local tbLiGuan = Npc:GetClass("liguan");

tbLiGuan.taskGroupId				= 2211;

tbLiGuan.receiveAwardDomainRank		= 1;
tbLiGuan.receiveAwardDomainDate		= 2;

tbLiGuan.receiveAwardMoneyRank		= 3;
tbLiGuan.receiveAwardMoneyDate		= 4;

tbLiGuan.receiveAwardDateBegin		= 20211010; 
tbLiGuan.receiveAwardDateEnd		= 20221020; 

tbLiGuan.tongNameGetReward = {
	{szTongName="",	nRank=1},
	{szTongName="TiêuDao", nRank=2},
	{szTongName="", nRank=3},
}

tbLiGuan.awardDomain = {
	[1] = {
		tbItem = {
			{item={18, 1, 1, 9}, 	nNum=30, 	nBind=0, 	nTime=30},
			{item={1,12, 30, 10}, 	nNum=1, 	nBind=1, 	nTime=90},
		},
		nCashMoney = 10000000,
	},
	[2] = {
		tbItem = {
			{item={18, 1, 1, 9}, 	nNum=20, 	nBind=0, 	nTime=30},
			{item={1,12, 31, 10}, 	nNum=1, 	nBind=1, 	nTime=90},
		},
		nCashMoney = 7000000,
	},
	[3] = {
		tbItem = {
			{item={18, 1, 1, 9}, 	nNum=15, 	nBind=0, 	nTime=30},
			{item={1,12, 32, 10}, 	nNum=1, 	nBind=1, 	nTime=90},
		},
		nCashMoney = 4000000,
	},
}

