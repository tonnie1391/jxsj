-- 文件名　：kuafubaihu_def.lu
-- 创建者　：zhangjunjie
-- 创建时间：2010-12-13 15:39:14
-- 描述：跨服白虎的一些定义

-----------------------通用----------------------
KuaFuBaiHu.nTotalTimeOut	= 20;	--跨服白虎的总时间
KuaFuBaiHu.nPKStartTimeOut	= 5;	--Apply开始后5分钟PKStart
KuaFuBaiHu.nTransTimeOut	= 5;	--传送至战斗场的时间限制
KuaFuBaiHu.nPKStopTimeOut 	= 15;	--传至战斗场关闭后15分钟PK结束
KuaFuBaiHu.nKickOutTimeOut = 5;	--PK结束后5分钟所有玩家传出


KuaFuBaiHu.STEP_END			= 6;	--跨服白虎分5个阶段，以6为结束
--KuaFuBaiHu.FIGHT_MAX_PLAYER	= 240;	--战斗场最多容纳的人数
KuaFuBaiHu.WAIT_MAX_PLAYER	= 100;	--准备场内最多容纳的人数
KuaFuBaiHu.nProtectedTime = 10;	--保护时间
KuaFuBaiHu.RESTSTATE	= 0;	--无活动
KuaFuBaiHu.APPLYSTATE	= 1;	--报名
KuaFuBaiHu.FIGHTSTATE	= 2;	--PK状态
KuaFuBaiHu.FORBIDENTER	= 3;	--开启5分钟后无法进入
KuaFuBaiHu.BEFORETRANSCLOSE = 4;	--进入战斗场关闭之前
KuaFuBaiHu.nActionState = KuaFuBaiHu.RESTSTATE;	--无活动,gs上的状态标记
KuaFuBaiHu.nScoreKillPlayer	= 50;		--杀人积分

-------------gc相关-------------------------------------------
KuaFuBaiHu.nActionState_GC	= KuaFuBaiHu.RESTSTATE;	--gc上的活动状态
KuaFuBaiHu.tbPlayerInfo_GC	= {};	--gc上存储的玩家信息
KuaFuBaiHu.tbGroupInfo_GC 	= {};	--gc上进行的分组信息
KuaFuBaiHu.tbCampInfo_GC	= {};	--gc上的阵营信息，用于分组使用
--------------------------------------------------------------

------------gs相关-------------------------------------------
KuaFuBaiHu.tbPlayerGroupInfo = {};	--玩家的分组信息	
KuaFuBaiHu.tbMissionList = {};	--misson的记录表
-------------------------------------------------------------

----------------mission相关--------------------------------
KuaFuBaiHu.tbTimerFunc	= {
			{1, 						 1,	"CallBoss"},		--每五分钟为一个阶段
			{2,		Env.GAME_FPS *  60 * 5,	"CallBoss"}, 		
			{3,		Env.GAME_FPS *  60 * 5,	"CallBoss"},
			{4,		Env.GAME_FPS *  60 * 5,	"CallBoss"},  	
			{5,		Env.GAME_FPS *  60 * 5,	"OnGameOver"}, 	
			{KuaFuBaiHu.STEP_END},		
	}
KuaFuBaiHu.GROUP_COLOR ={	--不同分组的颜色
		[1] = "cyan",
		[2] = "green",
		[3] = "pink",
		[4] = "blue",
		[5] = "gold",		
	}	
---------------------------------------------------------------


---------玩家任务变量ID定义--------------------------------
KuaFuBaiHu.TASK_GID	= 2150;
KuaFuBaiHu.TASK_SERVER_NAME	= 1; -- 1-8 服务器名
KuaFuBaiHu.TASK_TONG_NAME	= 9; -- 9-16 帮会名
KuaFuBaiHu.TASK_TONG_ID		= 17; -- 17-17	帮会id
KuaFuBaiHu.TASK_UNION_ID	= 18; -- 18-18 联盟id
KuaFuBaiHu.TASK_RICHES		= 19; --19-19 财富荣誉
KuaFuBaiHu.TASK_OUT_FOR_DEATH = 20; --20-20 是否在可进入状态死亡出来
KuaFuBaiHu.TASK_MYSERVER_SCORES	 = 21; --21 - 21 本服上的玩家积分，和跨服上的进行差值,在进行事后兑换时进行赋初值
KuaFuBaiHu.TASK_CURRENT_GET_SCORES = 22; --22-22,玩家当前获得的积分
KuaFuBaiHu.TASK_GB_TOTAL_SCORES	=23;	--23-23,玩家当前在大区的累计积分，每次清零

--------全局玩家sporttask id -----------------------------
KuaFuBaiHu.GB_TASK_GID	= 7;
KuaFuBaiHu.GB_TASK_SCORES = 1;	-- 1-1,白虎堂活动积分
----------------------------------------------------------


