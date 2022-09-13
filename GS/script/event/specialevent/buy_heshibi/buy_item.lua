-- 文件名  : buy_item.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-06-11 16:08:38
-- 描述    : 

SpecialEvent.BuyItem = SpecialEvent.BuyItem or {};
local tbBuyItem = SpecialEvent.BuyItem;
--tbBuyItem.TSK_GROUP 	=2027;
--tbBuyItem.TSK_ID 		=70;		--可以购买和氏壁数量
--tbBuyItem.TSK_DATE 		=91;		--增加和氏壁次数时间
--tbBuyItem.DEF_COIN 		=8000;	--需要金币数
--tbBuyItem.DEF_CWAREID 	=380;	--奇珍阁表Id
--tbBuyItem.DEF_CLSDATE 	=20;	--次数累加间隔20天清除


--物品list  {物品名字, {g,d,p,l}, 价格，奇珍阁表Id, 任务变量组，购买数量任务变量id， 增加次数时间任务变量id， 次数累加间隔(0为默认下月清零，1为隔天清), 是否绑定0否1是，是否有有效期0否1是}
tbBuyItem.tbItemList = {
	[1] = {"Anh Hùng Lệnh",{18,1,487,1},21888, 235, 2027, 154, 155, 0, 0, 0},
	[2] = {"Kỷ niệm chương Thịnh Hạ 2010",{18,1,663,1},7000, 243, 2027, 157, 158, 0, 0, 0},
	[3] = {"Hoàng Kim Tinh Hoa",{18,1,565,2},100, 244, 2027, 159, 160, 0, 0, 0},
	[4] = {"Tần Lăng-Hòa Thị Bích",{18,1,377,1},8000, 245, 2027, 161, 162, 0, 0, 0},
	[5] = {"Bạch Ngọc",{18,1,916,1},7500, 262, 2027, 164, 165, 20, 0, 0},
	[6] = {"Gói huyền tinh cấp 7 (-70%)",{18,1,1,7,2},2366, 272, 2027, 178, 179, 0, 0, 0},
	[7] = {"Gói huyền tinh cấp 7 (-50%)",{18,1,1,7,2},1690, 273, 2027, 180, 181, 0, 0, 0},
	[8] = {"Rương Hồn Thạch (100) (-70%)",{18,1,244,1,2},1120, 274, 2027, 182, 183, 0, 0, 0},
	[9] = {"Rương Hồn Thạch (100) (-50%)",{18,1,244,1,2},800, 275, 2027, 184, 185, 0, 0, 0},
	[10] = {"Rương Hồn Thạch (1000) (-70%)",{18,1,244,2,2},10920, 276, 2027, 186, 187, 0, 0, 0},
	[11] = {"Rương Hồn Thạch (1000) (-50%)",{18,1,244,2,2},7800, 277, 2027, 188, 189, 0, 0, 0},
	[12] = {"Kỷ niệm giải Nữ anh hùng [24 ô]",{21,9,6,1},50000, 279, 2027, 193, 194, 0, 0, 0},
	[13] = {"Du Long Tinh Khí Hoàn",{18,1,532,1},240, 281, 2027, 195, 196, 0, 1, 0},
	[14] = {"Du Long Hoạt Khí Hoàn",{18,1,531,1},240, 282, 2027, 197, 198, 0, 1, 0},
	[15] = {"Bổ Tu Lệnh",{18,1,479,1},3000, 283, 2027, 199, 200, 0, 0, 1},
	[16] = {"Xích Thố Lệnh",{1,12,45,4},1200, 284, 2027, 201, 202, 0, 0, 1},
	[17] = {"Tuyết Hồn Lệnh",{18,1,512,1},6000, 285, 2027, 203, 204, 0, 0, 0},
	[18] = {"Tần Lăng-Hòa Thị Bích",{18,1,377,1}, 7000, 433, 2027, 205, 206, 0, 0, 0},
	[19] = {"Tần Lăng-Mạc Kim Phù x50",{18,1,366,1,50}, 5000, 432, 2027, 207, 208, 0, 0, 0},
	[20] = {"Bách Bộ Xuyên Dương Cung x50",{18,1,263,1,50}, 5000, 431, 2027, 209, 210, 0, 0, 0},
	[21] = {"Lệnh bài mở rộng rương Lv3",{18,1,216,3}, 50000, 287, 2027, 220, 221, 0, 1, 0},
	[22] = {"Tinh Khí Tán (500) x5",{18, 1, 89, 1,5}, 80, 448, 2027, 222, 223, 1, 1, 1},
	[23] = {"Hoạt Khí Tán (500) x5",{18, 1, 90, 1,5}, 80, 449, 2027, 224, 225, 1, 1, 1},
	[24] = {"Rương Chân Nguyên-Cao",{18, 1, 738, 1}, 180000, 288, 2027, 226, 227, 0, 1, 0},
	[25] = {"Mảnh Lôi Đình Ấn",{18, 1, 741, 1}, 240000, 289, 2027, 228, 229, 0, 0, 0},
};

