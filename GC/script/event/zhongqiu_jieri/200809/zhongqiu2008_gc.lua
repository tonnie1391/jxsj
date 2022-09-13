--王老吉活动
--孙多良
--2008.08.22

if (not MODULE_GC_SERVER) then
	return
end

Require("\\script\\event\\zhongqiu_jieri\\200809\\zhongqiu2008_def.lua")

local ZhongQiu2008 = SpecialEvent.ZhongQiu2008;

-- 动态注册到时间任务系统
function ZhongQiu2008:RegisterScheduleTask()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData < self.TIME_STATE[2] then
		local nTaskId = KScheduleTask.AddTask("2008中秋节活动", "SpecialEvent", "WangLaoJi_cheduleCallOut");
		assert(nTaskId > 0);
		KScheduleTask.RegisterTimeTask(nTaskId, 0, 1);
	end
end

--定时执行
function SpecialEvent:ZhongQiu2008_cheduleCallOut()
	local nTime = GetTime();
	local nData = tonumber(os.date("%Y%m%d", nTime));
	local nWeek = tonumber(os.date("%w", nTime))
	if nData < WangLaoJi.TIME_STATE[3] then
		SpecialEvent.ZhongQiu2008:SetNews();
	end
end

function ZhongQiu2008:SetNews()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData < self.TIME_STATE[2] then
		local nAddTime = Lib:GetDate2Time(math.floor(self.TIME_STATE[1]*10000));
		local nEndTime = Lib:GetDate2Time(math.floor(self.TIME_STATE[2]*10000));
		Task.tbHelp:SetDynamicNews(self.NEWS_INFO[1].nKey, self.NEWS_INFO[1].szTitle, self.NEWS_INFO[1].szMsg, nEndTime, nAddTime);
	end
end

--ZhongQiu2008:RegisterScheduleTask()
GCEvent:RegisterGCServerStartFunc(SpecialEvent.ZhongQiu2008.SetNews, SpecialEvent.ZhongQiu2008);
