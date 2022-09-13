
IpStatistics = IpStatistics or {}
IpStatistics.nResultCycle = 24 		-- 24小时一个循环，每24小时为一个数据的更新循环，每次更新1个小时的数据
IpStatistics.nRecordedCycle = 24 	-- 24小时内登录的同一个角色不重复记录
IpStatistics.tbResultDataGroup = IpStatistics.tbResultDataGroup or {} -- 已经记录的登录信息列表（分组存储）
IpStatistics.tbRecordedDataGroup = IpStatistics.tbRecordedDataGroup or {} -- 已经记录的玩家列表（分组存储）
IpStatistics.tbRecorded = IpStatistics.tbRecorded or {} -- 在一段时间内已经记录过的角色的名字的列表
IpStatistics.tbResult = IpStatistics.tbResult or {} -- IP地址与登录角色数的对应表

function IpStatistics:DecreaseResultByGroup(tbGroup)
	if type(tbGroup) ~= "table" then
		return
	end

	for k, v in pairs(self.tbResult) do
		if tbGroup[k] then
			local nNewCount = v - tbGroup[k]
			if nNewCount <= 0 then
				nNewCount = nil
			end
			self.tbResult[k] = nNewCount
		end
	end

end

function IpStatistics:RecoredItem(dwIp, szName)
	if type(dwIp) ~= "number" or type(szName) ~= "string" then
		return
	end

	self.tbResult[dwIp] = (self.tbResult[dwIp] or 0) + 1
	self.tbRecorded[szName] = true
end

function IpStatistics:RemoveRecordedByGroup(tbGroup)
	if type(tbGroup) ~= "table" then
		return
	end

	for k, v in pairs(self.tbRecorded) do
		if tbGroup[k] then
			self.tbRecorded[k] = nil
		end
	end
end

function  IpStatistics:IsRecorded(szName)
	return self.tbRecorded[szName] == true
end

function IpStatistics:InitResult()
	for i = 1, self.nResultCycle do
		local v = self.tbResultDataGroup[i]
		if v then
			for k1, v1 in pairs(v) do
				self.tbResult[k1] = (self.tbResult[k1] or 0) + v1
			end
		end
	end
end

function IpStatistics:InitDataBuffer()
	local tbBuffer = GetGblIntBuf(GBLINTBUF_IP_STATISTICS, 0)
	if type(tbBuffer) == "table" then
		self.tbResultDataGroup = tbBuffer
		self:InitResult()
	else
		self.tbResultDataGroup = self.tbResultDataGroup or {}
		self.bToSaveDataBuffer = true
	end
end

function IpStatistics:RecoredCount(dwIp)
	local nIndex = self.tbResultDataGroup["Index"] or 1
	local tbGroup = self.tbResultDataGroup[nIndex]
	if not tbGroup then
		tbGroup = {}
		self.tbResultDataGroup[nIndex] = tbGroup
	end
	local nCount = tbGroup[dwIp] or 0
	nCount = nCount + 1
	tbGroup[dwIp] = nCount

	self.bToSaveDataBuffer = true
end

function IpStatistics:RecoredPlayer(szName)
	local nIndex = self.tbRecordedDataGroup["Index"] or 1
	local tbGroup = self.tbRecordedDataGroup[nIndex]
	if not tbGroup then
		tbGroup = {}
		self.tbRecordedDataGroup[nIndex] = tbGroup
	end
	tbGroup[szName] = true
end