function tbBuyItem:Check(nNum)
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang bị khóa, không thể thao tác!");
		return;
	end
	if self:CheckCls(nNum) == 0 then
		Dialog:Say("Hoạt động bị sai.");
		return 0;
	end
 
	if me.GetTask(self.tbItemList[nNum][5], self.tbItemList[nNum][6]) <= 0 then
		Dialog:Say(string.format("Số lượng vật phẩm có hạn. Ngươi không thể mua <color=yellow>%s<color>.", self.tbItemList[nNum][1]));
		return 0;
	end
	
	if IVER_g_nSdoVersion == 0 and me.GetJbCoin() < self.tbItemList[nNum][3] then
		Dialog:Say(string.format("Đồng không đủ. 1 <color=yellow>%s<color> có giá %s đồng.", self.tbItemList[nNum][1], self.tbItemList[nNum][3]));
		return 0;
	end
	
	local nNeedCount = 1;
	nNeedCount = KItem.GetNeedFreeBag(self.tbItemList[nNum][2][1], self.tbItemList[nNum][2][2], self.tbItemList[nNum][2][3], self.tbItemList[nNum][2][4], {bTimeOut= self.tbItemList[nNum][10]}, self.tbItemList[nNum][2][5] or 1);	
	if me.CountFreeBagCell() < nNeedCount then
		me.Msg(string.format("Hành trang không đủ %s ô trống.", nNeedCount));
		return 0;
	end	
	return 1;
end

function tbBuyItem:BuyOnDialog(nNum, nSure)
	if self:Check(nNum) ~= 1 then
		return 0;
	end
	
	if not nSure then
		local nSum = me.GetTask(self.tbItemList[nNum][5], self.tbItemList[nNum][6]);
		local szMsg = string.format("Ngươi có thể mua <color=yellow>%s %s<color>. Mỗi <color=yellow>%s<color> có giá <color=yellow>%s<color> %s.", nSum, self.tbItemList[nNum][1], self.tbItemList[nNum][1], self.tbItemList[nNum][3], IVER_g_szCoinName);
		local tbOpt = {
			{"Ta chắc chắn",self.BuyOnDialog, self, nNum, 1},
			{"Để ta suy nghĩ lại"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end	
	me.ApplyAutoBuyAndUse(self.tbItemList[nNum][4], 1);
	if IVER_g_nSdoVersion == 0 then
		Dialog:Say(string.format("Đã mua thành công 1 <color=yellow>%s<color>", self.tbItemList[nNum][1]));
	end
	return 1;
end

function tbBuyItem:AddCount(nNum, nCount)
	if self:CheckCls(nNum) == 0 then
		Dialog:Say("Hoạt động không đúng!");
		return 0;
	end
	local nSum = me.GetTask(self.tbItemList[nNum][5], self.tbItemList[nNum][6]);
	me.SetTask(self.tbItemList[nNum][5], self.tbItemList[nNum][6], nSum + nCount);
	
	me.Msg(string.format("Nhận được <color=yellow>%s lần<color>cơ hội mua <color=yellow>%s<color.", nSum + nCount, self.tbItemList[nNum][1]));
	
	if (self.tbItemList[nNum][8] == 1) then
		me.Msg(string.format("Cơ hội mua <color=yellow>%s<color> sẽ vô hiệu hóa vào ngày mai, hãy sử dụng trong hôm nay.", self.tbItemList[nNum][1]));
	elseif (self.tbItemList[nNum][8] == 0) then
		me.Msg(string.format("Cơ hội mua <color=yellow>%s<color> sẽ vô hiệu hóa ở tháng tới, hãy sử dụng trong tháng này.", self.tbItemList[nNum][1]));
	end
	
	return 1;
end

function tbBuyItem:GetCount(nNum)
	if self:CheckCls(nNum) == 0 then
		Dialog:Say("Hoạt động không đúng!");
		return 0;
	end
	return me.GetTask(self.tbItemList[nNum][5], self.tbItemList[nNum][6])
end

function tbBuyItem:CheckCls(nNum)
	local nCurSec = GetTime()
	if nNum <= 0 or not self.tbItemList[nNum] then		
		return 0;
	end
	local nSaveSec = me.GetTask(self.tbItemList[nNum][5], self.tbItemList[nNum][7]);
	if self.tbItemList[nNum][8] == 1 then
		if nSaveSec <= 0 or tonumber(os.date("%Y%m%d", nSaveSec)) < tonumber(os.date("%Y%m%d", nCurSec)) then
			me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("%s số lần mua là 0", self.tbItemList[nNum][1]));
			me.SetTask(self.tbItemList[nNum][5], self.tbItemList[nNum][6], 0);
			me.SetTask(self.tbItemList[nNum][5], self.tbItemList[nNum][7], nCurSec);
		end
	elseif nSaveSec <= 0 or tonumber(os.date("%Y%m", nSaveSec)) < tonumber(os.date("%Y%m", nCurSec)) then
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("%s số lần mua là 0", self.tbItemList[nNum][1]));
		me.SetTask(self.tbItemList[nNum][5], self.tbItemList[nNum][6], 0);
		me.SetTask(self.tbItemList[nNum][5], self.tbItemList[nNum][7], nCurSec);
	end
	return 1;
