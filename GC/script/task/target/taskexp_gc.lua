-- 文件名  : taskexp_gc.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-07-27 16:36:51
-- 描述    : 

if not MODULE_GC_SERVER then
	return;
end

Task.TaskExp = Task.TaskExp or {};
local tbTaskExp = Task.TaskExp;

function tbTaskExp:SeverStart()
	for i = 1, #self.tbItem do
		self.tbTaskTemp[i] = DataForm_GetData(i);
		self.tbTask[i] = self.tbTask[i] or {};
		self:MakeTable(i)
		for j, tbTaskEx in pairs(self.tbTask[i]) do
			self:OnTimer(i, j, tbTaskEx[3]);
		end
	end
end

--撤掉所有单
function tbTaskExp:CancelAllTask()
	for nFormId , tbTaskEx in pairs (self.tbTask) do
		for nIndex,  tbTaskEx1 in pairs(tbTaskEx) do
			local nCoin = self:CalculateAword(nFormId, nIndex);
			local szPlayerName = tbTaskEx1.szBuf;
			local nKey = nFormId + nIndex * self.nItemCount;
			if self.tbTaskTimer[nKey] and self.tbTaskTimer[nKey] > 0 then
				Timer:Close(self.tbTaskTimer[nKey]);
				self.tbTaskTimer[nKey] = nil;
			end
			if self.tbTaskLockTimer[nKey] and self.tbTaskLockTimer[nKey] > 0 then
				Timer:Close(self.tbTaskLockTimer[nKey]);
				self.tbTaskLockTimer[nKey] = nil;
			end		
			DataForm_Delete(nFormId, nIndex);
			if nCoin > 0 then
				if self.tbCheXiaoBuffer[szPlayerName] then
					self.tbCheXiaoBuffer[szPlayerName] = self.tbCheXiaoBuffer[szPlayerName] + nCoin;
				else
					self.tbCheXiaoBuffer[szPlayerName] = nCoin;
				end
			end
		end
		self.tbTask[nFormId] = {};
	end
	self:SaveBuffer_GC();
end

--整理分类表，用C内存中的Index做lua中的
function tbTaskExp:MakeTable(nIndex)
	for _,tbTaskExp in ipairs(self.tbTaskTemp[nIndex]) do
		if tbTaskExp.nIndex > 0 then
			self.tbTask[nIndex][tbTaskExp.nIndex] = {[1] = tbTaskExp[0], [2] = tbTaskExp[1], [3] = tbTaskExp[2], szBuf = tbTaskExp.szBuf};
		end
	end
end

function tbTaskExp:OnTimer(nFormId, nIndex, nFabuTime)
	local nKey = nFormId + nIndex * self.nItemCount;
	local nTime = GetTime() - nFabuTime;
	if nTime  >= self.nTimeFabu * 3600 then		
		self:AutoCanCelTask(nFormId, nIndex);
	else		
		self.tbTaskTimer[nKey] = Timer:Register((self.nTimeFabu * 3600 - nTime) * Env.GAME_FPS, self.AutoCanCelTask, self, nFormId, nIndex);
	end	
end

--完成任务回调
function tbTaskExp:FinishTask_GC(nFormId, nIndex, szPlayerName)
	if not self.tbTask[nFormId] or not self.tbTask[nFormId][nIndex] or not self.tbItem[nFormId] then
		return 0;
	end	
	--发邮件给玩家，获得收购的物品
	GlobalExcute({"Task.TaskExp:SendMail2Player",nFormId, self.tbTask[nFormId][nIndex][1], self.tbTask[nFormId][nIndex].szBuf});
	
	--delete
	DataForm_Delete(nFormId, nIndex);
	self.tbTask[nFormId][nIndex] = nil;
	
	local nKey = nFormId  + nIndex * self.nItemCount;
	--关闭任务倒计时Timer
	if self.tbTaskTimer[nKey] and self.tbTaskTimer[nKey] > 0 then
		Timer:Close(self.tbTaskTimer[nKey]);
		self.tbTaskTimer[nKey] = nil;
	end
	
	--关闭锁定倒计时Timer
	if self.tbTaskLockTimer[nKey] and self.tbTaskLockTimer[nKey] > 0 then
		Timer:Close(self.tbTaskLockTimer[nKey]);
		self.tbTaskLockTimer[nKey] = nil;
	end
	
	--解除锁定
	if self.tbTaskLock[nFormId] and self.tbTaskLock[nFormId][nIndex] then
		self.tbTaskLock[nFormId][nIndex] = 1;
	end
	--Dbg:WriteLog("ExpTask","完成任务", string.format("玩家%s完成了%s发布的任务，缴纳了%s个%s", szPlayerName, self.tbTask[nIndex][nIndex].szBuf, self.tbTask[nIndex][nIndex][1],self.tbItem[nFormId][2]))
	return 1;
