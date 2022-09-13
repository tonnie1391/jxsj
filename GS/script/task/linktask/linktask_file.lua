
-- ====================== 文件信息 ======================

-- 剑侠世界门派任务链头文件（第二版）
-- Edited by peres
-- 2007/12/11 PM 08:50

-- 很多事情不需要预测
-- 预测会带来犹豫
-- 因为心里会有恐惧

-- ======================================================

LinkTask.tbfile_SubTask		= {};	-- 子任务的表格内容集合
LinkTask.tbSubTaskData		= {};	-- 子任务的缓存数据

-- 初始化任务链表格
function LinkTask:InitFile()
	-- 根据等级段来选择任务
	self.tbfile_TaskLevelGroup		= Lib:NewClass(Lib.readTabFile, "\\setting\\task\\linktask\\level_group.txt");
	
	-- 各种任务类型的权重
	self.tbfile_TaskType			= Lib:NewClass(Lib.readTabFile, "\\setting\\task\\linktask\\type_select.txt");
	
	for i=1, self.tbfile_TaskType:GetRow() do
		
		local nMainTaskId	= self.tbfile_TaskType:GetCellInt("TypeId", i);
		local szEntityFile	= self.tbfile_TaskType:GetCell("FileName", i);
		
		if nMainTaskId>0 and szEntityFile~="" then
			self:_Debug("Start create entity file: ", nMainTaskId, szEntityFile);
			self.tbfile_SubTask[nMainTaskId]		= Lib:NewClass(Lib.readTabFile, "\\setting\\task\\linktask\\"..szEntityFile);		
		end;
	end;
	
	self:ReadTaskFile();
end;

function LinkTask:ReadTaskFile()
	
	for nMainTaskId, _ in pairs(self.tbfile_SubTask) do

		self:_ReadTask(nMainTaskId);
		
		local tabfileSubTask	= self.tbfile_SubTask[nMainTaskId];
		
		for i=1, tabfileSubTask:GetRow() do
			local nSubTaskId		= tabfileSubTask:GetCellInt("TaskId", i); -- 引用子任务Id
			local szTargetName		= tabfileSubTask:GetCell("TaskType", i);
			local szTaskName		= tabfileSubTask:GetCell("TaskName", i);
			
			local tbParams			= {};
			
			-- 找物品任务
			if szTargetName == "SearchItemWithDesc" then
				local nGenre, nDetail, nParticular, nLevel, nSeries, nNum = 0,0,0,0,0,0;
				local szItemName		= "";
				
				nGenre		= tabfileSubTask:GetCellInt("Genre", i);
				nDetail		= tabfileSubTask:GetCellInt("Detail", i);
				nParticular	= tabfileSubTask:GetCellInt("Particular", i);
				nLevel		= tabfileSubTask:GetCellInt("Level", i);
				nSeries		= tabfileSubTask:GetCellInt("Series", i);
				nNum		= tabfileSubTask:GetCellInt("Num", i);
				szItemName	= tabfileSubTask:GetCell("ItemName", i);
	
				tbParams	= {szItemName, 
								nGenre, nDetail, nParticular, nLevel, nSeries, "", 
								nNum, 1};
			end;
			
			if szTargetName == "KillNpc" then
				local nMapId		= tabfileSubTask:GetCellInt("MapId", i);
				local nNpcId		= tabfileSubTask:GetCellInt("NpcId", i);
				local nCount		= tabfileSubTask:GetCellInt("Num", i);
				
				tbParams	= {nNpcId, nMapId, nCount};
			end;
			
			if szTargetName == "SearchItemBySuffix" then
				local szItemName	= tabfileSubTask:GetCell("ItemName", i);
				local szSuffix		= tabfileSubTask:GetCell("Suffix", i);
				local nCount		= tabfileSubTask:GetCellInt("Num", i);
				
				tbParams	= {szItemName, szSuffix, nCount, 1};
			end;
						
			-- 服务端才载入子任务
			if (MODULE_GAMESERVER) then
				self:_ReadSubTask(nSubTaskId, szTaskName, szTargetName, tbParams);
				-- self:_Debug("Find item id: ", nSubTaskId, szTaskName, unpack(tbParams));
			else
				-- 给客户端用的缓存
				if self.tbSubTaskData[nSubTaskId]==nil then
					self.tbSubTaskData[nSubTaskId] = {};
				end;
				self.tbSubTaskData[nSubTaskId].szTaskName		= szTaskName;
				self.tbSubTaskData[nSubTaskId].szTargetName		= szTargetName;
				self.tbSubTaskData[nSubTaskId].tbParams			= tbParams;
			end;
		end;
	end;
end;

