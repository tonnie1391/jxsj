--活动平台
--zhouchenfei
--2009.08.12
--GC/GS

function EPlatForm:GetTimeFrameState()
	local nSec = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_SETMAXLEVEL150);
	if nSec <= 0 then
		return 0;
	end
	local nMonth = tonumber(os.date("%Y%m", nSec));
	local nNowMonth = tonumber(GetLocalDate("%Y%m"));
	local nNowDay	= tonumber(GetLocalDate("%d"));
	if nNowMonth <= nMonth then
		return 0;
	end
	
	-- 如果比赛从来没进行过那么第一届应该在这个月的七号之前，或者下个月的7号开启
	if KGblTask.SCGetDbTaskInt(EPlatForm.GTASK_MACTH_SESSION) <= 0 then
		if (nNowDay > EPlatForm.DATE_START_DAY[1][1]) then
			return 0;
		end
	end
	
	return 1;
end

--用时间获得比赛属于哪个时期(7,27,28)
--1：间歇期		(28 24:00 - 7  00:00)
--2：比赛期第一阶段		( 7 00:00 - 16 24:00)
--3：比赛期第二阶段 ( 16 24:00 - 26 24:00)
--4. 八强赛期	(26 24:00 - 27 24:00)
function EPlatForm:GetMatchStateForDate()
	local nDate = tonumber(os.date("%d%H%M", GetTime()));
	
	--判断间歇期
	for nId, tbState in ipairs(EPlatForm.DATE_START_DAY) do
		local nStartDate = tbState[4] * 10000 + 2400;
		local nEndDate	 = EPlatForm.DATE_START_DAY[1][1] * 10000;
		if EPlatForm.DATE_START_DAY[nId + 1] then
			nEndDate = EPlatForm.DATE_START_DAY[nId + 1][1] * 10000;
		end
		
		--跨了月处理
		if nStartDate > nEndDate then
			if nDate > nStartDate then
				return EPlatForm.DEF_STATE_REST;
			end
			if nDate < nEndDate then
				return EPlatForm.DEF_STATE_REST;
			end
		else
			if nDate > nStartDate and nDate < nEndDate then
				return EPlatForm.DEF_STATE_REST;
			end
		end
	end
	
	--判断比赛期第一阶段
	for nId, tbState in ipairs(EPlatForm.DATE_START_DAY) do
		local nStartDate = tbState[1]*10000;
		local nEndDate	 = tbState[2]*10000 + 2400;
		
		--跨了月处理
		if nStartDate > nEndDate then
			if nDate >= nStartDate then
				return EPlatForm.DEF_STATE_MATCH_1;
			end
			if nDate <= nEndDate then
				return EPlatForm.DEF_STATE_MATCH_1;
			end
		else
			if nDate >= nStartDate and nDate <= nEndDate then
				return EPlatForm.DEF_STATE_MATCH_1;
			end
		end
	end

	--判断比赛期第二阶段
	for nId, tbState in ipairs(EPlatForm.DATE_START_DAY) do
		local nStartDate = tbState[2]*10000;
		local nEndDate	 = tbState[3]*10000 + 2400;
		
		--跨了月处理
		if nStartDate > nEndDate then
			if nDate >= nStartDate then
				return EPlatForm.DEF_STATE_MATCH_2;
			end
			if nDate <= nEndDate then
				return EPlatForm.DEF_STATE_MATCH_2;
			end
		else
			if nDate >= nStartDate and nDate <= nEndDate then
				return EPlatForm.DEF_STATE_MATCH_2;
			end
		end
	end	


	--判断八强赛期
	for nId, tbState in ipairs(EPlatForm.DATE_START_DAY) do
		local nStartDate = tbState[3]*10000;
		local nEndDate	 = tbState[4]*10000 + 2400;
		
		--跨了月处理
		if nStartDate > nEndDate then
			if nDate > nStartDate then
				return EPlatForm.DEF_STATE_ADVMATCH;
			end
			if nDate < nEndDate then
				return EPlatForm.DEF_STATE_ADVMATCH;
			end
		else
			if nDate > nStartDate and nDate < nEndDate then
				return EPlatForm.DEF_STATE_ADVMATCH;
			end
		end
	end
	
	return EPlatForm.DEF_STATE_CLOSE;
end

function EPlatForm:GetMatchStartForDate(nDay)
	for _, tbDate in ipairs(EPlatForm.DATE_START_DAY) do
		if tbDate[1] == nDay then
			return 1
		end
	end
	return 0;	
end

function EPlatForm:GetMatchEndForDate(nDay)
	for _, tbDate in ipairs(EPlatForm.DATE_START_DAY) do
		if tbDate[2] == nDay then
			return 1
		end
	end
	return 0;
end

--获得赛制类型配置表
function EPlatForm:GetMacthTypeCfg(nMacthType)
	if not nMacthType or nMacthType <= 0 then
		return
	end
	return self.MacthType[self.MACTH_TYPE[nMacthType]];
end

--获得赛制类型,Int
function EPlatForm:GetMacthType(nSession)
	if not nSession then
		if not self.SEASON_TB[KGblTask.SCGetDbTaskInt(self.GTASK_MACTH_SESSION)] then
			return 0;
		end
		return self.SEASON_TB[KGblTask.SCGetDbTaskInt(self.GTASK_MACTH_SESSION)][1];
	
	else
		if not self.SEASON_TB[nSession] then
			return 0;
		end
		return self.SEASON_TB[nSession][1];
	end
	return 0;
end

--获得联赛届数
function EPlatForm:GetMacthSession()
	return KGblTask.SCGetDbTaskInt(self.GTASK_MACTH_SESSION);
end

--设置联赛届数
function EPlatForm:SetMacthSession(nSession)
	return KGblTask.SCSetDbTaskInt(self.GTASK_MACTH_SESSION, nSession);
end

--获得每个准备场最大战队数
function EPlatForm:GetPreMaxLeague()
	return self.nCurReadyMaxCount;
end

--获得比赛时期
function EPlatForm:GetMacthState()
	return KGblTask.SCGetDbTaskInt(self.GTASK_MACTH_STATE)
end

--获得玩家荣誉排名
function EPlatForm:GetRank(szName)
	local nRank = GetPlayerHonorRankByName(szName, PlayerHonor.HONOR_CLASS_EVENTPLANT_PLAYER, 0);
	return nRank;
end

--获取荣誉值
function EPlatForm:GetHonor(szName)
	local nHonor = GetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_EVENTPLANT_PLAYER, 0);
	return nHonor;
end

--设置荣誉值
function EPlatForm:SetHonor(szName, nHonor)
	SetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_EVENTPLANT_PLAYER, 0, nHonor);
	return 0;
end

--获取荣誉值
function EPlatForm:GetHonorById(nPlayerId)
	local nHonor = PlayerHonor:GetPlayerHonor(nPlayerId, PlayerHonor.HONOR_CLASS_EVENTPLANT_PLAYER, 0);
	return nHonor;
end

--设置荣誉值
function EPlatForm:SetHonorById(nPlayerId, nHonor)
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	if (not szPlayerName) then
		return;
	end
	self:AddHonor(szPlayerName, nHonor);
	return 0;
end

function EPlatForm:SetEventScore(nPlayerId, nScore, bAddMonth, bAddKin)
	self:SetHonorById(nPlayerId, nScore);
	local pPlayer = nil;
	if (MODULE_GAMESERVER) then
		pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	end

	if (bAddMonth and bAddMonth == 1) then
		local nMonth = self:GetPlayerMonthScoreById(nPlayerId);
		self:SetPlayerMonthScoreById(nPlayerId, nScore + nMonth);
		if (MODULE_GAMESERVER) then
			if (pPlayer) then
				pPlayer.Msg(string.format("你的本月活动积分增加<color=yellow>%d<color>点", nScore));
				if (nScore + nMonth) >= 28 then
					Achievement:FinishAchievement(pPlayer, 39)
				end 
			end		
		end
	end	
	
	if (bAddKin and bAddKin == 1) then
		local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
		if (not szPlayerName) then
			return;
		end
		self:SetKinEventScoreByPlayer(szPlayerName, nScore);
	end
	
end

function EPlatForm:SetKinEventScoreByPlayer(szPlayerName, nScore)
	if (not szPlayerName) then
		return 0;
	end
	local tbInfo = GetPlayerInfoForLadderGC(szPlayerName);
	if (not tbInfo) then
		return 0;
	end
	local nKinId = tbInfo.nKinId;
	
	if (nKinId <= 0) then
		return;
	end

	if (MODULE_GC_SERVER) then
		self:SetKinEventScore_GC(szPlayerName, nKinId, nScore);
	elseif (MODULE_GAMESERVER) then
		GCExcute{"EPlatForm:SetKinEventScore_GC", szPlayerName, nKinId, nScore};
	end
end

function EPlatForm:SetKinEventScore_GC(szPlayerName, nKinId, nScore)
	self:SetPlatformScore(szPlayerName, nKinId, nScore);
	if (MODULE_GC_SERVER) then
		GlobalExcute{"EPlatForm:SetKinEventScore_GS", szPlayerName, nKinId, nScore};	
	end
end

function EPlatForm:SetKinEventScore_GS(szPlayerName, nKinId, nScore)
	if (self:SetPlatformScore(szPlayerName, nKinId, nScore) == 1) then
		if (MODULE_GAMESERVER) then
			local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
			if (pPlayer) then
				pPlayer.Msg(string.format("你给家族活动积分增加%d点", nScore));
			end	
		end	
	end
