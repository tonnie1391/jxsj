--大会大会
--孙多良
--2008.09.23

--单场比赛奖励，1为获胜，2为平，3为输, 4为轮空获胜
function Wldh:MacthAward(nType, nIsFinal, szLeagueName, szMatchLeagueName, tbMisPlayerList, nResult, nMacthTime, nReadyId)
	local nLGType = Wldh:GetLGType(nType);
	local tbMsg = 
	{
		[1] = {string.format("<color=yellow>您的战队在比赛中战胜了%s的战队，恭喜获得了胜利。<color>", szMatchLeagueName or "")},
		[2] = {string.format("<color=green>您的战队在比赛中战平了%s的战队，下次继续努力吧。<color>", szMatchLeagueName or "")},
		[3] = {string.format("<color=blue>您的战队在比赛中败给了%s的战队，下次继续努力吧。<color>", szMatchLeagueName or "")},
		[4] = {string.format("<color=yellow>您的战队在这次比赛中轮空了，意外的获得了胜利。<color>")}
	}
	local nLeagueTotal 	= League:GetLeagueTask(nLGType, szLeagueName, self.LGTASK_TOTAL);
	local nLeagueWin 	= League:GetLeagueTask(nLGType, szLeagueName, self.LGTASK_WIN);
	local nLeagueTie 	= League:GetLeagueTask(nLGType, szLeagueName, self.LGTASK_TIE);
	local nLeagueTime 	= League:GetLeagueTask(nLGType, szLeagueName, self.LGTASK_TIME);
	local nSession 		= League:GetLeagueTask(nLGType, szLeagueName, self.LGTASK_MSESSION);	
	--local nReadyId		= League:GetLeagueTask(nLGType, szLeagueName, self.LGTASK_ATTEND);
	if nResult == 3 then
		--负方不累计比赛时间
		nMacthTime = 0;
	end
--	local tbPlayerList = {};
--	local tbPlayerObjList = {};
--	--加荣誉点
--	for _, szMemberName in ipairs(Wldh:GetLeagueMemberList(nLGType, szLeagueName)) do
--		local nId = KGCPlayer.GetPlayerIdByName(szMemberName);
--		if nId then
--			tbPlayerList[nId] = szMemberName;
--		end
--	end
--	
--	for nId, szName in pairs(tbPlayerList) do
--		if nResult == 1 or nResult == 4 then
--			--SetPlayerSportTask(nId, Wldh.GBTASKID_GROUP, Wldh.GBTASKID_SINGLE_ID[nType], GetPlayerSportTask(nId, Wldh.GBTASKID_GROUP, Wldh.GBTASKID_SINGLE_ID[nType])+ 1);
--		end
--		local pPlayer = KPlayer.GetPlayerObjById(nId);
--		if pPlayer then
--			pPlayer.Msg(tbMsg[nResult][1]);
--			Dialog:SendBlackBoardMsg(pPlayer, tbMsg[nResult][1])
--			--奖励
--			if nResult == 1 or nResult == 4 then
--				pPlayer.SendMsgToFriend("你的好友[" ..pPlayer.szName.. "]在刚刚结束的武林大会中取得了一场胜利。");
--			end
--			
--			if nResult == 2 then
--				
--			end
--			if nResult == 3 then
--				
--			end
--			table.insert(tbPlayerObjList, pPlayer);
--		end
--		Wldh:WriteLog(string.format("奖励队员:%s，%s Vs %s，结果:%s", szName, szLeagueName, (szMatchLeagueName or ""), nResult))
--	end
	
	if nIsFinal > 0 then
		local nRank   = League:GetLeagueTask(nLGType, szLeagueName, Wldh.LGTASK_RANK);
		local nVsRank = 10000;
		if szMatchLeagueName then
			nVsRank = League:GetLeagueTask(nLGType, szMatchLeagueName, Wldh.LGTASK_RANK);
		end
		local nCurState = Wldh.MACTH_STATE_ADV_TASK[nIsFinal];
		local nNextState = Wldh.MACTH_STATE_ADV_TASK[nIsFinal+1];

		if nCurState > 2 then
			local nSeries = self.FINAL_VS_LIST[nRank][nCurState];
			if nResult == 1 or nResult == 4 or (nResult == 2 and nRank < nVsRank) then
				Wldh.AdvMatchLists[nType][nReadyId][nNextState][nSeries] = Wldh.AdvMatchLists[nType][nReadyId][32][nRank];
				League:SetLeagueTask(nLGType, szLeagueName, Wldh.LGTASK_RANK_ADV, nNextState);
			end
		end
		if nCurState == 2 then
			nNextState = 2;
			local nSeries = self.FINAL_VS_LIST[nRank][4];
			Wldh.AdvMatchLists[nType][nReadyId][2][nSeries].tbResult[nIsFinal - 4] = nResult;
		end
		GCExcute{"Wldh:SyncAdvMatchList", nType, nReadyId, nNextState, Wldh.AdvMatchLists[nType][nReadyId][nNextState]};
	else
		if nResult == 1 or nResult == 4 then
			League:SetLeagueTask(nLGType, szLeagueName, self.LGTASK_WIN, nLeagueWin + 1 );
			Wldh:WriteLog(string.format("胜利增加胜利场次:%s", szLeagueName));
		elseif nResult == 2 then
			League:SetLeagueTask(nLGType, szLeagueName, self.LGTASK_TIE, nLeagueTie + 1);
		end
		League:SetLeagueTask(nLGType, szLeagueName, self.LGTASK_TOTAL, nLeagueTotal + 1);
		League:SetLeagueTask(nLGType, szLeagueName, self.LGTASK_TIME, nLeagueTime + nMacthTime);
	end
	League:SetLeagueTask(nLGType, szLeagueName, Wldh.LGTASK_ENTER, 0);
end

function Wldh:GetFinalAwardTable(nType, nWinRank, nAttendTotle)
	if nType <= 0 or nWinRank <= 0 then
		return
	end
	local tbStep = self.AWARD_HONOR_STEP[nType].step;
	local nCurStep = 0;
	for nStep, nRank in ipairs(tbStep) do
		if (nWinRank <= nRank and nRank < 10000) or (nRank > 10000 and nAttendTotle*10000 >= nRank)then
			nCurStep = nStep;
			break;
		end
	end
	if nCurStep <= 0 then
		return;
	end
	local nHonor = self.AWARD_HONOR_STEP[nType].honor[nCurStep];
	local tbCurAward = {nHonor = nHonor};
	for nStep, tbAward in ipairs(self.AWARD_FINISH_LIST[nType]) do
		if (nWinRank <= tbAward.nRank and tbAward.nRank < 10000) or (tbAward.nRank > 10000 and nAttendTotle*10000 >= tbAward.nRank) then
			tbCurAward.tbAward = tbAward;
			break;
		end
	end
	return tbCurAward;
end

