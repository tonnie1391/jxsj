local tbItem = Item:GetClass("vn_tianxinshi");

tbItem.nTaskGroup 			=	2210;
tbItem.nTaskCheckDateUse 	=	6;
tbItem.nTaskCountUse	 	=	7;

tbItem.nMaxPerDay	 		=	200;
tbItem.pItemTemp			= 	{};

tbItem.tbLimitUse 			= 	{36, 56, 76, 96, 200};

tbItem.tbReputePoint = {
	["Nón"] 	= {220,		198,	158,	111,	67}, 	
	["Áo"] 		= {500,		450,	360,	252,	151}, 	
	["Lưng"] 	= {5,		5,		4,		3,		2}, 	
	["Tay"] 	= {17,		14,		12,		8,		5}, 		
	["Giày"] 	= {3,		3,		2,		2,		1}, 
	["Liên"] 	= {28,		23,		18,		13,		8}, 		
	["Nhẫn"] 	= {20,		17,		14,		10,		6}, 		
	["Bội"] 	= {28,		23,		18,		13,		8}, 	
	["Phù"] 	= {37,		32,		25,		18,		11},
}

tbItem.tbReputeId = {
	["Nón"] = {8,1}, 	["Áo"] = {7,1}, 	["Lưng"] = {5,2}, 	["Tay"] = {5,6}, 	["Giày"] = {10,1}, 
	["Liên"] = {5,5}, 	["Nhẫn"] = {11,1}, 	["Bội"] = {12,1}, 	["Phù"] = {5,4}, 
}

function tbItem:OnUse()
	DoScript("\\script\\item\\class\\vn_tianxinshi.lua");
	
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
		
		local nUseTimesInDay = me.GetTask(self.nTaskGroup, self.nTaskCountUse);
		local nIndex = 1;
		for nTabIndex, nValueIndex in pairs(tbItem.tbLimitUse) do
			if nUseTimesInDay >= nValueIndex then
				nIndex = nTabIndex + 1;
			end
		end
		local nFlag, nReputeExt = Player:AddReputeWithAccelerate(me, self.tbReputeId[nItemType][1], self.tbReputeId[nItemType][2], self.tbReputePoint[nItemType][nIndex]);
		if (0 == nFlag) then
			return;
		elseif (1 == nFlag) then
			Dialog:Say("Danh vọng này đã đạt cấp cao nhất. Không thể tăng thêm!");
			return;
		end
		me.ConsumeItemInBags(1, unpack(self.pItemTemp));
		me.SetTask(self.nTaskGroup, self.nTaskCountUse, me.GetTask(self.nTaskGroup, self.nTaskCountUse) + 1);
		me.Msg("Hôm nay đã sử dụng <color=yellow>"..me.GetTask(self.nTaskGroup, self.nTaskCountUse).."<color> Thiên Tâm Thạch.")
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
