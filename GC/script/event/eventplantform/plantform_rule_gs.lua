--活动平台
--zhouchenfei
--2009.08.13
if (MODULE_GC_SERVER) then
	return 0;
end

function EPlatForm:CheckLeagueType(tbLimitList, tbMacthCfg)
	return 0
end

--检查建立战队是否符合赛制类型（返回1不符合，0为符合）
function EPlatForm:CheckCreateLeague(pMyPlayer, tbPlayerIdList, tbMacthTypeCfg)
	return 0, "";
end

--检查加入战队是否符合赛制类型（返回1不符合，0为符合）
function EPlatForm:CheckJoinLeague(pMyPlayer, szLeagueName, tbPlayerIdList, tbJoinPlayerList, tbMacthTypeCfg)
	return 0;
end

--玩家进入准备场比赛场地
function EPlatForm:SetStateJoinIn(nGroupId)
	me.ClearSpecialState()		--清除特殊状态
	me.RemoveSkillStateWithoutKind(Player.emKNPCFIGHTSKILLKIND_CLEARDWHENENTERBATTLE) --清除状态
	me.DisableChangeCurCamp(1);	--设置与帮会有关的变量，不允许在竞技场战改变某个帮会阵营的操作
	me.SetFightState(1);	  	--设置战斗状态
	me.SetLogoutRV(1);			--玩家退出时，保存RV并，在下次等入时用RV(城市重生点，非退出点)
	me.ForbidEnmity(1);			--禁止仇杀
	me.DisabledStall(1);		--摆摊
	me.ForbitTrade(1);			--交易
	me.ForbidExercise(1);		-- 禁止切磋
	--me.nPkModel = Player.emKPK_STATE_PRACTISE;
	me.SetCurCamp(nGroupId);
	me.TeamDisable(1);			--禁止组队
	me.TeamApplyLeave();		--离开队伍
	me.StartDamageCounter();	--开始计算伤害
	Faction:SetForbidSwitchFaction(me, 1); -- 进入准备场比赛场就不能切换门派
	me.SetDisableZhenfa(1);
	me.nForbidChangePK	= 1;
end

--玩家离开准备场比赛场地
function EPlatForm:LeaveGame()
	me.SetFightState(0);
	me.SetCurCamp(me.GetCamp());
	me.StopDamageCounter();	-- 停止伤害计算
	me.DisableChangeCurCamp(0);
	me.nPkModel = Player.emKPK_STATE_PRACTISE;--关闭PK开关
	me.nForbidChangePK	= 0;
	me.SetDeathType(0);
	me.RestoreMana();
	me.RestoreLife();
	me.RestoreStamina();
	me.DisabledStall(0);	--摆摊
	me.TeamDisable(0);		--禁止组队
	me.ForbitTrade(0);		--交易
	me.ForbidEnmity(0);
	me.ForbidExercise(0);		-- 切磋
	Faction:SetForbidSwitchFaction(me, 0); -- 进入准备场比赛场就切换门派还原
	me.SetDisableZhenfa(0);
	me.LeaveTeam();
	--me.SetLogoutRV(0);
	--me.SetLogOutState(0);       --玩家下线时也可以调到LOGOUT
end

--排序
local function OnSort(tbA, tbB)
	if tbA.nWinRate == tbB.nWinRate then
		return tbA.nWinRate < tbB.nWinRate
	end 
	return tbA.nWinRate > tbB.nWinRate;
end
 
