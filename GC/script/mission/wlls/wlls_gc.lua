--武林联赛
--孙多良
--2008.09.11
if (not MODULE_GC_SERVER) then
	return 0;
end

--进入准备场；
function Wlls:EnterReadyMap(nPlayerId, szLeagueName, nGameLevel, nMapId, tbMapTypeParam, nCaptain)
	local tbMacthCfg = self:GetMacthTypeCfg(self:GetMacthType());
	local tbMacthLevelCfg = self:GetMacthLevelCfg(self:GetMacthType(), nGameLevel);
	local nEnterReadyId = Wlls:GetReadyMapId(tbMacthCfg, tbMacthLevelCfg, nGameLevel, nMapId, tbMapTypeParam, szLeagueName);
	if nEnterReadyId <= 0 then
		GlobalExcute{"Wlls:MapStateFull", nPlayerId};
		return 0;
	end
	if not self.GroupList[nGameLevel][nEnterReadyId][szLeagueName] then
		self.GroupList[nGameLevel][nEnterReadyId][szLeagueName] = {};
		self.GroupList[nGameLevel][nEnterReadyId].nLeagueCount = self.GroupList[nGameLevel][nEnterReadyId].nLeagueCount + 1;
	end
	if nCaptain > 0 then
		table.insert(self.GroupList[nGameLevel][nEnterReadyId][szLeagueName], 1, nPlayerId);
	else
		table.insert(self.GroupList[nGameLevel][nEnterReadyId][szLeagueName], nPlayerId);
	end
	
	--战队参赛
	if League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_ATTEND) ~= nEnterReadyId then
		League:SetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_ATTEND, nEnterReadyId);
	end
	League:SetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_ENTER, League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_ENTER) + 1);
	GlobalExcute{"Wlls:EnterReadyMap", nPlayerId, szLeagueName, nEnterReadyId, nGameLevel};
end

--开启联赛进入间歇期
function Wlls:GameState0Into1()
	if KGblTask.SCGetDbTaskInt(Wlls.GTASK_MACTH_SESSION) == 0 then
		KGblTask.SCSetDbTaskInt(Wlls.GTASK_MACTH_SESSION, 1);	
		KGblTask.SCSetDbTaskInt(Wlls.GTASK_MACTH_STATE, Wlls.DEF_STATE_REST);
	end
	GbWlls:WllsGlobalServerOpenTime();
end

--进入比赛期
function Wlls:GameState1Into2()
	if Wlls:GetMacthState() == Wlls.DEF_STATE_REST and Wlls.SEASON_TB[Wlls:GetMacthSession()] then
		-- 判断全局服务器是否要开启比赛期
		if (GLOBAL_AGENT) then
			if (GbWlls:CheckOpenState_GblServer() ~= 1) then
				return 0;
			end
		end
		KGblTask.SCSetDbTaskInt(self.GTASK_MACTH_STATE, Wlls.DEF_STATE_MATCH);
		if (GLOBAL_AGENT) then
			GbWlls:SetGblWllsState(Wlls.DEF_STATE_MATCH);
			GbWlls:ClearOld8RankInfo_GB();
		end
		Wlls:UpdateMatchTime();
		Wlls:LeagueClearSession();	--清除,不同届,不同赛制的战队数据
		DecreaseWllsHonor();--衰减荣誉排名
		Wlls:UpdateWllsHonorLadder();
		-- 更换mission
		Wlls.MissionList	= {[Wlls.MACTH_PRIM]={}, [Wlls.MACTH_ADV] ={}};
	end
end

