-------------------------------------------------------
-- 文件名　：vipreborn_npc.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-02-23 12:24:32
-- 文件描述：
-------------------------------------------------------

Require("\\script\\vipplayer\\VipReborn\\VipReborn_def.lua");

local tbVipReborn = VipPlayer.VipReborn;
local tbNpc = tbVipReborn.Npc or {};
tbVipReborn.Npc = tbNpc;

-- 对话框
function tbNpc:OnDialog()
	
	local szMsg = "恭喜您获得VIP转服资格，在这里可以完成转服申请。";
	local tbOpt = {};
	
	local nQualification = tbVipReborn:CheckQualification(me);
	
	if nQualification == 1 then
		tbOpt = {{"<color=yellow>申请转服<color>", self.ApplyReborn, self}};
		
	elseif nQualification == 2 then
		tbOpt = {{"<color=yellow>完成转服<color>", self.FinishReborn, self}};
	
	elseif nQualification == 3 then
		tbOpt = {{"<color=yellow>领取转服奖励<color>", self.GetAward, self}};
	
	elseif nQualification == 4 then
		tbOpt = {{"<color=yellow>旧版转服奖励<color>", VipPlayer.VipTransfer.DialogNpc.GetRemainAward, VipPlayer.VipTransfer.DialogNpc}};
	end
	
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg, tbOpt);
end

