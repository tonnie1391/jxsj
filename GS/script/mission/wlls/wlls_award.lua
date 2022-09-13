--联赛奖励
--孙多良
--2008.09.23

--单场比赛奖励, 1为获胜, 2为平, 3为输, 4为轮空获胜
function Wlls:MacthAward(szLeagueName, szMatchLeagueName, tbMisPlayerList, nResult, nMacthTime)
	if (GLOBAL_AGENT) then
		Wlls:GbWllsMacthAward(szLeagueName, szMatchLeagueName, tbMisPlayerList, nResult, nMacthTime)
		return 0;
	end
	
	local tbMsg = 
	{
		[1] = {string.format("<color=yellow>Đội của bạn đánh bại chiến đội %s, xin chúc mừng. <color>", szMatchLeagueName or "")},
		[2] = {string.format("<color=green>Đội của bạn hòa với chiến đội %s, tiếp tục cố gắng. <color>", szMatchLeagueName or "")},
		[3] = {string.format("<color=blue>Đội của bạn thua chiến đội %s, tiếp tục cố gắng. <color>", szMatchLeagueName or "")},
		[4] = {string.format("<color=yellow>Đội của bạn bất ngờ giành chiến thắng. <color>")}
	}
	
	local nLeagueTotal 	= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TOTAL);
	local nLeagueWin 	= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_WIN);
	local nLeagueTie 	= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TIE);
	local nLeagueTime 	= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TIME);
	local nGameLevel 	= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MLEVEL);
	local nSession 		= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MSESSION);	
	local nReadyId		= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_ATTEND);
	local nMatchType	= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MTYPE);
	if nResult == 3 then
		--负方不累计比赛时间
		nMacthTime = 0;
	end
	local tbPlayerList = {};
	local tbPlayerObjList = {};
	--加荣誉点
	for _, szMemberName in ipairs(Wlls:GetLeagueMemberList(szLeagueName)) do
		local nHonor = 0;
		if nResult == 1 or nResult == 4 then
			if Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Win.honor then
				nHonor = tonumber(Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Win.honor[1]);
			end
		end
		if nResult == 2 then
			if Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Tie.honor then
				nHonor = tonumber(Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Tie.honor[1]);
			end
		end
		if nResult == 3 then
			if Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Lost.honor then
				nHonor = tonumber(Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Lost.honor[1]);
			end
		end
		Wlls:AddHonor(szMemberName, nHonor);
		local nId = KGCPlayer.GetPlayerIdByName(szMemberName);
		tbPlayerList[nId] = szMemberName;
	end

	local nPoint = 0;
	if nResult == 1 or nResult == 4 then
		nPoint = 3;
	end
	if nResult == 2 then
		nPoint = 1;
	end
	if nResult == 3 then
		nPoint = 0;
	end		
	local szStatLog = string.format("%s,%s,%s,%s,%s", szLeagueName,nSession,nMatchType,nGameLevel,nPoint);
	
	for nId, szName in pairs(tbPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer then
			pPlayer.Msg(tbMsg[nResult][1]);
			Dialog:SendBlackBoardMsg(pPlayer, tbMsg[nResult][1])
			--奖励
			pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_MATCH_TOTLE, pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_TOTLE) + 1);
			pPlayer.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_TOTLE, nLeagueTotal + 1);
			if nResult == 1 or nResult == 4 then
				pPlayer.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_MATCH_WIN, pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_WIN) + 1);
				pPlayer.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_WIN, nLeagueWin + 1);
				Wlls.Fun:DoExcute(pPlayer, Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Win);
				pPlayer.SendMsgToFriend("Hảo hữu [" ..pPlayer.szName.."] giành chiến thắng trong Võ Lâm Liên Đấu.");
				pPlayer.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_MATCH_WIN_AWARD, 10);
				if nGameLevel >= 2 then -- 高级联赛赢得比赛给玩家增加一次英雄令兑换武林大会声望的机会
					local nCount = pPlayer.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_YINGXIONGLING_AWARD);
					nCount = nCount + 1;
					if (nCount > self.YINGXIONGLING_MAX_TIMES) then
						nCount = self.YINGXIONGLING_MAX_TIMES;
					end
					pPlayer.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_YINGXIONGLING_AWARD, nCount);
				end
				--成就
				if (not GLOBAL_AGENT) then
					Achievement:FinishAchievement(pPlayer, Wlls.tbAchievementWinOne);
				end
				--成就
			end
			
			if nResult == 2 then
				pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_MATCH_TIE, pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_TIE) + 1);
				pPlayer.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_TIE, nLeagueTie + 1);
				Wlls.Fun:DoExcute(pPlayer, Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Tie);
			end
			if nResult == 3 then
				Wlls.Fun:DoExcute(pPlayer, Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Lost);
			end
			table.insert(tbPlayerObjList, pPlayer);
			
			-- 统计玩家参加武林联赛的场次
			Stats.Activity:AddCount(pPlayer, Stats.TASK_COUNT_WLLS, 1);
			
			Player:AddJoinRecord_DailyCount(pPlayer, Player.EVENT_JOIN_RECORD_WLLS, 1);
			Player:AddJoinRecord_MonthCount(pPlayer, Player.EVENT_JOIN_RECORD_WLLS, 1);
			-- 统计本月联赛积分
			Player:UpdateJoinRecord_WllsPoint(pPlayer);
		else
			--不在线,下次上线自动给予.
			League:SetMemberTask(self.LGTYPE, szLeagueName, szName, self.LGMTASK_AWARD, nResult)
		end
		Wlls:WriteLog(string.format("奖励队员:%s, %s Vs %s, 结果:%s", szName, szLeagueName, (szMatchLeagueName or ""), nResult));
		
		StatLog:WriteStatLog("stat_info", "local_wlls", "fight_result", nId,szStatLog);
	end
	
	if Wlls:GetMacthState() == Wlls.DEF_STATE_ADVMATCH then
		local nRank   = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_RANK);
		local nVsRank = 0;
		if szMatchLeagueName then
			nVsRank = League:GetLeagueTask(Wlls.LGTYPE, szMatchLeagueName, Wlls.LGTASK_RANK);
		end
		if Wlls.MACTH_STATE_ADV_TASK[Wlls.AdvMatchState] == 8 then
			if nResult == 1 or nResult == 4 or (nResult == 2 and nRank < nVsRank) then
				local nSeries = Wlls:GetAdvMatchSeries(nRank, 8);
				Wlls.AdvMatchLists[nReadyId][4][nSeries] = Wlls.AdvMatchLists[nReadyId][8][nRank];
				League:SetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_RANK_ADV, 4);
			end
		elseif Wlls.MACTH_STATE_ADV_TASK[Wlls.AdvMatchState] == 4 then
			if nResult == 1 or nResult == 4  or (nResult == 2 and nRank < nVsRank) then
				local nSeries = Wlls:GetAdvMatchSeries(nRank, 4);
				Wlls.AdvMatchLists[nReadyId][2][nSeries] = Wlls.AdvMatchLists[nReadyId][8][nRank];
				League:SetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_RANK_ADV, 2);
			end			
		elseif Wlls.MACTH_STATE_ADV_TASK[Wlls.AdvMatchState] == 2 then
			local nSeries = Wlls:GetAdvMatchSeries(nRank, 2);
			Wlls.AdvMatchLists[nReadyId][2][nSeries].tbResult[Wlls.AdvMatchState - 2] = nResult;
			--if Wlls.AdvMatchState == 5 then
			--	Wlls:SetAdvMacthResult();
			--end
		end
	else
		if nResult == 1 or nResult == 4 then
			League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_WIN, nLeagueWin + 1 );
			Wlls:WriteLog(string.format("胜利增加胜利场次:%s", szLeagueName));
		elseif nResult == 2 then
			League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TIE, nLeagueTie + 1);
		end
		League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TOTAL, nLeagueTotal + 1);
		League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TIME, nLeagueTime + nMacthTime);
	end
	League:SetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_ENTER, 0);
	--增加亲密度：
	for i =1, #tbPlayerObjList do 
		for j = i + 1, #tbPlayerObjList do
			if (tbPlayerObjList[i].IsFriendRelation(tbPlayerObjList[j].szName) == 1) then
				Relation:AddFriendFavor(tbPlayerObjList[i].szName, tbPlayerObjList[j].szName, 50);
				tbPlayerObjList[i].Msg(string.format("Độ thân mật giữ bạn và <color=yellow>%s<color> tăng lên %d điểm.", tbPlayerObjList[j].szName, 50));
				tbPlayerObjList[j].Msg(string.format("Độ thân mật giữ bạn và <color=yellow>%s<color> tăng lên %d điểm.", tbPlayerObjList[i].szName, 50));
			end
		end
	end
