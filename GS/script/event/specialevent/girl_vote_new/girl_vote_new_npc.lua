-- 文件名  : girl_vote_new_npc.lua
-- 创建者  : zounan
-- 创建时间: 2010-10-08 13:56:11
-- 描述    : 
do return end; -- 重开美女活动，注掉巾帼英雄赛脚本
Require("\\script\\event\\specialevent\\girl_vote_new\\girl_vote_new_def.lua");
local tbGirl = SpecialEvent.Girl_Vote_New;

local tbNpc = Npc:GetClass("girl_dingding");
tbNpc.tbSeries =
{
	[1] = "金系",
	[2] = "木系",
	[3] = "水系",
	[4] = "火系",
	[5] = "土系",				
};

tbNpc.tbRepairGateWayName = 
{
	["gate0718"] = 1,
	["gate1016"] = 1,
	["gate1110"] = 1,
	["gate1017"] = 1,
	["gate1111"] = 1,		
};

--	["逍遥游"] = gate0718,
--	["虞美人"] = gate1016,
--	["霸王别姬"] = gate1110,
--	["牡丹亭"] = gate1017,
--	["剑雨风云"] = gate1111,

function tbNpc:OnDialog()	
	local nState = tbGirl:GetState();
	local szMsg = "    长相思，晓月寒，晚风寒，情人佳节独往还，顾影自凄然。见亦难，思亦难，长夜漫漫抱恨眠，问伊怜不怜。来我这里买束玫瑰吧。";
	local tbOpt = {};
	if nState ~= tbGirl.emVOTE_STATE_NONE then
		table.insert(tbOpt,{"巾帼英雄评选",self.GirlVote,self});
	end
	
	--table.insert(tbOpt,{"巾帼英雄PK赛",self.GirlPK,self});
	table.insert(tbOpt,{"Để ta suy nghĩ thêm"});
	-- qingren 2011
	if SpecialEvent.Qingren_2011:CheckIsOpen() > 0 then
		table.insert(tbOpt, 1, {"<color=yellow>情人节活动<color>", SpecialEvent.Qingren_2011.OnNpcDialog, SpecialEvent.Qingren_2011});
	end
	-- end
	Dialog:Say(szMsg,tbOpt);
end

function tbNpc:GirlVote()	
	local nState = tbGirl:GetState();
	if nState == tbGirl.emVOTE_STATE_NONE then
		Dialog:Say(string.format("%s, xin chào!。", me.szName));
		return 0;
	end

	if nState == tbGirl.emVOTE_STATE_SIGN then
		local szMsg = [[<color=yellow>“巾帼英雄”<color>评选拉开帷幕，谁能最终挺进决赛，荣登第一宝座？最精彩的赛事，最浪漫的评选方式，《剑侠世界》巾帼英雄海选10月12日正式开始报名，所有女玩家都有参加机会，拉风光环、面具、称号以及玄晶等超级大奖在向你招手，快来参加吧！]];
		local tbOpt = {};
		table.insert(tbOpt,{"我是美女我要参加", self.SignUp, self});
		table.insert(tbOpt,{"我是来给美女投票的", self.VoteTickets, self});
		table.insert(tbOpt,{"查询前10名排行", self.QueryRank, self});
		table.insert(tbOpt,	{"查询自己的信息", self.QueryByName, self, me.szName});		
		table.insert(tbOpt,{"查询票数信息", self.QueryIntPutName, self});
		table.insert(tbOpt,{"Ta chỉ xem qua Xóa bỏ"});	
		Dialog:Say(szMsg, tbOpt);		
		return;
	end
	
	if nState == tbGirl.emVOTE_STATE_FREE then
		local szMsg = [[<color=yellow>“巾帼英雄”<color>评选已落下帷幕，在这里可以查看各位的排名]];
		local tbOpt = {
				{"查询前10名排行", self.QueryRank, self},
				{"查询票数信息", self.QueryIntPutName, self},
				{"查询自己的信息", self.QueryByName, self, me.szName},										
				{"Ta chỉ xem qua Xóa bỏ"},
			};	
		Dialog:Say(szMsg, tbOpt);		
		return;		
	end
	
	if nState == tbGirl.emVOTE_STATE_AWARD then
		local szMsg = [[<color=yellow>“巾帼英雄”<color>评选已落下帷幕，请各位巾帼英雄领取奖励吧。]];
		local tbOpt = {
				{"领取美女评选奖励", self.GetAward, self},
				{"查询前10名排行", self.QueryRank, self},
				{"查询票数信息", self.QueryIntPutName, self},			
				{"查询自己的信息", self.QueryByName, self, me.szName},			
				{"Ta chỉ xem qua Xóa bỏ"},
			};	
		Dialog:Say(szMsg, tbOpt);		
		return;
	end
