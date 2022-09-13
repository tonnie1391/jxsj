-------------------------------------------------------------------
--File: kinlogic_gc.lua
--Author: lbh
--Date: 2007-6-26 14:57
--Describe: gamecenter家族逻辑
-------------------------------------------------------------------
if not Kin then --调试需要
	Kin = {}
	print(GetLocalDate("%Y/%m/%d/%H/%M/%S").." build ok ..")
else
	if not MODULE_GC_SERVER then
		return
	end
end

function Kin:CreateKinApply_GC(nPlayerId, szKinName)
	local nKinId = KKin.GetKinNameId(szKinName);
	return Tong:ApplyKinName(nKinId, nPlayerId);
end

function Kin:OnKinNameResult(nParam, nResult)
	GlobalExcute{"Kin:OnKinNameResult_GS2", nParam, nResult};
end

--以列表的PlayerId创建家族
function Kin:CreateKin_GC(anPlayerId, anStoredRepute, szKinName, nCamp, bGoldLogo)
	--检查创建家族的成员是否符合要求
	if self:CanCreateKin(anPlayerId) ~= 1 then
		return 0
	end
	local nCreateTime = GetTime()
	local tbStock = {};
	local cKin, nKinId = self:CreateKin(anPlayerId, anStoredRepute, szKinName, nCamp, nCreateTime, tbStock);
	if cKin == nil then
		return 0
	end
	
	--金牌家族标志
	if bGoldLogo then
		cKin.SetGoldLogo(1);
		StatLog:WriteStatLog("stat_info", "jinpailiansai", "create", anPlayerId[1], szKinName, 1);
	else
		StatLog:WriteStatLog("stat_info", "jinpailiansai", "create", anPlayerId[1], szKinName, 0);
	end
	
	--Log 记录
	local szMsg =  string.format("建立%s家族", szKinName);
	KGCPlayer.PlayerLog(anPlayerId[1], Log.emKPLAYERLOG_TYPE_CREATEFAMILY, szMsg);
	szMsg = string.format("%s 建立了该家族",  KGCPlayer.GetPlayerName(anPlayerId[1]));
	_G.KinLog(szKinName,  Log.emKKIN_LOG_TYPE_KINSTRUCTURE, szMsg);
	
	return GlobalExcute{"Kin:CreateKin_GS2", anPlayerId, anStoredRepute, szKinName, nCamp, nCreateTime, tbStock, bGoldLogo}
end

--增加成员
function Kin:MemberAdd_GC(nKinId, nExcutorId, nPlayerId, bCanJoinKinImmediately)
	local nRet, cKin = self:CheckSelfRight(nKinId, nExcutorId, 2)
	if nRet ~= 1 then
		return 0
	end
	if (self:CheckMemberCanAdd(nKinId, nPlayerId) ~= 1) then
		return 0
	end
	--从Id生成器获取Id
	local nMemberId = cKin.GetMemberIdGentor() + 1
	local cMember = cKin.AddMember(nMemberId)
	if not cMember then
		return 0
	end
	if KKin.SetPlayerKinMember(nPlayerId, nKinId, nMemberId) ~= 1 then
		cKin.DelMember(nMemberId)
		return 0
	end
	local nJoinTime = GetTime()
	--设置Id生成器
	cKin.SetMemberIdGentor(nMemberId)
	cMember.SetJoinTime(nJoinTime)
	cMember.SetPlayerId(nPlayerId)
	if (EventManager.IVER_bOpenTiFu == 1) then
		cMember.SetFigure(self.FIGURE_REGULAR)-- TEMP:2008-11-13,xiewen修改（为了方便玩家进入体服参加领土战）
	else
		cMember.SetFigure(self.FIGURE_SIGNED)
	end
	if (bCanJoinKinImmediately == 1) then	-- 如果是被召回老玩家，在老玩家活动期间可以马上转正
		cMember.SetFigure(self.FIGURE_REGULAR);
	end
	local nStoredRepute = KGCPlayer.GetPlayerPrestige(nPlayerId);
	if (nStoredRepute and nStoredRepute > 0) then
		cKin.AddTotalRepute(nStoredRepute)
	end
	self.nJourNum = self.nJourNum + 1
	cKin.SetKinDataVer(self.nJourNum)
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	if szPlayerName then
		cKin.AddHistoryPlayerJoin(szPlayerName);
	end
	
	KKin.DelKinInductee(nKinId, szPlayerName);
	local nRegular, nSigned, nRetire = cKin.GetMemberCount();
	local nMemberLimit, nRetireLimit = self:GetKinMemberLimit(nKinId);
	local nMemberCount = nRegular + nSigned;
	if cKin.GetRecruitmentPublish() == 1 and nMemberCount >= nMemberLimit then
		cKin.SetRecruitmentPublish(0);
	end
	
	-- 股份处理
	local nTongId = cKin.GetBelongTong()
	local pTong = KTong.GetTong(nTongId);
	local nPersonalStock = KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.TSK_TONGSTOCK);		-- 个人资产;
	nPersonalStock = nPersonalStock or 0;
	if pTong then
		local nPrice = Tong.DEFAULT_STOCKPRICE;
		local nBuildFund = pTong.GetBuildFund()
		local nTotalStock = pTong.GetTotalStock();
		if nBuildFund > 0 and nTotalStock > 0 then
			nPrice = nBuildFund / nTotalStock;		-- 计算股价
		end
		if nPrice < 1 then
			nPrice = 1;	-- 股价比1低的时候按1的股价加入帮会，防止溢出
		end
		nBuildFund = nBuildFund + nPersonalStock;
		if (nBuildFund > Tong.MAX_BUILD_FUND) then
			local nBefore = nPersonalStock;
			nPersonalStock = nPersonalStock - (nBuildFund - Tong.MAX_BUILD_FUND);
			nBuildFund = Tong.MAX_BUILD_FUND;
			nBefore = math.floor(100 * nPersonalStock / nBefore) 
			
			-- log
			local szLog = string.format("玩家[%s] 加入家族[%s]个人股份在原有基础上降低了[%d]百分比,当下的股份[%d]",
				KGCPlayer.GetPlayerName(nPlayerId), cKin.GetName(), nBefore, math.floor(nPersonalStock * Tong.JOIN_TONG_STOCK / nPrice));
			Dbg:WriteLog("Kin", szLog);
		end
		pTong.SetBuildFund(nBuildFund);
		nPersonalStock = math.floor(nPersonalStock * Tong.JOIN_TONG_STOCK / nPrice);
		if nTotalStock + nPersonalStock > Tong.MAX_TONG_FUND then
			nPersonalStock = Tong.MAX_TONG_FUND - nTotalStock;
			nTotalStock = Tong.MAX_TONG_FUND;
		else
			nTotalStock = nTotalStock + nPersonalStock;
		end
		pTong.SetTotalStock(nTotalStock);
		Tong:SyncStock(nTongId);
	end
	if nPersonalStock < 0 then
		nPersonalStock = 0;
	end
	cMember.SetPersonalStock(nPersonalStock)

	local szMsg = string.format("%s 加入家族",  KGCPlayer.GetPlayerName(nPlayerId));
	_G.KinLog(cKin.GetName(),  Log.emKKIN_LOG_TYPE_KINSTRUCTURE, szMsg);
	return GlobalExcute{"Kin:MemberAdd_GS2", self.nJourNum, nKinId, nPlayerId, nMemberId, nJoinTime, nStoredRepute, nPersonalStock, bCanJoinKinImmediately}
end

-- 解散家族
function Kin:DisbandKin_GC(nKinId)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	Tong:KinDisband_GC(nKinId);
	local nMoney = cKin.GetMoneyFund();
	local szKinName = cKin.GetName() or "";
	-- 把家族成员全部剔除家族
	local itor = cKin.GetMemberItor();
	local cMember = itor.GetCurMember();
	while cMember do
		local nMemberId = itor.GetCurMemberId();
		local cTmpMember = itor.NextMember();
		local nPlayerId = cMember.GetPlayerId()
		if nPlayerId > 0 then
			KGCPlayer.OptSetTask(nPlayerId, KGCPlayer.TSK_LEAVE_KIN_TIME, GetTime())
			KKin.DelPlayerKinMember(nPlayerId);
		end
		cKin.DelMember(nMemberId);
		cMember = cTmpMember;
	end
	KKin.DelKin(nKinId);
	print("解散家族", nKinId, szKinName, nMoney);
	return GlobalExcute{"Kin:DisbandKin_GS2", nKinId}
end

function Kin:MemberIntroduce_GC(nKinId, nExcutorId, nPlayerId, nPrestige)
	if self:HaveFigure(nKinId, nExcutorId, 3) ~= 1 then
		return 0
	end
	local aThisIntroEvent = self:GetKinData(nKinId).aIntroduceEvent
	--如果推荐已经发起过，返回
	if aThisIntroEvent[nPlayerId] then
		return 0
	end
	aThisIntroEvent[nPlayerId] = nPrestige
	--5分钟后删除
	Timer:Register(5*60*18, self.IntroduceCancel_GC, self, nKinId, nPlayerId)
	return GlobalExcute{"Kin:MemberIntroduce_GS2", nKinId, nExcutorId, nPlayerId}
end

--接受或拒绝推荐申请
function Kin:AcceptIntroduce_GC(nKinId, nExcutorId, nPlayerId, bAccept)
	if self:CheckSelfRight(nKinId, nExcutorId, 2) ~= 1 then
		return 0
	end
	local aThisIntroEvent = self:GetKinData(nKinId).aIntroduceEvent
	local nPrestige = aThisIntroEvent[nPlayerId]
	--如果推荐事件已不存在
	if not nPrestige then
		return 0
	end
	aThisIntroEvent[nPlayerId] = nil
	if KKin.GetPlayerKinMember(nPlayerId) ~= 0 then
		return 0
	end
	GlobalExcute{"Kin:AcceptIntroduce_GS2", nKinId, nPlayerId}
	if bAccept == 1 then
		return Kin:MemberAdd_GC(nKinId, nExcutorId, nPlayerId)
	end
	return 1
end

--时间到取消推荐事件
function Kin:IntroduceCancel_GC(nKinId, nPlayerId)
	local aThisIntroEvent = self:GetKinData(nKinId).aIntroduceEvent
	aThisIntroEvent[nPlayerId] = nil
	return 0
end

--删除成员nMethod = 0自己退出，nMethod = 1开除
function Kin:MemberDel_GC(nKinId, nMemberId, nMethod)
	local cKin = KKin.GetKin(nKinId)
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0
	end
	local nFigure = cMember.GetFigure()
	-- 族长不能直接删除
	if nFigure == self.FIGURE_CAPTAIN then
		return 0
	end
	
	local nPlayerId = cMember.GetPlayerId()
	if nPlayerId <= 0 then
		return 0
	end
	
	-- 股份处理
	local nTongId = cKin.GetBelongTong()
	local pTong = KTong.GetTong(nTongId);
	local nPersonalStock = cMember.GetPersonalStock();
	local nNewStock = 0;
	if pTong then
		local nPrice = 0;
		local nBuildFund = pTong.GetBuildFund()
		local nTotalStock = pTong.GetTotalStock();
		if nBuildFund > 0 and nTotalStock > 0 then
			nPrice = nBuildFund / nTotalStock;		-- 计算股价
		end
		local nMemberFund = math.floor(nPersonalStock * nPrice)
		nNewStock = math.floor(nMemberFund * Tong.QUIT_REDUCE_STOCK)
		nBuildFund = nBuildFund - nMemberFund;
		nTotalStock = nTotalStock - nPersonalStock;
		pTong.SetBuildFund(nBuildFund);
		pTong.SetTotalStock(nTotalStock);
		Tong:SyncStock(nTongId);
	else
		nNewStock = math.floor(nPersonalStock * Tong.QUIT_REDUCE_STOCK);
	end
	KGCPlayer.OptSetTask(nPlayerId, KGCPlayer.TSK_TONGSTOCK, nNewStock);		-- 保存个人资产
	-- 威望处理
	local nRepute = KGCPlayer.GetPlayerPrestige(nPlayerId);
	local nReputeLeft = 0
	if nRepute > 0 then
		--家族总江湖威望减少
		cKin.AddTotalRepute(-nRepute)
	end
	--退出时的时间
	KGCPlayer.OptSetTask(nPlayerId, KGCPlayer.TSK_LEAVE_KIN_TIME, GetTime())
	if KKin.DelPlayerKinMember(nPlayerId) ~= 1 then
		return 0
	end
	if cKin.DelMember(nMemberId) ~= 1 then
		return 0
	end
	if nFigure == self.FIGURE_ASSISTANT then
		cKin.SetAssistant(0)
	end
	self.nJourNum = self.nJourNum + 1
	cKin.SetKinDataVer(self.nJourNum)
	-- Add Kin Log
	local szMsg = string.format("%s, %s", KGCPlayer.GetPlayerName(nPlayerId), (nMethod == 0 and "叛离家族" or "被开除家族"));
	_G.KinLog(cKin.GetName(),  Log.emKKIN_LOG_TYPE_KINSTRUCTURE, szMsg);
	KGCPlayer.PlayerLog(nPlayerId, Log.emKKIN_LOG_TYPE_KINSTRUCTURE, szMsg);	
	
	return GlobalExcute{"Kin:MemberDel_GS2", self.nJourNum, nKinId, nMemberId, nPlayerId, nMethod, nReputeLeft, nRepute}
