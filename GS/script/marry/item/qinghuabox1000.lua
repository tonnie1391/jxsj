-- 文件名　：qinghuabox.lua
-- 创建者　：furuilei
-- 创建时间：2010-01-07 15:43:42
-- 功能描述：婚礼道具（情花箱）

local tbItem = Item:GetClass("marry_qinghuabox1000");

function tbItem:OnUse()
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ chỗ trống.");
		return 0;
	end
	me.AddStackItem(Marry.ITEM_QINGHUA_ID[1], Marry.ITEM_QINGHUA_ID[2], Marry.ITEM_QINGHUA_ID[3], Marry.ITEM_QINGHUA_ID[4], nil, 1000);
	return 1;
end
