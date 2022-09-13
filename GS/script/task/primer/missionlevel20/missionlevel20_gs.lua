-- 文件名　：missionlevel20_gs.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-09-20 10:22:36
-- 描述：20级教育副本gs

if not MODULE_GAMESERVER then
	return 0;
end

Require("\\script\\task\\primer\\missionlevel10\\missionlevel10_def.lua")

Task.PrimerLv20 = Task.PrimerLv20 or {};
local PrimerLv20 = Task.PrimerLv20;

PrimerLv20.tbGameManager = {};
local tbGameManager = PrimerLv20.tbGameManager;

function tbGameManager:InitManager()
	self.tbGame = {};
	self.tbMap = {};
	self.tbPlayer = {};	--存储是谁开的副本
	self.tbMap_Time = {};
	self.nMapCount = 0;
	self.nGameCount = 0;
end

--gs根据server id申请fb
function tbGameManager:ApplyGame(nPlayerId,nServerId,nApplyMapId)
	self:ClearOutData(self.nMapCount);--申请超时删除
	for i = 1, self.nMapCount do
		if not self.tbGame[self.tbMap[i]] and self.tbMap[i] and self.tbMap[i] ~= 0 then
			self.tbPlayer[nPlayerId] = self.tbMap[i];
			self.tbMap[i] = self.tbMap[i];
			self.tbGame[self.tbMap[i]] = Lib:NewClass(PrimerLv20.tbBase);
			self.tbGame[self.tbMap[i]]:InitGame(self.tbMap[i],nServerId,nPlayerId);
			self.nGameCount = self.nGameCount + 1;
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			local szName = pPlayer and pPlayer.szName or "";
			GCExcute{"Task.PrimerLv20:SyncGameMapInfo_GC",nPlayerId,szName,nApplyMapId};	--同步申请信息到每个gs，保证一个队伍只开启一个副本
			return 1;
		end
	end
	if self.nMapCount >= PrimerLv20:GetMapMaxCount() then
		return 0;
	end
	if (Map:LoadDynMap(Map.DYNMAP_TREASUREMAP,PrimerLv20.nMapTemplateId, {self.OnLoadMapFinish,self,nPlayerId,nServerId,nApplyMapId}) == 1)then
		self.nMapCount = self.nMapCount + 1; 	-- 先占一个名额~不用等GC响应也能判断是否已经到达副本上限
		self.tbMap[self.nMapCount] = 0; 		-- 先标0防止其他副本使用本地图
		self.tbPlayer[nPlayerId] = 0;
		self.tbMap_Time[self.nMapCount] = {nPlayerId, GetTime()};
		return 1;
	end
end

--地图加载完成后的回调
function tbGameManager:OnLoadMapFinish(nPlayerId,nServerId,nApplyMapId,nMapId)
	local i = #self.tbMap;
	if self.tbMap[i] == 0 then
		self.tbPlayer[nPlayerId] = nMapId;
		self.tbMap[i] = nMapId;
		self.tbGame[self.tbMap[i]] = Lib:NewClass(PrimerLv20.tbBase);
		self.tbGame[self.tbMap[i]]:InitGame(self.tbMap[i],nServerId,nPlayerId);
		self.nGameCount = self.nGameCount + 1;
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		local szName = pPlayer and pPlayer.szName or "";
		GCExcute{"Task.PrimerLv20:SyncGameMapInfo_GC",nPlayerId,szName,nApplyMapId};	--同步申请信息到每个gs，保证一个队伍只开启一个副本
	end
	return 1;
end

function tbGameManager:ClearOutData(nIdx)
	local nNowTime = GetTime();
	for j = nIdx, 1 , -1 do
		if self.tbMap[j] == 0 and self.tbMap_Time then
			local tbInfo = self.tbMap_Time[j];
			if tbInfo and nNowTime - tbInfo[2] >= 600 then
				table.remove(self.tbMap,j);
				self.tbPlayer[tbInfo[1]] = nil;
				self.tbMap_Time[j] = nil;
				self.nMapCount = self.nMapCount - 1;
			end
		end
	end	
end

function PrimerLv20:Init()
	self.tbManager = {};
end

if not PrimerLv20.tbManager then
	PrimerLv20:Init();
end

--获取当前server游戏数量
function PrimerLv20:GetGameCount(nServerId)
	if not self.tbManager[nServerId] then
		return 0;
	end
	return self.tbManager[nServerId].nGameCount;
end

--根据开服天数，判断一个服务器能开启的地图的最大数量
function PrimerLv20:GetMapMaxCount()
	if TimeFrame:GetServerOpenDay() >= 30 then
		return 0;
	else
		return 0;
	end
end

--根据开服天数，判断一个服务器能开启的副本的最大数量
function PrimerLv20:GetGameMaxCount()
	if TimeFrame:GetServerOpenDay() >= 30 then
		return 0;
	else
		return 0;
	end
