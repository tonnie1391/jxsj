 -- 文件名  : treasuremap2_def.lua
-- 创建者  : zounan
-- 创建时间: 2010-08-09 11:37:50
-- 描述    : 

Require("\\script\\achievement_st\\achievement_define_st.lua"); -- 师徒成就
TreasureMap2.INSTANCE_LIMIT  = 20; 				--每台服务器开启副本上限
TreasureMap2.DYNMAP_LIMIT	 = 40; 				-- 每台服务器藏宝图申请动态地图上限
TreasureMap2.DEFAULT_ITEM	 = {18,1,1000,1};   -- 通用令牌

TreasureMap2.DEFALUT_LEVEL_ITEM	= {					-- 星级通用令牌
	{18,1,1019,1},
	{18,1,1019,2},
	{18,1,1019,3},
	};

--玩家每天进入藏宝图副本的上限
TreasureMap2.TIMES_LIMIT	= 10;
TreasureMap2.TSK_GROUP  	= 2136;

TreasureMap2.TSK_PLAYTIMES 	= 1;
TreasureMap2.TSK_PLAYDATE  	= 2;

TreasureMap2.TSK_ADDLINGPAI_WEEK  = 8;
TreasureMap2.TSK_ADDLINGPAI_KIN   = 9;
TreasureMap2.TSK_ADDLINGPAI_DAY	  = 12;

TreasureMap2.nBiluogu_Horse_Count = 2;		-- 碧落谷马牌日产出数量

-- 藏定图教育任务相关
TreasureMap2.TASK_MAIN_ID	= "21C";
TreasureMap2.TASK_SUB_ID	= "2F6";
TreasureMap2.TASK_STEP		= 1;
TreasureMap2.TSK_GROUP_TASK_MAIN	= 1025;
TreasureMap2.TSK_GROUP_TASK_SUB		= 90;

TreasureMap2.MSG_REMAIN  	= "<color=green>Thời gian còn lại: <color=white>%s\n";
TreasureMap2.MSG_INSTANCE  	= "<color=green>%s độ khó %d sao\nĐiểm tích lũy: <color=white>%s\n";

--
TreasureMap2.DEF_MAX_ENTER  = 6;   --一张副本最多6个人
TreasureMap2.INSTANCE_TIME  = 2*3600; --副本时间 2h
TreasureMap2.CANCLOSE_TIME  = 10;	-- 10分钟之后才能关闭副本
TreasureMap2.MISSION_ACTIVE_TIME = Env.GAME_FPS;
TreasureMap2.MISSION_COMPLETE_WAITING = 10;
TreasureMap2.IS_COMPLETE    = 
{
	[0] = "Hoàn thành",
	[1] = "Đang thực hiện",
};

-- 加伤害技能
TreasureMap2.SKILL_ID	   = 1651;
TreasureMap2.SKILL_LEVEL   = 
{
	[1] = 5,
	[2] = 16,  --15,
	[3] = 25,
};

TreasureMap2.LEVEL_RATE	= {1, 1.5, 2};      -- 分数的难度系数加成
TreasureMap2.SCORE_RATE	= 6;    			-- 战斗分与评价分转化
	
TreasureMap2.WEAK_RATE = {					-- 衰减 --先不做衰减
	[0] = 100,
	[1] = 100,
	[2] = 100,	
};	
TreasureMap2.YanHuaId  = 1650;
TreasureMap2.TSKGID	   = 2015;    	-- 任务的任务变量 
TreasureMap2.IS_OPEN   = 1;

TreasureMap2.TSK_INS_TBTASK = 
{
	--        主人ID，队友ID，主任务ID，队友主任务ID
	[254]	= {201, 301, "DB", "159"},	-- 疑冢
	[272]	= {202, 302, "DC", "15A"},	-- 大漠
	[287]	= {203, 303, "E0", "15B"},	-- 千琼
	[344]	= {204, 304, "12D", "15C"},	-- 万花
};

