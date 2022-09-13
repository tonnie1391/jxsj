-------------------------------------------------------------------
--File: jbexchange_gs.lua
--Author: ZouYing
--Date: 2008-3-6
--Describe: 金币交易所服务器端的逻辑
-------------------------------------------------------------------
if not JbExchange then
	JbExchange = {};
elseif not MODULE_GAMESERVER then
	return;
end

JbExchange.SELLTYPE	= 0;
JbExchange.BUYTYPE	= 1;
JbExchange.tbc2sFun   = {};

JbExchange.MAXPRICE		= 3000;
JbExchange.MAXNUMBER	= 99999;

JbExchange.GetPrvAvgPrice = 200;

-- 设置休市
function JbExchange:SetClose(bClose)
	
	local nRet	= KJbExchange.SetClose(bClose);
	local szMsg	= "";
	if (bClose ~= 0) then
		szMsg = "休市";
	else
		szMsg = "开市";
	end
	if (nRet == 0) then
		szMsg = szMsg .. "设置失败。";
	else
		szMsg = szMsg .. "设置成功。";
	end
	Dialog:SendInfoBoardMsg(me,"<color=red>"..szMsg.."<color>");
end

-- 申请显示是否休市时间
function JbExchange:AcceptIsClose(nPlayerId)
	local bClose	= KJbExchange.IsClose();
	local pPlayer	= KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return 0;
	end
	
	local nRet	= pPlayer.CallClientScript({"JbExchange:GetBClose", bClose});
end
JbExchange.tbc2sFun["ApplyIsClose"] = JbExchange.AcceptIsClose

--	设置税率
function JbExchange:SetTax(nTax)
	if (nTax <= 0) then
		Dialog:SendInfoBoardMsg(me,"<color=red>税率不能设置成为负数！<color>");
		return 0;
	end
	local nRet	= GCExcute({"JbExchange:SetTradeTax", nTax});
	if (nRet == nil or nRet == 0) then
		Dialog:SendInfoBoardMsg(me,"<color=red>税率设置失败！<color>");
	end
end

--添加一个订单 
function JbExchange:AddBill(nPrice, nCount, nType)
	if me.GetTask(2093,23) + 30 >= GetTime() then
		Dialog:Say("请不要频繁挂单，挂单后必须等待30秒后才允许重新挂单。");
		return 0;
	end
	me.SetTask(2093,23, GetTime());	
	local nCanOpen = self:ForbidMgr();
	if (0 == nCanOpen) then
		return;
	end
	if (not nPrice or not nCount or not nType or
		0 == Lib:IsInteger(nPrice) or 0 == Lib:IsInteger(nCount) or 0 == Lib:IsInteger(nType)) then
		return;
	end
	
	if (KJbExchange.IsClose() == 1) then
		Dialog:SendInfoBoardMsg(me,"<color=red>现在是休市时间，不能提交交易单!<color>");
		return;
	end
	
	if (me.IsAccountLock() ~= 0) then
		Dialog:SendInfoBoardMsg(me,"<color=red>你的账号处于锁定状态，不能提交交易单!<color>");
		Account:OpenLockWindow(me)
		return;
	end
	
	if Account:Account2CheckIsUse(me, 3) == 0 then
		Dialog:Say("你正在使用副密码登陆游戏，设置了权限控制，无法进行该操作！");
		return 0;
	end
	
	if (nPrice > self.MAXPRICE or nPrice <= 0 or nCount <= 0 or nCount > self.MAXNUMBER or (nType ~= 0 and nType ~= 1)) then
		Dialog:SendInfoBoardMsg(me,"<color=red>您的交易单有误。<color>");
		return;
	end	
	local bHave = KJbExchange.HaveBill(me.nId);
	if (bHave == 1)then
		Dialog:SendInfoBoardMsg(me,"<color=red>您已经有订单，不能再提交！<color>");
		return;
	end
	local nTotalMoney	= nPrice * nCount;
	if (nType == self.BUYTYPE) then
		if (me.nCashMoney < nTotalMoney) then
			Dialog:SendInfoBoardMsg(me,"<color=red>您的身上的银两不够，挂单失败！<color>");
			return;
		end
	else
		local nCoin	= me.GetJbCoin();
		if (nCoin < nCount) then
			Dialog:SendInfoBoardMsg(me,"<color=red>您身上的金币不够，挂单失败！<color>");
			return;
		end
		local nTax = KJbExchange.GetTax();
		nTotalMoney	= math.floor(nCount * nPrice * (100 - nTax) / 100);
	end
	local nMoney	= KJbExchange.GetAccountMoney(me.nId) or 0;
	if (nTotalMoney + nMoney > me.GetMaxCarryMoney()) then
		Dialog:SendInfoBoardMsg(me,"<color=red>总价与帐户银两相加超过官府许可，挂单失败。<color>");
		return;
	end
	local nRet = GCExcute({"JbExchange:AddOneBill", me.nId, nPrice, nCount, nType});
	if (nRet == 1) then
		if (nTotalMoney and nTotalMoney > 0 and nType == self.BUYTYPE) then
			me.CostMoney(nTotalMoney, Player.emKPAY_JBEXCHANGE);
			Dbg:WriteLogEx(Dbg.LOG_ATTENTION, me.szName, nTotalMoney, GetLocalDate("%Y-%m-%d %H:%M:%S"));
		end
	else
		Dialog:SendInfoBoardMsg(me,"<color=red>您的挂单失败。<color>");	
	end
	