end

function tbBuyItem:Consume(nNum)
	if self:CheckCls(nNum) == 0 then
		Dialog:Say("Hoạt động không đúng!");
		return 0;
	end
	local nSum = me.GetTask(self.tbItemList[nNum][5], self.tbItemList[nNum][6]);
	if nSum <= 0 then
		return 0;
	end
	me.SetTask(self.tbItemList[nNum][5], self.tbItemList[nNum][6], nSum - 1);
	EventManager.tbChongZhiEvent:GetData(1);
	return 1;
end

local tbCoinItem = Item:GetClass("coin_arm_item");
	
function tbCoinItem:OnUse()	
	local nNum 	= tonumber(it.GetExtParam(1)) or 0;
	if nNum <= 0 or not SpecialEvent.BuyItem.tbItemList[nNum] then
		me.Msg("Có lỗi xảy ra, liên hệ với GM!");
		return 0;
	end
	local tbItemEx = SpecialEvent.BuyItem.tbItemList[nNum][2] or {};
	if #tbItemEx~= 4 and #tbItemEx ~= 5 then
		me.Msg("Có lỗi xảy ra, liên hệ với GM!");
		return 0;
	end
	local nNeedCount = 1;
	local nCount = SpecialEvent.BuyItem.tbItemList[nNum][2][5] or 1;
	nNeedCount = KItem.GetNeedFreeBag(SpecialEvent.BuyItem.tbItemList[nNum][2][1], SpecialEvent.BuyItem.tbItemList[nNum][2][2], SpecialEvent.BuyItem.tbItemList[nNum][2][3], SpecialEvent.BuyItem.tbItemList[nNum][2][4], {bTimeOut= SpecialEvent.BuyItem.tbItemList[nNum][10]}, nCount);	
	if me.CountFreeBagCell() < nNeedCount then
		me.Msg(string.format("Hành trang không đủ %s ô trống.", nNeedCount));
		return 0;
	end	
	for i = 1, nCount do
		local pItem = me.AddItemEx(tbItemEx[1], tbItemEx[2], tbItemEx[3], tbItemEx[4]);
		--不公告
		if pItem then
			if SpecialEvent.BuyItem.tbItemList[nNum][9] and SpecialEvent.BuyItem.tbItemList[nNum][9] == 1 then
				pItem.Bind(1);
			end
			if SpecialEvent.BuyItem.tbItemList[nNum][10] and SpecialEvent.BuyItem.tbItemList[nNum][10] == 1 then
				local szDate = os.date("%Y/%m/%d/%H/%M/%S", GetTime() + 3600*24*30);
				me.SetItemTimeout(pItem, szDate);
			end
			local szLog = string.format("自动使用获得了1个<color=yellow>%s<color>", SpecialEvent.BuyItem.tbItemList[nNum][1]);
			Dbg:WriteLog("Player.tbBuyItemInQiZhenGe", "购买奇珍阁道具", me.szAccount, me.szName, szLog);
		end
	end
	SpecialEvent.BuyItem:Consume(nNum);
	return 1;
end
