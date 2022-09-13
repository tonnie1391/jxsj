-------------------------------------------------------------------
--File: account_gs.lua
--Author: lbh
--Date: 2008-6-27 10:04
--Describe: 账号相关GS端
-------------------------------------------------------------------
Require("\\script\\account\\account_head.lua");
Require("\\script\\player\\playerevent.lua");

Account.tbUnlockFailCount = {} -- 账号解锁失败次数
Account.tbBanUnlockTime = {} -- 账号禁止时间
Account.UNLOCK_FAIL_LIMIT = 5;
Account.UNLOCK_BAN_TIME = 30;	-- 解锁达失败次数冻结多少分钟
Account.TIME_UNLOCKPASSPOD = 60 * 1.5;	-- 登陆后1.5分钟不得解锁
Account.c2sCmd = {};
Account.TSK_GROUP = 2137;				-- 台湾手机锁解锁辅助变量
Account.TSK_ID_FLAG = 1;				-- 台湾手机锁解锁辅助变量

function Account:ProcessClientCmd(nId, tbParam)
	if type(nId) ~= "number" then
		return;
	end
	local fun = self.c2sCmd[nId];
	if not fun then
		return;
	end
	fun(Account, unpack(tbParam));
end

function Account:SetAccPsw(nOldPsw, nNewPsw, nr)
	if not nr then
		nr = 1;
	end
	nNewPsw = math.floor(math.floor(nNewPsw * nr) / 64);
	local bSetOldPsw = 0;
	if (nOldPsw ~= 0) then
		bSetOldPsw = 1;
		nOldPsw = math.floor(nOldPsw * math.floor(nNewPsw / 1048576) / 64) - 1000000;
	end
	nNewPsw = nNewPsw % 1048576;
	local nNameId = KLib.String2Id(tostring(me.GetNpc().dwId));
	local nNewPswOrg = nNewPsw;
	local nOldPswOrg = nOldPsw;
	nNewPsw = 0;
	nOldPsw = 0;
	local nPos = 1;
	for i = 1, 6 do
		nNewPsw = nNewPsw + ((nNewPswOrg - nNameId) % 10 + 10) % 10 * nPos;
		nNewPswOrg = math.floor(nNewPswOrg / 10);
		if bSetOldPsw ~= 0 then
			nOldPsw = nOldPsw + ((nOldPswOrg - nNameId) % 10 + 10) % 10 * nPos;		
			nOldPswOrg = math.floor(nOldPswOrg / 10);
		end
		nNameId = math.floor(nNameId / 10);
		nPos = nPos * 10;
	end
	
	if nNewPsw < 100000 or nNewPsw > 999999 then
		me.Msg("设定失败：密码必须为6位，且不能以0开头！");
		return 0;
	end
	
	local szAccount = me.szAccount;
	local nBanTime = self.tbBanUnlockTime[szAccount];
	if nBanTime then
		local nLeftMin = math.ceil(nBanTime / 60 + self.UNLOCK_BAN_TIME -  GetTime() / 60);
		if nLeftMin > 0 then
			me.Msg("<color=yellow>"..nLeftMin.."<color>分钟后你才能再次尝试！");
			return 0;
		end
		self.tbBanUnlockTime[szAccount] = nil;
	end
	
	if me.SetAccountLockCode(nOldPsw, nNewPsw) ~= 1 then
		me.Msg("设定失败：原密码不正确！");
		self:PswFail();
		return 0;	
	end
	
	if self.tbUnlockFailCount[szAccount] then
		GlobalExcute{"Account:SetUnLockAccFailCount", szAccount, nil};
	end
	
	if (nOldPsw == 0) then
		me.UnLockAccount(nNewPsw); -- 重新同步锁定状态
		me.Msg("账号锁密码设定成功，该账号下所有角色在以后每次登录游戏时，锁定功能会自动开启！");	
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "账号锁密码设定成功。");
		
	else
		me.Msg("账号锁密码更改成功！");
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "账号锁密码更改成功。");
	end

	return 1;
end
Account.c2sCmd[Account.SET_PSW] = Account.SetAccPsw;

function Account:LockAcc()
	if me.LockAccount() ~= 1 then		
		me.Msg("锁定账号失败：账号锁密码未设定！");
		return;
	end
	me.Msg("账号已锁定！");
	return 1;
end
Account.c2sCmd[Account.LOCKACC] = Account.LockAcc;

-- 是否有权申请自助解锁
function Account:CanApplyDisableLock()
	if me.GetAccountMaxLevel() > me.nLevel then
		return 0;
	end
	return 1;
end

