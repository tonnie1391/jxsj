-- 优惠券
-- ExtParam1：物品的WareId
-- GenInfo: 使用次数，默认为1
local tbItem = Item:GetClass("coupon");

--TODO: dengyong 这个结构适用于对单种商品有效的优惠券，如果有对多种商品都有效的优惠券的话，需要修改这个结构。
tbItem.tbWareInfo = {
 --nWareId    szDescrip  nDiscountRate  对应商品的"g-d-p-l"	 购买的商品是否立即绑定
	[359] = {"Đại Bạch Câu Hoàn giảm 70%", 30, "18-1-71-2", 1},
	[360] = {"Càn Khôn Phù giảm 70%", 30, "18-1-85-1", 1},
	[361] = {"Huyền Tinh 7 giảm 70%", 30, "18-1-1-7", 1},
	[362] = {"Huyền Tinh 9 giảm 70%", 30, "18-1-1-9", 1},
	};

function tbItem:GetWareInfo()
	return self.tbWareInfo;
end

function tbItem:CalDiscount(tbWareList)
	--对优惠券的可用性进行判断，似乎将这个判断放在将优惠券放入格子的事件回调中更恰当一些，这里先将这段代码注释掉
	--local nRes, szMsg = self:Check(it.dwId);
	--if nRes == 0 then
	--	return szMsg;
	--end
	if not tbWareList then
		return {};
	end
	
	assert(it);
	assert(me);
	
	local tbRet = {};
	local pItem = KItem.GetObjById(it.dwId);
	local nWareId = pItem.GetExtParam(1);
	
	-- furuilei:旧优惠券的默认使用次数是0，需要在这里对次数进行手工加1
	local nTimes = pItem.GetGenInfo(1);
	if (0 == nTimes) then
		nTimes = nTimes + 1;
	end
	
	for nIndex, tbData in pairs(tbWareList) do
		local tbInfo = me.IbShop_GetWareInf(tbData.nWareId);
		
		if tbInfo.nCurrencyType == 0 then	--只有金币区才能使用优惠券(程序中0表示金币，1表示银两，2表示绑金)
			local szWareIndex = string.format("%s-%s-%s-%s", tbInfo.nGenre, tbInfo.nDetailType, 
				tbInfo.nParticular, tbInfo.nLevel);
				
			local nActualDiscountTimes, nDiscountRate = 0, 0;
			if szWareIndex == self.tbWareInfo[nWareId][3] then	
				--打折率
				nDiscountRate = self.tbWareInfo[nWareId][2];

				--实际打折商品的数量
				nActualDiscountTimes = nTimes > tbData.nCount and tbData.nCount or nTimes; 
				nTimes = nTimes - nActualDiscountTimes;
				local bBind = self.tbWareInfo[nWareId][4]	--是否获取绑定 1是， 0否
				table.insert(tbRet, {tbData.nWareId, nActualDiscountTimes, nDiscountRate, bBind});
			end
		end
	end	
	
	return tbRet;
end

function tbItem:CanCouponUse(dwId)
	assert(dwId);
	local pItem = KItem.GetObjById(dwId);
	if not pItem then
		return 0, "你的优惠券已过期。";
	end
	
	local nWareId = pItem.GetExtParam(1);
	local tbWareInfo = self.tbWareInfo[nWareId];
	
	if IVER_g_nSdoVersion == 0 and me.GetJbCoin() < tbWareInfo[2] then
		return 0, string.format("%s của ngươi không đủ, mua 1 %s cần %d %s", IVER_g_szCoinName, tbWareInfo[1], tbWareInfo[2], IVER_g_szCoinName);
	end
	
	if me.IsAccountLock() ~= 0 then
		return 0, "你还处于锁定状态";
	end
	
	return 1, pItem;
end

