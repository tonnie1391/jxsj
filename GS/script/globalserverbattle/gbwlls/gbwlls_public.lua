-- 文件名　：gbwlls_public.lua
-- 创建者　：zhouchenfei
-- 创建时间：2009-12-16 11:15:59
-- 描述　  ：跨服联赛相关函数

function GbWlls:GetGblWllsOpenState()
	return GetGlobalSportTask(GbWlls.GBTASK_GROUP, GbWlls.GBTASK_SESSION) or 0;
end

function GbWlls:SetGblWllsOpenState(nState)
	SetGlobalSportTask(GbWlls.GBTASK_GROUP, GbWlls.GBTASK_SESSION, nState);
end

function GbWlls:GetGblWllsOpenTime()
	return GetGlobalSportTask(GbWlls.GBTASK_GROUP, GbWlls.GBTASK_FIRSTOPENTIME) or 0;
end

function GbWlls:SetGblWllsOpenTime(nTime)
	SetGlobalSportTask(GbWlls.GBTASK_GROUP, GbWlls.GBTASK_FIRSTOPENTIME, nTime);
end

function GbWlls:SetGblWllsState(nState)
	SetGlobalSportTask(GbWlls.GBTASK_GROUP, GbWlls.GBTASK_MATCH_STATE, nState);
end

function GbWlls:GetGblWllsState()
	return GetGlobalSportTask(GbWlls.GBTASK_GROUP, GbWlls.GBTASK_MATCH_STATE) or 0;
end

-- 获取排序完成标志
function GbWlls:GetGblWllsRankFinish()
	return GetGlobalSportTask(GbWlls.GBTASK_GROUP, GbWlls.GBTASK_MATCH_RANK) or 0;
end

function GbWlls:SetGblWllsRankFinish(nFlag)
	SetGlobalSportTask(GbWlls.GBTASK_GROUP, GbWlls.GBTASK_MATCH_RANK, nFlag);
end

-- 设置黄金跨服联赛开关
function GbWlls:SetGoldenGbWllsOpenFlag(nFlag)
	SetGlobalSportTask(GbWlls.GBTASK_GROUP, GbWlls.GBTASK_MATCH_OPEN_GOLDEN, nFlag);
end

function GbWlls:GetGoldenGbWllsOpenFlag()
	return GetGlobalSportTask(GbWlls.GBTASK_GROUP, GbWlls.GBTASK_MATCH_OPEN_GOLDEN) or 0;
end

--获得赛制类型配置表
function GbWlls:GetMacthTypeCfg(nMacthType)
	if not nMacthType or nMacthType <= 0 then
		return
	end
	return self.MacthType[self.MACTH_TYPE[nMacthType]];
end

--获得赛制类型,Int
function GbWlls:GetMacthType(nSession)
	if not nSession then
		return 0;
	end
	if not self.SEASON_TB[nSession] then
		return 0;
	end
	return self.SEASON_TB[nSession][1];
end

-- 参加黄金跨服联赛的排名限制,已经参加黄金跨服联赛的
function GbWlls:GetJoinGoldenMatchAdvRank(nSession)
	if not nSession then
		return 0;
	end
	if not self.SEASON_TB[nSession] then
		return 0;
	end
	return self.SEASON_TB[nSession][3];
end

-- 参加黄金跨服联赛的排名限制,已经参加高级联赛的
function GbWlls:GetJoinGoldenMatchPrimRank(nSession)
	if not nSession then
		return 0;
	end
	if not self.SEASON_TB[nSession] then
		return 0;
	end
	return self.SEASON_TB[nSession][6];
end

--获得赛制等级配置表
function GbWlls:GetMacthLevelCfg(nMacthType, nMacthLevel)
	if not nMacthType or nMacthType <= 0 then
		return
	end
	return self.MacthType[self.MACTH_TYPE[nMacthType]][self.MACTH_LEVEL[nMacthLevel]];
end

--获得当前赛制类型
function GbWlls:GetMacthLevelCfgType()
	local nRankSession = GbWlls:GetGblWllsOpenState();
	if GbWlls:GetMacthTypeCfg(GbWlls:GetMacthType(nRankSession)) then
		return GbWlls:GetMacthTypeCfg(GbWlls:GetMacthType(nRankSession)).nMapLinkType;
	end
	return 0;
end

function GbWlls:SetPlayerGblWllsSessionByName(szPlayerName, nSession)
	if (not GLOBAL_AGENT) then
		return 0;
	end
	if (not szPlayerName) then
		return 0;
	end
	local nId = KGCPlayer.GetPlayerIdByName(szPlayerName);
	if nId then
		SetPlayerSportTask(nId, GbWlls.GBTASKID_GROUP, GbWlls.GBTASKID_SESSION, nSession);
	end
end

function GbWlls:GetPlayerGblWllsSessionByName(szPlayerName)
	if (not szPlayerName) then
		return 0;
	end
	local nId = KGCPlayer.GetPlayerIdByName(szPlayerName);
	if nId then
		return GetPlayerSportTask(nId, GbWlls.GBTASKID_GROUP, GbWlls.GBTASKID_SESSION) or 0;
	end
	return 0;
end

-- 检查是否允许进入比赛期
function GbWlls:CheckOpenState_GblServer()
	if (not GLOBAL_AGENT) then
		return 0;
	end
	
	if (self.IsOpen ~= 1) then
		return 0;
	end
	
	local nFlagState = GbWlls:GetGblWllsOpenState();
	if (not nFlagState or nFlagState <= 0) then
		return 0;
	end

	if (self:CheckOpenMonth(GetTime()) == 0) then
		return 0;
	end

	return 1;
end

function GbWlls:SetGblWllsSession(nSession)
	if (not GLOBAL_AGENT) then
		return 0;
	end

	if (not nSession or nSession <= 0) then
		return 0;
	end

	local nGblSession = self:GetGblWllsOpenState();
	if (nGblSession <= 0) then
		return 0;
	end
	self:SetGblWllsOpenState(nSession);
end

function GbWlls:CheckOpenMonth(nNowTime)
	if (not nNowTime) then
		return 0;
	end
	local tbTime	= os.date("*t", nNowTime);
	if (not tbTime) then
		return 0;
	end
	for i=1, #GbWlls.DEF_OPEN_MONTH do
		if (tbTime.month == GbWlls.DEF_OPEN_MONTH[i]) then
			return 1;
		end	
	end
	return 0;
end

-- 开启全局服务器第一届比赛
function GbWlls:WllsGlobalServerOpenTime()
	if (not GLOBAL_AGENT) then
		return 0;
	end

	-- 是否开启全局服务器联赛
	local nStateFlag = self:GetGblWllsOpenState();
	if (nStateFlag <= 0) then
		return 0;
	end
	
	-- 是否已经开启第一届
	local nTime = self:GetGblWllsOpenTime();
	-- 表示已经标记上开启联赛
	if (nTime > 0) then
		return 0;
	end
	
	if (Wlls:GetMatchStateForDate() ~= GbWlls.DEF_STATE_REST) then
		return 0;
	end	
	local nNowTime	= GetTime();
	if (self:CheckOpenMonth(nNowTime) == 0) then
		return 0;
	end

	KGblTask.SCSetDbTaskInt(GbWlls.GTASK_MACTH_SESSION, 1);	
	KGblTask.SCSetDbTaskInt(GbWlls.GTASK_MACTH_STATE, GbWlls.DEF_STATE_REST);
	GbWlls:SetGblWllsOpenState(1);
	GbWlls:SetGblWllsOpenTime(GetTime());
	return 1;
end

-- 查看本服是否有资格参加跨服联赛
function GbWlls:ServerIsCanJoinGbWlls()
	local nSession = Wlls:GetMacthSession();
	if (nSession < GbWlls.DEF_OPENGBWLLSSESSION) then
		return 0, "您所在的服务器还没进行过三届武林联赛，无法去参加跨服武林联赛。";
	end
	return 1;
end

-- 验证是否有资格去全局服务器
function GbWlls:CheckIsCanTransferGblWlls(pPlayer)
	if (not pPlayer) then
		return 0, string.format("只有财富荣誉前%d名，联赛荣誉排名前%d名的玩家，或者之前已经报了名的玩家才能去英雄岛。", GbWlls.DEF_MAXGBWLLS_MONEY_RANK, GbWlls.DEF_MAXGBWLLS_WLLS_RANK);
	end
	local nGblSession = self:GetGblWllsOpenState();
	local nMyGblSession = self:GetPlayerGblWllsSessionByName(pPlayer.szName);
	-- 已经参加了跨服联赛，无论是否排名等级，都可以进入

	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, pPlayer.szName);
	local nFlag = Wlls:GetPlayerLeagueFlag(pPlayer);

	if not szLeagueName then
		-- 表示没有战队但是没有清变量
		if (nFlag == 1) then
			Wlls:SetPlayerIsLeagueFlag(pPlayer.szName, 0);
		end
	else
		-- 如果有战队没标记，标记上
		if (nFlag == 0) then
			Wlls:SetPlayerIsLeagueFlag(pPlayer.szName, 1);
		end
		return 0, "您已经参加了本服的武林联赛，无法参加跨服联赛。";
	end
	
	if (nGblSession > 0 and nGblSession == nMyGblSession) then
		return 1;
	end
	
	if (pPlayer.nLevel < GbWlls.DEF_MIN_PLAYERLEVEL) then
		return 0, string.format("您的等级没有达到%d级，无法参加跨服联赛。", GbWlls.DEF_MIN_PLAYERLEVEL);
	end
	
	local nMoneyRank	= PlayerHonor:GetPlayerHonorRankByName(pPlayer.szName, PlayerHonor.HONOR_CLASS_MONEY, 0);
	local nWllsRank		= PlayerHonor:GetPlayerHonorRankByName(pPlayer.szName, PlayerHonor.HONOR_CLASS_WLLS, 0);
	if ((nMoneyRank <= 0 or nMoneyRank > self.DEF_MAXGBWLLS_MONEY_RANK) and (nWllsRank <= 0 or nWllsRank > self.DEF_MAXGBWLLS_WLLS_RANK)) then
		return 0, string.format("只有财富荣誉前%d名，联赛荣誉排名前%d名的玩家，或者之前已经报了名的玩家才能去英雄岛。", GbWlls.DEF_MAXGBWLLS_MONEY_RANK, GbWlls.DEF_MAXGBWLLS_WLLS_RANK);
	end
	
	local nSession = Wlls:GetMacthSession();
	if (nSession < GbWlls.DEF_OPENGBWLLSSESSION) then
		return 0, "您所在的服务器还没进行过三届武林联赛，无法去参加跨服武林联赛。";
	end
	me.SetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_MONEY_RANK, nMoneyRank);
	me.SetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_WLLS_RANK, nWllsRank);
	return 1;
