-------------------------------------------------------------------
--File: 	factionbattle_base.lua
--Author: 	zhengyuhua
--Date: 	2008-1-8 17:38
--Describe:	门派战逻辑
-------------------------------------------------------------------
if not FactionBattle then
	FactionBattle = {};
end
local tbBaseFaction	= FactionBattle.tbBaseFaction or {};	-- 	各门派的门派战基类
FactionBattle.tbBaseFaction = tbBaseFaction;

tbBaseFaction.tbSortFunc = {
	__lt = function(tbA, tbB)
		return tbA.nKey > tbB.nKey;
	end
};

function tbBaseFaction:init(nFaction, nMapId)
	self.tbAttendPlayer = nil;
	self.tbMapPlayer 	= nil;
	self.tbArena		= nil;				-- 各个比赛场数据表
	self.tbWinner		= {};
	self.tbNextWinner	= {};
	self.tbSort		= {};				-- 即时排序信息表
	self.tb16Player		= {};
	self.tbSportscast	= {};				-- 比赛实况表（赛程界面所需要数据）
	self.nFaction		= nFaction;			-- 门派
	self.nAttendCount	= 0;				-- 参加者计数
	self.nMapId			= nMapId			-- 竞技场地图
	self.nState			= 0;				-- 活动状态
	self.nStateJour		= 0;				-- 状态流水
	self.nIndex			= 0;
	self.nTimerId 		= 0;				-- 定时器ID
	self.nFinalWinner	= 0;
	self.nMeleeCount	= 0;
	self.nFightTimerId 	= 0;				-- 进入战斗倒计时（活动全局）
----------------------------------------------------------------------------------------------
-- 更新 2010/12/3 17:39:27xuantao
	self.tbArenaData 			= {}		-- 竞技场数据
	self.nEffictivePlayer			= 0;		-- 有效的玩家数量，用于确定奖励箱子的多少
	self.nMeleeTimerId			= 0;		-- 混战计时器
	self.nEliminationTimerId		= 0;		-- 用于判断淘汰赛是否结束的定时器的ID
	self.nChampionAwordTimerId 	= 0;		-- 每次冠军奖励都有个CD
	self.nChampionAwordCount	= 0;		-- 冠军领取的奖励次数
	self.nEliminationCount 		= 0;		-- 淘汰赛次数
	self.nFlagNpcId			= 0;		-- 旗帜NPC的ID
	self.nBoxTimerId			= 0;		-- 刷箱子的基数ID
----------------------------------------------------------------------------------------------
	self.tbRestActitive = Lib:NewClass(FactionBattle.tbBaseFactionRest);	-- 休息间活动对象
	self.tbRestActitive:InitRest(nMapId); -- 初始化
	
	-- 初始化log数据
	self.tbRoutes = KPlayer.GetFactionInfo(nFaction).tbRoutes;
	self.tbAttendRount= {};		-- 参加路线分布
	self.tbRouteKills = {};		-- 杀人数路线分布
	self.tb16Rount	  = {};		-- 16强路线分布
	self.tb8Rount	  = {};		-- 8强路线分布
end

-- 获得门派战参加者列表(没有则创建，永远不返回nil)
function tbBaseFaction:GetAttendPlayerTable()
	if not self.tbAttendPlayer then
		self.tbAttendPlayer = {}
	end
	return self.tbAttendPlayer;
end

-- 从参加者列表中寻找某玩家是否存在 return 0 or 1
function tbBaseFaction:FindAttendPlayer(nPlayerId)
	local tbPlayer = self:GetAttendPlayerTable();
	if (tbPlayer and tbPlayer[nPlayerId]) then
		return 1;
	end
	return 0;
end

-- 从参加者列表中删除某玩家（如果存在的话return 1, or return 0）
function tbBaseFaction:DelAttendPlayer(nPlayerId)
	local tbPlayer = self:GetAttendPlayerTable();

	if tbPlayer[nPlayerId] then
		tbPlayer[nPlayerId] = nil;
		self.nAttendCount = self.nAttendCount - 1;
		return 1;
	end
	return 0;
end

function tbBaseFaction:GetAttendPlayuerCount()
	if not self.nAttendCount then
		self.nAttendCount = 0;
	end
	return self.nAttendCount;
end

-- 把某玩家插入到参加者列表中(返回1 or 0, 1：插入成功,0:已存在)
function tbBaseFaction:AddAttendPlayer(nPlayerId)
	local tbPlayer = self:GetAttendPlayerTable();
	if tbPlayer[nPlayerId] then
		return 0;
	end
	if not self.nAttendCount then
		self.nAttendCount = 0;
	end
	tbPlayer[nPlayerId] = {};
	tbPlayer[nPlayerId].nScore 		= 0;	-- 混战积分	(排名依据)
	tbPlayer[nPlayerId].nArenaId 		= 0;	-- 混战区ID
	tbPlayer[nPlayerId].nTimerId		= 0;	-- 重新进入战斗状态定时ID
	tbPlayer[nPlayerId].nDeathCount	= 0;	-- 死亡次数计数
------------------------------------------------------------------------------------------
-- 新的数据段 2010/12/3 16:50:21 xuantao
	tbPlayer[nPlayerId].OnceScore 	= 0;		-- 每场的晋级积分
	tbPlayer[nPlayerId].bEffictive 		= 1;		-- 是否有效，判断是否成功报名用
	tbPlayer[nPlayerId].pTempPlayer	= nil;	-- 每一次重新分组的时候会给此值赋值
	tbPlayer[nPlayerId].nSort 		= 0;		-- 玩家的排名
	tbPlayer[nPlayerId].nCamp 		= 0;		-- 玩家被分配的阵营
	tbPlayer[nPlayerId].nSelfCamp	= nil;			-- 玩家本身的阵营
------------------------------------------------------------------------------------------
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		tbPlayer[nPlayerId].szName  = pPlayer.szName;
		tbPlayer[nPlayerId].szAccount = pPlayer.szAccount;
		local nRoute = pPlayer.nRouteId;
		if not self.tbAttendRount[nRoute] then
			self.tbAttendRount[nRoute] = 0;
		end
		self.tbAttendRount[nRoute] = self.tbAttendRount[nRoute] + 1;
	end
	self.nAttendCount = self.nAttendCount + 1;
	return 1;
end

-- 获取所有玩家列表（竞技地图内的）
function tbBaseFaction:GetMapPlayerTable()
	if not self.tbMapPlayer then
		self.tbMapPlayer = {};
		for i = 1, FactionBattle.ADDEXP_QUEUE_NUM do
			self.tbMapPlayer[i] = {};
		end
	end
	return self.tbMapPlayer;
end

-- 从所有玩家列表中删除某个玩家,nPlayerId 为空则全删
function tbBaseFaction:DelMapPlayerTable(nPlayerId)
	local tbMapPlayer = self:GetMapPlayerTable();
	for i = 1, FactionBattle.ADDEXP_QUEUE_NUM do
		if nPlayerId and tbMapPlayer[i][nPlayerId] then
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				self.tbRestActitive:LeaveEvent(pPlayer);
				self:SyncSportscast(pPlayer, 30 * 18);		-- 来开活动，活动界面仍然有效30秒  --TODO
				self:SetOutMap(pPlayer);
			end
			tbMapPlayer[i][nPlayerId] = nil;
		elseif not nPlayerId then
			for nId in pairs(tbMapPlayer[i]) do
				local pPlayer = KPlayer.GetPlayerObjById(nId);
				if pPlayer then
					self.tbRestActitive:LeaveEvent(pPlayer);
					self:SyncSportscast(pPlayer, 10 * 60 * 18);		-- 来开活动，活动界面仍然有效10分钟
					self:SetOutMap(pPlayer);
				end
				tbMapPlayer[i][nId] = nil;
			end
		end
	end
end

-- 增加玩家到所有玩家列表
function tbBaseFaction:AddMapPlayerTable(nPlayerId)
 	local nIndex = self:GetEnterIndex();
	local tbMapPlayer = self:GetMapPlayerTable();
	tbMapPlayer[nIndex][nPlayerId] = 1;
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		self:UpdateMapPlayerInfo(nPlayerId);
		FactionBattle:CheckDegree(pPlayer);
		self:SyncSportscast(pPlayer);		-- 同步界面数据
		self.tbRestActitive:JoinEvent(pPlayer); 
		self:SetInMap(pPlayer);
		local nCurPlayerCount = self:GetAttendPlayuerCount();
		local szMsg = "";
		local tbPlayer = self:GetAttendPlayerTable();
		if self.nState == FactionBattle.SIGN_UP then
			if nCurPlayerCount >= FactionBattle.MAX_ATTEND_PLAYER then
				szMsg = string.format("Lượng người đăng ký đã đạt %d, không thể đăng ký thêm.", FactionBattle.MAX_ATTEND_PLAYER);
--			elseif (Wlls:CheckFactionLimit() == 1 and pPlayer.nLevel >= FactionBattle.MAX_LEVEL) then
--				szMsg = "你已经出师了，不能再参加门派竞技";
			elseif pPlayer.nLevel < FactionBattle.MIN_LEVEL then
				szMsg = "Bạn chưa đạt cấp "..FactionBattle.MIN_LEVEL..", không thể tham gia."
			else
				self:AddAttendPlayer(nPlayerId);
				szMsg = "Bạn đã được tự động báo danh, hủy bỏ tại Quan báo danh";
				if FactionBattle.FACTIONBATTLE_MODLE == FactionBattle._MODEL_NEW then
					szMsg = "Đã vào Thi đấu môn phái chế độ mới.";
				end
			end
		elseif self.nState > FactionBattle.SIGN_UP then
			szMsg = "Thi đấu môn phái đã bắt đầu, không thể báo danh.";
		else
			return 0;
		end
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	end
end