end

function tbNpc:GirlPK()
	local tbOpt = {};
	table.insert(tbOpt,{"查看武林群芳谱",self.OpenRankLadder,self});
	if self:CheckGobalMatchAwardState() == 1 then
		table.insert(tbOpt,{"领取跨服巾帼英雄赛比赛奖励",self.GetGobalMatchAward,self});
		table.insert(tbOpt,{"领取跨服巾帼英雄赛活动奖励",self.GetGobalRestAward,self});	
		if self.tbRepairGateWayName[GetGatewayName()] == 1 then
			table.insert(tbOpt,{"<color=yellow>领取跨服巾帼英雄赛补偿奖励<color>",self.GetGobalAwardRepair,self});			
		end
	end
	table.insert(tbOpt,{"Để ta suy nghĩ thêm"});
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate == BeautyHero.GLOBAL_MATCHDATE then	
		local nCurTime = tonumber(GetLocalDate("%H%M"));
		if nCurTime < BeautyHero.TIME_BEGIN  then
			Dialog:Say("跨服巾帼英雄赛将于今晚19:30打响！你心目中的巾帼英雄是哪位？",tbOpt);
			return;				
		end

	 	if nCurTime >= BeautyHero.TIME_END then
			Dialog:Say("跨服巾帼英雄赛已经顺利结束！",tbOpt);
			return;				
		end 	
		table.insert(tbOpt,1,{"我要去",self.GoToGlobalMatch,self});
		Dialog:Say("跨服巾帼英雄赛进行中！要去比赛或者参观吗？比赛奖励和支持奖励将于21:30开始正式发放。",tbOpt);			
	 	return 	
	end
	
	local tbMissionBrief = BeautyHero:GetMissionBrief();
	if not tbMissionBrief then
		 Dialog:Say("目前暂时没有巾帼英雄赛",tbOpt);
		 return
	end	
	
	if tbMissionBrief.nServer == BeautyHero.emMATCHSERVER_LOCAL then
		if tbMissionBrief.nType == BeautyHero.emMATCHTYPE_SERIES then
			local nCount = 0;
			for i = 1, 5 do
				if tbMissionBrief.tbMissionFlag[i] then
					nCount = nCount + 1;
					table.insert(tbOpt,1,{string.format("我要去%s比赛场",self.tbSeries[i]),self.GoToLocalMatch,self,i});
				end
			end
			if nCount > 0 then
				Dialog:Say("你好，现在是巾帼英雄赛比赛时间。",tbOpt);
			else
				Dialog:Say("目前暂时没有巾帼英雄赛");
			end
		elseif tbMissionBrief.nType == BeautyHero.emMATCHTYPE_MELEE then
			if not tbMissionBrief.tbMissionFlag[1] then
				 Dialog:Say("目前暂时没有巾帼英雄赛",tbOpt);
				return
			end
			table.insert(tbOpt,1,{"我要去比赛场",self.GoToLocalMatch,self,1});
			Dialog:Say("你好，现在是巾帼英雄赛比赛时间。",tbOpt);			
		end
		return;
	end
	
	 Dialog:Say("目前暂时没有巾帼英雄赛",tbOpt);
	 return;	
end


