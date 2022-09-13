
local tb	= Task:GetTarget("CatchNpc");
tb.szTargetName	= "CatchNpc";
tb.REFRESH_FRAME = 18;

function tb:Init(nNpcTempId, nMapId, tbItemId, nPercent, nNeedCount, bDelete, szBeforePop, szLaterPop)
	self.nNpcTempId	= nNpcTempId;
	self.szNpcName	= KNpc.GetNameByTemplateId(nNpcTempId);
	self.nMapId		= nMapId;
	self.szMapName	= Task:GetMapName(nMapId);
	self.tbItemId	= tbItemId;
	self.szItemName	= KItem.GetNameById(unpack(tbItemId));
	self.nPercent	= nPercent;
	self.nNeedCount	= nNeedCount;
	self.bDelete	= bDelete;
	self.szBeforePop	= szBeforePop;
	self.szLaterPop		= szLaterPop;
end;

function tb:Start()
end;

function tb:Save(nGroupId, nStartTaskId)
	self.nGroupId	= nGroupId;
	return 0;
end;

function tb:Load(nGroupId, nStartTaskId)
	self.nGroupId	= nGroupId;
	return 0;
end;

function tb:IsDone()
	return self:GetCount() >= self.nNeedCount;
end;

function tb:GetDesc()
	local szMsg	= "Hạ gục ";
	if (self.nMapId ~= 0) then
		szMsg	= szMsg..self.szMapName.." - ";
	end;
	szMsg	= szMsg..string.format("%s và bắt được %s: %d/%d", self.szNpcName, self.szItemName, self:GetCount(), self.nNeedCount);
	return szMsg;
end;

function tb:GetStaticDesc()
	local szMsg	= "Hạ gục ";
	if (self.nMapId ~= 0) then
		szMsg	= szMsg..self.szMapName.." - ";
	end;
	szMsg	= szMsg..string.format("%s%d ", self.szNpcName, self.nNeedCount);
	return szMsg;
end;

function tb:Close(szReason)
	if (MODULE_GAMESERVER) then	-- 服务端看情况删除物品
		if (szReason == "finish" and self.bDelete) then
			--Task:DelItem(self.me, self.tbItemId, self.nNeedCount);
		end;
	end;
end;



function tb:RegisterTimer()
	if (MODULE_GAMESERVER and not self.nRegisterTimerId) then
		self.nRegisterTimerId	= Timer:Register(self.REFRESH_FRAME, self.OnTimer, self);
	end;
end;

function tb:UnRegisterTimer()
	if (MODULE_GAMESERVER and self.nRegisterTimerId) then
		Timer:Close(self.nRegisterTimerId);
		self.nRegisterTimerId	= nil;
	end;
end;


function tb:OnTimer()
	local tbSaveTask	= self.tbSaveTask;
	if (MODULE_GAMESERVER) then	-- 自行同步到客户端，要求客户端刷新
		local pPlayer = self:Base_GetPlayerObj();
		if not pPlayer then
			return;
		end
		KTask.SendRefresh(pPlayer, self.tbTask.nTaskId, self.tbTask.nReferId, tbSaveTask.nGroupId);
	end;
	
	if (self:IsDone()) then
		self.tbTask:OnFinishOneTag();
	end	
	
	return self.REFRESH_FRAME;
end

-- 返回已有物品数量
function tb:GetCount()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	return Task:GetItemCount(pPlayer, self.tbItemId);
end;

function tb:OnKillNpc(pPlayer, pNpc)
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	if (self.nNpcTempId ~= pNpc.nTemplateId) then
		return;
	end;
	if (self:IsDone()) then
		return;
	end;
	
	if (self.nMapId ~= 0 and self.nMapId ~= pPlayer.GetMapId()) then
		return;
	end;

	if (TaskCond:CanAddItemsIntoBag({self.tbItemId}) ~= 1) then
		pPlayer.Msg("Hành trang đã đầy, không thể chứa vật phẩm mới!")
		return;
	end
	
	if (MathRandom() >= self.nPercent) then
		return;
	end
	
	Task:AddItem(pPlayer, self.tbItemId);

	local szMsg	= string.format("Đạt được 1 %s ", self.szNpcName);
	pPlayer.Msg(szMsg);
	if (MODULE_GAMESERVER and self.nGroupId) then	-- 自行同步到客户端，要求客户端刷新
		KTask.SendRefresh(pPlayer, self.tbTask.nTaskId, self.tbTask.nReferId, self.nGroupId);
	end;
	
	if (self:IsDone()) then
		self.tbTask:OnFinishOneTag();
	end
end;