--以后可以考虑填成配置表
TreasureMap2.TEMPLATE_LIST = 
{
 	[1] = -- nIndex 同时也是TreasueId
	{
		nOpenState = 0,	--是否开启
 		szName = "Bách Niên Thiên Lao",
 		szInstanceInfoFile  = "\\setting\\task\\treasuremap2\\bainiantianlao\\info.txt",
 		szTrapPosFile 		= "\\setting\\task\\treasuremap2\\bainiantianlao\\trap.txt",
 		nTskGroupId 		  = 2136,
 		nTskInstanceLevelId	  = 3, 
 		nTemplateMapId		= 1737;				--地图模板ID
 		tbItem				= {18,1,995,1},		--
 		tbBirthPos			= {1613,3298},
 		tbNpcLevel			= {65,100,119},		--有些NPC是写在脚本里的所以要这样
 		nAchievementId		= Achievement_ST.FUBEN_BAINIANTIANLAO,
 		nBaseCount			= 4,				-- 一台服务器该副本的基本张数
 		tbTimeRate			=					-- 通关时间加成
 		{
 			[1] = {8 * 60,  25},
			[2] = {13 * 60, 20},
			[3] = {18 * 60, 15},
			[4] = {22 * 60, 10},
 		},
 		tbLevelItem		  = 					--不同的星级对应不同的令牌先写在这里吧
 		{
 			{18,1,995,2},
 			{18,1,995,3},
 			{18,1,995,4},
 		},
		tbXiaKeDailyItem	= {};
		tbTaskGroupId = {},
  	},	
 	[2] = 
	{
		nOpenState = 1,
 		szName = "Đào Chu Công Mộ Chủng",
 		szInstanceInfoFile  = "\\setting\\task\\treasuremap2\\taozhugongyizhong\\info.txt",
 		szTrapPosFile 		= "\\setting\\task\\treasuremap2\\taozhugongyizhong\\trap.txt",
 		nTskGroupId 		  = 2136,
 		nTskInstanceLevelId	  = 4, 
 		nTemplateMapId		= 1738;				--地图模板ID
 		tbItem				= {18,1,996,1},		--
 		tbBirthPos			= {1572,3172},
 		tbNpcLevel			= {75,100,119},		--有些NPC是写在脚本里的所以要这样
 		nAchievementId		= Achievement_ST.FUBEN_TAOZHUGONG,
  		tbTask				= {201, 301, "DB", "159"},	-- 疑冢
  		nBaseCount			= 4,				-- 一台服务器的基础数量		
   		tbTimeRate			=					-- 通关时间加成
 		{
 			[1] = {10 * 60,  25},
			[2] = {16 * 60, 20},
			[3] = {21 * 60, 15},
			[4] = {25 * 60, 10},
 		},
 			
  		tbLevelItem		  = 					--不同的星级对应不同的令牌先写在这里吧
 		{
 			{18,1,996,2},
 			{18,1,996,3},
 			{18,1,996,4},
 		},		
 		tbXiaKeDailyItem	= {};
 		tbTaskGroupId = {2203, 4},
  	},	
  	
   	[3] = 
	{
		nOpenState = 1,		
 		szName = "Đại Mạc Cổ Thành",
 		szInstanceInfoFile  = "\\setting\\task\\treasuremap2\\damogucheng\\info.txt",
 		szTrapPosFile 		= "\\setting\\task\\treasuremap2\\damogucheng\\trap.txt",
 		nTskGroupId 		  = 2136,
 		nTskInstanceLevelId	  = 5, 
 		nTemplateMapId		= 1739;				--地图模板ID
 		tbItem				= {18,1,997,1},		--
 		tbBirthPos			= {1546,3560},
 		tbNpcLevel			= {85,100,119},		--有些NPC是写在脚本里的所以要这样
 		nAchievementId		= Achievement_ST.FUBEN_DAMOGUCHENG,
 		nBaseCount			= 4,				-- 一台服务器的基础数量
 		tbTimeRate			=					-- 通关时间加成
 		{
 			[1] = {16 * 60,  25},
			[2] = {21 * 60, 20},
			[3] = {26 * 60, 15},
			[4] = {30 * 60, 10},
 		},
  		tbLevelItem		  = 					--不同的星级对应不同的令牌先写在这里吧
 		{
 			{18,1,997,2},
 			{18,1,997,3},
 			{18,1,997,4},
 		},		
 		tbTask				= {202, 302, "DC", "15A"},	-- 大漠
		tbXiaKeDailyItem	= 
		{
			[2] = {18, 1, 1232, 1},	
		};
		tbTaskGroupId = {2203, 5},
  	},	
  	
   	[4] = 
	{
		nOpenState = 1,
 		szName = "Vạn Hoa Cốc",
 		szInstanceInfoFile  = "\\setting\\task\\treasuremap2\\wanhuagu\\info.txt",
 		szTrapPosFile 		= "\\setting\\task\\treasuremap2\\wanhuagu\\trap.txt",
 		nTskGroupId 		  = 2136,
 		nTskInstanceLevelId	  = 6, 
 		nTemplateMapId		= 1741;				--地图模板ID
 		tbItem				= {18,1,999,1},		--
 		tbBirthPos			= {1565,3202},
 		tbNpcLevel			= {95,111,135},		--有些NPC是写在脚本里的所以要这样
 		nAchievementId		= Achievement_ST.FUBEN_WANHUA,
 		nBaseCount			= 4,				-- 一台服务器的基础数量
 	 	tbTimeRate			=					-- 通关时间加成
 		{
 			[1] = {10 * 60,  25},
			[2] = {16 * 60, 20},
			[3] = {21 * 60, 15},
			[4] = {25 * 60, 10},
 		}, 	
  		tbLevelItem		  = 					--不同的星级对应不同的令牌先写在这里吧
 		{
 			{18,1,999,2},
 			{18,1,999,3},
 			{18,1,999,4},
 		},		
 		tbTask				= {204, 304, "12D", "15C"},	-- 万花
 		tbXiaKeDailyItem	= 
		{
			[2] = {18, 1, 1230, 1},	
		};
		tbTaskGroupId = {2203, 6},
  	},
  	[5] = 
	{
		nOpenState = 1,		
 		szName = "Thiên Quỳnh Cung",
 		szInstanceInfoFile  = "\\setting\\task\\treasuremap2\\qianqionggongfuben\\info.txt",
 		szTrapPosFile 		= "\\setting\\task\\treasuremap2\\qianqionggongfuben\\trap.txt",
 		nTskGroupId 		  = 2136,
 		nTskInstanceLevelId	  = 7, 
 		nTemplateMapId		= 1740;				--地图模板ID
 		tbItem				= {18,1,998,1},		--
 		tbBirthPos			= {1527,3276},
 		tbNpcLevel			= {100,107,121},	--有些NPC是写在脚本里的所以要这样
 		nAchievementId		= Achievement_ST.FUBEN_QIANQIONG,
 		nBaseCount			= 4,				-- 一台服务器的基础数量
  	 	tbTimeRate			=					-- 通关时间加成
 		{
 			[1] = {15 * 60,  25},
			[2] = {30 * 60, 20},
			[3] = {40 * 60, 15},
			[4] = {50 * 60, 10},
 		}, 		
  		tbLevelItem		  = 					--不同的星级对应不同的令牌先写在这里吧
 		{
 			{18,1,998,2},
 			{18,1,998,3},
 			{18,1,998,4},
 		},			
 		tbTask				= {203, 303, "E0", "15B"},	-- 千琼
 		tbXiaKeDailyItem	= 
		{
			[2] = {18, 1, 1231, 1},	
		};
		tbTaskGroupId = {2203, 7},
  	},		
  	[6] = 
	{
		nOpenState = 1,		
 		szName = "Long Môn Phi Kiếm",
 		--szColor = "yellow",	--是否高亮
 		szInstanceInfoFile  = "\\setting\\task\\treasuremap2\\longmenfeijian\\info.txt",
 		szTrapPosFile 		= "\\setting\\task\\treasuremap2\\longmenfeijian\\trap.txt",
 		nTskGroupId 		  = 2136,
 		nTskInstanceLevelId	  = 11, 
 		nTemplateMapId		= 2145;				--地图模板ID
 		tbItem				= {18,1,995,1},		--
 		tbBirthPos			= {1597,3315},
 		tbNpcLevel			= {50,100,130},	--有些NPC是写在脚本里的所以要这样
 		nBaseCount			= 4,				-- 一台服务器的基础数量
  	 	tbTimeRate			=					-- 通关时间加成
 		{
 			[1] = {15 * 60, 25},
			[2] = {30 * 60, 20},
			[3] = {40 * 60, 15},
			[4] = {50 * 60, 10},
 		}, 		
  		tbLevelItem		  = 					--不同的星级对应不同的令牌先写在这里吧
 		{
 			{18,1,995,2},
 			{18,1,995,3},
 			{18,1,995,4},
 		},			
 		tbXiaKeDailyItem	= 
 		{
 			[2] = {18, 1, 1454, 1},	
 		};
 		tbTaskGroupId = {2203, 8},
  	},
  	[7] = 
	{
		nOpenState = 1,		
 		szName = "Bích Lạc Cốc",
 		szInstanceInfoFile  = "\\setting\\task\\treasuremap2\\biluogu\\info.txt",
 		szTrapPosFile 		= "\\setting\\task\\treasuremap2\\biluogu\\trap.txt",
 		nTskGroupId 		  = 2136,
 		nTskInstanceLevelId	  = 12, 
 		nTemplateMapId		= 2283;				--地图模板ID
 		tbItem				= {18,1,1794,1},		--通用信息
 		tbBirthPos			= {51552/32, 112288/32},
 		tbNpcLevel			= {25, 50, 130},			--有些NPC是写在脚本里的所以要这样
 		nBaseCount			= 8,				-- 碧落谷前期可能会多一些，给大一点点
  	 	tbTimeRate			=					-- 通关时间加成
 		{
 			[1] = {15 * 60, 25},
			[2] = {30 * 60, 20},
			[3] = {40 * 60, 15},
			[4] = {50 * 60, 10},
 		}, 		
  		tbLevelItem		  = 					-- 常规令牌
 		{
 			{18,1,1794,2},
 			{18,1,1794,3},
 			{18,1,1794,4},
 		},			
 		tbXiaKeDailyItem	= {},				-- 侠客令牌
 		tbTaskGroupId = {2203, 9},
  	},						
};


