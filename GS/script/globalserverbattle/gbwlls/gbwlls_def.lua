--全局武林联赛
--zhouchenfei
--2009-12-16 15:37:34

Require("\\script\\mission\\wlls\\wlls_def.lua")

GbWlls.IsOpen = 1; -- 开启标志，做手动关闭用
if (IVER_g_nSdoVersion == 1) then
	GbWlls.IsOpen=0;
end


GbWlls.GTASK_MACTH_SESSION		= Wlls.GTASK_MACTH_SESSION;
GbWlls.GTASK_MACTH_STATE		= Wlls.GTASK_MACTH_STATE;
GbWlls.DEF_STATE_CLOSE			= Wlls.DEF_STATE_CLOSE;
GbWlls.DEF_STATE_REST			= Wlls.DEF_STATE_REST;
GbWlls.DEF_STATE_MATCH			= Wlls.DEF_STATE_MATCH;
GbWlls.DEF_STATE_ADVMATCH		= Wlls.DEF_STATE_ADVMATCH;
GbWlls.GTASK_STARSERVERFLAG		= DBTASD_GBWLLS_STARSERVER_RANK;		--明星服务器标记
GbWlls.GTASK_STARSERVERFLAG_TIME= DBTASD_GBWLLS_STARSERVER_RANK_TIME;	--明星服务器标记
GbWlls.GTASK_MAX_GUESS_TICKET	= DBTASD_GBWLLS_GUESS_MAX_TICKET;

-- 跨服玩家变量
GbWlls.GBTASKID_GROUP				= 2;		-- 跨服变量组
GbWlls.GBTASKID_SESSION				= 1;		-- 记录玩家参加的全局服务器的联赛的届数
GbWlls.GBTASKID_MATCH_LEVEL			= 2;		-- 记录玩家参加的全局服务器的联赛等级
GbWlls.GBTASKID_MATCH_RANK			= 3;		-- 记录玩家参加的全局服务器联赛排名
GbWlls.GBTASKID_MATCH_WIN_AWARD		= 4;		-- 玩家单场胜场奖励
GbWlls.GBTASKID_MATCH_TIE_AWARD		= 5;		-- 玩家单场平场奖励
GbWlls.GBTASKID_MATCH_LOSE_AWARD	= 6;		-- 玩家单场负场奖励
GbWlls.GBTASKID_MATCH_FINAL_AWARD	= 7;		-- 玩家最终奖励
GbWlls.GBTASKID_MATCH_ADVRANK		= 8;		-- 记录玩家参加的全局服务器联赛八强赛排名
GbWlls.GBTASKID_MATCH_TYPE_PAREM	= 9;		-- 记录跨服联赛一些重要信息，比如门派赛的报名门派，比如五行赛的报名五行
GbWlls.GBTASKID_MATCH_DAILY_RESULT	= 10;		-- 记录跨服联赛玩家是否赢得比赛的时间
GbWlls.GBTASKID_MATCH_LAST_LEVEL_RANK	= 11;		-- 记录跨服联赛玩家上一次参加比赛的联赛等级和名次  等级*100000 + 名次

-- 跨服服务器变量
GbWlls.GBTASK_GROUP					= 2;		-- 跨服全局变量组
GbWlls.GBTASK_SESSION				= 11;		-- 记录全局服务器联赛届数
GbWlls.GBTASK_FIRSTOPENTIME			= 12;		-- 记录全局服务器第一届联赛时间
GbWlls.GBTASK_MATCH_STATE			= 13;		-- 记录跨服联赛状态
GbWlls.GBTASK_MATCH_RANK			= 14;		-- 是否排名完的标志
GbWlls.GBTASK_MATCH_OPEN_GOLDEN		= 15;		-- 是否开启黄金联赛标志


