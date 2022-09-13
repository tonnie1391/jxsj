
if (not TreasureMap.tbTreasurePos) then
	TreasureMap.tbTreasurePos = {};
end

-- 副本管理，包括副本的创建删除，分配
if (not TreasureMap.InstancingMgr) then
	TreasureMap.InstancingMgr = {};	
end

if (not TreasureMap.InstancingLib) then
	TreasureMap.tbInstancingLib = {};
end

function TreasureMap:GetInstancingBase(nMapTemplateId)
	if (not TreasureMap.tbInstancingLib[nMapTemplateId]) then
		TreasureMap.tbInstancingLib[nMapTemplateId] = {};
		TreasureMap.nMapTemplageId = nMapTemplateId
	end
	
	return TreasureMap.tbInstancingLib[nMapTemplateId];
end

function TreasureMap:New(nTemplateMapId)
	local tbClass = Lib:NewClass(self.InstancingMgr);
	local tbInstancingList = self.InstancingMgr.tbInstancingList;
	if (not tbInstancingList) then
		self.InstancingMgr.tbInstancingList = {};
		tbInstancingList = self.InstancingMgr.tbInstancingList;
	end
	
	assert(not tbInstancingList[nTemplateMapId]);
	
	tbInstancingList[nTemplateMapId] = tbClass;
	
	return tbClass;
end


-- 载入藏宝图文件
function TreasureMap:OnInit()
	local tbNumColName = {["TreasureId"] = 1, ["Level"] = 1, ["MapId"] = 1, ["MapX"] = 1, ["MapY"] = 1, ["InstancingMapId"] = 1, ["InstancingMapX"] = 1, ["InstancingMapY"] = 1, ["MaxMap"] = 1, ["EnterLimtPerWeek"] = 1};
	local tbTreasurePosData = Lib:LoadTabFile(self.szTreasurePosFilePath, tbNumColName);
	
	local nCount = 0;
	
	for _, tbPos in ipairs(tbTreasurePosData) do
		assert(not self.tbTreasurePos[tbPos.TreasureId]);
		self.tbTreasurePos[tbPos.TreasureId] = tbPos;
		nCount = nCount + 1;
	end
	
	-- 读入精铜宝箱的数据
	local tbAwardTreaBox_ColName		= {["Genre"] = 1, ["Detail"] = 1, ["Particular"] = 1, ["Level"] = 1, ["Five"] = 1, ["Rate"] = 1};
	
	TreasureMap.tbAwardTreaBox				= Lib:LoadTabFile(self.szAwardTreaBoxPath, tbAwardTreaBox_ColName);
	TreasureMap.tbAwardTreaBox_Level2		= Lib:LoadTabFile(self.szAwardTreaBox_Level2, tbAwardTreaBox_ColName);
	TreasureMap.tbAwardTreaBox_Level3		= Lib:LoadTabFile(self.szAwardTreaBox_Level3, tbAwardTreaBox_ColName);
	
	print(string.format("TreasureMap Inited! %d Treasure(s)loaded!", nCount));
	
	for _,tbTreasureMap in pairs(self.tbTreasurePos) do
		if (not self.InstancingMgr.tbUsable[tbTreasureMap.TreasureId]) then
			self.InstancingMgr.tbUsable[tbTreasureMap.TreasureId] = {};
		end
	end
	
end

-- 得到一个宝藏的信息
function TreasureMap:GetTreasureInfo(nTreasureId)
	if (not self.tbTreasurePos[nTreasureId]) then
--		self:_Debug("不存在的宝藏位置", nTreasureId);
		return;
	end
	
	return self.tbTreasurePos[nTreasureId];
end

