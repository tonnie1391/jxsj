Require("\\script\\task\\linktask\\linktask_head.lua");

-------------------------------------------------------------------------
 -- 目标库
if (not Task.tbTargetLib) then
	Task.tbTargetLib	= {};
end;

-------------------------------------------------------------------------------
-- 获取任务目标，主要用于目标定义
function Task:GetTarget(szTarget)
	local tbTarget	= self.tbTargetLib[szTarget];
	if (not tbTarget) then
		tbTarget	= {};
		self.tbTargetLib[szTarget]	= tbTarget;
		self.tbTargetLib[szTarget].Base_GetPlayerObj = self.GetPlayerObj;
	end;
	return tbTarget;
end;


function Task:GetPlayerObj()
	if MODULE_GAMESERVER then
		return KPlayer.GetPlayerObjById(self.nPlayerId);
	elseif MODULE_GAMECLIENT then
		return me;
	else
		return nil;
	end
end

-------------------------------------------------------------------------
-- 任务系统初始化，载入200个任务文件和600个子任务文件
function Task:OnInit()
	local nTaskCount	= 0;
	local nSubCount		= 0;
	self:LoadText();
	for i = 1, 600 do
		if (self:LoadTask(i)) then
			nTaskCount	= nTaskCount + 1;
		end
	end

	-- Warring:liuchang 如果有太多的话就会有字符串Id重复，目前底层是把字符HASH成一个Id
	-- 00000000000003c9.xml和0000000000000010.xml冲突了 my god,6年前写了一个warring，今天出问题了
	if (MODULE_GAMESERVER) then
		for i = 1, 900 do
			if (self:LoadSub(i)) then
				nSubCount	= nSubCount + 1;
			end
		end
	end
	
	
	print(string.format("Task System Inited! %d task(s) and %d subtask(s) loaded!", nTaskCount, nSubCount));
	
	self:LoadLevelRangeInfo();
	self:LoadTaskTypeFile();
	self:LoadBossDeathShareInfo();
	LinkTask:InitFile();	--包万同任务
	TreasureMap:OnInit();	--藏宝图任务
	Merchant:InitFile();	--商会任务
	Wanted:InitFile();		--官府通缉任务
	XiakeDaily:InitFile();	--侠客日常任务
	WeekendFish:InitFile();	-- 周末钓鱼任务
	Keyimen:InitFile();		-- 克夷门帮会任务
end

-------------------------------------------------------------------------
-- 玩家上线，先载入这个玩家的任务数据
function Task:OnLogin()
	Dialog:SetTrackTask(me, false);
	self:LoadData();
	me.SyncTaskGroup(1000); -- 同步已完成的任务,nGroupId = 1000, nTaskValueId = nTaskId, nTaskValue = nLastRefId
	Dialog:SetTrackTask(me, true);
end


-------------------------------------------------------------------------
-- 玩家下线，保存任务数据
function Task:OnLogout()
	if (MODULE_GAMESERVER) then
		local tbPlayerTask	= self:GetPlayerTask(me);
		for _, tbTask in pairs(tbPlayerTask.tbTasks) do
			tbTask:SaveData();
			tbTask:CloseCurStep("logout");
		end
		
		print(string.format("Player[%s] %d task(s) saved.", me.szName, tbPlayerTask.nCount));
	end
end



-------------------------------------------------------------------------
-- 根据玩家任务变量，载入已接任务，每个任务变量组前面4个都有特殊意义
function Task:LoadData()
	local nCount = 0;
	for nSaveGroup = self.TASK_GROUP_MIN, self.TASK_GROUP_MAX do
		local nReferId	= me.GetTask(nSaveGroup, self.emSAVEID_REFID);
		if (nReferId ~= 0) then
			local tbTask	= self:NewTask(nReferId);
			if (tbTask) then
				tbTask:LoadData(nSaveGroup);-- 载入这个任务的数据，比如当前目标和步骤
				nCount	= nCount + 1;
			else
				--任务不存在（义军任务删过任务，处理一下过期任务）
				if Task:GetTaskType(nReferId) == "LinkTask" then
					me.SetTask(nSaveGroup, self.emSAVEID_TASKID, 0);
					me.SetTask(nSaveGroup, self.emSAVEID_REFID, 0);
					me.SetTask(nSaveGroup, self.emSAVEID_CURSTEP, 0);
					me.SetTask(nSaveGroup, self.emSAVEID_ACCEPTDATA, 0);
					me.Msg("Nhiệm vụ ngẫu nhiên bị xóa");
					Dbg:WriteLog("Task","ClearErrorTask", nReferId);
				end
			end
		end;
	end;
	
	print(string.format("Player[%s] %d task(s) loaded.", me.szName, nCount));
end;


-------------------------------------------------------------------------
-- 任务存入玩家任务变量
function Task:SaveData()
	local tbPlayerTask	= self:GetPlayerTask(me);
	for _, tbTask in pairs(tbPlayerTask.tbTasks) do
		tbTask:SaveData();
	end;
	print(string.format("Player[%s] %d task(s) saved.", me.szName, tbPlayerTask.nCount));
end;



-------------------------------------------------------------------------
-- [S]通知客户端弹出接受任务对话框
function Task:AskAccept(nTaskId, nReferId, pSharedPlayer)
	local nSharedPlayerId = -1;
	
	if (self.tbTaskDatas[nTaskId] and self.tbTaskDatas[nTaskId].tbAttribute["Repeat"]) then
		if (self:CanAcceptRepeatTask() ~= 1) then
			if (pSharedPlayer) then
				pSharedPlayer.Msg(me.szName.."Nhiệm vụ tuần hoàn của hôm nay đã hết, không thể nhận nhiệm vụ chia sẻ");
			end
			
			return;
		end
	end

	if (pSharedPlayer) then
		nSharedPlayerId = pSharedPlayer.nId;
	end
	
	self:GetPlayerTask(me).tbAskAccept	= { -- 防止客户端作弊(没接任务也发送接任务请求)
		nTaskId			= nTaskId,
		nReferId		= nReferId,
		nAskDate		= GetCurServerTime(),
		nSharedPlayerId	= nSharedPlayerId; 
	};
	KTask.SendAccept(me, nTaskId, nReferId);
	return 1;
end;


-------------------------------------------------------------------------
-- 接到客户端确认接受
function Task:OnAccept(nTaskId, nReferId, bAccept)
	if (self.tbTaskDatas[nTaskId] and 
		not self.tbTaskDatas[nTaskId].tbAttribute["Repeat"] and
		Task:HaveDoneSubTask(me, nTaskId, nReferId) == 1) then
		me.Msg("Bạn đã hoàn thành nhiệm vụ này rồi!");
		local szMsg = "TaskId: " .. nTaskId .. "ReferId"  .. nReferId;
		Dbg:WriteLog("Task", "任务重复", me.szAccount, me.szName, szMsg);
		BlackSky:GiveMeBright(me);
		return;
	end;
	
	BlackSky:GiveMeBright(me);
	local tbPlayerTask	= self:GetPlayerTask(me);
	local tbAskAccept	= tbPlayerTask.tbAskAccept;
	if (not tbAskAccept or tbAskAccept.nTaskId ~= nTaskId or tbAskAccept.nReferId ~= nReferId) then -- 校验客户端是否作弊(没接任务也发送接任务请求)
		return;
	end
	local nSharedPlayerId	= tbAskAccept.nSharedPlayerId;
	
	local pSharedPlayer = KPlayer.GetPlayerObjById(nSharedPlayerId);
	
	tbPlayerTask.tbAskAccept	= nil;
	
	-- 重复任务需要检查可接次数
	if (self.tbTaskDatas[nTaskId].tbAttribute["Repeat"]) then
		if (self:CanAcceptRepeatTask() ~= 1) then
			Dialog:SendInfoBoardMsg(me, "Nhiệm vụ tuần hoàn mỗi ngày chỉ có thể nhận 10 lần!");
			return;
		end
	end
	
	if (bAccept == 0) then
		if (pSharedPlayer) then
			pSharedPlayer.Msg(me.szName.."Từ chối nhiệm vụ bạn chia sẻ"..self.tbTaskDatas[nTaskId].szName);
		end
		
		return 1;
	end
	
	if (pSharedPlayer) then
		pSharedPlayer.Msg(me.szName.."Đồng ý nhiệm vụ bạn chia sẻ"..self.tbTaskDatas[nTaskId].szName);
	end
	
	return self:DoAccept(nTaskId, nReferId);
end


