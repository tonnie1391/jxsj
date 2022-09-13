--竞技赛类型
--孙多良.麦亚津
--2008.12.24
TowerDefence.SNOWFIGHT_STATE = {
	[1] = 20100330,	--活动开始时间
	[2] = 20100411,	--活动结束时间
}

--活动开启时间
TowerDefence.SNOWFIGHT_TIME_SCHTASK = 
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
 };

--竞技赛系统相关定义

--任务变量定义
TowerDefence.TSK_GROUP 			= 2118;		--任务组
TowerDefence.TSK_ATTEND_TOTAL 	= 1;			--参加总数
TowerDefence.TSK_ATTEND_WIN 	= 2;			--参加胜数
TowerDefence.TSK_ATTEND_TIE 		= 3;			--参加平数
TowerDefence.TSK_ATTEND_COUNT 	= 4;			--每天可参加次数，记录次数
TowerDefence.TSK_ATTEND_DAY 		= 5;		--累计天数
TowerDefence.TSK_ATTEND_EXCOUNT 	= 6;		--额外参加次数
TowerDefence.TSK_ATTEND_AWARD 	= 7;		--奖励标志

TowerDefence.TSK_NEWYEAR_YANHUA 			= 8;	--每天领取新年烟花标志
TowerDefence.TSK_NEWYEAR_JINZHOUBAOZHU 	= 9; 	--每天领取一个禁咒爆竹
TowerDefence.TSK_NEWYEAR_LIANHUA 			= 10; --冲48额外获得红粉莲花
TowerDefence.TSK_NEWYEAR_LIANHUA_COUNT = 11; 	--每天使用红粉莲花换取次数最多3次,记录次数
TowerDefence.TSK_NEWYEAR_LIANHUA_DAY 	 = 12; 	--每天使用红粉莲花换取次数最多3次,记录天
TowerDefence.TSK_NEWYEAR_LIGUAN_COUNT_ALL 	 = 13; 	--总共使用家次数道具的
TowerDefence.TSK_MONEY 	 = 14 ;					--玩家获得的军饷
TowerDefence.TSK_AWARD_FINISH	= 15;				--最终奖励

TowerDefence.DEF_POINT_WIN	= 9;			--胜获得积分
TowerDefence.DEF_POINT_TIE	= 5;			--平获得积分
TowerDefence.DEF_POINT_LOST	= 3;			--负获得积分
TowerDefence.DEF_PLAYER_MAX	= 120;	--一个准备场最多人数（影响比赛动态地图加载总量）
TowerDefence.DEF_PLAYER_TEAM	= 4;		--对阵一方最多几人（影响比赛动态地图加载总量）
TowerDefence.DEF_PLAYER_LEVEL	= 60;		--最低等级需求
TowerDefence.DEF_PLAYER_COUNT	= 2;		--每天默认可参加次数
TowerDefence.DEF_PLAYER_KEEP_MAX	= 14;	--最多可累计多少场

TowerDefence.DEF_READY_MSG	= "<color=green>Thời gian bắt đầu: <color=white>%s<color>"; 
TowerDefence.DEF_READY_TIME	= Env.GAME_FPS * 270;			--准备时间;
TowerDefence.DEF_READY_TIME2	= Env.GAME_FPS * 10;				--准备时间结束，解散队伍，等待进入比赛场时间
TowerDefence.DEF_READY_TIME_ENTER	= Env.GAME_FPS * 10;			--入场最后倒数时间；
TowerDefence.DEF_READY_MAP		= {583, 584, 585, 2098, 2099, 2100};			--准备场地图ID
TowerDefence.DEF_READY_POS		= {{1619,3217}};		--准备场传入坐标,多个坐标随机

TowerDefence.DEF_MAP_TEMPLATE_ID	= 586;						--比赛场地图模版ID
TowerDefence.DEF_MAP_TEMPLATE_ID2	= 2106;						--比赛场地图模版ID
TowerDefence.DEF_MAP_POS			= {50848/32,102560/32};		--比赛场传入坐标,1589,3205
TowerDefence.WINNER_BOX		={	{18, 1, 630, 1},
								{18, 1, 631, 1},
								{18, 1, 632, 1},
								{18, 1, 632, 1},
							};			--获胜队伍奖励宝箱
--内存存储表
TowerDefence.tbGroupLists  	= TowerDefence.tbGroupLists or {};	--队伍列表
TowerDefence.tbPlayerLists 	= TowerDefence.tbPlayerLists or {};  	--选手场地表
TowerDefence.nReadyTimerId 	= TowerDefence.nReadyTimerId or 0;	--准备时间timer
TowerDefence.tbMissionLists 	= TowerDefence.tbMissionLists or {};	--启动的mission表
TowerDefence.tbDynMapLists	= TowerDefence.tbDynMapLists or {};	--动态比赛地图
TowerDefence.tbMpaTrapPoint	= TowerDefence.tbMpaTrapPoint or {};	--比赛地图trap点
TowerDefence.tbTowerPosition= TowerDefence.tbTowerPosition or {};	--tower坐标点	
TowerDefence.NPC_TYPE_ID	= TowerDefence.NPC_TYPE_ID or {};	--mission 刷怪的具体配置表
TowerDefence.NPC_SKILL	= TowerDefence.NPC_SKILL or {};		--怪物对应的释放技能id
TowerDefence.NPC_AWORD	= TowerDefence.NPC_AWORD or {};	--每种怪对应的积分和军饷数

TowerDefence.SKILL_ID_ORIGINAL = 1616;						--初始技能不痛不痒

--每种植物对应的三个id
TowerDefence.TOWERID = {	[1] = {6667, 6668,6669},				--金
						[2] = {6670,6671,6672},				--木
						[3] = {6673,6674,6675},				--水
						[4] = {6676,6677,6678},				--火
						[5] = {6679,6680,6681},};				--土

--最终奖励
TowerDefence.AWARD_FINISH = 
{
	{1,  {18,1,553,1}},
	{10, {18,1,114,10}},
	{100, {18,1,114,9}},
	{1000,{18,1,114,8}},
}
	 