function tbItem:DecreaseCouponTimes(tbCouponWare)
	if not tbCouponWare then
		return 0;
	end

	assert(it)
	local pItem = KItem.GetObjById(it.dwId);
	if not pItem then
		return 0;
	end

	local nWareId = pItem.GetExtParam(1);
	local nTimes = pItem.GetGenInfo(1);
	local nToDelTimes = 0;					--需要扣除的次数
	--furuilei:旧优惠券的默认次数是0，需要手工加1
	if (0 == nTimes) then
		nTimes = nTimes + 1;
	end
	
	if nTimes == 0 then
		pItem.Delete(me);
		return 0;
	end
		
	for nIndex, tbData in pairs(tbCouponWare) do
		local tbInfo = me.IbShop_GetWareInf(tbData[1]);
				
		local szWareIndex = string.format("%s-%s-%s-%s", tbInfo.nGenre, tbInfo.nDetailType, 
			tbInfo.nParticular, tbInfo.nLevel);
			
		if szWareIndex == self.tbWareInfo[nWareId][3] then
			nToDelTimes = nToDelTimes + tbData[2];
		end
	end
	
	if nToDelTimes > nTimes then	--要扣除的次数大于剩余次数
		Dbg:WriteLog("coupon", "Số ưu đãi lớn hơn số vé ưu đãi còn lại!");
		return 0;
	end
	
	nTimes = nTimes - nToDelTimes; 
	
	if nTimes == 0 then
		pItem.Delete(me);
	else
		pItem.SetGenInfo(1, nTimes);
		pItem.Sync();
	end
	
	return 1;
end

-------------------------------------------------------
--中间物品
local tbBaijuwan = Item:GetClass("newcoupon_temp");

function tbBaijuwan:OnUse()	
	Item:GetClass("newcoupon"):AddItem(it.dwId);
	Dbg:WriteLog("TempItem", me.szName, it.szName);
end

-------------------------------------------------------
-- by zhangjinpin@kingsoft
-------------------------------------------------------
local tbNewItem = Item:GetClass("newcoupon");

tbNewItem.tbWareInfo = 
{--nWareId    szDescrip    nDicountRate  对应商品的"g-d-p-l"  购买的商品是否立即绑定, 真正的nWareId，价格，原价, 原来物品名字
	[359] = {"Đại Bạch Câu Hoàn giảm 70%", 30, "18-1-71-2", 1,66, 220, "Đại Bạch Câu Hoàn"},
	[360] = {"Càn Khôn Phù giảm 70%", 30, "18-1-85-1", 1, 60, 200, "Càn Khôn Phù"},
	[361] = {"Huyền Tinh 7 giảm 70%", 30, "18-1-1-7", 1, 672, 2240, "Huyền Tinh cấp 7"},
	[362] = {"Huyền Tinh 9 giảm 70%", 30, "18-1-1-9", 1, 8640, 28800, "Huyền Tinh cấp 9"},
	[383] = {"Giảm 50% phí mua Thỏi bạc bang hội (lớn)", 50, "18-1-284-2", 1, 5000, 10000, "Thỏi bạc bang hội (đại)"},
	[519] = {"Mua Tinh Khí Tán giảm 60% (Hồi 1500)", 30, "18-1-89-3", 1, 120, 300, "Mua Tinh Khí Tán (Hồi 1500)"},
	[520] = {"Mua Hoạt Khí Tán giảm 60% (Hồi 1500)", 30, "18-1-90-3", 1, 120, 300, "Mua Hoạt Khí Tán (Hồi 1500)"},
	[669] = {"Mua Tinh Khí Tán giảm 60% (Hồi 1000)", 30, "18-1-89-2", 1, 48, 120, "Mua Tinh Khí Tán (Hồi 1000)"},
	[670] = {"Mua Hoạt Khí Tán giảm 60% (Hồi 1000)", 30, "18-1-90-2", 1, 48, 120, "Mua Hoạt Khí Tán (Hồi 1000)"},
	[610] = {"Rương Hồn Thạch giảm 80% (1000 cái)", 20, "18-1-244-2", 1, 1600, 8000, "Rương Hồn Thạch (1000 cái)"},
};

