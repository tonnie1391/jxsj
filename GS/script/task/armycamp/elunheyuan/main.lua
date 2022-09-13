
Require("\\script\\task\\armycamp\\campinstancing\\instancingmanager.lua");

local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancingBase(4); -- 4为此FB的Id
tbInstancing.tbSoldierSay = 
{
	"那达慕大会的比赛可不只是比武。",
	"请由此进入那达慕大会会场。",
	"在那达慕上取得好成绩，大汗也许会赏识你。",
	"看你的样子也不是很勇猛么。",
};
tbInstancing.szName = "鄂伦河原";
tbInstancing.szDesc = "备战，为了之后的胜利";
tbInstancing.nReviveTimesInHuntingGround = 3;-- 第三关可复活3次
tbInstancing.tbResetFunc = 
{
	[1] = "ResetBiwuchang",
	[2] = "ResetMachang",
	[3] = "ResetHuntingGround",
	[4] = "ResetAltar",
	[5] = "ResetJiaochang",
	[6] = "ResetKehandazhang",
	[7] = "ResetXiakeBoss",
};
tbInstancing.tbTrapNpcPosList = 
{
	[1] = {
		-- 障碍名字，什么状态存在，障碍点
		["biwuchang2machang"] = {tbAddState = {0, 1}, tbPosList = {{1739,3574},{1742,3572},{1744,3570}}},
		["houying2biwuchang"] = {tbAddState = {0}, tbPosList = {{1743,3531},{1744,3533},{1747,3535}}},
		},
	[2] = {
		["machangrukou"] = {tbAddState = {0, 1}, tbPosList = {{1761,3595},{1762,3594},{1764,3591}}},
		},
	[3] = {
		["shouliechangrukou"] = {tbAddState = {0}, tbPosList = {{1802,3576}, {1804,3578}, {1805,3580}}},
		},
	[4] = {
		["jishichang_enter"] = {tbAddState = {0}, tbPosList = {{1742,3407}, {1744,3405}, {1710,3405}, {1712,3406}, {1710,3376}, {1711,3374}, {1741,3374}, {1743,3376}}},
		["jishichang2jiaochang"] = {tbAddState = {0, 1}, tbPosList = {{1689,3359}, {1691,3356}, {1693, 3355}}},
		},
	[5] = {
		["jiaochang_enter"] = {tbAddState = {0}, tbPosList = {{1674,3341}, {1675,3339}, {1677, 3337}}},
		["jiaochang2dazhang"] = {tbAddState = {0, 1}, tbPosList = {{1670,3289}, {1672,3290}, {1674,3293}}},
		},
	[6] = {
		["dazhang_enter"] = {tbAddState = {0, 1}, tbPosList = {{1705,3242}, {1707,3243}, {1709,3245}}},
		},
	[7] = {
		["dazhang_enter2"] = {tbAddState = {0}, tbPosList = {{1705,3242}, {1707,3243}, {1709,3245}}},
		},
};

-- 开启FB的时候调用，用于一些初始化
function tbInstancing:OnOpen()
	Map:RegisterMapForbidReviveType(self.nMapId, 0, 0, "当前地图禁止原地复活和技能复活");
	Map:RegisterMapForbidRemoteRevive(self.nMapId, 0, "当前地图暂时禁止回城疗伤");
	-- 开启FB计时器
	self.nNoPlayerDuration = 0;
	self.nBreathTimerId = Timer:Register(Env.GAME_FPS, self.OnBreath, self);
	self.nCloseTimerId 	= Timer:Register(self.tbSetting.nInstancingExistTime*Env.GAME_FPS, self.OnClose, self);
	-- 门口喊话牧民
	local pNpc = KNpc.Add2(9980, 110, -1, self.nMapId, 1778, 3482);
	if pNpc then
		self.nHouyingMuming = pNpc.dwId;
	end
	self.tbTrapNpcList = {}; -- trap的表现NPC	
	self.tbPlayerList = {}; -- 当前Player列表
	self.tbEnteredPlayerList = {}; -- 曾经进过的Player列表
	self.tbAttendPlayerList = {};	-- 当前副本关卡参战玩家
	self.tbTollgateReset = {};	-- 关卡是否复位,0:正在游戏中需要复位,1:已经复位，2：已经过关 
	self.szOpenTime = GetLocalDate("%Y-%m-%d %H:%M:%S");
	
	
	for _, szFunc in ipairs(self.tbResetFunc) do
		self[szFunc](self);
	end
	self.tbMachang.nFirstChallenge = 1;	-- 第二关只有在第一次挑战的时候才会刷出马王
	self.tbHuntingGround.nFirstChallenge = 1;-- 第三关只有在第一次挑战的时候才可以领取额外奖励
	self.szOpenTime = GetLocalDate("%Y-%m-%d %H:%M:%S");
end