-- 转服申请
function tbNpc:ApplyReborn(nSure)

	if tbVipReborn:GetTransferRate(me) <= 0 then
		Dialog:Say("你没有申请转服的资 ô.");
		return 0;
	end
	
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("你的账号处于锁定状态，无法完成申请。");
		return 0;
	end
	
	local nFinish = me.GetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_REBORN_FINISH);
	if nFinish == 1 then
		local nTime = me.GetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_REBORN_TIME);
		if GetTime() - nTime < 90 * 24 * 60 * 60 then
			Dialog:Say("对不起，你的角色已经转过服，3个月之内无法再次转服。");
			return 0;
		end
	end
	
	if not nSure then
		local szMsg = string.format([[
    新版vip转服说明，请仔细阅读并点击同意选项！
	
	<color=green>服务条款：
    1、申请后将角色数据折算成价值量
    2、确定账号和区服后完成申请
    3、在新区服建立角色<color=yellow>（60级以下）<color>，完成转服
    4、转服后每月可根据<color=yellow>转服价值量<color>及当月的<color=yellow>充值和额度<color>，兑换绑金、绑银等
    5、转服后的角色，在<color=yellow>三个月<color>内无法再次申请转服
    6、转服后原角色的<color=yellow>内部返还功能<color>将关闭，额度平移至新角色
    7、适度游戏，合理消费，如有严重影响外网玩家的情况，<color=red>将关闭内部返还权限，并冻结角色所有资产！<color>
	]]);
		local tbOpt = 
		{
			{"<color=yellow>同意<color>", self.ApplyReborn, self, 1},
			{"Để ta suy nghĩ thêm"},	
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	local szGateway = me.GetTaskStr(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_GATEWAY);
	if szGateway and szGateway ~= "" then
		local szGateName = ServerEvent:GetGateNameByGateway(szGateway);
		local szServerName = ServerEvent:GetServerNameByGateway(szGateway);
--		if szGateName ~= "未知区" and szServerName ~= "未知服" then
			return self:OnSelectServer(szGateName, szServerName, szGateway);
--		end
	end
	
	local tbOpt = {};
	local szMsg = "您打算转往哪个大区？";
	local tbServerName = ServerEvent:GetServerNameList();
	for szGateName, _ in pairs(tbServerName) do
		if szGateName ~= "测试区" then
			tbOpt[#tbOpt + 1] = {string.format("<color=green>%s<color>", szGateName), self.OnSelectGate, self, szGateName};
		end
	end
	
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg, tbOpt);
end

-- 选择大区后
function tbNpc:OnSelectGate(szGateName)
	
	local tbOpt = {};
	local szMsg = string.format("您打算转往<color=yellow>[%s]<color>下哪个服务器？", szGateName);
	
	local tbServerName = ServerEvent:GetServerNameList();
	if not tbServerName[szGateName] then
		return 0;
	end
	
	for szServerName, szGateway in pairs(tbServerName[szGateName]) do
		if ServerEvent:CheckIsMainServer(szServerName, szGateway) == 1 then
			tbOpt[#tbOpt + 1] = {string.format("<color=green>%s<color>", szServerName), self.OnSelectServer, self, szGateName, szServerName, szGateway};
		end
	end
	
	tbOpt[#tbOpt + 1] = {"Quay lại", self.ApplyReborn, self};
	Dialog:Say(szMsg, tbOpt);	
end

-- 选择服务器后
function tbNpc:OnSelectServer(szGateName, szServerName, szGateway)
	
	local szAccount = me.GetTaskStr(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_ACCOUNT);
	if szAccount and szAccount ~= "" then
		return self:OnEnterAccount(szGateName, szServerName, szGateway, szAccount);
	end
	
	Dialog:AskString("请输入通行证：", 20, self.OnEnterAccount, self, szGateName, szServerName, szGateway);
end

-- 输入通行证后
function tbNpc:OnEnterAccount(szGateName, szServerName, szGateway, szAccount)
	
	local tbValue = tbVipReborn:CalculateValue(me);
	szAccount = (szAccount == "") and me.szAccount or string.lower(szAccount);
	
	-- 实在领不完了，优先转移这部分
	local nSpec = 0;
	local nBindValue = me.GetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_BIND_VALUE);
	local nNobindValue = me.GetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_NOBIND_VALUE);
	if me.GetHonorLevel() >= 10 and nBindValue >= 80000 then
		tbValue.nBindValue = nBindValue;
		tbValue.nNobindValue = nNobindValue;
		nSpec = 1;
	end
	
	local szMsg = string.format([[您确定转往区服<color=yellow>[%s-%s]<color>
网关标识为：<color=yellow>%s<color>
转入通行证：<color=yellow>%s<color>

绑定价值量：<color=green>%s<color>
不绑定价值量：<color=green>%s<color>	
]], szGateway, szGateName, szServerName, szAccount, tbValue.nBindValue, tbValue.nNobindValue);
	
	local tbOpt =
	{
		{"Xác nhận", self.OnConfirm, self, szAccount, szGateway, nSpec},
		{"Để ta suy nghĩ thêm"},
	};
	Dialog:Say(szMsg, tbOpt);
end

-- 确定转服
function tbNpc:OnConfirm(szAccount, szGateway, nSpec)
	
	local tbValue = tbVipReborn:CalculateValue(me);
	if nSpec == 1 then
		local nBindValue = me.GetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_BIND_VALUE);
		local nNobindValue = me.GetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_NOBIND_VALUE);
		tbValue.nBindValue = nBindValue;
		tbValue.nNobindValue = nNobindValue;
	end
	local nExtPoint = math.mod(math.floor(me.GetExtPoint(7) / 10000), 100)
	local tbData = {szAccount, szGateway, tbValue.nBindValue, tbValue.nNobindValue, nExtPoint};	
	local szData = Lib:ConcatStr(tbData)

	GCExcute({"VipPlayer.VipReborn:ApplyOut_GC", GetGatewayName(), szGateway, szData});
--	GCExcute({"VipPlayer.VipReborn:ApplyIn_GC", GetGatewayName(), szData});
	
	me.Msg("你已经顺利完成转服申请！");
	Dbg:WriteLog("VipReborn", "vip转服申请", me.szAccount, me.szName, "绑定价值量："..tbValue.nBindValue, "不绑定价值量："..tbValue.nNobindValue,
		"转向账号："..szAccount, "转向网关："..szGateway, "扩展点："..nExtPoint);
	
	if nSpec == 1 then
		me.SetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_BIND_VALUE, 0);
		me.SetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_NOBIND_VALUE, 0);
		me.SetTaskStr(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_ACCOUNT, "");
		me.SetTaskStr(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_GATEWAY, "");
	else
		me.SetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_QUALIFICATION, 0);
--		me.PayExtPoint(7, nExtPoint * 10000);
		jbreturn:SetRetLevel(me, 0, 0);
		Player:Freeze(me);
	end
end

