
Require("\\script\\lib\\gift.lua");
Wanted.Gift = Gift:New();

local tbGift = Wanted.Gift;

function tbGift:OnSwitch(pPickItem, pDropItem, nX, nY)
	if pDropItem then
		local szParam = string.format("%s,%s,%s,%s",pDropItem.nGenre,pDropItem.nDetail,pDropItem.nParticular,pDropItem.nLevel);
		if self._tbParam[szParam] == nil then
			me.Msg("Ta không cần vật phẩm này, hãy đặt lại vật phẩm khác phù hợp.");
			return 0;
		end
	end	
	return	1;
end

function tbGift:OnUpdateParam(szContent,tbParam)
	self._szContent = szContent;
	self._tbParam = {};
	for ni, tbItem in ipairs(tbParam) do
		if tbItem.nGenre ~= 0 and tbItem.nDetail ~= 0 and tbItem.nParticular ~= 0 then
			local szParam = string.format("%s,%s,%s,%s",tbItem.nGenre, tbItem.nDetail, tbItem.nParticular, tbItem.nLevel);
			self._tbParam[szParam] = tbItem.nCount;
		end
	end
end

function tbGift:OnOK(tbParam)
	local nFreeCount = 0;
	for ni, tbItem in pairs(tbParam.tbAward) do
		nFreeCount = nFreeCount + tbItem.nCount;
	end	
	if me.CountFreeBagCell() < nFreeCount then
		me.Msg(string.format("Hành trang không đủ chỗ trống, cần %s ô trống.", nFreeCount));
		return 0;
	end
	self.tbItemList = {};
	for ni, tbItem in ipairs(tbParam.tbMareial) do
		if tbItem.nGenre ~= 0 and tbItem.nDetail ~= 0 and tbItem.nParticular ~= 0 then
			local szParam = string.format("%s,%s,%s,%s",tbItem.nGenre, tbItem.nDetail, tbItem.nParticular, tbItem.nLevel);
			self.tbItemList[szParam] = tbItem.nCount;
		end
	end
	
	local pFind = self:First();
	while pFind do
		if self:DecreaseItemInList(pFind, self.tbItemList) == 0 then
			me.Msg("Số lượng vật phẩm không đúng.");
			return 0;
		end
		pFind = self:Next();
	end
	
	if self:CheckItemInList(self.tbItemList) == 0 then
		me.Msg("Số lượng vật phẩm không đúng.");
		return 0;
	end
	
	-- 删除物品
	local pFind = self:First();
	while pFind do
		Dbg:WriteLog("Nhiệm vụ truy nã",  me.szName..", cho phép giao diện trừ vật phẩm: ", pFind.szName);
		if me.DelItem(pFind, Player.emKLOSEITEM_KILLER) ~= 1 then
			return 0;
		end
		pFind = self:Next();
	end
	for ni, tbItem in pairs(tbParam.tbAward) do
		for i=1, tbItem.nCount  do
			local pItem = me.AddItem(tbItem.nGenre, tbItem.nDetail, tbItem.nParticular, tbItem.nLevel);
			if pItem then
				Dbg:WriteLog("Nhiệm vụ truy nã",  me.szName..", xuất hiện giao diện nhận vật phẩm: ", pItem.szName);
			end
		end
	end
end

function tbGift:CheckItemInList(tbItemList)
	for szParam, nCount in pairs(tbItemList) do
		return 0;
	end 
	return 1;
end
-- 判断指定物品是否在靠标物品列表中，若在则把数量 -1
function tbGift:DecreaseItemInList(pFind, tbItemList)
	for szItem, nCount in pairs(tbItemList) do
		local szParam = string.format("%s,%s,%s,%s",pFind.nGenre, pFind.nDetail, pFind.nParticular, pFind.nLevel);
		if szItem == szParam then
			tbItemList[szItem] = tbItemList[szItem] - pFind.nCount;
			if tbItemList[szItem] == 0 then
				tbItemList[szItem] = nil 
			elseif tbItemList[szItem] < 0 then
				return 0;
			end
			return 1;
		end
	end
	return 0;
end

function tbGift:OnOpen(szContent, tbParam)
	me.CallClientScript({"Wanted.Gift:OnUpdateParam", szContent, tbParam.tbMareial});
	Dialog:Gift("Wanted.Gift", tbParam);
end