end

-- 判断是否可以报名参加当前所在服务器的联赛比赛
function GbWlls:CheckWllsQualition(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	
	-- 如果是全局服务器就判断是否已经参加了那个玩家在本服的联赛
	if (GLOBAL_AGENT) then
		local nLeagueFlag = Wlls:GetPlayerLeagueFlag(pPlayer);
		if (nLeagueFlag == 1) then
			return 0;
		end
	else
		local nGblMySession = GetPlayerSportTask(pPlayer.nId, GbWlls.GBTASKID_GROUP, GbWlls.GBTASKID_SESSION) or 0;
		local nGblSession	= GetGlobalSportTask(GbWlls.GBTASK_GROUP, GbWlls.GBTASK_SESSION) or 0;
		if (nGblSession <= 0) then
			return 1;
		end
		
		-- 如果两个值相同，且都大于0，那么说明已经参加了玩家跨服联赛
		if (nGblMySession == nGblSession) then
			return 0;
		end
	end
	return 1;
end

-- 1表示已经参加跨服联赛
function GbWlls:CheckIsJoinGbWlls(szPlayerName)
	if (not szPlayerName) then
		return 0;
	end

	local nPlayerId = KGCPlayer.GetPlayerIdByName(szPlayerName);
	
	if (nPlayerId <= 0) then
		return 0;
	end
	
	local nGblMySession = GetPlayerSportTask(nPlayerId, GbWlls.GBTASKID_GROUP, GbWlls.GBTASKID_SESSION) or 0;
	local nGblSession	= GetGlobalSportTask(GbWlls.GBTASK_GROUP, GbWlls.GBTASK_SESSION) or 0;
	if (nGblSession <= 0) then
		return 0;
	end
	
	-- 如果两个值相同，且都大于0，那么说明已经参加了玩家跨服联赛
	if (nGblMySession == nGblSession) then
		return 1;
	end
	return 0;
end

function GbWlls:GetPlayerSportTask(szPlayerName, nTaskId)
	if (not szPlayerName or not nTaskId or nTaskId <= 0) then
		return 0;
	end
	local nId = KGCPlayer.GetPlayerIdByName(szPlayerName);
	if not nId or nId <= 0 then
		return 0;
	end
	return GetPlayerSportTask(nId, GbWlls.GBTASKID_GROUP, nTaskId) or 0;
end

function GbWlls:SetPlayerSportTask(szPlayerName, nTaskId, nValue)
	if (not szPlayerName or not nTaskId or nTaskId <= 0 or not nValue) then
		return 0;
	end
	local nId = KGCPlayer.GetPlayerIdByName(szPlayerName);
	if not nId or nId <= 0 then
		return 0;
	end
	SetPlayerSportTask(nId, GbWlls.GBTASKID_GROUP, nTaskId, nValue);
end

--获得奖励等级段
function GbWlls:GetAwardLevelSep(nGameLevel, nSession, nRank)
	if nRank <= 0 then
		return 0, 0;
	end
	for nLevelSep, tbInfo in ipairs(self.AWARD_LEVEL[nSession][nGameLevel]) do
		if nRank <= tbInfo.nMaxRank then
			return nLevelSep, tbInfo.nMaxRank;
		end
	end
	return 0, 0;
end

function GbWlls:ResetPlayerGbWllsInfo(szPlayerName, nMatchLevel, nExParam)
	if (not GLOBAL_AGENT) then
		return 0;
	end

	self:SetPlayerSportTask(szPlayerName, self.GBTASKID_MATCH_LEVEL, nMatchLevel);
	self:SetPlayerSportTask(szPlayerName, self.GBTASKID_MATCH_RANK, 0);
	self:SetPlayerSportTask(szPlayerName, self.GBTASKID_MATCH_WIN_AWARD, 0);
	self:SetPlayerSportTask(szPlayerName, self.GBTASKID_MATCH_TIE_AWARD, 0);
	self:SetPlayerSportTask(szPlayerName, self.GBTASKID_MATCH_LOSE_AWARD, 0);
	self:SetPlayerSportTask(szPlayerName, self.GBTASKID_MATCH_FINAL_AWARD, 0);
	self:SetPlayerSportTask(szPlayerName, self.GBTASKID_MATCH_ADVRANK, 0);
	self:SetPlayerSportTask(szPlayerName, self.GBTASKID_MATCH_TYPE_PAREM, nExParam or 0);
end

function GbWlls:SetGbWllsEnterFlag(pPlayer, nFlag)
	if (not pPlayer) then
		return 0;
	end
	pPlayer.SetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_ENTERFLAG, nFlag);
end

function GbWlls:GetGbWllsEnterFlag(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	return pPlayer.GetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_ENTERFLAG);
end

function GbWlls:Anncone_GS(szAnncone)
	KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szAnncone);
	KDialog.Msg2SubWorld(szAnncone);
end

function GbWlls:OnLogin()
	if (not GLOBAL_AGENT) then
		self:SetGbWllsEnterFlag(me, 0);
		self:ProcessJoinTitle(me);
	end
end

function GbWlls:ProcessJoinTitle(pPlayer)
	if (GLOBAL_AGENT) then
		return 0;
	end
	
	if (not pPlayer) then
		return 0;
	end
	
	local nTime = GetTime();
	if (self:CheckSiguUpTime(nTime) == 0) then
		return 0;
	end
	
	local tbTime = os.date("*t", nTime);
	if (not tbTime) then
		return 0;
	end

	local nJoinFlag		= self:CheckWllsQualition(pPlayer);
	local nTitleFlag	= pPlayer.FindTitle(unpack(self.JOIN_TITLE));
	-- 表示已经报名参加了跨服联赛
	if (0 == nJoinFlag) then
		-- 有资格没称号，加
		if (0 == nTitleFlag) then			
			local tbEndTime = {
				year	=tbTime.year,
				month	=tbTime.month + 1,
				day		=1,
				hour	=0,
				min		=0,
				sec		=0,
			};
			local nEndTime = os.time(tbEndTime);
			pPlayer.AddTitleByTime(self.JOIN_TITLE[1], self.JOIN_TITLE[2], self.JOIN_TITLE[3], self.JOIN_TITLE[4], nEndTime);
			local nSession = self:GetGblWllsOpenState();
			if (nSession <= 0) then
				return 0;
			end
			local nMacthType = GbWlls:GetMacthType(nSession);
			local tbMatchCfg = GbWlls:GetMacthTypeCfg(nMacthType);			
			local szMsg = string.format(self.MSG_JOIN_SUCCESS_FOR_ALL, pPlayer.szName, nSession, tbMatchCfg.szName);
			pPlayer.SendMsgToFriend(szMsg);
		end
	else
		-- 没资格有称号，删
		if (1 == nTitleFlag) then
			pPlayer.RemoveTitle(unpack(self.JOIN_TITLE));
		end
	end
end

function GbWlls:CheckSiguUpTime(nTime)
	if (not nTime or nTime <= 0) then
		return 0;
	end
	local tbTime = os.date("*t", nTime);
	if (not tbTime) then
		return 0;
	end
	local nMonthFlag = 0;
	for _, nValue in ipairs(GbWlls.DEF_OPEN_MONTH) do
		if (nValue == tbTime.month) then
			nMonthFlag = 1;
			break;
		end
	end
	if (nMonthFlag ~= 1) then
		return 0;
	end
	
	if (tbTime.day > self.DEF_SIGN_DEADLINE) then
		return 0;
	end
	return 1;
end

function GbWlls:GetZoneName(pPlayer)
	local szGateway = Transfer:GetMyGateway(pPlayer);
	local tbInfo = ServerEvent:GetServerInforByGateway(szGateway);
	if not tbInfo then
		print("stack traceback", "Transfer:GetMyGatewa Error", "Not Find gatewaylistInfor", szGateway);
		return;
	end
	return tbInfo.ZoneName, tbInfo.ServerName;
end

function GbWlls:GetZoneNameAndServerName()
	local tbInfo = ServerEvent:GetMyServerInforByGateway();
	if (not tbInfo) then
		return "", "";
	end
	return tbInfo.ZoneName, tbInfo.ServerName;
end

function GbWlls:GetZoneInfo(szGateway)
	if (not szGateway) then
		return nil;
	end
	if (not self.tbZoneName) then
		return nil;
	end
	local nZoneId = tonumber(string.sub(szGateway, 5, 6)) or 0;
	return self.tbZoneName[nZoneId];
end

function GbWlls:WriteLog(...)
	if (MODULE_GAMESERVER) then
		Dbg:WriteLogEx(Dbg.LOG_INFO, "GbWlls", unpack(arg));
	end
	if (MODULE_GC_SERVER) then
		Dbg:WriteLog("GbWlls", unpack(arg));
	end
end

function GbWlls:ClearAllStatuary()
	Domain.tbStatuary:ClearGbWllsStatuary();
end

function GbWlls:_RepairMatchLevel(pPlayer, nNowMatchLevel)
	if (not pPlayer) then
		return 0;
	end
	
	local nChangeDate = tonumber(os.date("%Y%m%d", GetTime()));
	if (nChangeDate >= GbWlls._DEF_MATCHLEVEL_CHANGETIME) then
		return 0;
	end
	local nMatchLevel = GbWlls:GetPlayerSportTask(me.szName, GbWlls.GBTASKID_MATCH_LEVEL);
	local nMatchSession	= GbWlls:GetPlayerSportTask(me.szName, GbWlls.GBTASKID_SESSION);
	if (nMatchSession <= 0) then
		return 0;
	end
	
	if (nMatchLevel > 0) then
		return 0;
	end

	GbWlls:SetPlayerSportTask(me.szName, GbWlls.GBTASKID_MATCH_LEVEL, nNowMatchLevel);
	self:WriteLog("_RepairMatchLevel", pPlayer.szName, "repair the matchlevel", nNowMatchLevel);
	return 1;