end

function EPlatForm:SetPlatformScore(szPlayerName, nKinId, nScore)
	if (nKinId <= 0) then
		return 0;
	end
	
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end

	local nPlayerId =KGCPlayer.GetPlayerIdByName(szPlayerName);
	
	local nKinId, nMemberId = KKin.GetPlayerKinMember(nPlayerId);
	if (nKinId <= 0 or nMemberId <= 0) then
		return 0;
	end
	
	local pMember = pKin.GetMember(nMemberId);
	
	if (not pMember) then
		return 0;
	end
	
	local nFigure = pMember.GetFigure();
	
	if ( nFigure <= 0 or nFigure > 3 ) then
		return 0;
	end
	
	local nCurSroce = pKin.GetPlatformScore() or 0;
	pKin.SetPlatformScore(nCurSroce + nScore);
	return 1;
end

function EPlatForm:SetPlatformKinScore(nKinId, nScore)
	if (not nKinId or nKinId <= 0) then
		return;
	end
	
	local pKin = KKin.GetKin(nKinId);
	if (not pKin) then
		return;
	end
	
	pKin.SetPlatformScore(nScore);
	if (MODULE_GC_SERVER) then
		GlobalExcute{"EPlatForm:SetPlatformKinScore", nKinId, nScore};
	end
	return;
end

function EPlatForm:SetPlatformKinRank(nKinId, nRank)
	if (not nKinId or nKinId <= 0) then
		return;
	end
	
	local pKin = KKin.GetKin(nKinId);
	if (not pKin) then
		return;
	end
	
	pKin.SetPlatformKinRank(nRank);
	if (MODULE_GC_SERVER) then
		GlobalExcute{"EPlatForm:SetPlatformKinRank", nKinId, nRank};
	end
	return;
end

function EPlatForm:GetPlatformKinScore(nPlayerId)
	local nKinId = 0;
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	if (not szPlayerName) then
		return 0;
	end
	local tbInfo = GetPlayerInfoForLadderGC(szPlayerName);
	if (not tbInfo) then
		return 0;
	end
	nKinId = tbInfo.nKinId;

	if (nKinId <= 0) then
		return 0;
	end

	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end

	local nCurSroce = pKin.GetPlatformScore() or 0;
	return nCurSroce
end

function EPlatForm:GetPlayerMonthScore(szPlayerName)
	local nScore = GetEventScoreForMonth(szPlayerName);
	return nScore;
end

function EPlatForm:SetPlayerMonthScoreById(nPlayerId, nScore)
	if (not nPlayerId or not nScore) then
		return 0;
	end
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	if (not szPlayerName) then
		return 0;
	end
	self:SetPlayerMonthScore(szPlayerName, nScore);
end

function EPlatForm:GetPlayerMonthScoreById(nPlayerId)
	if (not nPlayerId) then
		return 0;
	end
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	if (not szPlayerName) then
		return 0;
	end
	return self:GetPlayerMonthScore(szPlayerName);
end

function EPlatForm:SetPlayerMonthScore(szPlayerName, nScore)
	if (not szPlayerName) then
		return;
	end
	SetEventScoreForMonth(szPlayerName, nScore);
end


--增加荣誉值
function EPlatForm:AddHonor(szName, nHonor)
	if nHonor == 0 then
		return
	end
	if MODULE_GAMESERVER then
		GCExcute{"EPlatForm:AddHonor", szName, nHonor};
		
		--公告
		local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
		if nPlayerId and nPlayerId > 0 then
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				pPlayer.Msg(string.format("恭喜您获得了<color=yellow>%s点<color>活动荣誉点", nHonor));
			end
		end
		return 0;
	end
	local nAddHonor = self:GetHonor(szName) + nHonor;
	self:SetHonor(szName, nAddHonor);	
end

--获得奖励等级段
function EPlatForm:GetAwardLevelSep_Team(nPart, nSession, nRank)
	if nRank <= 0 then
		return 0, 0;
	end
	for nLevelSep, nMaxRank in ipairs(self.AWARD_LEVEL[nSession][nPart]) do
		if nRank <= nMaxRank then
			return nLevelSep, nMaxRank;
		end
	end
	return 0, 0;
end


--获得表中元素个数.
function EPlatForm:CountTableLeng(tbTable)
	local nLeng = 0;
	if type(tbTable) == 'table' then
		for Temp in pairs(tbTable) do
			nLeng = nLeng + 1;
		end
	end
	return nLeng;
end

--增加对手
function EPlatForm:AddMacthLeague(szLeagueName, szMacthLeagueId)
	local nEmy1Id = KLib.Number2UInt(League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_EMY1));
	local nEmy2Id = KLib.Number2UInt(League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_EMY2));
	local nEmy3Id = KLib.Number2UInt(League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_EMY3));
	local nEmy4Id = KLib.Number2UInt(League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_EMY4));
	local nEmy5Id = KLib.Number2UInt(League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_EMY5));
	if nEmy4Id > 0 then
		League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_EMY5, nEmy4Id);
	end
	if nEmy3Id > 0 then
		League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_EMY4, nEmy3Id);
	end
	if nEmy2Id > 0 then
		League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_EMY3, nEmy2Id);
	end
	if nEmy1Id > 0 then
		League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_EMY2, nEmy1Id);
	end
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_EMY1, szMacthLeagueId);
end

--进入准备场
function EPlatForm:AddGroupMember(nReadyId, szLeagueName, nPlayerId, szPlayerName)
	if not self.GroupList[nReadyId] then
		self.GroupList[nReadyId] = {};
	end
	
	if not self.GroupList[nReadyId][szLeagueName] then
		self.GroupList[nReadyId][szLeagueName] = {};
		self.GroupList[nReadyId][szLeagueName].tbPlayerList = {};
		
		if (EPlatForm:GetMacthState() == EPlatForm.DEF_STATE_MATCH_1) then
			---------
		else
			--战绩统计,胜率
			local nWin = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_WIN);
			local nTie = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_TIE);
			local nTotal   = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_TOTAL);
			local nRankAdv = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_RANK_ADV);
			local nRank    = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_RANK);
			local nWinRate =  EPlatForm.MACTH_NEW_WINRATE * 100;
			if nTotal > 0 then
				nWinRate = math.floor((nWin * 10000) / nTotal);
			end
			self.GroupList[nReadyId][szLeagueName].nWinRate = nWinRate;
			self.GroupList[nReadyId][szLeagueName].nRank 	= nRank;
			self.GroupList[nReadyId][szLeagueName].nRankAdv = nRankAdv;
			--战队ID和战队对战历史记录
			self.GroupList[nReadyId][szLeagueName].nNameId = tonumber(KLib.String2Id(szLeagueName));
			local nEmy1Id = KLib.Number2UInt(League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_EMY1));
			local nEmy2Id = KLib.Number2UInt(League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_EMY2));
			local nEmy3Id = KLib.Number2UInt(League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_EMY3));
			local nEmy4Id = KLib.Number2UInt(League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_EMY4));
			local nEmy5Id = KLib.Number2UInt(League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_EMY5));
			self.GroupList[nReadyId][szLeagueName].tbHistory = {};
			if nEmy1Id > 0 then
				self.GroupList[nReadyId][szLeagueName].tbHistory[nEmy1Id] = 1;
			end
			if nEmy2Id > 0 then
				self.GroupList[nReadyId][szLeagueName].tbHistory[nEmy2Id] = 1;
			end
			if nEmy3Id > 0 then
				self.GroupList[nReadyId][szLeagueName].tbHistory[nEmy3Id] = 1;
			end
			if nEmy4Id > 0 then
				self.GroupList[nReadyId][szLeagueName].tbHistory[nEmy4Id] = 1;
			end
			if nEmy5Id > 0 then
				self.GroupList[nReadyId][szLeagueName].tbHistory[nEmy5Id] = 1;
			end
		end
		
	end
	table.insert(self.GroupList[nReadyId][szLeagueName].tbPlayerList, nPlayerId);
end

--退出准备场
function EPlatForm:DelGroupMember(nReadyId, szLeagueName, nPlayerId)
	if not self.GroupList[nReadyId] or not  self.GroupList[nReadyId][szLeagueName] then
		return
	end
	local tbTemp = {};
	if (MODULE_GC_SERVER) then
		tbTemp = self.GroupList[nReadyId][szLeagueName]
		if (EPlatForm:GetMacthState() ~= EPlatForm.DEF_STATE_MATCH_1) then
			local nCount = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_ENTER);
			if nCount > 0 then
				League:SetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_ENTER, nCount - 1);
			end
		end
	else
		tbTemp = self.GroupList[nReadyId][szLeagueName].tbPlayerList
	end
	for ni, nId in pairs(tbTemp) do
		if nId == nPlayerId then
			table.remove(tbTemp, ni);
			break;
		end
	end
	if EPlatForm:CountTableLeng(tbTemp) <= 0 then
		self.GroupList[nReadyId][szLeagueName] = nil
		if (MODULE_GC_SERVER) then
			KGblTask.SCSetDbTaskInt(self.GTASK_MACTH_MAP_STATE, 0);
			self.GroupList[nReadyId].nLeagueCount = self.GroupList[nReadyId].nLeagueCount - 1;
			League:SetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_ENTER, 0);
		end
	end
	if (not MODULE_GC_SERVER) then
		GCExcute{"EPlatForm:DelGroupMember", nReadyId, szLeagueName, nPlayerId}
	end
