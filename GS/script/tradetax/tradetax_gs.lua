-------------------------------------------------------------------
--File: tradetax_gs.lua
--Author: zhengyuhua
--Date: 2008-3-17 14:23
--Describe: 交易税GS脚本
-------------------------------------------------------------------

-- 申请福利
function TradeTax:ApplyWelfare(pPlayer)
	local nCurJour = KGblTask.SCGetDbTaskInt(DBTASK_TRADE_TAX_JOUR_NUM);
	local nPlayerJour = pPlayer.GetTask(self.TAX_TASK_GROUP, self.TAX_WEL_JOU_TASK_ID);
	if nPlayerJour == nCurJour + 1 then
		return 2;		-- 已经申请过了
	end
	if nPlayerJour == nCurJour and nPlayerJour ~= 0 then
		return 3;		-- 上周福利未领
	end
	
	local nRepute = pPlayer.nPrestige;
	if nRepute < self.MIN_WEIWANG then
		return 0;
	end
	
	local nWelLevel = 0;
	for i = 1, #self.WELFARE_LEVEL do
		if nRepute >= self.WELFARE_LEVEL[i][1] then
			nWelLevel = i;
		end
	end
	pPlayer.SetTask(self.TAX_TASK_GROUP, self.TAX_LEVEL_TASK_ID, nWelLevel);
	GCExcute{"TradeTax:AddWarefulUnit_GC", self.WELFARE_LEVEL[nWelLevel][2]};
	local nCurJour = KGblTask.SCGetDbTaskInt(DBTASK_TRADE_TAX_JOUR_NUM);
	pPlayer.SetTask(self.TAX_TASK_GROUP, self.TAX_WEL_JOU_TASK_ID, nCurJour + 1);
	return 1;
end

-- 领取福利
function TradeTax:TakeWelfare(pPlayer, bConfirm)
	local nWelfare = 0;
	local nCurJour = KGblTask.SCGetDbTaskInt(DBTASK_TRADE_TAX_JOUR_NUM);
	local nPlayerJour = pPlayer.GetTask(self.TAX_TASK_GROUP, self.TAX_WEL_JOU_TASK_ID);
	if nPlayerJour ~= nCurJour then
		return -1;
	end
	local nWelLevel = pPlayer.GetTask(self.TAX_TASK_GROUP, self.TAX_LEVEL_TASK_ID);
	local nWelPerUnit = KGblTask.SCGetDbTaskInt(DBTASK_TRADE_UNIT_WEL);
	if nWelLevel ~= 0 and self.WELFARE_LEVEL[nWelLevel] then
		nWelfare = self.WELFARE_LEVEL[nWelLevel][2] * nWelPerUnit;
		if bConfirm then
			if pPlayer.nCashMoney + nWelfare > 2000000000 then 		-- 大于20亿
				pPlayer.Msg("你携带银两太多，请整理后再来领取");
				return -2;
			end
			pPlayer.Earn(nWelfare, Player.emKEARN_FULI);
			pPlayer.SetTask(self.TAX_TASK_GROUP, self.TAX_WEL_JOU_TASK_ID, -1);
		end
	else
		return -1;
	end
	return nWelfare;
end

-- 交易给某玩家金钱，从中扣取税收
function TradeTax:TradeMoney(pPlayer, nMoney)
	assert(type(pPlayer) == "userdata");
	if nMoney <= 0 then
		return 0;
	end
	self:Check(pPlayer);
	local nCurMount = pPlayer.GetTask(self.TAX_TASK_GROUP, self.TAX_AMOUNT_TASK_ID);
	
	local nTax = self:CalcTradeTax(pPlayer, nCurMount, nMoney, 1);
	
	local szMsg = "本周累计交易额为：".. nCurMount + nMoney .. "两，本次交易扣税：".. nTax ..string.format("两，税率查询请找临安府的福利官。通过奇珍阁金条、%s购买获得的银两不需要交税。",IVER_g_szCoinName);
	pPlayer.Msg(szMsg);
	if nTax > 0 then
		-- 记录交税情况
		local nTaxCount = pPlayer.GetTask(self.TAX_TASK_GROUP, self.TAX_ACCOUNT_TASK_ID);
		pPlayer.SetTask(self.TAX_TASK_GROUP, self.TAX_ACCOUNT_TASK_ID, nTaxCount + nTax);
	end
	-- 记录交易量
	pPlayer.SetTask(TradeTax.TAX_TASK_GROUP, TradeTax.TAX_AMOUNT_TASK_ID, nCurMount + nMoney);
	if nTax > 0 then
		GCExcute{"TradeTax:AddTax_GC", nTax};
	end
	Item:OnCoinChanged(2, -nTax);	-- 交易税要算银两消耗
	return nMoney - nTax;
end

-- 检查周税流水号~不相同则清0
function TradeTax:Check(pPlayer)
	assert(type(pPlayer) == "userdata");
	local nPlayerTaxJour = pPlayer.GetTask(self.TAX_TASK_GROUP, self.TAX_JOU_TASK_ID);
	local nCurTaxJour = KGblTask.SCGetDbTaskInt(DBTASK_TRADE_TAX_JOUR_NUM);
	if nCurTaxJour ~= nPlayerTaxJour then
		pPlayer.SetTask(self.TAX_TASK_GROUP, self.TAX_JOU_TASK_ID, nCurTaxJour);
		pPlayer.SetTask(self.TAX_TASK_GROUP, self.TAX_AMOUNT_TASK_ID, 0);
		pPlayer.SetTask(self.TAX_TASK_GROUP, self.TAX_ACCOUNT_TASK_ID, 0);
	end
end

function TradeTax:IsCoinTradeOpen()
	local nOpen = KGblTask.SCGetDbTaskInt(DBTASK_OPEN_COIN_TRADE);
	if (nOpen == 1) then
		return 1;
	else
		return 0;
	end
end
