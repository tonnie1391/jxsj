
local tb	= Task:GetTarget("ProtectNpc");
tb.szTargetName		= "ProtectNpc";
tb.REFRESH_FRAME 	= 18;
--tb.CHIEFSKILLID		= 100; -- 护送负责人的技能Id,目标关闭的时候关闭，开始的时候加载

--参数说明
--对话Npc模板Id, 刷对话Npc时间间隔,对话选项,对话内容,行走Npc模板Id,行走Npc等级,地图Id,玩家能离开的最远距离,目标点x坐标,目标点y坐标,目标半径,行走路线,完成前泡泡，完成后泡泡
function tb:Init(nDialogNpcTempId, nMapPosX, nMapPosY, nInterval, szOption, szMsg, nMoveNpcTempId, nMoveNpcLevel, nMapId, nMaxDistance, nLimitTime, nAimX, nAimY, nAimR, szTrack, szBeforePop, strRszLaterPop, nAttartRate)
	self.nDialogNpcTempId	= nDialogNpcTempId;
	self.nMapPosX			= nMapPosX;
	self.nMapPosY			= nMapPosY;
	self.nInterval			= nInterval;
	self.szDialogNpcName	= KNpc.GetNameByTemplateId(nDialogNpcTempId);
	self.szOption			= szOption;
	self.szMsg				= szMsg;
	self.nMoveNpcTempId		= nMoveNpcTempId;
	self.szMoveNpcName		= KNpc.GetNameByTemplateId(nMoveNpcTempId)
	self.nMoveNpcLevel		= nMoveNpcLevel;
	self.nMapId				= nMapId;
	self.szMapName			= Task:GetMapName(nMapId);
	self.nMaxDistance		= nMaxDistance;
	self.nLimitTime			= nLimitTime;
	self.nAimX				= nAimX;
	self.nAimY				= nAimY;
	self.nAimR				= nAimR;
	self.tbTrack			= self:ParseTrack(szTrack);
	self.szBeforePop		= szBeforePop;			-- 当mapid为0时，该值表示maptype，用来支持在多副本地图里面的npc护送
	self.szLaterPop			= szLaterPop;
	self.nAttartRate 		= tonumber(nAttartRate) or 20;
	self:IniTarget();
end;


-- 解析行走字符串
function tb:ParseTrack(szTrack)
	if (not szTrack or szTrack == "") then
		return;
	end
	
	local tbRet = {};
	local tbTrack = Lib:SplitStr(szTrack, "\n")
	for i=1, #tbTrack do
		if (tbTrack[i] and tbTrack[i] ~= "") then
			local tbPos = Lib:SplitStr(tbTrack[i]);
			table.insert(tbRet, tbPos);
		end
	end
	
	return tbRet;
end


function tb:IniTarget()
	if (MODULE_GAMESERVER) then		
		if (not self.bStart) then
			if (self.nMapId == 0 ) then
				assert(self.szBeforePop);
				local tbMapId = Map.tbTypeMap[self.szBeforePop];
				self.tbMapEnv = {};
				for i, v in pairs(tbMapId or {}) do
					if (IsMapLoaded(v) == 1) then
						self.tbMapEnv[v] = {};
					end			
				end
			else
				self.tbMapEnv = {};
				self.tbMapEnv[self.nMapId] = {};
			end
		
			for nMapId, tbEnv in pairs(self.tbMapEnv) do
				local pDialogNpc = KNpc.Add2(self.nDialogNpcTempId, 1, -1, nMapId, self.nMapPosX, self.nMapPosY);
				if (not pDialogNpc) then
					return;
				end
				tbEnv.nDialogNpcId = pDialogNpc.dwId;
			end
			Timer:Register(Env.GAME_FPS * 60, self.OnCheckNpcExist, self);
			self.bStart = true;
		end
	end
end;

