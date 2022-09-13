
-------------------------------------------------------------------
--File: shop.lua
--Author: fenghewen
--Date: 2009-7-30 16:23
--Describe: 商店系统扩展脚本指令
-------------------------------------------------------------------

if not Shop then --调试需要
	Shop = {}
	print(GetLocalDate("%Y\\%m\\%d  %H:%M:%S").." build ok ..")
end

Shop.tbDemoItems = {}; -- 打开的商店的样例道具与对应商品Id表
Shop.tbGoodsIdSet = {};
Shop.tbItemCoinUnit = {};	-- 金币替代物品的单位
Shop.tbValueCoinUnit = {};	-- 数值货币的单位
local SZ_FILE_GAMESETTING = "\\setting\\gamesetting.ini";

function Shop:CheckCanUse(nShop)
end

-- 根据道具的nIndex获得对应的商品Id
function Shop:GetGoods(nShopId, nItemIndex)
	if not Shop.tbGoodsIdSet[nShopId] then
		return nil;
	end
	return Shop.tbGoodsIdSet[nShopId][nItemIndex];
end

-- 根据商店的Id和对应的商品Id获得样例道具对象
function Shop:GetDemoItem(nShopId, nGoodsId)
	if not Shop.tbDemoItems[nShopId] then
		return nil;
	end
	return Shop.tbDemoItems[nShopId][nGoodsId];
end

-- 创建商店样例道具对象，该对象由TempItem和其对应的nGoodsId组成
function Shop:CreateDemoItem(nShopId, nGoodsId)
	local tbGoods = me.GetShopBuyItemInfo(nGoodsId);
	if not tbGoods or not nShopId then
		return nil;
	end
	
	if Shop.tbDemoItems[nShopId] == nil then
		Shop.tbDemoItems[nShopId] = {};
	end
	if Shop.tbGoodsIdSet[nShopId] == nil then
		Shop.tbGoodsIdSet[nShopId] = {};
	end
	
	local pItem = KItem.CreateTempItem(tbGoods.nGenre, 
									   tbGoods.nDetail, 
									   tbGoods.nParticular, 
									   tbGoods.nLevel, 
									   tbGoods.nSeries);								   
	if not pItem then
		return nil;
	end
	Shop.tbGoodsIdSet[nShopId][pItem.nIndex] = nGoodsId;
	Shop.tbDemoItems[nShopId][nGoodsId] = pItem;
	pItem.SetTimeOut(1, tbGoods.nTimeout * 60);
	return pItem;
end

-- 清除商店样例道具对象
function Shop:ClearDemoItem(nShopId)
	if Shop.tbDemoItems[nShopId] ~= nil then
		for i, pItem in pairs(Shop.tbDemoItems[nShopId]) do
			if pItem then
				pItem.Remove();
			end
		end	
		Shop.tbDemoItems[nShopId] = nil;
		Shop.tbGoodsIdSet[nShopId] = nil;
		return 1;
	end
	return 0;
end

-- 获取对应商品所需货币的描述和数量
function Shop:GetCurrencyInfo(nGoodsId)
	local tbGoods =  me.GetShopBuyItemInfo(nGoodsId);
	if not tbGoods then
		return nil;
	end
	local nType = me.nCurrencyType;
	if nType == 1 then
		local szUnitName = "银两";
		local nCount = me.nCashMoney;
		return szUnitName, nCount;
	elseif nType == 3 then
		local szUnitName = self:GetItemCoinUnit(tbGoods.ItemCoinIndex);
		local nCount = me.GetCashCoin(me.GetItemCoinIndex(nGoodsId)) or 0;
		return szUnitName, nCount;
	elseif nType == 4 then
		local szUnitName = "积分";
		local nCount = me.GetTask(2001, 9) or 0;
		return szUnitName, nCount;
	elseif nType == 7 then
		local szUnitName = "绑定银两";
		local nCount = me.GetBindMoney();
		return szUnitName , nCount;
	elseif nType == 8 then
		local szUnitName = "机关耐久度";
		local nCount = me.GetMachineCoin();
		return szUnitName, nCount;
	elseif nType == 10 then
		local szUnitName = self:GetValueCoinUnit(tbGoods.ValueCoinIndex);
		local nCount = me.GetValueCoin(me.GetValueCoinIndex(nGoodsId)) or 0;
		return szUnitName, nCount;
	end
	return nil;
end

