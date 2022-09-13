-------------------------------------------------------
-- 文件名　: european_gc.lua
-- 创建者　: zhangjinpin@kingsoft
-- 创建时间: 2012-06-15 16:27:11
-- 文件描述: 
-------------------------------------------------------

if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\event\\jieri\\2012_european\\european_def.lua");

local tbEuropean = SpecialEvent.tbEuropean;
	
function tbEuropean:LoadBuffer_GC()
	local tbLoadBuffer = GetGblIntBuf(self.BUFFER_INDEX, 0);
	if tbLoadBuffer and type(tbLoadBuffer) == "table" then
		self.tbGlobalBuffer = tbLoadBuffer;
	end
end

function tbEuropean:SaveBuffer_GC()
	SetGblIntBuf(self.BUFFER_INDEX, 0, 1, self.tbGlobalBuffer);
	GlobalExcute({"SpecialEvent.tbEuropean:LoadBuffer_GS"});
end

function tbEuropean:ClearBuffer_GC()
	self.tbGlobalBuffer = {};
	SetGblIntBuf(self.BUFFER_INDEX, 0, 1, {});
	GlobalExcute({"SpecialEvent.tbEuropean:ClearBuffer_GS"});
end

function tbEuropean:SetBuffer(nSession, tbData)
	if not self.tbGlobalBuffer[nSession] then
		self.tbGlobalBuffer[nSession] = {};
	end
	for szKey, varValue in pairs(tbData or {}) do
		self.tbGlobalBuffer[nSession][szKey] = varValue;
	end
	self:SaveBuffer_GC();
end

function tbEuropean:SetSession(nSession)
	KGblTask.SCSetDbTaskInt(DBTASK_EUROPEEN_SESSION, nSession);
end

GCEvent:RegisterGCServerStartFunc(tbEuropean.LoadBuffer_GC, tbEuropean);
