Require("\\script\\task\\merchant\\merchant_define.lua");

function Merchant:InitFile()
	self:LoadFile();
	self:InitTask();
	self:InitSubTask();
end

function Merchant:InitTask()	
	local tbTaskData	= {};
	local nTaskId		= self.TASKDATA_ID;
	tbTaskData.nId		= nTaskId;
	tbTaskData.szName	= "[Nhiệm vụ thương hội]";
	local szTaskDesc 	= "";
	
	-- 主任务的基础属性
	local tbAttribute	= {};
	tbTaskData.tbAttribute	= tbAttribute;
	
	tbAttribute["Order"]		= Lib:Str2Val("linear");	-- 任务流程：线性
	tbAttribute["Repeat"]		= Lib:Str2Val("true");		-- 是否可重做：是
	tbAttribute["Context"]		= Lib:Str2Val(szTaskDesc);	-- 任务描述
	tbAttribute["Share"]		= Lib:Str2Val("false");		-- 是否可共享
	tbAttribute["TaskType"]		= Lib:Str2Val("3");			-- 任务类型：3、随机任务
	tbAttribute["AutoTrack"]	= Lib:Str2Val("true");
	
	-- 主任务下的子任务
	local tbReferIds	= {};
	tbTaskData.tbReferIds	= tbReferIds;
	
	-- 任务的内容表

	-- 在这里循环将子任务放到任务 table 里去	
	local nReferId		= nTaskId -- 引用子任务Id
	local nReferIdx		= 1;	-- 引用子任务索引
	tbReferIds[nReferIdx]		= nReferId;	
	-- 不能存在已有的任务
	--assert(not Task.tbReferDatas[nReferId]);
	Task.tbReferDatas[nReferId]	= self:NewRefer(nReferId, Item.tbStone:GetOpenDay());
	Task.tbTaskDatas[nTaskId]	= tbTaskData;
end

function Merchant:InitSubTask()
	local nSubTaskId = self.TASKDATA_ID;
	local tbSubData = self:NewSubTask(nSubTaskId);
	Task.tbSubDatas[nSubTaskId]	= tbSubData;
	return tbSubData;
end


function Merchant:NewRefer(nReferId, bAddStoneAward)
		local tbReferData	= {};	
		local nReferIdx = 1;
		tbReferData.nReferId		= nReferId;
		tbReferData.nReferIdx		= nReferIdx;
		tbReferData.nTaskId			= nReferId;
		tbReferData.nSubTaskId		= nReferId
		tbReferData.szName			= "Nhiệm vụ thương hội"
		tbReferData.tbDesc			= {szMainDesc=string.format("Hoàn thành hết %s bước có thể nhận phần thưởng thêm", self.TASKDATA_MAXCOUNT),tbStepsDesc={""}}
		
		tbReferData.tbVisable	= self.TaskContent.tbReferData.tbVisable;	    -- 可见条件
		tbReferData.tbAccept	= self.TaskContent.tbReferData.tbAccept; 		-- 可接条件
		
		tbReferData.nAcceptNpcId	= self.NPC_ID;
		
		tbReferData.bCanGiveUp	= Lib:Str2Val("false");
		
		tbReferData.szGossip = "";			-- 流言文字
		tbReferData.nReplyNpcId	= self.NPC_ID;		-- 回复 NPC
		tbReferData.szReplyDesc	= "Tìm Chủ Thương Hội nhận thưởng";		-- 回复文字
		
		tbReferData.nBagSpaceCount = 0;		-- 背包空间检查
		tbReferData.nLevel = 60;
		tbReferData.szIntrDesc = "";
		tbReferData.nDegree = 1;
		tbReferData.tbAwards	= {
			tbFix	= {};
			tbOpt	= {},
			tbRand	= {},
		};
		tbReferData.nBagSpaceCount, tbReferData.tbAwards.tbFix = self:GetAwardFix(bAddStoneAward);
		return tbReferData;
end

function Merchant:NewSubTask(nSubTaskId)
	local tbSubData		= {};
	tbSubData.nId		= nSubTaskId;
	tbSubData.szName	= "[Nhiệm vụ thương hội]";
	tbSubData.szDesc	= "";
	
	tbSubData.tbSteps	= {};
	tbSubData.tbExecute = {};
	tbSubData.tbStartExecute = {};
	tbSubData.tbFailedExecute = {};
	tbSubData.tbFinishExecute = {};
	
	-- 任务属性
	tbSubData.tbAttribute	= self.TaskContent.tbSubData.tbAttribute;

	-- 步骤
	local tbStep	= {};
	table.insert(tbSubData.tbSteps, tbStep);

	-- 开始事件，这里设一个空的 npc
	local tbEvent	= {};
	tbStep.tbEvent	= tbEvent;
	tbEvent.nType	= 3;
	tbEvent.nValue	= 0;

	-- 任务目标
	local tbTargets		= {};
	tbStep.tbTargets	= tbTargets;

	-- 步骤条件
	tbStep.tbJudge	= {};
	tbStep.tbExecute = {};
	return tbSubData;
end


function Merchant:LoadFile()
	self.TaskSelectFile = {};	--大事件表
	self.TaskFile = {};			--各小事件表
	self.TaskAwardFile = {};	--奖励表
	self.TaskContent = {};		--固定内容表：
	local tbFile = Lib:LoadTabFile(self.FILE_PATH..self.FILE_SELECT);
	if not tbFile then
		return
	end
	for i = 2, #tbFile do
		local nTypeId =  tonumber(tbFile[i].TypeId) or 0;
		local szTypeName  = tbFile[i].TypeName;
		local szFileName  = tbFile[i].FileName;
		local nRate01  = tonumber(tbFile[i].Step01) or 0;
		local nRate02  = tonumber(tbFile[i].Step02) or 0;
		local nRate03  = tonumber(tbFile[i].Step03) or 0;

		self.TaskSelectFile[nTypeId] = {};
		self.TaskSelectFile[nTypeId].TypeName = szTypeName;
		self.TaskSelectFile[nTypeId].FileName = szFileName;
		self.TaskSelectFile[nTypeId].Rate01   = nRate01;
		self.TaskSelectFile[nTypeId].Rate02   = nRate02;
		self.TaskSelectFile[nTypeId].Rate03   = nRate03;
	end
	self:LoadSubFile();
	self:LoadAwardFile();
	self:LoadContent();
	
