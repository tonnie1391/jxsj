-------------------------------------------------------------------
--File: kluatong.lua
--Author: lbh
--Date: 2007-9-6 11:23
--Describe: KLuaTong扩展脚本指令
-------------------------------------------------------------------
if not _KLuaTong then --调试需要
	_KLuaTong = {}
	print(GetLocalDate("%Y\\%m\\%d  %H:%M:%S").." build ok ..")
end

local self	--作为第一个Up Value

--建立szDesc到TaskId的映射
Tong.aTongTaskDesc2Id = {}
Tong.aTongTmpTaskDesc2Id = {}
Tong.aTongBufTaskDesc2Id = {}
--用于生成帮会任务变量对应的指令
local function _GEN_TASK_FUN(szDesc, nTaskId)
	local funGet = 
		function ()
			return self.GetTask(nTaskId)
		end
	local funSet = 
		function (nValue)
			return self.SetTask(nTaskId, nValue)
		end
	local funAdd = 
		function (nValue)
			return self.AddTask(nTaskId, nValue)
		end
	rawset(_KLuaTong, "Get"..szDesc, funGet)
	rawset(_KLuaTong, "Set"..szDesc, funSet)
	rawset(_KLuaTong, "Add"..szDesc, funAdd)
	Tong.aTongTaskDesc2Id[szDesc] = nTaskId
end

--无符号整型任务变量
local function _GEN_TASK_FUN_U(szDesc, nTaskId)
	local funGet = 
		function ()
			return self.GetTaskU(nTaskId)
		end
	local funSet = 
		function (nValue)
			return self.SetTask(nTaskId, nValue)
		end
	local funAdd = 
		function (nValue)
			return self.AddTask(nTaskId, nValue)
		end
	rawset(_KLuaTong, "Get"..szDesc, funGet)
	rawset(_KLuaTong, "Set"..szDesc, funSet)
	rawset(_KLuaTong, "Add"..szDesc, funAdd)
	Tong.aTongTaskDesc2Id[szDesc] = nTaskId
end

-- 无符号整型任务变量，设置任务变量时带有负数溢出的判断
local function _GEN_TASK_FUN_CHECK_U(szDesc, nTaskId)
	local funGet = 
		function ()
			return self.GetTaskU(nTaskId)
		end
	local funSet = 
		function (nValue)
			if (nValue < 0) then
				local nOrgValue = self.GetTaskU(nTaskId);
				print(string.format("Error:_GEN_TASK_FUN_CHECK_U SetTaskValue szDesc = %s, nOrgValue = %s nSetValue = %s",
					szDesc, nOrgValue, nValue));
				nValue = 0;
			end
			return self.SetTask(nTaskId, nValue)
		end
	local funAdd = 
		function (nValue)
			local nOrgValue = self.GetTaskU(nTaskId)
			if ((nOrgValue + nValue) < 0) then
				print(string.format("Error:_GEN_TASK_FUN_CHECK_U AddTaskValue szDesc = %s, nOrgValue = %s nAddValue = %s",
					szDesc, nOrgValue, nValue));
				nValue = -nOrgValue;
			end
			return self.AddTask(nTaskId, nValue)
		end
	rawset(_KLuaTong, "Get"..szDesc, funGet)
	rawset(_KLuaTong, "Set"..szDesc, funSet)
	rawset(_KLuaTong, "Add"..szDesc, funAdd)
	Tong.aTongTaskDesc2Id[szDesc] = nTaskId
end

--单Bit指令
local function _GEN_TASK_FUN_FLAG(szDesc, nTaskId, nPos)
	local funGet = 
		function ()
			return self.GetTaskFlag(nTaskId, nPos)
		end
	local funSet = 
		function (nValue)
			return self.SetTaskFlag(nTaskId, nPos, nValue)
		end
	rawset(_KLuaTong, "Get"..szDesc, funGet)
	rawset(_KLuaTong, "Set"..szDesc, funSet)
end

local function _GEN_TMP_TASK_FUN(szDesc, nTaskId)
	local funGet = 
		function ()
			return self.GetTmpTask(nTaskId)
		end
	local funSet = 
		function (nValue)
			return self.SetTmpTask(nTaskId, nValue)
		end
	local funAdd = 
		function (nValue)
			return self.AddTmpTask(nTaskId, nValue)
		end
	rawset(_KLuaTong, "Get"..szDesc, funGet)
	rawset(_KLuaTong, "Set"..szDesc, funSet)
	rawset(_KLuaTong, "Add"..szDesc, funAdd)
	Tong.aTongTmpTaskDesc2Id[szDesc] = nTaskId
