local tbLiGuan = Npc:GetClass("liguan");

tbLiGuan.nTaskGroupId		= 2211;
tbLiGuan.nTaskIdDomain		= 1;
tbLiGuan.nTaskIdMoney		= 2;

tbLiGuan.receiveAwardDate	= 20211010;

function tbLiGuan:OnDialog()
	DoScript("\\script\\npc\\liguan.lua")
	local szMsg = "Chào đại hiệp, người cần gì?";
	local tbOpt = 
	{
		{"Phúc lợi", self.FuLi, self},
		{"Đoán Hoa Đăng", GuessGame.OnDialog, GuessGame},
		{"Kết thúc đối thoại"},
	}
	
	local currentDate = tonumber(os.date("%Y%m%d", GetTime()));
	if currentDate >= self.receiveAwardDate then
		table.insert(tbOpt, 1, {"<color=yellow>Sự kiện Đua Top<color>", self.receiveAwardTop, self,});
	end
	
	Dialog:Say(szMsg, tbOpt);
end

function tbLiGuan:receiveAwardTop()
	local tbOpt = {
		{"Nhận thưởng Top Lãnh Thổ", self.sendAwardTop, self, 1},
		{"Xem Top Lãnh Thổ", self.sendAwardTop, self, 1},
		{"Nhận thưởng Top Tài Phú", self.sendAwardTop, self, 2},
		{"Xem Top Tài Phú", self.sendAwardTop, self, 2},
		{"Kết thúc đối thoại"},
	}

	Dialog:Say("Hãy chọn điều người cần", tbOpt);          
end

function tbLiGuan:sendAwardTop(nType, nSure)
	if not nSure then
	
	else
	
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

	Dialog:Say("Hãy chọn điều người cần", tbOpt);          
end
