-------------------------------------------------------------------
--File: jbexchange_gc.lua
--Author: ZouYing
--Date: 2008-3-6
--Describe: 金币交易所服务器端的逻辑
-------------------------------------------------------------------

if not JbExchange then
	JbExchange = {};
end

JbExchange.SELLTYPE	= 0;
JbExchange.BUYTYPE	= 1;
JbExchange.nTax		= 0;


-- 处理添加一个交易单
function JbExchange:AddOneBill(nPlayerId, nPrice, nCount, nType)
	local bRet	= 0;
	local bHave = KJbExchange.HaveBill(nPlayerId);
	if (bHave == 1) then
		bRet	= 1100;
	elseif (nPrice > 0 and nCount > 0) then
		bRet	= KJbExchange.ApplyAddBill(nPlayerId, nPrice, nCount, nType);
		if (not bRet) then
			bRet = -1;
			self:WriteLog(Dbg.LOG_WARNING, "Paysys Disconnect AddBill Fail");
		end
		if (bRet == 0 and KJbExchange.GetBlockState() ~= 0) then
			bRet = -1;
		end
	end
	_G.GlobalExcute({"JbExchange:AddBillResult", nPlayerId, bRet, nType, nPrice * nCount});
	self:WriteLog(Dbg.LOG_WARNING, string.format("AddBillResult nType:%d, bRet:%d", nType, bRet));
	
	if (0 == bRet) then
		local szTilte		= "金币交易单提交失败通知";
		local szTypeBack	= "";
		local szType		= "";
		
		if (nType == self.SELLTYPE) then
			szTypeBack = "退还的金币已经进入您的账户";
			szType	   = "卖出金币"; 
		elseif (nType == self.BUYTYPE) then
			szTypeBack = "退还的银两已经返还到您的账户";
			szType	   = "买入金币";
		end
		local szContent = "您好，您在金币交易所提交的交易单提交失败，" .. szTypeBack .. "，对带给您的不便深表歉意：";		
		szContent	= szContent .. "\n交易类型：" .. szType .. "\n交易数量：" .. nCount .. "\n挂单价格：" .. nPrice .. "\n挂单时间：" .. GetLocalDate("%Y%m%d");
		szContent	= "<color=green>" .. szContent .. "<color>";
		_G.SendMailGC(nPlayerId, szTilte, szContent);
	end	
end

-- 撤销一个交易单
function JbExchange:DelOneBill(nPlayerId, nBillIndex, btType)
	local nRet	= KJbExchange.DelOneBill(nPlayerId, nBillIndex);
	if btType == self.BUYTYPE or (nRet ~= 1 and btType == self.SELLTYPE) then
		_G.GlobalExcute({"JbExchange:DelOneBillResult", nPlayerId, nRet});
		self:WriteLog(Dbg.LOG_WARNING, string.format("DelOneBillResult bRet:%d", nRet));
	end
end

-- 处理每天要处理的事务
function JbExchange:ProcessEveryDayEvent()
	-- 如果是其他版本就不走
	if (Task.IVER_nTask_OpenJbExchangeDayEvent == 0) then
		return 0;
	end
	local nRet1 = KJbExchange.CheckOverTime();
	local nRet2	= 0;
	local nRet3 = 0;
	local nDay	= tonumber(GetLocalDate("%w"));
	if (nDay ~= 0) then
		nRet2	= KJbExchange.ProcessDayEvent();
	else
		nRet3 	= KJbExchange.ProcessWeekEvent();
	end
	
	local nAvgPrice = KJbExchange.GetPrvAvgPrice();
	_G.GlobalExcute({"JbExchange:SyncAvgPrice", nAvgPrice});
	if (nRet1 == 0 ) then
		Dbg:WriteLogEx(Dbg.LOG_INFO, "JbExchange", "CheckOverTime", "检查是否有过期的交易单。");
	end
	if (nRet2 == 0 and nDay ~= 0) then
		Dbg:WriteLogEx(Dbg.LOG_INFO, "JbExchange", "ProcessDayEvent", "交易所日常事务处理出错。");
	elseif(nRet3 == 0 and nDay == 0) then
		Dbg:WriteLogEx(Dbg.LOG_INFO, "JbExchange", "ProcessWeekEvent", "交易所周事务处理出错。");		
	end	
end

-- 设置税率
function JbExchange:SetTradeTax(nTax)
	KJbExchange.SetTax(nTax);
end

-- 设置休市
function JbExchange:SetClose(bClose)
	KJbExchange.SetClose(bClose);
end

-- 删除所有交易单
function JbExchange:DelAllBill()
	KJbExchange.DelAllBill();
end


function JbExchange:ApplyGetMoney(nPlayerId, nMoney)
	local nRet	= KJbExchange.GetCashMoney(nPlayerId, nMoney);
	_G.GlobalExcute({"JbExchange:GetMoneyResult", nPlayerId, nRet});		
end

-- 指令改变汇率的回调 GC 啥都不做
function JbExchange:OnChangePreAvgPrice()
end
