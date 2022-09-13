-------------------------------------------------------------------
--File		: kingame_base.lua
--Author	: zhengyuhua
--Date		: 2008-5-13 10:24
--Describe	: 家族关卡基础脚本
-------------------------------------------------------------------
Require("\\script\\mission\\baselock.lua")
local tbBaseLock = Lock.tbBaseLock;
-- 锁模板
local tbFixNpcLock = Lib:NewClass(tbBaseLock);
local tbDifNpcLock = Lib:NewClass(tbBaseLock);

-- 特殊锁类 (复制房间特殊锁)
local tbCopyNpcLock = Lib:NewClass(tbBaseLock);

-- 房间基类
local tbBaseRoom = Lib:NewClass(tbBaseLock);

-- 活动基础类 
local tbBase = Mission:New();
KinGame.tbBase = tbBase;

function tbFixNpcLock:InitFixNpc(tbRoom, nRoomType, nTimeLock, nNumLock, ...)
	self:InitLock(nTimeLock, nNumLock);
	self.tbRoom = tbRoom;
	if not tbFixNpc then
		self.tbFixNpc = {};
	end
	for i = 1, #arg do
		if KinGame.FixTrap[tbRoom.nRoomId] and KinGame.FixTrap[tbRoom.nRoomId][arg[i]] then
			table.insert(self.tbFixNpc, KinGame.FixTrap[tbRoom.nRoomId][arg[i]]);
		end
	end
end

function tbFixNpcLock:OnStartLock()
	if self.tbFixNpc then
		for i, tbNpc in pairs(self.tbFixNpc) do
			local nNpcTemplateId = tbNpc.nNpcId;	-- npc模板ID
			for i, tbOnePos in pairs(tbNpc.tbPos) do
				local pNpc = KNpc.Add2(nNpcTemplateId, 10, -1, self.tbRoom.nMapId, unpack(tbOnePos));
				if pNpc then
					self:AddNpcInLock(pNpc);
				end
			end
		end
	end
end

function tbFixNpcLock:OnUnLock()
	self.tbRoom:UnLockMulti();
end

function tbDifNpcLock:InitDifNpc(tbRoom, nRoomType, nTimeLock, nNumLock, nOnceNum, nDegree, nFrequency, nBoss)
	self:InitLock(nTimeLock, nNumLock);
	self.tbRoom = tbRoom;
	self.nOnceNum = nOnceNum;
	self.nDegree = nDegree;
	self.nFrequency = nFrequency;
	self.nNpcTemplateId = 0;
	self.nNpcLevel = 0;
	self.nBaoxiangOnceNum = math.floor(KinGame.MAX_BAOXIANG / nDegree);
	self.tbNpcPos = {};
	self.nBoss = nBoss;
end

function tbDifNpcLock:OnStartLock()
	if not self.tbRoom.tbGame then
		return 0;
	end
	local nNpcTempLevel = self.tbRoom.tbGame:GetNpcHardLevel();
	self.nNpcTemplateId = KinGame:GetDifNpcTemplateId(self.tbRoom.nRoomId, nNpcTempLevel);
	self.tbNpcPos = KinGame:GetDifNpcPosTable(self.tbRoom.nRoomId);
	self.nNpcLevel = self.tbRoom.tbGame:GetNpcLevel();
	local nRet = self:AddDifNpc();
	if nRet ~= 0 then
		self.nTimer = Timer:Register(self.nFrequency, self.AddDifNpc, self);
	end
end

function tbDifNpcLock:AddDifNpc()
	if self.nDegree <= 0 then
		return 0;
	end
	for i = 1, self.nOnceNum do
		local nPosCount = #self.tbNpcPos
		local nRandom = 0;
		if self.nOnceNum == nPosCount then
			nRandom = i;
		else
			nRandom = Random(nPosCount) + 1;
		end
		local tbPoint = self.tbNpcPos[nRandom];
		local pNpc = KNpc.Add2(self.nNpcTemplateId, self.nNpcLevel, -1, self.tbRoom.nMapId, tbPoint[1], tbPoint[2], 0, self.nBoss or 0);
		if pNpc then
			self:AddNpcInLock(pNpc);
		end
	end
	if self.tbRoom.nRoomId == 6 or self.tbRoom.nRoomId == 23 then
		--刷古铜币宝箱宝箱
		for i = 1, self.nBaoxiangOnceNum do
			local nPosCount = #self.tbNpcPos
			local nRandom = Random(nPosCount) + 1;
			local pNpc = KNpc.Add2(KinGame.NPCID_BAOXIANG,1, -1, self.tbRoom.nMapId, unpack(self.tbNpcPos[nRandom]))
		end
	end
	self.nDegree = self.nDegree - 1;
	if self.nDegree <=0 then
		return 0;
	end
