-------------------------------------------------------------------
--File: jbreturn.lua
--Author: luobaohang
--Date: 2008-9-24 22:51:59
--Describe: 金币消耗返还脚本
--Modify by zhangjinpin@kingsoft
-------------------------------------------------------------------

-- 是否开启新优惠标记
jbreturn.USE_ACCOUNT_DATA = 1;

-- 固定10倍优惠
jbreturn.REBATE_RATE = 10;

-- 支持重载，方便内网测试
jbreturn.tbPermitIp = jbreturn.tbPermitIp or {
	["219.131.196.66"] = 1,
	["219.141.176.227"] = 1,
	["219.141.176.228"] = 1,
	["219.141.176.229"] = 1,
	["219.141.176.232"] = 1,
	["114.255.44.131"] = 1,
	["114.255.44.132"] = 1,
	["114.255.44.133"] = 1,	
	["114.255.44.136"] = 1,	
	["222.35.61.94"] = 1,
	["221.237.177.90"] = 1,
	["221.237.177.91"] = 1,
	["221.237.177.92"] = 1,
	["221.237.177.93"] = 1,
	["221.237.177.94"] = 1,
	["221.237.177.95"] = 1,
	["218.24.136.208"] = 1,
	["113.106.106.2"] = 1,
	["113.106.106.98"] = 1,
	["113.106.106.99"] = 1,
	["221.4.212.138"] = 1,
	["221.4.212.139"] = 1,
	["103.106.106.2"] = 1,
	["218.24.136.210"] = 1,
	["218.24.136.211"] = 1,
	["218.24.136.212"] = 1,
	["60.251.48.106"]	= 1,
	["59.124.243.115"]	= 1,
	["221.133.32.154"]	= 1,
	["221.133.32.155"]	= 1,
	["221.10.5.90"] = 1,
};

jbreturn.tbDisableAccount = {
	["115150291"] = 1,
	["13810438118"] = 1,
	["139808086@qq.com"] = 1,
	["15315008"] = 1,
	["15989796681"] = 1,
	["252750904@qq.com"] = 1,
	["271827548"] = 1,
	["438024295@qq.com"] = 1,
	["771807118@qq.com"] = 1,
	["82799135"] = 1,
	["99305422@qq.com"] = 1,
	["adsadfhy"] = 1,
	["alittleduck1"] = 1,
	["angelbabybabys"] = 1,
	["anita840122@163.com"] = 1,
	["annipoint"] = 1,
	["aolingbeilei2"] = 1,
	["better245"] = 1,
	["cc77ee2"] = 1,
	["cdzhao08@qq.com"] = 1,
	["chengdummpingping"] = 1,
	["coldmooncake"] = 1,
	["fanbobo.coo"] = 1,
	["fishbabay80"] = 1,
	["fm3651"] = 1,
	["frank.zhan"] = 1,
	["guaimaoer1010"] = 1,
	["hualuofeng"] = 1,
	["hw115150291"] = 1,
	["jiugongzhu1108"] = 1,
	["kodomo@tom.com"] = 1,
	["kok99999"] = 1,
	["lakerxu01"] = 1,
	["liuwei2@kingsoft.com"] = 1,
	["lltong"] = 1,
	["lpj120560928"] = 1,
	["lzpyj"] = 1,
	["maqingping_02"] = 1,
	["milanello1891"] = 1,
	["mlzjp@love"] = 1,
	["nonary_zx"] = 1,
	["nxd19780102"] = 1,
	["pingguo0808"] = 1,
	["qiuqiu948344"] = 1,
	["queen2012"] = 1,
	["quish_zlj"] = 1,
	["roger245"] = 1,
	["roger246"] = 1,
	["shangshi001"] = 1,
	["shenfengliang"] = 1,
	["sijin1981"] = 1,
	["standhook"] = 1,
	["sunx74"] = 1,
	["veinxu"] = 1,
	["wflx01"] = 1,
	["win_main"] = 1,
	["wow32167"] = 1,
	["woxhcfbm"] = 1,
	["wsh1106"] = 1,
	["wuhan758790"] = 1,
	["wuxiaoting2000"] = 1,
	["wuying52"] = 1,
	["wyllllll"] = 1,
	["xiaosese2010"] = 1,
	["yizhili11"] = 1,
	["yks.lucky"] = 1,
	["yuanlei14"] = 1,
	["yyljfgood"] = 1,
	["z3646658"] = 1,
	["zhaojihua_jxsj"] = 1,
	["zhaomojun"] = 1,
	["zhaoyustar"] = 1,
	["zhong_chi"] = 1,
	["zhouest"] = 1,
};

-- 额度档次
jbreturn.tbMonLimit	= {
	[0]	= 0,
	[1]	= 100,
	[2]	= 300,
	[3]	= 500,
	[4]	= 1000,
	[5]	= 2000,
	[6]	= 5000,
	[9]	= math.huge,
};

-- 权限对话
jbreturn.tbSpecial = 
{
	{0, "兑换为绑定银两", "SelectReturnType", 1},
	{0, "兑换为绑定金币", "SelectReturnType", 2},
	{0, "开启内部道具商店", "OpenSpecShop"},
	{0, "绑金购买限额度道具", "BuyLimitItem"},
	{0, "绑金购买特殊道具", "BuySpecailRepute"},
	{0, "绑金购买内部真元", "BuyZhenyuan"},
	{0, "兑换内部同伴装备", "BuyPartnerEquip"},
	{0, "兑换内部龙魂声望", "BuyLonghunRepute"},
	{0, "兑换内部秦陵声望", "BuyQinlingRepute"},
	{0, "打开内部仓库", "OpenSpecRepository"},
	{0, "内部密友返还", "BuySpecFriend"},
	{0, "内部相关设置", "SpecReturnSet"},
	{2, "绑金购买帮会银锭", "BuyTongFund"},
	{0, "内部返还积分规则", "ReturnHelp"};
	{0, "我要提升额度！", "LimitLevelUp"},
};

-- 银锭道具
jbreturn.tbRefundItem = 
{
	{
		szName	= "银锭",
		tbLevel	= 
		{
			{349, 500},
			{350, 5000},
		},
	}, 
	{
		szName	= "金锭",
		tbLevel	= 
		{
			{351, 500},
			{352, 5000},
		},
	},
};

-- 允许绑金购买的奇珍阁道具
jbreturn.tbSpecialItem	= 
{
	-- 权限等级，商品ID，商品名称
	{0, 86,	"百步穿杨弓"},
	{0, 91, "百步穿杨弓（50倍）"},
	{0, 87, "秦陵·摸金符"},
	{0, 92, "秦陵·摸金符（50倍）"},
}

jbreturn.BINDBANK_MAIN			= 2085;		-- 绑定银行主任务变量
jbreturn.BINDBANK_BINDMONEY		= 9;		-- 绑定银行子变量，绑银
jbreturn.BINDBANK_BINDCOIN		= 10;		-- 绑定银行子变更，绑金

-- 获取优惠级别
function jbreturn:GetRetLevel(pPlayer)
	
	--if (self.USE_ACCOUNT_DATA == 1) then
	local nRebateValue = Account:GetIntValue(pPlayer.szAccount, "jbreturn.nRebateValue");
	--else
	--	nRebateValue = pPlayer.nRebateMultiple;
	--end

	local nLimitLevel	= math.mod(nRebateValue, 10);
	local nSpecial	= math.floor(nRebateValue / 10);
	return nLimitLevel, nSpecial, self.tbMonLimit[nLimitLevel] or 0;
end

-- 设定优惠级别
function jbreturn:SetRetLevel(pPlayer, nLimitLevel, nSpecial)
	local nRebateValue = nLimitLevel + (nSpecial or 0) * 10;
	--local nOldValue	= pPlayer.nRebateMultiple;
	--if (nRebateValue > nOldValue) then
	--	pPlayer.AddExtPoint(7, (nRebateValue - nOldValue) * 10000);
	--else
	--	pPlayer.PayExtPoint(7, (nOldValue - nRebateValue) * 10000);
	--end
	Account:ApplySetIntValue(pPlayer.szAccount, "jbreturn.nRebateValue", nRebateValue);
end

-- 计算n月的优惠使用最大、最小值
function jbreturn:CheckConsume(pPlayer, nCheckMon, nCheckCount)
	local tbConsume, nLastMonth = self:GetConsume(pPlayer);
	local nMax = 0;
	local nMin = math.huge;
	local tbConsumeChecked = {};
	while (nCheckCount > 0) do
		local nMon = math.mod(nCheckMon, 100);
		if (nMon == 0) then	-- 跨年
			nMon = 12;
			nCheckMon = nCheckMon - 100 + 12;
		end
		local nConsume = tbConsume[nMon];
		if (nCheckMon > nLastMonth) then	-- 尚未消耗
			nConsume = 0;
		elseif (nCheckMon <= nLastMonth - 100 or not nConsume) then	-- 超出1年或没有消耗记录
			return nil, nil, tbConsumeChecked;
		end
		table.insert(tbConsumeChecked, 1, {nCheckMon, nConsume});
		if (nConsume > nMax) then
			nMax = nConsume;
		end
		if (nConsume < nMin) then
			nMin = nConsume;
		end
		nCheckMon = nCheckMon - 1;
		nCheckCount = nCheckCount - 1;
	end
	return nMax, nMin, tbConsumeChecked;
end

-- 检查优惠状态
function jbreturn:CheckState()
	if (self.USE_ACCOUNT_DATA ~= 1) then
		return 1;
	end
	
	local nRebateValue = Account:GetIntValue(me.szAccount, "jbreturn.nRebateValue");
	local nOldValue = me.nRebateMultiple;

	if (nRebateValue <= 0 and nOldValue <= 0) then	-- 无优惠
		return 1;
	end
	
	-- 需要转账号数据
	if (nRebateValue < nOldValue) then
		Account:ApplySetIntValue(me.szAccount, "jbreturn.nRebateValue", nOldValue);
		self:OnConsume(me, 0);	-- 更新消耗值
		if (self.USE_ACCOUNT_DATA == 1) then
			return 0, "优惠标记存储方式变更，请重新对话。";
		else
			return 1;
		end
	end
	
	local nCurMon = tonumber(GetLocalDate("%Y%m"));
	local tbConsume, nLastMonth = self:GetConsume(me);
	if (nCurMon == nLastMonth) then	-- 没跨月，无需检查
		return 1;
	end
	
	-- 检查近3月充值
	local nMaxConsume, nMinConsume = self:CheckConsume(me, nCurMon - 1, 3);
	if (not nMaxConsume) then	-- 记录不足3月
		return 1;
	end
	
	--if (nMaxConsume <= 0) then	-- 一直未用
	--	Account:ApplySetIntValue(me.szAccount, "jbreturn.nRebateValue", 0);
	--	return 0, "您的内部优惠资格因长期未用而取消。";
	--end
	
	local nLimitLevel, nSpecial, nMonLimit = self:GetRetLevel(me);
	
	--保持最低额度内部号资格。
	if nLimitLevel <= 1 then
		return 1;
	end
	
	local nLowMonLimit = self.tbMonLimit[nLimitLevel - 1] or 0;
	if (nMaxConsume < nLowMonLimit * 100) then	-- 低于更低等级
		self:SetRetLevel(me, nLimitLevel - 1, nSpecial);
		local szMsg = string.format("您的内部优惠额度因长期使用不足而降级（原：%d￥/月，现：%d￥/月）。", nMonLimit, nLowMonLimit);
		return 0, szMsg;
	end
	
	return 1;
end

