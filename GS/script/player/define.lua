-- 门派常量定义
Player.FACTION_NONE			= 0;		-- 无门派
Player.FACTION_SHAOLIN		= Env.FACTION_ID_SHAOLIN;			-- 少林
Player.FACTION_TIANWANG		= Env.FACTION_ID_TIANWANG;			-- 天王
Player.FACTION_TANGMEN		= Env.FACTION_ID_TANGMEN;			-- 唐门
Player.FACTION_WUDU			= Env.FACTION_ID_WUDU;				-- 五毒
Player.FACTION_EMEI			= Env.FACTION_ID_EMEI;				-- 峨嵋
Player.FACTION_CUIYAN		= Env.FACTION_ID_CUIYAN;			-- 翠烟
Player.FACTION_GAIBANG		= Env.FACTION_ID_GAIBANG;			-- 丐帮
Player.FACTION_TIANREN		= Env.FACTION_ID_TIANREN;			-- 天忍
Player.FACTION_WUDANG		= Env.FACTION_ID_WUDANG;			-- 武当
Player.FACTION_KUNLUN		= Env.FACTION_ID_KUNLUN;			-- 昆仑
Player.FACTION_MINGJIAO		= Env.FACTION_ID_MINGJIAO;			-- 明教
Player.FACTION_DUANSHI		= Env.FACTION_ID_DALIDUANSHI;		-- 大理段氏
Player.FACTION_GUMU			= Env.FACTION_ID_GUMU;				-- 新门派
Player.FACTION_NUM			= Env.FACTION_NUM;					-- 门派数量

-- TODO: 刘畅，下面这些只有任务用，暂时未改
Player.ROUTE_DAOSHAOLIN 		= 1;
Player.ROUTE_GUNSHAOLIN 		= 2;

Player.ROUTE_QIANGTIANWANG 		= 1;
Player.ROUTE_CHUITIANWANG		= 2;

Player.ROUTE_FEIDAOTANGMEN 		= 1;
Player.ROUTE_XIUJIANTANGMEN		= 2;

Player.ROUTE_DAOWUDU 			= 1;
Player.ROUTE_ZHANGWUDU 			= 2;

Player.ROUTE_ZHANGEMEI 			= 1;
Player.ROUTE_FUZHUEMEI 			= 2;

Player.ROUTE_JIANCUIYAN 		= 1;
Player.ROUTE_DAOCUIYAN 			= 2;

Player.ROUTE_ZHANGGAIBANG 		= 1;
Player.ROUTE_GUNGAIBANG 		= 2;

Player.ROUTE_ZHANTIANREN 		= 1;
Player.ROUTE_MOTIANREN 			= 2;

Player.ROUTE_QIWUDANG 			= 1;
Player.ROUTE_JIANWUDANG 		= 2;

Player.ROUTE_DAOKUNLUN 			= 1;
Player.ROUTE_JIANKUNLUN			= 2;

Player.ROUTE_CHUIMINGJIAO		= 1;
Player.ROUTE_JIANMINGJIAO		= 2;

Player.ROUTE_ZHIDUANSHI			= 1;
Player.ROUTE_QIDUANSHI			= 2;

Player.ROUTE_JIANGUMU			= 1;
Player.ROUTE_ZHENGUMU			= 2;


-- 人际关系枚举include\gamecenter\playerrelation_i.h  
-- KEPLAYERRELATION_TYPE
Player.emKPLAYERRELATION_TYPE_TMPFRIEND		= 0;		-- 临时好友，单向关系，A把B加为临时好友
Player.emKPLAYERRELATION_TYPE_BLACKLIST		= 1;		-- 黑名单，单向关系，A把B加入黑名单
Player.emKPLAYERRELATION_TYPE_BIDFRIEND		= 2;		-- 普通好友, 对等双向关系，A和B互为好友
Player.emKPLAYERRELATION_TYPE_SIBLING		= 3;		-- 结拜（兄弟、姐妹），对等双向关系，A和B互为结拜（兄弟、姐妹）
Player.emKPLAYERRELATION_TYPE_ENEMEY		= 4;		-- 仇人，不对等双向关系，A曾经被B杀死
Player.emKPLAYERRELATION_TYPE_TRAINING		= 5;		-- 师徒，不对等双向关系，A是B的师父（未出师）
Player.emKPLAYERRELATION_TYPE_TRAINED		= 6;		-- 师徒，不对等双向关系，A是B的师父（已出师）
Player.emKPLAYERRELATION_TYPE_COUPLE		= 7;		-- 夫妻，不对等双向关系，A是B的丈夫
Player.emKPLAYERRELATION_TYPE_INTRODUCTION	= 8;		-- 介绍，不对等双向关系，A是B的介绍人
Player.emKPLAYERRELATION_TYPE_BUDDY			= 9;		-- 指定密友，双向对等关系，A和B互为密友同时也互为普通好友
Player.emKPLAYERRELATION_TYPE_COUNT			= 10;
Player.emKPLAYERRELATION_TYPE_GLOBALFRIEND	= 100;		-- 跨服好友，此关系只用人际面板来显示，并不使用人际关系的逻辑

