-------------------------------------------------------------------
--File: tuiguangyuan.lua
--Author: kenmaster
--Date: 2008-06-04 03:00
--Describe: 活动推广员npc脚本
-------------------------------------------------------------------
local tbTuiGuangYuan = Npc:GetClass("tuiguangyuan");

tbTuiGuangYuan.TSK_GROUP 			= 2206;
tbTuiGuangYuan.TSK_FIRSTDONATE	 	= 1;
tbTuiGuangYuan.TSK_MONTHRECIEVE	 	= 2;
tbTuiGuangYuan.nMonthDonatePrice		= 1000000;

function tbTuiGuangYuan:OnDialog()
	DoScript("\\script\\npc\\tuiguangyuan.lua")
	local tbOpt = {
   		{"<color=yellow>Nhập mã Ưu đãi<color>", self.Giftcode, self},
   		{"<color=green>Ưu đãi Nạp lần đầu<color>", self.FirstDonate, self},
   		{"<color=green>Ưu đãi Nạp tháng<color>", self.MonthDonate, self},
   		{"Ta chỉ xem qua"}}
	
	Dialog:Say("Cổ Phong Hà: Xin chào!",tbOpt);
end

function tbTuiGuangYuan:FirstDonate()
	local nPayMonth = me.GetExtMonthPay();
	
	local tbOpt = {
   		{"Nhận phần thưởng", self.FirstDonateOK, self},
   		{"Xem phần thưởng", self.FirstDonateView, self},
   		{"Ta chỉ xem qua"}}
	
	Dialog:Say("Cổ Phong Hà:\n\nMỗi tháng, người chơi nạp "..self.nMonthDonatePrice.." vnđ sẽ nhận được Ưu đãi nạp thẻ.\n\n Tích lũy nạp trong tháng: <color=yellow>"..nPayMonth.."<color> vnđ." ,tbOpt);
end

function tbTuiGuangYuan:FirstDonateView()
	Dialog:Say("   Phần thưởng của ngươi gồm:\n- Bạn đồng hành 4 kỹ năng.\n- 10 Thiên Tâm Thạch.\n- Bộ Huyền tinh (5, 6, 7).\n- 1 Thú cưng Tài Bảo Thố (7 ngày).\n- 200 vạn bạc khóa.");
end

function tbTuiGuangYuan:FirstDonateOK(nSure)
	local nCurDate = tonumber(os.date("%Y%m", GetTime()));
	if not nSure then
		if me.GetExtMonthPay() <= 0 then
			Dialog:Say("Cổ Phong Hà:\n\n Tháng này chưa phát sinh nạp thẻ.");
			return 0
		end
		
		if me.CountFreeBagCell() < 30 then
			Dialog:Say("Cổ Phong Hà:\n\n Hành trang không đủ khoảng trống để nhận thưởng.",tbOpt);
			return 0
		end
		
		if me.GetBindMoney() + 2000000 > me.GetMaxCarryMoney() then
			Dialog:Say("Cổ Phong Hà:\n\n Ngân lượng mang theo bên người đã đạt tối đa.",tbOpt);
			return 0
		end
		
		if me.GetTask(self.TSK_GROUP, self.TSK_FIRSTDONATE) > 0 then
			Dialog:Say("Cổ Phong Hà:\n\n Ngươi đã nhận phần thưởng này rồi.",tbOpt);
			return 0
		else
			self:FirstDonateOK(1);
		end
	else
		me.AddStackItem(18,	1, 547,	1, {bForceBind = 1}, 1);
		me.AddStackItem(18, 1, 20426, 1, {bForceBind = 1}, 10);
		me.AddStackItem(18, 1, 114, 5, {bForceBind = 1}, 10);
		me.AddStackItem(18, 1, 114, 6, {bForceBind = 1}, 5);
		me.AddStackItem(18, 1, 114, 7, {bForceBind = 1}, 3);
		me.AddItemEx(18, 1, 1724, 1, {bForceBind = 1}, nil, GetTime() + 3600 * 24 * 7);
		me.AddBindMoney(2000000);
		
		me.AddTitle(999,2,1,1);
		me.SetCurTitle(999,2,1,1);
		
		me.SetTask(self.TSK_GROUP, self.TSK_FIRSTDONATE, nCurDate)
	end
end

function tbTuiGuangYuan:MonthDonate()
	local nPayMonth = me.GetExtMonthPay();
	
	local tbOpt = {
   		{"Nhận phần thưởng", self.MonthDonateOK, self},
   		{"Xem phần thưởng", self.MonthDonateView, self},
   		{"Ta chỉ xem qua"}}
	
	Dialog:Say("Cổ Phong Hà:\n\nMỗi tháng, người chơi nạp "..self.nMonthDonatePrice.." vnđ sẽ nhận được Ưu đãi nạp thẻ.\n\n Tích lũy nạp trong tháng: <color=yellow>"..nPayMonth.."<color> vnđ." ,tbOpt);