end

function Merchant:LoadContent()
	self.TaskContent.tbReferData = {};
	local tbVisable =
			{
				"return TaskCond:RequireTaskValue(2036,1,0)",		--每周只能做1次
				"return TaskCond:IsLevelAE(60)",					--达到60级
--				"return TaskCond:RequireTaskValue(1022,107,1)",		--已完成50级主线任务
			}
	local tbAccept = 
			{
				"return TaskCond:RequireTaskValue(2036,1,0)",		--每周只能做1次
				"return TaskCond:IsLevelAE(60)",					--达到60级
--				"return TaskCond:RequireTaskValue(1022,107,1)",		--已完成50级主线任务
				"return TaskCond:IsKinReputeAE(50)",				--江湖威望达到50点				
			}
	self.TaskContent.tbReferData.tbVisable = tbVisable;
	self.TaskContent.tbReferData.tbAccept  = tbAccept;
	
	self.TaskContent.tbSubData = {};
	local tbAttribute	= {};
	tbAttribute.tbDialog	= {};
	tbAttribute.tbDialog["Start"] = {szMsg= ""};
	tbAttribute.tbDialog["Procedure"] = {szMsg = ""};
	tbAttribute.tbDialog["Error"] = {szMsg = ""};
	tbAttribute.tbDialog["Prize"] = {szMsg = ""};
	tbAttribute.tbDialog["End"] = {szMsg = ""};	
	self.TaskContent.tbSubData.tbAttribute = tbAttribute;
end

function Merchant:LoadAwardFile()
	
	local tbFile = Lib:LoadTabFile(self.FILE_PATH..self.FILE_AWARD);
	if not tbFile then
		return
	end
	for i = 2, #tbFile do
		local nStepId 	=  tonumber(tbFile[i].Step) or 0;
		local szName  	= tbFile[i].Name;
		local nGenre  	= tonumber(tbFile[i].Genre) or 0;
		local nDetail  	= tonumber(tbFile[i].Detail) or 0;
		local nParticular  = tonumber(tbFile[i].Particular) or 0;
		local nLevel  	= tonumber(tbFile[i].Level) or 0;		
		local nSeries 	= tonumber(tbFile[i].Five) or 0;
		local nNum 		= tonumber(tbFile[i].Num) or 1;
		local nMoney 	= tonumber(tbFile[i].Money) or 0;
		local nBindMoney= tonumber(tbFile[i].BindMoney) or 0;	
		local nBaseExp 	= tonumber(tbFile[i].BaseExp) or 0;
		if self.TaskAwardFile[nStepId] == nil then
			self.TaskAwardFile[nStepId] = {};
		end
		local tbTemp = {
			szName = szName,
			nGenre	= nGenre,
			nDetail = nDetail,
			nParticular = nParticular,
			nLevel	= nLevel,
			nSeries = nSeries,
			nNum	= nNum,
			nMoney = nMoney,
			nBindMoney = nBindMoney,
			nBaseExp = nBaseExp,
		}
		table.insert(self.TaskAwardFile[nStepId], tbTemp);
	end
end

function Merchant:LoadSubFile()
	for	nTypeId, tbItem in pairs(self.TaskSelectFile) do
		if tbItem.FileName then
			local tbFile = Lib:LoadTabFile(self.FILE_PATH..tbItem.FileName);
			if not tbFile then
				return
			end
			
			if nTypeId == self.TYPE_DELIVERITEM or nTypeId == self.TYPE_DELIVERITEM_NEW then
				--送信			
				self:LoadDerivleItemFile(nTypeId, tbFile, 1, tbItem.Rate01);
				self:LoadDerivleItemFile(nTypeId, tbFile, 2, tbItem.Rate02);
				self:LoadDerivleItemFile(nTypeId, tbFile, 3, tbItem.Rate03);
			end
			
			if nTypeId == self.TYPE_BUYITEM or nTypeId == self.TYPE_BUYITEM_NEW then
				--购物
				self:LoadBuyItemFile(nTypeId, tbFile, 1, tbItem.Rate01);
				self:LoadBuyItemFile(nTypeId, tbFile, 2, tbItem.Rate02);
				self:LoadBuyItemFile(nTypeId, tbFile, 3, tbItem.Rate03);
			end
			
			if nTypeId == self.TYPE_FINDITEM or nTypeId == self.TYPE_FINDITEM_NEW then
				--寻物
				self:LoadFindItemFile(nTypeId, tbFile, 1, tbItem.Rate01);
				self:LoadFindItemFile(nTypeId, tbFile, 2, tbItem.Rate02);
				self:LoadFindItemFile(nTypeId, tbFile, 3, tbItem.Rate03);
			end	
			
			if nTypeId == self.TYPE_COLLECTITEM or nTypeId == self.TYPE_COLLECTITEM_NEW then
				--收集物品
				self:LoadCollectItemFile(nTypeId, tbFile, 1, tbItem.Rate01);
				self:LoadCollectItemFile(nTypeId, tbFile, 2, tbItem.Rate02);
				self:LoadCollectItemFile(nTypeId, tbFile, 3, tbItem.Rate03);
			end
		end
	end
end

