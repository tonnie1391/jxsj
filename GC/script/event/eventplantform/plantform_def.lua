

EPlatForm.GTASK_MACTH_SESSION 		= DBTASD_EVENT_SESSION;		--比赛届数
EPlatForm.GTASK_MACTH_LASTSESSION	= DBTASD_EVENT_LASTSESSION; --上届比赛届数，记录排名使用，防止出现排序进行中时换届
EPlatForm.GTASK_MACTH_STATE 	 	= DBTASD_EVENT_STATE;		--比赛阶段(0,未开启, 1间歇期,2.比赛期第一阶段,3.比赛期第二阶段 4.八强赛期)
EPlatForm.GTASK_MACTH_MAP_STATE		= DBTASD_EVENT_MAP_STATE;	--准备场满人状态（0，未满，1已满）
EPlatForm.GTASK_MACTH_RANK			= DBTASD_EVENT_RANK;		--是否已排名完成标志
EPlatForm.GTASK_MACTH_MAX_SCORE_FOR_NEXT	= DBTASD_EVENT_MAX_SCORE_FOR_NEXT;

EPlatForm.DEF_STATE_CLOSE			= 0;		--未开启
EPlatForm.DEF_STATE_REST			= 1;		--间歇期
EPlatForm.DEF_STATE_MATCH_1			= 2;		--比赛期第一阶段
EPlatForm.DEF_STATE_MATCH_2			= 3;		--比赛期第二阶段
EPlatForm.DEF_STATE_ADVMATCH		= 4;		--八强赛期

EPlatForm.DEF_MATCHTYPE_ESPORT		= 1;	-- 雪仗
EPlatForm.DEF_MATCHTYPE_DRAGONBOAT	= 2;	-- 龙舟
EPlatForm.DEF_MATCHTYPE_TOWER		= 3;	-- 蘑菇
EPlatForm.DEF_MATCHTYPE_CASTLEFIGHT	= 4;	-- 夜岚关

EPlatForm.DEF_STATE_MSG = {
	[EPlatForm.DEF_STATE_CLOSE]			= "未开启状态",
	[EPlatForm.DEF_STATE_REST]			= "间歇期",
	[EPlatForm.DEF_STATE_MATCH_1]		= "家族选拔赛",
	[EPlatForm.DEF_STATE_MATCH_2]		= "家族预选赛",	
	[EPlatForm.DEF_STATE_ADVMATCH]		= "家族决赛",
};


-- 第一阶段用不到战队，到第二阶段之后用到
EPlatForm.LGTYPE	= 7;	--活动平台战队系统类型

--LG Task ID--
EPlatForm.LGTASK_MSESSION	= 1;		--届数
EPlatForm.LGTASK_MTYPE		= 2;		--比赛赛制
EPlatForm.LGTASK_MEXPARAM	= 3;		--赛制额外参数(如门派,性别等)
EPlatForm.LGTASK_MLEVEL		= 4;		--比赛等级（1低级, 2高级）
EPlatForm.LGTASK_RANK		= 5;		--战队获得名次（比赛结束后排序获得）
EPlatForm.LGTASK_WIN		= 6;		--胜利次数
EPlatForm.LGTASK_TIE		= 7;		--平局次数
EPlatForm.LGTASK_TOTAL		= 8;		--参赛次数（失败次数 = TOTAL - WIN - TIE）
EPlatForm.LGTASK_TIME		= 9;		--战斗时间总计
EPlatForm.LGTASK_EMY1		= 10;		--最后的一场比赛遇到的对手（战队名String2ID）
EPlatForm.LGTASK_EMY2		= 11;		--倒数第二场比赛遇到的对手
EPlatForm.LGTASK_EMY3		= 12;		--倒数第三场比赛遇到的对手
EPlatForm.LGTASK_ATTEND		= 13;		--未参赛0和进入准备场Id(进入准备场为已参赛)
EPlatForm.LGTASK_ENTER		= 14;		--进入准备场队员总数.
EPlatForm.LGTASK_EMY4		= 15;		--倒数第四场比赛遇到的对手
EPlatForm.LGTASK_EMY5		= 16;		--倒数第五场比赛遇到的对手
EPlatForm.LGTASK_RANK_ADV	= 17;		--八强赛排名；
EPlatForm.LGTASK_DYNID		= 18;		--进入某个准备场后的某个比赛场
EPlatForm.LGTASK_DALIYCOUNT	= 19;		--参加活动的个数
EPlatForm.LGTASK_DALIYCHANGETIME	= 20;		--参加活动的个数

