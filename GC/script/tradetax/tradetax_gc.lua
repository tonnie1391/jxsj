-------------------------------------------------------------------
--File: tradetax_gc.lua
--Author: zhengyuhua
--Date: 2008-3-17 14:23
--Describe: 交易税GC脚本
-------------------------------------------------------------------

-- 增加税收
function TradeTax:AddTax_GC(nMoney)
	local nCurTax = KGblTask.SCGetDbTaskInt(DBTASK_TRADE_CUR_TAX);
	KGblTask.SCSetDbTaskInt(DBTASK_TRADE_CUR_TAX, nCurTax + nMoney);
end

-- 增加福利申请数目
function TradeTax:AddWarefulUnit_GC(nUnitCount)
	local nCurUnit = KGblTask.SCGetDbTaskInt(DBTASK_TRADE_MIN_UNIT);
	KGblTask.SCSetDbTaskInt(DBTASK_TRADE_MIN_UNIT, nCurUnit + nUnitCount);
end

-- 周结算
function TradeTax:WeekSchedule()
	local nWeek = tonumber(GetLocalDate("%w"));
	if nWeek ~= self.CLEAR_DATE then
		return;
	end
	
	local nCurJourNum = KGblTask.SCGetDbTaskInt(DBTASK_TRADE_TAX_JOUR_NUM);		-- 当前流水号
	KGblTask.SCSetDbTaskInt(DBTASK_TRADE_TAX_JOUR_NUM, nCurJourNum + 1);		-- 递增流水号
	local nCurTax = KGblTask.SCGetDbTaskInt(DBTASK_TRADE_CUR_TAX);
	local nUnitCount = KGblTask.SCGetDbTaskInt(DBTASK_TRADE_MIN_UNIT);
	local nWelPreUnit = 0;
	if nUnitCount > 0 then
		nWelPreUnit = math.floor(nCurTax * self.TAX_TO_WELFARE / nUnitCount);
	else
		nWelPreUnit = 0;
	end
	if nWelPreUnit > self.UNIT_WEL_MAX then
		nWelPreUnit = self.UNIT_WEL_MAX;
	end
	KGblTask.SCSetDbTaskInt(DBTASK_TRADE_UNIT_WEL, nWelPreUnit);
	-- 清理数据
	KGblTask.SCSetDbTaskInt(DBTASK_TRADE_CUR_TAX, 0);  -- 清空本周税收记录
	KGblTask.SCSetDbTaskInt(DBTASK_TRADE_MIN_UNIT, 0);	-- 清空申请福利单元数目
	
	-- 税率随汇率变化
	GlobalExcute{"TradeTax:AmendmentTaxRegion"};
end