end

--锁定任务
function tbTaskExp:LockTask_GC(nFormId, nIndex, szPlayerName)	
	if (not self.tbTaskLock[nFormId] or not self.tbTaskLock[nFormId][nIndex] ) and self.tbTask[nFormId] and self.tbTask[nFormId][nIndex] and self.tbItem[nFormId] then
		self.tbTaskLock[nFormId] = self.tbTaskLock[nFormId] or {};
		self.tbTaskLock[nFormId][nIndex] = 1;
		self.tbTaskLockTimer[nFormId *10000 + nIndex] = Timer:Register(60 * Env.GAME_FPS, self.UnLockTask, self, nFormId, nIndex);
		GlobalExcute({"Task.TaskExp:LockTaskFinish",nFormId, nIndex, szPlayerName});
	else
		GlobalExcute({"Task.TaskExp:LockTaskError",nFormId, nIndex, szPlayerName});
	end	
end

--解锁任务
function tbTaskExp:UnLockTask(nFormId, nIndex)	
	if  self.tbTaskLock[nFormId] and self.tbTaskLock[nFormId][nIndex] then
		self.tbTaskLock[nFormId][nIndex] = nil;
		if self.tbTaskLockTimer[nFormId *10000 + nIndex] then			
			self.tbTaskLockTimer[nFormId *10000 + nIndex] = nil;
		end
	end
	return 0;
end

--撤销任务回调
function tbTaskExp:CanCelTask(nFormId, nIndex, szPlayerName)
	if not self.tbTask[nFormId] or not self.tbItem[nFormId] then
		print("任务发布平台出错！");
		return 0;
	end
	if not self.tbTask[nFormId][nIndex] or (self.tbTaskLock[nFormId] and self.tbTaskLock[nFormId][nIndex]) then	
		GlobalExcute({"Task.TaskExp:CanCelTaskError", szPlayerName});
	else	
		local nCoin = self:CalculateAword(nFormId, nIndex);
		local nKey = nFormId + nIndex * self.nItemCount;
		if self.tbTaskTimer[nKey] and self.tbTaskTimer[nKey] > 0 then
			Timer:Close(self.tbTaskTimer[nKey]);
			self.tbTaskTimer[nKey] = nil;
		end
		if self.tbTaskLockTimer[nKey] and self.tbTaskLockTimer[nKey] > 0 then
			Timer:Close(self.tbTaskLockTimer[nKey]);
			self.tbTaskLockTimer[nKey] = nil;
		end		
		DataForm_Delete(nFormId, nIndex);
		self.tbTask[nFormId][nIndex] = nil;
		GlobalExcute({"Task.TaskExp:CanCelTaskFinish", nFormId, nIndex, nCoin, szPlayerName});		
	end
end

--发布时间结束自动删除
function tbTaskExp:AutoCanCelTask(nFormId, nIndex)	
	if not self.tbTask[nFormId] or not self.tbTask[nFormId][nIndex] then
		return 0;
	end
	local szPlayerName = self.tbTask[nFormId][nIndex].szBuf;
	local nCoin = self:CalculateAword(nFormId, nIndex);
	self.tbTask[nFormId][nIndex] = nil;
	DataForm_Delete(nFormId, nIndex);
	self:AddGlobleBuf(nCoin, szPlayerName);
	GlobalExcute({"Task.TaskExp:AutoCanCelTask", nFormId, nIndex});
	self.tbTaskTimer[nFormId *10000 + nIndex] = nil;
	return 0;
