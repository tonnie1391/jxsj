-- 文件名　：kinggame2_gs.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-06-09 14:26:42
-- 描述：新家族副本gs逻辑

Require("\\script\\kin\\kingame_new\\kingame2_def.lua")

KinGame2.tbGameManager = {};

local tbGameManager = KinGame2.tbGameManager;

function tbGameManager:InitManager()
	self.tbGame = {};
	self.tbMap = {};
	self.tbKin = {};
	self.nMapCount = 0;
	self.nGameCount = 0;
end

--gs根据citymap id申请fb
function tbGameManager:ApplyKinGame(nKinId, nCityMapId)
	if self.tbKin[nKinId] then
		return 0;
	end
	for i = 1, self.nMapCount do
		if not self.tbGame[self.tbMap[i]] and self.tbMap[i] and self.tbMap[i] ~= 0 then
			self.tbKin[nKinId] = self.tbMap[i];
			self.tbMap[i] = self.tbMap[i];
			self.tbGame[self.tbMap[i]] = Lib:NewClass(KinGame2.tbBase);
			self.tbGame[self.tbMap[i]]:InitGame(self.tbMap[i], nCityMapId, nKinId);
			self.nGameCount = self.nGameCount + 1;
			GCExcute{"KinGame2:AnnounceKinGame_GC", nKinId, nCityMapId};
			return 1;
		end
	end
	if self.nMapCount >= KinGame2.MAX_GAME then
		return 0;
	end
	if (LoadDynMap(Map.DYNMAP_TREASUREMAP, KinGame2.MAP_TEMPLATE_ID, nCityMapId) == 1) then
		self.nMapCount = self.nMapCount + 1; 	-- 先占一个名额~不用等GC响应也能判断是否已经到达副本上限
		self.tbMap[self.nMapCount] = 0; 		-- 先标0防止其他副本使用本地图
		self.tbKin[nKinId] = 0;
		return 1;
	end
end

--地图加载完成后的回调
function tbGameManager:OnLoadMap(nMapId, nCityMapId)
	for nKinId, nIsFinishLoad in pairs(self.tbKin) do
		if nIsFinishLoad == 0 then
			for i = 1,  #self.tbMap do
				if self.tbMap[i] == 0 then
					self.tbKin[nKinId] = nMapId;
					self.tbMap[i] = nMapId;
					self.tbGame[nMapId] = Lib:NewClass(KinGame2.tbBase);
					self.tbGame[nMapId]:InitGame(nMapId, nCityMapId, nKinId);
					self.nGameCount = self.nGameCount + 1;
					GCExcute{"KinGame2:AnnounceKinGame_GC", nKinId, nCityMapId};
					return 1;
				end
			end
		end
	end
	return 0;
end

function KinGame2:Init()
	self.tbManager = {};
end

if not KinGame2.tbManager then
	KinGame2:Init();
end

--通过地图id获取fb对象
function KinGame2:GetGameObjByMapId(nMapId)
	for i, tbManager in pairs(self.tbManager) do
		if tbManager.tbGame and tbManager.tbGame[nMapId] then
			return tbManager.tbGame[nMapId];
		end
	end
end

--通过家族id获取fb对象
function KinGame2:GetGameObjByKinId(nKinId)
	for i, tbManager in pairs(self.tbManager) do
		if tbManager.tbKin[nKinId] and tbManager.tbGame and tbManager.tbGame[tbManager.tbKin[nKinId]] then
			return tbManager.tbGame[tbManager.tbKin[nKinId]];
		end
	end
end


