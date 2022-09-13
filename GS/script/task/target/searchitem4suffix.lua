
local tb	= Task:GetTarget("SearchItemBySuffix");
tb.szTargetName	= "SearchItemBySuffix";
tb.REFRESH_FRAME	= 18;	-- 一秒检测一次

function tb:Init(szItemName, szSuffix, nNeedCount, bDelete)
	self.szItemName = szItemName;
	self.szSuffix	= szSuffix;
	
	self.nNeedCount = nNeedCount;
	self.bDelete = bDelete;

	self.tbItemId = {};													  
end;

function tb:Start()
	self:Register();
end;

function tb:Save(nGroupId, nStartTaskId)
	self.tbSaveTask	= {	-- 这里保存下来，以后随时可以自行同步客户端
		nGroupId		= nGroupId,
		nStartTaskId	= nStartTaskId,
	};

	return 0;
end;

function tb:Load(nGroupId, nStartTaskId)
	self.tbSaveTask	= {	-- 这里保存下来，以后随时可以自行同步客户端
		nGroupId		= nGroupId,
		nStartTaskId	= nStartTaskId,
	};
	
	self:Register();
	
	return 0;
end;

function tb:IsDone()
	return self:GetCount() >= self.nNeedCount;
	-- self:UnRegister();
end;

function tb:GetDesc()
	local szMsg	= string.format("Tìm thấy %s: %d/%d", self.szItemName.."-"..self.szSuffix, self:GetCount(), self.nNeedCount);
	return szMsg;
end;

function tb:GetStaticDesc()
	local szMsg	= string.format("Tìm thấy %s: %d", self.szItemName, self.nNeedCount);
	return szMsg;
end;

function tb:Close(szReason)
	self:UnRegister();
	if (MODULE_GAMESERVER) then	-- 服务端看情况删除物品
		if (szReason == "finish" and self.bDelete) then
			local pPlayer = self:Base_GetPlayerObj();
			if not pPlayer then
				return;
			end
			Task:DelItem(pPlayer, self.tbItemId, self.nNeedCount);
		end;
	end;
end;

function tb:Register()
	if (not self.nRegisterId) then
		self.nRegisterId	= Timer:Register(self.REFRESH_FRAME, self.OnTimer, self);
	end;
end;

function tb:UnRegister()
	if (self.nRegisterId) then
		Timer:Close(self.nRegisterId);
		self.nRegisterId	= nil;
	end;
end;

-- 返回已有物品数量
function tb:GetCount()
	local pPlayer = self:Base_GetPlayerObj();
	local nCount = 0
	local tbFind = pPlayer.FindClassItemInBags("equip");
	for _, tbItem in ipairs(tbFind) do
		local szItemName2 = tbItem.pItem.szOrgName;
		local szSuffix2 = tbItem.pItem.szSuffix;
		if (szItemName2 == self.szItemName) and (szSuffix2 == self.szSuffix) then
			nCount = nCount + 1
			self.tbItemId = {tbItem.pItem.nGenre, tbItem.pItem.nDetail, tbItem.pItem.nParticular, tbItem.pItem.nLevel}
		end
	end
	return nCount
end;

function tb:OnTimer(nTickCount)
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
			if (MODULE_GAMESERVER) then
				self.tbTask:OnFinishOneTag();
			end
		end
	end;
	
	return self.REFRESH_FRAME;
end;
