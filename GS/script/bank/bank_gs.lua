-- 文件名　：bank.lua
-- 创建者　：furuilei
-- 创建时间：2008-11-24 14:57:51

if MODULE_GAMECLIENT then
	return;
end

Bank.tbc2sFun = {};

if (GLOBAL_AGENT) then
	Bank.nBankState = 0;
else
	Bank.nBankState = 1;
end;


function Bank:SetBankState(nState)
	self.nBankState = nState;
end

-- 存入金币
function Bank:GoldSave(nValue)
	if (not nValue or 0 == Lib:IsInteger(nValue)) then
		return;
	end
	if (not nValue or nValue <= 0 or nValue > me.nCoin) then
		local szMsg = "您身上金币不够，不能进行该操作。";
		me.Msg(szMsg);
		return;
	end
	local bRet = me.RestoreCoin(nValue);
	if (bRet == 0) then
		me.Msg("游戏现在运行缓慢，请过会再来存钱。");
	end
end
Bank.tbc2sFun["GoldSave"] = Bank.GoldSave;

-- 从钱庄取出金币
function Bank:GoldDraw(nGoldDrawCount)
	if (not nGoldDrawCount or 0 == Lib:IsInteger(nGoldDrawCount)) then
		return;
	end
	local nGoldSum = me.GetTask(Bank.TASK_GROUP, Bank.TASK_ID_GOLD_SUM);
	if (not nGoldDrawCount or nGoldDrawCount <= 0 or nGoldDrawCount > nGoldSum) then
		local szMsg = "您的输入有误，请重新输入。";
		me.Msg(szMsg);
		return;
	end
	
	local nGoldLimit = me.GetTask(Bank.TASK_GROUP, Bank.TASK_ID_GOLD_LIMIT);
	local nHaveDraw = me.GetTask(Bank.TASK_GROUP, Bank.TASK_ID_TODAYTAKEOUTGOLDCOUNT);
	local nDate = me.GetTask(Bank.TASK_GROUP, Bank.TASK_ID_TAKEOUTGOLD_DATE);
	local nTime = GetTime();
	
	if (nTime - nDate >= self.DAYSECOND) then
		if (nGoldDrawCount > nGoldLimit)then
			me.Msg("您要取出的金币超过上限了。");
			return;
		end
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_TAKEOUTGOLD_DATE, nTime);
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_TODAYTAKEOUTGOLDCOUNT, nGoldDrawCount);
	else
		if ((nGoldDrawCount + nHaveDraw) > nGoldLimit) then
			local nCanDrawCount = nGoldLimit - nHaveDraw;
			if (nCanDrawCount < 0) then
				nCanDrawCount = 0;
			end
			local szMsg = "您在24小时内取出的金币超过上限，您最多还能取出<color=yellow>" .. nCanDrawCount .. "<color>金币。";
			me.Msg(szMsg);
			return;
		end
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_TODAYTAKEOUTGOLDCOUNT, nGoldDrawCount + nHaveDraw);
	end
	local bRet = me.TakeOutCoin(nGoldDrawCount);
	if (bRet == 0) then
		me.Msg("游戏现在运行缓慢，请过会再来取钱。");
	end
end
Bank.tbc2sFun["GoldDraw"] = Bank.GoldDraw;

-- 取消未生效的金币支取上限
function Bank:CancelGoldLimit()
	me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_GOLD_EFFICIENT_DAY, 0);
	me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_GOLD_UNEFFICIENT_LIMIT, 0);
	me.Msg("您已经成功取消未生效的金币支取上限。");	
	me.CallClientScript({"Bank:UpdateInfo"});
end
Bank.tbc2sFun["CancelGoldLimit"] = Bank.CancelGoldLimit;

-- 修改金币支取上限
function Bank:ModifyGoldLimit(nNewGoldLimit)
	if (not nNewGoldLimit or 0 == Lib:IsInteger(nNewGoldLimit)) then
		return;
	end
	if (not nNewGoldLimit or nNewGoldLimit <= 0 or nNewGoldLimit > Bank.MAX_COIN) then
		me.Msg("您输入的数字有误，请重新输入。");
		return;
	end
	
	local nOldGoldLimit = me.GetTask(Bank.TASK_GROUP, Bank.TASK_ID_GOLD_LIMIT);
	local szMsg = "";
	local nTime = GetTime();
	
	if nNewGoldLimit <= nOldGoldLimit then
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_GOLD_LIMIT, nNewGoldLimit);
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_GOLD_UNEFFICIENT_LIMIT, 0);
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_GOLD_EFFICIENT_DAY, 0);
		szMsg = "您新的金币支取上限<color=yellow>" .. nNewGoldLimit .. "<color>已经生效。";
	else
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_GOLD_UNEFFICIENT_LIMIT, nNewGoldLimit);
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_GOLD_EFFICIENT_DAY, nTime + self.EFFECITDAYS * self.DAYSECOND);
		szMsg = "您新的金币支取上限<color=yellow>" .. nNewGoldLimit .. "<color>将于"..self.EFFECITDAYS.."天后生效。";
	end
	
	me.Msg(szMsg);
	me.CallClientScript({"Bank:UpdateInfo"});