--LG MemberTask ID--
EPlatForm.LGMTASK_JOB		= 1;	--职位:0、队员；1、队长
EPlatForm.LGMTASK_AWARD		= 2;	--奖励补领:0、无补领奖励；1、胜利奖励,上线自动领取. 2.平奖励, 3负奖励
EPlatForm.LGMTASK_FACTION	= 3;	--门派
EPlatForm.LGMTASK_ROUTEID	= 4;	--路线
EPlatForm.LGMTASK_CAMP		= 5;	--阵营
EPlatForm.LGMTASK_SEX		= 6;	--性别
EPlatForm.LGMTASK_SERIES	= 7;	--五行


--Task ID--
EPlatForm.TASKID_GROUP			= 2103;		--任务变量组
EPlatForm.TASKID_MATCH_TOTLE	= 1;		--总场次
EPlatForm.TASKID_MATCH_WIN		= 2;		--胜场数
EPlatForm.TASKID_MATCH_TIE		= 3;		--平场数
EPlatForm.TASKID_MATCH_FIRST	= 4;		--冠军数量
EPlatForm.TASKID_MATCH_SECOND	= 5;		--银军数量
EPlatForm.TASKID_MATCH_THIRD	= 6;		--亚军数量
EPlatForm.TASKID_MATCH_BEST		= 7;		--最好名次
EPlatForm.TASKID_MATCH_FINISH	= 8;		--是否领取过奖励了
EPlatForm.TASKID_HELP_SESSION	= 9;		--帮助锦囊，战队活动平台届数
EPlatForm.TASKID_HELP_TOTLE		= 10;		--帮助锦囊，战队总场数
EPlatForm.TASKID_HELP_WIN		= 11;		--帮助锦囊，战队赢场数
EPlatForm.TASKID_HELP_TIE		= 12;		--帮助锦囊，战队负场数
EPlatForm.TASKID_MATCH_WIN_AWARD = 13;		--单场胜利领取奖励标志
EPlatForm.TASKID_AWARD_LOG		= 14;		--最终领取奖励log，（届数(3位) + 奖励段（3位） * 1000 + 初级高级类型（1位） * 1000000）
EPlatForm.TASKID_ENTER_READY	= 15;
EPlatForm.TASKID_ENTER_DYN		= 16;
EPlatForm.TASKID_DALIYEVENTCOUNT= 17;
EPlatForm.TASKID_COUNTCHANGETIME= 18;
EPlatForm.TASKID_SESSIONFLAG	= 19;		-- 记录玩家参加的比赛和记录的比赛第几阶段
EPlatForm.TASKID_ATTEND_AWARD	= 20;
EPlatForm.TASKID_AWARDFLAG		= 21;		-- 玩家奖励
EPlatForm.TASKID_KINAWARDFLAG	= 22;		-- 玩家家族奖励
EPlatForm.TASKID_KINAWARDEXFLAG	= 24;		-- 玩家家族奖励补偿标记
EPlatForm.TASKID_MATCH_TOTLE_MATCH1	= 25;		-- 玩家第一阶段已参加场次次数
EPlatForm.TASKID_PLAYER_LOGINRV	= 26;		-- 玩家上线清技能
EPlatForm.TASKID_PLAYER_SESSION	= 27;		-- 参加届数（成就使用）

--玩家上线清技能时限
EPlatForm.PLAYER_LOGINRV_DATE	= 20100211;		-- 玩家上线清技能时限


--参赛选手参数
EPlatForm.PLAYER_ATTEND_LEVEL 		= 100;		--最低等级需求;
EPlatForm.MAP_SELECT_MIN			= 8;		--每张准备场最少先进入多少队。
EPlatForm.MAP_SELECT_SUBAREA		= 8;		--匹配原则,按胜率多少队为一个区间
EPlatForm.MAP_SELECT_MAX			= 100;		--每张比赛地图最多有几个比赛擂台。
EPlatForm.MACTH_LEAGUE_MIN			= 4;		--准备场中最少要有多少队才能开启。
EPlatForm.MACTH_ATTEND_MAX			= 48;		--每个战队最多参加多少场
EPlatForm.MACTH_POINT_WIN 			= 3;		--胜利获得积分
EPlatForm.MACTH_POINT_TIE 			= 2;		--平获得积分
EPlatForm.MACTH_POINT_LOSS 			= 1;		--输掉比赛获得积分
EPlatForm.MACTH_TIME_BYE  			= 300;		--轮空计算的比赛时间的秒数
EPlatForm.MACTH_NEW_WINRATE  		= 50;		--一场没打队伍按50％胜率计算
EPlatForm.nCurReadyMaxCount			= 24;		-- 本阶段准备场最大队伍数
EPlatForm.nCurMatchMaxTeamCount		= 8;		-- 本阶段比赛最大参赛队伍数
EPlatForm.nCurMatchMinTeamCount		= 8;		-- 本阶段比赛最少开启比赛人数
EPlatForm.MACTH_MAX_JOINCOUNT		= 14;
EPlatForm.MIN_TEAM_EVENT_NUM		= 3;		-- 参加比赛的队伍成员最少人数
EPlatForm.MAX_KINRANK_NEXTMATCH		= 120;		-- 参加下一阶段比赛的家族的最大排名
EPlatForm.DEF_MIN_KINSCORE			= 0;		-- 最小能参加第二阶段的家族积分
EPlatForm.DEF_MIN_KINSCORE_PLAYER	= 24;		-- 最小能参加第二阶段的个人积分
EPlatForm.DEF_MIN_KINAWARD_SCORE	= 24;
EPlatForm.DEF_MAX_KINAWARDCOUNT		= 40;
EPlatForm.DEF_DEADLINE_CHECKDAY		= 1;		-- 队伍自动验证日期,第一阶段比赛后过一天
EPlatForm.DEF_MAX_TOTALCOUNT		= 28;		-- 一个玩家在第一阶段最大参加场数

