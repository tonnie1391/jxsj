-- 文件名　：crosstimeroom_def.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-07-29 16:54:49
-- 描述：时光阴阳店define

local preEnv = _G	 
setfenv(1, CrossTimeRoom)

nOpenState = 0;			--开关

nTemplateMapId = 2091;	--地图模板id

MAX_GAME = 50;			--当前地图最大的游戏数量

MAX_TIME = 60 * 60;		--游戏最大的时间

MAX_PLAYER = 6;			--游戏的最大人数

FINISH_TIME = 60;		--挑战完成后一分钟后关闭副本

ENTER_ITEM_GDPL = {18,1,1451,1};	--进入的令牌的gdpl	

ENTER_POS = --进入点
{
	{52896/32,103264/32},
};	

LEAVE_POS = --离开点，根据serverid进行判断
{
	[1] = {3,1585,3156},	
};

tbRoomPos =	--每个房间的传入点
{
	[1] = {47328/32,99072/32},
	[2] = {41824/32,97248/32},
	[3] = {50400/32,93952/32},
	[4] = {50112/32,106400/32},
	[5] = {51904/32,101760/32},
}

nTransferTemplateId = 9596;	--传送门模板id

tbTransferNpcPos = --传送门的pos
{
	[0] = {56448/32,106624/32},	--准备场的传送门
	[1] = {46976/32,98560/32},
	[2] = {41888/32,98336/32},
	[3] = {50016/32,94912/32},
	[4] = {50048/32,106464/32},
	[5] = {51968/32,101824/32},
	[6] = {56160/32,101440/32},	--第五关的异境里的传送npc，防止那里也有人死亡	
};	
 
tbMapTrapBackPos = 	--trap的弹回点 
{
	["trap_up"] = {52096/32,101984/32},
	["trap_down"] = {52352/32,102528/32},
}; 

nLimitJoinHuanglingBuffId = 2328;	--限制进入皇陵的buff id

nGetJoinItemBaseKinLevel = 200;	--每周可以领取进入牌子的家族的最低威望排名
nGetJoinItemBasePlayerLevel = 3000;	--每周可以领取进入牌子的个人最低威望排名

nCloseTransferNpcDelay = 55 * 60;	--报名npc存在的时间,55分钟

nBeginTransferTimeDay = 1525;
nEndTransferTimeDay = 1535;
nBeginTransferTimeNight = 2225;
nEndTransferTimeNight = 2235;

nDelteTransferNpcTimeDay = 1635;
nDelteTransferNpcTimeNight = 2335;


nApplyNpcTemplateId = 9615;	--报名npc的模板id

nApplyNpcMapId = 132;	--报名npc的地图id

tbApplyNpcPos = {62816/32,105952/32};	--报名npc的位置	

nEnterItemNum = 2;	--每周可领取令牌的数量

nGetEnterItemLimitTime = 21200;	--星期二中午12点后才可以进行领取

nTaskGroupId = 2177;	--记录领取令牌的任务变量组
nTaskGetItemTime = 1;	--领取时间
nTaskGetCount = 2;		--接取任务次数

tbTransferName = 
{
	[1] = "1: Đưa ta đi sửa đổi một người",
	[2] = "2: Đưa ta đi sửa đổi lịch sử",
	[3] = "3: Đưa ta đi sửa đổi quá khứ của mình",
	[4] = "4: Đưa ta đi sửa đổi một câu chuyện",
	[5] = "5: Đưa ta đi kết thúc tất cả",
};


nMakeStoneJinghuo = 3000;	--制作时候需要的精活

tbMakeStoneGDPL = {18,1,1453,1};

tbOtherDropInfo = {"\\setting\\npc\\droprate\\yinyangshiguangdian\\boss2_other.txt",10};

nRepute = 2;	--每关通关后给的威望

preEnv.setfenv(1, preEnv)
