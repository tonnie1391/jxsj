-------------------------------------------------------------------
--File: unionlogic_gc.lua
--Author: zhangyuhua
--Date: 2009-6-6 15:17
--Describe: Gamecenter 联盟逻辑
-------------------------------------------------------------------
if not Union.nJourNum then
	Union.nJourNum = 0;
end

-- 创建联盟申请_GC
function Union:ApplyCreateUnion_GC(tbPlayerInfo, szUnionName, nPlayerId)
	-- 合服一周内不能创建联盟
	if GetTime() < KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME) + 7 * 24 * 60 * 60 then
		return GlobalExcute{"Union:ApplyCreateUnion_GS2", nPlayerId, 0};
	end

	-- 帮会检测
	if Union:CheckTong(tbPlayerInfo) ~= 1 then
		return GlobalExcute{"Union:ApplyCreateUnion_GS2", nPlayerId, 0};
	end

	if Domain:GetBattleState_GC() == Domain.PRE_BATTLE_STATE or Domain:GetBattleState_GC() == Domain.BATTLE_STATE then
		return GlobalExcute{"Union:ApplyCreateUnion_GS2", nPlayerId, 0};
	end
	
	local tbTongId = {};
	for i, tbInfo in ipairs (tbPlayerInfo) do 
		table.insert(tbTongId, tbInfo.dwTongId);
	end
	if Union:CreateUnion_GC(tbTongId, szUnionName) ~= 0 then
		return GlobalExcute{"Union:ApplyCreateUnion_GS2", nPlayerId, 1};
	end
end

-- 帮会申请加入联盟
function Union:ApplyTongJoin_GC(nUnionId, nTongId, nKinId, nMemberId, nMasterTongId, nMasterKinId, nMasterMemberId)
	if not nUnionId or not nTongId or not nKinId or not nMemberId or not nMasterTongId then
		return 0;
	end
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	local nBelongUnionId = pTong.GetBelongUnion();
	if nBelongUnionId and nBelongUnionId ~= 0 then
		return 0;
	end
	-- 占有领土的数量不能>1
	if pTong.GetDomainCount() > self.MAX_TONG_DOMAIN_NUM then
		return 0;
	end
	local nTime = GetTime()
	if nTime - pTong.GetLeaveUnionTime() < Tong.TONG_LEVE_UNION_LAST then
		return 0;
	end
	if Tong:CheckSelfRight(nTongId, nKinId, nMemberId, Tong.POW_MASTER) ~= 1 then
		return 0;
	end
	local pUnion = KUnion.GetUnion(nUnionId);
	if not pUnion then
		return 0;
	end
	if pUnion.GetTongCount() >= self.MAX_TONG_NUM then
		return 0;
	end
	if pUnion.GetUnionMaster() ~= nMasterTongId then
		return 0;
	end
	if Tong:CheckSelfRight(nMasterTongId, nMasterKinId, nMasterMemberId, Tong.POW_MASTER) ~= 1 then
		return 0;
	end
	if Domain:GetBattleState_GC() == Domain.PRE_BATTLE_STATE or Domain:GetBattleState_GC() == Domain.BATTLE_STATE then
		return 0;
	end
	if Union:TongAdd_GC(nUnionId, nTongId) ~= 0 then
		return 0;
	end
	return 1;
end

-- 帮会申请退出联盟
function Union:ApplyTongLeave_GC(nTongId, nKinId, nMemberId)
	if not nTongId or not nKinId or not nMemberId then
		return 0;
	end
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	if Tong:CheckSelfRight(nTongId, nKinId, nMemberId, Tong.POW_MASTER) ~= 1 then
		return 0;
	end
	local nUnionId = pTong.GetBelongUnion();
	if not nUnionId or nUnionId == 0 then
		return 0;
	end
	local pUnion = KUnion.GetUnion(nUnionId);
	if not pUnion then
		return 0;
	end
	if Domain:GetBattleState_GC() == Domain.PRE_BATTLE_STATE or Domain:GetBattleState_GC() == Domain.BATTLE_STATE then
		return 0;
	end
	if Union:TongDel_GC(nUnionId, nTongId, 0) ~= 0 then
		return 0;
	end
end

-- 申请盟主移交
function Union:ApplyChangeUnionMaster(nUnionId, nNewMasterTongId, nPlayerId)
	if not nUnionId or nUnionId == 0 or not nNewMasterTongId or not nPlayerId then
		return 0;
	end
	local pUnion = KUnion.GetUnion(nUnionId);
	if not pUnion then
		return 0;
	end
	local pTong = KTong.GetTong(nNewMasterTongId);
	if not pTong then
		return 0;
	end
	local nUnionMasterId = Tong:GetMasterId(nNewMasterTongId);
	if not nUnionMasterId then
		return 0;
	end
	if Union:GetUnionMasterId(nUnionId) ~= nPlayerId then
		return 0;
	end
	if Domain:GetBattleState_GC() == Domain.PRE_BATTLE_STATE or Domain:GetBattleState_GC() == Domain.BATTLE_STATE then
		return 0;
	end
	if Union:ChangeUnionMaster_GC(nUnionId, 1, nNewMasterTongId) ~= 1 then
		return 0;
	end
