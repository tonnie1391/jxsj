--副本mission
--sunduoliang
--2008.11.07

Require("\\script\\task\\fourfoldmap\\fourfoldmap_def.lua");

local Mission = Mission:New();
Task.FourfoldMap.Mission = Mission;
Task.FourfoldMap.__debug_hour_factor = 1;--60*2;

--新加： 兔子NPC 
local tbRabbitNpc = Task.FourfoldMap.RabbitNpc or {};
Task.FourfoldMap.RabbitNpc = tbRabbitNpc;
tbRabbitNpc.TEMPLATEID     =  3707;  --兔子的模板ID
tbRabbitNpc.MAXNUMBER      =  12;   --兔子的最大数目
tbRabbitNpc.POSITION       = {nX = 1609 , nY = 3182}; -- 刷新点
tbRabbitNpc.TIME           = 2*60;              -- 刷新时间
tbRabbitNpc.DATE_START	   = 20090928;
tbRabbitNpc.DATE_END	   = 20091011;


-- 当玩家加入Mission“后”被调用
function Mission:OnJoin(nGroupId)
	local nStateTime = self:GetStateLastTime();
	
	if self:GetGameState() == 1 then
		Task.FourfoldMap:OpenSingleUi(me, Task.FourfoldMap.UI_READYTIME_MSG, nStateTime);
	elseif self:GetGameState() == 2 then
		if Task.FourfoldMap.TimerList[me.nId] then
			Timer:Close(Task.FourfoldMap.TimerList[me.nId]);
		end
		local nRemainTime = me.GetTask(Task.FourfoldMap.TSK_GROUP, Task.FourfoldMap.TSK_REMAIN_TIME);
		Task.FourfoldMap.TimerList[me.nId] = Timer:Register(nRemainTime * Env.GAME_FPS, Task.FourfoldMap.TimeStart,  Task.FourfoldMap, me.nId, nRemainTime, 1);
		local nRemainFrameTime = Timer:GetRestTime(Task.FourfoldMap.TimerList[me.nId]);
		Task.FourfoldMap:OpenSingleUi(me, Task.FourfoldMap.UI_TIME_MSG, nStateTime, nRemainFrameTime);
	end

	local nRes, nHour = self:GetFourfold(me.nId);
	if nRes == 1 then
		self.tbFourfoldPlayerHasJoin[me.nId] = 1;
		self:CreateTimer((nHour*3600 + Task.FourfoldMap.TIME_GET_READY*60)*Env.GAME_FPS, self.QuitFourfold, self, me.nId);
	end
	
	local szMsg = Task.FourfoldMap.UI_STAIC_MSG;
	if self:GetFourfold(me.nId) == 1 then
		szMsg = szMsg .. "\n\n<color=yellow>Có Bản đồ Bí Cảnh (kinh nghiệm tăng 2 lần)<color>";
	elseif self:IsOnceInFourfold(me.nId) == 1 then
		szMsg = szMsg .. "\n\n<color=orange>Kinh nghiệm tăng 4 lần, 2 lần kinh nghiệm tu luyện<color>";
	else
		szMsg = szMsg .. "\n\n<color=red>Không có Bản đồ Bí Cảnh<color>";
	end
	Task.FourfoldMap:UpdateMsgUi(me, szMsg);
end;

-- 当玩家离开Mission“后”被调用
function Mission:OnLeave(nGroupId, szReason)
	Task.FourfoldMap:CloseSingleUi(me)
	self.tbOffLinePlayer[me.nId]	= nil;
end;


function Mission:GetGameState()
	return self.nStateJour;
end

function Mission:JoinFourfold(nPlayerId, nHour)
	self.tbFourfoldPlayer[nPlayerId] = 1;
	self.tbFourfoldPlayerTime[nPlayerId] = nHour / Task.FourfoldMap.__debug_hour_factor;
end

function Mission:QuitFourfold(nPlayerId)
	self.tbFourfoldPlayer[nPlayerId] = nil;
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.RemoveSkillState(890);
		local szMsg = Task.FourfoldMap.UI_STAIC_MSG;
		szMsg = szMsg .. "\n\n<color=orange>Kinh nghiệm tăng 4 lần, 2 lần kinh nghiệm tu luyện<color>";
		Task.FourfoldMap:UpdateMsgUi(pPlayer, szMsg);
	end
