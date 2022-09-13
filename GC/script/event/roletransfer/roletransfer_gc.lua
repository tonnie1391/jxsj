-- 文件名　：roletransfer_gc.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-07-21 09:40:39
-- 功能    ：

if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\event\\roletransfer\\roletransfer_def.lua");
SpecialEvent.tbRoleTransfer = SpecialEvent.tbRoleTransfer or {};
local tbRoleTransfer = SpecialEvent.tbRoleTransfer;

--转移数据
function tbRoleTransfer:SetBuffer(tbInfo)
	self.tbTransferDate[tbInfo[2]] = self.tbTransferDate[tbInfo[2]] or {};
	local nFlag = 0;
	for _, tb in pairs(self.tbTransferDate[tbInfo[2]]) do
		if tb[1] == tbInfo[1] and tb[2] == tbInfo[3] or tb[3] == tbInfo[4] then
			tb[4] = tbInfo[5];
			tb[5] = tbInfo[6];
			nFlag = 1;
		end
	end
	if nFlag == 0 then
		table.insert(self.tbTransferDate[tbInfo[2]], {tbInfo[1], tbInfo[3], tbInfo[4],tbInfo[5], tbInfo[6]});
	end
	--table.insert(self.tbTransferDate, tbInfo);
	GlobalExcute{"SpecialEvent.tbRoleTransfer:SetBuffer", tbInfo};
end

--同步数据
function tbRoleTransfer:SyncDate()
	GlobalExcute{"SpecialEvent.tbRoleTransfer:SyncDate", self.tbTransferDate or {}};
end


function tbRoleTransfer:CancleApply(szAccount, szName, dwItemId, nTime)
	for _, tb in pairs(self.tbTransferDate[szName] or {}) do
		if tb[1] == szAccount and tb[4] == nTime and tb[5] == 1 then
			tb[5] = 0;
			break;
		end
	end
	GlobalExcute{"SpecialEvent.tbRoleTransfer:CancleApplySuccess", szAccount, szName, dwItemId, nTime};
end

--转移成功
function tbRoleTransfer:TransferSuccess(szAccount, szName, nTime)
	for _, tb in pairs(self.tbTransferDate[szName] or {}) do
		if tb[2] == szAccount and tb[4] == nTime and tb[5] == 1 then
			tb[5] = 2;
			break;
		end
	end
	GlobalExcute{"SpecialEvent.tbRoleTransfer:TransferSuccess", szAccount, szName, nTime};
end

--loadbuff
function tbRoleTransfer:LoadBuffer_GC()
	local tbBuffer = GetGblIntBuf(GBLINTBUF_ROLE_TRANSFER, 0);	
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbTransferDate = tbBuffer;
	end
end

--定时写文件处理buff，存buff
function SpecialEvent:tbRoleTransfer_SaveBuffer()
	SpecialEvent.tbRoleTransfer:ReadAndWriteBuffer();
	SetGblIntBuf(GBLINTBUF_ROLE_TRANSFER, 0, 1, self.tbRoleTransfer.tbTransferDate);
	GlobalExcute{"SpecialEvent.tbRoleTransfer:LoadBuffer_GS"};
end

--关机只存buff
function tbRoleTransfer:SaveBuffer()
	SetGblIntBuf(GBLINTBUF_ROLE_TRANSFER, 0, 1, self.tbTransferDate);
end

--每天23:55存储buffer
function tbRoleTransfer:RegisterScheduleTask_GC()
	local nTaskId = KScheduleTask.AddTask("SpecialEvent", "SpecialEvent", "tbRoleTransfer_SaveBuffer");
	KScheduleTask.RegisterTimeTask(nTaskId, 0100, 1);
end

