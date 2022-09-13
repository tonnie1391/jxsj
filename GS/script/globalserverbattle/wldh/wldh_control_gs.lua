--武林大会
--孙多良
--2008.09.11
if (MODULE_GC_SERVER) then
	return 0;
end

--比赛结束
function Wldh:OnGameOverGS(nType)
	if self.tbReadyTimer[nType] and self.tbReadyTimer[nType] > 0 then
		if Timer:GetRestTime(self.tbReadyTimer[nType]) > 0 then
			Timer:Close(self.tbReadyTimer[nType]);
			self.tbReadyTimer[nType] = 0;
		end		
	end
	Wldh:CloseMission(nType);
end

--关闭准备场时间计时
function Wldh:CloseGameTimer(nType)
	self.tbReadyTimer[nType] = 0;
	return 0;
end

--初始化数据
function Wldh:InitGameDateGS(nType, nIsFinal)
	self:OnGameOverGS(nType);
	for nReadyId, nMapId in pairs(self:GetMapReadyTable(nType)) do
		if not self.GroupList[nType] or not self.GroupList[nType][nReadyId] then
			self.GroupList[nType] = self.GroupList[nType] or {};
			self.GroupList[nType][nReadyId] = {};
		end
		for _, tbLeague in pairs(self.GroupList[nType][nReadyId]) do
			local nLeaveId = nil;
			for _, nPlayerId in pairs(tbLeague.tbPlayerList) do
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if pPlayer then
					nLeaveId = self:KickPlayer(pPlayer, "新的比赛开启,强制踢出准备场", nType, nLeaveId);
				end
			end
		end
		self.GroupList[nType][nReadyId] = {};
	end
	self.tbGameState[nType]	= 0;
	self.GroupListTemp[nType] = {};

end

--准备场启动开始
function Wldh:OnGameWaitStartGS(nType, nIsFinal)
	Wldh.AdvMatchState[nType] = nIsFinal;
	local szAnncone = string.format("武林大会%s开始接受报名，玩家可以到临安武林大会接引人处进入英雄岛，再通过英雄岛的武林大会官员传送入场报名。", self:GetName(nType));
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szAnncone);
	self.tbReadyTimer[nType] = Timer:Register(self.MACTH_TIME_READY,  self.CloseGameTimer,  self, nType);
	self.tbGameState[nType] = 1;
	GCExcute({"Wldh:Gb_Anncone", szAnncone});
end

function Wldh:Anncone_GS(szAnncone)
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szAnncone);
	KDialog.Msg2SubWorld(szAnncone);
end

--比赛场开始
function Wldh:OnGamePkStartGS(nType, nIsFinal)
	self.tbGameState[nType] = 2;
	Wldh.AdvMatchState[nType] = nIsFinal;
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, "武林大会正式开始，请参赛选手做好比赛准备。");
	Wldh:OpenMission(nType, nIsFinal);
	Wldh:EnterPkMapRule(nType, nIsFinal);
end

--开启准备场mission
function Wldh:OpenMission(nType, nIsFinal)
	for nReadyId, nMapId in pairs(self:GetMapReadyTable(nType)) do
		if SubWorldID2Idx(nMapId) >= 0 then
			self.MissionList[nType] = self.MissionList[nType] or {};
			self.MissionList[nType][nReadyId] = Lib:NewClass(self.GameMission);
			self.MissionList[nType][nReadyId]:StartGame(nReadyId, nType, nIsFinal);
		end
	end
end

--关闭准备场mission
function Wldh:CloseMission(nType)
	if not self.MissionList[nType] then
		self.MissionList[nType] = {};
	end
	for nReadyId, tbMission in pairs(self.MissionList[nType]) do
		if tbMission:IsOpen() ~= 0 then
			tbMission:OnGameOver();
		end
	end
end

--开启界面
function Wldh:OpenSingleUi(pPlayer, szMsg, nLastFrameTime)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SetBattleTimer(pPlayer,  szMsg, nLastFrameTime);
	Dialog:ShowBattleMsg(pPlayer,  1,  0); --开启界面
end

--关闭界面
function Wldh:CloseSingleUi(pPlayer)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:ShowBattleMsg(pPlayer,  0,  0); -- 关闭界面
end

--更新界面时间
function Wldh:UpdateTimeUi(pPlayer, szMsg, nLastFrameTime)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SetBattleTimer(pPlayer,  szMsg, nLastFrameTime);
end

