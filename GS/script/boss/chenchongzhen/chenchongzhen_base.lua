-- 文件名　：chenchongzhen_base.lua
-- 创建者　：zhangjunjie
-- 创建时间：2012-02-20 14:37:49
-- 描述：mission base

-- 文件名　：ChenChongZhen_base.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-07-31 16:52:02
-- 描述：时光屋base

local tbBase = Mission:New();
ChenChongZhen.tbBase = tbBase;

--关卡是否已经开启
function tbBase:IsStart()
	return self.nIsGameStart or 0;
end

--开启房间
function tbBase:StartRoom(nRoomId)
	if not self.tbRoom[nRoomId] then
		Dbg:WriteLog("ChenChongZhen","Start Room Failed!",self.nMapId,self.nServerId,self.nPlayerId);
		return 0;
	end
	if self.tbRoom[nRoomId]:IsRoomStart() == 1 or self.tbRoom[nRoomId]:IsRoomFinished() == 1 then
		return 0;
	end
	self.tbRoom[nRoomId]:StartRoom();
	self.nCurrentRoomId = nRoomId;
	if self.tbStartCount and self.tbStartCount[nRoomId] then
		self.tbStartCount[nRoomId] = self.tbStartCount[nRoomId] + 1;
	end
end

--失败后重新开启这一关
function tbBase:StartCurrentRoom()
	if not self.tbRoom[self.nCurrentRoomId] then
		return 0;
	end
	if not self.tbRoom[self.nCurrentRoomId] then
		Dbg:WriteLog("ChenChongZhen","Start Room Failed!",self.nMapId,self.nServerId,self.nPlayerId);
		return 0;
	end
	if self.tbRoom[self.nCurrentRoomId]:IsRoomStart() == 1 or self.tbRoom[self.nCurrentRoomId]:IsRoomFinished() == 1 then
		return 0;
	end
	self.tbRoom[self.nCurrentRoomId]:StartRoom();
	if self.tbStartCount and self.tbStartCount[self.nCurrentRoomId] then
		self.tbStartCount[self.nCurrentRoomId] = self.tbStartCount[self.nCurrentRoomId] + 1;
	end
end

--开启下一个房间
function tbBase:StartNextRoom()
	if self.tbRoom[self.nCurrentRoomId]:IsRoomFinished() ~= 1 then
		return 0;
	end
	self.nCurrentRoomId = self.nCurrentRoomId + 1;
	if self.nCurrentRoomId >= ChenChongZhen.MAX_ROOM_COUNT then
		self.nCurrentRoomId = ChenChongZhen.MAX_ROOM_COUNT;
	end
	if not self.tbRoom[self.nCurrentRoomId] then
		Dbg:WriteLog("ChenChongZhen","Start Room Failed!",self.nMapId,self.nServerId,self.nPlayerId);
		return 0;
	end
	self.tbRoom[self.nCurrentRoomId]:StartRoom();
	if self.tbStartCount and self.tbStartCount[self.nCurrentRoomId] then
		self.tbStartCount[self.nCurrentRoomId] = self.tbStartCount[self.nCurrentRoomId] + 1;
	end
end


--房间结束
function tbBase:RoomFinish()
	self.nTransferRoomMaxId = self.nTransferRoomMaxId + 1;
	if self.nTransferRoomMaxId >= ChenChongZhen.MAX_ROOM_COUNT then
		self.nTransferRoomMaxId = ChenChongZhen.MAX_ROOM_COUNT;
	end
	if self.tbFinishInfo and self.tbFinishInfo[self.nCurrentRoomId] then
		self.tbFinishInfo[self.nCurrentRoomId] = 1;	--标记通过
	end
	self:AddWeiwang();	--加江湖威望
	self:FinishAchievement();	--完成成就
	if self.nCurrentRoomId == ChenChongZhen.MAX_ROOM_COUNT then
		self:DelFireEye();	--先删除火眼
		if self.nGameTimerId and self.nGameTimerId > 0 then
			Timer:Close(self.nGameTimerId);
			self.nGameTimerId = 0;
		end
		self:AddActive();
		self.nEndTimer = Timer:Register(ChenChongZhen.FINISH_TIME * Env.GAME_FPS, self.FinishEnd, self);
		self:UpdateEndUi();	--更新ui 
		self:PlayerMsg("Phong Tụ và Phù Anh chìm trong biển lửa, từ đó Thần Trùng Trấn cũng không còn ai nhắc đến!");
	end
	if self.nCurrentRoomId < ChenChongZhen.MAX_ROOM_COUNT then
		self:RevivePlayerAfterFinish();
	else
		self:CreateTimer(ChenChongZhen.REVIVE_DELAY,self.RevivePlayerAfterFinish,self);
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
	for i = 1,#ChenChongZhen.tbRoom do
		self.tbRoom[i] = Lib:NewClass(ChenChongZhen.tbRoom[i]);
		self.tbRoom[i].tbBase = self;
	end
