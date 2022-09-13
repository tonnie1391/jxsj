-------------------------------------------------------------------
--File: tonglogic_gc.lua
--Author: lbh
--Date: 2007-9-6 11:24
--Describe: gamecenter帮会逻辑
-------------------------------------------------------------------
if not Tong then --调试需要
	Tong = {}
	print(GetLocalDate("%Y\\%m\\%d  %H:%M:%S").." build ok ..")
else
	if not MODULE_GC_SERVER then
		return
	end
end

--更换帮主,nSync 为是否同步，1同步，2不同步，默认（不填）同步
function Tong:ChangeMaster_GC(nTongId, nKinId, nExcutorId, nSync)
	if not nSync then
		nSync = 1;
	end
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 0
	end
	local nOrgMaster = cTong.GetMaster()
	local cKinOrg = KKin.GetKin(nOrgMaster)
	-- 恢复家族职位
	if cKinOrg then
		cKinOrg.SetTongFigure(self.CAPTAIN_NORMAL)
	end
	cTong.SetMaster(nKinId)
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		return 0
	end
	cKin.SetTongFigure(self.CAPTAIN_MASTER);

	local cMember = cKin.GetMember(cKin.GetCaptain());
	local nNewMasterId = cMember.GetPlayerId();
	local szNewMaster = KGCPlayer.GetPlayerName(nNewMasterId);
	cMember = cKinOrg.GetMember(cKinOrg.GetCaptain());
	local nOldMasterId = cMember.GetPlayerId();
	local szOldMaster = KGCPlayer.GetPlayerName(nOldMasterId);
	cTong.AddAffairChangeMaster(szNewMaster, szOldMaster);

	local szLogMsg = "";
	if nExcutorId == -1 then
		--罢免选举成帮主
		KGCPlayer.PlayerLog(nNewMasterId, Log.emKPLAYERLOG_TYPE_TONGAPPOINT, "经选举变成帮主");
		KGCPlayer.PlayerLog(nOldMasterId, Log.emKPLAYERLOG_TYPE_TONGAPPOINT, "帮主被罢免变成普通成员");
		local szPresident = self:GetPresidentMemberName(nTongId);

		szLogMsg = string.format("帮主[%s]被首领[%s]罢免, [%s]经选举变成帮主",  szOldMaster, szPresident,  szNewMaster);
	else
		--传位成族长
		local szMsg = string.format("%s被%s任命为帮主",szNewMaster,szOldMaster);
		KGCPlayer.PlayerLog(nNewMasterId, Log.emKPLAYERLOG_TYPE_TONGAPPOINT, szMsg);
		szLogMsg = szMsg;
	end
	_G.TongLog(cTong.GetName(), Log.emKTONG_LOG_TONGSTRUCTURE , szLogMsg);

	if nSync == 1 then
		self.nJourNum = self.nJourNum + 1;
		cTong.SetTongDataVer(self.nJourNum);
		return GlobalExcute{"Tong:ChangeMaster_GS2", nTongId, nKinId, self.nJourNum};
	end
	return 1;
end

function Tong:CreateTongApply_GC(nPlayerId, szTongName)
	local nTongId = KTong.GetTongNameId(szTongName);
	return Tong:ApplyTongName(nTongId, nPlayerId);
end

--以列表的家族创建帮会
function Tong:CreateTong_GC(anKinId, szTongName, nCamp)
	--检查创建帮会的家族是否符合要求
	if self:CanCreateTong(anKinId) ~= 1 then
		return 0
	end
	local nCreateTime = GetTime()
	local cTong, nTongId = self:CreateTong(anKinId, szTongName, nCamp, nCreateTime)
	if cTong == nil then
		return 0
	end
	_DbgOut("CreateTong_GC succeed")
	for _, nKinId in ipairs(anKinId) do
		Kin:JoinTong_GC(nKinId, szTongName, nTongId, nCamp)
	end
	--Log 记录
	local cKin = KKin.GetKin(anKinId[1])
	local nCaptainId = cKin.GetCaptain();
	local cMember = cKin.GetMember(nCaptainId);
	local szMsg =  string.format("建立[%s]帮会", szTongName);
	KGCPlayer.PlayerLog(cMember.GetPlayerId(), Log.emKPLAYERLOG_TYPE_CREATETONG, szMsg);
	szMsg = string.format("[%s] 创建了帮会",  KGCPlayer.GetPlayerName(cMember.GetPlayerId()));
	_G.TongLog(szTongName, Log.emKTONG_LOG_TONGSTRUCTURE , szMsg);
	GlobalExcute{"Tong:CreateTong_GS2", anKinId, szTongName, nCamp, nCreateTime};
	Tong:PresidentConfirm_GC(nTongId);			-- 决定首领
end

-- 申请解散帮会
function Tong:ApplyDisbandTong_GC(nTongId, nKinId, nMemberId)
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 0
	end
	local nKinCount = cTong.GetKinCount();
	if nKinCount > 2 then -- 小于2个家族可以解散
		return 0;
	end
	if self:CheckSelfRight(nTongId, nKinId, nMemberId, self.POW_MASTER) ~= 1 then
		return 0;
	end
	self:DisbandTong_GC(nTongId, 2);
end

-- nReason:  0帮会没有通过考验期，1帮会没有家族了自动解散，2帮会主动解散
function Tong:DisbandTong_GC(nTongId, nReason)
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 0
	end
	nReason = nReason or 0;
	print("DisbandTong_GC", cTong.GetName(), cTong.GetMoneyFund(), cTong.GetBuildFund());
	local cKinItor = cTong.GetKinItor();
	local nMasterKin = cTong.GetMaster();
	local szTongName = cTong.GetName();
	local cMasterKin = nil;
	if nMasterKin > 0 then
		cMasterKin = KKin.GetKin(nMasterKin);
	end
	local cMember 	= nil;
	if cMasterKin then
		cMember = cMasterKin.GetMember(cMasterKin.GetCaptain());
	end
	local nMasterId = 0;
	if cMember then
		nMasterId = cMember.GetPlayerId();
	end
	local nKinId = cKinItor.GetCurKinId();
	while nKinId ~= 0 do
		local nNextKinId = cKinItor.NextKinId();
		Kin:LeaveTong_GC(nTongId, nKinId, 0);
		nKinId = nNextKinId;
	end
	
	local pDomainItor = cTong.GetDomainItor()
	local nDomainId = pDomainItor.GetCurDomainId();
	while nDomainId ~= 0 do
		local nNextDomainId = pDomainItor.NextDomainId();
		Domain:SetDomainOwner_GC(nDomainId, 0);
		nDomainId = nNextDomainId;
	end
	
	local nUnionId = cTong.GetBelongUnion();
	local pUnion = KUnion.GetUnion(nUnionId);
	if pUnion then 
		Union:TongDel_GC(nUnionId, nTongId, 0);
	end
	
	KTong.DelTong(nTongId);
	if nMasterId > 0 then
		local szMsg =  string.format("因为帮会考验期没通过,%s帮会被解散", szTongName);
		if nReason == 1 then -- 没有家族强制解散
			szMsg = string.format("%s帮会强制被解散", szTongName);
		elseif nReason == 2 then -- 帮主主动解散
			local szMastName = KGCPlayer.GetPlayerName(nMasterId);
			szMsg = string.format("因帮会家族数量太少，帮主[%s]主动解散%s帮会", szMastName, szTongName);
		end
		KGCPlayer.PlayerLog(nMasterId, Log.emKPLAYERLOG_TYPE_TONGDISMISS, szMsg);
	end
	Dbg:WriteLog("帮会解散", szTongName, nReason);
	return GlobalExcute{"Tong:DisbandTong_GS2", nTongId}
end

-- 家族解散从帮会删除
function Tong:KinDisband_GC(nDisbandKinId)
	local cDisbandKin = KKin.GetKin(nDisbandKinId);
	if not cDisbandKin then
		return 0;
	end
	local nTongId = cDisbandKin.GetBelongTong();
	if nTongId <= 0 then
		return 0;
	end
	local cTong = KTong.GetTong(nTongId)
	if (not cTong) then
		return 0;
	end
	local nFlag = 0;
	-- 帮主家族则重新设立帮主
	if nDisbandKinId == cTong.GetMaster() then
		nFlag = 1;
		cTong.SetMaster(0);
		cDisbandKin.SetTongFigure(self.CAPTAIN_NORMAL);
		local itor = cTong.GetKinItor();
		local nKinId = itor.GetCurKinId();
		while nKinId ~= 0 do
			local cKin = KKin.GetKin(nKinId);
			if cKin and nKinId ~= nDisbandKinId then
				cTong.SetMaster(nKinId);
				cKin.SetTongFigure(self.CAPTAIN_MASTER);
				break;
			end
			nKinId = itor.NextKinId();
		end
	end
	-- 首领家族则重新帮主家族设置首领家族
	if nDisbandKinId == cTong.GetPresidentKin() then
		nFlag = 1;
		local nMastKinId = cTong.GetMaster();
		if nMastKinId == 0 then
			cTong.SetPresidentKin(0);
			cTong.SetPresidentMember(0);
		else
			local cKin = KKin.GetKin(nMastKinId);
			if cKin then
				cTong.SetPresidentKin(nMastKinId);
				cTong.SetPresidentMember(cKin.GetCaptain());
			end
		end
	end
	if nFlag == 1 then
		self.nJourNum = self.nJourNum + 1;
		cTong.SetTongDataVer(self.nJourNum);
		GlobalExcute{"Tong:ResetPresidentMaster_GS2", self.nJourNum, nTongId, cTong.GetMaster(), cTong.GetPresidentKin(), cTong.GetPresidentMember()};
	end
	Tong:KinDel_GC(nTongId, nDisbandKinId, 0);
end