-- 传送符 应该没啥用了
TreasureMap2.TB_NEW_WORLD	=
{
	[1]	= { 1, 1389, 3102 },
 	[2]	= { 2, 1785, 3586 },	
 	[3]	= { 3, 1693, 3288 },
 	[4]	= { 4, 1624, 3253 },	
 	[5]	= { 5, 1597, 3131 },	
 	[6]	= { 6, 1572, 3106 },
 	[7]	= { 7, 1510, 3268 },
 	[8]	= { 8, 1721, 3381 },

 	[26]	= { 26, 1641, 3129 },
	[25]	= { 25, 1630, 3169 },
 	[29]	= { 29, 1605, 3946 },
	[24]	= { 24, 1767, 3540 },
 	[28]	= { 28, 1439, 3366 },
 	[27]	= { 27, 1666, 3260 },
 	[23]	= { 23, 1486, 3179 },
};

--令牌 系统赠送和挖宝
TreasureMap2.LINGPAI_PRESENT_LEVEL =
{
	[1] = 50,
	[2] = 60,
	[3] = 70,
	[4] = 80,
	[5] = 90,
	[6] = 95,
	[7] = 100,
	[8] = 110,
	[9] = 120,
	[10] = 130,			
};

TreasureMap2.LINGPAI_WABAO_LEVEL = 
{
	[1] = 50,
	[2] = 60,
	[3] = 70,
	[4] = 80,
	[5] = 90,
	[6] = 100,
	[7] = 110,
	[8] = 120,	
};