end

function EPlatForm:SyncAdvMatchList(nReadyId, tbList)
	EPlatForm.AdvMatchLists[nReadyId] = EPlatForm.AdvMatchLists[nReadyId] or {};
	EPlatForm.AdvMatchLists[nReadyId] = tbList;
end

function EPlatForm:GetAdvMatchLeagueList(nReadyId)
	if not self.AdvMatchLists or not self.AdvMatchLists[nReadyId] then
		return {};
	end
	local nState = EPlatForm.MACTH_STATE_ADV_TASK[EPlatForm.AdvMatchState];
	if not nState or not self.AdvMatchLists[nReadyId][nState] then
		return {};
	end
	return self.AdvMatchLists[nReadyId][nState];
end

function EPlatForm:UpdateMatchTime()
	local nState		= EPlatForm:GetMacthState();
	local nRankSession	= EPlatForm:GetMacthSession();
	local tbMCfg		= EPlatForm:GetMacthTypeCfg(EPlatForm:GetMacthType(nRankSession));
	if (not tbMCfg) then
		return;
	end
	local tbCfg			= tbMCfg.tbMacthCfg;
	local nReadyTime	= 0;
	local nRankTime		= 0;
	local nPkTime		= 0;
	
	
	if (self.DEF_STATE_MATCH_1 == nState) then
		if (not tbCfg.nReadyTime_Common or tbCfg.nReadyTime_Common <= 0 or not tbCfg.nPKTime_Common or tbCfg.nPKTime_Common <= 0 ) then
			return;
		end
		nReadyTime	= Env.GAME_FPS * tbCfg.nReadyTime_Common;		--准备场准备时间;
		nRankTime 	= Env.GAME_FPS * (tbCfg.nPKTime_Common + 10);		--准备时间结束进入比赛后多少时间更新排行;
		nPkTime		= Env.GAME_FPS * tbCfg.nPKTime_Common;
		self.nCurReadyMaxCount	= tbMCfg.tbMacthCfg.nWeleeReadyMaxTeam;
		self.MACTH_ATTEND_MAX = tbCfg.nPlayCount_Player;
		self.nCurMatchMaxTeamCount	= tbMCfg.tbMacthCfg.nMeleeMaxCount;
		self.nCurMatchMinTeamCount	= tbMCfg.tbMacthCfg.nMeleeMinCount;
	elseif (self.DEF_STATE_MATCH_2 == nState) then
		if (not tbCfg.nReadyTime_Sec or tbCfg.nReadyTime_Sec <= 0 or not tbCfg.nPKTime_Sec or tbCfg.nPKTime_Sec <= 0) then
			return;
		end
		nReadyTime 	= Env.GAME_FPS * tbCfg.nReadyTime_Sec;		--准备场准备时间;
		nRankTime 	= Env.GAME_FPS * (tbCfg.nPKTime_Sec + 10);		--准备时间结束进入比赛后多少时间更新排行;
		nPkTime 	= Env.GAME_FPS * tbCfg.nPKTime_Sec;
		self.MACTH_ATTEND_MAX = tbCfg.nPlayCount_Team;
		self.nCurReadyMaxCount		= tbMCfg.tbMacthCfg.nSecReadyMaxTeam;
		self.nCurMatchMaxTeamCount	= 2;
		EPlatForm.MACTH_POINT_WIN 	= tbMCfg.tbMacthCfg.nTeamWinScore;		--胜利获得积分
		EPlatForm.MACTH_POINT_TIE 	= tbMCfg.tbMacthCfg.nTeamTieScore;		--平获得积分
		EPlatForm.MACTH_POINT_LOSS 	= tbMCfg.tbMacthCfg.nTeamLoseScore;		--输掉比赛获得积分		
	elseif (self.DEF_STATE_ADVMATCH == nState) then
		if (not tbCfg.nReadyTime_Adv or tbCfg.nReadyTime_Adv <= 0 or not tbCfg.nPKTime_Adv or tbCfg.nPKTime_Adv <= 0) then
			return;
		end
		nReadyTime 	= Env.GAME_FPS * tbCfg.nReadyTime_Adv;		--准备场准备时间;
		nRankTime 	= Env.GAME_FPS * (tbCfg.nPKTime_Adv + 10);		--准备时间结束进入比赛后多少时间更新排行;
		nPkTime 	= Env.GAME_FPS * tbCfg.nPKTime_Adv;
		self.nCurReadyMaxCount		= 10;
		self.nCurMatchMaxTeamCount = 2;
	end
	
	self.tbEventTime = {nReadyTime, nPkTime, nRankTime};

	local tbWeekend = self.CALEMDAR.tbWeekend;
	local tbCommon = self.CALEMDAR.tbCommon;
	local tbAdvMatch = self.CALEMDAR.tbAdvMatch;
	
	local tbCfg			= tbMCfg.tbMacthCfg;

	if (tbCfg and tbCfg.tbWeekend and #tbCfg.tbWeekend > 0) then
		self.CALEMDAR.tbWeekend = tbCfg.tbWeekend;
	end

	if (tbCfg and tbCfg.tbCommon and #tbCfg.tbCommon > 0) then
		self.CALEMDAR.tbCommon = tbCfg.tbCommon;
	end

	if (tbCfg and tbCfg.tbWeekend_Adv and #tbCfg.tbWeekend_Adv > 0) then
		self.CALEMDAR.tbWeekend_Adv = tbCfg.tbWeekend_Adv;
	end

	if (tbCfg and tbCfg.tbCommon_Adv and #tbCfg.tbCommon_Adv > 0) then
		self.CALEMDAR.tbCommon_Adv = tbCfg.tbCommon_Adv;
	end
	
	if (tbCfg and tbCfg.tbAdvMatch and #tbCfg.tbAdvMatch > 0) then
		self.CALEMDAR.tbAdvMatch = tbCfg.tbAdvMatch;
	end

	if (MODULE_GC_SERVER) then
		GlobalExcute{"EPlatForm:UpdateMatchTime"};
	end
end

function EPlatForm:GetPlayerReadyId(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	local nReadyId	= 0;
	nReadyId	= pPlayer.GetTask(EPlatForm.TASKID_GROUP, EPlatForm.TASKID_ENTER_READY);
	return nReadyId;
end

function EPlatForm:GetPlayerDynId(pPlayer)
	if (not pPlayer) then
		return 0;
	end

	local nDynId	= 0;
	nDynId		= pPlayer.GetTask(EPlatForm.TASKID_GROUP, EPlatForm.TASKID_ENTER_DYN);
	return nDynId;
end


function EPlatForm:SetPlayerReadyId(pPlayer, nReadyId)
	if (pPlayer and nReadyId) then
		pPlayer.SetTask(EPlatForm.TASKID_GROUP, EPlatForm.TASKID_ENTER_READY, nReadyId);
	end	
end

function EPlatForm:SetPlayerDynId(pPlayer, nDynId)
	if (pPlayer and nDynId) then
		pPlayer.SetTask(EPlatForm.TASKID_GROUP, EPlatForm.TASKID_ENTER_DYN, nDynId);
	end
end

-- 设置个人参加活动次数
function EPlatForm:SetPlayerEventCount(pPlayer, nCount)
	if (not pPlayer) then
		return;
	end
	pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_DALIYEVENTCOUNT, nCount);
end

function EPlatForm:AddPlayerTotalCount(pPlayer, nCount)
	if (not pPlayer or not nCount or nCount <= 0) then
		return 0;
	end
	
	local nLastCount = self:GetPlayerTotalCount(pPlayer);
	self:SetPlayerTotalCount(pPlayer, nLastCount + nCount);
end

function EPlatForm:SetPlayerTotalCount(pPlayer, nCount)
	if (not pPlayer or not nCount) then
		return 0;
	end
	pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_MATCH_TOTLE_MATCH1, nCount);
end

function EPlatForm:GetPlayerTotalCount(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	return pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_TOTLE_MATCH1);
end


-- 获取个人参加活动次数
function EPlatForm:GetPlayerEventCount(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	return pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_DALIYEVENTCOUNT);
end

function EPlatForm:GetEventCount(pPlayer)
	if (not pPlayer) then
		return 0;
	end

	local nState		= EPlatForm:GetMacthState();
	
	if (nState == self.DEF_STATE_MATCH_1) then
		return self:GetPlayerEventCount(pPlayer);
	elseif (nState == self.DEF_STATE_MATCH_2 or nState == self.DEF_STATE_ADVMATCH) then
		return self:GetTeamEventCountByPlayer(pPlayer.szName);
	end
	
	return 0;
end


-- 设置组队参加活动次数
function EPlatForm:SetTeamEventCount(szLeagueName, nCount)
	if (not szLeagueName) then
		return;
	end
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_DALIYCOUNT, nCount, 1);	
	if (MODULE_GC_SERVER) then
		GlobalExcute{"EPlatForm:SetTeamEventCount", szLeagueName, nCount};
	end
end

function EPlatForm:GetPlayerCountChangeTime(pPlayer)
	return pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_COUNTCHANGETIME);
end

function EPlatForm:SetPlayerCountChangeTime(pPlayer, nTime)
	return pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_COUNTCHANGETIME, nTime);
end

function EPlatForm:GetTeamEventCountByPlayer(szPlayerName)
	if (not szPlayerName) then
		return 0;
	end
	local szLeagueName = League:GetMemberLeague(self.LGTYPE, szPlayerName);
	if (not szLeagueName) then
		return 0;
	end
	return self:GetTeamEventCount(szLeagueName);
end

function EPlatForm:SetTeamEventCountByPlayer(szPlayerName, nCount)
	if (not szPlayerName or not nCount) then
		return 0;
	end
	local szLeagueName = League:GetMemberLeague(self.LGTYPE, szPlayerName);
	if (not szLeagueName) then
		return 0;
	end
	local nNowCount = self:GetTeamEventCount(szLeagueName) + nCount;
	if (MODULE_GAMESERVER) then
		GCExcute{"EPlatForm:SetTeamEventCount", szLeagueName, nNowCount};
	elseif (MODULE_GC_SERVER) then
		self:SetTeamEventCount(szLeagueName, nNowCount);
	end
end

-- 获取组队参加活动次数
function EPlatForm:GetTeamEventCount(szLeagueName)
	if (not szLeagueName) then
		return 0;
	end
	return League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_DALIYCOUNT) or 0;
