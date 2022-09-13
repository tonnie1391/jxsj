-- 文件名　：missionlevel20_def.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-07-16 09:29:10
-- 功能    ：201209新任务

Task.NewPrimerLv20 = Task.NewPrimerLv20 or {};
local NewPrimerLv20 = Task.NewPrimerLv20;

NewPrimerLv20.GroupId_Task = 1025;
NewPrimerLv20.TaskID_CANGET	= 31;		--任务相关



NewPrimerLv20.TASK_MAIN_ID = 528;	--副本任务id
NewPrimerLv20.TASK_SUB_ID	= 745;	--副本任务子Id-花灯初上
NewPrimerLv20.TASK_SUB_ID_NEXT	= 747;	--副本任务子Id-谁书离别



NewPrimerLv20.nMaxMCountPerServer = 300;		--服务器最大开启地图数量
NewPrimerLv20.nMaxMCountPlayer 	= 800;		--服务器最大人数

NewPrimerLv20.nMapTemplateId	= 2253;			--模板地图

NewPrimerLv20.MAX_TIME = 30 * 60;

NewPrimerLv20.tbMaxPlayer = {
	{30, 	250},
	{50,	150},
	{80, 	100},
	}

NewPrimerLv20.tbEnterPos = {1996,3389};

NewPrimerLv20.tbLevelPos = {24,1600,3200};	--通过任务离开的
NewPrimerLv20.tbLevelPos_Ex = {		--非任务离开
	}	

NewPrimerLv20.nApplyCount		= NewPrimerLv20.nApplyCount or 0;
NewPrimerLv20.tbMissionList 	= NewPrimerLv20.tbMissionList or {};
NewPrimerLv20.tbMapList 		= NewPrimerLv20.tbMapList or {};
NewPrimerLv20.tbManagerList 	= NewPrimerLv20.tbManagerList or {}
NewPrimerLv20.tbServerInfo 		= NewPrimerLv20.tbServerInfo or {}


NewPrimerLv20.tbEventList = {
	[4] = "AddTongling";	--id	747
	[5] = "AddXuShiwei";
	[6] = "AddShenmiren";
	}
