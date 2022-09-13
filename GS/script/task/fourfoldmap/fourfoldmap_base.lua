--副本mission
--sunduoliang
--2008.11.07

Require("\\script\\task\\fourfoldmap\\fourfoldmap_def.lua");

local Fourfold = Task.FourfoldMap;

--副本申请
function Fourfold:ApplyMap(nCityMapId, nPlayerId, nLevel, nHour)
	Fourfold.tbOpenHour[nPlayerId] = nHour;
	
	if not self.MapTempletList then
		self.MapTempletList = {};
		self.MapTempletList.tbBelongList = {};
		self.MapTempletList.tbMapList = {};
		self.MapTempletList.nCount = 0;
	end
	for nMapId, nFree in pairs(self.MapTempletList.tbMapList) do
		if nFree == 0 then
			self.MapTempletList.tbBelongList[nPlayerId] = {nCityMapId, nLevel, 0};
			self.MapTempletList.nCount = self.MapTempletList.nCount + 1;
			self:OnLoadMapFinish(nMapId, nPlayerId, nHour);
			GCExcute({"Task.FourfoldMap:Apply_GC", nPlayerId, nCityMapId, nLevel});
			return 1;
		end
	end
	
	if self.MapTempletList.nCount >= self.MAP_APPLY_MAX then
		return 0;
	end
	
	if (LoadDynMap(Map.DYNMAP_TREASUREMAP, self.MAP_TEMPLATE_ID, nPlayerId) == 1) then
		self.MapTempletList.tbBelongList[nPlayerId] = {nCityMapId, nLevel, 0};
		self.MapTempletList.nCount = self.MapTempletList.nCount + 1;
		GCExcute({"Task.FourfoldMap:Apply_GC", nPlayerId, nCityMapId, nLevel});
		return 1
	end
	return 0;
end

--副本申请成功回调
function Fourfold:OnLoadMapFinish(nMapId, nPlayerId, nHour)
	--local nCityMapId = self.MapTempletList.tbBelongList[nPlayerId][1];
	if not nHour then
		nHour = Fourfold.tbOpenHour[nPlayerId];
	end
	local nLevel = self.MapTempletList.tbBelongList[nPlayerId][2];
	self.MapTempletList.tbBelongList[nPlayerId][3] = nMapId;
	self.MapTempletList.tbMapList[nMapId] = 1;	--占用
	--开启副本内容。
	self:GameStart(nMapId, nPlayerId, nLevel, nHour);
end

function Fourfold:SyncMap(nPlayerId, nCityMapId, nLevel)
	if not self.MapTempletList then
		self.MapTempletList = {};
		self.MapTempletList.tbBelongList = {};
		self.MapTempletList.tbMapList = {};
		self.MapTempletList.nCount = 0;
	end
	if not self.MapTempletList.tbBelongList[nPlayerId] then
		self.MapTempletList.tbBelongList[nPlayerId] = {nCityMapId, nLevel, 0};
	end
end

function Fourfold:ReleaseMap(nPlayerId, nCityMapId, nLevel)
	if self.MapTempletList.tbBelongList[nPlayerId] then
		self.MapTempletList.tbBelongList[nPlayerId] = nil;
	end
end

function Fourfold:GameStart(nMapId, nPlayerId, nLevel, nHour)
	if not self.MissionList then
		self.MissionList = {};
	end
	if not self.MissionList[nPlayerId] then
		self.MissionList[nPlayerId] = Lib:NewClass(self.Mission);
	end
	self.MissionList[nPlayerId]:StartGame(nPlayerId, nMapId, nLevel, nHour);
end

function Fourfold:CallNpc(nMapId, nLevel)
	for _, tbPos in pairs(self.NpcPosList) do
		KNpc.Add2(self.NPC_ID, nLevel, -1, nMapId, tbPos[1], tbPos[2], 1, 2);
	end
end

--开始计时
function Fourfold:TimeStart(nPlayerId, nRestTime, nType)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		if nType == 1 then
			nRestTime = math.floor(Timer:GetWaitTime(Task.FourfoldMap.TimerList[pPlayer.nId]) / Env.GAME_FPS);
		end
		nRestTime = pPlayer.GetTask(self.TSK_GROUP, self.TSK_REMAIN_TIME) - nRestTime;
		if nRestTime < 0 then
			nRestTime = 0;
		end
		pPlayer.SetTask(self.TSK_GROUP, self.TSK_REMAIN_TIME, nRestTime);
		local tbPlayerTemp = self.PlayerTempList[pPlayer.nId];
		if tbPlayerTemp then
			local tbMis = self.MissionList[tbPlayerTemp.nCaptain];
			if nType == 1 and nRestTime > 0 and tbMis then
				local nStateTime = tbMis:GetStateLastTime();
				Task.FourfoldMap:UpdateTimeUi(pPlayer, self.UI_TIME_MSG, nStateTime, nRestTime * Env.GAME_FPS);
				return nRestTime * Env.GAME_FPS;
			end
		end
		self.PlayerTempList[pPlayer.nId].nState = 0;
		local nMapId = self.PlayerTempList[pPlayer.nId].nMapId
		local nPosX = self.PlayerTempList[pPlayer.nId].nPosX
		local nPosY = self.PlayerTempList[pPlayer.nId].nPosY
		self.TimerList[pPlayer.nId] = nil;
		pPlayer.NewWorld(nMapId, nPosX, nPosY);
	end
	return 0;
