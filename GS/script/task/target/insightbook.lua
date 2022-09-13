
local tb	= Task:GetTarget("InsightBook");
tb.szTargetName	= "InsightBook";

function tb:Init(nMaxLimit, tbItem, szDynamicDesc, szStaticDesc)
	self.nMaxLimit			= nMaxLimit;
	self.tbItem				= tbItem;
	self.szDynamicDesc		= szDynamicDesc;
	self.szStaticDesc		= szStaticDesc;
end;


--目标开启
function tb:Start()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	self.nCurInsight		= 0;
	self:Register();
	pPlayer.SetTask(2006, 2, 1);
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
	pPlayer.SetTask(nGroupId, nStartTaskId, self.nCurInsight, 1);
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
	self.nCurInsight		= pPlayer.GetTask(nGroupId, nStartTaskId);
	if (not self:IsDone()) then	-- 本目标是一旦达成后不会失效的
		self:Register();
		pPlayer.SetTask(2006, 2, 1);
	end;
	return 1;
end;

--返回目标是否达成
function tb:IsDone()
	return self.nCurInsight >= self.nMaxLimit;
end;

--返回目标进行中的描述（客户端）
function tb:GetDesc()
	local szDesc = string.format("你现在已获得%d/%d点修炼经验值。", self.nCurInsight, self.nMaxLimit);
	return szDesc;
end;


--返回目标的静态描述，与当前玩家进行的情况无关
function tb:GetStaticDesc()
	return "你通过刻苦的修炼终于写出了一本心得书！";
end;


function tb:Close(szReason)
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	pPlayer.SetTask(2006, 2, 0);
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
		self.nRegisterId	= PlayerEvent:Register("OnAddInsight", self.OnAddInsight, self);
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
		PlayerEvent:UnRegister("OnAddInsight", self.nRegisterId);
		self.nRegisterId	= nil;
	end;
	Setting:RestoreGlobalObj();
end;


function tb:OnAddInsight(nInsightNumber)
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	local nAddInsight = nInsightNumber;
	if ((self.nCurInsight + nAddInsight) > self.nMaxLimit) then
		nAddInsight = self.nMaxLimit - self.nCurInsight;
	end
	
	self.nCurInsight = self.nCurInsight + nAddInsight;
	
	pPlayer.Msg("你获得"..nAddInsight.."点心得！");

	
	local tbSaveTask	= self.tbSaveTask;
	if (MODULE_GAMESERVER and tbSaveTask) then	-- 自行同步到客户端，要求客户端刷新
		pPlayer.SetTask(tbSaveTask.nGroupId, tbSaveTask.nStartTaskId, self.nCurInsight, 1);
		KTask.SendRefresh(pPlayer, self.tbTask.nTaskId, self.tbTask.nReferId, tbSaveTask.nGroupId);
	end;
	
	if (self.nCurInsight >= self.nMaxLimit) then	
		self.tbTask:OnFinishOneTag();
	end
end

