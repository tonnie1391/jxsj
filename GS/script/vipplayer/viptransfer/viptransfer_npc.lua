-------------------------------------------------------
-- 文件名　：viptransfer_npc.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-11-19 11:23:04
-- 文件描述：
-------------------------------------------------------

Require("\\script\\vipplayer\\viptransfer\\viptransfer_def.lua");

local tbNpc = {};
VipPlayer.VipTransfer.DialogNpc = tbNpc;

-- 对话框
function tbNpc:OnDialog()
	
	local szMsg = "恭喜您获得VIP转服资格，在这里可以完成转服申请。";
	local tbOpt = {};
	
	local nQualification = VipPlayer.VipTransfer:CheckQualification(me);
	
	if nQualification == 1 then
		tbOpt = {{"<color=yellow>申请转服<color>", self.ApplyTransfer, self}};
		
	elseif nQualification == 2 then
		tbOpt = {{"<color=yellow>领取转服奖励<color>", self.GetAward, self}};
	
	elseif nQualification == 3 then
		tbOpt = {{"<color=yellow>领取后续奖励<color>", self.GetRemainAward, self}};
	end
	
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg, tbOpt);
end

-- 转服申请
function tbNpc:ApplyTransfer()
	
	if true then
		Dialog:Say("旧版内部转服已经关闭，敬请期待新版。");
		return 0;
	end
	
	if VipPlayer.VipTransfer:GetTransferRate(me) <= 0 then
		Dialog:Say("你没有申请转服的资 ô.");
		return 0;
	end
	
	-- 密码锁
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("你的账号处于锁定状态，无法完成申请。");
		return 0;
	end
	
	local szGateway = me.GetTaskStr(VipPlayer.VipTransfer.TASK_GROUP_ID, VipPlayer.VipTransfer.TASK_TRANS_GATEWAY);
	if szGateway ~= "" then
		local nGateId = tonumber(string.sub(szGateway, 5, 6));
		if VipPlayer.VipTransfer.tbServerName[nGateId] then
			return self:OnSelectServer(nGateId, szGateway);
		end
	end
	
	local szMsg = "您打算转往哪个大区？";
	local tbOpt = {};
	
	for nGateId, tbInfo in pairs(VipPlayer.VipTransfer.tbServerName) do
		tbOpt[#tbOpt + 1] = {string.format("<color=green>%s<color>", tbInfo.szZoneName), self.OnSelectGate, self, nGateId};
	end
	
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg, tbOpt);
end

