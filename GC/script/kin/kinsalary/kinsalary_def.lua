-------------------------------------------------------
-- 文件名　：kinsalary_def.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2012-07-02 11:31:58
-- 文件描述：
-------------------------------------------------------

-- 系统开关
Kinsalary.IS_OPEN					= 1;

-- 任务变量
Kinsalary.TASK_GID 					= 2196;					-- 任务变量组
Kinsalary.TASK_VIPPLAYER			= 1;					-- VIP充值特权
Kinsalary.TASK_GETAWARD				= 2;					-- 是否领取奖励
Kinsalary.TASK_JINDING				= 3;					-- 家族金锭
Kinsalary.TASK_YINDING				= 4;					-- 家族银锭

-- 消息类型
Kinsalary.MSG_TOP					= 1;					-- 全服公告
Kinsalary.MSG_MIDDLE				= 2;					-- 中央红字
Kinsalary.MSG_BOTTOM				= 3;					-- 底部黑条
Kinsalary.MSG_CHANNEL				= 4;					-- 频道提示
Kinsalary.MSG_GLOBAL				= 5;					-- 全服提示

-- 活动类型
Kinsalary.EVENT_XIAOYAO				= 1;					--逍遥谷
Kinsalary.EVENT_JUNYING				= 2;                    --军营副本
Kinsalary.EVENT_BAOTU				= 3;                    --藏宝图
Kinsalary.EVENT_JINGJI				= 4;                    --趣味竞技
Kinsalary.EVENT_DADAO				= 5;                    --官府通缉
Kinsalary.EVENT_YIJUN				= 6;                    --义军任务
Kinsalary.EVENT_GUANQIA				= 7;                    --家族关卡
Kinsalary.EVENT_ZHONGZHI			= 8;                    --家族种植
Kinsalary.EVENT_CHAQI				= 9;                    --家族插旗

-- 常量定义
Kinsalary.WEEKTASK_MULTI			= 2;					-- 周目标倍数
Kinsalary.WEEKTASK_RANGE			= 4;					-- 周目标范围
Kinsalary.TIME_GETSALARY			= 1900;					-- 领取时间
Kinsalary.MIN_LEVEL					= 30;					-- 角色等级
Kinsalary.MIN_SALARY				= 2000;					-- 最低工资
Kinsalary.MAX_NUMBER				= 2000000000;			-- 一个大数
Kinsalary.MAX_BIND_VALUE			= 200000;				-- 绑定价值
Kinsalary.MAX_NOBIND_VALUE			= 40000;				-- 不绑定价值

-- 道具ID
Kinsalary.ITEM_YUANBAO				= {18, 1, 1760, 1};		-- 元宝
Kinsalary.ITEM_YINDING				= {18, 1, 1761, 1};		-- 金锭
Kinsalary.ITEM_JINDING				= {18, 1, 1762, 1};		-- 银锭

-- 族长奖励
Kinsalary.CAPTAIN_AWARD =
{
	[0] = 2,
	[1] = 4,
	[2] = 5,
	[3] = 6,
};

-- 成员奖励
Kinsalary.MEMBER_AWARD =
{
	[0] = 1,
	[1] = 1.1,
	[2] = 1.2,
	[3] = 1.3,
};

-- 工资等级
Kinsalary.SALARY_LEVEL =
{
	[1] = 300000,
	[2] = 400000,
	[3] = 500000,
};

-- 商店类型
Kinsalary.SHOP_TYPE =
{
	[240] = 1,
	[241] = 1, 
};

