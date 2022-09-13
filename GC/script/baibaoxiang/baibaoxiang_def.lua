-------------------------------------------------------
-- 文件名　：baibaoxiang_def.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-04-20 10:14:53
-- 文件描述：
-------------------------------------------------------

Baibaoxiang.TASK_GROUP_ID 			= 2086;	-- 百宝箱任务变量组
Baibaoxiang.TASK_BAIBAOXIANG_LEVEL 	= 1;	-- 奖励的总等级
Baibaoxiang.TASK_BAIBAOXIANG_TIMES 	= 2;	-- 玩家转的次数
Baibaoxiang.TASK_BAIBAOXIANG_TYPE 	= 3;	-- 最终奖励类型
Baibaoxiang.TASK_BAIBAOXIANG_COIN 	= 4;	-- 投注贝壳数量
Baibaoxiang.TASK_BAIBAOXIANG_RESULT = 5;	-- 游戏结果(1个32位整数保存最多6次结果)
Baibaoxiang.TASK_BAIBAOXIANG_OVERFLOW = 6;	-- 暴机标志
Baibaoxiang.TASK_BAIBAOXIANG_CONTINUE = 7;	-- 继续标志
Baibaoxiang.TASK_BAIBAOXIANG_WEEKEND = 8;	-- 每周开箱子标记
Baibaoxiang.TASK_BAIBAOXIANG_INTERVAL = 9;	-- 上次点击时间

Baibaoxiang.tbRateStart 	= {};			-- 保存初始概率表
Baibaoxiang.tbRateNormal 	= {};			-- 保存进阶概率表

Baibaoxiang.MAX_LEVEL 	= 6;				-- 最高奖励等级：6级
Baibaoxiang.MAX_EXTRA	= 20000;			-- 彩池奖励上限：2万

Baibaoxiang.COIN_ID		= {18, 1, 325, 1};	-- 贝壳物品ID
Baibaoxiang.BOX_ID		= {18, 1, 324, 1};	-- 箱子物品ID

Baibaoxiang.bOpen 		= EventManager.IVER_bOpenBaiBaoXiang;
Baibaoxiang.bOpenChangeBack 		= EventManager.IVER_bOpenChangeBack;     

-- 表的路径
Baibaoxiang.RATE_START_PATH = "\\setting\\baibaoxiang\\rate_start.txt";
Baibaoxiang.RATE_NORMAL_PATH = "\\setting\\baibaoxiang\\rate_normal.txt";

-- 奖励类型
Baibaoxiang.tbAwardType = 
{
	[1] = "玄晶",
	[2] = "精活",
	[3] = "银两",
	[4] = "绑金",
	[5] = "宝箱",
};

-- 奖励逆照表
Baibaoxiang.tbAwardConType = 
{
	["玄晶"] = 1,
	["精活"] = 2,
	["银两"] = 3,
	["绑金"] = 4,
	["宝箱"] = 5,
};

-- 奖励数值
Baibaoxiang.tbAwardValue = 
{
	["玄晶"] = {4, 5, 6, 7, 8, 9},
	["精活"] = {300, 900, 3000, 10500, 36000, 120000},
	["银两"] = {10000, 30000, 100000, 350000, 1200000, 4000000},
	["绑金"] = {60, 180, 600, 2100, 7200, 24000},
	["宝箱"] = {1},
	["贝壳"] = {1, 3, 10, 35, 120, 400},
};