--进入八强赛期
function Wlls:GameState2Into3()
	Wlls:LeagueRank(0);
	if Wlls:GetMacthState() == Wlls.DEF_STATE_MATCH then
		Wlls:InitGameDateGC(0);
		KGblTask.SCSetDbTaskInt(self.GTASK_MACTH_STATE, Wlls.DEF_STATE_ADVMATCH);
		Wlls:UpdateMatchTime();
		if (GLOBAL_AGENT) then
			GbWlls:SetGblWllsState(Wlls.DEF_STATE_ADVMATCH);
		end
		if Wlls:GetMacthSession() < self.MACTH_ADV_START_MISSION then
			return 0;
		end
		Wlls.MissionList	= {[Wlls.MACTH_PRIM]={}, [Wlls.MACTH_ADV] ={}};
		
		--八强赛对阵表
		local tbMacthLevelCfg = self:GetMacthLevelCfg(self:GetMacthType(), Wlls.MACTH_ADV);
		for nReadyId, nMapId in pairs(tbMacthLevelCfg.tbReadyMap) do
			Wlls.AdvMatchLists[nReadyId] = {};
			Wlls.AdvMatchLists[nReadyId][8] = {};
			Wlls.AdvMatchLists[nReadyId][4] = {};
			Wlls.AdvMatchLists[nReadyId][2] = {};
			Wlls.AdvMatchLists[nReadyId][1] = {};

			if Wlls:GetMacthLevelCfgType() == Wlls.MAP_LINK_TYPE_RANDOM then
				if nReadyId == 1 then
					local tbLadder, szName, szContext = GetShowLadder(Ladder:GetType(0, 3, 2, 0));
					if (tbLadder) then
						for nId, tbLeague in ipairs(tbLadder) do
							if nId <= 8 then
								Wlls.AdvMatchLists[nReadyId][8][nId] = {szName = tbLeague.szName, tbResult={}};
								League:SetLeagueTask(Wlls.LGTYPE, tbLeague.szName, Wlls.LGTASK_RANK_ADV, 8);
								self:SetTeamPlayerAdvRank(tbLeague.szName, 8);
								League:SetLeagueTask(Wlls.LGTYPE, tbLeague.szName, Wlls.LGTASK_ATTEND, nReadyId);
								League:SetLeagueTask(self.LGTYPE, tbLeague.szName, self.LGTASK_ADV_ID, nId);
							end
						end
					end
					Wlls:SyncAdvMatchList(nReadyId, Wlls.AdvMatchLists[nReadyId]);
				end
			end	
		
			if Wlls:GetMacthLevelCfgType() == Wlls.MAP_LINK_TYPE_SERIES then
				local tbLadder, szName, szContext = GetShowLadder(Ladder:GetType(0, 3, 2, nReadyId));
				if (tbLadder) then
					for nId, tbLeague in ipairs(tbLadder) do
						if nId <= 8 then
							Wlls.AdvMatchLists[nReadyId][8][nId] = {szName = tbLeague.szName, tbResult={}};
							League:SetLeagueTask(Wlls.LGTYPE, tbLeague.szName, Wlls.LGTASK_RANK_ADV, 8);
							self:SetTeamPlayerAdvRank(tbLeague.szName, 8);
							League:SetLeagueTask(Wlls.LGTYPE, tbLeague.szName, Wlls.LGTASK_ATTEND, nReadyId);
							League:SetLeagueTask(self.LGTYPE, tbLeague.szName, self.LGTASK_ADV_ID, nId);
						end
					end
				end
				Wlls:SyncAdvMatchList(nReadyId, Wlls.AdvMatchLists[nReadyId]);				
			end		
			
			if Wlls:GetMacthLevelCfgType() == Wlls.MAP_LINK_TYPE_FACTION then
				local tbLadder, szName, szContext = GetShowLadder(Ladder:GetType(0, 3, 2, nReadyId));
				if (tbLadder) then
					for nId, tbLeague in ipairs(tbLadder) do
						if nId <= 8 then
							Wlls.AdvMatchLists[nReadyId][8][nId] = {szName = tbLeague.szName, tbResult={}};
							League:SetLeagueTask(Wlls.LGTYPE, tbLeague.szName, Wlls.LGTASK_RANK_ADV, 8);
							self:SetTeamPlayerAdvRank(tbLeague.szName, 8);
							League:SetLeagueTask(Wlls.LGTYPE, tbLeague.szName, Wlls.LGTASK_ATTEND, nReadyId);
							League:SetLeagueTask(self.LGTYPE, tbLeague.szName, Wlls.LGTASK_ADV_ID, nId);
						end
					end
				end
				Wlls:SyncAdvMatchList(nReadyId, Wlls.AdvMatchLists[nReadyId]);
			end

		end
		if (GLOBAL_AGENT) then
			GbWlls:SendAdvGbWllsMatchMail_Gb();
			local nState	= Wlls:GetMacthState();
			local nSession	= Wlls:GetMacthSession();
			local nMapType	= Wlls:GetMacthLevelCfgType();
			Wlls:SendGbWlls_8RankInfo_Gb(nSession, nMapType, nState, 1); -- 产生八强名单
		end
		Wlls:UpdateAdvHelpNews();
	end
