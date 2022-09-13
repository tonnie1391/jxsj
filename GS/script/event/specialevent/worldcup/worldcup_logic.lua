-- 文件名　：worldcup_logic.lua
-- 创建者　：furuilei
-- 创建时间：2010-05-18 15:56:59
-- 功能描述：gc，gs的buff中保存的数据

--==============================================
-- buff的table结构
--tbEvent.tbRankInfo = {
--	{tbCardInfo = {{1, 0, 2, ... , 3}, nValue = XXX, szName = "玩家一"},
--	{tbCardInfo = {{{1, 0, 2, ... , 3}, nValue = XXX, szName = "玩家一"},
--	...
--	-- 一共最多1500个
--	};
	
--==============================================

-- Require("\\script\\event\\specialevent\\worldcup\\worldcup_def.lua")

SpecialEvent.tbWroldCup = SpecialEvent.tbWroldCup or {};
local tbEvent = SpecialEvent.tbWroldCup;

tbEvent.bNeecReCalcValue = 0;

-- 更新排名
-- 参数表示新的排名记录，可以为nil，表示把原有的数据重新排名
-- 如果传入参数，就把把传入参数作为一个记录，并且排名
function tbEvent:UpdateRank(tbNewRecords)
	-- 如果需要，重新根据权重计算排名中玩家的总积分
	if (self.bNeecReCalcValue == 1) then
		self:ReCalcValue();
	end
	
	self:ReSort(tbNewRecords);
end

-- 重新根据各个卡片的权重计算总的积分
function tbEvent:ReCalcValue()
	if (not self.tbRankInfo) then
		return;
	end
	for _, tbInfo in pairs(self.tbRankInfo) do
		tbInfo.nValue = self:_CalcValue(tbInfo.tbCardInfo);
	end	
	self.bNeecReCalcValue = 0;
end

function tbEvent:_CalcValue(tbCardInfo)
	if (not tbCardInfo) then
		return 0;
	end
	
	local tbCardValue = self.tbCardValue;
	local nValue = 0;
	for i = 1, tbEvent.MAX_CARD_NUM do
		nValue = nValue + tbCardValue[i] * (tbCardInfo[i] or 0);
	end
	return nValue;
end

function tbEvent:AddNewRankRecord(tbNewRecords)
	if (not tbNewRecords) then
		return;
	end
	self.tbRankInfo = self.tbRankInfo or {};
	for _, tbNewRecord in pairs(tbNewRecords) do
		local bFind = 0;
		for _, tbInfo in pairs(self.tbRankInfo) do
			if (tbInfo.szName == tbNewRecord.szName) then
				bFind = 1;
				tbInfo.nValue = tbNewRecord.nValue;
				tbInfo.szName = tbNewRecord.szName;
				for i, v in ipairs(tbNewRecord.tbCardInfo) do
					tbInfo.tbCardInfo[i] = v;
				end
				break;
			end
		end
		if (0 == bFind) then
			table.insert(self.tbRankInfo, tbNewRecord);
		end
	end
end

function tbEvent:ReSort(tbNewRecords)
	if (not self.tbRankInfo) then
		self.tbRankInfo = {};
	end
	if (tbNewRecords) then
		self:AddNewRankRecord(tbNewRecords);
	end
	local _Sort = function(tbInfo1, tbInfo2)
		return tbInfo1.nValue > tbInfo2.nValue;
	end
	table.sort(self.tbRankInfo, _Sort);
	
	-- 超过1500名的玩家被挤掉
	if (#self.tbRankInfo > tbEvent.MAX_RANK_NUM) then
		for i = #self.tbRankInfo, tbEvent.MAX_RANK_NUM + 1, -1 do
			self.tbRankInfo[i] = nil;
		end
	end
end