function tbNpc:GoToLocalMatch(nSeries)
	local szMsg = "";
	local tbMissionBrief = BeautyHero:GetMissionBrief();

	if not tbMissionBrief or not tbMissionBrief.tbMissionFlag[nSeries] then
		 Dialog:Say("目前暂时没有巾帼英雄赛");
		 return
	end
	local tbMapInfo = {};
	if tbMissionBrief.nType == BeautyHero.emMATCHTYPE_SERIES then
		tbMapInfo = BeautyHero.MAP_SERIES;
	elseif tbMissionBrief.nType == BeautyHero.emMATCHTYPE_MELEE then
		tbMapInfo = BeautyHero.MAP_MELEE;
	end
	-- 检查条件
	if tbGirl:IsHaveGirl(me.szName) == 1 then
		BeautyHero:TrapIn(me,tbMapInfo[nSeries]);	
		return;
	end
	
	if tbGirl:GetTotalTickets(me) < BeautyHero.MEIGUI_LIMIT	then
		Dialog:Say(string.format("至少需要投了%d票或参加了美女英雄海选才能进入比赛场。",BeautyHero.MEIGUI_LIMIT));
		return;
	end
	
	BeautyHero:TrapIn(me,tbMapInfo[nSeries]);	
	return;	
	
end

--检查是否是pk榜前10玩家的前5粉丝
function tbNpc:CheckPKLadderFans(pPlayer)
	local nType = Ladder:GetType(0, Ladder.LADDER_CLASS_LADDER,Ladder.LADDER_TYPE_LADDER_ACTION, Ladder.LADDER_TYPE_LADDER_ACTION_BEAUTYHERO);
	local tbShowLadder	= GetTotalLadderPart(nType, 1, 10);	
	local tbBuf = tbGirl:GetGblBuf() or {};
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

function tbNpc:GoToGlobalMatch()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate ~= BeautyHero.GLOBAL_MATCHDATE then
		return;
	end
		
	local nCurTime = tonumber(GetLocalDate("%H%M"));
	if nCurTime < BeautyHero.TIME_BEGIN  or nCurTime >= BeautyHero.TIME_END then
		return;				
	end
	
	local nHonorRank = PlayerHonor:GetPlayerHonorRankByName(me.szName, PlayerHonor.HONOR_CLASS_BEAUTYHERO, 0);
	if nHonorRank <= BeautyHero.GLOBAL_RANKLIMIT and nHonorRank > 0 then
		me.SetTask(BeautyHero.TSK_GLOBAL_GROUP,BeautyHero.TSK_GLOBAL_MATCHTYPE,1);
		Transfer:NewWorld2GlobalMap(me);
		return;
	end
	

	if tbGirl:GetTotalTickets(me) >= BeautyHero.GLOBAL_MEIGUILIMIT then
		me.SetTask(BeautyHero.TSK_GLOBAL_GROUP,BeautyHero.TSK_GLOBAL_MATCHTYPE,2);
		Transfer:NewWorld2GlobalMap(me);
		return;
	end	
	
	if 	self:CheckPKLadderFans(me) == 1 then
		me.SetTask(BeautyHero.TSK_GLOBAL_GROUP,BeautyHero.TSK_GLOBAL_MATCHTYPE,2);
		Transfer:NewWorld2GlobalMap(me);
		return;
	end

	Dialog:Say(string.format("很不好意思~您投的金珠玉翠数量不足<color=yellow>%d<color>个,不可以进入跨服场地。",BeautyHero.GLOBAL_MEIGUILIMIT));
end


function tbNpc:VoteTickets()
	Dialog:AskString("请输入美女名", 16, SpecialEvent.Girl_Vote_New.VoteTickets, SpecialEvent.Girl_Vote_New);	
end


function tbNpc:QueryIntPutName()
	Dialog:AskString("请输入美女名", 16, self.QueryByName,  self);	
end

function tbNpc:QueryByName(szName)	
	local tbBuf = tbGirl:GetGblBuf();
	if not tbBuf[szName] then
		Dialog:Say("没有该美女信息");
		return 0;
	end
	
	local nTickets = tbBuf[szName].nTickets or 0;
	local szTickets = string.format("目前<color=yellow>%s<color>的票数为：<color=white>%s<color> ",szName, nTickets);

	local szMyTickets 	= "";
