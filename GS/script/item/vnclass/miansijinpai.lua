-- 文件名　：miansijinpai.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-04-13 14:37:37
--免死令牌

local tbLingPai = Item:GetClass("miansilingpai_vn");

function tbLingPai:OnUse()
	me.AddSkillState(2210, 4, 1, Env.GAME_FPS * 3600, 1, 0, 1);		--血内20%
	me.AddSkillState(892, 1, 1, Env.GAME_FPS * 3600, 1, 0, 1);		--强化优惠	
	me.AddSkillState(890, 1, 1, Env.GAME_FPS * 3600, 1, 0, 1);		--打怪经验翻倍
	me.AddSkillState(2212, 4, 1, Env.GAME_FPS * 3600, 1, 0, 1);		--魂石强化效果加20%
	return 1;
end