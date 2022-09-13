EPlatForm.CastleFight = EPlatForm.CastleFight or {};

function EPlatForm.CastleFight:GetNewMission()
	return Lib:NewClass(EPlatForm.CastleFight);	
end

-- nMatchType 表示活动类型是混战还是组队pvp
-- 若是混战那么就是2
-- 若是组队pvp就是3,4
function EPlatForm.CastleFight:OpenMission(tbEnterPos, tbLeavePos, nMatchType, nReadyId)
	self.tbMission = self.tbMission or Lib:NewClass(CastleFight.Mission);
	self.tbMission:Init(tbEnterPos, tbLeavePos, nMatchType);
	self.tbMission.tbCallbackOnClose = {self.OnMissionClose, self};
	self.tbEnterPos = tbEnterPos;
	self.nTaskId = nTaskId;
	self.tbTeamId = {};
	self.tbGroupId2LeageName = {};
	self.tbLeageName2PlayerList = {};
	self.tbTeam_Step1 = {
			[1] = {},
			[2] = {},
		};
	self.nGroupCount = 0;
	self.nGroupId = 1;
	self.nReadyId = nReadyId or 0;
	self.nMatchType = nMatchType;
end

function EPlatForm.CastleFight:IsOpen()
	if (self.tbMission and self.tbMission.IsOpen) then
		return self.tbMission:IsOpen();
	end
	return 0;
end

function EPlatForm.CastleFight:StartGame()
	self.tbMission:__start();
end

function EPlatForm.CastleFight:OnMissionClose()
	local tbRes = self.tbMission:GetResult();
	if not tbRes then
		return;
	end
	local tbResFinal = {};
	for _, tbInfo in ipairs(tbRes) do
		local tbGroup = {};
		tbGroup.szLeagueName = self.tbGroupId2LeageName[tbInfo[1]];
		tbGroup.tbPlayerList = self.tbLeageName2PlayerList[tbGroup.szLeagueName];
		if (tbGroup.szLeagueName and tbGroup.tbPlayerList) then
			tbGroup.nDamage		 = tbInfo[2];
			table.insert(tbResFinal, tbGroup)
		end
	end
	
	self.__tbResFinal = tbResFinal;
	EPlatForm:SendResult(tbResFinal, self.nReadyId);
end

function EPlatForm.CastleFight:GetEnterPos()
	return self.tbEnterPos;
end

function EPlatForm.CastleFight:GetGroupCount()
	return self.nGroupCount or 0;
end

