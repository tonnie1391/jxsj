-- 文件名　：lmfjitem.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-11-03 09:56:33
-- 描述：龙门飞剑item

local tbItem = Item:GetClass("lmfj_item_grass");

function tbItem:InitGenInfo()
	it.SetTimeOut(1,2 * 60 * 60);
	return {};
end