-- 文件名　：hunlishangren.lua
-- 创建者　：furuilei
-- 创建时间：2009-12-23 11:34:12
-- 功能描述：婚礼npc（婚礼商人）

local tbNpc = Npc:GetClass("marry_hunlishangren");

--=================================================================

tbNpc.tbQingHuaGDPL = {18, 1, 565, 1};

tbNpc.tbItemInfo = {
	[1] = {nIndex = 1, szName = "结义兄弟面具卡片", bBind = 0, nNeedLevel = 4, tbGDPL = {18, 1, 598, 5}, nCost = 10, nNeedRecordName = 1, nLiveTime = 24 * 3600},
	[2] = {nIndex = 2, szName = "闺中密友面具卡片", bBind = 0, nNeedLevel = 4, tbGDPL = {18, 1, 598, 6}, nCost = 10, nNeedRecordName = 1, nLiveTime = 24 * 3600},
	[3] = {nIndex = 3, szName = "邀请函", bBind = 0, nNeedLevel = 2, tbGDPL = {18, 1, 591, 1}, nCost = 1, nNeedRecordName = 1, nLiveTime = 24 * 3600},
	[4] = {nIndex = 4, szName = "逐客令", bBind = 0, nNeedLevel = 2, tbGDPL = {18, 1, 592, 1}, nCost = 1, nNeedRecordName = 1, nLiveTime = 24 * 3600},
	};

--=================================================================


function tbNpc:OnDialog()
	if (Marry:CheckState() == 0) then
		return 0;
	end
	if (1 == Marry:CheckWeddingMap(me.nMapId)) then
		self:InWeddingMap();
	else
		self:OutWeddingMap();
	end
end

-- 没有在婚礼地图当中（直接打开商店买物品）
function tbNpc:OutWeddingMap()
	self:OpenShop();
end

-- 在婚礼地图当中，会出现选项
function tbNpc:InWeddingMap()
	if (self:GetLevel() <= 0) then
		Dialog:Say("你不是受邀宾客，无法从我这里购买物品。");
		return 0;
	end
	
	local szMsg = "我这里有一些典礼有关的道具出售，你要看看吗？";
	local tbOpt = self:GetOpt() or {};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GetOpt()
	local tbItemList = self:GetItemList();
	if (not tbItemList) then
		return;
	end
	
	local tbOpt = {};
	for _, tbItemInfo in pairs(tbItemList) do
		local szOpt = string.format("<color=yellow>%s<color> 售价：<color=yellow>%s<color>情花",
			tbItemInfo.szName, tbItemInfo.nCost);
		table.insert(tbOpt, {szOpt, self.BuyItem, self, tbItemInfo.nIndex, tbItemInfo.nCost});
	end
	table.insert(tbOpt, {"打开商店", self.OpenShop, self});
	table.insert(tbOpt, {"以后再来吧"});
	
	return tbOpt;
end

function tbNpc:GetItemList()
	local nMyLevel = self:GetLevel();
	if (nMyLevel <= 0 or nMyLevel > 4) then
		return;
	end
	
	local tbItemList = {};
	for _, tbInfo in pairs(self.tbItemInfo) do
		-- 只有等级足够，并且非商店销售的物品才会被筛选出来
		if (nMyLevel >= tbInfo.nNeedLevel) then
			table.insert(tbItemList, tbInfo);
		end
	end
	return tbItemList;
end

function tbNpc:GetLevel()
	return Marry:GetWeddingPlayerLevel(me.nMapId, me.szName) or 0;
end

-- 打开情花之石商店
function tbNpc:OpenShop()
	me.OpenShop(165, 3);
end

function tbNpc:BuyItem(nIndex, nCostPerItem)
	if (not nCostPerItem or 0 >= nCostPerItem) then
		return;
	end
	local nQingHuaCount = me.GetItemCountInBags(unpack(Marry.ITEM_QINGHUA_ID));
	local nCanBuy = math.floor(nQingHuaCount / nCostPerItem);
	if (not nQingHuaCount or nQingHuaCount <= 0 or nCanBuy <= 0) then
		Dialog:Say("这里的商品需要用情花来兑换，请携带足够数量的情花再来吧。");
		return;
	end
	
	Dialog:AskNumber("请输入购买的数量：", nCanBuy, self.OnWishBuy, self, nIndex);
