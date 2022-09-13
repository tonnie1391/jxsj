-----------------------------------------------------------
-- 文件名　：guwang.lua
-- 文件描述：蛊王
-- 创建者　：ZhangDeheng
-- 创建时间：2008-11-27 11:19:16
-----------------------------------------------------------

-- 蛊王
local tbGuWang = Npc:GetClass("guwang");

-- 转变的NPC
tbGuWang.tbChangeNpcTemplateId 	= {4156, 4157, 4158, 4159, 4160, 4161, 4162};
-- 蛊神
tbGuWang.tbGuSheng				= {4153, 1820, 2841};

tbGuWang.tbText = {
	{"你们很快就会明白，什么是差距！", "实力的差距！就是这样！"},
	{"看看这是谁？", "不要动手啊！", "是我啊！我怎么会在这里？", "快停手，我们怎么可以自相残杀？", "住手，这是蛊王的阴谋啊！", "你们怎么不相信我？"},
	{"童儿，难道你真的忍心看着我就这样死去吗？", "事由你咎由自取怎么能怨我？", "求求你了，帮帮我吧！", "好吧，天意最终难违！", "你要做好准备！",},
	{{"这就是天意！", "蛊神"}, {"我怎么都想不到！", "我竟然还会有这么一天！", "被这些毛头小子打败！"}},
}

function tbGuWang:OnDeath(pNpc)
	local nEntryWayRate = MathRandom(100);
	
	KNpc.Add2(2793, 1, -1, him.nMapId, 1820, 2836); 
	
	local pPlayer  	= pNpc.GetPlayer();
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return;
	end
	local tbPlayList, nCount = KPlayer.GetMapPlayer(tbInstancing.nMapId);
	
	
	
	-- 用于老玩家召回任务完成任务记录
--	local tbMemberList = pPlayer.GetTeamMemberList();	
	for _, player in ipairs(tbPlayList) do 
		Task.OldPlayerTask:AddPlayerTaskValue(player.nId, 2082, 4);
	end;
					
	-- 增加队长的领袖荣誉
	local tbHonor = {[3] = 24, [4] = 36, [5] = 48, [6] = 60}; -- 3、4、5、6人队长的领袖荣誉表
	local tbTeamPlayer, _ = KTeam.GetTeamMemberList(pPlayer.nTeamId);
	local _, nCount = KPlayer.GetMapPlayer(tbInstancing.nMapId);	
	if tbHonor[nCount] and tbTeamPlayer then
		PlayerHonor:AddPlayerHonorById_GS(tbTeamPlayer[1], PlayerHonor.HONOR_CLASS_LINGXIU, 0, tbHonor[nCount]);
	end
	
		-- 四次任务
	for _, player in ipairs(tbPlayList) do 
		local tbPlayerTasks	= Task:GetPlayerTask(player).tbTasks;
		local tbTask1 = tbPlayerTasks[381];
		local tbTask2 = tbPlayerTasks[429];
		local tbTask3 = tbPlayerTasks[490];
		local tbTask4 = tbPlayerTasks[488];
		if ((tbTask1 and tbTask1.nReferId == 565) or (tbTask2 and tbTask2.nReferId == 622) 
			or (tbTask3 and tbTask3.nReferId == 703) or (tbTask4 and tbTask4.nReferId == 701)) then
			player.SetTask(1022, 201, player.GetTask(1022, 201) + 1);
		end;
		
		-- 额外奖励回调
		local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("ArmyCampBoss", player);
		SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
		
		--通过军营累积次数
		local nTimes = player.GetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_OVER_ARMY);
		player.SetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_OVER_ARMY, nTimes + 1);
		
		-- 成就，通过百蛮山
		Achievement:FinishAchievement(player, 249);
		Achievement:FinishAchievement(player, 250);
		-- 记录杀死boss的log
		StatLog:WriteStatLog("stat_info", "junying", "killboss", player.nId, player.GetHonorLevel(), pPlayer.nTeamId, him.nTemplateId, tbInstancing.szOpenTime);
		
		-- 完成军营任务记录次数
		Player:AddJoinRecord_DailyCount(player, Player.EVENT_JOIN_RECORD_JUNYINGRENWU, 1);
		
		SpecialEvent.ActiveGift:AddCounts(player, 26);		--完成军营活跃度
		SpecialEvent.BuyOver:AddCounts(pPlayer, SpecialEvent.BuyOver.TASK_QUANDOANH);
	end;
	-- 检查日常任务
	for _, player in ipairs(tbPlayList) do 
		if XiakeDaily:CheckHasTask(player, 1, 2) == 1 then
			-- 刷出开启侠客任务的npc
			local pStone = KNpc.Add2(7347, 1, -1, nSubWorld, 1820, 2846);
			local tbNpcData = pStone.GetTempTable("Task");
			tbNpcData.nType = 2;
			tbNpcData.nRefreshPlayerId = player.nId;
			tbNpcData.nRefreshMapId	= nSubWorld;
			tbNpcData.nRefreshNpcPosX = 1820;
			tbNpcData.nRefreshNpcPosY = 2846;
			return 0;
		end
	end
	if (nEntryWayRate < 50) then	
		-- 开出秘径
		
		local pEntryway = KNpc.Add2(4176, 110, -1, him.nMapId, 1820, 2846);
		local tbNpcData = pEntryway.GetTempTable("Task");
		tbNpcData.nEntrancePlayerId = pPlayer.nId;
		
		for _, teammate in ipairs(tbPlayList) do
			Task.tbArmyCampInstancingManager:ShowTip(teammate, "Một lối đi thần bí xuất hiện.");
		end;
	end;
