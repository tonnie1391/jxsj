-- 文件名　：plantform_def.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-20 20:53:47
-- 功能    ：无差别竞技

--全局变量
NewEPlatForm.GTASK_MACTH_SESSION 			= DBTASD_NEWPLATEVENT_SESSION;		--比赛类型 (1-龙舟2- 雪仗3-蘑菇4-夜岚关)
NewEPlatForm.GTASK_MACTH_STATE 	 		= DBTASD_NEWPLATEVENT_STATE;			--比赛阶段(0,未开启, 1开启)
NewEPlatForm.GTASK_MACTH_MAP_STATE		= DBTASD_NEWPLATEVENT_MAP_STATE;	--准备场满人状态（0，未满，1已满）

--状态
NewEPlatForm.DEF_STATE_CLOSE	= 0;		--未开启
NewEPlatForm.DEF_STATE_STAR		= 1;		--开启

--时间参数
NewEPlatForm.nOpenDay 			= 7;		--开启无差别竞技时间 开服7天内的周一
NewEPlatForm.nCloseDay 			= 96;	--关闭时间开服96天的时候

--Task ID--
NewEPlatForm.TASKID_GROUP				= 2179;	--任务变量组
NewEPlatForm.TASKID_MATCH_TOTLE		= 1;		--参加总场次
NewEPlatForm.TASKID_MATCH_MONTH		= 17;		--参加总场次时间
NewEPlatForm.TASKID_ENTER_READY		= 2;		--进场准备场地图index
NewEPlatForm.TASKID_ENTER_DYN			= 3;		--进场比赛场mission index
NewEPlatForm.TASKID_DALIYEVENTCOUNT	= 4;		--个人参加的次数
NewEPlatForm.TASKID_COUNTCHANGETIME	= 5;		--个人累计时间
NewEPlatForm.TASKID_AWARDFLAG			= 6;		--个人单场奖励
NewEPlatForm.TASKID_LEAGUENAME			= 9;		--单场战队信息（9-16）
NewEPlatForm.TASKID_AWARD_CARD		= 18;		--流水号011当月第一场领取奖励1次
NewEPlatForm.TASKID_AWARD_HANDON		= 19;		--上交物品个数
NewEPlatForm.TASKID_AWARD_MONTH		= 21;		--领取月度奖励
--参赛选手参数
NewEPlatForm.PLAYER_ATTEND_LEVEL 		= 40;	--最低等级需求;
NewEPlatForm.MACTH_ATTEND_MAX		= 48;	--每个战队最多参加多少场
NewEPlatForm.nCurReadyMaxCount			= 24;	--本阶段准备场最大队伍数
NewEPlatForm.nCurMatchMaxTeamCount		= 8;		--本阶段比赛最大参赛队伍数
NewEPlatForm.nCurMatchMinTeamCount		= 1;		--本阶段比赛最少开启比赛人数
NewEPlatForm.MACTH_MAX_JOINCOUNT		= 8;		--最大累计次数
NewEPlatForm.nMaxAllCount					= 24;	--每月最大参加数量
NewEPlatForm.DEF_PLAYER_TEAM			= 1;		--组队只能是4个人
NewEPlatForm.nMemPlayerCount				= 4;		--组队人数

NewEPlatForm.nKinGradeLimit				= 1080;
NewEPlatForm.nPayerGradeLimit				= 27;

NewEPlatForm.tbMonthAward				= {18,1,1732,3};

--比赛场参数
NewEPlatForm.MACTH_TIME_READY 				= Env.GAME_FPS * 300;		--准备场准备时间;
NewEPlatForm.MACTH_TIME_READY_LASTENTER 	= Env.GAME_FPS * 5;		--倒数5秒不允许进场;