function tbInstancing:OnBreath()
	if (self.nPlayerCount == 0) then
		self.nNoPlayerDuration = self.nNoPlayerDuration + 1;
	elseif (nNoPlayerDuration ~= 0) then
		self.nNoPlayerDuration = 0;
	end
	
	if (self.nNoPlayerDuration >= self.tbSetting.nNoPlayerDuration) then
		self:OnClose();
		return 0;
	end
	
	if (not self.nCurSec) then
		self.nCurSec = 1;
	else
		self.nCurSec = self.nCurSec + 1;
	end
	if (self.nCurSec % 5 == 0) then
		local nRand = MathRandom(#self.tbSoldierSay);
		self:NpcTimerSay(self.nHouyingMuming, self.tbSoldierSay[nRand]);
		-- 关卡各种状态npc说的各种话
		self:NpcTimerSayWithCondition(self.tbBiwuchangInfo.nDlgMengguyongshi1, self.tbTollgateReset[1], nil, "你们的第一个对手是我！放马过来吧！", "往前走会有更多有趣的再等着你。");
	end
	if (self.nCurSec % 600 == 0) then
		Task.tbArmyCampInstancingManager:Tip2MapPlayer(self.nMapId, "Thời gian đóng "..self.tbSetting.szName.." còn lại "..math.floor((self.tbSetting.nInstancingExistTime-self.nCurSec)/60).." phút");
	end
end

-- NPC按条件说话
function tbInstancing:NpcTimerSayWithCondition(nNpcId, nCondition, szMsg1, szMsg2, szMsg3)
	if (nNpcId) then
		local pNpc = KNpc.GetById(nNpcId);
		if not pNpc then
			return
		end
		if (nCondition == 0 and szMsg1) then
			pNpc.SendChat(szMsg1);
		elseif (nCondition == 1 and szMsg2) then
			pNpc.SendChat(szMsg2);
		elseif (nCondition == 2 and szMsg3) then
			pNpc.SendChat(szMsg3);
		end
	end
end

-- NPC说一句话
function tbInstancing:NpcTimerSay(nNpcId, szMsg)
	if (nNpcId) then
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.SendChat(szMsg);
		end
	end
end

-- npc说话，右下角文字提示
function tbInstancing:NpcSay(nNpcId, szMsg)
	if not nNpcId or not szMsg then
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		self:SendPrompt(string.format("<color=yellow>%s:<color><color=white>%s<color>", pNpc.szName, szMsg), 0, 0, 1, 0);
	end
end

-- FB关闭时调用
function tbInstancing:OnClose()
	for nPlayerId, tbPlayerData in pairs(self.tbPlayerList) do
		self:KickPlayer(nPlayerId, 1, "副本时间结束，你被传出了副本【鄂伦河原】");
	end
	
	Task.tbArmyCampInstancingManager:CloseMap(self.nMapId);
	Timer:Close(self.nBreathTimerId);
	Timer:Close(self.nCloseTimerId);

	if (self.nBzhjTimerId and self.nBzhjTimerId > 0) then
		Timer:Close(self.nBzhjTimerId);
		self.nBzhjTimerId = nil;
	end
	self:CloseTollgateTimer();
	self:ClearAllTollgateTable();
	ClearMapNpc(self.nMapId, 0);
	return 0;
end


-- 当一个玩家申请进入
function tbInstancing:OnPlayerAskEnter(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (self.nPlayerCount >= self.tbSetting.nMaxPlayer) then
		Dialog:SendInfoBoardMsg(pPlayer, "副本人数已满，你暂时无法进入。");
		return;
	end
	--加载任务
	if self.tbSetting.tbHaveTask and #self.tbSetting.tbHaveTask > 0 then
		local nHaveTask = 0;
		for _, nTaskId in ipairs(self.tbSetting.tbHaveTask) do
			if (Task:HaveTask(pPlayer, nTaskId) == 1) then
				nHaveTask = 1;
				break;
			end
		end
		if nHaveTask == 0 then
			if (pPlayer.GetTask(self.tbSetting.nJuQingTaskLimit_W.nTaskGroup, self.tbSetting.nJuQingTaskLimit_W.nTaskId) < self.tbSetting.nJuQingTaskLimit_W.nLimitValue) then
				local tbResult = Task:DoAccept(self.tbSetting.tbJuqingTask.nTaskId, self.tbSetting.tbJuqingTask.nReferId);
				if not tbResult then
					Dbg:WriteLog("armycamp", "accept haiwang juqing failure");
				end
			elseif (pPlayer.GetTask(self.tbSetting.nDailyTaskLimit_W.nTaskGroup, self.tbSetting.nDailyTaskLimit_W.nTaskId) < self.tbSetting.nDailyTaskLimit_W.nLimitValue) then
				local tbResult = Task:DoAccept(self.tbSetting.tbRichangTask.nTaskId, self.tbSetting.tbRichangTask.nReferId);
				if not tbResult then
					Dbg:WriteLog("armycamp", "accept haiwang richang failure");
				end
			else
				Dbg:WriteLog("armycamp", "accept haiwang failure");
			end
		end
	end
	pPlayer.NewWorld(self.nMapId, unpack(self.tbSetting.tbRevivePos));
	pPlayer.SetFightState(0);
	self:OnPlayerEnter(pPlayer.nId);
	
	-- 成就，参加鄂伦河原
	Achievement:FinishAchievement(pPlayer, 480);
end

-- 当一个玩家进入后
function tbInstancing:OnPlayerEnter(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	assert(pPlayer);
	self.nPlayerCount = self.nPlayerCount + 1;
	assert(self.nPlayerCount <= self.tbSetting.nMaxPlayer);
	-- 第一次进入当前副本
	if (not self.tbEnteredPlayerList[nPlayerId]) then
		--local nTimes = pPlayer.GetTask(self.tbSetting.nInstancingEnterLimit_D.nTaskGroup, self.tbSetting.nInstancingEnterLimit_D.nTaskId);
		--pPlayer.SetTask(self.tbSetting.nInstancingEnterLimit_D.nTaskGroup, self.tbSetting.nInstancingEnterLimit_D.nTaskId, nTimes + 1, 1);
		local nTimes = pPlayer.GetTask(self.tbSetting.nInstancingRemainEnterTimes.nTaskGroup, self.tbSetting.nInstancingRemainEnterTimes.nTaskId);
		pPlayer.SetTask(self.tbSetting.nInstancingRemainEnterTimes.nTaskGroup, self.tbSetting.nInstancingRemainEnterTimes.nTaskId, nTimes - 1, 1);
		self.tbEnteredPlayerList[nPlayerId] = 1;
		self:ResetPlayerAttr(nPlayerId);
		
		--参加军营累积次数
		local nTimes = pPlayer.GetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_JOIN_ARMY);
		pPlayer.SetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_JOIN_ARMY, nTimes + 1);
			
		-- 记录玩家参加军营副本的次数
		Stats.Activity:AddCount(pPlayer, Stats.TASK_COUNT_ARMYCAMP, 1);
	end
	
	self.tbPlayerList[nPlayerId] = {};
	
	-- 对此玩家注册一些事件
	Setting:SetGlobalObj(pPlayer, him, it);
	local nDeathEventId = PlayerEvent:Register("OnDeath", self.OnPlayerDeath, self);
	self.tbPlayerList[nPlayerId].nDeathEventId = nDeathEventId;
	local nLogoutEventId = PlayerEvent:Register("OnLogout", self.OnPlayerLogout, self);
	self.tbPlayerList[nPlayerId].nLogoutEventId = nLogoutEventId;
	local nLeaveMapEventId = PlayerEvent:Register("OnLeaveMap", self.OnPlayerLeaveMap, self);
	self.tbPlayerList[nPlayerId].nLeaveMapEventId = nLeaveMapEventId;
	Setting:RestoreGlobalObj();
	local nRevMapId, nRevPointId = pPlayer.GetRevivePos();
	self.tbPlayerList[nPlayerId].tbOldRev = {nRevMapId, nRevPointId};
	pPlayer.SetTmpDeathPos(self.nMapId, unpack(self.tbSetting.tbRevivePos));
	pPlayer.SetLogoutRV(1);
	--Setting:SetGlobalObj(pPlayer);
	--TaskAct:Talk("我们奉命前来调查蒙军在此突然大规模集结的缘由。草原人粗犷热情，我们想要混入其中应该不难。现在正当蒙人举行那达慕大会，我们不妨前去尝试一番，以期居于前茅，或者会有深入蒙军探查的机会。");
	--Setting:RestoreGlobalObj();
	
	Task.tbArmyCampInstancingManager:ShowTip(pPlayer, "Đội của "..self.szOpenerName.." tại "..self.szRegisterMapName.." đã mở "..self.tbSetting.szName .. ".", 20);

	-- Task.tbArmyCampInstancingManager:ShowTip(pPlayer, "想要深入蒙军内部打探消息，必须先通过那达慕大会的考验！", 20);
	-- pPlayer.Msg("想要深入蒙军内部打探消息，必须先通过那达慕大会的考验！");
	-- 计时面板
	if (not self.nCurSec) then -- 在报名的一秒钟以内进入副本，self.nCurSec还没经过OnBreath生成，为nil 则在此处生成
		self.nCurSec = 0;
	end;
	Dialog:SetTimerPanel(pPlayer, "<color=Gold>Phó bản Quân Doanh<color>\n<color=White>Thời gian kết thúc phó bản: <color>", (self.tbSetting.nInstancingExistTime-self.nCurSec));

	Task.tbArmyCampInstancingManager.StatLog:WriteLog(1, 1, pPlayer);
	
	--Task.tbArmyCampInstancingManager:OpenArmyCampUi(pPlayer.nId, self.nCloseTimerId);
end

-- 踢出一个玩家
function tbInstancing:KickPlayer(nPlayerId, bPassive, szDesc)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	if (not self.tbPlayerList[nPlayerId]) then
		return;
	end
	
	Dialog:CloseTimerPanel(pPlayer);
	
	self.nPlayerCount = self.nPlayerCount -1;
	assert(self.nPlayerCount >= 0);
	assert(self.tbPlayerList[nPlayerId] and self.tbPlayerList[nPlayerId].nDeathEventId and self.tbPlayerList[nPlayerId].nLogoutEventId and self.tbPlayerList[nPlayerId].nLeaveMapEventId);
	Setting:SetGlobalObj(pPlayer, him, it);
	PlayerEvent:UnRegister("OnDeath", self.tbPlayerList[nPlayerId].nDeathEventId);
	PlayerEvent:UnRegister("OnLogout", self.tbPlayerList[nPlayerId].nLogoutEventId);
	PlayerEvent:UnRegister("OnLeaveMap", self.tbPlayerList[nPlayerId].nLeaveMapEventId);
	Setting:RestoreGlobalObj();
	pPlayer.SetRevivePos(unpack(self.tbPlayerList[nPlayerId].tbOldRev));
	self.tbPlayerList[nPlayerId] = nil;
	if (pPlayer.IsDead() == 1) then
		pPlayer.ReviveImmediately(0);
	end
	
	-- 删除指定道具
	
	
	--Task.tbArmyCampInstancingManager:CloseArmyCampUi(pPlayer.nId);
	if (bPassive) then
		local nMapId, nReviveId, nMapX, nMapY = pPlayer.GetLoginRevivePos();
		pPlayer.NewWorld(nMapId, nMapX/32, nMapY / 32);
	end
	
	pPlayer.SetLogoutRV(0);
	
	if (szDesc) then
		Task.tbArmyCampInstancingManager:Warring(pPlayer, szDesc);
	end
	-- 玩家离开副本将玩家从参战列表移除
	self.tbAttendPlayerList[nPlayerId] = nil;
	self:RestartTollgate();
	if pPlayer.GetSkillState(2588) > 0 then
		pPlayer.RemoveSkillState(2588);
		Setting:SetGlobalObj(pPlayer);
		Player:RestoryShotCut(self.tbMachang.tbPlayerShotSkill or {});	
		Setting:RestoreGlobalObj();
	end
	
	--木华黎释放的鹰扬需要清除，玩家离开后会持续拥有，导致玩家攻击无效
	if pPlayer.GetSkillState(2514) > 0 then
		pPlayer.RemoveSkillState(2514);
	end
	
	Dialog:ShowBattleMsg(pPlayer, 0, 0);
end

function tbInstancing:RemoveTaskItem(pPlayer, tbItemId)	
	local nDelCount = Task:GetItemCount(me, tbItemId);
	
	Task:DelItem(me, tbItemId, nDelCount);
end

-- 当玩家下线时候调用
function tbInstancing:OnPlayerLogout()
	self:KickPlayer(me.nId, 1);
end

-- 玩家死亡后调用
function tbInstancing:OnPlayerDeath()
	--me.ReviveImmediately(0);
	--me.SetFightState(0);
	me.CallClientScript({"UiManager:CloseWindow","UI_RENASCENCEPANEL"});	--关闭复活界面
	if self.tbTollgateReset[3] == 0 then
		-- 猎场有3次复活机会
		if self:ReviveInHuntingGround(me.nId) == 1 then
			return;
		end
	end
	self.tbAttendPlayerList[me.nId] = 0;
	self:RestartTollgate();
end

-- 检查是否还有玩家在关卡中
function tbInstancing:CheckTollgateOver()
	for nPlayerId, nFlag in pairs(self.tbAttendPlayerList)	do
		if nFlag == 1 then
			return 0;
		end 
	end
	return 1;
end

-- 参战玩家全部死亡了或者不在关卡中了则将参赛玩家传送回复活点，并重新初始化关卡
function tbInstancing:RestartTollgate()
	local nAllDeath = 1;
	for nPlayerId, nFlag in pairs(self.tbAttendPlayerList) do
		if nFlag == 1 then
			nAllDeath = 0;
			break;
		end
	end
	if nAllDeath == 1 then
		for nPlayerId, nFlag in pairs(self.tbAttendPlayerList) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				if (pPlayer.IsDead() == 1) then
					pPlayer.ReviveImmediately(0);
				end
				pPlayer.SetFightState(0);
				Dialog:ShowBattleMsg(pPlayer, 0, 0);
				Task.tbArmyCampInstancingManager:ShowTip(pPlayer, "Có thể cưỡi ngựa đến khu khiêu chiến tiếp theo", 20);
			end
			self.tbAttendPlayerList[nPlayerId] = nil;
		end
		-- 初始化当前失败的关卡
		for nIndex, nFlag in ipairs(self.tbTollgateReset) do
			if nFlag == 0 then
				self[self.tbResetFunc[nIndex]](self);
				break;
			end
		end
	end
end

-- 玩家离开地图时调用
function tbInstancing:OnPlayerLeaveMap()
	self:KickPlayer(me.nId);
end

-- 重置玩家FB相关的属性
function tbInstancing:ResetPlayerAttr(nPlayerId)
	
end


-- 初始化第一关
function tbInstancing:ResetBiwuchang()
	if self.tbBiwuchangInfo then
		-- 清除已经有的状态
		self:DeleteNpc(self.tbBiwuchangInfo.nDlgMengguyongshi1);
		self:DeleteNpc(self.tbBiwuchangInfo.nDlgMengguyongshi2);
		self:DeleteNpc(self.tbBiwuchangInfo.nDlgMengguyongshi3_1);
		self:DeleteNpc(self.tbBiwuchangInfo.nDlgMengguyongshi3_2);
		self:DeleteNpc(self.tbBiwuchangInfo.nFightMengguyongshi1);
		self:DeleteNpc(self.tbBiwuchangInfo.nFightMengguyongshi2);
		self:DeleteNpc(self.tbBiwuchangInfo.nFightMengguyongshi3_1);
		self:DeleteNpc(self.tbBiwuchangInfo.nFightMengguyongshi3_2);
		if self.tbBiwuchangInfo.tbNpcWoodId and #self.tbBiwuchangInfo.tbNpcWoodId > 0 then
			for _, nNpcId in ipairs(self.tbBiwuchangInfo.tbNpcWoodId) do
				self:DeleteNpc(nNpcId);
			end
		end
		if self.tbBiwuchangInfo.tbNpcQuanzhongId and #self.tbBiwuchangInfo.tbNpcQuanzhongId then
			for nNpcId, _ in pairs(self.tbBiwuchangInfo.tbNpcQuanzhongId) do
				self:DeleteNpc(nNpcId);
			end
		end
	else
		self.tbBiwuchangInfo = {};
	end
	-- 添加对话蒙古勇士
	local pDlgNpc1 = KNpc.Add2(9938, 110, -1, self.nMapId, 54848/32, 113152/32);
	if pDlgNpc1 then
		self.tbBiwuchangInfo.nDlgMengguyongshi1 = pDlgNpc1.dwId;
	else
		self.tbBiwuchangInfo.nDlgMengguyongshi1 = 0;
		Dbg:WriteLog("elunheyuan add mengguyongshi_dlg1 failure");
	end
	local pDlgNpc2 = KNpc.Add2(9939, 110, -1, self.nMapId, 54784/32, 113248/32);
	if pDlgNpc2 then
		self.tbBiwuchangInfo.nDlgMengguyongshi2	= pDlgNpc2.dwId;
	else
		self.tbBiwuchangInfo.nDlgMengguyongshi2 = 0;
		Dbg:WriteLog("elunheyuan add mengguyongshi_dlg2 failure");
	end
	local pDlgNpc3_1 = KNpc.Add2(9940, 110, -1, self.nMapId, 54624/32, 113408/32);
	if pDlgNpc3_1 then
		self.tbBiwuchangInfo.nDlgMengguyongshi3_1 = pDlgNpc3_1.dwId;
	else
		self.tbBiwuchangInfo.nDlgMengguyongshi3_1 = 0;
		Dbg:WriteLog("elunheyuan add mengguyongshi_dlg3_1 failure");
	end
	local pDlgNpc3_2 = KNpc.Add2(9941, 110, -1, self.nMapId, 54720/32, 113312/32);
	if pDlgNpc3_2 then
		self.tbBiwuchangInfo.nDlgMengguyongshi3_2 = pDlgNpc3_2.dwId;
	else
		self.tbBiwuchangInfo.nDlgMengguyongshi3_2 = 0;
		Dbg:WriteLog("elunheyuan add mengguyongshi_dlg3_2 failure");
	end
	-- 初始化变量
	self.tbBiwuchangInfo.nFightMengguyongshi1 = 0;	-- 战斗npcId
	self.tbBiwuchangInfo.nFightMengguyongshi2 = 0;
	self.tbBiwuchangInfo.nFightMengguyongshi3_1 = 0;
	self.tbBiwuchangInfo.nFightMengguyongshi3_2 = 0;
	self.tbBiwuchangInfo.tbNpcWoodId = {};
	self.tbBiwuchangInfo.tbPlayerOpenInfo = {};	-- 每轮玩家开始木桩的次数记录
	self.tbBiwuchangInfo.tbNpcQuanzhongId = {};	-- id-type
	self.tbBiwuchangInfo.tbWoodUseInfo = {};	-- 木桩点的使用情况，插入木桩的时候不重复
	self:ChangeTollgateState(1,1);	-- 第一关已经复位
end

-- 删除Npc
function tbInstancing:DeleteNpc(nNpcId)
	if not nNpcId or nNpcId == 0 then
		return;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		pNpc.Delete();
	end
end

-- 初始化第二关：马场
function tbInstancing:ResetMachang()
	if self.tbMachang then
		if self.tbMachang.nTimerId then
			Timer:Close(self.tbMachang.nTimerId);
		end
		if self.tbMachang.nHugeHorseTimerId then
			Timer:Close(self.tbMachang.nHugeHorseTimerId);
		end
		if self.tbMachang.nHorseTimerId then
			Timer:Close(self.tbMachang.nHorseTimerId);
		end
		if self.tbMachang.nSheepTimerId then
			Timer:Close(self.tbMachang.nSheepTimerId);
		end
		if self.tbMachang.tbHorseId and #self.tbMachang.tbHorseId then
			for _, nId in pairs(self.tbMachang.tbHorseId) do
				self:DeleteNpc(nId);
			end
		end
		if self.tbMachang.tbSheepId and #self.tbMachang.tbSheepId then
			for _, nId in pairs(self.tbMachang.tbSheepId) do
				self:DeleteNpc(nId);
			end
		end 
		if self.tbMachang.nNpcManager then
			self:DeleteNpc(self.tbMachang.nNpcManager);
		end
	else
		self.tbMachang = {};
	end
	local pNpcManager = KNpc.Add2(9943, 110, -1, self.nMapId, 56384/32, 114880/32);
	if pNpcManager then
		self.tbMachang.nNpcManager = pNpcManager.dwId;
	else
		self.tbMachang.nNpcManager = nil;
		Dbg:WriteLog("elunheyuan add horsemanager failure");
	end
	self.tbMachang.tbPoint = {};	-- 记录每个人的分数
	self.tbMachang.nTotalPoint = 0;	-- 总分
	self.tbMachang.nTimerId = nil	-- 总计时器
	self.tbMachang.nHugeHorseTimerId = nil;	-- 大波马计时器
	self.tbMachang.nHorseTimerId = nil;	-- 隔固定时间刷一批马
	self.tbMachang.nSheepTimerId = nil;		-- 刷羊计时器
	self.tbMachang.tbHorseId = {};	-- 马
	self.tbMachang.tbSheepId = {};	-- 羊
	self.tbMachang.szPrompt = "";
	self.tbMachang.nFirstChallenge = 0;
	self.tbMachang.tbPlayerShotSkill = {};	-- 记录玩家快捷键
	self:ChangeTollgateState(2,1);
end

function tbInstancing:AddHarnessHorsePoint(nPlayerId, nPoint)
	if not self.tbMachang.tbPoint then
		return 0;
	end
	if not self.tbAttendPlayerList[nPlayerId] then
		return 0;
	end
	self.tbMachang.tbPoint[nPlayerId] = self.tbMachang.tbPoint[nPlayerId] or 0;
	self.tbMachang.tbPoint[nPlayerId] = self.tbMachang.tbPoint[nPlayerId] + nPoint;
	self.tbMachang.nTotalPoint = self.tbMachang.nTotalPoint + nPoint;
	return 1;
end

-- 第三关：狩猎场
function tbInstancing:ResetHuntingGround()
	if self.tbHuntingGround then
		-- 关闭刷新计时器
		if self.tbHuntingGround.tbAddAnimalTimer and #self.tbHuntingGround.tbAddAnimalTimer > 0 then
			for _, nTimerId in pairs(self.tbHuntingGround.tbAddAnimalTimer) do
				Timer:Close(nTimerId);
			end
		end
		if self.tbHuntingGround.nEndTimer then
			Timer:Close(self.tbHuntingGround.nEndTimer);
		end
		-- 删掉动物
		if self.tbHuntingGround.tbAnimalId and #self.tbHuntingGround.tbAnimalId > 0 then
			for _, nNpcId in ipairs(self.tbHuntingGround.tbAnimalId) do
				self:DeleteNpc(nNpcId);
			end
		end
		if self.tbHuntingGround.tbKingAnimalId and #self.tbHuntingGround.tbKingAnimalId > 0 then
			for _, nNpcId in ipairs(self.tbHuntingGround.tbKingAnimalId) do
				self:DeleteNpc(nNpcId);
			end
		end
		self:ClearHuntingGroundState();
	else
		self.tbHuntingGround = {};
	end
	self.tbHuntingGround.nEndTimer = nil;	-- 关卡计时器
	self.tbHuntingGround.tbAddAnimalTimer = {}; -- 动物重生定时器
	self.tbHuntingGround.tbAnimalId = {};	-- 普通动物的ID列表
	self.tbHuntingGround.tbKingAnimalId = {};	-- 各种王的ID列表
	self.tbHuntingGround.tbSpecialAnimalId = {};-- 各种特殊动物的ID列表
	self.tbHuntingGround.tbStateHugeNpcId = {};	-- 大波出来的怪,是index-table（index-id）
	self.tbHuntingGround.nStateDoubleTimerId = nil;	-- 双倍定时器，只有一个，是覆盖的状态
	self.tbHuntingGround.tbStateHugeTimerId = {};	-- 刷大波怪的定时器，是可以叠加的 
	self.tbHuntingGround.tbKingAnimalRrefreshNum = {};	-- 各种王出现的个数
	self.tbHuntingGround.tbAnimalAccumulationNum = {};	-- 各种类型的怪的累积击杀个数
	self.tbHuntingGround.tbPlayerInfo = {};	-- 记录每个玩家击杀动物详情
	self.tbHuntingGround.tbExtraAwardFlag = {}; -- 是否领取了猎人的特殊奖励
	self.tbHuntingGround.nTotalPoint = 0;		-- 总分
	local tbManager = Npc:GetClass("elunheyuan_animalmanager");
	self.tbHuntingGround.nExtraAwardType = MathRandom(#tbManager.tbExtraAward);
	self.tbHuntingGround.nFirstChallenge = 0;
	self.tbHuntingGround.nDoublePointState = 0;	-- 是否是双倍积分中
	self.tbHuntingGround.tbReviveList = {};		-- playerid-revivetimes复活情况
	self:ChangeTollgateState(3,1);
end

-- 尝试复活
function tbInstancing:ReviveInHuntingGround(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	if self.tbAttendPlayerList[nPlayerId] and self.tbHuntingGround.tbReviveList then
		self.tbHuntingGround.tbReviveList[nPlayerId] = self.tbHuntingGround.tbReviveList[nPlayerId] or 0;
		if self.tbHuntingGround.tbReviveList[nPlayerId] < self.nReviveTimesInHuntingGround then
			self.tbHuntingGround.tbReviveList[nPlayerId] = self.tbHuntingGround.tbReviveList[nPlayerId] + 1;
			pPlayer.ReviveImmediately(1);
			local szMsg = Npc:GetClass("elunheyuan_animalmanager"):GetPlayerInfoTxt(self, nPlayerId);
			Dialog:SendBattleMsg(pPlayer, szMsg);
			Dialog:ShowBattleMsg(pPlayer, 1, 0);
			Task.tbArmyCampInstancingManager:ShowTip(pPlayer, "Đã tiêu hao 1 lượt hồi sinh", 10);
			pPlayer.Msg("Đã tiêu hao 1 lượt hồi sinh。");
			return 1;
		else
			local szMsg = Npc:GetClass("elunheyuan_animalmanager"):GetPlayerInfoTxt(self, nPlayerId);
			Dialog:SendBattleMsg(pPlayer, szMsg);
			Dialog:ShowBattleMsg(pPlayer, 1, 0);
		end
	end
	return 0;
end

-- 清除特殊状态
function tbInstancing:ClearHuntingGroundState()
	if self.tbHuntingGround.tbStateHugeTimerId then
		for _, nTimerId in pairs(self.tbHuntingGround.tbStateHugeTimerId) do
			Timer:Close(nTimerId);
		end
		self.tbHuntingGround.tbStateHugeTimerId  = {};
	end
	if self.tbHuntingGround.nStateDoubleTimerId then
		Timer:Close(self.tbHuntingGround.nStateDoubleTimerId);
		self.tbHuntingGround.nStateDoubleTimerId = nil;
	end
	if self.tbHuntingGround.tbSpecialAnimalId and #self.tbHuntingGround.tbSpecialAnimalId > 0 then
		for _, nNpcId in ipairs(self.tbHuntingGround.tbSpecialAnimalId) do
			self:DeleteNpc(nNpcId);
		end
		self.tbHuntingGround.tbSpecialAnimalId = {};
	end
	if self.tbHuntingGround.tbStateHugeNpcId then
		for _, tbNpcListId in pairs(self.tbHuntingGround.tbStateHugeNpcId) do
			if #tbNpcListId > 0 then
				for _, nNpcId in ipairs(tbNpcListId) do
					self:DeleteNpc(nNpcId);
				end
			end
		end
		self.tbHuntingGround.tbStateHugeNpcId = {};
	end
end

-- 第四关：祭祀
function tbInstancing:ResetAltar()
	if self.tbAltar then
		self:DeleteNpc(self.tbAltar.nNpcSaman_Dialog);
		self:DeleteNpc(self.tbAltar.nNpcSaman_Fight);
		if self.tbAltar.tbNpcSamanbingId and #self.tbAltar.tbNpcSamanbingId > 0 then
			for _, nNpcId in pairs(self.tbAltar.tbNpcSamanbingId) do
				self:DeleteNpc(nNpcId);
			end
		end
	else
		self.tbAltar = {};
	end
	local pNpc = KNpc.Add2(9954, 110, -1, self.nMapId, 1727, 3393);
	if pNpc then
		self.tbAltar.nNpcSaman_Dialog = pNpc.dwId;
	else
		self.tbAltar.nNpcSaman_Dialog = nil;
		Dbg:WriteLog("elunheyuan add saman failure");
	end
	self.tbAltar.nNpcSaman_Fight = nil;
	self.tbAltar.tbNpcSamanbingId = {};
	self:ChangeTollgateState(4, 1);
end

-- 第五关-校场
function tbInstancing:ResetJiaochang()
	if self.tbJiaochang then
		self:DeleteNpc(self.tbJiaochang.nNpcMuhuali_Dialog);
		self:DeleteNpc(self.tbJiaochang.nNpcMuhuali_Fight);
		if self.tbJiaochang.tbNpcFlagInfo then
			for nNpcId, _ in pairs(self.tbJiaochang.tbNpcFlagInfo) do
				self:DeleteNpc(nNpcId);
			end
		end
		if self.tbJiaochang.tbNpcSoldierInfo then
			for nNpcId, _ in pairs(self.tbJiaochang.tbNpcSoldierInfo) do
				self:DeleteNpc(nNpcId);
			end
		end
		if self.tbJiaochang.tbNpcChangshengcaoId then
			for _, nNpcId in ipairs(self.tbJiaochang.tbNpcChangshengcaoId) do
				self:DeleteNpc(nNpcId);
			end
		end
	else
		self.tbJiaochang = {};
	end
	local pNpc = KNpc.Add2(9962, 110, -1, self.nMapId, 1636, 3291);
	if pNpc then
		self.tbJiaochang.nNpcMuhuali_Dialog = pNpc.dwId;
	else
		self.tbJiaochang.nNpcMuhuali_Dialog = nil;
		Dbg:WriteLog("elunheyuan add muhuali failure");
	end
	self.tbJiaochang.nNpcMuhuali_Fight = nil;
	self.tbJiaochang.tbNpcFlagInfo = {}; --id-type
	self.tbJiaochang.tbNpcSoldierInfo = {}; -- id-type
	self.tbJiaochang.tbNpcChangshengcaoId = {}; -- index-id
	self:ChangeTollgateState(5, 1);
end

-- 第六关 可汗大帐
function tbInstancing:ResetKehandazhang()
	if self.tbKehandazhang then
		self:DeleteNpc(self.tbKehandazhang.nNpcQuestion);
		self:DeleteNpc(self.tbKehandazhang.nNpcTuolei_Dialog);
		self:DeleteNpc(self.tbKehandazhang.nNpcTiemuzhen_Dialog);
		self:DeleteNpc(self.tbKehandazhang.nNpcTuolei_Fight);
		self:DeleteNpc(self.tbKehandazhang.nNpcTiemuzhen_Fight);
		if self.tbKehandazhang.tbNpcWineId and #self.tbKehandazhang.tbNpcWineId > 0 then
			for _, nNpcId in pairs(self.tbKehandazhang.tbNpcWineId) do
				self:DeleteNpc(nNpcId);
			end
		end
		if self.tbKehandazhang.nDrinkTimerId then
			Timer:Close(self.tbKehandazhang.nDrinkTimerId);
		end
	else
		self.tbKehandazhang = {};
	end
	-- 添加答题Npc
	local pNpc = KNpc.Add2(9966, 110, -1, self.nMapId, 1696, 3249);
	if pNpc then
		self.tbKehandazhang.nNpcQuestion = pNpc.dwId;
	else
		self.tbKehandazhang.nNpcQuestion = nil;
		Dbg:WriteLog("elunheyuan add questionnpc failure");
	end
	local pTuoLei_Dlg = KNpc.Add2(9967, 110, -1, self.nMapId, 1714, 3208);
	if pTuoLei_Dlg then
		self.tbKehandazhang.nNpcTuolei_Dialog = pTuoLei_Dlg.dwId;
	else
		self.tbKehandazhang.nNpcTuolei_Dialog = nil;
		Dbg:WriteLog("elunheyuan add tuolei_dialog failure");
	end
	local pTiemuzhen_Dlg = KNpc.Add2(9969, 110, -1, self.nMapId, 1747, 3199);
	if pTiemuzhen_Dlg then
		self.tbKehandazhang.nNpcTiemuzhen_Dialog = pTiemuzhen_Dlg.dwId;
	else
		self.tbKehandazhang.nNpcTiemuzhen_Dialog = nil
		Dbg:WriteLog("elunheyuan add tiemuzhen_dialog failure");
	end
	self.tbKehandazhang.nNpcTuolei_Fight = nil;
	self.tbKehandazhang.nNpcTiemuzhen_Fight = nil;
	self.tbKehandazhang.tbEnterDazhangList = {};	-- 进入了大帐的玩家列表nplayerid-type
	self.tbKehandazhang.tbWineOrder = {1,2,3,4};	-- 四种酒的顺序
	Lib:SmashTable(self.tbKehandazhang.tbWineOrder);-- 打乱酒顺序
	self.tbKehandazhang.tbPlayerDrinkInfo = {};		-- 喝酒的状态 nplayerid -- info
	self.tbKehandazhang.tbNpcWineId = {}; -- index-npcid
	self.tbKehandazhang.tbNpcSoldierInfo = {}; -- id-type
	self.tbKehandazhang.nDrinkTimerId = nil;
	self.tbKehandazhang.nCallTeamateTime = nil;
	self.tbKehandazhang.nKillTuoleiPlayerId = nil;
	self:ChangeTollgateState(6, 1);
end

-- 第七关 侠客boss
function tbInstancing:ResetXiakeBoss()
	if self.tbXiakeBoss then
		self:DeleteNpc(self.tbXiakeBoss.nNpcBaiLu_Dialog);
		self:DeleteNpc(self.tbXiakeBoss.nNpcBaiLu_Fight);
		self:DeleteNpc(self.tbXiakeBoss.nNpcCangLang_Dialog);
		self:DeleteNpc(self.tbXiakeBoss.nNpcCangLang_Fight);
		self:DeleteNpc(self.nNpcStone);
		if self.tbXiakeBoss.tbNpcLangWei and #self.tbXiakeBoss.tbNpcLangWei > 0 then
			for _, nNpcId in pairs(self.tbXiakeBoss.tbNpcLangWei) do
				self:DeleteNpc(nNpcId);
			end
		end
			
	else
		self.tbXiakeBoss = {};
	end
	self.tbXiakeBoss.nNpcStone = nil;
	if self.tbTollgateReset[6] == 2 then -- 第六关完了初始化尝试加一下侠客石
		self.tbXiakeBoss.nNpcStone = self:RefreshXiake();
	end
	self.tbXiakeBoss.nNpcBaiLu_Dialog = nil;
	self.tbXiakeBoss.nNpcBaiLu_Fight = nil;
	self.tbXiakeBoss.nNpcCangLang_Dialog = nil;
	self.tbXiakeBoss.nNpcCangLang_Fight = nil;
	self.tbXiakeBoss.tbNpcLangWei = {};
	self:ChangeTollgateState(7, 1);
end

-- 刷新侠客任务
function tbInstancing:RefreshXiake()
	local tbPlayList, _ = KPlayer.GetMapPlayer(self.nMapId);
	for _, player in ipairs(tbPlayList) do 
		if XiakeDaily:CheckHasTask(player, 1, 4) == 1 then
			-- 刷出开启侠客任务的npc
			local pStone = KNpc.Add2(7347, 1, -1, self.nMapId, 1725, 3223);
			if not pStone then
				return nil;
			end
			local tbNpcData = pStone.GetTempTable("Task");
			tbNpcData.nType	= 4;
			tbNpcData.nRefreshPlayerId = player.nId;
			tbNpcData.nRefreshMapId	= self.nMapId;
			tbNpcData.nRefreshNpcPosX = 1725;
			tbNpcData.nRefreshNpcPosY = 3223;
			return pStone.dwId;
		end
	end
end

-- 副本关闭时把所有定时器关闭掉
function tbInstancing:CloseTollgateTimer()
	if self.tbMachang.nTimerId then
		Timer:Close(self.tbMachang.nTimerId);
	end
	if self.tbMachang.nHugeHorseTimerId then
		Timer:Close(self.tbMachang.nHugeHorseTimerId);
	end
	if self.tbMachang.nHorseTimerId then
		Timer:Close(self.tbMachang.nHorseTimerId);
	end
	if self.tbMachang.nSheepTimerId then
		Timer:Close(self.tbMachang.nSheepTimerId);
	end
	if self.tbHuntingGround.tbAddAnimalTimer and #self.tbHuntingGround.tbAddAnimalTimer > 0 then
		for _, nTimerId in pairs(self.tbHuntingGround.tbAddAnimalTimer) do
			Timer:Close(nTimerId);
		end
		self.tbHuntingGround.tbAddAnimalTimer = {};
	end
	if self.tbHuntingGround.tbStateHugeTimerId and #self.tbHuntingGround.tbStateHugeTimerId > 0 then
		for _, nTimerId in pairs(self.tbHuntingGround.tbStateHugeTimerId) do
			Timer:Close(nTimerId);
		end
		self.tbHuntingGround.tbStateHugeTimerId = {};
	end
	if self.tbHuntingGround.nStateDoubleTimerId then
		Timer:Close(self.tbHuntingGround.nStateDoubleTimerId);
		self.tbHuntingGround.nStateDoubleTimerId = nil;
	end
	if self.tbHuntingGround.nEndTimer then
		Timer:Close(self.tbHuntingGround.nEndTimer);
		self.tbHuntingGround.nEndTimer = nil;
	end
	if self.tbKehandazhang.nDrinkTimerId then
		Timer:Close(self.tbKehandazhang.nDrinkTimerId);
	end
end

function tbInstancing:ClearAllTollgateTable()
	self.tbBiwuchangInfo = nil;
	self.tbMachang = nil;
	self.tbHuntingGround = nil;
	self.tbAltar = nil;
	self.tbJiaochang = nil;
	self.tbKehandazhang = nil;
	self.tbXiakeBoss = nil;
end

-- 给关卡中的玩家提示，nType：1：活着的玩家，0:全部玩家, nblack: 是否黑条, nMsg:是否右下角公告,nwaing:是否中屏红字
function tbInstancing:SendPrompt(szMsg, nType, nBlack, nMsg, nWaing)
	nType = nType or 0;
	for nPlayerId, nFlag in pairs(self.tbAttendPlayerList) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer and ((nType == 1 and nFlag == 1) or (nType == 0)) then
			if nBlack == 1 then
				Dialog:SendBlackBoardMsg(pPlayer, szMsg);
			end
			if nMsg == 1 then
				pPlayer.Msg(szMsg);
			end
			if nWaing == 1 then
				Dialog:SendInfoBoardMsg(pPlayer, szMsg);
			end
		end
	end
end

-- 设置关卡的状态，改变trap障碍表现
function tbInstancing:ChangeTollgateState(nIndex, nState)
	self.tbTollgateReset[nIndex] = nState;
	-- 扫描该关的trapnpc
	if not self.tbTrapNpcPosList[nIndex] then
		return;
	end
	self.tbTrapNpcList[nIndex] = self.tbTrapNpcList[nIndex] or {};
	for szTrapName, tbInfo in pairs(self.tbTrapNpcPosList[nIndex]) do
		local nFlag = 0;	-- 0表示要删除，1表示需要增加
		for _, nAddState in pairs(tbInfo.tbAddState) do
			if nAddState == nState then
				nFlag = 1;
				break;
			end
		end
		if nFlag == 0 then -- 如果障碍列表中有该障碍则需要删除
			if self.tbTrapNpcList[nIndex][szTrapName] then
				for _, nNpcId in pairs(self.tbTrapNpcList[nIndex][szTrapName]) do
					self:DeleteNpc(nNpcId);
				end
				self.tbTrapNpcList[nIndex][szTrapName] = {};
			end
		else
			self.tbTrapNpcList[nIndex][szTrapName] = self.tbTrapNpcList[nIndex][szTrapName] or {};
			if #self.tbTrapNpcList[nIndex][szTrapName] == 0 then
				for _, tbPos in pairs(self.tbTrapNpcPosList[nIndex][szTrapName]["tbPosList"]) do -- 添加障碍npc
					local pNpc = KNpc.Add2(9703, 110, -1, self.nMapId, unpack(tbPos))
					if pNpc then
						self.tbTrapNpcList[nIndex][szTrapName][#self.tbTrapNpcList[nIndex][szTrapName] + 1] = pNpc.dwId
					end
				end
			end
		end
	end 
end