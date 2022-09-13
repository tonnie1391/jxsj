-------------------------------------------------------------------
--File: tongdef.lua
--Author: lbh
--Date: 2007-9-6 16:38
--Describe: 帮会定义
-------------------------------------------------------------------
if not Tong then --调试需要
	Tong = {}
	print(GetLocalDate("%Y\\%m\\%d  %H:%M:%S").." build ok ..")
end

--返回位或的值，参数代表位的位置，位不重复
local function BitCombine(...)
	local nRet = 0
	for i,v in ipairs(arg) do
		nRet = nRet + math.pow(2, v - 1)
	end
	return nRet
end
local preEnv = _G	--保存旧的环境
setfenv(1, Tong)	--设置当前环境为Tong

CREATE_TONG_MONEY = 1000000	--创建所需金钱

TEST_PASS_BUILD_FUND = 5000000 --通过考验期所需建设基金

CHANGE_CAMP 			= 200000 		-- 修改阵营需要的花费的建设资金
CHANGE_CAMP_TIME		= 2 * 3600		-- 修改阵营的时间间隔
INHERIT_MASTER 			= 50			-- 移交帮主所需要的个人江湖威望
BUILD_TO_REPUTE 		= 10000 		-- 建设资金与江湖威望交换比 暂定 10000：1（不足的舍去）
DISPENSE_FUND_APPLY		= 1000000		-- 发放资金需要申请的界限 100W
DISPENSE_FUND_RECORD	= 10000			-- 人均发放资金记录起始量
TAKEFUND_APPLY 			= 1000000		-- 取资金需要申请的界限 100W
STORAGE_FUND_TO_KIN_APPLY = 1000000		-- 转存家族申请的界限100w
DISPENSE_OFFER_APPLY	= 1000			-- 发放贡献度需要申请的界限 1000点
DISPENSE_TIME 			= 6 * 3600 		-- 两次分发资金的时间间隔要求6小时
DISPENSE_AGREE_COUNT	= 1				-- 申请发放需要达到同意的个数 1个
DISPENSE_APPLY_LAST		= 10 * 60 * 18	-- 发放的申请延时 10分钟
TAKEFUND_TIME			= 6 * 3600		-- 两次取资金的时间间隔要求6小时
STORAGEFUND_TO_KIN_TIME	= 6 * 3600		-- 两次转存帮会资金到家族的时间
TAKEFUND_APPLY_LAST		= 10 * 60 * 18	-- 申请取钱的延时	10分钟
TAKEFUND_AGREE_COUNT	= 1				-- 申请取出资金需要达到的同意个数 1个
FIREKIN_APPLY_LAST		= 10 * 60 * 18	-- 申请开除家族的延时 10分钟
KICK_KIN_AGREE_COUNT	= 2				-- 开除家族需要达到的同意个数
TONG_TEST_TIME			= 14 * 24 * 3600	-- 帮会考验期
DEFAULT_STOCKPRICE		= 100			-- 默认股价
DIRECTORATE_MEMBERS		= 10			-- 董事会成员数
MIN_BUILDFUND			= 1000000		-- 帮会建设资金最低值 （小于100W则不能分红）
MIN_CAN_COST			= 10000			-- 最低能花的额度
QUIT_REDUCE_STOCK		= 1			-- 离开帮会 撤资损失
JOIN_TONG_STOCK			= 0.8			-- 加入帮会 资金转股份比例
CHANGE_TAKESTOCK_ENERGY = 100			-- 设置分红比例消耗的行动力
MAX_ENERGY				= 2400			-- 行动力最大值
SPILT_STOCK_MIN_PRICE	= 1000			-- 股份拆分的最小股价 1000

ANNOUNCE_MAX_LEN 		= 1000			-- 公告最大字节长度

TONG_TASK_GROUP			= 2081			-- 帮会用任务变量组
TONG_TAKE_STOCK_WEEKS	= 1				-- 领取分红的周数

PRESDIENT_CONFIRM_WDATA	= 1				-- 首领评选以及官衔维护的周数
TONG_LEVE_UNION_LAST	= 86400			-- 离开联盟后再能加入的时间间隔
MAX_KIN_NUM 			= 5 			--最大家族数
MAX_STORED_OFFER		= 2000000000  	-- 储备贡献上限 20E
MAX_BUILD_FUND			= 4000000000	-- 建设资金上限 40E
MAX_TONG_FUND			= 4000000000	-- 帮会资金40E

