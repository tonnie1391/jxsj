-- 文件名　：isbhop_gc.lua
-- 创建者　：zouying
-- 创建时间：2009-9-8 10:02:31
-- 描  述  ：

if (not MODULE_GC_SERVER) then
	return 0;
end

IbShop.nSyncFavoriteGoodsTime = 60 * 60;	--一个小时同步一次本服热销商品列表



function IbShop:StartEvent()
	self.tbGblBuf = {};
	local tbBuf = GetGblIntBuf(GBLINTBUF_IBSHOP, 0);
	if tbBuf and type(tbBuf)=="table"  then
		self.tbGblBuf = tbBuf;
		--Lib:ShowTB(tbBuf)
	end
	self:OpenTimeFrameLimit(1);
	self:LoadFavoriteList();
	self.nSyncTimer = Timer:Register(self.nSyncFavoriteGoodsTime * Env.GAME_FPS, self.SyncFavoriteGoodsToGS, self);
end

function IbShop:OpenTimeFrameLimit(nFlag)
	local nOpen = KGblTask.SCGetDbTaskInt(DBTASK_IBSHOPNOLIMIT_OPEN);	
	if nFlag and nOpen == 0 then
		return;
	end
	for nId, tbData in pairs(self.tbPreloadWareInfo) do
		if (self.tbCoinInfo[nId] or self.tbBindCoinInfo[nId]) and (tbData.nTimeFrameStartSale ~= 0 or tbData.nTimeFrameEndSale ~= 0) then
			local tbWareInfo = {};
			tbWareInfo.WareId = nId;
			if nOpen == 1 then
				tbWareInfo.nTimeFrameStartSale = 0;
				tbWareInfo.nTimeFrameEndSale = 0;				
			else
				tbWareInfo.nTimeFrameStartSale = tbData.nTimeFrameStartSale;
				tbWareInfo.nTimeFrameEndSale = tbData.nTimeFrameEndSale;				
			end
			ModifyIBWare(tbWareInfo);			
		end
	end
	return;
end


--GC数据同步给GS
function IbShop:OnRecConnectEvent(nConnectId)
	if self.tbGblBuf then
		for nWaraId, _ in pairs(self.tbGblBuf) do
			GSExcute(nConnectId, {"IbShop:OnRecConnectMsg", nWaraId, 1});
		end
	end
end

function IbShop:SetWareStatus(strParams, bDelOrAdd)
	local strIndex = self:GetParams(strParams)
	if not strIndex then
		return 0;
	end
	if bDelOrAdd == 1 then
		self.tbGblBuf[strIndex] = 1 
	else
		self.tbGblBuf[strIndex] = nil
	end
	-- bDelOrAdd:1是下架，0：是恢复上架
	GlobalExcute({"IbShop:OnRecConnectMsg", strIndex, bDelOrAdd});
	return 1
end

function IbShop:GetWareStatusList()
	local szMsg = ""
	local tbParams = {}
	for strIdx, _ in pairs(self.tbGblBuf) do
		tbParams = {}
		for w in string.gmatch(strIdx, "%d+") do
			table.insert(tbParams, tonumber(w))
		end
		local nG = Lib:LoadBits(tbParams[1], 24, 31)
		local nD = Lib:LoadBits(tbParams[1], 12, 23)
		local nP = Lib:LoadBits(tbParams[1], 0,  11)
		local str = tostring(nG) .. ',' .. tostring(nD) .. ',' .. tostring(nP) ..',' .. tostring(tbParams[2]) .. ',' .. tostring(tbParams[3])
		szMsg = szMsg .. '\n' .. str .. '\t down,'
	end
	return szMsg
end


function IbShop:ServerendEvent()
	SetGblIntBuf(GBLINTBUF_IBSHOP, 0, 1, self.tbGblBuf);
	--服务器关闭时候进行一次列表同步
	if self.tbFavoriteBindCoinGoods and self.tbFavoriteCoinGoods and
	   #self.tbFavoriteBindCoinGoods ~= 0 and #self.tbFavoriteCoinGoods ~= 0 then
	   	self:SortFavoriteGoodsList();
	   	SetGblIntBuf(GBLINTBUF_FAVORITE_IBSHOP_COIN, 0, 0, self.tbFavoriteCoinGoods);
		SetGblIntBuf(GBLINTBUF_FAVORITE_IBSHOP_BINDCOIN, 0, 0, self.tbFavoriteBindCoinGoods);
	end
end

