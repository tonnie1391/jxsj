-------------------------------------------------------------------
--File: tongscheduletask.lua
--Author: lbh
--Date: 2007-9-21 9:21
--Describe: 帮会时间任务
-------------------------------------------------------------------
if not Tong then --调试需要
	Tong = {}
	print(GetLocalDate("%Y\\%m\\%d  %H:%M:%S").." build ok ..")
end

if MODULE_GC_SERVER then
---------------------------GC_SERVER_START----------------------

function Tong:PerTongDailyAction_Timer()
	local cTong = self.PerTongDaily_cNextTong
	if not cTong then
		return 0	--Timer结束
	end
	local nTongId = self.PerTongDaily_nNextTong
	if cTong.GetTestState() ~= 0 then
		if cTong.GetBuildFund() >= self.TEST_PASS_BUILD_FUND then
			cTong.SetTestState(0)
			KTong.Msg2Tong(nTongId, "Chúc mừng, Bang hội đã vượt qua thời gian khảo nghiệm.")
		elseif (EventManager.IVER_bOpenTiFu == 1) then
			-- do nothing
		else
			local nLeftTime;
			local nCreateTime = cTong.GetCreateTime();
			if nCreateTime < os.time({year=2008, month=6, day=17}) then		-- 6月17日 前建立帮会的给14天的考验期
				nLeftTime= self.TONG_TEST_TIME * 2 - GetTime() + nCreateTime;
			else
				nLeftTime= self.TONG_TEST_TIME - GetTime() + nCreateTime;
			end
			if nLeftTime < 0 then
				KTong.Msg2Tong(nTongId, "Quỹ xây dựng không đạt được "..self.TEST_PASS_BUILD_FUND.." trong thời gian khảo nghiệm, Bang hội đã bị giải tán!")
				Tong:DisbandTong_GC(nTongId);
				cTong = nil;	-- 对象失效，赋予nil值
			else
				KTong.Msg2Tong(nTongId, "Thời gian khảo nghiệm Bang hội còn <color=red>"..math.ceil(nLeftTime / 24 / 3600)..
				"<color> ngày, nếu quỹ xây dựng không thể đạt "..self.TEST_PASS_BUILD_FUND..", Bang hội sẽ tự giải tán.")
			end
		end
	end
	-- 如果帮会已经没有家族则解散帮会
	if cTong and Tong.TONG_DISBAND_OPEN == 1 then
		local nKinCount = cTong.GetKinCount();
		if nKinCount == 0 then
			Tong:DisbandTong_GC(nTongId, 1);
			cTong = nil;	-- 对象失效，赋予nil值
		end
	end
	if cTong then
		if Tong:MasterVoteDeadLine(nTongId) == 1 then
			Tong:StopMasterVote_GC(nTongId);
		end
		
		local pKinItor = cTong.GetKinItor();
		local nKinId = pKinItor.GetCurKinId();
		local nTotalRepute = 0;
		while nKinId ~= 0 do
			local pKin = KKin.GetKin(nKinId);
			if pKin then
				nTotalRepute = nTotalRepute + pKin.GetTotalRepute();
			end
			nKinId = pKinItor.NextKinId();
		end
		cTong.SetTotalRepute(nTotalRepute);
		GlobalExcute{"Tong:SyncTongTotalRepute_GS2", nTongId, nTotalRepute, self.nJourNum};
		
		self:CheckAndSpiltOrComposeStock(nTongId);
	end
	--if cTong then
		--local nKinCount, nMemberCount = cTong.GetMemberCount();
		--KStatLog.ModifyMax("Tong", cTong.GetName(), "家族数", nKinCount);		-- 记录家族数
		--KStatLog.ModifyMax("Tong", cTong.GetName(), "帮会人数", nMemberCount);	-- 记录成员数
	--end
	self.PerTongDaily_cNextTong, self.PerTongDaily_nNextTong = KTong.GetNextTong(self.PerTongDaily_nNextTong)
	if not self.PerTongDaily_cNextTong then
		self.PerTongDaily_nNextTong = nil
		return 0
	end
	return 1	--1帧后再执行
