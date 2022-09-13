local tbItem = Item:GetClass("vnqiankunbox");
tbItem.pItemTemp			=	{};
tbItem.nUnLockItemId 		= 	{18, 1, 20451, 1};
tbItem.nUnLockItemInShop	= 	20115;
tbItem.nUnLockCost			=	3600;

function tbItem:OnUse()
	DoScript("\\script\\item\\class\\vnqiankunbox.lua");
	
	self.pItemTemp = {it.nGenre, it.nDetail, it.nParticular, it.nLevel};
	local tbOpt = {
		{"Sử dụng Chìa Càn Khôn", self.OpenBoxItem, self, 1},
		{"Sử dụng Tinh Hoạt Lực", self.OpenBoxItem, self, 2},
		{"Để ta suy nghĩ thêm"}, 
	}
	Dialog:Say("Để mở Rương Càn Khôn cần có Chìa Càn Khôn hoặc 3600 Tinh hoạt lực. Ngươi muốn chọn cách nào?", tbOpt);
end

function tbItem:OpenBoxItem(nWay, nSure)
	if me.CountFreeBagCell() < 2 then
		Dialog:Say("Hành trang không đủ chỗ trống!");
		return;
	end
	if not nSure then
		if nWay == 1 then
			if #me.FindItemInBags(unpack(self.nUnLockItemId)) <= 0 then
				local tbOpt = {
					{"Mua Chìa Càn Khôn", self.BuyUnlockItem, self},
					{"Để ta suy nghĩ thêm"},
				}
				Dialog:Say("Hành trang không có Chìa Càn Khôn. Ngươi muốn mua với giá <color=yellow>240 đồng<color> chứ?", tbOpt);
			else
				self:OpenBoxItem(nWay, 1);
			end
		elseif nWay == 2 then
			local nJing, nHou = self:CheckJingHou();
			if nJing < self.nUnLockCost or nHou < self.nUnLockCost then
				Dialog:Say("Không đủ Tinh Hoạt Lực!")
			else
				self:OpenBoxItem(nWay, 1);
			end
		end
	else
		if nWay == 1 then
			me.ConsumeItemInBags(1, unpack(self.nUnLockItemId));
			me.ConsumeItemInBags(1, unpack(self.pItemTemp));
		elseif nWay == 2 then
			me.ChangeCurGatherPoint(-self.nUnLockCost);
			me.ChangeCurMakePoint(-self.nUnLockCost);
			me.ConsumeItemInBags(1, unpack(self.pItemTemp));
		end
		
		me.AddItem(18, 1, 20424, 1);
		me.AddItem(18, 1, 20426, 2);
	end
end

function tbItem:CheckJingHou()
	return me.dwCurMKP, me.dwCurGTP
end

function tbItem:BuyUnlockItem()
	me.ApplyAutoBuyAndUse(self.nUnLockItemInShop, 1, 0);
end