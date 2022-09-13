-------------------------------------------------------
-- 文件名　：kinbattle_mission.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-7 13:10:27
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return 0;
end

Require("\\script\\mission\\kinbattle\\kinbattle_def.lua");

local tbMission = KinBattle.Mission or Mission:New();
KinBattle.Mission = tbMission;

function tbMission:OnOpen()
	self:GoNextState();
end

function tbMission:OnClose()
	for nPlayerId, nState in pairs(self.tbLookerList) do
		if nState == 1 then
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				self:LeaveLooker(pPlayer);
				Looker:Leave(pPlayer);
			end
		end
	end
end

function tbMission:OnDeath(pKillerNpc)
	--不是比赛时间内不能加分
	if (2 ~= self.nStateJour) then
		return 0;
	end
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	local tbKillerPlayerInfo = KinBattle:GetPlayerInfo(pKillerPlayer);
	local tbDeathPlayerInfo = KinBattle:GetPlayerInfo(me);
	-- 战场同家族仇杀不记杀人数和死亡数,但清空当前连斩
	if tbKillerPlayerInfo.tbCamp.nCampId == tbDeathPlayerInfo.tbCamp.nCampId then
		tbDeathPlayerInfo.nSeries = 0;
		return 0;
	end
	tbDeathPlayerInfo:HandleBeKiller();
	local nHonorLevel = me.GetHonorLevel();
	tbKillerPlayerInfo:HandleKiller(nHonorLevel);
end


function tbMission:OnJoin(nGroupId)
	local tbCamp = self.tbCamps[nGroupId];
	tbCamp:OnJoin(me);
	me.TeamApplyLeave(); --离开队伍
	if self.nStateJour == 1 then
		me.Msg("请在此准备，战斗即将开始。");
		Dialog:SendBlackBoardMsg(me, "请在此准备，战斗即将开始。");
	elseif self.nStateJour == 2 then
		me.Msg("战斗已打响，请从<color=yellow>车夫<color>处进入战斗地图！");
		Dialog:SendBlackBoardMsg(me, "战斗已打响，请从车夫处进入战斗地图！");
	end
end

function tbMission:OnLeave(nGroupId, szReason)
	self.tbCamps[nGroupId]:OnLeave(me);
	me.TeamApplyLeave();
	me.SetFightState(0);
	me.SetLogoutRV(0);
end

function tbMission:StartGame(nKinId, nKinIdMate, szKinName, szKinNameMate, nMissionId, nTimeIndex, nMapType, nLookMode)
	self.nMissionId = nMissionId;
	self.szKinName = szKinName;
	self.szKinNameMate = szKinNameMate;
	self.nKinId = nKinId;
	self.nKinIdMate = nKinIdMate;
	self.nTimeIndex = nTimeIndex;
	self.nMapType = nMapType;
	self.nLookMode = nLookMode or 2;
	self.nOverFlag = 0;
	self.tbFirstPromt = {};-- 记录各种一次性提示是否已经提示过了
	self.tbLookerList = {};-- 观战名单
	self.nLookerCount = 0;
	-- 双方阵营
	local tbCampKin = Lib:NewClass(KinBattle.tbCamp, KinBattle.MAP_TEMP_CAMP[1], nKinId, szKinName, KinBattle.MAP_TEMP_CAMP[2], nKinIdMate, szKinNameMate, self);
	local tbCampKinMate = Lib:NewClass(KinBattle.tbCamp,KinBattle.MAP_TEMP_CAMP[2], nKinIdMate, szKinNameMate, KinBattle.MAP_TEMP_CAMP[1], nKinId, szKinName, self);
	self.tbCamps = 
	{
		[KinBattle.MAP_TEMP_CAMP[1]] = tbCampKin,
		[KinBattle.MAP_TEMP_CAMP[2]] = tbCampKinMate,
	};
	self.tbRevivalPos = {};
	self.tbRevivalPos[1] = {};
	table.insert(self.tbRevivalPos[1], {KinBattle.MAP_LIST[nMissionId][2], KinBattle.MAP_REVIVAL_POS[1], KinBattle.MAP_REVIVAL_POS[2]});
	self.tbRevivalPos[2] = {};
	table.insert(self.tbRevivalPos[2], {KinBattle.MAP_LIST[nMissionId][3], KinBattle.MAP_REVIVAL_POS[1], KinBattle.MAP_REVIVAL_POS[2]});
	local nCityId = KinBattle.MAP_LIST[nMissionId][4];  
	self.tbMisCfg = 
	{
		tbLeavePos			= {[0] = {nCityId, unpack(KinBattle.LEAVE_POS[nCityId])}},		-- 离开坐标
		tbDeathRevPos		= self.tbRevivalPos,			-- 死亡重生点
		tbCamp				= KinBattle.MAP_TEMP_CAMP,		-- 双方阵营
		nPkState			= Player.emKPK_STATE_CAMP,		-- 战斗状态
		nForbidTeam			= 0,							-- 禁止组队换色
		nInBattleState		= 1,							-- 禁止不同阵营组队
		nDeathPunish		= 1,							-- 无死亡惩罚
		nOnDeath			= 1,							-- 玩家死亡回调
		nForbidStall		= 1,							-- 禁止摆摊
		nDisableOffer		= 1,							-- 禁止收购
		nDisableFriendPlane = 1,							-- 禁止好友界面
		nDisableStallPlane	= 1,							-- 禁止交易界面		
	};
	self.tbMisEventList = 
	{
		{1, KinBattle.TIMER_SIGNUP, "OnTimerPlay"},
		{2, KinBattle.TIMER_GAME[nTimeIndex] or KinBattle.TIMER_GAME[1], "OnTimerEnd"},	
	};
	self:Open();
