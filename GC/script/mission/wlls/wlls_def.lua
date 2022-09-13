--武林联赛
--孙多良
--2008.09.11

--Global Value--
Wlls.GTASK_MACTH_SESSION 	= DBTASD_WIIS_SESSION;		--比赛届数
Wlls.GTASK_MACTH_LASTSESSION= DBTASD_WIIS_LASTSESSION; 	--上届比赛届数，记录排名使用，防止出现排序进行中时换届
Wlls.GTASK_MACTH_STATE 	 	= DBTASD_WIIS_STATE;		--比赛阶段(0,未开启, 1间歇期,2.比赛期,3.八强赛期)
Wlls.GTASK_MACTH_MAP_STATE	= DBTASD_WIIS_MAP_STATE;	--准备场满人状态（0，未满，1已满）
Wlls.GTASK_MACTH_RANK		= DBTASD_WIIS_RANK;			--是否已排名完成标志


Wlls.DEF_STATE_CLOSE	= 0;		--未开启
Wlls.DEF_STATE_REST		= 1;		--间歇期
Wlls.DEF_STATE_MATCH	= 2;		--比赛期
Wlls.DEF_STATE_ADVMATCH	= 3;		--八强赛期

Wlls.DEF_STATE_MSG = {
	[Wlls.DEF_STATE_CLOSE]		= "未开启状态",
	[Wlls.DEF_STATE_REST]		= "间歇期",
	[Wlls.DEF_STATE_MATCH]		= "比赛期",
	[Wlls.DEF_STATE_ADVMATCH]	= "高级联赛八强赛期",
};


Wlls.LGTYPE	= 5;	--联赛战队系统类型

--LG Task ID--
Wlls.LGTASK_MSESSION= 1;		--届数
Wlls.LGTASK_MTYPE	= 2;		--比赛赛制
Wlls.LGTASK_MEXPARAM= 3;		--赛制额外参数(如门派,性别等)
Wlls.LGTASK_MLEVEL	= 4;		--比赛等级（1低级, 2高级）
Wlls.LGTASK_RANK	= 5;		--战队获得名次（比赛结束后排序获得）
Wlls.LGTASK_WIN		= 6;		--胜利次数
Wlls.LGTASK_TIE		= 7;		--平局次数
Wlls.LGTASK_TOTAL	= 8;		--参赛次数（失败次数 = TOTAL - WIN - TIE）
Wlls.LGTASK_TIME	= 9;		--战斗时间总计
Wlls.LGTASK_EMY1	= 10;		--最后的一场比赛遇到的对手（战队名String2ID）
Wlls.LGTASK_EMY2	= 11;		--倒数第二场比赛遇到的对手
Wlls.LGTASK_EMY3	= 12;		--倒数第三场比赛遇到的对手
Wlls.LGTASK_ATTEND	= 13;		--未参赛0和进入准备场Id(进入准备场为已参赛)
Wlls.LGTASK_ENTER	= 14;		--进入准备场队员总数.
Wlls.LGTASK_EMY4	= 15;		--倒数第四场比赛遇到的对手
Wlls.LGTASK_EMY5	= 16;		--倒数第五场比赛遇到的对手
Wlls.LGTASK_RANK_ADV= 17;		--八强赛排名；
Wlls.LGTASK_GATEWAY	= 18;		--只有在跨服联赛中用到，平时普通联赛用不到；
Wlls.LGTASK_ADV_ID	= 19;		--八强赛八支队伍的id；

--LG MemberTask ID--
Wlls.LGMTASK_JOB	= 1;	--职位:0、队员；1、队长
Wlls.LGMTASK_AWARD	= 2;	--奖励补领:0、无补领奖励；1、胜利奖励,上线自动领取. 2.平奖励, 3负奖励
Wlls.LGMTASK_FACTION= 3;	--门派
Wlls.LGMTASK_ROUTEID= 4;	--路线
Wlls.LGMTASK_CAMP	= 5;	--阵营
Wlls.LGMTASK_SEX	= 6;	--性别
Wlls.LGMTASK_SERIES	= 7;	--五行
Wlls.LGMTASK_GBWLLSLEVEL	= 8;		-- 参加初级还是高级跨服联赛，只在跨服联赛中用到本服的为0；
Wlls.LGMTASK_GBWLLSGATEWAY	= 9;		-- 参加跨服联赛的本服服务器ID