end

function tbDifNpcLock:OnUnLock()
	self.tbRoom:UnLockMulti();
end

function tbCopyNpcLock:InitCopyNpc(tbRoom)
	self:InitLock( (5 * 60 * Env.GAME_FPS), 1);
	self.tbRoom = tbRoom;
	self.tbNpcPos = {};
end

function tbCopyNpcLock:OnStartLock()
	if not self.tbRoom.tbGame then
		return 0;
	end
	self.nState = 0;
	self.tbNpcPos = KinGame:GetDifNpcPosTable(self.tbRoom.nRoomId);
	local nRet = self:AddCopyNpc();
	if nRet ~= 0 then
		self.nTimer = Timer:Register( (60 * Env.GAME_FPS), self.AddCopyNpc, self);
	end
end

function tbCopyNpcLock:AddCopyNpc()
	self.nState = self.nState + 1;
	local nDegree = 0;
	--self.tbPlayerId 玩家右路线列表,暂用
	for nPlayerId in pairs(self.tbRoom.tbGame.tbPlayerId.tbMid.tbPlayerId) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer ~= nil then
			local nLevel 	 = pPlayer.nLevel;
			local nSeries  = pPlayer.nSeries;
			local nFaction = pPlayer.nFaction;
			local nRouteId = pPlayer.nRouteId;
			local szName 	 = pPlayer.szName;
			local nSex		 = pPlayer.nSex;
			if nFaction == 0 then
				nFaction = 1;
			end
			if nRouteId == 0 then
				nRouteId = 1;
			end
			local nIndex 	 = nFaction * 10 + nRouteId * 2 + nSex;
			local nNpcTempletId = KinGame.CopyNpcTemplet[nIndex];
			local nPosCount = #self.tbNpcPos;
			local nRandom  = Random(nPosCount) + 1;
			local pNpc = KNpc.Add2(nNpcTempletId, nLevel, nSeries, self.tbRoom.nMapId, unpack(self.tbNpcPos[nRandom]))
			if pNpc then
				self:AddNpcInLock(pNpc);
				pNpc.szName = szName
				nDegree = nDegree + 1;
			end
		end
	end
	if self.nState == 5 then
		self.nMultiNum = self.nMultiNum + nDegree - 1;
		return 0;
	else
		self.nMultiNum = self.nMultiNum + nDegree;
	end
end

function tbCopyNpcLock:OnUnLock()
	self.tbRoom:UnLockMulti();
end

function tbBaseRoom:InitRoom(nMapId, ...)
	self.nMapId = nMapId;
	self.nLockNum = #arg;
	self:InitLock(0, self.nLockNum); -- 房间目前只要数量锁，需要的话可以添加时间锁
	self.tbRoomLock = {};
	self.tbObstacleNpcId = {};
	for i = 1, self.nLockNum do
		local nCount = #self.tbRoomLock;
		if nCount > 0 then
			arg[i]:AddPreLock(self.tbRoomLock[nCount]);		-- 房内锁目前总是串序锁，有需求可以扩展成允许并序锁
		end
		table.insert(self.tbRoomLock, arg[i]);
		arg[i].tbRoom = self;
	end
end

-- 增加这个房间的障碍NPC（从视觉上是阻挡进入该房间的门，房间锁开启后删除）
function tbBaseRoom:AddObstacleNpc(...)
	for i = 1, #arg do
		local pNpc = KNpc.Add2(arg[i].nNpcId, 10, 1, self.nMapId, arg[i].nPosX, arg[i].nPosY);
		if pNpc then
			table.insert(self.tbObstacleNpcId, pNpc.dwId);
		end
	end
end

