-- 文件名　：kingame_baoxiang.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-07-05 21:18:51
-- 描述：石鼓残卷

local tbItem = Item:GetClass("kingame_baoxiang");


function tbItem:OnUse()
	if me.CountFreeBagCell() < 3 then
		Dialog:Say("Hành trang không đủ chỗ trống，至少需要<color=yellow>3个<color>背包空间。");
		return 0;
	end
	return self:OpenBox(it.dwId);
end

function tbItem:OpenBox(nItemId)
	if me.CountFreeBagCell() < 3 then
		local szMsg = "Hành trang không đủ chỗ trống，至少需要<color=yellow>3个<color>背包空间。";
		Dialog:Say(szMsg);
		me.Msg(szMsg);
		return 0;
	end
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local tbRandomItem = Item:GetClass("randomitem");
	tbRandomItem:SureOnUse(216);
	tbRandomItem:SureOnUse(217);
 	tbRandomItem:SureOnUse(218);
	return 1;
end