end

-- 申请分配领土
function Union:ApplyDispenseDomain_GC(nUnionId, nTongId, nDomainId, nPlayerId)
	local pUnion = KUnion.GetUnion(nUnionId);
	if not pUnion then
		return 0;
	end
	if Union:GetUnionMasterId(nUnionId) ~= nPlayerId then
		return 0;
	end
	if Domain:GetBattleState_GC() == Domain.BATTLE_STATE then
		return 0;
	end
	local bHasDomain = 0;
	local pDomainItor = pUnion.GetDomainItor();
	local nCurDomainId =  pDomainItor.GetCurDomainId();
	while nCurDomainId ~= 0 do
		if nDomainId == nCurDomainId then
			bHasDomain = 1;
			break;
		end
		nCurDomainId =  pDomainItor.NextDomainId();
	end
	if bHasDomain == 0 then
		return 0;
	end
	local pTong = KTong.GetTong(nTongId)
	if not pTong then 
		return 0;
	end
	
	Domain:SetDomainOwner_GC(nDomainId, nTongId, 1);
	--Log 记录
	local szMsg = string.format("[%s] 联盟分配了领土 [%d] 给帮会 [%s]", pUnion.GetName(), nDomainId, pTong.GetName());
	Dbg:WriteLog("Union", "分配领土", szMsg);
	
	if pTong.GetDomainCount() > 1 then
		 Union:TongDel_GC(nUnionId, nTongId, 0);
	end
end

-- 创建联盟_GC, tbTongId里第一个帮会帮主为盟主
function Union:CreateUnion_GC(tbTongId, szUnionName)
	if not tbTongId or type(tbTongId) ~= "table" or not szUnionName then
		return 0;
	end
	print("CreateUnion_GC")
	
	-- 以下检查不可跳过
	-- id检查
	local nCheckId = KTong.GetTongNameId(szUnionName)
	if Tong:ApplyUnionName(nCheckId) ~= 1 then
		return 0;
	end
	-- 帮会是否合法
	for i, nTongId in ipairs(tbTongId) do
		local pTong = KTong.GetTong(nTongId)
		if not pTong or pTong.GetBelongUnion() ~= 0 then
			return 0;
		end
	end

	local nCreateTime = GetTime();
	local pUnion, nUnionId = self:CreateUnion(tbTongId, szUnionName, nCreateTime)
	if pUnion == nil then
		return 0;
	end
	_DbgOut("CreateUnion_GC succeed")
	for _, nTongId in ipairs(tbTongId) do
		Tong:JoinUnion_GC(nTongId, szUnionName, nUnionId);
	end
	
	--Log 记录	
	local nMasterId = Tong:GetMasterId(tbTongId[1]);
	local szUnionMasterName = KGCPlayer.GetPlayerName(nMasterId);
	local szMsg = string.format("[%s] 创建了联盟[%s]", szUnionMasterName, szUnionName);
	Dbg:WriteLog("Union", "创建联盟", szMsg);

	GlobalExcute{"Union:CreateUnion_GS2", tbTongId, szUnionName, nCreateTime};
	Domain:UpdateDataDomainColor();	
end

-- 解散联盟_GC
function Union:DisbandUnion_GC(nUnionId, bNoMsg)
	local pUnion = KUnion.GetUnion(nUnionId)
	if not pUnion then
		return 0;
	end
	local szUnionName = pUnion.GetName();
	print("DisbandTong_GC", szUnionName);
	local nUnionMaster = pUnion.GetUnionMaster();
	local nUnionMasterId = Tong:GetMasterId(nUnionMaster);

	local pTongItor = pUnion.GetTongItor();
	local nTongId = pTongItor.GetCurTongId();
	while nTongId ~= 0 do
		local nNextTongId = pTongItor.NextTongId();
		Tong:LeaveUnion_GC(nTongId, pUnion.GetName());
		nTongId = nNextTongId;
	end

	-- 清空领土
	local pDomainItor = pUnion.GetDomainItor();
	local nDomainId = pDomainItor.GetCurDomainId();
	while nDomainId ~= 0 do
		local nNextDomainId = pDomainItor.NextDomainId();
		Domain:SetDomainOwner_GC(nDomainId, 0);
		nDomainId = nNextDomainId;
	end
	
	KUnion.DelUnion(nUnionId);

	-- Log 记录
	local szMsg = string.format("[%s] 联盟解散", szUnionName);
	Dbg:WriteLog("Union", "联盟解散", szMsg);

	local nLeaveTime = GetTime();
	return GlobalExcute{"Union:DisbandUnion_GS2", nUnionId, nLeaveTime, bNoMsg}
end

