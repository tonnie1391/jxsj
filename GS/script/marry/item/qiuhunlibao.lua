-- 文件名　：qiuhunlibao.lua
-- 创建者　：furuilei
-- 创建时间：2009-11-28 14:00:09
-- 功能描述：求婚礼包
-- modify by zhangjinpin@kingsoft 2010-01-20

local tbItem = Item:GetClass("marry_qiuhunlibao");

--==============================================================
tbItem.tbItemInfo = {
--	[1] = {nCount = 2, tbGDPL = {18, 1, 571, 4}, szName = "亲爱的嫁给我吧"},
	[1] = {nCount = 2, tbGDPL = {18, 1, 571, 2}, szName = "爱相随"},
	[2] = {nCount = 2, tbGDPL = {18, 1, 571, 3}, szName = "你是唯一"},
	[3] = {nCount = 1, tbGDPL = {18, 1, 574, 1}, szName = "皇家礼炮"},
	[4] = {nCount = 1, tbGDPL = {18, 1, 573, 1}, szName = "地面花海"},
	[5] = {nCount = 1, tbGDPL = {18, 1, 572, 3}, szName = "纳吉誓言"},
	[6] = {nCount = 1, tbGDPL = {18, 1, 604, 1}, szName = "纳吉卡片"},
	};
--==============================================================

function tbItem:GetNeedBagCell()
	local nCount = 0;
	for _, tbInfo in pairs(self.tbItemInfo) do
		nCount = nCount + tbInfo.nCount;
	end
	return nCount;
end

function tbItem:OnUse()
	if (Marry:CheckState() == 0) then
		return 0;
	end
	local nFreeBagCell = me.CountFreeBagCell();
	local nNeedBagCell = self:GetNeedBagCell();
	if (nNeedBagCell > nFreeBagCell) then
		local szErrMsg = string.format("你的背包空间不足，请清理出<color=yellow>%s<color>个背包空间再来试试吧。",
			nNeedBagCell);
		Dialog:Say(szErrMsg);
		return 0;
	end

	self:GetItem();
	
	return 1;
end

function tbItem:GetItem()
	for _, tbInfo in pairs(self.tbItemInfo) do
		for i = 1, tbInfo.nCount do
			me.AddItem(unpack(tbInfo.tbGDPL));
		end
	end
end
