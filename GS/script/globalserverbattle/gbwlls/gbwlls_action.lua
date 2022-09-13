-- 跨服联赛期间的活动

function GbWlls:LoadGbWllsPlayer()
	if (GLOBAL_AGENT) then
		return 0;
	end
	self.tbMatchPlayerList = {};

	if (GbWlls:ServerIsCanJoinGbWlls() == 0) then
		return 0;
	end
	
	local nGblSession = GbWlls:GetGblWllsOpenState();
	if (nGblSession <= 0) then
		return 0;
	end
	
	local nTime		= GetTime();

	if (self:CheckOpenMonth(nTime) == 0) then
		return 0;
	end

	local nState = GbWlls:GetGblWllsState();
	if (nState ~= GbWlls.DEF_STATE_MATCH) then
		return 0;
	end	

	local nType = Ladder:GetType(0, Ladder.LADDER_CLASS_MONEY, Ladder.LADDER_TYPE_MONEY_HONOR_MONEY, 0);
	local tbLadder = GetTotalLadderPart(nType, 1, self.DEF_MAX_NUM_MONEY_HONOR);
	local tbName2Flag = {};
	if (tbLadder) then
		for _, tbInfo in pairs(tbLadder) do
			if (self:CheckIsJoinGbWlls(tbInfo.szPlayerName) == 1) then
				table.insert(self.tbMatchPlayerList, tbInfo.szPlayerName);
				tbName2Flag[tbInfo.szPlayerName] = 1;
			end
		end
	end

	nType = Ladder:GetType(0, Ladder.LADDER_CLASS_WLLS, Ladder.LADDER_TYPE_WLLS_HONOR, 0);
	tbLadder = GetTotalLadderPart(nType, 1, self.DEF_MAX_NUM_WLLS_HONOR);
	if (tbLadder) then
		for _, tbInfo in pairs(tbLadder) do
			if (self:CheckIsJoinGbWlls(tbInfo.szPlayerName) == 1 and not tbName2Flag[tbInfo.szPlayerName]) then
				table.insert(self.tbMatchPlayerList, tbInfo.szPlayerName);
			end
		end
	end
	return 1;
end

function GbWlls:OnPrayPlayer(nFlag)
	if (GbWlls:ServerIsCanJoinGbWlls() == 0) then
		Dialog:Say("跨服联赛还未开启无法送祝福！");
		return 0;
	end
	
	local nGblSession = GbWlls:GetGblWllsOpenState();
	if (nGblSession <= 0) then
		Dialog:Say("跨服联赛还未开启无法送祝福！");
		return 0;
	end
	
	local nTime		= GetTime();
	local tbTime	= os.date("*t", nTime);

	if (self:CheckOpenMonth(nTime) == 0) then
		Dialog:Say("不是在跨服联赛时间段，不能送祝福！");
		return 0;
	end

	local nState = GbWlls:GetGblWllsState();
	if (nState <= GbWlls.DEF_STATE_REST) then
		Dialog:Say("不在跨服联赛比赛期，不能送祝福！");
		return 0;
	end
	
	local nGetFlag	= me.GetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_PRAY_TIME);
	local nLastDay	= Lib:GetLocalDay(nGetFlag);
	local nNowDay	= Lib:GetLocalDay(nTime);
	if (nLastDay >= nNowDay) then
		Dialog:Say("您今天已经送过祝福了！");
		return 0;
	end
	
	local nHonorRank = PlayerHonor:GetPlayerHonorRankByName(me.szName, PlayerHonor.HONOR_CLASS_WEIWANG, 0);
	if (nHonorRank == 0 or nHonorRank > GbWlls.DEF_GUESS_MIN_PRESTIGE_RANK) then
		Dialog:Say(string.format("只有江湖威望排名在5000名内才能送祝福！", GbWlls.DEF_GUESS_MIN_PRESTIGE_RANK));
		return 0;
	end	

	if (not nFlag or nFlag ~= 1) then
		Dialog:Say(string.format([[    当今武林英雄辈出，我服务器中有一批侠士也参加了跨服联赛的比试。
    跨服联赛预赛期间%s月7日-%s月27日，为他们加油，你将会得到<color=yellow>跨服联赛幸运卡<color>，幸运卡要在<color=yellow>当日22点后到次日15点前<color>打开，将随机抽取到一名报名跨服联赛的选手，只要该选手在今日比赛中获得过一场胜利则你会获得跨服联赛幸运宝箱，奖励丰厚。]], tbTime.month, tbTime.month), 
		{
			{"送上我的祝福", self.OnPrayPlayer, self, 1},
			{"等会儿再送吧"},	
		});
		return 1;
	end
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say(string.format("您的背包空间不够,请整理%s格背包空间。", 1));
		return 0;
	end
	
	local tbItemResult = me.FindItemInAllPosition(unpack(GbWlls.DEF_ITEM_LUCK_GBWLLS_CARD));
	if #tbItemResult > 0 then
		Dialog:Say(string.format("你的背包里或者是储物箱中有相同的跨服联赛幸运卡存在，不能重复领取。"));
		return 0;
	end
	
	me.SetTask(GbWlls.TASKID_GROUP, GbWlls.TASKID_PRAY_TIME, nTime);

	-- todo 给奖励
	local tbItem = GbWlls.DEF_ITEM_LUCK_GBWLLS_CARD;
	local pItem = me.AddItemEx(tbItem[1], tbItem[2], tbItem[3], tbItem[4], {bForceBind=1});
	if (not pItem) then
		return 0;
	end

	local szTime = string.format("%02d/%02d/%02d/%02d/%02d/%02d", 			
			tbTime.year,
			tbTime.month,
			tbTime.day + 1,
			15, 0, 0);
	me.SetItemTimeout(pItem, szTime);
	pItem.Sync()
	pItem.SetGenInfo(1, nTime);

	return 1;
