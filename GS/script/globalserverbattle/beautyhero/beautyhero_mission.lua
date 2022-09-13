-- 文件名  : beautyhero_mission.lua
-- 创建者  : zounan
-- 创建时间: 2010-09-16 09:58:59
-- 描述    : 巾帼英雄赛 MISSION

Require("\\script\\globalserverbattle\\beautyhero\\beautyhero_def.lua");

local Mission = Mission:New();
BeautyHero.Mission = Mission;

Mission.tbSortFunc = {
	__lt = function(tbA, tbB)
		return tbA.nKey > tbB.nKey;
	end
};


function Mission:Init(nMapId,nType, nSeries,nServer)
	self.tbAttendPlayer = nil;
	self.tbMapPlayer 	= nil;
	self.tbArena		= nil;				-- 各个比赛场数据表
	self.tbAttend		= nil;
	self.tbWinner		= {};
	self.tbNextWinner	= {};
	self.tbSort			= {};				-- 即时排序信息表
	self.tb16Player		= {};
	self.tbSportscast	= {};				-- 比赛实况表（赛程界面所需要数据）
	self.nSeries		= nSeries;
	self.nAttendCount	= 0;				-- 参加者计数
	self.nMapId			= nMapId			-- 竞技场地图
	self.nType			= nType;
	self.nState			= 0;				-- 活动状态
	self.nStateJour		= 0;				-- 状态流水
	self.nIndex			= 0;
	self.nTimerId 		= 0;				-- 定时器ID
	self.nFinalWinner	= 0;
	self.nMeleeConut	= 0;
	self.nFightTimerId 	= 0;				-- 进入战斗倒计时（活动全局）
	self.tbRestActitive = Lib:NewClass(BeautyHero.tbMatchRestBase);	-- 休息间活动对象
	self.tbRestActitive:InitRest(nMapId); -- 初始化
	self.tbMisCfg	= {
	--	nFightState	= 1,						-- 战斗状态
	--	tbLeavePos = tbLeavePos, 			
		tbDeathRevPos = {[0]= {
			{self.nMapId, BeautyHero.REV_POINT[1][1],BeautyHero.REV_POINT[1][2]},
			{self.nMapId, BeautyHero.REV_POINT[2][1],BeautyHero.REV_POINT[2][2]},
			{self.nMapId, BeautyHero.REV_POINT[3][1],BeautyHero.REV_POINT[3][2]},
			{self.nMapId, BeautyHero.REV_POINT[4][1],BeautyHero.REV_POINT[4][2]},
			},},		

		nOnDeath 		= 1, 	-- 死亡脚本可用
--		nForbidSwitchFaction = 1, -- 禁止切换门派
--		nForbidStall	= 1,    --禁止摆摊
		nDeathPunish	= 1,
	};
	self.tbGirlVote = {};
	self.tbGirlVote.nTotalTickets = 0;
	self.tbGirlVote.tbVote = {};
	self.tbGroups	= {};	
	self.tbPlayers	= {};
	self.tbPlayerEx = {};  -- 玩家ID表作为索引  用于 查找玩家所在组 以及玩家在该MISSION中所得积分	
	self.tbTimers	= {};
	self.tbVoteAward = {};  -- 赌马奖励 
	self.tbMatchAward = {}; -- 比赛奖励
	self.bChampionAward = 0;
	self.nStateJour = 0;
	self.tbNowStateTimer = nil;
	self.nTimerId = 0;		
	self.tbMisEventList	= 	BeautyHero.STATE_TRANS;	
	self.nState = BeautyHero.NOTHING;
	self.tbBaoXiangNpc = {};
--	self:GoNextState();	
	self:AddNpcQQ();
	self:TimerStart();
	self:CheckMap();
end

-- 获得门派战参加者列表
function Mission:GetAttendPlayerTable()
	return	self:GetPlayerIdList();
--	return 	self:GetPlayerList(nGroupId)
end

