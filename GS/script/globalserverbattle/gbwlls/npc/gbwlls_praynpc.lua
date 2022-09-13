-- 跨服联赛祈愿npc

local tbNpc = Npc:GetClass("gbwlls_praynpc");

function tbNpc:OnDialog()
	if (GbWlls.IsOpenEvent1 and GbWlls.IsOpenEvent1 == 0) then
		Dialog:Say("活动没开启！");
		return 0;
	end
	
	if (GbWlls:ServerIsCanJoinGbWlls() == 0) then
		Dialog:Say("跨服联赛还未开启！");
		return;
	end

	if (GbWlls.IsOpen ~= 1) then
		Dialog:Say("跨服联赛还未开启！");
		return;		
	end
	
	local nGblSession = GbWlls:GetGblWllsOpenState();
	if (nGblSession <= 0) then
		Dialog:Say("跨服联赛还未开启！");
		return;
	end
	
	local nState = GbWlls:GetGblWllsState();
	
	local szMsg = "亘古至今，武术之道，唯承上而继下也。为了追求武术的更高境界，特开放跨服联赛，普天之下的侠客们，为本服的参赛选手加油鼓劲吧！你也会得到丰厚的奖励哟。";
	
	local tbOpt = {};
	if (nState == GbWlls.DEF_STATE_MATCH) then
		if (GbWlls.IsOpenEvent2 and GbWlls.IsOpenEvent2 == 1) then
			tbOpt[#tbOpt + 1] = {"为选手祈福", GbWlls.OnPrayPlayer, GbWlls};
		end
	end
	
	if (nState == GbWlls.DEF_STATE_ADVMATCH) then
		if (GbWlls.IsOpenEvent3 and GbWlls.IsOpenEvent3 == 1) then
			table.insert(tbOpt, 1, {"参加竞猜桂冠活动", self.OnGuess8RankInfo, self});
		end
	end
	
	if (nState == GbWlls.DEF_STATE_REST) then
		if (GbWlls.IsOpenEvent3 and GbWlls.IsOpenEvent3 == 1) then
			local tbAwardFlag = GbWlls:GetGuessAwardList(me);
			if (tbAwardFlag and #tbAwardFlag > 0) then
				table.insert(tbOpt, 1, {"领取竞猜桂冠活动奖励", self.OnGetGuess8RankAward, self});
			end
		end
		
		local nStarFlag = GbWlls:CheckStarServer();
		if (nStarFlag == 1) then
			table.insert(tbOpt, {"领取明星服务器奖励", self.OnGetStarServerAward, self});
		end
	end
	
	tbOpt[#tbOpt + 1] = {"了解跨服联赛助威鼓活动", self.About, self};
	tbOpt[#tbOpt + 1] = {"我只是路过的"};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnGuess8RankInfo()
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"进入竞猜桂冠", self.OnGuess8Rank, self};
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ lại"};
	Dialog:Say(GbWlls.MSG_8RANK_GUESS, tbOpt);
end

function tbNpc:OnGuess8Rank()
	if (GbWlls:ServerIsCanJoinGbWlls() == 0) then
		Dialog:Say("跨服联赛还未开启无法竞猜桂冠活动！");
		return 0;
	end
	
	local nGblSession = GbWlls:GetGblWllsOpenState();
	if (nGblSession <= 0) then
		Dialog:Say("跨服联赛还未开启无法竞猜桂冠活动！");
		return 0;
	end

	local nState = GbWlls:GetGblWllsState();
	if (nState ~= GbWlls.DEF_STATE_ADVMATCH) then
		Dialog:Say("不在跨服联赛八强期，不能竞猜桂冠活动！");
		return 0;
	end

	if (not GbWlls.tb8RankInfo) then
		Dialog:Say("没有竞猜名单！");
		return 0;
	end
	if (not GbWlls.tb8RankInfo.nSession) then
		Dialog:Say("没有竞猜名单！");
		return 0;
	end

	GbWlls:ResetPlayer8RankGuessCount(me);

	local tbOpt = self:GetGuessShowList();

	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ lại"};
	Dialog:Say([[黄沙百战穿金甲,不破楼兰终不还。在你心目中，谁才是门派中真正的英雄？谁才是真正的武林高手？看好他就支持他！用你的行动作为他凯旋的徽章吧！<color=yellow>4月28日0点-4月29日19点<color>投票支持心仪选手的时间千万不要错过了哦！]], tbOpt);
end

function tbNpc:GetGuessShowList()
	local tbOpt = {};
	local nSession, nMapType, _, tbRankInfo	= GbWlls:Get8RankGbWllsInfo();
	if (not nSession) then
		return 0;
	end
	
	if (not nMapType) then
		return tbOpt;
	end
	if (not tbRankInfo) then
		return tbOpt;
	end
	-- 门派赛
	if (nMapType == Wlls.MAP_LINK_TYPE_FACTION) then
		for nFaction, tbFaction in pairs(tbRankInfo) do
			local szFaction = Player:GetFactionRouteName(nFaction);
			table.insert(tbOpt, {string.format("%s八强", szFaction), self.Show8RankList, self, nFaction});
		end
	end
	return tbOpt;
end

function tbNpc:Show8RankList(nClass)
	local tbOpt = {};
	if (not nClass) then
		Dialog:Say("没有8强列表可以显示！");
		return 0;
	end

	local nSession, nMapType, _, tbRankInfo	= GbWlls:Get8RankGbWllsInfo();
	if (not nSession) then
		Dialog:Say("没有8强列表可以显示！");
		return 0;
	end
	
	if (not nMapType) then
		Dialog:Say("没有8强列表可以显示！");
		return 0;
	end	
	
	local szMsg = "";
	local tbData = GbWlls:Get8RankLeagueInfo(nClass);
	if (nMapType == Wlls.MAP_LINK_TYPE_FACTION) then
		local szFaction = Player:GetFactionRouteName(nClass);
		szMsg = string.format("<color=yellow>%s<color>门派八强列表", szFaction);
	else
		szMsg = "八强列表";
	end
	
	if (not tbData) then
		Dialog:Say("没有8强列表可以显示！");
		return 0;
	end
	
	for nIdx, tbLeague in pairs(tbData) do
		local nFlag, varParam = GbWlls:CheckFactionGbWllsGuess(me, nClass, nIdx);
		local szMsgInfo = string.format("%s：战队：%s，票数：%s", nIdx, tbLeague.tbInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_LEAGUENAME], tbLeague.nGuessCount or 0);
		-- 已经有存在的
		if (nFlag == 2) then
			szMsgInfo = string.format("<color=yellow>%s；<color>", szMsgInfo);
		end
		tbOpt[#tbOpt + 1] = {szMsgInfo, self.OnLookOnePlayerDetail, self, nClass, nIdx};
	end
	table.insert(tbOpt, {"返回前一页", self.OnGuess8Rank, self});
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnLookOnePlayerDetail(nClass, nLeagueIndex)
	if (not nClass or not nLeagueIndex) then
		Dialog:Say("没有8强列表可以显示！");
		return 0;
	end

	if (GbWlls:ServerIsCanJoinGbWlls() == 0) then
		Dialog:Say("跨服联赛还未开启无法竞猜桂冠！");
		return 0;
	end
	
	local nGblSession = GbWlls:GetGblWllsOpenState();
	if (nGblSession <= 0) then
		Dialog:Say("跨服联赛还未开启无法竞猜桂冠！");
		return 0;
	end

	local nState = GbWlls:GetGblWllsState();
	if (nState ~= GbWlls.DEF_STATE_ADVMATCH) then
		Dialog:Say("不在跨服联赛八强期，不能竞猜桂冠！");
		return 0;
	end
	
	local nSession, nMapType, _, tbRankInfo	= GbWlls:Get8RankGbWllsInfo();
	if (not nSession) then
		Dialog:Say("没有8强列表可以显示！");
		return 0;
	end
	
	if (not nMapType) then
		Dialog:Say("没有8强列表可以显示！");
		return 0;
	end

	local tbLeagueInfo = GbWlls:Get8RankLeagueInfo(nClass, nLeagueIndex);
	
	if (not tbLeagueInfo or not tbLeagueInfo.tbInfo or not tbLeagueInfo.tbList) then
		Dialog:Say("竞猜的战队信息不存在！");
		return 0;
	end
	local tbDetailInfo = tbLeagueInfo.tbInfo;
	
	local szMsg = "";
	
	local szLeagueName = tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_LEAGUENAME];
	local nMType	= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_MATCHTYPE];
	local nRank 	= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_RANK];
	local nWin		= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_WIN];
	local nTie		= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_TIE];
	local nTotal	= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_TOTAL];
	local szTime 	= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_TIME];
	local nRankAdv	= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_ADVRANK];
	local nGateWay	= tbDetailInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_GATEWAY];
	local nLoss		= nTotal-nWin-nTie;
	local nPoint	= nWin * Wlls.MACTH_POINT_WIN + nTie * Wlls.MACTH_POINT_TIE + nLoss * Wlls.MACTH_POINT_LOSS;
	local szRate	= 100.00;
	if nTotal > 0 then
		szRate = string.format("%.2f", (nWin/nTotal)*100) .. "％";
	else
		szRate = "Vô";
	end
	local szRank = "";
	if nRank > 0 then
		szRank = string.format("\n战队排名：<color=white>%s<color>", nRank);
	end
	
	local tbGateInfo	= GbWlls:GetGateWayInfo(nGateWay);
	local szServerName	= "";
	if (tbGateInfo) then
		szServerName	= tbGateInfo.ServerName or "";
	end	

	local szMemberMsg = self:GetLeagueInfoMsg(szLeagueName, tbLeagueInfo.tbList);
	local szMacthName = GbWlls:GetMacthTypeCfg(nMType).szName;
	szMemberMsg = string.format([[%s<color=green>
--战队战绩--
联赛届数：<color=white>第%s届<color>
所属区服：<color=white>%s<color> 
参加比赛：<color=white>%s<color> 
总 场 数：<color=white>%s<color> 
胜    率：<color=white>%s<color>
总 积 分：<color=white>%s<color>
胜：<color=white>%s<color>  平：<color=white>%s<color>  负：<color=white>%s <color>
累计比赛时间：<color=white>%s<color>
%s

]],szMemberMsg, Lib:Transfer4LenDigit2CnNum(nSession), szServerName, szMacthName, nTotal, szRate, nPoint, nWin, nTie, nLoss, szTime, szRank);
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"我想投票", self.OnSureGuessPlayer, self, nClass, nLeagueIndex};
	tbOpt[#tbOpt + 1] = {"返回上一层", self.Show8RankList, self, nClass};
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ lại"};
	Dialog:Say(szMemberMsg, tbOpt);
end

function tbNpc:OnSureGuessPlayer(nClass, nLeagueIndex, nFlag)
	if (not nClass or not nLeagueIndex) then
		Dialog:Say("没有8强列表可以显示！");
		return 0;
	end
	
	local nMoneyRank = PlayerHonor:GetPlayerHonorRankByName(me.szName, PlayerHonor.HONOR_CLASS_MONEY, 0);
	if (nMoneyRank <= 0 or nMoneyRank > GbWlls.DEF_PRAY_MIN_MONEY_HONOR_RANK) then
		Dialog:Say("只有财富荣誉排名在5000名内的玩家才能参与竞猜桂冠！");
		return 0;
	end
	
	local nSession, nMapType, _, tbRankInfo	= GbWlls:Get8RankGbWllsInfo();
	if (not nMapType) then
		Dialog:Say("没有8强列表可以显示！");
		return 0;
	end
	
	local tbLeagueInfo = GbWlls:Get8RankLeagueInfo(nClass, nLeagueIndex);
	if (not tbLeagueInfo or not tbLeagueInfo.tbList) then
		Dialog:Say("没有8强列表可以显示！");
		return 0;
	end
	
	for i, tbPlayer in pairs(tbLeagueInfo.tbList) do
		if (tbPlayer[1] and tbPlayer[1] == me.szName) then
			Dialog:Say("不能给自己的战队投票！");
			return 0;
		end
	end

	local nTime		= GetTime();
	local tbTime	= os.date("*t", nTime);
	
	if (tbTime.day == GbWlls.DEF_ADV_PK_STARTDAY and tbTime.hour >= GbWlls.DEF_ADV_GUESS_TICKET_ENDTIME) then
		Dialog:Say("现在已经过了投票期不能投票了！");
		return 0;
	end

	if (nMapType == Wlls.MAP_LINK_TYPE_FACTION) then
		local nTaskFlag, varParam = GbWlls:CheckFactionGbWllsGuess(me, nClass, nLeagueIndex);
		if (1 ~= nTaskFlag) then
			Dialog:Say(varParam);
			return 0;
		end
		
		if (not nFlag or nFlag ~= 1) then
			Dialog:Say("每人限投一张票，你真的要投给这个人吗？", 
				{
					{"我确定", self.OnSureGuessPlayer, self, nClass, nLeagueIndex, 1},
					{"Để ta suy nghĩ thêm"},	
				});
			return;
		end
		
		GbWlls:SetPlayerGbWllsGuessTask(me, varParam, nClass, nLeagueIndex);
		GbWlls:WriteLog("OnSureGuessPlayer", "Set Ticket sccuess", me.szName, nClass, nLeagueIndex);
		GbWlls:AddGuess8RankPlayer(me.szName, nClass, nLeagueIndex, 1);
		local szMsg = string.format("你把珍贵的票投给了<color=yellow>%s<color>战队！", tbLeagueInfo.tbInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_LEAGUENAME]);
		Dialog:Say(szMsg);
		return 1;
	end
	return 0;