end

local function _GEN_BUF_TASK_FUN(szDesc, nTaskId)
	local funGet = 
		function ()
			return self.GetBufTask(nTaskId)
		end
	local funSet = 
		function (szValue)
			return self.SetBufTask(nTaskId, szValue)
		end
	rawset(_KLuaTong, "Get"..szDesc, funGet)
	rawset(_KLuaTong, "Set"..szDesc, funSet)
	Tong.aTongBufTaskDesc2Id[szDesc] = nTaskId
end

local function RegisterHistory(nType, szFormat, nContentNum)
	if not Tong.HistoryFormat then
		Tong.HistoryFormat = {};
	end
	Tong.HistoryFormat[nType] = {}; 		-- 后注册的会覆盖先注册的
	Tong.HistoryFormat[nType].szFormat = szFormat;
	Tong.HistoryFormat[nType].nContentNum = nContentNum;
end

local function _GEN_HISTORY_RECORD_FUN(szDesc, nType, nContentNum, szFormat)
	local funAdd = 
		function (...)
			return self.AddTongHistory(1, nType, GetTime(), unpack(arg));
		end
	RegisterHistory(nType, szFormat, nContentNum);
	rawset(_KLuaTong, "AddHistory"..szDesc, funAdd);
end

local function _GEN_AFFAIR_RECORD_FUN(szDesc, nType, nContentNum, szFormat)
	local funAdd = 
		function (...)
			return self.AddTongHistory(0, nType, GetTime(), unpack(arg));
		end
	RegisterHistory(nType, szFormat, nContentNum);
	rawset(_KLuaTong, "AddAffair"..szDesc, funAdd);
end

-- 范围函数生成
local function _GEN_TASK_RANGE_FUN(szDesc, nBeginTaskId, nEndTaskId)
	local funGet = 
		function (nIndex)
			assert(self);  		-- 不能是删……为了保证第一个参数是self
			if nBeginTaskId + nIndex - 1 > nEndTaskId then
				return;
			end
			return self.GetTask(nBeginTaskId + nIndex - 1)
		end
	local funSet = 
		function (nIndex, nValue)
			assert(self);		-- 不能是删……为了保证第一个参数是self
			if nBeginTaskId + nIndex - 1 > nEndTaskId then
				return;
			end
			return self.SetTask(nBeginTaskId + nIndex - 1, nValue)
		end
	local funAdd = 
		function (nIndex, nValue)
			assert(self);		-- 不能是删……为了保证第一个参数是self
			if nBeginTaskId + nIndex - 1 > nEndTaskId then
				return;
			end
			return self.AddTask(nBeginTaskId + nIndex - 1, nValue)
		end
	rawset(_KLuaTong, "Get"..szDesc, funGet)
	rawset(_KLuaTong, "Set"..szDesc, funSet)
	rawset(_KLuaTong, "Add"..szDesc, funAdd)
end

local function _GEN_TASK_RANGE_FUN_U(szDesc, nBeginTaskId, nEndTaskId)
	local funGet = 
		function (nIndex)
			assert(self);  		-- 不能是删……为了保证第一个参数是self
			if nBeginTaskId + nIndex - 1 > nEndTaskId then
				return;
			end
			return self.GetTaskU(nBeginTaskId + nIndex - 1)
		end
	local funSet = 
		function (nIndex, nValue)
			assert(self);		-- 不能是删……为了保证第一个参数是self
			if nBeginTaskId + nIndex - 1 > nEndTaskId then
				return;
			end
			return self.SetTask(nBeginTaskId + nIndex - 1, nValue)
		end
	local funAdd = 
		function (nIndex, nValue)
			assert(self);		-- 不能是删……为了保证第一个参数是self
			if nBeginTaskId + nIndex - 1 > nEndTaskId then
				return;
			end
			return self.AddTask(nBeginTaskId + nIndex - 1, nValue)
		end
	rawset(_KLuaTong, "Get"..szDesc, funGet)
	rawset(_KLuaTong, "Set"..szDesc, funSet)
	rawset(_KLuaTong, "Add"..szDesc, funAdd)
end



