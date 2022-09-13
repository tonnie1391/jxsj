--=================================================
-- 文件名　：nationnalday_gc.lua
-- 创建者　：furuilei
-- 创建时间：2010-08-23 14:23:05
-- 功能描述：2010国庆活动gc
--=================================================
if not MODULE_GC_SERVER then
	return;
end
Require("\\script\\event\\jieri\\2010_nationnalday\\nationnalday_base.lua")
SpecialEvent.tbNationnalDay = SpecialEvent.tbNationnalDay or {};
local tbEvent = SpecialEvent.tbNationnalDay or {};

-- 随机幸运地区
function tbEvent:RandomSpeArea()
	if (self:CheckOpenFlag() ~= self.STATE_OPEN) then
		return;
	end
	
	self.tbSpeArea = {};
	
	local tbTemp = {};
	for i = 1, self.COUNT_AREA do
		table.insert(tbTemp, i);
	end
	
	for i = 1, self.NUM_SPEAREA do
		local nIndex = MathRandom(1, #tbTemp);
		table.insert(self.tbSpeArea, tbTemp[nIndex]);
		table.remove(tbTemp, nIndex);
	end
end

function tbEvent:GetSpeAreaId()
	return MathRandom(1, self.COUNT_AREA);
end

function tbEvent:NewSpeArea()
	if (self:CheckOpenFlag() ~= self.STATE_OPEN) then
		return;
	end
	self:RandomSpeArea();
	self:SetSpeArea_2GblTask(self.tbSpeArea);
end

function SpecialEvent:NewSpeArea()
	SpecialEvent.tbNationnalDay:NewSpeArea();
end

function SpecialEvent:StartEvent_NationnalDay()
	if (tbEvent:CheckOpenFlag() ~= tbEvent.STATE_OPEN) then
		return;
	end
	local nTaskId = KScheduleTask.AddTask("随机每日福地", "SpecialEvent", "NewSpeArea");
	KScheduleTask.RegisterTimeTask(nTaskId, 0000, 1);
end

-- 注册gamecenter启动事件
--GCEvent:RegisterGCServerStartFunc(SpecialEvent.StartEvent_NationnalDay, SpecialEvent);
