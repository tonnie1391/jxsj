
local tb	= Task:GetTarget("GiveItemWithName");
tb.szTargetName	= "GiveItemWithName";

-- Npc模板Id, 对话选项，对话内容，物品列表,
function tb:Init(nNpcTempId, nMapId, szOption, szMsg, szRepeatMsg, tbItemSet, szBeforePop, szLaterPop, szDesc)
	self.nNpcTempId = nNpcTempId;
	self.nMapId		= nMapId;
	self.szMapName	= Task:GetMapName(nMapId);
	self.szNpcName	= KNpc.GetNameByTemplateId(nNpcTempId);
	self.szOption	= szOption;
	self.szMsg		= szMsg;
	if (szRepeatMsg ~= "") then
		self.szRepeatMsg	= szRepeatMsg;
	end;
	self:ParseItem(tbItemSet);
	self.szBeforePop	= szBeforePop;
	self.szLaterPop		= szLaterPop;
	self.szDesc			= szDesc;
end;

function tb:ParseItem(tbItemSet)
	self.ItemList = {};
	for i, Param in ipairs(tbItemSet) do
		self.ItemList[i] = Param;
	end
	self.szItemDesc 	= tbItemSet[3].."个"..tbItemSet[1].."·"..tbItemSet[2];	
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
	if (not self:IsDone()  or self.szRepeatMsg) then	-- 本目标是一旦达成后不会失效的
		self:Register();
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
	local szMsg = "";
	if (self.szItemDesc) then
		szMsg = "把"..self.szItemDesc.."交给";
	else
		szMsg	= "把指定道具交给";
	end

	if (self.nMapId ~= 0) then
		szMsg	= szMsg..self.szMapName.."的";
	end;
	szMsg	= szMsg..string.format("%s", self.szNpcName);
	return szMsg;
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
	if (self.nMapId ~= 0 and self.nMapId ~= pPlayer.GetMapId()) then
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
	Task.GiveItemTag.tbGiveForm:SetRegular(self, pPlayer);
	-- 弹给与界面
	Dialog:Gift("Task.GiveItemTag.tbGiveForm");
	
end;

function tb:OnFinish()
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
	
	if (not self.szRepeatMsg) then
		self:UnRegister()	-- 本目标是一旦达成后不会失效的
	end;
	
	self.tbTask:OnFinishOneTag();
end;
