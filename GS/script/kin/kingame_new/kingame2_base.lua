-- 文件名　：kingame2_base.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-06-15 15:55:58
-- 描述：新家族关卡mission

local tbBase = Mission:New();
KinGame2.tbBase = tbBase;

--关卡是否已经开启
function tbBase:IsStart()
	return self.nIsGameStart or 0;
end

--开启第几个房间
function tbBase:StartRoom(nRoomId)
	if not nRoomId or nRoomId <= 0 or nRoomId > KinGame2.MAX_ROOM_NUM then
		return 0 ;
	end
	if self.tbRoom[nRoomId] then
		self.tbRoom[nRoomId]:StartRoom();
		self.nCurrentStepRoom = nRoomId;
	end
end



--房间关闭的回调
function tbBase:RoomFinish(nRoomId,nRet)
	if not nRoomId or nRoomId <= 0 or nRoomId > KinGame2.MAX_ROOM_NUM then
		return 0;
	end
	if not nRet or nRet == 0 then
		self.tbRoomFinishInfo[nRoomId] = 0;
		self:HandleFailRoom(nRoomId);
	elseif nRet == 1 then
		self.tbRoomFinishInfo[nRoomId] = 1;
		self:HandleSucessRoom(nRoomId);
	end
	if nRoomId == 7 and nRet == 0 then	--最后一个房间失败了，直接计算关卡是否成功(成功的地方在游龙那进行)
		self:HandleAllPassInfo();
	end
end

--计算全部的通过情况
function tbBase:HandleAllPassInfo()
	local nPassRoom = 0;
	for _,nFinish in pairs(self.tbRoomFinishInfo) do
		if nFinish == 1 then
			nPassRoom = nPassRoom + 1;
		end
	end
	if nPassRoom >= KinGame2.MIN_PASS_ROOM_NUM then	
		local cKin = KKin.GetKin(self.nKinId);
		if cKin and self.nGameLevel > cKin.GetKinGame2LastPassLevel() then
			GCExcute{"KinGame2:SetLastPassLevel_GC",self.nKinId,self.nGameLevel};
		end
		self:SetPlayerPassTask();
		self:WriteFinishLog(1,nPassRoom);
		--圣诞活动额外插入
		if SpecialEvent.Xmas2011:IsEventOpen() == 1 then
			local tbPos = KinGame2.XIMENFEIXUE_POS;
			SpecialEvent.Xmas2011:AddKinGameXmasBoss(2,self.nMonsterAvgLevel,self.nMapId,tbPos[1],tbPos[2]);		
			self:AllBlackBoard("圣诞Boss即将出现，请大家做好迎战准备！");
		end
	else
		self:WriteFinishLog(2,nPassRoom);
	end
	self.nIsPassAll = 1;	--已经挑战完了7个boss
	local szColor = nPassRoom >= KinGame2.MIN_PASS_ROOM_NUM and "green" or "red";
	local szSucess = nPassRoom >= KinGame2.MIN_PASS_ROOM_NUM and "挑战成功" or "挑战失败";
	local szStateMsg = string.format("当前通关率:%d/%d <color=%s>(%s)<color>",nPassRoom,KinGame2.MAX_ROOM_NUM,szColor,szSucess);
	szStateMsg = szStateMsg .. "\n\n<color=green>家族关卡挑战完成<color>"
	self:UpdateUiState(nil,nil,szStateMsg);
	self:AddFriendFavor(self.nMapId);	--关卡结束加好友亲密
	self:AddAllPlayerKinReputeEntry();	--加江湖威望
end


--处理房间失败
function tbBase:HandleFailRoom(nRoomId)
	if nRoomId == 1 or nRoomId == 2 then
		self:StartRoom(nRoomId + 1);
	end
end

--处理房间通过
function tbBase:HandleSucessRoom(nRoomId)
	if nRoomId == 1 or nRoomId == 4 or nRoomId == 7 then
		KinGame2:RandomGameAfterRoomBingo(nRoomId,self.nMapId);
	end
	if nRoomId == 2 then
		self:StartRoom(nRoomId + 1);
	end	