end

function tbTuiGuangYuan:MonthDonateView()
	Dialog:Say("   Phần thưởng của ngươi gồm:\n- 1000 Tiền Du Long.\n- 50 Hàn Tinh Thạch.\n- 5000 Ngũ hành hồn thạch.\n- 3 Huyền tinh 9.\n- 500 vạn bạc khóa.");
end

function tbTuiGuangYuan:MonthDonateOK(nSure)
	local nCurDate = tonumber(os.date("%Y%m", GetTime()));
	if not nSure then
		if me.GetExtMonthPay() < self.nMonthDonatePrice then
			Dialog:Say("Cổ Phong Hà:\n\n Tháng này chưa nạp đủ "..self.nMonthDonatePrice.." vnđ.");
			return 0
		end
		
		if me.CountFreeBagCell() < 10 then
			Dialog:Say("Cổ Phong Hà:\n\n Hành trang không đủ khoảng trống để nhận thưởng.",tbOpt);
			return 0
		end
		
		if me.GetBindMoney() + 5000000 > me.GetMaxCarryMoney() then
			Dialog:Say("Cổ Phong Hà:\n\n Ngân lượng mang theo bên người đã đạt tối đa.",tbOpt);
			return 0
		end
		
		if me.GetTask(self.TSK_GROUP, self.TSK_MONTHRECIEVE) == nCurDate then
			Dialog:Say("Cổ Phong Hà:\n\n Tháng này ngươi đã nhận phần thưởng rồi.",tbOpt);
			return 0
		else
			self:MonthDonateOK(1);
		end
	else
		local pItem = me.AddItemEx(1,12,20053,10, {bForceBind=1},nil,GetTime() + 3600 * 24 * 30);
		
		me.AddStackItem(18, 1, 553, 1, {bForceBind = 1}, 1000);
		me.AddStackItem(18, 1, 20448, 1, {bForceBind = 1}, 50);
		me.AddStackItem(18, 1, 205, 1, {bForceBind = 1}, 5000);
		me.AddStackItem(18, 1, 114, 9, {bForceBind = 1}, 3);
		me.AddBindMoney(5000000);
		
		me.AddTitle(999,2,2,1);
		me.SetCurTitle(999,2,2,1);
		
		me.SetTask(self.TSK_GROUP, self.TSK_MONTHRECIEVE, nCurDate)
	end
end

function tbTuiGuangYuan:Giftcode()
	-- Dialog:Say("Hệ thống đang bảo trì!")
	Dialog:AskString("Mã ưu đãi:", 1, self.GiftcodeOK, self);
end

function tbTuiGuangYuan:GiftcodeOK(szGiftcode)
	if me.nLevel < 50 then
		Dialog:Say("Đạt cấp 50 rồi hãy nhận Giftcode để không bỏ qua những phần thưởng hấp dẫn.");
		return
	end
	if szGiftcode == "" then
		Dialog:Say("Hãy nhập mã ưu đãi");
		return
	end
	if string.len(szGiftcode) < 10 then
		Dialog:Say("Mã ưu đãi không phù hợp.")
		return 0;
	end
	local szHeader = string.sub(szGiftcode, 1, 3)
	local szEventName = self:CheckHeader(szHeader);
	
	if szEventName ~= "" then
		Dialog:Say("Mã ưu đãi phù hợp với Event <color=yellow>"..szEventName.."<color>. Bạn muốn nhận chứ?", {"Xác nhận lãnh", self.ReceiveItem, self, szGiftcode}, {"Để ta suy nghĩ thêm"});
	else	
		Dialog:Say("Mã ưu đãi không đúng.")
	end
end

function tbTuiGuangYuan:ReceiveItem(szGiftcode)
	local bRet1, szMsg1 = self:CheckIsUsed(szGiftcode);
	local bRet2, szMsg2 = self:CheckGiftcode(szGiftcode);
	
	if bRet1 == 1 then
		Dialog:Say(szMsg1)
		return
	end
	
	if bRet2 == 1 then
		Dialog:Say(szMsg2)
		return
	end

	local bRet3 = self:CheckHeader(szGiftcode, 1)
end

function tbTuiGuangYuan:CheckGiftcode(szGiftcode)
	local szClassList = "\\setting\\GiftCode.txt";
	local pTabFile = KIo.OpenTabFile(szClassList);
	if (not pTabFile) then
		print("Van kien "..szClassList.." khong mo duoc!");
		return 0;
	end
	
	local tbContent = pTabFile.AsTable();
	local bRet = 1
	
	for i = 1, #tbContent do
		if (szGiftcode == tbContent[i][1]) then
			bRet = 0
			break;
		end
	end
	KIo.CloseTabFile(pTabFile);
	return bRet, "Mã ưu đãi không đúng.";
end

