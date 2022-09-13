-- 文件名　：worldcup_def.lua
-- 创建者　：furuilei
-- 创建时间：2010-05-17 09:12:48

SpecialEvent.tbWroldCup = SpecialEvent.tbWroldCup or {};
local tbEvent = SpecialEvent.tbWroldCup;

tbEvent.TIME_START	= 20100611;	-- todo furuilei 为了开发和测试的方便，临时修改了一下，发布的时候需要改回正确的时间
tbEvent.TIME_END	= 20100712;
tbEvent.TIME_END_SCORE_AWARD = 20100731;	-- 兑换积分奖励的最后时间
tbEvent.TIME_END_SCORE_CLS 	= 20100912;		-- 清除数据

tbEvent.MAX_TEAM_NUM = 32;						-- 32支球队
tbEvent.MAX_CARD_NUM = tbEvent.MAX_TEAM_NUM;	-- 卡片数量与球队数量
tbEvent.MAX_TIME_PERDAYQA = 3;					-- 每天的最多答题次数
tbEvent.MAX_RANK_NUM = 1500;					-- 收集卡片的排名，最多前1500名
tbEvent.TIME_OUT_DATE = "2010/07/12/23/59/59";
tbEvent.TIME_OUT_DATE_CARDCOLLECTION = "2010/08/12/23/59/59";
tbEvent.MIN_SCORE_AWARD = 50;					-- 兑换积分奖励的最低积分，低于此积分，就算有排名信息也不能兑换奖励
tbEvent.MAX_NUM_IDENTIFY_PERDAY = 6;			-- 每天最多能够鉴定的随机卡片数量
tbEvent.MAX_NUM_IDENTIFY_TOTAL = 150;			-- 活动期间最多可以使用100张随机卡片
tbEvent.NUM_GTPMKP_IDENTIFY = 800;				-- 没鉴定一张随机卡片需要消耗的精活

tbEvent.MONEY_PERPOINT = 100;					-- 回收卡册的时候，没电价值量对应的绑银数额

tbEvent.REPUTE_PER_BADGE = 100;					-- 每个徽章给的声望值

tbEvent.FAIL	= 1;
tbEvent.DRAW	= 2;
tbEvent.WIN		= 3;
tbEvent.tbScore = {
	[tbEvent.FAIL]	= 0,
	[tbEvent.DRAW]	= 1,
	[tbEvent.WIN]	= 3,
	}

-- 各个球队卡片的价值量
tbEvent.tbCardValue = tbEvent.tbCardValue or {};

function tbEvent:InitCardValue()
	for i = 1, tbEvent.MAX_CARD_NUM do
		tbEvent.tbCardValue[i] = 1;
	end
end
tbEvent:InitCardValue()

-- 各个球队的成绩等级（16强？8强？...）
tbEvent.tbTeamLevel = tbEvent.tbTeamLevel or {};

function tbEvent:InitTeamLevel()
	for i = 1, tbEvent.MAX_CARD_NUM do
		tbEvent.tbTeamLevel[i] = 1;
	end
end
tbEvent:InitTeamLevel()

-- 玩家收集卡片价值量的排名
tbEvent.tbRankInfo = tbEvent.tbRankInfo or {};

-- 球队成绩	
tbEvent.LEVEL_GROUP_MATCH = 1;	-- 小组赛
tbEvent.LEVEL_TOP_16 = 2;		-- 16强
tbEvent.LEVEL_TOP_8 = 3;		-- 8强
tbEvent.LEVEL_TOP_4 = 4;		-- 4强
tbEvent.LEVEL_JIJUN = 5;		-- 季军
tbEvent.LEVEL_YAJUN = 6;		-- 亚军
tbEvent.LEVEL_CHAMPION = 7;		-- 冠军
-- 不同档次的成绩对应的积分
tbEvent.Score_Level = {
	[tbEvent.LEVEL_GROUP_MATCH] = 1,
	[tbEvent.LEVEL_TOP_16] = 2,
	[tbEvent.LEVEL_TOP_8] = 4,
	[tbEvent.LEVEL_TOP_4] = 8,
	[tbEvent.LEVEL_JIJUN] = 12,
	[tbEvent.LEVEL_YAJUN] = 16,
	[tbEvent.LEVEL_CHAMPION] = 32,
	};
	
-- 不同档次的成绩对应的特效
tbEvent.tbEffect_Level = {
	[tbEvent.LEVEL_GROUP_MATCH] = 1,
	[tbEvent.LEVEL_TOP_16] = 2,
	[tbEvent.LEVEL_TOP_8] = 3,
	[tbEvent.LEVEL_TOP_4] = 4,
	[tbEvent.LEVEL_JIJUN] = 5,
	[tbEvent.LEVEL_YAJUN] = 6,
	[tbEvent.LEVEL_CHAMPION] = 6,
	};

tbEvent.TASK_GROUP = 2027;
tbEvent.TASKID_START = 114;		-- 从第101号id开始标记世界杯专用任务变量。从这个id开始的前32个表示32个球队的卡片收集数量
tbEvent.TASKID_DATE_LASTQA = 147;	-- 上次的答题日期
tbEvent.TASKID_NUM_TODAYQA = 148;	-- 今天的答题次数
tbEvent.TASKID_FLAG_QAAWARD = 149;	-- 是否需要领取答题奖励的标志（如果包裹空间满了，导致没有领取奖励，这个变量置1）
tbEvent.TASKID_FLAG_GETAWARD = 150;	-- 是否领取过积分奖励的标志
tbEvent.TASKID_NUM_IDENTIFY_TODAY = 151;	-- 当天鉴定的随即卡片次数
tbEvent.TASKID_DATE_LASTIDENDIFY = 152;		-- 上次鉴定随即卡片的日期
tbEvent.TASKID_NUM_IDENTIFY_TOTAL = 153;	-- 活动期间一共鉴定的随即卡片数量

tbEvent.tbGDPL_MASK = {18, 1, 662, 1};	-- 面具，世界杯宠物沃德卡普
tbEvent.tbGDPL_BOX = {18, 1, 661, 1};		-- 道具，活动宝箱
tbEvent.tbGDPL_CARDCOLLECTION = {18, 1, 657, 1}; -- 卡册

tbEvent.TB_FINAL_AWARD = {
	{nMinRank = 1, nMaxRank = 1, nMinScore = 256, tbAward = {{tbGDPL = {18, 1, 663, 1}, nCount = 50, bStack = 1}}},
	{nMinRank = 2, nMaxRank = 10, nMinScore = 192, tbAward = {{tbGDPL = {18, 1, 663, 1}, nCount = 10, bStack = 1}}},
	{nMinRank = 11, nMaxRank = 50, nMinScore = 128, tbAward = {{tbGDPL = {18, 1, 663, 1}, nCount = 5, bStack = 1}}},
	{nMinRank = 51, nMaxRank = 100, nMinScore = 96, tbAward = {{tbGDPL = {18, 1, 663, 1}, nCount = 2, bStack = 1}, {tbGDPL = {18, 1, 661, 1}, nCount = 2, bStack = 0}}},
	{nMinRank = 101, nMaxRank = 500, nMinScore = 64, tbAward = {{tbGDPL = {18, 1, 661, 1}, nCount = 3, bStack = 0}}},
	{nMinRank = 501, nMaxRank = 1500, nMinScore = 32, tbAward = {{tbGDPL = {18, 1, 661, 1}, nCount = 2, bStack = 0}}},
	{nMinRank = 1501, nMaxRank = 1000000, nMinScore = 50, tbAward = {{tbGDPL = {18, 1, 661, 1}, nCount = 1, bStack = 0}}},
	};