--	if szName ~= me.szName then
		local nUseTask, nNews = tbGirl:GetTaskGirlVoteId(szName);
		if nNews ~= 1 and nUseTask ~= 0 then
			local nMyTickets	= me.GetTask(tbGirl.TSK_GROUP, (nUseTask + (tbGirl.DEF_TASK_SAVE_FANS - 1)));
			szMyTickets = string.format("\n我的投票数：<color=white>%s<color>", nMyTickets);
			szTickets = szTickets..szMyTickets;
		end
--	end
	if nTickets > 0 then
		szTickets = szTickets.."\n\n粉丝                票数\n";	
		local szTmp = "";
		local tbFans = tbBuf[szName].tbFans or {};	
		for i = 1,  #tbFans do		
			szTmp = string.format("%s    <color=yellow>%s<color>\n",Lib:StrFillL(tbFans[i].szName, 16), tbFans[i].nTickets);
			szTickets = szTickets..szTmp;
		end
	end
	
	Dialog:Say(szTickets);
end


function tbNpc:QueryRank()
	if not tbGirl.tbRankBuffer or #tbGirl.tbRankBuffer == 0 then
		Dialog:Say("目前还没有排行榜。");
		return;
	end
	
	local szMsg = "  美女名称              票数\n";
	local tbBuf = tbGirl:GetGblBuf();	
	local nTickets = 0;
	local szTmp = "";
	local szFmt = "";
	for nIndex, tbInfo in ipairs(tbGirl.tbRankBuffer) do
		if tbBuf[tbInfo.szName] then
			nTickets = tbBuf[tbInfo.szName].nTickets;
		else 
			nTickets = tbInfo.nTickets;
		end
		szFmt = string.format("%d.%s",nIndex,tbInfo.szName);
		szTmp = string.format("%s    %d\n",Lib:StrFillL(szFmt, 20), nTickets);
		szMsg = szMsg..szTmp;
	end
	Dialog:Say(szMsg);	
end

