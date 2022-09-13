--机关材料手册

local tbItem = Item:GetClass("army_handbook")
tbItem.nTaskGroupId = 2044;	--随机获得零件的任务变量Group
tbItem.tbTaskId =
{
	--随机获得零件的任务变量
	1,2,3,4,5,6,7,8,9,10,
}
tbItem.tbTaskName = {"Tiền trục","Hậu trục","Trung cốt","Cánh tả","Cánh hữu","Tiêu thạch","Lưu huỳnh","Gỗ","Thỏi đồng","Thủy ngân"};

function tbItem:GetTip(nState)
	local szTip = "";
	for ni, nTaskId in ipairs(self.tbTaskId) do
		if ni == 6 then
			szTip = szTip .. "<enter>";
		end
		if me.GetTask(self.nTaskGroupId, nTaskId) == 0 then
			szTip = szTip .. string.format("<color=gray>%s<color>  ", self.tbTaskName[nTaskId]);	
		else
			szTip = szTip .. string.format("<color=yellow>%s<color>  ", self.tbTaskName[nTaskId]);	
		end
	end
	return szTip;
end

