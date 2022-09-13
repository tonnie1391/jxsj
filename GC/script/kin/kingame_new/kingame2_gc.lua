-- 文件名　：kingame2_gc.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-06-08 10:15:50
-- 描述：新家族副本gc逻辑,和已有逻辑类似，但为了区分新旧家族关卡
-- 还是挪出来加入到KinGame2全局table中

if not MODULE_GC_SERVER then
	return;
end

function KinGame2:ApplyKinGame_GC(nKinId, nMemberId, nCityMapId, nPlayerId)
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
			tbData.nIsNewGame = 1;
			nTime = GetTime();
			nDegree = nDegree + 1;
		end
	end
	GlobalExcute{"KinGame2:ApplyKinGame_GS2", nKinId, nCityMapId, nTime, nDegree, nRet, nPlayerId};
end

function KinGame2:ApplyKinGame_GC2(nKinId, nRet, nTime, nDegree)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	local tbData = Kin:GetKinData(nKinId);
	if nRet == 1 then
		cKin.SetKinGameTime(nTime);
		cKin.SetKinGameDegree(nDegree);
		GlobalExcute{"KinGame2:ApplyKinGame_GS3", nKinId, nTime, nDegree};
	else
		tbData.nApplyKinGameMap = nil;
		tbData.nIsNewGame = nil;
		GlobalExcute{"KinGame2:EndGame_GS2", nKinId};
	end
end

function KinGame2:AnnounceKinGame_GC(nKinId, nCityMapId)
	GlobalExcute{"KinGame2:AnnounceKin_GS2", nKinId, nCityMapId};
end

function KinGame2:EndGame_GC(nKinId, nRet)
	local tbData = Kin:GetKinData(nKinId)
	tbData.nApplyKinGameMap = nil;
	tbData.nIsNewGame = nil;
	GlobalExcute{"KinGame2:EndGame_GS2", nKinId, nRet};
end

--设置上次通关难度
function KinGame2:SetLastPassLevel_GC(nKinId,nLevel)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	if not nLevel then
		nLevel = 1;
	end
	cKin.SetKinGame2LastPassLevel(nLevel);
	GlobalExcute{"KinGame2:SetLastPassLevel_GS",nKinId,nLevel};
end


--test
function KinGame2:ClearDegree(nKinId,bToday)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	cKin.SetKinGameTime(0);
	if bToday and bToday == 1 then
		cKin.SetKinGameDegree(1);
	else
		cKin.SetKinGameDegree(0);
	end
	local tbData = Kin:GetKinData(nKinId)
	tbData.nApplyKinGameMap = nil;
	tbData.nIsNewGame = nil;
	GlobalExcute{"KinGame2:ClearDegree_GS",nKinId,bToday};
end

function KinGame2:SetGameDegree(nKinId,nTime,nDegree)
	if not nTime or not nDegree then
		return 0;
	end
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	cKin.SetKinGameTime(nTime);
	cKin.SetKinGameDegree(nDegree);
	GlobalExcute{"KinGame2:SetGameDegree_GS",nKinId,nTime,nDegree};
end