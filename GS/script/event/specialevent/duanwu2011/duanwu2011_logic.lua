-- 文件名　：duanwu2011_logic.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-05-17 09:46:10
-- 描  述  ：

Require("\\script\\event\\specialevent\\duanwu2011\\duanwu2011_def.lua");
SpecialEvent.DuanWu2011 = SpecialEvent.DuanWu2011 or {};
local tbDuanWu2011 = SpecialEvent.DuanWu2011 or {};

function tbDuanWu2011:LoadDataBuf()
	local tbData = GetGblIntBuf(GBLINTBUF_DUANWU2011, 0) or {};
	self.nDataVer = tbData.nDataVer or 0;	-- 数据版本
	self.tbTodayRank = tbData.tbTodayRank or {};-- 今日排名，记前200名家族
	self.tbYestodayRank = tbData.tbYestodayRank or {};-- 昨日排名，记前10名家族 
	self.tbAwardRecord = tbData.tbAwardRecord or {};	-- 领奖记录
	self.tbKinId2Rank = self:GenKinId2RankMap();
end

-- 生成家族id到排名的映射表，方便查找和排序
function tbDuanWu2011:GenKinId2RankMap()
	local tbMap = {};
	for nRank, tbTemp in ipairs(self.tbTodayRank) do
		tbMap[tbTemp[1]] = nRank;
	end
	return tbMap;
end

function tbDuanWu2011:AddMedalsPoint(nKinId, nPoint)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local nSaveFlag = 0;
	local nRank = self.tbKinId2Rank[nKinId];
	if nRank then
		self.tbTodayRank[nRank][2] = self.tbTodayRank[nRank][2] + nPoint;
		self.tbTodayRank[nRank][3] = GetTime();
		-- 只对前15进行排序，提高效率
		if nRank > self.MAX_VALID_RANK then
			if self.tbTodayRank[nRank][2] > self.tbTodayRank[self.MAX_VALID_RANK][2] then
				self:SwitchMedalsPoint(nRank, self.MAX_VALID_RANK);
				nRank = self.MAX_VALID_RANK;
			end
		end
		if nRank <= self.MAX_VALID_RANK and nRank > 1 then
			for i = 0, nRank-2 do
				local nCur = nRank - i; 
				if self.tbTodayRank[nCur][2] > self.tbTodayRank[nCur-1][2] then
					self:SwitchMedalsPoint(nCur, nCur-1);
					nSaveFlag = 1;
				end
			end
		end
	else -- 表里没有直接插在最后
		if #self.tbTodayRank >= self.MAX_KIN_MEDALS_RANK then
			return 0;
		end
		local tbTempData = {};
		tbTempData[1] = nKinId;
		tbTempData[2] = nPoint;
		tbTempData[3] = GetTime();
		table.insert(self.tbTodayRank, tbTempData);
		local nLastRank = #self.tbTodayRank;
		self.tbKinId2Rank[nKinId] = nLastRank;
		if nLastRank <= self.MAX_VALID_RANK then
			nSaveFlag = 1;
		end
	end 
	if MODULE_GC_SERVER then
		if nSaveFlag == 1 then -- 只有在前15名有变动的时候存盘一下
			self:SaveMedalsRank_GC();
		end
	end
end

function tbDuanWu2011:SwitchMedalsPoint(nRank1, nRank2)
	if not self.tbTodayRank[nRank1] or not self.tbTodayRank[nRank2] then
		print("tbDuanWu2011:SwitchMedalsPoint error", nRank1, nRank2);
		return 0;
	end
	local tbTemp = self.tbTodayRank[nRank2];
	local nKinId1 = self.tbTodayRank[nRank1][1];
	local nKinId2 = self.tbTodayRank[nRank2][1];
	self.tbTodayRank[nRank2] = self.tbTodayRank[nRank1];
	self.tbTodayRank[nRank1] = tbTemp;
	self.tbKinId2Rank[nKinId1] = nRank2;
	self.tbKinId2Rank[nKinId2] = nRank1;
	return 1;
end

-- 随机鱼
function tbDuanWu2011:RandFish(nType)
	nType = nType or 1;
	local nRand = MathRandom(1000);
	local nSum = 0;
	for i = 1, #self.TABLE_FISH_RAND[nType] do
		nSum = nSum + self.TABLE_FISH_RAND[nType][i];
		if nSum >= nRand then
			return i;
		end
	end
	return 1;
end

-- 随机勋章
function tbDuanWu2011:RandMedals()
	local nRand = MathRandom(100);
	if nRand <= self.MEDALS_RAND then
		return 1;
	end
	return 0;
end

-- 随机碎片
function tbDuanWu2011:RandFragment(nType)
	nType = nType or 2;
	local nRand = MathRandom(1000);
	if nRand <= self.BAWANGYU_FRAGMENT_RAND[nType] then
		return 1;
	end
	return 0;
end