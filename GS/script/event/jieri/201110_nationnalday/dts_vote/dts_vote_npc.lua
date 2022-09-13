-- 文件名　：Dts_Vote_npc.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-07 20:22:59
-- 功能    ：

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\event\\jieri\\201110_nationnalday\\dts_vote\\dts_vote_def.lua");
local tbDtsVote = SpecialEvent.Dts_Vote;

function tbDtsVote:Vote()
		local szMsg = [[在寒武的祝福活动期间<color=yellow>9月28日0:00—9月30日23:59，<color>各位侠客可以在我这儿为自己喜欢的寒武勇士送上祝福。使用月影之石在<color=yellow>【龙五太爷】<color>处购买，每个月影之石可购买一张【寒武勇士祝福卡】。比赛结束后，<color=red>若自己送祝福的勇士荣登寒武遗迹勇士榜，更有巨额绑金，璀璨宝石等丰厚奖励可领取。<color>
活动期间，每人最多可以使用10张【寒武勇士祝福卡】，每位侠客只能对同一个选手投注<color=red>1<color>票。
每送出祝福卡一张即可返还200绑金，且在领奖时间内每张祝福卡均有500绑金，30000绑银奖励领取。<color=green>最多可领取7000绑金、300000绑银。<color>
    侠客们所祝福的选手需要手动进行输入名字，可以在各大排行榜处查询你所喜爱选手的名字。
]];
		local tbOpt = {};
		table.insert(tbOpt,{"查看寒武遗迹比赛情况", self.QueryLadder, self});
		table.insert(tbOpt,{"查询奖池数量", self.QueryAwardInfo, self});
		if self:GetState() == self.emVOTE_STATE_AWARD then
			if tonumber(GetLocalDate("%Y%m%d")) ~= self.TIME_AWARD_START or tonumber(GetLocalDate("%H%M")) >= 10 then
				table.insert(tbOpt,{"<color=yellow>领取寒武大猜想奖励<color>", self.GetAward, self});
			end
		end
		if self:GetState() == self.emVOTE_STATE_SIGN then
			table.insert(tbOpt,{"<color=yellow>我要给侠士投票<color>", self.VoteTickets, self});
		end
		table.insert(tbOpt,{"查询前10名排行", self.QueryRank, self});
		table.insert(tbOpt,{"查询自己的信息", self.QueryByName, self, me.szName});
		table.insert(tbOpt,{"查询票数信息", self.QueryIntPutName, self});
		table.insert(tbOpt,{"查询自己投票的信息", self.QueryBySelf, self});
		table.insert(tbOpt,{"Ta chỉ xem qua Xóa bỏ"});
		Dialog:Say(szMsg, tbOpt);	
		return;
end

--打开排行榜
function tbDtsVote:QueryLadder()
	me.CallClientScript({"UiManager:OpenWindow", "UI_LADDER",2,2});
end

--检查是否是pk榜前10玩家的前5粉丝
function tbDtsVote:CheckPKLadderFans(pPlayer)
	local nType = Ladder:GetType(0, Ladder.LADDER_CLASS_LADDER,Ladder.LADDER_TYPE_LADDER_ACTION, Ladder.LADDER_TYPE_LADDER_ACTION_BEAUTYHERO);
	local tbShowLadder	= GetTotalLadderPart(nType, 1, 10);
	local tbBuf = self:GetGblBuf() or {};
	local tbFans = nil;
	for _, tbInfo in ipairs(tbShowLadder) do
		if tbBuf[tbInfo.szPlayerName] then	
			tbFans = tbBuf[tbInfo.szPlayerName].tbFans or {};
			for i = 1,  #tbFans do	
				if tbFans[i].szName	== pPlayer.szName then
					return 1;
				end
			end	
		end
	end
	
	return 0;
end

function tbDtsVote:VoteTickets()
	if me.nLevel < self.LEVEL_LIMIT then
		Dialog:Say("您等级不足"..self.LEVEL_LIMIT.."级。");
		return;
	end
	if me.nFaction <= 0 then
		Dialog:Say("请您先加入门派。");
		return;
	end
	Dialog:AskString("请输入侠士名", 16, self.VoteTickets1, self);
	return;
end

