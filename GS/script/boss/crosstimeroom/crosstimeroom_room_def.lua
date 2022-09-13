-- 文件名　：crosstimeroom_room_def.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-08-01 15:23:57
-- 描述：时光屋room define

local preEnv = _G	 
setfenv(1, CrossTimeRoom)

-------room 1 define---------------
nBossWangS1TemplateId = 9602;	--王遗风阶段1的模板id

nBossWangS2TemplateId = 9603;	--boss阶段2的模板id

nBossWangBeginerTemplateId = 9606;	--开启的对话npc

tbBossWangPos = {47680/32,98368/32};	--boss的pos

tbBossS2CastXinMoPercent = {90,60,30};	--释放心魔的血量点

tbBossS2CastRenxinPercent = {80,50,20};	--释放人心的血量点

nStopNpc_BigTemplateId = 9604;	--心魔时候放的定身npc

nStopNpc_NormalTemplateId = 9605;	--人心放的定身npc

nHengsaoSkillId = 2258;	--横扫技能id
-------room 1 define end-----------

-------room 2 define---------------
nHumeiniangTemplateId = 9597;	--媚娘模板id
nHuliTemplateId = 9598;	--狐狸模板id

tbHumeiniangPos= {41760/32,97088/32};	--媚娘pos
tbHuliPos = {41888/32,97120/32};		--狐狸pos

nBossLiTemplateId = 9599;	--李淳风模板id
nBossYuanTemplateId = 9600;	--袁天罡模板id

tbBossLiPos = {41568/32,97920/32};	--bossLi Pos
tbBossYuanPos = {41440/32,97920/32};	--bossYuan pos

nFangshiTemplateId = 9601;	--方士模板id,跑速、走速为0
tbFangshiPos = --方士pos
{
	{41376/32,96960/32},
	{42112/32,97344/32},
	{42336/32,98144/32},
	{41824/32,98848/32},
	{41024/32,98624/32},
	{40704/32,97696/32},	
};
tbBossLiAiPos = --ai路线是以像素为单位
{
	{41408,97088},
	{42080,97408},	
	{42240,98080},
	{41792,98784},
	{41088,98560},
	{40800,97728},
}	
-------room 2 define end-----------

-------room 3 define---------------
nWalkerBoyTemplateId = 9607;	--年幼孩子的模板id

tbWalkerBoyPos = {50560/32,93984/32};	--孩子的pos

nWalkerManTemplateId = 9608;	--王爷的模板id

tbWalkerManPos = {50272/32,93952/32};	--王爷的pos

nBossTaijianTemplateId = 9609;	--小太监的模板id

tbBossTaijianPos = {50368/32,94688/32};	--小太监的pos

nBossBornChildPercent = 40;	--开始分身的血量

nBossChildTemplateId = 9610;	--小太监的分身模板id

tbBossChildPos = --分身的pos
{
	{50176/32,94752/32},
	{50336/32,94560/32},
	{50400/32,95008/32},
};	

nFightHelpNpcTemplateId = 9611;	--援助npc

tbFightHelpNpcPos = --援助npc的pos
{
	{50048/32,94816/32},
	{49856/32,94528/32},
	{50240/32,94400/32},
	{50240/32,95168/32},
	{50656/32,95104/32},
	{50752/32,94336/32},
	{50848/32,94784/32},
};	

nFreezeHelperNpcTemplateId = 9605;	--定住援助npc的模板id

tbFreezeHelperNpcPos = --定住援助npc的pos
{
	{49888/32,94528/32},		
	{50048/32,94848/32},		
	{50240/32,94432/32},		
	{50240/32,95200/32},		
	{50656/32,95136/32},		
	{50752/32,94368/32},		
	{50848/32,94816/32},		
};	
-------room 3 define end-----------


-------room 4 define---------------
nWaitNpcTemplateId = 2976;	--等待npc的模板id

nYangyingfengTemplateId = 9612;	--杨影枫模板id
tbYangyingfengPos = {50208/32,106240/32};	--杨影枫pos

nBossZhuoTemplateId = 9613;	--卓非凡的模板id
tbBossZhuoPos = {49856/32,105536/32};	--桌非凡pos

nBossZiTemplateId = 9614;	--紫轩的模板id
tbBossZiPos = {49728/32,105664/32};	--紫轩的pos

nBossNalanTemplateId = 9661;	--纳兰真模板id
tbBossNalanPos = {49984/32,105440/32};	--纳兰真的pos

nMoonFlowerTemplateId = 9662;	--月影花（采集）模板id
tbMoonFlowerPos = --月影花pos
{
	{49440/32,105312/32},
	{49632/32,105696/32},
	{49792/32,104960/32},
	{50112/32,105184/32},
	{50080/32,105856/32},
	{50368/32,105536/32},	
};	

tbCastTianxianziPercent = {80,60,40,20};	--释放天仙子的血量点

tbTianxianziSkillId = {2282,2320,2322};	--天仙子技能id，随机释放一个

nDamageTemplateId = 9663;	--对boss伤害的草
tbDamagePos = {50368/32,105568/32}
tbDamageGrassGDPL = {18,1,1449,1};

