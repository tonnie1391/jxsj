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
Item.tbStone.UNBIND_MIN_TIME			= 60 * 1;	-- 三天后可解绑
Item.tbStone.UNBIND_MAX_TIME			= 60 * 2;	-- 四天后解绑状态失效
Item.tbStone.UNBIND_STONE_SKILLID		= 1689;				-- 解绑BUFF技能ID

Item.tbStone.TASK_GID_BREAKUP			= Item.tbStone.TASK_GID_UNBIND;				-- 主任务ID
Item.tbStone.TASK_SUBID_BREAKUP			= 7;				-- 高级原石拆解子任务ID
Item.tbStone.BREAKUP_MIN_TIME			= 60 * 1;			-- 三小时后有效
Item.tbStone.BREAKUP_MAX_TIME			= 60 * 2;			-- 四小时后状态失效
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
	{"purple", 	"Tím"},
	{"red", 	"Đỏ"},
	{"orange", 	"Cam"},
	{"gold", 	"Vàng"},
	{"blue", 	"Xanh"},
	{"white", 	"Trắng"},
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
	{Item.EQUIPPOS_HEAD, 		"Nón"},
	{Item.EQUIPPOS_BODY,		"Áo"},
	{Item.EQUIPPOS_BELT,		"Lưng"},
	{Item.EQUIPPOS_CUFF,		"Tay"},
	{Item.EQUIPPOS_FOOT,		"Giày"},
	{Item.EQUIPPOS_WEAPON,		"Vũ khí"},
	{Item.EQUIPPOS_NECKLACE,	"Liên"},	

	{Item.EQUIPPOS_RING,		"Nhẫn"},
	{Item.EQUIPPOS_PENDANT,		"Bội"},	
	{Item.EQUIPPOS_AMULET,		"Hộ Phù"},
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
		-- [2] = 343,
		-- [3] = 49,
		-- [4] = 7,
		-- [5] = 1,
		
		[2] = 295,
		[3] = 220,
		[4] = 100,
		[5] = 50,
		[6] = 20,
		[7] = 10,
		[8] = 5,
	}
}
-- warnning：调整上表的时候要修改nAbsoluteOpenDay值，否则概率将出现混乱
Item.tbStone.nAbsoluteOpenDay = 15167;		-- 20110712开放，todo 大飞：多版本需要修改这个值

Item.tbStone.SUBSECTION_DATE = 270;			-- 270天的曲线分割

Item.tbStone.tbSkillStoneDesc = {
	{"Cấp 10","Hành Vân Đới Vũ"},
	{"Cấp 30"},
	{"Cấp 40"},
	{"Cấp 50","Khán Chu Thành Bích"},
	{"Cấp 60"},
	{"Cấp 70"},
	{"Cấp 90"},
	{"Cấp 100","Phong Lưu Vân Tán"},
	{"Cấp 110"},
	{"Cấp 120"},
	{"Mật tịch-Sơ"},
	{"Mật tịch-Trung"},
	{"Mật tịch-Cao"},
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
Item.tbStone.nStonePatchPerStone2 = 50;	-- 30个碎片合成一个宝石
Item.tbStone.tbStonePatch = {18,1,1348,1}; -- 碎片
Item.tbStone.tbStonePatch2 = {22,1,102,1}; -- 碎片2
Item.tbStone.nSendMailEndTime = 7;		-- 发送的邮件7天内有效

Item.tbStone.JIEYUCHUI_WAREID = 444;		-- 解玉锤的商品ID
Item.tbStone.JIEYUCHUI_PRICE = 300;		-- 解玉锤价格190金币


-- 原石升级提示
Item.tbStone.tbStonePreName = {
	"Vỡ",
	"Mòn",
	"Hoàn chỉnh",
	"Tinh xảo",
	"Lấp lánh",
	"Óng Ánh-",
	"Lung Linh",
};

Item.tbStone.tbStoneName = {
	[1]= "Hoàng Quang Thạch",
	[2]= "Diên Dương Thạch",
	[3]= "Dạ Mạc Thạch",
	[4]= "Hạ Dương Thạch",
	[5]= "Kiêu Dương Thạch",
	[6]= "Lôi Đình Ngọc",
	[7]= "Băng Phong Thạch",
	[8]= "Cực Linh Ngọc",
	[9]= "Tuyệt Linh Ngọc",
	[10]= "Chấn Linh Ngọc",
	[11]= "Minh Linh Ngọc",
	[12]= "Hàn Linh Ngọc",
	[13]= "Chu Thiềm Thạch",
	[14]= "Chấn Lộ Thạch",
	[15]= "Thái Hư Thạch",
	[16]= "Thu Huy Thạch",
	[17]= "Nguyệt Quang Thạch",
	[18]= "Tham Lang Thạch",
	[19]= "Ngạo Sương Thạch",
	[20]= "Mị Ảnh Thạch",
	[21]= "Linh Phong Thạch",
	[22]= "Lăng Thiên Ngọc",
	[23]= "Ô Sương Ngọc",
	[24]= "Thương Lang Ngọc",
	[25]= "Nhã Hàn Ngọc",
	[26]= "Lạc Lôi Ngọc",
	[27]= "Chích Viêm Ngọc",
	[28]= "Thực Cốt Ngọc",
	[29]= "Đoạn Hải Ngọc",
	[30]= "Triệt Cốt Ngọc",
	[31]= "Vân Phách Ngọc",
	[32]= "Sí Phần Ngọc",
	[33]= "Hổ Côn Ngọc",
	[34]= "Doãn Tuyết Ngọc",
	[35]= "Ly Tâm Thạch",
	[36]= "Thiên Cơ Thạch",
	[37]= "Điểm Dật Thạch",
	[56]= "Thanh Cổ Ngọc",
	[57]= "Tước Kim Ngọc",
	[58]= "Băng Tàm Ngọc",
	[59]= "Cuồng Lôi Ngọc",
	[60]= "Chúc Dung Ngọc",
	[61]= "U Minh Ngọc",
	[62]= "Phá Thiên Ngọc",
	[63]= "Thương Hải Ngọc",
	[64]= "Tử Điện Ngọc",
	[65]= "Xích Diễm Ngọc",
	[66]= "Truy Nguyệt Thạch",
	[67]= "Huyền Dương Thạch",
	[68]= "Phá Lang Thạch",
};