Player.RELATION_NAME =			--主要用来消息提示
{
	[Player.emKPLAYERRELATION_TYPE_TMPFRIEND]		= "Bạn",
	[Player.emKPLAYERRELATION_TYPE_BLACKLIST]		= "Sổ đen",
	[Player.emKPLAYERRELATION_TYPE_BIDFRIEND]		= "Bạn",
	[Player.emKPLAYERRELATION_TYPE_SIBLING]			= "Kết bái",
	[Player.emKPLAYERRELATION_TYPE_ENEMEY]			= "Thù",
	[Player.emKPLAYERRELATION_TYPE_TRAINING]		= "Sư đồ",
	[Player.emKPLAYERRELATION_TYPE_TRAINED]			= "Sư đồ",
	[Player.emKPLAYERRELATION_TYPE_COUPLE]			= "Phu thê",
	[Player.emKPLAYERRELATION_TYPE_BUDDY]			= "Mật hữu",
};

Player.NPC		= -1;	-- Npc不分男女 - -#
Player.MALE		= 0;
Player.FEMALE	= 1;

Player.SEX =
{ 
	[Player.NPC] 	= "?",
	[Player.MALE] 	= "Nam",
	[Player.FEMALE] = "Nữ" 
};


-- 此枚举必须保证和程序中ktaskfuns.h中的枚举一致
Player.ProcessBreakEvent = 
{
	emEVENT_MOVE				= 0,	-- 移动
	emEVENT_ATTACK				= 1,	-- 主动攻击(使用部分技能)
	emEVENT_SITE				= 2,	-- 打坐
	emEVENT_RIDE				= 3,	-- 上下马
	emEVENT_USEITEM				= 4,	-- 使用道具
	emEVENT_ARRANGEITEM			= 5,	-- 移动物品栏中的道具
	emEVENT_DROPITEM			= 6,	-- 丢弃物品
	emEVENT_CHANGEEQUIP			= 7,	-- 更换装备
	emEVENT_SENDMAIL			= 8,	-- 发送电子信件
	emEVENT_TRADE				= 9,	-- 交易
	emEVENT_CHANGEFIGHTSTATE	= 10,	-- 改变战斗状态
	emEVENT_ATTACKED			= 11,	-- 被攻击
	emEVENT_DEATH				= 12,	-- 死亡
	emEVENT_LOGOUT				= 13,	-- 下线
	emEVENT_REVIVE				= 14,	-- 重生打断
	emEVENT_CLIENTCOMMAND		= 15,	-- 客户端命令，强制打断
	emEVENT_BUYITEM				= 16,	-- 买东西
	emEVENT_SELLITEM			= 17,	-- 卖东西
	EVENT_CHANGEDOING			= 18,	-- 改变行为
};

-- PK状态枚举
Player.emKPK_STATE_PRACTISE		= 0;	-- 练功
Player.emKPK_STATE_CAMP			= 1;	-- 阵营
Player.emKPK_STATE_TONG			= 2;	-- 帮会
Player.emKPK_STATE_BUTCHER		= 3;	-- 屠杀
Player.emKPK_STATE_UNION		= 4;	-- 联盟
Player.emKPK_STATE_EXTENSION	= 5;	-- 自定义模式
Player.emKPK_STATE_KIN			= 6;	-- 家族模式

