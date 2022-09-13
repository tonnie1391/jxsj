-----------------------------------------------------------
-- 文件名　：jiguanshuxinde.lua
-- 文件描述：使用后增加机关耐久度
-- 创建者　：ZhangDeheng
-- 创建时间：2008-11-17 11:28:11
-----------------------------------------------------------
local tbItem = Item:GetClass("jiguanshuxinde");

tbItem.AWARD 			= 20;	-- 增加20点机关耐久度
tbItem.WEEK_USED_COUNT 	= 10; -- 一周可以使用的个数

function tbItem:OnUse()
	if (me.GetTask(1022, 117) ~= 1) then
		me.Msg("只有学习了机关术才能使用此物品！");
		return 0;
	end;
	
	local nCount = me.GetTask(1024, 57);
	if (nCount >= self.WEEK_USED_COUNT) then
		me.Msg("您本周使用已达上限，不能再使用！");
		return 0;		
	end;
	
	me.AddMachineCoin(self.AWARD);
	me.Msg(string.format("您获得了<color=yellow>%s点<color>机关耐久度", self.AWARD));
	nCount = nCount + 1;
	me.SetTask(1024, 57, nCount)
	return 1;
end

function tbItem:InitGenInfo()
	--设置道具的生存期
	it.SetTimeOut(0, GetTime() + 24 * 3600);
	return	{ };
end

-- 每周清一次
function tbItem:WeekEvent()
	me.SetTask(1024, 57, 0, 1);
end

PlayerSchemeEvent:RegisterGlobalWeekEvent({tbItem.WeekEvent, tbItem});