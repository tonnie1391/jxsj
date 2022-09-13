
-- ITEM系统常量表，注意与游戏世界程序保持一致

-- 道具类别
Item.EQUIP_GENERAL			= 1;		-- 白色装备和蓝色装备
Item.EQUIP_PURPLE			= 2;		-- 紫色装备
Item.EQUIP_GOLD				= 3;		-- 黄金装备
Item.EQUIP_GREEN			= 4;		-- 绿色装备
Item.EQUIP_PARTNER			= 5;		-- 同伴装备
Item.EQUIP_PURPLEEX			= 6;		-- ex装备
Item.MEDICINE				= 17;		-- 药品
Item.SCRIPTITEM				= 18;		-- 脚本物品
Item.SKILLITEM				= 19;		-- 技能物品
Item.TASKQUEST				= 20;		-- 任务物品
Item.EXTBAG					= 21;		-- 扩展背包
Item.STUFFITEM				= 22;		-- 生活技能材料
Item.PLANITEM				= 23;		-- 生活技能配方
Item.STONEITEM				= 24;		-- 宝石

-- 装备细类
Item.EQUIP_MELEE_WEAPON		= 1;		-- 近程武器
Item.EQUIP_RANGE_WEAPON		= 2;		-- 远程武器
Item.EQUIP_ARMOR			= 3;		-- 衣服
Item.EQUIP_RING				= 4;		-- 戒指
Item.EQUIP_NECKLACE			= 5;		-- 项链
Item.EQUIP_AMULET			= 6;		-- 护身符
Item.EQUIP_BOOTS			= 7;		-- 鞋子
Item.EQUIP_BELT				= 8;		-- 腰带
Item.EQUIP_HELM				= 9;		-- 头盔
Item.EQUIP_CUFF				= 10;		-- 护腕
Item.EQUIP_PENDANT			= 11;		-- 腰坠
Item.EQUIP_HORSE			= 12;		-- 马匹
Item.EQUIP_MASK				= 13;		-- 面具
Item.EQUIP_BOOK				= 14;		-- 秘籍
Item.EQUIP_ZHEN				= 15;		-- 阵法
Item.EQUIP_SIGNET			= 16;		-- 印章
Item.EQUIP_MANTLE			= 17;		-- 披风
Item.EQUIP_CHOP				= 18;		-- 官印
Item.EQUIP_PARTNERWEAPON	= 19;		-- 同伴武器
Item.EQUIP_PARTNERBODY		= 20;		-- 同伴衣服
Item.EQUIP_PARTNERRING		= 21;		-- 同伴戒指
Item.EQUIP_PARTNERCUFF		= 22;		-- 同伴护腕
Item.EQUIP_PARTNERAMULET	= 23;		-- 同伴护身符
Item.EQUIP_ZHENYUAN			= 24;		-- 真元
Item.EQUIP_GARMENT			= 25;		-- 外衣
Item.EQUIP_OUTHAT			= 26;		-- 外帽

-- 扩展背包细类
Item.EXTBAG_4CELL			= 1;		-- 4格背包
Item.EXTBAG_6CELL			= 2;		-- 6格背包
Item.EXTBAG_8CELL			= 3;		-- 8格背包
Item.EXTBAG_10CELL			= 4;		-- 10格背包
Item.EXTBAG_12CELL			= 5;		-- 12格背包
Item.EXTBAG_15CELL			= 6;		-- 15格背包
Item.EXTBAG_18CELL			= 7;		-- 18格背包
Item.EXTBAG_20CELL			= 8;		-- 20格背包
Item.EXTBAG_24CELL			= 9;		-- 24格背包

-- 道具属性数目
Item.COUNT_BASE				= 7;		-- 基本属性的数目
Item.COUNT_REQ				= 6;		-- 需求属性的数目
Item.COUNT_RANDOM			= 6;		-- 装备随机魔法属性的数目
Item.COUNT_ENHANCE			= 4;		-- 装备增强附加属性的数目
Item.COUNT_SUITE			= 4;		-- 套装激活附加属性的数目
Item.COUNT_EXTPARAM			= 20;		-- 道具扩展参数数目

-- 宝石细类
Item.SONTE_NONE				= 0;		-- 非宝石
Item.STONE_PRODUCT			= 1;		-- 成品宝石
Item.STONE_GEM				= 2;		-- 原石

-- 脚本类道具细类
Item.SCRIPTITEM_NORMAL		= 1;		-- 普通类
Item.SCRIPTITEM_REFINESTUFF = 2;		-- 炼化图纸
Item.SCRIPTITEM_STRSUTFF  	= 3;		-- 装备改造符
Item.SCRIPTITEM_CASTSTUFF	= 4;		-- 精铸图纸


