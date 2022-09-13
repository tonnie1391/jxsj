-- 文件名　：baijuwan.lua
-- 创建者　：FanZai
-- 创建时间：2007-12-25 09:14:32
-- 文件说明：白驹丸


local tbItem 	= Item:GetClass("baijuwan");

function tbItem:OnUse()
	Player.tbOffline:OnCastCoin(me, it.nLevel, 1, 1);
	return 1;
end