end

function tbMission:_OnLogout()
	if (me.IsDead() == 1) then
		me.ReviveImmediately(0);
	end
	self:KickPlayer(me, "Logout");
end

-- 开始战斗
function tbMission:OnTimerPlay()
	if 0 == self:CheckOpenBattle() then 
		self:BroadcastMsg(0, "家族战报名时间到，但目前双方集结人数不足20人或一方没有人，请择日再战");
		KKin.Msg2Kin(self.nKinId, "因双方人数不足20人或一方没有人，家族战没有开启!", 0);
		KKin.Msg2Kin(self.nKinIdMate, "因双方人数不足20人或一方没有人，家族战没有开启!", 0);
		self:Close();
		KinBattle:FreeBattle_GS(self.nMissionId);
		Dbg:WriteLog("家族战", "因人数不足没有开启", string.format("家族1：%s,家族2：%s", self.szKinName, self.szKinNameMate));
		return 0;
	end
	local tbAllPlayer = self:GetPlayerList();
	for _, pPlayer in pairs(tbAllPlayer) do 
		local tbPlayerInfo = KinBattle:GetPlayerInfo(pPlayer);
		if tbPlayerInfo then
			tbPlayerInfo:SetRightBattleInfo(KinBattle.TIMER_GAME[self.nTimeIndex], self.nStateJour + 1);
		end
		pPlayer.Msg("战斗已打响，请从<color=yellow>车夫<color>处进入战斗地图！");
		Dialog:SendBlackBoardMsg(pPlayer, "战斗已打响，请从车夫处进入战斗地图！");
	end
	self:IncreaseKinBattleTime();
	self:CreateTimer(KinBattle.TIMER_SYNCDATA, self.OnTimerSyncData, self);
	self.nGameSyncCount	= math.floor(KinBattle.TIMER_GAME[self.nTimeIndex] / KinBattle.TIMER_SYNCDATA);
	KKin.Msg2Kin(self.nKinId, string.format("本家族与[%s]家族的家族战已经开始，请本家族成员火速去各大城市公平子处报名参战，捍卫家族荣誉！战斗期间可随时进入场地PK。", self.szKinNameMate), 0);
	KKin.Msg2Kin(self.nKinIdMate, string.format("本家族与[%s]家族的家族战已经开始，请本家族成员火速去各大城市公平子处报名参战，捍卫家族荣誉！战斗期间可随时进入场地PK。", self.szKinName), 0);
	Dbg:WriteLog("家族战", "成功开启", string.format("家族1：%s,家族2：%s", self.szKinName, self.szKinNameMate));
	if self.nLookMode == 1 then
		local szMsg = string.format("[%s]家族与[%s]家族开始了武艺切磋！诚邀各位侠士前往公平子处观战！", self.szKinName, self.szKinNameMate);
		local szMsgSub = string.format("<color=blue>[%s]<color>家族与<color=blue>[%s]<color>家族开始了武艺切磋！诚邀各位侠士前往公平子处观战！", self.szKinName, self.szKinNameMate);
		GlobalExcute{"Dialog:GlobalNewsMsg_GS", szMsg};
		GlobalExcute{"Dialog:GlobalMsg2SubWorld_GS", szMsgSub};
	else
		local szMsg = string.format("[%s]家族与[%s]家族开始了武艺切磋！此次禁止观战！", self.szKinName, self.szKinNameMate);
		local szMsgSub = string.format("<color=blue>[%s]<color>家族与<color=blue>[%s]<color>家族开始了武艺切磋！此次禁止观战！", self.szKinName, self.szKinNameMate);
		GlobalExcute{"Dialog:GlobalNewsMsg_GS", szMsg};
		GlobalExcute{"Dialog:GlobalMsg2SubWorld_GS", szMsgSub};
	end
	GCExcute{"KinBattle:SetMissionState", self.nMissionId, 2};
	GlobalExcute{"KinBattle:SetMissionState", self.nMissionId, 2};
	return 1;