end

-- 到时间的时候给符合跨服联赛资格的玩家发送邀请函
function GbWlls:SendJoiningGbWllsMail()
	if (GbWlls:ServerIsCanJoinGbWlls() ~= 1) then
		return 0;
	end

	local nSession	 = GbWlls:GetGblWllsOpenState();
	if (nSession <= 0) then
		return 0;
	end
	local nMacthType = GbWlls:GetMacthType(nSession);
	local tbMatchCfg = GbWlls:GetMacthTypeCfg(nMacthType);		
	
	local tbResultPlayerList = self:GetJoinPlayerList();
	
	local nTime		= GetTime();
	local tbTime	= os.date("*t", nTime);
	local tbMail = {
		szTitle		= string.format(self.MAIL_JOINGBWLLS.szTitle, tbMatchCfg.szName), 
		szContent	= string.format(self.MAIL_JOINGBWLLS.szContent, Lib:Transfer4LenDigit2CnNum(nSession), tbMatchCfg.szName, tbTime.month, self.DEF_ADV_PK_STARTDAY),
	};
	
	Mail.tbParticularMail:SendMail(tbResultPlayerList, tbMail);
	return 1;
end

function GbWlls:SendJoinMail_Gb()
	if (not GLOBAL_AGENT) then
		return 0;
	end

	local nNowTime = GetTime();
	if (self:CheckOpenMonth(nNowTime) == 0) then
		return 0;
	end
	
	local tbTime = os.date("*t", nNowTime);
	if (tbTime.day ~= self.DEF_SEND_MAIL_DAY) then
		return 0;
	end
	
	local nSession = self:GetGblWllsOpenState();
	if (nSession <= 0) then
		return 0;
	end
	
	if (self:GetGblWllsState() ~= self.DEF_STATE_REST) then
		return 0;
	end
	
	if (GbWlls.IsOpen ~= 1) then
		return 0;
	end
	-- 如果是跨服联赛则要删除所有战队
	Timer:Register(Wlls.MACTH_TIME_CLEARLEAGUE,  Wlls.ClearLeague, Wlls);
	Timer:Register(self.DEF_TIME_SEND_JOINMAIL * Env.GAME_FPS, self.OnTimer_SendJoinMail, self);
	
end

function GbWlls:OnTimer_SendJoinMail()
	GC_AllExcute({"GbWlls:SendJoiningGbWllsMail"});
	return 0;
end

-- 获取联赛前150名或者财富排名在前200名的玩家
function GbWlls:GetJoinPlayerList()
	local tbResultList = {};
	local tbTypeName = {};

	-- 联赛荣誉
	local nType = Ladder:GetType(0, Ladder.LADDER_CLASS_WLLS, Ladder.LADDER_TYPE_WLLS_HONOR, 0);
	local tbLadder = GetTotalLadderPart(nType, 1, self.DEF_MAXGBWLLS_WLLS_RANK);
	if (tbLadder) then
		for _, tbInfo in pairs(tbLadder) do
			table.insert(tbResultList, tbInfo.szPlayerName);
			tbTypeName[tbInfo.szPlayerName] = 1;
		end
	end
	
	-- 财富荣誉
	nType = Ladder:GetType(0, Ladder.LADDER_CLASS_MONEY, Ladder.LADDER_TYPE_MONEY_HONOR_MONEY, 0);
	tbLadder = GetTotalLadderPart(nType, 1, self.DEF_MAXGBWLLS_MONEY_RANK);	
	if (tbLadder) then
		for _, tbInfo in pairs(tbLadder) do
			if (not tbTypeName[tbInfo.szPlayerName]) then
				table.insert(tbResultList, tbInfo.szPlayerName);
			end
		end		
	end
	
	return tbResultList;
end

function GbWlls:SendAdvGbWllsMatchMail(tbPlayerName)
	if (not tbPlayerName) then
		return 0;
	end

	if (GbWlls:ServerIsCanJoinGbWlls() ~= 1) then
		return 0;
	end
	
	local nSession	 = GbWlls:GetGblWllsOpenState();
	if (nSession <= 0) then
		return 0;
	end
	local nMacthType = GbWlls:GetMacthType(nSession);
	local tbMatchCfg = GbWlls:GetMacthTypeCfg(nMacthType);	
	
	local tbGateInfo = ServerEvent:GetMyServerInforByGateway() or {};
	
	local nTime		= GetTime();
	local tbTime	= os.date("*t", nTime);
	local tbMail = {
		szTitle		= string.format(self.MAIL_JOINGBWLLS_ADV.szTitle, tbMatchCfg.szName), 
		szContent	= string.format(self.MAIL_JOINGBWLLS_ADV.szContent, tbGateInfo.ZoneName or "本", tbTime.month, self.DEF_ADV_PK_STARTDAY),
	};
	
	Mail.tbParticularMail:SendMail(tbPlayerName, tbMail);
	return 1;
end

