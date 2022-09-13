-- 跨服

function Transfer:PlayerLogin(nPlayerId)
	self:DeleteItemAtTransfer(nPlayerId);
	
	--武林大会上线给予自己服称号
	local szGateWay = self:GetMyGateway(me);
	local szServerName = ServerEvent:GetServerNameByGateway(szGateWay);
	if szServerName then
		local nEndTime = GetTime()+3600*24*30;
		me.AddSpeTitle(szServerName, nEndTime, "gold"); --增加称号
	end
	
	if Wldh:CheckIsOpen() == 1 and me.GetCamp() ~= 6 then
		me.AddItem(18,1,491,1);	--给予武林大会新手手册
		Wldh.tbChannelLeague:AddPlayer2League(nPlayerId);
	end
	
	-- 通知客户端，打开战斗力
	Player.tbFightPower:OnPlayerLogin();
	
	--GM号给予GM卡
	if me.GetCamp() == 6 then
		me.AddItem(18,1,400,1);
	end
	self:LoginGlbServerEvent();
end;

function Transfer:PlayerLogout(nPlayerId)
		
end;

--获得来自的区服号(废弃使用)
function Transfer:GetTransferGateway()
	return me.GetTask(self.tbServerTaskId[1], self.tbServerTaskId[2]);
end

--设置来自的区服号(废弃使用)
function Transfer:SetTransferGateway()
	local nGateway = tonumber(string.sub(GetGatewayName(), 5, -1))
	return me.SetTask(self.tbServerTaskId[1], self.tbServerTaskId[2], nGateway);
end

--获得来自的区服网关名
function Transfer:GetMyGateway(pPlayer)
	if not GLOBAL_AGENT then
		self:SetMyGateway(pPlayer);
	end
	return pPlayer.GetTaskStr(self.tbServerTaskGatewayName[1], self.tbServerTaskGatewayName[2]);
end

--获得自己区服跨服后的编号Id
function Transfer:GetMyTransferId(pPlayer)
	local szGateway = self:GetMyGateway(pPlayer);
	local tbInfo = ServerEvent:GetServerInforByGateway(szGateway);
	if not tbInfo then
		--print("Transfer:GetMyTransferId", "Transfer:GetMyGateway Error", "Not Find gatewaylistInfor", szGateway);
		return 14;
	end
	return tbInfo.nTransferId;
end

--设置来自的区服网关名
function Transfer:SetMyGateway(pPlayer)
	local szGateway = GetGatewayName();
	return pPlayer.SetTaskStr(self.tbServerTaskGatewayName[1], self.tbServerTaskGatewayName[2], szGateway);
end

--传送到英雄岛(普通服务器和全局服务器通用)
function Transfer:NewWorld2GlobalMap(pPlayer, tbPos)
	local nMapX, nMapY = 1876, 3343;
	if tbPos then
		nMapX, nMapY = unpack(tbPos);
	end
	if GLOBAL_AGENT then
		local nTransferId = Transfer:GetMyTransferId(pPlayer);
		local nMapId = self.tbGlobalMapId[nTransferId];
		if not self.tbGlobalMapId[nTransferId] then
			return 0;
		end
		pPlayer.NewWorld(nMapId, nMapX, nMapY);
		return 0;
	end
	me.SetLogoutRV(0);
	-- 判断是否有战队
	local nTransferId = Transfer:GetMyTransferId(pPlayer);
	local nMapId = self.tbGlobalMapId[nTransferId];
	if not self.tbGlobalMapId[nTransferId] then
		pPlayer.Msg("你的区服还未开放跨服功能。");
		return 0;
	end
	-- 实际这里是跨服操作
	local nCanSure = Map:CheckGlobalPlayerCount(nMapId);
	if nCanSure < 0 then
		pPlayer.Msg("Đường phía trước bị chặn.");
		return 0;
	end
	if nCanSure == 0 then
		pPlayer.Msg("英雄岛人数已满，请稍后再尝试。");
		return 0;
	end
	local nMapIdEx , nPosX, nPosY = me.GetWorldPos();
	pPlayer.SetTask(self.tbServerTaskSaveMapId[1], self.tbServerTaskSaveMapId[2], nMapIdEx);
	pPlayer.SetTask(self.tbServerTaskSavePosX[1], self.tbServerTaskSavePosX[2], nPosX);
	pPlayer.SetTask(self.tbServerTaskSavePosY[1], self.tbServerTaskSavePosY[2], nPosY);
	self:TransferData();	--同步数据
	pPlayer.GlobalTransfer(nMapId, nMapX, nMapY);	
end

--跨回本服
function Transfer:NewWorld2MyServer(pPlayer)
	if GLOBAL_AGENT then
		local nMapIdEx	= pPlayer.GetTask(self.tbServerTaskSaveMapId[1], self.tbServerTaskSaveMapId[2]);
		local nPosX		= pPlayer.GetTask(self.tbServerTaskSavePosX[1], self.tbServerTaskSavePosX[2]);
		local nPosY		= pPlayer.GetTask(self.tbServerTaskSavePosY[1], self.tbServerTaskSavePosY[2]);
		pPlayer.GlobalTransfer(nMapIdEx, nPosX, nPosY);	
	end
end

-- 删除所有物品 
function Transfer:DeleteItemAtTransfer(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end;
	
	local tbERoom = 
	{
		Item.ROOM_MAIL,						-- 信件附件
		Item.ROOM_RECYCLE,					-- 回购空间
	};
	
	local tbAllRoom = {
			Item.BAG_ROOM,
			Item.REPOSITORY_ROOM,
			tbERoom,
		}
	for _, tbRoom in pairs(tbAllRoom) do
		for _, nRoom in pairs(tbRoom) do
			local tbIdx = pPlayer.FindAllItem(nRoom);
			for i = 1, #tbIdx do
				local pItem = KItem.GetItemObj(tbIdx[i]);
				 pPlayer.DelItem(pItem);
			end;
		end;
	end;
end;

--同步数据
function Transfer:TransferData()
	for _, tbSyncData in pairs(self.tbTransferSyncData) do
		local tbCallBack = {tbSyncData.fun, unpack(tbSyncData.tbParam)};
		Lib:CallBack(tbCallBack);
	end
end

--注册同步数据
function Transfer:RegisterSyncData(fnStartFun, ...)
	self.tbTransferSyncData = self.tbTransferSyncData or {};
	local nRegId = #self.tbTransferSyncData + 1;
	self.tbTransferSyncData[nRegId] = {fun=fnStartFun, tbParam=arg};
	return nRegId;
end

--登陆事件
function Transfer:LoginGlbServerEvent()
	for _, tbEvent in pairs(self.tbLoginGlbServerEvent) do
		local tbCallBack = {tbEvent.fun, unpack(tbEvent.tbParam)};
		Lib:CallBack(tbCallBack);
	end
end

--注册登陆事件
function Transfer:RegisterGlbServerEvent(fnStartFun, ...)
	self.tbLoginGlbServerEvent = self.tbLoginGlbServerEvent or {};
	local nRegId = #self.tbLoginGlbServerEvent + 1;
	self.tbLoginGlbServerEvent[nRegId] = {fun=fnStartFun, tbParam=arg};
	return nRegId;
end
