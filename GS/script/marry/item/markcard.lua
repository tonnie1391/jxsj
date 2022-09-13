-- 文件名　：markcard.lua
-- 创建者　：furuilei
-- 创建时间：2009-12-18 10:26:53
-- 功能描述：面具卡片
-- modify by zhangjinpin@kingsoft 2010-01-20

local tbItem = Item:GetClass("marry_markcard");

--===================================================================

tbItem.TIME_FOREVER = -1;	-- 道具没有有效时间，永久有效
tbItem.SEX_MALE	= 0;		-- 性别需求，男性
tbItem.SEX_FEMALE = 1;		-- 性别需求，女性
tbItem.SEX_BOTH = -1;		-- 没有性别需求

tbItem.tbCardInfo = {
	[1] = {szName = "结义兄弟面具", tbCardGDPL = {18, 1, 598, 5}, tbMarkGDPL = {1, 13, 39, 1}, nNeedLevel = 1, nPurviewLevel = 2, nNeedSex = tbItem.SEX_MALE},
	[2] = {szName = "闺中密友面具", tbCardGDPL = {18, 1, 598, 6}, tbMarkGDPL = {1, 13, 40, 1}, nNeedLevel = 1, nPurviewLevel = 2, nNeedSex = tbItem.SEX_FEMALE},
	[3] = {szName = "蓝颜知己（华丽面具）", tbCardGDPL = {18, 1, 598, 1}, tbMarkGDPL = {1, 13, 35, 1}, nNeedLevel = 4, nPurviewLevel = 4, nNeedSex = tbItem.SEX_MALE},
	[4] = {szName = "红颜知己（华丽面具）", tbCardGDPL = {18, 1, 598, 2}, tbMarkGDPL = {1, 13, 36, 1}, nNeedLevel = 4, nPurviewLevel = 4, nNeedSex = tbItem.SEX_FEMALE},
	[5] = {szName = "蓝颜知己（普通面具）", tbCardGDPL = {18, 1, 598, 3}, tbMarkGDPL = {1, 13, 37, 1}, nNeedLevel = 4, nPurviewLevel = 4, nNeedSex = tbItem.SEX_MALE},
	[6] = {szName = "红颜知己（普通面具）", tbCardGDPL = {18, 1, 598, 4}, tbMarkGDPL = {1, 13, 38, 1}, nNeedLevel = 4, nPurviewLevel = 4, nNeedSex = tbItem.SEX_FEMALE},
	};

--===================================================================

function tbItem:CanUse(pItem, tbCardInfo)
	if (Marry:CheckState() == 0) then
		return 0;
	end
	local szErrMsg = "";
	if (not tbCardInfo) then
		return 0, szErrMsg;
	end
	
	local bIsWeddingMap = self:CheckWeddingMap();
	if (0 == bIsWeddingMap) then
		szErrMsg = "您当前所在场地不是典礼场地，不能使用该道具";
		return 0, szErrMsg;
	end
	
	local nNeedSex = tbCardInfo.nNeedSex;
	if (nNeedSex ~= self.SEX_BOTH) then
		if (me.nSex ~= nNeedSex) then
			szErrMsg = "由于性别原因，你不能使用这张卡片。";
			return 0, szErrMsg;
		end
	end
	
	local nPurviewLevel = tbCardInfo.nPurviewLevel;
	if (nPurviewLevel < self:GetPurviewLevel()) then
		szErrMsg = "根据你的权限等级，不适合使用这个卡片。";
		return 0, szErrMsg;
	end
	
	if (0 == Marry:CheckWeddingMap(me.nMapId)) then
		szErrMsg = "你没有处在典礼场地当中，不能使用该物品。";
		return 0, szErrMsg;
	end
	
	local tbCoupleName = Marry:GetWeddingOwnerName(me.nMapId) or {};
	local bIsCurMapItem = 0;	-- 是否是当前地图可以使用的物品
	for _, szName in pairs(tbCoupleName) do
		if (szName == pItem.szCustomString) then
			bIsCurMapItem = 1;
			break;
		end
	end
	if (0 == bIsCurMapItem) then
		szErrMsg = "这个物品与当前举行典礼的二位侠侣不匹配，不能使用！";
		return 0, szErrMsg;
	end
	
	local nMyCurPurviewLevel = Marry:GetWeddingPlayerLevel(me.nMapId, me.szName);
	if (nMyCurPurviewLevel < tbCardInfo.nNeedLevel) then
		szErrMsg = "你目前的身份不足以使用这个道具。";
		return 0, szErrMsg;
	end
	
	local nFreeBag = me.CountFreeBagCell();
	if (nFreeBag < 1) then
		szErrMsg = "您的包裹空间不足，还是清理出1格包裹空间再来试试吧。";
		return 0, szErrMsg;
	end
	
	return 1;
end

function tbItem:CheckWeddingMap()
	return Marry:CheckWeddingMap(me.nMapId);
end

function tbItem:GetWeddingLevel()
	return Marry:GetWeddingLevel(me.nMapId);
end

function tbItem:GetPurviewLevel()
	return Marry:GetWeddingPlayerLevel(me.nMapId, me.szName);
end

function tbItem:SetPurviewLevel(nPurviewLevel)
	return Marry:SetWeddingPlayerLevel(me.nMapId, me.szName, nPurviewLevel);
end

function tbItem:GetItemInfo(pItem)
	if (not pItem) then
		return;
	end
	
	local szCardGDPL = string.format("%s-%s-%s-%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
	for _, tbInfo in pairs(self.tbCardInfo) do
		local szGDPL = string.format("%s-%s-%s-%s", unpack(tbInfo.tbCardGDPL));
		if (szCardGDPL == szGDPL) then
			return tbInfo;
		end
	end
end

function tbItem:OnUse()
	local tbCardInfo = self:GetItemInfo(it);
	local bCanUse, szErrMsg = self:CanUse(it, tbCardInfo);
	if (0 == bCanUse) then
		if ("" ~= szErrMsg) then
			Dialog:Say(szErrMsg);
		end
		return 0;
	end
	
	local pMarkItem = me.AddItem(unpack(tbCardInfo.tbMarkGDPL));
	if (pMarkItem) then
		local nWeddingLevel = self:GetWeddingLevel();
		local nPurviewLevel = tbCardInfo.nPurviewLevel;
		pMarkItem.Bind(1);
		self:SetPurviewLevel(nPurviewLevel);
		pMarkItem.Sync();
	end
	return 1;
end
