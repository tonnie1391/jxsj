-------------------------------------------------------------------
--File: 	
--Author: 	sunduoliang
--Date: 		2008-4-14
--Describe:	令牌召唤逻辑
-------------------------------------------------------------------


if (not Item.tbZhaoHuanLingPai) then
	Item.tbZhaoHuanLingPai = {};
end

local tb = Item.tbZhaoHuanLingPai;
tb.nTime = 10;
tb.TEMPLET_ITEM_ID = {18,1,87,1}; --召唤模版类物品.取召唤类同一类型的其中一种做为模版
-- GC询问各个Server
--nKind = 1为家族召唤，2为帮会召唤，0为好友召唤
function tb:SelectPlayer(nKind, nMapId, nPosX, nPosY, nPlayerId, nKinTongId, szName, nFightState)
	--对所有家族成员发送请求
	--print("SelectPlayer",nKind, nMapId, nPosX, nPosY, nPlayerId, nKinTongId, szName, nFightState)
	GlobalExcute({"Item.tbZhaoHuanLingPai:SeachPlayer_GS1", nKind, nMapId, nPosX, nPosY, nPlayerId, nKinTongId, szName, nFightState});
end

--GS 每台服务器扫描家族成员
function tb:SeachPlayer_GS1(nKind, nMapId, nPosX, nPosY, nPlayerId, nKinTongId, szName, nFightState)
	--print("SeachPlayer_GS1",nKind, nMapId, nPosX, nPosY, nPlayerId, nKinTongId, szName, nFightState)
	if tonumber(nKind) == 1 then
		self:KinCallMember(nKind, nMapId, nPosX, nPosY, nPlayerId, nKinTongId, szName, nFightState);
	elseif tonumber(nKind) == 2 then
		self:TongCallMember(nKind, nMapId, nPosX, nPosY, nPlayerId, nKinTongId, szName, nFightState);
	end
end
--GS
function tb:KinCallMember(nKind, nMapId, nPosX, nPosY, nPlayerId, nKinTongId, szName, nFightState)
	--print("KinCallMember",nKind, nMapId, nPosX, nPosY, nPlayerId, nKinTongId, szName, nFightState)
	local cKin = KKin.GetKin(nKinTongId);
	if not cKin then
		return 0;
	end
	
	local nCanSendIn = Item:IsCallInAtMap(nMapId, unpack(self.TEMPLET_ITEM_ID));
	if (nCanSendIn ~= 1) then
		return 0;
	end	
	
	local itor = cKin.GetMemberItor();
	local cMember = itor.GetCurMember();
	while cMember do
		local nMemberPlayerId = cMember.GetPlayerId()
		local nOnline = KGCPlayer.OptGetTask(nMemberPlayerId, KGCPlayer.TSK_ONLINESERVER);
		if nOnline and nOnline > 0 then
			if nMemberPlayerId ~= nPlayerId then
				local pPlayer = KPlayer.GetPlayerObjById(nMemberPlayerId);
				if (pPlayer) then
					local nCanSendOut = Item:IsCallOutAtMap(pPlayer.nMapId, unpack(self.TEMPLET_ITEM_ID));
					if (nCanSendOut == 1) then
						self:SeachPlayer(nKind, nMapId, nPosX, nPosY, nMemberPlayerId, szName, nFightState);
					end
				end
			end
		end
		cMember = itor.NextMember()
	end	
end

