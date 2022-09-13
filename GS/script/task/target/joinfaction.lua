
local tb	= Task:GetTarget("JoinFaction");
tb.szTargetName	= "JoinFaction";

function tb:Init(nFactionId, szDynamicDesc, szStaticDesc)
	self.nFactionId 		= nFactionId;
	self.szDynamicDesc		= szDynamicDesc;
	self.szStaticDesc		= szStaticDesc;	
end;



function tb:Start()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	self.bDone		= 0;
	if (self.nFactionId == 0) then
		if (pPlayer.nFaction > 0) then
			self.bDone = 1;
		end
	else
		if (pPlayer.nFaction == self.nFactionId) then
			self.bDone = 1;
		end
	end
	if (self.bDone == 1) then
		local tbSaveTask	= self.tbSaveTask;
		if (MODULE_GAMESERVER and tbSaveTask) then	-- 自行同步到客户端，要求客户端刷新
			pPlayer.SetTask(tbSaveTask.nGroupId, tbSaveTask.nStartTaskId, self.bDone, 1);
			KTask.SendRefresh(pPlayer, self.tbTask.nTaskId, self.tbTask.nReferId, tbSaveTask.nGroupId);
		end;
		self.tbTask:OnFinishOneTag();
	else
		self:Register();	
	end	 
	
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

--返回目标是否达成
function tb:IsDone()
	return self.bDone == 1;
end;

--返回目标进行中的描述（客户端）
function tb:GetDesc()
	return self.szDynamicDesc or "";
end;


--返回目标的静态描述，与当前玩家进行的情况无关
function tb:GetStaticDesc()
	return self.szStaticDesc or "";
end;



function tb:Close(szReason)
	self:UnRegister();
end;


function tb:Register()
	assert(self._tbBase._tbBase)	--没有经过两次派生，脚本书写错误
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	Setting:SetGlobalObj(pPlayer);
	if (MODULE_GAMESERVER and not self.nRegisterId) then
		self.nRegisterId	= PlayerEvent:Register("OnFactionChange", self.OnFactionChange, self);
	end;
	Setting:RestoreGlobalObj();
end;


function tb:UnRegister()
	assert(self._tbBase._tbBase)	--没有经过两次派生，脚本书写错误
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	Setting:SetGlobalObj(pPlayer);
	if (MODULE_GAMESERVER and self.nRegisterId) then
		PlayerEvent:UnRegister("OnFactionChange", self.nRegisterId);
		self.nRegisterId	= nil;
	end;
	Setting:RestoreGlobalObj();
end;

function tb:OnFactionChange(nFactionId)
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	if (self:IsDone()) then
		return;
	end
	if (self.nFactionId == 0) then
		if (pPlayer.nFaction > 0) then
			self.bDone = 1;
		end
	else
		if (pPlayer.nFaction == self.nFactionId) then
			self.bDone = 1;
		end
	end
	
	local tbSaveTask	= self.tbSaveTask;
	if (MODULE_GAMESERVER and tbSaveTask) then	-- 自行同步到客户端，要求客户端刷新
		pPlayer.SetTask(tbSaveTask.nGroupId, tbSaveTask.nStartTaskId, self.bDone, 1);
		KTask.SendRefresh(pPlayer, self.tbTask.nTaskId, self.tbTask.nReferId, tbSaveTask.nGroupId);
	end;
	pPlayer.Msg("Mục tiêu: "..self:GetStaticDesc());
	self:UnRegister();
	self.tbTask:OnFinishOneTag();
end
