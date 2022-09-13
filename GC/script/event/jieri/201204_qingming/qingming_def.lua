--
-- FileName: qingming_def.lua
-- Author: lgy&lqy
-- Time: 2012/3/21 11:57
-- Comment: 2012清明节常量定义
--
SpecialEvent.tbQingMing2012 =  SpecialEvent.tbQingMing2012 or {};
local tbQingMing2012 = SpecialEvent.tbQingMing2012;

tbQingMing2012.bOpen	=	1;									-- 活动开关
tbQingMing2012.nStartTime 	= 20120401;							-- 活动开始时间
tbQingMing2012.nEndTime 	= 20120406;							-- 活动结束时间，这天就不能做活动了
tbQingMing2012.nMinLevel 	= 60;								-- 活动最低等级要求
tbQingMing2012.nCostMKP 	= 300;								-- 制造续魂香需要消耗的精力
tbQingMing2012.nCostGTP		= 300;  							-- 制造续魂香需要消耗的活力
tbQingMing2012.nQingMingYouMinDengId	= {18, 1, 1705, 1}; 	-- 清明幽冥灯的GDPL
tbQingMing2012.nQingMingShuHunDengId	= {18, 1, 1705, 2};		-- 清明续魂灯的GDPL
tbQingMing2012.nQingMingTiaoZhanLingId	= {18, 1, 1705, 5};		-- 英魂挑战令的GDPL
tbQingMing2012.nYingHunJianId			= {18, 1, 1705, 3};		-- 英魂简的GDPL
tbQingMing2012.nLiBaoId 				= {18, 1, 1705, 4};		-- 礼包的GDPL
tbQingMing2012.nYingLingKuiZengId 		= {18, 1, 1705, 6};		-- 英灵的馈赠的GDPL
tbQingMing2012.nNeededCount = 1; 								-- 消耗幽冥香数量加工一个续魂香
tbQingMing2012.nMinFreeBagCellCount = 1; 						-- 加工续魂香的时候最少需要多少个背包空间
tbQingMing2012.nMinFreeBagNpcLingJiang = 1; 					-- NPC领奖需要多少个背包空间
tbQingMing2012.nMinFreeBagCellCount = 1; 						-- 领取英灵npc需要多少个背包空间
tbQingMing2012.nBossLiveTime = 30 * 60 * Env.GAME_FPS; 			-- 召唤出来的BOSS的生存时间（单位:帧）
tbQingMing2012.nYingLingNpcLiveTime = 30 * 60 * Env.GAME_FPS; 	-- 英灵NPC存在时间（单位:帧）
tbQingMing2012.nXianHuaLiveTime = 10 * 60 * Env.GAME_FPS; 		-- 祭祀鲜花存在时间（单位:帧）
tbQingMing2012.tbXianHua ={10134,10135};						-- 鲜花的NPCID
tbQingMing2012.nDengLong = 696;									-- 灯笼特效Id
tbQingMing2012.nYouMinDengMaxCount = 8;							-- 每天最多获得幽冥灯的个数

tbQingMing2012.nGetTiaoZhanLinKinLvl	= 50;					--获取挑战令的家族排名要求
tbQingMing2012.tbGiveStone	=									--奖励玄晶Id
{
		[5] = {18, 1, 114, 5},
		[6] = {18, 1, 114, 6},
		[7] = {18, 1, 114, 7},
		[8] = {18, 1, 114, 8},
		[9] = {18, 1, 114, 9},
};

tbQingMing2012.AWARD_LIST =										--祭祀奖励
{
	[1] = {"stone","玄晶", 1, 483892, 5},
	[2] = {"stone","玄晶", 1, 245349, 6},
	[3] = {"stone","玄晶", 1, 6809, 7},
	[4] = {"money","绑银", 5000, 24099},
	[5] = {"money","绑银", 20000, 43991},
	[6] = {"money","绑银", 80000, 63884},
	[7] = {"gold", "绑金", 50, 24099},
	[8] = {"gold", "绑金", 200, 43991},
	[9] = {"gold", "绑金", 800, 63885},
};


tbQingMing2012.Bonus_ShuHunDeng	= 0.1;							--赎魂灯加成效果/每人

tbQingMing2012.TASKGID = 2192;

--  "云中镇","龙门镇","永乐镇","稻香村","江津村","石鼓镇","龙泉村","巴陵县"
tbQingMing2012.CityName =
{
	"云中镇","龙门镇","永乐镇","稻香村",
	"江津村","石鼓镇","龙泉村","巴陵县",
};
tbQingMing2012.TASK_CITY_JISI = {1, 2, 3, 4, 5, 6, 7, 8};		--本日祭祀变量
tbQingMing2012.TASK_CITY_HIGH = {9, 10, 11, 12, 13, 14, 15, 16};--卡片高亮


tbQingMing2012.TASK_COUNT_YOUMINDENG 	= 17;						--本日已获得幽冥灯数量
tbQingMing2012.TASK_LINGJIANG		 	= 18;						--本日是否已领点亮奖
tbQingMing2012.TASK_HAVEYINGHUNJIAN		= 19;						--拥有英魂简
tbQingMing2012.tbKinGet	= tbQingMing2012.tbKinGet or {};			--家族领取令牌记录

-- 清明挑战令召唤出来的BOSS的列表
tbQingMing2012.tbBoss =
{
	nNpcId = 10132,
	nLevel = 75
};

tbQingMing2012.tbBossNpc =
{
	nNpcId = 10133,
	nLevel = 75
};

tbQingMing2012.nQingMing_NpcId = 10131;
tbQingMing2012.tbNpc=
{
	{7,	1530, 3252},
	{4,	1609, 3221},
	{8,	1694, 3354},
	{5,	1596, 3095},
	{6,	1579, 3125},
	{1,	1384, 3082},
	{3,	1592, 3203},
	{2,	1768, 3573},
};

tbQingMing2012.tbWishMsg =										--清明祝福语
{
	"不必再感慨世事无常、人生苦短;曾经真正爱过，生命便不存在遗憾;即使是天涯地角、即使相隔着无法跨越的横沟，只要心中有爱，生活就有明天。",
	"清明雨是我的泪水，清明的风筝是我的思念。就让风筝飞向天堂，它会带着我的思念温暖你的灵魂。就让雨水回归故土，它会带着我的祝福滋润你的心田！",
	"在这个柳絮纷飞，樱花烂漫的时节化做万片飘零。清明节来了，在这个有爱的日子里，我们应该比以前更懂得如何去爱，更明白怎样去爱!\n剑世有你，真好。",
	"用通达的心对待生命，对待生活。用快乐的心感染生命，感染生活。用感恩的心感激生命，感激生活。清明节，关爱生命，开心生活，祝大家节日快乐！",
	"在这个特殊的节日里，放下你手里的工作。即使你是个工作狂，也在这个特别的日子里稍作变化。生命中还有很多更重要的事情需要我们去做，好好地活。",
	"烟云洒落情一片，雨雾茫然段一年。林飞郁郁情飘然，情海冲冲段开岩。",
	"清明雨是我的泪水，清明的风筝是我的思念。就让风筝飞向天堂，它会带着我的思念温暖你的灵魂。就让雨水回归故土，它会带着我的祝福滋润你的心田！",
	"总是那细雨纷飞，总是那行人匆匆，总是那杜鹃满山，总是那炮竹声声，总是那惦念的惦念。"
};
