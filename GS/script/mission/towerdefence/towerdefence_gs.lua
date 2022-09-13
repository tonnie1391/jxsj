--竞技赛GS
--孙多良
--2008.12.25

if (MODULE_GC_SERVER) then
	return 0;
end

--人数满，报名失败
function TowerDefence:SignUpFail(tbPlayerList)
	for _, nPlayerId in pairs(tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.Msg("参加报名的名额已满。");
			Dialog:SendBlackBoardMsg(pPlayer, "参加报名的名额已满")
			return 0;
		end
	end
end

--成功报名
function TowerDefence:SignUpSucess(nMapId, tbPlayerList)
	for _, nPlayerId in pairs(tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.NewWorld(nMapId, unpack(self.DEF_READY_POS[MathRandom(1,#self.DEF_READY_POS)]));
		end
	end
end

--进入准备场
function TowerDefence:OnEnterReady(pPlayer)
	pPlayer.ClearSpecialState()			--清除特殊状态
	pPlayer.RemoveSkillStateWithoutKind(Player.emKNPCFIGHTSKILLKIND_CLEARDWHENENTERBATTLE) --清除状态
	pPlayer.DisableChangeCurCamp(1);	--设置与帮会有关的变量，不允许在竞技场战改变某个帮会阵营的操作
	pPlayer.SetFightState(0);	  		--设置战斗状态
	pPlayer.SetLogoutRV(1);				--玩家退出时，保存RV并，在下次等入时用RV(城市重生点，非退出点)
	--pPlayer.SetLogOutState(Mission.LOGOUTRV_DEF_MISSION_ESPORT);			--设置还原状态; 地图OnEnter和LogIn顺序有错,临时去掉
	pPlayer.ForbidEnmity(1);			--禁止仇杀
	pPlayer.ForbidExercise(1);			--禁止切磋
	pPlayer.DisabledStall(1);			--摆摊
	pPlayer.ForbitTrade(1);				--交易
	pPlayer.nPkModel = Player.emKPK_STATE_PRACTISE;--关闭PK开关
	pPlayer.TeamDisable(1);				--禁止组队
	--pPlayer.TeamApplyLeave();			--离开队伍
	pPlayer.nForbidChangePK	= 1;		
end

--离开准备场
function TowerDefence:OnLeaveReady(pPlayer)
	pPlayer.SetFightState(0);
	pPlayer.SetCurCamp(pPlayer.GetCamp());
	pPlayer.DisableChangeCurCamp(0);
	pPlayer.nPkModel = Player.emKPK_STATE_PRACTISE;--关闭PK开关
	pPlayer.nForbidChangePK	= 0;
	pPlayer.SetDeathType(0);
	pPlayer.RestoreMana();
	pPlayer.RestoreLife();
	pPlayer.RestoreStamina();
	pPlayer.DisabledStall(0);	--摆摊
	if pPlayer.IsDisabledTeam() == 1 then
		pPlayer.TeamDisable(0);--禁止组队
	end	
	pPlayer.ForbitTrade(0);		--交易
	pPlayer.ForbidEnmity(0);
	pPlayer.ForbidExercise(0);
	pPlayer.SetLogOutState(0);			--设置还原状态

end

--离线或宕机恢复
function TowerDefence:LogOutRV()
	TowerDefence:OnLeaveReady(me);
	-- 打回原形
	if me.GetSkillState(TowerDefence.Mission.TRANSFORM_SKILL_ID) > 0 then
		me.RemoveSkillState(TowerDefence.Mission.TRANSFORM_SKILL_ID);
	end	
	--清除player加的技能
	for i = 1, #TowerDefence.Mission.PLAYER_SKILL_ID do
		if me.IsHaveSkill(TowerDefence.Mission.PLAYER_SKILL_ID[i]) == 1 then
			me.DelFightSkill(TowerDefence.Mission.PLAYER_SKILL_ID[i]);
		end
	end
	--清楚player吃符得到的技能
	for i = 1, #TowerDefence.Mission.PLAYER2NPC_SKILL_ID do
		if me.IsHaveSkill(TowerDefence.Mission.PLAYER2NPC_SKILL_ID[i]) == 1 then
			me.DelFightSkill(TowerDefence.Mission.PLAYER2NPC_SKILL_ID[i]);
		end
	end
	--清掉所有买的物品
	local tbTowerItem = me.FindClassItemInBags("tower_Item");
	local tbCanteen	=me.FindClassItemInBags("tower_canteen");
	local tbHoe = me.FindClassItemInBags("tower_hoe");
	for _,tbItem in ipairs (tbTowerItem) do
		tbItem.pItem.Delete(me);
	end
	for _,tbItem in ipairs (tbCanteen) do
		tbItem.pItem.Delete(me);
	end
	for _,tbItem in ipairs (tbHoe) do
		tbItem.pItem.Delete(me);
	end
	--清光环
	if me.FindTitle(unpack(TowerDefence.Mission.tbFirst_Title)) == 1 then
		me.RemoveTitle(unpack(TowerDefence.Mission.tbFirst_Title));
		me.SetCurTitle(0, 0, 0, 0);
	end
end


--比较开始匹配逻辑
function TowerDefence:SportStartLogic()
	for nMapId, tbGroup in pairs(self.tbGroupLists) do
		if SubWorldID2Idx(nMapId) > 0 then
			local tbGroupLists = self:LogicPreProcess(tbGroup);
			local tbGroupMatchList, tbGroupFlag = self:LogicBase(tbGroupLists);--基础分配逻辑
			local nCurMembers, nLastMembers = self:LogicGetLastSeries(tbGroupMatchList);
			self:LogicAvgTeam(tbGroupMatchList, tbGroupFlag, nLastMembers, nCurMembers);
			self:LogicCheckKickOut(tbGroupMatchList,nLastMembers, nCurMembers);--轮空处理
			self:LogicEnterGame(tbGroupMatchList, nMapId);--进场比赛
		end
	end
	return 0;
end

--预处理逻辑
function TowerDefence:LogicPreProcess(tbGroup)
	local tbGroupLists = {};
	for nMem=1, self.DEF_PLAYER_TEAM do
		tbGroupLists[nMem] = {};
	end
	for _, tbGroupTemp in ipairs(tbGroup.tbGroupList) do
		if #tbGroupTemp > 0 then
			table.insert(tbGroupLists[#tbGroupTemp], tbGroupTemp);
		end
	end
	
	--打乱原有顺序
	for _, tbGroups in ipairs(tbGroupLists) do
		for i in pairs(tbGroups) do
			local nP = MathRandom(1, #tbGroups);
			tbGroups[i], tbGroups[nP] = tbGroups[nP], tbGroups[i];
		end
	end
	return tbGroupLists;
end

--基础分配逻辑
function TowerDefence:LogicBase(tbGroupLists)
	--匹配原则。
	local tbGroupMatchList = {{}};
	local tbGroupFlag = {};
	local nGroupFlag = 0; 
	local nloop = 1;	--防止死循环,最多10000次循环
	while(self:CheckGroupLists(tbGroupLists)==1 and nloop <= 10000) do
		local nCurMembers = #tbGroupMatchList;
		
		--如果表中人员人数超过六个人,则新建下一个空表
		if #tbGroupMatchList[nCurMembers] >= self.DEF_PLAYER_TEAM then
			nCurMembers = nCurMembers + 1;
			tbGroupMatchList[nCurMembers] = {};
		end
		
		local nIsCreateNewGroup = 1;
		--查找符合条件的队伍加入表中
		for nMem = self.DEF_PLAYER_TEAM, 1, -1 do
			if #tbGroupLists[nMem] > 0 then
				if  #tbGroupLists[nMem][1] > 0 and #tbGroupMatchList[nCurMembers] + #tbGroupLists[nMem][1] <= self.DEF_PLAYER_TEAM then
					nGroupFlag = nGroupFlag + 1;
					for _, nId in pairs(tbGroupLists[nMem][1]) do
						tbGroupFlag[nId] = nGroupFlag;
						table.insert(tbGroupMatchList[nCurMembers], nId);
					end
					table.remove(tbGroupLists[nMem], 1);
					nIsCreateNewGroup = 0;
				end
			end
		end
		
		--没找到符合条件的队伍,则新建下一个空表
		if nIsCreateNewGroup == 1 then
			nCurMembers = nCurMembers + 1;
			tbGroupMatchList[nCurMembers] = {};
		end
		
		nloop = nloop + 1;
	end
	return tbGroupMatchList, tbGroupFlag;
end

function TowerDefence:LogicGetLastSeries(tbGroupMatchList)
	local nCurMembers = #tbGroupMatchList;
	if #tbGroupMatchList[nCurMembers] <= 0 then
		table.remove(tbGroupMatchList, nCurMembers);
	end
	
	nCurMembers = #tbGroupMatchList;
	local nLastMembers = nCurMembers - 1;
	if math.mod(nCurMembers, 2) ~= 0 or nCurMembers == 0 then
		nLastMembers = nCurMembers + 1;
	end
	return  nCurMembers, nLastMembers;
end

--最后两队伍平均分配
function TowerDefence:LogicAvgTeam(tbGroupMatchList, tbGroupFlag, nLastMembers, nCurMembers)
	--对最后匹配的2队进行平均分配
	
	local tbGroupA = tbGroupMatchList[nLastMembers] or {};
	local tbGroupB = tbGroupMatchList[nCurMembers] or {};
	local nMid = math.floor((#tbGroupA + #tbGroupB)/2);
	local tbFlag = {};
	for _, nId in pairs(tbGroupA) do
		tbFlag[tbGroupFlag[nId]] = tbFlag[tbGroupFlag[nId]] or {};
		table.insert(tbFlag[tbGroupFlag[nId]], nId);
	end
	for _, nId in pairs(tbGroupB) do
		tbFlag[tbGroupFlag[nId]] = tbFlag[tbGroupFlag[nId]] or {};
		table.insert(tbFlag[tbGroupFlag[nId]], nId);
	end
	tbGroupA = {};
	tbGroupB = {};
	for _, tbGroup in pairs(tbFlag) do
		if #tbGroupA <= nMid and (#tbGroupA + #tbGroup) <= nMid then
			for _, nId in pairs(tbGroup) do
				table.insert(tbGroupA, nId);
			end
		else
			for _, nId in pairs(tbGroup) do
				table.insert(tbGroupB, nId);
			end						
		end
	end
	tbGroupMatchList[nLastMembers] = tbGroupA;
	tbGroupMatchList[nCurMembers] = tbGroupB;
	return tbGroupMatchList;
end

--轮空处理
function TowerDefence:LogicCheckKickOut(tbGroupMatchList, nLastMembers, nCurMembers)
	local nLeaveMapId, nLeavePosX, nLeavePosY = TowerDefence:GetLeavePos()
	--轮空
	if #tbGroupMatchList[nLastMembers] <=0 or #tbGroupMatchList[nCurMembers] <= 0 then
		for _, nId in pairs(tbGroupMatchList[nLastMembers]) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer then
				pPlayer.Msg("很遗憾，你本场比赛轮空了。");
				Dialog:SendBlackBoardMsg(pPlayer, "很遗憾，你本场比赛轮空了。");
				pPlayer.NewWorld(nLeaveMapId, nLeavePosX, nLeavePosY);
			end
		end
		for _, nId in pairs(tbGroupMatchList[nCurMembers]) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer then
				pPlayer.Msg("很遗憾，你本场比赛轮空了。");
				Dialog:SendBlackBoardMsg(pPlayer, "很遗憾，你本场比赛轮空了。");
				--self:ConsumeTask(pPlayer);
				pPlayer.NewWorld(nLeaveMapId, nLeavePosX, nLeavePosY);
			end
		end
		table.remove(tbGroupMatchList, nLastMembers);
		table.remove(tbGroupMatchList, nCurMembers);
	end
	return tbGroupMatchList;
end

function TowerDefence:LogicEnterGame(tbGroupMatchList, nMapId)
	local nLeaveMapId, nLeavePosX, nLeavePosY = TowerDefence:GetLeavePos()
	for nKey = 1, #tbGroupMatchList, 2 do
		local nTeam = math.floor(nKey/2)+1;
		self.tbDynMapLists[nMapId] = self.tbDynMapLists[nMapId] or {};
		local nDyMapId = self.tbDynMapLists[nMapId][nTeam];
		if nDyMapId then
			self.tbMissionLists[nMapId] = self.tbMissionLists[nMapId] or {};
			self.tbMissionLists[nMapId][nTeam] = self.tbMissionLists[nMapId][nTeam] or Lib:NewClass(self.Mission);
			self.tbMissionLists[nMapId][nTeam]:StartGame({nDyMapId, self.DEF_MAP_POS[1], self.DEF_MAP_POS[2]}, {nLeaveMapId, nLeavePosX, nLeavePosY});
		end
		local nCaptionAId =0;
		for _, nId in pairs(tbGroupMatchList[nKey]) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer then
				if nDyMapId then
					self:ConsumeTask(pPlayer);
					if nCaptionAId == 0 then
						KTeam.CreateTeam(nId);	--建立队伍
						nCaptionAId = nId;
					else
						KTeam.ApplyJoinPlayerTeam(nCaptionAId, nId);	--加入队伍
					end
					self.tbPlayerLists[nId][3] = nTeam;
					self.tbMissionLists[nMapId][nTeam]:JoinPlayer(pPlayer, 1);
				else
					pPlayer.Msg("地图加载出现异常，本场比赛无法开启，请联系GM。");
					pPlayer.NewWorld(nLeaveMapId, nLeavePosX, nLeavePosY);					
				end
			end
		end
		
		nCaptionAId = 0;
		for _, nId in pairs(tbGroupMatchList[nKey + 1]) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer then
				if nDyMapId then
					self:ConsumeTask(pPlayer);
					if nCaptionAId == 0 then
						KTeam.CreateTeam(nId);	--建立队伍
						nCaptionAId = nId;
					else
						KTeam.ApplyJoinPlayerTeam(nCaptionAId, nId);	--加入队伍
					end	
					
					self.tbPlayerLists[nId][3] = nTeam;
					self.tbMissionLists[nMapId][nTeam]:JoinPlayer(pPlayer, 2);
				else
					pPlayer.Msg("地图加载出现异常，本场比赛无法开启，请联系GM。");
					pPlayer.NewWorld(nLeaveMapId, nLeavePosX, nLeavePosY);
				end
			end
		end
	end
end

--检查是否没有队伍
function TowerDefence:CheckGroupLists(tbGroupLists)
	for nMem = 1, self.DEF_PLAYER_TEAM do
		if #tbGroupLists[nMem] > 0 then
			return 1;
		end
	end
	return 0;
end

--离开坐标
function TowerDefence:GetLeavePos()
	local tbNpc = Npc:GetClass("chefu");
	for _, tbMapInfo in ipairs(tbNpc.tbCountry) do
		if SubWorldID2Idx(tbMapInfo.nId) > 0 then
			local nRandomPos = MathRandom(1, #tbMapInfo.tbSect)
			return tbMapInfo.nId, tbMapInfo.tbSect[nRandomPos][1],tbMapInfo.tbSect[nRandomPos][2];
		end
	end
	return 5, 1580, 3029;	--默认江津车夫
end

--副本申请
function TowerDefence:ApplyDyMap(nMapId)
	local nDyCount = math.ceil(self.DEF_PLAYER_MAX / (self.DEF_PLAYER_TEAM * 2));
	self.tbDynMapLists[nMapId] = self.tbDynMapLists[nMapId] or {};
	local nCurCount = #self.tbDynMapLists[nMapId];
	if nCurCount < nDyCount then
		for i=1, (nDyCount - nCurCount) do
			if (Map:LoadDynMap(1, self.DEF_MAP_TEMPLATE_ID, {self.OnLoadMapFinish, self, nMapId}) ~= 1) then
				print("竞技赛副本地图（守护先祖之魂）加载失败。。");
			end
		end
	end
	return 0;
end

--比赛地图动态加载成功
function TowerDefence:OnLoadMapFinish(nMapId, nDyMapId)
	self.tbDynMapLists[nMapId] = self.tbDynMapLists[nMapId] or {};
	table.insert(self.tbDynMapLists[nMapId], nDyMapId);
end