nYellowStateId = 2295;	--黄色情蛊id
nGreenStateId = 2294;	--绿色情蛊id
nRedStateId = 2296;	--红色情蛊id

nDeathSkillId = 2309;	--3种情蛊都齐的时候释放的秒杀技能，自己对自己释放

nDamageSkillId = 2319;	--道具草释放的技能id
-------room 4 define end-----------

-------room 5 define---------------
nBossSimingTemplateId = 9664;	--大司命模板id

tbBossSimingPos = {51584/32,101408/32};	--大司命pos

tbBossStepPercent = {70,50,20};	--大司命不同阶段的血量触发点

tbXinghunPos = --星魂的点，随机取几个点，20秒一次,不用除以32
{
	{51136,101024},
	{50912,101248},
	{51040,101024},
	{50848,101568},
	{50976,101856},
	{51136,101760},
	{51168,101440},
	{51040,101600},
	{51392,101152},
	{51680,101248},
	{51680,100992},
	{51488,100928},
	{51264,100832},
	{51424,100672},
	{51680,100704},
	{51488,101408},
	{51584,101536},
	{51328,101632},
	{51296,102144},
	{51552,102016},
	{51296,101888},
	{51680,102272},
	{51584,101856},
	{52032,101280},
	{52000,101056},
	{51776,101184},
	{51840,100864},
	{51744,101888},
	{52128,101664},
	{51936,101632},
	{52064,101920},
	{51808,101696},
	{51744,101472},
	{52320,101248},
};	

nXinghunSkillId = 2297;	--星魂的技能id

tbBornKuileiPercent = {95,80};	--释放傀儡的血量触发点，释放的时候会无敌

nKuileiTemplateId = 9665;	--三尸人的id

tbKuileiPos = --三尸人的pos
{
	{51584/32,101120/32},
	{51296/32,101344/32},
	{51488/32,101728/32},
	{51840/32,101280/32},
	{51808/32,101600/32},
};	

nChildSafeTemplateId = 9666;	--场边的固定傀儡的id,非战斗

nChildFightTemplateId = 9667;	--场边的固定傀儡，战斗状态

tbChildPos = --固定傀儡的pos
{
	{50464/32,101120/32},
	{50240/32,101376/32},
	{50464/32,101632/32},
	{50720/32,101376/32},
	{51520/32,100064/32},
	{51264/32,100320/32},
	{51520/32,100544/32},
	{51584/32,102336/32},
	{51328/32,102592/32},
	{51584/32,102848/32},
	{51776/32,100320/32},
	{51808/32,102592/32},
	{52640/32,101216/32},
	{52352/32,101472/32},
	{52608/32,101728/32},
	{52896/32,101472/32},
};	

tbAroundChildPos = --围绕在boss身边的npc
{
	{51648/32,101248/32},
	{51584/32,101248/32},
	{51424/32,101312/32},
	{51488/32,101280/32},
	{51520/32,101248/32},
	{51520/32,101632/32},
	{51616/32,101632/32},
	{51392/32,101408/32},
	{51392/32,101504/32},
	{51424/32,101568/32},
	{51456/32,101600/32},
	{51680/32,101600/32},
	{51712/32,101280/32},
	{51744/32,101472/32},
	{51744/32,101376/32},
	{51712/32,101536/32},
};

nWalkNpcTemplateId = 9668;	--第二阶段四个角走出来的npc

tbWalkNpcAiPos = {51552,101408};	--走出来的npc要走到的pos，不用除以32

nWalkNpcBuffSkillId = 2288;	--爆炸人出来身上的技能id

nWalkNpcBoomSkillId = 2289; --走出来的npc爆炸释放的技能

nCrazyNpcTemplateId = 9669;	--第二阶段不在规定时间内同时杀死会狂乱的怪物

tbCrazyNpcPos = 	--狂乱npc的pos
{
	{50976/32,101408/32},
	{52128/32,101408/32},
};

nCrazySkillIdIR = 2325;	--狂乱的技能id
nCrazySkillIdAD = 2326;

tbTansferNewPlacePos = {56128/32,101216/32};	--第三阶段大司命传送玩家的pos

nTransferNpcTemplateId = 9670;	--第三阶段传送阵里的npc

tbNewPlaceNpcPos = --第三阶段传送阵里的npc pos
{
	{56128/32,100800/32},	
	{55808/32,101216/32},	
	{56128/32,101664/32},	
	{56480/32,101216/32},		
};	

nBlackRegionSkillId = 2286;	--第四阶段黑水技能id

nBlackRegionNpcTemplateId = 9672;	--黑水npc模板id

tbBlackRegionPos = --不用除以32
{
	{50464,101376},
	{51520,100320},
	{51584,102592},
	{52640,101472},	
};	
	
nShouhuzheNpcTemplateId = 9671;	--第四阶段古殿守护者id

tbShouhuzhePos = {51584/32,101376/32};	--守护者的pos

-------room 5 define end-----------
preEnv.setfenv(1, preEnv)