-------------------------------------------------------------------
--File: 	factionbattle_def.lua
--Author: 	zhengyuhua
--Date: 	2008-1-8 17:38
--Describe:	门派战定义
-------------------------------------------------------------------

if not FactionBattle then --调试需要
	FactionBattle = {};
	print(GetLocalDate("%Y\\%m\\%d  %H:%M:%S").." build ok ..");
end

FactionBattle.tbDef_Old 	= {};
FactionBattle.tbDef_New = {};

FactionBattle.bXpOpen = EventManager.IVER_bOpenTiFu;
local preEnv = _G;	--保存旧的环境

-- 门派竞技地图对应表
FactionBattle.FACTION_TO_MAP =
{
	[Env.FACTION_ID_SHAOLIN] 	= 241,
	[Env.FACTION_ID_TIANWANG] 	= 241,
	[Env.FACTION_ID_TANGMEN] 	= 241,
	[Env.FACTION_ID_WUDU] 		= 241,
	[Env.FACTION_ID_EMEI] 		= 241,
	[Env.FACTION_ID_CUIYAN] 	= 241,
	[Env.FACTION_ID_GAIBANG] 	= 241,
	[Env.FACTION_ID_TIANREN] 	= 241,
	[Env.FACTION_ID_WUDANG] 	= 241,
	[Env.FACTION_ID_KUNLUN] 	= 241,
	[Env.FACTION_ID_MINGJIAO] 	= 241,
	[Env.FACTION_ID_DALIDUANSHI] = 241,
	[Env.FACTION_ID_GUMU]		= 241,
};

-- 两种模式下通用定义
setfenv(1, FactionBattle)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SETTING_PATH 	= "\\setting\\factionbattle\\";
ARENA_RANGE		= "arena_range.txt";
ARENA_POINT		= "arena_point.txt";
BOX_POINT		= "box_point.txt";
	
MAX_ATTEND_PLAYER		= 400; 		-- 最大参赛人数
MIN_ATTEND_PLAYER		= 2;		-- 最小参加人数 		
MIN_RESTART_MELEE		= 8;		-- 最少分场人数	
PLAYER_PER_ARENA		= 50;		-- 每个混战场所容纳的最大人数
MAX_ARENA				= 8;		-- 最大混战场个数
MELEE_RESTART_PROTECT	= 10;		-- 混战重分场地后保护时间 10秒
ELIMI_PROTECT_TIME		= 30;		-- 淘汰赛保护时间 30秒
END_DELAY				= 5;		-- 战区剩余唯一一人时要传出的传送延迟
ADD_BOX_DELAY			= 5; 		-- 决出胜负后宝箱刷出延迟时间
ADDEXP_SECOND_PRE_TIME	= 30;		-- 每次+经验间隔时间 30秒
ADDEXP_QUEUE_NUM		= 10;		-- +经验队列数
RATIO					= 1;		-- +经验为基准经验的倍数
FLAG_NPC_TAMPLATE_ID	= 2702;		-- 冠军旗子NPC模板ID
FLAG_X					= 1575;		-- 冠军旗子坐标
FLAG_Y					= 3375;		-- 冠军旗子坐标
FLAG_EXIST_TIME			= 10 * 60;		-- 冠军旗子生存期			
YANHUA_SKILL_ID			= 391;		-- 烟花的技能ID
GOUHUO_NPC_ID			= 2728;		-- 多人篝火ID
GOUHUO_EXISTENTIME 		= 600; 		-- 篝火持续时间
GOUHUO_BASEMULTIP		= 400; 		-- 篝火获得经验倍率百分比
TITLE_GROUP				= 4;		-- 冠军称号组
TITLE_ID				= 1;		-- 称号ID
MIN_LEVEL				= 50;		-- 参加等级下限
--MAX_LEVEL				= 100; 		-- 参加等级上限