SMCT_UI_TONG_REQUEST_LIST  = 27			-- 见gamedatadef.h,SYS_MESSAGE_CONFIRM_TYPE
-------------------------------------------------------------------
--长老职位的编号从0开始，职位相关的任务变量ID从100开始
--编号为0的长老为默认长老，可有多个，不分配权限，编号从1开始的每个位置只能同时有一个长老
--编号为1的为帮主，默认分配所有权限，其他长老动态分配权限
--编号为2-7为固定长老，不可更改称号，CAPTAIN_CUSTOM_BEGIN以上的可动态更改称号
-------------------------------------------------------------------
CAPTAIN_NORMAL = 0	--普通长老，不能分配任何权限
CAPTAIN_MASTER = 1	--帮主
CAPTAIN_VICEMASTER = 2	--副帮主
CAPTAIN_ASSISTANT2 = 3	--战争长老1
CAPTAIN_ASSISTANT3 = 4	--战争长老2
CAPTAIN_ASSISTANT4 = 5	--内政长老
CAPTAIN_ASSISTANT5 = 6	--外交长老
CAPTAIN_ASSISTANT6 = 7	--执事长老
CAPTAIN_CUSTOM_BEGIN = 7 --自定义长老启始
-- 注意：以后要扩展如果长老任务变量总数超过20，就得在uiTong上做细小改动

--长老权限定义，最多32个，每个长老职位权限用一个32位整型存储，每个位代表一个权限
POW_TITLE = 1 			--变更头衔
POW_RECRUIT = 2 		--招收家族
POW_ANNOUNCE = 3 		--公告编辑
POW_CAMP = 4				--阵营
POW_WORKSHOP = 5 		--作坊
POW_ENVOY = 6				--任免掌令使
POW_WAGE = 7				--调整分红
POW_FUN = 8 				--操作帮会资金
POW_GATHER = 9			--发起聚集
POW_STOREDOFFER = 10 	--储备贡献度
POW_UNION	= 11			--帮会联盟
POW_SPLIT	= 12			--拆分帮会
POW_WAR	= 13				--宣战
POW_COMMAND	= 14		--战指挥
POW_BANTALK	= 15		--禁言
POW_ACTIVITY = 16 	--发起帮会活动

POW_MASTER = 32	-- 定义最高位为帮主权限（这个权限不能给予，部分操作只有帮主有权限）
--以下为权限的组合定义
POWCB_ALL = 0xffffffff	--所有权限(帮主)

POWCB_VICEMASTER = 0x0fffffff	--副帮主默认权限.
--战争长老默认权限
POWCB_WAR = BitCombine(POW_ANNOUNCE,POW_CAMP,POW_ENVOY,POW_FUN,POW_STOREDOFFER,POW_COMMAND,POW_BANTALK)
--内政长老默认权限
POWCB_INTERIOR = BitCombine(POW_ANNOUNCE,POW_TITLE,POW_RECRUIT,POW_WORKSHOP,POW_ENVOY,POW_WAGE,POW_SPLIT,POW_BANTALK)
--外交长老默认权限
POWCB_DIPLOMAT = BitCombine(POW_ANNOUNCE,POW_TITLE,POW_CAMP,POW_ENVOY,POW_UNION,POW_WAR,POW_BANTALK)
--执事长老默认权限
POWCB_SECRETARY = BitCombine(POW_ANNOUNCE,POW_TITLE,POW_ENVOY,POW_GATHER,POW_FUN,POW_STOREDOFFER,POW_BANTALK,POW_ACTIVITY)
--自定义长老默认权限
POWCB_CUSTOM = BitCombine(POW_ANNOUNCE,POW_TITLE,POW_ENVOY,POW_BANTALK)

--阵营ID定义
CAMP_JUSTICE 	= 1		-- 宋阵营
CAMP_EVIL		= 2		-- 金阵营
CAMP_NEUTRALITY	= 3		-- 中立阵营

-- 帮会股权职位
NONE_STOCK_RIGHT	= 0	-- 普通股民
PRESIDENT 			= 1 -- 首领
DIRECTORATE			= 2 -- 股东会成员
PRESIDENT_CANDIDATE	= 3 -- 首领侯选人

--排序方法ID定义
SORT_POSITION	= 0		--按职位排序
SORT_REPUTE		= 1		--按威望排序
SORT_VOTED		= 2		--按票数排序
SORT_STOCK		= 3		--按股权排序
SORT_GREAT_MEMBER_VOTED = 4; --按优秀票数排序

NO_PAGE_TONG_NONE		= -1;
NO_PAGE_TONG_INFO		= 0;
NO_PAGE_TONG_NOTE		= 1;
NO_PAGE_TONG_POSITION	= 2;

TONG_NOTE_PAGE_NONE		= -1;
TONG_NOTE_PAGE_AFFICHE	= 0;
TONG_NOTE_PAGE_HISTORY	= 2;
TONG_NOTE_PAGE_EVENT	= 1;


