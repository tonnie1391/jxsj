
-- ====================== 文件信息 ======================

-- 大漠古城 BOSS 脚本
-- Edited by peres
-- 2008/05/15 PM 20:27

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

local tbBoss_1			= Npc:GetClass("damogucheng2_boss1");	-- 面具武士
local tbBoss_2			= Npc:GetClass("damogucheng2_boss2");	-- 尸逐达鲁
local tbBoss_3			= Npc:GetClass("damogucheng2_boss3");	-- 无名氏


function tbBoss_1:OnDeath(pNpc)
	local nNpcMapId, nNpcPosX, nNpcPosY	= him.GetWorldPos();
	
	-- 加一个袋子
	--KNpc.Add2(2727, 1, -1, nNpcMapId, nNpcPosX, nNpcPosY);
	KNpc.Add2(6951, 1, -1, nNpcMapId, nNpcPosX, nNpcPosY);
	local pPlayer = pNpc.GetPlayer();
	if (pPlayer) then
	--	pPlayer.DropRateItem(TreasureMap.tbDrop_Level_2["Npc_Boss1"], 24, -1, -1, him);
	--	TreasureMap2:AwardWeiWangAndXinde(pPlayer, 2, 5, 1, 100000);
	end
	
	local tbInstancing = TreasureMap2:GetInstancing(nNpcMapId);
	if not tbInstancing then
		print("[ERR] damogucheng  tbBoss_1:OnDeath not instance");
		return;
	end
	
--	TreasureMap2:AddInstanceScore(tbInstancing, him.GetTempTable("TreasureMap2").nNpcScore);
	tbInstancing:AddKillBossNum(him);	
	tbInstancing:AwardWeiWangAndXinde(2, 5, 100000);	
end;

function tbBoss_2:OnDeath(pNpc)
	local nNpcMapId, nNpcPosX, nNpcPosY	= him.GetWorldPos();
	
	-- 加一个袋子
	--KNpc.Add2(2729, 1, -1, nNpcMapId, nNpcPosX, nNpcPosY);
	KNpc.Add2(6952, 1, -1, nNpcMapId, nNpcPosX, nNpcPosY);
	local pPlayer = pNpc.GetPlayer();
	if (pPlayer) then
	--	pPlayer.DropRateItem(TreasureMap.tbDrop_Level_2["Npc_Boss2"], 24, -1, -1, him);
	--	TreasureMap2:AwardWeiWangAndXinde(pPlayer, 2, 5, 1, 100000);
	end
	
	local tbInstancing = TreasureMap2:GetInstancing(nNpcMapId);
	if not tbInstancing then
		print("[ERR] damogucheng  tbBoss_2:OnDeath not instance");
		return;
	end
	
--	TreasureMap2:AddInstanceScore(tbInstancing, him.GetTempTable("TreasureMap2").nNpcScore);
	tbInstancing:AddKillBossNum(him);	
	tbInstancing:AwardWeiWangAndXinde(2, 5, 100000);
end;

function tbBoss_3:OnDeath(pNpc)

	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nSubWorld);
	if not tbInstancing then
		print("[ERR] damogucheng  tbBoss_3:OnDeath not instance");
		return;
	end
	
	tbInstancing:AddKillBossNum(him);		
	tbInstancing.nBoss_3_kill		= 1;

	local pPlayer = pNpc.GetPlayer();
	if (pPlayer) then
	--	pPlayer.DropRateItem(TreasureMap.tbDrop_Level_2["Npc_Boss2"], 24, -1, -1, him);
	--	TreasureMap2:AwardWeiWangAndXinde(pPlayer, 2, 5, 1, 100000);
		
		-- 副本任务的处理
--		local tbTeamMembers, nMemberCount	= pPlayer.GetTeamMemberList();
--		
--		if (not tbTeamMembers) or (nMemberCount <= 0) then
--			TreasureMap2:InstancingTask(pPlayer, tbInstancing.nMapTemplateId);
--			return;
--		else
--			for i=1, nMemberCount do
--				local pNowPlayer	= tbTeamMembers[i];
--				TreasureMap2:InstancingTask(pNowPlayer, tbInstancing.nMapTemplateId);
--			end
--		end
		-- 添加亲密度
	--	TreasureMap2:AddFriendFavor(tbTeamMembers, pPlayer.nMapId, 50);
		
		-- 师徒成就：副本大漠古城
	--	TreasureMap2:GetAchievement(tbTeamMembers, Achievement.FUBEN_DAMOGUCHENG, pPlayer.nMapId);
		
	end	
	
	if tbInstancing.tbStele_1_Idx then
		for i=1, #tbInstancing.tbStele_1_Idx do
			local pNpc	= KNpc.GetById(tbInstancing.tbStele_1_Idx[i]);
			if pNpc then
				pNpc.Delete();
			end;
		end;
	end;
	tbInstancing:AwardWeiWangAndXinde(2, 5, 100000);
	tbInstancing:MissionComplete();		
end;