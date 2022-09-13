-- ====================== 文件信息 ======================

-- 千琼宫副本 BOSS 脚本
-- Edited by peres
-- 2008/07/25 AM 11:39

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

local tbBoss_1	= Npc:GetClass("purepalace2_boss_1");	-- 羽凌儿
local tbBoss_2	= Npc:GetClass("purepalace2_boss_2");	-- 萧媛媛
local tbBoss_3	= Npc:GetClass("purepalace2_boss_3");	-- 肖良
local tbBoss_4	= Npc:GetClass("purepalace2_boss_4");	-- 肖玉
local tbBoss_5	= Npc:GetClass("purepalace2_boss_5");	-- 冷霜然
local tbBoss_6	= Npc:GetClass("purepalace2_boss_6");	-- 小怜

local tbCaptain	= Npc:GetClass("purepalace2_captain");	-- 首领，杀死后可在地上产生箱子

local tbRabbit	= Npc:GetClass("purepalace2_rabbit");	-- 小兔子

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
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);
	
	tbInstancing.tbBossDown[1] = 1;
	
	-- 删除障碍物
	local pStatuary = KNpc.GetById(tbInstancing.tbStatuaryIndex[1]);
	if pStatuary then
		pStatuary.Delete();
	end;
	
	-- 如果兔子没被杀死的话，则产生一个 NPC
	if tbInstancing.nRabbit == 0 then
		--KNpc.Add2(2738, 1, 0, nMapId, 1684, 3119);
		local pNpc2 = KNpc.Add2(6961, 1, 0, nMapId, 1684, 3119);
		if pNpc2 then
			--pNpc2.GetTempTable("TreasureMap2").nNpcScore = 0;
		end
	end;
	
	-- 加一个袋子
	--KNpc.Add2(2751, 1, -1, nMapId, nMapX, nMapY);
	KNpc.Add2(6974, 1, -1, nMapId, nMapX, nMapY);
	local pPlayer = pNpc.GetPlayer();
	if (pPlayer) then
	--	pPlayer.DropRateItem(TreasureMap.tbDrop_Level_3["Npc_Boss1"], 26, -1, -1, him);
	--	TreasureMap:AwardWeiWangAndXinde(pPlayer, 2, 5, 1, 100000);
	end	
	
	tbInstancing:AddKillBossNum(him);	
	tbInstancing:AwardWeiWangAndXinde(2, 5, 100000);	
end;

function tbBoss_2:OnDeath(pNpc)
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);
	
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
			--KNpc.Add2(2744, 1, -1, nMapId, 1571, 2956);
			KNpc.Add2(6967, 1, -1, nMapId, 1571, 2956);
			TreasureMap2:AddInstanceScore(tbInstancing, 10 * TreasureMap2.LEVEL_RATE[tbInstancing.nTreasureLevel]);
		end;
	end;
	
	local pPlayer = pNpc.GetPlayer();
	if (pPlayer) then
	--	pPlayer.DropRateItem(TreasureMap.tbDrop_Level_3["Npc_Boss1"], 26, -1, -1, him);
	--	TreasureMap:AwardWeiWangAndXinde(pPlayer, 2, 5, 1, 100000);
	end
	
	tbInstancing:AddKillBossNum(him);			
	tbInstancing:AwardWeiWangAndXinde(2, 5, 100000);		
end;

function tbBoss_3:OnDeath(pNpc)
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);
	
	tbInstancing.tbBossDown[3] = 1;
	
	-- 删除障碍物
	local pStatuary = KNpc.GetById(tbInstancing.tbStatuaryIndex[3]);
	if pStatuary then
		pStatuary.Delete();
	end;
	
	local pPlayer = pNpc.GetPlayer();
	if (pPlayer) then
	--	pPlayer.DropRateItem(TreasureMap.tbDrop_Level_3["Npc_Boss1"], 26, -1, -1, him);
	--	TreasureMap:AwardWeiWangAndXinde(pPlayer, 2, 5, 1, 100000);
	end

	tbInstancing:AddKillBossNum(him);			
	tbInstancing:AwardWeiWangAndXinde(2, 5, 100000);		
end;