function GbWlls:SendAdvGbWllsMatchMail_Gb()
	if (not GLOBAL_AGENT) then
		return 0;
	end

	local nNowTime = GetTime();
	if (self:CheckOpenMonth(nNowTime) == 0) then
		return 0;
	end
	
	local tbTime = os.date("*t", nNowTime);
	
	local nSession = self:GetGblWllsOpenState();
	if (nSession <= 0) then
		return 0;
	end
	
	if (self:GetGblWllsState() ~= self.DEF_STATE_ADVMATCH) then
		return 0;
	end
	
	if (GbWlls.IsOpen ~= 1) then
		return 0;
	end

	local tbPlayerName = {};
	-- 门派赛
	if Wlls:GetMacthLevelCfgType() == Wlls.MAP_LINK_TYPE_FACTION then
		local tbMacthLevelCfg = Wlls:GetMacthLevelCfg(Wlls:GetMacthType(), Wlls.MACTH_ADV);
		for nReadyId, nMapId in pairs(tbMacthLevelCfg.tbReadyMap) do
			local tbLadder, szName, szContext = GetShowLadder(Ladder:GetType(0, 3, 2, nReadyId));
			if (tbLadder) then
				for nId, tbLeague in ipairs(tbLadder) do
					if nId <= 8 then
						local tbTeam = Wlls:GetLeagueMemberList(tbLeague.szName);
						if (tbTeam) then
							for _, szMemberName in ipairs(tbTeam) do
								tbPlayerName[#tbPlayerName + 1] = szMemberName;
							end
						end
					end
				end
			end
		end
	elseif (Wlls:GetMacthLevelCfgType() == Wlls.MAP_LINK_TYPE_RANDOM) then
		local tbLadder, szName, szContext = GetShowLadder(Ladder:GetType(0, 3, 2, 0));
		if (tbLadder) then
			for nId, tbLeague in ipairs(tbLadder) do
				if nId <= 8 then
					local tbTeam = Wlls:GetLeagueMemberList(tbLeague.szName);
					if (tbTeam) then
						for _, szMemberName in ipairs(tbTeam) do
							tbPlayerName[#tbPlayerName + 1] = szMemberName;
						end
					end
				end
			end
		end
	else
		return 0;
	end
	
	GC_AllExcute({"GbWlls:SendAdvGbWllsMatchMail", tbPlayerName});
end

function GbWlls:SendJoinMsg_GB(szPlayerName)
	if (not GLOBAL_AGENT) then
		return 0;
	end
	GC_AllExcute({"GbWlls:SendJoinMsg_GC", szPlayerName});
end

function GbWlls:SendJoinMsg_GC(szPlayerName)
	if (not MODULE_GC_SERVER) then
		return 0;
	end
	
	if (not szPlayerName) then
		return 0;
	end
	local nPlayerId = KGCPlayer.GetPlayerIdByName(szPlayerName);
	if (not nPlayerId or nPlayerId <= 0) then
		return 0;
	end
	GlobalExcute({"GbWlls:SendJoinMsg_GS", szPlayerName});
end

function GbWlls:SendJoinMsg_GS(szPlayerName)
	if (not MODULE_GAMESERVER) then
		return 0;
	end
	
	local tbPlayerInfo = GetPlayerInfoForLadderGC(szPlayerName);
	if (not tbPlayerInfo) then
		return 0;
	end

	local nSession = self:GetGblWllsOpenState();
	if (nSession <= 0) then
		return 0;
	end
	local nMacthType = self:GetMacthType(nSession);
	local tbMatchCfg = self:GetMacthTypeCfg(nMacthType);			
	local szMsg = string.format(self.MSG_JOIN_SUCCESS_FOR_ALL, szPlayerName, Lib:Transfer4LenDigit2CnNum(nSession), tbMatchCfg.szName);
	
	if (tbPlayerInfo.nKinId > 0) then
		KKin.Msg2Kin(tbPlayerInfo.nKinId, szMsg);
	end
	
	if (tbPlayerInfo.nTongId > 0) then
		KTong.Msg2Tong(tbPlayerInfo.nTongId, szMsg);
	end
	return 1;
end

function GbWlls:SendWorldMsg_Gb(szMsg)
	if GLOBAL_AGENT then
		GC_AllExcute({"Dialog:SendWorldMsg_GC", szMsg});
	end
end

function GbWlls:SendWorldMsg_GC(szMsg)
	if (self:ServerIsCanJoinGbWlls() == 0) then
		return 0;
	end
	Dialog:GlobalMsg2SubWorld_GC(szMsg);
end

function GbWlls:SendNewsMsg_Gb(szMsg)
	if GLOBAL_AGENT then
		GC_AllExcute({"Dialog:SendNewsMsg_GC", szMsg});
	end
end

function GbWlls:SendNewsMsg_GC(szMsg)
	if (self:ServerIsCanJoinGbWlls() == 0) then
		return 0;
	end
	Dialog:GlobalMsg2SubWorld_GC(szMsg);
end

function GbWlls:SendPlayerJoinOrLeave_GB(tbPlayerList, nGateWay, nLeave)
	if (not GLOBAL_AGENT) then
		return 0;
	end
	if (not tbPlayerList or not nGateWay or nGateWay <= 0) then
		return 0;
	end
	
	GC_AllExcute({"GbWlls:SendPlayerJoinOrLeave_GC", tbPlayerList, nGateWay, nLeave});
	return 1;
end

function GbWlls:SendPlayerJoinOrLeave_GC(tbPlayerList, nGateWay, nLeave)
	if (not MODULE_GC_SERVER) then
		return 0;
	end
	if (not tbPlayerList or not nGateWay or nGateWay <= 0) then
		return 0;
	end
	
	local szGateway = GetGatewayName();
	local nNowGateWay = tonumber(string.sub(szGateway, 5, 8));
	
	if (nGateWay ~= nNowGateWay) then
		return 0;
	end

	GlobalExcute({"GbWlls:SendPlayerJoinOrLeave_GS", tbPlayerList, nLeave});
	return 1;
end

function GbWlls:SendPlayerJoinOrLeave_GS(tbPlayerList, nLeave)
	if (not tbPlayerList) then
		return 0;
	end
	
	-- 表示是添加的
	if (not nLeave or nLeave ~= 1) then
		for _, szName in pairs(tbPlayerList) do
			table.insert(self.tbMatchPlayerList, szName);
		end
		return 1;
	end
	local tbDelList = {};
	-- 从表中删除
	for _, szName in pairs(tbPlayerList) do
		local nIndex = 0;
		for i, szPlayerName in pairs(self.tbMatchPlayerList) do
			if (szName == szPlayerName and szName ~= "") then
				nIndex = i;
				break;
			end
		end
		if (nIndex > 0) then
			table.remove(self.tbMatchPlayerList, nIndex);
		end
	end

	return 1;
end

function GbWlls:Process8RankInfo(tb8RankInfo)
	if (not tb8RankInfo) then
		return 0;
	end
	local nState	= tb8RankInfo.nState;
	if (not nState) then
		return 0;
	end

	if (GbWlls:ServerIsCanJoinGbWlls() ~= 1) then
		return 0;
	end
	
	local nSession	 = GbWlls:GetGblWllsOpenState();
	if (nSession <= 0) then
		return 0;
	end
	if (nState == Wlls.DEF_STATE_MATCH) then
		self:ProcessDailyMsg(tb8RankInfo);
	-- 表示传过来的是8强赛名单
	elseif (nState == Wlls.DEF_STATE_ADVMATCH) then
		self:ProcessAdv8Rank(tb8RankInfo);
	-- 表示八强赛已经结束
	elseif (nState == Wlls.DEF_STATE_REST) then
		self:ProcessFinal8Rank(tb8RankInfo);
	end
end

function GbWlls:ProcessDailyMsg(tb8RankInfo)
	if (not tb8RankInfo) then
		return 0;
	end
	local nSession	= tb8RankInfo.nSession;
	local nMapType	= tb8RankInfo.nMapType;
	local nState	= tb8RankInfo.nState;
	
	local nMatchType	= GbWlls:GetMacthType(nSession);
	local tbMatchCfg	= GbWlls:GetMacthTypeCfg(nMatchType);
	
	if (not tbMatchCfg) then
		return 0;
	end
	
	if (not nSession or not nMapType or not nState) then
		return 0;
	end
	
	-- 门派赛的话
	if (nMapType == Wlls.MAP_LINK_TYPE_FACTION) then
		local szTime	= os.date("%Y年%m月%d日", GetTime());
		local szMsg = string.format("<color=yellow>%s    本服%s循环赛战报：<color>\n\n", szTime, tbMatchCfg.szName);
		for i, tbInfo in pairs(tb8RankInfo.tbInfo) do
			if (tbInfo) then
				local szFaction = Player:GetFactionRouteName(i);
				for j, tbLeagueInfo in ipairs(tbInfo) do
					if (j > 3) then
						break;
					end
					local szInfo = "";
					local szInfo2 = "";
					local tbDetailInfo	= tbLeagueInfo.tbInfo;
					local szLeagueName	= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_LEAGUENAME];
					local nRank 		= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_RANK];
					local nGateWay 		= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_GATEWAY];
					local nNowGateWay	= self:GetGetWay2Num();
					if (nGateWay == nNowGateWay and nNowGateWay > 0) then
						local szMemberMsg = "";
						if (tbLeagueInfo.tbList) then
							for k, tbPlayerInfo in ipairs(tbLeagueInfo.tbList) do
								if (k > 1) then
									szMemberMsg = szMemberMsg .. "，";
								end
								szMemberMsg = szMemberMsg .. tbPlayerInfo[1];
							end
						end
						szInfo = string.format("战队名  ：%s\n参赛门派：%s；\n战队成员：%s\n名次    ：%s", szLeagueName, szFaction, szMemberMsg, nRank);
						szInfo2 = string.format("战队名：%s；参赛门派：%s；战队成员：%s；名次：%s。", szLeagueName, szFaction, szMemberMsg, nRank);
						szMsg = szMsg .. szInfo .. "\n\n";
						Dialog:GlobalNewsMsg_GC(szInfo2);
					end
				end
			end
		end
		local nKey		= Task.tbHelp.NEWSKEYID.NEWS_GBWLLS_DAILY;
		local szTitle	= string.format("第%s届跨服联赛每日战报", Lib:Transfer4LenDigit2CnNum(nSession));
		local nAddTime	= GetTime();
		local nEndTime	= nAddTime + 3600 * 24 * 1;	
		Task.tbHelp:AddDNews(nKey, szTitle, szMsg, nEndTime, nAddTime);
		return 0;
	end
	
	if (nMapType == Wlls.MAP_LINK_TYPE_RANDOM) then
		local szTime	= os.date("%Y年%m月%d日", GetTime());
		local szMsg = string.format("<color=yellow>%s    本服%s循环赛战报：<color>\n\n", szTime, tbMatchCfg.szName);
		local tbInfo 	= tb8RankInfo.tbInfo;
		
		if (tbInfo) then
			for j, tbLeagueInfo in ipairs(tbInfo) do
				if (j > 3) then
					break;
				end
				local szInfo = "";
				local szInfo2 = "";
				local tbDetailInfo	= tbLeagueInfo.tbInfo;
				local szLeagueName	= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_LEAGUENAME];
				local nRank 		= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_RANK];
				local nGateWay 		= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_GATEWAY];
				local nNowGateWay	= self:GetGetWay2Num();
				if (nGateWay == nNowGateWay and nNowGateWay > 0) then
					local szMemberMsg = "";
					if (tbLeagueInfo.tbList) then
						for k, tbPlayerInfo in ipairs(tbLeagueInfo.tbList) do
							if (k > 1) then
								szMemberMsg = szMemberMsg .. "，";
							end
							szMemberMsg = szMemberMsg .. tbPlayerInfo[1];
						end
					end
					szInfo = string.format("战队名  ：%s\n战队成员：%s\n名次    ：%s", szLeagueName, szMemberMsg, nRank);
					szInfo2 = string.format("战队名：%s；战队成员：%s；名次：%s。", szLeagueName, szMemberMsg, nRank);
					szMsg = szMsg .. szInfo .. "\n\n";
					Dialog:GlobalNewsMsg_GC(szInfo2);
				end
			end
		end

		local nKey		= Task.tbHelp.NEWSKEYID.NEWS_GBWLLS_DAILY;
		local szTitle	= string.format("第%s届跨服联赛每日战报", Lib:Transfer4LenDigit2CnNum(nSession));
		local nAddTime	= GetTime();
		local nEndTime	= nAddTime + 3600 * 24 * 1;	
		Task.tbHelp:AddDNews(nKey, szTitle, szMsg, nEndTime, nAddTime);
		return 0;
	end	
end

function GbWlls:ProcessAdv8Rank(tb8RankInfo)
	if (not tb8RankInfo) then
		return 0;
	end
	local nSession	= tb8RankInfo.nSession;
	local nMapType	= tb8RankInfo.nMapType;
	local nState	= tb8RankInfo.nState;
	local nMatchType	= GbWlls:GetMacthType(nSession);
	local tbMatchCfg	= GbWlls:GetMacthTypeCfg(nMatchType);
	if (not tbMatchCfg) then
		return 0;
	end
	
	if (not nSession or not nMapType or not nState) then
		return 0;
	end
	local tbZoneInfo	= ServerEvent:GetMyServerInforByGateway();
	local szTime		= os.date("%Y年%m月", GetTime());
	-- 门派赛的话
	if (nMapType == Wlls.MAP_LINK_TYPE_FACTION) then
		local szMsg = string.format("<color=yellow>%s区%s八强\n\n决赛将于%s%s日举行<color>，大家快去跨服联赛助威鼓为他们送上祝福吧！\n\n", tbZoneInfo.ZoneName, tbMatchCfg.szName, szTime, self.DEF_ADV_PK_STARTDAY);
		local nFlagCount = 0;
		for i, tbInfo in pairs(tb8RankInfo.tbInfo) do
			if (tbInfo) then
				local szFaction = Player:GetFactionRouteName(i);
				szMsg = string.format("%s<color=green>%s门派八强名单：<color>\n", szMsg, szFaction);
				for j, tbLeagueInfo in ipairs(tbInfo) do
					local szInfo = "";
					local tbDetailInfo = tbLeagueInfo.tbInfo;
					local szLeagueName	= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_LEAGUENAME];
					local nRank 		= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_RANK];
					local nGateWay 		= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_GATEWAY];
					local tbGateInfo	= self:GetGateWayInfo(nGateWay);
					local szServerName	= tbGateInfo.ServerName or "";
					local szMemberMsg = "";
					if (tbLeagueInfo.tbList) then
						for k, tbPlayerInfo in ipairs(tbLeagueInfo.tbList) do
							if (k > 1) then
								szMemberMsg = szMemberMsg .. "，";
							end
							szMemberMsg = szMemberMsg .. tbPlayerInfo[1];
						end
					end
					szInfo = string.format("    <color=yellow>%s<color>（<color=orange>%s<color>）  ", szLeagueName, szServerName);
					nFlagCount = nFlagCount + 1;
