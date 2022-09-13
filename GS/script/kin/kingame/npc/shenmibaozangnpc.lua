local tbNpc = Npc:GetClass("shenmibaozangnpc")

function tbNpc:OnDeath()
	KinGame:NpcUnLockMulti(him);	
end

local tbYouhun = Npc:GetClass("mingfuyouhun");

function tbYouhun:OnDeath()
	local pGame =  KinGame:GetGameObjByMapId(him.nMapId)
	if not pGame then
		return;
	end
	local tbPlayer = pGame:GetPlayerList() or {};
	pGame:KinGame_StatLog_KinLog_KillBoss(1);
	for _, pPlayer in pairs(tbPlayer) do
		if pPlayer.nLevel < 60 then
			pPlayer.AddKinReputeEntry(5, "kingame");
		elseif pPlayer.nLevel < 80 then
			pPlayer.AddKinReputeEntry(3, "kingame");
		end
		
		--玩家是否通过家族关卡
		pPlayer.SetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_OVER_KINGAME, 1);
		
		-- 成就，家族关卡通关
		Achievement:FinishAchievement(pPlayer, 46);
		Achievement:FinishAchievement(pPlayer, 47);
		Achievement:FinishAchievement(pPlayer, 48);
		
		local tbInfo = Kinsalary.EVENT_TYPE[Kinsalary.EVENT_GUANQIA];
		Kinsalary:AddSalary_GS(pPlayer, Kinsalary.EVENT_GUANQIA, tbInfo.nRate);
	end
	--圣诞活动额外插入
	if SpecialEvent.Xmas2011:IsEventOpen() == 1 then
		local nLevel = him.nLevel;
		local nMapId,nX,nY = him.GetWorldPos();
		SpecialEvent.Xmas2011:AddKinGameXmasBoss(1,nLevel,nMapId,nX,nY);
		local tbPlayer,nCount = pGame:GetPlayerList();
		for _,pPlayer in pairs(tbPlayer) do
			if pPlayer then
				Dialog:SendBlackBoardMsg(pPlayer,"圣诞Boss即将出现，请大家做好迎战准备！");
			end
		end
	end
	KinGame:NpcUnLockMulti(him);
end
