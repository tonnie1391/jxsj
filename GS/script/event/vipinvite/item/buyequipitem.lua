  --
-- FileName: buyequipitem.lua
-- Author: hanruofei
-- Time: 2011/5/12 17:10
-- Comment:
--
local tbItem = Item:GetClass("buyequipitem");
function tbItem:OnUse()
	SpecialEvent.tbVipInvite:AfterBuyEquip();
	return 1;
end