end

-- 设置组队更新活动次数的时间
function EPlatForm:SetTeamEventChangeTime(szLeagueName, nTime)
	if (not szLeagueName) then
		return;
	end
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_DALIYCHANGETIME, nTime, 1);
	if (MODULE_GC_SERVER) then
		GlobalExcute{"EPlatForm:SetTeamEventChangeTime", szLeagueName, nTime};
	end
	
end

-- 获取组队更新活动次数的时间
function EPlatForm:GetTeamEventChangeTime(szLeagueName)
	if (not szLeagueName) then
		return 0;
	end
	return League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_DALIYCHANGETIME) or 0;
end

function EPlatForm:UpdateEventCount(pPlayer)
	local nState	= self:GetMacthState();
	local nSession	= EPlatForm:GetMacthSession();
	if (nState == self.DEF_STATE_MATCH_1) then
		return self:UpdatePlayerDailyEventCount(pPlayer);
	elseif (nState == self.DEF_STATE_MATCH_2) then
		local szLName = League:GetMemberLeague(EPlatForm.LGTYPE, pPlayer.szName);
		if (szLName) then
			if(League:GetLeagueTask(EPlatForm.LGTYPE, szLName, EPlatForm.LGTASK_MTYPE) <= 0) then
				return 0;
			end
			return self:UpdateTeamDailyEventCount(szLName);
		end		
	end
	return 0;
end

function EPlatForm:_Bug_Count_Repair(pPlayer)
	local nNowTime = tonumber(os.date("%Y%m", GetTime()));
	if (nNowTime > 0 and nNowTime ~= 200911) then
		return 0;
	end
	if (not pPlayer) then
		return 0;
	end
	
	local nLastTotal = self:GetPlayerTotalCount(pPlayer);
	if (nLastTotal > 0) then
		return 0;
	end
	local nNowMonthScore = self:GetPlayerMonthScore(pPlayer.szName);
	if (nNowMonthScore <= 0) then
		return 0;
	end
	local nTotalCount = math.ceil(nNowMonthScore / 8);
	-- 如果本月有积分且没有总场数，说明有问题，那么就加上这个
	self:SetPlayerTotalCount(pPlayer, nTotalCount);
	local nOrgCount = self:GetPlayerEventCount(pPlayer);
	local nNowCount = nOrgCount + 2;
	if (nNowCount > self.MACTH_MAX_JOINCOUNT) then
		nNowCount = self.MACTH_MAX_JOINCOUNT;
	end
	self:SetPlayerEventCount(pPlayer, nNowCount);
end

function EPlatForm:UpdatePlayerDailyEventCount(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	
	local nLastChangeTime	= self:GetPlayerCountChangeTime(pPlayer);
	local nLastDay			= Lib:GetLocalDay(nLastChangeTime);
	local tbLastTime		= os.date("*t", nLastChangeTime);
	local nSession, nStage	= self:GetPlayerSession(pPlayer);
	local nState			= EPlatForm:GetMacthState();
	local nRankSession		= EPlatForm:GetMacthSession();

	if (nRankSession <= 0) then
		return 0;
	end

	local nNowTime	= GetTime();
	local nNowDay = Lib:GetLocalDay(nNowTime);
	local tbNowTime	= os.date("*t", nNowTime);
	local nStartDay = 0;
		
	if (nNowTime <= nLastChangeTime) then
		return 0;
	end
	
	if (nRankSession <= 0) then
		return 0;
	end
	
	if (nRankSession > 0 and nState ~= self.DEF_STATE_MATCH_1) then
		local nCount = self:GetPlayerEventCount(pPlayer);
		if (nCount > 0) then
			self:SetPlayerEventCount(pPlayer, 0);
			self:SetPlayerCountChangeTime(pPlayer, nNowTime);
			if (nRankSession ~= nSession) then
				self:SetPlayerSession(pPlayer, nRankSession);
			end
			if (nState ~= nStage) then
				self:SetPlayerSessionStage(pPlayer, nState);
			end
		end
		return 0;
	end

	local tbMCfg		= EPlatForm:GetMacthTypeCfg(EPlatForm:GetMacthType(nRankSession));
	if (not tbMCfg) then
		return;
	end
	local tbCfg			= tbMCfg.tbMacthCfg;	

	local nOrgCount = self:GetPlayerEventCount(pPlayer);
	if (nLastDay >= nNowDay) then
		return nOrgCount;
	end
	
	local nAddCount = tbCfg.nPlayCount_Player;
	local nDet	= 0;
	
	local nStartDay	= self.DATE_START_DAY[1][1] - 1;
	local nEndDay	= self.DATE_START_DAY[1][2];
	if (tbLastTime.month == tbNowTime.month) then		
		if (nStartDay < tbLastTime.day) then
			nStartDay = tbLastTime.day;
		end
	end
	
	if (nEndDay > tbNowTime.day) then
		nEndDay = tbNowTime.day;
	end
	
	if (nStartDay <= nEndDay) then
		nDet = nEndDay - nStartDay;
	end
	
	self:_Bug_Count_Repair(pPlayer);
	
	if (nRankSession ~= nSession) then
		self:SetPlayerTotalCount(pPlayer, 0);
		self:SetPlayerSession(pPlayer, nRankSession);
		nOrgCount = 0;
	end
	
	if (nState ~= nStage) then
		self:SetPlayerSessionStage(pPlayer, nState);
		nOrgCount = 0;
	end	
	
	local nNowCount = nOrgCount + nAddCount * nDet;
	if (nNowCount > self.MACTH_MAX_JOINCOUNT) then
		nNowCount = self.MACTH_MAX_JOINCOUNT;
	end

	self:SetPlayerEventCount(pPlayer, nNowCount);
	self:SetPlayerCountChangeTime(pPlayer, nNowTime);	
	return nNowCount;
end

function EPlatForm:UpdateTeamDailyEventCount(szLeagueName)
	if (not szLeagueName) then
		return 0;
	end
	
	local nLastChangeTime	= self:GetTeamEventChangeTime(szLeagueName);
	local nLastDay			= Lib:GetLocalDay(nLastChangeTime);
	local nSession, nStage	= self:GetPlayerSession(pPlayer);
	local nState			= EPlatForm:GetMacthState();
	local nRankSession		= EPlatForm:GetMacthSession();
	if (nRankSession <= 0) then
		return 0;
	end

	local nNowTime	= GetTime();
	local nNowDay = Lib:GetLocalDay(nNowTime);

	if (nRankSession > 0 and nState ~= self.DEF_STATE_MATCH_2) then
		return 0;
	end

	local tbMCfg		= EPlatForm:GetMacthTypeCfg(EPlatForm:GetMacthType(nRankSession));
	if (not tbMCfg) then
		return;
	end
	local tbCfg			= tbMCfg.tbMacthCfg;	
	local nRemainCount = self:GetTeamEventCount(szLeagueName);

	if (nLastDay >= nNowDay) then
		return nRemainCount;
	end
	
	local nDet = nNowDay - nLastDay;
	local nNowCount = tbCfg.nPlayCount_Player * nDet + nRemainCount;
	
	if (self.DEF_MAX_REMAINCOUNT < nNowCount) then
		nNowCount = self.DEF_MAX_REMAINCOUNT;
	end
	
--	self:SetTeamEventCount_GS(szLeagueName, nNowCount);
	if (MODULE_GAMESERVER) then
		GCExcute{"EPlatForm:SetTeamCountAndChangeTime", szLeagueName, nNowCount, nNowTime};
	end

	return nNowCount;
end

function EPlatForm:SetTeamCountAndChangeTime(szLeagueName, nCount, nNowTime)
	local nLastTime = self:GetTeamEventChangeTime(szLeagueName);
	local nLastDay	= Lib:GetLocalDay(nLastTime);
	local nNowDay 	= Lib:GetLocalDay(nNowTime);
	
	-- 如果是在同一天的，那么就不增加次数了，防止出现因为同步问题而导致的多加
	if (nLastDay >= nNowDay) then
		return 0;
	end
	
	self:SetTeamEventChangeTime(szLeagueName, nNowTime);
	self:SetTeamEventCount_GC(szLeagueName, nCount);
end

function EPlatForm:SetTeamEventCount_GC(szLeagueName, nCount)
	if (not MODULE_GC_SERVER) then
		return 0;
	end
	if (not szLeagueName) then
		return;
	end
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_DALIYCOUNT, nCount, 1);	
	GlobalExcute{"EPlatForm:SetTeamEventCount_GS", szLeagueName, nCount};
end

