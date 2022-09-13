-------------------------------------------------------------------
--File: kindef.lua
--Author: lbh
--Date: 2007-7-3 16:20
--Describe: 家族定义
-------------------------------------------------------------------
local preEnv = _G	--保存旧的环境
setfenv(1, Kin)	--设置当前环境为Kin
--家族帮会名称敏感字词过滤
aKinTongNameFilter = {
	"日.-本",
	"皇.-军",
	"日.-军",
	"靖.-国",
	"神.-社",
	"日.-不.-落",
	"法.-轮",
	"中.-南.-海",
	"共.-匪",
	"金山",
	"西山居",
	"我日",
	"我操",
	"日死",
}

--称号过滤
aTitleFilter = {
	["雷军"] = 1,
	["求伯君"] = 1,
	}

CREATE_KIN_MONEY = 100000	--创建所需金钱
CHANGE_CAMP	= 100000		-- 更改阵营费用 10W

INVITE_FAVOR = 100				--邀请加入所需亲密度

ANNOUNCE_MAX_LEN = 1000		-- 公告最大字节长度
MAX_GU_YIN_BI	= 500		-- 古银币最大存储量
HOMELANDDESC_MAX_LEN = 300	-- 家园描述最大字节长度
REC_ANNOUNCE_MAX_LEN = 64	-- 招募公告长度


CHANGE_ASSISTANT_TIME 	= 600				--更换副族长间隔
QUIT_TONG_TIME 			= 7 * 24 * 3600 	-- 发起退出帮会的响应时间
GET_EXP_BEGIN_TIME 		= 19 * 60 + 30		-- 家族领取经验的开始时间（相对0点的分钟数）
GET_EXP_END_TIME 		= 23 * 60 + 30		-- 家族领取经验的结束时间
CANCEL_RETIRE_TIME		= 7 * 24 * 3600		-- 家族取消退隐的时间
CHANGE_REGULAR_TIME		= 24 * 3600		-- 玩家从记名到转正的时间
STORAGE_FUND_TIME		= 60				-- 转存帮会间隔
SEND_SALARY_TIME		= 24 * 3600		    -- 发放工资间隔
TAKE_FUND_APPLY_LAST	= 10 * 60 * 18		-- 玩家取钱申请持续时间
KIN_RECRUITMENT_PUBLISH_TIME	= 7 * 24 * 3600	-- 家族招募持续的最小时间
TAKE_FUND_TIME 			= 5 * 60		-- 玩家取钱的间隔
MEMBER_LEAVE_TIME 		= 48 * 3600
MAX_KIN_FUND 			= 2000000000			-- 家族资金20000000000E
STORAGE_FUND_TO_TONG	= 1000000				--转存帮会记事件的额度为100w
TAKE_FUND_APPLY			= 1000000				--存钱取钱记家族事件的额度
MIN_PLAYER_LEVEL		= 30;

--职位ID定义
FIGURE_CAPTAIN = 1		--族长
FIGURE_ASSISTANT = 2	--副族长
FIGURE_REGULAR = 3		--正式成员
FIGURE_SIGNED = 4			--记名成员（暂时令记名等于正式）
FIGURE_RETIRE = 5			--荣誉成员

--阵营ID定义
CAMP_JUSTICE 	= 1		-- 宋方阵营
CAMP_EVIL		= 2		-- 金方阵营
CAMP_NEUTRALITY	= 3		-- 中立阵营


--系统消息中心消息类型定义
SMCT_UI_KIN_REQUEST_LIST = 26	-- 见gamedatadef.h,SYS_MESSAGE_CONFIRM_TYPE

--定义响应事件类型
KIN_EVENT_INTRODUCE 	= 1		-- 推荐加入
KIN_EVENT_KICK 			= 2		-- 开除正式成员
KIN_EVENT_FIRE_CAPTAIN 	= 3		-- 罢免族长
KIN_EVENT_QUIT_TONG		= 4		-- 退出帮会
KIN_EVENT_TAKE_FUND		= 5		-- 取钱申请
KIN_EVENT_SALARY		= 6		-- 发工资申请
KIN_EVENT_TAKE_REPOSITORY=7		-- 取仓库道具申请
KIN_EVENT_BUYBADGE		= 8		-- 购买族徽

REQUEST_QUIT_TONG		= 1; -- 固定索引1为退出帮会的申请，防止叠加出现多个帮会申请
REQUEST_REST_BEGIN		= 100; -- 预留了唯一申请的索引，不唯一申请的索引按流水递增.

