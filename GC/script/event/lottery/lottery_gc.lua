Lottery.tbBufId2TblName = {
	[1] = "tbLottery",
	[2] = "tbAward",
	[3] = "tbGoldPlayerName",
	[4] = "tbGoldPlayerNameSubZone",
	};

function Lottery:SaveTable()
	local tb = {};
	for nBufId, szTblName in pairs(self.tbBufId2TblName) do
		tb[nBufId] = self[szTblName];
	end
	SetGblIntBuf(GBLINTBUF_LOTTERY_200908, 0, 0, tb);
end

function Lottery:OnGCStart()
	--print("Lottery:OnGCStart()")
	local tb = {};
	local tbBuf = GetGblIntBuf(GBLINTBUF_LOTTERY_200908, 0);
	if tbBuf and type(tbBuf)=="table"  then
		tb = tbBuf;
	end
	
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"))
	local nSec = Lib:GetDate2Time(self.LAST_LOTTERY_DATE) + self.AWARD_KEEP_DAY*24*3600;
	local nEndDate = tonumber(os.date("%Y%m%d", nSec));
	if nCurDate < self.FIRST_LOTTERY_DATE or nCurDate > nEndDate then
		tb = {};
	end
	
	for nBufId, szTblName in pairs(self.tbBufId2TblName) do
		self[szTblName] = tb[nBufId] or {};
	end
end

function Lottery:OnGCShutDown()
	--print("Lottery:OnGCShutDown()");
	self:SaveTable();
end

function Lottery:OnRecConnectEvent(nConnectId)
	GSExcute(nConnectId, {"Lottery:GSSynStart"});
	for nDate, tbAwardInDate in pairs(self.tbAward) do
		for szName, tbPlayerAward in pairs(tbAwardInDate) do
			for nAward, nAwardNum in pairs(tbPlayerAward) do
				GSExcute(nConnectId, {"Lottery:__AddAwardEntry", szName, nAward, nAwardNum, nDate});
			end
		end
	end
	
	GSExcute(nConnectId, {"Lottery:GSSynEnd"});
end

function Lottery:CoZoneUpdateLottery(tbSubBuf)
	print("[GCEvent] CoZoneUpdateLottery start");
	local tb = {};
	local tbBuf = GetGblIntBuf(GBLINTBUF_LOTTERY_200908, 0);
	if tbBuf and type(tbBuf)=="table"  then
		tb = tbBuf;
	end
	
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"))
	local nSec = Lib:GetDate2Time(self.LAST_LOTTERY_DATE) + self.AWARD_KEEP_DAY*24*3600;
	local nEndDate = tonumber(os.date("%Y%m%d", nSec));
	if nCurDate < self.FIRST_LOTTERY_DATE or nCurDate > nEndDate then
		tb = {};
	end
	
	for nBufId, szTblName in pairs(self.tbBufId2TblName) do
		self[szTblName] = tb[nBufId] or {};
	end
	
	for nBufId, szTblName in pairs(self.tbBufId2TblName) do
		local tbOneBuf = tbSubBuf[szTblName];
		if (tbOneBuf) then
			if (szTblName == "tbLottery") then
				for szName, nNum in pairs(tbOneBuf) do
					self[szTblName][szName] = nNum;
				end
			elseif (szTblName == "tbAward") then
				for nDate, tbInfo in pairs(tbOneBuf) do
					if (not self[szTblName][nDate]) then
						self[szTblName][nDate] = {};
					end
					
					for szName, tbAwardList in pairs(tbInfo) do
						self[szTblName][nDate][szName] = tbAwardList;
					end
				end
			elseif (szTblName == "tbGoldPlayerName") then
				self["tbGoldPlayerNameSubZone"] = tbOneBuf;
			end
		end
	end
	self:SaveTable();
	print("[GCEvent] CoZoneUpdateLottery end");
end

GCEvent:RegisterGCServerStartFunc(Lottery.OnGCStart, Lottery);
GCEvent:RegisterGCServerShutDownFunc(Lottery.OnGCShutDown, Lottery);

--?gc DoScript("\\script\\event\\lottery\\lottery_gc.lua")
