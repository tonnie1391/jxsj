
local tb	= Task:GetTarget("PlayerLevelUp");
tb.szTargetName	= "PlayerLevelUp";
tb.REFRESH_FRAME	= 18 * 10;	-- zhengyuhua:降低刷新频率(原：一秒检测一次)

function tb:Init(nLevel, szStaticDesc, szDynamicDesc)
	self.nLevel				= nLevel;
	self.szStaticDesc		= szStaticDesc;
	self.szDynamicDesc		= szDynamicDesc;
end;


--目标开启
function tb:Start()
		self.bDone		= 0;
		self:Register();
end;

--目标保存
--根据任务变量组Id（nGroupId）以及组内变量起始Id（nStartTaskId），保存本目标的运行期数据
--返回实际存入的变量数量
function tb:Save(nGroupId, nStartTaskId)
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	self.tbSaveTask	= {	-- 这里保存下来，以后随时可以自行同步客户端
		nGroupId		= nGroupId,
		nStartTaskId	= nStartTaskId,
	};
	pPlayer.SetTask(nGroupId, nStartTaskId, self.bDone, 1);
	
	return 1;
end;

--目标载入
--根据任务变量组Id（nGroupId）以及组内变量起始Id（nStartTaskId），载入本目标的运行期数据
--返回实际载入的变量数量
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
	
	if (self.bDone ~= 1) then
		self:Register();
	end
	
	return 1;
end;

--返回目标是否达成
function tb:IsDone()
	return self.bDone == 1;
end;

--返回目标进行中的描述（客户端）
function tb:GetDesc()
	return self.szDynamicDesc;
end;


--返回目标的静态描述，与当前玩家进行的情况无关
function tb:GetStaticDesc()
	return self.szStaticDesc;
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
	if (pPlayer.nLevel >= self.nLevel) then
		self.bDone = 1;
		
		local tbSaveTask	= self.tbSaveTask;
		if (MODULE_GAMESERVER and tbSaveTask) then	-- 自行同步到客户端，要求客户端刷新
			pPlayer.SetTask(tbSaveTask.nGroupId, tbSaveTask.nStartTaskId, self.bDone, 1);
			KTask.SendRefresh(pPlayer, self.tbTask.nTaskId, self.tbTask.nReferId, tbSaveTask.nGroupId);
		end;
	
		pPlayer.Msg("Mục tiêu: "..self:GetStaticDesc());
	
		self:UnRegister()	-- 本目标是一旦达成后不会失效的
	
		self.tbTask:OnFinishOneTag();
	end
end