-- 装备穿在身上的位置
Item.EQUIPPOS_HEAD			= 0;		-- 头
Item.EQUIPPOS_BODY			= 1;		-- 衣服
Item.EQUIPPOS_BELT			= 2;		-- 腰带
Item.EQUIPPOS_WEAPON		= 3;		-- 武器
Item.EQUIPPOS_FOOT			= 4;		-- 鞋子
Item.EQUIPPOS_CUFF			= 5;		-- 护腕
Item.EQUIPPOS_AMULET		= 6;		-- 护身符
Item.EQUIPPOS_RING			= 7;		-- 戒指
Item.EQUIPPOS_NECKLACE		= 8;		-- 项链
Item.EQUIPPOS_PENDANT		= 9;		-- 腰坠
Item.EQUIPPOS_HORSE			= 10;		-- 马
Item.EQUIPPOS_MASK			= 11;		-- 面具
Item.EQUIPPOS_BOOK			= 12; 		-- 秘籍
Item.EQUIPPOS_ZHEN			= 13;		-- 阵法
Item.EQUIPPOS_SIGNET		= 14;		-- 印章
Item.EQUIPPOS_MANTLE		= 15;		-- 披风
Item.EQUIPPOS_CHOP			= 16;		-- 官印
Item.EQUIPPOS_ZHENYUAN_MAIN = 17;		-- 主真元
Item.EQUIPPOS_ZHENYUAN_SUB1 = 18;		-- 辅真元
Item.EQUIPPOS_ZHENYUAN_SUB2 = 19;		-- 从真元
Item.EQUIPPOS_GARMENT		= 20;		-- 外衣
Item.EQUIPPOS_OUTHAT		= 21;		-- 外帽
Item.EQUIPPOS_NUM			= 22;

-- 同伴装备在同伴装备栏的位置
Item.PARTNEREQUIP_WEAPON	= 0;		-- 同伴装备--武器
Item.PARTNEREQUIP_BODY		= 1;		-- 同伴装备--衣服
Item.PARTNEREQUIP_RING		= 2;		-- 同伴装备--戒指
Item.PARTNEREQUIP_CUFF		= 3;		-- 同伴装备--护腕
Item.PARTNEREQUIP_AMULET	= 4;		-- 同伴装备--护身符
Item.PARTNEREQUIP_NUM		= 5;

Item.emKEQUIP_WEAPON_CATEGORY_HAND		= 11;	-- 空手、裹手
Item.emKEQUIP_WEAPON_CATEGORY_SWORD		= 12;	-- 剑
Item.emKEQUIP_WEAPON_CATEGORY_KNIFE		= 13;	-- 刀
Item.emKEQUIP_WEAPON_CATEGORY_STICK		= 14;	-- 棍
Item.emKEQUIP_WEAPON_CATEGORY_SPEAR		= 15;	-- 枪
Item.emKEQUIP_WEAPON_CATEGORY_HAMMER	= 16;	-- 锤
Item.emKEQUIP_WEAPON_CATEGORY_DART		= 21;	-- 镖
Item.emKEQUIP_WEAPON_CATEGORY_FLYBAR	= 22;	-- 飞刀
Item.emKEQUIP_WEAPON_CATEGORY_ARROW		= 23;	-- 箭矢

-- 切换装备穿在身上的位置
Item.EQUIPEXPOS_HEAD		= 0;		-- 头
Item.EQUIPEXPOS_BODY		= 1;		-- 衣服
Item.EQUIPEXPOS_BELT		= 2;		-- 腰带
Item.EQUIPEXPOS_WEAPON		= 3;		-- 武器
Item.EQUIPEXPOS_FOOT		= 4;		-- 鞋子
Item.EQUIPEXPOS_CUFF		= 5;		-- 护腕
Item.EQUIPEXPOS_AMULET		= 6;		-- 护身符
Item.EQUIPEXPOS_RING		= 7;		-- 戒指
Item.EQUIPEXPOS_NECKLACE	= 8;		-- 项链
Item.EQUIPEXPOS_PENDANT		= 9;		-- 腰坠
Item.EQUIPEXPOS_NUM			= 10;

-- 扩展背包位置
Item.EXTBAGPOS_BAG1			= 0;		-- 扩展背包1
Item.EXTBAGPOS_BAG2			= 1;		-- 扩展背包2
Item.EXTBAGPOS_BAG3			= 2;		-- 扩展背包3
Item.EXTBAGPOS_NUM			= 3;		-- 扩展背包总数

-- 扩展储物箱位置
Item.EXTREPPOS_REP1			= 0;		-- 扩展储物箱1
Item.EXTREPPOS_REP2			= 1;		-- 扩展储物箱2
Item.EXTREPPOS_REP3			= 2;		-- 扩展储物箱3
Item.EXTREPPOS_REP4			= 3;		-- 扩展储物箱4
Item.EXTREPPOS_REP5			= 4;		-- 扩展储物箱5
Item.EXTREPPOS_NUM			= 5;		-- 扩展储物箱总数