-------------------------------------------------------------------------
-- 立即接受任务
function Task:DoAccept(nTaskId, nReferId)
	if (type(nTaskId) == "string") then
		nTaskId = tonumber(nTaskId, 16);
	end
	if (type(nReferId) == "string") then
		nReferId = tonumber(nReferId, 16);
	end
	
	if (not nTaskId or not nReferId) then
		assert(false);
		return;
	end
	
	local tbTaskData	= self.tbTaskDatas[nTaskId];
	local tbReferData	= self.tbReferDatas[nReferId];
	if (not tbReferData) then
		return;
	end
	
	if me.GetTiredDegree1() == 2 then
		me.Msg("Bạn đã quá mệt, hãy nghỉ ngơi!");
		return;
	end
	
	-- 判断可接条件
	if (tbReferData.tbAccept) then
		local bOK, szMsg	= Lib:DoTestFuncs(tbReferData.tbAccept);
		if (not bOK) then
			Dialog:SendInfoBoardMsg(me, szMsg)
			return nil;
		end;
	end;
	
	local tbUsedGroup	= {};
	-- 标记已经使用过的Group
	for _, tbTask in pairs(self:GetPlayerTask(me).tbTasks) do
		tbUsedGroup[tbTask.nSaveGroup]	= 1;
	end;
	-- 找出空闲的可以使用的Group
	local nSaveGroup	= nil;
	for n = self.TASK_GROUP_MIN, self.TASK_GROUP_MAX do
		if (not tbUsedGroup[n]) then
			nSaveGroup	= n;
			break;
		end;
	end;
	if (not nSaveGroup) then
		Dialog:SendInfoBoardMsg(me, "Nhiệm vụ của bạn đã đầy!");
		return nil;
	end;

	-- 若是物品触发，检查玩家身上是否有此物品，有则删除，没有就返回nil
	if (tbReferData.nParticular) then
		local tbItemId = {20,1,tbReferData.nParticular,1};
		if (not self:DelItem(me, tbItemId, 1)) then
			Dialog:SendInfoBoardMsg(me, "Không có vật phẩm chỉ định, không nhận được nhiệm vụ!");
			return nil;
		end
	end
	
	-- 建立此任务的实例
	local tbTask	= self:NewTask(nReferId);
	if (not tbTask) then
		return nil;
	end;
	
	Merchant:DoAccept(tbTask, nTaskId, nReferId);
	XiakeDaily:DoAccept(tbTask, nTaskId, nReferId);
	WeekendFish:DoAccept(tbTask, nTaskId, nReferId);
	Keyimen:DoAccept(tbTask, nTaskId, nReferId);
	
	-- 重复任务需要设置已接次数
	if (self.tbTaskDatas[nTaskId].tbAttribute["Repeat"] and tbReferData.nSubTaskId < 10000) then
		local nAcceptTime = me.GetTask(2031, 1);
		assert(nAcceptTime < self.nRepeatTaskAcceptMaxTime);
		me.SetTask(2031, 1, nAcceptTime + 1, 1);
	end
	
	tbTask.nAcceptDate	= GetCurServerTime();
	tbTask.nSaveGroup	= nSaveGroup;
	me.Msg("Nhận được nhiệm vụ mới: "..tbTask:GetName());
	tbTask:SetCurStep(1);
	me.CastSkill(self.nAcceptTaskSkillId,1,-1, me.GetNpc().nIndex);
	
	local tbStartExecute = tbTask.tbSubData.tbStartExecute;
	if (tbStartExecute and #tbStartExecute > 0) then
		Lib:DoExecFuncs(tbStartExecute);
	end;
	
	self:LogAcceptTask(nTaskId, nReferId);
	--写Log
--	if tbTask.tbTaskData.tbAttribute.TaskType == 1 then		
--		local szTaskName = self:GetTaskName(tbTask.nTaskId);
--		local szSubTaskName = self:GetManSubName(tbTask.nReferId);
--		KStatLog.ModifyField("roleinfo", me.szName, "主线："..szTaskName, szSubTaskName);
--	end
	return tbTask;
end;

function Task:LogAcceptTask(nTaskId, nReferId)
	if (nTaskId == 226 or nTaskId == 337 or nTaskId == 338 or nTaskId == 363 or nTaskId == 365 or nTaskId == 367) then -- 剧情
		Task.tbArmyCampInstancingManager.StatLog:WriteLog(2, 1);
	elseif (nTaskId == 227 or nTaskId == 333 or nTaskId == 334 or nTaskId == 364 or nTaskId == 366 or nTaskId == 368) then -- 日常
		Task.tbArmyCampInstancingManager.StatLog:WriteLog(3, 1);
	elseif (nTaskId >= 269 and nTaskId <= 280) then
		Task.tbArmyCampInstancingManager.StatLog:WriteLog(10, 1);
	end
	if self.tbOtherTask[nTaskId] and self.tbOtherTask[nTaskId][1] == nReferId then
		StatLog:WriteStatLog("stat_info", self.tbOtherTask[nTaskId][2], "get_task", me.nId, nTaskId, nReferId);
	end
end


function Task:LogFinishTask(nTaskId)
	if (nTaskId == 226 or nTaskId == 337 or nTaskId == 338 or nTaskId == 363 or nTaskId == 365 or nTaskId == 367) then
		Task.tbArmyCampInstancingManager.StatLog:WriteLog(4, 1);
	elseif (nTaskId == 227 or nTaskId == 333 or nTaskId == 334 or nTaskId == 364 or nTaskId == 366 or nTaskId == 368) then
		Task.tbArmyCampInstancingManager.StatLog:WriteLog(5, 1);
	end
end
-------------------------------------------------------------------------
-- 建立玩家当前任务数据
function Task:NewTask(nReferId)
	local tbReferData	= self.tbReferDatas[nReferId];
	if (not tbReferData) then
		me.Msg("Nhiệm vụ ngẫu nhiên - " .. nReferId);
		return nil;
	end
	
	local nTaskId		= tbReferData.nTaskId;
	local nSubTaskId	= tbReferData.nSubTaskId;
	local tbTaskData	= self.tbTaskDatas[nTaskId];
	local tbSubData		= self.tbSubDatas[nSubTaskId];

	-- 获得玩家的任务 
	local tbPlayerTask	= self:GetPlayerTask(me);
	if (tbPlayerTask.tbTasks[nTaskId]) then
		me.Msg("Nhiệm vụ tuần hoàn - " .. tbTaskData.szName);
		return nil;
	end;

	local tbTask		= Lib:NewClass(self._tbClassBase);
	tbTask.nTaskId		= nTaskId;
	tbTask.nSubTaskId	= nSubTaskId;
	tbTask.nReferId		= nReferId;
	tbTask.tbTaskData	= tbTaskData;
	tbTask.tbSubData	= tbSubData;
	tbTask.tbReferData	= tbReferData;
	tbTask.tbCurTags	= {};
	tbTask.nAcceptDate	= 0;
	tbTask.nCurStep		= 0;
	tbTask.nSaveGroup	= 0;
	tbTask.me			= me;
	tbTask.nPlayerId		= me.nId;
	tbTask.tbNpcMenus	= {};
	
	tbTask.nLogMoney	= 0;

	tbPlayerTask.tbTasks[nTaskId]	= tbTask;
	tbPlayerTask.nCount	= tbPlayerTask.nCount + 1;
	return tbTask;
end;



-------------------------------------------------------------------------
-- 接到客户端放弃
function Task:OnGiveUp(nTaskId, nReferId)
	local tbPlayerTask	= self:GetPlayerTask(me);
	local tbTask	= tbPlayerTask.tbTasks[nTaskId];
	
	if (not tbTask or tbTask.nReferId ~= nReferId) then
		me.Msg("Hủy thất bại: Không có nhiệm vụ này");
		return;
	end

	if (not tbTask.tbReferData.bCanGiveUp) then
		me.Msg("Hủy thất bại: Không thể hủy nhiệm vụ này");
		return;
	end
	
	self:CloseTask(nTaskId, "giveup");
end


-------------------------------------------------------------------------
-- [S]接到客户端申请共享
function Task:OnShare(nTaskId, nReferId)
	local tbPlayerTask	= self:GetPlayerTask(me);
	local tbTask	= tbPlayerTask.tbTasks[nTaskId];
	
	if (not tbTask or tbTask.nReferId ~= nReferId) then
		me.Msg("Chia sẻ thất bại: Không có nhiệm vụ này");
		return;
	end

	if (not tbTask.tbTaskData.tbAttribute["Share"]) then
		me.Msg("Chia sẻ thất bại: Nhiệm vụ này không thể chia sẻ");
		return;
	end
	
	local tbTeamMembers, nMemberCount	= me.GetTeamMemberList();
	if (not tbTeamMembers) then
		Dialog:SendInfoBoardMsg(me, "Chia sẻ thất bại: Chưa có tổ đội!");
		return;
	end
	if (nMemberCount <= 0) then
		Dialog:SendInfoBoardMsg(me, "Chia sẻ thất bại: Đội ngũ chưa có thành viên!");
		return;
	end
	
	-- 只有玩家处于这个任务的第一个引用子任务的时候才能共享
	if (self:GetFinishedRefer(nTaskId) > 0) then
		me.Msg("Chia sẻ thất bại: Nhiệm vụ này không có trong chuỗi nhiệm vụ!");
		return;
	end
	
	local tbReferData	= self.tbReferDatas[nReferId];
	local tbVisable	= tbReferData.tbVisable;
					
	local plOld	= me;
	local nOldPlayerIdx = me.nPlayerIndex;
	for i = 1, nMemberCount do
		me	= tbTeamMembers[i];
		if (me.nPlayerIndex ~= nOldPlayerIdx) then
			if (Task:AtNearDistance(me, plOld) == 1) then
				local tbPlayerTask = self:GetPlayerTask(me);
				if (not tbPlayerTask.tbTasks[nTaskId]) then
					if (self:GetFinishedRefer(nTaskId) <= 0) then  -- 只有从没接这个任务的队友才能接受
						if (Lib:DoTestFuncs(tbVisable)) then
							self:AskAccept(nTaskId, nReferId, plOld);
						else
							plOld.Msg(me.szName.."Không đủ điều kiện để nhận nhiệm vụ!")
						end
					else
						plOld.Msg(me.szName.." đã có nhiệm vụ này rồi!");
					end
				end
			else
				plOld.Msg(me.szName.." quá xa, không thể chia sẻ nhiệm vụ!");
			end
		end
	end
	me	= plOld;
end


-------------------------------------------------------------------------
-- 接到客户端领奖
function Task:OnAward(nTaskId, nReferId, nChoice)
	-- 需判断是否会接下一个子任务
	BlackSky:GiveMeBright(me);
	if (nChoice == -1) then
		me.Msg("Chưa nhận thưởng không thể hoàn thành nhiệm vụ. Bạn có thể quay lại nhận phần thưởng!");
		return;
	end;
	local tbPlayerTask	= self:GetPlayerTask(me);
	local tbTask	= tbPlayerTask.tbTasks[nTaskId];
	if (not tbTask or tbTask.nCurStep ~= -1) then --防止客户端舞弊
		me.Msg("Không có nhiệm vụ này hoặc chưa hoàn thành!");
		return;
	end
	
	if (tbTask and tbTask.nReferId ~= nReferId) then -- 错误的ReferId
		return;
	end
	local tbTaskType = {
		[226] = 1,	--军营剧情
		[337] = 1,
		[338] = 1,
		[363] = 1,
		[365] = 1,
		[367] = 1,
		[483] = 1,
		[493] = 1,
		[484] = 1,
		[494] = 1,
		[227] = 2,	--军营日常
		[333] = 2,
		[334] = 2,
		[364] = 2,
		[366] = 2,
		[368] = 2,
		[491] = 2,
		[492] = 2,
		[485] = 2,
		[495] = 2,
		[50000] = 3, --商会任务
		[429] = 4, -- 无尽的征程
		[490] = 4,
		[488] = 4,
	};
	local nFreeCount = 0;
	local tbFunExecute = {};
	if tbTaskType[nTaskId] == 1 or tbTaskType[nTaskId] == 2 then
		nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("ArmyCampTask", me, tbTaskType[nTaskId]);
	end
	
	if tbTaskType[nTaskId] == 3 then
		nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("MerchantTask", me);
	end
	
	if tbTaskType[nTaskId] == 4 then
		nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("EverQuest", me);
	end
	
	if (not TaskCond:HaveBagSpace(tbTask.tbReferData.nBagSpaceCount+nFreeCount)) then
		Dialog:SendInfoBoardMsg(me, "Thu xếp túi còn "..(tbTask.tbReferData.nBagSpaceCount + nFreeCount).." ô trống rồi quay lại nhận thưởng");
		return;
	end

	if tbTaskType[nTaskId] == 1 then	-- 完成剧情
--		me.AddOfferEntry(80, WeeklyTask.GETOFFER_TYPE_ARMYCAMP);
--		me.AddKinSKillExp(80, WeeklyTask.GETOFFER_TYPE_ARMYCAMP);
--		me.AddKinSkillOffer(80, WeeklyTask.GETOFFER_TYPE_ARMYCAMP);
		-- 增加帮会建设资金和相应族长、个人的股份		
--		local nStockBaseCount = 50; -- 股份基数			
--		Tong:AddStockBaseCount_GS1(me.nId, nStockBaseCount, 0.8, 0.15, 0.05, 0, 0, WeeklyTask.GETOFFER_TYPE_ARMYCAMP);
		SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
		
		-- 成就：完成军营任务
		Achievement_ST:FinishAchievement(me.nId, Achievement_ST.ARMYCAMP);
		
		self:AwardZhenYuanExp(1);
		
		local tbInfo = Kinsalary.EVENT_TYPE[Kinsalary.EVENT_JUNYING];
		Kinsalary:AddSalary_GS(me, Kinsalary.EVENT_JUNYING, tbInfo.nRate);
		
	elseif tbTaskType[nTaskId] == 2 then	-- 完成日常
--		me.AddOfferEntry(40, WeeklyTask.GETOFFER_TYPE_ARMYCAMP);
--		me.AddKinSKillExp(40, WeeklyTask.GETOFFER_TYPE_ARMYCAMP);
--		me.AddKinSkillOffer(40, WeeklyTask.GETOFFER_TYPE_ARMYCAMP);
		-- 增加帮会建设资金和相应个人的股份		
--		local nStockBaseCount = 20; -- 股份基数				
--		Tong:AddStockBaseCount_GS1(me.nId, nStockBaseCount, 0.8, 0.15, 0.05, 0, 0, WeeklyTask.GETOFFER_TYPE_ARMYCAMP);
		SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
		-- 成就：完成军营任务
		Achievement_ST:FinishAchievement(me.nId, Achievement_ST.ARMYCAMP);
		
		local tbInfo = Kinsalary.EVENT_TYPE[Kinsalary.EVENT_JUNYING];
		Kinsalary:AddSalary_GS(me, Kinsalary.EVENT_JUNYING, tbInfo.nRate);
		
	elseif tbTaskType[nTaskId] == 3 then
		Merchant:FinishTaskOnAward();
	elseif tbTaskType[nTaskId] == 4 then	-- 无尽的征程任务
		SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
		self:AwardZhenYuanExp(2);
	end

	local tbAwards	= self:GetAwardsForMe(nTaskId, true);
	if (tbAwards.tbOpt[nChoice]) then
		-- 判断一下要领取的这个物品是不是需要扣除金币替代物才能领取，如果是的话，就先扣除
		-- 这里的nIndex 对应的是speoptaward.txt 文件中的nIndex 那一列，是用来标识物品的
		local nIndex = -1;
		if (tbAwards.tbOpt[nChoice].varValue and tbAwards.tbOpt[nChoice].varValue[1]) then
			nIndex = tbAwards.tbOpt[nChoice].varValue[1];
		end
		
		if (nIndex ~= -1 and self:IsSpeOptAward(nTaskId, nReferId, nIndex) == 1) then
			local bCanGetSpeOptAward, szErrMsg = self:GetSpeOpt_Cost(nTaskId, nReferId, nIndex);
			if (not bCanGetSpeOptAward or bCanGetSpeOptAward ~= 1) then
				if (szErrMsg and szErrMsg ~= "") then
					me.Msg(szErrMsg);
				end
				return;
			end
			self:GiveAward(tbAwards.tbOpt[nChoice], nTaskId);
		else
			self:GiveAward(tbAwards.tbOpt[nChoice], nTaskId);
		end
	end;
	for _, tbAward in pairs(tbAwards.tbFix) do
		self:GiveAward(tbAward, nTaskId);
	end;
	
	
	if (tbAwards.tbRand[1]) then
		local nSum	= 0;
		local nCurSum = 0;
		for _,tbAward in pairs(tbAwards.tbRand) do
			nSum = nSum + tbAward.nRate;
		end
		if (nSum >= 1) then
			local nRand	= MathRandom(nSum);
			for _, tbAward in pairs(tbAwards.tbRand) do
				nCurSum	= nCurSum + tbAward.nRate;
				if (nCurSum > nRand) then
					self:GiveAward(tbAward, nTaskId);
					break;
				end
			end
		end
	end			
	
	self:SetFinishedRefer(nTaskId, nReferId);

	self:CloseTask(nTaskId, "finish");
	
	self:LogFinishTask(nTaskId);
end

-- 军营任务给予的真元经验奖励
function Task:AwardZhenYuanExp(nType)
	local nCount = me.GetTask(self.tbZhenYuanExpAward[nType][3], self.tbZhenYuanExpAward[nType][4]);
	local nTime = me.GetTask(self.tbZhenYuanExpAward[nType][3], self.tbZhenYuanExpAward[nType][5]);
	
	if nTime == 0 then
		nTime = GetTime();
		nCount = 0;
	end
	
	local nPreWeek = Lib:GetLocalWeek(nTime);
	local nNowWeek = Lib:GetLocalWeek(GetTime());
	if nPreWeek ~= nNowWeek then
		nTime = GetTime();
		nCount = 0;
	end
	
	if nCount < self.tbZhenYuanExpAward[nType][2] then
		local pZhenYuan = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_ZHENYUAN_MAIN);
		-- pZhenYuan可以为nil,表示全部累积
		Item.tbZhenYuan:AddExp(pZhenYuan, self.tbZhenYuanExpAward[nType][1], Item.tbZhenYuan.EXPWAY_ARMY);
	end
	
	me.SetTask(self.tbZhenYuanExpAward[nType][3], self.tbZhenYuanExpAward[nType][4], nCount + 1);
	me.SetTask(self.tbZhenYuanExpAward[nType][3], self.tbZhenYuanExpAward[nType][4], nTime);
