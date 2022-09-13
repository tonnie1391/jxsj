  --
-- FileName: levelupitem.lua
-- Author: hanruofei
-- Time: 2011/5/12 17:10
-- Comment:
--
local tbItem = Item:GetClass("levelupitem");

function tbItem:OnUse()
	SpecialEvent.tbVipInvite:AfterLevelUp();
	return 1;
end