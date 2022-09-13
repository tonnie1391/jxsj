--武林联赛
--孙多良
--2008.09.11
if (MODULE_GC_SERVER) then
	return 0;
end

function Wlls:CheckLeagueType(tbLimitList, tbMacthCfg)
	
	--性别检查
	if tbMacthCfg.nSex == Wlls.LEAGUE_TYPE_SEX_SINGLE then
		--同一性别关系
		local nSexFlag = -1;
		for _, nSex in pairs(tbLimitList.tbSex) do
			if nSexFlag == -1 then
				nSexFlag = nSex;
			else
				if nSexFlag ~= nSex then
					return 1, "本届联赛需要战队成员是同一性别组合。";
				end
			end
		end
		
	elseif tbMacthCfg.nSex == Wlls.LEAGUE_TYPE_SEX_MIX then
		--男女组合
		local nSexFlag = -1;
		for _, nSex in pairs(tbLimitList.tbSex) do
			if nSexFlag == -1 then
				nSexFlag = nSex;
			else
				if nSexFlag == nSex then
					return 1, "本届联赛需要战队成员是男女组合。";
				end
			end
		end		
	end
	
	
	--阵营检查
	if tbMacthCfg.nCamp == Wlls.LEAGUE_TYPE_CAMP_SINGLE then
		--同一阵营
		local nCampFlag = -1;
		for _, nCamp in pairs(tbLimitList.tbCamp) do
			if nCampFlag == -1 then
				nCampFlag = nCamp;
			else
				if nCampFlag ~= nCamp then
					return 1, "本届联赛需要战队成员是同一阵营组合。";
				end
			end
		end
		
	elseif tbMacthCfg.nCamp == Wlls.LEAGUE_TYPE_CAMP_MIX then
		--不同阵营
		local nCampFlag = -1;
		for _, nCamp in pairs(tbLimitList.tbCamp) do
			if nCampFlag == -1 then
				nCampFlag = nCamp;
			else
				if nCampFlag == nCamp then
					return 1, "本届联赛需要战队成员是不同阵营组合。";
				end
			end
		end
	end
	
	--五行检查 todo
	if tbMacthCfg.nSeries == Wlls.LEAGUE_TYPE_SERIES_SINGLE then
		--同一五行
		local nSeriesFlag = -1;
		for _, nSeries in pairs(tbLimitList.tbSeries) do
			if nSeriesFlag == -1 then
				nSeriesFlag = nSeries;
			else
				if nSeriesFlag ~= nSeries then
					return 1, "本届联赛需要战队成员是同一五行组合。";
				end
			end
		end
		
	elseif tbMacthCfg.nSeries == Wlls.LEAGUE_TYPE_SERIES_MIX then
		--不同五行
		local nSeriesFlag = -1;
		for _, nSeries in pairs(tbLimitList.tbSeries) do
			if nCampFlag == -1 then
				nSeriesFlag = nSeries;
			else
				if nSeriesFlag == nSeries then
					return 1, "本届联赛需要战队成员是不同五行组合。";
				end
			end
		end
	elseif tbMacthCfg.nSeries == Wlls.LEAGUE_TYPE_SERIES_RESTRAINT then -- 五行相克组队 这里暂时定五行相克赛限2人赛
		local nSeriesFlag = -1;
		for _, nSeries in pairs(tbLimitList.tbSeries) do
			if nSeriesFlag == -1 then
				nSeriesFlag = nSeries;
			else
				if nSeriesFlag == nSeries then
					return 1, "本届联赛需要战队成员是五行相克的组合。";
				else
					if (0 == self:IsSeriesRestraint(nSeriesFlag, nSeries)) then
						return 1, "本届联赛需要战队成员是五行相克的组合。";
					end
				end
			end
		end	
	end

	--门派检查 todo
	if tbMacthCfg.nFaction == Wlls.LEAGUE_TYPE_FACTION_SINGLE then
		--同一门派
		local nFactionFlag = -1;
		for _, nFaction in pairs(tbLimitList.tbFaction) do
			if nFactionFlag == -1 then
				nFactionFlag = nFaction;
			else
				if nFactionFlag ~= nFaction then
					return 1, "本届联赛需要战队成员是同一门派组合。";
				end
			end
		end
		
	elseif tbMacthCfg.nFaction == Wlls.LEAGUE_TYPE_FACTION_MIX then
		--不同门派
		local nFactionFlag = -1;
		for _, nFaction in pairs(tbLimitList.tbFaction) do
			if nFactionFlag == -1 then
				nFactionFlag = nFaction;
			else
				if nFactionFlag == nFaction then
					return 1, "本届联赛需要战队成员是不同门派组合。";
				end
			end
		end
	end
		
	--师徒检查 todo
	if tbMacthCfg.nTeacher == Wlls.LEAGUE_TYPE_TEACHER_MIX then
		--师徒组合
		local nOnlyTeacherId = 0;
		for nTeacherId, tbStudentId in pairs(tbLimitList.tbTeacher) do
			for nStudentId in pairs(tbStudentId) do
				if tbLimitList.tbTeacher[nStudentId] then
					nOnlyTeacherId = nTeacherId;
					break;
				end
			end
			if nOnlyTeacherId ~= 0 then
				break;
			end
		end
		if nOnlyTeacherId == 0 then
			return 1, "本届联赛需要战队成员是师徒组合。";
		end
		for nStudentId in pairs(tbLimitList.tbTeacher) do
			if nStudentId ~= nOnlyTeacherId then
				if not tbLimitList.tbTeacher[nOnlyTeacherId][nStudentId] then
					return 1, "本届联赛需要战队成员是师徒组合。";
				end
			end
		end
	end
	return 0
end

