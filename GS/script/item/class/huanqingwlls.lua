---------------------------
-- huanqingwlls.lua
-- zhouchenfei
-- Ì¨ÍåÇì×£ÎäÁÖÕù°Ô
-- 2010-10-13 16:28:23
---------------------------

local tbItem = Item:GetClass("huanqingwlls");

tbItem.DEF_YANHUA_SKILL = 1597;
tbItem.DEF_EXP_BASE = 15;

function tbItem:OnUse()
	me.AddExp(me.GetBaseAwardExp() * self.DEF_EXP_BASE);
	me.CastSkill(self.DEF_YANHUA_SKILL, 1, -1, me.GetNpc().nIndex);
	return 1;
end