end

--获取当前进行到第几个房间id
function tbBase:GetCurrentStepRoomId()
	return self.nCurrentStepRoom or 0;
end

--获取当前进行的房间
function tbBase:GetCurrentRoom()
	return self.tbRoom[self.nCurrentStepRoom];
end

--初始化trap占位npc
function tbBase:InitTrapNpc()
	self.tbTrapNpc = {};
	for nRoomId , tbPosA in pairs(KinGame2.TRAP_NPC_POS) do
		for nDirection,tbPos in pairs(tbPosA) do
			if tbPos then
				for _,tb in pairs(tbPos) do
					local pNpc = KNpc.Add2(KinGame2.nTrapNpcTemplateId,10,-1,self.nMapId,tb[1],tb[2]);
					if not self.tbTrapNpc[nRoomId] then
						self.tbTrapNpc[nRoomId] = {};
					end
					if not self.tbTrapNpc[nRoomId][nDirection] then
						self.tbTrapNpc[nRoomId][nDirection] = {};
					end
					if pNpc then
						pNpc.GetTempTable("KinGame2").nRoomId = nRoomId;
						pNpc.GetTempTable("KinGame2").nDirection = nDirection;
						table.insert(self.tbTrapNpc[nRoomId][nDirection],pNpc);
					end
				end
			end			
		end
	end
end

--初始化开关npc
function tbBase:InitSwitchNpc()
	for nRoomId , tbPosA in pairs(KinGame2.TRAP_SWITCH_NPC_POS) do
		for nDirection,tbPos in ipairs(tbPosA) do
			if nRoomId ~= 4 and nRoomId ~= 7 then	--4号房间的解锁柱子在第三关npc清理完成后才刷出来
				local pNpc = KNpc.Add2(nRoomId == 1 and KinGame2.nOpenGameNpcTemplateId or KinGame2.nTrapSwitchNpcTemplateId,10,-1,self.nMapId,tbPos[1],tbPos[2]);
				if pNpc then
					pNpc.GetTempTable("KinGame2").nRoomId = nRoomId;
					pNpc.GetTempTable("KinGame2").nDirection = nDirection;
				end
			end			
		end
	end
end


--删除障碍npc
function tbBase:DelTrapNpc(nRoomId,nDirection)
	if not nRoomId or not self.tbRoom[nRoomId] then
		return 0;
	end
	for  _,pNpc in pairs(self.tbTrapNpc[nRoomId][nDirection or 1]) do
		if pNpc then
			pNpc.Delete();
		end
	end
end

--设置整个关卡的难度
function tbBase:SetGameDifficulty(nLevel)
	self.nGameLevel = nLevel or 1;
end

--计算平均等级，也就是怪物刷出来的等级
function tbBase:CalAvgLevel()
	local tbPlayer,nCount = self:GetPlayerList();
	if nCount <= 0 then
		return KinGame2.MIN_MONSTER_LEVEL;
	end
	local nLevel = 0;
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer then
			nLevel = nLevel + pPlayer.nLevel;
		end
	end
	return math.floor(nLevel / nCount);
end

--设置怪物的平均等级,在startgame的时候进行调用
function tbBase:SetMonsterAvgLevel()
	local nLevel = self:CalAvgLevel();
	self.nMonsterAvgLevel = nLevel;
end

--玩家是否报过名,如果报过名，掉线了可以再进来
function tbBase:FindLogOutPlayer(nPlayerId)
	if self.tbLogOutPlayer[nPlayerId] then
		return 1;
	end
	return 0;
end

--初始化room
function tbBase:InitRoom()
	self.tbRoom = {};
	for i = 1 ,#KinGame2.tbRoom do
		self.tbRoom[i] = Lib:NewClass(KinGame2.tbRoom[i]);
		self.tbRoom[i].tbBase = self;
	end
end

