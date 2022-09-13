--武林大会
--孙多良
--2008.09.11
--时间表

Wldh.IS_OPEN = GLOBAL_AGENT or 0;	--开启
Wldh.END_DATE = 20091110;	--武林大会最终结束时间（全局服务器关闭武林大会）
Wldh.STATE1_DATE = 
{
	--开始日期(0点), 结束日期(24点),阶段
	{20091009, 20091013, 1}, --单人门派赛 
	{20091014, 20091018, 2}, --双人 
	{20091019, 20091023, 3}, --三人 
	{20091024 ,20091028, 4}, --五人五行 	
};

Wldh.STATE2_DATE = 
{
	--开始日期(0点), 32强开打时间, 共打几场, 阶段
	{20091029, 7, 5}, --单人门派赛 
	{20091103, 7, 6}, --双人 
	{20091031, 7, 7}, --三人 
	{20091101 ,7, 8}, --五人五行 
};
Wldh.STATE3_DATE = {
	
	20091104,	--小型赛领奖开始时间
	20091109,	--小型赛领奖结束时间
}
Wldh.STATE4_DATE = {
	
	20091104,	--区服领奖的时间开始时间
	20091130,	--区服领奖的时间结束时间
}
Wldh.STATE5_DATE = {
	
	20091104,	--团体赛领奖开始时间
	20091105,	--团体赛领奖结束时间
}

-- 11月合区列表
Wldh.COZONE_LIST = 
{
	[401] = 403,
	[403] = 401,
	[421] = 422,
	[422] = 421,
	[512] = 514,
	[514] = 512,
	[605] = 616,
	[616] = 605,
	[620] = 621,
	[621] = 620,
};

Wldh.STATE_TYPE = {
	--阶段＝{赛制类型，初赛/决赛}
	[1] = {1, 0},
	[2] = {2, 0},
	[3] = {3, 0},
	[4] = {4, 0},
	[5] = {1, 1},
	[6] = {2, 1},
	[7] = {3, 1},
	[8] = {4, 1},
};

Wldh.STATE1_PRE_TIME = 
{
	2000,2015,2030,2045,2100,2115,2130,2145,
};

Wldh.OPEN_WLLS_DATA = 20091028; --此时间之前拥有参加武林大会资格的成员不能参加武林联赛，建立战队。

--最终出各循环赛结果战报时间
Wldh.STATE1_PRE_FINIAL_TIME = {2205};

--决赛开打时间
Wldh.STATE2_PRE_FINIAL_TIME = {2000};

Wldh.LADDER_ID = {
	[1] = {"门派单人赛",	Ladder.LADDER_CLASS_WLDH, 1, 0, Task.tbHelp.NEWSKEYID.NEWS_WLDH_1},--门派单人赛
	[2] = {"双人赛", 		Ladder.LADDER_CLASS_WLDH, 2, 0, Task.tbHelp.NEWSKEYID.NEWS_WLDH_2},--双人赛
	[3] = {"三人赛", 		Ladder.LADDER_CLASS_WLDH, 3, 0, Task.tbHelp.NEWSKEYID.NEWS_WLDH_3},--三人赛
	[4] = {"五行五人赛", 	Ladder.LADDER_CLASS_WLDH, 4, 0, Task.tbHelp.NEWSKEYID.NEWS_WLDH_4},--五行五人赛
	[5] = {"大型团体赛", 	Ladder.LADDER_CLASS_WLDH, 5, 0, Task.tbHelp.NEWSKEYID.NEWS_WLDH_5},--大型团体赛
};



--GTsk
Wldh.GTASK_MACTH_TYPE 	= DBTASD_WLDH_TYPE;		--比赛类型

