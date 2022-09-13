-- 文件名　：log.lua
-- 创建者　：wangbin
-- 创建时间：2008-3-11 21:07:00
-- 文件说明：日志接口(写入的日志将存储到数据库)

-- 日志级别
Log.LEVEL_DEBUG		= 1		-- 调试信息
Log.LEVEL_INFO		= 2		-- 信息，记录游戏中正常行为（交易、奖励、物品生成等）
Log.LEVEL_WARNING 	= 3		-- 警告信息（断言错误等）
Log.LEVEL_NOTICE	= 4		-- 需要注意的信息（玩家数据损坏等）
Log.LEVEL_CRITICAL	= 5		-- 严重（刷装备、重复登录等）

-- 日志大类
Log.TYPE_STATISTICS 	= 1		-- 统计数据
Log.TYPE_ROLEADMIN		= 2		-- 角色管理
Log.TYPE_PLAYERCOURSE 	= 3		-- 玩家历程
Log.TYPE_EQUIPHISTORY 	= 4		-- 装备历史
Log.TYPE_TONG		  	= 5		-- 帮会
Log.TYPE_PROMOTION	  	= 6		-- 活动

-- 玩家行为日志类别
Log.emKPLAYERLOG_TYPE_LOGIN			= 0;			-- 玩家登录
Log.emKPLAYERLOG_TYPE_LOGOUT			= 1;			-- 玩家退出
Log.emKPLAYERLOG_TYPE_FACTIONSPORTS	= 2;			-- 门派竞技
Log.emKPLAYERLOG_TYPE_CREATEFAMILY		= 3;			-- 家族建立
Log.emKPLAYERLOG_TYPE_FAMILYAPPOINT	= 4;			-- 家族职位任免
Log.emKPLAYERLOG_TYPE_FAMILYDISMISS 	= 5;			-- 家族解散
Log.emKPLAYERLOG_TYPE_CREATETONG		= 6;			-- 帮会建立
Log.emKPLAYERLOG_TYPE_TONGAPPOINT		= 7;			-- 帮会职位任免
Log.emKPLAYERLOG_TYPE_TONGDISMISS		= 8;			-- 帮会解散
Log.emKPLAYERLOG_TYPE_TONGCONTRIBUTE	= 9;			-- 捐献帮会建设基金
Log.emKPLAYERLOG_TYPE_TONGPAYOFF		= 10;			-- 帮会资金发放
Log.emKPLAYERLOG_TYPE_BUYGOLDCOIN		= 11;			-- 买金币
Log.emKPLAYERLOG_TYPE_SELLGOLDCOIN		= 12;			-- 卖金币
Log.emKPLAYERLOG_TYPE_USEGOLDCOIN_APP	= 13;			-- 申请消耗金币
Log.emKPLAYERLOG_TYPE_USEGOLDCOIN_RES	= 14;			-- 消耗金币结果
Log.emKPLAYERLOG_TYPE_FINISHTASK		= 15;			-- 完成任务
Log.emKPLAYERLOG_TYPE_JOINSPORT		= 16;			-- 参加活动
Log.emKPLAYERLOG_TYPE_LEVELUP			= 17;			-- 玩家升级
Log.emKPLAYERLOG_TYPE_JB_BILL_CANCEL 	= 18;			-- 交易所撤单
Log.emKPLAYERLOG_TYPE_PLAYERTRADE		= 19;			--  玩家交易
Log.emKPLAYERLOG_TYPE_STALLSELL			= 20;			--  贩卖
Log.emKPLAYERLOG_TYPE_STALLBUY			= 21;			--  收购
Log.emKPLAYERLOG_TYPE_GETACCOUNTMONEY	= 22;			--  从账户中取钱
Log.emKPLAYERLOG_TYPE_SENDMAIL_MONEYANDITEM	= 23;		--  邮寄剑侠币或物品
Log.emKPLAYERLOG_TYPE_GETFRIENDCOINBACK	= 24;			--  密友返回绑定金币
Log.emKPLAYERLOG_TYPE_AUCTION			= 25;			--  拍卖行操作行为
Log.emKPLAYERLOG_TYPE_PROMOTION		= 26;			--  促销活动，消费金币获得绑定金币
Log.emKPLAYERLOG_TYPE_COINBANK			= 27;			--  将金币存入银行
Log.emKPLAYERLOG_TYPE_ANTIBOT_SCORE	= 28;			--  疑似外挂的分值记录,保存反外挂系统对玩家的评分
Log.emKPLAYERLOG_TYPE_ANTIBOT_PROCESS	= 29;			--  确定外挂的处理方式,保存反外挂系统对玩家的处理结果
Log.emKPLAYERLOG_TYPE_COINSTATE		= 30;			--  金币冻结，解冻行为
Log.emKPLAYERLOG_TYPE_BINDCOIN			= 31;			--  绑定金币消耗
Log.emKGLOBAL_TONGLOG_TYPE				= 32;		-- 全局帮会log
Log.emKGLOBAL_KINLOG_TYPE				= 33;		-- 全局家族log
Log.emKPLAYERLOG_TYPE_REALTION			= 34;		-- 玩家人际关系
Log.emKPLAYERLOG_TYPE_COMPENSATE		= 50;		-- 补偿相关
Log.emKPLAYERLOG_TYPE_GM_OPERATION		= 51;		-- GM操作
Log.emKPLAYERLOG_TYPE_MOONSTONE		= 52;		-- 月影之石兑换
Log.emKPLAYERLOG_TYPE_KINPAYOFF		= 53;		--家族资金相关
Log.emKPLAYERLOG_TYPE_SPREADER		= 54;		--奇珍阁消耗记录

-- 物品流向日志类别
Log.emKITEMLOG_TYPE_USE				= 0;			-- 道具使用
Log.emKITEMLOG_TYPE_ADDITEM			= 1;			-- 获取物品
Log.emKITEMLOG_TYPE_REMOVEITEM		= 2;			-- 失去物品


-- 家族日志分类
Log.emKKIN_LOG_TYPE_KINSTRUCTURE	= 1;  -- 家族结构
Log.emKKIN_LOG_TYPE_KINFUND			= 2;  -- 家族资金

-- 帮会日志分类
Log.emKTONG_LOG_TONGSTRUCTURE 	= 1; 	 -- "帮会结构"
Log.emKTONG_LOG_TONGBUILDFUN		= 2;	 --"帮会建设资金"
Log.emKTONG_LOG_TONGFUND	  		= 3;  -- "帮会资金"
