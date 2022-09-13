-- castlefight_def.lua
-- zhouchenfei
-- 定义文件
-- 2010/11/6 13:53:08

Require("\\script\\player\\playerhonor.lua");
if not MODULE_GAMECLIENT then
	Require("\\script\\console\\console_def.lua");
end

CastleFight.DEF_EVENT_TYPE = Console.DEF_CASTLEFIGHT;
CastleFight.DEF_EVENT_FILE	= "\\setting\\mission\\castlefight\\castlefight_cfg.txt";
CastleFight.DEF_AWARD_FILE	= "\\setting\\mission\\castlefight\\castlefight_award.txt";

CastleFight.DEF_PLAYER_LEVEL = 60;
CastleFight.DEF_READY_TIME_ENTER	= Env.GAME_FPS * 10;

CastleFight.TSK_GROUP			= 2146;
CastleFight.TSK_ATTEND_TOTAL	= 1;
CastleFight.TSK_ATTEND_COUNT	= 2;
CastleFight.TSK_ATTEND_EXCOUNT	= 3;
CastleFight.TSK_ATTEND_DAY		= 4;
CastleFight.TSK_MONEY 	 		= 5;	--玩家获得的军饷
CastleFight.TSK_ATTEND_AWARD	= 6;

CastleFight.TSK_ATTEND_WIN		= 7;
CastleFight.TSK_ATTEND_TIE		= 8;
CastleFight.TSK_AWARD_FINISH	= 9;	--最终奖励
CastleFight.TSK_NEWYEAR_LIANHUA_DAY		= 10;
CastleFight.TSK_NEWYEAR_LIANHUA_COUNT	= 11;
CastleFight.TSK_UPDATE_ITEM_TIME	= 12;
CastleFight.TSK_USE_ITEM_TIMES	= 13; -- 每天可以使用夜岚明灯的次数

CastleFight.DEF_PLAYER_KEEP_MAX = 7;	-- 最多能累计7场
CastleFight.DEF_MAX_TOTAL_NUM		= 48; -- 一个玩家最多能参加42场
CastleFight.DEF_CHANGENUME	= 3;

CastleFight.SNOWFIGHT_ITEM_EXCOUNT	= {18, 1, 476, 1};

CastleFight.DEF_POINT_WIN	= {5,4,3,3};			--胜获得积分
CastleFight.DEF_POINT_TIE	= {3,2,2,1};			--平获得积分
CastleFight.DEF_POINT_LOST	= {3,2,2,1};			--负获得积分

CastleFight.DEF_PLAYER_COUNT	= 1;
CastleFight.DEF_HONOR_CLASS		= PlayerHonor.HONOR_CLASS_LADDER2;

CastleFight.WAIT_TIME_FPS				= 10 * Env.GAME_FPS;	 
CastleFight.MATCH_TIME_FPS				= 580 * Env.GAME_FPS;	-- 比赛时间10min
CastleFight.ENDREST_TIME_FPS			= 120 * Env.GAME_FPS;	-- 赛后休息时间30s

CastleFight.tbMisEventList = 
{
		{"startrest", 		CastleFight.WAIT_TIME_FPS, 			"BeginPlay"},
		{"endgame", 		CastleFight.MATCH_TIME_FPS, 		"EndPlay"},
		{"endrest", 		CastleFight.ENDREST_TIME_FPS, 		"EndGame"},
};

CastleFight.TRANSFORM_SKILL_ID 		= 1800;	 	-- 变身技能
CastleFight.FINAL_SKILL_ID			= 1802;		--大招
CastleFight.FINAL_SKILL_TIMES 		= 1;		-- 只能使用一次

--CastleFight.TRANSFORM_SKILL_ID		= 1475;

--CastleFight.WUDI_SKILL_ID			= 1475; --1475;		--无敌 --1166 堡垒
					
CastleFight.SYS_ADDMONEY_INTERVAL = 10;   -- n秒 发一次钱
CastleFight.SYS_ADDMONEY_NUM	  = 10;	  -- 一次发n钱
CastleFight.SYS_ADDMONEY_START	  = 60;   --系统开始给玩家的军饷数目
CastleFight.WIN_ADD_SCORE_TIMES	  = 0.5;   --个人赛推到建筑所加积分

--道具表
CastleFight.ITEM_LIST = 
{
	[1] = {18,1,1066,1,0},
	[2] = {18,1,1067,1,0},
	[3] = {18,1,1068,1,0},
	[4] = {18,1,1069,1,0},
	[5] = {18,1,1070,1,0},
	[6] = {18,1,1072,1,0},
	[7] = {18,1,1071,1,0},
	[8] = {18,1,1074,1,0},
};

-- 快捷栏对应
CastleFight.ITEM_TO_SHORTCUT = 
{
	[1] = 1,
	[2] = 2,
	[3] = 3,
	[4] = 4,
	[5] = 5,
	[6] = 6,
	[7] = 7,
	[8] = 10,
};

--技能表
--CastleFight.SKILL_LIST = 

--BUFF表 TODO
CastleFight.BUFF_LIST =
{
	[1] = {nId = 1, nLevel = 2 , nSec = 5, nNeedMoney = 0,szName = "", szDesc = "",},
}

CastleFight.BOSS_POS = 
{
	[1] = {51072/32,104000/32},
	[2] = {54400/32,100544/32},
};
CastleFight.NPC_BOSS_ID  = 7200;

CastleFight.TEMP_MAP_ID  = 1863;
CastleFight.TEMP_MAP_ID2  = 2105;	--趣味竞技

CastleFight.AWARD_FINISH = 
{
	{1,		{18,1,512,1,30}	},
	{10,	{18,1,512,1,8}	},
	{50,	{18,1,114,10,1}	},
	{100,	{18,1,114,9,2}	},
	{500,	{18,1,114,9,1}	},
}

CastleFight.WINNER_BOX		={	
								{18, 1, 1075, 1},
								{18, 1, 1076, 1},
								{18, 1, 1077, 1},
								{ 20000 },
							};			--获胜队伍奖励宝箱

CastleFight.WINNER_AWARD_ID = { 1, 1, 2, 2 };

CastleFight.LOST_AWARD_ID = { 2, 3, 4, 4 };

CastleFight.ITEM_TIMEOUT = 1800;	-- 活动道具过期时间

CastleFight.GAMOVER_TYPE_DEC =
{
	["win"] = {[1] = "win_score", [2] = "win_down"},
	["lost"] = {[1] = "lost_score", [2] = "lost_down"},	
};

CastleFight.DELETE_XUANJING_LEVEL	 = 4;