end

function tbNpc:ChechItem(pItem)
	local szFollowItem = string.format("%s,%s,%s,%s", unpack(GbWlls.DEF_ITEM_GUESS));
	local szItem = string.format("%s,%s,%s,%s",pItem[1].nGenre, pItem[1].nDetail, pItem[1].nParticular, pItem[1].nLevel);
	
	if szFollowItem ~= szItem then
		bForbidItem = -1;
	end
	return pItem[1].nCount;
end

function tbNpc:GetLeagueInfoMsg(szLeagueName, tbLeagueList)
	local szMemberMsg = string.format("武林联赛官员：\n所在战队：<color=yellow>%s<color>\n", szLeagueName);
	for nId, tbInfo in ipairs(tbLeagueList) do
		local szMemberName = tbInfo[1];
		if nId == 1 then
			szMemberMsg = string.format("%s战队队长：<color=yellow>%s<color>\n", szMemberMsg, szMemberName);
			
			if #tbLeagueList > 1 then
				szMemberMsg = string.format("%s战队队员：", szMemberMsg);
			else
				szMemberMsg = string.format("%s<color=gray>无战队队员<color>\n", szMemberMsg);
			end 
		else
			szMemberMsg = string.format("%s<color=yellow>%s<color>", szMemberMsg, szMemberName);
			if nId < #tbLeagueList then
				szMemberMsg = string.format("%s，", szMemberMsg);
			end
		end
	end
	return szMemberMsg;
