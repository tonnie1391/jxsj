-- 文件名　：achievement_base.lua
-- 创建者　：furuilei
-- 创建时间：2010-07-02 10:49:07
-- 功能描述：成就系统，读取配置文件，组织数据结构

Require("\\script\\achievement\\achievement_define.lua")

--=============================================

Achievement.FILE_ACHIEVEMENT	= "\\setting\\achievement\\achievement.txt";
Achievement.FILE_COND_REPUET	= "\\setting\\achievement\\cond_repute.txt";
Achievement.FILE_COND_TITLE		= "\\setting\\achievement\\cond_title.txt";
Achievement.FILE_COND_MAP		= "\\setting\\achievement\\cond_map.txt";
Achievement.FILE_COND_KILLNPC	= "\\setting\\achievement\\cond_killnpc.txt";
Achievement.FILE_COND_ALL		= "\\setting\\achievement\\cond_all.txt";
Achievement.FILE_COND_COUNT		= "\\setting\\achievement\\cond_count.txt";

Achievement.FILE_AWARD_TITLE	= "\\setting\\achievement\\award_title.txt";

--=============================================

-- 检查一个传入的成就信息是否是有效地信息
function Achievement:IsAvailable(tbAchievementInfo)
	if (not tbAchievementInfo) then
		return 0;
	end
	
	if (not tbAchievementInfo.nAchievementId or tbAchievementInfo.nAchievementId == 0) then
		return 0;
	end
	
	if (not tbAchievementInfo.nGroupId or tbAchievementInfo.nGroupId == 0) then
		return 0;
	end
	if (not tbAchievementInfo.nSubGroupId or tbAchievementInfo.nSubGroupId == 0) then
		return 0;
	end
	if (not tbAchievementInfo.nIndex or tbAchievementInfo.nIndex == 0) then
		return 0;
	end
	
	if (not tbAchievementInfo.bEffective or tbAchievementInfo.bEffective == 0) then
		return 0;
	end
	
	return 1;
end

function Achievement:LoadFile_AddAchievementInfo(nGroupId, nSubGroupId, nIndex, tbInfo)
	if (not nGroupId or not nSubGroupId or not nIndex or not tbInfo) then
		return;
	end

	self.tbAchievementInfo[nGroupId] = self.tbAchievementInfo[nGroupId] or {};
	self.tbAchievementInfo[nGroupId][nSubGroupId] = self.tbAchievementInfo[nGroupId][nSubGroupId] or {};
	if (not self.tbAchievementInfo[nGroupId][nSubGroupId][nIndex]) then
		self.tbAchievementInfo[nGroupId][nSubGroupId][nIndex] = tbInfo;
	end
	
	self.tbMapingInfo = self.tbMapingInfo or {};
	self.tbMapingInfo[tbInfo.nAchievementId] = {nGroupId, nSubGroupId, nIndex};
end

-- 加载成就信息文件
function Achievement:LoadFile_Achievement()
	self.tbAchievementInfo = {};
	
	local tbAchievementSetting = Lib:LoadTabFile(self.FILE_ACHIEVEMENT);
	for nRow, tbRowData in pairs(tbAchievementSetting) do
		local tbTemp = {};
		tbTemp.nAchievementId	= tonumber(tbRowData["nAchievementId"]) or 0;
		tbTemp.nGroupId			= tonumber(tbRowData["nGroupId"]) or 0;
		tbTemp.nSubGroupId		= tonumber(tbRowData["nSubGroupId"]) or 0;
		tbTemp.nIndex			= tonumber(tbRowData["nIndex"]) or 0;
		tbTemp.nLevel			= tonumber(tbRowData["nLevel"]) or 0;
		tbTemp.szGroupName		= tostring(tbRowData["szGroupName"]) or "";
		tbTemp.szSubGroupName	= tostring(tbRowData["szSubGroupName"]) or "";
		tbTemp.szAchivementName	= tostring(tbRowData["szAchivementName"]) or "";
		tbTemp.szDesc			= tostring(tbRowData["szDesc"]) or "";
		tbTemp.nPoint			= tonumber(tbRowData["nPoint"]) or 0;
		tbTemp.bTrack			= tonumber(tbRowData["bTrack"]) or 0;
		tbTemp.bProcess			= tonumber(tbRowData["bProcess"]) or 0;
		tbTemp.nMaxCount		= tonumber(tbRowData["nMaxCount"]) or 0;
		tbTemp.nCondType		= tonumber(tbRowData["nCondType"]) or 0;
		tbTemp.nCondIndex		= tonumber(tbRowData["nCondIndex"]) or 0;
		tbTemp.nExp				= tonumber(tbRowData["nExp"]) or 0;
		tbTemp.nBindMoney		= tonumber(tbRowData["nBindMoney"]) or 0;
		tbTemp.nBindCoin		= tonumber(tbRowData["nBindCoin"]) or 0;
		tbTemp.nTitleId			= tonumber(tbRowData["nTitleId"]) or 0;
		tbTemp.bIsSub			= tonumber(tbRowData["bIsSubAchievement"]) or 0;
		tbTemp.bEffective		= tonumber(tbRowData["bEffective"]) or 0;
		
		if (1 == self:IsAvailable(tbTemp)) then
			self:LoadFile_AddAchievementInfo(tbTemp.nGroupId, tbTemp.nSubGroupId, tbTemp.nIndex, tbTemp);
		end
	end