function tbBaseRoom:OnStartLock()
	-- 开通往本房间的门
	for i, nNpcId in pairs(self.tbObstacleNpcId) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.Delete();
		end
	end
	self.tbObstacleNpcId = {};
	-- 开始房间内第一个锁，无锁则会自动解开房间锁
	if self.tbRoomLock[1] then
		self.tbRoomLock[1]:StartLock();
	end
end

-- 普通房间（关卡的共性房间，另外有特殊房间需要另外写）
local tbNormalRoom = Lib:NewClass(tbBaseRoom);

function tbNormalRoom:InitNormalRoom(tbGame, ...)
	if not tbGame.nMapId then
		return 0;
	end
	self.tbGame = tbGame;
	local tbLock = {};
	for i = 1, #arg do 
		if arg[i][1] == KinGame.FIX_NPC then
			tbLock[i] = tbGame:ApplyLock(tbFixNpcLock);
			tbLock[i]:InitFixNpc(self, unpack(arg[i]));
		elseif arg[i][1] == KinGame.DIF_NPC then
			tbLock[i] = tbGame:ApplyLock(tbDifNpcLock);
			tbLock[i]:InitDifNpc(self, unpack(arg[i]));
		elseif arg[i][1] == KinGame.COPY_NPC then
			tbLock[i] = tbGame:ApplyLock(tbCopyNpcLock);
			tbLock[i]:InitCopyNpc(self);	
		end
	end
	self:InitRoom(tbGame.nMapId, unpack(tbLock));
end

function tbNormalRoom:OnStartLock()
	if KinGame.AWARD_TABLE[self.nRoomId] ~= nil then
		if KinGame.AWARD_TABLE[self.nRoomId][3] ~= nil and KinGame.AWARD_TABLE[self.nRoomId][3] ~= "" then
			self.tbGame:BroadcastMsg(0, KinGame.AWARD_TABLE[self.nRoomId][3]);
		end
		if KinGame.AWARD_TABLE[self.nRoomId][5] ~= nil and KinGame.AWARD_TABLE[self.nRoomId][5] ~= "" then
			self.tbGame.szUiStateMsg = KinGame.AWARD_TABLE[self.nRoomId][5];
			self.tbGame:UpdateGameUi();
		end
	end
	tbBaseRoom.OnStartLock(self);
end

function tbNormalRoom:OnUnLock()
	if self.nRoomId == 1 then 
		local nRet = self.tbGame:StartGame();
		if nRet ~= 1 then
			self:Close();
			return 0;
		end
	elseif self.nRoomId == 3 then--选择间篝火
		KItem.AddItemInPos(self.nMapId, math.floor(54848/32), math.floor(99136/32), 18,1,101,1);
	elseif self.nRoomId == 26 then --休息间篝火
		KItem.AddItemInPos(self.nMapId, math.floor(62944/32), math.floor(90816/32), 18,1,102,1);
	elseif self.nRoomId == 27 then --宝箱间篝火
		KItem.AddItemInPos(self.nMapId, math.floor(67008/32), math.floor(86336/32), 18,1,103,1);
		-- 添加好有亲密度
		self.tbGame:AddFriendFavor(self.nMapId);
		
		local nStockBaseCount = 50; -- 股份基数
		local nHonor = 100;
		
		local tbPlayer = self.tbGame:GetPlayerList();
		for i, pPlayer in pairs(tbPlayer) do
			-- 增加帮会建设资金和族长、副族长、个人的股份
			Tong:AddStockBaseCount_GS1(pPlayer.nId, nStockBaseCount, 0.6, 0.1, 0.2, 0.1, 0);
		end		
		-- 增加族长和副族长的领袖荣誉
		local nKinId = self.tbGame.nKinId;
		local pKin = KKin.GetKin(nKinId);
		if pKin then
			local nCaptainId = Kin:GetPlayerIdByMemberId(nKinId, pKin.GetCaptain());	-- 族长ID
			local nAssistantId = Kin:GetPlayerIdByMemberId(nKinId, pKin.GetAssistant()); -- 副族长ID
			PlayerHonor:AddPlayerHonorById_GS(nCaptainId, PlayerHonor.HONOR_CLASS_LINGXIU, 0, nHonor);
			PlayerHonor:AddPlayerHonorById_GS(nAssistantId, PlayerHonor.HONOR_CLASS_LINGXIU, 0, nHonor/2);
		end
				
	end
	if KinGame.AWARD_TABLE[self.nRoomId] and KinGame.AWARD_TABLE[self.nRoomId][1] > 0 then
		self.tbGame:GiveAllPlayerAwardItem(KinGame.AWARD_TABLE[self.nRoomId][1]);	-- 古钱币奖励
	end
	if KinGame.AWARD_TABLE[self.nRoomId] and KinGame.AWARD_TABLE[self.nRoomId][2] > 0 then
		self.tbGame:GiveAllPlayerRepute(KinGame.AWARD_TABLE[self.nRoomId][2]);		-- 声望奖励
	end
	
	--发布公告
	if KinGame.AWARD_TABLE[self.nRoomId] ~= nil then
		if KinGame.AWARD_TABLE[self.nRoomId][4] ~= nil and KinGame.AWARD_TABLE[self.nRoomId][4] ~= "" then
			self.tbGame:BroadcastMsg(0, KinGame.AWARD_TABLE[self.nRoomId][4]);
		end
		if KinGame.AWARD_TABLE[self.nRoomId][6] ~= nil and KinGame.AWARD_TABLE[self.nRoomId][6] ~= "" then
			self.tbGame.szUiStateMsg = KinGame.AWARD_TABLE[self.nRoomId][6];
			self.tbGame:UpdateGameUi();
		end
	end