-- 合服时候用
function IbShop:MergeCoZoneAndMainZoneBuf(tbSubBuf)
	print("[IbShop MergeCoZoneAndMainZoneBuf] Start!!");
	self:StartEvent();
	if (not self.tbGblBuf) then
		self.tbGblBuf = {};
	end
	
	if (tbSubBuf) then
		for szIndex, value in pairs(tbSubBuf) do
			self.tbGblBuf[szIndex] = value;
		end
	end
	self:ServerendEvent();
end

function IbShop:GetParams(params)
	local tbParams = {}
	for w in string.gmatch(params, "%d+") do
		table.insert(tbParams, tonumber(w))
	
	end
	
	local nG = Lib:SetBits(0, tbParams[1], 24, 31)
	local nD = Lib:SetBits(nG, tbParams[2], 12, 23)
	local nWareId = Lib:SetBits(nD, tbParams[3], 0,  11)
	
	local strIndex = tostring(nWareId) .. ',' .. tbParams[4] .. ',' .. tbParams[5]
	--print(strIndex)
	return strIndex
end


-- 手工修改ib道具，
-- tbWareInfo 商品的具体信息（其中包含的信息参看"\\setting\\ibshop\\warelist.txt"文件）
function IbShop:PreEditIBWare(tbWareInfo)
	if (not tbWareInfo) then
		return;
	end
	
	tbWareInfo.WareId = tbWareInfo.WareId or 0;	-- 商品id
	tbWareInfo.WareName = tbWareInfo.WareName or ""; -- 商品名称
	tbWareInfo.WareType = tbWareInfo.WareType or 0; -- 商品类别（玄晶宝石、坐骑装备等）
	tbWareInfo.nGenre = tbWareInfo.nGenre or 0;	-- GDPL
	tbWareInfo.nDetailType = tbWareInfo.nDetailType or 0;
	tbWareInfo.nParticular = tbWareInfo.nParticular or 0;
	tbWareInfo.nLevel = tbWareInfo.nLevel or 0;
	tbWareInfo.nSeries = tbWareInfo.nSeries or 0; -- 五行
	tbWareInfo.nCurrencyType = tbWareInfo.nCurrencyType or 0; -- 货币类型
	tbWareInfo.nUseType = tbWareInfo.nUseType or 2;	-- 使用类型
	tbWareInfo.nOrgPrice = tbWareInfo.nOrgPrice or 0; -- 原始价格
	tbWareInfo.nWareUseStyle = tbWareInfo.nWareUseStyle or 0; -- 物品使用方式
	tbWareInfo.nDiscount = tbWareInfo.nDiscount or 100; -- 折扣（默认是100%，也就是不打折）
	tbWareInfo.nRecommend = tbWareInfo.nRecommend or 0; -- 是否推荐商品
	tbWareInfo.timeSaleStart = tbWareInfo.timeSaleStart or ""; -- 开始销售时间
	tbWareInfo.timeSaleClose = tbWareInfo.timeSaleClose or ""; -- 结束销售时间
	tbWareInfo.DiscountStart = tbWareInfo.DiscountStart or ""; -- 开始优惠时间
	tbWareInfo.DiscountClose = tbWareInfo.DiscountClose or ""; -- 结束优惠时间
	tbWareInfo.dwTimeout = tbWareInfo.dwTimeout or 0; -- 超时时间（记录的是分钟数）
	tbWareInfo.nTimeFrameStartSale = tbWareInfo.nTimeFrameStartSale or 0; -- 根据时间轴，物品开始销售时间，天
	tbWareInfo.nTimeFrameEndSale = tbWareInfo.nTimeFrameEndSale or 0; -- 根据时间轴，物品结束销售时间，天
	tbWareInfo.Ware_Describe = tbWareInfo.Ware_Describe or ""; -- 商品描述
	tbWareInfo.Consumed = tbWareInfo.Consumed or 0; -- 标记商品的消耗计算方式
	
	return tbWareInfo;
end

-- 在gc关闭的时候，把存在buff当中的在线指令存盘
function IbShop:SaveBuf()
	if (self.tbIbshopCmdBuff) then
		SetGblIntBuf(GBLINTBUF_IBSHOP_CMDBUF, 0, 1, self.tbIbshopCmdBuff);
	end
end

-- gc启动时，从buff当中读取ibshop的在线指令并执行
function IbShop:ExecuteBuf()
	self.tbIbshopCmdBuff = GetGblIntBuf(GBLINTBUF_IBSHOP_CMDBUF, 0);
	if (self.tbIbshopCmdBuff) then
		self:ExecuteIbshopCmdBuf(self.tbIbshopCmdBuff);
	end