GbWlls.TASKID_GROUP					= 2111;		-- 任务变量组
GbWlls.TASKID_MONEY_RANK			= 1;		-- 财富荣誉排名
GbWlls.TASKID_WLLS_RANK				= 2;		-- 联赛排名
GbWlls.TASKID_MATCH_SESSION			= 3;		-- 奖励的的联赛届数
GbWlls.TASKID_MATCH_WIN_AWARD		= 4;		-- 玩家单场胜场奖励
GbWlls.TASKID_MATCH_TIE_AWARD		= 5;		-- 玩家单场平场奖励
GbWlls.TASKID_MATCH_LOSE_AWARD		= 6;		-- 玩家单场负场奖励
GbWlls.TASKID_MATCH_FINAL_AWARD		= 7;		-- 玩家最终奖励
GbWlls.TASKID_MATCH_FIRST			= 8;		-- 冠军数量
GbWlls.TASKID_MATCH_SECOND			= 9;		-- 银军数量
GbWlls.TASKID_MATCH_THIRD			= 10;		-- 亚军数量
GbWlls.TASKID_MATCH_BEST			= 11;		-- 最好名次
GbWlls.TASKID_AWARD_LOG				= 12;		-- 最终领取奖励log，（届数(3位) + 奖励段（3位） * 1000 + 初级高级类型（1位） * 1000000）
GbWlls.TASKID_ENTERFLAG				= 13;		-- 通过正常途径会纪录标记
GbWlls.TASKID_STATUARY_TYPE			= 14;		-- 雕像的标记
GbWlls.TASKID_GETFINALAWARD_TIME	= 15;		-- 记录领取最终奖励的时间
GbWlls.TASKID_PRAY_TIME				= 16;		-- 记录玩家祈福时间，每天一次
GbWlls.TASKID_STARSERVER_FLAG		= 17;		-- 明星服务器领取奖励标记
GbWlls.TASKID_GUESS_SESSION			= 18;		-- 竞猜的届数
GbWlls.TASKID_GUESS_PLAYER_FLAG1	= 19;		-- 玩家投票记录，所投玩家
GbWlls.TASKID_GUESS_PLAYER_COUNT1	= 20;		-- 所投票数
GbWlls.TASKID_GUESS_PLAYER_FLAG2	= 21;
GbWlls.TASKID_GUESS_PLAYER_COUNT2	= 22;
GbWlls.TASKID_GUESS_PLAYER_FLAG3	= 23;
GbWlls.TASKID_GUESS_PLAYER_COUNT3	= 24;
GbWlls.TASKID_CHENGZHUBOX_NUM		= 25;		-- 购买城主箱子
GbWlls.TASKID_CHENGZHANBOX_NUM		= 26;		-- 购买城战箱子

GbWlls.DEF_ZONESERVERCOUNT	= 1;

GbWlls.MACTH_PRIM			= 1;		--初级联赛
GbWlls.MACTH_ADV			= 2;		--高级联赛

GbWlls.DEF_MAXGBWLLS_MONEY_RANK = 250;	-- 参加跨服武林联赛的最低财富排名
GbWlls.DEF_MAXGBWLLS_WLLS_RANK = 200;	-- 参加跨服武林联赛的最低联赛荣誉排名

GbWlls.DEF_ADV_MAXGBWLLS_MONEY_RANK = 250;	-- 参加跨服高级武林联赛的最低财富排名
GbWlls.DEF_ADV_MAXGBWLLS_WLLS_RANK = 200;	-- 参加跨服高级武林联赛的最低联赛荣誉排名

GbWlls.DEF_OPENGBWLLSSESSION	= 4; 	-- 允许开启跨服联赛的届数是4届
GbWlls.DEF_MIN_PLAYERLEVEL		= 100;	-- 允许参加跨服联赛的等级

GbWlls.SEASON_TB 			= GbWlls.SEASON_TB 			or {};		--联赛表
GbWlls.AWARD_LEVEL 			= GbWlls.AWARD_LEVEL 		or {};		--奖励分层
GbWlls.MACTH_ENTER_FLAG 	= GbWlls.MACTH_ENTER_FLAG 	or {};		--玩家进入比赛场标志
GbWlls.AWARD_FINISH_LIST  	= GbWlls.AWARD_FINISH_LIST 	or {[GbWlls.MACTH_PRIM]={}, [GbWlls.MACTH_ADV] ={}};		--最终奖励表
GbWlls.AWARD_SINGLE_LIST  	= GbWlls.AWARD_SINGLE_LIST 	or {[GbWlls.MACTH_PRIM]={}, [GbWlls.MACTH_ADV] ={}};		--单场奖励表

GbWlls.DEF_OPEN_MONTH		= {1,4,7,10}; -- 跨服联赛开启的月份

GbWlls.DEF_SEND_MAIL_DAY	= 1;
GbWlls._DEF_MATCHLEVEL_CHANGETIME = 20100129;

GbWlls.DEF_ADV_PK_STARTDAY	= 29;
GbWlls.DEF_ADV_GUESS_TICKET_ENDTIME	= 19;

-- 开了新大区需要维护
GbWlls.tbZoneName	= {
	[1] = {"青龙区", 1},
	[2]	= {"白虎区", 2},
	[3]	= {"朱雀区", 3},
	[4]	= {"玄武区", 4},
	[5]	= {"紫薇区", 5},
	[6]	= {"北斗区", 6},
	[7]	= {"金麟区", 7},
	[10]	= {"吉祥区", 8},
	[11]	= {"如意区", 9},
};