TASK_GROUP_ID			= 2016		-- 任务变量组ID
DEGREE_TASK_ID			= 1;		-- 届任务ID
SCORE_TASK_ID			= 2;		-- 旗子积分 ID
TASK_USED_LINGPAI		= 3;		-- 当天使用个数任务变量
TASK_LINGPAI_DATE 		= 4;		-- 记录使用的日期任务变量
ELIMINATION_TASK_ID		= 5;		-- 记录各玩家进入了几强的任务ID（换积分用）
HONOR_CLASS				= 2;		-- 荣誉大类
HONOR_WULIN_TYPE		= 0;		-- 武林荣誉小类
_MODEL_OLD				= 1;		-- 以前的门派竞技模式
_MODEL_NEW				= 2;		-- 新的门派竞技模式
_MODEL_96_DAY_WEEK_2	= 3;		-- 开服96天，且是在周二的话
AWARD_TIMES				= 1;		-- 奖励倍数
LIMIT_DAYS_NEWMODEL		= 96;	-- 新模式需要限制服务器开服天数
N_ADD_MORE_ARENA_LIMIT	= 30;	-- 当剩余的人数超过限制是，多曾开一个比赛场地
N_BASE_EXP_AWORD_TIME	= 15;	-- 每采集一个箱子奖励的基准经验分钟时间

TB_COMPETITION_STAGE		=
{
	["camp"]	= "Chiến đội",
	["out"]		= "Đấu loại",
	["final"]	= "Chung kết",
};
-- 混战阶段荣誉、威望
MELEE_HONOR = 
{
	--比率	-- 荣誉	-- 威望
	{0.1,	50,		0,		50},
	{0.3,	40,		0,		40},
	{0.7,	30,		0,		30},
	{0.9,	20,		0,		20},
	{1,		10,		0,		10},
}

-- 刷不同箱子的人数段
PLAYER_COUNT_LIMIT	= 
{
	[1]	= 16, [2] = 50, [3] = 100, [4] = 150, [5] = 100000 --(无限大,假如因为人数>10W人而造成BUG，我们该庆祝了)
}

-- 淘汰赛刷箱子数量表
BOX_NUM =
{--	 比赛各强	散落宝箱数(2)	(3)		(4)		(5)
	{16, 			1,			2,		3,		4};			-- 16进8奖励
	{8, 			2,			4,		6,		8};			-- 8进4奖励
	{4,				4, 			8,		12,		16};		-- 4进2奖励
	{2,				8, 			16,		24,		30};		-- 2进1奖励
	{1,				8, 			16,		24,		30};		-- 冠军奖励
}

-- 对阵表
ELIMI_VS_TABLE =
{
	{1, 16},
	{8,	9},
	{4,	13},
	{5,	12},
	{2,	15},
	{7,	10},
	{3,	14},
	{6,	11},
}

-- 进入点与重生点
REV_POINT = 
{
	{1470, 3426},
	{1517, 3377},
	{1542, 3492},
	{1590, 3442}
};

tbDescrption_2S = 
{
	["KillInMelee"] = {	
		[_MODEL_OLD] = "Đánh bại <color=yellow>%s<color>, liên trảm <color=green>%d<color>",
		[_MODEL_NEW] = "Đánh bại <color=yellow>%s<color>, tích lũy <color=green>%d<color>"
    },
}

-- 宝石奖励
STONE_AWARD_TABLE = 
{
	{ 1, {{18,1,1317,1,nil,4}}},
	{ 2, {{18,1,1317,1,nil,4}}},
	{ 4, {{18,1,1317,1,nil,3}}},
	{ 8, {{18,1,1317,1,nil,2}}},
	{ 16,{{18,1,1317,1,nil,1}}},
}


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--- 老的门派竞技模式
preEnv.setfenv(1, preEnv.FactionBattle.tbDef_Old);	--设置当前环境为FactionBattle

MELEE_PROTECT_TIME		= 15;	-- 混战前保护时间 15秒
MIN_ATTEND_PLAYER		= 2;		-- 最小参加人数
TAKE_BOX_TIME			= 5;		-- 拾取奖励箱子的时间
REST_ACTITIVE_TIME		= 7*60;		-- 每次休息活动的时间 7分钟	
ANOUNCE_TIME			= 6*60;		-- 经过多久提示剩余时间
AWARD_ITEM_ID			= {1,78,1};	-- 箱子道具ID
NOTHING					= 0;		-- 活动未启动
SIGN_UP					= 1;  	-- 报名阶段
MELEE					= 2;		-- 混战阶段
MELEE_REST				= 0;		-- 休息时间
READY_ELIMINATION		= 4;		-- 淘汰准备阶段
ELIMINATION				= 5;		-- 淘汰赛阶段
CHAMPION_AWARD			= 6;		-- 冠军颁奖
END						= 7;		-- 结束

