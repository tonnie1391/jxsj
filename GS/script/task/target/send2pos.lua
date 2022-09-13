
local tb			= Task:GetTarget("Send2Aim");
tb.szTargetName		= "Send2Aim";
tb.REFRESH_FRAME	= 18;


function tb:Init(nNpcTempId, nNpcMapId, szOption, szRepeat, nAimMapId,  nAimPosX, nAimPosY, nRange, 
	szMainInfo, szYesOpt, szCancelOpt, szStaticDesc, szDynamicDesc, szBeforePop, szLaterPop, nFightState)
	self.nNpcTempId			= nNpcTempId;
	self.szNpcName			= KNpc.GetNameByTemplateId(nNpcTempId);
	self.nNpcMapId			= nNpcMapId;
	self.szMapName			= Task:GetMapName(nNpcMapId);
	self.szOption			= szOption;
	self.szRepeat			= szRepeat;
	self.nAimMapId			= nAimMapId;
	self.nAimPosX			= nAimPosX;
	self.nAimPosY			= nAimPosY;
	self.nRange				= nRange;
	self.szMainInfo			= szMainInfo;
	self.szYesOpt			= szYesOpt;
	self.szCancelOpt		= szCancelOpt;
	self.szStaticDesc		= szStaticDesc;
	self.szDynamicDesc		= szDynamicDesc;
	self.szBeforePop		= szBeforePop;
	self.szLaterPop			= szLaterPop;
	self.nFightState		= tonumber(nFightState);
end;


function tb:Start()
	self.bDone		= 0;
	self:RegisterTalk();
	self:RegisterTimer();
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
	if (not self:IsDone()) then	-- 本目标是一旦达成后不会失效的
		self:RegisterTalk();
		self:RegisterTimer();
	elseif(self.szRepeatMsg) then
		self:RegisterTalk();
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
	self:UnRegisterTalk();
	self:UnRegisterTimer();
end;


function tb:RegisterTalk()
	self.tbTask:AddNpcMenu(self.nNpcTempId, self.nNpcMapId, self.szOption, self.OnTalkNpc, self);
end;

function tb:UnRegisterTalk()
	self.tbTask:RemoveNpcMenu(self.nNpcTempId);
end;

function tb:RegisterTimer()
	if (MODULE_GAMESERVER and not self.nRegisterId) then
		self.nRegisterId	= Timer:Register(self.REFRESH_FRAME, self.OnTimer, self);
	end;
end;

function tb:UnRegisterTimer()
	if (MODULE_GAMESERVER and self.nRegisterId) then
		Timer:Close(self.nRegisterId);
		self.nRegisterId	= nil;
	end;
end;

function tb:OnTimer(nTickCount)
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	Setting:SetGlobalObj(pPlayer);
	local bAtPos	= TaskCond:IsAtPos(self.nAimMapId, self.nAimPosX, self.nAimPosY, self.nRange);
	Setting:RestoreGlobalObj();
	
	if (not bAtPos) then
		return self.REFRESH_FRAME;
	end;
	self.bDone	= 1;
	local tbSaveTask	= self.tbSaveTask;
	if (MODULE_GAMESERVER and tbSaveTask) then	-- 自行同步到客户端，要求客户端刷新
		pPlayer.SetTask(tbSaveTask.nGroupId, tbSaveTask.nStartTaskId, self.bDone, 1);
		KTask.SendRefresh(pPlayer, self.tbTask.nTaskId, self.tbTask.nReferId, tbSaveTask.nGroupId);
	end;
	pPlayer.Msg("Mục tiêu: "..self:GetStaticDesc());
	self:UnRegisterTimer();
	if (not self.szRepeat) then
		self:UnRegisterTalk()	-- 本目标是一旦达成后不会失效的
	end;
	self.tbTask:OnFinishOneTag();
	return 0;	-- 关闭此Timer，本目标是一旦达成后不会失效的
end;

function tb:OnTalkNpc()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	if (self.nNpcMapId ~= 0 and self.nNpcMapId ~= pPlayer.GetMapId()) then
		TaskAct:Talk("你要找的不是本地图的"..self.szNpcName.."请前往"..self.szMapName)
		return;
	end;
	if (self:IsDone()) then
		return;
	end;
	
	self:StartSay();
end;


function tb:StartSay()
	Dialog:Say(self.szMainInfo,
			{
				{self.szYesOpt, tb.OnSelect, self},
				{self.szCancelOpt}
			});
end;

function tb:OnSelect()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	
	local nDstMapId = self.nAimMapId;
	if nDstMapId == 0 then
		nDstMapId = pPlayer.nMapId;
	end
	pPlayer.NewWorld(nDstMapId, self.nAimPosX, self.nAimPosY);
	
	if (self.nFightState) then
		pPlayer.SetFightState(self.nFightState);
	end
end
