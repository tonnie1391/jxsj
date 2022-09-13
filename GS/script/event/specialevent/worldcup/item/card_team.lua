-- 文件名　：card_team.lua
-- 创建者　：furuilei
-- 创建时间：2010-05-17 10:26:10
-- 功能描述：球队卡

SpecialEvent.tbWroldCup = SpecialEvent.tbWroldCup or {};
local tbEvent = SpecialEvent.tbWroldCup;

local tbItem = Item:GetClass("card_team");

function tbItem:OnUse()
	if (tbEvent:CheckOpenState() == 0) then
		return 0;
	end
	local nLevel = it.nLevel;
	if (nLevel <= 0 or nLevel > tbEvent.MAX_CARD_NUM + 1) then
		return 0;
	end
	
	if (me.CountFreeBagCell() < 3) then
		Dialog:Say("请清理出3格的背包空间再使用这张卡。");
		return 0;
	end
	
	if (1 == self:NeedAdd_CardCollection()) then
		if (self:AddCardCollection() ~= 1) then
			return 0;
		end
	end
	
	-- 剑侠世界的卡片需要特殊处理
	local bIsJxsjCard = self:Is_JxsjCard(nLevel);
	if (bIsJxsjCard and bIsJxsjCard == 1) then
		nLevel = self:Use_JxsjCard();
		local pItem = me.AddItem(18, 1, 660, nLevel);
		if (not pItem) then
			me.SetItemTimeout(pItem, tbEvent.TIME_OUT_DATE, 0);
			return 0;
		end
		me.AddItem(1, 13, 65, 1);
		local szMsg = string.format("%s使用了一张剑侠世界卡片，获得一个沃德卡普面具和一张%s", me.szName, pItem.szName);
		me.SendMsgToKinOrTong(0, szMsg);
		me.SendMsgToFriend(szMsg);
		return 1;
	end
	
	local nTskId = tbEvent:GetCardTaskIdByIndex(nLevel);
	local nCurCardNum = me.GetTask(tbEvent.TASK_GROUP, nTskId) + 1;
	me.SetTask(tbEvent.TASK_GROUP, nTskId, nCurCardNum);
	
	tbEvent:UpdateRankInfo_GS();
	return 1;
end

function tbItem:NeedAdd_CardCollection()
	local nNeed = 1;
	for i = 1, tbEvent.MAX_CARD_NUM do
		local nTskId = tbEvent:GetCardTaskIdByIndex(i);
		if (me.GetTask(tbEvent.TASK_GROUP, nTskId) > 0) then
			nNeed = 0;
			break;
		end
	end
	
	local tbFind = me.FindItemInAllPosition(unpack(tbEvent.tbGDPL_CARDCOLLECTION));
	if (tbFind and #tbFind > 0) then
		nNeed = 0;
	end
	
	return nNeed;
end

-- 为玩家自动增加一个卡片收集册
function tbItem:AddCardCollection()
	local pItem = me.AddItem(18, 1, 657, 1);
	if (pItem) then
		pItem.Bind(1);
		me.SetItemTimeout(pItem, tbEvent.TIME_OUT_DATE_CARDCOLLECTION, 0);
	end
	return 1;
end

-- 判断是否是剑侠世界的特殊卡片
function tbItem:Is_JxsjCard(nLevel)
	-- 剑侠世界卡片的nLevel 是33
	if (not nLevel or nLevel ~= 33) then
		return 0;
	end
	
	return 1;
end

-- 使用剑侠世界卡片，返回一个其他卡片的nLevel
function tbItem:Use_JxsjCard()
	local tbUsefulIndex = self:Jxsj_GetUsefulIndex();
	local nUsefulIndex = MathRandom(1, #tbUsefulIndex);
	return tbUsefulIndex[nUsefulIndex];
end

-- 使用剑侠世界卡时，选择可以随机到的卡片列表
function tbItem:Jxsj_GetUsefulIndex()
	local tbRet = {};
	
	-- 尽可能给一个还没有收集到的卡片
	for i = 1, tbEvent.MAX_CARD_NUM do
		local nTskId = tbEvent:GetCardTaskIdByIndex(i);
		if (me.GetTask(tbEvent.TASK_GROUP, nTskId) == 0) then
			table.insert(tbRet, i);
		end
	end
	
	-- 如果所有卡片都有了，那么就从32张卡片当中随机给一个
	if (#tbRet == 0) then
		for i = 1, tbEvent.MAX_CARD_NUM do
			table.insert(tbRet, i);
		end
	end
	
	return tbRet;
end
