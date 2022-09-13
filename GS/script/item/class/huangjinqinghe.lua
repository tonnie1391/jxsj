

local tbLingPai = Item:GetClass("huangjinqinghe");
tbLingPai.nDuration	= Env.GAME_FPS * 3600 * 24 * 7;
tbLingPai.nSkillId	= 881;

function tbLingPai:OnUse()
	me.AddSkillState(self.nSkillId, 1, 1, self.nDuration, 1, 0, 1);		-- 7天
	return 1;
end

function tbLingPai:GetTip()
	return "使用后可获得如下效果\n<color=gold>升级五行印时，魂石效果提高20%\n强化装备费用减少20%\n每天可在修炼珠中额外领取0.5小时修炼时间\n使用义军令牌、白虎堂令牌、家族令牌、宋金令牌、门派竞技令牌获得的声望增加50%<color>\n点击右键使用，效果持续7天"
end

