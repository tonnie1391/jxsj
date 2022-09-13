-- 文件名　：xiakedaily_gc.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-03-08 16:10:10
-- 描  述  ：

if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\task\\xiakedaily\\xiakedaily_def.lua")

function XiakeDaily:RefreshTask(nSeg, nDiff)
	nDiff = nDiff or 0;	-- 用来处理停服或第一次随任务导致的日期差
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));-- 用了具体的日期，使用很繁琐，注意使用Lib:GetLocalDay()来存储日期
	if nDiff > 0 then
		nNowDate = tonumber(os.date("%Y%m%d", GetTime() - nDiff * 24 * 3600));
	end
	local nTaskDay = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TASK_DAY);
	if nTaskDay < nNowDate then	-- 随机明日的两个任务
		if Lib:GetLocalDay(Lib:GetDate2Time(nTaskDay)) < Lib:GetLocalDay(Lib:GetDate2Time(nNowDate)) - 1 then -- 没有今日任务则先随今日任务放到明日任务变量中
			local nWeek = math.mod(GetLocalDate("%w") - nDiff + 7, 7);
			local nTask1, nTask2 = self:RandomTask(nWeek);
			KGblTask.SCSetDbTaskInt(DBTASK_XIAKEDAILY_TOMORROW_TASK_ID1, nTask1);
			KGblTask.SCSetDbTaskInt(DBTASK_XIAKEDAILY_TOMORROW_TASK_ID2, nTask2);
		end
		local nWeek = math.mod(GetLocalDate("%w") - nDiff + 8, 7);
		local nTaskId1, nTaskId2 = self:RandomTask(nWeek);
		local nTodayTask1 = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TOMORROW_TASK_ID1);
		local nTodayTask2 = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TOMORROW_TASK_ID2);
		KGblTask.SCSetDbTaskInt(DBTASK_XIAKEDAILY_TASK_DAY, nNowDate);
		KGblTask.SCSetDbTaskInt(DBTASK_XIAKEDAILY_TASK_ID1, nTodayTask1);
		KGblTask.SCSetDbTaskInt(DBTASK_XIAKEDAILY_TASK_ID2, nTodayTask2);
		KGblTask.SCSetDbTaskInt(DBTASK_XIAKEDAILY_TOMORROW_TASK_ID1, nTaskId1);
		KGblTask.SCSetDbTaskInt(DBTASK_XIAKEDAILY_TOMORROW_TASK_ID2, nTaskId2);
	end
end

function XiakeDaily:RandomTask(nWeek)
	local tbTaskType = self.RANDOM_TYPEID[nWeek];
		local nMath1 = MathRandom(1, #self.TYPE_FUBENID[tbTaskType[1]]);
		local nMath2 = MathRandom(1, #self.TYPE_FUBENID[tbTaskType[2]]);
		local nTaskId1 = self.TYPE_FUBENID[tbTaskType[1]][nMath1];
		local nTaskId2 = self.TYPE_FUBENID[tbTaskType[2]][nMath2];
		return nTaskId1, nTaskId2;
end

-- 启动时检查今日侠客任务变量是否正常
function XiakeDaily:CheckTask()
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	local nTaskDay = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TASK_DAY);
	local nNowTime = tonumber(GetLocalDate("%H%M%S"));
	if nTaskDay >= nNowDate then	-- 任务日期大于等于当前日期说明当前任务就是今日日常
		return 1;
	else
		if nNowTime >= self.REFRESH_TIME then	-- 今日过了3点直接随今日的任务
			self:RefreshTask();
		else
			if Lib:GetLocalDay(Lib:GetDate2Time(nTaskDay)) < Lib:GetLocalDay(Lib:GetDate2Time(nNowDate)) - 1 then -- 由于停服或第一次随
				self:RefreshTask(0, 1);	-- 未过3点先随前一天的
			end
		end
	end
end

---- 同步任务变量给gs
--function XiakeDaily:SynTaskValue_GC()
--	local nTaskDay = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TASK_DAY);
--	local nTask1 = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TASK_ID1);
--	local nTask2 = KGblTask.SCGetDbTaskInt(DBTASK_XIAKEDAILY_TASK_ID2);
--	GlobalExcute{"XiakeDaily:SynTaskValue_GS2", nTaskDay, nTask1, nTask2};
--end

GCEvent:RegisterGCServerStartFunc(XiakeDaily.CheckTask, XiakeDaily);
