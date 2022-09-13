-- 文件名　：crosstimeroom_base.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-07-31 16:52:02
-- 描述：时光屋base

local tbBase = Mission:New();
CrossTimeRoom.tbBase = tbBase;

--关卡是否已经开启
function tbBase:IsStart()
	return self.nIsGameStart or 0;
end

--开启房间
function tbBase:StartRoom(nRoomId)
	if not self.tbRoom[nRoomId] then
		return 0;
	end
	self.tbRoom[nRoomId]:StartRoom();
	self.nCurrentRoomId = nRoomId;
	if self.tbStartCount and self.tbStartCount[nRoomId] then
		self.tbStartCount[nRoomId] = self.tbStartCount[nRoomId] + 1;
	end
end

--房间结束
function tbBase:RoomFinish()
	self.nTransferRoomMaxId = self.nTransferRoomMaxId + 1;
	if self.nTransferRoomMaxId >= 5 then
		self.nTransferRoomMaxId = 5;
	end
	if self.tbFinishInfo and self.tbFinishInfo[self.nCurrentRoomId] then
		self.tbFinishInfo[self.nCurrentRoomId] = 1;	--标记通过
	end
	self:AddWeiwang();	--加江湖威望
	if self.nCurrentRoomId == 5 then
		if self.nGameTimerId and self.nGameTimerId > 0 then
			Timer:Close(self.nGameTimerId);
			self.nGameTimerId = 0;
		end
		self.nEndTimer = Timer:Register(CrossTimeRoom.FINISH_TIME * Env.GAME_FPS, self.FinishEnd, self);
		self:UpdateEndUi();	--更新ui 
	end
end

--第5关结束，1分钟后结束副本
function tbBase:FinishEnd()
	self.nEndTimer = 0;
	self:EndGame();
	return 0;
end

--初始化room
function tbBase:InitRoom()
	self.tbRoom = {};
	for i = 1 ,#CrossTimeRoom.tbRoom do
		self.tbRoom[i] = Lib:NewClass(CrossTimeRoom.tbRoom[i]);
		self.tbRoom[i].tbBase = self;
	end
end

function tbBase:InitLogInfo()
	self.tbFinishInfo = {0,0,0,0,0};
	self.tbStartCount = {0,0,0,0,0};
	self.tbDropItemInfo = {};	--产出log统计
end

--初始化mission
function tbBase:InitGame(nMapId, nServerId, nPlayerId)
	self.tbLogOutPlayer = {};	--记录已经报名的玩家
	self.nMapId = nMapId;
	self.nServerId = nServerId;
	self.nPlayerId = nPlayerId;
	self:InitRoom();
	self:InitLogInfo();
	self.tbMisCfg = 
	{
		nForbidSwitchFaction = 1,
		tbEnterPos = {},
		tbLeavePos	= {CrossTimeRoom.LEAVE_POS[1]},	-- 离开坐标
		tbDeathRevPos = {},		-- 死亡重生点
		nOnDeath = 1, 		-- 死亡脚本可用
		nDeathPunish = 1,
		nPkState = Player.emKPK_STATE_PRACTISE,
	};
	for i = 1 ,#CrossTimeRoom.ENTER_POS do
		table.insert(self.tbMisCfg.tbEnterPos, {self.nMapId, unpack(CrossTimeRoom.ENTER_POS[i])});
		table.insert(self.tbMisCfg.tbDeathRevPos, {self.nMapId, unpack(CrossTimeRoom.ENTER_POS[i])});
	end
	self.szUiStateMsg = "";
	self:Open();
	self:GameStart();
end

function tbBase:JoinGame(pPlayer)
	self:JoinPlayer(pPlayer,1);	-- 只有一个阵营
end

--结束mission
function tbBase:EndGame()
	if self.nGameTimerId and self.nGameTimerId > 0 then
		Timer:Close(self.nGameTimerId);
		self.nGameTimerId = 0;
	end
	local nPassRoom = 0;
	for _ , nPass in pairs(self.tbFinishInfo) do
		if nPass > 0 then
			nPassRoom = nPassRoom + 1;
		end
	end
	StatLog:WriteStatLog("stat_info","yinyangshiguangdian","over",self.nPlayerId,
		self.tbStartCount[1] or 0,
		self.tbStartCount[2] or 0,
		self.tbStartCount[3] or 0,
		self.tbStartCount[4] or 0,
		self.tbStartCount[5] or 0,
		nPassRoom);	--数据埋点
	self:WriteDropLog();	--掉落log
	self:Close();
	GCExcute{"CrossTimeRoom:EndGame_GC",self.nPlayerId,self.nServerId,self.nMapId};