end

-- 加载通用成就达成条件（声望）
function Achievement:LoadFile_Cond_Repute(nCondIndex)
	if (not nCondIndex) then
		return;
	end
	
	Achievement.tbCondInfo = Achievement.tbCondInfo or {};
	Achievement.tbCondInfo[nCondIndex] = {};
	local tbCondInfo = Achievement.tbCondInfo[nCondIndex] or {};
	
	local tbCondSetting = Lib:LoadTabFile(self.FILE_COND_REPUET);
	for nRow, tbRowData in pairs(tbCondSetting) do
		local tbTemp = {};
		tbTemp.nIndex	= tonumber(tbRowData["nIndex"]) or 0;
		tbTemp.nCampId	= tonumber(tbRowData["nCampId"]) or 0;
		tbTemp.nClassId	= tonumber(tbRowData["nClassId"]) or 0;
		tbTemp.nLevel	= tonumber(tbRowData["nLevel"]) or 0;
		
		tbCondInfo[tbTemp.nIndex] = tbTemp;
	end
end

-- 加载通用成就达成条件（称号）
function Achievement:LoadFile_Cond_Title(nCondIndex)
	if (not nCondIndex) then
		return;
	end
	
	Achievement.tbCondInfo = Achievement.tbCondInfo or {};
	Achievement.tbCondInfo[nCondIndex] = {};
	local tbCondInfo = Achievement.tbCondInfo[nCondIndex] or {};
	
	local tbCondSetting = Lib:LoadTabFile(self.FILE_COND_TITLE);
	for nRow, tbRowData in pairs(tbCondSetting) do
		local tbTemp = {};
		tbTemp.nIndex		= tonumber(tbRowData["nIndex"]) or 0;
		tbTemp.nGenre		= tonumber(tbRowData["nGenre"]) or 0;
		tbTemp.nDetailtype	= tonumber(tbRowData["nDetailtype"]) or 0;
		tbTemp.nlevel		= tonumber(tbRowData["nlevel"]) or 0;
		
		tbCondInfo[tbTemp.nIndex] = tbTemp;
	end
end