--增加帮会成员_GC
function Union:TongAdd_GC(nUnionId, nTongId)
	local pUnion = KUnion.GetUnion(nUnionId);
	if not pUnion then
		return 0;
	end
	local pTong = KTong.GetTong(nTongId);
	if not pTong then
		return 0;
	end
	local nCreateTime = GetTime();
	pUnion.AddTong(nTongId, nCreateTime);
	
	local szUnionName = pUnion.GetName();
	Tong:JoinUnion_GC(nTongId, szUnionName, nUnionId, 1);
	
	-- Log 记录
	local szMsg = string.format("[%s]帮会加入联盟[%s]", pTong.GetName(), szUnionName);
	Dbg:WriteLog("Union", "帮会加入联盟", szMsg);
	
	local nDataVer =  Domain:UpdateDataVer();
	GlobalExcute{"Union:TongAdd_GS2", nUnionId, nTongId, nCreateTime, nDataVer};
end

-- 删除帮会成员_GC, nMethod 为 1是开除， 0是离开
function Union:TongDel_GC(nUnionId, nTongId, nMethod)
	local pUnion = KUnion.GetUnion(nUnionId)
	if not pUnion then
		return 0;
	end

	local nRet = pUnion.DelTong(nTongId);
	if nRet == nil or nRet == 0 then
		return 0;
	end
	Tong:LeaveUnion_GC(nTongId, pUnion.GetName(), nMethod, 1);
	GlobalExcute{"Union:TongDel_GS2", nUnionId, nTongId, nMethod};
	Domain:UpdateDataDomainColor();

	local pTong = KTong.GetTong(nTongId);
	if pTong then
		if nMethod == 0 and pTong then
			local szMsg = string.format("[%s] 帮会离开联盟 [%s]", pTong.GetName(), pUnion.GetName());
			Dbg:WriteLog("Union", "帮会离开联盟", szMsg);
		else
			local szMsg = string.format("[%s] 帮会被联盟 [%s]开除", pTong.GetName(), pUnion.GetName());
			Dbg:WriteLog("Union", "帮会被联盟开除", szMsg);
		end
	end

	local nTongCount = pUnion.GetTongCount(); -- 帮会数量
	if nTongCount < 2 then
		self:DisbandUnion_GC(nUnionId);
		return 0;
	end
	
	if nTongId == pUnion.GetUnionMaster() then		-- 帮会是盟主帮会
		self:ChangeUnionMaster_GC(nUnionId);
		return 0;
	end
end

--更换盟主_GC : 
--	  nSync 为是否同步，1同步，2不同步，默认（nSync不填）同步， (nMasterTongId不填)新盟主按威望排
function Union:ChangeUnionMaster_GC(nUnionId, nSync, nMasterTongId)
	if not nSync then
		nSync = 1;
	end
	local pUnion = KUnion.GetUnion(nUnionId);
	if not pUnion then
		return 0;
	end
	
	local nNewTongId = 0;
	local nNewMasterId = 0;
	if nMasterTongId and nMasterTongId ~= 0 then
		nNewTongId = nMasterTongId;
		nNewMasterId = Tong:GetMasterId(nNewTongId);
	else	
		local nMaxPrestige = 0;
		local pTongItor = pUnion.GetTongItor();
		local nTongId = pTongItor.GetCurTongId();
		while nTongId ~= 0 do
			local nMasterId = Tong:GetMasterId(nTongId);
			local nPrestige = KGCPlayer.GetPlayerPrestige(nMasterId);
			if nMaxPrestige < nPrestige then
				nMaxPrestige = nPrestige;
				nNewTongId = nTongId;
				nNewMasterId = nMasterId;
			end
			nTongId = pTongItor.NextTongId();
		end
	end
	
	if nNewTongId == 0 then
		return 0;
	end
	
	pUnion.SetUnionMaster(nNewTongId);
	
	local szNewMasterName = KGCPlayer.GetPlayerName(nNewMasterId);
	if szNewMasterName then
		local szMsg = string.format("[%s] 更换盟主为[%s]", pUnion.GetName(), szNewMasterName);
		Dbg:WriteLog("Union", "更换盟主", szMsg);
	end
	if nSync == 1 then
		return GlobalExcute{"Union:ChangeMaster_GS2", nUnionId, nNewTongId, szNewMasterName};
	end
	return 1;
end

-- 解散所有联盟
function Union:DisbandAllUnion_GC()
	print("Union:DisbandAllUnion_GC()");
	local pUnion, nUnionId = KUnion.GetFirstUnion();
	while pUnion do
		Union:DisbandUnion_GC(nUnionId, 1);
		pUnion, nUnionId = KUnion.GetNextUnion(nUnionId);
	end
end

-- 调整联盟，移除解散了的帮会
function Union:RemoveDisbandTong_GC()
	local pUnion, nUnionId = KUnion.GetFirstUnion();
	while pUnion do
		local pTongItor = pUnion.GetTongItor();
		local nTongId = pTongItor.GetCurTongId();
		while nTongId ~= 0 do
			local nNextTongId = pTongItor.NextTongId();
			local pTong = KTong.GetTong(nTongId);
			if not pTong then
				Union:TongDel_GC(nUnionId, nTongId, 0);
			end
			nTongId = nNextTongId;
		end
		pUnion, nUnionId = KUnion.GetNextUnion(nUnionId);
	end
end
GCEvent:RegisterGCServerStartFunc(Union.RemoveDisbandTong_GC, Union);