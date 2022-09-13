-- 文件名　：201201_springfestival_gc.lua
-- 创建者　：zhangjunjie
-- 创建时间：2012-01-03 16:07:00
-- 描述：gc

if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\event\\jieri\\201201_springfestival\\201201_springfestival_def.lua");

SpecialEvent.SpringFestival2012 = SpecialEvent.SpringFestival2012 or {};
local SpringFestival = SpecialEvent.SpringFestival2012;
local CHECK_ADD_LANTERN = 1;	--检测刷花灯
local BEGIN_NOTIFY_DAY = 2;
local BEGIN_NOTIFY_NIGHT = 3;

function SpringFestival:OnSpringFestivaInit()
	local nTaskId = KScheduleTask.AddTask("SpringFestival", "SpecialEvent", "OnSpringFestivalStart");
	KScheduleTask.RegisterTimeTask(nTaskId,self.nCheckAddLanternTime,CHECK_ADD_LANTERN);
	KScheduleTask.RegisterTimeTask(nTaskId,self.nBeginGetIngotTimeDay,BEGIN_NOTIFY_DAY);
	KScheduleTask.RegisterTimeTask(nTaskId,self.nBeginGetIngotTimeNight,BEGIN_NOTIFY_NIGHT);
end

function SpecialEvent:OnSpringFestivalStart(nState)
	if nState == CHECK_ADD_LANTERN then
		SpringFestival:AddLantern_GC();	--刷花灯
	elseif nState == BEGIN_NOTIFY_DAY or nState == BEGIN_NOTIFY_NIGHT then
		SpringFestival:NotifyMsg_GC();
	end
end

function SpringFestival:NotifyMsg_GC()
	if self:IsEventStep1Open() ~= 1 then
		return 0;
	end
	GlobalExcute({"SpecialEvent.SpringFestival2012:AnnounceIngotMsg"});
end

function SpringFestival:AddLantern_GC()
	if self:IsEventOpen() ~= 1 then
		return 0;
	end
	GlobalExcute({"SpecialEvent.SpringFestival2012:AddLantern_GS"});
end


if tonumber(os.date("%Y%m%d",GetTime())) <= SpringFestival.nStep1EndTime then
	GCEvent:RegisterGCServerStartFunc(SpringFestival.OnSpringFestivaInit,SpringFestival);
end