-- 文件名　：console_gs.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-04-23 10:04:41
-- 描  述  ：--控制台

if (not MODULE_GC_SERVER) then
	return 0;
end

function Console:ApplySignUp(nDegree, tbPlayerList)
	local nAttendMap = self:IsFull(nDegree, #tbPlayerList);
	if nAttendMap == 0 then
		GlobalExcute{"Console:SignUpFail", tbPlayerList};
		return 0;
	end
	self:JoinGroupList(nDegree, nAttendMap, tbPlayerList);
	GlobalExcute{"Console:JoinGroupList", nDegree, nAttendMap, tbPlayerList};
	GlobalExcute{"Console:SignUpSucess", nDegree, nAttendMap, tbPlayerList};
end

function Console:StartSignUp(nDegree)
	local tbBase = Console:GetBase(nDegree);
	tbBase:StartSignUp();
end

function Console:RegisterScheduleTask()
	if (not Console.tbConsole) then
		return 0;
	end
	for i, tbConsole in pairs(Console.tbConsole) do
		tbConsole:RegisterScheduleTask();
	end
end

function Console:RegisterScheduleTask_TimeTask(szTaskName, szTaskTable, szTaskFun, tbTimeList)
	if (not szTaskName or not szTaskTable or not szTaskFun or not tbTimeList) then
		print("[ERROR] Console   RegisterScheduleTask_TimeTask there is no value");
		return 0;
	end
	local nTaskId = KScheduleTask.AddTask(szTaskName, szTaskTable, szTaskFun);
	assert(nTaskId > 0);
	for nTaskSeriel, nTimeState in pairs(tbTimeList) do
		KScheduleTask.RegisterTimeTask(nTaskId, nTimeState, nTaskSeriel);
	end
end

GCEvent:RegisterGCServerStartFunc(Console.RegisterScheduleTask, Console);