-- 帮主传位，解散家族是帮主家族时发生
function Tong:TransmitMast_GC(nTongId, nDisbandKinId, nTransmitKinId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return -1;
	end
	-- 解散的不是帮主家族，没什么事
	if pTong.GetMaster() ~= nDisbandKinId then
		return -1;
	end
	local pItor = pTong.GetKinItor()
	local nKinId = pItor.GetCurKinId()
	local pKin = KKin.GetKin(nKinId);
	if not nTransmitKinId then -- 如果没有指定传递的家族则传递第一个家族
		nTransmitKinId = nKinId;
	end
	pTong.SetMaster(nKinId); -- 先设上，防止指定的家族id不存在没有了帮主
	while (pKin) do
		if nTransmitKinId == nKinId then
			pTong.SetMaster(nTransmitKinId);
		end
		nKinId = pItor.NextKinId();
		pKin = KKin.GetKin(nKinId);	
	end
	local nMastKinId = pTong.GetMaster();
	return nMastKinId;
end

--帮主竞选（启动单个帮会的竞选）
function Tong:FireMaster_GC(nTongId, nKinId, nMemberId)
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 0;
	end

	if Tong:CheckPresidentRight(nTongId, nKinId, nMemberId) ~= 1 then
		return 0;
	end

	local nNowTime = GetTime()
	local nNowDay = tonumber(os.date("%y%m%d", nNowTime));
	local nFireMasterDate = tonumber(os.date("%y%m%d", cTong.GetFireMasterDate()));

	-- 一天只能罢免一次帮主
	if nFireMasterDate == nNowDay then
		return 0;
	end

	cTong.SetMasterLockState(1);
	cTong.SetFireMasterDate(nNowTime);

	return GlobalExcute{"Tong:FireMaster_GS2", nTongId, nNowTime}
end


--帮主竞选（启动单个帮会的竞选）
function Tong:StartMasterVote_GC(nTongId)
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 0;
	end

	--竞选已启动，则不能再启动
	if cTong.GetVoteStartTime() ~= 0 then
		return 0;
	end

	-- 发邮件通知
	local itor = cTong.GetKinItor();
	local nKinId = itor.GetCurKinId();
	while nKinId ~= 0 do
		local cKin = KKin.GetKin(nKinId);
		if cKin then
			KKin.SendKinMail(nKinId, "帮主竞选通知", "本届帮主竞选已经启动，持有帮会股份的股东现在可通过帮会界面投票！");
		end
		nKinId = itor.NextKinId();
	end

	local nNowTime = GetTime();
	-- 设置数据
	cTong.SetVoteStartTime(nNowTime);

	return GlobalExcute{"Tong:StartMasterVote_GS2", nTongId, nNowTime}
end

--停止帮主竞选
function Tong:StopMasterVote_GC(nTongId)
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 1;
	end
	if cTong.GetVoteStartTime() == 0 then
		return 0;
	end

	cTong.SetVoteCounter(0);
	cTong.SetVoteStartTime(0);
	local itor = cTong.GetKinItor();
	local nKinId = itor.GetCurKinId();
	local nMaxBallot = 0;
	local nCurMaxKin = 0;
	local nCurJourNum = 0;
	while nKinId ~= 0 do
		local cKin = KKin.GetKin(nKinId);
		if cKin then
			local nBallot = cKin.GetTongVoteBallot();
			if nBallot > nMaxBallot or (nBallot == nMaxBallot and cKin.GetTongVoteJourNum() < nCurJourNum) then
				nMaxBallot = nBallot;
				nCurMaxKin = itor.GetCurKinId();
				nCurJourNum = cKin.GetTongVoteJourNum();
			end
			-- 清空投票数据
			cKin.SetTongVoteBallot(0);
			cKin.SetTongVoteJourNum(0);
			-- 清空各家族成员的投票状态
			local itor = cKin.GetMemberItor();
			local cMember = itor.GetCurMember();
			while cMember do
				cMember.SetTongVoteState(0);
				cMember = itor.NextMember();
			end
		end
		nKinId = itor.NextKinId();
	end
	if nCurMaxKin ~= 0 then
		self:ChangeMaster_GC(nTongId, nCurMaxKin, -1);
	end
	--解除帮主锁定状态
	cTong.SetMasterLockState(0);
	return GlobalExcute{"Tong:StopMasterVote_GS2", nTongId, nCurMaxKin, nMaxBallot}
end

-- 投票
function Tong:ElectMaster_GC(nTongId, nTagetKinId, nTagetMemberId, nSelfKinId, nSelfMemberId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	if pTong.GetVoteStartTime() == 0 then
		return 0;
	end
	local pSelfKin = KKin.GetKin(nSelfKinId);
	if not pSelfKin then
		return 0;
	end
	local pTagetKin = KKin.GetKin(nTagetKinId);
	if not pTagetKin then
		return 0;
	end
	if nTagetMemberId ~= pTagetKin.GetCaptain() then
		return 0;
	end
	if nTongId ~= pTagetKin.GetBelongTong() then
		return 0;
	end

	local pSelfMember = pSelfKin.GetMember(nSelfMemberId);
	if not pSelfMember or pSelfMember.GetTongVoteState() == 1 then
		return 0;
	end
	local nTotalStock = pTong.GetTotalStock();
	local nSelfStock = pSelfMember.GetPersonalStock();
	if nTotalStock <= 0 or nSelfStock <= 0 then
		return 0;
	end

	local nPersonalVote = math.floor( nSelfStock / nTotalStock * 10000);
	local nVote = pTagetKin.GetTongVoteBallot() + nPersonalVote;

	pSelfMember.SetTongVoteState(1); --	标志已经投票
	pTagetKin.SetTongVoteBallot(nVote);
	local nVoteCount = pTong.GetVoteCounter() + 1;
	pTong.SetVoteCounter(nVoteCount);
	pTagetKin.SetVoteCounter(nVoteCount);

	GlobalExcute{"Tong:ElectMaster_GS2", nTongId, nTagetKinId, nSelfKinId, nSelfMemberId, nVoteCount, nVote}

	if nVote >= 5000 then
		Tong:StopMasterVote_GC(nTongId);
		return;
	end
end

--增加家族成员
function Tong:KinAdd_GC(nTongId, nKinId)
	local cTong = KTong.GetTong(nTongId);
	if (not cTong) then
		return 0;
	end
	if cTong.GetKinCount() >= self.MAX_KIN_NUM then
		return 0;
	end
	local nCreateTime = GetTime();
	local nRepute = self:_AddKin2Tong(nTongId, cTong, nKinId, nCreateTime, 0)
	if (nRepute == nil) then
		return 0;
	end
	-- 非创建帮会时加入帮会的要进行威望计算
	local nCurRepute = cTong.GetTotalRepute()
	if (nRepute > 0) then
		nCurRepute = nCurRepute + nRepute;
		cTong.SetTotalRepute(nCurRepute);
	end
	self.nJourNum = self.nJourNum + 1;
	cTong.SetTongDataVer(self.nJourNum);
	local szTongName = cTong.GetName();
	local nCamp = cTong.GetCamp();
	local cKin = KKin.GetKin(nKinId);
	if cKin then
		cTong.AddHistoryKinJoin(cKin.GetName());
	end

	-- 先在新家族未加入前广播新家族加入信息。
	GlobalExcute{"Tong:KinAdd_GS2", self.nJourNum, nTongId, nKinId, nCreateTime};
	Kin:JoinTong_GC(nKinId, szTongName, nTongId, nCamp, 1);
end

-- 开除家族申请，虽然有多个家族，但由于申请互斥，视为唯一申请
function Tong:FireKin_GC(nTongId, nSelfKinId, nSelfMemberId, nTagetKinId)
	local nRetCode, cMember = self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_MASTER);
	if nRetCode ~= 1 then
		return 0;
	end
	if not cMember then
		return 0;
	end
	local tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_KICK_KIN);
	if tbData.nApplyEvent == 1 then 	-- 已经存在某个开除家族的申请
		return 0;
	end
	-- 申请逻辑
	tbData.nApplyEvent 	= 1;
	tbData.tbAccept 	= {};		-- 家族表态表
	tbData.nCount		= 0;
	if not tbData.tbApplyRecord then
		tbData.tbApplyRecord = {};
	end
	tbData.tbApplyRecord.nTagetKinId = nTagetKinId;
	tbData.tbApplyRecord.nSelfKinId = nSelfKinId;		-- 记录申请的家族，该家族响应无效
	tbData.tbApplyRecord.nPlayerId = cMember.GetPlayerId();
	tbData.tbApplyRecord.nPow = 0
	tbData.tbApplyRecord.nTimerId = Timer:Register(
		self.FIREKIN_APPLY_LAST,
		self.CancelExclusiveEvent_GC,
		self,
		nTongId,
		self.REQUEST_KICK_KIN
	)
	return GlobalExcute{"Tong:FireKin_GS2", nTongId, nSelfKinId, cMember.GetPlayerId(), nTagetKinId};
end

function Tong:KinDel_GC(nTongId, nKinId, nMethod)-- nMethod为0表示离开，1表示开除
	local cTong = KTong.GetTong(nTongId)
	if (not cTong) then
		return 0;
	end
	if (nMethod == 1) then
		--开除事件要删除申请记录
		local tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_KICK_KIN);
		if tbData.tbApplyRecord and tbData.tbApplyRecord.nTimerId then
			Timer:Close(tbData.tbApplyRecord.nTimerId);
		end
		self:DelExclusiveEvent(nTongId, self.REQUEST_KICK_KIN);
	end

	-- 首领家族不能被开除
	if nKinId == cTong.GetPresidentKin() then
		if nMethod == 1 then
			GlobalExcute{"Tong:KinDelFailed_GS2", nTongId};
			return 0;
		end
	end	
	
	-- 家族是帮主家族
	if nKinId == cTong.GetMaster() then		
		if nMethod == 1 then
			GlobalExcute{"Tong:KinDelFailed_GS2", nTongId};
		else
			Kin:FailedQuitTong_GC(nKinId, 3);
		end
		return 0;
	end
	local nRet = cTong.DelKin(nKinId)
	if (nRet == nil or nRet ==0 ) then
		return 0
	end
	local cKin = KKin.GetKin(nKinId);
	if (not cKin) then
		return 0;
	end
	-- Add Tong Log
	local szLogMsg = string.format("%s 家族 %s", cKin.GetName(), (nMethod == 1 and "被开除出帮会" or "主动离开帮会"));
	_G.TongLog(cTong.GetName(), Log.emKTONG_LOG_TONGSTRUCTURE , szLogMsg);

	-- 威望处理
	local nKinRepute = cKin.GetTotalRepute();
	local nCurRepute = cTong.GetTotalRepute();
	if nKinRepute > 0 then
		nCurRepute = nCurRepute - nKinRepute;
		cTong.SetTotalRepute(nCurRepute);
	end

	self.nJourNum = self.nJourNum + 1;
	cTong.SetTongDataVer(self.nJourNum);
	cTong.AddHistoryKinLeave(cKin.GetName());
	cKin.AddHistoryLeaveTong(cTong.GetName());
	local nReduceFund = Kin:LeaveTong_GC(nTongId, nKinId, nMethod);
	GlobalExcute{"Tong:KinDel_GS2", self.nJourNum, nTongId, nKinId, nMethod, nReduceFund};
end

function Tong:ApointAssistant_GC(nTongId, nSelfKinId, nSelfMemberId, nAssistantId, nKinId, nMemberId)
	if self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_MASTER) ~= 1 then	-- 检查是否为帮主
		return 0;
	end
	if self:HaveFigure(nTong, nKinId, nMemberId, 0) ~= 1 then 	--检查是否为本帮长老
		return 0
	end
	-- 遍历一遍所有家族,检查是否已经有家族占了职位
	local cTong = KTong.GetTong(nTongId);
	local pKinIt = cTong.GetKinItor();
	local nCurKinId = pKinIt.GetCurKinId();
	local nOrgKinId = 0;
	while(nCurKinId ~= 0) do
		local pCurKin = KKin.GetKin(nCurKinId);
		if (pCurKin) and (pCurKin.GetTongFigure() == nAssistantId) then
			pCurKin.SetTongFigure(Tong.CAPTAIN_NORMAL);		--释放职位
			nOrgKinId = nCurKinId;							--记录释放职位的家族（要通知）
			break;
		end
		nCurKinId = pKinIt.NextKinId();
	end
	if nOrgKinId == nKinId then		-- 要任命的家族和原来担任该职位的家族相同
		return 0;
	end
	local cKin = KKin.GetKin(nKinId);
	if (not cKin) then
		return 0;
	end
	cKin.SetTongFigure(nAssistantId);		-- 任命
	GlobalExcute{"Tong:ApointAssistant_GS2", nTongId, nAssistantId, nKinId, nMemberId, nOrgKinId};
end

function Tong:ApointEmissary_GC(nTongId, nSelfKinId, nSelfMemberId, nTagetKinId, nTagetMemberId, nEmissaryId)
	if self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_ENVOY) ~= 1 then
		return 0;
	end
	local cKin = KKin.GetKin(nTagetKinId);
	if (not cKin) then
		return 0;
	end
	if (Kin:HaveFigure(nTagetKinId, nTagetMemberId, 4) ~= 1) then
		return 0;
	end
	local cMember = cKin.GetMember(nTagetMemberId);
	if not cMember then
		return 0;
	end
	cMember.SetEnvoyFigure(nEmissaryId);
	GlobalExcute{"Tong:ApointEmissary_GS2",nTongId, nTagetKinId, nTagetMemberId, nEmissaryId}
end

function Tong:ChangeAssistant_GC(nTongId, nSelfKinId, nSelfMemberId, nAssistantId, nPow, szTitle)
	local cExcutorKin = KKin.GetKin(nSelfKinId);
--	local nFigure = cExcutorKin.GetTongFigure();
	local cTong	= KTong.GetTong(nTongId);
	local nMasterKinId = cTong.GetMaster();
	local nExcutorCaptainId = cExcutorKin.GetCaptain();
--	if nFigure ~= 1 or nExcutorCaptainId ~= nSelfMemberId then
	if nMasterKinId ~= nSelfKinId or nExcutorCaptainId ~= nSelfMemberId then	-- 检查是不是帮主
		return 0;
	end
	if (not nAssistantId) then
	end
	cTong.SetCaptainTitle(nAssistantId, szTitle);
	cTong.AssignCaptainPower(nAssistantId, nPow);
	self.nJourNum = self.nJourNum + 1;
	cTong.SetTongFigureDataVer(self.nJourNum);
	GlobalExcute{"Tong:ChangeAssistant_GS2", nTongId, self.nJourNum, nAssistantId, nPow, szTitle};
end

function Tong:ChangeEmissary_GC(nTongId, nSelfKinId, nSelfMemberId, nEmissaryId, szTitle)
	if self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_ENVOY) ~= 1 then
		return 0;
	end
	local cTong = KTong.GetTong(nTongId);
	cTong.SetEnvoyTitle(nEmissaryId, szTitle);
	self.nJourNum = self.nJourNum + 1;
	cTong.SetTongFigureDataVer(self.nJourNum);
	GlobalExcute{"Tong:ChangeEmissary_GS2", nTongId, self.nJourNum, nEmissaryId, szTitle};
end

function Tong:FireEmissary_GC(nTongId, nSelfKinId, nSelfMemberId, nKinId, nMemberId, nSync)
	if self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_ENVOY) ~= 1 then
		return 0;
	end
	local cKin = KKin.GetKin(nKinId);
	if (not cKin) then
		return 0;
	end
	if(cKin.GetBelongTong() ~= nTongId) then
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId);
	if (not nMemberId) then --应该是写错了？ zounan
		return 0;
	end
	if (not cMember) then   -- 防止cMember为nil zounan
		return 0;
	end
	
	cMember.SetEnvoyFigure(0); -- 帮会掌令使信息每次刷新都固定同步，不产生版本的改变
	if nSync then
		GlobalExcute{"Tong:FireEmissary_GS2", nTongId, nKinId, nMemberId, 1};
	end
end