-- 用于防止意外造成Npc丢失
function tb:OnCheckNpcExist()
	for nMapId, tbEnv in pairs(self.tbMapEnv) do
		if (Task:IsNpcExist(tbEnv.nDialogNpcId, self) == 1) then
			return;
		end
		
		if (tbEnv.nReviveDurationTimeId) then
			return;
		end
		
		tbEnv.nDialogNpcId = nil;
		tbEnv.nReviveDurationTimeId = nil;
		
		self:AddDialogNpc(nMapId);
	end
end

-- 开始的时候
function tb:Start()
	self.bDone = 0;
	self:RegisterTalk();
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
	self.bDone	= pPlayer.GetTask(nGroupId, nStartTaskId);
	
	if (not self:IsDone()) then	-- 本目标是一旦达成后不会失效的
		self:RegisterTalk();
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
	return "Hộ tống "..self.szMoveNpcName;
end;


function tb:Close(szReason)
	self:UnReg_Npc_RunTimer();
	self:UnRegisterTalk();
	
	if (self.nMoveNpcId) then
		local pFightNpc = KNpc.GetById(self.nMoveNpcId);
		if (pFightNpc) then
			pFightNpc.Delete();
		end
	end
end;


-- 注册和Npc对话
function tb:RegisterTalk()
	self.tbTask:AddNpcMenu(self.nDialogNpcTempId, self.nMapId, self.szOption, self.OnTalkNpc, self);
end;

function tb:UnRegisterTalk()
	self.tbTask:RemoveNpcMenu(self.nDialogNpcTempId);
end;

function tb:OnTalkNpc()
	if (not him) then
		return;
	end;
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	
	local tbEnv = self.tbMapEnv[pPlayer.GetMapId()];
	if not tbEnv then
		TaskAct:Talk("您要找的"..self.szDialogNpcName.."不在本地图，请前往"..self.szMapName)
		return;
	end	
--	if (self.nMapId ~= 0 and self.nMapId ~= pPlayer.GetMapId()) then
--		TaskAct:Talk("您要找的"..self.szDialogNpcName.."不在本地图，请前往"..self.szMapName)
--		return;
--	end;

	Setting:SetGlobalObj(pPlayer);
	TaskAct:Talk(self.szMsg, self.OnTalkFinish, self);
	Setting:RestoreGlobalObj();
	
--	self.nMyDialogNpcId = him.dwId;
end;

-- 对话完后会删除当前对话Npc,在指定地方刷一个行走Npc,并让他行走，并注册计时器，指定时间后再刷一个对话Npc
function tb:OnTalkFinish()
	--if (self.nMyDialogNpcId ~= self._tbBase.nDialogNpcId) then
	--	return;
	--end
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end	
	
	-- 对话转战斗
	self:Dialog2Fight();	 
	
	--注册计时器到时间删Npc，每秒看玩家离Npc的距离，若距离远则删除 
	self:Reg_Npc_RunTimer();
	
	-- 注册指定时间后刷对话Npc
	self._tbBase:RiseDialogNpc(pPlayer.nMapId);
end;


function tb:Dialog2Fight()
	assert(MODULE_GAMESERVER);
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	
	local tbEnv = self.tbMapEnv[pPlayer.GetMapId()];
	if not tbEnv then
		return;
	end
	
	if tbEnv.nDialogNpcId then
		local pDialogNpc = KNpc.GetById(tbEnv.nDialogNpcId);
		if (pDialogNpc) then
			--local nCurMapId, nCurPosX, nCurPosY = pDialogNpc.GetWorldPos();
			pDialogNpc.Delete(); 
		end
		tbEnv.nDialogNpcId = nil;
	end
	
	-- 删除之前领的
	if (self.nMoveNpcId) then
		local pFightNpc = KNpc.GetById(self.nMoveNpcId);
		
		if (pFightNpc) then
			pFightNpc.Delete();
			self.nMoveNpcId = nil;
		end
	end
	
	local pFightNpc	= KNpc.Add2(self.nMoveNpcTempId, self.nMoveNpcLevel, -1, pPlayer.GetMapId(), self.nMapPosX, self.nMapPosY, 0, 0, 1);
	assert(pFightNpc); 
	pFightNpc.SetCurCamp(0);
	local szTitle = "Đội của <color=yellow>"..pPlayer.szName.."<color> hộ tống";
	pFightNpc.SetTitle(szTitle);
	Npc:RegPNpcOnDeath(pFightNpc, self.OnDeath, self);
	self.nMoveNpcId = pFightNpc.dwId;
	
	pFightNpc.AI_ClearPath();
	for _,Pos in ipairs(self.tbTrack) do
		if (Pos[1] and Pos[2]) then
			pFightNpc.AI_AddMovePos(tonumber(Pos[1])*32, tonumber(Pos[2])*32)
		end
	end 
	
	pFightNpc.AI_AddMovePos(tonumber(self.nAimX)*32, tonumber(self.nAimY)*32);-- 终点为目标
	pFightNpc.SetNpcAI(9, self.nAttartRate, 1,-1, 25, 25, 25, 0, 0, 0, pPlayer.GetNpc().nIndex);	
