Require("\\script\\shop\\scriptbuy.lua");
if MODULE_GC_SERVER then
	return;
end

local tbClass = Shop.tbScriptBuy:GetClass("localmedicine");

function tbClass:OnBuy(tbGoods, nCount, nCurrencyType)
	if not tbGoods or nCount <= 0 then --or nCurrencyType ~= 11 then
		print("Cửa hàng bị lỗi hoặc loại hình không đúng, hãy kiểm tra lại");
		return 0;	
	end

	local tbBaseProp = KItem.GetItemBaseProp(tbGoods.nGenre, tbGoods.nDetail,tbGoods.nParticular,tbGoods.nLevel);
	if not tbBaseProp or tbBaseProp.szClass ~= "localmedicine" then
		print("Thiết lập dược phẩm bị lỗi");
		return 0;
	end
	
	local nSinglePrice = tbBaseProp.nPrice;
	if nSinglePrice <= 0 then
		return 0;
	end
	
	local nNeed = nCount * nSinglePrice;
	local nNeedBind = 1;
	if nCurrencyType == Shop.SHOP_CURRENCY_BINDMONEY then
		if me.GetBindMoney() < nNeed then
			me.Msg("Bạc khóa không đủ!");
			return 0;
		end		
	elseif nCurrencyType == Shop.SHOP_CURRENCY_MONEY then
		if me.nCashMoney < nNeed then
			me.Msg("Bạc trong túi không đủ!");
			return 0;
		end		
		nNeedBind = 0;
	end
	
	if Item:CheckTravelItem(tbGoods.nGenre, tbGoods.nDetail,tbGoods.nParticular,tbGoods.nLevel) == 1 then
		print("Lỗi! Thiết lập thành vật phẩm Liên Server." .. tbGoods.szName);
		return 0;
	end
	
	if me.CountFreeBagCell() < 1 then
		me.Msg("Túi đã đầy.");
		return 0;	
	end
	
	local nMaxCount  = me.GetBagCellCount();
	local nFreeCount = me.CalFreeLocalMedicineCountInBags();
	
	if nFreeCount <= 0 then
		me.Msg("Chỉ được mang " .. nMaxCount .. " dược phẩm, không thể mua tiếp.");
		return 0;
	end
	
	if nFreeCount < nCount then
		me.Msg("Số lượng mua vượt quá giới hạn, được mang tối đa " .. nFreeCount .. " dược phẩm.");
		return 0;
	end
	
	local tbFind = me.FindItemInRepository(tbGoods.nGenre, tbGoods.nDetail,tbGoods.nParticular,tbGoods.nLevel);
	if #tbFind > 0 then
		me.Msg("Đã có dược phẩm này trong Rương Chứa Đồ, hãy lấy ra trước.");
		return 0;
	end
	
	local tbItemInfo = {};
	tbItemInfo.bForceBind = nNeedBind;	
	
	local nCostSuccess = 0;
	if nCurrencyType == Shop.SHOP_CURRENCY_BINDMONEY then
		if me.vnCostBindMoney(nCount * nSinglePrice, 100) == 1 then
			nCostSuccess = 1;
		else 
			print("Trừ Bạc khóa thất bại" .. me.szName);
		end
	else
		if me.vnCostMoney(nCount * nSinglePrice, 100) == 1 then
			nCostSuccess = 1;
		else 
			print("Trừ Bạc thất bại" .. me.szName);
		end
	end
	
	if nCostSuccess == 1 then
		me.AddStackItem(tbGoods.nGenre, tbGoods.nDetail,tbGoods.nParticular,tbGoods.nLevel, tbItemInfo, nCount);
		me.Msg(string.format("Bổ sung thành công %d %s, còn được mang %d dược phẩm.", nCount, tbGoods.szName, nFreeCount - nCount));
	end
	
	return 1;
end

function tbClass:OnLocalBuy(tbGoods, nCount, nCurrencyType)
	return self:OnBuy(tbGoods, nCount, nCurrencyType);
end
