--平台活动奖励
--孙多良
--2008.09.23

--单场比赛奖励，1为获胜，2为平，3为输, 4为轮空获胜
function EPlatForm:MacthAward(szLeagueName, szMatchLeagueName, tbMisPlayerList, nResult)
	local tbMsg = 
	{
		[1] = {string.format("<color=yellow>您的战队在比赛中战胜了对手，恭喜获得了胜利。<color>")},
		[2] = {string.format("<color=green>您的战队在比赛中战平了对手，下次继续努力吧。<color>")},
		[3] = {string.format("<color=blue>您的战队在比赛中败给了对手，下次继续努力吧。<color>")},
		[4] = {string.format("<color=yellow>您的战队在这次比赛中轮空了，意外的获得了胜利。<color>")}
	}
	local nLeagueTotal 	= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TOTAL);
	local nLeagueWin 	= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_WIN);
	local nLeagueTie 	= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TIE);
--	local nGameLevel 	= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MLEVEL);
	local nSession 		= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MSESSION);	
	local nReadyId		= League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_ATTEND);

	local tbPlayerList = {};
	local tbPlayerObjList = {};


	local nState			= EPlatForm:GetMacthState();
	local nRankSession		= EPlatForm:GetMacthSession();
	local nMacthType		= EPlatForm:GetMacthType();
	local tbMacth			= EPlatForm:GetMacthTypeCfg(nMacthType);
	local szMatchName	= "家族竞技";
	if (tbMacth) then
		szMatchName	= 	tbMacth.szName;
	end

	local tbMemberList = EPlatForm:GetLeagueMemberList(szLeagueName) or {};
	for _, szName in pairs(tbMemberList) do
		local pPlayer = KPlayer.GetPlayerByName(szName);
		if pPlayer then
			pPlayer.Msg(tbMsg[nResult][1]);
			Dialog:SendBlackBoardMsg(pPlayer, tbMsg[nResult][1])
			--奖励
			pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_MATCH_TOTLE, pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_TOTLE) + 1);
			pPlayer.SetTask(EPlatForm.TASKID_GROUP, EPlatForm.TASKID_HELP_TOTLE, nLeagueTotal + 1);
			local szFriendMsg	= "";
			local szMyMsg	= "";
			if nResult == 1 or nResult == 4 then
				pPlayer.SetTask(EPlatForm.TASKID_GROUP, EPlatForm.TASKID_MATCH_WIN, pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_WIN) + 1);
				pPlayer.SetTask(EPlatForm.TASKID_GROUP, EPlatForm.TASKID_HELP_WIN, nLeagueWin + 1);
				pPlayer.SendMsgToFriend(string.format("Hảo hữu [%s]所在战队在刚刚结束的%s活动中取得了胜利！", pPlayer.szName, szMatchName));
			end
			
			if (nState ~= self.DEF_STATE_ADVMATCH) then
				local nAwardFlag = self:SetAwardFlagParam(0, nRankSession, nState, nResult);
				self:SetAwardParam(pPlayer, nAwardFlag);			
			end

			-- 统计玩家参加武林联赛的场次
			-- Stats.Activity:AddCount(pPlayer, Stats.TASK_COUNT_WLLS, 1);
		else
			--不在线,下次上线自动给予.
			if (nState ~= self.DEF_STATE_ADVMATCH) then
				League:SetMemberTask(self.LGTYPE, szLeagueName, szName, self.LGMTASK_AWARD, nResult);
			end
		end
		EPlatForm:WriteLog(string.format("奖励队员:%s，%s Vs %s，结果:%s", szName, szLeagueName, (szMatchLeagueName or ""), nResult))
	end
	
	local szKinName = self:GetKinNameFromLeagueName(szLeagueName);
	if nResult == 1 or nResult == 4 then
		local szKinMsg = string.format("%s战队获得了%s活动的胜利！", szLeagueName, szMatchName);
		local nKinId = KKin.GetKinNameId(szKinName);
		if (nKinId > 0) then
			KKin.Msg2Kin(nKinId, szKinMsg);
		end
	end
	
	if EPlatForm:GetMacthState() == EPlatForm.DEF_STATE_ADVMATCH then
		local nRank   = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_RANK);
		local nVsRank = 0;
		if szMatchLeagueName then
			nVsRank = League:GetLeagueTask(EPlatForm.LGTYPE, szMatchLeagueName, EPlatForm.LGTASK_RANK);
		end
		if EPlatForm.MACTH_STATE_ADV_TASK[EPlatForm.AdvMatchState] == 8 then
			if nResult == 1 or nResult == 4 or (nResult == 2 and nRank < nVsRank) then
				local nSeries = EPlatForm:GetAdvMatchSeries(nRank, 8);
				EPlatForm.AdvMatchLists[nReadyId][4][nSeries] = EPlatForm.AdvMatchLists[nReadyId][8][nRank];
				League:SetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_RANK_ADV, 4);
				self:SetKinAwardFlag(szKinName, nRankSession, 4);
			end
			
			if (nResult == 3 or (nResult == 2 and nRank >= nVsRank) ) then
				EPlatForm:SendAdvMatchResultMsg(szLeagueName, 4);
				League:SetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_RANK_ADV, 8);
			end
		elseif EPlatForm.MACTH_STATE_ADV_TASK[EPlatForm.AdvMatchState] == 4 then
			if nResult == 1 or nResult == 4  or (nResult == 2 and nRank < nVsRank) then
				local nSeries = EPlatForm:GetAdvMatchSeries(nRank, 4);
				EPlatForm.AdvMatchLists[nReadyId][2][nSeries] = EPlatForm.AdvMatchLists[nReadyId][8][nRank];
				League:SetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_RANK_ADV, 2);
				self:SetKinAwardFlag(szKinName, nRankSession, 2);			
			end
			if (nResult == 3 or (nResult == 2 and nRank >= nVsRank) ) then
				EPlatForm:SendAdvMatchResultMsg(szLeagueName, 3);
				League:SetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_RANK_ADV, 4);
			end
		elseif EPlatForm.MACTH_STATE_ADV_TASK[EPlatForm.AdvMatchState] == 2 then
			local nSeries = EPlatForm:GetAdvMatchSeries(nRank, 2);
			EPlatForm.AdvMatchLists[nReadyId][2][nSeries].tbResult[EPlatForm.AdvMatchState - 2] = nResult;
		end
	else
		if nResult == 1 or nResult == 4 then
			League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_WIN, nLeagueWin + 1 );
			EPlatForm:WriteLog(string.format("胜利增加胜利场次:%s", szLeagueName));
		elseif nResult == 2 then
			League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TIE, nLeagueTie + 1);
		end
		League:SetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TOTAL, nLeagueTotal + 1);
	end
	League:SetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_ENTER, 0);