end
JbExchange.tbc2sFun["ApplyAddBill"] = JbExchange.AddBill

--	对于提交单的反馈结果
function JbExchange:AddBillResult(nPlayerId, nResult, nType, nTotalMoney)
	local szMsg = "";
	local pPlayer	= KPlayer.GetPlayerObjById(nPlayerId);
	if (pPlayer ~= nil) then
		if (nResult == 0) then
			if (nType == self.SELLTYPE) then
				szMsg	= "交易单提交失败。";
			elseif (nType == self.BUYTYPE) then
				szMsg	= "交易单提交失败。";
			end
			Dialog:SendInfoBoardMsg(pPlayer,"<color=red>"..szMsg.."<color>");	
		elseif (nResult == 1100 or nResult == -1) then
			if (nResult == 1100) then
				szMsg	= "您已经有订单，不能再提交！";
			else
				szMsg = "游戏目前运行缓慢，请您稍后再来交易。"
			end
			if (nType == self.BUYTYPE and nTotalMoney > 0) then
				pPlayer.Earn(nTotalMoney, Player.emKEARN_EXCHANGE_BUYFAIL);
			end
			Dialog:SendInfoBoardMsg(pPlayer, szMsg);
		else
			szMsg	= "您的交易申请单已经提交，请等待交易成功。在交易申请单取消前，您交易所需的部分银两或金币将被锁定，不能取出。";
			pPlayer.Msg(szMsg);
		end
		self:AcceptApplyBillList(nPlayerId);
		self:AcceptApplyPlayerBillInfo(nPlayerId);
	end	
end

--	取消一个交易单
function JbExchange:DelOneBill(nBillIndex, btType)
	if me.GetTask(2093,23) + 5 >= GetTime() then
		Dialog:Say("你刚进行了挂单，请稍后几秒再进行撤单操作。");
		return 0;
	end
	local nCanOpen = self:ForbidMgr();
	if (0 == nCanOpen) then
		return;
	end
	if (not nBillIndex or not btType or 0 == Lib:IsInteger(nBillIndex) or 0 == Lib:IsInteger(btType)) then
		return;
	end
	if (KJbExchange.IsClose() == 1) then
		Dialog:SendInfoBoardMsg(me,"<color=red>现在是休市时间，不能撤销交易单！<color>");
		return;
	end

	if (me.IsAccountLock() ~= 0) then
		Dialog:SendInfoBoardMsg(me,"<color=red>你的账号处于锁定状态，不能取消交易单!<color>");
		Account:OpenLockWindow(me);
		return;
	end
	if Account:Account2CheckIsUse(me, 3) == 0 then
		Dialog:Say("你正在使用副密码登陆游戏，设置了权限控制，无法进行该操作！");
		return 0;
	end	
	if (nBillIndex <= 0 or (btType ~= self.SELLTYPE and btType ~= self.BUYTYPE)) then
		Dialog:SendInfoBoardMsg(me, "<color=red>您没有提交单！<color>");
		return;	
	end
	local nRet	= GCExcute({"JbExchange:DelOneBill", me.nId, nBillIndex, btType});
	if (nRet ~= 1) then
		Dialog:SendInfoBoardMsg(me,"<color=red>您在金币交易所提交的交易单撤销失败。<color>");
	end
end
JbExchange.tbc2sFun["ApplyCancelBill"] = JbExchange.DelOneBill

-- 撤销结果的反馈
function JbExchange:DelOneBillResult(nPlayerId, nResult)
	local pPlayer	= KPlayer.GetPlayerObjById(nPlayerId);
	if (pPlayer ~= nil) then
		if (nResult == nil or nResult == 0) then
			Dialog:SendInfoBoardMsg(pPlayer,"<color=red>您在金币交易所提交的交易单撤销失败。<color>");
		elseif (nResult == -1) then
			Dialog:SendInfoBoardMsg(pPlayer, "游戏目前运行缓慢，请您稍后再来撤销。");
		else
			pPlayer.Msg("<color=red>您在金币交易所的交易单撤销成功。<color>");	
		end
	end	
	self:AcceptApplyBillList(nPlayerId);
	self:AcceptApplyPlayerBillInfo(nPlayerId);
end