end

function tbMission:OnTimerSyncData()
	self.nGameSyncCount = self.nGameSyncCount - 1;
	if self.nGameSyncCount <= 0 then
		return 0;
	end
	local nRemainTime = self.nGameSyncCount * KinBattle.TIMER_SYNCDATA / Env.GAME_FPS;
	if 2 ~= self.nStateJour then
		nRemainTime = 0;
	end
	self:UpdateBattleInfo(nRemainTime);
end

--同步战场信息
function tbMission:UpdateBattleInfo(nRemainTime)
	local tbPlayerInfoList = self:GetSortPlayerInfoList();
	local tbSyncPlayerInfoList = self:GetSyncPlayerInfoList(tbPlayerInfoList);
	local tbFisrtPlayerInfo = nil;
	for i = 1, #tbPlayerInfoList do
		local tbPlayerInfo = tbPlayerInfoList[i];
		local nOldRank = tbPlayerInfo.nRank;
		tbPlayerInfo.nRank = i;
		if nOldRank ~= i and 2 == self.nStateJour then
			tbPlayerInfo:ShowRightBattleInfo();
		end
		local tbSyncPlayerInfo = self:GetSyncPlayerInfo(tbPlayerInfo);
		if i == 1 then
			tbFisrtPlayerInfo = tbSyncPlayerInfo;
		end
		local tbAllData = {};
		tbAllData.tbInfo = tbSyncPlayerInfo;
		tbAllData.tbPlayerInfoList = tbSyncPlayerInfoList;
		local nUserFullTime = 12;
		if nRemainTime == 0 then
			nUserFullTime = 60;
		end
		Dialog:SyncCampaignDate(tbPlayerInfo.pPlayer, "KinBattle", tbAllData, nUserFullTime * Env.GAME_FPS);
	end
	if #tbPlayerInfoList  == 0 then
		return;
	end
	-- 给观看者同步战场战报,默认同步第一名的个人数据
	for nPlayerId, nState in pairs(self.tbLookerList) do
		if nState == 1 then
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				local tbAllData = {};
				tbAllData.tbInfo = tbFisrtPlayerInfo;
				tbAllData.tbPlayerInfoList = tbSyncPlayerInfoList;
				local nUserFullTime = 12;
				if nRemainTime == 0 then
					nUserFullTime = 60;
				end
				Dialog:SyncCampaignDate(pPlayer, "KinBattle", tbAllData, nUserFullTime * Env.GAME_FPS);
			end
		end
	end
end

