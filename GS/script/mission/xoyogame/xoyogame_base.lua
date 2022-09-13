--
-- 逍遥谷闯关活动脚本
-- Trap点加载
XoyoGame.BaseGame = Mission:New();
local BaseGame = XoyoGame.BaseGame;

BaseGame.TSK_GROUP_TASK_MAIN	= 1025;
BaseGame.TSK_GROUP_TASK_SUB		= 89;
BaseGame.TASK_MAIN_ID			= "214";
BaseGame.TASK_SUB_ID			= "2EE";
BaseGame.TASK_STEP				= 1;

local tbTrap = {}
-- 玩家触发trap点
function tbTrap:OnPlayerTrap(szClassName)
	if not self.tbGame then
		return 0;
	end
	
	local tbRoom = self.tbGame:GetPlayerRoom(me.nId);
	if tbRoom and tbRoom.OnPlayerTrap then
		tbRoom:OnPlayerTrap(szClassName);
	elseif self.tbGame.tbTrap[szClassName] then
		me.NewWorld(me.nMapId, unpack(self.tbGame.tbTrap[szClassName]));
	end
end

-- 定义玩家进入地图事件
function tbTrap:OnEnter()
	if (not self.tbGame) or (not self.nMapId) then
		return 0;
	end
	self.tbGame:JoinNextGame(me);
end

-- 定义玩家离开地图事件
function tbTrap:OnLeave()

end

-- 初始化地图
function BaseGame:MapInit(nMapId)
	local tbMapTrap = Map:GetClass(nMapId);
	for szFnc in pairs(tbTrap) do			-- 复制函数
		tbMapTrap[szFnc] = tbTrap[szFnc];
	end
	tbMapTrap.tbGame = self;
	tbMapTrap.nMapId = nMapId;
end

-- 初始化关卡 
function BaseGame:InitGame(tbMap, nCityMapId)
	--新加入了6，7，8关卡，每个关卡的地图组是个table，所以进行特殊处理
	for i = 1, #tbMap do
		if type(tbMap[i]) == "table" then
			for _,nMapId in pairs(tbMap[i]) do
				self:MapInit(nMapId);
			end
		else
			self:MapInit(tbMap[i]);
		end
	end
	self.nGameId = nCityMapId;
	self.tbMap = tbMap;
	self.tbRoom = {};			-- 房间对象表
	self.tbTrap = {};			-- Trap点传送
	self.tbTeam = {};			-- 队伍信息
	self.tbPlayer = {};			-- 玩家所在房间信息
	self.tbNextGameTeam = {};
	self.nNextTeamCount = 0;
	self.tbAddXoyoTimesPlayerId = {};   -- 已扣除逍遥次数的玩家id，防刷
	
	self.tbMisCfg = 
	{
		tbLeavePos	= {[1] = {nCityMapId, unpack(XoyoGame.LEAVE_POS[nCityMapId])}},	-- 离开坐标
		tbDeathRevPos = {{tbMap[1], 49088 / 32,	74208 / 32}},		-- 死亡重生点
		nDeathPunish = 1,
		nPkState = Player.emKPK_STATE_PRACTISE,
		nInLeagueState = 1,
		nLogOutRV = Mission.LOGOUTRV_DEF_XOYO,
	}
	self:Open();
end

-- 报名下次闯关(不检查资格,资格检查在npc逻辑上做)  -- TODO
function BaseGame:JoinNextGame(pPlayer)
	local nTeamId = pPlayer.nTeamId;
	if self.tbTeam[nTeamId] then
		return 0;
	end
	if nTeamId ~= 0 then
		if self.tbNextGameTeam[nTeamId] == nil and self.nNextTeamCount < XoyoGame.MAX_TEAM then
			self.tbNextGameTeam[nTeamId] = 1
			self.nNextTeamCount = self.nNextTeamCount + 1;
			KStatLog.ModifyAdd("xoyogame", "Tổ đội tham gia Tiêu Dao Cốc trong ngày", "Tổng", 1);
		elseif self.tbNextGameTeam[nTeamId] then
			self.tbNextGameTeam[nTeamId] = self.tbNextGameTeam[nTeamId] + 1;
		else
			pPlayer.Msg("Tổ đội tham gia đủ số lượng!")
		end
	else
		print("Đã vào Tiêu Dao Cốc", pPlayer.szName);
		Dbg:WriteLog("XoyoGame", "Đã vào Tiêu Dao Cốc");
		Dialog:SendBlackBoardMsg(pPlayer, "Nguy hiểm! Đã vào trong Tiêu Dao Cốc, về thành trong 5 giây!");
		Timer:Register(5 * Env.GAME_FPS, self.QuiteMap, self, pPlayer.nId);
		return 0;
	end
	pPlayer.GetTempTable("XoyoGame").tbGame = self;
	
	if self:GetPlayerGroupId(pPlayer) >= 0 then
		self:KickPlayer(pPlayer);
		return 0;
	end
	
	self:JoinPlayer(pPlayer, 1);