-- 活动类型
Kinsalary.EVENT_TYPE =
{
	[1] = {szKey = "SalaryXiaoyao", szTimes = "TimesXiaoyao", szName = "逍遥谷", nRate = 30, nMaxTimes = 70},
	[2] = {szKey = "SalaryJunying", szTimes = "TimesJunying", szName = "军营副本", nRate = 150, nMaxTimes = 14},
	[3] = {szKey = "SalaryBaotu", szTimes = "TimesBaotu", szName = "藏宝图", nRate = 210, nMaxTimes = 10},
	[4] = {szKey = "SalaryJingji", szTimes = "TimesJingji", szName = "趣味竞技", nRate = 420, nMaxTimes = 5},
	[5] = {szKey = "SalaryDadao", szTimes = "TimesDadao", szName = "官府通缉", nRate = 30, nMaxTimes = 40},
	[6] = {szKey = "SalaryYijun", szTimes = "TimesYijun", szName = "义军任务", nRate = 15, nMaxTimes = 80},
	[7] = {szKey = "SalaryGuanqia", szTimes = "TimesGuanqia", szName = "家族关卡", nRate = 600, nMaxTimes = 2},
	[8] = {szKey = "SalaryZhongzhi", szTimes = "TimesZhongzhi", szName = "家族种植", nRate = 60, nMaxTimes = 20},
	[9] = {szKey = "SalaryChaqi", szTimes = "TimesChaqi", szName = "家族插旗", nRate = 15, nMaxTimes = 80},	
};

-- 系统开关
function Kinsalary:CheckIsOpen()
	return self.IS_OPEN;
end

-- 获取开服天数
function Kinsalary:GetOpenDay()
	return math.floor((GetTime() - KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME)) / (60 * 60 * 24));
end

-- 计算工资等级
function Kinsalary:GetKinSalaryLevel(nSalary)
	local nLevel = 0;
	for i, nValue in ipairs(self.SALARY_LEVEL) do
		if nSalary >= math.floor(nValue * Lib:_GetXuanEnlarge(self:GetOpenDay())) then
			nLevel = nLevel + 1;
		end
	end
	return nLevel;
end

-- 更新成员数据
function Kinsalary:UpdateKinMemberWeeklyTask(pKin)
	local itor = pKin.GetMemberItor();
	local pMember = itor.GetCurMember();
	while pMember do
		local nCurWeek = pMember.GetSalaryCurWeek();
		if MODULE_GC_SERVER then
			if nCurWeek > 0 then
				StatLog:WriteStatLog("stat_info", "family_salary", "acitive_get_new", pMember.GetPlayerId(),
					pMember["Get"..self.EVENT_TYPE[1].szKey](),
					pMember["Get"..self.EVENT_TYPE[1].szTimes](),
					pMember["Get"..self.EVENT_TYPE[2].szKey](),
					pMember["Get"..self.EVENT_TYPE[2].szTimes](),
					pMember["Get"..self.EVENT_TYPE[3].szKey](),
					pMember["Get"..self.EVENT_TYPE[3].szTimes](),
					pMember["Get"..self.EVENT_TYPE[4].szKey](),
					pMember["Get"..self.EVENT_TYPE[4].szTimes](),
					pMember["Get"..self.EVENT_TYPE[5].szKey](),
					pMember["Get"..self.EVENT_TYPE[5].szTimes](),
					pMember["Get"..self.EVENT_TYPE[6].szKey](),
					pMember["Get"..self.EVENT_TYPE[6].szTimes](),
					pMember["Get"..self.EVENT_TYPE[7].szKey](),
					pMember["Get"..self.EVENT_TYPE[7].szTimes](),
					pMember["Get"..self.EVENT_TYPE[8].szKey](),
					pMember["Get"..self.EVENT_TYPE[8].szTimes](),
					pMember["Get"..self.EVENT_TYPE[9].szKey](),
					pMember["Get"..self.EVENT_TYPE[9].szTimes]()
				);
			end
		end
		pMember.SetSalaryLastWeek(nCurWeek);
		pMember.SetSalaryCurWeek(0);
		for i, tbInfo in ipairs(self.EVENT_TYPE) do		
			pMember["Set"..tbInfo.szKey](0);
			pMember["Set"..tbInfo.szTimes](0);
		end
		pMember = itor.NextMember();
	end
end