-- 道具容器
Item.ROOM_NONE				= -1;		-- 无
Item.ROOM_EQUIP				= 0;		-- 装备着的
Item.ROOM_EQUIPEX			= 1;		-- 装备切换空间
Item.ROOM_MAINBAG			= 2;		-- 主背包
Item.ROOM_REPOSITORY		= 3;		-- 贮物箱
Item.ROOM_EXTBAGBAR			= 4;		-- 扩展背包放置栏
Item.ROOM_EXTBAG1			= 5;		-- 扩展背包1
Item.ROOM_EXTBAG2			= 6;		-- 扩展背包2
Item.ROOM_EXTBAG3			= 7;		-- 扩展背包3
Item.ROOM_EXTREP1			= 8;		-- 扩展贮物箱1
Item.ROOM_EXTREP2			= 9;		-- 扩展贮物箱2
Item.ROOM_EXTREP3			= 10;		-- 扩展贮物箱3
Item.ROOM_EXTREP4			= 11;		-- 扩展贮物箱4
Item.ROOM_EXTREP5			= 12;		-- 扩展贮物箱5
Item.ROOM_MAIL				= 13;		-- 信件附件
Item.ROOM_TRADE				= 14;		-- 交易栏
Item.ROOM_TRADECLIENT		= 15;		-- 交易过程中对方的交易栏
Item.ROOM_GIFT				= 16;		-- 客户端给予界面
Item.ROOM_ENHANCE_EQUIP		= 17;		-- 装备强化/玄晶剥离装备栏空间
Item.ROOM_ENHANCE_ITEM		= 18;		-- 装备强化/玄晶剥离/玄晶合成 玄晶放置空间
Item.ROOM_BREAKUP			= 19;		-- 装备拆解空间
Item.ROOM_RECYCLE			= 20;		-- 回购空间
Item.ROOM_AUCTION           = 21;       -- 拍卖行卖物空间
Item.ROOM_IBSHOPCART		= 22		-- 奇珍阁购物车优惠券格子
Item.ROOM_PARTNEREQUIP		= 23;		-- 同伴装备栏
Item.ROOM_EQUIPEX2			= 24;		-- 备用装备栏2，加战斗力
Item.ROOM_ZHENYUAN_XIULIAN_ZHENYUAN		= 25;			-- 真元修炼，放真元的格子
Item.ROOM_ZHENYUAN_XIULIAN_ITEM			= 26;			-- 真元修炼，放经验书的格子
Item.ROOM_ZHENYUAN_REFINE_MAIN			= 27;			-- 真元炼化空间，主真元
Item.ROOM_ZHENYUAN_REFINE_CONSUME		= 28;			-- 真元炼化空间，副真元
Item.ROOM_ZHENYUAN_REFINE_RESULT		= 29;			-- 真元炼化空间，结果格子
Item.ROOM_REPOSITORY_EXT	= 30;
Item.ROOM_HOLE_EQUIP = 31;				-- 装备打孔/镶嵌/剥离 的装备
Item.ROOM_STONE_EXCHANGE_ORG= 32;
Item.ROOM_INTEGRATIONBAG1	= 33;		-- 新背包，包含主背包和扩展背包，是一个虚拟的空间
Item.ROOM_INTEGRATIONBAG2	= 34;
Item.ROOM_INTEGRATIONBAG3	= 35;
Item.ROOM_INTEGRATIONBAG4	= 36;
Item.ROOM_INTEGRATIONBAG5	= 37;
Item.ROOM_INTEGRATIONBAG6	= 38;
Item.ROOM_INTEGRATIONBAG7	= 39;
Item.ROOM_INTEGRATIONBAG8	= 40;
Item.ROOM_INTEGRATIONBAG9	= 41;
Item.ROOM_INTEGRATIONBAG10	= 42;
Item.ROOM_INTEGRATIONBAG11	= 43;
Item.ROOM_STALL_SALE_SETTING= 44;		-- 摆摊贩卖设置
Item.ROOM_OFFER_BUY_SETTING	= 45;		-- 摆摊收购设置
Item.ROOM_KIN_REPOSITORY1	= 46;		-- 家族贮物箱1
Item.ROOM_KIN_REPOSITORY2	= 47;		-- 家族贮物箱2
Item.ROOM_KIN_REPOSITORY3	= 48;		-- 家族贮物箱3
Item.ROOM_KIN_REPOSITORY4	= 49;		-- 家族贮物箱4
Item.ROOM_KIN_REPOSITORY5	= 50;		-- 家族贮物箱5
Item.ROOM_KIN_REPOSITORY6	= 51;		-- 家族贮物箱6
Item.ROOM_KIN_REPOSITORY7	= 52;		-- 家族贮物箱7
Item.ROOM_KIN_REPOSITORY8	= 53;		-- 家族贮物箱8
Item.ROOM_KIN_REPOSITORY9	= 54;		-- 家族贮物箱9
Item.ROOM_KIN_REPOSITORY10	= 55;		-- 家族贮物箱10
Item.ROOM_NUM				= 56;		

-- 装备穿在身上的位置描述字符串
Item.EQUIPPOS_NAME =
{
	[Item.EQUIPPOS_HEAD]		= "Nón",
	[Item.EQUIPPOS_BODY]		= "Áo",
	[Item.EQUIPPOS_BELT]		= "Yêu đái",
	[Item.EQUIPPOS_WEAPON]		= "Vũ khí",
	[Item.EQUIPPOS_FOOT]		= "Giày",
	[Item.EQUIPPOS_CUFF]		= "Tay",
	[Item.EQUIPPOS_AMULET]		= "Phù",
	[Item.EQUIPPOS_RING]		= "Nhẫn",
	[Item.EQUIPPOS_NECKLACE]	= "Liên",
	[Item.EQUIPPOS_PENDANT]		= "Bội",
	[Item.EQUIPPOS_HORSE]		= "Ngựa",
	[Item.EQUIPPOS_MASK]		= "Mặt",
	[Item.EQUIPPOS_BOOK]		= "Bí kíp",
	[Item.EQUIPPOS_ZHEN]		= "Trận",
	[Item.EQUIPPOS_SIGNET]		= "Ấn",
	[Item.EQUIPPOS_MANTLE]		= "Choàng",
	[Item.EQUIPPOS_CHOP]		= "Quan ấn",
	[Item.EQUIPPOS_ZHENYUAN_MAIN] = "Chân nguyên",
	[Item.EQUIPPOS_ZHENYUAN_SUB1] = "Chân nguyên",
	[Item.EQUIPPOS_ZHENYUAN_SUB2] = "Chân nguyên",
	[Item.EQUIPPOS_GARMENT]		= "Khoác",
	[Item.EQUIPPOS_OUTHAT]		= "Nón",	
	[Item.EQUIPPOS_NUM + Item.PARTNEREQUIP_WEAPON] = "Đồng Hành Chi Nhẫn",
	[Item.EQUIPPOS_NUM + Item.PARTNEREQUIP_BODY] = "Đồng Hành Chi Y",
	[Item.EQUIPPOS_NUM + Item.PARTNEREQUIP_RING] = "Đồng Hành Chi Giới",
	[Item.EQUIPPOS_NUM + Item.PARTNEREQUIP_CUFF] = "Đồng Hành Hộ Uyển",
	[Item.EQUIPPOS_NUM + Item.PARTNEREQUIP_AMULET] = "Đồng Hành Hộ Phù",
};

