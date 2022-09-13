

local tbYouManager = Youlongmibao.Manager or {};
Youlongmibao.Manager = tbYouManager;

tbYouManager.tbRoomMgr				= tbYouManager.tbRoomMgr or {};
tbYouManager.FILEPATH_MAPID			= "\\setting\\event\\youlongmibao\\youlongmibao_mapid.txt";
tbYouManager.FILEPATH_MAPPOS		= "\\setting\\event\\youlongmibao\\youlongmibao_mappos.txt";
tbYouManager.MAX_MAP_PLAYERCOUNT	= 30;
tbYouManager.NPC_DIALOG				= 3690;
tbYouManager.NPC_FIGHT				= 3689;
tbYouManager.TIMER_NPCPVERTIME		= 60 * 5; -- npc消失时间5分钟
tbYouManager.TIMER_WAITPVERTIME		= 60 * 6; -- 等待时间

function tbYouManager:LoadMapInfo()
	self.tbRoomMgr = {
			tbMapMgr = {}, -- 保存地图信息
			tbMapPos = {}, -- 保存地图坐标点信息
		};

	local tbMapPos = {};
	local tbData	= Lib:LoadTabFile(self.FILEPATH_MAPPOS);
	for nRow, tbRow in ipairs(tbData) do
		local nX	= tonumber(tbRow.TRAPX) or 0;
		local nY	= tonumber(tbRow.TRAPY) or 0;
		if (nX > 0 and nY > 0) then
			tbMapPos[#tbMapPos + 1] = {nX / 32, nY / 32};
		end
	end
	
	self.tbRoomMgr.tbMapPos = tbMapPos;

	local tbFileData	= Lib:LoadTabFile(self.FILEPATH_MAPID);

	for nRow, tbRow in ipairs(tbFileData) do
		local nMapId = tonumber(tbRow.MAPID) or 0;
		if (nMapId > 0) then
			local tbInfo = {};
			tbInfo.nPlayerCount = 0;
			tbInfo.tbRoomInfo = {};
			self.tbRoomMgr.tbMapMgr[nMapId] = tbInfo;
		end
	end
end

function tbYouManager:WriteLog(...)
	if (MODULE_GC_SERVER) then
		Dbg:Output("Youlongmibao.tbYouManager", unpack(arg));
	end
	
	if (MODULE_GAMESERVER) then
		Dbg:WriteLogEx(Dbg.LOG_INFO, "Youlongmibao.tbYouManager", unpack(arg));	
	end
end

-- nMapId表示地图可以进入，0表示本服所有地图人数满不能进入或者没有加载
function tbYouManager:FindMap()
	if (not self.tbRoomMgr) then
		self:WriteLog("CheckMapState", "There is no tbRoomMgr!!!!!");
		return 0;
	end
	
	local nResultMapId = 0;
	
	for nMapId, tbInfo in pairs(self.tbRoomMgr.tbMapMgr) do
		-- 这张地图本服务器存在
		if (SubWorldID2Idx(nMapId) >= 0) then
			local nCount = tbInfo.nPlayerCount;
			if (nCount < self.MAX_MAP_PLAYERCOUNT) then
				return nMapId;
			end
		end
	end
	return nResultMapId;
end

function tbYouManager:CheckMapState(nMapId)
	if (not nMapId or nMapId <= 0 or SubWorldID2Idx(nMapId) < 0) then
		return 0, "本服务器地图不存在";
	end
	
	local tbMapInfo = self.tbRoomMgr.tbMapMgr[nMapId];
	if (not tbMapInfo) then
		return 0, "本服务器地图信息不存在";
	end
	
	if (not tbMapInfo.nPlayerCount or tbMapInfo.nPlayerCount >= self.MAX_MAP_PLAYERCOUNT) then
		return 0, "本服务器的游龙地图人数已满，请到其他城市或新手村";
	end
	return 1;
end

function tbYouManager:GetRoom(nMapId)
	local nFlag, szMsg = self:CheckMapState(nMapId);
	if (nFlag <= 0) then
		return 0;
	end
	local tbPos = self.tbRoomMgr.tbMapPos;
	local tbMapInfo = self.tbRoomMgr.tbMapMgr[nMapId];
	
	if (tbMapInfo.nPlayerCount >= self.MAX_MAP_PLAYERCOUNT) then
		return 0;
	end
	
	if (not tbPos) then
		return 0;
	end
	for nId, tbInfo in ipairs(tbPos) do
		if (not tbMapInfo.tbRoomInfo[nId]) then
			return nId, tbInfo;
		end
	end
	return 0;
end

function tbYouManager:GetRoomInfo(nMapId, nRoomId)
	if (not nMapId or not nRoomId) then
		return;
	end
	
	if (not self.tbRoomMgr) then
		return;
	end
	
	local tbMapInfo = self.tbRoomMgr.tbMapMgr[nMapId];
	if (not tbMapInfo) then
		return;
	end
	
	local tbRoomInfo = tbMapInfo.tbRoomInfo;
	if (not tbRoomInfo) then
		return;
	end
	
	return tbRoomInfo[nRoomId];
end

function tbYouManager:ResetRoom(nMapId, nRoomId)
	if (not self.tbRoomMgr.tbMapMgr) then
		return 0;
	end
	
	if (not self.tbRoomMgr.tbMapMgr[nMapId]) then
		return 0;
	end
	
	if (not self.tbRoomMgr.tbMapMgr[nMapId].tbRoomInfo) then
		return 0;
	end
	
	if (not self.tbRoomMgr.tbMapMgr[nMapId].tbRoomInfo[nRoomId]) then
		return 0;
	end
	
	-- 如果npc结束时间还开着那么就要关掉
	local nNpcOverRegId = self.tbRoomMgr.tbMapMgr[nMapId].tbRoomInfo[nRoomId].nNpcTimerOverRegId;
	if (nNpcOverRegId and nNpcOverRegId > 0) then
		Timer:Close(nNpcOverRegId);
		self.tbRoomMgr.tbMapMgr[nMapId].tbRoomInfo[nRoomId].nNpcTimerOverRegId = nil;
	end
	
	self.tbRoomMgr.tbMapMgr[nMapId].tbRoomInfo[nRoomId] = nil;
	self.tbRoomMgr.tbMapMgr[nMapId].nPlayerCount = self.tbRoomMgr.tbMapMgr[nMapId].nPlayerCount - 1;
	if (self.tbRoomMgr.tbMapMgr[nMapId].nPlayerCount < 0) then
		self.tbRoomMgr.tbMapMgr[nMapId].nPlayerCount = 0;
	end
	return 1;
end

function tbYouManager:SetRoom(pPlayer, nMapId, nRoomId)
	if (not pPlayer or not nMapId or nMapId <= 0 or not nRoomId or nRoomId <= 0) then
		return 0;
	end
	
	if (not self.tbRoomMgr or
		not self.tbRoomMgr.tbMapMgr or
		not self.tbRoomMgr.tbMapMgr[nMapId]) then
		return 0;
	end
	
	local tbInfo = {};
	tbInfo.nPlayerId = pPlayer.nId;
	if (not self.tbRoomMgr.tbMapMgr[nMapId].tbRoomInfo) then
		self.tbRoomMgr.tbMapMgr[nMapId].tbRoomInfo = {};
	end
	if (not self.tbRoomMgr.tbMapMgr[nMapId].nPlayerCount) then
		self.tbRoomMgr.tbMapMgr[nMapId].nPlayerCount = 0;
	end
	self.tbRoomMgr.tbMapMgr[nMapId].tbRoomInfo[nRoomId] = tbInfo;
	self.tbRoomMgr.tbMapMgr[nMapId].nPlayerCount = self.tbRoomMgr.tbMapMgr[nMapId].nPlayerCount + 1;
	return 1;
end

function tbYouManager:GetPlayerRoomInfo(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	
	for nMapId, tbInfo in pairs(self.tbRoomMgr.tbMapMgr) do
		if (SubWorldID2Idx(nMapId) >= 0) then
			for nRoomId, tbPlayerInfo in pairs(tbInfo.tbRoomInfo) do
				if (tbPlayerInfo.nPlayerId == pPlayer.nId) then
					return nMapId, nRoomId, tbPlayerInfo;
				end
			end
		end
	end
	
	return 0;
end

function tbYouManager:JoinPlayer(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	if pPlayer.GetTiredDegree1() == 2 then
		pPlayer.Msg("Bạn đã quá mệt mỏi!");
		return;
	end
	local nMapId = self:FindMap();
	if nMapId <= 0 then
		Setting:SetGlobalObj(pPlayer);
		Dialog:Say("Mật Thất Du Long đã đầy chỗ, hãy chọn thành thị hoặc tân thủ thôn khác.");
		Setting:RestoreGlobalObj();
		return 0;
	end
	local nFlag, szMsg = self:CheckMapState(nMapId);
	
	if (nFlag <= 0) then
		Setting:SetGlobalObj(pPlayer);
		Dialog:Say(szMsg);
		Setting:RestoreGlobalObj();
		return 0;
	end

	local nRoomId, tbPos = self:GetRoom(nMapId);
	if (nRoomId <= 0) then
		Setting:SetGlobalObj(pPlayer);
		Dialog:Say("Không thể vào!");
		Setting:RestoreGlobalObj();
		return 0;
	end
	if (self:SetRoom(pPlayer, nMapId, nRoomId) == 0) then
		self:WriteLog("JoinPlayer", string.format("%s enter mapid: %d, room id: %d SetRoom failed! ", pPlayer.szName, nMapId, nRoomId));
		return 0;
	end

	pPlayer.NewWorld(nMapId, tbPos[1], tbPos[2]);
	self:WriteLog("JoinPlayer", string.format("%s enter mapid: %d, room id: %d success! ", pPlayer.szName, nMapId, nRoomId));
	return 1;
end

function tbYouManager:LeavePlayer(pPlayer)
	if (not pPlayer) then
		return 0;
	end

	local nMapId, nRoomId, tbRoomInfo = self:GetPlayerRoomInfo(pPlayer);
	if (nMapId > 0 and nRoomId > 0) then
		self:ResetRoom(nMapId, nRoomId);
	end
	self:WriteLog("LeavePlayer", string.format("%s leave mapid: %d, room id: %d success! ", pPlayer.szName, nMapId, nRoomId or 0));
	return 1;
end

function tbYouManager:AddDialogNpc(pPlayer)
	if (not self:AddNpc(pPlayer, self.NPC_DIALOG)) then
		return 0;
	end
	local nMapId, nRoomId, tbRoomInfo = self:GetPlayerRoomInfo(pPlayer);	
	if (tbRoomInfo.nNpcTimerOverRegId and tbRoomInfo.nNpcTimerOverRegId > 0) then
		Timer:Close(tbRoomInfo.nNpcTimerOverRegId);
		tbRoomInfo.nNpcTimerOverRegId = 0;
	end
	
	local szMsg = "<color=green>Thời gian chờ: <color=white>%s<color>";
	self:OpenSingleUi(pPlayer, szMsg, self.TIMER_WAITPVERTIME * Env.GAME_FPS);
	self:UpdateMsgUi(pPlayer, "Đang đợi.....");	
	tbRoomInfo.nNpcTimerOverRegId	= Timer:Register(self.TIMER_WAITPVERTIME * Env.GAME_FPS,  self.OnTimer_WaitTimerOver,  self, nMapId, nRoomId);
	return 1;
end

function tbYouManager:AddFightNpc(pPlayer)
	local nMapId, nRoomId, tbRoomInfo = self:GetPlayerRoomInfo(pPlayer);
	if (not tbRoomInfo) then
		return 0;
	end

	local pNpc = self:AddNpc(pPlayer, self.NPC_FIGHT);
	if (not pNpc) then
		return 0;
	end
	
	if (tbRoomInfo.nNpcTimerOverRegId and tbRoomInfo.nNpcTimerOverRegId > 0) then
		Timer:Close(tbRoomInfo.nNpcTimerOverRegId);
		tbRoomInfo.nNpcTimerOverRegId = 0;
	end

	Npc:RegPNpcOnDeath(pNpc, self.OnDeath_FightNpc, self);
	local szMsg = "<color=green>Thời gian kết thúc: <color=white>%s<color>";
	self:OpenSingleUi(pPlayer, szMsg, self.TIMER_NPCPVERTIME * Env.GAME_FPS);
	self:UpdateMsgUi(pPlayer, "Đang chiến đấu.....");
	tbRoomInfo.nNpcTimerOverRegId	= Timer:Register(self.TIMER_NPCPVERTIME * Env.GAME_FPS,  self.OnTimer_NpcTimerOver,  self, nMapId, nRoomId);
	return 1;
end

function tbYouManager:KickPlayer(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	local nMapId, nRoomId, tbRoomInfo = self:GetPlayerRoomInfo(pPlayer);	
	if (tbRoomInfo.nNpcTimerOverRegId and tbRoomInfo.nNpcTimerOverRegId > 0) then
		Timer:Close(tbRoomInfo.nNpcTimerOverRegId);
		tbRoomInfo.nNpcTimerOverRegId = 0;
	end	
	local nMapId, nPosX, nPosY = self:GetLeaveMapPos();
	pPlayer.NewWorld(nMapId, nPosX, nPosY);
	return 1;
end

function tbYouManager:GetLeaveMapPos()	
	local tbNpc = Npc:GetClass("chefu");
	for _, tbMapInfo in ipairs(tbNpc.tbCountry) do
		if SubWorldID2Idx(tbMapInfo.nId) >= 0 then
			local nRandomPos = MathRandom(1, #tbMapInfo.tbSect)
			return tbMapInfo.nId, tbMapInfo.tbSect[nRandomPos][1],tbMapInfo.tbSect[nRandomPos][2];
		end
	end
	return 5, 1580, 3029;
end	

function tbYouManager:DelNpc(pPlayer)
	local nMapId, nRoomId, tbRoomInfo = self:GetPlayerRoomInfo(pPlayer);
	if (nMapId <= 0 or nRoomId <= 0 or not tbRoomInfo) then
		return 0;
	end
	if (not tbRoomInfo.dwNpcId) then
		return 0;
	end
	local pNpc = KNpc.GetById(tbRoomInfo.dwNpcId);
	if (not pNpc) then
		return 0;
	end
	pNpc.Delete();
	return 1;
end

function tbYouManager:AddNpc(pPlayer, nNpcTempId)
	if (not pPlayer or not nNpcTempId or nNpcTempId <= 0) then
		return nil;
	end
	local nMapId, nRoomId, tbRoomInfo = self:GetPlayerRoomInfo(pPlayer);
	if (nMapId <= 0 or nRoomId <= 0 or not tbRoomInfo) then
		return nil;
	end
	local tbPos = self.tbRoomMgr.tbMapPos[nRoomId];
	if (not tbPos or not tbPos[1] or tbPos[1] <= 0) then
		return nil;
	end
	local pNpc = KNpc.Add2(nNpcTempId, pPlayer.nLevel, -1, nMapId, tbPos[1], tbPos[2]);
	if (not pNpc) then
		return nil;
	end
	tbRoomInfo.dwNpcId = pNpc.dwId;	
	return pNpc;
end

-- 有没有可能npc不是他杀的，是别人杀的？这样就诡异了
function tbYouManager:OnDeath_FightNpc(pNpc)
	if (not pNpc) then
		return 0;
	end
	local pKillerPlayer = pNpc.GetPlayer();
	if (pKillerPlayer) then	
		local pPlayer = pKillerPlayer;
		--pPlayer.SetFightState(0);
		
		local nMapId, nRoomId, tbRoomInfo = self:GetPlayerRoomInfo(pPlayer);
		if (not tbRoomInfo) then
			return 0;
		end
		
		local nNowMapId = pPlayer.GetWorldPos();
		if (nNowMapId ~= nMapId) then
			return 0;
		end
		local nNpcOverRegId = tbRoomInfo.nNpcTimerOverRegId;
		if (nNpcOverRegId and nNpcOverRegId > 0) then
			Timer:Close(nNpcOverRegId);
			tbRoomInfo.nNpcTimerOverRegId = nil;
		end	
		self:AddDialogNpc(pPlayer);	
		Dialog:SendBlackBoardMsg(pPlayer, "Khiêu chiến thành công, nhận được 1 phần thưởng.");
		-- 调用秘宝开始接口
		Youlongmibao:GameStart(pPlayer);
	end
end


function tbYouManager:OnTimer_WaitTimerOver(nMapId, nRoomId)
	local tbRoomInfo = self:GetRoomInfo(nMapId, nRoomId);
	if (tbRoomInfo) then
		local nPlayerId = tbRoomInfo.nPlayerId;
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if (not pPlayer) then
			return 0;
		end
		--pPlayer.SetFightState(0);
		Youlongmibao:PlayerLeave(pPlayer);
		Dialog:SendBlackBoardMsg(pPlayer, "Quá thời gian chờ, bạn đã được đưa ra ngoài.");
		if (tbRoomInfo.nNpcTimerOverRegId and tbRoomInfo.nNpcTimerOverRegId > 0) then
			Timer:Close(tbRoomInfo.nNpcTimerOverRegId);
			tbRoomInfo.nNpcTimerOverRegId = nil;
		end
	end
	return 0;
end

function tbYouManager:OnTimer_NpcTimerOver(nMapId, nRoomId)
	local tbRoomInfo = self:GetRoomInfo(nMapId, nRoomId);
	if (tbRoomInfo) then
		local nPlayerId = tbRoomInfo.nPlayerId;
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if (not pPlayer) then
			return 0;
		end
		self:DelNpc(pPlayer);
		--pPlayer.SetFightState(0);
		self:AddDialogNpc(pPlayer);
		Dialog:SendBlackBoardMsg(pPlayer, "Khiêu chiến thất bại, hãy thử lại.");
		if (tbRoomInfo.nNpcTimerOverRegId and tbRoomInfo.nNpcTimerOverRegId > 0) then
			Timer:Close(tbRoomInfo.nNpcTimerOverRegId);
			tbRoomInfo.nNpcTimerOverRegId = nil;
		end
	end
	return 0;
end

--开启界面
function tbYouManager:OpenSingleUi(pPlayer, szMsg, nLastFrameTime)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SetBattleTimer(pPlayer,  szMsg, nLastFrameTime);
	Dialog:ShowBattleMsg(pPlayer,  1,  0); --开启界面
end

--关闭界面
function tbYouManager:CloseSingleUi(pPlayer)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:ShowBattleMsg(pPlayer,  0,  0); -- 关闭界面
end

--更新界面时间
function tbYouManager:UpdateTimeUi(pPlayer, szMsg, nLastFrameTime)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SetBattleTimer(pPlayer,  szMsg, nLastFrameTime);
end

--更新界面信息
function tbYouManager:UpdateMsgUi(pPlayer, szMsg)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SendBattleMsg(pPlayer, szMsg, 1);
end
