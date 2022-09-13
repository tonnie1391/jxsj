-- 文件名　：worldcup_gs.lua
-- 创建者　：furuilei
-- 创建时间：2010-05-17 11:40:44
-- 功能描述：世界杯gs逻辑

SpecialEvent.tbWroldCup = SpecialEvent.tbWroldCup or {};
local tbEvent = SpecialEvent.tbWroldCup;
--====================================

-- 检查世界杯活动是否在开启状态
function tbEvent:CheckOpenState()
	local nCurDate = tonumber(os.date("%Y%m%d", GetTime()));
	if (nCurDate < tbEvent.TIME_START or nCurDate > tbEvent.TIME_END) then
		return 0;
	end
	return 1;
end

-- 返回活动的状态 0 未开启 1 正在进行中 2 活动结束兑换积分奖励时间 3 活动结束
function tbEvent:GetOpenState()
	local nCurDate = tonumber(os.date("%Y%m%d", GetTime()));
	if (nCurDate < tbEvent.TIME_START) then
		return 0;
	end
	
	if (nCurDate >= tbEvent.TIME_START and nCurDate <= tbEvent.TIME_END) then
		return 1;
	end
	
	if (nCurDate > tbEvent.TIME_END and nCurDate <= tbEvent.TIME_END_SCORE_AWARD) then
		return 2;
	end
	
	return 3;
end

--====================================

-- 根据卡片的index获取对应任务变量
function tbEvent:GetCardTaskIdByIndex(nIndex)
	if (not nIndex or nIndex <= 0) then
		return;
	end
	
	return self.TASKID_START + nIndex - 1;
end

-- 把index对应的卡片增减nNum个
function tbEvent:AddRecord(nIndex, nNum)
	if (not nIndex or nIndex <= 0 or nIndex > self.MAX_CARD_NUM) then
		return;
	end
	if (nNum and nNum <= 0) then
		return;
	end
	
	local nCurTskId = self:GetCardTaskIdByIndex(nIndex);
	if (not nCurTskId) then
		return;
	end
	
	nNum = nNum or 1;
	local nCurNum = me.GetTask(self.TASK_GROUP, nCurTskId) + nNum;
	me.SetTask(self.TASK_GROUP, nCurTskId, nCurNum);
end

-- 检查是否收集了全套卡品
function tbEvent:CheckHaveAllCards()
	for i = 1, self.MAX_TEAM_NUM do
		local nCurTskId = self:GetCardTaskIdByIndex(i);
		if (not nCurTskId) then
			return 0;
		end
		
		local nCurNum = me.GetTask(self.TASK_GROUP, nCurTskId);
		if (nCurNum <= 0) then
			return 0;
		end
	end
	
	return 1;
end

-- 设置各个球队卡片的价值量
function tbEvent:SetCardValue_GS(tbCardValue)
	if (not tbCardValue) then
		return;
	end
	self.tbCardValue = tbCardValue;
end

-- 设置各个球队的成绩等级
function tbEvent:SetTeamLevel_GS(tbTeamLevel)
	if (not tbTeamLevel) then
		return;
	end
	self.tbTeamLevel = tbTeamLevel;
end

-- 同步排名信息
function tbEvent:Sync2GS_RankInfo_GS(nRank, tbRankInfo)
	self.tbRankInfo = self.tbRankInfo or {};
	self.tbRankInfo[nRank] = tbRankInfo;
end

-- 更新排名信息
function tbEvent:UpdateRank_GS()
	self.bNeecReCalcValue = 1;
	self:UpdateRank();
end

-- 计算卡册的价值量，没有收入卡册的卡片不在计算范围之内
function tbEvent:CalcCardCollectionValue()
	local nValue = 0;
	for i = 1, tbEvent.MAX_CARD_NUM do
		local nTskId = self:GetCardTaskIdByIndex(i);
		local nCurCardNum = me.GetTask(tbEvent.TASK_GROUP, nTskId);
		local nCurCardValue = self.tbCardValue[i] or 1;
		nValue = nValue + (nCurCardNum * nCurCardValue);
	end
	return nValue;