--LG Task ID--
Wldh.LGTASK_MSESSION= 1;		--届数
Wldh.LGTASK_MTYPE	= 2;		--比赛赛制
Wldh.LGTASK_RANK	= 3;		--战队获得名次（比赛结束后排序获得）
Wldh.LGTASK_WIN		= 4;		--胜利次数
Wldh.LGTASK_TIE		= 5;		--平局次数
Wldh.LGTASK_TOTAL	= 6;		--参赛次数（失败次数 = TOTAL - WIN - TIE）
Wldh.LGTASK_TIME	= 7;		--战斗时间总计
Wldh.LGTASK_EMY1	= 8;		--最后的一场比赛遇到的对手（战队名String2ID）
Wldh.LGTASK_EMY2	= 9;		--倒数第二场比赛遇到的对手
Wldh.LGTASK_EMY3	= 10;		--倒数第三场比赛遇到的对手
Wldh.LGTASK_ATTEND	= 11;		--未参赛0和进入准备场Id(进入准备场为已参赛)
Wldh.LGTASK_ENTER	= 12;		--进入准备场队员总数.
Wldh.LGTASK_EMY4	= 13;		--倒数第四场比赛遇到的对手
Wldh.LGTASK_EMY5	= 14;		--倒数第五场比赛遇到的对手
Wldh.LGTASK_RANK_ADV= 15;		--八强赛排名；

--LG MemberTask ID--
Wldh.LGMTASK_JOB	= 1;		--职位:0、队员；1、队长
Wldh.LGMTASK_AWARD	= 2;		--奖励补领:0、无补领奖励；1、胜利奖励,上线自动领取. 2.平奖励, 3负奖励
Wldh.LGMTASK_FACTION= 3;		--门派
Wldh.LGMTASK_ROUTEID= 4;		--路线
Wldh.LGMTASK_CAMP	= 5;		--阵营
Wldh.LGMTASK_SEX	= 6;		--性别
Wldh.LGMTASK_SERIES	= 7;		--五行

--Task ID--
Wldh.TASKID_GROUP			= 2102;		--任务变量组
Wldh.TASKID_ATTEND_TYPE		= 1;		--参加类型
Wldh.TASKID_CHOSE_TYPE		= 2;		--3选1选择类型
Wldh.TASKID_Award	= {
	--类型={单场领奖，最终奖励}
	[1] = {3,4},
	[2] = {5,6},
	[3] = {7,8},
	[4] = {9,10},
};

Wldh.GBTASKID_GROUP			= 1;		--跨服变量组
Wldh.GBTASKID_ATTEND_ID	= 
{
	[1] = 1,		--门派赛参加总场数
 	[2] = 2,		--双人赛参加总场数
 	[3] = 3,		--三人赛参加总场数
 	[4] = 4,		--五人赛参加总场数
};

Wldh.GBTASKID_FINAL_ID = 
{
	[1] = 5;		--门派赛决赛奖励（记录几强）
	[2] = 6;		--双人赛决赛奖励（记录几强）
	[3] = 7;		--三人赛决赛奖励（记录几强）
	[4] = 8;		--五人赛决赛奖励（记录几强）
}

Wldh.GBTASKID_BATTLE_WIN_ID = 9;	--团体赛队伍胜利场数
Wldh.GBTASKID_CHOSE_TYPE = 10		--3选1选择类型
Wldh.GBTASKID_FACTION_ID = 11		--门派赛参加的门派Id

Wldh.GBTASKID_BATTLE_ATTEND_ID 	= 12;	--团体赛个人参加次数
Wldh.GBTASKID_BATTLE_RANK_ID 	= 13;	--团体赛队伍排名

--大会场进入准备场类型，
Wldh.MAP_LINK_TYPE_RANDOM 	= 1;		--随机选择进入;随机准备场
Wldh.MAP_LINK_TYPE_SERIES 	= 2;		--五行对应类型;准备场地图编号为战队五行,比赛场也是
Wldh.MAP_LINK_TYPE_FACTION 	= 3;		--门派对应类型;准备场地图编号为战队门派,比赛场也是

