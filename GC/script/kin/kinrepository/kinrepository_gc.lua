-- 文件名　：homeland_gc.lua
-- 创建者　：huangxiaoming
-- 创建时间：2012-06-13 9:18:10
-- 描  述  ：

if not MODULE_GC_SERVER then
	return;
end

function KinRepository:SetRoomAuthority_GC(dwKinId, nRoom, nAuthority)
	if self.IS_OPEN ~= 1 then
		return 0;
	end
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		return 0;
	end
	if nRoom < 0 or nRoom > self.ROOMTASK_END - self.ROOMTASK_BEGIN then
		return 0;
	end
	if nAuthority < self.AUTHORITY_EVERYONE or nAuthority > self.AUTHORITY_FIGURE_CAPTAIN then
		return 0;
	end
	local uInfo = cKin.GetTask(self.ROOMTASK_BEGIN + nRoom);
	local uNewInfo = Lib:SetBits(uInfo, nAuthority, self.BITS_AUTHORITY_BEG, self.BITS_AUTHORITY_END);
	cKin.SetTask(self.ROOMTASK_BEGIN + nRoom, uNewInfo);
	GlobalExcute{"KinRepository:SetRoomInfo_GS2", nRoom, uNewInfo};
	return 1;
end

function KinRepository:SetRoomExp_GC(dwKinId, nRoom, nExp)
	if self.IS_OPEN ~= 1 then
		return 0;
	end
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		return 0;
	end
	if nRoom < 0 or nRoom > self.ROOMTASK_END - self.ROOMTASK_BEGIN then
		return 0;
	end
	if nExp < 0 or nExp > 4190000 then
		return 0;
	end
	local uInfo = cKin.GetTask(self.ROOMTASK_BEGIN + nRoom);
	local uNewInfo = Lib:SetBits(uInfo, nExp, self.BITS_EXP_BEG, self.BITS_EXP_END);
	cKin.SetTask(self.ROOMTASK_BEGIN + nRoom, uNewInfo);
	GlobalExcute{"KinRepository:SetRoomInfo_GS2", nRoom, uNewInfo};
	return 1;
end

function KinRepository:SetRoomSize_GC(dwKinId, nRoom, nSize)
	if self.IS_OPEN ~= 1 then
		return 0;
	end
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		return 0;
	end
	local nRoomSize, nPermit, nExp = self:GetRoomInfo(dwKinId, nRoom);
	if not nRoomSize then
		return 0;
	end
	if nRoomSize >= nSize then
		return 0;
	end
	if nSize > self.MAX_ROOM_SIZE then
		print("家族仓库设置的大小超过最大值：", dwKinId, nRoom, nSize);
		nSize = slef.MAX_ROOM_SIZE;
	end
	local uInfo = cKin.GetTask(self.ROOMTASK_BEGIN + nRoom);
	local uNewInfo = Lib:SetBits(uInfo, nSize, self.BITS_SIZE_BEG, self.BITS_SIZE_END);
	cKin.SetTask(self.ROOMTASK_BEGIN + nRoom, uNewInfo);
	GlobalExcute{"KinRepository:SetRoomInfo_GS2", dwKinId, nRoom, uNewInfo};
	return 1;
end

------玩家存取物品成功回调-------------------
-- 家族的ID可能与玩家的家族ID不一致，玩家操作完成的时候有可能已经被踢出家族
-- 不要干太复杂的事了，会影响效率的
function KinRepository:TakeSucceed(dwKinId, nPlayerId, nRoom, nRoomIndex, nGenre, nDetailType, nParticular, nLevel, nCount)
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		return 0;
	end
	local szName = KGCPlayer.GetPlayerName(nPlayerId);
	local nRoomType = self:GetRoomType(nRoom);
	local nTimes = GetTime();
	cKin.AddRepRecord(nRoomType, self.OPERATE_TYPE_TAKE, nTimes, szName, nGenre, nDetailType, nParticular, nLevel, nCount);
	GlobalExcute{"KinRepository:AddRecord_GS2",dwKinId, nRoomType, self.OPERATE_TYPE_TAKE, nTimes, szName, nGenre, nDetailType, nParticular, nLevel, nCount};
