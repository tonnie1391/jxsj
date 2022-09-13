--- 领土争夺战 基础功能脚本
--- zhengyuhua

Domain.Base = {};
local tbBase = Domain.Base;

function tbBase:InitGame(nMapId, nLevel)
	self.nMapId 		= nMapId;
	self.nLevel			= nLevel;
	self.tbPlayer 		= {};		-- 征战玩家表
	self.tbTongOrUnion	= {}; 		-- 参与争夺帮会或联盟信息
	self.tbTowerNpc 	= {}; 		-- 标志NPC
	self.tbZhaohuan		= {};		-- 召唤NPC
	self.tbBoss			= {};		-- BOSS
	--self.tbBaolei		= {};		-- 堡垒NPC
	self.tbSort			= {};		-- 帮会排序
	self.tbDefendNpc	= {};		-- 保护NPC
	self.tbTongToUnion	= {};		-- 帮会联盟对应表
	self.nDataAvailFrame= 1;		-- 同步给客户端数据的有效时间
	self.nDomainId		= Domain:GetMapDomain(nMapId);					-- 领土区域ID
	self.nDefendUnion	= 0;
	self.nCountryId		= Domain:GetDomainCountry(self.nDomainId)
	self.tbNpcPos		= Domain:GetNpcPosTable(nMapId);				-- NPC坐标点
	self.tbCenterRange	= Domain:GetCenterRange(self.nDomainId);		-- 中心区域
	self.bIsCaptainCity = 0;											-- 是否主城
	self.bReact			= 0;											-- 是否反扑
	self.nWinId			= 0;											-- 胜利ID（可能帮会，可能联盟）
	self.nState 		= Domain.PRE_BATTLE_STATE;
end

-- 开启领土战
function tbBase:StartGame()
	-- 标志开启状态
	self.nState = Domain.BATTLE_STATE;
	self.nDefendTong	= Domain:GetDomainOwner(self.nDomainId);		-- 防守方
	if Domain:GetDomainType(self.nDomainId) == "village" then
		self.nDefendTong = 0;		-- 新手村默认由NPC防守
	end
	local pTong = KTong.GetTong(self.nDefendTong);
	if pTong then
		if pTong.GetBelongUnion() ~= 0 then
			self.nDefendUnion = pTong.GetBelongUnion();
		end
	else
		if KUnion.GetUnion(self.nDefendTong) then
			self.nDefendUnion = self.nDefendTong
		end
		self.nDefendTong = 0;
	end
	if pTong and pTong.GetCapital() == self.nDomainId then
		self.bIsCaptainCity = 1;		-- 标志主城
	end
	local tbMap = Map:GetClass(self.nMapId);	
	if tbMap then
		-- 注册进入地图回调
		tbMap:RegisterMapEnterFun("DomainBattle", Domain.OnEnterMap, Domain, self.nMapId);
		-- 注册离开地图回调
		tbMap:RegisterMapLeaveFun("DomainBattle", Domain.OnLeaveMap, Domain, self.nMapId);
		-- 注册禁止使用复活
		Map:RegisterMapForbidReviveType(self.nMapId, 0, 1, "Trong Lãnh thổ chiến, tất cả các bản đồ chinh chiến sẽ không thể sử dụng Cửu Chuyển Tục Mệnh Hoàn để hồi sinh!")
	end
	self:AddNpc();
	self:ChangeMapPlayer();
end

-- 进入休战期
function tbBase:StopGame()
	self.nDataAvailFrame = Env.GAME_FPS * Domain.DATA_AVAIL_TIME;
	for nPlayerId, tbInfo in pairs(self.tbPlayer) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer and tbInfo.bInGame == 1 then		-- 所有玩家都离开征战
			self:LeaveGame(pPlayer);
		end
	end
	-- 判断胜负
	self.nWinId = self.nDefendTong == 0 and self.nDefendUnion or self.nDefendTong;
	if #self.tbSort > 0 then
		self.nWinId = self.tbSort[1];
	end
	if self.nWinId == self.nDefendUnion and self.nWinId ~= 0 and self.nDefendTong ~= 0 then
		Domain:SetDomainOwner_GS1(self.nDomainId, self.nDefendTong)
	else
		Domain:SetDomainOwner_GS1(self.nDomainId, self.nWinId)
	end
	self.nState = Domain.STOP_STATE;			-- 休战期
	self:ChangeMapPlayer();
	self:DelNpc(1);					-- 删除NPC
end

-- 结束领土战
function tbBase:EndGame()
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for i, pPlayer in pairs(tbPlayer) do
		self:LeaveGame(pPlayer);
	end
	local tbMap = Map:GetClass(self.nMapId);
	if tbMap then
		-- 反注册进入地图回调
		tbMap:UnregisterMapEnterFun("DomainBattle");
		-- 反注册离开地图回调
		tbMap:UnregisterMapLeaveFun("DomainBattle");
		-- 反注册动态禁止复活操作
		Map:UnRegisterMapForbidReviveType(self.nMapId)
	end
	self:DelNpc(2);	
end

-- 更换加经验的标记
function tbBase:ChangeExpFlag()
	for nPlayerId, tbInfo in pairs(self.tbPlayer) do
		if tbInfo.bInGame == 1 then
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			Domain:CheckAndAddExp(pPlayer);
		end
	end
end

function tbBase:MsgToAttendPlayer(szMsg)
	for nPlayerId, tbInfo in pairs(self.tbPlayer) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer and tbInfo.bInGame == 1 then
			pPlayer.Msg(szMsg);
		end
	end
end

function tbBase:MsgToMapPlayer(szMsg)
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId)
	if not tbPlayer then
		return;
	end
	for i = 1, #tbPlayer do
		tbPlayer[i].Msg(szMsg);
	end
end

