-- 文件名　：qixi2012_def.lua
-- 创建者　：huangxiaoming
-- 创建时间：2012-08-10 14:10:10
-- 描  述  ：

SpecialEvent.QiXi2012 = SpecialEvent.QiXi2012 or {};
local tbQiXi2012 = SpecialEvent.QiXi2012 or {};

tbQiXi2012.tbRoseList = tbQiXi2012.tbRoseList or {};	-- npc表，playerid为索引
tbQiXi2012.tbAwardRoseList = tbQiXi2012.tbAwardRoseList or {};	-- 奖励npc表，已playerid为索引
tbQiXi2012.tbTransmitPos = {};


tbQiXi2012.IS_OPEN					= 1;	-- 系统开关

-- task id
tbQiXi2012.TASK_GROUP_ID			= 2027;	-- 任务组ID
tbQiXi2012.TASK_LAST_ACCEPT_DAY		= 245;	-- 最后一次领取任务的天数
tbQiXi2012.TASK_DAY_AWARD_TIMES		= 246;	-- 当天领奖的次数
tbQiXi2012.TASK_PLANT_TIME			= 247;	-- 上一次种植时间
tbQiXi2012.TASK_AWARD_PET			= 248;	-- 是否开到过跟宠
tbQiXi2012.TASK_QINGYUANLIBAO		= 249;	-- 是否领取了七夕情缘礼包
tbQiXi2012.TASK_OPENSUOXINYU_DAY	= 250;	-- 开锁心玉的日子
tbQiXi2012.TASK_OPENSUOXINYU_TIMES	= 251;	-- 开锁心玉的次数

-- const
tbQiXi2012.NPCID_HUODONGDASHI		= 10318;	-- 活动大使
tbQiXi2012.NPCID_ROSE_SEED			= 10319;	-- 玫瑰种子
tbQiXi2012.NPCID_ROSE_RED			= 10321;	-- 红玫瑰
tbQiXi2012.NPCID_ROSE_PINK			= 10320;	-- 粉玫瑰
tbQiXi2012.NPCID_ROSE_AWARD			= 10322;	-- 领奖玫瑰
tbQiXi2012.NPCID_XUYUANDENG			=
{
	[1] = 10323,
	[2] = 11057,
	[3] = 11058,
};

tbQiXi2012.NPCPOS_HUODONGDASHI =  -- 活动npc刷新点
{
	[24] = {1786, 3532},
	[25] = {1651, 3163},
	[29] = {1647, 3942},	
};

-- 花型偏移量
tbQiXi2012.ROSE_OFFSET	=
{-- posx,posy
	{0, -6},
	{-2, -8},
	{2, -8},
	{-4, -10},
	{4, -10},
	{-7, -10},
	{7, -10},
	{-9, -8},
	{9, -8},
	{-11, -6},
	{11, -6},
	{-11, -3},
	{11,-3},
	{-9, 0},
	{9, 0},
	{-7, 3},
	{7, 3},
	{-5, 6},
	{5, 6},
	{-3, 8},
	{3, 8},
	{0, 10},
};

tbQiXi2012.ROSE_COLORSET = 
{
	-- 各等级对应的哪几个偏移索引是红玫瑰
	[1] = {1, 2, 7, 8, 11, 12, 13, 17, 20},
	[2] = {2, 7, 8, 11, 13, 14, 19, 20, 22},
	[3] = {1, 3, 4, 11, 14, 16, 17, 18, 22},	
	[4] = {1, 2, 5, 12, 15, 16, 17, 20,21},
	[5] = {1, 2, 9, 12, 13, 15, 17, 18, 22},
	[6] = {4, 5, 6, 7, 10, 11, 12, 13, 22},
	[7] = {3, 8, 9, 12, 14, 15, 17, 21, 22},
	[8] = {1, 3, 9, 10, 12, 14, 19, 21, 22},
	[9] = {1, 6, 8, 9, 10, 16, 17, 20, 21},
	[10] = {6, 7, 8, 10, 11, 12, 13, 17, 22},
};