end

function KinRepository:StoreSucceed(dwKinId, nPlayerId, nRoom, nRoomIndex, nGenre, nDetailType, nParticular, nLevel, nCount)
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		return 0;
	end
	local szName = KGCPlayer.GetPlayerName(nPlayerId);
	local nRoomType = self:GetRoomType(nRoom);
	local nTimes = GetTime();
	cKin.AddRepRecord(nRoomType, self.OPERATE_TYPE_STORE, nTimes, szName, nGenre, nDetailType, nParticular, nLevel, nCount);
	GlobalExcute{"KinRepository:AddRecord_GS2",dwKinId, nRoomType, self.OPERATE_TYPE_STORE, nTimes, szName, nGenre, nDetailType, nParticular, nLevel, nCount};
end

function KinRepository:TakeAndStoreSuceed(dwKinId, nPlayerId, nRoom, nRoomIndex, nTakeGenre, nTakeDetailType, nTakeParticular, nTakeLevel, nTakeCount, nStoreGenre, nStoreDetailType, nStoreParticular, nStoreLevel, nStoreCount)
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		return 0;
	end
	local szName = KGCPlayer.GetPlayerName(nPlayerId);
	local nRoomType = self:GetRoomType(nRoom);
	local nTimes = GetTime();
	cKin.AddRepRecord(nRoomType, self.OPERATE_TYPE_TAKE, nTimes, szName, nTakeGenre, nTakeDetailType, nTakeParticular, nTakeLevel, nTakeCount);
	cKin.AddRepRecord(nRoomType, self.OPERATE_TYPE_STORE, nTimes, szName, nStoreGenre, nStoreDetailType, nStoreParticular, nStoreLevel, nStoreCount);
	GlobalExcute{"KinRepository:AddRecord_GS2",dwKinId, nRoomType, self.OPERATE_TYPE_TAKE, nTimes, szName, nTakeGenre, nTakeDetailType, nTakeParticular, nTakeLevel, nTakeCount};
	GlobalExcute{"KinRepository:AddRecord_GS2",dwKinId, nRoomType, self.OPERATE_TYPE_STORE, nTimes, szName, nStoreGenre, nStoreDetailType, nStoreParticular, nStoreLevel, nStoreCount};
end

function KinRepository:ApplyTakeAuthority_GC(nPlayerId, dwKinId, nMemberId)
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		return;
	end
	if self:CheckRepAuthority(dwKinId, nMemberId, self.AUTHORITY_ASSISTANT) ~= 1 then
		return;
	end
	local tbData = Kin:GetExclusiveEvent(dwKinId, Kin.KIN_EVENT_TAKE_REPOSITORY);
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
		return;
	end
	tbData.nApplyEvent = 1;
	if not tbData.tbApplyRecord then
		tbData.tbApplyRecord = {};
	end
	tbData.tbApplyRecord.nMemberId = nMemberId;
	tbData.tbApplyRecord.nPow = KinRepository.AUTHORITY_ASSISTANT;
	tbData.tbApplyRecord.nPlayerId = nPlayerId;
	tbData.tbAccept = {};
	tbData.nAgreeCount = self.TAKE_AUTHORITY_AGREE_COUNT;
	tbData.tbApplyRecord.nTimerId = Timer:Register(
		self.TAKE_REPOSITORY_APPLY_LAST,
		Kin.CancelExclusiveEvent_GC,
		Kin,
		dwKinId,
		Kin.KIN_EVENT_TAKE_REPOSITORY
		);
	GlobalExcute{"KinRepository:ApplyTakeAuthority_GS2", nPlayerId, dwKinId, nMemberId, nRoom};
end

