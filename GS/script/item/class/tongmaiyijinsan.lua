------------------------------------------------------
-- 文件名　：编辑5
-- 创建者　：dengyong
-- 创建时间：2009-12-15 19:47:45
-- 描  述  ：通脉易筋散
------------------------------------------------------
local tbItem = Item:GetClass("tongmaiyijinsan");

tbItem.nSkillId   = 1525;	-- 触发的状态技能ID

function tbItem:OnUse()
	if (Partner.bOpenPartner ~= 1) then
		Dialog:Say("现在同伴活动已经关闭，无法使用物品");
		return 0;
	end

	me.AddSkillState(self.nSkillId, 1, 1, 30 * 60* Env.GAME_FPS, 0);
	Dbg:WriteLog("同伴Log:", me.szName, "使用", it.szName, ",激活同伴获取经验无视怪物等级限制");
	return 1;
end