--不要改变任务变量的编号！
--_GEN_TASK_FUN("State", 1)					--帮会状态（通过单Bit指令使用）
_GEN_TASK_FUN("CreateTime", 2)				--创建时间
_GEN_TASK_FUN("Camp", 3)					--阵营
_GEN_TASK_FUN_U("Master", 4)				--帮主家族ID
_GEN_TASK_FUN("Energy", 5)					--行动力
_GEN_TASK_FUN("TotalRepute", 6)				--帮会总威望
_GEN_TASK_FUN("VoteCounter", 7)				--帮会投票流水号
_GEN_TASK_FUN("VoteStartTime", 8)			--帮会投票启始时间
_GEN_TASK_FUN_CHECK_U("MoneyFund", 9)		--资金
_GEN_TASK_FUN_CHECK_U("BuildFund", 10)		--建设资金
_GEN_TASK_FUN("StoredOffer", 11)			--储备贡献度 (已无用)
_GEN_TASK_FUN("TakeStock", 12)				--分红比例
_GEN_TASK_FUN("LastTakeStock", 13)			--上周种红比例
------- 领土争夺战相关
_GEN_TASK_FUN("Capital", 14)				-- 主城编号
_GEN_TASK_FUN("CapitalChangeCount", 15)		-- 改变主城的次数
_GEN_TASK_FUN("CozoneAttackNum", 16)		-- 合服后可宣战领土数
_GEN_TASK_FUN("DomainAwardAmount", 17)		-- 军饷的总额度
_GEN_TASK_FUN("DomainAwardNo", 18)			-- 上次设置奖励流水号
_GEN_TASK_FUN("ConzoneReputeParam", 19)		-- 合服后的额外声望奖励数
_GEN_TASK_RANGE_FUN("DomainAwardLimit", 20, 24)		-- 领土战个人奖励限制(先预留10个ID位置)
_GEN_TASK_FUN("DomainAttendNum", 30)		-- 上次领土战出席人数（积分>0的成员数）
_GEN_TASK_FUN("DomainAttendNo", 31)			-- 上次参战流水号
_GEN_TASK_FUN("DomainJunXunMedicineNum", 32)	-- 设置军需药的箱数	
_GEN_TASK_FUN("DomainJunXunNo",	33)			-- 设置军需的场次
_GEN_TASK_FUN("DomainJunXunType", 34)		-- 军需等级和类型
_GEN_TASK_FUN("DomainBaZhu", 35)			-- 帮会缴纳的霸主之印数量

------- TODO:暂时不做 领土战个人积分前10排名记录
------- 50以前保留给领土争夺战-------------------

_GEN_TASK_FUN("TongOffer", 51)			-- 帮会总贡献
_GEN_TASK_FUN("LowWeeklyTask", 52)		-- 帮会的低级目标
_GEN_TASK_FUN("MidWeeklyTask", 53)		-- 帮会的中级目标
_GEN_TASK_FUN("HighWeeklyTask", 54)		-- 帮会的高级目标

_GEN_TASK_FUN_CHECK_U("TotalStock", 55)	-- 帮会总股份数
_GEN_TASK_FUN_U("PresidentKin", 56)		-- 首领所在家族
_GEN_TASK_FUN_U("PresidentMember", 57)	-- 首领成员ID
_GEN_TASK_FUN("BuildFundLimit", 58)  	-- 建设资金上限
_GEN_TASK_FUN("CostedBFundWeek", 59)  	-- 记录累积消耗掉的建设基金的时间周（每年的第几周）
_GEN_TASK_FUN("CostedBuildFund", 61)  	-- 本周已消耗掉的建设基金
_GEN_TASK_FUN("FireMasterDate", 62)  	-- 罢免帮主的日期
_GEN_TASK_FUN("DomainColor", 63)		-- 领土颜色