-- 检查够不够对应的货币买要买的商品
function Shop:CheckCanBuy(nGoodsId)
	local tbGoods =  me.GetShopBuyItemInfo(nGoodsId);
	if not tbGoods then
		return 0;
	end
	-- 各项货币
	local tbCurrencyType = { 
							 [1] = {nMine = me.nCashMoney or 0, nGoods = tbGoods.nPrice or 0, szMsg = "你的银两不足" },
--							 [2] = {nMine = me.GetFuYuan() or 0, nGoods = tbGoods.nPrice or 0, szMsg = "你的福缘不足"},
							 [3] = {nMine = me.GetCashCoin(me.GetItemCoinIndex(nGoodsId)) or 0, nGoods = tbGoods.nCoin or 0, szMsg = "你的%s不足"},
							 [4] = {nMine = me.GetTask(2001, 9) or 0, nGoods = tbGoods.nScore or 0, szMsg = "你的积分不足"},
--							 [5] = {nMine = me.GetTongOffer() or 0, nGoods = tbGoods.nPrice or 0, szMsg = "你的贡献度不足"},
--							 [6] = {nMine = me.GetHonour() or 0, nGoods = tbGoods.nPrice or 0, szMsg = "你的联赛荣誉点数不足"},
							 [7] = {nMine = me.GetBindMoney() or 0, nGoods = tbGoods.nPrice or 0, szMsg = "你的绑定银两不足"},
							 [8] = {nMine = me.GetMachineCoin() or 0, nGoods = tbGoods.nPrice or 0, szMsg = "你的机关力耐久力不足"},
							 [10] = {nMine = me.GetValueCoin(me.GetValueCoinIndex(nGoodsId)) or 0, nGoods = tbGoods.nCoin or 0, szMsg = "你的%s不足"},
						   }
	-- 帮会资金有服务器检测
	if me.nCurrencyType == 9 then
		return 1;
	end 					   
	if tbCurrencyType[me.nCurrencyType].nMine >= tbCurrencyType[me.nCurrencyType].nGoods then
		return 1, "符合购买的条件";
	else
		return 0, tbCurrencyType[me.nCurrencyType].szMsg;
	end
end

-- 从配置文件gamesetting.ini中读取金币替代物品的单位名称
function Shop:ReadItemCoinUnitInfo()
	local tbIniInfo = Lib:LoadIniFile(SZ_FILE_GAMESETTING);
	assert(tbIniInfo);
	self.tbItemCoinUnit = {};
	for szSessionName, tbItemCoinInfo in pairs(tbIniInfo) do
		if (szSessionName == "Coin") then
			local nCount = tonumber(tbItemCoinInfo["nCount"]);
			if (nCount <= 0) then
				break;
			end
			for i = 1, nCount do
				local szInfoKey = string.format("CoinParam%s_", i);
				local nGenre = tonumber(tbItemCoinInfo[szInfoKey .. 1]);
				local nDetail = tonumber(tbItemCoinInfo[szInfoKey .. 2]);
				local nParticular = tonumber(tbItemCoinInfo[szInfoKey .. 3]);
				local nLevel = tonumber(tbItemCoinInfo[szInfoKey .. 4]);
				local szName = KItem.GetNameById(nGenre, nDetail, nParticular, nLevel);
				self.tbItemCoinUnit[i] = szName;
			end
		end
	end
end

-- 获取金币替代物品的单位
function Shop:GetItemCoinUnit(nItemCoinIndex)
	return self.tbItemCoinUnit[nItemCoinIndex] or "";
end

-- 从配置文件中gamesetting.ini中读取数值货币的单位名称
function Shop:ReadValueCoinUnitInfo()
	local tbIniInfo = Lib:LoadIniFile(SZ_FILE_GAMESETTING);
	assert(tbIniInfo);
	self.tbValueCoinUnit = {};
	for szSessionName, tbValueCoinInfo in pairs(tbIniInfo) do
		if (szSessionName == "ValueCoin") then
			local nCount = tonumber(tbValueCoinInfo["nCount"]);
			if (nCount <= 0) then
				break;
			end
			for i = 1, nCount do
				local szKeyName = string.format("ValueName%s", i);
				local szName = tostring(tbValueCoinInfo[szKeyName]);
				self.tbValueCoinUnit[i] = szName;
			end
		end
	end
end