Item.WEAPON_NAME = 
{
	[Item.emKEQUIP_WEAPON_CATEGORY_HAND]		= "Triền thủ",
	[Item.emKEQUIP_WEAPON_CATEGORY_SWORD]		= "Kiếm",
	[Item.emKEQUIP_WEAPON_CATEGORY_KNIFE]		= "Đao",
	[Item.emKEQUIP_WEAPON_CATEGORY_STICK]		= "Côn",
	[Item.emKEQUIP_WEAPON_CATEGORY_SPEAR]		= "Thương",
	[Item.emKEQUIP_WEAPON_CATEGORY_HAMMER]		= "Chùy",
	[Item.emKEQUIP_WEAPON_CATEGORY_DART]		= "Tiêu",
	[Item.emKEQUIP_WEAPON_CATEGORY_FLYBAR]		= "Phi đao",
	[Item.emKEQUIP_WEAPON_CATEGORY_ARROW]		= "Tiễn",
}

-- 所有背包的空间
Item.BAG_ROOM =
{
	Item.ROOM_MAINBAG,
	Item.ROOM_EXTBAG1,
	Item.ROOM_EXTBAG2,
	Item.ROOM_EXTBAG3,
};

Item.REPOSITORY_ROOM =
{
	Item.ROOM_REPOSITORY,		-- 贮物箱
	Item.ROOM_EXTREP1,		-- 扩展贮物箱1
	Item.ROOM_EXTREP2,		-- 扩展贮物箱2
	Item.ROOM_EXTREP3,		-- 扩展贮物箱3
	Item.ROOM_EXTREP4,		-- 扩展贮物箱4
	Item.ROOM_EXTREP5,		-- 扩展贮物箱5
}

-- 扩展背包位置对应空间
Item.EXTBAGPOS2ROOM =
{
	[0] = Item.ROOM_EXTBAG1,
	[1] = Item.ROOM_EXTBAG2,
	[2] = Item.ROOM_EXTBAG3,
};

-- 扩展储物箱序号对应空间
Item.EXTREPPOS2ROOM =
{
	[0] = Item.ROOM_EXTREP1,
	[1] = Item.ROOM_EXTREP2,
	[2] = Item.ROOM_EXTREP3,
	[3] = Item.ROOM_EXTREP4,
	[4] = Item.ROOM_EXTREP5,
};

-- 绑定类型
Item.BIND_NONE					= 0;		-- 不绑定
Item.BIND_GET					= 1;		-- 获取时绑定，可以卖给NPC
Item.BIND_EQUIP					= 2;		-- 装备时绑定
Item.BIND_OWN					= 3;		-- 获取时绑定，不可以卖给NPC
Item.BIND_NONE_OWN				= 4;		-- 不绑定，不可以卖给NPC

-- 修理方式
Item.REPAIR_COMMON				= 1;		-- 普通修理
Item.REPAIR_SPECIAL				= 2;		-- 特殊修理
Item.REPAIR_ITEM				= 3;		-- 使用道具修理

Item.MIN_LEVEL					= 1;		-- 道具最低等级
Item.MAX_EQUIP_LEVEL			= 10;		-- 装备最高等级
Item.MAX_EQUIP_ENHANCE			= 16;		-- 装备最多可以强化16次
Item.MIN_COMMON_EQUIP			= 1;		-- 普通装备（参与五行激活）细类最小值
Item.MAX_COMMON_EQUIP			= 11;		-- 普通装备（参与五行激活）细类最大值
Item.MAX_RANDATTRIB_LEVEL		= Item.MAX_EQUIP_LEVEL + Item.MAX_EQUIP_ENHANCE;

Item.DUR_MAX					= 1000;		-- 耐久满值
Item.DUR_WARNING				= 300;		-- 耐久警告值

Item.MIN_BOOK_LEVEL				= 1;		-- 秘籍最小等级
Item.MAX_BOOK_LEVEL				= 100;		-- 秘籍最大等级

Item.MIN_SIGNET_LEVEL			= 1;
Item.tbMAX_SIGNET_LEVEL	=
{
	[1] = 1000, 
	[2] = 1500,
}

Item.SIGNET_ATTRIB_NUM			= 2;