end

function GbWlls:AddGuessTicket_GS(szLeagueName, nCount)
	if (not szLeagueName or not nCount) then
		return 0;
	end
	if (not self.tb8RankInfo) then
		return 0;
	end
	local tb8RankInfo = self.tb8RankInfo;
	local nSession	= tb8RankInfo.nSession;
	local nMapType	= tb8RankInfo.nMapType;
	local nState	= tb8RankInfo.nState;
	if (nMapType == Wlls.MAP_LINK_TYPE_FACTION) then
		for nFaction, tbInfo in pairs(tb8RankInfo.tbInfo) do
			if (tbInfo) then
				for j, tbLeagueInfo in ipairs(tbInfo) do
					local szLeague	= tbLeagueInfo.tbInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_LEAGUENAME];
					if (szLeagueName == szLeague) then
						local nLastGuess = tbLeagueInfo.nGuessCount or 0;
						nLastGuess = nLastGuess + nCount;
						if (nLastGuess < 0) then
							nLastGuess = 0;
						end
						tbLeagueInfo.nGuessCount = nLastGuess;
					end
				end
			end
		end		
	end
end

function GbWlls:AddGuessTicket_GC(szLeagueName, nCount)
	if (not MODULE_GC_SERVER) then
		return 0;
	end

	if (not szLeagueName or not nCount) then
		return 0;
	end

	if (not self.tb8RankInfo) then
		return 0;
	end

	local tb8RankInfo = self.tb8RankInfo;
	local nSession	= tb8RankInfo.nSession;
	local nMapType	= tb8RankInfo.nMapType;
	local nState	= tb8RankInfo.nState;
	
	if (nMapType == Wlls.MAP_LINK_TYPE_FACTION) then
		for nFaction, tbInfo in pairs(tb8RankInfo.tbInfo) do
			if (tbInfo) then
				for j, tbLeagueInfo in ipairs(tbInfo) do
					if (tbLeagueInfo.tbInfo) then
						local szLeague	= tbLeagueInfo.tbInfo[GbWlls.DEF_INDEX_GBWLLS_8RANK_LEAGUENAME];
						if (szLeagueName == szLeague) then
							local nLastGuess = tbLeagueInfo.nGuessCount or 0;
							nLastGuess = nLastGuess + nCount;
							if (nLastGuess < 0) then
								nLastGuess = 0;
							end
							tbLeagueInfo.nGuessCount = nLastGuess;
						end
					end
				end
			end
		end
	end
	GlobalExcute({"GbWlls:AddGuessTicket_GS", szLeagueName, nCount});
end

if (MODULE_GAMESERVER) then
	ServerEvent:RegisterServerStartFunc(GbWlls.LoadGbWllsPlayer, GbWlls);
end