end

function tbNpc:OnGetStarServerAward(nSureFlag)
	if (GbWlls:ServerIsCanJoinGbWlls() == 0) then
		Dialog:Say("跨服联赛还未开启！");
		return;
	end
	
	if (GbWlls.IsOpen ~= 1) then
		Dialog:Say("跨服联赛还未开启！");
		return;		
	end
	
	local nGblSession = GbWlls:GetGblWllsOpenState();
	if (nGblSession <= 0) then
		Dialog:Say("跨服联赛还未开启！");
		return;
	end
	
	
	local nState = GbWlls:GetGblWllsState();
	if nState ~= Wlls.DEF_STATE_REST or GbWlls:GetGblWllsRankFinish() < GbWlls:GetGblWllsOpenState() then
		return 0, 0, string.format("比赛期还未结束或者比赛最终排行还未出来，请耐心等待。");		
	end	
	
	local nStarFlag = KGblTask.SCGetDbTaskInt(GbWlls.GTASK_STARSERVERFLAG);
	
	if (nStarFlag <= 0) then
		Dialog:Say("当前服务器不是明星服务器！");
		return 0;
	end

	local nHonorRank = PlayerHonor:GetPlayerHonorRankByName(me.szName, PlayerHonor.HONOR_CLASS_MONEY, 0);
	if (nHonorRank <= 0 or nHonorRank > GbWlls.DEF_PRAY_MIN_MONEY_HONOR_RANK) then
		Dialog:Say(string.format("只有财富排名在%s名内才能送祝福！", GbWlls.DEF_PRAY_MIN_MONEY_HONOR_RANK));
		return 0;
	end
	
	local nStarTime	= KGblTask.SCGetDbTaskInt(GbWlls.GTASK_STARSERVERFLAG_TIME);
	local nNowTime	= GetTime();
	local tbTime	= os.date("*t", nNowTime);
	local nNowDay	= Lib:GetLocalDay(nNowTime);
	local nStarDay	= Lib:GetLocalDay(nStarTime);
	local nOpenFlag = 0;
	local nDetDay	= nNowDay - nStarDay;
	if (nDetDay < 0) then
		nDetDay = 0;
	end
	local nLastDay	= -1;
	if (1 == nStarFlag or 2 == nStarFlag) then
		nLastDay = GbWlls.DEF_DAY_STARSERVER_1;
	elseif (3 == nStarFlag) then
		nLastDay = GbWlls.DEF_DAY_STARSERVER_3;
	elseif (4 == nStarFlag) then
		nLastDay = GbWlls.DEF_DAY_STARSERVER_4;
	end
	
	if (nDetDay > nLastDay) then
		Dialog:Say("没有礼花可以领取！");
		return 0;
	end
	
	local nGetFlag	= me.GetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_STARSERVER_FLAG);
	local nMyDay	= Lib:GetLocalDay(nGetFlag);
	
	if (nMyDay >= nNowDay) then
		Dialog:Say("你已经领取过礼花了！");
		return 0;
	end
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say(string.format("您的背包空间不够,请整理%s格背包空间.", 1));
		return 0;
	end
	
	if (not nSureFlag or nSureFlag ~= 1) then
		Dialog:Say(string.format("恭喜恭喜！普天同庆！贵服务器在第%s届跨服联赛中总积分排名大区<color=yellow>第%s名<color>。可以获得明星服务器奖励。确定现在领取吗？", nGblSession - 1, nStarFlag),
				{
					{"Xác nhận", self.OnGetStarServerAward, self, 1},	
					{"Ta chỉ đến xem"},
				}
			);
		return 0;
	end		
	
	-- 领取还有其他什么条件？
	me.SetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_STARSERVER_FLAG, nNowTime);
	local pItem = me.AddItem(unpack(GbWlls.DEF_ITEM_STAR_FLOWER));
	if (not pItem) then
		return 0;
	end

	local szTime = string.format("%02d/%02d/%02d/%02d/%02d/%02d", 			
			tbTime.year,
			tbTime.month,
			tbTime.day,
			23,59,59);
	me.SetItemTimeout(pItem, szTime);
	pItem.Sync()
	pItem.SetGenInfo(1,nStarFlag);
	pItem.Bind(1);
	GbWlls:WriteLog("GetStarServerAward", me.szName, nStarFlag);
	return 1;