function tb:TongCallMember(nKind, nMapId, nPosX, nPosY, nPlayerId, nKinTongId, szName, nFightState)
	--print("TongCallMember",nKind, nMapId, nPosX, nPosY, nPlayerId, nKinTongId, szName, nFightState)
	local nTongId = nKinTongId;
	if nTongId == nil or nTongId <= 0 then
		return 0;
	end
	
	local nCanSendIn =  Item:IsCallInAtMap(nMapId, unpack(self.TEMPLET_ITEM_ID));
	if (nCanSendIn ~= 1) then
		return 0;
	end
	
	--对所有帮会成员发送请求
	local cTong = KTong.GetTong(nTongId)
	if not cTong then
		return 0;
	end	
	local cKinItor = cTong.GetKinItor()
	local nKinId = cKinItor.GetCurKinId()
	while nKinId ~= 0 do
		local cKin = KKin.GetKin(nKinId);
		if not cKin then
			return 0;
		end
		local itor = cKin.GetMemberItor();
		local cMember = itor.GetCurMember();
		while cMember do
			local nMemberPlayerId = cMember.GetPlayerId()
			--local szName= KGCPlayer.GetPlayerName(cMember.GetPlayerId());
			local nOnline = KGCPlayer.OptGetTask(nMemberPlayerId, KGCPlayer.TSK_ONLINESERVER);
			if nOnline and nOnline > 0 then
				if nMemberPlayerId ~= nPlayerId then
					local pPlayer = KPlayer.GetPlayerObjById(nMemberPlayerId);
					if (pPlayer) then
						local nSelfKinId, nSelfMemberId = pPlayer.GetKinMember();
						if Tong:HaveFigure(nTongId, nSelfKinId, nSelfMemberId, 0) == 1 then							
							local nCanSendOut = Item:IsCallOutAtMap(pPlayer.nMapId, unpack(self.TEMPLET_ITEM_ID));
							if (nCanSendOut == 1) then
								self:SeachPlayer(nKind, nMapId, nPosX, nPosY, nMemberPlayerId, szName, nFightState);
							end
						end	
					end
				end
			end
			cMember = itor.NextMember()
		end
	  nKinId = cKinItor.NextKinId()
	end
end

-- GS 搜索本服务器上是否有指定玩家
function tb:SeachPlayer(nKind, nMapId, nPosX, nPosY, nMemberPlayerId, szName, nFightState)
	--print("SeachPlayer",nKind, nMapId, nPosX, nPosY, nMemberPlayerId, szName, nFightState)
	-- 如果找到的话返回这个玩家的坐标
	local pPlayer = KPlayer.GetPlayerObjById(nMemberPlayerId);
	if (pPlayer) then
		local nCanSendOut = Item:IsCallOutAtMap(pPlayer.nMapId, unpack(self.TEMPLET_ITEM_ID));
		local nCanSendIn  = Item:IsCallInAtMap(nMapId, unpack(self.TEMPLET_ITEM_ID));
		if (nCanSendOut ~= 1) then
			pPlayer.Msg("当前地图不可以被传送！");
			return;
		end
		if (nCanSendIn ~= 1) then
			pPlayer.Msg("不可以传送到目标地图！");
			return;
		end	
		
		-- 通知确认
		GCExcute({"Item.tbZhaoHuanLingPai:Msg2Player4Confirm_GC", nKind, nMapId, nPosX, nPosY, nMemberPlayerId, szName, nFightState});		
	end
end


-- GC 通知确认
function tb:Msg2Player4Confirm_GC(nKind, nMapId, nPosX, nPosY, nMemberPlayerId, szName, nFightState)
	--print("Msg2Player4Confirm_GC",nKind, nMapId, nPosX, nPosY, nMemberPlayerId, szName, nFightState)
	GlobalExcute({"Item.tbZhaoHuanLingPai:Msg2Player4Confirm_GS", nKind, nMapId, nPosX, nPosY, nMemberPlayerId, szName, nFightState});
end

-- GS 通知确认
function tb:Msg2Player4Confirm_GS(nKind, nMapId, nPosX, nPosY, nMemberPlayerId, szName, nFightState)
	--print("Msg2Player4Confirm_GS",nKind, nMapId, nPosX, nPosY, nMemberPlayerId, szName, nFightState)
	local pPlayer = KPlayer.GetPlayerObjById(nMemberPlayerId);
	if (not pPlayer) then
		return;
	end
	pPlayer.GetTempTable("Item").nZhaoHuanPlayerId = nMemberPlayerId;
	pPlayer.GetTempTable("Item").tbZhaoHuanLingPai = {nKind, nMapId, nPosX, nPosY, nMemberPlayerId, szName, nFightState};
	Setting:SetGlobalObj(pPlayer);
	Player:RegisterTimer(Env.GAME_FPS * 70, self.InvalidRequest, self, nMemberPlayerId);
	
	Setting:RestoreGlobalObj();
	pPlayer.CallClientScript({"Item.tbZhaoHuanLingPai:Msg2Player4Confirm_C", nKind, nMapId, nPosX, nPosY, nMemberPlayerId, szName, nFightState});
end