end

function Mission:GetFourfold(nPlayerId)
	if not self.tbFourfoldPlayer[nPlayerId] then
		return 0;
	end
	return 1, self.tbFourfoldPlayerTime[nPlayerId];
end

function Mission:IsOnceInFourfold(nPlayerId)
	if self.tbFourfoldPlayerHasJoin[nPlayerId] then
		return 1;
	else
		return 0;
	end
end

function Mission:GetHour()
	return self.nHour;
end

function Mission:GetStartTime()
	return self.nStartTime;
end

-- 开启活动
function Mission:StartGame(nPlayerId, nMapId, nLevel, nHour)
	-- 设定可选配置项
	self.nHour = nHour -- 秘境开多久（队长决定）
	self.nStartTime = GetTime(); -- 开启时间
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local tbLeavePos = nil;
	if pPlayer then
		local nLeaveMapId, nLeavePosX, nLeavePosY = pPlayer.GetWorldPos();
		tbLeavePos = {nLeaveMapId, nLeavePosX, nLeavePosY};
	end
	self.tbMisCfg	= {
		nFightState	= 1,						-- 战斗状态
		tbLeavePos = tbLeavePos;
	}
	self.nCaptainId = nPlayerId;
	self.tbFourfoldPlayer = {[nPlayerId]=1};
	self.tbFourfoldPlayerTime = {[nPlayerId] = nHour / Task.FourfoldMap.__debug_hour_factor}; -- 玩家用的是几小时地图
	self.tbFourfoldPlayerHasJoin = {[nPlayerId]=1}; -- 玩家使用过地图
	self.nMapId = nMapId;
	self.nLevel = (math.floor((nLevel-1)/10) * 10 + 5);
	if nLevel > 115 then
		self.nLevel = 115;
	end
	self.tbGroups	= {};
	self.tbPlayers	= {};
	self.tbTimers	= {};
	self.tbOffLinePlayer = {};
	self.nStateJour = 0;
	self.tbNowStateTimer = nil;
	self.tbMisEventList	= 	--mission时间表
	{
		{"StartEvent", Env.GAME_FPS * 60 * Task.FourfoldMap.TIME_GET_READY, "OnStartGame"},
		{"EndEvent", Env.GAME_FPS * 60 * nHour / Task.FourfoldMap.__debug_hour_factor, "EndGame"},
	};
	
	--清怪
	ResetMapNpc(nMapId);
	self:GoNextState()	-- 开始报名	

end

function Mission:OffLinePro(nTime)
	if self:IsOpen() ~= 1 or self:GetGameState() <= 0 or self:GetGameState() > 2 then
		return 0
	end
	local tbFold = self.tbFourfoldPlayer;
	--寻找带图的队员
	local szMsg = Task.FourfoldMap.UI_STAIC_MSG;
	szMsg = szMsg .. "\n\n<color=yellow>Có Bản đồ Bí Cảnh (kinh nghiệm tăng 2 lần)<color>";
	for _, pPlayer in pairs(self:GetPlayerList()) do
		if (self:GetFourfold(pPlayer.nId) == 1) then
			local nNowState = Player.tbOffline:AddSpecialExp(pPlayer, nTime);
			
			local nOldState	= self.tbOffLinePlayer[pPlayer.nId];
			--处理右边的信息显示
			if (nNowState ~= nOldState) then
				local szMsg2 = "";
				if (nNowState == 2) then
					szMsg2 = szMsg .. "\n\n<color=red>Thời gian nhận kinh nghiệm offline không đủ, tích lũy để có được kinh nghiệm khi tu luyện trong Bí Cảnh.<color>";
					Task.FourfoldMap:UpdateMsgUi(pPlayer, szMsg2);
				elseif (nNowState == 3) then
					szMsg2 = szMsg.."\n\n<color=red>Thời gian nhận kinh nghiệm offline đã hết.<color>";
					Task.FourfoldMap:UpdateMsgUi(pPlayer, szMsg2);
				else
					Task.FourfoldMap:UpdateMsgUi(pPlayer, szMsg);
				end
				self.tbOffLinePlayer[pPlayer.nId] = nNowState;
			end
		end
	end