--					szInfo = string.format("    所在服务器：%s；战队名：%s；参赛门派：%s；战队成员：%s；名次：%s。\n", szServerName, szLeagueName, szFaction, szMemberMsg, nRank);
					szMsg = szMsg .. szInfo;
					nFlagCount = nFlagCount + 1;
					if (nFlagCount >= 3) then
						szMsg = szMsg .. "\n";
						nFlagCount = 0;						
					end

					if (not tbLeagueInfo.nGuessCount) then
						tbLeagueInfo.nGuessCount = 0;
					end
				end
				szMsg = szMsg .. "\n\n";
			end
		end
		self.tb8RankInfo = tb8RankInfo;
		self:SaveGbWllsGbBuf(self.tb8RankInfo);
		local nKey		= Task.tbHelp.NEWSKEYID.NEWS_GBWLLS_DAILY;
		local szTitle	= string.format("第%s届跨服联赛八强赛名单", Lib:Transfer4LenDigit2CnNum(nSession));
		local nAddTime	= GetTime();
		local nEndTime	= nAddTime + 3600 * 24 * 2;	
		Task.tbHelp:AddDNews(nKey, szTitle, szMsg, nEndTime, nAddTime);
		return 0;
	end

	-- 门派赛的话
	if (nMapType == Wlls.MAP_LINK_TYPE_RANDOM) then
		local szMsg = string.format("<color=yellow>%s区%s八强\n\n决赛将于%s%s日举行<color>，大家快去跨服联赛助威鼓为他们送上祝福吧！\n\n", tbZoneInfo.ZoneName, tbMatchCfg.szName, szTime, self.DEF_ADV_PK_STARTDAY);
		local nFlagCount = 0;
		local tbInfo = tb8RankInfo.tbInfo;
		if (tbInfo) then
			for j, tbLeagueInfo in ipairs(tbInfo) do
				local szInfo = "";
				local tbDetailInfo = tbLeagueInfo.tbInfo;
				local szLeagueName	= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_LEAGUENAME];
				local nRank 		= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_RANK];
				local nGateWay 		= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_GATEWAY];
				local tbGateInfo	= self:GetGateWayInfo(nGateWay);
				local szServerName	= tbGateInfo.ServerName or "";
				local szMemberMsg = "";
				if (tbLeagueInfo.tbList) then
					for k, tbPlayerInfo in ipairs(tbLeagueInfo.tbList) do
						if (k > 1) then
							szMemberMsg = szMemberMsg .. "，";
						end
						szMemberMsg = szMemberMsg .. tbPlayerInfo[1];
					end
				end
				szInfo = string.format("    <color=yellow>%s<color>（<color=orange>%s<color>）  ", szLeagueName, szServerName);
				nFlagCount = nFlagCount + 1;
				szMsg = szMsg .. szInfo;
				nFlagCount = nFlagCount + 1;
				if (nFlagCount >= 3) then
					szMsg = szMsg .. "\n";
					nFlagCount = 0;						
				end

				if (not tbLeagueInfo.nGuessCount) then
					tbLeagueInfo.nGuessCount = 0;
				end
			end
			szMsg = szMsg .. "\n\n";
		end

		self.tb8RankInfo = tb8RankInfo;
		self:SaveGbWllsGbBuf(self.tb8RankInfo);
		local nKey		= Task.tbHelp.NEWSKEYID.NEWS_GBWLLS_DAILY;
		local szTitle	= string.format("第%s届跨服联赛八强赛名单", Lib:Transfer4LenDigit2CnNum(nSession));
		local nAddTime	= GetTime();
		local nEndTime	= nAddTime + 3600 * 24 * 2;	
		Task.tbHelp:AddDNews(nKey, szTitle, szMsg, nEndTime, nAddTime);
		return 0;
	end
end

function GbWlls:ProcessFinal8Rank(tb8RankInfo)
	if (not tb8RankInfo) then
		return 0;
	end
	local nSession	= tb8RankInfo.nSession;
	local nMapType	= tb8RankInfo.nMapType;
	local nState	= tb8RankInfo.nState;
	
	local nMatchType	= GbWlls:GetMacthType(nSession);
	local tbMatchCfg	= GbWlls:GetMacthTypeCfg(nMatchType);
	if (not tbMatchCfg) then
		return 0;
	end
	
	if (not nSession or not nMapType or not nState) then
		return 0;
	end
	
	-- 门派赛的话
	if (nMapType == Wlls.MAP_LINK_TYPE_FACTION) then
		local szMsg = string.format("<color=yellow>%s决赛战报<color>\n", tbMatchCfg.szName);
		local tbRank = {};
		local tbRankResult = {};
		tbRankResult.nSession = nSession;
		tbRankResult.nMapType = nMapType;
		for nFaction, tbInfo in pairs(tb8RankInfo.tbInfo) do
			if (tbInfo) then
				local szFaction = Player:GetFactionRouteName(nFaction);
				szMsg = string.format("%s    <color=green>%s门派最终排名：<color>\n", szMsg, szFaction);
				tbRank[nFaction] = {};
				for j, tbLeagueInfo in ipairs(tbInfo) do
					local szInfo = "";
					local tbDetailInfo = tbLeagueInfo.tbInfo;
					local szLeagueName	= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_LEAGUENAME];
					local nRank 		= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_RANK];
					local nGateWay 		= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_GATEWAY];
					local nAdvId		= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_ADVID];
					local tbGateInfo	= self:GetGateWayInfo(nGateWay);
					local szServerName	= tbGateInfo.ServerName or "";
					local szMemberMsg = "";
					if (tbLeagueInfo.tbList) then
						for k, tbPlayerInfo in ipairs(tbLeagueInfo.tbList) do
							if (k > 1) then
								szMemberMsg = szMemberMsg .. "，";
							end
							szMemberMsg = szMemberMsg .. tbPlayerInfo[1];
						end
					end
					szInfo = string.format("<color=yellow>名次：%s  服务器：%s  战队名：%s  成员：%s。<color>\n", nRank, szServerName, szLeagueName, szMemberMsg);
					szMsg = szMsg .. szInfo;
					if (not tbLeagueInfo.nGuessCount) then
						tbLeagueInfo.nGuessCount = 0;
					end
					tbRank[nFaction][j] = {szLeagueName, nAdvId};
				end
			end
		end
		tbRankResult.tbRank = tbRank;
		self:SendGbWllsFinal_GC(tbRankResult);
		local nKey		= Task.tbHelp.NEWSKEYID.NEWS_GBWLLS_DAILY;
		local szTitle	= string.format("第%s届跨服联赛终极战报", Lib:Transfer4LenDigit2CnNum(nSession));
		local nAddTime	= GetTime();
		local nEndTime	= nAddTime + 3600 * 24 * 30;	
		Task.tbHelp:AddDNews(nKey, szTitle, szMsg, nEndTime, nAddTime);
		return 0;
	end

	if (nMapType == Wlls.MAP_LINK_TYPE_RANDOM) then
		local szMsg = string.format("<color=yellow>%s决赛战报<color>\n", tbMatchCfg.szName);
		local tbRank = {};
		local tbRankResult = {};
		tbRankResult.nSession = nSession;
		tbRankResult.nMapType = nMapType;
		local tbInfo = tb8RankInfo.tbInfo;
		
		if (tbInfo) then
			local szFaction = Player:GetFactionRouteName(nFaction);
			szMsg = string.format("%s    <color=green>最终排名：<color>\n", szMsg);
			tbRank = {};
			for j, tbLeagueInfo in ipairs(tbInfo) do
				local szInfo = "";
				local tbDetailInfo = tbLeagueInfo.tbInfo;
				local szLeagueName	= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_LEAGUENAME];
				local nRank 		= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_RANK];
				local nGateWay 		= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_GATEWAY];
				local nAdvId		= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_ADVID];
				local tbGateInfo	= self:GetGateWayInfo(nGateWay);
				local szServerName	= tbGateInfo.ServerName or "";
				local szMemberMsg = "";
				if (tbLeagueInfo.tbList) then
					for k, tbPlayerInfo in ipairs(tbLeagueInfo.tbList) do
						if (k > 1) then
							szMemberMsg = szMemberMsg .. "，";
						end
						szMemberMsg = szMemberMsg .. tbPlayerInfo[1];
					end
				end
				szInfo = string.format("<color=yellow>名次：%s  服务器：%s  战队名：%s  成员：%s。<color>\n", nRank, szServerName, szLeagueName, szMemberMsg);
				szMsg = szMsg .. szInfo;
				if (not tbLeagueInfo.nGuessCount) then
					tbLeagueInfo.nGuessCount = 0;
				end
				tbRank[j] = {szLeagueName, nAdvId};
			end
		end

		tbRankResult.tbRank = tbRank;
		-- self:SendGbWllsFinal_GC(tbRankResult);
		local nKey		= Task.tbHelp.NEWSKEYID.NEWS_GBWLLS_DAILY;
		local szTitle	= string.format("第%s届跨服联赛终极战报", Lib:Transfer4LenDigit2CnNum(nSession));
		local nAddTime	= GetTime();
		local nEndTime	= nAddTime + 3600 * 24 * 30;	
		Task.tbHelp:AddDNews(nKey, szTitle, szMsg, nEndTime, nAddTime);
		return 0;
	end
end

function GbWlls:SendGbWllsFinal_GC(tbRankResult)
	if (not MODULE_GC_SERVER) then
		return 0;
	end
	if (not tbRankResult or not tbRankResult.nSession) then
		return 0;
	end
	if (not self.tb8RankInfo) then
		print("[Error] SendGbWllsFinal_GC is no tb8RankInfo");
		return 0;
	end
	if (tbRankResult.nMapType == Wlls.MAP_LINK_TYPE_FACTION) then
		for i, tbFaction in pairs(tbRankResult.tbRank) do
			if (self.tb8RankInfo.tbInfo and self.tb8RankInfo.tbInfo[i]) then
				for j, tbInfo in pairs(tbFaction) do
					local szName = tbInfo[1];
					for k, tbLeague in pairs(self.tb8RankInfo.tbInfo[i]) do
						local tbLInfo = tbLeague.tbInfo;
						if (tbLInfo and tbLInfo[1] and tbLInfo[1] == szName and szName ~= "") then
							tbLeague.tbInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_RANK] = j;
							tbLeague.tbInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_ADVRANK] = j;
							self.tb8RankInfo.tbInfo[i][k] = tbLeague;
						end
					end
				end
			end
		end
		self:SaveGbWllsGbBuf(self.tb8RankInfo);	
	end
	GlobalExcute({"GbWlls:SendGbWllsFinal_GS", tbRankResult});
	return 0;	