EPlatForm.DEF_MAX_REMAINCOUNT		= 4;		-- 一个玩家在第一阶段最大参加场数

EPlatForm.MATCH_WELEE				= 1;
EPlatForm.MATCH_TEAMMATCH			= 2;
EPlatForm.MATCH_KINAWARD			= 3;

--八强赛场次对应表
EPlatForm.MACTH_STATE_ADV_TASK = 
{
	[1] = 8,
	[2] = 4,
	[3] = 2,
	[4] = 2,
	[5] = 2,
};

-- 分队规则
EPlatForm.MATCH_TEAM_PART = {
	[1] = 1,
	[2] = 2,
	[3] = 2,	
	[4] = 1,
	[5] = 1,
	[6] = 2,	
	[7] = 2,
	[8] = 1,
	[9] = 1,	
	[10] = 2,
};

--比赛场参数
EPlatForm.MACTH_TIME_READY 			= Env.GAME_FPS * 280;		--准备场准备时间;
EPlatForm.MACTH_TIME_READY_LASTENTER = Env.GAME_FPS * 5;			--倒数5秒不允许进场;
EPlatForm.MACTH_TIME_PK_DAMAGE 		= Env.GAME_FPS * 5;			--同步伤血量时间;
EPlatForm.MACTH_TIME_UPDATA_RANK 	= Env.GAME_FPS * 610;		--准备时间结束进入比赛后多少时间更新排行;
EPlatForm.DEF_READY_TIME_ENTER		= Env.GAME_FPS * 10

EPlatForm.MACTH_TIME_ADVMATCH 		= Env.GAME_FPS * 900;		--八强赛每场相隔时间;
EPlatForm.MACTH_TIME_ADVMATCH_MAX 	= 5;						--八强赛总场数，5场;

EPlatForm.MACTH_TIME_RANK_FINISH 	= Env.GAME_FPS * 60;		--预计最终排名所需要处理时间，玩家才能领取奖励

EPlatForm.MIS_LIST 	= 
{	
	{"PkToPkStart", 	Env.GAME_FPS * 15, 	"OnGamePk"	},	--Pk准备时间 15秒
	{"PkStartToEnd", 	Env.GAME_FPS * 585, "OnGameOver"},	--比赛时间 585秒
};
EPlatForm.MIS_UI 	= 
{
	[1] = {"<color=gold>%s Vs %s\n\n", "<color=green>比赛开始剩余时间：<color=white>%s<color>\n\n", "<color=green>对方受伤总量：<color=red>%s\n<color=green>本方受伤总量：<color=blue>%s"};
	[2] = {"<color=gold>%s Vs %s\n\n", "<color=green>剩余时间：<color=white>%s<color>\n\n", "<color=green>对方受伤总量：<color=red>%s\n<color=green>本方受伤总量：<color=blue>%s"};
}
EPlatForm.MIS_UI_LOOKER = "<color=green>%s队伤血量：<color=red>\n    %s\n\n<color=green>%s队伤血量：\n    <color=blue>%s";

EPlatForm.MACTH_TRAP_ENTER ={{50464/32, 103712/32}, {53600/32, 106912/32}, {48000/32, 105024/32}, {51872/32, 109696/32}};	--进入准备场坐标
EPlatForm.MACTH_TRAP_LEAVE ={{1392,3091},};	--进入会场坐标
EPlatForm.MACTH_TRAP_LEAVE_MAPID = 1;
EPlatForm.SNOWFIGHT_ITEM_SINGLEWIN	= 	{18,1,282,1}