end

function Mission:OnStartGame()
	local nStateTime = self.tbMisEventList[2][2];
	for _, pPlayer in pairs(self:GetPlayerList()) do
		if not Task.FourfoldMap.TimerList[pPlayer.nId] then
			local nRemainTime = pPlayer.GetTask(Task.FourfoldMap.TSK_GROUP, Task.FourfoldMap.TSK_REMAIN_TIME);
			Task.FourfoldMap.TimerList[pPlayer.nId] = Timer:Register(nRemainTime * Env.GAME_FPS, Task.FourfoldMap.TimeStart,  Task.FourfoldMap, pPlayer.nId, nRemainTime, 1);
		end
		
		local nRemainFrameTime = Timer:GetRestTime(Task.FourfoldMap.TimerList[pPlayer.nId]);
		Task.FourfoldMap:UpdateTimeUi(pPlayer, Task.FourfoldMap.UI_TIME_MSG, nStateTime, nRemainFrameTime);
	end
	--召怪
	Task.FourfoldMap:CallNpc(self.nMapId, self.nLevel);
	
	local nTime = 5;
	self:CreateTimer(nTime * Env.GAME_FPS, self.OffLinePro, self, nTime);
	
	--新加： 生成兔子计时器
	local tbRabbitID = {};
	self:CreateTimer(tbRabbitNpc.TIME * Env.GAME_FPS, self.CallRabbitNpc, self, tbRabbitID, self.nMapId);
	
	--额外事件，活动系统
	SpecialEvent.ExtendEvent:DoExecute("Open_FourfoldMap", self.nLevel, self.nMapId);

end

function Mission:EndGame()
	ResetMapNpc(self.nMapId);
	for _, pPlayer in pairs(self:GetPlayerList()) do
		local nRestTime = 0;
		if Task.FourfoldMap.TimerList[pPlayer.nId] then
			local nWaitTime = Timer:GetWaitTime(Task.FourfoldMap.TimerList[pPlayer.nId]);
			nRestTime = math.floor((nWaitTime - Timer:GetRestTime(Task.FourfoldMap.TimerList[pPlayer.nId])) / Env.GAME_FPS);
			Timer:Close(Task.FourfoldMap.TimerList[pPlayer.nId]);
		end
		Task.FourfoldMap:TimeStart(pPlayer.nId, nRestTime, 2);
	end
	--清怪
	
	Task.FourfoldMap.MapTempletList.tbMapList[self.nMapId] = 0;
	Task.FourfoldMap.MapTempletList.nCount = Task.FourfoldMap.MapTempletList.nCount - 1;
	GCExcute({"Task.FourfoldMap:Release_GC", self.nCaptainId, 1, self.nLevel});
	--Task.FourfoldMap.MissionList[self.nCaptainId] = nil;
	self:Close();
	return 0;
end

--新加
function Mission:CallRabbitNpc(tbRabbitID, nMapId)
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate < tbRabbitNpc.DATE_START or nCurDate >= tbRabbitNpc.DATE_END then
		return
	end
    local nCount = 0;
	for nNpcId in pairs(tbRabbitID) do
		local pRabbit = KNpc.GetById(nNpcId);
		if pRabbit and pRabbit.GetTempTable("Npc").tbRabbitAbout and pRabbit.GetTempTable("Npc").tbRabbitAbout.bIsCatch == 0 then
			nCount = nCount + 1;
		else
			tbRabbitID[nNpcId] = nil;
		end
	end
	if nCount >= tbRabbitNpc.MAXNUMBER then
		return;
	end
	local nAddNum = math.floor(MathRandom(1, 4));
	if	 (nCount + nAddNum) >= tbRabbitNpc.MAXNUMBER then
		nAddNum = tbRabbitNpc.MAXNUMBER - nCount;
	end
	for i = 1 , nAddNum do 
	   	local nNpcId = SpecialEvent.CollectCard.CallAiRabbit:CallRabbit(nMapId, tbRabbitNpc.POSITION.nX * 32 ,tbRabbitNpc.POSITION.nY * 32, tbRabbitNpc.TEMPLATEID);
	    if nNpcId ~= 0 then
 	    	tbRabbitID[nNpcId] = 1;
 	    end
 	end 
end