function Tong:FireAllEmissary_GC(nTongId, nSelfKinId, nSelfMemberId, nEmissaryId)
	if self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_ENVOY) ~= 1 then
		return 0;
	end
	local cTong = KTong.GetTong(nTongId);
	if (not cTong) then
		return 0;
	end
	local cKinItor = cTong.GetKinItor();
	local nKinId = cKinItor.GetCurKinId();
	while (nKinId ~= 0) do
		local cKin = KKin.GetKin(nKinId);
		if cKin then
			local cMemberItor = cKin.GetMemberItor();
			local cMember = cMemberItor.GetCurMember();
			while (cMember) do
				if (cMember.GetEnvoyFigure() == nEmissaryId) then
					cMember.SetEnvoyFigure(0);
				end
				cMember = cMemberItor.NextMember();
			end
		end
		nKinId = cKinItor.NextKinId();
	end
	GlobalExcute{"Tong:FireAllEmissary_GS2", nTongId, nEmissaryId};
end

function Tong:SaveAnnounce_GC(nTongId, nSelfKinId, nSelfMemberId, szAnnounce)
	if self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_ANNOUNCE) ~= 1 then
		return 0;
	end
	local cTong = KTong.GetTong(nTongId);
	if (not cTong) then
		return 0;
	end
	cTong.SetAnnounce(szAnnounce);
	self.nJourNum = self.nJourNum + 1;
	cTong.SetTongAnnounceDataVer(self.nJourNum);
	GlobalExcute{"Tong:SaveAnnounce_GS2", nTongId, self.nJourNum, szAnnounce};
end

function Tong:ChangeTakeStock_GC(nTongId, nSelfKinId, nSelfMemberId, nPercent)
	local nRet = self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_WAGE)
	if nRet ~= 1 then
		return 0;
	end
	local cTong = KTong.GetTong(nTongId);
	if (not cTong) then
		return 0;
	end
	local nCurEnergy = cTong.GetEnergy() - 100;
	if (nCurEnergy < 0) then
		return 0;
	end
	cTong.SetTakeStock(nPercent);
	cTong.SetEnergy(nCurEnergy);
	self.nJourNum = self.nJourNum + 1;
	cTong.SetTongDataVer(self.nJourNum)
	GlobalExcute{"Tong:ChangeTakeStock_GS2", nTongId, self.nJourNum, nPercent, nCurEnergy};
end

function Tong:HandUp_GC(nTongId, nSelfKinId, nSelfMemberId)
	GlobalExcute{"Tong:HandUp_GS2", nTongId, nSelfKinId, nSelfMemberId};
end

function Tong:AddFund_GC(nTongId, nPlayerId, nMoney)
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
	local nCurMoney = cTong.GetMoneyFund() + nMoney;
	if nCurMoney > self.MAX_TONG_FUND then
		Dbg:WriteLog("Error!!", "Tong:AddFund_GC", szPlayerName, "Failed to add "..nMoney);
		return 0;
	end
	cTong.SetMoneyFund(nCurMoney);
	self.nJourNum = self.nJourNum + 1;
	cTong.SetTongDataVer(self.nJourNum);
	if nMoney >= self.TAKEFUND_APPLY then
		cTong.AddAffairSaveFund(szPlayerName, tostring(nMoney));
	end
	if (nMoney >= 50000) then
		-- Add TongLog Add TongFund
		_G.TongLog(cTong.GetName(), Log.emKTONG_LOG_TONGFUND, szPlayerName.." 存入 ".. nMoney .. "帮会资金");
		KGCPlayer.PlayerLog(nPlayerId, Log.emKPLAYERLOG_TYPE_TONGPAYOFF, "["..szPlayerName.."] 向帮会 ["..cTong.GetName().."] 存入银两".. nMoney .. "帮会资金");

	end
	GlobalExcute{"Tong:AddFund_GS2", nTongId, self.nJourNum, nPlayerId, nCurMoney, nMoney};
end

function Tong:ApplyTakeFund_GC(nTongId, nSelfKinId, nSelfMemberId, nPlayerId, nMoney)
	if self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_FUN) ~= 1 then
		return 0;
	end
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	local tbDataStorageToKin = self:GetExclusiveEvent(nTongId, self.REQUEST_STORAGE_FUND_TO_KIN);
	if tbDataStorageToKin.nApplyEvent and tbDataStorageToKin.nApplyEvent == 1 then		-- 已经有申请转存家族 
		return 0;
	end
	local tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_TAKE_FUND);
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then		-- 已经有申请取钱
		return 0;
	end
	if tbData.nLastTime and GetTime() - tbData.nLastTime < self.TAKEFUND_TIME then -- 不足6小时
		return 0;
	end
	if (nMoney >= self.TAKEFUND_APPLY) then
		tbData.nApplyEvent = 1;
		if not tbData.tbApplyRecord then
			tbData.tbApplyRecord = {};
		end
		tbData.tbApplyRecord.nPlayerId = nPlayerId;
		tbData.tbApplyRecord.nKinId = nSelfKinId;
		tbData.tbApplyRecord.nAmount = nMoney;
		tbData.tbApplyRecord.nPow = self.POW_FUN;
		tbData.nCount = 0;
		tbData.tbAccept = {};	--表态家族表
		tbData.tbApplyRecord.nTimerId = Timer:Register(
			self.TAKEFUND_APPLY_LAST,
			self.CancelExclusiveEvent_GC,
			self,
			nTongId,
			self.REQUEST_TAKE_FUND
		);
		return GlobalExcute{"Tong:ApplyTakeFund_GS2",
			nTongId,
			nSelfKinId,
			nPlayerId,
			nMoney,
		};
	end
	-- 回gs查找player是否还存在
	self:FindPlayer_GC(nTongId, nMoney, nPlayerId);
	-- 不需要申请则直接发放
	--self:TakeFund_GC(nTongId, nMoney, nPlayerId);
end

 -- 回gs查找player是否还存在
function Tong:FindPlayer_GC(nTongId, nMoney, nPlayerId)
	local tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_TAKE_FUND);
	if tbData.nLastTime and GetTime() - tbData.nLastTime < self.TAKEFUND_TIME then
		return 0;
	end
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	GlobalExcute{"Tong:FindPlayer_GS", nTongId, nMoney, nPlayerId};
end

function Tong:TakeFund_GC(nTongId, nMoney, nPlayerId)
	local tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_TAKE_FUND);
	if tbData.nLastTime and GetTime() - tbData.nLastTime < self.TAKEFUND_TIME then
		GlobalExcute{"Tong:FailureToUnLock", nPlayerId};
		return 0;
	end
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		GlobalExcute{"Tong:FailureToUnLock", nPlayerId};
		return 0;
	end
	local nCurFund = cTong.GetMoneyFund();
	if nCurFund > Tong.MAX_TONG_FUND then
		cTong.SetMoneyFund(0);
		local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
		Dbg:WriteLog("tongfund over", cTong.GetName(), nTongId, "tongmoney:" .. nCurFund, "takemoney:" .. nMoney, szPlayerName);
		GlobalExcute{"Tong:FailureToUnLock", nPlayerId};
		return 0;
	end
	if (nMoney <= nCurFund) and (nMoney > 0) then
		nCurFund = nCurFund - nMoney;
		cTong.SetMoneyFund(nCurFund);
		self.nJourNum = self.nJourNum + 1;
		cTong.SetTongDataVer(self.nJourNum);
		tbData.nLastTime = GetTime();
		local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
		if nMoney >= self.TAKEFUND_APPLY then
			cTong.AddAffairTakeFund(szPlayerName, tostring(nMoney));
		end
		if (nMoney > 10000) then
			-- Add TongLog Take TongFund
			_G.TongLog(cTong.GetName(), Log.emKTONG_LOG_TONGFUND, szPlayerName.. " 取出 ".. nMoney .. "帮会资金");
		end

		GlobalExcute{"Tong:TakeFund_GS2", nTongId, nPlayerId, self.nJourNum, nMoney, nCurFund}
	else
		GlobalExcute{"Tong:FailureToUnLock", nPlayerId};
	end
	if (tbData.nApplyEvent == 1) then
		if tbData.tbApplyRecord and tbData.tbApplyRecord.nTimerId then
			Timer:Close(tbData.tbApplyRecord.nTimerId);
		end
		self:DelExclusiveEvent(nTongId, self.REQUEST_TAKE_FUND);
	end
end

function Tong:ApplyDispenseFund_GC(nTongId, nSelfKinId, nSelfMemberId, nType, nMoney)
	local nRetCode, cMember = self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_FUN)
	if nRetCode ~= 1 then
		return 0;
	end
	if not cMember then
		return 0;
	end
	local nPlayerId = cMember.GetPlayerId();
	local tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_DISPENSE_FUND);
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then	-- 上次申请响应没结束
		return 0;
	end
	if (tbData.nLastTime and tbData.nLastTime[nType] and GetTime() - tbData.nLastTime[nType] < self.DISPENSE_TIME) then
		return 0;
	end
	if not tbData.tbApplyRecord then
		tbData.tbApplyRecord = {};
	end
	tbData.tbApplyRecord.nType = nType;		-- 记录群众类型
	tbData.tbApplyRecord.nAmount = nMoney;
	tbData.nDisFundId = nPlayerId;
	if nMoney >= self.DISPENSE_FUND_APPLY then	-- 人均发资金量达到需要申请的界限
		tbData.nApplyEvent = 1;
		tbData.tbApplyRecord.nPlayerId = nPlayerId;
		tbData.tbApplyRecord.nKinId = nSelfKinId;
		tbData.tbApplyRecord.nType = nType;
		tbData.tbApplyRecord.nPow = self.POW_FUN;
		tbData.tbAccept = {};	--表态家族表
		-- 状态持10分钟
		tbData.tbApplyRecord.nTimerId = Timer:Register(
			self.DISPENSE_APPLY_LAST,
			self.CancelExclusiveEvent_GC,
			self,
			nTongId,
			self.REQUEST_DISPENSE_FUND
		);

		return GlobalExcute{"Tong:ApplyDispense_GS2",
			nTongId,
			nSelfKinId,
			nPlayerId,
			nType,
			nMoney,
			self.REQUEST_DISPENSE_FUND
		};
	end
	-- 没超界限，直发
	return KTong.DispenseFun(nTongId, nPlayerId, nType, nMoney);
end

-- 分发资源成功后，程序调用同步帮会资源
function Tong:SyncDispense_GC(nTongId, nType, nCurFund, nPlayerId)
	local tbData;
	local nCrowdType, nAmount;
	local cTong = KTong.GetTong(nTongId);
	if nType == self.DISPENSE_FUND then
		tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_DISPENSE_FUND);
		nCrowdType = tbData.tbApplyRecord.nType;
		nAmount = tbData.tbApplyRecord.nAmount;
		if tbData.nApplyEvent and tbData.nApplyEvent == 1 then  	--有开启申请
			if tbData.tbApplyRecord and tbData.tbApplyRecord.nTimerId then
				Timer:Close(tbData.tbApplyRecord.nTimerId);
			end
			self:DelExclusiveEvent(nTongId, self.REQUEST_DISPENSE_FUND);
		end
		if tbData.nDisFundId ~= nil then
			local szMsg = string.format("由帮会资金给%s每人发放%s剑侠币", self.tbCrowdTitle[nCrowdType], nAmount);
			KGCPlayer.PlayerLog(tbData.nDisFundId, Log.emKPLAYERLOG_TYPE_TONGPAYOFF, szMsg);
			
			-- 记录事件 
			local pTong = KTong.GetTong(nTongId);
			if pTong and nPlayerId and nAmount >= self.DISPENSE_FUND_RECORD then
				local szSelfName = KGCPlayer.GetPlayerName(nPlayerId);
				pTong.AddAffairDispenseFund(szSelfName, tostring(nAmount), Tong.tbCrowdTitle[nCrowdType]);
			end
		end
	elseif nType == self.DISPENSE_OFFER then
		tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_DISPENSE_OFFER);
		nCrowdType = tbData.tbApplyRecord.nType;
		nAmount = tbData.tbApplyRecord.nAmount;
		if tbData.nApplyEvent and tbData.nApplyEvent == 1 then  	--有开启申请
			if tbData.tbApplyRecord and tbData.tbApplyRecord.nTimerId then
				Timer:Close(tbData.tbApplyRecord.nTimerId);
			end
			self:DelExclusiveEvent(nTongId, self.REQUEST_DISPENSE_OFFER);
		end
	end
	if not tbData.nLastTime then
		tbData.nLastTime = {};
	end
	tbData.nLastTime[nCrowdType] = GetTime();		-- 记录操作的时间
	self.nJourNum = self.nJourNum + 1;
	cTong.SetTongDataVer(self.nJourNum);
	GlobalExcute{"Tong:SyncDispense_GS2", nTongId, nCurFund, self.nJourNum, nType, nCrowdType, nAmount, nPlayerId};
end