--初始化mission
function tbBase:InitGame(nMapId, nCityMapId, nKinId)
	self.tbRoomFinishInfo = {};	--记录每个小关卡的完成情况
	for i = 1,KinGame2.MAX_ROOM_NUM do
		self.tbRoomFinishInfo[i] = 0;
	end
	self.tbLogOutPlayer = {};	--记录已经报名的玩家，可以让报名的玩家掉线了再进来
	self.tbDrinkPlayer = {};	--已经领取过酒的玩家
	self.tbGetBookPlayer = {};	--已经捡取过书的玩家
	self.nMapId = nMapId;
	self.nCityMapId = nCityMapId;
	self.nKinId = nKinId;
	--创建房间copy
	self:InitRoom();
	self.tbMisCfg = 
	{
		nPkState =  Player.emKPK_STATE_EXTENSION;	--自定义阵营模式，掉落的东西可以所有人捡
		nForbidSwitchFaction = 1,
		tbEnterPos = {},
		tbLeavePos	= {[1] = {nCityMapId, unpack(KinGame2.LEAVE_POS[nCityMapId])}},	-- 离开坐标
		tbDeathRevPos = {[1] = {self.nMapId,unpack(KinGame2.DEATH_POS)}},		-- 死亡重生点
		nOnDeath = 1, 		-- 死亡脚本可用
		nDeathPunish = 1,
	}
	for i = 1 ,#KinGame2.ENTER_POS do
		table.insert(self.tbMisCfg.tbEnterPos, {self.nMapId, unpack(KinGame2.ENTER_POS[i])});
	end
	self.nIsGameStart = 0;
	self.nMonsterAvgLevel = KinGame2.MIN_MONSTER_LEVEL;
	self.nGameLevel = 1;
	self.nCurrentStepRoom = 0;
	self.nIsPassAll = 0;
	self.szUiStateMsg = "关卡还未开启";
	self.nStartTimer = Timer:Register(KinGame2.WAIT_TIME * Env.GAME_FPS, self.OnStartTimer, self);	--游戏控制的timer
	self.nGameTimerId = 0;
	self:InitSwitchNpc();
	self:InitTrapNpc();
	self:Open();
end


--增加喷火npc
function tbBase:AddFireTrapNpc()
	if not self.tbTrapFire then
		self.tbTrapFire = {};
	end
	if not self.tbTrapFireLong then
		self.tbTrapFireLong = {};
	end
	for i = 1 , #KinGame2.TRAP_FIRE_POS do
		local tbPos = KinGame2.TRAP_FIRE_POS[i];
		local pNpc = KNpc.Add2(KinGame2.TRAP_FIRE_NPC_TEMPLATEID,self.nMonsterAvgLevel,0,self.nMapId,tbPos[1],tbPos[2]);
		if pNpc then
			self.tbTrapFire[i] = pNpc;
			pNpc.AddFightSkill(1475,1,1);
		end
	end
	for i = 1, #KinGame2.TRAP_FIRE_LONG_POS do
		local tbPos = KinGame2.TRAP_FIRE_LONG_POS[i];
		local pNpc = KNpc.Add2(KinGame2.TRAP_FIRE_NPC_TEMPLATEID,self.nMonsterAvgLevel,0,self.nMapId,tbPos[1],tbPos[2]);
		if pNpc then
			self.tbTrapFireLong[i] = pNpc;
			pNpc.AddFightSkill(1475,1,1);
		end
	end
	self:OnCastFire();
	self.nOnCastFireTimer = Timer:Register(KinGame2.TRAP_FIRE_CAST_DELAY * Env.GAME_FPS, self.OnCastFire, self);
end

--喷火npc 喷火
function tbBase:OnCastFire()
	for i = 1 , #KinGame2.TRAP_FRIE_CAST_POS do
		local pNpc = self.tbTrapFire[i];
		local tbPos = KinGame2.TRAP_FRIE_CAST_POS[i];
		if pNpc and tbPos[1] and tbPos[2] then
			pNpc.CastSkill(KinGame2.TRAP_FIRE_SKILL_ID,10,tbPos[1],tbPos[2]);
		end
	end
	for i = 1 , #KinGame2.TRAP_FIRE_LONG_CAST_POS do
		local pNpc = self.tbTrapFireLong[i];
		local tbPos = KinGame2.TRAP_FIRE_LONG_CAST_POS[i];
		if pNpc and tbPos[1] and tbPos[2] then
			pNpc.CastSkill(KinGame2.TRAP_FIRE_LONG_SKILL_ID,10,tbPos[1],tbPos[2]);
		end
	end
