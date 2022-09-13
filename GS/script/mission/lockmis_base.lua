-- 文件名　：lockmis_base.lua
-- 创建者　：zounan
-- 创建时间：2009-12-11 11:19:09
-- 描  述  ：带有锁结构的MISSION
Require("\\script\\mission\\mission.lua");
Require("\\script\\mission\\baselock.lua");


Mission.LockMis = Mission.LockMis or Mission:New();
local BaseGame = Mission.LockMis;

function Mission:NewLock()
	return Lib:NewClass(Mission.LockMis);
end

--++++TRAP事件+++
local tbMapBase = {};
local tbTrapBase = {};
-- 玩家触发trap点
function tbMapBase:OnPlayerTrap(szClassName)
	self:GetTrapClass(szClassName):OnPlayer(szClassName);
end

-- 定义玩家进入地图事件
function tbMapBase:OnEnter()
	local tbGame = me.GetTempTable("Mission").tbGame;
	if not tbGame then
		print("【LockMisMap】OnEnter:player is not in the mission");
		return;
	end
	tbGame:OnMapEnter();
end

-- 定义玩家离开地图事件
function tbMapBase:OnLeave()
	local tbGame = me.GetTempTable("Mission").tbGame;
	if not tbGame then
		return;
	end
	if tbGame:IsOpen() ~= 0 then
		tbGame:KickPlayer(me);
	end
	tbGame:OnMapLeave();
end


function tbTrapBase:OnPlayer(szClassName)
	local tbGame = me.GetTempTable("Mission").tbGame;
	if not tbGame then
--		print("player is not in the mission");
		return;
	end
	tbGame:OnPlayerTrap(szClassName);	
end

--++++EventLock+++++++
local tbEventLock = Lib:NewClass(Lock.tbBaseLock);

function tbEventLock:InitEventLock(tbGame, nTime, nMultiNum, tbStartEvent, tbUnLockEvent)
	self:InitLock(nTime, nMultiNum);
	self.tbGame 		= tbGame;
	self.tbUnLockEvent 	= tbUnLockEvent;
	self.tbStartEvent 	= tbStartEvent;
end

function tbEventLock:OnUnLock()
	if self.tbGame and self.tbUnLockEvent then
		for i = 1, #self.tbUnLockEvent do
			self.tbGame:OnEvent(unpack(self.tbUnLockEvent[i]));
		end
	end
end

function tbEventLock:OnStartLock()
	if self.tbGame and self.tbStartEvent then
		for i = 1, #self.tbStartEvent do
			self.tbGame:OnEvent(unpack(self.tbStartEvent[i]));
		end
	end
end


---定义函数事件 方便给外部看
BaseGame.EVENT_PROC  =
{
	["AddNpc"]		   = "AddNpc",
	["DelNpc"]		   = "DelNpc",
	["ChangeTrap"] 	   = "ChangeTrap",
	["DelTrap"] 	   = "DelTrap",
	["AddTrapLock"]	   = "AddTrapLock",	
	["NewWorld"]       = "NewWorld",
	["ChangeFight"]	   = "ChangeFight",
	["SetTagetInfo"]   = "SetTagetInfo",
	["SetTimeInfo"]    = "SetTimeInfo",
	["CloseInfo"]	   = "CloseInfo",
	["MovieDialog"]    = "MovieDialog",
	["BlackMsg"]	   = "BlackMsg",
	["SendPlayerMsg"]  = "SendPlayerMsg",
	["ChangeNpcAi"]    = "ChangeNpcAi",
	["SendNpcChat"]	   = "SendNpcChat",
	["AddNpcLifePObserver"] = "AddNpcLifePObserver",
	["ChangeCamp"]     = "ChangeCamp",
	["AddProtectedState"]  = "AddProtectedState",
	["AddDiaologNpcRate"]  = "AddDiaologNpcRate",
	["GameWin"]        = "GameWin",
	["GameLose"]       = "GameLose",
--	["ExcuteScript"]   = "ExcuteScript",
--	["AddGouHuo"]	   = "AddGouHuo",
--	["SetSkill"]       = "SetSkill",
--	["DisableSwitchSkill"] = "DisableSwitchSkill",
--	["AddTeamTitle"]   = "AddTeamTitle",
--	["TransformChild"] = "TransformChild",
--	["TransformChild2"]= "TransformChild2",
--	["ShowNameAndLife"]= "ShowNameAndLife",
--	["NpcCanTalk"]     = "NpcCanTalk",
};

BaseGame.AI_MODE_PROC = 
{
	["AI_MOVE"] 			= "SetNpcMove";
	["AI_RECYLE_MOVE"]	    = "SetNpcReMove";
	["AI_ATTACK"]		    = "SetNpcAttack";
}

