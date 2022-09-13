-------------------------------------------------------------------
--File: globaltaskdef.lua
--Author: lbh
--Date: 2007-7-12 14:23
--Describe: 脚本全局任务变量定义
-------------------------------------------------------------------
--暂时去掉全局变量保护，后面恢复
local mTable = getmetatable(_G)
setmetatable(_G, {})

if (MODULE_GAMECLIENT) then	------- 客户端模拟KGblTask
	KGblTask	= {};
end

------------------------------全局GblIntBuf定义Start-----------------------------------------
GBLINTBUF_HELPNEWS			= 	1;	--帮助锦囊buf
GBLINTBUF_COMPENSATE_GM		= 	2;	--GM离线指令buf
GBLINTBUF_GIRL_VOTE			=	3;	--第一美女评选
GBLINTBUF_DOMAINSTATUARY	=	4;	--领土二期雕像buf
GBLINTBUF_GIRL_VOTE2		= 	5;	--第一美女评选决赛
GBLINTBUF_LOTTERY_200908  	=	6;  --09年8月促销抽奖活动
GBLINTBUF_IBSHOP			=   7;  -- 奇珍阁物品上下架状态
GBLINTBUF_KINGEYES_EVENT	=   8;  -- 在线运营活动存档
GBLINTBUF_WLDH_MEMBER		=	9;	--武林大会资格认定
GBLINTBUF_LOTTERY_200909	=  	10;  --09年9月促销抽奖活动
GBLINTBUF_ARREST_LIST		=  	11;  -- 批量关天牢
GBLINTBUF_BLACKLIST			= 	12;	--非法刷道具玩家及其所得道具名单
GBLINTBUF_MAIL_LIST			=  	13;  -- 批量邮件
GBLINTBUF_VIP_TRANSFER		=  	14;  -- Vip转服数据
GBLINTBUF_QUEST_PLIAYERLIST	=  	15;  -- 调查问卷名单
GBLINTBUF_MARRY				= 	16;	-- 结婚系统
GBLINTBUF_PROPOSAL			=	17;	-- 解除求婚关系
GBLINTBUF_IBSHOP_CMDBUF		=	18;	-- 奇珍阁在线修改指令buf
GBLINTBUF_MARRY_COZONE		= 	19;	-- 婚期合服备份
GBLINTBUF_GBWLLS_FINALPLAYERLIST = 20; -- 八强战队信息，包括成员名
GBLINTBUF_Tong_Vote			= 	21;	-- 帮会选举
GBLINTBUF_PRESENDCARD		= 	22; --定制礼包
GBLINTBUF_MAIL_LIST_2		=  	23;  -- 批量邮件运营平台
GBLINTBUF_GLOBALFRIEND		=	24; --跨服好友
GBLINTBUF_WORLDCUP			=	25;	-- 世界杯
-- xkland
GBLINTBUF_XK_COMPETITIVE	= 	26;	-- 竞拍数据
GBLINTBUF_XK_GROUP			= 	27;	-- 军团数据
GBLINTBUF_XK_PLAYER			= 	28;	-- 玩家数据
GBLINTBUF_XK_WAR			=	29; -- 战争数据
GBLINTBUF_XK_CASTLE			= 	30; -- 城堡数据
GBLINTBUF_XKL_GROUP			= 	31;	-- 军团数据
GBLINTBUF_XKL_CASTLE		= 	32; -- 城堡数据
-- end
GBLINTBUF_GOLDBAR_IPLIST	=	33;	-- 金牌网吧iplist
GBLINTBUF_QIXI_XIALV		= 	34;	-- 七夕侠侣幸福榜
GBLINTBUF_TASKPLATFORM		= 	35;	-- 任务发布平台撤销的任务
GBLINTBUF_GUIDLADDER		=	36; -- 道具排行榜
GBLINTBUF_MARRY_LIJIN		= 	37;	-- 结婚系统礼金记录
GBLINTBUF_QIXI_XIALV_HEFU	= 	38;	-- 七夕侠侣幸福榜 --合服
GBLINTBUF_FIGHTAFTER		= 	39; -- 战后系统
GBLINTBUF_OLDPLAYERBACK		=	40;	--老玩家回归
GBLINTBUF_XOYO_RANK			=	41;	-- 逍遥谷通关时间排名
GBLINTBUF_LAXIN2010			=	42;	-- 拉新活动卡密存储
GBLINTBUF_TAOBAOCOOPERATE	= 	43;	--淘宝合作活动
GBLINTBUF_GMCOMMAND			= 	44;	--GM指令重启执行
GBLINTBUF_GIRL_VOTE_NEW		=	45;	--巾帼英雄美女评选
GBLINTBUF_Tong_Vote201011	= 	46;	-- 帮会选举201011
-- newland
GBLINTBUF_NL_SIGNUP			= 	47;
GBLINTBUF_NL_GROUP			= 	48;
GBLINTBUF_NL_WAR			= 	49;
GBLINTBUF_NL_PLAYER			= 	50;
GBLINTBUF_NL_CASTLE			= 	51;
-- end
GBLINTBUF_KE_ADDNPC			= 	52;	--ke AddNpc指令所加的npc信息
GBLINTBUF_DRIFT_BOTTLE1		= 	53;	-- 漂流瓶
GBLINTBUF_DRIFT_BOTTLE2		= 	54;	-- 漂流瓶
GBLINTBUF_DRIFT_BOTTLE3		= 	55;	-- 漂流瓶

