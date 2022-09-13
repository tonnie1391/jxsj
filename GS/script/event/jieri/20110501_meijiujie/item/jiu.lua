  --
-- FileName: kaixinjiubei.lua
-- Author: hanruofei
-- Time: 2011/4/21 16:29
-- Comment:
--

local tbItem = Item:GetClass("jiu_20110501");

function tbItem:OnUse()
	SpecialEvent.tbMeijiujie20110501:Drink(me, it)
end
