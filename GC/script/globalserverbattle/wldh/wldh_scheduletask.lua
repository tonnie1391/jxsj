--武林大会
--比赛启动
--孙多良
--2008.09.18

if (not MODULE_GC_SERVER) then
	return 0;
end

-- 动态注册到时间任务系统
function Wldh:RegisterScheduleTask()
	if Wldh:CheckIsOpen() ~= 1 then
		return;
	end
	local nTaskId = KScheduleTask.AddTask("武林大会预赛单场比赛", "Wldh", "ScheduleCallOut_PreGameStart");
	assert(nTaskId > 0);
	for i, nDate in ipairs(self.STATE1_PRE_TIME) do
		KScheduleTask.RegisterTimeTask(nTaskId, nDate, i);
	end
	
	nTaskId = KScheduleTask.AddTask("武林大会预赛确定进入决赛名单", "Wldh", "ScheduleCallOut_PreGameFinalList");
	for i, nDate in ipairs(self.STATE1_PRE_FINIAL_TIME) do
		KScheduleTask.RegisterTimeTask(nTaskId, nDate, i);
	end
	
	nTaskId = KScheduleTask.AddTask("武林大会决赛开启", "Wldh", "ScheduleCallOut_FinalGameStart");
	for i, nDate in ipairs(self.STATE2_PRE_FINIAL_TIME) do
		KScheduleTask.RegisterTimeTask(nTaskId, nDate, i);
	end
	
	nTaskId = KScheduleTask.AddTask("武林大会阶段转换", "Wldh", "ScheduleCallOut_State");
	KScheduleTask.RegisterTimeTask(nTaskId, 0, 1);
end

function Wldh:ScheduleCallOut_State()
	local nType = self:GetState1GameType();
	if nType > 0 then
		Wldh:SetCurGameType(nType);
		return 0;
	end
	local nType = self:GetState2GameType();
	if nType > 0 then
		Wldh:SetCurGameType(nType);
		return 0;
	end
	Wldh:SetCurGameType(0);
end

function Wldh:ScheduleCallOut_PreGameStart(nSeries)
	Wldh:ScheduleCallOut_State();
	local nType, nIsFinial = self:GetCurGameType();
	if nType > 0 and nIsFinial == 0 then
		self:OnGameWaitStartGC(nType, 0);
		Timer:Register(Wldh.MACTH_TIME_UPDATA_RANK,  self.OnGameLeagueRank,  self, nType);
	end
end

function Wldh:ScheduleCallOut_PreGameFinalList(nSeries)
	local nType = self:GetState1FinalListType();
	if nType > 0 then
		--出该类型最终名单；
		self:GetAdvMacthListByLeague(nType, 1, 1);
		self:UpdateNewsFinalList(nType, 0);
	end
end

function Wldh:OnGameWaitStartGC(nType, nIsFinal)
	--Wldh:SetCurGameType(nType);
	Wldh:InitGameDateGC(nType, nIsFinal);
	self.tbReadyTimer[nType] = Timer:Register(self.MACTH_TIME_READY,  self.OnGamePkStartGC,  self, nType, nIsFinal);
	GlobalExcute{"Wldh:OnGameWaitStartGS", nType, nIsFinal};	
end

function Wldh:OnGamePkStartGC(nType, nIsFinal)
	--开启pk比赛mission。
	self.tbReadyTimer[nType] = 0;
	Wldh.AdvMatchState[nType] = nIsFinal;
	GlobalExcute{"Wldh:OnGamePkStartGS", nType, nIsFinal};	--初级大会
	return 0;
end

function Wldh:InitGameDateGC(nType, nIsFinal)
	if self.tbReadyTimer[nType] and self.tbReadyTimer[nType] > 0 then
		if Timer:GetRestTime(self.tbReadyTimer[nType]) > 0 then
			Timer:Close(self.tbReadyTimer[nType]);
			self.tbReadyTimer[nType] = 0;
		end
	end
	
	if nIsFinal == 1 then
		Wldh:LeagueRank(nType);
	end
	
	self.GroupList[nType] = {};
	self.GroupListTemp[nType] = {};
	local bNewCreate = 0;
	local bSyncGs = 0;
	if nIsFinal == 1 then
		bNewCreate = 1;
	end
	if nIsFinal > 0 then
		bSyncGs = 1;
	end
	self:GetAdvMacthListByLeague(nType, bSyncGs, bNewCreate);
	GlobalExcute{"Wldh:InitGameDateGS", nType, nIsFinal};
end

--更新排行
function Wldh:OnGameLeagueRank(nType)
	Wldh:LeagueRank(nType);
	return 0;
end

--开启决赛
function Wldh:ScheduleCallOut_FinalGameStart(nTaskId)
	Wldh:ScheduleCallOut_State();
	local nType, nFinal = self:GetCurGameType();
	if nType > 0 and nFinal == 1 then
		Wldh:GameAdvPkStart(nType, 1);
	end
end

--开启32强赛
function Wldh:GameAdvPkStart(nType, nTaskId)
	--启动下一场比赛计时器
	if nTaskId <= 0 or nTaskId > 8 then
		return 0;
	end
	if self.nAdvTimerId and nTaskId == 1 then
		Timer:Close(self.nAdvTimerId);
	end
	if nTaskId <= 7 then
		self.nAdvTimerId = Timer:Register(Wldh.MACTH_TIME_ADVMATCH,  self.GameAdvPkStart,  self, nType, (nTaskId + 1));
		self:OnGameWaitStartGC(nType, nTaskId);
	end
	self:UpdateNewsFinalList(nType, nTaskId);
	GlobalExcute{"Wldh:SyncAdvMatchUiList", nType};
	if nTaskId > Wldh.MACTH_TIME_ADVMATCH_MAX then
		Wldh:LeagueRank(nType, nil, 1);
		self.nAdvTimerId = nil;
	end
	return 0;
end

GCEvent:RegisterGCServerStartFunc(Wldh.RegisterScheduleTask, Wldh);
