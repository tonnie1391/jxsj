-- 文件名　：lingpaibaoxiang.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-04-29 17:26:12
-- 描  述  ：

SpecialEvent.LaborDay = SpecialEvent.LaborDay or {};
local LaborDay = SpecialEvent.LaborDay or {};

local tbItem = Item:GetClass("lingpaibaoxiang");
function tbItem:OnUse()	
	local nTime = tonumber(GetLocalDate("%H%M"));
	if nTime >= 1900 and nTime <= 2100 then
		GlobalExcute{"SpecialEvent.LaborDay:GetExpPoint",me.szName};
	end
	return Item:GetClass("randomitem"):SureOnUse(LaborDay.nLingpaibaoxiang, nil, nil, nil, nil, nil, nil, nil, nil, it);
end
