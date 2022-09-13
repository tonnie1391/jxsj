-- 武林联赛聊天

Require("\\script\\league\\league.lua");
Require("\\script\\globalserverbattle\\wldh\\battle\\wldh_battle_def.lua")

-- 添加玩家到战队中，
local tbChannelLeague 			= Wldh.tbChannelLeague or {};
Wldh.tbChannelLeague	= tbChannelLeague;

tbChannelLeague.nLGType		= League.LEAGUE_TYPE.LEAGUETYPE_WLDH_CHANNEL;

function tbChannelLeague:AddPlayer2League(nPlayerId) 

	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end;

	local pLGList 	= KLeague.GetLeagueSetObject(self.nLGType);
	-----------------------------------------------------------------
	--- 根据人物获取战队名
	local nTaskValue = pPlayer.GetTask(Transfer.tbServerTaskId[1], Transfer.tbServerTaskId[2]);
	local szMyLGName = "";
	if (nTaskValue and Wldh.Battle.tbLeagueName[nTaskValue] and Wldh.Battle.tbLeagueName[nTaskValue][1]) then
		szMyLGName	= Wldh.Battle.tbLeagueName[nTaskValue][1];
	end;
	
	szMyLGName = "团体赛战队【" .. szMyLGName .. "】";
	
	local szLeagueName	= League:GetMemberLeague(self.nLGType, pPlayer.szName);
	
	-- 过期的战队，先删除，再重新加
	if (szLeagueName and szMyLGName ~= szLeagueName) then
		KLeague.DelLeagueMember(self.nLGType, szLeagueName, pPlayer.szName);
	end;
	
	-----------------------------------------------------------------
	local pLG 	= pLGList.FindLeague(szMyLGName);
	if (not pLG) then
		League:AddLeague(self.nLGType, szMyLGName);
		League:AddMember(self.nLGType, szMyLGName, pPlayer.szName);
		return;
	end;

	if (not pLG.GetMember(pPlayer.szName)) then
		League:AddMember(self.nLGType, szMyLGName, pPlayer.szName);
	end;

	pPlayer.CallClientScript({"UpdateChatChanel"});
end;

function tbChannelLeague:DeleteAllLeague()
	local pLGList 	= KLeague.GetLeagueSetObject(self.nLGType);
	if (not pLGList) then
		return;
	end;
	
	local tbLeagueNameList = {};
	
	local pLeagueItor = pLGList.GetLeagueItor();
	local pLeague =  pLeagueItor.GetCurLeague();
	
	
	while(pLeague) do
		tbLeagueNameList[#tbLeagueNameList] = pLeague.szName;
		pLeague = pLeagueItor.NextLeague();
	end
	
	for _, szName in pairs(tbLeagueNameList) do
		League:DelLeague(self.nLGType, szName);
	end
end; 

function Wldh:DeleteChannelLeague()
	if not GLOBAL_AGENT then
		return 0;
	end
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if (nCurDate > 20091110 and nCurDate < 20091115) then
		Wldh.tbChannelLeague:DeleteAllLeague();
	end;
	if (nCurDate > 20091110 and nCurDate < 20091115) then
		Wldh.Battle:ClearLeague();
	end;
end;

function tbChannelLeague:SetCaptain(nCaptain, szLGName, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pLGList = KLeague.GetLeagueSetObject(self.nLGType);
	if (not pPlayer or not pLGList) then
		return false;
	end;
	
	local pLG 	= pLGList.FindLeague(szMyLGName);
	if (not pLG) then
		return false;
	end;
	
	return League:SetMemberTask(self.nLGType, szLGName, pPlayer.szName, nCaptain, 1);
end;

function tbChannelLeague:GetCaptain(nCaptain, szLGName)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pLGList) then
		return false;
	end;
	
	local pLG 	= pLGList.FindLeague(szMyLGName);
	if (not pLG) then
		return false;
	end;
	
	local pMemberItor = pLG.GetMemberItor();
	local pMember =  pMemberItor.GetCurMember();
	local szCaptainName = 0;
	while(pMember) do
		if (League:GetMemberTask(self.nLGType, szLGName, pMember, nCaptain) == 1) then
			szCaptainName = pMember.szName;
		end;
		pMember = pMemberItor.NextMember();
	end
	return szCaptainName;
end;