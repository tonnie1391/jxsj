-- 文件名  : beautyhero_def.lua
-- 创建者  : zounan
-- 创建时间: 2010-09-13 16:00:13
-- 描述    : 巾帼英雄赛 定义

BeautyHero = BeautyHero or {};

--直接用门派竞技的配置文件 TODO
BeautyHero.ARENA_RANGE		= "\\setting\\factionbattle\\arena_range.txt";
BeautyHero.ARENA_POINT		= "\\setting\\factionbattle\\arena_point.txt";
BeautyHero.BOX_POINT		= "\\setting\\factionbattle\\box_point.txt";
BeautyHero.QIQI_POINT		= "\\setting\\beautyhero\\qiqi.txt";
BeautyHero.GUANJUNBAOXIANG_POINT		= "\\setting\\beautyhero\\guanjunbaoxiang.txt";
	
BeautyHero.MAX_ATTEND_PLAYER			= 400; 		-- 最大参赛人数
BeautyHero.MIN_ATTEND_PLAYER			= 8;		-- 最小参加人数 		
BeautyHero.MIN_RESTART_MELEE			= 8;		-- 最少分场人数	
BeautyHero.PLAYER_PER_ARENA				= 50;		-- 每个混战场所容纳的最大人数
BeautyHero.MAX_ARENA					= 8;		-- 最大混战场个数
BeautyHero.MELEE_PROTECT_TIME			= 15;		-- 混战前保护时间 15秒
BeautyHero.MELEE_RESTART_PROTECT		= 10;		-- 混战重分场地后保护时间 10秒
BeautyHero.ELIMI_PROTECT_TIME			= 30;		-- 淘汰赛保护时间 30秒
BeautyHero.END_DELAY					= 5;		-- 战区剩余唯一一人时要传出的传送延迟
BeautyHero.ADD_BOX_DELAY				= 5; 		-- 决出胜负后宝箱刷出延迟时间

BeautyHero.TAKE_BOX_TIME				= 5;		-- 拾取奖励箱子的时间
BeautyHero.REST_ACTITIVE_TIME			= 7*60;		-- 每次休息活动的时间 7分钟	
BeautyHero.FLAG_NPC_TAMPLATE_ID			= 7020;		-- 冠军旗子NPC模板ID
BeautyHero.FLAG_X						= 1575;		-- 冠军旗子坐标
BeautyHero.FLAG_Y						= 3375;		-- 冠军旗子坐标
BeautyHero.FLAG_EXIST_TIME				= 10*60;		-- 冠军旗子生存期			
BeautyHero.ANOUNCE_TIME					= 4*60;		-- 经过多久提示剩余时间		
BeautyHero.YANHUA_SKILL_ID				= 391;		-- 烟花的技能ID
BeautyHero.AWARD_ITEM_ID				= {1,78,1};	-- 箱子道具ID
BeautyHero.GOUHUO_NPC_ID				= 2728;		-- 多人篝火ID
BeautyHero.GOUHUO_EXISTENTIME 			= 600; 		-- 篝火持续时间
BeautyHero.GOUHUO_BASEMULTIP			= 400; 		-- 篝火获得经验倍率百分比
BeautyHero.TITLE_GROUP					= 4;		-- 冠军称号组
BeautyHero.TITLE_ID						= 1;		-- 称号ID
BeautyHero.MIN_LEVEL					= 50;		-- 参加等级下限
--BeautyHero.MAX_LEVEL					= 100; 		-- 参加等级上限


BeautyHero.NOTHING						= 0;		-- 活动未启动
BeautyHero.SIGN_UP						= 1;  		-- 报名阶段
BeautyHero.MELEE						= 2;		-- 混战阶段
BeautyHero.MATCH_REST					= 3;		-- 混战到淘汰赛之间的休息阶段
BeautyHero.READY_ELIMINATION			= 4;		-- 淘汰准备阶段
BeautyHero.ELIMINATION					= 5;		-- 淘汰赛阶段
BeautyHero.CHAMPION_AWARD				= 6;		-- 冠军颁奖
BeautyHero.END							= 7;		-- 结束