end

function GbWlls:SendGbWllsFinal_GS(tbRankResult)
	if (not tbRankResult or not tbRankResult.nSession) then
		return 0;
	end
	if (not GbWlls.tb8RankInfo) then
		return 0;
	end
	if (tbRankResult.nMapType == Wlls.MAP_LINK_TYPE_FACTION) then
		for i, tbFaction in pairs(tbRankResult.tbRank) do
			if (self.tb8RankInfo.tbInfo and self.tb8RankInfo.tbInfo[i]) then
				for j, tbInfo in pairs(tbFaction) do
					local szName = tbInfo[1];
					for k, tbLeague in pairs(self.tb8RankInfo.tbInfo[i]) do
						local tbLInfo = tbLeague.tbInfo;
						if (tbLInfo and tbLInfo[1] and tbLInfo[1] == szName and szName ~= "") then
							tbLeague.tbInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_RANK] = j;
							tbLeague.tbInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_ADVRANK] = j;
							self.tb8RankInfo.tbInfo[i][k] = tbLeague;
						end
					end
				end
			end
		end
	end
end

function GbWlls:GetGetWay2Num()
	local szGateway = GetGatewayName();
	local nNowGateWay = tonumber(string.sub(szGateway, 5, 8));
	return nNowGateWay;
end

function GbWlls:GetGateWayInfo(nGateWay)
	local szGateway	= tostring(nGateWay);
	local nLen		= string.len(szGateway);
	if (nLen < 4) then
		for i=1, 4 - nLen do
			szGateway = "0"..szGateway;
		end
	end
	szGateway = "gate" .. szGateway;
	return ServerEvent:GetServerInforByGateway(szGateway);
end

function GbWlls:Save8RankInfo()
	if (not MODULE_GC_SERVER) then
		return 0;
	end
	
	if (GbWlls:ServerIsCanJoinGbWlls() ~= 1) then
		return 0;
	end
	
	if (self.IsOpen ~= 1) then
		return 0;
	end
	
--	local nFlagState = GbWlls:GetGblWllsOpenState();
--	if (not nFlagState or nFlagState <= 0) then
--		return 0;
--	end

	if (self:CheckOpenMonth(GetTime()) == 0) then
		return 0;
	end
	
	GbWlls:SaveGbWllsGbBuf(self.tb8RankInfo);
end

function GbWlls:Load8RankInfo()
	if (GbWlls:ServerIsCanJoinGbWlls() ~= 1) then
		return 0;
	end
	
	if (self.IsOpen ~= 1) then
		return 0;
	end
	
--	local nFlagState = GbWlls:GetGblWllsOpenState();
--	if (not nFlagState or nFlagState <= 0) then
--		return 0;
--	end

	self.tb8RankInfo = GbWlls:LoadGbWllsGbBuf();

	if (self:CheckOpenMonth(GetTime()) == 0) then
		return 0;
	end

	if (MODULE_GC_SERVER and not GLOBAL_AGENT) then
		if (self.nTime_SaveGbWlls_TimerId and self.nTime_SaveGbWlls_TimerId > 0) then
			Timer:Close(self.nTime_SaveGbWlls_TimerId);
			self.nTime_SaveGbWlls_TimerId = 0;
		end
		self.nTime_SaveGbWlls_TimerId = Timer:Register(self.DEF_TIME_SAVE_GBWLLSBUF * Env.GAME_FPS, self.OnTimer_SaveGbWllsGbBuf, self);	
	end
end

function GbWlls:OnTimer_SaveGbWllsGbBuf()
	if (not MODULE_GC_SERVER or GLOBAL_AGENT) then
		self.nTime_SaveGbWlls_TimerId = 0;
		return 0;
	end

	if (GbWlls:ServerIsCanJoinGbWlls() ~= 1) then
		self.nTime_SaveGbWlls_TimerId = 0;
		return 0;
	end

	if (self:CheckOpenMonth(GetTime()) == 0) then
		self.nTime_SaveGbWlls_TimerId = 0;
		return 0;
	end

	if (self.IsOpen ~= 1) then
		self.nTime_SaveGbWlls_TimerId = 0;
		return 0;
	end
	
	local nFlagState = GbWlls:GetGblWllsOpenState();
	if (not nFlagState or nFlagState <= 0) then
		self.nTime_SaveGbWlls_TimerId = 0;
		return 0;
	end	

	if (self:GetGblWllsState() ~= self.DEF_STATE_ADVMATCH) then
		return;
	end
	
	self:Save8RankInfo();

	return;
end

function GbWlls:LoadGbWllsGbBuf()
	local tbData = GetGblIntBuf(GBLINTBUF_GBWLLS_FINALPLAYERLIST, 0) or {};
	return tbData;
end

function GbWlls:SaveGbWllsGbBuf(tbData)
	SetGblIntBuf(GBLINTBUF_GBWLLS_FINALPLAYERLIST, 0, 1, tbData);
end

function GbWlls:CheckFactionGbWllsGuess(pPlayer, nFaction, nLeagueIndex)
	local bResult = 0;
	if (not pPlayer) then
		return bResult, "投票对象出错，不能投票";
	end
	local szFaction = "";

	local nResultTaskId = 0;
	local nGuessFaction, nLeagueIdex = GbWlls:GetPlayerGbWllsGuessTask(pPlayer, GbWlls.TASKID_GUESS_PLAYER_FLAG1);
	if (nGuessFaction > 0) then
		local szFaction = Player:GetFactionRouteName(nGuessFaction);
		local nFlag = 0;
		if (nGuessFaction == nFaction and nLeagueIndex == nLeagueIdex) then
			nFlag = 2;
		end
		return nFlag, string.format("你已经投过%s门派八强里的人，不能再投票了！", szFaction);
	end

	szFaction = Player:GetFactionRouteName(nFaction);
	if (pPlayer.nFaction ~= nFaction) then
		return 0, string.format("你目前的门派不是%s，不能给这个门派投票！", szFaction);
	end

	nResultTaskId = GbWlls.TASKID_GUESS_PLAYER_FLAG1;

	return 1, nResultTaskId;
end

function GbWlls:SetPlayerGbWllsGuessTask(pPlayer, nTaskId, nFirstParam, nSecondParam)
	if (not pPlayer) then
		return 0;
	end
	local nFlag = 0;
	nFlag	= KLib.SetByte(0, 1, nFirstParam);
	nFlag	= KLib.SetByte(nFlag, 3, nSecondParam);
	pPlayer.SetTask(GbWlls.TASKID_GROUP, nTaskId, nFlag);
	return 1;
end

function GbWlls:GetPlayerGbWllsGuessTask(pPlayer, nTaskId)
	if (not pPlayer) then
		return;
	end
	local nFirstParam	= 0;
	local nSecondParam	= 0;
	local nTaskValue	= pPlayer.GetTask(GbWlls.TASKID_GROUP, nTaskId);
	nFirstParam		= KLib.GetByte(nTaskValue, 1);
	nSecondParam	= KLib.GetByte(nTaskValue, 3);
	return nFirstParam, nSecondParam;
end

function GbWlls:AddGuess8RankPlayer(szName, nClass, nLeagueIndex, nCount)
	if (not MODULE_GAMESERVER) then
		return 0;
	end
	local tbLeagueInfo = self:Get8RankLeagueInfo(nClass, nLeagueIndex);
	if (not tbLeagueInfo) then
		return 0;
	end
	local szLeagueName = tbLeagueInfo.tbInfo[self.DEF_INDEX_GBWLLS_8RANK_LEAGUENAME];
	GCExcute({"GbWlls:AddGuessTicket_GC", szLeagueName, nCount});
end

function GbWlls:UpdateMaxGuessTicketPlayer(szName)
	if (not szName) then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerByName(szName);
	if (not pPlayer) then
		return 0;
	end
	local nTotalCount = 0;
	nTotalCount = nTotalCount + GbWlls:GetPlayer8RankGuessTicket(pPlayer, GbWlls.TASKID_GUESS_PLAYER_COUNT1);
	if (nTotalCount <= 0) then
		return 0;
	end
	
	local nCurMaxCount = KGblTask.SCGetDbTaskInt(self.GTASK_MAX_GUESS_TICKET);
	if (nTotalCount > nCurMaxCount) then
		KGblTask.SCSetDbTaskStr(self.GTASK_MAX_GUESS_TICKET, szName);
		KGblTask.SCSetDbTaskInt(self.GTASK_MAX_GUESS_TICKET, nTotalCount);
	end
	return 1;
end

function GbWlls:Get8RankLeagueInfo(nClass, nSmallClass)
	if (not self.tb8RankInfo) then
		return;
	end
	if (not self.tb8RankInfo.nSession) then
		return;
	end
	
	local nMapType = self.tb8RankInfo.nMapType;

	if (nMapType == Wlls.MAP_LINK_TYPE_FACTION) then
		local tbData = self.tb8RankInfo.tbInfo;
		if (not tbData) then
			return;
		end
		
		local tbFaction = tbData[nClass];
		if (not tbFaction) then
			return;
		end
		
		if (not nSmallClass) then
			return tbFaction;
		end
		
		local tbLeagueInfo = tbFaction[nSmallClass];
		return tbLeagueInfo;
	end
	return;
end

function GbWlls:Get8RankGbWllsInfo()
	if (not self.tb8RankInfo) then
		return;
	end
	return self.tb8RankInfo.nSession, self.tb8RankInfo.nMapType, self.tb8RankInfo.nState, self.tb8RankInfo.tbInfo;
end

function GbWlls:GetPlayer8RankGuessTicket(pPlayer, nTaskId)
	if (not pPlayer) then
		return 0;
	end
	return pPlayer.GetTask(GbWlls.TASKID_GROUP, nTaskId);
end