-- 由于资源不足造成发放资源失败
function Tong:FailedDispense_GC(nTongId, nType, nPlayerId)
	local tbData;
	if nType == self.DISPENSE_FUND then
		tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_DISPENSE_FUND);
		if tbData.nApplyEvent and tbData.nApplyEvent == 1 then  	--有开启申请
			if tbData.tbApplyRecord and tbData.tbApplyRecord.nTimerId then
				Timer:Close(tbData.tbApplyRecord.nTimerId);
			end
			self:DelExclusiveEvent(nTongId, self.REQUEST_DISPENSE_FUND);
		end
	elseif nType == self.DISPENSE_OFFER then
		tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_DISPENSE_OFFER);
		if tbData.nApplyEvent and tbData.nApplyEvent == 1 then  	--有开启申请
			if tbData.tbApplyRecord and tbData.tbApplyRecord.nTimerId then
				Timer:Close(tbData.tbApplyRecord.nTimerId);
			end
			self:DelExclusiveEvent(nTongId, self.REQUEST_DISPENSE_OFFER);
		end
	end
	GlobalExcute{"Tong:FailedDispense_GS2", nTongId, nType, nPlayerId};
end

--扣除邮资费用的同步
function Tong:MailMoney_GC(nTongId, nMoney)
	local cTong = KTong.GetTong(nTongId);
	if (cTong )then
		local nCurTongFund = cTong.GetMoneyFund();
		if nCurTongFund > Tong.MAX_TONG_FUND then
			cTong.SetMoneyFund(0);
			Dbg:WriteLog("tongfund over", cTong.GetName(), nTongId, "tongmoney:" .. nCurTongFund, "mailmoney:" .. nMoney);
			nMoney = 0;
		end
		self.nJourNum = self.nJourNum + 1;
		cTong.SetTongDataVer(self.nJourNum);
		GlobalExcute{"Tong:SyncMoney", nTongId, nMoney, self.nJourNum};
	end
end

-- 超时删除申请资金事件
function Tong:CancelExclusiveEvent_GC(nTongId, nEventId)
	self:DelExclusiveEvent(nTongId, nEventId);
	return 0;
end

-- 唯一事件的响应
function Tong:AcceptExclusiveEvent_GC(nTongId, nSelfKinId, nSelfMemberId, nKey, nAccept)
	local tbData = self:GetExclusiveEvent(nTongId, nKey);
	if not tbData.nApplyEvent or tbData.nApplyEvent == 0 then	-- 事件已不存在
		return 0
	end
	local nRetCode, cMember = self:HaveFigure(nTongId, nSelfKinId, nSelfMemberId, tbData.tbApplyRecord.nPow)
	if nRetCode ~= 1 then
		return 0;
	end
	if not cMember then
		return 0;
	end
	if not tbData.tbAccept then
		tbData.tbAccept = {}		-- 已表态家族记录
	end
	if tbData.tbAccept[nSelfKinId] then
		return 0;
	end
	tbData.tbAccept[nSelfKinId] = nAccept;
	if not tbData.nCount then
		tbData.nCount = 0;
	end
	if nAccept == 1 then
		tbData.nCount = tbData.nCount + 1;
	end
	GlobalExcute{"Tong:AcceptExclusiveEvent_GS2",
		nTongId,
		nSelfKinId,
		cMember.GetPlayerId(),
		nKey,
		nAccept
	};
	-- 判断是否通过了申请，执行操作
	if nKey == self.REQUEST_DISPENSE_FUND then
		if tbData.nCount < self.DISPENSE_AGREE_COUNT then
			return 0;
		end
		KTong.DispenseFun(
			nTongId,
			tbData.tbApplyRecord.nPlayerId,
			tbData.tbApplyRecord.nType,
			tbData.tbApplyRecord.nAmount
		);
	elseif nKey == self.REQUEST_TAKE_FUND then
		if tbData.nCount < self.TAKEFUND_AGREE_COUNT then
			return 0;
		end
		return self:FindPlayer_GC(
			nTongId,
			tbData.tbApplyRecord.nAmount,
			tbData.tbApplyRecord.nPlayerId
		);
	elseif nKey == self.REQUEST_DISPENSE_OFFER then
		if tbData.nCount < self.DISPENSE_AGREE_COUNT then
			return 0;
		end
		return KTong.DispenseOffer(
			nTongId,
			tbData.tbApplyRecord.nPlayerId,
			tbData.tbApplyRecord.nType,
			tbData.tbApplyRecord.nAmount
		);
	elseif nKey == self.REQUEST_KICK_KIN then
		local cTong = KTong.GetTong(nTongId);
		if (not cTong) then
			return 0;
		end
		if tbData.nCount < self.KICK_KIN_AGREE_COUNT or nKinId == cTong.GetPresidentKin()then
			return 0;
		end
		self:KinDel_GC(nTongId, tbData.tbApplyRecord.nTagetKinId, 1);
	elseif nKey == self.REQUEST_STORAGE_FUND_TO_KIN then
		if tbData.nCount < self.DISPENSE_AGREE_COUNT then
			return 0;
		end
		self:StorageFundToKin_GC(nTongId, tbData.tbApplyRecord.nPlayerId, tbData.tbApplyRecord.nAmount, tbData.tbApplyRecord.nTargetKinId);
	else
		return 0;
	end
	if tbData.tbApplyRecord then
		if tbData.tbApplyRecord.nTimerId then
			Timer:Close(tbData.tbApplyRecord.nTimerId);		-- 关闭计时器，防止误删下次申请
			tbData.tbApplyRecord.nTimerId = nil;
		end
		self:DelExclusiveEvent(nTongId, nKey);
	end

end

function Tong:ApplyDispenseOffer_GC(nTongId, nSelfKinId, nSelfMemberId, nType, nAmount)
	local nRetCode, cMember = self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_FUN)
	if nRetCode ~= 1 then
		return 0;
	end
	if not cMember then
		return 0;
	end
	local tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_DISPENSE_OFFER);
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
		return 0
	end
	if tbData.nLastTime and tbData.nLastTime[nType] and GetTime() - tbData.nLastTime[nType] < self.DISPENSE_APPLY_LAST then
		return 0;
	end
	local nPlayerId = cMember.GetPlayerId();
	if not tbData.tbApplyRecord then
		tbData.tbApplyRecord = {};
	end
	tbData.tbApplyRecord.nType = nType;		-- 记录群众类型
	tbData.tbApplyRecord.nAmount = nAmount;

	if nAmount > self.DISPENSE_OFFER_APPLY then
		tbData.nApplyEvent = 1;
		if not tbData.tbApplyRecord then
			tbData.tbApplyRecord = {};
		end
		tbData.tbApplyRecord.nPlayerId = nPlayerId;
		tbData.tbApplyRecord.nKinId = nSelfKinId;
		tbData.tbApplyRecord.nPow = self.POW_STOREDOFFER;
		tbData.tbAccept = {};	--表态家族表
		-- 状态持10分钟
		tbData.tbApplyRecord.nTimerId = Timer:Register(
			self.DISPENSE_APPLY_LAST,
			self.CancelExclusiveEvent_GC,
			self,
			nTongId,
			self.REQUEST_DISPENSE_OFFER
		);
		return GlobalExcute{"Tong:ApplyDispense_GS2",
			nTongId,
			nSelfKinId,
			nPlayerId,
			nType,
			nAmount,
			self.REQUEST_DISPENSE_OFFER
		};
	end
	-- 直发
	KTong.DispenseOffer(nTongId, nPlayerId, nType, nAmount)
end

function Tong:ChangeTitle_GC(nTongId, nSelfKinId, nSelfMemberId, szTitle, nTitleType)
	if self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_TITLE) ~= 1 then
		return 0;
	end
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	cTong.SetBufTask(nTitleType, szTitle);
	return GlobalExcute{"Tong:ChangeTitle_GS2", nTongId, szTitle, nTitleType};
end

function Tong:ChangeCamp_GC(nTongId, nSelfKinId, nSelfMemberId, nCamp)
	if self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_CAMP) ~= 1 then
		return 0;
	end
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	local tbData = Tong:GetTongData(nTongId);
	if tbData.nLastCampTime and GetTime() - tbData.nLastCampTime < Tong.CHANGE_CAMP_TIME then
		return 0;
	end
	if nCamp < 1 or nCamp > 3 then
		return 0;
	end
	if self:CostBuildFund_GC(nTongId, nSelfKinId, nSelfMemberId, Tong.CHANGE_CAMP, 0) ~= 1 then
		return 0;
	end
	cTong.SetCamp(nCamp);
	local cKinItor = cTong.GetKinItor();
	local nCurKinId = cKinItor.GetCurKinId();
	while (nCurKinId ~= 0) do
		local cKin = KKin.GetKin(nCurKinId);
		if cKin then
			cKin.SetCamp(nCamp);
		end
		nCurKinId = cKinItor.NextKinId();
	end
	self.nJourNum = self.nJourNum + 1;
	cTong.SetTongDataVer(self.nJourNum);
	tbData.nLastCampTime = GetTime();
	return GlobalExcute{"Tong:ChangeCamp_GS2", nTongId, nCamp, self.nJourNum};
end

function Tong:InheritMaster_GC(nTongId, nSelfKinId, nSelfMemberId, nTagetKinId, nTagetMemberId)
	local nRetCode, cMember = self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_MASTER);
	if nRetCode ~= 1 then
		return 0;
	end
	if self:HaveFigure(nTongId, nTagetKinId, nTagetMemberId, 0) ~= 1 then
		return 0;
	end
	local nCurRepute = KGCPlayer.GetPlayerPrestige(cMember.GetPlayerId()) - self.INHERIT_MASTER;
	if nCurRepute < 0 then
		return 0;
	end
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0
	end
	KGCPlayer.SetPlayerPrestige(cMember.GetPlayerId(), nCurRepute);
	self:ChangeMaster_GC(nTongId, nTagetKinId, 0, 0);
	self.nJourNum = self.nJourNum + 1;
	cTong.SetTongDataVer(self.nJourNum);
	return GlobalExcute{"Tong:InheritMaster_GS2", nTongId, nSelfKinId, nTagetKinId, self.nJourNum, nCurRepute};
end

function Tong:AddEnergy_GC(nTongId, nEnergy)
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 0;
	end
	local nCurEnergy = cTong.GetEnergy() + nEnergy;
	cTong.SetEnergy(nCurEnergy);
	self.nJourNum = self.nJourNum + 1;
	cTong.SetTongDataVer(self.nJourNum);
	return GlobalExcute{"Tong:AddEnergy_GS2", nTongId, nCurEnergy, self.nJourNum};
end

function Tong:AddTongTotalRepute_GC(nTongId, nRepute)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	pTong.AddTotalRepute(nRepute);
	self.nJourNum = self.nJourNum + 1;
	pTong.SetTongDataVer(self.nJourNum);
	GlobalExcute{"Tong:SyncTongTotalRepute_GS2", nTongId, pTong.GetTotalRepute(), self.nJourNum};
end

--function Tong:AddTongOffer_GC(nTongId, nOffer, nFund, nKinId)
--	local pTong = KTong.GetTong(nTongId);
--	if not pTong then
--		return 0;
--	end
--	local cKin = KKin.GetKin(nKinId);
--	if (not cKin) then
--		return 0;
--	end
--	--cKin.AddTongOffer(nOffer);
--	--local nTempOffer = pTong.GetStoredOffer();
--	--if nTempOffer + nOffer >= self.MAX_STORED_OFFER then
--	--	nOffer = self.MAX_STORED_OFFER - nTempOffer;
--	--end
--	--pTong.AddStoredOffer(nOffer);
--	--self.nJourNum = self.nJourNum + 1;
--	--pTong.SetTongDataVer(self.nJourNum);
--	pTong.AddBuildFund(nFund);
--	GlobalExcute{"Tong:AddTongOffer_GS2", nTongId, nOffer, nFund, nKinId};
--end

--上周工资发放管理.
function Tong:DealTakeStock(nTongId)
	local pTong = KTong.GetTong(nTongId)
	if not pTong then
		return 0
	end
	local nTake = pTong.GetTakeStock();
	pTong.SetLastTakeStock(nTake);

--[[  注释掉~可能将来这部分还要用 zhengyuhua
	local cKinItor = cTong.GetKinItor()
	local nKinId = cKinItor.GetCurKinId()
	while nKinId ~= 0 do
		local cKin = KKin.GetKin(nKinId)
		if cKin then
			local cKinMemberItor = cKin.GetMemberItor()
			local cMember = cKinMemberItor.GetCurMember()
			while cMember do
				local nFigure = cMember.GetFigure()
				local nWageFigure = self.WAGE_NOFIGURE;
				if (Kin.FIGURE_CAPTAIN == nFigure) or (cMember.GetBitExcellent() == 1) then
						nWageFigure = self.WAGE_HIGHFIGURE;
				elseif (Kin.FIGURE_REGULAR == nFigure) or (Kin.FIGURE_ASSISTANT == nFigure) then
						nWageFigure = self.WAGE_LOWFIGURE;
				end
				cMember.SetWageFigure(nWageFigure)
				cMember.SetWageValue(0)
				cMember = cKinMemberItor.NextMember()
			end
		end
		nKinId = cKinItor.NextKinId()
	end
--]]
	GlobalExcute{"Tong:DealTakeStock_GS2", nTongId, nTake};
	return 1
