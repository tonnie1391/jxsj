--联赛奖励
--孙多良
--2008.09.23

--检查领取单场胜利奖项
function GbWlls:OnCheckAwardSingle(pPlayer, nGbTaskId, nTaskId)
	if (not pPlayer) then
		return 0;
	end
	
	if (not nGbTaskId or not nTaskId or nGbTaskId <= 0 or nTaskId <= 0) then
		return 0;
	end
	
	local nGblSession		= GbWlls:GetGblWllsOpenState();
	local nMyGblSession		= GbWlls:GetPlayerGblWllsSessionByName(pPlayer.szName);
	local nMatchWinCount	= GbWlls:GetPlayerSportTask(pPlayer.szName, nGbTaskId);
	local nAlreadyGetAward	= pPlayer.GetTask(GbWlls.TASKID_GROUP, nTaskId);
	local nMySession		= pPlayer.GetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_MATCH_SESSION);
	if (nGblSession <= 0) then
		return 0;
	end
	
	if (nMyGblSession <= 0) then
		return 0;
	end
	
	if (nGblSession ~= nMyGblSession) then
		return 0;
	end
	
	if (nMySession ~= nMyGblSession) then
		return 0;
	end

	if nMatchWinCount > 0 and nMatchWinCount > nAlreadyGetAward then
		return nTaskId;
	end
	return 0;
end

function GbWlls:UpdateMatchAwardCount(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	
	local nGblSession		= GbWlls:GetGblWllsOpenState();
	local nMyGblSession		= GbWlls:GetPlayerGblWllsSessionByName(pPlayer.szName);
	local nAlreadyGetAward	= pPlayer.GetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_MATCH_WIN_AWARD);
	local nMySession		= pPlayer.GetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_MATCH_SESSION);
	if (nGblSession <= 0) then
		return 0;
	end
	
	if (nMyGblSession <= 0) then
		return 0;
	end
	
	if (nMySession == nMyGblSession) then
		return 0
	end

	pPlayer.SetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_MATCH_SESSION, nMyGblSession);
	pPlayer.SetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_MATCH_LOSE_AWARD, 0);
	pPlayer.SetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_MATCH_WIN_AWARD, 0);
	pPlayer.SetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_MATCH_TIE_AWARD, 0);
	
	return 0;
end

--领取单场胜利奖励
function GbWlls:OnGetAwardSingle(nGbTaskId, nTaskId)
	self:UpdateMatchAwardCount(me);
	local nFlag = GbWlls:OnCheckAwardSingle(me, nGbTaskId, nTaskId);
	if nFlag == 0 then
		Dialog:Say("目前没有可以领取的奖励。");
		return 0;
	end

	local nMatchWinCount	= GbWlls:GetPlayerSportTask(me.szName, nGbTaskId);
	local nAlreadyGetAward	= me.GetTask(GbWlls.TASKID_GROUP, nTaskId);
	
	local nDet = nMatchWinCount - nAlreadyGetAward;
	if (nDet <= 0) then
		Dialog:Say("目前没有可以领取的奖励。");
		return 0;
	end
		
	local szMsg = string.format("目前您有<color=yellow>%d<color>个奖励没有领取，确定领取吗？", nDet);
	Dialog:Say(szMsg, 
		{
			{"我确定领取", self.GetSingleAward, self, nGbTaskId, nTaskId},
			{"过段时间再来拿"},
		}
	);

end

