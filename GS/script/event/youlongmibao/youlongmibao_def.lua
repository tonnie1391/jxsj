-------------------------------------------------------
-- 文件名　：youlongmibao_def.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-10-29 14:30:36
-- 文件描述：
-------------------------------------------------------

Youlongmibao.TASK_GROUP_ID 				= 2106;	-- 游龙密窑
Youlongmibao.TASK_YOULONG_HAVEAWARD		= 1;	-- 有奖未领
Youlongmibao.TASK_YOULONG_INTERVAL		= 2;	-- 挑战间隔
Youlongmibao.TASK_YOULONG_COUNT			= 3;	-- 累计次数
Youlongmibao.TASK_YOULONG_HAPPY_EGG		= 6;	-- 是否已经拿过开心蛋；0为未拿
Youlongmibao.TASK_DEPOSIT_COIN			= 7;	-- 未领取的古币值
Youlongmibao.TASK_ATTEND_NUM			= 8;	-- 每天参加的次数
Youlongmibao.TASK_ATTEND_DATE			= 9;	-- 每天参加的日期记录

--游龙周活动
Youlongmibao.TASK_ATTEND_NUM_EVENT		= 10;	 -- 游龙周活动参加的次数及领奖情况
Youlongmibao.TASK_BATCH						= 11;	--游龙周批次
Youlongmibao.TASK_DAILY_NO_INTERVAL_TIMES	= 12;	--每天参加游龙阁次数
Youlongmibao.TASK_CAN_YOULONG_COUNT			= 13;	--游龙累积次数限制，最多累积7天
Youlongmibao.TASK_CAN_YOULONG_COUNT_REFRESHTIME	= 14;	--每天刷新时间
Youlongmibao.nEventStarDay 				= 20110521;		--游龙周活动开始日期
Youlongmibao.nEventEndDay 				= 20110531;		--游龙周活动结束日期
Youlongmibao.nMaxAttendNum 				= 20000;		--游龙周活动记录的最大参加次数*100
--游龙周活动end

Youlongmibao.MAX_TIMES 					= 4;	-- 最多进行4次
Youlongmibao.MAX_GRID					= 25;	-- 格子数量
Youlongmibao.MAX_INTERVAL				= 1;	-- 挑战间隔15秒
Youlongmibao.DEF_GET_HAPPYEGG_COUNT		= 5;
Youlongmibao.nBatch						= 1;	--游龙周批次
Youlongmibao.NO_TIME_MAX_NUM			= 50;	--每天前两百个不需要等待时间
Youlongmibao.MAX_DAILY_COUNT			= 50;

Youlongmibao.MAX_CAN_YOULONG_COUNT			= 500;

-- ITEM ID
Youlongmibao.ITEM_YUEYING				= {18, 1, 476, 1};	-- 月影之石
Youlongmibao.ITEM_ZHANSHU				= {18, 1, 524, 1};	-- 游龙战书
Youlongmibao.ITEM_ZHANSHU_BIND			= {18, 1, 524, 4};	-- 游龙战书
Youlongmibao.ITEM_COIN					= {18, 1, 553, 1};	-- 游龙古币
Youlongmibao.ITEM_HAPPYEGG				= "18,1,525,1" 		-- 开心蛋

-- NPC ID
Youlongmibao.NPC_DIALOG			= 3690;
Youlongmibao.NPC_FIGHT			= 3689;

-- 多语言开关
Youlongmibao.bOpen = EventManager.IVER_bOpenYoulongmibao;

-- 表的路径
Youlongmibao.TYPE_RATE_PATH = "\\setting\\event\\youlongmibao\\youlongmibao_rate.txt";

-- 过滤物品
Youlongmibao.tbExcludeBind = {8, 16, 18, 28, 29};