end

-- 在加载脚本的时候，把warelist当中的商品信息读取到内存当中
function IbShop:PreLoadWareInfo()
	self.tbPreloadWareInfo = {};
	self.tbCoinInfo = {};
	self.tbBindCoinInfo = {};
	local tbWare = Lib:LoadTabFile("\\setting\\ibshop\\warelist.txt");	
	for _, tbData in pairs(tbWare) do
		local nId = tonumber(tbData["WareId"]);
		self.tbPreloadWareInfo[nId] = tbData;		
	end
	local tbCoinInfo = KLib.LoadTabFile("\\setting\\ibshop\\coinshop.txt");
	for _, tbData in pairs(tbCoinInfo) do
		local nId = tonumber(tbData[1]) or 0;
		self.tbCoinInfo[nId] = 1;
	end
	local tbBindCoinInfo = KLib.LoadTabFile("\\setting\\ibshop\\bindcoinshop.txt");
	for _, tbData in pairs(tbBindCoinInfo) do
		local nId = tonumber(tbData[1]) or 0;
		self.tbBindCoinInfo[nId] = 1;
	end
end

--加载本服热销商品，若为空，则先进行一次读取,by Egg
function IbShop:LoadFavoriteList()
	self.tbFavoriteCoinGoods = self.tbFavoriteCoinGoods or GetGblIntBuf(GBLINTBUF_FAVORITE_IBSHOP_COIN, 0) or {};
	self.tbFavoriteBindCoinGoods = self.tbFavoriteBindCoinGoods or GetGblIntBuf(GBLINTBUF_FAVORITE_IBSHOP_BINDCOIN, 0) or {};
	if #self.tbFavoriteCoinGoods == 0 then
		for nIndex, _ in pairs(self.tbCoinInfo) do
			local tbInfo = {};
			tbInfo.nId = nIndex;
			tbInfo.nTimes = 0;
			table.insert(self.tbFavoriteCoinGoods,tbInfo);
		end
	end
	if #self.tbFavoriteBindCoinGoods == 0 then
		for nIndex, _ in pairs(self.tbBindCoinInfo) do
			local tbInfo = {};
			tbInfo.nId = nIndex;
			tbInfo.nTimes = 0;
			table.insert(self.tbFavoriteBindCoinGoods,tbInfo);
		end
	end
end


--增加本服热销商品次数,by Egg
function IbShop:AddFavoriteGoodsTimes(nCurrencyType,nWareCount,nWareId)
	if not nCurrencyType or (nCurrencyType ~= 0 and nCurrencyType ~= 2 ) then
		return;
	end
	if not nWareId or nWareId == 0 then
		return;
	end
	if not nWareCount or nWareCount == 0 then
		return;
	end
	local nIndex = self:FindWareById(nCurrencyType,nWareId);
	if nIndex ~= 0 then
		if nCurrencyType == 0 then
			if self.tbFavoriteCoinGoods[nIndex] and self.tbFavoriteCoinGoods[nIndex].nTimes then
				self.tbFavoriteCoinGoods[nIndex].nTimes = self.tbFavoriteCoinGoods[nIndex].nTimes + nWareCount;
			end
		elseif nCurrencyType == 2 then
			if self.tbFavoriteBindCoinGoods[nIndex] and self.tbFavoriteBindCoinGoods[nIndex].nTimes then
				self.tbFavoriteBindCoinGoods[nIndex].nTimes = self.tbFavoriteBindCoinGoods[nIndex].nTimes + nWareCount;
			end
		end 
	end		
end

--查找对应id的商品table index,by Egg
function IbShop:FindWareById(nCurrencyType,nWareId)
	if not nCurrencyType then
		return 0;
	end
	if not nWareId or nWareId == 0 then
		return 0;
	end
	if nCurrencyType == 0 then
		for nIndex , tbInfo in pairs(self.tbFavoriteCoinGoods) do
			if tbInfo then
				if nWareId == tbInfo.nId then
					return nIndex;
				end
			end	
		end
	elseif nCurrencyType == 2 then
		for nIndex , tbInfo in pairs(self.tbFavoriteBindCoinGoods) do
			if tbInfo then
				if nWareId == tbInfo.nId then
					return nIndex;
				end
			end	
		end
	end
	return 0;
end