--Task ID--
Wlls.TASKID_GROUP			= 2052;		--任务变量组
Wlls.TASKID_MATCH_TOTLE		= 1;			--总场次
Wlls.TASKID_MATCH_WIN		= 2;			--胜场数
Wlls.TASKID_MATCH_TIE		= 3;			--平场数
Wlls.TASKID_MATCH_FIRST		= 4;			--冠军数量
Wlls.TASKID_MATCH_SECOND	= 5;			--银军数量
Wlls.TASKID_MATCH_THIRD		= 6;			--亚军数量
Wlls.TASKID_MATCH_BEST		= 7;			--最好名次
Wlls.TASKID_MATCH_FINISH	= 8;			--是否领取过奖励了
Wlls.TASKID_HELP_SESSION	= 9;			--帮助锦囊，战队联赛届数
Wlls.TASKID_HELP_TOTLE		= 10;		--帮助锦囊，战队总场数
Wlls.TASKID_HELP_WIN		= 11;		--帮助锦囊，战队赢场数
Wlls.TASKID_HELP_TIE		= 12;		--帮助锦囊，战队负场数
Wlls.TASKID_MATCH_WIN_AWARD = 13;		--单场胜利领取奖励标志
Wlls.TASKID_AWARD_LOG		= 14;		--最终领取奖励log，（届数(3位) + 奖励段（3位） * 1000 + 初级高级类型（1位） * 1000000）
Wlls.TASKID_WLLS_SESSION	= 15;		-- 记录加入战队时玩家的届数
Wlls.TASKID_WLLS_ISHAVELEAGUE = 16;		-- 记录是否加入战队
Wlls.TASKID_YINGXIONGLING_MONTH		= 21;		-- 武林大会英雄令使用的月份
Wlls.TASKID_YINGXIONGLING_TIMES		= 22;		-- 武林大会英雄令本月使用的次数
Wlls.TASKID_YINGXIONGLING_AWARD		= 23;		-- 是否可使用英雄令的标志，与联赛单场奖励一致

Wlls.YINGXIONGLING_MAX_TIMES	= 18;	-- 武林大会英雄令每月最大使用次数
Wlls.YINGXIONGLING_REPUTE		= 44;	-- 武林大会英雄令声望值
Wlls.ITEM_YINGXIONGLING			= {18, 1, 1600, 1};	-- 英雄令ID
Wlls.COIN_ITEM_WARE				= 623;

--大会场进入准备场类型，
Wlls.MAP_LINK_TYPE_RANDOM 	= 1;		--随机选择进入;随机准备场
Wlls.MAP_LINK_TYPE_SERIES 	= 2;		--五行对应类型;准备场地图编号为战队五行,比赛场也是
Wlls.MAP_LINK_TYPE_FACTION 	= 3;		--门派对应类型;准备场地图编号为战队门派,比赛场也是

--战队组队类型，
Wlls.LEAGUE_TYPE_SEX_FREE 			= 0;		--自由性别
Wlls.LEAGUE_TYPE_SEX_SINGLE 		= 1;		--同一性别;
Wlls.LEAGUE_TYPE_SEX_MIX 			= 2;		--混合性别;
Wlls.LEAGUE_TYPE_CAMP_FREE 			= 0;		--自由阵营;
Wlls.LEAGUE_TYPE_CAMP_SINGLE 		= 1;		--同一阵营;
Wlls.LEAGUE_TYPE_CAMP_MIX 			= 2;		--混合阵营;
Wlls.LEAGUE_TYPE_SERIES_FREE 		= 0;		--自由五行;
Wlls.LEAGUE_TYPE_SERIES_SINGLE 		= 1;		--同一五行;
Wlls.LEAGUE_TYPE_SERIES_MIX 		= 2;		--混合五行;
Wlls.LEAGUE_TYPE_SERIES_RESTRAINT	= 3;		--相克五行;（此类型本版本暂不开发）
Wlls.LEAGUE_TYPE_FACTION_FREE 		= 0;		--自由门派;
Wlls.LEAGUE_TYPE_FACTION_SINGLE 	= 1;		--同一门派;
Wlls.LEAGUE_TYPE_FACTION_MIX 		= 2;		--混合门派;
Wlls.LEAGUE_TYPE_TEACHER_FREE 		= 0;		--自由师徒;
Wlls.LEAGUE_TYPE_TEACHER_MIX 		= 1;		--混合师徒;

Wlls.MATCH_ROUND_TYPE_DEFAULT		= 0;		-- 默认一轮比赛
Wlls.MATCH_ROUND_TYPE_PERPK			= 1;		-- 根据配置表的比赛时间分为几轮


