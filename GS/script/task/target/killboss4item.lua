
local tb	= Task:GetTarget("KillBoss4Item");
tb.szTargetName	= "KillBoss4Item";
tb.REFRESH_FRAME	= 18 * 3;	-- zhengyuhua:降低刷新频率(原：一秒检测一次)

function tb:Init(nNpcTempId, nMapId, tbItemId, nPercent, nNeedCount, bDelete, szBeforePop, szLaterPop)
	self.nNpcTempId	= nNpcTempId;
	self.szNpcName	= KNpc.GetNameByTemplateId(nNpcTempId);
	self.nMapId		= nMapId;
	self.szMapName	= Task:GetMapName(nMapId);
	self.tbItemId	= tbItemId;
	self.szItemName	= KItem.GetNameById(unpack(self.tbItemId)) or "";
	self.nPercent	= nPercent;
	self.nNeedCount	= nNeedCount;
	self.bDelete	= bDelete;
	self.szBeforePop	= szBeforePop;
	self.szLaterPop		= szLaterPop;
	self.bShare = 1
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
	
	
	szMsg	= szMsg..string.format("%s, được %s: %d/%d", self.szNpcName, self.szItemName, nCurCount, self.nNeedCount);
	return szMsg;
end;

function tb:GetStaticDesc()
	local szMsg	= "Hạ gục ";
	if (self.nMapId ~= 0) then
		szMsg	= szMsg..self.szMapName.." - ";
	end;
	szMsg	= szMsg..string.format("%s, nhận %s %d", self.szNpcName, self.szItemName, self.nNeedCount);
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
	if (MODULE_GAMESERVER and not self.nRegisterId) then
		self.nRegisterId	= Timer:Register(self.REFRESH_FRAME, self.OnTimer, self);
	end;
end


function tb:UnRegister()
	if (MODULE_GAMESERVER and self.nRegisterId) then
		Timer:Close(self.nRegisterId);
		self.nRegisterId	= nil;
	end;
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
			self.tbTask:OnFinishOneTag();
		end
	end;
	
	return self.REFRESH_FRAME;
end


function tb:OnShareBossItem(pPlayer, pNpc)
	local pPlayerEx = self:Base_GetPlayerObj();
	if not pPlayerEx then
		return;
	end
	if (self:IsDone()) then
		return 0;
	end
	
	if (self.nNpcTempId ~= pNpc.nTemplateId) then
		return 0;
	end;
	
	if (self.nMapId ~= 0 and self.nMapId ~= pPlayer.GetMapId()) then
		return 0;
	end;	
	Setting:SetGlobalObj(pPlayerEx);
	if (TaskCond:CanAddItemsIntoBag({self.tbItemId}) ~= 1) then
		me.Msg("Túi đầy!")
		Setting:RestoreGlobalObj();
		return;
	end	
	Task:AddItem(me, self.tbItemId);
	Setting:RestoreGlobalObj();
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
