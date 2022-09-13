-------------------------------------------------------------------
--File		: kingame_gc.lua
--Author	: zhengyuhua
--Date		: 2008-5-15 14:43
--Describe	: 家族关卡GC脚本
-------------------------------------------------------------------

function KinGame:ApplyKinGame_GC(nKinId, nMemberId, nCityMapId, nPlayerId)
	local nRet, cKin = Kin:CheckSelfRight(nKinId, nMemberId, 2)
	if nRet ~= 1 or not cKin then
		return 0;
	end
	local tbData = Kin:GetKinData(nKinId)
	local nRet = 0;
	local nTime = cKin.GetKinGameTime();
	local nDegree = cKin.GetKinGameDegree();
	if tbData.nApplyKinGameMap then
		if tbData.nApplyKinGameMap == nCityMapId then
			return 0;
		end
		nCityMapId = tbData.nApplyKinGameMap;
	else
		if os.date("%W", nTime) ~= os.date("%W", GetTime()) then
			nTime = 0;
			nDegree = 0; 
			nRet = 1;
		elseif os.date("%W%w", nTime) == os.date("%W%w", GetTime()) or 
			nDegree >= self.MAX_WEEK_DEGREE then
				nCityMapId = nil;
		else
			nRet = 1;
		end
		if nRet == 1 then
			tbData.nApplyKinGameMap = nCityMapId;
			nTime = GetTime();
			nDegree = nDegree + 1;
		end
	end
	GlobalExcute{"KinGame:ApplyKinGame_GS2", nKinId, nCityMapId, nTime, nDegree, nRet, nPlayerId};
end

function KinGame:ApplyKinGame_GC2(nKinId, nRet, nTime, nDegree)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local tbData = Kin:GetKinData(nKinId);
	if nRet == 1 then
		cKin.SetKinGameTime(nTime);
		cKin.SetKinGameDegree(nDegree);
		GlobalExcute{"KinGame:ApplyKinGame_GS3", nKinId, nTime, nDegree};
	else
		tbData.nApplyKinGameMap = nil;
		GlobalExcute{"KinGame:EndGame_GS2", nKinId};
	end
end

function KinGame:AnnounceKinGame_GC(nKinId, nCityMapId)
	GlobalExcute{"KinGame:AnnounceKin_GS2", nKinId, nCityMapId};
end

function KinGame:EndGame_GC(nKinId, nRet)
	local tbData = Kin:GetKinData(nKinId)
	tbData.nApplyKinGameMap = nil;
	GlobalExcute{"KinGame:EndGame_GS2", nKinId, nRet};
end

function KinGame:BuyCallBossItem_GC(nKinId, nMemberId, nItemLevel)
	local nRet, cKin = Kin:CheckSelfRight(nKinId, nMemberId, 2)
	local nCurYinBi = 0;
	if cKin then
		nCurYinBi = cKin.GetKinGuYinBi()
	end
	if nRet == 1 then
		if nCurYinBi >= self.GOU_HUN_YU_COST[nItemLevel] then
			nCurYinBi = nCurYinBi - self.GOU_HUN_YU_COST[nItemLevel];
			cKin.SetKinGuYinBi(nCurYinBi);
		else
			nRet = -1;	-- 古银币不足
		end
	end
	GlobalExcute{"KinGame:BuyCallBossItem_GS2", nKinId, nMemberId, nItemLevel, nCurYinBi, nRet}
end