-- 改变当前地图符合条件的玩家到正确的状态
function tbBase:ChangeMapPlayer()
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for i, pPlayer in pairs(tbPlayer) do
		self:Join2Game(pPlayer);
	end
end

-- 参与玩家死亡脚本
function tbBase:OnDeath(pKiller)
	local pPlayer = pKiller.GetPlayer();
	if not pPlayer then
		return 0;
	end
	local nSelfLevel = self:CheckScoreLevel(me);
	local nKillerLevel = self:CheckScoreLevel(pPlayer);
	if Domain.KILLER_SCORE[nKillerLevel] and Domain.KILLER_SCORE[nKillerLevel][nSelfLevel] then
		-- 加功勋
		local nScore = Domain.KILLER_SCORE[nKillerLevel][nSelfLevel] * Domain.SCORE_PER_KILL;
		local nRate = 0.1;
		if Domain.CLOSE_SHARE == 1 then
			nRate = 0;
		end
		self:AddPlayerScore(pPlayer, nScore, math.floor(nScore * nRate), " đánh bại "..Domain.KILLER_LEVEL[nSelfLevel][2]);
		self:AddTeamTask(pPlayer, Domain.KILL_PLAYER);
	end
end

function tbBase:CheckScoreLevel(pPlayer)
	if not pPlayer then
		return 0;
	end
	local nCurScore = pPlayer.GetTask(Domain.TASK_GROUP_ID, Domain.SCORE_ID);
	local nLevel = 0;
	for i = 1, #Domain.KILLER_LEVEL do
		if nCurScore >= Domain.KILLER_LEVEL[i][1] then
			nLevel = i;
		end
	end
	return nLevel;
end

-- 标志NPC死亡脚本
function tbBase:OnTowerNpcDeath(pNpc, pKiller)
	local nNpcId = pNpc.dwId;
	local pPlayer = pKiller.GetPlayer();
	local nOldType, nOldId = pNpc.GetVirtualRelation();
	local nNewType = Npc.emNPCVRELATIONTYPE_TONE;
	local nNextId = nOldId;
	local pOldOwner;
	local szOldOwnerName = "";
	local szNewOwnerName = "";
	local szOldType = "";
	local szNewType = "Bang hội";
	local szNpcName = "Long trụ"
	local szMsg = ""
	local szMapName = GetMapNameFormId(self.nMapId);
	
	if nOldType == Npc.emNPCVRELATIONTYPE_TONE then
		pOldOwner = KTong.GetTong(nOldId);
		szOldType = "Bang hội"
	else
		pOldOwner = KUnion.GetUnion(nOldId);
		szOldType = "Liên minh"
	end
	if pOldOwner then
		szOldOwnerName = pOldOwner.GetName();
	else
		szOldOwnerName = Domain.NPC_TONG_NAME[self.nCountryId];
	end
	if self.tbTowerNpc[nNpcId] then
		szNpcName = self.tbTowerNpc[nNpcId].nNpcNo.." số Long trụ";
	end
	if pPlayer and pPlayer.dwTongId ~= 0 then
		nNextId = pPlayer.dwUnionId;
		nNewType = Npc.emNPCVRELATIONTYPE_UNION;
		szNewType = "Liên minh";
		if nNextId == 0 then
			nNextId = pPlayer.dwTongId;
			nNewType = Npc.emNPCVRELATIONTYPE_TONE;
			szNewType = "Bang hội";
		end
		self:AddPlayerScore(pPlayer, Domain.SCORE_PER_TOWER, Domain.SCORE_PER_TOWER, " chiếm đánh "..szNpcName);
		self:AddTeamTask(pPlayer, Domain.KILL_TOWER);
	else
		nNewType, nNextId = pKiller.GetVirtualRelation();
	end
	if nNewType == Npc.emNPCVRELATIONTYPE_UNION and self:GetUnionId(nNextId) ~= 0 then
		szNewType = "Liên minh";
	end
	local pNewOwner = KTong.GetTong(nNextId) or KUnion.GetUnion(nNextId);
	if pNewOwner then
		szNewOwnerName = pNewOwner.GetName()
	elseif Domain.NPC_TONG_NAME[self.nCountryId] then
		szNewOwnerName = Domain.NPC_TONG_NAME[self.nCountryId];
	end
	if nNextId ~= 0 then
		szMsg = string.format("<color=green>%s<color>Chiến báo: %s chiếm thành công [%s] của <color=green>%s<color>!", 
			szMapName, szNewType, szOldOwnerName, szNpcName)
		self:Msg2TongOrUnion(nNextId, szMsg);		-- 广播
	end
	if nOldId ~= 0 and nNextId ~= nOldId then
		szMsg = string.format("<color=red>%s<color>Chiến báo: %s của <color=red>%s<color> bị [%s] chiếm đánh!", 
			szMapName, szOldType, szNpcName, szNewOwnerName)
		self:Msg2TongOrUnion(nOldId, szMsg);		-- 广播
	end
	local nScore = Domain:GetOccupyScore(0, self.tbTowerNpc[nNpcId].nDeathTimes + 1);
	self:AddTowerScore(nNextId, nScore);
	self:SyncSortInfoToPlayer();
	local nMapId, nX, nY = pNpc.GetWorldPos();
	Timer:Register(Domain.TOWER_REVIVE_TIME * Env.GAME_FPS, self.EndReviveTimer, self, nNextId, nX, nY, 
		self.tbTowerNpc[nNpcId].nDeathTimes + 1, self.tbTowerNpc[nNpcId].nNpcNo);
	self.tbTowerNpc[nNpcId] = nil;
end

function tbBase:Msg2TongOrUnion(nId, szMsg)
	if KTong.GetTong(nId) then
		KTong.Msg2Tong(nId, szMsg, 0);
	else
		Union:Msg2UnionTong(nId, szMsg, 0);
	end