function LinkTask:_ReadTask(nTaskId)
	
	local tbTaskData	= {};
	tbTaskData.nId		= nTaskId;
	tbTaskData.szName	= "["..self:GetMainTaskName(nTaskId).."]";
	
	
	-- 主任务的基础属性
	local tbAttribute	= {};
	tbTaskData.tbAttribute	= tbAttribute;
	
	tbAttribute["Order"]		= Lib:Str2Val("linear");	-- 任务流程：线性
	tbAttribute["Repeat"]		= Lib:Str2Val("true");		-- 是否可重做：是
	tbAttribute["Context"]		= Lib:Str2Val("");			-- 任务描述
	tbAttribute["Share"]		= Lib:Str2Val("false");		-- 是否可共享
	tbAttribute["TaskType"]		= Lib:Str2Val("3");			-- 任务类型：3、随机任务
	tbAttribute["AutoTrack"]	= Lib:Str2Val("true");
	
	-- 主任务下的子任务
	local tbReferIds	= {};
	tbTaskData.tbReferIds	= tbReferIds;

	-- 任务的内容表
	local tabfileSubTask	= self.tbfile_SubTask[nTaskId];

	-- 在这里循环将子任务放到任务 table 里去
	
	self:_Debug("Start read subtask in maintask!");
	
	for i=1, tabfileSubTask:GetRow() do

		local nReferId		= tabfileSubTask:GetCellInt("TaskId", i); -- 引用子任务Id
		local nReferIdx		= #tbReferIds + 1;	-- 引用子任务索引
		local tbReferData	= {};
		
		-- 不能存在已有的任务
		assert(not Task.tbReferDatas[nReferId]);
		
		Task.tbReferDatas[nReferId]	= tbReferData;
		
		tbReferIds[nReferIdx]		= nReferId;
		tbReferData.nReferId		= nReferId;
		tbReferData.nReferIdx		= nReferIdx;
		tbReferData.nTaskId			= nTaskId;
		tbReferData.nSubTaskId		= tabfileSubTask:GetCellInt("TaskId", i);
		tbReferData.szName			= tabfileSubTask:GetCell("TaskName", i);
		tbReferData.tbDesc			= "";
		
		tbReferData.tbVisable	= {};	-- 可见条件
		tbReferData.tbAccept	= {}; 	-- 可接条件
		
		tbReferData.nAcceptNpcId	= 0;
		
		tbReferData.bCanGiveUp	= Lib:Str2Val("false");
		
		tbReferData.szGossip = "";			-- 流言文字
		tbReferData.nReplyNpcId	= 0;		-- 回复 NPC
		tbReferData.szReplyDesc	= "";		-- 回复文字
		tbReferData.nBagSpaceCount = 0;		-- 背包空间检查
		tbReferData.nLevel = 1;
		tbReferData.szIntrDesc = "";
		tbReferData.nDegree = 100;
		tbReferData.tbAwards	= {
			tbFix	= {},
			tbOpt	= {},
			tbRand	= {},
		};
		
		self:_Debug("Read sub task: "..tbReferData.szName.."  Refer Id: "..nReferId.."  Refer Idx: "..nReferIdx);
	end;
	
	Task.tbTaskDatas[nTaskId]	= tbTaskData;
	return tbTaskData;
end;

-- 读入子任务，子任务 id，子任务类型（杀怪、寻物等），任务中文名
function LinkTask:_ReadSubTask(nSubTaskId, szTaskName, szTargetName, tbParams)

	local tbSubData		= {};
	tbSubData.nId		= nSubTaskId;
	tbSubData.szName	= "["..szTaskName.."]";
	tbSubData.szDesc	= "";
	
	tbSubData.tbSteps	= {};
	tbSubData.tbExecute = {};
	tbSubData.tbStartExecute = {};
	tbSubData.tbFailedExecute = {};
	tbSubData.tbFinishExecute = {};
	-- 任务属性
	local tbAttribute	= {};
	tbSubData.tbAttribute	= tbAttribute;
	
	-- 开始对话
	local tbDialog	= {};
	tbAttribute.tbDialog	= tbDialog;
	tbAttribute.tbDialog["Start"] = {szMsg= ""};
	tbAttribute.tbDialog["Procedure"] = {szMsg = ""};
	tbAttribute.tbDialog["Error"] = {szMsg = ""};
	tbAttribute.tbDialog["Prize"] = {szMsg = ""};
	tbAttribute.tbDialog["End"] = {szMsg = ""};	

	-- 步骤
	local tbStep	= {};
	table.insert(tbSubData.tbSteps, tbStep);

	-- 开始事件，这里设一个空的 npc
	local tbEvent	= {};
	tbStep.tbEvent	= tbEvent;
	tbEvent.nType	= 1;
	tbEvent.nValue	= 0;

	-- 任务目标
	local tbTargets		= {};
	tbStep.tbTargets	= tbTargets;


	local tbTagLib	= Task.tbTargetLib[szTargetName];
	assert(tbTagLib, "Target["..szTargetName.."] not found!!!");
	local tbTarget	= Lib:NewClass(tbTagLib);--根据函数名new目标
	tbTarget:Init(unpack(tbParams));--从子任务文件把目标数据读入
	tbTargets[#tbTargets+1]	= tbTarget;


	-- 步骤条件
	tbStep.tbJudge	= {};
	tbStep.tbExecute = {};

	
	Task.tbSubDatas[nSubTaskId]	= tbSubData;
	return tbSubData;
end;

-- 根据一个主任务 Id 来获取该主任务的中文名
function LinkTask:GetMainTaskName(nTaskId)
	local nRow =	self.tbfile_TaskType:GetDateRow("TypeId", nTaskId);
		if nRow == 0 then
			self:_Debug("GetMainTaskName Error!");
			return "";
		end;
	return self.tbfile_TaskType:GetCell("TypeName", nRow);
end;


function LinkTask:_Debug(...)
--	print ("[LinkTask]: ", unpack(arg));
end;
