-- 文件名  : TaobaoCooperate_libao.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-09-07 15:01:44
-- 描述    : 淘宝合作活动 淘·礼包

local tbItem = Item:GetClass("TaobaoBox");

function tbItem:OnUse()	
	SpecialEvent.tbTaobaoCooperate:OnUse(it.dwId, me.nId, 1);
end
