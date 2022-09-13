--武林联赛
--孙多良
--2008.09.12

local tbNpc = {};
GbWlls.DialogNpc = tbNpc;

function tbNpc:OnDialog(nGameLevel, nFlag)
	if GbWlls:GetGblWllsOpenState() <= 0 or Wlls:GetMacthSession() <= 0 then
		Dialog:Say("武林联赛官员：武林联赛功能还未开启。");
		return 0;
	end

	if (GbWlls:CheckWllsQualition(me) == 0) then
		Dialog:Say("武林联赛官员：您已经报名参加了您所在的服务器的武林联赛，无法参加这里的武林联赛！");
		return 0;
	end

	if nGameLevel == Wlls.MACTH_ADV and Wlls:GetMacthSession() < Wlls.MACTH_ADV_START_MISSION then
		Dialog:Say("武林联赛官员：黄金武林联赛还未开启，请大侠到高级联赛官员处报名参加高级武林联赛。");
		
		return 0;
	end
	
	GbWlls:_RepairMatchLevel(me, nGameLevel);
	
	local nMacthType = Wlls:GetMacthType();
	local tbMacthCfg = Wlls:GetMacthTypeCfg(nMacthType);
	local szGameLevelName = Wlls.MACTH_LEVEL_NAME[nGameLevel];
	if (GLOBAL_AGENT and GbWlls:CheckOpenGoldenGbWlls() == 1) then
		szGameLevelName = GbWlls.MACTH_LEVEL_NAME[nGameLevel];
	end
	
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, me.szName);
	if (szLeagueName) then
		local nTeamLevel = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MLEVEL);
		if (nTeamLevel ~= nGameLevel) then
			local szTeamLevelName = Wlls.MACTH_LEVEL_NAME[nTeamLevel];
			if (GLOBAL_AGENT and GbWlls:CheckOpenGoldenGbWlls() == 1) then
				szTeamLevelName = GbWlls.MACTH_LEVEL_NAME[nTeamLevel];
			end
			Dialog:Say(string.format("您已经报名参加了%s武林联赛，请找%s武林联赛官员！", szTeamLevelName, szTeamLevelName));
			return 0;
		end
	end
	
	if (GbWlls:CheckOpenGoldenGbWlls() == 1) then
		Wlls.DEF_STATE_MSG[Wlls.DEF_STATE_ADVMATCH] = "黄金联赛八强赛期";
	end

	local szDesc = (tbMacthCfg and tbMacthCfg.szDesc) or "";
	local szMsg = string.format("%s武林联赛官员：亘古至今，武术之道，唯承上而继下也。%s\n\n<color=yellow>现在是武林联赛的%s<color>\n", szGameLevelName, szDesc, Wlls.DEF_STATE_MSG[Wlls:GetMacthState()]);
	local tbOpt = 
	{
		{string.format("前往%s武林联赛会场", szGameLevelName), Wlls.DialogNpc.EnterGame, Wlls.DialogNpc, nGameLevel},
		{string.format("我的联赛战队"), Wlls.DialogNpc.MyLeague, Wlls.DialogNpc, nGameLevel},
		{"查询上次跨服联赛排名", GbWlls.OnQueryRank, GbWlls},
		{"查询相关赛况", Wlls.DialogNpc.QueryMatch, Wlls.DialogNpc},
		{string.format("%s武林联赛的相关介绍", szGameLevelName), self.About, self, nGameLevel},
		{"我只是来看看的"},
	};

	if Wlls:GetMacthState() == Wlls.DEF_STATE_ADVMATCH then
		table.insert(tbOpt, 2, {"<color=yellow>观看八强赛战况<color>", Wlls.OnLookDialog, Wlls});	
	end
	
	Dialog:Say(szMsg, tbOpt);
end