end

function tbBase:InitGame(nMapId, nCityMapId, nKinId)
	self.tbRoom 		= {};	
	self.tbLock			= {};	
	self.tbLogOutPlayer = {};		-- 掉线记录表 
	self.nMapId = nMapId;
	self.nCityMapId = nCityMapId;
	self.nKinId = nKinId;
	self.nTimerId 	= 0; 	--整个活动计时器Id
	self.nAwardMultip = 0;	--经验奖励倍数
	self.nNpcTempletLevel = 0; --模版等级
	self.nNpcLevel = 0;		-- NPC等级
	self.nLockCount = 0;
	self.nRoomCount = 0;
	self.nStart = 0;
	self.bStatLogOk = 0;
	self.szUiStateMsg = "关卡还未开启";
	self.tbMiYaoLimit = {}; --迷药限制;
	self.tbHeartRoom = {}; --心魔房记录玩家ID和心魔ID
	self.tbPlayerId 	= 			-- 三条路线记录Id
	{
		tbLeft	={nCount=0,	tbPlayerId={}},
		tbMid		={nCount=0,	tbPlayerId={}},
		tbRight	={nCount=0,	tbPlayerId={}},
	};
	self.tbMisCfg = 
	{
		tbEnterPos = {},
		tbLeavePos	= {[1] = {nCityMapId, unpack(KinGame.LEAVE_POS[nCityMapId])}},	-- 离开坐标
		tbDeathRevPos = {},		-- 死亡重生点
		nOnKillNpc = 1,
		nOnDeath = 1, 		-- 死亡脚本可用
		nDeathPunish = 1,
	}
	for i = 1 ,#KinGame.ENTER_POS do
		table.insert(self.tbMisCfg.tbEnterPos, {self.nMapId, unpack(KinGame.ENTER_POS[i])});
		table.insert(self.tbMisCfg.tbDeathRevPos, {self.nMapId, unpack(KinGame.ENTER_POS[i])});
	end
	for i = 1, KinGame.MAXROOM do
		self.tbRoom[i] = self:ApplyRoom(tbNormalRoom);
		self.tbRoom[i]:InitNormalRoom(self, unpack(KinGame.tbRoom[i]));
		if KinGame.ObstacleTrap[i] then
			self.tbRoom[i]:AddObstacleNpc(unpack(KinGame.ObstacleTrap[i]));
		end
	end
	
	-- 随机房间前的房间
	self.tbRoom[2]:AddPreLock(self.tbRoom[1]);
	self.tbRoom[3]:AddPreLock(self.tbRoom[2]);
	self.tbRoom[4]:AddPreLock(self.tbRoom[3]);
	self.tbRoom[5]:AddPreLock(self.tbRoom[3]);
	self.tbRoom[6]:AddPreLock(self.tbRoom[3]);
	
	-- 随机房间
	self.tbRoom[15]:AddPreLock(self.tbRoom[4], self.tbRoom[5], self.tbRoom[6]);
	self.tbRoom[19]:AddPreLock(self.tbRoom[4], self.tbRoom[5], self.tbRoom[6]);
	local tbRandomRoomId = {{7,8,9,10}, {11,12,13,14}};
	self:RandomRoom(tbRandomRoomId[1]);
	self:RandomRoom(tbRandomRoomId[2]);
	for i = 1, 3 do
		self.tbRoom[tbRandomRoomId[1][i]]:AddPreLock(self.tbRoom[14 + i]);
		self.tbRoom[15 + i]:AddPreLock(self.tbRoom[tbRandomRoomId[1][i]]);
		self.tbRoom[tbRandomRoomId[2][i]]:AddPreLock(self.tbRoom[18 + i]);
		self.tbRoom[19 + i]:AddPreLock(self.tbRoom[tbRandomRoomId[2][i]]);
	end
	self.tbRoom[tbRandomRoomId[1][4]]:AddPreLock(self.tbRoom[18]);
	self.tbRoom[tbRandomRoomId[2][4]]:AddPreLock(self.tbRoom[22]);
	self.tbRoom[29]:AddPreLock(self.tbRoom[tbRandomRoomId[1][4]]); -- 辅助房间
	self.tbRoom[30]:AddPreLock(self.tbRoom[tbRandomRoomId[2][4]]); -- 辅助房间
	
	-- 随机房间后面的房间
	self.tbRoom[23]:AddPreLock(self.tbRoom[29],self.tbRoom[30]);
	self.tbRoom[24]:AddPreLock(self.tbRoom[29],self.tbRoom[30]);
	self.tbRoom[25]:AddPreLock(self.tbRoom[29],self.tbRoom[30]);
	
	self.tbRoom[26]:AddPreLock(self.tbRoom[23], self.tbRoom[24], self.tbRoom[25]);
	self.tbRoom[27]:AddPreLock(self.tbRoom[26]);
	self.tbRoom[28]:AddPreLock(self.tbRoom[27]);
	
	self.tbRoom[1]:StartLock();
	self:Open();
