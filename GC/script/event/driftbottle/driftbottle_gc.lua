-------------------------------------------------------
-- 文件名　：driftbottle_gc.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-11-30 15:16:50
-- 文件描述：
-------------------------------------------------------

if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\event\\driftbottle\\driftbottle_def.lua");

-- 载入本地global buffer
function DriftBottle:LoadBuffer_GC()
	for nIndex, tbInfo in pairs(self.BUFFER_LIST) do
		local tbLoadBuffer = GetGblIntBuf(tbInfo.nIndex, 0);
		if tbLoadBuffer and type(tbLoadBuffer) == "table" then
			self[tbInfo.szBuffer] = tbLoadBuffer;
		end
	end
end

-- 存储本地global buffer
function DriftBottle:SaveBuffer_GC()
	for nIndex, tbInfo in pairs(self.BUFFER_LIST) do
		SetGblIntBuf(tbInfo.nIndex, 0, 1, self[tbInfo.szBuffer]);
	end
	GlobalExcute({"DriftBottle:LoadBuffer_GS"});
end

-- 清空本地global buffer
function DriftBottle:ClearBuffer_GC()
	for nIndex, tbInfo in pairs(self.BUFFER_LIST) do
		self[tbInfo.szBuffer] = {};
		SetGblIntBuf(tbInfo.nIndex, 0, 1, {});
	end
	GlobalExcute({"DriftBottle:ClearBuffer_GS"});
end

-- gc增加新帖子
function DriftBottle:AddNewMsg_GC(szPlayerName, szMsg)
	local nCount, nFree = self:CalcBufferLength();
	local tbBuffer = self:GetBufferByIndex(nFree);
	if tbBuffer then
		tbBuffer[nCount + 1] = {szType = "player", szWritter = szPlayerName, szHead = szMsg, tbReply = {}};
		self:SaveBuffer_GC();
	end
end

-- gc摘取帖子
function DriftBottle:PickMsg_GC(szPlayerName)
	
	local nFlag = 0;
	local nCount, nFree = self:CalcBufferLength();
	
	if nCount > 0 then
		local nRand = MathRandom(1, nCount);
		local tbInfo = self:GetInfoByIndex(nRand);
		while not tbInfo or tbInfo.szOwner do
			nFlag = nFlag + 1;
			nRand = MathRandom(1, nCount);
			tbInfo = self:GetInfoByIndex(nRand);
			if nFlag >= 100 then
				nRand = 0;
				break;
			end
		end
		if nRand > 0 then
			tbInfo.szOwner = szPlayerName;
			tbInfo.nTimerId = Timer:Register(600 * Env.GAME_FPS, self.AutoUnlock, self, nRand);
			GlobalExcute({"DriftBottle:PickMsgSuccess_GS", szPlayerName, nRand});
			self:SaveBuffer_GC();
		else
			GlobalExcute({"DriftBottle:PickMsgFailed_GS", szPlayerName});
		end
	else
		GlobalExcute({"DriftBottle:PickMsgFailed_GS", szPlayerName});
	end
end

-- 自动解锁
function DriftBottle:AutoUnlock(nIndex)
	local tbInfo = self:GetInfoByIndex(nIndex);
	if tbInfo then
		tbInfo.szOwner = nil;
		tbInfo.nTimerId = nil;
		self:SaveBuffer_GC();
	end
	return 0;
end

-- gc回复帖子
function DriftBottle:ReplyMsg_GC(szPlayerName, nIndex, szMsg)
	local tbInfo = self:GetInfoByIndex(nIndex);
	if not tbInfo or #tbInfo.tbReply >= self.MAX_REPLY_TIMES then
		GlobalExcute({"DriftBottle:ReplyMsgFailed_GS", szPlayerName});
		return 0;
	end
	table.insert(tbInfo.tbReply, szMsg);
	tbInfo.szOwner = nil;
	self:SaveBuffer_GC();
	GlobalExcute({"DriftBottle:ReplyMsgSuccess_GS", szPlayerName, nIndex});
end

-- gc放回帖子
function DriftBottle:ReturnMsg_GC(szPlayerName, nIndex)
	local tbInfo = self:GetInfoByIndex(nIndex);
	if not tbInfo then
		return 0;
	end
	tbInfo.szOwner = nil;
	if tbInfo.nTimerId and tbInfo.nTimerId > 0 then
		Timer:Close(tbInfo.nTimerId);
		tbInfo.nTimerId = nil;
	end
	self:SaveBuffer_GC();
end

-- 读取系统消息列表
function DriftBottle:LoadSystemMsg()
	local tbSystemMsg = {};
	local tbFile = Lib:LoadTabFile(self.SYSTEM_MSG_PATH);
	for _, tbRow in pairs(tbFile or {}) do
		local nIndex = tonumber(tbRow.Index);
		local szMsg = tostring(tbRow.Msg);
		tbSystemMsg[nIndex] = szMsg;
	end
	self.tbSystemMsg = tbSystemMsg;
end

-- gc启动事件
function DriftBottle:StartEvent_GC()
			
	self:LoadBuffer_GC();
	self:LoadSystemMsg();
	
	local nLength = self:CalcBufferLength();
	if nLength < self.SYSTEM_MSG_COUNT then
		self:ClearBuffer_GC();
		Lib:SmashTable(self.tbSystemMsg);
		for i = 1, self.SYSTEM_MSG_COUNT do
			if self.tbSystemMsg[i] then
				local nCount, nFree = self:CalcBufferLength();
				local tbBuffer = self:GetBufferByIndex(nFree);
				if tbBuffer then
					tbBuffer[nCount + 1] = {szType = "system", szWritter = "system", szHead = self.tbSystemMsg[i], tbReply = {}};
					self:SaveBuffer_GC();
				end
			end
		end
		self:SaveBuffer_GC();
	end
	self:_ClearLock();
	
	--local nTaskId = KScheduleTask.AddTask("许愿树每日事件", "DriftBottle", "TaskDailyEvent");
	--KScheduleTask.RegisterTimeTask(nTaskId, 0005, 1);
end

function DriftBottle:TaskDailyEvent()
	GlobalExcute({"DriftBottle:RefreshTree"});
end

-- gameserver连接时同步
function DriftBottle:OnRecConnectEvent_GC(nConnectId)
	for nIndex, tbInfo in pairs(self.BUFFER_LIST) do
		for nKey, tbValue in pairs(self[tbInfo.szBuffer]) do
			GSExcute(nConnectId, {"DriftBottle:SyncBuffer_GS", tbInfo.szBuffer, nKey, tbValue});
		end
	end
end

-- 注册启动事件
GCEvent:RegisterGCServerStartFunc(DriftBottle.StartEvent_GC, DriftBottle);
GCEvent:RegisterGS2GCServerStartFunc(DriftBottle.OnRecConnectEvent_GC, DriftBottle);

-- 测试指令
function DriftBottle:_ClearLock()
	for nIndex, tbInfo in pairs(self.BUFFER_LIST) do
		for nKey, tbValue in pairs(self[tbInfo.szBuffer]) do
			tbValue.szOwner = nil;
			if tbValue.nTimerId and tbValue.nTimerId > 0 then
				Timer:Close(tbValue.nTimerId);
				tbValue.nTimerId = nil;
			end
		end
	end
	self:SaveBuffer_GC();
end

