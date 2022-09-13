if not MODULE_GAMESERVER then
	return;
end

local tbItem = Item:GetClass("mijibox");

function tbItem:OnUse()
	if (me.nFaction <= 0) then
		Dialog:Say("请先加入门派。");
		return 0;
	end

	if (me.nRouteId <= 0) then
		Dialog:Say("请先选择门派路线。");
		return 0;
	end
	
	if (me.CountFreeBagCell() < 1) then
		Dialog:Say("背包空间已满，请清理出一个空间！");
		return 0;
	end
	
	local nMijiId = Npc.tbMenPaiNpc.tbFcts[me.nFaction].tbMiji[me.nRouteId];
	
	local pItem = me.AddItem(Item.EQUIP_GENERAL, 14, nMijiId, 1, -1);
	if (pItem) then
		Task:AutoEquip(pItem);
	end
	return 1;
end