GbWlls.MAIL_JOINGBWLLS = {
	szTitle		= "跨服联赛%s", 
	szContent	= "《第%s届跨服联赛》再度向各位英雄发出邀请！本届跨服联赛为<color=yellow>%s<color>，<color=yellow>%s月7日-27日各路英雄将齐战循环赛、%s日全区8强将决战江湖<color>！<color=green>恭喜您已获得比赛资格<color>，快去找<color=orange>临安府<color><link=npcpos:跨服联赛报名官,0,3718>，去英雄岛报名比赛吧！全服所有玩家都会为您祝福！",
};

GbWlls.MAIL_JOINGBWLLS_ADV = {
	szTitle		= "跨服%s赛八强赛", 
	szContent	= "英雄果然是高手中的高手！恭喜您闯入<color=green>%s全区八强<color>！比赛将在<color=yellow>%s月%s日<color>展开，无敌到寂寞的人就是你了！！",
};

GbWlls.MSG_JOIN_SUCCESS_FOR_ALL = "<color=yellow>%s<color>已报名参加第%s届跨服联赛<color=yellow>%s<color>！快去<color=yellow>临安府的跨服联赛助威鼓<color>为他祝福吧！";
GbWlls.MSG_JOIN_SUCCESS_FOR_MY	= "您已报名成功，将参加第%s届跨服联赛——%s！并将获得全服玩家的祝福！";

GbWlls.MSG_MATCH_RESULT_COMMON_FACTION		= "%s在本届%s区跨服联赛中目前暂列%s门派第%s名！";
GbWlls.MSG_MATCH_RESULT_ADV_FINAL_RESULT_1	= "由%s服的%s组成的战队%s在本届%s区跨服联赛中获得了%s的%s！";
GbWlls.MSG_MATCH_RESULT_ADV_FACTION_2		= "%s在本届%s区跨服联赛中获得了%s门派第%s名！";

GbWlls.MSG_MATCH_TIME_GLOBALMSG_COMMON		= "<color=yellow>《第%s届跨服联赛》<color>隆重开启，本届将举行<color=yellow>%s，%s月7号-27号进行循环赛<color>，各位大侠快去<color=yellow>临安府<color>的<color=yellow>跨服联赛助威鼓<color>那儿为你所看好的选手送上祝福吧！";
GbWlls.MSG_MATCH_TIME_GLOBALMSG_ADV			= "<color=yellow>《第%s届跨服联赛》<color>已进入白热化阶段，进入全区门派8强的选手将在<color=yellow>%s号决赛<color>！";
GbWlls.MSG_MATCH_TIME_GLOBALMSG_STAR		= "<color=yellow>第%s届<color>跨服联赛完美落幕，本服在比赛期间本服参赛队总积分位列<color=yellow>%s前四名<color>，获得<color=yellow>“明星服务器”<color>的称号，这是全服所有玩家共同的荣耀，快去临安府的跨服联赛助威鼓共享荣耀之光吧！";

GbWlls.MSG_8RANK_GUESS	= [[    跨服联赛门派单人赛预赛已经告一段落，在经过角逐后，门派八强已经产生。点击参赛者姓名选项可深入了解该选手资料。
    你现在可以对自己当前门派中的你心目中的最强者表示支持，你只有一次支持的机会，若你支持的选手最终获得冠军，你也将会获得，<color=gold>跨服联赛宝箱<color>和<color=gold>“跨服联赛铁杆粉丝”<color>的称号以及持续一周的<color=gold>靓丽光环<color>哟。投票截止时间为<color=green>4月29日19点<color>，千万不要错过了哟！
    而十二门派中获得支持率最高的侠客也可以获得为期一个月的神秘称号和光环。
]]; -- 八强竞猜对话提示

GbWlls.MSG_STARPLAYER	= "恭喜<color=yellow>%s<color>成为<color=yellow>%s大区<color>获得跨服联赛中玩家支持最多的选手，让我们为他欢呼！";

GbWlls.JOIN_TITLE = {6,23,1,0};

GbWlls.DEF_PRAY_MIN_LEVEL				= 69;		-- 送祝福最低等级
GbWlls.DEF_PRAY_MIN_PRESTIGE			= 200;		-- 送祝福最低威望
GbWlls.DEF_PRAY_MIN_MONEY_HONOR_RANK	= 5000;		-- 送祝福最低财富荣誉排名

GbWlls.DEF_ITEM_LUCK_GBWLLS_CARD		= {18,1,912,1}; -- 幸运刮刮卡
GbWlls.DEF_ITEM_WINGUESS				= {18,1,913,1};		-- 幸运刮刮卡胜利奖励宝箱
GbWlls.DEF_ITEM_STAR_FLOWER				= {18,1,914,1}; -- 明星服务器礼花

GbWlls.DEF_GUESS_MIN_PRESTIGE_RANK		= 5000;		-- 竞猜最低名次要求

