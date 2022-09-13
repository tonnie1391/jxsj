-- 文件名　：weekendfish_def.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-08-05 11:48:10
-- 描  述  ：
if MODULE_GAMECLIENT then
	return;
end

WeekendFish._OPEN			= 1;		-- 系统开关

WeekendFish.TASK_MAIN_ID	= 60001;	
WeekendFish.TXT_NAME		= "【钓鱼活动】";

WeekendFish.TASK_GROUP			= 2174;		-- 主任务ID
WeekendFish.TASK_ACCEPT_DAY		= 1;		-- 接任务日期
WeekendFish.TASK_AWARD_DAY		= 2;		-- 最后领奖日期
WeekendFish.TASK_TEAM_IDGROUP	= 3;		-- 组队接任务预存的任务变量
WeekendFish.TASK_TODAY_FISHTIMES= 4;		-- 今日钓鱼次数
WeekendFish.TASK_FISH_TIMES		= 5;		-- 总钓鱼次数
WeekendFish.TASK_FISHING_STATE	= 6;		-- 钓鱼的状态
WeekendFish.TASK_MAKE_DAY		= 7;		-- 做鱼饵的日期
WeekendFish.TASK_TODAY_MAKE_NUM	= 8;		-- 做鱼饵的数量
WeekendFish.TASK_HANDIN_WEIGHT	= 9;		-- 今日交鱼的重量
WeekendFish.TASK_HANDIN_NUM		= 31;		-- 交鱼的数量，用来校验，防止刷了多交
WeekendFish.TASK_HANDIN_AWARD	= 32;		-- 今日是否领取了交鱼奖励
WeekendFish.TASK_ACHIEVEBUF_WEEK= 33;		-- 任务buf的周数
WeekendFish.TASK_ACHEIVEBUF_NUM = 34;		-- 本周交任务的次数
WeekendFish.TASK_FISH_DAY		= 35;		-- 钓鱼的日期
WeekendFish.TASK_RANK_WEEK		= 36;		-- 身上的排行版重量是第几周的数据
WeekendFish.TASK_HANDIN_DAY		= 37;		-- 交鱼的日期
WeekendFish.TASK_HANDIN_TOTLANUM= 38;		-- 总交鱼的斤数
WeekendFish.TASK_FIRSTFISH_TIME	= 39;		-- 每日第一次钓鱼的时间
WeekendFish.TASK_FISH_ID1		= 10;		-- 需要的鱼变量,注意保持连续
WeekendFish.TASK_FISH_ID2		= 11;
WeekendFish.TASK_FISH_ID3		= 12;
WeekendFish.TASK_FISH_ID4		= 13;
WeekendFish.TASK_FISH_ID5		= 14;
--WeekendFish.TASK_FISH_ID6		= 15;
WeekendFish.TASK_TARGET1		= 20;		-- 任务系统所用的变量
WeekendFish.TASK_TARGET2		= 21;
WeekendFish.TASK_TARGET3		= 22;
WeekendFish.TASK_TARGET4		= 23;
WeekendFish.TASK_TARGET5		= 24;
--WeekendFish.TASK_TARGET6		= 25;
WeekendFish.TASK_WEIGHT_FISH1	= 40;		-- 任务鱼1交的重量
WeekendFish.TASK_WEIGHT_FISH2	= 41;		-- 任务鱼2交的重量
WeekendFish.TASK_WEIGHT_FISH3	= 42;		-- 任务鱼3交的重量


WeekendFish.PLAYER_LEVEL_LIMIT	= 30;	-- 等级限制
WeekendFish.NUM_GTPMKP_MAKE		= 30;	-- 精致鱼饵需要的精活
WeekendFish.DAY_MAKE_NUM_LIMIT	= 50;	-- 每日最多制作个数

WeekendFish.BASEEXP_NUM			= 8 * 60;	-- 基准经验的时间

WeekendFish.ACCELERATE_DAYLIMIT = 180;	-- 180天后才产出加速声望符（不包括180天）
WeekendFish.MAX_FISH_KIND		= 25;	-- 鱼的种类
WeekendFish.RANK_FISH_KIND_NUM	= 3;	-- 当天会出现在排行榜上的鱼,每个玩家都会随到
WeekendFish.FISH_TASK_NUM		= 5;	-- 每个人玩家随五条鱼

