-------------------------------------------------------
-- 文件名　：kinsalary_gc.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2012-07-02 11:31:58
-- 文件描述：
-------------------------------------------------------

if not MODULE_GC_SERVER then
	return 0;
end

Require("\\script\\kin\\kinsalary\\kinsalary_def.lua");

-- 增加工资
function Kinsalary:AddSalary_GC(nKinId, nMemberId, nType)
	
	-- 活动类型
	local tbInfo = self.EVENT_TYPE[nType];
	if not tbInfo then
		return 0;
	end
	
	-- 存在家族
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	
	-- 存在成员
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return 0;
	end
	
	-- 正式成员
	if Kin:CheckSelfRight(nKinId, nMemberId, 3) ~= 1 then
		return 0;
	end
	
	-- 周目标
	local nMaxTimes = tbInfo.nMaxTimes;
	local nTimes = pMember["Get"..tbInfo.szTimes]();
	if nTimes >= nMaxTimes then
		return 0;
	end
	
	-- 计算工资
	local nSalary = math.floor(tbInfo.nRate * Lib:_GetXuanEnlarge(self:GetOpenDay()));
	local nKinTask = pKin.GetSalaryCurTask();
	if nKinTask > 0 and nKinTask == nType then
		nSalary = nSalary * self.WEEKTASK_MULTI;
	end
	
	-- 增加工资
	pKin.AddSalaryCurWeek(nSalary);
	pMember.AddSalaryCurWeek(nSalary);
	pMember["Add"..tbInfo.szKey](nSalary);
	pMember["Add"..tbInfo.szTimes](1);
	
	-- 更新数据
	local nKinSalary = pKin.GetSalaryCurWeek();
	local nCurSalaryLevel = pKin.GetSalaryCurLevel();
	local nLevel = self:GetKinSalaryLevel(nKinSalary);
	if nLevel > nCurSalaryLevel then
		pKin.SetSalaryCurLevel(nLevel);
	end	
	
	GlobalExcute{"Kinsalary:DoAddSalary_GS", nKinId, nMemberId, nType, nSalary};
end

-- 领取工资
function Kinsalary:GetSalary_GC(nKinId, nMemberId)
	
	-- 存在家族
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	
	-- 存在成员
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return 0;
	end
	
	-- 族长领取一次
	if Kin:CheckSelfRight(nKinId, nMemberId, 1) == 1 then
		pKin.SetSalaryCaptainGet(1);
	end

	-- 清空上周工资
--	pMember.SetSalaryLastWeek(0);
	
	-- 调用gs执行
	GlobalExcute{"Kinsalary:DoGetSalary_GS", nKinId, nMemberId};
end

-- 更新家族数据
function Kinsalary:UpdateKinWeeklyTask_GC(pKin, nKinId)

	local nCurTask = pKin.GetSalaryCurTask();
	local nCurWeek = pKin.GetSalaryCurWeek();
	local nCurLevel = pKin.GetSalaryCurLevel();
	
	-- 随机任务
	local nRandTask = MathRandom(1, self.WEEKTASK_RANGE);
	while nCurTask == nRandTask do	
		nRandTask = MathRandom(1, self.WEEKTASK_RANGE);
	end
	
	-- 更新数据
	pKin.SetSalaryLastTask(nCurTask);
	pKin.SetSalaryCurTask(nRandTask);
	pKin.SetSalaryLastWeek(nCurWeek);
	pKin.SetSalaryCurWeek(0);
	pKin.SetSalaryLastLevel(nCurLevel);
	pKin.SetSalaryCurLevel(0);
	pKin.SetSalaryCaptainGet(0);
	
	-- 更新成员数据
	self:UpdateKinMemberWeeklyTask(pKin);
	
	-- 调用gs执行
	GlobalExcute{"Kinsalary:UpdateKinWeeklyTask_GS", nKinId, nRandTask, nCurTask, nCurWeek, nCurLevel};
end

-- 设置家族数据
function Kinsalary:SetKinSalaryInfo_GC(nKinId, szType, nValue)
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	pKin["Set"..szType](nValue);
	GlobalExcute{"Kinsalary:DoSetKinSalaryInfo", nKinId, szType, nValue};
end

-- 设置成员数据
function Kinsalary:SetMemberSalaryInfo_GC(nKinId, nMemberId, szType, nValue)
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end	
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return 0;
	end	
	pMember["Set"..szType](nValue);
	GlobalExcute{"Kinsalary:DoSetMemberSalaryInfo", nKinId, nMemberId, szType, nValue};
end

-- 7点公告todo
function Kinsalary:Announce_GC()
	local nDay = tonumber(os.date("%w", GetTime()));
	if nDay == 1 then
		GlobalExcute({"KDialog.Msg2SubWorld", "<color=green>Lương Gia tộc của Tuần trước đã có thể nhận tại giao diện Lương Gia tộc trong Gia tộc (F6)<color>"});
	end
end	

-- 测试指令
function Kinsalary:_T1_GC(nKinId)
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	self:UpdateKinWeeklyTask_GC(pKin, nKinId);
end

-- 启动事件
function Kinsalary:StartEvent_GC()
	if KGblTask.SCGetDbTaskInt(DBTASK_KINSALARY_SESSION) == 0 then
		KGblTask.SCSetDbTaskInt(DBTASK_KINSALARY_SESSION, tonumber(os.date("%Y%W", GetTime())));
	end
end

-- 注册gamecenter启动事件
GCEvent:RegisterGCServerStartFunc(Kinsalary.StartEvent_GC, Kinsalary);
