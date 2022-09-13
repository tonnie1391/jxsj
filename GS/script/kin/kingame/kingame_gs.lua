-------------------------------------------------------------------
--File		: kingame_gs.lua
--Author	: zhengyuhua
--Date		: 2008-5-15 14:43
--Describe	: 家族关卡GS脚本
-------------------------------------------------------------------
KinGame.tbGameManager = {};
local tbGameManager = KinGame.tbGameManager

function tbGameManager:InitManager()
end

function tbGameManager:InitManager()
	self.tbGame = {};
	self.tbMap = {};
	self.tbKin = {};
	self.nMapCount = 0;
	self.nGameCount = 0;
end

function tbGameManager:ApplyKinGame(nKinId, nCityMapId)
	if self.tbKin[nKinId] then
		return 0;
	end
	for i = 1, self.nMapCount do
		if not self.tbGame[self.tbMap[i]] and self.tbMap[i] and self.tbMap[i] ~= 0 then
			self.tbKin[nKinId] = self.tbMap[i];
			self.tbMap[i] = self.tbMap[i];
			self.tbGame[self.tbMap[i]] = Lib:NewClass(KinGame.tbBase);
			self.tbGame[self.tbMap[i]]:InitGame(self.tbMap[i], nCityMapId, nKinId);
			self.nGameCount = self.nGameCount + 1;
			GCExcute{"KinGame:AnnounceKinGame_GC", nKinId, nCityMapId};
			return 1;
		end
	end
	if self.nMapCount >= KinGame.MAX_GAME then
		return 0;
	end
	if (LoadDynMap(Map.DYNMAP_TREASUREMAP, KinGame.MAP_TEMPLATE_ID, nCityMapId) == 1) then
		self.nMapCount = self.nMapCount + 1; 	-- 先占一个名额~不用等GC响应也能判断是否已经到达副本上限
		self.tbMap[self.nMapCount] = 0; 		-- 先标0防止其他副本使用本地图
		self.tbKin[nKinId] = 0;
		return 1;
	end
end

function tbGameManager:OnLoadMap(nMapId, nCityMapId)
	for nKinId, nIsFinishLoad in pairs(self.tbKin) do
		if nIsFinishLoad == 0 then
			for i = 1,  #self.tbMap do
				if self.tbMap[i] == 0 then
					self.tbKin[nKinId] = nMapId;
					self.tbMap[i] = nMapId;
					self.tbGame[nMapId] = Lib:NewClass(KinGame.tbBase);
					self.tbGame[nMapId]:InitGame(nMapId, nCityMapId, nKinId);
					self.nGameCount = self.nGameCount + 1;
					GCExcute{"KinGame:AnnounceKinGame_GC", nKinId, nCityMapId};
					return 1;
				end
			end
		end
	end
	return 0;
end


function KinGame:Init()
	self.tbManager = {}
end
if not KinGame.tbManager then
	KinGame:Init();
end

function KinGame:GetGameObjByMapId(nMapId)
	for i, tbManager in pairs(self.tbManager) do
		if tbManager.tbGame and tbManager.tbGame[nMapId] then
			return tbManager.tbGame[nMapId];
		end
	end
end

function KinGame:GetGameObjByKinId(nKinId)
	for i, tbManager in pairs(self.tbManager) do
		if tbManager.tbKin[nKinId] and tbManager.tbGame and tbManager.tbGame[tbManager.tbKin[nKinId]] then
			return tbManager.tbGame[tbManager.tbKin[nKinId]];
		end
	end
end

