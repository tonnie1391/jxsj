------------------------------------------------------
-- 文件名　：define.lua
-- 创建者　：dengyong
-- 创建时间：2011-05-28 16:23:29
-- 描  述  ：宝石相关定义
------------------------------------------------------

Item.tbStone = Item.tbStone or {};

Item.tbStone.EXCHANGE_STYLE_LIMIT 		= 0;	-- 可参与兑换的宝石style
Item.tbStone.SKILL_STONE_STYLE			= 1;	-- 技能宝石style
Item.tbStone.STONE_LEVEL_MAX			= 8;	-- 当前最大宝石等级
Item.tbStone.UPGRADE_LEVEL_DIFF			= 1;	-- 宝石升级时，原石的等级必须等于宝石的等级加1
Item.tbStone.STONE_BREAKUP_LEVEL_LIMIT 	= 3;	-- 2级及以上的原石才能拆解
Item.tbStone.STONE_BREAKUP_RES_COUT		= 3;	-- 原石拆解可得到三个低级的原石
Item.tbStone.STONE_BREAKUP_LEVEL_APPLY	= 4;	-- 3级以上的原石拆解需要申请

Item.tbStone.TASK_GID_UNBIND			= 2085;				-- 主任务ID
Item.tbStone.TASK_SUBID_UNBIND			= 6;				-- 解绑子任务ID
Item.tbStone.UNBIND_MIN_TIME			= 3600 * 1 * 24;	-- 三天后可解绑
Item.tbStone.UNBIND_MAX_TIME			= 3600 * 2 * 24;	-- 四天后解绑状态失效
Item.tbStone.UNBIND_STONE_SKILLID		= 1689;				-- 解绑BUFF技能ID

Item.tbStone.TASK_GID_BREAKUP			= Item.tbStone.TASK_GID_UNBIND;				-- 主任务ID
Item.tbStone.TASK_SUBID_BREAKUP			= 7;				-- 高级原石拆解子任务ID
Item.tbStone.BREAKUP_MIN_TIME			= 3600 * 3;			-- 三小时后有效
Item.tbStone.BREAKUP_MAX_TIME			= 3600 * 4;			-- 四小时后状态失效
Item.tbStone.BREAKUP_STONE_SKILLID		= 1690;				-- 拆解申请BUFF技能ID
Item.tbStone.BREAKUP_COST_MONEY			= 100000;			-- 拆解花费10w绑银

Item.tbStone.emSTONE_OPERATION_NONE		= 0;	-- 不操作或取消操作
Item.tbStone.emSTONE_OPERATION_UPGRADE	= 1;	-- 宝石升级
Item.tbStone.emSTONE_OPERATION_EXCHANGE = 2;	-- 宝石兑换
Item.tbStone.emSTONE_OPERATION_BREAKUP	= 3;	-- 宝石拆解

Item.tbStone.RAND_RATE_SKILLSTONE		= 300;

Item.tbStone.STONE_PRODUCE_LEVEL_LOW	= 1;	-- 宝石产出等级，低
Item.tbStone.STONE_PRODUCE_LEVEL_HIGH	= 2;	-- 宝石产出等级，高

Item.tbStone.STONE_LOW_PRODUCE_BEGIN_LEVEL = 1;	-- 低级产出时产出宝石起始等级
Item.tbStone.STONE_HIGH_PRODUCE_BEGIN_LEVEL = 2;	-- 高级产出时产出宝石起始等级

Item.tbStone.STONE_STAR_LEVEL_1			= 1;	-- 1级的半星
Item.tbStone.STONE_STAR_LEVEL_2			= 3;	-- 2级的1.5星
Item.tbStone.STONE_STAR_LEVEL_BEGINGROW = 2;	-- 从2级开始星级按照等级成长
Item.tbStone.STONE_STAR_LEVEL_GROWTH	= 1;	-- 宝石每级星级成长
Item.tbStone.STAR_LELVEL_REPRESENT_FILE = "\\setting\\item\\001\\extern\\value\\stone_starlevel_represent.txt";

Item.tbStone.SKILLSTONE_STAR_CAL_LEVEL  = 5;	-- 技能加1石头星级计算时的等级
Item.tbStone.EXPSTONE_STAR_CAL_LEVEL  = 4;	-- 技能加1石头星级计算时的等级

-- 装备孔内嵌入的宝石信息位定义
Item.tbStone.tbHoleStoneBitParam = 
{
	{ 0,  7},	-- g值占8位
	{ 8, 11},	-- d值占4位
	{12, 23},	-- p值占12位
	{24, 31},	-- l值占8位
}

Item.tbStone.tbStoneColor = 	-- 宝石颜色列表
{
	{"purple", 	"紫色"},
	{"red", 	"红色"},
	{"orange", 	"橙色"},
	{"gold", 	"金色"},
	{"blue", 	"蓝色"},
	{"white", 	"白色"},
}

