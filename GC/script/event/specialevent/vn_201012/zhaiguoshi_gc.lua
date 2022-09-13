-- 文件名  : zhaiguoshi.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-11-17 12:12:43
-- 描述    :  摘果实

--VN--

if (not MODULE_GC_SERVER) then
	return 0;
end

Require("\\script\\event\\specialevent\\vn_201012\\zhaiguoshi_def.lua");

-- 动态注册到时间任务系统每半小时执行一次;
function SpecialEvent:RegisterScheduleTask_VnZaiShu()
	if self:CheckState_VnZhaiGuoShi() == 0 then
		return 0;
	end	
	local nTaskId = KScheduleTask.AddTask("SpecialEvent", "SpecialEvent", "ScheduleTask_VnZaiShu");
	assert(nTaskId > 0);
	for nTask, nTime in ipairs(SpecialEvent.tbZaiGuoShi.tbTime) do
		-- 时间执行点注册
		KScheduleTask.RegisterTimeTask(nTaskId, nTime, nTask);
	end
end

--开始栽树
function SpecialEvent:ScheduleTask_VnZaiShu()
	if self:CheckState_VnZhaiGuoShi() == 1 then
		GlobalExcute{"SpecialEvent.tbZaiGuoShi:StartPlant"};
	end
end

function SpecialEvent:CheckState_VnZhaiGuoShi()
	local nNowData = tonumber(GetLocalDate("%Y%m%d"));
	if nNowData > SpecialEvent.tbZaiGuoShi.nEndTime then
		return 0;
	end
	return 1;
end

--GCEvent:RegisterGCServerStartFunc(SpecialEvent.RegisterScheduleTask_VnZaiShu, SpecialEvent);
