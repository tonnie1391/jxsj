
-- 副本入口Npc
local tbInstancingEntrancePoint = Npc:GetClass("instancingentrancepoint");

function tbInstancingEntrancePoint:OnDialog()
	local tbNpcData = him.GetTempTable("TreasureMap");
	assert(tbNpcData.nEntrancePlayerId);
	local pOpener = KPlayer.GetPlayerObjById(tbNpcData.nEntrancePlayerId);
	if (not pOpener) then
		return;
	end
	
	local nTeamId = pOpener.nTeamId;
	
	if (me.nTeamId == 0) then
		local szMsg = "只有组队才能进入此地底迷宫！"
		Dialog:SendInfoBoardMsg(me, szMsg);
		return;
	end
	
	if (me.nTeamId ~= nTeamId) then
		local szMsg = "只有<color=yellow>"..pOpener.szName.."<color>所在的队伍才能进入此地底迷宫！"
		Dialog:SendInfoBoardMsg(me, szMsg);
		return;
	end
	
	-- 进入副本的等级限制
	local tbLevelLimit	= {
		[1] = 50,
		[2]	= 80,
		[3]	= 151,	
	}
	
	local nTreasureId 		= tbNpcData.nEntranceTreasureId;
	local nTreasureMapId 	= tbNpcData.nTreasureMapId;
	local nTreasureMapLevel	= tbNpcData.nTreasureMapLevel;
	local nMapTemplateId 	= tbNpcData.nMapTemplateId;
	
	if tbLevelLimit[nTreasureMapLevel] then
		if me.nLevel >= tbLevelLimit[nTreasureMapLevel] then
			Dialog:SendInfoBoardMsg(me, "您的等级不适合进入此副本！");
			return;
		end;
	end;
	
	Dialog:Say("是否现在进入副本？", 
		{"好", self.Enter, self, me.nId, him.dwId, nTreasureId, nTreasureMapId, nMapTemplateId},
		{"暂时不去"})
end

function tbInstancingEntrancePoint:Enter(nPlayerId, nNpcId, nTreasureId, nTreasureMapId, nMapTemplateId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	assert(pPlayer);
	local pNpc = KNpc.GetById(nNpcId);
	if (TreasureMap:IsInstancingFree(nTreasureId, nTreasureMapId) == 1) then
		pPlayer.Msg("<color=yellow>你所发现的地底迷宫已经倒塌！<color>");
		if (pNpc) then
			pNpc.Delete();
		end
		return;
	end
	
	local tbInstancing = TreasureMap.InstancingMgr:GetInstancing(nTreasureMapId);
	if (not tbInstancing) then
		assert(false);
	end
	
	
	local tbTreasureInfo = TreasureMap:GetTreasureInfo(nTreasureId);
	
	-- 第一次进入

	if (not tbInstancing.tbPlayerList[nPlayerId]) then
		local nEnterTimes = pPlayer.GetTask(2066, tbTreasureInfo.InstancingMapId);
		local nLimitTimes = tbTreasureInfo.EnterLimtPerWeek;

		if (nLimitTimes > 0 and nEnterTimes >= nLimitTimes) then
			Dialog:SendInfoBoardMsg(pPlayer, "此副本每周只能进入<color=yellow> "..nLimitTimes.." <color>次。")
			return;
		end
		
		local nPlayerCount = 0;
		for _,_ in pairs(tbInstancing.tbPlayerList) do
			nPlayerCount = nPlayerCount + 1;
		end
		
		if (nPlayerCount >= TreasureMap.nMaxPlayer) then
			Dialog:SendInfoBoardMsg(pPlayer, "该副本进入人数已满 <color=yellow>"..nPlayerCount.."<color>人。")
			return;
		end
		
		-- 在这里设置每一个进入副本的队友状态（除了副本主人之外）
		-- 不是副本的主人，并且队友任务状态已经是 0
		if TreasureMap.TSK_INS_TBTASK[nMapTemplateId] then
		
			local nMainTaskState 	= pPlayer.GetTask(TreasureMap.TSKGID, TreasureMap.TSK_INS_TBTASK[nMapTemplateId][1]);
			local nTeamTaskState 	= pPlayer.GetTask(TreasureMap.TSKGID, TreasureMap.TSK_INS_TBTASK[nMapTemplateId][2]);
			
			local nHaveMainTask		= Task:HaveTask(pPlayer, TreasureMap.TSK_INS_TBTASK[nMapTemplateId][3]);
			local nHaveTeamTask		= Task:HaveTask(pPlayer, TreasureMap.TSK_INS_TBTASK[nMapTemplateId][4]);

			
			-- 对队友任务异常作除错（变量大于 1 但身上没任务）
			if nHaveTeamTask == 0 and nTeamTaskState>1 then
				print("藏宝图队友任务异常，做除错处理：", nMapTemplateId);
				nTeamTaskState = 0;
			end;
			
			if nMainTaskState ~=1 and nTeamTaskState <= 1 then
				pPlayer.SetTask(TreasureMap.TSKGID, TreasureMap.TSK_INS_TBTASK[nMapTemplateId][2], 1, 1);
			end;
			
		end;
		
		pPlayer.SetTask(2066, tbTreasureInfo.InstancingMapId,  nEnterTimes + 1, 1);
	end
	
	tbInstancing.tbPlayerList[nPlayerId] = 1;
	pPlayer.NewWorld(nTreasureMapId, tbTreasureInfo.InstancingMapX, tbTreasureInfo.InstancingMapY);
	TreasureMap:SetMyInstancingTreasureId(pPlayer, nTreasureId);
	pPlayer.SetFightState(1);
end
