--事件通用gift接口
--孙多良
--2008.10.31
--传入表格格式
--tbParam = {
--tbAward = {{nGenre=, nDetail=,nParticular=,nLevel=,nCount=,nBind=,nTimeLimit=分钟, nTimeType=限时类型(默认0绝对时间，1为相对时间)},{...},...}, 获得物品
--tbMareial = {{nGenre=, nDetail=,nParticular=,nLevel=,nCount=},{...},...}, 必须物品
--tbMareialOne = {{nGenre=, nDetail=,nParticular=,nLevel=,nCount=1}}, --材料必须其中一种
--}
--对外接口1 Dialog:OpenGift(szContent, tbParam) --标题，表格内容 
--对外接口2 Dialog:OpenGift(szContent, {"szCheckFun"}, {szOkFun, self}) --标题, 检查放入物品函数(client端), 确定函数
--szCheckFun接口参数szCheckFun(tbGiftSelf, pPickItem, pDropItem, nX, nY); --client端;参数：giftself, 放入物品,拿出物品
--szOkFun接口参数szOkFun(tbBoxItem);	--物品对象表tbBoxItem={{pItem,nx,ny},...};

Require("\\script\\lib\\gift.lua");
Dialog.tbGift = Gift:New();

local tbGift = Dialog.tbGift;

function tbGift:OnSwitch(pPickItem, pDropItem, nX, nY)
	self.nOnSwithItemCount = self.nOnSwithItemCount or 0;	--自定义统计放入有效物品数量
	if pDropItem and self._tbParam then
		local szParam = string.format("%s,%s,%s,%s",pDropItem.nGenre,pDropItem.nDetail,pDropItem.nParticular,pDropItem.nLevel);
		if self._tbParam[szParam] == nil and self._tbParamOne[szParam] == nil then
			me.Msg("我不需要这个物品，请重新放入我所需的物品。");
			return 0;
		end
	end
	if self._varCheckFun and type(self._varCheckFun[1]) == "string" then
		local tbUserParam = {};
		local szFun = self._varCheckFun[1]
		for i = 2, #(self._varCheckFun) do
			table.insert(tbUserParam, self._varCheckFun[i]);
		end
		local nRet = 0;
		local fnFunc, tbSelf = KLib.GetValByStr(szFun);
		if fnFunc then
			if tbSelf then
				nRet = fnFunc(tbSelf, self, pPickItem, pDropItem, nX, nY, unpack(tbUserParam)) or 0;
			else
				nRet = fnFunc(self, pPickItem, pDropItem, nX, nY, unpack(tbUserParam)) or 0;
			end
		end
		return nRet
	end
	return	1;
end

function tbGift:UpdateContent(szContent)
	self._szContent = szContent;
end

function tbGift:OnUpdateParam(szContent, tbParam, tbParamOne, varCheckFun)
	self._szContent = szContent;
	self._tbParam = {};
	self.nOnSwithItemCount = 0;
	self.tbOnSwithItemCount = {};
	if varCheckFun then
		self._varCheckFun = varCheckFun;
	else
		self._varCheckFun = nil;
	end
	
	if type(tbParam) ~= "table" and type(tbParamOne) ~= "table" then
		self._tbParam = nil;
		return 0;
	end
	
	for ni, tbItem in ipairs(tbParam) do
		if tbItem.nGenre ~= 0 and tbItem.nDetail ~= 0 and tbItem.nParticular ~= 0 then
			local szParam = string.format("%s,%s,%s,%s",tbItem.nGenre, tbItem.nDetail, tbItem.nParticular, tbItem.nLevel);
			self._tbParam[szParam] = tbItem.nCount or 1;
		end
	end
	self._tbParamOne = {};	
	for ni, tbItem in ipairs(tbParamOne) do
		if tbItem.nGenre ~= 0 and tbItem.nDetail ~= 0 and tbItem.nParticular ~= 0 then
			local szParam = string.format("%s,%s,%s,%s",tbItem.nGenre, tbItem.nDetail, tbItem.nParticular, tbItem.nLevel);
			self._tbParamOne[szParam] = tbItem.nCount or 1;
		end
	end
	
end