--同步本服热销商品,by Egg
function IbShop:SyncFavoriteGoodsToGS()
	print("Begin to sync favorite goods list to GS.....");
	if self.tbFavoriteBindCoinGoods and self.tbFavoriteCoinGoods and
	   #self.tbFavoriteBindCoinGoods ~= 0 and #self.tbFavoriteCoinGoods ~= 0 then
	   	self:SortFavoriteGoodsList();
	   	local tbCoin = self:GetForwardShowNumList(self.tbFavoriteCoinGoods, self.tbCoinInfo);
	   	local tbBindCoin = self:GetForwardShowNumList(self.tbFavoriteBindCoinGoods, self.tbBindCoinInfo);
	   	SetGblIntBuf(GBLINTBUF_FAVORITE_IBSHOP_COIN, 0, 0, self.tbFavoriteCoinGoods);
		SetGblIntBuf(GBLINTBUF_FAVORITE_IBSHOP_BINDCOIN, 0, 0, self.tbFavoriteBindCoinGoods);
		--如果不是gs请求，则广播，否则点对点同步
	   	GSExcute(GCEvent.nGCExecuteFromId or -1,{"IbShop:OnSyncFavoriteFavorite",tbCoin,0});
	   	GSExcute(GCEvent.nGCExecuteFromId or -1,{"IbShop:OnSyncFavoriteFavorite",tbBindCoin,2});
	end
end

--每次同步之前进行一次排序,by Egg
function IbShop:SortFavoriteGoodsList()
	if self.tbFavoriteBindCoinGoods and self.tbFavoriteCoinGoods and
		#self.tbFavoriteBindCoinGoods ~= 0 and #self.tbFavoriteCoinGoods ~= 0 then
		local sortFunc = function(tb1,tb2) return tb1.nTimes > tb2.nTimes end
		table.sort(self.tbFavoriteBindCoinGoods,sortFunc);
		table.sort(self.tbFavoriteCoinGoods,sortFunc);
	end
end

--取列表的前15项,减少同步大小,by Egg
function IbShop:GetForwardShowNumList(tbList, tbSell)
	if not tbList or #tbList == 0 then
		return {};
	end
	local tbForward = {};
	local nCount = 0;
	for i = 1, #tbList do
		if tbList[i].nTimes and tbList[i].nTimes > 0 then
			local tbInfo = GetWareExternInfo(tbList[i].nId);
			if tbInfo and tbSell[tbList[i].nId] then
				local nOnSale = IbShop:CheckIsOnSale(tbList[i].nId,tbInfo.nLevel,tbInfo.nCurrencyType,tbInfo.nTimeStartDay,tbInfo.nTimeEndDay,tbInfo.nTimeSaleStart,tbInfo.nTimeSaleClose);
				if nOnSale == 1 then
					table.insert(tbForward,tbList[i].nId);
					nCount = nCount + 1;
				end
			end
		end
		--只取15个
		if nCount >= self.MAX_SHOW_NUMBER then 
			break;
		end
	end
	return tbForward;
end

--清空本服热销列表
function IbShop:ClearFavoriteListGC()
	self.tbFavoriteCoinGoods = {};
	self.tbFavoriteBindCoinGoods = {};
 	SetGblIntBuf(GBLINTBUF_FAVORITE_IBSHOP_COIN, 0, 0, {});
	SetGblIntBuf(GBLINTBUF_FAVORITE_IBSHOP_BINDCOIN, 0, 0, {});
	for nIndex, _ in pairs(self.tbCoinInfo) do
		local tbInfo = {};
		tbInfo.nId = nIndex;
		tbInfo.nTimes = 0;
		table.insert(self.tbFavoriteCoinGoods,tbInfo);
	end
	for nIndex, _ in pairs(self.tbBindCoinInfo) do
		local tbInfo = {};
		tbInfo.nId = nIndex;
		tbInfo.nTimes = 0;
		table.insert(self.tbFavoriteBindCoinGoods,tbInfo);
	end
	self:SyncFavoriteGoodsToGS();
end



IbShop:PreLoadWareInfo();

GCEvent:RegisterGCServerShutDownFunc(IbShop.SaveBuf, IbShop);
GCEvent:RegisterGCServerStartFunc(IbShop.StartEvent, IbShop);
GCEvent:RegisterGCServerShutDownFunc(IbShop.ServerendEvent, IbShop);
GCEvent:RegisterGCServerStartFunc(IbShop.ExecuteBuf, IbShop);