end

function Tong:PerTongWeeklyAction_Timer()
	local cTong = self.PerTongWeekly_cNextTong
	if not cTong then
		return 0	--Timer结束
	end
	local nTongId = self.PerTongWeekly_nNextTong
		
	--行动力刷新
	self:RefleshTongEnergy(nTongId)
	--精英层决定
	self:ExcellentConfirm(nTongId)
	GlobalExcute{"Tong:ExcellentConfirm", nTongId}
	
	--上周分红生效
	self:DealTakeStock(nTongId)
	
	--下一个帮会
	self.PerTongWeekly_cNextTong, self.PerTongWeekly_nNextTong = KTong.GetNextTong(self.PerTongWeekly_nNextTong)
	if not self.PerTongWeekly_cNextTong then
		self.PerTongWeekly_nNextTong = nil
		self.bIsTongWeeklyActionOver = 1;
		return 0
	end
	return 1	--1帧后再执行
end


function Tong:DailyPresidentConfirm_Timer()
	local cTong = self.PerTongPresident_cNextTong;
	if not cTong then
		return 0;	--Timer结束
	end
	local nTongId = self.PerTongPresident_nNextTong;
	local nKinId = cTong.GetPresidentKin();			-- 首领家族
	local nMemberId = cTong.GetPresidentMember();	-- 首领成员
	local pKin = KKin.GetKin(nKinId);
	local bConfirm = 0;
	if not pKin or pKin.GetBelongTong() ~= nTongId then
		bConfirm = 1;
	elseif pKin then
		local pMember = pKin.GetMember(nMemberId);
		if not pMember then
			bConfirm = 1;
		end
	end
	if tonumber(os.date("%w", GetTime())) == self.PRESDIENT_CONFIRM_WDATA then		-- 需要选一次首领,同时决定官衔
		self:PresidentConfirm_GC(nTongId, 1)			
	elseif bConfirm == 1 then							-- 首领离开帮会了~需要选一次首领~不决定官衔
		self:PresidentConfirm_GC(nTongId)
	elseif tonumber(os.date("%w", GetTime())) == 5 then
		self:PresidentCandidateConfirm_GC(nTongId)
	end
	--下一个帮会
	self.PerTongPresident_cNextTong, self.PerTongPresident_nNextTong = KTong.GetNextTong(nTongId);
	if not self.PerTongPresident_cNextTong then
		self.PerTongPresident_cNextTong = nil
		self.PerTongPresident_nNextTong = 0
		return 0
	end
	return 1;
end

function Tong:PerTongVoteStat_Timer()
	_DbgOut("PerTongVoteStat_Timer")
	if not self.MasterVote_anVoteStatTongId then
		return 0
	end
	-- 取出一个Tong
	local nTongId = table.remove(self.MasterVote_anVoteStatTongId)
	-- 已为空
	if not nTongId then
		self.MasterVote_anVoteStatTongId = nil
		return 0
	end
	self:StopMasterVote_GC(nTongId);
	return 1
end


--帮会日常处理
function Tong:PerTongDailyStart()
	_DbgOut("PerTongDailyStart")
	self.PerTongDaily_cNextTong, self.PerTongDaily_nNextTong = KTong.GetFirstTong()
	if not self.PerTongDaily_cNextTong then
		_DbgOut("no tong");
		return 0
	end
	Timer:Register(1, self.PerTongDailyAction_Timer, self)
	return 0
end


function Tong:PerTongWeeklyStart()
	_DbgOut("PerWeeklyStart")
	local nWeek = tonumber(GetLocalDate("%W"))
	--如果当周已启动过不启动
	if KGblTask.SCGetDbTaskInt(DBTASK_TONG_WEEKLY) == nWeek then
		return 0
	end
	self.PerTongWeekly_cNextTong, self.PerTongWeekly_nNextTong = KTong.GetFirstTong()
	if not self.PerTongWeekly_cNextTong then
		self.bIsTongWeeklyActionOver = 1;
		_DbgOut("no tong")
		return 0
	end
	Timer:Register(1, self.PerTongWeeklyAction_Timer, self)
	--记录本周已执行
	KGblTask.SCSetDbTaskInt(DBTASK_TONG_WEEKLY, nWeek)	
	return 0
