Require("\\script\\task\\armycamp\\campinstancing\\instancingmanager.lua")

Task.tbArmyCampInstancingManager.tbGift = Gift:New();

local tbGift = Task.tbArmyCampInstancingManager.tbGift;
tbGift._szTitle = "";
																							-- bAllowMore 表示是否可以放入比要求的数量多
function Task:OnGift(szTitle, tbNeedItemList, tbOkCallBack, tbCancelCallBack, tbRepeatCheck, bAllowMore)
	me.CallClientScript({"Task.tbArmyCampInstancingManager.tbGift:SetContent", szTitle});
	self.tbArmyCampInstancingManager.tbGift:OnGift(szTitle, tbNeedItemList, tbOkCallBack, tbCancelCallBack, tbRepeatCheck, bAllowMore);
end

function tbGift:SetContent(szContent)
	self._szContent = szContent;
end

function tbGift:OnGift(szTitle, tbNeedItemList, tbOkCallBack, tbCancelCallBack, tbRepeatCheck, bAllowMore)
	tbGift._szTitle = szTitle;
	local tbArmyCampGiftData = self:GetGiftData();
	tbArmyCampGiftData.tbNeedItemList = tbNeedItemList;
	tbArmyCampGiftData.tbOkCallBack = tbOkCallBack;
	tbArmyCampGiftData.tbCancelCallBack = tbCancelCallBack;
	tbArmyCampGiftData.tbRepeatCheck = tbRepeatCheck;
	tbArmyCampGiftData.bAllowMore = bAllowMore;
	
	Dialog:Gift("Task.tbArmyCampInstancingManager.tbGift");
end


function tbGift:GetGiftData()
	local tbPlayerData	= me.GetTempTable("Task");
	local tbArmyCampGiftData	= tbPlayerData.tbArmyCampGiftData;
	if (not tbArmyCampGiftData) then
		tbArmyCampGiftData	= {};
		tbPlayerData.tbArmyCampGiftData	= tbArmyCampGiftData;
	end;
	
	return tbArmyCampGiftData;
end


function tbGift:OnOK()
	local tbRepeatCheck = self:GetGiftData().tbRepeatCheck;
	local bAllowMore = self:GetGiftData().bAllowMore;
	if (tbRepeatCheck) then
		local bOK, nRet	= Lib:CallBack(tbRepeatCheck);	-- 调用回调
		if (nRet ~= 1) then
			return;
		end
	end
	
	local tbNeedItemList = self:GetGiftData().tbNeedItemList;
	assert(tbNeedItemList);

	-- 把 table 里每个物品的数量等同于原始的数量
	for i=1, #tbNeedItemList do
		tbNeedItemList[i].nRemainCount = tbNeedItemList[i][5];
	end

	-- 遍历判断给与界面中每个格子的物品
	local nFormItemCount = 0;
	local pFind = self:First();
	while pFind do
		self:DecreaseItemInList(pFind, tbNeedItemList, bAllowMore);
		pFind = self:Next();
	end

	for _,tbItem in ipairs(tbNeedItemList) do
		if (tbItem.nRemainCount > 0) then
			me.Msg("给的物品不合要求!")
			return;
		end
	end

	for i=1, #tbNeedItemList do
		tbNeedItemList[i].nRemainCount = tbNeedItemList[i][5];
	end
	local pFind = self:First();
	while pFind do
		local nDelCount = 0;
		for _,tbItem in ipairs(tbNeedItemList) do
			if (tbItem.nRemainCount > 0 and
				tbItem[1] == pFind.nGenre and 
				tbItem[2] == pFind.nDetail and 
				tbItem[3] == pFind.nParticular and 
				(tbItem[4] == pFind.nLevel or tbItem[4] == -1)) then
					if (tbItem.nRemainCount <= pFind.nCount) then
						if bAllowMore then
							nDelCount = pFind.nCount;
							tbItem.nRemainCount = 0;
						else
							nDelCount = tbItem.nRemainCount;
							tbItem.nRemainCount = 0;
						end
					else
						tbItem.nRemainCount = tbItem.nRemainCount - pFind.nCount;
						nDelCount = pFind.nCount;
					end;
					break;
			end
		end
		if nDelCount > 0 then
			assert(pFind.nCount >= nDelCount);
			if nDelCount == pFind.nCount then
				me.DelItem(pFind, Player.emKLOSEITEM_TYPE_TASKUSED);
			else
				pFind.SetCount(pFind.nCount - nDelCount, Item.emITEM_DATARECORD_REMOVE);
			end
		end
		pFind = self:Next();
	end
	
	local tbCallBack = self:GetGiftData().tbOkCallBack;
	if (tbCallBack) then
		Lib:CallBack(tbCallBack);
	end
	
	me.CallClientScript({"Task.tbArmyCampInstancingManager.tbGift:SetContent", ""});
	self:GetGiftData().tbOkCallBack = nil;
end;


-- 判断指定物品是否在靠标物品列表中，若在则把数量 -1
function tbGift:DecreaseItemInList(pFind, tbNeedItemList, bAllowMore)
	for _,tbItem in ipairs(tbNeedItemList) do
		if (tbItem.nRemainCount > 0 and
			tbItem[1] == pFind.nGenre and 
			tbItem[2] == pFind.nDetail and 
			tbItem[3] == pFind.nParticular and 
			(tbItem[4] == pFind.nLevel or tbItem[4] == -1)) then
				tbItem.nRemainCount = tbItem.nRemainCount - pFind.nCount;
				break;
		end
	end
	return 1;
end


function tbGift:OnCancel()
	local tbCallBack = self:GetGiftData().tbCancelCallBack;
	if (tbCallBack) then
		Lib:CallBack(tbCallBack);
	end
	
	me.CallClientScript({"Task.tbArmyCampInstancingManager.tbGift:SetContent", ""});
	self:GetGiftData().tbCancelCallBack = nil;
end
