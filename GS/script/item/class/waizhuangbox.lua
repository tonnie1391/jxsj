-- 文件名　：waizhuangbox.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-01-06 17:09:17
-- 功能    ：外装盒子
-- 扩展参数填具体男女的物品，和时间，没个物品只支持单个，不支持多个
--单数为女号物品，双数为男号物品

local tbItem = Item:GetClass("waizhuangbox")

function tbItem:OnUse()
	local tbAward = {
		[1] = {1, 26, 45, 1, 23040},
		[2] = {1, 26, 44, 1, 23040},
		[3] = {1, 25, 43, 1, 23040},
		[4] = {1, 25, 42, 1, 23040},
		};
	local tbList = {};
	local nMaxMenCount = 0;
	local nMaxWoMenCount = 0;
	for i =1, 10 do
		local nNum = tonumber(it.GetExtParam(i));
		if nNum > 0 and tbAward[i] then
			if math.fmod(i,2) == 0 then
				tbList[0] = tbList[0] or {};
				table.insert(tbList[0], tbAward[i]);
			else
				tbList[1] = tbList[1] or {};
				table.insert(tbList[1], tbAward[i]);
			end
		end
	end
	local nMaxCount = #tbList[0];
	if me.nSex == 1 then
		nMaxCount = #tbList[1];
	end
	if nMaxCount <= 0 then
		Dialog:Say("道具存在问题。");
		return 0;
	end
	if me.CountFreeBagCell() < nMaxCount then
		Dialog:Say(string.format("领奖需要%s格背包空间，去整理下再来吧！", nMaxCount));
		return 0;
	end
	for _, tbItem in ipairs(tbList[me.nSex]) do
		local pItem = me.AddItem(tbItem[1], tbItem[2], tbItem[3], tbItem[4]);
		if pItem and tbItem[5] > 0 then
			me.SetItemTimeout(pItem, tbItem[5], 0);
		end
	end
	return 1;
end