function EPlatForm:SetTeamEventCount_GS(szLeagueName, nCount)
	if (not szLeagueName) then
		return;
	end
	League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_DALIYCOUNT, nCount, 1);	
end

function EPlatForm:GetPlayerSession(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	local nSessionFlag = pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_SESSIONFLAG);
	local nSession	= KLib.GetByte(nSessionFlag, 2);
	local nStage	= KLib.GetByte(nSessionFlag, 1);
	return nSession, nStage;
end

function EPlatForm:SetPlayerSession(pPlayer, nSession)
	if (not pPlayer or not nSession) then
		return;
	end
	local nSessionFlag = pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_SESSIONFLAG);
	nSessionFlag = KLib.SetByte(nSessionFlag, 2, nSession);
	pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_SESSIONFLAG, nSessionFlag);
end

function EPlatForm:SetPlayerSessionStage(pPlayer, nStage)
	if (not pPlayer or not nStage) then
		return;
	end
	local nSessionFlag = pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_SESSIONFLAG);
	nSessionFlag = KLib.SetByte(nSessionFlag, 1, nStage);
	pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_SESSIONFLAG, nSessionFlag);	
end

function EPlatForm:ChangeTeamMemeber(szCapName, tbChangeMember)
	if (not szCapName or not tbChangeMember or #tbChangeMember < 2) then
		self:WriteLog("[ChangeTeamMemeber] not szCapName or not tbChangeMember or #tbChangeMember < 2");
		return 0;
	end
	
	local szMemberNameA = tbChangeMember[1].szName;
	local szMemberNameB	= tbChangeMember[2].szName;
	
	if (not szMemberNameA or not szMemberNameB) then
		self:WriteLog("[ChangeTeamMemeber] not szMemberNameA or not szMemberNameB");
		return 0;
	end
	local szLeagueNameA = League:GetMemberLeague(self.LGTYPE, szMemberNameA);
	if not szLeagueNameA then
		self:WriteLog("[ChangeTeamMemeber] There is no League ", szMemberNameA);
		self:SendChangeMsg(szCapName, string.format("%s没有战队", szMemberNameA));
		return 0;
	end
	
	if (szLeagueNameA ~= tbChangeMember[1].szLeagueName) then
		self:WriteLog("[ChangeTeamMemeber] is not the same league szLeagueNameA ", szLeagueNameA, tbChangeMember[1].szLeagueName);
		return 0;
	end
	
	local nSession = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueNameA, EPlatForm.LGTASK_MTYPE);
	if (nSession > 0) then
		self:WriteLog("[ChangeTeamMemeber] Already Team ", szMemberNameA);
		self:SendChangeMsg(szCapName, string.format("%s所在战队已经确认过了", szMemberNameA));
		return 0;
	end

	local szLeagueNameB = League:GetMemberLeague(self.LGTYPE, szMemberNameB);
	if not szLeagueNameB then
		self:WriteLog("[ChangeTeamMemeber] There is no League ", szMemberNameB);
		self:SendChangeMsg(szCapName, string.format("%s没有战队", szLeagueNameB));
		return 0;
	end

	if (szLeagueNameB ~= tbChangeMember[2].szLeagueName) then
		self:WriteLog("[ChangeTeamMemeber] is not the same league szLeagueNameB ", szLeagueNameB, tbChangeMember[2].szLeagueName);
		return 0;
	end

	nSession = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueNameB, EPlatForm.LGTASK_MTYPE);
	if (nSession > 0) then
		self:WriteLog("[ChangeTeamMemeber] Already Team ", szMemberNameB);
		self:SendChangeMsg(szCapName, string.format("%s所在战队已经确认过了", szMemberNameB));
		return 0;
	end

	self:DelMember(szLeagueNameA,szMemberNameA);
	self:WriteLog("[ChangeTeamMemeber] Leave team membernameA, LeagueNameA = ", szMemberNameA, szLeagueNameA);
	local szNowLeagueNameA = League:GetMemberLeague(self.LGTYPE, szMemberNameA);	
	if (szNowLeagueNameA and szNowLeagueNameA == szLeagueNameA) then
		self:WriteLog("[ChangeTeamMemeber] DelMember failed ", szMemberNameA);
		self:SendChangeMsg(szCapName, string.format("%s离队失败", szMemberNameA));
		return 0;
	end

	self:DelMember(szLeagueNameB,szMemberNameB);
	self:WriteLog("[ChangeTeamMemeber] Leave team membernameB, LeagueNameB = ", szMemberNameB, szLeagueNameB);
	local szNowLeagueNameB = League:GetMemberLeague(self.LGTYPE, szMemberNameB);	
	if (szNowLeagueNameB and szNowLeagueNameB == szLeagueNameB) then
		self:WriteLog("[ChangeTeamMemeber] DelMember failed ", szMemberNameB);
		self:SendChangeMsg(szCapName, string.format("%s离队失败", szMemberNameB));
		return 0;
	end

	if (0 == self:AddNewTeamMember(szLeagueNameB, tbChangeMember[1])) then
		self:WriteLog("[ChangeTeamMemeber] AddNewTeamMember failed ", szLeagueNameB, tbChangeMember[1].szName);
		self:SendChangeMsg(szCapName, string.format("%s加入队伍%s失败", szLeagueNameB, tbChangeMember[1].szName));
		return 0;
	end
	if (0 == self:AddNewTeamMember(szLeagueNameA, tbChangeMember[2])) then
		self:WriteLog("[ChangeTeamMemeber] AddNewTeamMember failed ", szLeagueNameA, tbChangeMember[2].szName);
		self:SendChangeMsg(szCapName, string.format("%s加入队伍%s失败", szLeagueNameA, tbChangeMember[2].szName));
		return 0;
	end
	
	local szMyMsg = string.format("<color=yellow>%s<color>战队队员<color=yellow>%s<color>和<color=yellow>%s<color>战队队员<color=yellow>%s<color>更换成功", szLeagueNameA, tbChangeMember[1].szName, szLeagueNameB, tbChangeMember[2].szName);	
	self:SendChangeMsg(tbChangeMember[1].szName, string.format("你现在是%s战队的成员了", szLeagueNameB));
	self:SendMsgToTeamMember(tbChangeMember[1].szName, string.format("%s，%s是%s战队的成员", szMyMsg, tbChangeMember[1].szName, szLeagueNameB), szLeagueNameB);
	self:SendChangeMsg(tbChangeMember[2].szName, string.format("你现在是%s战队的成员了", szLeagueNameA));
	self:SendMsgToTeamMember(tbChangeMember[2].szName, string.format("%s，%s是%s战队的成员", szMyMsg, tbChangeMember[2].szName, szLeagueNameA), szLeagueNameA);
	self:WriteLog("[ChangeTeamMemeber] ChangeTeamMember sucess szLeagueNameA, szPlayerB, szLeagueNameB, szPlayerA", szLeagueNameA, tbChangeMember[2].szName, szLeagueNameB, tbChangeMember[1].szName);
	
	return 1;	
end

function EPlatForm:SendMsgToTeamMember(szPlayerName, szMsg, szLeagueName)
	if (MODULE_GC_SERVER) then
		GlobalExcute{"EPlatForm:SendMsgToTeamMember", szPlayerName, szMsg, szLeagueName};
		return 0;
	end
	
	if (not MODULE_GAMESERVER) then
		return 0;
	end	

	if (not szPlayerName or not szMsg or not szLeagueName) then
		return 0;
	end
	local tbTeamList = League:GetMemberList(EPlatForm.LGTYPE, szLeagueName);
	if (not tbTeamList) then
		return 0;
	end
	
	for _, szName in pairs(tbTeamList) do
		local pPlayer = KPlayer.GetPlayerByName(szName);
		if (pPlayer and pPlayer.szName ~= szPlayerName) then
			pPlayer.Msg(szMsg);
		end		
	end
	return 1;
end

function EPlatForm:SendChangeMsg(szName, szMsg)
	if (MODULE_GC_SERVER) then
		GlobalExcute{"EPlatForm:SendChangeMsg", szName, szMsg};
		return 0;
	end
	
	if (not MODULE_GAMESERVER) then
		return 0;
	end
	
	if (not szName) then
		return 0;
	end
	
	local pPlayer = KPlayer.GetPlayerByName(szName);
	if (pPlayer) then
		pPlayer.Msg(szMsg);
	end	

	return 1;
end