function tbNewItem:OnUse()
	local nWareId = it.GetExtParam(1);
	local nTimes = it.GetExtParam(3) - it.GetGenInfo(1);
	local tbWareInfo = self.tbWareInfo[nWareId];
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Ngươi còn ở trạng thái khóa");
		return 0;
	end
	if Account:Account2CheckIsUse(me, 4) == 0 then
		Dialog:Say("Bạn đang đăng nhập trò chơi bằng mật mã phụ, không thể thực hiện thao tác này!");
		return 0;
	end
	if not tbWareInfo then
		return 0;
	end
	if IVER_g_nSdoVersion == 0 and me.GetJbCoin() < tbWareInfo[5] then
		Dialog:Say(string.format("%s không đủ, mua 1 %s cần <color=yellow>%d %s<color>, lần mua này tiết kiệm được <color=yellow>%d %s<color>", IVER_g_szCoinName, tbWareInfo[1], tbWareInfo[5], IVER_g_szCoinName, tbWareInfo[6] -tbWareInfo[5], IVER_g_szCoinName), {{"Ta hiểu rồi"}});
		return 0
	end
	if me.CountFreeBagCell() <= 0 then
		Dialog:Say("Cần 1 ô túi trống.");
		return;
	end
	Dialog:Say(string.format("Giá khi dùng phiếu: <color=yellow>%s %s<color>.\n<color=yellow>%s<color> giá gốc <color=yellow>%s %s<color>, phiếu ưu đãi này tiết kiệm <color=yellow>%s %s<color>.", tbWareInfo[5], IVER_g_szCoinName, tbWareInfo[7], tbWareInfo[6], IVER_g_szCoinName, tbWareInfo[6] - tbWareInfo[5], IVER_g_szCoinName), 
		{{"Xác nhận mua (mua xong khóa)", self.OnBuyItem, self, it.dwId, nWareId, nTimes}, {"Mua sau"}});
	return;
end

function tbNewItem:GetNewCoupon()
	Dialog:Say("Vé giảm giá là một trong những phúc lợi và chính sách Kiếm Thế dành cho bạn, có thể dùng để <color=yellow>mua giảm giá Huyền Tinh 7/Huyền Tinh 9/Đại Bạch Câu Hoàn/Càn Khôn Phù<color>.\nVé giảm giá là một trong những phần thưởng nhiệm vụ hoặc hoạt động, bạn còn được nhận thêm bằng cách tham gia <color=yellow>hoạt động nạp thẻ tháng<color>.", {"Ta hiểu rồi"});
end

function tbNewItem:OnBuyItem(dwId, nWareId, nTimes)
	local pItem = KItem.GetObjById(dwId);
	if not pItem then
		Dialog:Say("Vé ưu đãi của ngươi đã hết hạn.");
		return;
	end
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Ngươi còn ở trạng thái khóa");
		return 0;
	end
	if Account:Account2CheckIsUse(me, 4) == 0 then
		Dialog:Say("Bạn đang đăng nhập trò chơi bằng mật mã phụ, không thể thực hiện thao tác này!");
		return 0;
	end
	local tbWareInfo = self.tbWareInfo[nWareId];
	if IVER_g_nSdoVersion == 0 and me.GetJbCoin() < tbWareInfo[5] then
		Dialog:Say(string.format("%s không đủ, mua 1 %s cần <color=yellow>%d %s<color>, lần mua này tiết kiệm được <color=yellow>%d %s<color>", IVER_g_szCoinName, tbWareInfo[1], tbWareInfo[5], IVER_g_szCoinName, tbWareInfo[6] -tbWareInfo[5], IVER_g_szCoinName), {{"Ta hiểu rồi"}});
		return 0
	end
	if me.CountFreeBagCell() <= 0 then
		Dialog:Say("Cần 1 ô túi trống.");
		return;
	end
	if me.IsItemInBags(pItem) == 0 then
		return;
	end
	if nTimes <= 1 then
		local nRet = pItem.Delete(me);
		if nRet ~= 1 then
			return;
		end
	else
		pItem.SetGenInfo(1,  pItem.GetGenInfo(1) + 1);
		pItem.Sync();
	end
	me.ApplyAutoBuyAndUse(nWareId, 1, 1);	
	return;
end

function tbNewItem:OpenWindow()	
	Player:OpenFuliTequan(1);
end

function tbNewItem:AddItem(dwId)
	local pItem = KItem.GetObjById(dwId);
	if not pItem then		
		return;
	end	
	local tbWareInfo = self.tbWareInfo[pItem.GetExtParam(1)];
	if not tbWareInfo then
		return;
	end
	pItem.Delete(me);
	local tbItem = Lib:SplitStr(tbWareInfo[3], "-");
	local pItemEx = me.AddItem(tonumber(tbItem[1]), tonumber(tbItem[2]), tonumber(tbItem[3]), tonumber(tbItem[4]));
	if pItemEx then
		pItemEx.Bind(1);
		me.SetItemTimeout(pItemEx, 30*24*60, 0);
	end
	return;
end

function tbNewItem:GetWareInfo()
	return self.tbWareInfo;
end