end

--申请完之后就开启了
function tbBase:GameStart()
	--如果已经开启，不进行游戏开启操作
	if self.nIsGameStart == 1 then
		return 0;
	end
	self.nGameTimerId = Timer:Register(CrossTimeRoom.MAX_TIME * Env.GAME_FPS, self.GameTimeUp, self);
	self.nCurrentRoomId = 0;	--起始房间
	self.nTransferRoomMaxId = 1;	--可以进行传送的房间号,
	self.nIsGameStart = 1;
	self:AddTransferNpc();
end

function tbBase:AddTransferNpc()
	local tbPos = CrossTimeRoom.tbTransferNpcPos[0];
	self.pReadyTransferNpc = KNpc.Add2(CrossTimeRoom.nTransferTemplateId,120,-1,self.nMapId,tbPos[1],tbPos[2]);
end


function tbBase:GameTimeUp()
	self.nGameTimerId = 0;
	self:EndGame();
	return 0;
end


--关闭前清理
function tbBase:OnClose()
	for i = 1 ,#self.tbRoom do
		self.tbRoom[i]:ClearRoom();
		self.tbRoom[i] = nil;
	end
	ClearMapNpc(self.nMapId);
end

--离开时
function tbBase:OnLeave()
	self:RemovePlayerInRoom(me.nId); --掉线、离开会进行当前房间内的移除
	--活着的玩家掉线后，应该进行房间是否失败处理
	if self.tbRoom and self.tbRoom[self.nCurrentRoomId] then
		local nIsFailed = self.tbRoom[self.nCurrentRoomId]:CheckFailed();
		if nIsFailed == 1 then
			self.tbRoom[self.nCurrentRoomId]:FailedRoom();
			local tbPlayer = self:GetPlayerList();
			for _,pPlayer in pairs(tbPlayer) do
				if pPlayer and pPlayer.IsDead() == 1 then
					pPlayer.ReviveImmediately(0);
				end
			end
		end
	end
	self:CloseSingleUi(me);	
	self:UpdateGameUi();	-- 更新人数
	me.RemoveSkillState(CrossTimeRoom.nRedStateId);
	me.RemoveSkillState(CrossTimeRoom.nYellowStateId);
	me.RemoveSkillState(CrossTimeRoom.nGreenStateId);
	me.SetFightState(0);	-- 非战斗状态
	me.SetLogoutRV(0);		-- 解除服务器宕机保护
	me.DisabledStall(0);	-- 允许摆摊
	me.DisableOffer(0);		-- 允许贩卖
end

function tbBase:OnJoin(nGroupId)
	if self.tbLogOutPlayer[me.nId] == nil then
		CrossTimeRoom:ConsumePlayerItem(me);
		--没有加buff的加上buff
--		if me.GetSkillState(CrossTimeRoom.nLimitJoinHuanglingBuffId) <= 0 then
--			CrossTimeRoom:AddPlayerLockBuff(me);
--		end
	end
	if me.nFightState == 1 then
		me.SetFightState(0);
	end
	self.tbLogOutPlayer[me.nId] = 1;
	me.SetLogoutRV(1);			-- 服务器宕机保护
	me.DisabledStall(1);		-- 禁止摆摊
	me.DisableOffer(1);			-- 禁止贩卖
	self:OpenSingleUi(me);
	self:UpdateGameUi();		--更新ui
end


function tbBase:FindLogOutPlayer(nPlayerId)
	if not self.tbLogOutPlayer[nPlayerId] or self.tbLogOutPlayer[nPlayerId] ~= 1 then
		return 0;
	end
	return 1;
end


--玩家死亡或者掉线把玩家从房间内移除
function tbBase:RemovePlayerInRoom(nPlayerId)
	if not self.tbRoom or not self.tbRoom[self.nCurrentRoomId] or not self.tbRoom[self.nCurrentRoomId].tbPlayerList then
		return 0;
	end
	for nId,nFlag in pairs(self.tbRoom[self.nCurrentRoomId].tbPlayerList) do
		if nId == nPlayerId then
			self.tbRoom[self.nCurrentRoomId].tbPlayerList[nId] = 0;	
		end
	end
end

