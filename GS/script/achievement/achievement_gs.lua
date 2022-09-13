-- 文件名　：achievement_gs.lua
-- 创建者　：furuilei
-- 创建时间：2010-07-05 16:29:12
-- 功能描述：成就系统gameserver逻辑

Achievement.tbc2sFun = {};

-- 完成成就的接口
function Achievement:FinishAchievement(pPlayer, nAchievementId)
	-- 全局服返回
	if (GLOBAL_AGENT) then
		return;
	end
	
	if (self.FLAG_OPEN ~= 1) then
		return;
	end
	
	if (not pPlayer or not nAchievementId or nAchievementId <= 0) then
		return;
	end
	
	Setting:SetGlobalObj(pPlayer);
	if (self:CheckFinished(nAchievementId) == 0) then
		local bIsGeneralAchievement = self:__IsGeneralAchievement(nAchievementId);
		if (not bIsGeneralAchievement or bIsGeneralAchievement == 0) then
			self:__FinishAchievement(nAchievementId);
		else
			self:__FinishGeneralAchievement(nAchievementId);
		end
	end
	Setting:RestoreGlobalObj();
end

-- 指定成就的目标是否是通用的成就达成目标
function Achievement:__IsGeneralAchievement(nAchievementId)
	local nGroupId, nSubGroupId, nIndex = self:GetIndexInfoById(nAchievementId);
	if (not nGroupId or not nSubGroupId or not nIndex) then
		return 0;
	end
	
	local tbInfo = self:GetAchievementInfo(nGroupId, nSubGroupId, nIndex);
	if (not tbInfo) then
		return 0;
	end
	
	-- 这个成就是无效的，返回
	if (tbInfo.bEffective == 0) then
		return 0;
	end
	
	if (tbInfo.nCondType and tbInfo.nCondType ~= 0) then
		return 1;
	end
	
	return 0;
end

function Achievement:__FinishGeneralAchievement(nAchievementId)
	local nCondType, nCondIndex = self:GetAchievementCondInfo(nAchievementId);
	if (not nCondType or not nCondIndex or nCondType <= 0 or nCondIndex <= 0) then
		return;
	end
	
	-- 目前通用的成就达成目标里面只有增加计数这一种需要在这里调用
	if (nCondType == self.INDEX_COND_COUNT) then
		self:OnAddAddCount(nAchievementId);
	end
end

function Achievement:__FinishAchievement(nAchievementId)
	-- 全局服返回
	if (GLOBAL_AGENT) then
		return;
	end
	
	if (self.FLAG_OPEN ~= 1) then
		return;
	end
	
	local nGroupId, nSubGroupId, nIndex = self:GetIndexInfoById(nAchievementId);
	if (not nGroupId or not nSubGroupId or not nIndex) then
		return;
	end
	
	local tbInfo = self:GetAchievementInfo(nGroupId, nSubGroupId, nIndex);
	if (not tbInfo) then
		return;
	end
	
	-- 这个成就是无效的，返回
	if (tbInfo.bEffective == 0) then
		return;
	end
	
	-- 设置标志位，表示已经完成该成就
	self:SetFinished(nAchievementId);
	
	-- 成就完成后，把对应的辅助用任务变量清0
	me.SetTask(self.TASK_GROUP_HELP, nAchievementId, 0);
	
	-- me.Msg(string.format("完成%s号成就", nAchievementId));
	
	-- 增加成就点数
	local nPoint = tbInfo.nPoint or 0;
	self:__AddConsumablePoint(tbInfo.nLevel or 0);
	self:__AddAchievementPoint(nPoint);
	self:__GiveAward(tbInfo);
	self:__SendMsg(tbInfo);
	self:__FinishSubAchievement(tbInfo);
	self:__AddFinishRecord();
	
	me.CallClientScript({"Achievement:FinishAchievement_C", nAchievementId});
	
	-- 成就log
	local szAchivementName = tbInfo.szAchivementName or "";
	local nLevel = tbInfo.nLevel or 0;
	local szLog = string.format("%s,%s,%s,%s", szAchivementName, nAchievementId, nPoint, nLevel);
	Dbg:WriteLogEx(Dbg.LOG_INFO, "Achievement", me.szName, szLog);
