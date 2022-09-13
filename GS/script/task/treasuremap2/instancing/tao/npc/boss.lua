
-- ====================== 文件信息 ======================

-- 陶朱公疑冢 BOSS 脚本
-- Edited by peres
-- 2008/03/04 PM 08:26

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

-- 第二层左边的 BOSS
local tbNpc_1	= Npc:GetClass("taozhugongyizhong2_boss1");

function tbNpc_1:OnDeath(pNpc)
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	tbInstancing.nSmallBoss_1		= 1;
	
	local pPlayer = pNpc.GetPlayer();
	if (pPlayer) then
		--pPlayer.DropRateItem(TreasureMap.tbDrop_Level_2["Npc_Boss1"], 24, -1, -1, him);
	--	TreasureMap2:AwardWeiWangAndXinde(pPlayer, 2, 5, 1, 100000);
	end
	

	if tbInstancing.nSmallBoss_1 == 1 and tbInstancing.nSmallBoss_2 == 1 then	
		if tbInstancing.tbStele_2_Idx then
			for i=1, #tbInstancing.tbStele_2_Idx do
				local nNpcId	= tbInstancing.tbStele_2_Idx[i];
				local pNpc		= KNpc.GetById(nNpcId);
		         if pNpc then
			       pNpc.Delete();
		         end;
			end;
		end;
	end;
	
--	TreasureMap2:AddInstanceScore(tbInstancing, him.GetTempTable("TreasureMap2").nNpcScore);
--	TreasureMap2:AddKillBossNum(tbInstancing);
	tbInstancing:AddKillBossNum(him);		
	
	tbInstancing:AwardWeiWangAndXinde(2, 5, 100000);	
	
end;


-- 第二层右边的 BOSS
local tbNpc_2	= Npc:GetClass("taozhugongyizhong2_boss2");

function tbNpc_2:OnDeath(pNpc)
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	tbInstancing.nSmallBoss_2		= 1;
	
	local pPlayer = pNpc.GetPlayer();
	if (pPlayer) then
--		pPlayer.DropRateItem(TreasureMap.tbDrop_Level_2["Npc_Boss1"], 24, -1, -1, him);
--		TreasureMap2:AwardWeiWangAndXinde(pPlayer, 2, 5, 1, 100000);
	end
	
	if tbInstancing.nSmallBoss_1 == 1 and tbInstancing.nSmallBoss_2 == 1 then	
		if tbInstancing.tbStele_2_Idx then
			for i=1, #tbInstancing.tbStele_2_Idx do
				local nNpcId	= tbInstancing.tbStele_2_Idx[i];
				local pNpc		= KNpc.GetById(nNpcId);
		         if pNpc then
			       pNpc.Delete();
		         end;
			end;
		end;
	end;
	

	
--	TreasureMap2:AddInstanceScore(tbInstancing, him.GetTempTable("TreasureMap2").nNpcScore);
--	TreasureMap2:AddKillBossNum(tbInstancing);	
	tbInstancing:AddKillBossNum(him);		
	tbInstancing:AwardWeiWangAndXinde(2, 5, 100000);	
	
end;



-- 最终 BOSS
local tbNpc_3	= Npc:GetClass("taozhugongyizhong2_boss3");

function tbNpc_3:OnDeath(pNpc)
	local nNpcMapId, nNpcPosX, nNpcPosY	= him.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nNpcMapId);
	assert(tbInstancing);
	
--	KNpc.Add2(2705, 1, -1, nNpcMapId, 1639, 3085);	-- 无名女子
--	KNpc.Add2(6931, 1, -1, nNpcMapId, 1639, 3085);	-- 无名女子
	--local pOutNpc = KNpc.Add2(2708, 1, -1, nNpcMapId, 1684, 3028);	-- 出口点
	--	pOutNpc.szName = "出口传送点";
	
	local pPlayer = pNpc.GetPlayer();
	
	if (pPlayer) then
	--	pPlayer.DropRateItem(TreasureMap.tbDrop_Level_2["Npc_Boss2"], 24, -1, -1, him);
		
		-- 副本任务的处理
	--	local tbTeamMembers, nMemberCount	= pPlayer.GetTeamMemberList();
		
	--	if (not tbTeamMembers) or (nMemberCount <= 0) then
	--		TreasureMap:InstancingTask(pPlayer, tbInstancing.nMapTemplateId);
	--		return;
	--	else
	--		for i=1, nMemberCount do
	--			local pNowPlayer	= tbTeamMembers[i];
	--			TreasureMap:InstancingTask(pNowPlayer, tbInstancing.nMapTemplateId);
	--		end
	--	end
	end
	
	--TreasureMap:AwardWeiWangAndXinde(pPlayer, 2, 5, 1, 100000);
	-- 添加亲密度
	--local tbTeamMembers = pPlayer.GetTeamMemberList();
	--TreasureMap:AddFriendFavor(tbTeamMembers, pPlayer.nMapId, 50);
	
	-- 师徒成就：副本陶朱公
	--TreasureMap:GetAchievement(tbTeamMembers, Achievement.FUBEN_TAOZHUGONG, pPlayer.nMapId);
	
	--掉落篝火
	--KItem.AddItemInPos(nNpcMapId,nNpcPosX,nNpcPosY,18,1,99,1);
--	TreasureMap2:AddInstanceScore(tbInstancing, him.GetTempTable("TreasureMap2").nNpcScore);	
--	TreasureMap2:AddKillBossNum(tbInstancing);
	
	tbInstancing:AddKillBossNum(him);		
	tbInstancing:AwardWeiWangAndXinde(2, 5, 100000);	
	tbInstancing:MissionComplete();

end;


local tbTaskNpc			= Npc:GetClass("taozhugong2_task_stele");


-- 接任务的 NPC
function tbTaskNpc:OnDialog()
	return;
end;