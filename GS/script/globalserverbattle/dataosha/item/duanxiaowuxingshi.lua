-- 文件名　：duanxiaowuxingshi.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-10-28 11:04:07
-- 描  述  ：
local tbItem 		= Item:GetClass("duanxiaowuxingshi");
tbItem.nDuration	= Env.GAME_FPS *10;
tbItem.nSkillId		= 386;


function tbItem:OnUse()
	me.AddSkillState(self.nSkillId, 8, 1, self.nDuration);
	
	return 1;
end


function tbItem:GetTip()
	local szTip = FightSkill:GetSkillItemTip(self.nSkillId, 8);
	
	-- 自己处理状态持续时间
	szTip = szTip..string.format("\n<color=white>Thời gian duy trì: <color><color=gold>%s<color>\n", Lib:FrameTimeDesc(self.nDuration));
	return szTip;	
end
