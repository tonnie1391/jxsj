-- 交易税数据定义

local preEnv = _G;	--保存旧的环境
setfenv(1, TradeTax);	--设置当前环境为TradeTax;

MIN_WEIWANG 		= 500;
TAX_TO_WELFARE		= 0.8;	-- 税收与福利转换率
UNIT_WEL_MAX		= 50000

-- 玩家任务变量
TAX_TASK_GROUP		= 2022; -- 任务组ID号
TAX_WEL_JOU_TASK_ID = 1;	-- 周福利流水号
TAX_LEVEL_TASK_ID 	= 2;	-- 福利档次
TAX_AMOUNT_TASK_ID	= 3;	-- 本周交易额
TAX_JOU_TASK_ID		= 4;	-- 交易记录周流水号
TAX_ACCOUNT_TASK_ID	= 5;	-- 本周交税情况
CLEAR_DATE			= 0;	-- 周日0点更新

TAX_REGION_MAXNUMBER	= 0.20	-- 30000001+ 收税 20%
TAX_CHANGED			= 0;

-- TODO:临时的收税区
ORIG_TAX_REGION = 
{
	[1] = {800000,  	0},
	[2] = {2000000, 	0.02},
	[3] = {5000000, 	0.05},
	[4] = {10000000, 	0.10},
	[5] = {30000000, 	0.15},
}

-- 计算使用
TAX_REGION = 
{
	[1] = {800000,  	0},
	[2] = {2000000, 	0.02},
	[3] = {5000000, 	0.05},
	[4] = {10000000, 	0.10},
	[5] = {30000000, 	0.15},
}

-- TODO：临时福利档次对应表
WELFARE_LEVEL = 
{
	[1] = {500, 		2},
	[2] = {1000,		4},
	[3] = {1500, 		5},
}

-- 金币转账协议
TRANSFER_COIN_AUCTION = 1;

tbTransferCoinCallBack = {};

--恢复全局环境
preEnv.setfenv(1, preEnv);
