------------------------------------------------------
-- 文件名　：zhenyuan_define.lua
-- 创建者　：dengyong
-- 创建时间：2010-07-14 11:09:02
-- 功能    ：真元相关定义
------------------------------------------------------

Item.tbZhenYuan = Item.tbZhenYuan or {};
local tbZhenYuan = Item.tbZhenYuan;

tbZhenYuan.ATTRIB_COUNT			= 4;		-- 每个真元的属性数量
tbZhenYuan.ATTRIBENHANCE_INTERVAL = 5;		-- 每隔5级提升一次属性的值
tbZhenYuan.MINLEVEL				= 1;		-- 最小等级
tbZhenYuan.MAXLEVEL				= 120;		-- 最大等级
tbZhenYuan.REFINE_MINLEVELUP	= 1;		-- 每次炼化真元的一条属性最多只能提升1个档次（0.5星）
tbZhenYuan.REFINE_MAXLEVELUP	= 3;		-- 每次炼化真元的一条属性最多只能提升3个档次（1.5星）
tbZhenYuan.ATTRIB_MAXSTARLEVEL	= 20;		-- 每条属性的属性资质最多到20档（10星）
tbZhenYuan.LEVELDOWN_MINLEVEL	= 60;		-- 炼化成功后降低等级，最低降至60级
tbZhenYuan.LEVELDOWN_MAXLEVEL	= 100;		-- 炼化成功后降低等级，最高至100级
tbZhenYuan.EXPTIMES_XIULIAN		= 10;		-- 修炼时每本经验书增加10分钟的基准经验
tbZhenYuan.MAPPINGVALUE_MIN		= 0;		-- 属性映射的最小值
tbZhenYuan.MAPPINGVALUE_MAX		= 1000;		-- 属性映射的最大值
tbZhenYuan.MAPPINGVALUE_MAX_ENHANCE = 960;	-- 属性成长映射的最大值

tbZhenYuan.LILIAN_MAX_COUNT		= 5;		-- 每次使用历练经验最多能提升几个真元的经验

tbZhenYuan.ZHENYUAN_LEVEL_NEED	= 100;		-- 获取真元历练经验等级至少要100级

tbZhenYuan.CONVERT_COST_RATE	= 15;		-- 真元凝聚需要消耗同伴价值量15%的银两
tbZhenYuan.REFINE_COST_COUNT	= 20000;	-- 真元炼化固定每次消耗2W银两

tbZhenYuan.RANK_MIN				= 1;		-- 排行榜排名
tbZhenYuan.RANK_MAX				= 1000;		-- 排行榜排名

tbZhenYuan.bOpen				= 1;		-- 真元开关，1表示开，0表示关

tbZhenYuan.emZHENYUAN_ENHANCE_NONE 			= 0;	-- 无操作/取消操作，关闭界面
tbZhenYuan.emZHENYUAN_ENHANCE_OPENWINDOW	= 1;	-- 打开操作界面
tbZhenYuan.emZHENYUAN_ENHANCE_XIULIAN		= 2;	-- 真元修炼
tbZhenYuan.emZHENYUAN_ENHANCE_REFINE		= 3;	-- 真元炼化
tbZhenYuan.emZHENYUAN_ENHANCE_RESTORE		= 4;	-- 真元还真

tbZhenYuan.EXPSTORE_TASK_MAIN	= 2134;		-- 累积历练经验的主任务变量
tbZhenYuan.EXPSTORE_TASK_SUB	= 1;		-- 累积历练经验的子任务变量
tbZhenYuan.EXPSTORE_TASK_GUARD	= 2;		-- 上次维护排行榜的时间
tbZhenYuan.EXPSTORE_MAX			= 3000;		-- 最多累积3K分钟
tbZhenYuan.LOG_TASK_MAIN		= 2135;		-- 数据埋点记录数据主任务变量
tbZhenYuan.LOG_TASK_REFINECOUNT = 1;		-- 记录炼化次数
tbZhenYuan.LOG_TASK_XIULIANCOUNT = 2;		-- 记录修炼次数

-- 真元获得经验的途径枚举
tbZhenYuan.EXPWAY_EXPBOOK		= 1;		-- 同伴经验书
tbZhenYuan.EXPWAY_XIAOYAO		= 2;		-- 逍遥活动产出
tbZhenYuan.EXPWAY_MERCHANT		= 3;		-- 商会奖励
tbZhenYuan.EXPWAY_BATTLE		= 4;		-- 宋金奖励
tbZhenYuan.EXPWAY_ARMY			= 5;		-- 军营任务