KICK_RESPOND_TIME = 5 * 60 * 18 --踢人响应的时限

CONF_VALUE2REPUTE = 100	--1江湖威望相当多少价值量

MEMBER_LIMITED = 60;	--正式记名成员上限
INDUCTEE_LIMITED = 30;	--招募榜

MEMBER_LIMITED_OLD = 40;	--帮会下家族数量超过5个，正式记名成员上限
RETIRE_LIMITED_OLD = 40;	--帮会下家族数量超过5个，荣誉成员数量	

CONF_DEC_REPUTE_QUIT = 0.8	--退出家族时剩余多少威望
CONF_DEC_REPUTE_KICK = 0.9	--被踢时...

CONF_REPUTE_DEC = 0.02 --家族威望日衰减（后剩余威望）系数

CONF_REPUTE_DEC_MAX = 200 --家族威望日衰减最大值

-- 排序方法
KIN_MEMBER_SORT_FIGURE 	= 0
KIN_MEMBER_SORT_LEVEL 	= 1
KIN_MEMBER_SORT_VOTE 	= 2
KIN_MEMBER_SORT_KINOFFER = 3		-- 按照个人家族总贡献排序
KIN_MEMBER_SORT_WEEKLYKINOFFER = 4	-- 按照个人家族周贡献排序
KIN_MEMBER_SORT_PLATFORM_MONTHSCORE = 5; -- 按家族平台活动月积分排名
KIN_MEMBER_SORT_PLATFORM_TOTALSCORE = 6; -- 按家族平台活动总积分排名
KIN_MEMBER_SORT_ATTENDANCE	= 7;	--按个人出勤次数排名
KIN_MEMBER_SORT_REPAUTHORITY = 8;	-- 按仓库权限排名
KIN_MEMBER_SORT_CURWEEK = 9;
KIN_MEMBER_SORT_LASTWEEK = 10;

--临时排序方法，不回掉gs获取数据，用打开时候同步回来的数据做
KIN_MEMBER_TEMPDATA_HONORRANK = 10000;
KIN_MEMBER_TEMPDATA_FACTION = 10001;
KIN_MEMBER_TEMPDATA_LASTONLINETIME = 10002;

-- 家族活动时间检测时间间隔
KIN_EVENT_ELAPES = 5

KIN_JOIN_RECRUITMENT_MAXTIMES = 10;

-- 如果到家族插旗预定时间的前半个小时,20分钟,10分钟提示
tbLeftTime = {30, 20, 10};

-- 家族周任务
TASK_BAIHUTANG = 1;		-- 白虎堂
TASK_BATTLE = 2;		-- 宋金战场
TASK_WANTED = 3;		-- 通缉任务
TASK_XOYOGAME = 4;		-- 逍遥谷
TASK_ARMYCAMP = 5;		-- 军营副本

-- 周任务目标等级
TASK_LEVEL_LOW = 50;
TASK_LEVEL_MID = 80;
TASK_LEVEL_HIGH = 90;

-- 家族周任务等级划分
TASK_LEVEL_KIN_SCORE = {2800, 2800, 2800, 2800, 2560,};

-- 个人周任务等级划分
TASK_LEVEL_PERSONAL_SCORE = {70, 70, 70, 70, 64,};


-- 家族徽章各等级价格
BADGE_LEVEL_PRICE = {1000000,5000000,20000000};

nBuyLimitPlayerCount2 = 30;	--2级徽章人数条件
nBuyLimitPlayerCount3 = 50;	--3级徽章人数条件

KIN_RECRUITMENT_TASK_GROUP_ID = 2100;
TSK_JOIN_RECRUITMENT_TIMES = 1;
TSK_JOIN_RECRUITMENT_DAY = 2;

KIN_RECRUITMENT_MIN_LEVEL = 10
KIN_RECRUITMENT_MAX_LEVEL = 150

GOLD_LS_SERVERDAY	= 201203;		--金牌联赛开服限制
NEW_KIN_LIMITDAY	= 20120501;	--新家族结构开服限制时间

MAX_WEEKLY_HANDLE_COUNT	= 3;	-- 家族周维护每帧维护的家族数

KIN_DISBAND_OPEN		= 0;		-- 解散家族开关
KIN_DISBAND_NOLOGIN_DAY	= 180;	-- 180天不上线解散家族

preEnv.setfenv(1, preEnv)	--恢复全局环境

Kin.RETIRE_LIMITED = EventManager.IVER_nKinRetireLimit;		--荣誉成员数量