-- 各ROOM尺寸定义
Item.ROOM_EQUIP_WIDTH			= Item.EQUIPPOS_NUM;			-- 装备栏格子数
Item.ROOM_EQUIP_HEIGHT			= 1;
Item.ROOM_EQUIPEX_WIDTH			= Item.EQUIPEXPOS_NUM;			-- 切换装备栏格子数
Item.ROOM_EQUIPEX_HEIGHT		= 1;
Item.ROOM_MAINBAG_WIDTH			= 5;							-- 主背包宽度
Item.ROOM_MAINBAG_HEIGHT		= 8;							-- 主背包高度
Item.ROOM_INTEGRATIONBAG_WIDTH	= 11;							-- 新背包宽度
Item.ROOM_REPOSITORY_WIDTH		= 5;							-- 储物箱宽度
Item.ROOM_REPOSITORY_HEIGHT		= 8;							-- 储物箱高度
Item.ROOM_EXTBAGBAR_WIDTH		= Item.EXTBAGPOS_NUM;			-- 扩展背包总数
Item.ROOM_EXTBAGBAR_HEIGHT		= 1;
Item.ROOM_EXTBAG_WIDTH			= 6;							-- 扩展背包最大宽度
Item.ROOM_EXTBAG_HEIGHT			= 4;							-- 扩展背包最大高度
Item.ROOM_EXTREP_WIDTH			= Item.ROOM_REPOSITORY_WIDTH;	-- 扩展储物箱宽度
Item.ROOM_EXTREP_HEIGHT			= Item.ROOM_REPOSITORY_HEIGHT;	-- 扩展储物箱高度
Item.ROOM_MAIL_WIDTH			= 1;
Item.ROOM_MAIL_HEIGHT			= 1;
Item.ROOM_TRADE_WIDTH			= 3;							-- 交易栏宽度
Item.ROOM_TRADE_HEIGHT			= 5;							-- 交易栏高度
Item.ROOM_GIFT_WIDTH			= 6;							-- 给予界面宽度
Item.ROOM_GIFT_HEIGHT			= 4;							-- 给予界面高度
Item.ROOM_ENHANCE_EQUIP_WIDTH	= 1;
Item.ROOM_ENHANCE_EQUIP_HEIGHT	= 1;
Item.ROOM_ENHANCE_ITEM_WIDTH	= 4;							-- 装备强化放置玄晶界面宽度
Item.ROOM_ENHANCE_ITEM_HEIGHT	= 4;							-- 装备强化放置玄晶界面高度
Item.ROOM_BREAKUP_WIDTH			= 1;
Item.ROOM_BREAKUP_HEIGHT		= 1;
Item.ROOM_RECYCLE_WIDTH			= 5;
Item.ROOM_RECYCLE_HEIGHT		= 4;
Item.ROOM_PARTNER_EQUIP_WIDTH	= Item.PARTNEREQUIP_NUM;		-- 同伴装备栏宽度
Item.ROOM_PARTNER_EQUIP_HEIGHT	= 1;							-- 同伴装备栏高度
Item.ROOM_ZHENYUAN_XIULIAN_ZHENYUAN_WIDTH = 1;					-- 真元修炼空间放真元界面宽度
Item.ROOM_ZHENYUAN_XIULIAN_ZHENYUAN_HEIGHT = 1;					-- 真元修炼空间放真元界面高度
Item.ROOM_ZHENYUAN_XIULIAN_ITEM_WIDTH = 6;						-- 真元修炼空间放经验界面宽度
Item.ROOM_ZHENYUAN_XIULIAN_ITEM_HEIGHT = 3;						-- 真元修炼空间放经验界面高度
Item.ROOM_ZHENYUAN_REFINE_WIDTH	= 1;							-- 真元炼化空间每个格子的宽度
Item.ROOM_ZHENYUAN_REFINE_HEIGHT = 1;							-- 真元炼化空间每个格子的高度
Item.KD_ROOM_HOLE_EQUIP_WIDTH	= 1;							-- 装备打孔的装备格子宽度		
Item.KD_ROOM_HOLE_EQUIP_HEIGHT	= 1;							-- 装备打孔的装备格子高度
Item.ROOM_STONE_EXCHANGE_ORG_WIDTH	= 3;						-- 宝石兑换界面宝石格子宽度
Item.ROOM_STONE_EXCHANGE_ORG_HEIGHT = 1;						-- 宝石兑换界面宝石格子高度
Item.ROOM_STALL_WIDTH			= 5;
Item.ROOM_STALL_HEIGHT			= 8;
Item.ROOM_KIN_REPOSITORY_WIDTH	= 8;
Item.ROOM_KIN_REPOSITORY_HEIGHT	= 6;

