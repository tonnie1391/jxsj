-- 文件名　：missionlevel20_gs.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-07-16 09:30:13
-- 功能    ：

if not MODULE_GAMESERVER then
	return 0;
end

Require("\\script\\task\\primer\\newmissionlevel20\\missionlevel20_def.lua")

Task.NewPrimerLv20 = Task.NewPrimerLv20 or {};
local NewPrimerLv20 = Task.NewPrimerLv20;

--gs根据server id申请fb
function NewPrimerLv20:ApplyGame(nPlayerId)
	if self.tbManagerList and self.tbManagerList[nPlayerId] then	--已经有申请过了
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	pPlayer.SetRevivePos(pPlayer.nMapId, 3);	--这里把玩家重生点设到副本门口（副本掉线就在副本门口了）
	--先检查自己gs是否有空闲地图或者剩余可以开起的地图
	local nRet = self:CheckMyServer();
	if nRet > 0 then
		self:ApplyMyServer(nPlayerId, nRet, 1);
		return;
	end
	--否则锁住玩家询问gc，其他gs
	pPlayer.AddWaitGetItemNum(1);
	GCExcute{"Task.NewPrimerLv20:ApplyGameMap_GC",nPlayerId, GetServerId()};
end

function NewPrimerLv20:ApplyMyServer(nPlayerId, nMapId, bOtherServer)
	self.tbManagerList[nPlayerId] = {};
	if nMapId <= 1 then		--有地图可以用就用地图，或者就去申请
		self:OnApplyMap(nPlayerId, bOtherServer);
	else
		if bOtherServer <= 0 then
			Timer:Register(5 * Env.GAME_FPS, self.OnStartGame, self, nPlayerId, nMapId);
		else
			self:OnStartGame(nPlayerId, nMapId);
		end
		self.tbMapList[nMapId].bUsed = 2;
		self.tbManagerList[nPlayerId].nUseMapId = nMapId;
		self.tbManagerList[nPlayerId].nStartTime = GetTime();
		local nMyServerId = GetServerId();
		self.tbServerInfo[nMyServerId] = self.tbServerInfo[nMyServerId] or {};
		self.tbServerInfo[nMyServerId].nUseCount = (self.tbServerInfo[nMyServerId].nUseCount or 0) + 1;
		GCExcute{"Task.NewPrimerLv20:SysApplyInfo", GetServerId(), nPlayerId, nMapId, GetTime(), bOtherServer};
	end
end

function NewPrimerLv20:OnStartGame(nPlayerId, nMapId)
	local tbMission = self.tbMissionList[nMapId];
	if not tbMission then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		--这里默认询问三次，如果玩家都还没过来就反注册掉
		tbMission.nApplyEnterCount = (tbMission.nApplyEnterCount or 0) + 1;
		if tbMission.nApplyEnterCount >= 3 then
			GCExcute{"Task.NewPrimerLv20:SysCloseInfo", GetServerId(), nPlayerId, nMapId};
			tbMission.nApplyEnterCount = 0;
			return 0;
		end
		return;
	end
	tbMission:InitGame(nMapId);
	local tbEnterPos = self:GetEnterPos(pPlayer);
	if not tbEnterPos then
		return 0;
	end
	Dialog:PlayIlluastration(pPlayer, {szImage = "chahua_xingkong.spr",szTalk = 'Sự mệt mỏi khiến bản thân chìm vào giấc ngủ...Khi tỉnh dậy chỉ thấy bóng đêm bao trùm. Đã đến lúc đến Lễ hội hoa đăng!'});
	Dialog:SendBlackBoardMsg(pPlayer, "Màn đêm vừa buông xuống...");
	pPlayer.NewWorld(nMapId, unpack(tbEnterPos));
	tbMission:JoinGame(pPlayer);
	return 0;
end

--检查本服是否有那么多副本可以开启
function NewPrimerLv20:CheckMyServer()
	for nMapId, tb in pairs(self.tbMapList) do
		if tb.bUsed == 0 then
			tb.bUsed = 1;		--map占位
			return nMapId;
		end
	end
	local tbInfo = self.tbServerInfo[GetServerId()];
	if not tbInfo or tbInfo.nUseCount < self:GetServerMaxMCount() then
		return 1;
	end
	return 0;
end

function NewPrimerLv20:OnApplyMap(nPlayerId, bOtherServer)
	if (Map:LoadDynMap(Map.DYNMAP_TREASUREMAP,self.nMapTemplateId, {self.OnLoadMapFinish,self,nPlayerId, bOtherServer}) ~= 1)then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if not pPlayer then
			return 0;
		end
		pPlayer.Msg("Vui lòng thử lại sau!");
		return 1;
	end