tbLiGuan.awardMoney = {
	[1] = {
		tbItem = {
			{item={18, 1, 114, 10}, nNum=5, 	nBind=1, 	nTime=30},
			{item={18, 1, 464, 1}, 	nNum=2, 	nBind=0, 	nTime=30},
			{item={18, 1, 465, 1}, 	nNum=2, 	nBind=0, 	nTime=30},
			{item={18, 1, 326, 2}, 	nNum=2, 	nBind=0, 	nTime=30},
			{item={18, 1, 326, 3}, 	nNum=2, 	nBind=0, 	nTime=30},
			{item={1,12, 27, 10}, 	nNum=1, 	nBind=1, 	nTime=365},
		},
		nCashMoney = 1500000,
		nBindMoney = 5000000,
		nTitle={999,1,4,0}
	},
	[2] = {
		tbItem = {
			{item={18, 1, 114, 10}, nNum=3, 	nBind=1, 	nTime=30},
			{item={18, 1, 464, 1}, 	nNum=1, 	nBind=0, 	nTime=30},
			{item={18, 1, 465, 1}, 	nNum=1, 	nBind=0, 	nTime=30},
			{item={18, 1, 326, 2}, 	nNum=1, 	nBind=0, 	nTime=30},
			{item={18, 1, 326, 3}, 	nNum=1, 	nBind=0, 	nTime=30},
			{item={1,12, 28, 10}, 	nNum=1, 	nBind=1, 	nTime=365},
		},
		nCashMoney = 1000000,
		nBindMoney = 3000000,
		nTitle={999,1,3,0}
	},
	[3] = {
		tbItem = {
			{item={18, 1, 114, 10}, nNum=3, 	nBind=1, 	nTime=30},
			{item={18, 1, 464, 1}, 	nNum=1, 	nBind=0, 	nTime=30},
			{item={18, 1, 465, 1}, 	nNum=1, 	nBind=0, 	nTime=30},
			{item={1,12, 29, 10}, 	nNum=1, 	nBind=1, 	nTime=365},
		},
		nCashMoney = 700000,
		nBindMoney = 3000000,
		nTitle={999,1,2,0}
	},
	[4] = {
		tbItem = {
			{item={18, 1, 114, 10}, 	nNum=1, 	nBind=1, 	nTime=30},
		},
		nCashMoney = 500000,
		nBindMoney = 1000000,
		nTitle={999,1,1,0}
	},
	
}

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
	if self.receiveAwardDateBegin <= currentDate and currentDate <= self.receiveAwardDateEnd then
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
	local nRank = self:checkPermission(nType);
	local szRank = 1 and "Lãnh Thổ" or "Tài phú";
	
	if not nSure then
		if nType == 1 then
			if me.CountFreeBagCell() < 30 then
				Dialog:Say("Lễ Quan: Hành trang không đủ khoảng trống để nhận thưởng.");
				return 0
			end
			if me.nCashMoney + 10000000 > me.GetMaxCarryMoney() then
				Dialog:Say("Lễ Quan: Ngân lượng mang theo bên người đã đạt tối đa.");
				return 0
			end
			if me.GetTask(self.taskGroupId, self.receiveAwardDomainDate) > 0 then
				Dialog:Say("Lễ Quan: Ngươi đã nhận phần thưởng này rồi.",tbOpt);
				return 0
			else
				self:sendAwardTop(nType, 1);
			end
		elseif nType == 2 then
			if me.CountFreeBagCell() < 20 then
				Dialog:Say("Lễ Quan: Hành trang không đủ khoảng trống để nhận thưởng.");
				return 0
			end
			if me.GetBindMoney() + 5000000 > me.GetMaxCarryMoney() then
				Dialog:Say("Lễ Quan: Ngân lượng mang theo bên người đã đạt tối đa.");
				return 0
			end
			if me.nCashMoney + 1500000 > me.GetMaxCarryMoney() then
				Dialog:Say("Lễ Quan: Ngân lượng mang theo bên người đã đạt tối đa.");
				return 0
			end
			if me.GetTask(self.taskGroupId, self.receiveAwardMoneyDate) > 0 then
				Dialog:Say("Lễ Quan: Ngươi đã nhận phần thưởng này rồi.",tbOpt);
				return 0
			else
				self:sendAwardTop(nType, 1);
			end
		end
	else
		if nType == 1 then
			if nRank == 0 then
				Dialog:Say("Lễ Quan: Ngươi không đủ tư cách nhận thưởng.",tbOpt);
				return 0
			end
			if nRank == 99 then
				Dialog:Say("Xin lỗi, chỉ có Bang chủ mới có thể đến nhận phần thưởng cho các thành viên.");
				return 0
			end
			
			if self.awardDomain[nRank].tbItem then
				for nIndex = 1, #self.awardDomain[nRank].tbItem do
					local nG, nD, nP, nL = unpack(self.awardDomain[nRank].tbItem[nIndex].item);
					for nMount = 1, self.awardDomain[nRank].tbItem[nIndex].nNum do
						me.AddItemEx(nG, nD, nP, nL, {bForceBind=self.awardDomain[nRank].tbItem[nIndex].nBind}, nil, GetTime() + 3600 * 24 * self.awardDomain[nRank].tbItem[nIndex].nTime)
					end
				end
			end 

			if self.awardDomain[nRank].nBindMoney then
				me.AddBindMoney(self.awardDomain[nRank].nBindMoney)
			end
			
			if self.awardDomain[nRank].nCashMoney then
				me.Earn(self.awardDomain[nRank].nCashMoney, 0)
			end
			
			if self.awardDomain[nRank].nTitle then
				me.AddTitle(unpack(self.awardDomain[nRank].nTitle));
				me.SetCurTitle(unpack(self.awardDomain[nRank].nTitle));
			end
			
		elseif nType == 2 then
			if self.awardMoney[nRank].tbItem then
				for nIndex = 1, #self.awardMoney[nRank].tbItem do
					local nG, nD, nP, nL = unpack(self.awardMoney[nRank].tbItem[nIndex].item);
					for nMount = 1, self.awardMoney[nRank].tbItem[nIndex].nNum do
						me.AddItemEx(nG, nD, nP, nL, {bForceBind=self.awardMoney[nRank].tbItem[nIndex].nBind}, nil, GetTime() + 3600 * 24 * self.awardMoney[nRank].tbItem[nIndex].nTime)
					end
				end
			end 

			if self.awardMoney[nRank].nBindMoney then
				me.AddBindMoney(self.awardMoney[nRank].nBindMoney)
			end
			
			if self.awardMoney[nRank].nCashMoney then
				me.Earn(self.awardMoney[nRank].nCashMoney, 0)
			end
			
			if self.awardMoney[nRank].nTitle then
				me.AddTitle(unpack(self.awardMoney[nRank].nTitle));
				me.SetCurTitle(unpack(self.awardMoney[nRank].nTitle));
			end
			
		end
		KDialog.NewsMsg(1, Env.NEWSMSG_COUNT, "<color=green>"..me.szName.."<color> nhận phần thưởng <color=red> TOP "..nRank.." "..szRank.."<color>");
		KDialog.MsgToGlobal("<color=green>"..me.szName.."<color> nhận phần thưởng <color=red> TOP "..nRank.." "..szRank.."<color>");	
	end
end

function tbLiGuan:checkPermission(nType)
	if nType == 1 then
		local pTong = KTong.GetTong(me.dwTongId);
		local szTongName = pTong.GetName();
		local nKinId, nMemberId = me.GetKinMember();
		if Tong:CheckSelfRight(me.dwTongId, nKinId, nMemberId, Tong.POW_MASTER) ~= 1 then
			return 99;
		end
		
		for nIndex = 1, #self.tongNameGetReward do
			if szTongName == self.tongNameGetReward[nIndex].szTongName then
				return self.tongNameGetReward[nIndex].nRank;
			end
		end
	elseif nType == 2 then
		local nHonorRank = PlayerHonor:GetPlayerHonorRankByName(me.szName, PlayerHonor.HONOR_CLASS_MONEY, 0);
		if 0 < nHonorRank and nHonorRank <= 3 then
			return nHonorRank;
		elseif 4 <= nHonorRank and nHonorRank <= 10 then
			return 4
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
			[[	   <color=red>Hạng 1:<color>
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
