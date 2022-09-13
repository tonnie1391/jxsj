-------------------------------------------------------
-- 文件名　：jinxiangzi.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-04-22 15:04:56
-- 文件描述：
-------------------------------------------------------

Require("\\script\\baibaoxiang\\baibaoxiang_def.lua");

-- 定义标示名字："\\setting\\item\\001\\other\scriptitem.txt"
local tbJinxiangziItem = Item:GetClass("jinxiangzi");

function tbJinxiangziItem:OnUse()
	
	local nWeekOpen	= me.GetTask(Baibaoxiang.TASK_GROUP_ID, Baibaoxiang.TASK_BAIBAOXIANG_WEEKEND);
	
	if nWeekOpen >= 5 then
		me.Msg("Mỗi tuần chỉ có thể mở 5 rương!");
		return 0;		
	end;
	
	if me.CountFreeBagCell() < 1 then
		me.Msg("Hành trang không đủ chỗ trống!");
		return 0;
	end
	
	local i = 0;
	local nAdd = 0;
	local nRand = 0;
	local nIndex = 0;
	
	-- random
	nRand = MathRandom(1, 10000);
	
	-- fill 3 rate	
	local tbRate = {8900, 1000, 100};
	local tbAward = {8 ,9, 10};
	
	-- get index
	for i = 1, 3 do
		nAdd = nAdd + tbRate[i];
		if nAdd >= nRand then
			nIndex = i;
			break;
		end
	end
	
	if nIndex == 0 then
		me.Msg("不好意思，您什么也没有得到。");
		return 0;
	end;
	
	local pItem = me.AddItem(18, 1, 1, tbAward[nIndex]);
	pItem.Bind(1);
	
	nWeekOpen = nWeekOpen + 1;
	me.SetTask(Baibaoxiang.TASK_GROUP_ID, Baibaoxiang.TASK_BAIBAOXIANG_WEEKEND, nWeekOpen);
	
	me.Msg("Mở Rương cao quý nhận được: <color=yellow>"..pItem.szName.."<color>");
	
	me.SendMsgToFriend("Hảo hữu [<color=yellow>" .. me.szName 
		.. "<color>] mở Rương cao quý nhận được <color=yellow>"
		.. pItem.szName .."<color>!");
	
	return 1;
end

function tbJinxiangziItem:WeekEvent()
	me.SetTask(Baibaoxiang.TASK_GROUP_ID, Baibaoxiang.TASK_BAIBAOXIANG_WEEKEND, 0);
end;

PlayerSchemeEvent:RegisterGlobalWeekEvent({tbJinxiangziItem.WeekEvent, tbJinxiangziItem});