end

function Wlls:GbWllsMacthAward(szLeagueName, szMatchLeagueName, tbMisPlayerList, nResult, nMacthTime)
	if (not GLOBAL_AGENT) then
		return 0;
	end
	local tbMsg = 
	{
		[1] = {string.format("<color=yellow>Đội của bạn đánh bại chiến đội %s, xin chúc mừng.<color>", szMatchLeagueName or "")},
		[2] = {string.format("<color=green>Đội của bạn hòa với chiến đội %s, tiếp tục cố gắng.<color>", szMatchLeagueName or "")},
		[3] = {string.format("<color=blue>Đội của bạn thua chiến đội %s, tiếp tục cố gắng.<color>", szMatchLeagueName or "")},
		[4] = {string.format("<color=yellow>Đội của bạn bất ngờ giành chiến thắng.<color>")}
	}
	
	local nLeagueTotal 	= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TOTAL);
	local nLeagueWin 	= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_WIN);
	local nLeagueTie 	= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TIE);
	local nLeagueTime 	= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TIME);
	local nGameLevel 	= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MLEVEL);
	local nSession 		= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MSESSION);	
	local nReadyId		= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_ATTEND);
	local tbMemberList	= Wlls:GetLeagueMemberList(szLeagueName);
	for _, szMemberName in ipairs(tbMemberList) do
		Dbg:WriteLogEx(Dbg.LOG_INFO, "GbWllsMacthAward", szMemberName, szLeagueName, nResult, nMacthTime, nGameLevel);
	end
	if nResult == 3 then
		--负方不累计比赛时间
		nMacthTime = 0;
	end
	local tbPlayerList = {};
	local tbPlayerObjList = {};
	--加荣誉点
	for _, szMemberName in ipairs(tbMemberList) do
		local nId = KGCPlayer.GetPlayerIdByName(szMemberName);
		tbPlayerList[nId] = szMemberName;
	end
	local nPoint = 0;
	if nResult == 1 or nResult == 4 then
		nPoint = 3;
	end
	if nResult == 2 then
		nPoint = 1;
	end
	if nResult == 3 then
		nPoint = 0;
	end		
	local szStatLog = string.format("%s,%s,%s", szLeagueName,nGameLevel,nPoint);
	for nId, szName in pairs(tbPlayerList) do
		StatLog:WriteStatLog("stat_info", "kfwlls", "fight_result", nId, szStatLog);
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer then
			pPlayer.Msg(tbMsg[nResult][1]);
			Dialog:SendBlackBoardMsg(pPlayer, tbMsg[nResult][1])
		end
		if nResult == 1 or nResult == 4 then
			GbWlls:SetPlayerSportTask(szName, GbWlls.GBTASKID_MATCH_WIN_AWARD, GbWlls:GetPlayerSportTask(szName, GbWlls.GBTASKID_MATCH_WIN_AWARD) + 1);
			GbWlls:SetPlayerSportTask(szName, GbWlls.GBTASKID_MATCH_DAILY_RESULT, GetTime());
		end
		if nResult == 2 then
			GbWlls:SetPlayerSportTask(szName, GbWlls.GBTASKID_MATCH_TIE_AWARD, GbWlls:GetPlayerSportTask(szName, GbWlls.GBTASKID_MATCH_TIE_AWARD) + 1);
		end
		if nResult == 3 then
			GbWlls:SetPlayerSportTask(szName, GbWlls.GBTASKID_MATCH_LOSE_AWARD, GbWlls:GetPlayerSportTask(szName, GbWlls.GBTASKID_MATCH_LOSE_AWARD) + 1);
		end		
		Wlls:WriteLog(string.format("[跨服联赛]奖励队员:%s, %s Vs %s, 结果:%s", szName, szLeagueName, (szMatchLeagueName or ""), nResult))
	end
	
	if Wlls:GetMacthState() == Wlls.DEF_STATE_ADVMATCH then
		local nRank   = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_RANK);
		local nVsRank = 0;
		if szMatchLeagueName then
			nVsRank = League:GetLeagueTask(Wlls.LGTYPE, szMatchLeagueName, Wlls.LGTASK_RANK);
		end
		if Wlls.MACTH_STATE_ADV_TASK[Wlls.AdvMatchState] == 8 then
			if nResult == 1 or nResult == 4 or (nResult == 2 and nRank < nVsRank) then
				local nSeries = Wlls:GetAdvMatchSeries(nRank, 8);
				Wlls.AdvMatchLists[nReadyId][4][nSeries] = Wlls.AdvMatchLists[nReadyId][8][nRank];
				League:SetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_RANK_ADV, 4);
				self:SetTeamPlayerAdvRank(szLeagueName, 4);
			end
		elseif Wlls.MACTH_STATE_ADV_TASK[Wlls.AdvMatchState] == 4 then
			if nResult == 1 or nResult == 4  or (nResult == 2 and nRank < nVsRank) then
				local nSeries = Wlls:GetAdvMatchSeries(nRank, 4);
				Wlls.AdvMatchLists[nReadyId][2][nSeries] = Wlls.AdvMatchLists[nReadyId][8][nRank];
				League:SetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_RANK_ADV, 2);
				self:SetTeamPlayerAdvRank(szLeagueName, 2);
			end			
		elseif Wlls.MACTH_STATE_ADV_TASK[Wlls.AdvMatchState] == 2 then
			local nSeries = Wlls:GetAdvMatchSeries(nRank, 2);
			Wlls.AdvMatchLists[nReadyId][2][nSeries].tbResult[Wlls.AdvMatchState - 2] = nResult;
			--if Wlls.AdvMatchState == 5 then
			--	Wlls:SetAdvMacthResult();
			--end
		end
	else
		if nResult == 1 or nResult == 4 then
			League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_WIN, nLeagueWin + 1 );
			Wlls:WriteLog(string.format("[跨服联赛]胜利增加胜利场次:%s", szLeagueName));
		elseif nResult == 2 then
			League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TIE, nLeagueTie + 1);
		end
		League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TOTAL, nLeagueTotal + 1);
		League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TIME, nLeagueTime + nMacthTime);
	end
	League:SetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_ENTER, 0);
