if MODULE_GC_SERVER then
	return 0;
end

Require("\\script\\shop\\shop.lua");

if not Shop.tbScriptBuy then
	Shop.tbScriptBuy = {};
end

local tbBuy = Shop.tbScriptBuy;

if not tbBuy.tbClass then
	
	tbBuy.tbClass = {};
	
end

function tbBuy:GetClass(szClassName, bNotCreate)
	local tbClass = self.tbClass[szClassName];
	if (not tbClass) and (bNotCreate ~= 1) then
		tbClass	= {};
		self.tbClass[szClassName] = tbClass;
	end
	return	tbClass;
end

function tbBuy:OnBuy(nGoodsId, nCount, nCurrencyType)
	if not MODULE_GAMESERVER then
		return 0;
	end
	local tbGoods = self:GetGoods(nGoodsId);
	local tbClass = self:GetGoodsClass(nGoodsId);
	if not tbClass then
		return 0;
	end

	-- if me.IsTraveller() == 1 then
		-- if tbClass.OnTravalBuy then
			-- return tbClass:OnTravalBuy(tbGoods, nCount, nCurrencyType);
		-- end
	-- else
		if tbClass.OnBuy then
			return tbClass:OnBuy(tbGoods, nCount, nCurrencyType);
		end
	-- end
	return 0;
end

function tbBuy:GetAllGoods()
	return self.tbGoods or {};
end

function tbBuy:GetGoods(nGoodsId)
	if nGoodsId then
		self.tbGoods = self.tbGoods or {};
		return self.tbGoods[nGoodsId];
	end
end

function tbBuy:GetGoodsClass(nGoodsId)
	assert(nGoodsId);
	self.tbGoods = self.tbGoods or {};
	if self.tbGoods[nGoodsId] then
		local szClassName = self.tbGoods[nGoodsId].szClassName;
		return self.tbClass[szClassName];
	end
end

function tbBuy:LoadScriptBuyGoods()
	self.tbGoods = {};
	local tbTempGoods = Lib:LoadTabFile("\\setting\\shop\\goods.txt");
	if not tbTempGoods then
		return
	end
	for _, tbGood in pairs(tbTempGoods) do
		local szName  = tbGood.Name;
		local nId 	  = tonumber(tbGood.Id);
		local nGenre  = tonumber(tbGood.Genre) or 0;
		local nDetail = tonumber(tbGood.DetailType) or 0;
		local nParticular = tonumber(tbGood.ParticularType) or 0;
		local nLevel  = tonumber(tbGood.Level) or 0;
		local nSeries = tonumber(tbGood.Series) or 0;
		local nGoodsPrice = tonumber(tbGood.goodsprice) or 0;
		local nGoodsIndex = tonumber(tbGood.goodsindex) or 0;
		local nValueCoinIndex = tonumber(tbGood.valuecoinindex) or 0;
		local nValueCoinPrice = tonumber(tbGood.valuecoinprice) or 0;
		local szClassName = tbGood.BuyClass;
		
		if szClassName and szClassName ~= "" and not self.tbGoods[nId] then
				
				self.tbGoods[nId] = 
				{
					szName 		= szName,
					nId			= nId;
					nGenre		= nGenre,
					nDetail		= nDetail,
					nParticular = nParticular,
					nLevel		= nLevel,
					nSeries		= nSeries,
					szClassName = szClassName,
					nGoodsPrice = nGoodsPrice,
					nGoodsIndex = nGoodsIndex,
					nValueCoinIndex = nValueCoinIndex,
					nValueCoinPrice = nValueCoinPrice,
				};
		end
	end
end

tbBuy:LoadScriptBuyGoods();

function Shop:OnBuy(nGoodsId, nCount, nCurrencyType)
	return tbBuy:OnBuy(nGoodsId, nCount, nCurrencyType) or 0;
end

function Shop:CheckScriptBuyItem(nGoodsId)
	local tbGoods  = tbBuy:GetGoods(nGoodsId);
	if tbGoods then
		return 1;
	end
	return 0;
end

function Shop:GetCanBuyCount(nGoodsId)
	local  tbGoods  = tbBuy:GetGoods(nGoodsId);
	local  tbClass  = tbBuy:GetGoodsClass(nGoodsId);
	if tbGoods and tbClass and tbClass["OnGetCanBuyCount"] then
		return tbClass:OnGetCanBuyCount(tbGoods);
	end
end