--获取需要同步的个人数据
function tbMission:GetSyncPlayerInfo(tbPlayerInfo)
	local tbSyncPlayerInfo = {};
	tbSyncPlayerInfo.tbPlayerInfo = {};
	tbSyncPlayerInfo.tbPlayerInfo.szName = tbPlayerInfo.szName;
	tbSyncPlayerInfo.tbPlayerInfo.nRank = tbPlayerInfo.nRank;
	tbSyncPlayerInfo.tbPlayerInfo.nKillCount = tbPlayerInfo.nKillCount;
	tbSyncPlayerInfo.tbPlayerInfo.nBeKillCount = tbPlayerInfo.nBeKillCount;
	tbSyncPlayerInfo.tbPlayerInfo.nMaxSeries = tbPlayerInfo.nMaxSeries;
	tbSyncPlayerInfo.tbPlayerInfo.nSeries = tbPlayerInfo.nSeries;
	tbSyncPlayerInfo.tbPlayerInfo.nJiuZhuanCount = tbPlayerInfo.nJiuZhuanCount;
	tbSyncPlayerInfo.tbPlayerInfo.tbBeKillerHonor ={};
	for i = 1, #tbPlayerInfo.tbBeKillerHonor do
		tbSyncPlayerInfo.tbPlayerInfo.tbBeKillerHonor[i] = tbPlayerInfo.tbBeKillerHonor[i];
	end
	local nStateTime = self:GetStateLastTime();
	tbSyncPlayerInfo.tbPlayerInfo.nRemainTime = nStateTime;
	local nCampId = tbPlayerInfo.tbCamp.nCampId;
	local nCampIdMate = tbPlayerInfo.tbCamp.nCampIdMate;
	tbSyncPlayerInfo.tbKinInfo = {};
	tbSyncPlayerInfo.tbKinInfo.szName = self.tbCamps[nCampId].szKinName;
	tbSyncPlayerInfo.tbKinInfo.nPlayerCount = self.tbCamps[nCampId].nPlayerCount;
	tbSyncPlayerInfo.tbKinInfo.nKillCount = self.tbCamps[nCampId].nKillCount;
	tbSyncPlayerInfo.tbKinInfo.nBeKillCount = self.tbCamps[nCampId].nBeKillCount;
	tbSyncPlayerInfo.tbKinInfo.nJiuZhuanCount = self.tbCamps[nCampId].nJiuZhuanCount;
	tbSyncPlayerInfo.tbKinInfoMate = {};
	tbSyncPlayerInfo.tbKinInfoMate.szName = self.tbCamps[nCampIdMate].szKinName;
	tbSyncPlayerInfo.tbKinInfoMate.nPlayerCount = self.tbCamps[nCampIdMate].nPlayerCount;
	tbSyncPlayerInfo.tbKinInfoMate.nKillCount = self.tbCamps[nCampIdMate].nKillCount;
	tbSyncPlayerInfo.tbKinInfoMate.nBeKillCount = self.tbCamps[nCampIdMate].nBeKillCount;
	tbSyncPlayerInfo.tbKinInfoMate.nJiuZhuanCount = self.tbCamps[nCampIdMate].nJiuZhuanCount;
	return tbSyncPlayerInfo;
end

