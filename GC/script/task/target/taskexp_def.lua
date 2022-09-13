-- 文件名  : taskexp_def.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-07-02 14:14:13
-- 描述    : 经验任务

Task.TaskExp = Task.TaskExp or {};
local tbTaskExp = Task.TaskExp;

tbTaskExp.TASK_GID 		= 2130;	--经验任务任务组
tbTaskExp.TASK_TASKID	= 1;	--开启经验书状态 记录注册的id
tbTaskExp.TASK_DATE		= 2;	--经验书每日使用的日期记录
tbTaskExp.TASK_USENUM	= 3;	--每天使用经验书的数目

tbTaskExp.tbXinDeShu_ing 	= {18,1,668,2};	--正在修炼的心得书
tbTaskExp.tbXinDeShu_ed 	= {18,1,668,3};	--已经修炼好的心得书

tbTaskExp.nUseXindeMaxNum	= 100;	-- 每天最多使用的心得书数目
tbTaskExp.nLevel_UseXindeshu	= 50;	--使用空白心得书等级限制
tbTaskExp.nLevel_UseXindeshued	= 20;	--使用修炼好的心得书等级限制
tbTaskExp.nFAVOR				= 20;	--使用师傅修炼的修炼书加亲密



--数据tb
tbTaskExp.tbExp = tbTaskExp.tbExp or {};	--修炼需要的值和修炼好的书获得的值 [nLevel] = {[1](修炼时需要的值) ,[2]（修炼好获得的值）}

------------------------------------------------------------------------------------------------------
--任务发布平台

tbTaskExp.Open				= EventManager.IVER_bOpenTaskPlatform;		-- 平台开关

tbTaskExp.TASK_GID 			= 2130;	--经验任务任务组
tbTaskExp.TASK_TASKCOIN		= 4;		--玩家在平台中所拥有的金币数
tbTaskExp.TASK_OPERATETIME 	= 5;		--玩家平台操作的时间记录

--奇珍阁自动购买物品
tbTaskExp.tbAutoBuy	= {{405, 1000},{404, 100},{403, 10},{402, 1}};

tbTaskExp.nMaxViewTask	= 50;		--平台显示前50个任务
tbTaskExp.nMaxEveryOne	= 100;		--每人显示发100任务
tbTaskExp.nRateBackBindJin	= 1;			--绑金返回的比率
tbTaskExp.nTimeFabu		= 24; 		--发布时间
tbTaskExp.nItemCount		= 1000;		--记录key值的，满足1000种物品需求
tbTaskExp.nMaxCount		= 10;			--每次收购的最大数
tbTaskExp.nMaxXing		= 20;		--每次收购的最星级

--数据tb
tbTaskExp.tbTaskTemp = tbTaskExp.tbTaskTemp or {};	--装备临时表
tbTaskExp.tbItem = tbTaskExp.tbItem or {};	--装备对应的内存id表
tbTaskExp.tbTask = tbTaskExp.tbTask or {};	--发布的任务表(分类)
tbTaskExp.tbTaskAll = tbTaskExp.tbTaskAll or {};	--发布的任务表(总表)

tbTaskExp.tbTaskLock = tbTaskExp.tbTaskLock or {};	--gc锁定的任务
tbTaskExp.tbTaskLockTimer = tbTaskExp.tbTaskLockTimer or {};	--gc锁定任务Timer
tbTaskExp.tbTaskTimer = tbTaskExp.tbTaskTimer or {};	--Task发布任务timer

--globalbuf
tbTaskExp.tbCheXiaoBuffer = tbTaskExp.tbCheXiaoBuffer or {}	--上线要加的平台金币

