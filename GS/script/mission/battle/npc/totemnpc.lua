--龙柱npc

local tbTotem	= Npc:GetClass("songjin_totem_npc");

local tbEvent = 
{
	Player.ProcessBreakEvent.emEVENT_MOVE,
	Player.ProcessBreakEvent.emEVENT_ATTACK,
	Player.ProcessBreakEvent.emEVENT_ATTACKED,
	Player.ProcessBreakEvent.emEVENT_SITE,
	Player.ProcessBreakEvent.emEVENT_USEITEM,
	Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
	Player.ProcessBreakEvent.emEVENT_DROPITEM,
	Player.ProcessBreakEvent.emEVENT_SENDMAIL,
	Player.ProcessBreakEvent.emEVENT_TRADE,
	Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
	Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
	Player.ProcessBreakEvent.emEVENT_LOGOUT,
	Player.ProcessBreakEvent.emEVENT_DEATH,
};

function tbTotem:OnDialog(szCamp)
	local pPlayer = me;
	local pNpc = him;
	local tbBattleInfo = Battle:GetPlayerData(pPlayer);
	local tbData = pNpc.GetTempTable("Npc");
	local tbRule = tbBattleInfo.tbMission.tbRule;
	
	if pPlayer.nFightState == 0 then
		return;
	end
	
	-- 是同阵营的 and 不在转变中
	if (tbBattleInfo.tbCamp.nCampId == tbData.nCampId and 
		Battle.CAMPID_NEUTRAL == tbData.nChangingToCampId) then
		return;
	end
	
	-- 是不同阵营的 and  正在转变成同阵营
	if (tbBattleInfo.tbCamp.nCampId ~= tbData.nCampId and 
		tbBattleInfo.tbCamp.nCampId == tbData.nChangingToCampId) then
		return;
	end
	
	GeneralProcess:StartProcess("Đang mở...", tbRule.SEIZE_TOTEM_PROCESS_TIME * Env.GAME_FPS, 
			{self.BeginSeize, self, pNpc.dwId, pPlayer.nId}, nil, tbEvent);
end

