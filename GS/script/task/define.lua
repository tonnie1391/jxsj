
-- 玩家可接20个任务
Task.TASK_GROUP_MIN				= 1001;
Task.TASK_GROUP_MAX				= 1020;

-- 玩家进入剑侠世界的第一个任务
Task.nFirstTaskId 				= 526;
Task.nFirstTaskValueGroup 		= 1021;
Task.nFirstTaskValueId 			= 6;


-- 任务共享的近距离定义
Task.nNearDistance				= 50;

-- 任务技能
Task.nAcceptTaskSkillId			= 305;	-- 接到任务的技能Id
Task.nFinishTaskSkillId 		= 306;	-- 完成任务的技能Id
Task.nFinishStepSkillId			= 328;	-- 完成步骤的技能Id

-- 任务类型
Task.emType_Main				= 1;		-- 主线任务
Task.emType_Branch	 			= 2;		-- 世界任务
Task.emType_World				= 3;		-- 江湖任务
Task.emType_Random				= 4;		-- 随机任务
Task.emType_Camp				= 5;		-- 军营任务

Task.tbemTypeName = {
	[Task.emType_Main] = "<color=yellow>[Cốt truyện]<color> ",
	[Task.emType_Branch] = "[Thế giới] ",
	[Task.emType_World] = "<color=blue>[Giang hồ]<color> ",
	[Task.emType_Random] = "[Ngẫu nhiên] ",
	[Task.emType_Camp] = "<color=green>[Quân doanh]<color> ",
};

-- 任务产出类型
Task.emTskProType_Main			= 1;		-- 主线任务产出
Task.emTskProType_Branch		= 2;		-- 支线任务产出
Task.emTskProType_World			= 3;		-- 世界任务产出
Task.emTskProType_Random		= 4;		-- 随机任务产出
Task.emTskProType_Camp			= 5;		-- 军营任务产出
Task.emTskProType_Merchant		= 6;		-- 商会任务产出
Task.emTskProType_Linktask		= 7;		-- 义军任务产出（任务链产出）

Task.emSAVEID_TASKID			= 1;
Task.emSAVEID_REFID				= 2;
Task.emSAVEID_CURSTEP			= 3;
Task.emSAVEID_ACCEPTDATA		= 4;


--任务系统_新任务_头顶		301
--任务系统_交任务_头顶		302
--任务系统_新任务_小地图	303
--任务系统_交任务_小地图	304
-- 任务检测类型
-- {头顶，小地图}
Task.CheckTaskFlagSkillSet = 
{
	MainCanVisible				= {301, 303},	-- 主线可见任务
	MainCanAccept				= {301, 303},	-- 主线可接任务
	MainCanNotReply				= {302, 304},	-- 主线不可交	
	MainCanReply				= {302, 304},	-- 主线可交				
						
	BranchCanVisible			= {334, 336},	-- 支线可见任务
	BranchCanAccept				= {334, 336},	-- 支线可接任务
	BranchCanNotReply			= {335, 337},	-- 支线不可交	
	BranchCanReply				= {335, 337},	-- 支线可交
	
	WorldCanVisible				= {334, 336},	-- 世界可见任务
	WorldCanAccept				= {334, 336},	-- 世界可接任务
	WorldCanNotReply			= {335, 337},	-- 世界不可交
	WorldCanReply				= {335, 337},	-- 世界可交
	
	RandomCanVisible			= {334, 336},	-- 随机可见任务
	RandomCanAccept				= {334, 336},	-- 随机可接任务
	RandomCanNotReply			= {335, 337},	-- 随机不可交
	RandomCanReply				= {335, 337},	-- 随机可交
	
	RepeatCanVisible			= {396, 398},	-- 可重复任务可见
	RepeatCanAccept				= {396, 398},	-- 可重复任务可接
	RepeatCanNotReply			= {397, 399},	-- 可重复任务不可交
	RepeatCanReply				= {397, 399},	-- 可重复任务可交
};

Task.nRepeatTaskAcceptMaxTime 	= 32;			-- 每天可接重复任务的最大次数

Task.tbZhenYuanExpAward	=
{	--奖励经验点数，每周奖励次数，任务变量主ID，次数子ID，时间子ID
	[1] = {15,  4, 2133, 1, 2},		-- 剧情任务
	[2] = {100, 1, 2133, 3, 4};		-- 无尽的征程
}

Task.TSKPRO_LOG_TYPE_MONEY		= 1;	-- 任务系统产出log货币类型（非绑银）
Task.TSKPRO_LOG_TYPE_BINDMONEY	= 2;	-- 任务系统产出log货币类型（绑定银两）
Task.TSKPRO_LOG_TYPE_BINDCOIN	= 3;	-- 任务系统产出log货币类型（绑定金币）

Task.tbOtherTask = {
		[510]={723, "keyimen_battle"},
		[511]={724, "keyimen_battle"}, 
		[512]={725, "keyimen_battle"},
		[513]={726, "keyimen_battle"},
		[514]={727, "keyimen_battle"},
		[515]={728, "keyimen_battle"},
		[516]={729, "keyimen_battle"},
		[517]={730, "keyimen_battle"},
		[518]={731, "keyimen_battle"},
		[519]={732, "keyimen_battle"},
		[520]={733, "keyimen_battle"},
		[521]={734, "keyimen_battle"},
		[522]={735, "keyimen_battle"},
		[497]={710, "keyimen_battle"},
		[498]={711, "keyimen_battle"},
		[499]={712, "keyimen_battle"},
		[500]={713, "keyimen_battle"},
		[501]={714, "keyimen_battle"},
		[502]={715, "keyimen_battle"},
		[503]={716, "keyimen_battle"},
		[504]={717, "keyimen_battle"},
		[505]={718, "keyimen_battle"},
		[506]={719, "keyimen_battle"},
		[507]={720, "keyimen_battle"},
		[508]={721, "keyimen_battle"},
		[509]={722, "keyimen_battle"},
		[529]={746, "qingling"},
		[536]={754,	"gumu_fuxiu"},
		[537]={755,	"gumu_fuxiu"},
	}