function tbNpc:SignUp(nSure)
	local nState = tbGirl:GetState();	
	if nState ~= tbGirl.emVOTE_STATE_SIGN then
		Dialog:Say("现在不能报名。");
		return 0;
	end
	
	
	if me.nSex ~= 1 then
		Dialog:Say("只有女玩家才可以参加，如果您执意参加我可以送你一本最新版的葵花宝典。");
		return 0;
	end	
	
	if me.nFaction == 0 then
		Dialog:Say("请加入门派先。");
		return 0;
	end	
		
	if me.nLevel < tbGirl.LEVEL_LIMIT then
		Dialog:Say(string.format("请升到%d级以后再来吧。",tbGirl.LEVEL_LIMIT));
		return 0;
	end
	
	if tbGirl:IsHaveGirl(me.szName) == 1 then
		Dialog:Say("你已经报过名了啊，可不要来欺骗本姑娘。");
		return 0;
	end
	
	if not nSure then
		local szMsg = "您确定报名参加《剑侠世界》巾帼英雄海选比赛吗？";
		local tbOpt = {
			{"Xác nhận", self.SignUp, self, 1},
			{"Ta chỉ xem qua"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	GCExcute({"SpecialEvent.Girl_Vote_New:SignUpBuf",GetServerId(), me.szName,me.nId});
--	me.AddTitle(6,6,1,8);
--	me.SetCurTitle(6,6,1,8);
	me.SetTask(tbGirl.TSK_GROUP, tbGirl.TSK_Vote_Girl, GetTime());
	Dialog:Say("恭喜您已成功报名巾帼英雄评选，快去让粉丝把<color=yellow>金珠玉翠<color>都投给您吧。");
	local szMsg = [[报名参加了<color=yellow>“巾帼英雄评选”<color>活动，大家快去给她捧场啊！]]
	Player:SendMsgToKinOrTong(me, szMsg, 1);
	szMsg = string.format("<color=yellow>%s<color>", me.szName) ..szMsg;
	me.SendMsgToFriend(szMsg);
	KDialog.NewsMsg(0,Env.NEWSMSG_NORMAL, szMsg);		
	return 0;
end

function tbNpc:GetAward()
	local tbOpt = {
		{"领取比赛奖励", self.GetMatchAward, self},
		{"领取粉丝奖励", self.GetVoteAward, self},
		{"Ta chỉ đến xem thôi"},
	};
	Dialog:Say("想领取啥奖励呢？", tbOpt);
end

function tbNpc:GetVoteAward()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	
	if nCurDate < tbGirl.TIME_AWARD_START then
		Dialog:Say("巾帼英雄评选粉丝奖励还未开始领取");
		return 0;
	end
	if nCurDate > tbGirl.TIME_AWARD_END then
		Dialog:Say("巾帼英雄评选粉丝奖励领取已经结束");
		return 0;
	end	

	if me.GetTask(tbGirl.TSK_GROUP, tbGirl.TSK_Award_StateEx1) > 0 then
		Dialog:Say("你已经领取过奖励了，不能太贪心哦。");
		return 0;
	end	
	Dialog:AskString("哪位美女的粉丝", 16, self.GetVoteAwardEx, self);		
end

--领取粉丝奖励
function tbNpc:GetVoteAwardEx(szName)
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));	
	if nCurDate < tbGirl.TIME_AWARD_START then
		Dialog:Say("巾帼英雄评选粉丝奖励还未开始领取");
		return 0;
	end
	if nCurDate > tbGirl.TIME_AWARD_END then
		Dialog:Say("巾帼英雄评选粉丝奖励领取已经结束");
		return 0;
	end	

	if me.GetTask(tbGirl.TSK_GROUP, tbGirl.TSK_Award_StateEx1) > 0 then
		Dialog:Say("你已经领取过奖励了，不能太贪心哦。");
		return 0;
	end	

	
	local tbBuf = tbGirl:GetGblBuf();
	if not tbBuf[szName] then
		Dialog:Say(string.format("美女评选中找不到美女%s的资料，如果你是某个美女的第一粉丝，请输入你该美女名字领取第一粉丝称号奖励。", szName));
		return 0;
	end
	
	if not tbGirl.tbRankBuffer or #tbGirl.tbRankBuffer == 0 then
		Dialog:Say("美女评选中找不到该美女资料。");
		return 0;
	end
	
	local nRank = 0;
	for nIndex,tbInfo in ipairs(tbGirl.tbRankBuffer) do
		if tbInfo.szName == szName then
			nRank = nIndex;
			break;
		end
	end	
	if nRank ==0 or nRank > tbGirl.DEF_SORT_MAX_NUM then
		Dialog:Say(string.format("美女评选中美女%s并没有入选十大美女，您不能领取奖励。",szName));
		return;
	end
	
	

	local tbFans = tbBuf[szName].tbFans[1];	
	if not tbFans then
		Dialog:Say(string.format("你不是美女%s的第一粉丝哦。", szName));
		return 0;	
	end
	
	if tbFans.szName ~= me.szName then
		Dialog:Say(string.format("你不是美女%s的第一粉丝哦。", szName));
		return 0;	
	end		

--	if tbFans.szName ~= me.szName then
--		Dialog:Say(string.format("你不是美女%s的第一粉丝哦。", szName));
--		return 0;	
--	end	
	
	if me.CountFreeBagCell() < 2 then
		Dialog:Say(string.format("至少需要%d格背包空间，才能领奖哦。",2));
		return 0;
	end	
		
	me.SetTask(tbGirl.TSK_GROUP, tbGirl.TSK_Award_StateEx1, 1);
	me.AddTitle(unpack(tbGirl.TITLE_VOTER_FANS));
	me.SetCurTitle(unpack(tbGirl.TITLE_VOTER_FANS));
	local pItem = me.AddItem(18,1,114,10);
	me.Msg("恭喜您获得美女粉丝的奖励。");
	return 0;
end

--领取海选奖励
function tbNpc:GetMatchAward()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	
	if nCurDate < tbGirl.TIME_AWARD_START then
		Dialog:Say("巾帼英雄评选比赛奖励还未开始领取");
		return 0;
	end
	if nCurDate > tbGirl.TIME_AWARD_END then
		Dialog:Say("巾帼英雄评选比赛奖励领取已经结束");
		return 0;
	end

	if me.nSex ~= Env.SEX_FEMALE then
		Dialog:Say("你没有报名参加美女评选活动。");
		return 0;
	end
	
	local tbBuf = tbGirl:GetGblBuf();	
	if not tbBuf[me.szName] then
		Dialog:Say("你没有报名参加美女评选活动。");
		return 0;
	end
	
	if me.GetTask(tbGirl.TSK_GROUP, tbGirl.TSK_Award_State1) > 0 then
		Dialog:Say("你已经领取过奖励了，不能太贪心哦。");
		return 0;
	end

