
local tb	= Task:GetTarget("Timer");
tb.szTargetName	= "Timer";

--	nMode，操作模式：
--		0、执行，到0后执行自定义脚本，并重新开始计数，此目标永远是已达成
--		1、失败，到0后执行自定义脚本，任务失败，在到0之前是已达成
--		2、成功，到0后执行自定义脚本，目标达成

function tb:Init(nTotalSec, nMode, szCode)
	self.nTotalSec	= nTotalSec;
	self.nMode		= nMode;
	if (szCode ~= "") then
		self.fnCall	= loadstring(szCode);
	end;
end;

function tb:Start()
	self.nRestFrame	= self.nTotalSec * 18;
	self:Register();
end;

function tb:Save(nGroupId, nStartTaskId)
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	self.tbSaveTask	= {	-- 这里保存下来，以后随时可以自行同步客户端
		nGroupId		= nGroupId,
		nStartTaskId	= nStartTaskId,
	};

	pPlayer.SetTask(nGroupId, nStartTaskId, self.nRestFrame);
	return 1;
end;

function tb:Load(nGroupId, nStartTaskId)
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	self.tbSaveTask	= {	-- 这里保存下来，以后随时可以自行同步客户端
		nGroupId		= nGroupId,
		nStartTaskId	= nStartTaskId,
	};
	self.nRestFrame	= pPlayer.GetTask(nGroupId, nStartTaskId);

	if (self.nRestFrame ~= 0) then	-- 一旦计时到0，一定是达成了
		self:Register();
	end;
	
	return 1;
end;

function tb:IsDone()
	return self.nRestFrame <= 0 or self.nMode ~= 2;
end;

function tb:GetDesc()
	return "Thời gian còn lại: "..self:GetTimeStr(math.ceil(self.nRestFrame/18));
end;

function tb:GetStaticDesc()
	return "限时："..self:GetTimeStr(self.nTotalSec);
end;

function tb:Close(szReason)
	self:UnRegister();
end;


function tb:Register()
	if (MODULE_GAMESERVER and not self.nRegisterId) then
		self.nRegisterId	= Timer:Register(18, self.OnTimer, self);
	end;
end;

function tb:UnRegister()
	if (MODULE_GAMESERVER and self.nRegisterId) then
		Timer:Close(self.nRegisterId);
		self.nRegisterId	= nil;
	end;
end;


function tb:OnTimer()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	self.nRestFrame	= self.nRestFrame - 18;
	
	if (self.nRestFrame > 0) then
		if (MODULE_GAMESERVER) then
			pPlayer.SetTask(self.tbSaveTask.nGroupId, self.tbSaveTask.nStartTaskId, self.nRestFrame, 1);
			KTask.SendRefresh(pPlayer, self.tbTask.nTaskId, self.tbTask.nReferId, self.tbSaveTask.nGroupId);
		end
		
		return 18;
	end
	
	-- 完成了
	self.nRestFrame = 0;
	if (self.nMode == 0) then
		--无响应
		if (self.fnCall) then
			self.fnCall();
		end;
	elseif (self.nMode == 1) then
		--失败
		if (self.fnCall) then
			self.fnCall();
		end;
		self.nRegisterId	= nil;	-- 先清除，防止重复注销
		Task:Failed(self.tbTask.nTaskId)	-- 此函数在调用后应尽快全部返回，停止此任务的处理，否则容易出现异常
		return 0;	-- 返回0表示注销Timer
	elseif (self.nMode == 2) then
		--成功
		if (self.fnCall) then
			self.fnCall();
		end;
		pPlayer.Msg("Mục tiêu: "..self:GetStaticDesc());
		self.tbTask:OnFinishOneTag();
	end;


	if (MODULE_GAMESERVER) then
		pPlayer.SetTask(self.tbSaveTask.nGroupId, self.tbSaveTask.nStartTaskId, self.nRestFrame, 1);
		KTask.SendRefresh(pPlayer, self.tbTask.nTaskId, self.tbTask.nReferId, self.tbSaveTask.nGroupId);
	end
		
	if (self.nRestFrame == 0) then
		self.nRegisterId	= nil;	-- 先清除，防止重复注销
	end;
	
	return 0;	
end;

function tb:GetTimeStr(nSec)
	local nMin	= math.floor(nSec / 60);
	local nHour	= math.floor(nMin / 60);
	local nDay	= math.floor(nHour / 24);
	nSec	= math.mod(nSec, 60);
	nMin	= math.mod(nMin, 60);
	nHour	= math.mod(nHour, 24);
	if (nDay > 0) then
		return string.format("%d天%d小时", nDay, nHour);
	elseif (nHour > 0) then
		return string.format("%d小时%d分", nHour, nMin);
	else
		return string.format("%d分%d秒", nMin, nSec);
	end;
end;
