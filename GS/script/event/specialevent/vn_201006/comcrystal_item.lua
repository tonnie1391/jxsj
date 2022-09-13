-- 文件名　：comcrystal_item.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-05-14 09:16:32
-- 描  述  ：越南6月合成结晶

--VN--
local tbItem 	= Item:GetClass("crystal");

SpecialEvent.tbComCrystal = SpecialEvent.tbComCrystal or {};
local tbComCrystal = SpecialEvent.tbComCrystal;

function tbItem:OnUse()
	--时间20100609----20100630
--	local nData = tonumber(GetLocalDate("%Y%m%d"));
--	if nData < tbComCrystal.nStarTime or nData > tbComCrystal.nCloseTime then	--活动期间外
--		Dialog:Say("水晶已经失效了！", {"知道了"});
--		return;
--	end
	--活动期间使用次数50次
	if me.GetTask(tbComCrystal.TASKGID, tbComCrystal.TASK_USEITEMNUM) >= tbComCrystal.nUseMaxNum then
		Dialog:Say("活动期间您已经使用足够多了，机会还是留给其他人吧！", {"知道了"});
		return;
	end
	
	--绑银数量判断
	local nBindMoney = 0;
	for i, tbAwordEx in pairs(tbComCrystal.tbAword[it.nLevel]) do		
		nBindMoney = nBindMoney + tbAwordEx[4];
	end	
	if me.GetBindMoney() + nBindMoney > me.GetMaxCarryMoney() then
		Dialog:Say( "您的绑定银两也太多了吧！", {"知道了"});
		return  ;
	end
	
	--背包判断	
	if me.CountFreeBagCell() < 4 then
		Dialog:Say( "请预留4格背包空间再来吧！", {"知道了"});
		return;		
	end
	
	tbComCrystal:GetAword(it.nLevel);
	me.SetTask(tbComCrystal.TASKGID, tbComCrystal.TASK_USEITEMNUM, me.GetTask(tbComCrystal.TASKGID, tbComCrystal.TASK_USEITEMNUM) + 1);
	--19级物品使用次数+1
	if it.nLevel == 20 then
		me.SetTask(tbComCrystal.TASKGID, tbComCrystal.TASK_GETMAXLEVELITEM, me.GetTask(tbComCrystal.TASKGID, tbComCrystal.TASK_GETMAXLEVELITEM) + 1);
	end
	return 1;
end

function tbItem:GetTip()	
	local nTimes = me.GetTask(tbComCrystal.TASKGID,tbComCrystal.TASK_USEITEMNUM);
	local tbColor = {"green","gray"};
	local nFlag = 1;
	if nTimes >= tbComCrystal.nUseMaxNum then
		nFlag = 2;
	end
	local szMsg = string.format("<color=%s>已经使用%s/%s<color><color=green>\n通过水晶您最多获得10亿经验<color>", tbColor[nFlag], nTimes, tbComCrystal.nUseMaxNum);
	return szMsg;
end