function tbDtsVote:VoteTickets1(szName)
	Dialog:Say(string.format("您确定要给侠士<color=yellow>%s<color>祝福？", szName), {{"Xác nhận", self.VoteTicketsEx, self, szName},{"Để ta suy nghĩ thêm"}});
	return;
end

function tbDtsVote:QueryIntPutName()
	Dialog:AskString("请输入侠士名", 16, self.QueryByName,  self);	
end

function tbDtsVote:QueryBySelf()
	local szMsgEx = "在寒武的祝福活动期间<color=yellow>9月28日0:00—9月30日23:59<color>，各位侠客可以在<color=yellow>【卖火柴的小女孩】<color>处为自己喜欢的寒武勇士进行祝福。在寒武遗迹竞技比赛结束后，若自己送祝福的勇士荣登寒武遗迹勇士榜，更有丰厚奖励可领取。赶快为你仰慕的勇士去送上祝福吧。";
	local szMsg = "\n<color=green>你为下列玩家送上了寒武的祝福：<color>\n";
	local nFlag = 0;
	for nTask = self.TSKSTR_FANS_NAME[1], self.TSKSTR_FANS_NAME[2] - self.DEF_TASK_SAVE_FANS, self.DEF_TASK_SAVE_FANS do
		local szPlayerName = me.GetTaskStr(self.TSK_GROUP, nTask);
		if szPlayerName ~= "" then
			szMsg = szMsg..szPlayerName.."\n";
			nFlag = 1;
		else
			szMsg = szMsgEx..szMsg
			Dialog:Say(szMsg);
			return;
		end
	end
	if nFlag == 0 then
		szMsg = "\n<color=red>您还没有祝福过玩家。<color>";
	end
	szMsg = szMsgEx..szMsg
	Dialog:Say(szMsg);
	return;
end

function tbDtsVote:QueryByName(szName)
	local tbBuf = self:GetGblBuf();
	if not tbBuf[szName] then
		Dialog:Say("没有该侠士信息");
		return 0;
	end
	
	local nTickets = tbBuf[szName].nTickets or 0;
	local szTickets = string.format("目前<color=yellow>%s<color>的票数为：<color=green>%s<color> ",szName, nTickets);

	local nUseTask, nNews = self:GetTaskGirlVoteId(szName);
	if nNews ~= 1 and nUseTask ~= 0 then
		szTickets = szTickets.."\n您已经投过该侠士";
	else
		szTickets = szTickets.."\n您未投过该侠士";
	end
	Dialog:Say(szTickets);
end

function tbDtsVote:QueryAwardInfo()
	Dialog:Say(string.format([[目前奖池拥有的绑金数量<color=yellow>%s<color>，原石宝箱数<color=yellow>%s<color>个。
		<color=yellow>10月12日<color>寒武遗迹勇士榜排名更新后，若自己送祝福的勇士在排行榜前<color=yellow>10名<color>，即可<color=red>再次领取大量高额绑金奖励，所送祝福的勇士上榜越多，侠客们获得的奖励越多。更有机率获得【国庆原石宝箱】。点击后可获得2-5级原石中的随机一种。<color>
每送出祝福卡一张即可返还200绑金，且在领奖时间内每张祝福卡均有500绑金，30000绑银奖励领取。<color=green>最多可领取7000绑金、300000绑银。<color>
]], self:GenAwardInfo()));
end

function tbDtsVote:QueryRank()
	if not self.tbRankBuffer or #self.tbRankBuffer == 0 then
		Dialog:Say("目前还没有排行榜。");
		return;
	end
	
	local szMsg = "  侠士名称              票数\n";
	local tbBuf = self:GetGblBuf();
	local nTickets = 0;
	local szTmp = "";
	local szFmt = "";
	for nIndex, tbInfo in ipairs(self.tbRankBuffer) do
		if tbBuf[tbInfo.szName] then
			nTickets = tbBuf[tbInfo.szName].nTickets;
		else 
			nTickets = tbInfo.nTickets;
		end
		szFmt = string.format("%d.%s",nIndex,tbInfo.szName);
		szTmp = string.format("%s    %d\n",Lib:StrFillL(szFmt, 20), nTickets);
		szMsg = szMsg..szTmp;
	end
	szMsg = szMsg.."\n<color=red>注：票数刷新时间为每天凌晨00:05分<color>"
	Dialog:Say(szMsg);
end