function tbGift:OnOK(varParam)
	
	if type(varParam) == "table" and type(varParam[1]) == "function" then
		local tbBoxItemObj = {};
		local pFind = self:First();
		while pFind do
			table.insert(tbBoxItemObj, {pFind, self:LastX(), self:LastY()});
			pFind = self:Next();
		end
		table.insert(varParam, tbBoxItemObj);
		Lib:CallBack(varParam);
		return 0;
	end
	
	local nFreeCount = 0;
	for ni, tbItem in pairs(varParam.tbAward) do
		nFreeCount = nFreeCount + tbItem.nCount;
	end	
	if me.CountFreeBagCell() < nFreeCount then
		me.Msg(string.format("Hành trang không đủ ，您需要%s个空间格子。", nFreeCount));
		return 0;
	end
	local nMustItem = nil;
	local nOneItem = nil;
	self.tbItemList = {};
	if varParam.tbMareial then
		for ni, tbItem in ipairs(varParam.tbMareial) do
			if tbItem.nGenre ~= 0 and tbItem.nDetail ~= 0 and tbItem.nParticular ~= 0 then
				local szParam = string.format("%s,%s,%s,%s",tbItem.nGenre, tbItem.nDetail, tbItem.nParticular, tbItem.nLevel);
				self.tbItemList[szParam] = tbItem.nCount or 1;
				nMustItem = 1;
			end
		end
	end
	self.tbItemListOne = {};
	self.tbItemListOneTemp = {};
	if varParam.tbMareialOne then
		for ni, tbItem in ipairs(varParam.tbMareialOne) do
			if tbItem.nGenre ~= 0 and tbItem.nDetail ~= 0 and tbItem.nParticular ~= 0 then
				local szParam = string.format("%s,%s,%s,%s",tbItem.nGenre, tbItem.nDetail, tbItem.nParticular, tbItem.nLevel);
				self.tbItemListOne[szParam] = tbItem.nCount or 1;
				self.tbItemListOneTemp[szParam] = tbItem.nCount or 1;
				nOneItem = 1;
			end
		end
	end
	local pFind = self:First();
	while pFind do
			local nItem = 0;
		 	if nMustItem and self:DecreaseItemInList(pFind, self.tbItemList) == 0 then
				nItem = 1;
			end
		 	if nOneItem and self:DecreaseItemInOneList(pFind, self.tbItemListOne, self.tbItemListOneTemp) == 0 then
				nItem = nItem + 1;
			end
			
			if nMustItem and nOneItem then
				if nItem >= 2 then
					me.Msg("您放入的物品数量不对。");
					return 0;
				end
			elseif not nMustItem and not nOneItem then
					me.Msg("您放入的物品数量不对。");
					return 0;
			elseif not nMustItem or not nOneItem then
				if nItem >= 1 then
					me.Msg("您放入的物品数量不对。");
					return 0;	
				end
			end
			pFind = self:Next();
	end
	
	if nMustItem and self:CheckItemInList(self.tbItemList) == 0 then
		me.Msg("您放入的物品数量不对。");
		return 0;
	end
	
	if nOneItem and self:CheckItemInOneList(self.tbItemListOne, self.tbItemListOneTemp) == 0 then
		me.Msg("您放入的物品数量不对。");
		return 0;
	end
	
	-- 删除物品
	local pFind = self:First();
	while pFind do
		Dbg:WriteLog("通过Gift",  me.szName..",给予界面扣除物品:", pFind.szName);
		if me.DelItem(pFind, Player.emKLOSEITEM_KILLER) ~= 1 then
			return 0;
		end
		pFind = self:Next();
	end
	for ni, tbItem in pairs(varParam.tbAward) do
		for i=1, tbItem.nCount  do
			local pItem = me.AddItem(tbItem.nGenre, tbItem.nDetail, tbItem.nParticular, tbItem.nLevel);
			if pItem then
				if tbItem.nBind then
					pItem.Bind(tbItem.nBind);
				end
				if tbItem.nTimeLimit then
					local nType = 0;
					if tbItem.nTimeType then
						nType = tbItem.nTimeType;
					end
					me.SetItemTimeout(pItem, os.date("%Y/%m/%d/%H/%M/%S", GetTime() + tbItem.nTimeLimit * 60), nType);
				end
				Dbg:WriteLog("通过Gift",  me.szName..",给予界面获得物品:", pItem.szName);
			end
		end
	end
	if type(varParam.fnOnSucceed) == "function" then
		varParam.fnOnSucceed(unpack(varParam.tbSucceedParams));
	end
end

function tbGift:CheckItemInList(tbItemList)
	for szParam, nCount in pairs(tbItemList) do
		return 0;
	end 
	return 1;
end

function tbGift:CheckItemInOneList(tbItemOrgList, tbItemNewList)
	local nNeed = 0;
	for szParam, nCount in pairs(tbItemOrgList) do
		if not tbItemNewList[szParam] then
			return 0;
		end
		if tbItemNewList[szParam] ~= nCount and tbItemNewList[szParam] ~= 0 then
			return 0;
		end
		if tbItemNewList[szParam] ~= nCount and tbItemNewList[szParam] == 0 then
			nNeed = nNeed + 1;
		end
	end
	if nNeed ~= 1 then
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

function tbGift:DecreaseItemInOneList(pFind, tbItemOrgList, tbItemNewList)
	for szItem, nCount in pairs(tbItemOrgList) do
		local szParam = string.format("%s,%s,%s,%s",pFind.nGenre, pFind.nDetail, pFind.nParticular, pFind.nLevel);
		if szItem == szParam then
			if tbItemOrgList[szItem] - pFind.nCount < 0 then
				return 0;
			end
			tbItemNewList[szItem] = tbItemOrgList[szItem] - pFind.nCount;
			return 1;
		end
	end
	return 0;	
end

function tbGift:OnOpen(szContent, varParam, varFun)
	
	if type(varParam) == "table" and (varParam.tbMareial or varParam.tbMareialOne) then
		me.CallClientScript({"Dialog.tbGift:OnUpdateParam", szContent or "请放入物品", varParam.tbMareial or {}, varParam.tbMareialOne or {}});
		Dialog:Gift("Dialog.tbGift", varParam);
		return 0;
	end
	
	if type(varFun) == "table" and type(varFun[1]) == "function" then
		me.CallClientScript({"Dialog.tbGift:OnUpdateParam", szContent or "请放入物品", 0, 0, varParam});		
		Dialog:Gift("Dialog.tbGift", varFun);
		return 0;
	end
end