end

function tbBase:InitLogInfo()
	self.tbFinishInfo = {0,0,0,0,0,0,0};
	self.tbStartCount = {0,0,0,0,0,0,0};
	self.nStartTime = GetTime();
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
		tbLeavePos	= {ChenChongZhen.LEAVE_POS[1]},	-- 离开坐标
		tbDeathRevPos = {},		-- 死亡重生点
		nOnDeath = 1, 			-- 死亡脚本可用
		nDeathPunish = 1,
		nPkState = Player.emKPK_STATE_PRACTISE,
	};
	for i = 1 ,#ChenChongZhen.ENTER_POS do
		table.insert(self.tbMisCfg.tbEnterPos, {self.nMapId, unpack(ChenChongZhen.ENTER_POS[i])});
		table.insert(self.tbMisCfg.tbDeathRevPos, {self.nMapId, unpack(ChenChongZhen.ENTER_POS[i])});
	end
	self.szUiStateMsg = "";
	self.tbFireEye = {};	--记录火眼
	self.tbRoom7Horse = {};	--记录马匹
	self.tbDropItemInfo = {};	--记录掉落的东西
	self.tbRoomDropInfo = {0,0,0,0,0,0,0};	--记录某关是否已经掉落过,防止有些剧情中玩家死亡重新开启刷奖励
	self.nTransferRoomMaxId = 1;	--路路通可以传送
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
	local nUseTime = GetTime() - self.nStartTime;
	StatLog:WriteStatLog("stat_info","chenchongzhen","over",self.nPlayerId,
		self.tbStartCount[1] or 0,
		self.tbStartCount[2] or 0,
		self.tbStartCount[3] or 0,
		self.tbStartCount[4] or 0,
		self.tbStartCount[5] or 0,
		self.tbStartCount[6] or 0,
		self.tbStartCount[7] or 0,
		nPassRoom,
		nUseTime);	--数据埋点
	self:WriteDropLog();	--记录掉落埋点
	self:Close();
	GCExcute{"ChenChongZhen:EndGame_GC",self.nPlayerId,self.nServerId,self.nMapId};
end

--申请完之后就开启了
function tbBase:GameStart()
	--如果已经开启，不进行游戏开启操作
	if self.nIsGameStart == 1 then
		return 0;
	end
	self.nGameTimerId = Timer:Register(ChenChongZhen.MAX_TIME * Env.GAME_FPS, self.GameTimeUp, self);
	self.nIsGameStart = 1;
	self:StartRoom(1);	--游戏开启就开启第一关
	self:AddFireEye();
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
	self:ChangeWeather();	--恢复天气
	ClearMapNpc(self.nMapId);
end

--离开时
function tbBase:OnLeave()
	--活着的玩家掉线后，应该进行房间是否失败处理
	if self.tbRoom and self.tbRoom[self.nCurrentRoomId] then
		local nIsFailed = self:CheckAllPlayerDeath();
		if nIsFailed == 1 then
			self.tbRoom[self.nCurrentRoomId]:FailedRoom();
			self:RevivePlayerAfterFailed();
		end
	end
	self:CloseSingleUi(me);	
	self:UpdateGameUi();	-- 更新人数
	self:DelHorse();		-- 出副本删除马
	me.SetFightState(0);	-- 非战斗状态
	me.SetLogoutRV(0);		-- 解除服务器宕机保护
	me.DisabledStall(0);	-- 允许摆摊
	me.DisableOffer(0);		-- 允许贩卖
	me.SetTask(2191, 5, 0);
end