end

function Kin:LeaveApply_GC(nKinId, nExcutorId, bLeave)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local cMember = cKin.GetMember(nExcutorId)
	if not cMember then
		return 0
	end
	local nTime = 0;
	if bLeave == 1 then
		nTime = GetTime()
	end
	cMember.SetLeaveInitTime(nTime)
	return GlobalExcute{"Kin:LeaveApply_GS2", nKinId, nExcutorId, nTime}
end

--开除成员
function Kin:MemberKickInit_GC(nKinId, nExcutorId, nMemberId)
	if self:CheckSelfRight(nKinId, nExcutorId, 2) ~= 1 then
		return 0
	end	
	local aThisKickEvent = self:GetKinData(nKinId).aKickEvent
	--如果开除已经发起过，返回
	if aThisKickEvent[nMemberId] then
		return 0
	end
	--记录踢人响应事件信息
	aThisKickEvent[nMemberId] = 0	
	--在一定时间后删除
	Timer:Register(self.KICK_RESPOND_TIME, self.MemberKickCancel_GC, self, nKinId, nMemberId)
	return GlobalExcute{"Kin:MemberKickInit_GS2", nKinId, nExcutorId, nMemberId}
end

function Kin:MemberKickRespond_GC(nKinId, nExcutorId, nMemberId)
	if self:HaveFigure(nKinId, nExcutorId, 3) ~= 1 then
		return 0
	end
	local aThisKickEvent = self:GetKinData(nKinId).aKickEvent
	--如果开除未发起或已取消，返回
	if not aThisKickEvent[nMemberId] then
		return 0
	end	
	--先前已经有一个人响应，加上这个响应就有两个人响应，执行删除
	if aThisKickEvent[nMemberId] ~= 0 then
		--如果是同一个人，返回
		if aThisKickEvent[nMemberId] == nExcutorId then
			return 0
		end
		aThisKickEvent[nMemberId] = nil	--释放该事件
		return self:MemberDel_GC(nKinId, nMemberId, 1)
	end
	--否则作为第一个响应的成员记录
	aThisKickEvent[nMemberId] = nExcutorId
end

function Kin:Member2Regular_GC(nKinId, nMemberId)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0
	end
	if cMember.GetFigure() ~= self.FIGURE_SIGNED then
		return 0
	end
	cMember.SetFigure(self.FIGURE_REGULAR)
	return GlobalExcute{"Kin:Member2Regular_GS2", nKinId, nMemberId}
end

function Kin:MemberKickCancel_GC(nKinId, nMemberId)
	local aThisKickEvent = self:GetKinData(nKinId).aKickEvent
	aThisKickEvent[nMemberId] = nil
	GlobalExcute{"Kin:MemberKickCancel_GS2", nKinId, nMemberId}
	return 0
end

--退隐
function Kin:MemberRetire_GC(nKinId, nMemberId)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0
	end
	local nFigure = cMember.GetFigure()
	if nFigure == self.FIGURE_CAPTAIN then
		return 0
	end
	if cMember.GetFigure() > self.FIGURE_REGULAR then
		return 0
	end

	local nRegular, nSigned, nRetireCount = cKin.GetMemberCount();
	
	local nMember, nRetire = self:GetKinMemberLimit(nKinId);
	if nRetireCount >= nRetire then
		return 0;
	end
	
	-- 首领不能退隐
	local nTongId = cKin.GetBelongTong();
	if Tong:IsPresident(nTongId, nKinId, nMemberId) == 1 then
		return 0;
	end
	
	if nFigure == self.FIGURE_ASSISTANT then
		cKin.SetAssistant(0);
	end
	cMember.SetRepAuthority(0); -- 取消仓库管理员权限
	cMember.SetFigure(self.FIGURE_RETIRE)
	cMember.SetEnvoyFigure(0);			-- 退隐删除掌令使职位
	cMember.SetBitExcellent(0);			-- 退隐删除精英
	local nTime = GetTime();
	cMember.SetRetireTime(nTime);		-- 记录申请退隐的时间
	
	local nPlayerId = cMember.GetPlayerId();
	local szMsg = string.format("[%s]退隐家族[%s]", KGCPlayer.GetPlayerName(nPlayerId), cKin.GetName());
	_G.KinLog(cKin.GetName(),  Log.emKKIN_LOG_TYPE_KINSTRUCTURE, szMsg);
	
	return GlobalExcute{"Kin:MemberRetire_GS2", nKinId, nMemberId, nTime}
end

-- 取消退隐
function Kin:CancelRetire_GC(nKinId, nMemberId)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0
	end
	local nFigure = cMember.GetFigure()
	if nFigure ~= self.FIGURE_RETIRE then
		return 0;
	end
	if GetTime() - cMember.GetRetireTime() < self.CANCEL_RETIRE_TIME then
		return 0;
	end
	local nRegular, nSign = cKin.GetMemberCount();
	local nMemberLimit, nRetireLimit = self:GetKinMemberLimit(nKinId);
	if nRegular + nSign >= nMemberLimit then		-- 到达人数上限，取消退隐失败
		return 0;
	end
	cMember.SetFigure(self.FIGURE_REGULAR);
	
	local nPlayerId = cMember.GetPlayerId();
	local szMsg = string.format("[%s]取消退隐家族[%s]", KGCPlayer.GetPlayerName(nPlayerId), cKin.GetName());
	_G.KinLog(cKin.GetName(),  Log.emKKIN_LOG_TYPE_KINSTRUCTURE, szMsg);
	
	local nMemberCount = nRegular + nSign + 1;
	if cKin.GetRecruitmentPublish() == 1 and nMemberCount >= nMemberLimit then
		cKin.SetRecruitmentPublish(0);
	end
	
	return GlobalExcute{"Kin:CancelRetire_GS2", nKinId, nMemberId}
end

--更换称号
function Kin:ChangeTitle_GC(nKinId, nExcutorId, nTitleType, szTitle)
	local nRet, cKin = self:CheckSelfRight(nKinId, nExcutorId, 2)
	if nRet ~= 1 then
		return 0
	end
	--nTitleType + 1即为称号ID
	if cKin.SetBufTask(nTitleType + 1, szTitle) ~= 1 then
		return 0
	end
	return GlobalExcute{"Kin:ChangeTitle_GS2", nKinId, nTitleType, szTitle}
end

--更换阵营
function Kin:ChangeCamp_GC(nKinId, nExcutorId, nCamp)
	local nRet, cKin = self:CheckSelfRight(nKinId, nExcutorId, 1)
	if nRet ~= 1 then
		return 0
	end
	--有帮会则不能更改
	if cKin.GetBelongTong() ~= 0 then
		return 0
	end
	if cKin.SetCamp(nCamp) ~= 1 then
		return 0
	end
	-- 有可能没执行却扣了钱~写个LOG吧
	Dbg:WriteLog("家族","执行更换阵营", "家族ID:"..nKinId);
	self.nJourNum = self.nJourNum + 1;
	cKin.SetKinDataVer(self.nJourNum);
	local nDate = tonumber(Lib:GetLocalDay(GetTime()));
	cKin.SetChangeCampDate(nDate);
	return GlobalExcute{"Kin:ChangeCamp_GS2", self.nJourNum, nKinId, nCamp, nDate}
end

--设置副族长
function Kin:SetAssistant_GC(nKinId, nExcutorId, nMemberId)
	local nRet, cKin = self:CheckSelfRight(nKinId, nExcutorId, 1)
	if nRet ~= 1 then
		return 0
	end
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0
	end	
	local nOldAssistant = cKin.GetAssistant()
	if nOldAssistant ~= 0 then
		local cOldAssistant = cKin.GetMember(nOldAssistant)
		if cOldAssistant then
			cOldAssistant.SetFigure(self.FIGURE_REGULAR)
		end
	end
	cKin.SetAssistant(nMemberId)
	cMember.SetFigure(self.FIGURE_ASSISTANT)
	self.nJourNum = self.nJourNum + 1
	cKin.SetKinDataVer(self.nJourNum)
	
	--Log 记录
	local szAssistantName = KGCPlayer.GetPlayerName(cMember.GetPlayerId());
	local nCaptainId = cKin.GetCaptain();
	local cCaptain = cKin.GetMember(nCaptainId);
	local szCaptainName = KGCPlayer.GetPlayerName(cCaptain.GetPlayerId());
	local szMsg = string.format("%s被%s任命为副族长", szAssistantName, szCaptainName);
	KGCPlayer.PlayerLog(cMember.GetPlayerId(), Log.emKPLAYERLOG_TYPE_FAMILYAPPOINT, szMsg);
	
	return GlobalExcute{"Kin:SetAssistant_GS2", self.nJourNum, nKinId, nMemberId}
end

function Kin:FireAssistant_GC(nKinId, nExcutorId, nMemberId)
	local nRet, cKin = self:CheckSelfRight(nKinId, nExcutorId, 1)
	if nRet ~= 1 then
		return 0
	end
	if cKin.GetAssistant() ~= nMemberId then
		return 0
	end
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0
	end
	cMember.SetFigure(self.FIGURE_REGULAR)
	cKin.SetAssistant(0)
	
	--Log 记录
	local szAssistantName = KGCPlayer.GetPlayerName(cMember.GetPlayerId());
	local nCaptainId = cKin.GetCaptain();
	local cCaptain = cKin.GetMember(nCaptainId);
	local szCaptainName = KGCPlayer.GetPlayerName(cCaptain.GetPlayerId());

	local szMsg = string.format("%s被%s撤销副族长职务", szAssistantName, szCaptainName);
	KGCPlayer.PlayerLog(cMember.GetPlayerId(), Log.emKPLAYERLOG_TYPE_FAMILYAPPOINT, szMsg);
	
	return GlobalExcute{"Kin:FireAssistant_GS2", nKinId, nMemberId}
end