end

function tb:RiseDialogNpc(nMapId)
	assert(self._tbBase)
	assert(not self._tbBase._tbBase)
	assert(self.tbMapEnv[nMapId]);
	local tbEnv = self.tbMapEnv[nMapId];
	
	if (MODULE_GAMESERVER) then
		tbEnv.nReviveDurationTimeId = Timer:Register(Env.GAME_FPS * self.nInterval, self.AddDialogNpc, self, nMapId);
	end;
end

-- 添加一个对话Npc
function tb:AddDialogNpc(nMapId)
	assert(self._tbBase);
	assert(not self._tbBase._tbBase);
	--assert(not self.nDialogNpcId);
	
	assert(self.tbMapEnv[nMapId]);
	local tbEnv = self.tbMapEnv[nMapId];
	
	if (tbEnv.nDialogNpcId) then
		return 0;
	end
	local pDialogNpc = KNpc.Add2(self.nDialogNpcTempId, 1, -1, nMapId, self.nMapPosX, self.nMapPosY);
	assert(pDialogNpc)
	
	tbEnv.nDialogNpcId = pDialogNpc.dwId;
	tbEnv.nReviveDurationTimeId = nil;
	return 0;
end


function tb:Reg_Npc_RunTimer()
	self.nRunElapseTime = 0;
	if (MODULE_GAMESERVER and not self.nRegisterRunTimerId) then
		self.nRegisterRunTimerId = Timer:Register(self.REFRESH_FRAME, self.OnRunTimer, self);
	end;
end;

function tb:UnReg_Npc_RunTimer()
	if (MODULE_GAMESERVER and self.nRegisterRunTimerId) then
		Timer:Close(self.nRegisterRunTimerId);
		self.nRegisterRunTimerId	= nil;
	end;
end;