GBLINTBUF_SERVER_LIST		= 	56;	-- 服务器列表
GBLINTBUF_DIVORCE			=	57;	-- 解除侠侣
GBLINTBUF_QINGREN2011		=	58;	-- 2011情人节
GBLINTBUF_VIP_REBORN		=	59;	-- 新版vip转服
GBLINTBUF_OLDPLAYERBACK_2011_1		=	60;	--老玩家回归
GBLINTBUF_OLDPLAYERBACK_2011_2		=	61;	--老玩家回归
GBLINTBUF_XOYO_KIN_RANK		= 	62;	-- 逍遥谷家族积分排名	
GBLINTBUF_LAST_MONTH_XOYO_RANK		= 	63;	-- 逍遥谷个人上月排名
GBLINTBUF_Tong_Vote201105	= 	64;	-- 帮会选举201105	
GBLINTBUF_SHIWUJIANGLI		= 65;		--实物奖励
GBLINTBUF_VIP_INVITE		= 	66; -- VIP邀请玩家使用升级特权功能或者使用购买装备特权功能后的绑金返还
GBLINTBUF_LADDER_BATCH		= 67; -- 用于存储各排行榜批次标记的数据
GBLINTBUF_DUANWU2011		= 68;	--端午活动
GBLINTBUF_FAVORITE_IBSHOP_COIN	= 69;	 --金币区本服热销商品
GBLINTBUF_FAVORITE_IBSHOP_BINDCOIN = 70; --绑金区本服热销商品	

GBLINTBUF_SUPERBATTLE		=	71;	-- 跨服宋金

GBLINTBUF_LOTTERY_YEAR	= 72;	--抽奖
GBLINTBUF_LOTTERY_YEAR_COSUB	= 73;	--合服后把从服潜规则放到这儿抽奖
GBLINTBUF_ROLE_TRANSFER	= 74;		--角色转移
GBLINTBUF_LOGIN_AWARD	= 75;	--登录奖励&开服家族奖励
GBLINTBUF_STONE_REPIRE	= 76;	--宝石修复buff
GBLINTBUF_IP_STATISTICS	= 77;	-- 记录最近各IP登录的角色数量
GBLINTBUF_WEEKEND_FISH	= 78;	-- 周末钓鱼排行榜占位
GBLINTBUF_WEEKEND_FISH_EX	= 79;	-- 合服后子服周末钓鱼排行榜
GBLINTBUF_NEWGATEEVENT	= 80;	-- 新服绑定老玩家buff
GBLINTBUF_NEWGATEKINAWARD	= 81;	-- 新服家族拉人赛奖励
GBLINTBUF_DEROBOT_WG	= 82;	-- 待处理的外挂封停
GBLINTBUF_CHANGEACOUNT_FAIL = 83;	-- 角色转账号失败角色列表
GBLINTBUF_Dts_Vote		=84;	--寒武遗迹大猜想投票阶段
GBLINTBUF_Dts_Vote2		= 85;--寒武遗迹大猜想最终奖励
GBLINTBUF_KIN_PLANT	= 86;--国庆家族植树
GBLINTBUF_XOYO_KIN_RANK_EX	= 87;   --从服家族排名
GBLINTBUF_NAMESERER_MODIFY = 88;	-- globalnameserver网关名纠正列表
GBLINTBUF_KIN_PLANT_DAILY	= 89;--家族日常植树
GBLINTBUF_NL_HISTORY_EX = 90;	-- 合服后保存的是原大区服历届城主
GBLINTBUF_GIRL_VOTE3	= 91;	--第一美女评选每日数据
GBLINTBUF_KEYIMEN		= 92;	-- 克夷门战场
GBLINTBUF_ACC_LIMIT		= 93;	--限制账号存储不同步
GBLINTBUF_ACC_LIMIT2	= 94;	--限制账号存储同步
GBLINTBUF_GIRL_DAILY	= 95;	--美女认证日常活动
GBLINTBUF_LOTTERY_SCORES	= 96;	--玩家抽奖权值，每月清空一次
GBLINTBUF_EUROPEAN		= 97;	-- 欧洲杯2012
GBLINTBUF_SHENGXIA2012  = 98;  --2012盛夏
GBLINTBUF_KEYIMEN_KIN 	= 99;
GBLINTBUF_KEYIMEN_TONG 	= 100;
------------------------------全局GblIntBuf定义End-----------------------------------------


------------------------------存储并同步的全局任务变量----------------------------------
DBTASD_EVENT_SPRINGFRESTIVAL_VOWNUM = 0; --新年活动许愿树全局次数(以后不可以使用0)
DBTASK_KIN_VOTE = 1	--记录本月家族竞选启动是否已执行
DBTASK_TONG_WEEKLY = 2 --记录帮会周任务时为第几周
DBTASK_TONG_VOTE = 3 --记录本月帮会竞选启动是否已执行
DBTASK_HuangJinZhiZhong_MapId = 4

