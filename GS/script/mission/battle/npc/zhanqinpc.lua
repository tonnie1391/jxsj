-----------------------------------------------------
--文件名		：	zhanqinpc.lua
--创建者		：	zhouchenfei
--创建时间		：	2008-01-09
--功能描述		：	战旗npc
------------------------------------------------------

local tbZhanQi	= Npc:GetClass("zhanqinpc");

function tbZhanQi:OnDialog(szCamp)
	local pPlayer		= me;
	local nCampId		= Battle.tbNPCNAMETOID[szCamp];
	local tbBattleInfo	= Battle:GetPlayerData(pPlayer);
	if pPlayer.nFightState == 0 then
		return;
	end
	-- 已经有旗了就不可能再拿旗了
	if (1 == tbBattleInfo.bHaveFlag) then
		return;
	end
	-- 防止敌方玩家获得本方战旗
	if (nCampId ~= tbBattleInfo.tbCamp.nCampId) then
		return;
	end
	
	if (0 ~= tbBattleInfo.tbCamp.nPlayerIsFlag) then
		Battle:DbgOut("tbZhanQi:OnDialog", "Đã có người lấy cờ trước");
		return;
	end
	
	self:GiveTheFlagToPlayer(nCampId, tbBattleInfo);
	him.Delete();
end

function tbZhanQi:GiveTheFlagToPlayer(nCampId, tbBattleInfo)
	local tbFlagDesPos	= tbBattleInfo:GetFlagDesPos();
	tbBattleInfo.pPlayer.Msg(string.format("Bạn phải hộ tống Chiến Kỳ đến (%d, %d)", tbFlagDesPos[2] / 8, tbFlagDesPos[3] / 16));
	local nWorldId, nPosX, nPosY 		= tbBattleInfo.pPlayer.GetWorldPos();
	tbBattleInfo.tbCamp.nPlayerIsFlag	= tbBattleInfo.pPlayer.nId;
	tbBattleInfo.bHaveFlag				= 1;
	tbBattleInfo.tbCamp:PushNpcHighPoint(tbBattleInfo.pPlayer.GetNpc(), tbBattleInfo.tbMission.tbRule.MINIMAP_FLAG[nCampId]);	

	tbBattleInfo.tbMission.tbRule:ChangePlayerState(tbBattleInfo.pPlayer);

	tbBattleInfo.pPlayer.SetHide(0);
	tbBattleInfo.pPlayer.SetAForbitSkill(Battle.SKILL_FORBID_ID, 1);
	
	local szFirMsg	= string.format("<color=red>%s<color>-%s <color=green>%s<color> hộ tống Chiến Kỳ tiến về (%d, %d)", Battle.NAME_CAMP[tbBattleInfo.tbCamp.nCampId], Battle.NAME_RANK[tbBattleInfo.nRank], tbBattleInfo.pPlayer.szName, tbFlagDesPos[2] / 8, tbFlagDesPos[3] / 16);	
	local szSecMsg	= string.format("Lúc này <color=green>%s<color> đang ở (%d, %d)", tbBattleInfo.pPlayer.szName, nPosX / 8, nPosY / 16);
	tbBattleInfo.tbMission:BroadcastMsg(szFirMsg);
	tbBattleInfo.tbMission:BroadcastMsg(szSecMsg);
	tbBattleInfo.pPlayer.Msg("Trong quá trình Hộ kỳ chỉ có thể sử dụng <color=yellow>Hộ Kỳ Khinh Công<color>, không thể sử dụng kỹ năng khác.");
	local tbPlayerList	= tbBattleInfo.tbMission:GetPlayerList();
	for _, pPlayer in pairs(tbPlayerList) do
		Dialog:SendInfoBoardMsg(pPlayer, szFirMsg);
		Dialog:SendInfoBoardMsg(pPlayer, szSecMsg);
	end
	tbBattleInfo.tbCamp.tbSrcFlagPos	= nil;
end