end

--每届结束,八强赛期进入间歇期
function Wlls:GameState3Into1()
	if Wlls:GetMacthState() == Wlls.DEF_STATE_ADVMATCH then
		--战队排名
		local nNowSession = Wlls:GetMacthSession();
		local nNowType	= Wlls:GetMacthLevelCfgType();
		
		KGblTask.SCSetDbTaskInt(Wlls.GTASK_MACTH_RANK, Wlls:GetMacthSession());
		if (GLOBAL_AGENT) then
			GbWlls:SetGblWllsRankFinish(Wlls:GetMacthSession());
			GbWlls:ProcessMoreTicketPlayer();
		end
		KGblTask.SCSetDbTaskInt(Wlls.GTASK_MACTH_LASTSESSION, Wlls:GetMacthSession());
		
		local nLastSession = Wlls:GetMacthSession();
		
		if (not GLOBAL_AGENT) then
			if (nLastSession < 2) then
				Wlls:SetMacthSession(Wlls:GetMacthSession() + 1);
			else
				local tbNowTime = os.date("*t", GetTime());
				tbNowTime.month = tbNowTime.month + 1;
				local nNextTime = os.time(tbNowTime);
				local nNextSession = tonumber(os.date("%Y%m", nNextTime));
				local nSession = self.DATE_TO_SESSION[nNextSession];
				Wlls:SetMacthSession(nSession);
			end
		else
			Wlls:SetMacthSession(Wlls:GetMacthSession() + 1);
		end
		
		KGblTask.SCSetDbTaskInt(Wlls.GTASK_MACTH_STATE, Wlls.DEF_STATE_REST);
		if (GLOBAL_AGENT) then
			GbWlls:SetGblWllsState(Wlls.DEF_STATE_REST);
		end
		Wlls:LeagueRankFinal();	--排名;
		Timer:Register(Wlls.MACTH_TIME_RANK_FINISH,  self.LeagueRankFinish,  self);
		if (not GLOBAL_AGENT) then
			GbWlls:RegOnConnectGbServer();
		end
		if (GLOBAL_AGENT) then
			GbWlls:WllsGlobalServerOpenTime();
			GbWlls:SetGblWllsSession(Wlls:GetMacthSession());
			local nNowState	= Wlls.DEF_STATE_REST;
			Timer:Register(Wlls.MACTH_TIME_RANK_FINISH, self.SendGbWlls_8RankInfo_Gb, self, nNowSession, nNowType, nNowState, 1); -- 最终结果
			self:SendGbWllsStarServer_GB();
			Wlls:WriteDetailLeagueInfo();
			GC_AllExcute({"GbWlls:ClearAllStatuary"});
		end
	end
end

function Wlls:WriteDetailLeagueInfo()
	local nLgType		= self.LGTYPE;
	local pLeagueSet 	= KLeague.GetLeagueSetObject(nLgType);
	local pLeagueItor 	= pLeagueSet.GetLeagueItor();
	local pLeague 		= pLeagueItor.GetCurLeague();
	local tbLeagueList 	= {};
	local tbWllsLeagueList = {};
	local nMemberCount		= 0;
	local nRealMemberCount	= 0;
	while(pLeague) do
		local szLeagueName = pLeague.szName;

		local tbMemberList = Wlls:GetLeagueMemberList(szLeagueName);

		local nMSession	= League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MSESSION);
		local nMType	= League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MTYPE);
		local nMLevel	= League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MLEVEL);
		local nRank		= League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_RANK);
		local nWin		= League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_WIN);
		local nTie		= League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_TIE);
		local nTotal	= League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_TOTAL);
		local nTime		= League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_TIME);
		local nRankAdv	= League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_RANK_ADV);

		for i, szName in ipairs(tbMemberList) do
			local nFaction = League:GetMemberTask(self.LGTYPE, szLeagueName, szName, self.LGMTASK_FACTION);
			Dbg:WriteLogEx(Dbg.LOG_INFO, "PlayerWllsInfo", szName, szLeagueName, nMSession, nMType, nFaction, nRank, nWin, nTie, nTotal, nTime, nRankAdv);
		end
		pLeague = pLeagueItor.NextLeague();
	end
end

function Wlls:ClearLeague()
	League:ClearLeague(Wlls.LGTYPE);
	return 0;
end