end

function BaseGame:QuiteMap(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		--pPlayer.LeaveTeam();
		pPlayer.TeamDisable(0);
		pPlayer.ForbidExercise(0);
		pPlayer.ForbidEnmity(0);
		pPlayer.NewWorld(unpack(self.tbMisCfg.tbLeavePos[1]));
	end
	return 0;
end

function BaseGame:OnJoin(nGroupId)
	me.TeamDisable(1);
	me.ForbidExercise(1);
	me.ForbidEnmity(1);
	local nLastFrameTime = 0
	if self.nTimerId and self.nTimerId > 0 then
		nLastFrameTime = tonumber(Timer:GetRestTime(self.nTimerId));
	else
		local nCurTime = tonumber(os.date("%H%M", GetTime()));
		if (nCurTime >= XoyoGame.START_TIME1 and nCurTime < XoyoGame.END_TIME1) or 
			(nCurTime >= XoyoGame.START_TIME2 and nCurTime < XoyoGame.END_TIME2) then
			-- 计算下一场的开启剩余时间
			nLastFrameTime = ((30 - (nCurTime % 100) % 30) * 60 - tonumber(os.date("%S", GetTime())) 
				+ XoyoGame.LOCK_MANAGER_TIME)* Env.GAME_FPS;
		end
	end
	if nLastFrameTime > 0 then
		Dialog:SetBattleTimer(me,  "<color=green>Thời gian báo danh còn: %s<color>", nLastFrameTime);
		Dialog:SendBattleMsg(me, "");
		Dialog:ShowBattleMsg(me,  1,  0);
	end
	me.SetTask(XoyoGame.TASK_GROUP, XoyoGame.EXCHANGE_ROOM_LEVEL, -1); -- 设-1防止在报名场地内使用传送
	--XoyoGame.Achievement:JoinGames(me);
	-- LOG 帖子的LOG
	local nCount = me.GetItemCountInBags(18,1,541,2);
	if nCount > 0 then
		StatLog:WriteStatLog("statlog", "xoyo", "Lv2Card", me.nId, nCount);
	end
end

function BaseGame:LogOutRV()
	-- 拔萝卜用到了打雪仗技能
	for _, nSkillId in pairs(Esport.tbTemplateId2Skill) do
		if me.IsHaveSkill(nSkillId) == 1 then
			me.DelFightSkill(nSkillId);
		end
	end
	
	for _, nBuffId in pairs(Esport.tbTemplateId2Buff) do
		if me.GetSkillState(nBuffId) > 0 then
			me.RemoveSkillState(nBuffId);
		end
	end
	
	me.RemoveSkillState(1450); -- 头顶的萝卜状态
	XoyoGame.RoomCarrot.DeleteCarrotInBag(me);
end

function BaseGame:GetStartLevel(nTeamId)
	local nDifficuty = XoyoGame:GetDifficuty(nTeamId);
	return XoyoGame.LevelCofig[nDifficuty][1] or 1;
end

function BaseGame:GetFinalLevel(nTeamId)
	local nDifficuty = XoyoGame:GetDifficuty(nTeamId);
	return XoyoGame.LevelCofig[nDifficuty][5] or 5;
end

function BaseGame:GetNextLevel(nTeamId)
	if not nTeamId then
		return;
	end
	local nDifficuty = XoyoGame:GetDifficuty(nTeamId);
	local nCurStep = self.tbTeam[nTeamId].nWinRoomCount or 0;
	nCurStep = nCurStep + 1;
	if nCurStep > 5 then
		nCurStep = 5;
	end
	return XoyoGame.LevelCofig[nDifficuty][nCurStep];
end

-- 开始一轮闯关
function BaseGame:StartNewGame()
	local tbTemp = {};
	self.tbAddXoyoTimesPlayerId = {};
	self:CalcRoomOccupy();
	for nTeamId, nCount in pairs(self.tbNextGameTeam) do
		XoyoGame.tbStartTime[nTeamId] = GetTime();
		table.insert(tbTemp, nTeamId);
		self.tbTeam[nTeamId] = {};
		self.tbTeam[nTeamId].nCurRoomCount = 0; -- 玩过几个房间
		self.tbTeam[nTeamId].nWinRoomCount = 0;	-- 通过几个房间
	end
	self:AddXoyoTimes(tbTemp);
	for nTeamId, nCount in pairs(self.tbNextGameTeam) do
		local nStartLevel = self:GetStartLevel(nTeamId);
		self:RandomRoom({ nTeamId }, nStartLevel);
		local tbMember, nNum = KTeam.GetTeamMemberList(nTeamId);
		for j = 1, nNum do
			local pPlayer = KPlayer.GetPlayerObjById(tbMember[j]);
			if pPlayer then
				pPlayer.SetTask(XoyoGame.TASK_GROUP, XoyoGame.ATTEND_TIME, GetTime()); -- 参加时间
				pPlayer.SetTask(XoyoGame.TASK_GROUP, XoyoGame.EXCHANGE_ROOM_LEVEL, 0);
				pPlayer.SetTask(XoyoGame.TASK_GROUP, XoyoGame.EXCHANGE_TIMES, 0);
			end
		end
		self:WriteJoinLog(nTeamId);	--游戏开启，记录队伍log
	end
	self.tbNextGameTeam = {};
	self.nNextTeamCount = 0;
	GCExcute{"XoyoGame:SyncGameData_GC", self.nGameId, 0}
	-- 给玩家一个很假的计时
	self.nTimerId = Timer:Register(XoyoGame.START_GAME_TIME * Env.GAME_FPS, self.CloseTimer, self);
end

function BaseGame:AddXoyoTimes(tbTeam)
	local fnExcute = function (pPlayer)
		self.tbAddXoyoTimesPlayerId[pPlayer.nId] = 1;
		local nTimes = XoyoGame:GetPlayerTimes(pPlayer)
		if nTimes > 0 then
			pPlayer.SetTask(XoyoGame.TASK_GROUP, XoyoGame.TIMES_ID, nTimes - 1);
		else
			Dbg:WriteLog("xoyogame", "Error 逍遥谷次数为0却仍然能进逍遥谷！");
		end
		
		-- 记录玩家参加逍遥谷的次数
		Stats.Activity:AddCount(pPlayer, Stats.TASK_COUNT_XOYOGAME, 1);
		
		-- KStatLog.ModifyAdd("xoyogame", string.format("本日参加了第%d次逍遥谷的人数", nTimes + 1), "总量", 1);
		
		--参加逍遥累积次数
		local nTimes = pPlayer.GetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_JOIN_XOYOGAME);
		pPlayer.SetTask(SpecialEvent.tbPJoinEventTimes.TASKGID, SpecialEvent.tbPJoinEventTimes.TASK_JOIN_XOYOGAME, nTimes + 1);

		-- 师徒成就：参加逍遥谷
		Achievement_ST:FinishAchievement(pPlayer.nId, Achievement_ST.XOYOGAME);
	end
	XoyoGame.BaseRoom:TeamPlayerExcute(fnExcute, tbTeam);
