
local tb = Task:GetTarget("GoPosByMutiMap");
tb.szTargetName	= "GoPosByMutiMap";

tb.REFRESH_FRAME	= 18;	-- 一秒检测一次

function tb:Init(szMapType, nPosX, nPosY, nR, szPosDesc)
	self.tbMapEnv	= {};
	self.szMapType	= szMapType;
	self.nPosX		= nPosX;
	self.nPosY		= nPosY;
	self.nR			= nR;
	self.szPosDesc	= szPosDesc;
	self:InitTargetMap();
end;

function tb:InitTargetMap()
	if (not self.szMapType) then
		return;
	end
	local tbMapId = Map.tbTypeMap[self.szMapType] or {};
	self.tbMapEnv = {};
	for i, v in pairs(tbMapId) do
		if (IsMapLoaded(v) == 1) then
			self.tbMapEnv[v] = {};
		end			
	end
end

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

	local nIsCanDoTarget, szErrorMsg = Task:IsCanDoTargetSpeCondition(pPlayer, self.tbTask.nTaskId, self.tbTask.nCurStep);
	if (nIsCanDoTarget ~= 1) then
		Setting:RestoreGlobalObj();
		return;
	end	
	
	local bAtPos = nil;
	for nMapId, tbInfo in pairs(self.tbMapEnv) do
		bAtPos	= TaskCond:IsAtPos(nMapId, self.nPosX, self.nPosY, self.nR);
		if (bAtPos) then
			break;
		end
	end
	
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
	pPlayer.Msg("Mục tiêu:"..self:GetStaticDesc());
	self:UnRegister();
	self.tbTask:OnFinishOneTag();
	return 0;	-- 关闭此Timer，本目标是一旦达成后不会失效的
end;