function tbBase:OnJoin(nGroupId)
	if self.tbLogOutPlayer[me.nId] == nil then
		ChenChongZhen:ConsumePlayerItem(me);
	end
	self.tbLogOutPlayer[me.nId] = 1;
	me.SetLogoutRV(1);			-- 服务器宕机保护
	me.DisabledStall(1);		-- 禁止摆摊
	me.DisableOffer(1);			-- 禁止贩卖
	self:OpenSingleUi(me);
	self:UpdateGameUi();		-- 更新ui
	me.SetFightState(0);		-- 非战斗状态
	me.SetTask(2191, 5, 1);
end

function tbBase:DelHorse()
	local tbGdpl = {1,12,62,1};
	local pHorse = me.GetEquip(Item.EQUIPPOS_HORSE);
	local nIsEquipHorse = 0;
	if pHorse and pHorse.SzGDPL() == string.format("%s,%s,%s,%s",tbGdpl[1],tbGdpl[2],tbGdpl[3],tbGdpl[4]) then
		me.DelItem(pHorse);
	end
	local tbFind = me.FindItemInAllPosition(unpack(tbGdpl));
	if #tbFind > 0 then
		for _,tbItem in pairs(tbFind) do
			if tbItem.pItem then
				me.DelItem(tbItem.pItem);
			end
		end
	end
end


function tbBase:FindLogOutPlayer(nPlayerId)
	if not self.tbLogOutPlayer[nPlayerId] or self.tbLogOutPlayer[nPlayerId] ~= 1 then
		return 0;
	end
	return 1;
end

--检测是否所有玩家死亡，如果死亡，当前关卡失败，所有玩家复活到重生点
function tbBase:CheckAllPlayerDeath()
	local tbPlayer,nPlayerCount = self:GetPlayerList();
	local nCount = 0;
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			if pPlayer.IsDead() == 1 or (self.nTransferRoomMaxId > 1 and pPlayer.GetTask(2191, 5) == 1) then
				nCount = nCount + 1;
			end
		end
	end
	if nCount ~= nPlayerCount then
		return 0;
	else
		return 1;
	end
end

--某关失败后复活玩家到起始点
function tbBase:RevivePlayerAfterFailed()
	local tbPlayer = self:GetPlayerList();
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			if pPlayer.IsDead() == 1 then
				pPlayer.ReviveImmediately(0);
				if pPlayer.nFightState == 1 then	--恢复战斗状态
					pPlayer.SetFightState(0)
				end
			end
			pPlayer.SetTask(2191, 5, 0);
		end
	end
end

--某关完成后原地复活玩家
function tbBase:RevivePlayerAfterFinish()
	local tbPlayer = self:GetPlayerList();
	local tbPos = ChenChongZhen.tbRevivePos[self.nCurrentRoomId];
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			if pPlayer.IsDead() == 1 then
				pPlayer.ReviveImmediately(1);
				pPlayer.SetFightState(1);
			end
			if tbPos then
				pPlayer.NewWorld(self.nMapId,tbPos[1],tbPos[2]);
				pPlayer.SetFightState(1);
			end
			pPlayer.SetTask(2191, 5, 0);
		end
	end
	return 0;
end

--死亡
function tbBase:OnDeath()
	me.CallClientScript({"UiManager:CloseWindow","UI_RENASCENCEPANEL"});	--关闭复活界面
	if self.nCurrentRoomId ~= 7 then
		self:BlackBoard(me,"Ngươi đã bị trọng thương");
	else
		self:BlackBoard(me,"Ngươi mất đi dị thú che chở, đã bị biển lửa thiêu đốt trọng thương");
	end
	local nIsFailed = self:CheckAllPlayerDeath();
	if nIsFailed == 1 then
		self.tbRoom[self.nCurrentRoomId]:FailedRoom();
		self:RevivePlayerAfterFailed();
	end
	me.SetTask(2191, 5, 0);
end

function tbBase:CheckAllPlayerLock()
	local tbPlayer = self:GetPlayerList();
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			if pPlayer.GetTask(2191, 5) == 0 then
				return 0;
			end
		end
	end	
	return 1;
end

function tbBase:UnlockAllPlayer()
	local tbPlayer = self:GetPlayerList();
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			pPlayer.SetTask(2191, 5, 0);
		end
	end
