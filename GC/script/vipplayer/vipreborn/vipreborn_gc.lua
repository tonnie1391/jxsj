-------------------------------------------------------
-- 文件名　：vipreborn_gc.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-02-23 12:24:45
-- 文件描述：
-------------------------------------------------------

Require("\\script\\vipplayer\\VipReborn\\VipReborn_def.lua");

if not MODULE_GC_SERVER then
	return 0;
end

local tbVipReborn = VipPlayer.VipReborn;

-------------------------------------------------------
-- buffer
-------------------------------------------------------

-- load
function tbVipReborn:LoadBuffer_GC()
	local tbLoadBuffer = GetGblIntBuf(self.nBufferIndex, 0);
	if tbLoadBuffer and type(tbLoadBuffer) == "table" then
		self.tbGlobalBuffer = tbLoadBuffer;
	end
end

-- save
function tbVipReborn:SaveBuffer_GC()
	SetGblIntBuf(self.nBufferIndex, 0, 1, self.tbGlobalBuffer);
	GlobalExcute({"VipPlayer.VipReborn:LoadBuffer_GS"});
end

-- clear
function tbVipReborn:ClearBuffer_GC()
	self.tbGlobalBuffer = {};
	SetGblIntBuf(self.nBufferIndex, 0, 1, {});
	GlobalExcute({"VipPlayer.VipReborn:ClearBuffer_GS"});
end

-------------------------------------------------------
-- 操作相关
-------------------------------------------------------

-- 申请转出
function tbVipReborn:ApplyOut_GC(szOrgGateway, szDstGateway, szData)
	GC2GCExecute(szDstGateway, {"VipPlayer.VipReborn:ApplyIn_GC", szOrgGateway, szData});
end

-- 申请转入
function tbVipReborn:ApplyIn_GC(szOrgGateway, szData)
		
	-- 验证数据列数
	local tbData = Lib:SplitStr(szData, ",");
	if Lib:CountTB(tbData) ~= 5 then
		Dbg:WriteLog("VipReborn", "vip转服", string.format("数据错误：%s", szData));
		return 0;
	end
	
	-- 格式化字符串
	local tbInfo = {};
	local szAccount = tostring(tbData[1]);
	tbInfo.szNewGateway = tostring(tbData[2]);
	tbInfo.nBindValue = tonumber(tbData[3]);
	tbInfo.nNobindValue = tonumber(tbData[4]);
	tbInfo.nExtPoint = tonumber(tbData[5]);
	
	-- 记录日期
	tbInfo.nApplyTime = GetTime();
	
	-- 验证网关
	if tbInfo.szNewGateway ~= GetGatewayName() then
		Dbg:WriteLog("VipReborn", "vip转服", string.format("网关不匹配：%s", szData), GetGatewayName());
		return 0;
	end
	
	-- 存储数据
	self:AddApplyIn_GC(szAccount, tbInfo);
	
	-- 成功回调
	GC2GCExecute(szOrgGateway, {"VipPlayer.VipReborn:RebornSuccess_GC", szAccount});
end

-- 增加转入数据
function tbVipReborn:AddApplyIn_GC(szAccount, tbInfo)
	self.tbGlobalBuffer[szAccount] = tbInfo;
	self:SaveBuffer_GC();
end

-- 删除转入数据
function tbVipReborn:RemoveApplyIn_GC(szAccount)
	self.tbGlobalBuffer[szAccount] = nil;
	self:SaveBuffer_GC();
end

-- 转服成功
function tbVipReborn:RebornSuccess_GC(szAccount)
	Dbg:WriteLog("VipReborn", "vip转服", string.format("申请成功：%s", szAccount));
end

-- 启动事件
function tbVipReborn:StartEvent_GC()
	
	-- load buffer
	self:LoadBuffer_GC();
	
	-- 计划任务
	local nTaskId = KScheduleTask.AddTask("vip转服过期数据清理", "VipPlayer", "ClearExpireData");
	KScheduleTask.RegisterTimeTask(nTaskId, 1400, 1);
end

-- 清理过期数据
function VipPlayer:ClearExpireData()
	
	for szAccount, tbInfo in pairs(VipPlayer.VipReborn.tbGlobalBuffer) do
		if GetTime() - tbInfo.nApplyTime > 30 * 24 * 60 * 60 then
			VipPlayer.VipReborn.tbGlobalBuffer[szAccount] = nil;
		end
	end
	
	VipPlayer.VipReborn:SaveBuffer_GC();
end

-- 合服操作
function tbVipReborn:CombineBuffer(tbSubBuf)
	
	if not tbSubBuf then
		return 0;
	end
	
	local tbBuffer = GetGblIntBuf(self.nBufferIndex, 0);
	if tbBuffer and type(tbBuffer) == "table" then
		self.tbGlobalBuffer = tbBuffer;
	end
	
	for szAccount, tbInfo in pairs(tbSubBuf) do
		self.tbGlobalBuffer[szAccount] = tbInfo;
	end
	
	self:SaveBuffer_GC();
end

-- 注册gamecenter启动事件
GCEvent:RegisterGCServerStartFunc(VipPlayer.VipReborn.StartEvent_GC, VipPlayer.VipReborn);
