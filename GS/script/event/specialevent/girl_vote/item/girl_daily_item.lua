-- 文件名　：girl_daily_item.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-04-23 10:45:20
-- 功能    ：

local tbItem = Item:GetClass("girl_daily_box");
tbItem.tbBox = {
	[1] = {18,1,1655,1, 30*24*60},
	[2] = {18,1,1659,1, 30*24*60},
	[3] = {1, 13, 176, 10, 15*24*60},
	}

function tbItem:OnUse()
	if me.CountFreeBagCell() < 3 then
		Dialog:Say("Hành trang không đủ ，需要3格背包空间。");
		return 0;
	end
	for _, tb in ipairs(self.tbBox) do
		local pItem = me.AddItem(tb[1], tb[2], tb[3], tb[4]);
		if pItem then
			me.SetItemTimeout(pItem, tb[5], 0);
		end
	end
	return 1;
end
