-- 文件名　：reputeitem.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-04-13 14:37:22
--声望令牌

local tbLingPai = Item:GetClass("reputeitem_vn");
tbLingPai.nDuration	= Env.GAME_FPS * 3600;
tbLingPai.nSkillId	= 2211;

function tbLingPai:OnUse()
	me.AddSkillState(self.nSkillId, 1, 1, self.nDuration, 1, 0, 1);		-- 7天
	return 1;
end
