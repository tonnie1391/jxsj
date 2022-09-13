-- 文件名　：stone.lua
-- 创建者　：LQY
-- 创建时间：2012-07-23 10:34:47
-- 说　　明：召唤石逻辑
-- 炉石你好！

local tbNpc = Npc:GetClass("NewBattle_stone")

-- 死亡事件
function tbNpc:OnDeath(pNpcKiller)
	local nPower = -1;
	local pKiller = pNpcKiller.GetPlayer();
	local szKillerName = "";
	--玩家杀的
	if pKiller then
		nPower = NewBattle.Mission:GetPlayerGroupId(me);
		szKillerName = pKiller.szName;
	end
	
	--NPC杀的
	if not pKiller then
		local tbInfo = pNpcKiller.GetTempTable("Npc")
		nPower = tbInfo.nPower;
		local tbPlayers = pNpcKiller.GetCarrierPassengers();
		for _, pPlayer in pairs(tbPlayers) do
			szKillerName = szKillerName..pPlayer.szName.." %s ";
		end		
		if not tbPlayers[1] then
			szKillerName = string.format(szKillerName, "Chiến Xa");
		else
			szKillerName = string.format(szKillerName, "và","Chiến Xa");
		end
	end
	if nPower == -1  then
		return;
	end
	local szMsg = string.format("<color=yellow>%s<color><color=white>[%s]<color> chiếm Đá Triệu Hồi, nhuệ khí phe %s tăng gấp bội", (nPower == 1) and "Mông Cổ-" or "Tây Hạ-", szKillerName, (nPower == 1) and "Mông Cổ" or "Tây Hạ");
	NewBattle.Mission:BroadCastMission(szMsg,NewBattle.SYSTEMBLACK_MSG, 0);
	NewBattle.Mission:BroadCastMission(string.format("Đá Triệu Hồi sau khi chiếm giữ có thời gian bảo vệ <color=white>%d giây<color>.", NewBattle.STONETRANSFERCD), NewBattle.SYSTEM_CHANNEL_MSG, 0);
	--设置召唤石归属
	NewBattle.Mission.nTransStoneOwner = nPower;			
	local nMapId, nPosX, nPosY = him.GetWorldPos();
	if not nMapId or not nPosX or not nPosY then
		return;
	end
	
	--原地重新刷新NPC，更改阵营，增加保护时间
	local pNpc = KNpc.Add2(NewBattle.STONE_ID, NewBattle.Mission.tbNpcLevel.ZHAOHUANSHI, -1, nMapId, nPosX, nPosY, 0, 1)
	if pNpc then
		local szCol  = (nPower == 1) and "blue" or "yellow";
		local szName = (nPower == 1) and "Phe Mông Cổ" or "Phe Tây Hạ";
		pNpc.SetTitle(string.format("<color=%s>%s<color>", szCol, szName));
		local tbInfo = pNpc.GetTempTable("Npc");
		tbInfo.nPower = nPower;
		pNpc.SetCurCamp(nPower);
		--pNpc.SetVirtualRelation(Player.emKPK_STATE_CAMP, nPower);
		pNpc.AddSkillState(2718, 20, 1, NewBattle.STONETRANSFERCD * Env.GAME_FPS);
		NewBattle.Mission:AddTip(NewBattle.POWER_ENAME[nPower], 2, 2);
		NewBattle.Mission:AddTip(NewBattle.POWER_ENAME[NewBattle:GetEnemy(nPower)], 2, 1);
	end
end
