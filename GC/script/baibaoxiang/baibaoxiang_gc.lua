-------------------------------------------------------
-- 文件名　：baibaoxiang_gc.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-04-19 20:12:39
-- 文件描述：
-------------------------------------------------------

Require("\\script\\baibaoxiang\\baibaoxiang_def.lua");

if (not MODULE_GC_SERVER) then
	return 0;
end

-- min 500
function Baibaoxiang:CheckCoin_GC()
	
	local nCaichi = KGblTask.SCGetDbTaskInt(DBTASK_BAIBAOXIANG_CAICHI);
	
	if nCaichi < 50000 then
		KGblTask.SCSetDbTaskInt(DBTASK_BAIBAOXIANG_CAICHI, 50000);
	end
end
	
-- gc cost coin
function Baibaoxiang:GetCoin_GC(nPlayerID)

	-- get caichi
	local nCaichi = KGblTask.SCGetDbTaskInt(DBTASK_BAIBAOXIANG_CAICHI);
	
	-- 20%-50%
	local nRand = MathRandom(20, 50);
	local nCoin = math.floor(nCaichi * nRand / 10000);
	
	-- max 20000
	if nCoin > self.MAX_EXTRA then
		nCoin = self.MAX_EXTRA;
	end
	
	-- cost success
	KGblTask.SCSetDbTaskInt(DBTASK_BAIBAOXIANG_CAICHI, nCaichi - nCoin * 100);
	Baibaoxiang:CheckCoin_GC();
	
	-- call back GS
	GlobalExcute({"Baibaoxiang:GetCoin_GS", nPlayerID, nCoin});
end

-- gc add coin
function Baibaoxiang:AddCoin_GC(nPlayerID, nCoin)

	-- get task
	local nCaichi = KGblTask.SCGetDbTaskInt(DBTASK_BAIBAOXIANG_CAICHI);

	-- save new coin
	KGblTask.SCSetDbTaskInt(DBTASK_BAIBAOXIANG_CAICHI, nCaichi + nCoin);
end

GCEvent:RegisterGCServerStartFunc(Baibaoxiang.CheckCoin_GC, Baibaoxiang);