--检查建立战队是否符合赛制类型（返回1不符合，0为符合）
function Wlls:CheckCreateLeague(pMyPlayer, tbPlayerIdList, tbMacthTypeCfg, nGameLevel)
	if (not pMyPlayer) then
		return 1, "您的所有队友必须在这附近。";
	end
	local tbMacthCfg = tbMacthTypeCfg.tbMacthCfg;
	local tbLimitList = {
			tbSex = {};
			tbCamp = {};
			tbSeries = {};
			tbFaction = {};
			tbTeacher = {};
		};
	local nMapId, nPosX, nPosY	= pMyPlayer.GetWorldPos();
	local nTeamGateway = "";
	if (GLOBAL_AGENT) then
		nTeamGateway = Transfer:GetMyGateway(pMyPlayer);
	end
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
		
		if pPlayer.nLevel < Wlls.PLAYER_ATTEND_LEVEL then
			return 1, string.format("队伍中<color=yellow>%s<color>等级低于%s级，必须等级达到%s级才能参加联赛。", pPlayer.szName, Wlls.PLAYER_ATTEND_LEVEL, Wlls.PLAYER_ATTEND_LEVEL);
		end
		
		if pPlayer.GetCamp() == 0 then
			return 1, string.format("队伍中<color=yellow>%s<color>还没有加入门派，只有加入门派的侠士侠女才能参加。", pPlayer.szName);
		end

		local nMyLevel = Wlls:GetGameLevelForRank(pPlayer.szName, nGameLevel);	
		local szGameLevelName = Wlls.MACTH_LEVEL_NAME[nGameLevel];
		if (GLOBAL_AGENT and GbWlls:CheckOpenGoldenGbWlls() == 1) then
			szGameLevelName = GbWlls.MACTH_LEVEL_NAME[nGameLevel];
		end
		
		if (not GLOBAL_AGENT) then
			if nMyLevel > nGameLevel then
				return 1, string.format("此地乃%s武林联赛，是为选拔江湖中的后起之秀，队伍中的大侠<color=yellow>%s<color>已不适合参加初级武林联赛了，还是让这位大侠去参加高级武林联赛吧。", szGameLevelName, pPlayer.szName);
			end
		end
		
		if Wldh.Qualification:CheckMember(pPlayer) > 0 and tonumber(GetLocalDate("%Y%m%d")) < Wldh.OPEN_WLLS_DATA  then
			return 1, string.format("此地乃武林联赛，队伍中的大侠<color=yellow>%s<color>是拥有武林大会参赛资格的成员，武林大会期间不能参加本届武林联赛，只能参加武林大会。", pPlayer.szName);			
		end
		
		local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, pPlayer.szName);
		if szLeagueName then
			return 1, string.format("队伍中<color=yellow>%s<color>已有战队，建立战队时，队伍中的队员必须没有战队。", pPlayer.szName);
		end
		
		-- 只有在跨服的时候需要判断
		if (GLOBAL_AGENT) then
			local nMyTeamGateway = Transfer:GetMyGateway(pPlayer);
			if (nMyTeamGateway ~= nTeamGateway) then
				return 1, string.format("队伍中<color=yellow>%s<color>和队长不是同一个服务器的玩家，建立战队时队伍中的队员必须是同一原服的玩家。", pPlayer.szName);
			end
			
			local nMoneyRank	= pPlayer.GetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_MONEY_RANK);
			local nWllsRank		= pPlayer.GetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_WLLS_RANK);

			if ((nMoneyRank <= 0 or nMoneyRank > GbWlls.DEF_MAXGBWLLS_MONEY_RANK) and (nWllsRank <= 0 or nWllsRank > GbWlls.DEF_MAXGBWLLS_WLLS_RANK)) then
				return 1, string.format("只有财富荣誉前%d名，联赛荣誉排名前%d名的玩家才能报名参加跨服武林联赛。", GbWlls.DEF_MAXGBWLLS_MONEY_RANK, GbWlls.DEF_MAXGBWLLS_WLLS_RANK);
			end
			
			local nEnterFlag = GbWlls:GetGbWllsEnterFlag(pPlayer);
			if (nEnterFlag ~= 1) then
				return 1, string.format("队伍中<color=yellow>%s<color>没有通过跨服联赛报名官报名进入，不能建立战队。", pPlayer.szName);
			end
			
			local nSession = self:GetMacthSession()
			local nCheckMatchJoinFlag = self:CheckPlayerJoinMatch(pPlayer, nSession, nGameLevel);
			if (1 ~= nCheckMatchJoinFlag) then
				return 1, string.format("队伍中<color=yellow>%s<color>达到参加黄金联赛的要求，只能参加黄金联赛！", pPlayer.szName);
			end
		end
		
		local nQuFlag = GbWlls:CheckWllsQualition(pPlayer);
		if (nQuFlag == 0) then
			local szMsg = "队伍中<color=yellow>%s<color>已经报名参加了跨服联赛，无法参加这里的武林联赛！";
			if (GLOBAL_AGENT) then
				szMsg = "队伍中<color=yellow>%s<color>已经报名参加了原服的武林联赛，无法参加这里的武林联赛！"; 
			end
			return 1, string.format(szMsg, pPlayer.szName);
		end

		table.insert(tbLimitList.tbSex, pPlayer.nSex);
		table.insert(tbLimitList.tbCamp, pPlayer.GetCamp());
		table.insert(tbLimitList.tbSeries, pPlayer.nSeries);
		table.insert(tbLimitList.tbFaction, pPlayer.nFaction);
		
		tbLimitList.tbTeacher[nPlayerId] = {};
		local tbStudent = pPlayer.GetTrainingStudentList();
		if tbStudent and #tbStudent > 0 then
			for _,szStudentName in ipairs(tbStudent) do
				local nStudentPlayerId = KGCPlayer.GetPlayerIdByName(szStudentName);
				tbLimitList.tbTeacher[nPlayerId][nStudentPlayerId] = 1;
			end
		end
	end
	
	--人数检查
	if #tbPlayerIdList > tbMacthCfg.nMemberCount then
		return 1, string.format("您的队伍人数不符合本届联赛人数需求，本届联赛最多只允许<color=yellow>%s名<color>成员组成战队参加比赛。", tbMacthCfg.nMemberCount);
	end
	
	local nFlag, szMsg = Wlls:CheckLeagueType(tbLimitList, tbMacthCfg)
	if nFlag == 1 then
		return 1, szMsg;
	end
	local szReturnMsg = "成功建立战队！";
	if #tbPlayerIdList < tbMacthCfg.nMemberCount then
		szReturnMsg = string.format("成功建立战队！你的战队<color=yellow>人数未满<color>，你可以在<color=yellow>联赛官员<color>处，让其他玩家加入你的战队，一起参加比赛。");
	end	
	return 0, szReturnMsg;