-- 加载通用成就达成条件（到达指定地图）
function Achievement:LoadFile_Cond_Map(nCondIndex)
	if (not nCondIndex) then
		return;
	end
	
	Achievement.tbCondInfo = Achievement.tbCondInfo or {};
	Achievement.tbCondInfo[nCondIndex] = {};
	local tbCondInfo = Achievement.tbCondInfo[nCondIndex] or {};
	
	local tbCondSetting = Lib:LoadTabFile(self.FILE_COND_MAP);
	for nRow, tbRowData in pairs(tbCondSetting) do
		local tbTemp = {};
		tbTemp.nIndex			= tonumber(tbRowData["nIndex"]) or 0;
		tbTemp.nTemplateMapId1	= tonumber(tbRowData["nTemplateMapId1"]) or 0;
		tbTemp.nTemplateMapId2	= tonumber(tbRowData["nTemplateMapId2"]) or 0;
		tbTemp.nTemplateMapId3	= tonumber(tbRowData["nTemplateMapId3"]) or 0;
		tbTemp.nTemplateMapId4	= tonumber(tbRowData["nTemplateMapId4"]) or 0;
		tbTemp.nTemplateMapId5	= tonumber(tbRowData["nTemplateMapId5"]) or 0;
		tbTemp.nTemplateMapId6	= tonumber(tbRowData["nTemplateMapId6"]) or 0;
		tbTemp.nTemplateMapId7	= tonumber(tbRowData["nTemplateMapId7"]) or 0;
		tbTemp.nTemplateMapId8	= tonumber(tbRowData["nTemplateMapId8"]) or 0;
		tbTemp.nTemplateMapId9	= tonumber(tbRowData["nTemplateMapId9"]) or 0;
		tbTemp.nTemplateMapId10	= tonumber(tbRowData["nTemplateMapId10"]) or 0;
		tbTemp.nTemplateMapId11	= tonumber(tbRowData["nTemplateMapId11"]) or 0;
		tbTemp.nTemplateMapId12	= tonumber(tbRowData["nTemplateMapId12"]) or 0;
		tbTemp.nTemplateMapId13	= tonumber(tbRowData["nTemplateMapId13"]) or 0;
		tbTemp.nTemplateMapId14	= tonumber(tbRowData["nTemplateMapId14"]) or 0;
		tbTemp.nTemplateMapId15	= tonumber(tbRowData["nTemplateMapId15"]) or 0;
		tbTemp.nTemplateMapId16	= tonumber(tbRowData["nTemplateMapId16"]) or 0;
		tbTemp.nTemplateMapId17	= tonumber(tbRowData["nTemplateMapId17"]) or 0;
		tbTemp.nTemplateMapId18	= tonumber(tbRowData["nTemplateMapId18"]) or 0;
		tbTemp.nTemplateMapId19	= tonumber(tbRowData["nTemplateMapId19"]) or 0;
		tbTemp.nTemplateMapId20	= tonumber(tbRowData["nTemplateMapId20"]) or 0;
		tbTemp.nCount			= tonumber(tbRowData["nCount"]) or 1;
		
		tbCondInfo[tbTemp.nIndex] = tbTemp;
	end
end

-- 加载通用成就达成条件（杀死npc）
function Achievement:LoadFile_Cond_KillNpc(nCondIndex)
	if (not nCondIndex) then
		return;
	end
	
	Achievement.tbCondInfo = Achievement.tbCondInfo or {};
	Achievement.tbCondInfo[nCondIndex] = {};
	local tbCondInfo = Achievement.tbCondInfo[nCondIndex] or {};
	
	local tbCondSetting = Lib:LoadTabFile(self.FILE_COND_KILLNPC);
	for nRow, tbRowData in pairs(tbCondSetting) do
		local tbTemp = {};
		tbTemp.nIndex			= tonumber(tbRowData["nIndex"]) or 0;
		tbTemp.nNpcTemplateId1	= tonumber(tbRowData["nNpcTemplateId1"]) or 0;
		tbTemp.nNpcTemplateId2	= tonumber(tbRowData["nNpcTemplateId2"]) or 0;
		tbTemp.nNpcTemplateId3	= tonumber(tbRowData["nNpcTemplateId3"]) or 0;
		tbTemp.nNpcTemplateId4	= tonumber(tbRowData["nNpcTemplateId4"]) or 0;
		tbTemp.nNpcTemplateId5	= tonumber(tbRowData["nNpcTemplateId5"]) or 0;
		tbTemp.nNpcTemplateId6	= tonumber(tbRowData["nNpcTemplateId6"]) or 0;
		tbTemp.nNpcTemplateId7	= tonumber(tbRowData["nNpcTemplateId7"]) or 0;
		tbTemp.nNpcTemplateId8	= tonumber(tbRowData["nNpcTemplateId8"]) or 0;
		tbTemp.bTeamShare		= tonumber(tbRowData["bTeamShare"]) or 0;
		tbTemp.nCount			= tonumber(tbRowData["nCount"]) or 1;
		
		tbCondInfo[tbTemp.nIndex] = tbTemp;
	end
