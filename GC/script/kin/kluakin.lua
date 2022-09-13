-------------------------------------------------------------------
--File: kluakin.lua
--Author: lbh
--Date: 2007-7-3 16:20
--Describe: KLuaKin扩展脚本指令
-------------------------------------------------------------------
if not _KLuaKin then --调试需要
	_KLuaKin = {}
	print(GetLocalDate("%Y\\%m\\%d  %H:%M:%S").." build ok ..")
end

local self	--作为第一个Up Value

--用于生成家族任务变量对应的指令
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
	rawset(_KLuaKin, "Get"..szDesc, funGet)
	rawset(_KLuaKin, "Set"..szDesc, funSet)
	rawset(_KLuaKin, "Add"..szDesc, funAdd)
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
	rawset(_KLuaKin, "Get"..szDesc, funGet)
	rawset(_KLuaKin, "Set"..szDesc, funSet)
	rawset(_KLuaKin, "Add"..szDesc, funAdd)
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
	rawset(_KLuaKin, "Get"..szDesc, funGet)
	rawset(_KLuaKin, "Set"..szDesc, funSet)
	rawset(_KLuaKin, "Add"..szDesc, funAdd)
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
	rawset(_KLuaKin, "Get"..szDesc, funGet)
	rawset(_KLuaKin, "Set"..szDesc, funSet)
end

local function RegisterHistory(nType, szFormat, nContentNum)
	if not Kin.HistoryFormat then
		Kin.HistoryFormat = {};
	end
	Kin.HistoryFormat[nType] = {}; 		-- 后注册的会覆盖先注册的
	Kin.HistoryFormat[nType].szFormat = szFormat;
	Kin.HistoryFormat[nType].nContentNum = nContentNum;
end

local function _GEN_HISTORY_RECORD_FUN(szDesc, nType, nContentNum, szFormat)
	local funAdd = 
		function (...)
			return self.AddKinHistory(1, nType, GetTime(), unpack(arg));
		end
	RegisterHistory(nType, szFormat, nContentNum);
	rawset(_KLuaKin, "AddHistory"..szDesc, funAdd);
end

local function _GEN_AFFAIR_RECORD_FUN(szDesc, nType, nContentNum, szFormat)
	local funAdd = 
		function (...)
			return self.AddKinHistory(0, nType, GetTime(), unpack(arg));
		end
	RegisterHistory(nType, szFormat, nContentNum);
	rawset(_KLuaKin, "AddAffair"..szDesc, funAdd);
end

--不要改变任务变量的编号！

_GEN_TASK_FUN("MemberIdGentor", 1)		--用于生成成员ID的计数器
_GEN_TASK_FUN("CreateTime", 2)			--创建时间
_GEN_TASK_FUN("Camp", 3)				--阵营
_GEN_TASK_FUN("Captain", 4)				--族长ID
_GEN_TASK_FUN("Assistant", 5)			--副族长ID
_GEN_TASK_FUN("TotalRepute", 6)			--家族总威望
_GEN_TASK_FUN("VoteCounter", 7)			--家族投票流水号
_GEN_TASK_FUN("VoteStartTime", 8)		--家族投票启始时间
_GEN_TASK_FUN("CaptainLockState", 9)	--族长冻结状态
_GEN_TASK_FUN("LastCamp", 10)			--本身阵营
_GEN_TASK_FUN_U("BelongTong", 11)		--所属帮会Id
_GEN_TASK_FUN("TongFigure", 12)			--在帮会的长老职位
_GEN_TASK_FUN_U("LastTong", 13)			--最近一次帮会Id
_GEN_TASK_FUN("TongVoteBallot", 14)		--族长帮主竞选得票数
_GEN_TASK_FUN("TongVoteJourNum", 15)	--族长帮主竞选得票序位
_GEN_TASK_FUN("TongVoteState", 16)		--帮会竞选是否已投票（族长帮主竞选无用）
_GEN_TASK_FUN_U("ApplyQuitTime", 17)	--申请退出帮会的时间
_GEN_TASK_FUN("GainExpState", 18) 		--家族领取令牌的状态
_GEN_TASK_FUN_U("TogetherTime", 19)		-- 家族聚集时间,最近一次家族插旗的时间
_GEN_TASK_FUN_U("ChangeCampDate", 20) 	-- 最近改变阵营的日期（距离1970年1月1日的天数）
_GEN_TASK_FUN_U("KinGameTime", 21)		-- 最近一次开启家族关卡的时间
_GEN_TASK_FUN_U("KinGameDegree", 22)	-- 进入家族关卡的次数
_GEN_TASK_FUN("KinGuYinBi", 23)			-- 家族古银币数量

