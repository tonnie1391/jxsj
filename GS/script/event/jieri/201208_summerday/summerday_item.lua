-- 文件名　：summerday_item.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-07-13 16:21:55
-- 功能    ：盛夏道具

local tbItem  = Item:GetClass("summerevent2012_item");

function tbItem:OnUse()
	Dialog:Say("神秘盛夏活动敬请期待。")
	return 0;
end