-- 申请要显示的列表
function JbExchange:AcceptApplyBillList(nPlayerId)
	
	local nId = nPlayerId or me.nId;
	KJbExchangeGs.ApplyShowBillList(nId);
end
JbExchange.tbc2sFun ["ApplyBillList"] = JbExchange.AcceptApplyBillList

-- 申请玩家的各类信息
function JbExchange:AcceptApplyPlayerBillInfo(nPlayerId)
	local nId = nPlayerId or me.nId;
	KJbExchangeGs.ApplyPlayerBill(nId);
end
JbExchange.tbc2sFun ["ApplyPlayerBillInfo"] = JbExchange.AcceptApplyPlayerBillInfo

--	从帐户中取金钱
function JbExchange:AcceptGetMoney(nMoney)
	local nCanOpen = self:ForbidMgr();
	if (0 == nCanOpen) then
		return;
	end
	if (not nMoney or 0 == Lib:IsInteger(nMoney)) then
		return;
	end
	if (me.IsAccountLock() ~= 0) then
		Dialog:SendInfoBoardMsg(me,"<color=red>你的账号处于锁定状态，不能取钱!<color>");
		Account:OpenLockWindow(me);
		return;
	end
	if Account:Account2CheckIsUse(me, 3) == 0 then
		Dialog:Say("你正在使用副密码登陆游戏，设置了权限控制，无法进行该操作！");
		return 0;
	end	
	if (nMoney + me.nCashMoney > me.GetMaxCarryMoney()) then
		Dialog:SendInfoBoardMsg(me,"<color=red>取出的银两超过背包可携带上限，取钱失败！<color>");
		return;
	end
	local nAccoutMoney	= KJbExchange.GetAccountMoney(me.nId) or 0;
	
	if (nMoney <= 0 or (nAccoutMoney < nMoney)) then
		Dialog:SendInfoBoardMsg(me,"<color=red>取钱失败，您的输入有误，请重新输入！<color>");
		return;
	end
	-- 设置取钱状态
	me.AddWaitGetItemNum(1);
	local nRet = GCExcute{"JbExchange:ApplyGetMoney", me.nId, nMoney};
	if (bRet == 0) then
		Dialog:SendInfoBoardMsg(me,"<color=red>取钱失败。<color>");
	end
end
JbExchange.tbc2sFun["ApplyGetCashMoney"] = JbExchange.AcceptGetMoney

-- 处理每天事务
function JbExchange:ProcessDayEvent()
	GCExcute{"JbExchange:ProcessEveryDayEvent"};
end

-- 清除所有交易单
function JbExchange:DelAllBill()
	KJbExchange.DelAllBill();
end

-- 登陆时同步税率
function JbExchange:OnLogin()
	me.CallClientScript({"JbExchange:SetPrvAvgPrice", JbExchange.GetPrvAvgPrice});
end

-- 同步汇率
function JbExchange:SyncAvgPrice(nAvgPrice)
	local tbPlayerList	= KPlayer.GetAllPlayer();
	
	for _, pPlayer in ipairs(tbPlayerList) do
		pPlayer.CallClientScript({"JbExchange:SetPrvAvgPrice", nAvgPrice});
	end
end

-- 指令改变汇率的回调，同步新汇率给在线玩家
function JbExchange:OnChangePreAvgPrice()
	local nAvgPrice = JbExchange.GetPrvAvgPrice
	self:SyncAvgPrice(nAvgPrice);
end

-- 从账户取钱结果反馈
function JbExchange:GetMoneyResult(nPlayerId, nRet)
	local pPlayer	= KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		--assert(false);
		return;
	end
	if (nRet == -1 ) then
		Dialog:SendInfoBoardMsg(pPlayer,"<color=red>帐户上的钱不够。<color>");
	elseif (nRet == 1) then
		pPlayer.Msg("<color=red>取钱成功。<color>");
	elseif (nRet == 0) then
		Dialog:SendInfoBoardMsg(pPlayer,"<color=red>取钱失败。<color>")
	end	
end

function JbExchange:ForbidMgr()
	local bIsInPrison = me.IsInPrison();
	if (bIsInPrison and bIsInPrison == 1) then
		return 0;
	end
	
	if (GLOBAL_AGENT) then
		return 0;
	end;
	
	return 1;
end

-- 判断是否可以打开金币交易所
function JbExchange:ApplyOpenJbExchange()
	local nCanOpen = self:ForbidMgr();
	me.CallClientScript({"JbExchange:CanOpenJbExchange", nCanOpen});
end
JbExchange.tbc2sFun["ApplyOpenJbExchange"] = JbExchange.ApplyOpenJbExchange

if (MODULE_GAMESERVER) then	-- GS专用
	-- 注册事件回调
	PlayerEvent:RegisterGlobal("OnLogin", JbExchange.OnLogin, JbExchange);
end