--参赛选手参数
Wlls.PLAYER_ATTEND_LEVEL 		= 100;		--最低等级需求;
Wlls.MAP_SELECT_MIN				= 10;		--每张准备场最少先进入多少队。
Wlls.MAP_SELECT_SUBAREA			= 10;		--匹配原则,按胜率多少队为一个区间
Wlls.MAP_SELECT_MAX				= 100;		--每张比赛地图最多有几个比赛擂台。
Wlls.MACTH_LEAGUE_MIN			= 4;		--准备场中最少要有多少队才能开启。
Wlls.MACTH_ATTEND_MAX			= 36;		--每个战队最多参加多少场
Wlls.MACTH_ADV_START_MISSION 	= 3;		--高级联赛开启届数。第三届才开启高级联赛
Wlls.MACTH_PRIM_START_MISSION 	= 0;		--初级联赛开启届数，只有跨服联赛才会用到

Wlls.MACTH_POINT_WIN 			= 3;		--胜利获得积分
Wlls.MACTH_POINT_TIE 			= 1;		--平获得积分
Wlls.MACTH_POINT_LOSS 			= 0;		--输掉比赛获得积分

if (GLOBAL_AGENT) then
	Wlls.MACTH_POINT_WIN 			= 3;		--胜利获得积分
	Wlls.MACTH_POINT_TIE 			= 2;		--平获得积分
	Wlls.MACTH_POINT_LOSS 			= 1;		--输掉比赛获得积分
end

Wlls.MACTH_TIME_BYE  			= 300;		--轮空计算的比赛时间的秒数
Wlls.MACTH_NEW_WINRATE  		= 50;		--一场没打队伍按50％胜率计算

--联赛类型
Wlls.MACTH_PRIM = 1;		--初级联赛
Wlls.MACTH_ADV 	= 2;		--高级联赛
Wlls.MACTH_LEVEL = 
{
	[Wlls.MACTH_PRIM ] 	= "PrimMacth",	--外围赛
	[Wlls.MACTH_ADV]	= "AdvMacth",	--精英赛
};
Wlls.MACTH_LEVEL_NAME = 
{
	[Wlls.MACTH_PRIM] 	= "初级",	--外围赛
	[Wlls.MACTH_ADV]	= "高级",	--精英赛
};

--八强赛场次对应表
Wlls.MACTH_STATE_ADV_TASK = 
{
	[1] = 8,
	[2] = 4,
	[3] = 2,
	[4] = 2,
	[5] = 2,
};

--四强对阵表


--比赛场参数
Wlls.MACTH_TIME_READY 			= Env.GAME_FPS * 280;		--准备场准备时间;
Wlls.MACTH_TIME_READY_LASTENTER = Env.GAME_FPS * 5;			--倒数5秒不允许进场;
Wlls.MACTH_TIME_PK_DAMAGE 		= Env.GAME_FPS * 5;			--同步伤血量时间;
Wlls.MACTH_TIME_UPDATA_RANK 	= Env.GAME_FPS * 610;		--准备时间结束进入比赛后多少时间更新排行;

Wlls.MACTH_TIME_ADVMATCH 		= Env.GAME_FPS * 900;		--八强赛每场相隔时间;
Wlls.MACTH_TIME_ADVMATCH_MAX 	= 5;						--八强赛总场数，5场;

Wlls.MACTH_TIME_RANK_FINISH 	= Env.GAME_FPS * 60;		--预计最终排名所需要处理时间，玩家才能领取奖励
Wlls.MACTH_TIME_CLEARLEAGUE 	= Env.GAME_FPS * 240;		--预计什么时候清除玩家战队

Wlls.MIS_LIST 	= 
{	
	{"PkToPkStart", 	Env.GAME_FPS * 15, 	"OnGamePk"	},	--Pk准备时间 15秒
	{"PkStartToEnd", 	Env.GAME_FPS * 585, "OnGameOver"},	--比赛时间 585秒
};

-- 在需要子mission的时候用到
Wlls.SUB_MIS_LIST 	= {};

Wlls.MIS_UI 	= 
{
	[1] = {"<color=gold>%s Vs %s\n\n", "<color=green>比赛开始剩余时间：<color=white>%s<color>\n\n", "<color=green>对方受伤总量：<color=red>%s\n<color=green>本方受伤总量：<color=blue>%s"};
	[2] = {"<color=gold>%s Vs %s\n\n", "<color=green>剩余时间：<color=white>%s<color>\n\n", "<color=green>对方受伤总量：<color=red>%s\n<color=green>本方受伤总量：<color=blue>%s"};
}

Wlls.SUB_MIS_UI		= {};


