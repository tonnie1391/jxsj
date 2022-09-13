local tbItem 	= Item:GetClass("wanwuguiyuandan");
tbItem.nDuration	= Env.GAME_FPS * 60 * 60;


function tbItem:OnUse()
	me.AddSkillState(385, 10, 1, self.nDuration, 1, 0, 1);
	me.AddSkillState(386, 10, 1, self.nDuration, 1, 0, 1);
	me.AddSkillState(387, 10, 1, self.nDuration, 1, 0, 1);
	if GLOBAL_AGENT then
		me.SetTask(Player.ACROSS_TSKGROUPID, Player.ACROSS_TSKID_USE_TIME, GetTime());
		me.SetTask(Player.ACROSS_TSKGROUPID, Player.ACROSS_TSKID_TIME_OUT, tbItem.nDuration / Env.GAME_FPS);
		me.SetTask(Player.ACROSS_TSKGROUPID, Player.ACROSS_TSKID_PRICE, it.nPrice);
	end
	return 1;
end


function tbItem:GetTip()
	local szTip = "";
	szTip	= szTip..FightSkill:GetSkillItemTip(385, 10) .. "\n";
	szTip	= szTip..FightSkill:GetSkillItemTip(386, 10) .. "\n";
	szTip	= szTip..FightSkill:GetSkillItemTip(387, 10) .. "\n";
	
	-- 自己处理状态持续时间
	szTip = szTip..string.format("<color=white>Thời gian duy trì: <color><color=gold>%s<color>\n", Lib:FrameTimeDesc(self.nDuration));
	return szTip;	
end