-- 金钱途径枚举
Player.emKEARN_BEGIN			= 100; -- 从100开始
Player.emKEARN_HELP_QUESTION	= 101; -- 帮助系统
Player.emKEARN_EVENT			= 102; -- 活动系统
Player.emKEARN_FUDAI			= 103; -- 福袋
Player.emKEARN_FUDAI2			= 104; -- 福袋100两
Player.emKEARN_RANDOM_ITEM		= 105; -- 随机物品
Player.emKEARN_YIJUN			= 106; -- 义军
Player.emKEARN_TASK				= 107; -- 剧情任务
Player.emKEARN_FULI				= 108; -- 福利
Player.emKEARN_WAGE				= 109; -- 工资
Player.emKEARN_TONG_FUN			= 110; -- 帮会取钱
Player.emKEARN_TONG_DISPAND		= 111; -- 帮会发钱
Player.emKEARN_BAI_QIU_LIN		= 112; -- 白秋林发钱
Player.emKEARN_TMP_LOGIN		= 113; -- tmplogin
Player.emKEARN_TASK_TOKE		= 114; -- 剧情Toke
Player.emKEARN_TASK_GIVE		= 115; -- 剧情Give
Player.emKEARN_TASK_ACT			= 116; -- 剧情Act
Player.emKEARN_TASK_JITIAO		= 117; -- 金条
Player.emKEARN_COLLECT_CARD		= 118; -- 盛夏活动，收集卡活动相关
Player.emKEARN_ERROR_REAWARD	= 119; -- 时间轴错误,补偿银两
Player.emKEARN_TASK_ARMYCAMP	= 120; -- 军营任务
Player.emKEARN_EXCHANGE_BUYFAIL = 121; -- 交易所购买金币单失败，银两返还
Player.emKEARN_EXCHANGE_BIND	= 122; -- 绑银兑换
Player.emKEARN_DRAWBANK			= 123;	-- 从钱庄取出银两
Player.emKEARN_CHANGELIVE_MONEY	= 125;	-- 剑网转剑世获得银两
Player.emKEARN_BAIBAOXIANG_MONEY	= 126;	-- 百宝箱获得银两
Player.emKEARN_VIP_TRANSFER		= 128;	-- Vip转服银两
Player.emKEARN_PRESENT_ITEM		= 129;	-- 礼包道具开出
Player.emKEARN_KIN_FUND			= 130;	--家族取钱
Player.emKEARN_EUROPEAN			= 131;	--欧洲杯2012
Player.emKEARN_KIN_SALARY		= 132;	-- 家族工资

-- Pay
Player.emKPAY_BEGIN				= 100;	-- 从100开始
Player.emKPAY_HELP_QUESTION		= 101;	-- 答题
Player.emKPAY_EVENT				= 102;	-- 活动系统
Player.emKPAY_EVENT2			= 103;	-- 活动系统
Player.emKPAY_COMPOSE			= 104;	-- 银两合成不绑玄
Player.emKPAY_ENHANCE			= 105;	-- 强化
Player.emKPAY_REPAIR			= 106;	-- 修理
Player.emKPAY_REPAIR2			= 107;	-- 修理2
Player.emKPAY_JBEXCHANGE		= 108;	-- 交易所
Player.emKPAY_CREATEKIN			= 109;	-- 创建家族
Player.emKPAY_KIN_CAMP			= 110;	-- 家族更换阵营
Player.emKPAY_DALAO				= 111;	-- 大牢
Player.emKPAY_MIJI				= 112;	-- 秘籍
Player.emKPAY_DEL_BUDDY			= 113;	-- 删除密友
Player.emKPAY_DEL_TEACHER		= 114;	-- 删除师傅
Player.emKPAY_DEL_STUDENT		= 115;	-- 删除徒弟
Player.emKPAY_ANSWER			= 116;	-- 答题
Player.emKPAY_CREATETONG		= 117;	-- 建帮
Player.emKPAY_TONGFUND			= 118;	-- 帮会资金
Player.emKPAY_BUILDFUND			= 119;	-- 建设基金
Player.emKPAY_PEEL				= 120;	-- 玄晶剥离
Player.emKPAY_CAMPSEND			= 121;	-- 军营副本传送
Player.emKPAY_RESTOREBANK		= 122;	-- 银两存入钱庄
Player.emKPAY_DRAWBANK			= 123;	-- 从钱庄取出银两  furuilei 获得银两，这个途径有误
Player.emKPAY_BUILD_FLAG_TIME	= 124;	-- 修改家族插旗
Player.emKPAY_CHANGELIVE_MONEY	= 125;	-- 剑网转剑世获得银两 by zhangjinpin@kingsoft furuilei 获得银两，这个途径有误
Player.emKPAY_BAIBAOXIANG_MONEY	= 126;	-- 百宝箱获得银两 by zhangjinpin@kingsoft furuilei 获得银两，这个途径有误
Player.emKPAY_STRENGTHEN		= 127;	-- 改造
Player.emKPAY_VIP_TRANSFER		= 128;	-- Vip转服银两 by zhangjinpin@kingsoft furuilei 获得银两，这个途径有误
Player.emKPAY_REFINE			= 129;	-- 装备炼化
Player.emKPAY_COMPOSE_BIND		= 130;  -- 银两合成绑玄
Player.emKPAY_CONVERT_PARTNER	= 131;  -- 真元凝聚
Player.emKPAY_ZHENYUAN_REFINE 	= 132;  -- 真元炼化
Player.emKPAY_KIN_FUND			= 133;	-- 家族存钱
Player.emKPAY_EQUIP_RECAST		= 134;	-- 装备重铸
Player.emKPAY_ENHANCE_TRANSFER	= 135;	-- 强化转移
Player.emKPAY_MAKEHOLE			= 136;	-- 装备打孔
Player.emKPAY_BREAKUPSTONE		= 137;	-- 拆解/兑换石头
Player.emKPAY_EUROPEAN			= 138;	-- 欧洲杯2012

