local tbItem = Item:GetClass("freepifengfanhuan");

tbItem.HUNSHI_COUNT	= 200; --  赠送魂石的数量

function tbItem:OnUse()
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ <color=yellow>1<color> chỗ trống.");
		return 0;
	end
	local pEquip = me.GetEquip(Item.EQUIPPOS_MANTLE);
	if not pEquip then
		Dialog:Say("Chỉ khi mang 1 Phi phong bất kỳ mới có thể nhận thưởng.");
		return 0;
	end
	if me.GetTask(PlayerHonor.TSK_GIFT_GROUP, PlayerHonor.TSK_ID_GIFT_USEAWARD) == 0 then
		me.SetTask(PlayerHonor.TSK_GIFT_GROUP, PlayerHonor.TSK_ID_GIFT_USEAWARD, 1);
		me.AddStackItem(18, 1, 205, 1, {bForceBind=1}, self.HUNSHI_COUNT);
	else
		Dialog:Say("Đã nhận Ngũ Hành Hồn Thạch, mỗi nhân vật chỉ có thể nhận 1 lần.");
		return 0;
	end
	return 1;
end