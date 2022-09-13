-- 文件名　：dragonboat_mission_newplatform.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-20 20:55:11
-- 功能    ：无差别竞技

NewEPlatForm.BoatFight = NewEPlatForm.BoatFight or {};

function NewEPlatForm.BoatFight:GetNewMission()
	return Lib:NewClass(NewEPlatForm.BoatFight);
end

-- nMatchType 表示活动类型是混战还是组队pvp
-- 若是混战那么就是2
-- 若是组队pvp就是3,4
function NewEPlatForm.BoatFight:OpenMission(tbEnterPos, tbLeavePos, nMatchType, nReadyId)
	self.tbMission = self.tbMission or Lib:NewClass(Esport.DragonBoatMission);
	self.tbMission:OpenMission(tbEnterPos[1], tbLeavePos, nMatchType);
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
	self.nMatchType = nMatchType;
	self.nReadyId = nReadyId or 0;
end

function NewEPlatForm.BoatFight:OnMissionEndPlay(pPlayer)
	local nRank = self.tbMission:GetCurRank(pPlayer);
	local tbAward = NewEPlatForm:CaleAward(nRank, pPlayer);
	if not tbAward then
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

function NewEPlatForm.BoatFight:OnMissionLevel()
	NewEPlatForm:OnLevel(self);
end

function NewEPlatForm.BoatFight:Continue()
	NewEPlatForm:Continue(self);
end

function NewEPlatForm.BoatFight:OnBackEnd()
	NewEPlatForm:OnBackEnd(self);
end

function NewEPlatForm.BoatFight:IsOpen()
	if (self.tbMission and self.tbMission.IsOpen) then
		return self.tbMission:IsOpen();
	end
	return 0;
end

function NewEPlatForm.BoatFight:StartGame()
	self.tbMission:OnStart();
end

--查找子表
function table.subfind(tbSrc, key, value)
	for _k, _v in pairs(tbSrc) do
		if _v[key] == value then
			return _k, _v;
		end
	end
	return nil;
end

function NewEPlatForm.BoatFight:OnMissionClose()	
	local tbRes = self.tbMission:GetResult();
	local tbScore = { 10,8,7,6,5,4,3,1 };
	if not tbRes then
		return;
	end

	local tbResFinal = {}; --[1]=szLeagueName tbPlayerList	
	for nPlace, tbInfo in ipairs(tbRes) do
		local tbPerson = {}; --单人赛，保存一个人的结果
		tbPerson.szLeagueName = tbInfo.szName;
		tbPerson.tbPlayerList = { tbInfo.szName };
		tbPerson.nDamage = tbScore[nPlace];
		table.insert(tbResFinal, tbPerson)
	end
	
	table.sort(tbResFinal, function (lhl, rhl)
		return lhl.nDamage > rhl.nDamage;
	end);

	self.__tbResFinal = tbResFinal;
	NewEPlatForm:SendResult(tbResFinal, self.nReadyId);
end

function NewEPlatForm.BoatFight:GetEnterPos()
	return self.tbEnterPos;
end

function NewEPlatForm.BoatFight:GetGroupCount()
	return self.nGroupCount or 0;
end

function NewEPlatForm.BoatFight:JoinGame(tbGroup, nCampId, tbJoinItem)
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
		end
		
		self.tbMission:AddGroupName(tbPlayer[1], self.nGroupId, tbPlayer[1].szName);
		self.tbGroupId2LeageName[self.nGroupId] = tbPlayer[1].szName;
		self.nGroupId = self.nGroupId + 1;
		self.nGroupCount = self.nGroupCount + 1;
	end
end

function NewEPlatForm.BoatFight:CloseGame()
	self.tbMission:OnGameOver();
end

function NewEPlatForm.BoatFight:GetPlayerGroupId(pPlayer)
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

function NewEPlatForm.BoatFight:KickPlayer(pPlayer)
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