end

function BaseGame:CloseTimer()
	self.nTimerId = nil;
	return 0;
end

-- 看看队里有没有没扣逍遥次数的玩家
function BaseGame:CheckTeamValidity(nTeamId)
	local tbMember, nCount = KTeam.GetTeamMemberList(nTeamId);
	local nValidPlayerNum = 0;
	if not tbMember then
		print("Xoyogame","BaseGame找不到队伍");
		return 0;
	end
	for _, nPlayerId in ipairs(tbMember) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			if not self.tbAddXoyoTimesPlayerId[pPlayer.nId] then
				pPlayer.Msg("Ngươi là ai mà dám đến Tiêu Dao Cốc? Đừng tưởng rằng lão phu lớn tuổi, mắt không còn nhìn thông.");
				if  XoyoGame:GetPlayerGame(pPlayer.nId) == self then
					self:KickPlayer(pPlayer);
				else
					Setting:SetGlobalObj(pPlayer);
					self:OnLeave();
					Setting:RestoreGlobalObj();
					self:QuiteMap(pPlayer.nId);
				end
			else
				nValidPlayerNum = nValidPlayerNum + 1;
			end
		end
	end
	if nValidPlayerNum == 0 then
		return 0;
	else
		return 1;
	end
end

function BaseGame:FilterTeam(tbTeam)
	local tbRes = {};
	for _, nTeamId in ipairs(tbTeam) do
		if self:CheckTeamValidity(nTeamId) == 1 then
			table.insert(tbRes, nTeamId);
		end
	end
	
	return tbRes;