-- 获取数值货币的单位
function Shop:GetValueCoinUnit(nValueCoinIndex)
	return self.tbValueCoinUnit[nValueCoinIndex] or "";
end

-- 打开外装商店
function Shop:OpenWaiZhuangShop(nShopId, nCurreycyType)
	if self.bOpenWaiZhuan and self.bOpenWaiZhuan == 1 then
		me.OpenShop(nShopId, nCurreycyType);
	else
		Dialog:Say("外装尚在运货途中，敬请期待！");
	end
end

function Shop:WaiZhuangShopSwitch(nSwitch)
	self.bOpenWaiZhuan = nSwitch;
end

Shop.bOpenWaiZhuan = 1;

--	2012/8/15 19:05:23  新增声望商店打开验证代码
function Shop:ApplyOpenShop(nShopId) --@错误返回0 & ERR信息	@正确返回1
	if type(nShopId) ~= "number" then
		return 0, "参数错误";
	end

	local nIsCanOpen, szMsg = self:IsCanOpenShop(me, nShopId);
	if (nIsCanOpen == 0) then
		Dialog:Say(szMsg);
		return 0, szMsg;
	end
	
	self:OpenShop(nShopId);

	return 1;
end

function Shop:IsCanOpenShop(pPlayer, nShopId) --@错误返回0 & ERR信息	@正确返回1
	if type(nShopId) ~= "number" then
		return 0, "参数错误";
	end

	local tbShopInfo = self.tbReputeShopCheck[nShopId];
	if not tbShopInfo then	--判断商店ID在配置文件中是否存在 如果不存在则直接返回
		return 0 , "商店ID不存在";
	end
	
	--	验证开服时间
	local nServerRunTime = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME)) or 0;
	if nServerRunTime == 0 then
		return 0, "服务器时间获取失败";
	end
	local nServerRunDay = math.floor((GetTime() - nServerRunTime) / (3600 * 24));

	if nServerRunDay < tbShopInfo.nServerRunDayNeed then
		return 0, "开服时间未达到打开此商店的资格";
	end
	
	--	验证地图类型
	local tbAllowMapType = Lib:SplitStr(tbShopInfo.szMapType, "|");	-- 允许打开商店的地图类型Table
	local szMapTypeNow = GetMapType(pPlayer.nMapId);
	
	
	for _, szMapType in pairs(tbAllowMapType) do	-- 遍历检查允许的地图类型表 如果有相同的地图类型 则调用服务器接口打开相应商店 并退出函数
		if (szMapType == szMapTypeNow) then	
			return 1;
		end
	end

	return 0, "此地图不能打开当前类型商店";
end

function Shop:LoadReputeShopFile()
	local tbReputeShopCheckConfig = Lib:LoadTabFile("\\setting\\player\\reputeshopcheck.txt");	 --读取txt文件
	
	if not tbReputeShopCheckConfig  then	-- 如果读取失败则直接返回 不执行下面的步骤
		return 0;
	end
	self.tbReputeShopCheck = {};
	for nId, tbShopCheckConfig in pairs(tbReputeShopCheckConfig) do	-- 建立商店ID的检查表	这里需要考虑前几列为说明信息的情况
			local nShopID		= tonumber(tbShopCheckConfig.ShopId) or 0;
			local nCurrencyType = tonumber(tbShopCheckConfig.CurrencyType) or 1;
			local nServerRunDay = tonumber(tbShopCheckConfig.ServerRunDayNeeded) or 0;
			local szMapType		= tbShopCheckConfig.MapType;
			
			if (szMapType ~= "" and nShopID > 0) then				
				self.tbReputeShopCheck[nShopID] = {
							["nShopID"] = nShopID,
							["nCurrencyType"] = nCurrencyType,
							["nServerRunDayNeed"] = nServerRunDay,
							["szMapType"] = szMapType
						}
			else
				print("reputeshopcheck.txt 配置文件:商店允许打开地图类型填写错误");
			end
	end
	return 1;
end

function Shop:OpenShop(nShopId) --@错误返回0 & ERR信息	@正确返回1
	if (not nShopId) then
		return 0;
	end
	
	local nCurrencyType = self.tbReputeShopCheck[nShopId].nCurrencyType;
	if (not nCurrencyType) then
		Dialog:Say("商店类型不存在！");
		return 0;
	end
	me.OpenShop(nShopId, nCurrencyType);
	return 1;
end

Shop:LoadReputeShopFile();
