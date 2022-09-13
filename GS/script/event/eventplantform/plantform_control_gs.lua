--武林联赛
--孙多良
--2008.09.11
if (MODULE_GC_SERVER) then
	return 0;
end

--比赛结束
function EPlatForm:GameOver()
	if self.ReadyTimerId > 0 then
		if Timer:GetRestTime(self.ReadyTimerId) > 0 then
			Timer:Close(self.ReadyTimerId);
			self.ReadyTimerId = 0;
		end		
	end

	EPlatForm:CloseMission();
end

--关闭准备场时间计时
function EPlatForm:CloseGameTimer()
	self.ReadyTimerId = 0;
	return 0;
end

--初始化数据
function EPlatForm:InitDate(nTaskId)
	self:GameOver();
	
	local tbMacthLevelCfg2 = self:GetMacthTypeCfg(self:GetMacthType());
	for nReadyId, nMapId in pairs(tbMacthLevelCfg2.tbReadyMap) do
		if not self.GroupList[nReadyId] then
			self.GroupList[nReadyId] = {};
		end
		for _, tbLeague in pairs(self.GroupList[nReadyId]) do
			local nLeaveId = nil;
			for _, nPlayerId in pairs(tbLeague.tbPlayerList) do
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if pPlayer then
					nLeaveId = self:KickPlayer(pPlayer, "新的比赛开启,强制踢出准备场", nLeaveId);
				end
			end
		end
		self.GroupList[nReadyId] = {};
	end	
	self.GroupListTemp = {};
	if tonumber(nTaskId) then
		EPlatForm.AdvMatchState	= nTaskId;
	end
	
	--八强赛初始化数据
	if EPlatForm.AdvMatchState == 1 then
		for nReadyId, nMapId in pairs(tbMacthLevelCfg2.tbReadyMap) do
			EPlatForm.AdvMatchLists[nReadyId] = {};
			EPlatForm.AdvMatchLists[nReadyId][8] = {};
			EPlatForm.AdvMatchLists[nReadyId][4] = {};
			EPlatForm.AdvMatchLists[nReadyId][2] = {};
			EPlatForm.AdvMatchLists[nReadyId][1] = {};
			
			if nReadyId == 1 and SubWorldID2Idx(nMapId) > 0 then
				local tbLadder, szName, szContext = GetShowLadder(self:GetCurEventLadderType());
				for nId, tbLeague in ipairs(tbLadder) do
					if nId <= 8 then
						EPlatForm.AdvMatchLists[nReadyId][8][nId] = {szName = tbLeague.szName, tbResult={}};
						League:SetLeagueTask(EPlatForm.LGTYPE, tbLeague.szName, EPlatForm.LGTASK_RANK_ADV, 8);
					end
				end
				GCExcute{"EPlatForm:SyncAdvMatchList", nReadyId, EPlatForm.AdvMatchLists[nReadyId]};
			end
		end
	end
	
	if EPlatForm.AdvMatchState > 0 then
		if EPlatForm.AdvMatchState > 1 then
			for nReadyId, nMapId in pairs(tbMacthLevelCfg2.tbReadyMap) do
				if SubWorldID2Idx(nMapId) > 0 and EPlatForm.AdvMatchLists[nReadyId] then
					GCExcute{"EPlatForm:SyncAdvMatchList", nReadyId, EPlatForm.AdvMatchLists[nReadyId]};
				end
			end
		end
		GCExcute{"EPlatForm:UpdateAdvHelpNews"};
	end
end

--准备场启动开始
function EPlatForm:GameStart(nTaskId)
	local tbMacthLevelCfg = self:GetMacthTypeCfg(self:GetMacthType());
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, string.format("%s活动开始报名了，请到各活动报名点报名", tbMacthLevelCfg.szName));
	self:ApplyDynMatchMap();
	self.ReadyTimerId = Timer:Register(self.MACTH_TIME_READY,  self.CloseGameTimer,  self);
	self.nMatchTaskId	= nTaskId;
	self.GameState = 1;
