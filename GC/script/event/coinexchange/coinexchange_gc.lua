-- 文件名　：coinexchange.lua
-- 创建者　：xiewen
-- 创建时间：2009-02-16 15:17:18

Require("\\script\\event\\coinexchange\\coinexchange_def.lua")

-- 定时任务
function CoinExchange:CheckOnlinePayer()
	local nThisMonth = Lib:GetLocalMonth(GetTime()) + 1
	local nRecentMonth = KGblTask.SCGetDbTaskInt(DBTASK_COIN_EXCHANGE_RECENT_MONTH)

	local nRecent = KGblTask.SCGetDbTaskInt(DBTASK_COIN_EXCHANGE_PAYER_RECENT)
	local nRecentDays = KGblTask.SCGetDbTaskInt(DBTASK_COIN_EXCHANGE_PAYER_RECENT_DAYS)

	-- 开服第一次统计
	if KGblTask.SCGetDbTaskInt(DBTASK_COIN_EXCHANGE_PAYER) == 0 and nRecentDays >= 7 then
		KGblTask.SCSetDbTaskInt(DBTASK_COIN_EXCHANGE_PAYER, nRecent / nRecentDays)
	end

	-- 跨月/跨年并且至少统计了7天
	if nThisMonth ~= nRecentMonth and nRecentDays >= 7 then
		KGblTask.SCSetDbTaskInt(DBTASK_COIN_EXCHANGE_PAYER, nRecent / nRecentDays)
		KGblTask.SCSetDbTaskInt(DBTASK_COIN_EXCHANGE_PAYER_RECENT_DAYS, 1)
		KGblTask.SCSetDbTaskInt(DBTASK_COIN_EXCHANGE_PAYER_RECENT, 0)
		KGblTask.SCSetDbTaskInt(DBTASK_COIN_EXCHANGE_RECENT_MONTH, nThisMonth)
	else
		KGblTask.SCSetDbTaskInt(DBTASK_COIN_EXCHANGE_PAYER_RECENT_DAYS, nRecentDays + 1)
	end

	GlobalExcute{"CoinExchange:CheckOnlinePayer_GS"}
end

function CoinExchange:CheckOnlinePayer_GC(nPlayerCount)
	local nRecent = KGblTask.SCGetDbTaskInt(DBTASK_COIN_EXCHANGE_PAYER_RECENT)
	KGblTask.SCSetDbTaskInt(DBTASK_COIN_EXCHANGE_PAYER_RECENT, nRecent + nPlayerCount * 5)
end

function CoinExchange:CheckExchangePayerMax_GC(nPlayerId)
	local nPrestige = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_PRESIGE_RESULT);
	local nSaveDate = KGblTask.SCGetDbTaskInt(DBTASK_COIN_EXCHANGE_PAYER_EXCHANGE_DATE);
	local nDate = tonumber(GetLocalDate("%Y%W"));
	if nDate > nSaveDate then
		KGblTask.SCSetDbTaskInt(DBTASK_COIN_EXCHANGE_PAYER_EXCHANGE_COUNT, 0);
		KGblTask.SCSetDbTaskInt(DBTASK_COIN_EXCHANGE_PAYER_EXCHANGE_DATE, nDate);
	end
	local nRank = PlayerHonor:GetPlayerHonorRank(nPlayerId, PlayerHonor.HONOR_CLASS_WEIWANG, 0);
	local nMaxPlayer = KGblTask.SCGetDbTaskInt(DBTASK_COIN_EXCHANGE_PAYER_EXCHANGE_COUNT);
	if nMaxPlayer >= self.ExchangePlayerMax and (nRank <= 0 or nRank > self.nMaxLimitRank) then
		GlobalExcute({"CoinExchange:ExchangePayerMaxIsSusscess",nPlayerId, 0});
		return 0;
	end
	GlobalExcute({"CoinExchange:ExchangePayerMaxIsSusscess",nPlayerId, 1});
end

function CoinExchange:AddExchangePayerMax_GC()
	local nMaxPlayer = KGblTask.SCGetDbTaskInt(DBTASK_COIN_EXCHANGE_PAYER_EXCHANGE_COUNT);
	KGblTask.SCSetDbTaskInt(DBTASK_COIN_EXCHANGE_PAYER_EXCHANGE_COUNT, nMaxPlayer+1);
end
