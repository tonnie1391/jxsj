--武林联赛
--孙多良
--2008.09.11
if (MODULE_GC_SERVER) then
	return 0;
end

--比赛结束
function Wlls:GameOver()
	if self.ReadyTimerId > 0 then
		if Timer:GetRestTime(self.ReadyTimerId) > 0 then
			Timer:Close(self.ReadyTimerId);
			self.ReadyTimerId = 0;
		end		
	end

	Wlls:CloseMission(Wlls.MACTH_PRIM);
	Wlls:CloseMission(Wlls.MACTH_ADV);
end

--关闭准备场时间计时
function Wlls:CloseGameTimer()
	self.ReadyTimerId = 0;
	return 0;
end

--初始化数据
function Wlls:InitDate(nTaskId)
	self:GameOver();
	local tbMacthLevelCfg1 = self:GetMacthLevelCfg(self:GetMacthType(), Wlls.MACTH_PRIM);
	for nReadyId, nMapId in pairs(tbMacthLevelCfg1.tbReadyMap) do
		if not self.GroupList[Wlls.MACTH_PRIM][nReadyId] then
			self.GroupList[Wlls.MACTH_PRIM][nReadyId] = {};
		end
		for _, tbLeague in pairs(self.GroupList[Wlls.MACTH_PRIM][nReadyId]) do
			local nLeaveId = nil;
			for _, nPlayerId in pairs(tbLeague.tbPlayerList) do
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if pPlayer then
					nLeaveId = self:KickPlayer(pPlayer, "Trận đấu mới bắt đầu, buộc ra khỏi đây", Wlls.MACTH_PRIM, nLeaveId);
				end
			end
		end
		self.GroupList[Wlls.MACTH_PRIM][nReadyId] = {};
	end
	self.GroupListTemp[Wlls.MACTH_PRIM] = {};
	
	local tbMacthLevelCfg2 = self:GetMacthLevelCfg(self:GetMacthType(), Wlls.MACTH_ADV);
	for nReadyId, nMapId in pairs(tbMacthLevelCfg2.tbReadyMap) do
		if not self.GroupList[Wlls.MACTH_ADV][nReadyId] then
			self.GroupList[Wlls.MACTH_ADV][nReadyId] = {};
		end
		for _, tbLeague in pairs(self.GroupList[Wlls.MACTH_ADV][nReadyId]) do
			local nLeaveId = nil;
			for _, nPlayerId in pairs(tbLeague.tbPlayerList) do
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if pPlayer then
					nLeaveId = self:KickPlayer(pPlayer, "Trận đấu mới bắt đầu, buộc ra khỏi đây", Wlls.MACTH_ADV, nLeaveId);
				end
			end
		end
		self.GroupList[Wlls.MACTH_ADV][nReadyId] = {};
	end	
	self.GroupListTemp[Wlls.MACTH_ADV] = {};
	self.LookerLeagueMap = {};
	Wlls.LookPlayerCount = {};
	Wlls.tbLookerReady	 = {};
	Wlls.tbLook			 = {};
	if tonumber(nTaskId) then
		Wlls.AdvMatchState	= nTaskId;
	end
	
	--八强赛初始化数据
	if Wlls.AdvMatchState == 1 then
		for nReadyId, nMapId in pairs(tbMacthLevelCfg2.tbReadyMap) do
			Wlls.AdvMatchLists[nReadyId] = {};
			Wlls.AdvMatchLists[nReadyId][8] = {};
			Wlls.AdvMatchLists[nReadyId][4] = {};
			Wlls.AdvMatchLists[nReadyId][2] = {};
			Wlls.AdvMatchLists[nReadyId][1] = {};
			
			if Wlls:GetMacthLevelCfgType() == Wlls.MAP_LINK_TYPE_RANDOM then
				if nReadyId == 1 and SubWorldID2Idx(nMapId) > 0 then
					local tbLadder, szName, szContext = GetShowLadder(Ladder:GetType(0, 3, 2, 0));
					for nId, tbLeague in ipairs(tbLadder) do
						if nId <= 8 then
							Wlls.AdvMatchLists[nReadyId][8][nId] = {szName = tbLeague.szName, tbResult={}};
							League:SetLeagueTask(Wlls.LGTYPE, tbLeague.szName, Wlls.LGTASK_RANK_ADV, 8);
						end
					end
					GCExcute{"Wlls:SyncAdvMatchList", nReadyId, Wlls.AdvMatchLists[nReadyId]};
				end
			end	
		
			if Wlls:GetMacthLevelCfgType() == Wlls.MAP_LINK_TYPE_SERIES then
				--自己的场情况，用原有nReadyId
				local tbLadder, szName, szContext = GetShowLadder(Ladder:GetType(0, 3, 2, nReadyId));
				for nId, tbLeague in ipairs(tbLadder) do
					if nId <= 8 then
						Wlls.AdvMatchLists[nReadyId][8][nId] = {szName = tbLeague.szName, tbResult={}};
						League:SetLeagueTask(Wlls.LGTYPE, tbLeague.szName, Wlls.LGTASK_RANK_ADV, 8);
					end
				end
				GCExcute{"Wlls:SyncAdvMatchList", nReadyId, Wlls.AdvMatchLists[nReadyId]};				
			end		
			
			if Wlls:GetMacthLevelCfgType() == Wlls.MAP_LINK_TYPE_FACTION then
				local tbLadder, szName, szContext = GetShowLadder(Ladder:GetType(0, 3, 2, nReadyId));
				for nId, tbLeague in ipairs(tbLadder) do
					if nId <= 8 then
						Wlls.AdvMatchLists[nReadyId][8][nId] = {szName = tbLeague.szName, tbResult={}};
						League:SetLeagueTask(Wlls.LGTYPE, tbLeague.szName, Wlls.LGTASK_RANK_ADV, 8);
					end
				end
				GCExcute{"Wlls:SyncAdvMatchList", nReadyId, Wlls.AdvMatchLists[nReadyId]};
			end			
		end
	end
	
	if Wlls.AdvMatchState > 0 then
		if Wlls.AdvMatchState > 1 then
			for nReadyId, nMapId in pairs(tbMacthLevelCfg2.tbReadyMap) do
				if SubWorldID2Idx(nMapId) > 0 and Wlls.AdvMatchLists[nReadyId] then
					GCExcute{"Wlls:SyncAdvMatchList", nReadyId, Wlls.AdvMatchLists[nReadyId]};
				end
			end
		end
		GCExcute{"Wlls:UpdateAdvHelpNews"};
	end