function tbBoss_4:OnDeath(pNpc)
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);
	
	tbInstancing.tbBossDown[4] = 1;
	
	-- 删除障碍物
	local pStatuary = KNpc.GetById(tbInstancing.tbStatuaryIndex[4]);
	if pStatuary then
		pStatuary.Delete();
	end;

	local pPlayer = pNpc.GetPlayer();
	if (pPlayer) then
	--	pPlayer.DropRateItem(TreasureMap.tbDrop_Level_3["Npc_Boss1"], 26, -1, -1, him);
	--	TreasureMap:AwardWeiWangAndXinde(pPlayer, 2, 5, 1, 100000);
	end	
	
	tbInstancing:AddKillBossNum(him);		
	tbInstancing:AwardWeiWangAndXinde(2, 5, 100000);		
end;

function tbBoss_5:OnDeath(pNpc)
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);
	
	tbInstancing.tbBossDown[5] = 1;

	tbInstancing:AwardWeiWangAndXinde(2, 5, 100000);	
	
	tbInstancing:AddKillBossNum(him);			
	local pPlayer = pNpc.GetPlayer();
	if (pPlayer) then
	--	pPlayer.DropRateItem(TreasureMap.tbDrop_Level_3["Npc_Boss2"], 28, -1, -1, him);
	--	TreasureMap:AwardWeiWangAndXinde(pPlayer, 2, 5, 1, 100000);
		-- 添加亲密度
	--	local tbTeamMembers = pPlayer.GetTeamMemberList();
	--	TreasureMap:AddFriendFavor(tbTeamMembers, pPlayer.nMapId, 50);
		
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
		
		-- 用于老玩家召回任务完成任务记录
		local tbMemberList = pPlayer.GetTeamMemberList() or {};	
		for _, player in ipairs(tbMemberList) do 
			Task.OldPlayerTask:AddPlayerTaskValue(player.nId, 2082, 5);
		end;
	end;

	tbInstancing:ProcessTask();
	-- 必须已经开始护送小怜而且小怜没死
	if tbInstancing.nGirlProStep == 1 and tbInstancing.nGirlKilled == 0 then
		-- 加一个袋子
		local pNpc = KNpc.Add2(6974, 1, -1, nMapId, nMapX, nMapY);
		return;
	end;
	
	tbInstancing:MissionComplete();
	
	-- 加一个传送点
--	local pSendPos	= KNpc.Add2(2749, 1, -1, nMapId, 1812, 2628);
--	pSendPos.szName	= "千琼宫通往地面的出口";
	
end;

function tbBoss_6:OnDeath(pNpc)
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);
	
	tbInstancing.tbBossDown[6] = 1;
	
	local pPlayer = pNpc.GetPlayer();
	if (pPlayer) then
		--pPlayer.DropRateItem(TreasureMap.tbDrop_Level_3["Npc_Boss2"], 26, -1, -1, him);
		-- TreasureMap2:AwardWeiWangAndXinde(pPlayer, 2, 5, 1, 100000);
		-- 添加亲密度
		--local tbTeamMembers = pPlayer.GetTeamMemberList();
		--TreasureMap:AddFriendFavor(tbTeamMembers, pPlayer.nMapId, 50);
		
		-- 师徒成就：副本千琼宫
	--	TreasureMap:GetAchievement(tbTeamMembers, Achievement.FUBEN_QIANQIONG, pPlayer.nMapId);
	end	
	
	-- 加一个传送点
	--local pSendPos	= KNpc.Add2(2749, 1, -1, nMapId, 1822, 2907);
	--pSendPos.szName	= "千琼宫通往地面的出口";

	tbInstancing:AddKillBossNum(him);		
	tbInstancing:AwardWeiWangAndXinde(2, 5, 100000);
	tbInstancing:MissionComplete();
end;

function tbCaptain:OnDeath(pNpc)
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);
	
	
	TreasureMap2:AddInstanceScore(tbInstancing, him.GetTempTable("TreasureMap2").nNpcScore);
	TreasureMap2:AddKillNpcNum(tbInstancing);		
	
	-- 在地上加个箱子
	local pNpc = KNpc.Add2(6973, 1, -1, nMapId, nMapX, nMapY);
	if pNpc then
		pNpc.GetTempTable("TreasureMap2").nNpcScore = 2 * TreasureMap2.LEVEL_RATE[tbInstancing.nTreasureLevel];
	end	
end;

