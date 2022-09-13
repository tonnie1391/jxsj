-- 文件名　：jiehunlihua.lua
-- 创建者　：furuilei
-- 创建时间：2009-12-23 09:51:41
-- 结婚道具：结婚礼花

local tbItem = Item:GetClass("marry_jiehunlihua");

--===================================================
tbItem.tbSkillId = {
	[1] = {szGDPL = "18-1-575-1", nLevel = 6},
	[2] = {szGDPL = "18-1-576-1", nLevel = 2},
	[3] = {szGDPL = "18-1-577-1", nLevel = 1},
	[4] = {szGDPL = "18-1-578-1", nLevel = 10},
	[5] = {szGDPL = "18-1-579-1", nLevel = 5},
	[6] = {szGDPL = "18-1-580-1", nLevel = 7},
	[7] = {szGDPL = "18-1-581-1", nLevel = 4},
	[8] = {szGDPL = "18-1-582-1", nLevel = 8},
	[9] = {szGDPL = "18-1-583-1", nLevel = 3},
	[10] = {szGDPL = "18-1-584-1", nLevel = 9},
	};
--===================================================

function tbItem:GetLihuaInfo(pItem)
	if (not pItem) then
		return nil;
	end
	local szGDPL = string.format("%s-%s-%s-%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel)
	for _, tbInfo in pairs(self.tbSkillId) do
		if (szGDPL == tbInfo.szGDPL) then
			return tbInfo;
		end
	end
	return nil;
end

function tbItem:OnUse()
	local tbInfo = self:GetLihuaInfo(it);
	if (not tbInfo) then
		return 0;
	end
	me.CastSkill(1528, tbInfo.nLevel, -1, me.GetNpc().nIndex);
	return 1;
end
