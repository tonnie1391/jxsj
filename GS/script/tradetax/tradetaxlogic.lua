-------------------------------------------------------------------
--File: tradetaxlogic.lua
--Author: Zouying
--Date: 2008-8-13 14:23
--Describe: 交易税tradelogic脚本
-------------------------------------------------------------------

function TradeTax:CalcTradeTax(pPlayer, nCurMount, nMoney, bSendMsg)
	if nMoney <= 0 then
		return 0;
	end
	
	self:CheckTaxReagion();	
	local nTempMoney = nMoney;
	local nBegin = 0;
	local nTax = 0;
	for i = 1, #self.TAX_REGION do
		if self.TAX_REGION[i][1] <= nCurMount then
			nBegin = i;				-- 寻找起始税区
		end
	end
	nBegin = nBegin + 1;
	local nRemain = nMoney;
	if self.TAX_REGION[nBegin] then
		nRemain = self.TAX_REGION[nBegin][1] - nCurMount; -- 该税区剩余额
	end
	local szMsg = "";
	if nBegin == 1 then		-- 免税区输出信息特殊，所以特殊处理
		if nRemain >= nMoney then
			szMsg = string.format("本次收入冲抵了%s两免税额，您的免税额还剩余%s两", nTempMoney, nRemain - nTempMoney);
			nTempMoney = 0;
			nRemain = 0;
		else
			szMsg = string.format("本次收入冲抵了%s两免税额，您的免税额还剩余%s两", nRemain, 0);
			nTempMoney = nTempMoney - nRemain;
			nRemain = self.TAX_REGION[2][1] - self.TAX_REGION[1][1];
		end
		nBegin = 2;
		if (bSendMsg == 1) then
			pPlayer.Msg(szMsg);
		end
	end
	-- 普通税区
	for i = nBegin, #self.TAX_REGION do
		if nTempMoney > 0 then
			if nRemain >= nTempMoney then
				nTax = nTax + nTempMoney * self.TAX_REGION[i][2];
				nTempMoney = 0;
				nRemain = 0;
			else
				nTax = nTax + nRemain * self.TAX_REGION[i][2];
				nTempMoney = nTempMoney - nRemain;
				if self.TAX_REGION[i + 1] and nTempMoney > 0 then
					nRemain = self.TAX_REGION[i + 1][1] - self.TAX_REGION[i][1];	-- 下一税区剩余额等与下一税区的值宽
				else
					nRemain = nTempMoney;
				end
			end
		end
	end
	-- 30000001+ 收税 20%
	if nRemain > 0 then
		nTax = nTax + self.TAX_REGION_MAXNUMBER * nRemain;
	end
	nTax = math.floor(nTax);
	return nTax;
end

if MODULE_GC_SERVER or MODULE_GAMESERVER then
	
function TradeTax:CheckTaxReagion()
	if (self.TAX_CHANGED == 1) then
		return;
	end
	self:AmendmentTaxRegion();
end

function TradeTax:AmendmentTaxRegion()
	-- 09年开始实施 新税率
	local nYear = tonumber(os.date("%Y", GetTime()));
	if (nYear <= 2008) then
		return;
	end
	local nRate = KJbExchange.GetPrvWeekAvgPrice();
	if (nRate < 100) then
		nRate = 100;
	elseif (nRate > 200) then -- 最大上限
		nRate = 200;
	end
	for i = 1, 5 do
		self.TAX_REGION[i][1] = math.ceil(self.ORIG_TAX_REGION[i][1] * nRate / 100);
	end
	self.TAX_CHANGED = 1;
end

-- 注册金币交易回调
function TradeTax:RegisterTransferCoinCallBack(nType, func, ...)
	if type(nType) == "number" then
		self.tbTransferCoinCallBack[nType] =
		{
			fnCallBack = func;
			argCallBack = arg;
		}
		return 1;
	else
		return 0;
	end
end

-- nResult: 1成功,2:失败, 3:找不到帐号,1100:金币余额不足,1600:交易id重复
function TradeTax:OnTransferCoin(nType, nResult, szId)
	print("TradeTax:OnTransferCoin", nType, nResult, szId);
	local tbCallBack = self.tbTransferCoinCallBack[nType];
	if tbCallBack then
		tbCallBack.fnCallBack(unpack(tbCallBack.argCallBack), nType, nResult, szId);
	else
		Dbg:WriteLog("OnTransferCoinCallback", nType, nResult, szId);
		-- 默认处理：不做任何处理
		if nResult == 1 then
			-- 成功处理
		else
			-- 失败处理
		end
	end
end

end