-- 奖励鲜花偏移量
tbQiXi2012.AWARDROSE_OFFSET = 
{ -- offsetx, offsety, 延迟帧数
	{0, -6, 1},
	{-2, -8, 4},
	{2, -8, 4},
	{-4, -10, 7},
	{4, -10, 7},
	{-7, -10, 10},
	{7, -10, 10},
	{-9, -8, 13},
	{9, -8, 13},
	{-11, -6, 16},
	{11, -6, 16},
	{-11, -3, 19},
	{11, -3, 19},
	{-9, 0, 22},
	{9, 0, 22},
	{-7, 3, 25},
	{7, 3, 25},
	{-5, 6, 28},
	{5, 6, 28},
	{-3, 8, 31},
	{3, 8, 31},
	{0, 10, 34},
};
tbQiXi2012.SUCCEED_REDROSE_NUM = 9;
tbQiXi2012.FAILURE_PINKROSE_NUM = 3;
tbQiXi2012.COLOR_TYPE_RED	= 1;
tbQiXi2012.COLOR_TYPE_PINK	= 2;

tbQiXi2012.SKILLID_EFFECT	= 2932;
tbQiXi2012.EFFECT_DURATION	= 60 * 18;

tbQiXi2012.ITEMID_SEED	= {18, 1, 1773, 1}; -- 种子ID
tbQiXi2012.ITEMID_GRAP	= {18, 1, 1774, 1}; -- 图ID
tbQiXi2012.ITEMID_GRAP_USED = {18, 1, 1789, 1}; -- 已使用的图，参考物
tbQiXi2012.ITEMID_AWARDROSE = {18, 1, 1775, 1}; -- 奖励玫瑰
tbQiXi2012.ITEMID_AWARD_BOYBOX = {18, 1, 1776, 1}; -- 男奖励
tbQiXi2012.ITEMID_AWARD_GIRLBOX = {18, 1, 1777, 1}; -- 女奖励
tbQiXi2012.ITEMID_SUOXINYU	= {18, 1, 1778, 1};	-- 锁心玉
tbQiXi2012.ITEMID_JIEXINYU	= {18, 1, 1779, 1};	-- 解心玉
tbQiXi2012.ITEMID_PET		= {18, 1, 1730, 11};-- 7天跟宠
tbQiXi2012.ITEMID_QINGYUANLIBAO = 
{
	[0] = {18, 1, 1780, 1}, -- 情缘礼包-男
 	[1] = {18, 1, 1790, 1}, -- 情缘礼包-女
}
tbQiXi2012.MAX_GRAP_LEVEL	= #tbQiXi2012.ROSE_COLORSET;		-- 最多10种图
tbQiXi2012.NUM_SEED		= 2;	-- 男性角色一次领两个种子
tbQiXi2012.NUM_GRAP		= 4;	-- 女性角色一次随机领取4张图
tbQiXi2012.MAX_AWARD_TIMES_BOY		= tbQiXi2012.NUM_SEED	;	-- 男的每天最多领2次
tbQiXi2012.MAX_AWARD_TIMES_GIRL		= tbQiXi2012.NUM_GRAP	;	-- 女的每天最多领4次

tbQiXi2012.LIMIT_LEVEL			= 50;
tbQiXi2012.MAX_TRANSMIT_RANGE	= 30;	-- 传送有效范围
tbQiXi2012.MAX_PLANT_RANGE		= 25;	-- 男女必须在这个范围内才能种植
tbQiXi2012.MAX_FREE_RANGE		= 30;	-- 玩家周围没有npc挡着的距离