_GEN_TASK_FUN("OfficialLevel", 64)		-- 帮会官衔水平
_GEN_TASK_FUN("PreOfficialLevel", 65)	-- 上周帮会官衔水平
_GEN_TASK_RANGE_FUN_U("OfficialKin", 66, 75)			-- 获得帮会官衔的玩家家族ID
_GEN_TASK_RANGE_FUN_U("OfficialMember", 76, 85)		-- 获得帮会官衔的玩家家族成员ID
-- _GEN_TASK_RANGE_FUN_U("OfficialAppointNo", 86, 95)		-- 任命官衔时的流水号 zhengyuhua: 废弃不用了，复用的时候注意，外网已经有数值
_GEN_TASK_FUN("OfficialMaxLevel", 96)		-- 帮会官衔最大水平（即帮会当前晋级到几级）
_GEN_TASK_FUN("IncreaseOfficialNo", 97)		-- 设置帮会官衔最大水平了流水号
-- 100到299禁用
_GEN_TASK_FUN("GreatBonus", 300)			-- 奖励基金
_GEN_TASK_FUN("GreatBonusPct", 301)			-- 奖励基金百分比, 不要直接调用，要经由Get、SetGreatBonusPercent调用
_GEN_TASK_FUN("WeekGreatBonus", 302)		-- 本周发放的奖励基金
--_GEN_TASK_FUN("GreatMemberVoteState", 303)		-- 奖励基金竞选状态
_GEN_TASK_RANGE_FUN_U("GreatMemberId", 304, 308)	-- 优秀成员的nMemberId
_GEN_TASK_RANGE_FUN_U("GreatKinId", 309, 313)	-- 优秀成员的nKinId
_GEN_TASK_FUN_U("BelongUnion", 314)			-- 归属联盟
_GEN_TASK_RANGE_FUN_U("PersonDomainScore", 315, 319)	-- 每人不同级别的个人领土战得分
_GEN_TASK_FUN_U("LeaveUnionTime", 320)		-- 离开联盟的时间
_GEN_TASK_FUN_U("AnnounceTimes", 321)		-- 发送公告次数

--帮会状态
_GEN_TASK_FUN_FLAG("TestState", 1, 1) --考验期
_GEN_TASK_FUN_FLAG("MasterLockState", 1, 2) --帮主冻结
_GEN_TASK_FUN_FLAG("GreatMemberVoteState", 1, 3) --奖励基金竞选状态

if not MODULE_GAMECLIENT then
	_GEN_TMP_TASK_FUN("TongDataVer", 1)			-- 当前数据版本号，用于与客户端的数据对比
	_GEN_TMP_TASK_FUN("TongFigureDataVer", 2) 	-- 当前职位信息版本
	_GEN_TMP_TASK_FUN("TongAnnounceDataVer", 3) -- 当前公告信息版本
else		-- 客户端专用
	_GEN_BUF_TASK_FUN("UnionName", 1007)		
end

_GEN_BUF_TASK_FUN("Name", 1)					-- 帮会名称
_GEN_BUF_TASK_FUN("TitleMan", 2)				-- 男称号
_GEN_BUF_TASK_FUN("TitleWoman", 3)				-- 女称号
_GEN_BUF_TASK_FUN("TitleRetire", 4)				-- 隐士称号
_GEN_BUF_TASK_FUN("TitleExcellent", 5)			-- 精英称号
_GEN_BUF_TASK_FUN("Announce", 6)				-- 帮会公告
_GEN_BUF_TASK_FUN("DomainResult", 7)			-- 领土争夺战排名情况

_GEN_HISTORY_RECORD_FUN("Establish", 	1, 8, 'Bang hội <color=purple>%s<color> chính thức thành lập, Bang chủ: <color=green>%s<color>, thành viên có gia tộc: <color=purple>%s %s %s %s %s %s<color>');
_GEN_HISTORY_RECORD_FUN("Split", 		2, 1, 'Bang <color=purple>%s<color> tách khỏi bang mình');
_GEN_HISTORY_RECORD_FUN("Compose", 		3, 1, '<color=purple>%s<color> nhập với bang mình');
_GEN_HISTORY_RECORD_FUN("KinJoin",		4, 1, 'Gia tộc <color=purple>%s<color> gia nhập bang mình');
_GEN_HISTORY_RECORD_FUN("KinLeave",		5, 1, 'Gia tộc <color=purple>%s<color> rời khỏi bang mình');
_GEN_HISTORY_RECORD_FUN("Decleared",	6, 1, 'Bang hội <color=purple>%s<color> khiêu chiến với bang mình');
_GEN_HISTORY_RECORD_FUN("DeclearTo",	7, 1, 'Bang mình tuyên chiến với bang <color=purple>%s<color>');
_GEN_HISTORY_RECORD_FUN("Occupy",		8, 1, 'Bang mình đã chiếm lĩnh <color=yellow>%s<color>');
_GEN_HISTORY_RECORD_FUN("Lost",			9, 1, 'Bang mình đã mất <color=yellow>%s<color>');
_GEN_HISTORY_RECORD_FUN("FactionElect",	15, 3, '<color=green>%s<color> trong lần %s vinh dự nhận được danh hiệu <color=gold>%s-Đại sư huynh/Đại sư tỷ<color>');
_GEN_HISTORY_RECORD_FUN("Ladder",		16, 3, '<color=green>%s<color> trong lần %s vinh dự nhận được danh hiệu <color=gold>Võ lâm liên đấu %s<color>!');