function tbNewItem:CalDiscount(tbWareList)
	--对优惠券的可用性进行判断，似乎将这个判断放在将优惠券放入格子的事件回调中更恰当一些，这里先将这段代码注释掉
	--local nRes, szMsg = self:Check(it.dwId);
	--if nRes == 0 then
	--	return szMsg;
	--end
	if not tbWareList then
		return {};
	end
	
	assert(it);
	assert(me);
	
	local tbRet = {};
	local pItem = KItem.GetObjById(it.dwId);
	local nWareId = pItem.GetExtParam(1);
	local nTimes = pItem.GetExtParam(3) - pItem.GetGenInfo(1);
	
	for nIndex, tbData in pairs(tbWareList) do
		local tbInfo = me.IbShop_GetWareInf(tbData.nWareId);
		
		if tbInfo.nCurrencyType == 0 then	--只有金币区才能使用优惠券(程序中0表示金币，1表示银两，2表示绑金)
			local szWareIndex = string.format("%s-%s-%s-%s", tbInfo.nGenre, tbInfo.nDetailType, 
				tbInfo.nParticular, tbInfo.nLevel);
				
			local nActualDiscountTimes, nDiscountRate = 0, 0;
			if szWareIndex == self.tbWareInfo[nWareId][3] then		
				--打折率
				nDiscountRate = self.tbWareInfo[nWareId][2];

				--实际打折商品的数量
				nActualDiscountTimes = nTimes > tbData.nCount and tbData.nCount or nTimes; 
				nTimes = nTimes - nActualDiscountTimes;
				local bBind = self.tbWareInfo[nWareId][4]; 	--是否获取绑定
				table.insert(tbRet, {tbData.nWareId, nActualDiscountTimes, nDiscountRate, bBind});

			end
		end
	end	
	
	return tbRet;
end

function tbNewItem:CanCouponUse(dwId)
	assert(dwId);
	local pItem = KItem.GetObjById(dwId);
	if not pItem then
		return 0, "你的优惠券已过期。";
	end
	
	local nWareId = pItem.GetExtParam(1);
	local tbWareInfo = self.tbWareInfo[nWareId];
	
	if IVER_g_nSdoVersion == 0 and me.GetJbCoin() < tbWareInfo[5] then
		return 0, string.format("%s của ngươi không đủ, mua 1 %s cần %d %s", IVER_g_szCoinName, tbWareInfo[1], tbWareInfo[5], IVER_g_szCoinName);
	end
	
	if me.IsAccountLock() ~= 0 then
		return 0, "Ngươi đang ở trạng thái khóa";
	end
	if Account:Account2CheckIsUse(me, 4) == 0 then
		Dialog:Say("Bạn đang đăng nhập trò chơi bằng mật mã phụ, không thể thực hiện thao tác này!");
		return 0;
	end	
	return 1;
end

function tbNewItem:DecreaseCouponTimes(tbCouponWare)
	if not tbCouponWare then
		return 0;
	end

	assert(it)
	local pItem = KItem.GetObjById(it.dwId);
	if not pItem then
		return 0;
	end

	local nWareId = pItem.GetExtParam(1);
	local nTimes = pItem.GetGenInfo(1);		--已经使用次数
	local nMaxTimes = pItem.GetExtParam(3);	--最多可使用次数
	local nToDelTimes = 0;					--需要扣除的次数
	
	if nTimes >= nMaxTimes then
		pItem.Delete(me);
		return 0;
	end
		
	for nIndex, tbData in pairs(tbCouponWare) do
		local tbInfo = me.IbShop_GetWareInf(tbData[1]);
				
		local szWareIndex = string.format("%s-%s-%s-%s", tbInfo.nGenre, tbInfo.nDetailType, 
			tbInfo.nParticular, tbInfo.nLevel);
			
		if szWareIndex == self.tbWareInfo[nWareId][3] then
			nToDelTimes = nToDelTimes + tbData[2];
		end
	end
	
	if nToDelTimes > nMaxTimes - nTimes then	--要扣除的次数大于剩余次数
		Dbg:WriteLog("coupon", "Số ưu đãi lớn hơn số vé ưu đãi còn lại!");
		return 0;
	end
	
	nTimes = nTimes + nToDelTimes; 
	
	if nTimes >= nMaxTimes then
		pItem.Delete(me);
	else		
		pItem.SetGenInfo(1, nTimes);
		pItem.Sync();
	end
	
	return 1;
end
