-------------------------------------------------------
-- 文件名　：keyimen_def.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2012-02-22 11:31:58
-- 文件描述：
-------------------------------------------------------

if MODULE_GAMECLIENT then
	return 0;
end

-- 系统开关
Keyimen.IS_OPEN					= 1;

-- 动态任务
Keyimen.TASK_MAIN_ID			= 60002;

-- 任务变量
Keyimen.TASK_GID 				= 2191;					-- 任务变量组
Keyimen.TASK_GET_PAD			= 1;					-- 领取军令
Keyimen.TASK_PROTECT			= 2;					-- 宕机保护
Keyimen.TASK_ENTERMAP			= 3;					-- 进入地图
Keyimen.TASK_REVTIME			= 4;					-- 重生时间
Keyimen.TASK_CHENCHONG			= 5;					-- 辰虫占用
Keyimen.TASK_STATE				= 16;					-- 任务状态
Keyimen.TASK_CAMP				= 17;					-- 任务阵营

-- 帮会任务完成变量
Keyimen.TASK_FINISH =
{
	[1] = 6,
	[2] = 7,
	[3] = 8,
	[4] = 9,
	[5] = 10,
};

-- 帮会任务目标变量
Keyimen.TASK_TARGET =
{
	[1] = 11,
	[2] = 12,
	[3] = 13,
	[4] = 14,
	[5] = 15,
};

-- 常量定义
Keyimen.MIN_LEVEL				= 100;					-- 角色等级限制
Keyimen.MIN_MANTLE				= 6;					-- 披风等级限制
Keyimen.SUPER_TIME				= 8;					-- 保护时间
Keyimen.NPC_LEVEL				= 130;					-- 怪物等级
Keyimen.RAND_TIME				= 1800;					-- 随机时间
Keyimen.DAEMON_TIME				= 5;					-- 守护时间
Keyimen.BUFFER_INDEX 			= GBLINTBUF_KEYIMEN;	-- buffer index
Keyimen.NEW_HORSE_GDPL			= {1, 12, 61, 4};		-- 新坐骑GDPL
Keyimen.FRANGMENT_GDPL			= {18, 1, 1675, 1};		-- 赤夜飞翎碎片
Keyimen.NEW_HOESE_VALID_TIME	= 7 * 24 * 3600;		-- 7天
Keyimen.GET_FRANG_RANK_LIMIT	= 6;					-- 从6名以后的才可取回碎片
Keyimen.SECONDS_PAST			= 21.5 * 3600;			-- 晚上9点半对应的秒数
Keyimen.REV_TIME				= 0;					-- 限制进入时间
Keyimen.FLAG_TIME				= 40;					-- 旗子存在时间
Keyimen.FLAG_INTERVAL			= 120;					-- 旗子召唤间隔
Keyimen.FINAL_DRAGON			= 12;					-- 最后一个柱子索引
Keyimen.DIALOG_TIME				= 40;					-- 对话npc存在时间
Keyimen.AWARD_EXP				= 8000000;				-- 800w经验
Keyimen.BASE_SALARY				= 1500;					-- 基础工资

-- 新增buffer列表
Keyimen.GBLBUFFER_LIST = 
{
	[GBLINTBUF_KEYIMEN_KIN]		= "tbKinBuffer",
	[GBLINTBUF_KEYIMEN_TONG]	= "tbTongBuffer",
};

-- 消息类型
Keyimen.MSG_TOP					= 1;					-- 全服公告
Keyimen.MSG_MIDDLE				= 2;					-- 中央红字
Keyimen.MSG_BOTTOM				= 3;					-- 底部黑条
Keyimen.MSG_CHANNEL				= 4;					-- 频道提示
Keyimen.MSG_GLOBAL				= 5;					-- 全服提示

-- boss类型
Keyimen.BOSS_TYPE				= 1;					-- 大boss
Keyimen.GUARD_TYPE				= 2;					-- 小boss
Keyimen.MONSTER_TYPE			= 3;					-- 随机boss
Keyimen.DRAGON_TYPE				= 4;					-- 龙柱