--战队组队类型，
Wldh.LEAGUE_TYPE_SEX_FREE 			= 0;		--自由性别
Wldh.LEAGUE_TYPE_SEX_SINGLE 		= 1;		--同一性别;
Wldh.LEAGUE_TYPE_SEX_MIX 			= 2;		--混合性别;
Wldh.LEAGUE_TYPE_CAMP_FREE 			= 0;		--自由阵营;
Wldh.LEAGUE_TYPE_CAMP_SINGLE 		= 1;		--同一阵营;
Wldh.LEAGUE_TYPE_CAMP_MIX 			= 2;		--混合阵营;
Wldh.LEAGUE_TYPE_SERIES_FREE 		= 0;		--自由五行;
Wldh.LEAGUE_TYPE_SERIES_SINGLE 		= 1;		--同一五行;
Wldh.LEAGUE_TYPE_SERIES_MIX 		= 2;		--混合五行;
Wldh.LEAGUE_TYPE_SERIES_RESTRAINT	= 3;		--相克五行;（此类型本版本暂不开发）
Wldh.LEAGUE_TYPE_FACTION_FREE 		= 0;		--自由门派;
Wldh.LEAGUE_TYPE_FACTION_SINGLE 	= 1;		--同一门派;
Wldh.LEAGUE_TYPE_FACTION_MIX 		= 2;		--混合门派;
Wldh.LEAGUE_TYPE_TEACHER_FREE 		= 0;		--自由师徒;
Wldh.LEAGUE_TYPE_TEACHER_MIX 		= 1;		--混合师徒;


--参赛选手参数
Wldh.PLAYER_ATTEND_LEVEL 		= 100;		--最低等级需求;
Wldh.MAP_SELECT_MIN				= 10;		--每张准备场最少先进入多少队。
Wldh.MAP_SELECT_SUBAREA			= 10;		--匹配原则,按胜率多少队为一个区间
Wldh.MAP_SELECT_MAX				= 100;		--每张比赛地图最多有几个比赛擂台。
Wldh.MACTH_LEAGUE_MIN			= 2;		--准备场中最少要有多少队才能开启。
Wldh.MACTH_ATTEND_MAX			= 24;		--每个战队最多参加多少场
Wldh.MACTH_POINT_WIN 			= 3;		--胜利获得积分
Wldh.MACTH_POINT_TIE 			= 1;		--平获得积分
Wldh.MACTH_POINT_LOSS 			= 0;		--输掉比赛获得积分
Wldh.MACTH_TIME_BYE  			= 300;		--轮空计算的比赛时间的秒数
Wldh.MACTH_NEW_WINRATE  		= 50;		--一场没打队伍按50％胜率计算

--32强赛场次对应表
Wldh.MACTH_STATE_ADV_TASK = 
{
	[1] = 32,
	[2] = 16,
	[3] = 8,
	[4] = 4,
	[5] = 2,
	[6] = 2,
	[7] = 2,
	[8] = 1,
};

--比赛场参数
Wldh.MACTH_TIME_READY 			= Env.GAME_FPS * 280;		--准备场准备时间;
Wldh.MACTH_TIME_READY_LASTENTER = Env.GAME_FPS * 5;			--倒数5秒不允许进场;
Wldh.MACTH_TIME_PK_DAMAGE 		= Env.GAME_FPS * 5;			--同步伤血量时间;
Wldh.MACTH_TIME_UPDATA_RANK 	= Env.GAME_FPS * 900;		--开始比赛后多少时间更新排行;

Wldh.MACTH_TIME_ADVMATCH 		= Env.GAME_FPS * 900;		--八强赛每场相隔时间;
Wldh.MACTH_TIME_ADVMATCH_MAX 	= 7;						--八强赛总场数，5场;

Wldh.MIS_LIST 	= 
{	
	{"PkToPkStart", 	Env.GAME_FPS * 15, 	"OnGamePk"	},	--Pk准备时间 15秒
	{"PkStartToEnd", 	Env.GAME_FPS * 585, "OnGameOver"},	--比赛时间 585秒
};