end

--trap 处理
function tbBase:ProcessTrap(szTrapName)
	if szTrapName == "trap_join" then
		if self:CheckAllPlayerLock() == 0 and self.nTransferRoomMaxId > 1 and me.GetTask(2191, 5) == 1 then
			Dialog:SendBlackBoardMsg(me, "Vui lòng đợi trước khi tiếp tục chiến đấu!");
			me.SetFightState(0);
			local tbPos = ChenChongZhen.tbMapTrapName[szTrapName];
			if tbPos then
				me.NewWorld(me.nMapId, tbPos[1],tbPos[2]);
			end
		elseif me.nFightState == 0 then
			me.SetFightState(1);
			local tbPos = ChenChongZhen.FIGHT_STATE_POS[szTrapName];
			if tbPos then
				me.NewWorld(me.nMapId,tbPos[1],tbPos[2]);
				if self:CheckAllPlayerLock() == 1 then
					self:UnlockAllPlayer();
				else
					me.SetTask(2191, 5, 0);
				end
			end
		else
			me.SetFightState(0);
			local tbPos = ChenChongZhen.tbMapTrapName[szTrapName];
			if tbPos then
				me.NewWorld(me.nMapId, tbPos[1],tbPos[2]);
			end
		end
	elseif string.find(szTrapName,"trap_machine",1,1) then
		self:ProcessMachine(szTrapName);
	elseif szTrapName == "trap_room2" then	--第二关弹回点
		if self.tbRoom[2]:IsRoomStart() == 1 or self.tbRoom[2]:IsRoomFinished() == 1 then
			return 0;
		else
			local tbPos = ChenChongZhen.tbMapTrapName[szTrapName];
			if tbPos then
				me.NewWorld(me.nMapId, tbPos[1],tbPos[2]);
			end
		end
	elseif szTrapName == "trap_room3" then	--第三关弹回点
		if self.tbRoom[2]:IsRoomFinished() == 1 then
			return 0;
		else
			local tbPos = ChenChongZhen.tbMapTrapName[szTrapName];
			if tbPos then
				me.NewWorld(me.nMapId,tbPos[1],tbPos[2]);
			end
		end
	elseif szTrapName == "trap_room4" then	--第四关传送点
		if self.tbRoom[3]:IsRoomFinished() == 1 then
			local tbPos = ChenChongZhen.tbMapTrapName[szTrapName];
			if tbPos then
				me.NewWorld(me.nMapId,tbPos[1],tbPos[2]);
			end
		else
			return 0;
		end
	elseif szTrapName == "trap_room5" then	--第五关传送点
		if self.tbRoom[4]:IsRoomFinished() == 1 then
			local tbPos = ChenChongZhen.tbMapTrapName[szTrapName];
			if tbPos then
				me.NewWorld(me.nMapId,tbPos[1],tbPos[2]);
				me.RemoveSkillState(2566);
				me.RemoveSkillState(2587);
			end
		else
			return 0;
		end
	elseif szTrapName == "trap_room6" then	--第六关弹回点
		if self.tbRoom[5]:IsRoomFinished() ~= 1 then
			local tbPos = ChenChongZhen.tbMapTrapName[szTrapName];
			if tbPos then
				me.NewWorld(me.nMapId,tbPos[1],tbPos[2]);
			end
		else
			return 0;
		end
	elseif szTrapName == "trap_room5_trans" then	--第六关弹回点
		if self.tbRoom[4]:IsRoomFinished() == 1 then
			local tbPos = ChenChongZhen.tbMapTrapName[szTrapName];
			if tbPos then
				me.NewWorld(me.nMapId,tbPos[1],tbPos[2]);
			end
		else
			return 0;
		end
	end	
end

--第一关的机关处理
function tbBase:ProcessMachine(szTrapName)
	if self.nCurrentRoomId ~= 1 then
		return 0;
	end
	self.tbRoom[self.nCurrentRoomId]:ProcessMachine(szTrapName);
end

