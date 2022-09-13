--
-- FileName: qingming_gs.lua
-- Author: lgy&lqy
-- Time: 2012/4/5 10:53
-- Comment:
--
if not MODULE_GAMESERVER then
	return 0;
end

Require("\\script\\event\\jieri\\201204_qingming\\qingming_def.lua");

local tbQingMing2012 = SpecialEvent.tbQingMing2012;

-- 检查当前时间是否在活动时间内, 注意[nStartTime,nEndTime)是一个半闭半开区间
function tbQingMing2012:IsInTime()
	if self.bOpen ~= 1 then 
		return 0, "活动还没开启。";
	end
	local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
	if nNowTime < self.nStartTime then
		return 0, "活动还没有开始。";
	end
	if nNowTime >= self.nEndTime then
		return 0, "活动已经结束了。";
	end
	return 1;
end

--队员是否满足领奖条件
function tbQingMing2012:CanShowMoney(pPlayer)
	
	if not pPlayer then
		return 0, "玩家不存在。";
	end
	
	--通用资格检查
	local bOk, szErrorMsg = self:CommonCheck(pPlayer);
	if bOk == 0 then
		return 0, szErrorMsg;
	end
	
	return 1;
end

-- 检查指定的玩家是否满足加工赎魂灯的条件
function tbQingMing2012:CanProduceShuHunDeng(pPlayer, nNumber)
	if nNumber <= 0 then
		return 0, "输入的数值不正确。";
	end
	
	if not pPlayer then
		return 0, "玩家不存在。";
	end
	
	--通用资格检查
	local bOk, szErrorMsg = self:CommonCheck(pPlayer);
	if bOk == 0 then
		return 0, szErrorMsg;
	end
	
	-- 检查幽冥灯数量
	local nCount = pPlayer.GetItemCountInBags(unpack(self.nQingMingYouMinDengId ));
	if nCount < nNumber then
		return 0, "你身上幽冥灯不足。";
	end

	-- 检查精力
	if pPlayer.dwCurMKP < self.nCostMKP * nNumber then
		return 0, "你的精力不足。";
	end

	-- 检查活力
	if pPlayer.dwCurGTP < self.nCostGTP * nNumber then
		return 0, "你的活力不足。";
	end
	local tbAward = self.nQingMingYouMinDengId;
	-- 检查背包空间
	local nNeedBag = KItem.GetNeedFreeBag(tbAward[1], tbAward[2], tbAward[3], tbAward[4], nil, nNumber);
	if pPlayer.CountFreeBagCell() < nNeedBag then
		return 0, "你的背包空间不足，请先整理出" .. tostring(nNeedBag) .. "个背包空间。";
	end

	return 1;
end

