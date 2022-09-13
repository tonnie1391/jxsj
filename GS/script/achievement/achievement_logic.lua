--=================================================
-- 文件名　：achievement_logic.lua
-- 创建者　：furuilei
-- 创建时间：2010-07-05 16:29:27
-- 功能描述：成就系统达成条件逻辑部分
--=================================================





-- 通用的计数接口
function Achievement:__AddCount(nAchievementId, nWishCount, nAddCount)
	if (not nAchievementId or not nWishCount or nAchievementId <= 0 or nWishCount <= 0) then
		return;
	end
	nAddCount = nAddCount or 1;
	if (self:CheckFinished(nAchievementId) == 0) then
		local nCurCount = me.GetTask(self.TASK_GROUP_HELP, nAchievementId) + nAddCount;
		if (nCurCount >= nWishCount) then
			self:__FinishAchievement(nAchievementId);
			me.SetTask(self.TASK_GROUP_HELP, nAchievementId, 0);
		else
			me.SetTask(self.TASK_GROUP_HELP, nAchievementId, nCurCount);
		end
	end
end

--================================================

-- 杀死npc成就
function Achievement:OnKillNpc(pPlayer, nNpcTemplateId)
	-- 全局服返回
	if (GLOBAL_AGENT) then
		return;
	end
	
	if (self.FLAG_OPEN ~= 1) then
		return;
	end
	
	if (not pPlayer or not nNpcTemplateId or nNpcTemplateId <= 0) then
		return;
	end
	
	Setting:SetGlobalObj(pPlayer);
	self:__OnKillNpc(nNpcTemplateId);
	Setting:RestoreGlobalObj();
end