end

--检查加入战队是否符合赛制类型（返回1不符合，0为符合）
function Wlls:CheckJoinLeague(pMyPlayer, szLeagueName, tbPlayerIdList, tbJoinPlayerList, tbMacthTypeCfg, nGameLevel)
	if (not pMyPlayer) then
		return 1, "您的所有队友必须在这附近。";
	end
	local tbMacthCfg = tbMacthTypeCfg.tbMacthCfg;
	local tbLimitList = {
			tbSex = {};
			tbCamp = {};
			tbSeries = {};
			tbFaction = {};
			tbTeacher = {};
		};
	local tbJoinList = {};
	local nMapId, nPosX, nPosY	= pMyPlayer.GetWorldPos();
	local nTeamGateway = "";
	if (GLOBAL_AGENT) then
		nTeamGateway = Transfer:GetMyGateway(pMyPlayer);
	end

	local szGameLevelName = Wlls.MACTH_LEVEL_NAME[nGameLevel];
	if (GLOBAL_AGENT and GbWlls:CheckOpenGoldenGbWlls() == 1) then
		szGameLevelName = GbWlls.MACTH_LEVEL_NAME[nGameLevel];
	end
	for _, tbPlayer in pairs(tbJoinPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(tbPlayer.nId);
		if not pPlayer then
			return 1, "您的所有队友必须在这附近。";
		end
		local nMapId2, nPosX2, nPosY2	= pPlayer.GetWorldPos();
		local nDisSquare = (nPosX - nPosX2)^2 + (nPosY - nPosY2)^2;
		if nMapId2 ~= nMapId or nDisSquare > 400 then
			return 1, "您的所有队友必须在这附近。";
		end	
		if pPlayer.nLevel < Wlls.PLAYER_ATTEND_LEVEL then
			return 1, string.format("队伍中<color=yellow>%s<color>等级低于%s级，必须等级达到%s级才能参加联赛。", pPlayer.szName, Wlls.PLAYER_ATTEND_LEVEL, Wlls.PLAYER_ATTEND_LEVEL);
		end
		if pPlayer.GetCamp() == 0 then
			return 1, string.format("队伍中<color=yellow>%s<color>还没有加入门派，只有加入门派的侠士侠女才能参加。", pPlayer.szName);
		end
		
		local nMyLevel = Wlls:GetGameLevelForRank(pPlayer.szName, nGameLevel);
		
		if (not GLOBAL_AGENT) then
			if nMyLevel > nGameLevel then
				return 1, string.format("此地乃初级武林联赛，是为选拔江湖中的后起之秀，队伍中的大侠<color=yellow>%s<color>已不适合参加初级武林联赛了，还是让这位大侠去参加高级武林联赛吧。", pPlayer.szName);
			end
		end
		
		if Wldh.Qualification:CheckMember(pPlayer) > 0 and tonumber(GetLocalDate("%Y%m%d")) < Wldh.OPEN_WLLS_DATA  then
			return 1, string.format("此地乃武林联赛，队伍中的大侠<color=yellow>%s<color>是拥有武林大会参赛资格的成员，武林大会期间不能参加本届武林联赛，只能参加武林大会。", pPlayer.szName);			
		end		
	
		local szLeagueName2 = League:GetMemberLeague(Wlls.LGTYPE, pPlayer.szName);
		if szLeagueName2 and szLeagueName ~= szLeagueName2  then
			return 1, string.format("队伍中<color=yellow>%s<color>已有战队，加入战队时，加入的队员必须没有战队。", pPlayer.szName);
		end
		
		if (szLeagueName2) then
			local nTeamLevel = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName2, Wlls.LGTASK_MLEVEL);
			local szGameLevelName1 = Wlls.MACTH_LEVEL_NAME[nTeamLevel];
			if (GLOBAL_AGENT and GbWlls:CheckOpenGoldenGbWlls() == 1) then
				szGameLevelName1 = GbWlls.MACTH_LEVEL_NAME[nTeamLevel];
			end
			if (nTeamLevel ~= nGameLevel) then
				Dialog:Say(string.format("队伍中<color=yellow>%s<color>已经报名参加了%武林联赛，不能加入%s武林联赛！", pPlayer.szName, szGameLevelName1, szGameLevelName));
				return 0;
			end
		end
		
		-- 只有在跨服的时候需要判断
		if (GLOBAL_AGENT) then
			local nMyTeamGateway = Transfer:GetMyGateway(pPlayer);
			if (nMyTeamGateway ~= nTeamGateway) then
				return 1, string.format("队伍中<color=yellow>%s<color>和队长不是同一个服务器的玩家，建立战队时队伍中的队员必须是同一原服的玩家。", pPlayer.szName);
			end

			local nMoneyRank	= pPlayer.GetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_MONEY_RANK);
			local nWllsRank		= pPlayer.GetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_WLLS_RANK);

			if ((nMoneyRank <= 0 or nMoneyRank > GbWlls.DEF_MAXGBWLLS_MONEY_RANK) and (nWllsRank <= 0 or nWllsRank > GbWlls.DEF_MAXGBWLLS_WLLS_RANK)) then
				return 1, string.format("只有财富荣誉前%d名，联赛荣誉排名前%d名的玩家才能报名参加跨服武林联赛。", GbWlls.DEF_MAXGBWLLS_MONEY_RANK, GbWlls.DEF_MAXGBWLLS_WLLS_RANK);
			end
			
			local nEnterFlag = GbWlls:GetGbWllsEnterFlag(pPlayer);
			if (nEnterFlag ~= 1) then
				return 1, string.format("队伍中<color=yellow>%s<color>没有通过跨服联赛报名官报名进入，不能加入战队。", pPlayer.szName);
			end

			local nSession = self:GetMacthSession()
			local nCheckMatchJoinFlag = self:CheckPlayerJoinMatch(pPlayer, nSession, nGameLevel);
			if (1 ~= nCheckMatchJoinFlag) then
				return 1, string.format("队伍中<color=yellow>%s<color>达到参加黄金联赛的要求，只能参加黄金联赛！", pPlayer.szName);
			end
		end
		
		local nQuFlag = GbWlls:CheckWllsQualition(pPlayer);
		if (nQuFlag == 0) then
			local szMsg = "队伍中<color=yellow>%s<color>已经报名参加了跨服联赛，无法参加这里的武林联赛！";
			if (GLOBAL_AGENT) then
				szMsg = "队伍中<color=yellow>%s<color>已经报名参加了原服的武林联赛，无法参加这里的武林联赛！"; 
			end
			return 1, string.format(szMsg, pPlayer.szName);
		end
		
		if not szLeagueName2 then
			table.insert(tbJoinList, tbPlayer.nId);
		end
		table.insert(tbLimitList.tbSex, pPlayer.nSex);
		table.insert(tbLimitList.tbCamp, pPlayer.GetCamp());
		table.insert(tbLimitList.tbSeries, pPlayer.nSeries);
		table.insert(tbLimitList.tbFaction, pPlayer.nFaction);
		
		tbLimitList.tbTeacher[tbPlayer.nId] = {};
		local tbStudent = pPlayer.GetTrainingStudentList();
		if tbStudent and #tbStudent > 0 then
			for _,szStudentName in ipairs(tbStudent) do
				local nStudentPlayerId = KGCPlayer.GetPlayerIdByName(szStudentName);
				tbLimitList.tbTeacher[tbPlayer.nId][nStudentPlayerId] = 1;
			end
		end
	end
	
	local nSType = Wlls:GetMacthTypeCfg(Wlls:GetMacthType()).tbMacthCfg.nSeries;
	local szMsg	= "";
	local nFlag	= 0;
	if (nSType and Wlls.LEAGUE_TYPE_SERIES_RESTRAINT == nSType or Wlls:GetMacthLevelCfgType() == Wlls.MAP_LINK_TYPE_SERIES) then
		local nSer=-1;
		szMsg = "当前队伍成员的五行为：";
		if (tbPlayerIdList) then
			for nId, szMName in ipairs(tbPlayerIdList) do
				local pPlayer	= KPlayer.GetPlayerByName(szMName);
				local nSeries	= League:GetMemberTask(Wlls.LGTYPE, szLeagueName, szMName, Wlls.LGMTASK_SERIES);

				szMsg = string.format("%s队员：%s，报名五行：%s，", szMsg, szMName, string.format(Wlls.SERIES_COLOR[nSeries], Env.SERIES_NAME[nSeries]));
				
				if (pPlayer.nSeries ~= nSeries) then
					nFlag = 1;
				end;
			end;
		end;
	end;

	if (1 == nFlag) then
		return 1, string.format("%s队伍中有成员的五行和报名时五行不一致，请先更换为报名时的五行！", szMsg);
	end
	
	--人数检查
	if #tbJoinList <= 0 then
		return 1, string.format("您的战队中没有符合资格申请进入的成员。");		
	end	
	if #tbPlayerIdList + (#tbJoinList) > tbMacthCfg.nMemberCount then
		return 1, string.format("您的战队已有<color=yellow>%s<color>名成员，现在有<color=yellow>%s<color>名成员申请加入，已超过本届联赛战队所需人数。", #tbPlayerIdList, #tbJoinList);
	end
	local nFlag, szMsg = Wlls:CheckLeagueType(tbLimitList, tbMacthCfg)
	if nFlag == 1 then
		return 1, szMsg;
	end
	return 0;
end

--玩家进入准备场比赛场地
function Wlls:SetStateJoinIn(nGroupId)
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
function Wlls:LeaveGame()
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
function Wlls:GameMatch(tbLeagueList)
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
function Wlls:GameMatchAdv(nGameLevel, nReadyId, tbSortLeague)
	if nGameLevel ~= Wlls.MACTH_ADV or Wlls.AdvMatchState <= 0 then
		for _, tbLeague in pairs(tbSortLeague) do
			Wlls:GameMatchAdvKickLeague(tbLeague, nGameLevel, nReadyId, "您的战队没有资格参加高级联赛决赛")			
		end
		return nil;
	end
	
	local tbAdvLeagueList = {};
	for _, tbLeague in pairs(tbSortLeague) do
		if tbLeague.nRank == 0 or tbLeague.nRank > 8 then
			Wlls:GameMatchAdvKickLeague(tbLeague, nGameLevel, nReadyId, "您的战队没有资格参加高级联赛决赛")
		else
			if Wlls.MACTH_STATE_ADV_TASK[Wlls.AdvMatchState] == 8 then
				tbAdvLeagueList[tbLeague.nRank] = tbLeague;
			elseif Wlls.MACTH_STATE_ADV_TASK[Wlls.AdvMatchState] == 4 then
				local nSeries = Wlls:GetAdvMatchSeries(tbLeague.nRank, 8);
				tbAdvLeagueList[nSeries] = tbLeague;
			elseif Wlls.MACTH_STATE_ADV_TASK[Wlls.AdvMatchState] == 2 then
				local nSeries = Wlls:GetAdvMatchSeries(tbLeague.nRank, 4);
				tbAdvLeagueList[nSeries] = tbLeague;				
			end
		end
	end
	
	local tbLeagueA = {};
	local tbLeagueB = {};

	--八强赛
	if Wlls.MACTH_STATE_ADV_TASK[Wlls.AdvMatchState] == 8 then
		for nRank = 1, 4 do 
			local nVsLeagueRank = 9 - nRank;
			local tbLeagueA1, tbLeagueB1 = Wlls:GetGameMatchAdvLogic1(tbAdvLeagueList, nGameLevel, nReadyId, nRank, nVsLeagueRank, 4, 8);
			if tbLeagueA1 and tbLeagueB1 then
				table.insert(tbLeagueA, tbLeagueA1);
				table.insert(tbLeagueB, tbLeagueB1);		
			end
		end
	end
	
	--四强赛
	if Wlls.MACTH_STATE_ADV_TASK[Wlls.AdvMatchState] == 4 then
		for nRank = 1, 2 do 
			local nVsLeagueRank = nRank + 2;
			local tbLeagueA1, tbLeagueB1 = Wlls:GetGameMatchAdvLogic1(tbAdvLeagueList, nGameLevel, nReadyId, nRank, nVsLeagueRank, 2, 4);
			if tbLeagueA1 and tbLeagueB1 then
				table.insert(tbLeagueA, tbLeagueA1);
				table.insert(tbLeagueB, tbLeagueB1);		
			end
		end
	end
	
	--决赛
	if Wlls.MACTH_STATE_ADV_TASK[Wlls.AdvMatchState] == 2 then
		local nRank = 1; 
		local nVsLeagueRank = 2;
		local tbLeagueA1, tbLeagueB1 = Wlls:GetGameMatchAdvLogic2(tbAdvLeagueList, nGameLevel, nReadyId);
		if tbLeagueA1 and tbLeagueB1 then
			table.insert(tbLeagueA, tbLeagueA1);
			table.insert(tbLeagueB, tbLeagueB1);		
		end
	end
	return tbLeagueA, tbLeagueB;
end

function Wlls:GetGameMatchAdvLogic1(tbAdvLeagueList, nGameLevel, nReadyId, nRank, nVsLeagueRank, nWinCamp, nLostCamp)
	if not tbAdvLeagueList[nRank] and not tbAdvLeagueList[nVsLeagueRank] then
		if Wlls.AdvMatchLists[nReadyId][nLostCamp][nRank] then
			Wlls.AdvMatchLists[nReadyId][nWinCamp][nRank] = Wlls.AdvMatchLists[nReadyId][nLostCamp][nRank];
			local szLeagueName = Wlls.AdvMatchLists[nReadyId][nWinCamp][nRank].szName;
			League:SetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_RANK_ADV, nWinCamp);
			self:SetTeamPlayerAdvRank(szLeagueName, nWinCamp);
		end
		if Wlls.AdvMatchLists[nReadyId][nLostCamp][nVsLeagueRank] then
			local szLeagueName = Wlls.AdvMatchLists[nReadyId][nLostCamp][nVsLeagueRank].szName;
			League:SetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_RANK_ADV, nLostCamp);
			self:SetTeamPlayerAdvRank(szLeagueName, nLostCamp);
		end
		return 0;	
	end
	
	if not tbAdvLeagueList[nRank] and tbAdvLeagueList[nVsLeagueRank] then
		if Wlls.AdvMatchLists[nReadyId][nLostCamp][nRank] then
			local szLeagueName = Wlls.AdvMatchLists[nReadyId][nLostCamp][nRank].szName;
			League:SetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_RANK_ADV, nLostCamp);
			self:SetTeamPlayerAdvRank(szLeagueName, nLostCamp);
		end
		if Wlls.AdvMatchLists[nReadyId][nLostCamp][nVsLeagueRank] then
			local szLeagueName = Wlls.AdvMatchLists[nReadyId][nLostCamp][nVsLeagueRank].szName;
			League:SetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_RANK_ADV, nWinCamp);
			self:SetTeamPlayerAdvRank(szLeagueName, nWinCamp);
		end
		Wlls:MacthAward(tbAdvLeagueList[nVsLeagueRank].szName, nil, {}, 1, 0);
		Wlls:GameMatchAdvKickLeague(tbAdvLeagueList[nVsLeagueRank], nGameLevel, nReadyId, "因为你的对手缺席比赛，你战队获得了胜利");			
		return 0;
	end
	
	if tbAdvLeagueList[nRank] and not tbAdvLeagueList[nVsLeagueRank] then
		if Wlls.AdvMatchLists[nReadyId][nLostCamp][nRank] then
			local szLeagueName = Wlls.AdvMatchLists[nReadyId][nLostCamp][nRank].szName;
			League:SetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_RANK_ADV, nWinCamp);
			self:SetTeamPlayerAdvRank(szLeagueName, nWinCamp);
		end
		if Wlls.AdvMatchLists[nReadyId][nLostCamp][nVsLeagueRank] then
			local szLeagueName = Wlls.AdvMatchLists[nReadyId][nLostCamp][nVsLeagueRank].szName;
			League:SetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_RANK_ADV, nLostCamp);
			self:SetTeamPlayerAdvRank(szLeagueName, nLostCamp);
		end
		Wlls:MacthAward(tbAdvLeagueList[nRank].szName, nil, {}, 1, 0);
		Wlls:GameMatchAdvKickLeague(tbAdvLeagueList[nRank], nGameLevel, nReadyId, "因为你的对手缺席比赛，你战队获得了胜利");
		return 0;
	end
	
	return tbAdvLeagueList[nRank], tbAdvLeagueList[nVsLeagueRank];