end

--开启指定步骤的副本阶段,通过task传入
function PrimerLv20:StartStepByTaskStep(pPlayer,nStep)
	if not pPlayer then
		return 0;
	end
	--获取玩家的对应的game对象，进行阶段开启
	local pGame = self:GetGameObjByPlayerId(pPlayer.nId);
	if not pGame then
		return 0;
	end
	pGame:StartStep(nStep);
end

function PrimerLv20:GetGameCount(nServerId)
	if not self.tbManager[nServerId] then
		return 0;
	end
	return self.tbManager[nServerId].nGameCount;
end

--通过地图id获取fb对象
function PrimerLv20:GetGameObjByMapId(nMapId)
	local tbManager = self.tbManager;
	if tbManager[GetServerId()] and tbManager[GetServerId()].tbGame and tbManager[GetServerId()].tbGame[nMapId] then
		return tbManager[GetServerId()].tbGame[nMapId];
	end
end

--通过playerid 获取对象
function PrimerLv20:GetGameObjByPlayerId(nPlayerId)
	local tbManager = self.tbManager;
	if tbManager[GetServerId()] and tbManager[GetServerId()].tbPlayer[nPlayerId] and
		tbManager[GetServerId()].tbGame and tbManager[GetServerId()].tbGame[tbManager[GetServerId()].tbPlayer[nPlayerId]] then
		return tbManager[GetServerId()].tbGame[tbManager[GetServerId()].tbPlayer[nPlayerId]];
	end
end