end


function Tong:TakeStock_GC(nTongId, nKinId, nMemberId)
	local pTong = KTong.GetTong(nTongId)
	if not pTong then
		return 0
	end
	local nTotalFund = pTong.GetBuildFund();
	local nTotalStock = pTong.GetTotalStock();
	local pKin = KKin.GetKin(nKinId);
	local pMember = pKin.GetMember(nMemberId);
	local nPersonalStock = pMember.GetPersonalStock();
	if nTotalFund == 0 or nTotalStock == 0 or nPersonalStock == 0 then
		return 0;
	end
	local nTakePercent = pTong.GetLastTakeStock()
	if nTakePercent <= 0 then
		return 0;
	end
	local nTakeStock = math.floor(nTakePercent * nPersonalStock / 100);
	local nTakeMoney = math.floor(nTakeStock * nTotalFund / nTotalStock);
	local nMoney = math.floor(nPersonalStock * nTotalFund / nTotalStock);
	pTong.SetBuildFund(nTotalFund - nTakeMoney);
	pTong.SetTotalStock(nTotalStock - nTakeStock);
	pMember.SetPersonalStock(nPersonalStock - nTakeStock);
	GlobalExcute{"Tong:TakeStock_GS2", nTongId, nKinId, nMemberId, nTotalFund - nTakeMoney,
		nTakeMoney, nTotalStock - nTakeStock, nPersonalStock - nTakeStock};
	-- Add TongLog 领取分红
	local szLogMsg = string.format("%s 领取了 %d 帮会分红",  KGCPlayer.GetPlayerName(pMember.GetPlayerId()), nTakeMoney);
	_G.TongLog(pTong.GetName(),  Log.emKTONG_LOG_TONGBUILDFUN, szLogMsg);
end

------------------------------家族帮会名字申请------------------------------------
Tong.aKinNameApply = {}
Tong.aTongNameApply = {}
function Tong:ApplyKinName(nId, nParam)
	if not nId or nId == 0 or self.aKinNameApply[nId] or KUnion.GetUnion(nId) then
		Kin:OnKinNameResult(nParam, 0);
		return 0;
	end
	self.aKinNameApply[nId] = nParam;
	return GCApplyCreateTongName(nId, tostring(nId));
end

function Tong:ApplyTongName(nId, nParam)	
	if not nId or nId == 0 or self.aTongNameApply[nId] or KUnion.GetUnion(nId) then
		self:OnTongNameResult(nParam, 0);
		return 0;
	end
	self.aTongNameApply[nId] = nParam;
	return GCApplyCreateTongName(nId, tostring(nId));
end

function Tong:ApplyUnionName(nId, nParam)		-- 写在这里是为了三个模块更容易看到Id互斥
	if not nId or self.aTongNameApply[nId] or self.aKinNameApply[nId] then		-- 该Id在家族帮会申请中，不允许使用
		return 0;
	end
	if KTong.GetTong(nId) or KKin.GetKin(nId) or KUnion.GetUnion(nId) then		-- 已在帮会、家族、联盟中存在，不允许使用
		return 0;
	end
	return 1;
end

-- 创建家族帮会名字回复
function Tong:OnKinTongNameResult(nId, nResult)
	local nParam = self.aKinNameApply[nId]
	if nParam then
		self.aKinNameApply[nId] = 0; -- 该id已验证过，后面再用的必重复
		return Kin:OnKinNameResult(nParam, nResult);
	end
	nParam = self.aTongNameApply[nId]
	if nParam then
		self.aTongNameApply[nId] = 0; -- 该id已验证过，后面再用的必重复
		return Tong:OnTongNameResult(nParam, nResult);
	end
	return 0;
end

function Tong:OnTongNameResult(nParam, nResult)
	GlobalExcute{"Tong:OnTongNameResult_GS2", nParam, nResult};
end

-- 设置主城
function Tong:SetCapital_GC(nTongId, nSelfKinId, nSelfMemberId, nDomainId)
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 0;
	end

	-- 是否已占领该领土
	if Domain:GetDomainOwner(nDomainId) == nTongId then
		-- 检查是否新手村
		if Domain:GetDomainType(nDomainId) == "village" then
			return 0;
		end
		local nCost, nChangeCount = Tong:CalcChangeCapital(nTongId);

		-- 扣帮会资金
		if self:CostBuildFund_GC(nTongId, nSelfKinId, nSelfMemberId, nCost, 0) ~= 1 then
			return 0;
		end
		local nDataVer = Domain:UpdateDataVer();
		cTong.SetCapital(nDomainId);
		cTong.SetCapitalChangeCount(nChangeCount + 1); -- 记录主城变更次数
		local szCapital = Domain:GetDomainName(nDomainId);
		if szCapital then
			cTong.AddAffairCapital(szCapital);
		end
		return GlobalExcute{"Tong:SetCapital_GS2", nTongId, nDomainId, nCost, nChangeCount + 1, nDataVer};
	end
end

-- 每周增加帮会声望
function Tong:AddDomainRepueDaily(nTongId)
	local cTong = KTong.GetTong()
	if not cTong then
		return 0;
	end
	local pItor = cTong.GetDomainItor()
	local pDomain = pItor.GetCurDomain();
	local tbRepute = {};
	if pDomain then
		local nOccupyTime = pDomain.GetOccupyTime();
		local nDomainId = pItor.GetCurDomainId();
		local nCountryId = Domain:GetDomainCountry(nDomainId);
		if not tbRepute[nCountryId] then
			tbRepute[nCountryId] = 0;
		end
		-- TODO: 根据天数计算获得声望的数量
		tbRepute[nCountryId] = tbRepute[nCountryId];
		pDomain = pItor.NextDomain();
	end
end

-- 帮会合并股
-- nComposeNum: 原来的nComposeNum股 合并成 1股，nComposeNum太大会出BUG
function Tong:ComposeStock_GC(nTongId, nComposeNum)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return;
	end
	print("ComposeStock_GC", pTong.GetName(), nComposeNum)
	local tbRet = {};		-- 合并结果，需要同步到各个服务器的
	local nTotalStock = 0;
	local pItor = pTong.GetKinItor()
	local nKinId = pItor.GetCurKinId()
	local pKin = KKin.GetKin(nKinId);
	while (pKin) do
		local tbKinRet = {}
		local pMemberItor = pKin.GetMemberItor();
		local pMember = pMemberItor.GetCurMember();
		while pMember do
			local nPersonalStock = pMember.GetPersonalStock();
			nPersonalStock = math.floor(nPersonalStock / nComposeNum);	-- 合并股
			pMember.SetPersonalStock(nPersonalStock);
			nTotalStock = nTotalStock + nPersonalStock;					-- 累加总股数
			tbKinRet[pMemberItor.GetCurMemberId()] = nPersonalStock;	-- 记录结果
			pMember = pMemberItor.NextMember()
		end
		tbRet[nKinId] = tbKinRet;	-- 记录结果
		nKinId = pItor.NextKinId();
		pKin = KKin.GetKin(nKinId);
	end
	pTong.SetTotalStock(nTotalStock);
	GlobalExcute{"Tong:SyncAllMemberStock_GS2", nTongId, nTotalStock, tbRet}		-- 同步合并股结果
end

-- 帮会股份拆分
-- nSpiltNum : 每股拆分成 nSpiltNum股
function Tong:SpiltStock_GC(nTongId, nSpiltNum)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	print("SpiltStock_GC", pTong.GetName(), nSpiltNum)
	local tbRet = {};		-- 合并结果，需要同步到各个服务器的
	local nTotalStock = 0;
	local pItor = pTong.GetKinItor()
	local nKinId = pItor.GetCurKinId()
	local pKin = KKin.GetKin(nKinId);
	while (pKin) do
		local tbKinRet = {}
		local pMemberItor = pKin.GetMemberItor();
		local pMember = pMemberItor.GetCurMember();
		while pMember do
			local nPersonalStock = pMember.GetPersonalStock();
			nPersonalStock = nPersonalStock * nSpiltNum;	-- 拆分股
			pMember.SetPersonalStock(nPersonalStock);
			nTotalStock = nTotalStock + nPersonalStock;					-- 累加总股数
			tbKinRet[pMemberItor.GetCurMemberId()] = nPersonalStock;	-- 记录结果
			pMember = pMemberItor.NextMember()
		end
		tbRet[nKinId] = tbKinRet;	-- 记录结果
		nKinId = pItor.NextKinId();
		pKin = KKin.GetKin(nKinId);
	end
	pTong.SetTotalStock(nTotalStock);
	return GlobalExcute{"Tong:SyncAllMemberStock_GS2", nTongId, nTotalStock, tbRet}		-- 同步合并股结果
end