end

-- 房间等级修改为自动获取，不是传进来
function BaseGame:RandomRoom(tbTeam, nRoomLevel)
	tbTeam = self:FilterTeam(tbTeam);
	local nNextLevel = self:GetNextLevel(tbTeam[1]);
	nRoomLevel = nNextLevel or nRoomLevel;
	local tbTemp = {};
	local tbNewRooms = {};
	local tbRoomWeight = {};
	local nTotalWeight = 0;
	local nTeamCount = #tbTeam;
	-- 打乱队伍
	for i = 1, nTeamCount do
		local nRandom = MathRandom(nTeamCount);
		tbTeam[i], tbTeam[nRandom] = tbTeam[nRandom], tbTeam[i]
	end
	-- 寻找合适当前人数的房间组合
	local tbXoyoRoomWeight = XoyoGame:GetRoomWeight()[nRoomLevel];
	for nRoomId, tbWeightInfo in pairs(tbXoyoRoomWeight) do
		if not self.tbRoom[nRoomId] and tbWeightInfo.nWeight > 0 then 		-- 房间没被占用
			nTotalWeight = nTotalWeight + tbWeightInfo.nWeight;
			-- 按房间参与人数再分组
			if not tbRoomWeight[tbWeightInfo.nTeams] then
				tbRoomWeight[tbWeightInfo.nTeams] = {};
			end
			tbRoomWeight[tbWeightInfo.nTeams][nRoomId] = tbWeightInfo;
		end
	end
	-- 随机房间
	local nWhileTimes = 0;
	while (nTeamCount > 0) do
		nWhileTimes = nWhileTimes + 1;
		local nRandom = MathRandom(nTotalWeight);
		local nSumWeight = 0;
		local nRoomId = nil;
		local nTeams = nil;
		local nWeight = nil;
		
		for _nTeams, _tbWeight in pairs(tbRoomWeight) do
			for _nRoomId, _tbInfo in pairs(_tbWeight) do
				nSumWeight = nSumWeight + _tbInfo.nWeight
				if nSumWeight >= nRandom then
					if _nTeams <= nTeamCount then
						nRoomId, nTeams, nWeight = _nRoomId, _nTeams, _tbInfo.nWeight;
					end
					break;
				end
			end
			if nRoomId then break end;
		end
		
		if nRoomId then
			local tbTemp = {}
			tbTemp.nRoomId = nRoomId;
			tbTemp.tbTeam = {}
			for i = 0, nTeams - 1 do
				table.insert(tbTemp.tbTeam, tbTeam[nTeamCount - i]);
				Dbg:WriteLog("XoyoGame", tbTeam[nTeamCount - i], "分配进入"..tbTemp.nRoomId.."号房间！")
			end
			local nRet = self:AddRoom(tbTemp.nRoomId, XoyoGame:GetDifficuty(tbTeam[nWhileTimes]), unpack(tbTemp.tbTeam));
			if nRet == 1 then
				table.insert(tbNewRooms, nRoomId);
			end
			tbRoomWeight[nTeams][nRoomId] = nil;
			nTotalWeight = nTotalWeight - nWeight;
			nTeamCount = nTeamCount - nTeams;
		end
		if nWhileTimes >= 200 then
			for i = 1, nTeamCount do
				self:KickTeam(tbTeam[i], nil, "Không tìm thấy phòng thích hợp");
			end
			Dbg:WriteLog("[XoyoGame]Random Room nWhileTimes >= 100");
			break;
		end
	end
	
	-- 结束循环
	self.tbNewRooms = tbNewRooms;
	for _, nRoomId in ipairs(tbNewRooms) do
		if self.tbRoom[nRoomId] then
			local nTimerId = Timer:Register(XoyoGame.ROOM_TIME[nRoomLevel] * Env.GAME_FPS, self.EndRoomTime, self, nRoomId);
			self.tbRoom[nRoomId].nTimerId = nTimerId;
		end
	end
end