DBTASK_HELPNEWS_TITLE	= 5;	-- 帮助锦囊—最新消息—标题（对外内测临时）
DBTASK_HELPNEWS_MSG1	= 6;	-- 帮助锦囊—最新消息—内容1（对外内测临时）
DBTASK_HELPNEWS_MSG2	= 7;	-- 帮助锦囊—最新消息—内容2（对外内测临时）
DBTASK_HELPNEWS_MSG3	= 8;	-- 帮助锦囊—最新消息—内容3（对外内测临时）
DBTASK_HELPNEWS_TIME	= 9;	-- 帮助锦囊—最新消息—激活时间（对外内测临时）

DBTASK_TRADE_TAX_JOUR_NUM 	= 10		-- 交易税周流水号
DBTASK_TRADE_CUR_TAX 		= 11		-- 本周收税金额
DBTASK_TRADE_UNIT_WEL 		= 12		-- 最小单元福利金额
DBTASK_TRADE_MIN_UNIT 		= 13		-- 申请福利的最小单元数（不同福利档次的玩家占最小单元数不同）

DBTASD_EVENT_FENGCEPRICE  = 14   	---封测奖励活动的开关
DBTASD_EVENT_CHANGESERVER = 15  	---移民转服,记移出服务器.

DBTASD_SERVER_STARTTIME   = 16		--记录开服时间(格式:GetTime);
-- 提醒：改变等级上限的时候必须要及时通知程序修改离线托管模块中的等级信息表
DBTASD_SERVER_SETMAXLEVEL79   = 17		--记录开启79级时间(格式:GetTime);
DBTASD_SERVER_SETMAXLEVEL89   = 18		--记录开启89级时间(格式:GetTime);
DBTASD_SERVER_SETMAXLEVEL99   = 19		--记录开启99级时间(格式:GetTime); 
-- 提醒：改变等级上限的时候必须要及时通知程序修改离线托管模块中的等级信息表
DBTASD_SERVER_RECOMMEND_TIME   	= 20		--推荐服务器开启时间(格式：GetTime);
DBTASD_SERVER_RECOMMEND_CLOSE	= 21		--推荐服务器当天24点自动关闭标志;

DBTASK_KIN_WEEKLY = 22			-- 家族周维护

--盛夏活动（按标记可重用，现标记为0）
DBTASD_EVENT_COLLECTCARD_RANDOM = 23		--盛夏活动，随机卡奖励;
DBTASD_EVENT_COLLECTCARD_FINISH = 24		--盛夏活动，集齐所有卡片的玩家数量;
DBTASD_EVENT_COLLECTCARD_BELT01 = 25	--盛夏活动，黄金令牌随机第几人;
DBTASD_EVENT_COLLECTCARD_BELT02 = 26	--盛夏活动，白银令牌随机第几人;
DBTASD_EVENT_COLLECTCARD_BELT03 = 27	--盛夏活动，白银令牌随机第几人;
DBTASD_EVENT_COLLECTCARD_BELT_COUNT = 28	--盛夏活动，五环腰带令牌第几人领取;
DBTASD_EVENT_COLLECTCARD_RANK01	= 29;		--收集卡片排名1
DBTASD_EVENT_COLLECTCARD_RANK02	= 30;		--收集卡片排名2
DBTASD_EVENT_COLLECTCARD_RANK03	= 31;		--收集卡片排名3
DBTASD_EVENT_COLLECTCARD_RANK04	= 32;		--收集卡片排名4
DBTASD_EVENT_COLLECTCARD_RANK05	= 33;		--收集卡片排名5
DBTASD_EVENT_COLLECTCARD_RANK06	= 34;		--收集卡片排名6
DBTASD_EVENT_COLLECTCARD_RANK07	= 35;		--收集卡片排名7
DBTASD_EVENT_COLLECTCARD_RANK08	= 36;		--收集卡片排名8
DBTASD_EVENT_COLLECTCARD_RANK09	= 37;		--收集卡片排名9
DBTASD_EVENT_COLLECTCARD_RANK10	= 38;		--收集卡片排名10
DBTASD_EVENT_COLLECTCARD_RANDOM_DAY = 39	--盛夏活动，随机卡奖励,记录改天随机;
DBTASD_EVENT_COLLECTCARD_RANDOM_DAY = 40	--盛夏活动，使用标记，可清除重用，现标记为0;

