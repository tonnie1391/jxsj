-------------------------------------------------------------------
--File: kinscheduletask.lua
--Author: lbh
--Date: 2007-7-11 11:26
--Describe: 家族时间任务
-------------------------------------------------------------------
if not Kin then --调试需要
	Kin = {}
	print(GetLocalDate("%Y/%m/%d/%H/%M/%S").." build ok ..")
end

if MODULE_GC_SERVER then
---------------------------GC_SERVER_START----------------------

-- 获取帮会职位
function Kin:GetMemberTongFigure(pTong, cMember, nKinId, nMemberId, nKinFigure)
	if not pTong or not cMember or not nKinId or not nMemberId or not nKinFigure then
		return nil;
	end
	local nTongFigure = nil;
	
	-- 从低到高的判断吧
	if self.FIGURE_REGULAR == nKinFigure then
		nTongFigure = 6;		-- 正式帮众
	elseif self.FIGURE_RETIRE == nKinFigure then
		nTongFigure = 7			-- 荣誉帮众
	elseif self.FIGURE_SIGNED == nKinFigure then
		nTongFigure = 8;		-- 记名帮众
	else
		nTongFigure = 6;		-- 其他的都归为正式帮众
	end
	if cMember.GetBitExcellent() == 1 then
		nTongFigure = 5;		-- 精英
	end
	if cMember.GetEnvoyFigure() > 0 then
		nTongFigure = 4;		-- 掌令使
	end
	if self.FIGURE_CAPTAIN == nKinFigure then
			if pTong.GetMaster() == nKinId then
				nTongFigure = 2;	-- 帮主
			else
				nTongFigure = 3;	-- 长老， 族长至少是长老
			end
	end
	if pTong.GetPresidentKin() == nKinId and pTong.GetPresidentMember() == nMemberId then
		nTongFigure = 1;		-- 首领
	end
	return nTongFigure;
end