end

--检查领取单场胜利奖项
function EPlatForm:OnCheckAwardSingle(pPlayer)
	if pPlayer.GetTask(EPlatForm.TASKID_GROUP, EPlatForm.TASKID_MATCH_WIN_AWARD) == 10 then
		return 1;
	end
	return 0;
end

--最终奖励，有奖励时优先弹出奖励选项
function EPlatForm:OnCheckAward(pPlayer, nPart)
	local szLeagueName = League:GetMemberLeague(EPlatForm.LGTYPE, pPlayer.szName);
	if not szLeagueName then
		return 0, 0, "您没有战队。";
	end
	
	-- 判断是不是本届联赛的选手
	
	if EPlatForm:GetMacthState() ~= EPlatForm.DEF_STATE_REST or KGblTask.SCGetDbTaskInt(EPlatForm.GTASK_MACTH_RANK) < EPlatForm:GetMacthSession() then
		return 0, 0, string.format("比赛期还未结束或者比赛最终排行还未出来，请耐心等待。");		
	end
	
	if League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_TOTAL) <= 0 then
		return 0, 0, string.format("您的战队还未参加过比赛，是新建战队，不能领取奖励。");	
	end
	local nRank = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_RANK);
	local nTotle = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_TOTAL);
	local nSession = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_MSESSION);
	local nAdvRank = League:GetLeagueTask(EPlatForm.LGTYPE, szLeagueName, EPlatForm.LGTASK_RANK_ADV);
	
	if pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_FINISH) >= nSession then
		return 0, 0 , string.format("您已领取过奖励了。");
	end	
	
	
	if nRank == 1 and nAdvRank == 2 then
		nRank = 2;
	end	
	local nGameType = EPlatForm:GetMacthType(nSession)
	local nLevelSep, nMaxRank = EPlatForm:GetAwardLevelSep(nPart, nSession, nRank);
	if nLevelSep <= 0 then
		return 0, 0, string.format("您的战队没有奖励可以领取。");
	end
	if nMaxRank >= 10000 and nTotle < math.floor(nMaxRank/10000) then
		return 0, 0 , string.format("您的战队在本届比赛中没有获得任何奖励,请下届继续努力。");
	end
	return 1, nRank , string.format("领取奖励");