--内存记录表
EPlatForm.MissionList 	= EPlatForm.MissionList   or {};		--mission
EPlatForm.GroupList 		= EPlatForm.GroupList 	 or {};		--战队临时名单;
EPlatForm.GroupListTemp 	= EPlatForm.GroupListTemp or {};		--战队临时名单2;
EPlatForm.ReadyTimerId 	= EPlatForm.ReadyTimerId  or 0;			--准备场计时器Id;
EPlatForm.GameState 		= EPlatForm.GameState	 or 0;			--单场比赛阶段,0未开始,1准备阶段,2pk阶段
EPlatForm.PosGamePk 		= EPlatForm.PosGamePk 	 or {};			--pk场传入点坐标
EPlatForm.PosGameReady 		= EPlatForm.PosGameReady 	 or {};			--pk场传入点坐标
EPlatForm.AdvMatchState	= EPlatForm.AdvMatchState or 0;			--八强赛阶段，（1：8进4；2：4进2，3：决赛场1；4：决赛场2；5：决赛场3；）
EPlatForm.AdvMatchLists	= EPlatForm.AdvMatchLists or {};			--八强赛名单，
EPlatForm.WaitMapMemList = EPlatForm.WaitMapMemList or {};		--会场玩家名单

EPlatForm.SEASON_TB 			= EPlatForm.SEASON_TB 			or {};		--联赛表
EPlatForm.DATE_TO_SESSION 		= EPlatForm.DATE_TO_SESSION 	or {};		--年月对应的家族竞技表
EPlatForm.AWARD_LEVEL 		= EPlatForm.AWARD_LEVEL 			or {};		--奖励分层
EPlatForm.MACTH_ENTER_FLAG 	= EPlatForm.MACTH_ENTER_FLAG 	or {};		--玩家进入比赛场标志
EPlatForm.AWARD_FINISH_LIST  = EPlatForm.AWARD_FINISH_LIST 	or {};		--最终奖励表
EPlatForm.AWARD_SINGLE_LIST  = EPlatForm.AWARD_SINGLE_LIST 	or {};		--单场奖励表

--数据处理
EPlatForm.RankFrameCount 	= 1000;							--每帧最多对1000个战队进行数据处理
EPlatForm.RankLeagueList 	= EPlatForm.RankLeagueList 	or {};	--战队排序表,分帧处理大量数据使用
EPlatForm.RankLeagueId 		= EPlatForm.RankLeagueId		or 0;	--战队排序记录,分帧处理大量数据使用
EPlatForm.ClsLeagueList 		= EPlatForm.ClsLeagueList	or {};	--战队清理表,分帧处理大量数据使用
EPlatForm.ClsLeagueId 		= EPlatForm.ClsLeagueId		or 0;	--战队清理记录,分帧处理大量数据使用

--观战数据
EPlatForm.LookerLeagueMap 	= EPlatForm.LookerLeagueMap or {};
EPlatForm.LookPlayerCount 	= EPlatForm.LookPlayerCount or {};
EPlatForm.tbLookerReady		= EPlatForm.tbLookerReady or {};
EPlatForm.tbLook				= EPlatForm.tbLook or {};

--禁药提示
EPlatForm.ForbidItem = 
{
	{18,1,28,1},	--金创药（小）·箱
	{18,1,29,1},	--凝神丹（小）·箱
	{18,1,30,1},	--承仙蜜（小）·箱
	{18,1,31,1},	--金创药（中）·箱
	{18,1,32,1},	--凝神丹（中）·箱
	{18,1,33,1},	--承仙蜜（中）·箱
	{18,1,34,1},	--金创药（大）·箱
	{18,1,35,1},	--凝神丹（大）·箱
	{18,1,36,1},	--承仙蜜（大）·箱
	{18,1,37,1},	--回天丹·箱
	{18,1,38,1},	--大补散·箱
	{18,1,39,1},	--七巧补心丹·箱
	{18,1,40,1},	--九转还魂丹·箱
	{18,1,41,1},	--首乌还神丹·箱
	{18,1,42,1},	--五花玉露丸·箱
};

EPlatForm.SERIES_RESTRAINT_TABLE = {
	[Env.SERIES_METAL]		= {Env.SERIES_WOOD, Env.SERIES_FIRE},		-- 金系
	[Env.SERIES_WOOD]		= {Env.SERIES_EARTH, Env.SERIES_METAL},		-- 木系
	[Env.SERIES_WATER]		= {Env.SERIES_FIRE, Env.SERIES_EARTH},		-- 水系
	[Env.SERIES_FIRE]		= {Env.SERIES_METAL, Env.SERIES_WATER},		-- 火系
	[Env.SERIES_EARTH]		= {Env.SERIES_WATER, Env.SERIES_WOOD},		-- 土系
}

EPlatForm.SERIES_COLOR = {
	[Env.SERIES_METAL]		= "<color=orange>%s<color>",		-- 金系
	[Env.SERIES_WOOD]		= "<color=green>%s<color>",			-- 木系
	[Env.SERIES_WATER]		= "<color=blue>%s<color>",			-- 水系
	[Env.SERIES_FIRE]		= "<color=salmon>%s<color>",		-- 火系
	[Env.SERIES_EARTH]		= "<color=wheat>%s<color>",			-- 土系	
};