end
Bank.tbc2sFun["ModifyGoldLimit"] = Bank.ModifyGoldLimit;

-- 处理存入银两操作
function Bank:SilverSave(nValue)
	if (not nValue or 0 == Lib:IsInteger(nValue)) then
		return;
	end
	if (not nValue or nValue <= 0 or nValue > me.nCashMoney) then
		me.Msg("您的输入有误，请重新输入。");
		return;
	end
	local nMoney = me.GetTask(Bank.TASK_GROUP, Bank.TASK_ID_SILVER_SUM) + nValue;
	if (nMoney > me.GetMaxCarryMoney()) then
		me.Msg("您存入的银两达到了您当前等级段允许存储的最大额度。");
		return;
	end
	me.CostMoney(nValue, Player.emKPAY_RESTOREBANK);
	me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_SILVER_SUM, nMoney);
	
	local szMsg = "您已经成功存入银两<color=yellow>" .. nValue .. "<color>两。";
	me.Msg(szMsg);
	me.CallClientScript({"Bank:UpdateInfo"});
	
	szMsg = "在钱庄中存入银两：" .. nValue;
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_COINBANK, szMsg);
end
Bank.tbc2sFun["SilverSave"] = Bank.SilverSave;

-- 取出银两操作
function Bank:SilverDraw(nSilverDrawCount)	
	if (not nSilverDrawCount or 0 == Lib:IsInteger(nSilverDrawCount)) then
		return;
	end
	local nSilverSum = me.GetTask(Bank.TASK_GROUP, Bank.TASK_ID_SILVER_SUM);
	if (not nSilverDrawCount or nSilverDrawCount <= 0 or nSilverDrawCount > nSilverSum) then
		me.Msg("您的输入有误，请重新输入。");
		return;
	end	
	
	local nSilverLimit = me.GetTask(Bank.TASK_GROUP, Bank.TASK_ID_SILVER_LIMIT);
	local nHaveDraw = me.GetTask(Bank.TASK_GROUP, Bank.TASK_ID_TODAYTAKEOUTSILVERCOUNT);
	local nTime = GetTime();
	local nDate = me.GetTask(self.TASK_GROUP, self.TASK_ID_TAKEOUTSILVER_DATE);
	
	if (me.nCashMoney + nSilverDrawCount > me.GetMaxCarryMoney()) then
		me.Msg("您不能携带更多的随身银两了。");
		return;	
	end
	
	if (nTime - nDate >= self.DAYSECOND) then
		if (nSilverDrawCount > nSilverLimit) then
			me.Msg("您要取出的银两超过上限了。");
			return;
		end
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_TAKEOUTSILVER_DATE, nTime);
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_TODAYTAKEOUTSILVERCOUNT, nSilverDrawCount);
	else
		if ((nSilverDrawCount + nHaveDraw) > nSilverLimit) then
			local nCanDrawCount = nSilverLimit - nHaveDraw;
			if (nCanDrawCount < 0) then
				nCanDrawCount = 0;
			end
			local szMsg = "您在24小时内取出的银两超过上限，您最多还能够取出<color=yellow>" .. nCanDrawCount .. "<color>银两。"
			me.Msg(szMsg);
			return;
		end
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_TODAYTAKEOUTSILVERCOUNT, nHaveDraw + nSilverDrawCount);
	end	
	
	local nMoney = nSilverSum - nSilverDrawCount;	
	me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_SILVER_SUM, nMoney);
	me.Earn(nSilverDrawCount, Player.emKEARN_DRAWBANK);
		
	local szMsg = "您已经成功取出银两<color=yellow>" .. nSilverDrawCount .. "<color>两。";
	me.Msg(szMsg);
	me.CallClientScript({"Bank:UpdateInfo"});
	
	szMsg = "取出银两：" .. nSilverDrawCount;
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_COINBANK, szMsg);
end
Bank.tbc2sFun["SilverDraw"] = Bank.SilverDraw;

