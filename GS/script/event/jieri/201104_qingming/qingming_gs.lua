--
-- FileName: qingming_gs.lua
-- Author: hanruofei
-- Time: 2011/4/5 10:53
-- Comment:
--

SpecialEvent.tbQingMing2011 =  SpecialEvent.tbQingMing2011 or {};
local tbQingMing2011 = SpecialEvent.tbQingMing2011;

function tbQingMing2011:GetAwardTable(nGroupId, bIsCaller)
	for _, v in pairs(self.tbBossGroups) do
		if v.nGroupId == nGroupId then
			if bIsCaller then
				return 1, v.tbAward.Caller;
			end
			return 1, v.tbAward.Helper;
		end
	end
	return 0, "没有对应级别为" .. tostring(nGroupId) .. "的奖励"
end

-- 获得一个随机BOSS
function tbQingMing2011:GetARandomBoss()
	local nValue = MathRandom(10000);
	for k, v in ipairs(self.tbBossGroups) do
		if nValue <= v.nProbability then
			local nKey = MathRandom(#v.tbBosses);
			return k, self.tbBosses[v.tbBosses[nKey]];
		end
		nValue = nValue - v.nProbability;
	end
end
	
-- 检查当前时间是否在活动时间内, 注意[nStartTime,nEndTime)是一个半闭半开区间
function tbQingMing2011:IsInTime()
	local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
	if nNowTime < self.nStartTime then
		return 0, "活动还没有开始。";
	end
	if nNowTime >= self.nEndTime then
		return 0, "活动已经结束了。";	
	end
	return 1;
end

-- 检查指定的玩家是否满足加工清明挑战令的挑战
function tbQingMing2011:CanProduceQingMingTiaoZhanLing(nPlayerId)
	-- 先检查时间
	local bOk = self:IsInTime();
	if bOk == 0 then
		return 0, "不在清明节活动期间，清明玄香不能被加工成清明挑战令。";
	end
	
	-- 检查玩家
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0, "加工清明挑战令的玩家不存在。";
	end
	
	-- 检查门派,必须加入门派才能参加活动
	if pPlayer.nFaction <= 0 then
		return 0, "你没有加入门派。";
	end
	
	-- 检查级别
	if pPlayer.nLevel < tbQingMing2011.nMinLevel then
		return 0, "你的等级不够。";
	end
	-- 检查清明玄香数量
	local nCount = pPlayer.GetItemCountInBags(unpack(self.nQingMingXuanXiangId ));
	if nCount < self.nNeededCount then
		return 0, "你的清明玄香数量不足。";
	end
	-- 检查精力
	if pPlayer.dwCurMKP < self.nCostMKP then
		return 0, "你的精力不足。";
	end
	-- 检查活力
	if pPlayer.dwCurGTP < self.nCostGTP then
		return 0, "你的活力不足。"
	end
	-- 检查背包空间
	if pPlayer.CountFreeBagCell() < self.nMinFreeBagCellCount then
		return 0, "你的背包空间不足，请先整理出" .. tostring(self.nMinFreeBagCellCount) .. "个背包空间。";
	end

	return 1;
end

--获得使用清明挑战令的条件的字符串描述
function tbQingMing2011:GetCallQingMingBossConditionDescription()
	return [[由队长组队后在野外地图可以使用清明挑战令，清明挑战令可以召唤出四个档次的BOSS他们的档次从低到高分别是：清明行者，清明侠客，清明至仁，清明至圣。
    BOSS被击杀后将在附近出现一个“清明香炉”。召唤BOSS的玩家可以从香炉上领取相应的奖励。召唤出的BOSS档次越高所获得的奖励将越好。
    帮助队长击杀BOSS的队友，也可以从香炉中分享属于自己的那份奖励。每人在活动期间最多可分享其他玩家奖励9次。]]
end

-- 检查指定的玩家是否满足使用清明挑战令召唤BOSS的条件
function tbQingMing2011:CanCallQingMingBoss(nPlayerId)
	-- 先检查时间
	--local bOk, szErrorMsg = self:IsInTime();
	--if bOk == 0 then
		--return bOk, szErrorMsg;
	--end
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0, "使用清明挑战令的玩家不存在。";
	end
	
	-- 检查清明挑战令的数量
	local nCount = pPlayer.GetItemCountInBags(unpack(self.nQingMingTiaoZhanLing ));
	if nCount < 1 then
		return 0, "你没有清明挑战令，无法召唤BOSS。";
	end
	
	-- 等级检查
	if pPlayer.nLevel < self.nMinLevel then
		return 0, string.format("你的等级不够%d。", self.nMinLevel)
	end
	
	-- 检查门派,必须加入门派才能参加活动
	if pPlayer.nFaction <= 0 then
		return 0, "必须加入门派才能使用清明挑战令。";
	end
	
	if (not pPlayer.GetTeamMemberList()) then
		return 0, "你没有组队。";
	end
	
	if pPlayer.IsCaptain() == 0 then
		return 0, "你不是队长。";
	end

	-- 野外打怪地图
	local nMapId = pPlayer.GetWorldPos();
	if GetMapType(nMapId) ~= "fight" then
		return 0, "对不起，此区域无法使用挑战令，请到野外地图再使用。";
	end
	
	return 1;
end

function tbQingMing2011:GetNeededFreeBagCellCount(nGroupId)

	local bOk, tbAward = self:GetAwardTable(nGroupId, true);
	if bOk == 0 then
		return 0, "没有对应的奖励。";
	end
	return 1, tbAward[1];
	
end


-- 检查指定的玩家是否能从指定的香炉上获得奖励吗
function tbQingMing2011:CanGetAwardFrom(nPlayerId, nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0, "香炉已经消失了。";
	end
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0, "点击香炉的玩家不存在。";
	end
	
	if pPlayer.nLevel < self.nMinLevel then
		return 0, string.format("你的等级不够%d, 无法领取奖励。", self.nMinLevel);
	end
	
	-- 检查门派,必须加入门派才能参加活动
	if pPlayer.nFaction <= 0 then
		return 0, "必须加入门派才能领取奖励。";
	end
	
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp then
		return 0;
	end
	
	if not tbTemp.nCallerId then
		return 0;
	end
	if not tbTemp.nGroupId then
		return 0;
	end
	
	local pCaller = KPlayer.GetPlayerObjById(tbTemp.nCallerId);
	if not pCaller then
		return 0, "召唤BOSS的人不在线。";
	end
	
	if pCaller.nTeamId ~= pPlayer.nTeamId then
		return 0, "你和召唤BOSS的人不在同一个队伍中。";
	end
	
	if pCaller.IsCaptain() == 0 then
		return 0, "召唤BOSS的人已经不是队长了。";
	end
	
	if tbTemp.tbAwardedPlayerList[nPlayerId] == 1 then
		return 0, "你已经领过奖励了。";
	end
		
	if nPlayerId == tbTemp.nCallerId then
		-- 检查召唤的人是否领过了
		if tbTemp.bIsCallerAwarded then
			return 0, "你已经领过奖励了。";
		end
		
		-- 检查背包空间
		local bOk, nCount = self:GetNeededFreeBagCellCount(tbTemp.nGroupId)
		if bOk == 0 then
			return 0, tostring(nCount);
		end
		if pPlayer.CountFreeBagCell() < nCount then
			local szRetMsg = "领取奖励需要" .. tostring(nCount) .."个背包空间，请清理出一个背包空间后再来领取奖励。";
			return 0,  szRetMsg;
		end
	else
		-- 检查该香炉上的分享奖励是否已经领完了
		if Lib:CountTB(tbTemp.tbAwardedPlayerList) >= self.nMaxHelperAwardCount then
			return 0, "奖励已经领完了。";
		end
	
		-- 检查该玩家当天所领的分享奖励是否已经达到了上限
		local nDate = pPlayer.GetTask(self.TASKGID, self.TASK_DATE_AWARD_PER_DAY);
		local nNowDay = tonumber(GetLocalDate("%Y%m%d"));
		if nNowDay ~= nDate then
			pPlayer.SetTask(self.TASKGID, self.TASK_DATE_AWARD_PER_DAY, nNowDay);
			pPlayer.SetTask(self.TASKGID, self.TASK_AWARD_COUNT, 0);
		end
		
		local nAwardedCount = pPlayer.GetTask(self.TASKGID, self.TASK_AWARD_COUNT);
		if nAwardedCount >= self.nHelperAwardMaxCount then
			return 0, "你今天已经领的够多了，明天再来领吧。";
		end
	end
	
	return 1;
end

-- 增加奖励到玩家身上
function tbQingMing2011:AddAward(nPlayerId, nGroupId, bIsCaller)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0, "未知的玩家。";
	end
	
	local bOk, tbAward = self:GetAwardTable(nGroupId, bIsCaller);
	if bOk == 0 then
		return 0, "没有对应奖励。";
	end
	
	if bIsCaller then
		-- 检查背包空间
		if pPlayer.CountFreeBagCell() < tbAward[1] then
			local szRetMsg = "领取奖励需要" .. tostring(tbAward[1]) .."个背包空间，请清理出一个背包空间后再来领取奖励。";
			return 0,  szRetMsg;
		end
	
		for i = 1, tbAward[1] do
			local pAddedItem = pPlayer.AddItem(unpack(tbAward[2]));
			if pAddedItem then
				pAddedItem.SetTimeOut(0, GetTime() + self.nQingMingJiangLiDaiLiveTime);
				pAddedItem.Sync();
			end
		end
		
		Dialog:SendBlackBoardMsg(pPlayer, tbAward[3]);
		
		StatLog:WriteStatLog("stat_info", "qingmingjie2011", "kill_boss", nPlayerId, pPlayer.nTeamId);
		
	else
		if pPlayer.GetBindMoney() + tbAward[1] > pPlayer.GetMaxCarryMoney() then
			return 0, "您的携带的绑定银两过多，还是整理下再来领奖励吧。";
		end
		pPlayer.AddBindMoney(tbAward[1]);
	end
	
	return 1;
end

-- 获得指定nGroupId的召唤者所获取的领取的袋子类型,袋子分2种，0表示普通的青袋，1表示高级的袋子
function tbQingMing2011:GetAwardType(nGroupId)
	if nGroupId == 1 or nGroupId == 2 or nGroupId == 3 then
		return 0;
	end
	return 1;
end

-- 把加工清明挑战令的条件生成一条描述字符串
function tbQingMing2011:GetProduceConditionDescription()
	return 	string.format("只有等级大于等于%d并且加入了门派的玩家，才能在活动期间消耗%d精力和%d活力把%d个清明玄香加工成一个清明挑战令。", self.nMinLevel,
				self.nCostMKP, self.nCostGTP, self.nNeededCount);
end

-- 获得加工清明挑战令的提示信息
function tbQingMing2011:GetProduceNotifyMsg(pPlayer)
	local nProducedCount = pPlayer.GetTask(tbQingMing2011.TASKGID, tbQingMing2011.TASK_PRODUCED_COUNT);
	return string.format("你确定要消耗<color=gold>%d精力和%d活力<color>把%d个清明玄香加工成一个清明挑战令吗?\n<color=green>你已加工清明挑战令个数：%s/9<color>", self.nCostMKP, self.nCostGTP, self.nNeededCount, nProducedCount);
end