end

--清除喷火npc
function tbBase:ClearFireTrap()
	if not self.tbTrapFire then
		return 0;
	end
	if self.nOnCastFireTimer and self.nOnCastFireTimer > 0 then
		Timer:Close(self.nOnCastFireTimer);
		self.nOnCastFireTimer = 0;
	end
	ClearMapNpcWithTemplateId(self.nMapId,KinGame2.TRAP_FIRE_NPC_TEMPLATEID);
end

--mission开启后的10分钟控制
function tbBase:OnStartTimer()
	self.nStartTimer = 0;
	if self.nIsGameStart == 1 then
		return 0;
	end
	local cKin = KKin.GetKin(self.nKinId);
	local nLevel = cKin.GetKinGame2LastPassLevel();
	if nLevel <= 0 then
		nLevel = 1;
	end
	self:SetGameDifficulty(nLevel);
	self:DelTrapNpc(1);
	self:GameStart();
	return 0;
end

--开始游戏
function tbBase:GameStart()
	--如果已经开启，不进行游戏开启操作
	if self.nIsGameStart == 1 then
		return 0;
	end
	local nCount = self:GetPlayerCount();
	if nCount < KinGame2.MIN_PLAYER then
		self:WriteOpenLog(0);	--人数不足没有开启的log
		self:EndGame(0);
		return 0;
	end	
	if self.nStartTimer and self.nStartTimer > 0 then
		Timer:Close(self.nStartTimer);
		self.nStartTimer = 0;
	end
	self.nGameTimerId = Timer:Register(KinGame2.MAX_TIME * Env.GAME_FPS, self.GameTimeUp, self);
	self.nIsGameStart = 1;
	self:SetMonsterAvgLevel();
	self:OpenEveryOneUi();
	self:RecordKinGameNum();
	self:AddAllPlayerDebuff();	--给玩家加debuff
	self:AddFireTrapNpc();	--加障碍火npc
	self:StartRoom(1);	--1号房间开启
	--记录埋点
	self:WriteJoinLog();
	self:WriteOpenLog(1);
end

--游戏时间到了
function tbBase:GameTimeUp()
	self.nGameTimerId = 0;
	if self.nIsPassAll ~= 1 then
		self:WriteFinishLog(2,nPassRoom);
	end
	self:EndGame();
	return 0;
end

--结束mission
function tbBase:EndGame(nRet)
	if self.nStartTimer and self.nStartTimer > 0 then
		Timer:Close(self.nStartTimer);
		self.nStartTimer = 0;
	end
	if self.nGameTimerId and self.nGameTimerId > 0 then
		Timer:Close(self.nGameTimerId);
		self.nGameTimerId = 0;
	end
	for i = 1 ,#self.tbRoom do
		self.tbRoom[i]:ClearRoom();
		self.tbRoom[i] = nil;
	end
	self:ClearFireTrap();	--关闭时候清楚地图上障碍喷火npc
	self:Close();
	ClearMapNpc(self.nMapId);
	KinGame2:EndGame_GS1(self.nKinId, self.nMapId, self.nCityMapId, nRet);
end

function tbBase:JoinGame(pPlayer)
	if self.nIsGameStart == 1 and self.tbLogOutPlayer[pPlayer.nId] == nil then
		return 0;
	end
	if self.nIsGameStart == 1 and self.tbLogOutPlayer[pPlayer.nId] then
		self:AddPlayerDebuff(pPlayer);
		self:OpenSingleUi(pPlayer);
	end
	self.tbLogOutPlayer[pPlayer.nId] = 1;
	Achievement:FinishAchievement(pPlayer,393);	--成就
	pPlayer.SetLogoutRV(1);			-- 服务器宕机保护
	self:JoinPlayer(pPlayer, 1);	-- 只有一个阵营
	pPlayer.DisabledStall(1);		-- 禁止摆摊
	pPlayer.DisableOffer(1);		-- 禁止贩卖
	pPlayer.nExtensionGroupId = KinGame2.EXTENSION_CAMP_ID;	--设置成一个阵营