-- ROOM总大小
Item.ROOM_EQUIP_SIZE			= Item.ROOM_EQUIP_WIDTH * Item.ROOM_EQUIP_HEIGHT;
Item.ROOM_EQUIPEX_SIZE			= Item.ROOM_EQUIPEX_WIDTH * Item.ROOM_EQUIPEX_HEIGHT;
Item.ROOM_MAINBAG_SIZE			= Item.ROOM_MAINBAG_WIDTH * Item.ROOM_MAINBAG_HEIGHT;
Item.ROOM_REPOSITORY_SIZE		= Item.ROOM_REPOSITORY_WIDTH * Item.ROOM_REPOSITORY_HEIGHT;
Item.ROOM_EXTBAGBAR_SIZE		= Item.ROOM_EXTBAGBAR_WIDTH * Item.ROOM_EXTBAGBAR_HEIGHT;
Item.ROOM_EXTBAG_SIZE			= Item.ROOM_EXTBAG_WIDTH * Item.ROOM_EXTBAG_HEIGHT;
Item.ROOM_EXTREP_SIZE			= Item.ROOM_EXTREP_WIDTH * Item.ROOM_EXTREP_HEIGHT;
Item.ROOM_MAIL_SIZE				= Item.ROOM_MAIL_WIDTH * Item.ROOM_MAIL_HEIGHT;
Item.ROOM_TRADE_SIZE			= Item.ROOM_TRADE_WIDTH * Item.ROOM_TRADE_HEIGHT;
Item.ROOM_GIFT_SIZE				= Item.ROOM_GIFT_WIDTH * Item.ROOM_GIFT_HEIGHT;
Item.ROOM_ENHANCE_EQUIP_SIZE	= Item.ROOM_ENHANCE_EQUIP_WIDTH * Item.ROOM_ENHANCE_EQUIP_HEIGHT;
Item.ROOM_ENHANCE_ITEM_SIZE		= Item.ROOM_ENHANCE_ITEM_WIDTH * Item.ROOM_ENHANCE_ITEM_HEIGHT;
Item.ROOM_BREAKUP_SIZE			= Item.ROOM_BREAKUP_WIDTH * Item.ROOM_BREAKUP_HEIGHT;
Item.ROOM_RECYCLE_SIZE			= Item.ROOM_RECYCLE_WIDTH * Item.ROOM_RECYCLE_HEIGHT;
Item.ROOM_PARTNEREQUIP_SIZE		= Item.ROOM_PARTNER_EQUIP_WIDTH * Item.ROOM_PARTNER_EQUIP_HEIGHT;
Item.ROOM_ZHENYUAN_XIULIAN_ITEM_SIZE = Item.ROOM_ZHENYUAN_XIULIAN_ITEM_WIDTH * Item.ROOM_ZHENYUAN_XIULIAN_ITEM_HEIGHT;
Item.ROOM_ZHENYUAN_XIULIAN_ZHENYUAN_SIZE = Item.ROOM_ZHENYUAN_XIULIAN_ZHENYUAN_WIDTH * Item.ROOM_ZHENYUAN_XIULIAN_ZHENYUAN_HEIGHT;
Item.ROOM_ZHENYUAN_REFINE_MAIN_SIZE	= Item.ROOM_ZHENYUAN_REFINE_WIDTH * Item.ROOM_ZHENYUAN_REFINE_HEIGHT;
Item.ROOM_ZHENYUAN_REFINE_CONSUME_SIZE = ROOM_ZHENYUAN_REFINE_MAIN_SIZE;
Item.ROOM_ZHENYUAN_REFINE_RESULT_SIZE = Item.ROOM_ZHENYUAN_REFINE_MAIN_SIZE;
Item.ROOM_STONE_EXCHANGE_ORG_SIZE = Item.ROOM_STONE_EXCHANGE_ORG_WIDTH * Item.ROOM_STONE_EXCHANGE_ORG_HEIGHT;
Item.KD_ROOM_KIN_REPOSITORY_SIZE = Item.ROOM_KIN_REPOSITORY_WIDTH * Item.ROOM_KIN_REPOSITORY_HEIGHT;

-- 扩展背包大小
Item.EXTBAG_WIDTH_4CELL			= 4;		-- 4格背包宽度
Item.EXTBAG_WIDTH_6CELL			= 6;		-- 6格背包宽度
Item.EXTBAG_WIDTH_8CELL			= 4;		-- 8格背包宽度
Item.EXTBAG_WIDTH_10CELL		= 5;		-- 10格背包宽度
Item.EXTBAG_WIDTH_12CELL		= 6;		-- 12格背包宽度
Item.EXTBAG_WIDTH_15CELL		= 5;		-- 15格背包宽度
Item.EXTBAG_WIDTH_18CELL		= 6;		-- 18格背包宽度
Item.EXTBAG_WIDTH_20CELL		= 5;		-- 20格背包宽度
Item.EXTBAG_WIDTH_24CELL		= 6;		-- 24格背包宽度
Item.EXTBAG_HEIGHT_4CELL		= 1;		-- 4格背包高度
Item.EXTBAG_HEIGHT_6CELL		= 1;		-- 6格背包高度
Item.EXTBAG_HEIGHT_8CELL		= 2;		-- 8格背包高度
Item.EXTBAG_HEIGHT_10CELL		= 2;		-- 10格背包高度
Item.EXTBAG_HEIGHT_12CELL		= 2;		-- 12格背包高度
Item.EXTBAG_HEIGHT_15CELL		= 3;		-- 15格背包高度
Item.EXTBAG_HEIGHT_18CELL		= 3;		-- 18格背包高度
Item.EXTBAG_HEIGHT_20CELL		= 4;		-- 20格背包高度
Item.EXTBAG_HEIGHT_24CELL		= 4;		-- 24格背包高度

-- 道具Tip状态
Item.TIPS_NORMAL				= 0;		-- 正常浏览状态
Item.TIPS_CREPAIR				= 1;		-- 普通修理状态
Item.TIPS_SREPAIR				= 2;		-- 特殊修理状态
Item.TIPS_IREPAIR				= 3;		-- 道具修理状态
Item.TIPS_LINK					= 4;		-- 道具链接状态
Item.TIPS_SHOP					= 5;		-- NPC购买/贩卖状态
Item.TIPS_STALL					= 6;		-- 摆摊状态
Item.TIPS_OFFER					= 7;		-- 收购状态
Item.TIPS_PREVIEW				= 8;		-- 固定属性装备未生成的属性预览状态
Item.TIPS_ENHANCE				= 9;		-- 装备强化预览状态
Item.TIPS_GOODS					= 10;		-- 商品属性预览状态
Item.TIPS_BINDGOLD_SECTION		= 11;		-- 奇珍阁绑定区状态
Item.TIPS_NOBIND_SECTION		= 12;		-- 奇真阁非绑定区状态
Item.TIPS_STRENGTHEN			= 13;		-- 改造装备预览状态
Item.TIPS_TRANSFER				= 14;		-- 强化转移预览
Item.TIPS_INTEGRAL_SECTION		= 15;		-- 奇珍阁积分区状态

