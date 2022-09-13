-- 文件名　：comcrystal_def.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-05-14 09:16:32
-- 描  述  ：越南6月合成结晶

--VN--

SpecialEvent.tbComCrystal = SpecialEvent.tbComCrystal or {};
local tbComCrystal = SpecialEvent.tbComCrystal;
	
tbComCrystal.tbItem		= {18,1,950};		--结晶GDP
tbComCrystal.tbLead		= {18, 1, 951, 1};		--铅GDPL
tbComCrystal.tbMask		= {1, 13, 64, 1};		--世界杯面具
tbComCrystal.tbHorse		= {1, 12, 33, 4};		--120级全抗马
tbComCrystal.nNumAwordHorse 	= 20;		--第20次肯定获得马
tbComCrystal.nAwordExpMax		= 1000000000;	--经验最高获得数
tbComCrystal.nUseMaxNum		= 50;	 		--使用物品的最大数
tbComCrystal.nStarTime			= 20090609;		--开始日期
tbComCrystal.nCloseTime		= 20090630;		--结束日期
tbComCrystal.nComMoney		= 500;			--合成物品需要的银两

tbComCrystal.TASKGID = 2124;			--任务变量组
tbComCrystal.TASK_ISGETHORSE 		= 1; 	-- 是否获得马
tbComCrystal.TASK_GETMAXLEVELITEM 	= 2; 	--使用19级结晶的数
tbComCrystal.TASK_USEITEMNUM		= 3; 	--使用的物品数量
tbComCrystal.TASK_GETEXPNUM 		= 4; 	-- 获得的经验总数

--管理表
tbComCrystal.tbAword = tbComCrystal.tbAword or {};	--每级结晶对应的奖励
tbComCrystal.tbComRate = tbComCrystal.tbComRate or {}; --合成结晶的概率