function Achievement:__OnKillNpc(nNpcTemplateId)
	local tbInfo_KillNpc = self:_GetAchievementList_KillNpc(nNpcTemplateId);
	if (not tbInfo_KillNpc or #tbInfo_KillNpc <= 0) then
		return;
	end
	
	for _, tbInfo in pairs(tbInfo_KillNpc) do
		local nAchievementId = tbInfo.nAchievementId;
		if (tbInfo.bTeamShare and tbInfo.bTeamShare == 1 and me.nTeamId > 0) then
			self:__TeamShareAchievement(me, nAchievementId, tbInfo.nCount);
		else
			if (self:CheckFinished(nAchievementId) == 0) then
				self:__AddCount(nAchievementId, tbInfo.nCount);
			end
		end
	end
end

-- 杀怪成就队伍共享
function Achievement:__TeamShareAchievement(pPlayer, nAchievementId, nWishCount)
	if (not pPlayer or not nAchievementId or not nWishCount or
		nAchievementId <= 0 or nWishCount <= 0) then
		return;
	end
	
	local tblMemberList, _ = pPlayer.GetTeamMemberList()
	if (not tblMemberList) then
		return;
	end
	
	local nMapId = him.nMapId;
	if (not nMapId or nMapId <= 0) then
		return;
	end
	
	for _, teamMember in pairs(tblMemberList) do
		if (nMapId == teamMember.nMapId) then
			Setting:SetGlobalObj(teamMember);
			if (self:CheckFinished(nAchievementId) == 0) then
				self:__AddCount(nAchievementId, nWishCount);
			end
			Setting:RestoreGlobalObj();
		end
	end
end

-- 返回杀死该npc对应的成就信息
-- {tbInfo1, tbInfo2, tbInfo3, ...}
function Achievement:_GetAchievementList_KillNpc(nNpcTemplateId)
	local tbRet = {};
	
	local tbCondInfo = self.tbCondInfo[self.INDEX_COND_KILLNPC];
	if (not tbCondInfo or #tbCondInfo <= 0) then
		return;
	end
	
	for _, tbInfo in pairs(tbCondInfo) do
		if (tbInfo.nNpcTemplateId1 == nNpcTemplateId or
			tbInfo.nNpcTemplateId2 == nNpcTemplateId or
			tbInfo.nNpcTemplateId3 == nNpcTemplateId or
			tbInfo.nNpcTemplateId4 == nNpcTemplateId or
			tbInfo.nNpcTemplateId5 == nNpcTemplateId or
			tbInfo.nNpcTemplateId6 == nNpcTemplateId or
			tbInfo.nNpcTemplateId7 == nNpcTemplateId or
			tbInfo.nNpcTemplateId8 == nNpcTemplateId) then
			table.insert(tbRet, tbInfo);
		end
	end
	
	return tbRet;
end

--=================================================

-- 进入指定地图成就
function Achievement:OnEnterMap(pPlayer, nMapTemplateId)
	-- 全局服返回
	if (GLOBAL_AGENT) then
		return;
	end
	
	if (self.FLAG_OPEN ~= 1) then
		return;
	end
	
	if (not pPlayer or not nMapTemplateId or nMapTemplateId <= 0) then
		return;
	end
	
	Setting:SetGlobalObj(pPlayer);
	self:__OnEnterMap(nMapTemplateId);
	Setting:RestoreGlobalObj();
end

function Achievement:__OnEnterMap(nMapTemplateId)
	local tbInfo_EnterMap = self:_GetAchievementList_EnterMap(nMapTemplateId);
	if (not tbInfo_EnterMap or #tbInfo_EnterMap <= 0) then
		return;
	end
	
	for _, tbInfo in pairs(tbInfo_EnterMap) do
		local nAchievementId = tbInfo.nAchievementId;
		self:__AddCount(nAchievementId, tbInfo.nCount);
	end
end

-- 返回进入指定地图的成就信息
-- {tbInfo1, tbInfo2, tbInfo3, ...}
function Achievement:_GetAchievementList_EnterMap(nMapTemplateId)
	if (not nMapTemplateId or nMapTemplateId <= 0) then
		return;
	end
	local tbRet = {};
	
	local tbCondInfo = self.tbCondInfo[self.INDEX_COND_MAP];
	if (not tbCondInfo or #tbCondInfo <= 0) then
		return;
	end
	
	for _, tbInfo in pairs(tbCondInfo) do
		if (tbInfo.nTemplateMapId1 == nMapTemplateId or tbInfo.nTemplateMapId2 == nMapTemplateId or
			tbInfo.nTemplateMapId3 == nMapTemplateId or tbInfo.nTemplateMapId4 == nMapTemplateId or
			tbInfo.nTemplateMapId5 == nMapTemplateId or tbInfo.nTemplateMapId6 == nMapTemplateId or
			tbInfo.nTemplateMapId7 == nMapTemplateId or tbInfo.nTemplateMapId8 == nMapTemplateId or
			tbInfo.nTemplateMapId9 == nMapTemplateId or tbInfo.nTemplateMapId10 == nMapTemplateId or
			tbInfo.nTemplateMapId11 == nMapTemplateId or tbInfo.nTemplateMapId12 == nMapTemplateId or
			tbInfo.nTemplateMapId13 == nMapTemplateId or tbInfo.nTemplateMapId14 == nMapTemplateId or
			tbInfo.nTemplateMapId15 == nMapTemplateId or tbInfo.nTemplateMapId16 == nMapTemplateId or
			tbInfo.nTemplateMapId17 == nMapTemplateId or tbInfo.nTemplateMapId18 == nMapTemplateId or
			tbInfo.nTemplateMapId19 == nMapTemplateId or tbInfo.nTemplateMapId20 == nMapTemplateId) then
			table.insert(tbRet, tbInfo);
		end
	end
	
	return tbRet;
end

--=================================================

-- 增加声望成就
function Achievement:OnAddRepute(pPlayer, nCampId, nClassId, nPoint)
	-- 全局服返回
	if (GLOBAL_AGENT) then
		return;
	end
	
	if (self.FLAG_OPEN ~= 1) then
		return;
	end
	
	if (not pPlayer or not nCampId or not nClassId or not nPoint or
		nCampId <= 0 or nClassId <= 0 or nPoint <= 0) then
		return;
	end
	
	Setting:SetGlobalObj(pPlayer);
	self:__OnAddRepute(nCampId, nClassId, nPoint);
	Setting:RestoreGlobalObj();	
end

function Achievement:__OnAddRepute(nCampId, nClassId, nPoint)
	local tbInfo_Repute = self:_GetAchievementList_Repute(nCampId, nClassId);
	if (not tbInfo_Repute or #tbInfo_Repute <= 0) then
		return;
	end
	for _, tbInfo in pairs(tbInfo_Repute) do
		local nAchievementId = tbInfo.nAchievementId;
		local nLevel = me.GetReputeLevel(nCampId, nClassId) or 0;
		if (nLevel > 0 and nLevel >= tbInfo.nLevel and self:CheckFinished(nAchievementId) == 0) then
			self:__FinishAchievement(nAchievementId);
		end
	end
end

-- 返回获得指定声望的成就信息
-- {tbInfo1, tbInfo2, tbInfo3, ...}
function Achievement:_GetAchievementList_Repute(nCampId, nClassId)
	local tbRet = {};
	
	local tbCondInfo = self.tbCondInfo[self.INDEX_COND_REPUTE];
	if (not tbCondInfo or #tbCondInfo <= 0) then
		return;
	end
	
	for _, tbInfo in pairs(tbCondInfo) do
		if (tbInfo.nCampId == nCampId and tbInfo.nClassId == nClassId) then
			table.insert(tbRet, tbInfo);
		end
	end
	
	return tbRet;
end

--=================================================

-- 增加称号
function Achievement:OnAddTitle(pPlayer, nGenre, nDetailtype, nlevel)
	-- 全局服返回
	if (GLOBAL_AGENT) then
		return;
	end
	
	if (self.FLAG_OPEN ~= 1) then
		return;
	end
	
	if (not pPlayer or not nGenre or not nDetailtype or not nlevel or
		nGenre <= 0 or nDetailtype <= 0 or nlevel <= 0) then
		return;
	end
	
	Setting:SetGlobalObj(pPlayer);
	self:__OnAddTitle(nGenre, nDetailtype, nlevel);
	Setting:RestoreGlobalObj();	
end

function Achievement:__OnAddTitle(nGenre, nDetailtype, nlevel)
	local tbInfo_Title = self:_GetAchievementList_Title(nGenre, nDetailtype, nlevel);
	if (not tbInfo_Title or #tbInfo_Title <= 0) then
		return;
	end
	
	for _, tbInfo in pairs(tbInfo_Title) do
		local nAchievementId = tbInfo_Title.nAchievementId;
		if (self:CheckFinished(nAchievementId) == 0) then
			self:__FinishAchievement(nAchievementId);
		end
	end
end

-- 返回获得指定称号的成就信息
-- {tbInfo1, tbInfo2, tbInfo3, ...}
function Achievement:_GetAchievementList_Title(nGenre, nDetailtype, nlevel)
	local tbRet = {};
	
	local tbCondInfo = self.tbCondInfo[self.INDEX_COND_TITLE];
	if (not tbCondInfo or #tbCondInfo <= 0) then
		return;
	end
	
	for _, tbInfo in pairs(tbCondInfo) do
		if (tbInfo.nGenre == nGenre and tbInfo.nDetailtype == nDetailtype and
			tbInfo.nlevel == nlevel) then
			table.insert(tbRet, tbInfo);
		end
	end
	
	return tbRet;
end


--=================================================

-- 完成所有下属成就的成就
function Achievement:OnAllAchievement()
	-- do nothing
end


--=================================================

-- 增加计数成就
function Achievement:OnAddAddCount(nAchievementId)
	-- 全局服返回
	if (GLOBAL_AGENT) then
		return;
	end
	
	if (self.FLAG_OPEN ~= 1) then
		return;
	end
	
	if (not nAchievementId or nAchievementId <= 0) then
		return;
	end
	
	self:__OnAddCount(nAchievementId);
end

function Achievement:__OnAddCount(nAchievementId)
	local tbInfo_Count = self:_GetAchievementList_Count(nAchievementId);
	if (not tbInfo_Count or #tbInfo_Count <= 0) then
		return;
	end
	
	for _, tbInfo in pairs(tbInfo_Count) do
		local nId = tbInfo.nAchievementId;
		if (self:CheckFinished(nId) == 0) then
			self:__AddCount(nId, tbInfo.nCount, tbInfo.nAddCount);
		end
	end
end

-- 返回获得指定声望的成就信息
-- {tbInfo1, tbInfo2, tbInfo3, ...}
function Achievement:_GetAchievementList_Count(nAchievementId)
	local tbRet = {};
	
	local tbCondInfo = self.tbCondInfo[self.INDEX_COND_COUNT];
	if (not tbCondInfo or #tbCondInfo <= 0) then
		return;
	end
	
	for _, tbInfo in pairs(tbCondInfo) do
		if (tbInfo.nAchievementId == nAchievementId) then
			table.insert(tbRet, tbInfo);
		end
	end
	
	return tbRet;
end