--预计排名结束，可领取奖励
function Wlls:LeagueRankFinish()
	KGblTask.SCSetDbTaskInt(Wlls.GTASK_MACTH_RANK, Wlls:GetMacthSession());
	if (GLOBAL_AGENT) then
		GbWlls:SetGblWllsRankFinish(Wlls:GetMacthSession());
	end
	return 0;
end

--每周战报
function Wlls:UpdateHelpNews(nSession, nFinalType)
	if not Wlls.RankLeagueList[Wlls.MACTH_PRIM] or not Wlls.RankLeagueList[Wlls.MACTH_ADV] then
		Wlls:LeagueRank(0, 1);
		return 0;
	end
	local tbMacthCfg = Wlls:GetMacthTypeCfg(Wlls:GetMacthType(nSession));
	local nKey		= Task.tbHelp.NEWSKEYID.NEWS_MENPAIJINGJI_NEW;
	local szTitle	= "武林联赛每周战报";
	if nFinalType == 1 then
		szTitle	= "武林联赛结束最终战报";
	end
	local nAddTime = GetTime();
	local nEndTime = nAddTime + 3600 * 24 * 7;	
	local szMsg	= "";
	local szPrimWllsName	= "<color=yellow>初级武林联赛战报<color>";
	local szAdvWllsName		= "<color=yellow>高级武林联赛战报<color>";
	if (GLOBAL_AGENT) then
		szPrimWllsName	= "<color=yellow>跨服初级武林联赛战报<color>";
		szAdvWllsName	= "<color=yellow>跨服高级武林联赛战报<color>";
		szTitle			= "跨服" .. szTitle
		if (GbWlls:CheckOpenGoldenGbWlls() == 1) then
			szPrimWllsName	= "<color=yellow>跨服高级武林联赛战报<color>";
			szAdvWllsName	= "<color=yellow>跨服黄金武林联赛战报<color>";
		end
	end

	--
	if tbMacthCfg.nMapLinkType == Wlls.MAP_LINK_TYPE_RANDOM then
		szMsg = szMsg .. Wlls:GetHelpNewsInfor(self.RankLeagueList[Wlls.MACTH_ADV], Wlls.MACTH_ADV, string.format("    %s\n\n", szAdvWllsName));
		szMsg = szMsg .. Wlls:GetHelpNewsInfor(self.RankLeagueList[Wlls.MACTH_PRIM], Wlls.MACTH_PRIM, string.format("    %s\n\n", szPrimWllsName));
	end
	
	if tbMacthCfg.nMapLinkType == Wlls.MAP_LINK_TYPE_SERIES then
		szMsg = szMsg .. Wlls:GetHelpSeriesNews(self.RankLeagueList[Wlls.MACTH_ADV], Wlls.MACTH_ADV, string.format("    %s\n\n", szAdvWllsName));
		szMsg = szMsg .. Wlls:GetHelpSeriesNews(self.RankLeagueList[Wlls.MACTH_PRIM], Wlls.MACTH_PRIM, string.format("    %s\n\n", szPrimWllsName));		
	end	
	
	if tbMacthCfg.nMapLinkType == Wlls.MAP_LINK_TYPE_FACTION then
		szMsg = szMsg .. Wlls:GetHelpFactionNews(self.RankLeagueList[Wlls.MACTH_ADV], Wlls.MACTH_ADV, string.format("    %s\n\n", szAdvWllsName));
		szMsg = szMsg .. Wlls:GetHelpFactionNews(self.RankLeagueList[Wlls.MACTH_PRIM], Wlls.MACTH_PRIM, string.format("    %s\n\n", szPrimWllsName));		
	end
	Task.tbHelp:AddDNews(nKey, szTitle, szMsg, nEndTime, nAddTime);
end

