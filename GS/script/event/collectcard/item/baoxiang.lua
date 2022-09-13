Require("\\script\\event\\collectcard\\define.lua")

local tbItem = Item:GetClass("collect_baoxiang");
local CollectCard = SpecialEvent.CollectCard;
local tbAward = 
{
	[4] = 1,	--黄金宝箱
	[3] = 2,	--白银宝箱
	[2] = 3,	--青铜宝箱
	[1] = 4,	--黑铁宝箱
}

function tbItem:OnUse()
	local nData = tonumber(GetLocalDate("%Y%m%d%H%M%S"));
	
	if nData < CollectCard.TIME_STATE[2] then
		Dialog:Say("活动还未开启。");
		return 0;
	end		
	if me.CountFreeBagCell() < 2 then
		me.Msg("您背包空间不足。请整理2格背包空间。");
		return 0;
	end
	
	if it.nLevel == 4 then
		me.AddWaitGetItemNum(1);
		GCExcute({"SpecialEvent.CollectCard:GetAward_GC", me.nId});
		return 1;
	end
	if tbAward[it.nLevel] then
		CollectCard:GetAward_BaoXiang(me, tbAward[it.nLevel])
	end
	return 1;
end
