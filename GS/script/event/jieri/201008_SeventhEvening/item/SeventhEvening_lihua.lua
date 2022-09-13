-- 文件名  : SeventhEvening_lihua.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-07-16 19:35:56
-- 描述    :  七夕礼花

local tbItem = Item:GetClass("Qx_lihua");

function tbItem:OnUse()	
	local nLevel = it.nLevel;
		
	if (1 == nLevel) then
		me.CastSkill(1595, 1, -1, me.GetNpc().nIndex);
	elseif (2 == nLevel) then
		me.CastSkill(1596, 1, -1, me.GetNpc().nIndex);
	end
	
	return 1;
end