end

-- 标志NPC复活
function tbBase:EndReviveTimer(nNextId, nX, nY, nDeathTimes, nNpcNo)
	if self.nState ~= Domain.BATTLE_STATE then
		return 0;
	end
	local nTemplateId = Domain.TOWER_NPC;
	if (KLib.Number2UInt(nNextId) == self.nDefendTong or KLib.Number2UInt(nNextId) == self.nDefendUnion) and 
		nNextId ~=0 and self.bIsCaptainCity == 1 then
		local pDefend = KTong.GetTong(self.nDefendTong)
		if pDefend then
			local nDomainNum = pDefend.GetDomainCount();
			if nDomainNum == 1 then	
				nTemplateId = Domain.DEFEND_TOWER_NPC_LV7;
			elseif nDomainNum == 2 then	
				nTemplateId = Domain.DEFEND_TOWER_NPC_LV5;
			elseif nDomainNum <= 4 and nDomainNum >= 3 then
				nTemplateId = Domain.DEFEND_TOWER_NPC_LV3;
			elseif nDomainNum <= 6 and nDomainNum >= 5 then
				nTemplateId = Domain.DEFEND_TOWER_NPC_LV1;
			end
		end
	end
	local pNpc = self:AddTongNpc(nTemplateId, self.nLevel, nNextId, nX, nY)
	if not pNpc then
		return 0;
	end
	local szTowerName = ""
	local pOwner = KTong.GetTong(nNextId) or KUnion.GetUnion(nNextId)
	if pOwner then
		szTowerName = pOwner.GetName();
	elseif Domain.NPC_TONG_NAME[self.nCountryId or 0] then
		szTowerName = Domain.NPC_TONG_NAME[self.nCountryId or 0];
	end
	local nNpcId = pNpc.dwId;
	pNpc.szName = szTowerName;
	pNpc.SetActiveForever(1);
	self.tbTowerNpc[nNpcId] = {};
	self.tbTowerNpc[nNpcId].nOccupyMinu = 0;		-- 占领时间
	self.tbTowerNpc[nNpcId].nDeathTimes = nDeathTimes;
	self.tbTowerNpc[nNpcId].nNpcNo = nNpcNo;
	self:UpdateMapNpcPos(pNpc)
	return 0;
end

-- 加入到战区
function tbBase:Join2Game(pPlayer)
	local nBattleRight = 0; 
	if self.nState == Domain.BATTLE_STATE then -- 征战期
		if pPlayer.GetTiredDegree1() == 2 then
			pPlayer.Msg("您太累了，已经不可以参加领土战了！");
			return;
		end
		nBattleRight = Domain:HasBattleRight(pPlayer.dwTongId, self.nMapId);
		if (nBattleRight ~= 1) then
			return 0
		end
		local nKinId, nMemberId = pPlayer.GetKinMember();
		if Kin:HaveFigure(nKinId, nMemberId, Kin.FIGURE_REGULAR) ~= 1 then
			return 0;
		end
		-- 设置征战BUF
		local pNpc = pPlayer.GetNpc();
		if pNpc then
			pNpc.SetRangeDamageFlag(1);
		end
		-- 强制联盟模式
		if pPlayer.dwUnionId ~= 0 then
			pPlayer.nPkModel = Player.emKPK_STATE_UNION;
			if Domain:GetState(pPlayer.dwUnionId) == 1 then
				pPlayer.AddSkillState(Domain.FIRST_SKILL, 5, 1, Domain.BATTLE_TIME * Env.GAME_FPS, 0, 1);
			end
		else
			pPlayer.nPkModel = Player.emKPK_STATE_TONG;
			if Domain:GetState(pPlayer.dwTongId) == 1 then
				pPlayer.AddSkillState(Domain.FIRST_SKILL, 5, 1, Domain.BATTLE_TIME * Env.GAME_FPS, 0, 1);
			end
		end
		pPlayer.nForbidChangePK = 1;
		-- 禁止仇杀
		pPlayer.ForbidEnmity(1);
		-- 死亡惩罚
		pPlayer.SetNoDeathPunish(1);
		-- 信息初始化
		Domain:CheckTask(pPlayer)
		local nPlayerId = pPlayer.nId
		if not self.tbPlayer[nPlayerId] then
			self.tbPlayer[nPlayerId] = {};
			self.tbPlayer[nPlayerId].nOnDeathRegId = 0;
		end
		self.tbPlayer[nPlayerId].bInGame = 1;
		-- 死亡脚本
		Setting:SetGlobalObj(pPlayer);
		if self.tbPlayer[nPlayerId].nOnDeathRegId ~= 0 then
			PlayerEvent:UnRegister("OnDeath", self.tbPlayer[pPlayer.nId].nOnDeathRegId);
		end
		self.tbPlayer[nPlayerId].nOnDeathRegId = PlayerEvent:Register("OnDeath", self.OnDeath, self);
		Setting:RestoreGlobalObj();
		self:SyncSortInfoToPlayer(pPlayer);		-- 同步当前地图帮会排名信息
		self:SyncMinInfoToPlayer(pPlayer, 1);	-- 同步自身帮会全局得分情况
		self:ShowNpcPos(pPlayer);				-- 同步柱子NPC小地图位置
		pPlayer.AddSkillState(Domain.DOMAIN_SKILL, 1, 1, Domain.BATTLE_TIME * Env.GAME_FPS, 0, 1);
		Player:AddProtectedState(pPlayer, 10);
		if (pPlayer.dwTongId == self.nDefendTong or (pPlayer.dwUnionId == self.nDefendUnion and self.nDefendUnion ~= 0))
			and self.bIsCaptainCity == 1 then		-- 主城防守BUF
			local pTong = KTong.GetTong(self.nDefendTong);
			if pTong then
				local nDomainNum = pTong.GetDomainCount();
				if nDomainNum == 1 then	
					pPlayer.AddSkillState(Domain.CAPTAIN_SKILL, 7, 1, Domain.BATTLE_TIME * Env.GAME_FPS, 0, 1);
				elseif nDomainNum == 2 then	
					pPlayer.AddSkillState(Domain.CAPTAIN_SKILL, 5, 1, Domain.BATTLE_TIME * Env.GAME_FPS, 0, 1);
				elseif nDomainNum <= 4 and nDomainNum >= 3 then
					pPlayer.AddSkillState(Domain.CAPTAIN_SKILL, 3, 1, Domain.BATTLE_TIME * Env.GAME_FPS, 0, 1);
				elseif nDomainNum <= 6 and nDomainNum >= 5 then
					pPlayer.AddSkillState(Domain.CAPTAIN_SKILL, 1, 1, Domain.BATTLE_TIME * Env.GAME_FPS, 0, 1);	
				end
			end
		end
		Domain:CheckAndAddExp(pPlayer);			-- 增加经验
		local nResTime = Domain:GetRestTime();
		if nResTime > 0 then
			Dialog:SendBattleMsg(pPlayer, "<color=green>Chiếm lĩnh hoặc bảo vệ Long trụ\nNhấm phím ~ để xem tình hình chiến sự<color>");
			Dialog:SetBattleTimer(pPlayer, "<color=green>Thời gian còn lại: <color=white>%s<color><color>\n", nResTime);
			Dialog:ShowBattleMsg(pPlayer, 1,  0); --开启界面
		end
		Dialog:SendBlackBoardMsg(pPlayer, "Bạn đã bước vào bản đồ chinh chiến bang hội");		-- 黑条
		
		-- 成就：参加领土争夺
		Achievement_ST:FinishAchievement(pPlayer.nId, Achievement_ST.DOMAINBATTLE);
		SpecialEvent.ActiveGift:AddCounts(pPlayer, 25);		--参加领土活跃度
	elseif self.nState == Domain.STOP_STATE then 		-- 休战期
		-- 强制练功模式
		pPlayer.nPkModel = Player.emKPK_STATE_PRACTISE
		pPlayer.nForbidChangePK = 1;
		-- 禁止仇杀
		pPlayer.ForbidEnmity(1);
		local szMsg = "Lãnh thổ tranh đoạt chiến kết thúc, bản đồ chinh chiến bước vào thời kỳ đình chiến, không thể chiến đấu với kẻ thù.";
		local pOwner = KTong.GetTong(self.nWinId) or KUnion.GetUnion(self.nWinId)
		if pOwner then
			szMsg = "Lãnh thổ tranh đoạt chiến "..pOwner.GetName().." chiến thắng, khu vực bước vào giai đoạn đình chiến!";
		end
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	end
end