function tbTotem:BeginSeize(dwNpcId, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pNpc = KNpc.GetById(dwNpcId);
	
	if (pPlayer == nil or pNpc == nil) then
		return;
	end
	
	local tbBattleInfo = Battle:GetPlayerData(pPlayer);
	local tbData = pNpc.GetTempTable("Npc");
	local tbRule = tbBattleInfo.tbMission.tbRule;
	local tbNpcPos = {pNpc.GetWorldPos()};
	
	-- 已经有同阵营的开了
	if (tbData.nChangingToCampId == tbBattleInfo.tbCamp.nCampId) then
		return;
	end
	
	-- 正在转变成对立阵营 and 之前是本阵营
	if (tbData.nChangingToCampId ~= tbBattleInfo.tbCamp.nCampId and 
		tbBattleInfo.tbCamp.nCampId == tbData.nCampId) then
		
		-- 立即变回本阵营
		local tbNewNpc = {};
		local tbNewData = {};
		tbNewNpc = KNpc.Add2(tbRule.TOTEM_ID[tbData.nCampId], 1, -1, tbNpcPos[1], tbNpcPos[2], tbNpcPos[3], 0);
		tbNewData = tbNewNpc.GetTempTable("Npc");
		
		tbNewData.nChangingToCampId = Battle.CAMPID_NEUTRAL;
		tbNewData.nCampId = tbBattleInfo.tbCamp.nCampId;
		tbNewData.nSeizePlayerId = nil;
		tbNewData.tbTimerList = {};
		tbRule.tbCamps[Battle.CAMPID_SONG]:PopNpcHighPoint(pNpc);
		tbRule.tbCamps[Battle.CAMPID_SONG]:PushNpcHighPoint(tbNewNpc, tbRule.MINIMAP_TOTEM[tbNewData.nCampId]);
		tbNewNpc.szName = tbRule.TOTEM_NAME[tbNewData.nCampId];
		tbNewNpc.SetTitle(tbRule.TOTEM_TITLE[tbNewData.nCampId]);
		if (tbData.tbTimerList) then
			for _,tbTimer in pairs(tbData.tbTimerList) do
				tbTimer:Close();
			end
		end
		tbData.tbTimerList = {};
		pNpc.Delete();
		
		tbRule.tbMission:BroadcastMsg(string.format("<color=yellow>%s<color>-%s <color=yellow>%s<color> chiếm giữ %s<enter>(<pos=%d,%d,%d>)",
						tbBattleInfo.tbCamp.szCampName, Battle.NAME_RANK[tbBattleInfo.nRank], pPlayer.szName, "Long trụ", tbNpcPos[1], tbNpcPos[2], tbNpcPos[3]));
		local tbAddPointTimer = tbRule.tbMission:CreateTimer(tbRule.CAMP_POINT_INTERVAL * Env.GAME_FPS,
											tbRule.OnTimer_AddCampPoint, tbRule, tbNewNpc.dwId);
		tbNewData.tbTimerList["tbAddPointTimer"] = tbAddPointTimer;
		return;
	end
	
	-- 正常开启
	if (tbData.nChangingToCampId ~= tbBattleInfo.tbCamp.nCampId and 
		tbBattleInfo.tbCamp.nCampId ~= tbData.nCampId) then
		
		local tbNewNpc = {};
		local tbNewData = {};
			
		tbNewNpc = KNpc.Add2(tbRule.TOTEM_ID[Battle.CAMPID_NEUTRAL], 1, -1, tbNpcPos[1], tbNpcPos[2], tbNpcPos[3], 0);
		tbNewData = tbNewNpc.GetTempTable("Npc");

		tbNewData.nChangingToCampId = tbBattleInfo.tbCamp.nCampId;
		tbNewData.nCampId = tbData.nCampId;
		tbNewData.nSeizePlayerId = pPlayer.nId;
		tbNewData.tbTimerList = {};
		
		tbRule.tbCamps[Battle.CAMPID_SONG]:PopNpcHighPoint(pNpc);
		tbRule.tbCamps[Battle.CAMPID_SONG]:PushNpcHighPoint(tbNewNpc, tbRule.MINIMAP_TOTEM[Battle.CAMPID_NEUTRAL]);
		tbNewNpc.szName = string.format("%s,%s,%s",tbRule.TOTEM_NAME[tbNewData.nCampId], tbRule.tbCamps[tbNewData.nChangingToCampId].szCampName, "Đang tranh đoạt");
		tbNewNpc.SetTitle(tbRule.TOTEM_TITLE[tbNewData.nCampId]);
		if (tbData.tbTimerList) then
			for _,tbTimer in pairs(tbData.tbTimerList) do
				tbTimer:Close();
			end
		end
		tbData.tbTimerList = {};
		pNpc.Delete();
		
		tbRule.tbMission:BroadcastMsg(string.format("<color=yellow>%s<color>-%s <color=yellow>%s<color> đột kích %s<enter>(<pos=%d,%d,%d>), <color=green>%d<color> sẽ bị <color=yellow>%s<color> chiếm sau vài giây.",
				tbBattleInfo.tbCamp.szCampName, Battle.NAME_RANK[tbBattleInfo.nRank], pPlayer.szName, "Long trụ", tbNpcPos[1], tbNpcPos[2], tbNpcPos[3], tbRule.SEIZE_TOTEM_WAIT_TIME, tbBattleInfo.tbCamp.szCampName));

		local tbSeizeTimer = tbRule.tbMission:CreateTimer(tbRule.SEIZE_TOTEM_WAIT_TIME * Env.GAME_FPS,
											tbRule.OnTimer_WaitSeizeEnd, tbRule, tbNewNpc.dwId, pPlayer.nId);
		tbNewData.tbTimerList["tbSeizeTimer"] = tbSeizeTimer;
		return;
	end
end