--更换族长（bPlayerAction是否玩家操作）
function Kin:ChangeCaptain_GC(nKinId, nExcutorId, nMemberId)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	local bSys = 0;
	--系统执行
	if nExcutorId == -1 then
		bSys = 1
		nExcutorId = cKin.GetCaptain()
	end
	if nExcutorId == nMemberId then
		return 0
	end
	local cExcutor = cKin.GetMember(nExcutorId)
	
	local cMember = cKin.GetMember(nMemberId)
	if not cExcutor or not cMember then
		return 0
	end
	
	-- 如果族长是帮主，也记录到帮会事件上
	local nTongId = cKin.GetBelongTong();
	local szNewCaptain = KGCPlayer.GetPlayerName(cMember.GetPlayerId());
	local szOldCaptain = KGCPlayer.GetPlayerName(cExcutor.GetPlayerId());
	if nTongId then
		local pTong = KTong.GetTong(nTongId);
		if pTong then
			if pTong.GetMaster() == nKinId then
				pTong.AddAffairChangeMaster(szNewCaptain, szOldCaptain);
			end
		end
	end
	
	if cKin.GetAssistant() == nMemberId then
		cKin.SetAssistant(0)
	end
	if cKin.SetCaptain(nMemberId) ~= 1 then
		return 0
	end
	if cMember.SetFigure(self.FIGURE_CAPTAIN) ~= 1 then
		return 0
	end
	cExcutor.SetFigure(self.FIGURE_REGULAR)
	cKin.AddAffairChangeCaptain(szNewCaptain, szOldCaptain);
	self.nJourNum = self.nJourNum + 1;
	cKin.SetKinDataVer(self.nJourNum)
	-- 移交仓库权限
	cMember.SetRepAuthority(KinRepository.AUTHORITY_FIGURE_CAPTAIN);
	cExcutor.SetRepAuthority(0);
	if 0 == bSys then
		local nPlayerId = cExcutor.GetPlayerId();
		local nPrestige = KGCPlayer.GetPlayerPrestige(nPlayerId);
		if nPrestige < 10 then
			return 0
		end
		KGCPlayer.SetPlayerPrestige(nPlayerId, nPrestige - 10);
	end
	
	local szMsg = "";
	if bSys == 1 then
		--罢免选举成族长
		szMsg = string.format("[%s] 经选举变成族长", KGCPlayer.GetPlayerName(cMember.GetPlayerId()));	
		KGCPlayer.PlayerLog(cMember.GetPlayerId(), Log.emKPLAYERLOG_TYPE_FAMILYAPPOINT, szMsg);		
	else
		--传位成族长
		local szExcutorMsg = string.format("[%s] 任命为族长, [%s] 变成普通成员", 
							 KGCPlayer.GetPlayerName(cMember.GetPlayerId()), 
							 KGCPlayer.GetPlayerName(cExcutor.GetPlayerId()));
		szMsg = string.format("[%s]被[%s]任命为族长",szNewCaptain,szOldCaptain);
		
		KGCPlayer.PlayerLog(cExcutor.GetPlayerId(), Log.emKPLAYERLOG_TYPE_FAMILYAPPOINT, szExcutorMsg);
		KGCPlayer.PlayerLog(cMember.GetPlayerId(), Log.emKPLAYERLOG_TYPE_FAMILYAPPOINT, szMsg);		
	end	

	-- Add KinLog
	_G.KinLog(cKin.GetName(),  Log.emKKIN_LOG_TYPE_KINSTRUCTURE,  szMsg);
	return GlobalExcute{"Kin:ChangeCaptain_GS2", self.nJourNum, nKinId, nExcutorId, nMemberId}
end

--发起罢免族长
function Kin:FireCaptain_Init_GC(nKinId, nExcutorId)
	local nRet, cKin, cExcutor = self:CheckSelfRight(nKinId, nExcutorId, 3)
	if nRet ~= 1 then
		return 0
	end
	local aKinData = self:GetKinData(nKinId)
	if aKinData.eveFireCaptain0 then
		return 0
	end
	aKinData.eveFireCaptain0 = nExcutorId
	Timer:Register(5*60*18, self.FireCaptain_Cancel, self, nKinId)
	return GlobalExcute{"Kin:FireCaptain_Init_GS2", nKinId, nExcutorId}
end

function Kin:FireCaptain_Cancel(nKinId)
	local aKinData = self:GetKinData(nKinId)
	aKinData.eveFireCaptain0 = nil
	aKinData.eveFireCaptain1 = nil
	GlobalExcute{"Kin:FireCaptain_Cancel_GS2", nKinId}
	return 0
end

function Kin:FireCaptain_Vote_GC(nKinId, nExcutorId)
	local nRet, cKin, cExcutor = self:HaveFigure(nKinId, nExcutorId, 3)
	if nRet ~= 1 then
		return 0
	end
	local aKinData = self:GetKinData(nKinId)
	if not aKinData.eveFireCaptain0 then
		return 0
	end
	local bLock
	--已经表决过
	if aKinData.eveFireCaptain0 == nExcutorId or aKinData.eveFireCaptain1 == nExcutorId then
		return 0
	end
	if not aKinData.eveFireCaptain1 then
		aKinData.eveFireCaptain1 = nExcutorId
	else --已有两个人表决
		aKinData.eveFireCaptain0 = nil
		aKinData.eveFireCaptain1 = nil
		cKin.SetCaptainLockState(1)
		bLock = 1;
	end
	local szPlayerName = KGCPlayer.GetPlayerName(cExcutor.GetPlayerId());
	KGCPlayer.PlayerLog(cExcutor.GetPlayerId(), Log.emKPLAYERLOG_TYPE_FAMILYAPPOINT, "["..szPlayerName.."]族长被罢免变成普通成员");
	
	return GlobalExcute{"Kin:FireCaptain_Vote_GS2", nKinId, nExcutorId, bLock}
end

--编辑公告
function Kin:SetAnnounce_GC(nKinId, nExcutorId, szAnnounce)
	local nRet, cKin = self:CheckSelfRight(nKinId, nExcutorId, 2)
	if nRet ~= 1 then
		return 0
	end
	if cKin.SetAnnounce(szAnnounce) ~= 1 then
		return 0
	end
	self.nJourNum = self.nJourNum + 1
	cKin.SetKinDataVer(self.nJourNum)
	return GlobalExcute{"Kin:SetAnnounce_GS2", self.nJourNum, nKinId, szAnnounce}
end

-- 编辑家园描述
function Kin:SetHomeLandDesc_GC(nKinId, nExcutorId, szHomeLandDesc)
	local nRet, cKin = self:CheckSelfRight(nKinId, nExcutorId, 2)
	if nRet ~= 1 then
		return 0
	end
	if cKin.SetHomeLandDesc(szHomeLandDesc) ~= 1 then
		return 0
	end
	self.nJourNum = self.nJourNum + 1
	cKin.SetKinDataVer(self.nJourNum)
	return GlobalExcute{"Kin:SetHomeLandDesc_GS2", self.nJourNum, nKinId, szHomeLandDesc}
end

--招募公告
function Kin:SetRecAnnounce_GC(nKinId, nExcutorId, szRecAnnounce)
	local nRet, cKin = self:CheckSelfRight(nKinId, nExcutorId, 2)
	if nRet ~= 1 then
		return 0
	end
	if cKin.SetRecAnnounce(szRecAnnounce) ~= 1 then
		return 0
	end
	self.nJourNum = self.nJourNum + 1
	cKin.SetKinDataVer(self.nJourNum)
	return GlobalExcute{"Kin:SetRecAnnounce_GS2", self.nJourNum, nKinId, szRecAnnounce}
end

--族长竞选（启动单个家族的竞选）
function Kin:StartCaptainVote_GC(nKinId)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	--竞选已启动，则不能再启动
	if cKin.GetVoteStartTime() ~= 0 then
		return 0
	end
	local nStartTime = GetTime()
	cKin.SetVoteStartTime(nStartTime)
	KKin.SendKinMail(nKinId, "家族竞选通知", "本界家族族长竞选已经启动，家族正式成员现在可通过家族界面投票！")
	return GlobalExcute{"Kin:StartCaptainVote_GS2", nKinId, nStartTime}
end

function Kin:StopCaptainVote_GC(nKinId)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 1
	end
	cKin.SetVoteCounter(0)
	cKin.SetVoteStartTime(0)
	local itor = cKin.GetMemberItor()
	local cMember = itor.GetCurMember()
	local nMaxBallot = 0
	local nCurMaxMember = 0
	local nCurJourNum = 0
	while cMember do
		local nBallot = cMember.GetBallot()
		if nBallot > nMaxBallot or (nBallot == nMaxBallot and cMember.GetVoteJourNum() < nCurJourNum) then
			nMaxBallot = nBallot
			nCurMaxMember = itor.GetCurMemberId()
			nCurJourNum = cMember.GetVoteJourNum()
		end
		--清空投票数据
		cMember.SetBallot(0)
		cMember.SetVoteState(0)
		cMember.SetVoteJourNum(0)
		
		cMember = itor.NextMember()
	end
	if nCurMaxMember > 0 then
		Kin:ChangeCaptain_GC(nKinId, -1, nCurMaxMember)
	end
	--解除族长锁定状态
	cKin.SetCaptainLockState(0)
	return GlobalExcute{"Kin:StopCaptainVote_GS2", nKinId, nCurMaxMember, nMaxBallot}
end

--族长竞选投票
function Kin:CaptainVoteBallot_GC(nKinId, nExcutorId, nMemberId)
	local nRet, cKin, cMemberExcutor = self:HaveFigure(nKinId, nExcutorId, 3)
	if nRet ~= 1 then
		return 0
	end
	local nVoteStartTime = cKin.GetVoteStartTime()
	if nVoteStartTime == 0 then
		return 0
	end
	if cMemberExcutor.GetVoteState() == nVoteStartTime then
		return 0
	end
	cMemberExcutor.SetVoteState(nVoteStartTime)
	--江湖威望作为票数
	local nBallot = KGCPlayer.GetPlayerPrestige(cMemberExcutor.GetPlayerId());
	if nBallot <= 0 then
		return 0
	end
	local cTargetMember = cKin.GetMember(nMemberId)
	if not cTargetMember or cTargetMember.GetFigure() > self.FIGURE_REGULAR then
		return 0
	end
	local nVoteCounter = cKin.GetVoteCounter() + 1
	cKin.SetVoteCounter(nVoteCounter)
	cTargetMember.AddBallot(nBallot)
	--记录投票序号
	cTargetMember.SetVoteJourNum(nVoteCounter)
	return GlobalExcute{"Kin:CaptainVoteBallot_GS2", nKinId, nExcutorId, nMemberId, nBallot, nVoteCounter}
end

function Kin:JoinTong_GC(nKinId, szTong, nTongId, nCamp, bSync)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	-- add Tonglog JoinTong
	local szMsg = string.format("[%s] 家族加入帮会", cKin.GetName());
	_G.TongLog(szTong, Log.emKTONG_LOG_TONGSTRUCTURE , szMsg);
	
	cKin.SetLastCamp(cKin.GetCamp())
	cKin.SetBelongTong(nTongId)
	cKin.SetCamp(nCamp)
	cKin.AddHistoryJoinTong(szTong);
	if bSync then
		return GlobalExcute{"Kin:JoinTong_GS2", nKinId, szTong, nTongId, nCamp}
	end
	return 1
end

function Kin:ApplyQuitTong_GC(nTongId, nKinId, nExcutorId)
	local nRet, cKin, cExcutor = self:CheckSelfRight(nKinId, nExcutorId, 1);
	if nRet ~= 1 then
		return 0
	end
	if cKin.GetApplyQuitTime() ~= 0 then
		return 0;
	end
	local nCurTime =GetTime();
	cKin.SetApplyQuitTime(nCurTime);
	return GlobalExcute{"Kin:ApplyQuitTong_GS2", nKinId, nCurTime};
end

function Kin:FailedQuitTong_GC(nKinId, nSuccess)
	return self:CloseQuitTong_GC(nKinId, nSuccess);
end

--关闭退出帮会的投票状态
--注意：nSuccess 为0；没通过,反对人数足够多，2为 族长取消）
function Kin:CloseQuitTong_GC(nKinId, nSuccess)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then 
		return 0;
	end
	cKin.SetApplyQuitTime(0);
	local cMemberItor = cKin.GetMemberItor();
	local cCurMember = cMemberItor.GetCurMember();
	while cCurMember do
		cCurMember.SetQuitVoteState(0);		-- 清空各个成员的投票状态
		cCurMember = cMemberItor.NextMember()
	end
	GlobalExcute{"Kin:CloseQuitTong_GS2", nKinId, nSuccess};
	return 1;
end

