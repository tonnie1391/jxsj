-------------------------------------------------------
-- 文件名　：bailianwan.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-09-04 12:00:21
-- 文件描述：
-------------------------------------------------------

local tbItem = Item:GetClass("bailianwan");
tbItem.nDuration = Env.GAME_FPS * 60 * 60;

function tbItem:OnUse()
	me.AddSkillState(385, 8, 1, self.nDuration, 1, 0, 1);
	me.AddSkillState(386, 8, 1, self.nDuration, 1, 0, 1);
	me.AddSkillState(387, 8, 1, self.nDuration, 1, 0, 1);
	if GLOBAL_AGENT then
		me.SetTask(Player.ACROSS_TSKGROUPID, Player.ACROSS_TSKID_USE_TIME, GetTime());
		me.SetTask(Player.ACROSS_TSKGROUPID, Player.ACROSS_TSKID_TIME_OUT, tbItem.nDuration / Env.GAME_FPS);
		me.SetTask(Player.ACROSS_TSKGROUPID, Player.ACROSS_TSKID_PRICE, it.nPrice);
	end
	return 1;
end

function tbItem:GetTip()
	local szTip = "";
	szTip = szTip..FightSkill:GetSkillItemTip(385, 8) .. "\n";
	szTip = szTip..FightSkill:GetSkillItemTip(386, 8) .. "\n";
	szTip = szTip..FightSkill:GetSkillItemTip(387, 8) .. "\n";
	
	-- 自己处理状态持续时间
	szTip = szTip..string.format("<color=white>Thời gian duy trì: <color><color=gold>%s<color>\n", Lib:FrameTimeDesc(self.nDuration));
	
	return szTip;
end