-- 初始化 
function BaseGame:InitGame(nMapId,tbDerivedRoom)	
	self.tbMisCfg 	   = {};             --tbMisCfg 由派生类配置    --此TABLE需由派生类进行配置
	self.tbLockMisCfg  = {};             --锁的配置信息				--此TABLE需由派生类进行配置

	--以下参数均由基类自行配置
	self.tbLock        = {};	         --锁的实例集合
	self.tbTrap        = {};			 --地图的TRAP点的传送点
	self.tbTrapLock    = {}; 			 -- TRAP点的锁序号
	self.tbNpcGroup    = {};   			 --NPC分组 [szGroupName]-->{dwId1, dwId2, ...}
	self.tbPlayerJoinCfg = {};           --玩家JOIN MISSION 时的一些配置 同步锁的界面信息用	
	self.tbAddNpcTimer = {};	         --定时刷NPC用
	self.IsWin	       = 0;              --胜利标志，胜利或失败
	self.nStartTime    = 0;              --记录开始时间 计时用
	self.nEndTime      = 0;              --记录结束时间 计时用
	self.nGameTime     = 0;              --游戏时间     计时用 
	self.nPlayerCount  = 0;				 --玩家数目
	self.nIsGameOver   = 0;				 --游戏是否结束
	self.nMapId        = nMapId;         -- 记录MAPID 刷NPC等函数需要用到
	self.nTmpMapId     = SubWorldIdx2MapCopy(SubWorldID2Idx(nMapId));
	if tbDerivedRoom then	--如果有继承房间，就从继承房间的逻辑走
		self.tbDerivedRoom = self.tbDerivedRoom or Lib:NewClass(tbDerivedRoom);
	end
	self:Open();                         --调用MISSION类的初始配置，感觉直接写也行	
end

--对锁进行初始化
function BaseGame:InitLock()
	if not self.tbLockMisCfg.LOCK then
		print("【LockMis】LOCK 都没有");
		return;
	end	

	for i, tbLockSetting in pairs(self.tbLockMisCfg.LOCK) do
		self.tbLock[i] = Lib:NewClass(tbEventLock);
		self.tbLock[i].nLockId = i;
		self.tbLock[i]:InitEventLock(self, tbLockSetting.nTime * Env.GAME_FPS, tbLockSetting.nNum, tbLockSetting.tbStartEvent, tbLockSetting.tbUnLockEvent);
	--	print(">>>>>", i , tbLockSetting.nTime, tbLockSetting.nNum, tbLockSetting.tbStartEvent);
	end
	
	for i, tbLockSetting in ipairs(self.tbLockMisCfg.LOCK) do -- 保证解锁顺序
		for _, verPreLock in pairs(tbLockSetting.tbPrelock) do
			if type(verPreLock) == "number" then
				self.tbLock[i]:AddPreLock(self.tbLock[verPreLock]);
			elseif type(verPreLock) == "table" then
				local tbPreLock = {}
				for j = 1, #verPreLock do
					if self.tbLock[verPreLock[j]] then
						table.insert(tbPreLock, self.tbLock[verPreLock[j]]);
					end
				end
				self.tbLock[i]:AddPreLock(tbPreLock);
			else
				print("【LockMis】LOCK SETTING 参数错误");
				return 0;
			end
		end
	end	
end

--初始化地图
function BaseGame:InitMap()
	local tbMapTrap = Map:GetClass(self.nTmpMapId);
	for szFnc in pairs(tbMapBase) do			-- 复制函数
		tbMapTrap[szFnc] = tbMapBase[szFnc];
	end
end

-- 重用时要跳过 ADDTRAP 故设置了bAddTrap标志位
function BaseGame:AddMapTrap(bAddTrap)
	if bAddTrap and bAddTrap >= 1 and self.tbLockMisCfg.tbTrap and self.tbLockMisCfg.tbTrap.tbSrcTrap then
		for szClassName,tbTrapPoint  in pairs(self.tbLockMisCfg.tbTrap.tbSrcTrap) do
			for _, tbPoint in ipairs(tbTrapPoint) do
				AddMapTrap(self.nMapId, tbPoint[1] * 32, tbPoint[2] * 32, szClassName);
			end
			local tbMapTrap = Map:GetClass(self.nTmpMapId):GetTrapClass(szClassName, 0);
			for szFnc in pairs(tbTrapBase) do			-- 复制函数
				tbMapTrap[szFnc] = tbTrapBase[szFnc];
			end
		end
	end									 
end