-- 成员表决退出帮会
function Kin:QuitTongVote_GC(nKinId, nMemberId, nAccept)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then 
		return 0;
	end
	if cKin.GetApplyQuitTime() == 0 then
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId);
	if not cMember then 
		return 0;
	end
	if cMember.GetQuitVoteState() ~= 0 then
		return 0;
	end
	cMember.SetQuitVoteState((nAccept == 1) and 1 or 2);
	return GlobalExcute{"Kin:QuitTongVote_GS2", nKinId, nMemberId, nAccept};
end
function Kin:LeaveTong_GC(nTongId, nKinId, nMethod, bSync)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	
--	local nLastCamp = cKin.GetLastCamp()
--	if nLastCamp ~= 0 then
--		cKin.SetCamp(nLastCamp)
--	end
	--清空帮会相关数据
	cKin.SetBelongTong(0)
	cKin.SetTongFigure(0)
	cKin.SetTongVoteBallot(0)
	cKin.SetTongVoteJourNum(0)
	cKin.SetTongVoteState(0)
	
	-- 股份处理
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	local nBuildFund = pTong.GetBuildFund()
	local nTotalStock = pTong.GetTotalStock();
	local nPrice = 0;
	if nBuildFund > 0 and nTotalStock > 0 then
		nPrice = nBuildFund / nTotalStock;		-- 计算股价
	end
	Dbg:WriteLog("TongBuildFund", "kinleave_beg", nTongId, nBuildFund, nTotalStock, nKinId, Kin:GetTotalKinStock(nKinId));
	--清空成员帮会相关数据
	local cMemberItor = cKin.GetMemberItor()
	local cMember = cMemberItor.GetCurMember()
	local tbResult = {};
	local nReduceFund = 0;
	while cMember do
		cMember.SetTongFlag(0);
		cMember.SetEnvoyFigure(0);
		cMember.SetWageFigure(0);
		cMember.SetWageValue(0);
		cMember.SetStockFigure(Tong.NONE_STOCK_RIGHT);
		local nPersonalStock = cMember.GetPersonalStock()
		local nMemberFund = math.floor(nPersonalStock * nPrice)
		local nNewStock = math.floor(nMemberFund * Tong.QUIT_REDUCE_STOCK)
		tbResult[cMemberItor.GetCurMemberId()] = nNewStock		-- 记录结果
		cMember.SetPersonalStock(nNewStock);		-- 无帮会的成员股票数等于资产，即股价恒为1
		nBuildFund = nBuildFund - nMemberFund;		-- 总资减少
		nReduceFund = nReduceFund + nMemberFund
		nTotalStock = nTotalStock - nPersonalStock;	-- 总股票减少
		local nPlayerId = cMember.GetPlayerId();
		cMember = cMemberItor.NextMember();
	end
	if nBuildFund < 0 then
		Dbg:WriteLog("TongBuildFund", "error", nTongId, nBuildFund, nTotalStock);
		nBuildFund = 0;
	end
	if nTotalStock < 0 then
		Dbg:WriteLog("TongBuildFund", "error", nTongId, nBuildFund, nTotalStock);
		nTotalStock = 0;
	end
	pTong.SetBuildFund(nBuildFund);
	pTong.SetTotalStock(nTotalStock);
	self:CloseQuitTong_GC(nKinId);	-- 关闭该家族的退出投票状态（如果存在的话）
	Dbg:WriteLog("TongBuildFund", "kinleave_end", nTongId, nBuildFund, nTotalStock, nKinId, Kin:GetTotalKinStock(nKinId));
	GlobalExcute{"Kin:LeaveTong_GS2", nTongId, nKinId, nMethod, nBuildFund, nTotalStock, tbResult, bSync or 1};
	return nReduceFund;
end

function Kin:SetSelfQuitVoteState_GC(nKinId, nMemberId, nVoteState)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId);
	if not cMember then
		return 0;
	end
	cMember.SetQuitVoteState(nVoteState);
end

function Kin:AddKinTotalRepute_GC(nKinId, nMemberId, nPlayerId, nRepute)
	KGCPlayer.SetPlayerPrestige(nPlayerId, KGCPlayer.GetPlayerPrestige(nPlayerId) + nRepute);
	local pKin = KKin.GetKin(nKinId);
	if pKin then
		pKin.AddTotalRepute(nRepute);
		self.nJourNum = self.nJourNum + 1
		pKin.SetKinDataVer(self.nJourNum);
	end
	GlobalExcute{"Kin:AddKinTotalRepute_GS2", nKinId, nMemberId, nPlayerId, nRepute, self.nJourNum};
end

-- 增加古银币
function Kin:AddGuYinBi_GC(nKinId, nAddGuYinBi)
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	if nAddGuYinBi <= 0 then
		return 0;
	end
	local nCurGuYinBi = pKin.GetKinGuYinBi();
	if nCurGuYinBi + nAddGuYinBi > self.MAX_GU_YIN_BI then
		nAddGuYinBi = self.MAX_GU_YIN_BI - nCurGuYinBi;
	end
	if nAddGuYinBi > 0 then
		pKin.AddKinGuYinBi(nAddGuYinBi);
	end
	GlobalExcute{"Kin:AddGuYinBi_GS2", nKinId, nCurGuYinBi + nAddGuYinBi, nAddGuYinBi};
end

-- 衰减威望
function Kin:DecreasePrestige()
	local nRank = EventManager.IVER_nMinPrestigeRank;
	local nNowTime		= GetTime();
	local nCoZoneTime	= KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME);
	if nNowTime < nCoZoneTime + 30 * 24 * 60 * 60 then
		nRank = nRank * 2;
	end
	KGCPlayer.StartSortPrestige(1, nRank);
	
	local nNowDay = tonumber(os.date("%w", nNowTime));
	if nNowDay == 1 then
		local Type = Ladder:GetType(0, Ladder.LADDER_CLASS_LADDER, Ladder.LADDER_TYPE_LADDER_ACTION, Ladder.LADDER_TYPE_LADDER_ACTION_WEIWANG);
		local tbShowLadder	= GetTotalLadderPart(Type, 1, 500);
		for i, tbInfo in ipairs(tbShowLadder) do
			local nPlayerId	= KGCPlayer.GetPlayerIdByName(tbInfo.szPlayerName);
			KGCPlayer.SetPlayerPrestige(nPlayerId, 0);
		end
	end
end

-- 保存插旗的时间和地点
function Kin:SaveBuildFlagSetting_GC(nPlayerId, nKinId, nTime, nMapId, nMapX, nMapY)
	-- 判断时间是否正确
	local nBeginTime		= 19 * 60 + 30	-- 允许使用的开始时间
	local nEndTime			= 23 * 60 + 30	-- 允许使用的结束时间
	if nTime < nBeginTime or nTime > nEndTime then
		return 0;
	end	
	
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0
	end
	

	-- 记录插旗时间
	cKin.SetKinBuildFlagOrderTime(nTime);
	-- 记录插旗地点
	cKin.SetKinBuildFlagMapId(nMapId);
	cKin.SetKinBuildFlagMapX(nMapX);
	cKin.SetKinBuildFlagMapY(nMapY);
	
	-- 记录今天已经插旗 （因为nTime只是记录时间，没有日期，所以要再取）
	local nNowDay = tonumber(os.date("%m%d", GetTime()));
	cKin.SetTogetherTime(nNowDay);
	--print("Kin"..nKinId..",BuildFlag_GC——TogetherTime"..nNowDay);
	GlobalExcute{"Kin:SaveBuildFlagSetting_GS2", nPlayerId, nKinId, nTime, nMapId, nMapX, nMapY};
end


-- 修改家族令牌的KinExpstate,使玩家能再领家族令牌
function Kin:ChangeKinExpState_GC(nPlayerId, nKinId, nMemberId)
	local nRet, cKin = self:CheckSelfRight(nKinId, nMemberId, 2); 
	if nRet ~= 1 then
		Dbg:WriteLog("Kin", "修改家族令牌时权限不足", "玩家姓名："..KGCPlayer.GetPlayerName(nPlayerId));
		return 0;
	end
	

	local nTime = GetTime();
	local nNowDay = tonumber(os.date("%m%d", nTime));

	-- 如果今天已经领过了
	if cKin.GetGainExpState() == nNowDay then
		Dbg:WriteLog("Kin", "修改家族令牌时发现今天已经领过了家族令牌",  "玩家姓名："..KGCPlayer.GetPlayerName(nPlayerId));
		return 0;
	end
	
	-- 如果已经给过钱了还没设时间或者是第一次领令牌
	if cKin.GetKinBuildFlagOrderTime() == 0 then
		Dbg:WriteLog("Kin", "修改家族令牌时发现已经给过钱了还没设时间或者是第一次领令牌",  "玩家姓名："..KGCPlayer.GetPlayerName(nPlayerId));
		return 0;
	end

	cKin.SetGainExpState(nNowDay);
	cKin.SetKinBuildFlagOrderTime(0);
	
	GlobalExcute{"Kin:ChangeKinExpState_GS2", nPlayerId, nKinId};
end


-- 领取家族令牌
function Kin:GetKinLingPai_GC(nKinId, nMemberId)
	local nRet, cKin = self:CheckSelfRight(nKinId, nMemberId, 2);
	if nRet ~= 1 then
		return 0;
	end
	

	local nTime = GetTime();
	local nNowDay = tonumber(os.date("%m%d", nTime));
	
	if cKin.GetGainExpState() == nNowDay then	--已经领取过了
		return 0;
	end
	
	local nPlayerId = cKin.GetMember(nMemberId).GetPlayerId();
	
	if not nPlayerId then
		return 0;
	end
	
	cKin.SetGainExpState(nNowDay);
	GlobalExcute{"Kin:GetKinLingPai_GS2", nKinId, nPlayerId};
end
-- 1.白虎堂 2.宋金 3. 通缉 4. 逍遥谷 5. 军营
--Kin.tbWeeklyAction = {
--	{1, 2, 3,},	-- 50级周目标任务
--	{1, 2, 3, 4,},	-- 80级的周目标任务
--	{1, 2, 3, 4, 5,},	-- 90级的周目标任务
--	};
--
--function Kin:PerKinWeeklyTask_GC(cKin, nKinId)
--	if (not cKin) then
--		return;
--	end
--	if (cKin.GetBelongTong() ~= 0) then
--		return 0;	-- 有帮会的家族不对家族进行处理
--	end
--	Kin:StatisticsWeeklyTaskLevel(cKin);
--	-- 为家族随机周任务，并且把周任务记录到家族当中
--	local nWeeklyTask = self:RandWeeklyAction(cKin);
--	if (not nWeeklyTask or nWeeklyTask == 0) then
--		local szErrLog = string.format("家族：%s，所属帮会：无，周目标等级为：%s，新的周目标编号为：%s，周目标维护出现异常。",
--			cKin.GetName(), cKin.GetTaskLevel(), nWeeklyTask or "不存在");
--		Dbg:WriteLog("家族周目标", szErrLog);
--		return;
--	end
--	-- 记录家族上周的贡献度，并把本周贡献度清零
--	local nOffer = cKin.GetWeeklyKinOffer();
--	cKin.SetWeeklyKinOffer(0);
--	cKin.SetLastWeekKinOffer(nOffer);
--	cKin.SetIsCaptainGetAward(0);
--	-- 记录下上周的活动目标
--	local nTaskTemp = cKin.GetWeeklyTask();
--	cKin.SetLastWeeklyTask(nTaskTemp);
--	cKin.SetWeeklyTask(nWeeklyTask);
--	local nTaskLevel = cKin.GetTaskLevel();
--	Kin:PerKinMemberWeeklyTask(cKin);
--	local szLog = string.format("家族：%s，所属帮会：无，周目标等级为：%s，上周周目标标号为：%s，新的周目标编号为：%s",
--			cKin.GetName(), nTaskLevel, nTaskTemp,  nWeeklyTask);
--	Dbg:WriteLog("家族维护", szLog);
--	GlobalExcute{"Kin:PerKinWeeklyTask_GS2", nKinId, nOffer, nTaskTemp, nTaskLevel, nWeeklyTask};
--end

