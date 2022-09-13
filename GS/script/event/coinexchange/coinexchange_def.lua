-- 文件名　：coinexchange.lua
-- 创建者　：xiewen
-- 创建时间：2009-02-16 15:17:18
-- 更新修改sunduoliang（兑换银两的声望值取5000名玩家的声望值，不再做玩家活跃度计算）

CoinExchange.TASK_GROUP = 2080		-- 兑换福利的任务组
CoinExchange.TASK_XCHG_TIME = 1		-- 兑换时间

CoinExchange.ExchangePlayerMax = 8000 -- 一周最多兑换人数

CoinExchange.nMaxLimitRank = 2000 -- 不受限制排名

CoinExchange.ExchangeAmount = 120000 -- 兑换数量
CoinExchange.__ExchangeRate = 1		-- 兑换比例
CoinExchange.__ExchangeRate_wellfare = EventManager.IVER_nWellFareCoinExChange --福利版兑换比例

CoinExchange.MIN_PRESTIGE = 100 -- 最低威望限制