end


--领取最终奖励
function EPlatForm:OnGetAward_Final(nPart, nFlag)
	local nCheck,nRank,szError = EPlatForm:OnCheckAward(me, nPart);
	if nCheck == 0 then
		Dialog:Say(szError);
		return 0;
	end
	local szLeagueName = League:GetMemberLeague(EPlatForm.LGTYPE, me.szName);
	local nSession = League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MSESSION);
	local nGameType = EPlatForm:GetMacthType(nSession);
	local nLevelSep, nMaxRank = EPlatForm:GetAwardLevelSep(nPart, nSession, nRank);
	
	if not nFlag then
		local szMsg = string.format("您的战队在上届家族竞技活动中获得了第<color=yellow>%s<color>名，领取奖励后，您将退出战队，如果战队没有剩余成员，战队将会解散。", nRank);
		local tbOpt = 
		{
			{"我确定领取奖励",self.OnGetAward_Final, self, nPart, 1},
			{"Để ta suy nghĩ lại"},
		}
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	local nFree = EPlatForm.Fun:GetNeedFree(EPlatForm.AWARD_FINISH_LIST[nSession][nLevelSep]);
	if me.CountFreeBagCell() < nFree then
		Dialog:Say(string.format("您的背包空间不够,请整理%s格背包空间.", nFree));
		return 0;
	end
	
	if me.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_BEST) > nRank then
		me.SetTask(self.TASKID_GROUP, self.TASKID_MATCH_BEST, nRank);
	end
	if me.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_BEST) == 0 then
		me.SetTask(self.TASKID_GROUP, self.TASKID_MATCH_BEST, nRank);
	end
	
	me.SetTask(self.TASKID_GROUP, self.TASKID_MATCH_FINISH, nSession);
	local nLogTaskFlag = nSession + nLevelSep * 1000 + nPart * 10000 ;
	me.SetTask(self.TASKID_GROUP, self.TASKID_AWARD_LOG, nLogTaskFlag);	
	
	--奖励
	EPlatForm.Fun:DoExcute(me, EPlatForm.AWARD_FINISH_LIST[nSession][nLevelSep]);

	GCExcute{"EPlatForm:LeaveLeague", me.szName, 1};
	Dialog:Say("您成功领取了奖励，并退出了战队，欢迎继续参加下届活动。");
	EPlatForm:WriteLog(string.format("本届活动排名:%s", nRank), me.nId, me.szName);
	
	--成就
	if nRank > 0 and nRank <= 8 then
		Achievement:FinishAchievement(me, 43);
	end
	if nRank == 1 then
		Achievement:FinishAchievement(me, 44);
		Achievement:FinishAchievement(me, 45);
	end
	--成就
	
	StatLog:WriteStatLog("stat_info", "kin_game", "award_get", me.nId, string.format("%s,%s", szLeagueName, nRank));
end

function EPlatForm:GetPlayerAward_Final()
	self:OnGetAward_Final(EPlatForm.MATCH_TEAMMATCH);
	return 1;
end

function EPlatForm:GetKinAward(nFlag)
	local nResult, szMsg = self:OnCheckKinAward(me);
	if (nResult == 0) then
		Dialog:Say(szMsg);
		return 0;
	end
	
	szMsg = string.format("%s，你确定要领取家族奖励吗？", szMsg or "");
	
	Dialog:Say(szMsg, 
		{
			{"我确定要领取", self.OnApplyGetKinAward, self, 1},
			{"Để ta suy nghĩ lại"}	
		});
	return 1;