-- 取消未生效的银两支取上限
function Bank:CancelSilverLimit()
	me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_SILVER_EFFICIENT_DAY, 0);
	me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_SILVER_UNEFFICIENT_LIMIT, 0);
	me.Msg("您已经成功取消未生效的银两支取上限。");	
	me.CallClientScript({"Bank:UpdateInfo"});
end
Bank.tbc2sFun["CancelSilverLimit"] = Bank.CancelSilverLimit;

-- 修改银两支取上限
function Bank:ModifySilverLimit(nNewSilverLimit)
	if (not nNewSilverLimit or 0 == Lib:IsInteger(nNewSilverLimit)) then
		return;
	end
	if (not nNewSilverLimit or nNewSilverLimit <= 0 or nNewSilverLimit > Bank.MAX_MONEY) then
		me.Msg("您输入的数字有误，请重新输入。");
		return;
	end
	local nOldSilverLimit = me.GetTask(Bank.TASK_GROUP, Bank.TASK_ID_SILVER_LIMIT);
	local szMsg = "";
	local nTime = GetTime();
	
	if nNewSilverLimit <= nOldSilverLimit then
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_SILVER_LIMIT, nNewSilverLimit);
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_SILVER_UNEFFICIENT_LIMIT, 0);
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_SILVER_EFFICIENT_DAY, 0);
		szMsg = "您新的银两支取上限<color=yellow>" .. nNewSilverLimit .. "<color>已经生效。";
	else
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_SILVER_UNEFFICIENT_LIMIT, nNewSilverLimit);
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_SILVER_EFFICIENT_DAY, nTime + self.EFFECITDAYS * self.DAYSECOND);
		szMsg = "您新的银两支取上限<color=yellow>" .. nNewSilverLimit .. "<color>将于"..self.EFFECITDAYS.."天后生效。";
	end
	
	me.Msg(szMsg);
	me.CallClientScript({"Bank:UpdateInfo"});
end
Bank.tbc2sFun["ModifySilverLimit"] = Bank.ModifySilverLimit;

-- 判断并执行金币以及银两的生效操作
function Bank:DoEfficient()
	self:DoGoldEfficient();
	self:DoSilverEfficient();
	me.CallClientScript({"Bank:UpdateInfo"});
end
Bank.tbc2sFun["DoEfficient"] = Bank.DoEfficient;

-- 判断并执行金币的生效操作,如果存在0值,把该值赋值为默认值
function Bank:DoGoldEfficient()
	local nEfficientTime = me.GetTask(Bank.TASK_GROUP, Bank.TASK_ID_GOLD_EFFICIENT_DAY);
	local nTime = GetTime();
		
	if (nEfficientTime > 0 and nTime >= nEfficientTime) then
		local nNewGoldLimit = me.GetTask(Bank.TASK_GROUP, Bank.TASK_ID_GOLD_UNEFFICIENT_LIMIT);
		if (nNewGoldLimit == 0) then
			return 0;
		end
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_GOLD_LIMIT, nNewGoldLimit);
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_GOLD_EFFICIENT_DAY, 0);
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_GOLD_UNEFFICIENT_LIMIT, 0);
	end	
	
	local nGoldLimit = me.GetTask(Bank.TASK_GROUP, Bank.TASK_ID_GOLD_LIMIT);
	if (0 == nGoldLimit) then
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_GOLD_LIMIT, Bank.DEFAULTCOINLIMIT);
	end
end

-- 判断并执行银两的生效操作，如果存在0值，把该值赋值为默认值
function Bank:DoSilverEfficient()
	local nEfficientTime = me.GetTask(Bank.TASK_GROUP, Bank.TASK_ID_SILVER_EFFICIENT_DAY);
	local nTime = GetTime();
	
	if (nEfficientTime > 0 and nTime >= nEfficientTime) then
		local nNewSilverLimit = me.GetTask(Bank.TASK_GROUP, Bank.TASK_ID_SILVER_UNEFFICIENT_LIMIT);
		if (0 == nNewSilverLimit) then
			return 0;
		end
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_SILVER_LIMIT, nNewSilverLimit);
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_SILVER_EFFICIENT_DAY, 0);
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_SILVER_UNEFFICIENT_LIMIT, 0);
	end
	
	local nSilverLimit = me.GetTask(Bank.TASK_GROUP, Bank.TASK_ID_SILVER_LIMIT);
	if (0 == nSilverLimit) then
		me.SetTask(Bank.TASK_GROUP, Bank.TASK_ID_SILVER_LIMIT, Bank.DEFAULTMONEYLIMIT);
	end
end