WeekendFish.MAX_FISH_DAYTIMES	= 50;	-- 每日最多钓50次
WeekendFish.TASK_NEED_FISH_NUM	= 5;	-- 任务所需的鱼数量

WeekendFish.MAX_REFRESH_NUM		= 14;	-- 刷新的堆数
WeekendFish.MAX_FISH_RANGE		= 25;	-- 检测鱼群范围
WeekendFish.MAX_FLOAT_RANGE		= 30;	-- 鱼漂的最大范围
WeekendFish.MAX_FISH_TIMES		= 6;	-- 最多可钓次数
WeekendFish.MAX_FISHING_NUM		= 6;	-- 同时钓的次数

WeekendFish.AWARD_NORECOMMENDATION	= 0.5;	-- 没有水产凭证只能拿50%的奖励 

WeekendFish.STATE_SKILLID		= 2222;
WeekendFish.STATE_TIME			= 2 * 24 * 60 * 60 * 18;
WeekendFish.MAX_LUCKFISH_RANK	= 10;	-- 幸运鱼排行
WeekendFish.MAX_LUCKFISH_AWARD_RANK = 5;	-- 幸运鱼领奖排名
WeekendFish.FLOAT_SKILLID		= 2221;-- 鱼上钩特效
WeekendFish.SHOUGAN_SKILLID		= 2224;	-- 收杆上鱼的特效
WeekendFish.XIAGAN_SKILLID		= 2225;	-- 下杆特效
WeekendFish.FISH_SUCCESS_SKILLID=
{
	[1] = 2227,
	[2] = 2228,
	[3] = 2229,
	[4] = 2230,	
};

WeekendFish.LUCKRANK_OPEN_WEEKDAY	= 0;	-- 星期天23:50开启领奖
WeekendFish.LUCKRANK_CLOSE_WEEKDAY	= 5;	-- 星期天23:50关闭领奖
-- 杂物给予的绑银
WeekendFish.PRICE_ZAWU			= 100;	-- 杂物给予的绑银
-- 概率表
WeekendFish.RAND_HOOKED			= 50;	-- 每10秒鱼上钩的概率
WeekendFish.RAND_IS_FISH		= 90;	-- 随机是鱼或者杂物
WeekendFish.RAND_FISHWEIGHT		=	-- 每个概率总和一千
{
	[1] = 
	{
		[1] = {59, 1, 2},	-- 概率，重量下限，重量上限 
		[2] = {118, 3, 4},
		[3] = {176, 5, 6},
		[4] = {353, 7, 7},
		[5] = {294, 8, 8},
	},
	[2] = 
	{
		[1] = {143, 3, 4},	-- 概率，重量下限，重量上限 
		[2] = {214, 5, 6},
		[3] = {429, 7, 8},
		[4] = {214, 9, 9},
	},
	[3] = 
	{
		[1] = {91, 10, 15},	-- 概率，重量下限，重量上限 
		[2] = {182, 16, 20},
		[3] = {455, 21, 35},
		[4] = {182, 36, 40},
		[5] = {90, 41, 45},
	},
	[4] = 
	{
		[1] = {95, 10, 15},	-- 概率，重量下限，重量上限 
		[2] = {190, 16, 20},
		[3] = {476, 21, 40},
		[4] = {238, 41, 45},
		[5] = {1, 46, 50},
	},
};

-- 中魂勋章的概率
WeekendFish.RANK_FRAGMENT = {[3] = 178, [4] = 357}; -- 总概率10000
-- 洞玄寒铁的概率
WeekendFish.DONGXUANHANTIE = {[2] = 1250, [3] = 2000, [4] = 5000};	-- 总概率10000

WeekendFish.FISH_WEIGHT_LEVEL	=
{
	[1] = 1,
	[2] = 20,
	[3] = 30,
	[4] = 40,
};

WeekendFish.AWARD_LEVEL =
{
	[1] = {60, 1, 0, 0, 0},
	[2] = {120, 2, 0, 0, 0},	-- 所需的重量，A,B,C,D宝箱的个数	
	[3] = {200, 5, 0, 0, 0},
	[4] = {500, 6, 2, 0, 0},
	[5] = {900, 2, 5, 2, 0},
	[6] = {1400, 0, 4, 5, 1},
	[7] = {1700, 0, 0, 0, 5},
};

WeekendFish.ITEM_AWARD_BOX = {18, 1, 1445, 1};