function KinRepository:AgreeTakeAuthority_GC(dwKinId, nMemberId, nPlayerId)
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		return;
	end
	if self:CheckRepAuthority(dwKinId, nMemberId, self.AUTHORITY_ASSISTANT) ~= 1 then
		return;
	end
	GlobalExcute{"KinRepository:AgreeTakeAuthority_GS2", nPlayerId, dwKinId};
	local tbData = Kin:GetExclusiveEvent(dwKinId, Kin.KIN_EVENT_TAKE_REPOSITORY);
	if tbData.nApplyEvent and tbData.nApplyEvent == 1 then
		if tbData.tbApplyRecord and tbData.tbApplyRecord.nTimerId then
			Timer:Close(tbData.tbApplyRecord.nTimerId);
		end
		Kin:DelExclusiveEvent(dwKinId, Kin.KIN_EVENT_TAKE_REPOSITORY);
	end
end

-- 开启仓库功能
function KinRepository:SetRepositoryFlag_GC(nKinId, nMemberId, nPlayerId)
	local nRet, cKin, cMember = Kin:CheckSelfRight(nKinId, nMemberId, 1)
	if nRet ~= 1 then
		return 0;
	end
	if cKin.GetIsOpenRepository() == 1 then
		return 0;
	end
	cKin.SetIsOpenRepository(1);
	cMember.SetRepAuthority(KinRepository.AUTHORITY_FIGURE_CAPTAIN);-- 开启的时候给族长设置权限
	GlobalExcute{"KinRepository:SetRepositoryFlag_GS2", nKinId, nMemberId};
	StatLog:WriteStatLog("stat_info", "jiazucangku", "open", nPlayerId, cKin.GetName());
end

function KinRepository:ExtendRep_GC(nType, dwKinId, nExcutorId, nPlayerId)
	local nRet, cKin = Kin:CheckSelfRight(dwKinId, nExcutorId, 1)
	if nRet ~= 1 then
		return 0;
	end
	if cKin.GetIsOpenRepository() == 0 then
		return 0;
	end
	local nFreeLevel = cKin.GetFreeRepBuildLevel();
	local nLimitLevel = cKin.GetLimitRepBuildLevel();
	local nLevel = 0;
	local nFullExtendFlag = 0; -- 是否扩展完全
	if nType == KinRepository.REPTYPE_FREE then -- 自由仓库
		nLevel = nFreeLevel;
		if nFreeLevel + 1>= #self.BUILD_VALUE[self.REPTYPE_FREE] and nLimitLevel >= #self.BUILD_VALUE[self.REPTYPE_LIMIT] then
			nFullExtendFlag = 1;
		end
	elseif nType == KinRepository.REPTYPE_LIMIT then	-- 限制仓库
		nLevel = nLimitLevel;
		if nLimitLevel + 1 >= #self.BUILD_VALUE[self.REPTYPE_LIMIT] and nFreeLevel >= #self.BUILD_VALUE[self.REPTYPE_FREE] then
			nFullExtendFlag = 1;
		end
	end
	if nLevel >= #KinRepository.BUILD_VALUE[nType] then
		return;
	end
	local nBuildValue = cKin.GetRepBuildValue();
	if nBuildValue < KinRepository.BUILD_VALUE[nType][nLevel+1][1] then
		return;
	end
	local nMoney = cKin.GetMoneyFund();
	local nExtendMoney = self:GetExtendMoney(nType, nLevel+1);
	local nCheckResult = Kin:CheckHaveEnoughMoney(dwKinId, nExtendMoney);
	if nCheckResult ~= 1 then
		return 0;
	end
	Kin.nJourNum = Kin.nJourNum + 1
	cKin.SetKinDataVer(Kin.nJourNum)
	local nRemainMoney = nMoney - nExtendMoney;
	local nRemainBuildValue = nBuildValue - KinRepository.BUILD_VALUE[nType][nLevel+1][1];
	-- 查找扩展的仓库页
	for _, nRoom in ipairs(KinRepository.ROOM_SET[nType]) do
		local nRoomSize = self:GetRoomInfo(dwKinId, nRoom);
		if nRoomSize < KinRepository.MAX_ROOM_SIZE then -- 找到没满的扩展一下
			assert(nRoomSize + KinRepository.EXTEND_ONCESIZE <= KinRepository.MAX_ROOM_SIZE);
			-- 升满了把建设度设0
			if nFullExtendFlag == 1 then
				nRemainBuildValue = 0;
			end
			cKin.SetRepBuildValue(nRemainBuildValue);
			cKin.SetMoneyFund(nRemainMoney);
			Dbg:WriteLog("仓库扩容：", nType, nLevel + 1, nExtendMoney);
			if nType == KinRepository.REPTYPE_FREE then -- 自由仓库
				cKin.SetFreeRepBuildLevel(nLevel + 1);
			elseif nType == KinRepository.REPTYPE_LIMIT then	-- 限制仓库
				cKin.SetLimitRepBuildLevel(nLevel + 1);
			end
			self:SetRoomSize_GC(dwKinId, nRoom, nRoomSize + KinRepository.EXTEND_ONCESIZE);
			return GlobalExcute{"KinRepository:ExtendRep_GS2", nType, dwKinId, nLevel, nRemainBuildValue, nRemainMoney, Kin.nJourNum, nPlayerId};
		end
	end
