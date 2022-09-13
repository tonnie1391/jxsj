-- 文件名　：camp.lua
-- 创建者　：FanZai
-- 创建时间：2007-10-14 18:55:38
-- 文件说明：针对Mission中一方阵营（宋或金）的操作

local tbCampBase	= Battle.tbCampBase or {};	-- 支持重载

-- 构造初始化
function tbCampBase:init(nCampId, tbMapCampInfo, tbMission)
	--Battle:DbgOut("tbCampBase:init", nCampId, tbMapCampInfo, tbMission);
	self.nCampId	= nCampId;
	self.tbMapInfo	= tbMapCampInfo;
	self.tbAddNpcs	= tbAddNpcs;
	self.tbMission	= tbMission;
	
	self.nRuleType		= tbMission.nRuleType;
	self.nBattleLevel	= tbMission.nBattleLevel;

	self.szCampName		= Battle.NAME_CAMP[nCampId];
	self.nNpcCamp		= Battle.NPCCAMP_MAP[nCampId];
	self.nDbTskId_PlCnt	= Battle.DBTASKID_PLAYER_COUNT[tbMission.nBattleLevel][tbMission.nBattleSeq][nCampId];

	self.nBouns				= 0;
	self.nFlags				= 0;
	self.nPlayerIsFlag		= 0;
	self.nFlagPlayerId		= 0;
	self.nFlagLimit			= 0;
	self.bIsProtectFlag		= 0;

	self.tbBTSaveData	= {};
	
	self:SetPlayerCount(0);

	self:AddDialogNpc("Npc_chuwuxiang", Battle.NPCID_WUPINBAOGUANYUAN);
	self:AddDialogNpc("Npc_junyiguan", Battle.tbNPCID_CAMPHOUYINGJUNYIGUAN[nCampId]);
end

-- 比赛开始
function tbCampBase:OnStart()
	local tbPlayerList	= self.tbMission:GetPlayerList(self.nCampId);
	for _, pPlayer in pairs(tbPlayerList) do
		pPlayer.SetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_KEY, self.tbMission.nBattleKey);
		pPlayer.SetTask(Battle.TSKGID, Battle.TASKID_BTCAMP, self.nCampId);
		
		-- 记录玩家参加宋金战场的次数
		Stats.Activity:AddCount(pPlayer, Stats.TASK_COUNT_BATTLE, 1);
		local nTimes = pPlayer.GetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_JOIN_BATTLE);
		pPlayer.SetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_JOIN_BATTLE, nTimes + 1);
	end
end

-- 比赛结束，处理本方阵营奖励等
--	注：比赛异常结束（人数不够终止比赛等），此函数并不会被调用
function tbCampBase:OnEnd(nResult, szWinMsg)	
	-- 发送胜败消息
	local tbPlayerList	= self.tbMission:GetPlayerList(self.nCampId);
	local szMsg	= string.format(Battle.MSG_CAMP_RESULT[nResult],
								self.tbMission:GetFullName(), self.szCampName);
	for _, pPlayer in pairs(tbPlayerList) do
		Dialog:SendInfoBoardMsg(pPlayer, szWinMsg);
		Dialog:SendInfoBoardMsg(pPlayer, szMsg);
		local tbBattleInfo = Battle:GetPlayerData(pPlayer);
		pPlayer.Msg(string.format("Bảng tổng kết xếp hạng: <color=green>%d<color>, điểm thu được: <color=yellow>%d<color>", tbBattleInfo.nListRank, tbBattleInfo.nBouns));
	end
end

-- 本方有玩家加入
function tbCampBase:OnJoin(pPlayer)
	self:SetPlayerCount(self.nPlayerCount + 1);
	
	local tbBattleInfo	= self:FindBTData(pPlayer);
	if (not tbBattleInfo) then
		tbBattleInfo	= Lib:NewClass(Battle.tbPlayerBase, pPlayer, self);
		if (2 == self.tbMission.nState) then
			--记录参加次数
			local nNum = pPlayer.GetTask(StatLog.StatTaskGroupId , 6) + 1;
			pPlayer.SetTask(StatLog.StatTaskGroupId, 6, nNum);
		end
	else
		tbBattleInfo.pPlayer = pPlayer;	
	end

	tbBattleInfo.nBackTime	= GetTime();
	
	tbBattleInfo.szFacName	= Player:GetFactionRouteName(pPlayer.nFaction, pPlayer.nRouteId);

	pPlayer.GetTempTable("Mission").tbPLBTInfo = tbBattleInfo;

	tbBattleInfo.pPlayer.AddTitle(2, self.nCampId, tbBattleInfo.nRank, 0);	
	
	if (2 == self.tbMission.nState) then
		local nRemainFrame		= self.tbMission:GetStateLastTime(self.tbMission.nState);
		tbBattleInfo:SetRightBattleInfo(nRemainFrame);
	else
		tbBattleInfo:DeleteRightBattleInfo();
	end
end

function tbCampBase:BeforeLeave(pPlayer)
	Battle:DbgOut("Camp:BeforeLeave", pPlayer.szName, self.nCampId);
end

-- 本方有玩家离开
function tbCampBase:OnLeave(pPlayer)
	self:SetPlayerCount(self.nPlayerCount - 1);

	Battle:DbgOut("Camp:OnLeave", pPlayer.szName, self.nCampId);
	self:SaveBTData(pPlayer);
	pPlayer.RemoveSkillState(Battle.SKILL_DAMAGEDEFENCE_ID);
	local tbBattleInfo = Battle:GetPlayerData(pPlayer);
	if (tbBattleInfo) then
		tbBattleInfo:DeleteRightBattleInfo();
		tbBattleInfo.pPlayer.RemoveTitle(2, self.nCampId, tbBattleInfo.nRank, 0);
	end