end

function EPlatForm:ApplyDynMatchMap()
	local tbMacthLevelCfg = self:GetMacthTypeCfg(self:GetMacthType());
	for nReadyId, nMapId in pairs(tbMacthLevelCfg.tbReadyMap) do
		if SubWorldID2Idx(nMapId) >= 0 then
			local nDynCount = math.ceil((self.nCurReadyMaxCount or 0) / self.nCurMatchMaxTeamCount);
			local nDynTempMapId = tbMacthLevelCfg.tbMacthMap[1];
			if (not tbMacthLevelCfg.tbDynMapLists[nReadyId]) then
				tbMacthLevelCfg.tbDynMapLists[nReadyId] = {};
			end
			local nCurCount = #tbMacthLevelCfg.tbDynMapLists[nReadyId];
			if nCurCount < nDynCount then
				for i=1, (nDynCount - nCurCount) do
					if (Map:LoadDynMap(1, nDynTempMapId, {self.OnLoadMapFinish, self, nMapId}) ~= 1) then
						print("家族活动竞技平台地图加载失败。。", nDynTempMapId, nMapId);
					end
				end
			end
		end
	end
end

--比赛地图动态加载成功
function EPlatForm:OnLoadMapFinish(nMapId, nDyMapId)
	local tbMacthCfg = self:GetMacthTypeCfg(self:GetMacthType());
	if (not tbMacthCfg) then
		print("OnLoadMapFinish not tbMacthCfg  Error !!!!!!!!!!!!!!");
		return;
	end
	local nReadyId = self:GetReadyIdByMapId(nMapId);
	if (nReadyId <= 0) then
		return;
	end
	tbMacthCfg.tbDynMapLists[nReadyId] = tbMacthCfg.tbDynMapLists[nReadyId] or {};
	table.insert(tbMacthCfg.tbDynMapLists[nReadyId], nDyMapId);
	--EPlatForm:LoadOneMapFun_PkMap(nDyMapId);
end

function EPlatForm:GetReadyIdByMapId(nCurMapId)
	local tbMacthCfg = self:GetMacthTypeCfg(self:GetMacthType());
	for nReadyId, nMapId in pairs(tbMacthCfg.tbReadyMap) do
		if (nCurMapId == nMapId) then
			return nReadyId;
		end
	end
	return 0;
end

--比赛场开始
function EPlatForm:GamePkStart(nTaskId)
	self.GameState = 2;
	local tbMacthLevelCfg = self:GetMacthTypeCfg(self:GetMacthType());
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, string.format("%s活动开始了，请参赛选手做好比赛准备。", tbMacthLevelCfg.szName));
	self.nMatchTaskId = nTaskId;
	self:OpenMission();
	self:EnterPkMapRule();
	self:StartGame();
	self:ClearReadyMap();
end

function EPlatForm:StartGame()
	local tbMacthLevelCfg = self:GetMacthTypeCfg(self:GetMacthType());
	if (not tbMacthLevelCfg or not tbMacthLevelCfg.tbDynMapLists) then
		return 0;
	end
	for nReadyId, tbMapId in pairs(tbMacthLevelCfg.tbDynMapLists) do
		local nReadyMapId = tbMacthLevelCfg.tbReadyMap[nReadyId];
		for nId, nMapId in pairs(tbMapId) do
			if self.MissionList[nReadyId] then
				local tbMission = self.MissionList[nReadyId][nId];
				if (tbMission and tbMission:IsOpen() ~= 0) then
					local nCount = tbMission:GetGroupCount() or 0;
					if (nCount > 0) then
						tbMission:StartGame();
					else
						tbMission:CloseGame();
					end
				end
			end
		end
	end
end