-- 再加张表，方便检索
Item.tbStone.tbStoneColorList = 
{
	["purple"] = 1,	
	["red"] = 2,
	["orange"] = 3,
	["gold"] = 4,
	["blue"] = 5,
	["white"] = 6,
}

Item.tbStone.tbStoneTipsImg = 
{
	[0] = 		-- normal
	{
		["empty"] = 167, 
		["purple"] = 172,
		["red"] = 173,
		["orange"] = 174,
		["gold"] = 175,
		["blue"] = 183,
		["white"] = 185,
	},
	[1] =		-- special
	{
		["empty"] = 168, 
		["purple"] = 179,
		["red"] = 180,
		["orange"] = 181,
		["gold"] = 182,
		["blue"] = 184,
		["white"] = 186,
	}
}

Item.tbStone.tbEquipPosDisplayList =
{
	{Item.EQUIPPOS_HEAD, 		"帽子"},
	{Item.EQUIPPOS_BODY,		"衣服"},
	{Item.EQUIPPOS_BELT,		"腰带"},
	{Item.EQUIPPOS_CUFF,		"护腕"},
	{Item.EQUIPPOS_FOOT,		"鞋子"},
	{Item.EQUIPPOS_WEAPON,		"武器"},
	{Item.EQUIPPOS_NECKLACE,	"项链"},	
	{Item.EQUIPPOS_RING,		"戒指"},
	{Item.EQUIPPOS_PENDANT,		"腰坠"},	
	{Item.EQUIPPOS_AMULET,		"护符"},
}

--宝石初始随机序列
--在实际运算中，该表是需要成长的
Item.tbStone.tbStoneLevelRandomSeed =
{
	[Item.tbStone.STONE_PRODUCE_LEVEL_LOW] =
	{
		[1] = 343,
		[2] = 0,
	},
	[Item.tbStone.STONE_PRODUCE_LEVEL_HIGH] =
	{
		[2] = 343,
		[3] = 49,
		[4] = 7,
		[5] = 1,
	}
}
-- warnning：调整上表的时候要修改nAbsoluteOpenDay值，否则概率将出现混乱
Item.tbStone.nAbsoluteOpenDay = 15167;		-- 20110712开放，todo 大飞：多版本需要修改这个值

Item.tbStone.SUBSECTION_DATE = 270;			-- 270天的曲线分割

Item.tbStone.tbSkillStoneDesc = {
	{"10级","行云带雨"},
	{"30级"},
	{"40级"},
	{"50级","看朱成碧"},
	{"60级"},
	{"70级"},
	{"90级"},
	{"100级","风流云散"},
	{"110级"},
	{"120级"},
	{"初级秘籍"},
	{"中级秘籍"},
	{"高级秘籍"},
};
-- 取消掉这样记录日志，不准确
Item.tbStone.tbStoneLogItem = 
{
	--["18,1,1313,1"] = 1;     --跨服白虎宝石原矿
	--["18,1,1314,1"] = 1;     --秦始皇陵宝石原矿
	--["18,1,1315,1"] = 1;     --高级联赛宝石原矿
	--["18,1,1316,1"] = 1;     --逍遥谷宝石原矿  
	--["18,1,1318,1"] = 1;     --门派竞技宝石原矿
	--["18,1,1319,1"] = 1;     --家族竞技宝石原矿
	--["18,1,1320,1"] = 1;     --跨服宋金宝石原矿
}

Item.tbStone.IsOpen = 1;	-- 宝石系统开关
Item.tbStone.nStonePatchPerStone = 30;	-- 30个碎片合成一个宝石
Item.tbStone.tbStonePatch = {18,1,1348,1}; -- 碎片
Item.tbStone.nSendMailEndTime = 7;		-- 发送的邮件7天内有效

Item.tbStone.JIEYUCHUI_WAREID = 444;		-- 解玉锤的商品ID
Item.tbStone.JIEYUCHUI_PRICE = 190;		-- 解玉锤价格190金币


-- 原石升级提示
Item.tbStone.tbStonePreName = {
	"碎裂的",
	"磨损的",
	"完整的",
	"精巧的",
	"耀眼的",
};

Item.tbStone.tbStoneName = {
	"煌光石",
	"延阳石",
	"夜幕石",
	"夏阳石",
	"骄阳石",
	"雷霆玉",
	"冰封石",
	"极灵玉",
	"绝灵玉",
	"震灵玉",
	"冥灵玉",
	"寒灵玉",
	"朱蟾石",
	"晨露石",
	"太虚石",
	"秋辉石",
	"月光石",
	"贪狼石",
	"傲霜石",
	"魅影石",
	"灵风石",
	"凌天玉",
	"乌霜玉",
	"苍狼玉",
	"若寒玉",
	"落雷玉",
	"炙炎玉",
	"蚀骨玉",
	"断海玉",
	"彻骨玉",
	"云珀玉",
	"炽焚玉",
	"虎琨玉",
	"尹雪玉",
	"璃心石",
	"天机石",
	"点逸石",
};
