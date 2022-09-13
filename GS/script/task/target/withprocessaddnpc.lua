--- 进度条目标
local tb	= Task:GetTarget("WithProcessAddNpc");
tb.szTargetName	= "WithProcessAddNpc";
tb.REFRESH_FRAME	= 18;

function tb:Init(nNpcTempId, nMapId, nMapX, nMapY, nIntervalTime, nFightNpcId, nFightNpcLevel, szPos, nNeedCount, szDynamicDesc, szStaticDesc)
	self.nNpcTempId			= nNpcTempId;
	self.szNpcName			= KNpc.GetNameByTemplateId(nNpcTempId);
	self.nMapId				= nMapId;
	self.szMapName			= Task:GetMapName(nMapId);
	self.nMapX				= nMapX;
	self.nMapY				= nMapY;
	self.nIntervalTime		= nIntervalTime * self.REFRESH_FRAME;
	
	self.szProcessInfo		= "进行中";
	self.szSucMsg			= "成功";
	self.szFailedMsg		= "失败";
	
	self.nFightNpcId		= nFightNpcId;
	self.nFightNpcLevel		= nFightNpcLevel;
	self.tbNpcPos			= self:ParsePos(szPos);
	self.nNeedCount			= nNeedCount;
	
	self.szDynamicDesc		= szDynamicDesc;
	self.szStaticDesc	  	= szStaticDesc;

	self:IniTarget();
end;

function tb:IniTarget()
	if (MODULE_GAMESERVER) then
		if (not self.bExist or self.bExist == 0) then
			local pProcessNpc = KNpc.Add2(self.nNpcTempId, self.nFightNpcLevel, -1, self.nMapId, self.nMapX, self.nMapY);
			if (not pProcessNpc) then
				return;
			end
			self.nProcessNpcId = pProcessNpc.dwId;
			Timer:Register(Env.GAME_FPS * 60, self.OnCheckNpcExist, self);
			self.bExist = 1; -- 只添加一次
		end
		
	end
end;

-- 用于防止意外造成Npc丢失
function tb:OnCheckNpcExist()
	if (Task:IsNpcExist(self.nProcessNpcId, self) == 1) then
		return;
	end
	
	if (self.nReviveDurationTimeId) then
		return;
	end
	
	print("TaskNpcMiss", self.nDialogNpcId, self.nReviveDurationTimeId);
	print(debug.traceback());
	
	self.nProcessNpcId = nil;
	
	if (MODULE_GAMESERVER) then
		self.nReviveDurationTimeId = Timer:Register(Env.GAME_FPS * self.nDeathDuration, self.AddProcessNpc, self);
	end;
end

-- 添加一个对话Npc
function tb:AddProcessNpc()
	assert(not self.nFightNpcId);
	
	-- 避免下面assert造成重复调用
	if (not self.nReviveDurationTimeId) then
		return 0;
	end

	self.nReviveDurationTimeId = nil;
	
	local pProcessNpc = KNpc.Add2(self.nNpcTempId, self.nFightNpcLevel, -1, self.nMapId, self.nMapX, self.nMapY);
	assert(pProcessNpc);
	
	self.nProcessNpcId = pProcessNpc.dwId;
	Task.tbToBeDelNpc[self.nProcessNpcId] = 1;
	return 0;
end

function tb:ParsePos(szPos)
	local tbRet = {};
	
	if (szPos and szPos ~= "") then
		local tbTrack = Lib:SplitStr(szPos, "\n")
		for i=1, #tbTrack do
			if (tbTrack[i] and tbTrack[i] ~= "") then
				tbRet[i] = {};
				local tbPos = Lib:SplitStr(tbTrack[i]);
				tbRet[i].nX = tonumber(tbPos[1]);
				tbRet[i].nY = tonumber(tbPos[2]);
			end
		end
	end
	
	return tbRet;
end