--准备场进入比赛场匹配规则
function EPlatForm:GameMatch(tbLeagueList)
	table.sort(tbLeagueList, OnSort);
	local tbLeagueA = {};
	local tbLeagueB = {};
	
	--匹配原则:.....暂定10队为一个区间;
	--按胜率,每N队为一个区间.打乱每个区间的排序
	--从高胜率区间遍历,发现已经打过的战队,则继续遍历,发现最后一个战队已经打过,则进入第二区间,
	--对第二区间进行遍历,如此循环.一直到最后区间...最后一队无论任何情况都进行匹配..
	local tbMatchLeague = {};
	
	--分区间
	local nDefArea = self.MAP_SELECT_SUBAREA;
	local nSubArea = 0;
	for i, tbLeague in ipairs(tbLeagueList) do
		if i > nSubArea * nDefArea then
			nSubArea = nSubArea + 1;
			tbMatchLeague[nSubArea] = {};
		end
		table.insert(tbMatchLeague[nSubArea], tbLeague);
	end
	local nMaxArea = #tbMatchLeague;
	for nArea, tbAreaLeague in ipairs(tbMatchLeague) do
		--打乱区间顺序.
		for i, tbLeague in ipairs(tbAreaLeague) do
			local nP = MathRandom(1, #tbAreaLeague);
			tbAreaLeague[i], tbAreaLeague[nP] = tbAreaLeague[nP], tbAreaLeague[i];
		end
		local nMaxCount = #tbAreaLeague;
		for i=1, nMaxCount do
			if tbAreaLeague[i] then
				local tbTempAreaLeague = {};
				local nTempMatchCount = 0;
				for j=i+1, nMaxCount  do
					if tbAreaLeague[j] then
						tbTempAreaLeague[j] = tbAreaLeague[j];
						nTempMatchCount = nTempMatchCount + 1;
					end
				end
				--如果没有匹配对象,并且是最后一个区间,则轮空,插入A表
				if nTempMatchCount == 0 and nArea ==  nMaxArea then
					table.insert(tbLeagueA, tbAreaLeague[i]);
					break;
				end
				
				--如果没有匹配对象,但不是最后一个区间,则把战队加入到下个区间
				if nTempMatchCount == 0 and nArea <  nMaxArea then
					table.insert(tbMatchLeague[nArea+1], tbAreaLeague[i]);
					break;
				end
				
				local nFindMatch = 0;
				--有匹配对象,进行匹配
				for nAreaLeagueId, tbTempLeague in pairs(tbTempAreaLeague) do
					if not tbAreaLeague[i].tbHistory[tbTempLeague.nNameId] 
					and not tbTempLeague.tbHistory[tbAreaLeague[i].nNameId] then
						table.insert(tbLeagueA, tbAreaLeague[i]);
						table.insert(tbLeagueB, tbAreaLeague[nAreaLeagueId]);
						tbAreaLeague[i] = nil;
						tbAreaLeague[nAreaLeagueId] = nil;
						nFindMatch = 1;
						break;
					end
				end
				
				--没找到匹配对象的情况下,并且是最后一个区间进行强制匹配
				if nFindMatch == 0 and nArea == nMaxArea then
					for nAreaLeagueId, tbTempLeague in pairs(tbTempAreaLeague) do
						table.insert(tbLeagueA, tbAreaLeague[i]);
						table.insert(tbLeagueB, tbAreaLeague[nAreaLeagueId]);
						tbAreaLeague[i] = nil;
						tbAreaLeague[nAreaLeagueId] = nil;
						nFindMatch = 1;
						break;
					end
				end
				
				--没找到匹配对象的情况下,不是最后一个区间,插入下个区间
				if nFindMatch == 0 and nArea < nMaxArea then
					table.insert(tbMatchLeague[nArea+1], tbAreaLeague[i]);
				end				
				
			end
		end
	end

	if #tbLeagueA < #tbLeagueB then
		return tbLeagueB, tbLeagueA;
	end
	
	return tbLeagueA, tbLeagueB;
end

--八强赛匹配
function EPlatForm:GameMatchAdv(nReadyId, tbSortLeague)
	local tbAdvLeagueList = {};
	for _, tbLeague in pairs(tbSortLeague) do
		if tbLeague.nRank == 0 or tbLeague.nRank > 8 then
			EPlatForm:GameMatchAdvKickLeague(tbLeague, nReadyId, "您的战队没有资格参加家族竞技决赛")
		else
			if EPlatForm.MACTH_STATE_ADV_TASK[EPlatForm.AdvMatchState] == 8 then
				tbAdvLeagueList[tbLeague.nRank] = tbLeague;
			elseif EPlatForm.MACTH_STATE_ADV_TASK[EPlatForm.AdvMatchState] == 4 then
				local nSeries = EPlatForm:GetAdvMatchSeries(tbLeague.nRank, 8);
				tbAdvLeagueList[nSeries] = tbLeague;
			elseif EPlatForm.MACTH_STATE_ADV_TASK[EPlatForm.AdvMatchState] == 2 then
				local nSeries = EPlatForm:GetAdvMatchSeries(tbLeague.nRank, 4);
				tbAdvLeagueList[nSeries] = tbLeague;				
			end
		end
	end
	
	local tbLeagueA = {};
	local tbLeagueB = {};

	--八强赛
	if EPlatForm.MACTH_STATE_ADV_TASK[EPlatForm.AdvMatchState] == 8 then
		for nRank = 1, 4 do 
			local nVsLeagueRank = 9 - nRank;
			local tbLeagueA1, tbLeagueB1 = EPlatForm:GetGameMatchAdvLogic1(tbAdvLeagueList, nReadyId, nRank, nVsLeagueRank, 4, 8);
			if tbLeagueA1 and tbLeagueB1 then
				table.insert(tbLeagueA, tbLeagueA1);
				table.insert(tbLeagueB, tbLeagueB1);		
			end
		end
	end
	
	--四强赛
	if EPlatForm.MACTH_STATE_ADV_TASK[EPlatForm.AdvMatchState] == 4 then
		for nRank = 1, 2 do 
			local nVsLeagueRank = nRank + 2;
			local tbLeagueA1, tbLeagueB1 = EPlatForm:GetGameMatchAdvLogic1(tbAdvLeagueList, nReadyId, nRank, nVsLeagueRank, 2, 4);
			if tbLeagueA1 and tbLeagueB1 then
				table.insert(tbLeagueA, tbLeagueA1);
				table.insert(tbLeagueB, tbLeagueB1);		
			end
		end
	end
	
	--决赛
	if EPlatForm.MACTH_STATE_ADV_TASK[EPlatForm.AdvMatchState] == 2 then
		local nRank = 1; 
		local nVsLeagueRank = 2;
		local tbLeagueA1, tbLeagueB1 = EPlatForm:GetGameMatchAdvLogic2(tbAdvLeagueList, nReadyId);
		if tbLeagueA1 and tbLeagueB1 then
			table.insert(tbLeagueA, tbLeagueA1);
			table.insert(tbLeagueB, tbLeagueB1);		
		end
	end
	return tbLeagueA, tbLeagueB;
end

function EPlatForm:GetGameMatchAdvLogic1(tbAdvLeagueList, nReadyId, nRank, nVsLeagueRank, nWinCamp, nLostCamp)
	if not tbAdvLeagueList[nRank] and not tbAdvLeagueList[nVsLeagueRank] then
		if EPlatForm.AdvMatchLists[nReadyId][nLostCamp][nRank] then
			EPlatForm.AdvMatchLists[nReadyId][nWinCamp][nRank] = EPlatForm.AdvMatchLists[nReadyId][nLostCamp][nRank];
			local szLeagueName = EPlatForm.AdvMatchLists[nReadyId][nWinCamp][nRank].szName;
			League:SetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_RANK_ADV, nWinCamp);
			EPlatForm:MacthAward(szLeagueName, nil, {}, 1, 0);
		end
		if EPlatForm.AdvMatchLists[nReadyId][nLostCamp][nVsLeagueRank] then
			local szLeagueName = EPlatForm.AdvMatchLists[nReadyId][nLostCamp][nVsLeagueRank].szName;
			League:SetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_RANK_ADV, nLostCamp);
		end
		return 0;	
	end
	
	if not tbAdvLeagueList[nRank] and tbAdvLeagueList[nVsLeagueRank] then
		if EPlatForm.AdvMatchLists[nReadyId][nLostCamp][nRank] then
			local szLeagueName = EPlatForm.AdvMatchLists[nReadyId][nLostCamp][nRank].szName;
			League:SetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_RANK_ADV, nLostCamp);
		end
		if EPlatForm.AdvMatchLists[nReadyId][nLostCamp][nVsLeagueRank] then
			local szLeagueName = EPlatForm.AdvMatchLists[nReadyId][nLostCamp][nVsLeagueRank].szName;
			League:SetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_RANK_ADV, nWinCamp);
		end
		EPlatForm:MacthAward(tbAdvLeagueList[nVsLeagueRank].szName, nil, {}, 1, 0);
		EPlatForm:GameMatchAdvKickLeague(tbAdvLeagueList[nVsLeagueRank], nReadyId, "因为你的对手缺席比赛，你战队获得了胜利");			
		return 0;
	end
	
	if tbAdvLeagueList[nRank] and not tbAdvLeagueList[nVsLeagueRank] then
		if EPlatForm.AdvMatchLists[nReadyId][nLostCamp][nRank] then
			local szLeagueName = EPlatForm.AdvMatchLists[nReadyId][nLostCamp][nRank].szName;
			League:SetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_RANK_ADV, nWinCamp);
		end
		if EPlatForm.AdvMatchLists[nReadyId][nLostCamp][nVsLeagueRank] then
			local szLeagueName = EPlatForm.AdvMatchLists[nReadyId][nLostCamp][nVsLeagueRank].szName;
			League:SetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_RANK_ADV, nLostCamp);
		end
		EPlatForm:MacthAward(tbAdvLeagueList[nRank].szName, nil, {}, 1, 0);
		EPlatForm:GameMatchAdvKickLeague(tbAdvLeagueList[nRank], nReadyId, "因为你的对手缺席比赛，你战队获得了胜利");
		return 0;
	end
	
	return tbAdvLeagueList[nRank], tbAdvLeagueList[nVsLeagueRank];