--回调
function BaseGame:OnJoin(nGroupId)
	self.nPlayerCount = self.nPlayerCount + 1;	
	me.GetTempTable("Mission").tbGame = self;

	--传送
	if self.tbLockMisCfg.tbNpcPoint["playerbirth"] then
		local nRandom = #self.tbLockMisCfg.tbNpcPoint["playerbirth"];
		local nX = self.tbLockMisCfg.tbNpcPoint["playerbirth"][nRandom][1];
		local nY = self.tbLockMisCfg.tbNpcPoint["playerbirth"][nRandom][2];	
		me.NewWorld(self.nMapId, nX, nY);	
	end
		
	-- 一些界面的显示问题 做到解锁之后进来的人 照样能显示界面 --有待加强
	if self.tbPlayerJoinCfg.szTimeInfo  then	
		local tbLockTime = {};
		for _, nLock in ipairs(self.tbPlayerJoinCfg.tbLock) do
			local nLastFrameTime = tonumber(Timer:GetRestTime(self.tbLock[nLock].nTimerId));
			if nLastFrameTime == -1 then -- timer还没开启
				nLastFrameTime = self.tbLockMisCfg.LOCK[nLock].nTime*Env.GAME_FPS;
			end
			table.insert(tbLockTime, nLastFrameTime);
		end
		Dialog:SetBattleTimer(me,  self.tbPlayerJoinCfg.szTimeInfo, unpack(tbLockTime));
	--	Dialog:ShowBattleMsg(me,  1,  0); --开启界面
	end
	
	if self.tbPlayerJoinCfg.szInfo then
		Dialog:SendBattleMsg(me,  self.tbPlayerJoinCfg.szInfo);
		Dialog:ShowBattleMsg(me,  1,  0); --开启界面
	end	
	
	self:OnLockMisJoin(nGroupId);    -- 派生类接口
end

function BaseGame:OnLeave(nGroupId, szReason)
	self.nPlayerCount = self.nPlayerCount - 1;
	me.GetTempTable("Mission").tbGame = nil;
	Dialog:ShowBattleMsg(me, 0, 0);         -- 关闭界面	
	me.SetCurCamp(me.GetCamp());            -- 还原阵营
	self:OnLockMisLeave(nGroupId, szReason);   -- 派生类接口
end

-- 开始游戏 
-- 参数bAddTrap：是否加载TRAP点 bAddTrap =1 加载 =0 不加载  默认不加载 
-- 地图重用之后或许不需要初始化了 而且多次ADDTRAP点或许会有问题  
function BaseGame:StartGame(bAddTrap)
--	self.tbLockMisCfg = CFuben.tbLockMis[1].tbLockMisCfg;
	if bAddTrap and bAddTrap >= 1 then
		self:InitMap();
	end
	self:AddMapTrap(bAddTrap);	
	
	--复制TRAP点的传送点 每一个MISSION都有独立的TABLE 这样改的时候不会影响其他MISSION
	if self.tbLockMisCfg.tbTrap and self.tbLockMisCfg.tbTrap.tbDesTrap then
		self:CopyTable(self.tbLockMisCfg.tbTrap.tbDesTrap, self.tbTrap);
	end	
	
	--如果有继承房间，并且继承房间有开启指令，就从继承房间走
	if self.tbDerivedRoom and self.tbDerivedRoom.StartRoom then
		self.tbDerivedRoom:StartRoom(self);	
	else
		self:InitLock();
		--开第一个锁
		self:StartLock();
	end
	
	self.nStartTime = tonumber(GetLocalDate("%Y%m%d%H%M")); --记录开始时间
end

--解第一个锁 游戏开始
function BaseGame:StartLock()
	if not self.tbLock[1] then
		print("【LockMis】self.tbLock[1]为空");
		return;
	end
	self.tbLock[1]:StartLock();
end

--游戏结束
function BaseGame:CloseGame()	
	--当游戏已经结束时，直接return
	if self.nIsGameOver == 1 then
		return;
	end
	self.nIsGameOver = 1;
	
	--self:OnGameClose();      --调派生类接口
	
	--记录用时
	self.nEndTime = tonumber(GetLocalDate("%Y%m%d%H%M"));
	self.nGameTime = Lib:GetDate2Time(self.nEndTime) - Lib:GetDate2Time(self.nStartTime);
	
	
	-- 关闭锁
	for i ,tbLock in pairs(self.tbLock) do
		tbLock:Close();
	end	
	
	--关MISSION
	if self:IsOpen() == 1 then
		self:Close();
	end	
	
	self:OnGameClose();      --调派生类接口
	--清光光
	
	--手动删
	for szGroup in pairs(self.tbNpcGroup) do
		self:DelNpc(szGroup);
	end

--	ClearMapTrap(self.nMapId);  -- 函数貌似有问题
--	ClearMapNpc (self.nMapId);  -- 手动删
	ClearMapObj (self.nMapId);	
end

