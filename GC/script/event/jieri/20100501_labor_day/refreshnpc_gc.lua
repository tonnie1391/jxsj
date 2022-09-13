-- 文件名　：refreshnpa_gc.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-04-07 19:48:23
-- 描  述  ：

function SpecialEvent:AddToulanNpcGC()	
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData >= SpecialEvent.LaborDay.OpenTime and nData <= SpecialEvent.LaborDay.CloseTime then
		GlobalExcute({"SpecialEvent.LaborDay:AddDefender_GS"});
	end
end

-- clear npc
function SpecialEvent:ClearToulanNpcGC()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData >= SpecialEvent.LaborDay.OpenTime and nData <= SpecialEvent.LaborDay.CloseTime then
		GlobalExcute({"SpecialEvent.LaborDay:ClearDefender_GS"});
	end
end