end


--死亡立即返回出生点
function tbBase:OnDeath(pKillerNpc)
	if pKillerNpc and pKillerNpc.nTemplateId == KinGame2.TRAP_FIRE_NPC_TEMPLATEID then
		Achievement:FinishAchievement(me,400);
	end
	me.ReviveImmediately(0);
end

function tbBase:OnLeave()
	me.SetFightState(0);	-- 非战斗状态
	self:CloseSingleUi(me);
	me.SetLogoutRV(0);		-- 解除服务器宕机保护
	me.DisabledStall(0);	-- 允许摆摊
	me.DisableOffer(0);		-- 允许贩卖
	self:RemoveBuff(me);	-- 移除debuff&buff
end

--游戏开启给玩家加个状态
function tbBase:AddPlayerDebuff(pPlayer)
	if pPlayer then
		--加状态
		pPlayer.AddSkillState(KinGame2.PLAYER_LEVEL_BUFF_ID,self.nGameLevel,0,KinGame2.PLAYER_DEBUFF_TIME * Env.GAME_FPS,1);
	end
end

--加所有人状态
function tbBase:AddAllPlayerDebuff()
	local tbPlayer,nCount = self:GetPlayerList();
	if nCount > 0 then
		for _,pPlayer in pairs(tbPlayer) do
			if pPlayer then
				self:AddPlayerDebuff(pPlayer);
			end
		end
	end
end

--移除状态
function tbBase:RemoveBuff(pPlayer)
	if pPlayer then
		--移除状态
		pPlayer.RemoveSkillState(KinGame2.PLAYER_LEVEL_BUFF_ID);
		pPlayer.RemoveSkillState(KinGame2.PLAYER_ADD_BUFF_ID);
	end
end

-- 记录玩家参加家族副本的次数
function tbBase:RecordKinGameNum()
	local tbPlayList = self:GetPlayerList();
	if (tbPlayList) then
		for _, pPlayer in ipairs(tbPlayList) do
			if pPlayer then
				Stats.Activity:AddCount(pPlayer, Stats.TASK_COUNT_KINGAME, 1);
				pPlayer.SetTask(KinGame2.TASK_GROUP_ID, KinGame2.TASK_NOW_WEEK_TIME, GetTime());
			end
		end
	end
end

--ui相关
function tbBase:OpenEveryOneUi()
	local tbPlayer = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayer) do
		if pPlayer then
			self:OpenSingleUi(pPlayer);
		end
	end
end

function tbBase:CloseEveryOneUi()
	local tbPlayer = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayer) do
		if pPlayer then
			self:CloseSingleUi(pPlayer)
		end
	end
end

function tbBase:OpenSingleUi(pPlayer)
	if pPlayer == 0 then
		return 0;
	end
	local nTimerId = self.nGameTimerId; --当前状态的计时器id	
	if nTimerId <= 0 then
		return 0;
	end
	local nLastFrameTime = tonumber(Timer:GetRestTime(nTimerId));
	local szMsg = "<color=green>距离副本结束还有<color><color=white>%s<color>"
	Dialog:SetBattleTimer(pPlayer,  szMsg, nLastFrameTime);
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
	local szMsg = string.format("\n\n当前参加人数：%s\n\n当前关卡星级：%s\n\n<color=yellow>%s<color>\n\n",nCount,self.nGameLevel,self.szUiStateMsg);
	Dialog:SendBattleMsg(pPlayer,szMsg);
end

function tbBase:CloseSingleUi(pPlayer)
	if pPlayer == nil then
		return 0;
	end
	Dialog:ShowBattleMsg(pPlayer,  0,  0); -- 关闭界面
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

