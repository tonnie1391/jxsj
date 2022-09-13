
if not MODULE_GC_SERVER then
	return;
end
-- 动态注册到时间任务系统添加Call Boss任务
function Merchant:RegisterScheduleTask()
	local nTaskId = KScheduleTask.AddTask("Merchant_Call_Npc", "Merchant", "ScheduleCallOut");
	assert(nTaskId > 0);
	for i=0, 47 do
		-- 时间执行点注册
		local nTime = (math.ceil((i+1)/2) - 1)*100 + math.mod(i,2) * 30;
		KScheduleTask.RegisterTimeTask(nTaskId, nTime, (i+1));
	end
end

function Merchant:ScheduleCallOut()
	GlobalExcute{"Merchant:RandomCallNpc"};
end

Merchant:RegisterScheduleTask();