function tbTuiGuangYuan:CheckHeader(szGiftcode, bSure)
	local szClassList = "\\setting\\GiftCode-Award.txt";
	local pTabFile = KIo.OpenTabFile(szClassList);
	if (not pTabFile) then
		print("Van kien "..szClassList.." khong mo duoc!");
		return 0;
	end
	
	local tbContent = pTabFile.AsTable();
	local bRet = ""
	local szHeader = string.sub(szGiftcode, 1, 3)
	
	for i = 2, #tbContent do
		if (szHeader == tbContent[i][1]) then
			bRet = tbContent[i][3]
			if bSure == 1 then
				if me.CountFreeBagCell() < tonumber(tbContent[i][16]) then
					Dialog:Say("Cổ Phong Hà: Hành trang không đủ chỗ trống!");
					KIo.CloseTabFile(pTabFile);
					return
				end
				
				if me.GetTask(2207, tonumber(tbContent[i][2])) >= 1 then
					Dialog:Say("Cổ Phong Hà: Ngươi đã tham gia sự kiện này rồi!");
					KIo.CloseTabFile(pTabFile);
					return
				end
				
				if tonumber(tbContent[i][17]) > me.GetTask(2181,3) or me.GetTask(2181,3) > tonumber(tbContent[i][18]) then
					Dialog:Say("Cổ Phong Hà: Ngươi không nằm trong đối tượng được phép sử dụng!");
					KIo.CloseTabFile(pTabFile);
					return
				end
				me.AddExp(tonumber(tbContent[i][20]))
				me.AddBindCoin(tonumber(tbContent[i][4]))
				me.AddBindMoney(tonumber(tbContent[i][5]))
				for j = 6, 15 do
					if tbContent[i][j] ~= "" then
						local tbItem = tostring(tbContent[i][j])
						local tbGDPL = Lib:SplitStr(tbItem);
						me.AddStackItem(tonumber(tbGDPL[1]), tonumber(tbGDPL[2]), tonumber(tbGDPL[3]) ,tonumber(tbGDPL[4]), {bForceBind = 1}, tonumber(tbGDPL[5]));
					else
						break;
					end
				end
				-- if szHeader == "FC2" then
					-- local pItem = me.AddItem(1, 13, 150 + (2 * me.nSex), 10)
					-- pItem.SetTimeOut(0, GetTime() + 3600 * 24 * 30);
					-- pItem.Sync();
				-- end
				me.SetTask(2207, tonumber(tbContent[i][2]), 1)
				KGCPlayer.SetPlayerPrestige(me.nId, 20);
				KDialog.NewsMsg(1, Env.NEWSMSG_COUNT, "Người chơi <color=green>"..me.szName.."<color> nhận phần thưởng từ Giftcode <color=red>"..tbContent[i][3].."<color>");
				KDialog.MsgToGlobal("Người chơi <color=green>"..me.szName.."<color> nhận phần thưởng từ Giftcode <color=red>"..tbContent[i][3].."<color>");	
				
				local szDate = os.date("%H:%M:%S %d/%m/%Y ", GetTime());
				local szOutput = szGiftcode.."\t"..me.szAccount.."\t"..me.szName.."\t"..me.dwIp.."\t"..szDate.."\n";
				KIo.AppendFile("\\..\\GiftCode-Used.txt", szOutput);
			end
			break;
		end
	end
	KIo.CloseTabFile(pTabFile);
	return bRet;
end

function tbTuiGuangYuan:CheckIsUsed(szGiftcode)
	local bRet = 0;
	local szMsg = "";

	local szClassList2 = "\\setting\\GiftCode-Award.txt";
	local pTabFile2 = KIo.OpenTabFile(szClassList2);
	if (not pTabFile2) then
		print("Van kien "..szClassList.." khong mo duoc!");
		return 0;
	end
	
	local szHeader = string.sub(szGiftcode, 1, 3)
	local tbContent2 = pTabFile2.AsTable();
	for i = 2, #tbContent2 do
		if (szHeader == tbContent2[i][1]) then
			if tonumber(tbContent2[i][19]) == 1 then
				bRet = 2;
				break;
			end
		end
	end
	if bRet == 2 then
		KIo.CloseTabFile(pTabFile2);
		return bRet, szMsg;
	end
	
	local szClassList = "\\..\\GiftCode-Used.txt";
	local pTabFile = KIo.OpenTabFile(szClassList);
	if (not pTabFile) then
		print("Van kien "..szClassList.." khong mo duoc!");
		return 0;
	end

	local tbContent = pTabFile.AsTable();
	for i = 1, #tbContent do
		if (tbContent[i][1] == szGiftcode) then
			bRet = 1
			szMsg = "Mã kích hoạt này đã được sử dụng cho nhân vật <color=yellow>"..tbContent[i][3].."<color> rồi."
			break;
		end
	end
	KIo.CloseTabFile(pTabFile);
	return bRet, szMsg;
end