-- 强化操作类型
Item.ENHANCE_MODE_NONE			= 0;		-- 无操作/取消操作
Item.ENHANCE_MODE_ENHANCE		= 1;		-- 装备强化
Item.ENHANCE_MODE_PEEL			= 2;		-- 玄晶剥离
Item.ENHANCE_MODE_COMPOSE		= 3;		-- 玄晶合成
Item.ENHANCE_MODE_UPGRADE		= 4;		-- 升级印鉴
Item.ENHANCE_MODE_REFINE		= 5;		-- 装备炼化
Item.ENHANCE_MODE_STRENGTHEN	= 6;		-- 装备改造
Item.ENHANCE_MODE_ENHANCE_TRANSFER  = 7;	-- 强化转移
Item.ENHANCE_MODE_EQUIP_RECAST		= 8;	-- 重铸道具
Item.ENHANCE_MODE_STONE_BREAKUP		= 9;	-- 宝石拆解
Item.ENHANCE_MODE_WEAPON_PEEL		= 10;	--青铜武器剥离
Item.ENHANCE_MODE_CAST				= 11;	-- 装备精铸
Item.ENHANCE_MODE_BREAKUP_XUAN		= 12;	-- 玄晶拆解
Item.ENHANCE_MODE_YINJIAN_RECAST	= 13;	-- 重铸印鉴
Item.ENHANCE_MODE_ALLOW_ALL			= 14;	-- 加这个枚举是为了区别对待特权操作和普通操作

-- 道具自定义字符串类型
Item.CUSTOM_TYPE_NONE			= 0;		-- 未使用
Item.CUSTOM_TYPE_MAKER			= 1;		-- 制造者名字
Item.CUSTOM_TYPE_EVENT			= 2;		-- 活动定制

Item.BIND_MONEY					= 0;
Item.NORMAL_MONEY				= 1;

-- 装备五形对应表
Item.tbSeriesFix = 
{
	[Item.EQUIPPOS_HEAD]			= {1,2,3,4,5},		-- 头
	[Item.EQUIPPOS_BODY]			= {3,4,2,5,1},		-- 衣服
	[Item.EQUIPPOS_BELT]			= {2,5,4,1,3},		-- 腰带
	[Item.EQUIPPOS_WEAPON]			= {1,2,3,4,5},		-- 武器
	[Item.EQUIPPOS_FOOT]			= {5,3,1,2,4},		-- 鞋子
	[Item.EQUIPPOS_CUFF]			= {4,1,5,3,2},		-- 护腕
	[Item.EQUIPPOS_AMULET]			= {5,3,1,2,4},		-- 护身符
	[Item.EQUIPPOS_RING]			= {2,5,4,1,3},		-- 戒指
	[Item.EQUIPPOS_NECKLACE]		= {3,4,2,5,1},		-- 项链
	[Item.EQUIPPOS_PENDANT]			= {4,1,5,3,2},		-- 腰坠
}

Item.TIP_SERISE = 
{
	"<color=yellow>Hệ Kim<color>", 
	"<color=green>Hệ Mộc<color>", 
	"<color=blue>Hệ Thủy<color>", 
	"<color=red>Hệ Hỏa<color>", 
	"<color=gray>Hệ Thổ<color>",
};

Item.SIGNET_ATTRIB_NUM			= 2;

Item.BIND_MASK_LAYER_PATH 		= "\\image\\effect\\other\\bind.spr";

-- 快捷栏数据存储需要用的常量
Item.TSKGID_SHORTCUTBAR			= 3;	-- 快捷栏任务变量组号
Item.TSKID_SHORTCUTBAR_FLAG		= 21;	-- 类型标志任务变量号
Item.SHORTCUTBAR_OBJ_MAX_SIZE	= 10;	-- 快捷栏Obj最大个数

--ADD BY:LQY 2012/8/8
Item.TSKGID_SHORTCUTBAR_CARRIER		=	2201;	-- 载具快捷键任务变量组号
Item.TSKID_SHORTCUTBAR_FLAG_CARRIER	=	21;		-- 载具类型标志任务变量号

Item.TSKGID_LEFTRIGHT_CARRIER		=	2202;	-- 玩家拥有载具技能变量组号
Item.TSKID_LEFT_FLAG_CARRIER		=	1;		-- 玩家拥有载具技能左键任务变量号
Item.TSKID_RIGHT_FLAG_CARRIER		=	2;		-- 玩家拥有载具技能右键任务变量号
Item.SHORTCUTBAR_TYPE_NONE		= 0;		-- 快捷Obj类型：无
Item.SHORTCUTBAR_TYPE_ITEM		= 1;		-- 快捷Obj类型：道具
Item.SHORTCUTBAR_TYPE_SKILL		= 2;		-- 快捷Obj类型：技能

Item.PEEL_RESTORE_RATE_12 =  3 / 100;
Item.PEEL_RESTORE_RATE_14 =  5 / 100;
Item.ENHANCE_COST_RATE = 10 / 100

Item.szResPart = 
{
	[0] = "Nón", 
	[1] = "Áo", 
	[2] = "Vũ khí", 
	[3] = "Ngựa", 
	[4] = "Choàng"
};

-- 客户端未知道具的GDPL
Item.nGenre = 18;
Item.nDetail = 1;
Item.nParticular = 799;
Item.nLevel = 1;
Item.nSeries = -1;

