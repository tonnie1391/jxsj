
local tb = Task:GetTarget("GoPos");
tb.szTargetName	= "GoPos";

tb.REFRESH_FRAME	= 18;	-- 一秒检测一次

function tb:Init(nMapId, nPosX, nPosY, nR, szPosDesc)
	self.nMapId		= nMapId;
	self.nPosX		= nPosX;
	self.nPosY		= nPosY;
	self.nR			= nR;
	self.szPosDesc	= szPosDesc;
end;

function tb:Start()
	self.bDone		= 0;
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
	pPlayer.SetTask(nGroupId, nStartTaskId, self.bDone);
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
	self.bDone		= pPlayer.GetTask(nGroupId, nStartTaskId);
	if (not self:IsDone()) then	-- 本目标是一旦达成后不会失效的
		self:Register();
	end;
	return 1;
end;

function tb:IsDone()
	return self.bDone == 1;
end;

function tb:GetDesc()
	return self:GetStaticDesc();
end;

function tb:GetStaticDesc()
	return self.szPosDesc;
end;

function tb:Close(szReason)
	self:UnRegister();
end;


function tb:Register()
	if (MODULE_GAMESERVER and not self.nRegisterId) then
		self.nRegisterId	= Timer:Register(self.REFRESH_FRAME, self.OnTimer, self);
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
	Setting:SetGlobalObj(pPlayer);
	local bAtPos	= TaskCond:IsAtPos(self.nMapId, self.nPosX, self.nPosY, self.nR);
	Setting:RestoreGlobalObj();
	
	if (not bAtPos) then
		return self.REFRESH_FRAME;
	end;
	self.bDone	= 1;
	local tbSaveTask	= self.tbSaveTask;
	if (MODULE_GAMESERVER and tbSaveTask) then	-- 自行同步到客户端，要求客户端刷新
		pPlayer.SetTask(tbSaveTask.nGroupId, tbSaveTask.nStartTaskId, self.bDone, 1);
		KTask.SendRefresh(pPlayer, self.tbTask.nTaskId, self.tbTask.nReferId, tbSaveTask.nGroupId);
	end;
	pPlayer.Msg("Mục tiêu: "..self:GetStaticDesc());
	self:UnRegister();
	self.tbTask:OnFinishOneTag();
	return 0;	-- 关闭此Timer，本目标是一旦达成后不会失效的
end;