function EPlatForm:AddNewTeamMember(szLeagueName, tbPlayerInfo)
	local tbPlayerList = {};
	if (not szLeagueName or not tbPlayerInfo) then
		return 0;
	end
	tbPlayerList[#tbPlayerList + 1] = tbPlayerInfo;
	if (MODULE_GAMESERVER) then
		GCExcute{"EPlatForm:JoinLeague", szLeagueName, tbPlayerList};
	elseif (MODULE_GC_SERVER) then
		self:JoinLeague(szLeagueName, tbPlayerList);	
	end
	self:WriteLog("EPlatForm:AddNewTeamMember is successed, szLeagueName, szMemberName :  ", szLeagueName, tbPlayerInfo.szName);
	return 1;
end

function EPlatForm:CheckEnterCount(pPlayer, tbJoinItem)
	if (not tbJoinItem or not pPlayer) then
		return -1;
	end
	local nCount = 0;
	for _, tbItemInfo in pairs(tbJoinItem) do
		if (tbItemInfo.tbItem and #tbItemInfo.tbItem > 0) then
			nCount = nCount + pPlayer.GetItemCountInBags(unpack(tbItemInfo.tbItem));
		end
	end
	
	return nCount;
end

-- 1表示通过，0表示未通过
function EPlatForm:ProcessItemCheckFun(pPlayer, tbJoinItem)
	if (not pPlayer or not tbJoinItem) then
		return 0, "没有竞技活动所需要的物品";
	end
	
	local tbItemList = {};
	local tbItemListInfo = {};
	for _, tbItemInfo in pairs(tbJoinItem) do
		if (tbItemInfo.tbItem) then
			local tbInfo = pPlayer.FindItemInBags(unpack(tbItemInfo.tbItem));
			if (tbInfo and #tbInfo > 0) then
				tbItemList = tbInfo;
				tbItemListInfo = tbItemInfo;
				break;
			end
		end
	end
	if (not tbItemList) then
		return 0, "身上没有竞技活动所需的物品";
	end

	local pItem = nil;
	for _, tbItemInfo in pairs(tbItemList) do
		if (tbItemInfo.pItem) then
			pItem = tbItemInfo.pItem;
			break;
		end
	end
	if (not pItem) then
		return 0, "身上没有竞技活动所需的物品";
	end
	
	local szClassName = pItem.szClass;
	if (szClassName and szClassName ~= "") then
		local tbItem = Item:GetClass(szClassName);
		if (tbItem and tbItem.ItemCheckFun) then
			return tbItem:ItemCheckFun(pItem);
		end
	end

	return 1;
end

function EPlatForm:GetItemName(tbItem)
	return KItem.GetNameById(unpack(tbItem));
end

function EPlatForm:UseMatchItem(pPlayer, nDelCount, tbJoinItem, nUseLimitCount)
	if (not pPlayer or not nDelCount or nDelCount <= 0 or not tbJoinItem or not nUseLimitCount or nUseLimitCount <= 0) then
		EPlatForm:WriteLog("UseMatchItem", "[ERROR] There is not pPlayer or not nDelCount or nDelCount <= 0 or not tbItemList or not nUseLimitCount or nUseLimitCount <= 0");
		return 0;
	end
	local tbItemList = {};
	local tbItemListInfo = {};
	for _, tbItemInfo in pairs(tbJoinItem) do
		if (tbItemInfo.tbItem) then
			local tbInfo = pPlayer.FindItemInBags(unpack(tbItemInfo.tbItem));
			if (tbInfo and #tbInfo > 0) then
				tbItemList = tbInfo;
				tbItemListInfo = tbItemInfo;
				break;
			end
		end
	end
	if (not tbItemList) then
		EPlatForm:WriteLog("[ERROR] UseMatchItem", "There is no tbItemList", pPlayer.szName);
		return 0;
	end

	local pItem = nil;
	for _, tbItemInfo in pairs(tbItemList) do
		if (tbItemInfo.pItem) then
			pItem = tbItemInfo.pItem;
			break;
		end
	end
	if (not pItem) then
		EPlatForm:WriteLog("[ERROR] UseMatchItem", "There is no pItem", pPlayer.szName);
		return 0;
	end
	local nWear  = nUseLimitCount - pItem.GetGenInfo(1, 0);
	if nWear <= 1 then
		pPlayer.DelItem(pItem);
	else
		pItem.Bind(1);
		pItem.SetGenInfo(1, pItem.GetGenInfo(1, 0) + 1);
		pPlayer.Msg(string.format("减少一次%s使用次数！", pItem.szName));
		pItem.Sync();
	end
	
	if (tbItemListInfo and tbItemListInfo.tbItemSkill and #tbItemListInfo.tbItemSkill > 0) then
		pPlayer.AddSkillState(unpack(tbItemListInfo.tbItemSkill));
	end
	
	return 1;
end

function EPlatForm:WriteLog(...)
	if (MODULE_GC_SERVER) then
		Dbg:WriteLog("EPlatForm", "家族竞技活动", unpack(arg));
	end
	
	if (MODULE_GAMESERVER) then
		Dbg:WriteLogEx(Dbg.LOG_INFO, "EPlatForm", unpack(arg));	
	end		
end

function EPlatForm :IsSignUpByAward(pPlayer)
	EPlatForm:RefreshTeamAward(pPlayer);
	return self:GetAwardParam(pPlayer);
end

function EPlatForm:SetAwardParam(pPlayer, nFlag)
	if (not pPlayer) then
		return;
	end
	pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_AWARDFLAG, nFlag);
end

function EPlatForm:GetAwardParam(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	return pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_AWARDFLAG);
end

function EPlatForm:GetPlayerTotalMatch(pPlayer)
	if (not pPlayer) then
		return 0;
	end	
	return pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_TOTLE)
end

function EPlatForm:GetPlayerWinMatch(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	return pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_WIN);
end

function EPlatForm:GetPlayerLoseMatch(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	return pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_TIE)
end

function EPlatForm:GetKinNameFromLeagueName(szLeagueName)
	if (not szLeagueName) then
		return;
	end
	-- 这里今后可能要改进一下，现在我们假定战队名中有家族名
	local szRet = "";
	local szStrConcat = szLeagueName;
	local szSep = "_";
	local nSepLen = #szSep;
	local nStart = 1;
	local nAt = string.find(szStrConcat, szSep);
	while nAt do
		nStart = nAt + nSepLen;
		nAt = string.find(szStrConcat, szSep, nStart);
	end
	szRet = string.sub(szStrConcat, 1, nStart - 2);
	return szRet;
end

function EPlatForm:GetCurEventLadderType()
	return Ladder:GetType(0, Ladder.LADDER_CLASS_LADDER, Ladder.LADDER_TYPE_LADDER_EVENTPLANT, Ladder.LADDER_TYPE_LADDER_EVENTPLANT_CURTEAM);
end

function EPlatForm:GetLastEventLadderType()
	return Ladder:GetType(0, Ladder.LADDER_CLASS_LADDER, Ladder.LADDER_TYPE_LADDER_EVENTPLANT, Ladder.LADDER_TYPE_LADDER_EVENTPLANT_PRETEAM);
end

--获得奖励等级段
function EPlatForm:GetAwardLevelSep(nPart, nSession, nRank)
	if nRank <= 0 then
		return 0, 0;
	end
	for nLevelSep, nMaxRank in ipairs(self.AWARD_LEVEL[nSession][nPart]) do
		if nRank <= nMaxRank then
			return nLevelSep, nMaxRank;
		end
	end
	return 0, 0;
end

function EPlatForm:SetKinAwardFlag(szKinName, nSession, nRank)
	local pKin=KKin.FindKin(szKinName);
	if (not pKin) then
		return 0;
	end
	local nKAType = pKin.GetPlatformKinAward() or 0;	
	local nType = math.fmod(nKAType, 10000);
	local nKSession = math.floor(nKAType / 10000);

	if (nType > 0 and nRank > 0 and nRank >= nType) then
		if (nKSession >= nSession) then
			return 0;
		end
	end
	if (nRank <= 0) then
		return 0;
	end
	local nKinAwardFlag = nSession * 10000 + nRank;
	if (MODULE_GAMESERVER) then
		GCExcute{"EPlatForm:SetKinAwardParam", szKinName, nKinAwardFlag};
	elseif (MODULE_GC_SERVER) then
		self:SetKinAwardParam(szKinName, nKinAwardFlag);
	end
	
end

-- 家族成员奖励标记
function EPlatForm:SetKinAwardParam(szKinName, nAwardParam)
	if (not szKinName or not nAwardParam) then
		return 0;
	end
	local nKinId = KKin.GetKinNameId(szKinName);
	if (not nKinId or nKinId <= 0) then
		return 0;
	end
	local pKin = KKin.GetKin(nKinId);
	if (not pKin) then
		return 0;
	end
	pKin.SetPlatformKinAward(nAwardParam);
	if (MODULE_GC_SERVER) then
		GlobalExcute{"EPlatForm:SetKinAwardParam", szKinName, nAwardParam};
	end
end

function EPlatForm:GetKinAwardParam(szKinName)
	local nKinId = KKin.GetKinNameId(szKinName);
	if (not nKinId or nKinId <= 0) then
		return 0;
	end
	local pKin = KKin.GetKin(nKinId);
	if (not pKin) then
		return 0;
	end
	return pKin.GetPlatformKinAward();
end

function EPlatForm:ApplyKinEventPlatformData()
	local nState		= EPlatForm:GetMacthState();
	local nRankSession	= EPlatForm:GetMacthSession();
	local nNowTime		= GetTime();
	
	if (nRankSession <= 0) then
		return 0;
	end
	
	local tbMCfg		= EPlatForm:GetMacthTypeCfg(EPlatForm:GetMacthType(nRankSession));
	if (not tbMCfg) then
		return 0;
	end
	
	local nDay = tonumber(os.date("%d", nNowTime));
	
	local tbPlatformInfo = {};
	tbPlatformInfo.szEventName		= "";
	tbPlatformInfo.szState			= self.DEF_STATE_MSG[nState] or "";
	tbPlatformInfo.szStateEndTime	= self:GetStateEndTime(nState) or "";
	tbPlatformInfo.szSignNpcName	= "";
	tbPlatformInfo.szNextTime		= self:GetNextMatchTime() or "";
	tbPlatformInfo.szKinTeamInfo	= "";
	tbPlatformInfo.nAttendCount		= 0;
	tbPlatformInfo.nCurMonthScore	= 0;
	tbPlatformInfo.nTotalScore		= 0;
	tbPlatformInfo.szKinTeamInfo	= "";
	tbPlatformInfo.nKinCurMonthScore	= 0;
	tbPlatformInfo.nKinCurMonthRank	= 0;
	tbPlatformInfo.nKinMinNextKinScore	= 0;
	
	local tbDay = self.DATE_START_DAY[1];
	
	if (nState == self.DEF_STATE_CLOSE or nState == self.DEF_STATE_REST) then
		if (nDay > tbDay[#tbDay]) then
			local tbMCfg		= EPlatForm:GetMacthTypeCfg(EPlatForm:GetMacthType(nRankSession - 1));
			if (tbMCfg) then
				tbPlatformInfo.szEventName		= tbMCfg.szName or "";
				tbPlatformInfo.szSignNpcName	= tbMCfg.szSignNpcName or "";
			end
		else
			tbPlatformInfo.szEventName		= tbMCfg.szName;
			tbPlatformInfo.szSignNpcName	= tbMCfg.szSignNpcName or "";
		end		
	else
		tbPlatformInfo.szEventName		= tbMCfg.szName;
		tbPlatformInfo.szSignNpcName	= tbMCfg.szSignNpcName or "";
	end
	
	local pKin = KKin.GetKin(me.dwKinId);
	if (pKin) then
		local szKinTeamInfo = "";
		local szKinName = pKin.GetName();
		local tbTeamName = self.tbKin2League[szKinName];
		if (tbTeamName) then
			for _, szLeagueName in pairs(tbTeamName) do
				if (League:FindLeague(self.LGTYPE, szLeagueName)) then
					local nFlag = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_MTYPE) or 0;
					if (nFlag > 0) then
						local nRank = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_RANK);
						local nWin = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_WIN);
						local nTie = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_TIE);
						local nTotal = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_TOTAL);
						local nLoss = nTotal-nWin-nTie;
						local nPoint = nWin * EPlatForm.MACTH_POINT_WIN + nTie * EPlatForm.MACTH_POINT_TIE + nLoss * EPlatForm.MACTH_POINT_LOSS;
						szKinTeamInfo = string.format("%s%s\n积分：%d；排名：%d\n", szKinTeamInfo, szLeagueName, nPoint, nRank);
					else
						szKinTeamInfo = string.format("%s%s\n待验证战队\n", szKinTeamInfo, szLeagueName);
					end
				end
			end
		end
		tbPlatformInfo.szKinTeamInfo		= szKinTeamInfo;
		tbPlatformInfo.nKinCurMonthScore	= pKin.GetPlatformScore();
		tbPlatformInfo.nKinCurMonthRank		= pKin.GetPlatformKinRank();
		tbPlatformInfo.nKinMinNextKinScore	= KGblTask.SCGetDbTaskInt(self.GTASK_MACTH_MAX_SCORE_FOR_NEXT);
	end
	
	tbPlatformInfo.nAttendCount = self:GetEventCount(me);
	tbPlatformInfo.nCurMonthScore = self:GetPlayerMonthScore(me.szName);
	tbPlatformInfo.nTotalScore = self:GetHonorById(me.nId);
	
	me.CallClientScript({"EPlatForm:SyncKinPlatformInfo", tbPlatformInfo});
