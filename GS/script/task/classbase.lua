
--一个任务在玩家身上，类的形式
local tbClassBase	= {};
Task._tbClassBase	= tbClassBase;

function tbClassBase:GetName()
	return self.tbReferData.szName;
end;

-- 得到当前步骤 
function tbClassBase:GetCurStep()
	return self.tbSubData.tbSteps[self.nCurStep];
end;

-- 看这个Npc身上有没有对话(tbNpcMenu)如果有的话就添加选项，否则返回nil
function tbClassBase:AppendNpcMenu(nNpcTempId, tbOption, pNpc)
	local tbNpcMenuData	= self.tbNpcMenus[nNpcTempId];
	
	if (not tbNpcMenuData) then
		return nil;
	end
	
	if (pNpc.nMapId ~= tbNpcMenuData.nMapId and tbNpcMenuData.nMapId ~= 0) then
		return nil;
	end
	
	local tbNpcMenu = tbNpcMenuData.tbCallBack;
	
	assert(type(tbNpcMenu[1]) == "string" );
	
	if (tbOption) then
		tbOption[#tbOption + 1]	= {tbNpcMenuData.nTaskType or 0, tbNpcMenu};
	end;
	
	return 1;
end;


function tbClassBase:CheckTaskOnNpc()
	if (self.tbNpcMenus[him.nTemplateId] and ((him.nMapId == self.tbNpcMenus[him.nTemplateId].nMapId) or self.tbNpcMenus[him.nTemplateId].nMapId == 0)) then
		return 1;
	end
	
	return nil;
end


function tbClassBase:OnExclusiveDialogNpc(nNpcTempId)
	local tbDialogTrigger = self.tbNpcExclusiveDialogs[nNpcTempId];
	if (not tbDialogTrigger) then
		return nil;
	end
	Lib:CallBack(tbDialogTrigger);
end

-- 物品触发
function tbClassBase:OnTaskItem(nParticular)
	local tbItemUse	= self.tbItemUse[nParticular];
	if (not tbItemUse) then
		return nil;
	end;
	Lib:CallBack(tbItemUse);
	return 1;
end;

-- 完成一个目标的时候执行，她判断是否事件为自动触发，若是则执行下一步骤。
function tbClassBase:OnFinishOneTag()
	local tbStep	= self:GetCurStep();
	if (not tbStep) then
		return "None.";
	end;

	if (tbStep.tbEvent.nType == 3) then
		assert(self.nCurStep > 0);
		for _, tbCurTag in ipairs(self.tbCurTags) do
			if (not tbCurTag:IsDone()) then
				return;
			end;
		end;
	
		self:GoNextStep();
	end
end;


function tbClassBase:Active()
	local pPlayer = self:GetPlayerObj();
	if not pPlayer then
		return;
	end
	for _, tbCurTag in ipairs(self.tbCurTags) do
		if (not tbCurTag:IsDone()) then
			return;
		end
	end
	local bOK, szMsg	= self:IsCurStepDone();
	if (not bOK) then
		Dialog:SendInfoBoardMsg(pPlayer, szMsg);
		return nil;
	end;

	self:GoNextStep()
	
	return 1;
end;

function tbClassBase:IsCurStepDone()
	local tbStep	= self:GetCurStep();
	if (not tbStep) then
		return nil;
	end;
	if (not tbStep.tbJudge) then
		return 1;
	end;
	return Lib:DoTestFuncs(tbStep.tbJudge);
end;

function tbClassBase:GoNextStep()
	assert(self.nCurStep > 0);
	local pPlayer = self:GetPlayerObj();
	if not pPlayer then
		return;
	end
	for _, tbCurTag in ipairs(self.tbCurTags) do
		if (not tbCurTag:IsDone()) then
			Dialog:SendInfoBoardMsg(pPlayer, "Mục tiêu chưa hoàn thành: "..tbCurTag:GetStaticDesc());
			return;
		end;
	end;
	local tbStep	= self:GetCurStep();
	local tbStepEvent = tbStep.tbEvent;
	if (tbStepEvent.nType == 2) then
		local tbItemId = {20,1,tbStepEvent.nValue,1};
		if (not Task:DelItem(pPlayer, tbItemId, 1)) then
			pPlayer.Msg("Vật phẩm chỉ định không tồn tại!")
			return nil;
		end
	end
		
	
	if (tbStep.tbExecute) then
		Setting:SetGlobalObj(pPlayer);	
		Lib:DoExecFuncs(tbStep.tbExecute, self.nTaskId);
		Setting:RestoreGlobalObj();
	end;
	self:CloseCurStep("finish");
	pPlayer.Msg("Hoàn thành.");
	pPlayer.CastSkill(Task.nFinishStepSkillId,1,-1, pPlayer.GetNpc().nIndex);
	
	if self.nTaskId == Merchant.TASKDATA_ID then
		local nCount = Merchant:GetTask(Merchant.TASK_STEP_COUNT);
		-- 记Log
		if nCount == 20 then
			-- KStatLog.ModifyAdd("mixstat", "商会完成20次人数", "总量", 1);
		elseif nCount % 100 == 0 then
			-- KStatLog.ModifyAdd("mixstat", "商会完成"..nCount.."次人数", "总量", 1);			
		end
		
		if (nCount%Merchant.AWARD_INTERVAL == 0) then
			Merchant:AddZhenYuanExpAward();
		end
		--每5步写log
		if math.fmod(nCount, 5) == 0 then
			Dbg:WriteLog("Merchant_Step", pPlayer.szName, pPlayer.szAccount, nCount);
		end	
		if nCount < Merchant.TASKDATA_MAXCOUNT then
			Merchant:SyncTaskExp();
			Merchant:OnAccept();
			self:SetCurStep(self.nCurStep);
		else
			--强制刷新奖励
			Merchant:SyncTaskExp();
			self:SetCurStep(self.nCurStep + 1);			
			Merchant:FinishTask()
		end
	else
		self:SetCurStep(self.nCurStep + 1);
	end	
	return 1;
end;

-- 设置当前步骤，包括当前目标
function tbClassBase:SetCurStep(nStep, bLoading)
	local pPlayer = self:GetPlayerObj();
	if not pPlayer then
		return;
	end
	Setting:SetGlobalObj(pPlayer);
	local tbCurTags	= {};
	self.tbCurTags	= tbCurTags;
	self.tbNpcMenus	= {}; --下标为Npc模板Id
	self.tbNpcExclusiveDialogs = {};
	self.tbItemUse	= {};
	self.tbCollectList = {};
	self.nCurStep		= nStep;
	local tbStep		= self:GetCurStep();
	if (tbStep) then --还有步骤，说明还没有做完此任务
		local tbStepDesc	= self.tbReferData.tbDesc.tbStepsDesc;
		local szStepDesc		= nil;
		if (tbStepDesc and tbStepDesc[nStep]) then
			szStepDesc = tbStepDesc[nStep];
		end

		local tbEvent	= tbStep.tbEvent;
		if (tbEvent.nType == 1) then --如果触发为npc
			self:AddNpcMenu(tbEvent.nValue, 0, self:GetName(),
				TaskAct.Talk, TaskAct, {self.GetNpcDialog, self},
				Task.Active, Task, self.nTaskId, self.nReferId, nStep);
		elseif (tbEvent.nType == 2) then --如果触发为Item
			self:AddItemUse(tbEvent.nValue,
				Task.Active, Task, self.nTaskId, self.nReferId, nStep);
		end;
		local nSaveLen	= 5; --保存的长度从5开始，之前4个为任务Id,引用子任务Id,当前步骤，接任务时间

		for i, tbTarget in ipairs(tbStep.tbTargets) do
			local tbCurTag	= Lib:NewClass(tbTarget); -- 目标的第2次派生，第一次见loadfile.lua
			tbCurTags[i]	= tbCurTag;
			tbCurTag.tbTask	= self;
			tbCurTag.me		= me;
			tbCurTag.nPlayerId	= self.nPlayerId;
			if (bLoading) then
				nSaveLen	= nSaveLen + tbCurTag:Load(self.nSaveGroup, nSaveLen); -- 一个步骤中的所有目标是固定的，所以nSaveLen会对应到指定目标
			else
				tbCurTag:Start();
			end;
		end;
		
	else -- 步骤已经全部完成
		self.nCurStep	= -1;
		
		--商会加载最终经验奖励
		if self.nTaskId == Merchant.TASKDATA_ID then
			Merchant:SyncTaskFixAward();
		end
		
		
		if (MODULE_GAMESERVER and not bLoading) then
			--local tbAwards	= self.tbReferData.tbAwards;
			local tbAwards = Task:GetAwards(self.nReferId); -- 如果没有奖励则直接算完成任务
			if (not (tbAwards.tbOpt[1] or tbAwards.tbRand[1] or tbAwards.tbFix[1])) then
				Task:SetFinishedRefer(self.nTaskId, self.nReferId);
				Task:CloseTask(self.nTaskId, "finish");
				Setting:RestoreGlobalObj();
				return;
			end;
		end;
		local szMsg = "";
		if (self.tbSubData.tbAttribute.tbDialog.Prize.szMsg) then -- 未分步骤
			szMsg = self.tbSubData.tbAttribute.tbDialog.Prize.szMsg;
		else
			szMsg = self.tbSubData.tbAttribute.tbDialog.Prize.tbSetpMsg[1];
		end
				
		local tbAwardCall	= {
			TaskAct.TalkInDark, TaskAct,
			szMsg,
			KTask.SendAward, me, self.nTaskId, self.nReferId,
		};
		if (MODULE_GAMESERVER and not bLoading) then
			if (TaskCond:HaveBagSpace(self.tbReferData.nBagSpaceCount)) then
				Lib:CallBack(tbAwardCall);
			else
				Dialog:SendInfoBoardMsg(me, "Thu xếp túi còn "..self.tbReferData.nBagSpaceCount.." ô trống rồi đến lãnh thưởng!");
			end
		end;
		
		if (not self.tbReferData.nReplyNpcId or self.tbReferData.nReplyNpcId <= 0) then
			local tbEvent	= self.tbSubData.tbSteps[#self.tbSubData.tbSteps].tbEvent;
			if (tbEvent.nType == 1) then
				self:AddNpcMenu(tbEvent.nValue, 0, self:GetName().."-Nhận thưởng", unpack(tbAwardCall));
			else
				assert(false or "Không có nơi lãnh thưởng!");
			end
		else
			self:AddNpcMenu(self.tbReferData.nReplyNpcId, 0, self:GetName().."-Nhận thưởng", unpack(tbAwardCall));
		end

	end;

	if (MODULE_GAMESERVER) then
		if (not bLoading) then
			self:SaveData();
		end;
		me.SyncTaskGroup(self.nSaveGroup);
		KTask.SendRefresh(me, self.nTaskId, self.nReferId, self.nSaveGroup);
		if (not bLoading and self.nCurStep > 0) then
			self:OnFinishOneTag();
		end
	end;
	
	Setting:RestoreGlobalObj();
end;

function tbClassBase:CloseCurStep(szReason)
	for i, tbCurTag in ipairs(self.tbCurTags) do
		tbCurTag:Close(szReason);
	end;
	
	self.tbCurTags	= {};
	self.tbNpcMenus	= {};
	self.tbItemUse	= {};
	self.tbCollectList = {};
	self.tbNpcExclusiveDialogs = {};
end;


function tbClassBase:SaveData()
	local pPlayer = self:GetPlayerObj();
	if not pPlayer then
		return;
	end
	pPlayer.SetTask(self.nSaveGroup, Task.emSAVEID_TASKID, self.nTaskId);
	pPlayer.SetTask(self.nSaveGroup, Task.emSAVEID_REFID, self.nReferId);
	pPlayer.SetTask(self.nSaveGroup, Task.emSAVEID_CURSTEP, self.nCurStep);
	pPlayer.SetTask(self.nSaveGroup, Task.emSAVEID_ACCEPTDATA, self.nAcceptDate);
	local nSaveLen	= 5;
	for _, tbCurTag in ipairs(self.tbCurTags) do
		nSaveLen	= nSaveLen + tbCurTag:Save(self.nSaveGroup, nSaveLen);
	end;
end;


-- 载入玩家指定任务组的数据
function tbClassBase:LoadData(nSaveGroup)
	local pPlayer = self:GetPlayerObj();
	if not pPlayer then
		return;
	end
	Merchant:LoadDate(self.nTaskId)
	XiakeDaily:SyncTask();
	WeekendFish:SyncTask();
	Keyimen:SyncTask();
	self.nSaveGroup		= nSaveGroup;
	self.nAcceptDate	= pPlayer.GetTask(nSaveGroup, Task.emSAVEID_ACCEPTDATA);
	self:SetCurStep(pPlayer.GetTask(nSaveGroup,Task.emSAVEID_CURSTEP), 1); -- 1标识为Load
	
	-- 遍历玩家所有任务目标
	if (MODULE_GAMESERVER) then
		for i, tbCurTag in ipairs(self.tbCurTags) do
			if (tbCurTag:IsDone()) then
				self:OnFinishOneTag();
				break;
			end
		end;
	end

end;


function tbClassBase:AddNpcMenu(nNpcTempId, nMapId, szOption, ...)
	if (not nMapId) then
		nMapId = 0;
	end
	Task:DbgOut("AddNpcMenu", nNpcTempId, nMapId, szOption)
	assert(not self.tbNpcMenus[nNpcTempId], "too many Target on npc:"..nNpcTempId);--对一个任务来说，应该不会存在多个选项在同一个Npc身上

	local szTaskType = "[Nhiệm vụ] ";
	local nTaskType = 0;
	if self.tbTaskData.tbAttribute and self.tbTaskData.tbAttribute.TaskType then
		nTaskType = tonumber(self.tbTaskData.tbAttribute.TaskType) or 0;
		szTaskType = Task.tbemTypeName[nTaskType] or "[Nhiệm vụ] ";
	end
	szOption = string.gsub(szOption, "<taskname>", self.tbTaskData.szName);
	szOption = string.gsub(szOption, "<subtaskname>", self.tbReferData.szName);
	self.tbNpcMenus[nNpcTempId]	= {tbCallBack = {szTaskType..szOption, unpack(arg)}, nMapId = nMapId, nTaskType = nTaskType, };
end;

function tbClassBase:AddExclusiveDialog(nNpcTempId ,...)
	Task:DbgOut("AddNpcExclusiveDialog", nNpcTempId)
	assert(not self.tbNpcExclusiveDialogs[nNpcTempId], "too many ExclusiveDialog on npc:"..nNpcTempId);
	self.tbNpcExclusiveDialogs[nNpcTempId] = {unpack(arg)};
end

-- 只能是任务物品
function tbClassBase:AddItemUse(nTaskItemId, ...)
	assert(not self.tbItemUse[nTaskItemId], "too many Target on item:"..nTaskItemId);
	self.tbItemUse[nTaskItemId]	= {unpack(arg)};
end;

function tbClassBase:RemoveNpcMenu(nNpcTempId)
	self.tbNpcMenus[nNpcTempId]	= nil;
end;
	
function tbClassBase:RemoveNpcExclusiveDialog(nNpcTempId)
	self.tbNpcExclusiveDialogs[nNpcTempId] = nil;
end

function tbClassBase:RemoveItemUse(nParticular)
	self.tbItemUse[nParticular] = nil;
end;


-- 去一个步骤结束Npc那里的对话
function tbClassBase:GetNpcDialog()
	local tbStep = self:GetCurStep();
	if (not tbStep) then
		Dbg:WriteLog("[UNKNOWBUG]", "TaskClassBase", "GetNpcDialog", "Can't Find CurStep", self.nCurStep or "UnKnowSetp");
		return nil;
	end

	local szMsg = nil;
	
	-- 1.目标没达成：过程对白
	for _, tbCurTag in ipairs(self.tbCurTags) do
		if (not tbCurTag:IsDone()) then
			if (self.tbSubData.tbAttribute.tbDialog.Procedure.szMsg) then -- 未分步骤
				szMsg = self.tbSubData.tbAttribute.tbDialog.Procedure.szMsg;
			else -- 分了步骤
				szMsg = self.tbSubData.tbAttribute.tbDialog.Procedure.tbSetpMsg[self.nCurStep];
			end
			
			return szMsg;
		end;
	end;
	

	-- 2.目标达成，条件没达成：出错对白
	local bOK, _  = self:IsCurStepDone();
	if (not bOK) then
		if (self.tbSubData.tbAttribute.tbDialog.Error.szMsg) then -- 未分步骤
			szMsg = self.tbSubData.tbAttribute.tbDialog.Error.szMsg;
		else -- 分了步骤
			szMsg = self.tbSubData.tbAttribute.tbDialog.Error.tbSetpMsg[self.nCurStep];
		end
		return szMsg
	end


	-- 3.目标和条件均达成：结束对白
	if (self.tbSubData.tbAttribute.tbDialog.End.szMsg) then -- 未分步骤
		szMsg = self.tbSubData.tbAttribute.tbDialog.End.szMsg;
	else -- 分了步骤
		szMsg = self.tbSubData.tbAttribute.tbDialog.End.tbSetpMsg[self.nCurStep];
	end
			
	return szMsg;	
end


-------------------------------------------------------------------------
-- 一个玩家杀死Npc有多种分享策略

function tbClassBase:OnKillNpcForCount(pPlayer, pNpc)
	for _, tbCurTag in ipairs(self.tbCurTags) do
		if (tbCurTag.OnKillNpc) then
			tbCurTag:OnKillNpc(pPlayer, pNpc);
		end
	end;
end


function tbClassBase:OnKillNpcForItem(pPlayer, pNpc, nType)
	local bDrop = 0;
	for _, tbCurTag in ipairs(self.tbCurTags) do
		if (tbCurTag.OnKillNpcDropItem) then
			if (tbCurTag:OnKillNpcDropItem(pPlayer, pNpc, nType) == 1) then
				bDrop = 1;
			end
		end
	end
	
	return bDrop;
end

function tbClassBase:OnKillBossForItem(pPlayer, pNpc)
	for _, tbCurTag in ipairs(self.tbCurTags) do
		if (tbCurTag.OnShareBossItem) then
			tbCurTag:OnShareBossItem(pPlayer, pNpc);
		end
	end;
end

function tbClassBase:AddInCollectList(tbItem)
	self.tbCollectList[#self.tbCollectList + 1] =  tbItem;
end

function tbClassBase:RemoveInCollectList(tbItem)
	local nRemoveIndex = -1;
	for i=1, #self.tbCollectList do
		if (Task:IsSameItem(tbItem, self.tbCollectList[i]) == 1) then
			nRemoveIndex = i;
			break;
		end
	end
	
	if (nRemoveIndex > 0) then
		table.remove(self.tbCollectList, nRemoveIndex);
	else
		assert(false);
	end
end

function tbClassBase:IsItemToBeCollect(tbItem)
	for _, item in ipairs(self.tbCollectList) do
		if (tbItem[1] == item[1] and
			tbItem[2] == item[2] and
			tbItem[3] == item[3] and
			tbItem[4] == item[4]) then
				return 1;
			end
	end
	
	return 0;
end


function tbClassBase:GetPlayerObj()
	if MODULE_GAMESERVER then
		return KPlayer.GetPlayerObjById(self.nPlayerId);
	elseif MODULE_GAMECLIENT then
		return me;
	else
		return nil;
	end
end