-- 获得物品
Player.emKADDITEM_BEGIN					= 100;			-- 从100开始
Player.emKITEMLOG_TYPE_UNENHANCE		= 101;			-- 玄晶剥离
Player.emKITEMLOG_TYPE_COMPOSE			= 102;			-- 玄晶合成
Player.emKITEMLOG_TYPE_PRODUCE			= 103;			-- 生活技能制造 
Player.emKITEMLOG_TYPE_FINISHTASK		= 104;			-- 完成任务
Player.emKITEMLOG_TYPE_STOREHOUSE		= 105;			-- 使用藏宝图
Player.emKITEMLOG_TYPE_JOINEVENT		= 106;			-- 参加活动获得
Player.emKITEMLOG_TYPE_BREAKUP			= 107;			-- 玄晶、装备拆解	
Player.emKITEMLOG_TYPE_PEEL_PARTNER		= 108;			-- 同伴剥离
Player.emKITEMLOG_TYPE_CYSTAL_COMPOSE	= 109;			-- 水晶合成
Player.emKITEMLOG_TYPE_MANTLE_SHOP		= 110;			-- 披风换魂石
Player.emKITEMLOG_TYPE_BAZHUZHIYIN_AWARD = 111;			-- 霸主之印奖励玄晶
Player.emKITEMLOG_TYPE_PEELSTONE		 = 112;			-- 宝石剥离

