-- 和指定的Npc对话可完成任务和talknpc目标一样，但这个指定的Npc要击败一个指定战斗Npc才能出来。
-- 指定对话Npc出来一段时间会被删掉，然后这个时候战斗Npc会被添加

local tb	= Task:GetTarget("Fight2Dialog");
tb.szTargetName	= "Fight2Dialog";


-- 地图Id,战斗Npc模板,对话Npc模板,对话选项,对话内容,重复对话，对话Npc持续时间,目标完成前泡泡，目标完成后泡泡
function tb:Init(nMapId, nMapPosX, nMapPosY, nFightNpcTempId, nFightNpcLevel, nDialogNpcTempId, szOption, szMsg, szRepeatMsg, nDialogDuration, szBeforePop, szLaterPop)
	self.nMapId				= nMapId;
	self.szMapName			= Task:GetMapName(nMapId);
	self.nMapPosX			= nMapPosX;
	self.nMapPosY			= nMapPosY;
	self.nFightNpcTempId	= nFightNpcTempId;
	self.szFightNpcName		= KNpc.GetNameByTemplateId(nFightNpcTempId);
	self.nFightNpcLevel		= nFightNpcLevel;
	self.nDialogNpcTempId	= nDialogNpcTempId;
	self.szDialogNpcName	= KNpc.GetNameByTemplateId(nDialogNpcTempId);
	self.szOption			= szOption;
	self.szMsg				= szMsg;
	self.szRepeatMsg		= szRepeatMsg;
	self.nDialogDuration	= nDialogDuration;
	self.szBeforePop		= szBeforePop;
	self.szLaterPop			= szLaterPop;
	self:IniTarget();
end;


---------------------------------------------------------------------
function tb:IniTarget()
	if (MODULE_GAMESERVER) then
		if (not self.bAddFight or self.bAddFight == 0) then
			local pFightNpc	= KNpc.Add2(self.nFightNpcTempId, self.nFightNpcLevel, -1, self.nMapId, self.nMapPosX, self.nMapPosY);
			if (not pFightNpc) then
				return;
			end
			self.nFightNpcId = pFightNpc.dwId;
			Npc:RegPNpcOnDeath(pFightNpc, self.OnDeath, self);
			Timer:Register(Env.GAME_FPS * 60, self.OnCheckNpcExist, self);
			self.bAddFight = 1; -- 确保只添加一次
		end
	end
end;

-- 用于防止意外造成Npc丢失
function tb:OnCheckNpcExist()
	if (Task:IsNpcExist(self.nDialogNpcId, self) == 1) then
		return;
	end
	
	if (Task:IsNpcExist(self.nFightNpcId, self) == 1) then
		return;
	end
	if (self.nReviveDurationTimeId) then
		return;
	end
	
	print("TaskNpcMiss", self.nDialogNpcId, self.nFightNpcId, self.nReviveDurationTimeId);
	self.nDialogNpcId = nil;
	self.nFightNpcId  = nil;
	
	self:AddFightNpc();
end


-- 第一个开启这个目标的玩家会注册一个战斗Npc，之后则是它的轮回
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
		assert(self._tbBase._tbBase)
	end;
	return 1;
end;

function tb:IsDone()
	return self.bDone == 1;
end;

function tb:GetDesc()
	return self:GetStaticDesc();
end;

function tb:GetStaticDesc()
	local szMsg = "Hạ gục ";
	szMsg = szMsg..self.szFightNpcName.." sau đó ";
	
	szMsg = szMsg.." với ";
	if (self.nMapId ~= 0) then
		szMsg	= szMsg..self.szMapName.." - ";
	end;
	szMsg	= szMsg..string.format(" %s đối thoại", self.szDialogNpcName);
	return szMsg;
end;

function tb:Close(szReason)
	self:UnRegister();
end;


function tb:Register()
	assert(self._tbBase._tbBase)
	
	self.tbTask:AddNpcMenu(self.nDialogNpcTempId, self.nMapId, self.szOption, self.OnTalkNpc, self);