function Merchant:LoadDerivleItemFile(nType, tbFile, nDiff, nRate)
	if self.TaskFile[nDiff] == nil then
		 self.TaskFile[nDiff] = {};
		 self.TaskFile[nDiff].MaxRate = 0;
		 self.TaskFile[nDiff].TypeClass = {};
	end
	if self.TaskFile[nDiff].TypeClass[nType] == nil then
		self.TaskFile[nDiff].TypeClass[nType] = {};
	end
	self.TaskFile[nDiff].TypeClass[nType].Rate = nRate;
	self.TaskFile[nDiff].MaxRate = self.TaskFile[nDiff].MaxRate + nRate;
	for i = 2, #tbFile do
		local nStepRate = 0;
		if nDiff == 1 then
			nStepRate = tonumber(tbFile[i].Step01) or 0;
		elseif nDiff == 2 then
			nStepRate = tonumber(tbFile[i].Step02) or 0;
		else
			nStepRate = tonumber(tbFile[i].Step03) or 0;
		end
		local nStartDay	 =  tonumber(tbFile[i].StartDay) or 0;
		local nLevelFlag =  tonumber(tbFile[i].LevelFlag) or 0;
		local nTaskId =  tonumber(tbFile[i].TaskId) or 0;
		local szTaskName = Lib:ClearStrQuote(tbFile[i].TaskName);
		local szTaskType =  tbFile[i].TaskType;
		local szNpcName = tbFile[i].NpcName;
		local nMapId = tonumber(tbFile[i].MapId) or 0;
		local nNpcId = tonumber(tbFile[i].NpcId) or 0;
		--local nGenre =  tonumber(tbFile[i].Genre) or 0;
		--local nDetail =  tonumber(tbFile[i].Detail) or 0;
		--local nParticular =  tonumber(tbFile[i].Particular) or 0;
		--local nLevel =  tonumber(tbFile[i].Level) or 0;	
		local nAwardExp = tonumber(tbFile[i].AwardExp) or 0;
		local nNeedTime = tonumber(tbFile[i].NeedTime) or 0;
		
		local tbTemp = self.TaskFile[nDiff].TypeClass[nType];
		if tbTemp[50] == nil then
			tbTemp[50] = {};
			tbTemp[50].MaxRate = 0;
			tbTemp[50].TaskEvent = {};
		end
			
		if tbTemp[60] == nil then
				tbTemp[60] = {};
				tbTemp[60].MaxRate = 0;
				tbTemp[60].TaskEvent = {};
			end
		if nLevelFlag == 0 then
			tbTemp[50].TaskEvent[nTaskId] = {};
			tbTemp[50].TaskEvent[nTaskId].TaskName = szTaskName;
			tbTemp[50].TaskEvent[nTaskId].TaskType = szTaskType;
			tbTemp[50].TaskEvent[nTaskId].NpcName = szNpcName;
			tbTemp[50].TaskEvent[nTaskId].MapId = nMapId;
			tbTemp[50].TaskEvent[nTaskId].NpcId = nNpcId;
			tbTemp[50].TaskEvent[nTaskId].Genre = nGenre;
			tbTemp[50].TaskEvent[nTaskId].Detail = nDetail;
			tbTemp[50].TaskEvent[nTaskId].Particular = nParticular;
			tbTemp[50].TaskEvent[nTaskId].Level = nLevel;
			tbTemp[50].TaskEvent[nTaskId].Rate = nStepRate;
			tbTemp[50].TaskEvent[nTaskId].AwardExp = nAwardExp;
			tbTemp[50].TaskEvent[nTaskId].NeedTime = nNeedTime;
			tbTemp[50].TaskEvent[nTaskId].StartDay = nStartDay;
			tbTemp[50].MaxRate = tbTemp[50].MaxRate + nStepRate;
			
			tbTemp[60].TaskEvent[nTaskId] = {};
			tbTemp[60].TaskEvent[nTaskId] = tbTemp[50].TaskEvent[nTaskId];
			tbTemp[60].MaxRate = tbTemp[60].MaxRate + nStepRate;
		end
		
		if nLevelFlag == 1 then
			tbTemp[60].TaskEvent[nTaskId] = {};
			tbTemp[60].TaskEvent[nTaskId].TaskName = szTaskName;
			tbTemp[60].TaskEvent[nTaskId].TaskType = szTaskType;
			tbTemp[60].TaskEvent[nTaskId].NpcName = szNpcName;
			tbTemp[60].TaskEvent[nTaskId].MapId = nMapId;
			tbTemp[60].TaskEvent[nTaskId].NpcId = nNpcId;
			tbTemp[60].TaskEvent[nTaskId].Genre = nGenre;
			tbTemp[60].TaskEvent[nTaskId].Detail = nDetail;
			tbTemp[60].TaskEvent[nTaskId].Particular = nParticular;
			tbTemp[60].TaskEvent[nTaskId].Level = nLevel;			
			tbTemp[60].TaskEvent[nTaskId].Rate = nStepRate;
			tbTemp[60].TaskEvent[nTaskId].AwardExp = nAwardExp;
			tbTemp[60].TaskEvent[nTaskId].NeedTime = nNeedTime;
			tbTemp[60].TaskEvent[nTaskId].StartDay = nStartDay;
			tbTemp[60].MaxRate = tbTemp[60].MaxRate + nStepRate;
		end
	end
end