end

--=======================================

-- 成就完成之后记录改服务器的成就完成情况
function Achievement:__AddFinishRecord()
	self:__UpdateRecord_Date();
	self:__AddReocrd();
end

function Achievement:__AddReocrd()
	self.nTotalRecord = self.nTotalRecord + 1;
	self.nTodayRecord = self.nTodayRecord + 1;
end

function Achievement:__UpdateRecord_Date()
	local nCurDate = tonumber(os.date("%Y%m%d", GetTime()));
	if (not self.nLastRecordDate) then
		self:__BeginNewRecord();
	elseif (self.nLastRecordDate ~= nCurDate) then
		self:__UpdateRecord_CrossDay();
	end
end

function Achievement:__BeginNewRecord()
	local nCurDate = tonumber(os.date("%Y%m%d", GetTime()));
	self.nLastRecordDate = nCurDate;
	self.nTotalRecord = 0;
	self.nTotalDays = 0;
	self.nTodayRecord = 0;
	self.nAvgRecord = 0;
end

function Achievement:__UpdateRecord_CrossDay()
	local nCurDate = tonumber(os.date("%Y%m%d", GetTime()));
	self.nLastRecordDate = nCurDate;
	self.nTodayRecord = 0;
	self.nTotalDays = self.nTotalDays + 1;
	if (self.nTotalDays <= 0) then
		self.nTotalDays = 1;
	end
	self.nAvgRecord = math.floor(self.nTotalRecord / self.nTotalDays);
end

--=======================================

-- 发聊天栏信息
function Achievement:__SendMsg(tbInfos)
	if (not tbInfos) then
		return;
	end
	
	local nAchievementId = tbInfos.nAchievementId;
	local nLevel = tbInfos.nLevel;
	if (not nAchievementId or not nLevel or nAchievementId <= 0 or nLevel <= 0) then
		return;
	end
	
	local szAchivementMsg = self:__SendMsg_MakdAchievementMsg(nAchievementId);
	if (not szAchivementMsg) then
		return;
	end
	
	if (nLevel >= 4) then
		self:__SendMsg_Sys(szAchivementMsg);
		self:__SendMsg_Team(szAchivementMsg);
		self:__SendMsg_Friend(szAchivementMsg);
		self:__SendMsg_KinTong(szAchivementMsg);
	elseif (nLevel >= 2) then
		self:__SendMsg_Sys(szAchivementMsg);
		self:__SendMsg_Team(szAchivementMsg);
		self:__SendMsg_Friend(szAchivementMsg);
	elseif (nLevel >= 1) then
		self:__SendMsg_Sys(szAchivementMsg);
		self:__SendMsg_Team(szAchivementMsg);
	end
end

function Achievement:__SendMsg_MakdAchievementMsg(nAchievementId)
	if (not nAchievementId or nAchievementId <= 0) then
		return;
	end
	return "<achievement=" .. nAchievementId .. ">";
end

function Achievement:__SendMsg_Sys(szAchivementMsg)
	if (not szAchivementMsg) then
		return;
	end
	local szMsg = string.format("Chúc mừng bạn đã đạt thành tựu: %s", szAchivementMsg);
	me.Msg(szMsg);
end

function Achievement:__SendMsg_Team(szAchivementMsg)
	if (not szAchivementMsg) then
		return;
	end
	local szMsg = string.format("Đồng đội %s đã đạt thành tựu: %s", me.szName, szAchivementMsg);
	KTeam.Msg2Team(me.nTeamId, szMsg);
end

function Achievement:__SendMsg_Friend(szAchivementMsg)
	if (not szAchivementMsg) then
		return;
	end
	local szMsg = string.format("Hảo hữu %s đã đạt thành tựu: %s", me.szName, szAchivementMsg);
	me.SendMsgToFriend(szMsg);
end

function Achievement:__SendMsg_KinTong(szAchivementMsg)
	if (not szAchivementMsg) then
		return;
	end
	local szMsg = string.format("Thành viên %s đã đạt thành tựu: %s", me.szName, szAchivementMsg);
	me.SendMsgToKinOrTong(0, szMsg);
end

--=======================================