-- 失去物品
Player.emKLOSEITEM_USE					= 5;
Player.emKLOSEITEM_BEGIN				= 100;			-- 从100开始
Player.emKLOSEITEM_TYPE_COMPOSE			= 101;			-- 合成玄晶
Player.emKLOSEITEM_TYPE_ENHANCE			= 102;			-- 强化装备失去玄晶
Player.emKLOSEITEM_TYPE_EVENTUSED		= 103;			-- 活动关卡等需求物品扣除，领奖兑换扣除
Player.emKLOSEITEM_TYPE_TASKUSED		= 104;			-- 任务扣除
Player.emKLOSEITEM_TYPE_DESTROY			= 105;			-- 销毁
Player.emKLOSEITEM_BREAKUP				= 106;			-- 装备拆解
Player.emKLOSEITEM_CHANGE_HUN			= 107;			-- 兑换魂石
Player.emKLOSEITEM_REPAIR				= 108;			-- 修理品消耗
Player.emKLOSEITEM_SERIES_STONE			= 109;			-- 升级五行印
Player.emKLOSEITEM_KILLER				= 110;			-- 官府通缉任务兑换扣除
Player.emKLOSEITEM_JINTIAO				= 111;			-- 金条使用扣除
Player.emKLOSEITEM_MANTLE_SHOP			= 112;		-- 披风换魂石扣除
Player.emKLOSEITEM_STRENGTHEN			= 113;		-- 改造扣除玄晶
Player.emKLOSEITEM_PARTNER_TALENT		= 114;		-- 同伴领悟
Player.emKLOSEITEM_CYSTAL_COMPOSE		= 115;		-- 水晶合成
Player.emKLOSEITEM_EXCHANGE_PARTEQ 		= 116;		-- 同伴装备碎片兑换
Player.emKLOSEITEM_BAZHUZHIYIN_TAKEIN	= 117;		-- 缴纳霸主之印
Player.emKLOSEITEM_RECAST_DEL			= 118;		-- 重铸时扣除道具
Player.emKLOSEITEM_VALUE_TRANSFER_DEL	= 119;		-- 强化转移时扣除道具
Player.emKLOSEITEM_ENCHASESTONE			= 120;		-- 宝石镶嵌
Player.emKLOSEITEM_HANDIN_HOSRE_FRAG	= 121;		-- 交纳新坐骑碎片
Player.emKLOSEITEM_LONGEQUIP_EXCHANGE	= 122;		-- 龙魂装备兑换货币

-- 摆摊贩卖状态
Player.STALL_STAT_NORMAL		= 0;	-- 处于正常状态
Player.STALL_STAT_STALL_SELL	= 1;	-- 贩卖：叫卖状态
Player.STALL_STAT_STALL_BUY		= 2;	-- 贩卖：购物状态
Player.STALL_STAT_OFFER_SELL	= 3;	-- 收购：出售状态
Player.STALL_STAT_OFFER_BUY		= 4;	-- 收购：收购状态

-- 声望阵营定义
Player.CAMP_TASK				= 1;	-- 任务声望
Player.CAMP_BATTLE				= 2;	-- 宋金战场声望
Player.CAMP_FACTION				= 3; 	-- 门派声望

Player.ATTRIB_STR				= 1;
Player.ATTRIB_DEX				= 2;
Player.ATTRIB_VIT				= 3;
Player.ATTRIB_ENG				= 4;

Player.nBeProtectedStateSkillId = 786;
Player.HEAD_STATE_AUTOPATH		= 147;

-- 威望入口定义
Player.PRESTIGE_LIMIT_GROUP		= 2015;	-- 任务组ID
Player.PRESTIGE_WEEK_ID			= 1;	-- 周数

Player.PRESTIGE_LIMIT =
{
						--变量ID	周上限
	["treasuremap"] 	= {2,		40},
	["linktask"]		= {3,		10},		-- 由30修改为10点，by zhangjinpin@kingsoft
	["baihutang"]		= {4,		60},
	["battle"]			= {5,		60},
	["huihuangzhiguo"]	= {6,		20},
	["wlls"]			= {7,		200},		-- 联赛暂时把上限去掉一周最大只可能144
	["kingame"]			= {8, 		30},
	["uniqueboss"]		= {9, 		60},
	["xoyogame"]		= {10,		100},		-- 由60修改为100点，by zhangjinpin@kingsoft
	["factionbattle"]	= {11,		60},
	["tongji"]			= {12,		30},		-- 官府通缉任务，增加每周30上限，by zhangjinpin@kingsoft
	["superbattle"]		= {13,		60},		-- 跨服战场
	["newcangbaotu"]	= {1010,	40},		-- 高级藏宝图
	["kingame_quwei"]	= {1021,	40},		-- 家族趣味竞技
}


--zounan add 增加经验的几种途径
Player.EXP_TYPE = 
{

	["gouhuo"] 			= 1,    --篝火
	["jiazuchaqi"]		= 1,    --家族插旗
	["guessgame"]		= 1,	--猜灯谜
	["army"]			= 1,	--军营
	["task"]			= 1,    --任务
	["battle"]			= 1,	--宋金
	["pvp"]				= 1,    --门派竞技
--	["uniqueboss"]		= 1,
--	["xoyogame"]		= 1,
--	["factionbattle"]	= 1,
--	["tongji"]			= 1,
}