HIGHER_LEVEL_PLAYER		= 7
LIMIT_TO_ADD_ARENA		= 30
CAMP_RED				= 1;
CAMP_BLUE				= 2;
MELEE_END_ANOUNCE_TIME	= 120		-- 混战结束后，等待多长时间提醒淘汰赛的开始
CHAMPION_AWARD_COUNT	= 4;			-- 冠军需要点NPC的次数
CHAMPION_AWARD_CD_TIME	= 30;		-- 冠军点击NPC的CD时间(单位为秒)
MELEE_COUNT				= 4;			-- 晋级或混战次数
PERCENTAGE				= 1			-- 积分比例		积分 = 重伤人数 * 积分比例
PERCENTAGE_AWORD		= 0.1		-- 积分提成		当阵营胜利后，所在阵营的玩家积分可以提成
-- 自由PK重新投入战斗时间表
RETURN_TO_MELEE_TIME = 
{	-- 死亡次数			等待时间
		[1] = 			10,
		[2] = 			20,
		[3] = 			40,
		[4] = 			60,
}

-- 注意：奖励会叠加，各个奖励是上个奖励之后再加上去的
AWARD_TABLE = 
{--		心得		威望		门派声望	额外奖励（X分钟经验、X个箱子）  股份基数	荣誉
	{	200000,		0,			160,		0,			0,		0,			0	},	-- 无杀人奖励
	{	100000,		0,			80,			0,			0,		0,			0	},	-- 有杀人奖励
	{	100000,		6,			110,		90,			1,		100,		40	},	-- 晋级16强奖励
	{	200000,		6,			50,			120,		2,		100,		10	},	-- 16进8奖励
	{	200000,		10,			100,		180,		4,		300,		10	},	-- 8进4奖励
	{	0,			0,			0,			180,		4,		0,			20	},	-- 4进2奖励
	{	200000,		10,			100,		240,		8,		500,		20	},	-- 2进1奖励
	{	0,			0,			0,			0,			0,		0,			0	},	-- 冠军奖励
}	

if (bXpOpen == 1) then
	STATE_TRANS	=
	{
	--	 状态 					定时时间				时间到回调函数(函数返回0表示不在继续定时，结束活动)
		{SIGN_UP, 				10 * 60, 				"StartMelee"		},		-- 报名定时
		{MELEE,					6 * 60,					"RestartMelee"		},		-- 混战定时
		{MELEE,					6 * 60,					"RestartMelee"		},		-- 混战定时
		{MELEE,					6 * 60,					"RestartMelee"		},		-- 混战定时
		{MELEE,					6 * 60,					"RestartMelee"		},		-- 混战定时
		{MELEE,					6 * 60,					"EndMelee"			},		
		{READY_ELIMINATION,		3 * 60,					"StartElimination"	}, 		-- 淘汰赛准备
		{ELIMINATION,			7 * 60,					"EndElimination"	}, 		-- 淘汰赛1阶	决出8强
		{READY_ELIMINATION,		7 * 60,					"StartElimination"	}, 		-- 淘汰赛准备
		{ELIMINATION,			7 * 60,					"EndElimination"	}, 		-- 淘汰赛2阶	决出4强
		{READY_ELIMINATION,		7 * 60,					"StartElimination"	}, 		-- 淘汰赛准备
		{ELIMINATION,			7 * 60,					"EndElimination"	}, 		-- 淘汰赛3阶	决出2强
		{READY_ELIMINATION,		7 * 60,					"StartElimination"	}, 		-- 淘汰赛准备
		{ELIMINATION,			7 * 60,					"EndElimination"	}, 		-- 淘汰赛4阶	冠军
		{CHAMPION_AWARD,		10 * 60,				"EndChampionAward"	}, 		-- 冠军奖励
		{END}
	};