TreasureMap2.LINGPAI_PRESENT = 
{
	[1] = {[1] = { tbItem = {18,1,995,2}, nCount = 2},},    -- 50
	[2] = {[1] = { tbItem = {18,1,995,2}, nCount = 2},},	-- 60
	[3] = {[1] = { tbItem = {18,1,996,2}, nCount = 2},},	-- 70
	[4] = {[1] = { tbItem = {18,1,997,2}, nCount = 2},},	-- 80
	[5] = {[1] = { tbItem = {18,1,999,2}, nCount = 2},},	-- 90
	[6] = {[1] = { tbItem = {18,1,998,2}, nCount = 1},		-- 95	
		   [2] = { tbItem = {18,1,999,2}, nCount = 1},},	-- 95	
	[7] = {[1] = { tbItem = {18,1,998,2}, nCount = 1},		-- 100	
		   [2] = { tbItem = {18,1,999,2}, nCount = 1},},	-- 100		
	[8] = {[1] = { tbItem = {18,1,998,3}, nCount = 1},		-- 110	
		   [2] = { tbItem = {18,1,999,3}, nCount = 1},},	-- 110			
	[9] = {[1] = { tbItem = {18,1,998,3}, nCount = 1},		-- 120	
		   [2] = { tbItem = {18,1,999,3}, nCount = 1},},	-- 120	
	[10] = {[1] = { tbItem = {18,1,998,3}, nCount = 1},		-- 130	
		   [2] = { tbItem = {18,1,999,3}, nCount = 1},},	-- 130			   			   			   	   		   	
};