--一个帮会的记名成员转正
function Kin:PerMemberDailyAction(cKin, nKinId)
	local itor = cKin.GetMemberItor()
	local cMember = itor.GetCurMember()
	--获取当天的0点时间（假设任务为18:00执行，若不是要更改下式）
	local nTodayBeginTime = GetTime();
	local nLastReputeRank = cKin.GetLastHomeLandRank();
	local nLastLoginTime = cKin.GetLastLoginTime();
	if nLastLoginTime == 0 then -- 第一次维护，默认是三个月前最后一次登录
		local nAssumeTime = math.floor(self.KIN_DISBAND_NOLOGIN_DAY / 2) * 24 * 3600;
		nLastLoginTime = GetTime() - nAssumeTime;
		cKin.SetLastLoginTime(nLastLoginTime);
	end
	local nBeDisband = 0;-- 威望排名大于1000，且家族180天都没有玩家登录
	if (nLastReputeRank == 0 or nLastReputeRank > HomeLand.MAX_VISIBLE_LADDER) and (GetTime() - nLastLoginTime > self.KIN_DISBAND_NOLOGIN_DAY * 24 * 3600) then
		if self.KIN_DISBAND_OPEN == 1 then
			-- 解散家族
			Kin:DisbandKin_GC(nKinId);
			-- 处理家族排行榜
			local nKinIndex = HomeLand.tbKinId2Index[nKinId];
			local nKinCount = #HomeLand.tbCurWeekRank;
			local tbLastKinRank = HomeLand.tbCurWeekRank[nKinCount];
			local nLastKinId = tbLastKinRank.nKinId;
			if nKinIndex then
				if nKinIndex == nKinCount then
					HomeLand.tbCurWeekRank[nKinIndex] = nil;
				else
					-- 保证家族排行榜连续，将最后一名替补到该名次
					HomeLand.tbCurWeekRank[nKinIndex].nKinId = tbLastKinRank.nKinId;
					HomeLand.tbCurWeekRank[nKinIndex].nRepute = tbLastKinRank.nRepute;
					HomeLand.tbCurWeekRank[nKinIndex].nLastRank = tbLastKinRank.nLastRank;
					HomeLand.tbCurWeekRank[nKinCount] = nil;
					HomeLand.tbKinId2Index[nLastKinId] = nKinIndex;
				end
			end
			HomeLand.tbKinId2Index[nKinId] = nil;
			return -1;
		else -- 记Log，用于查看对比
			local szKinName = cKin.GetName();
			local szTongName	= "";
			local pTong			= KTong.GetTong(cKin.GetBelongTong());
			if (pTong) then
				szTongName	= pTong.GetName();
			end
			local nMoney = cKin.GetMoneyFund();
			local nMemberCount = cKin.nMemberCount;
			Dbg:WriteLog("Need DisbandKin", szKinName, szTongName, nMemberCount, nMoney);
		end
	end
	--大于48小时即可转正
	local nMinTime = nTodayBeginTime - self.CHANGE_REGULAR_TIME;
	local nTotalRepute = 0;
	local nTotalDec = 0
	local cTmpMember = cMember;
	local nMemberId;
	while cMember do
		--记名成员转正
		nMemberId = itor.GetCurMemberId();
		cTmpMember = itor.NextMember();
		local tbInfo = GetPlayerInfoForLadderGC(KGCPlayer.GetPlayerName(cMember.GetPlayerId()) or "");
		if (cMember.GetFigure() == self.FIGURE_SIGNED) then
			if (cMember.GetJoinTime() < nMinTime or (tbInfo and tbInfo.nLevel and tbInfo.nLevel < 69)) then
				cMember.SetCan2Regular(1);
				GlobalExcute{"Kin:SetCan2Regular_GS2", nKinId, nMemberId};
			end
		end
		-- 计算家族总威望
		local nPlayerId = cMember.GetPlayerId();
		local nMemberRepute = KGCPlayer.GetPlayerPrestige(nPlayerId);
		nTotalRepute = nTotalRepute + nMemberRepute;
		
		-- 家族成员LOG: 角色名    家族名    帮会名	家族职位	帮会职位
		local szKinName		= cKin.GetName();
		local szTongName	= "";
		local pTong			= KTong.GetTong(cKin.GetBelongTong());
		if (pTong) then
			szTongName	= pTong.GetName();
		end
		local nKinFigure	= cMember.GetFigure() or 0;		-- 家族内职位
		local nTongFigure	= self:GetMemberTongFigure(pTong, cMember, nKinId, nMemberId, nKinFigure) or 0;-- 帮会内职位
		if (szKinName and szTongName and nKinFigure and nTongFigure) then
			StatLog:WriteStatLog("stat_info", "relationship", "member", nPlayerId, szKinName, szTongName, nKinFigure, nTongFigure);
		end
		
		--判断是否退出生效（假设是18:00执行，若不是需更改）
		local nLeaveInitTime = cMember.GetLeaveInitTime()
		if nLeaveInitTime > 0 and nTodayBeginTime - nLeaveInitTime > self.MEMBER_LEAVE_TIME then
			local nFigure = cMember.GetFigure()
			-- 族长不能直接删除
			if nFigure == self.FIGURE_CAPTAIN then
				cMember.SetLeaveInitTime(0);
			else
				self:MemberDel_GC(nKinId, nMemberId, 0);
			end
		end
		-- **后面不准加代码
		cMember = cTmpMember; 
	end
	--家族总威望
	if nTotalRepute < 0 then
		nTotalRepute = 0
	end
	cKin.SetTotalRepute(nTotalRepute)
	self.nJourNum = self.nJourNum + 1
	cKin.SetKinDataVer(self.nJourNum)
	--KStatLog.ModifyMax("Kin", cKin.GetName(), "人数", cKin.nMemberCount);
	local nApplyTime = cKin.GetApplyQuitTime();
	if nApplyTime ~= 0 and GetTime() - nApplyTime >= self.QUIT_TONG_TIME then
		if self:CheckQuitTong(cKin) == 1 then
			local nTongId = cKin.GetBelongTong();
			Tong:KinDel_GC(nTongId, nKinId, 0); -- 通过表决退出成功
		else
			Kin:FailedQuitTong_GC(nKinId, 0);			-- 失败
		end
	end
	-- 族长罢免，开启竞选
	if cKin.GetCaptainLockState() == 1 then
		Kin:StartCaptainVote_GC(nKinId);
	end
	local nLastReputeRank = cKin.GetLastHomeLandRank();
	GlobalExcute{"Kin:PerMemberDailyAction_GS", nKinId, self.nJourNum, nMinTime, nTotalRepute, nLastReputeRank}
	local nKinIndex = HomeLand.tbKinId2Index[nKinId];
	if nKinIndex then
		if not HomeLand.tbCurWeekRank[nKinIndex] then
			HomeLand.tbCurWeekRank[nKinIndex] = {};
		end
	else
		nKinIndex = #HomeLand.tbCurWeekRank + 1;
		HomeLand.tbCurWeekRank[nKinIndex] = {};
	end
	HomeLand.tbCurWeekRank[nKinIndex].nKinId = nKinId;
	HomeLand.tbCurWeekRank[nKinIndex].nRepute = nTotalRepute;
	HomeLand.tbCurWeekRank[nKinIndex].nLastRank = nLastReputeRank;
	HomeLand.tbKinId2Index[nKinId] = nKinIndex;
	return 1;