-- 自由PK重新投入战斗时间表
BeautyHero.RETURN_TO_MELEE_TIME = 
{	-- 死亡次数			等待时间
		[1] = 			5,
		[2] = 			10,
		[3] = 			15,
		[4] = 			20,
		[5] = 			30,
		[6] = 			50,
		[7] = 			60,	
}

-- 淘汰赛刷箱子数量表
BeautyHero.BOX_NUM =
{--	 比赛各强	散落宝箱数(2)	(3)		(4)		(5)
	{16, 			1,			2,		3,		4};			-- 16进8奖励
	{8, 			2,			4,		6,		8};			-- 8进4奖励
	{4,				4, 			8,		12,		16};		-- 4进2奖励
	{2,				8, 			16,		24,		30};		-- 2进1奖励
	{1,				8, 			16,		24,		30};		-- 冠军奖励
}

-- 对阵表
BeautyHero.ELIMI_VS_TABLE =
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

BeautyHero.emMATCHTYPE_SERIES 	= 1;   --同系单人赛
BeautyHero.emMATCHTYPE_MELEE	= 2;   -- 混战

BeautyHero.emPLAYERTYPE_MATCH 	= 1;   --参赛
BeautyHero.emPLAYERTYPE_WATCH 	= 2;   --观看

BeautyHero.emMATCHSERVER_LOCAL  = 1;   -- 本服
BeautyHero.emMATCHSERVER_GLOBAL = 2;   -- 全局服


BeautyHero.HONOR_SERIES =
{
	[1] = 1,		-- 混战
	[2] = 1,		-- 16强
	[3] = 2,		-- 8强
	[4] = 2,		-- 4强
	[5] = 2,		-- 2强
	[6] = 2,		-- 冠军
}

BeautyHero.HONOR_MELEE =
{
	[1] = 1,		-- 混战
	[2] = 2,		-- 16强
	[3] = 3,		-- 8强
	[4] = 3,		-- 4强
	[5] = 3,		-- 2强
	[6] = 3,		-- 冠军
}

BeautyHero.HONOR_TABLE = 
{
	[1] = BeautyHero.HONOR_SERIES,
	[2] = BeautyHero.HONOR_MELEE;
};


-- 进入点与重生点
BeautyHero.REV_POINT = 
{
	{math.floor(48480/32), math.floor(109152/32)},
	{math.floor(48800/32), math.floor(110144/32)},
	{math.floor(49408/32), math.floor(109344/32)},
	{math.floor(49728/32), math.floor(110432/32)},
};


BeautyHero.STATE_TRANS	= 	--mission时间表
{	
--	{BeautyHero.SIGN_UP, 		Env.GAME_FPS * 3 * 60, 				"StartMelee"		},		
	{BeautyHero.SIGN_UP, 		Env.GAME_FPS * 30 * 60, 				"StartMelee"		},		-- 报名定时
	{BeautyHero.MELEE,			Env.GAME_FPS * 4 * 60,					"RestartMelee"		},		-- 混战定时
	{BeautyHero.MELEE,			Env.GAME_FPS * 4 * 60,					"RestartMelee"		},		-- 混战定时
	{BeautyHero.MELEE,			Env.GAME_FPS * 4 * 60,					"RestartMelee"		},		-- 混战定时
	{BeautyHero.MELEE,			Env.GAME_FPS * 4 * 60,					"EndMelee"			},		
	{BeautyHero.MATCH_REST,		Env.GAME_FPS * 9 * 60,					"StartElimination"	}, 		-- 淘汰赛准备 25:00
	{BeautyHero.ELIMINATION,		Env.GAME_FPS * 6 * 60,				"EndElimination"	}, 		-- 淘汰赛1阶	决出8强 31:00
	{BeautyHero.READY_ELIMINATION,	Env.GAME_FPS * 5 * 60,				"StartElimination"	}, 		-- 淘汰赛准备36:00
	{BeautyHero.ELIMINATION,		Env.GAME_FPS * 6 * 60,				"EndElimination"	}, 		-- 淘汰赛2阶	决出4强 42:00
	{BeautyHero.READY_ELIMINATION,	Env.GAME_FPS * 5 * 60,				"StartElimination"	}, 		-- 淘汰赛准备 47：00
	{BeautyHero.ELIMINATION,		Env.GAME_FPS * 6 * 60,				"EndElimination"	}, 		-- 淘汰赛3阶	决出2强 53:00
	{BeautyHero.READY_ELIMINATION,	Env.GAME_FPS * 5 * 60,				"StartElimination"	}, 		-- 淘汰赛准备 58:00
	{BeautyHero.ELIMINATION,		Env.GAME_FPS * 6 * 60,				"EndElimination"	}, 		-- 淘汰赛4阶	冠军 2104
	{BeautyHero.CHAMPION_AWARD,		Env.GAME_FPS * 56 * 60,				"EndChampionAward"	}, 		-- 冠军奖励
	{BeautyHero.END}
};