function Wlls:GetHelpFactionNews(tbLeagueList, nLevel, szTitle)
	local szMsg = "";
	if Lib:CountTB(tbLeagueList) <= 0 then
		return szMsg;
	end
	szMsg = szMsg .. szTitle;
	for nFaction, tbLeague in pairs(tbLeagueList) do
		local szLeagueName = (tbLeague[1] and tbLeague[1].szName) or "暂缺";
		szMsg = szMsg .. string.format("    <color=yellow>%s第一名<color>\n", Player:GetFactionRouteName(nFaction));
		szMsg = szMsg .. string.format("    战 队 名： <color=green>%s<color>\n", szLeagueName);
		szMsg = szMsg .. string.format("    战队成员： <color=pink>");
		
		if tbLeague[1] then
			local tbMemberList = Wlls:GetLeagueMemberList(tbLeague[1].szName);
			local tbList = {};
			for i, szName in ipairs(tbMemberList) do
				local nCaptain = League:GetMemberTask(self.LGTYPE, tbLeague[1].szName, szName, self.LGMTASK_JOB)
				--local nFaction = League:GetMemberTask(self.LGTYPE, tbLeague.szName, szName, self.LGMTASK_FACTION)
				--local nRouteId = League:GetMemberTask(self.LGTYPE, tbLeague.szName, szName, self.LGMTASK_ROUTEID);
				--local szFaction = Player:GetFactionRouteName(nFaction, nRouteId);
				if nCaptain == 1 then
					table.insert(tbList, 1, szName);
				else
					table.insert(tbList, szName);
				end
			end
			for _, szName in pairs(tbList) do
				szMsg = szMsg .. string.format("%s  ", szName);
			end
		else
			szMsg = szMsg .. string.format("暂缺");
		end
		szMsg = szMsg .. string.format("<color>\n\n");
	end
	if nLevel == Wlls.MACTH_ADV then
		szMsg = szMsg .. string.format("－－－－－－－－－－－－－－－－－－－－－－－－\n\n");
	end
	return szMsg;	
end

function Wlls:GetHelpSeriesNews(tbLeagueList, nLevel, szTitle)
	local szMsg = "";
	if not tbLeagueList then
		return szMsg;
	end
	szMsg = szMsg .. szTitle;
	for nSereis, tbLeague in pairs(tbLeagueList) do
		local szLeagueName = (tbLeague[1] and tbLeague[1].szName) or "暂缺";
		szMsg = szMsg .. string.format("    <color=yellow>%s系第一名<color>\n", string.format(Wlls.SERIES_COLOR[nSereis], Env.SERIES_NAME[nSereis]));
		szMsg = szMsg .. string.format("    战 队 名： <color=green>%s<color>\n", szLeagueName);
		szMsg = szMsg .. string.format("    战队成员： <color=pink>");
		
		if tbLeague[1] then
			local tbMemberList = Wlls:GetLeagueMemberList(tbLeague[1].szName);
			local tbList = {};
			for i, szName in ipairs(tbMemberList) do
				local nCaptain = League:GetMemberTask(self.LGTYPE, tbLeague[1].szName, szName, self.LGMTASK_JOB)
				--local nFaction = League:GetMemberTask(self.LGTYPE, tbLeague.szName, szName, self.LGMTASK_FACTION)
				--local nRouteId = League:GetMemberTask(self.LGTYPE, tbLeague.szName, szName, self.LGMTASK_ROUTEID);
				--local szFaction = Player:GetFactionRouteName(nFaction, nRouteId);
				if nCaptain == 1 then
					table.insert(tbList, 1, szName);
				else
					table.insert(tbList, szName);
				end
			end
			for _, szName in pairs(tbList) do
				szMsg = szMsg .. string.format("%s  ", szName);
			end
		else
			szMsg = szMsg .. string.format("暂缺");
		end
		szMsg = szMsg .. string.format("<color>\n\n");
	end
	if nLevel == Wlls.MACTH_ADV then
		szMsg = szMsg .. string.format("－－－－－－－－－－－－－－－－－－－－－－－－\n\n");
	end
	return szMsg;	
end

function Wlls:GetHelpNewsInfor(tbLeagueList, nLevel, szTitle)
	local szMsg = "";
	if #tbLeagueList <= 0 then
		return szMsg;
	end
	szMsg = szMsg .. szTitle;
	for nRank, tbLeague in pairs(tbLeagueList) do
		if nRank > 10 then
			break;
		end
		szMsg = szMsg .. string.format("    <color=yellow>第%s名<color>\n", Lib:Transfer4LenDigit2CnNum(nRank));
		szMsg = szMsg .. string.format("    战 队 名： <color=green>%s<color>\n", tbLeague.szName);
		szMsg = szMsg .. string.format("    战队成员： <color=pink>");
		
		local tbMemberList = Wlls:GetLeagueMemberList(tbLeague.szName);
		local tbList = {};
		for i, szName in ipairs(tbMemberList) do
			local nCaptain = League:GetMemberTask(self.LGTYPE, tbLeague.szName, szName, self.LGMTASK_JOB)
			--local nFaction = League:GetMemberTask(self.LGTYPE, tbLeague.szName, szName, self.LGMTASK_FACTION)
			--local nRouteId = League:GetMemberTask(self.LGTYPE, tbLeague.szName, szName, self.LGMTASK_ROUTEID);
			--local szFaction = Player:GetFactionRouteName(nFaction, nRouteId);
			if nCaptain == 1 then
				table.insert(tbList, 1, szName);
			else
				table.insert(tbList, szName);
			end
		end
		for _, szName in pairs(tbList) do
			szMsg = szMsg .. string.format("%s  ", szName);
		end
		szMsg = szMsg .. string.format("<color>\n\n");
	end
	if nLevel == Wlls.MACTH_ADV then
		szMsg = szMsg .. string.format("－－－－－－－－－－－－－－－－－－－－－－－－\n\n");
	end
	return szMsg;
