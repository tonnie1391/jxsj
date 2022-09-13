-- 文件名　：taskboard.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-12-07 14:25:45
-- 功能    ：公告板-发布系统收集任务的

Require("\\script\\kin\\kinplant\\kinplant_def.lua");

if MODULE_GC_SERVER then
--随即任务
function KinPlant:RandSpecialTask()
	if tonumber(GetLocalDate("%w")) ~= self.nTaskFreshDay then
		return;
	end
	if #self.tbPlantWeekTask == 3 then
		local nTask1 = MathRandom(#self.tbPlantWeekTask[1]);
		local nTask2 = MathRandom(#self.tbPlantWeekTask[2]);
		local nTask3 = MathRandom(#self.tbPlantWeekTask[3]);
		local nWeakly =  tonumber(GetLocalDate("%W"));
		KGblTask.SCSetDbTaskInt(DBTASK_KINPLANT_TASK, nWeakly * 1000000 + nTask3*10000 + nTask2*100 + nTask1);
	end
	return;
end

--重启保护任务
function KinPlant:RepairTask()
	local nTaskInfo = KGblTask.SCGetDbTaskInt(DBTASK_KINPLANT_TASK);
	local nNowWeakly =  tonumber(GetLocalDate("%W"));
	local nWeakly = math.floor(nTaskInfo/1000000);
	local nWeak = tonumber(GetLocalDate("%w"));
	--周次不一致，且到了周1以后重启随即一个任务
	if nWeakly ~= nNowWeakly and (nWeak == 0 or nWeak >= self.nTaskFreshDay) and #self.tbPlantWeekTask == 3 then
		local nTask1 = MathRandom(#self.tbPlantWeekTask[1]);
		local nTask2 = MathRandom(#self.tbPlantWeekTask[2]);
		local nTask3 = MathRandom(#self.tbPlantWeekTask[3]);
		KGblTask.SCSetDbTaskInt(DBTASK_KINPLANT_TASK, nNowWeakly * 1000000 + nTask3*10000 + nTask2*100 + nTask1);
	end
end
end