-- 全拷贝table函数，注意不能出现table环链~否则会死循环
function BaseGame:CopyTable(tbSourTable, tbDisTable)
	if not tbSourTable or not tbDisTable then
		return 0;
	end
	for varField, varData in pairs(tbSourTable) do
		if type(varData) == "table" then
			tbDisTable[varField] = {}
			self:CopyTable(varData, tbDisTable[varField]);
		else
			tbDisTable[varField] = varData;
		end
	end
end

--目前只支持本地图传送
function BaseGame:OnPlayerTrap(szClassName)
	--传送优先
	if self.tbTrap[szClassName]  then
		me.NewWorld(self.nMapId,unpack(self.tbTrap[szClassName]));
	elseif self.tbTrapLock[szClassName] then
		local nLock = self.tbTrapLock[szClassName];
		if not self.tbLock[nLock] then
			print("【LockMis】OnPlayerTrap：lock is not exist.", nLock);
		else 
			self.tbLock[nLock]:UnLockMulti();	
			self.tbTrapLock[szClassName] = nil;         -- 解了就删	
		end	
	end
	self:OnMapTrap(szClassName);
end

--LockMisCfg 目前是挂在CFuben下
function BaseGame:GetLockMisCfg(nId)
	if not CFuben.tbLockMis and not CFuben.tbLockMis[nId] and not CFuben.tbLockMis[nId].tbLockMisCfg then
		print("【LockMis】GetLockMisCfg is not exist",nId);
		return {};
	end
	return CFuben.tbLockMis[nId].tbLockMisCfg;
end

--读取文件配置 貌似没用了
function BaseGame:LoadMisFile(szPath)
--	local tbLockMisCfg = self:LoadMisFile(szPath);
--	self.tbLockMisCfg = tbLockMisCfg;	
--	self.tbLockMisCfg = CFuben.tbLockMisFile:LoadMisFile(szPath);
end

--事件处理函数
function BaseGame:OnEvent(szEventType, ...)
	if self.EVENT_PROC[szEventType] and self[self.EVENT_PROC[szEventType]] then
		self[self.EVENT_PROC[szEventType]](self, ...);
	else
		print("Undefind EventType ", szEventType, ...);
	end
end

----------------事件函数----------------

--胜利
function BaseGame:GameWin(nGroupId)	
	self.IsWin = 1;
	self:CloseGame();
end

--失败
function BaseGame:GameLose(nGroupId)
	self.IsWin = -1;
	self:CloseGame();
end

-- 遍历组内玩家执行 默认为全体执行
function BaseGame:GroupPlayerExcute(fnExcute, nGroupId)
	if not nGroupId or nGroupId < 0 then
		nGroupId = 0;
	end
	
	local tbPlayer = self:GetPlayerList(nGroupId);	
	for _, pPlayer in pairs(tbPlayer) do
		fnExcute(pPlayer, nGroupId);
	end
end

-- 遍历队伍所有玩家执行
function BaseGame:TeamPlayerExcute(fnExcute, tbTeam)
	if not tbTeam then
		return;
	end
	for _, nTeamId in ipairs(tbTeam) do
		local tbMember, nCount = KTeam.GetTeamMemberList(nTeamId);
		for i = 1, nCount do
			local pPlayer = KPlayer.GetPlayerObjById(tbMember[i]);
			if pPlayer then
				fnExcute(pPlayer);
			end
		end
	end
end


--设临时阵营 --TODO
function BaseGame:ChangeCamp(nGroup, nCamp)
--	self.USE_CHANGE_CAMP = 1;
	local f = function(pPlayer, nGroupId)
--		self.tbGroupOriginalCamp[nGroupId] = pPlayer.GetCurCamp();
		pPlayer.SetCurCamp(nCamp);
	end
	self:GroupPlayerExcute(f, nGroup);
end


-- 执行脚本 -- TODO
--[[
function BaseGame:ExcuteScript(szCmd)
	XoyoGame.tbExcuteTable = self;
	local fnExc = loadstring("local self = XoyoGame.tbExcuteTable;"..szCmd);
	if fnExc then
		xpcall(fnExc, Lib.ShowStack);
	end
	XoyoGame.tbExcuteTable = nil;
end
--]]

--传送 
function BaseGame:NewWorld(nPlayerGroup, nX, nY, nMapId)
	if not nMapId then
		nMapId = self.nMapId;
	end
	local fnExcute = function (pPlayer)
		pPlayer.NewWorld(nMapId, nX, nY);
	end
	self:GroupPlayerExcute(fnExcute, nPlayerGroup);	
end


-- 改变Trap点传送位置
function BaseGame:ChangeTrap(szClassName, nX, nY)
	if self.tbTrap then
		self.tbTrap[szClassName] = {nx, nY};
	end
end

-- 删除Trap点传送位置
function BaseGame:DelTrap(szClassName)
	self.tbTrap[szClassName] = nil;
end

