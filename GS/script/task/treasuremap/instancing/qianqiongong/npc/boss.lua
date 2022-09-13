
-- ====================== 文件信息 ======================

-- 千琼宫副本 BOSS 脚本
-- Edited by peres
-- 2008/07/25 AM 11:39

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

local tbBoss_1	= Npc:GetClass("purepalace_boss_1");	-- 羽凌儿
local tbBoss_2	= Npc:GetClass("purepalace_boss_2");	-- 萧媛媛
local tbBoss_3	= Npc:GetClass("purepalace_boss_3");	-- 肖良
local tbBoss_4	= Npc:GetClass("purepalace_boss_4");	-- 肖玉
local tbBoss_5	= Npc:GetClass("purepalace_boss_5");	-- 冷霜然
local tbBoss_6	= Npc:GetClass("purepalace_boss_6");	-- 小怜

local tbCaptain	= Npc:GetClass("purepalace_captain");	-- 首领，杀死后可在地上产生箱子

local tbRabbit	= Npc:GetClass("purepalace_rabbit");	-- 小兔子

local tbCallNpcPos = {
	[1]	= {
			[50]	= {{1678, 3115},{1685, 3123}},
			[30]	= {{1674, 3120},{1681, 3127},{1684, 3118}},
		},
	[2]	= {
			[50]	= {{1567, 2956},{1571, 2951}},
			[30]	= {{1563, 2959},{1574, 2948},{1571, 2956}},		
		},
	[3]	= {
			[50]	= {{1567, 2823},{1579, 2835}},
			[30]	= {{1567, 2829},{1572, 2835}},		
		},
	[4]	= {
			[50]	= {{1708, 2783},{1711, 2789}},
			[30]	= {{1703, 2788},{1708, 2794}},	
		},
	[5]	= {
			[50]	= {{1804, 2663},{1820, 2679}},
			[30]	= {{1804, 2678},{1816, 2666}},
		},
}

function tbBoss_1:OnDeath(pNpc)
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	tbInstancing.tbBossDown[1] = 1;
	
	-- 删除障碍物
	local pStatuary = KNpc.GetById(tbInstancing.tbStatuaryIndex[1]);
	if pStatuary then
		pStatuary.Delete();
	end;
	
	-- 如果兔子没被杀死的话，则产生一个 NPC
	if tbInstancing.nRabbit == 0 then
		KNpc.Add2(2738, 1, 0, nMapId, 1684, 3119);
	end;
	
	-- 加一个袋子
	KNpc.Add2(2751, 1, -1, nMapId, nMapX, nMapY);
	
	local pPlayer = pNpc.GetPlayer();
	if (pPlayer) then
		pPlayer.DropRateItem(TreasureMap.tbDrop_Level_3["Npc_Boss1"], 26, -1, -1, him);
		TreasureMap:AwardWeiWangAndXinde(pPlayer, 2, 5, 1, 100000);
	end		
end;

function tbBoss_2:OnDeath(pNpc)
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	tbInstancing.tbBossDown[2] = 1; 

	-- 删除障碍物
	local pStatuary = KNpc.GetById(tbInstancing.tbStatuaryIndex[2]);
	if pStatuary then
		pStatuary.Delete();
	end;
	
	-- 如果这时候小怜没死的话，则把她变回普通 NPC
	if tbInstancing.nGirlKilled == 0 and tbInstancing.nGirlProStep == 1 then
		local pGirlNpc	= KNpc.GetById(tbInstancing.nGirlId);
		if pGirlNpc then
			pGirlNpc.Delete();
			KNpc.Add2(2744, 1, -1, nMapId, 1571, 2956);
		end;
	end;
	
	local pPlayer = pNpc.GetPlayer();
	if (pPlayer) then
		pPlayer.DropRateItem(TreasureMap.tbDrop_Level_3["Npc_Boss1"], 26, -1, -1, him);
		TreasureMap:AwardWeiWangAndXinde(pPlayer, 2, 5, 1, 100000);
	end	
end;

function tbBoss_3:OnDeath(pNpc)
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	tbInstancing.tbBossDown[3] = 1;
	
	-- 删除障碍物
	local pStatuary = KNpc.GetById(tbInstancing.tbStatuaryIndex[3]);
	if pStatuary then
		pStatuary.Delete();
	end;
	
	local pPlayer = pNpc.GetPlayer();
	if (pPlayer) then
		pPlayer.DropRateItem(TreasureMap.tbDrop_Level_3["Npc_Boss1"], 26, -1, -1, him);
		TreasureMap:AwardWeiWangAndXinde(pPlayer, 2, 5, 1, 100000);
	end		
end;