function tbBase:LeaveGame(pPlayer)
	if self.nState == Domain.BATTLE_STATE then
		if self.tbPlayer and self.tbPlayer[pPlayer.nId] then
			-- 解除征战状态
			local pNpc = pPlayer.GetNpc();
			if pNpc then
				pNpc.SetRangeDamageFlag(0);
			end
			-- 解除强制帮会模式
			pPlayer.nPkModel = Player.emKPK_STATE_PRACTISE
			pPlayer.nForbidChangePK = 0;
			-- 解除禁止仇杀
			pPlayer.ForbidEnmity(0);
			-- 开启死亡惩罚
			pPlayer.SetNoDeathPunish(0);
			-- 注销死亡脚本
			local nPlayerId = pPlayer.nId;
			if self.tbPlayer[nPlayerId].nOnDeathRegId ~= 0 then
				Setting:SetGlobalObj(pPlayer);
				PlayerEvent:UnRegister("OnDeath", self.tbPlayer[pPlayer.nId].nOnDeathRegId);
				self.tbPlayer[nPlayerId].nOnDeathRegId = 0;
				Setting:RestoreGlobalObj();
			end
			self.tbPlayer[pPlayer.nId].bInGame = 0;
			self:HideNpcPos(pPlayer);				-- 隐藏区域旗子在地图的标示
			local nPreTongId = KLib.Number2UInt(pPlayer.GetTask(Domain.TASK_GROUP_ID, Domain.SCORE_TONG));
			local nBelongTongId = pPlayer.dwTongId;
			if nBelongTongId == 0 then
				local nKinId = KGCPlayer.GetKinId(pPlayer.nId);
				if nKinId and nKinId > 0 then
					local cKin = KKin.GetKin(nKinId);
					if cKin then
						nBelongTongId = cKin.GetBelongTong();
					end
				end
			end
			if nPreTongId ~= nBelongTongId then
				pPlayer.SetTask(Domain.TASK_GROUP_ID, Domain.SCORE_TONG, nBelongTongId);
				pPlayer.SetTask(Domain.TASK_GROUP_ID, Domain.SCORE_ID, 1);
			end
			local nScore = pPlayer.GetTask(Domain.TASK_GROUP_ID, Domain.SCORE_ID);
			pPlayer.RemoveSkillState(Domain.DOMAIN_SKILL);
			pPlayer.RemoveSkillState(Domain.CAPTAIN_SKILL);
			pPlayer.RemoveSkillState(Domain.FIRST_SKILL);
			Dialog:ShowBattleMsg(pPlayer, 0,  0); --关闭界面
			if nScore > 0 and self.tbPlayer[pPlayer.nId].bSyncGC == 1 and Domain.CLOSE_SYNC_TO_GC ~= 1 then
				GCExcute{"Domain:SetTongPlayerScore_GC", pPlayer.dwUnionId, nBelongTongId, pPlayer.nId, nScore}
				self.tbPlayer[pPlayer.nId].bSyncGC = 0;
			end
			pPlayer.CallClientScript({"Domain:SetDomainInfoTimeOut", self.nDataAvailFrame})
			-- TODO: 临时这么写来清除变身状态，但变身状态多了之后就必须得改了
			local nSkillId = Item:GetClass("bianshenlingpai").nSkillId
			if nSkillId then
				pPlayer.RemoveSkillState(nSkillId)			
			end
		end
	elseif self.nState == Domain.STOP_STATE then		-- 休战期
		-- 解除强制模式
		pPlayer.nForbidChangePK = 0;
		-- 解除禁止仇杀
		pPlayer.ForbidEnmity(0);
	end