-- 获取消耗记录
function jbreturn:GetConsume(pPlayer)
	-- 这里缓存一下，避免写入后立即读取出错
	local tbTemp = self:GetPlayerTempTable(pPlayer);
	if (not tbTemp.tbConsume) then
		tbTemp.nLastMonth = Account:GetIntValue(pPlayer.szAccount, "jbreturn.nCurMon");
		local szBuffer = Account:GetBinValue(pPlayer.szAccount, "jbreturn.tbMonUse");
		if (tbTemp.nLastMonth > 0) then
			tbTemp.tbConsume = KLib.LoadBuffer2Value(szBuffer or "") or {};
		else
			local nConsumedValue = pPlayer.GetTask(2034, 4);
			local nConsumedMon = pPlayer.GetTask(2034, 3) + 1;
			tbTemp.nLastMonth = tonumber(GetLocalDate("%Y%m"));
			local nCurMon = math.mod(tbTemp.nLastMonth, 100);
			if (nCurMon ~= nConsumedMon) then
				nConsumedValue = 0;
			end
			tbTemp.tbConsume = { [nCurMon] = nConsumedValue };
		end
	end
	return tbTemp.tbConsume, tbTemp.nLastMonth;
end

-- 获取当月消耗
function jbreturn:GetCurConsume(pPlayer)
	if (self.USE_ACCOUNT_DATA == 1) then
		local tbConsume, nLastMonth = self:GetConsume(pPlayer);
		local nCurMonth = tonumber(GetLocalDate("%Y%m"));
		if (nCurMonth == nLastMonth) then
			return tbConsume[math.mod(nLastMonth, 100)] or 0;
		end
	end
	
	return pPlayer.nConsumedValue;
end

-- 当消耗额度时
function jbreturn:OnConsume(pPlayer, nPrice)
	pPlayer.ApplyConsumeRebateCredit(nPrice);
	
	-- 追加消耗记录
	local tbConsume, nLastMonth = self:GetConsume(pPlayer);
	local nCurMonth = tonumber(GetLocalDate("%Y%m"));
	if (nLastMonth < nCurMonth - 100) then
		nLastMonth = nCurMonth - 100;
	end
	while (nLastMonth < nCurMonth) do
		nLastMonth = nLastMonth + 1;
		local nLastMon = math.mod(nLastMonth, 100);
		if (nLastMon > 12) then
			nLastMon = 1;
			nLastMonth = nLastMonth - 12 + 100;
		end
		print("~~~", nLastMonth, nLastMon, tbConsume[nLastMon])
		tbConsume[nLastMon] = nil;
	end
	local nCurMon = math.mod(nCurMonth, 100);
	local nConsumedValue = pPlayer.GetTask(2034, 4);	-- 转换期间，可能原记录方式数值更高
	tbConsume[nCurMon] = math.max((tbConsume[nCurMon] or 0) + nPrice, nConsumedValue);
	local tbTemp = self:GetPlayerTempTable(pPlayer);
	tbTemp.nLastMonth = nCurMonth;
	Account:ApplySetBinValue(pPlayer.szAccount, "jbreturn.tbMonUse", KLib.SaveValue2Buffer(tbConsume));
	Account:ApplySetIntValue(pPlayer.szAccount, "jbreturn.nCurMon", nCurMonth);
end

-- 是否是允许IP
function jbreturn:IsPermitIp(pPlayer)
	local szIp	= pPlayer.GetPlayerIpAddress();
	local nPos	= string.find(szIp, ":");
	if (nPos) then
		szIp	= string.sub(szIp, 1, nPos - 1);
	end
	return self.tbPermitIp[szIp] or 0;
end

-- 测试用激活内部优惠
function jbreturn:ActiveAccount(nMonLimit, nSpecial, szCurName)
	nMonLimit	= nMonLimit or 2;
	nSpecial	= nSpecial or 0;
	self:SetRetLevel(me, nMonLimit, nSpecial);
	me.Msg(string.format("激活内部优惠(%d,%d)！", nMonLimit, nSpecial));
	
	local nMonthLimit = self.tbMonLimit[nMonLimit]
	if nMonLimit <= 0 then
		self:DelSpecItem(me);
		GCExcute({"Account:DelAccountLimit", me.szName, me.szAccount, nMonLimit, nSpecial, nMonthLimit, me.nMonCharge, me.GetHonorLevel()});
	else
		local szCurIp = Lib:IntIpToStrIp(me.GetTask(2063, 1)) or "0.0.0.0";
		local szCurArea = GetIpAreaAddr(me.GetTask(2063, 1)) or "未知区域";
		GCExcute({"Account:LogLimitAccount", me.szName, me.szAccount, nMonLimit, nSpecial, nMonthLimit, me.nMonCharge, me.GetHonorLevel(), szCurIp , szCurArea});
		if szCurName and szCurName ~= "" and szCurName ~= "未设置" then
			GCExcute({"Account:SetLimitAccountCurName", me.szAccount, szCurName});
		end
	end
end

-- 获取每月兑换额度
function jbreturn:GetMonLimit(pPlayer)
	local nLimitLevel, nSpecial, nMonthLimit = self:GetRetLevel(pPlayer);
	return nMonthLimit;
end

