-- 文件名　：dts_vote_item.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-10-12 17:17:23
-- 功能    ：原石宝箱

local tbItem = Item:GetClass("yuanshibaoxiang");

function tbItem:OnUse()
	if me.CountFreeBagCell() < 1 then
		return 0, "Hành trang không đủ chỗ trống1格，请清理下。";
	end
	local tbItem = Item.tbStone:RandomStone(2, 2);
	me.AddItem(unpack(tbItem));
	return 1;
end