end

-- 加载通用成就达成条件（完成所有指定成就）
function Achievement:LoadFile_Cond_All(nCondIndex)
	if (not nCondIndex) then
		return;
	end
	
	Achievement.tbCondInfo = Achievement.tbCondInfo or {};
	Achievement.tbCondInfo[nCondIndex] = {};
	local tbCondInfo = Achievement.tbCondInfo[nCondIndex] or {};
	
	local tbCondSetting = Lib:LoadTabFile(self.FILE_COND_ALL);
	for nRow, tbRowData in pairs(tbCondSetting) do
		local tbTemp = {};
		tbTemp.nIndex			= tonumber(tbRowData["nIndex"]) or 0;
		tbTemp.nAchievementId1	= tonumber(tbRowData["nAchievementId1"]) or 0;
		tbTemp.nAchievementId2	= tonumber(tbRowData["nAchievementId2"]) or 0;
		tbTemp.nAchievementId3	= tonumber(tbRowData["nAchievementId3"]) or 0;
		tbTemp.nAchievementId4	= tonumber(tbRowData["nAchievementId4"]) or 0;
		tbTemp.nAchievementId5	= tonumber(tbRowData["nAchievementId5"]) or 0;
		tbTemp.nAchievementId6	= tonumber(tbRowData["nAchievementId6"]) or 0;
		tbTemp.nAchievementId7	= tonumber(tbRowData["nAchievementId7"]) or 0;
		tbTemp.nAchievementId8	= tonumber(tbRowData["nAchievementId8"]) or 0;
		tbTemp.nAchievementId9	= tonumber(tbRowData["nAchievementId9"]) or 0;
		tbTemp.nAchievementId10	= tonumber(tbRowData["nAchievementId10"]) or 0;
		tbTemp.nAchievementId11	= tonumber(tbRowData["nAchievementId11"]) or 0;
		tbTemp.nAchievementId12	= tonumber(tbRowData["nAchievementId12"]) or 0;
		tbTemp.nAchievementId13	= tonumber(tbRowData["nAchievementId13"]) or 0;
		tbTemp.nAchievementId14	= tonumber(tbRowData["nAchievementId14"]) or 0;
		tbTemp.nAchievementId15	= tonumber(tbRowData["nAchievementId15"]) or 0;
		
		tbCondInfo[tbTemp.nIndex] = tbTemp;
	end
end

function Achievement:LoadFile_Cond_Count(nCondIndex)
	if (not nCondIndex) then
		return;
	end
	
	Achievement.tbCondInfo = Achievement.tbCondInfo or {};
	Achievement.tbCondInfo[nCondIndex] = {};
	local tbCondInfo = Achievement.tbCondInfo[nCondIndex] or {};
	
	local tbCondSetting = Lib:LoadTabFile(self.FILE_COND_COUNT);
	for nRow, tbRowData in pairs(tbCondSetting) do
		local tbTemp = {};
		tbTemp.nIndex		= tonumber(tbRowData["nIndex"]) or 0;
		tbTemp.nCount		= tonumber(tbRowData["nCount"]) or 0;
		tbTemp.nAddCount	= tonumber(tbRowData["nAddCount"]) or 0;
		tbCondInfo[tbTemp.nIndex] = tbTemp;
	end
end

-- 加载通用成就达成奖励（称号）
function Achievement:LoadFile_Award_Title(nAwardIndex)
	if (not nAwardIndex) then
		return;
	end
	
	Achievement.tbAwardInfo = Achievement.tbAwardInfo or {};
	Achievement.tbAwardInfo[nAwardIndex] = {};
	local tbAwardInfo = Achievement.tbAwardInfo[nAwardIndex] or {};
	
	local tbAwardSetting = Lib:LoadTabFile(self.FILE_AWARD_TITLE);
	for nRow, tbRowData in pairs(tbAwardSetting) do
		local tbTemp = {};
		tbTemp.nIndex		= tonumber(tbRowData["nIndex"]) or 0;
		tbTemp.szTitle		= tostring(tbRowData["szTitle"]) or "";
		tbTemp.nTime		= tonumber(tbRowData["nTime"]) or 0;
		
		tbAwardInfo[tbTemp.nIndex] = tbTemp;
	end