Wldh.MIS_UI 	= 
{
	[1] = {"<color=gold>%s Vs %s\n\n", "<color=green>比赛开始剩余时间：<color=white>%s<color>\n\n", "<color=green>对方受伤总量：<color=red>%s\n<color=green>本方受伤总量：<color=blue>%s"};
	[2] = {"<color=gold>%s Vs %s\n\n", "<color=green>剩余时间：<color=white>%s<color>\n\n", "<color=green>对方受伤总量：<color=red>%s\n<color=green>本方受伤总量：<color=blue>%s"};
}

Wldh.MIS_UI_LOOKER = "<color=green>%s队伤血量：<color=red>\n    %s\n\n<color=green>%s队伤血量：\n    <color=blue>%s";
Wldh.MACTH_TRAP_ENTER ={{50464/32, 103712/32}, {53600/32, 106912/32}, {48000/32, 105024/32}, {51872/32, 109696/32}};	--进入准备场坐标
Wldh.MACTH_TRAP_LEAVE ={{52672/32, 104192/32}, {54784/32, 106336/32}, {49824/32, 108320/32}, {52224/32, 110592/32}};	--进入会场坐标
Wldh.MACTH_ENTER_FLAG = {};

--内存记录表
Wldh.MissionList 	= {};		--mission
Wldh.GroupList 		= {};		--战队临时名单;
Wldh.GroupListTemp 	= {};		--战队临时名单2;
Wldh.tbReadyTimer 	= {};		--准备场计时器Id;
Wldh.tbGameState	= {};		--单场比赛阶段,0未开始,1准备阶段,2pk阶段
Wldh.AdvMatchState	= {};		--32强赛阶段，（1：32进16；2：16进8，3：8－4；4：4－2；5：决赛场1；6：决赛场2；7：决赛场3）
Wldh.AdvMatchLists	= {};		--32强
Wldh.WaitMapMemList = Wldh.WaitMapMemList or {};		--会场玩家名单


--数据处理
Wldh.RankFrameCount 	= 1000;							--每帧最多对1000个战队进行数据处理
Wldh.RankLeagueList 	= Wldh.RankLeagueList 	or {};	--战队排序表,分帧处理大量数据使用
Wldh.RankLeagueId 		= Wldh.RankLeagueId		or {};	--战队排序记录,分帧处理大量数据使用
Wldh.ClsLeagueList 		= Wldh.ClsLeagueList	or {};	--战队清理表,分帧处理大量数据使用
Wldh.ClsLeagueId 		= Wldh.ClsLeagueId		or 0;	--战队清理记录,分帧处理大量数据使用

--禁药提示
Wldh.ForbidItem = 
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