-- 血量触发
function tbBoss_1:OnLifePercentReduceHere(nLifePercent)
	local nBossId	= 1;
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbNpcPos	= tbCallNpcPos[nBossId];
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);
	local nNpcLevel =  	TreasureMap2.TEMPLATE_LIST[tbInstancing.nTreasureId].tbNpcLevel[tbInstancing.nTreasureLevel] ;
	
	if nLifePercent == 50 and tbInstancing.tbBossLifePoint[nBossId][50] == 0 then
		for i=1, #tbNpcPos[50] do
			local pNpc = KNpc.Add2(6955, nNpcLevel, -1, nMapId, tbNpcPos[50][i][1], tbNpcPos[50][i][2]);
			if pNpc then
			--	pNpc.GetTempTable("TreasureMap2").nCaptainId = tbInstancing.nCaptainId;
			--	pNpc.GetTempTable("TreasureMap2").nNpcScore = 1 * TreasureMap2.LEVEL_RATE[tbInstancing.nTreasureLevel];
			end
		end;
		tbInstancing.tbBossLifePoint[nBossId][50] = 1;
		him.SendChat("Hãy nhanh chóng giúp ta !");
	end;
	if nLifePercent == 30 and tbInstancing.tbBossLifePoint[nBossId][30] == 0 then
		for i=1, #tbNpcPos[30] do
			local pNpc = KNpc.Add2(6955, nNpcLevel, -1, nMapId, tbNpcPos[30][i][1], tbNpcPos[30][i][2]);
			if pNpc then
				--pNpc.GetTempTable("TreasureMap2").nCaptainId = tbInstancing.nCaptainId;
				--pNpc.GetTempTable("TreasureMap2").nNpcScore = 1 * TreasureMap2.LEVEL_RATE[tbInstancing.nTreasureLevel];
			end
		end;
		tbInstancing.tbBossLifePoint[nBossId][30] = 1;
		him.SendChat("Tiểu Thố Tử, hãy nhanh chóng giúp ta!");
	end;	
end;

function tbBoss_2:OnLifePercentReduceHere(nLifePercent)
	local nBossId	= 2;
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbNpcPos	= tbCallNpcPos[nBossId];
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);
	local nNpcLevel =  	TreasureMap2.TEMPLATE_LIST[tbInstancing.nTreasureId].tbNpcLevel[tbInstancing.nTreasureLevel] ;

	if nLifePercent == 50 and tbInstancing.tbBossLifePoint[nBossId][50] == 0 then
		for i=1, #tbNpcPos[50] do
			local pNpc = KNpc.Add2(6955, nNpcLevel, -1, nMapId, tbNpcPos[50][i][1], tbNpcPos[50][i][2]);
			if pNpc then
			--	pNpc.GetTempTable("TreasureMap2").nCaptainId = tbInstancing.nCaptainId;
			--	pNpc.GetTempTable("TreasureMap2").nNpcScore = 1 * TreasureMap2.LEVEL_RATE[tbInstancing.nTreasureLevel];
			end
		end;
		tbInstancing.tbBossLifePoint[nBossId][50] = 1;
		him.SendChat("Ngươi còn chờ đợi gì nữa ?");
	end;
	if nLifePercent == 30 and tbInstancing.tbBossLifePoint[nBossId][30] == 0 then
		for i=1, #tbNpcPos[30] do
			local pNpc = KNpc.Add2(6955, nNpcLevel, -1, nMapId, tbNpcPos[30][i][1], tbNpcPos[30][i][2]);
			if pNpc then
				--pNpc.GetTempTable("TreasureMap2").nCaptainId = tbInstancing.nCaptainId;
				--pNpc.GetTempTable("TreasureMap2").nNpcScore = 1 * TreasureMap2.LEVEL_RATE[tbInstancing.nTreasureLevel];
			end	
		end;
		tbInstancing.tbBossLifePoint[nBossId][30] = 1;
		him.SendChat("Hãy ra đây, bảo vệ ta !");
	end;	
end;