_GEN_AFFAIR_RECORD_FUN("Occupy",		8, 1, 'Bang mình đã chiếm lĩnh <color=yellow>%s<color>');
_GEN_AFFAIR_RECORD_FUN("Lost",			9, 1, 'Bang mình đã mất <color=yellow>%s<color>');
_GEN_AFFAIR_RECORD_FUN("Union", 		10,5, 'Bang mình và bang <color=purple>%s %s %s %s %s<color> liên minh');
_GEN_AFFAIR_RECORD_FUN("LeaveUnion",	11,1, 'Bang <color=purple>%s<color> rời khỏi liên minh');
_GEN_AFFAIR_RECORD_FUN("ChangeMaster",	12,2, '<color=green>%s<color> thay thế <color=green>%s<color> trở thành bang chủ bổn bang');
_GEN_AFFAIR_RECORD_FUN("SaveFund",		13,2, '<color=green>%s<color> đã nộp <color=yellow>%s<color> lượng vào ngân quỹ bang hội');
_GEN_AFFAIR_RECORD_FUN("TakeFund",		14,2, '<color=green>%s<color> đã lấy từ ngân quỹ bang hội ra <color=yellow>%s<color> lượng');
_GEN_AFFAIR_RECORD_FUN("FactionElect",	15, 3, '<color=green>%s<color> trong lần %s vinh dự nhận được danh hiệu <color=gold>%s-Đại sư huynh/Đại sư tỷ<color>');
_GEN_AFFAIR_RECORD_FUN("Ladder",		16, 3, '<color=green>%s<color> trong lần %s vinh dự nhận được danh hiệu <color=gold>Võ lâm liên đấu %s<color>!');
_GEN_AFFAIR_RECORD_FUN("GreatMember",	17, 5, '<color=green>%s %s %s %s %s<color> được chọn làm thành viên ưu tú bang hội tuần này!');
_GEN_AFFAIR_RECORD_FUN("TongAward",		18, 2, '<color=green>%s<color> đã phát quân hưởng trị giá <color=yellow>%s<color> lượng tiền quỹ xây dựng bang hội');
_GEN_AFFAIR_RECORD_FUN("DispenseFund",	19, 3, '<color=green>%s<color> đã phát <color=yellow>%s<color>(lượng/người) tiền quỹ bang hội cho <color=green>%s<color>');
_GEN_AFFAIR_RECORD_FUN("BuildFund",		20, 2, '<color=green>%s<color> dùng Thỏi bạc bang hội để tăng <color=yellow>%s<color> lượng quỹ xây dựng bang hội');
_GEN_AFFAIR_RECORD_FUN("Capital",		21, 1, 'Bổn bang thiết lập thành chính ở <color=yellow>%s<color>');
_GEN_AFFAIR_RECORD_FUN("StorageFundToKin",	22, 3, '<color=green>%s<color>向<color=green>%s<color>家族转存帮会资金<color=yellow>%s<color>两');
_GEN_AFFAIR_RECORD_FUN("GetFundFromKin",23, 2, '<color=green>%s<color>家族向帮会转存家族资金<color=yellow>%s<color>两');

--长老职位的编号从0开始，职位的称号ID从100开始
--编号为0的长老可有多个，不分配权限，编号从1开始的每个位置只能有一个，可分配权限
function _KLuaTong.GetCaptainTitle(nFigure)
	return self.GetBufTask(100 + nFigure)
end

function _KLuaTong.SetCaptainTitle(nFigure, szTitle)
	return self.SetBufTask(100 + nFigure, szTitle)
end


if MODULE_GAMECLIENT then
	-- 获取自身权限(限于客户端调用)
	function _KLuaTong.GetSelfPower(nPow)
		return self.GetTaskFlag(100, nPow);
	end
	_GEN_TASK_FUN("SelfRepute", 1004)		-- 自身江湖威望
end

--长老的权限，权限ID也从100开始，与职位ID保持同步，权限编号看tongdef.lua长老权限定义
--nFigure为0（普通长老），不能分配任何权限，nFigure为1（帮主），默认有全部权限，nFigure为2以上，权限动态分配
function _KLuaTong.GetCaptainPower(nFigure, nPow)
	if nFigure > 0 then
		return self.GetTaskFlag(100 + nFigure, nPow)
	else
		return 0;
	end