-- 自动分配Index，实现分队列存储地图玩家，分帧+经验
function tbBaseFaction:GetEnterIndex()
	if not self.nIndex then
		self.nIndex = 0;
	end
	self.nIndex = self.nIndex + 1;
	return self.nIndex % FactionBattle.ADDEXP_QUEUE_NUM + 1;
end

-- 获得某赛场地的玩家
function tbBaseFaction:GetArenaPlayer(nArenaId)
	if not self.tbArena then
		self.tbArena = {};
	end
	if not self.tbArena[nArenaId] then
		self.tbArena[nArenaId] = {};
	end
	return self.tbArena[nArenaId];
end

-- 把某个玩家增加到某个场地列表中
function tbBaseFaction:AddArenaPlayer(nArenaId, nPlayerId)
	local tbPlayer = self:GetArenaPlayer(nArenaId);
	local tbAttendPlayer = self:GetAttendPlayerTable();
	if ((tbPlayer[nPlayerId]) or (not tbAttendPlayer[nPlayerId])) then
		return 0;
	end
	tbAttendPlayer[nPlayerId].nArenaId = nArenaId;
	tbPlayer[nPlayerId] = 1;
end

-- 从某场地中删除某个玩家
function tbBaseFaction:DelArenaPlayer(nArenaId, nPlayerId)
	if not nArenaId or not nPlayerId then
		return;
	end
	
	if (self.nState == FactionBattle.ELIMINATION and self.tbAttend) then
		for i, tbplayerId in pairs(self.tbAttend) do
			if (nPlayerId == tbplayerId[1] or nPlayerId == tbplayerId[2]) then
				local pPlayer1 = KPlayer.GetPlayerObjById(tbplayerId[1]);
				local pPlayer2 = KPlayer.GetPlayerObjById(tbplayerId[2]);
				if (pPlayer1) then
					Dialog:SendBattleMsg(pPlayer1, "");
				end;
				if (pPlayer2) then
					Dialog:SendBattleMsg(pPlayer2, "")
				end;
				self.tbAttend[i] = nil;
			end;
		end;
	end;
	
	local tbPlayer = self:GetArenaPlayer(nArenaId)
	if tbPlayer[nPlayerId] then
		tbPlayer[nPlayerId]= nil;
	end
	
end

-- 检查地图中是否已经有人存在，并做些处理 
function tbBaseFaction:CheckMap()
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for i, pPlayer in pairs(tbPlayer) do
		self:AddMapPlayerTable(pPlayer.nId);	-- 加到地图玩家列表中
	end
end

-- 分阶段定时开始
function tbBaseFaction:TimerStart(szFunction)
	local nRet;
	self.nTimerId = 0;

	if szFunction then
		local fncExcute = self[szFunction];
		if fncExcute then
			nRet = fncExcute(self);
			if nRet and nRet == 0 then	
				self:ShutDown();	-- 关闭活动
				return 0;
			end
		end
	end

	-- 状态转换
	self.nStateJour = self.nStateJour + 1;
	self.nState = FactionBattle.STATE_TRANS[self.nStateJour][1];
	
	if self.nState == FactionBattle.NOTHING or self.nState >= FactionBattle.END then	-- 未必开启或者已经结束
		self:ShutDown(1);	-- 关闭活动
		return 0;
	end
	-- 下一阶段定时
	local tbTimer = FactionBattle.STATE_TRANS[self.nStateJour];
	if not tbTimer then
		return 0;
	end
	self.nTimerId = Timer:Register(
		tbTimer[2] * Env.GAME_FPS,
		self.TimerStart,
		self,
		tbTimer[3]
	);	-- 开启新的定时
	-- 新模式，在开始的时候都要提醒
	if FactionBattle.FACTIONBATTLE_MODLE == FactionBattle._MODEL_NEW then
		local szMsgBlack = "";
		local szMsgSys = "";
		local nTime = tbTimer[2] - 30;
		if nTime < 0 then
			nTime = 1;
		end
		if self.nState == FactionBattle.SIGN_UP then
			szMsgSys = string.format("Bước vào giai đoạn 1/4 của vòng loại sau 30 giây. Chú ý, trong thể thức thi đấu mới, 4 vòng thi thăng cấp mỗi vòng đều ngẫu nhiên phân phối hai phe, căn cứ vào số lượng người khác trọng thương đạt được điểm thi đấu môn phái, tiến vào top 16.", self.nMeleeCount + 1);
			szMsgBlack = string.format("Còn 30 giây nữa sẽ tiến vào vòng 1/4");
		elseif  self.nState == FactionBattle.MELEE_REST then
			szMsgBlack = string.format("Còn 30 giây nữa sẽ tiến vào vòng %d/4", self.nMeleeCount + 1);
			szMsgSys = szMsgBlack;
		elseif self.nState == FactionBattle.READY_ELIMINATION then
			if self.nEliminationCount < 4 then
				szMsgSys = "Còn 30 giây nữa sẽ tiến vào vòng tiếp theo."
			elseif nEliminationCount == 4 then
				szMsgSys = "Còn 30 giây nữa sẽ tiến vào vòng Chung kết.";
			end
			szMsgBlack = szMsgSys;
		end
		if nTime > 0 and szMsgBlack and szMsgBlack ~= "" and szMsgSys ~= "" then
			Timer:Register(nTime * Env.GAME_FPS, self.BoardMsgToMapPlayer, self, szMsgBlack);
			Timer:Register(nTime * Env.GAME_FPS, self.MsgToMapPlayer, self, szMsgSys);
		end
	end

	self:UpdateMapPlayerInfo()
	return 0
end

-- 更新地图内玩家信息,nPlayrId为0则更新全部玩家信息
function tbBaseFaction:UpdateMapPlayerInfo(nPlayerId)
	local nRestTime = Timer:GetRestTime(self.nTimerId);
	local szMsg = ""
	local szTimeFmt = ""; 
	
	if nPlayerId and nPlayerId ~= 0 then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			Dialog:ShowBattleMsg(pPlayer, 1,  0); --开启界面
			Dialog:SendBattleMsg(pPlayer, "");
			Dialog:SetBattleTimer(pPlayer, "");
		end
	end
	
	if self.nState == FactionBattle.SIGN_UP then 
		self:UpdatePlayerTimer_SignUp(nPlayerId);
	elseif self.nState == FactionBattle.MELEE then
		self:UpdatePlayerInfo_Melee();
	elseif self.nState == FactionBattle.READY_ELIMINATION  then
		self:UpdatePlayerTimer_ReadyElimination(nPlayerId);
	elseif self.nState == FactionBattle.MELEE_REST then
		self:UpdatePlayerTimer_MeleeRest(nPlayerId);
	elseif self.nState == FactionBattle.ELIMINATION then
		self:UpdatePlayerTimer_Elimination(nPlayerId);
	elseif self.nState == FactionBattle.CHAMPION_AWARD then
		self:UpdatePlayerTimer_ChampionAword(nPlayerId);
	end
	return 0;
end

-- 混战时期需要即时同步重投战斗倒计时和战场排名，需要分离信息和倒计时的同步
-- 更新混战玩家信息
function tbBaseFaction:UpdateMeleePlayerInfo(nPlayerId)
	local nRestTime = Timer:GetRestTime(self.nTimerId);
	local tbPlayer = self:GetAttendPlayerTable();
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not tbPlayer[nPlayerId] then
		if pPlayer then
			Dialog:SendBattleMsg(pPlayer, "");
		end
		return 0;
	end
	local nSort = tbPlayer[nPlayerId].nSort or 0;
	local tbTmp = {};
	local tbTmpId = {};
	table.insert(tbTmpId, nPlayerId);
	-- 排序
	while (nSort > 1) do
		if self.tbSort[nSort].tbPlayerInfo.nScore > self.tbSort[nSort - 1].tbPlayerInfo.nScore then
			table.insert(tbTmpId, self.tbSort[nSort - 1].nPlayerId);
			tbTmp = self.tbSort[nSort];
			self.tbSort[nSort] = self.tbSort[nSort - 1];
			self.tbSort[nSort - 1] = tbTmp;
			self.tbSort[nSort - 1].tbPlayerInfo.nSort = nSort - 1;
			self.tbSort[nSort].tbPlayerInfo.nSort = nSort;			
			nSort = nSort - 1;
		else
			nSort = 0;
		end
	end
	
	for i, nId in ipairs(tbTmpId) do
		pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer then
			local szMsg = "";
			if FactionBattle._MODEL_OLD == FactionBattle.FACTIONBATTLE_MODLE then
				szMsg = string.format("Liên thắng: %s\n\nXếp hạng: %s", tbPlayer[nId].nScore, tbPlayer[nId].nSort);
				if self.nMeleeCount and self.nMeleeCount > 4 then -- 混战结束休息时间
					szMsg = "";
				end
			else
				szMsg = string.format("Điểm số: %d\n\nTổng điểm: %d\n\nXếp hạng: %d", tbPlayer[nId].OnceScore, tbPlayer[nId].nScore, tbPlayer[nId].nSort);
			end
			Dialog:SendBattleMsg(pPlayer, szMsg);
		end
	end
end