--设置ui状态,并且更新
function tbBase:UpdateUiState(szMsg,nTimerId,szUiState)
	if not szUiState then
		szUiState = "";
	end
	if self.nGameTimerId and self.nGameTimerId <= 0 then
		return 0;
	end
	local nLastFrameTime = 0;
	if not szMsg or szMsg == "" or not nTimerId or nTimerId <= 0 then
		nLastFrameTime = tonumber(Timer:GetRestTime(self.nGameTimerId));
		szMsg = "<color=green>距离副本结束还有<color><color=white>%s<color>"
	else
		nLastFrameTime = tonumber(Timer:GetRestTime(nTimerId));
	end
	self.szUiStateMsg = szUiState;
	local tbPlayer = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayer) do
		if pPlayer then
			Dialog:SetBattleTimer(pPlayer, szMsg, nLastFrameTime);
			self:UpdateSingleUi(pPlayer);
		end
	end
end

-- 加物品奖励,每个房间的固定奖励
function tbBase:GiveAllPlayerAwardItem(nRoomId,nRet)
	if nRet ~= 1 then
		return 0;
	end
	local tbCoin = KinGame2.AWARD_COIN_ROOM[nRoomId];
	if not tbCoin or not tbCoin[self.nGameLevel] then
		return 0;
	end
	local tbPlayer = self:GetPlayerList();
	for i, pPlayer in pairs(tbPlayer) do
		if pPlayer then
			KinGame2:GiveAwardItem(pPlayer, tbCoin[self.nGameLevel]);
		end
	end
end

-- 每个随机事件的奖励
function tbBase:GiveAllPlayerAwardItemRandom(nRoomId,nLevel)
	if not nLevel or nLevel <= 0 then
		return 0;
	end
	local tbAward = KinGame2.AWARD_COIN_RANDOM[nRoomId];
	if not tbAward or not tbAward[nLevel] or not tbAward[nLevel][self.nGameLevel] then
		return 0;
	end
	local tbPlayer = self:GetPlayerList();
	for i, pPlayer in pairs(tbPlayer) do
		if pPlayer then
			KinGame2:GiveAwardItem(pPlayer,tbAward[nLevel][self.nGameLevel],1,nLevel);
		end
	end
end


-- 加声望
function tbBase:GiveAllPlayerRepute(nRoomId,nRet)
	if nRet ~= 1 then
		return 0;
	end
	local tbRepute = KinGame2.AWARD_REPUTE[nRoomId]
	if not tbRepute or not tbRepute[self.nGameLevel] then
		return 0;
	end
	local tbPlayer = self:GetPlayerList();
	for i, pPlayer in pairs(tbPlayer) do
		if pPlayer then
			pPlayer.AddRepute(KinGame2.KIN_REPUTE_CAMP, KinGame2.KIN_REPUTE_CALSS, tbRepute[self.nGameLevel]);
		end
	end
end

--加江湖威望
function tbBase:AddAllPlayerKinReputeEntry()
	local tbPlayer = self:GetPlayerList() or {};
	for _, pPlayer in pairs(tbPlayer) do
		if pPlayer and pPlayer.nLevel > 80 then
			pPlayer.AddKinReputeEntry(KinGame2.AWARD_REPUTE_JIANGHU[self.nGameLevel], "kingame");
		end
	end
end

--加经验
function tbBase:AddAllPlayerExp(nRoomId,nRet)
	local tbExp = KinGame.LevelBaseExp;
	local tbPlayer = self:GetPlayerList() or {};
	for _, pPlayer in pairs(tbPlayer) do
		if nRet == 1 then
			if tbExp[pPlayer.nLevel] and KinGame2.AWARD_EXP_SUCESS[nRoomId] then
				pPlayer.AddExp(tbExp[pPlayer.nLevel] * KinGame2.AWARD_EXP_SUCESS[nRoomId] * 60);
			end
		elseif nRet == 0 then
			if tbExp[pPlayer.nLevel] and KinGame2.AWARD_EXP_FAIL[nRoomId] then
				pPlayer.AddExp(tbExp[pPlayer.nLevel] * KinGame2.AWARD_EXP_FAIL[nRoomId] * 60);
			end
		end
	end
end