function tb:Start()
	self.nCount = 0;
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
	if (not self:IsDone()) then	-- 本目标是一旦达成后不会失效的
		self:Register();
	end;
	
	return 1;
end;


function tb:IsDone()
	return self.nCount >= self.nNeedCount;
end;


function tb:GetDesc()
	local bHasTag = 0;
	local bTagStart, bTagEnd = string.find(self.szDynamicDesc, "%%d");
	if (bTagEnd) then
		bHasTag = bHasTag + 1;	
		bTagStart, bTagEnd = string.find(self.szDynamicDesc, "%%d", bTagEnd + 1);
		if (bTagEnd) then
			bHasTag = bHasTag + 1;
		end
	end
	
	if (bHasTag == 1) then
		return string.format(self.szDynamicDesc, self.nCount);
	elseif (bHasTag == 2) then
		return string.format(self.szDynamicDesc, self.nCount, self.nNeedCount);
	else
		return self.szDynamicDesc;
	end
end;


function tb:GetStaticDesc()
	return self.szStaticDesc;
end;




function tb:Close(szReason)
	self:UnRegister();
end;


function tb:Register()
	self.tbTask:AddExclusiveDialog(self.nNpcTempId, self.SelectOpenBox, self);
end;

function tb:UnRegister()
	self.tbTask:RemoveNpcExclusiveDialog(self.nNpcTempId);
end;


-- 玩家选择开
function tb:SelectOpenBox()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	if (self.nMapId ~= 0 and self.nMapId ~= pPlayer.GetMapId()) then
		print(self.nMapId, pPlayer.GetMapId());
		pPlayer.Msg("你要开启的不是本地图的"..self.szNpcName.."请前往"..self.szMapName)
		return;
	end;

	if (self:IsDone()) then
		pPlayer.Msg(self.szFailedMsg)
		return;
	end;

	self.nCurTagIdx = him.dwId;

	Task:SetProgressTag(self, pPlayer);
	KTask.StartProgressTimer(pPlayer, self.nIntervalTime, self.szProcessInfo);
end;


function tb:OnProgressFull()
	self:AddFightNpc();
end;

function tb:AddFightNpc()	
	local tbNpcList = KNpc.GetMapNpcWithName(self.nMapId, KNpc.GetNameByTemplateId(self.nFightNpcId));
	if (tbNpcList and #tbNpcList > self.nNeedCount * 2) then
		return; -- 最多存在2倍的
	end;
	
	for i = 1, #self.tbNpcPos do
		local pNpc = KNpc.Add2(self.nFightNpcId, self.nFightNpcLevel, -1, self.nMapId, self.tbNpcPos[i].nX, self.tbNpcPos[i].nY);
		if (not pNpc or pNpc.nIndex == 0) then
			print("[Task Error]:"..self.nNpcTempId.."  添加失败！");
		end;
	end;
end;

function tb:OnKillNpc(pPlayer, pNpc)
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	if (self:IsDone()) then
		return;
	end;
	if (self.nFightNpcId ~= pNpc.nTemplateId) then
		return;
	end;
	
	if (self.nMapId ~= 0 and self.nMapId ~= pPlayer.GetMapId()) then
		return;
	end;
	
	self.nCount	= self.nCount + 1;
	
	
	local tbSaveTask	= self.tbSaveTask;
	if (MODULE_GAMESERVER and tbSaveTask) then	-- 自行同步到客户端，要求客户端刷新
		pPlayer.SetTask(tbSaveTask.nGroupId, tbSaveTask.nStartTaskId, self.nCount, 1);
		KTask.SendRefresh(pPlayer, self.tbTask.nTaskId, self.tbTask.nReferId, tbSaveTask.nGroupId);
	end;
	
	if (self:IsDone()) then	-- 本目标是一旦达成后不会失效的
		pPlayer.Msg("Mục tiêu: "..self:GetStaticDesc());
		self.tbTask:OnFinishOneTag();
	end;
end;