TONG_FIGURE_MASTER 			= 1;		-- 帮主
TONG_FIGURE_CAPTAIN_END 	= 20;		-- 长老
TONG_FIGURE_ENVOY_END 		= 34;		-- 掌令使
TONG_FIGURE_EXCELLENCT		= 500;		-- 精英
TONG_FIGURE_NORMAL 			= 3000;		-- 普通帮众
TONG_FIGURE_SIGNED 			= 4000;		-- 记名帮众
TONG_FIGURE_RETIRE 			= 5000;		-- 荣誉帮众

-- 申请的类型ID
REQUEST_DISPENSE_FUND		= 1;		-- 申请发放人均100万以上的资金
REQUEST_TAKE_FUND			= 2;		-- 申请取出100万以上的帮会资金
REQUEST_DISPENSE_OFFER		= 3;		-- 申请发放人均1000点以上的储备贡献度
REQUEST_KICK_KIN			= 4;		-- 发起开除家族
REQUEST_JOIN				= 5;		-- 入帮申请
REQUEST_STORAGE_FUND_TO_KIN = 6;		-- 帮会资金转存家族(与申请帮会资金是互斥的)

tbCrowdTitle = {"Trưởng lão", "Chưởng lệnh", "Tinh anh", "Thành viên chính thức", "Thành viên ký danh"};
TITLE_MENU 		= {"  Danh hiệu nam", "  Danh hiệu nữ", " Danh hiệu ẩn sĩ", " Danh hiệu tinh anh"};

CAMP =
{
	[CAMP_JUSTICE]		= "Tống",
	[CAMP_EVIL]			= "Kim",
	[CAMP_NEUTRALITY]	= "Trung lập",
};


-- 发放资源类型ID,与程序的KE_TONG_DISPENSE_SOURCE_TYPE相对应
DISPENSE_FUND				= 1			-- 发放资金
DISPENSE_OFFER				= 2			-- 发放贡献度

--作坊定义
WS_LIANGONG = 1
WS_TIANGONG = 2
WS_BINGJIA = 3
WS_MIANJU = 4
WS_SHILIAN = 5
WS_MIJI = 6
WS_RENWU = 7
WS_LIWU = 8
WS_CIFU = 9

--发工资定义
if not WAGE_LOCKSTATE then
	WAGE_LOCKSTATE = {} --状态锁
end
WAGE_LEVEL = 90;
WAGE_HIGHFIGURE = 2;	--长老，精英等级
WAGE_LOWFIGURE 	= 1;	--正式成员
WAGE_NOFIGURE 	= 0;	--无资格

-- 周任务目标等级
TASK_LEVEL_LOW = 50;
TASK_LEVEL_MID = 80;
TASK_LEVEL_HIGH = 90;

-- 帮会官衔水平与所需领土数量对应表
OFFICIAL_LEVEL_CONDITION = {1, 3, 6, 10, 18, 42};

-- 帮会官衔最大个数
MAX_TONG_OFFICIAL_NUM = 10;

-- 帮会股份职位名称
OFFICIAL_RANK_NAME = {" Thủ lĩnh", "Chức quan cấp 1", "Chức quan cấp 2", "Chức quan cấp 3", "Chức quan cấp 4", "Chức quan cấp 5", "Chức quan cấp 6", "Chức quan cấp 7",  "Chức quan cấp 8",  "Chức quan cấp 9"  };

-- 帮会官衔等级升级费用
TONG_OFFICIAL_LEVEL_CHARGE	= {100000, 100000, 100000, 100000, 100000, 100000};

-- 官衔的Genre
OFFICIAL_TITLE_GENRE = 10;

-- 官衔的默认Detail
OFFICIAL_TITLE_DETAIL = 1;

-- 帮会官衔水平与个人官衔级别对应表
OFFICIAL_TABLE = 
{
	{3, 1, 1, 1, 0, 0, 0, 0, 0, 0},
	{4, 2, 2, 1, 1, 1, 0, 0, 0, 0},
	{5, 3, 3, 2, 2, 1, 1, 1, 1, 0},
	{6, 4, 3, 3, 2, 2, 2, 2, 2, 0},
	{7, 5, 4, 4, 3, 3, 2, 2, 2, 0},
	{8, 6, 5, 5, 4, 4, 4, 3, 3, 3},
};

GREAT_MEMBER_COUNT = 5;
GREAT_MEMBER_VOTE_START_DAY = 5;
GREAT_MEMBER_VOTE_END_DAY = 0;

TONGANNOUNCE_MAX_TIMES = 20;
TONGANNOUNCE_MIN_TIMES = 1;
TONGANNOUNCE_MAX_DISTANCE = 300;
TONGANNOUNCE_MIN_DISTANCE = 10;

TONG_DISBAND_OPEN		= 1;		-- 解散帮会开关

preEnv.setfenv(1, preEnv)	--恢复全局环境