--	local nHonor		= PlayerHonor:GetPlayerHonorByName(me.szName, PlayerHonor.HONOR_CLASS_PRETTYGIRL, 0);
--	local nType 		= Ladder:GetType(0, Ladder.LADDER_CLASS_LADDER, Ladder.LADDER_TYPE_LADDER_ACTION, Ladder.LADDER_TYPE_LADDER_ACTION_PRETTYGIRL);
--	local tbLadderPart 	= GetTotalLadderPart(nType, 1, SpecialEvent.Girl_Vote.DEF_AWARD_ALL_RANK);

	if not tbGirl.tbRankBuffer or #tbGirl.tbRankBuffer == 0 then
		Dialog:Say("您没有奖励可以领取。");
		return 0;
	end
	
	local nRank = 0;
	for nIndex,tbInfo in ipairs(tbGirl.tbRankBuffer) do
		if tbInfo.szName == me.szName then
			nRank = nIndex;
			break;
		end
	end

	if nRank > 1 and nRank <= tbGirl.DEF_SORT_MAX_NUM  then		
		if me.CountFreeBagCell() < 3 then
			Dialog:Say(string.format("至少需要%d格背包空间，才能领奖哦。",3));
			return 0;
		end		
		me.SetTask(tbGirl.TSK_GROUP, tbGirl.TSK_Award_State1, 1);	
		me.AddTitle(unpack(tbGirl.TITLE_TOP_10));
		me.SetCurTitle(unpack(tbGirl.TITLE_TOP_10));
		local pItem = me.AddItem(unpack(tbGirl.ITEM_WAIZHUANG));
		if pItem then
			pItem.SetTimeOut(0, GetTime() + 3600 * 24 * 365);
			pItem.Sync();
		end		
		pItem = me.AddItem(unpack(tbGirl.ITEM_WAIZHUANG_2));
		if pItem then
			pItem.SetTimeOut(0, GetTime() + 3600 * 24 * 365);
			pItem.Sync();
		end		
		pItem = me.AddItem(18,1,114,11);
		me.Msg("恭喜您获得十大巾帼英雄的奖励。");
		Dbg:WriteLogEx(Dbg.LOG_INFO, "BeautyHeroVote", "比赛奖励前十",me.szName, tbBuf[me.szName].nTickets or 0);	
		return 0;
	end	
	
	if nRank == 1 then	
		if me.CountFreeBagCell() < 4 then
			Dialog:Say(string.format("至少需要%d格背包空间，才能领奖哦。",4));
			return 0;
		end		
		me.SetTask(tbGirl.TSK_GROUP, tbGirl.TSK_Award_State1, 1);	
		me.AddTitle(unpack(tbGirl.TITLE_TOP_1));
		me.SetCurTitle(unpack(tbGirl.TITLE_TOP_1));
		local pItem = me.AddItem(unpack(tbGirl.ITEM_WAIZHUANG));
		if pItem then
			pItem.SetTimeOut(0, GetTime() + 3600 * 24 * 365);
			pItem.Sync();
		end
		pItem = me.AddItem(unpack(tbGirl.ITEM_WAIZHUANG_2));
		if pItem then
			pItem.SetTimeOut(0, GetTime() + 3600 * 24 * 365);
			pItem.Sync();
		end		
		pItem = me.AddItem(18,1,114,12);
		pItem = me.AddItem(1,12,40,4);
		if pItem then
			pItem.SetTimeOut(0, GetTime() + 3600 * 24 * 365);
			pItem.Sync();
		end
		me.Msg("恭喜您获得第一巾帼英雄的奖励。");
		Dbg:WriteLogEx(Dbg.LOG_INFO, "BeautyHeroVote", "比赛奖励第一",me.szName, tbBuf[me.szName].nTickets or 0);	
		return 0;	
	end
	
	
	if tbBuf[me.szName].nTickets >= tbGirl.AWARD_VOTE_LIMIT then
		if me.CountFreeBagCell() < 3 then
			Dialog:Say(string.format("至少需要%d格背包空间，才能领奖哦。",3));
			return 0;
		end		
		me.SetTask(tbGirl.TSK_GROUP, tbGirl.TSK_Award_State1, 1);	
		me.AddTitle(unpack(tbGirl.TITLE_VOTER_VOTES));
		me.SetCurTitle(unpack(tbGirl.TITLE_VOTER_VOTES));
		local pItem = me.AddItem(1,13,111,1);
		if pItem then
			pItem.Bind(1);
		end
		for i = 1, 2 do
			pItem = me.AddItem(18,1,114,10); --两个10
		end
		me.Msg("恭喜您获得巾帼英雄评选的奖励。");
		Dbg:WriteLogEx(Dbg.LOG_INFO, "BeautyHeroVote", "比赛奖励够票数",me.szName, tbBuf[me.szName].nTickets);	
		return 0;	
	end
	Dialog:Say("很遗憾，按你的排名和票数，你没有任何奖励可以领取。排名前十或者得票数超过499均可以获得丰厚的奖励。");
	return 0;