-- 按时间从小到大排序
BeautyHero.MATCH_STATE =
{
	{nDate = 20101019, nType = BeautyHero.emMATCHTYPE_SERIES,nServer = BeautyHero.emMATCHSERVER_LOCAL},
	{nDate = 20101023, nType = BeautyHero.emMATCHTYPE_SERIES,nServer = BeautyHero.emMATCHSERVER_LOCAL},
	{nDate = 20101026, nType = BeautyHero.emMATCHTYPE_MELEE, nServer = BeautyHero.emMATCHSERVER_LOCAL},
	{nDate = 20101028, nType = BeautyHero.emMATCHTYPE_MELEE, nServer = BeautyHero.emMATCHSERVER_LOCAL},
	{nDate = 20101030, nType = BeautyHero.emMATCHTYPE_MELEE, nServer = BeautyHero.emMATCHSERVER_LOCAL},
	{nDate = 20101031, nType = BeautyHero.emMATCHTYPE_MELEE, nServer = BeautyHero.emMATCHSERVER_LOCAL},
	{nDate = 20101102, nType = BeautyHero.emMATCHTYPE_MELEE, nServer = BeautyHero.emMATCHSERVER_GLOBAL},													
};

BeautyHero.GLOBAL_MATCHDATE = 20101102;
BeautyHero.TIME_BEGIN		= 1930;
BeautyHero.TIME_END			= 2200;

BeautyHero.TIME_GLOBAL_AWARD_BEGIN = 20101102;
BeautyHero.TIME_GLOBAL_AWARD_BEGIN_HOUR = 2130;
BeautyHero.TIME_GLOBAL_AWARD_END   = 20101114;



BeautyHero.MAX_MATCHTIMES	= 2;  
BeautyHero.GLOBAL_RANKLIMIT = 10;
BeautyHero.GLOBAL_MEIGUILIMIT = 199;

BeautyHero.TSK_GLOBAL_GROUP			= 2141;
BeautyHero.TSK_GLOBAL_MATCHTYPE		= 516;  -- 1是比赛 2是参观

-- 本服任务变量 -- 一周参加两次
BeautyHero.TSK_MATCH_WEEK		= 517;  
BeautyHero.TSK_MATCH_TIMES		= 518;  

BeautyHero.TSK_IS_GETMATCH_AWARD	= 519;  --是否领取了比赛奖励
BeautyHero.TSK_IS_GETREST_AWARD		= 520;  --是否领取了活动奖励


--跨服 能带回的玩家变量
BeautyHero.TSK_GB_PLAYER_GROUP	= 4;  
BeautyHero.TSK_GB_PLAYER_MATCH_AWARD	= 1;    --  玩家比赛奖励
BeautyHero.TSK_GB_PLAYER_REST_AWARD		= 2;	--  玩家活动奖励

--同系有5张地图
BeautyHero.MAP_SERIES =
{
	[1] = 1806,			--nSeries 表示五行
	[2] = 1807,
	[3] = 1808,
	[4] = 1809,
	[5] = 1810,
};

--混战只有1张地图 
BeautyHero.MAP_MELEE = 
{
	[1] = 1811,
};

BeautyHero.MATCH_SCORE = 
{
	[1] = 1806,
};


