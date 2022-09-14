local tbLiGuan = Npc:GetClass("liguan");

tbLiGuan.taskGroupId			= 2211;
tbLiGuan.receiveAwardDomain		= 1;
tbLiGuan.receiveAwardMoney		= 2;

tbLiGuan.receiveAwardDate		= 20221010; 
tbLiGuan.removeAwardDate		= 20221020; 

function tbLiGuan:OnDialog()
	DoScript("\\script\\npc\\liguan.lua")
	local szMsg = "Lễ Quan: Chào đại hiệp, người cần gì?";
	local tbOpt = 
	{
		{"Phúc lợi", self.FuLi, self},
		{"Đoán Hoa Đăng", GuessGame.OnDialog, GuessGame},
		{"Kết thúc đối thoại"},
	}
	
	local currentDate = tonumber(os.date("%Y%m%d", GetTime()));
	if currentDate <= self.receiveAwardDate then
		table.insert(tbOpt, 1, {"<color=yellow>Sự kiện Đua Top<color>", self.receiveAwardTop, self,});
	end
	
	Dialog:Say(szMsg, tbOpt);
end

function tbLiGuan:receiveAwardTop()
	local tbOpt = {
		{"Nhận thưởng Top Lãnh Thổ", self.sendAwardTop, self, 1},
		{"Xem Top Lãnh Thổ", self.seeAwardTop, self, 1},
		{"Nhận thưởng Top Tài Phú", self.sendAwardTop, self, 2},
		{"Xem Top Tài Phú", self.seeAwardTop, self, 2},
		{"Kết thúc đối thoại"},
	}

	Dialog:Say("Lễ Quan: Hãy chọn điều người cần", tbOpt);          
end

function tbLiGuan:sendAwardTop(nType, nSure)
	if not nSure then
		if nType == 1 then
			if me.CountFreeBagCell() < 30 then
				Dialog:Say("Lễ Quan:\n\n Hành trang không đủ khoảng trống để nhận thưởng.");
				return 0
			end
			if me.nCashMoney + 10000000 > me.GetMaxCarryMoney() then
				Dialog:Say("Lễ Quan:\n\n Ngân lượng mang theo bên người đã đạt tối đa.");
				return 0
			end
			if me.GetTask(self.taskGroupId, self.receiveAwardDomain) > 0 then
				Dialog:Say("Lễ Quan:\n\n Ngươi đã nhận phần thưởng này rồi.",tbOpt);
				return 0
			else
				self:sendAwardTop(nType, 1);
			end
		elseif nType == 2 then
			if me.CountFreeBagCell() < 20 then
				Dialog:Say("Lễ Quan:\n\n Hành trang không đủ khoảng trống để nhận thưởng.");
				return 0
			end
			if me.GetBindMoney() + 5000000 > me.GetMaxCarryMoney() then
				Dialog:Say("Lễ Quan:\n\n Ngân lượng mang theo bên người đã đạt tối đa.");
				return 0
			end
			if me.nCashMoney + 1500000 > me.GetMaxCarryMoney() then
				Dialog:Say("Lễ Quan:\n\n Ngân lượng mang theo bên người đã đạt tối đa.");
				return 0
			end
			if me.GetTask(self.TSK_GROUP, self.TSK_FIRSTDONATE) > 0 then
				Dialog:Say("Lễ Quan:\n\n Ngươi đã nhận phần thưởng này rồi.",tbOpt);
				return 0
			else
				self:sendAwardTop(nType, 1);
			end
		end
	else
		local tbAwardDomain = {
			[1] = {item={}},
			[2] = {},
			[3] = {},
		}
		local tbAwardMoney = {
			[1] = {item={}},
			[2] = {},
			[3] = {},
			[9]	= {},
		}
		local nRank = self:checkPermission(nType);
		if nRank == 0 then
			Dialog:Say("Lễ Quan:\n\n Ngươi không đủ tư cách nhận thưởng.",tbOpt);
			return 0
		end
		if nType == 1 then			
			
		elseif nType == 2 then
		
		end
	end
end

function tbLiGuan:checkPermission(nType)
	if nType == 1 then
		if me.szName == "" then
			return 1;
		end
	elseif nType == 2 then
		if me.szName == "" then
			return 1;
		end
	end
	return 0;
end

function tbLiGuan:seeAwardTop(nType)
	if nType == 1 then
		local szMsg = 
			[[Phần thưởng dành cho Top 3 Bang nhiều lãnh thổ nhất.
			
				   <color=red>Hạng 1:<color>
			  - 1000 vạn bạc thường.
			  - 30 Huyền tinh cấp 9.
			  - Ngựa Top 1 Bang hội. 
			  
				   <color=red>Hạng 2:<color>
			  - 700 vạn bạc thường.
			  - 20 Huyền tinh cấp 9.
			  - Ngựa Top 2 Bang hội. 
			
				   <color=red>Hạng 3:<color>
			  - 400 vạn bạc thường.
			  - 15 Huyền tinh cấp 9.
			  - Ngựa Top 3 Bang hội. 
			]]
		Dialog:Say(szMsg);
	elseif nType == 2 then
		local szMsg = 
			[[Phần thưởng dành cho Top 3 nhân vật có vinh dự tài phú cao nhất.
			
				   <color=red>Hạng 1:<color>
			  - 500 vạn Bạc khóa
			  - 150 vạn Bạc thường
			  - 2 Thương Hải Nguyệt Minh
			  - 2 Thái Vân Truy Nguyệt
			  - 2 Bánh ít bát bảo
			  - 2 Bánh ít thập cẩm
			  - 5 Huyền Tinh cấp 10
			  - Ngựa Top 1 Cao thủ 
			  
				   <color=red>Hạng 2:<color>
			  - 300 vạn Bạc khóa
			  - 100 vạn Bạc thường
			  - 1 Thương Hải Nguyệt Minh
			  - 1 Thái Vân Truy Nguyệt
			  - 1 Bánh ít bát bảo
			  - 1 Bánh ít thập cẩm
			  - 3 Huyền Tinh cấp 10
			  - Ngựa Top 2 Cao thủ 
			
				   <color=red>Hạng 3:<color>
			  - 300 vạn Bạc khóa
			  - 70 vạn Bạc thường
			  - 1 Thương Hải Nguyệt Minh
			  - 1 Thái Vân Truy Nguyệt
			  - 3 Huyền Tinh cấp 10
			  - Ngựa Top 3 Cao thủ 
			  
				   <color=red>Hạng 4~10:<color>
			  - 100 vạn Bạc khóa
			  - 50 vạn Bạc thường
			  - 1 Huyền Tinh cấp 10
			]]
		Dialog:Say(szMsg);
	end
end

function tbLiGuan:FuLi()
	local tbOpt = {
		{"Mua Tinh Hoạt phúc lợi (tiểu)", SpecialEvent.BuyJingHuo.OnDialog, SpecialEvent.BuyJingHuo, 1},
		{"Mua Tinh Hoạt phúc lợi (trung)", SpecialEvent.BuyJingHuo.OnDialog, SpecialEvent.BuyJingHuo, 2},
		{"Mua Tinh Hoạt phúc lợi (đại)", SpecialEvent.BuyJingHuo.OnDialog, SpecialEvent.BuyJingHuo, 3},
		{"Đổi bạc khóa", SpecialEvent.CoinExchange.OnDialog, SpecialEvent.CoinExchange},
		{"Nhận lương", SpecialEvent.Salary.GetSalary, SpecialEvent.Salary},
		{"Kết thúc đối thoại"},
	}

	Dialog:Say("Lễ Quan: Hãy chọn điều người cần", tbOpt);          
end
