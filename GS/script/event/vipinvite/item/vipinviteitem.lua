  --
-- FileName: vipinviteitem.lua
-- Author: hanruofei
-- Time: 2011/5/12 15:04
-- Comment:
--

local tbItem = Item:GetClass("vipinviteitem");

function tbItem:OnUse()
	SpecialEvent.tbVipInvite:OnInvitorDialog(it.dwId)
end