--王老吉活动使用排名20名（可重用，现标记为0）
DBTASD_EVENT_SORT01 = 41		--排名
DBTASD_EVENT_SORT02 = 42		--排名
DBTASD_EVENT_SORT03 = 43		--排名
DBTASD_EVENT_SORT04 = 44		--排名
DBTASD_EVENT_SORT05 = 45		--排名
DBTASD_EVENT_SORT06 = 46		--排名
DBTASD_EVENT_SORT07 = 47		--排名
DBTASD_EVENT_SORT08 = 48		--排名
DBTASD_EVENT_SORT09 = 49		--排名
DBTASD_EVENT_SORT10 = 50		--排名
DBTASD_EVENT_SORT11 = 51		--排名
DBTASD_EVENT_SORT12 = 52		--排名
DBTASD_EVENT_SORT13 = 53		--排名
DBTASD_EVENT_SORT14 = 54		--排名
DBTASD_EVENT_SORT15 = 55		--排名
DBTASD_EVENT_SORT16 = 56		--排名
DBTASD_EVENT_SORT17 = 57		--排名
DBTASD_EVENT_SORT18 = 58		--排名
DBTASD_EVENT_SORT19 = 59		--排名
DBTASD_EVENT_SORT20 = 60		--排名
DBTASD_EVENT_SORT21 = 61		--排名
DBTASD_EVENT_KEEP01	= 62		--保留记录
DBTASD_EVENT_KEEP02	= 63		--保留记录
DBTASD_EVENT_KEEP03	= 64		--保留记录
DBTASD_EVENT_KEEP04	= 65		--保留记录
DBTASD_EVENT_KEEP05	= 66		--保留记录
DBTASD_EVENT_KEEP06	= 67		--保留记录
DBTASD_EVENT_KEEP07	= 68		--保留记录
DBTASD_EVENT_KEEP08	= 69		--保留记录
DBTASD_EVENT_KEEP09	= 70		--保留记录
DBTASD_EVENT_KEEP10	= 71		--保留记录
DBTASD_EVENT_SORT_SIGN = 72		--重用标记

DBTASD_EVENT_PRESIGE_RESULT = 73 -- 威望排序结果

DBTASD_EVENT_QQSHOW = 74 -- QQShow激活码发放状态
DBTASD_EVENT_GONGCE_YANHUA = 75 -- 公测烟花激活，记录时间Time
DBTASD_EVENT_GONGCE_RABBIT = 76 -- 公测财宝兔激活，记录时间Time
DBTASD_EVENT_GONGCE_PAYAWARD = 77 -- 公测充值送礼激活，记录时间Time
DBTASD_SERVER_SETMAXLEVEL150 = 78 --记录开启150级时间(格式:GetTime); 

--联赛使用--
DBTASD_WIIS_SESSION 	= 79	--联赛届数
DBTASD_WIIS_STATE		= 80	--联赛阶段(间歇期,比赛期);
DBTASD_WIIS_MAP_STATE 	= 81	--联赛赛场满人状态
DBTASD_WIIS_LASTSESSION = 82	--上届比赛届数，记录排名使用，防止出现排序进行中时换届


DBTASD_WIIS_RANK		= 83	--武林联赛排名标志

DBTASD_LADDER_MODIFYOLDLADDER = 84 -- 记录是否已经执行了更换新排行榜的指令 
DBTASD_EVENT_TEMP_01 = 85		--临时记录(王老吉增加周头名);

DBTASD_HONOR_LADDER_TIME	= 86	-- 上次荣誉排行的排行时间GetTime()

DBTASD_UI_FUN_SWITCH	= 87	-- 客户端功能开关

-- 领土争夺战
DBTASK_DOMAIN_BATTLE_NO	= 88	-- 领土争夺战流水编号

DBTASK_COZONE_TIME = 89		-- 合并服务器时间
DBTASK_SERVER_STARTTIME_DISTANCE = 90		-- 合并的2个服务器的开服时间差值
DBTASK_COZONE_DOMAIN_BATTLE_NO = 91		-- 合并服务器时主服的领土战号
DBTASD_WLDH_TYPE	= 92	--比赛类型
DBTASK_XOYOGAME_WEIGHT = 93				--记录逍遥谷卡片的权值(更新得分用)
DBTASK_YOULONGMIBAO_COUNT = 94			--游龙密窑服务器累加次数
DBTASK_YOULONGMIBAO_BIG_AWARD = 95		--游龙秘宝5级以上大奖累计次数


-- 非绑银兑换
DBTASK_COIN_EXCHANGE_PAYER = 100		-- 上月平均在线付费玩家
DBTASK_COIN_EXCHANGE_PAYER_RECENT = 101 -- 最近在线付费总人数
DBTASK_COIN_EXCHANGE_RECENT_MONTH = 102 -- 最后统计的月份
DBTASK_COIN_EXCHANGE_PRESTIGE = 103		-- 威望排序
DBTASK_COIN_EXCHANGE_PAYER_RECENT_DAYS = 104 -- 当前统计天数
DBTASK_OFFICIAL_MAINTAIN_NO = 105 			 -- 官衔维护流水号
DBTASK_FACTION_LIMIT				= 115;  -- 多修上限
DBTASK_BAIBAOXIANG_CAICHI	= 116;		-- 彩池银币数量

