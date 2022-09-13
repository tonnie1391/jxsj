-- 文件名　：voucher.lua
-- 创建者　：furuilei
-- 创建时间：2010-03-22 09:46:26
-- 功能描述：奇珍阁全部商品打折优惠券（注意，是金币区的全部商品）

local tbVoucher = Item:GetClass("voucher");

function tbVoucher:GetTip()
	local szTip = "";
	local pVoucher = KItem.GetObjById(it.dwId);
	if (not pVoucher) then
		return szTip;
	end
	local nMaxPoint = pVoucher.GetExtParam(1);
	szTip = szTip.."<color=0x8080ff>还可使用点数：".. (nMaxPoint - it.GetGenInfo(1)) .."<color>";
	return	szTip;
end

function tbVoucher:GetWareInfo()
	return {};
end

function tbVoucher:CalDiscount(tbWareList)
	if not tbWareList then
		return {};
	end
	
	assert(it);
	assert(me);
	
	local tbRet = {};
	local pVoucher = KItem.GetObjById(it.dwId);
	
	local nDiscountRate = pVoucher.GetExtParam(2);	-- 优惠券的折扣，在extparam2里面配置
	local nMaxPoint = pVoucher.GetExtParam(1);		-- 一共多少打折额度，在extparam1里面配置
	local nUsedPoint = pVoucher.GetGenInfo(1);		-- 已经使用了多少打折额度
	local nLeftPoint = nMaxPoint - nUsedPoint;		-- 还剩余多少打折额度
	local bBind = pVoucher.GetExtParam(3);			-- 通过这个优惠券购买的商品是否绑定
	
	-- 打折的折扣不正确
	if (nDiscountRate > 100 or nDiscountRate < 0) then
		return {};
	end
	
	-- 没有剩余使用点数了
	if (nMaxPoint <= 0 or nLeftPoint <= 0) then
		return {};
	end
	
	for _, tbData in pairs(tbWareList) do
		local tbInfo = me.IbShop_GetWareInf(tbData.nWareId);
		
		-- 只有金币区才能使用优惠券(程序中0表示金币，1表示银两，2表示绑金)
		if (tbInfo.nCurrencyType == 0) then
			local nActualDiscountTimes = 0;
			local nEachItemUsePoint = math.ceil(tbInfo.nOrgPrice * (100 - nDiscountRate) / 100);	-- 每个商品使用的优惠点数
			if (nLeftPoint >= nEachItemUsePoint and nEachItemUsePoint > 0) then
				nActualDiscountTimes = math.floor(nLeftPoint / nEachItemUsePoint);					-- 可以对当前商品当中的几个进行打折
				if (nActualDiscountTimes >= tbData.nCount) then
					nActualDiscountTimes = tbData.nCount;
				end
			end
			nLeftPoint = nLeftPoint - (nActualDiscountTimes * nEachItemUsePoint);					-- 还可以剩余多少打折点数
			
			if (nActualDiscountTimes >= 0 and nLeftPoint >= 0) then
				table.insert(tbRet, {tbData.nWareId, nActualDiscountTimes, nDiscountRate, bBind});
			end
		end
	end	
	return tbRet;
end

function tbVoucher:CanCouponUse(dwId)
	assert(dwId);
	local pItem = KItem.GetObjById(dwId);
	if not pItem then
		return 0, "你的优惠券已过期。";
	end
	
	if me.IsAccountLock() ~= 0 then
		return 0, "你还处于锁定状态";
	end
	
	return 1;
end

function tbVoucher:DecreaseCouponTimes(tbDiscountWare)
	if (not tbDiscountWare) then
		return 0;
	end

	assert(it)
	local pVoucher = KItem.GetObjById(it.dwId);
	if (not pVoucher) then
		return 0;
	end

	local nDiscountRate = pVoucher.GetExtParam(2);	-- 优惠券的折扣，在extparam2里面配置
	local nMaxPoint = pVoucher.GetExtParam(1);		-- 一共多少打折额度，在extparam1里面配置
	local nUsedPoint = pVoucher.GetGenInfo(1);		-- 已经使用了多少打折额度
	local nLeftPoint = nMaxPoint - nUsedPoint;		-- 还剩余多少打折额度
	local bBind = pVoucher.GetExtParam(3);			-- 通过这个优惠券购买的商品是否绑定
	local nDecresePoint = 0;						-- 需要扣除的使用点数
	
	if (nLeftPoint <= 0) then
		pVoucher.Delete(me);
	end
		
	for _, tbData in pairs(tbDiscountWare) do
		local tbInfo = me.IbShop_GetWareInf(tbData[1]);
		local nEachItemUsePoint = math.ceil(tbInfo.nOrgPrice * (100 - nDiscountRate) / 100);
		local nDiscountCount = tbData[2];
		nDecresePoint = nDecresePoint + nEachItemUsePoint * nDiscountCount;
	end
	
	if (nDecresePoint > nLeftPoint) then	--要扣除的点数大于剩余点数
		Dbg:WriteLog("coupon", "Error:优惠券扣除点数大于剩余点数！！！");
		return 0;
	end
	
	nUsedPoint = nUsedPoint + nDecresePoint;
	
	if (nUsedPoint >= nMaxPoint) then
		pVoucher.Delete(me);
	else
		pVoucher.SetGenInfo(1, nUsedPoint);
		pVoucher.Sync();
	end
	
	return 1;
end
