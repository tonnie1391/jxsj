-- 文件名　：menter_def.lua
-- 创建者　：zhaoyu
-- 创建时间：2009/10/26 14:39:19
-- 描  述  ：师徒副本定义

Esport.Mentor = Esport.Mentor or {};
local Mentor = Esport.Mentor;

Mentor.nGroupTask = 2109;		--师徒副本相关主任务变量
Mentor.nSubDailyTimes = 1;		--子任务变量，存放副本当日剩余次数
Mentor.nSubWeeklyTimes = 2; 	--子任务变量，存放副本本周剩余次数
Mentor.nSubCurDegree = 3;		--子任务变量，存放当前周进度	
Mentor.nSubLastDayTime = 4;		--子任务变量，上次更新日任务变量的时间
Mentor.nSubLastWeekTime = 5;		--子任务变量，上次更新周任务变量的时间

Mentor.RELATIONTYPE_TRAINING = 5;	--徒弟未出师的师徒关系（详见playerrelation_i.h的枚举KEPLAYERRELATION_TYPE）

Mentor.DAILY_SCHEDULE = 1;	--每天能进入副本的最大次数
Mentor.WEEKLY_SCHEDULE = 3;	--每周能进入副本的最大次数

Mentor.TEMPLATE_MAP_ID = 1652;
Mentor.MAX_MAP_COUNT = 0;

Mentor.ENTER_X = 1579;
Mentor.ENTER_Y = 3174;

Mentor.LEAVE_MAP = 1;
Mentor.LEAVE_X = 1389;
Mentor.LEAVE_Y = 3102;
Mentor.TIMEOUT = 20;
Mentor.AwardTimer = 5;		--领奖时间限时为5分钟

Mentor.tbBoom = {18, 1, 521, 1};	--爆破陷阱的GDPL	
Mentor.tbFreeze = {18, 1, 522, 1};	--冰冻陷阱的GDPL