tbQiXi2012.SKILLID_CHANGESELF	= 2764;	-- 变身技能ID，沿用六一
tbQiXi2012.SKILLLEVEL_GROP	=
{
	[1] = {[0] = 27, [1] = 28},
	[2] = {[0] = 29, [1] = 30},
	[3] = {[0] = 31, [1] = 32},
	[4] = {[0] = 33, [1] = 34},
	[5] = {[0] = 35, [1] = 36},
	[6] = {[0] = 37, [1] = 38},
	[7] = {[0] = 39, [1] = 40},
	[8] = {[0] = 41, [1] = 42},	
	[9] = {[0] = 43, [1] = 44},	
};
tbQiXi2012.TYPE2NAME	=
{
	[27] = "杨过",
	[28] = "小龙女",
	[29] = "吕布",
	[30] = "貂蝉",
	[31] = "后羿",
	[32] = "嫦娥",
	[33] = "贾宝玉",
	[34] = "林黛玉",
	[35] = "虎子",
	[36] = "燕燕",
	[37] = "圣诞男孩",
	[38] = "圣诞女孩",
	[39] = "唐玄宗",
	[40] = "杨玉环",
	[41] = "许仙",
	[42] = "白素贞",
	[43] = "王重阳",
	[44] = "林朝英",
};
tbQiXi2012.PATH_ROSE_SHARP_SPR =
{
	[1] = "<pic=image\\item\\huodong\\qixi1.spr>",	
	[2] = "<pic=image\\item\\huodong\\qixi2.spr>",	
	[3] = "<pic=image\\item\\huodong\\qixi3.spr>",	
	[4] = "<pic=image\\item\\huodong\\qixi4.spr>",	
	[5] = "<pic=image\\item\\huodong\\qixi5.spr>",	
	[6] = "<pic=image\\item\\huodong\\qixi6.spr>",	
	[7] = "<pic=image\\item\\huodong\\qixi7.spr>",
	[8] = "<pic=image\\item\\huodong\\qixi8.spr>",		
	[9]	= "<pic=image\\item\\huodong\\qixi9.spr>",
	[10]= "<pic=image\\item\\huodong\\qixi10.spr>",
};

tbQiXi2012.PATH_RANDPOS = "\\setting\\event\\jieri\\201208_qixi\\randompos.txt";
-- time
tbQiXi2012.OPEN_DAY		= 20120818;	-- 开启时间
tbQiXi2012.CLOSE_DAY	= 20120827;	-- 结束时间

tbQiXi2012.DAY_OPEN_TIME1 	= 110000;
tbQiXi2012.DAY_CLOSE_TIME1	= 150000;
tbQiXi2012.DAY_OPEN_TIME2 	= 180000;
tbQiXi2012.DAY_CLOSE_TIME2	= 230000;

tbQiXi2012.YINGYUANDENG_DURATION_TIME	= 30 * 60; -- 姻缘灯持续时间
tbQiXi2012.PLANT_INTERVAL	= 20 * 60;	-- 两次种植间隔20分钟
tbQiXi2012.SEED_DURATION_TIME = 15 * 60; -- 种子生命周期 
tbQiXi2012.AWARD_DURATION_TIME = 4 * 60; -- 领奖持续时间
tbQiXi2012.AWARDBOX_BASEVALUE = 80000;	-- 基础奖励
tbQiXi2012.OPENSUOXINYU_INFO = -- 消耗解心玉的个数
{
	-- 层数，消耗解心玉个数，获得的价值量
	[1] = {2, 60000},
	[2] = {4, 120000},
	[3] = {6, 240000},
	[4] = {8, 320000},	
};
tbQiXi2012.OPENSUOXINYU_RANDPET	= -- 随机跟宠的概率,概率最大值100
{
	[1] = 0,
	[2] = 0,
	[3] = 5,
	[4] = 10,
}
tbQiXi2012.QINGYUANLIBAO_AWARD	= -- 记在道具上，最多配六个奖励
{--描述，类型,值,数量,有效期(分钟)
	[1780] = 
	{
		[1] = {"绑金", 1, 1999},
		[2] = {"欢欢坐骑*1（10天）", 2, {1,12,25,4}, 1, 10*24*60},
		[3] = {"情·情深似海*1", 2, {18,1,1656,1}, 1, 30*24*60},
		[4] = {"情·真爱永恒*1", 2, {18,1,1659,1}, 1, 30*24*60},
		[5] = {"愿得一心·白首不离", 3, {6,102,1,0}},
	},
	[1790] = 
	{
		[1] = {"绑金", 1, 1999},
		[2] = {"喜喜坐骑*1（10天）", 2, {1,12,26,4}, 1, 10*24*60},
		[3] = {"情·情深似海*1", 2, {18,1,1656,1}, 1, 30*24*60},
		[4] = {"情·真爱永恒*1", 2, {18,1,1659,1}, 1, 30*24*60},
		[5] = {"晓梦迷蝶·只若初见", 3, {6,101,1,0}},	
	},
};

-- 系统开关
function tbQiXi2012:CheckIsOpen()
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate < self.OPEN_DAY or nDate > self.CLOSE_DAY then
		return 0;
	end
	return self.IS_OPEN;
end