-- 1.到指定时间删战斗Npc；2.每秒看玩家离Npc的距离，若距离远则删常 3.目标是否完成(和玩家走))
function tb:OnRunTimer()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	if (not self.nMoveNpcId) then
		self.nRegisterRunTimerId	= nil;
		return 0;
	end
	
	local pFightNpc = KNpc.GetById(self.nMoveNpcId);
	if (not pFightNpc) then
		self.nRegisterRunTimerId	= nil;
		return 0;
	end
	self.nRunElapseTime = self.nRunElapseTime + 1;
	if (self.nRunElapseTime > self.nLimitTime) then -- 到了指定时间，护送失败
		pFightNpc.Delete();
		pPlayer.Msg("Hộ tống "..self.szMoveNpcName.." thất bại, do không đáp ứng thời gian quy định.")
		self.nMoveNpcId = nil;
		self.nRegisterRunTimerId	= nil;
		return 0;
	else
		local nHimCurMapId, nHimCurPosX, nHimCurPosY = pFightNpc.GetWorldPos();
		Setting:SetGlobalObj(pPlayer);
		local bAtPos, szMsg	= TaskCond:IsAtPos(self.nMapId, nHimCurPosX, nHimCurPosY, self.nMaxDistance);
		Setting:RestoreGlobalObj();
		if (not bAtPos) then
			pFightNpc.Delete();
			pPlayer.Msg("Hộ tống "..self.szMoveNpcName.." thất bại, do khoảng cách quá xa.")
			self.nMoveNpcId = nil;
			self.nRegisterRunTimerId	= nil;
			return 0;
		end;

		Setting:SetGlobalObj(pPlayer);
		-- 判断到达目的地
		if (TaskCond:IsNpcAtPos(pFightNpc.dwId, self.nMapId, self.nAimX, self.nAimY, self.nAimR) or pFightNpc.AI_IsArrival() == 1) then
			self.bDone	=  1;
			self:ShareProtectNpc();
			local tbSaveTask	= self.tbSaveTask;
			if (MODULE_GAMESERVER and tbSaveTask) then	-- 自行同步到客户端，要求客户端刷新
				me.SetTask(tbSaveTask.nGroupId, tbSaveTask.nStartTaskId, self.bDone, 1);
				KTask.SendRefresh(me, self.tbTask.nTaskId, self.tbTask.nReferId, tbSaveTask.nGroupId);
			end;
			pFightNpc.Delete();
			self.nMoveNpcId = nil;
			self:UnReg_Npc_RunTimer();
			self.nRunElapseTime = 0;
		end;
		Setting:RestoreGlobalObj();
		
		if (self:IsDone()) then	-- 本目标是一旦达成后不会失效的
			pPlayer.Msg("Mục tiêu: "..self:GetStaticDesc());
			self:UnReg_Npc_RunTimer();
			self:UnRegisterTalk();
			self.tbTask:OnFinishOneTag();
			self.nRunElapseTime = 0;
			self.nRegisterRunTimerId	= nil;
			return 0
		end;
	end;
	
	return self.REFRESH_FRAME;
end;


function tb:ShareProtectNpc()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
-- 遍历所有队友所有任务的当前步骤的目标，若是和此目标相同则调用OnTeamMateKillNpc
	local tbTeamMembers, nMemberCount	= pPlayer.GetTeamMemberList();
	if (not tbTeamMembers) then --共享失败：没有组队
		return;
	end
	if (nMemberCount <= 0) then-- 共享失败：队伍没有成员
		return;
	end
	
	local nOldPlayerIndex = pPlayer.nPlayerIndex;
	for i = 1, nMemberCount do
		if (tbTeamMembers[i].nPlayerIndex ~= nOldPlayerIndex) then
			if (Task:AtNearDistance(tbTeamMembers[i], pPlayer) == 1) then
				for _, tbTask in pairs(Task:GetPlayerTask(tbTeamMembers[i]).tbTasks) do
					
					for _, tbCurTag in pairs(tbTask.tbCurTags) do
						
						if (tbCurTag.szTargetName == self.szTargetName) then
							if (tbCurTag.nMoveNpcTempId == self.nMoveNpcTempId and
								(tbCurTag.nMapId == 0 or tbCurTag.nMapId == self.nMapId)) then
								tbCurTag:OnTeamMateProtectNpc();
							end
						end
					end
				end
			end
		end
	end
end;


function tb:OnTeamMateProtectNpc()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	self.bDone  = 1;
	local tbSaveTask	= self.tbSaveTask;
	if (MODULE_GAMESERVER and tbSaveTask) then	-- 自行同步到客户端，要求客户端刷新
		pPlayer.SetTask(tbSaveTask.nGroupId, tbSaveTask.nStartTaskId, self.bDone, 1);
		KTask.SendRefresh(pPlayer, self.tbTask.nTaskId, self.tbTask.nReferId, tbSaveTask.nGroupId);
	end;
	if (self:IsDone()) then	-- 本目标是一旦达成后不会失效的
		pPlayer.Msg("Mục tiêu: "..self:GetStaticDesc());
		self:UnReg_Npc_RunTimer();
		self:UnRegisterTalk();
		self.tbTask:OnFinishOneTag();
	end;
end;


function tb:OnDeath()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	if (self:IsDone()) then
		return;
	end
	self.nMoveNpcId = nil;
	pPlayer.Msg(self.szMoveNpcName.." đã trọng thương, nhiệm vụ thất bại.");
end