--完成祭祀
function tbQingMing2012:FinishJiSi(pPlayer, pItem, szType)

	if not pPlayer then
		return;
	end

	if not pItem then
		pPlayer.Msg("你使用的幽冥灯不知道怎么的不见了。");
		return;
	end
	local tbMemberId, nMemberCount = KTeam.GetTeamMemberList(pPlayer.nTeamId);
	if not tbMemberId then
		return;
	end
	
	local nMapId, nNpcX, nNpcY = pPlayer.GetWorldPos();
	--灯笼,释放一个特效
	pPlayer.CastSkill(self.nDengLong,30,-1,pPlayer.GetNpc().nIndex);
	--鲜花
	local nRand = MathRandom(1, 2);
	local pNpc = KNpc.Add2(self.tbXianHua[nRand], 1, -1,nMapId, nNpcX, nNpcY);
	if pNpc then
		pNpc.SetLiveTime(self.nXianHuaLiveTime);
		pNpc.szName = ""
		pNpc.SetTitle(string.format("<color=gold>%s<color><color=green>队伍的烛魂花<color>", pPlayer.szName));
	end
	
	--先发英魂简
	for _, nMemberId in pairs(tbMemberId) do
		local pMember = KPlayer.GetPlayerObjById(nMemberId);
		if not pMember then 
			return;
		end
		
		if pMember.GetTask(self.TASKGID,self.TASK_HAVEYINGHUNJIAN) == 0 then
			--今天第一次点亮
			if self:CheckHighCity(pMember) == 1 then 
				--发放卡片
				pMember.AddItem(unpack(self.nYingHunJianId));
				pMember.SetTask(self.TASKGID,self.TASK_HAVEYINGHUNJIAN,1);
			end
		end
	end
	
	--移除队长物品,用啥删啥
	if szType == "YouMinDeng" then
		local nRet = pItem.Delete(me);
		if nRet ~= 1 then
			return 0;
		end
		pPlayer.Msg("你进行了祭祀，消耗了一个幽冥灯。")
		self:ShowMeTheMoney(pPlayer, nMemberCount, "YouMinDeng")
	elseif szType == "ShuHunDeng" then
		local nRet = pItem.Delete(me);
		if nRet ~= 1 then
			return 0;
		end
		pPlayer.Msg("你进行了祭祀，消耗了一个赎魂灯。")
		self:ShowMeTheMoney(pPlayer, nMemberCount, "ShuHunDeng")
	else
		return 0;
	end
	
	--记录log
	if self:CheckFirstJiSi(pPlayer) == 1 then
		StatLog:WriteStatLog("stat_info", "qingmingjie2012", "worship", pPlayer.nId, 1);	
	end
	
	for _, nMemberId in pairs(tbMemberId) do
		local pMember = KPlayer.GetPlayerObjById(nMemberId);
		if not pMember then 
			return;
		end
		
		--队长排除
		if nMemberId ~= nPlayerId then
			local nCountYouMing = pMember.GetItemCountInBags(unpack(self.nQingMingYouMinDengId));
			local nCountShuHun  = pMember.GetItemCountInBags(unpack(self.nQingMingShuHunDengId));
			if nCountShuHun > 0 then
			 	pMember.ConsumeItemInBags(1,unpack(self.nQingMingShuHunDengId));
			 	pMember.Msg("你进行了祭祀，消耗了一个赎魂灯。")
			 	self:ShowMeTheMoney(pMember, nMemberCount, "ShuHunDeng")
			else
				pMember.ConsumeItemInBags(1,unpack(self.nQingMingYouMinDengId));
				pMember.Msg("你进行了祭祀，消耗了一个幽冥灯。")
				self:ShowMeTheMoney(pMember, nMemberCount, "YouMinDeng")
			end
			--记录log
			if self:CheckFirstJiSi(pMember) == 1 then
				StatLog:WriteStatLog("stat_info", "qingmingjie2012", "worship", pMember.nId, 1);	
			end
		end
		--祭祀城市
		pMember.SetTask(self.TASKGID,self.TASK_CITY_JISI[pMember.nMapId],1);
		
		--点亮卡片
		pMember.SetTask(self.TASKGID,self.TASK_CITY_HIGH[pMember.nMapId],1);
		
		--发黑条
		Dialog:SendBlackBoardMsg(pMember, string.format("你在%s成功的进行了祭祀。愿英魂安宁，浩气长存！",self.CityName[pMember.nMapId]));
	end
end

