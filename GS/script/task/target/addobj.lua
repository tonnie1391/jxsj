
-- 文件载入的时候可以在Task.tbTargetLib中载入这个目标
local tb	= Task:GetTarget("AddObj");
tb.szTargetName	= "AddObj";

function tb:Init(tbItemId, nNpcTempId, szNewName, nMapId, nPosX, nPosY, nR, szPosName, szMsg)
	if (tbItemId[1] ~= 20) then
		print("[Task Error]"..self.szTargetName.."  没有使用任务道具！")
	end
	self.tbItemId	= tbItemId;
	self.szItemName	= KItem.GetNameById(unpack(tbItemId));
	self.nParticular= tbItemId[3];
	self.nNpcTempId	= nNpcTempId;
	assert(nNpcTempId > 0);
	self.szNpcName	= KNpc.GetNameByTemplateId(nNpcTempId);
	self.szNewName	= szNewName;
	self.nMapId		= nMapId;
	self.nPosX		= nPosX;
	self.nPosY		= nPosY;
	self.nR			= nR;
	self.szPosName	= szPosName;
	if (self.szMsg ~= "") then
		self.szMsg	= szMsg;
	end;
end;

function tb:Start()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	self.bDone		= 0;
	self:Register();
	if (MODULE_GAMESERVER) then	-- 服务端看情况添加物品
		if (Task:GetItemCount(pPlayer, self.tbItemId) <= 0) then
			Task:AddItem(pPlayer, self.tbItemId);
		end
	end
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
		self:Register();
		if (MODULE_GAMESERVER) then	-- 服务端看情况添加物品
			if (Task:GetItemCount(pPlayer, self.tbItemId) <= 0) then
				Task:AddItem(pPlayer, self.tbItemId);
			end
		end
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
	return string.format("Đem %s để ở %s", self.szNpcName, self.szPosName);
end;

function tb:Close(szReason)
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	self:UnRegister();
	if (MODULE_GAMESERVER) then	-- 服务端看情况删除物品，完成的话在完成瞬间删
		if (szReason == "giveup" or szReason == "failed") then
			Task:DelItem(pPlayer, self.tbItemId, 1);
		end;
	end;
end;


function tb:Register()
	self.tbTask:AddItemUse(self.nParticular, self.OnItem, self)
end;

function tb:UnRegister()
	self.tbTask:RemoveItemUse(self.nParticular);
end;

function tb:OnItem()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	if (self:IsDone()) then
		return nil;
	end;
	Setting:SetGlobalObj(pPlayer);
	local bAtPos, szMsg	= TaskCond:IsAtPos(self.nMapId, self.nPosX, self.nPosY, self.nR);
	if (not bAtPos) then
		me.Msg(szMsg);
		Setting:RestoreGlobalObj();
		return 1;
	end;
	
	-- 开始进度条计时
	local tbEvent = {
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SIT,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,		
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
	}
	
	GeneralProcess:StartProcess("", 180, {self.OnProgressFull, self}, nil, tbEvent)
	Setting:RestoreGlobalObj();
end;


function tb:OnProgressFull()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	Setting:SetGlobalObj(pPlayer);
	local pNpc = TaskAct:AddObj(self.nNpcTempId, self.szNewName);
	Setting:RestoreGlobalObj();
	
	Timer:Register(2 * 60 *Env.GAME_FPS, self.DelNpc, self, pNpc.dwId);
	Task:DelItem(pPlayer, self.tbItemId);
	
	self.bDone	= 1;
	
	local tbSaveTask	= self.tbSaveTask;
	if (MODULE_GAMESERVER and tbSaveTask) then	-- 自行同步到客户端，要求客户端刷新
		pPlayer.SetTask(tbSaveTask.nGroupId, tbSaveTask.nStartTaskId, self.bDone, 1);
		KTask.SendRefresh(pPlayer, self.tbTask.nTaskId, self.tbTask.nReferId, tbSaveTask.nGroupId);
	end;
	
	pPlayer.Msg("Mục tiêu: "..self:GetStaticDesc());
	self:UnRegister()	-- 本目标是一旦达成后不会失效的
	if (self.szMsg) then
		pPlayer.Msg(self.szMsg);
	end;
	
	self.tbTask:OnFinishOneTag();
	 
	return 0;
end


function tb:DelNpc(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end
	pNpc.Delete();
	return 0;
end