-- 家族插旗时间的变量
_GEN_TASK_FUN_U("KinBuildFlagOrderTime", 24) 	-- 家族插旗设置的时间
_GEN_TASK_FUN_U("KinBuildFlagMapId", 25) 		-- 家族插旗设置的地点的地图名字
_GEN_TASK_FUN_U("KinBuildFlagMapX", 26) 		-- 家族插旗设置的地点的地图X坐标
_GEN_TASK_FUN_U("KinBuildFlagMapY", 27) 		-- 家族插旗设置的地点的地图Y坐标

-- 家族周活动相关变量
_GEN_TASK_FUN_U("KinOffer", 28)			-- 家族贡献度
_GEN_TASK_FUN_U("WeeklyTask", 29)		-- 家族周目标
_GEN_TASK_FUN_U("WeeklyKinOffer", 30)	-- 本周家族贡献度
_GEN_TASK_FUN_U("LastWeekKinOffer", 31)	-- 上周的家族贡献度
_GEN_TASK_FUN_U("JoinTongTime", 32)		-- 加入帮会时间
--_GEN_TASK_FUN_U("TongOffer", 33)		-- 家族对帮会的总贡献 已无效
_GEN_TASK_FUN("LastWeeklyTask", 34)	-- 上周的家族活动
_GEN_TASK_FUN("TaskLevel", 35)		-- 周活动目标等级
_GEN_TASK_FUN("NewTaskLevel", 36)		-- 未生效的目标等级
_GEN_TASK_FUN("LastTaskLevel", 37)	-- 上周的周目标等级
_GEN_TASK_FUN("IsCaptainGetAward", 38)	-- 本周族长是否已经领过奖励

-- 家族招募的变量
_GEN_TASK_FUN("RecruitmentPublish", 39)	-- 家族招募是否发布
_GEN_TASK_FUN("RecruitmentLevel", 40)	-- 家族招募等级限制
_GEN_TASK_FUN("RecruitmentHonour", 41)	-- 家族招募荣誉等级限制
_GEN_TASK_FUN("RecruitmentPublishTime", 42)	-- 家族招募发布时间

_GEN_TASK_FUN("MoneyFund", 43)	-- 家族资金
_GEN_TASK_FUN_U("LastSalaryTime", 44)		-- 最近一次发放工资的时间

_GEN_TASK_FUN("BattleCount", 45)	-- 家族战次数

-- 家族逍遥积分
_GEN_TASK_FUN("XoyoMonth", 46)	-- 月份
_GEN_TASK_FUN("XoyoPoint", 47)	-- 积分
_GEN_TASK_FUN("XoyoLastTime", 48)-- 最后一次获得积分时间

--家族技能
_GEN_TASK_FUN("SkillLevel", 49)	-- 技能等级
_GEN_TASK_FUN("SkillExp", 50)	-- 技能当前经验
_GEN_TASK_FUN("UsePoint", 51)	-- 使用的技能点数
_GEN_TASK_FUN("Skilll1-1-1", 52)	-- 技能
_GEN_TASK_FUN("Skilll1-1-2", 53)	-- 技能
_GEN_TASK_FUN("Skilll1-1-3", 54)	-- 技能
_GEN_TASK_FUN("Skilll1-1-4", 55)	-- 技能
_GEN_TASK_FUN("Skilll1-1-5", 56)	-- 技能
_GEN_TASK_FUN("Skilll1-2-1", 57)	-- 技能
_GEN_TASK_FUN("Skilll1-2-2", 58)	-- 技能
_GEN_TASK_FUN("Skilll1-2-3", 59)	-- 技能
_GEN_TASK_FUN("Skilll1-2-4", 60)	-- 技能
_GEN_TASK_FUN("Skilll1-3-1", 61)	-- 技能
-- 家园
_GEN_TASK_FUN("LastHomeLandRank", 62)	-- 上周家园排名
_GEN_TASK_FUN("IsOpenHomeLand", 63)	-- 是否开启了家园
-- 家族高级家族副本变量
_GEN_TASK_FUN("KinGame2LastPassLevel",64)	--上次通关的高级家族关卡

-- 家族YY号
_GEN_TASK_FUN("YYNumber", 65)

-- 自动同意申请
_GEN_TASK_FUN("RecruitmentAutoAgree", 66)

-- 家园种植经验
_GEN_TASK_FUN("PlantExp", 67)
-- 家园种植单周收获棵树
_GEN_TASK_FUN("HandInCount", 68)

-- 金牌家族标志
_GEN_TASK_FUN("GoldLogo", 69)

--家族npc的分配数量，0标识平均分配，正数值表示最多分配到几个玩家身上
_GEN_TASK_FUN("NpcAssignCount", 70)		