end

function EPlatForm:OnApplyGetKinAward()
	local nResult, szMsg = self:OnCheckKinAward(me);
	if (nResult == 0) then
		Dialog:Say(szMsg);
		return 0;
	end
	GCExcute{"EPlatForm:ApplyGetKinAward", me.nId};
end

function EPlatForm:OnGetKinAward(nPlayerId)
	if (not nPlayerId) then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return 0;
	end
	local nResult, szMsg = self:OnCheckKinAward(pPlayer);
	if (nResult == 0) then
		pPlayer.Msg(szMsg);
		return 0;
	end

	local dwKinId, nMemberId = KKin.GetPlayerKinMember(pPlayer.nId);
	if (dwKinId <= 0) then
		return 0;
	end
	
	local pKin = KKin.GetKin(dwKinId);
	if (not pKin) then
		return 0;
	end
	
	local pMember = pKin.GetMember(nMemberId);
	if (not pMember) then 
		return 0;
	end
	
	local szKinName = pKin.GetName();
	local nFigure = pMember.GetFigure();
	if (nFigure <= 0 or nFigure > 3) then
		return 0;
	end

	local nKinAwardType = pKin.GetPlatformKinAward() or 0;
	if (nKinAwardType <= 0) then
		return 0;
	end

	if (self:GetPlayerMonthScore(pPlayer.szName) < self.DEF_MIN_KINAWARD_SCORE) then
		return 0;
	end

	local nSession = math.floor(nKinAwardType / 10000);
	local nType = math.fmod(nKinAwardType, 10000);

	local nKinCount = pKin.GetPlatformAwardCount();
	if (nKinCount >= self.DEF_MAX_KINAWARDCOUNT) then
		return 0;
	end

	local nFlag = pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_KINAWARDFLAG);
	local nMySession= math.floor(nFlag / 10000);
	local nMyType	= math.fmod(nFlag, 10000);

	if (nSession == nMySession) then
		return 0;
	end
	
	local tbResultName = {
			[1] = "冠军",
			[2] = "亚军",
			[4] = "4强",
			[8] = "8强", 
			[16] = "16强",
			[32] = "32强",
		};	
	local nLevel = self:GetAwardLevelSep(self.MATCH_KINAWARD, nSession, nType);
	
	if (nLevel <= 0) then
		self:WriteLog("GetKinAward", string.format("%s 奖励领取失败", pPlayer.szName), nSession, nType);
		return 0;
	end
	
	if (not self.AWARD_KIN_LIST[nSession][nLevel]) then
		return 0;
	end
	
	local nFree = EPlatForm.Fun:GetNeedFree(self.AWARD_KIN_LIST[nSession][nLevel]);
	if pPlayer.CountFreeBagCell() < nFree then
		return 0;
	end
	
	EPlatForm.Fun:DoExcute(pPlayer, self.AWARD_KIN_LIST[nSession][nLevel]);
	nKinCount = nKinCount + 1;
	if (nKinCount > EPlatForm.DEF_MAX_KINAWARDCOUNT	) then
		nKinCount = EPlatForm.DEF_MAX_KINAWARDCOUNT;
	end

	pKin.SetPlatformAwardCount(nKinCount);
	pPlayer.SetTask(self.TASKID_GROUP, self.TASKID_KINAWARDFLAG, nKinAwardType);
	self:WriteLog("OnGetKinAward", string.format("GS Del Kin AwardCount 1, now Count %d", nKinCount), pPlayer.nId, pPlayer.szName, szKinName);
	self:WriteLog("OnGetKinAward", string.format("%s玩家获取家族奖励成功", pPlayer.szName), nSession, nLevel, nKinAwardType);
	return 1;	
end