end;

-- 血量触发
function tbGuWang:OnLifePercentReduceHere(nLifePercent)
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return;	
	end
	--assert(tbInstancing);
	-- 血量第一次到达75或50 ，变成别的NPC，记录血量
	if ((nLifePercent == 75 and tbInstancing.nGuWangChange75 == 0) or (nLifePercent == 50 and tbInstancing.nGuWangChange50 == 0)) then
		if (nLifePercent == 75) then
			tbInstancing.nGuWangChange75 = 1;
		end;
		if (nLifePercent == 50) then
			tbInstancing.nGuWangChange50 = 1;
		end;
		local nNpcNo =  MathRandom(7);
		local nSubWorld, nPosX, nPosY	= him.GetWorldPos();
		local pNpc = KNpc.Add2(self.tbChangeNpcTemplateId[nNpcNo], tbInstancing.nNpcLevel, -1, nSubWorld, nPosX, nPosY);
		assert(pNpc);
		
		tbInstancing:NpcSay(pNpc.dwId, self.tbText[2]);
		pNpc.AddLifePObserver(10);
		pNpc.GetTempTable("Task").nNpcId	= pNpc.dwId;
		pNpc.GetTempTable("Task").nGuWangCurLife = him.nCurLife; 
		him.Delete();
	elseif(nLifePercent == 30 and tbInstancing.nGuShenOut == 0) then -- 血量在10%的时候召唤蛊王
		tbInstancing.nGuShenOut = 1;
		local pNpc = KNpc.Add2(self.tbGuSheng[1], tbInstancing.nNpcLevel, -1, nSubWorld, self.tbGuSheng[2], self.tbGuSheng[3]);
		assert(pNpc);
		
		self:OnLifePercent10Say(him.dwId, pNpc.dwId); -- 蛊王与蛊神对话
	elseif (tbInstancing.nGuWangLife99 == 0) then -- 开始打的时候的对话
		tbInstancing:NpcSay(him.dwId, self.tbText[1]);
		tbInstancing.nGuWangLife99 = 1;
	end;
end;
	
function tbGuWang:OnLifePercent10Say(nGuWangId, nGuShenId)
	if (not nGuWangId or not nGuShenId) then
		return;
	end;
	local pNpc = KNpc.GetById(nGuWangId);
	if (not pNpc) then
		return;
	end;
	local nSubWorld, _, _	= pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return;
	end
	--assert(tbInstancing);
	
	tbInstancing.nNpcSayTimerId2 	= Timer:Register(Env.GAME_FPS * 2, self.OnBreathDialog, self, nGuWangId, nGuShenId);
	tbInstancing.nCount				= 0;
end;