-- 申请自助解锁
function Account:DisableLock_Apply()
	if me.IsAccountLockOpen() ~= 1 then
		me.Msg("Tài khoản đang khóa.");
		return 0;
	end
	if self.CanApplyDisableLock() == 1 then
		me.DisableAccountLock_Apply();
		me.Msg("您已经申请自助解锁，将于<color=yellow>5天后再登录此角色时<color>生效，在这期间随时可以来取消。")
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "申请自助解锁。");
	else
		me.Msg("请登录你帐号下等级最高的角色申请自助解锁。");
	end
	self:SyncJiesuoStateToClient();
end
Account.c2sCmd[Account.JIESUO_APPLY] = Account.DisableLock_Apply;

-- 自助解锁 执行
function Account:DisableLock()
	me.ClearAccountLock();
	Account:DisableLock_Cancel(); -- 清除自助解锁申请
	
	self:SyncJiesuoStateToClient();
	me.CallClientScript({"Player:JiesuoNotify"});
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "自助解锁已经执行成功。");
end

-- 取消自助解锁申请
function Account:DisableLock_Cancel()
	me.DisableAccountLock_Cancel();
	self:SyncJiesuoStateToClient();
end

function Account:Jiesuo_Cancel()
	self:DisableLock_Cancel();
	me.Msg("自助解锁申请已取消。");
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "成功取消自助解锁申请。");
end
Account.c2sCmd[Account.JIESUO_CANCEL] = Account.Jiesuo_Cancel;

function Account:GetDisableLockApplyTime()
	--me.Msg("上次申请解锁时间 "..os.date("%Y-%m-%d %H:%M:%S", me.GetDisableAccountLockApplyTime()));
	return me.GetDisableAccountLockApplyTime();
end

function Account:IsApplyingDisableLock()
	return me.IsApplyingDisableAccountLock();
end
Account.c2sCmd[Account.IS_APPLYING_JIESUO] = Account.IsApplyingDisableLock;

function Account:UnLockAcc(nPsw, nr)
	if (me.GetPasspodMode() == 1) then
		return 0;	-- 有密保，原账号锁失效
	end
	
	if not nr then
		nr = 1;
	end
	nPsw = math.floor(math.floor(nPsw * nr) / 64) % 1048576;
	if nPsw == 0 then
		return 0;
	end
	local nNameId = KLib.String2Id(tostring(me.GetNpc().dwId));
	local nOldPsw = nPsw;
	nPsw = 0;
	local nPos = 1;
	for i = 1, 6 do
		nPsw = nPsw + ((nOldPsw - nNameId) % 10 + 10) % 10 * nPos;
		nOldPsw = math.floor(nOldPsw / 10);
		nNameId = math.floor(nNameId / 10);
		nPos = nPos * 10;
	end
	if nPsw == 0 then
		return 0;
	end
	local szAccount = me.szAccount;
	local nBanTime = self.tbBanUnlockTime[szAccount];
	if nBanTime then
		local nLeftMin = math.ceil(nBanTime / 60 + self.UNLOCK_BAN_TIME -  GetTime() / 60);
		if nLeftMin > 0 then
			me.Msg("<color=yellow>"..nLeftMin.."<color>分钟后你才能再次尝试解锁账号！");
			return 0;
		end
		self.tbBanUnlockTime[szAccount] = nil;
	end

	local szLog = string.format("申请解锁\t%s\t类型:密码锁", me.szName);
	Dbg:WriteLogEx(Dbg.LOG_INFO, "Account", szLog);
	
	return me.UnLockAccount(nPsw);
end
Account.c2sCmd[Account.UNLOCK] = Account.UnLockAcc;

function Account:UnLockAcc_ByPasspod(szCode)
	if (me.GetPasspodMode() == 0) then
		return 0;	-- 无密保
	end
	if type(szCode) ~= "string" then
		return 0;
	end

	if (me.GetPasspodMode() == self.PASSPODMODE_ZPTOKEN or me.GetPasspodMode() == self.PASSPODMODE_KSPHONELOCK) and 
		(GetTime() < Player:GetLastLoginTime(me) + self.TIME_UNLOCKPASSPOD) then
			return 0;	-- 金山令牌 登陆后1.5分钟内不得解锁
	end
	
	local szAccount = me.szAccount;
	local nBanTime = self.tbBanUnlockTime[szAccount];
	if nBanTime then
		local nLeftMin = math.ceil(nBanTime / 60 + self.UNLOCK_BAN_TIME -  GetTime() / 60);
		if nLeftMin > 0 then
			me.Msg("<color=yellow>"..nLeftMin.."<color>分钟后你才能再次尝试解锁账号！");
			return 0;
		end
		self.tbBanUnlockTime[szAccount] = nil;
	end
	
	local szType = "密保卡";
	if (me.GetPasspodMode() == self.PASSPODMODE_ZPTOKEN) then
		szType = "金山令牌";
	end
	local szLog = string.format("申请解锁\t%s\t类型:%s", me.szName, szType);
	Dbg:WriteLogEx(Dbg.LOG_INFO, "Account", szLog);
	
	me.ClearAccountLock();	-- 清除安全锁
	return me.UnLockPasspodAccount(szCode);