function Merchant:LoadBuyItemFile(nTypeId, tbFile, nDiff, nRate)
	if self.TaskFile[nDiff] == nil then
		 self.TaskFile[nDiff] = {};
		 self.TaskFile[nDiff].MaxRate = 0;
		 self.TaskFile[nDiff].TypeClass = {};
	end
	if self.TaskFile[nDiff].TypeClass[nTypeId] == nil then
		self.TaskFile[nDiff].TypeClass[nTypeId] = {};
	end
	self.TaskFile[nDiff].TypeClass[nTypeId].Rate = nRate;
	self.TaskFile[nDiff].MaxRate = self.TaskFile[nDiff].MaxRate + nRate;
	for i = 2, #tbFile do
		
		local nStepRate = 0;
		if nDiff == 1 then
			nStepRate = tonumber(tbFile[i].Step01) or 0;
		elseif nDiff == 2 then
			nStepRate = tonumber(tbFile[i].Step02) or 0;
		else
			nStepRate = tonumber(tbFile[i].Step03) or 0;
		end
		local nStartDay	 =  tonumber(tbFile[i].StartDay) or 0;
		local nLevelFlag =  tonumber(tbFile[i].LevelFlag) or 0;
		local nTaskId =  tonumber(tbFile[i].TaskId) or 0;
		local szTaskName =  Lib:ClearStrQuote(tbFile[i].TaskName);
		local szTaskType =  tbFile[i].TaskType;
		local nGenre =  tonumber(tbFile[i].Genre) or 0;
		local nDetail =  tonumber(tbFile[i].Detail) or 0;
		local nParticular =  tonumber(tbFile[i].Particular) or 0;
		local nLevel =  tonumber(tbFile[i].Level) or 0;
		local nSeries =  tonumber(tbFile[i].Series) or 0;
		local nNum =  tonumber(tbFile[i].Num) or 1;
		local szItemName = tbFile[i].ItemName;
		local szSuffix = tbFile[i].Suffix;
		local nAwardExp = tonumber(tbFile[i].AwardExp) or 0;
		local nNeedTime = tonumber(tbFile[i].NeedTime) or 0;
		
		local tbTemp = self.TaskFile[nDiff].TypeClass[nTypeId];
			if tbTemp[50] == nil then
				tbTemp[50] = {};
				tbTemp[50].MaxRate = 0;
				tbTemp[50].TaskEvent = {};
			end
			
		if tbTemp[60] == nil then
				tbTemp[60] = {};
				tbTemp[60].MaxRate = 0;
				tbTemp[60].TaskEvent = {};
			end
		if nLevelFlag == 0 then
			tbTemp[50].TaskEvent[nTaskId] = {};
			tbTemp[50].TaskEvent[nTaskId].TaskName = szTaskName;
			tbTemp[50].TaskEvent[nTaskId].TaskType = szTaskType;
			tbTemp[50].TaskEvent[nTaskId].Genre = nGenre;
			tbTemp[50].TaskEvent[nTaskId].Detail = nDetail;
			tbTemp[50].TaskEvent[nTaskId].Particular = nParticular;
			tbTemp[50].TaskEvent[nTaskId].Level = nLevel;			
			tbTemp[50].TaskEvent[nTaskId].Series = nSeries;			
			tbTemp[50].TaskEvent[nTaskId].Num = nNum;			
			tbTemp[50].TaskEvent[nTaskId].ItemName = szItemName;	
			tbTemp[50].TaskEvent[nTaskId].Suffix = szSuffix;
			tbTemp[50].TaskEvent[nTaskId].Rate = nStepRate;
			tbTemp[50].TaskEvent[nTaskId].AwardExp = nAwardExp;
			tbTemp[50].TaskEvent[nTaskId].NeedTime = nNeedTime;
			tbTemp[50].TaskEvent[nTaskId].StartDay = nStartDay;
			tbTemp[50].MaxRate = tbTemp[50].MaxRate + nStepRate;
			
			tbTemp[60].TaskEvent[nTaskId] = {};
			tbTemp[60].TaskEvent[nTaskId] = tbTemp[50].TaskEvent[nTaskId];
			tbTemp[60].MaxRate = tbTemp[60].MaxRate + nStepRate;
		end
		
		if nLevelFlag == 1 then
			tbTemp[60].TaskEvent[nTaskId] = {};
			tbTemp[60].TaskEvent[nTaskId].TaskName = szTaskName;
			tbTemp[60].TaskEvent[nTaskId].TaskType = szTaskType;
			tbTemp[60].TaskEvent[nTaskId].Genre = nGenre;
			tbTemp[60].TaskEvent[nTaskId].Detail = nDetail;
			tbTemp[60].TaskEvent[nTaskId].Particular = nParticular;
			tbTemp[60].TaskEvent[nTaskId].Level = nLevel;			
			tbTemp[60].TaskEvent[nTaskId].Series = nSeries;			
			tbTemp[60].TaskEvent[nTaskId].Num = nNum;			
			tbTemp[60].TaskEvent[nTaskId].ItemName = szItemName;	
			tbTemp[60].TaskEvent[nTaskId].Suffix = szSuffix;
			tbTemp[60].TaskEvent[nTaskId].Rate = nStepRate;
			tbTemp[60].TaskEvent[nTaskId].AwardExp = nAwardExp;
			tbTemp[60].TaskEvent[nTaskId].NeedTime = nNeedTime;
			tbTemp[60].TaskEvent[nTaskId].StartDay = nStartDay;
			tbTemp[60].MaxRate = tbTemp[60].MaxRate + nStepRate;
		end
	end
end