-- 给TRAP加锁 即踩TRAP有解锁功能 目前只支持一个锁
function BaseGame:AddTrapLock(szClassName, nLock)
	self.tbTrapLock[szClassName] = nLock;
end

-- 改变PK、战斗模式
function BaseGame:ChangeFight(nPlayerGroup, nFightState, nPkModel, nCamp)
	--joinCfg
--	self.tbPlayerJoinCfg.nFightState = nFightState;
--	self.tbPlayerJoinCfg.nPkModel	 = nPkModel;
--	self.tbPlayerJoinCfg.nCamp		 = nCamp;
	
	local fnExcute = function (pPlayer)
		pPlayer.SetFightState(nFightState);
		pPlayer.nPkModel = nPkModel;
		if nCamp and nCamp > 0 and nCamp <= 3 then
			pPlayer.SetCurCamp(nCamp);
		end
	end
	self:GroupPlayerExcute(fnExcute, nPlayerGroup);
end

-- 同步即时战报信息给组内玩家
function BaseGame:SetTagetInfo(nGroupId, szInfo)
	if not szInfo then
		szInfo = "";
	end	
	
	--joincfg
	self.tbPlayerJoinCfg.szInfo = szInfo;	

	local fnExcute = function (pPlayer)
		Dialog:SendBattleMsg(pPlayer,  szInfo);
		Dialog:ShowBattleMsg(pPlayer,  1,  0); --开启界面
	end
	self:GroupPlayerExcute(fnExcute, nGroupId);
end

-- 同步时间信息  --TODO
-- varLock: nLock or {nLock1, nLock2, ...}
function BaseGame:SetTimeInfo(nPlayerGroup, szTimeInfo, varLock)
	local tbLock = nil;
	local tbLockTime = {};
	if type(varLock) == "number" then
		tbLock = {varLock};
	else
		tbLock = varLock;
	end
		
	for _, nLock in ipairs(tbLock) do
		if not self.tbLock[nLock] then
			assert(false);
		end
	end
	
	for _, nLock in ipairs(tbLock) do
		local nLastFrameTime = tonumber(Timer:GetRestTime(self.tbLock[nLock].nTimerId));
		if nLastFrameTime == -1 then -- timer还没开启
			nLastFrameTime = self.tbLockMisCfg.LOCK[nLock].nTime*Env.GAME_FPS;
		end
		table.insert(tbLockTime, nLastFrameTime);
	end
	
	--joincfg
	self.tbPlayerJoinCfg.szTimeInfo = szTimeInfo;
	self.tbPlayerJoinCfg.tbLock = tbLock;
	
	local fnExcute = function (pPlayer)
		Dialog:SetBattleTimer(pPlayer,  szTimeInfo, unpack(tbLockTime));
	end
	self:GroupPlayerExcute(fnExcute, nPlayerGroup);
end

-- 关闭即时战报信息
function BaseGame:CloseInfo(nGroupId)
--	self.nIsUiOpen = 0;
	self.tbPlayerJoinCfg.szTimeInfo = nil;
	self.tbPlayerJoinCfg.tbLock		= nil;
	self.tbPlayerJoinCfg.szInfo     = nil;
	
	local fnExcute = function (pPlayer)
		Dialog:ShowBattleMsg(pPlayer,  0,  0); --关闭界面
	end
	self:GroupPlayerExcute(fnExcute, nGroupId);
end

-- 电影模式对话
function BaseGame:MovieDialog(nGroupId, szMovie)
	local fnExcute = function (pPlayer)
		Setting:SetGlobalObj(pPlayer);
		TaskAct:Talk(szMovie);
		Setting:RestoreGlobalObj();
	end
	self:GroupPlayerExcute(fnExcute, nGroupId);
end

-- 黑条消息
function BaseGame:BlackMsg(nGroupId, szMsg)
	local fnExcute = function (pPlayer)
		Dialog:SendBlackBoardMsg(pPlayer, szMsg)
	end
	self:GroupPlayerExcute(fnExcute, nGroupId);
end

--给玩家保护BUFF
function BaseGame:AddProtectedState(nGroupId, nSec)
	local fnExcute = function (pPlayer)
		Player:AddProtectedState(pPlayer, nSec);   
	end
	self:GroupPlayerExcute(fnExcute, nGroupId);	
end	