function GbWlls:GetSingleAward(nGbTaskId, nTaskId)
	self:UpdateMatchAwardCount(me);
	local nFlag = GbWlls:OnCheckAwardSingle(me, nGbTaskId, nTaskId);
	if nFlag == 0 then
		return 0;
	end

	local nGameLevel	= GbWlls:GetPlayerSportTask(me.szName, self.GBTASKID_MATCH_LEVEL);
	if (nGameLevel <= 0) then
		return 0;
	end

	local nMatchWinCount	= GbWlls:GetPlayerSportTask(me.szName, nGbTaskId);
	local nCount			= me.GetTask(GbWlls.TASKID_GROUP, nTaskId);
	
	local nSession		= GbWlls:GetPlayerGblWllsSessionByName(me.szName);
	local tbAward		= {};
	local nFreeCount	= 0;
	if (self.TASKID_MATCH_WIN_AWARD == nTaskId) then
		tbAward	= GbWlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Win;
		nFreeCount = GbWlls.Fun:GetNeedFree(tbAward);
		nFreeCount = nFreeCount + 1;
	elseif (self.TASKID_MATCH_LOSE_AWARD == nTaskId) then
		tbAward	= GbWlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Lost;
		nFreeCount	= GbWlls.Fun:GetNeedFree(tbAward);
	elseif (self.TASKID_MATCH_TIE_AWARD == nTaskId) then
		tbAward	= GbWlls.AWARD_SINGLE_LIST[nGameLevel][nSession].Tie;
		nFreeCount	= GbWlls.Fun:GetNeedFree(tbAward);
	end
	
	if me.CountFreeBagCell() < nFreeCount then
		Dialog:Say(string.format("您的背包空间不够,请整理%s格背包空间.", nFreeCount));
		return 0;
	end
	
	if (nMatchWinCount - nCount <= 0) then
		Dialog:Say("目前没有可以领取的奖励。");
		return 0;
	end	
	
	GbWlls.Fun:DoExcute(me, tbAward);
	if (self.TASKID_MATCH_WIN_AWARD == nTaskId) then
		local pItem = me.AddItem(18,1,548,1);
		if pItem then
			Dbg:WriteLog("GbWlls","成功领取跨服联赛礼包", me.szName);
		end
		Dialog:Say("您获得了一个<color=yellow>跨服联赛礼包<color>。");		
	elseif (self.TASKID_MATCH_LOSE_AWARD == nTaskId) then
		-- TODO
	elseif (self.TASKID_MATCH_TIE_AWARD == nTaskId) then
		-- TODO
	end
	
	SpecialEvent.ActiveGift:AddCounts(me, 33);		--领取宋跨服联赛奖励完成跨服联赛活跃度
	
	me.SetTask(GbWlls.TASKID_GROUP, nTaskId, nCount + 1);
end

--最终奖励，有奖励时优先弹出奖励选项
function GbWlls:OnCheckAward(pPlayer, nGameLevel)
	if (not pPlayer) then
		return 0, 0, "";
	end
	
	local nGblSession		= GbWlls:GetGblWllsOpenState();
	local nMyGblSession		= GbWlls:GetPlayerGblWllsSessionByName(pPlayer.szName);
	
	if (nGblSession <= 0) then
		return 0, 0, string.format("跨服联赛还是未开启，无法领取奖励！");
	end

	if not nGameLevel or nGameLevel <= 0 then
		return 0, 0 ,string.format("您不是跨服武林联赛的参赛选手。");
	end
	
	if GbWlls:GetGblWllsState() ~= Wlls.DEF_STATE_REST or GbWlls:GetGblWllsRankFinish() < GbWlls:GetGblWllsOpenState() then
		return 0, 0, string.format("比赛期还未结束或者比赛最终排行还未出来，请耐心等待。");		
	end
	
	local nTotal = self:GetPlayerSportTask(pPlayer.szName, self.GBTASKID_MATCH_WIN_AWARD) + self:GetPlayerSportTask(pPlayer.szName, self.GBTASKID_MATCH_LOSE_AWARD) + self:GetPlayerSportTask(pPlayer.szName, self.GBTASKID_MATCH_TIE_AWARD);
	if nTotal <= 0 then
		return 0, 0, string.format("您的战队还未参加过比赛，是新建战队，不能领取奖励。");	
	end
	local nRank		= self:GetPlayerSportTask(pPlayer.szName, self.GBTASKID_MATCH_RANK);
	local nAdvRank	= self:GetPlayerSportTask(pPlayer.szName, self.GBTASKID_MATCH_ADVRANK);
	
	if pPlayer.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_FINAL_AWARD) >= nMyGblSession then
		return 0, 0 , string.format("您已领取过奖励了。");
	end	
	
	
	if nRank == 1 and nAdvRank == 2 then
		nRank = 2;
	end	

	local nLevelSep, nMaxRank = GbWlls:GetAwardLevelSep(nGameLevel, nMyGblSession, nRank);
	if nLevelSep <= 0 then
		return 0, 0, string.format("您的战队没有奖励可以领取。");
	end

	if nMaxRank >= 10000 and nTotal < math.floor(nMaxRank/10000) then
		return 0, 0 , string.format("您的战队在本届比赛中没有获得任何奖励,请下届继续努力。");
	end
	return 1, nRank , string.format("领取奖励");
end


