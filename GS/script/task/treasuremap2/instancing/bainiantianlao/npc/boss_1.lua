
-- 百年天牢的第一个 BOSS，杀死他可以获得进入密室的钥匙

local tbNpc_1	= Npc:GetClass("bainiantianlao2_boss1");

function tbNpc_1:OnDeath(pNpc)
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	tbInstancing.nBoss				= 1;

	tbInstancing:AddKillBossNum(him);
	tbInstancing:AwardWeiWangAndXinde(2, 5, 100000);
	local pPlayer = pNpc.GetPlayer();
	if (pPlayer) then
--		pPlayer.DropRateItem(TreasureMap.szBossDropPath_1, 24, -1, -1, him);
--		TreasureMap2:AwardWeiWangAndXinde(pPlayer, 2, 5, 1, 100000);
	end
end;



local tbNpc_2	= Npc:GetClass("bainiantianlao2_boss2");

function tbNpc_2:OnDeath(pNpc)
	local pPlayer = pNpc.GetPlayer();
	if (pPlayer) then
	--	pPlayer.DropRateItem(TreasureMap.szBossDropPath_1, 24, -1, -1, him);
	--	TreasureMap2:AwardWeiWangAndXinde(pPlayer, 2, 5, 1, 100000);		
		-- 成就：完成初级副本百年天牢
		--TreasureMap2:GetAchievement(tbTeamList, Achievement.FUBEN_BAINIANTIANLAO, pPlayer.nMapId);
	end

	--掉落篝火
	--local nNpcMapId, nNpcPosX, nNpcPosY = him.GetWorldPos();
	--KItem.AddItemInPos(nNpcMapId,nNpcPosX,nNpcPosY,18,1,99,1);
	
	-- 
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nSubWorld);
	assert(tbInstancing);	
	tbInstancing:AwardWeiWangAndXinde(2, 5, 100000);	
	tbInstancing:AddKillBossNum(him);
	tbInstancing:MissionComplete();
end;
