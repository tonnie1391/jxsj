-- 文件名　：201202_loverday_gc.lua
-- 创建者　：zhangjunjie
-- 创建时间：2012-02-08 10:33:48
-- 描述：gc

if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\event\\jieri\\201202_loverday\\201202_loverday_def.lua");

SpecialEvent.LoverDay2012 = SpecialEvent.LoverDay2012 or {};
local LoverDay2012 = SpecialEvent.LoverDay2012;


local ADD_NPC_STATE = 1;	--刷花灯
local NOTIFY_ROSE_LOVE = 2;
local NOTIFY_MATCH_DAY = 3;
local NOTIFY_MATCH_NIGHT = 4;	

function LoverDay2012:OnInit()
	local nTaskId = KScheduleTask.AddTask("LoverDay2012", "SpecialEvent", "OnLoverDayStart");
	KScheduleTask.RegisterTimeTask(nTaskId,self.nAddNpcTime,ADD_NPC_STATE);
	KScheduleTask.RegisterTimeTask(nTaskId,self.nRoseLoveBeginTime,NOTIFY_ROSE_LOVE);
	KScheduleTask.RegisterTimeTask(nTaskId,self.nLoveMatchBeginTimeDay,NOTIFY_MATCH_DAY);
	KScheduleTask.RegisterTimeTask(nTaskId,self.nLoveMatchBeginTimeNight,NOTIFY_MATCH_NIGHT);
end

function SpecialEvent:OnLoverDayStart(nState)
	if nState == ADD_NPC_STATE then
		LoverDay2012:AddNpc_GC();	--刷花灯
	elseif nState == NOTIFY_ROSE_LOVE then
		LoverDay2012:Notify_GC(1);	
	elseif nState == NOTIFY_MATCH_DAY or nState == NOTIFY_MATCH_NIGHT then
		LoverDay2012:Notify_GC(2);	
	end
end

function LoverDay2012:Notify_GC(nType)
	if self:IsEventOpen() ~= 1 then
		return 0;
	end
	if nType == 1 then
		GlobalExcute({"SpecialEvent.LoverDay2012:NotifyRoseLoveMsg_GS",nType});
	elseif nType == 2 then
		GlobalExcute({"SpecialEvent.LoverDay2012:NotifyMatchMsg_GS",nType});
	end
end

function LoverDay2012:AddNpc_GC()
	if self:IsEventOpen() ~= 1 then
		return 0;
	end
	GlobalExcute({"SpecialEvent.LoverDay2012:AddNpc_GS"});
end

if tonumber(os.date("%Y%m%d",GetTime())) <= LoverDay2012.nEndTime then
	GCEvent:RegisterGCServerStartFunc(LoverDay2012.OnInit,LoverDay2012);
end