else
	STATE_TRANS	=
	{
	--	 状态 					定时时间				时间到回调函数(函数返回0表示不在继续定时，结束活动)
		{SIGN_UP, 				5 * 60, 				"StartMelee"		},		-- 报名定时
		{MELEE,					5 * 60,					"RestartMelee"		},		-- 混战定时
		{MELEE,					5 * 60,					"RestartMelee"		},		-- 混战定时
		{MELEE,					5 * 60,					"RestartMelee"		},		-- 混战定时
	--	{MELEE,					6 * 60,					"RestartMelee"		},		-- 混战定时
		{MELEE,					5 * 60,					"EndMelee"			},		
		{READY_ELIMINATION,		3 * 60,					"StartElimination"	}, 		-- 淘汰赛准备
		{ELIMINATION,			7 * 60,					"EndElimination"	}, 		-- 淘汰赛1阶	决出8强
		{READY_ELIMINATION,		7 * 60,					"StartElimination"	}, 		-- 淘汰赛准备
		{ELIMINATION,			7 * 60,					"EndElimination"	}, 		-- 淘汰赛2阶	决出4强
		{READY_ELIMINATION,		7 * 60,					"StartElimination"	}, 		-- 淘汰赛准备
		{ELIMINATION,			7 * 60,					"EndElimination"	}, 		-- 淘汰赛3阶	决出2强
		{READY_ELIMINATION,		7 * 60,					"StartElimination"	}, 		-- 淘汰赛准备
		{ELIMINATION,			7 * 60,					"EndElimination"	}, 		-- 淘汰赛4阶	冠军
		{CHAMPION_AWARD,		10 * 60,				"EndChampionAward"	}, 		-- 冠军奖励
		{END}
	};
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 新模式下的定义
preEnv.setfenv(1, preEnv.FactionBattle.tbDef_New);

SZ_BOX_POINT			= "baoxiang";
N_BAOXIANG_BASE			= 0;
N_BAOXIANG_MAX			= 8;

SZ_ARENA_POINT			= "zhenying";
N_ZHENYING_BASE			= 1;
N_ZHENYING_MAX			= 8;
N_MAX_BOX_NUMBER		= 200;		-- 最大允许的箱子个数
N_BOX_PERCENT			= 0.5;		-- 刷箱子的比例，和有效玩家的比例
N_BOX_EXSIT_TIME		= 20;		-- 箱子的存在时间
N_BOX_INTERVAL_TIME		= 40;		-- 箱子的间隔时间
MIN_ATTEND_PLAYER		= 2;		-- 最小参加人数
MELEE_PROTECT_TIME		= 10;		-- 混战前保护时间 10秒
MELEE_RESTART_PROTECT	= 10;		-- 混战重分场地后保护时间 10秒
TAKE_BOX_TIME			= 2;			-- 拾取奖励箱子的时间
REST_ACTITIVE_TIME		= 7*60;		-- 每次休息活动的时间 7分钟	

ANOUNCE_TIME			= 6*60;		-- 经过多久提示剩余时间

AWARD_ITEM_ID			= {1,78,2};	-- 箱子道具ID

NOTHING					= 0;		-- 活动未启动
SIGN_UP					= 1;  	-- 报名阶段
MELEE					= 2;		-- 混战阶段
MELEE_REST				= 3;		-- 休息时间
READY_ELIMINATION		= 4;		-- 淘汰准备阶段
ELIMINATION				= 5;		-- 淘汰赛阶段
CHAMPION_AWARD			= 6;		-- 冠军颁奖
END						= 7;		-- 结束


HIGHER_LEVEL_PLAYER		= 7
LIMIT_TO_ADD_ARENA		= 30			-- 当分组时，剩余人数超过这个值时，将会多增加一个场地比赛晋级赛
MELEE_TIME_LENGTH		= 180 		-- 单位秒
CAMP_RED				= 1;			-- 红队
CAMP_BLUE				= 2;			-- 蓝队
MELEE_END_ANOUNCE_TIME	= 120		-- 混战结束后，等待多长时间提醒淘汰赛的开始
CHAMPION_AWARD_COUNT	= 4;			-- 冠军需要点NPC的次数
CHAMPION_AWARD_CD_TIME	= 30;		-- 冠军点击NPC的CD时间(单位为秒)
MELEE_COUNT				= 4;			-- 晋级或混战次数
PERCENTAGE				= 10			-- 积分比例		积分 = 重伤人数 * 积分比例
PERCENTAGE_AWORD		= 0.1		-- 积分提成		当阵营胜利后，所在阵营的玩家积分可以提成

TB_TITLE	=
{
	[CAMP_RED] = {"Phe Ác", "purple"},
	[CAMP_BLUE] = {"Phe Thiện", "blue"},
};

-- 晋级赛中死亡的等待时间
RETURN_TO_MELEE_TIME = 
{	-- 死亡次数			等待时间
		[1] = 			10,
}

-- 淘汰赛奖励
ELIMINATION_REST_AWORD = 
{
	-- 宝箱的次数	刷宝箱场次		是否立即刷
	{3, 			8,		1},		-- 16进8
	{3,			4,		1},		-- 8进4
	{5,			2,		1},		-- 4进2
	{1,			1,		1},		-- 决赛
};