end

--检查领取单场胜利奖项
function Wlls:OnCheckAwardSingle(pPlayer)
	if pPlayer.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_MATCH_WIN_AWARD) == 10 then
		return 1;
	end
	return 0;
end

-- 检查单场胜利英雄令换声望奖项
function Wlls:OnCheckWldhRep(pPlayer)
	local nTaskMonth = pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_YINGXIONGLING_MONTH);
	local nMonth = tonumber(GetLocalDate("%Y%m"));
	if nTaskMonth ~= nMonth then
		pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_YINGXIONGLING_MONTH, nMonth);
		pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_YINGXIONGLING_TIMES, 0);
		pPlayer.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_YINGXIONGLING_AWARD, 0);
	end	
	
	if pPlayer.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_YINGXIONGLING_AWARD) <= 0 then
		return 0;
	end
	-- 判断是否高级联赛
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, pPlayer.szName);
	if not szLeagueName then
		return 0;
	end
	local nGameLevel = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MLEVEL)
	if nGameLevel < 2 then
		return 0;
	end
	if pPlayer.CheckLevelLimit(11, 1) == 1 then
		return 0;
	end
	return 1;
end

--领取单场胜利奖励
function Wlls:OnGetAwardSingle()
	if Wlls:OnCheckAwardSingle(me) == 0 then
		return 0;
	end
	local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("Wlls", me); 
	
	if me.CountFreeBagCell() < (1 + nFreeCount) then
		Dialog:Say(string.format("Hành trang không đủ %s ô trống.", (1 + nFreeCount)));
		return 0;
	end
	me.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_MATCH_WIN_AWARD, 0);
	local pItem = me.AddItem(18,1,259,1);
	if not pItem then
		Dbg:WriteLog("Wlls","领取联赛礼包失败", me.szName);
	end
	SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
	
	SpecialEvent.ActiveGift:AddCounts(me, 32);		--领取联赛奖励完成联赛活跃度
	Dialog:Say("Bạn nhận được 1 <color=yellow>Túi quà Liên Đấu<color>.");
	return 1;