function Achievement:__AddConsumablePoint(nLevel)
	local nRate = 1;	-- 可消费成就积分和成就等级的倍率是1
	local nAddPoint = (nLevel or 0) * nRate;
	if (me.GetTask(self.TASK_GROUP_POINT, self.TSK_ID_FLAG_CONSUME) == 0) then
		-- 如果没有领取过可消费成就积分，那么遍历所有已完成成就，把可消费的成就计分都补上
		local nSum = 0;
		local nMaxId = self:GetMaxId();
		for nId = 1, nMaxId do
			if (self:CheckFinished(nId) == 1) then
				local tbInfo = self:GetAchievementInfoById(nId) or {};
				if (tbInfo.nLevel and tbInfo.nLevel > 0) then
					nSum = nSum + tbInfo.nLevel * nRate;
				end
			end
		end
		self:SetConsumablePoint(me, nSum);
		me.SetTask(self.TASK_GROUP_POINT, self.TSK_ID_FLAG_CONSUME, 1);
	else
		local nCurConsumablePoint = self:GetConsumeablePoint(me) or 0;
		self:SetConsumablePoint(me, nCurConsumablePoint + nAddPoint);
	end
end

-- 增加成就点数
function Achievement:__AddAchievementPoint(nPoint)
	if (not nPoint or nPoint <= 0) then
		return;
	end
	
	-- 增加积累成就点数
	local nPoint_Accumulate = Achievement:GetAchievementPoint(me) + nPoint;
	Achievement:SetAchievementPoint(me, nPoint_Accumulate);
	
	-- 增加当前成就点数
	local nCurPoint = Achievement:GetAchievementPoint_Cur(me) + nPoint;
	Achievement:SetAchievementPoint_Cur(me, nCurPoint);
	
	Ladder:SetPlayerHonor(me.nId, 18, nPoint_Accumulate);
end

-- 成就达成之后的奖励
function Achievement:__GiveAward(tbAchievementInfo)
	if (not tbAchievementInfo) then
		return;
	end
	
	local nExp = tbAchievementInfo.nExp or 0;
	local nBindMoney = tbAchievementInfo.nBindMoney or 0;
	local nBindCoin = tbAchievementInfo.nBindCoin or 0;
	local nTitleId = tbAchievementInfo.nTitleId or 0;
	
	if (nExp > 0) then
		me.AddExp(nExp);
	end
	
	if (nBindMoney > 0) then
		me.AddBindMoney(nBindMoney, Player.emKBINDMONEY_ADD_EVENT);
	end
	
	if (nBindCoin > 0) then
		me.AddBindCoin(nBindCoin, Player.emKBINDCOIN_ADD_EVENT);
	end
	
	if (nTitleId > 0) then
		local tbAward_Title = self.tbAwardInfo[self.INDEX_AWARD_TITLE] or {};
		local tbInfo = tbAward_Title[nTitleId];
		local szTitle = tbInfo.szTitle;
		local nTime = tbInfo.nTime;
		if (szTitle and nTime and szTitle ~= "" and nTime > 0) then
			me.AddSpeTitle(szTitle, GetTime() + nTime, "gold");
		end
	end
end

-- 检查完成的成就是否是包含在其他成就中的子成就
-- 如果是的话，检查对应的成就是否完成
function Achievement:__FinishSubAchievement(tbAchievementInfo)
	if (not tbAchievementInfo) then
		return;
	end
	if (not tbAchievementInfo.bIsSub or tbAchievementInfo.bIsSub ~= 1) then
		return;
	end
	
	local tbInfo = self:__FindSuperAchievementInfo(tbAchievementInfo.nAchievementId);
	if (not tbInfo or Lib:CountTB(tbInfo) <= 0) then
		return;
	end
	
	local nSuperId = tbInfo.nAchievementId or 0;
	if (not nSuperId or nSuperId <= 0) then
		return;
	end
	local tbSubId = {};
	for i = 1, 15 do
		local szkey = "nAchievementId" .. i;
		local nId = tbInfo[szkey] or 0;
		if (nId and nId > 0) then
			table.insert(tbSubId, nId);
		end
	end
	
	local bFinished = 1;
	for _, nId in pairs(tbSubId) do
		if (self:CheckFinished(nId) ~= 1) then
			bFinished = 0;
			break;
		end
	end
	if (0 == bFinished) then
		return;
	end
	
	if (self:CheckFinished(nSuperId) == 0) then
		self:__FinishAchievement(nSuperId);
	end
