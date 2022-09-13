-- 文件名　：esport_mission_neweplatform.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-20 20:55:00
-- 功能    ：无差别竞技

NewEPlatForm.SnowFight = NewEPlatForm.SnowFight or {};

function NewEPlatForm.SnowFight:GetNewMission()
	return Lib:NewClass(NewEPlatForm.SnowFight);	
end

-- nMatchType 表示活动类型是混战还是组队pvp
-- 若是混战那么就是2
-- 若是组队pvp就是3,4
function NewEPlatForm.SnowFight:OpenMission(tbEnterPos, tbLeavePos, nMatchType, nReadyId)
	self.tbMission = self.tbMission or Lib:NewClass(Esport.Mission);
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
	self.nGroupId = 1;
	self.nReadyId = nReadyId or 0;
end

function NewEPlatForm.SnowFight:OnMissionEndPlay(pPlayer)
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

function NewEPlatForm.SnowFight:OnMissionLevel()
	NewEPlatForm:OnLevel(self);
end

function NewEPlatForm.SnowFight:Continue()
	NewEPlatForm:Continue(self);
end

function NewEPlatForm.SnowFight:OnBackEnd()
	NewEPlatForm:OnBackEnd(self);
end

function NewEPlatForm.SnowFight:IsOpen()
	if (self.tbMission and self.tbMission.IsOpen) then
		return self.tbMission:IsOpen();
	end
	return 0;
end

function NewEPlatForm.SnowFight:StartGame()
	self.tbMission:__start();
end

function NewEPlatForm.SnowFight:OnMissionClose()
	local tbRes = self.tbMission:GetResult();
	if not tbRes then
		return;
	end
	local tbResFinal = {};
	for _, tbInfo in ipairs(tbRes) do
		local pPlayer = KPlayer.GetPlayerByName(self.tbGroupId2LeageName[tbInfo[1]]);
		local tbGroup = {};
		tbGroup.szLeagueName = self.tbGroupId2LeageName[tbInfo[1]];
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

function NewEPlatForm.SnowFight:GetEnterPos()
	return self.tbEnterPos;
end

function NewEPlatForm.SnowFight:GetGroupCount()
	return self.nGroupCount or 0;
end

function NewEPlatForm.SnowFight:JoinGame(tbGroup, nCampId)
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
		
		for _, pPlayer in ipairs(tbPlayer) do
			self.tbMission:JoinPlayer(pPlayer, self.nGroupId);			
		end
		
		self.tbMission:AddGroupName(tbPlayer[1], self.nGroupId, tbPlayer[1].szName);
		self.tbGroupId2LeageName[self.nGroupId] = tbPlayer[1].szName;
		self.nGroupId = self.nGroupId + 1;
		self.nGroupCount = self.nGroupCount + 1;
	end
end

function NewEPlatForm.SnowFight:CloseGame()
	self.tbMission:Close();
end

function NewEPlatForm.SnowFight:GetPlayerGroupId(pPlayer)
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

function NewEPlatForm.SnowFight:KickPlayer(pPlayer)
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

-- ?pl DoScript("\\script\\mission\\esport\\esport_mission_NewEPlatForm.lua")
