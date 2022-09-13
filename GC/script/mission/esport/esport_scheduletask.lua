--武林联赛
--比赛启动
--孙多良
--2008.09.18

if (not MODULE_GC_SERVER) then
	return 0;
end

Require("\\script\\mission\\esport\\esport_def.lua");

-- 动态注册到时间任务系统每半小时执行一次;
function Esport:RegisterScheduleTask()
	
	if self:CheckState() == 0 then
		return 0;
	end
	
	local nTaskId = KScheduleTask.AddTask("Esport", "Esport", "ScheduleTask");
	assert(nTaskId > 0);
	for nTask, nTime in pairs(self.SNOWFIGHT_TIME_SCHTASK) do
		-- 时间执行点注册
		KScheduleTask.RegisterTimeTask(nTaskId, nTime, nTask);
	end
end

--开始报名
function Esport:ScheduleTask(nTask)
	if self:CheckState() == 1 then
		self:StartSignUp();
		GlobalExcute{"Esport:StartSignUp"};
	end
end

GCEvent:RegisterGCServerStartFunc(Esport.RegisterScheduleTask, Esport);