--zounan add 增加绑银的几种途径
Player.BINDMONEY_TYPE = 
{

	["army"]			= 1,	--军营
	["task"]			= 1,    --任务
--	["wlls"]			= 1,
--	["kingame"]			= 1,
--	["uniqueboss"]		= 1,
--	["xoyogame"]		= 1,
--	["factionbattle"]	= 1,
--	["tongji"]			= 1,
}



Player.ATTACT_TRAUMA	= 0;		-- 内功
Player.ATTACT_INNER		= 1;		-- 外功

--技能清除类型枚举定义
Player.emKNPCFIGHTSKILLKIND_NONE				= 0;
Player.emKNPCFIGHTSKILLKIND_NEGATIVE			= 1;		-- 负面类型
Player.emKNPCFIGHTSKILLKIND_POSITIVE			= 2;		-- 正面类型
Player.emKNPCFIGHTSKILLKIND_DOMAINENABLE		= 4;		-- 区域争夺战可用类型
Player.emKNPCFIGHTSKILLKIND_CLEARDWHENENTERBATTLE	= 8;	-- 进入某些战场需要清除的技能

-- 老玩家召回的相关变量
Player.TASK_GROUP_OLDPLAYER = 2082;
Player.TASK_ID_LEAVEKIN_TIME = 15;	-- 老玩家在召回后活动期间退出家族的时间
Player.TASK_ID_JOINKIN_TIME = 16;	-- 老玩家在召回后活动期间加入家族的时间
Player.OLDPLAYER_ACTION_TIME = 3600 * 24 * 7;	-- 老玩家的优惠活动时间（7天）

-- 跨服
Player.ACROSS_TSKGROUPID = 2104;
Player.ACROSS_TSKID = 1;
Player.ACROSS_TSKID_USE_TIME = 2;
Player.ACROSS_TSKID_TIME_OUT = 3;
Player.ACROSS_TSKID_PRICE = 4;

-- 绑银的添加途径
Player.emKBINDMONEY_ADD_BEGIN			= 100; -- 从100开始
Player.emKBINDMONEY_ADD_QUESTION		= 101; -- 帮助系统
Player.emKBINDMONEY_ADD_EVENT			= 102; -- 活动系统
Player.emKBINDMONEY_ADD_FUDAI			= 103; -- 福袋
Player.emKBINDMONEY_ADD_FUDAI2			= 104; -- 福袋100两
Player.emKBINDMONEY_ADD_RANDOMITEM		= 105; -- 随机物品
Player.emKBINDMONEY_ADD_YIJUN			= 106; -- 义军
Player.emKBINDMONEY_ADD_TASK			= 107; -- 剧情任务
Player.emKBINDMONEY_ADD_FULI			= 108; -- 福利
Player.emKBINDMONEY_ADD_WAGE			= 109; -- 工资
Player.emKBINDMONEY_ADD_TONG_FUN		= 110; -- 帮会取钱
Player.emKBINDMONEY_ADD_TONG_DISPAND	= 111; -- 帮会发钱
Player.emKBINDMONEY_ADD_BAI_QIU_LIN		= 112; -- 白秋林发钱
Player.emKBINDMONEY_ADD_TMP_LOGIN		= 113; -- tmplogin
Player.emKBINDMONEY_ADD_TASK_TOKE		= 114; -- 剧情Toke
Player.emKBINDMONEY_ADD_TASK_GIVE		= 115; -- 剧情Give
Player.emKBINDMONEY_ADD_TASK_ACT		= 116; -- 剧情Act
Player.emKBINDMONEY_ADD_JITIAO			= 117; -- 金条
Player.emKBINDMONEY_ADD_COLLECT_CARD	= 118; -- 盛夏活动，收集卡活动相关
Player.emKBINDMONEY_ADD_ERROR_REAWARD	= 119; -- 时间轴错误,补偿银两
Player.emKBINDMONEY_ADD_TASK_ARMYCAMP	= 120; -- 军营任务
Player.emKBINDMONEY_ADD_EXCHANGE_BUYFAIL = 121; -- 交易所购买金币单失败，银两返还
Player.emKBINDMONEY_ADD_VIP_TRANSFER	= 122; -- VIP转服
Player.emKBINDMONEY_ADD_HAPPYEGG		= 123; -- 开心蛋（盛夏和游龙）
Player.emKBINDMONEY_ADD_PEEL			= 124; -- 剥离装备
Player.emKBINDMONEY_ADD_CHANGELIVE		= 125; -- 剑网转剑世获得绑银
Player.emKBINDMONEY_ADD_HUNDREDKIN		= 126; -- 百大家族评选奖励
Player.emKBINDMONEY_ADD_YOULONG_ITEM	= 127; -- 游龙秘宝道具
Player.emKBINDMONEY_ADD_XISHANYIDING	= 128; -- 西山银锭
Player.emKBINDMONEY_ADD_MARRY			= 129; -- 结婚相关
Player.emKBINDMONEY_ADD_SHANGHUI		= 130; -- 商会材料兑换绑银
Player.emKBINDMONEY_ADD_PRESENTITEM		= 131; -- 礼包开绑银
Player.emKBINDMONEY_ADD_EQUIP_TRANSFER	= 132; -- 强化转移


