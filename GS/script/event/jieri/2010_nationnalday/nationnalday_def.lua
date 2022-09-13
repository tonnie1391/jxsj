--=================================================
-- 文件名　：nationnalday_def.lua
-- 创建者　：furuilei
-- 创建时间：2010-08-23 10:26:00
-- 功能描述：2010年国庆节活动
--=================================================

SpecialEvent.tbNationnalDay = SpecialEvent.tbNationnalDay or {};
local tbEvent = SpecialEvent.tbNationnalDay;

tbEvent.TIME_OPEN = 20100920;		-- 活动开始时间
tbEvent.TIME_CLOSE = 20101009;		-- 活动结束时间
tbEvent.TIME_AWARD = 20101015;		-- 兑奖时间

tbEvent.STATE_CLOSE = 1;
tbEvent.STATE_OPEN = 2;
tbEvent.STATE_AWARD = 3;

tbEvent.TSK_GROUP = 2027;
tbEvent.TSKID_FLAG_BEGIN = 169;		-- 每个bit表示一个地区的卡片是否收集到
tbEvent.TSKID_DATE = 171;			-- 开启卡片的日期
tbEvent.TSKID_COUNT_DAY = 172;		-- 当天开启卡片的数量
tbEvent.TSKID_COUNT_SUM = 173;		-- 活动期间开启的卡片总数

tbEvent.COUNT_AREA = 34;			-- 一共34个地区
tbEvent.COUNT_PERDAY = 6;			-- 每天最多6个卡片
tbEvent.COUNT_SUM = 54;				-- 活动期间一共可以开启54个卡片

tbEvent.RATE_RANDCARD = 5;			-- 开出随机卡片的几率是5%

tbEvent.NUM_SPEAREA	= 2;			-- 每天福地数量

tbEvent.JH_USECARD = 800;			-- 使用每张卡片消耗精活800

tbEvent.tbAreaInfo = tbEvent.tbAreaInfo or {};
tbEvent.tbSpeArea = tbEvent.tbSpeArea or {};

tbEvent.TBAWARD = {
	{nMin = 34,	nMax = 34,	nCount = 2,	tbGDPL = {18, 1, 1013, 1},	nBindMoney = 0},
	{nMin = 32,	nMax = 33,	nCount = 1,	tbGDPL = {18, 1, 1013, 1},	nBindMoney = 0},
	{nMin = 28,	nMax = 31,	nCount = 2,	tbGDPL = {18, 1, 1013, 2},	nBindMoney = 0},
	{nMin = 24,	nMax = 27,	nCount = 1,	tbGDPL = {18, 1, 1013, 2},	nBindMoney = 0},
	{nMin = 20,	nMax = 23,	nCount = 2,	tbGDPL = {18, 1, 1013, 3},	nBindMoney = 0},
	{nMin = 10,	nMax = 19,	nCount = 0,	tbGDPL = {},				nBindMoney = 500000},
	};