-- 技能id
Keyimen.SKILL_SUPER_ID			= 1111;					-- 无敌技能
Keyimen.SKLLL_EQUIP_ID			= 2648;					-- 装备磨损
Keyimen.SKLLL_DAMAGE_ID			= 2649;					-- 伤害加成

-- 阵营名字
Keyimen.CAMP_LIST =
{
	[1] = "Tây Hạ",
	[2] = "Mông Cổ",
};

-- 阵营军令
Keyimen.CAMP_PAD_LIST =
{
	[1] = {18, 1, 1673, 1},
	[2] = {18, 1, 1674, 1},
};

-- 阵营旗子
Keyimen.CAMP_FLAG_LIST =
{
	[1] = 10136,
	[2] = 10137,
};

-- 复活点坐标
Keyimen.REVIVAL_LIST =
{
	[1] = {2148, 1497, 2978},
	[2] = {2150, 1642, 3514},
};

-- 地图ID
Keyimen.MAP_LIST = 
{
	[2147] = 1,		-- 克夷门要隘
	[2148] = 1,		-- 贺兰山东麓
	[2149] = 2,		-- 盐州
	[2150] = 2,		-- 兀剌海城
	[2151] = 0,		-- 鹿合谷
};

-- trap list
Keyimen.TRAP_LIST =
{
	["helan_safe_enter"] 		= {1507, 2970, 0},
	["helan_safe_exit"] 		= {1516, 2947, 1},
	["haicheng_safe_enter1"] 	= {1629, 3526, 0},
	["haicheng_safe_exit1"]		= {1615, 3547, 1},
	["haicheng_safe_enter2"] 	= {1657, 3505, 0},
	["haicheng_safe_exit2"]		= {1670, 3482, 1},
};

-- trap limit
Keyimen.TRAP_LIMIT =
{
	[94] = 
	{
		{"to_helanshandonglu", {2148, 1502, 2858}}, 
		{"to_keyimenyaoai", {2147,1614, 3603}},
	},
	[101] = 
	{
		{"to_yanzhou", {2149, 1924, 3240}}, 
		{"to_wulahaicheng", {2150, 1600, 3589}},
	},
};

-- trap remove
Keyimen.TRAP_REMOVE =
{
	[2147] = {"to_juyanze", {94, 1980, 3936}},
	[2148] = {"to_juyanze", {94, 1775, 3975}},
	[2149] = {"to_shamomigong", {101, 1772, 3893}},
	[2150] = {"to_shamomigong", {101, 1847, 3890}},
};

-- boss list
Keyimen.NPC_BOSS_LIST =
{
	[1] = -- 西夏boss
	{
		nBossId = 10028,
		nDragonId = 11095,
		szDragonName = "Vĩ Túc-Hạ",
		tbPos = 
		{
			{{2147, 1768, 3574}, {2147, 1805, 3550}},
			{{2147, 1866, 3438}, {2147, 1810, 3454}},
			{{2147, 1867, 3649}, {2147, 1905, 3634}},
			{{2148, 1688, 2999}, {2148, 1717, 3009}},																											
			{{2148, 1800, 3301}, {2148, 1808, 3328}},																											
			{{2148, 1930, 3131}, {2148, 1960, 3139}},
		},                        
	},                            
                                  
	[2] = -- 蒙古boss             
	{                             
		nBossId = 10038,          
		nDragonId = 11107,
		szDragonName = "Vĩ Túc-Mông",
		tbPos = 
		{
			{{2149, 1752, 3634}, {2149, 1751, 3658}},
			{{2149, 1771, 3270}, {2149, 1732, 3296}},
			{{2149, 1907, 3738}, {2149, 1940, 3715}},
			{{2150, 1861, 3272}, {2150, 1902, 3252}},
			{{2150, 1931, 3732}, {2150, 1906, 3763}},
			{{2150, 1953, 3401}, {2150, 1956, 3359}},
		},
	},
};

