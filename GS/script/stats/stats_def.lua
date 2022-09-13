-- 文件名　：stats_def.lua
-- 创建者　：furuilei
-- 创建时间：2009-05-21 20:16:58

if (MODULE_GAMECLIENT) then
	return;
end

--========================================================
Stats.TASK_GROUP = 2094;
Stats.TASK_ID_STATS_KEY	= 1;			-- 统计的开关
Stats.TASK_ID_UNLOGINTIME = 2;			-- 玩家没有上线的最大天数
Stats.TASK_ID_LASTGETREPUTETIME = 3;	-- 玩家最近一次获得威望的时间
Stats.TASK_ID_UNGETREPUTETIME = 4;		-- 玩家连续没有获得威望的最大天数
Stats.TASK_ID_PLAYERTYPE = 5;			-- 记录玩家种类（0、玩家在统计期间没有上线；1、没有达到领取福利的标准；2、达到标准但是没有领取精活；3、达到标准并且领取了精活）
Stats.TASK_ID_LASTGETFULITIME = 6;		-- 玩家上次领取福利精活的时间
Stats.TASK_ID_UNUSEFULITIME = 7;		-- 达到标准但是没有领取福利精活的最大天数
Stats.TASK_ID_TODAYONLINETIME = 8;		-- 玩家当天的在总线时间
Stats.TASK_ID_BELOWHALFTIME = 9;		-- 一天总在线时间不足平均在线时间一半的最大天数
Stats.TASK_ID_CURBELOWHALFTIME = 10		-- 玩家当前的连续低于平均时间一半的天数
Stats.TASK_ID_BELOW4HOURSTIME = 11;		-- 一天总在线时间不足4小时的最大天数
Stats.TASK_ID_CURBELOW4HOURSTIME = 12;	-- 玩家当前的连续低于4小时的天数

-- 注意：以后再添加和潜在流失统计相关的任务变量时，每增加一个变量相应的要更新下面这个的表示任务变量个数
Stats.COUNT_TASK_ID	= 12;	
--========================================================			

-- 表示玩家登陆时间的任务变量
Stats.TASK_GROUP_LOGIN = 2063;
Stats.TASK_ID_LOGINTIME = 2;

-- 表示上线还是下线时候执行的标志
Stats.LOGINEXE = 1;
Stats.LOGOUTEXE = 2;

Stats.ONLINETIME = 4 * 3600;		-- 4小时的在线时间
Stats.ONEDAYTIME = 24 * 3600;		-- 一天的时间

Stats.PLAYER_STATE_NEVERLOGIN = 0;		-- 表示玩家没有上过线
Stats.PLAYER_STATE_TODAY_NOTADD = 1;	-- 表示玩家当天没有进行过加1的操作的标识
Stats.PLAYER_STATE_TODAY_ADD = 2;		-- 表示玩家当天有进行过加1操作的标识



--========================================================
-- 角色参加活动总次数的统计
Stats.TASK_COUNT_ACTIVITY_KEY = 50;	-- 角色参与活动总次数统计的开关

Stats.TASK_COUNT_XIULIANZHU	= 51;	-- 玩家使用修炼珠的计数
Stats.TASK_COUNT_BAIHUTANG = 52;	-- 玩家参加白虎堂的计数
Stats.TASK_COUNT_BATTLE	= 53;		-- 玩家参加宋金的次数
Stats.TASK_COUNT_YIJUN	= 54;		-- 玩家参加以军任务的次数
Stats.TASK_COUNT_KINGAME = 55;		-- 玩家参加家族副本的次数
Stats.TASK_COUNT_FACTION = 56;		-- 玩家参加门派竞技的次数
Stats.TASK_COUNT_CANGBAOTU = 57;	-- 玩家挖宝的次数
Stats.TASK_COUNT_SHANGHUI = 58;		-- 玩家完成商会任务的次数
Stats.TASK_COUNT_WANTED = 59;		-- 玩家参加官府通缉任务的次数
Stats.TASK_COUNT_ARMYCAMP = 60;		-- 玩家参加军营副本的次数
Stats.TASK_COUNT_GUESS = 61;		-- 玩家参加花灯猜谜的次数
Stats.TASK_COUNT_XOYOGAME = 62;		-- 玩家参加逍遥谷闯关的次数
Stats.TASK_COUNT_WLLS = 63;			-- 玩家参加武林联赛的次数
Stats.TASK_COUNT_QINSHIHUANG = 64;	-- 玩家进入秦始皇陵的计数（进去过的天数）
Stats.TASK_COUNT_DOMAIN = 65;		-- 玩家参加领土争夺的次数
Stats.TASK_COUNT_FULIJINGHUO = 66;	-- 玩家领取福利精活的计数（天数）
Stats.TASK_COUNT_COINEX = 67;		-- 玩家绑银换银两的次数
Stats.TASK_COUNT_SALARY = 68;		-- 玩家领取工资的计数
Stats.TASK_COUNT_WEEKLYTASK = 69;	-- 玩家领取到家族周目标奖励的次数

Stats.TASK_ACTIVITY_COUNT = 19;		-- 表示目前需要统计的活动数目
