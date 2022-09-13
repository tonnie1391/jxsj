-- 文件名  : taskexp_item.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-08-05 09:17:28
-- 描述    : 

--隐藏道具
local tbItem = Item:GetClass("TaskExpItem");

function tbItem:OnUse()
	return 1;
end