end

--开启界面
function Fourfold:OpenSingleUi(pPlayer, szMsg, nMapFrameTime, nLastFrameTime)
	Dialog:SetBattleTimer(pPlayer,  szMsg, nMapFrameTime, nLastFrameTime);
	Dialog:ShowBattleMsg(pPlayer,  1,  0); --开启界面
end

--关闭界面
function Fourfold:CloseSingleUi(pPlayer)
	Dialog:ShowBattleMsg(pPlayer,  0,  0); -- 关闭界面
end

--更新界面时间
function Fourfold:UpdateTimeUi(pPlayer, szMsg, nMapFrameTime, nLastFrameTime)
	Dialog:SetBattleTimer(pPlayer,  szMsg, nMapFrameTime, nLastFrameTime);
end

--更新界面信息
function Fourfold:UpdateMsgUi(pPlayer, szMsg)
	Dialog:SendBattleMsg(pPlayer, szMsg);
end

function Fourfold:AddTimeTemp(nSec)
	if me.nLevel < self.LIMIT_LEVEL then
		return 0;
	end
	self:UpdateInMap(nSec);
end


function Fourfold:UpdateInMap(nSec)
	local nRemainTime = me.GetTask(self.TSK_GROUP, self.TSK_REMAIN_TIME);
	if self.TimerList[me.nId] and self.PlayerTempList[me.nId] and self.MissionList[self.PlayerTempList[me.nId].nCaptain] then
		 if self.MissionList[self.PlayerTempList[me.nId].nCaptain]:GetGameState() == 2 then
		 	local nStateTime = self.MissionList[self.PlayerTempList[me.nId].nCaptain]:GetStateLastTime();
			local nWaitTime = Timer:GetWaitTime(self.TimerList[me.nId]);
			local nRestTime = math.floor((nWaitTime - Timer:GetRestTime(self.TimerList[me.nId])) / Env.GAME_FPS);
			Timer:Close(self.TimerList[me.nId]);
			nRemainTime = nRemainTime - nRestTime + nSec;
			if nRemainTime > self.DEF_MAX_TIME then
				nRemainTime = self.DEF_MAX_TIME;
			end
			me.SetTask(self.TSK_GROUP, self.TSK_REMAIN_TIME, nRemainTime);
			self.TimerList[me.nId] = Timer:Register(nRemainTime * Env.GAME_FPS, self.TimeStart,  self, me.nId, nRemainTime, 1);
		 	self:UpdateTimeUi(me, self.UI_TIME_MSG, nStateTime, nRemainTime * Env.GAME_FPS);
			return
		end
	end
	nRemainTime = nRemainTime + nSec;
	if nRemainTime > self.DEF_MAX_TIME then
		nRemainTime = self.DEF_MAX_TIME;
	end
	me.SetTask(self.TSK_GROUP, self.TSK_REMAIN_TIME, nRemainTime);
end

--累加时间
function Fourfold:AddTaskTime(nDay)
	if me.nLevel < self.LIMIT_LEVEL or nDay <= 0  then
		return 0;
	end
	local nSec = nDay * self.DEF_PRE_TIME;
	self:UpdateInMap(nSec);
end

--加载npc坐标
function Fourfold:LoadNpcPosFile()
	local tbFile = Lib:LoadTabFile("\\setting\\task\\fourfoldmap\\npc_area.txt");
	if not tbFile then
		return 0;
	end
	self.NpcPosList = {};
	for _, tbPos in pairs(tbFile) do
		local nPosX = tonumber(tbPos.TRAPX) or 0;
		local nPosY = tonumber(tbPos.TRAPY) or 0;
		table.insert(self.NpcPosList, {math.floor(nPosX/32), math.floor(nPosY/32)});
	end
end

Task.FourfoldMap:LoadNpcPosFile();
PlayerSchemeEvent:RegisterGlobalDailyEvent({Task.FourfoldMap.AddTaskTime, Task.FourfoldMap});