tbNpc.tbAbout = 
{

	[1] = [[
	1）本届跨服联赛为<color=yellow>混合双人赛<color>，具体报名规则与联赛双人赛规则相同。你可以通过<color=yellow>临安府的跨服武林联赛官员<color>处报名参加跨服武林联赛。
	
	2）联赛类型为多人赛时，战队建立后，战队队长可以在英雄岛的黄金（高级）武林联赛官员处将其他符合条件的人加入自己的战队。
	
	3）比赛日，战队成员与洗髓岛的跨服武林联赛官员对话进入联赛会场，与会场官员对话，报名参加当日比赛。
	
	4）报名后，战队成员进入联赛准备场，待准备时间结束，则进入比赛场正式开始比赛。]],
	[2] = [[
    1）跨服武林联赛每个<color=yellow>赛季为1个月<color>，当月<color=yellow>7-28号<color>为比赛期，其中<color=yellow>7-27<color>号为循环赛时间，<color=yellow>28号<color>为黄金联赛决赛时间，高级联赛没有决赛。循环赛<color=yellow>前8名的队伍<color>有资格参加最后的决赛，联赛前8名排名以决赛名次为准，其他名次以循环赛为准。联赛全赛季（3个星期）共<color=yellow>150场比赛<color>，每个战队最多可参加<color=yellow>36场<color>比赛，决赛的场次不计算在48场之内。	
   
    2）具体比赛时间为
    周一-周五（每天6场）：<color=yellow>20：00、20：15、20：30、20：45、21：00、21：15<color>
    周六-周日（每天10场）：<color=yellow>15：00、15：15、15：30、15：45、16：00、16：15、19：00、19：15、19：30、19：45、20：00<color>
    28日（共5场）：<color=yellow>19：00、19：15、19：30、19：45<color>

    3）每场比赛准备时间为<color=yellow>4分半<color>，比赛时间为<color=yellow>10分钟<color>。

    4）最终决赛共有5场，19：00为8强进4强，19：15为4强进决赛，19：30、19：45、20：00为冠亚军决赛，双方需要打满3场，各队伍没有参加决赛的自动判负。
	]],
	[3] = [[
	1）第一届跨服武林联赛只有高级联赛。你需要加入战队才能参加联赛。
	
	2）高级武林联赛战队参赛条件：战队成员为100级以上，已加入门派，且必须为本服务器联赛荣誉排名前150名，或者财富荣誉排名前200名（根据联赛类型不同，所需条件也不同）。
	
	]],
	[4] = [[
	1）联赛类型为多人赛时，战队队长可以与其他人组队，在英雄岛的高级（黄金）武林联赛官员处，选择将队伍中的成员，加入本战队。
	
	2）在赛季期内，凡是没有参加过比赛的战队，其战队成员都可以在英雄岛的黄金（高级）武林联赛官员处选择退出战队。

	]],
	[5] = [[
	1）比赛中任意一方将对方两人全部击败时判胜。
	
	2）在比赛过程中如其中一队参赛选手同时不在比赛场内，则另一队直接获胜。
	
	3）在比赛时间结束后，双方仍未分出胜负，则判定剩余人数多的战队获胜；如果双方剩余人数相同，则以双方所有队员有效受伤总量来判断胜负,有效受伤总量小的一方获胜。有效受伤总量相同，则判平。
	
	4）参加比赛，轮空的战队直接判胜。轮空获胜比赛时间按5分钟计算。
	]],
	[6] = [[
	1）	常规比赛奖励：每场比赛打完，无论胜负平，参赛玩家都能获得经验、联赛声望和联赛荣誉点的奖励。
	
	2）	最终排名奖励：根据联赛的最终排名，参赛玩家能获得经验、联赛声望和联赛荣誉点奖励。同时排名前列的玩家可以领取特殊的联赛称号奖励。
	]],
}

function tbNpc:About()
	local tbOpt = 
	{
		{"参赛流程", self.AboutInfo, self, 1},
		{"赛程时间", self.AboutInfo, self, 2},
		{"参赛条件", self.AboutInfo, self, 3},
		{"战队的相关操作", self.AboutInfo, self, 4},
		{"如何判定胜负", self.AboutInfo, self, 5},
		{"联赛奖励", self.AboutInfo, self, 6},
		{"Kết thúc đối thoại"},
	}
	
	Dialog:Say("武林联赛官员：武林联赛为每三个月举行一届的竞技活动。你可以参加联赛，与众多武林高手一起争夺武林至高荣誉。想查询武林联赛相关信息吗?选择你想要查询的信息。", tbOpt);
end

function tbNpc:AboutInfo(nType)
	if not Wlls.SEASON_TB[Wlls:GetMacthSession()] then
		Dialog:Say("武林联赛官员：下届武林联赛还未确定类型，请留意官方公告。");
		return 0;
	end
	local nRank = Wlls.SEASON_TB[Wlls:GetMacthSession()][3];
	Dialog:Say(string.format(self.tbAbout[nType], nRank, nRank), {{"Quay lại", self.About, self},{"Kết thúc đối thoại"}});
end
