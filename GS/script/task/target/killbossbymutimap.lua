
local tb	= Task:GetTarget("KillBossByMutiMap");
tb.szTargetName	= "KillBossByMutiMap";

function tb:Init(nNpcTempId, nMapId, nNeedCount, szBeforePop, szLaterPop)
	self.nNpcTempId		= nNpcTempId;
	self.szNpcName		= KNpc.GetNameByTemplateId(nNpcTempId);
	self.nMapId			= nMapId;
	self.szMapName		= Task:GetMapName(nMapId);
	self.nNeedCount		= nNeedCount;
	self.szBeforePop	= szBeforePop;
	self.szLaterPop		= szLaterPop;
	self:InitTargetMap();
end;

function tb:InitTargetMap()
	if (self.nMapId == 0) then
		if (not self.szBeforePop) then
			return;
		end
		local tbMapId = Map.tbTypeMap[self.szBeforePop] or {};
		for i, v in pairs(tbMapId) do
			if (IsMapLoaded(v) == 1) then
				self.nMapId = v;
				break;
			end			
		end
		self.szMapName = Task:GetMapName(self.nMapId)
	end	
end


function tb:Start()
	self.nCount		= 0;
end;


function tb:Save(nGroupId, nStartTaskId)
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	self.tbSaveTask	= {
		nGroupId		= nGroupId,
		nStartTaskId	= nStartTaskId,
	};
	pPlayer.SetTask(nGroupId, nStartTaskId, self.nCount);
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
	self.nCount		= pPlayer.GetTask(nGroupId, nStartTaskId);
	return 1;
end;


function tb:IsDone()
	return self.nCount >= self.nNeedCount;
end;


function tb:GetDesc()
	local szMsg	= "Diệt ";
	if (self.nMapId ~= 0) then
		szMsg	= szMsg..self.szMapName.."-";
	end;
	szMsg	= szMsg..string.format("%s: %d/%d", self.szNpcName, self.nCount, self.nNeedCount);
	return szMsg;
end;


function tb:GetStaticDesc()
	local szMsg	= "Diệt ";
	if (self.nMapId ~= 0) then
		szMsg	= szMsg..self.szMapName.."-";
	end;
	szMsg	= szMsg..string.format("%s %d", self.szNpcName, self.nNeedCount);
	return szMsg;
end;


function tb:Close(szReason)

end;


function tb:OnKillNpc(pPlayer, pNpc)
	local pPlayerEx = self:Base_GetPlayerObj();
	if not pPlayerEx then
		return;
	end
	if (self:IsDone()) then
		return;
	end;
	
	if (self.nNpcTempId ~= pNpc.nTemplateId) then
		return;
	end;
	if (self.nMapId ~= 0 and self.nMapId ~= pPlayer.GetMapId()) then
		return;
	end;
	
	self.nCount	= self.nCount + 1;
	
	local tbSaveTask	= self.tbSaveTask;
	if (MODULE_GAMESERVER and tbSaveTask) then	-- 自行同步到客户端，要求客户端刷新
		pPlayerEx.SetTask(tbSaveTask.nGroupId, tbSaveTask.nStartTaskId, self.nCount, 1);
		KTask.SendRefresh(pPlayerEx, self.tbTask.nTaskId, self.tbTask.nReferId, tbSaveTask.nGroupId);
	end;
	
	
	if (self:IsDone()) then	-- 本目标是一旦达成后不会失效的
		pPlayerEx.Msg("Mục tiêu:"..self:GetStaticDesc());
		self.tbTask:OnFinishOneTag();
	end;
	
end;