end

--准备场启动开始
function Wlls:GameStart()
	if (not GLOBAL_AGENT) then
		KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, "Võ Lâm Liên Đấu đã bắt đầu ghi danh. Hãy đến Quan Liên Đấu tại các thành thị để ghi danh.");		
	end
	self.ReadyTimerId = Timer:Register(self.MACTH_TIME_READY,  self.CloseGameTimer,  self);
	self.GameState = 1;
end

--比赛场开始
function Wlls:GamePkStart(nGameLevel)
	self.GameState = 2;
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, "Võ Lâm Liên Đấu chính thức bắt đầu, các hiệp sĩ hãy chuẩn bị.");
	Wlls:OpenMission(nGameLevel);
	Wlls:EnterPkMapRule(nGameLevel);
end

--开启准备场mission
function Wlls:OpenMission(nGameLevel)
	--self:CloseMission(nGameLevel);
--	print("调试信息\n" .. debug.traceback());
	local tbMacthLevelCfg	= self:GetMacthLevelCfg(self:GetMacthType(), nGameLevel);
	local nNowMissionType	= self:GetMissionType(self:GetMacthType());
	local tbMission			= self:GetMacthMission(self:GetMacthType());
	if (not tbMission) then
		Wlls:WriteLog(string.format("[ERROR] There is no this Type Mission, MatchType %s, GameLevel %s!!!!!", self:GetMacthType(), nGameLevel));
		return 0;
	end
	for nReadyId, nMapId in pairs(tbMacthLevelCfg.tbReadyMap) do
		if SubWorldID2Idx(nMapId) >= 0 then
			if not self.MissionList[nGameLevel][nReadyId] then
				self.MissionList[nGameLevel][nReadyId] = Lib:NewClass(tbMission);
			end
			-- 这样做的目的是防止换一届结果mission没换
			if (self.MissionList[nGameLevel][nReadyId]:GetMissionType() ~= nNowMissionType) then
				self.MissionList[nGameLevel][nReadyId] = nil;
				self.MissionList[nGameLevel][nReadyId] = Lib:NewClass(tbMission);
			end
			
			self.MissionList[nGameLevel][nReadyId]:StartGame(nReadyId, nGameLevel, nNowMissionType);
		end
	end