function tbDtsVote:GetAward()
	local tbOpt = {		
		{"领取大猜想奖励", self.GetVoteAward, self},
		{"领取祝福卡奖励", self.GetBaseAward, self},
		{"Ta chỉ đến xem thôi"},
	};
	Dialog:Say("想领取啥奖励呢？", tbOpt);
end

--基础奖励
function tbDtsVote:GetBaseAward()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate < self.TIME_AWARD_START then
		Dialog:Say("寒武勇士大猜想奖励还未开始领取");
		return 0;
	end
	if nCurDate > self.TIME_AWARD_END then
		Dialog:Say("寒武勇士大猜想奖励领取已经结束");
		return 0;
	end	
	local nCount = 0;
	for nTask = self.TSKSTR_FANS_NAME[1], self.TSKSTR_FANS_NAME[2] - self.DEF_TASK_SAVE_FANS, self.DEF_TASK_SAVE_FANS do
		if me.GetTaskStr(self.TSK_GROUP, nTask) ~= "" then
			nCount = nCount + 1;
		else
			break;
		end
	end
	if nCount == 0 then
		Dialog:Say("您没使用过祝福卡，没有奖励领取。");
		return 0;	
	end
	if me.GetTask(self.TSK_GROUP, self.TSK_Award_StateEx2) > 0 then
		Dialog:Say("你已经领取过奖励了，不能太贪心哦。");
		return 0;
	end
	if me.GetBindMoney() + nCount * self.tbBaseMoney > me.GetMaxCarryMoney() then
		Dialog:Say("携带的银两达上限，请先清理下再来。");
		return 0;
	end
	me.AddBindCoin(self.tbBaseCoin2 * nCount);
	me.AddBindMoney(self.tbBaseMoney *nCount);
	me.Msg(string.format("恭喜您在寒武勇士大猜想活动中竞猜了%s个玩家，获得%s绑金和%s绑定银两。", nCount, self.tbBaseCoin2 * nCount, self.tbBaseMoney *nCount));
	me.SetTask(self.TSK_GROUP, self.TSK_Award_StateEx2, 1);
end

--竞猜奖励
function tbDtsVote:GetVoteAward()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	
	if nCurDate < self.TIME_AWARD_START then
		Dialog:Say("寒武勇士大猜想奖励还未开始领取");
		return 0;
	end
	if nCurDate > self.TIME_AWARD_END then
		Dialog:Say("寒武勇士大猜想奖励领取已经结束");
		return 0;
	end	
	
	if not self.tbAwardList[me.szName] then
		Dialog:Say("您没有奖励可以领取。");
		return 0;
	end

	if self.tbAwardList[me.szName][3] > 0 and me.CountFreeBagCell() < self.tbAwardList[me.szName][3] then
		Dialog:Say(string.format("Hành trang không đủ %s chỗ trống.", self.tbAwardList[me.szName][3]));
		return 0;
	end
	
	if me.GetTask(self.TSK_GROUP, self.TSK_Award_StateEx1) > 0 then
		Dialog:Say("Ngươi đã nhận phần thưởng, đừng quá tham lam.");
		return 0;
	end	
	me.AddBindCoin(self.tbAwardList[me.szName][2]);
	
	if self.tbAwardList[me.szName][3] > 0 then
		me.AddStackItem(self.ITEM_AWARD[1], self.ITEM_AWARD[2], self.ITEM_AWARD[3], self.ITEM_AWARD[4], nil, self.tbAwardList[me.szName][3]);
		me.Msg(string.format("恭喜您在寒武勇士大猜想活动中猜中%s个玩家获得前十，获得%s绑金奖励，同时获得原石箱子%s个。", self.tbAwardList[me.szName][1], self.tbAwardList[me.szName][2], self.tbAwardList[me.szName][3]));
	else
		me.Msg(string.format("恭喜您在寒武勇士大猜想活动中猜中%s个玩家获得前十，获得%s绑金奖励。", self.tbAwardList[me.szName][1], self.tbAwardList[me.szName][2]));
	end
	me.SetTask(self.TSK_GROUP, self.TSK_Award_StateEx1, 1);
	StatLog:WriteStatLog("stat_info", "mid_autumn2011", "get_award", me.nId, string.format("%s,%s",self.tbAwardList[me.szName][2], self.tbAwardList[me.szName][3]));
end
