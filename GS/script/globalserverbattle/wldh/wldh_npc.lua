--武林大会
--孙多良
--2008.09.12

local tbNpc = {};
Wldh.DialogNpc = tbNpc;

function tbNpc:Query()
	local szMyInfo1 = "你已报名参加的比赛类型:\n";
	local szMyInfo2 = "";
	local nHave = 0;
	for i=1, 4 do
		local nLGType = Wldh:GetLGType(i);
		local szLeagueName = League:GetMemberLeague(nLGType, me.szName);
		if szLeagueName then
			nHave = 1;
			szMyInfo2 = szMyInfo2 .. string.format("<color=yellow>%s<color>\n", Wldh:GetName(i));
		end
	end
	if nHave == 0 then
		szMyInfo2 = "<color=gray>未报名任何比赛<color>\n";
	end
	
	local szMsg = szMyInfo1..szMyInfo2.."\n你想查询什么信息？";
	local tbOpt = {
		{"门派单人赛", self.QueryMatch, self, 1},
		{"双人赛", self.QueryMatch, self, 2},
		{"三人赛", self.QueryMatch, self, 3},
		{"五行五人赛", self.QueryMatch, self, 4},
		{"Kết thúc đối thoại"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:QueryMatch(nType)
	local nLGType = Wldh:GetLGType(nType);
	local szMsg = "你可以在我这儿查询初相关赛况。";
	local tbOpt = {
		{"查询其他人赛况", self.QueryOtherMatch, self, nType, 1},
		{"查询其他战队赛况", self.QueryOtherMatch, self, nType, 2},
		{"Quay lại", self.Query, self},
		{"Kết thúc đối thoại"},
	};
	local szLeagueName = League:GetMemberLeague(nLGType, me.szName);
	if szLeagueName then
		table.insert(tbOpt, 1 , {"查询本战队的战绩", self.QueryLeague, self, nType})
	end	
	Dialog:Say(szMsg, tbOpt);
end


function tbNpc:QueryOtherMatch(nGameType, nType, nFlag, szText)
	local nLGType = Wldh:GetLGType(nGameType);
	local szType = "战队名";
	if nType == 1 then
		szType = "角色名";
	end
	
	if not nFlag then
		Dialog:AskString(string.format("请输入%s：",szType), 16, self.QueryOtherMatch, self, nGameType, nType, 1);
		return
	end
	--名字合法性检查
	local nLen = GetNameShowLen(szText);
	if nLen < 4 or nLen > 16 then
		Dialog:Say(string.format("您的%s的字数达不到要求。", szType), {{"Quay lại", self.QueryMatch, self, nType}, {"Kết thúc đối thoại"}});
		return 0;
	end
	
	--是否允许的单词范围
	if KUnify.IsNameWordPass(szText) ~= 1 then
		Dialog:Say(string.format("您的%s含有非法字符。", szType), {{"Quay lại", self.QueryMatch, self, nType}, {"Kết thúc đối thoại"}});
		return 0;
	end
	
	--是否包含敏感字串
	if IsNamePass(szText) ~= 1 then
		Dialog:Say(string.format("您的%s含有非法的敏感字符。", szType), {{"Quay lại", self.QueryMatch, self, nType}, {"Kết thúc đối thoại"}});
		return 0;
	end
	
	if nType == 2 then
		if not League:FindLeague(nLGType, szText) then
			Dialog:Say("您查询的武林大会战队不存在。", {{"Quay lại", self.QueryMatch, self, nType}, {"Kết thúc đối thoại"}});
			return 0;
		end
		--显示战队情况
		self:QueryLeague(nGameType, szText);
	end
	if nType == 1 then
		local szLeagueName = League:GetMemberLeague(nLGType, szText);
		if not szLeagueName then
			Dialog:Say("您查找的玩家不在武林大会战队中.", {{"Quay lại", self.QueryMatch, self, nType}, {"Kết thúc đối thoại"}});
			return 0;
		end
		self:QueryLeague(nGameType, szLeagueName);
	end
end

function tbNpc:QueryLeague(nType, szFindName)
	local nLGType = Wldh:GetLGType(nType);
	local szLeagueName = szFindName;
	if not szLeagueName then
		szLeagueName = League:GetMemberLeague(nLGType, me.szName);
		if not szLeagueName then
			Dialog:Say("官员：您还没有战队！", {{"Quay lại", self.QueryMatch, self, nType}, {"Kết thúc đối thoại"}});
			return 0;
		end
	end
	local tbLeagueList = Wldh:GetLeagueMemberList(nLGType, szLeagueName);
	local szMemberMsg = self:GetLeagueInfoMsg(nLGType, szLeagueName);
	local nRank = League:GetLeagueTask(nLGType, szLeagueName, Wldh.LGTASK_RANK);
	local nWin = League:GetLeagueTask(nLGType, szLeagueName, Wldh.LGTASK_WIN);
	local nTie = League:GetLeagueTask(nLGType, szLeagueName, Wldh.LGTASK_TIE);
	local nTotal = League:GetLeagueTask(nLGType, szLeagueName, Wldh.LGTASK_TOTAL);
	local nTime = League:GetLeagueTask(nLGType, szLeagueName, Wldh.LGTASK_TIME);
	local nRankAdv = League:GetLeagueTask(nLGType, szLeagueName, Wldh.LGTASK_RANK_ADV);
	local nLoss = nTotal-nWin-nTie;
	local szMacthName = Wldh:GetName(nType);
	local nPoint = nWin * Wldh.MACTH_POINT_WIN + nTie * Wldh.MACTH_POINT_TIE + nLoss * Wldh.MACTH_POINT_LOSS;
	local szRate = 100.00;
	if nTotal > 0 then
		szRate = string.format("%.2f", (nWin/nTotal)*100) .. "％";
	else
		szRate = "Vô";
	end
	local szRank = "";
	if nRank > 0 then
		szRank = string.format("\n战队排名：<color=white>%s<color>", nRank);
	end
	local tbAdvMsg = {
		[0] = "无决赛资格",
		[1]	= "冠军",
		[2]	= "进入决赛",
		[4] = "进入四强赛",
		[8] = "进入八强赛",
		[16] = "进入十六强赛",
		[32] = "进入三十二强赛",
	};
	szRank = szRank .. string.format("\n\n战队八强赛情况：<color=white>%s<color>", tbAdvMsg[nRankAdv]);
	
	szMemberMsg = string.format([[%s<color=green>
--战队战绩--
赛制类型：<color=white>%s<color> 
总 场 数：<color=white>%s<color> 
胜    率：<color=white>%s<color>
总 积 分：<color=white>%s<color>
胜：<color=white>%s<color>  平：<color=white>%s<color>  负：<color=white>%s <color>
累计比赛时间：<color=white>%s<color>
%s
]],szMemberMsg, szMacthName, nTotal, szRate, nPoint, nWin, nTie, nLoss, Lib:TimeFullDesc(nTime), szRank);
		Dialog:Say(szMemberMsg, {{"Quay lại", self.QueryMatch, self, nType}, {"Kết thúc đối thoại"}});
end

function tbNpc:GetLeagueInfoMsg(nLGType, szLeagueName)
	local tbLeagueList = Wldh:GetLeagueMemberList(nLGType, szLeagueName);
	local szMemberMsg = string.format("官员：\n所在战队：<color=yellow>%s<color>\n", szLeagueName);
	for nId, szMemberName in ipairs(tbLeagueList) do
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
	return 	szMemberMsg;
end


function tbNpc:Attend(nType)
	local nLGType = Wldh:GetLGType(nType);
	local szLeagueName = League:GetMemberLeague(nLGType, me.szName);
	if not szLeagueName then
		Dialog:Say("你还没报名参加本类型比赛,请先报名建立战队。");
		return 0;
	end
	me.SetLogoutRV(1);
	Wldh:KickPlayer(me, "你进入了大会会场，报名开始后，你与队友可以在<color=yellow>会场官员<color>处报名参加比赛。", nType);
	Dialog:SendBlackBoardMsg(me, "欢迎进入大会会场，请到会场官员处报名参赛。");	
end

function tbNpc:ChoseType()
	if me.GetCamp() == 6 then
		Dialog:Say("记者记得要用GM卡哦！！！！！！不能建立战队！！！")
		return;
	end
	local szMsg = "每个玩家都可以选择参加门派单人赛，但双人赛，三人赛和五行五人赛每个玩家三种只能选择其中一种参加，而且必须找够确定人数的符合资格的队友一起来才能建立战队，战队建立后将不能取消或解散，请谨慎选择。";
	local tbOpt = {
		{"【固定】门派单人赛", self.CreateLeague, self, 1},
		{"【三选一】双人赛", self.CreateLeague, self, 2},
		{"【三选一】三人赛", self.CreateLeague, self, 3},
		{"【三选一】五行五人赛", self.CreateLeague, self, 4},
		{"单人赛更换门派", self.ChangeLeague, self, 1},
		{"Để ta suy nghĩ lại"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:ChangeLeague(nType)	
	if (me.nFaction <= 0) then
		Dialog:Say("你未加入门派。");
		return 0;
	end			
	local nLGType = Wldh:GetLGType(nType);
	local szGameName = Wldh:GetName(nType);
	local szLeagueName = League:GetMemberLeague(nLGType, me.szName);
	if not szLeagueName then
		Dialog:Say("你还没有建立战队，无需更换门派。");
		return 0;
	end	
	if League:GetLeagueTask(nLGType, szLeagueName, Wldh.LGTASK_TOTAL) > 0 then
		Dialog:Say("你已经参加过比赛，无法再更换门派了。");
		return 0;
	end	
	if me.nFaction == League:GetMemberTask(nLGType, szLeagueName, me.szName, Wldh.LGMTASK_FACTION) then
		Dialog:Say("你目前的门派与报名参赛时一致，无需更换。");
		return 0;
	end	
	League:SetMemberTask(nLGType, szLeagueName, me.szName, Wldh.LGMTASK_FACTION, me.nFaction);
	me.Msg("你已经成功更换单人赛参赛门派。");
end

function tbNpc:CreateLeague(nType, nSure, szCreateLeagueName)
	local nLGType = Wldh:GetLGType(nType);
	local szGameName = Wldh:GetName(nType);
	local szLeagueName = League:GetMemberLeague(nLGType, me.szName);
	if szLeagueName then
		Dialog:Say("你已经报名参加了本类型战队，已建立过战队了。");
		return 0;
	end
	if nType == 1 then
		szCreateLeagueName = me.szName;
	end
	if nType > 1 then
		local nChose = GetPlayerSportTask(me.nId, Wldh.GBTASKID_GROUP, Wldh.GBTASKID_CHOSE_TYPE) or 0;
		if nChose > 0 then
			Dialog:Say(string.format("三种类型的比赛，每个玩家只能选择其中一种类型，你已经选择了%s赛，不能再选择其他比赛。", Wldh:GetName(nChose)));
			return 0;
		end
		if me.nTeamId <= 0 then
			Dialog:Say("官员：必须组队才能建立战队！");
			return 0;
		end
		if me.IsCaptain() == 0 then
			Dialog:Say("官员：必须是队长才能建立战队！");
			return 0;
		end
		if not nSure then
			local szMsg = string.format("三种类型的比赛，每个玩家只能选择其中一种类型，你确定要参加%s比赛吗？", szGameName);
			local tbOpt = {
				{"Xác nhận", self.CreateLeague, self, nType, 1},
				{"Để ta suy nghĩ lại"},
			};
			Dialog:Say(szMsg, tbOpt);
			return 0;
		end
	end
	
	local tbTeamMemberList = {};
	if me.nTeamId > 0 then
		tbTeamMemberList = KTeam.GetTeamMemberList(me.nTeamId);
	else
		tbTeamMemberList = {me.nId};
	end
	
	local nFlag, szMsg = Wldh:CheckCreateLeague(me, tbTeamMemberList, nType);
	if nFlag == 1 then
		Dialog:Say(szMsg);
		return 0;
	end
	
	if not szCreateLeagueName then
		Dialog:AskString("请输入战队名：", 12, self.CreateLeague, self, nType, 1);
		return 0;
	end
	
	if nType > 1 then
		--名字合法性检查
		local nLen = GetNameShowLen(szCreateLeagueName);
		if nLen < 6 or nLen > 16 then
			Dialog:Say("您的战队名字的字数达不到要求,必须要3到8个汉字之间。");
			return 0;
		end
		
		--是否允许的单词范围
		if KUnify.IsNameWordPass(szCreateLeagueName) ~= 1 then
			Dialog:Say("您的战队名字含有非法字符。");
			return 0;
		end
		
		--是否包含敏感字串
		if IsNamePass(szCreateLeagueName) ~= 1 then
			Dialog:Say("您的战队名字含有非法的敏感字符。");
			return 0;
		end
	
		if League:FindLeague(nLGType, szCreateLeagueName) then
			Dialog:Say("您取的战队名已存在，请重新建立战队");
			return 0;
		end
	end
	
	local nMapLinkType = Wldh:GetMapLinkType(nType);
	if (nMapLinkType == Wldh.MAP_LINK_TYPE_FACTION) then
		if (nSure ~= 2) then
			local nFaction = 0;
			local szMsg = "";
			local tbOpt	= {};
			if (me.nFaction <= 0) then
				Dialog:Say("你未加入门派。");
				return 0;
			end
			local szFaction = Player:GetFactionRouteName(me.nFaction);
			szMsg	= string.format("您确定要以%s门派参加%s门派单人赛吗？", szFaction, szFaction);
			tbOpt	= {
					{"Xác nhận", self.CreateLeague, self, nType, 2, szCreateLeagueName},
					{"Để ta suy nghĩ thêm"},
				}; 
			Dialog:Say(szMsg, tbOpt);
			return 0;
		end
	end
	
	-- 五行相克赛
	if (Wldh:GetCfg(nType).nSeries == Wldh.LEAGUE_TYPE_SERIES_MIX) then
		if (nSure == 1) then
			local nSeries	= -1;
			local nNoFlag	= 0;
			local szSeriesMsg = "";
			for _, nPlayerId in ipairs(tbTeamMemberList) do
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				szSeriesMsg = string.format("%s%s %s系，", szSeriesMsg, pPlayer.szName, string.format(Wldh.SERIES_COLOR[pPlayer.nSeries], Env.SERIES_NAME[pPlayer.nSeries]));
			end
			szSeriesMsg = string.format("当前报名五行为：%s确定以当前五行参赛吗？", szSeriesMsg);
			local tbOpt	= {
					{"Xác nhận", self.CreateLeague, self, nType, 2, szCreateLeagueName},
					{"Để ta suy nghĩ thêm"},
				}; 
			Dialog:Say(szSeriesMsg, tbOpt);
			return 0;
		end
	end
	
	local tbMemberList = {};
	for _, nPlayerId in ipairs(tbTeamMemberList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			if nType > 1 then
				SetPlayerSportTask(pPlayer.nId, Wldh.GBTASKID_GROUP, Wldh.GBTASKID_CHOSE_TYPE, nType);
			end
			table.insert(tbMemberList, {
				nId=nPlayerId,
				szName=pPlayer.szName,
				nFaction=pPlayer.nFaction, 
				nRouteId=pPlayer.nRouteId, 
				nSex=pPlayer.nSex, 
				nCamp=pPlayer.GetCamp(), 
				nSeries=pPlayer.nSeries,
				});
		end
		pPlayer.Msg(string.format("您成为了<color=yellow>%s<color>武林大会%s战队的一员，请在比赛期内，进入武林大会会场，在<color=yellow>会场官员处报名参加比赛<color>。", szCreateLeagueName, szGameName));
		Dialog:SendBlackBoardMsg(pPlayer, string.format("您成功成为了%s战队的成员", szCreateLeagueName));
	end
	me.Msg(szMsg);
	Dialog:Say(szMsg);
	GCExcute{"Wldh:CreateLeague", tbMemberList, szCreateLeagueName, nType};
end
