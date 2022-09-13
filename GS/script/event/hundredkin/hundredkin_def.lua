

if not SpecialEvent.HundredKin then
	SpecialEvent.HundredKin = {}
end

local HundredKin = SpecialEvent.HundredKin;

HundredKin.EVENT_TIME = 
{
	["songjin"] 		= { 20090727, 20090803 },
	["baihutang"] 		= { 20090803, 20090810 },
	["xoyogame"]		= { 20090810, 20090817 },
	["menpaijingji"]	= {	20090727, 20090817 },
	["score"]			= {	20090727, 20090817 },
}

HundredKin.EVENT_TIME2 = 
{
	["award"]			= { 20090818, 20090825 },
	["view"]			= { 20090727, 20090825 },
}
HundredKin.TASK_GROUP 			= 2039
HundredKin.TASK_SCORE_ID 		= 5;		-- 玩家自己的积分
HundredKin.TASK_AWARD_ID 		= 6;		-- 是否领奖
HundredKin.TASK_SONGJIN_NUM 	= 7;		-- 宋金次数
HundredKin.TASK_SONGJIN_DATE 	= 8;		-- 参加宋金的日期
HundredKin.TASK_XOYO_SOCRE 		= 9;		-- 逍遥获得总分


HundredKin.TAKE_AWARD_MIN_SCORE = 500	-- 最少需要累计多少分才能领取奖
HundredKin.TAKE_AWARD_MAX_COUNT = 40	-- 每个家族最多40人领取
HundredKin.TAKE_SOCRE_MAX_XOYO  = 700	-- 逍遥最高分


HundredKin.DOUBLE_DATE = {20080816, 20080816};

HundredKin.CLEAR_DATE = 20090727;	--该日期前每次启服务器都清除百大家族数据

HundredKin.KIN_AWARD = 
{
	--1名
	{
		{
			bindmoney = 10000000,
			item = {18,1,381,1, {bForceBind=1}, 3},
			repute=1000,
			leader=5000,
			freebag=3,
		}, --族长
		{
			item = {18,1,381,1, {bForceBind=1}, 3},
			repute=500,
			freebag=3,			
		} --成员
	},
	--2-10名
	{
		{
			bindmoney = 5000000,
			item = {18,1,381,1, {bForceBind=1}, 2},
			repute=600,
			leader=3000,
			freebag=2,
		},--族长
		{
			item = {18,1,381,1, {bForceBind=1}, 2},
			repute=300,
			freebag=2,			
		} --成员	
	},
	--11-30名
	{
		{
			bindmoney = 3000000,
			item = {18,1,381,1, {bForceBind=1}, 1},
			repute=400,
			leader=2000,
			freebag=1,
		}, --族长
		{
			item = {18,1,381,1, {bForceBind=1}, 1},
			repute=200,
			freebag=1,			
		} --成员	
	},
	--31-60名
	{
		{
			bindmoney = 1000000,
			item = {18,1,381,2, {bForceBind=1}, 2},
			repute=200,
			leader=1000,
			freebag=2,
		}, --族长
		{
			item = {18,1,381,2, {bForceBind=1}, 2},
			repute=100,
			freebag=2,			
		} --成员	
	},
	--61-100名
	{
		{
			bindmoney = 500000,
			item = {18,1,381,2, {bForceBind=1}, 1},
			leader=500,
			freebag=1,
		}, --族长
		{
			item = {18,1,381,2, {bForceBind=1}, 1},
			freebag=1,		
		} --成员	
	},
}