-- 获取特殊权限对话（未做激活处理）
function jbreturn:GetSpecialOption(pPlayer)
	local nLimitLevel, nSpecial, nMonthLimit = self:GetRetLevel(pPlayer);
	local tbOption	= {};
	for _, tb in ipairs(self.tbSpecial) do
		if (nSpecial >= tb[1]) then
			tbOption[#tbOption + 1]	= {tb[2], self[tb[3]], self, unpack(tb, 4)};
		end
	end
	-- 美术同学特别通道
	local nWeek = Lib:GetLocalWeek();
	if pPlayer.GetTask(2056, 16) >= nWeek then
		table.insert(tbOption, 1, {"美术特别优惠", self.GetFreeReward, self});
	end
	return tbOption;
end

function jbreturn:GainBindCoin()
	if (self:IsPermitIp(me) ~= 1) then
		return 0;
	end
	
	local bOk, szMsg = self:CheckState();
	if (bOk ~= 1) then
		Dialog:Say(szMsg);
		return 1;
	end
	
	local nMonLimit	= self:GetMonLimit(me);
	if (nMonLimit <= 0) then
		return 0;
	end
	
	local nConsumedValue	= self:GetCurConsume(me);
	local nMonCharge		= me.nMonCharge;
	local nRefundAvailable	= math.min(nMonLimit, nMonCharge) * 100 - nConsumedValue;
	if (nRefundAvailable < 0) then
		nRefundAvailable	= 0;
	end
	local tbOption	= self:GetSpecialOption(me);
	local tbNpc	= Npc:GetClass("renji");
	tbOption[#tbOption + 1]	= {"领取密友返还的绑定金币", tbNpc.GetIbBindCoin, tbNpc};
	tbOption[#tbOption + 1]	= {"<color=gray>关闭"};
	
	local szMsgFmt	= [[
<color=red>您的帐号是内部流通帐号<color>
您每月可以使用金币换取<color=yellow>%s<color>金币的绑定金币或绑定银两，<color=yellow>换取后金币将被扣除<color>。
本月充值<color=yellow>%d<color>金币。
已兑换过<color=yellow>%d<color>金币。
还可兑换<color=yellow>%d<color>金币。

请选择您希望兑换的类型：]];
	
	Dialog:Say(string.format(szMsgFmt, (nMonLimit == math.huge and "无限") or nMonLimit * 100,
		nMonCharge * 100, nConsumedValue, nRefundAvailable), tbOption);
	
	return 1;
end

jbreturn.tbFreeReward = {bindcoin = 50000, bindmoney = 500000};

-- 激活免费领取，有效期26周
function jbreturn:ActiveFreeReward()
	local nWeek = Lib:GetLocalWeek();
	me.SetTask(2056, 16, nWeek + 25);
end

function jbreturn:GetFreeReward()
	local nWeek = Lib:GetLocalWeek();
	if me.GetTask(2056, 16) < nWeek then
		Dialog:Say("对不起，该角色没有权利领取该优惠。");
		return;
	end
	if me.GetTask(2056, 17) >= nWeek then
		Dialog:Say(string.format("无法领取，每个角色每周只能领取一次。\n角色至激活后<color=yellow>26周以内<color>可以领取该优惠，当前该角色还可以领取<color=yellow>%s周<color>。", me.GetTask(2056, 16) - nWeek));
		return;
	end
	if self.tbFreeReward.bindmoney + me.GetBindMoney() > me.GetMaxCarryMoney() then
		Dialog:Say(string.format("您的绑定银两将超出<color=yellow>%s两<color>的上限，请用掉一部分再来！<pic=26>", me.GetMaxCarryMoney()));
		return;
	end
	me.SetTask(2056, 17, nWeek);
	me.AddBindCoin(self.tbFreeReward.bindcoin, Player.emKBINDCOIN_ADD_VIP_REBACK);
	me.AddBindMoney(self.tbFreeReward.bindmoney, Player.emKBINDMONEY_ADD_VIP_TRANSFER);
	Dialog:Say(string.format("你本周成功领取了<color=yellow>5万绑金和50万绑银<color>的优惠。\n角色至激活后<color=yellow>26周以内<color>可以领取该优惠，当前该角色还可以领取<color=yellow>%s周<color>。", me.GetTask(2056, 16) - nWeek));
end

-- nType 1:绑银，2：绑金 nLevel:等级(大/小) nCount个数
function jbreturn:_GetRefundOption(nType, nLevel, nCount)
	local nRate		= self:GetRebateRate(nType);
	local tbItem	= self.tbRefundItem[nType].tbLevel[nLevel];
	-- 将500金币兑换成
	local szMsg = string.format("将%d金币兑换成%s%s", tbItem[2] * nCount, tbItem[2] * nRate * nCount, self.tbRefundItem[nType].szName);
	return {szMsg, self.PrepareRefund, self, nType, nLevel, nCount};
end

function jbreturn:SelectReturnType(nType)
	Dialog:Say("请选择兑换额度：", {
		self:_GetRefundOption(nType, 1, 1),
		self:_GetRefundOption(nType, 1, 2),
		self:_GetRefundOption(nType, 1, 4),
		self:_GetRefundOption(nType, 2, 1),
		self:_GetRefundOption(nType, 2, 2),
		self:_GetRefundOption(nType, 2, 4),
		self:_GetRefundOption(nType, 2, 10),
		{"<color=gray>关闭"}
	});
end

function jbreturn:PrepareRefund(nType, nLevel, nCount)
	if (me.IsInPrison() == 1) then
		me.Msg("天牢里不能兑换。");
		return 0;
	end	
	
	local tbItem	= self.tbRefundItem[nType].tbLevel[nLevel];
	local nConsume	= self:GetCurConsume(me) + tbItem[2] * nCount;

	if (nConsume > self:GetMonLimit(me) * 100) then
		me.Msg("您的每月兑换额度不足以完成兑换，请下个月再来。<pic=20>");
		return 0;
	end
	if (nConsume > me.nMonCharge * 100) then
		me.Msg("您本月充值额度不足以兑换，想要继续兑换，请充值。<pic=20>");
		return 0;
	end
	if (nType == 1	-- 换绑银需要检查携带上限
		and tbItem[2] * self:GetRebateRate(nType) * nCount + me.GetBindMoney() > me.GetMaxCarryMoney()) then
		Dialog:Say(string.format("您的绑定银两将超出<color=yellow>%s两<color>的上限，请用掉一部分再来！<pic=26>", me.GetMaxCarryMoney()));
		return 0;
	end
	me.ApplyAutoBuyAndUse(tbItem[1], nCount);
	return 1;
end

function jbreturn:ReturnHelp()
	Dialog:Say(
		string.format("在充值当月，您可以按一定比例将金币兑换为绑定金币或绑定银两。兑换比例是您的返还倍数(<color=yellow>%d倍<color>)，金币兑换总量不能超过当月充值的金币数量。\n\n此功能仅限公司内部帐号，并且只有从公司IP登录游戏才可看到。", self.REBATE_RATE),
		{
			{ "返回上一页", self.GainBindCoin, self },
			{ "Kết thúc đối thoại" }
		}
	);
end

function jbreturn:BuyTongFund()
	Dialog:Say("请选择购买的帮会银锭种类:",
		{
			{"帮会银锭（小）", self.ExcuteBuyTongFund, self, 1},
			{"帮会银锭（大）", self.ExcuteBuyTongFund, self, 2},
			{"取消"}
		}
	);
end

jbreturn.tbTongSyceeCost = { [1] = 1000, [2] = 10000 }
jbreturn.tbBindItemInfo =
{
		nil,		--	五行，默认无
		nil,		--	强化次数，默认0
		nil,		--	幸运
		nil,						
		nil, 		--	装备随机品质
		nil,					
		nil,		--	随机种子
		1,			--	强制绑定默认0
		nil,		--	是否会超时
 		nil,		--	是否消息通知
};

function jbreturn:ExcuteBuyTongFund(nType)
	local nCost = self.tbTongSyceeCost[nType];
	if not nCost or nCost <= 0 then
		return;
	end
	if me.AddBindCoin(-nCost, Player.emKBINDCOIN_COST_JBRETURN) == 1 then
		local pItem = me.AddItemEx(18, 1, 284, nType, self.tbBindItemInfo);
		if pItem then
			pItem.SetTimeOut(0, GetTime()+ 30*24*3600 );
			pItem.Sync();
		end
	else
		Dialog:Say("您的绑定金币不足！");
	end
end

-- 获得汇率
function jbreturn:GetRebateRate(nType)
	local nRate	= self.REBATE_RATE;
	if (nType == 1) then
		local nJbPrice = JbExchange.GetPrvAvgPrice;
		nRate = nRate * math.max(100, nJbPrice);
	end
	return nRate;
end

-- 绑金购买奇珍阁道具
function jbreturn:BuyItem_List()
	local tbOption	= {};
	local nLimitLevel, nSpecial, nMonthLimit = self:GetRetLevel(me);
	local emKIBSHOP_CURRENCY_COIN	= 0;
	for _, tb in ipairs(self.tbSpecialItem) do
		if (nSpecial >= tb[1]) then
			local nWareId	= tb[2];
			local szName	= tb[3];
			local tbInfo	= me.IbShop_GetWareInf(nWareId);
			if (tbInfo and tbInfo.nCurrencyType == emKIBSHOP_CURRENCY_COIN and tbInfo.bIsOnSale == 1) then
				tbOption[#tbOption + 1]	= {szName, self.BuyItem_Input, self, nWareId};
			else
				tbOption[#tbOption + 1]	= {string.format("<color=gray>%s（未开放）", szName), self.BuyItem_List, self};
			end
		end
	end
	tbOption[#tbOption + 1]	= {"<color=gray>关闭"};
	Dialog:Say("请选择您要购买的商品。\n（购买后绑定）", tbOption);
end

function jbreturn:BuyItem_Input(nWareId)
	local tbInfo	= me.IbShop_GetWareInf(nWareId);
	local szName	= KItem.GetNameById(tbInfo.nGenre, tbInfo.nDetailType, tbInfo.nParticular, tbInfo.nLevel);
	local nFreeCell	= me.CalcFreeItemCountInBags(tbInfo.nGenre, tbInfo.nDetailType, tbInfo.nParticular, tbInfo.nLevel, tbInfo.nSeries, 1);
	if (nFreeCell <= 0) then
		me.Msg("请留出一定背包空间！");
		return;
	end
	Dialog:AskNumber("请输入购买数量：", nFreeCell, self.BuyItem_Show, self, nWareId)
end

function jbreturn:BuyItem_Show(nWareId, nCount)
	if (nCount <= 0) then
		return;
	end
	local tbInfo	= me.IbShop_GetWareInf(nWareId);
	local szName	= KItem.GetNameById(tbInfo.nGenre, tbInfo.nDetailType, tbInfo.nParticular, tbInfo.nLevel);
	local nPrice	= tbInfo.nOrgPrice * nCount;
	local szMsg	= string.format([[
商品名称：<color=yellow>%s<color>
购买数量：<color=yellow>%d<color>
消耗绑金：<color=yellow>%s<color>

是否确认购买？]], szName, nCount, nPrice);
	Dialog:Say(szMsg, {{"Xác nhận", self.BuyItem_Sure, self, nWareId, nCount}, {"<color=gray>取消"}});
end

function jbreturn:BuyItem_Sure(nWareId, nCount)
	local tbInfo	= me.IbShop_GetWareInf(nWareId);
	local nPrice	= tbInfo.nOrgPrice * nCount;
	local nFreeCell	= me.CalcFreeItemCountInBags(tbInfo.nGenre, tbInfo.nDetailType, tbInfo.nParticular, tbInfo.nLevel, tbInfo.nSeries, 1);
	if (me.nBindCoin < nPrice) then
		me.Msg("您的绑定金币不足！");
		return;
	elseif (nFreeCell < nCount) then
		me.Msg("Hành trang không đủ ！");
		return;
	end
	
	me.AddBindCoin(-nPrice, Player.emKBINDCOIN_COST_JBRETURN);
	me.AddStackItem(tbInfo.nGenre, tbInfo.nDetailType, tbInfo.nParticular, tbInfo.nLevel, {nSeries = tbInfo.nSeries, bForceBind = 1}, nCount);
end

-------------------------------------------------------
-- 内部返还充值额度
-------------------------------------------------------
function jbreturn:GetMonthPay(nMonth, nPay)
	if not self.tbMonthPay then
		local tbMonthPay = {};
		local tbTabFile = Lib:LoadTabFile("\\setting\\misc\\monthpay.txt");
		for _, tbRow in pairs(tbTabFile or {}) do
			local nMonth = tonumber(tbRow.Month);
			if not tbMonthPay[nMonth] then
				tbMonthPay[nMonth] = {};
			end
			for szKey, szValue in pairs(tbRow) do
				local nFind = string.find(szKey, "Pay");
				if nFind then
					local nKey = tonumber(string.sub(szKey, nFind + 3, -1));
					local nValue = tonumber(szValue);
					table.insert(tbMonthPay[nMonth], {Real = nValue, Result = nKey});
				end
			end
			table.sort(tbMonthPay[nMonth], function(a, b) return a.Real > b.Real end);
		end
		self.tbMonthPay = tbMonthPay;
	end
	if not self.tbMonthPay[nMonth] then
		local tbPrePay = 
		{
			[1] = {Real = 2000, Result = 5000},
			[2] = {Real = 800, Result = 2000},
			[3] = {Real = 400, Result = 1000},
			[4] = {Real = 250, Result = 600},
			[5] = {Real = 150, Result = 200},
			[6] = {Real = 50, Result = 50},
		};
		for _, tbRow in ipairs(tbPrePay) do
			if nPay >= tbRow.Real then
				return (nPay >= tbRow.Result) and nPay or tbRow.Result;
			end
		end
		return nPay;
	end
	for _, tbRow in ipairs(self.tbMonthPay[nMonth]) do
		if nPay >= tbRow.Real then
			return (nPay >= tbRow.Result) and nPay or tbRow.Result;
		end
	end
	return nPay;
end

-------------------------------------------------------
-- 限额度道具
-------------------------------------------------------

-- 限额度道具列表
jbreturn.tbLimitItemList =
{
	[1] = 
	{
		szName = "游龙古币",
		nLimit = 3,
		nPrice = 30,
		tbRepute = nil,
		tbItemId = {18, 1, 553, 1},
		tbTaskId = {2056, 3},
		nDayLimit = 90,
		nHonor = 0,
		tbHonorLimit = {[8] = 3000, [9] = 6000, [10] = 10000},
	},
--	[2] =
--	{
--		szName = "和氏璧声望",
--		nLimit = 1,
--		nPrice = 6000,
--		tbRepute = {9, 2, 100},
--		tbItemId = nil,
--		tbTaskId = {2056, 5},
--		nDayLimit = 90,
--		nHonor = 0,
--		tbHonorLimit = {[8] = 2000, [9] = 2000, [10] = 2000},
--	},
	[2] =
	{
		szName = "游龙战书",
		nLimit = 4,
		nPrice = 150,
		tbRepute = nil,
		tbItemId = {18, 1, 524, 4},
		tbTaskId = {2056, 8},
		nDayLimit = 90,
		nHonor = 0,
		tbHonorLimit = {[8] = 6000, [9] = 8000, [10] = 10000},
	},
	[3] =
	{
		szName = "秘境地图",
		nLimit = 0.01,
		nPrice = 1200,
		tbRepute = nil,
		tbItemId = {18, 1, 251, 1},
		tbTaskId = {2056, 9},
		nDayLimit = 0,
		nHonor = 0,
		tbHonorLimit = {[8] = 20, [9] = 30, [10] = 30},
	},
--	[5] =
--	{
--		szName = "玫瑰花",
--		nLimit = 0,
--		nPrice = 100,
--		tbRepute = nil,
--		tbItemId = {18, 1, 373, 2},
--		tbTaskId = {2056, 14},
--		nDayLimit = 0,
--		nHonor = 0,
--		tbHonorLimit = {[3] = 600, [4] = 600, [5] = 1000, [6] = 1500, [7] = 2000, [8] = 2500, [9] = 3000, [10] = 4000},
--	},
	[4] =
	{
		szName = "帮会银锭（大）",
		nLimit = 0,
		nPrice = 10000,
		tbRepute = nil,
		tbItemId = {18, 1, 284, 2},
		tbTaskId = {2056, 15},
		nDayLimit = 0,
		nHonor = 9,
		tbHonorLimit = {[8] = 4, [9] = 4, [10] = 8},
	},
	[5] =
	{
		szName = "龙纹银币",
		nLimit = 0,
		nPrice = 10,
		tbRepute = nil,
		tbItemId = {18, 1, 1672, 1},
		tbTaskId = {2056, 18},
		nDayLimit = 0,
		nHonor = 6,
		tbHonorLimit = {[6] = 1000, [7] = 1000, [8] = 1000, [9] = 1000, [10] = 1000},
	},
};

-- 购买限额度道具
function jbreturn:BuyLimitItem()
	
	local tbOpt = {};
	local szMsg = "大家好，我是金老板！我这里可以购买限额度内部道具。";
	
	local nPlayerHonor = me.GetHonorLevel();
	local nOpenTime = GetTime() - KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	for nIndex, tbInfo in ipairs(self.tbLimitItemList) do
		if nOpenTime >= tbInfo.nDayLimit * 60 * 60 * 24 and nPlayerHonor >= tbInfo.nHonor then
			table.insert(tbOpt, {tbInfo.szName, self.DoBuyLimitItem, self, nIndex});
		end
	end
	
	table.insert(tbOpt, {"<color=gray>返回<color>", self.GainBindCoin, self});
	Dialog:Say(szMsg, tbOpt);
end

function jbreturn:DoBuyLimitItem(nType)
	
	local tbInfo = self.tbLimitItemList[nType];
	if not tbInfo then
		return 0;
	end

	if tbInfo.tbTaskId[2] == 5 and me.GetTask(2056, 13) <= 0 then
		local nValueEx = me.GetReputeValue(9, 2);
		me.AddRepute(9, 2, -1 * nValueEx);
		me.AddBindCoin(nValueEx * 80, Player.emKBINDCOIN_ADD_XISHANJINDING);
		me.SetTask(2056, 13, 1);
		me.Msg("您之前购买的未升级的和氏璧声望已经按旧价格折算为绑金。");
		Dbg:WriteLog("jbreturn", me.szName, string.format("和氏璧声望折算绑金：%s", nValueEx * 80));
	end
		
	local nLimitLevel, nSpecial, nMonthLimit = self:GetRetLevel(me);
	local nChange = me.GetTask(tbInfo.tbTaskId[1], tbInfo.tbTaskId[2]);
	local nPermit = math.max(nMonthLimit * tbInfo.nLimit - nChange, 0);
	nPermit = math.max(nPermit, (tbInfo.tbHonorLimit[me.GetHonorLevel()] or 0) - nChange);
	
	local szMsg = string.format("您本月已经购买了%s<color=yellow>%s<color>个，还能继续购买<color=yellow>%s<color>个%s。",
		tbInfo.szName, nChange, (nMonthLimit == math.huge) and "无限" or nPermit, tbInfo.szName);
	
	local tbOpt = 
	{
		{"我要购买", self.OnBuyLimitItem, self, nType, nPermit},
		{"Để ta suy nghĩ thêm"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function jbreturn:OnBuyLimitItem(nType, nPermit)
	Dialog:AskNumber("Nhập số lượng: ", nPermit, self.OnBuyLimitItem_Show, self, nType);
end

function jbreturn:OnBuyLimitItem_Show(nType, nInput)

	local tbInfo = self.tbLimitItemList[nType];
	if not tbInfo then
		return 0;
	end
	
	local nLimitLevel, nSpecial, nMonthLimit = self:GetRetLevel(me);
	local nChange = me.GetTask(tbInfo.tbTaskId[1], tbInfo.tbTaskId[2]);
	local nPermit = math.max(nMonthLimit * tbInfo.nLimit - nChange, 0);
	nPermit = math.max(nPermit, (tbInfo.tbHonorLimit[me.GetHonorLevel()] or 0) - nChange);
	
	if nInput <= 0 or nInput > nPermit then
		Dialog:Say("请输入正确的数量。");
		return 0;	
	end
	
	local nPrice = tbInfo.nPrice * nInput;
	local szMsg	= string.format([[
商品名称：<color=yellow>%s<color>
购买数量：<color=yellow>%d<color>
消耗绑金：<color=yellow>%s<color>

是否确认购买？]], tbInfo.szName, nInput, nPrice);

	Dialog:Say(szMsg, {{"Xác nhận", self.OnBuyLimitItem_Sure, self, nType, nInput, nPrice}, {"<color=gray>取消"}});
end

function jbreturn:OnBuyLimitItem_Sure(nType, nInput, nPrice)

	local tbInfo = self.tbLimitItemList[nType];
	if not tbInfo then
		return 0;
	end
	
	if me.nBindCoin < nPrice then
		Dialog:Say(string.format("对不起，您的绑金不足<color=green>%s<color>。", nPrice));
		return 0;
	end
	
	if tbInfo.tbRepute then
		local tbRepute = tbInfo.tbRepute;
		local nRet = Player:AddRepute(me, tbRepute[1], tbRepute[2], tbRepute[3] * nInput);
		if nRet == 0 then
			return 0;
		elseif nRet == 1 then
			Dialog:Say(string.format("您的%s已达到最高等级，无法再增加声望。", tbInfo.szName));
			return 0;
		end
		
	elseif tbInfo.tbItemId then
		local tbItemId = tbInfo.tbItemId;
		local nNeed = KItem.GetNeedFreeBag(tbItemId[1], tbItemId[2], tbItemId[3], tbItemId[4], {bForceBind = 1}, nInput);
		if me.CountFreeBagCell() < nNeed then
			Dialog:Say(string.format("请留出%s格背包空间。", nNeed));
			return 0;
		end
		me.AddStackItem(tbItemId[1], tbItemId[2], tbItemId[3], tbItemId[4], {bForceBind = 1}, nInput);
	end

	me.AddBindCoin(-nPrice, Player.emKBINDCOIN_COST_JBRETURN);

	local nChange = me.GetTask(tbInfo.tbTaskId[1], tbInfo.tbTaskId[2]);
	me.SetTask(tbInfo.tbTaskId[1], tbInfo.tbTaskId[2], nChange + nInput);
end

-------------------------------------------------------
-- 特殊道具、声望道具
-------------------------------------------------------

-- 特殊声望道具列表
jbreturn.tbSpecailReputeList = 
{
	[1] = 
	{
		nPrice = 80,
		nMaxCount = 150,
		tbItemId = {18, 1, 200, 1},
		szName = "血影枪",
		nDayLimit = 30,
		nHonor = 0,
	},
	[2] = 
	{
		nPrice = 100,
		nMaxCount = 500,
		tbItemId = {18, 1, 263, 1},
		szName = "百步穿杨弓",
		nDayLimit = 43,
		nHonor = 0,
	},
	[3] = 
	{
		nPrice = 4000,
		nMaxCount = 10,
		tbItemId = {18, 1, 382, 1},
		szName = "夜明珠·箱",
		nDayLimit = 138,
		nHonor = 0,
	},
	[4] = 
	{
		nPrice = 100,
		nMaxCount = 1000,
		tbItemId = {18, 1, 366, 1},
		szName = "秦陵·摸金符",
		nDayLimit = 142,
		nHonor = 0,
	},
	[5] = 
	{
		nPrice = 6000,
		nMaxCount = 50,
		tbItemId = {18, 1, 215, 4},
		szName = "武林联赛黄金令牌",
		nDayLimit = 130,
		nHonor = 0,
	},
	[6] = 
	{
		nPrice = 6000,
		nMaxCount = 50,
		tbItemId = {18, 1, 916, 1},
		szName = "跨服联赛声望白玉",
		nDayLimit = 50,
		nHonor = 7,
	},
	[7] = 
	{
		nPrice = 5000,
		nMaxCount = 60,
		tbItemId = {18, 1, 512, 1},
		szName = "寒武遗迹·雪魂令",
		nDayLimit = 50,
		nHonor = 7,
	},
	[8] = 
	{
		nPrice = 1000,
		nMaxCount = 50,
		tbItemId = {18, 1, 1300, 1},
		szName = "忠魂之石碎片",
		nDayLimit = 70,
		nHonor = 7,
	},
	[9] = 
	{
		nPrice = 240000,
		nMaxCount = 10,
		tbItemId = {18, 1, 741, 1},
		szName = "雷霆印碎片",
		nDayLimit = 90,
		nHonor = 9,
	},
};

-- 绑金购买特殊声望道具
function jbreturn:BuySpecailRepute()
	
	local tbOpt = {};
	local szMsg = "大家好，我是金老板！我这里可以购买特殊声望道具。";
	
	local nOpenTime = GetTime() - KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	local nPlayerHonor = me.GetHonorLevel();
	local nLimitLevel, nSpecial, nMonthLimit = self:GetRetLevel(me);
	for nIndex, tbInfo in ipairs(self.tbSpecailReputeList) do
		if nOpenTime >= tbInfo.nDayLimit * 3600 * 24 and (nSpecial == 9 or nPlayerHonor >= tbInfo.nHonor) then
			table.insert(tbOpt, {tbInfo.szName, self.OnBuySpecailRepute, self, nIndex});
		end
	end
	table.insert(tbOpt, {"<color=gray>返回<color>", self.GainBindCoin, self});
	
	Dialog:Say(szMsg, tbOpt);
end

function jbreturn:OnBuySpecailRepute(nType)
	
	local tbInfo = self.tbSpecailReputeList[nType];
	if not tbInfo then
		return 0;
	end
	
	Dialog:AskNumber("Nhập số lượng: ", tbInfo.nMaxCount, self.OnBuySpecailRepute_Show, self, nType);
end

function jbreturn:OnBuySpecailRepute_Show(nType, nInput)
	
	local tbInfo = self.tbSpecailReputeList[nType];
	if not tbInfo then
		return 0;
	end
	
	if nInput <= 0 or nInput > tbInfo.nMaxCount then
		Dialog:Say("请输入正确的数量。");
		return 0;
	end
	
	local nPrice = tbInfo.nPrice * nInput;
	local szMsg	= string.format([[
商品名称：<color=yellow>%s<color>
购买数量：<color=yellow>%d<color>
消耗绑金：<color=yellow>%s<color>

是否确认购买？]], tbInfo.szName, nInput, nPrice);

	Dialog:Say(szMsg, {{"Xác nhận", self.OnBuySpecailRepute_Sure, self, nType, nInput, nPrice}, {"<color=gray>取消"}});
end

function jbreturn:OnBuySpecailRepute_Sure(nType, nInput, nPrice)
	
	local tbInfo = self.tbSpecailReputeList[nType];
	if not tbInfo then
		return 0;
	end
	
	if me.nBindCoin < nPrice then
		Dialog:Say(string.format("对不起，您的绑金不足<color=green>%s<color>。", nPrice));
		return 0;
	end
	
	local tbItemId = tbInfo.tbItemId;
	local nNeed = KItem.GetNeedFreeBag(tbItemId[1], tbItemId[2], tbItemId[3], tbItemId[4], {bForceBind = 1}, nInput);
	if me.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("请留出%s格背包空间。", nNeed));
		return 0;
	end
	
	me.AddBindCoin(-nPrice, Player.emKBINDCOIN_COST_JBRETURN);
	me.AddStackItem(tbItemId[1], tbItemId[2], tbItemId[3], tbItemId[4], {bForceBind = 1}, nInput);
end

-------------------------------------------------------
-- 内部真元
-------------------------------------------------------

-- 内部真元列表
jbreturn.tbZhenyuanType = 
{
	[1] = {"宝玉", 193},
	[2] = {"夏小倩", 182},
	[3] = {"莺莺", 194},
	[4] = {"木超", 181},
	[5] = {"紫苑", 177},
	[6] = {"秦仲", 178},
	[7] = {"叶静", 246},
};

-- 内部真元限额
jbreturn.tbZhenyuanLimit =
{
	nDayLimit = 5,
	nTotalLimit = 200,
	nPrice = 500,
	tbTaskTotalId = {2056, 6},
	tbTaskGetId = {2056, 7},
	tbTaskFreeId = {2056, 10},
	nStartDay = 96,
};

jbreturn.tbZhenyuanHonor = {[8] = 10, [9] = 15, [10] = 20};

function jbreturn:CheckZhenyuan()
	
	local tbLimit = self.tbZhenyuanLimit;
	local nSpeed = KGblTask.SCGetDbTaskInt(DBTASK_TIMEFRAME_OPEN);
	local nStartDay = (nSpeed == 1) and 10 or tbLimit.nStartDay;
	local nOpenTime = GetTime() - KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	if nOpenTime < nStartDay * 60 * 60 * 24 then
		return 0;
	end
	
	return me.GetTask(tbLimit.tbTaskFreeId[1], tbLimit.tbTaskFreeId[2]);
end

-- 购买内部真元
function jbreturn:BuyZhenyuan()
	
	local szMsg = string.format([[
	大家好，我是金老板，新生代高级产品内部真元激情到货了，欢迎选购！
	
	<color=green>说明：
	1. 内部真元永久绑定，不可交易，与其他真元炼化后也将永久绑定
	2. 每天每人可以购买5个内部真元，品质同逍遥谷产出(随机2-6技能品质)
	3. 内部真元合成过程中，不降低等级
	4. 内部真元售价：%s绑金<color>
	
	你今天还可以购买<color=yellow>%s个<color>内部真元，要继续购买么？
]], self.tbZhenyuanLimit.nPrice, self:CheckZhenyuan());
	
	local tbOpt = 
	{
		{"我要购买", self.SelectZhenyuan, self},
		{"转为外部真元", self.ChangeCommon, self},
		{"<color=gray>返回<color>", self.GainBindCoin, self},	
	};
	Dialog:Say(szMsg, tbOpt);
end

function jbreturn:SelectZhenyuan()
	
	if self:CheckZhenyuan() <= 0 then
		Dialog:Say("对不起，你今日已经无法再购买内部真元了。");
		return 0;
	end
	
	local tbOpt = {};
	local szMsg = string.format("你今天还可以购买<color=yellow>%s个<color>内部真元，内部真元分七种，你要选择哪一种？", self:CheckZhenyuan());
	for nType, tbInfo in ipairs(self.tbZhenyuanType) do
		table.insert(tbOpt, {tbInfo[1], self.OnSelectZhenyuan, self, nType});
	end
	
	table.insert(tbOpt, {"Để ta suy nghĩ thêm"});
	Dialog:Say(szMsg, tbOpt);
end

function jbreturn:OnSelectZhenyuan(nType)
	
	if self:CheckZhenyuan() <= 0 then
		return 0;
	end
	
	local tbInfo = self.tbZhenyuanType[nType];
	if not tbInfo then
		return 0;
	end
	
	Dialog:AskNumber("Nhập số lượng: ", self:CheckZhenyuan(), self.OnSelectZhenyuan_Show, self, nType);
end

function jbreturn:OnSelectZhenyuan_Show(nType, nInput)
	
	local tbInfo = self.tbZhenyuanType[nType];
	if not tbInfo then
		return 0;
	end
	
	if nInput <= 0 or nInput > self:CheckZhenyuan() then
		Dialog:Say("请输入正确的数量。");
		return 0;	
	end
	
	local nPrice = self.tbZhenyuanLimit.nPrice * nInput;
	local szMsg	= string.format([[
商品名称：<color=yellow>%s<color>
购买数量：<color=yellow>%d<color>
消耗绑金：<color=yellow>%s<color>

是否确认购买？]], tbInfo[1], nInput, nPrice);

	Dialog:Say(szMsg, {{"Xác nhận", self.OnSelectZhenyuan_Sure, self, nType, nInput, nPrice}, {"<color=gray>取消"}});
end

function jbreturn:OnSelectZhenyuan_Sure(nType, nInput, nPrice)

	local tbInfo = self.tbZhenyuanType[nType];
	if not tbInfo then
		return 0;
	end
	
	if nInput <= 0 or nInput > self:CheckZhenyuan() then
		Dialog:Say("请输入正确的数量。");
		return 0;	
	end
		
	if me.nBindCoin < nPrice then
		Dialog:Say(string.format("对不起，您的绑金不足<color=green>%s<color>。", nPrice));
		return 0;
	end
	
	if me.CountFreeBagCell() < nInput then
		Dialog:Say(string.format("请留出<color=green>%s格<color>背包空间。", nInput));
		return 0;
	end
	
	local tbLimit = self.tbZhenyuanLimit;
	for i = 1, nInput do
		local pItem = Item.tbZhenYuan:GenerateEx(tbInfo[2]);
		if pItem then
			Item.tbZhenYuan:SetLevel(pItem, 120);
			me.AddBindCoin(-tbLimit.nPrice, Player.emKBINDCOIN_COST_JBRETURN);
			me.SetTask(tbLimit.tbTaskFreeId[1], tbLimit.tbTaskFreeId[2], me.GetTask(tbLimit.tbTaskFreeId[1], tbLimit.tbTaskFreeId[2]) - 1);
		end
	end
end

-- 转化为外部真元
function jbreturn:ChangeCommon()
	Dialog:OpenGift(string.format("请放入欲转化的内部真元<color=yellow>（价值量需超过5000，转化后所有属性降1星）<color>"), nil, {jbreturn.OnChangeCommon, jbreturn});
end

function jbreturn:OnChangeCommon(tbItem, nSure)
	
	local nLimit = 50000000;
	local nCount = 0;
	local pTmpItem = nil;
	for _, tbItem in pairs(tbItem) do
		local pItem = tbItem[1];
		if pItem.IsZhenYuan() == 1 and Item.tbZhenYuan:GetParam1(pItem) == 1 and Item.tbZhenYuan:GetZhenYuanValue(pItem) >= nLimit then
			nCount = nCount + 1;
			pTmpItem = pItem;
		end
	end
	
	if nCount ~= 1 then
		Dialog:Say("请放入正确的内部真元，每次只能放入一件。");
		return 0;
	end
	
	
	if not nSure then
		local szMsg = string.format("你打算将<color=yellow>%s<color>转化为外部真元吗？（转化后所有属性降1星）", pTmpItem.szName);
		local tbOpt =
		{
			{"Xác nhận", self.OnChangeCommon, self, tbItem, 1},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	for _, tbItem in pairs(tbItem) do
		local pItem = tbItem[1];
		if pItem.IsZhenYuan() == 1 and Item.tbZhenYuan:GetParam1(pItem) == 1 then
			local nOrgValue = Item.tbZhenYuan:GetZhenYuanValue(pItem);
			if nOrgValue >= nLimit then
				self:ZhenYuanRevalue(pItem, 2);
				Item.tbZhenYuan:SetParam1(pItem, 0);
				if IsGlobalServer() == false then
					Ladder.tbGuidLadder:ApplyChangeValue(Item.tbZhenYuan:GetLadderId(pItem), pItem.szGUID, me.szName, Item.tbZhenYuan:GetZhenYuanValue(pItem)/10000);
				end
				Dbg:WriteLog("jbreturn", me.szName, string.format("转化为外部真元：%s，原价值量：%s，新价值量：%s", pItem.szName, nOrgValue, Item.tbZhenYuan:GetZhenYuanValue(pItem)));
			end
		end
	end
end

-- 转化为非护体真元
function jbreturn:ChangeFree()
	Dialog:OpenGift(string.format("请放入欲转化的护体真元<color=yellow>（需要在背包中，价值量需超过1000，转化后所有属性降半星）<color>"), nil, {jbreturn.OnChangeFree, jbreturn});
end

function jbreturn:OnChangeFree(tbItem)
	local tbEquipOrg = {};	--当前已经装备的真元17,18,19三个格子
	for i =1, 3 do
		local pEquiped = me.GetItem(0,16+i, 0);
		if pEquiped then
			tbEquipOrg[pEquiped.dwId] = 1;
		end
	end
	local nLimit = 10000000;
	local nCount = 0;
	local pTmpItem = nil;
	for _, tbItem in pairs(tbItem) do
		local pItem = tbItem[1];
		if pItem.IsZhenYuan() == 1 and Item.tbZhenYuan:GetEquiped(pItem) == 1 and Item.tbZhenYuan:GetZhenYuanValue(pItem) >= nLimit and not tbEquipOrg[pItem.dwId] then
			nCount = nCount + 1;
			pTmpItem = pItem;
		end
	end
	
	if nCount ~= 1 then
		Dialog:Say("请放入正确的护体真元，每次只能放入一件。");
		return 0;
	end
	
	for _, tbItem in pairs(tbItem) do
		local pItem = tbItem[1];
		if pItem.IsZhenYuan() == 1 and Item.tbZhenYuan:GetEquiped(pItem) == 1 then
			local nOrgValue = Item.tbZhenYuan:GetZhenYuanValue(pItem);
			if nOrgValue >= nLimit and not tbEquipOrg[pItem.dwId] then
				self:ZhenYuanRevalue(pItem, 1);
				Item.tbZhenYuan:SetEquiped(pItem, 0);
				pItem.Regenerate(pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel, pItem.nSeries, pItem.nEnhTimes, pItem.nLucky, pItem.GetGenInfo(), 
					pItem.nVersion, pItem.dwRandSeed, pItem.nStrengthen);
				if Item.tbZhenYuan:GetParam1(pItem) == 0 and IsGlobalServer() == false then
					Ladder.tbGuidLadder:ApplyChangeValue(Item.tbZhenYuan:GetLadderId(pItem), pItem.szGUID, me.szName, Item.tbZhenYuan:GetZhenYuanValue(pItem)/10000);
				end
				me.SetTask(2085, 8, 0);
				me.RemoveSkillState(2476);
				local szLog = string.format("转化为非护体真元：%s，原价值量：%s，新价值量：%s", pItem.szName, nOrgValue, Item.tbZhenYuan:GetZhenYuanValue(pItem));
				Dbg:WriteLog("jbreturn", me.szName, szLog);
				me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szLog);
			end
		end
	end
end

function jbreturn:ZhenYuanRevalue(pItem, nPot)
	if pItem and pItem.IsZhenYuan() == 1 then
		local nPot1 = Item.tbZhenYuan:GetAttribPotential1(pItem);
		local nPot2 = Item.tbZhenYuan:GetAttribPotential2(pItem);
		local nPot3 = Item.tbZhenYuan:GetAttribPotential3(pItem);
		local nPot4 = Item.tbZhenYuan:GetAttribPotential4(pItem);
		Item.tbZhenYuan:SetAttribPotential1(pItem, math.max(nPot1 - nPot, 1));
		Item.tbZhenYuan:SetAttribPotential2(pItem, math.max(nPot2 - nPot, 1));
		Item.tbZhenYuan:SetAttribPotential3(pItem, math.max(nPot3 - nPot, 1));
		Item.tbZhenYuan:SetAttribPotential4(pItem, math.max(nPot4 - nPot, 1));
		pItem.Sync();
		
		Dbg:WriteLog("真元降星", me.szName, string.format("真元：%s, 原始星级：%d_%d_%d_%d，集体下降%d星", 
			pItem.szName, nPot1, nPot2, nPot3, nPot4, nPot));
	end
end

-------------------------------------------------------
-- 内部同伴装备
-------------------------------------------------------

-- 同伴装备列表
jbreturn.tbPartnerEquip =
{
	[1] = {"碧血战衣", {5, 20, 1, 1}, {18, 1, 944, 1}, 15, 15},
	[2] = {"碧血之刃", {5, 19, 1, 1}, {18, 1, 941, 1}, 15, 15},
	[3] = {"碧血护符", {5, 23, 1, 1}, {18, 1, 947, 1}, 15, 15},
	[4] = {"碧血护腕", {5, 22, 1, 1}, {18, 1, 1235, 1}, 300, 270},
	[5] = {"碧血戒指", {5, 21, 1, 1}, {18, 1, 1236, 1}, 300, 270},
	[6] = {"金鳞战衣", {5, 20, 1, 2}, {18, 1, 945, 1}, 15, 15},
	[7] = {"金鳞之刃", {5, 19, 1, 2}, {18, 1, 942, 1}, 15, 15},
	[8] = {"金鳞护符", {5, 23, 1, 2}, {18, 1, 948, 1}, 15, 15},
	[9] = {"金鳞护腕", {5, 22, 1, 2}, {18, 1, 1235, 2}, 300, 270},
	[10] = {"金鳞戒指", {5, 21, 1, 2}, {18, 1, 1236, 2}, 300, 270},
	[11] = {"碧血战衣（结晶）", {5, 20, 1, 1}, {18, 1, 1491, 1}, 30},
	[12] = {"碧血之刃（结晶）", {5, 19, 1, 1}, {18, 1, 1491, 1}, 45},
	[13] = {"碧血护符（结晶）", {5, 23, 1, 1}, {18, 1, 1491, 1}, 300},
};

function jbreturn:BuyPartnerEquip()
	
	local szMsg = [[
	大家好，我是金老板，萌达同伴装备到货了！你要兑换哪一种？
	
	<color=green>说明：
	1. 内部同伴装备不可交易，不可解绑
	2. 使用一定数量的同伴碎片或材料换取<color>
]];
	local tbOpt = {};
	for nType, tbInfo in ipairs(self.tbPartnerEquip) do
		table.insert(tbOpt, {string.format("%s - %s", tbInfo[1], tbInfo[4]), self.ChangePartnerEquip, self, nType});
	end
	table.insert(tbOpt, {"<color=yellow>同伴装备兑换材料<color>", self.ChangeBack, self});
	table.insert(tbOpt, {"<color=gray>返回<color>", self.GainBindCoin, self});

	Dialog:Say(szMsg, tbOpt);	
end

function jbreturn:ChangePartnerEquip(nType)
	Dialog:OpenGift(string.format("请放入<color=yellow>%s<color>碎片或材料", self.tbPartnerEquip[nType][1]), nil, {jbreturn.OnChangePartnerEquip, jbreturn, nType});
end

function jbreturn:OnChangePartnerEquip(nType, tbItem, nSure)
	
	local tbInfo = self.tbPartnerEquip[nType];
	if not tbInfo then
		return 0;
	end
	
	local nCount = 0;
	local nBind = 1;
	for _, tbItem in pairs(tbItem) do
		local pItem = tbItem[1];
		local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
		if szKey == string.format("%s,%s,%s,%s", unpack(tbInfo[3])) then
			nCount = nCount + pItem.nCount;
			if pItem.IsBind() == 1 then
				nBind = 2;
			end
		end
	end
	
	local nBase = tbInfo[4] * nBind;
	if nCount <= 0 or math.mod(nCount, nBase) ~= 0 then
		Dialog:Say(string.format("请放入<color=yellow>%s<color>或其整数倍的<color=yellow>%s<color>材料或碎片。", nBase, tbInfo[1]));
		return 0;
	end
	
	local nNeed = math.floor(nCount / nBase);
	if me.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("请留出%s格背包空间。", nNeed));
		return 0;
	end
	
	if not nSure then
		local szMsg = string.format("你确定要兑换<color=yellow>%s<color>个<color=yellow>%s<color>么？", nNeed, tbInfo[1]);
		local tbOpt =
		{
			{"Xác nhận", self.OnChangePartnerEquip, self, nType, tbItem, 1},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end

	for _, tbItem in pairs(tbItem) do
		local pItem = tbItem[1];
		local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
		if szKey == string.format("%s,%s,%s,%s", unpack(tbInfo[3])) then
			me.DelItem(pItem);
		end
	end

	for i = 1, nNeed do 
		local tbItemId = tbInfo[2];	
		local pItem = me.AddItem(tbItemId[1], tbItemId[2], tbItemId[3], tbItemId[4]);
		if pItem then
			Partner:SetPartnerEquipParam(pItem);
			pItem.Bind(1);
			pItem.Sync();
		end
	end
end

function jbreturn:ChangeBack()
	Dialog:OpenGift("请放入同伴装备", nil, {jbreturn.OnChangeBack, jbreturn});
end

function jbreturn:OnChangeBack(tbItem, nSure)
	
	local nNeed = 0;
	local nValue = 0;
	for _, tbItem in pairs(tbItem) do
		local pItem = tbItem[1];
		if Partner:GetPartnerEquipParam(pItem) == 1 then
			local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
			for i, tbInfo in pairs(self.tbPartnerEquip) do
				if szKey == string.format("%s,%s,%s,%s", unpack(tbInfo[2])) and tbInfo[5] then
					nValue = nValue + 1;
					nNeed = nNeed + math.ceil(tbInfo[5] / 100);
				end
			end
		end
	end
	
	if nValue <= 0 then
		Dialog:Say("请放入正确的同伴装备，一次可以放入多件。");
		return 0;
	end

	if me.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("请留出%s格背包空间。", nNeed));
		return 0;
	end
	
	if not nSure then
		local szMsg = string.format("你打算将放入的<color=yellow>%s件<color>同伴装备全部兑换为原料吗？", nValue);
		local tbOpt =
		{
			{"Xác nhận", self.OnChangeBack, self, tbItem, 1},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	for _, tbItem in pairs(tbItem) do
		local pItem = tbItem[1];
		if Partner:GetPartnerEquipParam(pItem) == 1 then
			local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
			for i, tbInfo in pairs(self.tbPartnerEquip) do
				if szKey == string.format("%s,%s,%s,%s", unpack(tbInfo[2])) and tbInfo[5] then
					me.DelItem(pItem);
					me.AddStackItem(tbInfo[3][1], tbInfo[3][2], tbInfo[3][3], tbInfo[3][4], nil, tbInfo[5]);
				end
			end
		end
	end
end

-------------------------------------------------------
-- 内部龙魂装备
-------------------------------------------------------

jbreturn._LONGHUN_VALUE = 4;
jbreturn.tbLonghunList =
{         

	[1] = {"龙魂鉴·衣服（1级）", {22, 1, 112, 1}, {15, 2, 1}},
	[2] = {"龙魂鉴·衣服（2级）", {22, 1, 112, 2}, {15, 2, 2}},
	[3] = {"龙魂鉴·衣服（3级）", {22, 1, 112, 3}, {15, 2, 3}},
	[4] = {"龙魂鉴·戒指（1级）", {22, 1, 113, 1}, {15, 3, 1}},
	[5] = {"龙魂鉴·戒指（2级）", {22, 1, 113, 2}, {15, 3, 2}},
	[6] = {"龙魂鉴·戒指（3级）", {22, 1, 113, 3}, {15, 3, 3}},
	[7] = {"龙魂鉴·护身符（1级）", {22, 1, 114, 1}, {15, 4, 1}},
	[8] = {"龙魂鉴·护身符（2级）", {22, 1, 114, 2}, {15, 4, 2}},
	[9] = {"龙魂鉴·护身符（3级）", {22, 1, 114, 3}, {15, 4, 3}},
};

function jbreturn:CalcLonghunRepute(nCamp, nClass, nLevel)
	local nCurLevel = me.GetReputeLevel(nCamp, nClass);
	local nCurValue = me.GetReputeValue(nCamp, nClass);
	if nCurLevel ~= nLevel then
		return 0;
	end
	local tbFullReputeInfo = KPlayer.GetReputeInfo();
	local tbReputeInfo = tbFullReputeInfo[nCamp][nClass];
	if nCurValue < 0 then
		return 0;
	end
	return math.ceil(tbReputeInfo[nCurLevel].nLevelUp - nCurValue) / self._LONGHUN_VALUE;
end

function jbreturn:BuyLonghunRepute()
	local szMsg = "    这里可以直接用<color=yellow>龙魂鉴碎片<color>兑换龙魂声望，独此一家，别无分号，赶紧的吧哈哈哈。";
	local tbOpt = {};
	for nType, tbInfo in ipairs(self.tbLonghunList) do
		local nCamp, nClass, nLevel = unpack(tbInfo[3]);
		local nLimit = self:CalcLonghunRepute(nCamp, nClass, nLevel);
		if nLimit > 0 then
			table.insert(tbOpt, {string.format("%s - <color=yellow>需要%s个<color>", tbInfo[1], nLimit), self.DoBuyLonghunRepute, self, nType});
		else
			table.insert(tbOpt, {string.format("%s - <color=gray>不可兑换<color>", tbInfo[1]), self.BuyLonghunRepute, self});
		end
	end
	table.insert(tbOpt, {"<color=gray>返回<color>", self.GainBindCoin, self});
	Dialog:Say(szMsg, tbOpt);	
end

function jbreturn:DoBuyLonghunRepute(nType)
	Dialog:OpenGift(string.format("请放入<color=yellow>%s<color>", self.tbLonghunList[nType][1]), nil, {jbreturn.OnBuyLonghunRepute, jbreturn, nType});
end

function jbreturn:OnBuyLonghunRepute(nType, tbItem, nSure)
	
	local tbInfo = self.tbLonghunList[nType];
	if not tbInfo then
		return 0;
	end
	
	local nCount = 0;
	for _, tbItem in pairs(tbItem) do
		local pItem = tbItem[1];
		local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
		if szKey == string.format("%s,%s,%s,%s", unpack(tbInfo[2])) then
			nCount = nCount + pItem.nCount;
		end
	end
	
	local nCamp, nClass, nLevel = unpack(tbInfo[3]);
	local nLimit = self:CalcLonghunRepute(nCamp, nClass, nLevel);
	if nCount <= 0 or nCount > nLimit then
		Dialog:Say("请放入正确数量的声望碎片。");
		return 0;
	end
	
	if not nSure then
		local szMsg = string.format("你确定要将<color=yellow>%s<color>个<color=yellow>%s<color>兑换成声望么？", nCount, tbInfo[1]);
		local tbOpt =
		{
			{"Xác nhận", self.OnBuyLonghunRepute, self, nType, tbItem, 1},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end

	for _, tbItem in pairs(tbItem) do
		local pItem = tbItem[1];
		local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
		if szKey == string.format("%s,%s,%s,%s", unpack(tbInfo[2])) then
			local nRet = me.DelItem(pItem);
			if nRet ~= 1 then
				return 0;
			end
		end
	end

	me.AddRepute(nCamp, nClass, nCount * self._LONGHUN_VALUE);
end

-------------------------------------------------------
-- 内部秦陵声望
-------------------------------------------------------
jbreturn.tbQinlingItem =
{
	[1] = {"和氏璧", {18, 1, 377, 1}, 800},
	[2] = {"蓝田玉", {18, 1, 1452, 1}, 20},
};

function jbreturn:BuyQinlingRepute()
	local szMsg = "    这里可以使用<color=yellow>和氏璧<color>和<color=yellow>蓝田玉<color>兑换秦陵·发丘门声望，要换的赶紧。";
	local tbOpt = 
	{
		{"我要兑换", self.DoBuyQinlingRepute, self},
		{"<color=gray>返回<color>", self.GainBindCoin, self},
	};
	Dialog:Say(szMsg, tbOpt);	
end

function jbreturn:DoBuyQinlingRepute()
	Dialog:OpenGift("请放入<color=yellow>和氏璧<color>或<color=yellow>蓝田玉<color>", nil, {jbreturn.OnBuyQinlingRepute, jbreturn});
end

function jbreturn:OnBuyQinlingRepute(tbItem, nSure)
	
	local nRepute = 0;
	for _, tbItem in pairs(tbItem) do
		local pItem = tbItem[1];
		local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
		for _, tbInfo in ipairs(self.tbQinlingItem) do
			if szKey == string.format("%s,%s,%s,%s", unpack(tbInfo[2])) then
				nRepute = nRepute + pItem.nCount * tbInfo[3];
			end
		end
	end
	
	if nRepute <= 0 then
		Dialog:Say("请放入正确数量的道具。");
		return 0;
	end
	
	if not nSure then
		local szMsg = string.format("    你确定要将放入的材料兑换成<color=yellow>%s点<color>秦陵·发丘门声望么？", nRepute);
		local tbOpt =
		{
			{"<color=yellow>确定<color>", self.OnBuyQinlingRepute, self, tbItem, 1},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end

	for _, tbItem in pairs(tbItem) do
		local pItem = tbItem[1];
		local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
		for _, tbInfo in ipairs(self.tbQinlingItem) do
			if szKey == string.format("%s,%s,%s,%s", unpack(tbInfo[2])) then
				local nRet = me.DelItem(pItem);
				if nRet ~= 1 then
					return 0;
				end
			end
		end	
	end

	me.AddRepute(9, 2, nRepute);
end

-------------------------------------------------------
-- 日月事件
-------------------------------------------------------

-- 刷新月额度
function jbreturn:ResetMonthLimit()
	local nMonLimit	= self:GetMonLimit(me);
	if nMonLimit <= 0 then
		return 0;
	end
	for _, tbInfo in pairs(self.tbLimitItemList or {}) do
		local tbTaskId = tbInfo.tbTaskId;
		if tbTaskId then
			me.SetTask(tbTaskId[1], tbTaskId[2], 0);
		end
	end
	me.SetTask(self.FRIEND_TASK_GID, self.FRIEND_TASK_COST, 0);
end

-- 刷新日额度
function jbreturn:ResetDailyLimit()
	
	local nLimitLevel, nSpecial, nMonLimit = self:GetRetLevel(me);
	if nMonLimit <= 0 then
		return 0;
	end
	
	local tbLimit = self.tbZhenyuanLimit;
	local nSpeed = KGblTask.SCGetDbTaskInt(DBTASK_TIMEFRAME_OPEN);
	local nStartDay = (nSpeed == 1) and 10 or tbLimit.nStartDay;
	local nOpenTime = GetTime() - KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	if nOpenTime < nStartDay * 60 * 60 * 24 then
		return 0;
	end
	
	local nPlayerHonor = (nSpecial == 9) and 10 or PlayerHonor:GetPlayerMaxHonorLevel(me);
	local nAddCount = self.tbZhenyuanHonor[nPlayerHonor] and self.tbZhenyuanHonor[nPlayerHonor] or tbLimit.nDayLimit;
	local nTotalCount = me.GetTask(tbLimit.tbTaskFreeId[1], tbLimit.tbTaskFreeId[2]) + nAddCount;
	if nTotalCount > tbLimit.nTotalLimit then
		nTotalCount = tbLimit.nTotalLimit;
	end
	me.SetTask(tbLimit.tbTaskFreeId[1], tbLimit.tbTaskFreeId[2], nTotalCount);
end

-- 内部特殊设置
function jbreturn:SpecReturnSet()
	local szMsg = "    这里可以设置游龙提示状态、微博关联状态、领取充值称号等等。";
	local tbOpt = 
	{
		{"内部游龙设置", self.SpecYoulong, self},
		{"微博关联设置", self.SpecSnsSet, self},
		{"领取充值称号", self.GetSpecTitle, self},
		{"<color=gray>返回<color>", self.GainBindCoin, self},
	};
	Dialog:Say(szMsg, tbOpt);
end

-- 内部商店
function jbreturn:OpenSpecShop()
	me.OpenShop(178, 10);
end

-- 内部仓库
function jbreturn:OpenSpecRepository()
	me.OpenRepository(him, 1);
	self:SyncBindBankData(me);
end

function jbreturn:BindCurrencyOperate(nOperate, nMoneyType, nCount)
	if self:IsPermitIp(me) == 0 then
		return;
	end
	
	local bOk, szMsg = self:CheckState();
	if (bOk ~= 1) then
		return;
	end
	
	local nMonLimit	= self:GetMonLimit(me);
	if (nMonLimit <= 0) then
		return;
	end
	
	-- 内部仓库处于打开状态才行
	if me.GetRepositoryOpenState() ~= 2 then
		return;
	end
		
	if nOperate == 1 then	-- 存
		if nMoneyType == 1 then	-- 绑银
			local nSum = me.GetBindMoney();
			if nSum < nCount then
				return;
			end			
			if (me.CostBindMoney(nCount) ~= 1) then
				return;
			end
			me.SetTask(self.BINDBANK_MAIN, self.BINDBANK_BINDMONEY, 
				me.GetTask(self.BINDBANK_MAIN, self.BINDBANK_BINDMONEY) + nCount);		
		else	-- 绑金
			local nSum = me.nBindCoin;
			if nSum < nCount then
				return;
			end			
			if (me.AddBindCoin(0-nCount) ~= 1) then
				return;
			end
			me.SetTask(self.BINDBANK_MAIN, self.BINDBANK_BINDCOIN,
				me.GetTask(self.BINDBANK_MAIN, self.BINDBANK_BINDCOIN) + nCount);	
		end		
	else	-- 取
		if nMoneyType == 1 then	-- 绑银
			local nSum = me.GetTask(self.BINDBANK_MAIN, self.BINDBANK_BINDMONEY);
			if nSum < nCount then
				return;
			end
			
			if me.GetMaxCarryMoney() < me.GetBindMoney() + nCount then
				me.Msg("携带量将达上限！")
				return;
			end
			me.AddBindMoney(nCount);
			me.SetTask(self.BINDBANK_MAIN, self.BINDBANK_BINDMONEY, nSum - nCount);		
		else	-- 绑金
			local nSum = me.GetTask(self.BINDBANK_MAIN, self.BINDBANK_BINDCOIN);
			if nSum < nCount then
				return;
			end			
			if (me.AddBindCoin(nCount) ~= 1) then
				return;
			end
			me.SetTask(self.BINDBANK_MAIN, self.BINDBANK_BINDCOIN, nSum - nCount);	
		end				
	end
	
	self:SyncBindBankData(me);
end

function jbreturn:SyncBindBankData(pPlayer)
	local nBankBindMoney = me.GetTask(self.BINDBANK_MAIN, self.BINDBANK_BINDMONEY);
	local nBankBindCoin = me.GetTask(self.BINDBANK_MAIN, self.BINDBANK_BINDCOIN);
	pPlayer.CallClientScript({"Player:BindInfoSync", nBankBindMoney, nBankBindCoin});
end

-------------------------------------------------------
-- 充值称号
-------------------------------------------------------

jbreturn.tbReputeTitle =
{
	[1] = {tbRepute = {11, 1}, tbTitle = {6, 31, 1, 0}, szTitle = "指环王"},
	[2] = {tbRepute = {5, 5}, tbTitle = {6, 32, 1, 0}, szTitle = "海洋之心"},
	[3] = {tbRepute = {12, 1}, tbTitle = {6, 47, 1, 0}, szTitle = "乱世枭雄"},
	[4] = {tbRepute = {9, 2}, tbTitle = {6, 33, 1, 0}, szTitle = "玉如意"},
	[5] = {tbRepute = {5, 6}, tbTitle = {6, 52, 1, 0}, szTitle = "雪山飞狐"},
};

-- 领取充值称号
function jbreturn:GetSpecTitle()

	local tbOpt = {};
	local szMsg = "大家好，我是金老板，这里可以领取充值称号！";
	for nIndex, tbInfo in pairs(self.tbReputeTitle) do
		table.insert(tbOpt, {tbInfo.szTitle, self.OnGetSpecTitle, self, nIndex});
	end
	table.insert(tbOpt, {"<color=gray>返回<color>", self.GainBindCoin, self});
	Dialog:Say(szMsg, tbOpt);
end

function jbreturn:OnGetSpecTitle(nIndex)
	local tbInfo = self.tbReputeTitle[nIndex];
	if not tbInfo then
		return 0;
	end
	if me.GetReputeLevel(unpack(tbInfo.tbRepute)) < 2 then
		Dialog:Say("对不起，你的此项声望不足，无法领取该称号。");
		return 0;
	end
	if me.FindTitle(unpack(tbInfo.tbTitle)) == 1 then
		Dialog:Say("对不起，你已经拥有该称号。");
		return 0;
	end
	me.AddTitle(unpack(tbInfo.tbTitle));
end

-------------------------------------------------------
-- 内部密友返还
-------------------------------------------------------

-- 500封上限
jbreturn.MAX_FRIEND_COST 	= 500000;
jbreturn.FRIEND_TASK_GID 	= 2056;
jbreturn.FRIEND_TASK_COST	= 11;

-- 高密友返还道具
jbreturn.tbFriendItemList = 
{
	[1] = 
	{
		nPrice =500,
		nMaxCount = 20,
		tbItemId = {18, 1, 924, 1},
		szName = "千里传音（小）",
	},
	[2] = 
	{
		nPrice = 2500,
		nMaxCount = 10,
		tbItemId = {18, 1, 925, 1},
		szName = "千里传音（大）",
	},
	[3] = 
	{
		nPrice = 4000,
		nMaxCount = 10,
		tbItemId = {18, 1, 490, 1},
		szName = "跨服绑银",
	},
};

function jbreturn:BuySpecFriend()
	local nFriendCost = me.GetTask(self.FRIEND_TASK_GID, self.FRIEND_TASK_COST);
	local nTotal = math.min(self:GetMonLimit(me) * 200, self.MAX_FRIEND_COST);
	local szMsg = string.format([[
   此功能是为了解决<color=yellow>加外网玩家密友<color>的问题，对于角色本身是<color=yellow>无优惠<color>的，请谨慎使用！
	
	<color=green>说明：
	1. 下列产品均非内部价格<color=yellow>(0.1)<color>，而接近于奇珍阁原价<color=yellow>(0.8-1.0)<color>
	2. 下列产品购买后，均可产生高额的密友返还<color=yellow>(1:1)<color>
	3. 根据账号额度，购买限量，约可产生<color=yellow>略低于财富增长<color>的密友返还值
	4. 内部返还账号一般<color=yellow>不建议加外网玩家为密友<color>，如果实在要这么做，可以通过下列产品，制造足够的<color=yellow>密友返还值<color>，以消除疑虑，但是对于自身，等同于<color=yellow>直接奇珍阁消费<color>，请三思而后定<color>

你本月产生的密友返还为：<color=yellow>%s<color>
还可以消耗的密友绑金为：<color=yellow>%s<color>
]], math.floor(nFriendCost / 10), nTotal - nFriendCost);

	local tbOpt = {};
	for nIndex, tbInfo in ipairs(self.tbFriendItemList) do
		table.insert(tbOpt, {tbInfo.szName, self.OnBuySpecFriend, self, nIndex});
	end
	table.insert(tbOpt, {"<color=gray>返回<color>", self.GainBindCoin, self});
	
	Dialog:Say(szMsg, tbOpt);
end

function jbreturn:OnBuySpecFriend(nType)
	
	local tbInfo = self.tbFriendItemList[nType];
	if not tbInfo then
		return 0;
	end
	
	Dialog:AskNumber("Nhập số lượng: ", tbInfo.nMaxCount, self.OnBuySpecFriend_Show, self, nType);
end

function jbreturn:OnBuySpecFriend_Show(nType, nInput)
	
	local tbInfo = self.tbFriendItemList[nType];
	if not tbInfo then
		return 0;
	end
	
	if nInput <= 0 or nInput > tbInfo.nMaxCount then
		Dialog:Say("请输入正确的数量。");
		return 0;
	end
	
	local nPrice = tbInfo.nPrice * nInput;
	local szMsg	= string.format([[
商品名称：<color=yellow>%s<color>
购买数量：<color=yellow>%d<color>
消耗绑金：<color=yellow>%s<color>

是否确认购买？]], tbInfo.szName, nInput, nPrice);

	Dialog:Say(szMsg, {{"Xác nhận", self.OnBuySpecFriend_Sure, self, nType, nInput, nPrice}, {"<color=gray>取消"}});
end

function jbreturn:OnBuySpecFriend_Sure(nType, nInput, nPrice)
	
	local tbInfo = self.tbFriendItemList[nType];
	if not tbInfo then
		return 0;
	end
	
	if me.nBindCoin < nPrice then
		Dialog:Say(string.format("对不起，您的绑金不足<color=green>%s<color>。", nPrice));
		return 0;
	end
	
	local nFriendCost = me.GetTask(self.FRIEND_TASK_GID, self.FRIEND_TASK_COST);
	local nTotal = math.min(self:GetMonLimit(me) * 200, self.MAX_FRIEND_COST);
	if nPrice + nFriendCost > nTotal then
		Dialog:Say(string.format("对不起，你本月还可以消耗的密友绑金为：<color=yellow>%s<color>，无法继续够买。", nTotal - nFriendCost));
		return 0;
	end
	
	local tbItemId = tbInfo.tbItemId;
	local nNeed = KItem.GetNeedFreeBag(tbItemId[1], tbItemId[2], tbItemId[3], tbItemId[4], {bForceBind = 1}, nInput);
	if me.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("请留出%s格背包空间。", nNeed));
		return 0;
	end
	
	me.AddBindCoin(-nPrice, Player.emKBINDCOIN_COST_JBRETURN);
	me.IbBackCoin(nPrice * 2);
	me.Msg(string.format("消耗：%s绑金，等同于消耗：%s金币，正常密友返还：%s绑金，现密友返还：%s绑金", nPrice, math.floor(nPrice / 10), math.floor(nPrice / 200), math.floor(nPrice / 10)));
	me.AddStackItem(tbItemId[1], tbItemId[2], tbItemId[3], tbItemId[4], {bForceBind = 1}, nInput);
	me.SetTask(self.FRIEND_TASK_GID, self.FRIEND_TASK_COST, nFriendCost + nPrice);
end

-- 内部游龙可选屏蔽所有消息
function jbreturn:SpecYoulong()
	local nHide = me.GetTask(2056, 12);
	local tbType = {[0] = "开启", [1] = "Đóng lại"};
	local szMsg = string.format("你当前的游龙频道提示状态为：<color=yellow>%s<color>", tbType[nHide]);
	local tbOpt = 
	{
		{string.format("<color=yellow>%s<color>", tbType[1 - nHide]), self.DoSpecYoulong, self},
		{"<color=gray>返回<color>", self.GainBindCoin, self},
	};
	Dialog:Say(szMsg, tbOpt);
end

function jbreturn:DoSpecYoulong()
	local nHide = me.GetTask(2056, 12);
	local tbType = {[0] = "开启", [1] = "Đóng lại"};
	me.SetTask(2056, 12, 1 - nHide);
	me.Msg(string.format("你的游龙频道提示状态设置为：<color=yellow>%s<color>", tbType[1 - nHide]));
end

-- 内部微博关联屏蔽接口
function jbreturn:SpecSnsSet()
	local tbType = {[0] = "可见", [1] = "隐藏"};
	local nSnsBind = KGCPlayer.OptGetTask(me.nId, KGCPlayer.SNS_BIND);
	local nHide = Lib:LoadBits(nSnsBind, 4, 7);
	local szMsg = string.format("你当前的微博关联状态为：<color=yellow>%s<color>", tbType[nHide]);
	local tbOpt = {
		{string.format("<color=yellow>%s<color>", tbType[1 - nHide]), self.DoSpecSnsSet, self},
		{"<color=gray>返回<color>", self.GainBindCoin, self},
	};
	Dialog:Say(szMsg, tbOpt);
end

function jbreturn:DoSpecSnsSet()
	local tbType = {[0] = "可见", [1] = "隐藏"};
	local nSnsBind = KGCPlayer.OptGetTask(me.nId, KGCPlayer.SNS_BIND);
	local nHide = Lib:LoadBits(nSnsBind, 4, 7);
	nSnsBind = Lib:SetBits(nSnsBind, 1 - nHide, 4, 7);
	me.SetSnsBind(nSnsBind);
	me.Msg(string.format("你的微博关联状态设置为：<color=yellow>%s<color>", tbType[1 - nHide]));
end

function jbreturn:LimitLevelUp()
	local nCurMon = tonumber(GetLocalDate("%Y%m"));
	local nMaxConsume, nMinConsume, tbConsume = self:CheckConsume(me, nCurMon, 3);
	local szConsume = "消耗记录：";
	local nMonth = math.mod(nCurMon, 100);
	local nYear = math.floor(nCurMon / 100);
	for _, tb in ipairs(tbConsume) do
		local m = math.mod(tb[1], 100);
		local y = math.floor(tb[1] / 100);
		szConsume = szConsume .. string.format("\n%d年%02d月：%4d￥", y, m, math.floor(tb[2] / 100));
	end
	if (not nMinConsume) then
		Dialog:Say("充值记录不足3个月，不能处理升级。\n\n" .. szConsume);
		return;
	end
	local nLimitLevel, nSpecial, nMonLimit = self:GetRetLevel(me);
	if (nLimitLevel >= 5) then
		Dialog:Say("您当前额度过高，已不能自动升级，请向相关负责人申请。\n\n" .. szConsume);
		return;
	end
	if (nMinConsume < nMonLimit * 100) then
		Dialog:Say(string.format("请先保持3个月用满原%d￥/月的额度，再来申请。\n\n" .. szConsume, nMonLimit));
		return;
	end
	self:SetRetLevel(me, nLimitLevel + 1, nSpecial);
	Dialog:Say(string.format("符合提升要求，已将您的优惠额度提升至%d￥/月！\n\n" .. szConsume, self.tbMonLimit[nLimitLevel + 1]));
end

-- 处理非法道具
function jbreturn:DelSpecItem(Player)
	
	local tbList = 
	{
		{"内部战书", {18, 1, 524, 4}, 1},
		{"碧血战衣", {5, 20, 1, 1}, 2, {18, 1, 944, 1}, 30},
		{"碧血之刃", {5, 19, 1, 1}, 2, {18, 1, 941, 1}, 30},
		{"碧血护符", {5, 23, 1, 1}, 2, {18, 1, 947, 1}, 30},
		{"碧血护腕", {5, 22, 1, 1}, 2, {18, 1, 1237, 1}, 30},
		{"碧血戒指", {5, 21, 1, 1}, 2, {18, 1, 1240, 1}, 30},
		{"金鳞战衣", {5, 20, 1, 2}, 2, {18, 1, 945, 1}, 30},
		{"金鳞之刃", {5, 19, 1, 2}, 2, {18, 1, 942, 1}, 30},
		{"金鳞护符", {5, 23, 1, 2}, 2, {18, 1, 948, 1}, 30},
		{"金鳞护腕", {5, 22, 1, 2}, 2, {18, 1, 1238, 1}, 30},
		{"金鳞戒指", {5, 21, 1, 2}, 2, {18, 1, 1241, 1}, 30},
		{"【真元】叶静", {1, 24, 1, 1}, 3},
		{"【真元】宝玉", {1, 24, 2, 1}, 3},
		{"【真元】夏小倩", {1, 24, 3, 1}, 3},
		{"【真元】莺莺", {1, 24, 4, 1}, 3},
		{"【真元】木超", {1, 24, 5, 1}, 3},
		{"【真元】紫苑", {1, 24, 6, 1}, 3},
		{"【真元】秦仲", {1, 24, 7, 1}, 3},
	};

	Setting:SetGlobalObj(pPlayer);
	for _, tbInfo in pairs(tbList) do 
		local tbFind = GM:GMFindAllRoom(tbInfo[2]);
		for _, tbItem in pairs(tbFind or {}) do
			if tbInfo[3] == 1 then
				local szMsg = string.format("VIP游龙战书扣除：%s", tbItem.pItem.szName);
				me.DelItem(tbItem.pItem);
				me.PlayerLog(Log.emKPLAYERLOG_TYPE_GM_OPERATION, szMsg);
				Dbg:WriteLog("jbreturn", me.szName, szMsg);
			elseif tbInfo[3] == 2 and Partner:GetPartnerEquipParam(tbItem.pItem) == 1 then
				local szMsg = string.format("VIP同伴装备扣除：%s", tbItem.pItem.szName);
				me.DelItem(tbItem.pItem);
				me.AddStackItem(tbInfo[4][1], tbInfo[4][2], tbInfo[4][3], tbInfo[4][4], {bForceBind = 1}, tbInfo[5]);
				me.PlayerLog(Log.emKPLAYERLOG_TYPE_GM_OPERATION, szMsg);
				Dbg:WriteLog("jbreturn", me.szName, szMsg);
			elseif tbInfo[3] == 3 and Item.tbZhenYuan:GetParam1(tbItem.pItem) == 1 then
				local szPot = string.format("%s-%s-%s-%s", 
					Item.tbZhenYuan:GetAttribPotential1(tbItem.pItem),
					Item.tbZhenYuan:GetAttribPotential2(tbItem.pItem),
					Item.tbZhenYuan:GetAttribPotential3(tbItem.pItem),
					Item.tbZhenYuan:GetAttribPotential4(tbItem.pItem)
				);
				local szOrgValue = Item.tbZhenYuan:GetZhenYuanValue(tbItem.pItem);
				self:ZhenYuanRevalue(tbItem.pItem, 2);
				Item.tbZhenYuan:SetParam1(tbItem.pItem, 0);
				local szMsg = string.format("VIP真元降星：%s, 价值：%s，星级：%s", tbItem.pItem.szName, szOrgValue, szPot);
				me.PlayerLog(Log.emKPLAYERLOG_TYPE_GM_OPERATION, szMsg);
				Dbg:WriteLog("jbreturn", me.szName, szMsg);
			end
		end
		for i = 0, 4 do
			local pItem = me.GetItem(Item.ROOM_PARTNEREQUIP, i, 0);
			if pItem then
				local szName = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
				local szName2 = string.format("%s,%s,%s,%s", unpack(tbInfo[2]));
				if szName == szName2 and Partner:GetPartnerEquipParam(pItem) == 1 then
					local szMsg = string.format("VIP同伴装备扣除：%s", pItem.szName);
					me.DelItem(pItem);
					me.AddStackItem(tbInfo[4][1], tbInfo[4][2], tbInfo[4][3], tbInfo[4][4], {bForceBind = 1}, tbInfo[5]);
					me.PlayerLog(Log.emKPLAYERLOG_TYPE_GM_OPERATION, szMsg);
					Dbg:WriteLog("jbreturn", me.szName, szMsg);
				end
			end
		end
	end
	Setting:RestoreGlobalObj(pPlayer);
end

function jbreturn:_OnLogin(bExchangeServerComing)
	local nIsNoUse = Account:GetIntValue(me.szAccount, "Account.VipIsNoUse"); 
	if nIsNoUse == 0 then
		return;
	end
	self:DelSpecItem(me);
	
	if (me.nRebateMultiple == 0) then
		return;
	end
	
	self:SetRetLevel(me, 0, 0);
	
	self:WriteLog(Dbg.LOG_ATTENTION, me.szAccount, me.szName, "Disable Account!")
end

if (not jbreturn.nLoginId) then
	PlayerSchemeEvent:RegisterGlobalDailyEvent({jbreturn.ResetDailyLimit, jbreturn});
	PlayerSchemeEvent:RegisterGlobalMonthEvent({jbreturn.ResetMonthLimit, jbreturn});
	jbreturn.nLoginId = PlayerEvent:RegisterGlobal("OnLogin", "jbreturn:_OnLogin");
end
