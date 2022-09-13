-- 文件名　：newserverevent_gc.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-11-09 17:17:42
-- 描述：新服固定活动gc

if not MODULE_GC_SERVER then
	return;
end


Require("\\script\\event\\newserverevent\\newserverevent_def.lua");

SpecialEvent.NewServerEvent =  SpecialEvent.NewServerEvent or {};
local NewServerEvent = SpecialEvent.NewServerEvent;


--活动是否在开启时间段
function NewServerEvent:IsEventOpen()
	local nHasOpenTime = TimeFrame:GetServerOpenDay();
	if nHasOpenTime > NewServerEvent.nEndDate then
		return 0;
	end
	return 1;
end


----------------------------家族活动相关-----------------------
--上次获取召唤令时间
function NewServerEvent:SetLastGetItemTime_GC(nKinId)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	cKin.SetLastGetCallBossTime(GetTime());
	GlobalExcute{"SpecialEvent.NewServerEvent:SetLastGetItemTime_GS",nKinId};
end


--设置当天获得令牌的个数
function NewServerEvent:SetFreeCallBossItemCount_GC(nKinId,nCount)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	if not nCount then
		nCount = 0;
	end
	cKin.SetFreeCallBossItemCount(nCount);
	GlobalExcute{"SpecialEvent.NewServerEvent:SetFreeCallBossItemCount_GS",nKinId,nCount};
end

--设置当天获得令牌的个数
function NewServerEvent:SetBuyCallBossItemCount_GC(nKinId,nCount)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	if not nCount then
		nCount = 0;
	end
	cKin.SetBuyCallBossItemCount(nCount);
	GlobalExcute{"SpecialEvent.NewServerEvent:SetBuyCallBossItemCount_GS",nKinId,nCount};
end

--设置当天召唤boss的次数
function NewServerEvent:SetCallBossCount_GC(nKinId,nCount)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	if not nCount then
		nCount = 0;
	end
	cKin.SetCallBossCount(nCount);
	GlobalExcute{"SpecialEvent.NewServerEvent:SetCallBossCount_GS",nKinId,nCount};
end

function NewServerEvent:ClearCallBossData_GC(nKinId)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	self:SetLastGetItemTime_GC(nKinId);
	self:SetFreeCallBossItemCount_GC(nKinId,0);
	self:SetBuyCallBossItemCount_GC(nKinId,0);
	self:SetCallBossCount_GC(nKinId,0);
end

--------------------------------------------------------------------
-------------------派利活动-----------------------------------------
local ANNOUNCE_BEFORE_STATE = 1;	--提前公告的state
local BEGIN_WELFARE_STATE = 2;	--开始活动的state
local BEGIN_ANNOUNCE_KINEVENT = 3;	--家族活动开始的公告

function NewServerEvent:OnWelFareInit()
	if NewServerEvent:IsEventOpen() ~= 1 then
		return 0;
	end
	local nTaskId = KScheduleTask.AddTask("NewServerEvent", "SpecialEvent", "OnNewServerEvent_WelFare_Start");
	KScheduleTask.RegisterTimeTask(nTaskId, NewServerEvent.nWelFareAnnounceBeforeTime,ANNOUNCE_BEFORE_STATE);
	KScheduleTask.RegisterTimeTask(nTaskId, NewServerEvent.nWelFareBeginTime,BEGIN_WELFARE_STATE);
	KScheduleTask.RegisterTimeTask(nTaskId, NewServerEvent.nCallKinBossTimeStart,BEGIN_ANNOUNCE_KINEVENT);
end


function SpecialEvent:OnNewServerEvent_WelFare_Start(nState)
	if NewServerEvent:IsEventOpen() ~= 1 then
		return 0;
	end
	if nState == ANNOUNCE_BEFORE_STATE then
		NewServerEvent:StartAnnounceBefore_GC();
	elseif nState == BEGIN_WELFARE_STATE then
		NewServerEvent:StartWelFare_GC();	
	elseif nState == BEGIN_ANNOUNCE_KINEVENT then
		NewServerEvent:StartAnnounceKinEvent_GC();
	end
end

function NewServerEvent:StartAnnounceKinEvent_GC()
	if NewServerEvent:IsEventOpen() ~= 1 then
		return 0;
	end
	GlobalExcute({"SpecialEvent.NewServerEvent:StartAnnounceKinEvent"});
end

function NewServerEvent:StartWelFare_GC()
	if NewServerEvent:IsEventOpen() ~= 1 then
		return 0;
	end
	GlobalExcute({"SpecialEvent.NewServerEvent:StartWelFare"});
end

function NewServerEvent:StartAnnounceBefore_GC()
	if NewServerEvent:IsEventOpen() ~= 1 then
		return 0;
	end
	GlobalExcute({"SpecialEvent.NewServerEvent:StartAnnounceBefore"});
end

GCEvent:RegisterGCServerStartFunc(NewServerEvent.OnWelFareInit,NewServerEvent);