end

--=====================================

-- 卡册回收
function tbEvent:RecycleCardCollection()
	local tbFind = me.FindItemInBags(unpack(tbEvent.tbGDPL_CARDCOLLECTION));	-- 玩家身上的卡册
	if (#tbFind <= 0) then
		Dialog:Say("请把卡册带在身上再来吧。");
		return 0;
	end
	
	local nValue = self:CalcCardCollectionValue();
	self:Recycle_GiveAward(nValue, tbFind);
end

-- 回收卡册，根据剩余价值量给予相应奖励
function tbEvent:Recycle_GiveAward(nValue, tbFind)
	if (not nValue or nValue <= 0) then
		return;
	end
	
	local nMoney = tbEvent.MONEY_PERPOINT * nValue;
	if (me.GetBindMoney() + nMoney > me.GetMaxCarryMoney()) then
		me.Msg("你的绑定银两快要超出上限了，还是等会再来交还卡册吧。");
		return;
	end
	
	for _, tbInfo in pairs(tbFind) do
		local pItem = tbInfo.pItem;
		if (pItem) then
			pItem.Delete(me);
		end
	end

	me.AddBindMoney(nMoney, Player.emKBINDMONEY_ADD_EVENT);
end

function tbEvent:ClearCardNum()
	for i = 1, tbEvent.MAX_CARD_NUM do
		local nTskId = self:GetCardTaskIdByIndex(i);
		me.SetTask(tbEvent.TASK_GROUP, nTskId, 0);
	end
end

--===================================

-- 兑换积分奖励时获取自己的排名信息
-- 返回值是自己当前在排行中的名次，如果没有排名，返回值nil
function tbEvent:ScoreAward_GetMyRankInfo()
	local nMyValue = self:CalcCardCollectionValue();
	local tbRankInfo = self.tbRankInfo or {};
	local nIndex = #tbRankInfo;
	local nLastValue = tbRankInfo[nIndex].nValue or 0;
	if (nMyValue < nLastValue and nIndex >= tbEvent.MAX_RANK_NUM) then
		return tbEvent.MAX_RANK_NUM + 1;
	end
	
	for i, tbInfo in ipairs(tbRankInfo) do
		if (tbInfo.szName == me.szName) then
			return i;
		end
	end
	
	for i = nIndex, 1, -1 do
		if (tbRankInfo[i].nValue >= nMyValue) then
			return i
		end
	end
	
	return tbEvent.MAX_RANK_NUM + 1;
end

function tbEvent:GetAwardList()
	local nMyRank = self:ScoreAward_GetMyRankInfo();
	if (not nMyRank) then
		return;
	end
	
	local nMyValue = self:CalcCardCollectionValue();
	if (not nMyValue or nMyValue <= 0) then
		return;
	end
	local tbAwardList = {};
	local tbFinalAward = tbEvent.TB_FINAL_AWARD;
	for i, tbAward in ipairs(tbFinalAward) do
		local nMinRank = tbAward.nMinRank;
		local nMaxRank = tbAward.nMaxRank;
		local nMinScore = tbAward.nMinScore;
		-- if (nMyRank >= nMinRank and nMyRank <= nMaxRank and nMyValue >= nMinScore) then
		if (nMyRank <= nMaxRank and nMyValue >= nMinScore) then
			tbAwardList = tbAward.tbAward;
			break;
		end
	end
	return tbAwardList;
end

function tbEvent:GiveFinalAward(tbAwardList)
	if (not tbAwardList) then
		return;
	end
	
	local nNeedCount = 0;
	for _, tbAward in pairs(tbAwardList) do
		local tbGDPL = tbAward.tbGDPL;
		local nCount = tbAward.nCount;
		local bStack = tbAward.bStack;
		if (tbGDPL and nCount) then
			if (bStack == 1) then
				nNeedCount = nNeedCount + 1;
			else
				nNeedCount = nNeedCount + nCount;
			end
		end
	end
	
	if (me.CountFreeBagCell() < nNeedCount) then
		Dialog:Say(string.format("领取奖励需要<color=yellow>%s<color>格包裹空间，你还是清理一下包裹再来领取吧。", nNeedCount));
		return;
	end
	
	for _, tbAward in pairs(tbAwardList) do
		local tbGDPL = tbAward.tbGDPL;
		local nCount = tbAward.nCount;
		if (tbGDPL and nCount) then
			for i = 1, nCount do
				me.AddItem(unpack(tbGDPL));
			end
		end
	end
	return 1;
end

-- 领取积分奖励
function tbEvent:GetScoreAward()
	if (me.GetTask(tbEvent.TASK_GROUP, tbEvent.TASKID_FLAG_GETAWARD) == 1) then
		Dialog:Say("你已经领取过积分奖励了，请不要重复领取。");
		return;
	end
	
	local tbAwardList = self:GetAwardList();
	if (not tbAwardList or #tbAwardList == 0) then
		Dialog:Say("您目前的积分不够领取奖励。");
		return;
	end
	
	local bGiveFinalAwardOk = self:GiveFinalAward(tbAwardList);
	if (bGiveFinalAwardOk and bGiveFinalAwardOk == 1) then
		me.SetTask(tbEvent.TASK_GROUP, tbEvent.TASKID_FLAG_GETAWARD, 1);
	end
end

--===================================

-- 获得卡片收集册
function tbEvent:GetCardCollection()
	local tbFind = me.FindItemInAllPosition(unpack(tbEvent.tbGDPL_CARDCOLLECTION));
	if (tbFind and #tbFind > 0) then
		Dialog:Say("你的卡册在你的包裹或者储物箱当中，不要重复领取。");
		return;
	end
	
	if (me.CountFreeBagCell() < 1) then
		Dialog:Say("请清理出1格包裹空间再来领取吧。");
		return;
	end
	
	local pItem = me.AddItem(unpack(tbEvent.tbGDPL_CARDCOLLECTION));
	if (pItem) then
		pItem.Bind(1);
		me.SetItemTimeout(pItem, tbEvent.TIME_OUT_DATE_CARDCOLLECTION, 0);
	end
end

--===================================

function tbEvent:UpdateRankInfo_GS()
	local nValue = self:CalcCardCollectionValue();
	if (not nValue or nValue <= 0) then
		return;
	end
	if (not self.tbRankInfo or
		not self.tbRankInfo[tbEvent.MAX_RANK_NUM] or 
		not self.tbRankInfo[tbEvent.MAX_RANK_NUM].nValue) then
		self:SyncMyRankInfo2GC();
		return;
	end
	if (nValue > self.tbRankInfo[tbEvent.MAX_RANK_NUM].nValue) then
		self:SyncMyRankInfo2GC();
	end
end

-- 组织自己的同步到gc的rankinfo
function tbEvent:GetMyRankInfo()
	local tbMyRankInfo = {};
	tbMyRankInfo.szName = me.szName;
	tbMyRankInfo.nValue = self:CalcCardCollectionValue();
	tbMyRankInfo.tbCardInfo = {};
	for i = 1, tbEvent.MAX_CARD_NUM do
		local nTskId = self:GetCardTaskIdByIndex(i);
		local nCurCardNum = me.GetTask(self.TASK_GROUP, nTskId);
		table.insert(tbMyRankInfo.tbCardInfo, nCurCardNum);
	end
	return tbMyRankInfo;
end

-- 把自己的信息同步到gc
function tbEvent:SyncMyRankInfo2GC()
	local tbMyRankInfo = self:GetMyRankInfo();
	if (not tbMyRankInfo) then
		return;
	end
	GCExcute({"SpecialEvent.tbWroldCup:SyncMyRankInfo_GC", tbMyRankInfo});
end

function tbEvent:SyncMyRankInfo_GS(tbMyRankInfo)
	if (not tbMyRankInfo) then
		return;
	end
	local pPlayer = KPlayer.GetPlayerByName(tbMyRankInfo.szName);
	if (pPlayer) then
		Setting:SetGlobalObj(pPlayer);
		local nMyValue = tbEvent:CalcCardCollectionValue();
		Setting:RestoreGlobalObj();
		pPlayer.CallClientScript({"SpecialEvent.tbWroldCup:OpenCollectionWnd_Client", tbEvent.tbTeamLevel, nMyValue});
	end
end

-- 获取自己的排名成绩
function tbEvent:GetMyRank_Num()
	local nMyRankNum = 0;
	local nMyValue = 0;
	for nIndex, tbInfo in ipairs(self.tbRankInfo) do
		if (me.szName == tbInfo.szName) then
			nMyRankNum = nIndex;
			nMyValue = tbInfo.nValue
			break;
		end
	end

	local szMsg = "";
	-- 显示前5名玩家的排名以及积分
	for i = 1, 5 do
		local tbInfo = self.tbRankInfo[i];
		if (tbInfo) then
			szMsg = szMsg .. string.format("第<color=yellow>%s<color>名  积分<color=yellow>%s<color>  <color=yellow>%s<color>\n",
				i, tbInfo.nValue or 0, tbInfo.szName or "");
		else
			break;
		end
	end
	if (nMyRankNum ~= 0) then
		szMsg = szMsg .. string.format("\n您的积分为%s，排名为%s。", nMyValue, nMyRankNum);
	else
		szMsg = szMsg .. string.format("\n您的积分为%s，由于您收集的积分过低，在排行榜中没有排名", nMyValue);
	end
	Dialog:Say(szMsg);
	return;
end

-- 世界杯卡片兑换奖励
function tbEvent:ExchangeAward()
	if (self:CheckHaveAllCards() ~= 1) then
		Dialog:Say("您的卡片没有收集够整套的，还是收集完一整套再兑换奖励吧。");
		return;
	end
	
	if (me.CountFreeBagCell() < 1) then
		Dialog:Say("请清理出至少1格背包空间再兑换奖励吧。");
		return;
	end

	if (self:ReduceAllCardsBy1() == 1) then
		self:UpdateRankInfo_GS();
		self:GetCardAward();
	end
end

-- 世界杯卡片奖励
function tbEvent:GetCardAward()
	local pItem = me.AddItem(unpack(tbEvent.tbGDPL_BOX));
	if (pItem) then
		pItem.Bind(1);
		Dialog:Say(string.format("你已经兑换了一个%s", pItem.szName));
	end
end

-- 所有的卡片数量减1，兑换卡片奖励的时候会用到
function tbEvent:ReduceAllCardsBy1()
	for i = 1, self.MAX_TEAM_NUM do
		local nCurTskId = self:GetCardTaskIdByIndex(i);
		if (not nCurTskId) then
			return 0;
		end
		
		local nCurNum = me.GetTask(self.TASK_GROUP, nCurTskId);
		if (nCurNum <= 0) then
			return 0;
		end
		
		me.SetTask(self.TASK_GROUP, nCurTskId, nCurNum - 1);
	end
	
	return 1;
end

function tbEvent:Timer_SyncNewRankInfo_GS(tbInfo)
	self.tbNewRankInfo = self.tbNewRankInfo or {};
	table.insert(self.tbNewRankInfo, tbInfo);
end

function tbEvent:Timer_UpdateRank_GS()
	self:UpdateRank(self.tbNewRankInfo);
	self.tbNewRankInfo = {};
end