--死亡
function tbBase:OnDeath()
	me.CallClientScript({"UiManager:CloseWindow","UI_RENASCENCEPANEL"});	--关闭复活界面
	self:BlackBoard(me,"Ngươi đã trọng thương");
	if self.nCurrentRoomId ~= 2 then	--第二关是特殊处理
		--将房间内玩家个数减一个
		self:RemovePlayerInRoom(me.nId);
		local nIsFailed = self.tbRoom[self.nCurrentRoomId]:CheckFailed();
		if nIsFailed == 1 then
			self.tbRoom[self.nCurrentRoomId]:FailedRoom();
			local tbPlayer = self:GetPlayerList();
			for _,pPlayer in pairs(tbPlayer) do
				if pPlayer and pPlayer.IsDead() == 1 then
					pPlayer.ReviveImmediately(0);
				end
			end
		end
	else
		--检测是不是所有人都死了,如果都死了，重新开启关卡,并且把玩家传送到对应的房间
		--处理躺尸体情况,获取boss周围的玩家的死亡情况
		if not self.tbRoom[self.nCurrentRoomId].CheckCanRevive then
			return 0;
		end
		local nCanRevive = self.tbRoom[self.nCurrentRoomId]:CheckCanRevive() or 0;
		if nCanRevive == 1 then
			GeneralProcess:StartProcess("Phương Sĩ đang cứu ngươi...", 1 * Env.GAME_FPS, {self.DoRevive,self,me.nId},{self.Revive,self,me.nId},{});
		else
			self:RemovePlayerInRoom(me.nId);
			local nIsFailed = self.tbRoom[self.nCurrentRoomId]:CheckFailed();
			if nIsFailed == 1 then
				self.tbRoom[self.nCurrentRoomId]:FailedRoom();
				local tbPlayer = self:GetPlayerList();
				for _,pPlayer in pairs(tbPlayer) do
					if pPlayer and pPlayer.IsDead() == 1 then
						pPlayer.ReviveImmediately(0);
					end
				end			
			end
		end
	end
end

