-- 文件名  : SeventhEvening_gc.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-07-08 15:44:53
-- 描述    : 
if not MODULE_GC_SERVER then
	return;
end
Require("\\script\\event\\jieri\\201008_SeventhEvening\\SeventhEvening_def.lua");

SpecialEvent.SeventhEvening = SpecialEvent.SeventhEvening or {};
local SeventhEvening = SpecialEvent.SeventhEvening or {};

function SpecialEvent:SeventhEvening_AddNpc()
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData >= SeventhEvening.OpenTime and nData <= 20100907 then	--活动期间内		
		GlobalExcute{"SpecialEvent.SeventhEvening.AddNpc"};
	end
end

function SeventhEvening:LoadBuffer_GC()
	local tbBuffer = GetGblIntBuf(GBLINTBUF_QIXI_XIALV, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbXialvBuffer = tbBuffer;
	end
end

function SeventhEvening:SaveBuffer_GC()
	SetGblIntBuf(GBLINTBUF_QIXI_XIALV, 0, 1, self.tbXialvBuffer);
	GlobalExcute({"SpecialEvent.SeventhEvening:LoadBuffer_GS"});
end

function SeventhEvening:ClearBuffer_GC()
	self.tbXialvBuffer = {};
	self:SaveBuffer_GC();
end

function SeventhEvening:UpdateBuffer_GC(szMaleName, szFemaleName, nPoint)
	
	if not szMaleName or not szFemaleName or not nPoint then
		return 0;
	end
	
	for nIndex, tbInfo in pairs(self.tbXialvBuffer) do
		if tbInfo.szMaleName == szMaleName and tbInfo.szFemaleName == szFemaleName then
			table.remove(self.tbXialvBuffer, nIndex);
		end
	end
	
	local nIns = 0;
	for i = 1, #self.tbXialvBuffer do
		if self.tbXialvBuffer[i].nPoint < nPoint then
			table.insert(self.tbXialvBuffer, i, {szMaleName = szMaleName, szFemaleName = szFemaleName, nPoint = nPoint});
			nIns = i;
			break;
		end
	end
	
	if nIns == 0 then
		table.insert(self.tbXialvBuffer, {szMaleName = szMaleName, szFemaleName = szFemaleName, nPoint = nPoint});
	end
	
	for i = self.MAX_BUFFER_LEN + 1, #self.tbXialvBuffer do
		self.tbXialvBuffer[i] = nil;
	end
	
	self:SaveBuffer_GC();
end

-- 合服操作
function SeventhEvening:CombineMainZoneAndSubZone(tbSubBuf)
	SetGblIntBuf(GBLINTBUF_QIXI_XIALV_HEFU, 0, 0, tbSubBuf);
end

GCEvent:RegisterGCServerStartFunc(SpecialEvent.SeventhEvening.LoadBuffer_GC, SpecialEvent.SeventhEvening);
