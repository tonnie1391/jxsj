Require("\\script\\shop\\scriptbuy.lua");
if MODULE_GC_SERVER then
	return;
end

local tbClass = Shop.tbScriptBuy:GetClass("travelmedicine");

tbClass.tbOtherItemList = {
	{17,	18,	1,	5},
	{17,	18,	1,	6},
	{17,	18,	2,	5},
	{17,	18,	2,	6},
	{17,	18,	3,	5},
	{17,	18,	3,	6},
	}

function tbClass:OnBuy(tbGoods, nCount, nCurrencyType)
	if not tbGoods or nCount <= 0 or nCurrencyType ~= 11 then
		print("Cửa hàng bị lỗi hoặc không phải loại Bạc khóa liên server, hãy kiểm tra Script");
		return 0;	
	end
	
	if Item:CheckTravelItem(tbGoods.nGenre, tbGoods.nDetail,tbGoods.nParticular,tbGoods.nLevel) ~= 1 then
		print(" bị lỗi, chưa thiết lập thành vật phẩm liên server." .. tbGoods.szName);
		return 0;
	end
	
	if me.CountFreeBagCell() < 1 then
		me.Msg("Túi không có 1 ô trống.");
		return 0;	
	end
		
	local nMaxCount  = me.CountFreeBagCell();
	local nFreeCount = self:GetFreeCount();
	
	if nFreeCount <= 0 then
		me.Msg("Chỉ được mang " .. nMaxCount .. " thuốc liên server, không thể mua tiếp.");
		return 0;
	end
	
	if nFreeCount < nCount then
		me.Msg("Số lượng cần mua vượt quá giới hạn mang theo, nhiều nhất có thể mang " .. nFreeCount .. " thuốc liên Server.");
		return 0;
	end
	
	local tbFind = me.FindItemInRepository(tbGoods.nGenre, tbGoods.nDetail,tbGoods.nParticular,tbGoods.nLevel);
	if #tbFind > 0 then
		me.Msg("Rương chứa đồ có thuốc này, hãy lấy ra rồi mới mua.");
		return 0;
	end
	
	local tbBaseProp = KItem.GetItemBaseProp(tbGoods.nGenre, tbGoods.nDetail,tbGoods.nParticular,tbGoods.nLevel);
	if not tbBaseProp or tbBaseProp.szClass ~= "travelmedicine" then
		print("Thiết lập thuốc bị lỗi");
		return 0;
	end
	
	local nSinglePrice = tbBaseProp.nPrice;
	if nSinglePrice <= 0 then
		return 0;
	end
	-- if me.GetGlbBindMoney() < nCount * nSinglePrice then
		-- if me.IsTraveller() == 1 then
			-- me.Msg("Bạc khóa không đủ.");
		-- else
			-- me.Msg("Bạc khóa liên server không đủ.");
		-- end
		-- return 0;
	-- end
	
	local nGroupId = tbBaseProp.tbExtParam[1];
	local nTaskId  = tbBaseProp.tbExtParam[2];
	if not nGroupId or not nTaskId or nGroupId == 0 then
		print("Dược phẩm liên server chưa thiết lập biến lượng nhiệm vụ");
		return 0;
	end
	
	local nCurCount =  me.GetTask(nGroupId, nTaskId);
	local tbFind    = me.FindItemInBags(tbGoods.nGenre, tbGoods.nDetail,tbGoods.nParticular,tbGoods.nLevel);
		
	if #tbFind <= 0 then
		-- if me.IsTraveller() == 1 and nCurCount > 0 then
			-- me.Msg("Du lịch liên server đã quên mang thuốc chứa trong rương, hãy về lấy ra rồi mới mua.");
			-- return 0;
		-- end
		
		local pItem = me.AddItem(tbGoods.nGenre, tbGoods.nDetail,tbGoods.nParticular,tbGoods.nLevel);
		if pItem then
			pItem.Bind(1);
		else
			print("Thêm Rương Thuốc bị lỗi.");
			return 0;
		end
	end
	
	if me.CostGlbBindMoney(nCount * nSinglePrice, 100) == 1 then
		me.SetTask(nGroupId, nTaskId, nCurCount + nCount);
		me.Msg(string.format("Thành công bổ sung %d %s, còn được mang %d thuốc liên server.", nCount, tbGoods.szName, nFreeCount - nCount));
		me.CallClientScript({"Ui:ServerCall", "UI_ITEMBOX", "OnUseTravelMedicine", tbGoods.nGenre, tbGoods.nDetail,tbGoods.nParticular,tbGoods.nLevel});
		return 1;
	else 
		print("Trừ Bạc khóa liên server thất bại" .. me.szName);
	end
	
	return 0;