--开启比赛场mission
function EPlatForm:OpenMission()
	--self:CloseMission();
	local tbMacthLevelCfg = self:GetMacthTypeCfg(self:GetMacthType());
	local szBaseMission = tbMacthLevelCfg.tbMacthCfg.szBaseMission;
	local fnFunc, tbSelf	= KLib.GetValByStr(szBaseMission);
	local nState		= self:GetMacthState();
	if (not tbMacthLevelCfg or not tbMacthLevelCfg.tbDynMapLists) then
		return 0;
	end
	for nReadyId, tbMapId in pairs(tbMacthLevelCfg.tbDynMapLists) do
		local nReadyMapId = tbMacthLevelCfg.tbReadyMap[nReadyId];
		if SubWorldID2Idx(nReadyMapId) >= 0 then
			for nId, nMapId in pairs(tbMapId) do
				if SubWorldID2Idx(nMapId) >= 0 then
					if not self.MissionList[nReadyId] then 
						self.MissionList[nReadyId] = {};
					end

					local tbEnterPos = {};
					for _, tbPos in pairs (tbMacthLevelCfg.tbPkPos) do
						tbEnterPos[#tbEnterPos + 1]	= {nMapId, tbPos[1], tbPos[2]};
					end

					local nLeaveMap, nLX, nLY = self:GetLeaveMapPos();
					local tbLeavePos	= {nLeaveMap, nLX, nLY};
					
					if (not self.MissionList[nReadyId][nId]) then
						self.MissionList[nReadyId][nId] = fnFunc(tbSelf);
					end
					if (self.MissionList[nReadyId][nId]) then
						self.MissionList[nReadyId][nId]:OpenMission(tbEnterPos, tbLeavePos, EPlatForm:GetMacthState(), nReadyId);
						if (self.DEF_STATE_ADVMATCH == nState) then
							if (EPlatForm.AdvMatchState >= 3) then
								break;
							end
						end
					else
						self:WriteLog("OpenMission failed! ", nMapId, nReadyMapId);
					end
				end
			end
		end
	end
end

--关闭比赛场mission
function EPlatForm:CloseMission()
	if not self.MissionList then
		self.MissionList = {};
	end
	for nReadyId, tbMissions in pairs(self.MissionList) do
		for nId, tbMission in pairs(tbMissions) do
			if tbMission:IsOpen() ~= 0 then
				tbMission:CloseGame();
			end
		end
	end
end

--开启界面
function EPlatForm:OpenSingleUi(pPlayer, szMsg, nLastFrameTime)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SetBattleTimer(pPlayer,  szMsg, nLastFrameTime);
	Dialog:ShowBattleMsg(pPlayer,  1,  0); --开启界面
end

--关闭界面
function EPlatForm:CloseSingleUi(pPlayer)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:ShowBattleMsg(pPlayer,  0,  0); -- 关闭界面
end

--更新界面时间
function EPlatForm:UpdateTimeUi(pPlayer, szMsg, nLastFrameTime)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SetBattleTimer(pPlayer,  szMsg, nLastFrameTime);
end

--更新界面信息
function EPlatForm:UpdateMsgUi(pPlayer, szMsg)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SendBattleMsg(pPlayer, szMsg, 1);
end

--更新准备场界面信息
function EPlatForm:UpdateAllMsgUi(nReadyId, szLeagueName)
	if not self.GroupList[nReadyId] or not self.GroupList[nReadyId][szLeagueName] or not self.GroupList[nReadyId][szLeagueName].tbPlayerList then
		return 0;
	end
	for _, nPlayerId in pairs(self.GroupList[nReadyId][szLeagueName].tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		EPlatForm:UpdateMsgUi(pPlayer, string.format("\n\n<color=green>进入准备场中队员数：<color><color=white>%s<color>\n\n<color=green>等待比赛开始<color>", #self.GroupList[nReadyId][szLeagueName].tbPlayerList));
	end
end

--提示准备场已满
function EPlatForm:MapStateFull(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.Msg("活动准备场参赛人数已满。");
		Dialog:SendBlackBoardMsg(pPlayer, "活动准备场参赛人数已满。");
	end
end

--玩家进入准备场
function EPlatForm:EnterReadyMap(nPlayerId, szLeagueName, nReadyId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		local tbMacthLevelCfg = self:GetMacthTypeCfg(self:GetMacthType());
		pPlayer.SetTask(EPlatForm.TASKID_GROUP, EPlatForm.TASKID_ENTER_READY, nReadyId);
		local tbPos = tbMacthLevelCfg.tbReadyPos[MathRandom(1, #tbMacthLevelCfg.tbReadyPos)];
		pPlayer.NewWorld(tbMacthLevelCfg.tbReadyMap[nReadyId], unpack(tbPos));
	end
end

--把玩家踢到会场
function EPlatForm:KickPlayer(pPlayer, szMsg, nLeaveId)
	if (not pPlayer) then
		return 0;
	end
	
	if szMsg then
		pPlayer.Msg(szMsg);
	end
	-- 传回当前服务器的新手村
	if nLeaveId then
		pPlayer.NewWorld(self:GetLeaveMapPos());
	else
		nLeaveId = pPlayer.NewWorld(self:GetLeaveMapPos());
	end
	
	return nLeaveId;
end



--判断门派竞技是否运行100级参加
function EPlatForm:CheckFactionLimit()
	if EPlatForm:GetMacthSession() == 1 and EPlatForm:GetMacthState() == EPlatForm.DEF_STATE_REST then
		return 0;
	end
	if EPlatForm:GetMacthSession() > 0 then
		return 1;
	end
	return 0;
end

--判断战队是否符合参加八强赛资格。
function EPlatForm:IsAdvMacthLeague(szLeagueName)
	local nRank = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_RANK);
	if not nRank or nRank <= 0 or nRank > 8 then
		return 0;
	end

	for nReayId, tbList in pairs(EPlatForm.AdvMatchLists) do
		if EPlatForm.AdvMatchLists[nReayId][EPlatForm.MACTH_STATE_ADV_TASK[EPlatForm.AdvMatchState]] then
			for _, tbLeague in pairs(EPlatForm.AdvMatchLists[nReayId][EPlatForm.MACTH_STATE_ADV_TASK[EPlatForm.AdvMatchState]]) do
				if tbLeague.szName == szLeagueName then
					return 1;
				end
			end
		end
	end
	
	return 0;
end

local tbAdvMatchSeries8 = {
	[1] = 1, [8] = 1,
	[2] = 2, [7] = 2,
	[3] = 3, [6] = 3,
	[4] = 4, [5] = 4,
};
local tbAdvMatchSeries4 = {
	[1] = 1, [8] = 1,
	[2] = 2, [7] = 2,
	[3] = 1, [6] = 1,
	[4] = 2, [5] = 2,
};

function EPlatForm:GetAdvMatchSeries(nRank, nState)
	if nState == 8 then
		return tbAdvMatchSeries8[nRank] or 0;
	end
	if nState == 4 then
		return tbAdvMatchSeries4[nRank] or 0;
	end
	if nState == 2 then
		return tbAdvMatchSeries4[nRank] or 0;
	end
	return 0;
end

function EPlatForm:SetAdvMacthResult(nReadyId)
	--设置冠军
--	for nReadyId, tbList in pairs(EPlatForm.AdvMatchLists) do
	if EPlatForm.AdvMatchLists[nReadyId]	then
		if EPlatForm.AdvMatchLists[nReadyId][2] then
			local nGargeA = 0;
			local nGargeB = 0;
			local nRankA  = 0;
			local nRankB  = 0;
			if EPlatForm.AdvMatchLists[nReadyId][2][1] then
				nRankA = League:GetLeagueTask(EPlatForm.LGTYPE, EPlatForm.AdvMatchLists[nReadyId][2][1].szName, EPlatForm.LGTASK_RANK);
		
				for _, nResult in pairs(EPlatForm.AdvMatchLists[nReadyId][2][1].tbResult) do
					if nResult == 1 or nResult == 4 then
						nGargeA = nGargeA + 1;
					end
				end
			end
			if EPlatForm.AdvMatchLists[nReadyId][2][2] then
				nRankB = League:GetLeagueTask(EPlatForm.LGTYPE, EPlatForm.AdvMatchLists[nReadyId][2][2].szName, EPlatForm.LGTASK_RANK);
				for _, nResult in pairs(EPlatForm.AdvMatchLists[nReadyId][2][2].tbResult) do
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
			local szFirst = "";
			if nRankAdvA == 1 then
			   	EPlatForm.AdvMatchLists[nReadyId][1][1]	= EPlatForm.AdvMatchLists[nReadyId][2][1];
			   	szFirst = EPlatForm.AdvMatchLists[nReadyId][1][1].szName;
			elseif nRankAdvB == 1 then
				EPlatForm.AdvMatchLists[nReadyId][1][1]	= EPlatForm.AdvMatchLists[nReadyId][2][2];
				szFirst = EPlatForm.AdvMatchLists[nReadyId][1][1].szName;
			end
			if EPlatForm.AdvMatchLists[nReadyId][2][1] then
				League:SetLeagueTask(EPlatForm.LGTYPE, EPlatForm.AdvMatchLists[nReadyId][2][1].szName, EPlatForm.LGTASK_RANK_ADV, nRankAdvA);
				EPlatForm:SendAdvMatchResultMsg(EPlatForm.AdvMatchLists[nReadyId][2][1].szName, nRankAdvA);
			end
			if EPlatForm.AdvMatchLists[nReadyId][2][2] then
				League:SetLeagueTask(EPlatForm.LGTYPE, EPlatForm.AdvMatchLists[nReadyId][2][2].szName, EPlatForm.LGTASK_RANK_ADV, nRankAdvB);
				EPlatForm:SendAdvMatchResultMsg(EPlatForm.AdvMatchLists[nReadyId][2][2].szName, nRankAdvB);
			end
			
			if (szFirst and szFirst ~= "") then
				local nSession = self:GetMacthSession();
				local szKinName = self:GetKinNameFromLeagueName(szFirst);
				if (MODULE_GAMESERVER) then
					local nKinAwardFlag = nSession * 10000 + 1;
					GCExcute{"EPlatForm:SetKinAwardParam", szKinName, nKinAwardFlag};
				end
			end

			GCExcute{"EPlatForm:SyncAdvMatchList", nReadyId, EPlatForm.AdvMatchLists[nReadyId]};
			GCExcute{"EPlatForm:UpdateAdvHelpNews"};			

		end
	end
end

function EPlatForm:SyncAdvMatchUiList()
	if EPlatForm:GetMacthState() ~= EPlatForm.DEF_STATE_ADVMATCH then
		return 0;
	end
	
	if self.GroupList[2] then
		for nReadyId, tbReadyList in pairs(self.GroupList[2]) do
			for _, tbList in pairs(tbReadyList) do
				for _, nPlayerId in pairs(tbList.tbPlayerList) do
					local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
					if pPlayer then
						EPlatForm:SyncAdvMatchUiSingle(pPlayer, nReadyId, 15 * 60 * 18);
					end	
				end
			end
		end
	end
end

function EPlatForm:SyncAdvMatchUiSingle(pPlayer, nReadyId, nUsefulTime)
	if EPlatForm:GetMacthState() ~= EPlatForm.DEF_STATE_ADVMATCH then
		nUsefulTime = 0;
	end	

	nReadyId = 1;	--每个场都一样

	if not self.AdvMatchLists[nReadyId] or not self.AdvMatchLists[nReadyId][8] or #self.AdvMatchLists[nReadyId][8] <= 0 then
		nUsefulTime = 0;
	end
	if pPlayer then
		if nUsefulTime == 0 then
			Dialog:SyncCampaignDate(pPlayer, "LeagueMatch", nil, nUsefulTime);	
		else
			Dialog:SyncCampaignDate(pPlayer, "LeagueMatch", self.AdvMatchLists[nReadyId], nUsefulTime);
		end
	end
end

-- 过界要清
function EPlatForm:ClearMissionList()
	self.MissionList = {};
end