--获取需要同步的排行榜
function tbMission:GetSyncPlayerInfoList(tbPlayerInfoList)
	local tbSyncPlayerInfoList = {};
	local nBattleListNum = #tbPlayerInfoList;
	if nBattleListNum > KinBattle.MAX_SYNC_COUNT then
		nBattleListNum = KinBattle.MAX_SYNC_COUNT;
	end
	for i = 1, nBattleListNum do
		local tbSyncPlayerInfo = {};
		tbSyncPlayerInfo.szName = tbPlayerInfoList[i].szName;
		tbSyncPlayerInfo.szKinName = tbPlayerInfoList[i].tbCamp.szKinName;
		tbSyncPlayerInfo.szFacName = tbPlayerInfoList[i].szFacName;
		tbSyncPlayerInfo.nKillCount = tbPlayerInfoList[i].nKillCount;
		tbSyncPlayerInfo.nSeries = tbPlayerInfoList[i].nSeries;
		tbSyncPlayerInfo.nMaxSeries = tbPlayerInfoList[i].nMaxSeries;
		tbSyncPlayerInfo.nJiuZhuanCount = tbPlayerInfoList[i].nJiuZhuanCount;
		tbSyncPlayerInfoList[#tbSyncPlayerInfoList + 1] = tbSyncPlayerInfo;
	end
	return tbSyncPlayerInfoList
end

--获取排过序的玩家
function tbMission:GetSortPlayerInfoList()
	local tbPlayerInfoList = self:GetPlayerInfoList();
	table.sort(tbPlayerInfoList, self._PlayerCmp);
	return tbPlayerInfoList;
end

function tbMission:GetPlayerInfoList(nCampId)
	local tbPlayerList, nCount = self:GetPlayerList(nCampId);
	local tbPlayerInfoList = {};
	for i, pPlayer in pairs(tbPlayerList) do
		tbPlayerInfoList[i] = KinBattle:GetPlayerInfo(pPlayer);
	end
	return tbPlayerInfoList, nCount;
end

tbMission._PlayerCmp = function (tbPlayerA, tbPlayerB)
	if tbPlayerA.nKillCount == tbPlayerB.nKillCount then
		return tbPlayerA.nLastKillTime < tbPlayerB.nLastKillTime;
	end
	return tbPlayerA.nKillCount > tbPlayerB.nKillCount;
end

-- 结束战斗
function tbMission:OnTimerEnd()
	self.nOverFlag = 1;
	self:UpdateBattleInfo(0);
	KKin.Msg2Kin(self.nKinId, "此次家族战时间已到，场地关闭。可在城市的公平子处查看个人战绩", 0);
	KKin.Msg2Kin(self.nKinIdMate, "此次家族战时间已到，场地关闭。可在城市的公平子处查看个人战绩", 0);
	local tbAllPlayer = self:GetPlayerList();
	for _, pPlayer in pairs(tbAllPlayer) do 
		Dialog:SendBlackBoardMsg(pPlayer, "此次家族战时间已到，场地关闭。可在城市的公平子处查看个人战绩");
	end
	if self.nLookMode == 1 then
		for nPlayerId, nState in pairs(self.tbLookerList) do
			if nState == 1 then
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if pPlayer then
					pPlayer.Msg("此次家族战时间已到，场地关闭。可在城市的公平子处查看战绩");
				end
			end
		end
	end
	self:Close();
	KinBattle:FreeBattle_GS(self.nMissionId);
	return 0;
end

function tbMission:GetGameState()
	return self.nStateJour;
end

--是否达到了开战条件
function tbMission:CheckOpenBattle()
	local _, nCount1 = self:GetPlayerList(KinBattle.MAP_TEMP_CAMP[1]);
	local _, nCount2 = self:GetPlayerList(KinBattle.MAP_TEMP_CAMP[2]);
	if nCount1 + nCount2 < KinBattle.MIN_PLAYER_COUNT or nCount1 < 1 or nCount2 < 1 then
		return 0;
	end
	return 1;
end

-- 增加家族战次数
function tbMission:IncreaseKinBattleTime()
	GCExcute{"KinBattle:IncreaseBattleTime_GC", self.nKinId, self.nKinIdMate};
end

function tbMission:CheckOver()
	if not self.nOverFlag or self.nOverFlag ~= 1 then
		return 0;
	end
	return 1;
end

-- 加入观看者
function tbMission:JoinLooker(pPlayer)
	self.tbLookerList[pPlayer.nId] = 1;
	self.nLookerCount = self.nLookerCount + 1;
end

-- 踢出观战者
function tbMission:LeaveLooker(pPlayer)
	if self.tbLookerList[pPlayer.nId] and self.tbLookerList[pPlayer.nId] == 1 then
		self.tbLookerList[pPlayer.nId] = 0;
		self.nLookerCount = self.nLookerCount - 1;
	end
end

-- 给观战成员发公告
function tbMission:Msg2Looker(szMsg)
	for nPlayerId, nState in pairs(self.tbLookerList) do
		if nState == 1 then
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				pPlayer.Msg(szMsg);
			end
		end
	end
end