-- 选择大区后
function tbNpc:OnSelectGate(nGateId)
	
	local szMsg = string.format("您打算转往<color=yellow>[%s]<color>下哪个服务器？", VipPlayer.VipTransfer.tbServerName[nGateId].szZoneName);
	local tbOpt = {};
	
	for szGateway, szServerName in pairs(VipPlayer.VipTransfer.tbServerName[nGateId]) do
		if szGateway ~= "szZoneName" then
			tbOpt[#tbOpt + 1] = {string.format("<color=green>%s<color>", szServerName), self.OnSelectServer, self, nGateId, szGateway};
		end
	end
	
	tbOpt[#tbOpt + 1] = {"Quay lại", self.ApplyTransfer, self};
	Dialog:Say(szMsg, tbOpt);	
end

-- 选择服务器后
function tbNpc:OnSelectServer(nGateId, szGateway)
	local szAccount = me.GetTaskStr(VipPlayer.VipTransfer.TASK_GROUP_ID, VipPlayer.VipTransfer.TASK_TRANS_ACCOUNT);
	if szAccount ~= "" then
		return self:OnEnterAccount(nGateId, szGateway, szAccount);
	end
	Dialog:AskString("请输入通行证：", 10, self.OnEnterAccount, self, nGateId, szGateway);
end

-- 输入通行证后
function tbNpc:OnEnterAccount(nGateId, szGateway, szAccount)
	
	if szAccount == "" then
		szAccount = me.szAccount;
	end
	
	szAccount = string.lower(szAccount);
	
	local szMsg = string.format("您确定转往区服<color=yellow>[%s-%s]<color>，转入通行证：<color=yellow>%s<color>", 
		VipPlayer.VipTransfer.tbServerName[nGateId].szZoneName, VipPlayer.VipTransfer.tbServerName[nGateId][szGateway], szAccount);
	
	local tbValue = VipPlayer.VipTransfer:CalculateValue(me);
	local szValue = string.format([[
绑定价值量：<color=green>%s<color>
不绑定价值量：<color=green>%s<color>
]], tbValue.nBindValue, tbValue.nNoBindValue);

	szMsg = szMsg .. "\n\n" .. szValue;
	
	local tbOpt =
	{
		{"Xác nhận", self.OnConfirm, self, szAccount, szGateway},
		{"Để ta suy nghĩ thêm"},
	};
	Dialog:Say(szMsg, tbOpt);
end

-- 确定转服
function tbNpc:OnConfirm(szAccount, szGateway)
	
	local tbInfo = {};
	local tbValue = VipPlayer.VipTransfer:CalculateValue(me);
	
	tbInfo.nBindValue = tbValue.nBindValue;
	tbInfo.nNoBindValue = tbValue.nNoBindValue;
	tbInfo.szNewAccount = szAccount;
	tbInfo.szNewGateway = szGateway;
	tbInfo.tbRepute = tbValue.tbRepute;
	tbInfo.nExtPoint = 0;
	
	-- 记录日期
	tbInfo.nApplyTime = GetTime();
	
	-- 扩展点(同账号才转移)
	if szAccount == me.szAccount then
		tbInfo.nExtPoint = math.mod(math.floor(me.GetExtPoint(7) / 10000), 100);
	end
	
	-- 增加数据项
	VipPlayer.VipTransfer:AddApplyOut_GS(me.szName, GetGatewayName(), szGateway, tbInfo);
	
	-- 设置任务变量
	me.SetTask(VipPlayer.VipTransfer.TASK_GROUP_ID, VipPlayer.VipTransfer.TASK_QUALIFICATION, 0);
	me.SetTask(VipPlayer.VipTransfer.TASK_GROUP_ID, VipPlayer.VipTransfer.TASK_TRANS_APPLY, 1);
	
	-- 记本地log
	Dbg:WriteLog("VipTransfer", "Vip转服申请", me.szAccount, me.szName, "绑定价值量："..tbInfo.nBindValue, "不绑定价值量："..tbInfo.nNoBindValue,
		"转向账号："..tbInfo.szNewAccount, "转向网关："..tbInfo.szNewGateway, "保留声望数量："..#tbInfo.tbRepute, "扩展点："..tbInfo.nExtPoint);
		
	me.Msg("你已经顺利完成转服申请！");
	
	-- 账号冻结
	Player:Freeze(me);
end

-- 领取转服奖励
function tbNpc:GetAward()
	
	if VipPlayer.VipTransfer:CheckGetAward(me) ~= 1 then
		return 0;
	end
	
	local szMsg = string.format("您的转服奖励如下：\n\n" 
		.."<color=yellow>\t绑定金币：\t%d\n<color>" 
		.."<color=yellow>\t绑定银两：\t%d\n<color>" 
		.."<color=yellow>\t银两：\t%d\n<color>",
		VipPlayer.VipTransfer.tbGlobalBuffer.tbApplyIn[me.szAccount].nBindCoin,
		VipPlayer.VipTransfer.tbGlobalBuffer.tbApplyIn[me.szAccount].nBindMoney,
		VipPlayer.VipTransfer.tbGlobalBuffer.tbApplyIn[me.szAccount].nMoney
		);
		
	local tbOpt = 
	{
		{"确定领取", self.OnGetAward, self},
		{"Ta hiểu rồi"},
	}
	Dialog:Say(szMsg, tbOpt);
end

-- 确定领取
function tbNpc:OnGetAward()
	
	if VipPlayer.VipTransfer:CheckGetAward(me) ~= 1 then
		return 0;
	end
	
	-- 先提升等级
	self:SetTransLevel();
	
	-- 处理扩展点
	local nCurExtPoint = math.mod(math.floor(me.GetExtPoint(7) / 10000), 100);
	local nExtPoint = VipPlayer.VipTransfer.tbGlobalBuffer.tbApplyIn[me.szAccount].nExtPoint;
	if nExtPoint > nCurExtPoint then
		me.AddExtPoint(7, (nExtPoint - nCurExtPoint) * 10000);
	end
	
	local nBindCoin = VipPlayer.VipTransfer.tbGlobalBuffer.tbApplyIn[me.szAccount].nBindCoin;
	local nBindMoney = VipPlayer.VipTransfer.tbGlobalBuffer.tbApplyIn[me.szAccount].nBindMoney;
	local nMoney = VipPlayer.VipTransfer.tbGlobalBuffer.tbApplyIn[me.szAccount].nMoney;
	local tbRepute = VipPlayer.VipTransfer.tbGlobalBuffer.tbApplyIn[me.szAccount].tbRepute;
		
	-- 直接领取
	if nBindCoin > 0 then
		me.AddBindCoin(nBindCoin, Player.emKBINDCOIN_ADD_VIP_TRANSFER);
	end
	
	-- 超上限的记任务变量
	if nBindMoney > 0 then
		if nBindMoney + me.GetBindMoney() > me.GetMaxCarryMoney() then
			me.SetTask(VipPlayer.VipTransfer.TASK_GROUP_ID, VipPlayer.VipTransfer.TASK_BIND_MONEY, nBindMoney);
			me.Msg("领取后您身上的绑定银两将会超出上限，请整理后再来。");
		else
			me.AddBindMoney(nBindMoney, Player.emKBINDMONEY_ADD_VIP_TRANSFER);
		end
	end
	
	-- 超上限的记任务变量
	if nMoney > 0 then
		if nMoney + me.nCashMoney > me.GetMaxCarryMoney() then
			me.SetTask(VipPlayer.VipTransfer.TASK_GROUP_ID, VipPlayer.VipTransfer.TASK_MONEY, nMoney);
			me.Msg("领取后您身上的银两将会超出上限，请整理后再来。");
		else
			me.Earn(nMoney, Player.emKEARN_VIP_TRANSFER);
		end
	end
	
	-- 开服时间(秒)
	local nOpenTime = GetTime() - KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	for nKey, tbRow in pairs(tbRepute or {}) do
		
		local nCamp = tbRow[1];
		local nClass = tbRow[2];
		local nLevel = tbRow[3]
		local nRepute = tbRow[4];
		
		local nIndex = VipPlayer.VipTransfer:GetReputeIndex(nCamp, nClass);
		if nIndex ~= 0 then
			
			local nCurLevel = me.GetReputeLevel(nCamp, nClass);
			local nCurRepute = me.GetReputeValue(nCamp, nClass);	
			if nLevel > nCurLevel or (nLevel == nCurLevel and nRepute > nCurRepute) then
	
				-- 满足开服时间，直接加上
				if nOpenTime >= VipPlayer.VipTransfer.tbReputeName[nIndex][2] * 60 * 60 * 24 then		
					me.SetReputeLevelAndValue(nCamp, nClass, nLevel, nRepute);
					me.Msg(string.format("您的<color=yellow>%s<color>已经提升至<color=yellow>%s级<color>", VipPlayer.VipTransfer.tbReputeName[nIndex][1], nLevel));
				
				-- 否则存任务变量
				else
					local nTaskId = VipPlayer.VipTransfer.TASK_REPUTE[nIndex];
					VipPlayer.VipTransfer:SetReputeTask(me, nTaskId, nCamp, nClass, nLevel, nRepute);
					me.Msg(string.format("您的<color=green>%s<color>暂时不满足领取条件，请稍后再来。", VipPlayer.VipTransfer.tbReputeName[nIndex][1]));
				end
			end
		end
	end
	
	-- 领取标记
	me.SetTask(VipPlayer.VipTransfer.TASK_GROUP_ID, VipPlayer.VipTransfer.TASK_TRANS_GETAWARD, 1);
	
	-- 记本地log
	Dbg:WriteLog("VipTransfer", "Vip转服领奖", me.szAccount, me.szName, "绑定金币："..nBindCoin, "绑定银两："..nBindMoney,
		"银两："..nMoney, "等级："..me.nLevel, "保留声望数量："..#tbRepute);
	
	-- 清掉数据表
	GCExcute({"VipPlayer.VipTransfer:RemoveApplyIn_GC", me.szAccount});
end

-- 领取未完奖励
function tbNpc:GetRemainAward()
	
	-- 密码锁
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("你的账号处于锁定状态，无法领取奖励。");
		return 0;
	end
	
	local tbOpt = {};
	local szMsg = "下列奖励需要满足开服时间限制，请确认后再来领取。";
	
	local nBindMoney = me.GetTask(VipPlayer.VipTransfer.TASK_GROUP_ID, VipPlayer.VipTransfer.TASK_BIND_MONEY);
	local nMoney = me.GetTask(VipPlayer.VipTransfer.TASK_GROUP_ID, VipPlayer.VipTransfer.TASK_MONEY);
	
	if nBindMoney > 0 then
		tbOpt[#tbOpt + 1] = {"领取绑定银两", self.OnGetRemainBindMoney, self};
	end
	
	if nMoney > 0 then
		tbOpt[#tbOpt + 1] = {"领取银两", self.OnGetRemainMoney, self};
	end
	
	-- 领过的就不显示了
	for nIndex, nTaskId in pairs(VipPlayer.VipTransfer.TASK_REPUTE) do
		local nCamp, nClass, nLevel, nRepute = VipPlayer.VipTransfer:LoadReputeTask(me, nTaskId);
		if nLevel + nRepute > 1 then
			tbOpt[#tbOpt + 1] = {VipPlayer.VipTransfer.tbReputeName[nIndex][1], self.OnGetRemainRepute, self, nIndex};
		end
	end
	
	tbOpt[#tbOpt + 1] = {"Ta hiểu rồi"};
	Dialog:Say(szMsg, tbOpt);
end

-- 领取绑银
function tbNpc:OnGetRemainBindMoney()
	
	local nBindMoney = me.GetTask(VipPlayer.VipTransfer.TASK_GROUP_ID, VipPlayer.VipTransfer.TASK_BIND_MONEY);
	if nBindMoney <= 0 then
		return 0;
	end
	
	if nBindMoney + me.GetBindMoney() > me.GetMaxCarryMoney() then
		
		-- 领取到上限
		local nTmpBindMoney = me.GetMaxCarryMoney() - me.GetBindMoney();
		me.AddBindMoney(nTmpBindMoney, Player.emKBINDMONEY_ADD_VIP_TRANSFER);
		nBindMoney = nBindMoney - nTmpBindMoney;
		
		-- 记录下剩余的
		me.SetTask(VipPlayer.VipTransfer.TASK_GROUP_ID, VipPlayer.VipTransfer.TASK_BIND_MONEY, nBindMoney);
		Dialog:Say(string.format("剩下的<color=yellow>%s<color>绑定银两，请满足携带银两上限后再来领取。", nBindMoney));
	else
		me.AddBindMoney(nBindMoney, Player.emKBINDMONEY_ADD_VIP_TRANSFER);
		me.SetTask(VipPlayer.VipTransfer.TASK_GROUP_ID, VipPlayer.VipTransfer.TASK_BIND_MONEY, 0);
	end
end

-- 领取银两
function tbNpc:OnGetRemainMoney()
	
	local nMoney = me.GetTask(VipPlayer.VipTransfer.TASK_GROUP_ID, VipPlayer.VipTransfer.TASK_MONEY);
	if nMoney <= 0 then
		return 0;
	end
	
	if nMoney + me.nCashMoney > me.GetMaxCarryMoney() then
		
		-- 领取到上限
		local nTmpMoney = me.GetMaxCarryMoney() - me.nCashMoney;
		me.Earn(nTmpMoney, Player.emKEARN_VIP_TRANSFER);
		nMoney = nMoney - nTmpMoney;
		
		-- 记录下剩余的
		me.SetTask(VipPlayer.VipTransfer.TASK_GROUP_ID, VipPlayer.VipTransfer.TASK_MONEY, nMoney);
		Dialog:Say(string.format("剩下的<color=yellow>%s<color>银两，请满足携带银两上限后再来领取。", nMoney));
	else
		me.Earn(nMoney, Player.emKEARN_VIP_TRANSFER);
		me.SetTask(VipPlayer.VipTransfer.TASK_GROUP_ID, VipPlayer.VipTransfer.TASK_MONEY, 0);
	end
end

-- 领取后续声望
function tbNpc:OnGetRemainRepute(nIndex)
	
	-- 开服时间
	local nOpenTime = GetTime() - KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	local nDay = VipPlayer.VipTransfer.tbReputeName[nIndex][2];
	local nTaskId = VipPlayer.VipTransfer.TASK_REPUTE[nIndex];
	local nCamp, nClass, nLevel, nRepute = VipPlayer.VipTransfer:LoadReputeTask(me, nTaskId);
	
	if nOpenTime >= nDay * 60 * 60 * 24  then
		local nCurLevel = me.GetReputeLevel(nCamp, nClass);
		local nCurRepute = me.GetReputeValue(nCamp, nClass);
		if nLevel > nCurLevel or (nLevel == nCurLevel and nRepute > nCurRepute) then
			me.SetReputeLevelAndValue(nCamp, nClass, nLevel, nRepute);	
			me.Msg(string.format("您的<color=yellow>%s<color>已经提升至<color=yellow>%s级<color>", VipPlayer.VipTransfer.tbReputeName[nIndex][1], nLevel));
		end
		me.SetTask(VipPlayer.VipTransfer.TASK_GROUP_ID, nTaskId, 0);
	else
		local nValue = VipPlayer.VipReborn:GetReputeValue(nCamp, nClass, nLevel);
		local szMsg = string.format("服务器开服时间不满%s天，暂时无法领取该项声望，你可以选择兑换为绑金：<color=yellow>%s<color>", nDay, nValue * 80);
		local tbOpt =
		{
			{"我要兑换", self.ChangeBindCoin, self, nIndex},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
	end
end

function tbNpc:ChangeBindCoin(nIndex)
	local nTaskId = VipPlayer.VipTransfer.TASK_REPUTE[nIndex];
	local nCamp, nClass, nLevel, nRepute = VipPlayer.VipTransfer:LoadReputeTask(me, nTaskId);
	local nValue = VipPlayer.VipReborn:GetReputeValue(nCamp, nClass, nLevel);
	me.AddBindCoin(nValue * 80, Player.emKBINDCOIN_ADD_VIP_TRANSFER);
	me.SetTask(VipPlayer.VipTransfer.TASK_GROUP_ID, nTaskId, 0);
end

-- 提升等级
function tbNpc:SetTransLevel()
	
	-- 服务器等级上限150级
	if TimeFrame:GetState("OpenLevel150") == 1 then
		
		-- 开服时间
		local nOpenTime = GetTime() - KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
		
		-- 对应提升等级
		for i = 1, #VipPlayer.VipTransfer.tbTimeLevel do
			local tbLevel = VipPlayer.VipTransfer.tbTimeLevel[i];
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