--获得一次随机奖励
function tbQingMing2012:RandomAward(pPlayer, nCount)
	
	if not pPlayer then
		return 0;
	end
	--人数异常
	
	if nCount > 6 or nCount <= 0 then 
		return 0; 
	end	
	
	--能否领奖
	if self:CanShowMoney(pPlayer) ~= 1 then 
		return 0; 
	end	
	
	--随机奖励
	local nFind = 0;
	local nAdd = 0;
	local nRand = MathRandom(1, 1000000);
	for i = 1, #self.AWARD_LIST do
		nAdd = nAdd + self.AWARD_LIST[i][4];
		if nAdd >= nRand then
			nFind = i;
			break;
		end
	end

	--发放奖励
	if nFind >= 0 then
		local tbAward = self.AWARD_LIST[nFind];
		-- add award
		if tbAward[1] =="stone" then
			local nStone = self:ChangeStoneType(tbAward[5], nCount);
			pPlayer.AddStackItem(self.tbGiveStone[nStone][1], self.tbGiveStone[nStone][2], self.tbGiveStone[nStone][3], self.tbGiveStone[nStone][4], nil,tbAward[3]);
			return 1;
		end
		if tbAward[1] =="money" then
			local nValue = self:ChangeMoneyValue(tbAward[3], nCount);
			if pPlayer.GetBindMoney() + nValue > pPlayer.GetMaxCarryMoney() then
				pPlayer.Msg("您的携带的绑定银两过多。");
				return 0;
			end
			pPlayer.AddBindMoney(nValue);
			return 1;
		end
		if tbAward[1] =="gold"  then
			local nValue = self:ChangeMoneyValue(tbAward[3], nCount);
			pPlayer.AddBindCoin(nValue);
			return 1;
		end
	end
end

--变石头
function tbQingMing2012:ChangeStoneType(nStone, nCount)
	
	--加成值 10到50
	local p = math.floor((nCount - 1) * self.Bonus_ShuHunDeng * 10000 / 2.4); 
	local nRand = MathRandom(1, 10000);
	if nRand <= p then
		return nStone + 1;
	end
	return nStone;
end

--涨奖励
function tbQingMing2012:ChangeMoneyValue(nValue, nCount)
	
	--加成值 10到50
	local p =(nCount - 1) * self.Bonus_ShuHunDeng;
	return nValue * (1 + p);	
end

--发放奖励
function tbQingMing2012:ShowMeTheMoney(pPlayer, nCount, szType)

	if not pPlayer then
		return;
	end
	
	--人数异常
	if nCount > 6 or nCount <= 0 then 
		return; 
	end
	
	--能否领奖
	if self:CanShowMoney(pPlayer) ~= 1 then 
		return; 
	end
	
	--赎魂灯随机三次
	if szType == "ShuHunDeng" then
		for i = 1, 3 do
			self:RandomAward(pPlayer, nCount);
		end
		return;
	end
	
	--幽冥灯随机一次
	if szType == "YouMinDeng" then
		self:RandomAward(pPlayer, nCount);
		return;
	end
end

--检查是不是第一次点亮
function tbQingMing2012:CheckHighCity(pPlayer)
	if not pPlayer then
		return;
	end
	for _,nTaskId in pairs(self.TASK_CITY_HIGH) do
		local nV = pPlayer.GetTask(self.TASKGID,nTaskId);
		if nV == 1 then
			return 0;
		end
	end
	return 1;
end

--检查是不是第一次祭祀（数据埋点用）
function tbQingMing2012:CheckFirstJiSi(pPlayer)
	if not pPlayer then
		return;
	end
	for _,nTaskId in pairs(self.TASK_CITY_JISI) do
		local nV = pPlayer.GetTask(self.TASKGID,nTaskId);
		if nV == 1 then
			return 0;
		end
	end
	return 1;
end

--检查指定的玩家最多可以加工多少个赎魂灯
function tbQingMing2012:CheckMostNumber(pPlayer)
	
	-- 检查玩家
	if not pPlayer then
		return 0;
	end

	--取得最多可以加工多少个赎魂灯
	local nCountYouMing = pPlayer.GetItemCountInBags(unpack(self.nQingMingYouMinDengId));
	local nCountMKP     = math.floor(pPlayer.dwCurMKP / self.nCostMKP);
	local nCountGTP     = math.floor(pPlayer.dwCurGTP / self.nCostGTP);
		
	--取最小值
	local nMax = math.min(nCountYouMing, math.min(nCountMKP, nCountGTP));
	return nMax;
end

