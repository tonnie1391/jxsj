-- 文件名　：achivement.lua
-- 创建者　：furuilei
-- 创建时间：2009-10-19 10:29:41
-- 功能描述：成就系统

if (MODULE_GAMECLIENT) then
	return;
end

Achievement_ST.tbc2sFun = {};

-- 检查是否达到完成成就的条件
function Achievement_ST:CheckCondition(nAchievementId)	
	if (nAchievementId <= 0 or nAchievementId >= self.COUNT) then
		return 0;
	end
	
	if (not self.tbAchievementInfo[nAchievementId]) then
		return 0;
	end
	
	if (self.tbAchievementInfo[nAchievementId].bEffective and
		self.tbAchievementInfo[nAchievementId].bEffective == 0) then
		return 0
	end
	
	-- 只有当前有师傅的弟子才能加成就
	if (not me.GetTrainingTeacher()) then
		return 0;
	end
	
	if (self:GetTaskValue(nAchievementId) == 1) then
		return 0;
	end
	
	return 1;
end

-- 为gs提供的，设置成就的接口
function Achievement_ST:FinishAchievement(nPlayerId, nAchievementId)
	if (nPlayerId and nPlayerId <= 0) then
		return;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	
	Setting:SetGlobalObj(pPlayer);
	if (0 == self:CheckCondition(nAchievementId)) then
		Setting:RestoreGlobalObj();
		return;
	end
	
	-- 在每次获取成就的时候，对以往的成就（目前主要是固定成就）进行检测
	self:CheckPreviousAchievement();
	
	self:SetTaskValue(nAchievementId, 1);
	local szMsg = string.format("获得成就：%s", self.tbAchievementInfo[nAchievementId].szAchievement);
	me.Msg(szMsg);
	
	Setting:RestoreGlobalObj();
end

function Achievement_ST:__GetAchievementInfo(nAchievementId)
	if (nAchievementId <= 0 or nAchievementId >= self.COUNT) then
		return;
	end
	local tbInfo = {};
	tbInfo.nAchievementId = self.tbAchievementInfo[nAchievementId].nAchievementId;
	tbInfo.bAchieve = self:GetTaskValue(nAchievementId);	-- 是否完成成就
	tbInfo.bAward = self:GetTaskState(nAchievementId);		-- 是否领取相应成就的奖励
	return tbInfo;
end

function Achievement_ST:GetAchievementInfo()
	local tbInfo = {};
	-- for i, nAchievementId in pairs() do
	for i, v in pairs(self.tbAchievementInfo) do
		local tbTempInfo = self:__GetAchievementInfo(v.nAchievementId);
		table.insert(tbInfo, tbTempInfo);
	end
	return tbInfo;
end

-- 把指定的某项成就标记为已经领取过奖励了
function Achievement_ST:SetGetAwardFlag(nAchievementId)
	if (nAchievementId <= 0 or nAchievementId >= self.COUNT) then
		return;
	end
	
	self:SetTaskState(nAchievementId, 1);
end

-- 为客户端提供的用来获取成就信息的接口
function Achievement_ST:GetAchievementInfo_C2S(nPlayerId)
	if (not nPlayerId or nPlayerId <= 0) then
		return;
	end
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	
	Setting:SetGlobalObj(pPlayer);
	local tbInfo = self:GetAchievementInfo();
	me.CallClientScript({"Achievement_ST:SyncAchievementInfo", tbInfo});
	Setting:RestoreGlobalObj();
end
Achievement_ST.tbc2sFun["GetAchievementInfo_C2S"] = Achievement_ST.GetAchievementInfo_C2S;

-- 获取指定类型的所有成就的列表
-- 返回值：{{nAchievementId, bAchieve}, {nAchievementId, bAchieve}, ...}
function Achievement_ST:GetSpeTypeAchievementInfo(nPlayerId, szType)
	if (not nPlayerId or nPlayerId <= 0 or not szType or szType == "") then
		return;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	Setting:SetGlobalObj(pPlayer);
	local tbSpeType = {};
	for _, tbInfo in pairs(self.tbAchievementInfo) do
		if (tbInfo.szType == szType) then
			local tbTemp = {};
			tbTemp.nAchievementId = tbInfo.nAchievementId;
			tbTemp.bAchieve = self:GetTaskValue(tbInfo.nAchievementId);
			table.insert(tbSpeType, tbTemp);
		end
	end
	Setting:RestoreGlobalObj();
	
	return tbSpeType;
end

-- 检查过去的成就（主要是固定成就，在玩家完成任何一项成就的时候触发）
function Achievement_ST:CheckPreviousAchievement(bByHand)
	-- 只有当前有师傅的弟子才会修复过去的固定成就
	if (not me.GetTrainingTeacher()) then
		return;
	end
	
	-- 手工修复的时候，不做检查
	if (not bByHand or bByHand ~= 1) then
		-- 任何一项成就不为0，就表示已经设置过成就，不需要再次检查了
		for _, tbInfo in pairs(self.tbAchievementInfo) do
			if (self:GetTaskValue(tbInfo.nAchievementId) == 1) then
				return;
			end
		end
	end
	
	-- 检查主线类型的成就
	for nAchievementId, tbTaskIdInfo in pairs(self.tbMainTaskId) do
		for _, tbTaskId in pairs(tbTaskIdInfo) do
			local nMainTaskId = tbTaskId[1];
			local nSubTaskId = tbTaskId[2];
			if (me.GetTask(1000, nMainTaskId) >= nSubTaskId) then
				self:SetTaskValue(nAchievementId, 1);
			end
		end
	end
	
	-- 检查是否加入家族
	if (me.dwKinId > 0) then
		self:SetTaskValue(self.ENTER_KIN, 1);
	end
	
	-- 是否进行过祈福
	local nRepute = me.GetReputeValue(5, 4);
	if (0 ~= nRepute) then
		self:SetTaskValue(self.QIFU, 1);
	end
	
	-- 生活技能
	for i = 1, 10 do
		local nLifeSkillLevel = LifeSkill:GetSkillLevel(me, i);
		if (nLifeSkillLevel >= 20) then
			self:SetTaskValue(self.LIFISKILL_20, 1);
		end
		if (nLifeSkillLevel >= 30) then
			self:SetTaskValue(self.LIFISKILL_30, 1);
		end
	end
	
	-- 剑侠词典
	-- HelpQuestion:LoadQuestion();
	local nGroupNum = Lib:CountTB(HelpQuestion.tbGroup);
	for i = 1, nGroupNum do
		if (me.GetTaskBit(HelpQuestion.TASK_GROUP_ID, i) == 1) then
			self:SetTaskValue(self.JXCIDIAN, 1);
		end
	end
end
