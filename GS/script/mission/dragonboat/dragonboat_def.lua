-- 文件名　：dragonboat_def.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-05-04 16:41:51
-- 描  述  ：


Esport.DragonBoat = Esport.DragonBoat or {};
local DragonBoat = Esport.DragonBoat;

DragonBoat.TSK_GROUP		= 2064;
DragonBoat.TSK_RANK			= 14;	--排名
DragonBoat.TSK_ATTEND_COUNT		= 15;	--次数
DragonBoat.TSK_ATTEND_COUNT_EX	= 16;	--额外次数
DragonBoat.TSK_EXCHANGE_COUNT	= 17;	--每天换取额外次数
DragonBoat.TSK_EXCHANGE_DAY		= 18;	--每天换取额外次数
DragonBoat.TSK_ATTEND_DAY		= 19;	--第一次记录天数;
DragonBoat.TSK_MERCHANT_COUNT	= 20;	--完成商会轮数，可领取龙舟原型数量；
DragonBoat.TSK_ITEM_ZONGZIEXP_COUNT	= 21;	--使用粽子数量；最多100个；
DragonBoat.TSK_ATTEND_COUNT_SUM	= 22;	--累计参加次数；
DragonBoat.TSK_AWARD_FINISH		= 23;	--奖励标志；

DragonBoat.DEF_EXCHANGE_MAX		= 2;	--每天换取额外次数;最大4次；
DragonBoat.DEF_PLAYER_LEVEL		= 60;	--60级才能参加
DragonBoat.DEF_PLAYER_MAXCOUNT	= 14;	--累计最大次数;
DragonBoat.DEF_PLAYER_PRECOUNT	= 2;	--累计最大次数;


DragonBoat.DEF_STATE ={
	DrangonBoat.IVER_nRaceBegin,
	DrangonBoat.IVER_nRacetEnd,
	DrangonBoat.IVER_nRewardBegin,
	DrangonBoat.IVER_nRewardEnd,
};

--龙舟属性
DragonBoat.GEN_WEAR		  	= 1;
DragonBoat.GEN_SKILL_ATTACK = {2,3};
DragonBoat.GEN_SKILL_DEFEND = {4,5};
DragonBoat.DEF_FINISH_RANK 	= 1000000;

DragonBoat.MAP_POS_START = {{1360,3439},{1363,3442},{1367,3445}};	--开始点的坐标

DragonBoat.ITEM_BOAT_ID	 = {18,1,327}; --龙舟Id
DragonBoat.ITEM_ZONGZI_ID= {18,1,326,4}; --葫芦香溪粽Id
DragonBoat.ITEM_ORG_BOAT_ID= {18,1,329,1}; --龙舟原型

DragonBoat.AWARD_REPUTE = 
{
	[1] = 8,	--第一名5点
	[2] = 6,	--第二名3点
	[3] = 4,	--第三名3点
	[4] = 3,
	[5] = 2,
	[6] = 2,
	[7] = 1,
	[8] = 1,
}

DragonBoat.PRODUCT_SKILL = {
	
	--攻击性
	[1] = {
		--技能Id，名称，描述，改造龙舟等级,需要绑定银两
		{1363, "Lữ Băng", "Làm cho mục tiêu chậm trong 5 giây, đánh định điểm",{[1]=1,[2]=1,[3]=1,[4]=1,[5]=1,[6]=1,[7]=1,[8]=1}, 15000},
		{1364, "Ám Tiêu", "Làm cho mục tiêu choáng trong 2 giây, đánh định điểm",{[1]=1,[2]=1,[3]=1,[4]=1,[5]=1,[6]=1,[7]=1,[8]=1}, 15000},
		{1365, "Hiên Lãng", "Làm cho mục tiêu định thân trong 3 giây, đánh định điểm",{[1]=1,[2]=1,[3]=1,[4]=1,[5]=1,[6]=1,[7]=1,[8]=1}, 15000},
		{1366, "Xoáy Nước", "Làm cho mục tiêu hỗn loạn trong 2 giây, đánh định điểm",{[1]=1,[2]=1,[3]=1,[4]=1,[5]=1,[6]=1,[7]=1,[8]=1}, 15000},
	},
	
	--防御性
	[2] = {
		--技能Id，名称，描述，改造龙舟等级,需要绑定银两
		{1372, "Thạch Phu", "Chịu sự định thân và tỉ lệ xác suất hiệu ứng giảm đi 40%",{[1]=1,[2]=1,[3]=1,[4]=1,[5]=1,[6]=1,[7]=1,[8]=1}, 15000},
		{1373, "Long Tâm", "Chịu sự hỗn loạn và tỉ lệ xác suất hiệu ứng giảm đi 40%",{[1]=1,[2]=1,[3]=1,[4]=1,[5]=1,[6]=1,[7]=1,[8]=1}, 15000},
		{1374, "Hải Hồn", "Bị choáng và tỉ lệ xác suất hiệu ứng giảm đi 40%",{[1]=1,[2]=1,[3]=1,[4]=1,[5]=1,[6]=1,[7]=1,[8]=1}, 15000},
		{1375, "Nghịch Lân", "Chịu tất cả hiệu ứng phụ có tỉ lệ xác suất hiệu ứng giảm đi 30%",{[4]=1, [8]=1}, 30000},
	},
};