-- 金牌家族补偿（战斗关系导致）
_GEN_TASK_FUN("GoldBack", 71)

-- 家族成员最后登录时间
_GEN_TASK_FUN_U("LastLoginTime", 72)

-- 家族仓库
_GEN_TASK_FUN("RepositoryInfoRoom0", 73) -- 1-22位：经验, 23-25位:权限类型, 26-32:背包格数
_GEN_TASK_FUN("RepositoryInfoRoom1", 74)
_GEN_TASK_FUN("RepositoryInfoRoom2", 75)
_GEN_TASK_FUN("RepositoryInfoRoom3", 76)
_GEN_TASK_FUN("RepositoryInfoRoom4", 77)
_GEN_TASK_FUN("RepositoryInfoRoom5", 78)
_GEN_TASK_FUN("RepositoryInfoRoom6", 79)
_GEN_TASK_FUN("RepositoryInfoRoom7", 80)
_GEN_TASK_FUN("RepositoryInfoRoom8", 81)
_GEN_TASK_FUN("RepositoryInfoRoom9", 82)
_GEN_TASK_FUN("FreeRepStartPos",  83)
_GEN_TASK_FUN("LimitRepStartPos", 84)
_GEN_TASK_FUN("IsOpenRepository", 85) -- 仓库是否开启
_GEN_TASK_FUN("RepBuildValue", 86)	-- 仓库建设度
_GEN_TASK_FUN("FreeRepBuildLevel", 87)	-- 自由仓库等级
_GEN_TASK_FUN("LimitRepBuildLevel", 88)	-- 限制仓库等级

-- 家族竞技积分
_GEN_TASK_FUN_U("KinGameMonth", 89)
_GEN_TASK_FUN_U("KinGameGrade", 90)
_GEN_TASK_FUN_U("KinGameGradeLast", 91)

-- 家族工资
_GEN_TASK_FUN("SalaryCurWeek", 92)			-- 当前工资点数
_GEN_TASK_FUN("SalaryLastWeek", 93)			-- 上周工资点数
_GEN_TASK_FUN("SalaryCurTask", 94)			-- 当前周目标
_GEN_TASK_FUN("SalaryLastTask", 95)			-- 上周周目标
_GEN_TASK_FUN("SalaryCurLevel", 96)			-- 上周工资等级
_GEN_TASK_FUN("SalaryLastLevel", 97)		-- 上周工资等级
_GEN_TASK_FUN("SalaryCaptainGet", 98)		-- 族长是否领取奖励

-- 家族徽章
_GEN_TASK_FUN("KinBadge",99)				-- 家族当前使用的徽章在kinbadge中的序号
_GEN_TASK_FUN("BadgeRecord1",100)			-- 1级徽章购买记录
_GEN_TASK_FUN("BadgeRecord2",101)			-- 1级徽章购买记录
_GEN_TASK_FUN("BadgeRecord3",102)			-- 1级徽章购买记录

-- 家族关卡活动的变量
--_GEN_TASK_FUN_U("KinGameOrderTime1", 208) 	-- 家族关卡设置的时间1
--_GEN_TASK_FUN_U("KinGameOrderTime2", 209) 	-- 家族关卡设置的时间2
--_GEN_TASK_FUN_U("KinGameOrderTime3", 210) 	-- 家族关卡设置的时间3
--_GEN_TASK_FUN("KinGameOrderMapId", 211) 		-- 家族关卡设置的地点的地图名字

-- 200 以后是各类临时活动的任务变量
_GEN_TASK_FUN_U("HundredKinScore", 201)	-- 百家评选活动积分
_GEN_TASK_FUN_U("HundredKinJour", 202)	-- 百家评选活动流水
_GEN_TASK_FUN_U("HundredKinAward", 203)	-- 百家评选活动领奖
_GEN_TASK_FUN_U("HundredKinAwardCount", 204)	-- 百家评选活动领奖人数

_GEN_TASK_FUN_U("PlatformScore", 205)	-- 活动平台记录每月家族竞技平台积分
_GEN_TASK_FUN_U("PlatformKinAward", 206)	-- 活动平台记录每月家族竞技平台成员奖励标记
_GEN_TASK_FUN_U("PlatformAwardCount", 207)	-- 活动平台记录每月家族竞技平台成员奖励领取成员数
_GEN_TASK_FUN_U("PlatformKinRank", 208)	-- 活动平台家族排名
_GEN_TASK_FUN_U("BaiHuTangKillNum", 209)	-- 活动平台家族排名
_GEN_TASK_FUN_U("LastGetCallBossTime",210)	-- 新服活动购买家族令牌的时间
_GEN_TASK_FUN_U("FreeCallBossItemCount",211)-- 新服活动每天获得召唤令牌的个数
_GEN_TASK_FUN_U("BuyCallBossItemCount",212)	-- 新服活动每天获得召唤令牌的个数
_GEN_TASK_FUN_U("CallBossCount",213)		-- 新服活动每天召唤boss的次数