-- 检查指定的玩家是否满足使用的条件
function tbQingMing2012:CanUseShuHunDeng(pPlayer)
	
	if not pPlayer then
		return 0, "玩家不存在。";
	end
	
	--通用资格检查
	local bOk, szErrorMsg = self:CommonCheck(pPlayer);
	if bOk == 0 then
		return 0, szErrorMsg;
	end

	--只能在新手村使用
	local szMapClass = GetMapType(pPlayer.nMapId) or ""
	if szMapClass ~= "village" then
		return 0,"该道具只能在新手村使用。";
	end
	
	-- 是否组队
	local tbMemberId, nMemberCount = KTeam.GetTeamMemberList(pPlayer.nTeamId);
	if not tbMemberId then
		return 0,"请叫齐你的伙伴一起组队吧。";
	end

	--检查队长，必须是队长才可以使用道具
	if pPlayer.IsCaptain() ~= 1 then
		return 0,"你不是队长，必须由队长来使用赎魂灯或者幽冥灯。";
	end

	-- 所有成员在附近
	local nNearby = 0;
	local tbPlayerList = KPlayer.GetAroundPlayerList(pPlayer.nId, 50);
	for _, tbRound in pairs(tbPlayerList or {}) do
		for _, nMemberId in pairs(tbMemberId) do
			local pMember = KPlayer.GetPlayerObjById(nMemberId);
			if pMember and pMember.szName == tbRound.szName then
				nNearby = nNearby + 1;
			end
		end
	end
	if nNearby ~= nMemberCount then
		return 0,"你的队友离得太远了，请叫他们都过来吧。";
	end
	
	--所有成员都未祭祀过此城市
	for _, nMemberId in pairs(tbMemberId) do
		local pMember = KPlayer.GetPlayerObjById(nMemberId);
		if pMember then
			
			local nV = pMember.GetTask(self.TASKGID,self.TASK_CITY_JISI[pMember.nMapId])
			if 	nV == 1 then
				return 0,"你的队友<color=red>"..pMember.szName.."<color>今天已经祭祀过这里了。";
			end
			
			-- 检查门派,必须加入门派才能参加活动
			if pMember.nFaction <= 0 then
				return 0, "你的队友<color=red>"..pMember.szName.."<color>没有加入门派。";
			end

			-- 检查级别
			if pMember.nLevel < tbQingMing2012.nMinLevel then
				return 0, "你的队友<color=red>"..pMember.szName.."<color>等级不够。";
			end
			
			-- 检查幽冥灯数量
			local nCountYouMing = pMember.GetItemCountInBags(unpack(self.nQingMingYouMinDengId ));
			local nCountShuHun  = pMember.GetItemCountInBags(unpack(self.nQingMingShuHunDengId ));
			if nCountYouMing == 0 and  nCountShuHun == 0 then
				local szMsg = "<color=red>"..pMember.szName.."<color>身上没有幽冥灯或者赎魂灯，不能进行祭祀。"
				return 0,szMsg;
			end
			
			if pMember.CountFreeBagCell() < 4 then
				return 0, string.format("队友%s的背包空间不足4 ô.", pMember.szName);
			end
		end
	end

	--确定周围没有NPC
	local nPosOk, szPosMsg = self:GetAPos(pPlayer);
	if nPosOk == 0 then
		return 0, szPosMsg;	
	end

	return 1;
end

-- 检查指定的玩家是否满足使用英灵挑战令召唤BOSS的条件
function tbQingMing2012:CanCallYingLingBoss(pPlayer)

	if not pPlayer then
		return 0, "玩家不存在。";
	end
	
	--通用资格检查
	local bOk, szErrorMsg = self:CommonCheck(pPlayer);
	if bOk == 0 then
		return 0, szErrorMsg;
	end

	-- 检查英灵挑战令的数量
	local nCount = pPlayer.GetItemCountInBags(unpack(self.nQingMingTiaoZhanLingId));
	if nCount < 1 then
		return 0, "你没有英灵挑战令，无法召唤BOSS。";
	end

	--检查家族族长
	if self:CheckKinCaptain(pPlayer) ~= 1 then
		return 0,"你不是家族族长，必须由家族族长来召唤英灵！";
	end

	-- 野外打怪地图
	local nMapId = pPlayer.GetWorldPos();
	if GetMapType(nMapId) ~= "fight" then
		return 0, "对不起，此区域无法使用挑战令，请到野外地图再使用。";
	end

	return 1;