end

-- 活动期间增加玩家功勋(一中心点附近一个菱形为区域)
function tbBase:AddScoreInGame()
	for nPlayerId, tbInfo in pairs(self.tbPlayer) do
		if tbInfo.bInGame == 1 then
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
			if pPlayer then
				local nMapId, nX, nY = pPlayer.GetWorldPos()
				if (nMapId == self.nMapId and 
					math.abs(self.tbCenterRange.nX - nX) + math.abs(self.tbCenterRange.nY - nY) <= self.tbCenterRange.nRange) then
					self:AddPlayerScore(pPlayer, 50, 0, "");
				end
			end
		end
	end
end

function tbBase:AddNpc()
	if not Domain.tbNpcPos[self.nMapId] then
		print("Npc pos is not exist mapId ==", self.nMapId);
		return 0;
	end
	local szTowerName = ""
	local pDefend = KUnion.GetUnion(self.nDefendUnion) or KTong.GetTong(self.nDefendTong)
	if pDefend then
		szTowerName = pDefend.GetName();
	elseif Domain.NPC_TONG_NAME[self.nCountryId or 0] then
		szTowerName = Domain.NPC_TONG_NAME[self.nCountryId or 0];
	end
	for nTemplate, tbPos in pairs(Domain.tbNpcPos[self.nMapId]) do
		for i = 1, #tbPos do
			if nTemplate == 0 then		-- 标志NPC点坐标
				local nTemplateId = Domain.TOWER_NPC;
				if self.nDefendTong ~= 0 and self.bIsCaptainCity == 1 then	-- 主城防守方NPC，也称龙柱
					local pTong = KTong.GetTong(self.nDefendTong)
					if pTong then
						local nDomainNum = pTong.GetDomainCount();
						if nDomainNum == 1 then	
							nTemplateId = Domain.DEFEND_TOWER_NPC_LV7;
						elseif nDomainNum == 2 then	
							nTemplateId = Domain.DEFEND_TOWER_NPC_LV5;
						elseif nDomainNum <= 4 and nDomainNum >= 3 then
							nTemplateId = Domain.DEFEND_TOWER_NPC_LV3;
						elseif nDomainNum <= 6 and nDomainNum >= 5 then
							nTemplateId = Domain.DEFEND_TOWER_NPC_LV1;
						end
					end
				end
				local nId = (self.nDefendUnion == 0 and self.nDefendTong or self.nDefendUnion)
				local pNpc = self:AddTongNpc(nTemplateId, self.nLevel, nId, tbPos[i].nX, tbPos[i].nY);
				if pNpc then
					local nNpcId = pNpc.dwId;
					pNpc.szName = szTowerName;
					pNpc.SetActiveForever(1);
					self.tbTowerNpc[nNpcId] = {};
					self.tbTowerNpc[nNpcId].nOccupyMinu = 0;		-- 占领时间
					self.tbTowerNpc[nNpcId].nDeathTimes = 0;		-- 死亡次数
					self.tbTowerNpc[nNpcId].nNpcNo = i;
				end
			elseif self.nDefendTong == 0 then			-- 白城
				local pNpc = self:AddTongNpc(nTemplate, self.nLevel, 0, tbPos[i].nX, tbPos[i].nY, 1, 1)
			elseif self.bReact == 1 then				-- 反扑
				local pNpc = self:AddTongNpc((tbPos[i].nReactNpcId or nTemplate), self.nLevel, 0, tbPos[i].nX, tbPos[i].nY, 1, 1)
			end
		end
	end
end

-- 增加堡垒
function tbBase:AddBaolei(nId, nMapX, nMapY)
	local pBattleNpc = KNpc.Add2(self.BATTLE_NPC_MODE_ID, 1, -1, nMapId, nMapX, nMapY);
	if not pBattleNpc then
		return 0;
	end
	
	local pDialogNpc = KNpc.Add2(self.DIALOG_NPC_MODE_ID, 1, -1, nMapId, nMapX, nMapY);
	if not pBattleNpc then
		return 0;
	end
end

-- 堡垒死亡
function tbBase:OnBaoleiDeath()
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		pNpc.Delete();
	end
end

-- 刷BOSS
function tbBase:AddBoss()
	if Domain:GetDomainType(self.nDomainId) == "village" and 
		KGblTask.SCGetDbTaskInt(DBTASK_DOMAIN_BATTLE_NO) > 2 then
		return 0;
	elseif Domain:GetDomainType(self.nDomainId) ~= "village" and
		self.nDefendTong ~= 0 then
		return 0;
	end
	local szMsg = "Tướng quân Lưu vong xuất hiện! Mau chóng đến nơi khiêu chiến!"
	local fnExcute = function (pPlayer, nNpcId, nX, nY, nPic, szName, nTime)
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
		pPlayer.SetHighLightPoint(nX, nY, nPic, nNpcId, szName, nTime);
	end
	local nTimes = Domain:GetBossTimes();
	if Domain.tbBossPos[self.nMapId] and Domain.tbBossPos[self.nMapId][nTimes] then
		for i, tbBossPos in ipairs(Domain.tbBossPos[self.nMapId][nTimes]) do
			if tbBossPos then
				local pNpc = self:AddTongNpc(tbBossPos.nTemplateId, self.nLevel, 0, tbBossPos.nX, tbBossPos.nY);
				if pNpc then
					self.tbBoss[pNpc.dwId] = 1;
					self:AttendPlayerExcute(fnExcute, pNpc.dwId, tbBossPos.nX, tbBossPos.nY, Domain.BOSS_PIC, pNpc.szName, -1)
				end
			end
		end