function Merchant:LoadFindItemFile(nTypeId, tbFile, nDiff, nRate)
	if self.TaskFile[nDiff] == nil then
		 self.TaskFile[nDiff] = {};
		 self.TaskFile[nDiff].MaxRate = 0;
		 self.TaskFile[nDiff].TypeClass = {};
	end
	if self.TaskFile[nDiff].TypeClass[nTypeId] == nil then
		self.TaskFile[nDiff].TypeClass[nTypeId] = {};
	end
	self.TaskFile[nDiff].TypeClass[nTypeId].Rate = nRate;
	self.TaskFile[nDiff].MaxRate = self.TaskFile[nDiff].MaxRate + nRate;
	for i = 2, #tbFile do
		local nStepRate = 0;
		if nDiff == 1 then
			nStepRate = tonumber(tbFile[i].Step01) or 0;
		elseif nDiff == 2 then
			nStepRate = tonumber(tbFile[i].Step02) or 0;
		else
			nStepRate = tonumber(tbFile[i].Step03) or 0;
		end		
		local nStartDay	 =  tonumber(tbFile[i].StartDay) or 0;
		local nLevelFlag =  tonumber(tbFile[i].LevelFlag) or 0;
		local nTaskId =  tonumber(tbFile[i].TaskId) or 0;
		local szTaskName =  Lib:ClearStrQuote(tbFile[i].TaskName);
		local szStepDesc =  Lib:ClearStrQuote(tbFile[i].StepDesc);		
		local szTaskType =  tbFile[i].TaskType;
		local nGenre =  tonumber(tbFile[i].Genre) or 0;
		local nDetail =  tonumber(tbFile[i].Detail) or 0;
		local nParticular =  tonumber(tbFile[i].Particular) or 0;
		local nLevel =  tonumber(tbFile[i].Level) or 0;
		local nSeries =  tonumber(tbFile[i].Series) or 0;
		local nNum =  tonumber(tbFile[i].Num) or 1;
		local nMoney =tonumber(tbFile[i].Money) or 0;
		local szItemName = tbFile[i].ItemName;
		local szSuffix = tbFile[i].Suffix;
		local nAwardExp = tonumber(tbFile[i].AwardExp) or 0;
		local nNeedTime = tonumber(tbFile[i].NeedTime) or 0;
		
		local tbTemp = self.TaskFile[nDiff].TypeClass[nTypeId];
			if tbTemp[50] == nil then
				tbTemp[50] = {};
				tbTemp[50].MaxRate = 0;
				tbTemp[50].TaskEvent = {};
			end
			
		if tbTemp[60] == nil then
				tbTemp[60] = {};
				tbTemp[60].MaxRate = 0;
				tbTemp[60].TaskEvent = {};
			end
		if nLevelFlag == 0 then
			tbTemp[50].TaskEvent[nTaskId] = {};
			tbTemp[50].TaskEvent[nTaskId].TaskName = szTaskName;
			tbTemp[50].TaskEvent[nTaskId].TaskType = szTaskType;
			tbTemp[50].TaskEvent[nTaskId].StepDesc = szStepDesc;
			tbTemp[50].TaskEvent[nTaskId].Genre = nGenre;
			tbTemp[50].TaskEvent[nTaskId].Detail = nDetail;
			tbTemp[50].TaskEvent[nTaskId].Particular = nParticular;
			tbTemp[50].TaskEvent[nTaskId].Level = nLevel;			
			tbTemp[50].TaskEvent[nTaskId].Series = nSeries;			
			tbTemp[50].TaskEvent[nTaskId].Num = nNum;			
			tbTemp[50].TaskEvent[nTaskId].ItemName = szItemName;	
			tbTemp[50].TaskEvent[nTaskId].Suffix = szSuffix;
			tbTemp[50].TaskEvent[nTaskId].Rate = nStepRate;
			tbTemp[50].TaskEvent[nTaskId].AwardExp = nAwardExp;
			tbTemp[50].TaskEvent[nTaskId].Money = nMoney;
			tbTemp[50].TaskEvent[nTaskId].NeedTime = nNeedTime;
			tbTemp[50].TaskEvent[nTaskId].StartDay = nStartDay;
			tbTemp[50].MaxRate = tbTemp[50].MaxRate + nStepRate;
			
			tbTemp[60].TaskEvent[nTaskId] = {};
			tbTemp[60].TaskEvent[nTaskId] = tbTemp[50].TaskEvent[nTaskId];
			tbTemp[60].MaxRate = tbTemp[60].MaxRate + nStepRate;
		end
		
		if nLevelFlag == 1 then
			tbTemp[60].TaskEvent[nTaskId] = {};
			tbTemp[60].TaskEvent[nTaskId].TaskName = szTaskName;
			tbTemp[60].TaskEvent[nTaskId].StepDesc = szStepDesc;
			tbTemp[60].TaskEvent[nTaskId].TaskType = szTaskType;
			tbTemp[60].TaskEvent[nTaskId].Genre = nGenre;
			tbTemp[60].TaskEvent[nTaskId].Detail = nDetail;
			tbTemp[60].TaskEvent[nTaskId].Particular = nParticular;
			tbTemp[60].TaskEvent[nTaskId].Level = nLevel;			
			tbTemp[60].TaskEvent[nTaskId].Series = nSeries;			
			tbTemp[60].TaskEvent[nTaskId].Num = nNum;			
			tbTemp[60].TaskEvent[nTaskId].ItemName = szItemName;	
			tbTemp[60].TaskEvent[nTaskId].Suffix = szSuffix;
			tbTemp[60].TaskEvent[nTaskId].Rate = nStepRate;
			tbTemp[60].TaskEvent[nTaskId].AwardExp = nAwardExp;
			tbTemp[60].TaskEvent[nTaskId].Money = nMoney;
			tbTemp[60].TaskEvent[nTaskId].NeedTime = nNeedTime;
			tbTemp[60].TaskEvent[nTaskId].StartDay = nStartDay;
			tbTemp[60].MaxRate = tbTemp[60].MaxRate + nStepRate;
		end
	end
end

function Merchant:LoadCollectItemFile(nTypeId, tbFile, nDiff, nRate)
	if self.TaskFile[nDiff] == nil then
		 self.TaskFile[nDiff] = {};
		 self.TaskFile[nDiff].MaxRate = 0;
		 self.TaskFile[nDiff].TypeClass = {};
	end
	if self.TaskFile[nDiff].TypeClass[nTypeId] == nil then
		self.TaskFile[nDiff].TypeClass[nTypeId] = {};
	end
	self.TaskFile[nDiff].TypeClass[nTypeId].Rate = nRate;
	self.TaskFile[nDiff].MaxRate = self.TaskFile[nDiff].MaxRate + nRate;
	for i = 2, #tbFile do

		local nStepRate = 0;
		if nDiff == 1 then
			nStepRate = tonumber(tbFile[i].Step01) or 0;
		elseif nDiff == 2 then
			nStepRate = tonumber(tbFile[i].Step02) or 0;
		else
			nStepRate = tonumber(tbFile[i].Step03) or 0;
		end		
		local nStartDay	 =  tonumber(tbFile[i].StartDay) or 0;
		local nLevelFlag =  tonumber(tbFile[i].LevelFlag) or 0;
		local nTaskId =  tonumber(tbFile[i].TaskId) or 0;
		local szTaskName =  Lib:ClearStrQuote(tbFile[i].TaskName);
		local szTaskType =  tbFile[i].TaskType;
		local szStepDesc =  Lib:ClearStrQuote(tbFile[i].StepDesc);
		local nGenre =  tonumber(tbFile[i].Genre) or 0;
		local nDetail =  tonumber(tbFile[i].Detail) or 0;
		local nParticular =  tonumber(tbFile[i].Particular) or 0;
		local nLevel =  tonumber(tbFile[i].Level) or 0;
		local nSeries =  tonumber(tbFile[i].Series) or 0;
		local nNum =  tonumber(tbFile[i].Num) or 1;
		local szItemName = tbFile[i].ItemName;
		local szSuffix = tbFile[i].Suffix;
		local nAwardExp = tonumber(tbFile[i].AwardExp) or 0;
		local nNeedTime = tonumber(tbFile[i].NeedTime) or 0;
		
		local tbTemp = self.TaskFile[nDiff].TypeClass[nTypeId];
			if tbTemp[50] == nil then
				tbTemp[50] = {};
				tbTemp[50].MaxRate = 0;
				tbTemp[50].TaskEvent = {};
			end
			
		if tbTemp[60] == nil then
				tbTemp[60] = {};
				tbTemp[60].MaxRate = 0;
				tbTemp[60].TaskEvent = {};
			end
		if nLevelFlag == 0 then
			tbTemp[50].TaskEvent[nTaskId] = {};
			tbTemp[50].TaskEvent[nTaskId].TaskName = szTaskName;
			tbTemp[50].TaskEvent[nTaskId].TaskType = szTaskType;
			tbTemp[50].TaskEvent[nTaskId].StepDesc = szStepDesc;
			tbTemp[50].TaskEvent[nTaskId].Genre = nGenre;
			tbTemp[50].TaskEvent[nTaskId].Detail = nDetail;
			tbTemp[50].TaskEvent[nTaskId].Particular = nParticular;
			tbTemp[50].TaskEvent[nTaskId].Level = nLevel;			
			tbTemp[50].TaskEvent[nTaskId].Series = nSeries;			
			tbTemp[50].TaskEvent[nTaskId].Num = nNum;			
			tbTemp[50].TaskEvent[nTaskId].ItemName = szItemName;	
			tbTemp[50].TaskEvent[nTaskId].Suffix = szSuffix;
			tbTemp[50].TaskEvent[nTaskId].Rate = nStepRate;
			tbTemp[50].TaskEvent[nTaskId].AwardExp = nAwardExp;
			tbTemp[50].TaskEvent[nTaskId].NeedTime = nNeedTime;
			tbTemp[50].TaskEvent[nTaskId].StartDay = nStartDay;
			tbTemp[50].MaxRate = tbTemp[50].MaxRate + nStepRate;
			
			tbTemp[60].TaskEvent[nTaskId] = {};
			tbTemp[60].TaskEvent[nTaskId] = tbTemp[50].TaskEvent[nTaskId];
			tbTemp[60].MaxRate = tbTemp[60].MaxRate + nStepRate;
		end
		
		if nLevelFlag == 1 then
			tbTemp[60].TaskEvent[nTaskId] = {};
			tbTemp[60].TaskEvent[nTaskId].TaskName = szTaskName;
			tbTemp[60].TaskEvent[nTaskId].TaskType = szTaskType;
			tbTemp[60].TaskEvent[nTaskId].StepDesc = szStepDesc;
			tbTemp[60].TaskEvent[nTaskId].Genre = nGenre;
			tbTemp[60].TaskEvent[nTaskId].Detail = nDetail;
			tbTemp[60].TaskEvent[nTaskId].Particular = nParticular;
			tbTemp[60].TaskEvent[nTaskId].Level = nLevel;			
			tbTemp[60].TaskEvent[nTaskId].Series = nSeries;			
			tbTemp[60].TaskEvent[nTaskId].Num = nNum;			
			tbTemp[60].TaskEvent[nTaskId].ItemName = szItemName;	
			tbTemp[60].TaskEvent[nTaskId].Suffix = szSuffix;
			tbTemp[60].TaskEvent[nTaskId].Rate = nStepRate;
			tbTemp[60].TaskEvent[nTaskId].AwardExp = nAwardExp;
			tbTemp[60].TaskEvent[nTaskId].NeedTime = nNeedTime;
			tbTemp[60].TaskEvent[nTaskId].StartDay = nStartDay;
			tbTemp[60].MaxRate = tbTemp[60].MaxRate + nStepRate;
		end
	end