end

function EPlatForm:LoadKinLeagueInfo()
	local nRankSession = KGblTask.SCGetDbTaskInt(EPlatForm.GTASK_MACTH_SESSION);
	local tbMacthCfg = EPlatForm:GetMacthTypeCfg(EPlatForm:GetMacthType(nRankSession))

	self.tbKin2League = {};

	if (not tbMacthCfg) then
		return 0;
	end

	if (EPlatForm:GetMacthState() == EPlatForm.DEF_STATE_MATCH_1 or EPlatForm:GetMacthState() == EPlatForm.DEF_STATE_REST) then
		return 0;
	end
	
	local tbKin2League = {};	
	local pLeagueSet 	= KLeague.GetLeagueSetObject(EPlatForm.LGTYPE);
	local pLeagueItor 	= pLeagueSet.GetLeagueItor();
	local pLeague 		= pLeagueItor.GetCurLeague();
	while(pLeague) do
		local szLeagueName = pLeague.szName;
		local nLeagueSession = League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MSESSION);
		if (nLeagueSession == nRankSession) then
			local szKinName = EPlatForm:GetKinNameFromLeagueName(szLeagueName);
			if (not self.tbKin2League[szKinName]) then
				self.tbKin2League[szKinName] = {};
			end
			self.tbKin2League[szKinName][#self.tbKin2League[szKinName] + 1] = szLeagueName;
		end
		pLeague = pLeagueItor.NextLeague();
	end
end

function EPlatForm:GetKinTeam(szKinName)
	local tbTeamList = {};
	if (not szKinName) then
		return tbTeamList;
	end
end

function EPlatForm:GetNextMatchTime()
	if EPlatForm:GetMacthSession() <= 0 then
		return "";
	end

	if EPlatForm:GetMacthState() == EPlatForm.DEF_STATE_CLOSE then
		return "";		
	end	
	
	if EPlatForm:GetMacthState() == EPlatForm.DEF_STATE_REST then
		return "";
	end	
	
	local nState = EPlatForm:GetMacthState();
	local nTime = GetTime();
	local nHourMin = tonumber(os.date("%H%M", nTime));
	local nDay = tonumber(os.date("%d", nTime));
	local tbCalemdar = EPlatForm.CALEMDAR.tbCommon;
	
	if (nState == EPlatForm.DEF_STATE_MATCH_2) then
		tbCalemdar = EPlatForm.CALEMDAR.tbCommon_Adv;
	end
	
	if (nState == EPlatForm.DEF_STATE_ADVMATCH) then
		tbCalemdar = EPlatForm.CALEMDAR.tbAdvMatch;
	end
	
	if nHourMin > tbCalemdar[#tbCalemdar] then
		return EPlatForm.Fun:Number2Time(tbCalemdar[1]);
	end	
	if nHourMin < tbCalemdar[1] then
		return EPlatForm.Fun:Number2Time(tbCalemdar[1]);
	end
	for nId, nMatchTime in ipairs(tbCalemdar) do
		if nHourMin > nMatchTime and tbCalemdar[nId+1] and nHourMin <= tbCalemdar[nId+1] then
			return EPlatForm.Fun:Number2Time(tbCalemdar[nId+1]);
		end
	end
	return "";
end

function EPlatForm:GetStateEndTime(nState)
	local szStateEndTime = "";
	if (not nState) then
		return szStateEndTime;
	end
	
	local nNowTime = GetTime();
	local nDate = tonumber(os.date("%d%H%M", nNowTime));
	local nMonth = tonumber(os.date("%m", nNowTime));
	local nNextMonth = nMonth + 1;
	if (nNextMonth > 12) then
		nNextMonth = 1;
	end
	
	--判断间歇期
	for nId, tbState in ipairs(EPlatForm.DATE_START_DAY) do
		local nStartDate = tbState[4] * 10000 + 2400;
		local nEndDate	 = EPlatForm.DATE_START_DAY[1][1] * 10000;
		if EPlatForm.DATE_START_DAY[nId + 1] then
			nEndDate = EPlatForm.DATE_START_DAY[nId + 1][1] * 10000;
		end
		
		--跨了月处理
		if nStartDate > nEndDate then
			if nDate > nStartDate then
				return string.format("%d月%d日0点", nNextMonth, EPlatForm.DATE_START_DAY[1][1]);
			end
			if nDate < nEndDate then
				return string.format("%d月%d日0点", nMonth, EPlatForm.DATE_START_DAY[1][1]);
			end
		else
			if nDate > nStartDate and nDate < nEndDate then
				return string.format("%d月%d日0点", nMonth, EPlatForm.DATE_START_DAY[1][1]);
			end
		end
	end
	
	--判断比赛期第一阶段
	for nId, tbState in ipairs(EPlatForm.DATE_START_DAY) do
		local nStartDate = tbState[1]*10000;
		local nEndDate	 = tbState[2]*10000 + 2400;
		
		if nDate >= nStartDate and nDate <= nEndDate then
			return string.format("%d月%d日24点", nMonth, tbState[2]);
		end
	end

	--判断比赛期第二阶段
	for nId, tbState in ipairs(EPlatForm.DATE_START_DAY) do
		local nStartDate = tbState[2]*10000;
		local nEndDate	 = tbState[3]*10000 + 2400;

		if nDate >= nStartDate and nDate <= nEndDate then
			return string.format("%d月%d日24点", nMonth, tbState[3]);
		end
	end	


	--判断八强赛期
	for nId, tbState in ipairs(EPlatForm.DATE_START_DAY) do
		local nStartDate = tbState[3]*10000;
		local nEndDate	 = tbState[4]*10000 + 2400;
		
		--跨了月处理
		if nDate > nStartDate and nDate < nEndDate then
			return string.format("%d月%d日24点", nMonth, tbState[4]);
		end
	end

	return szStateEndTime;
end

function EPlatForm:DelLeagueNameInKinList(szLeagueName)
	if (not szLeagueName) then
		return 0;
	end

	if (MODULE_GC_SERVER) then
		GlobalExcute{"EPlatForm:DelLeagueNameInKinList", szLeagueName};
		return 0;
	end	

	local szKinName = self:GetKinNameFromLeagueName(szLeagueName);
	local tbList = self.tbKin2League[szKinName];
	if (not tbList) then
		return 0;
	end
	for nId, szLeague in pairs(tbList) do
		if (szLeague == szLeagueName) then
			table.remove(self.tbKin2League[szKinName], nId);
			break;
		end
	end
	return 1;
end

function EPlatForm:AddLeagueNameInKinList(szLeagueName)	
	if (not szLeagueName) then
		return 0;
	end

	if (MODULE_GC_SERVER) then
		GlobalExcute{"EPlatForm:AddLeagueNameInKinList", szLeagueName};
		return 0;
	end	
	
	local szKinName = self:GetKinNameFromLeagueName(szLeagueName);
	if (not self.tbKin2League[szKinName]) then
		self.tbKin2League[szKinName] = {};
	end
	table.insert(self.tbKin2League[szKinName], szLeagueName);
	return 1;
end

function EPlatForm:UpdateKinRankInfo(tbKinRankList)
	if (not tbKinRankList) then
		return 0;
	end
	for i, tbInfo in ipairs(tbKinRankList) do
		local pKin = KKin.FindKin(tbInfo[1]);
		if (pKin) then
			pKin.SetPlatformKinRank(i);
		end
	end
	
	if (MODULE_GC_SERVER) then
		GlobalExcute{"EPlatForm:UpdateKinRankInfo", tbKinRankList};
	end
	return 1;
end


function EPlatForm:_Test_ShowKinScore()
	local pKin, nKinId = KKin.GetNextKin(0);
	local tbKinRankList	= {};
	
	while pKin do
		local nScore = pKin.GetPlatformScore();
		pKin, nKinId = KKin.GetNextKin(nKinId);
	end

	return 0;
end

function EPlatForm:ApplyGetKinAward(nPlayerId)
	if (not nPlayerId) then
		return 0;
	end

	local dwKinId, nMemberId = KKin.GetPlayerKinMember(nPlayerId);
	if (dwKinId <= 0) then
		return 0;
	end
	
	local pKin = KKin.GetKin(dwKinId);
	if (not pKin) then
		return 0;
	end
	
	local pMember = pKin.GetMember(nMemberId);
	if (not pMember) then 
		return 0;
	end
	
	local szKinName = pKin.GetName();
	local nFigure = pMember.GetFigure();
	if (nFigure <= 0 or nFigure > 3) then
		return 0;
	end

	local nKinCount = pKin.GetPlatformAwardCount();
	if (nKinCount >= self.DEF_MAX_KINAWARDCOUNT) then
		return 0;
	end
	
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	
	if (self:GetPlayerMonthScore(szPlayerName) < self.DEF_MIN_KINAWARD_SCORE) then
		return 0;
	end
	
	nKinCount = nKinCount - 1;
	
	if (nKinCount < 0) then
		nKinCount = 0;
	end
	
	pKin.SetPlatformAwardCount(nKinCount);
	self:WriteLog("ApplyGetKinAward", string.format("GC Del Kin AwardCount 1, now Count %d", nKinCount), nPlayerId, szPlayerName, szKinName);
		
	if (MODULE_GC_SERVER) then
		GlobalExcute{"EPlatForm:OnGetKinAward", nPlayerId};
	end
end

function EPlatForm:SetKinAwardCount(nPlayerId, nKinCount, nFlag)
	if (not nFlag and MODULE_GAMESERVER) then
		GCExcute{"EPlatForm:SetKinAwardCount", nPlayerId, nKinCount};
		return 0;
	end
	
	if (not nPlayerId) then
		return 0;
	end

	local dwKinId, nMemberId = KKin.GetPlayerKinMember(nPlayerId);
	if (dwKinId <= 0) then
		return 0;
	end
	
	local pKin = KKin.GetKin(dwKinId);
	if (not pKin) then
		return 0;
	end
	
	pKin.SetPlatformAwardCount(nKinCount);
	if (MODULE_GC_SERVER) then
		GlobalExcute{"EPlatForm:SetKinAwardCount", nPlayerId, nKinCount, 1};
	end
end

-- 当时间到的时候
function EPlatForm:SetAllLeagueToFormat()
	local pLeagueSet 	= KLeague.GetLeagueSetObject(EPlatForm.LGTYPE);
	if (not pLeagueSet) then
		return 0;
	end
	local pLeagueItor 	= pLeagueSet.GetLeagueItor();
	if (not pLeagueItor) then
		return 0;
	end
	local pLeague 		= pLeagueItor.GetCurLeague();
	local tbLeagueList	= {};
	local nSync = 1;
	while(pLeague) do
		local nType = pLeague.GetTask(EPlatForm.LGTASK_MTYPE);
		local nSession = pLeague.GetTask(EPlatForm.LGTASK_MSESSION);
		local szLeagueName = pLeague.szName;
		if (nType <= 0) then
			League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MSESSION, self:GetMacthSession(), nSync);
			League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MTYPE, self:GetMacthType(), nSync);
			League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MEXPARAM, 0, nSync);
			League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_RANK, 0, nSync);
			League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_WIN, 0, nSync);
			League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TIE, 0, nSync);
			League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TOTAL, 0, nSync);
			League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TIME, 0, nSync);
			League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_EMY1, 0, nSync);
			League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_EMY2, 0, nSync);
			League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_EMY3, 0, nSync);
			League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_EMY4, 0, nSync);
			League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_EMY5, 0, nSync);
			League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_ATTEND, 0, nSync);
			League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_ENTER, 0, nSync);
			League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_DALIYCOUNT, 2, nSync);
			League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_DALIYCHANGETIME, GetTime(), nSync);	
			
			if (MODULE_GC_SERVER) then
				local szLog = "";
				local szMemberNameList = "";
				local tbPlayerList = League:GetMemberList(EPlatForm.LGTYPE, szLeagueName);
				local nCount = Lib:CountTB(tbPlayerList);
				local nFlag = 0;
				for nId, szMemberName in pairs(tbPlayerList) do
					if (nFlag > 0) then
						szMemberNameList = szMemberNameList .. ",";
					end
					szMemberNameList = szMemberNameList .. szMemberName;
					nFlag = 1;
				end
				szLog = string.format("%s,%s,%s", szLeagueName, nCount, szMemberNameList);
				StatLog:WriteStatLog("stat_info", "kin_game", "biuldup", 0, szLog);
			end
		end
		pLeague = pLeagueItor.NextLeague();
	end

	if (MODULE_GC_SERVER) then
		GlobalExcute{"EPlatForm:SetAllLeagueToFormat"};
	end
