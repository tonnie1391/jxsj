-------------------------------------------------------------------
--File: account_head.lua
--Author: lbh
--Date: 2008-6-27 17:03
--Describe: 账号相关
-------------------------------------------------------------------
-- c2s枚举定义
Account.SET_PSW = 1;
Account.LOCKACC = 2;
Account.UNLOCK = 3;
Account.IS_APPLYING_JIESUO = 4; -- 是否在申请自助解锁
Account.JIESUO_APPLY = 5;
Account.JIESUO_CANCEL = 6;
Account.UNLOCK_BYPASSPOD = 7;
Account.UNLOCK_PHONELOCK = 8;

Account.PASSPODMODE_ZPTOKEN  = 1; --金山令牌
Account.PASSPODMODE_ZPMATRIX = 2;  --矩阵卡
Account.PASSPODMODE_KSPHONELOCK = 3;  --金山手机令牌
Account.PASSPODMODE_TW_PHONELOCK = 255;  --台湾手机锁

Account.SZ_CARD_JIESUO_URL = "http://ecard.xoyo.com/";
Account.SZ_LINGPAI_JIESUO_URL = "http://ekey.xoyo.com/";

Account.nAccount2LockDef_Tsk_Group = 2198;	--任务组
Account.tbAccount2LockDef_Tsk_Id = {
	--类型Id={任务变量}
	[1] = {1},	--玩家之间交易功能
	[2] = {2},	--拍卖行功能 1
	[3] = {3},	--金币交易所功能 1
	[4] = {4},	--奇珍阁功能 1
	[5] = {5},	--邮件功能
	[6] = {6},	--解绑功能（宝石解绑，同伴功能和同伴装备功能，真元功能）
	[7] = {7},	--冶炼大师强化相关功能（远程合玄可用） 1
	[8] = {8}, 	--充值促销功能 1
}

Account.FAILED_RESULT = 
{
	[5001] = "系统错误",
	[5002] = "动态密码已使用",
	[5003] = "令牌验证失败，请重新输入动态密码。",
	[5004] = "令牌过期",
	[5005] = "令牌绑定未找到",
	[5006] = "令牌已经禁用（挂失）",
	[5007] = "密保卡验证失败，请重新输入指定位置的数字密码。",
	[5008] = "密保卡已失效（密保卡使用期限已到），请更换一张新的密保卡。",
	[5009] = "密保卡未找到",
}

Account.PHONE_UNLOCK_RESULT = 
{
	[0] = "<color=red>超過驗證等待時間，請撥打通訊鎖號碼以進行認證。<color>\n 台灣解鎖號碼：0800-771-778\n 香港解鎖號碼：3717-1615",
	--[1] = "<color=green>驗證成功<color>",
	[2] = "<color=red>此帳號已有其他玩家登入，若非您本人使用，請勿撥打通訊鎖並盡快至GF官網修改密碼。<color>",
	[3] = "<color=red>此帳號所綁定的電話號碼同時有其他相關帳號在等候開通，若非您本人使用請盡快至GF官網修改相關帳號之密碼。<color>",
}

Account.tbAccountValue_int = {};
Account.tbAccountValue_bin = {};
Account.tbLimitUseType = {
	[0] = "取消资格",
	[1] = "正在使用",
	[2] = "角色转移",
}
Account.tbNameAccountList = {};

function Account:Init()
	local tbData = Lib:LoadTabFile("\\setting\\player\\accountvalue.txt", { Id = 1 });
	for _, tbRow in ipairs(tbData) do
		local tb = self["tbAccountValue_" .. tbRow.Type];
		tb[tbRow.Key] = tbRow.Id;
	end
end

function Account:GetIntValue(szAccount, szKey)
	local nId = self.tbAccountValue_int[szKey];
	assert(nId, "invalid key: " .. szKey);
	local bOk, nValue = GetAccountIntegerDataCache(szAccount, nId);
	if (bOk ~= 1) then
		nValue = 0;
	end
	return nValue;
end

function Account:GetBinValue(szAccount, szKey)
	local nId = self.tbAccountValue_bin[szKey];
	assert(nId, "invalid key: " .. szKey);
	local bOk, szValue = GetAccountBinaryDataCache(szAccount, nId);
	if (bOk ~= 1) then
		szValue = "";
	end
	return szValue;
end

--szAccount, szKey, nValue, bAppend
--账号,key值，更改的值，操作方式（0为设置值，1为累加值）
function Account:ApplySetIntValue(szAccount, szKey, nValue, bAppend)
	local nId = self.tbAccountValue_int[szKey];
	assert(nId, "invalid key: " .. szKey);
	if (GetAccountIntegerDataCache(szAccount, nId) ~= 1) then	-- 不存在此变量
		RequestAccountIntegerDataUpdating(szAccount, nId, 3, nValue);
	elseif (bAppend == 1) then
		RequestAccountIntegerDataUpdating(szAccount, nId, 1, nValue);
	else
		RequestAccountIntegerDataUpdating(szAccount, nId, 2, nValue);
	end
end

function Account:ApplySetBinValue(szAccount, szKey, szValue)
	local nId = self.tbAccountValue_bin[szKey];
	assert(nId, "invalid key: " .. szKey);
	if (GetAccountBinaryDataCache(szAccount, nId) ~= 1) then	-- 不存在此变量
		RequestAccountBinaryDataUpdating(szAccount, nId, 3, szValue);
	else
		RequestAccountBinaryDataUpdating(szAccount, nId, 2, szValue);
	end
end

function Account:GetAccountLimitBuff()
	
	if not self.tbAccountLimitBuff then
		self.tbAccountLimitBuff = GetGblIntBuf(GBLINTBUF_ACC_LIMIT, 0) or {};
	end
	self.tbNameAccountList  = self.tbNameAccountList or {};
	return self.tbAccountLimitBuff;
end

Account:Init();