end

-- 找到包含指定子文件的成就信息
function Achievement:__FindSuperAchievementInfo(nAchievementId)
	if (not nAchievementId or nAchievementId <= 0) then
		return;
	end
	
	local tbCondInfo = self.tbCondInfo[self.INDEX_COND_ALL];
	if (not tbCondInfo or #tbCondInfo <= 0) then
		return;
	end
	
	for _, tbInfo in pairs(tbCondInfo) do
		for i = 1, 15 do
			local szkey = "nAchievementId" .. i;
			local nId = tbInfo[szkey] or 0;
			if (nAchievementId == nId) then
				return tbInfo;
			end
		end
	end
end

--=================================================

-- 对比成就
function Achievement:CompAchievement_GS(szDstName)
	if (not szDstName) then
		return;
	end
	
	local pDstPlayer = KPlayer.GetPlayerByName(szDstName);
	if (not pDstPlayer) then
		return;
	end
	
	Setting:SetGlobalObj(pDstPlayer);
	local tbInfo = self:__Cmp_GetInfo();
	Setting:RestoreGlobalObj();
	
	if (not tbInfo or Lib:CountTB(tbInfo) <= 0) then
		return;
	end
	me.CallClientScript({"Achievement:CompAchievement_C", szDstName, tbInfo});
end
Achievement.tbc2sFun["CompAchievement_GS"] = Achievement.CompAchievement_GS;

function Achievement:__Cmp_GetInfo()
	local nMaxId = self:GetMaxId();
	if (not nMaxId or nMaxId <= 0) then
		return;
	end
	
	local tbRet = {};
	for nAchievementId = 1, nMaxId do
		local bFinished = self:CheckFinished(nAchievementId);
		table.insert(tbRet, bFinished);
	end
	return tbRet;
end

--============================================

-- 修复成就
function Achievement:RepairAchievement()
	Relation:RepairAchievement();
	Player:RepairAchievement_Repute();
	Kin:RepairAchievement();
	Faction:RepairAchievement();
	self:RepairAchievement_All();
	self:__AddConsumablePoint();
	Wlls:RepairAchievement();
	Task:RepairPrimerAchievement();	--新手任务成就修复
	Item:RepairEnhanceAchievement();	--强化成就修复
end

-- 完成所有类型子成就类型的成就修复
function Achievement:RepairAchievement_All()
	-- 351, 352 两个成就在秦陵改造的时候去掉了，以后不能完成了
	-- 在这个table当中放入该成就所属成就的一个还有效地子id就可以修复该成就
	-- 如果有其他的不能完成的成就，并且是子成就的，可以将成就id放到这个table当中
	local tbAchievement_NeedRepair = {353};
	
	for _, nAchievementId in pairs(tbAchievement_NeedRepair) do
		local tbAchievementInfo = self:GetAchievementInfoById(nAchievementId);
		if (tbAchievementInfo) then
			self:__FinishSubAchievement(tbAchievementInfo);
		end
	end
end

-- 玩家上线的时候调用下，刷过门派成就的扣下来
-- 9.28 - 10.12 4场门派竞技，最多4次，多的次数扣掉
-- 因为在此之前还没有侠义值的概念，不对侠义值进行修复
function Achievement:RepairAchievement_Faction()
	local nLastOutTime = me.GetLastLogoutTime();
	if (not nLastOutTime) then
		return;
	end
	local nLastOutDate = tonumber(os.date("%Y%m%d%H", nLastOutTime));
	if (nLastOutDate >= 2010101208) then
		return;
	end
	-- 67 成就是这组成就当中需要计数最少的，只需要判断这一个成就就可以知道是否刷了门派成就
	if (self:CheckFinished(67) ~= 1 and self:GetFinishNum(me, 67) <= 4) then
		return;
	end
	
	local tbFactionInfo = {
		{nAchievementId = 67, nPoint = 4},
		{nAchievementId = 68, nPoint = 3},
		{nAchievementId = 69, nPoint = 2},
		{nAchievementId = 70, nPoint = 1},
		};
	local nTotalPoint = 0;
	for _, tbInfo in pairs(tbFactionInfo) do
		self:SetFinishNum(me, tbInfo.nAchievementId, 4);
		if (self:CheckFinished(tbInfo.nAchievementId) == 1) then
			me.SetTaskBit(self.TASK_GROUP_ACV, tbInfo.nAchievementId, 0);
			nTotalPoint = nTotalPoint + tbInfo.nPoint;
		end
	end
	local nPoint = self:GetAchievementPoint_Cur(me) - nTotalPoint;
	self:SetAchievementPoint_Cur(me, nPoint);
	nPoint = self:GetAchievementPoint(me) - nTotalPoint;
	self:SetAchievementPoint(me, nPoint);
	
	Ladder:SetPlayerHonor(me.nId, 18, nPoint);
end

function Achievement:RepairAchievement_Kin()
	local nLastOutTime = me.GetLastLogoutTime();
	if (not nLastOutTime) then
		return;
	end
	local nLastOutDate = tonumber(os.date("%Y%m%d%H", nLastOutTime));
	if (nLastOutDate >= 2012091608) then
		return;
	end
	if (self:CheckFinished(28) ~= 1) then
		return;
	end
	
	local tbInfo = 
	{
		{nAchievementId = 28, nPoint = 4},
		{nAchievementId = 29, nPoint = 3},
		{nAchievementId = 30, nPoint = 3},
		{nAchievementId = 31, nPoint = 3},
	};
	local nTotalPoint = 0;
	for _, tbInfo in pairs(tbInfo) do
		if (self:CheckFinished(tbInfo.nAchievementId) == 1) then
			me.SetTaskBit(self.TASK_GROUP_ACV, tbInfo.nAchievementId, 0);
			nTotalPoint = nTotalPoint + tbInfo.nPoint;
		end
	end
	local nPoint = self:GetAchievementPoint_Cur(me) - nTotalPoint;
	self:SetAchievementPoint_Cur(me, nPoint);
	nPoint = self:GetAchievementPoint(me) - nTotalPoint;
	self:SetAchievementPoint(me, nPoint);
	
	Ladder:SetPlayerHonor(me.nId, 18, nPoint);
end

function Achievement:RepairAchievement_Wlls1()
	local nLastOutTime = me.GetLastLogoutTime();
	if (not nLastOutTime) then
		return;
	end
	if (self:CheckFinished(273) ~= 1) then
		return;
	end
	
	local tbInfo = 
	{
		{nAchievementId = 273, nPoint = 4},
		{nAchievementId = 281, nPoint = 3},
		{nAchievementId = 282, nPoint = 4},
		{nAchievementId = 283, nPoint = 3},
		{nAchievementId = 284, nPoint = 1},
		{nAchievementId = 285, nPoint = 3},
		{nAchievementId = 286, nPoint = 2},
		{nAchievementId = 287, nPoint = 1},
	};
	local nTotalPoint = 0;
	for _, tbInfo in pairs(tbInfo) do
		if (self:CheckFinished(tbInfo.nAchievementId) == 1) then
			me.SetTaskBit(self.TASK_GROUP_ACV, tbInfo.nAchievementId, 0);
			nTotalPoint = nTotalPoint + tbInfo.nPoint;
		end
	end
	local nPoint = self:GetAchievementPoint_Cur(me) - nTotalPoint;
	self:SetAchievementPoint_Cur(me, nPoint);
	nPoint = self:GetAchievementPoint(me) - nTotalPoint;
	self:SetAchievementPoint(me, nPoint);
	
	Ladder:SetPlayerHonor(me.nId, 18, nPoint);
end

function Achievement:_OnLogin(bExchangeServerComing)
	if (bExchangeServerComing == 1) then
		return;
	end
	self:RepairAchievement_Faction();
	self:RepairAchievement_Kin();
	self:RepairAchievement_Wlls1();
end
PlayerEvent:RegisterGlobal("OnLogin", Achievement._OnLogin, Achievement);