-- 从参加者列表中寻找某玩家是否存在 return 0 or 1
function Mission:FindAttendPlayer(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer and self:GetPlayerGroupId(pPlayer) ~= -1 then
		return 1;
	end
	return 0;
end

-- 从参加者列表中删除某玩家
function Mission:DelAttendPlayer(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if self:FindAttendPlayer(nPlayerId) == 0 then
		return 0;
	end
	if pPlayer then
		self:KickPlayer(pPlayer);
	end
	return 1;
end

function Mission:GetAttendPlayerCount()
	return self:GetPlayerCount();
end


function Mission:OnDeath(pKillerNpc)
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return;
	end
	
	local tbPlayer = self.tbPlayerEx;
	if self:FindAttendPlayer(pKillerPlayer.nId) == 1 and self.nState == BeautyHero.MELEE then		-- 混战模式下加分处理
		self.tbPlayerEx[pKillerPlayer.nId].nScore = self.tbPlayerEx[pKillerPlayer.nId].nScore + 1;

		-- 马上原地复活
		me.ReviveImmediately(1);
		-- 战斗状态
		me.SetFightState(0);
		-- PK状态
		me.nPkModel = Player.emKPK_STATE_PRACTISE;
		-- 重投战斗定时
		self.tbPlayerEx[me.nId].nDeathCount = self.tbPlayerEx[me.nId].nDeathCount + 1;
		local nDeath = self.tbPlayerEx[me.nId].nDeathCount;
		if nDeath > #BeautyHero.RETURN_TO_MELEE_TIME then
			nDeath = #BeautyHero.RETURN_TO_MELEE_TIME
		end
		tbPlayer[me.nId].nTimerId = Timer:Register(
			BeautyHero.RETURN_TO_MELEE_TIME[nDeath] * Env.GAME_FPS,
			self.ReturnToMelee,
			self,
			me.nId
		);
		self:UpdateMeleePlayerTimer(me.nId);		-- 被杀者更新时间
		self:UpdateMeleePlayerInfo(pKillerPlayer.nId); -- 杀人者更新信息
		pKillerPlayer.Msg("你击败了<color=yellow>"..me.szName.."<color>，当前连胜为<color=green>"..tbPlayer[pKillerPlayer.nId].nScore);
		me.Msg("你被<color=yellow>"..pKillerPlayer.szName.."<color>击败了，<color=green>"..BeautyHero.RETURN_TO_MELEE_TIME[nDeath].."秒<color>后重新投入战斗！");
	end
	
	if  self.nState == BeautyHero.ELIMINATION then
		Timer:Register(
			BeautyHero.END_DELAY * Env.GAME_FPS,
			self.AutoRevivePlayer,
			self,
			me.nId
		);
		self:KickPlayerFromArena(me.nId);
	end
end		




function Mission:OnJoin()
	--if self.tbPlayerEx[me.nId] then
	--	self.tbPlayerEx[me.nId] = {}; -- 二次加入 清空？
	--end
	
	self.tbPlayerEx[me.nId] = {};	
	local tbPlayerInfo = self.tbPlayerEx[me.nId];
	tbPlayerInfo.nScore 		= 0;	-- 混战积分	(排名依据)
	tbPlayerInfo.nArenaId 		= 0;	-- 混战区ID
	tbPlayerInfo.nTimerId		= 0;	-- 重新进入战斗状态定时ID
	tbPlayerInfo.nDeathCount 	= 0;	-- 死亡次数计数
	tbPlayerInfo.szName 	 	= me.szName;
	--tbPlayerInfo.szAccount = me.szAccount;
end


-- 获取所有玩家列表（竞技地图内的）
function Mission:GetMapPlayerTable()
	self.tbMapPlayer = self.tbMapPlayer or {};

--	if not self.tbMapPlayer then
--		self.tbMapPlayer = {};
	--  没有分帧加经验了 没有必要这样	
	--	for i = 1, BeautyHero.ADDEXP_QUEUE_NUM do
	--		self.tbMapPlayer[i] = {};
	--	end
--	end
	return self.tbMapPlayer;
end

-- 从所有玩家列表中删除某个玩家,nPlayerId 为空则全删
function Mission:DelMapPlayerTable(nPlayerId)
	local tbMapPlayer = self:GetMapPlayerTable();
	if nPlayerId and tbMapPlayer[nPlayerId] then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
		--	self.tbRestActitive:LeaveEvent(pPlayer);
			self:SyncSportscast(pPlayer, 30 * 18);		-- 来开活动，活动界面仍然有效30秒  --TODO
			Dialog:SendBattleMsg(pPlayer,"");
			Dialog:ShowBattleMsg(pPlayer,  0,  0); -- 关闭界面
		end
		tbMapPlayer[nPlayerId] = nil;
	elseif not nPlayerId then
		for nId in pairs(tbMapPlayer) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer then
			--	self.tbRestActitive:LeaveEvent(pPlayer);
				self:SyncSportscast(pPlayer, 30 * 18);		-- 来开活动，活动界面仍然有效30秒
				Dialog:SendBattleMsg(pPlayer,"");			
				Dialog:ShowBattleMsg(pPlayer,  0,  0); -- 关闭界面
			end
			tbMapPlayer[nId] = nil;
		end
	end
end

-- 增加玩家到所有玩家列表
function Mission:AddMapPlayerTable(nPlayerId)
	local tbMapPlayer = self:GetMapPlayerTable();
	if tbMapPlayer[nPlayerId] then
		-- 如果有的话？
	end
	tbMapPlayer[nPlayerId] = 1;
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		self:UpdateMapPlayerInfo(nPlayerId);
		if self.nState > BeautyHero.MATCH_REST then
			self:SyncSportscast(pPlayer);		-- 同步界面数据
		end
		--self.tbRestActitive:JoinEvent(pPlayer); 
	end
end


-- 获得某赛场地的玩家
function Mission:GetArenaPlayer(nArenaId)
	self.tbArena = self.tbArena or {};
	self.tbArena[nArenaId] = self.tbArena[nArenaId] or {};
	return self.tbArena[nArenaId];
end

-- 把某个玩家增加到某个场地列表中
function Mission:AddArenaPlayer(nArenaId, nPlayerId)
	local tbPlayer = self:GetArenaPlayer(nArenaId);
	local bAttend  = self:FindAttendPlayer(nPlayerId);
	if (tbPlayer[nPlayerId]) or bAttend == 0 then
		return 0;
	end
	self.tbPlayerEx[nPlayerId].nArenaId = nArenaId;
	tbPlayer[nPlayerId] = 1;
end

-- 从某场地中删除某个玩家
function Mission:DelArenaPlayer(nArenaId, nPlayerId)
	if not nArenaId or not nPlayerId then
		return;
	end
	
	if (self.nState == BeautyHero.ELIMINATION and self.tbAttend) then
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
function Mission:CheckMap()
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
	for _, pPlayer in pairs(tbPlayer) do
		self:AddMapPlayerTable(pPlayer.nId);	-- 加到地图玩家列表中
	end
end


-- 分阶段定时开始 --不使用MISSION的
function Mission:TimerStart(szFunction)
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
	self.nState = BeautyHero.STATE_TRANS[self.nStateJour][1];
	if self.nState == BeautyHero.NOTHING or self.nState >= BeautyHero.END then	-- 未必开启或者已经结束
		self:ShutDown(1);	-- 关闭活动
		return 0;
	end
	-- 下一阶段定时
	local tbTimer = BeautyHero.STATE_TRANS[self.nStateJour];
	if not tbTimer then
		return 0;
	end
	self.nTimerId = Timer:Register(
		tbTimer[2],
		self.TimerStart,
		self,
		tbTimer[3]
	);	-- 开启新的定时
	self:UpdateMapPlayerInfo();
	return 0;
end

-- 更新地图内玩家信息,nPlayrId为0则更新全部玩家信息
function Mission:UpdateMapPlayerInfo(nPlayerId)
	local nRestTime = Timer:GetRestTime(self.nTimerId);
	local szMsg = ""
	local szTimeFmt = ""; 
	if self.nState == BeautyHero.SIGN_UP then 
		szTimeFmt = "<color=green>Thời gian đăng ký: <color>";
	elseif self.nState == BeautyHero.MELEE then
		if nPlayerId then
			self:UpdateMeleePlayerTimer(nPlayerId, 1);
			self:UpdateMeleePlayerInfo(nPlayerId);
			return 0;
		end
	elseif self.nState == BeautyHero.READY_ELIMINATION or self.nState == BeautyHero.MATCH_REST then
		local nEliminationCount = self.nEliminationCount or 0;
		local szN = "";
		if BeautyHero.BOX_NUM[nEliminationCount + 1][1] > 2 then
			szN = BeautyHero.BOX_NUM[nEliminationCount+1][1].." cường";
		else
			szN = "Chung kết";
		end

		-- 点旗子活动已经有数据界面，不添加界面信息
	--	if self.nEliminationCount and self.nEliminationCount > 0 then
	--		return 0;
	--	end
		szTimeFmt = string.format("<color=green>Vòng %s-Thời gian bắt đầu: <color>",szN);
	elseif self.nState == BeautyHero.ELIMINATION then
		local szN = "";
		if BeautyHero.BOX_NUM[self.nEliminationCount][1] > 2 then
			szN = BeautyHero.BOX_NUM[self.nEliminationCount][1].." cường";
		else
			szN = "Chung kết";
		end
		szTimeFmt = string.format("<color=green>Vòng %s-Thời gian còn lại: <color>", szN);
	elseif self.nState == BeautyHero.CHAMPION_AWARD then
		szTimeFmt = "<color=green>Thời gian nhận thưởng: <color>";
	else
		return ;
	end
	
	if (nPlayerId and nPlayerId > 0) then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId, 1);
		if not pPlayer then
			return ;
		end
		Dialog:SendBattleMsg(pPlayer, szMsg);
		Dialog:SetBattleTimer(pPlayer, szTimeFmt.."<color=white>%s<color>\n", nRestTime);
		Dialog:ShowBattleMsg(pPlayer, 1,  0); --开启界面
	else
		local tbMapPlayer = self:GetMapPlayerTable();
		for nId in pairs(tbMapPlayer) do
			if self.nState == BeautyHero.MELEE then
				self:UpdateMeleePlayerTimer(nId);
				self:UpdateMeleePlayerInfo(nId);
			else
				local pPlayer = KPlayer.GetPlayerObjById(nId);
				if pPlayer then
					Dialog:SendBattleMsg(pPlayer, szMsg);
					Dialog:SetBattleTimer(pPlayer,  szTimeFmt.."<color=white>%s<color>\n", nRestTime);
				end
			end
		end
	end
end

-- 混战时期需要即时同步重投战斗倒计时和战场排名，需要分离信息和倒计时的同步
-- 更新混战玩家信息
function Mission:UpdateMeleePlayerInfo(nPlayerId)
	local nRestTime = Timer:GetRestTime(self.nTimerId);
--	local tbPlayer = self:GetAttendPlayerTable();
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local bAttend = self:FindAttendPlayer(nPlayerId);
	if bAttend == 0 then
		if pPlayer then
			Dialog:SendBattleMsg(pPlayer, "");
		end
		return 0;
	end
	local nSort = self.tbPlayerEx[nPlayerId].nSort;
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
			local szMsg = string.format("当前累计连胜：%s\n\n目前排名：%s", self.tbPlayerEx[nId].nScore, self.tbPlayerEx[nId].nSort);
			Dialog:SendBattleMsg(pPlayer, szMsg);
		end
	end
end

-- 更新混战玩家倒计时
function Mission:UpdateMeleePlayerTimer(nPlayerId, bShowMsg)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	local nRestTime = Timer:GetRestTime(self.nTimerId);
--	local tbPlayer = self:GetAttendPlayerTable();
	local bAttend  = self:FindAttendPlayer(nPlayerId);
	local szTimeFmt = "";
	if self.nMeleeConut == 4 then
		szTimeFmt = "<color=green>离自由 PK 结束剩余：<color><color=white>%s<color>\n";
	else
		szTimeFmt = "<color=green>离下一次按名次分场剩余：<color><color=white>%s<color>\n";
	end
	if bAttend == 1 and self.tbPlayerEx[nPlayerId].nTimerId ~= 0 then
		local nRetTime = Timer:GetRestTime(self.tbPlayerEx[nPlayerId].nTimerId);
		szTimeFmt = szTimeFmt.."\n<color=green>进入战斗倒计时：<color><color=white>%s<color>\n";
		Dialog:SetBattleTimer(pPlayer, szTimeFmt, nRestTime, nRetTime);
	elseif bAttend == 1 and self.tbPlayerEx[nPlayerId].nArenaId > 0 and self.nFightTimerId > 0 then
		local nRetTime = Timer:GetRestTime(self.nFightTimerId);
		szTimeFmt = szTimeFmt.."\n<color=green>进入战斗倒计时：<color><color=white>%s<color>\n";
		Dialog:SetBattleTimer(pPlayer, szTimeFmt, nRestTime, nRetTime);
	else
		Dialog:SetBattleTimer(pPlayer, szTimeFmt, nRestTime);
	end
	if bShowMsg == 1 then
		Dialog:ShowBattleMsg(pPlayer,  1,  0); --开启界面
	end
end

-- 把玩家分配到相关的混战地图,以及玩家各种相关设置
function Mission:AssignPlayerToMelee()
	local tbPlayer = self:GetAttendPlayerTable()
	-- 人数不达最低要求则不进行
	local nPlayerNum = self:GetAttendPlayerCount();
	if nPlayerNum < BeautyHero.MIN_ATTEND_PLAYER then
		return 0;
	end
	
	-- 按等级排序
	self.tbSort = {}
	for _,nPlayerId in ipairs(tbPlayer) do
		local tbTemp = {}
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		if (pPlayer) and (pPlayer.nMapId == self.nMapId) then
			tbTemp.nKey = pPlayer.nLevel + (pPlayer.GetExp() / pPlayer.GetUpLevelExp());
			tbTemp.nPlayerId = nPlayerId;
			tbTemp.tbPlayerInfo = self.tbPlayerEx[nPlayerId];
			tbTemp.pPlayer = pPlayer;
			setmetatable(tbTemp, self.tbSortFunc);
			table.insert(self.tbSort, tbTemp);
		else
			self:DelAttendPlayer(nPlayerId); -- 不可能到这一步吧？
		end
	end
	-- 在场的参加人数不足则不进行
	self.nTotalPlayer = #self.tbSort;
	if self.nTotalPlayer < BeautyHero.MIN_ATTEND_PLAYER then
		return 0;
	end
	-- 排序
	table.sort(self.tbSort);
	-- 计算需要的比赛场地个数
	local nArenaNum = math.ceil(nPlayerNum / BeautyHero.PLAYER_PER_ARENA);
	local nPlayerPerArena = math.ceil(nPlayerNum / nArenaNum);
	-- 等级平均分布地把玩家发送到各个比赛场地
	for i = 1, nArenaNum do
		local j = i;
		while (self.tbSort[j]) do
			local nX, nY = BeautyHero:GetRandomPoint(i)
			self.tbSort[j].pPlayer.NewWorld(self.nMapId, nX, nY);

			if (self.tbSort[j].tbPlayerInfo) then
				self.tbSort[j].tbPlayerInfo.nSort = j;	-- 初始排名
			end

			self:SetPlayerMeleeState(self.tbSort[j].pPlayer);

			self:AddArenaPlayer(i, self.tbSort[j].nPlayerId); 			-- 记录每个战场的玩家
			j = j + nArenaNum;
		end
	end
	-- 混战保护时间
	self.nFightTimerId = Timer:Register(
		BeautyHero.MELEE_PROTECT_TIME * Env.GAME_FPS,
		self.ChangeFight,
		self
	);	
	return 1;
end

function Mission:RestartMelee()
	self.nMeleeConut = self.nMeleeConut + 1;
	local tbPlayer = self:GetAttendPlayerTable();
	local nPlayerCount = 0;
	-- 计算人数
	for _, nPlayerId  in ipairs(tbPlayer) do
		local tbInfo = self.tbPlayerEx[nPlayerId];
		if tbInfo.nTimerId and tbInfo.nTimerId > 0 then
			Timer:Close(tbInfo.nTimerId);
			tbInfo.nTimerId = 0; -- ERROR
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
	local nArenaNum = math.ceil(nPlayerCount / BeautyHero.PLAYER_PER_ARENA) + 1;
	if nPlayerCount <= BeautyHero.MIN_RESTART_MELEE then
		nArenaNum = 1;
	end
	if nArenaNum > BeautyHero.MAX_ARENA then
		nArenaNum = BeautyHero.MAX_ARENA; 
	end
	local nPlayerPerArena = math.ceil(nPlayerCount / nArenaNum);
	local nMaxPlayer = self:GetAttendPlayerCount();
	local nArenaId = 1;
	local nArenaPlayerCount = 0;
	local pSortPlayer = nil;
--	for i = 1, nMaxPlayer do
	for i = 1, #self.tbSort do
		pSortPlayer = KPlayer.GetPlayerObjById(self.tbSort[i].nPlayerId);
		if pSortPlayer and self:FindAttendPlayer(self.tbSort[i].nPlayerId) == 1 then
	--	if self.tbSort[i] and self.tbSort[i].tbPlayerInfo.pPlayer then
		--	local pPlayer = self.tbSort[i].tbPlayerInfo.pPlayer;
			local nX, nY = BeautyHero:GetRandomPoint(nArenaId);
			pSortPlayer.NewWorld(self.nMapId, nX, nY);
			self:SetPlayerMeleeState(pSortPlayer);
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
		BeautyHero.MELEE_RESTART_PROTECT * Env.GAME_FPS,
		self.ChangeFight,
		self
	);	