end

Wlls.tbWldhReputeChange = {
		[1] = { "Nhẫn Bạch Ngân", 4800},
		[2] = { "Nhẫn Hoàng Kim", 9600},
	};
	
Wlls.BUY_WLDH_COIN = 660;

function Wlls:GetPlayerMaxReputeChangeCount(pPlayer)
	local nMaxCount = 0;
	local nReputeLevel = pPlayer.GetReputeLevel(11,1);
	local nReputeValue = pPlayer.GetReputeValue(11,1);
	local nNeedRepute = 0;
	
	for i, tbRepute in ipairs(self.tbWldhReputeChange) do
		if (i == nReputeLevel) then
			nNeedRepute = nNeedRepute + tbRepute[2] - nReputeValue;
		elseif (i > nReputeLevel) then
			nNeedRepute = nNeedRepute + tbRepute[2];
		end
	end

	local nLastCount = math.ceil(nNeedRepute / self.YINGXIONGLING_REPUTE);
	return nLastCount;
end

-- 武林大会英雄令换武林大会声望
function Wlls:OnGetAwardSingleWithWldhRep()
	if Wlls:OnCheckWldhRep(me) == 0 then
		Dialog:Say("Chưa đủ điều kiện!");
		return 0;
	end

	local nTaskTimes = me.GetTask(self.TASKID_GROUP, self.TASKID_YINGXIONGLING_TIMES);
	local nReputeLevel = me.GetReputeLevel(11,1);
	local nReputeValue = me.GetReputeValue(11,1);
	local tbRepute = self.tbWldhReputeChange[nReputeLevel];
	local nDet = tbRepute[2] - nReputeValue;
	local nLastCount = math.ceil(nDet / self.YINGXIONGLING_REPUTE);
	local nHaveChangeCount = me.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_YINGXIONGLING_AWARD);
	local nCanChangeCount = self.YINGXIONGLING_MAX_TIMES - nTaskTimes;
	
	if (nCanChangeCount < 0) then
		nCanChangeCount = 0;
	end
	
	local nCanFinialChange = math.min(nHaveChangeCount, nCanChangeCount);

	local szMsg = [[Ngươi có thể sử dụng 1 Anh Hào Lệnh đổi %s điểm Danh vọng Đại hội Võ lâm. 
Hiện tại có thể đổi được <color=yellow>%s<color> lần, để mua <color=yellow>%s<color>, cần %s lần nữa. Mỗi tháng chiến thắng %s lần trong liên đấu là có thể nhận tối đa. 
<color=green>Lưu ý: Số lần đổi thưởng mỗi tháng có giới hạn và chỉ có thể đổi ở tháng hiện tại, không cộng dồn qua tháng sau! <color>]];
	szMsg = string.format(szMsg, self.YINGXIONGLING_REPUTE, nCanFinialChange, tbRepute[1], nLastCount, self.YINGXIONGLING_MAX_TIMES);
	local tbOpt = {};
	if nCanFinialChange > 0 then
		tbOpt[#tbOpt + 1] = {"Đổi danh vọng Đại hội Võ lâm", self.OnChangeWldhReput, self};
		tbOpt[#tbOpt + 1] = {"Mua đạo cụ [Anh Hào Lệnh]", self.OnOpenYueYingShop, self};
	end
		
	tbOpt[#tbOpt + 1] = {"Mua Nhẫn Đại hội Võ Lâm [+1 Kỹ năng]", self.OnOpenWldhReputeShop, self};
	tbOpt[#tbOpt + 1] = {"Tìm hiều Đổi danh vọng", self.AboutWldhReput, self};
	
	local tbNpc = Npc:GetClass("wlls_guanyuan3");
	tbOpt[#tbOpt + 1] = {"Trở lại", tbNpc.OnDialog, tbNpc};

	Dialog:Say(szMsg, tbOpt);
	return 0;
end

function Wlls:AboutWldhReput()
	local szMsg = [[
    1. Mỗi tháng tham gia Liên đấu <color=red>18 lần<color> để nhận hết phần thưởng. 
    2. Số lần tích lũy chỉ sử dụng trong tháng, hãy nhanh chóng đổi thưởng. 
    3. Chỉ cần tích lũy 110 lần là đủ điều kiện mua Nhẫn Bạch Ngân [Kỹ năng môn phái +1 cấp] Đại hội Võ lâm. 
]];
	Dialog:Say(szMsg, {
			{"Trở lại", self.OnGetAwardSingleWithWldhRep, self},
			{"Ta biết rồi"},
		});
end

function Wlls:OnOpenYueYingShop()
	me.OpenShop(166, 3);
end

function Wlls:OnOpenWldhReputeShop()
	me.OpenShop(163, 1);
end

function Wlls:OnChangeWldhReput()
	if Wlls:OnCheckWldhRep(me) == 0 then
		Dialog:Say("Chưa đủ điều kiện để đổi!");
		return 0;
	end

	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang khóa.");
		return 0;
	end

	local nTaskTimes = me.GetTask(self.TASKID_GROUP, self.TASKID_YINGXIONGLING_TIMES);
	
	local szMsg = "Hãy chọn cách thức để đổi：";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"Sử dụng Anh Hào Lệnh", self.OpenAskNumber, self, 1};
	tbOpt[#tbOpt + 1] = {"Mua trực tiếp (tiêu hao 660 đồng)", self.OpenAskNumber, self, 2};
	tbOpt[#tbOpt + 1] = {"Trở lại", self.OnGetAwardSingleWithWldhRep, self};
	tbOpt[#tbOpt + 1] = {"Ta chỉ đến xem thôi"};
	Dialog:Say(szMsg, tbOpt);
end

function Wlls:OpenAskNumber(nType)
	if Wlls:OnCheckWldhRep(me) == 0 then
		Dialog:Say("Chưa đủ điều kiện để đổi!");
		return 0;
	end

	local nTaskTimes = me.GetTask(self.TASKID_GROUP, self.TASKID_YINGXIONGLING_TIMES);
	local nHaveCount = me.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_YINGXIONGLING_AWARD);
	local nMaxCount = self.YINGXIONGLING_MAX_TIMES - nTaskTimes;
	if (nMaxCount <= 0) then
		Dialog:Say("Số lần đổi trong tháng đã hết!");
		return 0;
	end
	local nReputeCount = self:GetPlayerMaxReputeChangeCount(me);
	nMaxCount = math.min(nMaxCount, nHaveCount);
	nMaxCount = math.min(nReputeCount, nMaxCount);
	Dialog:AskNumber("Nhập số lượng: ", nMaxCount, self.DoChangeWldhRepute, self, nType);
end

function Wlls:DoChangeWldhRepute(nType, nChangeCount)
	if (1 == nType) then
		local szMsg = string.format("Ngươi chắc chắn tiêu hao %s Anh Hào Lệnh để đổi danh vọng Đại Hội Võ Lâm?", nChangeCount);
		Dialog:Say(szMsg, {
				{"Xác nhận", self.OnChangeWldhReputeByItem, self, nChangeCount},
				{"Trở lại", self.OnChangeWldhReput, self},
			});
	elseif (2 == nType) then
		local szMsg = string.format("Ngươi chắc chắn tiêu hao %s đồng để đổi danh vọng Đại Hội Võ Lâm?", nChangeCount * self.BUY_WLDH_COIN);
		Dialog:Say(szMsg, {
				{"Xác nhận", self.OnChangeWldhReputeByCoin, self, nChangeCount},
				{"Trở lại", self.OnChangeWldhReput, self},
			});
	end
end

function Wlls:OnChangeWldhReputeByItem(nChangeCount)
	if Wlls:OnCheckWldhRep(me) == 0 then
		Dialog:Say("Chưa đủ điều kiện để đổi!");
		return 0;
	end
	
	local nTaskTimes = me.GetTask(self.TASKID_GROUP, self.TASKID_YINGXIONGLING_TIMES);
	local nMaxCount = self.YINGXIONGLING_MAX_TIMES - nTaskTimes;
	if (nMaxCount <= 0) then
		Dialog:Say("Không còn lượt đổi!");
		return 0;
	end
	
	local nHaveCount = me.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_YINGXIONGLING_AWARD);
	if (nChangeCount > nHaveCount) then
		return 0;
	end
	
	local nReputeCount = self:GetPlayerMaxReputeChangeCount(me);
	if (nChangeCount > nReputeCount) then
		return 0;
	end

	local nCount = me.GetItemCountInBags(unpack(self.ITEM_YINGXIONGLING));
	if nCount < nChangeCount then
		Dialog:Say(string.format("Không đủ <color=yellow>%s Anh Hào Lệnh<color>, đến Long Ngũ Thái Gia mua ngay đi.", nChangeCount));
		return;
	end
	local nReamainCount = me.ConsumeItemInBags(nChangeCount, self.ITEM_YINGXIONGLING[1], self.ITEM_YINGXIONGLING[2], self.ITEM_YINGXIONGLING[3], self.ITEM_YINGXIONGLING[4], -1);
	if nReamainCount > 0 then
		return 0;
	end
	
	if (nTaskTimes + nChangeCount > self.YINGXIONGLING_MAX_TIMES) then
		return 0;
	end
	
	me.SetTask(self.TASKID_GROUP, self.TASKID_YINGXIONGLING_AWARD, nHaveCount - nChangeCount);
	me.SetTask(self.TASKID_GROUP, self.TASKID_YINGXIONGLING_TIMES, nTaskTimes + nChangeCount);
	Player:AddRepute(me, 11, 1, self.YINGXIONGLING_REPUTE * nChangeCount);
	StatLog:WriteStatLog("stat_info", "ring_repute", "exchange", me.nId, nChangeCount);
	me.SendMsgToFriend(string.format("Hảo hữu [<color=yellow>%s<color>] dùng Anh Hào Lệnh đổi danh vọng Đại hội Võ lâm.", me.szName));		
	Player:SendMsgToKinOrTong(me, "Dùng Anh Hào Lệnh đổi danh vọng Đại hội Võ lâm.", 1);
	
end

function Wlls:OnChangeWldhReputeByCoin(nChangeCount)
	if Wlls:OnCheckWldhRep(me) == 0 then
		Dialog:Say("Chưa đủ điều kiện để đổi!");
		return 0;
	end

	local nTaskTimes = me.GetTask(self.TASKID_GROUP, self.TASKID_YINGXIONGLING_TIMES);
	local nMaxCount = self.YINGXIONGLING_MAX_TIMES - nTaskTimes;
	if (nMaxCount <= 0) then
		Dialog:Say("Không còn lượt đổi!");
		return 0;
	end

	local nHaveCount = me.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_YINGXIONGLING_AWARD);
	if (nChangeCount > nHaveCount) then
		return 0;
	end

	local nReputeCount = self:GetPlayerMaxReputeChangeCount(me);
	if (nChangeCount > nReputeCount) then
		return 0;
	end

	local nTotalCoin = self.BUY_WLDH_COIN * nChangeCount;
	
	if (me.nCoin < nTotalCoin) then
		Dialog:Say(string.format("Không đủ %s đồng, không thể đổi", nTotalCoin));
		return 0;
	end
	
	if (nTaskTimes + nChangeCount > self.YINGXIONGLING_MAX_TIMES) then
		return 0;
	end

	me.SetTask(self.TASKID_GROUP, self.TASKID_YINGXIONGLING_AWARD, nHaveCount - nChangeCount);
	me.SetTask(self.TASKID_GROUP, self.TASKID_YINGXIONGLING_TIMES, nTaskTimes + nChangeCount);
	
	me.ApplyAutoBuyAndUse(self.COIN_ITEM_WARE, nChangeCount);
	
	StatLog:WriteStatLog("stat_info", "ring_repute", "exchange", me.nId, nChangeCount);
	me.SendMsgToFriend(string.format("Hảo hữu [<color=yellow>%s<color>] dùng đồng đổi danh vọng Đại hội Võ lâm.", me.szName));		
	Player:SendMsgToKinOrTong(me, "Đổi thành công danh vọng Đại hội Võ lâm.", 1);
	
end

--最终奖励, 有奖励时优先弹出奖励选项
function Wlls:OnCheckAward(pPlayer, nGameLevel)
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, pPlayer.szName);
	if not szLeagueName then
		return 0, 0, "Không có chiến đội.";
	end
	
	local szGameLevelName = Wlls.MACTH_LEVEL_NAME[nGameLevel];
	if (GLOBAL_AGENT and GbWlls:CheckOpenGoldenGbWlls() == 1) then
		szGameLevelName = GbWlls.MACTH_LEVEL_NAME[nGameLevel];
	end
	if nGameLevel ~= League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MLEVEL) then
		return 0, 0 ,string.format("Không phải thí sinh của Liên đấu %s.", szGameLevelName);
	end
	
	if Wlls:GetMacthState() ~= Wlls.DEF_STATE_REST or KGblTask.SCGetDbTaskInt(Wlls.GTASK_MACTH_RANK) < Wlls:GetMacthSession() then
		return 0, 0, string.format("Thời gian thi đấu vẫn chưa kết thúc.");		
	end
	
	if League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_TOTAL) <= 0 then
		return 0, 0, string.format("Chiến đội của ngươi chưa tham gia thi đấu.");	
	end
	local nRank = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_RANK);
	local nTotle = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_TOTAL);
	local nSession = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MSESSION);
	local nAdvRank = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_RANK_ADV);
	
	if pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_FINISH) >= nSession then
		return 0, 0 , string.format("Đã nhận được phần thưởng.");
	end	
	
	
	if nRank == 1 and nAdvRank == 2 then
		nRank = 2;
	end	
	local nGameType = Wlls:GetMacthType(nSession)
	local nLevelSep, nMaxRank = Wlls:GetAwardLevelSep(nGameLevel, nSession, nRank);
	if nLevelSep <= 0 then
		return 0, 0, string.format("Chiến đội không có phần thưởng để nhận.");
	end
	if nMaxRank >= 10000 and nTotle < math.floor(nMaxRank/10000) then
		return 0, 0 , string.format("Chiến đội không nhận được bất kỳ phần thưởng nào.");
	end
	return 1, nRank , string.format("Nhận phần thưởng");