-- 获取家族周目标等级
--function Kin:GetWeeklyTaskLevel(cKin)
--	-- local cKin = self.PerKinWeekly_cNextKin;
--	if (not cKin) then
--		return 0;
--	end
--	local nMinLevel = cKin.GetNewTaskLevel();
--	if (nMinLevel == 0) then
--		nMinLevel = cKin.GetTaskLevel();
--		if (nMinLevel == 0) then
--			nMinLevel = Kin.TASK_LEVEL_LOW;
--			cKin.SetTaskLevel(Kin.TASK_LEVEL_LOW);	-- 家族的默认周目标等级是50
--		end
--	elseif (nMinLevel ~= 0) then
--		cKin.SetNewTaskLevel(0);
--		cKin.SetTaskLevel(nMinLevel);	-- 把新的周任务目标等级生效
--	end
--	nMinLevel = cKin.GetTaskLevel();
--	return nMinLevel;
--end

-- 根据家族的周任务目标等级随机可以执行的周任务
--function Kin:RandWeeklyAction(cKin)
--	-- local cKin = self.PerKinWeekly_cNextKin;
--	local nLastAction = 0;
--	local nLastAction = cKin.GetWeeklyTask();
--	local nTaskLevel = self:GetWeeklyTaskLevel(cKin);
--	if (nTaskLevel == Kin.TASK_LEVEL_LOW) then
--		nTaskLevel = 1;
--	elseif (nTaskLevel == Kin.TASK_LEVEL_MID) then
--		nTaskLevel = 2;
--	elseif (nTaskLevel == Kin.TASK_LEVEL_HIGH) then
--		nTaskLevel = 3;
--	else
--		return 0;
--	end
--	local nWeeklyAction = MathRandom(#self.tbWeeklyAction[nTaskLevel]);
--	while nLastAction == nWeeklyAction do	-- 本周任务要和上周任务不同
--		nWeeklyAction = MathRandom(#self.tbWeeklyAction[nTaskLevel]);
--	end
--	if (not nWeeklyAction or nWeeklyAction < 1 or nWeeklyAction > #self.tbWeeklyAction[nTaskLevel]) then
--		return 0;
--	end
--	if (nWeeklyAction == 1 or nWeeklyAction == 2 or nWeeklyAction == 3) then
--		return nWeeklyAction;
--	elseif (nWeeklyAction == 4 and nTaskLevel >= 2) then
--		return nWeeklyAction;
--	elseif (nWeeklyAction == 5 and nTaskLevel == 3) then
--		return nWeeklyAction;
--	else
--		return 0;
--	end
--end
--
--function Kin:SetNewTaskLevel_GC(nKinId , nTaskLevel)
--	local cKin = KKin.GetKin(nKinId);
--	if (not cKin) then
--		return 0;
--	end
--	cKin.SetNewTaskLevel(nTaskLevel);
--	GlobalExcute{"Kin:SetNewTaskLevel_GS2", nKinId , nTaskLevel};
--end
--
--function Kin:SetLWKinOffer0_GC(nKinId, nMemberId, nFigure)
--	local cKin = KKin.GetKin(nKinId);
--	if (not cKin) then
--		return 0;
--	end
--	if (nFigure == 2 and cKin.GetIsCaptainGetAward() == 0) then
--		cKin.SetIsCaptainGetAward(1);
--	end
--	local cMember = cKin.GetMember(nMemberId);
--	if (not cMember) then
--		return 0;
--	end
--	cMember.SetLastWeekKinOffer(0);
--	GlobalExcute{"Kin:SetLWKinOffer0_GS2", nKinId, nMemberId, nFigure};
--end

-- 在第一次gamecenter启动的时候，把家族周活动的流水号初始化为当前周的正确值
function Kin:InitKinWeeklyNo()
--	if (0 == KGblTask.SCGetDbTaskInt(DBTASK_KIN_WEEKLYACTION_NO)) then
--		local nCurNo = tonumber(os.date("%Y%W", GetTime()));
--		KGblTask.SCSetDbTaskInt(DBTASK_KIN_WEEKLYACTION_NO, nCurNo);
--	end
	--新服家族结构变化，正式记名改为60上限
	--if self:CheckNewKin() == 1 then
	--	self.MEMBER_LIMITED = 60;
	--end
end
GCEvent:RegisterGCServerStartFunc(Kin.InitKinWeeklyNo, Kin);

function Kin:SetRecuitmentAutoAgree_GC(nKinId, nMemberId, nAutoAgree)
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	if Kin:CheckSelfRight(nKinId, nMemberId, 2) ~= 1 then
		return 0;
	end
	if nAutoAgree then
		pKin.SetRecruitmentAutoAgree(nAutoAgree);
	end
	GlobalExcute{"Kin:SetRecuitmentAutoAgree_GS2", nKinId, nAutoAgree};
end

-- 发布\取消招募
function Kin:RecruitmentPublish_GC(nKinId, nMemberId, nPublish, nLevel, nHonour, nAutoAgree)
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	if Kin:CheckSelfRight(nKinId, nMemberId, 2) ~= 1 then
		return 0;
	end
	local nRegular, nSigned, nRetire = pKin.GetMemberCount();
	local nMemberLimit, nRetireLimit = self:GetKinMemberLimit(nKinId);
	
	if (nRegular + nSigned + nRetire) >= (nMemberLimit + nRetireLimit) then
		return 0;
	end
	
	if (nRegular + nSigned) >= nMemberLimit then
		return 0;
	end
	if nPublish then
	 	pKin.SetRecruitmentPublish(nPublish);
	end
	if nLevel then
	 	pKin.SetRecruitmentLevel(nLevel);
	end
	if nHonour then
	 	pKin.SetRecruitmentHonour(nHonour);
	end
	if nAutoAgree then
		pKin.SetRecruitmentAutoAgree(nAutoAgree);
	end
	
	pKin.SetRecruitmentPublish(nPublish);
	pKin.SetRecruitmentPublishTime(GetTime());
	GlobalExcute{"Kin:RecruitmentPublish_GS2", nKinId, nPublish, nLevel, nHonour, nAutoAgree};
end

-- 同意招募
function Kin:RecruitmentAgree_GC(nSelfKinId, nSelfMemberId, szName, nKinId)
	local pSelfKin = KKin.GetKin(nSelfKinId);
	if not pSelfKin then
		return 0;
	end
	if Kin:CheckSelfRight(nSelfKinId, nSelfMemberId, 2) ~= 1 then
		return 0;
	end
	local nRegular, nSigned, nRetire = pSelfKin.GetMemberCount();
	local nMemberLimit, nRetireLimit = self:GetKinMemberLimit(nSelfKinId);
	local nMemberCount = nRegular + nSigned;
	
	if (nRegular + nSigned + nRetire) >= (nMemberLimit + nRetireLimit) then
		return 0;
	end
		
	if nMemberCount >= nMemberLimit then
		return 0;
	end
	local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
	if not nPlayerId or nPlayerId <= 0 then
		return 0;
	end
	local nKinId = KGCPlayer.GetKinId(nPlayerId)
	local pKin = KKin.GetKin(nKinId);
	if pKin then
		return 0;
	end
	GlobalExcute{"Kin:RecruitmentAgree_GS2", nSelfKinId, nSelfMemberId, szName, nPlayerId};
end

-- 拒绝招募
function Kin:RecruitmentReject_GC(szName, nKinId, nMemberId)
	local pKin = KKin.GetKin(nKinId)
	if not pKin then
		return 0;
	end
	if Kin:CheckSelfRight(nKinId, nMemberId, 2) ~= 1 then
		return 0;
	end
	local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
	if not nPlayerId or nPlayerId <= 0 then
		return 0;
	end
	KKin.DelKinInductee(nKinId, szName);
	
	GlobalExcute{"Kin:RecruitmentReject_GS2", szName, nKinId, nMemberId};
end

-- 加入招募榜
function Kin:JoinRecruitment_GC(nKinId, nPlayerId)
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	local nPublish =  pKin.GetRecruitmentPublish();
	if nPublish == 0 then
		return;
	end
	local nRegular, nSigned, nRetire = pKin.GetMemberCount();
	local nMemberLimit, nRetireLimit = self:GetKinMemberLimit(nKinId);
	local nMemberCount = nRegular + nSigned;
	if nMemberCount >= nMemberLimit then
		return 0;
	end
	local szName = KGCPlayer.GetPlayerName(nPlayerId);
	if not szName then
		return 0;
	end
	if KKin.GetKinInducteeJoinTime(nKinId, szName) then
		return 0;
	end 
	
	local nTime = GetTime();

	KKin.AddKinInductee(nKinId, nTime, szName);	

	GlobalExcute{ "Kin:JoinRecruitment_GS2", nKinId, nPlayerId, nTime, szName};
end

-- 每日清理家族超时应聘者
function Kin:KinRecruitmenClean(nKinId)
	local nCurTime = GetTime();
	local tbDelKinInducteeList = {};
	if not nKinId or nKinId == 0 then
		return 0;
	end
	local tbKeyList = KKin.GetKinInducteeKeyList(nKinId)
	if not tbKeyList then 
		return 0;
	end
	for i, nKey in pairs(tbKeyList) do
		local szName, nJoinTime = KKin.GetKinInductee(nKinId, nKey);
		if nCurTime - nJoinTime > 7 * 24 * 60 * 60 then
			KKin.DelKinInductee(nKinId, szName);
			table.insert(tbDelKinInducteeList, szName);
		end
	end
	
	GlobalExcute{ "Kin:KinRecruitmenClean_GS2", nKinId, tbDelKinInducteeList};
end

-- 每次打开清理有家族的应聘者
function Kin:KinInducteeClean_GC(nKinId)
	local tbDelKinInducteeList = {};
	local tbKeyList = KKin.GetKinInducteeKeyList(nKinId)
	if not tbKeyList then  -- 程序传不过来 加保护zounan
		return;
	end
	
	for i, nKey in pairs(tbKeyList) do
		local szName, nJoinTime = KKin.GetKinInductee(nKinId, nKey);
		local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
		local nTagetKinId = KGCPlayer.GetKinId(nPlayerId);
		local pTagetKin = KKin.GetKin(nTagetKinId);
		if pTagetKin and nTagetKinId ~= 0 then
			KKin.DelKinInductee(nKinId, szName);
			table.insert(tbDelKinInducteeList, szName);
		end
	end
	GlobalExcute{ "Kin:KinRecruitmenClean_GS2", nKinId, tbDelKinInducteeList};
end

-- 每周清理家族招募榜
function Kin:CleanKinRecruitmenPublish(nKinId)
	local nCurTime = GetTime();
	if nCurTime < os.time({year=2010, month=1, day=17}) then		-- 1月12日前发布的家族招募榜的给7天发布期
		return
	end
	local pCurKin = KKin.GetKin(nKinId);
	if not pCurKin then
		return;
	end
	if pCurKin.GetRecruitmentPublish() == 0 then
		return;
	end
    if nCurTime - pCurKin.GetRecruitmentPublishTime() > self.KIN_RECRUITMENT_PUBLISH_TIME then
        pCurKin.SetRecruitmentPublish(0);
        GlobalExcute{ "Kin:CleanKinRecruitmenPublish_GS2", nKinId};
    end
end

function Kin:StorageFundToTong_GC(nPlayerId, nKinId, nMemberId, nTongId, nMoney)
	local cKin = KKin.GetKin(nKinId);
	if (not cKin) then
		return 0;
	end
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	if (Kin:CheckSelfRight(nKinId, nMemberId, 1) ~= 1) then
		return 0;
	end
	local tbSalaryData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_SALARY);
	if tbSalaryData.nApplyEvent and tbSalaryData.nApplyEvent == 1 then
		return 0;
	end
	local tbData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_TAKE_FUND);
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
		return 0;
	end
	if tbData.nLastStorageTime and GetTime() - tbData.nLastStorageTime < self.STORAGE_FUND_TIME then
		return 0 ;
	end
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	local szKinName = cKin.GetName();
	local szTongName = cTong.GetName();
	local nCurKinFund = cKin.GetMoneyFund();
	local nCurTongFund = cTong.GetMoneyFund();
	if nMoney > nCurKinFund or nMoney + nCurTongFund > Tong.MAX_TONG_FUND then
		Dbg:WriteLog("Error!!", "Kin:StorageFundToTong_GC", szPlayerName, "Failed to storage " .. nMoney);
		return 0;
	end
	tbData.nLastStorageTime = GetTime();
	local nKinFund = nCurKinFund - nMoney;
	local nTongFund = nCurTongFund + nMoney;
	cKin.SetMoneyFund(nKinFund);
	cTong.SetMoneyFund(nTongFund);
	self.nJourNum = self.nJourNum + 1;
	Tong.nJourNum = Tong.nJourNum + 1;
	cTong.SetTongDataVer(Tong.nJourNum);
	cKin.SetKinDataVer(self.nJourNum);
	if nMoney >= self.STORAGE_FUND_TO_TONG then
		cTong.AddAffairGetFundFromKin(szKinName, tostring(nMoney));
		cKin.AddAffairStorageFundToTong(szPlayerName, szTongName, tostring(nMoney));
	end
	if (nMoney >= 50000) then
		_G.TongLog(szTongName, Log.emKTONG_LOG_TONGFUND, szKinName .. "家族的" .. szPlayerName.. "向帮会转存 ".. nMoney .. "两家族资金");
		_G.KinLog(szKinName, Log.emKKIN_LOG_TYPE_KINFUND, szTongName .. "从家族转出" .. nMoney .. "两家族资金到"  .. szTongName .. "帮会");
		Dbg:WriteLog("家族资金", "家族名字：" .. szKinName, "申请人:" .. szPlayerName, "目标帮会：" .. szTongName, "资金数额:" .. nMoney);
	end
	GlobalExcute{"Kin:StorageFundToTong_GS2", nPlayerId, nKinId, nTongId, self.nJourNum, Tong.nJourNum, nKinFund, nTongFund, nMoney};
end

function Kin:AddFund_GC(nKinId, nPlayerId, nMoney)	
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	
	local szPlayerName = "系统";
	if nPlayerId > 0 then
		szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	end
	local szKinName = cKin.GetName();
	local nCurMoney = cKin.GetMoneyFund() + nMoney;
	if nCurMoney > self.MAX_KIN_FUND then
		Dbg:WriteLog("Error!!", "Kin:AddFund_GC", szPlayerName, "Failed to add " .. nMoney);
		return 0;
	end
	cKin.SetMoneyFund(nCurMoney);
	self.nJourNum = self.nJourNum + 1;
	cKin.SetKinDataVer(self.nJourNum);
	if nMoney >= self.TAKE_FUND_APPLY then
		cKin.AddAffairSaveFund(szPlayerName, tostring(nMoney));
	end
	if (nMoney >= 50000) then
		_G.KinLog(szKinName, Log.emKKIN_LOG_TYPE_KINFUND, szPlayerName .. "存入" .. nMoney .. "家族资金");
		if nPlayerId > 0 then
			KGCPlayer.PlayerLog(nPlayerId, Log.emKPLAYERLOG_TYPE_KINPAYOFF, "["..szPlayerName.."] 向家族 [".. szKinName .."] 存入银两".. nMoney .. "家族资金");
		end
		Dbg:WriteLog("家族资金", "家族名字：" .. szKinName, "存钱", "存钱人：" .. szPlayerName, "金额：" .. nMoney);
	end	
	GlobalExcute{"Kin:AddFund_GS2", nKinId, self.nJourNum, nPlayerId, nCurMoney, nMoney};
end

function Kin:ApplyTakeFund_GC(nKinId, nMemberId, nPlayerId, nMoney)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local tbSalaryData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_SALARY);
	if tbSalaryData.nApplyEvent and tbSalaryData.nApplyEvent == 1 then
		return 0;
	end
	local tbData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_TAKE_FUND);
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
		return 0;
	end
	if tbData.nLastTime and GetTime() - tbData.nLastTime < self.TAKE_FUND_TIME then
		return 0;
	end
	local nCurFund = cKin.GetMoneyFund();
	if (nMoney > nCurFund) then
		return 0;
	end
	if self:CheckSelfRight(nKinId, nMemberId, self.FIGURE_CAPTAIN) ~= 1 then --非族长取钱需要族长同意
		tbData.nApplyEvent = 1;
		if not tbData.tbApplyRecord then
			tbData.tbApplyRecord = {};
		end
		tbData.tbApplyRecord.nMemberId = nMemberId;
		tbData.tbApplyRecord.nAmount = nMoney;
		tbData.tbApplyRecord.nPow = self.FIGURE_CAPTAIN;
		tbData.tbAccept = {};
		tbData.nAgreeCount = 1;
		tbData.tbApplyRecord.nTimerId = Timer:Register(
			self.TAKE_FUND_APPLY_LAST,
			self.CancelExclusiveEvent_GC,
			self,
			nKinId,
			self.KIN_EVENT_TAKE_FUND
			);
		return GlobalExcute{"Kin:ApplyTakeFund_GS2",
			0,
			nKinId,
			nMemberId,
			nPlayerId,
			nMoney,
			self.FIGURE_CAPTAIN,
			};
	end
	if self:CheckSelfRight(nKinId, nMemberId, self.FIGURE_CAPTAIN) == 1 then--族长直接取钱,需要两名正式成员同意
		tbData.nApplyEvent = 1;
		if not tbData.tbApplyRecord then
			tbData.tbApplyRecord = {};
		end
		tbData.tbApplyRecord.nMemberId = nMemberId;
		tbData.tbApplyRecord.nAmount = nMoney;
		tbData.tbApplyRecord.nPow = self.FIGURE_REGULAR;
		tbData.tbAccept = {};
		tbData.nAgreeCount = 2;
		tbData.tbApplyRecord.nTimerId = Timer:Register(
			self.TAKE_FUND_APPLY_LAST,
			self.CancelExclusiveEvent_GC,
			self,
			nKinId,
			self.KIN_EVENT_TAKE_FUND
			);
		return GlobalExcute{"Kin:ApplyTakeFund_GS2",
			1,
			nKinId,
			nMemberId,
			nPlayerId,
			nMoney,
			};
	end
	--return GlobalExcute{"Kin:FindPlayerAddMoney_GS", nKinId, nMoney, nPlayerId};
