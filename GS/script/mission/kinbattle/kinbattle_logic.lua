-------------------------------------------------------
-- 文件名　：kinbattle_logic.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-7 10:15:46
-- 文件描述：
-------------------------------------------------------

Require("\\script\\mission\\kinbattle\\kinbattle_def.lua");

function KinBattle:FindMissionId(nKinId, nKinIdMate)
	if not self.tbMissionList then
		return -1;
	end
	for nIndex, tbInfo in pairs(self.tbMissionList) do
		if tbInfo.nState == 1 then			
			if nKinId == tbInfo.nKinId then
				return nIndex, 1;
			end
			if nKinId == tbInfo.nKinIdMate then
				return nIndex, 2;
			end
			if nKinIdMate and nKinIdMate == tbInfo.nKinId or nKinIdMate == tbInfo.nKinIdMate then
				return nIndex, 0;
			end
		end
	end
	return -1;
end

function KinBattle:CheckJoin(pPlayer)
	local nKinId, nMemberId = pPlayer.GetKinMember();
	if nKinId == 0 or nMemberId == 0 then
		return 0;
	end
	local nMapIndex, nCampIndex = KinBattle:FindMissionId(nKinId);
	if nMapIndex == -1 then
		return 0;
	end
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0;
	end
	if cMember.GetFigure() == Kin.FIGURE_SIGNED then
		return 0;
	end
	return 1;
end

function KinBattle:CheckHaveFreeBattle(nMapType)
	if not nMapType then
		nMapType = 1;
	end
	local nIndexBeg = 1;
	for i = 1, nMapType - 1 do
		nIndexBeg = nIndexBeg + KinBattle.MAP_TYPE_COUNT[i];
	end
	local nIndexEnd = nIndexBeg + KinBattle.MAP_TYPE_COUNT[nMapType];
	for i = nIndexBeg, nIndexEnd - 1 do
		if not self.tbMissionList[i] or self.tbMissionList[i].nState == 0 then
			return i;
		end
	end
	return 0;
end

-- 获取家族战列表
function KinBattle:GetBattleInfoList()
	local tbBattleInfoList = {};
	for nIndex, tbTemp in pairs(self.tbMissionList) do
		if tbTemp.nState == 1 and tbTemp.nLookMode == 1 then
			local tbTempList = {};
			tbTempList.nId = nIndex;
			tbTempList.nKinId = tbTemp.nKinId;
			tbTempList.nKinIdMate = tbTemp.nKinIdMate;
			tbTempList.szKinName = self:GetKinName(tbTemp.nKinId);
			tbTempList.szKinNameMate = self:GetKinName(tbTemp.nKinIdMate);
			tbTempList.nMissionState = tbTemp.nMissionState;
			table.insert(tbBattleInfoList, tbTempList);
		end
	end
	return tbBattleInfoList;
end

function KinBattle:OccupyBattle(nIndex, nKinId, nKinIdMate, nTimeIndex, nLookMode)
	if not self.tbMissionList[nIndex] then
		self.tbMissionList[nIndex] = {};
	end
	self.tbMissionList[nIndex].nState = 1;
	self.tbMissionList[nIndex].nKinId = nKinId;
	self.tbMissionList[nIndex].nKinIdMate = nKinIdMate;
	self.tbMissionList[nIndex].nTimeIndex = nTimeIndex;
	self.tbMissionList[nIndex].nLookMode = nLookMode;
	self.tbMissionList[nIndex].nLookerCount = 0;
	self.tbMissionList[nIndex].nMissionState = 1;
	self.tbMissionList[nIndex].nStartTime = GetTime();
	self.tbMissionList[nIndex].tbLookerList = {};
end

function KinBattle:FreeBattle(nIndex)
	if self.tbMissionList[nIndex] then
		self.tbMissionList[nIndex].nState = 0;
		self.tbMissionList[nIndex].nKinId = -1;
		self.tbMissionList[nIndex].nKinIdMate = -1;
		self.tbMissionList[nIndex].nTimeIndex = -1;
		self.tbMissionList[nIndex].tbMission = nil;
		self.tbMissionList[nIndex].nLookMode = 0;
		self.tbMissionList[nIndex].nLookerCount = 0;
		self.tbMissionList[nIndex].nMissionState = 0;
		self.tbMissionList[nIndex].nStartTime = -1;
		self.tbMissionList[nIndex].tbLookerList = {};
	end
end

function KinBattle:GetKinName(nKinId)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return "未知家族";
	end
	return cKin.GetName();
end

