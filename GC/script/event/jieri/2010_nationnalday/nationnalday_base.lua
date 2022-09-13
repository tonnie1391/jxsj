--=================================================
-- 文件名　：nationnalday_base.lua
-- 创建者　：furuilei
-- 创建时间：2010-08-23 10:27:05
-- 功能描述：2010年国庆节活动
--=================================================

Require("\\script\\event\\jieri\\2010_nationnalday\\nationnalday_def.lua")
SpecialEvent.tbNationnalDay = SpecialEvent.tbNationnalDay or {};
local tbEvent = SpecialEvent.tbNationnalDay or {};

tbEvent.szFilePath = "\\setting\\event\\jieri\\2010_nationnalday\\areainfo.txt";

function tbEvent:LoadAreaInfo()
	self.tbAreaInfo = self.tbAreaInfo or {};
	local tbSetting = Lib:LoadTabFile(self.szFilePath);
	for _, tbRowData in pairs(tbSetting or {}) do
		local tbTemp = {};
		tbTemp.nIndex		= tonumber(tbRowData["nIndex"]) or 0;
		tbTemp.szName		= tostring(tbRowData["szName"]) or "";
		tbTemp.szShortName	= tostring(tbRowData["szShortName"]) or "";
		tbTemp.szDesc		= tostring(tbRowData["szDesc"]) or "";
		table.insert(self.tbAreaInfo, tbTemp);
	end
end
tbEvent:LoadAreaInfo();

function tbEvent:GetAreaInfo(nIndex)
	if (not nIndex or nIndex <= 0) then
		return;
	end
	for _, tbInfo in pairs(self.tbAreaInfo or {}) do
		if (tbInfo.nIndex == nIndex) then
			return tbInfo;
		end
	end
end

--=============================================

function tbEvent:CheckOpenFlag()
	local nCurState = self.STATE_CLOSE;
	local nCurDate = tonumber(os.date("%Y%m%d", GetTime()));
	if (nCurDate >= self.TIME_OPEN and nCurDate < self.TIME_CLOSE) then
		nCurState = self.STATE_OPEN;
	elseif (nCurDate >= self.TIME_CLOSE and nCurDate <= self.TIME_AWARD) then	
		nCurState = self.STATE_AWARD;
	end
	
	return nCurState;
end

--=============================================

-- 获取已经收集到的地域的数量
function tbEvent:GetCollectNum()
	local nNum = 0;
	for i = 1, self.COUNT_AREA do
		if (self:GetAchieveFlag(i) == 1) then
			nNum = nNum + 1;
		end
	end
	return nNum;
end

-- 获取已经使用的卡片的数量
function tbEvent:GetUseCardNum()
	return me.GetTask(self.TSK_GROUP, self.TSKID_COUNT_SUM);
end

--=============================================

-- 根据index计算出表示该信息的是第几个bit
function tbEvent:GetBitIndex(nIndex)
	if (not nIndex or nIndex <= 0) then
		return 0;
	end
	return 32 * (self.TSKID_FLAG_BEGIN - 1) + nIndex;
end

-- 获取是否获取了某一个信息的标志位信息
-- 参数表示的是第几个bit
function tbEvent:GetAchieveFlag(nIndex)
	if (not nIndex or nIndex <= 0 or nIndex > self.COUNT_AREA) then
		return;
	end
	local nBitIndex = self:GetBitIndex(nIndex);
	if (not nBitIndex or nBitIndex <= 0) then
		return;
	end
	return me.GetTaskBit(self.TSK_GROUP, nBitIndex);
end

-- 设置某个bit为nFlag
function tbEvent:SetAchiveFlag(nIndex, nFlag)
	if (not nIndex or nIndex <= 0 or nIndex > self.COUNT_AREA or
		not nFlag or (nFlag ~= 0 and nFlag ~= 1)) then
		return;
	end
	local nBitIndex = self:GetBitIndex(nIndex);
	if (not nBitIndex or nBitIndex <= 0) then
		return;
	end
	return me.SetTaskBit(self.TSK_GROUP, nBitIndex, nFlag);
end

--=============================================

function tbEvent:GetSpeArea_FromGblTask()
	self.tbSpeArea = {};
	local nSpeAreaIndex = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_2010_NATIONNAL);
	if (nSpeAreaIndex and 0 ~= nSpeAreaIndex) then
		local nIndex1 = Lib:LoadBits(nSpeAreaIndex, 0, 15);
		local nIndex2 = Lib:LoadBits(nSpeAreaIndex, 16, 31);
		table.insert(self.tbSpeArea, nIndex1);
		table.insert(self.tbSpeArea, nIndex2);
	end
end

function tbEvent:SetSpeArea_2GblTask(tbSpeArea)
	local nSpeAreaIndex = 0;
	if (tbSpeArea and #tbSpeArea == 2) then
		local nIndex1 = self.tbSpeArea[1] or 0;
		local nIndex2 = self.tbSpeArea[2] or 0;
		nSpeAreaIndex = Lib:SetBits(nSpeAreaIndex, nIndex1, 0, 15);
		nSpeAreaIndex = Lib:SetBits(nSpeAreaIndex, nIndex2, 16, 31);
	end
	KGblTask.SCSetDbTaskInt(DBTASD_EVENT_2010_NATIONNAL, nSpeAreaIndex)
end