end

function _KLuaTong.SetCaptainPower(nFigure, nPow, bSet)
	if nFigure > 0 then
		return self.SetTaskFlag(100 + nFigure, nPow, bSet)
	else
		return 0;
	end
end

--一次过分配所有权限，nPowSet的每个bit表示相应位置的权限是否分配
function _KLuaTong.AssignCaptainPower(nFigure, nPowSet)
	if nFigure > 0 then
		return self.SetTask(100 + nFigure, nPowSet)
	else
		return 0;
	end
end

--掌令使职位的编号从1开始，职位的称号ID从200开始
function _KLuaTong.GetEnvoyTitle(nFigure)
	return self.GetBufTask(200 + nFigure)
end

function _KLuaTong.SetEnvoyTitle(nFigure, szTitle)
	return self.SetBufTask(200 + nFigure, szTitle)
end

if MODULE_GAMECLIENT then
	function _KLuaTong.GetMemberCount()
		local nKinCount		= 0;
		local nMemberCount	= 0
		local pKinIt 		= self.GetKinItor();
		local nCurKinId 	= pKinIt.GetCurKinId();
		while nCurKinId > 0  do
			if (nCurKinId ~= 0) then
				nKinCount = nKinCount + 1;
				nMemberCount = nMemberCount + self.GetKinMemberCount(nCurKinId);
			end
			nCurKinId = pKinIt.NextKinId();
		end
		return nKinCount, nMemberCount;
	end
else
	function _KLuaTong.GetMemberCount()
		local nKinCount		= 0;
		local nMemberCount	= 0
		local pKinIt 		= self.GetKinItor();
		local nCurKinId 	= pKinIt.GetCurKinId();
		while nCurKinId > 0  do
			local pKin = KKin.GetKin(nCurKinId);
			if (pKin) then
				nKinCount = nKinCount + 1;
				nMemberCount = nMemberCount + pKin.nMemberCount;
			end
			nCurKinId = pKinIt.NextKinId();
		end
		return nKinCount, nMemberCount;
	end
end
	

function _KLuaTong.GetCrowdCount(bOnline)
	local nCaptain		= 0;
	local nEmissary		= 0;
	local nExcellent 	= 0;
	local nNormal		= 0;
	local nSigned		= 0
	local pKinIt 		= self.GetKinItor();
	local nCurKinId		= 0;
	local pCurKin		= nil;
	if MODULE_GAMECLIENT then
		pCurKin		= pKinIt.GetCurKin();
	else
		nCurKinId	= pKinIt.GetCurKinId();
		pCurKin		= KKin.GetKin(nCurKinId);
	end
	
	
	while pCurKin do
		local cMemberItor = pCurKin.GetMemberItor();
		local cMember = cMemberItor.GetCurMember();
		while (cMember) do
			if (bOnline or cMember.GetOnline() == 1 ) then
				local nFigure = cMember.GetFigure()
				if (nFigure == 1) then
					nCaptain = nCaptain + 1;
				elseif (cMember.GetEnvoyFigure() ~= 0) then
					nEmissary = nEmissary + 1;
				end
				if (cMember.GetBitExcellent() == 1) then
					nExcellent = nExcellent + 1;
				end
				if (nFigure < Kin.FIGURE_SIGNED) then
					nNormal = nNormal + 1;
				elseif (nFigure == Kin.FIGURE_SIGNED) then
					nSigned = nSigned + 1;
				end
			end
			cMember = cMemberItor.NextMember();
		end
		if MODULE_GAMECLIENT then
			pCurKin = pKinIt.NextKin();
		else
			nCurKinId 	= pKinIt.NextKinId();
			pCurKin		= KKin.GetKin(nCurKinId);
		end
	end
	return {nCaptain, nEmissary, nExcellent, nNormal, nSigned};
end

-- 获得帮会奖励基金的百分比
function _KLuaTong.GetGreatBonusPercent()
	 -- 初始值为0, 对应到50%，取值范围为-50到50，对应到0%～100%
	return self.GetGreatBonusPct() + 50;
end

-- 设置帮会奖励基金的百分比
function _KLuaTong.SetGreatBonusPercent(nPercent)
	 -- 初始值为0, 对应到50%，取值范围为-50到50，对应到0%～100%
	return self.SetGreatBonusPct(nPercent - 50);
end