end


--领取跨服巾帼英雄赛的奖励
function tbNpc:GetGobalMatchAward(nSure)
	nSure = nSure or 0;
	if self:CheckGobalMatchAwardState() == 0 then
		return;
	end
	
	if me.GetTask(BeautyHero.TSK_GLOBAL_GROUP,BeautyHero.TSK_IS_GETMATCH_AWARD) == 1 then
		Dialog:Say("您已经领过这份奖励了，不能重复领取。");
		return;
	end
	
	local nGlobalRankAward = GetPlayerSportTask(me.nId, BeautyHero.TSK_GB_PLAYER_GROUP, BeautyHero.TSK_GB_PLAYER_MATCH_AWARD) or 0;
	if nGlobalRankAward == 0 or (not BeautyHero.GLOBAL_MATCH_AWARD[nGlobalRankAward]) then
		Dialog:Say("对不起，这儿没有您的奖励记录。");
		return;
	end	
	
	if nSure == 0 then		
		Dialog:Say(string.format("恭喜您在这次跨服巾帼英雄PK赛中获得<color=yellow>%s<color>，领取奖励吗？",BeautyHero.AWARD_VOTER[nGlobalRankAward-1].szName), {{"我要领取",self.GetGobalMatchAward,self,1},{"Để ta suy nghĩ thêm"}});
	--	Dialog:Say(string.format("恭喜您在这次跨服巾帼英雄PK赛中获得<color=yellow>%s<color>，目前奖励正在紧锣密鼓的筹备中，11月9号服务器维护后再到我这儿来领吧，敬请期待！",BeautyHero.AWARD_VOTER[nGlobalRankAward-1].szName));
		return;
	end
	
	
	local tbAward = BeautyHero.GLOBAL_MATCH_AWARD[nGlobalRankAward];
	if me.CountFreeBagCell() < 3 then
		Dialog:Say(string.format("你的背包空间不够。请整理出%d格背包空间再领取奖励吧。",3));
		return 0;
	end
	Dbg:WriteLogEx(Dbg.LOG_INFO, "BeautyHeroGLOBALMATCHAWARDEX", me.szName,nGlobalRankAward);		
	me.SetTask(BeautyHero.TSK_GLOBAL_GROUP,BeautyHero.TSK_IS_GETMATCH_AWARD,1);	
	for _, tbDetail in ipairs(tbAward) do
		local bForceBind = tbDetail.nBind or 1;
		me.AddStackItem(tbDetail.tbItemId[1], tbDetail.tbItemId[2], tbDetail.tbItemId[3], tbDetail.tbItemId[4], {bForceBind=bForceBind}, tbDetail.nCount);
	end
	
	local tbTitle = BeautyHero.GLOBAL_MATCH_AWARD_TITLE[nGlobalRankAward];
	me.AddTitle(unpack(tbTitle));
	me.SetCurTitle(unpack(tbTitle));	