Item.tbEnhanceFightPower = 
{
	[0]		= 0;
	[1]		= 0;
	[2]		= 0;
	[3]		= 0;
	[4]		= 0;
	[5]		= 0;
	[6]		= 0;
	[7]		= 0;
	[8]		= 0.5;
	[9]		= 0.5;
	[10]	= 0.5;
	[11]	= 0.5;
	[12]	= 1;
	[13]	= 1;
	[14]	= 3;
	[15]	= 5;
	[16]	= 8;
};


Item.tbEnhanceOfEquipPos = 
{
	[0]		= 1;
	[1]		= 1;
	[2]		= 1;
	[3]		= 3;
	[4]		= 1;
	[5]		= 1;
	[6]		= 1.5;
	[7]		= 1.5;
	[8]		= 1.5;
	[9]		= 1.5;
};

Item.tbRefineFightPower =
{
	[-1] = 0;
	[0] = 0;
	[1] = 1;
	[2] = 2;
};

-- 新五行印的g,d,p,l和五行
Item.tbNewSignetGDPLS = 
{
	1,16,13,2,0
}

-- 赤夜天翔的GDPL
Item.tbNewHorseGDPL = 
{
	1,12,61,4
}

Item.DELAY_BIND			= 1;
Item.DELAY_UNBIND		= 2;
Item.DELAY_CACEL_UNBIND = 3;
Item.tbSpecFile 		= "\\setting\\item\\001\\other\\specialbinditem.txt"
Item.tbTransferEquip    = {};	--强化转移的info，用于tip显示
Item.nEnhTimesLimitOpen = 16;	--强化开关限制的强化数


-- 装备打孔/宝石镶嵌/宝石剥离
Item.ROOM_HOLE_EQUIP_WIDTH	= 1;
Item.ROOM_HOLE_EQUIP_HEIGHT	= 1;
Item.ROOM_HOLE_STONE_WIDTH	= 3;							-- 装备打孔可以放的宝石宽度
Item.ROOM_HOLE_STONE_HEIGHT	= 1;							-- 装备打孔可以放的宝石高度

-- 装备打孔操作界面
Item.HOLE_MODE_NONE			= 0;		-- 无操作/取消操作
Item.HOLE_MODE_MAKEHOLE		= 1;		-- 打孔，冶炼大师
Item.HOLE_MODE_MAKEHOLEEX	= 2;		-- 打孔，高级打孔
Item.HOLE_MODE_ENCHASE		= 3;		-- 宝石镶嵌
Item.HOLE_MODE_STONE_UPGRADE= 4;		-- 对孔内的宝石升级


Item.nEquipHoleMinLevel		= 8;	-- 最小可以打孔的装备等级
Item.nEquipHoleMinQuality	= 3;	-- 最小可以打孔的装备质量等级，优秀/精良/稀有
Item.nNormalHole			= 0;	-- 普通孔的标识值
Item.nSpecialHole			= 1;	-- 特殊孔的标识值
Item.nCanMakeSupuerHoleLevel= 10;	-- 最小可以打高级孔的装备
Item.tbMakeHoleMoney 		= {		-- 打孔费用
	[3] =  {200000,300000, 400000},					-- 蓝
	[4] =  {200000,300000, 400000},					-- 紫
	[5] =  {200000,300000, 400000},					-- 橙
	[6] =  {300000,450000, 600000},					-- 白银
	[7] =  {400000,600000, 800000},					-- 黄金
	[8] =  {500000,750000,1000000},					-- 传说
	[10] = {200000,300000, 400000},					-- 青铜
};
Item.nMaxHoleCount			= 3;	-- 一个装备最大的打孔数量

Item.tbEquipHoleCount = {		-- 装备等级对应的打孔数量
	[8] = 1,
	[9] = 2,
	[10] = 3,
};
Item.tbEquipHoleLevel = {		-- 装备类别（蓝、紫、橙、白银、黄金、传说）对应的孔最高等级
	[3] = 3,					-- 蓝
	[4] = 4,					-- 紫
	[5] = 5,					-- 橙
	[6] = 6,					-- 白银
	[7] = 7,					-- 黄金
	[8] = 8,					-- 传说
	[10] = 3,					-- 青铜
};
Item.tbMakeHolePaper = {18, 1, 1311, 1};			-- 金刚钻的gdpl

Item.tbCastLevelToQuality = {
	[1]		= 6,				-- 白银品质	
	[2]		= 7,				-- 黄金品质
}

-- 装备打第三个孔需要的家族技能等级及功勋消耗
Item.EQUIPPOS_MAKEHOLE_KIN_SKILLLEVEL =
{
	[Item.EQUIPPOS_HEAD]		= {{1,1,1}, 350},
	[Item.EQUIPPOS_BODY]		= {{1,1,2}, 350},
	[Item.EQUIPPOS_BELT]		= {{1,1,3}, 350},
	[Item.EQUIPPOS_WEAPON]		= {{1,3,1}, 350},
	[Item.EQUIPPOS_FOOT]		= {{1,1,5}, 350},
	[Item.EQUIPPOS_CUFF]		= {{1,1,4}, 350},
	[Item.EQUIPPOS_AMULET]		= {{1,2,4}, 350},
	[Item.EQUIPPOS_RING]		= {{1,2,2}, 350},
	[Item.EQUIPPOS_NECKLACE]	= {{1,2,1}, 350},
	[Item.EQUIPPOS_PENDANT]		= {{1,2,3}, 350},
};

Item.EQUIP_TO_CURRENCY_RATE	= 50;					-- 龙魂装备兑换成龙纹银币的万分比