-- C
function tb:Msg2Player4Confirm_C(nKind, nMapId, nPosX, nPosY, nMemberPlayerId, szName, nFightState)
	CoreEventNotify(
		UiNotify.emCOREEVENT_CONFIRMATION,
		UiNotify.CONFIRMATION_KIN_CONVECTION,
		szName,
		nKind,
		nMapId,
		nPosX,
		nPosY,
		nMemberPlayerId,
		nFightState
	);
end

-- GS确认后,bAccept为(0.拒绝，1.同意)
function tb:PlayerAccredit(nMapId, nPosX, nPosY, nMemberPlayerId, nFightState, bAccept)
	if (bAccept ~= 2) then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nMemberPlayerId);
	if (not pPlayer) then
		return;
	end
	if pPlayer.GetTempTable("Item").nZhaoHuanPlayerId ~= nMemberPlayerId then
		pPlayer.Msg("您的操作超时了。");
		return 0;
	end
	
	local nTempKind = pPlayer.GetTempTable("Item").tbZhaoHuanLingPai[1];
	local nTempMapId = pPlayer.GetTempTable("Item").tbZhaoHuanLingPai[2];
	local nTempPosX = pPlayer.GetTempTable("Item").tbZhaoHuanLingPai[3];
	local nTempPosY = pPlayer.GetTempTable("Item").tbZhaoHuanLingPai[4];
	local nTempMemberPlayerId = pPlayer.GetTempTable("Item").tbZhaoHuanLingPai[5];
	local szTempName = pPlayer.GetTempTable("Item").tbZhaoHuanLingPai[6];
	local nTempFightState = pPlayer.GetTempTable("Item").tbZhaoHuanLingPai[7];	
	

	
	local nCanSendOut = Item:IsCallOutAtMap(pPlayer.nMapId, unpack(self.TEMPLET_ITEM_ID));
	local nCanSendIn  = Item:IsCallInAtMap(nTempMapId, unpack(self.TEMPLET_ITEM_ID));
	if (nCanSendOut ~= 1) then
		pPlayer.Msg("当前地图不可以被传送！");
		return;
	end
	if (nCanSendIn ~= 1) then
		pPlayer.Msg("不可以传送到目标地图！");
		return;
	end	
	local tbEvent	= {						-- 会中断延时的事件
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
	};
	if (0 == pPlayer.nFightState) then				-- 玩家在非战斗状态下传送无延时正常传送
		self:SendAllMemberSuccess(nTempMapId, nTempPosX, nTempPosY, nTempMemberPlayerId, nTempFightState)
		return 0;
	end
	GeneralProcess:StartProcess("正在发送召唤请求...", self.nTime * Env.GAME_FPS, {self.SendAllMemberSuccess, self, nTempMapId, nTempPosX, nTempPosY, nTempMemberPlayerId, nTempFightState}, nil, tbEvent);	-- 在战斗状态下需要nTime秒的延时
end

function tb:SendAllMemberSuccess(nMapId, nPosX, nPosY, nMemberPlayerId, nFightState)
	--print("SendAllMemberSuccess",nMapId, nPosX, nPosY, nMemberPlayerId, nFightState)
	local pPlayer = KPlayer.GetPlayerObjById(nMemberPlayerId);
	if (not pPlayer) then
		return 0;
	end
	local nCanSendOut = Item:IsCallOutAtMap(pPlayer.nMapId, unpack(self.TEMPLET_ITEM_ID));
	local nCanSendIn  = Item:IsCallInAtMap(nMapId, unpack(self.TEMPLET_ITEM_ID));
	if (nCanSendOut ~= 1) then
		pPlayer.Msg("当前地图不可以被传送！");
		return;
	end
	if (nCanSendIn ~= 1) then
		pPlayer.Msg("不可以传送到目标地图！");
		return;
	end
	local nRet, szMsg = Map:CheckTagServerPlayerCount(nMapId)
	if nRet ~= 1 then
		pPlayer.Msg(szMsg);
		return 0;
	end
	pPlayer.SetFightState(nFightState);
	pPlayer.NewWorld(nMapId, nPosX, nPosY);
end

function tb:InvalidRequest(nMemberPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nMemberPlayerId);
	if (not pPlayer) then
		return 0;
	end
	pPlayer.GetTempTable("Item").nZhaoHuanPlayerId = nil;
	pPlayer.GetTempTable("Item").tbZhaoHuanLingPai = nil;
	return 0;
end