end

function Merchant:GetAwardFix(bAddStoneAward)
	local tbFix = {};
	local nItemFree = 0; --物品空间
	if self.TaskAwardFile[self.TASKDATA_MAXCOUNT] == nil then
		return 0
	end
	for _, tb in pairs(self.TaskAwardFile[self.TASKDATA_MAXCOUNT]) do
		if tb.nMoney ~=0 then
			local tbTemp = {szType="activemoney",varValue=tb.nMoney, nSprIdx="",szDesc="",szCondition1="TaskAwardCond:None",szCondition2="TaskAwardCond:None",szCondition3="TaskAwardCond:None"};
			table.insert(tbFix, tbTemp)
		end
		if tb.nBindMoney ~= 0 then
			local tbTemp = {szType="bindmoney",varValue=tb.nBindMoney, nSprIdx="",szDesc="",szCondition1="TaskAwardCond:None",szCondition2="TaskAwardCond:None",szCondition3="TaskAwardCond:None"};
			table.insert(tbFix, tbTemp)			
		end
		if tb.nBaseExp ~=0 then
			local tbTemp = {szType="exp",varValue=tb.nBaseExp, nSprIdx="",szDesc="",szCondition1="TaskAwardCond:None",szCondition2="TaskAwardCond:None",szCondition3="TaskAwardCond:None"};
			table.insert(tbFix, tbTemp)
		end
		if tb.nGenre ~= 0 and tb.nDetail ~= 0 and tb.nParticular ~= 0 then
			local tbTemp = {szType="item",varValue={tb.nGenre,tb.nDetail,tb.nParticular,tb.nLevel,tb.nSeries,-1},nSprIdx="",szDesc="",szCondition1="TaskAwardCond:None",szCondition2="TaskAwardCond:None",szCondition3="TaskAwardCond:None",szAddParam1 = tb.nNum};
			local nId = self:CheckFixItem(tbFix, tbTemp.szType, tbTemp.varValue)
			if nId > 0 then
				tbFix[nId].szAddParam1 = tbFix[nId].szAddParam1 + tb.nNum;
			else
				table.insert(tbFix, tbTemp)
			end
			nItemFree = nItemFree + tb.nNum;
		end
	end
	if (bAddStoneAward and bAddStoneAward ~= 0) then		-- 插入宝石奖励
		for nStep, tbData in pairs(self.tbStoneAward) do
			if (nStep == self.TASKDATA_MAXCOUNT) then		-- 只有最后一部有固定奖励
				for _, tb in pairs(tbData) do
					local tbTemp = {szType="item",varValue={tb.nGenre,tb.nDetail,tb.nParticular,tb.nLevel,tb.nSeries,-1},nSprIdx="",szDesc="",szCondition1="TaskAwardCond:None",szCondition2="TaskAwardCond:None",szCondition3="TaskAwardCond:None",szAddParam1 = tb.nNum};
					local nId = self:CheckFixItem(tbFix, tbTemp.szType, tbTemp.varValue)
					if nId > 0 then
						tbFix[nId].szAddParam1 = tbFix[nId].szAddParam1 + tb.nNum;
					else
						table.insert(tbFix, tbTemp)
					end
					nItemFree = nItemFree + tb.nNum;
				end		
			end
		end		
	end
	return nItemFree, tbFix;
end