--对阵表
--Wldh.FINAL_VS_LIST = {
--	[1] = {[32]=1,  [16]=1, [8]=1, [4]=1, [2]=1},
--	[2] = {[32]=2,  [16]=2, [8]=2, [4]=2, [2]=1},
--	[3] = {[32]=3,  [16]=3, [8]=3, [4]=2, [2]=1},
--	[4] = {[32]=4,  [16]=4, [8]=4, [4]=1, [2]=1},
--	[5] = {[32]=5,  [16]=5, [8]=4, [4]=1, [2]=1},
--	[6] = {[32]=6,  [16]=6, [8]=3, [4]=2, [2]=1},
--	[7] = {[32]=7,  [16]=7, [8]=2, [4]=2, [2]=1},
--	[8] = {[32]=8,  [16]=8, [8]=1, [4]=1, [2]=1},
--	[9] = {[32]=9,  [16]=8, [8]=1, [4]=1, [2]=1},
--	[10]= {[32]=10, [16]=7, [8]=2, [4]=2, [2]=1},
--	[11]= {[32]=11, [16]=6, [8]=3, [4]=2, [2]=1},
--	[12]= {[32]=12, [16]=5, [8]=4, [4]=1, [2]=1},
--	[13]= {[32]=13, [16]=4, [8]=4, [4]=1, [2]=1},
--	[14]= {[32]=14, [16]=3, [8]=3, [4]=2, [2]=1},
--	[15]= {[32]=15, [16]=2, [8]=2, [4]=2, [2]=1},
--	[16]= {[32]=16, [16]=1, [8]=1, [4]=1, [2]=1},
--	[17]= {[32]=16, [16]=1, [8]=1, [4]=1, [2]=1},
--	[18]= {[32]=15, [16]=2, [8]=2, [4]=2, [2]=1},
--	[19]= {[32]=14, [16]=3, [8]=3, [4]=2, [2]=1},
--	[20]= {[32]=13, [16]=4, [8]=4, [4]=1, [2]=1},
--	[21]= {[32]=12, [16]=5, [8]=4, [4]=1, [2]=1},
--	[22]= {[32]=11, [16]=6, [8]=3, [4]=2, [2]=1},
--	[23]= {[32]=10, [16]=7, [8]=2, [4]=2, [2]=1},
--	[24]= {[32]=9,  [16]=8, [8]=1, [4]=1, [2]=1},
--	[25]= {[32]=8,  [16]=8, [8]=1, [4]=1, [2]=1},
--	[26]= {[32]=7,  [16]=7, [8]=2, [4]=2, [2]=1},
--	[27]= {[32]=6,  [16]=6, [8]=3, [4]=2, [2]=1},
--	[28]= {[32]=5,  [16]=5, [8]=4, [4]=1, [2]=1},
--	[29]= {[32]=4,  [16]=4, [8]=4, [4]=1, [2]=1},
--	[30]= {[32]=3,  [16]=3, [8]=3, [4]=2, [2]=1},
--	[31]= {[32]=2,  [16]=2, [8]=2, [4]=2, [2]=1},
--	[32]= {[32]=1,  [16]=1, [8]=1, [4]=1, [2]=1},
--}

--脚本生成对阵表
function Wldh:CreateVsList()
	Wldh.FINAL_VS_LIST ={};
	for nId, nCurState in ipairs(Wldh.MACTH_STATE_ADV_TASK) do
		if nCurState < 4 then
			break;
		end
		if nId == 1 then
			for nTRank=1, nCurState/2 do
				Wldh.FINAL_VS_LIST[nTRank] = Wldh.FINAL_VS_LIST[nTRank] or {}
				Wldh.FINAL_VS_LIST[nCurState-nTRank+1] = Wldh.FINAL_VS_LIST[nCurState-nTRank+1] or {}
				Wldh.FINAL_VS_LIST[nTRank][nCurState] = nTRank;
				Wldh.FINAL_VS_LIST[nCurState-nTRank+1][nCurState] = nTRank;
			end		
		end
		
		local tbTemp = {};
		for nTRank=1, nCurState/4 do
			tbTemp[nTRank] = nTRank;
			tbTemp[nCurState/2 - nTRank + 1] = nTRank;
		end
		
		for nTRank=1, 32 do
			for i=1, nCurState/2 do
				if Wldh.FINAL_VS_LIST[nTRank][nCurState] == i then
					Wldh.FINAL_VS_LIST[nTRank][nCurState/2] = tbTemp[i];
				end
			end
		end
	end
end
Wldh:CreateVsList();

Wldh.SERIES_COLOR = {
	[Env.SERIES_METAL]		= "<color=orange>%s<color>",		-- 金系
	[Env.SERIES_WOOD]		= "<color=green>%s<color>",			-- 木系
	[Env.SERIES_WATER]		= "<color=blue>%s<color>",			-- 水系
	[Env.SERIES_FIRE]		= "<color=salmon>%s<color>",		-- 火系
	[Env.SERIES_EARTH]		= "<color=wheat>%s<color>",			-- 土系	
};