end

--1为获胜，2为平，3为输, 4为轮空获胜
function Wlls:GetGameMatchAdvLogic2(tbAdvLeagueList, nGameLevel, nReadyId)
	if not tbAdvLeagueList[1] and not tbAdvLeagueList[2] then
		if Wlls.AdvMatchLists[nReadyId][2][1] then
			Wlls.AdvMatchLists[nReadyId][2][1].tbResult[Wlls.AdvMatchState - 2] = 4;
		end
		if Wlls.AdvMatchLists[nReadyId][2][2] then
			Wlls.AdvMatchLists[nReadyId][2][2].tbResult[Wlls.AdvMatchState - 2] = 4;
		end
		if Wlls.AdvMatchLists[nReadyId][2][1] and Wlls.AdvMatchState == 5 then
			Wlls:SetAdvMacthResult(nReadyId);
		end
		return 0;	
	end
	
	if not tbAdvLeagueList[1] and tbAdvLeagueList[2] then
		if Wlls.AdvMatchLists[nReadyId][2][1] then
			Wlls.AdvMatchLists[nReadyId][2][1].tbResult[Wlls.AdvMatchState - 2] = 3;
		end
		if Wlls.AdvMatchLists[nReadyId][2][2] then
			Wlls.AdvMatchLists[nReadyId][2][2].tbResult[Wlls.AdvMatchState - 2] = 1;
		end
		Wlls:MacthAward(tbAdvLeagueList[2].szName, nil, {}, 1, 0);
		Wlls:GameMatchAdvKickLeague(tbAdvLeagueList[2], nGameLevel, nReadyId, "因为你的对手缺席比赛，你战队获得了胜利");			
		if Wlls.AdvMatchLists[nReadyId][2][1] and Wlls.AdvMatchState == 5 then
			Wlls:SetAdvMacthResult(nReadyId);
		end
		return 0;
	end
	
	if tbAdvLeagueList[1] and not tbAdvLeagueList[2] then
		if Wlls.AdvMatchLists[nReadyId][2][1] then
			Wlls.AdvMatchLists[nReadyId][2][1].tbResult[Wlls.AdvMatchState - 2] = 1;
		end
		if Wlls.AdvMatchLists[nReadyId][2][2] then
			Wlls.AdvMatchLists[nReadyId][2][2].tbResult[Wlls.AdvMatchState - 2] = 3;
		end
		Wlls:MacthAward(tbAdvLeagueList[1].szName, nil, {}, 1, 0);
		Wlls:GameMatchAdvKickLeague(tbAdvLeagueList[1], nGameLevel, nReadyId, "因为你的对手缺席比赛，你战队获得了胜利");
		if Wlls.AdvMatchLists[nReadyId][2][1] and Wlls.AdvMatchState == 5 then
			Wlls:SetAdvMacthResult(nReadyId);
		end
		return 0;
	end
	
	return tbAdvLeagueList[1], tbAdvLeagueList[2];