--读条复活
function tbBase:Revive(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	if pPlayer.GetTempTable("CrossTimeRoom").nReviveTimer and pPlayer.GetTempTable("CrossTimeRoom").nReviveTimer > 0 then
		Timer:Close(pPlayer.GetTempTable("CrossTimeRoom").nReviveTimer);
		pPlayer.GetTempTable("CrossTimeRoom").nReviveTimer = 0;
	end
	--要用一个计时器进行延迟复活，否则会死循环
	pPlayer.GetTempTable("CrossTimeRoom").nReviveTimer = Timer:Register(Env.GAME_FPS,self.OnRevive,self,nPlayerId);
end

function tbBase:OnRevive(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not self.tbRoom[self.nCurrentRoomId].CheckCanRevive then
		return 0;
	end
	local nCanRevive = self.tbRoom[self.nCurrentRoomId]:CheckCanRevive() or 0;
	if pPlayer and pPlayer.nMapId == self.nMapId then
		if nCanRevive == 1 then
			GeneralProcess:StartProcess("Phương Sĩ đang cứu ngươi...", 5 * Env.GAME_FPS,{self.DoRevive,self,nPlayerId},{self.Revive,self,nPlayerId},{});
		else
			self:RemovePlayerInRoom(pPlayer.nId);
			local nIsFailed = self.tbRoom[self.nCurrentRoomId]:CheckFailed();
			if nIsFailed == 1 then
				self.tbRoom[self.nCurrentRoomId]:FailedRoom();
				local tbPlayer = self:GetPlayerList();
				for _,pPlayer in pairs(tbPlayer) do
					if pPlayer and pPlayer.IsDead() == 1 then
						pPlayer.ReviveImmediately(0);
					end
				end			
			end
		end
		pPlayer.GetTempTable("CrossTimeRoom").nReviveTimer = 0;
	end
	return 0;
end

--第一关特殊处理，延迟复活
function tbBase:DoRevive(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not self.tbRoom[self.nCurrentRoomId].CheckCanRevive then
		return 0;
	end
	local nCanRevive = self.tbRoom[self.nCurrentRoomId]:CheckCanRevive() or 0;
	if pPlayer and pPlayer.nMapId == self.nMapId then
		if nCanRevive == 1 then
			pPlayer.ReviveImmediately(1);
			self.tbRoom[self.nCurrentRoomId]:DelFangshi();	--每次复活减少一个方士
		else
			self:RemovePlayerInRoom(pPlayer.nId);
			local nIsFailed = self.tbRoom[self.nCurrentRoomId]:CheckFailed();
			if nIsFailed == 1 then
				self.tbRoom[self.nCurrentRoomId]:FailedRoom();
				local tbPlayer = self:GetPlayerList();
				for _,pPlayer in pairs(tbPlayer) do
					if pPlayer and pPlayer.IsDead() == 1 then
						pPlayer.ReviveImmediately(0);
					end
				end			
			end
		end
	end
end

--ui相关
function tbBase:CloseEveryOneUi()
	local tbPlayer = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayer) do
		if pPlayer then
			self:CloseSingleUi(pPlayer)
		end
	end
end

function tbBase:UpdateEndUi()
	local tbPlayer = self:GetPlayerList();
	local nTimerId = self.nEndTimer; 
	if nTimerId <= 0 then
		return 0;
	end
	local nLastFrameTime = tonumber(Timer:GetRestTime(nTimerId));
	local szMsg = "<color=green>Thời gian đóng phó bản: <color><color=white>%s<color>"
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			Dialog:SetBattleTimer(pPlayer,szMsg,nLastFrameTime);
			self:UpdateSingleUi(pPlayer);
		end
	end
end

function tbBase:OpenSingleUi(pPlayer)
	if not pPlayer then
		return 0;
	end
	local nTimerId = self.nGameTimerId; --当前状态的计时器id	
	if nTimerId <= 0 then
		return 0;
	end
	local nLastFrameTime = tonumber(Timer:GetRestTime(nTimerId));
	local szMsg = "<color=green>Thời gian kết thúc phó bản: <color><color=white>%s<color>"
	Dialog:SetBattleTimer(pPlayer,szMsg,nLastFrameTime);
	self:UpdateSingleUi(pPlayer);
	Dialog:ShowBattleMsg(pPlayer,  1,  0); --开启界面
end

function tbBase:UpdateGameUi()
	local tbPlayer = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayer) do
		if pPlayer then
			self:UpdateSingleUi(pPlayer);
		end
	end
end

function tbBase:UpdateSingleUi(pPlayer)
	if not pPlayer then
		return 0;
	end
	local nCount = self:GetPlayerCount();
	if self.nGameTimerId <= 0 then
		return 0;
	end
	local szMsg = string.format("\n\nSố người tham gia: %s\n\n<color=yellow>%s<color>\n\n",nCount,self.szUiStateMsg);
	Dialog:SendBattleMsg(pPlayer,szMsg);
end

function tbBase:CloseSingleUi(pPlayer)
	if pPlayer == nil then
		return 0;
	end
	Dialog:ShowBattleMsg(pPlayer,  0,  0); -- 关闭界面
end

--设置ui状态,并且更新
function tbBase:UpdateUiState(szUiState)
	if not szUiState then
		szUiState = "";
	end
	self.szUiStateMsg = szUiState;
	self:UpdateGameUi();
end

--黑条通知
function tbBase:BlackBoard(pPlayer,szMsg)
	if pPlayer and szMsg and #szMsg ~= 0 then
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	end
end

--集体黑条
function tbBase:AllBlackBoard(szMsg)
	local tbPlayer,nCount = self:GetPlayerList();
	if nCount > 0 then
		for _,pPlayer in pairs(tbPlayer) do
			if pPlayer then
				self:BlackBoard(pPlayer,szMsg);
			end
		end
	end
end

--npc说话
function tbBase:NpcTalk(nNpcId,szChat)
	local pNpc = KNpc.GetById(nNpcId);
	if not szChat or #szChat == 0 then
		return 0;
	end
	if pNpc then
		pNpc.SendChat(szChat);
		local tbNearPlayer = KNpc.GetAroundPlayerList(nNpcId,30);
		if tbNearPlayer then
			for _, pPlayer in ipairs(tbNearPlayer) do
				pPlayer.Msg(szChat, pNpc.szName);
			end
		end
	else
		return 0;
	end
end

function tbBase:AddWeiwang()
	local tbPlayer = self:GetPlayerList();
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			pPlayer.AddKinReputeEntry(CrossTimeRoom.nRepute,"newcangbaotu");
		end	
	end
end

function tbBase:OnBossDrop(pNpc,tbItem)
	for _,nId in pairs(tbItem.Item) do
		local pItem = KItem.GetObjById(nId);
		if pItem then
			local szGDPL = string.format("%s_%s_%s_%s",pItem.nGenre,pItem.nDetail,pItem.nParticular,pItem.nLevel);
			if not self.tbDropItemInfo[szGDPL] then
				self.tbDropItemInfo[szGDPL] = 1;
			else
				self.tbDropItemInfo[szGDPL] = self.tbDropItemInfo[szGDPL] + 1;
			end
		end		
	end
	return 1;	
end

function tbBase:WriteDropLog()
	for szGdpl,nCount in pairs(self.tbDropItemInfo) do
		StatLog:WriteStatLog("stat_info","yinyangshiguangdian","product",0,szGdpl,nCount);		
	end
end