end

--1为获胜，2为平，3为输, 4为轮空获胜
function EPlatForm:GetGameMatchAdvLogic2(tbAdvLeagueList, nReadyId)
	if not tbAdvLeagueList[1] and not tbAdvLeagueList[2] then
		if EPlatForm.AdvMatchLists[nReadyId][2][1] then
			EPlatForm.AdvMatchLists[nReadyId][2][1].tbResult[EPlatForm.AdvMatchState - 2] = 4;
		end
		if EPlatForm.AdvMatchLists[nReadyId][2][2] then
			EPlatForm.AdvMatchLists[nReadyId][2][2].tbResult[EPlatForm.AdvMatchState - 2] = 4;
		end
		if EPlatForm.AdvMatchLists[nReadyId][2][1] and EPlatForm.AdvMatchState == 5 then
			EPlatForm:SetAdvMacthResult(nReadyId);
		end
		return 0;	
	end
	
	if not tbAdvLeagueList[1] and tbAdvLeagueList[2] then
		if EPlatForm.AdvMatchLists[nReadyId][2][1] then
			EPlatForm.AdvMatchLists[nReadyId][2][1].tbResult[EPlatForm.AdvMatchState - 2] = 3;
		end
		if EPlatForm.AdvMatchLists[nReadyId][2][2] then
			EPlatForm.AdvMatchLists[nReadyId][2][2].tbResult[EPlatForm.AdvMatchState - 2] = 1;
		end
		EPlatForm:MacthAward(tbAdvLeagueList[2].szName, nil, {}, 1, 0);
		EPlatForm:GameMatchAdvKickLeague(tbAdvLeagueList[2], nReadyId, "因为你的对手缺席比赛，你战队获得了胜利");			
		if EPlatForm.AdvMatchLists[nReadyId][2][1] and EPlatForm.AdvMatchState == 5 then
			EPlatForm:SetAdvMacthResult(nReadyId);
		end
		return 0;
	end
	
	if tbAdvLeagueList[1] and not tbAdvLeagueList[2] then
		if EPlatForm.AdvMatchLists[nReadyId][2][1] then
			EPlatForm.AdvMatchLists[nReadyId][2][1].tbResult[EPlatForm.AdvMatchState - 2] = 1;
		end
		if EPlatForm.AdvMatchLists[nReadyId][2][2] then
			EPlatForm.AdvMatchLists[nReadyId][2][2].tbResult[EPlatForm.AdvMatchState - 2] = 3;
		end
		EPlatForm:MacthAward(tbAdvLeagueList[1].szName, nil, {}, 1, 0);
		EPlatForm:GameMatchAdvKickLeague(tbAdvLeagueList[1], nReadyId, "因为你的对手缺席比赛，你战队获得了胜利");
		if EPlatForm.AdvMatchLists[nReadyId][2][1] and EPlatForm.AdvMatchState == 5 then
			EPlatForm:SetAdvMacthResult(nReadyId);
		end
		return 0;
	end
	
	return tbAdvLeagueList[1], tbAdvLeagueList[2];