end;

function tb:UnRegister()
	assert(self._tbBase._tbBase)
	
	self.tbTask:RemoveNpcMenu(self.nDialogNpcTempId);
end;


function tb:OnTalkNpc()
	if (not him) then
		return;
	end;
	
	assert(self._tbBase._tbBase)
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	if (self.nMapId ~= 0 and self.nMapId ~= pPlayer.GetMapId()) then
		TaskAct:Talk("Không phải bản đồ ngươi muốn tìm"..self.szDialogNpcName.."Xin hãy đến "..self.szMapName)
		return;
	end
		
	if (self:IsDone()) then
		if (self.szRepeatMsg) then
			TaskAct:Talk(self.szRepeatMsg);
		end
		
		return;
	end
	
	TaskAct:Talk(self.szMsg, self.OnTalkFinish, self);
end



function tb:OnTalkFinish()
	assert(self._tbBase._tbBase)
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
	pPlayer.Msg("Mục tiêu: "..self:GetStaticDesc());
	
	self.tbTask:OnFinishOneTag();
	
	if (not self.szRepeatMsg) then
		self:UnRegister()	-- 本目标是一旦达成后不会失效的
	end;
end;


function tb:RiseDialogNpc(pFightNpc)
	assert(self._tbBase)
	assert(self._tbBase._tbBase == nil)
	
	-- 在战斗Npc的位置添加对话Npc
	local nCurMapId, nCurPosX, nCurPosY = pFightNpc.GetWorldPos();
	local pDialogNpc = KNpc.Add2(self.nDialogNpcTempId, 1, -1, nCurMapId, nCurPosX, nCurPosY);
	assert(pDialogNpc);
	self.nDialogNpcId = pDialogNpc.dwId;
	Task.tbToBeDelNpc[self.nDialogNpcId] = 1;
	-- 指定时间后删除对话Npc，并添加战斗Npc
	if (MODULE_GAMESERVER) then
		self.nReviveDurationTimeId = Timer:Register(Env.GAME_FPS * self.nDialogDuration, self.Dialog2Fight, self);
	end;
end;


-- 对话转战斗
function tb:Dialog2Fight()
	assert(not self.nFightNpcId);
	assert(self._tbBase)
	assert(self._tbBase._tbBase == nil)
	assert(MODULE_GAMESERVER);
	-- 避免下面assert造成重复调用
	if (not self.nReviveDurationTimeId) then
		return 0;
	end
	
	self.nReviveDurationTimeId = nil;
	
	-- 删除这个对话Npc
	if (self.nDialogNpcId) then
		local pDialogNpc = KNpc.GetById(self.nDialogNpcId);
		assert(pDialogNpc);
		Task.tbToBeDelNpc[self.nDialogNpcId] = 0;
		pDialogNpc.Delete();
		self.nDialogNpcId = nil;
	else
		assert(false);
	end
	
	self:AddFightNpc();
	return 0;
end;

-- 添加一个战斗Npc
function tb:AddFightNpc()
	assert(not self.nDialogNpcId);
	assert(not self.nFightNpcId);
	assert(not self._tbBase._tbBase);
	assert(self._tbBase);
	
	local pFightNpc	= KNpc.Add2(self.nFightNpcTempId, self.nFightNpcLevel, -1, self.nMapId, self.nMapPosX, self.nMapPosY);
	assert(pFightNpc);	
	self.nFightNpcId = pFightNpc.dwId; 
	Npc:RegPNpcOnDeath(pFightNpc, self.OnDeath, self);
end


-- OnDeath处于tb._tbBase环境
function tb:OnDeath()
	assert(self._tbBase)
	assert(not self._tbBase._tbBase)
	
	if (self.nFightNpcId and him.dwId == self.nFightNpcId) then
		self.nFightNpcId = nil;
		self:RiseDialogNpc(him);
	else
		assert(false);
	end
end;