function Tong:CheckAndSpiltOrComposeStock(nTongId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	local nTongStock = pTong.GetTotalStock();
	local nBuildFund = pTong.GetBuildFund()
	if nTongStock <= 0 then
		return 0;
	end
	if nBuildFund / nTongStock > self.SPILT_STOCK_MIN_PRICE then		-- 股价太高，拆分股份
		local nSpiltNum = math.ceil(nBuildFund / (nTongStock * self.DEFAULT_STOCKPRICE))		-- 先乘再除减少误差
		if nSpiltNum > 1 then
			return self:SpiltStock_GC(nTongId, nSpiltNum);
		end
	elseif nBuildFund / nTongStock < 2 then		-- 股价太低，合并股份
		local nComposeNum = math.min(math.ceil(self.DEFAULT_STOCKPRICE / (nBuildFund / nTongStock)),
			math.ceil(nTongStock / 100));
		self:ComposeStock_GC(nTongId, nComposeNum);
	else
		return 0;
	end
	return 1;
end

function Tong:PresidentConfirm_GC(nTongId, bUpdateOfficial)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	local tbResult = self:PresidentConfirm(nTongId);
	if not tbResult or not tbResult[1] then
		return 0
	end
--	Lib:ShowTB(tbResult);
	self.nJourNum = self.nJourNum + 1;		-- 帮会数据版本号
	pTong.SetTongDataVer(self.nJourNum);
	Kin.nJourNum = Kin.nJourNum + 1;		-- 家族数据版本号
	GlobalExcute{"Tong:PresidentConfirm_GS2", nTongId, tbResult, self.nJourNum, Kin.nJourNum};
	if bUpdateOfficial == 1 then
		self:UpDateOfficialMaintain_GC(nTongId, tbResult);
	end
end

function Tong:PresidentCandidateConfirm_GC(nTongId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	local tbResult = self:PresidentConfirm(nTongId, nil, 0);
	if not tbResult or not tbResult[1] then
		return 0
	end
	if tbResult[1].nKinId == pTong.GetPresidentKin() and
		tbResult[1].nMemberId == pTong.GetPresidentMember() then
		return 0;		-- 本身自己就是首领~不记录候选人
	end
	local pKin = KKin.GetKin(tbResult[1].nKinId);
	if not pKin then
		return 0;
	end
	local pMember = pKin.GetMember(tbResult[1].nMemberId);
	if not pMember then
		return 0;
	end
	pMember.SetStockFigure(self.PRESIDENT_CANDIDATE);
	self.nJourNum = self.nJourNum + 1;		-- 帮会数据版本号
	Kin.nJourNum = Kin.nJourNum + 1;		-- 家族数据版本号

	-- Add TongLog
	local szLogMsg = string.format("%s 成为首领候选人", KGCPlayer.GetPlayerName(pMember.GetPlayerId()));
	_G.TongLog(pTong.GetName(), Log.emKTONG_LOG_TONGSTRUCTURE , szLogMsg);
	GlobalExcute{"Tong:PresidentCandidateConfirm_GS2", nTongId, tbResult[1].nKinId, tbResult[1].nMemberId, self.nJourNum, Kin.nJourNum}
end

-- 消费帮会资金(纯处理接口，不检查权限和使用限制，包括了GS同步功能但不公告)
function Tong:ConsumeBuildFund_GC(nTongId, nMoney)
	local pTong = KTong.GetTong(nTongId)
	if not pTong then
		return 0;
	end
	local nBuildFund = pTong.GetBuildFund()
	if nBuildFund < nMoney then
		return 0;
	end
	local nCurFund = nBuildFund - nMoney
	pTong.SetBuildFund(nCurFund);			-- 消耗资金
	local nCurTotalStock = pTong.GetTotalStock()	-- 股份总数
	if nCurFund == 0 or nCurTotalStock == 0 then
		self:ClearAllStock(nTongId);
	elseif nCurFund / nCurTotalStock < 1 then		-- 需要合并股了
		local nComposeNum = math.min(math.ceil(self.DEFAULT_STOCKPRICE / (nCurFund / nCurTotalStock)),
			math.ceil(nCurTotalStock / 100));
		self:ComposeStock_GC(nTongId, nComposeNum);
	end
	print("ConsumeBuildFund_GC", nTongId, nMoney)			-- 消费LOG
	return GlobalExcute{"Tong:ConsumeBuildFund_GS2", nTongId, nCurFund};
end

-- 增加帮会资金（纯接口，包括GS同步但不公告）
function Tong:AddBuildFund_GC(nTongId, nKinId, nMemberId, nMoney, nTranceRate, bTongShow, bSelfShow)

	local pKin = KKin.GetKin(nKinId)
	if not pKin or pKin.GetBelongTong() ~= nTongId then
		return 0;
	end
	if nTongId == 0 then
		bSelfShow = 0;
	end
	Tong:_AddTongBuildFund(nKinId, nMemberId, nMoney, nTranceRate)
	local pTong = KTong.GetTong(nTongId);
	if pTong then
		local pKin = KKin.GetKin(nKinId);
		if pKin then
			local pMember = pKin.GetMember(nMemberId);
			if pMember then
				local szPlayerName = KGCPlayer.GetPlayerName(pMember.GetPlayerId());
				if nMoney >= self.TAKEFUND_APPLY then
					pTong.AddAffairBuildFund(szPlayerName, tostring(nMoney));
				end
			end
		end
	end
	print("Tong", "AddBuildFund_GC", nKinId, nMemberId, nMoney, nTranceRate)
	GlobalExcute{"Tong:AddBuildFund_GS2", nKinId, nMemberId, nMoney, bTongShow, bSelfShow};
end

-- 增加帮会资金，与其他无关（纯接口，包括GS同步但不公告）
function Tong:AddBuildFund2_GC(nTongId,  nMoney)
	local pTong = KTong.GetTong(nTongId);
	if 0 ==nMoney then
		return 0;
	end
	if pTong then
		pTong.AddBuildFund(nMoney);
		print("Tong", "AddBuildFund2_GC", nTongId,nMoney);
	end
	GlobalExcute{"Tong:AddBuildFund2_GS2", nTongId, nMoney};
end
-- nKinId	：家族ID(会自动寻找帮会ID)
-- nMemberId：成员ID
-- nFund	：资金数
-- nTranceRate：资金转化股份的转化率
function Tong:_AddTongBuildFund(nKinId, nMemberId, nFund, nTranceRate)
	local bClear = 0;
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	if nFund <= 0 then
		return 0;
	end
	if nTranceRate > 1 then
		nTranceRate = 1;
	end
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return 0;
	end
	local nTongId = pKin.GetBelongTong()
	local pTong = KTong.GetTong(nTongId);
	local nPersonalStock = pMember.GetPersonalStock();
	if not pTong then
		local nTotal = nPersonalStock + nFund;
		if nTotal > self.MAX_BUILD_FUND then
			nTotal = self.MAX_BUILD_FUND;
		end
		pMember.SetPersonalStock(nTotal);	-- 没有帮会的时候股价恒定为1，也就是等于资产，全部转化为成员资产
		return GlobalExcute{"Tong:_AddTongBuildFund_GS2", nTongId, nKinId, nMemberId,
			0, 0, nPersonalStock + nFund, bClear};
	end
	local nBuildFund = pTong.GetBuildFund();
	if nBuildFund + nFund > self.MAX_BUILD_FUND then
		return 0;
	end
	local nTotalStock = pTong.GetTotalStock();	-- 总股份数
	local nBuildFund = pTong.GetBuildFund();	-- 建设资金
	local nStockPrice = 0; 						-- 股价
	if nTotalStock > 0 and nBuildFund > 0 then
		nStockPrice = nBuildFund / nTotalStock
	else
		bClear = 1
		self:ClearAllStock(nTongId);			-- 股份数或总资产为0了，清空股份数
		nTotalStock = 0;
		nBuildFund = 0;
		nStockPrice = self.DEFAULT_STOCKPRICE;
	end

---------------------------------------------------------------
	if (nBuildFund > self.MAX_BUILD_FUND) then
		nBuildFund = self.MAX_BUILD_FUND;
	end
	
	if nFund + nBuildFund > self.MAX_BUILD_FUND then
		nFund = self.MAX_BUILD_FUND - nBuildFund;
	end
---------------------------------------------------------------
	local nStock = math.floor(nFund * nTranceRate / nStockPrice);
	pTong.SetBuildFund(nBuildFund + nFund);
	pTong.SetTotalStock(nTotalStock + nStock);
	pMember.SetPersonalStock(nPersonalStock + nStock);
	if nFund >= 200000 then
		-- Add TongLog AddTongFund
		local szName = KGCPlayer.GetPlayerName(pMember.GetPlayerId());
		local szLogMsg = string.format("[%s ]增加了帮会建设资金%d。", szName, nFund);
		_G.TongLog(pTong.GetName(), Log.emKTONG_LOG_TONGBUILDFUN, szLogMsg);
		local szMsg = string.format("捐献%s剑侠币作为帮会建设基金", nFund);
		KGCPlayer.PlayerLog(pMember.GetPlayerId(), Log.emKPLAYERLOG_TYPE_TONGCONTRIBUTE, szMsg);
		Dbg:WriteLog("Tong", "Name:"..szName, "Fund:"..nFund, "TotalFund:"..(nBuildFund + nFund), 
			"TotalStock:"..(nTotalStock + nStock), "PersonStock:"..(nPersonalStock + nStock), 
			"StockPrice"..nStockPrice);
	end

	return GlobalExcute{"Tong:_AddTongBuildFund_GS2", nTongId, nKinId, nMemberId,
		nBuildFund + nFund, nTotalStock + nStock, nPersonalStock + nStock, bClear};
end

function Tong:SyncStock(nTongId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	return GlobalExcute{"Tong:SyncStock_GS2", nTongId, pTong.GetBuildFund(), pTong.GetTotalStock()};
end

-- 使用帮会建设资金（ConsumeBuildFund的封装，做各项检测）
function Tong:CostBuildFund_GC(nTongId, nKinId, nMemberId, nMoney, bNeedMsg)
	bNeedMsg = bNeedMsg or 1;
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end

	if self:CanCostedBuildFund(nTongId, nKinId, nMemberId, nMoney) == 1 then
		if (self:ConsumeBuildFund_GC(nTongId, nMoney) ==1)then
			local pKin = KKin.GetKin(nKinId);
			if (pKin) then
				local pMember = pKin.GetMember(nMemberId);
				local szLogMsg = string.format("%s 消耗了 %d 帮会建设资金。", KGCPlayer.GetPlayerName(pMember.GetPlayerId()), nMoney);
				if (nMoney >= 50000) then
					_G.TongLog(pTong.GetName(),  Log.emKTONG_LOG_TONGBUILDFUN, szLogMsg);
					KGCPlayer.PlayerLog(pMember.GetPlayerId(), Log.emKPLAYERLOG_TYPE_TONGCONTRIBUTE, szLogMsg);
				end
			end
		end
		pTong.AddCostedBuildFund(nMoney); -- 记录本周总共消耗的建设资金
		local nCostedBuildFund = pTong.GetCostedBuildFund()
		GlobalExcute{"Tong:CostBuildFund_GS2", nTongId, nCostedBuildFund, nMoney, 1};
		return 1
	end
	return 0
end


-- 设置帮会建设资金上限
function Tong:SetBuildFundLimit_GC(nTongId, nKinId, nMemberId, nMoneyLimit)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end

	if Tong:CheckPresidentRight(nTongId, nKinId, nMemberId) ~= 1 then
		return 0;
	end

	pTong.SetBuildFundLimit(nMoneyLimit); -- 设置建设资金上限

	GlobalExcute{"Tong:SetBuildFundLimit_GS2", nTongId, nMoneyLimit};
	return 1;
end

-- 修正指令
function Tong:SyncTotalStock(nTongId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	local pItor = pTong.GetKinItor()
	local nKinId = pItor.GetCurKinId()
	local pKin = KKin.GetKin(nKinId);
	local nTotalStock = 0;
	local tbRet = {};
	while (pKin) do
		tbRet[nKinId] = {};
		local pMemberItor = pKin.GetMemberItor();
		local pMember = pMemberItor.GetCurMember();
		while pMember do
			local nMemberId = pMemberItor.GetCurMemberId();
			local nPersonalStock = pMember.GetPersonalStock()
			nTotalStock = nTotalStock + nPersonalStock;
			tbRet[nKinId][nMemberId] = nPersonalStock;
			pMember = pMemberItor.NextMember()
		end
		nKinId = pItor.NextKinId();
		pKin = KKin.GetKin(nKinId);
	end
	if nTotalStock ~= pTong.GetTotalStock() then
		Dbg:WriteLog("Tong", pTong.GetName(), "SyncTotalStock work!!", nTotalStock, pTong.GetTotalStock());
		pTong.SetTotalStock(nTotalStock);
		GlobalExcute{"Tong:SyncAllMemberStock_GS2", nTongId, nTotalStock, tbRet};
	end
end


-- 每周官衔维护检测
function Tong:UpDateOfficialMaintain_GC(nTongId, tbResult)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end

	-- 自动设置帮会官衔水平
	Tong:AdjustOfficialMaxLevel_GC(nTongId)
	local nMaxTongLevel = pTong.GetOfficialMaxLevel();
	local nOfficialLevel = pTong.GetOfficialLevel() or 0;
	local nTongOfficialLevel = math.min(nMaxTongLevel, nOfficialLevel);
	pTong.SetPreOfficialLevel(nTongOfficialLevel);

	-- 自动官衔维护
	for i = 1, Tong.MAX_TONG_OFFICIAL_NUM do
		if tbResult[i] then
			local nOfficialKinId = tbResult[i].nKinId;
			local nOfficialMemberId = tbResult[i].nMemberId;
			pTong.SetOfficialKin(i, nOfficialKinId);
			pTong.SetOfficialMember(i, nOfficialMemberId);
			local nRet = Tong:OfficialMaintain_GC(nTongId, nOfficialKinId, nOfficialMemberId)
			if nRet ~= 1 then
				local pKin = KKin.GetKin(nOfficialKinId);
				if pKin then
				 	local pMember = pKin.GetMember(nOfficialMemberId);
				 	if pMember then
						local szPlayerName = KGCPlayer.GetPlayerName(pMember.GetPlayerId());
						GlobalExcute{"Tong:OfficialMaintainFail_GS2", pMember.GetPlayerId()};
						-- 如果维护失败，发邮件通知
				 		if nRet == 0 and szPlayerName then
				 			SendMailGC(szPlayerName, "官衔自动维护失败！", "尊敬的"..szPlayerName.."：\n    由于您的个人资产额不足，本周的自动官衔维护失败，官衔已被系统暂时冻结。\n    请您准备足够的个人资产到<color=green>临安府的官衔官员<color>处手动进行官衔维护，维护成功后将立即恢复本周的官衔。个人资产可以在帮会面板查看，官衔相关的帮助信息可以查询帮助锦囊。\n          ");
						end
					end
				end
			end
		end
	end

	-- 更新版本号
	self.nJourNum = self.nJourNum + 1;
	pTong.SetTongFigureDataVer(self.nJourNum);
	GlobalExcute{"Tong:UpDateOfficialMaintain_GS2", nTongId, nTongOfficialLevel, tbResult, self.nJourNum};
	return 1;
end

-- 申请帮会官衔晋级
function Tong:IncreaseOfficialLevel_GC(nTongId, nKinId, nMemberId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end

	if Tong:CheckPresidentRight(nTongId, nKinId, nMemberId) ~= 1 then
		return 0;
	end
	local nTongLevel = pTong.GetPreOfficialLevel();
	local nMaxTongLevel = pTong.GetOfficialMaxLevel();
	local nMaxLevelByDomain = Tong:GetMaxLevelByDomain(nTongId);
	if nMaxTongLevel >= nMaxLevelByDomain or nMaxTongLevel >= #Tong.OFFICIAL_LEVEL_CONDITION then
		return 0;
	end

	local nLevel = nMaxTongLevel + 1;
	local nMoney = Tong.TONG_OFFICIAL_LEVEL_CHARGE[nLevel];
	if Tong:CostBuildFund_GC(nTongId, nKinId, nMemberId, nMoney) ~= 1 then
		return 0;
	end

	local nIncreaseNo = pTong.GetIncreaseOfficialNo();
	local nCurNo = KGblTask.SCGetDbTaskInt(DBTASK_OFFICIAL_MAINTAIN_NO);
	if nCurNo + 1 == nIncreaseNo then
		return 0;
	end


	pTong.SetIncreaseOfficialNo(nCurNo + 1);
	pTong.SetOfficialMaxLevel(nLevel);
	pTong.SetOfficialLevel(nLevel);
	self.nJourNum = self.nJourNum + 1;
	pTong.SetTongFigureDataVer(self.nJourNum);

	Dbg:WriteLog("Official", "帮会"..pTong.GetName(), "晋升到"..nLevel.."级");
	GlobalExcute{"Tong:IncreaseOfficialLevel_GS2", nTongId, nLevel, nCurNo + 1, self.nJourNum};
end

-- 选择帮会官衔水平
function Tong:ChoseOfficialLevel_GC(nTongId, nKinId, nMemberId, nLevel)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end

	if Tong:CheckPresidentRight(nTongId, nKinId, nMemberId) ~= 1 then
		return 0;
	end

	local nDomainNum = pTong.GetDomainCount();		-- 该帮会占领的领土数量
	if not nDomainNum or nDomainNum == 0 then
		return 0;
	end

	-- 如果领土是新手村
	if nDomainNum == 1 then
		local pDomainItor = pTong.GetDomainItor();
		local nDomainId = pDomainItor.GetCurDomainId();
		if Domain:GetDomainType(nDomainId) == "village" then
			return 0;
		end
	end

	-- 该帮会能选择的最大官衔水平
	local nMaxTongLevel = pTong.GetOfficialMaxLevel();
	if nMaxTongLevel < nLevel then
		return 0;
	end

	-- 设置帮会官衔水平
	pTong.SetOfficialLevel(nLevel);
	-- 更新版本号
	self.nJourNum = self.nJourNum + 1;
	pTong.SetTongFigureDataVer(self.nJourNum);
	GlobalExcute{"Tong:ChoseOfficialLevel_GS2", nTongId, nLevel, self.nJourNum};
end

-- 个人官衔维护
function Tong:OfficialMaintain_GC(nTongId, nKinId, nMemberId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	local pMember = pKin.GetMember(nMemberId);
	if not pMember then
		return 0;
	end

	-- 检测是不是股东会成员或首领
	if Tong:CanAppointOfficial(nTongId, nKinId, nMemberId) ~= 1 then
		return 0;
	end

	-- 在帮会官衔表中搜有自己的帮会官衔职位
	local nOfficialRank = self:GetOfficialRank(nTongId, nKinId, nMemberId);
	if nOfficialRank == 0 then
		return 2;
	end

	local nGCPlayerId = pMember.GetPlayerId();
	local nCurNo = KGblTask.SCGetDbTaskInt(DBTASK_OFFICIAL_MAINTAIN_NO);
	-- 判断是否已经维护过
	if nCurNo == KGCPlayer.OptGetTask(nGCPlayerId, KGCPlayer.TSK_MAINTAIN_OFFICIAL_NO) then
		return 2;
	end

	-- 检测帮会官衔水平
	local nTongLevel = pTong.GetPreOfficialLevel();
	if not nTongLevel or nTongLevel == 0 then
		GlobalExcute{"Tong:OfficialMaintainFail_GS2", pMember.GetPlayerId()};
		return 2;
	end

	-- 获得个人官衔Level
	local nPersonalLevel = Tong.OFFICIAL_TABLE[nTongLevel][nOfficialRank];
	if not nPersonalLevel then
		return 0;
	end

	-- 扣个人资产和股份
	local nStockAmount = self:CalculateStockCost(nTongId, nKinId, nMemberId,
												 tonumber(Tong.OFFICIAL_CHARGE[nPersonalLevel]));
	if not nStockAmount then
		return 0;
	end

	local nPersonalStock = pMember.GetPersonalStock() - nStockAmount;
	if nPersonalStock < 0 then
		return 0;
	end
	pMember.SetPersonalStock(nPersonalStock);

	local nTotalStock = pTong.GetTotalStock() - nStockAmount;

	if nTotalStock < 0 then
		nTotalStock = Tong:CaculateTotalStock(nTongId);
	end
	pTong.SetTotalStock(nTotalStock);

	KGCPlayer.OptSetTask(nGCPlayerId, KGCPlayer.TSK_MAINTAIN_OFFICIAL_NO, nCurNo);  --记录维护流水号
	KGCPlayer.OptSetTask(nGCPlayerId, KGCPlayer.TSK_OFFICIAL_LEVEL, nPersonalLevel);

	-- 更新版本号
	self.nJourNum = self.nJourNum + 1;
	pTong.SetTongFigureDataVer(self.nJourNum);
	return GlobalExcute{"Tong:OfficialMaintain_GS2",
		nTongId, nKinId, nMemberId, nGCPlayerId, nPersonalStock, nTotalStock, nCurNo, nPersonalLevel, self.nJourNum};
end

-- 根据领土数量调整帮会官衔水平
function Tong:AdjustOfficialMaxLevel_GC(nTongId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	local nBattleNo = KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO);
	local nConzoneTime = KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME);	-- 合服时间
	if GetTime() - nConzoneTime < 3 * 7 * 24 * 3600 then		-- 合服后3周内领土战官衔不会降级
		return 0;
	end
	local nMaxTongLevel = pTong.GetOfficialMaxLevel();
	local nMaxLevelByDomain = Tong:GetMaxLevelByDomain(nTongId);
	local nChoseLevel = pTong.GetOfficialLevel();
	if nMaxTongLevel > nMaxLevelByDomain then
		pTong.SetOfficialMaxLevel(nMaxLevelByDomain);

		if nChoseLevel > nMaxLevelByDomain then
			nChoseLevel = nMaxLevelByDomain;
			pTong.SetOfficialLevel(nMaxLevelByDomain);
		end
		Dbg:WriteLog("Official", "帮会"..pTong.GetName(), "调正到"..nMaxLevelByDomain.."级");
		-- 更新版本号
		self.nJourNum = self.nJourNum + 1;
		pTong.SetTongFigureDataVer(self.nJourNum);
		return GlobalExcute{"Tong:AdjustOfficialMaxLevel_GS2", nTongId, nMaxLevelByDomain, nChoseLevel, self.nJourNum};
	end
	return 0;
end

-- 开始评选优秀成员
function Tong:StartGreatMemberVote_GC(nTongId)
	local nSucess = 0;
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end

	if pTong.GetGreatMemberVoteState() ~= 1 then
		pTong.SetGreatMemberVoteState(1);
		nSucess = 1;
	end

	Tong:ClearGreatMemberVote(nTongId);
	return GlobalExcute{"Tong:StartGreatMemberVote_GS2", nTongId, nSucess};
end

-- 结束评选优秀成员
function Tong:EndGreatMemberVote_GC(nTongId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end

	if pTong.GetGreatMemberVoteState() == 0 then
		return 0;
	end

	local nGreatBonus = pTong.GetGreatBonus();
	local nGreatBonusPercent =  pTong.GetGreatBonusPercent();

	pTong.SetGreatMemberVoteState(0);
	local tbGreatMemberInfo = self:GreatMemberConfirm(nTongId);

	local nWeekGreatBonus = nGreatBonus * nGreatBonusPercent / 100 / 5;
	pTong.SetWeekGreatBonus(nWeekGreatBonus);

	local tbGreatMemberName = {};
	local nGreatMemberCout = 0;
	local szMsg = string.format("[%s] 帮会结束评选优秀成员, 优秀成员有:", pTong.GetName());
	
	if not tbGreatMemberInfo then
		szMsg = string.format("[%s] 帮会结束评选优秀成员, 没有评优秀成员", pTong.GetName());
		_G.TongLog(pTong.GetName(), Log.emKTONG_LOG_TONGSTRUCTURE , szMsg);
		return GlobalExcute{"Tong:EndGreatMemberVote_GS2", nTongId, nWeekGreatBonus, tbGreatMemberInfo}
	end
	
	for i = 1, self.GREAT_MEMBER_COUNT do
		local szPlayerName = "";
		if tbGreatMemberInfo[i] then
			local pKin = KKin.GetKin(tbGreatMemberInfo[i][1]);
			if pKin then
				local pMember = pKin.GetMember(tbGreatMemberInfo[i][2])
				if pMember then
					nGreatMemberCout = nGreatMemberCout + 1;
					szPlayerName = KGCPlayer.GetPlayerName(pMember.GetPlayerId());	
					szMsg = szMsg.."["..szPlayerName.."]";
				end
				local szPlayerMsg =  string.format("[%s]评优获胜", szPlayerName);
				KGCPlayer.PlayerLog(pMember.GetPlayerId(), Log.emKPLAYERLOG_TYPE_TONGDISMISS, szPlayerMsg);
			end
		end
		table.insert(tbGreatMemberName, szPlayerName);
	end
	if nGreatMemberCout > 0 then
		pTong.AddAffairGreatMember(unpack(tbGreatMemberName));
	end
	_G.TongLog(pTong.GetName(), Log.emKTONG_LOG_TONGSTRUCTURE , szMsg);
	return GlobalExcute{"Tong:EndGreatMemberVote_GS2", nTongId, nWeekGreatBonus, tbGreatMemberInfo};
end

-- 确定优秀成员
function Tong:GreatMemberConfirm(nTongId, bNoMail)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return;
	end
	local tbSort =
	{
		__lt = function(tbA, tbB)
			return tbA.nKey > tbB.nKey;
		end
	};
	local pItor = pTong.GetKinItor();
	local nKinId = pItor.GetCurKinId();
	local pKin = KKin.GetKin(nKinId);
	local tbRet = {};
	-- 按成员的评优票数排序
	while (pKin) do
		local pMemberItor = pKin.GetMemberItor();
		local pMember = pMemberItor.GetCurMember();
		while pMember do
			local tbTemp = {};
			tbTemp.nKey = pMember.GetGreatMemberVote();
			tbTemp.nKinId = nKinId;
			tbTemp.nMemberId = pMemberItor.GetCurMemberId();
			tbTemp.nPlayerId = pMember.GetPlayerId();
			if tbTemp.nKey > 0 then 
				setmetatable(tbTemp, tbSort);
				table.insert(tbRet, tbTemp);
			end
			pMember = pMemberItor.NextMember();
		end
		nKinId = pItor.NextKinId();
		pKin = KKin.GetKin(nKinId);
	end
	table.sort(tbRet);

	-- 按排序添加进帮会优秀成员列表
	local tbGreatMemberInfo = {};
	for i = 1, self.GREAT_MEMBER_COUNT do
		if tbRet[i] then
			local pKin = KKin.GetKin(tbRet[i].nKinId);
			local bRecord = 0;
			if tbRet[i] then
				pTong.SetGreatMemberId(i,tbRet[i].nMemberId);
				pTong.SetGreatKinId(i,tbRet[i].nKinId);
				tbGreatMemberInfo[i] = {tbRet[i].nKinId, tbRet[i].nMemberId};
				if bNoMail ~= 1 then
					local szSelfName = KGCPlayer.GetPlayerName(tbRet[i].nPlayerId);
					SendMailGC(szSelfName, "帮会优秀成员", "尊敬的"..szSelfName.."\n恭喜你当选为本周的帮会优秀成员。请于下周评选开始前前往武林盟主特使处领取优秀成员的奖励!");
					
					local nMemberVoteNo = KGblTask.SCGetDbTaskInt(DBTASK_GREAT_MEMBER_VOTE_NO);
					Dbg:WriteLog("GreatMemberConfirm", "优秀成员确定", "玩家名:"..szSelfName, "帮会ID:"..nTongId,
							 "家族ID:"..tbRet[i].nKinId, "成员ID:"..tbRet[i].nMemberId, "流水号:"..nMemberVoteNo);
				end
			end
		end
	end
	return tbGreatMemberInfo;
end

-- 优秀成员投票_GC
function Tong:ElectGreatMember_GC(nTongId, nSelfKinId, nSelfMemberId, nTagetKinId, nTagetMemberId, nMemberVoteNo)
	if Tong:CanElectGreatMember(nTongId, nSelfKinId, nSelfMemberId, nTagetKinId, nTagetMemberId) == 0 then
		return 0;
	end

	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return;
	end

	local pSelfKin = KKin.GetKin(nSelfKinId);
	local pTagetKin = KKin.GetKin(nTagetKinId);
	if not pSelfKin or not pTagetKin then
		return 0;
	end
	local pSelfMember = pSelfKin.GetMember(nSelfMemberId);
	local pTagetMember = pTagetKin.GetMember(nTagetMemberId);
	if not pSelfMember or not pTagetMember then
		return 0;
	end

	pSelfMember.SetMemberVoteNo(nMemberVoteNo);

	local nTotalStock = pTong.GetTotalStock();
	local nSelfStock = pSelfMember.GetPersonalStock();
	if nTotalStock < 0 or nSelfStock < 0 then
		return 0;
	end
	local nPersonalVote = math.floor( nSelfStock / nTotalStock * 10000);
	local nVote = pTagetMember.GetGreatMemberVote() + nPersonalVote;
	pTagetMember.SetGreatMemberVote(nVote);

	return GlobalExcute{"Tong:ElectGreatMember_GS2", pSelfMember.GetPlayerId(), nTagetKinId, nTagetMemberId, nVote};
end

-- 增加奖励基金GC
function Tong:AddGreatBonus_GC(nTongId, nMoney, nPlayerId)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end

	local nBonus = pTong.GetGreatBonus() + nMoney;
	if nBonus > 2000000000 or nBonus < 0 then
		return 0;
	end
	pTong.SetGreatBonus(nBonus);
	if nBonus > 10000 then
		if nPlayerId then
			local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
			Dbg:WriteLog("Tong", "增加帮会奖励基金"..nBonus, "帮会"..pTong.GetName(), "充值玩家"..szPlayerName);
		else
			Dbg:WriteLog("Tong", "增加帮会奖励基金"..nBonus, "帮会"..pTong.GetName());
		end
	end
	return GlobalExcute{"Tong:AddGreatBonus_GS2", nTongId, nBonus, nPlayerId, nMoney};
end

-- 接受奖励基金GC
function Tong:ReceiveGreatBonus_GC(nTongId, nSelfKinId, nSelfMemberId, nMoney, nAwardMode)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	local pSelfKin = KKin.GetKin(nSelfKinId);
	local pSelfMember = pSelfKin.GetMember(nSelfMemberId);
	local nPlayerId = pSelfMember.GetPlayerId();
	local bIsGreatMember = 0;
	for i = 1, self.GREAT_MEMBER_COUNT do
		if pTong.GetGreatMemberId(i) == nSelfMemberId and pTong.GetGreatKinId(i) == nSelfKinId then
			bIsGreatMember = 1;
		end
	end
	if bIsGreatMember ~= 1 then
		return 0;
	end
	local nCurNo = KGblTask.SCGetDbTaskInt(DBTASK_GREAT_MEMBER_VOTE_NO);
	if pSelfMember.GetReceiveGreatBonusNo() == nCurNo then
		return 0;
	end

	local nBonus = pTong.GetGreatBonus() - nMoney;
	if nBonus < 0 then
		return 0;
	end
	pTong.SetGreatBonus(nBonus);
	pSelfMember.SetReceiveGreatBonusNo(nCurNo);
	return GlobalExcute{"Tong:ReceiveGreatBonus_GS2", nTongId, nSelfKinId, nSelfMemberId, nBonus, nMoney, nAwardMode};
end

-- 设置帮会奖励基金比例GC
function Tong:AdjustGreatBonusPercent_GC(nTongId,  nSelfKinId, nSelfMemberId, nPercent)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	if Tong:CheckPresidentRight(nTongId, nSelfKinId, nSelfMemberId) ~= 1 then
		return 0;
	end
	pTong.SetGreatBonusPercent(nPercent);
	self.nJourNum = self.nJourNum + 1;
	return GlobalExcute{"Tong:AdjustGreatBonusPercent_GS2", nTongId, nPercent, self.nJourNum};
end

-- 加入联盟gc
function Tong:JoinUnion_GC(nTongId, szUnionName, nUnionId, bSync)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	pTong.SetBelongUnion(nUnionId);
--	local szMsg = string.format("[%s] 帮会加入了联盟 [%s]", pTong.GetName(), szUnionName);
--	_G.TongLog(pTong.GetName(),  Log.emKTONG_LOG_TONGSTRUCTURE, szLogMsg);
	if bSync == 1 then
	return GlobalExcute{"Tong:JoinUnion_GS2", nTongId, szUnionName, nUnionId} ;
	end
end

-- 离开联盟gc
function Tong:LeaveUnion_GC(nTongId, szUnionName, nMethod, bSync)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	--清空帮会相关数据
	pTong.SetBelongUnion(0);	
	if nMethod ~= 1 then
		local szMsg = string.format("[%s] 帮会离开联盟 [%s]", pTong.GetName(), szUnionName);
--		_G.TongLog(pTong.GetName(),  Log.emKTONG_LOG_TONGSTRUCTURE, szLogMsg);
	else
		local szMsg = string.format("[%s] 帮会被联盟 [%s]开除了", pTong.GetName(), szUnionName);
--		_G.TongLog(pTong.GetName(),  Log.emKTONG_LOG_TONGSTRUCTURE, szLogMsg);
	end
	local nLeaveTime = GetTime();
	pTong.SetLeaveUnionTime(nLeaveTime);
	self.nJourNum = self.nJourNum + 1;
	if bSync == 1 then
		return GlobalExcute{"Tong:LeaveUnion_GS2", nTongId, szUnionName, nLeaveTime, nMethod};
	end
end

-- 注册帮会公告
function Tong:RegisterTongAnnounce_GC(nTongId, nKinId, nMemberId, nTimes, nDistance, szMsg)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end

	-- 权限为长老，次数不超过20 ，时间间隔10～300秒
	if Tong:CheckSelfRight(nTongId, nKinId, nMemberId, 0) ~= 1 or 
	   nTimes < self.TONGANNOUNCE_MIN_TIMES or 
	   nTimes > self.TONGANNOUNCE_MAX_TIMES or 
	   nDistance < self.TONGANNOUNCE_MIN_DISTANCE or 
	   nDistance > self.TONGANNOUNCE_MAX_DISTANCE then
	   	return 0;
	end

	-- 之前的帮会公告正在发送，同一时间只能发送一条帮会公告。
	if pTong.GetAnnounceTimes() > 0 then
		return 0;
	end
	pTong.SetAnnounceTimes(nTimes);
	GlobalExcute{"Tong:TongAnnounce_GS2", nTongId, szMsg, nTimes};
	
	if nTimes > 0 then
		Timer:Register(nDistance * Env.GAME_FPS, self.TongAnnounce_GC, self, nTongId, szMsg);
	end
end

-- 帮会公告
function Tong:TongAnnounce_GC(nTongId, szMsg)
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end

	local nTimes = pTong.GetAnnounceTimes();
	nTimes = nTimes - 1;
	pTong.SetAnnounceTimes(nTimes);
	if nTimes <= 0 then
		GlobalExcute{"Tong:TongAnnounce_GS2", nTongId, "", 0};
		return 0;
	end
	GlobalExcute{"Tong:TongAnnounce_GS2", nTongId, szMsg, nTimes};
end

function Tong:ApplyStorageFundToKin_GC(nTongId, nSelfKinId, nSelfMemberId, nPlayerId, nMoney, nTargetKinId)
	if self:CheckSelfRight(nTongId, nSelfKinId, nSelfMemberId, self.POW_FUN) ~= 1 then
		return 0;
	end
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	local cTargetKin = KKin.GetKin(nTargetKinId)
	if not cTargetKin then
		return 0;
	end
	local tbDataTakeFund = self:GetExclusiveEvent(nTongId, self.REQUEST_TAKE_FUND);
	if tbDataTakeFund.nApplyEvent and tbDataTakeFund.nApplyEvent == 1 then		-- 已经有申请取钱 
		return 0;
	end
	local tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_STORAGE_FUND_TO_KIN);
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then		-- 已经有申请转存家族 
		return 0;
	end
	if not tbData.tbKinLastTimeList then
		tbData.tbKinLastTimeList = {};
	end
	if tbData.tbKinLastTimeList[nTargetKinId] and GetTime() - tbData.tbKinLastTimeList[nTargetKinId] < self.STORAGEFUND_TO_KIN_TIME then
		return 0;
	end
	
	tbData.nApplyEvent = 1;
	if not tbData.tbApplyRecord then
		tbData.tbApplyRecord = {};
	end
	tbData.tbApplyRecord.nPlayerId = nPlayerId;
	tbData.tbApplyRecord.nKinId = nSelfKinId;
	tbData.tbApplyRecord.nAmount = nMoney;
	tbData.tbApplyRecord.nPow = self.POW_FUN;
	tbData.tbApplyRecord.nTargetKinId = nTargetKinId;
	tbData.nCount = 0;
	tbData.tbAccept = {};	--表态家族表
	tbData.tbApplyRecord.nTimerId = Timer:Register(
		self.TAKEFUND_APPLY_LAST,
		self.CancelExclusiveEvent_GC,
		self,
		nTongId,
		self.REQUEST_STORAGE_FUND_TO_KIN
	);
	return GlobalExcute{"Tong:ApplyStorageFundToKin_GS2",
			nTongId,
			nSelfKinId,
			nPlayerId,
			nMoney,
			nTargetKinId,	
		};
end

function Tong:StorageFundToKin_GC(nTongId, nPlayerId, nMoney, nTargetKinId)
	local tbData = self:GetExclusiveEvent(nTongId, self.REQUEST_STORAGE_FUND_TO_KIN);
	if tbData.tbKinLastTimeList[nTargetKinId] and GetTime() - tbData.tbKinLastTimeList[nTargetKinId] < self.STORAGEFUND_TO_KIN_TIME then
		return 0;
	end
	local cTong = KTong.GetTong(nTongId);
	if not cTong then
		return 0;
	end
	local cTargetKin = KKin.GetKin(nTargetKinId)
	if not cTargetKin then
		return 0;
	end
	if cTargetKin.GetBelongTong() ~= nTongId then
		return 0;
	end
	local nCurTongFund = cTong.GetMoneyFund();
	if nCurTongFund > Tong.MAX_TONG_FUND then
		cTong.SetMoneyFund(0);
		Dbg:WriteLog("tongfund over", cTong.GetName(), nTongId, "tongmoney:" .. nCurTongFund, "storemoney:" .. nMoney, nTargetKinId);
		return 0;
	end
	local nCurKinFund = cTargetKin.GetMoneyFund();
	if nMoney + nCurKinFund > Kin.MAX_KIN_FUND then
		return GlobalExcute{"Tong:KinFundOverFlow", nPlayerId};
	end
	if (nMoney <= nCurTongFund) and (nMoney > 0) then
		nCurTongFund = nCurTongFund - nMoney;
		nCurKinFund = nCurKinFund + nMoney;
		cTong.SetMoneyFund(nCurTongFund);
		cTargetKin.SetMoneyFund(nCurKinFund);
		self.nJourNum = self.nJourNum + 1;
		Kin.nJourNum = Kin.nJourNum + 1;
		cTong.SetTongDataVer(self.nJourNum);
		cTargetKin.SetKinDataVer(Kin.nJourNum);
		if not tbData.tbKinLastTimeList then
			tbData.tbKinLastTimeList = {};
		end
		tbData.tbKinLastTimeList[nTargetKinId] = GetTime();
		local szPlayerName = KGCPlayer.GetPlayerName(nPlayerId);
		local szTargetKinName = cTargetKin.GetName();
		local szTongName = cTong.GetName();
		if nMoney >= self.STORAGE_FUND_TO_KIN_APPLY then
			cTong.AddAffairStorageFundToKin(szPlayerName, szTargetKinName, tostring(nMoney));
			cTargetKin.AddAffairGetFundFromTong(szTongName, tostring(nMoney));
		end
		if (nMoney > 10000) then
			_G.TongLog(szTongName, Log.emKTONG_LOG_TONGFUND, szPlayerName.. "向" .. szTargetKinName .. " 转存 ".. nMoney .. "两帮会资金");
			_G.KinLog(szTargetKinName, Log.emKKIN_LOG_TYPE_KINFUND, szTongName .. "向家族转入" .. nMoney .. "两帮会资金");
			Dbg:WriteLog("帮会资金", "帮会名字：" .. szTongName, "申请人:" .. szPlayerName, "目标家族：" .. szTargetKinName, "资金数额:" .. nMoney);
		end
		GlobalExcute{"Tong:StorageFundToKin_GS2", nTongId, nPlayerId, self.nJourNum, Kin.nJourNum, nMoney, nCurTongFund, nCurKinFund, nTargetKinId};
	end
	if (tbData.nApplyEvent == 1) then
		if tbData.tbApplyRecord and tbData.tbApplyRecord.nTimerId then
			Timer:Close(tbData.tbApplyRecord.nTimerId);
		end
		self:DelExclusiveEvent(nTongId, self.REQUEST_STORAGE_FUND_TO_KIN);
	end
end
	
function Tong:WriteLogTongInfo()	
	local PerKinEvents_cNextTong, PerKinEvents_nNextTong = KTong.GetFirstTong();
	local nCount = 1;
	while (PerKinEvents_cNextTong and nCount <= 100000) do		
		local pTong = KTong.GetTong(PerKinEvents_nNextTong);
		if pTong then 		
			StatLog:WriteStatLog("stat_info", "banghui", "zijin", 0, string.format("%s,%s,%s,%s", pTong.GetName(), pTong.GetMoneyFund(), pTong.GetBuildFund(), pTong.GetGreatBonus()));
		end
		nCount = nCount + 1;
		PerKinEvents_cNextTong, PerKinEvents_nNextTong = KTong.GetNextTong(PerKinEvents_nNextTong);
	end
end

GCEvent:RegisterGCServerShutDownFunc(Tong.WriteLogTongInfo, Tong);
