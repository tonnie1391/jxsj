-- 各等级对应的任务信息,def表没有放gc
TreasureMap2.LEVEL_TASKIID	=
{
	[25] = {7},
	[50] = {7, 6},
	[70] = {2, 3},	
	[90] = {3, 4, 5},
	[100] = {4, 5, 6}
};

function TreasureMap2:RandTask_GC()
	local nTaskDay = KGblTask.SCGetDbTaskInt(DBTASK_TREASUREMAP_RANDDAY);
	local nDay = Lib:GetLocalDay();
	if nTaskDay < nDay then
		-- 算出一个随机值，保证均匀随机
		local nMaxRand = 1;
		local tbLevelSize = {};
		for nLevel, tbTemp in pairs(self.LEVEL_TASKIID) do
			tbLevelSize[#tbTemp] = 1;
		end
		for nSize, _ in pairs(tbLevelSize) do
			nMaxRand = nMaxRand * nSize;
		end
		local nRand = MathRandom(nMaxRand);
		KGblTask.SCSetDbTaskInt(DBTASK_TREASUREMAP_RANDDAY, nDay);
		KGblTask.SCSetDbTaskInt(DBTASK_TREASUREMAP_RANDSEED, nRand);
	end
end


function TreasureMap2:Apply_GC(nPlayerId, nCityMapId)
	GlobalExcute({"TreasureMap2:SyncMap", nPlayerId, nCityMapId});
end

function TreasureMap2:Release_GC(nPlayerId)
	GlobalExcute({"TreasureMap2:ReleaseMap", nPlayerId});
end

--设置产出骆驼的标记
function TreasureMap2:SetHorseGenDate()
	KGblTask.SCSetDbTaskInt(DBTASK_TREASUREMAP_OUT_HORSE,GetTime());
end

--碧落谷马牌产出标记
function TreasureMap2:ApplyGiveHorse_BiLuoGu(tbInstancKey)
	local nDay = KGblTask.SCGetDbTaskInt(DBTASK_TREASUREMAP_BILUOGU_HORSE_DAY);
	local nToday = Lib:GetLocalDay(GetTime()) ;
	if nDay ~= nToday then
		KGblTask.SCSetDbTaskInt(DBTASK_TREASUREMAP_BILUOGU_HORSE_DAY, nToday);
		KGblTask.SCSetDbTaskInt(DBTASK_TREASUREMAP_BILUOGU_HORSE_COUNT, 0);
	end
	
	local nTodayCount = KGblTask.SCGetDbTaskInt(DBTASK_TREASUREMAP_BILUOGU_HORSE_COUNT);
	if nTodayCount < self.nBiluogu_Horse_Count then
		-- 可以产出
		KGblTask.SCSetDbTaskInt(DBTASK_TREASUREMAP_BILUOGU_HORSE_COUNT, nTodayCount + 1);
		GSExcute(GCEvent.nGCExecuteFromId, {"TreasureMap2:OnHorseApplyRequest_biluogu", tbInstancKey, 1});
		return 1;
	end
	
	-- 不能产出
	return 0;
end

GCEvent:RegisterGCServerStartFunc(TreasureMap2.RandTask_GC, TreasureMap2);