function EPlatForm:OnCheckKinAward(pPlayer)
	if EPlatForm:GetMacthState() ~= EPlatForm.DEF_STATE_REST or KGblTask.SCGetDbTaskInt(EPlatForm.GTASK_MACTH_RANK) < EPlatForm:GetMacthSession() then
		return 0, string.format("比赛期还未结束或者比赛最终排行还未出来，请耐心等待。");		
	end		
	
	local dwKinId, nMemberId = KKin.GetPlayerKinMember(pPlayer.nId);
	if (dwKinId <= 0) then
		return 0, "你没有家族无法领取家族奖励";
	end
	
	local pKin = KKin.GetKin(dwKinId);
	if (not pKin) then
		return 0, "你没有家族无法领取家族奖励";
	end
	
	local pMember = pKin.GetMember(nMemberId);
	if (not pMember) then 
		return 0, "你不是家族成员无法领取家族奖励";
	end
	
	local szKinName = pKin.GetName();
	local nFigure = pMember.GetFigure();
	if (nFigure <= 0 or nFigure > 3) then
		return 0, string.format("你不是<color=yellow>%s<color>家族的<color=yellow>正式成员<color>，不能领取家族奖励！", szKinName);
	end
	
	if (self:GetPlayerMonthScore(pPlayer.szName) < self.DEF_MIN_KINAWARD_SCORE) then
		return 0, string.format("你的月活动积分没有达到%d分，不能领取奖励！", self.DEF_MIN_KINAWARD_SCORE);
	end

	local nKinAwardType = pKin.GetPlatformKinAward() or 0;
	if (nKinAwardType <= 0) then
		return 0, string.format("你所在家族没有奖励可以领取！");
	end
	local nSession = math.floor(nKinAwardType / 10000);
	local nType = math.fmod(nKinAwardType, 10000);


	local nFlag = pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_KINAWARDFLAG);
	local nMySession= math.floor(nFlag / 10000);
	local nMyType	= math.fmod(nFlag, 10000);
	
	if (nSession == nMySession) then
		return 0, "你已经领取过本家族的家族奖励了";
	end
	
	local nKinCount = pKin.GetPlatformAwardCount();
	if (nKinCount >= self.DEF_MAX_KINAWARDCOUNT) then
		return 0, string.format("%s家族奖励数额已经领完，你无法领取！", szKinName);
	end

	local nLevel = self:GetAwardLevelSep(self.MATCH_KINAWARD, nSession, nType);
	
	if (nLevel <= 0) then
		self:WriteLog("GetKinAward", string.format("%s 奖励领取等级不对", pPlayer.szName), nSession, nType);
		return 0, "你没有资格领家族奖励";
	end
	
	if (not self.AWARD_KIN_LIST[nSession][nLevel]) then
		return 0, "奖励不存在请联系管理员";
	end
	
	local nFree = EPlatForm.Fun:GetNeedFree(self.AWARD_KIN_LIST[nSession][nLevel]);
	if pPlayer.CountFreeBagCell() < nFree then
		return 0, string.format("您的背包空间不够,请整理%s格背包空间.", nFree);
	end

	local tbResultName = {
			[1] = "冠军",
			[2] = "亚军",
			[3] = "4强",
			[4] = "8强", 
			[5] = "16强",
			[6] = "32强",
		};
	return 1, string.format("你所在的家族在第%d届活动中获得了<color=yellow>%s<color>奖励", nSession, tbResultName[nLevel]);
end

function EPlatForm:GetPlayerAward_Single()
	local nAwardFlag = me.GetTask(EPlatForm.TASKID_GROUP, EPlatForm.TASKID_AWARDFLAG);
	if (0 >= nAwardFlag) then
		Dialog:Say("没有奖励可以领哦，想要奖励快快参加活动吧！");
		return 0;
	end
	local nSession, nState, nAwardID = EPlatForm:GetAwardFlagParam(nAwardFlag);
	if (nSession <= 0 or nState <= 0 or nAwardID <= 0) then
		return 0;
	end
	
	-- 是第一阶段比赛奖励，那么就是个人奖励
	if (nState == EPlatForm.DEF_STATE_MATCH_1) then
		return self:OnGetAwardSingle(EPlatForm.MATCH_WELEE, nSession, nAwardID);
	elseif (nState == EPlatForm.DEF_STATE_MATCH_2 or nState == EPlatForm.DEF_STATE_ADVMATCH) then
		return self:OnGetAwardSingle(EPlatForm.MATCH_TEAMMATCH, nSession, nAwardID);
	end
	
	return 1;
end