DBTASK_XOYO_FINAL_LADDER_MONTH = 117; -- 逍遥录最终排行月份
DBTASK_GREAT_MEMBER_VOTE_NO = 118		-- 帮会评优流水号
DBTASK_STATS_KEY = 119;					-- 潜在流失标准统计控制开关
DBTASK_WEIWANG_WEEK = 120;				-- 这是那个星期的威望排行
DBTASK_GIRL_VOTE_MAX = 121;				-- 美女评选报名,压力控制(最多报名玩家数)
DBTASK_BAZHUZHIYIN_MAX = 122;			-- 领取争夺战，缴纳霸主之印最多的玩家姓名和数量
DBTASK_DOMAINTASK_OPENTIME = 123;		-- 开门任务开启时间点 -- by zhangjinpin@kingsoft
DBTASK_DOMAIN_BATTLE_STEP = 124;		-- 领土战步骤: 0-未开启, 1-领土一期, 2-开门任务进行中, 3-领土二期....
DBTASK_COIN_EXCHANGE_PAYER_EXCHANGE_COUNT = 125 -- 每周服务器绑银换银两的人数；
DBTASK_COIN_EXCHANGE_PAYER_EXCHANGE_DATE = 126 -- 记录刷新人数上限的日期
DBTASK_STATS_ACTIVITY_KEY = 127			-- 角色参与活动总次数记录的开关
DBTASK_KIN_WEEKLYACTION_NO = 128		-- 家族周目标维护流水号
DBTASK_LOTTERY_DATE = 129               -- 八月促销抽奖数据处理完成时间
DBTASK_NATIONAL_DAY_CLEAR_DATE = 130	-- 09国庆清除以前雪仗数据时间

DBTASK_WLDH_PROSSESSION = 131;			-- 武林资格认定
DBTASK_NINE_LOTTERY_DATE = 132              -- 九月促销抽奖数据处理完成时间

