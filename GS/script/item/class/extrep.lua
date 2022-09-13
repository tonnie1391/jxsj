--扩展储物箱
--孙多良
--2008.10.16
--用百十个位来记3种扩展箱道具。

local tbItem = Item:GetClass("extrep")

tbItem.TaskGroup = 2024;
tbItem.TaskId 	 = 17;

function tbItem:OnUse()
	self:SureUse(it.dwId);
	return 0;
end

function tbItem:SureUse(nItemId, nFlag)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 1
	end
	local nTask = me.GetTask(self.TaskGroup, self.TaskId);
	if math.mod(math.floor(nTask/(10^(pItem.nLevel-1))), 10) > 0 then
		Dialog:Say("Ngươi đã dùng qua đạo cụ mở rộng rương.");
		return 1;
	end
	if not nFlag then
		local tbOpt =
		{
			{"Đồng ý dùng", self.SureUse, self, nItemId, 1},
			{"Để ta suy nghĩ lại"},
		}
		Dialog:Say("Sử dụng đạo cụ này sẽ tăng 1 ngăn của rương chứa đồ, nhưng <color=red>mỗi nhân vật chỉ được dùng 1 lần<color>, ngươi chắc chứ?", tbOpt);
		return 1;
	end
	local nItemLevel = pItem.nLevel;
	if me.DelItem(pItem) == 1 then
		if me.nExtRepState >= Item.EXTREPPOS_NUM then
			Dialog:Say("Đã đạt mức tối đa.");
			return 1;
		end	
		me.SetExtRepState(me.nExtRepState + 1);
		me.SetTask(self.TaskGroup, self.TaskId, nTask + 10^(nItemLevel-1));
		me.Msg("Chúc mừng bạn đã mở thêm một ngăn mới.");
	end
	return 1;	
end

function tbItem:GetTip()
	local nTask = me.GetTask(self.TaskGroup, self.TaskId);
	local nUse = 0;
	if math.mod(math.floor(nTask/(10^(it.nLevel-1))), 10) > 0 then
		nUse = 1;
	end
	local szTip = string.format("<color=green>Đã sử dụng %s/1<color>", nUse);
	return szTip;
end