function KinBattle:CheckHaveEnoughMoney(nKinId, nKinIdMate)
	local cKin = KKin.GetKin(nKinId);
	local cKinMate = KKin.GetKin(nKinIdMate);
	if not cKin or not cKinMate then
		return 0;
	end
	-- 检查家族资金是否被锁定
	local tbTakeFundData = Kin:GetExclusiveEvent(nKinId, Kin.KIN_EVENT_TAKE_FUND);
	if tbTakeFundData.nApplyEvent and tbTakeFundData.nApplyEvent == 1 then
		return -1;
	end
	local tbSalaryData = Kin:GetExclusiveEvent(nKinId, Kin.KIN_EVENT_SALARY);
	if tbSalaryData.nApplyEvent and tbSalaryData.nApplyEvent == 1 then
		return -1;
	end
	local tbTakeFundDataMate = Kin:GetExclusiveEvent(nKinIdMate, Kin.KIN_EVENT_TAKE_FUND);
	if tbTakeFundDataMate.nApplyEvent and tbTakeFundDataMate.nApplyEvent == 1 then
		return -1;
	end
	local tbSalaryDataMate = Kin:GetExclusiveEvent(nKinIdMate, Kin.KIN_EVENT_SALARY);
	if tbSalaryDataMate.nApplyEvent and tbSalaryDataMate.nApplyEvent == 1 then
		return -1;
	end
	local nMoney = cKin.GetMoneyFund();
	local nMoneyMate = cKinMate.GetMoneyFund()
	if nMoney >= KinBattle.MONEY_COST and nMoneyMate >= KinBattle.MONEY_COST then
		return 1;
	end
	return -2;
end

function KinBattle:IncreaseBattleTime(nKinId, nKinIdMate)
	local cKin = KKin.GetKin(nKinId);
	if cKin then
		local nTimes = cKin.GetBattleCount();
		cKin.SetBattleCount(nTimes+1);
	end
	local cKinMate = KKin.GetKin(nKinIdMate);
	if cKinMate then
		local nTimes = cKinMate.GetBattleCount();
		cKinMate.SetBattleCount(nTimes+1);
	end
end

function KinBattle:CheckIsBattleMap(nMapId)
	for i = 1, #KinBattle.MAP_LIST do
		if nMapId == KinBattle.MAP_LIST[i][1] then
			return 1;
		end
	end
	return 0;
end

-- 根据索引获取地图类型
function KinBattle:GetMapType(nIndex)
	local nMapCount = 0;
	for nType, nNum in ipairs(self.MAP_TYPE_COUNT) do
		nMapCount = nMapCount + nNum;
		if nMapCount >= nIndex then
			return nType;
		end
	end
	return -1;
end

-- 根据地图id返回mission编号
function KinBattle:GetMissionIdByMapId(nMapId)
	for nIndex, tbTemp in pairs(self.MAP_LIST) do
		if tbTemp[1] == nMapId then
			return nIndex;
		end
	end
	return -1;
end

function KinBattle:AddLooker(nIndex, nPlayerId)
	if nIndex <= 0 then
		return 0;
	end
	if not self.tbMissionList[nIndex] or self.tbMissionList[nIndex].nState ~= 1 then
		return 0;
	end
	if not self.tbMissionList[nIndex].tbLookerList then
		self.tbMissionList[nIndex].tbLookerList = {};
	end
	if self.tbMissionList[nIndex].tbLookerList[nPlayerId] and self.tbMissionList[nIndex].tbLookerList[nPlayerId] == 1 then
		return 0;
	end
	self.tbMissionList[nIndex].tbLookerList[nPlayerId] = 1;
	self.tbMissionList[nIndex].nLookerCount = self.tbMissionList[nIndex].nLookerCount + 1;
end

function KinBattle:ReduceLooker(nIndex, nPlayerId)
	if nIndex <= 0 then
		return 0;
	end
	if not self.tbMissionList[nIndex] or self.tbMissionList[nIndex].nState ~= 1 then
		return 0;
	end
	if not self.tbMissionList[nIndex].tbLookerList then
		return 0;
	end
	if self.tbMissionList[nIndex].tbLookerList[nPlayerId] and self.tbMissionList[nIndex].tbLookerList[nPlayerId] == 1 then
		self.tbMissionList[nIndex].tbLookerList[nPlayerId] = 0;
		self.tbMissionList[nIndex].nLookerCount = self.tbMissionList[nIndex].nLookerCount - 1;
	end
end

function KinBattle:SetMissionState(nIndex, nMissionState)
	if self.tbMissionList[nIndex] and self.tbMissionList[nIndex].nState == 1 then
		self.tbMissionList[nIndex].nMissionState = nMissionState;
	end
end