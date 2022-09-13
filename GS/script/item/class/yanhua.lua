
-- 烟花
-- 作用：右键点击使用，可放出美丽的烟花
local tbItem 		= Item:GetClass("yanhua");
tbItem.nCastSkillId 	=  307;

function tbItem:OnUse()
	me.CastSkill(self.nCastSkillId, 1, -1, me.GetNpc().nIndex);
	return 1;
end