end

function Kin:TakeFund_GC(nKinId, nMoney, nPlayerId)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		GlobalExcute{"Kin:FailureToUnLock", nPlayerId};
		return 0;
	end
	local tbData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_TAKE_FUND);
	if tbData.nLastTime and GetTime() - tbData.nLastTime < self.TAKE_FUND_TIME then
		GlobalExcute{"Kin:FailureToUnLock", nPlayerId};
		return 0;
	end
	local nCurFund = cKin.GetMoneyFund();
	if nMoney <= nCurFund and nMoney > 0 then
		nCurFund = nCurFund - nMoney;
		cKin.SetMoneyFund(nCurFund);
		self.nJourNum = self.nJourNum + 1;
		cKin.SetKinDataVer(self.nJourNum);
		tbData.nLastTime = GetTime();
		local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
		local szKinName = cKin.GetName();
		if nMoney >= self.TAKE_FUND_APPLY then
			cKin.AddAffairTakeFund(szPlayerName, tostring(nMoney));
		end
		if nMoney > 10000 then
			_G.KinLog(szKinName, Log.emKKIN_LOG_TYPE_KINFUND, szPlayerName .. " 取出 ".. nMoney .. "家族资金");
			Dbg:WriteLog("家族资金", "家族名字：" .. szKinName, "取钱",  "取钱人：" .. szPlayerName, "金额：" .. nMoney);
		end
		GlobalExcute{"Kin:TakeFund_GS2", nKinId, nPlayerId, self.nJourNum, nMoney, nCurFund};
	else
		GlobalExcute{"Kin:FailureToUnLock", nPlayerId};
	end
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
		if tbData.tbApplyRecord and tbData.tbApplyRecord.nTimerId then
			Timer:Close(tbData.tbApplyRecord.nTimerId);
		end
		self:DelExclusiveEvent(nKinId, self.KIN_EVENT_TAKE_FUND);
	end
end

-- 超时删除申请资金事件
function Kin:CancelExclusiveEvent_GC(nKinId, nEventId)
	self:DelExclusiveEvent(nKinId, nEventId);
	return 0;
end

function Kin:AcceptExclusiveEvent_GC(nKey, nPlayerId, nKinId, nMemberId, nAccept, nAppleyMemberId)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	
	local tbData = self:GetExclusiveEvent(nKinId, nKey);
	if not tbData.nApplyEvent or tbData.nApplyEvent == 0 then
		return 0;
	end
	if tbData.tbApplyRecord.nMemberId == nMemberId then --表决人是发起人不需要表决
		return 0;
	end
	if tbData.tbApplyRecord.nMemberId ~= nAppleyMemberId then
		return 0;
	end
	local cMember = cKin.GetMember(nAppleyMemberId); 
	if not cMember then
		return 0;
	end
	if nKey == self.KIN_EVENT_TAKE_REPOSITORY then -- 家族仓库的权限判断
		if KinRepository:CheckRepAuthority(nKinId, nMemberId, tbData.tbApplyRecord.nPow) ~= 1 then
			return 0;
		end
	else
		if (Kin:CheckSelfRight(nKinId, nMemberId, tbData.tbApplyRecord.nPow) ~= 1) then
			return 0;
		end
	end
	if not tbData.tbAccept then
		tbData.tbAccept = {};
	end
	if tbData.tbAccept[nMemberId] then
		return 0;
	end
	tbData.tbAccept[nMemberId] = nAccept;
	if not tbData.nCount then
		tbData.nCount = 0;
	end
	if nAccept == 1 then
		tbData.nCount = tbData.nCount + 1;
	end
	GlobalExcute{"Kin:AcceptExclusiveEvent_GS2",
		nKey,
		nPlayerId,
		nKinId,
		nMemberId,
		nAccept
		};
	-- 判断是否通过了申请，执行操作
	if nKey ==  self.KIN_EVENT_TAKE_FUND then
		if tbData.nCount < tbData.nAgreeCount then
			if tbData.tbApplyRecord.nPow == self.FIGURE_CAPTAIN then -- 如果是成员取钱，则只要族长拒绝就取消这个申请
				return self:CanCelMemberTakeFund_GC(nKinId, nPlayerId);
			end
			return 0;
		end
		local nTakePlayerId = cMember.GetPlayerId();
		return GlobalExcute{"Kin:FindPlayerAddMoney_GS", nKinId, tbData.tbApplyRecord.nAmount, nTakePlayerId};
	elseif nKey == self.KIN_EVENT_SALARY then
		if tbData.nCount < tbData.nAgreeCount then 
			return 0;
		end
		return self:SendSalary_GC(nKinId);
	elseif nKey == self.KIN_EVENT_TAKE_REPOSITORY then
		if tbData.nCount < tbData.nAgreeCount then
			return 0;
		end
		return KinRepository:AgreeTakeAuthority_GC(nKinId, tbData.tbApplyRecord.nMemberId, tbData.tbApplyRecord.nPlayerId);
	elseif nKey == self.KIN_EVENT_BUYBADGE then
		-- 购买徽章
		if tbData.nCount < tbData.nAgreeCount then
			return 0;
		end
		self:BuyBadge_GC(nKinId, tbData.tbApplyRecord.nMemberId, tbData.tbApplyRecord.nPlayerId, tbData.tbApplyRecord.nAmount, tbData.tbApplyRecord.nRecord, tbData.tbApplyRecord.nRate);
	else
		return 0;
	end
end