DragonBoat.PRODUCT_BOAT = {
	--耐久，攻击改造，防御改造，是否可重造
	[1] = {10,2,0,{1383,1}},	--1级,15耐久，2次攻击性改造，0次防御行改造，变身技能
	[2] = {10,1,1,{1383,2}},	--2级,15耐久，1次攻击性改造，1次防御行改造，变身技能
	[3] = {10,0,2,{1383,3}},	--3级,15耐久，0次攻击性改造，2次防御行改造，变身技能
	[4] = {10,2,1,{1383,4}},	--4级,15耐久，2次攻击性改造，1次防御行改造，变身技能
	[5] = {10,2,0,{1383,1}},	--1级,15耐久，2次攻击性改造，0次防御行改造，变身技能
	[6] = {10,1,1,{1383,2}},	--2级,15耐久，1次攻击性改造，1次防御行改造，变身技能
	[7] = {10,0,2,{1383,3}},	--3级,15耐久，0次攻击性改造，2次防御行改造，变身技能
	[8] = {10,2,1,{1383,4}},	--4级,15耐久，2次攻击性改造，1次防御行改造，变身技能
}
DragonBoat.CALLNPC_TYPE	= {
	--召唤npc类型 = Id, 概率
	[1]	= {3649, 30}, --秘印
	[2] = {3650, 25}, --巨综
	[3] = {3644, 45}, --天罚
}

DragonBoat.SKILL_ITEM_LIST = {
	[1] = {
		--主动技能
		{1376, 4},
		{1377, 4},
		{1378, 4},
		{1379, 4},
		{1380, 4},
		{1381, 4},
	},
	[2] = {
		--负面状态,粽子
		{1389, 3},
		{1385, 3},
		{1386, 3},
		{1387, 3},
		{1388, 3},
	},
	[3] = {
		--龙舟机关技能
		{1367, 2},
		{1368, 2},
		{1369, 2},
		{1370, 2},
		{1371, 2},
	},
	[4] = {
		--玄晶
		{18, 1, 114, 4},
		{18, 1, 114, 5},
		{18, 1, 114, 6},
		{18, 1, 114, 7},
	},
	[5] = {
		--天罚负面状态
		{1385, 11},	--减速
		{1386, 11},	--晕
		{1387, 11},  --定
		{1388, 11},  --乱
	},
}


--玄晶概率
DragonBoat.SKILL_ITEM_GET_RATE = {
	[4] = {
		[1] = 6490,
		[2] = 3000,
		[3] = 500,
		[4] = 10
	};
}

--巨粽子几率
DragonBoat.SKILL_ITEM_RATE = {
	--概率表； {上面那种} = [概率]；
	[1] = 60,
	[2] = 30,
	[3] = 0,
	[4] = 10,
}

DragonBoat.MIS_LIST 	= 
{	
	{"PkToPkStart", 	Env.GAME_FPS * 10, 	"OnGameStart"},	--准备时间 10秒
	{"PkStartToEnd", 	Env.GAME_FPS * 590, "OnGameOver"},	--比赛时间 600秒
};
DragonBoat.MIS_UI 	= 
{
	[1] = {"<color=green>Thời gian bắt đầu: <color=white>%s<color>"};
	[2] = {"<color=green>Thời gian còn lại: <color=white>%s<color>"};
};


--单场奖励
DragonBoat.AWARD_ITEM = 
{
	[1] = {18, 1, 328, 1},	--箱子
	[2] = {18, 1, 328, 2},	--箱子
	[3] = {18, 1, 328, 2},	--箱子
	[4] = {18, 1, 328, 3},	--箱子
	[5] = {18, 1, 328, 3},	--箱子
	[6] = {18, 1, 114, 5},	--
	[7] = {18, 1, 114, 5},	--
	[8] = {18, 1, 114, 5},	--
}

--最终排名奖励
DragonBoat.AWARD_FINISH = 
{
	{10,  {{18,1,114,10}} },
	{100, {{18,1,114,9},{18,1,114,9}} },
	{500, {{18,1,114,9}} },
	{1500,{{18,1,114,8},{18,1,114,8}} },
	{3000,{{18,1,114,8}} },
}