function tbBoss_4:OnDeath(pNpc)
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	tbInstancing.tbBossDown[4] = 1;
	
	-- 删除障碍物
	local pStatuary = KNpc.GetById(tbInstancing.tbStatuaryIndex[4]);
	if pStatuary then
		pStatuary.Delete();
	end;

	local pPlayer = pNpc.GetPlayer();
	if (pPlayer) then
		pPlayer.DropRateItem(TreasureMap.tbDrop_Level_3["Npc_Boss1"], 26, -1, -1, him);
		TreasureMap:AwardWeiWangAndXinde(pPlayer, 2, 5, 1, 100000);
	end		
end;

function tbBoss_5:OnDeath(pNpc)
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	tbInstancing.tbBossDown[5] = 1;

	local pPlayer = pNpc.GetPlayer();
	if (pPlayer) then
		pPlayer.DropRateItem(TreasureMap.tbDrop_Level_3["Npc_Boss2"], 28, -1, -1, him);
		TreasureMap:AwardWeiWangAndXinde(pPlayer, 2, 5, 1, 100000);
		-- 添加亲密度
		local tbTeamMembers = pPlayer.GetTeamMemberList();
		TreasureMap:AddFriendFavor(tbTeamMembers, pPlayer.nMapId, 50);
		
		-- 副本任务的处理
		local tbTeamMembers, nMemberCount	= pPlayer.GetTeamMemberList();
		
		if (not tbTeamMembers) or (nMemberCount <= 0) then
			TreasureMap:InstancingTask(pPlayer, tbInstancing.nMapTemplateId);
			return;
		else
			for i=1, nMemberCount do
				local pNowPlayer	= tbTeamMembers[i];
				TreasureMap:InstancingTask(pNowPlayer, tbInstancing.nMapTemplateId);
			end
		end
		
		-- 用于老玩家召回任务完成任务记录
		local tbMemberList = pPlayer.GetTeamMemberList();	
		for _, player in ipairs(tbMemberList) do 
			Task.OldPlayerTask:AddPlayerTaskValue(player.nId, 2082, 5);
		end;
	end;

	
	-- 必须已经开始护送小怜而且小怜没死
	if tbInstancing.nGirlProStep == 1 and tbInstancing.nGirlKilled == 0 then
		-- 加一个袋子
		KNpc.Add2(2751, 1, -1, nMapId, nMapX, nMapY);
	end;
	
	-- 加一个传送点
	local pSendPos	= KNpc.Add2(2749, 1, -1, nMapId, 1812, 2628);
	pSendPos.szName	= "千琼宫通往地面的出口";
	
end;

function tbBoss_6:OnDeath(pNpc)
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	tbInstancing.tbBossDown[6] = 1;
	
	local pPlayer = pNpc.GetPlayer();
	if (pPlayer) then
		pPlayer.DropRateItem(TreasureMap.tbDrop_Level_3["Npc_Boss2"], 26, -1, -1, him);
		TreasureMap:AwardWeiWangAndXinde(pPlayer, 2, 5, 1, 100000);
		-- 添加亲密度
		local tbTeamMembers = pPlayer.GetTeamMemberList();
		TreasureMap:AddFriendFavor(tbTeamMembers, pPlayer.nMapId, 50);
		
		-- 师徒成就：副本千琼宫
		TreasureMap:GetAchievement(tbTeamMembers, Achievement_ST.FUBEN_QIANQIONG, pPlayer.nMapId);
	end	
	
	-- 加一个传送点
	local pSendPos	= KNpc.Add2(2749, 1, -1, nMapId, 1822, 2907);
	pSendPos.szName	= "千琼宫通往地面的出口";

end;

function tbCaptain:OnDeath(pNpc)
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	
	-- 在地上加个箱子
	KNpc.Add2(2750, 1, -1, nMapId, nMapX, nMapY);
end;

-- 血量触发
function tbBoss_1:OnLifePercentReduceHere(nLifePercent)
	local nBossId	= 1;
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbNpcPos	= tbCallNpcPos[nBossId];
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	if nLifePercent == 50 and tbInstancing.tbBossLifePoint[nBossId][50] == 0 then
		for i=1, #tbNpcPos[50] do
			KNpc.Add2(2732, 80, -1, nMapId, tbNpcPos[50][i][1], tbNpcPos[50][i][2]);
		end;
		tbInstancing.tbBossLifePoint[nBossId][50] = 1;
		him.SendChat("快出来帮我！");
	end;
	if nLifePercent == 30 and tbInstancing.tbBossLifePoint[nBossId][30] == 0 then
		for i=1, #tbNpcPos[30] do
			KNpc.Add2(2732, 80, -1, nMapId, tbNpcPos[30][i][1], tbNpcPos[30][i][2]);
		end;
		tbInstancing.tbBossLifePoint[nBossId][30] = 1;
		him.SendChat("小的们，快出来帮我！");
	end;	