function tbGuWang:OnBreathDialog(nGuWangId, nGuShenId)
	assert(nGuWangId and nGuShenId);

	local pNpc = KNpc.GetById(nGuWangId);
	if (not pNpc) then
		return 0;
	end;
	local nSubWorld, _, _	= pNpc.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	--	assert(tbInstancing); -- 改成 RETURN zounan
	
	if not tbInstancing then
		return 0;
	end
	tbInstancing.nCount = tbInstancing.nCount or 0;
	tbInstancing.nCount = tbInstancing.nCount + 1;
	if (tbInstancing.nCount >#self.tbText[3]) then
		return 0;
	end;
	
	-- nNpcId用来区分由谁说出
	local nNpcId = 0;
	if (tbInstancing.nCount == #self.tbText[3]) then
		nNpcId = nGuShenId;
		return 0;
	elseif (tbInstancing.nCount % 2 == 0) then
		nNpcId = nGuShenId;
	else
		nNpcId = nGuWangId;
	end;
	
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return 0;
	end;
		
	pNpc.SendChat(self.tbText[3][tbInstancing.nCount]);
	local tbPlayList, nCount = KPlayer.GetMapPlayer(pNpc.nMapId);
	for _, teammate in ipairs(tbPlayList) do
			teammate.Msg(self.tbText[3][tbInstancing.nCount], pNpc.szName);
	end;
	
end;

-- 变成的NPC
local tbNpc = Npc:GetClass("guwang_npc");

function tbNpc:OnLifePercentReduceHere(nLifePercent)
	local tbNpcData = him.GetTempTable("Task");
	if (not tbNpcData or him.dwId ~= tbNpcData.nNpcId) then
		return;
	end;
	
	local nSubWorld, nPosX, nPosY	= him.GetWorldPos();
	
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return;
	end
	--assert(tbInstancing);	
	
	local pGuWang = KNpc.Add2(4152, tbInstancing.nNpcLevel, -1, nSubWorld, nPosX, nPosY);
	assert(pGuWang);
	
	local nReduct = pGuWang.nMaxLife - tbNpcData.nGuWangCurLife;
	pGuWang.ReduceLife(nReduct);
	
	if (tbNpcData.nGuWangCurLife > 50) then
		pGuWang.AddLifePObserver(50);
		pGuWang.AddLifePObserver(30);
	else
		pGuWang.AddLifePObserver(30);
	end;
	
	if (him) then
		him.Delete();
	end;
end;


-- 蛊神
local tbGuSheng = Npc:GetClass("gushen");

function tbGuSheng:OnDeath(pNpc)
end;

-- 天绝峰指引
local tbTianJueGongZhiYin = Npc:GetClass("tianjuegongzhiyin");

tbTianJueGongZhiYin.szText = "    此地为蛊王修炼之地，蛊王此时正在闭关。蛊王蛊术全靠本命蛊神，蛊神的力量来自于天绝峰周围小峰上的幻影浮灯。这些浮灯按照五行相生的顺序互相作用，由五位长老看守。只需将五盏浮灯按五行相克的顺序一一转动，即可发挥妙用，蛊王也将在此时出现。\n\n    浮灯在打败看守的长老之后才会显影，这些长老精通隐遁之术，这点需要切记。<color=red>开启浮灯需从金开始，以金、木、土、水、火的顺序开启，万不可更改次序！<color>";

function tbTianJueGongZhiYin:OnDialog()
	local tbOpt = {{"Kết thúc đối thoại"}, };
	Dialog:Say(self.szText, tbOpt);
end;

-- 禁地之门
local tbJinDiZhiMen = Npc:GetClass("jindizhimen");

function tbJinDiZhiMen:OnDialog()
	local tbNpcData = him.GetTempTable("Task");
	assert(tbNpcData.nEntrancePlayerId);
	local pOpener = KPlayer.GetPlayerObjById(tbNpcData.nEntrancePlayerId);
	if (not pOpener) then
		return;
	end
	
	local nTeamId = pOpener.nTeamId;
	
	if (me.nTeamId == 0) then
		local szMsg = "只有组队才能进入！"
		Dialog:SendInfoBoardMsg(me, szMsg);
		return;
	end
	
	if (me.nTeamId ~= nTeamId) then
		local szMsg = "只有<color=yellow>"..pOpener.szName.."<color>所在的队伍才能进入！"
		Dialog:SendInfoBoardMsg(me, szMsg);
		return;
	end
	
	local nEntryMapId = tbNpcData.nEntryMapId;

	Dialog:Say("是否现在进入？", 
		{"好", self.Enter, self, me, him.dwId, him.nMapId},
		{"暂时不去"})
end;

function tbJinDiZhiMen:Enter(pPlayer, nNpcId, nEntryMapId)
	pPlayer.NewWorld(nEntryMapId, 1874, 2825);
	pPlayer.SetFightState(1);
end