end

function EPlatForm:GameMatchAdvKickLeague(tbLeague, nReadyId, szMsg)
	local nLeaveId = nil;
	
	local tbKickList = {};
	for _, nPlayerId in pairs(tbLeague.tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			tbKickList[nPlayerId] = pPlayer.szName;
		end
	end;
	
	for nPlayerId in pairs(tbKickList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			nLeaveId = self:KickPlayer(pPlayer, szMsg, nLeaveId);
			Dialog:SendBlackBoardMsg(pPlayer, szMsg);
		end
	end
	
	self.GroupList[nReadyId][tbLeague.szName] = nil;	
end

function EPlatForm:ClearReadyMap()
end

--进入比赛场匹配规则
function EPlatForm:EnterPkMapRule()
	local tbMCfg = EPlatForm:GetMacthTypeCfg(EPlatForm:GetMacthType());
	if (not tbMCfg) then
		return 0;
	end

	local tbMacthCfg = tbMCfg.tbMacthCfg;
	for nReadyId, tbMissions in pairs(self.MissionList) do
		if not self.GroupList[nReadyId] then
			self.GroupList[nReadyId] = {};
		end
		--传送进入比赛场地,匹配原则;
		local tbSortLeague = {};
		for szLeagueName, tbLeague in pairs(self.GroupList[nReadyId]) do
			local tbTemp = {szName = szLeagueName, 
				nNameId 		= tbLeague.nNameId , 
				nWinRate 		= tbLeague.nWinRate, 
				tbPlayerList 	= tbLeague.tbPlayerList, 
				tbHistory		= tbLeague.tbHistory,
				nRankAdv		= tbLeague.nRankAdv,
				nRank			= tbLeague.nRank,
				nPlayerNum		= #tbLeague.tbPlayerList,};
			table.insert(tbSortLeague, tbTemp);
		end
		
		local tbMisFlag = {};
		
		--如果是八强赛的匹配规则
		if EPlatForm:GetMacthState() == EPlatForm.DEF_STATE_ADVMATCH then
			local tbLeagueA, tbLeagueB = EPlatForm:GameMatchAdv(nReadyId, tbSortLeague);
			for i in pairs(tbLeagueA) do
				for nId, tbMission in pairs(tbMissions) do
					if (not tbMisFlag[nId] or tbMisFlag[nId] ~= 1) then
						EPlatForm:OnMacthPkStart(tbMission, nId, nReadyId, tbLeagueA[i], tbLeagueB[i], i);
						tbMisFlag[nId] = 1;
						break;
					end
				end
			end
		elseif (EPlatForm:GetMacthState() == EPlatForm.DEF_STATE_MATCH_1) then
			EPlatForm:OnMacthPkStart_Single(tbMissions, nReadyId);
		elseif #tbSortLeague < EPlatForm.MACTH_LEAGUE_MIN then
			local tbLeagueOut = {};
			for _, tbLeague in pairs(tbSortLeague) do
				tbLeagueOut[tbLeague.szName] = {};
				for _, nPlayerId in pairs(tbLeague.tbPlayerList) do
					tbLeagueOut[tbLeague.szName][nPlayerId] = 1;
				end
			end
			
			for szName, tbLeague in pairs(tbLeagueOut) do
				local nLeaveId = nil;
				for nPlayerId in pairs(tbLeague) do
					local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
					if pPlayer then
						nLeaveId = self:KickPlayer(pPlayer, string.format("参赛队伍不足%s队，比赛无法开启", EPlatForm.MACTH_LEAGUE_MIN), nLeaveId);
						Dialog:SendBlackBoardMsg(pPlayer, string.format("参赛队伍不足%s队，比赛无法开启", EPlatForm.MACTH_LEAGUE_MIN))
					end
				end
				League:SetLeagueTask(EPlatForm.LGTYPE, szName, EPlatForm.LGTASK_ENTER, 0);
				self.GroupList[nReadyId][szName] = nil;
			end

			for nId, tbMission in pairs(tbMissions) do
				if tbMission:IsOpen() ~= 0 then
					tbMission:CloseGame();
				end
			end
		else
			local tbKickPlayerList = {};
			local tbEnterPlayerList = {};
			local tbKickPlayerList_Ex = {};
			
			-- 先做一次随机
			for i, tbLeague in ipairs(tbSortLeague) do
				local nP = MathRandom(1, #tbSortLeague);
				tbSortLeague[i], tbSortLeague[nP] = tbSortLeague[nP], tbSortLeague[i];
			end
			
			for _, tbList in pairs(tbSortLeague) do
				local nCount = self:GetTeamEventCount(tbList.szName);
				if (tbList.nPlayerNum < self.MIN_TEAM_EVENT_NUM or nCount <= 0) then
					tbKickPlayerList[#tbKickPlayerList + 1] = tbList;
				else
					if (#tbEnterPlayerList < self:GetPreMaxLeague()) then
						tbEnterPlayerList[#tbEnterPlayerList + 1] = tbList;
					else
						tbKickPlayerList_Ex[#tbKickPlayerList_Ex + 1] = tbList;	
					end
				end
			end
			
			--log统计
			KStatLog.ModifyAdd("eventplantform", string.format("活动平台"), "总量", #tbEnterPlayerList);

			local tbLeagueA, tbLeagueB = EPlatForm:GameMatch(tbEnterPlayerList);
			for i, tbMatchLeague in pairs(tbLeagueA) do
				if not tbLeagueB[i] then
					--轮空;
					local tbAwardList = {};
					for _, nId in pairs(tbLeagueA[i].tbPlayerList) do
						local pPlayer = KPlayer.GetPlayerObjById(nId);
						if pPlayer then
							tbAwardList[nId] = pPlayer.szName;
						end
					end
					
--					EPlatForm:MacthAward(tbLeagueA[i].szName, nil, tbAwardList, 4, EPlatForm.MACTH_TIME_BYE)
					--奖励
					
					local nLeaveId = nil;
					for nId, szName in pairs(tbAwardList) do
						local pPlayer = KPlayer.GetPlayerObjById(nId);
						if pPlayer then
							nLeaveId = self:KickPlayer(pPlayer, "本轮轮空", nLeaveId);
							Dialog:SendBlackBoardMsg(pPlayer, "本轮轮空..")
						end					
					end
					self.GroupList[nReadyId][tbLeagueA[i].szName] = nil;
					break;
				end
				for nId, tbMission in pairs(tbMissions) do
					if (not tbMisFlag[nId] or tbMisFlag[nId] ~= 1) then
						EPlatForm:OnMacthPkStart(tbMission, nId, nReadyId, tbLeagueA[i], tbLeagueB[i], i);
						tbMisFlag[nId] = 1;
						break;
					end
				end
			end
			for i, tbList in pairs(tbKickPlayerList) do
				local nLeaveId = nil;
				local tbTemp = Lib:CopyTB1(tbList.tbPlayerList);
				for j, nPlayerId in pairs(tbTemp) do
					local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
					if pPlayer then
						nLeaveId = self:KickPlayer(pPlayer, string.format("本队参加活动的人数不足%d人不能比赛", self.MIN_TEAM_EVENT_NUM), nLeaveId);
					end					
				end
				self.GroupList[nReadyId][tbList.szName] = nil;
			end
			for i, tbList in pairs(tbKickPlayerList_Ex) do
				local nLeaveId = nil;
				local tbTemp = Lib:CopyTB1(tbList.tbPlayerList);
				for j, nPlayerId in pairs(tbTemp) do
					local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
					if pPlayer then
						nLeaveId = self:KickPlayer(pPlayer, string.format("活动比赛场已满，本队本轮轮空"), nLeaveId);
					end					
				end
				self.GroupList[nReadyId][tbList.szName] = nil;
			end
		end
	end	
end

function EPlatForm:OnMacthPkStart_Single(tbMissions, nReadyId)
	local tbCfg			 = EPlatForm:GetMacthTypeCfg(EPlatForm:GetMacthType());
	if (not tbCfg) then
		self:WriteLog("OnMacthPkStart_Single", "error OnMacthPkStart_Single not tbCfg");
		return 0;
	end
	local nGamePlayerMax = self.nCurMatchMaxTeamCount;
	local nGamePlayerMin = self.nCurMatchMinTeamCount;
	local nReadyMapId	 = tbCfg.tbReadyMap[nReadyId];
	
	if (not nReadyMapId or nReadyMapId <= 0) then
		return 0;
	end
	
	local tbList = self.GroupList[nReadyId];
	
	local nGroupDivide  = 0;
	local tbKickPlayerList = {};
	local nDynMapIndex	= 1;
	local nLoopMaxCount = 0;
	local nCurReadyMapId = tbCfg.tbReadyMap[nReadyId] or 0;
	
	local tbMission = nil;
	local tbMisFlag	= {};
	local nDynId	= 0;
	
	for nId, tbMis in pairs(tbMissions) do
		if (not tbMisFlag[nId] or tbMisFlag[nId] ~= 1) then
			tbMission = tbMis;
			tbMisFlag[nId] = 1;
			nDynId = nId;
			break;
		end
	end
	
	local nMaxLeaguCount = tbList.nLeagueCount;
	
	local tbTemp = {};
	local tbRandomTemp = {};
	local tbName2Id = {};
	for szLeagueName, tbGroup in pairs(tbList) do
		if (tbGroup) then
			tbRandomTemp[#tbRandomTemp + 1] = {tbGroup = tbGroup, szLeagueName = szLeagueName};
		end
	end
	
	Lib:SmashTable(tbRandomTemp);
	
	for i, tbInfo in pairs(tbRandomTemp) do
		tbTemp[#tbTemp + 1]	= tbInfo.tbGroup;
		tbName2Id[#tbTemp]	= tbInfo.szLeagueName;
	end
	
	for nGroup, tbGroup in ipairs(tbTemp) do
		if nGroupDivide == 0 then
			--判断是否够4人
			if not tbTemp[nGroup + (nGamePlayerMin-1)] then
				--后面不够4组，踢出赛场；
				for nKickGroup = nGroup, #tbTemp do
					if (not tbTemp[nKickGroup].tbPlayerList) then
						tbTemp[nKickGroup].tbPlayerList = {};
					end
					for _, nPlayerId in pairs(tbTemp[nKickGroup].tbPlayerList) do
						local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
						if pPlayer then
							table.insert(tbKickPlayerList, pPlayer);
						end
					end
				end
				break;
			end
		end
		if (not tbGroup.tbPlayerList) then
			tbGroup.tbPlayerList = {};
		end
		
		for _, nPlayerId in pairs(tbGroup.tbPlayerList) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			--对象，分配动态地图索引，组号；
			if pPlayer then
				local nCurMapId = pPlayer.GetWorldPos();
				if (nCurMapId == nCurReadyMapId and tbMission) then
					local tbEnterPos	= tbMission:GetEnterPos();
					local nCount		= self:GetPlayerEventCount(pPlayer);
					if (tbEnterPos and nCount > 0) then
						local nCountFlag = self:CheckEnterCount(pPlayer, tbCfg.tbMacthCfg.tbJoinItem);
						-- 没有参赛物品就不能参赛
						if (nCountFlag <= 0 or nCountFlag > 1) then
							table.insert(tbKickPlayerList, pPlayer);
						else
							if (tbEnterPos[1][1] > 0) then
								--pPlayer.NewWorld(tbEnterPos[1][1], tbEnterPos[1][2], tbEnterPos[1][3]);
								local tbTemp = {};
								tbTemp.szLeagueName = pPlayer.szName;
								tbTemp.tbPlayerList = { nPlayerId };
								tbMission:JoinGame(tbTemp, 0, tbCfg.tbMacthCfg.tbJoinItem);
								self:SetPlayerDynId(pPlayer, nDynId);
								
								local nCount = self:GetPlayerEventCount(pPlayer);
								nCount = nCount - 1;
								if (nCount < 0) then
									nCount = 0;
								end
								self:UseMatchItem(pPlayer, 1, tbCfg.tbMacthCfg.tbJoinItem, tbCfg.tbMacthCfg.nEnterItemCount);
								self:SetPlayerEventCount(pPlayer, nCount);
								self:AddPlayerTotalCount(pPlayer, 1);
								nGroupDivide = nGroupDivide + 1;
							end
						end
					else
						table.insert(tbKickPlayerList, pPlayer);
					end
				end
			end
		end		
		if nGroupDivide >= nGamePlayerMax then
			nGroupDivide = 0;
			nDynMapIndex = nDynMapIndex + 1;

			for nId, tbMis in pairs(tbMissions) do
				if (not tbMisFlag[nId] or tbMisFlag[nId] ~= 1) then
					tbMission = tbMis;
					tbMisFlag[nId] = 1;
					break;
				end
			end

		end
	end
	for _, pPlayer in pairs(tbKickPlayerList) do
		self:KickPlayer(pPlayer);
		local szMsg = string.format("你被随机分配到的组中不够%d人，不能开启比赛，请下场再次参赛。", nGamePlayerMin);
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
		pPlayer.Msg(string.format("<color=green>%s<color>",szMsg));
		pPlayer.AddStackItem(18, 1, 80, 1,nil, 2);
	end
	self.GroupList[nReadyId] = nil;
end

function EPlatForm:OnMacthPkStart(tbMission, nDynId, nReadyId, tbLeagueA, tbLeagueB)
	local tbMacthCfg = EPlatForm:GetMacthTypeCfg(EPlatForm:GetMacthType());
	if (not tbMacthCfg) then
		return 0;
	end
	local nGamePlayerMax = tbMacthCfg.tbMacthCfg.nPlayerCount;
	local tbEnterPos	= tbMission:GetEnterPos();
	local nMatchPatch, nPosX, nPosY 	 = 0, 0, 0;
	if (tbEnterPos and tbEnterPos[1]) then
		nMatchPatch, nPosX, nPosY = tbEnterPos[1][1] or 0, tbEnterPos[1][2] or 0, tbEnterPos[1][3] or 0;
	end
	
	if SubWorldID2Idx(nMatchPatch) < 0 then
		print("Error!!!", "活动地图没有开启", nMatchPatch);
		return 0;
	end 
	
	--战队数据记录
	EPlatForm:AddMacthLeague(tbLeagueA.szName, tbLeagueB.nNameId);
	EPlatForm:AddMacthLeague(tbLeagueB.szName, tbLeagueA.nNameId);
	
	local szMatchMsgA = string.format("您的对手战队是：<color=green>%s<color=yellow>", tbLeagueA.szName);
	local szMatchMsgB = string.format("您的对手战队是：<color=green>%s<color=yellow>", tbLeagueB.szName);
	local tbPlayerMatchListA = {};
	local tbPlayerMatchListB = {};
	local nPlayerCountA = 0;
	local nPlayerCountB = 0;
	local nLeaveId = nil;
	for _, nId in pairs(tbLeagueA.tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer then
			if nPlayerCountA >= nGamePlayerMax then
				nLeaveId = self:KickPlayer(pPlayer, "你战队正式成员已进入比赛场，<color=yellow>你做为替补，请在外面等待结果<color>。", nLeaveId);
			else
				nPlayerCountA = nPlayerCountA + 1;
				table.insert(tbPlayerMatchListA, nId);
				szMatchMsgA = szMatchMsgA .. "\n对手：" .. pPlayer.szName;
			end
		end
	end
	local nLeaveId = nil;
	for _, nId in pairs(tbLeagueB.tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer then
			if nPlayerCountB >= nGamePlayerMax then
				nLeaveId = self:KickPlayer(pPlayer, "你战队正式成员已进入比赛场，你做为替补，请在外面等待结果。", nLeaveId);							
			else
				nPlayerCountB = nPlayerCountB + 1;
				table.insert(tbPlayerMatchListB, nId);							
				szMatchMsgB = szMatchMsgB .. "\n对手：" .. pPlayer.szName;
			end
		end
	end
	
	--阵营1
	local nCaptionAId = 0;
	local tbTempA = {};
	tbTempA.szLeagueName = tbLeagueA.szName;
	tbTempA.tbPlayerList = {};
	for _, nId in pairs(tbPlayerMatchListA) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer then
			if nCaptionAId == 0 then
				KTeam.CreateTeam(nId);	--建立队伍
				nCaptionAId = nId;
			else
				KTeam.ApplyJoinPlayerTeam(nCaptionAId, nId);	--加入队伍
			end
			EPlatForm.MACTH_ENTER_FLAG[nId] = 1;
			pPlayer.NewWorld(nMatchPatch, nPosX, nPosY);
			self:SetPlayerDynId(pPlayer, nDynId);
			tbTempA.tbPlayerList[#tbTempA.tbPlayerList + 1] = nId;
			pPlayer.Msg(szMatchMsgB);
		end
	end
	tbMission:JoinGame(tbTempA, 1, tbMacthCfg.tbMacthCfg.tbJoinItem);
	local nCount = self:GetTeamEventCount(tbTempA.szLeagueName);
	nCount = nCount - 1;
	if (nCount < 0) then
		nCount = 0;
	end
	GCExcute{"EPlatForm:SetTeamEventCount", tbTempA.szLeagueName, nCount};
	
	for _, nId in pairs(tbPlayerMatchListA) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer then
			self:UseMatchItem(pPlayer, 1, tbMacthCfg.tbMacthCfg.tbJoinItem, tbMacthCfg.tbMacthCfg.nEnterItemCount);
		end
	end	

	
	--阵营2
	local tbTempB = {};
	tbTempB.szLeagueName = tbLeagueB.szName;
	tbTempB.tbPlayerList = {};
	local nCaptionBId = 0;
	for _, nId in pairs(tbPlayerMatchListB) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer then
			if nCaptionBId == 0 then
				KTeam.CreateTeam(nId);	--建立队伍
				nCaptionBId = nId;
			else
				KTeam.ApplyJoinPlayerTeam(nCaptionBId, nId);	--加入队伍
			end
			EPlatForm.MACTH_ENTER_FLAG[nId] = 1;
			pPlayer.NewWorld(nMatchPatch, nPosX, nPosY);
			self:SetPlayerDynId(pPlayer, nDynId);
			tbTempB.tbPlayerList[#tbTempB.tbPlayerList + 1] = nId;
			pPlayer.Msg(szMatchMsgA);
		end
	end
	tbMission:JoinGame(tbTempB, 2, tbMacthCfg.tbMacthCfg.tbJoinItem);
	nCount = self:GetTeamEventCount(tbTempB.szLeagueName);
	nCount = nCount - 1;
	if (nCount < 0) then
		nCount = 0;
	end
	GCExcute{"EPlatForm:SetTeamEventCount", tbTempB.szLeagueName, nCount};
	
	for _, nId in pairs(tbPlayerMatchListB) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer then
			self:UseMatchItem(pPlayer, 1, tbMacthCfg.tbMacthCfg.tbJoinItem, tbMacthCfg.tbMacthCfg.nEnterItemCount);
		end
	end		

	
	self.GroupList[nReadyId][tbLeagueB.szName] = nil;
	self.GroupList[nReadyId][tbLeagueA.szName] = nil;	
end

function EPlatForm:SendResult(tbResultList, nReadyId)
	if (EPlatForm:GetMacthState() == EPlatForm.DEF_STATE_ADVMATCH) then
		self:Award2PvpMatch(tbResultList, nReadyId);
	elseif (EPlatForm:GetMacthState() == EPlatForm.DEF_STATE_MATCH_1) then
		self:AwardWeleeMatch(tbResultList);
	elseif (EPlatForm:GetMacthState() == EPlatForm.DEF_STATE_MATCH_2) then
		self:Award2PvpMatch(tbResultList, nReadyId);
	end
end

function EPlatForm:AwardWeleeMatch(tbPlayerList)
	if (not tbPlayerList) then
		return;
	end
	-- 这里奖励要改一下
	for nRank, tbGroup in ipairs(tbPlayerList) do
		if (tbGroup.tbPlayerList) then
			for nIndex, nPlayerId in pairs(tbGroup.tbPlayerList) do
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				self:GiveWeleeAwardToPlayer(pPlayer, nRank);
			end
		end
	end

	local nState			= EPlatForm:GetMacthState();
	local nSession			= EPlatForm:GetMacthSession();
	local nMacthType		= EPlatForm:GetMacthType();
	for nRank, tbGroup in ipairs(tbPlayerList) do
		if (tbGroup.tbPlayerList) then
			for nIndex, nPlayerId in pairs(tbGroup.tbPlayerList) do
				StatLog:WriteStatLog("stat_info", "kin_game", "game_score", nPlayerId, string.format("%s,%s,%s,%s", nMacthType, nState, tbGroup.szLeagueName, tbGroup.nDamage));
			end
		end
	end
end

function EPlatForm:GiveWeleeAwardToPlayer(pPlayer, nRank)
	if (not pPlayer or not nRank or nRank <= 0) then
		return 0;
	end
	
	local nState			= EPlatForm:GetMacthState();
	local nSession			= EPlatForm:GetMacthSession();
	local nMacthType		= EPlatForm:GetMacthType();
	local tbMacth			= EPlatForm:GetMacthTypeCfg(nMacthType);
	local szMatchName	= "家族竞技";
	if (tbMacth) then
		szMatchName	= 	tbMacth.szName;
	end	

	if (nRank > 0 and nRank <= 5) then
		pPlayer.SendMsgToFriend(string.format("您的好友[%s]在刚刚结束的%s活动中获得第<color=yellow>%d<color>名！", pPlayer.szName, szMatchName, nRank));
	end
	local nAwardFlag = self:SetAwardFlagParam(0, nSession, nState, nRank);
	self:SetAwardParam(pPlayer, nAwardFlag);
	local nHonor = 0;
	if	EPlatForm.AWARD_WELEE_LIST[nSession] and 
	 	EPlatForm.AWARD_WELEE_LIST[nSession][nRank] and 
	 	EPlatForm.AWARD_WELEE_LIST[nSession][nRank].honor then
		nHonor = EPlatForm.AWARD_WELEE_LIST[nSession][nRank].honor[1];
	end
	--家族竞技、趣味竞技指引任务变量
	if pPlayer.GetTask(1022,238) ~= 1 then
		pPlayer.SetTask(1022,238, 1);
	end
	-- 记录个人赛阶段比赛积分
	Player:AddJoinRecord_MonthPoint(pPlayer, Player.EVENT_JOIN_RECORD_JIAZUJINGJI, nHonor);
	pPlayer.Msg(string.format("你在本场活动比赛中获得第<color=yellow>%d<color>名，获得了<color=yellow>%s<color>积分。", nRank, nHonor));
	self:SetEventScore(pPlayer.nId, nHonor, 1, 1);
	
	SpecialEvent.ActiveGift:AddCounts(pPlayer, 15);		--家族竞技完成活跃度
end

function EPlatForm:Award2PvpMatch(tbPlayerList, nReadyId)
	if (not tbPlayerList) then
		return;
	end

	if (tbPlayerList[1] and tbPlayerList[2]) then
		local tbListA = {};
		if (tbPlayerList[1].tbPlayerList) then
			for _, nId in pairs(tbPlayerList[1].tbPlayerList) do
				local szPlayerName = KGCPlayer.GetPlayerName(nId);
				tbListA[nId] = szPlayerName;
			end
		end
		
		local tbListB = {};
		if (tbPlayerList[2].tbPlayerList) then
			for _, nId in pairs(tbPlayerList[2].tbPlayerList) do
				local szPlayerName = KGCPlayer.GetPlayerName(nId);
				tbListB[nId] = szPlayerName;
			end
		end		

		if (tbPlayerList[1].nDamage == tbPlayerList[2].nDamage) then
			EPlatForm:MacthAward(tbPlayerList[1].szLeagueName, tbPlayerList[2].szLeagueName, tbListA, 2);
			EPlatForm:MacthAward(tbPlayerList[2].szLeagueName, tbPlayerList[1].szLeagueName, tbListB, 2);
		else
			EPlatForm:MacthAward(tbPlayerList[1].szLeagueName, tbPlayerList[2].szLeagueName, tbListA, 1);
			EPlatForm:MacthAward(tbPlayerList[2].szLeagueName, tbPlayerList[1].szLeagueName, tbListB, 3);
		end		
	end
	
	if (tbPlayerList[1] and not tbPlayerList[2]) then
		local tbListA = {};
		if (tbPlayerList[1].tbPlayerList) then
			for _, nId in pairs(tbPlayerList[1].tbPlayerList) do
				local szPlayerName = KGCPlayer.GetPlayerName(nId);
				tbListA[nId] = szPlayerName;
			end
		end
		EPlatForm:MacthAward(tbPlayerList[1].szLeagueName, "", tbListA, 1);
	end
	
	if (EPlatForm.DEF_STATE_ADVMATCH == self:GetMacthState()) then
		if (EPlatForm.AdvMatchState == 5) then -- 最后一场
			EPlatForm:SetAdvMacthResult(nReadyId);
		end
	end

	local nState			= EPlatForm:GetMacthState();
	local nSession			= EPlatForm:GetMacthSession();
	local nMacthType		= EPlatForm:GetMacthType();
	for nRank, tbGroup in ipairs(tbPlayerList) do
		if (tbGroup.tbPlayerList) then
			for nIndex, nPlayerId in pairs(tbGroup.tbPlayerList) do
				StatLog:WriteStatLog("stat_info", "kin_game", "game_score", nPlayerId, nMacthType, nState, tbGroup.szLeagueName, tbGroup.nDamage);
			end
		end
	end
end