if not MODULE_GAMECLIENT then
	_GEN_TMP_TASK_FUN("KinDataVer", 1)	--当前数据版本号，用于与客户端的数据对比
else
	-- 以下只用于客户端专有变量
	_GEN_TASK_FUN("SelfQuitVoteState", 1002)	-- 获取自身投票信息
end

_GEN_BUF_TASK_FUN("Name", 1)				 --家族名称
_GEN_BUF_TASK_FUN("TitleCaptain", 2)		--族长称号
_GEN_BUF_TASK_FUN("TitleAssistant", 3)		--副族长称号
_GEN_BUF_TASK_FUN("TitleMan", 4)			--男称号
_GEN_BUF_TASK_FUN("TitleWoman", 5)			--女称号
_GEN_BUF_TASK_FUN("TitleRetire", 6)			--隐士称号
_GEN_BUF_TASK_FUN("Announce", 7)			--家族公告
_GEN_BUF_TASK_FUN("HomeLandDesc", 8)		--家园描述
_GEN_BUF_TASK_FUN("RecAnnounce", 9)			--招募公告

_GEN_HISTORY_RECORD_FUN("Establish", 	1, 7, '家族"%s"成立，族长为："%s"，成员有：%s %s %s %s %s');
_GEN_HISTORY_RECORD_FUN("Split", 		2, 1, '家族"%s"从本家族中分离');
_GEN_HISTORY_RECORD_FUN("Compose", 		3, 1, '家族"%s"并入本家族中');
_GEN_HISTORY_RECORD_FUN("PlayerJoin", 	4, 1, '玩家"%s"加入了本家族');
_GEN_HISTORY_RECORD_FUN("JoinTong", 	5, 1, '本家族加入帮会"%s"');
_GEN_HISTORY_RECORD_FUN("LeaveTong", 	6, 1, '本家族脱离帮会"%s"');

_GEN_AFFAIR_RECORD_FUN("ChangeCaptain",	7, 2, '玩家"%s"代替了玩家"%s"成为本家族的族长');
_GEN_AFFAIR_RECORD_FUN("GetFundFromTong", 8, 2, '从"%s"帮会转入帮会资金"%s"两');
_GEN_AFFAIR_RECORD_FUN("StorageFundToTong", 9, 3, '"%s"向"%s"帮会转入家族资金"%s"两');
_GEN_AFFAIR_RECORD_FUN("SaveFund", 10, 2, '"%s"存入了"%s"两家族资金');
_GEN_AFFAIR_RECORD_FUN("TakeFund", 11, 2, '"%s"取出了"%s"两家族资金');
_GEN_AFFAIR_RECORD_FUN("SendSalary", 12, 2, '"%s"发放了"%s"工资');

function _KLuaKin.GetMemberCount()
	local nRegular = 0	    --正式成员
	local nSigned = 0		--记名成员
	local nRetire = 0		--荣誉成员
	local nCaptain = 0		--族长称号
	local nAssistant = 0	--副族长称号
	
	local itor = self.GetMemberItor()
	local cMember = itor.GetCurMember()
	while cMember do
		local nFigure = cMember.GetFigure()
		
		if Kin.FIGURE_CAPTAIN == nFigure then
			nCaptain = nCaptain + 1;
		elseif Kin.FIGURE_ASSISTANT == nFigure then
			nAssistant = nAssistant + 1;
		end
		if nFigure <= Kin.FIGURE_REGULAR then
			nRegular = nRegular + 1
		elseif nFigure <= Kin.FIGURE_SIGNED then
			nSigned = nSigned + 1
		else
			nRetire = nRetire + 1
		end
		cMember = itor.NextMember()
	end
	return nRegular, nSigned, nRetire, nCaptain, nAssistant
end


-- 获得成员的PlayerId
function _KLuaKin.GetMemberPlayerId(nMemberId)
	local pMember	= self.GetMember(nMemberId);
	if (not pMember) then
		return nil;
	end
	
	return pMember.GetPlayerId();
end

-- 获得成员的角色名
function _KLuaKin.GetMemberName(nMemberId)
	local nPlayerId	= self.GetMemberPlayerId(nMemberId);
	if not nPlayerId then
		return nil;
	end
	return KGCPlayer.GetPlayerName(nPlayerId);
end