-- 绑银的消耗途径
Player.emKBINDMONEY_COST_BEGIN			= 100; -- 从100开始
Player.emKBINDMONEY_COST_HELP_QUESTION  = 101; -- 帮助系统
Player.emKBINDMONEY_COST_EVENT			= 102; -- 活动系统
Player.emKBINDMONEY_COST_COMPOSE		= 103; -- 合成
Player.emKBINDMONEY_COST_ENHANCE		= 104; -- 强化
Player.emKBINDMONEY_COST_REFINE			= 105; -- 炼化
Player.emKBINDMONEY_COST_STRENGTHEN		= 106; -- 改造
Player.emKBINDMONEY_COST_REPAIR			= 107; -- 修理
Player.emKBINDMONEY_COST_REPAIR2		= 108; -- 修理2
Player.emKBINDMONEY_COST_EXCHANGE		= 109; -- 绑银兑换银两
Player.emKBINDMONEY_COST_GM 			= 110; -- GM扣除
Player.emKBINDMONEY_COST_TRANSFER		= 111; --强化转移扣除

-- 绑金的获取途径
Player.emKBINDCOIN_ADD_BEGIN			= 100; -- 从100开始
Player.emKBINDCOIN_ADD_HELP_QUESTION	= 101; -- 帮助系统
Player.emKBINDCOIN_ADD_EVENT			= 102; -- 活动
Player.emKBINDCOIN_ADD_TASK				= 103; -- 任务
Player.emKBINDCOIN_ADD_BAIBAOXIANG		= 104; -- 百宝箱
Player.emKBINDCOIN_ADD_FUDAI			= 105; -- 福袋
Player.emKBINDCOIN_ADD_CHANGELIFE		= 106; -- 剑网转剑世获得绑金
Player.emKBINDCOIN_ADD_CHANGESERVER_AWARD = 107; -- 移民奖励
Player.emKBINDCOIN_ADD_GUOQING_CARD		= 108; -- 国庆卡
Player.emKBINDCOIN_ADD_ERROR_REAWARD	= 109; -- 时间轴错误，补偿绑金
Player.emKBINDCOIN_ADD_CALLBACK			= 110; -- 老玩家召回活动
Player.emKBINDCOIN_ADD_XMAS_REBACK		= 111; -- 圣诞返还
Player.emKBINDCOIN_ADD_SALARY			= 112; -- 工资
Player.emKBINDCOIN_ADD_HAPPYEGG			= 113; -- 开心蛋
Player.emKBINDCOIN_ADD_RANDOM_ITEM		= 114; -- 随机物品
Player.emKBINDCOIN_ADD_XISHANJINDING	= 115; -- 西山金锭
Player.emKBINDCOIN_ADD_TONG_JINTIAO		= 116; -- 帮会金条
Player.emKBINDCOIN_ADD_RELATION			= 117; -- 好友个数奖励
Player.emKBINDCOIN_ADD_VIP_TRANSFER		= 118; -- VIP转服
Player.emKBINDCOIN_ADD_VIP_REBACK		= 119; -- VIP返还
Player.emKBINDCOIN_ADD_PRESENT_ITEM		= 120; -- 礼包开出
Player.emKBINDCOIN_ADD_LOTTERY_ITEM		= 121; -- 充值奖券开出
Player.emKBINDCOIN_ADD_PAY_RETURN		= 122; -- 充值1000以上返还
Player.emKBINDCOIN_ADD_LOTTERY_GET		= 123; -- 充值抽奖获得
Player.emKBINDCOIN_ADD_OLD_RETURN		= 124; -- 老玩家回归活动返还
Player.emKBINDCOIN_ADD_ONLINE_AWARD		= 125; -- 在线领奖

