-------------------------------------------------------
-- 文件名　 : superbattle_gs.lua
-- 创建者　 : zhangjinpin@kingsoft
-- 创建时间 : 2011-06-02 15:30:39
-- 文件描述 :
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\superbattle\\superbattle_def.lua");

-------------------------------------------------------
-- 启动相关
-------------------------------------------------------

-- gs启动战场
function SuperBattle:StartGame_GS(nServerId)
	
	-- 服务器号不匹配
	if nServerId ~= GetServerId() then
		return 0;
	end
	
	-- 已经有战场，开启失败
	if self.tbMissionGame and self.tbMissionGame:IsOpen() ~= 0 then
		GCExcute({"SuperBattle:StartGameFailed_GA", nServerId});
		return 0
	end
	
	-- 初始化几个表
	self.tbPole = {};
	self.tbAdmiral = {};
	self.tbMarshal = {};
	self.tbPlayerData = {};
	self.tbSortPlayer = {};
	self.tbCampData = 
	{
		[1] = {nPoint = 0, nCamp = 0, nPlayer = 0}, 
		[2] = {nPoint = 0, nCamp = 0, nPlayer = 0},
	};
	
	-- 创建mission
	self.tbMissionGame = Lib:NewClass(self.Mission);
	self.tbMissionGame:InitGame(self.BATTLE_MAP[nServerId]);
	
	-- 启动计时器
	self:StartTimer(self.UPDATE_TIME, self.TimerUpdate, "update");
	
	-- 通知gc成功
	GCExcute({"SuperBattle:StartGameSuccess_GA", nServerId});
end