end

function tbBase:RandomRoom(tbRoomId)
	for i = 1, #tbRoomId do
		local nRandom = MathRandom(#tbRoomId);
		local nTemp = tbRoomId[i]
		tbRoomId[i] = tbRoomId[nRandom];
		tbRoomId[nRandom] = nTemp;
	end
end

function tbBase:ApplyLock(tbBaseClass)
	local tbNewLock = Lib:NewClass(tbBaseClass);
	self.nLockCount = self.nLockCount + 1;
	tbNewLock.nLockId = self.nLockCount;
	self.tbLock[self.nLockCount] = tbNewLock;
	return tbNewLock;
end

function tbBase:ApplyRoom(tbBaseClass)
	local tbRoom = self:ApplyLock(tbBaseClass);
	self.nRoomCount = self.nRoomCount + 1;
	tbRoom.nRoomId = self.nRoomCount;
	return tbRoom;
end

function tbBase:GetNpcHardLevel()
	return self.nNpcTempletLevel;
end

function tbBase:GetNpcLevel()
	return self.nNpcLevel;
end

-- 记录玩家参加家族副本的次数
function tbBase:RecordKinGameNum()
	local tbPlayList = KPlayer.GetMapPlayer(self.nMapId);
	if (tbPlayList) then
		for _, pPlayer in ipairs(tbPlayList) do
			Stats.Activity:AddCount(pPlayer, Stats.TASK_COUNT_KINGAME, 1);
			pPlayer.SetTask(KinGame.TASK_GROUP_ID, KinGame.TASK_NOW_WEEK_TIME, GetTime());
		end
	end
end

function tbBase:StartGame()
	local nCount = self:GetPlayerCount();
	if nCount < KinGame.MIN_PLAYER then
		self:EndGame(0);
		self:WriteOpenLog(0);	--人数不够，没开启
		return 0;
	end	
	self.nTimerId = Timer:Register(KinGame.GAME_MAX_TIME, self.GameTimeUp, self);
	KinGame.tbHeartMonster:InIt(self.nMapId);
	self:SetMultipTemplet();	--设置怪物模版等级和奖励倍数；
	self:OpenEveryOneUi();
	self.nStart = 1;
	self:RecordKinGameNum();
	
	self:KinGame_StatLog_PlayerLog();
	self:WriteOpenLog(1); --人数不够，没开启
	--额外事件，活动使用
	SpecialEvent.ExtendEvent:DoExecute("Open_KinGame", self.nNpcLevel, nCount);

	return 1;
end

function tbBase:WriteOpenLog(nFlag)
	local cKin = KKin.GetKin(self.nKinId);
	local szKinName = "无家族"
	if cKin then
		szKinName = cKin.GetName();
	end
	StatLog:WriteStatLog("stat_info", "kin_FB","open", 0,szKinName,nFlag,0);
end

function tbBase:KinGame_StatLog_PlayerLog()
	local tbPlayer = self:GetPlayerList();
	local szKinName	= "_无家族";
	local cKin = KKin.GetKin(self.nKinId);
	if cKin then
		szKinName = cKin.GetName();
	end
	for _, pPlayer in pairs(tbPlayer) do
		StatLog:WriteStatLog("stat_info", "kin_FB", "join", pPlayer.nId, string.format("%s,%s", szKinName, 1));
	end
end

function tbBase:KinGame_StatLog_KinLog_KillBoss(nCloseFlag)
	if (1 == self.bStatLogOk) then
		return 0;
	end
	local szKinName	= "_无家族";
	local cKin = KKin.GetKin(self.nKinId);
	if cKin then
		szKinName = cKin.GetName();
	end
	
	local nLastFrameTime = 0;
	local nTimerId = self.nTimerId--计时器Id			暂定
	if nTimerId > 0 then
		nLastFrameTime = tonumber(Timer:GetRestTime(nTimerId));
	end
	local nLastTime = math.ceil(nLastFrameTime / 18);
	StatLog:WriteStatLog("stat_info", "kin_FB", "finish", 0, string.format("%s,%s,%s,%s,%s", szKinName, 0, nCloseFlag, nLastTime,0));
	self.bStatLogOk = 1;
end

function tbBase:GameTimeUp()
	self.nTimerId = 0;
	self:KinGame_StatLog_KinLog_KillBoss(2);
	self:EndGame();
	return 0;
end

function tbBase:IsStart()
	return self.nStart;
end

function tbBase:EndGame(nRet)
	if self.nTimerId > 0 then
		Timer:Close(self.nTimerId);
		self.nTimerId = 0;
	end
	for i, tbLock in pairs(self.tbLock) do
		tbLock:Close();
	end
	self:Close();
	KinGame:EndGame_GS1(self.nKinId, self.nMapId, self.nCityMapId, nRet);
	ClearMapNpc(self.nMapId);
end

function tbBase:JoinGame(pPlayer)
	if self.nStart == 1 and self.tbLogOutPlayer[pPlayer.nId] == nil then
		return 0;
	end
	if self.tbLogOutPlayer[pPlayer.nId] then
		-- self.tbLogOutPlayer[pPlayer.nId] = nil;
		self:OpenSingleUi(pPlayer);
	end
	self.tbLogOutPlayer[pPlayer.nId] = 1;
	pPlayer.SetLogoutRV(1);			-- 服务器宕机保护
	self:JoinPlayer(pPlayer, 1);	-- 只有一个阵营
	pPlayer.DisabledStall(1);		-- 禁止摆摊
	pPlayer.DisableOffer(1);		-- 禁止贩卖
end

function tbBase:OnLeave(nGroupId, szReason)
	-- 开启副本后，玩家掉线需要记录数据，使玩家可以再加进来
	--if self.nStart == 1 and szReason == "Logout" then
	--	self.tbLogOutPlayer[me.nId] = 1;
	--end
	--如果玩家在选择区内掉线，删除玩家
	if self.tbRoom[26]:IsStart() == 0 then
		self:DelLinePlayer(me.nId)
	end
	
	--如果玩家在心魔房掉线，删除心魔
	if self.tbHeartRoom[me.nId] ~= nil then
		local pNpc = KNpc.GetById(self.tbHeartRoom[me.nId]);
		if pNpc then
			local tbTmp = pNpc.GetTempTable("KinGame");
			local nRoomId = tbTmp.nRoomId;
			pNpc.Delete();
			KinGame.tbHeartMonster:AddMonsterItem(nRoomId, self.nMapId)
			self.tbHeartRoom[me.nId] = nil
		end
	end
	me.SetFightState(0);	-- 非战斗状态
	local nCount = self:GetPlayerCount();
	-- 人走光了也不能关
	--if nCount <= 0 and self.tbRoom[28]:IsStart() == 1 then
	--	self:EndGame();
	--end
	self:CloseSingleUi(me);
	me.SetLogoutRV(0);		-- 解除服务器宕机保护
	me.DisabledStall(0);	-- 允许摆摊
	me.DisableOffer(0);		-- 允许贩卖
end

function tbBase:OnDeath()
	
	--如果玩家在选择区内死亡，删除玩家
	if self.tbRoom[26]:IsStart() == 0 then
		self:DelLinePlayer(me.nId)
	end
	
	--如果玩家在心魔房内死亡，删除心魔
	if self.tbHeartRoom[me.nId] ~= nil then
		local pNpc = KNpc.GetById(self.tbHeartRoom[me.nId]);
		if not pNpc then
			return 0
		end
		local tbTmp = pNpc.GetTempTable("KinGame");
		local nRoomId = tbTmp.nRoomId;
		pNpc.Delete();
		KinGame.tbHeartMonster:AddMonsterItem(nRoomId, self.nMapId)
		self.tbHeartRoom[me.nId] = nil
	end
	me.ReviveImmediately(0);
end

-- 在开启副本后掉线的玩家表中寻找玩家ID
function tbBase:FindLogOutPlayer(nPlayerId)
	if self.tbLogOutPlayer[nPlayerId] then
		return 1;
	end
	return 0;
end

function tbBase:OnKillNpc(pKillNpc)
	-- TODO 加积分
end

function tbBase:SetMultipTemplet()
	local nCount = self:GetPlayerCount();
	local tbPlayer = self:GetPlayerList();
	if nCount > 40 then
		nCount = 40;
	end
	self.nAwardMultip = KinGame.MultipTemplet[nCount].nAwardMultip;
	self.nNpcTempletLevel =	 KinGame.MultipTemplet[nCount].nTempletLevel;
	local nTotalLevel = 0;
	local nLevelCount = 0;
	for i, pPlayer in pairs(tbPlayer) do
		if pPlayer.nLevel >= 50 then
			nLevelCount = nLevelCount + 1;
			nTotalLevel = nTotalLevel + pPlayer.nLevel;
		end
	end
	if nLevelCount == 0 then
		self.nNpcLevel = 50;
		return 0;
	end
	self.nNpcLevel = math.ceil(nTotalLevel / nLevelCount);
	if self.nNpcLevel < 50 then
		self.nNpcLevel = 50;
	end
end

function tbBase:AddHeartRoomNpc(nPlayerId, nNpcId)
	if self.tbHeartRoom[nPlayerId] == nil then
		self.tbHeartRoom[nPlayerId] = nNpcId;
	end
end

function tbBase:DelHeartRoomNpc(nPlayerId, nNpcId)
	if self.tbHeartRoom[nPlayerId] ~= nil then
		self.tbHeartRoom[nPlayerId] = nil;
	end	
end

--玩家各路线管理接口START----
--增加左路线玩家
function tbBase:AddLeftPlayer(nPlayerId)
	if not self.tbPlayerId.tbLeft.tbPlayerId[nPlayerId] then
		self.tbPlayerId.tbLeft.tbPlayerId[nPlayerId] = 1;
		self.tbPlayerId.tbLeft.nCount = self.tbPlayerId.tbLeft.nCount + 1;
	end		
end

--增加中路线玩家
function tbBase:AddMidPlayer(nPlayerId)
	if not self.tbPlayerId.tbMid.tbPlayerId[nPlayerId] then
		self.tbPlayerId.tbMid.tbPlayerId[nPlayerId] = 1;
		self.tbPlayerId.tbMid.nCount = self.tbPlayerId.tbMid.nCount + 1;
	end	
end

--增加右路线玩家
function tbBase:AddRightPlayer(nPlayerId)
	if not self.tbPlayerId.tbRight.tbPlayerId[nPlayerId] then
		self.tbPlayerId.tbRight.tbPlayerId[nPlayerId] = 1;
		self.tbPlayerId.tbRight.nCount = self.tbPlayerId.tbRight.nCount + 1;
	end
end

--删除路线玩家
function tbBase:DelLinePlayer(nPlayerId)
	if self.tbPlayerId.tbLeft.tbPlayerId[nPlayerId] == 1 then
		self.tbPlayerId.tbLeft.tbPlayerId[nPlayerId] = nil;
		self.tbPlayerId.tbLeft.nCount = self.tbPlayerId.tbLeft.nCount - 1;
	end
	
	if self.tbPlayerId.tbMid.tbPlayerId[nPlayerId] == 1 then
		self.tbPlayerId.tbMid.tbPlayerId[nPlayerId] = nil;
		self.tbPlayerId.tbMid.nCount = self.tbPlayerId.tbMid.nCount - 1;
	end
	
	if self.tbPlayerId.tbRight.tbPlayerId[nPlayerId] == 1 then
		self.tbPlayerId.tbRight.tbPlayerId[nPlayerId] = nil;
		self.tbPlayerId.tbRight.nCount = self.tbPlayerId.tbRight.nCount - 1;
	end
end

--获得左路玩家数
function tbBase:GetLeftPlayerCount()
	return self.tbPlayerId.tbLeft.nCount;
end

--获得中路玩家数
function tbBase:GetMidPlayerCount()
	return self.tbPlayerId.tbMid.nCount;
end


--获得右路玩家数
function tbBase:GetRightPlayerCount()
	return self.tbPlayerId.tbRight.nCount;
end
--玩家各路线管理接口END----

--界面START------
function tbBase:OpenEveryOneUi()
	local tbPlayer = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayer) do
		self:OpenSingleUi(pPlayer)
	end
