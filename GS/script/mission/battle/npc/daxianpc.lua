

local tbDaXia	= Npc:GetClass("daxianpc");

function tbDaXia:OnDialog(szCamp)
	local nCampId		= Battle.tbNPCNAMETOID[szCamp];
	local tbBattleInfo	= Battle:GetPlayerData(me);
	if me.nFightState == 0 then
		return;
	end
	-- 已经有旗了就不可能再拿旗了
	if (1 == tbBattleInfo.bHaveNpc) then
		return;
	end
	-- 防止敌方玩家获得本方战旗
	if (nCampId ~= tbBattleInfo.tbCamp.nCampId) then
		return;
	end
	
	if (0 ~= tbBattleInfo.tbCamp.nPlayerIsNpc) then
		Battle:DbgOut("tbZhanQi:OnDialog", "已经有人先拿了npc");
		return;
	end

	self:OnGetPlayerNpc(tbBattleInfo, nCampId);
	
	him.Delete();
end

function tbDaXia:OnGetPlayerNpc(tbBattleInfo, nCampId)
	tbBattleInfo.tbMission.tbCamps[nCampId].nGetPlayerNpcTime = GetTime();
	tbBattleInfo.tbMission.tbCamps[nCampId].nPlayerIsNpc = tbBattleInfo.pPlayer.nId;
	tbBattleInfo.tbMission.tbCamps[nCampId].nAddPlayerNpcTime = nil;
	tbBattleInfo.tbMission.tbCamps[nCampId].nAddPlayerNpcId	= nil;
	tbBattleInfo.bHaveNpc = 1;
	tbBattleInfo.tbCamp:PushNpcHighPoint(tbBattleInfo.pPlayer.GetNpc(), tbBattleInfo.tbMission.tbRule.MINIMAP_FLAG[nCampId]);	
	tbBattleInfo.tbMission.tbRule:ChangePlayerState(tbBattleInfo.pPlayer);

	tbBattleInfo.pPlayer.SetHide(0);
	local szFirMsg	= string.format("<color=red>%s<color>-%s <color=green>%s<color> đã trở thành Chiến Thần! Binh sĩ <color=red>%s<color> hãy theo yểm trợ!", Battle.NAME_CAMP[tbBattleInfo.tbCamp.nCampId], Battle.NAME_RANK[tbBattleInfo.nRank], tbBattleInfo.pPlayer.szName, Battle.NAME_CAMP[tbBattleInfo.tbCamp.nCampId]);	
	
	tbBattleInfo.tbMission:BroadcastMsg(szFirMsg);
	
	tbBattleInfo.tbMission.tbCamps[nCampId].tbSrcFlagPos	= nil;
	tbBattleInfo.tbCamp:PopNpcHighPoint(him);
	Dbg:WriteLogEx(Dbg.LOG_INFO, "BattleLog", "GetDaXiaNpc", tbBattleInfo.pPlayer.szName, tbBattleInfo.pPlayer.nLevel, Player:GetFactionRouteName(tbBattleInfo.pPlayer.nFaction, tbBattleInfo.pPlayer.nRouteId));
end