end;

function tbBoss_2:OnLifePercentReduceHere(nLifePercent)
	local nBossId	= 2;
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbNpcPos	= tbCallNpcPos[nBossId];
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	if nLifePercent == 50 and tbInstancing.tbBossLifePoint[nBossId][50] == 0 then
		for i=1, #tbNpcPos[50] do
			KNpc.Add2(2732, 80, -1, nMapId, tbNpcPos[50][i][1], tbNpcPos[50][i][2]);
		end;
		tbInstancing.tbBossLifePoint[nBossId][50] = 1;
		him.SendChat("你们还等什么？");
	end;
	if nLifePercent == 30 and tbInstancing.tbBossLifePoint[nBossId][30] == 0 then
		for i=1, #tbNpcPos[30] do
			KNpc.Add2(2732, 80, -1, nMapId, tbNpcPos[30][i][1], tbNpcPos[30][i][2]);
		end;
		tbInstancing.tbBossLifePoint[nBossId][30] = 1;
		him.SendChat("出来吧，保护我！");
	end;	
end;

function tbBoss_3:OnLifePercentReduceHere(nLifePercent)
	local nBossId	= 3;
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbNpcPos	= tbCallNpcPos[nBossId];
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	if nLifePercent == 50 and tbInstancing.tbBossLifePoint[nBossId][50] == 0 then
		for i=1, #tbNpcPos[50] do
			KNpc.Add2(2732, 80, -1, nMapId, tbNpcPos[50][i][1], tbNpcPos[50][i][2]);
		end;
		tbInstancing.tbBossLifePoint[nBossId][50] = 1;
		him.SendChat("来吧，我的侍女们！");
	end;
	if nLifePercent == 30 and tbInstancing.tbBossLifePoint[nBossId][30] == 0 then
		for i=1, #tbNpcPos[30] do
			KNpc.Add2(2732, 80, -1, nMapId, tbNpcPos[30][i][1], tbNpcPos[30][i][2]);
		end;
		tbInstancing.tbBossLifePoint[nBossId][30] = 1;
		him.SendChat("来吧，我的侍女们！");
	end;	
end;

function tbBoss_4:OnLifePercentReduceHere(nLifePercent)
	local nBossId	= 4;
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbNpcPos	= tbCallNpcPos[nBossId];
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	if nLifePercent == 50 and tbInstancing.tbBossLifePoint[nBossId][50] == 0 then
		for i=1, #tbNpcPos[50] do
			KNpc.Add2(2732, 82, -1, nMapId, tbNpcPos[50][i][1], tbNpcPos[50][i][2]);
		end;
		tbInstancing.tbBossLifePoint[nBossId][50] = 1;
		him.SendChat("快来把入侵的人赶跑！");
	end;
	if nLifePercent == 30 and tbInstancing.tbBossLifePoint[nBossId][30] == 0 then
		for i=1, #tbNpcPos[30] do
			KNpc.Add2(2732, 82, -1, nMapId, tbNpcPos[30][i][1], tbNpcPos[30][i][2]);
		end;
		tbInstancing.tbBossLifePoint[nBossId][30] = 1;
		him.SendChat("快来把入侵的人赶跑！");
	end;	
end;


function tbBoss_5:OnLifePercentReduceHere(nLifePercent)
	local nBossId	= 5;
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbNpcPos	= tbCallNpcPos[nBossId];
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	if nLifePercent == 50 and tbInstancing.tbBossLifePoint[nBossId][50] == 0 then
		for i=1, #tbNpcPos[50] do
			KNpc.Add2(2736, 30, -1, nMapId, tbNpcPos[50][i][1], tbNpcPos[50][i][2]);
		end;
		tbInstancing.tbBossLifePoint[nBossId][50] = 1;
		him.SendChat("治愈我吧，美丽的花朵！");
	end;
	if nLifePercent == 30 and tbInstancing.tbBossLifePoint[nBossId][30] == 0 then
		for i=1, #tbNpcPos[30] do
			KNpc.Add2(2736, 30, -1, nMapId, tbNpcPos[30][i][1], tbNpcPos[30][i][2]);
		end;
		tbInstancing.tbBossLifePoint[nBossId][30] = 1;
		him.SendChat("盛开吧！我的花朵！");
	end;	
end;


-- 小兔子被杀死
function tbRabbit:OnDeath(pNpc)
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);
	
	tbInstancing.nRabbit	= 1;
end;