--领取最终奖励
function GbWlls:OnGetAward(nFlag)
	local nGameLevel = self:GetPlayerSportTask(me.szName, self.GBTASKID_MATCH_LEVEL);
	if (nGameLevel <= 0) then
		Dialog:Say("目前没有可以领取的奖励。");
		return 0;
	end
	local nCheck,nRank,szError = GbWlls:OnCheckAward(me, nGameLevel);
	
	if nCheck == 0 then
		Dialog:Say(szError);
		return 0;
	end

	local nSession		= GbWlls:GetPlayerGblWllsSessionByName(me.szName);
	local nMatchType	= self:GetMacthType(nSession);
	local tbMatchType	= self:GetMacthTypeCfg(nMatchType);
	local nLevelSep, nMaxRank = GbWlls:GetAwardLevelSep(nGameLevel, nSession, nRank);

	local szRank = string.format("第%d名", nRank);	
	
	--变量设置
	if nRank == 1 then
		me.SetTask(self.TASKID_GROUP, self.TASKID_MATCH_FIRST, me.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_FIRST) + 1);
		szRank = "冠军";
	end
	if nRank == 2 then
		me.SetTask(self.TASKID_GROUP, self.TASKID_MATCH_SECOND, me.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_SECOND) + 1);
		szRank = "亚军";
	end
	if nRank == 3 then
		me.SetTask(self.TASKID_GROUP, self.TASKID_MATCH_THIRD, me.GetTask(self.TASKID_GROUP, self.TASKID_MATCH_THIRD) + 1);
		szRank = "季军";
	end

	local nTotal = self:GetPlayerSportTask(me.szName, self.GBTASKID_MATCH_WIN_AWARD) + self:GetPlayerSportTask(me.szName, self.GBTASKID_MATCH_LOSE_AWARD) + self:GetPlayerSportTask(me.szName, self.GBTASKID_MATCH_TIE_AWARD);	
	
	if (nMaxRank >= 10000) then
		local nMaxMatch = math.floor(nMaxRank/10000);
		if (nMaxMatch <= nTotal) then
			szRank = string.format("打满<color=yellow>%s<color>场", nMaxMatch);
		end
	else
		szRank = string.format("<color=yellow>%s<color>", szRank);
	end

	local nLevel = self:GetPlayerSportTask(me.szName, self.GBTASKID_MATCH_LEVEL);
	local szGameLevelName = Wlls.MACTH_LEVEL_NAME[nLevel];
	if (GbWlls:CheckOpenGoldenGbWlls() == 1) then
		szGameLevelName = GbWlls.MACTH_LEVEL_NAME[nLevel];
	end

	if not nFlag then
		local szMsg = string.format("跨服武林联赛官员：您的战队在上届%s武林联赛中获得了%s，确定现在领取吗？", szGameLevelName, szRank);
		local tbOpt = 
		{
			{"我确定领取奖励",self.OnGetAward, self, 1},
			{"Để ta suy nghĩ lại"},
		}
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	local nFree = GbWlls.Fun:GetNeedFree(GbWlls.AWARD_FINISH_LIST[nGameLevel][nSession][nLevelSep]);
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
		
	me.SetTask(self.TASKID_GROUP, self.TASKID_MATCH_FINAL_AWARD, nSession);
	me.SetTask(self.TASKID_GROUP, self.TASKID_GETFINALAWARD_TIME, GetTime());
	local nLogTaskFlag = nSession + nLevelSep * 1000 + nGameLevel * 1000000;
	me.SetTask(self.TASKID_GROUP, self.TASKID_AWARD_LOG, nLogTaskFlag);	
	
	--奖励
	GbWlls.Fun:DoExcute(me, GbWlls.AWARD_FINISH_LIST[nGameLevel][nSession][nLevelSep]);

	local nStarPlayerFlag = self:GetPlayerSportTask(me.szName, GbWlls.GBTASKID_MATCH_DAILY_RESULT);
	if (nStarPlayerFlag > 0 and nStarPlayerFlag < 100) then
		self:GiveStarPlayerTitle(me, nStarPlayerFlag);
	end

	-- 玩家领取武林联赛最终奖励的客服log
	local szLogMsg = string.format("玩家：%s 参赛场次：%s 名次：%s， 已经领取跨服武林联赛奖励。", me.szName, nTotal, nRank);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLogMsg);
	
	
	StatLog:WriteStatLog("stat_info", "kfwlls", "final_award", me.nId, string.format("%s,%s", nGameLevel, nRank));
	
	-- 公告提示
	local _, szServerName = self:GetZoneNameAndServerName();
	
	Dialog:Say("您成功领取了奖励。");
	GbWlls:WriteLog(me.szAccount, me.szName, string.format("%s级跨服联赛排名:%s, 路线:%s", nGameLevel, nRank, Player:GetFactionRouteName(me.nFaction, me.nRouteId)))	
	
	local szAnncone = string.format("<color=green>%s玩家%s<color>在上一届跨服武林联赛中获得了<color=red>%s<color>！！！", szServerName, me.szName, szRank);
	local szKinOrTong = string.format("在上一届武林联赛中获得了<color=red>%s<color>的好成绩。", szRank);
	local szFriend = string.format("Hảo hữu [<color=green>%s<color>]在上届武林联赛中获得了<color=red>%s<color>。", me.szName, szRank);
	
	if (nRank <= 0) then
		return 0;
	end
	
	-- 前3名
	if nRank <= 3 then
		Dialog:GlobalMsg2SubWorld(szAnncone);
		Dialog:GlobalNewsMsg(szAnncone);
		Player:SendMsgToKinOrTong(me, szKinOrTong, 1);
	-- 前8名
	elseif nRank <= 8 then
		KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, szAnncone);
		Player:SendMsgToKinOrTong(me, szKinOrTong, 1);
	end
	
	-- 好友公告
	me.SendMsgToFriend(szFriend);