end

function Achievement:CreateCond_Maping()
	for nGroupId, tbGroupInfo in pairs(self.tbAchievementInfo) do
		for nSubGroupId, tbSubInfo in pairs(tbGroupInfo) do
			for nIndex, tbInfo in pairs(tbSubInfo) do
				
				local nCondType = tbInfo.nCondType;
				local nCondIndex = tbInfo.nCondIndex;
				if (nCondType ~= 0 and nCondIndex ~= 0) then
					if (self.tbCondInfo and self.tbCondInfo[nCondType] and
						self.tbCondInfo[nCondType][nCondIndex]) then
						self.tbCondInfo[nCondType][nCondIndex].nAchievementId = tbInfo.nAchievementId;
					end
				end
				
			end
		end
	end
	
	-- 对tbCondInfo 重复遍历一遍，没有对应nAchievementId 的对应成默认的无效值0
	for nCondType, tbInfo_Type in pairs(self.tbCondInfo) do
		for nIndex, tbInfo in pairs(tbInfo_Type) do
			if (not tbInfo.nAchievementId) then
				tbInfo.nAchievementId = 0;
			end
		end
	end
end

function Achievement:LoadFile()
	self:LoadFile_Achievement();
	self:LoadFile_Cond_Repute(self.INDEX_COND_REPUTE);
	self:LoadFile_Cond_Title(self.INDEX_COND_TITLE);
	self:LoadFile_Cond_Map(self.INDEX_COND_MAP);
	self:LoadFile_Cond_KillNpc(self.INDEX_COND_KILLNPC);
	self:LoadFile_Cond_All(self.INDEX_COND_ALL);
	self:LoadFile_Cond_Count(self.INDEX_COND_COUNT);
	self:CreateCond_Maping();
	
	self:LoadFile_Award_Title(self.INDEX_AWARD_TITLE)
end
Achievement:LoadFile();

--========================================================

-- 检查是否完成了指定成就
function Achievement:CheckFinished(nAchievementId)
	if (not nAchievementId or nAchievementId <= 0) then
		return 0;
	end
	
	return me.GetTaskBit(self.TASK_GROUP_ACV, nAchievementId);
end

-- 设置完成了某项成就
function Achievement:SetFinished(nAchievementId)
	if (not nAchievementId or nAchievementId <= 0) then
		return 0;
	end
	
	me.SetTaskBit(self.TASK_GROUP_ACV, nAchievementId, 1);
end

-- 获取积累的成就点数
function Achievement:GetAchievementPoint(pPlayer)
	if (not pPlayer) then
		return;
	end
	return pPlayer.GetTask(self.TASK_GROUP_POINT, self.TSK_ID_POINT_ACCUMULATE);
end

-- 设置积累的成就点数
function Achievement:SetAchievementPoint(pPlayer, nPoint)
	if (not pPlayer) then
		return;
	end
	pPlayer.SetTask(self.TASK_GROUP_POINT, self.TSK_ID_POINT_ACCUMULATE, nPoint);
end

-- 获取当前成就点数
function Achievement:GetAchievementPoint_Cur(pPlayer)
	if (not pPlayer) then
		return;
	end
	return pPlayer.GetTask(self.TASK_GROUP_POINT, self.TSK_ID_POINT_CUR);
end

-- 设置当前成就点数
function Achievement:SetAchievementPoint_Cur(pPlayer, nPoint)
	if (not pPlayer) then
		return;
	end
	pPlayer.SetTask(self.TASK_GROUP_POINT, self.TSK_ID_POINT_CUR, nPoint);
end

-- 获取当前可消费成就积分
function Achievement:GetConsumeablePoint(pPlayer)
	if (not pPlayer) then
		return;
	end
	
	return pPlayer.GetTask(self.TASK_GROUP_POINT, self.TSK_ID_CONSUMABLE_POINT);
end

