local tbItem = Item:GetClass("vnhanxingshi");

tbItem.nTaskGroup 			=	2210;
tbItem.nTaskCheckDateUse 	=	1;
tbItem.nTaskCountUse	 	=	2;

tbItem.nMaxPerDay	 		=	5;
tbItem.pItemTemp			= 	{};

tbItem.tbReputePoint = {
	["Nón"] = {8,1,88}, 	["Áo"] = {7,1,200}, 	["Lưng"] = {5,2,2}, 	["Tay"] = {5,6,6}, 	["Giày"] = {10,1,1}, 
	["Liên"] = {5,5,11}, 	["Nhẫn"] = {11,1,8}, 	["Bội"] = {12,1,11}, 	["Phù"] = {5,4,14}, 
}

function tbItem:OnUse()
	DoScript("\\script\\item\\class\\vnhanxingshi.lua");
	
	self.pItemTemp = {it.nGenre, it.nDetail, it.nParticular, it.nLevel};
	local tbOpt = {
		{"Nón", 	self.GiveRepute, 	self, 	"Nón"},
		{"Áo", 		self.GiveRepute,	self, 	"Áo"},
		{"Lưng", 	self.GiveRepute, 	self, 	"Lưng"},
		{"Tay", 	self.GiveRepute, 	self, 	"Tay"},
		{"Giày", 	self.GiveRepute, 	self, 	"Giày"},
		{"Liên", 	self.GiveRepute, 	self, 	"Liên"},
		{"Nhẫn", 	self.GiveRepute, 	self, 	"Nhẫn"},
		{"Bội", 	self.GiveRepute, 	self, 	"Bội"},
		{"Phù", 	self.GiveRepute, 	self, 	"Phù"},
		{"Để ta suy nghĩ thêm"},
	}
	Dialog:Say("Hãy chọn Danh vọng mà ngươi cần!", tbOpt)
end

function tbItem:GiveRepute(nItemType, nSure)
	if not nSure then
		if self:CheckUsePerDay() == "full" then
			Dialog:Say("Hôm nay ngươi đã sử dụng đủ rồi!")
		else
			self:GiveRepute(nItemType, 1)
		end
	else
		local nFind = me.GetItemCountInBags(unpack(self.pItemTemp));
		if nFind <= 0 then
			Dialog:Say("Không tìm thấy Hàn Tinh Thạch trong hành trang!");
			return;
		end
		
		local nFlag, nReputeExt = Player:AddReputeWithAccelerate(me, unpack(self.tbReputePoint[nItemType]));
		if (0 == nFlag) then
			return;
		elseif (1 == nFlag) then
			Dialog:Say("Danh vọng này đã đạt cấp cao nhất. Không thể tăng thêm!");
			return;
		end
		me.ConsumeItemInBags(1, unpack(self.pItemTemp));
		me.SetTask(self.nTaskGroup, self.nTaskCountUse, me.GetTask(self.nTaskGroup, self.nTaskCountUse) + 1);
		me.Msg("Hôm nay đã sử dụng <color=yellow>"..me.GetTask(self.nTaskGroup, self.nTaskCountUse).."<color> Hàn Tinh Thạch.")
	end
end

function tbItem:CheckUsePerDay()
	local nCurrentDate = tonumber(os.date("%Y%m%d", GetTime()))
	if me.GetTask(self.nTaskGroup, self.nTaskCheckDateUse) == nCurrentDate then
		if me.GetTask(self.nTaskGroup, self.nTaskCountUse) >= self.nMaxPerDay then
			return "full";
		end
	else
		me.SetTask(self.nTaskGroup, self.nTaskCheckDateUse, nCurrentDate);
		me.SetTask(self.nTaskGroup, self.nTaskCountUse, 0);
	end
end
