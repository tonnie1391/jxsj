--武林联赛
--比赛启动
--孙多良
--2008.09.18

if (not MODULE_GC_SERVER) then
	return 0;
end

Require("\\script\\mission\\wlls\\wlls_def.lua")

-- 动态注册到时间任务系统
function Wlls:RegisterScheduleTask()
	
	local nTaskId = KScheduleTask.AddTask("武林联赛时间轴开启", "Wlls", "ScheduleCallOut_TimerFrame");
	assert(nTaskId > 0);
	KScheduleTask.RegisterTimeTask(nTaskId, 0, 1);

	local tbWeekend = self.CALEMDAR.tbWeekend;
	local tbCommon = self.CALEMDAR.tbCommon;
	local tbAdvMatch = self.CALEMDAR.tbAdvMatch;
	
	local nRankSession	= Wlls:GetMacthSession();
	local tbMCfg		= Wlls:GetMacthTypeCfg(Wlls:GetMacthType(nRankSession));
	if (tbMCfg) then
		local tbCfg			= tbMCfg.tbMacthCfg;
		if (tbCfg and tbCfg.tbWeekend and #tbCfg.tbWeekend > 0) then
			tbWeekend = tbCfg.tbWeekend;
			self.CALEMDAR.tbWeekend = tbWeekend;
		end
		if (tbCfg and tbCfg.tbCommon and #tbCfg.tbCommon > 0) then
			tbCommon = tbCfg.tbCommon;
			self.CALEMDAR.tbCommon = tbCommon;
		end
		if (tbCfg and tbCfg.tbAdvMatch and #tbCfg.tbAdvMatch > 0) then
			tbAdvMatch = tbCfg.tbAdvMatch;
			self.CALEMDAR.tbAdvMatch = tbAdvMatch;
		end
	end

	nTaskId = KScheduleTask.AddTask("武林联赛[周末]", "Wlls", "ScheduleCallOut_Weekend");
	assert(nTaskId > 0);
	for nTaskSeriel, nTimeState in pairs(tbWeekend) do
		KScheduleTask.RegisterTimeTask(nTaskId, nTimeState, nTaskSeriel);
	end
	
	nTaskId = KScheduleTask.AddTask("武林联赛[日常]", "Wlls", "ScheduleCallOut_Common");
	assert(nTaskId > 0);
	for nTaskSeriel, nTimeState in pairs(tbCommon) do
		KScheduleTask.RegisterTimeTask(nTaskId, nTimeState, nTaskSeriel);
	end
	
	nTaskId = KScheduleTask.AddTask("武林联赛[八强]", "Wlls", "ScheduleCallOut_AdvMatch");
	assert(nTaskId > 0);
	KScheduleTask.RegisterTimeTask(nTaskId, tbAdvMatch[1], 1);

end

--周末
function Wlls:ScheduleCallOut_Weekend(nTaskId)
	local nWeek = tonumber(GetLocalDate("%w"));
	if Wlls.CALEMDAR.tbWeekDay[nWeek] then
		self:ScheduleCallOut(nTaskId);
	end
end

--平时
function Wlls:ScheduleCallOut_Common(nTaskId)
	local nWeek = tonumber(GetLocalDate("%w"));
	if Wlls.CALEMDAR.tbCommonDay[nWeek] then
		self:ScheduleCallOut(nTaskId);
	end
end

--八强赛
function Wlls:ScheduleCallOut_AdvMatch(nTaskId)
	if Wlls:GetMacthType() <= 0 then
		return 0;
	end
	
	--如果不在比赛期
	if Wlls:GetMacthState() ~= Wlls.DEF_STATE_ADVMATCH or Wlls:GetMatchStateForDate() ~= Wlls.DEF_STATE_ADVMATCH then
		return 0;
	end
	
	if Wlls:GetMacthSession() < self.MACTH_ADV_START_MISSION then
		return 0;
	end
	
	if (GLOBAL_AGENT) then
		local nTime		= GetTime();
		local tbTime	= os.date("*t", nTime);
		-- 八强赛有两天，如果不到那天就不开
		if (tbTime.day ~= GbWlls.DEF_ADV_PK_STARTDAY) then
			return 0;
		end
	end
	
	Wlls:Game8PkStart(1);
	
	return 0;
end

--开启八强赛
function Wlls:Game8PkStart(nTaskId)
	--启动下一场比赛计时器
	if nTaskId <= Wlls.MACTH_TIME_ADVMATCH_MAX then
		Timer:Register(Wlls.MACTH_TIME_ADVMATCH,  self.Game8PkStart,  self, (nTaskId + 1));
	end
	
	if nTaskId > 0 and nTaskId <= Wlls.MACTH_TIME_ADVMATCH_MAX then
		Wlls:GamePkStart(nTaskId);
	end
	
	if nTaskId > Wlls.MACTH_TIME_ADVMATCH_MAX then
		Wlls:GameState3Into1();
	end
	return 0;
end

--时间轴开启第一届
function Wlls:ScheduleCallOut_TimerFrame(nTaskId)
	
	if Wlls:GetTimeFrameState() ~= 1 then
		return;
	end
	
	--每周战报--
	if Wlls:GetMacthState() == Wlls.DEF_STATE_MATCH then
		Wlls:SendMatchDailyResult();
		if tonumber(GetLocalDate("%w")) == 1 then
			Wlls:UpdateHelpNews(Wlls:GetMacthSession());
		end
	end
	
	if (GLOBAL_AGENT) then
		GbWlls:SendJoinMail_Gb();
	end
	
	--开启联赛进入间歇期
	Wlls:GameState0Into1();
	
	--间歇期进入比赛期
	if Wlls:GetMatchStateForDate() == Wlls.DEF_STATE_MATCH then
		Wlls:GameState1Into2();
	end
	
	--比赛期进入八强赛期
	if Wlls:GetMatchStateForDate() == Wlls.DEF_STATE_ADVMATCH then
		Wlls:GameState2Into3();
	end
	
	--八强赛期进入最终结束间歇期
	if Wlls:GetMatchStateForDate() == Wlls.DEF_STATE_REST then
		Wlls:GameState3Into1();
	end
	
	--写战队历史log
	League:WriteFileHisory(self.LGTYPE, 1, 4, 5, 6, 7, 8, 17);
end

function Wlls:SendMatchDailyResult()
	if (not GLOBAL_AGENT) then
		return 0;
	end
	local nState	= Wlls:GetMacthState();
	local nSession	= Wlls:GetMacthSession();
	local nMapType	= Wlls:GetMacthLevelCfgType();
	Wlls:SendGbWlls_8RankInfo_Gb(nSession, nMapType, nState); -- 每日战报
end

function Wlls:ScheduleCallOut(nTaskId)
	if Wlls:GetMacthType() <= 0 then
		return 0;
	end
	
	--如果不在比赛期
	if Wlls:GetMacthState() ~= Wlls.DEF_STATE_MATCH or Wlls:GetMatchStateForDate() ~= Wlls.DEF_STATE_MATCH then
		return 0;
	end
	
	if (self.nTest_CloseOpen and self.nTest_CloseOpen == 1) then
		print("测试手动关闭自动开启联赛！");
		return 0;
	end
	
	Wlls:GamePkStart(0);
end

function Wlls:GamePkStart(nTaskId)
	Wlls:InitGameDateGC(nTaskId);
	self.ReadyTimerId = Timer:Register(self.MACTH_TIME_READY,  self.OnGamePkStart,  self, nTaskId);
	if (GLOBAL_AGENT) then
		local tbCfg = Wlls:GetMacthTypeCfg(Wlls:GetMacthType());
		local szName = "";
		if (tbCfg) then
			szName = tbCfg.szName;
		end
		if (nTaskId == 0) then
			local szAnncone = string.format("跨服武林联赛%s开始接受报名，玩家可以到临安跨服联赛报名官处进入英雄岛，再通过英雄岛的跨服联赛官员传送入场报名。", szName);
			-- 表示八强赛
			Dialog:GlobalNewsMsg_Center(szAnncone);
			Dialog:GlobalNewsMsg_GC(szAnncone);
		elseif (nTaskId >= 1) then
			if (self.nMsgTimerId and self.nMsgTimerId > 0) then
				Timer:Close(self.nMsgTimerId);
				self.nMsgTimerId = 0;
			end
			-- 如果是第一场八强赛开始了
--			if (GLOBAL_AGENT and 1 == nTaskId) then
--				GC_AllExcute({"GbWlls:Send8RankTickets"});
--			end
			self.nMsgTimerId = Timer:Register(Env.GAME_FPS * GbWlls.DEF_TIME_ADV_STARTMSG, self.Send8PkMsg, self, tbCfg.nMapLinkType);
		end
	end	
	GlobalExcute{"Wlls:GameStart", nTaskId};
end

function Wlls:SendOneMsg(nReadyId, tbLeague)
	if (not tbLeague) then
		return 0;
	end
	local szFormat = "<color=green>%s<color>赛区代表<color=green>%s<color>服的战队<color=green>%s<color>";
	local szMsg = "";
	if #tbLeague[2] > 0 then
		local nRank = 1;
		local nVsRank = 2;
		local szMsg  	= "<color=gray>无参赛队伍<color>";
		local szVsMsg	= "<color=gray>无参赛队伍<color>";
		local nFlag		= 0;
		if tbLeague[2][nRank] then
			local tbInfo = self:GetGateWayInfo(tbLeague[2][nRank].szName);
			local szServerName	= "无"
			local szZoneName	= "无"
			if (tbInfo) then
				szZoneName = tbInfo.ZoneName;
				szServerName = tbInfo.ServerName;
			end
			szMsg = string.format(szFormat, szZoneName, szServerName, tbLeague[2][nRank].szName);
			nFlag = nFlag + 1;
		end
		if tbLeague[2][nVsRank] then
			local tbInfo = self:GetGateWayInfo(tbLeague[2][nVsRank].szName);
			local szServerName	= "无"
			local szZoneName	= "无"
			if (tbInfo) then
				szZoneName = tbInfo.ZoneName;
				szServerName = tbInfo.ServerName;
			end					
			szVsMsg = string.format(szFormat, szZoneName, szServerName, tbLeague[2][nVsRank].szName);
			nFlag = nFlag + 1;
		end
		szMsg = string.format("%s即将与%s进行<color=red>决赛<color>，让我们拭目以待", szMsg, szVsMsg);
		if (nFlag > 0) then
			Dialog:GlobalNewsMsg_Center(szMsg);
			Dialog:GlobalNewsMsg_GC(szMsg);
		end	
	elseif #tbLeague[4] > 0 then
		for nRank=1, 2 do
			local nVsRank = nRank + 2;
			local szMsg  = "<color=gray>无参赛队伍<color>";
			local szVsMsg  = "<color=gray>无参赛队伍<color>";
			local nFlag	= 0;
			if tbLeague[4][nRank] then
				local tbInfo = self:GetGateWayInfo(tbLeague[4][nRank].szName);
				local szServerName	= "无"
				local szZoneName	= "无"
				if (tbInfo) then
					szZoneName = tbInfo.ZoneName;
					szServerName = tbInfo.ServerName;
				end
				szMsg = string.format(szFormat, szZoneName, szServerName, tbLeague[4][nRank].szName);
				nFlag = nFlag + 1;
			end
			if tbLeague[4][nVsRank] then
				local tbInfo = self:GetGateWayInfo(tbLeague[4][nVsRank].szName);
				local szServerName	= "无"
				local szZoneName	= "无"
				if (tbInfo) then
					szZoneName = tbInfo.ZoneName;
					szServerName = tbInfo.ServerName;
				end					
				szVsMsg = string.format(szFormat, szZoneName, szServerName, tbLeague[4][nVsRank].szName);
				nFlag = nFlag + 1;
			end
			szMsg = string.format("%s即将与%s进行<color=red>半决赛<color>，让我们拭目以待", szMsg, szVsMsg);
			if (nFlag > 0) then
				Dialog:GlobalNewsMsg_Center(szMsg);
				Dialog:GlobalNewsMsg_GC(szMsg);
			end
		end
	elseif #tbLeague[8] > 0 then
		for nRank=1, 4 do
			local nVsRank = 9 - nRank;
			local szMsg  = "<color=gray>无参赛队伍<color>";
			local szVsMsg  = "<color=gray>无参赛队伍<color>";
			local nFlag	= 0;
			if tbLeague[8][nRank] then
				local tbInfo = self:GetGateWayInfo(tbLeague[8][nRank].szName);
				local szServerName	= "无"
				local szZoneName	= "无"
				if (tbInfo) then
					szZoneName = tbInfo.ZoneName;
					szServerName = tbInfo.ServerName;
				end
				szMsg = string.format(szFormat, szZoneName, szServerName, tbLeague[8][nRank].szName);
				nFlag = nFlag + 1;
			end
			if tbLeague[8][nVsRank] then
				local tbInfo = self:GetGateWayInfo(tbLeague[8][nVsRank].szName);
				local szServerName	= "无"
				local szZoneName	= "无"
				if (tbInfo) then
					szZoneName = tbInfo.ZoneName;
					szServerName = tbInfo.ServerName;
				end					
				szVsMsg = string.format(szFormat, szZoneName, szServerName, tbLeague[8][nVsRank].szName);
				nFlag = nFlag + 1;
			end
			szMsg = string.format("%s即将与%s进行<color=red>4强争夺赛<color>，让我们拭目以待", szMsg, szVsMsg);
			if (nFlag > 0) then
				Dialog:GlobalNewsMsg_Center(szMsg);
				Dialog:GlobalNewsMsg_GC(szMsg);
			end
		end
	end
end

function Wlls:Send8PkMsg(nType)
	if nType == self.MAP_LINK_TYPE_FACTION then
		--未开发
		for nReadyId, tbLeague in pairs(Wlls.AdvMatchLists) do
			self:SendOneMsg(nReadyId, tbLeague);
		end
	elseif nType == self.MAP_LINK_TYPE_RANDOM then
		--未开发
		local nReadyId = 1;
		local tbLeague = Wlls.AdvMatchLists[nReadyId];
		self:SendOneMsg(nReadyId, tbLeague);
	else
		local szAnncone = string.format("跨服武林联赛开始接受报名，玩家可以到临安跨服联赛报名官处进入英雄岛，再通过英雄岛的跨服联赛官员传送入场报名。");
		-- 表示八强赛
		Dialog:GlobalNewsMsg_Center(szAnncone);
		Dialog:GlobalNewsMsg_GC(szAnncone);
	end
	self.nMsgTimerId = 0;
	return 0;
end

function Wlls:OnGamePkStart(nTaskId)
	--开启pk比赛mission。
	self.ReadyTimerId = 0;
	GlobalExcute{"Wlls:GamePkStart", Wlls.MACTH_PRIM};	--初级联赛
	
	if Wlls:GetMacthSession() >= self.MACTH_ADV_START_MISSION then
		GlobalExcute{"Wlls:GamePkStart", Wlls.MACTH_ADV};	--高级联赛
	end
	
	--刷新排行榜.
	if nTaskId == 0 then
		Timer:Register(Wlls.MACTH_TIME_UPDATA_RANK,  self.OnGameLeagueRank,  self);
	end
	return 0;
end

--更新排行
function Wlls:OnGameLeagueRank()
	Wlls:LeagueRank(0);
	return 0;
end

function Wlls:InitGameDateGC(nTaskId)
	if self.ReadyTimerId > 0 then
		if Timer:GetRestTime(self.ReadyTimerId) > 0 then
			Timer:Close(self.ReadyTimerId);
			self.ReadyTimerId = 0;
		end
	end	
	self.GroupList[Wlls.MACTH_PRIM] = {};
	self.GroupList[Wlls.MACTH_ADV] = {};
	self.GroupListTemp[Wlls.MACTH_PRIM] = {};
	self.GroupListTemp[Wlls.MACTH_ADV] = {};
	KGblTask.SCSetDbTaskInt(Wlls.GTASK_MACTH_MAP_STATE, 0);
	if tonumber(nTaskId) then
		Wlls.AdvMatchState	= nTaskId;
	end
	GlobalExcute{"Wlls:InitDate", nTaskId};
end

GCEvent:RegisterGCServerStartFunc(Wlls.RegisterScheduleTask, Wlls);
GCEvent:RegisterGCServerStartFunc(Wlls.ScheduleCallOut_TimerFrame, Wlls);