--第二关的剧情开始
function tbBase:ProcessRoom2Start(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	else
		pNpc.Delete();
		if self.tbRoom[self.nCurrentRoomId].StartMovie then
			self.tbRoom[self.nCurrentRoomId]:StartMovie();	--第二关开启剧情
		end
	end
end


function tbBase:StartRoom4Light()
	if self.nCurrentRoomId ~= 4 then
		return 0;
	end
	self.tbRoom[self.nCurrentRoomId]:StartFireLight();
end

function tbBase:ProcessRoom4FireLight(nIsCorrect,nNpcId,nX,nY)
	if self.nCurrentRoomId ~= 4 then
		return 0;
	end
	self.tbRoom[self.nCurrentRoomId]:ProcessFireLight(nIsCorrect,nNpcId,nX,nY);
end

function tbBase:ProcessRoom4NotifyLight()
	if self.nCurrentRoomId ~= 4 then
		return 0;
	end
	self.tbRoom[self.nCurrentRoomId]:ApplyNotifyLight();
end

function tbBase:GetRoom4ErrorLightCount()	--获取点错的灯的数量
	if self.nCurrentRoomId ~= 4 then
		return 0;
	end
	return self.tbRoom[self.nCurrentRoomId]:GetErrorCount();
end

function tbBase:GetRoom4LightIsBegin()
	if self.nCurrentRoomId ~= 4 then
		return 0;
	end
	return self.tbRoom[self.nCurrentRoomId]:GetIsLightBegin();
end


function tbBase:ProcessRoom7Switch(nPlayerId)
	if self.nCurrentRoomId ~= 7 then
		return 0;
	end
	self.tbRoom[self.nCurrentRoomId]:ProcessSwitch(nPlayerId);
end

function tbBase:IsPlayerOpenedRoom7Switch(nPlayerId)
	if self.nCurrentRoomId ~= 7 then
		return 0;
	end
	return self.tbRoom[self.nCurrentRoomId]:IsPlayerOpened(nPlayerId);
end


function tbBase:AddRoom7Horse()
	if self:IsOpen() ~= 1 then
		return 0;
	end
	if self.nIsHorseAdded and self.nIsHorseAdded == 1 then
		return 0;
	end
	self.nIsHorseAdded = 1;
	self.tbRoom7Horse = {};
	local nTempId = ChenChongZhen.tbRoom7Horse[1];
	local tbPos = ChenChongZhen.tbRoom7Horse[2];
	for _,tb in pairs(tbPos) do
		local pNpc = KNpc.Add2(nTempId,1,-1,self.nMapId,tb[1],tb[2]);
		if pNpc then
			table.insert(self.tbRoom7Horse,{pNpc.dwId,tb[1],tb[2]});
		end
	end
	self:CreateTimer(ChenChongZhen.nRoom7AddHorseDelay,self.OnAddHorse,self);
end

function tbBase:OnAddHorse()
	if self:IsOpen() ~= 1 then
		return 0;
	end
	if not self.tbRoom7Horse then
		self.tbRoom7Horse = {};
	end
	local nTempId = ChenChongZhen.tbRoom7Horse[1];
	for nIndex,tbInfo in pairs(self.tbRoom7Horse) do
		local pOld = KNpc.GetById(tbInfo[1]);
		if not pOld then
			local pNpc = KNpc.Add2(nTempId,1,-1,self.nMapId,tbInfo[2],tbInfo[3]);
			if pNpc then
				self.tbRoom7Horse[nIndex] = {pNpc.dwId,tbInfo[1],tbInfo[2]};
			end
		end
	end
end

function tbBase:AddFireEye()
	if not self.tbFireEye then
		self.tbFireEye = {};
	end
	local nTempId = ChenChongZhen.tbRoom7FireEyeInfo[1];
	local tbPos = ChenChongZhen.tbRoom7FireEyeInfo[2];
	for _,tb in pairs(tbPos) do
		local pNpc = KNpc.Add2(nTempId,125,-1,self.nMapId,tb[1],tb[2]);	
		if pNpc then
			table.insert(self.tbFireEye,{pNpc.dwId,tb[1],tb[2]});
		end
	end
	self:CreateTimer(ChenChongZhen.nRoom7FireEyeCastSkillDelay,self.OnFireCastSkill,self);
end

function tbBase:OnFireCastSkill()
	if not self.tbFireEye then
		return 0;
	end
	for _,tbInfo in pairs(self.tbFireEye) do
		local pNpc = KNpc.GetById(tbInfo[1]);
		if pNpc then
			pNpc.CastSkill(ChenChongZhen.nRoom7FireEyeSkillId,20,tbInfo[2]*32,tbInfo[3]*32);
		end
	end
end

function tbBase:DelFireEye()
	if not self.tbFireEye then
		return 0;
	end
	for _,tbInfo in pairs(self.tbFireEye) do
		local pNpc = KNpc.GetById(tbInfo[1]);
		if pNpc then
			pNpc.Delete();
		end
	end
	self.tbFireEye = {};
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
	local szMsg = "<color=green>Thời gian đóng phó bản<color> <color=white>%s<color>"
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
	local szMsg = "<color=green>Thời gian đóng phó bản<color> <color=white>%s<color>"
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

function tbBase:PlayerMsg(szMsg)
	if not szMsg or #szMsg == 0 then
		return 0;
	end
	local tbPlayer = self:GetPlayerList();
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			pPlayer.Msg(szMsg,"Hệ thống");
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
		local tbNearPlayer = KNpc.GetAroundPlayerList(nNpcId,60);
		if tbNearPlayer then
			for _, pPlayer in ipairs(tbNearPlayer) do
				pPlayer.Msg("<color=white>" .. szChat .. "<color>", pNpc.szName);
			end
		end
	else
		return 0;
	end
end

--改变天黑
function tbBase:ChangeWeather(bDark)
	if bDark and bDark == 1 then
		ChangeWorldWeather(self.nMapId,1);
	else
		ChangeWorldWeather(self.nMapId,0);
	end
end
	
	
function tbBase:DropBox()
	if self.tbRoomDropInfo[self.nCurrentRoomId] == 1 then
		return 0;
	end
	local nTempId = ChenChongZhen.nDropItemBoxTemplateId;
	local tbInfo = ChenChongZhen.tbBoxInfo;
	local tbPos  = tbInfo[self.nCurrentRoomId];
	if not tbPos then
		return 0;
	end
	local pNpc = KNpc.Add2(nTempId,1,-1,self.nMapId,tbPos[1],tbPos[2]);
	if pNpc then
		self.tbRoomDropInfo[self.nCurrentRoomId] = 1;
		pNpc.GetTempTable("ChenChongZhen").nRoomId = self.nCurrentRoomId;
		Npc:RegDeathLoseItem(pNpc,self.OnBossDrop,self);	--掉落回调
	end
end

	
function tbBase:NpcDropItem(pNpc)
	if not pNpc then
		return 0;
	end
	if self.tbRoomDropInfo[self.nCurrentRoomId] == 1 then
		return 0;
	end
	local tbPlayer = KNpc.GetAroundPlayerList(pNpc.dwId,80);
	local pPlayer = tbPlayer[MathRandom(#tbPlayer)];
	local nId = pPlayer and pPlayer.nId or 0;
	local tbInfo = ChenChongZhen.tbDropRateInfo[self.nCurrentRoomId];
	if not tbInfo then
		return 0;
	end
	for _,tb in pairs(tbInfo) do
		local szFile = tb[1];
		local nCount = tb[2];
		if szFile and nCount then
			pNpc.DropRateItem(szFile,nCount,0,-1,nId); 
		end
	end
	self.tbRoomDropInfo[self.nCurrentRoomId] = 1;
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
		StatLog:WriteStatLog("stat_info","chenchongzhen","product",0,szGdpl,nCount);		
	end
end

function tbBase:AddWeiwang()
	local tbPlayer = self:GetPlayerList();
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			pPlayer.AddKinReputeEntry(ChenChongZhen.nRepute,"newcangbaotu");
		end	
	end
end

function tbBase:AddActive()
	local tbPlayer = self:GetPlayerList();
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			SpecialEvent.ActiveGift:AddCounts(pPlayer,48);	--完成辰虫镇活跃度
		end	
	end
end

function tbBase:FinishAchievement()
	local nId = ChenChongZhen.tbAchievement[self.nCurrentRoomId];
	if nId then
		local tbPlayer = self:GetPlayerList();
		for _,pPlayer in pairs(tbPlayer) do
			if pPlayer then
				Achievement:FinishAchievement(pPlayer,nId);	--成就
			end
		end
	end	
end

