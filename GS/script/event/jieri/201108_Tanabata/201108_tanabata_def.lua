-- 文件名　：201108_tanabata_def.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-07-20 10:30:08
-- 描述：2011七夕活动define 
 
SpecialEvent.Tanabata201108 =  SpecialEvent.Tanabata201108 or {};
local Tanabata201108 = SpecialEvent.Tanabata201108;

Tanabata201108.nStartDay = 20110804;	--开始日期
Tanabata201108.nEndDay = 20110808;	--结束日期

Tanabata201108.tbTaskMap = --任务地图
{
	{587,1561,3208},	
	{2088,1561,3208},
	{2089,1561,3208},
};

Tanabata201108.tbXiquePos = {29,1477,3773};	--喜鹊的刷出pos

Tanabata201108.nXiQueTemplateId = 9637;	--喜鹊的模板id

Tanabata201108.nTongxinzhuTemplateId = 9640;	--同心烛id

Tanabata201108.nHongzhuTemplateId = 9641;	--红烛的id

Tanabata201108.nLengqingjueTemplateId = 9638;	--冷清绝id

Tanabata201108.nLengqingwangmuTemplateId = 9639;	--冷清王母id

Tanabata201108.nDelBossTime = 60 * 60;	--删除boss的时间

Tanabata201108.nAddExpTime = 5;	--蜡烛烤火，5秒加一次经验

Tanabata201108.nWaitHopeTime = 10 * 60;	--10分钟不点火，则删除npc

Tanabata201108.TASK_GROUP = 2172; --任务变量组
Tanabata201108.CHANGE_PRIZE_TIME = 7;	--领取奖励的时间
Tanabata201108.CHANGE_PRIZE = 8;	--是否领取过奖励



Tanabata201108.nCheckXiqueTime = 0000;	--检测是不是到时间刷喜鹊了

Tanabata201108.nChangePrizeStartTime = 080000;	--每天可以兑奖的时间start

Tanabata201108.nChangePrizeEndTime = 235000;	--每天可以兑奖的时间end

Tanabata201108.nMakeBookJinghuo = 600;	--加工成书卷需要的精活

Tanabata201108.tbBookPartInfo = 	--散落的书页info
{
	{18,1,1356,1},
	{18,1,1356,2},
	{18,1,1356,3},
	{18,1,1356,4},
	{18,1,1356,5},
	{18,1,1356,6},
	{18,1,1356,7},
	{18,1,1356,8},
	{18,1,1356,9},
	{18,1,1356,10},
	{18,1,1356,11},
	{18,1,1356,12},
};

Tanabata201108.tbBookInfo = 	--书卷info
{
	{18,1,1357,1},
	{18,1,1357,2},
	{18,1,1357,3},
	{18,1,1357,4},
	{18,1,1357,5},
	{18,1,1357,6},
	{18,1,1357,7},
	{18,1,1357,8},
	{18,1,1357,9},
	{18,1,1357,10},
	{18,1,1357,11},
	{18,1,1357,12},
};

Tanabata201108.szBookGDP = "18,1,1357";	--书卷的gdp，判定交的时候是否有其它物品

Tanabata201108.tbPrizeInfo = --书卷交换的奖励info
{
	[3] = {{18,1,1358,1}},
	[5] = {{18,1,1358,2}},
	[7] = {{18,1,1358,3}},
	[9] = {{18,1,1,9}},
	[10] = {{18,1,1,10}},
	[11] = {{18,1,1,10},{18,1,1358,4}},
	[12] = {{24,1,44,1}},
};

Tanabata201108.tbPrizeInfo_NewServer = --书卷交换的奖励info,新服的
{
	[3] = {{18,1,1358,1}},
	[5] = {{18,1,1358,2}},
	[7] = {{18,1,1358,5}},	--新服的宝箱
	[9] = {{18,1,1,9}},
	[10] = {{18,1,1,10}},
	[11] = {{18,1,1,10},{18,1,1358,4}},
	[12] = {{24,1,44,1}},
};


--刷冷清绝的时间
Tanabata201108.nAddNormalBossTime01 = 1537;
Tanabata201108.nAddNormalBossTime02 = 1937;
Tanabata201108.nAddNormalBossTime03 = 2237;
--刷冷清王母时间
Tanabata201108.nAddBigBossTime = 2100;


--一次冷清绝的数量
Tanabata201108.nAddNormalBossCount = 5;
--冷清王母数量
Tanabata201108.nAddBigBossCount = 1;

--冷清绝掉落表
Tanabata201108.szNormalBossDropFile01 = "\\setting\\event\\jieri\\201108_Tanabata\\normalboss_1.txt";
Tanabata201108.szNormalBossDropFile02 = "\\setting\\event\\jieri\\201108_Tanabata\\normalboss_2.txt";

--冷请王母掉落表
Tanabata201108.szBigBossDropFile01 = "\\setting\\event\\jieri\\201108_Tanabata\\bigboss_1.txt";
Tanabata201108.szBigBossDropFile02 = "\\setting\\event\\jieri\\201108_Tanabata\\bigboss_2.txt";


--刷冷清绝的地图和pos
Tanabata201108.tbAddNormalBossPos = 
{
	{100,{{1947,3593},{1869,3719},{1846,3341}}},	
	{101,{{1813,3696},{1670,3645},{1712,3507},{1635,3535}}},
	{102,{{1265,2995},{1294,2931},{1321,2780}}},
	{103,{{1773,3628},{1879,3666},{1902,3571}}},
	{104,{{1595,3614},{1859,3619},{1806,3423}}},
	{106,{{1676,3612},{1782,3695},{1785,3695}}},
	{59,{{1294,2500},{1464,2367},{1405,2631}}},
	{126,{{1753,3313},{1847,3534},{1611,3802},{1757,3854}}},
	{134,{{1676,3619},{1698,3369},{1812,3633},{1686,3771}}},
	{88,{{1894,3651},{1772,3405},{1674,3445},{1885,3718}}},
	{109,{{1868,3768},{1653,3464},{1897,3542},{1820,3681}}},
	{92,{{1829,3779},{1862,3620},{1844,3687}}},
	{96,{{1909,3636},{1864,3924},{1924,3248}}},
	{99,{{1482,2624},{1551,3040},{1318,3025}}},
	{89,{{1581,3628},{1815,3294},{1838,3652}}},
	{50,{{1720,3323},{1662,3564},{1780,3314}}},
	{60,{{1580,2952},{1437,2859},{1628,3236}}},
	{45,{{1926,3309},{1908,3790},{1690,3747}}},
	{136,{{1650,3120},{1767,3385},{1826,3142}}},
	{128,{{1926,3175},{1757,3204},{1651,3401}}},
	{137,{{1701,3566},{1853,3829},{1932,3487}}},
	{69,{{1525,2625},{1298,2371},{1148,2870},{1285,3046}}},
	{73,{{1648,3256},{1505,3401},{1722,3307}}},
	{68,{{1682,3169},{1792,3311},{1688,2955},{1760,2904}}},
	{67,{{1587,3569},{1598,3374}}},
	{74,{{1768,3476},{1678,3818},{1885,3523}}}
}

--刷冷清王母的pos
Tanabata201108.tbAddBigBossPos = 
{
	{30,{{1893,3376}}},	
	{52,{{1691,3724}}},
	{97,{{1781,3381}}},
	{123,{{1903,3645}}},
	{130,{{1679,3589}}},
}