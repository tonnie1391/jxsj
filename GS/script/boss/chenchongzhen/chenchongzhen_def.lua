-- 文件名　：chenchongzhen_def.lua
-- 创建者　：zhangjunjie
-- 创建时间：2012-02-20 14:37:39
-- 描述：common define

local preEnv = _G	 
setfenv(1, ChenChongZhen)

nTemplateMapId = 2153;	--地图模板id

MAX_GAME = 50;			--当前地图最大的游戏数量

MAX_TIME = 90 * 60;		--游戏最大的时间

MAX_PLAYER = 6;			--游戏的最大人数

FINISH_TIME = 60;		--一分钟后关闭副本

REVIVE_DELAY = 1 * 18;		--复活的延迟

ENTER_ITEM_GDPL	= {18,1,1695,1};	--进入的令牌gdpl


nGetJoinItemBaseKinLevel = 200;	--每周可以领取进入牌子的家族的最低威望排名
nGetJoinItemBasePlayerLevel = 3000;	--每周可以领取进入牌子的个人最低威望排名
nGetEnterItemLimitTime = 21200;	--星期二中午12点后才可以进行领取
nEnterItemNum = 2;	--每周可领取令牌的数量
nTaskGroupId = 2177;	--记录领取令牌的任务变量组
nTaskGetItemTime = 3;	--领取时间


ENTER_POS = --进入点
{
	{1489,3324},
};	

LEAVE_POS = --离开点，根据serverid进行判断
{
	[1] = {24,1752,3532},	
};

FIGHT_STATE_POS = --准备场到战斗的点，2个
{
	["trap_join"] = {48320/32,105632/32},
}

MAX_ROOM_COUNT = 7;	--关卡的数量

tbMapTrapName = 
{
	["trap_join"] = {48224/32,105760/32},	
	["trap_machine1"] = {},
	["trap_machine2"] = {},
	["trap_machine3"] = {},
	["trap_machine4"] = {},
	["trap_room2"] = {1630,3178},
	["trap_room3"] = {1714,3080},
	["trap_room4"] = {49408/32,97760/32},
	["trap_room5"] = {61472/32,96960/32},
	["trap_room5_trans"] = {61472/32,96960/32},
}

tbRoom7FireEyeInfo = {10020,
	{
		{52704/32,108800/32},
		{53216/32,108160/32},
		{53856/32,107936/32},
		{54752/32,107136/32},
		{54400/32,107520/32},
		{55168/32,106624/32},
		{55648/32,106112/32},		
	}
};	--火眼

nRoom7FireEyeCastSkillDelay = 4 * 18;	--释放技能的间隔

nRoom7FireEyeSkillId = 2600;	--火眼的技能id


tbRoom7Horse = {10019,
	{
		{57312/32,103328/32},
		{57216/32,103520/32},
		{57184/32,103616/32},
		{57184/32,103744/32},
		{57248/32,103424/32},
		{57376/32,103264/32},		
	}
};	--第七关的马匹

nRoom7AddHorseDelay = 5 * 60 * 18;


tbDropRateInfo = --掉落
{
	[1] = {{"\\setting\\npc\\droprate\\chenchongzhen\\boss1.txt",6}},
	[2] = {{"\\setting\\npc\\droprate\\chenchongzhen\\boss1.txt",7}},
	[3] = {{"\\setting\\npc\\droprate\\chenchongzhen\\boss1.txt",8}},
	[4] = {{"\\setting\\npc\\droprate\\chenchongzhen\\boss1.txt",9}},
	[5] = {{"\\setting\\npc\\droprate\\chenchongzhen\\boss1.txt",10}},
	[6] = {{"\\setting\\npc\\droprate\\chenchongzhen\\boss1.txt",3}},
	[7] = {{"\\setting\\npc\\droprate\\chenchongzhen\\boss2.txt",10},{"\\setting\\npc\\droprate\\chenchongzhen\\boss2_other.txt",24}},
};
 
tbRevivePos = --复活后的点 
{
	[1] = {51872/32,102048/32},	
	[7] = {52320/32,109440/32},
};

nDropItemBoxTemplateId = 9838;	--宝箱的id 
 
tbBoxInfo = 
{
	[1] = {51968/32,101920/32},	
	[4] = {45376/32,101696/32},	
	[7] = {52192/32,109536/32},	
}; 

nRepute = 2;	--每关通关后给的威望

tbAchievement = --成就
{
	[1] = 493,
	[2] = 494,
	[3] = 495,
	[4] = 496,
	[5] = 497,
	[6] = 498,
	[7] = 499,
};

nHaveTaskId = 523;	--需要接的任务

nTaskNeedStep = 1;	--需要接的步骤

nTaskHavePlayerTaskGroupId = 1025;

nTaskHavePlayerTaskId = 76;

preEnv.setfenv(1, preEnv)