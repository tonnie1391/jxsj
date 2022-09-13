-- 文件名　：mission.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-04-27 16:15:57
-- 描  述  ：

Esport.DragonBoatMission = Esport.DragonBoatMission or Mission:New();
local tbMission = Esport.DragonBoatMission;

local function OnSort(tbA, tbB)
	if tbA.nRank ~= tbB.nRank then
		return tbA.nRank > tbB.nRank;
	end
	if tbA.nTime ~= tbB.nTime then
		return tbA.nTime < tbB.nTime;
	end
	return tbA.nTime < tbB.nTime;
end

function tbMission:OpenMission(tbEnterPos, tbLeavePos, nMatchType)
	if self:IsOpen() == 1 then
		print("龙舟重复开启");
		return;
	end	
	-- 设定可选配置项
	self.tbMisCfg	= {
		tbEnterPos		= {[0] = tbEnterPos},	-- 进入坐标
		tbLeavePos		= {[0] = tbLeavePos},	-- 离开坐标
		tbCamp			= {[0]=0, [1]=1, [2]=2},
		nForbidTeam		= 1,
		nPkState		= Player.emKPK_STATE_PRACTISE,--战斗模式
		nDeathPunish	= 1,
		nInLeagueState	= 1,
		nButcheStamina	= 1,
		nForbidSwitchFaction	= 1,
		nLogOutRV		= Mission.LOGOUTRV_DEF_MISSION_DRAGONBOAT,
	}
	self.tbGroups	= {};
	self.tbPlayers	= {};
	self.tbTimers	= {};	
	self.nMisMapId		= tbEnterPos[1];
	self.tbMisEventList	= Esport.DragonBoat.MIS_LIST;
	self.tbNowStateTimer = nil;
	self.tbSkillList= {};	--龙舟技能表
	self.tbRankList = {};	--排名表
	self.tbObjList 	= {};	--眩晕表
	self.tbSkillItemList = {};	--随机召唤技能物品
	self.tbPlayers	= {};
	self.nStateJour = 0;
	self.tbGroupName = {};
	self.nGroupNum = 0;
	self.nMatchType = nMatchType or 0;
	self.tbResultRank = {};
	self.nMissionCloseFlag = 0; -- 表示正在关闭中不需要触发团队离线提前关闭比赛场函数
end

function tbMission:OnStart()
	self:GoNextState();
	self:InitGame();
end

function tbMission:InitGame()
	self.tbNpcJiGuan = {};
	for _, tbPos in pairs(Esport.DragonBoat.tbPosJiGuan) do
		local pNpc = KNpc.Add2(3643, 100, -1, self.nMisMapId, tonumber(tbPos.TRAPX)/32, tonumber(tbPos.TRAPY)/32);
		if pNpc then
			table.insert(self.tbNpcJiGuan, pNpc.dwId);
		end
	end
	self:OnCallSkillItem();
	self:CreateTimer(3*18, self.OnNpcCastSkill, self);
	self:CreateTimer(15*18, self.OnCallSkillItem, self);
end

