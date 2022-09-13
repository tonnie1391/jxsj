--官府通缉，boss掉落
--孙多良
--2008.08.13

local tbBoss = Npc:GetClass("wanted")
tbBoss.nExpGrade = {[55] = 100000, [65] = 120000, [75] = 140000, [85] = 160000, [95] = 180000, [120] = 300000};

function tbBoss:OnDeath(pNpc)
	if not Wanted.DROPRATE[him.nLevel] then
		return
	end
	local pPlayer = pNpc.GetPlayer();
	if not pPlayer then
		return
	end
	DataLog:WriteELog(pPlayer.szName, 3, 2, him.nTemplateId);
	
	local tbStudentList 	= {};
	local tbTeammateList 	= {};
	local tbPlayerList = {};
	local bTeamHaveTask = 0;
	-- 队友计数
	local tbTeamMembers, nMemberCount	= pPlayer.GetTeamMemberList();
	self:AddFriendFavor(tbTeamMembers, nMemberCount);
	local nFlag, nHaveTaskCount = self:TeamFinishTask(pPlayer, tbTeamMembers, nMemberCount);
	if nFlag == 1 then
		bTeamHaveTask = 1;
	end
	
	--杀死Boss玩家身上有任务而且第一次完成使调用
	if self:MyFinishTask(pPlayer, nHaveTaskCount) == 1 then
		bTeamHaveTask = 1;
	end
	
	if bTeamHaveTask == 1 then
		
		--额外召回boss
		self:CallAdvBoss(pPlayer)
		
		--数据统计--队伍内有玩家有任务的情况杀死boss

		local tbDataLog = {};
		
		if (not tbTeamMembers) then
			table.insert(tbDataLog, pPlayer.szName);
		else
			for _, pLogPlayer in pairs(tbTeamMembers) do
				table.insert(tbDataLog, pLogPlayer.szName);
			end
		end
		DataLog:WriteELog(pPlayer.szName, 3, 5, him.nTemplateId, (pPlayer.nTeamId or 0), unpack(tbDataLog));
		--数据统计
	end

end