-- 教育任务相关宏定义
tbZhenYuan.TASK_MAINID			= "01DA";	-- 真元相关任务的主任务ID，16进制
tbZhenYuan.TASK_SUBID			= "029C";	-- 真元相关任务的子任务ID，16进制
tbZhenYuan.TASKSTEP_CONVERT		= 2;		-- 真元凝聚的步骤
tbZhenYuan.TASKSTEP_LILIAN		= 3;		-- 真元历练的步骤
tbZhenYuan.TASKSTEP_XIULIAN		= 4;		-- 真元修炼的步骤
tbZhenYuan.TASKSTEP_REFINE		= 5;		-- 真元炼化的步骤
tbZhenYuan.TASKID_MAIN			= 1025;		-- 记录任务完成信息的主任务变量
tbZhenYuan.TASKID_CONVERT		= 20;		-- 真元凝聚子任务变量
tbZhenYuan.TASKID_LILIAN		= 21;		-- 历练子任务变量
tbZhenYuan.TASKID_XIULIAN		= 22;		-- 真元修炼子任务变量
tbZhenYuan.TASKID_REFINE		= 23;		-- 真元炼化子任务变量
tbZhenYuan.tbTaskValue = 
{
	[tbZhenYuan.TASKSTEP_CONVERT] = {tbZhenYuan.TASKID_MAIN, tbZhenYuan.TASKID_CONVERT},
	[tbZhenYuan.TASKSTEP_LILIAN]  = {tbZhenYuan.TASKID_MAIN, tbZhenYuan.TASKID_LILIAN},
	[tbZhenYuan.TASKSTEP_XIULIAN] = {tbZhenYuan.TASKID_MAIN, tbZhenYuan.TASKID_XIULIAN},
	[tbZhenYuan.TASKSTEP_REFINE]  = {tbZhenYuan.TASKID_MAIN, tbZhenYuan.TASKID_REFINE},
}

-- 真元解绑相关宏定义
tbZhenYuan.TASK_GID_UNBIND 		= 2085;
tbZhenYuan.TASK_SUBID_UNBIND	= 5;
tbZhenYuan.UNBIND_MIN_TIME		= 3 * 24 * 3600;   -- 申请后三天能解绑
tbZhenYuan.UNBIND_MAX_TIME		= 4 * 24 * 3600;   -- 申请四天后过期
tbZhenYuan.UNBIND_BUFF_SKILLID  = 1652;		-- 申请解绑BUFF对应的技能ID

-- 真元里存放到geninfo里的数据都可以通过这张表来生成指定的get,set接口
tbZhenYuan.tbParam = 
{-- 接口名   GenInfoId  nBitBegin nBitEnd
	["Attrib1Range"] = {1, 0, 7},		-- 初始属性1
	["Attrib2Range"] = {1, 16, 23},		-- 初始属性2
	["Attrib3Range"] = {2, 0, 7},		-- 初始属性3
	["Attrib4Range"] = {2, 16, 23},		-- 初始属性4
	["AttribPotential1"] = {1, 8, 15},	-- 属性1的资质档次, 1 - 20
	["AttribPotential2"] = {1, 24, 31},	-- 属性2的资质档次, 1 - 20
	["AttribPotential3"] = {2, 8, 15},	-- 属性3的资质档次, 1 - 20
	["AttribPotential4"] = {2, 24, 31},	-- 属性4的资质档次, 1 - 20
	["TemplateId"] = {3, 0, 7},			-- 模板ID
	["Level"] = {3, 8, 15},				-- 等级
	["CurExp"] = {3, 16, 29},			-- 经验
	["Equiped"] = {3, 30, 31},			-- 是否被装备过
	["PotenRateTemp"] = {4, 0, 7},		-- 属性资质分配模板
	--[""] = {4, 8, 15},				-- 预留
	["Param1"] = {4, 16, 16},			-- Param1
	["Param2"] = {4, 17, 17},			-- Param2
	["Rank"]   = {4, 18, 31},			-- 真元在排行榜的排名
}

tbZhenYuan.nCount_FullLevel_Today 		= 0;	-- 今天真元达到满级的个数
tbZhenYuan.nCount_FullLevel_All	 		= 0;	-- GS上次启动以来真元达到满级的个数
tbZhenYuan.nCount_Refine_Today	  		= 0;	-- 今天真元炼化的个数
tbZhenYuan.nCount_Refine_All	  		= 0;	-- GS上次启动以来真元炼化的个数
tbZhenYuan.nLastDayTime			  		= 0;	-- 上次做记录的时间
