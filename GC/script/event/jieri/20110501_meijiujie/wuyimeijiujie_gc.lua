--
-- FileName: wuyimeijiujie_gc.lua
-- Author: hanruofei
-- Time: 2011/4/20 17:41
-- Comment:
--
if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\event\\jieri\\20110501_meijiujie\\wuyimeijiujie_gc_def.lua");

SpecialEvent.tbMeijiujie20110501 =  SpecialEvent.tbMeijiujie20110501 or {};
local tbMeijiujie20110501 = SpecialEvent.tbMeijiujie20110501;
tbMeijiujie20110501.bIsInEventTime = 0; -- 当时是否是刷了篝火后的喝酒跳舞时间内

-- 初始化
function tbMeijiujie20110501:Init()
	
	if self.bIsOpen ~= 1 then
		return;
	end
	
	local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
	if nNowTime > self.nEndTime then
		return;
	end
	
	--local nTaskId = KScheduleTask.AddTask("Meijiujie20110501", "SpecialEvent", "StartMeijiujie");
	--for _, v in pairs(self.tbTimes) do
	--	KScheduleTask.RegisterTimeTask(nTaskId, v[0], 0);
	--	KScheduleTask.RegisterTimeTask(nTaskId, v[1], 1);
	--end
end

function SpecialEvent:StartMeijiujie(bCallOrRemove)
	local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
	if nNowTime < tbMeijiujie20110501.nStartTime or nNowTime > tbMeijiujie20110501.nEndTime then
		return;
	end
	
	if bCallOrRemove == 0 then
		GlobalExcute{"SpecialEvent.tbMeijiujie20110501:CallEventNpc"};
	elseif bCallOrRemove == 1 then
		GlobalExcute{"SpecialEvent.tbMeijiujie20110501:RemoveEventNpc"};
	end
end

GCEvent:RegisterGCServerStartFunc(tbMeijiujie20110501.Init, tbMeijiujie20110501)