function tbBoss:TeamFinishTask(pPlayer, tbTeamMembers, nMemberCount)
	local bTeamHaveTask = 0;
	if (not tbTeamMembers) then
		return 0, 0;
	end
	local nHaveTaskNum = 0;
	local nExp = self.nExpGrade[him.nLevel] or 0;
	
	for i = 1, nMemberCount do
		if (Task:AtNearDistance(pPlayer, tbTeamMembers[i]) == 1) then
			if Task:GetPlayerTask(tbTeamMembers[i]).tbTasks[Wanted.TASK_MAIN_ID] then
				for _, tbCurTag in ipairs(Task:GetPlayerTask(tbTeamMembers[i]).tbTasks[Wanted.TASK_MAIN_ID].tbCurTags) do
					if (tbCurTag.OnKillNpc) then
						--杀死Boss玩家的队友身上有任务完成时调用	
						if tbTeamMembers[i].GetTask(Wanted.TASK_GROUP, Wanted.TASK_FINISH) == 1 then
							nHaveTaskNum = nHaveTaskNum + 1;
						end
					end
				end
			end
		end
	end
	
	for i = 1, nMemberCount do
		if (pPlayer.nPlayerIndex ~= tbTeamMembers[i].nPlayerIndex) and 
		(Task:AtNearDistance(pPlayer, tbTeamMembers[i]) == 1) and
		Task:GetPlayerTask(tbTeamMembers[i]).tbTasks[Wanted.TASK_MAIN_ID] then
			for _, tbCurTag in ipairs(Task:GetPlayerTask(tbTeamMembers[i]).tbTasks[Wanted.TASK_MAIN_ID].tbCurTags) do
				if (tbCurTag.OnKillNpc) then
					if (tbCurTag:IsDone()) then
						--杀死Boss玩家的队友身上有任务完成时调用	
						if tbTeamMembers[i].GetTask(Wanted.TASK_GROUP, Wanted.TASK_FINISH) == 1 then
							tbTeamMembers[i].SetTask(Wanted.TASK_GROUP, Wanted.TASK_FINISH, 0);
							if math.floor(him.nLevel / 10) == math.floor(tbTeamMembers[i].nLevel / 10) or him.nLevel >= 95 then
								tbTeamMembers[i].AddKinReputeEntry(1, "tongji");  		-- 符合等级段加威望
							end
																
							if nExp > 0 and nHaveTaskNum > 0 then
								tbTeamMembers[i].AddExp(math.floor(nExp / nHaveTaskNum));
							end
										
							-- 用于老玩家召回任务完成任务记录
							Task.OldPlayerTask:AddPlayerTaskValue(tbTeamMembers[i].nId, 2082, 2);
							bTeamHaveTask = 1;
						end
						break;
					end;

					if (tbCurTag.nNpcTempId ~= him.nTemplateId) then
						break;
					end;
					if (tbCurTag.nMapId ~= 0 and tbCurTag.nMapId ~= him.nMapId) then
						
						break;
					end;
					
					tbCurTag.nCount	= tbCurTag.nCount + 1;		
					local tbSaveTask	= tbCurTag.tbSaveTask;
					if (MODULE_GAMESERVER and tbSaveTask) then	-- 自行同步到客户端，要求客户端刷新
						tbCurTag.me.SetTask(tbSaveTask.nGroupId, tbSaveTask.nStartTaskId, tbCurTag.nCount, 1);
						KTask.SendRefresh(tbCurTag.me, tbCurTag.tbTask.nTaskId, tbCurTag.tbTask.nReferId, tbSaveTask.nGroupId);
					end;
									
					if (tbCurTag:IsDone()) then	-- 本目标是一旦达成后不会失效的
						tbCurTag.me.Msg("Mục tiêu: "..tbCurTag:GetStaticDesc());
						tbCurTag.tbTask:OnFinishOneTag();
					end;
					
					--杀死Boss玩家的队友身上有任务完成时调用				
					if tbTeamMembers[i].GetTask(Wanted.TASK_GROUP, Wanted.TASK_FINISH) == 1 then
						tbTeamMembers[i].SetTask(Wanted.TASK_GROUP, Wanted.TASK_FINISH, 0);
						if math.floor(him.nLevel / 10) == math.floor(tbTeamMembers[i].nLevel / 10) or him.nLevel >= 95 then
							tbTeamMembers[i].AddKinReputeEntry(1, "tongji");  		-- 符合等级段加威望
						end
						
						if nExp > 0 and nHaveTaskNum > 0 then
							tbTeamMembers[i].AddExp(math.floor(nExp / nHaveTaskNum));
						end
						
						-- 用于老玩家召回任务完成任务记录
						Task.OldPlayerTask:AddPlayerTaskValue(tbTeamMembers[i].nId, 2082, 2);
						
						bTeamHaveTask = 1;
					end
				end
			end
		end
	end
	return bTeamHaveTask, nHaveTaskNum;
end

function tbBoss:MyFinishTask(pPlayer, nHaveTaskCount)
	local bTeamHaveTask = 0;
	local nExp = self.nExpGrade[him.nLevel] or 0;
	if Task:GetPlayerTask(pPlayer).tbTasks[Wanted.TASK_MAIN_ID] then
		for _, tbCurTag in ipairs(Task:GetPlayerTask(pPlayer).tbTasks[Wanted.TASK_MAIN_ID].tbCurTags) do
			if (tbCurTag.OnKillNpc) then
				if (tbCurTag.nNpcTempId ~= him.nTemplateId) then
					break;
				end;
				if (tbCurTag.nMapId ~= 0 and tbCurTag.nMapId ~= him.nMapId) then
					break;
				end;
				if pPlayer.GetTask(Wanted.TASK_GROUP, Wanted.TASK_FINISH) == 1 then
					local nLuck = Wanted.DROPLUCK + pPlayer.nCurLucky;
					if type(Wanted.DROPRATE[him.nLevel]) == "string" then
						pPlayer.DropRateItem(Wanted.DROPRATE[him.nLevel], 16, nLuck, -1, him);
					end
					pPlayer.SetTask(Wanted.TASK_GROUP, Wanted.TASK_FINISH, 0);
					if math.floor(him.nLevel / 10) == math.floor(pPlayer.nLevel / 10) or him.nLevel >= 95 then
						pPlayer.AddKinReputeEntry(1, "tongji");		-- 符合等级段加威望
					end	
					
					if nHaveTaskCount and nExp > 0 then
						if nHaveTaskCount > 1 then
							nExp = math.floor(nExp / nHaveTaskCount);
						end
						pPlayer.AddExp(nExp);
					end
					
					-- 用于老玩家召回任务完成任务记录
					Task.OldPlayerTask:AddPlayerTaskValue(pPlayer.nId, 2082, 2);
					
					--额外掉落
					local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("WantedBoss", pPlayer);
					SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
					bTeamHaveTask = 1;
				end
			end
		end;
	end
	return bTeamHaveTask;
