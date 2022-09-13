Require("\\script\\task\\treasuremap\\treasuremap.lua")

local tbInstancingMgr = TreasureMap.InstancingMgr;
tbInstancingMgr.tbUsable = {}; 		-- 已经加载的可用副本地图列表
tbInstancingMgr.tbWaitQueue = {};	-- 等待FB的队列
tbInstancingMgr.tbOpenedList = {};	-- 已经打开的FB列表
 
-- 玩家开出一个FB
function tbInstancingMgr:CreatInstancing(pPlayer, nTreasureId)
	assert(pPlayer)
	if (pPlayer.nTeamId == 0) then
		Dialog:SendInfoBoardMsg(pPlayer, "<color=red>只有组队才能进入副本！<color>");
		return;
	end
	
	local tbTreasureInfo = TreasureMap:GetTreasureInfo(nTreasureId);
	local nMyMapId, nMyPosX, nMyPosY	= pPlayer.GetWorldPos();
	if (tbTreasureInfo.MapId ~= nMyMapId) then
		Dialog:SendInfoBoardMsg(pPlayer, "<color=red>你和宝藏不在同一地图！<color>");
		return;
	end
	
	local nTreasureMapId, bReset = self:PreorderMap(tbTreasureInfo.InstancingMapId, nTreasureId, tbTreasureInfo.MaxMap);
	
	-- 通知GC载入地图
	if (not nTreasureMapId) then
		if (LoadDynMap(Map.DYNMAP_TREASUREMAP, tbTreasureInfo.InstancingMapId, nTreasureId) == 1) then
			self.tbWaitQueue[#self.tbWaitQueue + 1] = {nPlayerId = pPlayer.nId, tbPos = {nMyMapId, nMyPosX, nMyPosY}, nTreasureId = nTreasureId, nMapTemplateId = tbTreasureInfo.InstancingMapId};
		end
	else
		self:OpenMap(pPlayer, nTreasureId, nTreasureMapId, tbTreasureInfo.MapId, nMyPosX, nMyPosY, bReset);
	end
end


-- 预订一个副本
function tbInstancingMgr:PreorderMap(nMapTemplateId, nTreasureId, nMaxMap)
	local bReset = 1;	-- 是否需要重置副本
	
	-- 复用之前可用的老的副本，需要重置
	for nIndex = 1, #self.tbUsable[nTreasureId] do
		if ((self.tbUsable[nTreasureId][nIndex].MapTemplateId == nMapTemplateId) and (self.tbUsable[nTreasureId][nIndex].Free == 1)) then
			self.tbUsable[nTreasureId][nIndex].Free = 0;
			return self.tbUsable[nTreasureId][nIndex].MapId, bReset;
		end
	end
	
	
	-- 进入一个有人的副本
	if (nMaxMap > 0 and #self.tbUsable[nTreasureId] >= nMaxMap) then
		bReset = 0;
		local nIndex = MathRandom(#self.tbUsable[nTreasureId]);
		return self.tbUsable[nTreasureId][nIndex].MapId, bReset;	-- 进入有人的FB，不重置里面的东西
	end
	
	-- 执行到此处说明没有FB可用，需要通知GC载入一个地图
end

-- GC载入地图完毕
function tbInstancingMgr:OnLoadMapFinish(nTreasureMapId, nMapTemplateId, nTreasureId)
	if (#self.tbWaitQueue == 0) then
		assert(false);
		return;
	end
	
	for nIndex = 1, #self.tbWaitQueue do
		if (nMapTemplateId == self.tbWaitQueue[nIndex].nMapTemplateId and nTreasureId == self.tbWaitQueue[nIndex].nTreasureId) then
			local pPlayer = KPlayer.GetPlayerObjById(self.tbWaitQueue[nIndex].nPlayerId);
			if (pPlayer and pPlayer.nTeamId ~= 0) then
				self.tbUsable[nTreasureId][#self.tbUsable[nTreasureId] + 1] = {MapTemplateId = nMapTemplateId, MapId = nTreasureMapId, Free = 0};
				self:OpenMap(pPlayer, self.tbWaitQueue[nIndex].nTreasureId, nTreasureMapId, self.tbWaitQueue[nIndex].tbPos[1], self.tbWaitQueue[nIndex].tbPos[2], self.tbWaitQueue[nIndex].tbPos[3], 1);
				table.remove(self.tbWaitQueue, nIndex);
				break;
			else
				self.tbUsable[nTreasureId][#self.tbUsable[nTreasureId] + 1] = {MapTemplateId = nMapTemplateId, MapId = nTreasureMapId, Free = 1};
				table.remove(self.tbWaitQueue, nIndex);
				break;
			end
		end
	end
end


-- 开启副本地图
function tbInstancingMgr:OpenMap(pPlayer, nTreasureId, nTreasureMapId, nEntranceMapId, nEntranceMapPosX, nEntranceMapPosY, bReset)
	assert(pPlayer)
	if (bReset == 1) then
		assert(not self.tbOpenedList[nTreasureMapId]);
	end
	
	self:RegisterEntranceNpc(pPlayer, nTreasureId, nTreasureMapId, nEntranceMapId, nEntranceMapPosX, nEntranceMapPosY, bReset);
	if (bReset == 1) then
		self:ResetMap(nTreasureMapId);
	end
	
	
	local tbInfo = TreasureMap:GetTreasureInfo(nTreasureId);
	local nMapTemplateId = tbInfo.InstancingMapId;
	local tbInstancingBase = TreasureMap:GetInstancingBase(nMapTemplateId);
	local tbInstancing = Lib:NewClass(tbInstancingBase);
	
	self.tbOpenedList[nTreasureMapId] = tbInstancing;
	tbInstancing.nTreasureId = nTreasureId;
	tbInstancing.nTreasureMapId = nTreasureMapId;
	tbInstancing.nMapTemplateId = nMapTemplateId;
	if (bReset == 1) then
		tbInstancing.nFirstOpenerId = pPlayer.nId;
		tbInstancing:OnNew();
		tbInstancing.nCurStep = 1;
		if (tbInstancing.GetSteps and #tbInstancing:GetSteps() > 0) then
			tbInstancing.nTimerId = Timer:Register(TreasureMap.nInstancingCheckTime, self.OnInstancingTimer, self, nTreasureMapId);
		end
	end
	tbInstancing.tbPlayerList = {};
	tbInstancing:OnOpen();
	
	--额外事件，活动系统
	SpecialEvent.ExtendEvent:DoExecute("Open_Treasure", tbInfo.nLevel, nTreasureMapId, nMapTemplateId);
end


function tbInstancingMgr:OnInstancingTimer(nTreasureMapId)
	local tbInstancing = self.tbOpenedList[nTreasureMapId];
	if (not tbInstancing) then
		return;
	end
	local tbSteps = tbInstancing:GetSteps();
	local tbStep = tbSteps[tbInstancing.nCurStep]
	if (not tbStep) then
		tbInstancing.nTimerId = nil;
		return 0;
	end
	
	-- 满足condition
	if (self:CheckConditions(tbStep.tbConditions) == 1) then
		tbInstancing.nCurStep = tbInstancing.nCurStep + 1;
		self:DoActions(tbStep.tbActions);
		return tbStep.nTime * Env.GAME_FPS;
	end
	
	return TreasureMap.nInstancingCheckTime;
end


function tbInstancingMgr:CheckConditions(tbConditions)
	if (not tbConditions) then
		return 1;
	end
	
	for _, tbCondition in ipairs(tbConditions) do
		local _, nRet	= Lib:CallBack(tbCondition);
		if (nRet ~= 1) then
			return 0
		end
	end
	
	return 1;
end

function tbInstancingMgr:DoActions(tbActions)
	if (not tbActions) then
		return;
	end
	
	for _, tbAction in ipairs(tbActions) do
		Lib:CallBack(tbAction);
	end
end


-- 注册一个入口Npc
function tbInstancingMgr:RegisterEntranceNpc(pPlayer, nTreasureId, nTreasureMapId, nEntranceMapId, nEntranceMapPosX, nEntranceMapPosY, bReset)
	assert(pPlayer);
	local tbTreasureInfo = TreasureMap:GetTreasureInfo(nTreasureId);
	local pNpc = KNpc.Add2(TreasureMap.TreasureMapEntranceNpcId, 1, -1, nEntranceMapId, nEntranceMapPosX, nEntranceMapPosY);
	local tbNpcData = pNpc.GetTempTable("TreasureMap");

	tbNpcData.nEntrancePlayerId 	= pPlayer.nId;
	tbNpcData.nEntranceTreasureId 	= nTreasureId;
	tbNpcData.nTreasureMapId		= nTreasureMapId;
	tbNpcData.nTreasureMapLevel		= tbTreasureInfo.Level;
	tbNpcData.nMapTemplateId		= tbTreasureInfo.InstancingMapId;
	
	local szTitle = pPlayer.szName.."发掘的地下入口";
	pNpc.SetTitle(szTitle);
	Timer:Register(50 *60 *Env.GAME_FPS, self.DelEntrance, self, pPlayer.nId, pNpc.dwId);
	
	if (bReset) then
		Timer:Register(tbTreasureInfo.Duration * 60 * Env.GAME_FPS, self.DelMap, self, nTreasureId, nTreasureMapId, nEntranceMapId, nEntranceMapPosX, nEntranceMapPosY, pPlayer.nId);
	end
end

-- 删除入口
function tbInstancingMgr:DelEntrance(nPlayerId, nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (not pNpc) then
		return;
	end
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (pPlayer) then
		pPlayer.Msg("<color=yellow>你所发现的地底入口已经消失！<color>")
	end
	
	pNpc.Delete();
	
	return 0;
end


-- 删除一个副本地图
function tbInstancingMgr:DelMap(nTreasureId, nMapId, nEntranceMapId, nEntranceMapPosX, nEntranceMapPosY, nPlayerId)
	assert(self.tbOpenedList[nMapId]);
	local tbInstancing = self.tbOpenedList[nMapId];
	
	-- 关闭计时器
	if (tbInstancing.nTimerId) then
		Timer:Close(tbInstancing.nTimerId);
		tbInstancing.nTimerId = nil;
	end
	
	if (tbInstancing.OnDelete) then
		tbInstancing:OnDelete();
	end
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (pPlayer) then
		pPlayer.Msg("<color=yellow>随着一声巨响，你所发现的地底迷宫已经倒塌！<color>")
	end
	
	-- 玩家回到入口点
	local tbPlayerList = KPlayer.GetMapPlayer(nMapId);
	for _, pPlayer in pairs(tbPlayerList) do
		pPlayer.NewWorld(nEntranceMapId, nEntranceMapPosX, nEntranceMapPosY);
	end
	
	for _, Instancing in ipairs(self.tbUsable[nTreasureId]) do
		if (Instancing.MapId == nMapId and Instancing.Free == 0) then
			Instancing.Free = 1;
			break;
		end
	end
	
	self.tbOpenedList[nMapId] = nil;
	
	return 0;
end


-- 重置一个副本地图
function tbInstancingMgr:ResetMap(nMapId)
	ResetMapNpc(nMapId);
end


function tbInstancingMgr:ShowInstancingInfo(pPlayer)
	for _, tbTreasureMap in pairs(self.tbUsable) do
		for _, Instancing in ipairs(tbTreasureMap) do
			pPlayer.Msg("地图模板Id："..Instancing.MapTemplateId.."，地图Id："..Instancing.MapId.."，是否空闲："..Instancing.Free);
		end
	end
end

function tbInstancingMgr:IsInstancingFree(nTreasureId, nMapId)
	assert(self.tbUsable[nTreasureId]);
	for _, Instancing in ipairs(self.tbUsable[nTreasureId]) do
		if (Instancing.MapId == nMapId) then
			return Instancing.Free;
		end
	end
end

function tbInstancingMgr:GetInstancing(nMapId)
	return self.tbOpenedList[nMapId];	
end
function tbInstancingMgr:WeekEvent()
	me.ClearTaskGroup(2066, 1);	-- 每周进入指定地图的次数清0
	me.SetTask(TreasureMap.TSKGID, TreasureMap.TSK_OPENBOX, 0, 1);	-- 玩家每周开箱子的次数
end

PlayerSchemeEvent:RegisterGlobalWeekEvent({"TreasureMap.InstancingMgr:WeekEvent"});
