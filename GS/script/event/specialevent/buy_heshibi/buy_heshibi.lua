-- 文件名　：buy_heshibi.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-07-17 15:00:48
-- 描  述  ：

SpecialEvent.BuyHeShiBi = SpecialEvent.BuyHeShiBi or {};
local tbBuyItem = SpecialEvent.BuyHeShiBi;
tbBuyItem.TSK_GROUP 	=2027;
tbBuyItem.TSK_ID 		=70;		--可以购买和氏壁数量
tbBuyItem.TSK_DATE 		=91;		--增加和氏壁次数时间
tbBuyItem.DEF_COIN 		=8000;	--需要金币数
tbBuyItem.DEF_CWAREID 	=380;	--奇珍阁表Id
tbBuyItem.DEF_CLSDATE 	=20;	--次数累加间隔20天清除(取消，下月清0)

function tbBuyItem:Check()
	self:CheckCls();

	if me.GetTask(self.TSK_GROUP, self.TSK_ID) <= 0 then
		Dialog:Say("Số lượng Hòa Thị Bích có hạn. Ngươi không thể mua");
		return 0;
	end
	
	if IVER_g_nSdoVersion == 0 and me.GetJbCoin() < self.DEF_COIN then
		Dialog:Say(string.format("Không đủ đồng để mua. 1 <color=yellow>Tần Lăng-Hòa Thị Bích<color>có giá %s đồng.", self.DEF_COIN));
		return 0;
	end
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say(string.format("Hành trang không đủ 1 ô trống."));
		return 0;	
	end
	return 1;
end

function tbBuyItem:BuyOnDialog(nSure)
	if self:Check() ~= 1 then
		return 0;
	end
	if not nSure then
		local nSum = me.GetTask(self.TSK_GROUP, self.TSK_ID);
		local szMsg = string.format("Ngươi muốn mua <color=yellow>%s Tần Lăng-Hòa Thị Bích<color>. Mỗi <color=yellow>Tần Lăng-Hòa Thị Bích<color> với giá <color=yellow>%s<color> %s.", nSum, self.DEF_COIN, IVER_g_szCoinName);
		local tbOpt = {
			{"Ta chắc chắn",self.BuyOnDialog, self, 1},
			{"Để ta suy nghĩ lại"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	me.ApplyAutoBuyAndUse(self.DEF_CWAREID, 1);
	if IVER_g_nSdoVersion == 0 then
		Dialog:Say(string.format("Mua thành công 1 <color=yellow>Tần Lăng-Hòa Thị Bích<color>"));
	end

	return 1;
end

function tbBuyItem:AddCount(nCount)
	self:CheckCls();
	local nSum = me.GetTask(self.TSK_GROUP, self.TSK_ID);
	me.SetTask(self.TSK_GROUP, self.TSK_ID, nSum + nCount);
	return 1;
end

function tbBuyItem:GetCount(nCount)
	self:CheckCls();
	return me.GetTask(self.TSK_GROUP, self.TSK_ID);
end

function tbBuyItem:CheckCls()
	local nCurSec = GetTime()
	local nSaveSec = me.GetTask(self.TSK_GROUP, self.TSK_DATE);
	if nSaveSec <= 0 or tonumber(os.date("%Y%m", nSaveSec)) < tonumber(os.date("%Y%m", nCurSec)) then
	--if (nSaveSec + self.DEF_CLSDATE * 24*3600) < nCurSec then
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "Tần Lăng-Hòa Thị Bích số lần mua là 0");
		me.SetTask(self.TSK_GROUP, self.TSK_ID, 0);
		me.SetTask(self.TSK_GROUP, self.TSK_DATE, nCurSec);
	end	
end

function tbBuyItem:Consume()
	local nSum = me.GetTask(self.TSK_GROUP, self.TSK_ID);
	if nSum <= 0 then
		return 0;
	end
	me.SetTask(self.TSK_GROUP, self.TSK_ID, nSum - 1);
	EventManager.tbChongZhiEvent:GetData(1);
	return 1;
end

local tbCoinItem = Item:GetClass("coin_qinling_arm_item");
	
function tbCoinItem:OnUse()
	if me.CountFreeBagCell() < 1 then
		me.Msg(string.format("Hành trang không đủ 1 ô trống."));
		return 0;
	end	
	local tbItemInfo = {bTimeOut=1, bForceBind=1, bMsg = 0};
	local pItem = me.AddItemEx(18, 1, 377, 1, tbItemInfo);
	--不公告
	if pItem then
		SpecialEvent.BuyHeShiBi:Consume();
		pItem.Bind(1);
		local szDate = os.date("%Y/%m/%d/%H/%M/%S", GetTime() + 3600*24*30);
		me.SetItemTimeout(pItem, szDate);
		local szLog = string.format("自动使用获得了1个Tần Lăng-Hòa Thị Bích");
		Dbg:WriteLog("Player.tbBuyJingHuo", "优惠购买精活", me.szAccount, me.szName, szLog);
	end
	return 1;
end

	