end

function tbBoss:CallAdvBoss(pPlayer)
	local nTaskId = Wanted.Npc2TaskId[him.nTemplateId]
	if nTaskId and Wanted.TaskFile[nTaskId] then
		local nRandCallBoss = Wanted.TaskFile[nTaskId].nRandCallBoss;
		local nBossId		= Wanted.TaskFile[nTaskId].nBossId;
		local nMapId		= Wanted.TaskFile[nTaskId].nMapId;
		local nPosX			= Wanted.TaskFile[nTaskId].nPosX;
		local nPosY			= Wanted.TaskFile[nTaskId].nPosY;
		if nRandCallBoss > 0 and nBossId > 0 then
			local pCur = MathRandom(1,1000000);
			if pCur <= nRandCallBoss then
				--to do 按概率加npc
				local pNpc = KNpc.Add2(nBossId, him.nLevel, -1, nMapId, nPosX, nPosY, 0, 1);
				if pNpc then
					local szMsg = string.format("%s在<color=green>%s(%s,%s)<color>抓住了大盗<color=white>%s<color>时，突然大盗叫来了他们的头领<color=white>%s<color>！", 
					pPlayer.szName, GetMapNameFormId(nMapId), math.floor(nPosX/8), math.floor(nPosY/16), him.szName, pNpc.szName);
					KDialog.NewsMsg(0, Env.NEWSMSG_COUNT, szMsg);
					KDialog.MsgToGlobal(szMsg);
				end	
			end
		end
	end
end

function tbBoss:HaveTag(pPlayer)
	local bRet = 0;
	if Task:GetPlayerTask(pPlayer).tbTasks[Wanted.TASK_MAIN_ID] and pPlayer.GetTask(Wanted.TASK_GROUP, Wanted.TASK_FINISH) == 1 then
		for _, tbCurTag in ipairs(Task:GetPlayerTask(pPlayer).tbTasks[Wanted.TASK_MAIN_ID].tbCurTags) do
			if (tbCurTag.OnKillNpc) then
				if (tbCurTag.nNpcTempId ~= him.nTemplateId) then
					break;
				end;
				if (tbCurTag.nMapId ~= 0 and tbCurTag.nMapId ~= him.nMapId) then
					break;
				end;
				bRet = 1;
			end		
		end
	end
	return bRet;	
end

function tbBoss:AddFriendFavor(tbTeamMembers, nMemberCount)
	if (not tbTeamMembers) then
		return; 
	end
	
	local tbTaskTeam = {};
	for i =1, nMemberCount do 
		if (self:HaveTag(tbTeamMembers[i]) == 1) then
			table.insert(tbTaskTeam, tbTeamMembers[i]);
		end
	end
	
	for i =1, #tbTaskTeam do 
		for j = i + 1, #tbTaskTeam do
			if (tbTaskTeam[i].IsFriendRelation(tbTaskTeam[j].szName) == 1) then
				Relation:AddFriendFavor(tbTaskTeam[i].szName, tbTaskTeam[j].szName, 20);
				tbTaskTeam[i].Msg(string.format("您与<color=yellow>%s<color>好友亲密度增加了%d点。", tbTaskTeam[j].szName, 20));
				tbTaskTeam[j].Msg(string.format("您与<color=yellow>%s<color>好友亲密度增加了%d点。", tbTaskTeam[i].szName, 20));
			end
		end
	end
end