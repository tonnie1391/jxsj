--武林大会
--孙多良
--2008.09.11
if (MODULE_GC_SERVER) then
	return 0;
end

function Wldh:CheckLeagueType(tbLimitList, tbMacthCfg)

	--五行检查 todo
	if tbMacthCfg.nSeries == self.LEAGUE_TYPE_SERIES_MIX then
		--不同五行
		local tbSeries = {};
		for _, nSeries in pairs(tbLimitList.tbSeries) do
			if not tbSeries[nSeries] then
				tbSeries[nSeries] = 1;
			else
				return 1, "本类型比赛需要战队成员是不同五行组合。";
			end
		end
	end
	return 0
end

--检查建立战队是否符合赛制类型（返回1不符合，0为符合）
function Wldh:CheckCreateLeague(pMyPlayer, tbPlayerIdList, nType)
	local tbMacthCfg = self:GetCfg(nType);
	local nLGType = self:GetLGType(nType);
	local tbLimitList = {
			tbSex = {};
			tbCamp = {};
			tbSeries = {};
			tbFaction = {};
		};
	local nMapId, nPosX, nPosY	= pMyPlayer.GetWorldPos();	
	for _, nPlayerId in pairs(tbPlayerIdList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not pPlayer then
			return 1, "您的所有队友必须在这附近。";
		end
		local nMapId2, nPosX2, nPosY2	= pPlayer.GetWorldPos();
		local nDisSquare = (nPosX - nPosX2)^2 + (nPosY - nPosY2)^2;
		if nMapId2 ~= nMapId or nDisSquare > 400 then
			return 1, "您的所有队友必须在这附近。";
		end		
		if not pPlayer or pPlayer.nMapId ~= nMapId then
			return 1, "您的所有队友必须在这附近。";
		end
		
		local nChose = GetPlayerSportTask(pPlayer.nId, Wldh.GBTASKID_GROUP, Wldh.GBTASKID_CHOSE_TYPE) or 0;
		if nType > 1 and nChose > 0 then
			return 1, string.format("队伍中<color=yellow>%s<color>已经选择了其他赛制的比赛，三种赛制只能选择其中一种。", pPlayer.szName);			
		end
		
		if pPlayer.GetCamp() == 0 then
			return 1, string.format("队伍中<color=yellow>%s<color>还没有加入门派，只有加入门派的侠士侠女才能参加。", pPlayer.szName);
		end

		local szLeagueName = League:GetMemberLeague(nLGType, pPlayer.szName);
		if szLeagueName then
			return 1, string.format("队伍中<color=yellow>%s<color>已有和别人建立战队参加本类型比赛，建立战队时，队伍中的队员必须没有选择参加本类型比赛。", pPlayer.szName);
		end
		
		table.insert(tbLimitList.tbSex, pPlayer.nSex);
		table.insert(tbLimitList.tbCamp, pPlayer.GetCamp());
		table.insert(tbLimitList.tbSeries, pPlayer.nSeries);
		table.insert(tbLimitList.tbFaction, pPlayer.nFaction);
	end
	
	--人数检查
	if #tbPlayerIdList ~= tbMacthCfg.nMemberCount then
		return 1, string.format("您的队伍人数不符合本类型比赛人数需求，本类型比赛必须由<color=yellow>%s名<color>成员组成战队参加比赛。", tbMacthCfg.nMemberCount);
	end
	
	local nFlag, szMsg = self:CheckLeagueType(tbLimitList, tbMacthCfg)
	if nFlag == 1 then
		return 1, szMsg;
	end
	local szReturnMsg = "成功建立战队！";
	return 0, szReturnMsg;
end

--玩家进入准备场比赛场地
function Wldh:SetStateJoinIn(nGroupId)
	me.ClearSpecialState()		--清除特殊状态
	me.RemoveSkillStateWithoutKind(Player.emKNPCFIGHTSKILLKIND_CLEARDWHENENTERBATTLE) --清除状态
	me.DisableChangeCurCamp(1);	--设置与帮会有关的变量，不允许在竞技场战改变某个帮会阵营的操作
	me.SetFightState(1);	  	--设置战斗状态
	me.SetLogoutRV(1);			--玩家退出时，保存RV并，在下次等入时用RV(城市重生点，非退出点)
	me.ForbidEnmity(1);			--禁止仇杀
	me.DisabledStall(1);		--摆摊
	me.ForbitTrade(1);			--交易
	--me.nPkModel = Player.emKPK_STATE_PRACTISE;
	me.SetCurCamp(nGroupId);
	me.TeamDisable(1);			--禁止组队
	me.TeamApplyLeave();		--离开队伍
	me.StartDamageCounter();	--开始计算伤害
	Faction:SetForbidSwitchFaction(me, 1); -- 进入准备场比赛场就不能切换门派
	me.SetDisableTeam(1);
	me.SetDisableStall(1);
	me.SetDisableFriend(1);
	me.nForbidChangePK	= 1;
end

--玩家离开准备场比赛场地
function Wldh:LeaveGame()
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
	Faction:SetForbidSwitchFaction(me, 0); -- 进入准备场比赛场就切换门派还原
	me.SetDisableTeam(0);
	me.SetDisableStall(0);
	me.SetDisableFriend(0);	
	me.LeaveTeam();
end

--排序
local function OnSort(tbA, tbB)
	if tbA.nWinRate == tbB.nWinRate then
		return tbA.nWinRate < tbB.nWinRate
	end 
	return tbA.nWinRate > tbB.nWinRate;
end
 
--准备场进入比赛场匹配规则
function Wldh:GameMatch(tbLeagueList)
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

--进入比赛场匹配规则
function Wldh:EnterPkMapRule(nType, nIsFinal)
	local nLGType = self:GetLGType(nType);
	local szTypeName = self:GetName(nType);
	for nReadyId, tbMission in pairs(self.MissionList[nType]) do
		if not self.GroupList[nType][nReadyId] then
			self.GroupList[nType][nReadyId] = {};
		end
		--传送进入比赛场地,匹配原则;
		local tbSortLeague = {};
		for szLeagueName, tbLeague in pairs(self.GroupList[nType][nReadyId]) do
			local tbTemp = {szName = szLeagueName, 
				nNameId 		= tbLeague.nNameId , 
				nWinRate 		= tbLeague.nWinRate, 
				tbPlayerList 	= tbLeague.tbPlayerList, 
				tbHistory		= tbLeague.tbHistory,
				nRankAdv		= tbLeague.nRankAdv,
				nRank			= tbLeague.nRank};
			table.insert(tbSortLeague, tbTemp);
		end
		
		--如果是八强赛的匹配规则
		if nIsFinal > 0 then
			local tbLeagueA, tbLeagueB = Wldh:GameMatchAdv(nIsFinal, nType, nReadyId, tbSortLeague);
			local nIsNotAttend = 1;
			for i in pairs(tbLeagueA) do
				nIsNotAttend = 0;
				Wldh:OnMacthPkStart(tbMission, nType, nReadyId, tbLeagueA[i], tbLeagueB[i], i);
			end
			if nIsFinal == 7 and nIsNotAttend == 1 then
				Wldh:SetAdvMacthResult(nType, nReadyId);
			end
		elseif #tbSortLeague < Wldh.MACTH_LEAGUE_MIN then
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
						nLeaveId = self:KickPlayer(pPlayer, string.format("参赛队伍不足%s队，比赛无法开启", Wldh.MACTH_LEAGUE_MIN), nType, nLeaveId);
						Dialog:SendBlackBoardMsg(pPlayer, string.format("参赛队伍不足%s队，比赛无法开启", Wldh.MACTH_LEAGUE_MIN))
					end
				end
				--League:SetLeagueTask(nLGType, szName, Wldh.LGTASK_ENTER, 0);
				self.GroupList[nType][nReadyId][szName] = nil;
			end
			
			if tbMission:IsOpen() ~= 0 then
				tbMission:EndGame();
			end
		else
			--log统计
			--KStatLog.ModifyAdd("Wldh", string.format("%s级赛每天参赛队伍数",nType), "总量", #tbSortLeague);

			local tbLeagueA, tbLeagueB = Wldh:GameMatch(tbSortLeague);
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
					
					Wldh:MacthAward(nType, nIsFinal, tbLeagueA[i].szName, nil, tbAwardList, 4, Wldh.MACTH_TIME_BYE, nReadyId)
					--奖励
					
					local nLeaveId = nil;
					for nId, szName in pairs(tbAwardList) do
						local pPlayer = KPlayer.GetPlayerObjById(nId);
						if pPlayer then
							local szKickMsg = string.format("你真幸运，因为人数匹配不均，你本场%s比赛轮空。", szTypeName);
							nLeaveId = self:KickPlayer(pPlayer, szKickMsg, nType, nLeaveId);
							Dialog:SendBlackBoardMsg(pPlayer, szKickMsg)
						end					
					end
					self.GroupList[nType][nReadyId][tbLeagueA[i].szName] = nil;
					break;
				end
				
				Wldh:OnMacthPkStart(tbMission, nType, nReadyId, tbLeagueA[i], tbLeagueB[i], i);
			end
		end
	end	
end

function Wldh:OnMacthPkStart(tbMission, nType, nReadyId, tbLeagueA, tbLeagueB, nAearId)
	local nGamePlayerMax = self:GetCfg(nType).nPlayerCount;
	local nMatchPatch 	 = tbMission.nMacthMap;
	if nAearId > self.MAP_SELECT_MAX then
		nAearId = (nAearId - self.MAP_SELECT_MAX)
		nMatchPatch = tbMission.nMacthMapPatch;
	end
	
	if SubWorldID2Idx(nMatchPatch) < 0 then
		print("Error!!!", "武林大会地图没有开启", nMatchPatch);
		return 0;
	end 
	
	local nPosX, nPosY = unpack(Wldh:GetMapPKPosTable(nType)[nAearId]);
	
	--战队数据记录
	Wldh:AddMacthLeague(nType, tbLeagueA.szName, tbLeagueB.nNameId);
	Wldh:AddMacthLeague(nType, tbLeagueB.szName, tbLeagueA.nNameId);
	
	local szMatchMsgA = string.format("您的对手战队是：<color=green>%s<color=yellow>", tbLeagueA.szName);
	local szMatchMsgB = string.format("您的对手战队是：<color=green>%s<color=yellow>", tbLeagueB.szName);
	local szLookMsgA = string.format("<color=green>---%s战队情况---<color><color=yellow>", tbLeagueA.szName);
	local szLookMsgB = string.format("<color=green>---%s战队情况---<color><color=yellow>", tbLeagueB.szName);
	local tbPlayerMatchListA = {};
	local tbPlayerMatchListB = {};
	local nPlayerCountA = 0;
	local nPlayerCountB = 0;
	local nLeaveId = nil;
	for _, nId in pairs(tbLeagueA.tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer then
			if nPlayerCountA >= nGamePlayerMax then
				nLeaveId = self:KickPlayer(pPlayer, "你战队正式成员已进入比赛场，<color=yellow>你做为替补，请在会场等待结果<color>，如果离开了会场，将<color=yellow>无法获得你战队的比赛奖励<color>。", nType, nLeaveId);
			else
				nPlayerCountA = nPlayerCountA + 1;
				table.insert(tbPlayerMatchListA, nId);
				szMatchMsgA = szMatchMsgA .. "\n对手：" .. pPlayer.szName .."  ".. Player:GetFactionRouteName(pPlayer.nFaction, pPlayer.nRouteId) .. "  " .. pPlayer.nLevel .."级";
				szLookMsgA = szLookMsgA .. "\n成员：" .. pPlayer.szName .."  ".. Player:GetFactionRouteName(pPlayer.nFaction, pPlayer.nRouteId) .. "  " .. pPlayer.nLevel .."级";
			end
		end
	end
	local nLeaveId = nil;
	for _, nId in pairs(tbLeagueB.tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer then
			if nPlayerCountB >= nGamePlayerMax then
				nLeaveId = self:KickPlayer(pPlayer, "你战队正式成员已进入比赛场，你做为替补，请在会场等待结果。", nType, nLeaveId);							
			else
				nPlayerCountB = nPlayerCountB + 1;
				table.insert(tbPlayerMatchListB, nId);							
				szMatchMsgB = szMatchMsgB .. "\n对手：" .. pPlayer.szName .."  ".. Player:GetFactionRouteName(pPlayer.nFaction, pPlayer.nRouteId) .. "  " .. pPlayer.nLevel .."级";
				szLookMsgB = szLookMsgB .. "\n成员：" .. pPlayer.szName .."  ".. Player:GetFactionRouteName(pPlayer.nFaction, pPlayer.nRouteId) .. "  " .. pPlayer.nLevel .."级";
			end
		end
	end
	
	--阵营1
	local nCaptionAId = 0;
	for _, nId in pairs(tbPlayerMatchListA) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer then
			if nCaptionAId == 0 then
				KTeam.CreateTeam(nId);	--建立队伍
				nCaptionAId = nId;
			else
				KTeam.ApplyJoinPlayerTeam(nCaptionAId, nId);	--加入队伍
			end
			Wldh.MACTH_ENTER_FLAG[nId] = 1;
			tbMission:AddLeague(pPlayer, pPlayer.szName, tbLeagueA.szName, tbLeagueB.szName);
			pPlayer.NewWorld(nMatchPatch, nPosX, nPosY);
			tbMission:JoinGame(pPlayer, 1);
			pPlayer.Msg(szMatchMsgB);
		end
	end
	
	--阵营2
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
			Wldh.MACTH_ENTER_FLAG[nId] = 1;
			tbMission:AddLeague(pPlayer, pPlayer.szName, tbLeagueB.szName, tbLeagueA.szName);
			pPlayer.NewWorld(nMatchPatch, nPosX, nPosY);
			tbMission:JoinGame(pPlayer, 2)
			pPlayer.Msg(szMatchMsgA);
		end
	end
	
	self.GroupList[nType][nReadyId][tbLeagueB.szName] = nil;
	self.GroupList[nType][nReadyId][tbLeagueA.szName] = nil;	
end

function Wldh:GameMatchAdv(nIsFinal, nType, nReadyId, tbSortLeague)
	local nLGType = self:GetLGType(nType);
	local tbLeagueListA = {};
	local tbLeagueListB = {};
	for nRank=1, math.floor(Wldh.MACTH_STATE_ADV_TASK[nIsFinal]/2) do
		if not self.AdvMatchLists[nType] or not self.AdvMatchLists[nType][nReadyId] then
			break;
		end
		local tbList = self.AdvMatchLists[nType][nReadyId][Wldh.MACTH_STATE_ADV_TASK[nIsFinal]];
		local tbLeagueA = tbList[nRank];
		local tbLeagueB = tbList[Wldh.MACTH_STATE_ADV_TASK[nIsFinal] - nRank + 1];

		--都有对手情况
		if tbLeagueA and tbLeagueB then
			local szAName = tbLeagueA.szName;
			local szBName = tbLeagueB.szName;
			local nAId, tbLeagueA1 = self:GameMatchAdvLeagueInfo(szAName, tbSortLeague);
			local nBId, tbLeagueB1 = self:GameMatchAdvLeagueInfo(szBName, tbSortLeague);

			--对手都在场
			if tbLeagueA1 and tbLeagueB1 then
				table.insert(tbLeagueListA, tbLeagueA1);
				table.insert(tbLeagueListB, tbLeagueB1);
				tbSortLeague[nAId] = nil;
				tbSortLeague[nBId] = nil;
			elseif not tbLeagueA1 and not tbLeagueB1 then--对手都不在场
				local szWinName = szAName;
				local szLostName = szBName;
				if tbLeagueA.nRank > tbLeagueB.nRank then
					szWinName = szBName;
					szLostName = szAName;
				end
				self:MacthAward(nType, nIsFinal, szWinName, szLostName, {}, 2, 0, nReadyId);
				self:MacthAward(nType, nIsFinal, szLostName, szWinName, {}, 2, 0, nReadyId);
			else
				local szWinName = szAName;
				local szLostName = szBName;
				if tbLeagueB1 then
					szWinName = szBName;
					szLostName = szAName;
				end
				self:MacthAward(nType, nIsFinal, szWinName, szLostName, {}, 1, 0, nReadyId);
				self:MacthAward(nType, nIsFinal, szLostName, szWinName, {}, 3, 0, nReadyId);				
				self:GameMatchAdvKickLeague(tbLeagueA1 or tbLeagueB1, nType, nReadyId, "因为你的对手缺席比赛，你战队获得了胜利");
				tbSortLeague[nAId] = nil;
				tbSortLeague[nBId] = nil;
			end
		elseif tbLeagueA or tbLeagueB then
			--无对手情况，直接获胜
			
			local tbWinLeague = tbLeagueA or tbLeagueB;
			local szWinName = tbWinLeague.szName;
			self:MacthAward(nType, nIsFinal, szWinName, nil, {}, 1, 0, nReadyId);
			local nAId, tbLeagueA1 = self:GameMatchAdvLeagueInfo(szWinName, tbSortLeague);
			if tbLeagueA1 then
				self:GameMatchAdvKickLeague(tbLeagueA1, nType, nReadyId, "因为你没有对手，你战队直接获得了胜利");
				tbSortLeague[nAId] = nil;
			end
		end
	end
	
	--其他人全部提出场地
	for _, tbLeague in pairs(tbSortLeague) do
		Wldh:GameMatchAdvKickLeague(tbLeague, nType, nReadyId, "您的战队没有资格参加武林大会决赛")
	end
	
	return tbLeagueListA, tbLeagueListB;
end

function Wldh:GameMatchAdvLeagueInfo(szName, tbSortLeague)
	local tbLeagueA1 = nil;
	local nAId = 0;
	for nId, tbLeague in pairs(tbSortLeague) do
		if tbLeague.szName == szName then
			tbLeagueA1 = tbLeague;
			nAId = nId;
			break;
		end
	end
	return nAId, tbLeagueA1;
end

function Wldh:GameMatchAdvKickLeague(tbLeague, nType, nReadyId, szMsg)
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
			nLeaveId = self:KickPlayer(pPlayer, szMsg, nType, nLeaveId);
			Dialog:SendBlackBoardMsg(pPlayer, szMsg);
		end
	end
	self.GroupList[nType][nReadyId][tbLeague.szName] = nil;	
end