function Merchant:CheckFixItem(tbFix, szType, varValue)
	for nId, tbTemp in pairs(tbFix) do
		if tbTemp.szType == szType then
			if (tbTemp.varValue[1] == varValue[1] and
				tbTemp.varValue[2] == varValue[2] and
				tbTemp.varValue[3] == varValue[3] and
				tbTemp.varValue[4] == varValue[4] and
				tbTemp.varValue[5] == varValue[5]) then
				return nId;
			end
		end
	end
	return 0;
end

function Merchant:GetStepAward(nStep, nExp, nMoney)
	local szAwardDesc = "";
	local nItemFree = 0;
	local tbAward = {};
	if nStep == 0 then
		return szAwardDesc, tbAward, nItemFree;
	end
	if nExp > 0 then
		szAwardDesc = szAwardDesc .. string.format("  Nhận được %s kinh nghiệm\n", nExp);
		table.insert(tbAward, string.format("TaskAct:AddExp(%s)",nExp));
	end
	
	if nMoney and nMoney > 0 then
		szAwardDesc = szAwardDesc .. string.format("  Nhận được %s bạc\n", nMoney);
		table.insert(tbAward, string.format("TaskAct:GiveActiveMoney(%d, 0, 0, 0, %d)", nMoney, self.TASKDATA_ID));		
	end
	
	if self.TaskAwardFile[nStep] and nStep ~= self.TASKDATA_MAXCOUNT then
		szAwardDesc = szAwardDesc .. string.format("<color=gold>Phần thưởng bước %s:<color=white>\n", nStep);
		for _, tb in pairs(self.TaskAwardFile[nStep]) do
			if tb.nMoney ~=0 then
				table.insert(tbAward, string.format("TaskAct:GiveActiveMoney(%s, 0, 0, 0, %d)", tb.nMoney, self.TASKDATA_ID));
				szAwardDesc = szAwardDesc ..  string.format("  Nhận được %s bạc\n",tb.nMoney);
			end
			if tb.nBindMoney ~= 0 then
				table.insert(tbAward, string.format("TaskAct:SelBindMoney(%s, 1,  0, 0, 0, %d)", tb.nBindMoney, self.TASKDATA_ID));
				szAwardDesc = szAwardDesc ..  string.format("  Nhận được %s bạc khóa\n",tb.nBindMoney);				
			end
			if tb.nBaseExp ~=0 then
				table.insert(tbAward, string.format("TaskAct:AddExp(%s)", me.GetBaseAwardExp() * tb.nBaseExp));
				szAwardDesc = szAwardDesc ..  string.format("  Nhận được %s kinh nghiệm\n",tb.nBaseExp);
			end
			if tb.nGenre ~= 0 and tb.nDetail ~= 0 and tb.nParticular ~= 0 then
				table.insert(tbAward, string.format("TaskAct:AddItems({%s,%s,%s,%s},%s)", tb.nGenre,tb.nDetail,tb.nParticular,tb.nLevel, tb.nNum));
				szAwardDesc = szAwardDesc ..  string.format("  Nhận được %s %s\n",tb.nNum, tb.szName);
				nItemFree = nItemFree + 1;
			end
		end
	end
	
	return szAwardDesc, tbAward, nItemFree;
end

function Merchant:SyncTask(nTypeId, nStepType, nLevelType, nTaskId)
	local tbTargetFile = self.TaskFile[nStepType].TypeClass[nTypeId][nLevelType].TaskEvent[nTaskId];
	self:InitStep(nTypeId, nStepType, nLevelType, nTaskId, tbTargetFile)
end

function Merchant:InitStep(nTypeId, nStepType, nLevelType, nTaskId, tbTargetFile)

	local TbSubTask = {};
	local TBReferTask = {};
	if Task:GetPlayerTask(me).tbTasks[self.TASKDATA_ID] then
		Task:GetPlayerTask(me).tbTasks[self.TASKDATA_ID].tbReferData = self:NewRefer(self.TASKDATA_ID, self:GetTask(self.TASK_STONE_AWARD));
		Task:GetPlayerTask(me).tbTasks[self.TASKDATA_ID].tbSubData = self:NewSubTask(self.TASKDATA_ID);
		TbSubTask = Task:GetPlayerTask(me).tbTasks[self.TASKDATA_ID].tbSubData;
		TBReferTask = Task:GetPlayerTask(me).tbTasks[self.TASKDATA_ID].tbReferData;
	else
		return 0;
	end
	local nStep = self:GetTask(self.TASK_STEP_COUNT);
	local szTargetName = tbTargetFile.TaskType;
	local szTaskName = tbTargetFile.TaskName;
	local szStepDesc = tbTargetFile.StepDesc or "";
	local nGenre = tbTargetFile.Genre or self.DERIVEL_ITEM[1];
	local nDetail = tbTargetFile.Detail or self.DERIVEL_ITEM[2];
	local nParticular = tbTargetFile.Particular or self.DERIVEL_ITEM[3];
	local nLevel = tbTargetFile.Level or self.DERIVEL_ITEM[4];		
	local nSeries = tbTargetFile.Series or 0;			
	local nNum = tbTargetFile.Num or 1;	
	local szItemName = tbTargetFile.ItemName	
	local szSuffix = tbTargetFile.Suffix
	local nRate = tbTargetFile.Rate or 0;
	local nBaseExp = tbTargetFile.AwardExp or 0;
	local nMoney	= tbTargetFile.Money or 0;
	local nNeedTime = tbTargetFile.NeedTime
	local szNpcName = tbTargetFile.NpcName;
	local nMapId = tbTargetFile.MapId or 0;
	local nNpcId = tbTargetFile.NpcId or self.NPC_ID;
	local szSelect = "Nhiệm vụ thương hội";
	local szMsg1   = "Xin chào! Hoàn thành nhiệm vụ thương hội? Hãy đưa nó cho ta.";
	local szMsg2   = "Xin chào, bạn đã hoàn thành.";
	local ItemSet = nil;
	local szDesc = "";
	
	
	local nExp = math.floor(nBaseExp * nNeedTime * me.GetBaseAwardExp() / 60);
	
	if MODULE_GAMESERVER then
		--给箱子
		local tbFind1 = me.FindItemInBags(unpack(Merchant.MERCHANT_BOX_ITEM));
		local tbFind2 = me.FindItemInRepository(unpack(Merchant.MERCHANT_BOX_ITEM));
		if #tbFind1 <= 0 and #tbFind2 <= 0 and me.CountFreeBagCell() > 1 then
			me.AddItem(unpack(Merchant.MERCHANT_BOX_ITEM));	
		end
		
		--如果类型时送信的类型。则补给信
		if nTypeId == Merchant.TYPE_DELIVERITEM or nTypeId == Merchant.TYPE_DELIVERITEM_NEW then
			local tbFind1 = me.FindItemInBags(unpack(self.DERIVEL_ITEM));
			local tbFind2 = me.FindItemInRepository(unpack(self.DERIVEL_ITEM));
			if #tbFind1 <= 0 and #tbFind2 <= 0 then
				if me.CountFreeBagCell() >= 1 then
					me.AddItem(unpack(self.DERIVEL_ITEM));
				else
					me.Msg("Hành trang không đủ ，无法拿到商会信笺，请到商人处再领取。");
				end
			end
		end
	end
	if szTargetName == "GiveItem" then
		ItemSet = string.format("{%s,%s,%s,%s,%s,%s,%s}",szTaskName, nGenre, nDetail, nParticular, nLevel, nSeries, nNum);
		szDesc = string.format("Giao vật phẩm:\n %s %s", nNum, KItem.GetNameById(nGenre, nDetail, nParticular, nLevel));
	end
	
	if szTargetName == "GiveItemWithName" then
		ItemSet = {szItemName, szSuffix, nNum};
		szDesc = string.format("Giao vật phẩm:\n %s %s - %s", nNum, szItemName, szSuffix);
	end
	
	--描述：
	--TBReferTask.tbDesc.szMainDesc = "主任务描述内容";
	TBReferTask.tbDesc.tbStepsDesc[1] = szTaskName .. "\n".. szStepDesc;
	local tbParams = {nNpcId, nMapId, szSelect, szMsg1, szMsg2, ItemSet, nil, nil, szDesc, 1}	
	local szAwardDesc, tbExecute = self:GetStepAward(nStep, nExp, nMoney);
	TbSubTask.tbSteps[1].szAwardDesc = szAwardDesc;
	TbSubTask.tbSteps[1].tbExecute 	 = tbExecute;
	local tbTargets		= TbSubTask.tbSteps[1].tbTargets;
	local tbTagLib	= Task.tbTargetLib[szTargetName];
	assert(tbTagLib, "Target["..szTargetName.."] not found!!!");
	local tbTarget	= Lib:NewClass(tbTagLib);--根据函数名new目标
	tbTarget:Init(unpack(tbParams));--从子任务文件把目标数据读入
	tbTargets[1]	= tbTarget;
	if MODULE_GAMESERVER then
		me.CallClientScript({"Merchant:SyncTask", nTypeId, nStepType, nLevelType, nTaskId});
	end
