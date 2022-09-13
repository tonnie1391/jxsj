-- 文件名　：kinrepository_gs.lua
-- 创建者　：huangxiaoming
-- 创建时间：2012-06-10 14:44:10
-- 描  述  ：
if MODULE_GAMECLIENT then
	return
end

KinRepository.IS_OPEN			= 1;	-- 仓库功能是否开启

KinRepository.MAX_ROOM_SIZE		= 48;	-- 每页空间上限
KinRepository.MAX_ROOM_PAGE		= 10;	-- 仓库总共最多10页

KinRepository.ROOMTASK_BEGIN	= 73; -- 任务变量起始值
KinRepository.ROOMTASK_END		= 82;

KinRepository.BITS_EXP_BEG = 0;
KinRepository.BITS_EXP_END = 22;
KinRepository.BITS_AUTHORITY_BEG = 23;
KinRepository.BITS_AUTHORITY_END = 25;
KinRepository.BITS_SIZE_BEG = 26;
KinRepository.BITS_SIZE_END = 31;

KinRepository.FORBID_TIME_BEG	= 50000;	-- 数据库备份时间，暂停家族仓库操作
KinRepository.FORBID_TIME_END	= 54500;

KinRepository.MAX_MANAGER_COUNT			= 4;	-- 不算族长最多四个管理员

KinRepository.AUTHORITY_EVERYONE		= 1;	-- 所有都能操作
KinRepository.AUTHORITY_RETIRE			= 2;	-- 荣誉的能操作，记名的不可以的
KinRepository.AUTHORITY_FIGURE_REGULAR	= 3;	-- 正式的能操作
----以上的权限不需要申请操作，下面的都需要申请之后才能操作----------
KinRepository.AUTHORITY_ASSISTANT		= 4;	-- 指定管理员能操作
KinRepository.AUTHORITY_FIGURE_CAPTAIN		= 5;	-- 族长能操作

-- 每页默认权限
KinRepository.AUTHORITY_ROOM	= 
{	
	[0] = KinRepository.AUTHORITY_RETIRE,
	[1] = KinRepository.AUTHORITY_RETIRE,
	[2] = KinRepository.AUTHORITY_RETIRE,
	[3] = KinRepository.AUTHORITY_RETIRE,
	[4] = KinRepository.AUTHORITY_ASSISTANT,
	[5] = KinRepository.AUTHORITY_ASSISTANT,
	[6] = KinRepository.AUTHORITY_ASSISTANT,
	[7] = KinRepository.AUTHORITY_ASSISTANT,
	[8] = KinRepository.AUTHORITY_ASSISTANT,
	[9] = KinRepository.AUTHORITY_ASSISTANT,
}

-- 每页默认大小
KinRepository.ROOMSIZE_ROOM		=
{
	[0] = KinRepository.MAX_ROOM_SIZE,
	[1] = 0,
	[2]	= 0,
	[3] = 0,
	[4] = KinRepository.MAX_ROOM_SIZE,
	[5] = 0,
	[6] = 0,
	[7] = 0,
	[8] = 0,
	[9] = 0,
}

KinRepository.FREE_ROOM_SET = {0, 1, 2, 3}; ---- 自由仓库集合
KinRepository.LIMIT_ROOM_SET = {4, 5, 6, 7};

KinRepository.REPTYPE_FREE	= 1;
KinRepository.REPTYPE_LIMIT	= 2;
KinRepository.EXTEND_ONCESIZE	= 8;	-- 每次扩充的格子数

KinRepository.ROOM_SET =
{
	[KinRepository.REPTYPE_FREE] = 	KinRepository.FREE_ROOM_SET,
	[KinRepository.REPTYPE_LIMIT] = KinRepository.LIMIT_ROOM_SET;
};

KinRepository.MAX_AVG_PRICE = 2000; -- 汇率上限
KinRepository.EXTEND_MONEY_COE = 100 * 0.3;	-- 银两系数
-- 每一级需要的贡献度,银两权重(银两= 权重*系数*汇率)
KinRepository.BUILD_VALUE	= {};
KinRepository.BUILD_VALUE[KinRepository.REPTYPE_FREE] = 
{
		[1] = {111100, 25},
		[2] = {117625, 25},
		[3] = {124150, 25},
		[4] = {130675, 25},
		[5] = {137200, 40},
		[6] = {143725, 40},
		[7] = {150250, 40},
		[8] = {156775, 40},
		[9] = {163300, 55},
		[10] = {169825, 55},
		[11] = {176350, 55},
		[12] = {182875, 55},
		[13] = {189400, 70},
		[14] = {195925, 70},
		[15] = {202450, 70},
		[16] = {208975, 70},
		[17] = {215500, 85},
		[18] = {222025, 85},	
};
-- 公共和权限仓库数值一致
KinRepository.BUILD_VALUE[KinRepository.REPTYPE_LIMIT] = KinRepository.BUILD_VALUE[KinRepository.REPTYPE_FREE];

KinRepository.OPERATE_TYPE_TAKE 	= 0; -- 操作类型:取
KinRepository.OPERATE_TYPE_STORE	= 1; -- 操作类型:存
KinRepository.OPERATE_TYPE_ALL		= 8; -- 所有类型

KinRepository.TYPEDESC = 
{
	[KinRepository.OPERATE_TYPE_TAKE] = "取出",
	[KinRepository.OPERATE_TYPE_STORE] = "存入",
	[KinRepository.OPERATE_TYPE_ALL] = "存取",
};

KinRepository.TAKE_REPOSITORY_APPLY_LAST  = 2 * 60 * 18; -- 申请响应时间
KinRepository.TAKE_REPOSITOR_AUTHORITY_LAST = 5 * 60;	-- 申请成功之后可操作持续时间
KinRepository.TAKE_AUTHORITY_AGREE_COUNT	= 2;	-- 申请取操作需要同意的人数

KinRepository.OPERATE_MONTH_PAY		= 100;	-- 每月充值100才可以操作

-- 可存取仓库的地图
KinRepository.ALLOW_MAPTYPE_LIST = {
	["village"] = KinRepository.OPERATE_TYPE_ALL, 
	["city"]	= KinRepository.OPERATE_TYPE_ALL,
	["faction"] = KinRepository.OPERATE_TYPE_ALL,
	["fight"] 	= KinRepository.OPERATE_TYPE_ALL,
	["jiehun_fb"] = KinRepository.OPERATE_TYPE_ALL,
	["baihutang"]= KinRepository.OPERATE_TYPE_ALL,
	["qinshihuangling"] = KinRepository.OPERATE_TYPE_ALL, 
	["battle_wild"] = KinRepository.OPERATE_TYPE_ALL,
	["kinbattlezhunbei"] = KinRepository.OPERATE_TYPE_ALL,	
	["homeland"] = KinRepository.OPERATE_TYPE_ALL,
};
