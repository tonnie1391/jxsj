EPlatForm.TowerDefence = EPlatForm.TowerDefence or {};

function EPlatForm.TowerDefence:GetNewMission()
	return Lib:NewClass(EPlatForm.TowerDefence);	
end

-- nMatchType 表示活动类型是混战还是组队pvp
-- 若是混战那么就是2
-- 若是组队pvp就是3,4
function EPlatForm.TowerDefence:OpenMission(tbEnterPos, tbLeavePos, nMatchType, nReadyId)
	self.tbMission = self.tbMission or Lib:NewClass(TowerDefence.Mission);
	self.tbMission:__open(tbEnterPos[1], tbLeavePos, nMatchType);
	self.tbMission.tbCallbackOnClose = {self.OnMissionClose, self};
	self.tbEnterPos = tbEnterPos;
	self.nTaskId = nTaskId;
	self.tbTeamId = {};
	self.tbGroupId2LeageName = {};
	self.tbLeageName2PlayerList = {};
	self.nGroupCount = 0;
	self.nGroupId = 1;
	self.nReadyId = nReadyId or 0;
end

function EPlatForm.TowerDefence:IsOpen()
	if (self.tbMission and self.tbMission.IsOpen) then
		return self.tbMission:IsOpen();
	end
	return 0;
end

function EPlatForm.TowerDefence:StartGame()
	self.tbMission:__start();
end

function EPlatForm.TowerDefence:OnMissionClose()
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

function EPlatForm.TowerDefence:GetEnterPos()
	return self.tbEnterPos;
end

function EPlatForm.TowerDefence:GetGroupCount()
	return self.nGroupCount or 0;
end

function EPlatForm.TowerDefence:JoinGame(tbGroup, nCampId, tbJoinItem)
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

function EPlatForm.TowerDefence:CloseGame()
	self.tbMission:Close();
end

function EPlatForm.TowerDefence:GetPlayerGroupId(pPlayer)
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

function EPlatForm.TowerDefence:KickPlayer(pPlayer)
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
