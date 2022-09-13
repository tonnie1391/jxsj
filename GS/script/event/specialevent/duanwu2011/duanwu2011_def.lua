-- 文件名　：define.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-05-17 09:46:10
-- 描  述  ：

SpecialEvent.DuanWu2011 = SpecialEvent.DuanWu2011 or {};
local tbDuanWu2011 = SpecialEvent.DuanWu2011 or {};

tbDuanWu2011.IS_OPEN					= 1;				-- 系统开关

tbDuanWu2011.TASK_GROUP_ID				= 2027;
tbDuanWu2011.TASK_LAST_MAKE_DAY			= 211;				-- 最后一次做粽子的日期
tbDuanWu2011.TASK_TODAY_MAKE_NUM		= 212;				-- 今天做粽子的个数
tbDuanWu2011.TASK_TOTAL_MAKE_NUM		= 213;				-- 活动期间做的总个数
tbDuanWu2011.TASK_LAST_FISH_DAY			= 214;				-- 最后一次钓鱼日期
tbDuanWu2011.TASK_TODAY_FISH_NUM		= 215;				-- 今日钓鱼个数
tbDuanWu2011.TASK_YESTODAY_FISH_NUM		= 216;				-- 前一天钓鱼数
tbDuanWu2011.TASK_TOTAL_FISH_NUM		= 217;				-- 总钓鱼数
tbDuanWu2011.TASK_GET_AWARD				= 218;				-- 是否领取了忠魂袋，日期跟钓鱼日期一样
tbDuanWu2011.TASK_DUIHUAN_NUM			= 219;				-- 兑换箱子的个数

tbDuanWu2011.ITEM_MATERIAL_MEAT_ID		= {18, 1, 1292, 1};	-- 肉
tbDuanWu2011.ITEM_MATERIAL_RICE_ID 		= {18, 1, 1293, 1};	-- 糯米
tbDuanWu2011.ITEM_MATERIAL_LEAF_ID		= {18, 1, 1294, 1};	-- 粽叶

tbDuanWu2011.ITEM_DUMPLING_MEAT_ID		= {18, 1, 1295, 1}; -- 肉粽 
--tbDuanWu2011.ITEM_DUMPLING_REDDATE_ID	= {18, 1, 1296, 1}; -- 红枣粽

tbDuanWu2011.ITEM_TBALBE_FISH_ID		= 
{
	[1] = {18, 1, 1296, 1}, -- 青鱼
	[2] = {18, 1, 1296, 2}, -- 鲤鱼
	[3] = {18, 1, 1296, 3}, -- 鲫鱼
	[4] = {18, 1, 1296, 4}, -- 霸王鱼
}

tbDuanWu2011.ITEM_MEDALS_ID				= {18, 1, 1297, 1};	-- 勋章
tbDuanWu2011.ITEM_LINGPAI_ID			= {18, 1, 1301, 1};	-- 令牌
tbDuanWu2011.ITEM_ZHONGHUN_BAG_ID		= {18, 1, 1299, 1};	-- 忠魂袋
tbDuanWu2011.ITEM_FRAGMENT_ID			= {18, 1, 1300, 1};	-- 碎片

tbDuanWu2011.ITEM_AWARDBOX_ID			=
{
	[1] = {18, 1, 1302, 1}, -- 青鱼
	[2] = {18, 1, 1302, 2}, -- 鲤鱼
	[3] = {18, 1, 1302, 3}, -- 鲫鱼
	[4] = {18, 1, 1302, 4}, -- 霸王鱼
};
tbDuanWu2011.ITEM_LIANHUATU_ID	=
{
	[1] = {18, 1, 1305, 1},	-- 中级炼化图
	[2] = {18, 1, 1305, 2},	-- 高级炼化图
};
tbDuanWu2011.NPC_SHAOL_ID	= 9543;	-- 鱼群
tbDuanWu2011.NPC_DUMPLING_ID= 9544;	-- 粽子
tbDuanWu2011.NPC_BOSS_ID	= 9545; -- 端午boss
tbDuanWu2011.NPC_QUYUAN_ID	= 9546; -- 屈原忠魂

tbDuanWu2011.OPEN_DAY			= 20110602;
tbDuanWu2011.CLOSE_DAY			= 20110608;
tbDuanWu2011.CLEARBUF_DAY		= 20110615;

tbDuanWu2011.RANK_OPEN_DAY 		= 20110603;
tbDuanWu2011.RANK_CLOSE_DAY 	= 20110609;

