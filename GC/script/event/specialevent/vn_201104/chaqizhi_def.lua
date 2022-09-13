-- 文件名　：chaqizhi_def.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-04-06 17:10:22
--插旗

SpecialEvent.tbChaQi2011 = SpecialEvent.tbChaQi2011 or {};
local tbChaQi2011 = SpecialEvent.tbChaQi2011;

tbChaQi2011.TASKGID = 2143;
tbChaQi2011.TASK_DATE				= 31;		--种树日期
tbChaQi2011.TASK_COUNT_PLANT		= 32;	--每天种树的数目
tbChaQi2011.TASK_COUNT_PLANT_ALL	= 33;		--总种树的数目

tbChaQi2011.nAttendMinLevel 		= 65;			--参加等级
tbChaQi2011.nMaxPlant				= 10;				--每天每人可以种植希望之种子
tbChaQi2011.nMaxPlantAll			= 100			--总共可以种植希望之种子
tbChaQi2011.nStartTime 				= 201005060000;	--活动开始时间
tbChaQi2011.nEndTime 				= 201005302400;	--活动结束时间
tbChaQi2011.RANGE_EXP			= 45;			-- 组队经验范围
tbChaQi2011.BASE_EXP_MULTIPLE	= 0.5;			-- 经验倍率
tbChaQi2011.tbQIZhi 				= {18, 1, 1270, 1};	--功勋旗帜
tbChaQi2011.tbGongXunXiang		= {18, 1, 1271, 1}	--功勋箱
tbChaQi2011.tbTitle 				= {6,62,1,1};		--称号：威震天下
tbChaQi2011.EXP_TIME				= 5;				-- 每5秒给一次经验

--种树npc
tbChaQi2011.tbTree = {	
	[1] = {9534,180},
	[2] = {9534,60},
};
tbChaQi2011.INDEX_BIG_TREE = #tbChaQi2011.tbTree;		--最大树

--date table
tbChaQi2011.tbPlantInfo = tbChaQi2011.tbPlantInfo or {};		--种树标志{[nServerId]= {[szName] = 1}}