end

function tbNpc:OnGetGuess8RankAward(nSureFlag)
	if (GbWlls:ServerIsCanJoinGbWlls() == 0) then
		Dialog:Say("跨服联赛还未开启！");
		return;
	end
	
	if (GbWlls.IsOpen ~= 1) then
		Dialog:Say("跨服联赛还未开启！");
		return;		
	end
	
	local nGblSession = GbWlls:GetGblWllsOpenState();
	if (nGblSession <= 0) then
		Dialog:Say("跨服联赛还未开启！");
		return;
	end

	local nState = GbWlls:GetGblWllsState();
	if nState ~= Wlls.DEF_STATE_REST or GbWlls:GetGblWllsRankFinish() < GbWlls:GetGblWllsOpenState() then
		Dialog:Say("比赛期还未结束或者比赛最终排行还未出来，请耐心等待。");
		return 0;
	end
	
	local tbAwardFlag = GbWlls:GetGuessAwardList(me);
	if (not tbAwardFlag or #tbAwardFlag <= 0) then
		Dialog:Say("目前没有奖励可以领取");
		return 0;
	end

	
	local szAwardMsg	= "你所投票的玩家最终结果及获得的奖励：\n";
	local nAwardFlag	= 0;
	for _, tbAward in pairs(tbAwardFlag) do
		local tbLeagueInfo = GbWlls:Get8RankLeagueInfo(tbAward.nClass, tbAward.nIndex);
		if (tbLeagueInfo and tbLeagueInfo.tbInfo) then
			local szLeague = string.format("战队：%s；名次：%s；", tbLeagueInfo.tbInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_LEAGUENAME], tbLeagueInfo.tbInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_RANK]);
			if (tbLeagueInfo.tbInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_RANK] == 1) then
				szLeague = string.format("%s<color=yellow>获得跨服联赛宝箱<color>。", szLeague);
			else
				szLeague = string.format("%s<color=yellow>获得两个福袋<color>。", szLeague);
			end
			szAwardMsg = string.format("%s%s\n", szAwardMsg, szLeague);
			nAwardFlag = 1;
		end
	end
	
	if (not nSureFlag or nSureFlag ~= 1) then
		local tbOpt = {};
		if (nAwardFlag == 1) then
			szAwardMsg = string.format("%s你确定现在领取吗？", szAwardMsg);
			table.insert(tbOpt, {"Xác nhận", self.OnGetGuess8RankAward, self, 1});
		end
		table.insert(tbOpt, {"Ta chỉ đến xem"});
		Dialog:Say(szAwardMsg, tbOpt);
		return 0;
	end

	local tbAwardList	= {};
	local nBagCount		= 0;
	local nBaoXiang		= 0;
	local nFudaiCount	= 0;
	for _, tbAward in pairs(tbAwardFlag) do
		local tbLeagueInfo = GbWlls:Get8RankLeagueInfo(tbAward.nClass, tbAward.nIndex);
		if (tbLeagueInfo and tbLeagueInfo.tbInfo) then
			local nTotalTicket	= GbWlls:GetTotalTicket(tbAward.nClass, tbAward.nIndex);
			local nLeagueCount	= tbLeagueInfo.nGuessCount;
			if (tbLeagueInfo.tbInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_RANK] == 1) then
				nBaoXiang = 1;
			else
				nFudaiCount = 2;
			end
			GbWlls:WriteLog("OnGetGuess8RankAward", "Calu8RankAward", me.szName, tbAward.nClass, tbAward.nIndex, tbLeagueInfo.tbInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_LEAGUENAME], tbLeagueInfo.tbInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_RANK]);
		end
	end
	nBagCount = nBaoXiang + nFudaiCount;
	if (me.CountFreeBagCell() < nBagCount) then
		Dialog:Say(string.format("你的背包空间不足%s格", nBagCount));
		return 0;
	end

	if (nBaoXiang > 0) then
		local tbItem = GbWlls.DEF_ITEM_WINGUESS;
		me.AddStackItem(tbItem[1], tbItem[2], tbItem[3], tbItem[4], {bForceBind=1}, nBaoXiang);
		me.AddTitle(unpack(GbWlls.DEF_STARFANS_TITLE));
		GbWlls:WriteLog("OnGetGuess8RankAward", me.szName, string.format("Add %s GbWllsBaoXiang", nBaoXiang));
	end
	
	if (nFudaiCount > 0) then
		local tbItem = GbWlls.DEF_ITEM_LOSTGUESS8RANK;
		me.AddStackItem(tbItem[1], tbItem[2], tbItem[3], tbItem[4], {bForceBind=1}, nFudaiCount);
		GbWlls:WriteLog("OnGetGuess8RankAward", me.szName, string.format("Add %s fudai", nFudaiCount));		
	end
	
	GbWlls:Clear8RankTaskValue(me);
	GbWlls:WriteLog("OnGetGuess8RankAward", me.szName, "Get 8RankAward Success!!");