-- 结束游戏
function SuperBattle:StopGame_GS(nWinner)
	
	-- 玩家排名
	self.tbSortPlayer = {};
	for szPlayerName, tbInfo in pairs(self.tbPlayerData) do
		table.insert(self.tbSortPlayer, {szPlayerName = szPlayerName, nPoint = tbInfo.nPoint, nOccupy = tbInfo.nOccupy, nCamp = tbInfo.nCamp, szGateway = tbInfo.szGateway});
	end
	table.sort(self.tbSortPlayer, function(a, b) return a.nPoint > b.nPoint end);
	
	-- 设置奖励
	for i, tbInfo in ipairs(self.tbSortPlayer) do
		
		-- 大于1500分才获得奖励
		local nRst = tbInfo.nPoint >= self.MIN_POINT and self:CalcPlayerResult(i, #self.tbSortPlayer) or 0;
		local nExp = tbInfo.nPoint >= self.MIN_POINT and self:CalcPlayerExp(i, #self.tbSortPlayer) or 0;
		local nRepute = self:CalcPlayerRepute(i, tbInfo.nPoint);
		GCExcute({"SuperBattle:SetPlayerResult_GA", tbInfo.szPlayerName, tbInfo.nPoint, i, nRst, nExp, tbInfo.szGateway, nRepute});
		local szMsg = string.format("Chiến thắng vẻ vang nhận được <color=yellow>%s điểm<color> chiến tích, hạng: <color=yellow>%s<color>, điểm xếp hạng: <color=yellow>%s<color>, kinh nghiệm đạt được: <color=yellow>%s phút<color>, Uy danh: <color=yellow>%s<color>.", tbInfo.nPoint, i, nRst, nExp, nRepute);
		self:SendMessage_GS(tbInfo.szPlayerName, self.MSG_CHANNEL, szMsg);
		
		-- stat log
		local pPlayer = KPlayer.GetPlayerByName(tbInfo.szPlayerName);
		if pPlayer then
			-- task1
			if pPlayer.GetTask(1022, 233) == 1 and tbInfo.nOccupy >= 1 and tbInfo.nPoint >= 1500 then
				SetPlayerSportTask(pPlayer.nId, self.GA_TASK_GID, self.GA_TASK_TASK1, 1);
			-- task2
			elseif pPlayer.GetTask(1022, 234) == 1 and tbInfo.nCamp == nWinner then
				SetPlayerSportTask(pPlayer.nId, self.GA_TASK_GID, self.GA_TASK_TASK2, 1);
			end
			SuperBattle:StatLog("score", pPlayer.nId, self:GetSession(), tbInfo.nCamp, i, tbInfo.nPoint, nRst, nExp, pPlayer.nFaction, pPlayer.nRouteId);
		end
	end
	
	-- 关闭游戏
	if self.tbMissionGame then
		self.tbMissionGame:Close();
		self.tbMissionGame = nil;
	end
	
	-- 清地图npc
	for _, nMapId in pairs(self.BATTLE_MAP) do
		if SubWorldID2Idx(nMapId) >= 0 then		
			ClearMapNpc(nMapId);
		end
	end
	
	-- 关闭计时器
	for szType, _ in pairs(self.tbTimerId) do
		self:ClearTimer(szType);
	end
	
	-- 通知gc成功
	GCExcute({"SuperBattle:StopGameSuccess_GA", GetServerId()});
end

-------------------------------------------------------
-- 报名相关
-------------------------------------------------------

-- 战斗力判定
function SuperBattle:CheckPower(pPlayer)
	local nFightPower = pPlayer.GetTask(self.TASK_GID, self.TASK_FIGHTPOWER);
	local nCurPower = Player.tbFightPower:GetFightPower(pPlayer);
	if math.abs(nFightPower - nCurPower) > self.MAX_OFFSET then
		self:SendMessage(pPlayer, self.MSG_MIDDLE, "Sự chênh lệch sức mạnh quá lớn.");
		return 0;
	end
	return 1;
end

-- 当日参加场次
function SuperBattle:GetAttendCount(pPlayer)
	local nAttDay = GetPlayerSportTask(pPlayer.nId, self.GA_TASK_GID, self.GA_TASK_DAY) or 0;
	local nAttCount = GetPlayerSportTask(pPlayer.nId, self.GA_TASK_GID, self.GA_TASK_COUNT) or 0;
	if nAttDay < tonumber(GetLocalDate("%Y%m%d")) then
		return 0;
	end
	return nAttCount;
end

-- 判断是否可以报名
function SuperBattle:CheckSignup_GS(pPlayer)
	
	-- 停止报名
	if self:CheckIsSignup() ~= 1 then
		self:SendMessage(pPlayer, self.MSG_MIDDLE, "Chiến trường vẫn chưa đến lúc báo danh.");
		return 0;
	end
	
	-- gm
	if pPlayer.GetCamp() == 6 then
		return 1;
	end
	
	-- 等级限制
	if pPlayer.nLevel < 100 then
		self:SendMessage(pPlayer, self.MSG_MIDDLE, "Đẳng cấp còn quá thấp!");
		return 0;
	end
	
	-- 门派限制
	if pPlayer.nFaction <= 0 then
		self:SendMessage(pPlayer, self.MSG_MIDDLE, "Chưa gia nhập môn phái.");
		return 0;
	end
	
	-- 判断披风(雏凤)
	-- local pItem = pPlayer.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MANTLE, 0);
	-- if not pItem or pItem.nLevel < SuperBattle.MANTLE_LEVEL then
		-- self:SendMessage(pPlayer, self.MSG_MIDDLE, "Phi phong không đủ để tham gia!");
		-- return 0;
	-- end
	
	-- 参加的场次
	if self:GetAttendCount(pPlayer) >= self.MAX_ATT_DAY then
		self:SendMessage(pPlayer, self.MSG_MIDDLE, string.format("Hôm nay đã tham gia <color=yellow>%s<color>, mai hãy quay lại", self.MAX_ATT_DAY));
		return 0;
	end
	
	-- 报名间隔
	if GetTime() - pPlayer.GetTask(self.TASK_GID, self.TASK_INTERAL) < self.INTERAL_TIME then
		self:SendMessage(pPlayer, self.MSG_MIDDLE, "Hãy kiên nhẫn chờ đợi thêm!");
		return 0;
	end

	return 1;
end

-- 玩家报名参战
function SuperBattle:SignupBattle_GS(pPlayer, nSure)
	if self:CheckSignup_GS(pPlayer) == 1 then
		local nSignOk = pPlayer.GetTask(self.TASK_GID, self.TASK_SIGNUP);
		if nSignOk >= 3 and EventManager.IVER_bOpenTiFu ~= 1 then
			if not nSure then
				Setting:SetGlobalObj(pPlayer);
				local szMsg = string.format("Hôm nay đã báo danh <color=yellow>%s lần<color>, để báo danh thêm cần tiêu hao <color=yellow>%s điểm<color> Uy danh. Ngươi chắc chứ?", nSignOk, self.REPUTE_COST);
				local tbOpt =
				{
					{"<color=yellow>Đồng ý<color>", self.SignupBattle_GS, self, pPlayer, 1},
					{"Để ta suy nghĩ thêm"},
				};
				Dialog:Say(szMsg, tbOpt);
				Setting:RestoreGlobalObj(pPlayer);
				return 0;
			-- elseif pPlayer.nPrestige < self.REPUTE_COST then
				-- self:SendMessage(pPlayer, self.MSG_MIDDLE, "对不起，你的威望不足，无法报名。");
				-- return 0;
			else
				local nPrestige = math.max(pPlayer.nPrestige - self.REPUTE_COST, 0);
				KGCPlayer.SetPlayerPrestige(pPlayer.nId, nPrestige);
			end
		end
		local nCurPower = me.GetTask(Player.tbFightPower.TASK_GROUP, Player.tbFightPower.TASK_FIGHTPOWER);
		GCExcute({"SuperBattle:SignupBattle_GC", pPlayer.szName, math.floor(nCurPower / 100)});
	end
end

-- 报名成功
function SuperBattle:SignupBattleSuccess_GS(szPlayerName)
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if pPlayer then
		local szMsg = "Đăng ký thành công, vui lòng đợi sắp xếp.";
		self:SendMessage(pPlayer, self.MSG_BOTTOM, szMsg);
		self:SendMessage(pPlayer, self.MSG_CHANNEL, szMsg);
		pPlayer.SetTask(self.TASK_GID, self.TASK_INTERAL, GetTime());
	end
end

-- 报名失败
function SuperBattle:SignupBattleFailed_GS(szPlayerName, nType)
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if pPlayer then
		local szMsg = "";
		if nType == 1 then
			szMsg = "Mông Cổ-Tây Hạ Liên Server bạn đăng ký đã khai chiến, đến Đảo Anh Hùng để tham chiến.";
		elseif nType == 2 then
			szMsg = "Đã đăng ký thành công, vui lòng đợi sắp xếp.";
		end
		self:SendMessage(pPlayer, self.MSG_BOTTOM, szMsg);
		self:SendMessage(pPlayer, self.MSG_CHANNEL, szMsg);
	end
end

-- 进入站场
function SuperBattle:EnterBattle_GS(pPlayer)
	GCExcute({"SuperBattle:EnterBattle_GA", pPlayer.szName});
end

-- 进入成功
function SuperBattle:EnterBattleSuccess_GS(szPlayerName, tbInfo)
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if pPlayer and self:CheckPower(pPlayer) == 1 then
		local nMapId = self.BATTLE_MAP[tbInfo.nServerId];
		local nRand = MathRandom(1, #self.CAMP_POS[tbInfo.nCamp]);
		local nMapX, nMapY = unpack(self.CAMP_POS[tbInfo.nCamp][nRand]);
		pPlayer.NewWorld(nMapId, nMapX, nMapY);
	end
end

-- 进入失败
function SuperBattle:EnterBattleFailed_GS(szPlayerName)
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if pPlayer then
		local szMsg = "Bạn chưa đăng ký hoặc chiến trường chưa mở, hãy tiếp tục đợi.";
		self:SendMessage(pPlayer, self.MSG_BOTTOM, szMsg);
		self:SendMessage(pPlayer, self.MSG_CHANNEL, szMsg);
	end
end

-- 取消报名
function SuperBattle:CancelSignup_GS(pPlayer)
	GCExcute({"SuperBattle:CancelSignup_GC", pPlayer.szName});
end

-- 取消报名成功
function SuperBattle:CancelSignupSuccess_GS(szPlayerName)
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if pPlayer then
		local szMsg = "Hủy bỏ vào đội chiến trường liên server.";
		self:SendMessage(pPlayer, self.MSG_BOTTOM, szMsg);
		self:SendMessage(pPlayer, self.MSG_CHANNEL, szMsg);
	end
end

-- 取消报名失败
function SuperBattle:CancelSignupFailed_GS(szPlayerName, nType)
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if pPlayer then
		if nType == 1 then
			local szMsg = "Mông Cổ Tây Hạ Liên Server mà bạn đăng ký đã khiêu chiến, hãy đến Đảo Anh Hùng để tham chiến càng sớm càng tốt.";
			self:SendMessage(pPlayer, self.MSG_BOTTOM, szMsg);
			self:SendMessage(pPlayer, self.MSG_CHANNEL, szMsg);		
		end
	end
end

-- 开启成功
function SuperBattle:StartGameSuccess_GS(szPlayerName)
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if pPlayer then
		local szMsg = "Mông Cổ Tây Hạ Liên Server mà bạn đăng ký đã khiêu chiến, hãy đến Đảo Anh Hùng để tham chiến càng sớm càng tốt.";
		self:SendMessage(pPlayer, self.MSG_BOTTOM, szMsg);
		self:SendMessage(pPlayer, self.MSG_CHANNEL, szMsg);
		pPlayer.AddSkillState(SuperBattle.IN_BUFFER_ID, 1, 1, 45 * 60 * Env.GAME_FPS, 1, 0, 1);
		pPlayer.SetTask(self.TASK_GID, self.TASK_SIGNUP, pPlayer.GetTask(self.TASK_GID, self.TASK_SIGNUP) + 1);
	end
end

-- 打开界面或者请求状态
function SuperBattle:SelectState_GS(pPlayer, nOnlyApplyState)
	GCExcute({"SuperBattle:SelectState_GC", pPlayer.szName, nOnlyApplyState});
end

function SuperBattle:SelectStateResult_GS(szPlayerName, nType, nOnlyApplyState)
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if pPlayer then
		local nOpen = self:CheckIsOpen();
		local nAttend = self:GetAttendCount(pPlayer);
		local nQueue = GetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_QUEUE);
		if nOnlyApplyState == 1 then
			local nTime = 0;
			if nType == 3 then
				local _, _, nFrame = pPlayer.GetSkillState(SuperBattle.IN_BUFFER_ID);
				nTime = math.max(math.floor((nFrame or 0) / Env.GAME_FPS) - 1800, 0);
			end
			pPlayer.CallClientScript({"Ui:ServerCall", "UI_FUBEN_INFO", "OnGlobalSongJinUpdate",nOpen, nAttend, nQueue, nType, nTime});
		else
			if nType == 1 then
				pPlayer.CallClientScript({"UiManager:OpenWindow", "UI_SPBATTLE_SIGNUP"});
				pPlayer.CallClientScript({"Ui:ServerCall", "UI_SPBATTLE_SIGNUP", "OnRecvData", nOpen, nAttend, nQueue, 0});
			elseif nType == 2 then
				pPlayer.CallClientScript({"UiManager:OpenWindow", "UI_SPBATTLE_SIGNUP"});
				pPlayer.CallClientScript({"Ui:ServerCall", "UI_SPBATTLE_SIGNUP", "OnRecvData", nOpen, nAttend, nQueue, 1});
			elseif nType == 3 then
				local _, _, nFrame = pPlayer.GetSkillState(SuperBattle.IN_BUFFER_ID);
				local nTime = math.max(math.floor((nFrame or 0) / Env.GAME_FPS) - 1800, 0);
				pPlayer.CallClientScript({"UiManager:OpenWindow", "UI_SPBATTLE_TRANS"});
				pPlayer.CallClientScript({"Ui:ServerCall", "UI_SPBATTLE_TRANS", "OnRecvData", nTime});	
			end
		end
	end
end

-------------------------------------------------------
-- 数据相关
-------------------------------------------------------

-- 初始化玩家数据
function SuperBattle:InitPlayer_GS(szPlayerName, nCamp, szGateway)
	if not self.tbPlayerData[szPlayerName] then
		self.tbPlayerData[szPlayerName] = 
		{
			nCamp = nCamp,
			nPoint = 0,
			nKillCount = 0,
			nCurSeriesKill = 0,
			nMaxSeriesKill = 0,
			nRank = 0,
			nSort = 0,
			nCampPoint = 0,
			nAdmiralPoint = 0,
			nMarshalPoint = 0,
			nOccupy = 0,
			szGateway = szGateway,
			nMedicine = 2,
		};
	end
end

-- 获取玩家数据
function SuperBattle:GetPlayerData(pPlayer)
	return self.tbPlayerData[pPlayer.szName];
end

-- 获取阵营名称
function SuperBattle:GetCampName(nCamp)
	return self.CAMP_NAME[nCamp] or "Không xác định";
end

-- 获取玩家分类数据
function SuperBattle:GetPlayerTypeData(pPlayer, szType)
	if not self.tbPlayerData[pPlayer.szName] then
		return 0;
	end 
	return self.tbPlayerData[pPlayer.szName][szType] or 0;
end

-- 变更分类数据
function SuperBattle:AddPlayerTypeDate(pPlayer, szType, nData)
	if self.tbPlayerData[pPlayer.szName] then
		self.tbPlayerData[pPlayer.szName][szType] = (self.tbPlayerData[pPlayer.szName][szType] or 0) + nData;
	end
end

-- 增加玩家积分
function SuperBattle:AddPlayerPoint(pPlayer, nPoint)
	local tbPlayerData = self:GetPlayerData(pPlayer);
	if tbPlayerData then
		tbPlayerData.nPoint = tbPlayerData.nPoint + nPoint;
		self:AddCampPlayerPoint(tbPlayerData.nCamp, nPoint);
		for i = 1, #self.RANK_POINT do
			if tbPlayerData.nPoint < self.RANK_POINT[i][1] then
				tbPlayerData.nRank = i - 1;
				break;
			end
		end
		if tbPlayerData.nPoint >= self.RANK_POINT[#self.RANK_POINT][1] then
			tbPlayerData.nRank = #self.RANK_POINT;
		end
	end
	pPlayer.CallClientScript({"TestFlyChar", 25, nPoint});
end

-- 获取阵营数据
function SuperBattle:GetCampData(nCamp)
	return self.tbCampData[nCamp];
end

-- 获取披风等级
function SuperBattle:GetMantleLevel(pPlayer)
	local pItem = pPlayer.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MANTLE, 0);
	return pItem and pItem.nLevel or 0;
end

-- 增加阵营积分
function SuperBattle:AddCampPoint(nCamp, nPoint)
	local tbCampData = self:GetCampData(nCamp);
	if tbCampData then
		tbCampData.nCamp = tbCampData.nCamp + nPoint;
		tbCampData.nPoint = tbCampData.nPoint + nPoint;
	end
end

-- 增加阵营玩家积分
function SuperBattle:AddCampPlayerPoint(nCamp, nPoint)
	local tbCampData = self.tbCampData[nCamp];
	if tbCampData then
		tbCampData.nPlayer = tbCampData.nPlayer + nPoint;
		tbCampData.nPoint = tbCampData.nPoint + nPoint;
	end
end

-- 连斩处理
function SuperBattle:AddPlayerKill(pPlayer, nSeriesKill)
	local tbPlayerData = self:GetPlayerData(pPlayer);
	if tbPlayerData then
		tbPlayerData.nKillCount = tbPlayerData.nKillCount + 1;
		if nSeriesKill == 1 then
			tbPlayerData.nCurSeriesKill = tbPlayerData.nCurSeriesKill + 1;
			if tbPlayerData.nCurSeriesKill > tbPlayerData.nMaxSeriesKill then
				tbPlayerData.nMaxSeriesKill = tbPlayerData.nCurSeriesKill;
			end
			pPlayer.ShowSeriesPk(1, tbPlayerData.nCurSeriesKill, 60);
		else
			tbPlayerData.nCurSeriesKill = 1;
		end
	end
end

-- 杀人处理
function SuperBattle:OnKillPlayer(pKiller, pDied)
	
	-- 处理杀人数
	local nSeriesKill = pKiller.GetTask(self.TASK_GID, self.TASK_SERIES_KILL);
	self:AddPlayerKill(pKiller, nSeriesKill);
	
	-- 处理连斩
	if nSeriesKill ~= 1 then
		pKiller.SetTask(self.TASK_GID, self.TASK_SERIES_KILL, 1);
	end
	
	-- 死亡连斩清0
	pDied.SetTask(self.TASK_GID, self.TASK_SERIES_KILL, 0);
	
	-- buffer
	local nDiedLevel = pDied.GetSkillState(self.DIE_BUFFER_ID);
	if nDiedLevel < 0 then
		nDiedLevel = 0;
	end
	if nDiedLevel < 20 then
		pDied.AddSkillState(self.DIE_BUFFER_ID, nDiedLevel + 1, 1, 5 * 60 * Env.GAME_FPS, 1, 1);
	end
	
	local nKillLevel = pKiller.GetSkillState(self.DIE_BUFFER_ID);
	pKiller.RemoveSkillState(self.DIE_BUFFER_ID);
	if nKillLevel > 5 then
		pKiller.AddSkillState(self.DIE_BUFFER_ID, nKillLevel - 5, 1, 5 * 60 * Env.GAME_FPS, 1, 1);
	end
	
	-- 放刷设置
	local tbKilled = pKiller.GetTempTable("SuperBattle").tbKilled or {};
	if tbKilled[pDied.szName] then
		tbKilled[pDied.szName] = tbKilled[pDied.szName] + 1;
	else
		if Lib:CountTB(tbKilled) == 3 then
			for szKName, _ in pairs(tbKilled) do
				tbKilled[szKName] = nil;
				break;
			end
		end
		tbKilled[pDied.szName] = 1; 
	end
	pKiller.GetTempTable("SuperBattle").tbKilled = tbKilled;
	
	if tbKilled[pDied.szName] > 3 then
		return 0;
	end
	
	-- 计算积分
	local nDiedPoint = self:GetPlayerTypeData(pDied, "nPoint");
	local nKillerPoint = self:GetPlayerTypeData(pKiller, "nPoint");
	local nPoint = math.floor(self.KILL_PLAYER_POINT * ((nDiedPoint + self.KILL_PLAYER_POINT) / (nKillerPoint + self.KILL_PLAYER_POINT)) ^ 0.5);
	
	-- 增加积分
	self:AddPlayerPoint(pKiller, nPoint);
	self:SendMessage(pKiller, self.MSG_CHANNEL, string.format("Lập đại công! Nhận được <color=yellow>%s điểm<color> chiến tích!", nPoint));
	
	-- 队友共享
	if pKiller.nTeamId then
		local tbMemberId, nMemberCount = KTeam.GetTeamMemberList(pKiller.nTeamId);
		if tbMemberId and nMemberCount > 1 then
			local nTmpPoint = math.floor(nPoint * self.SHARE_TEAM_RATE);
			local szMsg = string.format("Đồng đội lập đại công! bạn nhận được <color=yellow>%s điểm<color> chiến tích chia sẻ!", nTmpPoint);
			local tbPlayerList = KPlayer.GetAroundPlayerList(pKiller.nId, 50);
			for _, pTmpPlayer in pairs(tbPlayerList or {}) do
				for _, nMemberId in pairs(tbMemberId) do
					local pMember = KPlayer.GetPlayerObjById(nMemberId);
					if pMember and pMember.szName == pTmpPlayer.szName and pMember.szName ~= pKiller.szName then
						self:AddPlayerPoint(pMember, nTmpPoint);
						self:SendMessage(pMember, self.MSG_CHANNEL, szMsg);
					end
				end
			end
		end
	end
	
	-- 连斩积分
	if self:GetPlayerTypeData(pKiller, "nCurSeriesKill") >= self.BASE_SERIES_KILL then
		local nExtPoint = math.floor(nPoint * self.SERIES_KILL_RATE);
		self:AddPlayerPoint(pKiller, nExtPoint);
		self:SendMessage(pKiller, self.MSG_CHANNEL, string.format("Lập liên trảm, nhận <color=yellow>%s điểm<color> chiến tích!", nExtPoint));
	end
end

-- 更新计时器
function SuperBattle:TimerUpdate()
	return self:UpdateInfo();
end

-- 更新数据
function SuperBattle:UpdateInfo()

	if self.tbMissionGame and self.tbMissionGame:IsOpen() ~= 0 then
		
		-- 15秒更新一次
		self._nFlag = (self._nFlag or 0) + 1;
		if self._nFlag > self.MAX_OVERFLOW then
			self._nFlag = self._nFlag - self.MAX_OVERFLOW;
		end
		
		-- 更新积分
		if math.mod(self._nFlag, 3) == 1 then
			self:UpdatePoint();
		end
		
		-- 玩家排名
		self.tbSortPlayer = {};
		for szPlayerName, tbInfo in pairs(self.tbPlayerData) do
			table.insert(self.tbSortPlayer, {szPlayerName = szPlayerName, nPoint = tbInfo.nPoint});
		end
		table.sort(self.tbSortPlayer, function(a, b) return a.nPoint > b.nPoint end);
		
		-- 记录排名
		for i, tbInfo in ipairs(self.tbSortPlayer) do
			if self.tbPlayerData[tbInfo.szPlayerName] then
				self.tbPlayerData[tbInfo.szPlayerName].nSort = i;
			end
		end
		
		-- 更新npc
		self:UpdateNpcState();
		
		-- 更新头衔
		self.tbMissionGame:UpdatePlayerRank();
		
		-- 右侧信息
		self.tbMissionGame:UpdateAllRightUI();
		
		-- 同步战报
		self.tbMissionGame:TimerSyncReportData();
		
		-- 小地图
		self.tbMissionGame:UpdateMiniMap();
		
		SetMapHighLightPointEx(self.tbMissionGame.nMapId, 5, 12, 6000, 0, 1, 1);
		SetMapHighLightPointEx(self.tbMissionGame.nMapId, 5, 12, 6000, 0, 1, 2);
	end
	
	return self.UPDATE_TIME;
end

-- 更新积分
function SuperBattle:UpdatePoint()
	
	if self.tbMissionGame and self.tbMissionGame:IsOpen() ~= 0 then

		-- 营地分，护卫营地分
		if self.tbMissionGame.nWarState >= self.WAR_CAMPFIGHT then
			for nNpcDwId, tbInfo in pairs(self.tbPole) do
				-- 个人护卫积分
				local tbPlayerList = KNpc.GetAroundPlayerList(nNpcDwId, SuperBattle.PROTECT_DISTANCE);
				for _, pPlayer in pairs(tbPlayerList or {}) do
					local tbPlayerData = self:GetPlayerData(pPlayer);
					if tbPlayerData and tbPlayerData.nCamp == tbInfo.nOwner then
						self:AddPlayerPoint(pPlayer, self.POLE_PROTECT_POINT);
						self:AddPlayerTypeDate(pPlayer, "nCampPoint", self.POLE_PROTECT_POINT);
						self:SendMessage(pPlayer, self.MSG_CHANNEL, string.format("Có công hộ kỳ, nhận %s điểm chiến tích.", self.POLE_PROTECT_POINT));
					end
				end
				-- 军团积分
				self:AddCampPoint(tbInfo.nOwner, self.POLE_CAMP_POINT);
			end
		end
			
		-- 将军分，护卫将军分
		if self.tbMissionGame.nWarState == self.WAR_ADMIRAL then
			for nNpcDwId, tbInfo in pairs(self.tbAdmiral) do
				-- 个人护卫积分
				local tbPlayerList = KNpc.GetAroundPlayerList(nNpcDwId, SuperBattle.PROTECT_DISTANCE);
				for _, pPlayer in pairs(tbPlayerList or {}) do
					local tbPlayerData = self:GetPlayerData(pPlayer);
					if tbPlayerData and tbPlayerData.nCamp == tbInfo.nCamp then
						self:AddPlayerPoint(pPlayer, self.ADMIRAL_PROTECT_POINT);
						self:AddPlayerTypeDate(pPlayer, "nAdmiralPoint", self.ADMIRAL_PROTECT_POINT);
						self:SendMessage(pPlayer, self.MSG_CHANNEL, string.format("Có công hộ vệ Chiến tướng, nhận %s điểm chiến tích.", self.ADMIRAL_PROTECT_POINT));
					end
				end
				-- 军团积分
				self:AddCampPoint(tbInfo.nCamp, self.ADMIRAL_CAMP_POINT);
			end
		end
			
		-- 护卫元帅分
		if self.tbMissionGame.nWarState == self.WAR_MARSHAL then
			for nNpcDwId, tbInfo in pairs(self.tbMarshal) do
				-- 个人护卫积分
				local tbPlayerList = KNpc.GetAroundPlayerList(nNpcDwId, SuperBattle.PROTECT_DISTANCE);
				for _, pPlayer in pairs(tbPlayerList or {}) do
					local tbPlayerData = self:GetPlayerData(pPlayer);
					if tbPlayerData and tbPlayerData.nCamp == tbInfo.nCamp then
						self:AddPlayerPoint(pPlayer, self.MARSHAL_PROTECT_POINT);
						self:AddPlayerTypeDate(pPlayer, "nMarshalPoint", self.MARSHAL_PROTECT_POINT);
						self:SendMessage(pPlayer, self.MSG_CHANNEL, string.format("Có công hộ vệ Nguyên Soái, nhận %s điểm chiến tích.", self.MARSHAL_PROTECT_POINT));
					end
				end
			end
		end
	end	
end

-------------------------------------------------------
-- 营地相关
-------------------------------------------------------

-- 添加营地旗子
function SuperBattle:AddPole(nNpcId, nMapId, nMapX, nMapY, nOwner, nIndex)
	local pNpc = KNpc.Add2(nNpcId, self.NPC_LEVEL, -1, nMapId, nMapX, nMapY);
	if pNpc then
		if not self.tbPole[pNpc.dwId] then
			self.tbPole[pNpc.dwId] = {};
		end
		self.tbPole[pNpc.dwId].nNpcId = nNpcId;
		self.tbPole[pNpc.dwId].nMapId = nMapId;
		self.tbPole[pNpc.dwId].nMapX = nMapX;
		self.tbPole[pNpc.dwId].nMapY = nMapY;
		self.tbPole[pNpc.dwId].nIndex = nIndex;
		self.tbPole[pNpc.dwId].nOwner = nOwner;		-- 当前归属
		self.tbPole[pNpc.dwId].nFight = 0;			-- 争夺状态
		self.tbPole[pNpc.dwId].nNext = 0;			-- 未来归属
		self.tbPole[pNpc.dwId].nBaby = 0;			-- 护卫数
		self.tbPole[pNpc.dwId].tbBaby = nil;		-- 护卫表
		pNpc.szName = string.format("Chiến kỳ-%s", self.CAMP_NAME[nOwner] or "");
	end
end

-- 清除旗子
function SuperBattle:ClearPole()
	for nNpcDwId, tbInfo in pairs(self.tbPole) do
		local pNpc = KNpc.GetById(nNpcDwId);
		if pNpc then
			pNpc.Delete();
		end
		for _, nBabyDwId in pairs(tbInfo.tbBaby or {}) do
			local pNpc = KNpc.GetById(nBabyDwId);
			if pNpc then
				pNpc.Delete();
			end
		end
	end
	self.tbPole = {};
end

-- 夺旗判定
function SuperBattle:CheckOccupyPole(pPlayer, nNpcDwId)
	local tbPlayerData = self:GetPlayerData(pPlayer);
	if not tbPlayerData then
		return 0;
	end
	local tbPole = self.tbPole[nNpcDwId];
	if not tbPole then
		return 0;
	end
	if tbPole.nOwner == 0 then
		return 1;
	elseif tbPole.nOwner == tbPlayerData.nCamp then
		if tbPole.nFight == 1 then
			return 1;
		end
	else
		if tbPole.nFight == 0 then
			return 1;
		end
	end
	return 0;
end

-- 夺旗处理
function SuperBattle:OccupyPole(pPlayer, nNpcDwId)
	
	local tbPlayerData = self:GetPlayerData(pPlayer);
	local tbPole = self.tbPole[nNpcDwId];
	
	if tbPole.nOwner == 0 then
		self:AddPlayerTypeDate(pPlayer, "nOccupy", 1);
		SuperBattle:StatLog("res_fight", pPlayer.nId, self:GetSession(), tbPole.nIndex, tbPlayerData.nCamp, tbPole.nOwner);
		tbPole.nOwner = tbPlayerData.nCamp;
		local pNpc = KNpc.GetById(nNpcDwId);
		if pNpc then
			local szMsg = string.format("%s <color=yellow>%s<color> chiếm đóng %s!", self:GetCampName(tbPlayerData.nCamp), pPlayer.szName, pNpc.szName);
			self.tbMissionGame:BroadCastMission(self.MSG_BOTTOM, szMsg);
			self.tbMissionGame:BroadCastMission(self.MSG_CHANNEL, szMsg);
			pNpc.Delete();
		end
		local nNpcId = self.POLE_POS[tbPole.nIndex]["tbCamp"][tbPlayerData.nCamp];
		self:AddPole(nNpcId, tbPole.nMapId, tbPole.nMapX, tbPole.nMapY, tbPlayerData.nCamp, tbPole.nIndex);	
		self.tbPole[nNpcDwId] = nil;

	elseif tbPole.nOwner == tbPlayerData.nCamp then
		tbPole.nFight = 0;
		tbPole.nNext = 0;
		tbPole.nBaby = 0;
		for _, nBabyDwId in pairs(tbPole.tbBaby) do
			local pNpc = KNpc.GetById(nBabyDwId);
			if pNpc then
				pNpc.Delete();
			end
		end
		tbPole.tbBaby = nil;
	else
		tbPole.nFight = 1;
		tbPole.nNext = tbPlayerData.nCamp;
		tbPole.tbBaby = {};
		local tbTmp = {{-4, 0}, {4, 0}, {-2, -5}, {-2, 4}, {2, -4}, {2, 4}};
		for i = 1, #tbTmp do
			local pNpc = KNpc.Add2(self.NPC_POLE_BABY_ID[tbPole.nOwner], self.NPC_LEVEL, -1, tbPole.nMapId, tbPole.nMapX + tbTmp[i][1], tbPole.nMapY + tbTmp[i][2]);
			if pNpc then
				pNpc.GetTempTable("SuperBattle").nRootNpcDwId = nNpcDwId;
				pNpc.SetVirtualRelation(Player.emKPK_STATE_EXTENSION, tbPole.nOwner);
				table.insert(tbPole.tbBaby, pNpc.dwId);
				tbPole.nBaby = tbPole.nBaby + 1;
			end	
		end
		local szMsg = string.format("%s <color=yellow>%s<color> tấn công %s!", self:GetCampName(tbPlayerData.nCamp), pPlayer.szName, self.POLE_POS[tbPole.nIndex].szName);
		self.tbMissionGame:BroadCastMission(self.MSG_BOTTOM, szMsg);
		self.tbMissionGame:BroadCastMission(self.MSG_CHANNEL, szMsg);
	end
end

-- 旗子护卫死亡
function SuperBattle:OnBabyDeath(pPlayer, pNpc)
	local nNpcDwId = pNpc.GetTempTable("SuperBattle").nRootNpcDwId;
	local tbPole = self.tbPole[nNpcDwId];
	if not tbPole then
		return 0;
	end
	tbPole.nBaby = tbPole.nBaby - 1;
	if tbPole.nBaby <= 0 then	
		local pNpc = KNpc.GetById(nNpcDwId);
		if pNpc then
			local szMsg = string.format("%s <color=yellow>%s<color> chiếm đóng thành công %s!", self:GetCampName(tbPole.nNext), pPlayer and pPlayer.szName or "Người bí ẩn", pNpc.szName);
			self.tbMissionGame:BroadCastMission(self.MSG_BOTTOM, szMsg);
			self.tbMissionGame:BroadCastMission(self.MSG_CHANNEL, szMsg);
			pNpc.Delete();
		end
		local nNpcId = self.POLE_POS[tbPole.nIndex]["tbCamp"][tbPole.nNext];
		self:AddPole(nNpcId, tbPole.nMapId, tbPole.nMapX, tbPole.nMapY, tbPole.nNext, tbPole.nIndex);
		if pPlayer then
			local nCamp = SuperBattle:GetPlayerTypeData(pPlayer, "nCamp"); 
			local tbPlayerList = KPlayer.GetAroundPlayerList(pPlayer.nId, 50);
			for _, pTmpPlayer in pairs(tbPlayerList or {}) do
				local nTmpCamp = SuperBattle:GetPlayerTypeData(pTmpPlayer, "nCamp"); 
				if nTmpCamp == nCamp then
					local nPoint = self.OCCUPY_POLE_POINT;
					if self:GetPlayerTypeData(pTmpPlayer, "nPoint") >= self.DECAY_POLE_POINT then
						nPoint = math.floor(nPoint / 5);
					end
					self:AddPlayerPoint(pTmpPlayer, nPoint);
					self:SendMessage(pTmpPlayer, self.MSG_CHANNEL, string.format("Đoạt kỳ thành công, nhận <color=yellow>%s điểm<color> chiến tích!", nPoint));
					self:AddPlayerTypeDate(pTmpPlayer, "nOccupy", 1);
				end
			end
			SuperBattle:StatLog("res_fight", pPlayer.nId, self:GetSession(), tbPole.nIndex, tbPole.nNext, tbPole.nOwner);	
		end
		self.tbPole[nNpcDwId] = nil;
	end
end

-- 更新营地坐标
function SuperBattle:OnUpdateMiniMap(pPlayer)
	for nNpcDwId, tbInfo in pairs(self.tbPole) do
		local pNpc = KNpc.GetById(nNpcDwId);
		if pNpc then
			local _, nMapX, nMapY = pNpc.GetWorldPos();
			pPlayer.SetHighLightPoint(nMapX, nMapY, tbInfo.nPic, nNpcDwId, tbInfo.szName, 6000);
		end
	end
	for nNpcDwId, tbInfo in pairs(self.tbAdmiral) do
		local pNpc = KNpc.GetById(nNpcDwId);
		if pNpc then
			local _, nMapX, nMapY = pNpc.GetWorldPos();
			pPlayer.SetHighLightPoint(nMapX, nMapY, tbInfo.nPic, nNpcDwId, tbInfo.szName, 6000);
		end
	end
	for nNpcDwId, tbInfo in pairs(self.tbMarshal) do
		local pNpc = KNpc.GetById(nNpcDwId);
		if pNpc then
			local _, nMapX, nMapY = pNpc.GetWorldPos();
			pPlayer.SetHighLightPoint(nMapX, nMapY, tbInfo.nPic, nNpcDwId, tbInfo.szName, 6000);
		end
	end
end

-- 清除营地坐标
function SuperBattle:ClearMiniMap(pPlayer)
	for nNpcDwId, tbInfo in pairs(self.tbPole) do
		local pNpc = KNpc.GetById(nNpcDwId);
		if pNpc then
			local _, nMapX, nMapY = pNpc.GetWorldPos();
			pPlayer.SetHighLightPoint(nMapX, nMapY, 0, nNpcDwId, "", 0);
		end
	end
	for nNpcDwId, tbInfo in pairs(self.tbAdmiral) do
		local pNpc = KNpc.GetById(nNpcDwId);
		if pNpc then
			local _, nMapX, nMapY = pNpc.GetWorldPos();
			pPlayer.SetHighLightPoint(nMapX, nMapY, 0, nNpcDwId, "", 0);
		end
	end
	for nNpcDwId, tbInfo in pairs(self.tbMarshal) do
		local pNpc = KNpc.GetById(nNpcDwId);
		if pNpc then
			local _, nMapX, nMapY = pNpc.GetWorldPos();
			pPlayer.SetHighLightPoint(nMapX, nMapY, 0, nNpcDwId, "", 0);
		end
	end
end

-- 更新npc状态
function SuperBattle:UpdateNpcState()
	for nNpcDwId, tbInfo in pairs(self.tbPole) do
		local pNpc = KNpc.GetById(nNpcDwId);
		if pNpc then
			local nPic = self.PIC_CAMP[tbInfo.nOwner];
			if tbInfo.nFight == 1 then
				nPic = self.PIC_FIGHT;
			end
			tbInfo.nPic = nPic;
			tbInfo.szName = string.format("Chiến kỳ-%s", self.CAMP_NAME[tbInfo.nOwner] or "");
		end
	end
	for nNpcDwId, tbInfo in pairs(self.tbAdmiral) do
		local pNpc = KNpc.GetById(nNpcDwId);
		if pNpc then
			local nPic = self.PIC_MARSHAL;
			if pNpc.nCurLife < tbInfo.nLife then
				nPic = self.PIC_FIGHT;
				tbInfo.nLife = pNpc.nCurLife;
			end
			tbInfo.nPic = nPic;
			tbInfo.szName = string.format("Chiến tướng-%s", self.CAMP_NAME[tbInfo.nCamp] or "");
		end
	end
	for nNpcDwId, tbInfo in pairs(self.tbMarshal) do
		local pNpc = KNpc.GetById(nNpcDwId);
		if pNpc then
			local nPic = self.PIC_MARSHAL;
			if pNpc.nCurLife < tbInfo.nLife then
				nPic = self.PIC_FIGHT;
				tbInfo.nLife = pNpc.nCurLife;
			end
			tbInfo.nPic = nPic;
			tbInfo.szName = string.format("Nguyên Soái-%s", self.CAMP_NAME[tbInfo.nCamp] or "");
		end
	end
end

-------------------------------------------------------
-- 将军元帅
-------------------------------------------------------

-- 增加将军
function SuperBattle:AddAdmiral(nNpcId, nMapId, nMapX, nMapY, nCamp, nFight)
	local pNpc = KNpc.Add2(nNpcId, self.NPC_LEVEL, -1, nMapId, nMapX, nMapY);
	if pNpc then
		if not self.tbAdmiral[pNpc.dwId] then
			self.tbAdmiral[pNpc.dwId] = {};
		end
		self.tbAdmiral[pNpc.dwId].nNpcId = nNpcId;
		self.tbAdmiral[pNpc.dwId].nMapId = nMapId;
		self.tbAdmiral[pNpc.dwId].nMapX = nMapX;
		self.tbAdmiral[pNpc.dwId].nMapY = nMapY;
		self.tbAdmiral[pNpc.dwId].nCamp = nCamp;
		self.tbAdmiral[pNpc.dwId].nLife = pNpc.nCurLife;
		if nFight == 1 then
			pNpc.SetVirtualRelation(Player.emKPK_STATE_EXTENSION, nCamp);
		end
	end
end

-- 清除将军
function SuperBattle:ClearAdmiral()
	for nNpcDwId, _ in pairs(self.tbAdmiral) do
		local pNpc = KNpc.GetById(nNpcDwId);
		if pNpc then
			pNpc.Delete();
		end
	end
	self.tbAdmiral = {};
end

-- 增加元帅
function SuperBattle:AddMarshal(nNpcId, nMapId, nMapX, nMapY, nCamp, nFight, nMove)
	local pNpc = KNpc.Add2(nNpcId, self.NPC_LEVEL, -1, nMapId, nMapX, nMapY);
	if pNpc then
		if not self.tbMarshal[pNpc.dwId] then
			self.tbMarshal[pNpc.dwId] = {};
		end
		self.tbMarshal[pNpc.dwId].nNpcDwId = pNpc.dwId;
		self.tbMarshal[pNpc.dwId].nMapId = nMapId;
		self.tbMarshal[pNpc.dwId].nMapX = nMapX;
		self.tbMarshal[pNpc.dwId].nMapY = nMapY;
		self.tbMarshal[pNpc.dwId].nCamp = nCamp;
		self.tbMarshal[pNpc.dwId].nLife = pNpc.nCurLife;
		
		if nFight == 1 then
			pNpc.SetVirtualRelation(Player.emKPK_STATE_EXTENSION, nCamp);
		end
		
		if nMove == 1 then
			pNpc.AI_ClearPath();
			pNpc.GetTempTable("Npc").tbOnArrive = {self.OnArrive, self, pNpc, nCamp};
			local tbRoute = Lib:LoadTabFile(self.CAMP_ROUTE[nCamp]);
			if tbRoute and #tbRoute > 0 then
				for i, tbInfo in ipairs(tbRoute) do
					pNpc.AI_AddMovePos(tonumber(tbInfo["PosX"]), tonumber(tbInfo["PosY"]));
				end
				pNpc.SetActiveForever(1);
				pNpc.SetNpcAI(9, 0, 0, -1, 25, 25, 25, 0, 0, 0, 0);
			end
			-- 召唤护卫
			--
			-- 自言自语
			self:StartTimer(3 * Env.GAME_FPS, self.TimerNpcChat, "NpcChat" .. pNpc.dwId, pNpc.dwId, nCamp);
		end
	end
end

-- 完成移动
function SuperBattle:OnArrive(pNpc, nCamp)
	local nNpcId = self.MARSHAL_POS[nCamp].nFight;
	local nMapId, nMapX, nMapY = pNpc.GetWorldPos();
	self:AddMarshal(nNpcId, nMapId, nMapX, nMapY, nCamp, 1);
	pNpc.Delete();
	-- 召唤战士
	local tbTmp = {{-3, 0}, {3, 0}, {0, 3}, {0, -3},{-3, 3}, {3, 3}, {3, -3}, {3, -3}};
	for i = 1, #tbTmp do
		local pTmpNpc = KNpc.Add2(self.NPC_MARSHAL_ARRIVE_ID[nCamp], self.NPC_LEVEL, -1, nMapId, nMapX + tbTmp[i][1], nMapY + tbTmp[i][2]);
		if pTmpNpc then
			pTmpNpc.SetVirtualRelation(Player.emKPK_STATE_EXTENSION, nCamp);
		end	
	end
end

-- 清除元帅
function SuperBattle:ClearMarshal()
	for nNpcDwId, _ in pairs(self.tbMarshal) do
		local pNpc = KNpc.GetById(nNpcDwId);
		if pNpc then
			pNpc.Delete();
		end
	end
	self.tbMarshal = {};
end

-------------------------------------------------------
-- 系统相关
-------------------------------------------------------

-- 消息封装
function SuperBattle:SendMessage(pPlayer, nType, szMsg)
	if nType == self.MSG_CHANNEL then
		pPlayer.Msg(szMsg);
	elseif nType == self.MSG_BOTTOM then
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	elseif nType == self.MSG_MIDDLE then
		Dialog:SendInfoBoardMsg(pPlayer, szMsg);
	end
end

-- 名字广播
function SuperBattle:SendMessage_GS(szPlayerName, nType, szMsg)
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if pPlayer then
		self:SendMessage(pPlayer, nType, szMsg);
	end
end

-- 同步一层table
function SuperBattle:SyncTable_GS(szT, k, v, nServerId)
	if nServerId and nServerId ~= GetServerId() then
		return 0;
	end
	if not self[szT] then
		self[szT] = {};
	end
	self[szT][k] = v;
end

-- 开启排队信息
function SuperBattle:OpenGameWait(pPlayer)
	Dialog:SetBattleTimer(pPlayer, "", 0);
	local szMsg = string.format("<color=green>Số người trong hàng chờ: <color=yellow>%s/%s<color>", 0, self.MIN_QUEUE);
	Dialog:SendBattleMsg(pPlayer, szMsg, 1);
	Dialog:ShowBattleMsg(pPlayer, 1, 0);
end

-- 关闭排队信息
function SuperBattle:CloseGameWait(pPlayer)
	Dialog:ShowBattleMsg(pPlayer, 0, 0);
end

-- 更新排队信息
function SuperBattle:ShowGameWait(pPlayer, nQueueLen)
	local szMsg = string.format("<color=green>Số người trong hàng chờ: <color=yellow>%s/%s<color>", nQueueLen, self.MIN_QUEUE);
	Dialog:SendBattleMsg(pPlayer, szMsg, 1);
	Dialog:ShowBattleMsg(pPlayer, 1, 0);
end

-- 同步协议
function SuperBattle:ShowGameWait_GS(szPlayerName, nQueueLen)
	local pPlayer = KPlayer.GetPlayerByName(szPlayerName);
	if pPlayer then
		self:ShowGameWait(pPlayer, nQueueLen);
	end
end

-- 记录战斗力
function SuperBattle:SetFightPower()
	local nCurPower = me.GetTask(Player.tbFightPower.TASK_GROUP, Player.tbFightPower.TASK_FIGHTPOWER);
	me.SetTask(self.TASK_GID, self.TASK_FIGHTPOWER, math.floor(nCurPower / 100));
end

-- 增加自定义头衔
function SuperBattle:AddPlayerTitle(pPlayer, nCamp)
	if not pPlayer or not self.tbPlayerData[pPlayer.szName] then
		return 0;
	end
	local nLevel = math.max(self.tbPlayerData[pPlayer.szName].nRank, 1);
	if nLevel > #self.RANK_POINT then
		nLevel = #self.RANK_POINT;
	end
	local szTitle = string.format("%s·%s", self:GetCampName(nCamp), self.RANK_POINT[nLevel][2]);
	pPlayer.AddSpeTitle(szTitle, GetTime() + 60 * 60 * 24, self.RANK_POINT[nLevel][3]);
end

-- 删除自定义头衔
function SuperBattle:RemovePlayerTitle(pPlayer, nCamp)
	if not pPlayer then
		return 0;
	end
	for i = 1, #self.RANK_POINT do	
		local szTitle = string.format("%s·%s", self:GetCampName(nCamp), self.RANK_POINT[i][2]);
		pPlayer.RemoveSpeTitle(szTitle);			
	end
end

-- npc自言自语
function SuperBattle:TimerNpcChat(nNpcDwId, nCamp)
	return self:NpcChat(nNpcDwId, nCamp);
end

function SuperBattle:NpcChat(nNpcDwId, nCamp)
	local pNpc = KNpc.GetById(nNpcDwId);
	if pNpc then
		local nRand = MathRandom(1, #self.NPC_CHAT_MSG[nCamp]);
		pNpc.SendChat(self.NPC_CHAT_MSG[nCamp][nRand]);
	end
	return 3 * Env.GAME_FPS;
end

-- 玩家退出事件
function SuperBattle:OnPlayerLogout(szReason)
	if szReason ~= "SwitchServer" then
		self:CancelSignup_GS(me);
	end
end

-------------------------------------------------------
-- buffer
-------------------------------------------------------

-- load buffer
function SuperBattle:LoadBuffer_GS()
	local tbLoadBuffer = GetGblIntBuf(self.nBufferIndex, 0);
	if tbLoadBuffer and type(tbLoadBuffer) == "table" then
		self.tbGlobalBuffer = tbLoadBuffer;
	end
end

-- clear buffer
function SuperBattle:ClearBuffer_GS()
	self.tbGlobalBuffer = {};
end

-- gs启动事件
function SuperBattle:StartEvent_GS()
	if self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	self:LoadBuffer_GS();
end

-------------------------------------------------------
-- c2s call
-------------------------------------------------------

-- 加入队列
function c2s:ApplySuperBattleJoin()
	if SuperBattle:CheckIsGlobal() ~= 1 then
		SuperBattle:SignupBattle_GS(me);
	end
end

-- 退出队列
function c2s:ApplySuperBattleCancel()
	if SuperBattle:CheckIsGlobal() ~= 1 then
		SuperBattle:CancelSignup_GS(me);
	end
end

-- 传送到英雄岛
function c2s:ApplySuperBattleTrans()
	if SuperBattle:CheckIsGlobal() ~= 1 then
		local szMapClass = GetMapType(me.nMapId) or "";
		if szMapClass ~= "village" and szMapClass ~= "city"then
			local szMsg = "Chỉ có thể sử dụng trong Thành thị và Tân thủ thôn.";
			SuperBattle:SendMessage(me, SuperBattle.MSG_BOTTOM, szMsg);
			SuperBattle:SendMessage(me, SuperBattle.MSG_CHANNEL, szMsg);
			return 0;
		end
		Transfer:NewWorld2GlobalMap(me, SuperBattle.TRANS_POS);
	end
end

-- 打开界面
function c2s:ApplySuperBattleWindow()
	SuperBattle:SelectState_GS(me);
end

-- 获取报名状态
function c2s:ApplySuperBattlePlayerState()
	SuperBattle:SelectState_GS(me, 1);
end

-- 每日事件
function SuperBattle:PlayerDailyEvent()
	me.SetTask(self.TASK_GID, self.TASK_SIGNUP, 0);
end

-- 注册每日事件
PlayerSchemeEvent:RegisterGlobalDailyEvent({SuperBattle.PlayerDailyEvent, SuperBattle});

-- 注册启动事件
ServerEvent:RegisterServerStartFunc(SuperBattle.StartEvent_GS, SuperBattle);

-- 注册同步数据
Transfer:RegisterSyncData(SuperBattle.SetFightPower, SuperBattle);

-- 注册退出事件
if SuperBattle:CheckIsGlobal() ~= 1 then
	if SuperBattle.nEventLogoutId then
		PlayerEvent:UnRegisterGlobal("OnLogout", SuperBattle.nEventLogoutId)	
	end
	SuperBattle.nEventLogoutId = PlayerEvent:RegisterGlobal("OnLogout", SuperBattle.OnPlayerLogout, SuperBattle);
end
