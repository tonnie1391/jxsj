  --
-- FileName: qingming_def.lua
-- Author: hanruofei
-- Time: 2011/3/22 11:57
-- Comment: 2011清明节常量定义
--
SpecialEvent.tbQingMing2011 =  SpecialEvent.tbQingMing2011 or {};
local tbQingMing2011 = SpecialEvent.tbQingMing2011;
tbQingMing2011.nStartTime = 20110404;					-- 活动开始时间
tbQingMing2011.nEndTime = 20110407;						-- 活动结束时间，这天就不能做活动了
tbQingMing2011.nMinLevel = 60;							-- 活动最低等级要求
tbQingMing2011.nCostMKP = 800;							-- 制造清明召唤令需要消耗的精力
tbQingMing2011.nCostGTP = 800;  							-- 制造清明召唤令需要消耗的活力
tbQingMing2011.nQingMingXuanXiangId = {18, 1, 1247, 1}; 	-- 清明玄香的GDPL
tbQingMing2011.nQingMingTiaoZhanLing = {18, 1, 1246, 1};	-- 清明召唤令的GDPL
tbQingMing2011.nTaQingDaiId = {};						-- 踏青袋的GDPL
tbQingMing2011.nYongZheDaiId = {};						-- 勇者袋的GDPL
tbQingMing2011.nNeededCount = 2; 						-- 消耗多少清明玄香加工一个令牌
tbQingMing2011.nMinFreeBagCellCount = 1; 				-- 加工清明挑战令的时候最少需要多少个背包空间
tbQingMing2011.nProcessDuration = 2 * Env.GAME_FPS;		-- 加工清明挑战令需要的读条时间（单位:帧）
tbQingMing2011.nGetAwardDuration = 2 * Env.GAME_FPS;	-- 获得奖励的读条时间（单位:帧）
tbQingMing2011.szGetAwardMsg = "获得奖励..."; 			-- 获得奖励的读条提示
tbQingMing2011.szProduceMsg = "加工清明挑战令...";		-- 加工清明挑战令时的提示
tbQingMing2011.nBossLiveTime = 30 * 60 * Env.GAME_FPS; 	-- 召唤出来的BOSS的生存时间（单位:帧）
tbQingMing2011.nXiangLuLiveTime = 10 * 60 * Env.GAME_FPS; 	-- 香炉存在时间（单位:帧）
tbQingMing2011.tbXiangLu = {nNpcId = 7385, nLevel = 1}; -- 香炉的NPCID
tbQingMing2011.nHelperAwardMaxCount = 9;				-- 每天最多领取分享奖励的次数
tbQingMing2011.nMaxHelperAwardCount = 5;				-- 每个香炉最多可以被领的分享奖励次数
tbQingMing2011.nQingMingZhaoHuanLingLiveTime = 3 * 24 * 60 * 60; -- 清明召唤令的有效期（ 单位秒）
tbQingMing2011.nQingMingJiangLiDaiLiveTime = 7 * 24 * 60 * 60; 	-- 清明勇者袋，清明至圣袋的有效期

tbQingMing2011.TASKGID = 2160;
tbQingMing2011.TASK_DATE = 1;
tbQingMing2011.TASK_COUNT_PER_DAY = 2;
tbQingMing2011.TASK_DATE_AWARD_PER_DAY = 3;
tbQingMing2011.TASK_AWARD_COUNT = 4;
tbQingMing2011.TASK_PRODUCED_COUNT = 5;	-- 活动期间已经加工的清明挑战令个数的任务变量位置

tbQingMing2011.tbBreakEvent = 
{
	Player.ProcessBreakEvent.emEVENT_MOVE,
	Player.ProcessBreakEvent.emEVENT_ATTACK,
	Player.ProcessBreakEvent.emEVENT_SITE,
	Player.ProcessBreakEvent.emEVENT_USEITEM,
	Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
	Player.ProcessBreakEvent.emEVENT_DROPITEM,
	Player.ProcessBreakEvent.emEVENT_SENDMAIL,		
	Player.ProcessBreakEvent.emEVENT_TRADE,
	Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
	Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
	Player.ProcessBreakEvent.emEVENT_ATTACKED,
	Player.ProcessBreakEvent.emEVENT_DEATH,
	Player.ProcessBreakEvent.emEVENT_LOGOUT,
};

-- 清明挑战令召唤出来的BOSS的列表
tbQingMing2011.tbBosses =
{
	[1] = {nNpcId = 7377, nLevel = 75},
	[2] = {nNpcId = 7378, nLevel = 75},
	[3] = {nNpcId = 7379, nLevel = 75},
	[4] = {nNpcId = 7380, nLevel = 85},
	[5] = {nNpcId = 7381, nLevel = 85},
	[6] = {nNpcId = 7382, nLevel = 85},
	[7] = {nNpcId = 7383, nLevel = 85},
	[8] = {nNpcId = 7384, nLevel = 90},
};

-- 击败召唤出来的BOSS获得的奖励的列表，根据tbQingMing2011.tbBossGroups中每项的nGroupId决定奖励级别
-- tbQingMing2011.tbAward 表中的Key代表nGroupId
tbQingMing2011.tbAward = 
{
	[1] = 
	{
		Caller = {1, {18,1,1248, 1}, "你获得了1个清明勇者袋"},
		Helper=	{50000,},
	},
	[2] = 
	{
		Caller = {2, {18,1,1248, 1}, "你获得了2个清明勇者袋"},
		Helper=	{95000,},
	},
	[3] = 
	{
		Caller = {4, {18,1,1248, 1},"你获得了4个清明勇者袋"},
		Helper=	{200000,},
	},
	[4] =
	{
		Caller = {2, {18,1,1248, 2}, "你获得了2个清明至圣袋"},
		Helper=	{1000000,},
	},
};

-- 召唤出来的BOSS的分组信息，fProbability表示召唤到该组的概率（百分数的点数）
tbQingMing2011.tbBossGroups =
{
	{nGroupId = 1, tbBosses = {1,2,3},	nProbability = 6900, tbAward = tbQingMing2011.tbAward[1]},
	{nGroupId = 2, tbBosses = {4,5},	nProbability = 2250, tbAward = tbQingMing2011.tbAward[2]},
	{nGroupId = 3, tbBosses = {6,7},	nProbability = 750, tbAward = tbQingMing2011.tbAward[3]},
	{nGroupId = 4, tbBosses = {8},		nProbability = 100, tbAward = tbQingMing2011.tbAward[4]},
};