end
Account.c2sCmd[Account.UNLOCK_BYPASSPOD] = Account.UnLockAcc_ByPasspod;

function Account:UnLockAcc_PhoneLock()
	local szLog = string.format("申请解锁\t%s\t类型:手机锁", me.szName);
	Dbg:WriteLogEx(Dbg.LOG_INFO, "Account", szLog);
	
	GCExcute{"Account:OnApplyPhoneLock", me.szName};
end
Account.c2sCmd[Account.UNLOCK_PHONELOCK] = Account.UnLockAcc_PhoneLock;

function Account:OnUnlockResult(nResult)
	if (nResult == 1) then
		if self.tbUnlockFailCount[me.szAccount] then
			GlobalExcute{"Account:SetUnLockAccFailCount", me.szAccount, nil};
		end
		me.Msg("解锁成功！");
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "解锁成功。");
		return;
	end
	
	local szErrorMsg = "";
	if (0 == nResult) then
		local bIsAccountLockOpen = me.GetAccountLockState();
		local bIsPhoneLockOpen = me.GetPhoneLockState();
		local bHasPhoneLock = IVER_g_bHasPhoneLock;
		if (bHasPhoneLock == 1) then
			if (bIsAccountLockOpen == 1 and bIsPhoneLockOpen == 0) then
				me.Msg("手机锁已经解开，请再解开账号锁。");
				
				if (0 ~= me.GetTask(self.TSK_GROUP, self.TSK_ID_FLAG)) then
					szErrorMsg = "解锁失败：安全锁密码错误，请重新输入。";
					me.Msg(szErrorMsg);
					me.CallClientScript({"Ui:ServerCall", "UI_LOCKACCOUNT", "UpdateErrorMsg" , szErrorMsg});	
					me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szErrorMsg);
					self:PswFail();
				else
					me.SetTask(self.TSK_GROUP, self.TSK_ID_FLAG, 1);
				end
				
				return;
			elseif (bIsAccountLockOpen == 0 and bIsPhoneLockOpen == 1) then
				me.Msg("账号锁已经解开，请再解开手机锁。");
				return;
			end
		end
	end
	
	if (me.GetPasspodMode() ~= 0) then
		
		szErrorMsg = "解锁失败："..(self.FAILED_RESULT[nResult] or "未知错误");
		
		me.Msg(szErrorMsg);
		
		--通知客户端界面更新错误提示
		me.CallClientScript({"Ui:ServerCall", "UI_LOCKACCOUNT", "UpdateErrorMsg" , szErrorMsg});	
	
		
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szErrorMsg);
	else
		
		szErrorMsg = "解锁失败：安全锁密码错误，请重新输入。";
		
		me.Msg(szErrorMsg);
		
	  --通知客户端界面更新错误提示
		me.CallClientScript({"Ui:ServerCall", "UI_LOCKACCOUNT", "UpdateErrorMsg" , szErrorMsg});	
		
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szErrorMsg);
	end
	self:PswFail();
end

function Account:OnUnlockPhoneLockResult(szPlayerName, nResult)
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if pPlayer then
		if (1 == nResult) then
			pPlayer.UnLockAccount(0, 1);
			pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "手机锁密码设定成功。");
		end
		pPlayer.CallClientScript{"Ui:ServerCall", "UI_LOCKACCOUNT", "PhoneLockResult" , nResult};
	end
end

function Account:SetUnLockAccFailCount(szAccount, nCount)
	self.tbUnlockFailCount[szAccount] = nCount;
end

function Account:SetUnLockAccBanTime(szAccount, nTime)
	self.tbBanUnlockTime[szAccount] = nTime;
	self.tbUnlockFailCount[szAccount] = 0; -- 次数清0
end

