--
-- FileName: shengxia_gs.lua
-- Author: lgy
-- Time: 2012/7/5 10:53
-- Comment:
--
if not MODULE_GAMESERVER then
	return 0;
end

Require("\\script\\event\\jieri\\201204_qingming\\qingming_def.lua");

local tbShengXia2012 = SpecialEvent.tbShengXia2012;

-- 检查当前时间是否在活动时间内, 注意[nStartTime,nEndTime)是一个半闭半开区间
function tbShengXia2012:IsInTime()
	if self.bOpen ~= 1 then 
		return 0;
	end
	local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
	if nNowTime < self.nStartTime then
		return 0;
	end
	if nNowTime >= self.nEndTime then
		return 0;
	end
	return 1;
end

--检查指定的玩家是否满足60级，是否加入门派
function tbShengXia2012:CheckLevelFaction(pPlayer)

	-- 检查门派,必须加入门派才能参加活动
	if pPlayer.nFaction <= 0 then
		return 0, "你没有加入门派。";
	end

	-- 检查级别
	if pPlayer.nLevel < tbShengXia2012.nMinLevel then
		return 0, "你的等级不够。";
	end
	return 1;

end

--通用资格检查
function tbShengXia2012:CommonCheck(pPlayer)
	-- 先检查时间
	local bOk = self:IsInTime();
	if bOk == 0 then
		return 0, "不在盛夏动期间。";
	end
	if not pPlayer then
		return 0, "玩家不存在。";
	end
	if pPlayer.IsAccountLock() ~= 0 then
		return 0,"Tài khoản đang bị khóa, không thể thao tác!";
	end
	
	--检查玩家，级别，门派
	local bOk, szErrorMsg = self:CheckLevelFaction(pPlayer);
	if bOk == 0 then
		return 0, szErrorMsg;
	end
	
end

--清除玩家竞猜信息
function tbShengXia2012:ClearJingCai(pPlayer)
	if not pPlayer then
		return 0;
	end
	pPlayer.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JINGCAI,0)
	pPlayer.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JINGCAIBEISHU, 0);
	for i=1,2 do
		pPlayer.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JINGCAIID[i], 0);
	end
	pPlayer.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JINGCAIDAYID, 0);
	return 1;
end

--获取玩家竞猜信息,竞猜倍数，竞猜流水号，是否为当天竞猜
function tbShengXia2012:GetJingCaiInfo(pPlayer)
	if not pPlayer then
		return 0;
	end
	
	local nMyBeiShu  = pPlayer.GetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JINGCAIBEISHU);
	local nMyDay     = pPlayer.GetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JINGCAIDAYID);	
	local nYesterday = KGblTask.SCGetDbTaskInt(DBTASK_SHENGXIA_DAY);
	local nToday     = nYesterday + 1;
	local bToday     = 0;
	if  (nMyDay == nToday) or  (nMyDay == 0) then
		bToday = 1;
	end
	return nMyBeiShu, nMyDay, bToday, nToday; 
end

--设置玩家竞猜信息
function tbShengXia2012:SetJingCaiInfo(pPlayer, nBeiShu, nMyDay, nJingCai)
	if (pPlayer and nBeiShu and nMyDay and nJingCai) then
		pPlayer.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JINGCAIBEISHU, nBeiShu);
		pPlayer.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JINGCAIDAYID, nMyDay);
		pPlayer.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JINGCAIID[nBeiShu], nJingCai);
		return 1;
	else
		return 0,"参数错误";
	end
end

--获取随即表，最大绑银值
function tbShengXia2012:GetMaxBandMoney(tbAward)
	if not tbAward then
		return 0, "奖励不存在。";
	end
	local nMaxValue = 0;
	for _, tb in ipairs(tbAward or {}) do
		if tb.type == "绑银" and nMaxValue < tb.value then
			nMaxValue = tb.value;
		end
	end
	return nMaxValue;
end

