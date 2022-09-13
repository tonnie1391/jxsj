-- 文件名　：zhuzongzi_item_zongzi.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-21 16:10:10
-- 描  述  ：

SpecialEvent.ZongZi2011 = SpecialEvent.ZongZi2011 or {};
local tbZongZi = SpecialEvent.ZongZi2011 or {};

local tbItem	= Item:GetClass("zongzi201101_vn");

function tbItem:InitGenInfo()
	it.SetTimeOut(0, GetTime() + tbZongZi.ITEM_VALIDITY_ZONGZI);
	return {};
end

function tbItem:OnUse()
	if me.nLevel < tbZongZi.LEVEL_LIMIT then
		Dialog:Say("您等级不足60级，无法食用粽子！",{"知道了"});
		return 0;
	end
	local nCount = me.GetTask(tbZongZi.TASK_GROUP_ID, tbZongZi.TASK_EAT_TOTAL_COUNT);
	if nCount >= tbZongZi.MAX_BOIL_TOTAL_COUNT then
		Dialog:Say("您已经食用的够多了，还是把机会留个别的人吧。活动期间最多食用100个粽子！");
		return 0;
	end
	if me.CountFreeBagCell() < 2 then
		Dialog:Say("请确保您有<color=yellow>2格<color>背包空间，否则可能导致无法获取全部奖励！");
		return 0;
	end
	me.SetTask(tbZongZi.TASK_GROUP_ID, tbZongZi.TASK_EAT_TOTAL_COUNT, nCount + 1);
	local tbRandomItem = Item:GetClass("randomitem");
	local nRes = tbRandomItem:SureOnUse(tbZongZi.RANDOM_ITEM_ID, nil ,nil, nil, nil, nil, nil, nil, nil, it);
	if nRes == 1 and tbZongZi:RandomBenXiao() == 1 then
		GCExcute{"SpecialEvent.ZongZi2011:RandomBenXiao_GC", me.nId};
		me.AddWaitGetItemNum(1);
	end
	return nRes;
end