end

function Merchant:SyncTaskExp()
	local nTypeId =  self:GetTask(self.TASK_TYPE);
	local nStepType  =  self:GetTask(self.TASK_STEP);
	local nLevel  =  self:GetTask(self.TASK_LEVEL);
	local nTaskId =  self:GetTask(self.TASK_NOWTASK);	
	local nNeedSec = self.TaskFile[nStepType].TypeClass[nTypeId][nLevel].TaskEvent[nTaskId].NeedTime;
	local nSec = GetTime() - self:GetTask(self.TASK_ACCEPT_STEP_TIME);
	local nAddSec = nSec;
	if nNeedSec < nSec then
		nAddSec = nNeedSec;
	end
	self:SetTask(self.TASK_ACCEPT_TASK_TIME, self:GetTask(self.TASK_ACCEPT_TASK_TIME) + nAddSec);	
	self:SetTask(self.TASK_ACCEPT_STEP_TIME, GetTime());
end

function Merchant:SyncTaskFixAward()
	local tbReferData = {};
	if Task:GetPlayerTask(me).tbTasks[self.TASKDATA_ID] then
		Task:GetPlayerTask(me).tbTasks[self.TASKDATA_ID].tbReferData = self:NewRefer(self.TASKDATA_ID, self:GetTask(self.TASK_STONE_AWARD));
		tbReferData = Task:GetPlayerTask(me).tbTasks[self.TASKDATA_ID].tbReferData;
	else
		return 0;
	end

	local nSec = math.floor(self:GetTask(self.TASK_ACCEPT_TASK_TIME) * me.GetBaseAwardExp() * 0.6 / 60);
	if nSec > 0 then
		local tbTemp = {szType="exp",varValue=nSec,nSprIdx="",szDesc="",szCondition1="TaskAwardCond:None",szCondition2="TaskAwardCond:None",szCondition3="TaskAwardCond:None"};
		table.insert(tbReferData.tbAwards.tbFix, tbTemp)
		if MODULE_GAMESERVER then
			me.CallClientScript({"Merchant:SyncTaskFixAward"});
		end	
	end
end

function Merchant:LoadDate(nTaskId)
	--self:_Debug(nTaskId, self.TASKDATA_ID)
	if nTaskId == self.TASKDATA_ID then
		
		--更换类型，步骤做相应兑换
		if MODULE_GAMESERVER 
		and self:GetTask(self.TASK_TYPE) <= 4 and self:GetTask(self.TASK_TYPE) > 0 and self:GetTask(self.TASK_RESET_NEWTYPE) == 0 then
			self:SetTask(self.TASK_RESET_NEWTYPE, 1);
			local nNewStep = math.floor(self:GetTask(self.TASK_STEP_COUNT)/10);
			if nNewStep == 0 then
				nNewStep = 1;
			end
			self:SetTask(self.TASK_STEP_COUNT, nNewStep);
		end
		
		if self:GetTask(self.TASK_OPEN) == 1 then
			return 0;
		end
		local nTypeId =  self:GetTask(self.TASK_TYPE);
		local nStepType =  self:GetTask(self.TASK_STEP);
		local nLevelType  =  self:GetTask(self.TASK_LEVEL);
		local nNowTaskId =  self:GetTask(self.TASK_NOWTASK);
		if nTypeId == 0 or nStepType ==0 or nLevelType == 0 or nNowTaskId == 0 then
			return 0;
		end
		self:SyncTask(nTypeId, nStepType, nLevelType, nNowTaskId);	
	end
	--self:_Debug(nTaskId, self.TASKDATA_ID)
end

