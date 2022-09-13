
local tb	= Task:GetTarget("TalkWithNpcByMutiMap");
tb.szTargetName	= "TalkWithNpcByMutiMap";

function tb:Init(nNpcTempId, nMapId, szOption, szMsg, szRepeatMsg,  szStaticDesc, szDynamicDesc, szBeforePop, szLaterPop)
	self.nNpcTempId	= nNpcTempId;
	self.szNpcName	= KNpc.GetNameByTemplateId(nNpcTempId);
	self.nMapId		= nMapId;
	self.szMapName	= Task:GetMapName(nMapId);
	self.szOption	= szOption;
	self.szMsg		= szMsg;
	if (szRepeatMsg ~= "") then
		self.szRepeatMsg	= szRepeatMsg;
	end;
	
	self.szStaticDesc	= szStaticDesc;
	self.szDynamicDesc	= szDynamicDesc;
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
		local nMapNameId = 0;
		self.tbMapEnv = {};
		for i, v in pairs(tbMapId) do
			if (IsMapLoaded(v) == 1) then
				self.nMapId = v;
			end			
		end
		self.szMapName = Task:GetMapName(self.nMapId)
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
	if (not self:IsDone() or self.szRepeatMsg) then	-- 本目标是一旦达成后不会失效的
		self:Register();
	end;
	return 1;
end;

function tb:IsDone()
	return self.bDone == 1;
end;

function tb:GetDesc()
	return self.szDynamicDesc or "";
end;

function tb:GetStaticDesc()
	return self.szStaticDesc or "";
end;


function tb:Close(szReason)
	self:UnRegister();
end;


function tb:Register()
	self.tbTask:AddNpcMenu(self.nNpcTempId, self.nMapId, self.szOption, self.OnTalkNpc, self);
end;

function tb:UnRegister()
	self.tbTask:RemoveNpcMenu(self.nNpcTempId);
end;

function tb:OnTalkNpc()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end

	local nIsCanDoTarget, szErrorMsg = Task:IsCanDoTargetSpeCondition(pPlayer, self.tbTask.nTaskId, self.tbTask.nCurStep);
	if (nIsCanDoTarget ~= 1) then
		TaskAct:Talk(szErrorMsg);
		return;
	end
	
	if (self.nMapId ~= 0 and self.nMapId ~= pPlayer.GetMapId()) then
		TaskAct:Talk("Không phải bản đồ ngươi muốn tìm"..self.szNpcName.."Hãy đến "..self.szMapName)
		return;
	end;
	if (self:IsDone()) then
		if (self.szRepeatMsg) then
			TaskAct:Talk(self.szRepeatMsg);
		end;
		return;
	end;
	TaskAct:Talk(self.szMsg, self.OnTalkFinish, self);
end;

function tb:OnTalkFinish()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	self.bDone	= 1;
	local tbSaveTask	= self.tbSaveTask;
	if (MODULE_GAMESERVER and tbSaveTask) then	-- 自行同步到客户端，要求客户端刷新
		pPlayer.SetTask(tbSaveTask.nGroupId, tbSaveTask.nStartTaskId, self.bDone, 1);
		KTask.SendRefresh(pPlayer, self.tbTask.nTaskId, self.tbTask.nReferId, tbSaveTask.nGroupId);
	end;
	pPlayer.Msg("Mục tiêu:"..self:GetStaticDesc());
	
	if (not self.szRepeatMsg) then
		self:UnRegister()	-- 本目标是一旦达成后不会失效的
	end;
	
	self.tbTask:OnFinishOneTag();
end;