function BaseGame:EndRoomTeamProcess(tbTeams, tbNextLevel, nRoomId, nIsWinner)
	for _, nTeamId in pairs(tbTeams) do
		if self.tbTeam[nTeamId] then
			self.tbTeam[nTeamId].nCurRoomCount = self.tbTeam[nTeamId].nCurRoomCount + 1;
			if nIsWinner == 1 then
				self.tbTeam[nTeamId].nWinRoomCount = self.tbTeam[nTeamId].nWinRoomCount + 1;
			end
			self.tbRoom[nRoomId].nWinRoomCount = self.tbTeam[nTeamId].nWinRoomCount;
			self.tbRoom[nRoomId].nRoomCount = self.tbTeam[nTeamId].nCurRoomCount;
			local tbMember, nCount = KTeam.GetTeamMemberList(nTeamId);
			if not tbMember then
				return;
			end
			if self.tbTeam[nTeamId].nCurRoomCount >= XoyoGame.PLAY_ROOM_COUNT or nCount == 0 then
				for i = 1, #tbMember do
					local pPlayer = KPlayer.GetPlayerObjById(tbMember[i]);	
					if pPlayer then
						SpecialEvent.ActiveGift:AddCounts(pPlayer, 19);		--完成5逍遥谷活跃度
						SpecialEvent.BuyOver:AddCounts(pPlayer, SpecialEvent.BuyOver.TASK_TIEUDAOCOC);
					end
				end
				self:KickTeam(nTeamId, 1);
			else
				table.insert(tbNextLevel, nTeamId);
			end

			if nIsWinner == 1 then
				Dbg:WriteLog("XoyoGame", nTeamId, nRoomId .."Vào phòng thành công");
				self:WritePassLog(nRoomId,1);
			else
				Dbg:WriteLog("XoyoGame", nTeamId, nRoomId .."Vào phòng thất bại");
				self:WritePassLog(nRoomId,0);
			end
			

			--失败LOG统计
			if XoyoGame.LOG_ATTEND_OPEN == 1  and nIsWinner ~= 1 then				
				for i = 1, #tbMember do
					local pPlayer = KPlayer.GetPlayerObjById(tbMember[i]);	
					if pPlayer then
						DataLog:WriteELog(pPlayer.szName, 1, 3, nRoomId, nTeamId, 0);
					end
				end
			end				
		end
	end	
end