end

function tbNpc:OnAbout8RankGuess()
	Dialog:Say([[1、若猜中的选手是冠军，将按比例获得当前选择门派所有的支持度，每1点支持度可获得3个游龙古币。即，如玩家A投了选手甲50票，选手甲竞选期间共计获得500票，选手甲当前门派共获得10000票，则玩家A最终可获得：（50/500）x10000x3个游龙古币=3000个游龙古币
2、若未猜中，那么很遗憾，无论您投了多少月影石也只能拿回2个福袋。
注意事项：
1、玩家只能选择自己当前门派的冠军竞猜，若该玩家同时修炼多个门派，则最多可选择三个门派的冠军竞猜。
2、每个门派只能对一个参赛者进行支持，且对每个参赛者最多投出1000票。]]);
end

tbNpc.tbAbout = 
{
	[1] = [[
    10月7日-27日，循环赛期间，江湖威望排名前5000的玩家可去本服临安府跨服联赛官员旁，敲响跨服联赛助威鼓，为参赛者加油，每天一次，每次可获得一张幸运卡。
    每天的22：00~次日15：00期间使用幸运卡可随机获得一个参赛选手的名字，若该选手在本日比赛中获得过一场胜利，您将随机获得6~9玄、999绑金、9999绑金中的任意一项奖励，快来瞧瞧你是否与当天的比赛胜者有缘吧！
	]],
	[2] = [[
    28日0点至29日晚19点8强决赛前，<color=yellow>财富荣誉达到本服前5000名<color>的玩家可<color=yellow>去临安府跨服联赛官员旁，跨服联赛助威鼓处，支持你认为可能获得冠军的8强选手一次！<color> 
    猜中冠军的玩家可获得“<color=yellow>跨服联赛铁杆粉丝<color>”称号、<color=yellow>特殊光环<color>（一周）、<color=yellow>一个宝箱<color>。
    每个门派获得支持最多的玩家，可获得“跨服联赛XX（门派）明星”的称号。
    <color=orange>注意：每人只可支持一次！不可再切换门派支持其他选手。门派多修的玩家一定要，先选好门派再竞猜哦！<color>
	]],
	[3] = [[
    本大区本次联赛所有选手的总积分最多的四个服务器，还将获得“明星服务器”的称号，全服玩家共享祝福！
    财富荣誉前五千名的侠客们可以到临安跨服联赛助威鼓处领取惊喜奖励，每人每天可领取一次。
	]],
}

function tbNpc:About()
	local tbOpt = 
	{
		{"击鼓呐喊", self.AboutInfo, self, 1},
--		{"竞猜桂冠活动", self.AboutInfo, self, 2},
		{"明星服务器大评选", self.AboutInfo, self, 3},
		{"Kết thúc đối thoại"},
	}
	local szMsg = "亘古至今，武术之道，唯承上而继下也。为了追求武术的更高境界，特开放跨服联赛，普天之下的侠客们，为本服的参赛选手加油鼓劲吧！你也会得到丰厚的奖励哟。";	
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:AboutInfo(nIndex)
	Dialog:Say(string.format(self.tbAbout[nIndex]), {{"Quay lại", self.About, self},{"Kết thúc đối thoại"}});
end