--内存记录表
NewEPlatForm.MissionList 			= NewEPlatForm.MissionList   	or {};			--mission
NewEPlatForm.GroupList 			= NewEPlatForm.GroupList 	 	or {};			--战队临时名单;
NewEPlatForm.ReadyTimerId 			= NewEPlatForm.ReadyTimerId  	or 0;				--准备场计时器Id;
NewEPlatForm.GameState 			= NewEPlatForm.GameState	 	or 0;				--单场比赛阶段,0未开始,1准备阶段,2pk阶段
NewEPlatForm.SEASON_TB 			= NewEPlatForm.SEASON_TB 			or {};	--联赛表
NewEPlatForm.AWARD_LEVEL 		= NewEPlatForm.AWARD_LEVEL 			or {};	--奖励分层
NewEPlatForm.MACTH_ENTER_FLAG 	= NewEPlatForm.MACTH_ENTER_FLAG 	or {};	--玩家进入比赛场标志
NewEPlatForm.AWARD_WELEE_LIST	= NewEPlatForm.AWARD_WELEE_LIST 	or {};	--奖励

NewEPlatForm.tbLadderManager		= NewEPlatForm.tbLadderManager or {};	--排行榜内容
NewEPlatForm.tbLastLadderManager	= NewEPlatForm.tbLastLadderManager or {};	--排行榜内容
NewEPlatForm.nLadderDay			= NewEPlatForm.nLadderDay or 0;			--排行榜日期

NewEPlatForm.nCurEventType		= 0;		--当前活动类型

--禁药
NewEPlatForm.ForbidItem = 
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
--比赛时间
NewEPlatForm.CALEMDAR = {1000, 1030, 1100, 1130, 1200, 1230, 1300, 1330, 1700, 1730, 1800, 1830, 1900, 1930, 2000, 2030};


NewEPlatForm.tbItemChange = {
	["18,1,1277,3"] = 1,
	["18,1,1277,4"] = 2,
	["18,1,327,5"] = 1,
	["18,1,327,6"] = 1,
	["18,1,327,7"] = 1,
	["18,1,327,8"] = 2,
	["18,1,477,2"] = 1,
	["18,1,478,2"] = 2,
	["18,1,638,3"] = 1,
	["18,1,638,4"] = 2,
}

NewEPlatForm.tbItemUpdateList = {
	["18,1,1277,3"] = {18,1,1277,4},
	["18,1,327,5"] = {18,1,327,8},
	["18,1,327,6"] = {18,1,327,8},
	["18,1,327,7"] = {18,1,327,8},
	["18,1,477,2"] = {18,1,478,2},
	["18,1,638,3"] = {18,1,638,4},
}

NewEPlatForm.tbItemChangeOther = {
	["18,1,1277,1"] = {18,1,1277,3},
	["18,1,1277,2"] = {18,1,1277,4},
	["18,1,327,1"] = {18,1,327,5},
	["18,1,327,2"] = {18,1,327,6},
	["18,1,327,3"] = {18,1,327,7},
	["18,1,327,4"] = {18,1,327,8},
	["18,1,477,1"] = {18,1,477,2},
	["18,1,478,1"] = {18,1,478,2},
	["18,1,638,1"] = {18,1,638,3},
	["18,1,638,2"] = {18,1,638,4},
}

NewEPlatForm.szUITitle = "Phần thưởng Thi đấu Gia tộc";
NewEPlatForm.tbPayItem = {nil,{{18, 1, 1731, 1, 1}}, {{18, 1, 1731, 2, 1}}};
NewEPlatForm.tbMsg = {
	{"Chọn Bắt đầu để rút thẻ", "Chọn 1 thẻ để nhận thưởng", "Chọn Tiếp tục để quay tiếp, rời khỏi để kết thúc."},
	{"Chọn Bắt đầu để sử dụng Quả Thắng Lợi (nhỏ)", "Chọn 1 thẻ để nhận thưởng", "Chọn Tiếp tục để quay tiếp, rời khỏi để kết thúc."},
	{"Chọn Bắt đầu để sử dụng Quả Thắng Lợi (lớn)", "Chọn 1 thẻ để nhận thưởng", "Chọn rời khỏi để kết thúc."},
};