--遍历奖励
function tbShengXia2012:ReturnXuan(tbVar)
	local tbXuanJing = {};
	local nNumber =0;
	for k, v in pairs(tbVar) do
		if tbVar[k][1] == "玄晶" then
			tbXuanJing[#tbXuanJing +1] = tbVar[k][2];
			nNumber = nNumber + 1;
		end
	end
	return nNumber,tbXuanJing;
end

--给予奖励
function tbShengXia2012:RandomItem(pPlayer, tbAward)
	if not pPlayer then
		return 0, "玩家不存在。";
	end
	
	local nRate = MathRandom(1000000);
	local nTotalCount = 0;
	for _, tb in ipairs(tbAward) do
		nTotalCount = nTotalCount + tb[3];
		if nRate <= nTotalCount then
			local nType = 0;
			if  tb[1] == "玄晶" then
				pPlayer.AddItemEx(18,1,114, tb[2],nil);
				return 1, tb[2].."级玄晶", 1, tb[2];
			elseif tb[1] == "绑金" then
				pPlayer.AddBindCoin(tb[2]);
				return 1, tb[2].."绑金", 2, tb[2];
			elseif tb[1] == "绑银" then
				local nBindMoney = math.floor(tb[2]);
				pPlayer.AddBindMoney(nBindMoney);
				return 1, nBindMoney.."绑银", 3, nBindMoney;
			end
		end
	end
end

--买东西
function tbShengXia2012:BuyItem(nIndex, nFlag, nNum)
	if not nFlag then
		Dialog:AskNumber("请输入您要购买物品的数量", 10, tbShengXia2012.BuyItem, tbShengXia2012, nIndex,1);
		return;
	end
	local tbBuyItem = {[1] = {621, 20}, [2] = {622, 2000}};
	if nIndex <= 0 or nIndex > 2 then
		return;
	end
	if nNum <= 0 then
		Dialog:Say("您输入的数目不正确。");
		return;
	end
	if me.nCoin < tbBuyItem[nIndex][2] * nNum then
		Dialog:Say("您的金币不足！", {{"我知道啦"}});
		return;
	end
	if me.CountFreeBagCell() < nNum then
		Dialog:Say("Hành trang không đủ chỗ trống.", {{"我知道啦"}});
		return;
	end
	me.ApplyAutoBuyAndUse(tbBuyItem[nIndex][1], nNum, 0);
	return;
end

--添加NPC
function tbShengXia2012:AddNpc()
	for _,tbPoint in pairs(self.tbNpc) do
		if SubWorldID2Idx(tbPoint[1]) >= 0 then
			KNpc.Add2(self.nShengXia_NpcId,1, -1,tbPoint[1],tbPoint[2],tbPoint[3]);
		end
	end
end

--获取当前中国队获取的金银铜牌以及总数，nType为1是总数，2为上个比赛日
function tbShengXia2012:GetJiangPai(nType)
	local nYesterday = KGblTask.SCGetDbTaskInt(DBTASK_SHENGXIA_DAY);
	if nYesterday < 1 then
		return 0,0,0,0;
	end
	local nYesterdayG = 0;
	local nYesterdayS = 0;
	local nYesterdayB = 0;
	local nCount = 0 ;
	if nType == 2 then
		nYesterdayG = tbShengXia2012.tbGlobalBuffer[nYesterday][1];
		nYesterdayS = tbShengXia2012.tbGlobalBuffer[nYesterday][2];
		nYesterdayB = tbShengXia2012.tbGlobalBuffer[nYesterday][3];
		nCount = tbShengXia2012.tbGlobalBuffer[nYesterday][4];
		return nYesterdayG,nYesterdayS,nYesterdayB,nCount;
	end
	if nType == 1 then
		for i =1,nYesterday do
			nYesterdayG = nYesterdayG + tbShengXia2012.tbGlobalBuffer[i][1];
			nYesterdayS = nYesterdayS + tbShengXia2012.tbGlobalBuffer[i][2];
			nYesterdayB = nYesterdayB + tbShengXia2012.tbGlobalBuffer[i][3];
			nCount = nCount + tbShengXia2012.tbGlobalBuffer[i][4];
		end
		return nYesterdayG,nYesterdayS,nYesterdayB,nCount;
	end
	return;
end

--载入缓存数据
function tbShengXia2012:LoadBuffer_GS()
	if self:IsInTime() ~= 1 then
		return;
	end
	local tbLoadBuffer = GetGblIntBuf(self.BUFFER_INDEX, 0);
	if tbLoadBuffer and type(tbLoadBuffer) == "table" then
		self.tbGlobalBuffer = tbLoadBuffer;
	end
end

-- 每日事件
function tbShengXia2012:DailyEvent_GS()
	me.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_JIANDING, 0);
	me.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_HUIHUANG, 0);
	me.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_LINGHUOYUEDU1, 0);
	me.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_LINGHUOYUEDU2, 0);
	me.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_LINGHUOYUEDU3, 0);
	me.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_HUIHUANGXIAOYAO, 0);
	me.SetTask(tbShengXia2012.TASKGID, tbShengXia2012.TASK_HUIHUANGJUNYING, 0);	
end

--清楚缓存数据
function tbShengXia2012:ClearBuffer_GS()
	self.tbGlobalBuffer = {};
end

--修改概率指令
function tbShengXia2012:SetProbability(nId, nValue)
	tbShengXia2012.tbPaiZi[nId]	= nValue;						--牌子概率
end

--测试用集卡册
function tbShengXia2012:SetCard(nStart, nEnd)
	for i = nStart, nEnd do
		me.SetTask(tbShengXia2012.TASKGID, i ,1);
	end
	local nNumber = me.GetTask(tbShengXia2012.TASKGID,tbShengXia2012.TASK_DIANLIANG);
	nNumber = nNumber + nEnd - nStart + 1;
	me.SetTask(tbShengXia2012.TASKGID,tbShengXia2012.TASK_DIANLIANG,nNumber);			
end

--注册服务器重启事件，载入缓存数据
ServerEvent:RegisterServerStartFunc(tbShengXia2012.LoadBuffer_GS, tbShengXia2012);
PlayerSchemeEvent:RegisterGlobalDailyEvent({tbShengXia2012.DailyEvent_GS, tbQingMing2012});