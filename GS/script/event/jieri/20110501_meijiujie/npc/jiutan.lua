  --
-- FileName: jiutan.lua
-- Author: hanruofei
-- Time: 2011/4/22 9:56
-- Comment:
--

local tbNpc = Npc:GetClass("jiutan_20110501");

function tbNpc:OnDialog()
	SpecialEvent.tbMeijiujie20110501:GetWine(me);
end

