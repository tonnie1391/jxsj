--新年烟花
--2008.12.31
--sunduoliang

local tbItem = Item:GetClass("xinnianyanhua");
tbItem.nSkillExpId 		= 377;	--经验特效
tbItem.nSkillId 		= 1327;	--烟花特效
tbItem.nSkillId2 		= 1328;	--新年快乐特效
tbItem.nSkillBuffId 	= 1331;	--烟花buf
tbItem.nNpcId   		= 3627;	--烟花Npc
tbItem.nLastTime 		= 3 * 60 * Env.GAME_FPS	--3分钟

function tbItem:InitGenInfo()
	-- 设定有效期限
	it.SetTimeOut(0, (GetTime() + 24 * 3600));
	return	{ };
end

function tbItem:OnUse()
	
	local szMsg = "新年好！大家一起放烟花。\n新年烟花燃放时，队伍里面的燃放烟花的成员越多，经验也越丰富。\n\n<color=yellow>必须到礼官附近燃放才有效果。<color>\n你是否确定在礼官附近燃放烟花？";
	local tbOpt = {
		{"燃放烟花", self.OnUseSure, self, it.dwId},
		{"再等等"},
	}
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

function tbItem:OnUseSure(nItemId)
	local nCurTime = tonumber(GetLocalDate("%H%M"));
	if nCurTime < 2000 or nCurTime >= 2400 then
		Dialog:Say("新年好，烟花燃放只能在每天晚上的8点到12点，到礼官附近进行燃放，现在的时间段不允许燃放烟花。");
		return 0;
	end
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0
	end
	if me.nFightState == 1 then
		Dialog:Say("必须要在新手村和城市的礼官附近才能燃放烟花。在其他地方燃放烟花将会没有任何效果。");
		return 0;
	end
	if me.GetSkillState(self.nSkillBuffId) > 0 then
		Dialog:Say("你正在燃放一个烟花，请不要重复使用。");		
		return 0;
	end
	if me.DelItem(pItem) == 1 then
		me.AddSkillState(self.nSkillBuffId, 1, 1, self.nLastTime, 0);
		me.Msg("成功使用烟花，但必须要在礼官附近才有效，请保持在礼官附近。");
	end
end