end

-- 帮会首领处理
function Tong:DailyPresidentConfirm()
	_DbgOut("DailyPresidentConfirm");
	if tonumber(os.date("%w", GetTime())) == self.PRESDIENT_CONFIRM_WDATA then				-- 周一需要维护官衔
		local nOfficialMainTainNo = KGblTask.SCGetDbTaskInt(DBTASK_OFFICIAL_MAINTAIN_NO);
		KGblTask.SCSetDbTaskInt(DBTASK_OFFICIAL_MAINTAIN_NO, nOfficialMainTainNo + 1);
	end
	self.PerTongPresident_cNextTong, self.PerTongPresident_nNextTong = KTong.GetFirstTong()
	if not self.PerTongPresident_cNextTong then
		_DbgOut("no tong");
		return 0
	end
	Timer:Register(1, self.DailyPresidentConfirm_Timer, self)
	return 0
end

-- 开始评优
function Tong:StartGreatMemberVote()
	self.StartGreatMemberVote_pNextTong, self.StartGreatMemberVote_nNextTongId = KTong.GetFirstTong()
	if not self.StartGreatMemberVote_pNextTong then
		_DbgOut("no tong");
		return 0;
	end
	if tonumber(os.date("%w", GetTime())) == self.GREAT_MEMBER_VOTE_START_DAY then				-- 周五开始
		local nCurNo = KGblTask.SCGetDbTaskInt(DBTASK_GREAT_MEMBER_VOTE_NO) + 1
		KGblTask.SCSetDbTaskInt(DBTASK_GREAT_MEMBER_VOTE_NO, nCurNo);
		Timer:Register(1, self.StartGreatMemberVote_Timer, self);
		return 0;
	end
end

-- 每个帮会开始评优
function Tong:StartGreatMemberVote_Timer()
	local pTong = self.StartGreatMemberVote_pNextTong;
	if not pTong then
		return 0;	--Timer结束
	end
	local nTongId = self.StartGreatMemberVote_nNextTongId;
	
	Tong:StartGreatMemberVote_GC(nTongId);
		
	self.StartGreatMemberVote_pNextTong, self.StartGreatMemberVote_nNextTongId = KTong.GetNextTong(self.StartGreatMemberVote_nNextTongId)
	if not self.StartGreatMemberVote_pNextTong then
		self.StartGreatMemberVote_nNextTongId = nil;
		return 0;
	end
	return 1;	--1帧后再执行
end

-- 结束评优
function Tong:EndGreatMemberVote()
	self.EndGreatMemberVote_pNextTong, self.EndGreatMemberVote_nNextTongId = KTong.GetFirstTong()
	if not self.EndGreatMemberVote_pNextTong then
		_DbgOut("no tong");
		return 0;
	end
	if tonumber(os.date("%w", GetTime())) == self.GREAT_MEMBER_VOTE_END_DAY then				-- 周日开始
		Timer:Register(1, self.EndGreatMemberVote_Timer, self);
		return 0;
	end
end

-- 每个帮会结束评优
function Tong:EndGreatMemberVote_Timer()
	local pTong = self.EndGreatMemberVote_pNextTong;
	if not pTong then
		return 0;	--Timer结束
	end
	local nTongId = self.EndGreatMemberVote_nNextTongId;
	
	Tong:EndGreatMemberVote_GC(nTongId);
		
	self.EndGreatMemberVote_pNextTong, self.EndGreatMemberVote_nNextTongId = KTong.GetNextTong(self.EndGreatMemberVote_nNextTongId)
	if not self.EndGreatMemberVote_pNextTong then
		self.EndGreatMemberVote_nNextTongId = nil;
		return 0;
	end
	return 1;	--1帧后再执行
end



----------------------GC_SERVER_END------------------------------
end

if MODULE_GAMESERVER then
----------------------GAME_SERVER_START---------------------------

---------------------GAME_SERVER_END------------------------------
end