end

Kin.aSecTotalRepute = { 0, 0, 0, 0 };
function Kin:PerMemberWeeklyAction(cKin, nKinId)
	if not cKin then
		return 0;
	end
	print(cKin.GetName(), "WeeklyAction");
	Kinsalary:UpdateKinWeeklyTask_GC(self.PerKinWeekly_cNextKin, self.PerKinWeekly_nNextKin);
	local nRepute = cKin.GetTotalRepute();
	if nRepute >= 4000 then
		Kin:AddGuYinBi_GC(nKinId, 200);
	elseif nRepute >= 2000 then
		Kin:AddGuYinBi_GC(nKinId, 150);
	elseif nRepute >= 1000 then
		Kin:AddGuYinBi_GC(nKinId, 100);
	end
end

function Kin:PerKinDailyAction_Timer()
	local nResult = self:PerMemberDailyAction(self.PerKinDaily_cNextKin, self.PerKinDaily_nNextKin);
	if nResult ~= -1 then -- 家族已经删除了则不需要处理
		-- 每日清理家族招募榜
		Kin:KinRecruitmenClean(self.PerKinDaily_nNextKin);
		-- 每日家族排行榜处理
		NewEPlatForm:KinPlanFormToLadder(self.PerKinDaily_nNextKin);
		--每日家族族徽资格
		Kin:SysChangeKinBadge(self.PerKinDaily_nNextKin);
	end
	self.PerKinDaily_cNextKin, self.PerKinDaily_nNextKin = KKin.GetNextKin(self.PerKinDaily_nNextKin);
	if not self.PerKinDaily_cNextKin then
		self.PerKinDaily_cNextKin = nil
		self.PerKinDaily_nNextKin = nil
		HomeLand:RefreshRank();
		NewEPlatForm:UpDateLadder()
		print("-------------家族日维护完成-----------------");
		return 0	--Timer结束
	end
	return 1;	--1帧后再执行
end

function Kin:PerKinWeeklyAction_Timer()
	local nTimes = 0;
	while nTimes < Kin.MAX_WEEKLY_HANDLE_COUNT  do
		Kin:CleanKinRecruitmenPublish(self.PerKinWeekly_nNextKin);
	
		self:PerMemberWeeklyAction(self.PerKinWeekly_cNextKin, self.PerKinWeekly_nNextKin);
		self.PerKinWeekly_cNextKin, self.PerKinWeekly_nNextKin = KKin.GetNextKin(self.PerKinWeekly_nNextKin);
		if not self.PerKinWeekly_cNextKin then
			self.PerKinWeekly_cNextKin = nil;
			self.PerKinWeekly_nNextKin = nil;
			self.bIsKinWeeklyActionOver = 1;

			local nSession = tonumber(os.date("%Y%W", GetTime()));	
			KGblTask.SCSetDbTaskInt(DBTASK_KINSALARY_SESSION, nSession);
			
			-- KStatLog.ModifyField("mixstat", "家族0威望段", "总量", self.aSecTotalRepute[1]);
			-- KStatLog.ModifyField("mixstat", "家族1000威望段", "总量", self.aSecTotalRepute[2]);
			-- KStatLog.ModifyField("mixstat", "家族2000威望段", "总量", self.aSecTotalRepute[3]);
			-- KStatLog.ModifyField("mixstat", "家族4000威望段", "总量", self.aSecTotalRepute[4]);
			return 0	--Timer结束
		end
		nTimes = nTimes + 1;
	end
	return 1	--1帧后再执行
