-------------------------------------------------------
-- 文件名　：viptransfer_gc.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-11-19 11:18:49
-- 文件描述：
-------------------------------------------------------

Require("\\script\\vipplayer\\viptransfer\\viptransfer_def.lua");

if (not MODULE_GC_SERVER) then
	return 0;
end

local tbVipTransfer = VipPlayer.VipTransfer;

-- 保存数据
function tbVipTransfer:SaveBuffer_GC()
	SetGblIntBuf(GBLINTBUF_VIP_TRANSFER, 0, 1, self.tbGlobalBuffer);
	self:SyncBuffer_GC();
end

-- 清除数据
function tbVipTransfer:ClearBuffer_GC()
	self.tbGlobalBuffer = {tbApplyOut = {}, tbApplyIn = {}};
	SetGblIntBuf(GBLINTBUF_VIP_TRANSFER, 0, 1, self.tbGlobalBuffer);
	GlobalExcute({"VipPlayer.VipTransfer:ClearBuffer_GS"});
end

-- 同步给gameserver
function tbVipTransfer:SyncBuffer_GC()
	
	-- 先把所有的都清掉
	GlobalExcute({"VipPlayer.VipTransfer:ClearBuffer_GS"});
	
	-- 同步转出表
	for szPlayerName, tbInfo in pairs(self.tbGlobalBuffer.tbApplyOut) do
		GlobalExcute({"VipPlayer.VipTransfer:SyncBufferOut_GS", szPlayerName, tbInfo});
	end
	
	--同步转入表
	for szAccount, tbInfo in pairs(self.tbGlobalBuffer.tbApplyIn) do
		GlobalExcute({"VipPlayer.VipTransfer:SyncBufferIn_GS", szAccount, tbInfo});
	end
end

-- gameserver连接时同步
function tbVipTransfer:OnRecConnectEvent(nConnectId)
	
	-- 同步转出表
	for szPlayerName, tbInfo in pairs(self.tbGlobalBuffer.tbApplyOut) do
		GSExcute(nConnectId, {"VipPlayer.VipTransfer:SyncBufferOut_GS", szPlayerName, tbInfo});
	end
	
	--同步转入表
	for szAccount, tbInfo in pairs(self.tbGlobalBuffer.tbApplyIn) do
		GSExcute(nConnectId, {"VipPlayer.VipTransfer:SyncBufferIn_GS", szAccount, tbInfo});
	end
end

-- 增加转出数据项
function tbVipTransfer:AddApplyOut_GC(szPlayerName, szOrgGateway, szDstGateway, tbInfo)
	if not self.tbGlobalBuffer.tbApplyOut[szPlayerName] then
		self.tbGlobalBuffer.tbApplyOut[szPlayerName] = tbInfo;
	end
	self:SaveBuffer_GC();
	local szData = self:GetApplyOut_GC(szPlayerName);
	if szData then
		GC2GCExecute(szDstGateway, {"VipPlayer.VipTransfer:SetApplyIn_GC", szOrgGateway, szData});
	end
end

-- 删除转出数据项
function tbVipTransfer:RemoveApplyOut_GC(szPlayerName)
	if self.tbGlobalBuffer.tbApplyOut[szPlayerName] then
		self.tbGlobalBuffer.tbApplyOut[szPlayerName] = nil;
	end
	self:SaveBuffer_GC();
end

-- 增加转入数据项
function tbVipTransfer:AddApplyIn_GC(szAccount, tbInfo)
	if not self.tbGlobalBuffer.tbApplyIn[szAccount] then
		self.tbGlobalBuffer.tbApplyIn[szAccount] = tbInfo;
	end
	self:SaveBuffer_GC();
end

-- 删除转入数据项
function tbVipTransfer:RemoveApplyIn_GC(szAccount)
	if self.tbGlobalBuffer.tbApplyIn[szAccount] then
		self.tbGlobalBuffer.tbApplyIn[szAccount] = nil;
	end
	self:SaveBuffer_GC();
end

-- 平台取出申请数据(字符串)
function tbVipTransfer:GetApplyOut_GC(szPlayerName)
	
	-- 找数据项
	local tbApplyOut = self.tbGlobalBuffer.tbApplyOut[szPlayerName];
	
	-- 找到则转成字符串
	if tbApplyOut then
		local tbMap = {};
		for _, tbPiece in pairs(tbApplyOut.tbRepute) do
			table.insert(tbMap, Lib:ConcatStr(tbPiece, "*"));
		end
		local szMap = Lib:ConcatStr(tbMap, "|");
		local tbData = 
		{
			tbApplyOut.szNewAccount, 
			tbApplyOut.szNewGateway, 
			tbApplyOut.nBindValue * 95,
			tbApplyOut.nBindValue * 5 * math.max(100, KJbExchange.GetPrvAvgPrice()),
			tbApplyOut.nNoBindValue,
			tbApplyOut.nExtPoint,
			szMap,
		};
		local szData = Lib:ConcatStr(tbData);
		return szData;
	end
	
	return nil;
--	return "找不到该角色的申请数据";
end

