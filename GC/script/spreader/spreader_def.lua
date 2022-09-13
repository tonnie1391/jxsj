-- 文件名　：spreader_def.lua
-- 创建者　：xiewen
-- 创建时间：2008-12-29 16:11:03

Spreader.ZoneGroup = nil;			-- 区服号

if MODULE_GAMESERVER then
	Spreader.TASK_GROUP 		= 2070;
	Spreader.TASKID_CONSUME 	= 1;		-- 累积的消费额(GS)
	Spreader.TSK_IBSHOP_GOURP 	= 2070;		-- 奇珍阁消费	
	Spreader.TSK_IBSHOP_COSUME 	= 2;		-- 奇珍阁消费额（每月清空）
	Spreader.TSK_IBSHOP_MONTH 	= 3;		-- 奇珍阁消费额月份
	Spreader.TSK_IBSHOP_MONTH_LAST = 4;	-- 奇珍阁消费额上月
	Spreader.TSK_IBSHOP_MONTH_ALL = 5;	-- 奇珍阁消费额总的
	Spreader.TSK_IBSHOP_MONEY = 6;	-- 奇珍阁消费额总的  货币类型
	Spreader.TSK_IBSHOP_MONEY_BATCH = 7;	-- 奇珍阁消费额总的  货币类型 批次（第一次累积之前所有的消耗额度）
	Spreader.TSK_IBSHOP_MONEY_YEAR = 8;	-- 奇珍阁消费额总的  货币类型 批次（第一次累积之前所有的消耗额度）
	Spreader.TSK_IBSHOP_OTHER = 9;		--积分返还额外值
	Spreader.TSK_IBSHOP_MONEY_LASTYEAR = 10;		--保存上一年的积分
end

if MODULE_GC_SERVER then
	-- 发送消费记录的两个条件(满足其一即可)
	Spreader.SEND_INTERVAL = 3600;	-- 距上次发送超过1小时
	Spreader.MIN_CONSUME = 1000;	-- 累计消费额超过￥10.00
end

Spreader.ExchangeRate_Gold2JingHuo = 25;	-- 金币兑精活
Spreader.ExchangeRate_Gold2Jxb = 150;	-- 金币换银两的默认汇率
Spreader.ExchangeRate_Rmb2Gold = 100;	-- 人民币兑金币

Spreader.GOUHUNYU = 12000;	-- 高级勾魂玉价格


-----------------------类型枚举Begin(和gamecenter/kgc_normalprotocoldef.h里的要一致)-----------------
Spreader.emKTYPE_SPREADER = 1			-- 推广员
Spreader.emKTYPE_REDUX_PLAYER = 2 		-- 老玩家召回
------------------------类型枚举End(和gamecenter/kgc_normalprotocoldef.h里的要一致)------------------

-----------------------消耗途径枚举Start(和kitemmgr.h里的要一致)-------------------
Spreader.emITEM_CONSUMEMODE_NORMAL = 0
Spreader.emITEM_CONSUMEMODE_REALCONSUME_START = 1								-- 真实消耗

Spreader.emITEM_CONSUMEMODE_SELL = Spreader.emITEM_CONSUMEMODE_REALCONSUME_START -- 卖商店
Spreader.emITEM_CONSUMEMODE_ENCHASER = 2										-- 装备升级
Spreader.emITEM_CONSUMEMODE_USINGTIMESEND = 3									-- 使用次数用完
Spreader.emITEM_CONSUMEMODE_USINGTIMEOUT = 4									-- 使用时间到
Spreader.emITEM_CONSUMEMODE_EXPIREDTIMEOUT = 5									-- 保值期到
Spreader.emITEM_CONSUMEMODE_EAT_QUICK = 6										-- 通过右键或快捷键使用(吃掉)
Spreader.emITEM_CONSUMEMODE_EAT = 7												-- 通过脚本使用(吃掉)
Spreader.emITEM_CONSUMEMODE_CONSUME = 8											-- 通过脚本消耗
Spreader.emITEM_CONSUMEMODE_ERRORLOST_STACK = 9									-- 因物品叠加异常删除
Spreader.emITEM_CONSUMEMODE_PICKUP = 10											-- 捡起即消失
Spreader.emITEM_CONSUMEMODE_COMMONSCRIPT = 11									-- 通过通用脚本删除
Spreader.emITEM_CONSUMEMODE_DUPEDITEM = 12										-- 因复制品而被删除
Spreader.emITEM_CONSUMEMODE_ERRORLOST_PK = 13									-- 因PK原因丢失，异常删除
Spreader.emITEM_CONSUMEMODE_ERRORLOST_THROWALLITEM = 14							-- 因丢物品到地上，异常删除
Spreader.emITEM_CONSUMEMODE_ERRORLOST_ADDONBODY = 15							-- 因向身上添加物品失败，异常删除

Spreader.emITEM_CONSUMEMODE_REALCONSUME_END = Spreader.emITEM_CONSUMEMODE_ERRORLOST_ADDONBODY	-- 正常消耗
Spreader.emITEM_CONSUMEMODE_STACK = 16											-- 因物品叠加
-------------------------------消耗途径枚举End------------------------------------