--通过gc的申请返回值判断是否申请fb
function KinGame2:ApplyKinGame_GS2(nKinId, nCityMapId, nTime, nDegree, nRet, nPlayerId)
	local tbData = Kin:GetKinData(nKinId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if nRet == 0 then
		-- 数据差异，同步数据
		local cKin = KKin.GetKin(nKinId);
		if cKin then
			cKin.SetKinGameTime(nTime);
			cKin.SetKinGameDegree(nDegree);
			tbData.nApplyKinGameMap = nCityMapId;
			tbData.nIsNewGame = 1;
		end
		return 0;
	end
	tbData.nApplyKinGameMap = nCityMapId;
	tbData.nIsNewGame = 1;	--标记选择的是新家族关卡
	if IsMapLoaded(nCityMapId) ~= 1 then
		-- 不是本服务器申请的副本
		return 0;
	end
	if not self.tbManager[nCityMapId] then
		self.tbManager[nCityMapId] = Lib:NewClass(tbGameManager);
		self.tbManager[nCityMapId]:InitManager()
	end
	-- 申请地图，本地逻辑发送成功就视为成功
	nRet = self.tbManager[nCityMapId]:ApplyKinGame(nKinId, nCityMapId);
	if nRet ~= 1 and pPlayer then
		pPlayer.Msg("该地方的活动场地已满！");
	end
	GCExcute{"KinGame2:ApplyKinGame_GC2", nKinId, nRet, nTime, nDegree};
end

--gc确认申请成功，设置家族关卡进度
function KinGame2:ApplyKinGame_GS3(nKinId, nTime, nDegree)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	cKin.SetKinGameTime(nTime);
	cKin.SetKinGameDegree(nDegree);
end

-- 副本地图加载完成回调
function KinGame2:OnLoadMapFinish(nMapId, nCityMapId)
	assert(self.tbManager[nCityMapId]);
	self.tbManager[nCityMapId]:OnLoadMap(nMapId, nCityMapId);
end

-- 家族公告打开副本
function KinGame2:AnnounceKin_GS2(nKinId, nCityMapId)
	KKinGs.KinClientExcute(nKinId, {"KKin.ShowKinMsg", string.format("石鼓书院关卡已经开启，请要参加的成员去<color=red>家族领地<color>找“马穿山”报名进入！")});
end

-- 关闭家族关卡GS-GC逻辑
function KinGame2:EndGame_GS1(nKinId, nMapId, nCityMapId, nRet)
	if self.tbManager[nCityMapId].tbGame[nMapId] then
		self.tbManager[nCityMapId].tbGame[nMapId] = nil;
		self.tbManager[nCityMapId].nGameCount = self.tbManager[nCityMapId].nGameCount - 1;
		self.tbManager[nCityMapId].tbKin[nKinId] = nil;
	end
	GCExcute{"KinGame2:EndGame_GC", nKinId, nRet};
end

function KinGame2:EndGame_GS2(nKinId, nRet)
	local tbData = Kin:GetKinData(nKinId);
	tbData.nApplyKinGameMap = nil;
	tbData.nIsNewGame = nil;
	if nRet == 0 then
		KKinGs.KinClientExcute(nKinId, {"KKin.ShowKinMsg", "你的家族在开启石鼓书院时未达到8个参加者，家族关卡关闭"});
	end
end

--设置上次通关难度
function KinGame2:SetLastPassLevel_GS(nKinId,nLevel)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	if not nLevel then
		nLevel = 1;
	end
	cKin.SetKinGame2LastPassLevel(nLevel);
end


function KinGame2:GetCityGameNum(nCityMapId)
	if not self.tbManager[nCityMapId] then
		return 0;
	end
	return self.tbManager[nCityMapId].nGameCount;
end

--获取该sever上的城市,用于进入fb时判断
function KinGame2:GetSeverCity()
	local nId = 0 ;
	for _ , nMapId in pairs(self.CITY_MAP) do
		if nMapId then
			if IsMapLoaded(nMapId) == 1 then
				nId = nMapId;
				break;
			end
		end
	end
	return nId;
end

--加入游戏
function KinGame2:JoinGame()
	if me.GetTiredDegree1() == 2 then
		Dialog:Say("您太累了，还是休息下吧！");
		return;
	end
	local nKinId, nMemberId = me.GetKinMember()
	local tbGame = self:GetGameObjByKinId(nKinId);
	if not tbGame then
		return 0;
	end
	if tbGame:IsStart() == 1 and tbGame:FindLogOutPlayer(me.nId) ~= 1 then
		Dialog:Say("你们家族的人已经进去开启了机关关闭了入口，现在谁也进不去了！");
		return 0;
	end
	-- 记录参加次数
	local nNum = me.GetTask(StatLog.StatTaskGroupId , 1) + 1;
	me.SetTask(StatLog.StatTaskGroupId , 1, nNum);
	tbGame:JoinGame(me);
end


--每个关卡完成后的随机行为,关卡成功通过刷出
function KinGame2:RandomGameAfterRoomBingo(nRoomId,nMapId)
	if not nRoomId or nRoomId == 0 then
		return 0;
	end
	local tbPosA = self.YOULONG_NPC_POS[nRoomId];
	if not tbPosA then
		return 0;
	end
	local pGame =  self:GetGameObjByMapId(nMapId) --获得对象
	if not pGame then
		return 0;
	end
	pGame.nSelectPlayerId = 0;
	pGame.tbSelectLuck = {};
	local tbPlayer,nCount = pGame:GetPlayerList();
	local nRandom = MathRandom(nCount);
	if tbPlayer[nRandom] then
		pGame.nSelectPlayerId = tbPlayer[nRandom].nId;
		Achievement:FinishAchievement(tbPlayer[nRandom],399);
	end
	local tbSelect = {1,2,3,4};	--4个等级的备选幸运数
	for i = 1,#tbSelect do
		local nPos = MathRandom(#tbSelect);
		table.insert(pGame.tbSelectLuck,tbSelect[nPos]);
		table.remove(tbSelect,nPos);
	end
	pGame.tbYouLongNpc = {};
	for _,tbPos in pairs(tbPosA) do
		if tbPos then
			local pNpc = KNpc.Add2(self.YOULONG_NPC_ID, 10, -1, nMapId, unpack(tbPos));
			table.insert(pGame.tbYouLongNpc,pNpc);
		end
	end
	pGame.nSelectTimer = Timer:Register(30 * Env.GAME_FPS, self.RandomTimeUp, self,nMapId);
	pGame:AllBlackBoard(string.format("请<color=yellow>%s<color>在30秒内进行幸运选择",tbPlayer[nRandom].szName));
	local szState = string.format("请<color=pink>%s<color>点击游龙真气进行幸运选择",tbPlayer[nRandom].szName);
	pGame:UpdateUiState(nil,nil,szState);
end


function KinGame2:RandomTimeUp(nMapId)
	local pGame = self:GetGameObjByMapId(nMapId);
	if not pGame or not pGame.tbSelectLuck then
		return 0;
	end
	local nLevel = pGame.tbSelectLuck[MathRandom(#pGame.tbSelectLuck)];
	self:EndRandomGame(nLevel,nMapId);
	return 0;
end


--选择完毕后结束随机游戏,计时器到点也回调这个函数
function KinGame2:EndRandomGame(nLevel,nMapId)
	if not nLevel or nLevel <= 0 or nLevel > 4 then
		nLevel = 1;
	end 
	if not nMapId then
		return 0;
	end
	local pGame =  self:GetGameObjByMapId(nMapId) --获得对象
	if not pGame then
		return 0;
	end
	if pGame.nSelectTimer > 0 then
		Timer:Close(pGame.nSelectTimer);
		pGame.nSelectTimer = 0;
	end
	--猜点完成，删除npc
	local tbYouLongNpc = pGame.tbYouLongNpc;
		for _,pNpc in pairs(tbYouLongNpc) do
		if pNpc then
			pNpc.Delete();
		end
	end
	pGame.tbYouLongNpc = nil;
	local nGameLevel = pGame.nGameLevel;	--游戏等级
	local szMsg = string.format("恭喜，家族本关获得%s等级的古金币加成奖励",KinGame2.RANDOM_LEVEL_NAME[nLevel]);
	pGame:AllBlackBoard(szMsg);
	--给奖励
	pGame:GiveAllPlayerAwardItemRandom(pGame.nCurrentStepRoom,nLevel);
	if pGame.nCurrentStepRoom == 1 then	--第一关游龙结束，开启第二关
		pGame:StartRoom(pGame.nCurrentStepRoom + 1,1);
	end
	if pGame.nCurrentStepRoom == 4 then
		local szMsg = "";
		local szState = "小心前方的机关";
		pGame:UpdateUiState(szMsg,nil,szState);
	end
	if pGame.nCurrentStepRoom == 7 then	--第7关成功以后进行所有关卡成败处理
		pGame:HandleAllPassInfo();
	end
end


--获得古金币
function KinGame2:GiveAwardItem(pPlayer,nNum,nRandom,nLevel)
	local nCount = pPlayer.GetTask(KinGame2.TASK_GROUP_ID, KinGame2.TASK_GOLD_COIN);
	local nDrop = 0;
	local nOrgNum = nNum;	
	local nState = pPlayer.GetSkillState(2240);
	if nState == 1 then
		nNum = nNum * 1.2;
	end
	local nTimesNum = nOrgNum * self.AWARD_TIMES;
	if nTimesNum ~= nOrgNum and nNum < nTimesNum then
		nNum = nTimesNum;
	end
	if nCount >= self.MAX_GOLD_COIN then
		pPlayer.Msg(string.format("古金币袋已满，在古金币用掉之前已不能再获得古金币", nNum));
		return 0;
	end
	if nCount + nNum > self.MAX_GOLD_COIN then 
		nDrop = nCount + nNum - self.MAX_GOLD_COIN;
		nNum = self.MAX_GOLD_COIN - nCount;
	end
	
	pPlayer.SetTask(KinGame2.TASK_GROUP_ID, KinGame2.TASK_GOLD_COIN, nCount + nNum);
	SpecialEvent.tbGoldBar:AddTask(pPlayer, 4, nNum);		--金牌联赛家族光卡铜钱数
	-- 成就
	if (nCount + nNum >= 500) then
		Achievement:FinishAchievement(pPlayer, 51);
	end

	if nNum > nOrgNum and nNum ~= nTimesNum then
		pPlayer.Msg("您真幸运，获得1.2倍古金币。");
		Dialog:SendBlackBoardMsg(pPlayer, "您真幸运，获得1.2倍古金币。");
	elseif nNum > nOrgNum and nNum == nTimesNum then
		local szMsg =  string.format("您真幸运，获得%s倍古金币。",self.AWARD_TIMES);
		pPlayer.Msg(szMsg);
		Dialog:SendBlackBoardMsg(pPlayer,szMsg);
	end
	if nRandom and nLevel and nRandom == 1 and nLevel >= 1 then
		pPlayer.Msg(string.format("<color=yellow>游龙随机幸运数，奖励级别:%s，您一共获得了%d枚古金币。<color>",KinGame2.RANDOM_LEVEL_NAME[nLevel],nNum));
	else
		pPlayer.Msg(string.format("你获得了%d枚古金币。", nNum));
	end
end


-------test------------
function KinGame2:ClearDegree_GS(nKinId,bToday)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	cKin.SetKinGameTime(0);
	if bToday and bToday == 1 then
		cKin.SetKinGameDegree(0);
	else
		cKin.SetKinGameDegree(1);
	end
	local tbData = Kin:GetKinData(nKinId)
	tbData.nApplyKinGameMap = nil;
	tbData.nIsNewGame = nil;
end

function KinGame2:SetGameDegree_GS(nKinId,nTime,nDegree)
	if not nTime or nDegree then
		return 0;
	end
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	cKin.SetKinGameTime(0);
	cKin.SetKinGameDegree(0);
	cKin.SetKinGameDegree(1);
end


function KinGame2:StartRoom(nKinId,nRoomId)
	local pGame = self:GetGameObjByKinId(nKinId);
	if not pGame then
		return 0;
	end
	if pGame.tbRoom[nRoomId - 1] then
		pGame.tbRoom[nRoomId - 1]:EndRoom();
	end
end