end

-- 加建设度
function KinRepository:AddRepBuildValue_GC(dwKinId, nAddValue)
	local cKin = KKin.GetKin(dwKinId);
	if not cKin then
		return;
	end
	local nBuildValue = cKin.GetRepBuildValue();
	if nBuildValue >= 2000000000 then -- 保护一下别超了
		return;
	end
	local nFreeLevel = cKin.GetFreeRepBuildLevel();
	local nLimitLevel = cKin.GetLimitRepBuildLevel();
	-- 都满级了不加了
	if nFreeLevel >= #self.BUILD_VALUE[self.REPTYPE_FREE] and nLimitLevel >= #self.BUILD_VALUE[self.REPTYPE_LIMIT] then
		return;
	end
	Kin.nJourNum = Kin.nJourNum + 1
	cKin.SetKinDataVer(Kin.nJourNum)
	local nRemainBuildValue = nBuildValue + nAddValue;
	cKin.SetRepBuildValue(nRemainBuildValue);
	GlobalExcute{"KinRepository:AddRepBuildValue_GS2", dwKinId, nRemainBuildValue, Kin.nJourNum};
end

-- 设置权限
function KinRepository:SetMemberRepAuthority_GC(dwKinId, nExcutorId, nMemberId, nCurRepAuthority, nSetRepAuthority)
	if nMemberId == nExcutorId then
		return;
	end
	local nRet, cKin = Kin:CheckSelfRight(dwKinId, nExcutorId, 1)
	if nRet ~= 1 then
		return;
	end
	if cKin.GetIsOpenRepository() == 0 then
		return;
	end
	local cMember = cKin.GetMember(nMemberId);
	if not cMember then
		return;
	end
	local nRepAuthority = cMember.GetRepAuthority();
	if nRepAuthority ~= nCurRepAuthority then
		return;
	end
	if nSetRepAuthority == self.AUTHORITY_ASSISTANT then
		if cMember.GetFigure() > Kin.FIGURE_REGULAR then
			return;
		end
		
		local nManagerCount = 0;
		local itor = cKin.GetMemberItor()
		local cTemp = itor.GetCurMember()
		while cTemp do
			if cTemp.GetRepAuthority() == self.AUTHORITY_ASSISTANT then
				nManagerCount = nManagerCount + 1;
			end
			cTemp = itor.NextMember();
		end
		if nManagerCount >= self.MAX_MANAGER_COUNT then
			return;
		end
	end

	Kin.nJourNum = Kin.nJourNum + 1
	cKin.SetKinDataVer(Kin.nJourNum)
	cMember.SetRepAuthority(nSetRepAuthority);
	GlobalExcute{"KinRepository:SetMemberRepAuthority_GS2", dwKinId, nMemberId, nCurRepAuthority, nSetRepAuthority, Kin.nJourNum};
end