-- 得到指定级别的宝藏列表
function TreasureMap:GetTreasureTableInfo(nLevel)
	local tbRet = {};
	for _, item in pairs(self.tbTreasurePos) do
		if (item.Level == nLevel) then
			tbRet[#tbRet + 1] = item;
		end
	end
	
	return tbRet;
end


-- 产生夺宝贼
function TreasureMap:AddTreasureMugger(pPlayer, nTreasureId, nMinCount, nMaxCount)
	if (nMinCount < 0) then
		nMinCount = 0;
	end
	
	local nMyMapId, nMyPosX, nMyPosY = pPlayer.GetWorldPos();
	local tbPos = self:_GetRandomPosList();
	if (nMaxCount > #tbPos) then
		nMaxCount = #tbPos;
	end
	local nCount = MathRandom(nMinCount, nMaxCount);
	
	local tbInfo		= TreasureMap:GetTreasureInfo(nTreasureId);
	local nMuggerId		= 0;
	local nMuggerLevel	= 0;
	
	if tbInfo.Level == 1 then
		nMuggerId = self.nMuggerId;
		nMuggerLevel = 35;
	elseif tbInfo.Level == 2 then
		nMuggerId = self.nMuggerId_Level2;
		nMuggerLevel = 65;
	elseif tbInfo.Level == 3 then
		nMuggerId = self.nMuggerId_Level3;
		nMuggerLevel = 90;		
	end;
	
	for i = 1, nCount do
		local pNpc = KNpc.Add2(nMuggerId, nMuggerLevel, -1, nMyMapId, (nMyPosX + tbPos[i][1]), (nMyPosY + tbPos[i][2]));
		if pNpc then
			pNpc.GetTempTable("TreasureMap").nPlayerId = pPlayer.nId;
		end;
	end
end


function TreasureMap:_GetRandomPosList()
	Lib:SmashTable(self.tbTreasureMuggerPos);
	return self.tbTreasureMuggerPos;
end


-- 指定地点产生一个带6重锁的宝箱
function TreasureMap:AddTreasureBox(pPlayer, nTreasureId)
	local nMyMapId, nMyPosX, nMyPosY = pPlayer.GetWorldPos();
	local pNpc = KNpc.Add2(self.nTreasureBoxId, 100, -1, nMyMapId, nMyPosX, nMyPosY)
	if (not pNpc) then
		assert(false);
		return;
	end
	local nDeleteTimeId = Timer:Register(30 * 60 *Env.GAME_FPS, self.DelTreasureBox, self, pNpc.dwId);
	pNpc.GetTempTable("TreasureMap").nDeleteTimeId = nDeleteTimeId;
	pNpc.GetTempTable("TreasureMap").nTreasureId = nTreasureId;
	pNpc.GetTempTable("TreasureMap").nPlayerId = pPlayer.nId;
	
	local szTitle = pPlayer.szName.."发现的宝箱";
	pNpc.SetTitle(szTitle);
	
end

function TreasureMap:DelTreasureBox(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if (pNpc) then
		pNpc.Delete();
	end
	
	return 0;
end

-- 副本
function TreasureMap:AddInstancing(pPlayer, nTreasureId)
	assert(pPlayer)
	
	-- 副本任务的处理
	local tbInfo		= TreasureMap:GetTreasureInfo(nTreasureId);
	
	local nMapTemplateId = tbInfo.InstancingMapId;
	
	if TreasureMap.TSK_INS_TBTASK[nMapTemplateId] then
		local nMainTaskState = pPlayer.GetTask(TreasureMap.TSKGID, TreasureMap.TSK_INS_TBTASK[nMapTemplateId][1]);
		
		local nHaveMainTask		= Task:HaveTask(pPlayer, TreasureMap.TSK_INS_TBTASK[nMapTemplateId][3]);
		
		if nHaveMainTask == 0 then
			-- 直接将主人 ID 变为 1，不做判断了
			pPlayer.SetTask(TreasureMap.TSKGID, TreasureMap.TSK_INS_TBTASK[nMapTemplateId][1], 1, 1);
		end;
		
	end;
	
	TreasureMap.InstancingMgr:CreatInstancing(pPlayer, nTreasureId);
end

function TreasureMap:GetMyInstancingTreasureId(pPlayer)
	local tbInstancingData = self:GetMyInstancingData(pPlayer);
	return tbInstancingData.nCurTreasureId;
end


function TreasureMap:GetMyInstancingData(pPlayer)
	local tbPlayerData = pPlayer.GetTempTable("TreasureMap");
	local tbInstancingData = tbPlayerData.tbInstancingData;
	if (not tbInstancingData) then
		tbPlayerData.tbInstancingData = {};
		tbInstancingData = tbPlayerData.tbInstancingData;
	end
	
	return tbInstancingData;
end

function TreasureMap:SetMyInstancingTreasureId(pPlayer, nTreasureId)
	local tbInstancingData = self:GetMyInstancingData(pPlayer);
	tbInstancingData.nCurTreasureId = nTreasureId;
end

function TreasureMap:IsInstancingFree(nTreasureId, nMapId)
	return self.InstancingMgr:IsInstancingFree(nTreasureId, nMapId);	
end	

function TreasureMap:AwardWeiWangAndXinde(pPlayer, nWeiWang, nGongXian, nFriWei, nXinDe)
	self:AwardWeiWang(pPlayer, nWeiWang, nGongXian);
	self:AwardXinDe(pPlayer, nXinDe);
	local nTeamId	= pPlayer.nTeamId;
		if nTeamId <= 0 then
			return;
		end;
	local tbPlayerId, nMemberCount	= KTeam.GetTeamMemberList(nTeamId);
	for i, nPlayerId in pairs(tbPlayerId) do
		local pPL	= KPlayer.GetPlayerObjById(nPlayerId);
		if pPL and pPL.nId ~= pPlayer.nId and pPL.nMapId == pPlayer.nMapId then
			self:AwardWeiWang(pPL, nWeiWang, nGongXian);
			self:AwardXinDe(pPL, nXinDe);
		end
	end
end

function TreasureMap:AwardWeiWang(pPlayer, nWeiWang, nGongXian)
	-- by zhangjinpin@kingsoft
	if pPlayer.nLevel >= 80 then
		return;
	end
	pPlayer.AddKinReputeEntry(nWeiWang, "treasuremap");
end

function TreasureMap:AwardXinDe(pPlayer, nXinDe)
	Setting:SetGlobalObj(pPlayer);
	Task:AddInsight(nXinDe);
	Setting:RestoreGlobalObj();
end

function TreasureMap:GetInstancing(nMapId)
	return self.InstancingMgr:GetInstancing(nMapId);
end


function TreasureMap:AddFriendFavor(tbTeamList, nMapId, nFavor)
	if (not tbTeamList) then
		return;
	end
	
	for i = 1, #tbTeamList do
		for j = i + 1, #tbTeamList do
			if (tbTeamList[i].nMapId == nMapId and tbTeamList[j].nMapId == nMapId and 
				tbTeamList[i].IsFriendRelation(tbTeamList[j].szName) == 1) then
					Relation:AddFriendFavor(tbTeamList[i].szName, tbTeamList[j].szName, nFavor);
					tbTeamList[i].Msg(string.format("您与<color=yellow>%s<color>好友亲密度增加了%d点。", tbTeamList[j].szName, nFavor));
					tbTeamList[j].Msg(string.format("您与<color=yellow>%s<color>好友亲密度增加了%d点。", tbTeamList[i].szName, nFavor));
				end
		end
	end
end


-- 师徒成就：完成副本
function TreasureMap:GetAchievement(tbTeamList, nAchievementId, nMapId)
	if (not tbTeamList or not nMapId or nMapId <= 0) then
		return;
	end
	
	for _, pPlayer in pairs(tbTeamList) do
		if (pPlayer.nMapId == nMapId) then
			Achievement_ST:FinishAchievement(pPlayer.nId, nAchievementId);
		end
	end
end


-- 测试用
-- 添加一个指定属性的藏宝图
function TreasureMap:AddTreasureMap(pPlayer, nTreasureId)
	
	local tbInfo		= TreasureMap:GetTreasureInfo(nTreasureId);
	
	local pItem = me.AddItem(18, 1, 9, tbInfo.Level);
	pItem.SetGenInfo(TreasureMap.ItemGenIdx_nTreaaureId, nTreasureId);
	pItem.SetGenInfo(TreasureMap.ItemGenIdx_IsIdentify, 1);
	pItem.Sync();
end


function TreasureMap:ShowInstancingInfo(pPlayer)
	TreasureMap.InstancingMgr:ShowInstancingInfo(pPlayer);
end

-- 根据玩家得到其当前所处的副本模板 ID
function TreasureMap:GetPlayerMapTemplateId(pPlayer)
	local nMapId, nMapX, nMapY	= pPlayer.GetWorldPos();
	local tbInstancing = TreasureMap:GetInstancing(nMapId);	
	
	if tbInstancing then
		return tbInstancing.nMapTemplateId;
	else
		return 0;
	end;
end;

TreasureMap.bIsLimitationStart = true;
TreasureMap.nMaxMoneyPerTenMinutes			= 714000; -- 每10分钟最高产银两数量
TreasureMap.nAwardedMoney 				= 0;	-- 当前这个10分钟已经产出的银两数量
TreasureMap.nCurTimeValue 					= 0;	-- 当前这个10分钟的标记
TreasureMap.tbValidTime = {100, 240}; -- 产出银两的时间段 [10, 24)
TreasureMap.nAddedMoney = 0; 		-- 记录每个同步时间段的产出量
TreasureMap.nSynDeltaTime = 5 * Env.GAME_FPS; -- 同步数据间隔

function TreasureMap:IsOverLimit()
	if not self.bIsLimitationStart then
		return false;
	end
	local nCurTimeValue = math.floor(tonumber(GetLocalDate("%H%M")) / 10);
	if nCurTimeValue ~= self.nCurTimeValue then
		self.nCurTimeValue = nCurTimeValue;
		self.nAwardedMoney = 0;
		self.nAddedMoney = 0;
	end
	if (nCurTimeValue < self.tbValidTime[1] or nCurTimeValue >= self.tbValidTime[2]) then
		return true; -- 不在产出时间段，不发银子
	end
	-- 是否应该产出非绑银(在产出非绑银的时间段，并且当前这个小时已产出的非绑银没有超过额度)
	if self.nAwardedMoney >= self.nMaxMoneyPerTenMinutes then
		return true; -- 这个小时发完了，不发了
	end
	return false;
end

function TreasureMap:GetMoneyOfTeam(pPlayer)
	local tbTeamMember = pPlayer.GetTeamMemberList() or {};
	local tbMoney = {};
	for _, v in pairs(tbTeamMember) do
		tbMoney[v.nId] = v.nCashMoney;
	end
	return tbMoney;
end

-- 记录所有队员身上的钱
function TreasureMap:BeforeAward(pPlayer)
	if not self.bIsLimitationStart then
		return ;
	end
	self.tbMoneyBeforeAward = self:GetMoneyOfTeam(pPlayer);
end

function TreasureMap:AfterAward(pPlayer)
	if not self.bIsLimitationStart then
		return ;
	end
	
	local nDeltaMoney = 0;
	for k, v in pairs(self:GetMoneyOfTeam(pPlayer)) do
		local nMoneyBefore = self.tbMoneyBeforeAward[k]
		if nMoneyBefore and v > nMoneyBefore then
			nDeltaMoney = nDeltaMoney + (v - nMoneyBefore);
		end
	end
	
	if nDeltaMoney > 0 then
		self.nAwardedMoney = self.nAwardedMoney + nDeltaMoney;
		self.nAddedMoney = self.nAddedMoney + nDeltaMoney;
		if not self.nTimerId then
			self.nTimerId = Timer:Register(self.nSynDeltaTime, self.SynData_Timer, self);
		end
	end
end

function TreasureMap:SynDataToGS(nTime, nAddedMoney, nServerId)
	if not self.bIsLimitationStart then
		return ;
	end
	local nCurTimeValue = math.floor(tonumber(GetLocalDate("%H%M")) / 10);
	if nCurTimeValue ~= self.nCurTimeValue then
		self.nCurTimeValue = nCurTimeValue;
		self.nAwardedMoney = 0;
		self.nAddedMoney = 0;
	end
	if nTime == self.nCurTimeValue and GetServerId() ~= nServerId then
		self.nAwardedMoney = self.nAwardedMoney + nAddedMoney;
	end
end

function TreasureMap:SynData_Timer()
	if not self.bIsLimitationStart then
		return ;
	end
	
	if self.nAddedMoney  <= 0 then
		return;
	end
	local nCurTimeValue = math.floor(tonumber(GetLocalDate("%H%M")) / 10);
	if nCurTimeValue ~= self.nCurTimeValue then
		self.nCurTimeValue = nCurTimeValue;
		self.nAwardedMoney = 0;
		self.nAddedMoney = 0;
		return;
	end
	GCExcute({"TreasureMap:SynData", self.nCurTimeValue, self.nAddedMoney, GetServerId()});
	self.nAddedMoney = 0;
end

function TreasureMap:OpenByGC()
	self.bIsLimitationStart = true;
end

function TreasureMap:CloseByGC()
	self.bIsLimitationStart = false;
end