end

function EPlatForm:GetLeaveMapPos()	
	local tbNpc = Npc:GetClass("chefu");
	for _, tbMapInfo in ipairs(tbNpc.tbCountry) do
		if SubWorldID2Idx(tbMapInfo.nId) >= 0 then
			local nRandomPos = MathRandom(1, #tbMapInfo.tbSect)
			return tbMapInfo.nId, tbMapInfo.tbSect[nRandomPos][1],tbMapInfo.tbSect[nRandomPos][2];
		end
	end
	return 5, 1580, 3029;
end	

function EPlatForm:ClearKinScoreAndRank()
	local pKin, nKinId = KKin.GetNextKin(0);
	
	while pKin do
		pKin.SetPlatformScore(0);
		pKin.SetPlatformKinRank(0);
		pKin.SetPlatformKinAward(0);
		pKin, nKinId = KKin.GetNextKin(nKinId);
	end
	if (MODULE_GC_SERVER) then
		GlobalExcute{"EPlatForm:ClearKinScoreAndRank"};
	end
end

function EPlatForm:ClearKinAwardCount()
	local pKin, nKinId = KKin.GetNextKin(0);
	
	while pKin do
		pKin.SetPlatformAwardCount(0);
		pKin, nKinId = KKin.GetNextKin(nKinId);
	end
	if (MODULE_GC_SERVER) then
		GlobalExcute{"EPlatForm:ClearKinAwardCount"};
	end
end

function EPlatForm:ClearPlatformMonthScore()
	ClearPlatformMonthScore();
	if (MODULE_GC_SERVER) then
		GlobalExcute{"EPlatForm:ClearPlatformMonthScore"};
	end
end

function EPlatForm:PlayerLoginRV()
	local nDate = tonumber(GetLocalDate("%Y%m%d")); 
	if nDate > EPlatForm.PLAYER_LOGINRV_DATE then
		return;
	end
	
	if me.GetTask(EPlatForm.TASKID_GROUP, EPlatForm.TASKID_PLAYER_LOGINRV) ~= 0 then
		return;
	end
	
	me.SetTask(EPlatForm.TASKID_GROUP, EPlatForm.TASKID_PLAYER_LOGINRV, 1);
	-- 清雪仗技能
	for _, nSkillId in pairs(Esport.tbTemplateId2Skill) do
		if me.IsHaveSkill(nSkillId) == 1 then
			me.DelFightSkill(nSkillId);
		end
	end
	
	if me.IsHaveSkill(1312) == 1 then
		me.DelFightSkill(1312);
	end
	
	--清龙舟技能
	Esport.DragonBoat:ClearAllSkill(me);
end



if (MODULE_GC_SERVER) then
	GCEvent:RegisterGCServerStartFunc(EPlatForm.UpdateMatchTime, EPlatForm);
end

if (MODULE_GAMESERVER) then
	ServerEvent:RegisterServerStartFunc(EPlatForm.UpdateMatchTime, EPlatForm);
	ServerEvent:RegisterServerStartFunc(EPlatForm.LoadKinLeagueInfo, EPlatForm);
	PlayerEvent:RegisterOnLoginEvent(EPlatForm.PlayerLoginRV, EPlatForm);
end
