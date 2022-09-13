-- 文件名　：plantform_gc.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-20 20:54:18
-- 功能    ：无差别竞技

if (not MODULE_GC_SERVER) then
	return 0;
end

--进入准备场；
function NewEPlatForm:EnterReadyMap(tbPlayerId, szLeagueName, nMapId)
	local tbMacthCfg = self:GetMacthTypeCfg(self:GetMacthType());	
	local nEnterReadyId = self:GetReadyMapId(tbMacthCfg, nMapId, #tbPlayerId);
	if nEnterReadyId <= 0 then
		GlobalExcute{"NewEPlatForm:MapStateFull", tbPlayerId};
		return 0;
	end
	if not self.GroupList[nEnterReadyId][szLeagueName] then
		self.GroupList[nEnterReadyId][szLeagueName] = tbPlayerId;
		self.GroupList[nEnterReadyId].nLeagueCount = self.GroupList[nEnterReadyId].nLeagueCount + 1;
		self.GroupList[nEnterReadyId].nPlayerCount = self.GroupList[nEnterReadyId].nPlayerCount + #tbPlayerId;
	end	
	GlobalExcute{"NewEPlatForm:EnterReadyMap", tbPlayerId, szLeagueName, nEnterReadyId};
end

--获得准备场
function NewEPlatForm:GetReadyMapId(tbMacthCfg, nMapId, nPlayerCount)
	for nReadyId, nMapId in ipairs(tbMacthCfg.tbReadyMap) do
		if not self.GroupList[nReadyId] then
			self.GroupList[nReadyId] = {};
			self.GroupList[nReadyId].nLeagueCount = 0;
			self.GroupList[nReadyId].nPlayerCount = 0;
		end
		if (self.GroupList[nReadyId].nLeagueCount < self:GetPreMaxLeague() and self.GroupList[nReadyId].nPlayerCount + nPlayerCount <= self:GetPreMaxLeague()) then			
			return nReadyId;
		end
	end
	--准备场已满。
	KGblTask.SCSetDbTaskInt(self.GTASK_MACTH_MAP_STATE, 1)
	return 0;		
end

------------------------------------------------------------------------------------------------------------
-- 时间系统的设定可以由每个活动自己去决定
-- 动态注册到时间任务系统
function NewEPlatForm:RegisterScheduleTask()
	
	-- 时间系统可以完善成允许若干个未知的系统进行
	
	local nTaskId = KScheduleTask.AddTask("活动平台时间轴开启", "NewEPlatForm", "ScheduleCallOut_TimerFrame");
	assert(nTaskId > 0);
	KScheduleTask.RegisterTimeTask(nTaskId, 0, 1);

	local nTaskIdEx = KScheduleTask.AddTask("家族竞技排行榜", "NewEPlatForm", "OnUpLadder");
	assert(nTaskIdEx > 0);
	KScheduleTask.RegisterTimeTask(nTaskIdEx, 0005, 1);
	
	local tbCommon = self.CALEMDAR;
	
	local nRankSession	= self:GetMacthSession();
	local tbMCfg		= self:GetMacthTypeCfg(self:GetMacthType(nRankSession));
	if (tbMCfg) then
		local tbCfg			= tbMCfg.tbMacthCfg;		
		if (tbCfg and tbCfg.tbCommon and #tbCfg.tbCommon > 0) then
			tbCommon = tbCfg.tbCommon;
			self.CALEMDAR = tbCommon;
		end
	
		nTaskId = KScheduleTask.AddTask("活动平台[日常]", "NewEPlatForm", "ScheduleCallOut_Common");
		assert(nTaskId > 0);
		for nTaskSeriel, nTimeState in pairs(tbCommon) do
			KScheduleTask.RegisterTimeTask(nTaskId, nTimeState, nTaskSeriel);
		end	
	end
	self:OnUpLadder(-1)
end

--平时
function NewEPlatForm:ScheduleCallOut_Common(nTaskId)
	if (self:GetMatchState() ~= self.DEF_STATE_STAR) then
		return;
	end
	self:ScheduleCallOut(nTaskId);
end

--每周一改活动类型并且第一个周一开启活动，96天关闭活动
function NewEPlatForm:ScheduleCallOut_TimerFrame()	
	self:GameSessionChange();	
	self:SetMatchStart();
end

--每个时间掉用
function NewEPlatForm:ScheduleCallOut()
	if self:GetMacthSession() <= 0 then
		return 0;
	end	
	--如果不在比赛期
	if  self:GetMatchState() == self.DEF_STATE_STAR then
		self:GamePkStart();
		return 1;
	end	
	return 0;
end

--开启进比赛场
function NewEPlatForm:GamePkStart()
	if (self:GetMacthSession() <= 0) then
		return 0;
	end	
	local nWeek = tonumber(GetLocalDate("%w"));
	if not self.tbStartTime[nWeek] then
		return 0;
	end
	if self:GetMatchState() ~= self.DEF_STATE_STAR then
		return 0;
	end	
	self:InitGameDateGC();
	self.ReadyTimerId = Timer:Register(self.MACTH_TIME_READY,  self.OnGamePkStart,  self);
	GlobalExcute{"NewEPlatForm:GameStart", nTaskId};
end

--开启比赛
function NewEPlatForm:OnGamePkStart()
	--开启pk比赛mission。
	self.ReadyTimerId = 0;
	GlobalExcute{"NewEPlatForm:GamePkStart"};
	return 0;
end

--initGame
function NewEPlatForm:InitGameDateGC()
	if self.ReadyTimerId > 0 then
		if Timer:GetRestTime(self.ReadyTimerId) > 0 then
			Timer:Close(self.ReadyTimerId);
			self.ReadyTimerId = 0;
		end
	end	
	self.GroupList = {};
	KGblTask.SCSetDbTaskInt(self.GTASK_MACTH_MAP_STATE, 0);
	GlobalExcute{"NewEPlatForm:InitDate"};
end

-- 每日家族竞技排行榜处理
function NewEPlatForm:KinPlanFormToLadder(nKinId)
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return;
	end
	local nDayNow = tonumber(GetLocalDate("%Y%m%d"));
	if self.nLadderDay ~= nDayNow then
		self.tbLadderManager = {};
		self.tbLastLadderManager = {};
		self.nLadderDay = nDayNow;
	end
	local nMonthNow = tonumber(GetLocalDate("%m"));
	local nKinMonth = pKin.GetKinGameMonth();
	local nKinGrade = pKin.GetKinGameGrade();
	local nLastKinGrade = pKin.GetKinGameGradeLast();
	if math.fmod(nKinMonth, 12) + 1 == nMonthNow then	--上个月的就转换
		nLastKinGrade = nKinGrade;
		nKinGrade = 0;
	elseif nKinMonth ~= nMonthNow then	--不是上个月的也不相等，那都是0
		nLastKinGrade = 0;
		nKinGrade = 0;
	end
	local nIndex = #self.tbLadderManager + 1;
	self.tbLadderManager[nIndex] = self.tbLadderManager[nKinId] or {nKinId, nKinGrade};
	self.tbLastLadderManager[nIndex] = self.tbLastLadderManager[nKinId] or {nKinId, nLastKinGrade};
end

function NewEPlatForm:OnUpLadder(nFlag)
	local nMonthNow = tonumber(GetLocalDate("%m"));
	local nLastDayMonth = tonumber(os.date("%m", GetTime() - 24*3600));
	if nMonthNow == nLastDayMonth and (not nFlag or nFlag ~= -1) then	--跨月的0点刷一次排行榜
		return;
	end
	self.tbLadderManager = {};
	self.tbLastLadderManager = {};
	local nCount = 1;
	local cNextKin, nNextKin = KKin.GetFirstKin();
	while cNextKin and nCount < 2000000 do
		local nMonthNow = tonumber(GetLocalDate("%m"));
		local nKinMonth = cNextKin.GetKinGameMonth();
		local nKinGrade = cNextKin.GetKinGameGrade();
		local nLastKinGrade = cNextKin.GetKinGameGradeLast();
		if math.fmod(nKinMonth, 12) + 1 == nMonthNow then	--上个月的就转换
			nLastKinGrade = nKinGrade;
			nKinGrade = 0;
		elseif nKinMonth ~= nMonthNow then	--不是上个月的也不相等，那都是0
			nLastKinGrade = 0;
			nKinGrade = 0;
		end
		self.tbLadderManager[nCount] = {nNextKin, nKinGrade};
		self.tbLastLadderManager[nCount] = {nNextKin, nLastKinGrade};
		cNextKin, nNextKin = KKin.GetNextKin(nNextKin);
		nCount = nCount + 1; -- 防死循环
	end
	self:UpDateLadder();
end

--刷新
function NewEPlatForm:UpDateLadder()
	local function OnSort(tbA, tbB)
		return tbA[2] > tbB[2];
	end
	---------------------------------------------------------------
	table.sort(self.tbLadderManager, OnSort);
	self:SetRankData(self.tbLadderManager, "本月竞技榜", 0, Ladder.LADDER_CLASS_LADDER, Ladder.LADDER_TYPE_LADDER_EVENTPLANT, Ladder.LADDER_TYPE_LADDER_EVENTPLANT_CURTEAM);
	
	-----------------------------------------------------------------
	table.sort(self.tbLastLadderManager, OnSort);
	self:SetRankData(self.tbLastLadderManager, "上月竞技榜", 0, Ladder.LADDER_CLASS_LADDER, Ladder.LADDER_TYPE_LADDER_EVENTPLANT, Ladder.LADDER_TYPE_LADDER_EVENTPLANT_PRETEAM);
	GlobalExcute{"Ladder:RefreshLadderName"};
	self:OnRecConnectEvent(-1);
	return 0;
end

function NewEPlatForm:SetRankData(tbData, szTitle, nRankParam1, nRankParam2, nRankParam3, nRankParam4)
	local tbLadderInfo = {}
	local tbCAMP = 
		{
			[1]		= "宋方",
			[2]		= "金方",
			[3]		= "中立",
		}
	local nLadderType = Ladder:GetType(nRankParam1, nRankParam2, nRankParam3, nRankParam4);
	if GetShowLadder(nLadderType) then
		DelShowLadder(nLadderType);
	end
	--第一名积分都是0，没有刷的必要
	if not tbData or not tbData[1] or tbData[1][2] <= 0 then
		return;
	end
	if (0 == CheckShowLadderExist(nLadderType)) then
		AddNewShowLadder(nLadderType);
	end
	SetShowLadderName(nLadderType, szTitle, string.len(szTitle) + 1);
	for nRank, tbKinInfo in ipairs(tbData) do
		if nRank > 10 then
			break;
		end
		local pKin = KKin.GetKin(tbKinInfo[1]);
		if pKin then
			local nCamp = pKin.GetCamp();
			local nRegular, nSigned, nRetire = pKin.GetMemberCount();
			local nBelongTong = pKin.GetBelongTong();
			local szTongName = "所属帮会：";
			local cTong = KTong.GetTong(nBelongTong);
			if cTong then
				szTongName = "所属帮会：" .. cTong.GetName();
			end
			local szKinLeaderName = "";
			local nLeader = pKin.GetCaptain();
			local cMember = pKin.GetMember(nLeader);
			if cMember then
				local nPlayerId = cMember.GetPlayerId();
				szKinLeaderName = KGCPlayer.GetPlayerName(nPlayerId);
			end
			local tbMemberInfo = {
			dwImgType = 2,
			szName = pKin.GetName(),
			szTxt1 =  tbKinInfo[2],
			szTxt2 = string.format("阵营：%s", tbCAMP[nCamp] or ""),
			szTxt3 = string.format("成员：%s人", nRegular+nSigned+ nRetire),
			szTxt4 = string.format("族长：%s", szKinLeaderName),
			szTxt5 = szTongName,
			szTxt6 = "",
			szContext = "";
			};
			table.insert(tbLadderInfo, tbMemberInfo);
		end
	end
	SetShowLadder(nLadderType, szTitle, string.len(szTitle)+1, tbLadderInfo);
end

function NewEPlatForm:OnRecConnectEvent(nConnectId)
	--本月排行榜只要前1000名
	local tbConnectDate = {};
	for i =1, 1000 do
		if self.tbLadderManager[i] then
			table.insert(tbConnectDate, {self.tbLadderManager[i][1], self.tbLadderManager[i][2]});
		end
	end
	GSExcute(nConnectId, {"NewEPlatForm:LoadLadder_GS", tbConnectDate});
end

GCEvent:RegisterGCServerStartFunc(NewEPlatForm.RegisterScheduleTask, NewEPlatForm);
GCEvent:RegisterGCServerStartFunc(NewEPlatForm.ScheduleCallOut_TimerFrame, NewEPlatForm);
GCEvent:RegisterGS2GCServerStartFunc(NewEPlatForm.OnRecConnectEvent, NewEPlatForm);