function Kin:CanCelMemberTakeFund_GC(nKinId, nPlayerId)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local tbData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_TAKE_FUND);
	tbData.nLastTime = GetTime();
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
		if tbData.tbApplyRecord and tbData.tbApplyRecord.nTimerId then
			Timer:Close(tbData.tbApplyRecord.nTimerId);
		end
		self:DelExclusiveEvent(nKinId, self.KIN_EVENT_TAKE_FUND);
	end
	return GlobalExcute{"Kin:CanCelMemberTakeFund_GS2", nKinId, nPlayerId};
end

function Kin:SaveSalaryCount_GC(nPlayerId, nKinId, nMemberId, tbMember)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	if (Kin:CheckSelfRight(nKinId, nMemberId, 2) ~= 1) then
		return 0;
	end
	local tbSalaryData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_SALARY);
	if tbSalaryData.nApplyEvent and tbSalaryData.nApplyEvent == 1 then
		return 0;
	end
	local cMemberIt = cKin.GetMemberItor();
	local cMember = cMemberIt.GetCurMember();
	local nMemberId = cMemberIt.GetCurMemberId();
	while cMember do
		local nAttendance = tbMember[nMemberId];
		if (not nAttendance or 0 == Lib:IsInteger(nAttendance) or nAttendance < 0 or nAttendance > 1000000) then
			return 0;
		end
		cMember.SetAttendance(nAttendance);
		cMember = cMemberIt.NextMember();
		nMemberId = cMemberIt.GetCurMemberId();
	end
	GlobalExcute{"Kin:SaveSalaryCount_GS2", nPlayerId, nKinId, tbMember};
end

function Kin:ClearSalaryCount_GC(nPlayerId, nKinId, nMemberId)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	if (Kin:CheckSelfRight(nKinId, nMemberId, 2) ~= 1) then
		return 0;
	end
	local tbSalaryData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_SALARY);
	if tbSalaryData.nApplyEvent and tbSalaryData.nApplyEvent == 1 then
		return 0;
	end
	local cMemberIt = cKin.GetMemberItor();
	local cMember = cMemberIt.GetCurMember();
	while cMember do
		cMember.SetAttendance(0);
		cMember = cMemberIt.NextMember();
	end
	GlobalExcute{"Kin:ClearSalaryCount_GS2", nPlayerId, nKinId};
end

function Kin:ApplySendSalary_GC(nPlayerId, nKinId, nMemberId, tbMember, nAttendanceAward)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	if (Kin:CheckSelfRight(nKinId, nMemberId, 1) ~= 1) then
		return 0;
	end
	local nCheck, nAttendanceCount, tbSalary = self:CheckClientMember(nKinId, tbMember);
	if nCheck ~= 1 then
		return 0;
	end
	if nAttendanceCount == 0 then
		return 0;
	end
	local tbTakeFundData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_TAKE_FUND);
	if tbTakeFundData.nApplyEvent and tbTakeFundData.nApplyEvent == 1 then
		return 0;
	end
	local tbData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_SALARY);
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
		return 0;
	end
	local nLastSalaryTime = cKin.GetLastSalaryTime();
	if GetTime() - nLastSalaryTime < self.SEND_SALARY_TIME then
		return 0;
	end
	local nFund = cKin.GetMoneyFund();
	local nMoney = nAttendanceCount * nAttendanceAward;
	local nCurFund = nFund - nMoney;
	if nCurFund < 0 then 
		return 0;
	end
	tbData.nApplyEvent = 1;
	if not tbData.tbApplyRecord then
		tbData.tbApplyRecord = {};
	end
	tbData.tbApplyRecord.nMemberId = nMemberId;
	tbData.tbApplyRecord.nAmount = nMoney;
	tbData.tbApplyRecord.nPow = self.FIGURE_REGULAR;
	tbData.tbApplyRecord.nAttendanceAward = nAttendanceAward;
	tbData.tbApplyRecord.tbSalary = tbSalary;
	tbData.tbAccept = {};
	tbData.nAgreeCount = 2;
	tbData.tbApplyRecord.nTimerId = Timer:Register(
		self.TAKE_FUND_APPLY_LAST,
		self.CancelExclusiveEvent_GC,
		self,
		nKinId,
		self.KIN_EVENT_SALARY
		);
	GlobalExcute{"Kin:ApplySendSalary_GS2", nPlayerId, nKinId, nMemberId, nMoney, nAttendanceAward};
end

function Kin:CheckClientMember(nKinId, tbClientMember)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0, -1;
	end
	local tbSalary = {};
	local nAttendanceCount = 0;
	local cMemberIt = cKin.GetMemberItor();
	local cMember = cMemberIt.GetCurMember();
	local nMemberId = cMemberIt.GetCurMemberId();
	while cMember do
		local nAttendance = cMember.GetAttendance();
		if not tbClientMember[nMemberId] or tbClientMember[nMemberId] ~= nAttendance then
			return 0, -1;
		end
		local nPlayerId = cMember.GetPlayerId();
		tbSalary[nMemberId] = {};
		tbSalary[nMemberId].nPlayerId = nPlayerId;
		tbSalary[nMemberId].nAttendance = nAttendance;
		nAttendanceCount = nAttendanceCount + nAttendance;
		cMember = cMemberIt.NextMember();
		nMemberId = cMemberIt.GetCurMemberId();
	end
	return 1, nAttendanceCount, tbSalary;
end


function Kin:SendSalary_GC(nKinId)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local tbData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_SALARY);
	local nMemberId = tbData.tbApplyRecord.nMemberId;
	local nAttendanceAward = tbData.tbApplyRecord.nAttendanceAward;
	local tbSalary = tbData.tbApplyRecord.tbSalary;
	local nMoney = tbData.tbApplyRecord.nAmount;
	local nFund = cKin.GetMoneyFund();
	local nCurFund = nFund - nMoney;
	if nCurFund < 0 then 
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId);
	if not cMember then
		return 0;
	end
	cKin.SetMoneyFund(nCurFund);
	local nLastSalaryTime = GetTime();
	cKin.SetLastSalaryTime(nLastSalaryTime);
	self.nJourNum = self.nJourNum + 1;
	cKin.SetKinDataVer(self.nJourNum);
	
	local nPlayerId = cMember.GetPlayerId();
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	local szKinName = cKin.GetName();
	if nMoney >= self.TAKE_FUND_APPLY then
		cKin.AddAffairSaveFund(szPlayerName, tostring(nMoney));
	end
	if (nMoney >= 50000) then
		_G.KinLog(szKinName, Log.emKKIN_LOG_TYPE_KINFUND, szPlayerName .. "发放工资" .. nMoney .. "两");
		Dbg:WriteLog("家族资金", "家族名字：" .. szKinName, "发工资", "操作人：" .. szPlayerName, "金额：" .. nMoney);
	end
	local szTotalSalary = Lib:FormatMoney(nMoney);
	local szAward = Lib:FormatMoney(nAttendanceAward);
	for nMemberId, tbMemberData in pairs(tbSalary) do
		local szNameTo = KGCPlayer.GetPlayerName(tbMemberData.nPlayerId);
		local nSalary = tbMemberData.nAttendance * nAttendanceAward;
		local szTitle = "家族出勤奖励";
		local szSalary = Lib:FormatMoney(nSalary);
		local szContent = "族长已发放了出勤奖励（共" .. szTotalSalary .. "两），以下是您的出勤奖励，请您查收\n<color=green>单次出勤奖励：<color><color=yellow>" .. szAward .. "两<color>\n<color=green>您的出勤次数：<color><color=yellow>" .. tbMemberData.nAttendance .. "次<color>\n<color=green>您的出勤奖励：<color><color=yellow>" .. szSalary .. "两<color>\n";
		SendMailWithMoneyGC(szNameTo, szTitle, szContent, nSalary);
		if nSalary >= 50000 then
			Dbg:WriteLog(szNameTo, "工资邮件", "工资金额：" .. nSalary);
		end
	end
	GlobalExcute{"Kin:SendSalary_GS2", self.nJourNum, nPlayerId, nKinId, nCurFund, nMoney, nLastSalaryTime, tbSalary};
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
		if tbData.tbApplyRecord and tbData.tbApplyRecord.nTimerId then
			Timer:Close(tbData.tbApplyRecord.nTimerId);
		end
		self:DelExclusiveEvent(nKinId, self.KIN_EVENT_SALARY);
	end
end

local function _OnSort(tbA, tbB)
	return tbA.nRankPoint > tbB.nRankPoint;
end

