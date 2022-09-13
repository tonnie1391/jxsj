--竞技赛类型
--孙多良.麦亚津
--2008.12.24

--雪仗活动相关定义
Esport.SNOWFIGHT_ITEM_SINGLEWIN	= 	{18,1,282,1}	--单场奖励宝箱一个

Esport.SNOWFIGHT_ITEM_JINZHOUBAOZHU	= 	{18,1,278,1}	--禁咒爆竹

Esport.SNOWFIGHT_ITEM_EXCOUNT	= 	{18,1,280,1}	--红粉莲花，可以额外获得参加次数

Esport.SNOWFIGHT_STATE = {
	[1] = 20090114,	--活动开始时间
	[2] = 20090213,	--活动结束时间
	[3] = 20090220,	--物品消失期
	[4] = 20090121,	--充值额外获得红粉莲花时间开始
	[5] = 20090201,	--充值额外获得红粉莲花时间结束
}

--活动开启时间
Esport.SNOWFIGHT_TIME_SCHTASK = 
{
 1000, 1030, 
 1100, 1130,
 1200, 1230,
 1300, 1330,
 1400, 1430,
 1500, 1530,
 1600, 1630,
 1700, 1730,
 1800, 1830,
 1900, 1930,
 2000, 2030,
 2100, 2130,
 2200, 2230,
 2300, 2330,
 0000, 0030,
 };

--竞技赛系统相关定义

--任务变量定义
Esport.TSK_GROUP 			= 2064;		--任务组
Esport.TSK_ATTEND_TOTAL 	= 1;		--参加总数
Esport.TSK_ATTEND_WIN 		= 2;		--参加胜数
Esport.TSK_ATTEND_TIE 		= 3;		--参加平数
Esport.TSK_ATTEND_COUNT 	= 4;		--每天可参加次数，记录次数
Esport.TSK_ATTEND_DAY 		= 5;		--累计天数
Esport.TSK_ATTEND_EXCOUNT 	= 6;		--额外参加次数
Esport.TSK_ATTEND_AWARD 	= 7;		--奖励标志

Esport.TSK_NEWYEAR_YANHUA 	= 8;		--每天领取新年烟花标志
Esport.TSK_NEWYEAR_JINZHOUBAOZHU = 9 	--每天领取一个禁咒爆竹
Esport.TSK_NEWYEAR_LIANHUA = 10 		--冲48额外获得红粉莲花
Esport.TSK_NEWYEAR_LIANHUA_COUNT = 11 	--每天使用红粉莲花换取次数最多3次,记录次数
Esport.TSK_NEWYEAR_LIANHUA_DAY 	 = 12 	--每天使用红粉莲花换取次数最多3次,记录天
Esport.TSK_NEWYEAR_LIGUAN_DAY 	 = 13 	--每天只能在随机刷出的礼官处领取一次随机奖励,记录天

Esport.DEF_POINT_WIN	= 6;		--胜获得积分
Esport.DEF_POINT_TIE	= 4;		--平获得积分
Esport.DEF_POINT_LOST	= 3;		--负获得积分
Esport.DEF_PLAYER_MAX	= 120;		--一个准备场最多人数（影响比赛动态地图加载总量）
Esport.DEF_PLAYER_TEAM	= 6;		--对阵一方最多几人（影响比赛动态地图加载总量）
Esport.DEF_PLAYER_LEVEL	= 50;		--最低等级需求
Esport.DEF_PLAYER_COUNT	= 2;		--每天默认可参加次数
Esport.DEF_PLAYER_KEEP_MAX	= 14;	--最多可累计多少场

Esport.DEF_PLAYER_EXP_WIN	= 120;	--胜利获得120分钟基准经验
Esport.DEF_PLAYER_EXP_LOST	= 90;	--失败或平获得90分钟基准经验

Esport.DEF_READY_MSG	= "<color=green>离活动开启剩余时间：<color=white>%s<color>"; 
Esport.DEF_READY_TIME	= Env.GAME_FPS * 595;			--准备时间;
Esport.DEF_READY_TIME2	= Env.GAME_FPS * 5;				--准备时间结束，解散队伍，等待进入比赛场时间
Esport.DEF_READY_TIME_ENTER	= Env.GAME_FPS * 10;			--入场最后倒数时间；
Esport.DEF_READY_MAP		= {1504, 1505, 1506};			--准备场地图ID
Esport.DEF_READY_POS		= {{1607,3183}};		--准备场传入坐标,多个坐标随机

Esport.DEF_MAP_TEMPLATE_ID	= 1507;						--比赛场地图模版ID
Esport.DEF_MAP_POS			= {50848/32,102560/32};		--比赛场传入坐标,1589,3205

--内存存储表
Esport.tbGroupLists  	= Esport.tbGroupLists or {};	--队伍列表
Esport.tbPlayerLists 	= Esport.tbPlayerLists or {};  	--选手场地表
Esport.nReadyTimerId 	= Esport.nReadyTimerId or 0;	--准备时间timer
Esport.tbMissionLists 	= Esport.tbMissionLists or {};	--启动的mission表
Esport.tbDynMapLists	= Esport.tbDynMapLists or {};	--动态比赛地图

Esport.SKILL_ID_SNOWBALL_ORIGINAL = 1300;

-- Npc 用数据
-- {[模板Id] = skill_id, ... }
Esport.tbTemplateId2Skill = 
	{[3609] = 1301, [3610] = 1302, [3611] = 1304, [3612] = 1306, [3613] = 1308, [3614] = 1309,
     [4290] = 1452, [4291] = 1453, [4292] = 1454, [4293] = 1455, [4294] = 1456,
    };

-- {[color] = trap_id, ... }
Esport.tbTemplateId2Trap = {[3615] = 1315, [3628] = 1316, [3629] = 1317, [3630] = 1318, [3631] = 1320,
    [4295] = 1315, [4296] = 1316, [4297] = 1317, [4298] = 1318, [4299] = 1320,
    };

-- {[模板Id] = buff_id, ... }
Esport.tbTemplateId2Buff = 
	{[3616] = 1312, [3624] = 1314, [3625] = 1311, [3626] = 1313,};
	
Esport.tbSkill2Level = 
	{[1301] = 3,	[1302] = 2,	[1304] = 2, [1306] = 2, [1308] = 2, [1309] = 4,
	 [1311] = 10,	[1312] = 1, [1313] = 1, [1314] = 1, [1315] = 3, [1316] = 3, [1317] = 5,
	 [1318] = 3,	[1320] = 3, 
	 [1452] = 1,	[1453] = 1, [1454] = 1, [1455] = 1, [1456] = 1,
	 };

Esport.tbSkill2Time = 
	{[1301] = 30,	[1302] = 30,	[1304] = 30, [1306] = 30, [1308] = 30, [1309] = 30,
	 [1311] = 30,	[1312] = 30, 	[1313] = 30, [1314] = 20, 
	 }; 

Esport.tbSkill2Original = 
	{
	 [1452] = 1451, [1453] = 1451, [1454] = 1451, [1455] = 1451, [1456] = 1451,
	}
	
Esport.tbBlizzardPos1 = 
{
	{50304,102304},
	{50400,103040},
	{50848,102048},
	{50816,103200},
	{51424,102048},
	{51200,102976},
	{51264,102400},
}
	 