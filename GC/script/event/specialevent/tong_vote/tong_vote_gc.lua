-- 文件名　：Tong_Vote_gc.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-06-04 17:49:23
-- 描  述  ：

if (not MODULE_GC_SERVER) or GLOBAL_AGENT then
	return 0;
end

Require("\\script\\event\\specialevent\\tong_vote\\tong_vote_def.lua");
SpecialEvent.Tong_Vote = SpecialEvent.Tong_Vote or {};
local tbTong = SpecialEvent.Tong_Vote;

function tbTong:IsOpen()
	if self.IVER_OPEN == 0 then
		return 0;
	end
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate < self.TIME_START or nDate > self.TIME_END then
		return 0;
	end
	return 1;
end

function tbTong:StartEvent()
	if self:IsOpen() ~= 1 then
		return;
	end	
	self.tbGblBuf = {};
	local tbBuf = GetGblIntBuf(GBLINTBUF_Tong_Vote201105, 0);
	if tbBuf and type(tbBuf)=="table"  then
		self.tbGblBuf = tbBuf;
	end
end


local function OnSort(tbA, tbB)
	return tbA[2] > tbB[2];
end

function tbTong:RankAndWriteFile()
	if not self.tbGblBuf then
		return;
	end
	local tbBuf = self:GetGblBuf();
	SetGblIntBuf(GBLINTBUF_Tong_Vote201105, 0, 1, tbBuf);
	--PlayerHonor:OnSchemeUpdatePrettygirlHonorLadder();
	local tbRank = {};
	for szTongName,tbInfo in pairs(tbBuf) do
		table.insert(tbRank, {szTongName,tbInfo.nTickets});	
	end
	table.sort(tbRank,OnSort);	
	local szGateway	= GetGatewayName();
	local szOutFile = "\\playerladder\\tongvotehonor_" .. szGateway .. ".txt";
	local szContext = "Rank\tTong\tTickets\tGatewayId\n";
	KFile.WriteFile(szOutFile, szContext);
	for nId, tbInfo in ipairs(tbRank) do
		local szOut = string.format("%s\t%s\t%s\t%s\n",
			nId,
			tbInfo[1],
			tbInfo[2],		
			szGateway);
		KFile.AppendFile(szOutFile, szOut);	
	end
end

function tbTong:GetGblBuf()
	return self.tbGblBuf or {};
end

function tbTong:SetGblBuf(tbBuf)
	self.tbGblBuf = tbBuf;
end

function tbTong:BufVoteTicket(szName, nTickets, szPlayerName)
	local tbBuf = self:GetGblBuf();
	tbBuf[szName] = tbBuf[szName] or {};
	tbBuf[szName].nTickets = (tbBuf[szName].nTickets or 0) + nTickets;
	self:SetGblBuf(tbBuf);
	GlobalExcute({"SpecialEvent.Tong_Vote:OnRecConnectMsg", szName, tbBuf[szName]});
	Dbg:WriteLog("SpecialEvent.Girl_Vote", szPlayerName.."投了"..nTickets.."票给"..szName);
end

function tbTong:OnRecConnectEvent(nConnectId)
	if self:IsOpen() ~= 1 then
		return;
	end
	if self.tbGblBuf then
		for szName, tbInfo in pairs(self.tbGblBuf) do
			GSExcute(nConnectId, {"SpecialEvent.Tong_Vote:OnRecConnectMsg", szName, tbInfo});
		end
	end
end

if tbTong.IVER_OPEN == 1 then
GCEvent:RegisterGCServerStartFunc(SpecialEvent.Tong_Vote.StartEvent, SpecialEvent.Tong_Vote);
GCEvent:RegisterGCServerShutDownFunc(SpecialEvent.Tong_Vote.RankAndWriteFile, SpecialEvent.Tong_Vote);
GCEvent:RegisterGS2GCServerStartFunc(SpecialEvent.Tong_Vote.OnRecConnectEvent,SpecialEvent.Tong_Vote);
end
