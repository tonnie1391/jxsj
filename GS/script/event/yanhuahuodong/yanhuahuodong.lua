--
-- 烟花活动脚本
-- zhengyuhua

SpecialEvent.tbYanHua = {}
local tbYanHua = SpecialEvent.tbYanHua;

tbYanHua.BEGIN_TIME		= 20090727	-- 开始日期
tbYanHua.END_TIME		= 20090817	-- 结束日期
tbYanHua.TASK_GROUP		= 2038
tbYanHua.TASK_DATE_ID	= 9
tbYanHua.YANHUA_ITEM	= {18,1,180,1};

function tbYanHua:CheckEventTime()
	local nCurDate = tonumber(os.date("%Y%m%d",GetTime()));
	if nCurDate >= self.BEGIN_TIME and nCurDate < self.END_TIME then
		return 1;
	end
	return 0;
end

function tbYanHua:DialogLogic()
	local nCurDate = tonumber(os.date("%Y%m%d",GetTime()));
	if nCurDate < self.BEGIN_TIME then
		Dialog:Say("盛夏活动烟花领取将从7月27日正式开始！");
		return 0;
	elseif nCurDate > self.END_TIME then
		Dialog:Say("盛夏活动烟花领取已经结束！");
		return 0;
	end
	local nDate = me.GetTask(self.TASK_GROUP, self.TASK_DATE_ID);
	local szInfo;
	local nKinId, nMemberId = me.GetKinMember();
	local nRet = Kin:HaveFigure(nKinId, nMemberId, 3)
	if nDate == nCurDate or nRet ~= 1 then
		szInfo = "  从7月27日至8月17日0点，玩家每天可以从我这领取一个烟花。但只有加入家族的<color=red>正式成员<color>才能领取烟花，且活动期间，<color=red>每天只能领取一次<color>"
	end
	if me.CountFreeBagCell() <= 0 then
		szInfo = "你的背包空间不足"
	end
	
	if not szInfo then
		local pItem = me.AddItem(unpack(self.YANHUA_ITEM));
		if pItem then
			me.SetItemTimeout(pItem, os.date("%Y/%m/%d/00/00/00", GetTime() + 3600 * 24));	-- 当天有效
			me.SetTask(self.TASK_GROUP, self.TASK_DATE_ID, nCurDate);
		end
		return 1;
	end
	Dialog:Say(szInfo);
end