DBTASD_EVENT_SESSION		= 133;	--比赛届数
DBTASD_EVENT_LASTSESSION	= 134;	--上届比赛届数，记录排名使用，防止出现排序进行中时换届
DBTASD_EVENT_STATE			= 135;	--比赛阶段(0,未开启, 1间歇期,2.比赛期第一阶段,3.比赛期第二阶段 4.八强赛期)
DBTASD_EVENT_MAP_STATE		= 136;	--准备场满人状态（0，未满，1已满）
DBTASD_EVENT_RANK			= 137;	--是否已排名完成标志
DBTASD_EVENT_MAX_SCORE_FOR_NEXT = 138;	--第120名
DBTASD_LOTTERY_STARTTIME = 139;	--促销抽奖开始时间和名字(例：一月份抽奖)
DBTASD_LOTTERY_ENDTIME = 140;	--促销抽奖结束时间
DBTASD_GBWLLS_STARSERVER_RANK = 141;	-- 明星服务器标记
DBTASD_GBWLLS_STARSERVER_RANK_TIME = 142; -- 标记明星服务器时间
DBTASD_GBWLLS_GUESS_MAX_TICKET = 143; -- 跨服联赛最多投票数和这个人名
DBTASD_EVENT_ZHENZAI_VOWNUM = 144; --赈灾全服次数
DBTASD_EVENT_COMCRYSTAL	= 145;	--越南合成水晶产出马的数量  --VN--
DBTASD_EVENT_CHENMISWITCH	= 146;	--防沉迷开关
DBTASD_EVENT_YOULONGGESWITCH	= 147;	--游龙阁10次次数限制开关 --VN--
DBTASK_WEIWANG_TIMES	= 148; -- 江湖威望倍率
DBTASD_QIXI_TONGXINSHU_COUNT	= 149;	-- 七夕活动同心树数量
DBTASD_EVENT_2010_NATIONNAL 	= 150;	-- 2010国庆活动
DBTASK_SONGJIN_BOUNS_MAX	= 151;	-- 每周最大宋金积分
DBTASK_SONGJIN_BOUNS_MAX_AWARDPLAYER	= 152;	-- 宋金周积分获得者名
DBTASK_SONGJIN_BOUNS_MAX_AWARDPLAYER_REFRESH_TIME	= 153;	-- 每周刷新时间
DBTASK_OPEN_COIN_TRADE	= 154; -- 开放金币交易
DBTASK_COIN_TRADE_LIMIT	= 155; -- 金币交易限额
DBTASK_LAXIN2010_OPEN	= 156; -- 拉新活动是否开启
DBTASD_EVENT_TAOBAO_LIHE		= 157;	--淘宝合作活动
DBTASD_EVENT_TAOBAOSWITCH	= 158;	--淘宝合作活动
DBTASD_WANTED_LV6_WEEKTASK_COUNT	= 159;	-- 高级官府通缉本周完成任务数
DBTASD_WANTED_LV6_LASTWEEKTASK_COUNT= 160;	-- 高级官府通缉上周完成任务数
DBTASD_WANTED_LASTWEEKTASK_TIME		= 161;	-- 官府通缉更新周时间(废弃)
DBTASD_EVENT_VN_HUANGJINBAIYIN_DAY 	= 162;	-- 越南10月黄金白银龙每天黄金龙产出
DBTASD_EVENT_VN_HUANGJINBAIYIN_ALL 	= 163;	-- 越南10月黄金白银龙总的黄金龙产出
DBTASK_GIRL_VOTE_MAX_NEW 			= 164;	-- 巾帼英雄美女评选报名,压力控制(最多报名玩家数)
DBTASK_OPEN_COIN_AUCTION			= 165;	-- 拍卖行金币寄卖
DBTASD_WANTED_LV1_WEEKTASK_COUNT	= 166;	-- 1级官府通缉本周完成任务数
DBTASD_WANTED_LV1_LASTWEEKTASK_COUNT= 167;	-- 1级官府通缉上周完成任务数
DBTASD_WANTED_LV2_WEEKTASK_COUNT	= 168;	-- 2级官府通缉本周完成任务数
DBTASD_WANTED_LV2_LASTWEEKTASK_COUNT= 169;	-- 2级官府通缉上周完成任务数
DBTASD_WANTED_LV3_WEEKTASK_COUNT	= 170;	-- 3级官府通缉本周完成任务数
DBTASD_WANTED_LV3_LASTWEEKTASK_COUNT= 171;	-- 3级官府通缉上周完成任务数
DBTASD_WANTED_LV4_WEEKTASK_COUNT	= 172;	-- 4级官府通缉本周完成任务数
DBTASD_WANTED_LV4_LASTWEEKTASK_COUNT= 173;	-- 4级官府通缉上周完成任务数
DBTASD_WANTED_LV5_WEEKTASK_COUNT	= 174;	-- 5级官府通缉本周完成任务数
DBTASD_WANTED_LV5_LASTWEEKTASK_COUNT= 175;	-- 5级官府通缉上周完成任务数
DATASK_FACTIONBATTLE_MODEL			=176;	-- 门派竞技模式
DATASK_VN_BENXIAO_LAST_DAY			= 177;	-- 越南活动最后一次随机到奔宵的时间
DATASK_VN_BENXIAO_ALL_COUNT			= 178;	-- 越南活动随到奔宵的总次数
DBTASK_VN_BENXIAO_LAST_DAY_YH		= 179;	-- 越南烟花活动最后一次随机到奔宵的时间
DBTASK_VN_BENXIAO_ALL_COUNT_YH		= 180;	-- 越南烟花活动随到奔宵的总次数
DBTASK_VN_BENXIAO_LAST_DAY_GP		= 181;	-- 越南五果盘活动最后一次随机到奔宵的时间
DBTASK_VN_BENXIAO_ALL_COUNT_GP		= 182;	-- 越南五果盘活动随到奔宵的总次数
DBTASK_SERVER_LIST_LOADBUFF			= 183;	-- 服务器列表配置读取文件还是读取数据库buff开关（1,读buff,0读文件）
DBTASK_GC_KUAFUBAIHU_SWITCH			= 184;	-- 跨服白虎开关
DBTASK_JINGHUOFULI_KE			= 185;	-- ke控制精活福利值
DBTASK_OLDPLAYERBACK_TIMES			= 186;	-- 老玩家批次重用buff
DBTASK_DAY_PARTNEREXPBOOK_COUNT	= 187;	-- 每天给同伴所使用的同伴经验书数量
DBTASK_DAY_PARTNERARRESTBOOK_COUNT	= 188;	-- 每天每角色使用镶边帛帖数量
DBTASK_VN_TASKID_PICI			= 189;	-- 越南活动（177-182）重用批次
DBTASK_XIAKEDAILY_TASK_DAY			= 190;	-- 侠客日常任务刷新的日期
DBTASK_XIAKEDAILY_TASK_ID1			= 191;	-- 第一个侠客任务任务id
DBTASK_XIAKEDAILY_TASK_ID2			= 192;	-- 第二个侠客任务任务id
DBTASK_XIAKEDAILY_TOMORROW_TASK_ID1 = 193;	-- 明日第一个侠客任务id
DBTASK_XIAKEDAILY_TOMORROW_TASK_ID2 = 194;	-- 明日第二个侠客任务id
DBTASK_XOYO_RANK_LAST_MONTH			= 195;	-- 逍遥排行版最终的月份
DBTASK_TIMEFRAME_OPEN			=	196;	--加速版时间轴开关
DBTASK_ENHANCESIXTEEN_OPEN	=	197;	--强16开关
DBTASK_IBSHOPNOLIMIT_OPEN		=	198;	--奇珍阁无时间轴开关
DBTASK_DATAOSHA_BATCH		=	199;	--大逃杀批次
DBTASK_HOMELAND_FIRST_OPEN			=	200;	-- 家园系统
DBTASK_ZHUFUSHU_DATE		=	201;	-- 祝福树日期
DBTASK_ZHUFUSHU_STEP1		=	202;	-- 祝福树步骤1
DBTASK_ZHUFUSHU_STEP2		=	203;	-- 祝福树步骤2
DBTASK_STONE_FUNCTION_OPENDAY		= 204;	-- 宝石功能开放日期
DBTASK_STONE_FUNCTION_OPENFLAG		= 205;	-- 宝石功能开放控制开关
DBTASK_STONE_MAIL_SENDFLAG			= 206;	-- 宝石系统邮件发送与否开关
DBTASK_QX_STONE_BORN 				= 207;	--是否已经产出宝石--2011七夕
DBTASK_WEEKENDFISH_WEEK				= 208;	-- 周末钓鱼随任务的周数占位
DBTASK_WEEKENDFISH_TASK_ID1			= 209;	-- 周末钓鱼活动任务id占位
DBTASK_WEEKENDFISH_TASK_ID2			= 210;	-- 周末钓鱼活动任务id占位
DBTASK_WEEKENDFISH_TASK_ID3			= 211;	-- 周末钓鱼活动任务id占位
DBTASK_KINPLANT_TASK_ID				= 212;	-- 家族植树触发系统收果子
DBTASK_DTSVOTE_TASK_ID				= 213;	-- 大逃杀生成奖励
DBTASD_NEWPLATEVENT_SESSION			= 214;	--无差别竞技
DBTASD_NEWPLATEVENT_STATE			= 215;	--无差别竞技
DBTASD_NEWPLATEVENT_MAP_STATE		= 216;	--无差别竞技
DBTASK_CROSSTIMEROOM_CLOSESTATE		= 217;	-- 时光殿开启标记
DBTASK_TREASUREMAP_OUT_HORSE		= 218;	-- 藏宝图产出白骆驼标记
DBTASK_NEWPLAYERGIFT_HONOR_DAY		= 219;	-- 新手礼包
DBTASK_NEWPLAYERGIFT_HONOR_COUNT	= 220;	-- 藏宝图产出白骆驼标记
DBTASK_OFFICIAL_MAINTAIN_NO_SUB		= 221;	-- 合服后从服领土官衔流水号
DBTASK_COZONE_SUB_ZONE_GATEWAY		= 222;	-- 保存从服gateway;
DBTASK_XMAS_SNOWMAN_PROCESS			= 223;	-- 雪城建设的进度