--更新界面信息
function Wldh:UpdateMsgUi(pPlayer, szMsg)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SendBattleMsg(pPlayer, szMsg, 1);
end

--更新准备场界面信息
function Wldh:UpdateAllMsgUi(nGameLevel, nReadyId, szLeagueName)
	if not self.GroupList[nGameLevel][nReadyId] or not self.GroupList[nGameLevel][nReadyId][szLeagueName] or not self.GroupList[nGameLevel][nReadyId][szLeagueName].tbPlayerList then
		return 0;
	end
	for _, nPlayerId in pairs(self.GroupList[nGameLevel][nReadyId][szLeagueName].tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		Wldh:UpdateMsgUi(pPlayer, string.format("\n\n<color=green>进入准备场中队员数：<color><color=white>%s<color>\n\n<color=green>等待比赛开始<color>", #self.GroupList[nGameLevel][nReadyId][szLeagueName].tbPlayerList));
	end
end

--提示准备场已满
function Wldh:MapStateFull(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.Msg("武林大会准备场参赛队伍数已满。");
		Dialog:SendBlackBoardMsg(pPlayer, "武林大会准备场参赛队伍数已满。");
	end
end

--玩家进入准备场
function Wldh:EnterReadyMap(nPlayerId, szLeagueName, nReadyId, nType)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		Wldh:SetAttendThisType(pPlayer, nType);
		local tbPos = self.MACTH_TRAP_ENTER[MathRandom(1, #self.MACTH_TRAP_ENTER)];
		pPlayer.NewWorld(self:GetMapReadyTable(nType)[nReadyId], unpack(tbPos));
	end
end

--把玩家踢到会场
function Wldh:KickPlayer(pPlayer, szMsg, nType, nLeaveId)
		-- 设定可选配置项
	Wldh:SetAttendThisType(pPlayer, nType);
	--随机会场
	local tbLeaveMap = Wldh:GetLeaveMapPos(nType, 0, {nFaction = pPlayer.nFaction, nSeries= pPlayer.nSeries, nCamp=pPlayer.GetCamp()});
	
	if szMsg then
		pPlayer.Msg(szMsg);
	end
	if nLeaveId then
		pPlayer.NewWorld(unpack(tbLeaveMap[nLeaveId]));
	else
		nLeaveId = pPlayer.NewWorld(unpack(tbLeaveMap[MathRandom(1, #tbLeaveMap)]));
	end
	
	return nLeaveId;
end

--判断战队是否符合参加八强赛资格。
function Wldh:IsAdvMacthLeague(nType, nAdvState, szLeagueName)
	if not Wldh.AdvMatchLists[nType] then
		return 0;
	end
	local nLGType = self:GetLGType(nType);
	local nRank = League:GetLeagueTask(nLGType, szLeagueName, Wldh.LGTASK_RANK);
	if not nRank or nRank <= 0 or nRank > 32 then
		return 0;
	end
	for nReayId, tbList in pairs(Wldh.AdvMatchLists[nType]) do
		if Wldh.AdvMatchLists[nType][nReayId][Wldh.MACTH_STATE_ADV_TASK[nAdvState]] then
			for _, tbLeague in pairs(Wldh.AdvMatchLists[nType][nReayId][Wldh.MACTH_STATE_ADV_TASK[nAdvState]]) do
				if tbLeague.szName == szLeagueName then
					return 1;
				end
			end
		end
	end
	
	return 0;
end

function Wldh:SetAdvMacthResult(nType, nReadyId)
	--设置冠军
	local nLGType = Wldh:GetLGType(nType);
--	for nReadyId, tbList in pairs(Wldh.AdvMatchLists) do
	if Wldh.AdvMatchLists[nType] and Wldh.AdvMatchLists[nType][nReadyId] then
		if Wldh.AdvMatchLists[nType][nReadyId][2] then
			local nGargeA = 0;
			local nGargeB = 0;
			local nRankA  = 0;
			local nRankB  = 0;
			if Wldh.AdvMatchLists[nType][nReadyId][2][1] then
				nRankA = League:GetLeagueTask(nLGType, Wldh.AdvMatchLists[nType][nReadyId][2][1].szName, Wldh.LGTASK_RANK);
		
				for _, nResult in pairs(Wldh.AdvMatchLists[nType][nReadyId][2][1].tbResult) do
					if nResult == 1 or nResult == 4 then
						nGargeA = nGargeA + 1;
					end
				end
			end
			if Wldh.AdvMatchLists[nType][nReadyId][2][2] then
				nRankB = League:GetLeagueTask(nLGType, Wldh.AdvMatchLists[nType][nReadyId][2][2].szName, Wldh.LGTASK_RANK);
				for _, nResult in pairs(Wldh.AdvMatchLists[nType][nReadyId][2][2].tbResult) do
					if nResult == 1 or nResult == 4 then
						nGargeB = nGargeB + 1;
					end
				end
			end
			local nRankAdvA = 0;
			local nRankAdvB = 0;
			if nGargeA > 0 and nGargeA == nGargeB then
				if nRankA < nRankB then
					nRankAdvA = 1;
					nRankAdvB = 2;
				else
					nRankAdvA = 2;
					nRankAdvB = 1;
				end
			elseif nGargeA == 0 and nGargeA == nGargeB then
				nRankAdvA = 2;
				nRankAdvB = 2;
			elseif nGargeA > nGargeB then
				nRankAdvA = 1;
				nRankAdvB = 2;
			else
				nRankAdvA = 2;
				nRankAdvB = 1;				
			end
			if nRankAdvA == 1 then
			   	Wldh.AdvMatchLists[nType][nReadyId][1][1]	= Wldh.AdvMatchLists[nType][nReadyId][2][1];
			elseif nRankAdvB == 1 then
				Wldh.AdvMatchLists[nType][nReadyId][1][1]	= Wldh.AdvMatchLists[nType][nReadyId][2][2];
			end
			if Wldh.AdvMatchLists[nType][nReadyId][2][1] then
				League:SetLeagueTask(nLGType, Wldh.AdvMatchLists[nType][nReadyId][2][1].szName, Wldh.LGTASK_RANK_ADV, nRankAdvA);
			end
			if Wldh.AdvMatchLists[nType][nReadyId][2][2] then
				League:SetLeagueTask(nLGType, Wldh.AdvMatchLists[nType][nReadyId][2][2].szName, Wldh.LGTASK_RANK_ADV, nRankAdvB);
			end
			GCExcute{"Wldh:SyncAdvMatchList", nType, nReadyId, 1, Wldh.AdvMatchLists[nType][nReadyId][1]};
			--GCExcute{"Wldh:UpdateAdvHelpNews"};
		end
	end
end

function Wldh:SyncAdvMatchUiList(nType)

	for nPlayerId in pairs(Wldh.WaitMapMemList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			Wldh:SyncAdvMatchUiSingle(nType, pPlayer, nReadyId, 1 * 3600 * 18);
		end
	end
	
	if self.GroupList[2] then
		for nReadyId, tbReadyList in pairs(self.GroupList[2]) do
			for _, tbList in pairs(tbReadyList) do
				for _, nPlayerId in pairs(tbList.tbPlayerList) do
					local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
					if pPlayer then
						Wldh:SyncAdvMatchUiSingle(nType, pPlayer, nReadyId, 15 * 60 * 18);
					end	
				end
			end
		end
	end
end

function Wldh:SyncAdvMatchUiSingle(nType, pPlayer, nReadyId, nUsefulTime)
	local _, nFinal = self:GetCurGameType();
	if not nFinal or nFinal <= 0 then
		return 0;
	end
	if nType == 0 or nReadyId == 0 or nUsefulTime == 0 or not pPlayer then
		Dialog:SyncCampaignDate(pPlayer, "WuLinDaHui", nil, nUsefulTime);		
		return 0;
	end
	local nLGType = Wldh:GetLGType(nType);
	
	if self:GetMapLinkType(nType) == Wldh.MAP_LINK_TYPE_RANDOM then
		nReadyId = 1;	--每个场都一样
	end	
	
	if self:GetMapLinkType(nType) == Wldh.MAP_LINK_TYPE_FACTION then
		--自己的场情况，用原有nReadyId
		local szLeagueName	= League:GetMemberLeague(nLGType, pPlayer.szName);
		if (not szLeagueName) then
			return 0;
		end
		nReadyId = League:GetMemberTask(nLGType, szLeagueName, pPlayer.szName, Wldh.LGMTASK_FACTION);
	end
	
	if not self.AdvMatchLists[nType] or not self.AdvMatchLists[nType][nReadyId] or not self.AdvMatchLists[nType][nReadyId][32] or #self.AdvMatchLists[nType][nReadyId][32] <= 0 then
		return 0;
	end
	Dialog:SyncCampaignDate(pPlayer, "WuLinDaHui", self.AdvMatchLists[nType][nReadyId], nUsefulTime);
end
