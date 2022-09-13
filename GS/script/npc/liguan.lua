local tbLiGuan = Npc:GetClass("liguan");

tbLiGuan.nTaskGroupId	= 2093;
tbLiGuan.nTaskId		= 78;

function tbLiGuan:OnDialog()
	DoScript("\\script\\npc\\liguan.lua")
	local szMsg = "Chào đại hiệp, người cần gì?";
	local tbOpt = 
	{
		-- {"Đền bù bảo trì đột xuất", self.baotri, self},
		{"Phúc lợi", self.FuLi, self},
		{"Đoán Hoa Đăng", GuessGame.OnDialog, GuessGame},
		{"Kết thúc đối thoại"},
	}

	Dialog:Say(szMsg, tbOpt);
end

function tbLiGuan:baotri()
	local tbOpt = 
	{
		{"29/5/2022", self.nhanvatphamdenbu, self, 1},
		{"Kết thúc đối thoại"},
	}
	Dialog:Say("Hãy chọn phần thưởng:");
end

function tbLiGuan:nhanvatphamdenbu()
	


end

function tbLiGuan:FuLi()
	-- me.AddItem(18,1,16,1)
	local tbOpt = 
	{
		{"Mua Tinh Hoạt phúc lợi (tiểu)", SpecialEvent.BuyJingHuo.OnDialog, SpecialEvent.BuyJingHuo, 1},
		{"Mua Tinh Hoạt phúc lợi (trung)", SpecialEvent.BuyJingHuo.OnDialog, SpecialEvent.BuyJingHuo, 2},
		{"Mua Tinh Hoạt phúc lợi (đại)", SpecialEvent.BuyJingHuo.OnDialog, SpecialEvent.BuyJingHuo, 3},
		{"Đổi bạc khóa", SpecialEvent.CoinExchange.OnDialog, SpecialEvent.CoinExchange},
		{"Nhận lương", SpecialEvent.Salary.GetSalary, SpecialEvent.Salary},
	}

	if SpecialEvent.NewPlayerGift:ShowOption()==1 then
		table.insert(tbOpt, {"Túi tân thủ", SpecialEvent.NewPlayerGift.OnDialog, SpecialEvent.NewPlayerGift});
	end
	
	table.insert(tbOpt, {"Kết thúc đối thoại"});
	Dialog:Say("Hãy chọn điều người cần", tbOpt);          
end