end

-- 设置玩家预备混战状态（传送进混战区设置）
function Mission:SetPlayerMeleeState(pPlayer)
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
	-- 屏蔽组队、交易、好友界面
	pPlayer.SetDisableTeam(1);
	pPlayer.SetDisableStall(1);
	pPlayer.SetDisableFriend(1);	
	
	-- 死亡惩罚
	pPlayer.SetNoDeathPunish(1);

end

-- 设置玩家淘汰赛预备状态(传送进淘汰区设置)
function Mission:SetPlayerElmState(pPlayer)
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
end

-- 设置玩家进入比赛状态(比赛开始设置)
function Mission:SetPlayerFightState(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
	-- 战斗状态
		pPlayer.SetFightState(1);
	-- PK状态
		pPlayer.nPkModel = Player.emKPK_STATE_BUTCHER;
	-- 计算伤害量(淘汰赛)

		if self:FindAttendPlayer(nPlayerId) ~= 1 then
			return 0;
		end

		if self.nState == BeautyHero.ELIMINATION then			
			self.tbPlayerEx[nPlayerId].nDamageCount = 0;
			pPlayer.StartDamageCounter();			
			local szMsg = string.format("己方受伤害总量：0\n对方受伤害总量：0\n");
			Dialog:SendBattleMsg(pPlayer, szMsg);
			if (not self.nDamageTimer) then
				self.nDamageTimer = Timer:Register(Env.GAME_FPS * 5, self.DamageTimerBreath, self);
			end			
		end
	end
end

function Mission:DamageTimerBreath()
	if (#self.tbAttend <= 0) then
		self.nDamageTimer = nil;
		return 0;
	end
	
	for _, tbplayerId in pairs(self.tbAttend) do
		local pPlayer1 = KPlayer.GetPlayerObjById(tbplayerId[1]);
		local pPlayer2 = KPlayer.GetPlayerObjById(tbplayerId[2]);
		if (pPlayer1 and pPlayer2) then
			local nDamage1 = pPlayer1.GetDamageCounter();
			local nDamage2 = pPlayer2.GetDamageCounter();
		
			local szMsg1 = string.format("己方受伤害总量：%s\n对方受伤害总量：%s\n", nDamage1, nDamage2);
			local szMsg2 = string.format("己方受伤害总量：%s\n对方受伤害总量：%s\n", nDamage2, nDamage1);
			
			Dialog:SendBattleMsg(pPlayer1, szMsg1);
			Dialog:SendBattleMsg(pPlayer2, szMsg2);
		end
	end
end

-- 恢复玩家到正常状态
function Mission:ResumeNormalState(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
	if not pPlayer then
		return;
	end

	if self:FindAttendPlayer(nPlayerId) ~= 1 then
		return 0;
	end
	-- 非战斗状态
	pPlayer.SetFightState(0);
	pPlayer.nPkModel = Player.emKPK_STATE_PRACTISE;
	-- 死亡惩罚
	pPlayer.SetNoDeathPunish(0);
	--  战场标志（同家族可相互攻击）
	pPlayer.nInBattleState	= 0;
	-- 允许组队
	pPlayer.TeamDisable(0);	

	-- 关闭屏蔽组队、交易、好友界面
	pPlayer.SetDisableTeam(0);
	pPlayer.SetDisableStall(0);
	pPlayer.SetDisableFriend(0);		
	
	-- 允许交易
	pPlayer.ForbitTrade(0);
	-- 停止计算伤害量
	self.tbPlayerEx[nPlayerId].nDamageCount = pPlayer.GetDamageCounter();
	pPlayer.StopDamageCounter();
end

-- 所有区域玩家都进入战斗状态
function Mission:ChangeFight()
	self.nFightTimerId = 0;
	if (self.tbArena) then
		for i, tbOne in pairs(self.tbArena) do
			for nPlayerId in pairs(tbOne) do
				self:SetPlayerFightState(nPlayerId);
				if self.nState == BeautyHero.MELEE then
					self:UpdateMeleePlayerTimer(nPlayerId);
				end
			end
		end
	end
	return 0;
end

-- 踢某个正在战斗区的玩家离开战斗区域（只删除记录，不NewWorld）
function Mission:KickPlayerFromArena(nPlayerId)
	if self:FindAttendPlayer(nPlayerId) ~= 1 then
		return 0;
	end	

	local nArenaId = self.tbPlayerEx[nPlayerId].nArenaId;
	if not nArenaId or nArenaId == 0 then
		return;
	end
	self:DelArenaPlayer(nArenaId, nPlayerId);
	self.tbPlayerEx[nPlayerId].nArenaId = 0;
	if self.tbPlayerEx[nPlayerId].nTimerId ~= 0 then
		Timer:Close(self.tbPlayerEx[nPlayerId].nTimerId);
		self.tbPlayerEx[nPlayerId].nTimerId = 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (pPlayer and self.nMapId == pPlayer.nMapId) then
		self:ResumeNormalState(nPlayerId);	-- 恢复状态
	end
	
	local nRet = self:CheckPlayerNumInArena(nArenaId);
	if nRet ~= 1 then		-- 结束该混战区域活动
		if self.nState == BeautyHero.ELIMINATION and self.tbNextWinner[nArenaId] == -1 then
			local tbOnlyPlayer = self:GetArenaPlayer(nArenaId);
			for nWinnerId in pairs(tbOnlyPlayer) do	-- 只有一个人了
				self:SetEliminationWinner(nArenaId, nWinnerId, nPlayerId);
			end
		end
		self:MsgToArenaPlayer(nArenaId, "胜负已分，你将在5秒后传回到外场！");
		Timer:Register(
			BeautyHero.END_DELAY * Env.GAME_FPS,
			self.CloseArena,
			self,
			nArenaId
			);
		
	end
end


-- 重新投入战斗定时函数
function Mission:ReturnToMelee(nPlayerId)
	if self:FindAttendPlayer(nPlayerId) ~= 1 then
		return 0;
	end
	if self.tbPlayerEx[nPlayerId] then
		self.tbPlayerEx[nPlayerId].nTimerId = 0;
		self:SetPlayerFightState(nPlayerId);
		self:UpdateMeleePlayerTimer(nPlayerId);
	end
	return 0;
end

-- 自动重生(淘汰阶段)
function Mission:AutoRevivePlayer(nPlayerId)
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
function Mission:CheckPlayerNumInArena(nArenaId)
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
function Mission:CloseArena(nArenaId)
	local tbPlayer = self:GetAttendPlayerTable();
	local tbArenaPlayer = self:GetArenaPlayer(nArenaId);
	for nPlayerId in pairs(tbArenaPlayer) do
		self:DelArenaPlayer(nArenaId, nPlayerId)
		if self:FindAttendPlayer(nPlayerId) == 1 then
			self.tbPlayerEx[nPlayerId].nArenaId = 0;
			if self.tbPlayerEx[nPlayerId].nTimerId ~= 0 then
				Timer:Close(self.tbPlayerEx[nPlayerId].nTimerId);
			end
			self.tbPlayerEx[nPlayerId].nTimerId = 0;
		end
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if (pPlayer and self.nMapId == pPlayer.nMapId) then
			self:ResumeNormalState(nPlayerId);
		end
		if pPlayer then
			BeautyHero:TrapIn(pPlayer);
		end
	end
	self.tbArena[nArenaId] = nil;
	return 0;
end

-- 给在 某比赛场区 中的玩家发送消息
function Mission:MsgToArenaPlayer(nArenaId, szMsg)
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
end

-- 给地图内的玩家发送消息
function Mission:MsgToMapPlayer(szMsg)
	if self.tbMapPlayer then
		for nPlayerId in pairs(self.tbMapPlayer) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				pPlayer.Msg(szMsg);
			end
		end
	end
end

function Mission:BoardMsgToMapPlayer(szMsg)
	if self.tbMapPlayer then
		for nPlayerId in pairs(self.tbMapPlayer) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				Dialog:SendBlackBoardMsg(pPlayer, szMsg);
			end
		end
	end
end

-- 淘汰某个玩家
function Mission:WashOutPlayer(nPlayerId)
	if self:FindAttendPlayer(nPlayerId) == 1 then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if (pPlayer and self.nMapId == pPlayer.nMapId) then
			self:ResumeNormalState(nPlayerId);
		end
		self:DelAttendPlayer(nPlayerId);
	end
end

-- 计算16强
function Mission:Calc16thPlayer()
	local pPlayer = nil;
	local nCount = 1;
	local tb16thPlayer = {};
	local n = 1;
	local m = 1;
	
	while (#tb16thPlayer < 16 and self.tbSort[m]) do
		pPlayer = KPlayer.GetPlayerObjById(self.tbSort[m].nPlayerId);	
		--if pPlayer and pPlayer.nMapId == self.nMapId then
		if pPlayer and self:FindAttendPlayer(self.tbSort[m].nPlayerId) == 1 then
			tb16thPlayer[#tb16thPlayer + 1] = self.tbSort[m].nPlayerId;
			n = n + 1;
			-- 加honor
			self:AddPlayerHonor(pPlayer, 2);
			-- 记录LOG
			StatLog:WriteStatLog("statlog", "beautyleague", "leagueranking", pPlayer.nId, #tb16thPlayer);			
		end
		m = m + 1;
	end
	local nPlayerNum = #tb16thPlayer;
	for i = 1, 8 do
		self.tbWinner[2 * i - 1] = tb16thPlayer[BeautyHero.ELIMI_VS_TABLE[i][1]] or 0;
		self.tbWinner[2 * i] = tb16thPlayer[BeautyHero.ELIMI_VS_TABLE[i][2]] or 0;
	end

	
	for i = 1, 16 do
		if self:FindAttendPlayer(self.tbWinner[i]) == 1 then 
			self.tbSportscast[self.tbWinner[i]] = {};
			self.tb16Player[i] = self.tbSportscast[self.tbWinner[i]];
			self.tbSportscast[self.tbWinner[i]].szName = self.tbPlayerEx[self.tbWinner[i]].szName;
			self.tbSportscast[self.tbWinner[i]].nWinCount = 0;
		end
	end
end

-- 淘汰赛判断胜者
function Mission:CalcWinner()
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
					if self:FindAttendPlayer(nPlayer1Id) == 1 then
						nDamageCount1 = self.tbPlayerEx[nPlayer1Id].nDamageCount;
					end
					nScore1 = nDamageCount1 * 100 - pPlayer1.nLevel - (pPlayer1.GetExp() / pPlayer1.GetUpLevelExp());		
					Dbg:WriteLog("BeautyHero", "玩家1:"..pPlayer1.szName, nDamageCount1);		
				end
				if pPlayer2 then
					if self:FindAttendPlayer(nPlayer2Id) == 1 then
						nDamageCount2 = self.tbPlayerEx[nPlayer2Id].nDamageCount;
					end
					nScore2 = nDamageCount2 * 100 - pPlayer2.nLevel - (pPlayer2.GetExp() / pPlayer2.GetUpLevelExp());
					Dbg:WriteLog("BeautyHero", "玩家2:"..pPlayer2.szName, nDamageCount2);
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
function Mission:CalcElimination()
	local tbTempPlayer = {};
	for i, nWinnerId in pairs(self.tbWinner) do
		if nWinnerId ~= 0 then
			tbTempPlayer[nWinnerId] = 1;
		end
	end
	local tbPlayer = self:GetAttendPlayerTable();	
	for _,nPlayerId in ipairs(tbPlayer) do
		if not tbTempPlayer[nPlayerId] then
			self:WashOutPlayer(nPlayerId);	-- 淘汰玩家
		end
	end
end


-- 把淘汰赛玩家传送到指定场区，准备比赛
function Mission:AssignPlayerToElimination()
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
		if self:FindAttendPlayer(nPlayer2Id) == 1 and self:FindAttendPlayer(nPlayer1Id) == 1 then
			self.tbAttend[i] = {nPlayer1Id, nPlayer2Id};	
			local tbPoint1, tbPoint2 = BeautyHero:GetElimFixPoint(i);
			self:AddArenaPlayer(i, nPlayer1Id);
			self:AddArenaPlayer(i, nPlayer2Id);
			pPlayer1.NewWorld(self.nMapId, unpack(tbPoint1));
			self:SetPlayerElmState(pPlayer1);
			pPlayer2.NewWorld(self.nMapId, unpack(tbPoint2));
			self:SetPlayerElmState(pPlayer2);
		elseif self:FindAttendPlayer(nPlayer1Id) == 1 then
			self:SetEliminationWinner(i, nPlayer1Id, nPlayer2Id);
		elseif self:FindAttendPlayer(nPlayer2Id) == 1 then
			self:SetEliminationWinner(i, nPlayer2Id, nPlayer1Id);
		else 	-- 无对手VS无对手
			self.tbNextWinner[i] = 0;	-- 0 为无人晋级
		end
	end
	-- 进入保护时间
	Timer:Register(
		BeautyHero.ELIMI_PROTECT_TIME * Env.GAME_FPS,
		self.ChangeFight,
		self
		);
end

function Mission:SetEliminationWinner(nArenaId, nWinnerId, nLoserId, bCalcDamiage)

	local pWinner = KPlayer.GetPlayerObjById(nWinnerId);
	if not pWinner then
		self.tbNextWinner[nArenaId] = 0
		return 0;
	end
	self.tbNextWinner[nArenaId] = nWinnerId;
	if self.tbSportscast[nWinnerId] then
		self.tbSportscast[nWinnerId].nWinCount = self.tbSportscast[nWinnerId].nWinCount + 1;
	end

	-- 晋级奖励
	local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
	--local tbAttendPlayer = self:GetAttendPlayerTable();
	local nPlayerNum = #tbPlayer;
	--BeautyHero:PromotionAward(self.nMapId, nArenaId, self.nEliminationCount, nWinnerId, nLoserId, nPlayerNum);
	self:AddPlayerHonor(pWinner, self.nEliminationCount + 2);
	-- 公告
	local pLoser = KPlayer.GetPlayerObjById(nLoserId);
	if pLoser then
		pLoser.Msg("你落败了，失去了晋级下一轮的资格");
		Dialog:SendBlackBoardMsg(pLoser, "你落败了，失去了晋级下一轮的资格");
	end
	if self.tbSportscast[nWinnerId].nWinCount >= 4 then
		pWinner.Msg("恭喜你获得冠军！请到地图中央领奖台处领取冠军旗帜");
		self:MsgToMapPlayer("恭喜<color=yellow>"..pWinner.szName.."<color>获得冠军！");
		self:BoardMsgToMapPlayer("恭喜["..pWinner.szName.."]获得冠军，冠军可以到领奖台摘得冠军旗帜");
		--Dialog:SendBlackBoardMsg(pWinner, "你击败了对手，获得了门派竞技冠军！");
		self.nFinalWinner = nWinnerId;
		BeautyHero:FinalWinner(self.nSeries,self.nType,self.nMapId, self.tb16Player);

		self:ChampionAward();
		
		-- 如果没对手而决出冠军则跳过淘汰赛状态
		if self.nState == BeautyHero.READY_ELIMINATION then
			self.nStateJour = self.nStateJour + 1;
		end
		if self.nTimerId and self.nTimerId > 0 then
			Timer:Close(self.nTimerId);
			self:TimerStart();
		end
	--	local szFaction = Player:GetFactionRouteName(pWinner.nFaction);
	--	local szWinMsg = "在"..szFaction.. "的门派竞技决赛中获胜，成为新一届的"..szFaction.."新人王。";
	--	local szLoseMsg = "在"..szFaction.. "的门派竞技决赛中遗憾落败。";
		
	--	pWinner.SendMsgToFriend("Hảo hữu ["..pWinner.szName.."]" ..szWinMsg);
	--	Player:SendMsgToKinOrTong(pWinner, szWinMsg, 1);
		if (pLoser) then
	--		pLoser.SendMsgToFriend("Hảo hữu [".. pLoser.szName.. "]"..szLoseMsg);
	--		Player:SendMsgToKinOrTong(pLoser, szLoseMsg, 1);
		end
		

		Dbg:WriteLogEx(Dbg.LOG_INFO, "BeautyHero", "冠军:", pWinner.szName, pWinner.szAccount);
	else
		Dialog:SendBlackBoardMsg(pWinner, "你击败了对手，获得了晋级下一轮的资格！");
		pWinner.Msg("你击败了对手，获得了晋级下一轮的资格！");
	end
	
	local szMsg = "";
	if (self.tbSportscast[nWinnerId].nWinCount == 1) then

	end
	if (self.tbSportscast[nWinnerId].nWinCount == 2) then
		--半决赛
	--	szMsg = "在"..Player:GetFactionRouteName(pWinner.nFaction).. "的门派竞技赛中进入半决赛。";
	--	pWinner.SendMsgToFriend("Hảo hữu ["..pWinner.szName.. "]".. szMsg);
	--	Player:SendMsgToKinOrTong(pWinner, szMsg, 0);
		
		
	elseif (self.tbSportscast[nWinnerId].nWinCount == 3) then
		--进入决赛
	--	szMsg = "在巾帼英雄赛中进入决赛。";
	--	pWinner.SendMsgToFriend("Hảo hữu ["..pWinner.szName.. "]".. szMsg);
	--	Player:SendMsgToKinOrTong(pWinner, szMsg, 0);
	end
	
	local szLoserName = KGCPlayer.GetPlayerName(nLoserId);
	local szReason;
	if not szLoserName then
		szLoserName = " ";
	end
	if bCalcDamiage and bCalcDamiage == 1 then
		szReason = "伤血量取胜";
	else
		szReason = "直接击败";
	end
	local szQiang = "不明"; 
	if BeautyHero.BOX_NUM[self.nEliminationCount] then
		szQiang = BeautyHero.BOX_NUM[self.nEliminationCount][1].."强";
	end 
	local szMsg = string.format("在%s比赛击败%s, 原因为%s", szQiang,szLoserName, szReason)
--	pWinner.PlayerLog(Log.emKPLAYERLOG_TYPE_FACTIONSPORTS, szMsg)

	-- 
	self:UpdateNpcQQ(nArenaId, pWinner);

	-- 同步数据
	for i, pPlayer in pairs(tbPlayer) do
		self:SyncSportscast(pPlayer);	
	end
	Dbg:WriteLog("BeautyHero", "SetWinner", "FactionId:"..pWinner.nFaction, pWinner.szName..szMsg, nArenaId or 0);
	StatLog:WriteStatLog("statlog", "beautyleague", "winner", nWinnerId, szLoserName);
end


-- 开始混战模式
function Mission:StartMelee()
	--记录LOG 
	Dbg:WriteLog("BeautyHero", "BeginMatch", self.nSeries, "PlayerNum:"..(self:GetAttendPlayerCount()));	
	
	if self:AssignPlayerToMelee() ~= 1 then  -- 不够人就不开
		Dbg:WriteLog("BeautyHero", "BeginMatchFail",self.nSeries);
		local szMsg = string.format("由于在场的参加人数未达%d人，巾帼英雄赛不能开启！",BeautyHero.MIN_ATTEND_PLAYER);
		self:MsgToMapPlayer(szMsg);
		return 0;
	end
	
	self:AddPlayerAttendTimes();

	local nSeries = self.nSeries;
	if self.nType ==  BeautyHero.emMATCHTYPE_MELEE then
		nSeries = 0;
	end
	
	for  _, pPlayer in pairs(self:GetPlayerList()) do
		self:AddPlayerHonor(pPlayer, 1);
		StatLog:WriteStatLog("statlog", "beautyleague", "joinleague", pPlayer.nId, nSeries);	
	end	
	
	self:MsgToMapPlayer("巾帼英雄赛正式开始！首先进入自由切磋阶段")
end

-- 结束混战模式
function Mission:EndMelee()

	self:BoardMsgToMapPlayer("16强已经产生。各位可以给喜欢的人投票");
	if self.tbArena then
		for i in pairs(self.tbArena) do
			self:CloseArena(i);
		end
	end
--	local nDegree = GetBeautyHeroCurId();
--	for  _, pPlayer in pairs(self:GetPlayerList()) do
--		self:AddPlayerHonor(pPlayer, 1);
--	end

	self:Calc16thPlayer();
	self:CalcElimination();
	Timer:Register(8 * 60 * 18, self.AnounceTime, self);
end

function Mission:StartElimination()
	self.tbRestActitive:CloseRest();
	self.nEliminationCount = (self.nEliminationCount or 0) + 1;
	if self.nEliminationCount == 1 then
		local tbPlayer = KPlayer.GetMapPlayer(self.nMapId);
		for i, pPlayer in pairs(tbPlayer) do
			self:SyncSportscast(pPlayer);	
		end
	end
	
	local szMsg = "";
	if BeautyHero.BOX_NUM[self.nEliminationCount][1] > 2 then
		szMsg = BeautyHero.BOX_NUM[self.nEliminationCount][1].."强比赛开始了！参赛选手将被传入指定擂台";
	else
		szMsg = "最终决赛开始了！参赛选手将被传入指定擂台"
	end
	self:MsgToMapPlayer(szMsg);
	self:BoardMsgToMapPlayer(szMsg);
	self:AssignPlayerToElimination();
end

-- 结束淘汰赛(冠军提前产生的话就不调用这里)
function Mission:EndElimination()
	local nIndex = BeautyHero.BOX_NUM[self.nEliminationCount][1];
	local szMsg = ""
	if nIndex > 2 then
		szMsg = string.format("%s强比赛结束，%s强选手已产生，请晋级选手做好准备，比赛将在5分钟后进行",
			tonumber(nIndex), tonumber(math.ceil(nIndex / 2)))
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
	end
	-- 开启休息期活动 
	if self.nEliminationCount < 3 then
		self.tbRestActitive:StartRest();
		Timer:Register(BeautyHero.ANOUNCE_TIME * Env.GAME_FPS, self.AnounceTime, self);
	end
	
	--奖励在这里搞？
	if self.nEliminationCount == 4 then
		self:ChampionAward();
	end
end

function Mission:AnounceTime()
	if not self.nEliminationCount then
		self.nEliminationCount = 0;
	end
	if BeautyHero.BOX_NUM[self.nEliminationCount + 1][1] > 2 then
		self:MsgToMapPlayer(BeautyHero.BOX_NUM[self.nEliminationCount + 1][1].."强淘汰赛还有60秒请晋级选手做好准备");
	else
		self:MsgToMapPlayer("最终决赛淘汰赛还有60秒请晋级选手做好准备")
	end
	return 0;
end

function Mission:ShutDown(bComplete)
	bComplete = bComplete or 0;
	local tbPlayer = self:GetAttendPlayerTable()
	for _, nPlayerId in ipairs(tbPlayer) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if (pPlayer and self.nMapId == pPlayer.nMapId) then
			self:ResumeNormalState(nPlayerId);
		end
	end
	self:ClearGuanjunBaoXiang();
	self.nState = BeautyHero.NOTHING;


	if bComplete == 1 then
		self:MsgToMapPlayer("此次巾帼英雄比赛圆满结束！");
		self:BoardMsgToMapPlayer("此次巾帼英雄比赛圆满结束！");
	--	BeautyHero:UpdateBeautyHeroLadder();
	else
		self:MsgToMapPlayer("巾帼英雄比赛关闭！");
	end

	self:DelNpcQQ();
	-- 关闭休息活动
	self.tbRestActitive:CloseRest();
	self:DelMapPlayerTable();
	BeautyHero:ShutDown(self.nMapId,self.nSeries);
	self.nTimerId = 0;
	self:Close();
end

-- 空函数~啥都不做
function Mission:EndChampionAward()
end

-- 同步界面需要的数据给玩家
function Mission:SyncSportscast(pPlayer, nUsefulTime)
	if pPlayer then
		Dialog:SyncCampaignDate(pPlayer, "BeautyHero", self.tb16Player, nUsefulTime);
	end
	return 1;
end

function Mission:EndGame()
	if self.nTimerId ~= 0 then
		Timer:Close(self.nTimerId);
	end	

	self.nTimerId = 0;	
	self:ShutDown(0);
end

function Mission:GetFinalWinner()
	return self.nFinalWinner;
end

function Mission:AddPlayerHonor(pPlayer,nState)
	if GLOBAL_AGENT then -- 全局服不需要吧
		return;
	end

	local tbHonorInfo = BeautyHero.HONOR_TABLE[self.nType];
	local szTmp = "进入";
	if nState == 1 then
		szTmp = "参加";
	end
	local szTips = "淘汰赛";
	local nIndex = nState - 2;
	if nIndex >= 0 then
		szTips = BeautyHero.AWARD_VOTER[nIndex].szName;
		if nIndex == 3 then
			szTips = "决赛";
		end
	end
	local nAddHonor   = tbHonorInfo[nState];
	
	local nCurHonor = PlayerHonor:GetPlayerHonorByName(pPlayer.szName, PlayerHonor.HONOR_CLASS_BEAUTYHERO, 0);
	PlayerHonor:SetPlayerHonorByName(pPlayer.szName, PlayerHonor.HONOR_CLASS_BEAUTYHERO, 0, nCurHonor + nAddHonor);
	pPlayer.Msg(string.format("恭喜你%s<color=yellow>%s<color>，获得<color=yellow>%d<color>点积分",szTmp,szTips,nAddHonor));
end

-- ?gc PlayerHonor:OnSchemeUpdateBeautyHeroHonorLadder()

function Mission:AddNpcQQ()
	self.tbQiqi = {};
	
	local pNpc = nil;
	for nArena,tbData in pairs(BeautyHero.tbNpcPoint) do
	 	pNpc = KNpc.Add2(BeautyHero.NPCID_QIQI, 100, -1, self.nMapId ,tbData[1], tbData[2], 0, 0, 0);
		if pNpc then
			pNpc.GetTempTable("BeautyHero").nArena = nArena;
			pNpc.GetTempTable("BeautyHero").szName = "";
			self.tbQiqi[nArena] = pNpc.dwId;
		else
			print("[err] BeautyHero Mission :AddNpcQQ");
		end
	end	
end

function Mission:DelNpcQQ()
	local pNpc = nil;
	for nArena, nNpcId in pairs(self.tbQiqi or {}) do
		pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.Delete();
		end		
	end
	self.tbQiqi = {};
end

function Mission:UpdateNpcQQ(nArenaId, pWinner)
	local nNpcId = self.tbQiqi[nArenaId];
	local pNpc = nil;
	if nNpcId ~= 0 then
		pNpc = KNpc.GetById(nNpcId);	
		if pNpc then
			pNpc.Delete();
		end
	end
	self.tbQiqi[nArenaId] = 0;
	local tbData = BeautyHero.tbNpcPoint[nArenaId];
	pNpc = KNpc.Add2(BeautyHero.NPCID_QIQI, 100, -1, self.nMapId ,tbData[1], tbData[2], 0, 0, 0);
	if pNpc then
		pNpc.GetTempTable("BeautyHero").nArena = nArenaId;
		pNpc.GetTempTable("BeautyHero").szName = pWinner.szName;
		pNpc.SetTitle(string.format("%s的粉丝",pWinner.szName));
		self.tbQiqi[nArenaId] = pNpc.dwId;
		pNpc.Sync();
	else
		print("[err] BeautyHero Mission :UpdateNpcQQ",nArenaId);
	end	
end

function Mission:AddGuanjunBaoXiang()
	self.tbBaoXiangNpc = {};	
	for nIndex, tbInfo in ipairs(BeautyHero.tbGuanjunbaoxiangPoint) do
		local pNpc = KNpc.Add2(BeautyHero.NPCID_GUANJUNBAOXIANG, 100, -1, self.nMapId ,tbInfo[1] , tbInfo[2], 0, 0, 0);
		if  pNpc then
			self.tbBaoXiangNpc[#self.tbBaoXiangNpc+ 1] = pNpc.dwId;
		end
	end	
end

function Mission:ClearGuanjunBaoXiang()
	if self.tbBaoXiangNpc and #self.tbBaoXiangNpc ~= 0 then 
		for nNpcNo=1, #self.tbBaoXiangNpc do
			local pNpc = KNpc.GetById(self.tbBaoXiangNpc[nNpcNo]);
			if pNpc then
				pNpc.Delete();
			end
		end
	end
	self.tbBaoXiangNpc = {};		
end

function Mission:CalcDuBoAward()	
	local tbAward = {};

	if self.tbGirlVote.nTotalTickets > BeautyHero.TICKETS_MAX then
		self.tbGirlVote.nTotalTickets = BeautyHero.TICKETS_MAX;
	end
	
	-- BeautyHero.VOTE_RETURN_MAX 
	
	if self.tbGirlVote.nTotalTickets < BeautyHero.TICKETS_MIN then
		self.tbGirlVote.nTotalTickets = BeautyHero.TICKETS_MIN;
	end
	
	for nIndex , tbData in pairs(BeautyHero.AWARD_VOTER) do
		if nIndex > 0 then
			tbAward[nIndex] = math.ceil(self.tbGirlVote.nTotalTickets * tbData.nFacor);
		end
	end

	local tbRankTicket = {};
	local tbVote = nil;
	for _, tbInfo  in pairs(self.tb16Player) do
		if tbInfo.nWinCount > 0 then
			tbVote = self.tbGirlVote.tbVote[tbInfo.szName];
			if tbVote and tbVote.nTickets >= 0 then
				tbRankTicket[tbInfo.nWinCount] = (tbRankTicket[tbInfo.nWinCount] or 0)	+ tbVote.nTickets;
			end
		end
	end

	local tbInfo = nil;
	local nCaclBindCoin = 0;
	-- 先不计算  冠军的
	for i = 1, 16 do
	  tbInfo = self.tb16Player[i];
	  if tbInfo and tbInfo.nWinCount > 0 and tbInfo.nWinCount < 4 then
	  		nCaclBindCoin = nCaclBindCoin + self:CalcAwardForVoter(tbInfo.szName,tbAward[tbInfo.nWinCount],tbInfo.nWinCount,tbRankTicket[tbInfo.nWinCount]);	   	
	  end
	end		
	
	--计算总奖池
	local nTotalFacor = 0;
	for _ ,tbInfo in pairs(BeautyHero.AWARD_VOTER) do		
		nTotalFacor = nTotalFacor + tbInfo.nFacor;
	end


	for i = 1, 16 do
	  tbInfo = self.tb16Player[i];
	  if tbInfo and  tbInfo.nWinCount == 4 then
	  		nCaclBindCoin =  self:CalcAwardForVoter(tbInfo.szName,math.ceil((self.tbGirlVote.nTotalTickets * nTotalFacor * 100 - nCaclBindCoin)/100),tbInfo.nWinCount,tbRankTicket[tbInfo.nWinCount],1);	
	  end
	end		
	
end


function Mission:CalcAwardForVoter(szPlayerName,nPlayerAward, nWinCount,nRankTickets,bCamp)
	local nCaclBindCoin = 0;
	local szWinName = BeautyHero.AWARD_VOTER[nWinCount].szName;
	if not szWinName then
		print("【err】 CalcAwardForVoter" , nWinCount);
		return 0;
	end
	
	local tbVote = self.tbGirlVote.tbVote[szPlayerName];
	-- 没人投..
	if not tbVote or tbVote.nTickets <= 0 then
		return 0;
	end
	if not nRankTickets or nRankTickets == 0 then
		return 0;
	end

	local pPlayer = nil;
	local nPlayerId = 0;	
	local nBindCoin = 0;
	for  szFanName, nTickets in pairs(tbVote.tbFans) do
		nBindCoin = math.floor((nPlayerAward / nRankTickets * nTickets*100));
		if not bCamp or bCamp ~= 1 then
			if nBindCoin > nTickets * BeautyHero.VOTE_RETURN_MAX * 100 then
				nBindCoin = nTickets * BeautyHero.VOTE_RETURN_MAX * 100;
			end
		end
		
		nCaclBindCoin = nCaclBindCoin + nBindCoin;
		
		Dbg:WriteLogEx(Dbg.LOG_INFO, "BeautyHeroPK", "赌马奖励获得",szFanName, nBindCoin);	

		self.tbVoteAward[szFanName] = self.tbVoteAward[szFanName] or {};
		table.insert(self.tbVoteAward[szFanName],	{szPlayerName = szPlayerName,szWinName = szWinName, nBindCoin = nBindCoin,bHaveGet = 0,});
	
		if GLOBAL_AGENT then
			nPlayerId	= KGCPlayer.GetPlayerIdByName(szFanName);
			pPlayer = KPlayer.GetPlayerByName(szFanName);
			if not nPlayerId or nPlayerId == 0 then
				Dbg:WriteLogEx(Dbg.LOG_INFO, "BeautyHeroPK", "找不到该玩家",szFanName);	
			else
				BeautyHero:AddGlobalRestAward(nPlayerId,nBindCoin, pPlayer);
			end
		end	
	end	
	return nCaclBindCoin;
end

function Mission:CalcMatchAward()
	local tbInfo = nil;	
	local nPlayerId	= nil;
	for i = 1, 16 do
	  tbInfo = self.tb16Player[i];
	  if tbInfo then
	  	Dbg:WriteLogEx(Dbg.LOG_INFO, "BeautyHeroPK", "MatchRank", tbInfo.szName, tbInfo.nWinCount);
	  	self.tbMatchAward[tbInfo.szName] = {nWinCount = tbInfo.nWinCount, bHaveGet = 0};
	  	if GLOBAL_AGENT then
	  		nPlayerId = KGCPlayer.GetPlayerIdByName(tbInfo.szName);
	  		if nPlayerId and nPlayerId ~= 0 then
	 			BeautyHero:SetGlobalMatchAward(nPlayerId,tbInfo.nWinCount + 1);
	 		end
	 	end
	  end
	end	
end


function Mission:AddPlayerAttendTimes()
	local tbPlayer = self:GetPlayerList();	
	local nCurWeek = tonumber(GetLocalDate("%Y%W"));
	for _, pPlayer in pairs(tbPlayer) do
		BeautyHero:AddAttendTimes(pPlayer);
	end
end

function Mission:ChampionAward()
	if self.bChampionAward == 1 then
		return;
	end
	
	self.bChampionAward = 1;	
	self:CalcDuBoAward();
	self:CalcMatchAward();
	if not GLOBAL_AGENT then
		BeautyHero:UpdateBeautyHeroLadder();
	end		
end