end

function Wlls:GameMatchAdvKickLeague(tbLeague, nGameLevel, nReadyId, szMsg)
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
			nLeaveId = self:KickPlayer(pPlayer, szMsg, nGameLevel, nLeaveId);
			Dialog:SendBlackBoardMsg(pPlayer, szMsg);
		end
	end
	
	if Wlls.tbLook and Wlls.tbLook[nReadyId] and Wlls.tbLook[nReadyId][tbLeague.szName] then
		for nLookerId in pairs(Wlls.tbLook[nReadyId][tbLeague.szName]) do
			local pLookPlayer = KPlayer.GetPlayerObjById(nLookerId);
			Looker:Leave(pLookPlayer)
			pLookPlayer.Msg(string.format("你观看的战队<color=yellow>%s<color>因为没有对手直接获得了胜利。", tbLeague.szName))
		end
		Wlls.tbLook[nReadyId][tbLeague.szName] = nil;
	end
	
	self.GroupList[nGameLevel][nReadyId][tbLeague.szName] = nil;	
end

--进入比赛场匹配规则
function Wlls:EnterPkMapRule(nGameLevel)
	for nReadyId, tbMission in pairs(self.MissionList[nGameLevel]) do
		if not self.GroupList[nGameLevel][nReadyId] then
			self.GroupList[nGameLevel][nReadyId] = {};
		end
		--传送进入比赛场地,匹配原则;
		local tbSortLeague = {};
		for szLeagueName, tbLeague in pairs(self.GroupList[nGameLevel][nReadyId]) do
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
		if Wlls:GetMacthState() == Wlls.DEF_STATE_ADVMATCH and nGameLevel == Wlls.MACTH_ADV then
			local tbLeagueA, tbLeagueB = Wlls:GameMatchAdv(nGameLevel, nReadyId, tbSortLeague);
			if (tbLeagueA) then
				for i in pairs(tbLeagueA) do
					Wlls:OnMacthPkStart(tbMission, nGameLevel, nReadyId, tbLeagueA[i], tbLeagueB[i], i);
				end
			end
			if Wlls.tbLook and Wlls.tbLook[nReadyId] then
				for szLookLeagueName, tbLooker in pairs(Wlls.tbLook[nReadyId]) do
					for nLookerId in pairs(tbLooker) do
						local pLookPlayer = KPlayer.GetPlayerObjById(nLookerId);
						Looker:Leave(pLookPlayer);
						pLookPlayer.Msg(string.format("你选择观战的队伍<color=yellow>%s<color>因为没有参赛，很遗憾的输掉了比赛。", szLookLeagueName));
					end
				end
				Wlls.tbLook[nReadyId] = nil;
			end
		elseif #tbSortLeague < Wlls.MACTH_LEAGUE_MIN then
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
						nLeaveId = self:KickPlayer(pPlayer, string.format("参赛队伍不足%s队，比赛无法开启", Wlls.MACTH_LEAGUE_MIN), nGameLevel, nLeaveId);
						Dialog:SendBlackBoardMsg(pPlayer, string.format("参赛队伍不足%s队，比赛无法开启", Wlls.MACTH_LEAGUE_MIN))
					end
				end
				League:SetLeagueTask(Wlls.LGTYPE, szName, Wlls.LGTASK_ENTER, 0);
				self.GroupList[nGameLevel][nReadyId][szName] = nil;
			end
			
			if tbMission:IsOpen() ~= 0 then
				tbMission:EndGame();
			end
		else
			--log统计
			KStatLog.ModifyAdd("wlls", string.format("%s级赛每天参赛队伍数",nGameLevel), "总量", #tbSortLeague);
			local tbEnterLeague = {};
			local tbLeaveLeague = {};
			local nMinPlayerPkNum = Wlls:GetMacthTypeCfg(Wlls:GetMacthType()).tbMacthCfg.nMinPlayerPkNum;
			
			if (nMinPlayerPkNum and nMinPlayerPkNum > 0) then
				for _, tbLeague in pairs(tbSortLeague) do
					if (tbLeague and tbLeague.tbPlayerList and #tbLeague.tbPlayerList >= nMinPlayerPkNum) then
						table.insert(tbEnterLeague, tbLeague);
					else
						table.insert(tbLeaveLeague, tbLeague);
					end
				end
				tbSortLeague = tbEnterLeague;
			end
			
			local tbLeagueA, tbLeagueB = Wlls:GameMatch(tbSortLeague);
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
					
					Wlls:MacthAward(tbLeagueA[i].szName, nil, tbAwardList, 4, Wlls.MACTH_TIME_BYE)
					--奖励
					
					local nLeaveId = nil;
					for nId, szName in pairs(tbAwardList) do
						local pPlayer = KPlayer.GetPlayerObjById(nId);
						if pPlayer then
							nLeaveId = self:KickPlayer(pPlayer, "本轮轮空", nGameLevel, nLeaveId);
							Dialog:SendBlackBoardMsg(pPlayer, "本轮轮空..")
						end					
					end
					self.GroupList[nGameLevel][nReadyId][tbLeagueA[i].szName] = nil;
					break;
				end
				
				Wlls:OnMacthPkStart(tbMission, nGameLevel, nReadyId, tbLeagueA[i], tbLeagueB[i], i);
			end
			
			for i, tbList in pairs(tbLeaveLeague) do
				local nLeaveId = nil;
				local tbTemp = Lib:CopyTB1(tbList.tbPlayerList);
				for j, nPlayerId in pairs(tbTemp) do
					local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
					if pPlayer then
						nLeaveId = self:KickPlayer(pPlayer, string.format("本队参加比赛的人数不足%d人不能比赛", nMinPlayerPkNum), nGameLevel, nLeaveId);
					end					
				end
				self.GroupList[nGameLevel][nReadyId][tbList.szName] = nil;
			end
		end
	end
end

function Wlls:OnMacthPkStart(tbMission, nGameLevel, nReadyId, tbLeagueA, tbLeagueB, nAearId)
	local nGamePlayerMax = Wlls:GetMacthTypeCfg(Wlls:GetMacthType()).tbMacthCfg.nPlayerCount;
	local nMatchPatch 	 = tbMission.nMacthMap;
	if nAearId > self.MAP_SELECT_MAX then
		nAearId = (nAearId - self.MAP_SELECT_MAX)
		nMatchPatch = tbMission.nMacthMapPatch;
	end
	
	if SubWorldID2Idx(nMatchPatch) < 0 then
		print("Error!!!", "武林联赛地图没有开启", nMatchPatch);
		return 0;
	end 
	
	local nPosX, nPosY = unpack(Wlls.PosGamePk[Wlls:GetMacthType()][nAearId]);
	--战队数据记录
	Wlls:AddMacthLeague(tbLeagueA.szName, tbLeagueB.nNameId);
	Wlls:AddMacthLeague(tbLeagueB.szName, tbLeagueA.nNameId);
	
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
				nLeaveId = self:KickPlayer(pPlayer, "你战队正式成员已进入比赛场，<color=yellow>你做为替补，请在会场等待结果<color>，如果离开了会场，将<color=yellow>无法获得你战队的比赛奖励<color>。", nGameLevel, nLeaveId);
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
				nLeaveId = self:KickPlayer(pPlayer, "你战队正式成员已进入比赛场，你做为替补，请在会场等待结果。", nGameLevel, nLeaveId);							
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
			Wlls.MACTH_ENTER_FLAG[nId] = 1;
			tbMission:AddLeague(pPlayer, pPlayer.szName, tbLeagueA.szName, tbLeagueB.szName);
			pPlayer.NewWorld(nMatchPatch, nPosX, nPosY);
			tbMission:JoinGame(pPlayer, 1);
			pPlayer.Msg(szMatchMsgB);
			local szLogMsg = string.format("OnMacthPkStart\t%s\t%s\t%s\t%s", tbLeagueA.szName, pPlayer.szName, Player:GetFactionRouteName(pPlayer.nFaction, pPlayer.nRouteId), pPlayer.nLevel);
			Wlls:WriteLog(szLogMsg);
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
			Wlls.MACTH_ENTER_FLAG[nId] = 1;
			tbMission:AddLeague(pPlayer, pPlayer.szName, tbLeagueB.szName, tbLeagueA.szName);
			pPlayer.NewWorld(nMatchPatch, nPosX, nPosY);
			tbMission:JoinGame(pPlayer, 2)
			pPlayer.Msg(szMatchMsgA);
			local szLogMsg = string.format("OnMacthPkStart\t%s\t%s\t%s\t%s", tbLeagueB.szName, pPlayer.szName, Player:GetFactionRouteName(pPlayer.nFaction, pPlayer.nRouteId), pPlayer.nLevel);
			Wlls:WriteLog(szLogMsg);
		end
	end
	
	if Wlls:GetMacthState() == Wlls.DEF_STATE_ADVMATCH and nGameLevel == Wlls.MACTH_ADV then	
		Wlls:AddLookerLeague(tbLeagueA.szName, nMatchPatch, nPosX, nPosY, tbMission);
		Wlls:AddLookerLeague(tbLeagueB.szName, nMatchPatch, nPosX, nPosY, tbMission);
	end
	
	--观战
	if Wlls.tbLook and Wlls.tbLook[nReadyId] and Wlls.tbLook[nReadyId][tbLeagueA.szName] then
		for nLookerId in pairs(Wlls.tbLook[nReadyId][tbLeagueA.szName]) do
			local pLookPlayer = KPlayer.GetPlayerObjById(nLookerId);
			if pLookPlayer then
				Wlls.tbLookerReady[pLookPlayer.nId] = 1;
				Looker:Join(pLookPlayer, Wlls.LOOK_PKID, nMatchPatch, nPosX, nPosY);
				pLookPlayer.Msg(szLookMsgA)
				pLookPlayer.Msg(szLookMsgB)
			end
		end
		Wlls.tbLook[nReadyId][tbLeagueA.szName] = nil;
	end
	
	if Wlls.tbLook and Wlls.tbLook[nReadyId] and Wlls.tbLook[nReadyId][tbLeagueB.szName] then
		for nLookerId in pairs(Wlls.tbLook[nReadyId][tbLeagueB.szName]) do
			local pLookPlayer = KPlayer.GetPlayerObjById(nLookerId);
			if pLookPlayer then	
				Wlls.tbLookerReady[pLookPlayer.nId] = 1;
				Looker:Join(pLookPlayer, Wlls.LOOK_PKID, nMatchPatch, nPosX, nPosY);
				pLookPlayer.Msg(szLookMsgA);
				pLookPlayer.Msg(szLookMsgB)
			end
		end
		Wlls.tbLook[nReadyId][tbLeagueB.szName] = nil;
	end
	
	self.GroupList[nGameLevel][nReadyId][tbLeagueB.szName] = nil;
	self.GroupList[nGameLevel][nReadyId][tbLeagueA.szName] = nil;	
end

--记录可以观战的战队数据
function Wlls:AddLookerLeague(szLeagueName, nMapId, nPosX, nPosY, tbMission)
	Wlls:AddLookerLeague_GS(szLeagueName, nMapId, nPosX, nPosY, tbMission); 
	GlobalExcute({"Wlls:AddLookerLeague_GS", szLeagueName, nMapId, nPosX, nPosY});
end

function Wlls:RemoveLookerLeague(szLeagueName)
	GlobalExcute({"Wlls:RemoveLookerLeague_GS", szLeagueName});
end

function Wlls:AddLookerLeague_GS(szLeagueName, nMapId, nPosX, nPosY, tbMission)
	self.LookerLeagueMap[szLeagueName] = self.LookerLeagueMap[szLeagueName] or {};
	self.LookerLeagueMap[szLeagueName][1] = nMapId;
	self.LookerLeagueMap[szLeagueName][2] = nPosX;
	self.LookerLeagueMap[szLeagueName][3] = nPosY;
	if tbMission then
		self.LookerLeagueMap[szLeagueName][4] = tbMission;
	end
end

function Wlls:RemoveLookerLeague_GS(szLeagueName)
	if self.LookerLeagueMap[szLeagueName] then
		self.LookerLeagueMap[szLeagueName] = nil;
	end
end

function Wlls:RepairAchievement()
	for _, nAchieId in pairs(Wlls.tbAchievementAttend) do
		if (Achievement:CheckFinished(nAchieId) == 0) then
			local nNum = Achievement:GetFinishNum(me, nAchieId);
			local tbInfo_Count = Achievement:_GetAchievementList_Count(nAchieId);
			if (tbInfo_Count and #tbInfo_Count > 0) then
				for _, tbInfo in pairs(tbInfo_Count) do
					if (nAchieId == tbInfo.nAchievementId and tbInfo.nCount <= nNum) then						
						Achievement:__FinishAchievement(nAchieId);
					end
				end
			end
		end
	end

	-- 修复上届联赛因为宝石问题没有完成就
	local nDeadline = tonumber(os.date("%Y%m%d", GetTime()));
	if (nDeadline > 20110827) then
		return;
	end
	
	local nLogTaskFlag = me.GetTask(self.TASKID_GROUP, self.TASKID_AWARD_LOG);
	local nGameLevel = math.floor(nLogTaskFlag / 1000000);
	nLogTaskFlag = math.fmod(nLogTaskFlag, 1000000);
	local nLevelSep = math.floor(nLogTaskFlag / 1000);
	nLogTaskFlag = math.fmod(nLogTaskFlag, 1000);
	local nSession = nLogTaskFlag;
	--local nLogTaskFlag = nSession + nLevelSep * 1000 + nGameLevel * 1000000;
	local nGameType = Wlls:GetMacthType(nSession);
	local tbAchievement = Wlls.tbAchievementRank_repair;
	if nGameLevel == Wlls.MACTH_ADV and not GLOBAL_AGENT and tbAchievement[nGameType] and nLevelSep > 0 then
		if nLevelSep <= tbAchievement[nGameType][1][1] then
			Achievement:FinishAchievement(me, tbAchievement[nGameType][1][2]);
		end
		if nLevelSep <= tbAchievement[nGameType][2][1] then
			Achievement:FinishAchievement(me, tbAchievement[nGameType][2][2]);
		end
		if nLevelSep <= tbAchievement[nGameType][3][1] then
			Achievement:FinishAchievement(me, tbAchievement[nGameType][3][2]);
		end
	end
end