-- 平台导入申请数据(字符串)
function tbVipTransfer:SetApplyIn_GC(szOrgGateway, szData)
	
	-- 验证数据列数
	local tbData = Lib:SplitStr(szData, ",");
	if Lib:CountTB(tbData) ~= 7 then
		return 0;
--		return "数据格式错误，导入失败";
	end
	
	-- 格式化字符串
	local tbInfo = {};
	local szAccount = tostring(tbData[1]);
	tbInfo.szNewGateway = tostring(tbData[2]);
	tbInfo.nBindCoin = tonumber(tbData[3]);
	tbInfo.nBindMoney = tonumber(tbData[4]);
	tbInfo.nMoney = tonumber(tbData[5]) * math.max(100, KJbExchange.GetPrvAvgPrice()) * 100;
	tbInfo.nExtPoint = tonumber(tbData[6]);
	tbInfo.tbRepute = {};
	
	-- 记录日期
	tbInfo.nApplyTime = GetTime();

	local tbMap = Lib:SplitStr(tbData[7], "|");
	for _, tbPiece in pairs(tbMap) do
		local tbTmp = Lib:SplitStr(tbPiece, "*");
		table.insert(tbInfo.tbRepute, {tonumber(tbTmp[1]), tonumber(tbTmp[2]), tonumber(tbTmp[3]), tonumber(tbTmp[4])});
	end
	
	-- 验证网关
	if tbInfo.szNewGateway ~= GetGatewayName() then
		return 0;
--		return "网关不匹配，导入失败";
	end
	
	-- 成功返回1
	self:AddApplyIn_GC(szAccount, tbInfo);
	GC2GCExecute(szOrgGateway, {"VipPlayer.VipTransfer:TransferSuccess_GC"});
	return 1;
end

-- 转服成功
function tbVipTransfer:TransferSuccess_GC()
	--
end

-- 启动时载入数据表
function tbVipTransfer:StartEvent()
	
	--载入global buffer
	local tbBuffer = GetGblIntBuf(GBLINTBUF_VIP_TRANSFER, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbGlobalBuffer = tbBuffer;
	end
	
	-- 计划任务
	local nTaskId = KScheduleTask.AddTask("Vip转服过期数据清理", "VipPlayer", "ClearExpireData");
	KScheduleTask.RegisterTimeTask(nTaskId, 1400, 1);
end

-- 清理过期数据
function VipPlayer:ClearExpireData()
		
	-- 清理转出表
	for szPlayerName, tbInfo in pairs(VipPlayer.VipTransfer.tbGlobalBuffer.tbApplyOut) do
		if GetTime() - tbInfo.nApplyTime > 30 * 24 * 60 * 60 then
			VipPlayer.VipTransfer.tbGlobalBuffer.tbApplyOut[szPlayerName] = nil;
		end
	end
	
	-- 清理转入表
	for szAccount, tbInfo in pairs(VipPlayer.VipTransfer.tbGlobalBuffer.tbApplyIn) do
		if GetTime() - tbInfo.nApplyTime > 30 * 24 * 60 * 60 then
			VipPlayer.VipTransfer.tbGlobalBuffer.tbApplyIn[szAccount] = nil;
		end
	end
	
	VipPlayer.VipTransfer:SaveBuffer_GC();
end

-- 合服操作
function tbVipTransfer:CombineMainAndSubBuf(tbSubBuf)
	
	if (not tbSubBuf) then
		return 0;
	end
	
	local tbBuffer = GetGblIntBuf(GBLINTBUF_VIP_TRANSFER, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbGlobalBuffer = tbBuffer;
	end
	
-- tbApplyOut[szPlayerName] = 
-- {szNewAccount = "", nNewGateId = 0, nBindValue = 0, nNoBindValue = 0, tbRepute = {}}
-- tbApplyIn[szAccount] = 
-- {nNewGateId, nBindCoin = 0, nBindMoney = 0, nMoney = 0, tbRepute = {}};	

	if (not self.tbGlobalBuffer) then
		self.tbGlobalBuffer = {};
	end
	
	if (not self.tbGlobalBuffer.tbApplyIn) then
		self.tbGlobalBuffer.tbApplyIn = {};
	end

	if (not self.tbGlobalBuffer.tbApplyOut) then
		self.tbGlobalBuffer.tbApplyOut = {};
	end

	if (tbSubBuf.tbApplyIn) then
		for szAccount, tbInfo in pairs(tbSubBuf.tbApplyIn) do
			self.tbGlobalBuffer.tbApplyIn[szAccount] = tbInfo;
		end
	end

	if (tbSubBuf.tbApplyOut) then
		for szPlayerName, tbInfo in pairs(tbSubBuf.tbApplyOut) do
			self.tbGlobalBuffer.tbApplyOut[szPlayerName] = tbInfo;
		end
	end
	
	self:SaveBuffer_GC();
end

-- 注册gamecenter启动事件
GCEvent:RegisterGCServerStartFunc(VipPlayer.VipTransfer.StartEvent, VipPlayer.VipTransfer);