WeekendFish.TOTAL_FISH_TIMES	= 5;	-- 一轮钓鱼的次数
WeekendFish.DELAY_ADDFISH_TIME	= 30 * Env.GAME_FPS;	-- 延迟30秒刷
WeekendFish.PROCESS_TIME		= 33 * Env.GAME_FPS;
WeekendFish.DETECT_FISHING		= 6 * Env.GAME_FPS;
WeekendFish.SHINE_TIME			= 3 * Env.GAME_FPS;
WeekendFish.DETECT_FISH_SORT	= 6 * Env.GAME_FPS;	-- 检查鱼种类的时间
WeekendFish.NOTICE_PROMPT_TIME	= 20 * 60 * Env.GAME_FPS;	-- 公告提示时间 

WeekendFish.FLOAT_POS	=
{
	[1] = {0, 0},
	[2] = {0, 2},
	[3] = {2, 0},
	[4] = {-2, 0},
	[5] = {0, -2},
	[6] = {-2, -2}	
};

WeekendFish.ITEM_FISH_ID = {};	-- 25种鱼
for i = 1, 25 do
	WeekendFish.ITEM_FISH_ID[i] = {18, 1, 1364 + i, 1};	-- 不连续需要手动添加
end

WeekendFish.ITEM_SUNDRIES_ID = {};
for i = 1, 20 do
	WeekendFish.ITEM_SUNDRIES_ID[i] = {18, 1, 1395 + i, 1};
end

WeekendFish.ITEM_FISHBAIT	= 
{
	[1] = {18, 1, 1391, 1},
	[2] = {18, 1, 1392, 1},
};

WeekendFish.ITEM_MATERIAL_FISHBAILT_FINE	= {18, 1, 1393, 1};

WeekendFish.ITEM_LUCKRANK_BAG	=	-- 幸运鱼排行帮给的背包
{
	[1] = {21, 7, 11, 1},	-- 18 格包
	[2] = {21, 6, 11, 1},	-- 15 格包
};
WeekendFish.ITEM_FRAGMENT_ID = {18, 1, 1300, 1};	-- 碎片
WeekendFish.ITEM_RECOMMENDATION	= {18, 1, 1446, 1};	-- 水产大师推荐信
WeekendFish.ITEM_DONGXUANHANTIE = {18, 1, 1529, 1};	-- 洞玄寒铁
WeekendFish.ITEM_YUEYING = {18, 1, 476, 1}; -- 月影之石

WeekendFish.NPC_FISH_ID	= 
{
	[1] = 9648,
	[2] = 9649,
	[3] = 9650,
	[4] = 9651,
	[5] = 9652,
};
WeekendFish.FISH_FLOAT	=	
{
	[1] = 9653,
	[2] = 9654,
	[3] = 9655,
	[4] = 9656,
	[5] = 9657,
};
WeekendFish.NPC_DETECT	= 9658;
WeekendFish.NPC_HIDE	= 9660;
WeekendFish.AREA_INDEX	=
{
	[1] = {1, 2, 3, 4, 5},
	[2] = {6, 7, 8, 9, 10},
	[3] = {11, 12, 13, 14, 15},
	[4] = {16, 17, 18, 19, 20},
	[5] = {21, 22, 23, 24, 25},	
};

WeekendFish.REFRESHTASK_WEEK		= 6;		-- 每星期六更新幸运鱼
WeekendFish.TB_ACCEPTTASKWEEKDAY	= {0,6};	-- 可接任务的日期
WeekendFish.ACCEPTTASKWEEKDAY_BEG	= 100000;	-- 可接任务的开始时间
WeekendFish.ACCEPTTASKWEEKDAY_END	= 200000;	-- 可接任务的结束时间
WeekendFish.AWARDTASKWEEKDAY_BEG	= 100000;	-- 领奖开始时间
WeekendFish.AWARDTASKWEEKDAY_END	= 233000;	-- 领奖结束时间
WeekendFish.REFRESHFISHTIME_BEG	=
{
	[1] = {100000, 140000},
	[2] = {160000, 200000},	
};

WeekendFish.tbLuckFishRank_Ex = {};

WeekendFish.FILE_TASK_INI_PATH	= "\\setting\\task\\weekednfish\\taskini.txt";	-- 任务配置表
WeekendFish.FILE_FISH_POS_PATH	= "\\setting\\task\\weekednfish\\fish_pos.txt"; -- 鱼位置，木挂客户端