BeautyHero.MEIGUI_LIMIT = 10;		 --进入PK赛的条件 必须要投玫瑰				-- 
BeautyHero.ITEM_VOTE	  = {18,1,1037,1};
BeautyHero.ITEM_CARD	  = {18,1,1036,1};
BeautyHero.ITEM_BAOXIANG  = {18,1,1039,1};
BeautyHero.ITEM_MOBANG	  = {18,1,1038,1};
BeautyHero.TIME_CARD	  = 5;		-- 卡片有效期

BeautyHero.COIN_BOX		  = 1000;	--活动产出宝箱的绑金价值 本服领取用

BeautyHero.TICKETS_MAX = 100000; -- 10w
BeautyHero.TICKETS_MIN = 100;	  -- 100

BeautyHero.VOTE_RETURN_MAX = 10;	  -- 投票最高10倍返还（非冠军）

BeautyHero.AWARD_VOTER = 
{
	[0] = { nFacor = 0, 	szName = "十六强",nBoxNum = 1, tbBox = {18,1,1045,1},},
	[1] = { nFacor = 0.75,	szName = "八强",  nBoxNum = 1, tbBox = {18,1,1045,2},},
	[2] = { nFacor = 1.2,	szName = "四强",  nBoxNum = 1, tbBox = {18,1,1045,3},},
	[3] = { nFacor = 1.8,	szName = "亚军",  nBoxNum = 1, tbBox = {18,1,1045,4},},
	[4] = { nFacor = 3,		szName = "冠军",  nBoxNum = 1, tbBox = {18,1,1045,5},},
};

--跨服比赛奖励
BeautyHero.GLOBAL_MATCH_AWARD = 
{
	[1] = {   -- 16强
		{ tbItemId = {21,8,4,1},	nCount = 1,},
		{ tbItemId = {1,13,117,1},  nCount = 1,},
		{ tbItemId = {18,1,915,1},  nCount = 4,nBind = 0,},
	--	{ tbItemId = {18,1,915,1},  nCount = 4,}, tbItemId
		},
		
	[2] = {   -- 8强
		{ tbItemId = {21,8,4,1},	nCount = 1,},
		{ tbItemId = {1,13,117,1},  nCount = 1,},
		{ tbItemId = {18,1,915,1},  nCount = 8,nBind = 0,},
		},	
		
	[3] = {   -- 4强
		{ tbItemId = {21,9,6,1}, 	nCount = 1,},
		{ tbItemId = {1,13,117,1},  nCount = 1,},
		{ tbItemId = {18,1,915,1},  nCount = 24,nBind = 0,},
		},				
		
	[4] = {   -- 2强
		{ tbItemId = {21,9,6,1},	nCount = 1,},
		{ tbItemId = {1,13,117,1},  nCount = 1, },
		{ tbItemId = {18,1,915,1},  nCount = 32,nBind = 0,},
		},				
		
	[5] = {   -- 1强
		{ tbItemId = {21,9,6,1},	nCount = 1,},
		{ tbItemId = {1,13,116,1},  nCount = 1,},
		{ tbItemId = {18,1,915,1},  nCount = 48, nBind = 0,},
		},		

};

--跨服比赛奖励光环
BeautyHero.GLOBAL_MATCH_AWARD_TITLE = 
{
	[1] = {6,46,5,9}, -- 16强		
	[2] = {6,46,5,9},   -- 8强		
	[3] = {6,46,5,9},   -- 4强
	[4] = {6,46,5,9},   -- 2强		
	[5] = {6,46,6,10},   -- 1强
};

BeautyHero.NPCID_QIQI				= 7019;
BeautyHero.NPCID_GUANJUNBAOXIANG	= 7021;


function BeautyHero:GetMatchIndex()
	local nIndex = 0;
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	for _nIndex, tbInfo  in ipairs(BeautyHero.MATCH_STATE) do
		if nCurDate < tbInfo.nDate then
			break;
		elseif nCurDate == tbInfo.nDate then
			nIndex = _nIndex;
			break;
		end		
	end		
	return nIndex;
end
