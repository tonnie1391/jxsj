

local tb	= Task:GetTarget("KillNpc4NormalItem");
tb.szTargetName	= "KillNpc4NormalItem";
tb.REFRESH_FRAME	= 18 * 3;	-- zhengyuhua:降低刷新频率(原：一秒检测一次)

function tb:Init(nNpcTempId, nMapId, tbItemId, nPercent, nNeedCount, szBeforePop, szLaterPop , bShare)
	self.nNpcTempId	= nNpcTempId;
	self.szNpcName	= KNpc.GetNameByTemplateId(nNpcTempId);
	self.nMapId		= nMapId;
	self.szMapName	= Task:GetMapName(nMapId);
	self.tbItemId	= tbItemId;
	self.szItemName	= KItem.GetNameById(unpack(self.tbItemId)) or "";
	self.nPercent	= nPercent;
	self.nNeedCount	= nNeedCount;
	self.bDelete	= false;
	self.szBeforePop	= szBeforePop;
	self.szLaterPop		= szLaterPop;
	self.bShare     = tonumber(bShare) or 1;
end;

function tb:Start()
	self:Register();
end;

function tb:Save(nGroupId, nStartTaskId)
	self.tbSaveTask	= {	-- 这里保存下来，以后随时可以自行同步客户端
		nGroupId		= nGroupId,
		nStartTaskId	= nStartTaskId,
	};
	
	
	return 1;
end;

function tb:Load(nGroupId, nStartTaskId)
		self.tbSaveTask	= {	-- 这里保存下来，以后随时可以自行同步客户端
		nGroupId		= nGroupId,
		nStartTaskId	= nStartTaskId,
	};
	self:Register();
	
	return 1;
end;

function tb:IsDone()
	return self:GetCount() >= self.nNeedCount;
end;

function tb:GetDesc()
	local szMsg	= "Hạ gục ";
	if (self.nMapId ~= 0) then
		szMsg	= szMsg..self.szMapName.." - ";
	end;
	
	local nCurCount = self:GetCount();
	if (nCurCount > self.nNeedCount) then
		nCurCount = self.nNeedCount;
	end
	
	
	szMsg	= szMsg..string.format("%s ,nhận %s: %d/%d", self.szNpcName, self.szItemName, nCurCount, self.nNeedCount);
	return szMsg;
end;

function tb:GetStaticDesc()
	local szMsg	= "Hạ gục ";
	if (self.nMapId ~= 0) then
		szMsg	= szMsg..self.szMapName.." - ";
	end;
	szMsg	= szMsg..string.format("%s ,nhận %s%d", self.szNpcName, self.szItemName, self.nNeedCount);
	return szMsg;
end;



function tb:Close(szReason)
	if (MODULE_GAMESERVER) then	-- 服务端看情况删除物品
		local pPlayer = self:Base_GetPlayerObj();
		if not pPlayer then
			return;
		end
		if (szReason == "finish" and self.bDelete) then
			Task:DelItem(pPlayer, self.tbItemId, self.nNeedCount);
		end
	end
	
	self:UnRegister();
end;


function tb:Register()
	if (MODULE_GAMESERVER) then
		local pPlayer = self:Base_GetPlayerObj();
		if not pPlayer then
			return;
		end
		if (not self.nRegisterId) then
			self.tbTask:AddInCollectList(self.tbItemId);
			self.bCanCollect = 1;
			self.nRegisterId	= Timer:Register(self.REFRESH_FRAME, self.OnTimer, self);
		end
		if (not self.nRegPickId) then
			Setting:SetGlobalObj(pPlayer);
			self.nRegPickId		= PlayerEvent:Register("OnPickUp", self.OnPickUp, self);
			Setting:RestoreGlobalObj()
		end
	end;
end


function tb:UnRegister()
	if (MODULE_GAMESERVER) then
		local pPlayer = self:Base_GetPlayerObj();
		if not pPlayer then
			return;
		end
		if (self.nRegisterId) then
			Timer:Close(self.nRegisterId);
			self.nRegisterId	= nil;
		end
		if (self.nRegPickId) then
			Setting:SetGlobalObj(pPlayer);
			PlayerEvent:UnRegister("OnPickUp", self.nRegPickId);
			self.nRegPickId = nil;
			Setting:RestoreGlobalObj()
		end
	end;
end


function tb:OnPickUp()
	if (self:IsDone()) then
		if (self.bCanCollect == 1) then
			self.tbTask:RemoveInCollectList(self.tbItemId);
			self.bCanCollect = 0;
		end
	else
		if (self.bCanCollect == 0) then
			self.tbTask:AddInCollectList(self.tbItemId);
			self.bCanCollect = 1;
		end
	end
end

function tb:OnTimer()
	local nCount	= self:GetCount();
	if (not self.nCount or self.nCount ~= nCount) then
		self.nCount	= nCount;
		local tbSaveTask	= self.tbSaveTask;
		if (MODULE_GAMESERVER) then	-- 自行同步到客户端，要求客户端刷新
			local pPlayer = self:Base_GetPlayerObj();
			if not pPlayer then
				return;
			end
			KTask.SendRefresh(pPlayer, self.tbTask.nTaskId, self.tbTask.nReferId, tbSaveTask.nGroupId);
		end;
		
		if (self:IsDone()) then
			if (self.bCanCollect == 1) then
				self.tbTask:RemoveInCollectList(self.tbItemId);
				self.bCanCollect = 0;
			end
			self.tbTask:OnFinishOneTag();
		else
			if (self.bCanCollect == 0) then
				self.tbTask:AddInCollectList(self.tbItemId);
				self.bCanCollect = 1;
			end
		end
	end;
	
	return self.REFRESH_FRAME;
end


function tb:OnKillNpcDropItem(pPlayer, pNpc, nType)
	if (self:IsDone()) then
		return 0;
	end
	
	if (self.nNpcTempId ~= pNpc.nTemplateId) then
		return 0;
	end;
	
	if (self.nMapId ~= 0 and self.nMapId ~= pPlayer.GetMapId()) then
		return 0;
	end;
	
	
	if (MathRandom() >= self.nPercent) then
		return 0;
	end
	
	local nPosX, nPosY = pNpc.GetMpsPos();
	local nMapIdx = 0;
	if (self.nMapId <= 0) then
		nMapIdx	= SubWorldID2Idx(pPlayer.GetMapId()); 
	else
		nMapIdx	= SubWorldID2Idx(self.nMapId);
	end
	
	if not nType then
		Task:AddObjAtPos(pPlayer, self.tbItemId, nMapIdx, nPosX, nPosY);
	else
		Task:AddItem(pPlayer, self.tbItemId);
	end
	
	return 1;
end


-- 返回已有物品数量
function tb:GetCount()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	return Task:GetItemCount(pPlayer, self.tbItemId);
end;