end

--检查指定的玩家是否满足60级，是否加入门派
function tbQingMing2012:CheckLevelFaction(pPlayer)

	-- 检查门派,必须加入门派才能参加活动
	if pPlayer.nFaction <= 0 then
		return 0, "你没有加入门派。";
	end

	-- 检查级别
	if pPlayer.nLevel < tbQingMing2012.nMinLevel then
		return 0, "你的等级不够。";
	end
	return 1;

end

-- 检查玩家是否是家族族长或者副族长
function tbQingMing2012:CheckKinCaptain(pPlayer)
	local nKinId, nMemberId = pPlayer.GetKinMember();
	if nKinId == 0 or nMemberId == 0 then
		return 0;
	end
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId);
	if not cMember then
		return 0;
	end
	if Kin:CheckSelfRight(nKinId, nMemberId, Kin.FIGURE_ASSISTANT) ~= 1 then
		return 0;
	end
	return 1, nKinId, nMemberId;
end

-- 在pPlayer周围是否有功能NPC
function tbQingMing2012:GetAPos(pPlayer)
	local nMapId, nPosX, nPosY = pPlayer.GetWorldPos();
	local tbNpcList = KNpc.GetAroundNpcList(pPlayer, 10);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nKind == 3 then
			return 0, "这个位置会把其他人挡住，还是挪个地方吧。";
		end
	end
	return 1;
end

-- 检查指定的玩家是否能从英灵npc上获得奖励吗
function tbQingMing2012:CanGetAwardFrom(pPlayer, pNpc)
	if not pNpc then
		return 0, "英灵已经消失了。";
	end

	if not pPlayer then
		return 0, "玩家不存在。";
	end
	
	--通用资格检查
	local bOk, szErrorMsg = self:CommonCheck(pPlayer);
	if bOk == 0 then
		return 0, szErrorMsg;
	end

	--该玩家的家族id，有没有加入家族
	local nPlayerKinId, nPlayerMemberId = pPlayer.GetKinMember();
	if nPlayerKinId == 0 then
		return 0, "你还没有加入家族。";
	end
	 
	-- 检查背包空间
	if pPlayer.CountFreeBagCell() < tbQingMing2012.nMinFreeBagNpcLingJiang then
		local szRetMsg = "领取奖励需要" .. tostring(tbQingMing2012.nMinFreeBagCellCount) .."个背包空间，请清理出一个背包空间后再来领取奖励。";
		return 0,  szRetMsg;
	end
	
	local tbTemp = pNpc.GetTempTable("Npc");
	if not tbTemp then
		return 0, "召唤该英灵家族不存在。";
	end
	
	--玩家当天是否领过奖了
	if tbTemp.tbGetPlayers[pPlayer.nId] then
		return 0,"您已经领取过奖励了，不能再领奖了！" ;
	end
	

	if not tbTemp.nKinId then
		return 0, "召唤该英灵家族不存在。";
	end
	
	--召唤英灵的家族id 和该玩家的家族id
	local cKinPlayer = KKin.GetKin(nPlayerKinId);
	if not cKinPlayer  then
		return 0, "您没有家族不能领取奖励。";
	end
	local cMemberPlayer = cKinPlayer.GetMember(nPlayerMemberId);
	if not cMemberPlayer then
		return 0, "您没有家族不能领取奖励。";
	end
	
	if  tbTemp.nKinId == nPlayerKinId and ((cMemberPlayer.GetFigure() <= Kin.FIGURE_REGULAR) or (cMemberPlayer.GetFigure() == Kin.FIGURE_RETIRE)) then
		return 1;
	else
		return 0, "我不记得你通过了考验……要时刻记得，诚意正心。";
	end
	
	return 1;