end


--领取最终奖励
function Wlls:OnGetAward(nGameLevel, nFlag)
	local nCheck,nRank,szError = Wlls:OnCheckAward(me, nGameLevel);
	if nCheck == 0 then
		Dialog:Say(szError);
		return 0;
	end
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, me.szName);
	local nSession = League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MSESSION);
	local nGameType = Wlls:GetMacthType(nSession);
	local nLevelSep, nMaxRank = Wlls:GetAwardLevelSep(nGameLevel, nSession, nRank);

	local nGameLevel 	= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MLEVEL);
	local nMatchType	= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MTYPE);
	
	if not nFlag then
		local szMsg = string.format("Chiến đội của ngươi giành được <color=yellow>Hạng %s<color>, sau khi nhận thưởng sẽ rời khỏi chiến đội.", nRank);
		local tbOpt = 
		{
			{"Ta chắc chắn",self.OnGetAward, self, nGameLevel, 1},
			{"Để ta suy nghĩ lại"},
		}
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	-- 将额外奖励插入到原来排名奖励列表中
	local tbRandAward = Wlls.AWARD_FINISH_LIST[nGameLevel][nSession][nLevelSep];

	local tbExternAward = self:GetFinalExternAward(nGameLevel);
	
	local nFree = Wlls.Fun:GetNeedFree(tbRandAward);
	if (tbExternAward) then
		nFree = nFree + Wlls.Fun:GetNeedFree(tbExternAward);
	end
	if me.CountFreeBagCell() < nFree then
		Dialog:Say(string.format("Hành trang không đủ %s ô trống.", nFree));
		return 0;
	end
	
	--变量设置
	if nRank == 1 then
		me.SetTask(self.TASKID_GROUP, self.TASKID_MATCH_FIRST, me.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_FIRST) + 1);
		local pTong = KTong.GetTong(me.dwTongId);
		if pTong and nSession then
			pTong.AddHistoryLadder(me.szName, tostring(nSession), "Quán Quân"); 
			pTong.AddAffairLadder(me.szName, tostring(nSession), "Quán Quân");
			GCExcute{"Wlls:AddAffairLadder", me.dwTongId, me.szName, nSession, "Quán Quân"};
		end
	end
	if nRank == 2 then
		me.SetTask(self.TASKID_GROUP, self.TASKID_MATCH_SECOND, me.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_SECOND) + 1);
		local pTong = KTong.GetTong(me.dwTongId);
		if pTong and nSession then 
			pTong.AddHistoryLadder(me.szName, tostring(nSession), "Á Quân");
			pTong.AddAffairLadder(me.szName, tostring(nSession), "Á Quân");
			GCExcute{"Wlls:AddAffairLadder", me.dwTongId, me.szName, nSession, "Á Quân"};
		end
	end
	if nRank == 3 then
		me.SetTask(self.TASKID_GROUP, self.TASKID_MATCH_THIRD, me.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_THIRD) + 1);
		local pTong = KTong.GetTong(me.dwTongId);
		if pTong then 
			pTong.AddHistoryLadder(me.szName, tostring(nSession), "Quý Quân");
			pTong.AddAffairLadder(me.szName, tostring(nSession), "Quý Quân");
			GCExcute{"Wlls:AddAffairLadder", me.dwTongId, me.szName, nSession, "Quý Quân"};
		end
	end	
	
	if me.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_BEST) > nRank then
		me.SetTask(self.TASKID_GROUP, self.TASKID_MATCH_BEST, nRank);
	end
	if me.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_BEST) == 0 then
		me.SetTask(self.TASKID_GROUP, self.TASKID_MATCH_BEST, nRank);
	end
	
	me.SetTask(self.TASKID_GROUP, self.TASKID_MATCH_FINISH, nSession);
	local nLogTaskFlag = nSession + nLevelSep * 1000 + nGameLevel * 1000000;
	me.SetTask(self.TASKID_GROUP, self.TASKID_AWARD_LOG, nLogTaskFlag);	
	
	--奖励
	Wlls.Fun:DoExcute(me, tbRandAward);
	if (tbExternAward) then
		Wlls.Fun:DoExcute(me, tbExternAward);
	end
	
	-- 玩家领取武林联赛最终奖励的客服log
	local nTotle = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_TOTAL);
	local szLogMsg = string.format("玩家：%s 参赛场次：%s 名次：%s,  已经领取武林联赛奖励.", me.szName, nTotle, nRank);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLogMsg);

	GCExcute{"Wlls:LeaveLeague", me.szName, nGameLevel, 1};
	Dialog:Say("Nhận thưởng thành công.");
	Wlls:WriteLog(string.format("%s级联赛排名:%s, 路线:%s", nGameLevel, nRank, Player:GetFactionRouteName(me.nFaction, me.nRouteId)), me.nId)
	
	StatLog:WriteStatLog("stat_info", "local_wlls", "fight_award_get", me.nId, string.format("%s,%s,%s,%s,%s", nSession, nGameType, nGameLevel, szLeagueName, nRank));
	
	--成就
	local tbAchievement = Wlls.tbAchievementRank;
	if not GLOBAL_AGENT and tbAchievement[nGameType] and nRank > 0 then
		
		if nRank <= tbAchievement[nGameType][1][1] then
			Achievement:FinishAchievement(me, tbAchievement[nGameType][1][2]);
		end
		if nRank <= tbAchievement[nGameType][2][1] then
			Achievement:FinishAchievement(me, tbAchievement[nGameType][2][2]);
		end
		if nRank <= tbAchievement[nGameType][3][1] then
			Achievement:FinishAchievement(me, tbAchievement[nGameType][3][2]);
		end
		
	end
	--成就