--------------道具一些定义--------------------------------
KuaFuBaiHu.nScoreAddByCanYe = 10;	--残页加的积分
KuaFuBaiHu.nScoreAddByCanJuan = 100;	--残卷加的积分
----------------------------------------------------------

-------------npc一些定义----------------------------------
KuaFuBaiHu.tbNormalBossDropCount = {nMin = 40,nMax = 60};--小boss掉落个数
KuaFuBaiHu.tbFinalBossDropCount = {nMin = 30, nMax = 70}; --大boss掉落个数
KuaFuBaiHu.tbFinalBossBloodPercent = {99,50,3};	--大boss血量触发百分比
KuaFuBaiHu.szNormaBossDropFile = "\\setting\\npc\\droprate\\kuafubaihu\\kuafuboss_2.txt"; --小boss掉落表
KuaFuBaiHu.szFinalBossDropFile ="\\setting\\npc\\droprate\\kuafubaihu\\kuafuboss_1.txt";	--大boss掉落表
----------------------------------------------------------

--------------地图相关-------------------------------------
KuaFuBaiHu.tbEnterPos = {
		{nX = 48384,nY = 100896},
		{nX = 50464,nY = 98816},
		{nX = 50496,nY = 103008},
		{nX = 52640,nY = 100928},
	};	--存储玩家进入战斗场地图的坐标,格式{{nX,nY},...,}

KuaFuBaiHu.tbWaitMapPos	= {
		{nX = 49088,nY = 100192},
		{nX = 49216,nY = 99712 },
		{nX = 49824,nY = 99264 },
		{nX = 49888,nY = 99968 },
		{nX = 50240,nY = 100384},
		{nX = 50912,nY = 100064},
		{nX = 51136,nY = 99360 },
		{nX = 50688,nY = 100224},
		{nX = 51680,nY = 99680 },
		{nX = 51872,nY = 100256},
	}; --玩家传送或者死亡或者离开战斗场进入准备场的地图坐标,格式同上

KuaFuBaiHu.tbTransferDoorPos = {--boss清理干净后的传送门的坐标
		nX = 52000,nY = 99520,
	}

KuaFuBaiHu.tbNpcId  = {
		["dadao1"] = {7268,7269,7270,},
		["dadao2"] = {7271,7272,7273,},
		["dadao3"] = {7274,7275,7276,},
		["shiyuejiaotu"] = {7265},
		["shiyuelolo"] = {7267},
		["chuansongmen"] = {7266},
	};

--mission中npc的坐标，包括boss坐标,从表中读取,格式{ [szNpcClass]={{nX=,nY=},..,},..}
KuaFuBaiHu.tbNpcPos = {	
		["dadao1"] = {{nX = 49312,nY = 101792},{nX = 49888,nY = 99712},{nX = 51552,nY = 100032}},
		["dadao2"] = {{nX = 50464,nY = 99104},{nX = 50400,nY = 102048},{nX = 51392,nY = 101376}},
		["dadao3"] = {{nX = 48896,nY = 100832},{nX = 50624,nY = 102208},{nX = 52160,nY = 100896}},
		["shiyuejiaotu"] = {{nX = 50560,nY = 100512}},
		["chuansong"]	= {{nX = 52000,nY = 99520}},
	};	


KuaFuBaiHu.tbNpcLevel = {	--mission中npc的等级,包括boss等级,格式{[szNpcClass] = nLevel,..,}
		["dadao1"] = 110,
		["dadao2"] = 110,
		["dadao3"] = 110,
		["shiyuejiaotu"] = 120,
		["shiyuelolo"] = 100,
	}; 

KuaFuBaiHu.tbReturnMapIdList = {	
		[1] = 821,	--返回本服的黄金白虎堂大殿
	}
KuaFuBaiHu.tbReturnMapPos = {	--返回本服黄金白虎大殿的坐标
		{nX =48448,nY =100864},
		{nX =48992,nY =102272},
		{nX =49024,nY =102112},
		{nX =50464,nY =98816 },
		{nX =50496,nY =103008},
		{nX =52608,nY =100928},
	}
KuaFuBaiHu.tbFightMapIdList	= {	--存储战斗场的mapid,格式{[nServerId] = {nMapid1,nMapId2}, ... ,}
		[1] = {1867,},
		[2] = {1868,},
		[3] = {1869,},
		[4] = {1870,},
		[5] = {1871,},
		[6] = {1872,},
		[7] = {1873,},
	}
KuaFuBaiHu.tbWaitMapIdList	= {	--存储准备场的map id，格式同上,nIndex为gs的id,1-7
		[1]  = {1864,},
		[2]  = {1865,},
		[3]	 = {1866,},
		[4]	 = {1889,},
		[5]  = {1890,},
		[6]  = {1891,},
		[7]  = {1892,},
}
--------------------------------------------------------------------------------------------------