end

function tbNpc:OnWishBuy(nIndex, nCount)
	if (not nCount or nCount <= 0) then
		Dialog:Say("你输入的数字有误。");
		return;
	end
	
	local tbItemInfo = {};
	for _, tbInfo in pairs(self.tbItemInfo) do
		if (nIndex == tbInfo.nIndex) then
			tbItemInfo = tbInfo;
			break;
		end
	end
	local nNeedCount = tbItemInfo.nCost * nCount;
	if (nNeedCount <= 0) then
		return;
	end
	local nQingHuaCount = me.GetItemCountInBags(unpack(Marry.ITEM_QINGHUA_ID));
	if (nNeedCount > nQingHuaCount) then
		local szErrMsg = string.format("购买<color=yellow>%s<color>个<color=yellow>%s<color>，需要<color=yellow>%s<color>朵情花。你现在的数量不足，请确带够来再来吧。",
			nCount, tbItemInfo.szName, nNeedCount);
		Dialog:Say("");
		return;
	end
	
	local szMsg = string.format("你现在要购买<color=yellow>%s<color>个<color=yellow>%s<color>，需要<color=yellow>%s<color>个朵情花。确定吗？",
		nCount, tbItemInfo.szName, nNeedCount);
	local tbOpt = {
		{"是的，我要购买", self.SureBuy, self, nNeedCount, nCount, tbItemInfo},
		{"我还是想想吧"},
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:SureBuy(nNeedCount, nCount, tbItemInfo)
	if (me.CountFreeBagCell() < nCount) then
		Dialog:Say(string.format("您的包裹空间不足，还是清理出<color=yellow>%s<color>个包裹空间再来吧。", nCount));
		return;
	end
	
	local bRet = me.ConsumeItemInBags2(nNeedCount, unpack(Marry.ITEM_QINGHUA_ID));
	if (bRet ~= 0) then
		return;
	end
	
	for i = 1, nCount do
		local pItem = me.AddItem(unpack(tbItemInfo.tbGDPL));
		if (pItem) then
			local nWddingCloseTime = self:GetWeddingCloseTime();
			pItem.SetTimeOut(0, nWddingCloseTime);
			self:RecordCoupleName(pItem, tbItemInfo);
			pItem.Bind(tbItemInfo.bBind);
			pItem.Sync();
		end
	end
end

function tbNpc:GetWeddingCloseTime()
	local nCurTime = GetTime();
	local nCurHour = tonumber(os.date("%H", nCurTime));
	local nCurDate = tonumber(os.date("%Y%m%d", nCurTime));
	local nCrossDayTime = Lib:GetDate2Time(nCurDate);
	local nWeddingCloseTime = 0;
	if (nCurHour <= 7) then
		nWeddingCloseTime = nCrossDayTime + 7 * 3600;
	else
		nWeddingCloseTime = nCrossDayTime + (24 + 7) * 3600;
	end
	return nWeddingCloseTime;
end

function tbNpc:RecordCoupleName(pItem, tbItemInfo)
	if (not pItem or tbItemInfo.nNeedRecordName == 0) then
		return 0;
	end
	
	local tbCoupleName = Marry:GetWeddingOwnerName(me.nMapId);
	if (not tbCoupleName or #tbCoupleName ~= 2) then
		return 0;
	end
	if (tbItemInfo.nNeedRecordName == 1) then
		pItem.SetCustom(Item.CUSTOM_TYPE_EVENT, tbCoupleName[1]);
		pItem.Sync();
		return 1;
	elseif (tbItemInfo.nNeedRecordName == 2) then
		local szName = string.format("祝贺%s和%s幸福快乐", tbCoupleName[1], tbCoupleName[2]);
		pItem.SetCustom(Item.CUSTOM_TYPE_EVENT, szName);
		pItem.Sync();
		return 1;
	end
	return 0;
end