--		if Domain.tbDeclareDomainTong[nDomainId] then		
--			for _, nTongId in pairs(Domain.tbDeclareDomainTong[nDomainId]) do
--				KTong.Msg2Tong(nTongId, string.format(
--					"<color=green><color>战报：%s", 
--					GetMapNameFormId(self.nMapId) or "", 
--					szMsg))
--			end
--		end
	end
end

-- BOSS死亡
function tbBase:OnBossDeath(pNpc, pKiller)
	local fnExcute = function (pPlayer, nNpcId)
		pPlayer.SetHighLightPoint(0, 0, 0, nNpcId, "", 0);
	end
	if self.tbBoss[pNpc.dwId] then
		self.tbBoss[pNpc.dwId] = nil;
		self:AttendPlayerExcute(fnExcute, pNpc.dwId);
	end
end

-- TODO:死亡NPC删不掉~分两步删除~等以后NPC删除修改好之后再改回来
function tbBase:DelNpc(nStep)
	if nStep == 1 then
		for nNpcId, _ in pairs(self.tbTowerNpc) do
			local pNpc = KNpc.GetById(nNpcId)
			if pNpc then
				pNpc.Delete();
			end
		end
		for nNpcId, _ in pairs(self.tbZhaohuan) do
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				pNpc.Delete();
			end
		end
		for nNpcId, _ in pairs(self.tbBoss) do
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				pNpc.Delete();
			end
		end
		self.tbZhaohuan = nil;
		self.tbTowerNpc = nil;
	elseif nStep == 2 then
		for nNpcId, _ in pairs(self.tbDefendNpc) do
			local pNpc = KNpc.GetById(nNpcId)
			if pNpc then
				pNpc.Delete();
			end
		end
		self.tbDefendNpc = nil;
	end
end

function tbBase:GetUnionId(nTongId)
	if not self.tbTongToUnion[nTongId] then
		local pTong = KTong.GetTong(nTongId);
		if pTong then
			self.tbTongToUnion[nTongId] = pTong.GetBelongUnion();
		else
			self.tbTongToUnion[nTongId] = 0;
		end
	end
	return self.tbTongToUnion[nTongId]
end

-- 刷出帮会阵营NPC 
function tbBase:AddTongNpc(nTemplateId, nLevel, nVirtualId, nX, nY, bRevive, bRecordToDefualt)
	bRevive = bRevive or 0;
	local pNpc = KNpc.Add2(nTemplateId, nLevel, -1, self.nMapId, nX, nY, bRevive);
	if not pNpc then
		print(nTemplateId, nLevel, -1, self.nMapId, nX, nY, bRevive);
		return;
	end
	-- 设置NPC虚拟关系
	local nUnionId = 0; 
	if KUnion.GetUnion(nVirtualId) then
		nUnionId = nVirtualId;
	else
		nUnionId = self:GetUnionId(nVirtualId);
	end
	if nUnionId > 0 then		-- 该Id有联盟，设置NPC为联盟阵营
		pNpc.SetVirtualRelation(Npc.emNPCVRELATIONTYPE_UNION, nUnionId);
	else						-- 该Id有阵营，设置NPC为帮会阵营
		pNpc.SetVirtualRelation(Npc.emNPCVRELATIONTYPE_TONE, nVirtualId);
	end
	-- 设置征战BUF
	pNpc.SetRangeDamageFlag(1);
	if bRecordToDefualt and bRecordToDefualt == 1 then
		local nNpcId = pNpc.dwId;
		self.tbDefendNpc[nNpcId] = 1;		-- 记录NPC~结束领土争夺需要删除
	elseif bRecordToDefualt == 2 then
		local nNpcId = pNpc.dwId;
		self.tbZhaohuan[nNpcId] = 1;
	end
	return pNpc;
end

-- 增加帮会积分
function tbBase:AddTowerScore(nId, nScore, bSync)
	if nScore <= 0 then
		return 0;
	end
	if not self.tbTongOrUnion[nId] then
		self.tbTongOrUnion[nId] = {};
	end
	local tbSortResult = {}
	if Domain:GetState(nId) == 1 then
		nScore = nScore * 1.2;
	end
	if not self.tbTongOrUnion[nId].nScore then
		local pTong = KTong.GetTong(nId) or KUnion.GetUnion(nId);
		if nId == 0 then
			self.tbTongOrUnion[nId].szName = Domain.NPC_TONG_NAME[self.nCountryId];
		elseif pTong then
			self.tbTongOrUnion[nId].szName = pTong.GetName();
		else
			return;
		end
		self.tbTongOrUnion[nId].nScore = 0;
		self.tbTongOrUnion[nId].nSort = #self.tbSort + 1;
		table.insert(self.tbSort, nId);
		tbSortResult[nId] = self.tbTongOrUnion[nId].nSort;
	end
	self.tbTongOrUnion[nId].nScore = self.tbTongOrUnion[nId].nScore + nScore;
	tbSortResult = self:UpdateSort(nId, tbSortResult);
	Domain:AddTongScore_GS1(self.nMapId, nId, self.tbTongOrUnion[nId].nScore, tbSortResult);
end

