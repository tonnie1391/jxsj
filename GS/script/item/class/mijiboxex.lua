if not MODULE_GAMESERVER then
	return;
end

local tbItem = Item:GetClass("mijiboxex");

function tbItem:OnUse()
	if (me.nFaction <= 0) then
		Dialog:Say("Chưa có môn phái, không thể sử dụng!");
		return 0;
	end

	if (me.CountFreeBagCell() < 2) then
		Dialog:Say("Hành trang không đủ 2 ô trống!");
		return 0;
	end

	local nMiJiKind = tonumber(it.GetExtParam(1));

	for i=1, 2 do
		local nMijiId = (me.nFaction - 1) * 2 + i;
		local pItem = me.AddItem(Item.EQUIP_GENERAL, 14, nMijiId, nMiJiKind, -1);
		if (not pItem) then
			Dbg:WriteLog("mijiboxex", me.szName, "get failed");
		else
			pItem.Bind(1);
			pItem.Sync();
		end
	end
	return 1;
end 