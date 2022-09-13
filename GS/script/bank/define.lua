-------------
-- 银行脚本宏定义
-- zouying
-- 2008-11-13 11:05
-----------------

Bank.TASK_GROUP 					 = 2055;
Bank.TASK_ID_GOLD_SUM 				 = 1;		-- 存储的金币总量
Bank.TASK_ID_SILVER_SUM 			 = 2;		-- 存储的银两总量
Bank.TASK_ID_GOLD_LIMIT 			 = 3;		-- 当前金币支取上限
Bank.TASK_ID_SILVER_LIMIT 			 = 4;		-- 当前银两支取上限
Bank.TASK_ID_GOLD_EFFICIENT_DAY		 = 5;		-- 金币支取上限生效日期
Bank.TASK_ID_SILVER_EFFICIENT_DAY 	 = 6;		-- 银两支取上限生效日期
Bank.TASK_ID_GOLD_UNEFFICIENT_LIMIT  = 7;		-- 未生效的金币支取上限
Bank.TASK_ID_SILVER_UNEFFICIENT_LIMIT= 8;		-- 未生效的银两支取上限
Bank.TASK_ID_GOLD_SHORTAGE 			 = 9;		-- 不足一绑金的记录
Bank.TASK_ID_SILVER_SHORTAGE 		 = 10;		-- 不足一绑银的记录
Bank.TASK_ID_TAKEOUTGOLD_DATE 		 = 11;		-- 从银行取出金币日期
Bank.TASK_ID_TODAYTAKEOUTGOLDCOUNT 	 = 12;		-- 当天取出金币数量
Bank.TASK_ID_TAKEOUTSILVER_DATE    	 = 13;		-- 从银行取出银两日期
Bank.TASK_ID_TODAYTAKEOUTSILVERCOUNT = 14;		-- 当天取出银两数量

Bank.MAX_MONEY = 2000000000;
Bank.MAX_COIN  = 2000000000;

Bank.DEFAULTMONEYLIMIT  = 20000;		
Bank.DEFAULTCOINLIMIT	= 1000;

Bank.DAYSECOND =  3600 * 24;
Bank.EFFECITDAYS = 5;