-- 注意：奖励会叠加，各个奖励是上个奖励之后再加上去的,奖励表，只用进入16强的人才能够有奖励好领的
AWARD_TABLE = 
{--		心得		威望		门派声望	额外奖励（X分钟经验、X个箱子）  股份基数	荣誉
	{	200000,		0,			160,	0,			0,			0,			0	},	-- 无杀人奖励
	{	100000,		0,			80,		0,			0,			0,			0	},	-- 有杀人奖励
	{	100000,		6,			110,	90,			3,			100,		40	},	-- 晋级16强奖励
	{	200000,		6,			50,		120,		4,			100,		10	},	-- 16进8奖励
	{	200000,		10,			100,	180,		5,			300,		10	},	-- 8进4奖励
	{	0,			0,			0,		240,		7,			0,			20	},	-- 4进2奖励
	{	200000,		10,			100,	240,		8,			500,		20	},	-- 2进1奖励
	{	0,			0,			0,		0,			0,			0,			0	},	-- 冠军奖励
}

-- 状态转换
STATE_TRANS	=
{
--	 状态 					定时时间				时间到回调函数(函数返回0表示不在继续定时，结束活动)
	{SIGN_UP, 				5*60,				"StartMelee_New"		},		-- 报名定时
	{MELEE,					190,				"StopAMelee"			},		-- 混战定时
	{MELEE_REST,			60,					"ReStartMelee_New"		},
	{MELEE,					190,				"StopAMelee"			},		-- 混战定时
	{MELEE_REST,			60,					"ReStartMelee_New"		},
	{MELEE,					190,				"StopAMelee"			},		-- 暂停混战
	{MELEE_REST,			60,					"ReStartMelee_New"		},		-- 混战定时
	{MELEE,					190,				"StopAMelee"			},		-- 暂停混战
	{READY_ELIMINATION,		180,				"StartElimination"		}, 		-- 淘汰赛准备
	{ELIMINATION,			270,				"EndElimination"		}, 		-- 淘汰赛1阶	决出8强
	{READY_ELIMINATION,		120,				"StartElimination"		}, 		-- 淘汰赛准备
	{ELIMINATION,			270,				"EndElimination"		}, 		-- 淘汰赛2阶	决出4强
	{READY_ELIMINATION,		120,				"StartElimination"		}, 		-- 淘汰赛准备
	{ELIMINATION,			270,				"EndElimination"		}, 		-- 淘汰赛3阶	决出2强
	{READY_ELIMINATION,		180,				"StartElimination"		}, 		-- 淘汰赛准备
	{ELIMINATION,			330,				"EndElimination"		}, 		-- 淘汰赛4阶	冠军
	{CHAMPION_AWARD,		300,				"EndChampionAward"		}, 		-- 冠军奖励
	{END}
};

AWARD_TIMES=1;
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
preEnv.setfenv(1, preEnv);	--恢复全局环境

-- 开启在周2，4
FactionBattle.OPEN_WEEK_DATE = {2, EventManager.IVER_nSecFactionDay};

function FactionBattle:SetDefByMode(nMode)
	local tbDef;
	if nMode == FactionBattle._MODEL_OLD or nMode == FactionBattle._MODEL_96_DAY_WEEK_2 then
		tbDef = FactionBattle.tbDef_Old;
		FactionBattle.FACTIONBATTLE_MODLE = FactionBattle._MODEL_OLD;
	elseif nMode == FactionBattle._MODEL_NEW then
		tbDef = FactionBattle.tbDef_New;
		FactionBattle.FACTIONBATTLE_MODLE = FactionBattle._MODEL_NEW;
	end
	Dbg:WriteLog(GetLocalDate("%Y\\%m\\%d  %H:%M:%S"), "设置门派竞技模式",nMode);
	assert(tbDef, "没有指定的模式啊")
	for k,v in pairs(tbDef) do
		self[k] = v;
	end
	
	if nMode == FactionBattle._MODEL_96_DAY_WEEK_2 then
		self.AWARD_TABLE = self.tbDef_New.AWARD_TABLE;		-- 开服96天之后，和以前的只是奖励变成了新的
		self.AWARD_ITEM_ID = self.tbDef_New.AWARD_ITEM_ID;
	end

	return 0;
end