-- 加好友亲密度
function tbBase:AddFriendFavor(nMapId)
	local tbPlayer, nCount = KPlayer.GetMapPlayer(nMapId);
	for _, pPlayer in ipairs(tbPlayer) do
		for _, pPlayer1 in ipairs(tbPlayer) do
			if (pPlayer.IsFriendRelation(pPlayer1.szName) == 1) then
				Relation:AddFriendFavor(pPlayer.szName, pPlayer1.szName, 25);
				pPlayer.Msg(string.format("您与<color=yellow>%s<color>好友亲密度增加了%d点。", pPlayer1.szName, 50));
			end
		end
	end
end

--特殊处理的
function tbBase:SetPlayerPassTask()
	local tbPlayer,nCount = self:GetPlayerList();
	if nCount > 0 then
		for _,pPlayer in pairs(tbPlayer) do
			--是否通过家族关卡
			if pPlayer then
				pPlayer.SetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_OVER_KINGAME, 1);
				-- 成就，家族关卡通关
				Achievement:FinishAchievement(pPlayer, 46);
				Achievement:FinishAchievement(pPlayer, 47);
				Achievement:FinishAchievement(pPlayer, 48);
				Achievement:FinishAchievement(pPlayer, 398);
				if self.nGameLevel >= 5 then
					Achievement:FinishAchievement(pPlayer,394);
				end
				if self.nGameLevel >= 9 then
					Achievement:FinishAchievement(pPlayer,396);
				end
				if self.nGameLevel >= 10 then
					Achievement:FinishAchievement(pPlayer,397);
				end
				if self.nGameLevel == 11 then
					Achievement:FinishAchievement(pPlayer,401);
				elseif self.nGameLevel == 12 then
					Achievement:FinishAchievement(pPlayer,402);
				end
				
				local tbInfo = Kinsalary.EVENT_TYPE[Kinsalary.EVENT_GUANQIA];
				Kinsalary:AddSalary_GS(pPlayer, Kinsalary.EVENT_GUANQIA, tbInfo.nRate);
			end
		end
	end
end


--是否已经领取过酒了
function tbBase:FindDrinkPlayer(nPlayerId)
	if self.tbDrinkPlayer[nPlayerId] and self.tbDrinkPlayer[nPlayerId] == 1 then
		return 1;
	end
	return 0;
end

--是否已经捡取过书
function tbBase:FindGetBookPlayer(nPlayerId)
	if self.tbGetBookPlayer[nPlayerId] and self.tbGetBookPlayer[nPlayerId] == 1 then
		return 1;
	end
	return 0;
end


-----------数据埋点相关---------------
function tbBase:WriteJoinLog()
	local tbPlayer,nCount = self:GetPlayerList();
	local cKin = KKin.GetKin(self.nKinId);
	local szKinName = "无家族"
	if cKin then
		szKinName = cKin.GetName();
	end
	if nCount > 0 then
		for _,pPlayer in pairs(tbPlayer) do
			if pPlayer then
				StatLog:WriteStatLog("stat_info", "kin_FB","join", pPlayer.nId, szKinName,2);
			end
		end
	end
end

function tbBase:WriteOpenLog(nFlag)
	local cKin = KKin.GetKin(self.nKinId);
	local szKinName = "无家族"
	if cKin then
		szKinName = cKin.GetName();
	end
	local nLevel = self.nGameLevel or 1;
	StatLog:WriteStatLog("stat_info", "kin_FB","open", 0, szKinName,nFlag,nLevel);
end

function tbBase:WriteFinishLog(nFlag,nPassRoom)
	if not nPassRoom then
		nPassRoom = 1;
	end
	local cKin = KKin.GetKin(self.nKinId);
	local szKinName = "无家族"
	if cKin then
		szKinName = cKin.GetName();
	end
	local nLastFrameTime = 0;
	local nTimerId = self.nGameTimerId--计时器Id			暂定
	if nTimerId > 0 then
		nLastFrameTime = tonumber(Timer:GetRestTime(nTimerId));
	end
	local nLastTime = math.ceil(nLastFrameTime / 18);
	StatLog:WriteStatLog("stat_info", "kin_FB","finish", 0, szKinName,self.nGameLevel,nFlag,nLastTime,nPassRoom);
end








