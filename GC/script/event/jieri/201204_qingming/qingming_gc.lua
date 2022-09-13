--
-- FileName: qingming_gc.lua
-- Author: 
-- Time: 2012/4/5 10:53
-- Comment:
--
if not MODULE_GC_SERVER then
	return 0;
end

Require("\\script\\event\\jieri\\201204_qingming\\qingming_def.lua");

local tbQingMing2012 = SpecialEvent.tbQingMing2012;

--每日领取数据清除
function SpecialEvent:ClearQingming2012_GC()
	local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
	if nNowTime >= tbQingMing2012.nStartTime and nNowTime < tbQingMing2012.nEndTime then
		tbQingMing2012.tbKinGet = {};
		GlobalExcute({"SpecialEvent.tbQingMing2012:ClearKinGet_GS"});
	end
end

--同步家族领取信息到GS
function tbQingMing2012:UpdateKinGet_GC(nKinId, nValue)
	self.tbKinGet[nKinId] = nValue;
	GlobalExcute({"SpecialEvent.tbQingMing2012:UpdateKinGet_GS", nKinId, nValue});
end

--GS连接事件
function tbQingMing2012:OnRecConnectEvent(nConnectId)
	for nKinId, nValue in pairs(self.tbKinGet) do
		GSExcute(nConnectId, {"SpecialEvent.tbQingMing2012:UpdateKinGet_GS", nKinId, nValue});
	end
end

--注册GS连接事件
GCEvent:RegisterGS2GCServerStartFunc(SpecialEvent.tbQingMing2012.OnRecConnectEvent, SpecialEvent.tbQingMing2012);
