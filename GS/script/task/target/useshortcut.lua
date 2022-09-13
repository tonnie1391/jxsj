
-- 使用快捷键目标达成
local tb	= Task:GetTarget("UseShortcut");
tb.szTargetName	= "UseShortcut";	--本目标的名字，暂时还没用到


--目标初始化
--具体参数可在任务编辑器中自定义
function tb:Init()
	
end;

--目标开启
function tb:Start()
	self.bDone = 0;
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


--返回目标是否达成
function tb:IsDone()
	return self.bDone == 1;
end;

--返回目标进行中的描述（客户端）
function tb:GetDesc()
	return self:GetStaticDesc();
end;

--返回目标的静态描述，与当前玩家进行的情况无关
function tb:GetStaticDesc()
	local szMsg	= "右键点击快捷栏，使用其中的物品";
	return szMsg;
end;


function tb:Close(szReason)
	self:UnRegister();
end;

----==== 以下是本目标所特有的函数定义，如有雷同，纯属巧合 ====----

function tb:Register()
	assert(self._tbBase._tbBase)	--没有经过两次派生，脚本书写错误
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	Setting:SetGlobalObj(pPlayer);
	if (MODULE_GAMESERVER and not self.nRegisterId) then
		self.nRegisterId	= PlayerEvent:Register("OnUseShortcut", self.OnUseShortcut, self);
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
		PlayerEvent:UnRegister("OnUseShortcut", self.nRegisterId);
		self.nRegisterId	= nil;
	end;
	Setting:RestoreGlobalObj();
end;


function tb:OnUseShortcut()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	if (self:IsDone()) then
		return;
	end;
	
	self.bDone = 1;
	local tbSaveTask	= self.tbSaveTask;
	if (MODULE_GAMESERVER and tbSaveTask) then	-- 自行同步到客户端，要求客户端刷新
		pPlayer.SetTask(tbSaveTask.nGroupId, tbSaveTask.nStartTaskId, self.bDone, 1);
		KTask.SendRefresh(pPlayer, self.tbTask.nTaskId, self.tbTask.nReferId, tbSaveTask.nGroupId);
	end;
	if (self:IsDone()) then	-- 本目标是一旦达成后不会失效的
		pPlayer.Msg("Mục tiêu: "..self:GetStaticDesc());
		self:UnRegister();
		self.tbTask:OnFinishOneTag();
	end;
end;
