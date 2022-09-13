
-- 和指定的Npc对话可完成任务和talknpc目标一样，但这个指定的Npc要击败一个指定战斗Npc才能出来。
-- 指定对话Npc出来一段时间会被删掉，然后这个时候战斗Npc会被添加
local tb	= Task:GetTarget("FightNpc2DialogNpc");
tb.szTargetName	= "FightNpc2DialogNpc";


-- 地图Id,战斗Npc模板,对话Npc模板,对话选项,对话内容,重复对话，对话Npc持续时间,目标完成前泡泡，目标完成后泡泡
function tb:Init(nMapId, nMapPosX, nMapPosY, nFightNpcTempId, nFightNpcLevel, nDialogNpcTempId, szOption, szMsg, szRepeatMsg, nDialogDuration, szStaticDesc, szDynamicDesc, szBeforePop, szLaterPop)
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
	self.szStaticDesc		= szStaticDesc;
	self.szDynamicDesc		= szDynamicDesc;
	self.szBeforePop		= szBeforePop;		-- 当mapid为0时，该值表示maptype，用来支持在多副本地图里面的npc战斗转对话
	self.szLaterPop			= szLaterPop;
	self:IniTarget();
end;


---------------------------------------------------------------------
function tb:IniTarget()
	if (MODULE_GAMESERVER) then
		if (self.nMapId == 0 ) then
			assert(self.szBeforePop);
			local tbMapId = Map.tbTypeMap[self.szBeforePop] or {};
			self.tbMapEnv = {};
			for i, v in pairs(tbMapId) do
				if (IsMapLoaded(v) == 1) then
					self.tbMapEnv[v] = {};
				end			
			end
		else
			self.tbMapEnv = {};
			self.tbMapEnv[self.nMapId] = {};
		end
			
		if (not self.bAddFight or self.bAddFight == 0) then
			for nMapId, tbEnv in pairs(self.tbMapEnv) do			
				local pFightNpc	= KNpc.Add2(self.nFightNpcTempId, self.nFightNpcLevel, -1, nMapId, self.nMapPosX, self.nMapPosY);
				if (not pFightNpc) then
					return;
				end
				tbEnv.nFightNpcId = pFightNpc.dwId;
				Npc:RegPNpcOnDeath(pFightNpc, self.OnDeath, self);
			end
			Timer:Register(Env.GAME_FPS * 60, self.OnCheckNpcExist, self);
			self.bAddFight = 1; -- 确保只添加一次
		end
	end
end;


-- 用于防止意外造成Npc丢失
function tb:OnCheckNpcExist()
	for nMapId, tbEnv in pairs(self.tbMapEnv) do
		if (Task:IsNpcExist(tbEnv.nDialogNpcId, self) == 1) then
			return;
		end
		if (Task:IsNpcExist(tbEnv.nFightNpcId, self) == 1) then
			return;
		end
		if (tbEnv.nReviveDurationTimeId) then
			return;
		end
		
		print("TaskNpcMiss", tbEnv.nDialogNpcId, tbEnv.nFightNpcId, tbEnv.nReviveDurationTimeId);
		tbEnv.nDialogNpcId = nil;
		tbEnv.nFightNpcId  = nil;
		
		self:AddFightNpc(nMapId);
	end
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
	return self.szDynamicDesc or "";
end;


function tb:GetStaticDesc()
	return self.szStaticDesc or "";
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
		TaskAct:Talk("你要找的不是本地图的"..self.szDialogNpcName.."请前往"..self.szMapName)
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
	assert(self.tbMapEnv[pFightNpc.nMapId]);	
	local tbEnv = self.tbMapEnv[pFightNpc.nMapId];
	
	-- 在战斗Npc的位置添加对话Npc
	local nCurMapId, nCurPosX, nCurPosY = pFightNpc.GetWorldPos();
	local pDialogNpc = KNpc.Add2(self.nDialogNpcTempId, 1, -1, nCurMapId, nCurPosX, nCurPosY);
	assert(pDialogNpc);
	tbEnv.nDialogNpcId = pDialogNpc.dwId;
	Task.tbToBeDelNpc[tbEnv.nDialogNpcId] = 1;
	-- 指定时间后删除对话Npc，并添加战斗Npc
	if (MODULE_GAMESERVER) then
		tbEnv.nReviveDurationTimeId = Timer:Register(Env.GAME_FPS * self.nDialogDuration, self.Dialog2Fight, self, nCurMapId);
	end;
end;


-- 对话转战斗
function tb:Dialog2Fight(nMapId)
	assert(not self.nFightNpcId);
	assert(self._tbBase)
	assert(self._tbBase._tbBase == nil)
	assert(MODULE_GAMESERVER);
	assert(self.tbMapEnv[nMapId]);	
	local tbEnv = self.tbMapEnv[nMapId];
	
	-- 避免下面assert造成重复调用
	if (not tbEnv.nReviveDurationTimeId) then
		return 0;
	end
	
	tbEnv.nReviveDurationTimeId = nil;
	
	-- 删除这个对话Npc
	if (tbEnv.nDialogNpcId) then
		local pDialogNpc = KNpc.GetById(tbEnv.nDialogNpcId);
		assert(pDialogNpc);
		Task.tbToBeDelNpc[tbEnv.nDialogNpcId] = 0;
		pDialogNpc.Delete();
		tbEnv.nDialogNpcId = nil;
	else
		assert(false);
	end
	
	self:AddFightNpc(nMapId);
	
	return 0;
end;

-- 添加一个战斗Npc
function tb:AddFightNpc(nMapId)
	assert(not self.nDialogNpcId);
	assert(not self.nFightNpcId);
	assert(not self._tbBase._tbBase);
	assert(self._tbBase);
	assert(self.tbMapEnv[nMapId]);	
	local tbEnv = self.tbMapEnv[nMapId];
		
	local pFightNpc	= KNpc.Add2(self.nFightNpcTempId, self.nFightNpcLevel, -1, nMapId, self.nMapPosX, self.nMapPosY);
	assert(pFightNpc);	
	tbEnv.nFightNpcId = pFightNpc.dwId; 
	Npc:RegPNpcOnDeath(pFightNpc, self.OnDeath, self);
end


-- OnDeath处于tb._tbBase环境
function tb:OnDeath()
	assert(self._tbBase)
	assert(not self._tbBase._tbBase)
	assert(self.tbMapEnv[him.nMapId]);
	
	local tbEnv = self.tbMapEnv[him.nMapId];
	
	if (tbEnv.nFightNpcId and him.dwId == tbEnv.nFightNpcId) then
		tbEnv.nFightNpcId = nil;
		self:RiseDialogNpc(him);
	else
		assert(false);
	end
end;