end

--关闭准备场mission
function Wlls:CloseMission(nGameLevel)
	if not self.MissionList[nGameLevel] then
		self.MissionList[nGameLevel] = {};
	end
	for nReadyId, tbMission in pairs(self.MissionList[nGameLevel]) do
		if tbMission:IsOpen() ~= 0 then
			tbMission:OnGameOver(1);
		end
	end
end

--开启界面
function Wlls:OpenSingleUi(pPlayer, szMsg, nLastFrameTime)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SetBattleTimer(pPlayer,  szMsg, nLastFrameTime);
	Dialog:ShowBattleMsg(pPlayer,  1,  0); --开启界面
end

--关闭界面
function Wlls:CloseSingleUi(pPlayer)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:ShowBattleMsg(pPlayer,  0,  0); -- 关闭界面
end

--更新界面时间
function Wlls:UpdateTimeUi(pPlayer, szMsg, nLastFrameTime)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SetBattleTimer(pPlayer,  szMsg, nLastFrameTime);
end

--更新界面信息
function Wlls:UpdateMsgUi(pPlayer, szMsg)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SendBattleMsg(pPlayer, szMsg, 1);
end

--更新准备场界面信息
function Wlls:UpdateAllMsgUi(nGameLevel, nReadyId, szLeagueName)
	if not self.GroupList[nGameLevel][nReadyId] or not self.GroupList[nGameLevel][nReadyId][szLeagueName] or not self.GroupList[nGameLevel][nReadyId][szLeagueName].tbPlayerList then
		return 0;
	end
	for _, nPlayerId in pairs(self.GroupList[nGameLevel][nReadyId][szLeagueName].tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		Wlls:UpdateMsgUi(pPlayer, string.format("\n\n<color=green>Số lượng người tham dự: <color><color=white>%s<color>\n\n<color=green>Thi đấu sắp bắt đầu<color>", #self.GroupList[nGameLevel][nReadyId][szLeagueName].tbPlayerList));
	end
end

--提示准备场已满
function Wlls:MapStateFull(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.Msg("Số lượng người tham dự đã đủ.");
		Dialog:SendBlackBoardMsg(pPlayer, "Số lượng người tham dự đã đủ.");
	end
end

--玩家进入准备场
function Wlls:EnterReadyMap(nPlayerId, szLeagueName, nReadyId, nGameLevel)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		local tbMacthLevelCfg = self:GetMacthLevelCfg(self:GetMacthType(), nGameLevel);
		--pPlayer.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_ENTER_READY, nReadyId);
		local tbPos = self.MACTH_TRAP_ENTER[MathRandom(1, #self.MACTH_TRAP_ENTER)];
		pPlayer.NewWorld(tbMacthLevelCfg.tbReadyMap[nReadyId], unpack(tbPos));
	end
end

--把玩家踢到会场
function Wlls:KickPlayer(pPlayer, szMsg, nGameLevel, nLeaveId)
		-- 设定可选配置项
	local tbMacthCfg = Wlls:GetMacthTypeCfg(Wlls:GetMacthType());
	local tbMacthLevelCfg = Wlls:GetMacthLevelCfg(Wlls:GetMacthType(), nGameLevel);
	
	--随机会场
	local tbLeaveMap = Wlls:GetLeaveMapPos(tbMacthCfg, tbMacthLevelCfg, 0, {nFaction = pPlayer.nFaction, nSeries= pPlayer.nSeries, nCamp=pPlayer.GetCamp()});
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

--判断门派竞技是否运行100级参加
function Wlls:CheckFactionLimit()
	if Wlls:GetMacthSession() == 1 and Wlls:GetMacthState() == Wlls.DEF_STATE_REST then
		return 0;
	end
	if Wlls:GetMacthSession() > 0 then
		return 1;
	end
	return 0;
end

--判断战队是否符合参加八强赛资格。
function Wlls:IsAdvMacthLeague(szLeagueName)
	local nRank = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_RANK);
	if not nRank or nRank <= 0 or nRank > 8 then
		return 0;
	end

	for nReayId, tbList in pairs(Wlls.AdvMatchLists) do
		if Wlls.AdvMatchLists[nReayId][Wlls.MACTH_STATE_ADV_TASK[Wlls.AdvMatchState]] then
			for _, tbLeague in pairs(Wlls.AdvMatchLists[nReayId][Wlls.MACTH_STATE_ADV_TASK[Wlls.AdvMatchState]]) do
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

function Wlls:GetAdvMatchSeries(nRank, nState)
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

function Wlls:SetAdvMacthResult(nReadyId)
	--设置冠军
--	for nReadyId, tbList in pairs(Wlls.AdvMatchLists) do
	if Wlls.AdvMatchLists[nReadyId]	then
		if Wlls.AdvMatchLists[nReadyId][2] then
			local nGargeA = 0;
			local nGargeB = 0;
			local nRankA  = 0;
			local nRankB  = 0;
			if Wlls.AdvMatchLists[nReadyId][2][1] then
				nRankA = League:GetLeagueTask(Wlls.LGTYPE, Wlls.AdvMatchLists[nReadyId][2][1].szName, Wlls.LGTASK_RANK);
		
				for _, nResult in pairs(Wlls.AdvMatchLists[nReadyId][2][1].tbResult) do
					if nResult == 1 or nResult == 4 then
						nGargeA = nGargeA + 1;
					end
				end
			end
			if Wlls.AdvMatchLists[nReadyId][2][2] then
				nRankB = League:GetLeagueTask(Wlls.LGTYPE, Wlls.AdvMatchLists[nReadyId][2][2].szName, Wlls.LGTASK_RANK);
				for _, nResult in pairs(Wlls.AdvMatchLists[nReadyId][2][2].tbResult) do
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
			
			local tbLeague;
			if nRankAdvA == 1 then
			   	tbLeague = Wlls.AdvMatchLists[nReadyId][2][1];
				Wlls.AdvMatchLists[nReadyId][1][1] = tbLeague;
			elseif nRankAdvB == 1 then
				tbLeague = Wlls.AdvMatchLists[nReadyId][2][2];
				Wlls.AdvMatchLists[nReadyId][1][1] = tbLeague;
			end
			--如果存在联赛冠军,则向冠军战队的每个成员推送SNS通知
			if tbLeague then
				local szPopupMessage = "Chúc mừng đội của bạn đã trở thành <color=yellow>Quán Quân Liên Đấu<color>!";
				local szTweet = string.format("#Kiếm Thế# Đội \"%s\" đã dành chức Vô địch. Thật tuyệt!!! ", tbLeague.szName);
				local tbMemberList = Wlls:GetLeagueMemberList(tbLeague.szName);
				for _, szPlayerName in ipairs(tbMemberList) do
					local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
					if pPlayer then
						Sns:NotifyClientNewTweet(pPlayer, szPopupMessage, szTweet);
					end
				end
			end
			
			if Wlls.AdvMatchLists[nReadyId][2][1] then
				League:SetLeagueTask(Wlls.LGTYPE, Wlls.AdvMatchLists[nReadyId][2][1].szName, Wlls.LGTASK_RANK_ADV, nRankAdvA);
				self:SetTeamPlayerAdvRank(Wlls.AdvMatchLists[nReadyId][2][1].szName, nRankAdvA);
			end
			if Wlls.AdvMatchLists[nReadyId][2][2] then
				League:SetLeagueTask(Wlls.LGTYPE, Wlls.AdvMatchLists[nReadyId][2][2].szName, Wlls.LGTASK_RANK_ADV, nRankAdvB);
				self:SetTeamPlayerAdvRank(Wlls.AdvMatchLists[nReadyId][2][2].szName, nRankAdvB);
			end
			GCExcute{"Wlls:SyncAdvMatchList", nReadyId, Wlls.AdvMatchLists[nReadyId]};
			GCExcute{"Wlls:UpdateAdvHelpNews"};
		end
	end
end

function Wlls:SyncAdvMatchUiList()
	if Wlls:GetMacthState() ~= Wlls.DEF_STATE_ADVMATCH then
		return 0;
	end
	
	for nPlayerId in pairs(Wlls.WaitMapMemList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			Wlls:SyncAdvMatchUiSingle(pPlayer, nReadyId, 1 * 3600 * 18);
		end
	end
	
	if self.GroupList[2] then
		for nReadyId, tbReadyList in pairs(self.GroupList[2]) do
			for _, tbList in pairs(tbReadyList) do
				for _, nPlayerId in pairs(tbList.tbPlayerList) do
					local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
					if pPlayer then
						Wlls:SyncAdvMatchUiSingle(pPlayer, nReadyId, 15 * 60 * 18);
					end	
				end
			end
		end
	end
end

function Wlls:SyncAdvMatchUiSingle(pPlayer, nReadyId, nUsefulTime)
	if Wlls:GetMacthState() ~= Wlls.DEF_STATE_ADVMATCH then
		nUsefulTime = 0;
	end	
	
	if Wlls:GetMacthLevelCfgType() == Wlls.MAP_LINK_TYPE_RANDOM then
		nReadyId = 1;	--每个场都一样
	end	
	
	if Wlls:GetMacthLevelCfgType() == Wlls.MAP_LINK_TYPE_SERIES then
		--自己的场情况，用原有nReadyId
		local szLeagueName	= League:GetMemberLeague(Wlls.LGTYPE, pPlayer.szName);
		if (not szLeagueName) then
			return 0;
		end
		nReadyId = League:GetMemberTask(Wlls.LGTYPE, szLeagueName, pPlayer.szName, Wlls.LGMTASK_SERIES);		
	end	
	
	if Wlls:GetMacthLevelCfgType() == Wlls.MAP_LINK_TYPE_FACTION then
		--自己的场情况，用原有nReadyId
		local szLeagueName	= League:GetMemberLeague(Wlls.LGTYPE, pPlayer.szName);
		if (not szLeagueName) then
			return 0;
		end
		nReadyId = League:GetMemberTask(Wlls.LGTYPE, szLeagueName, pPlayer.szName, Wlls.LGMTASK_FACTION);
	end
	
	if not self.AdvMatchLists[nReadyId] or not self.AdvMatchLists[nReadyId][8] or #self.AdvMatchLists[nReadyId][8] <= 0 then
		nUsefulTime = 0;
	end
	if pPlayer then
		Dialog:SyncCampaignDate(pPlayer, "LeagueMatch", self.AdvMatchLists[nReadyId], nUsefulTime);
	end
end

function Wlls:OnGivePkChoosePlayerResult(tbResult)
	local pPlayer = me;
	if (not tbResult) then
		return 0;
	end

	local szLeagueName		= League:GetMemberLeague(Wlls.LGTYPE, pPlayer.szName);
	if (not szLeagueName) then
		return 0;
	end

	local nMissionReadyId	= League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_ATTEND);
	if (not nMissionReadyId or nMissionReadyId <= 0) then
		return 0;
	end

	local nGameLevel	= League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MLEVEL);
	
	if (nGameLevel <= 0) then
		return 0;
	end
	
	if (not self.MissionList or not self.MissionList[nGameLevel]) then
		return 0;
	end
	
	
	local tbMission = self.MissionList[nGameLevel][nMissionReadyId];
	if (not tbMission or tbMission:IsOpen() == 0) then
		return 0;
	end

	tbMission:GiveChooseResult(me.szName, tbResult);
end