Wlls.MIS_UI_LOOKER = "<color=green>%s队伤血量：<color=red>\n    %s\n\n<color=green>%s队伤血量：\n    <color=blue>%s";
Wlls.MACTH_TRAP_ENTER ={{50464/32, 103712/32}, {53600/32, 106912/32}, {48000/32, 105024/32}, {51872/32, 109696/32}};	--进入准备场坐标
Wlls.MACTH_TRAP_LEAVE ={{52672/32, 104192/32}, {54784/32, 106336/32}, {49824/32, 108320/32}, {52224/32, 110592/32}};	--进入会场坐标

--内存记录表
Wlls.MissionList 	= Wlls.MissionList   or {[Wlls.MACTH_PRIM]={}, [Wlls.MACTH_ADV] ={}};		--mission
Wlls.GroupList 		= Wlls.GroupList 	 or {[Wlls.MACTH_PRIM]={}, [Wlls.MACTH_ADV] ={}};		--战队临时名单;
Wlls.GroupListTemp 	= Wlls.GroupListTemp or {[Wlls.MACTH_PRIM]={}, [Wlls.MACTH_ADV] ={}};		--战队临时名单2;
Wlls.ReadyTimerId 	= Wlls.ReadyTimerId  or 0;			--准备场计时器Id;
Wlls.GameState 		= Wlls.GameState	 or 0;			--单场比赛阶段,0未开始,1准备阶段,2pk阶段
Wlls.PosGamePk 		= Wlls.PosGamePk 	 or {};			--pk场传入点坐标
Wlls.AdvMatchState	= Wlls.AdvMatchState or 0;			--八强赛阶段，（1：8进4；2：4进2，3：决赛场1；4：决赛场2；5：决赛场3；）
Wlls.AdvMatchLists	= Wlls.AdvMatchLists or {};			--八强赛名单，
Wlls.WaitMapMemList = Wlls.WaitMapMemList or {};		--会场玩家名单

Wlls.SEASON_TB 			= Wlls.SEASON_TB 			or {};		--联赛表
Wlls.AWARD_LEVEL 		= Wlls.AWARD_LEVEL 			or {};		--奖励分层
Wlls.MACTH_ENTER_FLAG 	= Wlls.MACTH_ENTER_FLAG 	or {};		--玩家进入比赛场标志
Wlls.AWARD_FINISH_LIST  = Wlls.AWARD_FINISH_LIST 	or {[Wlls.MACTH_PRIM]={}, [Wlls.MACTH_ADV] ={}};		--最终奖励表
Wlls.AWARD_SINGLE_LIST  = Wlls.AWARD_SINGLE_LIST 	or {[Wlls.MACTH_PRIM]={}, [Wlls.MACTH_ADV] ={}};		--单场奖励表
Wlls.DATE_TO_SESSION	= Wlls.DATE_TO_SESSION		or {};		-- 根据月份决定赛制

--数据处理
Wlls.RankFrameCount 	= 1000;							--每帧最多对1000个战队进行数据处理
Wlls.RankLeagueList 	= Wlls.RankLeagueList 	or {};	--战队排序表,分帧处理大量数据使用
Wlls.RankLeagueId 		= Wlls.RankLeagueId		or 0;	--战队排序记录,分帧处理大量数据使用
Wlls.ClsLeagueList 		= Wlls.ClsLeagueList	or {};	--战队清理表,分帧处理大量数据使用
Wlls.ClsLeagueId 		= Wlls.ClsLeagueId		or 0;	--战队清理记录,分帧处理大量数据使用

--观战数据
Wlls.LookerLeagueMap 	= Wlls.LookerLeagueMap or {};
Wlls.LookPlayerCount 	= Wlls.LookPlayerCount or {};
Wlls.tbLookerReady		= Wlls.tbLookerReady or {};
Wlls.tbLook				= Wlls.tbLook or {};

Wlls.tbMissionType		= Wlls.tbMissionType or {};

--禁药提示
Wlls.ForbidItem = 
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

Wlls.SERIES_RESTRAINT_TABLE = {
	[Env.SERIES_METAL]		= {Env.SERIES_WOOD, Env.SERIES_FIRE},		-- 金系
	[Env.SERIES_WOOD]		= {Env.SERIES_EARTH, Env.SERIES_METAL},		-- 木系
	[Env.SERIES_WATER]		= {Env.SERIES_FIRE, Env.SERIES_EARTH},		-- 水系
	[Env.SERIES_FIRE]		= {Env.SERIES_METAL, Env.SERIES_WATER},		-- 火系
	[Env.SERIES_EARTH]		= {Env.SERIES_WATER, Env.SERIES_WOOD},		-- 土系
}