function GbWlls:SetPlayer8RankGuessTicket(pPlayer, nTaskId, nCount)
	if (not pPlayer) then
		return 0;
	end
	pPlayer.SetTask(GbWlls.TASKID_GROUP, nTaskId, nCount);
	return 1;
end

function GbWlls:GetGuessAwardList(pPlayer)
	local tbAward = {};

	local tbOneAward = GbWlls:GetGuessAwardTable(pPlayer, self.TASKID_GUESS_PLAYER_FLAG1, self.TASKID_GUESS_PLAYER_COUNT1);
	if (tbOneAward) then
		table.insert(tbAward, tbOneAward);
	end

	return tbAward;
end

function GbWlls:GetGuessAwardTable(pPlayer, nTaskId, nCountTaskId)
	local tbAward = nil;
	local nClass, nLeagueIdex = GbWlls:GetPlayerGbWllsGuessTask(pPlayer, nTaskId);
	if (nClass > 0) then
		tbAward = {
			nClass		= nClass,
			nIndex		= nLeagueIdex,
			nMyCount	= self:GetPlayer8RankGuessTicket(pPlayer, nCountTaskId),
			nTaskFlagId	= nTaskId,
		};
	end
	return tbAward;
end

function GbWlls:GetTotalTicket(nClass, nIndex)
	if (not self.tb8RankInfo) then
		return 0;
	end
	if (not self.tb8RankInfo.nSession) then
		return 0;
	end
	
	local nMapType = self.tb8RankInfo.nMapType;

	if (nMapType == Wlls.MAP_LINK_TYPE_FACTION) then
		if (not self.tb8RankInfo.tbInfo) then
			return 0;
		end
		local tbFaction = self.tb8RankInfo.tbInfo[nClass];
		if (not tbFaction) then
			return 0;
		end
		local nCount = 0;
		for i, tbLeague in pairs(tbFaction) do
			nCount = nCount + tbLeague.nGuessCount or 0;
		end
		return nCount;
	end
	return 0;
end

function GbWlls:Clear8RankTaskValue(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	self:WriteLog("Clear8RankTaskValue", pPlayer.szName, "Clear All Ticket Value");
	self:SetPlayerGbWllsGuessTask(pPlayer, self.TASKID_GUESS_PLAYER_FLAG1, 0, 0);
	self:SetPlayer8RankGuessTicket(pPlayer, self.TASKID_GUESS_PLAYER_COUNT1, 0);
end

function GbWlls:ClearOld8RankInfo_GB()
	if (not GLOBAL_AGENT) then
		return 0;
	end
	self.tb8RankInfo = {};
	self:SaveGbWllsGbBuf(self.tb8RankInfo);
	GC_AllExcute({"GbWlls:ClearOld8RankInfo_GC"});
end

function GbWlls:ClearOld8RankInfo_GC()
	if (not MODULE_GC_SERVER) then
		return 0;
	end
	self.tb8RankInfo = {};
	self:SaveGbWllsGbBuf(self.tb8RankInfo);
	GlobalExcute({"GbWlls:ClearOld8RankInfo_GS"});
end

function GbWlls:ClearOld8RankInfo_GS()
	self.tb8RankInfo = {};
end

function GbWlls:ResetPlayer8RankGuessCount(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	local nLastGuessSession = pPlayer.GetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_GUESS_SESSION);
	local nNowSession		= GbWlls:GetGblWllsOpenState();
	if (nLastGuessSession == nNowSession) then
		return 0;
	end
	GbWlls:Clear8RankTaskValue(pPlayer)
	pPlayer.SetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_GUESS_SESSION, nNowSession);
	return 1;
end

function GbWlls:SendSystemMsg()
	if (not self.nTimeMsg_Count) then
		return 0;
	end
	if (self.nTimeMsg_Count > self.DEF_TIME_MSG_MAX_COUNT) then
		return 0;
	end
	
	if (GbWlls:ServerIsCanJoinGbWlls() ~= 1) then
		return 0;
	end
	
	if (self.IsOpen ~= 1) then
		return 0;
	end
	
	local nFlagState = GbWlls:GetGblWllsOpenState();
	if (not nFlagState or nFlagState <= 0) then
		return 0;
	end
	
	local nNowTime	= GetTime();
	local tbTime	= os.date("*t", nNowTime);

	local nStarTime	= KGblTask.SCGetDbTaskInt(GbWlls.GTASK_STARSERVERFLAG_TIME);
	local nNowDay	= Lib:GetLocalDay(nNowTime);
	local nStarDay	= Lib:GetLocalDay(nStarTime);
	local nOpenFlag = 0;
	local nDetDay	= nNowDay - nStarDay;
	if (nDetDay < 0) then
		nDetDay = 0;
	end
	
	local nMatchType	= self:GetMacthType(nFlagState);
	local tbMatchCfg	= self:GetMacthTypeCfg(nMatchType);
	local nMatchState	= GbWlls:GetGblWllsState();	
	
	if (self.DEF_STATE_REST == nMatchState and nStarTime > 0) then
		if (nDetDay >= 0 and nDetDay <= GbWlls.DEF_DAY_STARSERVER_1) then
			local nStarFlag = KGblTask.SCGetDbTaskInt(GbWlls.GTASK_STARSERVERFLAG);
			if (nStarFlag > 0) then
				local szZoneName = GbWlls:GetZoneNameAndServerName();
				local szMsg = string.format(GbWlls.MSG_MATCH_TIME_GLOBALMSG_STAR, Lib:Transfer4LenDigit2CnNum(nFlagState - 1), szZoneName);
				Dialog:GlobalMsg2SubWorld_GC(szMsg);
				self.nTimeMsg_Count = self.nTimeMsg_Count + 1;
				return;
			end
		end	
	end	

	if (self:CheckOpenMonth(nNowTime) == 0) then
		return 0;
	end

	if (self.DEF_STATE_MATCH == nMatchState) then
		local szMsg = string.format(GbWlls.MSG_MATCH_TIME_GLOBALMSG_COMMON, Lib:Transfer4LenDigit2CnNum(nFlagState), tbMatchCfg.szName, tbTime.month);
		Dialog:GlobalMsg2SubWorld_GC(szMsg);
	elseif (self.DEF_STATE_ADVMATCH == nMatchState) then
		local szMsg = string.format(GbWlls.MSG_MATCH_TIME_GLOBALMSG_ADV, Lib:Transfer4LenDigit2CnNum(nFlagState), GbWlls.DEF_ADV_PK_STARTDAY);
		Dialog:GlobalMsg2SubWorld_GC(szMsg);
	end
	self.nTimeMsg_Count = self.nTimeMsg_Count + 1;
	return;
end

function GbWlls:OnTimer_SendSystem_Msg()
	self.nTimeMsg_Count = 0;

	if (GbWlls:ServerIsCanJoinGbWlls() ~= 1) then
		return 0;
	end

	if (self.IsOpen ~= 1) then
		return 0;
	end

	local nFlagState = GbWlls:GetGblWllsOpenState();
	if (not nFlagState or nFlagState <= 0) then
		return 0;
	end

	self.nTimeMsg_TimerId = Timer:Register(self.DEF_TIME_MSG_TIME * Env.GAME_FPS, self.SendSystemMsg, self);
end

function GbWlls:StatLog_Statuary()
	local tbStatuary = Domain.tbStatuary.tbStatuData;
	for i, tbInfo in pairs(tbStatuary) do
		local tbPlayer = tbInfo.tbPlayerInfo;
		if (tbPlayer) then
			local szName	= tbPlayerInfo[Domain.tbStatuary.INFOID_PLAYERNAME];
			local nRevere	= tbPlayerInfo[Domain.tbStatuary.INFOID_REVERE];
			local nEndure	= tbPlayerInfo[Domain.tbStatuary.INFOID_ENDURE];
			local nAddTime	= tbPlayerInfo[Domain.tbStatuary.INFOID_ADDTIME];
			local nType		= tbPlayerInfo[Domain.tbStatuary.INFOID_EVENTTYPE];
			if (szName and szName ~= "" and nType >= 2000 and nType < 3000) then
				Dbg:WriteLogEx(Dbg.LOG_INFO, "GbWlls_Statuary_Info", szName, nRevere, nEndure, nAddTime, nType);
			end
		end		
	end
end

function GbWlls:Stat_GbWllsPlayer8League(nType)
	local tbLadder = GetShowLadder(Ladder:GetType(0, 3, 5, 0));
	if not tbLadder then
	    return -1;
	end
	local szMsg="";
	for i, tbPlayer in ipairs(tbLadder) do
	    if (i > 4) then
	        break;
	    end
	    local szLName=tbPlayer.szName;
	    local tbContext = Lib:SplitStr(tbPlayer.szContext, "\n");
	    szMsg = szMsg..i..":"..szLName;
	    for _, szStr1 in ipairs(tbContext) do
	        local tbText = Lib:SplitStr(szStr1, "|");
	        if (tbText and tbText[1]) then
	            szMsg = szMsg.."\t"..tbText[1];
	        end
	    end
	    szMsg = szMsg.."\n"
	end
	return szMsg;
end

function GbWlls:CheckStarServer()
	local nStarFlag = KGblTask.SCGetDbTaskInt(GbWlls.GTASK_STARSERVERFLAG);
	if (nStarFlag <= 0) then
		return 0;
	end
	local nStarTime	= KGblTask.SCGetDbTaskInt(GbWlls.GTASK_STARSERVERFLAG_TIME);
	local nNowTime	= GetTime();
	local tbTime	= os.date("*t", nNowTime);
	local nNowDay	= Lib:GetLocalDay(nNowTime);
	local nStarDay	= Lib:GetLocalDay(nStarTime);
	local nOpenFlag = 0;
	local nDetDay	= nNowDay - nStarDay;
	if (nDetDay <= 0) then
		return 0;
	end
	local nLastDay	= -1;
	if (1 == nStarFlag or 2 == nStarFlag) then
		nLastDay = GbWlls.DEF_DAY_STARSERVER_1;
	elseif (3 == nStarFlag) then
		nLastDay = GbWlls.DEF_DAY_STARSERVER_3;
	elseif (4 == nStarFlag) then
		nLastDay = GbWlls.DEF_DAY_STARSERVER_4;
	end
	
	if (nDetDay > nLastDay) then
		return 0;
	end
	return 1;