TreasureMap2.LINGPAI_PRESENT_DAY = 
{
	[1] = {[1] = { tbItem = {18,1,1794,2}, nCount = 2},},
}

TreasureMap2.LINGPAI_WABAO	 = 
{
	[1] = {[1] = { tbItem = {18,1,995,2}, nPro = 30},},  -- 50
	[2] = {[1] = { tbItem = {18,1,995,2}, nPro = 30},},	-- 60
	[3] = {[1] = { tbItem = {18,1,996,2}, nPro = 30},},	-- 70
	[4] = {[1] = { tbItem = {18,1,997,2}, nPro = 30},},	-- 80
	[5] = {[1] = { tbItem = {18,1,998,2}, nPro = 15},	-- 90
		   [2] = { tbItem = {18,1,999,2}, nPro = 15},},	-- 90
	[6] = {[1] = { tbItem = {18,1,998,2}, nPro = 15},	-- 100
		   [2] = { tbItem = {18,1,999,2}, nPro = 15},},	-- 100	  	
	[7] = {[1] = { tbItem = {18,1,995,3}, nPro = 10},	-- 110	
		   [2] = { tbItem = {18,1,996,3}, nPro = 10},	-- 110	
		   [3] = { tbItem = {18,1,997,3}, nPro = 10}, }, -- 110				
	[8] = {[1] = { tbItem = {18,1,995,3}, nPro = 10},	-- 120	
		   [2] = { tbItem = {18,1,996,3}, nPro = 10},	-- 120	
		   [3] = { tbItem = {18,1,997,3}, nPro = 10},},	-- 120			
};

TreasureMap2.TASK_GROUP = 2203;
TreasureMap2.TASK_ID_COUNTWEEK = 1;		-- 领取的周数
TreasureMap2.TASK_ID_COUNTDAY  = 2;		-- 领取的日期
TreasureMap2.TASK_ID_COMMONTASK	= 3;	-- 通用令牌次数的任务id
TreasureMap2.NUMBER_WEEK_COMMON = 2;	-- 每周两个通用令牌
TreasureMap2.NUMBER_MAX_TREASURE_TIMES = 20;	-- 副本最多个数20个


-- 各等级对应的任务信息,def表没有放gc，改动时注意将treasuremap2_gc文件中的该表一起改了
TreasureMap2.LEVEL_TASKIID	=
{
	[25] = {7},
	[50] = {7, 6},
	[70] = {2, 3},	
	[90] = {3, 4, 5},
	[100] = {4, 5, 6}
};

--管理TABLE
TreasureMap2.MissionList    = TreasureMap2.MissionList or {};
TreasureMap2.tbTotalMapList = TreasureMap2.tbTotalMapList or {};
TreasureMap2.tbOpenedList 	= TreasureMap2.tbOpenedList or {}; --为了兼容藏宝图 还是很有必要的

if not TreasureMap2.tbDynMapList then
	TreasureMap2.tbDynMapList = {};    --动态地图最多申请表
	TreasureMap2.tbDynMapList[0] = TreasureMap2.DYNMAP_LIMIT;
	for nTreasureId, tbData in ipairs(TreasureMap2.TEMPLATE_LIST) do
		TreasureMap2.tbDynMapList[nTreasureId] = tbData.nBaseCount;
		TreasureMap2.tbDynMapList[0] = TreasureMap2.tbDynMapList[0] - tbData.nBaseCount;
	end
	if TreasureMap2.tbDynMapList[0] <= 0 then
		print("[ERR],tbDynMapList[0] is negative");
	end
end