--领取单场胜利奖励
function EPlatForm:OnGetAwardSingle(nAwardType, nSession, nAwardID)
	-- 混战奖励
	if (self.MATCH_WELEE == nAwardType) then
		local nAwardLevel = EPlatForm:GetAwardLevelSep(nAwardType, nSession, nAwardID);
		
		if (not EPlatForm.AWARD_WELEE_LIST[nSession]) then
			Dialog:Say("没有奖励");
			return 0;
		end
		
		local tbAward = EPlatForm.AWARD_WELEE_LIST[nSession][nAwardLevel];
		if (not tbAward) then
			Dialog:Say("没有奖励");
			return 0;	
		end
		
		local nFree = EPlatForm.Fun:GetNeedFree(tbAward);
		if me.CountFreeBagCell() < nFree then
			Dialog:Say(string.format("您的背包空间不够,请整理%s格背包空间.", nFree));
			return 0;
		end

		--奖励
		EPlatForm.Fun:DoExcute(me, tbAward);

		me.SetTask(self.TASKID_GROUP, self.TASKID_AWARDFLAG, 0);
		EPlatForm:WriteLog("OnGetAwardSingle", string.format("%s获得混战物品奖励 nSession, nAwardID", me.szName), nSession, nAwardID);	
	-- 战队奖励
	elseif (self.MATCH_TEAMMATCH == nAwardType) then
		if (not EPlatForm.AWARD_WELEE_LIST[nSession]) then
			Dialog:Say("没有奖励");
			return 0;
		end
		
		local tbAward = nil;
		
		if (not EPlatForm.AWARD_SINGLE_LIST[nSession]) then
			Dialog:Say("没有奖励");
			return 0;		
		end
		
		-- 胜利奖励
		if (nAwardID == 1) then
			tbAward = EPlatForm.AWARD_SINGLE_LIST[nSession].Win;
		elseif (nAwardID == 2) then
			tbAward = EPlatForm.AWARD_SINGLE_LIST[nSession].Tie;
		elseif (nAwardID == 3) then
			tbAward = EPlatForm.AWARD_SINGLE_LIST[nSession].Lost;
		end
		
		if (not tbAward) then
			Dialog:Say("没有奖励");
			return 0;		
		end
		
		local nFree = EPlatForm.Fun:GetNeedFree(tbAward);
		if me.CountFreeBagCell() < nFree then
			Dialog:Say(string.format("您的背包空间不够,请整理%s格背包空间.", nFree));
			return 0;
		end

		--奖励
		EPlatForm.Fun:DoExcute(me, tbAward);

		me.SetTask(self.TASKID_GROUP, self.TASKID_AWARDFLAG, 0);
		EPlatForm:WriteLog("OnGetAwardSingle", string.format("%s获得战队奖励物品奖励 nSession, nAwardID", me.szName), nSession, nAwardID);	
	end
	return 1;
end

--玩家登陆补领奖励.
function EPlatForm:OnLogin()
	self:RefreshTeamAward(me);
end

function EPlatForm:RefreshTeamAward(pPlayer)
	local szLeagueName = League:GetMemberLeague(EPlatForm.LGTYPE, pPlayer.szName);
	if szLeagueName then
		local nLeagueTotal = League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TOTAL);
		local nLeagueWin = League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_WIN);
		local nLeagueTie = League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_TIE);
		local nSession = League:GetLeagueTask(self.LGTYPE, szLeagueName, self.LGTASK_MSESSION);
		
		if nSession > pPlayer.GetTask(EPlatForm.TASKID_GROUP, EPlatForm.TASKID_HELP_SESSION) then
			pPlayer.SetTask(EPlatForm.TASKID_GROUP, EPlatForm.TASKID_HELP_SESSION, nSession);
			pPlayer.SetTask(EPlatForm.TASKID_GROUP, EPlatForm.TASKID_HELP_TOTLE, nLeagueTotal);
			pPlayer.SetTask(EPlatForm.TASKID_GROUP, EPlatForm.TASKID_HELP_WIN, nLeagueWin);
			pPlayer.SetTask(EPlatForm.TASKID_GROUP, EPlatForm.TASKID_HELP_TIE, nLeagueTie);	
		end
		if pPlayer.GetTask(EPlatForm.TASKID_GROUP, EPlatForm.TASKID_HELP_TOTLE) ~= nLeagueTotal then
			pPlayer.SetTask(EPlatForm.TASKID_GROUP, EPlatForm.TASKID_HELP_TOTLE, nLeagueTotal);
			pPlayer.SetTask(EPlatForm.TASKID_GROUP, EPlatForm.TASKID_HELP_WIN, nLeagueWin);
			pPlayer.SetTask(EPlatForm.TASKID_GROUP, EPlatForm.TASKID_HELP_TIE, nLeagueTie);		
		end
		local nResult = League:GetMemberTask(self.LGTYPE, szLeagueName, pPlayer.szName, self.LGMTASK_AWARD);
		if nResult == 0 then
			return 0
		end

		local nAwardFlag = self:SetAwardFlagParam(0, nSession, EPlatForm.DEF_STATE_MATCH_2, nResult);
		self:SetAwardParam(pPlayer, nAwardFlag);		
		
		League:SetMemberTask(self.LGTYPE, szLeagueName, pPlayer.szName, self.LGMTASK_AWARD, 0);
		EPlatForm:WriteLog("成功补领单场奖励", pPlayer.szName);
	end	
