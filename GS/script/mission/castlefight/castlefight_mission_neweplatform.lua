-- 文件名　：castlefight_mission_neweplatform.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-20 20:55:07
-- 功能    ：无差别竞技

NewEPlatForm.CastleFight = NewEPlatForm.CastleFight or {};

function NewEPlatForm.CastleFight:GetNewMission()
	return Lib:NewClass(NewEPlatForm.CastleFight);	
end

-- nMatchType 表示活动类型是混战还是组队pvp
-- 若是混战那么就是2
-- 若是组队pvp就是3,4
function NewEPlatForm.CastleFight:OpenMission(tbEnterPos, tbLeavePos, nMatchType, nReadyId)
	self.tbMission = self.tbMission or Lib:NewClass(CastleFight.Mission);
	self.tbMission:Init(tbEnterPos, tbLeavePos, nMatchType);
	self.tbMission.tbCallbackOnClose = {self.OnMissionClose, self};
	self.tbMission.tbCallbackEndPlay = {self.OnMissionEndPlay, self};
	self.tbMission.tbOnLevelMision = {self.OnMissionLevel, self};
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
	self.nGroupId = 0;
	self.nReadyId = nReadyId or 0;
	self.nMatchType = nMatchType;
end

function NewEPlatForm.CastleFight:OnMissionEndPlay(pPlayer)
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

function NewEPlatForm.CastleFight:OnMissionLevel()
	NewEPlatForm:OnLevel(self);
end

function NewEPlatForm.CastleFight:Continue()
	NewEPlatForm:Continue(self);
end

function NewEPlatForm.CastleFight:OnBackEnd()
	NewEPlatForm:OnBackEnd(self);
end

function NewEPlatForm.CastleFight:IsOpen()
	if (self.tbMission and self.tbMission.IsOpen) then
		return self.tbMission:IsOpen();
	end
	return 0;
end

function NewEPlatForm.CastleFight:StartGame()
	self.tbMission:__start();
end

function NewEPlatForm.CastleFight:OnMissionClose()
	local tbRes = self.tbMission:GetResult();
	if not tbRes then
		return;
	end
	local tbResFinal = {};
	for _, tbInfo in ipairs(tbRes) do
		local tbGroup = {};
		local pPlayer = KPlayer.GetPlayerObjById(tbInfo[1]);
		if pPlayer then
			tbGroup.szLeagueName = pPlayer.szName;
		else
			tbGroup.szLeagueName = "";
		end
		if self.tbMission:GetPlayerGroupId(pPlayer) > 0 then
			tbGroup.tbPlayerList = {tbInfo[1]};
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

function NewEPlatForm.CastleFight:GetEnterPos()
	return self.tbEnterPos;
end

function NewEPlatForm.CastleFight:GetGroupCount()
	return self.nGroupCount or 0;
end

function NewEPlatForm.CastleFight:JoinGame_Melee(tbGroup, nTypeId, tbJoinItem, nGamePlayerMin)
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
	
	local nTeamNumA = #self.tbTeam_Step1[1];
	local nCampId = 0;
	local nNeedCeateTeam = 0;
	local pPlayer = KPlayer.GetPlayerObjById(tbGroup.tbPlayerList[1]);
	if pPlayer then
		local tbTeam_Step = self.tbTeam_Step1[1];
		if nTeamNumA < nGamePlayerMin then
			nCampId = 1;
		else
			nCampId = 2;
			tbTeam_Step = self.tbTeam_Step1[2];
		end
		table.insert(tbTeam_Step, tbGroup.tbPlayerList[1]);
		if bFirst == 1 then
			KTeam.CreateTeam(self.tbLeageName2PlayerList[tbGroup.szLeagueName][1]);
		else
			KTeam.ApplyJoinPlayerTeam(self.tbLeageName2PlayerList[tbGroup.szLeagueName][1], tbGroup.tbPlayerList[1]);
		end
		local tbFind = nil;
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
		if (pItem.nLevel == 4) then
			self.tbMission.tbItemSkill[pPlayer.nId] = 1;
		end

		self.tbMission:JoinPlayer(pPlayer, nCampId);
		self.tbMission:AddGroupName(pPlayer.nId, self.nGroupId, pPlayer.szName);
	end
end

function NewEPlatForm.CastleFight:JoinGame_Team(tbGroup, nCampId, tbJoinItem)
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
			
			if (pItem.nLevel == 4) then
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


function NewEPlatForm.CastleFight:JoinGame(tbGroup, nCampId, tbJoinItem, nGamePlayerMin)
	if (0 == nCampId) then
		self:JoinGame_Melee(tbGroup, nCampId, tbJoinItem, nGamePlayerMin);
	else
		self:JoinGame_Team(tbGroup, nCampId, tbJoinItem);
	end
end

function NewEPlatForm.CastleFight:CloseGame()
	self.tbMission:TerminateGame();
end

function NewEPlatForm.CastleFight:GetPlayerGroupId(pPlayer)
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

function NewEPlatForm.CastleFight:KickPlayer(pPlayer)
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