function EPlatForm.CastleFight:JoinGame_Melee(tbGroup, nTypeId, tbJoinItem)
	local tbPlayer = {};
	for _, nId in ipairs(tbGroup.tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer then
			table.insert(tbPlayer, pPlayer);
		end
	end
	
	local nTeamNumA = #self.tbTeam_Step1[1];
	local nTeamNumB = #self.tbTeam_Step1[2];
	local nCampId = 0;
	local nNeedCeateTeam = 0;
	
	if #tbPlayer > 0 then
		if (nTeamNumA <= nTeamNumB) then
			nCampId = 1;
			if (nTeamNumA <= 0) then
				nNeedCeateTeam = 1;
			end
		else
			nCampId = 2;
			if (nTeamNumB <= 0) then
				nNeedCeateTeam = 1;
			end
		end
		table.insert(self.tbTeam_Step1[nCampId], tbPlayer[1].nId);
		if (nNeedCeateTeam == 1) then
			KTeam.CreateTeam(tbPlayer[1].nId);	
		else
			KTeam.ApplyJoinPlayerTeam(self.tbTeam_Step1[nCampId][1], tbPlayer[1].nId);
		end

		for _, pPlayer in ipairs(tbPlayer) do
			local tbFind = {};
			-- 保证进来的时候只有一个龙舟
			for _, tbItemInfo in pairs(tbJoinItem) do
				if (tbItemInfo.tbItem) then
					tbFind = pPlayer.FindItemInBags(unpack(tbItemInfo.tbItem));
					if (tbFind and #tbFind > 0) then
						break;
					end
				end	
			end
		
			local pItem = tbFind[MathRandom(1,#tbFind)].pItem;
			self.tbMission.tbSkillList = self.tbMission.tbSkillList or {};
			self.tbMission.tbSkillList[pPlayer.nId] = pItem.dwId;

			self.tbMission.tbItemSkill = self.tbMission.tbItemSkill or {};
			self.tbMission.tbItemSkill[pPlayer.nId] = 0;
			if (pItem.nLevel == 2) then
				self.tbMission.tbItemSkill[pPlayer.nId] = 1;
			end			
			
			self.tbMission:JoinPlayer(pPlayer, nCampId);
			
			-- 记录参加家族竞技的次数
			Player:AddJoinRecord_DailyCount(pPlayer, Player.EVENT_JOIN_RECORD_JIAZUJINGJI, 1);
			Player:AddJoinRecord_MonthCount(pPlayer, Player.EVENT_JOIN_RECORD_JIAZUJINGJI, 1);
		end
		self.tbLeageName2PlayerList[tbGroup.szLeagueName] = tbGroup.tbPlayerList;
		self.tbMission:AddGroupName(tbPlayer[1], self.nGroupId, tbPlayer[1].szName);
		self.tbGroupId2LeageName[self.nGroupId] = tbPlayer[1].szName;
		self.nGroupId = self.nGroupId + 1;
		self.nGroupCount = self.nGroupCount + 1;
	end

end

function EPlatForm.CastleFight:JoinGame_Team(tbGroup, nCampId, tbJoinItem)
	self.tbLeageName2PlayerList[tbGroup.szLeagueName] = tbGroup.tbPlayerList;
	local tbPlayer = {};
	for _, nId in ipairs(tbGroup.tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer then
			table.insert(tbPlayer, pPlayer);
		end
	end
	
	if #tbPlayer > 0 then
		KTeam.CreateTeam(tbPlayer[1].nId);
		for i = 2, #tbPlayer do
			KTeam.ApplyJoinPlayerTeam(tbPlayer[1].nId, tbPlayer[i].nId);
		end
		
		for _, pPlayer in ipairs(tbPlayer) do
			local tbFind = {};
			-- 保证进来的时候只有一个龙舟
			for _, tbItemInfo in pairs(tbJoinItem) do
				if (tbItemInfo.tbItem) then
					tbFind = pPlayer.FindItemInBags(unpack(tbItemInfo.tbItem));
					if (tbFind and #tbFind > 0) then
						break;
					end
				end	
			end
		
			local pItem = tbFind[MathRandom(1,#tbFind)].pItem;
			self.tbMission.tbSkillList = self.tbMission.tbSkillList or {};
			self.tbMission.tbSkillList[pPlayer.nId] = pItem.dwId;
			self.tbMission.tbItemSkill = self.tbMission.tbItemSkill or {};
			self.tbMission.tbItemSkill[pPlayer.nId] = 0;
			
			if (pItem.nLevel == 2) then
				self.tbMission.tbItemSkill[pPlayer.nId] = 1;
			end
			
			self.tbMission:JoinPlayer(pPlayer, self.nGroupId);
			
			-- 记录参加家族竞技的次数
			Player:AddJoinRecord_DailyCount(pPlayer, Player.EVENT_JOIN_RECORD_JIAZUJINGJI, 1);
			Player:AddJoinRecord_MonthCount(pPlayer, Player.EVENT_JOIN_RECORD_JIAZUJINGJI, 1);
		end

		
		self.tbMission:AddGroupName(tbPlayer[1], self.nGroupId, tbGroup.szLeagueName);
		self.tbGroupId2LeageName[self.nGroupId] = tbGroup.szLeagueName;
		self.nGroupId = self.nGroupId + 1;
		self.nGroupCount = self.nGroupCount + 1;
	end	
end


function EPlatForm.CastleFight:JoinGame(tbGroup, nCampId, tbJoinItem)
	if (0 == nCampId) then
		self:JoinGame_Melee(tbGroup, nCampId, tbJoinItem);
	else
		self:JoinGame_Team(tbGroup, nCampId, tbJoinItem);
	end
end

function EPlatForm.CastleFight:CloseGame()
	self.tbMission:TerminateGame();
end

function EPlatForm.CastleFight:GetPlayerGroupId(pPlayer)
	if (not pPlayer) then
		return -1;
	end
	
	if (not self.tbMission) then
		return -1;
	end
	
	if (not self.tbMission.GetPlayerGroupId) then
		return -1;
	end
	return self.tbMission:GetPlayerGroupId(pPlayer);
end

function EPlatForm.CastleFight:KickPlayer(pPlayer)
	if (not pPlayer) then
		return -1;
	end
	
	if (not self.tbMission) then
		return -1;
	end
	
	if (not self.tbMission.KickPlayer) then
		return -1;
	end
	return self.tbMission:KickPlayer(pPlayer);
end

-- ?pl DoScript("\\script\\mission\\towerdefence\\towerdefence_mission_eplatform.lua")