end

function tbBase:CloseEveryOneUi()
	local tbPlayer = self:GetPlayerList();
	for _, pPlayer in pairs(tbPlayer) do
		self:CloseSingleUi(pPlayer)
	end
end

function tbBase:OpenSingleUi(pPlayer)
	if pPlayer == 0 then
		return 0;
	end
	local nTimerId = self.nTimerId--计时器Id			暂定
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
		self:UpdateSingleUi(pPlayer)
	end
end

function tbBase:UpdateSingleUi(pPlayer)
	if pPlayer == 0 then
		return 0;
	end
	local nMultip = self.nAwardMultip;		--参加人数奖励 倍	暂定
	if self.nTimerId <= 0 then
		return 0;
	end
	local szMsg = string.format("\n\n参加人数奖励倍数：%s\n\n<color=yellow>%s<color>", nMultip, self.szUiStateMsg);
	
	Dialog:SendBattleMsg(pPlayer,  szMsg);
end

function tbBase:CloseSingleUi(pPlayer)
	if pPlayer == nil then
		return 0;
	end
	Dialog:ShowBattleMsg(pPlayer,  0,  0); -- 关闭界面
end

--界面END------

--获得秘药刷新个数
function tbBase:GetMiYaoCount(nRoomId)
	if self.tbMiYaoLimit[nRoomId] == nil then
		self.tbMiYaoLimit[nRoomId] = 0;
	end
	return self.tbMiYaoLimit[nRoomId];
end

--增加秘药刷新个数
function tbBase:AddMiYaoCount(nRoomId)
	if self.tbMiYaoLimit[nRoomId] == nil then
		self.tbMiYaoLimit[nRoomId] = 0;
	end
	self.tbMiYaoLimit[nRoomId] = self.tbMiYaoLimit[nRoomId] + 1;
end

-- 加物品奖励 
function tbBase:GiveAllPlayerAwardItem(nNum)
	local tbPlayer = self:GetPlayerList();
	for i, pPlayer in pairs(tbPlayer) do
		KinGame:GiveAwardItem(pPlayer, nNum);
	end
end

-- 加声望
function tbBase:GiveAllPlayerRepute(nRepute)
	local tbPlayer = self:GetPlayerList();
	for i, pPlayer in pairs(tbPlayer) do
		pPlayer.AddRepute(KinGame.KIN_REPUTE_CAMP, KinGame.KIN_REPUTE_CALSS, nRepute);
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