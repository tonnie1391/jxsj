-- 文件名　：missionlevel20_def.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-09-20 10:22:26
-- 描述：20级教育副本def

Task.PrimerLv20 = Task.PrimerLv20 or {};

local PrimerLv20 = Task.PrimerLv20;

local preEnv = _G	 
setfenv(1,PrimerLv20)

nMapTemplateId = 2129;	--地图模板id

MAX_TIME = 30 * 60;	--游戏最大时间

WARNING_TIME = 5 * 60;	--每隔多少时间进行一次告警

ENTER_POS = {{51552/32,112288/32}};	--进入点

LEAVE_POS = {1605,3288};	--离开点

LEAVE_POS_TIMEUP = {1726,4059};

TASK_MAIN_ID =  "1E0";
TASK_SUB_ID  =  "2B3";

NEXT_TASK_MAIN_ID = "9E";
NEXT_TASK_SUB_ID = "13A";

VILLAGE_MAP = {2115,2116,2117,2118,2119,2120,2121};

TIMEUP_LEAVE_MAP = {2122,2123,2124,2125,2126,2127,2128};

tbTaskSubId = {25,26,27,28,29,30,31,50,51,52,53};

STATIC_MAP_ID = 
{
	2138,2139,2140,2141,2142,2143,2144,
};

REFRESH_NPC_DELAY = 5;		--静态地图刷npc的间隔

----------其它定义---------------
tbZergInfo = --毒虫的模板id和对应pos
{
	{9687,{52512/32,110560/32},{52480/32,111328/32},{52352/32,111168/32}},
	{9687,{52352/32,110976/32},{52672/32,111072/32},{52480/32,110752/32}},	
	{9687,{52864/32,111072/32},{52832/32,110688/32},{52736/32,110848/32}},		
};

tbMashRoomInfo=	--第一阶段的蘑菇
{
	{9688,{52576/32,110912/32}},	
	{9689,{52672/32,111296/32}},	
	{9690,{52928/32,110848/32}},	
	{9691,{52352/32,110752/32}},	
};

nAddBufferMashRoomTemplateId = 9688;	--加buff的蘑菇id

tbBossManInfo = --守园人id和pos
{
	{9692,{52672/32,110496/32}},	
};

tbXieziSWitchInfo =	--开蝎子的柱子 
{
	{9760,{54144/32,111264/32}},	
};

tbXieziInfo = --蝎子
{
	{9693,{54304/32,111072/32},{54336/32,111328/32},{54400/32,110944/32},{54560/32,111392/32},{54464/32,111232/32}},
};

tbShouhuzheStep2_Safe = --3个守护者非战斗，按顺序
{
	{9728,{54880/32,111136/32}},
	{9729,{54944/32,111648/32}},
	{9730,{54720/32,111328/32}},
};

tbShouhuzheStep2_Fight = --3个守护者，按顺序
{
	{9694,{54880/32,111136/32}},	--31
	{9695,{54944/32,111648/32}},	--50
	{9696,{54720/32,111328/32}},	--51
};

tbShouhuzheTask	=
{
	[9694] = 31,
	[9695] = 50,
	[9696] = 51,
};

tbBossGirlInfo = --第二阶段的boss,打败后ai跑路
{
	{9697,{54944/32,110848/32}},
};

tbBossGirlAiPos = 	--第二阶段boss的ai路线
{
	{54944,110848},
	{55488,109792},	
};

tbAddMashRoomPercent = {90,50};	--夕岚召唤蘑菇的血量点

tbMashRoom_Step2Info =	--夕岚召唤出来的蘑菇的位置
{
	[90] = {9761,{54688/32,110816/32},{55168/32,111328/32}},
	[50] = {9762,{54784/32,110752/32},{55136/32,111104/32}},	
};

tbFinalBoss_Safe = --第三阶段的boss非战斗
{
	{9731,{55776/32,109152/32}},
};

tbFinalBoss_Fight = --第三阶段的boss战斗
{
	{9698,{55776/32,109152/32}},
};

tbFinalBossPercent = {95,70,50};

tbHelperInfo =	--甜酒叔等人，战斗的
{
	{9701,{55616/32,109024/32}},
	{9764,{55872/32,108992/32}},
};

tbHelperTalkContent = 	--helper说话的内容
{
	[9701] = {"休要伤我少主人！","欺侮小辈算什么好汉！","少主人不过寻亲心切！还不住手！"},
};

tbShouhuzheContent = 
{
	[9694] = "何人冲撞我小主人！",
	[9695] = "呵呵，敢在我们的地盘撒野？",
	[9696] = "夕岚别怕！我替你教训这家伙！",
};

tbBottleInfo =	--药罐
{
	{9763,{55584/32,109344/32},{55968/32,108896/32},{56064/32,109472/32}},
};
tbPasserbyStep3 = --第三阶段的路人甲,最后的剧情路人
{
	{9699,{56000/32,109184/32}},
	{9700,{56096/32,109152/32}},
	{9702,{56032/32,109024/32},{56160/32,109184/32}},
};

tbTrapNpcStep1 = --1-2路上的障碍
{
	{9703,{53280/32,111456/32},{53344/32,111392/32},{53408/32,111328/32}},	
}                                    
                                     
tbTrapNpcStep2 = --2-3路上的障碍     
{                                    
	{9703,{55104/32,110560/32},{55168/32,110624/32},{55200/32,110656/32}},	
}

tbTrapBackPos = --trap弹回点
{
	["trap_step1"] = {53312/32,111360/32},
	["trap_step2"] = {55136/32,110688/32},
};

tbAddBuffInfo = {1972,1,90 * 60};


preEnv.setfenv(1,preEnv)