-- 更新排名(积分只增不减的前提下)
function tbBase:UpdateSort(nId, tbSortResult)
	local nBegin = self.tbTongOrUnion[nId].nSort;
	while (nBegin > 1) do
		if self.tbTongOrUnion[self.tbSort[nBegin - 1]].nScore < self.tbTongOrUnion[nId].nScore then
			self.tbTongOrUnion[self.tbSort[nBegin - 1]].nSort = nBegin;
			self.tbTongOrUnion[nId].nSort = nBegin - 1;
			tbSortResult[self.tbSort[nBegin - 1]] = nBegin;
			tbSortResult[nId] = nBegin - 1;
			self.tbSort[nBegin - 1], self.tbSort[nBegin] = self.tbSort[nBegin], self.tbSort[nBegin - 1];
		else
			break;
		end
		nBegin = nBegin - 1;
	end
	return tbSortResult;
end

-- 同步排名数据 pPlayer缺省则同步所有玩家
function tbBase:SyncSortInfoToPlayer(pPlayer)
	if Domain.CLOSE_SYNC_INFO == 1 then
		return 0;
	end
	local tbSyncSort = {};
	for i = 1, math.min(Domain.SYNC_MAX_SORT, #self.tbSort) do
		tbSyncSort[i] = {};
		tbSyncSort[i].nScore = self.tbTongOrUnion[self.tbSort[i]].nScore;
		tbSyncSort[i].szName = self.tbTongOrUnion[self.tbSort[i]].szName;
	end
	if pPlayer then
		pPlayer.CallClientScript({"Domain:s2cBattleSortInfo", tbSyncSort});
	else
		for nPlayerId, tbInfo in pairs(self.tbPlayer) do
			local pPlayer1 = KPlayer.GetPlayerObjById(nPlayerId);
			if tbInfo.bInGame == 1 and pPlayer1 then
				pPlayer1.CallClientScript({"Domain:s2cBattleSortInfo", tbSyncSort});
			end
		end
	end
end

-- 同步全局数据 pPlayer不可省, bSync 强制同步
function tbBase:SyncMinInfoToPlayer(pPlayer, bSync)
	if Domain.CLOSE_SYNC_INFO == 1 then
		return 0;
	end
	if pPlayer then
		local nId = pPlayer.dwTongId;
		if pPlayer.dwUnionId ~= 0 then
			nId = pPlayer.dwUnionId;
		end
		local tbMinInfo, tbSortInfo = Domain:GetTongGlobalInfo(nId)
		if (bSync) or (tbMinInfo and nId ~= 0) then
			pPlayer.CallClientScript({"Domain:s2cBattleMinInfo", tbMinInfo, tbSortInfo});
		end
	end
end

-- 增加玩家功勋 
function tbBase:AddPlayerScore(pPlayer, nSelfScore, nTeamScore, szMsg)
	if not pPlayer then
		return 0;
	end
	local nSelfTongId = pPlayer.dwTongId;
	if nSelfScore <= 0 then
		return 0;
	end
	self:__AddPlayerScore(pPlayer, nSelfScore);
	pPlayer.Msg(string.format("Bạn %s nhận được<color=yellow>%d điểm<color> công trạng lãnh thổ!", szMsg, nSelfScore));
	if nTeamScore <= 0 then
		return 0;
	end
	local tbTeamPlayer, nCount = pPlayer.GetTeamMemberList();
	if tbTeamPlayer then
		for i = 1, nCount do
			-- 同地图同帮会才共享积分
			if (tbTeamPlayer[i].dwTongId == nSelfTongId and tbTeamPlayer[i].nMapId == self.nMapId and
				pPlayer.nId ~= tbTeamPlayer[i].nId) then
				self:__AddPlayerScore(tbTeamPlayer[i], nTeamScore)
				tbTeamPlayer[i].Msg(string.format("Đồng đội của bạn %s, cùng nhận được <color=yellow>%d<color> điểm công trạng lãnh thổ!", szMsg, nTeamScore));
			end
		end
	end
end

function tbBase:__AddPlayerScore(pPlayer, nAddScore)
	if not pPlayer or pPlayer.IsDead() == 1 or nAddScore <= 0 then
		return 0;
	end
	local nPreTongId = KLib.Number2UInt(pPlayer.GetTask(Domain.TASK_GROUP_ID, Domain.SCORE_TONG));
	local nCurScore = pPlayer.GetTask(Domain.TASK_GROUP_ID, Domain.SCORE_ID);
	if (0 == nCurScore) then
		-- 在玩家第一次增加功勋的时候，参战次数加1
		Stats.Activity:AddCount(pPlayer, Stats.TASK_COUNT_DOMAIN, 1);
	end
	if nPreTongId ~= pPlayer.dwTongId then
		nCurScore = 0;
		pPlayer.SetTask(Domain.TASK_GROUP_ID, Domain.SCORE_TONG, pPlayer.dwTongId);
	end
	pPlayer.SetTask(Domain.TASK_GROUP_ID, Domain.SCORE_ID, nCurScore + nAddScore);

	-- 如果积分达到800分就算记录一次参加领土战
	if (nCurScore + nAddScore >= 800) then
		if (Player:GetJoinRecord_DailyCount(pPlayer, Player.EVENT_JOIN_RECORD_LINGTUZHAN) <= 0) then
			Player:AddJoinRecord_DailyCount(pPlayer, Player.EVENT_JOIN_RECORD_LINGTUZHAN, 1);
		end
	end

	if self.tbPlayer[pPlayer.nId] then
		self.tbPlayer[pPlayer.nId].bSyncGC = 1;
	end
	return 1;
end

-- 增加玩家任务变量
function tbBase:AddTeamTask(pPlayer, nTaskId)
	if not pPlayer then
		return 0;
	end
	local nValue = pPlayer.GetTask(Domain.TASK_GROUP_ID, nTaskId);
	pPlayer.SetTask(Domain.TASK_GROUP_ID, nTaskId, nValue + 1);
	local nSelfTongId = pPlayer.dwTongId;
	if Domain.CLOSE_SHARE == 1 then
		return;
	end
	local tbTeamPlayer, nCount = pPlayer.GetTeamMemberList();
	if tbTeamPlayer then
		for i = 1, nCount do
			if tbTeamPlayer[i].dwTongId == nSelfTongId and tbTeamPlayer[i].nMapId == self.nMapId 
				and pPlayer.nId ~= tbTeamPlayer[i].nId then
				nValue = tbTeamPlayer[i].GetTask(Domain.TASK_GROUP_ID, nTaskId);
				tbTeamPlayer[i].SetTask(Domain.TASK_GROUP_ID, nTaskId, nValue + 1);
			end
		end
	end
end

-- 每分钟执行
function tbBase:ExcutePerMinute()
	local tbToAdd = {}
	if not self.tbTowerNpc then
		return;
	end
	
	for nNpcId, tbNpcInfo in pairs(self.tbTowerNpc) do
		local pNpc = KNpc.GetById(nNpcId)
		if pNpc then
			local nType, nId = pNpc.GetVirtualRelation();
			tbNpcInfo.nOccupyMinu = tbNpcInfo.nOccupyMinu + 1;
			local nScore = Domain:GetOccupyScore(tbNpcInfo.nOccupyMinu, tbNpcInfo.nDeathTimes);
			if not tbToAdd[nId] then
				tbToAdd[nId] = 0;
			end
			-- 先缓存再一次性加
			tbToAdd[nId] = tbToAdd[nId] + nScore;   -- 设置分值
		end
	end
	for nId, nAddScore in pairs(tbToAdd) do
		self:AddTowerScore(nId, nAddScore);
	end
	-- 定时加功勋
	if Domain.CLOSE_ADD_PER_MINI ~= 1 then
		self:AddScoreInGame();
	end
	-- 同步排名数据
	self:SyncSortInfoToPlayer();
end

-- 在地图上显示柱子NPC
function tbBase:ShowNpcPos(pPlayer, nTime)
	if not pPlayer then
		return 0;
	end
	if not nTime then
		nTime = Domain:GetRestTime();
		if nTime < 0 then
			return 0;
		end
		nTime = nTime / Env.GAME_FPS * 1000;
	end
	if not self.tbTowerNpc then
		print("Npc pos is not exist mapId ==", self.nMapId);
		return 0;
	end
	
	for nNpcId, tbNpcInfo in pairs(self.tbTowerNpc) do
		local pNpc = KNpc.GetById(nNpcId);
		self:UpdateNpcPos(pPlayer, nTime, tbNpcInfo.nNpcNo, pNpc);
	end
	for nNpcId, _ in pairs(self.tbBoss) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			local _, nX, nY = pNpc.GetWorldPos()
			pPlayer.SetHighLightPoint(nX, nY, Domain.BOSS_PIC, nNpcId, pNpc.szName, -1);
		end
	end
end

function tbBase:AttendPlayerExcute(fnExcute, ...)
	for nPlayerId, tbInfo in pairs(self.tbPlayer) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer and tbInfo.bInGame == 1 then
			fnExcute(pPlayer, ...);
		end
	end
end

function tbBase:UpdateMapNpcPos(pNpc, nTime)
	if not pNpc then
		print("pNpc is not exist!");
		return;
	end
	local tbNpcInfo = self.tbTowerNpc[pNpc.dwId];
	if not tbNpcInfo then
		return;
	end
	if not nTime then
		nTime = Domain:GetRestTime();
		if nTime < 0 then
			return 0;
		end
		nTime = nTime / Env.GAME_FPS * 1000;
	end
	for nPlayerId, tbInfo in pairs(self.tbPlayer) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer and tbInfo.bInGame == 1 then
			self:UpdateNpcPos(pPlayer, nTime, tbNpcInfo.nNpcNo, pNpc)
		end
	end
end

function tbBase:UpdateNpcPos(pPlayer, nTime, nNpcNo, pNpc)
	if not pPlayer then
		return 0;
	end
	if not Domain.tbNpcPos[self.nMapId] then
		print("Npc pos is not exist mapId ==", self.nMapId);
		return 0;
	end
	local tbPos = Domain.tbNpcPos[self.nMapId][0][nNpcNo];
	if pNpc then
		local _, nId = pNpc.GetVirtualRelation();
		local pOwner = KTong.GetTong(nId) or KUnion.GetUnion(nId);
		local szName = string.format("%s(%d)", (pOwner and pOwner.GetName() or Domain.NPC_TONG_NAME[self.nCountryId]), nNpcNo);
		local nPic = ((nId == pPlayer.dwTongId or (nId == pPlayer.dwUnionId and nId ~= 0)) and Domain.TOWER_SELF_PIC or Domain.TOWER_ENEMY_PIC);
		pPlayer.SetHighLightPoint(tbPos.nX, tbPos.nY, nPic, 100+nNpcNo, szName, nTime);
	end
end

-- 在地图上隐藏柱子NPC
function tbBase:HideNpcPos(pPlayer)
	if not pPlayer then
		return 0;
	end
	if not Domain.tbNpcPos[self.nMapId] then
		print("Npc pos is not exist mapId ==", self.nMapId);
		return 0;
	end
	for i, tbPos in pairs(Domain.tbNpcPos[self.nMapId][0]) do
		pPlayer.SetHighLightPoint(tbPos.nX, tbPos.nY, 0, 100+i, "", 0);
	end
	for nNpcId, _ in pairs(self.tbBoss) do
		pPlayer.SetHighLightPoint(0, 0, 0, nNpcId, "", 0);
	end
end