Wlls.SERIES_COLOR = {
	[0]						= "未知五行",
	[Env.SERIES_METAL]		= "<color=orange>%s<color>",		-- 金系
	[Env.SERIES_WOOD]		= "<color=green>%s<color>",			-- 木系
	[Env.SERIES_WATER]		= "<color=blue>%s<color>",			-- 水系
	[Env.SERIES_FIRE]		= "<color=salmon>%s<color>",		-- 火系
	[Env.SERIES_EARTH]		= "<color=wheat>%s<color>",			-- 土系	
};

if (GLOBAL_AGENT) then
	Wlls.DEF_FILE_ADDRESS			= "gbwlls";
	Wlls.MACTH_ADV_START_MISSION	= 0;		--一开始就开高级联赛
	Wlls.MACTH_PRIM_START_MISSION	= 5;		--5届后开初级
else
	Wlls.DEF_FILE_ADDRESS = "wlls";
end

--成就配置表

--报名
Wlls.tbAchievementApply = {
				[1] = 275,	--双人赛
				[2] = 276,	--三人
				[3] = 279,	--四人
				[4] = 274,	--混合单人
				[5] = 273,	--门派单人
				[6] = 278,	--相克双人
				[7] = 277,	--同系双人
				[8] = 276,	--三人组单人赛
};

--获胜场次
Wlls.tbAchievementWin = {
		[1] = {[18] = 296,[27] = 297,[36] = 298}, 	--3双人赛
		[2] = {[18] = 303,[27] = 304,[36] = 305},	--4三人
		[3] = {[18] = 324,[27] = 325,[36] = 326},	--7四人
		[4] = {[18] = 289,[27] = 290,[36] = 291},	--2混合单人
		[5] = {[18] = 282,[27] = 283,[36] = 284},	--1门派单人
		[6] = {[18] = 317,[27] = 318,[36] = 319},	--6相克双人
		[7] = {[18] = 310,[27] = 311,[36] = 312},	--5同系双人														
		[8] = {[18] = 303,[27] = 304,[36] = 305},	--8三人组单人赛
};

--最终排名
Wlls.tbAchievementRank = {
		[1] = {{500, 299}, {8, 300}, {1, 301}}, 	--3双人赛
		[2] = {{200, 306}, {8, 307}, {1, 308}},		--4三人
		[3] = {{100, 327}, {8, 328}, {1, 329}},		--7四人
		[4] = {{1000, 292}, {8, 293}, {1, 294}},	--2混合单人
		[5] = {{100, 285}, {8, 286}, {1, 287}},		--1门派单人
		[6] = {{100, 320}, {8, 321}, {1, 322}},		--6相克双人
		[7] = {{100, 313}, {8, 314}, {1, 315}},		--5同系双人														
		[8] = {{200, 306}, {8, 307}, {1, 308}},		--8三人组单人赛
};

Wlls.tbAchievementRank_repair = {
		[1] = {{9, 299}, {5, 300}, {1, 301}}, 	--3双人赛
		[2] = {{8, 306}, {5, 307}, {1, 308}},		--4三人
		[3] = {{7, 327}, {5, 328}, {1, 329}},		--7四人
		[4] = {{9, 292}, {5, 293}, {1, 294}},	--2混合单人
		[5] = {{7, 285}, {5, 286}, {1, 287}},		--1门派单人
		[6] = {{7, 320}, {5, 321}, {1, 322}},		--6相克双人
		[7] = {{7, 313}, {5, 314}, {1, 315}},		--5同系双人
		[8] = {{8, 306}, {5, 307}, {1, 308}},		--8三人组单人赛
};

--参加比赛
Wlls.tbAchievementAttend = {
		[1] = 295,	--3双人赛
		[2] = 302,	--4三人
		[3] = 323,	--7四人
		[4] = 288,	--2混合单人
		[5] = 281,	--1门派单人
		[6] = 316,	--6相克双人
		[7] = 309,	--5同系双人
		[8] = 302,	--8三人组单人赛
};

Wlls.tbAchievementWinOne = 280;

-- 参加场次获得的最终额外奖励
Wlls.tbExternAwardOnGameTimes = 
{
	--[Wlls.MACTH_PRIM] = {};  -- 初级联赛没有额外奖励
	[Wlls.MACTH_ADV] =
	{
		-- 参加满场次的额外奖励
		[Wlls.MACTH_ATTEND_MAX] = { 
			["stone_stackitem"] = { {18, 1, 1315, 1, 2, 1} },	-- 为了统一处理，这里要填成跟配置表一致的格式（Wlls.Fun能识别的格式）
		}	
	}
}