end


--领取跨服活动的奖励
function tbNpc:GetGobalRestAward(nSure)
	nSure = nSure or 0;
	if self:CheckGobalMatchAwardState() == 0 then
		return;
	end
	
	if me.GetTask(BeautyHero.TSK_GLOBAL_GROUP,BeautyHero.TSK_IS_GETREST_AWARD) == 1 then
		Dialog:Say("您已经领过这份奖励了，不能重复领取。");
		return;
	end
	
	local nCoin = GetPlayerSportTask(me.nId, BeautyHero.TSK_GB_PLAYER_GROUP, BeautyHero.TSK_GB_PLAYER_REST_AWARD) or 0;
	if nCoin == 0 then
		Dialog:Say("对不起，这儿没有您的奖励记录。");
		return;
	end
	if nSure == 0 then		
		Dialog:Say(string.format("恭喜您在这次跨服巾帼英雄PK赛参与活动获得<color=yellow>%d<color>绑金的奖励，确定领取吗？",nCoin), {{"我要领取",self.GetGobalRestAward,self,1},{"Để ta suy nghĩ thêm"}});
		return;
	end
	Dbg:WriteLogEx(Dbg.LOG_INFO, "BeautyHeroGLOBALMATCHAWARD", me.szName, nCoin);	

	me.SetTask(BeautyHero.TSK_GLOBAL_GROUP,BeautyHero.TSK_IS_GETREST_AWARD,1);
	me.AddBindCoin(nCoin);
end

--补偿
function tbNpc:GetGobalAwardRepair(nSure)
	nSure = nSure or 0;
	if self:CheckGobalMatchAwardState() == 0 then
		return;
	end
	
	if me.GetTask(BeautyHero.TSK_GLOBAL_GROUP,BeautyHero.TSK_IS_GETMATCH_AWARD) == 1 then
		Dialog:Say("您已经领过这份补偿了，不能重复领取。");
		return;
	end

	local nHonorRank = PlayerHonor:GetPlayerHonorRankByName(me.szName, PlayerHonor.HONOR_CLASS_BEAUTYHERO, 0);
	if nHonorRank > BeautyHero.GLOBAL_RANKLIMIT or nHonorRank <= 0 then
		Dialog:Say("对不起，您不符合补偿条件。武林群芳谱排名前十的玩家才能领取该补偿。");
		return;
	end	
	
	if nSure == 0 then		
		Dialog:Say(string.format("很遗憾，由于本服是新开服务器，没有跨服资格，现对武林群芳谱排名前十的玩家给出补偿, 确定领取吗？"), {{"我要领取",self.GetGobalAwardRepair,self,1},{"Để ta suy nghĩ thêm"}});
		return;
	end	

	
	me.SetTask(BeautyHero.TSK_GLOBAL_GROUP,BeautyHero.TSK_IS_GETMATCH_AWARD,1);	
	local tbTitle = BeautyHero.GLOBAL_MATCH_AWARD_TITLE[1];
	me.AddTitle(unpack(tbTitle));
	me.SetCurTitle(unpack(tbTitle));	
	me.AddBindCoin(80000); -- 8w绑金	
	Dbg:WriteLogEx(Dbg.LOG_INFO, "BeautyHeroRepair", me.szName);	
end


function tbNpc:CheckGobalMatchAwardState()
	local nDate = tonumber(GetLocalDate("%Y%m%d"));	
	if nDate < BeautyHero.TIME_GLOBAL_AWARD_BEGIN then
		return 0;
	end
	
	if nDate == BeautyHero.TIME_GLOBAL_AWARD_BEGIN then
		local nTime = tonumber(GetLocalDate("%H%M"));
		if nTime < BeautyHero.TIME_GLOBAL_AWARD_BEGIN_HOUR then
			return 0;
		end
		return 1;
	end
	
	
	if nDate > BeautyHero.TIME_GLOBAL_AWARD_END then
		return 0;
	end
	
	return 1;
end

function tbNpc:OpenRankLadder()
	me.CallClientScript({"UiManager:OpenWindow", "UI_LADDER",2,2});
end