end

--地图加载完成后的回调
function NewPrimerLv20:OnLoadMapFinish(nPlayerId, bOtherServer, nMapId)
	self.tbMapList[nMapId] = self.tbMapList[nMapId] or {};
	self.tbMapList[nMapId].bUsed = 2;
	self.tbManagerList[nPlayerId].nUseMapId = nMapId;
	self.tbManagerList[nPlayerId].nStartTime = GetTime();
	local nServerId = GetServerId();
	self.tbServerInfo[nServerId] = self.tbServerInfo[nServerId] or {};
	self.tbServerInfo[nServerId].nUseCount = (self.tbServerInfo[nServerId].nUseCount or 0) + 1;
	
	self.tbMissionList[nMapId] = Lib:NewClass(NewPrimerLv20.tbBase);
	if bOtherServer <= 0 then
		Timer:Register(5 * Env.GAME_FPS, self.OnStartGame, self, nPlayerId, nMapId)
	else
		self:OnStartGame(nPlayerId, nMapId);
	end
	GCExcute{"Task.NewPrimerLv20:SysApplyInfo", GetServerId(), nPlayerId, nMapId, GetTime(), bOtherServer};
	return 1;
end

--申请失败
function NewPrimerLv20:ApplyGameFailed(nPlayerId, nFlag)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	if not nFlag then
		pPlayer.AddWaitGetItemNum(-1);
	end
	Dialog:SendBlackBoardMsg(pPlayer, "Vẫn chưa đến thời gian.");
end

--获取当前server游戏数量
function NewPrimerLv20:GetGameCount(nServerId)
	if not self.tbManager[nServerId] then
		return 0;
	end
	return self.tbManager[nServerId].nGameCount;
end

--开启指定步骤的副本阶段,通过task传入
function NewPrimerLv20:StartStepByTaskStep(pPlayer,nStep)
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

function NewPrimerLv20:GetGameCount(nServerId)
	if not self.tbManager[nServerId] then
		return 0;
	end
	return self.tbManager[nServerId].nGameCount;
end

--通过地图id获取fb对象
function NewPrimerLv20:GetGameObjByMapId(nMapId)
	local tbManager = self.tbManager;
	if tbManager[GetServerId()] and tbManager[GetServerId()].tbGame and tbManager[GetServerId()].tbGame[nMapId] then
		return tbManager[GetServerId()].tbGame[nMapId];
	end
end

--通过playerid 获取对象
function NewPrimerLv20:GetGameObjByPlayerId(nPlayerId)
	local tbManager = self.tbManager;
	if tbManager[GetServerId()] and tbManager[GetServerId()].tbPlayer[nPlayerId] and
		tbManager[GetServerId()].tbGame and tbManager[GetServerId()].tbGame[tbManager[GetServerId()].tbPlayer[nPlayerId]] then
		return tbManager[GetServerId()].tbGame[tbManager[GetServerId()].tbPlayer[nPlayerId]];
	end
end

--申请
function NewPrimerLv20:ApplyGame_GS(nServerId, nPlayerId, bOtherServer)
	if nServerId ~= GetServerId() then
		return 0;
	end
	if self.tbManagerList and self.tbManagerList[nPlayerId] then	--已经有申请过了
		GlobalExcute{"Task.NewPrimerLv20:ApplyGameFailed", nPlayerId, 1};
		return 0;
	end
	--先检查自己gs是否有空闲地图或者剩余可以开起的地图
	local nRet = self:CheckMyServer();
	if nRet > 0 then
		self:ApplyMyServer(nPlayerId, nRet, bOtherServer);
		return 0;
	end
	GlobalExcute{"Task.NewPrimerLv20:ApplyGameFailed", nPlayerId, 1};
end