end

-- 本方有玩家被对方玩家杀
--	注：被Npc杀死的不会调到这里
function tbCampBase:OnPlayerDeath(tbDeathBattleInfo)
	tbDeathBattleInfo.nSeriesKill		= 0;
	tbDeathBattleInfo.nSeriesKillNum	= 0;
	tbDeathBattleInfo.nBackTime			= GetTime();	-- 从1970年1月1日0时算起的秒数
	DeRobot:OnMissionDeath(tbDeathBattleInfo);
end

-- 本方有玩家杀死对方玩家
function tbCampBase:OnKillPlayer(tbKillerBattleInfo, tbDeathBattleInfo)
	Battle:GiveKillerBouns(tbKillerBattleInfo, tbDeathBattleInfo);
	Battle:ProcessSeriesBouns(tbKillerBattleInfo, tbDeathBattleInfo);
end

-- 本方有玩家杀死Npc
function tbCampBase:OnKillNpc(tbKillerBattleInfo, pNpc)
	Battle:DbgOut("Camp:OnKillNpc", tbKillerBattleInfo.pPlayer.szName, pNpc.szName, self.nCampId);
	tbKillerBattleInfo:GiveKillNpcBouns(pNpc);
end

function tbCampBase:OnProtectFlag(tbFlagPlayer)
	tbFlagPlayer:GiveProtectFlagBouns();
	local szFirMsg = string.format("%s-%s <color=green>%s<color> hộ kỳ thành công", Battle.NAME_CAMP[tbFlagPlayer.tbCamp.nCampId], Battle.NAME_RANK[tbFlagPlayer.nRank], tbFlagPlayer.pPlayer.szName);
	local szSecMsg = string.format("Số lần phe %s hộ kỳ thành công: <color=red>%d<color>", Battle.NAME_CAMP[tbFlagPlayer.tbCamp.nCampId], tbFlagPlayer.tbCamp.nFlags);
	return szFirMsg, szSecMsg;
end

-- 设置阵营人数
function tbCampBase:SetPlayerCount(nPlayerCount)
	self.nPlayerCount	= nPlayerCount;
	KGblTask.SCSetTmpTaskInt(self.nDbTskId_PlCnt, nPlayerCount + 1);	-- 按照人数+1保存
end

-- 获得阵营人数
function tbCampBase:GetPlayerCount()
	return self.nPlayerCount;
end

-- 传送
function tbCampBase:TransTo(pPlayer, szPosName)
	local tbPos	= self:GetMapPos(szPosName);
	pPlayer.NewWorld(unpack(tbPos));
end

-- 获得随机点
function tbCampBase:GetMapPos(szPosName)
	local tbPoss	= self.tbMapInfo[szPosName];
	local nRand		= MathRandom(#tbPoss);
	return tbPoss[nRand];
end

-- 增加对话NPC
function tbCampBase:AddDialogNpc(szPosName, nNpcId)
	for _, tbPos in pairs(self.tbMapInfo[szPosName]) do
		-- TODO:	最好不用Index
		KNpc.Add2(nNpcId, 1, 0, tbPos[1], tbPos[2], tbPos[3]);
	end
end

-- 保存玩家战场信息
function tbCampBase:SaveBTData(pPlayer)
	local tbPLInfo								= {};
	tbPLInfo.nPLId								= pPlayer.nId;
	tbPLInfo.tbPLBTInfo							= Battle:GetPlayerData(pPlayer);
	if (not tbPLInfo.tbPLBTInfo) then
		return;
	end
	self.tbBTSaveData[#self.tbBTSaveData + 1]	= tbPLInfo;
	tbPLInfo.pPlayer							= nil;
end

-- 搜索玩家战场信息
function tbCampBase:FindBTData(pPlayer)
	local tbPLBTInfo	= nil;
	local nId			= pPlayer.nId;
	local nDelId		= 0;
	for nKey, tbPLInfo in pairs(self.tbBTSaveData) do
		if (tbPLInfo.nPLId == nId) then
			nDelId		= nKey;
			tbPLBTInfo 	= tbPLInfo.tbPLBTInfo; 
			break;
		end
	end
	if (0 ~= nDelId) then
		table.remove(self.tbBTSaveData, nDelId);
	end	
	return tbPLBTInfo;
end

-- 为本方所有玩家加积分
function tbCampBase:AddCampBouns(nAddBouns)
	local tbPlayerInfoList	= self.tbMission:GetPlayerInfoList(self.nCampId);
	-- 阵营奖励积分
	for _, tbBattleInfo in pairs(tbPlayerInfoList) do
		tbBattleInfo:AddBounsWithoutCamp(nAddBouns);
	end
end

function tbCampBase:PushNpcHighPoint(pNpc, nPicId, nHurtPicId)
	local tbMiniMapInfo		= {};
	tbMiniMapInfo.nPicId	= nPicId;
	tbMiniMapInfo.nHurtPicId= nHurtPicId;
	self.tbMission.tbNpcHighPoint[pNpc.dwId] = tbMiniMapInfo;
end

function tbCampBase:PopNpcHighPoint(pNpc)
	self.tbMission.tbNpcHighPoint[pNpc.dwId] = nil;
end

function tbCampBase:_PRINT(tbTemp)
	for Key, Value in pairs(tbTemp) do
		Battle:DbgOut("Key, Value = ", Key, Value);
	end
end

Battle.tbCampBase	= tbCampBase;
