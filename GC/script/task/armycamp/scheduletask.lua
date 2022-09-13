--gc执行
if not MODULE_GC_SERVER then
	return;
end

function Task:ArmyCamp_ScheduleTask()
	GlobalExcute({"Task.tbArmyCampInstancingManager:Annouce"});
end

local tbArmy = {};
-- 动态注册到时间任务系统
function tbArmy:RegisterScheduleTask()
	local nTaskId = KScheduleTask.AddTask("军营副本", "Task", "ArmyCamp_ScheduleTask");
	assert(nTaskId > 0);
	for i=0, 23 do
		-- 时间执行点注册
		local nTime = i * 100;
		KScheduleTask.RegisterTimeTask(nTaskId, nTime, (i+1));
	end
end

tbArmy:RegisterScheduleTask();