end

function Kin:CaptainVoteStart()
	local nMonth = tonumber(GetLocalDate("%m"))
	--如果当月已启动过竞选，不启动
	if KGblTask.SCGetDbTaskInt(DBTASK_KIN_VOTE) == nMonth then
		return 0
	end
	local itor = KKin.GetKinItor()
	if not itor then
		return 0
	end
	local nKinId = itor.GetCurKinId()
	while nKinId > 0 do
		Kin:StartCaptainVote_GC(nKinId);
		nKinId = itor.NextKinId()
	end
	--记录本月族长竞选已启动
	KGblTask.SCSetDbTaskInt(DBTASK_KIN_VOTE, nMonth);
	return 1;
end

function Kin:CaptainVoteStop()
	local itor = KKin.GetKinItor()
	if not itor then
		return 0
	end
	local cKin = itor.GetCurKin()
	local nCurTime = GetTime()
	--临时数组记录竞选结束要统计票数的家族Id
	self.CaptainVote_anVoteStatKinId = {}
	while cKin do
		local nVoteTime = cKin.GetVoteStartTime()
		--24 * 4 * 3600 = 345600
		--投票在第五天后结束
		if nVoteTime > 0 and nCurTime - nVoteTime > 24 * 4 * 3600 then
			table.insert(self.CaptainVote_anVoteStatKinId, itor.GetCurKinId())
		end
		cKin = itor.NextKin()
	end
	--启动统计票数定时函数（每个家族的统计均错帧执行，以提高效率）
	Timer:Register(1, self.PerKinVoteStat_Timer, self)
	return 1
end

function Kin:PerKinVoteStat_Timer()
	if not self.CaptainVote_anVoteStatKinId then
		return 0
	end
	--取出一个Kin
	local nKinId = table.remove(self.CaptainVote_anVoteStatKinId)
	--已为空
	if not nKinId then
		self.CaptainVote_anVoteStatKinId = nil
		return 0
	end
	self:StopCaptainVote_GC(nKinId)
	return 1
end

--家族日常处理
function Kin:PerKinDailyStart()
	self.PerKinDaily_cNextKin, self.PerKinDaily_nNextKin = KKin.GetFirstKin();
	if not self.PerKinDaily_cNextKin then
		return 0
	end
	Timer:Register(1, self.PerKinDailyAction_Timer, self)
	return 0
end

-- 家族周处理
function Kin:PerKinWeeklyStart()
	self.aSecTotalRepute = { 0, 0, 0, 0 };
	local nWeek = tonumber(GetLocalDate("%W"))
	--如果当周已启动过不启动
	if KGblTask.SCGetDbTaskInt(DBTASK_KIN_WEEKLY) == nWeek then
		return 0
	end
	self.PerKinWeekly_cNextKin, self.PerKinWeekly_nNextKin = KKin.GetFirstKin()
	if not self.PerKinWeekly_cNextKin then
		self.bIsKinWeeklyActionOver = 1;
		local nSession = tonumber(os.date("%Y%W", GetTime()));	
		KGblTask.SCSetDbTaskInt(DBTASK_KINSALARY_SESSION, nSession);
		return 0
	end
	Timer:Register(1, self.PerKinWeeklyAction_Timer, self)
	KGblTask.SCSetDbTaskInt(DBTASK_KIN_WEEKLY, nWeek)
	return 0
end

----------------------GC_SERVER_END------------------------------
end

if MODULE_GAMESERVER then
----------------------GAME_SERVER_START---------------------------

function Kin:PerMemberDailyAction_GS(nKinId, nDataVer, nMinTime, nTotalRepute, nLastReputeRank)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return
	end
	cKin.SetTotalRepute(nTotalRepute)
	cKin.SetKinDataVer(nDataVer)
	cKin.SetLastHomeLandRank(nLastReputeRank);
end
---------------------GAME_SERVER_END--------------------------------
end