-- guard list
Keyimen.NPC_GUARD_LIST =
{
	[1] = 
	{
		tbGuardId = {10029, 10030, 10031},
		tbPos = 
		{
			{2147, 1716, 3296}, 
			{2147, 1815, 3229},
			{2147, 1970, 3282}, 
			{2147, 2036, 3379},
			{2148, 1611, 3256},
			{2148, 1843, 3032}, 
			{2148, 1902, 2850},
		},
	},
	[2] = 
	{
		tbGuardId = {10039, 10040, 10041},
		tbPos = 
		{
			{2149, 1749, 3483}, 
			{2149, 1885, 3363},
			{2149, 1918, 3578},
			{2150, 1673, 3333}, 
			{2150, 1773, 3567},
			{2150, 1829, 3527},
		},
	},
};

-- monster list
Keyimen.NPC_MONSTER_LIST =
{
	[1] = 
	{
		nMonsterId = 10032,
		tbPos = {{2147, 1713, 3517}, {2147, 1778, 3738}, {2147, 1915, 3678}, {2147, 1913, 3296}},
	},
	[2] = 
	{
		nMonsterId = 10033,
		tbPos = {{2148, 1571, 3065}, {2148, 1927, 3227}, {2148, 1802, 3089}, {2148, 1827, 2864}},
	},
	[3] = 
	{
		nMonsterId = 10042,
		tbPos = {{2149, 1733, 3396}, {2149, 1832, 3537}, {2149, 1844, 3650}, {2149, 1972, 3435}},
	},
	[4] = 
	{
		nMonsterId = 10043,
		tbPos = {{2150, 1628, 3353}, {2150, 1703, 3702}, {2150, 1920, 3307}, {2150, 1961, 3845}},
	},
};

-- boss阶段
Keyimen.BOSS_STEP =
{
	[1] = {75, "Ngươi xem nơi này như nhà vắng chủ sao?"},
	[2] = {50, "Nhìn xem, ngươi có thể làm gì được nào?"},
	[3] = {25, "Ta phải nghiêm túc hơn với các ngươi rồi!"},
};

-- servant list
Keyimen.NPC_SERVANT_LIST =
{
	[1] = 10035,
	[2] = 10045,
};

-- pole list
Keyimen.NPC_POLE_LIST =
{
	[1] = 10034,
	[2] = 10044,
};

-- 幽玄龙柱
Keyimen.NPC_DRAGON_LIST = 
{
	[1] = 
	{
		[1] =  {nNpcId = 11084, tbPos = {2148, 1568, 3176}, szName = "Hỏa Xà-Hạ"},
		[2] =  {nNpcId = 11085, tbPos = {2148, 1759, 3228}, szName = "Thủy Viên-Hạ"},
		[3] =  {nNpcId = 11086, tbPos = {2148, 1876, 3188}, szName = "Mộc Giao-Hạ"},
		[4] =  {nNpcId = 11087, tbPos = {2148, 1742, 2929}, szName = "Thổ Bức-Hạ"},
		[5] =  {nNpcId = 11088, tbPos = {2148, 1878, 2923}, szName = "Kim Ngưu-Hạ"},
		[6] =  {nNpcId = 11089, tbPos = {2148, 1864, 3076}, szName = "Mệnh Quỹ-Hạ"},
		[7] =  {nNpcId = 11090, tbPos = {2147, 1797, 3664}, szName = "Thiên Tôn-Hạ"},
		[8] =  {nNpcId = 11091, tbPos = {2147, 1925, 3611}, szName = "Địa Khuê-Hạ"},
		[9] =  {nNpcId = 11092, tbPos = {2147, 1992, 3467}, szName = "Nguyệt Ô-Hạ"},
		[10] = {nNpcId = 11093, tbPos = {2147, 1885, 3330}, szName = "Nhật Quán-Hạ"},
		[11] = {nNpcId = 11094, tbPos = {2147, 1747, 3277}, szName = "Tinh Trần-Hạ"},
	},
	[2] = 
	{
		[1] =  {nNpcId = 11096, tbPos = {2149, 1675, 3467}, szName = "Hỏa Xà-Mông"},
		[2] =  {nNpcId = 11097, tbPos = {2149, 1706, 3664}, szName = "Thủy Viên-Mông"},
		[3] =  {nNpcId = 11098, tbPos = {2149, 1809, 3511}, szName = "Mộc Giao-Mông"},
		[4] =  {nNpcId = 11099, tbPos = {2149, 1801, 3321}, szName = "Thổ Bức-Mông"},
		[5] =  {nNpcId = 11100, tbPos = {2149, 1984, 3612}, szName = "Kim Ngưu-Mông"},
		[6] =  {nNpcId = 11101, tbPos = {2150, 1758, 3810}, szName = "Mệnh Quỹ-Mông"},
		[7] =  {nNpcId = 11102, tbPos = {2150, 1918, 3789}, szName = "Thiên Tôn-Mông"},
		[8] =  {nNpcId = 11103, tbPos = {2150, 1930, 3558}, szName = "Địa Khuê-Mông"},
		[9] =  {nNpcId = 11104, tbPos = {2150, 1770, 3347}, szName = "Nguyệt Ô-Mông"},
		[10] = {nNpcId = 11105, tbPos = {2150, 1858, 3436}, szName = "Nhật Quán-Mông"},
		[11] = {nNpcId = 11106, tbPos = {2150, 1705, 3285}, szName = "Tinh Trần-Mông"},
	},
};