-- 更新混战玩家倒计时
function tbBaseFaction:UpdateMeleePlayerTimer(nPlayerId, bShowMsg)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local nRestTime = Timer:GetRestTime(self.nTimerId);
	local tbPlayer = self:GetAttendPlayerTable();
	local szTimeFmt = "";
	if FactionBattle.FACTIONBATTLE_MODLE == FactionBattle._MODEL_NEW then
		szTimeFmt = "<color=green>".. self.nMeleeCount .. "/4 vòng đấu thăng hạng: <color><color=white>%s<color>\n";
	else
		if self.nMeleeCount == 4 then
			szTimeFmt = "<color=green>Kết thúc vòng loại: <color><color=white>%s<color>\n";
		else
			szTimeFmt = "<color=green>Vòng thăng hạng tiếp theo: <color><color=white>%s<color>\n";
		end
	end
	if tbPlayer[nPlayerId] and tbPlayer[nPlayerId].nTimerId ~= 0 then
		local nRetTime = Timer:GetRestTime(tbPlayer[nPlayerId].nTimerId);
		szTimeFmt = szTimeFmt.."\n<color=green>Thời gian còn lại: <color><color=white>%s<color>\n";
		Dialog:SetBattleTimer(pPlayer, szTimeFmt, nRestTime, nRetTime);
	elseif tbPlayer[nPlayerId] and tbPlayer[nPlayerId].nArenaId > 0 and self.nFightTimerId > 0 then
		local nRetTime = Timer:GetRestTime(self.nFightTimerId);
		szTimeFmt = szTimeFmt.."\n<color=green>Thời gian còn lại: <color><color=white>%s<color>\n";
		Dialog:SetBattleTimer(pPlayer, szTimeFmt, nRestTime, nRetTime);
	else
		Dialog:SetBattleTimer(pPlayer, szTimeFmt, nRestTime);
	end
	if bShowMsg == 1 then
		Dialog:ShowBattleMsg(pPlayer,  1,  0); --开启界面
	end
end

function tbBaseFaction:BeginAddExp()
	if FactionBattle._MODEL_OLD == FactionBattle.FACTIONBATTLE_MODLE then
		self:BoardMsgToMapPlayer("Kinh nghiệm cho người chơi sắp bắt đầu!");
	end
	Timer:Register(
		FactionBattle.ADDEXP_SECOND_PRE_TIME * Env.GAME_FPS,
		self.AddExp,
		self
	);
end

-- 增加经验,按不同队列分帧加，以免玩家数量庞大导致其他服务在+经验期间延时过大
function tbBaseFaction:AddExp()
	if self.nState == FactionBattle.NOTHING or self.nState == FactionBattle.END then
		return 0;
	end
	Timer:Register(
		1,
		self._AddExp,
		self,
		1
	);	-- 分帧+经验
end

function tbBaseFaction:_AddExp(nIndex)
	if nIndex > FactionBattle.ADDEXP_QUEUE_NUM then
		return 0
	end
	local tbPlayer = self:GetMapPlayerTable();
	for nPlayerId in pairs(tbPlayer[nIndex]) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			local nExp = pPlayer.GetBaseAwardExp() * FactionBattle.RATIO;
			pPlayer.AddExp2(nExp,"pvp"); -- mod zounan 修改经验接口
		end
	end
	Timer:Register(
		1,
		self._AddExp,
		self,
		nIndex + 1
	);
	return 0;
end

-- 把玩家分配到相关的混战地图,以及玩家各种相关设置
function tbBaseFaction:AssignPlayerToMelee()
	local tbPlayer = self:GetAttendPlayerTable()
	-- 人数不达最低要求则不进行
	local nPlayerNum = self:GetAttendPlayuerCount();
	if nPlayerNum < FactionBattle.MIN_ATTEND_PLAYER then
		return 0;
	end
	
	-- 按等级排序
	self.tbSort = {}
	for nPlayerId in pairs(tbPlayer) do
		local tbTemp = {}
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		if (pPlayer) and (pPlayer.nMapId == self.nMapId) then
			tbTemp.nKey = pPlayer.nLevel + (pPlayer.GetExp() / pPlayer.GetUpLevelExp());
			tbTemp.nPlayerId = nPlayerId;
			tbTemp.tbPlayerInfo = tbPlayer[nPlayerId];
			tbTemp.pPlayer = pPlayer;
			setmetatable(tbTemp, self.tbSortFunc);
			table.insert(self.tbSort, tbTemp);
		else
			self:DelAttendPlayer(nPlayerId);
		end
	end
	-- 在场的参加人数不足则不进行
	self.nTotalPlayer = #self.tbSort;
	if self.nTotalPlayer < FactionBattle.MIN_ATTEND_PLAYER then
		return 0;
	end
	-- 排序
	table.sort(self.tbSort);
	-- 计算需要的比赛场地个数
	local nArenaNum = math.ceil(nPlayerNum / FactionBattle.PLAYER_PER_ARENA);
	local nPlayerPerArena = math.ceil(nPlayerNum / nArenaNum);
	-- 等级平均分布地把玩家发送到各个比赛场地
	for i = 1, nArenaNum do
		local j = i;
		while (self.tbSort[j]) do
			local nX, nY = FactionBattle:GetRandomPoint(i)
			self.tbSort[j].pPlayer.NewWorld(self.nMapId, nX, nY);
			if (self.tbSort[j].pPlayer.GetTrainingTeacher()) then	-- 如果玩家的身份是徒弟，那么师徒任务当中的门派竞技次数加1
				-- local tbItem = Item:GetClass("teacher2student");
				local nNeed_Faction = self.tbSort[j].pPlayer.GetTask(Relation.TASK_GROUP, Relation.TASK_ID_SHITU_FACTION) + 1;
				self.tbSort[j].pPlayer.SetTask(Relation.TASK_GROUP, Relation.TASK_ID_SHITU_FACTION, nNeed_Faction);
			end
			
			-- 师徒成就：门派竞技
			Achievement_ST:FinishAchievement(self.tbSort[j].pPlayer.nId, Achievement_ST.FACTION);
			
			if (self.tbSort[j].tbPlayerInfo) then
				self.tbSort[j].tbPlayerInfo.nSort = j;	-- 初始排名
			end
			--KStatLog.ModifyAdd("RoleWeeklyEvent", self.tbSort[j].pPlayer.szName, "本周参加门派竞技次数", 1);
			self:SetPlayerMeleeState(self.tbSort[j].pPlayer);
			FactionBattle:AwardAttender(self.tbSort[j].pPlayer, 1);
			self:AddArenaPlayer(i, self.tbSort[j].nPlayerId); 			-- 记录每个战场的玩家
			j = j + nArenaNum;
		end
	end
	-- 混战保护时间
	self.nFightTimerId = Timer:Register(
		FactionBattle.MELEE_PROTECT_TIME * Env.GAME_FPS,
		self.ChangeFight,
		self
	);	
	return 1;
end

function tbBaseFaction:RestartMelee()
	self.nMeleeCount = self.nMeleeCount + 1;
	local tbPlayer = self:GetAttendPlayerTable();
	local nPlayerCount = 0;
	-- 计算人数
	for nPlayerId, tbInfo in pairs(tbPlayer) do
		if tbInfo.nTimerId and tbInfo.nTimerId > 0 then
			Timer:Close(tbInfo.nTimerId);
			tbInfo.nTimerId = 0;
		end
		if tbInfo.nArenaId > 0 then
			self:DelArenaPlayer(tbInfo.nArenaId, nPlayerId);
		end
		tbInfo.nDeathCount = 0;
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer and pPlayer.nMapId == self.nMapId then
			pPlayer.SetFightState(0);
			pPlayer.nPkModel = Player.emKPK_STATE_PRACTISE;
			nPlayerCount = nPlayerCount + 1
			tbInfo.pPlayer = pPlayer;	-- 临时数据
		else
			tbInfo.pPlayer = nil;
		end
	end
	
	-- 分配场地
	local nArenaNum = math.ceil(nPlayerCount / FactionBattle.PLAYER_PER_ARENA) + 1;
	if nPlayerCount <= FactionBattle.MIN_RESTART_MELEE then
		nArenaNum = 1;
	end
	if nArenaNum > FactionBattle.MAX_ARENA then
		nArenaNum = FactionBattle.MAX_ARENA; 
	end
	local nPlayerPerArena = math.ceil(nPlayerCount / nArenaNum);
	local nMaxPlayer = self:GetAttendPlayuerCount();
	local nArenaId = 1;
	local nArenaPlayerCount = 0;
	for i = 1, nMaxPlayer do
		if self.tbSort[i] and self.tbSort[i].tbPlayerInfo.pPlayer then
			local pPlayer = self.tbSort[i].tbPlayerInfo.pPlayer;
			local nX, nY = FactionBattle:GetRandomPoint(nArenaId);
			pPlayer.NewWorld(self.nMapId, nX, nY);
			self:SetPlayerMeleeState(pPlayer);
			self:AddArenaPlayer(nArenaId, self.tbSort[i].nPlayerId);
			nArenaPlayerCount = nArenaPlayerCount + 1;
			if nArenaPlayerCount == nPlayerPerArena then	-- 该场分的人够了，分下一个场
				nArenaPlayerCount = 0;
				nArenaId = nArenaId + 1;
			end
		end
	end
	-- 混战保护时间
	self.nFightTimerId = Timer:Register(
		FactionBattle.MELEE_RESTART_PROTECT * Env.GAME_FPS,
		self.ChangeFight,
		self
	);
end

