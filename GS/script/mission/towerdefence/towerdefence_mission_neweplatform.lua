-- 文件名　：towerdefence_mission_neweplatform.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-20 20:55:17
-- 功能    ：无差别竞技

NewEPlatForm.TowerDefence = NewEPlatForm.TowerDefence or {};

function NewEPlatForm.TowerDefence:GetNewMission()
	return Lib:NewClass(NewEPlatForm.TowerDefence);
end

-- nMatchType 表示活动类型是混战还是组队pvp
-- 若是混战那么就是2
-- 若是组队pvp就是3,4
function NewEPlatForm.TowerDefence:OpenMission(tbEnterPos, tbLeavePos, nMatchType, nReadyId)
	self.tbMission = self.tbMission or Lib:NewClass(TowerDefence.Mission);
	self.tbMission:__open(tbEnterPos[1], tbLeavePos, nMatchType);
	self.tbMission.tbCallbackOnClose = {self.OnMissionClose, self};
	self.tbMission.tbCallbackEndPlay = {self.OnMissionEndPlay, self};
	self.tbMission.tbOnLevelMision = {self.OnMissionLevel, self};
	self.tbEnterPos = tbEnterPos;
	self.nTaskId = nTaskId;
	self.tbTeamId = {};
	self.tbGroupId2LeageName = {};
	self.tbLeageName2PlayerList = {};
	self.nGroupCount = 0;
	self.nGroupId = 0;
	self.nReadyId = nReadyId or 0;
end

function NewEPlatForm.TowerDefence:OnMissionEndPlay(pPlayer)
	local nRank = self.tbMission:GetCurRank(pPlayer);
	local tbAward = NewEPlatForm:CaleAward(nRank, pPlayer);
	if not tbAward then
		self:KickPlayer(pPlayer);
		return;
	end
	local tbCallBack = {
		["tbBackEnd"] 		= {self.OnBackEnd, self},
		["tbHandUp"] 		= {NewEPlatForm.OnHandUp, NewEPlatForm},
		["tbOpenOneCard"] 	= {NewEPlatForm.OpenOneCard, NewEPlatForm},
	};
	if TimeFrame:GetState("OpenLevel89") == 1 then
		tbCallBack.tbContinue = {self.Continue, self};
	end
	Setting:SetGlobalObj(pPlayer);
	me.CallClientScript({"UiManager:OpenWindow", "UI_KINGAMESCREEN", 60, NewEPlatForm.szScreenMsg});
	CardAward:SendAskAward(NewEPlatForm.szUITitle, NewEPlatForm.tbMsg[1], tbAward, nil, nil, tbCallBack, 0, 1, 1, 1);
	Setting:RestoreGlobalObj();
end

function NewEPlatForm.TowerDefence:OnMissionLevel()
	NewEPlatForm:OnLevel(self);
end

function NewEPlatForm.TowerDefence:Continue()
	NewEPlatForm:Continue(self);
end

function NewEPlatForm.TowerDefence:OnBackEnd()
	NewEPlatForm:OnBackEnd(self);
end

function NewEPlatForm.TowerDefence:IsOpen()
	if (self.tbMission and self.tbMission.IsOpen) then
		return self.tbMission:IsOpen();
	end
	return 0;
end

function NewEPlatForm.TowerDefence:StartGame()
	self.tbMission:__start();
end

function NewEPlatForm.TowerDefence:OnMissionClose()
	local tbRes = self.tbMission:GetResult();
	if not tbRes then
		return;
	end
	local tbResFinal = {};
	for _, tbInfo in ipairs(tbRes) do
		local tbGroup = {};
		tbGroup.szLeagueName = tbInfo[1];
		local pPlayer = KPlayer.GetPlayerByName(tbInfo[1]);
		if self.tbMission:GetPlayerGroupId(pPlayer) > 0 then
			tbGroup.tbPlayerList = {pPlayer.nId};
			if (tbGroup.szLeagueName and tbGroup.tbPlayerList) then
				tbGroup.nDamage		 = tbInfo[2];
				table.insert(tbResFinal, tbGroup)
			end
		else
			tbGroup.tbPlayerList = {0};
			tbGroup.nDamage	 = 0;
			table.insert(tbResFinal, tbGroup)
		end
	end
	
	self.__tbResFinal = tbResFinal;
	NewEPlatForm:SendResult(tbResFinal, self.nReadyId);
end

function NewEPlatForm.TowerDefence:GetEnterPos()
	return self.tbEnterPos;
end

function NewEPlatForm.TowerDefence:GetGroupCount()
	return self.nGroupCount or 0;
end

function NewEPlatForm.TowerDefence:JoinGame(tbGroup, nCampId, tbJoinItem, nGamePlayerMin)
	local bFirst = 0;
	if not self.tbLeageName2PlayerList[tbGroup.szLeagueName]  then
		self.tbLeageName2PlayerList[tbGroup.szLeagueName] = tbGroup.tbPlayerList;
		self.nGroupId = self.nGroupId + 1;
		self.tbGroupId2LeageName[self.nGroupId] = tbGroup.szLeagueName;
		self.nGroupCount = self.nGroupCount + 1;
		bFirst = 1;
	else
		for _, nPlayerId in ipairs(tbGroup.tbPlayerList) do
			table.insert(self.tbLeageName2PlayerList[tbGroup.szLeagueName], nPlayerId);
		end
	end
	
	--这里默认只有四个人才能开启
	local pPlayer = KPlayer.GetPlayerObjById(tbGroup.tbPlayerList[1]);
	if pPlayer then
		if bFirst == 1 then
			KTeam.CreateTeam(self.tbLeageName2PlayerList[tbGroup.szLeagueName][1]);
		else
			KTeam.ApplyJoinPlayerTeam(self.tbLeageName2PlayerList[tbGroup.szLeagueName][1], tbGroup.tbPlayerList[1]);
		end
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
		self.tbMission:AddGroupName(pPlayer.nId, self.nGroupId, tbGroup.szLeagueName);
	end
end

function NewEPlatForm.TowerDefence:CloseGame()
	self.tbMission:Close();
end

function NewEPlatForm.TowerDefence:GetPlayerGroupId(pPlayer)
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

function NewEPlatForm.TowerDefence:KickPlayer(pPlayer)
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

-- ?pl DoScript("\\script\\mission\\towerdefence\\towerdefence_mission_NewEPlatForm.lua")
