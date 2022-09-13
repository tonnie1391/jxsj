-------------------------------------------------------
-- 文件名　：mingsuxinde.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-05-25 14:16:27
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

local tbItem = Item:GetClass("mingsuxinde");

tbItem.MAX_USE_DAY 		= 3;
tbItem.TASK_GID 		= 2027;
tbItem.TASK_USE_DAY 	= 113;

function tbItem:OnUse()
	
	local nUse = me.GetTask(self.TASK_GID, self.TASK_USE_DAY);
	if nUse >= self.MAX_USE_DAY then
		me.Msg(string.format("该道具每天最多能使用<color=yellow>%s<color>个，您今天不能再用了。", self.MAX_USE_DAY));
		return 0;
	end
	
	if me.nLevel >= 90 then
		me.Msg("该道具只能90级以下的角色使用。");
		return 0;
	end
	
	local nAddExp = 130 * me.nLevel^2 + 2600 * me.nLevel + 9750;
	
	me.AddExp(nAddExp);
	me.SetTask(self.TASK_GID, self.TASK_USE_DAY, nUse + 1);
	me.Msg(string.format("您今天已经使用了<color=yellow>%s<color>个名宿心得，每天最多能使用<color=yellow>%s<color>个。", (nUse + 1), self.MAX_USE_DAY));
	
	return 1;
end

function tbItem:GetTip(nState)
	local nAddExp = 130 * me.nLevel^2 + 2600 * me.nLevel + 9750;
	local nUse = me.GetTask(self.TASK_GID, self.TASK_USE_DAY);
	local szTip = string.format("使用该物品可以获得<color=yellow>%s<color>经验。", nAddExp);
	szTip = szTip .. string.format("\n\n<color=green>您今天已使用%s个名宿心得，每天最多使用%s个<color>", nUse, self.MAX_USE_DAY);
	return szTip;
end

function tbItem:DailyEvent()
	me.SetTask(self.TASK_GID, self.TASK_USE_DAY, 0);
end;

PlayerSchemeEvent:RegisterGlobalDailyEvent({tbItem.DailyEvent, tbItem});