end

function tbClass:OnTravalBuy(tbGoods, nCount, nCurrencyType)
	return self:OnBuy(tbGoods, nCount, nCurrencyType);
end

function tbClass:OnGetCanBuyCount()
	return self:GetFreeCount();
end

function tbClass:GetFreeCount(bNotCaleOther)
	local nMaxCount = me.GetBagCellCount(); -- 背包大小
	local nCurCount = 0; -- 当前使用了几个
	local tbAllGoods = Shop.tbScriptBuy:GetAllGoods(); -- 获取所有出售中的并通过脚本购买的物品
	
	for _, tbGoods in pairs(tbAllGoods) do
		if Item:CheckTravelItem(tbGoods.nGenre, tbGoods.nDetail,tbGoods.nParticular,tbGoods.nLevel) == 1 then
			local tbBaseProp = KItem.GetItemBaseProp(tbGoods.nGenre, tbGoods.nDetail,tbGoods.nParticular,tbGoods.nLevel);
			if tbBaseProp and tbBaseProp.szClass == "travelmedicine" then
				local nGroupId = tbBaseProp.tbExtParam[1];
				local nTaskId  = tbBaseProp.tbExtParam[2];
				if nGroupId and nTaskId then
					local nCount = me.GetTask(nGroupId, nTaskId);
					nCurCount = nCurCount + nCount;
				end
			end
		end
	end
	local nIsGlobal = Player:GetTransferStatus();
	if nIsGlobal ~= 1 and not bNotCaleOther then
		for _, tbItem in ipairs(self.tbOtherItemList) do
			if Item:CheckTravelItem(unpack(tbItem)) == 1 then
				local tbBaseProp = KItem.GetItemBaseProp(unpack(tbItem));
				if tbBaseProp and tbBaseProp.szClass == "travelmedicine" then
					local nGroupId = tbBaseProp.tbExtParam[1];
					local nTaskId  = tbBaseProp.tbExtParam[2];
					if nGroupId and nTaskId then
						local nCount = me.GetTask(nGroupId, nTaskId);
						nCurCount = nCurCount + nCount;
					end
				end
			end
		end
	end
	local nFreeCount = nMaxCount - nCurCount;
	if nFreeCount <= 0 then
		nFreeCount = 0;
	end
	return nFreeCount;
end

function tbClass:AddMedcineBox()
	-- if me.IsTraveller() == 1 then
		-- return;
	-- end
	local tbAllGoods = Shop.tbScriptBuy:GetAllGoods(); -- 获取所有出售中的并通过脚本购买的物品
	for _, tbGoods in pairs(tbAllGoods) do
		local tbBaseProp = KItem.GetItemBaseProp(tbGoods.nGenre, tbGoods.nDetail,tbGoods.nParticular,tbGoods.nLevel);
		if tbBaseProp and tbBaseProp.szClass == "travelmedicine" then
			local nGroupId = tbBaseProp.tbExtParam[1];
			local nTaskId  = tbBaseProp.tbExtParam[2];
			if nGroupId and nTaskId then
				local nCount = me.GetTask(nGroupId, nTaskId);
				local tbFind    = me.FindItemInAllPosition(tbGoods.nGenre, tbGoods.nDetail,tbGoods.nParticular,tbGoods.nLevel);
				
				if nCount > 0 and #tbFind <=0 then
					if me.CountFreeBagCell() > 0 then
						local pItem = me.AddItem(tbGoods.nGenre, tbGoods.nDetail,tbGoods.nParticular,tbGoods.nLevel);
						if pItem then
							pItem.Bind(1);
						end
					end
				elseif nCount <= 0 and #tbFind > 0 then
					for i = 1, #tbFind do
						me.DelItem(tbFind[i].pItem);
					end
				end
			end
		end
	end
end

if not MODULE_GAMESERVER then
	return;
end
 
if GLOBAL_AGENT then
	Transfer:RegisterGlbServerEvent(tbClass.AddMedcineBox, tbClass);
else
	PlayerEvent:RegisterGlobal("OnLoginOnly", tbClass.AddMedcineBox, tbClass);
end
