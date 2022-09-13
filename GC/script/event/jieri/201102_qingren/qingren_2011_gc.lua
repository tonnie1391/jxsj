-------------------------------------------------------
-- 文件名　：qingren_2011_gc.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-01-06 17:44:12
-- 文件描述：
-------------------------------------------------------

if not MODULE_GC_SERVER then
	return 0;
end

Require("\\script\\event\\jieri\\201102_qingren\\qingren_2011_def.lua");

local tbQingren_2011 = SpecialEvent.Qingren_2011;

function tbQingren_2011:LoadBuffer_GC()
	local tbBuffer = GetGblIntBuf(GBLINTBUF_QINGREN2011, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbBuffer = tbBuffer;
	end
end

function tbQingren_2011:SaveBuffer_GC()
	SetGblIntBuf(GBLINTBUF_QINGREN2011, 0, 1, self.tbBuffer);
	GlobalExcute({"SpecialEvent.Qingren_2011:LoadBuffer_GS"});
end

function tbQingren_2011:ClearBuffer_GC()
	self.tbBuffer = {};
	self:SaveBuffer_GC();
end

function tbQingren_2011:UpdateBuffer_GC(szPlayerName, nPoint)
	
	if not szPlayerName or not nPoint then
		return 0;
	end
	
	for nIndex, tbInfo in pairs(self.tbBuffer) do
		if tbInfo.szPlayerName == szPlayerName then
			table.remove(self.tbBuffer, nIndex);
		end
	end
	
	local nIns = 0;
	for i = 1, #self.tbBuffer do
		if self.tbBuffer[i].nPoint < nPoint then
			table.insert(self.tbBuffer, i, {szPlayerName = szPlayerName, nPoint = nPoint});
			nIns = i;
			break;
		end
	end
	
	if nIns == 0 then
		table.insert(self.tbBuffer, {szPlayerName = szPlayerName, nPoint = nPoint});
	end
	
	for i = self.MAX_BUFFER_LEN + 1, #self.tbBuffer do
		self.tbBuffer[i] = nil;
	end
	
	self:SaveBuffer_GC();
end

GCEvent:RegisterGCServerStartFunc(SpecialEvent.Qingren_2011.LoadBuffer_GC, SpecialEvent.Qingren_2011);
