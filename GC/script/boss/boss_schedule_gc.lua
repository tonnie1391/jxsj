-------------------------------------------------------------------
--File: boss_schedule_gc.lua
--Author: lbh
--Date: 2008-1-10 12:43
--Describe: 刷Boss脚本gamecenter端
-------------------------------------------------------------------
if not Boss then
	Boss = {};
elseif not MODULE_GC_SERVER then
	return;
end

-- 记录哪些Boss已被召出
if not Boss.tbUniqueBossCallOut then
	Boss.tbUniqueBossCallOut = {};
end

local SZ_FILE_BOSS_SCHEDULE =  "\\setting\\boss\\boss_schedule.ini";
Boss.tbScheduleCallout = {};
-- 加载泡泡设置文件
function Boss:LoadSchedule(szIniFile)
	self.tbScheduleCallout = {};
	local tbIniInfo = Lib:LoadIniFile(szIniFile);
	assert(tbIniInfo);
	-- 转换易读格式
	for szBossName, tbCallOutInfo in pairs(tbIniInfo) do
		local nTemplateId = tonumber(tbCallOutInfo["TemplateId"]);
		local nLevel = tonumber(tbCallOutInfo["Level"]);
		local nSeries = -1;
		if (tbCallOutInfo["Series"]) then
			nSeries = tonumber(tbCallOutInfo["Series"]);
		end
		local tbTime = {};
		local tbPlace = {};
		local nTimeIndex = 1;
		local szTimeKey = "Time_"..nTimeIndex;
		while (tbCallOutInfo[szTimeKey]) do
			local nTime = tonumber(tbCallOutInfo[szTimeKey]);
			if nTime >= 0 then
				table.insert(tbTime, nTime);
			end
			nTimeIndex = nTimeIndex + 1;
			szTimeKey = "Time_"..nTimeIndex;
		end 
		local nPlaceIndex = 1;
		local szPlaceKey = "Point_"..nPlaceIndex;
		while (tbCallOutInfo[szPlaceKey]) do
			table.insert(tbPlace, tbCallOutInfo[szPlaceKey]);
			nPlaceIndex = nPlaceIndex + 1;
			szPlaceKey = "Point_"..nPlaceIndex;
		end
		local tbNew = {};
		tbNew.nTemplateId = nTemplateId;
		tbNew.nLevel = nLevel;
		tbNew.nSeries = nSeries;
		tbNew.tbPlace = tbPlace;
		tbNew.tbTime = tbTime;
		table.insert(self.tbScheduleCallout, tbNew);
	end
end

-- 动态注册到时间任务系统添加Call Boss任务
function Boss:RegisterScheduleTask()
	local nTaskId = KScheduleTask.AddTask("CALL_BOSS", "Boss", "ScheduleCallOut");
	assert(nTaskId > 0);
	for i, tbCallOutInfo in ipairs(self.tbScheduleCallout) do
		-- 时间执行点注册
		for _, nTime in ipairs(tbCallOutInfo.tbTime) do
			KScheduleTask.RegisterTimeTask(nTaskId, nTime, i);
		end
	end
end

-- 只加载一次，不能通过Reload脚本的方式重新加载，必须重新启动
if not Boss._bInit_Schedule then
	Boss._bInit_Schedule = 1;
	Boss:LoadSchedule(SZ_FILE_BOSS_SCHEDULE);
	Boss:RegisterScheduleTask();
end

-- 时间点到时执行
function Boss:ScheduleCallOut(nSeqNum)
	local tbCallOutInfo = self.tbScheduleCallout[nSeqNum];
	if not tbCallOutInfo then
		return 0;
	end
	
	--时间轴访问是否开启.
	if tbCallOutInfo.nLevel == 55 then
		if TimeFrame:GetState("OpenBoss55") ~= 1 then
			return 0;
		end
	elseif tbCallOutInfo.nLevel == 75 then
		if TimeFrame:GetState("OpenBoss75") ~= 1 then
			return 0;
		end
	elseif tbCallOutInfo.nLevel == 95 then
		if TimeFrame:GetState("OpenBoss95") ~= 1 then
			return 0;
		end
	-- by zhangjinpin@kingsoft
	elseif tbCallOutInfo.nLevel == 120 then
		if TimeFrame:GetState("OpenBoss120") ~= 1 then
			return 0;
		end	
	end
		
	local nPlace = MathRandom(#tbCallOutInfo.tbPlace);
	local szPlace = tbCallOutInfo.tbPlace[nPlace];
	-- 召唤坐标
	local nMapId, nMapX, nMapY = self:TransPlace(szPlace);
	-- 召唤五行
	local nSeries = tbCallOutInfo.nSeries;
	if (nSeries < 0) then
		nSeries = - 1;
	end
	GlobalExcute{"Boss:DoCallOut", tbCallOutInfo.nTemplateId, tbCallOutInfo.nLevel, nSeries, nMapId, nMapX, nMapY};
	return 0;
end

-- 将字符串的地点转换成数据坐标
function Boss:TransPlace(szPlace)
	local nPos = string.find(szPlace, ",");
	local nMapId = tonumber(string.sub(szPlace, 1, nPos -1));
	local szPlace = string.sub(szPlace, nPos + 1);
	nPos = string.find(szPlace, ",");
	local nMapX = tonumber(string.sub(szPlace, 1, nPos - 1));
	nPos = string.find(szPlace, ",");
	local szPlace = string.sub(szPlace, nPos + 1);
	local nMapY = tonumber(szPlace);
	return nMapId, nMapX, nMapY;
end