end

--八强动态战报
function Wlls:UpdateAdvHelpNews()
	--if not Wlls.RankLeagueList[Wlls.MACTH_PRIM] or not Wlls.RankLeagueList[Wlls.MACTH_ADV] then
	--	Wlls:LeagueRank(0, 1);
	--	return 0;
	--end
	local tbMacthCfg = Wlls:GetMacthTypeCfg(Wlls:GetMacthType(nSession));
	local nKey		= Task.tbHelp.NEWSKEYID.NEWS_LEAGUE_ADV;
	local szTitle	= "武林联赛八强赛战报";
	if nFinalType == 1 then
		szTitle	= "武林联赛结束最终战报";
	end
	local nAddTime = GetTime();
	local nEndTime = nAddTime + 3600 * 24 * 1;	
	local szMsg	= "";
	
	if (GLOBAL_AGENT) then
		szTitle = "跨服" .. szTitle;
	end

	--不是门派制类型
	for nReadyId, tbList in pairs(Wlls.AdvMatchLists) do
		
		szMsg = szMsg .. Wlls:GetAdvHelpNewsInfor(tbList, tbMacthCfg.nMapLinkType, nReadyId)
		GlobalExcute{"Wlls:SyncAdvMatchList", nReadyId, tbList}; --同步给GS；
	end
	Task.tbHelp:AddDNews(nKey, szTitle, szMsg, nEndTime, nAddTime);
	
	--同步Ui界面给会场内所有玩家；
	GlobalExcute{"Wlls:SyncAdvMatchUiList"};
	
end