end

function GbWlls:GiveStarPlayerTitle(pPlayer, nStarPlayerFlag)
	if (not pPlayer or not nStarPlayerFlag) then
		return 0;
	end
	
	if (2 == nStarPlayerFlag) then
		local nFaction = self:GetPlayerSportTask(me.szName, GbWlls.GBTASKID_MATCH_TYPE_PAREM);
		if (nFaction <= 0 or nFaction > 12) then
			self:WriteLog("GiveStarPlayerTitle", "Give Star Player Title failed", pPlayer.szName, nFaction);
			return 0;
		end
		pPlayer.AddTitle(self.DEF_STARPLAYER_FAC_TITLE[1], self.DEF_STARPLAYER_FAC_TITLE[2], nFaction, 0);
		self:WriteLog("GiveStarPlayerTitle", pPlayer.szName, nFaction);
	end
	return 1;
end

function GbWlls:GiveLuckCardAward(pPlayer, nNowTime)
	if (not pPlayer or not nNowTime) then
		return 0;
	end

	if (not self.tbMatchPlayerList) then
		self:WriteLog("GiveLuckCardAward", "tbMatchPlayerList is not exist!!!!", pPlayer.szName);
		return 0;
	end
	
	local nMaxCount = #self.tbMatchPlayerList;
	if (nMaxCount <= 0) then
		local tbItem = GbWlls.DEF_ITEM_LOSTGUESS;
		pPlayer.AddStackItem(tbItem[1], tbItem[2], tbItem[3], tbItem[4], {bForceBind=1}, GbWlls.DEF_ITEM_LOSTGUESS_COUNT);
		pPlayer.Msg("目前还没有玩家报名，谢谢您的参与！");
		return 0;
	end
	local nRandomResult = MathRandom(1, nMaxCount);
	local szGuessName = self.tbMatchPlayerList[nRandomResult];
	
	if (not szGuessName) then
		pPlayer.Msg("玩家异常，谢谢您的参与！");
		return 0;		
	end

	local nNowDay	= Lib:GetLocalDay(nNowTime);
	local nResult	= self:GetPlayerSportTask(szGuessName, self.GBTASKID_MATCH_DAILY_RESULT);
	local nWinDay	= Lib:GetLocalDay(nResult); 
	local szMsg		= "";
	if (nNowDay == nWinDay and nNowDay > 0) then
		szMsg = string.format(string.format("<color=yellow>%s<color>玩家是你今天的幸运星，他在今天的所参加的比赛中至少赢得了一场比赛的胜利，恭喜你！", szGuessName));
		local tbItem = GbWlls.DEF_ITEM_WINGUESS;
		pPlayer.AddStackItem(tbItem[1], tbItem[2], tbItem[3], tbItem[4], {bForceBind=1}, self.DEF_ITEM_WINGUESS_COUNT);
	else
		szMsg = string.format("玩家<color=yellow>%s<color>是你今天的幸运星，可惜今天状态不好，没有赢得今天比赛的胜利！", szGuessName);
		local tbItem = GbWlls.DEF_ITEM_LOSTGUESS;
		pPlayer.AddStackItem(tbItem[1], tbItem[2], tbItem[3], tbItem[4], {bForceBind=1}, GbWlls.DEF_ITEM_LOSTGUESS_COUNT);
	end
	
	GbWlls:WriteLog("GiveLuckCardAward", pPlayer.szName, szGuessName);
	
	pPlayer.Msg(szMsg);
	return 1;	
end