end

--玩家登陆补领奖励.
function Wlls:OnLogin()
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, me.szName);
	if szLeagueName then
		local nLeagueTotal = League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TOTAL);
		local nLeagueWin = League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_WIN);
		local nLeagueTie = League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TIE);
		local nLeagueTime = League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TIME);
		local nGameLevel = League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MLEVEL);
		local nSession = League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MSESSION);
		
		if nSession > me.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_SESSION) then
			me.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_SESSION, nSession);
			me.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_TOTLE, nLeagueTotal);
			me.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_WIN, nLeagueWin);
			me.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_TIE, nLeagueTie);
			Player:UpdateJoinRecord_WllsPoint(me);
		end
		if me.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_TOTLE) ~= nLeagueTotal then
			me.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_TOTLE, nLeagueTotal);
			me.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_WIN, nLeagueWin);
			me.SetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_TIE, nLeagueTie);
			Player:UpdateJoinRecord_WllsPoint(me);
		end
		local nResult = League:GetMemberTask(self.LGTYPE, szLeagueName, me.szName, self.LGMTASK_AWARD);
		if nResult == 0 then
			return 0
		end
		if nResult == 1 or nResult == 4 then
			--获胜奖励
			Wlls.Fun:DoExcute(me, Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Win);
			
		end
		if nResult == 2 then
			--平奖励
			Wlls.Fun:DoExcute(me, Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Tie);
		end
		
		if nResult == 3 then
			--负奖励
			Wlls.Fun:DoExcute(me, Wlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Lost);
		end
		Player:AddJoinRecord_DailyCount(me, Player.EVENT_JOIN_RECORD_WLLS, 1);
		Player:AddJoinRecord_MonthCount(me, Player.EVENT_JOIN_RECORD_WLLS, 1);
		League:SetMemberTask(self.LGTYPE, szLeagueName, me.szName, self.LGMTASK_AWARD, 0);
		Wlls:WriteLog("成功补领单场奖励", me.nId);
	end
end

-- 获取最终的额外奖励
function Wlls:GetFinalExternAward(nGameLevel)
	if (Item.tbStone:GetOpenDay() == 0) then
		return nil;
	end
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, me.szName);
	local nTotal = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_TOTAL);		-- 本届联赛一共参加了多少场
	
	local tbLevelAward = self.tbExternAwardOnGameTimes[nGameLevel];
	if not tbLevelAward then
		return;
	end
	
	local tbAward = tbLevelAward[nTotal];
	
	return tbAward;
end