--离开游戏
function NewPrimerLv20:LeaveGame(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	if not self.tbManagerList[nPlayerId] then
		return 0;
	end
	local tbMission = self.tbMissionList[self.tbManagerList[nPlayerId].nUseMapId];
	if not tbMission then
		return 0;
	end
	pPlayer.SetLogoutRV(0);		-- 解除服务器宕机保护
	BlackSky:GiveMeBright(pPlayer);     -- 关闭剧情黑屏状态
	tbMission:KickPlayer(pPlayer);
	return 0;
end

--任务回掉这里删掉子书青，增加跟随子书青
function NewPrimerLv20:FindNpcInMap()
	local tbNpcList =  KNpc.GetAroundNpcList(me, 10);
	for i, pNpc in ipairs(tbNpcList) do
		if pNpc.nTemplateId == 10249 then
			pNpc.Delete();
			local nMapId, nX, nY = me.GetWorldPos();
			local pNpc = KNpc.Add2(10301, 10, -1, nMapId, nX, nY);
			if pNpc then
				pNpc.SetNpcAI(10, me.GetNpc().nIndex, 0, 0, 0, 0, 0, 0, 0, 0, 0);
				return;
			end
		end
	end
end

function NewPrimerLv20:DeleteFollowNpc()
	--这步完成后删掉跟随的子书青
	local tbNpcList =  KNpc.GetAroundNpcList(me, 50);
	for i, pNpc in ipairs(tbNpcList) do
		if pNpc.nTemplateId == 10301 or pNpc.nTemplateId == 11079 then
			pNpc.Delete();
		end
	end
end

--放烟花
function NewPrimerLv20:AddYanhua(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	local tbNpcList =  KNpc.GetAroundNpcListByNpc(nNpcId, 20);
	for _, pNpcEx in ipairs(tbNpcList) do
		pNpcEx.CastSkill(2934, 1,-1,pNpcEx.nIndex);
	end
	local tbMission = self.tbMissionList[pNpc.nMapId];
	if not tbMission then
		return 0;
	end
	self:SayZishuqing(me, "Hãy cùng nhau bắn pháo hoa năm mới...");
	tbMission.nYanhua = (tbMission.nYanhua or 0) + 1;
	if tbMission.nYanhua >= 3 then
		tbMission:FireYanhua();
	end
end

function NewPrimerLv20:AddLight()
	local tbMission = self.tbMissionList[me.nMapId];
	if not tbMission then
		return 0;
	end
	tbMission.nAddLightCount = 0;
	Timer:Register(1, self.AddLightEx, self, me.nMapId)
	self:SayZishuqing(me, "Mỗi đèn lồng là lời cầu, tôi không biết cần bao nhiêu đèn lồng cho thế giới này.");
end

function NewPrimerLv20:AddLightEx(nMapId)
	local tbMission = self.tbMissionList[nMapId];
	if not tbMission then
		return 0;
	end
	local nNpcId = 10302;
	local pNpc = KNpc.Add2(nNpcId + MathRandom(2) - 1, 1, -1, nMapId, 2032, 3368);
	if pNpc then
		local nX = MathRandom(5) - (2 - MathRandom(2) *  5);
		local nY = MathRandom(5) - (2 - MathRandom(2) *  5);
		pNpc.AI_AddMovePos((2041+nX) * 32, (3357 + nY) * 32);
		pNpc.SetNpcAI(9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		pNpc.GetTempTable("Npc").tbOnArrive = {self.tbOnLightArrive, self, pNpc.dwId};
		tbMission.nAddLightCount = (tbMission.nAddLightCount or 0) + 1;
	end
	if tbMission.nAddLightCount == 5 then
		return 0;
	end
	return 18*3;
end

--npc到达
function NewPrimerLv20:tbOnLightArrive(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		pNpc.Delete();
	end
end

function NewPrimerLv20:AddZiQing(tbTasks, nMapId)
	if tbTasks.nReferId == self.TASK_SUB_ID and tbTasks.nCurStep > 2 and tbTasks.nCurStep < 8 then
		local pNpc = KNpc.Add2(10301, 1, -1, nMapId, 1999, 3385);
		if pNpc then
			pNpc.SetNpcAI(10, me.GetNpc().nIndex, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		end
	elseif (tbTasks.nReferId == self.TASK_SUB_ID and tbTasks.nCurStep == 8) or (tbTasks.nReferId == self.TASK_SUB_ID_NEXT and tbTasks.nCurStep < 7) then
		local pNpc = KNpc.Add2(10301, 1, -1, nMapId, 1952, 3510);
		if pNpc then
			pNpc.SetNpcAI(10, me.GetNpc().nIndex, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		end
	else
		KNpc.Add2(10249, 1, -1, nMapId, 2026, 3376);
	end
end

--增加统领（吕家被屠之后刷）
function NewPrimerLv20:AddTongling(nMapId)
	Timer:Register(3*18, self.AddTonglingEx, self, nMapId);
end
function NewPrimerLv20:AddTonglingEx(nMapId)
	KNpc.Add2(10259, 15, -1, nMapId, 1874,3524);
	return 0;
end

--增加许士伟
function NewPrimerLv20:AddXuShiwei(nMapId, nFlag)
	if not nFlag then
		Timer:Register(5*18, self.AddXuShiwei, self, nMapId, 1);
		return 0;
	end
	KNpc.Add2(10261, 15, -1, nMapId, 1874,3524);
	return 0;
end

--增加神秘人（打败许士伟后刷）
function NewPrimerLv20:AddShenmiren(nMapId, nFlag)
	if not nFlag then
		Timer:Register(5*18, self.AddShenmiren, self, nMapId, 1);
		return;
	end
	local pNpc = KNpc.Add2(10256, 15, -1, nMapId, 1836,3483);
	--if pNpc then
	--	Npc:RegPNpcLifePercentReduce(pNpc,10,self.OnFinalBossPercent,self,pNpc.dwId, me.nId);
	--end
	return 0;
end
--神秘人20%血时触发子书青，挡子弹场景
function NewPrimerLv20:OnFinalBossPercent(nNpcId, nPlayerId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	pNpc.SendChat("Tiền bối không muốn hại huynh, chỉ là không muốn giữ huynh lại chốn này.");
	local tbNpcList = KNpc.GetAroundNpcListByNpc(nNpcId, 20);
	local _, nX1, nY1 = pNpc.GetWorldPos();
	local _, nX2, nY2 = pPlayer.GetWorldPos();
	local nX3 = nX1 + math.floor((nX2 - nX1) / 2);
	local nY3 = nY1 + math.floor((nY2 - nY1) / 2);
	for i, pNpcEx in pairs(tbNpcList) do
		if pNpcEx.nTemplateId == 10301 then
			pNpcEx.AI_AddMovePos(nX3 * 32, nY3 * 32);
			pNpcEx.SetNpcAI(9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
			pNpcEx.SendChat("Hãy cẩn thận...");
			Timer:Register(18, self.AddOtherZiqing, self, pNpcEx.dwId, pPlayer.nMapId, nX3, nY3, nPlayerId);
			return;
		end
	end
end
--子书青到达子弹点
function NewPrimerLv20:AddOtherZiqing(nNpcId, nMapId, nX, nY, nPlayerId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	pNpc.Delete();
	Dialog:PlayIlluastration(pPlayer, {szImage = "chahua_xueguang.spr",szTalk = '<color=yellow>Tử Thư Thanh<color>: Không......'});
	local pNpcEx = KNpc.Add2(11079, 15, -1, nMapId, nX, nY);
	if pNpcEx then
		Timer:Register(9, self.AddOtherZiqingEx, self, pNpcEx.dwId);
	end
	return 0;
end
function NewPrimerLv20:AddOtherZiqingEx(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		pNpc.SendChat("Thư Thanh cuối cùng cũng hoàn thành sứ mệnh của mình...");
	end
	return 0;
end

--副本进入点
function NewPrimerLv20:EnterFuben()
	local tbTasks = Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID];
	if not tbTasks then
		return;
	end
	if (tbTasks.nReferId == self.TASK_SUB_ID and (tbTasks.nCurStep >= 2 or tbTasks.nCurStep == -1)) or tbTasks.nReferId == self.TASK_SUB_ID_NEXT then
		self:ApplyGame(me.nId);
	end
end

function NewPrimerLv20:AddBaiQiuLin(nMapId)
	KNpc.Add2(10180, 15, -1, nMapId, 1824,3490);
end

--剧情1
function NewPrimerLv20:AddJuQing1()
	local tbTasks = Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID];
	if not tbTasks then
		return;
	end
	if tbTasks.nReferId ~= self.TASK_SUB_ID or tbTasks.nCurStep ~= 7 then
		return;
	end
	me.LockClientInput();
	Npc.SceneAction:DoParam(8);
	Npc.SceneAction:DoParam(17);
	Timer:Register(25*18, self.AddJuQing1Ex, self, me.nId);
end

function NewPrimerLv20:AddJuQing1Ex(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		local tbNpcList = KNpc.GetAroundNpcList(pPlayer,20);
		for i, pNpc in ipairs(tbNpcList) do 
			if pNpc.nTemplateId ~= 10301 and pNpc.szName ~= pPlayer.szName then
				pNpc.CastSkill(2935,1,-1,pNpc.nIndex);
			end
		end
		pPlayer.CastSkill(2935,1,-1,pPlayer.GetNpc().nIndex);
		Timer:Register(36, self.AddJuQing1Ex2, self, nPlayerId);
		pPlayer.GetNpc().SendChat("Chuyện gì đã xảy ra...");
	end
	return 0;
end

function NewPrimerLv20:AddJuQing1Ex2(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		local tbNpcList =  KNpc.GetAroundNpcList(pPlayer, 10);
		for i, pNpc in ipairs(tbNpcList) do
			if pNpc.nTemplateId == 10301 then
				pNpc.NewWorld(pPlayer.nMapId, 1951, 3510);
				break;
			end
		end
		pPlayer.NewWorld(pPlayer.nMapId, 1951, 3510);
		pPlayer.SetTask(1025,79,1);
		pPlayer.UnLockClientInput();
	end
	return 0;
end

--剧情2
function NewPrimerLv20:AddJuQing2()
	local tbTasks = Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID];
	if not tbTasks then
		return;
	end
	if tbTasks.nReferId ~= self.TASK_SUB_ID_NEXT or tbTasks.nCurStep ~= 2 then
		return;
	end
	me.LockClientInput();
	Npc.SceneAction:DoParam(9);
	Npc.SceneAction:DoParam(10);
	Npc.SceneAction:DoParam(11);
	Npc.SceneAction:DoParam(12);
	me.CallClientScript({"GM:DoCommand",string.format("me.StartAutoPath(%s, %s, 1)", 1880,3530)});
	Timer:Register(18*18, self.AddJuQing2_black, self, me.nId);
	Timer:Register(34*18, self.AddJuQing2Ex, self, me.nId);
end

function NewPrimerLv20:AddJuQing2_black(nPlayerId)
	local szMsg = [[
	<Playername>：“书青！他是你祖父！你我不能袖手旁观！我得去救他们！”<end>
	<npc=10249>:“不能去！我们得马上出村！是……就是因为那是我吕家尊长，才更加不能去！”<end>
	<Playername>：“书青你在说些什么！快放手！”<end>
	<npc=10249>:“……你以为我吕家是为了谁……你以为！若不是为了保护你！我吕家怎会落得如此！我子书青又怎会在此苟且偷生！”<end>
	]]
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		BlackSky:SimpleTalk(pPlayer, szMsg)
	end
	return 0;
end

function NewPrimerLv20:AddJuQing2Ex(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.SetTask(1025,80,1);
		pPlayer.UnLockClientInput();
		self:AddTongling(pPlayer.nMapId);
	end
	return 0;
end

--根据不同的玩家任务状态开启不同的事件
function NewPrimerLv20:OpenEvent(nMapId)
	local tbTasks = Task:GetPlayerTask(me).tbTasks[self.TASK_MAIN_ID];
	if not tbTasks then
		return;
	end
	self:AddZiQing(tbTasks, nMapId)
	if tbTasks.nReferId == self.TASK_SUB_ID_NEXT then
		if tbTasks.nCurStep == 3 then
			self:AddTongling(nMapId);
		elseif tbTasks.nCurStep == 4 then
			self:AddXuShiwei(nMapId, 1);
		elseif tbTasks.nCurStep == 6 then
			self:AddShenmiren(nMapId, 1);
		elseif tbTasks.nCurStep == 7 then
			self:AddBaiQiuLin(nMapId);
		end
	end
	return;
end

--根据玩家进度把玩家new到不同的点
function NewPrimerLv20:GetEnterPos(pPlayer)
	local tbTasks = Task:GetPlayerTask(pPlayer).tbTasks[self.TASK_MAIN_ID];
	if not tbTasks then
		return;
	end
	if tbTasks.nReferId == self.TASK_SUB_ID and tbTasks.nCurStep <= 7 and tbTasks.nCurStep > 0 then
		return {1996,3389};
	elseif tbTasks.nReferId == self.TASK_SUB_ID_NEXT or (tbTasks.nReferId == self.TASK_SUB_ID and (tbTasks.nCurStep == 8 or tbTasks.nCurStep == -1)) then
		return {1949,3510};
	end
	return;
end

function NewPrimerLv20:GetLevelPos(pPlayer)
	local tbMap = {2154, 2254};
	local tbTasks = Task:GetPlayerTask(pPlayer).tbTasks[self.TASK_MAIN_ID];
	if tbTasks then
		for _, nMapId in ipairs(tbMap) do
			if SubWorldID2Idx(nMapId) >= 0 then
				return {nMapId, 1914,3484};
			end
		end
		return {2154, 1914,3484};
	end
	
	
	local tbSendPos = 
	{
		{55, 1679, 3722},
		-- {2286, 1679, 3722},
	}
	local nRand = MathRandom(1, #tbSendPos);
	return tbSendPos[nRand];
end

--新手上线保护
function NewPrimerLv20:OnLogin(bExchangeServerComing)
	if bExchangeServerComing == 1 then
		return;
	end
	
	local tbTasks = Task:GetPlayerTask(me).tbTasks[NewPrimerLv20.TASK_MAIN_ID];
	--刚好是在两个任务衔接处离开的，这里要帮玩家接任务，否则有问题
	if me.GetTask(1000, NewPrimerLv20.TASK_MAIN_ID) == NewPrimerLv20.TASK_SUB_ID and	not tbTasks then
		Task:DoAccept(NewPrimerLv20.TASK_MAIN_ID, NewPrimerLv20.TASK_SUB_ID_NEXT);
	end
	
	me.SetTask(2000, 6, 0);	--取消屏蔽功能
	me.UnLockClientInput();	--取消锁屏功能
	--使用戏服下线，再次上线完成步骤任务
	if me.GetTask(1025,82) == 1 then
		me.SetTask(1025,81,1);
		me.SetTask(1025,82,0);
	end
	--计乱水贼营任务变身，再次上线需要增加变身技能
	local tbTasks = Task:GetPlayerTask(me).tbTasks[527];
	if tbTasks and tbTasks.nReferId == 744 and tbTasks.nCurStep > 2 and tbTasks.nCurStep < 7 then
		me.AddSkillState(2854,2,0,5*60*18,1,1);
	end
	--以下是坐船保护
	if tbTasks and tbTasks.nReferId == 743 and tbTasks.nCurStep == 3 and me.GetTask(1025,83) == 10247 then
		me.NewWorld(me.nMapId, 1804, 3556);
	end
	
	if tbTasks and tbTasks.nReferId == 743 and tbTasks.nCurStep == 9 and me.GetTask(1025,83) == 10163 then
		me.NewWorld(me.nMapId, 1673, 3713);
	end
	
	if tbTasks and tbTasks.nReferId == 744 and tbTasks.nCurStep == 8 and me.GetTask(1025,83) == 10248 then
		me.NewWorld(me.nMapId, 1778, 3558);
	end
	
	-- 青螺岛坐船任务保护
	if me.GetTask(1025,83) == 8 then
		me.NewWorld(me.nMapId, 1665, 3813);
		me.SetTask(1025, 83, 0);
	end
	return 1;
end

-- PlayerEvent:RegisterGlobal("OnLogin", NewPrimerLv20.OnLogin, NewPrimerLv20);


---------------------------------------------------------------------------------------------------------------------
--新手任务用
---------------------------------------------------------------------------------------------------------------------


--使用戏服
function NewPrimerLv20:UseXiFu()
	me.SetTask(2000, 6, 1);
	me.CastSkill(2933,10,-1,me.GetNpc().nIndex);
	me.AddSkillState(2175,5,0,30*18,1,1,0,0,1);
	me.AddSkillState(2854,1,0,30*18,1,1);
	me.LockClientInput();
	Npc.SceneAction:DoParam(53);
	me.SetTask(1025,82,1);
	me.CallClientScript({"SpecialEvent.QiXi2012:OpenTimer", 2932, 20 * 18});
	Timer:Register(23*18, self.UseXiFuEx, self, me.nId);	--18秒后释放
end	

function NewPrimerLv20:UseXiFuEx(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	pPlayer.SetTask(2000, 6, 0);
	pPlayer.RemoveSkillState(2854);
	pPlayer.RemoveSkillState(2175);
	pPlayer.UnLockClientInput();
	pPlayer.SetTask(1025,81,1);
	return 0;
end

function NewPrimerLv20:UsePilidan()
	me.CastSkill(2930,4,-1,me.GetNpc().nIndex)
end

function NewPrimerLv20:UseJieyao()
	me.CallClientScript{"GM:DoCommand", "me.CastSkill(273,1,-1,me.GetNpc().nIndex)"};
end
function NewPrimerLv20:SayZishuqing(pPlayer, szMsg)
	local tbNpcList =  KNpc.GetAroundNpcList(pPlayer, 10);
	for i, pNpc in ipairs(tbNpcList) do
		if pNpc.nTemplateId == 10301 then
			pNpc.SendChat(szMsg)
		end
	end
end
