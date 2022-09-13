-- 文件名　：spreaderitem.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-10-11 20:22:30
-- 功能    ：奇珍阁消耗积分券

local tbItem = Item:GetClass("spreaderitem");

function tbItem:OnUse()				-- 放技能
	Spreader:IbShopAddConsume(5000, 1);
	me.Msg("恭喜您获得5000点奇珍阁消耗积分。");
	return 1;
end