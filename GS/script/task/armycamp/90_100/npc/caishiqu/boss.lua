
-- 第二层左边的 BOSS
local tbNpc_1	= Npc:GetClass("caishiquboss");

tbNpc_1.ENTRYWAY_RATE =  50; --打死BOSS后出现秘径的概率

function tbNpc_1:OnDeath(pNpc)
	local nSubWorld, nNpcPosX, nNpcPosY	= him.GetWorldPos();

	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	if not tbInstancing then
		return 0;
	end
	assert(tbInstancing);
	tbInstancing.nCaiShiQuPass = 1;
	local pPlayer  	= pNpc.GetPlayer();
	
	
	
	KNpc.Add2(2793, 1, -1, nSubWorld, 1694, 3862);
	local tbPlayList, nCount = KPlayer.GetMapPlayer(tbInstancing.nMapId)
	
	-- 用于老玩家召回任务完成任务记录
--	local tbMemberList = pPlayer.GetTeamMemberList();	
	for _, player in ipairs(tbPlayList) do 
		Task.OldPlayerTask:AddPlayerTaskValue(player.nId, 2082, 4);
	end;
	
	-- 增加队长的领袖荣誉
	local tbHonor = {[3] = 24, [4] = 36, [5] = 48, [6] = 60}; -- 3、4、5、6人队长的领袖荣誉表
	local tbTeamPlayer, _ = KTeam.GetTeamMemberList(pPlayer.nTeamId);	
	if tbHonor[nCount] and tbTeamPlayer then
		PlayerHonor:AddPlayerHonorById_GS(tbTeamPlayer[1], PlayerHonor.HONOR_CLASS_LINGXIU, 0, tbHonor[nCount]);
	end
	
	-- 四次任务
	for _, player in ipairs(tbPlayList) do 
		local tbPlayerTasks	= Task:GetPlayerTask(player).tbTasks;
		local tbTask1 = tbPlayerTasks[381];
		local tbTask2 = tbPlayerTasks[429]
		local tbTask3 = tbPlayerTasks[490];
		local tbTask4 = tbPlayerTasks[488];
		if ((tbTask1 and tbTask1.nReferId == 565) or (tbTask2 and tbTask2.nReferId == 622)
			or (tbTask3 and tbTask3.nReferId == 703) or (tbTask4 and tbTask4.nReferId == 701)) then
			player.SetTask(1022, 200, player.GetTask(1022, 200) + 1);
		end;
		
		-- 额外奖励回调
		local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("ArmyCampBoss", player);
		SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
		
		--通过军营累积次数
		local nTimes = player.GetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_OVER_ARMY);
		player.SetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_OVER_ARMY, nTimes + 1);
		
		-- 成就，通过伏牛山
		Achievement:FinishAchievement(player, 243);
		Achievement:FinishAchievement(player, 244);
		-- 记录杀死boss的log
		StatLog:WriteStatLog("stat_info", "junying", "killboss", player.nId, player.GetHonorLevel(), pPlayer.nTeamId, him.nTemplateId, tbInstancing.szOpenTime);
		-- 完成军营任务记录次数
		Player:AddJoinRecord_DailyCount(player, Player.EVENT_JOIN_RECORD_JUNYINGRENWU, 1);
		
		SpecialEvent.ActiveGift:AddCounts(player, 26);		--完成军营活跃度
		SpecialEvent.BuyOver:AddCounts(pPlayer, SpecialEvent.BuyOver.TASK_QUANDOANH);
	end;
	Task.ArmyCamp:ClearData(him.dwId);
	for _, player in ipairs(tbPlayList) do 
		if XiakeDaily:CheckHasTask(player, 1, 1) == 1 then
			-- 刷出开启侠客任务的npc
			local pStone = KNpc.Add2(7347, 1, -1, nSubWorld, nNpcPosX, nNpcPosY);
			local tbNpcData = pStone.GetTempTable("Task");
			tbNpcData.nType	= 1;
			tbNpcData.nRefreshPlayerId = player.nId;
			tbNpcData.nRefreshMapId	= nSubWorld;
			tbNpcData.nRefreshNpcPosX = 1680;
			tbNpcData.nRefreshNpcPosY = 3817;
			return 0;
		end
	end
	
	local nEntryWayRate = MathRandom(100);
	if (self.ENTRYWAY_RATE > nEntryWayRate) then	
		-- 开出秘径
		
		local pEntryway = KNpc.Add2(4114, 1, -1, nSubWorld, nNpcPosX, nNpcPosY);
		local tbNpcData = pEntryway.GetTempTable("Task");
		tbNpcData.nEntrancePlayerId = pPlayer.nId;
		tbNpcData.nEntryMapId	= nSubWorld;
		KTeam.Msg2Team(pPlayer.nTeamId, pPlayer.szName.."发现了通往伏牛山庄的秘径！");
	end;
end