end

function EPlatForm:SendAdvMatchResultMsg(szLeagueName, nResultId)
	if (not szLeagueName or not nResultId or nResultId <= 0 or nResultId > 4) then
		return 0;
	end
	local tbResultName = {
			[1] = "冠军",
			[2] = "亚军",
			[3] = "4强",
			[4] = "8强", 
		};

	local nMacthType = EPlatForm:GetMacthType();
	local tbMacth	= EPlatForm:GetMacthTypeCfg(nMacthType);
	local szMatchName	= "";
	if (tbMacth) then
		szMatchName	= 	tbMacth.szName;
	end

	local szMsg = "恭喜<color=yellow>%s<color>家族的<color=yellow>%s<color>战队在队长<color=yellow>%s<color>的带领下获得了本月家族竞技活动<color=yellow>%s<color>的<color=yellow>%s<color>";
	local szMyMsg = "恭喜您所在队伍获得了比赛的%s"
	local tbMemberList = EPlatForm:GetLeagueMemberList(szLeagueName);
	local szCaptain	= "";
	for _, szMemberName in ipairs(tbMemberList) do
		local nCaptain = League:GetMemberTask(self.LGTYPE, szLeagueName, szMemberName, self.LGMTASK_JOB);
		if (1 == nCaptain) then
			szCaptain = szMemberName;
			break;
		end
	end
	local szKinName = self:GetKinNameFromLeagueName(szLeagueName);
	szMsg = string.format(szMsg, szKinName, szLeagueName, szCaptain, szMatchName, tbResultName[nResultId]);
	szMyMsg = string.format(szMyMsg, tbResultName[nResultId]);
	
	if (1 == nResultId or 2 == nResultId) then
		KDialog.NewsMsg(0, Env.NEWSMSG_NORMAL, szMsg);	
	end
	
	for nId, szName in pairs(tbMemberList) do
		local pPlayer = KPlayer.GetPlayerByName(szName);
		if pPlayer then
			pPlayer.Msg(szMyMsg);
			Dialog:SendBlackBoardMsg(pPlayer, szMyMsg);
			Player:SendMsgToKinOrTong(pPlayer, szMsg, 1);
			pPlayer.SendMsgToFriend(szMsg);
		end
	end
end

function EPlatForm:GetAwardFlagParam(nAwardFlag)	
	local nSession	= KLib.GetByte(nAwardFlag, 3);
	local nState	= KLib.GetByte(nAwardFlag, 2);
	local nAwardID	= KLib.GetByte(nAwardFlag, 1);
	return nSession, nState, nAwardID;
end

function EPlatForm:SetAwardFlagParam(nAwardFlag, nSession, nState, nAwardID)	
	nAwardFlag	= KLib.SetByte(nAwardFlag, 3, nSession);
	nAwardFlag	= KLib.SetByte(nAwardFlag, 2, nState);
	nAwardFlag	= KLib.SetByte(nAwardFlag, 1, nAwardID);
	return nAwardFlag;
end

