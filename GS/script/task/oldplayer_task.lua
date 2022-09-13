
Require("\\script\\task\\task.lua");

Task.OldPlayerTask = Task.OldPlayerTask or {};
local tbOldPlayerTask = Task.OldPlayerTask;

tbOldPlayerTask.OLDPLAYER_TASK_ID		= 349;
tbOldPlayerTask.OLDPLAYER_REFERID		= 524;

tbOldPlayerTask.NORMALPLAYER_TASK_ID 	= 350;
tbOldPlayerTask.NORMALPLAYER_REFREID	= 525;

tbOldPlayerTask.tbTaskTarget			= {
		20,
		7,
		1,
		1,
		1,
	}

function tbOldPlayerTask:CheckCondition(tbMemberList)
	local nHaveOldPlayer 		= 0;
	local nHaveNormalPlayer 	= 0;
	for _, player in ipairs(tbMemberList) do 
		if (self:IsOldPlayer(player)) then
			nHaveOldPlayer = 1;
		else
			nHaveNormalPlayer = 1;
		end;
	end;
	if (nHaveNormalPlayer == 1 and nHaveOldPlayer == 1) then
		return 1;
	end;	
	return 0;
end;

function tbOldPlayerTask:CheckTask(tbMemberList, nGroupId, nTaskId)
	local nHaveOldPTask 	= 0;
	local nHaveNormalPTask 	= 0;
	for _, player in ipairs(tbMemberList) do
		local tbPlayerTasks	= Task:GetPlayerTask(player).tbTasks;	 
		if (self:IsOldPlayer(player)) then
			local tbTask = tbPlayerTasks[self.OLDPLAYER_TASK_ID];
			local nValue = player.GetTask(nGroupId, nTaskId);
			if (tbTask and tbTask.nReferId == self.OLDPLAYER_REFERID and nValue < self.tbTaskTarget[nTaskId]) then
				nHaveOldPTask = 1;
			end;
		end;
		if (not self:IsOldPlayer(player)) then
			local tbTask = tbPlayerTasks[self.NORMALPLAYER_TASK_ID];
			local nValue = player.GetTask(nGroupId, nTaskId);
			if (tbTask and tbTask.nReferId == self.NORMALPLAYER_REFREID and nValue < self.tbTaskTarget[nTaskId]) then
				nHaveNormalPTask = 1;
			end;		
		end;
	end;
	if (nHaveOldPTask == 1 and nHaveNormalPTask == 1) then
		return 1;
	end;
	return 0;
end;

function tbOldPlayerTask:AddPlayerTaskValue(nPlayerId, nGroupId, nTaskId)
	if (not nPlayerId or not nGroupId or not nTaskId) then
		assert(false);
		return;
	end;
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer or not pPlayer.nTeamId) then
		return;
	end;

	local tbMemberList, _ = pPlayer.GetTeamMemberList();
	if (not tbMemberList) then
		return;
	end;
	if (self:CheckCondition(tbMemberList) ~= 1 or self:CheckTask(tbMemberList, nGroupId, nTaskId) ~= 1) then
		return;
	end;
	if (nTaskId >= 3) then
		for _, player in ipairs(tbMemberList) do
			self:AddValue(player.nId, nGroupId, nTaskId);
		end;
	else
		self:AddValue(nPlayerId, nGroupId, nTaskId);
	end;
end;

function tbOldPlayerTask:AddValue(nPlayerId, nGroupId, nTaskId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);	
	local tbPlayerTasks	= Task:GetPlayerTask(pPlayer).tbTasks;
	if (self:IsOldPlayer(pPlayer)) then
		local tbTask = tbPlayerTasks[self.OLDPLAYER_TASK_ID];
		if (tbTask and tbTask.nReferId == self.OLDPLAYER_REFERID) then
			local nValue = pPlayer.GetTask(nGroupId, nTaskId);
			if (nValue <= 10) then
				pPlayer.SetTask(nGroupId, nTaskId, nValue + 1);
			end;
		end;	
	else
		local tbTask = tbPlayerTasks[self.NORMALPLAYER_TASK_ID];
		if (tbTask and tbTask.nReferId == self. NORMALPLAYER_REFREID) then
			local nValue = pPlayer.GetTask(nGroupId, nTaskId);
			if (nValue <= 10) then
				pPlayer.SetTask(nGroupId, nTaskId, nValue + 1);
			end;
		end;
	end;
end;

function tbOldPlayerTask:IsOldPlayer(pPlayer)
	assert(pPlayer);
	Setting:SetGlobalObj(pPlayer);
	local bOld = (EventManager.ExEvent.tbPlayerCallBack:CheckPlayer() == 1);
	Setting:RestoreGlobalObj();
	return bOld;
end;