-- 处理一些家族里统计数据的函数，统计金牌家族积分
function Kin:ProcessKinDaliyTotalEvent()
	local nSec = tonumber(KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME));
	local nDate = tonumber(os.date("%Y%m", nSec));
	--只记录201203开服的服务器
	if nDate ~= Kin.GOLD_LS_SERVERDAY then
		return;
	end
	local pKin, nKinId = KKin.GetNextKin(0);
	local tbKinDaliyDate		= {};
	local nTotalMoneyHonor		= 0;
	local nTotalBaiHuTangKill	= 0;
	
	while pKin do
		--只有金牌家族才记录
		local tbKinInfo	= {};
		local szKinName	= pKin.GetName();
		local nKinGrade	= self:ProcessKinTotalGrade(szKinName);
		if pKin.GetGoldLogo() == 1 then
			tbKinInfo.szKinName = szKinName;
			tbKinInfo.nRankPoint = nKinGrade;
			tbKinInfo.nMemberCount = pKin.nMemberCount;
			tbKinDaliyDate[#tbKinDaliyDate + 1] = tbKinInfo;
		end
		
		pKin, nKinId = KKin.GetNextKin(nKinId);
	end	
	table.sort(tbKinDaliyDate, _OnSort);
	
	self:WriteKinDayliDateFile(tbKinDaliyDate);
end


function Kin:WriteKinDayliDateFile(tbKinDaliyDate)
	local szGateway	= GetGatewayName();
	local szFile = "\\kindaliydate\\"..szGateway.."_kindaliydate.txt";
	local szMsg = "Gateway\tRank\tKinName\tPlayerCount\tGrade\n";

	if (not tbKinDaliyDate) then
		print("[KIN] ERROR WriteKinDayliDateFile 没有家族每日数据");
		return 0;
	end
	
	KFile.WriteFile(szFile, szMsg);
	local nOutCount = 0;
	for i, tbKin in ipairs(tbKinDaliyDate) do
		local szInfo = string.format("%s\t%s\t%s\t%s\t%s\n", szGateway, i, tbKin.szKinName, tbKin.nMemberCount, tbKin.nRankPoint);		
		KFile.AppendFile(szFile, szInfo);
	
	end
	return 1;
end

function Kin:ProcessKinTotalGrade(szKinName)
	local nTotalGrade = 0;
	local pKin = KKin.FindKin(szKinName);
	if (pKin) then
		local itor = pKin.GetMemberItor();
		local cMember = itor.GetCurMember();
		while cMember do
			--非记名成员才算分
			if cMember.GetFigure() > 0 and cMember.GetFigure() ~= 4 then
				local nPlayerId = cMember.GetPlayerId();
				local nGrade	= cMember.GetGoldLS();
				nTotalGrade = nTotalGrade + nGrade;
			end
			--周一统计的时候顺便清空
			if tonumber(GetLocalDate("%w")) == 1 then
				cMember.SetGoldLS(0);
			end
			cMember = itor.NextMember();
		end
		if tonumber(GetLocalDate("%w")) == 1 then
			GlobalExcute({"Kin:ClearGoldDate_GS", KKin.GetKinNameId(szKinName)})
		end
	end
	return nTotalGrade;
end

function Kin:GetFileHistoryInfoList(nDate, nSRank, nERank)
	local nSec = Lib:GetDate2Time(nDate)
	local szTime = os.date("%Y_%m_%d",nSec);
	self.tbKinDaliyInfoDate = self.tbKinDaliyInfoDate or {};
	self.tbKinDaliyInfoDate[nDate] = self.tbKinDaliyInfoDate[nDate] or {};

	local szFile = "\\log\\gamecenter\\" .. szTime .. "\\kindaliydate.txt";

	-- "排名\t家族名\t家族人数\t家族财富荣誉\t家族白虎堂击杀总数\t家族财富权值\t家族白虎堂击杀总数权值\t家族排名积分\n"
	local tbFileTitle = {
		["nRank"]					="排名",
		["szKinName"]				="家族名",
		["nMemberCount"]			="家族人数",
		["nTotalMoneyHonor"]		="家族财富荣誉",
		["nTotalBaiHuTangKill"]		="家族白虎堂击杀总数",
		["nWeight_MoneyHonor"]		="家族财富权值",
		["nWeight_BaiHuTang"]		="家族白虎堂击杀总数权值",
		["nRankPoint"]				="家族排名积分",
	};

	if not self.tbKinDaliyInfoDate[nDate].tbRankList then
		local tbFileData = Lib:LoadTabFile(szFile)
		if not tbFileData then
			return "该日期的历史数据不存在";
		end
		local tbRankList = {};
		for _, tbData in pairs(tbFileData) do
			local tbInfo = {};
			for szKey, szTitle in pairs(tbFileTitle) do
				tbInfo[szKey] = tbData[szTitle];
				if (szKey ~= "szKinName") then
					tbInfo[szKey] = tonumber(tbInfo[szKey]);
				end
			end
			if (tbInfo.nRank) then
				tbRankList[tbInfo.nRank] = tbInfo;
			end
		end
		self.tbKinDaliyInfoDate[nDate].tbRankList = tbRankList;
	end
	if not self.tbKinDaliyInfoDate[nDate].tbRankList then
		return "该日期的历史数据不存在";
	end
	
	local tbRankList = self.tbKinDaliyInfoDate[nDate].tbRankList;

	nSRank = nSRank or 0;
	nERank = nERank or 50;
	if nSRank > nERank then
		nSRank, nERank = nERank, nSRank;
	end
	local szResult = "排名\t家族名\t家族人数\t家族财富荣誉\t家族白虎堂击杀总数\t家族财富权值\t家族白虎堂击杀总数权值\t家族排名积分\n"
	for nRank, tbInfo in pairs(tbRankList) do
		if (nRank > nSRank and nRank <= nERank) then
			local szInfo = string.format("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", nRank, tbInfo.szKinName, tbInfo.nMemberCount, tbInfo.nTotalMoneyHonor, tbInfo.nTotalBaiHuTangKill, tbInfo.nWeight_MoneyHonor, tbInfo.nWeight_BaiHuTang, tbInfo.nRankPoint);
			szResult = szResult .. szInfo;
		end
	end

	return szResult
end

function Kin:AddKinKillBaiHuTangCount_GC(nPlayerId, nNum)
	-- 杀死boss会给家族增加一次本日击杀boss个数
	local dwKinId, nMemberId = KKin.GetPlayerKinMember(nPlayerId);
	print("AddKinKillBaiHuTangCount_GC(nPlayerId, nNum) ", nPlayerId, nNum);
	if (dwKinId > 0) then
		local pKin = KKin.GetKin(dwKinId);
		if (pKin) then
			local nCount = pKin.GetBaiHuTangKillNum();
			pKin.SetBaiHuTangKillNum(nCount + nNum);
		end		
	end
	GlobalExcute{"Kin:AddKinKillBaiHuTangCount_GS", nPlayerId, nNum};
	return 1;
end

function Kin:WriteLogKinInfo()	
	local PerKinEvents_cNextKin, PerKinEvents_nNextKin = KKin.GetFirstKin();
	local nCount = 1;
	while (PerKinEvents_cNextKin and nCount <= 100000) do		
		local pKin = KKin.GetKin(PerKinEvents_nNextKin);		
		if pKin and pKin.GetMoneyFund() >= 1000000 then 
			local pTong = KTong.GetTong(pKin.GetBelongTong());	
			StatLog:WriteStatLog("stat_info", "jiazu", "zijin", 0, string.format("%s,%s,%s", pKin.GetName(), pTong and pTong.GetName() or "nil", pKin.GetMoneyFund()));
		end
		nCount = nCount + 1;
		PerKinEvents_cNextKin, PerKinEvents_nNextKin = KKin.GetNextKin(PerKinEvents_nNextKin);
	end
end

-- 设置YY号
function Kin:SetYYNumber_GC(nKinId, nExcutorId, nYYNumber)
	local nRet, cKin = self:CheckSelfRight(nKinId, nExcutorId, 2);
	if nRet ~= 1 then
		return 0;
	end
	cKin.SetYYNumber(nYYNumber);	
	return GlobalExcute{"Kin:SetYYNumber_GS2", nKinId, nYYNumber};
end

function Kin:AddGoldLSTask_GC(nKinId, nExcutorId, nPoint)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local cMember = cKin.GetMember(nExcutorId);
	if not cMember then
		return 0
	end
	local nTotalPoint = cMember.GetGoldLS();
	cMember.SetGoldLS(nTotalPoint + nPoint);
	return GlobalExcute{"Kin:AddGoldLSTask", nKinId, nExcutorId, nPoint};
end

function Kin:SetGoldFlag(nKinId)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	cKin.SetGoldLogo(1);
	return GlobalExcute{"Kin:SetGoldFlag", nKinId};
end

GCEvent:RegisterGCServerShutDownFunc(Kin.WriteLogKinInfo, Kin);

-- 设置家族徽章
function Kin:SetKinBadge_GC(nKinId, nExcutorId, nPlayerId, nSelectBadge, nType)
	local nRet, cKin = self:CheckSelfRight(nKinId, nExcutorId, 2);
	if nRet ~= 1 then
		return 0;
	end
	local nRecord = 0;
	local nRecord = 0;
	local nRegular, nSigned, nRetire = cKin.GetMemberCount()
	if nType == 1 then
		nRecord = cKin.GetBadgeRecord1();
	elseif nType == 2 then
		nRecord = cKin.GetBadgeRecord2();
		if nRegular < self.nBuyLimitPlayerCount2 then
			return 0;
		end
	elseif nType == 3 then
		nRecord = cKin.GetBadgeRecord3();
		if nRegular < self.nBuyLimitPlayerCount3 then
			return 0;
		end
	end
	if nType ~= 1 or nSelectBadge ~=1 then
		if Lib:LoadBits(nRecord, nSelectBadge - 1,nSelectBadge - 1) ~= 1 then
			return 0;
		end
	end
	cKin.SetKinBadge(nType*10000 + nSelectBadge);
	return GlobalExcute{"Kin:SetKinBadge_GS2", nKinId, nPlayerId, nSelectBadge, nType};
end

-- 购买家族徽章
function Kin:ApplyBuyBadge_GC(nKinId, nMemberId, nPlayerId, nRecord, nRate)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	--购买条件及是否已经购买
	local nRecordEx = 0;
	local nRegular, nSigned, nRetire = cKin.GetMemberCount()
	if nRate == 1 then
		nRecordEx = cKin.GetBadgeRecord1();
	elseif nRate == 2 then
		nRecordEx = cKin.GetBadgeRecord2();
		if nRegular < self.nBuyLimitPlayerCount2 then
			return 0;
		end
	elseif nRate == 3 then
		nRecordEx = cKin.GetBadgeRecord3();
		if nRegular < self.nBuyLimitPlayerCount3 then
			return 0;
		end
	end
	if Lib:LoadBits(nRecordEx, nRecord - 1, nRecord - 1) == 1 then
		return 0;
	end
	--申请情况判断
	local tbData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_BUYBADGE);
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
		return 0;
	end
	if tbData.nLastTime and GetTime() - tbData.nLastTime < self.TAKE_FUND_TIME then
		return 0;
	end
	local nCurFund = cKin.GetMoneyFund();
	local nMoney = self.BADGE_LEVEL_PRICE[nRate];
	if (nMoney > nCurFund) then
		return 0;
	end
	--族长取钱购买徽章,需要两名正式成员同意
	tbData.nApplyEvent = 1;
	if not tbData.tbApplyRecord then
		tbData.tbApplyRecord = {};
	end
	tbData.tbApplyRecord.nMemberId = nMemberId;
	tbData.tbApplyRecord.nAmount = nMoney;	-- 购买徽章需要银两
	tbData.tbApplyRecord.nPlayerId = nPlayerId;	-- 申请人id
	tbData.tbApplyRecord.nRate	 = nRate;		-- 购买的徽章级数
	tbData.tbApplyRecord.nRecord = nRecord;	-- 购买徽章记录
	tbData.tbApplyRecord.nPow = self.FIGURE_REGULAR;
	tbData.tbAccept = {};
	tbData.nAgreeCount = 2;
	tbData.tbApplyRecord.nTimerId = Timer:Register(self.TAKE_FUND_APPLY_LAST, self.CancelExclusiveEvent_GC, self, nKinId, self.KIN_EVENT_BUYBADGE);
	return GlobalExcute{"Kin:ApplyBuyBadge_GS2", nKinId, nMemberId, nPlayerId, nRecord, nRate};
end

function Kin:BuyBadge_GC(nKinId, nMemberId, nPlayerId, nMoney, nRecord, nRate)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local tbData = self:GetExclusiveEvent(nKinId, self.KIN_EVENT_BUYBADGE);
	if tbData.nLastTime and GetTime() - tbData.nLastTime < self.TAKE_FUND_TIME then
		return 0;
	end
	local nCurFund = cKin.GetMoneyFund();
	if nMoney <= nCurFund and nMoney > 0 then
		nCurFund = nCurFund - nMoney;
		cKin.SetMoneyFund(nCurFund);	-- 取钱
		-- 记录购买徽章
		if nRate == 1 then
			local nRecordEx = cKin.GetBadgeRecord1();
			cKin.SetBadgeRecord1(Lib:SetBits(nRecordEx, 1, nRecord - 1, nRecord - 1));
		elseif nRate == 2 then
			local nRecordEx = cKin.GetBadgeRecord2();
			cKin.SetBadgeRecord2(Lib:SetBits(nRecordEx, 1, nRecord - 1, nRecord - 1));
		else
			local nRecordEx = cKin.GetBadgeRecord3();
			cKin.SetBadgeRecord3(Lib:SetBits(nRecordEx, 1, nRecord - 1, nRecord - 1));
		end

		tbData.nLastTime = GetTime();
		local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
		local szKinName = cKin.GetName();
		
		_G.KinLog(szKinName, Log.emKKIN_LOG_TYPE_KINFUND, szPlayerName .. " 取出 ".. nMoney .. "家族资金，购买了一个" .. nRate .. "级徽章："..nRecord);
		Dbg:WriteLog("家族资金", "家族名字：" .. szKinName, "消费",  "取钱人：" .. szPlayerName, "金额：" .. nMoney, "购买了一个" .. nRate .. "级徽章："..nRecord);

		GlobalExcute{"Kin:BuyBadge_GS2", nKinId, nMemberId, nPlayerId, nMoney, nRecord, nRate};
	end
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
		if tbData.tbApplyRecord and tbData.tbApplyRecord.nTimerId then
			Timer:Close(tbData.tbApplyRecord.nTimerId);
		end
		self:DelExclusiveEvent(nKinId, self.KIN_EVENT_BUYBADGE);
	end
end

-- 每日族徽操作
function Kin:SysChangeKinBadge(nKinId)
	if not nKinId or nKinId == 0 then
		return 0;
	end
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0;
	end
	local nRegular, nSigned, nRetire = cKin.GetMemberCount()
	local nSelectBadge = cKin.GetKinBadge();
	local nLevel = math.floor(nSelectBadge / 10000);
	
	if (nLevel == 3 and nRegular < self.nBuyLimitPlayerCount3) or (nLevel == 2 and nRegular < self.nBuyLimitPlayerCount2) then
		cKin.SetKinBadge(10001);
		GlobalExcute{ "Kin:SysChangeKinBadge", nKinId};
	end
end

-- 记录玩家下线时间
function Kin:SetLastLogOutTime_GC(nKinId, nMemberId, nTime)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0
	end
	if nTime < 0 then
		return 0;
	end
	cMember.SetLastLogOutTime(nTime);
	GlobalExcute{"Kin:SetLastLogOutTime_GS", nKinId, nMemberId, nTime};
end