GbWlls.DEF_NOT_OPEN_LUCKCARD_TIME_START	= 15;
GbWlls.DEF_NOT_OPEN_LUCKCARD_TIME_END	= 22;		-- 开刮刮卡时间，比赛期每天22点后才能开刮刮卡

GbWlls.DEF_ITEM_LOSTGUESS				= {18,1,80,1}; -- 幸运刮刮卡玩家竞猜失败的奖励
GbWlls.DEF_ITEM_LOSTGUESS_COUNT			= 2;	-- 数量

GbWlls.DEF_ITEM_WINGUESS8RANK			= {18,1,553,1};	-- 游龙古币
GbWlls.DEF_ITEM_LOSTGUESS8RANK			= {18,1,80,1}; -- 幸运刮刮卡玩家竞猜失败的奖励
GbWlls.DEF_ITEM_LOSTGUESS8RANK_COUNT	= 2;	-- 数量


GbWlls.DEF_ITEM_GUESS					= {18,1,476,1};	-- 竞猜需要的物品
GbWlls.DEF_COUNT_MAX_GUESS				= 10;	-- 一次性投票最多能投10个

GbWlls.DEF_ITEM_WINGUESS_COUNT			= 1;

GbWlls.tbMatchPlayerList				= {};		-- 本服保存已经报名参加跨服联赛的玩家爱
GbWlls.tb8RankInfo						= {};		-- 大区前八名玩家

GbWlls.DEF_MAX_NUM_MONEY_HONOR			= 1000;		-- 取1000名财富荣誉玩家
GbWlls.DEF_MAX_NUM_WLLS_HONOR			= 1000;		-- 取1000名联赛荣誉玩家


GbWlls.DEF_INDEX_GBWLLS_8RANK_LEAGUENAME	= 1;
GbWlls.DEF_INDEX_GBWLLS_8RANK_MAPTYPE 		= 2;
GbWlls.DEF_INDEX_GBWLLS_8RANK_GATEWAY 		= 3;
GbWlls.DEF_INDEX_GBWLLS_8RANK_WIN 			= 4;
GbWlls.DEF_INDEX_GBWLLS_8RANK_TIE 			= 5;
GbWlls.DEF_INDEX_GBWLLS_8RANK_TOTAL 		= 6;
GbWlls.DEF_INDEX_GBWLLS_8RANK_RANK 			= 7;
GbWlls.DEF_INDEX_GBWLLS_8RANK_ADVRANK		= 8;
GbWlls.DEF_INDEX_GBWLLS_8RANK_TIME			= 9;
GbWlls.DEF_INDEX_GBWLLS_8RANK_ADVID			= 10;
GbWlls.DEF_INDEX_GBWLLS_8RANK_MATCHTYPE		= 11;

GbWlls.DEF_DAY_STARSERVER_1	= 20;	-- 礼花活动持续时间
GbWlls.DEF_DAY_STARSERVER_2	= 20;	-- 礼花活动持续时间
GbWlls.DEF_DAY_STARSERVER_3	= 10;	-- 礼花活动持续时间
GbWlls.DEF_DAY_STARSERVER_4	= 5;	-- 礼花活动持续时间

GbWlls.DEF_MAX_NUM_GUESS_TICKET				= 1000;	-- 每个人对一个人最多能投1000票

GbWlls.DEF_NUM_PER_TICKET		= 3; -- 每个投注获3个游龙古币
GbWlls.DEF_TIME_MSG_MAX_COUNT	= 6; -- 每次放6编
GbWlls.DEF_TIME_MSG_TIME		= 10 * 60; -- 10分钟一次
GbWlls.DEF_TIME_SEND_JOINMAIL	= 5 * 60;

GbWlls.IsOpenEvent1	= 1;	-- 是否跨服联赛活动
GbWlls.IsOpenEvent2	= 1;	-- 是否开启幸运卡活动
GbWlls.IsOpenEvent3	= 0;	-- 是否开启八强竞猜活动

GbWlls.DEF_STARPLAYER_FAC_TITLE	= {12, 10};
GbWlls.DEF_STARFANS_TITLE	= {6,24,1,0};

GbWlls.DEF_STARNUM = 4;

GbWlls.DEF_SIGN_DEADLINE = 27; -- 报名截止日期

GbWlls.DEF_TIME_SAVE_GBWLLSBUF	= 10 * 60;
GbWlls.DEF_TIME_ADV_STARTMSG	= 25;

GbWlls.MACTH_LEVEL_NAME = 
{
	[Wlls.MACTH_PRIM] 	= "高级",	--外围赛
	[Wlls.MACTH_ADV]	= "黄金",	--精英赛
};