DBTASK_KINPLANT_TASK			= 224;	-- 家族植树随即任务
DBTASK_QINGRENJIE_POINT			= 225;	-- 多版本情人节爱情点数记录
DBTASK_XIYULONGHUN_LOTTERY			= 226;	-- 西域龙魂充值奖励

DBTASK_NEW_HORSE_OWNER			= 227;	-- 新坐骑所属者
DBTASK_STONECOMBINE_OPENFLAG	= 228;		-- 多版本宝石合成系统
DBTASK_CLOASE_TEAMLINK			= 229;		-- 关闭组队招募链接功能
DBTASK_MAIN_SET_PLAYERSPORT		= 230;	-- 标记是否设置本服的全局服数据
DBTASK_SUB_SET_PLAYERSPORT		= 231;	-- 标记是否设置从服的全局服数据

DBTASK_EUROPEEN_SESSION			= 232;	-- 欧洲杯赌球流水号
DBTASK_KINSALARY_SESSION		= 233;	-- 家族工资流水号
DBTASK_CLOSE_RELATIONGROUP		= 234;	-- 分组功能关闭

DBTASK_SHENGXIA_DAY             = 235;  -- 盛夏奥运金牌竞猜天
DBTASK_GAMESERVER_COUNT			= 236;	-- 服务器配置多少台gs，同步给gs和client
DBTASK_GLOBAL_NEWLAND_CITYER1	= 237;	-- 铁浮城主1号战区
DBTASK_GLOBAL_NEWLAND_CITYER2	= 238;	-- 铁浮城主2号战区
DBTASK_GLOBAL_NEWLAND_CITYER3	= 239;	-- 铁浮城主3号战区
DBTASK_GLOBAL_NEWLAND_CITYER4	= 240;	-- 铁浮城主4号战区
DBTASK_GLOBAL_NEWLAND_CITYER5	= 241;	-- 铁浮城主5号战区
DBTASK_GLOBAL_NEWLAND_CITYER6	= 242;	-- 铁浮城主6号战区
DBTASK_GLOBAL_NEWLAND_CITYER7	= 243;	-- 铁浮城主7号战区
DBTASK_GLOBAL_AREA_NAME			= 244;	-- 全局服战区名
DBTASK_NEWBATTLE_SESSION		= 245;	-- 新宋金流水号
DBTASK_TREASUREMAP_BILUOGU_HORSE_DAY	= 246;	-- 碧落谷马牌产出日期(天数)
DBTASK_TREASUREMAP_BILUOGU_HORSE_COUNT 	= 247;	-- 碧落谷日产出马牌数
DBTASK_TREASUREMAP_RANDSEED		= 248;	-- 副本随机种子
DBTASK_TREASUREMAP_RANDDAY		= 249;	-- 副本随机的天数
DBTASK_OPEN_GUMU_FACTION		= 250;	-- 开启古墓主修
DBTASK_OPEN_GUMU_FUXIU			= 251;	-- 开启古墓辅修
DBTASK_OPEN_GUMU_FUXIU_TASK		= 252;	-- 开启古墓辅修任务
DBTASD_SERVER_SETMAXLEVEL		= 253;

------------------------------不存储但同步的全局任务变量--------------------------------