end

--===================================================

-- 在获取要扣除特定物品才能获得的可选奖励前，扣除物品
function Task:GetSpeOpt_Cost(nTaskId, nReferId, nIndex)
	local szErrMsg = "";
	
	if (not nTaskId or not nReferId or not nIndex or nTaskId <= 0 or nReferId <= 0) then
		return 0;
	end
	
	if (self:IsSpeOptAward(nTaskId, nReferId, nIndex) == 0) then
		return 0;
	end
	
	local tbSpeOptAward = self:GetSpeOptInfo(nTaskId, nReferId, nIndex);
	if (not tbSpeOptAward) then
		return 0;
	end
	
	local nCostNum = tbSpeOptAward.nCost;
	if (nCostNum == 0) then
		-- 扣除0个物品，直接认为扣除成功
		return 1;
	end
	local tbCostGDPL = tbSpeOptAward.tbCostGDPL;
	local szCostItem = KItem.GetNameById(unpack(tbSpeOptAward.tbCostGDPL));
	if (not szCostItem or nCostNum < 0) then
		return 0;
	end
	
	local tbFind = me.FindItemInBags(unpack(tbCostGDPL));
	if (#tbFind < nCostNum) then
		szErrMsg = string.format("Đem %s %s mới được nhận thưởng", nCostNum, szCostItem);
		return 0, szErrMsg;
	end
	
	local bRet = me.ConsumeItemInBags(nCostNum, unpack(tbCostGDPL));
	if (bRet ~= 0) then
		local szLog = string.format("Sử dụng %s %s thất bại!", nCostNum, szCostItem);
		Dbg:WriteLog("Nhận được trang bị Tân Thủ", me.szName, szLog);
		return 0;
	end
	
	return 1;
end

-------------------------------------------------------------------------

-- 任务产出log
function Task:TskProduceLog(nTaskId, nType, nValue)
	if (not nTaskId or not nType or not nValue or nTaskId <= 0 or nValue <= 0) then
		return;
	end
	
	local nSubTaskId, nTskProType, szAwardType = self:__TskProduceLog_GetInfo(nType, nTaskId);
	if (not nSubTaskId or not nTskProType or not szAwardType) then
		return;
	end
	
	local szLog = string.format("%s,%s,%s,%s,%s", nTaskId, nSubTaskId, nTskProType, szAwardType, nValue);
	StatLog:WriteStatLog("stat_info", "taskproduct", "currency", me.nId, szLog);
end

function Task:__TskProduceLog_GetInfo(nMoneyType, nTaskId)
	local tbAwardType = {
		[self.TSKPRO_LOG_TYPE_MONEY] = "money",
		[self.TSKPRO_LOG_TYPE_BINDMONEY] = "bindmoney",
		[self.TSKPRO_LOG_TYPE_BINDCOIN] = "bindcoin",
		};
	
	local tbTskProType = {
		[self.emType_Main]		= self.emTskProType_Main,
		[self.emType_Branch]	= self.emTskProType_Branch,
		[self.emType_World]		= self.emTskProType_World,
		[self.emType_Random]	= self.emTskProType_Random,
		[self.emType_Camp]		= self.emTskProType_Camp,
		};
	
	local tbPlayerTask	= self:GetPlayerTask(me);
	local tbTask = tbPlayerTask.tbTasks[nTaskId];
	local nSubTaskId = tbTask.nReferId or 0;
	local nTaskType = tbTask.tbTaskData.tbAttribute.TaskType;
	local nTskProType = tbTskProType[nTaskType] or 0;
	if (nTaskId == Merchant.TASKDATA_ID) then
		nTskProType = self.emTskProType_Merchant;
	end
	
	return nSubTaskId, nTskProType, tbAwardType[nMoneyType];
end


-------------------------------------------------------------------------
-- 给与一组奖励，并提示获得奖品
function Task:GiveAward(tbAward, nTaskId)
	
	local szType	= tbAward.szType;
	local varValue	= tbAward.varValue;
	
	if (szType == "exp") then
		local nExp = tbAward.varValue;
		--越南防沉迷，经验获取0.5倍
		if (me.GetTiredDegree() == 1) then
			nExp = nExp * 0.5;
		end
		me.AddExp2(nExp,"task");
	elseif (szType == "money" or szType == "bindmoney") then
		--	me.AddBindMoney(tbAward.varValue, Player.emKBINDMONEY_ADD_TASK);
			me.AddBindMoney2(tbAward.varValue,"task",Player.emKBINDMONEY_ADD_TASK);
			KStatLog.ModifyAdd("bindjxb", "[Nơi]"..self:GetTaskTypeName(nTaskId), "Tổng", tbAward.varValue);
			self:TskProduceLog(nTaskId, self.TSKPRO_LOG_TYPE_BINDMONEY, tbAward.varValue);
	elseif (szType == "activemoney") then
		local tbPlayerTask	= self:GetPlayerTask(me);
		local tbTask		= tbPlayerTask.tbTasks[nTaskId];
		if (tbTask) then
			me.Earn(tbAward.varValue, Player.emKEARN_TASK_GIVE);
			tbTask.nLogMoney = tbAward.varValue;
			KStatLog.ModifyAdd("jxb", "[Nơi]"..self:GetTaskTypeName(nTaskId), "Tổng", tbAward.varValue);
			self:TskProduceLog(nTaskId, self.TSKPRO_LOG_TYPE_MONEY, tbAward.varValue);
		end
	elseif (szType == "repute") then
		--军营声望
		if (tbAward.varValue[1] == 1 and tbAward.varValue[2] == 2) then
			me.Msg(string.format("Bạn nhận được <color=yellow>%s điểm <color> Danh vọng quân doanh", tbAward.varValue[3]));
		end
		--机关学造诣
		if (tbAward.varValue[1] == 1 and tbAward.varValue[2] == 3) then
			me.Msg(string.format("Bạn nhận được <color=yellow>%s điểm <color> Cơ Quan Học Tạo Đồ", tbAward.varValue[3]));
			Task.tbArmyCampInstancingManager.StatLog:WriteLog(11, tbAward.varValue[3]);
		end
		me.AddRepute(unpack(tbAward.varValue))
	elseif (szType == "title") then
		me.AddTitle(tbAward.varValue[1], tbAward.varValue[2], tbAward.varValue[3], 0)
	elseif (szType == "taskvalue") then
		if (tbAward.varValue[1] == 2025 and tbAward.varValue[2] == 2) then
			Task.tbArmyCampInstancingManager.StatLog:WriteLog(12, tbAward.varValue[3]);
			me.AddMachineCoin(tbAward.varValue[3]);
		else
			me.SetTask(tbAward.varValue[1], tbAward.varValue[2], tbAward.varValue[3], 1);
		end	
	elseif(szType == "script") then
		-- 直接执行脚本
		Lib:DoExecFuncs({tbAward.varValue}, nTaskId)
	elseif (szType == "item") then
		local nCount = tonumber(tbAward.szAddParam1) or 1;
		if (nCount < 1) then
			nCount = 1;
		end
		for i = 1, nCount do
			local pItem 	= Task:AddItem(me, tbAward.varValue, nTaskId);
			if pItem then
				self:AutoEquip(pItem);
			end
			--self:WriteItemLog(pItem, me, nTaskId);
		end
	elseif (szType == "customizeitem") then
		local pItem = Task:AddItem(me, tbAward.varValue, nTaskId);
		if pItem then
			self:AutoEquip(pItem);
		end
	elseif (szType == "gatherpoint") then
		TaskAct:AddGatherPoint(tonumber(tbAward.varValue))
	elseif (szType == "makepoint") then
		TaskAct:AddMakePoint(tonumber(tbAward.varValue))
	elseif (szType == "KinReputeEntry") then
		me.AddKinReputeEntry(tbAward.varValue[1]);
	elseif (szType == "arrary") then
		for _, tbOneAward in ipairs(tbAward.varValue) do
			self:GiveAward(tbOneAward, nTaskId);
		end;
	elseif (szType == "bindcoin") then
		me.AddBindCoin(tbAward.varValue[1], Player.emKBINDCOIN_ADD_TASK);
		KStatLog.ModifyAdd("bindcoin", "[Nơi]"..self:GetTaskTypeName(nTaskId), "Tổng", tbAward.varValue[1]);
		self:TskProduceLog(nTaskId, self.TSKPRO_LOG_TYPE_BINDCOIN, tbAward.varValue[1]);
	elseif (szType == "factionequip") then
		self:GetSpeOpt_FactionEquip(nTaskId, varValue[1]);
	elseif (szType == "customequip") then
		self:Get_CustomEquip(nTaskId, varValue[1]);
	end;
end;

--自动装备
function Task:AutoEquip(pItem)
	if me.GetTask(2181,1) > 0 then
		return;
	end
	if pItem.IsEquip() ~= 1 then
		return;
	end
	me.CallClientScript({"UiManager:OpenWindow", "UI_AUTOEQUIP", {pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel}});
end

function Task:Get_CustomEquip(nTaskId, nIndex)
	if (not nTaskId or not nIndex or  nTaskId <= 0) then
		return;
	end
	local nFaction = me.nFaction;
	local nRoute = me.nRouteId;
	local nSex = me.nSex;
	nFaction = math.max(nFaction, 1);		--默认发放金系
	nRoute = math.max(nRoute, 1);			--默认发放金系枪天装备
	if not self.tbCustomEquip[nIndex] or not self.tbCustomEquip[nIndex][nFaction] or 
	not self.tbCustomEquip[nIndex][nFaction][nRoute] or not self.tbCustomEquip[nIndex][nFaction][nRoute][nSex] then
		me.Msg("Lỗi hệ thống, xin liên hệ GM!");
		Dbg:WriteLog("Nhận trang bị nhiệm vụ thất bại", me.szName, nFaction, nRoute, nSex);
		return;
	end
	local tbAwardInfo = self.tbCustomEquip[nIndex][nFaction][nRoute][nSex];
	local pItem = me.AddItem(unpack(tbAwardInfo));
	if (pItem) then
		pItem.Bind(1);	
		if nTaskId ~= 10000 then		--10000做活跃度调入
			self:AutoEquip(pItem);	
			local szLog = string.format("Nhận trang bị nhiệm vụ thành công!!!", nFaction, nRoute, nSex);
			Dbg:WriteLog("Nhận trang bị nhiệm vụ", me.szName, szLog);		
		end
	end
end

-- 获取特殊奖励（门派装备），注意，并不是所有的门派装备奖励都走到这里
-- 只有出现在可选奖励里面，并且需要扣除一些费用才能得到的门派装备才会执行到这里
function Task:GetSpeOpt_FactionEquip(nTaskId, nIndex)
	if (not nTaskId or not nIndex or  nTaskId <= 0) then
		return;
	end
	
	local tbPlayerTask = self:GetPlayerTask(me);
	local tbTask = tbPlayerTask.tbTasks[nTaskId];
	local nReferId = tbTask.nReferId;
	
	local tbAwardInfo = self:GetSpeOptInfo(nTaskId, nReferId, nIndex);
	local tbGDPL = tbAwardInfo.tbGDPL;
	if (not tbGDPL or #tbGDPL ~= 4) then
		return;
	end
	
	local nCostNum = tbAwardInfo.nCost;
	local tbCostGDPL = tbAwardInfo.tbCostGDPL;
	local szCostItem = KItem.GetNameById(unpack(tbCostGDPL));
	if (not nCostNum or not szCostItem) then
	end
	
	local pItem = me.AddItem(unpack(tbGDPL));
	if (pItem) then
		pItem.Bind(1);
		self:AutoEquip(pItem);
		local szLog = string.format("Sử dụng %s %s, nhận được 1 %s", nCostNum, szCostItem, pItem.szName);
		Dbg:WriteLog("Nhận được trang bị Tân Thủ", me.szName, szLog);
	end
end

function Task:WriteItemLog(pItem, pPlayer, nTaskId)
	local tbPlayerTask	= self:GetPlayerTask(pPlayer);
	local tbTask		= tbPlayerTask.tbTasks[nTaskId];
	local szLogMsg		= "";
	if (tbTask) then
		szLogMsg	= string.format(" hoàn thành %s, ID nhiệm vụ: %x, ID nhiệm vụ phụ tuyến: %x", tbTask:GetName(), tbTask.nTaskId, tbTask.nReferId);		
	else
		szLogMsg	= string.format("Không có nhiệm vụ có Id là %x!", nTaskId);
	end;
	local bGiveSuc 	= 1;
	if (not pItem) then
		bGiveSuc = 0;
	end
--	me.ItemLog(pItem, bGiveSuc, Log.emKITEMLOG_TYPE_FINISHTASK, szLogMsg);
	local szLog = string.format("%s nhận được 1 %s", szLogMsg, pItem.szName);
	Dbg:WriteLog("Task", "nhiệm vụ nhận được vật phẩm ", me.szAccount, me.szName, szLog);
end

-------------------------------------------------------------------------
-- 设定特定任务完成的最后一个引用子任务ID
function Task:SetFinishedRefer(nTaskId, nReferId)
	local nLogReferId = nReferId;
	local tbTaskData = self.tbTaskDatas[nTaskId];
	if (tbTaskData.tbAttribute["Repeat"]) then
		local nReferIdx		= self:GetFinishedIdx(nTaskId) + 2;	
		local nNextReferId	= tbTaskData.tbReferIds[nReferIdx];
		if (not nNextReferId) then
			nReferId = 0;
		end
	end
	
	me.SetTask(1000, nTaskId, nReferId, 1); -- Group1000保存了所有任务的完成情况,其中任务变量Id(nTaskId)也就是任务Id
end


-------------------------------------------------------------------------
-- 使任务失败
function Task:Failed(nTaskId)
	if (type(nTaskId) == "string") then
		nTaskId = tonumber(nTaskId, 16);
	end

	return self:CloseTask(nTaskId, "failed");
end;

-------------------------------------------------------------------------

-- 获取师徒成就：完成XXX任务
function Task:GetAchiemement(pPlayer, nMainTaskId, nSubTaskId)
	if (not pPlayer) then
		return;
	end
	local tbMainTaskId = Achievement_ST.tbMainTaskId;
	for nAchievementId, tbAchievement in pairs(tbMainTaskId) do
		for i, v in pairs(tbAchievement) do
			local nMainId = v[1];
			local nSubId = v[2];
			if (nMainTaskId == nMainId and nSubTaskId == nSubId) then
				Achievement_ST:FinishAchievement(pPlayer.nId, nAchievementId);				
			end
		end
	end
end

-------------------------------------------------------------------------
-- 关闭任务
function Task:CloseTask(nTaskId, szReason)
	local tbPlayerTask	= self:GetPlayerTask(me);
	local tbTask	= tbPlayerTask.tbTasks[nTaskId];
	if (not tbTask) then
		return nil;
	end;

	tbTask:CloseCurStep(szReason);
	if (szReason == "giveup") then
		me.Msg("Huỷ nhiệm vụ: "..tbTask:GetName());
		me.Msg(tbTask.tbReferData.szGossip);
	elseif (szReason == "failed") then
		me.Msg("Nhiệm vụ thất bại: "..tbTask:GetName());
		me.Msg(tbTask.tbReferData.szGossip);
	elseif (szReason == "finish") then
		-- 2. 低于50级以下角色的任务事件，不记入角色历程日志。
		if (me.nLevel >= 50) then
			me.Msg("Nhiệm vụ hoàn thành: "..tbTask:GetName());
			me.CastSkill(self.nFinishTaskSkillId, 1, -1, me.GetNpc().nIndex);
			local szLogMsg = string.format(" hoàn thành %s, ID nhiệm vụ: %x, ID nhiệm vụ phụ tuyến: %x", tbTask:GetName(), tbTask.nTaskId, tbTask.nReferId);
			if (tbTask.nLogMoney > 0) then
				szLogMsg = szLogMsg .. string.format(" 奖励%d银两", tbTask.nLogMoney)
				tbTask.nLogMoney = 0;
			end
			if self.tbOtherTask[tbTask.nTaskId] and self.tbOtherTask[tbTask.nTaskId][1] == tbTask.nReferId then
				StatLog:WriteStatLog("stat_info", self.tbOtherTask[tbTask.nTaskId][2] , "finish_task", me.nId, tbTask.nTaskId, tbTask.nReferId);
			end
			me.PlayerLog(Log.emKPLAYERLOG_TYPE_FINISHTASK ,szLogMsg);
		end
		
		if (self:CheckArmyTask(nTaskId) == 1) then -- 剧情任务
			Dbg:WriteLogEx(Dbg.LOG_INFO, "ArmyTask", "FinishJuqingTask", tbTask:GetName(), me.szName, os.date("%Y-%m-%d-%H:%M:%S", GetTime()));
		elseif (self:CheckArmyTask(nTaskId) == 2) then -- 日常任务
			Dbg:WriteLogEx(Dbg.LOG_INFO, "ArmyTask", "FinishDailyTask", tbTask:GetName(), me.szName, os.date("%Y-%m-%d-%H:%M:%S", GetTime()));
		elseif (self:CheckArmyTask(nTaskId) == 3) then
			Dbg:WriteLogEx(Dbg.LOG_INFO, "ArmyTask", "FinishWuJinTask", tbTask:GetName(), me.szName, os.date("%Y-%m-%d-%H:%M:%S", GetTime()));
		end
	end;
	
	-- 师徒成就：完成XXX任务
	self:GetAchiemement(me, tbTask.nTaskId, tbTask.nReferId);
	
	tbPlayerTask.tbTasks[nTaskId]	= nil;
	tbPlayerTask.nCount	= tbPlayerTask.nCount - 1;
	if (tbPlayerTask.nCount <= 0) then
		
	end;

	me.ClearTaskGroup(tbTask.nSaveGroup,1);

	KTask.SendRefresh(me, nTaskId, tbTask.nReferId, 0);
	
	if (szReason == "finish") then
		local tbFinishExecute = tbTask.tbSubData.tbFinishExecute;
		if (tbFinishExecute and #tbFinishExecute > 0) then
			Lib:DoExecFuncs(tbFinishExecute);
		end;
		
		local tbSubExecute = tbTask.tbSubData.tbExecute;
		if (tbSubExecute and #tbSubExecute > 0) then
			Lib:DoExecFuncs(tbSubExecute);
		end;		
	elseif (szReason == "failed" or szReason == "giveup") then
		local tbFailedExecute = tbTask.tbSubData.tbFailedExecute;
		if (tbFailedExecute and #tbFailedExecute > 0) then
			Lib:DoExecFuncs(tbFailedExecute);
		end;
	end
	
	return 1;
end;

function Task:CheckArmyTask(nTaskId)
	local tbTaskType = {
		[226] = 1,	--军营剧情
		[337] = 1,
		[338] = 1,
		[363] = 1,
		[365] = 1,
		[367] = 1,
		[227] = 2,	--军营日常
		[333] = 2,
		[334] = 2,
		[364] = 2,
		[366] = 2,
		[368] = 2,
		[429] = 3, -- 无尽的征程
	};
	if tbTaskType[nTaskId] then	-- 完成剧情
		return tbTaskType[nTaskId];
	end		
	return 0;
end

-------------------------------------------------------------------------
local function TaskOnSort(tbA, tbB)
	return tbA[1] < tbB[1];
end

-- 追加Npc对话选项
function Task:AppendNpcMenu(tbOption)
	local nNpcTempId	= him.nTemplateId;
	local tbPlayerTasks	= self:GetPlayerTask(me).tbTasks;
	local bHaveRelation	= 0;
	-- 添加已有任务对话选项
	local tbTaskOption = {};
	for _, tbTask in pairs(tbPlayerTasks) do
		if (tbTask:AppendNpcMenu(nNpcTempId, tbTaskOption, him)) then
			bHaveRelation	= 1;
		end
	end
	
	-- 添加可见任务对话选项
	for _, tbTaskData in pairs(self.tbTaskDatas) do
		if (not tbPlayerTasks[tbTaskData.nId]) then
			local nReferIdx		= self:GetFinishedIdx(tbTaskData.nId) + 1;			-- +1表示将要继续的任务
			local nReferId		= tbTaskData.tbReferIds[nReferIdx];
			if (not tbTaskData.tbAttribute["Repeat"] or self:CanAcceptRepeatTask() == 1) then
				if (nReferId) then
					local tbReferData	= self.tbReferDatas[nReferId];
					if (tbReferData.nAcceptNpcId == nNpcTempId) then
						local tbVisable	= tbReferData.tbVisable;
						local bOK	= Lib:DoTestFuncs(tbVisable);						-- 可见条件测试
						if (bOK) then
							bHaveRelation	= 1;
							local tbSubData	= self.tbSubDatas[tbReferData.nSubTaskId];
							if (tbSubData) then
								local szMsg = "";
								if (tbSubData.tbAttribute.tbDialog.Start) then
									if (tbSubData.tbAttribute.tbDialog.Start.szMsg) then 		-- 未分步骤
										szMsg = tbSubData.tbAttribute.tbDialog.Start.szMsg;
									else
										szMsg = tbSubData.tbAttribute.tbDialog.Start.tbSetpMsg[1];
									end
								end
								local szTaskType = "[Nhiệm vụ] ";
								local nTaskType = 0;
								if tbTaskData.tbAttribute and tbTaskData.tbAttribute.TaskType then
									nTaskType = tonumber(tbTaskData.tbAttribute.TaskType) or 0;
									szTaskType = Task.tbemTypeName[nTaskType] or "[Nhiệm vụ] ";
								end
								tbTaskOption[#tbTaskOption + 1]	= {nTaskType, {szTaskType..tbReferData.szName,
									TaskAct.TalkInDark, TaskAct, szMsg,
									self.AskAccept, self, tbTaskData.nId, nReferId}};
								if (tbTaskData.nId == Merchant.TASKDATA_ID) then		-- 因为商会任务的客户端奖励刷新有问题，所以这样搞
									me.CallClientScript({"Merchant:InitTask"});
								end
							end
						end
					end
				end
			end
		end
	end
	Lib:SmashTable(tbTaskOption);
	table.sort(tbTaskOption, TaskOnSort);
	for _, tbTaskTmp in ipairs(tbTaskOption) do
		table.insert(tbOption, tbTaskTmp[2]); 
	end

	return bHaveRelation;
end;


-------------------------------------------------------------------------
-- 靠近一个NPC时触发，显示在小地图上的技能和头上的问号，叹号
function Task:OnApproachNpc()
	local tbTaskState = Task:CheckTaskOnNpc();
	
	self:ChangeNpcFlag(tbTaskState);
end;


-------------------------------------------------------------------------
-- 检测Npc任务标记，用于客户端显示
-- TODO: liuchang 之后可能有需求根据是否已完成目标添加新的技能
function Task:CheckTaskOnNpc()
	local tbPlayerTasks	= self:GetPlayerTask(me).tbTasks;
	
	-- 检测已有任务
	for _, tbTask in pairs(tbPlayerTasks) do
		if (tbTask:CheckTaskOnNpc() == 1) then
			if (tbTask.tbTaskData.tbAttribute["Repeat"]) then
				return self.CheckTaskFlagSkillSet.RepeatCanReply;
			elseif (tbTask.tbTaskData.tbAttribute.TaskType == self.emType_Main) then
				return self.CheckTaskFlagSkillSet.MainCanReply;
			elseif (tbTask.tbTaskData.tbAttribute.TaskType == self.emType_Branch) then
				return self.CheckTaskFlagSkillSet.BranchCanReply;
			elseif (tbTask.tbTaskData.tbAttribute.TaskType == self.emType_World) then
				return self.CheckTaskFlagSkillSet.WorldCanReply;
			elseif (tbTask.tbTaskData.tbAttribute.TaskType == self.emType_Random) then
				return self.CheckTaskFlagSkillSet.RandomCanReply;
			elseif (tbTask.tbTaskData.tbAttribute.TaskType == self.emType_Camp) then
				return self.CheckTaskFlagSkillSet.RandomCanReply;
			else
				assert(false);
			end
		end;
	end;
	
	
	-- 检测可见任务
	for _, tbTaskData in pairs(self.tbTaskDatas) do
		if (not tbPlayerTasks[tbTaskData.nId]) then
			local nReferIdx		= self:GetFinishedIdx(tbTaskData.nId) + 1;--+1表示将要做的任务
			local nReferId		= tbTaskData.tbReferIds[nReferIdx];
			if (nReferId) then
				local tbReferData	= self.tbReferDatas[nReferId];
				if (tbReferData.nAcceptNpcId == him.nTemplateId) then
					local tbVisable	= tbReferData.tbVisable;
					local bOK	= Lib:DoTestFuncs(tbVisable);
					if (bOK) then
						if (tbTaskData.tbAttribute["Repeat"]) then
							if (self:CanAcceptRepeatTask() ~= 1) then
								return;
							end
							return self.CheckTaskFlagSkillSet.RepeatCanAccept;
						elseif (tbTaskData.tbAttribute.TaskType == self.emType_Main) then
							return self.CheckTaskFlagSkillSet.MainCanAccept;
						elseif (tbTaskData.tbAttribute.TaskType == self.emType_Branch) then
							return self.CheckTaskFlagSkillSet.BranchCanAccept;
						elseif (tbTaskData.tbAttribute.TaskType == self.emType_World) then
							return self.CheckTaskFlagSkillSet.WorldCanAccept;
						elseif (tbTaskData.tbAttribute.TaskType == self.emType_Random) then
							return self.CheckTaskFlagSkillSet.RandomCanAccept;
						elseif (tbTaskData.tbAttribute.TaskType == self.emType_Camp) then
							return self.CheckTaskFlagSkillSet.RandomCanAccept;
						else
							assert(false);
						end
					end
				end;
			end;
		end;
	end;
	
	return;

end;



-------------------------------------------------------------------------
-- 改变NPC的任务状态显示,去除不需要的，添加需要的
function Task:ChangeNpcFlag(tbSkillId)
	
	local tbTempTotleSkill = {};
	for _,tbSkillSet in pairs(self.CheckTaskFlagSkillSet) do
		for _, Skill in pairs(tbSkillSet) do
			tbTempTotleSkill[Skill] = 1;
		end
	end

	local tbTotleSkill = {};
	for Skill,Item in pairs(tbTempTotleSkill) do
		tbTotleSkill[#tbTotleSkill+1] = Skill;
	end


	if (not tbSkillId) then
		for _,nSkillId in ipairs(tbTotleSkill) do
			him.RemoveTaskState(nSkillId);
		end
		return;
	end

	for _,nSkillId in ipairs(tbTotleSkill) do	
		local bRemove = 1;
		for _, nRetainSkillId in ipairs(tbSkillId) do
			local tbBeRemoveSet = {};
			if (nRetainSkillId == nSkillId) then
				bRemove = 0;
			end
		end
		if (bRemove == 1) then
			him.RemoveTaskState(nSkillId);
		end
	end
	
	for _, nRetainSkillId in ipairs(tbSkillId) do
		him.AddTaskState(nRetainSkillId);
	end
end


-------------------------------------------------------------------------
-- 玩家使用任务物品时候触发
function Task:OnTaskItem(pItem)
	local nParticular	= pItem.nParticular;
	local tbPlayerTasks	= self:GetPlayerTask(me).tbTasks;
	
	-- 用于已有任务
	for _, tbTask in pairs(tbPlayerTasks) do
		if (tbTask:OnTaskItem(nParticular)) then
			return 1;
		end;
	end;
	
	-- 用于接新任务
	for _, tbTaskData in pairs(self.tbTaskDatas) do
		if (not tbPlayerTasks[tbTaskData.nId]) then
			local nReferIdx	= self:GetFinishedIdx(tbTaskData.nId) + 1;--+1表示将要做的任务
			local nReferId	= tbTaskData.tbReferIds[nReferIdx];
			if (nReferId) then
				local tbReferData = self.tbReferDatas[nReferId];
				local tbSubData	  = self.tbSubDatas[tbReferData.nSubTaskId];
				local szMsg = "";
				if (tbSubData.tbAttribute.tbDialog.Start) then
					if (tbSubData.tbAttribute.tbDialog.Start.szMsg) then -- 未分步骤
						szMsg = tbSubData.tbAttribute.tbDialog.Start.szMsg;
					else
						szMsg = tbSubData.tbAttribute.tbDialog.Start.tbSetpMsg[1];
					end
				end
							
			
				if (tbReferData.nParticular == pItem.nParticular) then
					local tbVisable	= tbReferData.tbVisable;
					local bOK, szMsg = Lib:DoTestFuncs(tbVisable);						-- 可见条件测试
					if (bOK) then
						TaskAct:TalkInDark(szMsg, self.AskAccept, self, tbTaskData.nId, nReferId);
						return 1
					else
						me.Msg(szMsg);
						return nil;
					end
				end;
			end;
		else
			local nReferIdx	= self:GetFinishedIdx(tbTaskData.nId) + 1;--+1表示将要做的任务
			local nReferId	= tbTaskData.tbReferIds[nReferIdx];
			if (nReferId) then
				local tbReferData	= self.tbReferDatas[nReferId];
				if (tbReferData.nParticular == pItem.nParticular) then
					me.Msg("Vật phẩm để kích hoạt nhiệm vụ đang vận hành!");
					return nil;
				end
			end

		end;
	end;

	return nil;
end;



-------------------------------------------------------------------------
-- 触发下个步骤时调用,NPC对话和使用道具的时候，见CalssBase.SetCurStep
function Task:Active(nTaskId, nReferId, nCurStep)
	local tbTask	= self:GetPlayerTask(me).tbTasks[nTaskId];
	if (not tbTask) then
		return nil;
	end;
	assert(tbTask.nReferId == nReferId);
	--assert(tbTask.nCurStep == nCurStep); -- 改为return nil; zounan
	if tbTask.nCurStep ~= nCurStep then
		return nil;
	end
	
	return tbTask:Active();
end;


-------------------------------------------------------------------------
-- 和withprocesstagnpc类型NPC交互时触发，不会弹Say界面，而是进度条之类的及时触发
function Task:OnExclusiveDialogNpc()
	local nTemplateId = him.nTemplateId;
	local tbPlayerTasks	= self:GetPlayerTask(me).tbTasks;
	

	for _, tbTask in pairs(tbPlayerTasks) do
		if (tbTask:OnExclusiveDialogNpc(nTemplateId)) then
			return 1;
		end;
	end;
	
end


-------------------------------------------------------------------------
-- 根据引用子任务Id获取奖励表
function Task:GetAwards(nReferId)
	local tbAwardRet = {};
	local tbRefSubData	= self.tbReferDatas[nReferId];
	if (tbRefSubData) then
		local tbAwardSrc = tbRefSubData.tbAwards;
		-- 1.固定奖励
		tbAwardRet.tbFix = {};
		for _, tbFix in ipairs(tbAwardSrc.tbFix) do
			if (tbFix.tbConditions) then
				if (Lib:DoTestFuncs(tbFix.tbConditions) == 1) then
					table.insert(tbAwardRet.tbFix, tbFix);
				end
			else
				table.insert(tbAwardRet.tbFix, tbFix);
			end
		end
		
		-- 2.随机奖励
		tbAwardRet.tbRand = {};
		for _, tbRand in ipairs(tbAwardSrc.tbRand) do
			if (tbRand.tbConditions) then
				if (Lib:DoTestFuncs(tbRand.tbConditions) == 1) then
					table.insert(tbAwardRet.tbRand, tbRand);
				end
			else
				table.insert(tbAwardRet.tbRand, tbRand);
			end
		end
		
		-- 3.可选奖励
			tbAwardRet.tbOpt = {};
		for _, tbOpt in ipairs(tbAwardSrc.tbOpt) do
			if (tbOpt.tbConditions) then
				if (Lib:DoTestFuncs(tbOpt.tbConditions) == 1) then
					table.insert(tbAwardRet.tbOpt, tbOpt);
				end
			else
				table.insert(tbAwardRet.tbOpt, tbOpt);
			end
		end
		
		return tbAwardRet;
	else
		return nil;
	end;
end;


-- 根据直接获取奖励表
function Task:GetAwardsForMe(nTaskId, bOutMsg)
	local tbAwardRet = {};
	local tbPlayerTask = self:GetPlayerTask(me);
	local tbTask = tbPlayerTask.tbTasks[nTaskId];
	if (not tbTask or not tbTask.tbReferData) then
		return nil;
	end
	local tbAwardSrc = tbTask.tbReferData.tbAwards;
	tbAwardRet.tbFix = self:GetTypeAward(tbAwardSrc.tbFix, bOutMsg);
	tbAwardRet.tbRand = self:GetTypeAward(tbAwardSrc.tbRand, bOutMsg);
	tbAwardRet.tbOpt = self:GetTypeAward(tbAwardSrc.tbOpt, bOutMsg);		
	return tbAwardRet;
end;

function Task:GetTypeAward(tbSrc, bOutMsg)
	local tb = {};
	for _, tbAward in ipairs(tbSrc) do
		if (tbAward.tbConditions) then
			local bRet, szMsg = Lib:DoTestFuncs(tbAward.tbConditions);
			if (bRet == 1) then
				table.insert(tb, tbAward);
			elseif (szMsg and bOutMsg) then
				Dialog:SendBlackBoardMsg(me, szMsg);		
			end
		else
			table.insert(tb, tbAward);
		end
	end
	return tb;
end
-------------------------------------------------------------------------
-- 取得当前玩家任务数据
function Task:GetPlayerTask(pPlayer)
	local tbPlayerData	= pPlayer.GetTempTable("Task");
	local tbPlayerTask	= tbPlayerData.tbTask;
	if (not tbPlayerTask) then
		tbPlayerTask	= {
			nCount	= 0,
			tbTasks	= {},
		};
		tbPlayerData.tbTask	= tbPlayerTask;
	end
	return tbPlayerTask;
end


-------------------------------------------------------------------------
-- 取得特定任务完成的最后一个引用子任务ID
function Task:GetFinishedRefer(nTaskId)
	return me.GetTask(1000, nTaskId);
end


-------------------------------------------------------------------------
-- 取得特定任务完成的最后一个引用子任务序号
function Task:GetFinishedIdx(nTaskId)
	local nReferId	= self:GetFinishedRefer(nTaskId);
	if (nReferId == 0) then
		return 0;
	end;
	local tbReferData	= self.tbReferDatas[nReferId];
	if (tbReferData) then
		return tbReferData.nReferIdx;
	end
	local tbTaskData	= self.tbTaskDatas[nTaskId];
	return #tbTaskData.tbReferIds;
end


-------------------------------------------------------------------------
-- 或得一个任务的名字
function Task:GetTaskName(nTaskId)
	if (not self.tbTaskDatas[nTaskId]) then
		self:LoadTask(nTaskId);
	end;
	
	return self.tbTaskDatas[nTaskId].szName;
end


-------------------------------------------------------------------------
-- 获得一个任务的描述
function Task:GetTaskDesc(nTaskId)
	if (not self.tbTaskDatas[nTaskId]) then
		self:LoadTask(nTaskId);
	end;
	
	return self.tbTaskDatas[nTaskId].szDesc;
end


-------------------------------------------------------------------------
--获得一个引用子任务名
function Task:GetManSubName(nReferId)
	return self.tbReferDatas[nReferId].szName;
end


-------------------------------------------------------------------------
--获得一个引用子任务描述
function Task:GetManSubDesc(nReferId)
	return self.tbReferDatas[nReferId].tbDesc.szMainDesc;
end

-------------------------------------------------------------------------
-- 根据图标索引得到图标路径
function Task:GetIconPath(nIconIndex)
	nIconIndex = tonumber(nIconIndex) or 1;
	nIconIndex = tonumber(nIconIndex);
	local szPath = KTask.GetIconPath(nIconIndex);
	if not szPath then
		szPath = "\\image\\ui\\001a\\tasksystem\\award\\item.spr"; -- 默认值
	end
	return szPath;
end

-- 获取nTaskId任务下第nRefIndex个子任务的ID,前提是tbTaskDatas已初始化,不能用于义军任务
function Task:GetReferID(nTaskId,nRefIndex)  
    nRefIndex = nRefIndex or 1;
    if not nTaskId or not self.tbTaskDatas[nTaskId] or not self.tbTaskDatas[nTaskId].tbReferIds[nRefIndex] then
       return nil;
    end
    return self.tbTaskDatas[nTaskId].tbReferIds[nRefIndex];
end

-------------------------------------------------------------------------
function Task:OnKillNpc(pPlayer, pNpc)
	local tbStudentList 	= {};
	local tbTeammateList 	= {};
	local tbSharePlayerList = {};
	
	-- 队友和徒弟(组队的徒弟)计数
	local tbTeamMembers, nMemberCount	= pPlayer.GetTeamMemberList();	
	if (tbTeamMembers) then
		for i = 1, nMemberCount do
			if (pPlayer.nPlayerIndex ~= tbTeamMembers[i].nPlayerIndex) then
				if (tbTeamMembers[i].GetTrainingTeacher() == pPlayer.szName) then
					tbStudentList[#tbStudentList + 1] = tbTeamMembers[i];
				else
					tbTeammateList[#tbTeammateList + 1] = tbTeamMembers[i];
				end
			end
		end
	end
	
	local nDistance = self:GetDeathShareDistance(pNpc);
	if nDistance > 0 then
		tbSharePlayerList = KNpc.GetAroundPlayerList(pNpc.dwId, nDistance);		
	end

	self:OnKillNpcForCount(pPlayer, pNpc, tbStudentList, tbTeammateList, tbSharePlayerList);
	self:OnKillNpcForItem(pPlayer, pNpc, tbStudentList, tbTeammateList, tbSharePlayerList);
	self:OnKillBossForItem(pPlayer, pNpc, tbStudentList, tbTeammateList, tbSharePlayerList);
end

function Task:GetDeathShareDistance(pNpc)
	if not self.tbBossDeathShare then
		return 0;
	end
	
	if not self.tbBossDeathShare[pNpc.nTemplateId] then
		return 0;
	end
	
	local nDistance = self.tbBossDeathShare[pNpc.nTemplateId];
	return nDistance;
end


-- 杀怪计数
function Task:OnKillNpcForCount(pPlayer, pNpc, tbStudentList, tbTeammateList, tbSharePlayerList)	
	-- 自己的和队友的
	for _, tbMyTask in pairs(Task:GetPlayerTask(pPlayer).tbTasks) do
		for _, teammate in ipairs(tbTeammateList) do
			if (Task:AtNearDistance(pPlayer, teammate) == 1) then
				for _, tbTask in pairs(Task:GetPlayerTask(teammate).tbTasks) do
					if (tbMyTask.nReferId == tbTask.nReferId and (not tbMyTask.tbReferData.nShareKillNpc or tbMyTask.tbReferData.nShareKillNpc == 0)) then
						tbTask:OnKillNpcForCount(pPlayer, pNpc);
					end
				end
			end
		end
		
		tbMyTask:OnKillNpcForCount(pPlayer, pNpc);
	end
	
	for _, teammate in ipairs(tbTeammateList) do
		if (teammate.nMapId == pPlayer.nMapId) then
			for _, tbTask in pairs(Task:GetPlayerTask(teammate).tbTasks) do
				if (tbTask.tbReferData.nShareKillNpc == 1) then			
					tbTask:OnKillNpcForCount(pPlayer, pNpc);
				end
			end	
		end
	end
	
	-- 徒弟的
	for _, pStudent in ipairs(tbStudentList) do
		for _, tbTask in pairs(Task:GetPlayerTask(pStudent).tbTasks) do
			tbTask:OnKillNpcForCount(pPlayer, pNpc);
		end
	end
	
	-- 注意同队伍的不同共享，否则会被计数再次
	for _, _player in pairs(tbSharePlayerList) do
		if (_player.nTeamId ~= pPlayer.nTeamId or _player.nTeamId == 0) and
			_player.nId ~= pPlayer.nId then
			for _, tbTask in pairs(Task:GetPlayerTask(_player).tbTasks) do
				tbTask:OnKillNpcForCount(_player, pNpc);
			end	
		end
	end
end

-- 杀怪获物(自己需要的可以掉多个,别人的只能掉一个)
function Task:OnKillNpcForItem(pPlayer, pNpc, tbStudentList, tbTeammateList)
	local tbMemCount = {};
	-- 自己和队友的
	local nDropCount = 0;
	for _, tbMyTask in pairs(Task:GetPlayerTask(pPlayer).tbTasks) do
		if (tbMyTask:OnKillNpcForItem(pPlayer, pNpc) == 1) then
			tbMemCount[pPlayer.nId] = 1; 
			nDropCount = nDropCount + 1;
		end
		for _, teammate in ipairs(tbTeammateList) do
			if (nDropCount > 0) then -- 保证不会因为队友增多造成物品掉落增多
				break;
			end
			if (Task:AtNearDistance(pPlayer, teammate) == 1) then
				local tbTask = Task:GetPlayerTask(teammate).tbTasks[tbMyTask.nTaskId];
				if (tbTask) then
					if (tbMyTask.nReferId == tbTask.nReferId and (not tbMyTask.tbReferData.nShareKillNpc or tbMyTask.tbReferData.nShareKillNpc == 0)) then
						if (tbTask:OnKillNpcForItem(teammate, pNpc) == 1) then
							tbMemCount[teammate.nId] = 1; 
							nDropCount = nDropCount + 1;
						end
					end
				end
			end
		end
	end
	
	for _, teammate in ipairs(tbTeammateList) do
		if (nDropCount > 0) then
			break;
		end

		for _, tbTask in pairs(Task:GetPlayerTask(teammate).tbTasks) do
			if (teammate.nMapId == pPlayer.nMapId) then
				if (tbTask.tbReferData.nShareKillNpc == 1) then			
					if (tbTask:OnKillNpcForItem(teammate, pNpc) == 1) then
						tbMemCount[teammate.nId] = 1; 
						nDropCount = nDropCount + 1;
						break;
					end
				end
			end
		end
	end
	
	-- 徒弟的
	nDropCount = 0;
	for _, pStudent in ipairs(tbStudentList) do
		if (nDropCount > 0) then
			break;
		end
		for _, tbTask in pairs(Task:GetPlayerTask(pStudent).tbTasks) do
			if (tbTask:OnKillNpcForItem(pStudent, pNpc) == 1) then
				tbMemCount[pStudent.nId] = 1; 
				nDropCount = nDropCount + 1;
			end
		end
	end
	local tbSharePlayerList = {};
	local nDistance = self:GetDeathShareDistance(pNpc);
	if nDistance > 0 then
		tbSharePlayerList = KNpc.GetAroundPlayerList(pNpc.dwId, nDistance);		
	end
	for _, _player in pairs(tbSharePlayerList) do
		if (_player.nTeamId ~= pPlayer.nTeamId or _player.nTeamId == 0) and
			_player.nId ~= pPlayer.nId then
			for _, tbTask in pairs(Task:GetPlayerTask(_player).tbTasks) do
				if not tbMemCount[_player.nId] then
					if (tbTask:OnKillNpcForItem(_player, pNpc, 1) == 1) then
						tbMemCount[_player.nId] =1;
					end
				end
			end	
		end
	end
end

function Task:OnKillBossForItem(pPlayer, pNpc, tbStudentList, tbTeammateList, tbSharePlayerList)
	-- 自己的和队友的
	for _, tbMyTask in pairs(Task:GetPlayerTask(pPlayer).tbTasks) do
		for _, teammate in ipairs(tbTeammateList) do
			if (Task:AtNearDistance(pPlayer, teammate) == 1) then
				for _, tbTask in pairs(Task:GetPlayerTask(teammate).tbTasks) do
					if (tbMyTask.nReferId == tbTask.nReferId and (not tbMyTask.tbReferData.nShareKillNpc or tbMyTask.tbReferData.nShareKillNpc == 0)) then
						tbTask:OnKillBossForItem(pPlayer, pNpc);
					end
				end
			end
		end
		tbMyTask:OnKillBossForItem(pPlayer, pNpc);
	end
	
	for _, teammate in ipairs(tbTeammateList) do
		if (teammate.nMapId == pPlayer.nMapId) then
			for _, tbTask in pairs(Task:GetPlayerTask(teammate).tbTasks) do
				if (tbTask.tbReferData.nShareKillNpc == 1) then			
					tbTask:OnKillBossForItem(pPlayer, pNpc);
				end
			end	
		end
	end
	
	
	-- 徒弟的
	for _, pStudent in ipairs(tbStudentList) do
		for _, tbTask in pairs(Task:GetPlayerTask(pStudent).tbTasks) do
			tbTask:OnKillBossForItem(pPlayer, pNpc);
		end
	end
	
	-- 注意同队伍的不同共享，否则会被计数再次
	for _, _player in pairs(tbSharePlayerList) do
		if (_player.nTeamId ~= pPlayer.nTeamId or _player.nTeamId == 0) and
			_player.nId ~= pPlayer.nId then
			for _, tbTask in pairs(Task:GetPlayerTask(_player).tbTasks) do
				tbTask:OnKillBossForItem(_player, pNpc);
			end	
		end
	end
end

-- 注册离线事件
PlayerEvent:RegisterGlobal("OnLogout", Task.OnLogout, Task)

if (not Task.tbTrackTaskSet) then
	Task.tbTrackTaskSet = {};
end

if (not Task.tbTrackTaskSet) then
	Task.tbTrackTaskSet = {};
end

function Task:SendAward(nTaskId, nReferId, nSelIdx)
	KTask.SendAward(me, nTaskId, nReferId, nSelIdx);
end


-- C
function Task:OnRefresh(nTaskId, nReferId, nParam)
	local tbPlayerTask	= self:GetPlayerTask(me);
	if (nParam and nParam ~= 0) then
		local tbTask		= tbPlayerTask.tbTasks[nTaskId];
		if (not tbTask) then
			local tbReferData	= self.tbReferDatas[nReferId];
			local nSubTaskId	= tbReferData.nSubTaskId;
	
			if (not self.tbSubDatas[nSubTaskId]) then
				-- 任务链的任务特殊处理
				if self:GetTaskType(nSubTaskId) == "Task" then
					self:LoadSub(nSubTaskId);
				elseif self:GetTaskType(nSubTaskId) == "LinkTask" then
					--老包任务
					local tbTaskSub	= LinkTask.tbSubTaskData;
					LinkTask:_ReadSubTask(	nSubTaskId, 
											tbTaskSub[nSubTaskId].szTaskName, 
											tbTaskSub[nSubTaskId].szTargetName,
											tbTaskSub[nSubTaskId].tbParams);
				elseif self:GetTaskType(nSubTaskId) == "WantedTask" then
					--官府通缉任务
					local tbTaskSub	= Wanted.tbSubTaskData;
					Wanted:ReadSubTask(	nSubTaskId,
											tbTaskSub[nSubTaskId].szTaskName, 
											tbTaskSub[nSubTaskId].szTargetName,
											tbTaskSub[nSubTaskId].tbParams);
				else
					print(debug.traceback("Warning!!! TaskType is not found"));
				end;
			end
			
			tbTask	= Task:NewTask(nReferId);
			if (self.tbTaskDatas[nTaskId].tbAttribute["AutoTrack"]) then
				self:OnTrackTask(nTaskId);
			end
		end
		
		tbTask:LoadData(nParam);
	elseif (tbPlayerTask.tbTasks[nTaskId]) then
		tbPlayerTask.tbTasks[nTaskId]:CloseCurStep("finish");
		tbPlayerTask.tbTasks[nTaskId] = nil;
		tbPlayerTask.nCount	= tbPlayerTask.nCount - 1;
	end
	
	CoreEventNotify(UiNotify.emCOREEVENT_TASK_REFRESH, nTaskId, nReferId, nParam);
end

function Task:OnTrackTask(nTaskId)
	CoreEventNotify(UiNotify.emCOREEVENT_TASK_TRACK, nTaskId);
end

function Task:ShowInfoBoard(szInfo)
	local szMsg = Lib:ParseExpression(szInfo);
	szMsg = Task:ParseTag(szMsg);
	CoreEventNotify(UiNotify.emCOREEVENT_TASK_SHOWBOARD, szMsg)
end

function Task:GetPlayerMainTask(pPlayer)
	local tbMainTaskLogData = {};
	local tbPlayerTasks = self:GetPlayerTask(pPlayer);
	for _, tbTask in pairs(tbPlayerTasks.tbTasks) do
		if (tbTask.tbTaskData.tbAttribute.TaskType == 1) then
			local szTaskName = self:GetTaskName(tbTask.nTaskId);
			local szSubTaskName = self:GetManSubName(tbTask.nReferId);
			table.insert(tbMainTaskLogData, {szTaskName, szSubTaskName});
		end
	end

	return tbMainTaskLogData;
end


function Task:SharePickItem(pPlayer, pItem)
	local tbTeamMembers, nMemberCount	= pPlayer.GetTeamMemberList();
	if (not nMemberCount) then
		return;
	end

	for i = 1, nMemberCount do
		if (pPlayer.nPlayerIndex ~= tbTeamMembers[i].nPlayerIndex) then
			--if (Task:AtNearDistance(pPlayer, tbTeamMembers[i]) == 1) then
			if (pPlayer.nMapId == tbTeamMembers[i].nMapId) then
				Task:GetShareItem(tbTeamMembers[i], {pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel});
			end
		end
	end
end

function Task:GetShareItem(pPlayer, tbItem)
	Setting:SetGlobalObj(pPlayer)
	if (TaskCond:CanAddCountItemIntoBag(tbItem, 1)) then
		for _, tbTask in pairs(Task:GetPlayerTask(pPlayer).tbTasks) do
			if (tbTask:IsItemToBeCollect(tbItem) == 1) then
				Task:AddItem(pPlayer, tbItem, tbTask.nTaskId);
				Setting:RestoreGlobalObj()
				return 1;
			end
		end		
	end
	
	Setting:RestoreGlobalObj()
end

function Task:CanAcceptRepeatTask()
	local nAcceptTime = me.GetTask(2031, 1);
	if (nAcceptTime >= self.nRepeatTaskAcceptMaxTime) then
		return 0;
	end
	
	return 1;
end

function Task:GetTaskType(nTaskId)
	local nTaskId = tonumber(nTaskId);
	if (nTaskId) then
		for ni, tbTask in pairs(self.tbTaskTypes) do
			if nTaskId >= tbTask.nFirstId and nTaskId <= tbTask.nLastId then
				return tbTask.szTaskType;
			end
		end
	end
	
	return "Task";
end

function Task:GetTaskTypeName(nTaskId)
	local nTaskId = tonumber(nTaskId);
	if (nTaskId) then
		for ni, tbTask in pairs(self.tbTaskTypes) do
			if nTaskId >= tbTask.nFirstId and nTaskId <= tbTask.nLastId then
				return tbTask.szTaskName;
			end
		end
	end
	
	return "未知任务";
end

function Task:IsInstancingTask(nTaskId)
	if (nTaskId == 219 or nTaskId == 220 or nTaskId == 224) then
		return 1;
	end
	
	return 0;
end

function Task:IsCommerceTask(nTaskId)
	if (nTaskId == 50000) then
		return 1;
	end
	
	return 0;
end

--============= 任务目标自动寻路 ====================

-- 从指定语句当中获取
function Task:GetInfoFromSentence(szSource, szFormat)
	if (not szSource or not szFormat) then
		return;
	end
	local tbInfo = {};
	local s = 1;
	local e = 1;
	s, e = string.find(szSource, szFormat, 1);
	while (s and e and s ~= e) do
		local szSub = string.sub(szSource, s, e);
		s, e = string.find(szSource, szFormat, s + 1);
		table.insert(tbInfo, szSub);
	end
	return tbInfo;
end

-- 分析单条语句，返回改语句中的坐标信息
function Task:ParseSingleInfo(szDesc)
	if (not szDesc) then
		return;
	end
	local szFormat = "%<n?p?c?pos.-%>";				-- 模式匹配字符串，匹配"<" 和">" 之间的字符串
	local tbInfo = self:GetInfoFromSentence(szDesc, szFormat);
	if (not tbInfo or #tbInfo == 0) then
		return;
	end
	return tbInfo;
end

-- 获取一个任务当中某个步骤的的坐标信息
function Task:GetPosInfo(nTaskId, szTaskName, nCurStep)
	if (not szTaskName or not nCurStep or not nTaskId) then
		return;
	end
	if (not self.tbReferDatas or Lib:CountTB(self.tbReferDatas) <= 0) then
		return;
	end
	for _, tbInfo in pairs(self.tbReferDatas) do
		if (tbInfo.szName == szTaskName and tbInfo.tbDesc and
			tbInfo.tbDesc.tbStepsDesc and tbInfo.nTaskId == nTaskId and
			tbInfo.tbDesc.tbStepsDesc[nCurStep]) then
			local szCurStepInfo = tbInfo.tbDesc.tbStepsDesc[nCurStep];
			return self:ParseSingleInfo(szCurStepInfo);
		end
	end
end

-- 寻找关键字，例如传入参数是"<pos=红娘,5,1633,2941>"
-- 返回值就是"红娘"
function Task:FindKeyWord(szInfo)
	if (not szInfo) then
		return;
	end
	local s, e = string.find(szInfo, "=");
	if (not s or not e) then
		return;
	end
	local nBegin = e + 1;
	s, e = string.find(szInfo, ",", nBegin);
	if (not s or not e) then
		return;
	end
	local szKeyWord = string.sub(szInfo, nBegin, s - 1);
	if (not szKeyWord) then
		return;
	end
	
	return szKeyWord;
end

-- 在没有找到匹配的时候进行替换
-- szSource "与白秋琳对话"
-- szReplace "<npcpos=秋姨,X,X>"
-- 结果 "<npcpos=与白秋琳对话,X,X>"
function Task:ReplaceWhileNoMatch(szSource, szReplace)
	if (not szSource or not szReplace) then
		return;
	end
	local szKeyWord = self:FindKeyWord(szReplace);
	if (not szKeyWord) then
		return;
	end
	return string.gsub(szReplace, szKeyWord, szSource);
end

function Task:GetFinalDesc(szDesc, tbPosInfo)
	if (not tbPosInfo) then
		return szDesc;
	end
	
	for i, v in pairs(tbPosInfo) do
		tbPosInfo[i] = self:ReplaceName_Link(v);
	end
	szDesc = string.gsub(szDesc, "Thu Lâm", "Bạch Thu Lâm");
	
	local nPosCount = #tbPosInfo;
	if (tbPosInfo and #tbPosInfo > 0) then
		for _, szPosInfo in pairs(tbPosInfo) do
			local szKeyWord = Task:FindKeyWord(szPosInfo);
			local s, e = string.find(szDesc, szKeyWord);
			if (s and e and s ~= e) then
				szDesc = string.gsub(szDesc, szKeyWord, szPosInfo);
			elseif (nPosCount == 1) then
				szDesc = Task:ReplaceWhileNoMatch(szDesc, szPosInfo) or szDesc;
			end
		end
	end
	return szDesc;
end

-- 统一把任务描述和任务目标中超链接部分的“秋姨”全部替换为“白秋琳”
function Task:ReplaceName_Link(szSource)
	if (not szSource) then
		return;
	end
	local szFormat = "%<n?p?c?pos=Thu Lâm.-%>";
	local s, e = string.find(szSource, szFormat);
	if (s and e) then
		local szDst = string.gsub(szSource, "Thu Lâm", "Bạch Thu Lâm", 1);
		return szDst;
	end
	return szSource;
end

--===================================================
-- 需要满足一定条件才能选择的可选奖励

-- 判断一个任务是否是可选奖励有特殊条件的任务
function Task:IsSpeOptAward(nTaskId, nReferId, nIndex)
	if (not nTaskId or not nReferId or nTaskId <= 0 or nReferId <= 0 or not nIndex) then
		return 0;
	end
	
	local tbSpeOptInfo = self.tbSpeOptInfo or {};
	for _, tbInfo in pairs(tbSpeOptInfo) do
		if (tbInfo.nTaskId == nTaskId and tbInfo.nSubId == nReferId and
			tbInfo.nIndex == nIndex) then
			return 1;
		end
	end
	
	return 0;
end

-- 获取这个可选奖励对应内容
function Task:GetSpeOptInfo(nTaskId, nReferId, nIndex)
	if (not nTaskId or not nReferId or not nIndex) then
		return;
	end
	
	local nFaction = me.nFaction;
	local nRouteId = me.nRouteId;
	local nSeries = me.nSeries;
	if (not nFaction or not nRouteId or nFaction <= 0 or nRouteId <= 0) then
		return;
	end
	
	local tbRetInfo = {};
	local bFind = 0;
	local tbSpeOptInfo = self.tbSpeOptInfo or {};
	for _, tbInfo in pairs(tbSpeOptInfo) do
		if (tbInfo.nTaskId == nTaskId and tbInfo.nSubId == nReferId) then
			if (tbInfo.nTaskId == nTaskId and tbInfo.nSubId == nReferId and tbInfo.nIndex == nIndex and
				((tbInfo.nFaction ~= -1 and tbInfo.nFaction == nFaction) or tbInfo.nRoute == -1) and
				((tbInfo.nRoute ~= -1 and tbInfo.nRoute == nRouteId) or tbInfo.nRoute == -1) and
				((tbInfo.nSeries ~= -1 and tbInfo.nSeries == nSeries) or tbInfo.nSeries == -1) and
				tbInfo.nSex == me.nSex) then
					
					tbRetInfo = tbInfo;
					bFind = 1;
					break;
					
			end
		end

	end
	
	if (1 == bFind) then
		return tbRetInfo;
	else
		return;
	end
end

-- 读取配置文件中门派装备的信息
function Task:LoadSpeOptInfo()
	self.tbSpeOptInfo = {};
	local szSpeOptInfoFile = "\\setting\\task\\speoptaward.txt";
	local tbInfoSetting = Lib:LoadTabFile(szSpeOptInfoFile);
	if (not tbInfoSetting) then
		return;
	end
	
	for nRow, tbRowData in pairs(tbInfoSetting) do
		local nTaskId = tonumber(tbRowData["TaskId"]) or 0;
		local nSubId = tonumber(tbRowData["SubId"]) or 0;
		local nFaction = tonumber(tbRowData["Faction"]) or -1;
		local nRoute = tonumber(tbRowData["nRoute"]) or -1;
		local nSex = tonumber(tbRowData["Sex"]) or 0;
		local nIndex = tonumber(tbRowData["Index"]) or 0;
		local nCost = tonumber(tbRowData["Cost"]) or 0;
		local nSeries = tonumber(tbRowData["nSeries"]) or -1;
		local szCostGDPL = tostring(tbRowData["szCostGDPL"]) or "";
		local szGDPL = tostring(tbRowData["szGDPL"]) or "";
		local tbCostGDPL = Lib:SplitStr(szCostGDPL);
		local tbGDPL = Lib:SplitStr(szGDPL);
		
		local tbTemp = {};
		tbTemp.nTaskId = nTaskId;
		tbTemp.nSubId = nSubId;
		tbTemp.nFaction = nFaction;
		tbTemp.nRoute = nRoute;
		tbTemp.nSex = nSex;
		tbTemp.nIndex = nIndex;
		tbTemp.nCost = nCost;
		tbTemp.nSeries = nSeries;
		tbTemp.tbGDPL = {};
		tbTemp.tbCostGDPL = {};
		tbTemp.tbGDPL[1], tbTemp.tbGDPL[2], tbTemp.tbGDPL[3], tbTemp.tbGDPL[4] =
			tonumber(tbGDPL[1]), tonumber(tbGDPL[2]), tonumber(tbGDPL[3]) ,tonumber(tbGDPL[4]);
		tbTemp.tbCostGDPL[1], tbTemp.tbCostGDPL[2], tbTemp.tbCostGDPL[3], tbTemp.tbCostGDPL[4] =
			tonumber(tbCostGDPL[1]), tonumber(tbCostGDPL[2]), tonumber(tbCostGDPL[3]) ,tonumber(tbCostGDPL[4]);
		
		table.insert(self.tbSpeOptInfo, tbTemp);
	end
end

Task:LoadSpeOptInfo();

function Task:LoadCustomEquip()
	Task.tbCustomEquip = {};
	local tbCustomEquipAwardFile =  Lib:LoadTabFile("\\setting\\task\\customequip.txt");
	if (not tbCustomEquipAwardFile) then
		return;
	end
	for nId, tbParam in ipairs(tbCustomEquipAwardFile) do
		if nId >= 1 then
			local nIdEx = tonumber(tbParam.Id) or 0;
			local nFaction = tonumber(tbParam.Faction) or 0;
			local nRoutId = tonumber(tbParam.nRoute) or 0;
			local nSex = tonumber(tbParam.Sex) or -1;
			local szGDPL  = Lib:ClearStrQuote(tbParam.szGDPL) or "";
			if nIdEx ~= 0 and nFaction ~= 0 and nRoutId ~= 0 and nSex ~= -1 and szGDPL ~= "" then
				Task.tbCustomEquip[nIdEx] = Task.tbCustomEquip[nIdEx] or {};
				Task.tbCustomEquip[nIdEx][nFaction] = Task.tbCustomEquip[nIdEx][nFaction] or {};
				Task.tbCustomEquip[nIdEx][nFaction][nRoutId] = Task.tbCustomEquip[nIdEx][nFaction][nRoutId] or {};
				local tbItem = Lib:SplitStr(szGDPL);
				if #tbItem == 4 then
					Task.tbCustomEquip[nIdEx][nFaction][nRoutId][nSex] = {tonumber(tbItem[1]),tonumber(tbItem[2]),tonumber(tbItem[3]),tonumber(tbItem[4])};
				end
			end
		end
	end
end

Task:LoadCustomEquip();


--修复新手成就
function Task:RepairPrimerAchievement()
	if me.nLevel >= 20 then
		if me.nFaction > 0 then
			Achievement:FinishAchievement(me,414);
		end
		for i = 415,417 do
			Achievement:FinishAchievement(me,i);
		end
	end
end

function Task:CheckMantleLevel(nLevel)
	local pItem = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MANTLE, 0);
	if pItem and pItem.nLevel >= nLevel then
		return 1;
	end
	local szMsg = string.format("Không mặc Phi Phong hoặc Phi Phong chưa đủ cấp, cần trang bị Phi Phong cấp %s.", nLevel);
	return nil, szMsg;
end