-- 篝火  --TODO
-- nMinute: ?
-- nBaseMultip: ?
-- 篝火npc的group
-- varPoint: {x,y} or 点的名字
--[[
function BaseGame:AddGouHuo(nMinute, nBaseMultip, szGroup, varPoint)
	if not self.tbTeam[1] then
		return 0;
	end
	
	local pos;
	
	if type(varPoint) == "table" then
		pos = varPoint;
	else
		local szPointName = varPoint
		local tbPoint 	= XoyoGame.tbNpcPoint[szPointName];
		if not tbPoint then
			return 0;
		end
		local nRand = MathRandom(#tbPoint)
		pos = tbPoint[nRand];
	end
	
	local nTeamId	= self.tbTeam[1].nTeamId;
	local tbNpc		= Npc:GetClass("gouhuonpc");
	local pNpc		= KNpc.Add2(tbNpc.nNpcId, 1, -1, self.nMapId, pos[1], pos[2]);		-- 获得篝火Npc
	if pNpc then
		tbNpc:InitGouHuo(pNpc.dwId, 1,	nMinute * 60, 5, 40, nBaseMultip, 1)
		tbNpc:SetTeamId(pNpc.dwId, nTeamId);
		tbNpc:StartNpcTimer(pNpc.dwId)
		self:AddNpcInGroup(pNpc, szGroup);
		KTeam.Msg2Team(nTeamId, "队伍篝火已经点燃，队伍成员可在篝火周围分享经验！");
	else
		print("XoyoGame", "AddGouHuo Failed");
	end
end
--]]
-- npc头顶冒字
function BaseGame:SendNpcChat(szGroup, szChat)
	if not szGroup or not self.tbNpcGroup[szGroup] then
		print("error", "No Npc Group!");
		return 0;
	end
	for _, nNpcId in pairs(self.tbNpcGroup[szGroup]) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.SendChat(szChat);
			local tbNearPlayer = KNpc.GetAroundPlayerList(pNpc.dwId, 30);
			if tbNearPlayer then
				for _, pPlayer in ipairs(tbNearPlayer) do
					pPlayer.Msg(szChat, pNpc.szName);
				end
			end
		else
			print("NO NPC?")
		end
	end
end

-- 公告
function BaseGame:SendPlayerMsg(nGroupId, szMsg)
	local f = function(pPlayer)
		pPlayer.Msg(szMsg);
	end
	
	self:GroupPlayerExcute(f, nGroupId);
end

function BaseGame:AddTeamTitle(nPlayerGroup, nGenre, nDetail, nLevel, nParam)
	local fnExcute = function (pPlayer)
		pPlayer.AddTitle(nGenre, nDetail, nLevel, nParam);
	end
	self:GroupPlayerExcute(fnExcute, nPlayerGroup);
end


--++++++Npc相关函数+++++++++++----

---Npc死亡回调
--[[
function BaseGame:OnKillNpc()
	self:UnLockNpc(him);
end
--]]

--添加NPC 
-- nNum: 数量 nTemplateId: NPC模板ID
-- nLock: 加锁序号（解锁用) szGroup: NPC组名
function BaseGame:AddNpc(nTemplateId, nLevel, nSeries, nNum, nLock, szGroup, szPointName, nTimes, nFrequency, szTimerName)
	if (nTimes or nFrequency or szTimerName) and not (nTimes > 1 and nFrequency > 0 and szTimerName) then
		assert(false);
	end
	
--[[	
	if type(varIndex) == "number" then
		varIndex = {varIndex};
	end
	for _, id in ipairs(varIndex) do
		local tbNpcInfo = self.tbSetting.NPC[id];
		assert(tbNpcInfo);
	end
--]]
	--local varIndex = nTemplateId;
	
	if nFrequency and not self.tbAddNpcTimer[szTimerName] then
		self.tbAddNpcTimer[szTimerName] = {};
		self.tbAddNpcTimer[szTimerName].tbNpcId = {};
	end

	self:__AddNpc(nTemplateId, nLevel, nSeries, nNum, nLock, szGroup, szPointName, nTimes, nFrequency, szTimerName);
end

-- 计算玩家等级平均值
function BaseGame:GetAverageLevel()
	local nLevel = nil;
	-- 计算房间内玩家平均等级
	local tbPlayer, nCount = self:GetPlayerList(0);
	if nCount == 0 then
		return 0;
	end
	local nTotalLevel = 0;
	for _ , pPlayer in pairs(tbPlayer) do
		nTotalLevel = nTotalLevel + pPlayer.nLevel;
	end
		
	nLevel = math.ceil(nTotalLevel / nCount);
	return nLevel;
end