-- 完成转服
function tbNpc:FinishReborn()
	
	if tbVipReborn:CheckFinishReborn(me) ~= 1 then
		return 0;
	end
	
	local szMsg = string.format([[完成转服后，您将获得相应的转服价值量，可以根据需要兑换成绑金、绑银、银两。
		
	您的转服价值量为：
<color=yellow>绑定价值量：%d<color>
<color=yellow>非绑价值量：%d<color>
]],	tbVipReborn.tbGlobalBuffer[me.szAccount].nBindValue, tbVipReborn.tbGlobalBuffer[me.szAccount].nNobindValue);
		
	local tbOpt = 
	{
		{"确定领取", self.OnFinishReborn, self},
		{"Ta hiểu rồi"},
	}
	Dialog:Say(szMsg, tbOpt);
end

-- 确定领取
function tbNpc:OnFinishReborn()
	
	if tbVipReborn:CheckFinishReborn(me) ~= 1 then
		return 0;
	end
	
	-- 先提升等级
	self:SetTransLevel();
	
	-- 处理扩展点
	local nCurExtPoint = math.mod(math.floor(me.GetExtPoint(7) / 10000), 100);
	local nExtPoint = tbVipReborn.tbGlobalBuffer[me.szAccount].nExtPoint;
	if nExtPoint > nCurExtPoint then
		me.AddExtPoint(7, (nExtPoint - nCurExtPoint) * 10000);
	end
	
	local nBindValue = tbVipReborn.tbGlobalBuffer[me.szAccount].nBindValue;
	local nNobindValue = tbVipReborn.tbGlobalBuffer[me.szAccount].nNobindValue;
	
	me.SetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_BIND_VALUE, nBindValue);
	me.SetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_NOBIND_VALUE, nNobindValue);
	
	-- 领取标记
	me.SetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_REBORN_FINISH, 1);
	me.SetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_REBORN_TIME, GetTime());
	
	me.Msg("你已经完成转服，请根据需要兑换绑金、绑银、银两。");
	
	-- 记本地log
	Dbg:WriteLog("VipReborn", "vip转服领奖", me.szAccount, me.szName, "绑定价值量："..nBindValue, "非绑价值量："..nNobindValue, "等级："..me.nLevel);
	
	-- 清掉数据表
	GCExcute({"VipPlayer.VipReborn:RemoveApplyIn_GC", me.szAccount});
end

-- 提升等级
function tbNpc:SetTransLevel()
	
	-- 服务器等级上限150级
	if TimeFrame:GetState("OpenLevel150") == 1 then
		
		-- 开服时间
		local nOpenTime = GetTime() - KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
		
		-- 对应提升等级
		for i = 1, #tbVipReborn.tbTimeLevel do
			local tbLevel = tbVipReborn.tbTimeLevel[i];
			if tbLevel and nOpenTime >= tbLevel[1] * 60 * 60 * 24 then
				me.AddLevel(math.max(tbLevel[2] - me.nLevel, 0));
				return 0;
			end
		end
		
		-- 96天
		me.AddLevel(math.max(99 - me.nLevel, 0));
		return 0;	
	end
	
	-- 服务器等级上限99级
	if TimeFrame:GetState("OpenLevel99") == 1 then
		me.AddLevel(math.max(89 - me.nLevel, 0));
		return 0;
	end
	
	-- 服务器等级上限89级
	if TimeFrame:GetState("OpenLevel89") == 1 then
		me.AddLevel(math.max(79 - me.nLevel, 0));
		return 0;
	end
	
	-- 服务器等级上限79级
	if TimeFrame:GetState("OpenLevel79") == 1 then
		me.AddLevel(math.max(69 - me.nLevel, 0));
		return 0;
	end
end