--获得帮助
function Wlls:GetAdvHelpNewsInfor(tbLeague, nType, nReadyId)
	local szMsg = "";
	
	if nType == self.MAP_LINK_TYPE_RANDOM then
		if Wlls.AdvMatchState == 5 and tbLeague[2][1] and #tbLeague[2][1].tbResult >= 3 then
			if tbLeague[1] and tbLeague[1][1] then
				szMsg = szMsg .. "\n\n<color=red>最终联赛冠军：".. tbLeague[1][1].szName .. "<color>\n";
			else
				szMsg = szMsg .. "\n\n<color=red>最终联赛冠军：因双方战平而无冠军，两队均为第二名<color>\n";
			end
		end
		
		if #tbLeague[2] > 0 then
			szMsg = szMsg .. "\n\n<color=yellow>决赛对阵表<color>\n\n";
			local nRank = 1;
			local nVsRank = 2;
			local szName  = "<color=gray>无参赛队伍<color>";
			local szVsName  = "<color=gray>无参赛队伍<color>";
			if tbLeague[2][nRank] then
				szName = "<color=pink>" .. tbLeague[2][nRank].szName .. "<color>";
			end
			
			if tbLeague[2][nVsRank] then
				szVsName = "<color=pink>" .. tbLeague[2][nVsRank].szName .. "<color>";
			end
				szMsg = szMsg .. Lib:StrFillR(szName, 37) .. Lib:StrFillC("对阵", 8) .. szVsName .. "\n";
		end
			
		if #tbLeague[4] > 0 then
			szMsg = szMsg .. "\n\n<color=yellow>四强赛对阵表<color>\n\n";
			for nRank=1, 2 do
				local nVsRank = nRank + 2;
				local szName  = "<color=gray>无参赛队伍<color>";
				local szVsName  = "<color=gray>无参赛队伍<color>";
				if tbLeague[4][nRank] then
					szName = "<color=pink>" .. tbLeague[4][nRank].szName .. "<color>";
				end
				
				if tbLeague[4][nVsRank] then
					szVsName = "<color=pink>" .. tbLeague[4][nVsRank].szName .. "<color>";
				end
				szMsg = szMsg .. Lib:StrFillR(szName, 37) .. Lib:StrFillC("对阵", 8) .. szVsName .. "\n";
			end
		end
				
		if #tbLeague[8] > 0 then
			szMsg = szMsg .. "\n\n<color=yellow>八强赛对阵表<color>\n\n";
			for nRank=1, 4 do
				local nVsRank = 9 - nRank;
				local szName  = "<color=gray>无参赛队伍<color>";
				local szVsName  = "<color=gray>无参赛队伍<color>";
				if tbLeague[8][nRank] then
					szName = "<color=pink>" .. tbLeague[8][nRank].szName .. "<color>";
				end
				
				if tbLeague[8][nVsRank] then
					szVsName ="<color=pink>" .. tbLeague[8][nVsRank].szName .. "<color>";
				end
				szMsg = szMsg .. Lib:StrFillR(szName, 37) .. Lib:StrFillC("对阵", 8) .. szVsName .. "\n";
			end
		end
		szMsg = szMsg .. "\n\n";
	end
	
	if nType == self.MAP_LINK_TYPE_SERIES then
		--未开发
		local szSereis = string.format(Wlls.SERIES_COLOR[nReadyId], Env.SERIES_NAME[nReadyId]);
		if Wlls.AdvMatchState == 5 and tbLeague[2][1] and #tbLeague[2][1].tbResult >= 3 then
			if tbLeague[1] and tbLeague[1][1] then
				szMsg = szMsg .. "\n\n<color=red>最终联赛冠军：".. tbLeague[1][1].szName .. "<color>\n";
			else
				szMsg = szMsg .. "\n\n<color=red>最终联赛冠军：因双方战平而无冠军，两队均为第二名<color>\n";
			end
		end
		
		if #tbLeague[2] > 0 then
			szMsg = szMsg .. "\n\n<color=yellow>" .. szSereis .. "五行赛决赛对阵表<color>\n\n";
			local nRank = 1;
			local nVsRank = 2;
			local szName  = "<color=gray>无参赛队伍<color>";
			local szVsName  = "<color=gray>无参赛队伍<color>";
			if tbLeague[2][nRank] then
				szName = "<color=pink>" .. tbLeague[2][nRank].szName .. "<color>";
			end
			
			if tbLeague[2][nVsRank] then
				szVsName = "<color=pink>" .. tbLeague[2][nVsRank].szName .. "<color>";
			end
				szMsg = szMsg .. Lib:StrFillR(szName, 37) .. Lib:StrFillC("对阵", 8) .. szVsName .. "\n";
			szMsg = szMsg .. "\n\n";
			return szMsg;
		end
			
		if #tbLeague[4] > 0 then
			szMsg = szMsg .. "\n\n<color=yellow>" .. szSereis .. "五行赛四强赛对阵表<color>\n\n";
			for nRank=1, 2 do
				local nVsRank = nRank + 2;
				local szName  = "<color=gray>无参赛队伍<color>";
				local szVsName  = "<color=gray>无参赛队伍<color>";
				if tbLeague[4][nRank] then
					szName = "<color=pink>" .. tbLeague[4][nRank].szName .. "<color>";
				end
				
				if tbLeague[4][nVsRank] then
					szVsName = "<color=pink>" .. tbLeague[4][nVsRank].szName .. "<color>";
				end
				szMsg = szMsg .. Lib:StrFillR(szName, 37) .. Lib:StrFillC("对阵", 8) .. szVsName .. "\n";
			end
			szMsg = szMsg .. "\n\n";
			return szMsg;
		end
				
		if #tbLeague[8] > 0 then
			szMsg = szMsg .. "\n\n<color=yellow>" .. szSereis .. "五行赛八强赛对阵表<color>\n\n";
			for nRank=1, 4 do
				local nVsRank = 9 - nRank;
				local szName  = "<color=gray>无参赛队伍<color>";
				local szVsName  = "<color=gray>无参赛队伍<color>";
				if tbLeague[8][nRank] then
					szName = "<color=pink>" .. tbLeague[8][nRank].szName .. "<color>";
				end
				
				if tbLeague[8][nVsRank] then
					szVsName ="<color=pink>" .. tbLeague[8][nVsRank].szName .. "<color>";
				end
				szMsg = szMsg .. Lib:StrFillR(szName, 37) .. Lib:StrFillC("对阵", 8) .. szVsName .. "\n";
			end
		end
		szMsg = szMsg .. "\n\n";
		return szMsg;
	end
	
	if nType == self.MAP_LINK_TYPE_FACTION then
		--未开发
		local szFaction = Wlls.LADDER_FACTIONNAME[nReadyId];
		if Wlls.AdvMatchState == 5 then
			if tbLeague[2][1] and #tbLeague[2][1].tbResult >= 3 then
				if tbLeague[1] and tbLeague[1][1] then
					szMsg = szMsg .. "\n\n<color=red>" .. szFaction .. "门派赛最终联赛冠军：".. tbLeague[1][1].szName .. "<color>\n";
				else
					szMsg = szMsg .. "\n\n<color=red>" .. szFaction .. "门派赛最终联赛冠军：因双方战平而无冠军，两队均为第二名<color>\n";
				end
			else
				szMsg = szMsg .. "\n\n<color=red>" .. szFaction .. "门派赛冠军暂缺<color>\n";
			end
			szMsg = szMsg .. "\n\n";
			return szMsg;
		end
		
		if #tbLeague[2] > 0 then
			szMsg = szMsg .. "\n\n<color=yellow>" .. szFaction .. "门派赛决赛对阵表<color>\n\n";
			local nRank = 1;
			local nVsRank = 2;
			local szName  = "<color=gray>无参赛队伍<color>";
			local szVsName  = "<color=gray>无参赛队伍<color>";
			if tbLeague[2][nRank] then
				szName = "<color=pink>" .. tbLeague[2][nRank].szName .. "<color>";
			end
			
			if tbLeague[2][nVsRank] then
				szVsName = "<color=pink>" .. tbLeague[2][nVsRank].szName .. "<color>";
			end
				szMsg = szMsg .. Lib:StrFillR(szName, 37) .. Lib:StrFillC("对阵", 8) .. szVsName .. "\n";
			szMsg = szMsg .. "\n\n";
			return szMsg;
		end
			
		if #tbLeague[4] > 0 then
			szMsg = szMsg .. "\n\n<color=yellow>" .. szFaction .. "门派赛四强赛对阵表<color>\n\n";
			for nRank=1, 2 do
				local nVsRank = nRank + 2;
				local szName  = "<color=gray>无参赛队伍<color>";
				local szVsName  = "<color=gray>无参赛队伍<color>";
				if tbLeague[4][nRank] then
					szName = "<color=pink>" .. tbLeague[4][nRank].szName .. "<color>";
				end
				
				if tbLeague[4][nVsRank] then
					szVsName = "<color=pink>" .. tbLeague[4][nVsRank].szName .. "<color>";
				end
				szMsg = szMsg .. Lib:StrFillR(szName, 37) .. Lib:StrFillC("对阵", 8) .. szVsName .. "\n";
			end
			szMsg = szMsg .. "\n\n";
			return szMsg;
		end
				
		if #tbLeague[8] > 0 then
			szMsg = szMsg .. "\n\n<color=yellow>" .. szFaction .. "门派赛八强赛对阵表<color>\n\n";
			for nRank=1, 4 do
				local nVsRank = 9 - nRank;
				local szName  = "<color=gray>无参赛队伍<color>";
				local szVsName  = "<color=gray>无参赛队伍<color>";
				if tbLeague[8][nRank] then
					szName = "<color=pink>" .. tbLeague[8][nRank].szName .. "<color>";
				end
				
				if tbLeague[8][nVsRank] then
					szVsName ="<color=pink>" .. tbLeague[8][nVsRank].szName .. "<color>";
				end
				szMsg = szMsg .. Lib:StrFillR(szName, 37) .. Lib:StrFillC("对阵", 8) .. szVsName .. "\n";
			end
		end
		szMsg = szMsg .. "\n\n";
		return szMsg;
	end
	
	return szMsg;
end

function Wlls:AddAffairLadder(nTongId, szName, nSession, szTitle)
	local pTong = KTong.GetTong(nTongId);
	if pTong then 
		pTong.AddHistoryLadder(szName, tostring(nSession), szTitle);
		pTong.AddAffairLadder(szName, tostring(nSession), szTitle);
	end
end