end

--是否能领取挑战令
function tbQingMing2012:CanGetTiaoZhanLin(pPlayer)
	
	--通用资格检查
	local bOk, szErrorMsg = self:CommonCheck(pPlayer);
	if bOk == 0 then
		return 0, szErrorMsg;
	end

	--家族
	local nKinId, nMemberId = pPlayer.GetKinMember();	
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0, "对不起，你还没有家族，等你有了家族再来找我吧。";
	end
	
	--是否为族长/副族长
	local nCapOk = self:CheckKinCaptain(pPlayer);
	if nCapOk ~= 1 then
		return 0, "对不起，你不是族长/副族长，无法进行领取！"
	end
	
	--家族排行
	local nKinRank = HomeLand:GetKinRank(nKinId);
	if nKinRank <= 0 or nKinRank > self.nGetTiaoZhanLinKinLvl then
		return 0, "对不起，你的家族威望排行未达到领取条件，无法进行领取！";
	end
	
	if pPlayer.CountFreeBagCell() < 1 then
		return 0,  "Hành trang không đủ chỗ trống，无法进行领取！";
	end
	
	local bGet = self.tbKinGet[nKinId] or 0;
	if bGet == 1 then
		return 0,  "你的家族今天已经领取过英灵挑战令了！";
	end
	
	return 1;
end

--添加NPC
function tbQingMing2012:AddNpc()
	for _,tbPoint in pairs(self.tbNpc) do
		if SubWorldID2Idx(tbPoint[1]) >= 0 then
			KNpc.Add2(self.nQingMing_NpcId,1, -1,tbPoint[1],tbPoint[2],tbPoint[3]);
		end
	end
end

--服务器启动事件
function tbQingMing2012:OnServerStart()
	if self.bOpen ~= 1 then 
		return;
	end
	self:AddNpc();	
end

-- 每日事件
function tbQingMing2012:DailyEvent_GS()
	me.SetTask(self.TASKGID, self.TASK_LINGJIANG, 0);
	me.SetTask(self.TASKGID, self.TASK_COUNT_YOUMINDENG, 0);
	me.SetTask(self.TASKGID, self.TASK_LINGJIANG_BOSS, 0);
	--清除祭祀信息
	for _,nTaskId in pairs(self.TASK_CITY_JISI) do
		me.SetTask(self.TASKGID,nTaskId, 0);
	end
	--清除点亮信息
	for _,nTaskId in pairs(tbQingMing2012.TASK_CITY_HIGH) do
		me.SetTask(self.TASKGID,nTaskId, 0);
	end
end

--通用资格检查
function tbQingMing2012:CommonCheck(pPlayer)
	-- 先检查时间
	local bOk = self:IsInTime();
	if bOk == 0 then
		return 0, "不在清明节活动期间，不能领取挑战令。";
	end
	if pPlayer.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang bị khóa, không thể thao tác!");
		return 0;
	end
	
	--检查玩家，级别，门派
	local bOk, szErrorMsg = self:CheckLevelFaction(pPlayer);
	if bOk == 0 then
		return 0, szErrorMsg;
	end
	
end

--同步挑战令领取数据，GC调用
function tbQingMing2012:UpdateKinGet_GS(nKinId, nValue)
	self.tbKinGet[nKinId] = nValue;
end

--每日清除挑战令领取数据，GC调用
function tbQingMing2012:ClearKinGet_GS()
	self.tbKinGet = {};
end


if tonumber(os.date("%Y%m%d",GetTime())) <= tbQingMing2012.nEndTime then 
	
	--注册启动回调
	ServerEvent:RegisterServerStartFunc(SpecialEvent.tbQingMing2012.OnServerStart, SpecialEvent.tbQingMing2012);
	
	--注册每日事件
	PlayerSchemeEvent:RegisterGlobalDailyEvent({SpecialEvent.tbQingMing2012.DailyEvent_GS, SpecialEvent.tbQingMing2012});
end