-- 把npc刷到不同位置上
function BaseGame:__AllocNpc(nNum, nTemplateId, nLock, szGroup, nLevel, nSeries, tbPoint)
	local pNpc = nil;
	local tbNpcId = {};
	Lib:SmashTable(tbPoint);	
	local x, y = nil, nil;
	for i = 1, nNum do
		local nPos = i;
		if i > #tbPoint then
			nPos = MathRandom(#tbPoint);
			x, y = tbPoint[nPos][1], tbPoint[nPos][2];
		else
			x, y = tbPoint[nPos][1], tbPoint[nPos][2];
		end
		
		pNpc = KNpc.Add2(nTemplateId, nLevel, nSeries, self.nMapId, x,y,0,0,0,1);
		--pNpc = KNpc.Add2(nTemplateId, nLevel, nSeries, self.nMapId, x,y);
		if pNpc then
			pNpc.GetTempTable("Mission").tbGame = self;
			self:AddNpcInLock(pNpc, nLock);
			self:AddNpcInGroup(pNpc, szGroup);
			table.insert(tbNpcId, pNpc.dwId);
		else
		--	print("Add Npc Failed", nTemplateId, nLevel, nSeries, self.nMapId, x,y,0,0,0,1)
		end
	end
	return tbNpcId;
end

function BaseGame:__AddNpc(nTemplateId, nLevel, nSeries, nNum, nLock, szGroup, szPointName, nTimes, nFrequency, szTimerName)
	
	--刷之前先检查MISSION还在不在
	if self:IsOpen() == 0 then
		print("Mission Is Closed");
		return;
	end
	
	local tbPoint = self.tbLockMisCfg.tbNpcPoint[szPointName];
	if not tbPoint then
		print("no npc point");
		return 0;
	end
	
	if nLevel <= 0 then
		nLevel = self:GetAverageLevel();
	end
	
	local tbNpcId = self:__AllocNpc(nNum, nTemplateId, nLock, szGroup, nLevel, nSeries, tbPoint);
	
	if nFrequency then
		for _, id in ipairs(self.tbAddNpcTimer[szTimerName].tbNpcId) do -- 删除上一轮的npc
			local pNpc = KNpc.GetById(id);
			if pNpc then
				pNpc.Delete();
			end
		end
		if nTimes == 1 then
			self.tbAddNpcTimer[szTimerName].nTimerId = nil;
			self.tbAddNpcTimer[szTimerName].tbNpcId = tbNpcId;
		else
			self.tbAddNpcTimer[szTimerName].nTimerId = Timer:Register(nFrequency * Env.GAME_FPS, self.__AddNpc, self, tbIndex, nNum, nLock, szGroup, szPointName, nTimes - 1, nFrequency, szTimerName);
			self.tbAddNpcTimer[szTimerName].tbNpcId = tbNpcId;
		end
	end
	
	return 0;
end

-- 把NPC加到锁里
function BaseGame:AddNpcInLock(pNpc, nLock)
	if not nLock or nLock <= 0 then
		print("【LockMis】AddNpcInLock nLock error",pNpc.szName, nLock);
		return 0;
	end
	local tbTmp = pNpc.GetTempTable("Mission");
	tbTmp.nLock = nLock;
end

-- 把NPC加到组里
function BaseGame:AddNpcInGroup(pNpc, szGroup)
	if not self.tbNpcGroup[szGroup] then
		self.tbNpcGroup[szGroup] = {};
	end
	if pNpc then
		table.insert(self.tbNpcGroup[szGroup], pNpc.dwId);
	end
end

-- 删除特定组的NPC
function BaseGame:DelNpc(szGroup)
	if not self.tbNpcGroup[szGroup] then
		return 0;
	end
	for _, nId in pairs(self.tbNpcGroup[szGroup]) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			pNpc.Delete();
		end
	end
	self.tbNpcGroup[szGroup] = nil;
end

--NPC行进路线
function BaseGame:SetNpcMove(pNpc, szRoad, nLockId, nAttact, bRetort, bArriveDel)
	if not self.tbLockMisCfg.tbRoad or not self.tbLockMisCfg.tbRoad[szRoad] then
		print("SetNpcMove:not road");
		return 0;
	end
	pNpc.AI_ClearPath();
	for _,Pos in pairs(self.tbLockMisCfg.tbRoad[szRoad]) do
		if (Pos[1] and Pos[2]) then
			pNpc.AI_AddMovePos(Pos[1]*32, Pos[2]*32);
		end
	end
	pNpc.SetNpcAI(9, nAttact or 0, bRetort or 1, -1, 25, 25, 25, 0, 0, 0, 0);
	pNpc.SetActiveForever(1);
	pNpc.GetTempTable("Npc").tbOnArrive = {self.OnArrive, self, nLockId, bArriveDel};
end

function BaseGame:SetNpcReMove(pNpc, szRoad, nAttact, bRetort, nTimes)
	if not self.tbLockMisCfg.tbRoad or not self.tbLockMisCfg.tbRoad[szRoad] then
		print("SetNpcReMove:not road");
		return 0;
	end
	pNpc.AI_ClearPath();
	for _,Pos in pairs(self.tbLockMisCfg.tbRoad[szRoad]) do
		if (Pos[1] and Pos[2]) then
			pNpc.AI_AddMovePos(Pos[1]*32, Pos[2]*32);
		end
	end
	pNpc.SetNpcAI(9, nAttact or 0, bRetort or 1, -1, 25, 25, 25, 0, 0, 0, 0);
	pNpc.SetActiveForever(1);
	pNpc.GetTempTable("Npc").tbOnArrive = {self.OnReMoveArrive, self, szRoad, nAttact, bRetort, nTimes};
end

function BaseGame:SetNpcAttack(pNpc, szNpc, nCamp, bRetort)
	pNpc.SetCurCamp(nCamp)
	if szNpc and self.tbNpcGroup[szNpc] then
		if #self.tbNpcGroup[szNpc] >= 1 then
			local nRandom = MathRandom(#self.tbNpcGroup[szNpc]);
			local pTagetNpc = KNpc.GetById(self.tbNpcGroup[szNpc][nRandom])
			if pTagetNpc then
				pNpc.SetNpcAI(9, 100, bRetort or 1, -1, 25, 25, 25, 1, 0, self.tbNpcGroup[szNpc][nRandom], 0);
			end
		end
	end
end

function BaseGame:OnArrive(nLockId, bArriveDel)
	-- 要先删除NPC~
	if bArriveDel == 1 then
		him.Delete();
	end
	if not nLockId then
		return 0;
	end
	
	if not self.tbLock[nLockId] then
		return 0;
	end
	self.tbLock[nLockId]:UnLockMulti();
end

function BaseGame:OnReMoveArrive(szRoad, nAttact, bRetort, nTimes)
	if not self.tbLockMisCfg.tbRoad or not self.tbLockMisCfg.tbRoad[szRoad] then
		return 0;
	end
	him.AI_ClearPath();
	for _,Pos in pairs(self.tbLockMisCfg.tbRoad[szRoad]) do
		if (Pos[1] and Pos[2]) then
			him.AI_AddMovePos(Pos[1]*32, Pos[2]*32);
		end
	end
	him.SetNpcAI(9, nAttact or 0, bRetort or 1, -1, 25, 25, 25, 0, 0, 0, 0);
end



function BaseGame:ChangeNpcAi(szNpcGroup, nAiMode, ...)
	if not self.tbNpcGroup[szNpcGroup] then
		print("NpcGroup is not In", szNpcGroup);
		return 0
	end
	if self.AI_MODE_PROC[nAiMode] and self[self.AI_MODE_PROC[nAiMode]] then
		for i, nNpcId in pairs(self.tbNpcGroup[szNpcGroup]) do
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				self[self.AI_MODE_PROC[nAiMode]](self, pNpc, ...);
			end
		end
	else
		print("Undefine AiModeType ", nAiMode, ...);
	end
end

--给NPC加上生命值减少的回调
function BaseGame:AddNpcLifePObserver(szNpcGroup,nPercent)
	if not self.tbNpcGroup[szNpcGroup] then
		print("NpcGroup is not In", szNpcGroup);
		return 0
	end
	local nIsSet = 0;
	for _, nNpcId in ipairs(self.tbNpcGroup[szNpcGroup]) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.AddLifePObserver(nPercent);
		end
	end
end

function BaseGame:AddDiaologNpcRate(szNpcGroup, nRate)
	for _, nNpcId in ipairs(self.tbNpcGroup[szNpcGroup]) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.GetTempTable("Mission").nRate = nRate;
		end
	end	
end

function BaseGame:UnLockNpc(pNpc)
	if not pNpc then
		print("UnLockNpc:pNpc is null");
		return;
	end
	local tbTmp = pNpc.GetTempTable("Mission");

	if not tbTmp.nLock then
		print("not Lock");
		return 0;
	end
	if not self.tbLock[tbTmp.nLock] then
		print("not lock2");
		return 0;
	end
	self.tbLock[tbTmp.nLock]:UnLockMulti();	
	pNpc.GetTempTable("Mission").nLock = nil;
end



---++++++派生类接口+++++++++
--玩家加入MISSION 后调用
function BaseGame:OnLockMisJoin(nGroupId)
--	print("【LockMis】 BaseClass: OnLockMisJoin", me.szName);
end

--玩家加入MISSION 后调用
function BaseGame:OnLockMisLeave(nGroupId, szReason)
--	print("【LockMis】 BaseClass: OnLockMisLeave", me.szName);
end

function BaseGame:OnGameClose()
--	print("【LockMis】 BaseClass: OnGameClose");
end

--++地图事件接口

function BaseGame:OnMapTrap(szClassName)
--	print("【LockMis】 BaseClass: OnMapTrap", me.szName, szClassName);
end


function BaseGame:OnMapEnter()
--	print("【LockMis】 BaseClass: OnMapEnter", me.szName);
end

function BaseGame:OnMapLeave()
--	print("【LockMis】 BaseClass: OnMapLeave", me.szName);
end