-- 设置当前可消费成就积分
function Achievement:SetConsumablePoint(pPlayer, nPoint)
	if (not pPlayer) then
		return;
	end
	
	pPlayer.SetTask(self.TASK_GROUP_POINT, self.TSK_ID_CONSUMABLE_POINT, nPoint);
end

-- 获取指定成就对应的计数
function Achievement:GetFinishNum(pPlayer, nAchievementId)
	if (not pPlayer or not nAchievementId or nAchievementId <= 0) then
		return 0;
	end
	
	return pPlayer.GetTask(self.TASK_GROUP_HELP, nAchievementId);
end

-- 设置某个成就对应的计数
function Achievement:SetFinishNum(pPlayer, nAchievementId, nNum)
	if (not pPlayer or not nAchievementId or not nNum or nAchievementId <= 0) then
		return;
	end
	
	pPlayer.SetTask(self.TASK_GROUP_HELP, nAchievementId, nNum);
end

--========================================================

-- 根据nGroupId, nSubGroupId, nIndex 获取对应的成就的详细信息
function Achievement:GetAchievementInfo(nGroupId, nSubGroupId, nIndex)
	if (not nGroupId or not nSubGroupId or not nIndex) then
		return;
	end
	
	if (not self.tbAchievementInfo[nGroupId] or
		not self.tbAchievementInfo[nGroupId][nSubGroupId] or
		not self.tbAchievementInfo[nGroupId][nSubGroupId][nIndex]) then
		return;
	end

	return self.tbAchievementInfo[nGroupId][nSubGroupId][nIndex];
end

-- 根据id获取成就具体信息
function Achievement:GetAchievementInfoById(nAchievementId)
	if (not nAchievementId or nAchievementId <= 0) then
		return;
	end
	
	local nGroupId, nSubGroupId, nIndex = self:GetIndexInfoById(nAchievementId);
	if (not nGroupId or not nSubGroupId or not nIndex) then
		return;
	end
	
	return self:GetAchievementInfo(nGroupId, nSubGroupId, nIndex) or {};
end

-- 返回最大的一个成就id
function Achievement:GetMaxId()
	local nRet = 0;
	for nId, _ in pairs(self.tbMapingInfo) do
		if (nId > nRet) then
			nRet = nId;
		end
	end
	
	return nRet;
end

-- 根据nAchievementId 获取nGroupId, nSubGroupId, nIndex
function Achievement:GetIndexInfoById(nAchievementId)
	if (not nAchievementId or nAchievementId <= 0) then
		return;
	end
	
	if (not self.tbMapingInfo or not self.tbMapingInfo[nAchievementId]) then
		return;
	end
	
	return unpack(self.tbMapingInfo[nAchievementId]);
end

-- 根据nGroupId, nSubGroupId, nIndex 获取对应的成就的id
function Achievement:GetIdByIndexInfo(nGroupId, nSubGroupId, nIndex)
	if (not nGroupId or not nSubGroupId or not nIndex) then
		return;
	end
	
	local tbInfo = self:GetAchievementInfo(nGroupId, nSubGroupId, nIndex);
	return tbInfo.nAchievementId;
end

-- 获取指定成就对应的达成类型以及索引
function Achievement:GetAchievementCondInfo(nAchievementId)
	if (not nAchievementId or nAchievementId <= 0) then
		return;
	end
	
	local nGroupId, nSubGroupId, nIndex = self:GetIndexInfoById(nAchievementId);
	if (not nGroupId or not nSubGroupId or not nIndex) then
		return;
	end
	
	local tbInfo = self:GetAchievementInfo(nGroupId, nSubGroupId, nIndex);
	if (not tbInfo) then
		return;
	end
	
	return tbInfo.nCondType, tbInfo.nCondIndex;
end

function Achievement:GetAchievementName(nAchievementId)
	if (not nAchievementId or nAchievementId <= 0) then
		return;
	end
	
	local nGroupId, nSubGroupId, nIndex = self:GetIndexInfoById(nAchievementId);
	if (not nGroupId or not nSubGroupId or not nIndex) then
		return;
	end
	
	local tbInfo = self:GetAchievementInfo(nGroupId, nSubGroupId, nIndex);
	return tbInfo.szAchivementName;
end
