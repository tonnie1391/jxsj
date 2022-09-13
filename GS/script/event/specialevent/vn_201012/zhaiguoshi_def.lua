-- 文件名  : zhaiguoshi_def.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-11-18 11:08:08
-- 描述    : 

--VN--
SpecialEvent.tbZaiGuoShi = SpecialEvent.tbZaiGuoShi or {};
local tbZaiGuoShi = SpecialEvent.tbZaiGuoShi;


tbZaiGuoShi.nStartTime = 20101013;					--开始时间
tbZaiGuoShi.nEndTime = 20100112;					--结束时间
tbZaiGuoShi.tbTime = {1000,1200,1400,1600,1800,2200};	--时间点
tbZaiGuoShi.nTime = 45;								--持续时间段 分钟
tbZaiGuoShi.nMaxCount = 3;							--每天最大次数
tbZaiGuoShi.SkillId	= 1657;							--摘果实buff

--任务组
tbZaiGuoShi.TASKGID 				= 2147;	--任务组
tbZaiGuoShi.TASK_DATA			= 16;		--上次接任务的日期
tbZaiGuoShi.TASK_COUNT			= 17;		--每天次数
tbZaiGuoShi.TASK_TIME			= 18;		--当天任务做到那个时间点的
tbZaiGuoShi.TASK_DATA_PEACH		= 20;	--桃子日期
tbZaiGuoShi.TASK_COUNT_PEACH	= 21;		--桃子每天使用的次数
tbZaiGuoShi.TASK_DATA_OLDWINE	= 22;	--陈年桃酒日期
tbZaiGuoShi.TASK_COUNT_OLDWINE	= 23;	--陈年桃酒每天使用的次数
tbZaiGuoShi.TASK_DATA_GOODWINE		= 24;	--上等桃酒日期
tbZaiGuoShi.TASK_COUNT_GOODWINE	= 25;	--上等桃酒每天使用的次数

--mission
tbZaiGuoShi.MissionList = {};