function Account:PswFail()
	local szAccount = me.szAccount;
	local nFailCount = self.tbUnlockFailCount[szAccount];	
	if not nFailCount then
		nFailCount = 0;
	end
	nFailCount = nFailCount + 1;
	
	if nFailCount >= self.UNLOCK_FAIL_LIMIT then
		
		local szErrorMsg = "账号锁密码错误次数已达上限，<color=yellow>"..self.UNLOCK_BAN_TIME..
			"<color>分钟内您将不能再次尝试！（如果您确定已遗忘了账号锁密码，请与客服联系）。"
		me.Msg(szErrorMsg);
		
		--通知客户端界面更新错误提示
		me.CallClientScript({"Ui:ServerCall", "UI_LOCKACCOUNT", "UpdateErrorMsg" , szErrorMsg});	
		
		local nTime = GetTime();
		self.tbBanUnlockTime[szAccount] = nTime;
		GlobalExcute{"Account:SetUnLockAccBanTime", szAccount, nTime};	

		return 0;
	end	
	me.Msg("账号锁密码错误次数已达到<color=yellow>"..nFailCount..
	"<color>次，如果连续<color=yellow>"..self.UNLOCK_FAIL_LIMIT.."<color>次失败，在<color=yellow>"..
		self.UNLOCK_BAN_TIME.."<color>分钟内您同一账号下的角色将不能再次尝试！");
	
	self.tbUnlockFailCount[szAccount] = nFailCount;
	
	GlobalExcute{"Account:SetUnLockAccFailCount", szAccount, nFailCount};
	return 1;
end

function Account:OnLogin(bExchangeServer)
	if me.GetPasspodMode() == self.PASSPODMODE_ZPMATRIX then
		self:RandomMatrixPos();	-- 随机矩阵卡位置
	end
	if (bExchangeServer == 1) then
		return;
	end	
	me.SetTask(self.TSK_GROUP, self.TSK_ID_FLAG, 0);
	if me.IsApplyingDisableAccountLock() == 1 then		
		local dwTimeApply = me.GetDisableAccountLockApplyTime();
		if dwTimeApply ~= 0 then
			if dwTimeApply + 5 * 24 * 60 * 60 <= GetTime() then
				Account:DisableLock();
			else
				me.CallClientScript({"Player:ApplyJiesuoNotify", me.GetDisableAccountLockApplyTime()});				
			end
		else
			me.CallClientScript({"Player:ApplyJiesuoNotify"});
		end
	end
	self:SyncJiesuoStateToClient();
	if (UiManager.IVER_nIsLoginOpenLockWnd == 1) then
		self:OpenLockWindow(me);
	end
	local nLimiLevel, nSpeLevel, nMonthLimit = jbreturn:GetRetLevel(me);
	local nIsNoUse = Account:GetIntValue(me.szAccount, "Account.VipIsNoUse"); 
	if nLimiLevel > 0 and nIsNoUse == 0 then
		local szCurIp = Lib:IntIpToStrIp(me.GetTask(2063, 1)) or "0.0.0.0";
		local szCurArea = GetIpAreaAddr(me.GetTask(2063, 1)) or "未知区域";
		GCExcute({"Account:LogLimitAccount", me.szName, me.szAccount, nLimiLevel, nSpeLevel, nMonthLimit, me.nMonCharge, me.GetHonorLevel(), szCurIp , szCurArea});
	end
end

function Account:RandomMatrixPos()
	local tbRow = {'A','B','C','D','E','F','G','H'};
	local tbLine = {1, 2, 3, 4, 5, 6, 7, 8, 9, 0};
	
	local szPos = "";
	for i = 1, 3 do
		local nIndex = MathRandom(#tbRow);
		szPos = szPos..tbRow[nIndex];
		table.remove(tbRow, nIndex);
		nIndex = MathRandom(#tbLine);
		szPos = szPos..tbLine[nIndex];
		table.remove(tbLine, nIndex);
	end
	me.SetMatrixPosition(szPos);
end

function Account:SyncJiesuoStateToClient()
	me.CallClientScript({"Player:SyncJiesuoState_C", self.CanApplyDisableLock()
		, self.IsApplyingDisableLock(), self.GetDisableLockApplyTime()});
end

-- 是否打开推广密保和令牌
function Account:IsOpenPasspodAd()
	return IVER_g_nLockAccount or 0;
end

function Account:OpenLockWindow(pPlayer)
	if (not pPlayer) then
		return;
	end
	if (EventManager.IVER_nOpenLockWnd == 1) then
		pPlayer.CallClientScript({"UiManager:OpenWindow", "UI_LOCKACCOUNT"});
	end
end

function Account:OpenLockWindow(pPlayer)
	if (not pPlayer) then
		return;
	end
	if (EventManager.IVER_nOpenLockWnd == 1) then
		pPlayer.CallClientScript({"UiManager:OpenWindow", "UI_LOCKACCOUNT"});
	end
end

PlayerEvent:RegisterGlobal("OnLogin", Account.OnLogin, Account);