--ke读buffer并处理buffer
function tbRoleTransfer:ReadAndWriteBuffer()
	local szDate = os.date("%Y_%m_%d", GetTime());
	local szOutFile = "\\playerladder\\"..szDate.."\\"..GetGatewayName().."_roletransfer.txt";
	local nFlag = 0;
	if Lib:CountTB(self.tbTransferDate) <= 0 then
		return;
	end
	--KFile.AppendFile(szOutFile, "GATEWAY\tORG_ACCOUNT\tORG_ROLE\tNEW_ACCOUNT\tNEW_ROLE\tAPPLY_DATE\tAPPLY_TIME\tSTATE\n");
	KFile.WriteFile(szOutFile, "GATEWAY\tORG_ACCOUNT\tORG_ROLE\tNEW_ACCOUNT\tNEW_ROLE\tAPPLY_DATE\tAPPLY_TIME\tSTATE\n");
	for szName, tbEx in pairs(self.tbTransferDate) do
		for i, tb in pairs(tbEx) do
			nFlag = 0;
			if GetTime() - tb[4] > self.nMaxTransferDay and tb[5] ~= 2 then
				nFlag = 1;
			end
			local szMsg = GetGatewayName().."\t"..tb[1].."\t"..szName.."\t"..tb[2].."\t"..tb[3].."\t"..os.date("%Y%m%d",tb[4]).."\t"..os.date("%H%M%S",tb[4]).."\t".. tb[5].."\n";
			KFile.AppendFile(szOutFile, szMsg);
			--去掉时间已经超时的或者成功的
			if nFlag == 1 or tb[5] == 2 then
				self.tbTransferDate[szName][i] = nil;
			end
			if Lib:CountTB(self.tbTransferDate[szName]) <= 0 then
				self.tbTransferDate[szName] = nil;
			end
		end
	end
end

function tbRoleTransfer:BroadcastTransferFailData(szName, tbData)
	local tb = GetGblIntBuf(GBLINTBUF_CHANGEACOUNT_FAIL, 0) or {};
	tb[szName] = tbData;
	SetGblIntBuf(GBLINTBUF_CHANGEACOUNT_FAIL, 0, 1, tb);
	GlobalExcute{"SpecialEvent.tbRoleTransfer:OnSyncTransferFailData", szName, tbData};
end

function tbRoleTransfer:CoZoneUpdateTransferBuf(tbSubBuf)
	print("[GCEvent] tbRoleTransfer:CoZoneUpdateTransferBuf  start");
	self.tbTransferDate = {};
	local tbBuffer = GetGblIntBuf(GBLINTBUF_ROLE_TRANSFER, 0);	
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbTransferDate = tbBuffer;
	end	
	
	for szName, tbInfo in pairs(tbSubBuf) do
		print("[GCEvent] tbRoleTransfer:CoZoneUpdateTransferBuf ", szName);
		self.tbTransferDate[szName] = tbInfo;
	end
	
	SetGblIntBuf(GBLINTBUF_ROLE_TRANSFER, 0, 1, self.tbTransferDate);
	print("[GCEvent] tbRoleTransfer:CoZoneUpdateTransferBuf  end");
end

function tbRoleTransfer:CoZoneUpdateTransferFailedBuf(tbSubBuf)
	print("[GCEvent] tbRoleTransfer:CoZoneUpdateTransferFailedBuf  start");
	local tbBuffer = GetGblIntBuf(GBLINTBUF_CHANGEACOUNT_FAIL, 0) or {};
	
	for szName, tbInfo in pairs(tbSubBuf) do
		print("[GCEvent] tbRoleTransfer:CoZoneUpdateTransferFailedBuf ", szName);
		tbBuffer[szName] = tbInfo;
	end
	
	SetGblIntBuf(GBLINTBUF_CHANGEACOUNT_FAIL, 0, 1, tbBuffer);
	print("[GCEvent] tbRoleTransfer:CoZoneUpdateTransferFailedBuf  end");	
end


GCEvent:RegisterGCServerStartFunc(SpecialEvent.tbRoleTransfer.LoadBuffer_GC, SpecialEvent.tbRoleTransfer);
GCEvent:RegisterGCServerStartFunc(SpecialEvent.tbRoleTransfer.RegisterScheduleTask_GC, SpecialEvent.tbRoleTransfer);
GCEvent:RegisterGCServerShutDownFunc(SpecialEvent.tbRoleTransfer.SaveBuffer, SpecialEvent.tbRoleTransfer);