-- 设置玩家预备混战状态（传送进混战区设置）
function tbBaseFaction:SetPlayerMeleeState(pPlayer)
	if type(pPlayer) ~= "userdata" then
		Dbg:WriteLog("FactionBattle", "tbBaseFaction:SetPlayerMeleeState(pPlayer) param pPlayer isn't userdate but ", type(pPlayer));
		assert(nil);
	end
	-- 非战斗状态, 保护时间过后进入战斗状态
	pPlayer.SetFightState(0);
	--	PK状态 保护后进入屠杀状态
	pPlayer.nPkModel = Player.emKPK_STATE_PRACTISE;
	--  战场标志（同家族可相互攻击）
	pPlayer.nInBattleState	= 1;
	-- 禁止组队
	pPlayer.TeamDisable(1);
	pPlayer.TeamApplyLeave();
	pPlayer.SetDisableTeam(1);
	-- 禁止交易
	pPlayer.ForbitTrade(1);
	-- 屏蔽组队、交易、好友界面
	pPlayer.SetDisableStall(1);
	pPlayer.SetDisableFriend(1);	
	
	-- 死亡惩罚
	pPlayer.SetNoDeathPunish(1);
	-- 死亡回调	
	Setting:SetGlobalObj(pPlayer);
	local tbPlayer = self:GetAttendPlayerTable();
	if tbPlayer[pPlayer.nId].nOnDeathRegId ~= 0 then
		PlayerEvent:UnRegister("OnDeath", tbPlayer[pPlayer.nId].nOnDeathRegId);
		tbPlayer[pPlayer.nId].nOnDeathRegId = 0;
	end
	tbPlayer[pPlayer.nId].nOnDeathRegId	= PlayerEvent:Register("OnDeath", self.OnDeathInMelee, self);
	Setting:RestoreGlobalObj();
end

-- 设置玩家淘汰赛预备状态(传送进淘汰区设置)
function tbBaseFaction:SetPlayerElmState(pPlayer)
	-- 非战斗状态, 保护时间过后进入战斗状态
	pPlayer.SetFightState(0);
	--	PK状态 保护后进入屠杀状态
	pPlayer.nPkModel = Player.emKPK_STATE_PRACTISE;
	--  战场标志（同家族可相互攻击）
	pPlayer.nInBattleState	= 1;
	-- 禁止组队
	pPlayer.TeamDisable(1);
	pPlayer.TeamApplyLeave();
	-- 禁止交易
	pPlayer.ForbitTrade(1);
	-- 飘血可见
	pPlayer.SetBroadHitState(1);
	-- 死亡惩罚
	pPlayer.SetNoDeathPunish(1);

	-- 屏蔽组队、交易、好友界面
	pPlayer.SetDisableTeam(1);
	pPlayer.SetDisableStall(1);
	pPlayer.SetDisableFriend(1);	
	
	--	死亡回调
	Setting:SetGlobalObj(pPlayer);
	local tbPlayer = self:GetAttendPlayerTable();
	if tbPlayer[pPlayer.nId].nOnDeathRegId ~= 0 then
		PlayerEvent:UnRegister("OnDeath", tbPlayer[pPlayer.nId].nOnDeathRegId);
		tbPlayer[pPlayer.nId].nOnDeathRegId = 0;
	end
	tbPlayer[pPlayer.nId].nOnDeathRegId	= PlayerEvent:Register("OnDeath", self.OnDeathInElimin, self);
	Setting:RestoreGlobalObj();
end

