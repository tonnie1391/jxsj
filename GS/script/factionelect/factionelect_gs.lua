-------------------------------------------------------------------
--File: 	factionelect_gs.lua
--Author: 	zhengyuhua
--Date: 	2008-9-28 18:29
--Describe:	门派选举gs逻辑
-------------------------------------------------------------------

local MAX_PER_PAGE = 10

-- 投票对话逻辑
function FactionElect:VoteDialogLogin(nBegin)
	nBegin = nBegin or 1;
	if (IsVoting() == 0) then
		Dialog:Say("本月门派大师兄/大师姐竞选已经结束！");
	end
	local nElectVer = GetCurElectVer();
	local nVoteVer = me.GetTask(self.TASK_GROUP, self.TASK_VOTE_VER);
	local nVotedId = me.GetTask(self.TASK_GROUP, self.TASK_VOTE_ID);
	local szDialog = "<color=green>票数说明：<color>\n<color=orange>1、1点门派荣誉值可投一张票，门派荣誉可通过参加门派竞技获得。\n2、江湖威望达到福利精活威望时，票数加成10%，达到1.1倍的福利精活威望时，票数加成11%，以此类推，票数最高可加成50%。<color>\n";
	local tbList = GetLastMonthCandidate(me.nFaction);
	local tbOpt = {};
	if nVoteVer ~= nElectVer or nVotedId == 0 then
		for i = nBegin, math.min(nBegin + MAX_PER_PAGE - 1, #tbList) do
			local tbCandidate = tbList[i];
			local szInfo = Lib:StrFillL(tbCandidate.szName, 20)..tbCandidate.nVote.."票";
			table.insert(tbOpt, 
				{szInfo, self.VoteConfirm, self, tbCandidate.nElectId, tbCandidate.szName});
		end
		if nBegin + MAX_PER_PAGE <= #tbList then
			tbOpt[#tbOpt + 1] = {"Trang sau", FactionElect.VoteDialogLogin, FactionElect, nBegin + MAX_PER_PAGE}
		end
		tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ lại"};
		local sz = string.format("\n<color=yellow>可投票数：%d<color>", self:GetFactionVote(me));
		szDialog = szDialog .. sz;
	else
		local szName = "";
		for i, tbCandidate in pairs(tbList) do
			local szInfo = Lib:StrFillL("\n  "..tbCandidate.szName, 20)..tbCandidate.nVote.."票";
			szDialog = szDialog..szInfo;
			if tbCandidate.nElectId == nVotedId then
				szName = tbCandidate.szName;
			end
		end
		
		if szName and szName ~= "" then
			szDialog = szDialog.."\n\n你已经投票给<color=green>"..szName.."<color>了";
		else
			szDialog = szDialog .. "\n\n你已经投过票了";
		end
		

		tbOpt[#tbOpt + 1] = {"Xác nhận"}
	end
	szDialog = szDialog .. string.format("\n第<color=green>%s<color>届%s大师兄/大师姐候选人：", tostring(nElectVer), Player:GetFactionRouteName(me.nFaction));
	Dialog:Say(szDialog, tbOpt);
end
-- 获取门派大师兄或是大师姐投票时玩家可以投的票数
function FactionElect:GetFactionVote(pPlayer)
	if not pPlayer then
		return 0
	end
	local nPrestige = pPlayer.nPrestige;
	local nFactionHonor =  PlayerHonor:GetPlayerHonor(pPlayer.nId, self.HONOR_CLASS, self.HONOR_WULIN_TYPE); 	-- 获取门派荣誉
	local tbBuyJinghuo = Player.tbBuyJingHuo;
	local nVote = nFactionHonor;
	local nDeduct = 0;		-- 计算加成
	if (me.nLevel > tbBuyJinghuo.nLevelMax) then
		local nDayPrestige = tbBuyJinghuo:GetTodayPrestige() or 0;	-- 当天的精活
		if nPrestige >= nDayPrestige then
			nDeduct = nDeduct + self.HONOR_ADDITION;
			local nRePrestige = nPrestige - nDayPrestige;
			local nTemp = math.floor(nDayPrestige * self.HONOR_ADDITION_BASE);
			if nTemp < 1 then
				nTemp = 1;
			end
			if nTemp >= 1 then
				nDeduct = nDeduct + math.floor(nRePrestige / nTemp) * self.HONOR_ADDITION_PERCENT;
			end
		end
	end
	
	if nDeduct > self.HONOR_ADDITION_MAX then
		nDeduct = self.HONOR_ADDITION_MAX;
	end
	
	nVote = nVote + math.floor(nVote * nDeduct);
	
	return nVote;
end

function FactionElect:VoteConfirm(nElectId, szElectName)
	local nVote = self:GetFactionVote(me);
	
	Dialog:Say("你确定要把自己的<color=green>"..nVote.."<color>票投给<color=green>"..szElectName.."<color>吗？",
		{
			{"Xác nhận", self.VoteToCandidate_GS, self, nElectId, me.nId, szElectName},
			{"Để ta suy nghĩ lại"}
		});
end

-- 投票给某个候选人
function FactionElect:VoteToCandidate_GS(nElectId, nPlayerId, szElectName)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	if IsVoting() ~= 1 then
		pPlayer.Msg("现在不是投票期");
	end
	local nElectVer = GetCurElectVer()
	local nVoteVer = pPlayer.GetTask(self.TASK_GROUP, self.TASK_VOTE_VER);
	local nVotedId = me.GetTask(self.TASK_GROUP, self.TASK_VOTE_ID);
	if nVoteVer ~= nElectVer or nVotedId == 0 then
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_VOTE_VER, nElectVer);	-- 设置已投票
		pPlayer.SetTask(self.TASK_GROUP, self.TASK_VOTE_ID, nElectId);
		local nVote = self:GetFactionVote(pPlayer);	-- 获取玩家可以投的票数			--pPlayer.nPrestige;
		if nVote < 0 then
			return 0;
		end
		
		szElectName = szElectName or "";
		Dbg:WriteLog("FactionElect", "玩家",pPlayer.szName, pPlayer.szAccount, "投票", nVote, "门派", pPlayer.nFaction, "nElectId", nElectId,"候选人", szElectName);
		
		GCExcute{"FactionElect:VoteToCandidate_GC", pPlayer.nFaction, nElectId, nPlayerId, nVote};
	else
		pPlayer.Msg("你已经投过票了!");
	end
end

-- 信息反馈
function FactionElect:VoteToCandidate_GS2(nPlayer)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayer);
	if not pPlayer then
		return 0;
	end
	pPlayer.Msg("投票成功！");
	--成就 
--	if me.nSex == 0 then	
		Achievement:FinishAchievement(pPlayer, 84);
--	end
end

-- 领取大师兄大师姐称号对话逻辑
function FactionElect:ObtainWinnerTitle()
	local tbWinner = GetCurWinner(me.nFaction);
	local nCurVer = GetCurElectVer() - 1;
	
	if (not tbWinner or me.nId ~= tbWinner.nPlayerId) then
		Dialog:Say("    每个月的1号，各个大师兄（大师姐）候选人在当日通过同门内的投票选举产生本门的大师兄（大师姐）。\n    上月的门派竞技产生的“新人王”可以获得候选人资格",
			{
				{"你尚未获得大师兄（大师姐）资格，继续努力吧"}
			});
		return 0;
	end
	local nWinVer = me.GetTask(self.TASK_GROUP, self.TASK_WIN_VER);
	if nCurVer == nWinVer then
		Dialog:Say("    每个月的1号，各个大师兄（大师姐）候选人在当日通过同门内的投票选举产生本门的大师兄（大师姐）。\n    上月的门派竞技产生的“新人王”可以获得候选人资格",
			{
				{"你已经领取过大师兄（大师姐）的称号了"}
			});
		return 0;
	end
	local nTitleLevel = (me.nFaction - 1) * 2 + me.nSex + 1;
	me.AddTitle(self.TITEL_GENRE, self.TITEL_TYPE, nTitleLevel, 0);
	me.SetTask(self.TASK_GROUP, self.TASK_WIN_VER, nCurVer);
	-- by zhangjinpin@kingsoft 改为200
	me.AddKinReputeEntry(200);			-- 江湖威望
	local szFaction = Player:GetFactionRouteName(me.nFaction);
	local szFactionMsg = "在"..szFaction.."门派大师兄（大师姐）的评选中胜出，获得了"..szFaction.."大师兄（大师姐）的称号。"
	me.SendMsgToFriend("Hảo hữu ["..me.szName.. "]"..szFactionMsg);
	Player:SendMsgToKinOrTong(me, szFactionMsg, 1);
	
	--成就 
--	if me.nSex == 0 then	
		Achievement:FinishAchievement(me, 85);
		Achievement:FinishAchievement(me, 86);
--	end	
	
	Dialog:Say("    每个月的1号，各个大师兄（大师姐）候选人在当日通过同门内的投票选举产生本门的大师兄（大师姐）。\n    上月的门派竞技产生的“新人王”可以获得候选人资格",
	{
		{"祝贺你获得了本门大师兄（大师姐）称号！"}
	});
	

	return 1;
end

-- 添加事件
function FactionElect:AddAffair(nTongId, szName, szElectVer, szMenpaiName)	
	if szName and szElectVer and szMenpaiName then
		local pTong = KTong.GetTong(nTongId);
		if pTong then
			pTong.AddHistoryFactionElect(szName, szElectVer, szMenpaiName);
			pTong.AddAffairFactionElect(szName, szElectVer, szMenpaiName);
		end
	end
end
