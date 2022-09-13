-------------------------------------------------------------------
--File: tuiguangyuan.lua
--Author: kenmaster
--Date: 2008-06-04 03:00
--Describe: 活动推广员npc脚本
-------------------------------------------------------------------
local tbTuiGuangYuan = Npc:GetClass("shengxia_tuiguangyuan");

function tbTuiGuangYuan:OnDialog()
	local tbOpt = {
		}
	local szMsg = "Xin chào, Làm thế nào ta có thể giúp cho ngươi?";
	
	table.insert(tbOpt,{"Mua đạo cụ Kỳ Trân Các", self.OnBuyIbShopItem, self});
	
	
	if SpecialEvent.tbYanHua:CheckEventTime() == 1 then
		table.insert(tbOpt,{"Nhận pháo hoa sự kiện thịnh hạ", SpecialEvent.tbYanHua.DialogLogic, SpecialEvent.tbYanHua})
	end
	
	if SpecialEvent.HundredKin:CheckEventTime2("award") == 1 then
		table.insert(tbOpt,{"Nhận thưởng Bách Đại Gia Tộc", SpecialEvent.HundredKin.DialogLogic, SpecialEvent.HundredKin})
	end
			
	if Npc.IVER_nShengXiaTuiGuanYuan == 1 then
		if SpecialEvent.ZhongQiu2008:CheckTime() == 1 then
			table.insert(tbOpt, 1, {"Sử dụng Uy danh mua nguyên liệu Bánh Trung Thu", SpecialEvent.ZhongQiu2008.OnAward, SpecialEvent.ZhongQiu2008})
		end	
		
		if SpecialEvent.WangLaoJi:CheckEventTime(4) == 1 then
			table.insert(tbOpt, 1, {"Nhận thưởng hoạt động Vương Lão Cát", SpecialEvent.WangLaoJi.OnDialog, SpecialEvent.WangLaoJi})
		end
		
		if SpecialEvent.WangLaoJi:CheckExAward() == 1 then
			table.insert(tbOpt, 1, {"<color=red>Nhận phần thưởng bổ sung", SpecialEvent.WangLaoJi.GetWeekFinishAward, SpecialEvent.WangLaoJi})		
		end
	end
	
	if (SpecialEvent.tbWroldCup:GetOpenState() == 1 or SpecialEvent.tbWroldCup:GetOpenState() == 2) then
		table.insert(tbOpt, 1, {"Sự kiện thịnh hạ 2010", SpecialEvent.tbWroldCup.tbNpc.OnDialog, SpecialEvent.tbWroldCup.tbNpc});
	end
	
	table.insert(tbOpt, {"Kết thúc đối thoại"});
	Dialog:Say(szMsg, tbOpt);
end

function tbTuiGuangYuan:OnBuyIbShopItem()
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang bị khóa, không thể thao tác!");
		return;
	end
	if Account:Account2CheckIsUse(me, 4) == 0 then
		Dialog:Say("Ngươi đang sử dụng mật khẩu phụ, không thể thao tác!");
		return 0;
	end	
	local szMsg = "Xin chào, ngươi có thể mua tất cả đạo cụ ở đây nếu đủ điều kiện.";
	local tbOpt = {
		{"Anh Hùng Lệnh", SpecialEvent.BuyItem.BuyOnDialog, SpecialEvent.BuyItem, 1},
		{"Kỷ niệm chương Thịnh Hạ 2010", SpecialEvent.BuyItem.BuyOnDialog, SpecialEvent.BuyItem, 2},
		{"Hoàng Kim Tinh Hoa", SpecialEvent.BuyItem.BuyOnDialog, SpecialEvent.BuyItem, 3},
		{"Tần Lăng-Hòa Thị Bích", SpecialEvent.BuyItem.BuyOnDialog, SpecialEvent.BuyItem, 4},
		-- {"Mua Tần lăng-Hòa Thị Bích", SpecialEvent.BuyHeShiBi.BuyOnDialog, SpecialEvent.BuyHeShiBi},
		{"Bạch Ngọc", SpecialEvent.BuyItem.BuyOnDialog, SpecialEvent.BuyItem, 5},
		{"Kỷ niệm giải Nữ anh hùng [24 ô]", SpecialEvent.BuyItem.BuyOnDialog, SpecialEvent.BuyItem, 12},
		{"Lệnh bài mở rộng rương Lv3", SpecialEvent.BuyItem.BuyOnDialog, SpecialEvent.BuyItem, 21},
		{"Rương Chân Nguyên-Cao", SpecialEvent.BuyItem.BuyOnDialog, SpecialEvent.BuyItem, 24},
		{"Kết thúc đối thoại"},
	};
	if EventManager.IVER_bOpenChongzhiPaiZi == 0 then
		tbOpt = {
		{"Gói huyền tinh cấp 7 (-70%)", SpecialEvent.BuyItem.BuyOnDialog, SpecialEvent.BuyItem, 6},
		{"Gói huyền tinh cấp 7 (-50%)", SpecialEvent.BuyItem.BuyOnDialog, SpecialEvent.BuyItem, 7},
		{"Rương Hồn Thạch (100) (-70%)", SpecialEvent.BuyItem.BuyOnDialog, SpecialEvent.BuyItem, 8},
		{"Rương Hồn Thạch (100) (-50%)", SpecialEvent.BuyItem.BuyOnDialog, SpecialEvent.BuyItem, 9},
		{"Rương Hồn Thạch (1000) (-70%)", SpecialEvent.BuyItem.BuyOnDialog, SpecialEvent.BuyItem, 10},
		{"Rương Hồn Thạch (1000) (-50%)", SpecialEvent.BuyItem.BuyOnDialog, SpecialEvent.BuyItem, 11},
		{"Du Long Tinh Khí Hoàn", SpecialEvent.BuyItem.BuyOnDialog, SpecialEvent.BuyItem, 13},
		{"Du Long Hoạt Khí Hoàn", SpecialEvent.BuyItem.BuyOnDialog, SpecialEvent.BuyItem, 14},
		{"Bổ Tu Lệnh", SpecialEvent.BuyItem.BuyOnDialog, SpecialEvent.BuyItem, 15},
		{"Xích Thố Lệnh", SpecialEvent.BuyItem.BuyOnDialog, SpecialEvent.BuyItem, 16},
		{"Tần Lăng-Hòa Thị Bích", SpecialEvent.BuyItem.BuyOnDialog, SpecialEvent.BuyItem, 18},
		{"Tần Lăng-Mạc Kim Phù x50", SpecialEvent.BuyItem.BuyOnDialog, SpecialEvent.BuyItem, 19},
		{"Bách Bộ Xuyên Dương Cung x50", SpecialEvent.BuyItem.BuyOnDialog, SpecialEvent.BuyItem, 20},
		{"Kết thúc đối thoại"},
	};
	end
	Dialog:Say(szMsg, tbOpt);
end