NewEPlatForm.szScreenMsg = "Kết thúc thời gian, sẽ tự động rời khỏi.";

NewEPlatForm.tbBuyItem = {620, 500};

NewEPlatForm.tbCardAward = {
	{	{["szType"] = "item", 	["varValue"] = {18,1,1732,1,1,5},   ["nRate"] = 2000}, -- Mảnh Ngọc Như Ý (1 khóa, 2 không khóa)
		{["szType"] = "item", 	["varValue"] = {18,1,553, 1,1,5},   ["nRate"] = 2000}, -- Tiền Du Long
		{["szType"] = "item", 	["varValue"] = {18,1,553, 1,1,10},  ["nRate"] = 1000}, -- Tiền Du Long
		{["szType"] = "item", 	["varValue"] = {18,1,475, 1,1,1},   ["nRate"] = 1000}, -- Ngọc Như Ý
	},
	{	{["szType"] = "item", 	["varValue"] = {18,1,1732,2,0,15},  ["nRate"] = 2000}, -- Mảnh Ngọc Như Ý (1 khóa, 2 không khóa)
		{["szType"] = "item", 	["varValue"] = {18,1,553, 1,1,10},  ["nRate"] = 3000}, -- Tiền Du Long
		{["szType"] = "item", 	["varValue"] = {18,1,553, 1,1,15},  ["nRate"] = 2000}, -- Tiền Du Long
		{["szType"] = "item", 	["varValue"] = {18,1,475, 1,1,3},   ["nRate"] = 1500}, -- Ngọc Như Ý
		{["szType"] = "item", 	["varValue"] = {18,1,475, 1,1,5},   ["nRate"] = 1000}, -- Ngọc Như Ý
		{["szType"] = "item", 	["varValue"] = {18,1,475, 1,1,7},   ["nRate"] = 500}, -- Ngọc Như Ý
	},
	{	{["szType"] = "item", 	["varValue"] = {18,1,1732,2,0,25},  ["nRate"] = 2000}, -- Mảnh Ngọc Như Ý (1 khóa, 2 không khóa)
		{["szType"] = "item", 	["varValue"] = {18,1,553, 2,0,20},  ["nRate"] = 3000}, -- Tiền Du Long
		{["szType"] = "item", 	["varValue"] = {18,1,553, 2,0,35},  ["nRate"] = 2000}, -- Tiền Du Long
		{["szType"] = "item", 	["varValue"] = {18,1,475, 1,0,5},   ["nRate"] = 1500}, -- Ngọc Như Ý
		{["szType"] = "item", 	["varValue"] = {18,1,475, 1,0,10},  ["nRate"] = 1000}, -- Ngọc Như Ý
		{["szType"] = "item", 	["varValue"] = {18,1,475, 1,0,15},  ["nRate"] = 500}, -- Ngọc Như Ý
	},

}

NewEPlatForm.tbXuanjingRate = {4000, 0, 0};

NewEPlatForm.tbWeleeAward = {
	{30, 7195, 105, 5},
	{30, 6167, 90, 4},
	{30, 5653, 83, 3},
	{30, 5139, 75, 2},
	{30, 5139, 75, 1},
	{30, 4625, 68, 0},
	{30, 3598, 53, 0},
	{30, 3598, 53, 0},
}

NewEPlatForm.tbWeleeGrade = {8, 6, 4, 3, 2, 2, 1, 1};

NewEPlatForm.tbStartTime= {[1] = 1, [3] = 1, [5]= 1, [0] = 1};

NewEPlatForm.MAX_VISIBLE_LADDER = 1000;			-- 排行榜上最多显示的家族数

NewEPlatForm.tbAchievement ={
	[1] = {35,503},
	[2] = {34,502},	
	[3] = {36,504},
	[4] = {501,505},
}