end

-- 向全局服务器发送本服投票结果
function GbWlls:Send8RankTickets()
	if (not MODULE_GC_SERVER) then
		return 0;
	end
	
	if (GLOBAL_AGENT) then
		return 0;
	end

	if (GbWlls:ServerIsCanJoinGbWlls() ~= 1) then
		return 0;
	end

	if (self.IsOpen ~= 1) then
		return 0;
	end

	local nFlagState = GbWlls:GetGblWllsOpenState();
	if (not nFlagState or nFlagState <= 0) then
		return 0;
	end
	
	if (not self.tb8RankInfo) then
		return 0;
	end
	
	local nMapType	= self.tb8RankInfo.nMapType;
	local nSession	= self.tb8RankInfo.nSession;
	if (not nMapType or not nSession or nSession <= 0) then
		return 0;
	end

	if (nSession ~= nFlagState) then
		return 0;
	end
	
	if (Wlls.MAP_LINK_TYPE_FACTION == nMapType) then
		local tbSendInfo = {};
		local tbTickets = {};
		local szGateWay = GetGatewayName();
		for nFaction, tbFaction in pairs(self.tb8RankInfo.tbInfo) do
			if (not tbTickets[nFaction]) then
				tbTickets[nFaction] = {};
			end
			for nRank, tbTeamInfo in pairs(tbFaction) do
				if (tbTeamInfo.tbInfo) then
					local szLeagueName	= tbTeamInfo.tbInfo[self.DEF_INDEX_GBWLLS_8RANK_LEAGUENAME];
					local nTotalCount	= tbTeamInfo.nGuessCount or 0;
					tbTickets[nFaction][nRank] = {szLName = szLeagueName, nTickets = nTotalCount};
					self:WriteLog("Send8RankTickets", szLeagueName, nTotalCount, szGateWay);
				end
			end
		end
		tbSendInfo = { 
			nMapType = nMapType, 
			nSession = nSession, 
			tbTickets = tbTickets 
		};
		GC_AllExcute({"GbWlls:Recv8RankTickets_GB", tbSendInfo, szGateWay})
	end
end

-- 接收各个服务器票数
function GbWlls:Recv8RankTickets_GB(tbRecvInfo, szGateWay)
	if (not GLOBAL_AGENT) then
		return 0;
	end
	
	if (not tbRecvInfo) then
		return 0;
	end
	
	local nSession = tbRecvInfo.nSession;
	local nMapType = tbRecvInfo.nMapType;
	local tbTickets = tbRecvInfo.tbTickets;
	
	if (not nSession or not nMapType or not tbTickets) then
		return 0;
	end
	
	local nFlagState = GbWlls:GetGblWllsOpenState();
	if (not nFlagState or nFlagState <= 0) then
		return 0;
	end
	
	if (nSession ~= nFlagState) then
		return 0;
	end
	
	if (not self.tbTicketInfo) then
		self.tbTicketInfo = {};
		self.tbTicketInfo.nSession = nSession;
		self.tbTicketInfo.nMapType = nMapType;
		self.tbTicketInfo.tbTickets	= {};
	else
		local nTbSession = self.tbTicketInfo.nSession;
		if (not nTbSession or nTbSession ~= nSession) then
			self.tbTicketInfo = {};
			self.tbTicketInfo.nSession = nSession;
			self.tbTicketInfo.nMapType = nMapType;
			self.tbTicketInfo.tbTickets	= {};
		end
	end
	
	if (Wlls.MAP_LINK_TYPE_FACTION == nMapType) then
		if (not self.tbTicketInfo.tbTickets) then
			self.tbTicketInfo.tbTickets = {};
		end
		for nFaction, tbFaction in pairs(tbTickets) do
			if (not self.tbTicketInfo.tbTickets[nFaction]) then
				self.tbTicketInfo.tbTickets[nFaction] = {};
			end
			local tbFac = self.tbTicketInfo.tbTickets[nFaction];
			for nRank, tbInfo in pairs(tbFaction) do
				if (tbInfo.szLName and tbInfo.szLName ~= "") then
					if (not tbFac[tbInfo.szLName]) then
						tbFac[tbInfo.szLName] = 0;
					end
					tbFac[tbInfo.szLName] = tbFac[tbInfo.szLName] + tbInfo.nTickets;
					self:WriteLog("Recv8RankTickets_GB", tbInfo.szLName, tbFac[tbInfo.szLName], tbInfo.nTickets, szGateWay);
				end
			end
			self.tbTicketInfo.tbTickets[nFaction] = tbFac;
		end
	end
end

local function _OnTicketSort(tbA, tbB)
	return tbA[2] > tbB[2];
end

function GbWlls:ProcessMoreTicketPlayer()
	if (not GLOBAL_AGENT) then
		return 0;
	end
	
	if (not self.tbTicketInfo) then
		return 0;
	end
	
	local nSession	= self.tbTicketInfo.nSession;
	local nMapType	= self.tbTicketInfo.nMapType;
	local tbTickets	= self.tbTicketInfo.tbTickets

	if (not nSession or not nMapType or not tbTickets) then
		return 0;
	end
	
	local nFlagState = GbWlls:GetGblWllsOpenState();
	if (not nFlagState or nFlagState <= 0) then
		return 0;
	end
	
	if (nSession ~= nFlagState) then
		return 0;
	end
	
	if (Wlls.MAP_LINK_TYPE_FACTION == nMapType) then
		local tbMoreTicketPlayer = {};
		for nFaction, tbFaction in pairs(tbTickets) do
			local tbList = {};
			for szName, nTickets in pairs(tbFaction) do
				if (szName and szName ~= "") then
					tbList[#tbList + 1] = {szName, nTickets};
				end
			end
			table.sort(tbList, _OnTicketSort);
			if (tbList[1] and tbList[1][1]) then
				local tbStar = {};
				local szFirstName = tbList[1][1];
				local nTickets = tbList[1][2];
				for _, tbInfo in ipairs(tbList) do
					if (nTickets ~= tbInfo[2]) then
						break;
					end
					if (tbInfo[2] > 0) then
						self:GiveMoreTicketTitleFlag(tbInfo[1]);
					end
				end
			end
		end
	end
end

function GbWlls:GiveMoreTicketTitleFlag(szLeagueName)
	if (not GLOBAL_AGENT) then
		return 0;
	end
	if (not szLeagueName) then
		return 0;
	end
	
	local nGateWay	= League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_GATEWAY);
	local nSession	= League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MSESSION);
	local tbMember	= League:GetMemberList(Wlls.LGTYPE, szLeagueName);
	if (not tbMember) then
		return 0;
	end

	local tbGateInfo	= self:GetGateWayInfo(nGateWay);
	local szZoneName	= "";
	if (tbGateInfo) then
		szZoneName	= tbGateInfo.ZoneName or "";
	end

	for _, szName in pairs(tbMember) do
		local szMsg = string.format(GbWlls.MSG_STARPLAYER, szName, szZoneName);
		self:SetPlayerSportTask(szName, GbWlls.GBTASKID_MATCH_DAILY_RESULT, nSession);
		self:WriteLog("GiveMoreTicketTitleFlag", szLeagueName, szName, szZoneName);
		Dialog:GlobalMsg2SubWorld_Center(szMsg);
	end
end

function GbWlls:_GetPlayerGbWllsInfo(szName)
	if (not szName) then
		return 0;
	end
	local szMsg="";
	for i=1,6 do
		szMsg = szMsg .. GbWlls:GetPlayerSportTask(szName, 2, i) .. ",";
	end
	return szMsg;	
end

-- 设置上次参加跨服联赛的最终排名和所参加的等级
function GbWlls:SetPlayerLastFinalRank(szPlayerName, nLevel, nRank)
	if (not szPlayerName or not nLevel or not nRank) then
		return 0;
	end
	local nValue = nLevel * 100000 + nRank;
	self:SetPlayerSportTask(szPlayerName, self.GBTASKID_MATCH_LAST_LEVEL_RANK, nValue);
	return 1;
end

-- 获取上次参加跨服联赛的最终排名和所参加的等级
function GbWlls:GetPlayerLasrFinalRank(szPlayerName)
	if (not szPlayerName) then
		return 0, 0;
	end
	local nValue = self:GetPlayerSportTask(szPlayerName, self.GBTASKID_MATCH_LAST_LEVEL_RANK) or 0;
	local nRank	= math.fmod(nValue, 100000);
	local nLevel = math.floor(nValue / 100000);
	return nLevel, nRank;
end

function GbWlls:OnQueryRank()
	local nSession = Wlls:GetMacthSession();
	if (nSession < GbWlls.DEF_OPENGBWLLSSESSION) then
		Dialog:Say("您所在的服务器还没进行过三届武林联赛，无法查询跨服武林联赛排名。");
		return 0;
	end
	
	local nLevel, nRank = GbWlls:GetPlayerLasrFinalRank(me.szName);
	if (nLevel <= 0) then
		Dialog:Say("目前没有记录上一次参加跨服联赛的联赛等级和排名！");
		return 0;
	end
	
	local tbLevelName = {"初级", "高级"};
	
	if (GbWlls:CheckOpenGoldenGbWlls() == 1) then
		tbLevelName = {"高级", "黄金"};
	end
	
	Dialog:Say(string.format("您上一次参加的跨服联赛情况：\n联赛等级是：<color=yellow>%s<color>\n联赛排名：第<color=yellow>%s<color>名", tbLevelName[nLevel], nRank));
	return 1;
end

function GbWlls:CheckOpenGoldenGbWlls()
	return self:GetGoldenGbWllsOpenFlag();
end

if (MODULE_GAMESERVER) then
	PlayerEvent:RegisterGlobal("OnLogin", GbWlls.OnLogin, GbWlls);
	ServerEvent:RegisterServerStartFunc(GbWlls.Load8RankInfo, GbWlls);
end

if (MODULE_GC_SERVER) then
	GCEvent:RegisterGCServerShutDownFunc(GbWlls.Save8RankInfo, GbWlls);
	GCEvent:RegisterGCServerStartFunc(GbWlls.Load8RankInfo, GbWlls);
end