-- 宋金战场用100~199
DBTASK_BATTLE_PLCNT_LEVEL1_SONG1	= 100;	-- 记录：人数+1	（即：1为无人、0为未开启）
DBTASK_BATTLE_PLCNT_LEVEL1_JIN1		= 101;
DBTASK_BATTLE_PLCNT_LEVEL2_SONG1	= 102;
DBTASK_BATTLE_PLCNT_LEVEL2_JIN1		= 103;
DBTASK_BATTLE_PLCNT_LEVEL3_SONG1	= 104;
DBTASK_BATTLE_PLCNT_LEVEL3_JIN1		= 105;
DBTASK_BATTLE_PLCNT_LEVEL1_SONG2	= 106;	-- 记录：人数+1	（即：1为无人、0为未开启）
DBTASK_BATTLE_PLCNT_LEVEL1_JIN2		= 107;
DBTASK_BATTLE_PLCNT_LEVEL2_SONG2	= 108;
DBTASK_BATTLE_PLCNT_LEVEL2_JIN2		= 109;
DBTASK_BATTLE_PLCNT_LEVEL3_SONG2	= 110;
DBTASK_BATTLE_PLCNT_LEVEL3_JIN2		= 111;
DBTASK_BATTLE_PLCNT_LEVEL1_SONG3	= 112;	-- 记录：人数+1	（即：1为无人、0为未开启）
DBTASK_BATTLE_PLCNT_LEVEL1_JIN3		= 113;
DBTASK_BATTLE_PLCNT_LEVEL2_SONG3	= 114;
DBTASK_BATTLE_PLCNT_LEVEL2_JIN3		= 115;

-- 武林大会 by zhangjinpin
DBTASK_WLDH_BATTLE_SONG1 	= 121;
DBTASK_WLDH_BATTLE_SONG2 	= 122;
DBTASK_WLDH_BATTLE_SONG3 	= 123;
DBTASK_WLDH_BATTLE_SONG4 	= 124;
DBTASK_WLDH_BATTLE_JIN1 	= 125;
DBTASK_WLDH_BATTLE_JIN2 	= 126;
DBTASK_WLDH_BATTLE_JIN3 	= 127;
DBTASK_WLDH_BATTLE_JIN4 	= 128;
DBTASK_WLDH_BATTLE_SONG5	= 129;
DBTASK_WLDH_BATTLE_SONG6	= 130;
DBTASK_WLDH_BATTLE_JIN5		= 131;
DBTASK_WLDH_BATTLE_JIN6		= 132;


DBTASK_XISUIDAO_PLAYER				= 200; -- 洗髓岛在线人数

--大逃杀问卷调查
DBTASK_DATAOSHA_WENJUAN_GOOD = 201;   --好
DBTASK_DATAOSHA_WENJUAN_SOSO = 202;   --一般
DBTASK_DATAOSHA_WENJUAN_BAD  = 203;   --差
DBTASK_VILLAGELIST_FLAG  = 204;   


------------------------------不同步也不存储的任务变量----------------------------------




--恢复全局变量保护
setmetatable(_G, mTable)

---- 需要同步客户端的变量（暂时只支持key为数值型） ----
GblTask.tbSyncReg	= {
	DBTASD_SERVER_STARTTIME,
	DBTASD_UI_FUN_SWITCH,
	DBTASD_WIIS_SESSION,
	DBTASK_COZONE_TIME,
	DBTASK_TRADE_TAX_JOUR_NUM,
	DBTASK_BAIBAOXIANG_CAICHI, -- by zhangjinpin@kingsoft
	DBTASK_DOMAINTASK_OPENTIME,
	DBTASK_DOMAIN_BATTLE_STEP,
	DBTASK_DOMAIN_BATTLE_NO,
	DBTASD_EVENT_PRESIGE_RESULT,
	DBTASD_EVENT_COLLECTCARD_RANDOM,
	DBTASD_EVENT_SESSION,
	DBTASD_EVENT_STATE,
	DBTASD_EVENT_2010_NATIONNAL,
	DBTASK_OPEN_COIN_TRADE,
	DBTASK_COIN_TRADE_LIMIT,
	DBTASK_OPEN_COIN_AUCTION,
	DBTASK_JINGHUOFULI_KE,
	DBTASK_ENHANCESIXTEEN_OPEN,
	DBTASK_TIMEFRAME_OPEN,
	DBTASK_STONE_FUNCTION_OPENDAY,
	DBTASK_STONE_FUNCTION_OPENFLAG,
	DBTASK_CROSSTIMEROOM_CLOSESTATE,
	DBTASK_XIAKEDAILY_TASK_DAY,
	DBTASD_NEWPLATEVENT_SESSION,
	DBTASD_NEWPLATEVENT_STATE,
	DBTASD_WIIS_SESSION,
	DBTASD_WIIS_STATE,
	DBTASK_KINPLANT_TASK,
	DBTASK_NEW_HORSE_OWNER,
	DBTASK_STONECOMBINE_OPENFLAG,
	DBTASK_CLOASE_TEAMLINK,
	DBTASK_CLOSE_RELATIONGROUP,
	DBTASK_GAMESERVER_COUNT,
	DBTASK_GLOBAL_NEWLAND_CITYER1,	-- 铁浮城主1号战区
	DBTASK_GLOBAL_NEWLAND_CITYER2,	-- 铁浮城主2号战区
	DBTASK_GLOBAL_NEWLAND_CITYER3,	-- 铁浮城主3号战区
	DBTASK_GLOBAL_NEWLAND_CITYER4,	-- 铁浮城主4号战区
	DBTASK_GLOBAL_NEWLAND_CITYER5,	-- 铁浮城主5号战区
	DBTASK_GLOBAL_NEWLAND_CITYER6,	-- 铁浮城主6号战区
	DBTASK_GLOBAL_NEWLAND_CITYER7,	-- 铁浮城主7号战区
};