--申请
function PrimerLv20:ApplyGame_GS(nPlayerId,nServerId,nApplyMapId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not self.tbManager[nServerId] then
		self.tbManager[nServerId] = Lib:NewClass(tbGameManager);
		self.tbManager[nServerId]:InitManager();
	end
	if self.tbGameMapInfo and self.tbGameMapInfo[nPlayerId] then	--已经有申请过了
		return 0;
	end
	local nRet = self.tbManager[nServerId]:ApplyGame(nPlayerId,nServerId,nApplyMapId);
	if nRet ~= 1 and pPlayer then
		pPlayer.Msg("当前副本地图都已经有侠士去挑战了，请稍后再来！");
		return 0;
	end
end

function PrimerLv20:ApplyStaticGame_GS(nPlayerId,nServerId)
	if not self.tbStaticGame then
		self.tbStaticGame = {};
	end
	for _,nMapId in pairs(self.STATIC_MAP_ID) do
		if nMapId and IsMapLoaded(nMapId) == 1 then
			local tbGame = Lib:NewClass(PrimerLv20.tbBase);
			tbGame:InitGame(nMapId,nServerId,nPlayerId,1);	--标记是不是静态的
			table.insert(self.tbStaticGame,tbGame);
		end
	end
end


--获取静态的副本对象
function PrimerLv20:GetStaticGameObjByServerId(nServerId)
	if not self.tbStaticGame then
		return nil;
	end
	local pGame = nil;
	for _,tbGame in pairs(self.tbStaticGame) do
		if tbGame then
			pGame = tbGame;
			break;
		end
	end
	return pGame;
end

--同步申请的信息，保证所有server一个人里只能申请一个
function PrimerLv20:SyncGameMapInfo_GS(nPlayerId,szName,nApplyMapId)
	if not self.tbGameMapInfo then
		self.tbGameMapInfo = {};
	end
	if not self.tbGameMapInfo[nPlayerId] then
		self.tbGameMapInfo[nPlayerId] = {};
	end
	self.tbGameMapInfo[nPlayerId].szName = szName;
	self.tbGameMapInfo[nPlayerId].nApplyMapId = nApplyMapId;
end


-- 关闭
function PrimerLv20:EndGame_GS(nPlayerId,nServerId,nMapId)
	if self.tbManager and self.tbManager[nServerId] and 
		self.tbManager[nServerId].tbGame and self.tbManager[nServerId].tbGame[nMapId] then
		self.tbManager[nServerId].tbGame[nMapId] = nil;
		self.tbManager[nServerId].nGameCount = self.tbManager[nServerId].nGameCount - 1;
		self.tbManager[nServerId].tbPlayer[nPlayerId] = nil;
	end
	if self.tbGameMapInfo and self.tbGameMapInfo[nPlayerId] then
		self.tbGameMapInfo[nPlayerId] = nil;
	end
end

--加入游戏
function PrimerLv20:JoinGame()
	if me.GetTiredDegree1() == 2 then
		Dialog:Say("您太累了，还是休息下吧！");
		return;
	end
	local pGame = self:GetGameObjByPlayerId(me.nId) or self:GetStaticGameObjByServerId(GetServerId());
	if not pGame then
		return 0;
	end
	pGame:JoinGame(me);
end


--离开游戏
function PrimerLv20:LeaveGame(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local pGame = self:GetGameObjByPlayerId(nPlayerId) or self:GetStaticGameObjByServerId(GetServerId());
	if not pGame then
		return 0;
	end
	pPlayer.SetLogoutRV(0);		-- 解除服务器宕机保护
	pGame:KickPlayer(pPlayer);
	return 1;
end

function PrimerLv20:DialogLeave(nPlayerId)
	local szMsg = "确定要离开么？"
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"我要离开",Task.PrimerLv20.LeaveGame,Task.PrimerLv20,nPlayerId};
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
	return 1;
end


function PrimerLv20:OpenBiluogu()
	local pGame = Task.PrimerLv20:GetGameObjByPlayerId(me.nId);
	if not pGame then
		local nNum = Task.PrimerLv20:GetGameCount(GetServerId());
		if nNum >= Task.PrimerLv20:GetGameMaxCount() then
			self:OpenStaticGame();
			return 0;
		end
		if self.tbManager and self.tbManager[GetServerId()] and self.tbManager[GetServerId()].tbPlayer[me.nId] then
			Dialog:Say("你已经申请过副本了，请稍后再试！");
			return 0;
		end
		GCExcute{"Task.PrimerLv20:ApplyGame_GC",me.nId,GetServerId(),me.nMapId};
		local szMsg = "你准备好了么？"
		local tbOpt = {};
		tbOpt[#tbOpt + 1] = {"是的，我确定前往碧落谷",self.JoinBiluogu,self};
		tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
		Dialog:Say(szMsg,tbOpt);
		return 1;
	else
		local szMsg = "你准备好了么？"
		local tbOpt = {};
		tbOpt[#tbOpt + 1] = {"是的，我确定前往碧落谷",self.JoinBiluogu,self};
		tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
		Dialog:Say(szMsg,tbOpt);
		return 0;
	end
end

function PrimerLv20:JoinBiluogu()
	local pGame = self:GetGameObjByPlayerId(me.nId);
	if not pGame then
		Dialog:Say("你现在无法进入碧落谷！");	
		return 0;
	else
		self:JoinGame();
		return 0;
	end
end

function PrimerLv20:OpenStaticGame()
	local pStatic = PrimerLv20:GetStaticGameObjByServerId(GetServerId());
	if not pStatic then
		GCExcute{"Task.PrimerLv20:ApplyStaticGame_GC",me.nId,GetServerId()};
		local szMsg = "你准备好了么？"
		local tbOpt = {};
		tbOpt[#tbOpt + 1] = {"是的，我确定前往碧落谷",self.JoinStaticGame,self};
		tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
		Dialog:Say(szMsg,tbOpt);
		return 1;
	else
		self:JoinStaticGame();
		return 1;	
	end
end

function PrimerLv20:JoinStaticGame()
	local pStatic = self:GetStaticGameObjByServerId(GetServerId());
	if pStatic then
		self:JoinGame();
		return 0;
	else
		Dialog:Say("前方人满为患，请稍候再试！");	
		return 0;
	end
end

function PrimerLv20:GetReturnBackMap(nType)
	local nId = 0 ;
	local tbMap = {};
	if nType == 1 then
		tbMap = PrimerLv20.VILLAGE_MAP;
	elseif nType == 2 then
		tbMap = PrimerLv20.TIMEUP_LEAVE_MAP;
	end
	for _ , nMapId in pairs(tbMap) do
		if nMapId then
			if IsMapLoaded(nMapId) == 1 then
				nId = nMapId;
				break;
			end
		end
	end
	return nId;
end

--上线检测
function PrimerLv20:OnLogin()
	if me.GetTask(1025,32) == 2 then
		if Task:GetPlayerTask(me).tbTasks[tonumber(PrimerLv20.TASK_MAIN_ID,16)] and
			Task:GetPlayerTask(me).tbTasks[tonumber(PrimerLv20.TASK_MAIN_ID,16)].nReferId == tonumber(PrimerLv20.TASK_SUB_ID,16) then
			Task:CloseTask(tonumber(PrimerLv20.TASK_MAIN_ID,16));
			--Task:DoAccept(PrimerLv20.NEXT_TASK_MAIN_ID,PrimerLv20.NEXT_TASK_SUB_ID);
		end
	elseif me.GetTask(1025,32) == 1 then
		for _,nId in pairs(PrimerLv20.tbTaskSubId) do
			me.SetTask(1025,nId,0);
		end
		Task:CloseTask(tonumber(PrimerLv20.TASK_MAIN_ID,16));
		Task:DoAccept(PrimerLv20.TASK_MAIN_ID,PrimerLv20.TASK_SUB_ID);
	end
	return 1;
end

PlayerEvent:RegisterGlobal("OnLogin", PrimerLv20.OnLogin, PrimerLv20);