-- 设置玩家进入比赛状态(比赛开始设置)
function tbBaseFaction:SetPlayerFightState(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		local tbPlayer = self:GetAttendPlayerTable();
-------------------------------------------------------------------------------------------------
-- 设设置攻击模式 xuantao 2010/12/6 19:35:36
		if tbPlayer[nPlayerId] then
			pPlayer.SetFightState(1);	-- 战斗状态
			-- 新版的混战，攻击模式会不一样
			if self.nState == FactionBattle.MELEE and FactionBattle.FACTIONBATTLE_MODLE == FactionBattle._MODEL_NEW then
				pPlayer.nPkModel = Player.emKPK_STATE_CAMP;		-- 设置PK 模式为 阵营模式
			else
				pPlayer.nPkModel = Player.emKPK_STATE_BUTCHER; 		-- 屠杀-- PK状态
			end
		else		-- 没报名过？
			return 0;
		end
-------------------------------------------------------------------------------------------------
		-- 计算伤害量(淘汰赛)
		if self.nState == FactionBattle.ELIMINATION then
			tbPlayer[nPlayerId].nDamageCount = 0;
			pPlayer.StartDamageCounter();
			
			local szMsg = string.format("Sát thương phe ta: 0\nSát thương phe địch: 0\n");
			Dialog:SendBattleMsg(pPlayer, szMsg);
			if (not self.nDamageTimer) then
				self.nDamageTimer = Timer:Register(Env.GAME_FPS * 5, self.DamageTimerBreath, self);
			end
		end
	end
end

function tbBaseFaction:DamageTimerBreath()
	if (#self.tbAttend <= 0) then
		self.nDamageTimer = nil;
		return 0;
	end;
		for _, tbplayerId in pairs(self.tbAttend) do
		local pPlayer1 = KPlayer.GetPlayerObjById(tbplayerId[1]);
		local pPlayer2 = KPlayer.GetPlayerObjById(tbplayerId[2]);
		if (pPlayer1 and pPlayer2) then
			local nDamage1 = pPlayer1.GetDamageCounter();
			local nDamage2 = pPlayer2.GetDamageCounter();
		
			local szMsg1 = string.format("Sát thương phe ta: %s\nSát thương phe địch: %s\n", nDamage1, nDamage2);
			local szMsg2 = string.format("Sát thương phe ta: %s\nSát thương phe địch: %s\n", nDamage2, nDamage1);
			
			Dialog:SendBattleMsg(pPlayer1, szMsg1);
			Dialog:SendBattleMsg(pPlayer2, szMsg2);
		end;
	end;
end;

-- 恢复玩家到正常状态
function tbBaseFaction:ResumeNormalState(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if not pPlayer then
		return;
	end
	local tbPlayer = self:GetAttendPlayerTable();
	if not tbPlayer[nPlayerId] then		-- 没报名过？
		return 0;
	end
	-- 非战斗状态
	pPlayer.SetFightState(0);
	pPlayer.nPkModel = Player.emKPK_STATE_PRACTISE;
	-- 死亡惩罚
	pPlayer.SetNoDeathPunish(0);
	--  战场标志（同家族可相互攻击）
	pPlayer.nInBattleState	= 0;
	-- 新模式下，是阵营模式，需要重置玩家的阵营
	if FactionBattle._MODEL_NEW == FactionBattle.FACTIONBATTLE_MODLE then
		if tbPlayer[nPlayerId].nSelfCamp then
			pPlayer.SetCurCamp(tbPlayer[nPlayerId].nSelfCamp);
		end
	end
	-- 允许组队
	pPlayer.TeamDisable(0);
	-- 关闭屏蔽组队、交易、好友界面
	pPlayer.SetDisableTeam(0);
	pPlayer.SetDisableStall(0);
	pPlayer.SetDisableFriend(0);		
	
	-- 允许交易
	pPlayer.ForbitTrade(0);
	-- 停止计算伤害量
	tbPlayer[nPlayerId].nDamageCount = pPlayer.GetDamageCounter();
	pPlayer.StopDamageCounter();
	-- 注销死亡脚本
	Setting:SetGlobalObj(pPlayer);
	PlayerEvent:UnRegister("OnDeath", tbPlayer[nPlayerId].nOnDeathRegId);
	Setting:RestoreGlobalObj();
end

-- 设置进入地图的状态
function tbBaseFaction:SetInMap(pPlayer)
	-- 临时重生点
	local nRandom = MathRandom(4)
	pPlayer.SetTmpDeathPos(self.nMapId, unpack(FactionBattle.REV_POINT[nRandom]));
end

-- 设置离开地图的状态
function tbBaseFaction:SetOutMap(pPlayer)
	-- 恢复重生
	local nRevMapId, nRevPointId = pPlayer.GetRevivePos();
	pPlayer.SetRevivePos(nRevMapId, nRevPointId);
end

-- 所有区域玩家都进入战斗状态
function tbBaseFaction:ChangeFight()
	self.nFightTimerId = 0;
	local tbPlayer = self:GetAttendPlayerTable();
	if (self.tbArena) then
		for i, tbOne in pairs(self.tbArena) do
			for nPlayerId in pairs(tbOne) do
				self:SetPlayerFightState(nPlayerId);
				if self.nState == FactionBattle.MELEE then
					self:UpdateMeleePlayerTimer(nPlayerId);
				elseif self.nState == FactionBattle.ELIMINATION then
					self:UpdateEliminationPlayerTimer(nPlayerId);
				end
			end
		end
	end
	return 0;
end

-- 踢某个正在战斗区的玩家离开战斗区域（只删除记录，不NewWorld）
function tbBaseFaction:KickPlayerFromArena(nPlayerId)
	local tbPlayer = self:GetAttendPlayerTable();
	if tbPlayer[nPlayerId] then
		local nArenaId = tbPlayer[nPlayerId].nArenaId
		if not nArenaId or nArenaId == 0 then
			return;
		end
		self:DelArenaPlayer(nArenaId, nPlayerId);
		tbPlayer[nPlayerId].nArenaId = 0;
		if tbPlayer[nPlayerId].nTimerId ~= 0 then
			Timer:Close(tbPlayer[nPlayerId].nTimerId);
			tbPlayer[nPlayerId].nTimerId = 0;
		end
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if (pPlayer and self.nMapId == pPlayer.nMapId) then
			self:ResumeNormalState(nPlayerId);	-- 恢复状态
		end
		local nRet = self:CheckPlayerNumInArena(nArenaId);
		if nRet ~= 1 then		-- 结束该混战区域活动
			if self.nState == FactionBattle.ELIMINATION and self.tbNextWinner[nArenaId] == -1 then
				local tbOnlyPlayer = self:GetArenaPlayer(nArenaId);
				for nWinnerId in pairs(tbOnlyPlayer) do	-- 只有一个人了
					self:SetEliminationWinner(nArenaId, nWinnerId, nPlayerId);
				end
			end
			self:MsgToArenaPlayer(nArenaId, "Thắng bại đã rõ! Kết quả sẽ sớm công bố!");
			Timer:Register(
				FactionBattle.END_DELAY * Env.GAME_FPS,
				self.CloseArena,
				self,
				nArenaId
				);
			
		end
	end
end

-- 混战期玩家死亡脚本
function tbBaseFaction:OnDeathInMelee(pKillerNpc)
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return;
	end
	
	--成就
	for i = 71, 75 do
		Achievement:FinishAchievement(pKillerPlayer, i);
	end
	
	local tbPlayer = self:GetAttendPlayerTable();
	local nKillerRoute = pKillerPlayer.nRouteId;
	if self.tbRouteKills[nKillerRoute] == nil then
		self.tbRouteKills[nKillerRoute] = 0;
	end
	self.tbRouteKills[nKillerRoute] = self.tbRouteKills[nKillerRoute] + 1;
	if tbPlayer[pKillerPlayer.nId] and self.nState == FactionBattle.MELEE then		-- 混战模式下加分处理
		
		tbPlayer[pKillerPlayer.nId].nScore = tbPlayer[pKillerPlayer.nId].nScore + 1 * FactionBattle.PERCENTAGE;
		-- 跟阵营加分
		if FactionBattle._MODEL_NEW == FactionBattle.FACTIONBATTLE_MODLE then
			tbPlayer[pKillerPlayer.nId].OnceScore = tbPlayer[pKillerPlayer.nId].OnceScore + 1 * FactionBattle.PERCENTAGE;
			local tbArenaData = self:GetArenaData(tbPlayer[pKillerPlayer.nId].nArenaId);
			tbArenaData[tbPlayer[pKillerPlayer.nId].nCamp] = tbArenaData[tbPlayer[pKillerPlayer.nId].nCamp] + 1;
		end
		
		if tbPlayer[pKillerPlayer.nId].nScore == 1* FactionBattle.PERCENTAGE then
			FactionBattle:AwardAttender(pKillerPlayer, 2);
		end
		-- 马上原地复活
		me.ReviveImmediately(1);
		-- 战斗状态
		me.SetFightState(0);
		-- PK状态
		me.nPkModel = Player.emKPK_STATE_PRACTISE;
		-- 重投战斗定时
		tbPlayer[me.nId].nDeathCount = tbPlayer[me.nId].nDeathCount + 1;
		-- 数据埋点，记录玩家被杀和杀人者的情况
		if FactionBattle._MODEL_NEW == FactionBattle.FACTIONBATTLE_MODLE then
			StatLog:WriteStatLog("stat_info", "menpaijingj", "kill", pKillerPlayer.nId, me.szAccount, me.szName, FactionBattle.TB_COMPETITION_STAGE["camp"]);
			-- log记录
			Dbg:WriteLog("menpaijingj", "kill", pKillerPlayer.szAccount, pKillerPlayer.szName, me.szAccount, me.szName, FactionBattle.TB_COMPETITION_STAGE["camp"]);
		end
		local nDeath = tbPlayer[me.nId].nDeathCount;
		if nDeath > #FactionBattle.RETURN_TO_MELEE_TIME then
			nDeath = #FactionBattle.RETURN_TO_MELEE_TIME
		end
		tbPlayer[me.nId].nTimerId = Timer:Register(
			FactionBattle.RETURN_TO_MELEE_TIME[nDeath] * Env.GAME_FPS,
			self.ReturnToMelee,
			self,
			me.nId
		);
		self:UpdateMeleePlayerTimer(me.nId);		-- 被杀者更新时间
		self:UpdateMeleePlayerInfo(pKillerPlayer.nId); -- 杀人者更新信息
		pKillerPlayer.Msg(string.format(FactionBattle.tbDescrption_2S["KillInMelee"][FactionBattle.FACTIONBATTLE_MODLE], me.szName, tbPlayer[pKillerPlayer.nId].nScore));
		me.Msg("Ngươi bị <color=yellow>"..pKillerPlayer.szName.."<color> hạ gục, chờ <color=green>"..FactionBattle.RETURN_TO_MELEE_TIME[nDeath].." giây <color> hồi phục sẽ tiếp tục chiến đấu.");
	end
end

-- 重新投入战斗定时函数
function tbBaseFaction:ReturnToMelee(nPlayerId)
	local tbPlayer = self:GetAttendPlayerTable()
	if tbPlayer[nPlayerId] then
		tbPlayer[nPlayerId].nTimerId = 0;
		self:SetPlayerFightState(nPlayerId);
		self:UpdateMeleePlayerTimer(nPlayerId);
	end
	return 0;
end

-- 淘汰赛期玩家死亡脚本
function tbBaseFaction:OnDeathInElimin(pKillerNpc)
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return;
	end
	
	--成就
	for i = 71, 75 do
		Achievement:FinishAchievement(pKillerPlayer, i);
	end

	Timer:Register(
		FactionBattle.END_DELAY * Env.GAME_FPS,
		self.AutoRevivePlayer,
		self,
		me.nId
	);
	self:KickPlayerFromArena(me.nId);
end

-- 自动重生(淘汰阶段)
function tbBaseFaction:AutoRevivePlayer(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	if pPlayer.IsDead() == 1 then
		pPlayer.Revive(0);
	end
	return 0;
end

-- 检查场上人数是否能继续比赛(是否>1人)
function tbBaseFaction:CheckPlayerNumInArena(nArenaId)
	local nNum = 0;
	local nPlayerId = 0;
	local tbPlayer = self:GetArenaPlayer(nArenaId);
	for i in pairs(tbPlayer) do
		nNum = nNum + 1;
		nPlayerId = i;
		if nNum > 1 then
			return 1;
		end
	end
	return 0, nPlayerId;
end

-- 结束某场地活动，并把玩家传送回广场
function tbBaseFaction:CloseArena(nArenaId)
	local tbPlayer = self:GetAttendPlayerTable();
	local tbArenaPlayer = self:GetArenaPlayer(nArenaId);
	for nPlayerId in pairs(tbArenaPlayer) do
		self:DelArenaPlayer(nArenaId, nPlayerId)
		if tbPlayer[nPlayerId] then
			tbPlayer[nPlayerId].nArenaId = 0;
			if tbPlayer[nPlayerId].nTimerId ~= 0 then
				Timer:Close(tbPlayer[nPlayerId].nTimerId);
			end
			tbPlayer[nPlayerId].nTimerId = 0;
		end
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if (pPlayer and self.nMapId == pPlayer.nMapId) then
			self:ResumeNormalState(nPlayerId);
		end

		if pPlayer then
			FactionBattle:TrapIn(pPlayer);
		end
	end
	self.tbArena[nArenaId] = nil;
	return 0;
end

-- 给在 某比赛场区 中的玩家发送消息
function tbBaseFaction:MsgToArenaPlayer(nArenaId, szMsg)
	local tbPlayer = self:GetArenaPlayer(nArenaId);
	if not tbPlayer then
		return;
	end
	for nPlayerId in pairs(tbPlayer) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.Msg(szMsg);
		end
	end
	return 0;
end

-- 给地图内的玩家发送消息
function tbBaseFaction:MsgToMapPlayer(szMsg)
	if self.tbMapPlayer then
		for nIndex, tbPlayer in pairs(self.tbMapPlayer) do
			for nPlayerId in pairs(tbPlayer) do
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if pPlayer then
					pPlayer.Msg(szMsg);
				end
			end
		end
	end
	return 0;
end

function tbBaseFaction:BoardMsgToMapPlayer(szMsg)
	if self.tbMapPlayer then
		for nIndex, tbPlayer in pairs(self.tbMapPlayer) do
			for nPlayerId in pairs(tbPlayer) do
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if pPlayer then
					Dialog:SendBlackBoardMsg(pPlayer, szMsg);
				end
			end
		end
	end
	return 0;
end

-- 淘汰某个玩家
function tbBaseFaction:WashOutPlayer(nPlayerId)
	local tbPlayer = self:GetAttendPlayerTable();
	if tbPlayer[nPlayerId] then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if (pPlayer and self.nMapId == pPlayer.nMapId) then
			self:ResumeNormalState(nPlayerId);
		end
		self:DelAttendPlayer(nPlayerId);
	end
	return 0;
end

-- 计算16强
function tbBaseFaction:Calc16thPlayer()
	local tbPlayer = self:GetAttendPlayerTable()
	local pPlayer;
	local nCount = 1;
	local tb16thPlayer = {};
	local n = 1;
	local m = 1;
	
	while (#tb16thPlayer < 16 and self.tbSort[m]) do
		pPlayer = KPlayer.GetPlayerObjById(self.tbSort[m].nPlayerId);	
		if pPlayer and pPlayer.nMapId == self.nMapId then
			tb16thPlayer[#tb16thPlayer + 1] = self.tbSort[m].nPlayerId;
			FactionBattle:AwardAttender(pPlayer, 3);
			-- 记录16强 路线分布
			local nRoute = pPlayer.nRouteId;
			if not self.tb16Rount[nRoute] then
				self.tb16Rount[nRoute] = 0
			end
			self.tb16Rount[nRoute] = self.tb16Rount[nRoute] + 1
			n = n + 1;
		end
		m = m + 1;
	end
	local nPlayerNum = #tb16thPlayer;
	for i = 1, 8 do
		self.tbWinner[2 * i - 1] = tb16thPlayer[FactionBattle.ELIMI_VS_TABLE[i][1]] or 0;
		self.tbWinner[2 * i] = tb16thPlayer[FactionBattle.ELIMI_VS_TABLE[i][2]] or 0;
	end
	for i = 1, 16 do
		if self.tbAttendPlayer[self.tbWinner[i]] then
			self.tbSportscast[self.tbWinner[i]] = {};
			self.tb16Player[i] = self.tbSportscast[self.tbWinner[i]];
			self.tbSportscast[self.tbWinner[i]].szName = self.tbAttendPlayer[self.tbWinner[i]].szName;
			self.tbSportscast[self.tbWinner[i]].nWinCount = 0;
		end
	end
	local tbMapPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for i, pPlayer in pairs(tbMapPlayer) do
		self:SyncSportscast(pPlayer);	
	end
	
	--成就 16 强
	local p16thPlayer = nil;
	for i = 1,	#tb16thPlayer do
		p16thPlayer = KPlayer.GetPlayerObjById(tb16thPlayer[i]);
		if p16thPlayer then
			Achievement:FinishAchievement(p16thPlayer, 79); --16强
		end	
	end

	for i = 1, #self.tbSort do
		-- 给每个参加的玩家加混战的荣誉、威望
		local pPlayer = KPlayer.GetPlayerObjById(self.tbSort[i].nPlayerId);
		if pPlayer then
			for j = 1, #FactionBattle.MELEE_HONOR do
				if i <= math.floor(FactionBattle.MELEE_HONOR[j][1] * self.nTotalPlayer) then
					FactionBattle:AddFactionHonor(pPlayer, FactionBattle.MELEE_HONOR[j][2]);
					pPlayer.AddKinReputeEntry(FactionBattle.MELEE_HONOR[j][3], "factionbattle");
					
					-- 增加建设资金和个人、帮主、族长的股份
					Tong:AddStockBaseCount_GS1(pPlayer.nId, FactionBattle.MELEE_HONOR[j][4], 0.7, 0.2, 0.05, 0, 0.05);
					break;
				end
			end
		end
	end
end

-- 淘汰赛判断胜者
function tbBaseFaction:CalcWinner()
	if self.tbNextWinner then
		for i in pairs(self.tbNextWinner) do
			if self.tbNextWinner[i] == -1 then	-- 未知胜利者
				-- 判胜
				local nPlayer1Id = self.tbWinner[2 * i - 1];
				local nPlayer2Id = self.tbWinner[2 * i];
				local pPlayer1 = KPlayer.GetPlayerObjById(nPlayer1Id);
				local pPlayer2 = KPlayer.GetPlayerObjById(nPlayer2Id);
				local nScore1 = 0;
				local nScore2 = 0;
				local tbPlayer = self:GetAttendPlayerTable();
				local nDamageCount1 = 0;
				local nDamageCount2 = 0;
				if pPlayer1 then
					if tbPlayer[nPlayer1Id] then
						nDamageCount1 = tbPlayer[nPlayer1Id].nDamageCount;
					end
					nScore1 = nDamageCount1 * 100 - pPlayer1.nLevel - (pPlayer1.GetExp() / pPlayer1.GetUpLevelExp());		
					Dbg:WriteLog("FactionBattle", "玩家1:"..pPlayer1.szName, nDamageCount1);
				end
				if pPlayer2 then
					if tbPlayer[nPlayer2Id] then
						nDamageCount2 = tbPlayer[nPlayer2Id].nDamageCount;
					end
					nScore2 = nDamageCount2 * 100 - pPlayer2.nLevel - (pPlayer2.GetExp() / pPlayer2.GetUpLevelExp());
					Dbg:WriteLog("FactionBattle", "玩家2:"..pPlayer2.szName, nDamageCount2);
				end
				self.tbNextWinner[i] = nScore1 < nScore2 and nPlayer1Id or nPlayer2Id;
				if self.tbNextWinner[i] == nPlayer1Id then
					self:SetEliminationWinner(i, nPlayer1Id, nPlayer2Id, 1);
				else
					self:SetEliminationWinner(i, nPlayer2Id, nPlayer1Id, 1);
				end
			end
		end
		self.tbWinner = self.tbNextWinner;
	end
end

-- 淘汰与赛程计算
function tbBaseFaction:CalcElimination()
	local tbPlayer = self:GetAttendPlayerTable();
	local tbTempPlayer = {};
	local nTempCount = 0;
	for i, nWinnerId in pairs(self.tbWinner) do
		if nWinnerId ~= 0 then
			tbTempPlayer[nWinnerId] = tbPlayer[nWinnerId];
			self:DelAttendPlayer(nWinnerId);
			nTempCount = nTempCount + 1;
		end
	end
	for nPlayerId in pairs(tbPlayer) do
		self:WashOutPlayer(nPlayerId);	-- 淘汰玩家
	end
	self.tbAttendPlayer = tbTempPlayer;
	self.nAttendCount = nTempCount;
end


-- 把淘汰赛玩家传送到指定场区，准备比赛
function tbBaseFaction:AssignPlayerToElimination()
	local tbPlayer = self.tbWinner;
	local nPlayerNum = #self.tbWinner;
	self.tbNextWinner = {};
	self.tbAttend = {};
	for i = 1, math.ceil(nPlayerNum / 2) do
		local nPlayer1Id = self.tbWinner[2 * i - 1];
		local nPlayer2Id = self.tbWinner[2 * i];
		local pPlayer1 = KPlayer.GetPlayerObjById(nPlayer1Id)
		local pPlayer2 = KPlayer.GetPlayerObjById(nPlayer2Id)
		self.tbNextWinner[i] = -1;		-- 为-1，未知晋级名单
		if pPlayer1 and pPlayer2 and pPlayer1.nMapId == self.nMapId and pPlayer2.nMapId == self.nMapId then
			self.tbAttend[i] = {nPlayer1Id, nPlayer2Id};	
			local tbPoint1, tbPoint2 = FactionBattle:GetElimFixPoint(i);
			self:AddArenaPlayer(i, nPlayer1Id);
			self:AddArenaPlayer(i, nPlayer2Id);
			pPlayer1.NewWorld(self.nMapId, unpack(tbPoint1));
			self:SetPlayerElmState(pPlayer1);
			pPlayer2.NewWorld(self.nMapId, unpack(tbPoint2));
			self:SetPlayerElmState(pPlayer2);
			local szMsg = "";
			if 4 == self.nEliminationCount then
				szMsg = "Giai đoạn cuối bắt đầu sau 30 giây.";
			elseif self.nEliminationCount < 4 then
				local nNum = self.nEliminationCount;
				if nNum <= 0 then
					nNum = 1;
				end
				szMsg = string.format("Vòng %d lấy %d bắt đầu sau 30 giây.", nPlayerNum / nNum , math.ceil(nPlayerNum / (2 * nNum)));
			end
			if szMsg ~= "" then
				pPlayer2.Msg(szMsg);
				pPlayer1.Msg(szMsg);
				Dialog:SendBlackBoardMsg(pPlayer2, szMsg);
				Dialog:SendBlackBoardMsg(pPlayer1, szMsg);
			end
		elseif pPlayer1 and pPlayer1.nMapId == self.nMapId then
			self:SetEliminationWinner(i, nPlayer1Id, nPlayer2Id);
		elseif pPlayer2 and pPlayer2.nMapId == self.nMapId then
			self:SetEliminationWinner(i, nPlayer2Id, nPlayer1Id);
		else 	-- 无对手VS无对手
			self.tbNextWinner[i] = 0;	-- 0 为无人晋级
		end
	end
	-- 进入保护时间
	self.nFightTimerId = Timer:Register(
		FactionBattle.ELIMI_PROTECT_TIME * Env.GAME_FPS,
		self.ChangeFight,
		self
		);
end

function tbBaseFaction:SetEliminationWinner(nArenaId, nWinnerId, nLoserId, bCalcDamiage)
	local pWinner = KPlayer.GetPlayerObjById(nWinnerId);
	if not pWinner then
		self.tbNextWinner[nArenaId] = 0
		return 0;
	end
	self.tbNextWinner[nArenaId] = nWinnerId;
	if self.tbSportscast[nWinnerId] then
		self.tbSportscast[nWinnerId].nWinCount = self.tbSportscast[nWinnerId].nWinCount + 1;
	end
	FactionBattle:AwardAttender(pWinner, self.nEliminationCount + 3);
	-- 晋级奖励
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
	local tbAttendPlayer = self:GetAttendPlayerTable();
	local nPlayerNum = #tbPlayer;
	if FactionBattle._MODEL_OLD == FactionBattle.FACTIONBATTLE_MODLE then	-- 晋级送礼
		FactionBattle:PromotionAward(self.nMapId, nArenaId, self.nEliminationCount, nWinnerId, nLoserId, nPlayerNum);
	end
	
	-- 公告
	local pLoser = KPlayer.GetPlayerObjById(nLoserId);
	if pLoser then
		local szMsg = "";
		if FactionBattle._MODEL_NEW == FactionBattle.FACTIONBATTLE_MODLE then
			if self.nEliminationCount < 3 then
				szMsg = "Thật đáng tiếc, bạn đã thất bại.";
			elseif self.nEliminationCount == 3 then
				szMsg = "Thật đáng tiếc, bạn không vào được Chung kết."
			elseif self.nEliminationCount == 4 then
				szMsg = "Thật đáng tiếc, bạn không giành được chức Quán quân.";
			end
		else
			szMsg = "Thi đấu thất bại, không thể vào vòng trong"
		end
		pLoser.Msg(szMsg);
		if FactionBattle._MODEL_NEW == FactionBattle.FACTIONBATTLE_MODLE then
			Timer:Register(Env.GAME_FPS, self.SendBlackMsg2Player, self, pLoser.nId, szMsg);
		else
			Dialog:SendBlackBoardMsg(pLoser, szMsg);
		end
	end
	if self.tbSportscast[nWinnerId].nWinCount >= 4 then -- nWinCount ==淘汰赛胜利次数
		if FactionBattle._MODEL_NEW == FactionBattle.FACTIONBATTLE_MODLE then
			pWinner.Msg("Chúc mừng ngươi đã trở thành Quán Quân. Hãy đến nhận thưởng tại Đài Nhận Lễ");
			Timer:Register(Env.GAME_FPS, self.SendBlackMsg2Player, self, pWinner.nId, "Chúc mừng bạn đã dành chức vô địch lần này.");
		else
			pWinner.Msg("Chúc mừng ngươi đã trở thành Quán Quân. Hãy đến nhận thưởng tại Đài Nhận Lễ");
			self:BoardMsgToMapPlayer("Chúc mừng ["..pWinner.szName.."] là Tân Nhân Vương Mới. Hãy đến nhận thưởng.")
		end
		self:MsgToMapPlayer("Chúc mừng <color=yellow>"..pWinner.szName.."<color> giành được Quán quân!");
		
		--向门派竞技冠军玩家推送SNS通知
		-- local szPopupMessage = "祝贺您获得<color=yellow>门派竞技冠军<color>！\n把这个好消息分享给朋友们吧！";
		-- local szTweet;
		-- if pLoser then
			-- szTweet = string.format("#Kiếm Thế# 我打败%s赢得门派竞技冠军！呵呵……", pLoser.szName);
		-- else
			-- szTweet = "#Kiếm Thế# 刚刚赢得了门派竞技冠军！呵呵……";
		-- end
		-- Sns:NotifyClientNewTweet(pWinner, szPopupMessage, szTweet);
		
		FactionBattle:FinalWinner(self.nFaction, nWinnerId);
		self.nFinalWinner = nWinnerId;
		-- 如果没对手而决出冠军则跳过淘汰赛状态
		if self.nState == FactionBattle.READY_ELIMINATION then
			self.nStateJour = self.nStateJour + 1;
		end
		if self.nTimerId and self.nTimerId > 0 then
			Timer:Close(self.nTimerId);
			self:TimerStart();
		end
		-- 冠军奖励
		if FactionBattle._MODEL_NEW == FactionBattle.FACTIONBATTLE_MODLE then
			self:EliminationAword();
		end
		local szFaction = Player:GetFactionRouteName(pWinner.nFaction);
		local szWinMsg = " tại Thi đấu môn phái "..szFaction.. " đã dành chiến thắng, trở thành Tân Nhân Vương "..szFaction..".";
		local szLoseMsg = " tại Thi đấu môn phái "..szFaction.. " đã thất bại.";
		
		pWinner.SendMsgToFriend("Hảo hữu ["..pWinner.szName.."]" ..szWinMsg);
		Player:SendMsgToKinOrTong(pWinner, szWinMsg, 1);
		if (pLoser) then
			pLoser.SendMsgToFriend("Hảo hữu [".. pLoser.szName.. "]"..szLoseMsg);
			Player:SendMsgToKinOrTong(pLoser, szLoseMsg, 1);
		end
		--成就
		Achievement:FinishAchievement(pWinner, 81); --冠军
		Achievement:FinishAchievement(pWinner, 82); --冠军
		
		Dbg:WriteLogEx(Dbg.LOG_INFO, "FactionBattle", "冠军:", pWinner.szName, pWinner.szAccount);
		if (EventManager.IVER_bOpenTiFu == 1) then
			if pWinner.nRouteId ~= 0 then
				KStatLog.ModifyAdd("tifu", string.format("%s\t门派夺冠次数", self.tbRoutes[pWinner.nRouteId].szName), "总量", 1)
			end
		end
	else
		local szMsg = "";
		if FactionBattle._MODEL_NEW == FactionBattle.FACTIONBATTLE_MODLE then
			if self.nEliminationCount == 3 then
				szMsg = "Đấu loại kết thúc, chúc mừng ngươi tiến nhập trận chung kết, nỗ lực lên!";
			else
				szMsg = "Ngươi đánh bại đối thủ, được tư cách vào vòng tiếp theo";
			end
			Timer:Register(Env.GAME_FPS, self.SendBlackMsg2Player, self, pWinner.nId, szMsg);
		else
			szMsg = "Ngươi đánh bại đối thủ, được tư cách vào vòng tiếp theo"
			Dialog:SendBlackBoardMsg(pWinner, szMsg);
		end
		pWinner.Msg(szMsg);
	end
	
	local szMsg = "";
	if (self.tbSportscast[nWinnerId].nWinCount == 1) then
		local nRoute = pWinner.nRouteId
		if not self.tb8Rount[nRoute] then
			self.tb8Rount[nRoute] = 0;
		end
		self.tb8Rount[nRoute] = self.tb8Rount[nRoute] + 1;
	end
	if (self.tbSportscast[nWinnerId].nWinCount == 2) then
		--半决赛
		szMsg = " tại Thi đấu môn phái "..Player:GetFactionRouteName(pWinner.nFaction).. " tiến vào vòng Bán kết.";
		pWinner.SendMsgToFriend("Hảo hữu ["..pWinner.szName.. "]".. szMsg);
		Player:SendMsgToKinOrTong(pWinner, szMsg, 0);
		--成就
		Achievement:FinishAchievement(pWinner, 80); --四强
	elseif (self.tbSportscast[nWinnerId].nWinCount == 3) then
		--进入决赛
		szMsg = " tại Thi đấu môn phái "..Player:GetFactionRouteName(pWinner.nFaction).. " tiến vào vòng Chung kết.";
		pWinner.SendMsgToFriend("Hảo hữu ["..pWinner.szName.. "]".. szMsg);
		Player:SendMsgToKinOrTong(pWinner, szMsg, 0);
	end
	
	local szLoserName = KGCPlayer.GetPlayerName(nLoserId);
	local szReason;
	if not szLoserName then
		szLoserName = " ";
	end
	if bCalcDamiage and bCalcDamiage == 1 then
		szReason = "sát thương lớn hơn";
	else
		szReason = "hạ gục";
	end
	local szQiang = "不明"; 
	if FactionBattle.BOX_NUM[self.nEliminationCount] then
		szQiang = FactionBattle.BOX_NUM[self.nEliminationCount][1].."强";
	end 
	local szMsg = string.format("Tại %s hạ %s bằng %s", szQiang,szLoserName, szReason)
	pWinner.PlayerLog(Log.emKPLAYERLOG_TYPE_FACTIONSPORTS, szMsg)
	-- 同步数据
	for i, pPlayer in pairs(tbPlayer) do
		self:SyncSportscast(pPlayer);	
	end
	Dbg:WriteLog("FactionBattle", "SetWinner", "FactionId:"..pWinner.nFaction, pWinner.szName..szMsg, nArenaId or 0);
	-- 数据埋点，记录玩家被杀和杀人者的情况
	if FactionBattle._MODEL_NEW == FactionBattle.FACTIONBATTLE_MODLE and pWinner and pLoser then
		local szIndex = "out";
		if self.nEliminationCount == 4 then
			szIndex = "final";
		end
		StatLog:WriteStatLog("stat_info", "menpaijingj", "kill", pWinner.nId, pLoser.szAccount, pLoser.szName, FactionBattle.TB_COMPETITION_STAGE[szIndex]);
		Dbg:WriteLog("menpaijingj", "kill", pWinner.szAccount, pWinner.szName, pLoser.szAccount, pLoser.szName, FactionBattle.TB_COMPETITION_STAGE[szIndex]);
	end
end

-- 开始混战模式
function tbBaseFaction:StartMelee()
	if self:AssignPlayerToMelee() ~= 1 then
		local szMsg = "Số người tham dự không đủ "..FactionBattle.MIN_ATTEND_PLAYER.." người, không thể tiến hành thi đấu."
		self:MsgToMapPlayer(szMsg);
		return 0;
	end
	self.nMeleeCount = 1;	-- 混战次数
	self:MsgToMapPlayer("Đấu trường môn phái chính thức bắt đầu, hình thức đầu tiên là hỗn đấu.")
	self:AddAttendAchive();
	self:BeginAddExp();
end

-- 结束混战模式
function tbBaseFaction:EndMelee()
	self:BoardMsgToMapPlayer("16强已经产生，可以按～键查看对阵表");
	if self.tbArena then
		for i in pairs(self.tbArena) do
			self:CloseArena(i);
		end
	end
	local nDegree = GetFactionBattleCurId();
	if (EventManager.IVER_bOpenTiFu == 1) then
		for nRoute, nNum in pairs(self.tbRouteKills) do
			if nRoute ~= 0 then
				KStatLog.ModifyField("tifu", string.format("门派第%d届\t%s\t杀人数", nDegree, self.tbRoutes[nRoute].szName), "总量", nNum);
			end
		end
		for nRoute, nNum in pairs(self.tbAttendRount) do
			if nRoute ~= 0 then
				KStatLog.ModifyField("tifu", string.format("门派第%d届\t%s\t参加人数", nDegree, self.tbRoutes[nRoute].szName), "总量", nNum);
			end
		end
	end
	self:Calc16thPlayer()
	self:CalcElimination();
	if (EventManager.IVER_bOpenTiFu == 1) then
		for nRoute, nNum in pairs(self.tb16Rount) do
			if nRoute ~= 0 then
				KStatLog.ModifyField("tifu", string.format("门派第%d届\t%s\t16强人数", nDegree, self.tbRoutes[nRoute].szName), "总量", nNum);
			end
		end
	end
	
	self.nMeleeCount = self.nMeleeCount + 1;
	Timer:Register(
		FactionBattle.MELEE_END_ANOUNCE_TIME * Env.GAME_FPS,
		self.AnounceTime,
		self);
end

function tbBaseFaction:StartElimination()
	if not self.nEliminationCount then
		self.nEliminationCount = 0;
	end
	self.nEliminationCount = self.nEliminationCount + 1;
	local szMsg = "";
	if FactionBattle.BOX_NUM[self.nEliminationCount][1] > 2 then
		szMsg = "Vòng "..FactionBattle.BOX_NUM[self.nEliminationCount][1].." bắt đầu, các anh hùng sẽ được đưa vào lôi đài chỉ định.";
	else
		szMsg = "Trận chung kết bắt đầu rồi! Các anh hùng sẽ được đưa vào lôi đài chỉ định."
	end
	self:MsgToMapPlayer(szMsg);
	self:BoardMsgToMapPlayer(szMsg);
	self:AssignPlayerToElimination();	-- 把玩家传入到相应地图
------------------------------------------------------------------------------------------
-- 注册检测函数 xuantao 2010/12/6 15:53:54
	if self.nEliminationTimerId and self.nEliminationTimerId ~= 0 then
		Timer:Close(self.nEliminationTimerId);
		self.nEliminationTimerId = 0;
	end
	-- 注册检测函数，用于检测比赛是否结束了，每秒钟检测一次
	if self.nEliminationCount < 4 then		-- 决赛不需要检测
		self.nEliminationTimerId = Timer:Register(
			FactionBattle.ELIMI_PROTECT_TIME * Env.GAME_FPS,
			self.CheckEliminationIsOver,
			self
		);
	end
------------------------------------------------------------------------------------------
end

-- 结束淘汰赛(冠军提前产生的话就不调用这里)
function tbBaseFaction:EndElimination()
	local nIndex = FactionBattle.BOX_NUM[self.nEliminationCount][1];
	local szMsg = ""
	if nIndex > 2 and FactionBattle._MODEL_OLD == FactionBattle.FACTIONBATTLE_MODLE then
		szMsg = string.format("%s强比赛结束，%s强选手已产生，请晋级选手做好准备，比赛将在7分钟后进行",
			tonumber(nIndex), tonumber(math.ceil(nIndex / 2)));
		self:MsgToMapPlayer(szMsg); 
	end
	if self.tbArena then
		for i in pairs(self.tbArena) do
			self:CloseArena(i);
		end
	end
	self:CalcWinner();
	self:CalcElimination();
	
	if nIndex == 16 then  -- 16强结束~记录8强路线分布
		local nDegree = GetFactionBattleCurId();
		
		if (EventManager.IVER_bOpenTiFu == 1) then
			for nRoute, nNum in pairs(self.tb8Rount) do
				if nRoute ~= 0 then
					KStatLog.ModifyField("tifu", string.format("门派第%d届\t%s\t8强人数", nDegree, self.tbRoutes[nRoute].szName), "总量", nNum);
				end
			end
		end
		
	end
------------------------------------------------------------------------------------
-- 修改xuantao 2010/12/6 14:38:46
	if self.nEliminationTimerId and self.nEliminationTimerId ~= 0 then
		Timer:Close(self.nEliminationTimerId);	-- 关闭检测淘汰赛比赛是否结束的检测定时
		self.nEliminationTimerId = 0;
	end
------------------------------------------------------------------------------------
	-- 开启休息期活动 
	if self.nEliminationCount < 4 then
		if FactionBattle.FACTIONBATTLE_MODLE == FactionBattle._MODEL_OLD then
			self.tbRestActitive:StartRest();		-- 找旗帜活动
			Timer:Register(FactionBattle.ANOUNCE_TIME * Env.GAME_FPS, self.AnounceTime, self);
		else
			self:EliminationAword();			-- 刷宝箱活动
		end
	end
end

function tbBaseFaction:AnounceTime()
	if not self.nEliminationCount then
		self.nEliminationCount = 0;
	end
	if FactionBattle.BOX_NUM[self.nEliminationCount + 1][1] > 2 then
		self:MsgToMapPlayer(FactionBattle.BOX_NUM[self.nEliminationCount + 1][1].."Cách trận chung kết còn 60 giây, mời các anh hùng chuẩn bị");
	else
		self:MsgToMapPlayer("Cách trận chung kết còn 60 giây, mời các anh hùng chuẩn bị")
	end
	return 0;
end

function tbBaseFaction:ShutDown(bCamplete)
	local tbPlayer = self:GetAttendPlayerTable()
	for nPlayerId in pairs(tbPlayer) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if (pPlayer and self.nMapId == pPlayer.nMapId) then
			self:ResumeNormalState(nPlayerId);
		end
	end
	-- 关闭定时
	if self.nTimerId and self.nTimerId > 0 then
		Timer:Close(self.nTimerId);
	end
	self.nState = FactionBattle.NOTHING;
	if bCamplete == 1 then
		if FactionBattle._MODEL_NEW == FactionBattle.FACTIONBATTLE_MODLE then
			self:MsgToMapPlayer("Thi đấu môn phái đã thành công tốt đẹp. Chúc anh em server Thiên Tuyệt Kiếm luôn vui vẻ.");
		self:BoardMsgToMapPlayer("Thi đấu môn phái đã thành công tốt đẹp. Chúc anh em server Thiên Tuyệt Kiếm luôn vui vẻ.");
		else
			self:MsgToMapPlayer("Thi đấu môn phái đã kết thúc");
			self:BoardMsgToMapPlayer("Thi đấu môn phái đã kết thúc");
		end
	else
		self:MsgToMapPlayer("Thi đấu môn phái đóng!");
	end
	
	if self.nTimerId and self.nTimerId ~= 0 and self.nState ~= FactionBattle.NOTHING then
		Timer:Close(self.nTimerId);
	end
	
	if self.nEliminationTimerId and self.nEliminationTimerId ~= 0 then
		Timer:Close(self.nEliminationTimerId);
	end
	
	if self.nChampionAwordTimerId and self.nChampionAwordTimerId ~= 0 then
		Timer:Close(self.nChampionAwordTimerId);
	end
	
	if self.nBoxTimerId and self.nBoxTimerId ~= 0 then
		Timer:Close(self.nBoxTimerId);
	end
	
	--记录门派竞技16强情况Log
	if (MODULE_GAMESERVER) then
		GCExcute({"FactionBattle:WriteLogFor16Player", self.nFaction or 0, self.tb16Player});
	end
	--记录门派竞技16强情况Log
	
	self:DelMapPlayerTable();
	-- 关闭休息活动
	if FactionBattle._MODEL_OLD == FactionBattle.FACTIONBATTLE_MODLE then
		self.tbRestActitive:EndRest();
	end
	self.nTimerId = 0;
	FactionBattle:ShutDown(self.nFaction);
end

-- 空函数~啥都不做
-- 还是做点事情吧，比如说删除领取奖励的NPC等哈
function tbBaseFaction:EndChampionAward()
	local nRest = Timer:GetRestTime(self.nFlagTimerId);
	if nRest > 0 then
		self.nFlagTimerId = 0;
		Timer:Close(self.nFlagTimerId);
	end
	FactionBattle:CancelAwardChampion(self.nFlagNpcId);
end

-- 同步界面需要的数据给玩家
function tbBaseFaction:SyncSportscast(pPlayer, nUsefulTime)
	if pPlayer then
		Dialog:SyncCampaignDate(pPlayer, "FactionBattle", self.tb16Player, nUsefulTime);
	end
	return 1;
end

function tbBaseFaction:EndAll()
	self:ShutDown(0);
	if self.nTimerId ~= 0 then
		Timer:Close(nTimerId);
	end
end

function tbBaseFaction:GetFinalWinner()
	return self.nFinalWinner;
end

--参加次数成就
function tbBaseFaction:AddAttendAchive()
	local tbPlayer =  self:GetAttendPlayerTable();
	local pPlayer = nil;
	for nPlayerId in pairs(tbPlayer) do
		pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer and pPlayer.nMapId == self.nMapId then
			for i = 66, 70 do
				Achievement:FinishAchievement(pPlayer, i);
			end
			Player:AddJoinRecord_DailyCount(pPlayer, Player.EVENT_JOIN_RECORD_MENPAIJINGJI, 1);
		end
	end
	return 0;
end

