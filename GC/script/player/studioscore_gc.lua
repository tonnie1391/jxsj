--
-- FileName: studioscore_gc.lua
-- Author: hanruofei
-- Time: 2011/6/23 14:34
-- Comment:
--

if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\misc\\gcevent.lua");
Require("\\script\\player\\studioscore_def.lua");

StudioScore.nUpdateIpDataTime = 0000;

function StudioScore:LoadIpData()
	self.tbIpData = {}; 
end

-- 拍卖行买入或者卖出都会回调到这
function StudioScore:AuctionTransactionCallback(nSellerId, nBuyerId, szGoodsKey, nCount)
	if not self.bIsOpen then
		return;
	end
	local tbBuyItem = self.tbScoreSetting["buy"][szGoodsKey];
	local tbSellItem = self.tbScoreSetting["sell"][szGoodsKey];
	if (not tbBuyItem or tbBuyItem.Score == 0) and (not tbSellItem or tbSellItem.Score == 0) then
		return
	end
	local szSellerName = KGCPlayer.GetPlayerName(nSellerId);
	local szBuyerName = KGCPlayer.GetPlayerName(nBuyerId);
	GlobalExcute{"StudioScore:AuctionTransactionCallback", szSellerName, szBuyerName, szGoodsKey, nCount};
end

-- 开启角色打分功能
function StudioScore:Open()
	self.bIsOpen = true;
	GlobalExcute{"StudioScore:Open"};
end

-- 关闭角色打分功能
function StudioScore:Close()
	self.bIsOpen = false;
	GlobalExcute{"StudioScore:Close"};
end

-- 每日0点或者GC启动的时候调用到
function StudioScore:OnScheduleCallback()
	self.tbIpData = {};
	GlobalExcute{"StudioScore:SynIpData", self.tbIpData};
end

-- 一个玩家登陆了，记录相关信息，并同步给所有GS
function StudioScore:SynIpDataItem(dwIp, nPlayerId, nServerId)
	local tbDataItem = self.tbIpData[dwIp] or {};
	self.tbIpData[dwIp] = tbDataItem;
	if tbDataItem[nPlayerId] then
		return;
	end
	
	tbDataItem[nPlayerId] = true;
	tbDataItem.nCount = tbDataItem.nCount or 0;
	tbDataItem.nCount = tbDataItem.nCount + 1;
	GlobalExcute{"StudioScore:SynIpDataItem", dwIp, nPlayerId, nServerId};
end

-- GS启动起来了，请求IP地址数据
function StudioScore:RequestIpData(nServerId)
	GlobalExcute{"StudioScore:SynIpData", self.tbIpData};
end

-- GC启动了的回调
function StudioScore:OnGCStart()
	self:LoadIpData();
	local nTaskId = KScheduleTask.AddTask("StudioScore", "StudioScore", "OnScheduleCallback");
	KScheduleTask.RegisterTimeTask(nTaskId, self.nUpdateIpDataTime, 0);
	self:OnScheduleCallback()
end

GCEvent:RegisterGCServerStartFunc(StudioScore.OnGCStart, StudioScore)

