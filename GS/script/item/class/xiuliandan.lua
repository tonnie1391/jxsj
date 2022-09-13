--修炼丹
--sunduoliang
--2008.11.24

local tbItem = Item:GetClass("xiuliandan");
tbItem.TaskGourp = 2024;
tbItem.TaskId_Day = 18;
tbItem.TaskId_Count = 19;
tbItem.Use_Max = EventManager.IVER_nXiulindanMaxUse;
 
function tbItem:OnUse()
	local nDate = tonumber(GetLocalDate("%y%m%d"));
	if me.GetTask(self.TaskGourp, self.TaskId_Day) < nDate then
		me.SetTask(self.TaskGourp, self.TaskId_Day, nDate);
		me.SetTask(self.TaskGourp, self.TaskId_Count, 0);
	end 
	local nCount = me.GetTask(self.TaskGourp, self.TaskId_Count)
	if nCount >= self.Use_Max then
		Dialog:Say(string.format("Mỗi ngày chỉ được dùng %d Tu Luyện Đơn.", tbItem.Use_Max));
		return 0;
	end
	
	local tbXiuLianZhu = Item:GetClass("xiulianzhu");
	if tbXiuLianZhu:GetReTime() > 12 then
		Dialog:Say("Thời gian tu luyện của bạn còn hơn 12 giờ, không thể sử dụng Tu Luyện Đơn.")
		return 0;
	end
	tbXiuLianZhu:AddRemainTime(120);	
	me.Msg(string.format("Thời gian tu luyện của bạn đã tăng <color=green>2 giờ<color>, hôm nay bạn đã dùng <color=yellow>%s <color> Tu Luyện Đơn.",nCount + 1));
	me.SetTask(self.TaskGourp, self.TaskId_Count, nCount + 1);
	return 1;
end

function tbItem:GetTip(nState)
	return string.format("Có thể <color=gold>tăng 2 giờ<color> Tu Luyện Châu, mỗi ngày uống tối đa <color=gold>%d lọ<color>. <enter><color=gold>Tổng thời gian tu luyện không quá 14 giờ.<color>", self.Use_Max);
end
