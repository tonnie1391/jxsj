-- FileName	: lihuabao.lua
-- Author	: furuilei
-- Time		: 2010/1/30 0:54
-- Comment	: 结婚系统道具（礼花包）

local tbItem = Item:GetClass("marry_lihuabao");

--===========================================================

-- 礼花包里面包含的礼花的具体信息
tbItem.TB_LIHUA_INFO = {
	[1] = {tbGDPL = {18, 1, 575, 1}, nCount = 3},
	[2] = {tbGDPL = {18, 1, 576, 1}, nCount = 3},
	[3] = {tbGDPL = {18, 1, 577, 1}, nCount = 3},
	-- [4] = {tbGDPL = {18, 1, 578, 1}, nCount = 3},
	[4] = {tbGDPL = {18, 1, 579, 1}, nCount = 3},
	[5] = {tbGDPL = {18, 1, 580, 1}, nCount = 3},
	[6] = {tbGDPL = {18, 1, 581, 1}, nCount = 3},
	[7] = {tbGDPL = {18, 1, 582, 1}, nCount = 3},
	-- [9] = {tbGDPL = {18, 1, 583, 1}, nCount = 3},
	[8] = {tbGDPL = {18, 1, 584, 1}, nCount = 3},
	};

--===========================================================

function tbItem:OnUse()
	local nFreeBagCell = me.CountFreeBagCell();
	local nNeedCount = #self.TB_LIHUA_INFO;
	if (nFreeBagCell < nNeedCount) then
		Dialog:Say(string.format("你的包裹空间不足，还是清理出<color=yellow>%s<color>个背包空间再来吧。", nNeedCount));
		return 0;
	end
	
	for _, tbInfo in ipairs(self.TB_LIHUA_INFO) do
		me.AddStackItem(tbInfo.tbGDPL[1], tbInfo.tbGDPL[2], tbInfo.tbGDPL[3], tbInfo.tbGDPL[4],
			{bForceBind = 1}, tbInfo.nCount);
	end
	
	return 1;
end