tbDuanWu2011.FISH_START_TIME	=  90000;
tbDuanWu2011.FISH_CLOSE_TIME	= 235500;

tbDuanWu2011.PLAYER_LEVEL_LIMIT		= 60;	-- 等级
tbDuanWu2011.NUM_GTPMKP_MAKE		= 100;	-- 需要的精活
tbDuanWu2011.DAY_MAKE_NUM_LIMIT		= 30;	-- 每日制作个数
tbDuanWu2011.TOTAL_MAKE_NUM_LIMIT	= 210;	-- 总制作个数
tbDuanWu2011.DAY_FISH_NUM_LIMIT		= 30;	-- 每日钓鱼个数
tbDuanWu2011.TOTAL_FISH_NUM_LIMIT	= 210;	-- 总钓鱼个数

tbDuanWu2011.ITEM_VALIDITY_DUMPLING = 24 * 3600;	-- 粽子有效期
tbDuanWu2011.ITEM_VALIDITY_ZHONGHUNDAI= 7 * 24 * 3600;	-- 忠魂袋有效期
tbDuanWu2011.ITEM_VALIDITY_BOX		= 7 * 24 * 3600;-- 鱼锦盒的有效期

tbDuanWu2011.MEDALS_POINT		= 5;	-- 勋章积分
tbDuanWu2011.MAX_VALID_RANK		= 15;	-- 有效的最大的排名
tbDuanWu2011.MAX_AWARD_RANK		= 10;	-- 能领奖的最大排名

tbDuanWu2011.MAX_FEED_TIMES		= 10;		-- 一个鱼群最多喂食次数
tbDuanWu2011.MIN_AWARD_FEED_TIMES = 10;		-- 领忠魂奖励最少需要喂食的次数
tbDuanWu2011.DELAY_FEED_TIME	= 8 * 18;	-- 喂食之后收获延迟时间
tbDuanWu2011.FISH_REFRESH_COUNT	= 10;		-- 每个gs刷鱼堆的个数
tbDuanWu2011.DELAY_ADDSHOAL_TIME= 10 * 18;	-- 一个鱼群结束之后重新添加的时间
tbDuanWu2011.MIN_WEALTHORDER	= 5000;
tbDuanWu2011.MAX_KIN_MEDALS_RANK= 200;		-- 每天前200个有名次
tbDuanWu2011.DUANWU_REPUTE		= 50;		-- 碎片加的声望
tbDuanWu2011.MAX_FISH_RANGE		= 25;

function tbDuanWu2011:CheckOpen()
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate < self.OPEN_DAY or nDate > self.CLOSE_DAY then
		return 0;
	end
	return self.IS_OPEN;
end

-- 定义一下全局变量，防止出错
tbDuanWu2011.nDataVer = tbDuanWu2011.nDataVer or 0;	-- 数据版本
tbDuanWu2011.tbTodayRank = tbDuanWu2011.tbTodayRank or {};-- 今日排名，记前200名家族
tbDuanWu2011.tbYestodayRank = tbDuanWu2011.tbYestodayRank or {};-- 昨日排名，记前10名家族 
tbDuanWu2011.tbAwardRecord = tbDuanWu2011.tbAwardRecord or {}; --领奖记录

tbDuanWu2011.SHOAL_FILEPATH	= "\\setting\\event\\specialevent\\duanwu2011\\shoal.txt";
tbDuanWu2011.EQUIT_CHANGE_FILEPATH = "\\setting\\event\\specialevent\\duanwu2011\\duanwu_equit.txt";

tbDuanWu2011.TABLE_FISH_RAND =	--出四种鱼的概率，概率总和为1000
{
	[1] = 
	{
		[1] = 550,
		[2] = 350,
		[3] = 75,
		[4] = 25,
	},
	[2] =
	{
		[1] = 560,
		[2] = 360,
		[3] = 75,
		[4] = 5,
	},	
};


tbDuanWu2011.MEDALS_RAND	= 20;	-- 出勋章的概率，综合为100

tbDuanWu2011.TABLE_DUMPLING_POS = 	-- 粽子相对鱼群的位置
{
	[1] = {0, 0},	
	[2] = {-1, -1},
	[3] = {1, 1},
	[4] = {1, -1},
	[5] = {-1, 1},
	[6] = {0, -1},
	[7] = {0, 1},
	[8] = {-1, 0},
	[9] = {1, 0},
};

tbDuanWu2011.BAWANGYU_FRAGMENT_RAND	= {235, 50}; -- 总概率1000