function tbMission:OnNpcCastSkill()
	if self:IsOpen() ~= 1 then
		return 0;
	end
	for _, nNpcId in pairs(self.tbNpcJiGuan) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			local nM, nX, nY = pNpc.GetWorldPos();
			local pRandom = MathRandom(1, #Esport.DragonBoat.SKILL_ITEM_LIST[3]);
			local tbSkill = Esport.DragonBoat.SKILL_ITEM_LIST[3][pRandom];
			if tbSkill then
				pNpc.CastSkill(tbSkill[1], tbSkill[2], nX*32, nY*32);
			else
				print("Random", pRandom);
			end
		end
	end
end

function tbMission:OnCallSkillItem()
	local tbRandom = {};
	for i=1, 10 do
		tbRandom[i] = i;
	end
	
	local nSecFrame = self.tbMisEventList[2][2];
	local nPerGroupFrame = math.floor(nSecFrame / #Esport.DragonBoat.tbPosRandom);
	local nUseTime = nSecFrame - self:GetStateLastTime();
	for nGroup, tbPos in pairs(Esport.DragonBoat.tbPosRandom) do
		if (nGroup * nPerGroupFrame) >= nUseTime then
			Lib:SmashTable(tbRandom);
			for i=1,7 do
				local nPoint	= tbRandom[i];
				local tbCallPos = tbPos[nPoint];
				local nPosX 	= tonumber(tbCallPos.TRAPX);
				local nPosY 	= tonumber(tbCallPos.TRAPY);
				local nType 	= self:GetRandomNpcType();
				
				local nNpcId	= Esport.DragonBoat.CALLNPC_TYPE[nType][1];
				self.tbSkillItemList[nGroup] = self.tbSkillItemList[nGroup] or {};
				self.tbSkillItemList[nGroup][nPoint] = {};
				local pNpc = KNpc.Add2(nNpcId, 100, -1, self.nMisMapId, nPosX/32, nPosY/32);
				if pNpc then
					self.tbSkillItemList[nGroup][nPoint] = {pNpc.dwId, nType};
					local tb = pNpc.GetTempTable("Npc");
					tb.DragonBoat = {};
					tb.DragonBoat.nGroup = nGroup;
					tb.DragonBoat.nPoint = nPoint;
				end
			end
		end
	end
	self:CreateTimer(10*18, self.OnCallSkillItemClose, self);
end

function tbMission:GetRandomNpcType()
	local nMaxRate = 0;
	for _, tbRate in pairs(Esport.DragonBoat.CALLNPC_TYPE) do
		nMaxRate = nMaxRate + tbRate[2];
	end
	local nCurRate = MathRandom(1, nMaxRate);
	local nSum = 0;
	for nType, tbRate in pairs(Esport.DragonBoat.CALLNPC_TYPE) do
		nSum = nSum + tbRate[2];
		if nSum >= nCurRate then
			return nType;
		end
	end
	return 1;
end

function tbMission:GetSkillItem(nGroup, nPoint)
	if not self.tbSkillItemList[nGroup] or not self.tbSkillItemList[nGroup][nPoint] then
		return 0;
	end
	local nType  = self.tbSkillItemList[nGroup][nPoint][2];
	return nType;
end

function tbMission:SkillItemClose(nGroup, nPoint)
	--do return 0 end; --改用点击npc，不再使用过trap点获得
	if not self.tbSkillItemList[nGroup] or not self.tbSkillItemList[nGroup][nPoint] then
		return 0;
	end
	local nNpcId = self.tbSkillItemList[nGroup][nPoint][1];
	local nType  = self.tbSkillItemList[nGroup][nPoint][2];
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		pNpc.Delete();
	end
	self.tbSkillItemList[nGroup][nPoint] = nil;
end

function tbMission:OnCallSkillItemClose()
	for nGroup, tbPoint in pairs(self.tbSkillItemList) do
		for _, tbInfo in pairs(tbPoint) do
			local pNpc = KNpc.GetById(tbInfo[1]);
			if pNpc then
				pNpc.Delete();
			end
		end
	end
	self.tbSkillItemList = {};
	return 0;
end

function tbMission:OnGameStart()
	for nRank, pPlayer in pairs(self:GetPlayerList()) do
		pPlayer.SetFightState(1);
		pPlayer.nPkModel = Player.emKPK_STATE_BUTCHER;
		Dialog:SendBlackBoardMsg(pPlayer, "Thi đấu bắt đầu, ai sẽ là người nhanh nhất đây?");
		local szMsg = Esport.DragonBoat.MIS_UI[self:GetGameState()+1][1]
		self:UpdateTimeUi(pPlayer, szMsg, self.tbMisEventList[self:GetGameState()+1][2]);
	end
	self:UpdataAllUi();
end

function tbMission:OnGameOver()
	table.sort(self.tbRankList, OnSort);
	self.tbResultRank = {};
	for nRank, tbInfo in ipairs(self.tbRankList) do
		local pPlayer = KPlayer.GetPlayerObjById(tbInfo.nId)
		if (self.nMatchType == 2) then
			if pPlayer and self:GetPlayerGroupId(pPlayer) >= 0 then
				if self:GetRank(pPlayer) < Esport.DragonBoat.DEF_FINISH_RANK then
					local nRank = self:GetCurRank(pPlayer);
					local szMsg1 = string.format("Thật tiếc, chỉ đạt được hạng %s", nRank or 1);
					Dialog:SendBlackBoardMsg(pPlayer, szMsg1);
					pPlayer.Msg(string.format("<color=yellow>%s<color>",szMsg1));
					Esport.DragonBoat:GetSingleGameAward(pPlayer, nRank);
				end			
			end			
		else
			-- 要么玩家还在mission里，要么就是不在mission里但是已经完成比赛了的
			if ( (pPlayer and self:GetPlayerGroupId(pPlayer) >= 0) or (tbInfo.nRank or 0) == Esport.DragonBoat.DEF_FINISH_RANK ) then
				table.insert(self.tbResultRank, {nGroupId = tbInfo.nGroupId, nPlayerId = tbInfo.nId, szName = tbInfo.szName, nRank = nRank});
			end
		end
		if (pPlayer) then
			pPlayer.SetLogoutRV(0);
		end
	end

	-- 组队赛且有回调函数
	if ((self.nMatchType > 2) and self.tbCallbackOnClose) then
		Lib:CallBack(self.tbCallbackOnClose);
	end
	self:EndGame();
	return 0;
end

function tbMission:EndGame()
	self.nMissionCloseFlag = 1;
	ClearMapNpc(self.nMisMapId);
	self:Close();	
end

function tbMission:OnSingleEndGame(pPlayer)
	if (not pPlayer) then
		return 0;
	end
	pPlayer.SetFightState(0);
	local nRestTime = self:GetStateLastTime();
	local nOutTime	= 120*18;

	-- 如果是单人赛就需要提前退出比赛场
	if nRestTime > nOutTime then
		if self.tbCallbackEndPlay and type(self.tbCallbackEndPlay[1]) == "function" then
			self.tbCallbackEndPlay[1](self.tbCallbackEndPlay[2], pPlayer);
		end
		self:CreateTimer(nOutTime, self.OnSingleKickGame, self, pPlayer.nId);
	else
		nOutTime= 30*18;
		if nRestTime > nOutTime then
			self:CreateTimer(nOutTime, self.OnSingleKickGame, self, pPlayer.nId);
		else
			nOutTime = nRestTime;
		end
	end

	local nRank = self:GetCurRank(pPlayer);
	local szMsg = Esport.DragonBoat.MIS_UI[2][1] .. "\nThời gian nước rút: <color=white>%s<color>";
	self:UpdateTimeUi(pPlayer, szMsg, nRestTime, nOutTime);	
	local szMsg1 = "";

	-- 如果是个人赛
	if (self.nMatchType == 2) then
		szMsg1 = string.format("Thi đấu kết thúc! Đạt hạng %s, hãy tiếp tục cố gắng!", nRank or 1);
		Esport.DragonBoat:GetSingleGameAward(pPlayer, nRank);
	else
		szMsg1 = string.format("Thi đấu kết thúc! Đến gặp Án Nhược Tuyết để xem kết quả!", nRank or 1);
	end

	Dialog:SendBlackBoardMsg(pPlayer, szMsg1);
	pPlayer.Msg(string.format("<color=yellow>%s<color>",szMsg1));	
	
	return 0;
end


function tbMission:OnSingleKickGame(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.SetLogoutRV(0);
		self:KickPlayer(pPlayer);
	end
	return 0;
end

function tbMission:GetGameState()
	return self.nStateJour;
end

function tbMission:OnJoin(nGroupId)
	me.GetTempTable("Esport").tbDragonBoatInfo = {};
	me.GetTempTable("Esport").tbDragonBoatInfo.tbMission = self;
	local nSkillNum = 0;
	local pItem = nil;
	local nItemId = self.tbSkillList[me.nId];
	pItem = KItem.GetObjById(nItemId);
	
	if not pItem or not me.GetItemPos(pItem) then
		self:KickPlayer(me);
		return 0;
	end
	
	Player:SetFreshState(me, 1);
	
	nSkillNum = pItem.nLevel;
	local tbProp = Esport.DragonBoat.PRODUCT_BOAT[nSkillNum];
	local nSkillId 	  = tbProp[4][1];
	local nSkillLevel = tbProp[4][2];
	local mapId, x, y = me.GetWorldPos();
	me.CastSkill(nSkillId, nSkillLevel, x, y);

	for _, nGenId in pairs(Esport.DragonBoat.GEN_SKILL_ATTACK) do
		local nUseSkillId = pItem.GetGenInfo(nGenId, 0);
		if nUseSkillId > 0 and me.IsHaveSkill(nUseSkillId) <= 0 then
			me.AddFightSkill(nUseSkillId, 1);
		end
	end
	
	for _, nGenId in pairs(Esport.DragonBoat.GEN_SKILL_DEFEND) do
		local nUseSkillId = pItem.GetGenInfo(nGenId, 0);
		if nUseSkillId > 0 and me.IsHaveSkill(nUseSkillId) <= 0 then
			me.AddFightSkill(nUseSkillId, 1);
		end
	end

	local szMsg = Esport.DragonBoat.MIS_UI[1][1]
	self:OpenSingleUi(me, szMsg, Esport.DragonBoat.MIS_LIST[1][2]);
	table.insert(self.tbRankList, {nRank=0, nTime=GetTime(), nId=me.nId, szName=me.szName, nGroupId = nGroupId});
	self:UpdateMsgUi(me, "Hãy vào vị trí xuất phát");
	me.SetCurCamp(math.fmod(nGroupId,3)+1);
	--self:UpdataAllUi();
	me.SetFightState(0);
end

function tbMission:GetRank(pPlayer)
	for _, tbRank in pairs(self.tbRankList) do
		if tbRank.nId == pPlayer.nId then
			return tbRank.nRank;
		end
	end
	return 0;
end

function tbMission:GetCurRank(pPlayer)
	for nRank, tbRank in pairs(self.tbRankList) do
		if tbRank.nId == pPlayer.nId then
			return nRank;
		end
	end
	return 0;
end

function tbMission:GetRankListWithOutMe(pMePlayer)
	local tbOnLineRankList = {};
	for _, tbList in ipairs(self.tbRankList) do
		local pPlayer = KPlayer.GetPlayerObjById(tbList.nId)
		if pPlayer and pMePlayer.nId ~= pPlayer.nId and self:GetPlayerGroupId(pPlayer) >= 0 and tbList.nRank < Esport.DragonBoat.DEF_FINISH_RANK then
			table.insert(tbOnLineRankList, {nRank = tbList.nRank, nId = tbList.nId, nTime = tbList.nTime});
		end
	end
	table.sort(tbOnLineRankList, OnSort);
	return tbOnLineRankList;
end

function tbMission:GetRankList()
	local tbOnLineRankList = {};
	for _, tbList in ipairs(self.tbRankList) do
		local pPlayer = KPlayer.GetPlayerObjById(tbList.nId)
		if pPlayer and self:GetPlayerGroupId(pPlayer) >= 0 and tbList.nRank < Esport.DragonBoat.DEF_FINISH_RANK then
			table.insert(tbOnLineRankList, {nRank = tbList.nRank, nId = tbList.nId, nTime = tbList.nTime});
		end
	end
	table.sort(tbOnLineRankList, OnSort);
	return tbOnLineRankList;
end

function tbMission:SetRank(nRank)
	for _, tbRank in pairs(self.tbRankList) do
		if tbRank.nId == me.nId then
			tbRank.nRank = nRank;
			tbRank.nTime = GetTime();
			break;
		end
	end
	self:UpdataAllUi();
end

function tbMission:SetObjTime(nTime)
	self.tbObjList[me.nId] = nTime;
end

function tbMission:GetObjTime()
	return self.tbObjList[me.nId] or 0;
end

function tbMission:OnLeave(nGroupId, szReason)
	me.GetTempTable("Esport").tbDragonBoatInfo = {};
	Esport.DragonBoat:ClearAllSkill(me);
	self:CloseSingleUi(pPlayer);
	me.SetFightState(0);
	me.SetLogoutRV(0);
	Player:SetFreshState(me, 0);
	if self.tbOnLevelMision then
		Lib:CallBack(self.tbOnLevelMision);
	end
	if self:GetPlayerCount(nGroupId) == 0 and self.nMissionCloseFlag == 0 then -- 全队早退会输掉比赛
		-- 不是混战赛的话如果有一方队员全部退出了那么就比赛结束
		if self.nMatchType and self.nMatchType == 2 then	
			if (self:GetPlayerCount(0) > 0) then
				return 0;
			end
		end
		self.nMissionCloseFlag = 1;
		self:OnGameOver();
	end
end

function tbMission:UpdataAllUi()
	
	table.sort(self.tbRankList, OnSort);
	local tbMsg = {};
	for _, tbList in ipairs(self.tbRankList) do
		table.insert(tbMsg, {szName = tbList.szName, nRank = tbList.nRank});
	end

	local tbScore = { 10,8,7,6,5,4,3,1 };
	
	for _, tbList in ipairs(self.tbRankList) do
		local pPlayer = KPlayer.GetPlayerObjById(tbList.nId)
		if pPlayer and self:GetPlayerGroupId(pPlayer) >= 0 then
			local szMsg = "Hạng    Người chơi";
			if (self.nMatchType > 2) then
				szMsg = szMsg .. "    Điểm"
			end
			szMsg = szMsg .. "\n";
			szMsg = string.format("%s <color=white>", szMsg);
			for nRank, tbName in ipairs(tbMsg) do
				local szName 	 = tbName.szName;
				local szRankName = nRank.." - "..szName;
				if (self.nMatchType > 2) then
					szRankName = szRankName .. " " .. tbScore[nRank] or 0;
				end
				if tbName.nRank >= Esport.DragonBoat.DEF_FINISH_RANK then
					szRankName = szRankName .. "<Hoàn thành>";
				end
				if pPlayer.szName == szName then
					szRankName = string.format("<color=yellow>%s<color>", szRankName);
				end
				szMsg = string.format("%s\n%s",szMsg, szRankName);
			end
			self:UpdateMsgUi(pPlayer, szMsg);
		end
	end	
end

--开启界面
function tbMission:OpenSingleUi(pPlayer, szMsg, nLastFrameTime)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SetBattleTimer(pPlayer,  szMsg, nLastFrameTime);
	Dialog:ShowBattleMsg(pPlayer,  1,  0); --开启界面
end

--关闭界面
function tbMission:CloseSingleUi(pPlayer)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:ShowBattleMsg(pPlayer,  0,  0); -- 关闭界面
end

--更新界面时间
function tbMission:UpdateTimeUi(pPlayer, szMsg, ...)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SetBattleTimer(pPlayer,  szMsg, unpack(arg));
end

--更新界面信息
function tbMission:UpdateMsgUi(pPlayer, szMsg)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SendBattleMsg(pPlayer, szMsg, 1);
end

-- 每组的名字
function tbMission:AddGroupName(pPlayer, nGroupId, szGroupName)
	if szGroupName then
		self.tbGroupName[nGroupId] = szGroupName;
		return;
	end
	
	if self.tbGroupName[nGroupId] then
		return;
	end
	if pPlayer.nTeamId == 0 then
		self.tbGroupName[nGroupId] = pPlayer.szName;
	else
		local tbPlayerList = KTeam.GetTeamMemberList(pPlayer.nTeamId);
		local pCaptin = KPlayer.GetPlayerObjById(tbPlayerList[1]);
		if pCaptin then
			self.tbGroupName[nGroupId] = pCaptin.szName;
		else
			self.tbGroupName[nGroupId] = pPlayer.szName;
		end
	end
end

function tbMission:GetResult()
	return self.tbResultRank or {};
end