-- 领取转服奖励
function tbNpc:GetAward()
	
	local nMonLimit = 2000;
	local nBindValue = me.GetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_BIND_VALUE);
	local nNobindValue = me.GetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_NOBIND_VALUE);
	
	local nMonthValue = me.GetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_MONTH_VALUE);
	local nFreeValue = math.min(math.min(nMonLimit, me.nMonCharge) * tbVipReborn.MONTH_RATE - nMonthValue, nBindValue);
	if nFreeValue < 0 then
		nFreeValue = 0;
	end
	
	local szMsg = string.format([[您剩余的转服价值量为：
绑定价值量：<color=yellow>%d<color>
非绑价值量：<color=yellow>%d<color>

您本月充值的金币为：<color=yellow>%d<color>
本月可兑的价值量为：<color=yellow>%d<color>
本月已兑的价值量为：<color=yellow>%d<color>
本月未兑的价值量为：<color=yellow>%d<color>
]], nBindValue, nNobindValue, me.nMonCharge * 100, math.min(nMonLimit, me.nMonCharge) * tbVipReborn.MONTH_RATE, nMonthValue, nFreeValue);

	local tbOpt = 
	{
		{"兑换绑金", self.OnGetAward, self, 1, nFreeValue},
		{"兑换绑银", self.OnGetAward, self, 2, nFreeValue},
		{"兑换银两", self.OnGetAward, self, 3, nNobindValue},
		{"Ta hiểu rồi"},	
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnGetAward(nType, nValue)
	
	local tbType = {"绑金", "绑银", "银两"};
	if not tbType[nType] then
		return 0;
	end
	
	if nValue <= 0 then
		Dialog:Say(string.format("对不起。你已经无法再兑换%s了。", tbType[nType]));
		return 0;
	end
	
	Dialog:AskNumber("Nhập số lượng: ", nValue, self.OnGetAwardSure, self, nType);
end

function tbNpc:OnGetAwardSure(nType, nValue, nSure)
	
	local nMonLimit = 2000;
	local nBindValue = me.GetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_BIND_VALUE);
	local nNobindValue = me.GetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_NOBIND_VALUE);
	
	local nMonthValue = me.GetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_MONTH_VALUE);
	local nFreeValue = math.min(math.min(nMonLimit, me.nMonCharge) * tbVipReborn.MONTH_RATE - nMonthValue, nBindValue);
	if nFreeValue < 0 then
		nFreeValue = 0;
	end
	
	local nJbPrice = math.max(100, JbExchange.GetPrvAvgPrice) * 100;	
	local tbType = 
	{
		[1] = {"绑金", 100},
		[2] = {"绑银", nJbPrice},
		[3] = {"银两", nJbPrice},
	};
	
	if not tbType[nType] or nValue <= 0 then
		return 0;
	end
	
	if not nSure then
		local szMsg = string.format("本次兑换消耗价值量：<color=yellow>%s<color>，将获得的%s：<color=yellow>%s<color>，确定么？", nValue, tbType[nType][1], nValue * tbType[nType][2]);
		local tbOpt =
		{
			{"Xác nhận", self.OnGetAwardSure, self, nType, nValue, 1},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	-- 绑金
	if nType == 1 then
		if nValue <= nFreeValue then
			Spreader:IbShopAddConsume(nValue * 50, 1);
			me.AddBindCoin(nValue * 100, Player.emKBINDCOIN_ADD_VIP_TRANSFER);
			me.SetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_BIND_VALUE, nBindValue - nValue);
			me.SetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_MONTH_VALUE, nMonthValue + nValue);
			Dbg:WriteLog("VipReborn", "vip转服兑换", me.szAccount, me.szName, string.format("绑金：%s", nValue * 100));
		end
	
	-- 绑银
	elseif nType == 2 then
		if nValue <= nFreeValue then
			if nValue * nJbPrice + me.GetBindMoney() > me.GetMaxCarryMoney() then
				Dialog:Say("对不起，领取后您身上的绑定银两将会超出上限，请整理后再来领取。");
				return 0;
			end
			Spreader:IbShopAddConsume(nValue * 50, 1);
			me.AddBindMoney(nValue * nJbPrice, Player.emKBINDMONEY_ADD_VIP_TRANSFER);
			me.SetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_BIND_VALUE, nBindValue - nValue);
			me.SetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_MONTH_VALUE, nMonthValue + nValue);
			Dbg:WriteLog("VipReborn", "vip转服兑换", me.szAccount, me.szName, string.format("绑银：%s", nValue * nJbPrice));
		end
		
	-- 银两
	elseif nType == 3 then
		if nValue <= nNobindValue then
			if nValue * nJbPrice + me.nCashMoney > me.GetMaxCarryMoney() then
				Dialog:Say("对不起，领取后您身上的银两将会超出上限，请整理后再来领取。");
				return 0;
			end
			me.Earn(nValue * nJbPrice, Player.emKEARN_VIP_TRANSFER);
			me.SetTask(tbVipReborn.TASK_GROUP_ID, tbVipReborn.TASK_NOBIND_VALUE, nNobindValue - nValue);
			Dbg:WriteLog("VipReborn", "vip转服兑换", me.szAccount, me.szName, string.format("银两：%s", nValue * nJbPrice));	
		end
	end
end