-- 赤焰龙魂
Keyimen.NPC_DIALOG_LIST = 
{
	[1] = 11108,
	[2] = 11109,
	[3] = 11110,
	[4] = 11111,
	[5] = 11112,
};

-- 计时器列表
Keyimen.tbTimerId = Keyimen.tbTimerId or {};

-- 玩家列表
Keyimen.tbPlayerList = Keyimen.tbPlayerList or {};

-- boss列表
Keyimen.tbBossList = Keyimen.tbBossList or {};

-- damage列表
Keyimen.tbDamageList = Keyimen.tbDamageList or {};

-- kin list
Keyimen.tbKinList = Keyimen.tbKinList or {};

-- tong list
Keyimen.tbTongList = Keyimen.tbTongList or {};

-- global buffer
Keyimen.tbGlobalBuffer = Keyimen.tbGlobalBuffer or {};

-- kin buffer
Keyimen.tbKinBuffer = Keyimen.tbKinBuffer or {};

-- tong buffer
Keyimen.tbTongBuffer = Keyimen.tbTongBuffer or {};

-- active boss
Keyimen.tbActiveList = Keyimen.tbActiveList or {};

-- 龙柱列表
Keyimen.tbDragonList = Keyimen.tbDragonList or {};

-- 系统开关
function Keyimen:CheckIsOpen()
	if TimeFrame:GetState("Keyimen") == 0 then
		return 0;
	end
	return self.IS_OPEN;
end

-- 启动计时器
function Keyimen:StartTimer(nTime, fnTimer, szType, ...)
	self:ClearTimer(szType);
	if arg then
		self.tbTimerId[szType] = Timer:Register(nTime, fnTimer, self, unpack(arg));
	else
		self.tbTimerId[szType] = Timer:Register(nTime, fnTimer, self);
	end
end

-- 关闭计时器
function Keyimen:ClearTimer(szType)
	local nTimerId = self.tbTimerId[szType];
	if nTimerId and nTimerId > 0 then
		local nRest = Timer:GetRestTime(nTimerId);
		if nRest ~= -1 then
			Timer:Close(nTimerId);
		end
		self.tbTimerId[szType] = nil;
	end
end

-- 读取本日阵营
function Keyimen:GetTongCamp(nTongId)
	local tbInfo = self.tbTongBuffer[nTongId];
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if not tbInfo or nDate ~= tbInfo.nDate then
		return 0;
	end
	return tbInfo.nCurCamp or 0;
end

-- boss时段检测
function Keyimen:CheckPeriod()
	local nRet = 0;
	local tbFree = {{1430, 1515}, {2130, 2215}}
	local nTime = tonumber(GetLocalDate("%H%M"));
	for _, tbInfo in pairs(tbFree) do
		if nTime >= tbInfo[1] and nTime <= tbInfo[2] then
			nRet = 1;
		end
	end
	return nRet;
end
