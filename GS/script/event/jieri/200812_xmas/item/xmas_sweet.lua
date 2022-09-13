--圣诞糖果
--孙多良
--2008.12.16
if  MODULE_GC_SERVER then
	return;
end
local tbItem = Item:GetClass("xmas_sweet");
tbItem.MAX_USE_COUNT = 100;
tbItem.TSK_GROUP = 2027;
tbItem.TSK_ID = 96;

function tbItem:InitGenInfo()
	-- 设定有效期限
	local nSec = GetTime() + 30 * 24 * 3600;
	it.SetTimeOut(0, nSec);
	return	{ };
end

function tbItem:OnUse()
	local nUse = me.GetTask(self.TSK_GROUP, self.TSK_ID);
	if nUse >= self.MAX_USE_COUNT then
		me.Msg(string.format("该道具最多能用<color=yellow>%s<color>个，您不能再用了。", self.MAX_USE_COUNT));
		return 0;
	end
	
	if me.nLevel < 60 then
		me.Msg("您的等级不够60级，无法使用。");
		return 0;
	end
	
	local nAddExp = 130 * me.nLevel^2 + 2600 * me.nLevel + 9750;
	
	me.AddExp(nAddExp);
	me.SetTask(self.TSK_GROUP, self.TSK_ID, nUse + 1);
	me.Msg(string.format("您已经使用了<color=yellow>%s<color>个圣诞糖果，最多能用<color=yellow>%s<color>个。", (nUse + 1), self.MAX_USE_COUNT));
	return 1;
end

function tbItem:GetTip(nState)
	local nAddExp = 130 * me.nLevel^2 + 2600 * me.nLevel + 9750;
	local nUse = me.GetTask(self.TSK_GROUP, self.TSK_ID);
	local szTip = string.format("使用该物品可以获得<color=yellow>%s<color>经验。", nAddExp);
	szTip = szTip .. string.format("\n\n<color=green>已使用%s个该物品<color>", nUse);
	return szTip;
end