-- 房间时间到
function BaseGame:EndRoomTime(nRoomId)
	local tbRoomsId = { nRoomId };
	local nLevel = self.tbRoom[nRoomId].tbSetting.nRoomLevel;
	local tbUpgrateTeam = {};
	local tbStayTeam 	= {};
	local bWin = self.tbRoom[nRoomId].tbTeam[1].bIsWiner;
	local nTeamId = self.tbRoom[nRoomId].tbTeam[1].nTeamId;
	local nCurRoomCount = self.tbTeam[nTeamId].nCurRoomCount + 1;
	local nFinalLevel = self:GetFinalLevel(nTeamId);
	for i = 1, #tbRoomsId do
		if self.tbRoom[tbRoomsId[i]] then
			local tbWinner, tbLoser = self.tbRoom[tbRoomsId[i]]:CheckWinner();
			self:EndRoomTeamProcess(tbWinner, tbUpgrateTeam, tbRoomsId[i], 1); -- 队伍晋级
			self:EndRoomTeamProcess(tbLoser, tbStayTeam, tbRoomsId[i], 0); -- 留下来
			self.tbRoom[tbRoomsId[i]]:Close();
			self.tbRoom[tbRoomsId[i]] = nil;
		end
	end
	if #tbUpgrateTeam > 0 and nCurRoomCount < XoyoGame.PLAY_ROOM_COUNT then
		KStatLog.ModifyAdd("xoyogame", string.format("本日到达%s级房间的队伍", nLevel + 1), "总量", #tbUpgrateTeam);
		if (nLevel < nFinalLevel) then
			self:RandomRoom(tbUpgrateTeam, nLevel + 1);		-- 队伍房间升级
		else
			self:RandomRoom(tbUpgrateTeam, nLevel);			-- 等级不变
		end
	end
	if nCurRoomCount == XoyoGame.PLAY_ROOM_COUNT and nLevel == nFinalLevel and bWin == 1 then
		XoyoGame:CalcTotalTime(
			XoyoGame:GetDifficuty(nTeamId),
			XoyoGame.tbStartTime[nTeamId],
			nTeamId
			);
	end
	if #tbStayTeam > 0 then
		self:RandomRoom(tbStayTeam, nLevel)
	end
	return 0;
end

-- 剔除队伍
function BaseGame:KickTeam(nTeamId, bAward, szMsg)
	szMsg = szMsg or "";
	if not self.tbTeam[nTeamId] then
		return 0;
	end
	if self.tbTeam[nTeamId].nRoomId then
		local nRoomId = self.tbTeam[nTeamId].nRoomId
		if self.tbRoom[nRoomId] then
			self.tbRoom[nRoomId]:DelTeamInfo(nTeamId);
		end
	end
	local nDifficuty = XoyoGame:GetDifficuty(nTeamId);
	local tbTeamer, nCount = KTeam.GetTeamMemberList(nTeamId);	
	for i=1, nCount do
		local pPlayer = KPlayer.GetPlayerObjById(tbTeamer[i]);
		if pPlayer then
			if bAward and bAward == 1 then
				if pPlayer.AddStackItem(18,1,80,1,nil,2) ~= 2 then
					pPlayer.Msg("Hành trang không đủ ô trống!");
				end
			end
			Dialog:ShowBattleMsg(pPlayer,  0,  0); --关闭界面
			if nDifficuty ~= 9 then -- 9是简单难度，不计入侠客
				if (nDifficuty == 1 and self.tbTeam[nTeamId].nWinRoomCount >= XoyoGame.XIAKE_WIN_COUNT) or (nDifficuty > 1 and self.tbTeam[nTeamId].nWinRoomCount >= XoyoGame.XIAKE_WIN_COUNT - 1) then
					XiakeDaily:AchieveTask(pPlayer, 3, nDifficuty);
					
					--教育任务完成判断，与侠客任务判断条件一致
					local nTaskMainId = tonumber(self.TASK_MAIN_ID, 16);
					local nTaskSubId = tonumber(self.TASK_SUB_ID, 16);
					
					local tbPlayerTasks	= Task:GetPlayerTask(pPlayer).tbTasks;
					local tbTask = tbPlayerTasks[nTaskMainId];	-- 主任务ID
					
					if tbTask and tbTask.nReferId == nTaskSubId then
						if (tbPlayerTasks[nTaskMainId].nCurStep == self.TASK_STEP) then
							pPlayer.SetTask(self.TSK_GROUP_TASK_MAIN, self.TSK_GROUP_TASK_SUB, 1);
						end
					end
				end
				
				if (nDifficuty == 1 and self.tbTeam[nTeamId].nWinRoomCount >= XoyoGame.GUMUREPUTE_TASK_WIN_COUNT) or 
					(nDifficuty > 1 and self.tbTeam[nTeamId].nWinRoomCount >= XoyoGame.GUMUREPUTE_TASK_WIN_COUNT - 1) then
					Faction:AchieveTask(pPlayer, Faction.TYPE_XOYO);
				end
			end
			self:KickPlayer(pPlayer, szMsg);
			XoyoGame.Achievement:JoinGames(pPlayer);
			
			-- 激活龙珠
			if TimeFrame:GetState("Keyimen") == 1 then
				Item:ActiveDragonBall(pPlayer);
			end
		end
	end
	self.tbTeam[nTeamId] = nil;		-- 删除队伍信息
end

function BaseGame:OnLeave(nGroupId, szReason)
	local nPlayerId = me.nId;
	local nTeamId = me.nTeamId;
	if self.tbPlayer[nPlayerId] then	-- 玩家可能仍在某个房间的逻辑内
		local nRoomId = self.tbPlayer[nPlayerId];
		self.tbPlayer[nPlayerId] = nil;
		if self.tbRoom[nRoomId] then
			self.tbRoom[nRoomId]:PlayerLeaveRoom(nPlayerId);
		end
	elseif self.tbNextGameTeam[nTeamId] then
		self.tbNextGameTeam[nTeamId] = self.tbNextGameTeam[nTeamId] - 1
		if self.tbNextGameTeam[nTeamId] == 0 then
			self.tbNextGameTeam[nTeamId] = nil;
			self.nNextTeamCount = self.nNextTeamCount - 1;
			GCExcute{"XoyoGame:ReduceTeam_GC", self.nGameId};
		end
	end
	me.TeamDisable(0);
	me.ForbidExercise(0);
	me.ForbidEnmity(0);
	--me.LeaveTeam();
	me.GetTempTable("XoyoGame").tbGame = nil;
end

-- 关房间
function BaseGame:CloseRoom(nRoomId)
	if self.tbRoom and self.tbRoom[nRoomId] then
		self.tbRoom[nRoomId]:Close();
		self.tbRoom[nRoomId] = nil;
	end
end

function BaseGame:CloseGame()
	if self.tbRoom then
		for nId, _ in pairs(self.tbRoom) do
			self:CloseRoom(nId);
		end
	end
	
	if self.nEndRoomTimerId then
		Timer:Close(self.nEndRoomTimerId);
		self.nEndRoomTimerId = nil;
	end
	if self:IsOpen() == 1 then
		self:Close();
	end
end

-- 增加一个房间
function BaseGame:AddRoom(nRoomId, nDifficuty, ...)
	if self.tbRoom[nRoomId] then		-- 房间已经被占用;
		print("The Room is occupy", nRoomId, ...)
		return 0;
	end
	if not XoyoGame.RoomSetting.tbRoom[nRoomId] then	-- 没有这个配置的房间
		return 0;
	end
	local tbRoomSetting = XoyoGame.RoomSetting.tbRoom[nRoomId];
	local tbRoomExp = XoyoGame.tbRoomExp[nRoomId];

	if not XoyoGame.RoomSetting.tbRoom[nRoomId].DerivedRoom then
		self.tbRoom[nRoomId] = Lib:NewClass(XoyoGame.BaseRoom);
	else
		self.tbRoom[nRoomId] = Lib:NewClass(XoyoGame.RoomSetting.tbRoom[nRoomId].DerivedRoom);
	end
	--新加入了6，7，8关卡，每个关卡的地图组是个table，所以进行特殊处理
	if type(tbRoomSetting.nMapIndex) == "table" then
		local nIndex,nMapIndex = unpack(tbRoomSetting.nMapIndex); 
		self.tbRoom[nRoomId]:InitRoom(self, tbRoomSetting, self.tbMap[nIndex][nMapIndex], 
			nRoomId, tbRoomExp);
	else
		self.tbRoom[nRoomId]:InitRoom(self, tbRoomSetting, self.tbMap[tbRoomSetting.nMapIndex], 
			nRoomId, tbRoomExp);	
	end
	self.tbRoom[nRoomId].nDifficuty = nDifficuty;
	self.tbRoom[nRoomId]:JoinRoom(...);
	self.tbRoom[nRoomId]:Start();
	self.tbRoom[nRoomId].nStartTime = GetTime();	--记录该房间的开始时间
	self:RecordTeamInfo(nRoomId,...);
	return 1;
end


function BaseGame:RecordTeamInfo(nRoomId,...)
	if not nRoomId then
		return 0;
	end
	self.tbRoom[nRoomId].tbTeamInfo = {};
	for i = 1,#arg do 
		local tbMember,nCount = KTeam.GetTeamMemberList(arg[i]);
		self.tbRoom[nRoomId].tbTeamInfo[i] = {};
		self.tbRoom[nRoomId].tbTeamInfo[i].nCount = nCount;
		self.tbRoom[nRoomId].tbTeamInfo[i].nTeamId = arg[i];
		self.tbRoom[nRoomId].tbTeamInfo[i].tbName = {};
		for j = 1,nCount do
			local szName = KGCPlayer.GetPlayerName(tbMember[j]);
			table.insert(self.tbRoom[nRoomId].tbTeamInfo[i].tbName,szName); 
		end
	end
end

-- 统计房间的占用
function BaseGame:CalcRoomOccupy()
	local szLog = ""
	for nRoomId, _ in pairs(self.tbRoom) do
		szLog = nRoomId.."Người truyền đạt gian bị chiếm dụng ";
	end
	Dbg:WriteLog("XoyoGame", szLog)
end

function BaseGame:SetPlayerInRoom(nPlayerId, nRoomId)
	self.tbPlayer[nPlayerId] = nRoomId;
end

function BaseGame:GetPlayerRoom(nPlayerId)
	if not self.tbPlayer or not self.tbRoom then
		return nil;
	end
	local  nRoomId = self.tbPlayer[nPlayerId];
	if nRoomId then
		return self.tbRoom[nRoomId];
	end
	return nil;
end

function BaseGame:__TeamJoinNextGame(nTeamId)
	local tbMember, nCount = KTeam.GetTeamMemberList(nTeamId);
	for i = 1, nCount do
		local pPlayer = KPlayer.GetPlayerObjById(tbMember[i])
		if pPlayer then
			self:KickPlayer(pPlayer);
			self:JoinNextGame(pPlayer);
		end
	end
end

--开启后写log
function BaseGame:WriteJoinLog(nTeamId)
	if not nTeamId then
		return;
	end
	local pLeader = nil;
	local tbMember, nCount = KTeam.GetTeamMemberList(nTeamId);
	for i = 1, nCount do
		local pPlayer = KPlayer.GetPlayerObjById(tbMember[i]);
		if pPlayer then
			if pPlayer.IsLeader() == 1 then
				pLeader = pPlayer;
				break;
			end
		end
	end
	local nDifficuty = XoyoGame:GetDifficuty(nTeamId);
	StatLog:WriteStatLog("stat_info", "xoyo", "join", pLeader and pLeader.nId or 0,nDifficuty,nTeamId,nCount);
end

--房间结束后写log
function BaseGame:WritePassLog(nRoomId,nResult)
	local nTimeUsed = GetTime() - self.tbRoom[nRoomId].nStartTime or 0;
	local szUsed = os.date("%M分%S秒", nTimeUsed);
	if not self.tbRoom[nRoomId] or not self.tbRoom[nRoomId].tbTeamInfo then
		return 0;
	end
	for i = 1,#self.tbRoom[nRoomId].tbTeamInfo do
		local nTeamId = self.tbRoom[nRoomId].tbTeamInfo[i].nTeamId or 0;
		local nCount = self.tbRoom[nRoomId].tbTeamInfo[i].nCount or 0;
		local nDifficuty = self.tbRoom[nRoomId].nDifficuty or 0;
		local tbName = self.tbRoom[nRoomId].tbTeamInfo[i].tbName or {""};
		StatLog:WriteStatLog("stat_info", "xoyo", "room_pass", 0,nResult,nTeamId,nCount,nRoomId,nDifficuty,szUsed,unpack(tbName));
	end
end

-- 测试房间用,实际功能不需要
function BaseGame:TestRoom(nMap, tbMap, nRoomId, nDifficuty)
	if me.nTeamId == 0 then
		return 0;
	end
	self:CloseRoom(nRoomId);
	self:InitGame(tbMap, nMap);
	self:__TeamJoinNextGame(me.nTeamId);
	self.tbTeam[me.nTeamId] = {};
	self.tbTeam[me.nTeamId].nCurRoomCount = XoyoGame.PLAY_ROOM_COUNT - 1;
	self.tbTeam[me.nTeamId].nWinRoomCount = 0;
	self:AddRoom(nRoomId, nDifficuty, me.nTeamId);
	local nRoomLevel = XoyoGame.RoomSetting.tbRoom[nRoomId].nRoomLevel;
	self.nEndRoomTimerId = Timer:Register(XoyoGame.ROOM_TIME[nRoomLevel] * Env.GAME_FPS, self.EndRoomTime, self, nRoomId);
	self.tbRoom[nRoomId].nTimerId = self.nEndRoomTimerId;
	XoyoGame.tbStartTime[me.nTeamId] = GetTime();
end

-- 
function BaseGame:TestGame(nMap, tbMap)
	if me.nTeamId == 0 then
		return 0;
	end
	self:InitGame(tbMap, nMap);
	self:JoinNextGame(me);
	self:StartNewGame();
end

--[[
function BaseGame:TestPKRoom(nMap, tbMap, nRoomId, nRoomLevel, nTeamId2)
	local nTeamId1 = me.nTeamId
	if nTeamId1 == 0 or not nTeamId2 then
		return 0;
	end
	
	self:CloseRoom(nRoomId);
	self:InitGame(tbMap, nMap);
	self:__TeamJoinNextGame(nTeamId1);
	self:__TeamJoinNextGame(nTeamId2);
	
	self.tbTeam[nTeamId1] = {};
	self.tbTeam[nTeamId1].nCurRoomCount = XoyoGame.PLAY_ROOM_COUNT - 1;
	self.tbTeam[nTeamId2] = {};
	self.tbTeam[nTeamId2].nCurRoomCount = XoyoGame.PLAY_ROOM_COUNT - 1;
	self:AddRoom(nRoomId, nTeamId1, nTeamId2);
	self.nEndRoomTimerId  = Timer:Register(XoyoGame.ROOM_TIME[nRoomLevel] * Env.GAME_FPS, self.EndRoomTime, self, {nRoomId}, nRoomLevel);
	self.tbRoom[nRoomId].nTimerId = self.nEndRoomTimerId;
end
--]]



