
-- Player GC脚本

-- 帮会商店GC回调
function Player:Buy_GC(nCurrencyType, nCost, nEnergyCost, dwTongId, nSelfKinId, nSelfMemberId, nPlayerId, nBuy, nBuyIndex, nCount)
	local cTong = KTong.GetTong(dwTongId);
	if not cTong then
		return 0;
	end
	
	if nCurrencyType == 9 then
		local nEnergy = cTong.GetEnergy();
		local nEnergyLeft = nEnergy - nEnergyCost * nCount;
		if nEnergyLeft < 0 then 
			return 0;
		end
		if Tong:CostBuildFund_GC(dwTongId, nSelfKinId, nSelfMemberId, nCost * nCount, 0) ~= 1 then
			return 0;
		end
		cTong.SetEnergy(nEnergyLeft);
		GlobalExcute{"Player:Buy_GS2", nCurrencyType, dwTongId, nPlayerId, nBuy, nBuyIndex, nCost, nEnergyLeft, nCount};
	end
end

-- 跨区服数据同步_全局GC
function Player:Gb_DataSync_GC(szName, nValue)
	local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
	if nPlayerId and nValue and GLOBAL_AGENT then
		-- 如果是全局GC，则广播给各个普通GC
		local nConnetId = KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.TSK_CONNET_ID);
		if nConnetId > 0 then
			GlobalGCExcute(nConnetId, {"Player:Nor_DataSync_GC", szName, nValue});
		else
			GlobalGCExcute(-1, {"Player:Nor_DataSync_GC", szName, nValue});
		end
	end
end

-- 跨区服数据同步_普通GC
function Player:Nor_DataSync_GC(szName, nValue)
	local nPlayerId = KGCPlayer.GetPlayerIdByName(szName);
	if nPlayerId and nValue then
		local nCurrentMoney = KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.TSK_CURRENCY_MONEY);
		nCurrentMoney = nCurrentMoney + nValue;
		KGCPlayer.OptSetTask(nPlayerId, KGCPlayer.TSK_CURRENCY_MONEY, nCurrentMoney);
		Dbg:WriteLog("Nor_DataSync_GC", szName, nValue, KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.TSK_CURRENCY_MONEY));
		GlobalExcute{"Player:DataSync_GS2", szName, nCurrentMoney};
	end
end

function Player:CollectGatesInfo_GC(tbGatesInfo)
	local tbBuff = GetGblIntBuf(GBLINTBUF_NAMESERER_MODIFY, 0) or {};
	
	-- 理论上一个GC只有一个正确的网关名
	assert(Lib:CountTB(tbGatesInfo) <= 1);
	
	for szCorrectGates, tbInfo in pairs(tbGatesInfo) do
		tbBuff[szCorrectGates] = tbBuff[szCorrectGates] or {};
		for szGate, _ in pairs(tbInfo) do
			if not tbBuff[szCorrectGates][szGate] then
				tbBuff[szCorrectGates][szGate] = 1;
			end			
		end
	end
	
	--assert(Lib:CountTB(tbBuff) <= 1);
	SetGblIntBuf(GBLINTBUF_NAMESERER_MODIFY, 0, 1, tbBuff);
end

function Player:ResetAllPlayerDragonBallState_GC()
	GlobalExcute({"Player:OnResetAllPlayerDragonBallState"});		
end

function Player:OnNameServerModifyResult(key, bSucc)
	if not self.tbNameServerCallBack then
		return;
	end
	local tb = self.tbNameServerCallBack[key];
	if tb then
		table.insert(tb, bSucc);
		Lib:CallBack(tb);
		self.tbNameServerCallBack[key] = nil;
	end
end

function Player:InsertNameSeverResultCallBack(key, tbCallBack)
	self.tbNameServerCallBack = self.tbNameServerCallBack or {};
	self.tbNameServerCallBack[key] = tbCallBack;
end

function Player:_TestResCallBack(bSucc)
	print("----Player:_TestResCallBack-----", bSucc);
end

function Player:_TestApplyModify()
	local key = ApplyModifyNameServerGate("dengyong3", "dengyong", "");
	self:InsertNameSeverResultCallBack(key, {"Player:_TestResCallBack"});
end

function Player:UpdateCoZoneRefreshPlayerGateWayCallBack(bSucc)
end

function Player:UpdateCoZoneRefreshPlayerGateWay()
	local nGbCoZoneTime = KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME);
	local nNowTime = GetTime();
	-- 合服七天后就不执行这条指令
	if nNowTime < nGbCoZoneTime or nNowTime >= nGbCoZoneTime + 7 * 24 * 60 * 60 then
		return 0;
	end
	
	if (not self.nUpdateCoZoneRefreshPlayerGateWayId or self.nUpdateCoZoneRefreshPlayerGateWayId <= 0) then
		self.nUpdateCoZoneRefreshPlayerGateWayId = Timer:Register(Env.GAME_FPS * 5, self.UpdateCoZoneRefreshPlayerGateWay, self);
	end

	local szSubGateWay = KGblTask.SCGetDbTaskStr(DBTASK_COZONE_SUB_ZONE_GATEWAY);
	if (not szSubGateWay or szSubGateWay == "") then
		return 0;
	end
	
	local szMainGateWay = GetGatewayName();
	if (not szMainGateWay or szMainGateWay == "") then
		return 0;
	end
	
	print("[GCEvent] start UpdateCoZoneRefreshPlayerGateWay", szSubGateWay, szMainGateWay);
	local key = ApplyModifyNameServerGate(szSubGateWay, szMainGateWay, "");
	self:InsertNameSeverResultCallBack(key, {"Player:UpdateCoZoneRefreshPlayerGateWayCallBack"});
	self.nUpdateCoZoneRefreshPlayerGateWayId = 0;
	return 0;
end

function Player:ApplySnsImgAddress(szDstPlayerName, nSnsId, szSrcPlayer)
	if (not self.tbPlayerName2SnsIdAddress) then
		self.tbPlayerName2SnsIdAddress = {};
	end
	
	if (not self.tbPlayerName2SnsIdAddress[szSrcPlayer]) then
		self.tbPlayerName2SnsIdAddress[szSrcPlayer] = {};
	end
	
	
	if (not self.tbPlayerName2SnsIdAddress[szSrcPlayer][nSnsId]) then
		GlobalExcute{"Sns:ApplyPlayerImg_GS", szDstPlayerName, nSnsId, szSrcPlayer};
	else
		GlobalExcute{"Sns:SendSnsImg", szDstPlayerName, nSnsId, szSrcPlayer, self.tbPlayerName2SnsIdAddress[szSrcPlayer][nSnsId]};
	end
end

function Player:ApplyUpdateSnsImgAddress_GC(szSrcPlayerName, nSnsId, szHttpAddress)
	if (not self.tbPlayerName2SnsIdAddress) then
		self.tbPlayerName2SnsIdAddress = {};
	end

	if (not self.tbPlayerName2SnsIdAddress[szSrcPlayerName]) then
		self.tbPlayerName2SnsIdAddress[szSrcPlayerName] = {};
	end
	
	self.tbPlayerName2SnsIdAddress[szSrcPlayerName][nSnsId] = szHttpAddress;
end

Player.tbNameServerCallBack = {};

GCEvent:RegisterGCServerStartFunc(Player.UpdateCoZoneRefreshPlayerGateWay, Player);
 