-- 绑金的消耗途径
Player.emKBINDCOIN_COST_BEGIN			= 100; -- 从100开始
Player.emKBINDCOIN_COST_CHANGESERVER	= 101; -- 移民
Player.emKBINDCOIN_COST_GM				= 102; -- GM扣除
Player.emKBINDCOIN_COST_OFFLINE			= 103; -- 离线托管自动买白驹
Player.emKBINDCOIN_COST_JBRETURN		= 104; -- 金币消耗返还
Player.emKBINDCOIN_COST_BAIJU_LOGOUT	= 105; -- 下线时绑金购买白驹丸

-- 新手玩家的指引任务
Player.TSKGROUP_NEWPLAYER_GUIDE			= 1022; -- 新手指引任务
Player.TSKID_NEWPLAYER_FACTION			= 222;	-- 新手指引，完成的门派指引情况
Player.TSKID_NEWPLAYER_FRIEND			= 223;	-- 新手指引，好友
Player.TSKID_NEWPLAYER_KIN				= 224;	-- 新手指引，家族

-- 金币冻结途径
Player.emKCOIN_FREEZE_XKLAND			= 1;	-- 侠客岛冻结金币

Player.TSK_PAYACTION_GROUP			= 2027;
Player.TSK_PAYACTION_EXT_ID			= {156, 157, 75};	--


Player.TSK_GROUP_HIDE_MANTLE 		= 2145;
Player.TSK_SUB_HIDE_MANTLE			= 1;

Player.tbViewEquipMsg =
{
	[0] = " đang nhìn bạn!",
	[1] = " tay chống cằm, nhìn chằm chằm vào trang bị của bạn!",
	[4] = " đang hiếu kỳ nhìn chằm chằm vào trang bị của bạn !",
	[7] = " nhìn chằm chằm vào trang bị của bạn, hai mắt phát sáng!",
	[9] = " nhìn thấy trang bị của bạn đẹp lung linh, thèm chảy nước dãi!",
	[10] = " nhìn bạn một cách ngưỡng mộ!",
}
Player.tbViewEquipMsg[2] = Player.tbViewEquipMsg[1];
Player.tbViewEquipMsg[3] = Player.tbViewEquipMsg[1];
Player.tbViewEquipMsg[5] = Player.tbViewEquipMsg[4];
Player.tbViewEquipMsg[6] = Player.tbViewEquipMsg[4];
Player.tbViewEquipMsg[8] = Player.tbViewEquipMsg[7];

--Player.szBeViewdEquipMsg = "对方后脑勺一凉，发现你正在偷看！";

Player.tbRouteName = 
{
	"Đao Thiếu Lâm", "Côn Thiếu Lâm",
	"Thương Thiên Vương", "Chùy Thiên Vương",
	"Hãm Tĩnh Đường Môn", "Tụ Tiễn Đường Môn",
	"Đao Ngũ Độc", "Chưởng Ngũ Độc",
	"Chưởng Nga My", "Phụ Trợ Nga My",
	"Kiếm Thúy Yên", "Đao Thúy Yên",
	"Chưởng Cái Bang", "Côn Cái Bang",
	"Chiến Nhẫn", "Ma Nhẫn",
	"Khí Võ Đang", "Kiếm Võ Đang",
	"Đao Côn Lôn", "Kiếm Côn Lôn",
	"Chùy Minh Giáo", "Kiếm Minh Giáo",
	"Chỉ Đoàn Thị", "Khí Đoàn Thị",	
	"Cổ Mộ Kiếm", "Cổ Mộ Châm",--"素心", "丽影",
}

Player.TASK_MAIN_GROUP 	= 1024;
Player.TASK_SUB_GROUP_STATE		 = 67;	-- 当前状态
Player.TASK_SUB_GROUP_RESET_DAY  = 68;	-- 上次重置的天数