function tbBoss_3:OnLifePercentReduceHere(nLifePercent)
	local nBossId	= 3;
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbNpcPos	= tbCallNpcPos[nBossId];
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);
	local nNpcLevel =  	TreasureMap2.TEMPLATE_LIST[tbInstancing.nTreasureId].tbNpcLevel[tbInstancing.nTreasureLevel] ;

	if nLifePercent == 50 and tbInstancing.tbBossLifePoint[nBossId][50] == 0 then
		for i=1, #tbNpcPos[50] do
			local pNpc = KNpc.Add2(6955, nNpcLevel, -1, nMapId, tbNpcPos[50][i][1], tbNpcPos[50][i][2]);
			if pNpc then
			--	pNpc.GetTempTable("TreasureMap2").nCaptainId = tbInstancing.nCaptainId;
			--	pNpc.GetTempTable("TreasureMap2").nNpcScore = 1 * TreasureMap2.LEVEL_RATE[tbInstancing.nTreasureLevel];
			end
		end;
		tbInstancing.tbBossLifePoint[nBossId][50] = 1;
		him.SendChat("Đến đây, đúng là phụ nữ !");
	end;
	if nLifePercent == 30 and tbInstancing.tbBossLifePoint[nBossId][30] == 0 then
		for i=1, #tbNpcPos[30] do
			local pNpc = KNpc.Add2(6955, nNpcLevel, -1, nMapId, tbNpcPos[30][i][1], tbNpcPos[30][i][2]);
			if pNpc then
			--	pNpc.GetTempTable("TreasureMap2").nCaptainId = tbInstancing.nCaptainId;
			--	pNpc.GetTempTable("TreasureMap2").nNpcScore = 1 * TreasureMap2.LEVEL_RATE[tbInstancing.nTreasureLevel];
			end
		end;
		tbInstancing.tbBossLifePoint[nBossId][30] = 1;
		him.SendChat("Đến đây, đúng là phụ nữ !");
	end;	
end;

function tbBoss_4:OnLifePercentReduceHere(nLifePercent)
	local nBossId	= 4;
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbNpcPos	= tbCallNpcPos[nBossId];
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);
	local nNpcLevel =  	TreasureMap2.TEMPLATE_LIST[tbInstancing.nTreasureId].tbNpcLevel[tbInstancing.nTreasureLevel] ;

	
	if nLifePercent == 50 and tbInstancing.tbBossLifePoint[nBossId][50] == 0 then
		for i=1, #tbNpcPos[50] do
			local pNpc = KNpc.Add2(6955, nNpcLevel, -1, nMapId, tbNpcPos[50][i][1], tbNpcPos[50][i][2]);
			if pNpc then
			--	pNpc.GetTempTable("TreasureMap2").nCaptainId = tbInstancing.nCaptainId;
			--	pNpc.GetTempTable("TreasureMap2").nNpcScore = 1 * TreasureMap2.LEVEL_RATE[tbInstancing.nTreasureLevel];
			end
		end;
		tbInstancing.tbBossLifePoint[nBossId][50] = 1;
		him.SendChat("Hãy tới đây những kẻ xâm nhập kia !");
	end;
	if nLifePercent == 30 and tbInstancing.tbBossLifePoint[nBossId][30] == 0 then
		for i=1, #tbNpcPos[30] do
			local pNpc = KNpc.Add2(6955, nNpcLevel, -1, nMapId, tbNpcPos[30][i][1], tbNpcPos[30][i][2]);
			if pNpc then
			--	pNpc.GetTempTable("TreasureMap2").nCaptainId = tbInstancing.nCaptainId;
			--	pNpc.GetTempTable("TreasureMap2").nNpcScore = 1 * TreasureMap2.LEVEL_RATE[tbInstancing.nTreasureLevel];
			end
		end;
		tbInstancing.tbBossLifePoint[nBossId][30] = 1;
		him.SendChat("Hãy tới đây những kẻ xâm nhập kia !");
	end;	
end;


function tbBoss_5:OnLifePercentReduceHere(nLifePercent)
	local nBossId	= 5;
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbNpcPos	= tbCallNpcPos[nBossId];
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);
	local nNpcLevel =  	TreasureMap2.TEMPLATE_LIST[tbInstancing.nTreasureId].tbNpcLevel[tbInstancing.nTreasureLevel] ;

	if nLifePercent == 50 and tbInstancing.tbBossLifePoint[nBossId][50] == 0 then
		for i=1, #tbNpcPos[50] do
			KNpc.Add2(6959, nNpcLevel, -1, nMapId, tbNpcPos[50][i][1], tbNpcPos[50][i][2]);
		end;
		tbInstancing.tbBossLifePoint[nBossId][50] = 1;
		him.SendChat("Chữa trị cho ta, đúng là một đóa hoa đẹp !");
	end;
	if nLifePercent == 30 and tbInstancing.tbBossLifePoint[nBossId][30] == 0 then
		for i=1, #tbNpcPos[30] do
			KNpc.Add2(6959, nNpcLevel, -1, nMapId, tbNpcPos[30][i][1], tbNpcPos[30][i][2]);
		end;
		tbInstancing.tbBossLifePoint[nBossId][30] = 1;
		him.SendChat("Đã nở rồi ! Bông hoa của ta !");
	end;	
end;


-- 小兔子被杀死
function tbRabbit:OnDeath(pNpc)
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);
	
	tbInstancing.nRabbit	= 1;
end;