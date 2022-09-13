-------------------------------------------------------
-- 文件名　：keyimen_boss.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2012-02-22 11:31:58
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\boss\\keyimen\\keyimen_def.lua");

-- 大boss
local tbBoss = Npc:GetClass("keyimen_npc_boss");
function tbBoss:OnDeath(pNpcKiller)
	
	-- 清记录
	Keyimen.tbActiveList[him.nTemplateId] = nil;
	
	-- 掉落表
	local tbDropItem = him.GetLoseItemInfo();
	
	local tbList = {};
	for _, tbInfo in pairs(tbDropItem) do
		local pItem = KItem.GetObjById(tbInfo.nItemIdx);
		if pItem then
			local pPlayer = KPlayer.GetPlayerObjById(tbInfo.nPlayerId);
			local szKeyName = pPlayer and pPlayer.szName or "-Không ai nhặt-";
			if not tbList[szKeyName] then
				tbList[szKeyName] = {};
			end
			if not tbList[szKeyName][pItem.szName] then
				tbList[szKeyName][pItem.szName] = 1;
			else
				tbList[szKeyName][pItem.szName] = tbList[szKeyName][pItem.szName] + 1;
			end
		end
	end
	
	-- 家族id
	local nKinId = him.GetKillerKinId();
	local pKin = KKin.GetKin(nKinId);
	local szKinName = pKin and pKin.GetName() or "-Không biết-";
	
	-- 频道广播
	local szMsg = string.format("Gia tộc <color=cyan>[%s]<color> hạ Thống Soái <color=yellow>%s<color> ở Khắc Di Môn!", szKinName, him.szName);
	Keyimen:BroadCast(Keyimen.MSG_TOP, szMsg);
	Keyimen:BroadCast(Keyimen.MSG_BOTTOM, szMsg);
	Keyimen:BroadCast(Keyimen.MSG_GLOBAL, szMsg);
	KKin.Msg2Kin(nKinId, szMsg, 0);
	
	-- 掉落信息
	for szPlayerName, tbItemInfo in pairs(tbList) do
		local szTmpMsg = "";
		if szPlayerName ~= "-Không ai nhặt-" then
			szTmpMsg = string.format("<color=cyan>%s<color> Thu được vật phẩm: ", szPlayerName);
		else
			szTmpMsg = string.format("<color=green>Vật phẩm rơi gồm: <color>");
		end
		for szItemName, nCount in pairs(tbItemInfo) do
			szTmpMsg = szTmpMsg .. string.format("\n<color=yellow>%s - %s cái<color>", szItemName, nCount);
		end
		Keyimen:BroadCast(Keyimen.MSG_CHANNEL, szTmpMsg);
	end
	
	-- stat log
	StatLog:WriteStatLog("stat_info", "keyimen_battle", "kill_boss", 0, him.nTemplateId, szKinName, him.nMapId);
	
	local tbLog = {};
	for _, tbInfo in pairs(tbDropItem) do
		local pItem = KItem.GetObjById(tbInfo.nItemIdx);
		if pItem then
			local szName = string.format("%d_%d_%d_%d", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
			if not tbLog[szName] then
				tbLog[szName] = 1;
			else
				tbLog[szName] = tbLog[szName] + 1;
			end
		end
	end
	
	for szName, nCount in pairs(tbLog) do
		StatLog:WriteStatLog("stat_info", "keyimen_battle", "chip_output", 0, him.nTemplateId, szKinName, szName, nCount);
	end
	
	-- 回调系统
	Keyimen:OnBossDeath(him.dwId);
end

-- 血量触发
function tbBoss:OnLifePercentReduceHere(nLifePercent)
	
	local tbInfo = Keyimen.tbBossList[him.dwId];
	if not tbInfo then
		return 0;
	end
	
	for i, tbPercent in ipairs(Keyimen.BOSS_STEP) do
		if nLifePercent == tbPercent[1] and tbInfo.nStep == i then
			-- 说话
			local szMsg = string.format("%s: %s", him.szName, tbPercent[2]);
			Keyimen:BroadCast(Keyimen.MSG_CHANNEL, szMsg);
			Keyimen:BroadCast(Keyimen.MSG_BOTTOM, szMsg);
			-- 刷小怪
			local nMapId, nMapX, nMapY = him.GetWorldPos();
			local nServantId = Keyimen.NPC_SERVANT_LIST[tbInfo.nCamp];
			local tbOffset = {{-8, 0}, {8, 0}, {0, -8}, {0, 8}};
			for i = 1, #tbOffset do
				local pNpc = KNpc.Add2(nServantId, Keyimen.NPC_LEVEL, -1, nMapId, nMapX + tbOffset[i][1], nMapY + tbOffset[i][2]);
				if pNpc then
					Keyimen:OnAddServant(him.dwId, pNpc.dwId);
				end
			end
			-- 下阶段
			tbInfo.nStep = tbInfo.nStep + 1;
			him.AddSkillState(2718, 20, 1, Env.GAME_FPS * 60);
		end
	end
	
	if nLifePercent == 20 then
		-- 说话
		local szMsg = string.format("%s: Phệ Hồn Kiếm mau bày trận...", him.szName);
		Keyimen:BroadCast(Keyimen.MSG_CHANNEL, szMsg);
		-- 刷小怪
		local nMapId, nMapX, nMapY = him.GetWorldPos();
		local nPoleId = Keyimen.NPC_POLE_LIST[tbInfo.nCamp];
		local tbOffset = {{-8, -10}, {-8, 10}, {8, -10}, {8, 10}};
		for i = 1, #tbOffset do
			local pNpc = KNpc.Add2(nPoleId, Keyimen.NPC_LEVEL, -1, nMapId, nMapX + tbOffset[i][1], nMapY + tbOffset[i][2]);
			if pNpc then
				Keyimen:OnAddServant(him.dwId, pNpc.dwId);	
			end
		end
		-- 去掉小boss
		-- GCExcute({"Keyimen:UpdateGuard_GC", tbInfo.nCamp});
	end
end

-- 小boss
local tbGuard = Npc:GetClass("keyimen_npc_guard");
function tbGuard:OnDeath(pNpcKiller)
	
	-- 清记录
	Keyimen.tbActiveList[him.nTemplateId] = nil;
	
	-- 掉落表
	local tbDropItem = him.GetLoseItemInfo();
	
	local tbList = {};
	for _, tbInfo in pairs(tbDropItem) do
		local pItem = KItem.GetObjById(tbInfo.nItemIdx);
		if pItem then
			local pPlayer = KPlayer.GetPlayerObjById(tbInfo.nPlayerId);
			local szKeyName = pPlayer and pPlayer.szName or "-Không ai nhặt-";
			if not tbList[szKeyName] then
				tbList[szKeyName] = {};
			end
			if not tbList[szKeyName][pItem.szName] then
				tbList[szKeyName][pItem.szName] = 1;
			else
				tbList[szKeyName][pItem.szName] = tbList[szKeyName][pItem.szName] + 1;
			end
		end
	end
	
	-- 家族id
	local nKinId = him.GetKillerKinId();
	local pKin = KKin.GetKin(nKinId);
	local szKinName = pKin and pKin.GetName() or "-Không biết-";
	
	-- 频道广播
	local szMsg = string.format("Gia tộc <color=cyan>[%s]<color> hạ Tướng Quân <color=yellow>%s<color> ở Khắc Di Môn!", szKinName, him.szName);
	Keyimen:BroadCast(Keyimen.MSG_GLOBAL, szMsg);
	KKin.Msg2Kin(nKinId, szMsg, 0);
	
	-- 掉落信息
	for szPlayerName, tbItemInfo in pairs(tbList) do
		local szTmpMsg = "";
		if szPlayerName ~= "-Không ai nhặt-" then
			szTmpMsg = string.format("<color=cyan>%s<color> Thu được vật phẩm: ", szPlayerName);
		else
			szTmpMsg = string.format("<color=green>Vật phẩm rơi gồm: <color>");
		end
		for szItemName, nCount in pairs(tbItemInfo) do
			szTmpMsg = szTmpMsg .. string.format("\n<color=yellow>%s - %s cái<color>", szItemName, nCount);
		end
		Keyimen:BroadCast(Keyimen.MSG_CHANNEL, szTmpMsg);
	end
	
	-- stat log
	StatLog:WriteStatLog("stat_info", "keyimen_battle", "kill_boss", 0, him.nTemplateId, szKinName, him.nMapId);
	
	local tbLog = {};
	for _, tbInfo in pairs(tbDropItem) do
		local pItem = KItem.GetObjById(tbInfo.nItemIdx);
		if pItem then
			local szName = string.format("%d_%d_%d_%d", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
			if not tbLog[szName] then
				tbLog[szName] = 1;
			else
				tbLog[szName] = tbLog[szName] + 1;
			end
		end
	end
	
	for szName, nCount in pairs(tbLog) do
		StatLog:WriteStatLog("stat_info", "keyimen_battle", "chip_output", 0, him.nTemplateId, szKinName, szName, nCount);
	end
	
	-- 回调系统
	Keyimen:OnBossDeath(him.dwId);
end

-- 随机boss
local tbMonster = Npc:GetClass("keyimen_npc_monster");
function tbMonster:OnDeath(pNpcKiller)
	
	Keyimen.tbActiveList[him.nTemplateId] = nil;
	Keyimen:BroadCast(Keyimen.MSG_CHANNEL, string.format("[<color=yellow>%s<color>] đã bị tiêu diệt!", him.szName));
	
	local pPlayer = pNpcKiller.GetPlayer();
	if not pPlayer then
		return 0;
	end
	
	local tbPlayerName = {};
	if pPlayer.nTeamId ~= 0 then
		local tbPlayerId, nMemberCount = KTeam.GetTeamMemberList(pPlayer.nTeamId);
		for i, nPlayerId in pairs(tbPlayerId) do
			local pTeamPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if (pTeamPlayer and pTeamPlayer.nMapId == him.nMapId and nPlayerId ~= pPlayer.nId) then
				table.insert(tbPlayerName, pTeamPlayer.szName);
			end
		end
	end
	
	StatLog:WriteStatLog("stat_info", "keyimen_battle", "kill_boss_2", pPlayer.nId, unpack(tbPlayerName));
end

-- 掉落表
function tbMonster:DeathLoseItem(tbLoseItem)
	local tbLog = {};
	for _, nItemId in pairs(tbLoseItem.Item) do
		local pItem = KItem.GetObjById(nItemId);
		if pItem then
			local szName = string.format("%d_%d_%d_%d", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
			if not tbLog[szName] then
				tbLog[szName] = 1;
			else
				tbLog[szName] = tbLog[szName] + 1;
			end
		end
	end
	
	for szName, nCount in pairs(tbLog) do
		StatLog:WriteStatLog("stat_info", "keyimen_battle", "chip_output", 0, him.nTemplateId, 0, szName, nCount);
	end
end

-- 护卫
local tbServant = Npc:GetClass("keyimen_npc_servant");
function tbServant:OnDeath(pNpcKiller)
	--
end

-- 幽玄龙珠
local tbDragon = Npc:GetClass("keyimen_npc_dragon");
function tbDragon:OnDeath(pNpcKiller)
	local pPlayer = pNpcKiller.GetPlayer();
	if not pPlayer then
		local tbNpcInfo = Keyimen.tbDragonList[him.dwId];
		if (not tbNpcInfo) then
			print("[stack trackback]keyimen_npc_dragon OnDeath Keyimen.tbDragonList not pPlayer is nil", him.dwId);
			return 0;
		end
		Keyimen:UpdateDragon_GS(tbNpcInfo.nNpcId, tbNpcInfo.nMapId, tbNpcInfo.nMapX, tbNpcInfo.nMapY, tbNpcInfo.nCamp, tbNpcInfo.nIndex);
		Keyimen.tbDragonList[him.dwId] = nil;
		return 0;
	end

	local nTongId = pPlayer.dwTongId;
	local pTong = KTong.GetTong(nTongId);
	if pTong then
		Keyimen:UpdateDialogNpc(him.dwId, nTongId, pTong.GetName());
	else
		local tbNpcInfo = Keyimen.tbDragonList[him.dwId];
		if (not tbNpcInfo) then
			print("[stack trackback]keyimen_npc_dragon OnDeath Keyimen.tbDragonList not pTong is nil", him.dwId);
			return 0;
		end
		Keyimen:UpdateDragon_GS(tbNpcInfo.nNpcId, tbNpcInfo.nMapId, tbNpcInfo.nMapX, tbNpcInfo.nMapY, tbNpcInfo.nCamp, tbNpcInfo.nIndex);
		Keyimen.tbDragonList[him.dwId] = nil;
	end
end

-- 赤焰龙魂
local tbDialog = Npc:GetClass("keyimen_npc_dialog");
function tbDialog:OnDialog()
	
	-- 检测帮会
	local nTongId = him.GetTempTable("Keyimen").nTongId;
	if nTongId ~= me.dwTongId then
		return 0;
	end	
	
	-- 完成任务
	local nIndex = him.GetTempTable("Keyimen").nIndex;
	if me.GetTask(Keyimen.TASK_GID, Keyimen.TASK_FINISH[nIndex]) == 0 then
		local tbBreakEvent = 
		{
			Player.ProcessBreakEvent.emEVENT_MOVE,
			Player.ProcessBreakEvent.emEVENT_ATTACK,
			Player.ProcessBreakEvent.emEVENT_SIT,
			Player.ProcessBreakEvent.emEVENT_RIDE,
	--		Player.ProcessBreakEvent.emEVENT_USEITEM,
			Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
			Player.ProcessBreakEvent.emEVENT_DROPITEM,
			Player.ProcessBreakEvent.emEVENT_CHANGEEQUIP,
			Player.ProcessBreakEvent.emEVENT_SENDMAIL,		
			Player.ProcessBreakEvent.emEVENT_TRADE,
			Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
	--		Player.ProcessBreakEvent.emEVENT_ATTACKED,
			Player.ProcessBreakEvent.emEVENT_DEATH,
			Player.ProcessBreakEvent.emEVENT_LOGOUT,
			Player.ProcessBreakEvent.emEVENT_REVIVE,
			Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		}
		GeneralProcess:StartProcess("Phóng thích Long Hồn...", 1 * Env.GAME_FPS, {self.OnFinish, self, me.nId, him.dwId}, nil, tbBreakEvent);			
	end
end

function tbDialog:OnFinish(nPlayerId, nNpcdwId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pNpc = KNpc.GetById(nNpcdwId);
	if pPlayer and pNpc then
		local nIndex = pNpc.GetTempTable("Keyimen").nIndex;
		if pPlayer.GetTask(Keyimen.TASK_GID, Keyimen.TASK_FINISH[nIndex]) == 0 then
			pPlayer.SetTask(Keyimen.TASK_GID, Keyimen.TASK_FINISH[nIndex], 1);
			Keyimen:SendMessage(pPlayer, Keyimen.MSG_CHANNEL, string.format("Hoàn thành nhiệm vụ: Phóng thích <color=yellow>%s<color>", pNpc.szName));
			StatLog:WriteStatLog("stat_info", "keyimen_battle", "dragon_talk", pPlayer.nId, pNpc.nTemplateId);
		end
	end
end
