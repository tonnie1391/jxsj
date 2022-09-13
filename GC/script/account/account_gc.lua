
function Account:OnPhoneLockResult(szName, nResult)
	return GlobalExcute{"Account:OnUnlockPhoneLockResult", szName, nResult};
end

function Account:OnApplyPhoneLock(szName)
	local nRet = ApplyUnlockPhoneLock(szName);
	if nRet ~= 1 then
		self:OnPhoneLockResult(szName, 2);			-- 重复申请
	end
end

--记录角色等级
function Account:LogLimitAccount(szName, szAccount, nLimiLevel, nSpeLevel, nMonthLimit, nMonCharge, nHonorLevel, szCurIp , szCurArea)
	local tbBuff = self:GetAccountLimitBuff();
	local szDate = os.date("%Y-%m-%d", GetTime());
	tbBuff[szAccount] = tbBuff[szAccount] or {};
	tbBuff[szAccount][szName] = tbBuff[szAccount][szName] or {};
	tbBuff[szAccount][szName] = {nLimiLevel, nSpeLevel, nMonthLimit, nMonCharge, nHonorLevel, szDate, 1, szCurIp, szCurArea};
	local szCurName = Account:GetBinValue(szAccount, "Account.VipName");
	if szCurName == "" then
		szCurName = "未设置";
	end

	--角色转移了账号情况
	if self.tbNameAccountList[szName] and self.tbNameAccountList[szName] ~= szAccount then
		if tbBuff[self.tbNameAccountList[szName]] and tbBuff[self.tbNameAccountList[szName]][szName] then
			tbBuff[self.tbNameAccountList[szName]][szName][7] = "转移角色";
		end
	end
	self.tbNameAccountList[szName] = szAccount;
end

function Account:SetLimitAccountCurName(szAccount, szCurName)
	Account:ApplySetBinValue(szAccount, "Account.VipName", szCurName);
	return 1;
end

function Account:DelAccountLimit(szName, szAccount, nLimiLevel, nSpeLevel, nMonthLimit, nMonCharge, nHonorLevel)
	Account:LogLimitAccount(szName, szAccount, nLimiLevel, nSpeLevel, nMonthLimit, nMonCharge, nHonorLevel, "0.0.0.0", "未知区域");
	local tbBuff,tbBuff2 = self:GetAccountLimitBuff();
	for szName, tbInfo in pairs(tbBuff[szAccount]) do
		tbInfo[7] = 0;
	end
	Account:SetAccountLimitIsUse(szAccount, 1);
	SetGblIntBuf(GBLINTBUF_ACC_LIMIT, 0, 0, tbBuff);
end

function Account:SetAccountLimitIsUse(szAccount, bInt)
	Account:ApplySetIntValue(szAccount, "Account.VipIsNoUse", bInt, 0);
	return 1;
end

function Account:ScheduletaskAccountLimitSave()
	local szGateWay = GetGatewayName();
	local szGateName = ServerEvent:GetServerNameByGateway(szGateWay);
	local szOutFile = "\\accountlimit\\".. szGateWay .."_accountlimit.txt";
	local szContext = "网关\t服务器名\t账号\t角色名\t优惠等级\t特殊优惠\t优惠额度\t当月充值额\t财富荣誉等级\t最近上线日期\t是否取消\t最近登陆Ip\t最近登陆地区\t归属权\n";
	KFile.WriteFile(szOutFile, szContext);
	local tbBuff = self:GetAccountLimitBuff();
	for szAccount, tbName in pairs(tbBuff) do
		for szName, tbInfo in pairs(tbName) do
			local szUseInfo = "未知状况";
			local szCurName = "未设置";

			local nUseInfo = Account:GetIntValue(szAccount, "Account.VipIsNoUse");
			szUseInfo = self.tbLimitUseType[nUseInfo] or "";
			szCurName = Account:GetBinValue(szAccount, "Account.VipName");
			if nUseInfo == 0 then
				szUseInfo = self.tbLimitUseType[tbInfo[7]] or "";
			end
	
			local szOut = string.format("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
				szGateWay,
				szGateName,
				szAccount,
				szName,
				tbInfo[1] or 0,
				tbInfo[2] or 0,
				tbInfo[3] or 0,
				tbInfo[4] or 0,
				tbInfo[5] or 0,
				tbInfo[6] or 0,
				szUseInfo or "",
				tbInfo[8] or "0.0.0.0",
				tbInfo[9] or "未知区域",
				szCurName or "");
			KFile.AppendFile(szOutFile, szOut);
		end
	end
	SetGblIntBuf(GBLINTBUF_ACC_LIMIT, 0, 1, tbBuff);
end

function Account:AccountLimitSaveBuff()
	local tbBuff = self:GetAccountLimitBuff();
	SetGblIntBuf(GBLINTBUF_ACC_LIMIT, 0, 1, tbBuff);
end

GCEvent:RegisterGCServerShutDownFunc(Account.AccountLimitSaveBuff, Account);