-- GC仲裁成功或失败回调，成功申请副本地图，失败同步GC数据
function KinGame:ApplyKinGame_GS2(nKinId, nCityMapId, nTime, nDegree, nRet, nPlayerId)
	local tbData = Kin:GetKinData(nKinId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if nRet == 0 then
		-- 数据差异，同步数据
		local cKin = KKin.GetKin(nKinId);
		if cKin then
			cKin.SetKinGameTime(nTime);
			cKin.SetKinGameDegree(nDegree);
			tbData.nApplyKinGameMap = nCityMapId;
		end
		return 0;
	end
	tbData.nApplyKinGameMap = nCityMapId;
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
		pPlayer.Msg("该城市的活动场地已满！");
	end
	GCExcute{"KinGame:ApplyKinGame_GC2", nKinId, nRet, nTime, nDegree};
end

-- 认为副本已经成功开启的回调
function KinGame:ApplyKinGame_GS3(nKinId, nTime, nDegree)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 0;
	end
	cKin.SetKinGameTime(nTime);
	cKin.SetKinGameDegree(nDegree);
end

-- 副本地图加载完成回调
function KinGame:OnLoadMapFinish(nMapId, nCityMapId)
	assert(self.tbManager[nCityMapId]);
	self.tbManager[nCityMapId]:OnLoadMap(nMapId, nCityMapId);
end

-- 家族公告打开副本
function KinGame:AnnounceKin_GS2(nKinId, nCityMapId)
	local szCityName = GetMapNameFormId(nCityMapId);
	KKinGs.KinClientExcute(nKinId, {"KKin.ShowKinMsg", string.format("家族关卡已经开启，请要参加的成员去<color=red>%s<color>找“马穿山”报名进入！", szCityName)});
end

-- 关闭家族关卡GS-GC逻辑
function KinGame:EndGame_GS1(nKinId, nMapId, nCityMapId, nRet)
	if self.tbManager[nCityMapId].tbGame[nMapId] then
		self.tbManager[nCityMapId].tbGame[nMapId] = nil;
		self.tbManager[nCityMapId].nGameCount = self.tbManager[nCityMapId].nGameCount - 1;
		self.tbManager[nCityMapId].tbKin[nKinId] = nil;
	end
	GCExcute{"KinGame:EndGame_GC", nKinId, nRet};
end

function KinGame:EndGame_GS2(nKinId, nRet)
	local tbData = Kin:GetKinData(nKinId);
	tbData.nApplyKinGameMap = nil;
	if nRet == 0 then
		KKinGs.KinClientExcute(nKinId, {"KKin.ShowKinMsg", "你的家族在家族关卡开启时未达到6个参加者，家族关卡关闭"});
	end
end

function KinGame:GetDifNpcTemplateId(nRoomId, nNpcTempLevel)
	return self.DifNpcTemplet[nNpcTempLevel][nRoomId];
end

function KinGame:GetDifNpcPosTable(nRoomId)
	return self.DifTrap[nRoomId];
end

function KinGame:GetCityGameNum(nCityMapId)
	if not self.tbManager[nCityMapId] then
		return 0;
	end
	return self.tbManager[nCityMapId].nGameCount;
end

function KinGame:JoinGame()
	if me.GetTiredDegree1() == 2 then
		Dialog:Say("您太累了，还是休息下吧！");
		return;
	end
	local nKinId, nMemberId = me.GetKinMember()
	local tbGame = self:GetGameObjByKinId(nKinId);
	if not tbGame then
		return 0;
	end
	-- 记录参加次数
	local nNum = me.GetTask(StatLog.StatTaskGroupId , 1) + 1;
	me.SetTask(StatLog.StatTaskGroupId , 1, nNum);
	tbGame:JoinGame(me);
end

-- NPC解数量锁公用函数
function KinGame:NpcUnLockMulti(pNpc)
	local tbTmp = pNpc.GetTempTable("KinGame")
	if not tbTmp then
		return 0;
	end
	if tbTmp.tbLockTable then
		tbTmp.tbLockTable:UnLockMulti();
	end
end

--获得古钱币
function KinGame:GiveAwardItem(pPlayer, nNum)
	local nCount = pPlayer.GetTask(KinGame.TASK_GROUP_ID, KinGame.TASK_BAG_ID);
	local nDrop = 0;
	nNum = nNum * self.AWARD_TIMES;
	local nOrgNum = nNum;
	local nState = pPlayer.GetSkillState(2240);	
	local nRate = MathRandom(100);
	if nState == 1 and nRate <= 20 then
		nNum = nNum * 2;
	end
	if nCount >= self.MAX_GUQIANBI then
		pPlayer.Msg(string.format("钱袋已满，在用掉之前已不能再获得古铜钱", nNum));
		return 0;
	end
	if nCount + nNum > self.MAX_GUQIANBI then 
		nDrop = nCount + nNum - self.MAX_GUQIANBI;
		nNum = self.MAX_GUQIANBI - nCount;
	end	
	
	pPlayer.SetTask(KinGame.TASK_GROUP_ID, KinGame.TASK_BAG_ID, nCount + nNum);
	
	if nNum > nOrgNum then
		pPlayer.Msg("您真幸运，获得双倍古铜钱。");
		Dialog:SendBlackBoardMsg(pPlayer, "您真幸运，获得双倍古铜钱。");
	end
	
	-- 成就，古钱币
	if (nCount + nNum >= 500) then
		Achievement:FinishAchievement(pPlayer, 51);
	end
	SpecialEvent.tbGoldBar:AddTask(pPlayer, 4, nNum);		--金牌联赛家族光卡铜钱数
	pPlayer.Msg(string.format("你获得了%d枚古铜钱。", nNum));
end

--返回一个随机table nMax个数里，返回nCount个随机数的table
function KinGame:GetRandomTable(nMax, nCount)
	if nCount > nMax then
		nCount = nMax;
	end
	local table1 = {};
	for i = 1, nMax do
		table1[i] = i;
	end
	for i = 1,nMax do
		local p = Random(nMax) + 1;
		table1[i],table1[p] = table1[p],table1[i]
	end
	local table2 = {};
	for i = 1, nCount do
		table2[table1[i]] = 1;
	end
	return table2
end

function KinGame:GiveEveryOneAward(nMapId)
	local pGame =  KinGame:GetGameObjByMapId(nMapId) --获得对象
	if pGame == nil then
		return 0;
	end
	local nCountMax = pGame:GetPlayerCount();
	local nAwardMultip = pGame.nAwardMultip;
	local nExCount = (nCountMax * nAwardMultip) - nCountMax;
	local nExPlayer = KinGame:GetRandomTable(nCountMax, nExCount);
	local tbPlayer = pGame:GetPlayerList();
	for ni, pKinPlayer in pairs(tbPlayer) do
		local nNum = 1;
		if nExPlayer[ni] == 1 then
			nNum = 2;
		end
		KinGame:GiveAwardItem(pKinPlayer, nNum);
	end
end

function KinGame:BuyCallBossItem_GS2(nKinId, nMemberId, nItemLevel, nCurYinBi, nRet)
	local cKin = KKin.GetKin(nKinId);
	if not cKin then
		return 
	end
	cKin.SetKinGuYinBi(nCurYinBi);
	if not cKin then
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId)
	if not cMember then
		return 0;
	end
	local nPlayerId = cMember.GetPlayerId()
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0
	end
	-- 还原锁定状态
	pPlayer.AddWaitGetItemNum(-1);
	if nRet == 1 then
		local pItem = pPlayer.AddItem(self.GOU_HUN_YU_ITEM[1], self.GOU_HUN_YU_ITEM[2], self.GOU_HUN_YU_ITEM[3], nItemLevel);
		if pItem then
			-- 拆开家族ID来存~否则部分家族会变负数
			pItem.SetGenInfo(1, math.floor(nKinId / 2));
			pItem.SetGenInfo(2,	nKinId % 2)
			pPlayer.SetItemTimeout(pItem, os.date("%Y/%m/%d/%H/%M/00", GetTime() + 30 * 3600 * 24));  	-- 一个月有效
		else
			print("[gouhunyu]", pPlayer.szName, "加勾魂玉道具失败！", nItemLevel);
		end
	elseif nRet == -1 then
		pPlayer.Msg("你家族的古银币不足！")
		return 0;
	else
		pPlayer.Msg("只有族长和副族长可以购买勾魂玉！");
		return 0;
	end
end

function KinGame:CheckPlayerInKinGame(szPlayerName)
	if (not szPlayerName) then
		return 0;
	end
	
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);

	if (not pPlayer) then
		return 0;
	end
	
	local nKinId, nMemberId = pPlayer.GetKinMember();	
	local cKin = KKin.GetKin(nKinId);

	if (not cKin) then
		return 0;
	end	

	local tbGame = KinGame:GetGameObjByKinId(nKinId);
	if not tbGame then
		return 0;
	end
	if tbGame:IsStart() == 1 and tbGame:FindLogOutPlayer(pPlayer.nId) ~= 1 then
		return 0;
	end

	return 1;
end

function KinGame:DailyEvent_UpdateDate()
	me.SetTask(self.TASK_GROUP_ID, self.TASK_NOW_WEEK_TIME, 0);
end
	
PlayerSchemeEvent:RegisterGlobalDailyEvent({KinGame.DailyEvent_UpdateDate, KinGame});

