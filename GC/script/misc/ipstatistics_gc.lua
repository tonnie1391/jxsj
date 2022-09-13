
if not MODULE_GC_SERVER then
	return;
end
Require("\\script\\misc\\ipstatistics_base.lua")
Require("\\script\\misc\\gcevent.lua")

IpStatistics.nTimerFrequence = 5 * Env.GAME_FPS -- 多长时间检查下是否有数据需要更新或者保存
IpStatistics.bToSaveDataBuffer = false			-- 是否要保存数据

function IpStatistics:ChangeTimerFraequence(nNewFrequence)
	if type(nNewFrequence) ~= "number" or nNewFrequence <= 0 then
		return
	end

	if nNewFrequence == self.nTimerFrequence then
		return
	end

	if self.nTimerId then
		Timer:Close(self.nTimerId)
		self.nTimerId = nil
	end

	self.nTimerFrequence = nNewFrequence
	self.nTimerId = Timer:Register(self.nTimerFrequence, self.OnTimer, self)
end

function IpStatistics:ClearData()
	self.tbRecordedDataGroup = {}
	self.tbRecorded = {}
	self.tbResultDataGroup = {}
	self.tbResult = {}

	SetGblIntBuf(GBLINTBUF_IP_STATISTICS, 0, 1, self.tbResultDataGroup)

	GlobalExcute({"IpStatistics:ClearData"})
end

function IpStatistics:OnTimer()
	self:TryUpdateResultDataGroup()
	self:TryUpdateRecordedDataGroup()
	self:SaveDataBuffer()
end


function IpStatistics:TryUpdateResultDataGroup()
	local nTimeStamp = self.tbResultDataGroup["TimeStamp"] or 0
	local nNowTime = tonumber(GetLocalDate("%m%d%H"))

	if nTimeStamp == 0 then
		self.tbResultDataGroup["TimeStamp"] = nNowTime
		self.tbResultDataGroup["Index"] = 1
		self.bToSaveDataBuffer = true
		return
	end

	if nNowTime == nTimeStamp then
		return
	end

	self.tbResultDataGroup["TimeStamp"] = nNowTime
	local nIndex = math.fmod(self.tbResultDataGroup["Index"] + 1, self.nResultCycle + 1)
	if nIndex == 0 then nIndex = 1 end
	self.tbResultDataGroup["Index"] = nIndex
	local tbGroup = self.tbResultDataGroup[nIndex]
	self.tbResultDataGroup[nIndex] = {}

	self.bToSaveDataBuffer = true

	self:DecreaseResultByGroup(tbGroup)

	GlobalExcute({"IpStatistics:DecreaseResultByGroupIndex", nIndex})
end

function IpStatistics:TryUpdateRecordedDataGroup()
	local nTimeStamp = self.tbRecordedDataGroup["TimeStamp"] or 0
	local nNowTime = tonumber(GetLocalDate("%m%d%H"))
	if nTimeStamp == 0 then
		self.tbRecordedDataGroup["TimeStamp"] = nNowTime
		self.tbRecordedDataGroup["Index"] = 1
		return
	end

	if nNowTime == nTimeStamp then
		return
	end

	self.tbRecordedDataGroup["TimeStamp"] = nNowTime
	local nIndex = math.fmod(self.tbRecordedDataGroup["Index"] + 1, self.nRecordedCycle + 1)
	if nIndex == 0 then nIndex = 1 end
	self.tbRecordedDataGroup["Index"] = nIndex
	local tbGroup = self.tbRecordedDataGroup[nIndex]
	self.tbRecordedDataGroup[nIndex] = {}

	self:RemoveRecordedByGroup(tbGroup)
	GlobalExcute({"IpStatistics:RemoveRecordedByGroupIndex", nIndex})
end


function IpStatistics:SaveDataBuffer()
	if self.bToSaveDataBuffer then
		SetGblIntBuf(GBLINTBUF_IP_STATISTICS, 0, 1, self.tbResultDataGroup)
		self.bToSaveDataBuffer = false
	end
end

function IpStatistics:OnLogin(dwIp, szName)
	if type(dwIp) ~= "number" or type(szName) ~= "string" then
		return
	end

	if self:IsRecorded(szName) then
		return
	end

	self:RecoredCount(dwIp)
	self:RecoredPlayer(szName)

	self:RecoredItem(dwIp, szName)

	GlobalExcute({"IpStatistics:OnLoginCallbackFromGC", dwIp, szName})
end


function IpStatistics:OnGCStart()
	self:InitDataBuffer()
	self.nTimerId = Timer:Register(self.nTimerFrequence, self.OnTimer, self)
end

if not IpStatistics.bEventRegistered then
	GCEvent:RegisterGCServerStartFunc(IpStatistics.OnGCStart, IpStatistics)
	IpStatistics.bEventRegistered = true
end


