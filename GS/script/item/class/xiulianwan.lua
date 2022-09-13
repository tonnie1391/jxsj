-- 文件名　：xiulianwan.lua
-- 创建者　：
-- 创建时间：2009-02-04 11:53:26

local tbItem = Item:GetClass("xiulianwan");
tbItem.TaskGourp = 2067;
tbItem.TaskId_Day = 8;
tbItem.TaskId_Count = 9;
tbItem.Use_Max = 3;

function tbItem:OnUse()
	local nDate = tonumber(GetLocalDate("%y%m%d"));
	if me.GetTask(self.TaskGourp, self.TaskId_Day) < nDate then
		me.SetTask(self.TaskGourp, self.TaskId_Day, nDate);
		me.SetTask(self.TaskGourp, self.TaskId_Count, 0);
	end 
	local nCount = me.GetTask(self.TaskGourp, self.TaskId_Count)
	if nCount >= self.Use_Max then
		Dialog:Say("每天最多只能使用3个修炼丸。");
		return 0;
	end
	
	local tbXiuLianZhu = Item:GetClass("xiulianzhu");
	if tbXiuLianZhu:GetReTime() > 13.5 then
		Dialog:Say("您的修炼时间还剩余13.5小时以上，不能使用修炼丸。");
		return 0;
	end
	tbXiuLianZhu:AddRemainTime(30);	
	me.Msg(string.format("您的修炼时间增加了<color=green>半小时<color>，您今天已使用了<color=yellow>%s颗<color>修炼丸。",nCount + 1));
	me.SetTask(self.TaskGourp, self.TaskId_Count, nCount + 1);
	return 1;
end
