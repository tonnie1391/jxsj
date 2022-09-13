-- 2010-8-31 14:37:36
-- zhouchenfei
-- 中秋卷轴换宝箱

local tbItem = Item:GetClass("luckyzhongqiu");

function tbItem:OnUse()
	if (me.CountFreeBagCell() < 1) then
		Dialog:Say(string.format("Hành trang không đủ %s，请清理足够的背包空间后再来领取！", 1));
		return 0;
	end
	
	me.AddItemEx(18, 1, 1022, 1, {bForceBind=1});
	return 1;
end