end

--删除globalbuf
function tbTaskExp:DeleteGlobleBuf(nCoin, szPlayerName)
	print(nCoin, szPlayerName, self.tbCheXiaoBuffer[szPlayerName])
	if nCoin <= 0  then
		return;
	end
	if not self.tbCheXiaoBuffer[szPlayerName] then
		return;
	end
	if self.tbCheXiaoBuffer[szPlayerName] <= nCoin then
		self.tbCheXiaoBuffer[szPlayerName] = nil;
	else
		self.tbCheXiaoBuffer[szPlayerName] = self.tbCheXiaoBuffer[szPlayerName] - nCoin;
	end
	self:SaveBuffer_GC();
end

--增加globalbuf
function tbTaskExp:AddGlobleBuf(nCoin, szPlayerName)	
	if nCoin <= 0  then
		return;
	end
	if self.tbCheXiaoBuffer[szPlayerName] then
		self.tbCheXiaoBuffer[szPlayerName] = self.tbCheXiaoBuffer[szPlayerName] + nCoin;
	else
		self.tbCheXiaoBuffer[szPlayerName] = nCoin;
	end
	self:SaveBuffer_GC();
end

function tbTaskExp:LoadBuffer_GC()
	local tbBuffer = GetGblIntBuf(GBLINTBUF_TASKPLATFORM, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbCheXiaoBuffer = tbBuffer;
	end
end

function tbTaskExp:SaveBuffer_GC()
	SetGblIntBuf(GBLINTBUF_TASKPLATFORM, 0, 1, self.tbCheXiaoBuffer);
	GlobalExcute({"Task.TaskExp:LoadBuffer_GS"});
end


--发布任务回调
function tbTaskExp:FaBuTask(nFormId, tbTaskFaBu)
	tbTaskFaBu[3] = GetTime();
	local nIndex = DataForm_Add(nFormId, tbTaskFaBu);
	tbTaskFaBu.nIndex = nIndex;	
	self.tbTask[nFormId][nIndex] = tbTaskFaBu;
	local nKey = nFormId + nIndex * self.nItemCount;
	self.tbTaskTimer[nKey] = Timer:Register(self.nTimeFabu * 3600 * Env.GAME_FPS, self.AutoCanCelTask, self, nFormId, nIndex);
	GlobalExcute({"Task.TaskExp:FaBuTaskFinish", nFormId, nIndex, tbTaskFaBu, tbTaskFaBu.szBuf});
end

--计算金币
function tbTaskExp:CalculateAword(nFormId, nIndex)
	if not self.tbTask[nFormId] or not self.tbTask[nFormId][nIndex] or not self.tbItem[nFormId] then
		return 0;
	end
	return (self.tbItem[nFormId][3] + self.tbItem[nFormId][4] * self.tbTask[nFormId][nIndex][2]) * self.tbTask[nFormId][nIndex][1];
end

function tbTaskExp:MergeCheXiaoBuf(tbSubBuf)
	self.tbCheXiaoBuffer = {};
	self:LoadBuffer_GC();
	for szPlayerName, nCoin in pairs(tbSubBuf) do
		print("[GC_MergeZone]tbSubBuf szPlayerName, nCoin ", szPlayerName, nCoin);
		if (self.tbCheXiaoBuffer[szPlayerName]) then
			print("[GC_MergeZone]Error MergeCheXiaoBuf szPlayerName, nCoin ", szPlayerName, nCoin);
		else
			self.tbCheXiaoBuffer[szPlayerName] = nCoin;
		end
	end
	self:SaveBuffer_GC();
end

GCEvent:RegisterGCServerStartFunc(Task.TaskExp.SeverStart, Task.TaskExp);
GCEvent:RegisterGCServerStartFunc(Task.TaskExp.LoadBuffer_GC, Task.TaskExp);
