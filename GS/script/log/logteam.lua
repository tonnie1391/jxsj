-------------------------------------------------------------------
--File: logteam.lua
--Author: zhoupengfeng
--Date: 2010-8-9 15:26
--Describe: 参与活动队伍Log
-------------------------------------------------------------------

if MODULE_GAMESERVER then
---------------------------GC_SERVER_START----------------------

DataLog.tbLogTeam = DataLog.tbLogTeam or {};
local LogTeam = DataLog.tbLogTeam;

LogTeam.LOG_TIME_CYCLE			= 24 * 60 * 60;		-- Log日志周期：每天为一个周期 单位：s
LogTeam.LOG_MAX_NUM_CYCLE		= 24 * 6;			-- 每周期记录多少次 
LogTeam.LOG_MIN_INTERVAL		= 30;				-- 两次记录Log最小时间间隔 单位：s

function LogTeam:SetParam(nCycleTime, nMaxNum, nMinInterval)
	if (nCycleTime < nMaxNum * nMinInterval) then
		return;
	end
	self.LOG_TIME_CYCLE		= nCycleTime;
	self.LOG_MAX_NUM_CYCLE	= nMaxNum;
	self.LOG_MIN_INTERVAL	= nMinInterval;
	--print("修改成功："..self.LOG_TIME_CYCLE.." "..self.LOG_MAX_NUM_CYCLE.." "..self.LOG_MIN_INTERVAL.." ");
	Timer:Close(self.nTimerId);
	self:LogTeamStart();
end

function LogTeam:LoadConfigFile()
	local szConfigFile = "setting\\log\\team\\logmapid.txt";
	local tbFile = Lib:LoadTabFile(szConfigFile);
	if (not tbFile) then
		print("[LogTeam]Error 加载队伍Log配置文件失败！");
		return 0;
	else
		self.tbLogMap = {};
		for _, tbRow in pairs(tbFile) do
			-- 地图模板Id
			local nTemplateId = tonumber(tbRow.TemplateId);
			self.tbLogMap[nTemplateId] = 1;
		end
	end
	return 1;
end

function LogTeam:IsLoadedConfigFile()
	if (not self.tbLogMap) then
		return self:LoadConfigFile();
	end
	return 1;
end

-- 判断地图是否需要记录Log
function LogTeam:IsLogMap(nTemplateMapId)
	if ( 1 == self:IsLoadedConfigFile() and  1 == self.tbLogMap[nTemplateMapId]) then
		return 1;
	end
	return 0;
end

function LogTeam:OneTeamLog(nTeamId)
	if (not nTeamId) then
		return;
	end
	-- 【队伍参与活动】    地图模板ID    队伍ID    队员A，队员B，队员C，队员D，队员E，队员F
	local tbPlayerId, nMemberCnt = KTeam.GetTeamMemberList(nTeamId);
	local tbTeamMembers = {};
	for i, nPlayerId in pairs(tbPlayerId) do
		local pPlayer		= KPlayer.GetPlayerObjById(nPlayerId);
		if (pPlayer) then
			local nTemplateMapId = pPlayer.nTemplateMapId;
			if (1 == self:IsLogMap(nTemplateMapId)) then
				local szTeamMembers = tbTeamMembers[nTemplateMapId] or "";
				szTeamMembers = szTeamMembers .. pPlayer.szName .. ",";
				-- 一个队伍的成员可能在多个地图
				tbTeamMembers[nTemplateMapId] = szTeamMembers;
			end
		end
	end
	for nTemplateMapId, szTeamMembers in pairs(tbTeamMembers) do
		--print(GetLocalDate("%Y/%m/%d/%H/%M/%S").." 队伍："..nTemplateMapId.." "..nTeamId.." "..szTeamMembers);
		Dbg:WriteLog("队伍参与活动", nTemplateMapId, nTeamId, szTeamMembers);
	end
end

function LogTeam:LogTeams()
	local itor = KTeam.GetTeamItor();
	local nTeamId = itor.GetCurTeamId();
	
	while(nTeamId > 0) do
		self:OneTeamLog(nTeamId);
		nTeamId = itor.NextTeamId();
	end
end

function LogTeam:LogMark()
	self.nLogCount = self.nLogCount + 1;
end

-- 多少秒后，再一次记录Log
function LogTeam:GetTimerNextSleepTime()
	local nCurTime		= GetTime();
	
	-- 距离下一次周期，剩余的时间
	local nRemainTime	= self.LOG_TIME_CYCLE + self.nLogStartTimeCycle - nCurTime; 
	
	-- 本周期内还需要记录多少次Log
	local nRemainNum	= self.LOG_MAX_NUM_CYCLE - self.nLogCount;
	local nMinNeedTime	= (nRemainNum) * self.LOG_MIN_INTERVAL;
	
	local nSleepTime	= self.LOG_MIN_INTERVAL;	
	if (nRemainNum < 1) then
		-- Log任务完成后，剩余的时间
		if (nRemainTime > 0) then
			nSleepTime	= nRemainTime; 
		end
	elseif (1 == nRemainNum) then
		-- 本周期最后一次
		nSleepTime		= MathRandom(self.LOG_MIN_INTERVAL, nRemainTime);
	elseif (nMinNeedTime > 0 and nRemainTime > nMinNeedTime) then
		-- 将nSleepTime控制在[self.LOG_MIN_INTERVAL, 三倍平均时间]
		local nTimeAverage = nRemainTime / nRemainNum;	-- 平均时间
		local nRandNum	= 2;
		if (nRemainNum > 2) then
			nRandNum	= MathRandom(2, 3);
		end
		local nRandMax	= nTimeAverage * nRandNum;
		if (nRandMax > (nRemainTime - nMinNeedTime + self.LOG_MIN_INTERVAL)) then
			nRandMax	= nRemainTime - nMinNeedTime + self.LOG_MIN_INTERVAL;
		end
		if (nRandMax > self.LOG_MIN_INTERVAL) then
			nSleepTime	= MathRandom(self.LOG_MIN_INTERVAL, nRandMax);
		end
	end
	-- 防止出现负数
	if (nSleepTime <= 0) then
		nSleepTime = self.LOG_MIN_INTERVAL;
	end
	return nSleepTime;
end

-- 每10分钟，随机一个时间点，遍历所有指定地图
function LogTeam:LogTeam_Timer()
	if (self.nLogCount >= self.LOG_MAX_NUM_CYCLE) then
		-- 开始下一个周期
		self:Reset(self.LOG_TIME_CYCLE + self.nLogStartTimeCycle);
		--print("开始："..GetLocalDate("%Y/%m/%d/%H/%M/%S"));
		return self:GetTimerNextSleepTime() * Env.GAME_FPS;
	end
	self:LogTeams();
	self:LogMark();
	local nNextTime = self:GetTimerNextSleepTime();
	--print("现在时间："..GetLocalDate("%Y/%m/%d/%H/%M/%S").."  SleepTime: "..nNextTime);
	return nNextTime * Env.GAME_FPS;
end

function LogTeam:Reset()
	--self:PrintRandInfo();
	self.nLogCount = 0; 
	self.nLogStartTimeCycle = GetTime();
end

-- 
function LogTeam:LogTeamStart()
	-- Initialization
	self:Reset();
	self:LoadConfigFile();
	
	self.nTimerId = Timer:Register(1, self.LogTeam_Timer, self);
end


--GCEvent:RegisterGCServerStartFunc(LogTeam.LogTeamStart, LogTeam);
ServerEvent:RegisterServerStartFunc(LogTeam.LogTeamStart, LogTeam);

---------------------------GC_SERVER_END------------------------
end
