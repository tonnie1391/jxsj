-------------------------------------------------------------------
--File: 		factionbattle_base_new.lua
--Author: 		xuantao
--Date: 		2010/12/3 15:36:53
--Describe:	门派战定义更新
-------------------------------------------------------------------

if not FactionBattle then
	FactionBattle = {};
end

local tbBaseFaction	=  FactionBattle.tbBaseFaction or {};	-- 	各门派的门派战基类
FactionBattle.tbBaseFaction = tbBaseFaction;
-- 开始晋级比赛
function tbBaseFaction:StartMelee_New()
	local nTotalCount = 0;
	local aaArena;
	nTotalCount, aaArena = self:Group2Melee();
	if nTotalCount < FactionBattle.MIN_ATTEND_PLAYER or not aaArena then
		local szMsg = "由于在场的参加人数未达"..FactionBattle.MIN_ATTEND_PLAYER.."人，门派竞技不能开启！"
		self:MsgToMapPlayer(szMsg);
		return 0;
	end
	
	self.nEffictivePlayer = nTotalCount;	-- 记录有效玩家数量，用于后面的刷箱子
	self.nMeleeCount = 1;			-- 初始化晋级赛次数
	self:InitSortTable();				-- 初始化排序表
	self:Send2Arena(aaArena, 1);		-- 将玩家送入到混战房间中
	self:MsgToMapPlayer("晋级赛第1/4阶段开始，10秒后开始战斗！");
	self:BoardMsgToMapPlayer("晋级赛第1/4阶段开始，10秒后开始战斗！");
	self:AddAttendAchive();			-- 增加成就
	self:BeginAddExp();				-- 增加经验

	-- 混战保护时间
	self.nFightTimerId = Timer:Register(
		FactionBattle.MELEE_PROTECT_TIME * Env.GAME_FPS,
		self.ChangeFight,
		self
	);
end
-- 获得奖励箱子的个数
function tbBaseFaction:GetAwordBoxNum()
	local nNum = math.ceil(self.nEffictivePlayer * FactionBattle.N_BOX_PERCENT);
	if nNum <= 0 then
		nNum = 1;
	elseif nNum > FactionBattle.N_MAX_BOX_NUMBER then
		nNum = FactionBattle.N_MAX_BOX_NUMBER;
	end
	return nNum;
end

-- 分场地的细节
function tbBaseFaction:GroupDetail(nArena, aPlayers, tbArena)
	local tbTemp = {};
	local tbGroup = {};
	local nNum = nArena;
	assert(nArena and aPlayers and tbArena);
	if not nArena or nArena <= 0 then
		return 0;
	end
	
	for i = 1, nArena do
		if not tbArena[i] then
			tbArena[i] = {};
		end
		tbTemp[i] = tbArena[i];	
	end
	
	local nCount = 1;
	for _, nId in pairs(aPlayers) do
		local nIndex = MathRandom(nNum);
		if nIndex <=0 or nIndex >= nArena then
			nIndex = 1;
		end
		
		table.insert(tbTemp[nIndex], nId);
		table.insert(tbGroup, tbTemp[nIndex]);
		table.remove(tbTemp, nIndex);
		nNum = nNum - 1;
		if #tbTemp == 0 or nNum == 0 then
			nNum = nArena;
			tbTemp = tbGroup;
			tbGroup = {};
		end
	end
end
-- 以随机的方式给数组排序
function tbBaseFaction:RandomSort(tbArray)
	if not tbArray or #tbArray <= 0 then
		return 0;
	end
	local tbTemp = {};
	local nCount = #tbArray;
	while nCount > 0 do
		local nIndex = MathRandom(nCount);
		if nIndex > 0 and nIndex <= nCount then
			table.insert(tbTemp, tbArray[nIndex]);
			table.remove(tbArray, nIndex);
			nCount = nCount - 1;
		end
	end
	for k, v in pairs(tbTemp) do
		tbArray[k] = v;
	end
	return 1;
end

-- 将玩家分场地，并将场地表返回
-- @ret	: nTotalCount, 有效的玩家个数 0, 不符和条件(即错误)
-- @ret	: aArena, 各个场地的分配数组，场地的个数可以由#aArena获得
function tbBaseFaction:Group2Melee()
	local tbPlayer = self:GetAttendPlayerTable()
	-- 人数不达最低要求则不进行
	local nPlayerNum = self:GetAttendPlayuerCount();
	local tbHigher = {};
	local tbLower = {};
	local nTotalCount = 0;
	-- 将高P和低P的玩家区分开
	for nId, tbInfo in pairs(tbPlayer) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer and pPlayer.nMapId == self.nMapId and tbInfo.bEffictive == 1 then
			nTotalCount = nTotalCount + 1;
			tbPlayer[nId].pTempPlayer = pPlayer;
			tbInfo.nSelfCamp = pPlayer.GetCurCamp();
			if pPlayer.GetHonorLevel() >= FactionBattle.HIGHER_LEVEL_PLAYER then
				table.insert(tbHigher, nId);
			else
				table.insert(tbLower, nId);
			end
		end
		-- 超出限制
		if nTotalCount > FactionBattle.MAX_ATTEND_PLAYER then
			break;
		end
	end
	-- 给高P和低P的玩家随机排个序
	self:RandomSort(tbHigher);
	self:RandomSort(tbLower);
	
	local tbArena = {};
	local nArenaNum = 0;
	local nFree = 0;
	-- 确定需要的场次
	nArenaNum = math.floor(nTotalCount / FactionBattle.PLAYER_PER_ARENA);
	nFree = math.floor(nTotalCount % FactionBattle.PLAYER_PER_ARENA);
	if nFree >= FactionBattle.LIMIT_TO_ADD_ARENA or nArenaNum == 0 then
		nArenaNum = nArenaNum + 1;
	end
	
	for i = 1, nArenaNum do
		tbArena[i] = {};
	end
	local nLimit = 1;
	
	-- 将高p的和低p的合并到一个队列中
	 for _, nId in pairs(tbLower) do
	 	table.insert(tbHigher, nId);
	end
	-- 分配高P玩家
	self:GroupDetail(nArenaNum, tbHigher, tbArena);
	-- 分配低P玩家
	--self:GroupDetail(nArenaNum, tbLower, tbArena);
	self.nArenaNum = nArenaNum;	-- 记录混战的场次
	return nTotalCount, tbArena;
end
-- 获取某个竞技场的数据
function tbBaseFaction:GetArenaData(nArena)
	if not self.tbArenaData then
		self.tbArenaData = {};
	end
	if not self.tbArenaData[nArena] then
		self.tbArenaData[nArena] = {};
	end
	return self.tbArenaData[nArena];
end
-- 设置某个竞技场的数据
function tbBaseFaction:SetArenaData(nArena, value)
	if not self.tbArenaData then
		self.tbArenaData = {};
	end
	if not self.tbArenaData[nArena] then
		self.tbArenaData[nArena] = {};
	end
	self.tbArenaData[nArena] = value;
end
-- 将玩家分阵营，并传送到相应的竞技场地
-- @param	: nArena，竞技场编号
-- @param	: aPlayers，竞技场上的玩家ID数组
-- @param	: bFirstMelee，是否是第一场的竞技，因为第一场竞技会给玩家加一些成就
-- @param	: tbArenaData，返回这个场地的数据
function tbBaseFaction:Send2Arena_Detail(nArena, aPlayers, bFirstMelee)
	local tbArenData = {};
	local nCamp = 0;
	local tbPlayer = self:GetAttendPlayerTable();
	-- 设置两大阵营的初始值
	tbArenData[FactionBattle.CAMP_RED] = 0;		-- 阵营积分，给胜利阵营加分提成用
	tbArenData[FactionBattle.CAMP_BLUE] = 0;
	local tbPoints = FactionBattle:GetArenaPoint_New(nArena);
	assert(tbPoints, "没有传入点啊")
	for _, nPlayerId in pairs(aPlayers) do
		local pPlayer = tbPlayer[nPlayerId].pTempPlayer;
		if not pPlayer then
			pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		end
		if pPlayer and pPlayer.nMapId == self.nMapId then
			-- 阵营
			if nCamp == FactionBattle.CAMP_RED then
				nCamp = FactionBattle.CAMP_BLUE;
			else
				nCamp = FactionBattle.CAMP_RED;
			end
			
			tbPlayer[nPlayerId].nArena = nArena;			-- 记录玩家的竞技场ID
			tbPlayer[nPlayerId].OnceScore = 0;			-- 初始设置这次玩家的得分记录
			tbPlayer[nPlayerId].nCamp = nCamp;			-- 记录玩家的阵营ID

			self:AddArenaPlayer(nArena, nPlayerId);
			pPlayer.SetCurCamp(nCamp);				-- 设置玩家的阵营
			pPlayer.NewWorld(self.nMapId, tbPoints[nCamp].TRAPX, tbPoints[nCamp].TRAPY);
			local nTimeNow = FactionBattle.STATE_TRANS[self.nStateJour + 1][2] or 0;
			if nTimeNow > 0 then
				nTimeNow = nTimeNow + GetTime() + 60;		-- 加60(一分钟)好像是因为特殊称号好像是有点问题
				pPlayer.AddSpeTitle(FactionBattle.TB_TITLE[nCamp][1], nTimeNow, FactionBattle.TB_TITLE[nCamp][2]);	-- 给玩家添加称号
			end
			-- 设置玩家的混战状态
			self:SetPlayerMeleeState(pPlayer);			-- 设置初始的晋级状态
			-- TODO:一些其他的操作，比如说传输等
			-- 添加成就
			if bFirstMelee and bFirstMelee == 1 then
				if (pPlayer.GetTrainingTeacher()) then	-- 如果玩家的身份是徒弟，那么师徒任务当中的门派竞技次数加1
					local nNeed_Faction = pPlayer.GetTask(Relation.TASK_GROUP, Relation.TASK_ID_SHITU_FACTION) + 1;
					pPlayer.SetTask(Relation.TASK_GROUP, Relation.TASK_ID_SHITU_FACTION, nNeed_Faction);
				end
				-- 师徒成就：门派竞技
				Achievement_ST:FinishAchievement(pPlayer.nId, Achievement_ST.FACTION);
				FactionBattle:AwardAttender(pPlayer, 1);
				-- 获取玩家的门派路线
				local szZhiYe = self:GetPlayerRouteName(pPlayer);
				-- 数据埋点，记录每个有效的参加者
				StatLog:WriteStatLog("stat_info", "menpaijingj", "join", pPlayer.nId, pPlayer.nFaction, pPlayer.nRouteId, pPlayer.GetHonorLevel());
				Dbg:WriteLog("menpaijingj","join", pPlayer.szAccount, pPlayer.szName, pPlayer.nFaction, pPlayer.nRouteId, pPlayer.GetHonorLevel());
			end
		else
			self:DelAttendPlayer(nPlayerId);
		end
	end
	return tbArenData;
end

-- @desc		: 将分好的场次和玩家传入到相对应的竞技场中，且将玩家分阵营
-- @param	: aaArena，分好了的场地安排aaArena是个数组
-- @ret		: 返回1或0
function tbBaseFaction:Send2Arena(aaArena, bFirstMelee)
	for k, aPlayers in pairs(aaArena) do
		local tbArenaData = self:Send2Arena_Detail(k, aPlayers, bFirstMelee);
		self:SetArenaData(k, tbArenaData);
	end
end
-- 随机刷箱子
-- @param：nTimes刷箱子的次数
-- @param：nMaps在那些点随机的刷箱子(那些区域会刷箱子)
-- @param：nItemNum刷箱子的个数
-- @param：nPickTime拾取箱子需要多少时间
-- @param：nDuiation箱子存在的持续时间
-- @param：nIterval每次刷箱子的间隔时间
-- @param：tbCallBack回调函数				-- 可有可无
-- @param：szFmt用于计时提示的字符串内容	-- 可有可无
-- @param：tbArgs计时提示的时间信息		-- 可有可无
function tbBaseFaction:BrushXiangZi(nTimes,  nMaps, nItemNum, nPickTime, nDuration, nInterval, tbCallBack)
	--local tPoints = FactionBattle.REV_POINT or tbPoints;
	local tbParam = {};
	tbParam.tbTable = FactionBattle;
	tbParam.fnAwardFunction = FactionBattle.GiveABoxPlayer;
	if not nTimes or nTimes <= 0 then
		return 0;
	end
	if nItemNum > 200 then
		nItemNum = 200;
	end
	
	local tbPoint = self:GetBoxArangePoint(nMaps, nItemNum);
	--print("刷箱子的个数为", #tbPoint);
	-- 实际刷箱子的
	Dbg:WriteLog("FactionBattle", "刷箱子", #tbPoint, "门派", self.nFaction);
	for i,point in pairs(tbPoint) do
		Npc.tbXiangZiNpc:AddBox(
				self.nMapId, 
				point.TRAPX, 
				point.TRAPY, 
				nPickTime * Env.GAME_FPS, 
				tbParam,
				1,
				nDuration * Env.GAME_FPS
			);
	end
	self.nBoxTimerId = 0;
	-- 注册
	if nTimes - 1 > 0 then
		self.nBoxTimerId = Timer:Register(
			nInterval * Env.GAME_FPS,
			self.BrushXiangZi,
			self,
			nTimes - 1,
			nMaps,
			nItemNum,
			nPickTime,
			nDuration,
			nInterval,
			tbCallBack
		);
	end
	
	-- 回调
	if tbCallBack then
		Lib:CallBack(tbCallBack);
	end
	return 0;
end
-- 重新开始一场竞技比赛
function tbBaseFaction:ReStartMelee_New()
	local nTotalCount = 0;
	local aaArena;
	self.nMeleeCount = self.nMeleeCount + 1;
	nTotalCount, aaArena = self:Group2Melee();
	-- 活动状态提醒
	local szMsg = string.format("晋级赛第%d/4阶段开始，10秒后开始战斗！", self.nMeleeCount);
	self:MsgToMapPlayer(szMsg);
	self:BoardMsgToMapPlayer(szMsg);
	
	if aaArena and #aaArena > 0 then
		self:Send2Arena(aaArena);
	else
		print("这次分组没有人了，怎么办呢")
		return 0;
	end
	
	-- 混战保护时间
	self.nFightTimerId = Timer:Register(
		FactionBattle.MELEE_PROTECT_TIME * Env.GAME_FPS,
		self.ChangeFight,
		self
	);
end
-- 发送前三轮阵营赛的比赛成绩
function tbBaseFaction:SendMeleeResultMsg()
	local tbPlayer = self:GetAttendPlayerTable();
	if not tbPlayer then
		return;
	end
	
	if self.nMeleeCount < FactionBattle.MELEE_COUNT then		-- 前三轮的晋级比赛结果通知
		for nPlayerId, tbInfo in pairs(tbPlayer) do
			tbInfo.nCamp = 0;	-- 清空阵营状态
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			-- 玩家存在，玩家在本地图，玩家有效
			if pPlayer and pPlayer.nMapId == self.nMapId and tbInfo.bEffictive == 1 then
				local szMsgBlack = string.format("晋级赛第%d/4阶段结束，您获得了%d点门派竞技积分。", self.nMeleeCount, tbInfo.OnceScore);
				local szMsgSys = string.format("您在晋级赛第%d/4阶段中获得了%d点门派竞技积分。门派竞技积分是进入16强的依据。", self.nMeleeCount, tbInfo.OnceScore);
				Dialog:SendBlackBoardMsg(pPlayer, szMsgBlack);
				pPlayer.Msg(szMsgSys);
			end
		end
	else		-- 最终的晋级比赛结果通知
		local tbTemp = {};
		for k, nPlayerId in pairs(self.tbWinner) do
			if nPlayerId ~= 0 then
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if pPlayer and pPlayer.nMapId == self.nMapId and tbPlayer[nPlayerId].bEffictive == 1 then
					tbTemp[nPlayerId] = 1;
					Dialog:SendBlackBoardMsg(pPlayer, "晋级赛结束，恭喜您进入了16强（淘汰赛），加油啊！");
					pPlayer.Msg("晋级赛结束，恭喜您进入了16强（淘汰赛），加油啊！");
					pPlayer.Msg("本阶段您获得了" .. tbPlayer[nPlayerId].nScore .. "点门派竞技积分。");
				end
			end
		end
		for nPlayerId, tbInfo in pairs(tbPlayer) do
			tbInfo.nCamp = 0;	-- 清空阵营状态
			if not tbTemp[nPlayerId] then
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				-- 玩家存在，玩家在本地图，玩家有效
				if pPlayer and pPlayer.nMapId == self.nMapId and tbInfo.bEffictive == 1 then
					Dialog:SendBlackBoardMsg(pPlayer, "晋级赛结束，很遗憾您没进入16强，您可观看下面的比赛并抢宝箱");
					pPlayer.Msg("晋级赛结束，很遗憾您没进入16强，您可观看下面的比赛并抢宝箱");
					pPlayer.Msg("本阶段您获得了" .. tbPlayer[nPlayerId].nScore .. "点门派竞技积分。");
				end
			end
		end
	end
	return 0;
end

-- 暂停一场竞技
-- 将玩家传回到休息区
-- 清除玩家的状态
-- 更新积分
function tbBaseFaction:StopAMelee()
	if self.tbArenaData then
		for i in pairs(self.tbArenaData) do
			self:CalMeleeResult(i);	-- 计算本轮的对战成绩
			self:CloseArena(i);
		end
	end
	if self.nMeleeCount == FactionBattle.MELEE_COUNT then	-- 混战已经结束，现在需要的是休息，准备淘汰赛，休息过程中，顺便刷刷宝箱
		self:BoardMsgToMapPlayer("16强已经产生，可以按～键查看对阵表");
		
		self:Calc16thPlayer()
		self:CalcElimination();

		local szMsg = "8个赛场周围刷出好多宝箱，大家快去捡哦！";
		local tbCallBack = {self.BoxingCallBack, self, szMsg, szMsg};
		local nBoxNum = self:GetAwordBoxNum();
		-- 注册刷宝箱
		self.nBoxTimerId = Timer:Register(
			FactionBattle.N_BOX_INTERVAL_TIME * Env.GAME_FPS,
			self.BrushXiangZi,
			self,
			2,									-- 刷箱子的次数
			8,									-- 指定在那些地图刷箱子
			nBoxNum,								-- 指定耍箱子的个数
			FactionBattle.TAKE_BOX_TIME,			-- 采集箱子需要的时间
			FactionBattle.N_BOX_EXSIT_TIME,			-- 箱子的生命时间
			FactionBattle.N_BOX_INTERVAL_TIME,		-- 刷箱子的间隔时间
			tbCallBack
		);
	end
	-- 发送晋级赛一轮结束的提示信息
	self:SendMeleeResultMsg();
end

-- 初始化排序表，一便一开始就有一个名次表，一玩家等级排序
function tbBaseFaction:InitSortTable()
	local tbPlayer = self:GetAttendPlayerTable();
	self.tbSort = {}
	for nPlayerId,tbPlayerInfo in pairs(tbPlayer) do
		local tbTemp = {}
		local pPlayer = tbPlayerInfo.pTempPlayer;
		if (pPlayer) and (pPlayer.nMapId == self.nMapId) then
			tbTemp.nKey = pPlayer.nLevel + (pPlayer.GetExp() / pPlayer.GetUpLevelExp());
			tbTemp.nPlayerId = nPlayerId;
			tbTemp.tbPlayerInfo = tbPlayerInfo;
			setmetatable(tbTemp, self.tbSortFunc);
			table.insert(self.tbSort, tbTemp);
		else
			self:DelAttendPlayer(nPlayerId);
		end
	end
		-- 排序
	table.sort(self.tbSort);
	for k,value in ipairs(self.tbSort) do
		value.tbPlayerInfo.nSort = k;	-- 初始排名
	end
	-- 在场的参加人数不足则不进行
	self.nTotalPlayer = #self.tbSort;

	if self.nTotalPlayer < FactionBattle.MIN_ATTEND_PLAYER then
		print("参加人数过少，然后就退出了啊");
		return 0;
	end
end
-- 计算竞技场中的阵营比赛结果
function tbBaseFaction:CalMeleeResult(nArena)
	local tbArenaData = self:GetArenaData(nArena);		-- 获取区域数据
	local tbArenaPlayer = self:GetArenaPlayer(nArena);	-- 获取区域玩家
	local tbPlayer = self:GetAttendPlayerTable();			-- 获取参加活动得玩家

	if not tbArenaData or #tbArenaData == 0 then
		return;
	end

	assert(tbArenaData[FactionBattle.CAMP_RED] and tbArenaData[FactionBattle.CAMP_BLUE], "没有阵营数据，搞个毛啊~~");
	local nWinCamp = 0;
	if tbArenaData[FactionBattle.CAMP_RED] > tbArenaData[FactionBattle.CAMP_BLUE] then		-- 红队胜利
		nWinCamp = FactionBattle.CAMP_RED;
	elseif tbArenaData[FactionBattle.CAMP_RED] < tbArenaData[FactionBattle.CAMP_BLUE] then	-- 蓝队胜利
		nWinCamp = FactionBattle.CAMP_BLUE;
	end
	-- 给胜利方的阵营玩家积分提成
	for nPlayerId in pairs(tbArenaPlayer) do
		local tbInfo = tbPlayer[nPlayerId];
		if tbInfo and tbInfo.nCamp == nWinCamp then
			tbInfo.nScore = tbInfo.nScore + tbInfo.OnceScore * FactionBattle.PERCENTAGE_AWORD;			-- 根据玩家本场比赛提成
			tbInfo.OnceScore = tbInfo.OnceScore + tbInfo.OnceScore * FactionBattle.PERCENTAGE_AWORD;
		end
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer and FactionBattle.TB_TITLE[tbInfo.nCamp][1] then	-- 删除玩家称号
			pPlayer.RemoveSpeTitle(FactionBattle.TB_TITLE[tbInfo.nCamp][1]);
		end
	end
end
-- 判断淘汰是否结束
-- 判断各个区域是否还有玩家
function tbBaseFaction:CheckEliminationIsOver()
	if self.nState ~= FactionBattle.ELIMINATION then
		self.nEliminationTimerId = 0;
		return 0;
	end

	local nCount = 0;
	if self.tbArena then
		for k,v in pairs(self.tbArena) do
			nCount = 1;
		end
	end
	
	if nCount == 0 then-- 没有玩家在比赛了，结束比赛
		self.nEliminationTimerId = 0;
		if self.nTimerId and self.nTimerId ~= 0 then
			local nRest = Timer:GetRestTime(self.nTimerId);
			if nRest and nRest > Env.GAME_FPS * 10 then
				Timer:Close(self.nTimerId);
				Timer:Register(10 * Env.GAME_FPS, self.TimerStart, self, "EndElimination");
				self:MsgToMapPlayer("比赛已经结束，10秒钟后进入下一阶段");
			end
		end
	else
		self.nEliminationTimerId = Timer:Register(
			Env.GAME_FPS,
			self.CheckEliminationIsOver,	-- 下次继续检测
			self
		);
	end
	return 0;
end

-- 刷箱子过程中的显示
function tbBaseFaction:BattleTimer2MapPlayers(szFmt, tbParam)
	local tbPlayer = self:GetAttendPlayerTable();
	local tbMapPlayer = self:GetMapPlayerTable();
	for i = 1, FactionBattle.ADDEXP_QUEUE_NUM do
		for nId in pairs(tbMapPlayer[i]) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer and pPlayer.nMapId == self.nMapId then
				Dialog:SetBattleTimer(pPlayer, szFmt, unpack(tbParam));
				Dialog:SendBattleMsg(pPlayer, "");
			end
		end
	end
	return 0;
end

-- 刷箱子的提示。。。
function tbBaseFaction:GetPlayerTimerState(szFmt)
	local szMsgFmt = "";
	local tbParam = {};
	if szFmt then
		
		local nTimeLen = 0;
		if self.nTimerId and self.nTimerId ~= 0 then
			nTimeLen = Timer:GetRestTime(self.nTimerId);
			if nTimeLen and nTimeLen > 0 then
				table.insert(tbParam, nTimeLen);
				szMsgFmt = szMsgFmt .. szFmt;
			end
		end
		
		if self.nChampionAwordTimerId and self.nChampionAwordTimerId ~= 0 then
			nTimeLen = Timer:GetRestTime(self.nChampionAwordTimerId);
			if nTimeLen and nTimeLen >  0 then
				if szMsgFmt ~= "" then
					szMsgFmt = szMsgFmt .. "\n\n";
				end
				if self:GetChampionAwordCount() < FactionBattle.CHAMPION_AWARD_COUNT then
					table.insert(tbParam, nTimeLen);
					szMsgFmt = szMsgFmt .. "<color=green>下一次发奖时间：<color><color=white>%s<color>";
				end
			end
		end
		
		if self.nBoxTimerId and self.nBoxTimerId ~= 0 then
			nTimeLen = Timer:GetRestTime(self.nBoxTimerId);
			if nTimeLen and nTimeLen > 0 then
				table.insert(tbParam, nTimeLen);
				if szMsgFmt ~= "" then
					szMsgFmt = szMsgFmt .. "\n\n";
				end
				szMsgFmt = szMsgFmt .. "<color=green>下一轮宝箱刷出时间：<color><color=white>%s<color>\n\n刷出地点：比武场/决赛场周围/淘汰赛场周围";				
			end
		end
	end
	return szMsgFmt, tbParam;
end

function tbBaseFaction:BoxingCallBack(szMsgBlack, szMsgSys)
	if szMsgSys and szMsgSys  ~= "" then
		self:MsgToMapPlayer(szMsgSys);
	end
	
	if szMsgBlack and szMsgBlack ~= "" then
		self:BoardMsgToMapPlayer(szMsgBlack);
	end
	self:UpdateMapPlayerInfo();
	return 0;
end

-- 淘汰赛结束休息过程中的奖励
function tbBaseFaction:EliminationAword()
	if not self.nEliminationCount then
		return;
	end
	local tbAword = FactionBattle.ELIMINATION_REST_AWORD[self.nEliminationCount];
	if not tbAword then
		return;
	end

	local szMsg = "在淘汰赛场周围刷出了好多宝箱，大家快去捡哦！";

	local tbCallBack = {self.BoxingCallBack, self, szMsg, szMsg};
	local nBoxNum = self:GetAwordBoxNum();

	-- 冠军领奖CD时间
	if self.nEliminationCount == 4 and (not self.nChampionAwordTimerId or self.nChampionAwordTimerId == 0) then
		self.nChampionAwordTimerId = Timer:Register(
			FactionBattle.CHAMPION_AWARD_CD_TIME * Env.GAME_FPS,	-- 冠军领奖CD时间
			self.ChampionAwordCoolDown,
			self, 0);
	end
	if tbAword[3] == 1 then
		self:BrushXiangZi(tbAword[1], tbAword[2], nBoxNum, FactionBattle.TAKE_BOX_TIME,
			FactionBattle.N_BOX_EXSIT_TIME, FactionBattle.N_BOX_INTERVAL_TIME, tbCallBack);
	else
		self.nBoxTimerId = Timer:Register(FactionBattle.N_BOX_INTERVAL_TIME, self.BrushXiangZi, self, tbAword[1], tbAword[2], nBoxNum,
			 FactionBattle.TAKE_BOX_TIME, FactionBattle.N_BOX_EXSIT_TIME, FactionBattle.N_BOX_INTERVAL_TIME, tbCallBack);
	end
end
-- 冠军点击旗帜，刷箱子
function tbBaseFaction:FlushChampionAword(pPlayer, nCount)
	local szMsg = "本届冠军<color=yellow>".. pPlayer.szName .. "<color>发放了奖励，有好多宝箱在领奖台附近";
	self:BoardMsgToMapPlayer(szMsg);
	self:MsgToMapPlayer(szMsg);
	local nCount = self:GetAwordBoxNum();	-- 箱子的个数是最开始的有效玩家数 * 0.5
	self:BrushXiangZi(1, 0, nCount, FactionBattle.TAKE_BOX_TIME, FactionBattle.N_BOX_EXSIT_TIME, FactionBattle.N_BOX_INTERVAL_TIME);	-- 刷箱子
end
-- 冠军点旗帜的CD时间，定时器
function tbBaseFaction:ChampionAwordCoolDown(nPlayerId)
	self.nChampionAwordTimerId = 0;
	if nPlayerId and nPlayerId == 0 then	-- 冠军发奖CD
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		local szMsg = "";
		if self:GetChampionAwordCount() + 1 == FactionBattle.CHAMPION_AWARD_COUNT then
			szMsg = "冠军可以领取最终奖励了，请点击旗子领取！"
		else	
			szMsg = "冠军可以发下一次奖励了，请点击旗帜发放奖励";
		end
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
		pPlayer.Msg(szMsg);
	else
		print("冠军已经不在了，player Id = ", nPlayerId);
	end
	return 0;
end
-- 获取发放冠军奖励的次数
function tbBaseFaction:GetChampionAwordCount()
	if not self.nChampionAwordCount then
		self.nChampionAwordCount = 0;
	end
	return self.nChampionAwordCount;
end

-- @Desc：	发放冠军奖励，主要是给观众发奖励，并不给冠军发奖励
-- @Param：	pPlayer，冠军玩家对象
function tbBaseFaction:ChampionAword_New(pPlayer)
	if not pPlayer then	-- 不是玩家点的~~闹鬼了~~
		return 0;
	end
	
	if not self.nChampionAwordTimerId then
		self.nChampionAwordTimerId = 0;
	end
	
	if not self.nChampionAwordCount then
		self.nChampionAwordCount = 0;
	end
	
	if self.nChampionAwordCount > FactionBattle.CHAMPION_AWARD_COUNT then	-- 你已经领完了奖励，可以回家吃饭了
		return 0;
	end
	
	if self.nChampionAwordTimerId ~= 0 then	-- ("每次领取奖励后需要三十秒，刚得冠军，你不觉得累吗~~搞笑~~");
		local nRest = Timer:GetRestTime(self.nChampionAwordTimerId);
		local szMsg = "";
		nRest = math.floor(nRest / Env.GAME_FPS);
		if nRest and nRest > 1 then
			szMsg = string.format("到领取下一次奖励还有%d秒", nRest);
			pPlayer.CallClientScript({"UiManager:OpenWindow", "UI_INFOBOARD", szMsg});
			pPlayer.Msg(szMsg);
		end
		return 0;
	end
	
	self.nChampionAwordCount = self.nChampionAwordCount + 1;
	if self.nChampionAwordCount < FactionBattle.CHAMPION_AWARD_COUNT then
		self:FlushChampionAword(pPlayer, self.nChampionAwordCount);
	end
	
	if self.nChampionAwordCount < FactionBattle.CHAMPION_AWARD_COUNT then
		-- 最后一次了
		if self.nChampionAwordCount == FactionBattle.CHAMPION_AWARD_COUNT then
			self:UpdateMapPlayerInfo();
		end
		self.nChampionAwordTimerId = Timer:Register(
			FactionBattle.CHAMPION_AWARD_CD_TIME * Env.GAME_FPS,
			self.ChampionAwordCoolDown,
			self,
			pPlayer.nId);
		-- 发奖励提示
		if self.nChampionAwordCount ~= FactionBattle.CHAMPION_AWARD_COUNT then
			self:UpdateMapPlayerInfo();
		else
			self:UpdateMapPlayerInfo(pPlayer.nId);
		end
	end
	return 0;
end

-- 给玩家发送黑条消息
function tbBaseFaction:SendBlackMsg2Player(nPlayerId, szMsg)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer and szMsg and szMsg ~= "" then
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	end
	return 0;
end
-- 刷箱子时，获取随机的刷箱子的点的细节
function tbBaseFaction:GetArangePoint_Detail(tbBoxPoints, nBoxNum, tbResult)
	if not tbBoxPoints or not tbResult or not nBoxNum then
		assert(false, "param error");
		return 0;
	end
	local tbTemp = {};
	local nNum = 0;
	for _,tbPoint in pairs(tbBoxPoints) do
		table.insert(tbTemp, tbPoint);
		nNum = nNum + 1;
	end
	while true do
		if nBoxNum <= 0 or nNum <= 0 then
			break;
		end
		local nTemp = MathRandom(nNum);
		table.insert(tbResult, tbTemp[nTemp]);
		table.remove(tbTemp, nTemp);
		nNum = nNum - 1;
		nBoxNum = nBoxNum - 1;
	end
	if nBoxNum == 0 then
		return 1;
	else
		return 0;
	end
end
-- 刷箱子时，获取随机的刷箱子的点
function tbBaseFaction:GetBoxArangePoint(nMaps, nBoxNum)
	local nTemp = nMaps;
	local tbPoints = {};
	if nTemp <= 0 then
		nTemp = 1;
	end
	local nAver = math.floor(nBoxNum / nTemp);
	local nYu = math.floor(nBoxNum % nTemp);
	local tbArenaPoint;
	if nMaps == 0 then
		tbArenaPoint = FactionBattle:GetBoxPoint_New(nMaps)
		assert(1 == self:GetArangePoint_Detail(tbArenaPoint, nAver, tbPoints));
	else
		for i = 1, nMaps do
			tbArenaPoint = FactionBattle:GetBoxPoint_New(i)
			local nTemp = nAver;
			if nYu > 0 then
				nTemp = nTemp + 1;
				nYu = nYu - 1;
			end
			assert(1 == self:GetArangePoint_Detail(tbArenaPoint, nTemp, tbPoints));
		end
	end
	return tbPoints;
end
-- 更新玩家在淘汰赛中的显示
function tbBaseFaction:UpdateEliminationPlayerTimer(nPlayerId, bShowMsg)
	local szN = "";
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local szTimeFmt = "";
	if not pPlayer then
		return 0;
	end
	if FactionBattle.FACTIONBATTLE_MODLE == FactionBattle._MODEL_OLD then
		if FactionBattle.BOX_NUM[self.nEliminationCount][1] > 2 then
			szN = FactionBattle.BOX_NUM[self.nEliminationCount][1].."强";
		else
			szN = "冠军";
		end
		szTimeFmt = string.format("<color=green>%s比赛剩余时间：<color>", szN);
	else
		if self.nEliminationCount < 3 then
			szTimeFmt = string.format("<color=green>%d进%d淘汰赛阶段：<color>", 16 / self.nEliminationCount, 8 / self.nEliminationCount);
		elseif self.nEliminationCount == 3 then
			szTimeFmt = "<color=green>半决赛阶段：<color>";
		elseif self.nEliminationCount == 4 then
			szTimeFmt = "<color=green>决赛阶段：<color>";
		end
	end
	local nRestTime = Timer:GetRestTime(self.nTimerId);
	local nRestChangeFight = 0;
	local bInFight = 0;		-- 检测一下是不是待会儿要进入战斗
	if self.nFightTimerId and self.nFightTimerId ~= 0 and self.tbArena then
		for i, tbOne in pairs(self.tbArena) do
			if tbOne[nPlayerId] then
				bInFight = 1;
				break;
			end
		end
	end
	if bInFight == 1 then
		local nFR = Timer:GetRestTime(self.nFightTimerId);
		Dialog:SetBattleTimer(pPlayer, szTimeFmt .. "<color=white>%s<color>\n\n<color=green>进入战斗倒计时：<color><color=white>%s<color>\n", nRestTime, nFR);
	else
		Dialog:SetBattleTimer(pPlayer,  szTimeFmt.."<color=white>%s<color>\n", nRestTime);
	end
	Dialog:SendBattleMsg(pPlayer, "");
	return 0;
end
-- 跟新报名阶段玩家的定时信息
function tbBaseFaction:UpdatePlayerTimer_SignUp(nPlayerId)
	local	szTimeFmt = "<color=green>报名剩余时间：<color><color=white>%s<color>";
	local nTimeRest = Timer:GetRestTime(self.nTimerId);
	local tbParam = {};
	if nTimeRest and nTimeRest ~= 0 then
		table.insert(tbParam, nTimeRest);
		self:UpdatePlayerTimer_Detail(nil, szTimeFmt, tbParam, nPlayerId, 0)
	end
	return 0;
end

-- 更新混战休息时玩家的提示
function tbBaseFaction:UpdatePlayerTimer_MeleeRest(nPlayerId)
	local szTimeFmt = "";
	if self.nMeleeCount and self.nMeleeCount < 4 then
		szTimeFmt = string.format("<color=green>%d/4轮晋级休息阶段：<color>", self.nMeleeCount);
	end
	szTimeFmt = szTimeFmt .. "<color=white>%s<color>";
	local nTimeRest = Timer:GetRestTime(self.nTimerId);
	self:UpdatePlayerTimer_Detail("", szTimeFmt, {[1] = nTimeRest}, nPlayerId, 0);
end
-- 跟新混战时玩家的提示信息
function tbBaseFaction:UpdatePlayerInfo_Melee(nPlayerId)
	if nPlayerId and nPlayerId ~= 0 then
		self:UpdateMeleePlayerInfo(nPlayerId);
		self:UpdateMeleePlayerTimer(nPlayerId);
	else
		local tbMapPlayer = self:GetMapPlayerTable();
		for i = 1, FactionBattle.ADDEXP_QUEUE_NUM do
			for nId in pairs(tbMapPlayer[i]) do
				self:UpdateMeleePlayerInfo(nId);
				self:UpdateMeleePlayerTimer(nId);
			end
		end
	end
end
-- 跟新玩家淘汰赛准备时间的时间显示
function tbBaseFaction:UpdatePlayerTimer_ReadyElimination(nPlayerId)
	local szTimeFmt = "";
	local tbParam;
	if FactionBattle._MODEL_NEW == FactionBattle.FACTIONBATTLE_MODLE then
		if not self.nEliminationCount or self.nEliminationCount == 0 then
			szTimeFmt, tbParam = self:GetPlayerTimerState("<color=green>晋级赛结束：<color><color=white>%s<color>");
		else
			local nCount = self.nEliminationCount;
			local szFmt = "";
			if nCount == 0 then
				nCount = 1;
			end
			if nCount < 3 then
				szFmt = string.format("%d进%d淘汰赛结束休息时间：", 16 / nCount, 8 / nCount);
			elseif nCount == 3 then
				szFmt = "半决赛结束休息时间：";
			elseif nCount == 4 then
				szFmt = "冠军发奖阶段：";
			end
			szFmt = "<color=green>".. szFmt .. "<color>";
			szFmt = szFmt .. "<color=white>%s<color>";
			szTimeFmt, tbParam = self:GetPlayerTimerState(szFmt);
		end
		self:UpdatePlayerTimer_Detail("", szTimeFmt, tbParam, nPlayerId, 0);
	else
		if self.nEliminationCount and self.nEliminationCount > 0 then
			return 0;
		end
		local nRestTime = Timer:GetRestTime(self.nTimerId);
		szTimeFmt = "<color=green>离16强比赛开始剩余时间：<color><color=white>%s<color>"
		self:UpdatePlayerTimer_Detail("", szTimeFmt, {[1] = nRestTime}, nPlayerId, 0);
	end
end
-- 更新玩家在淘汰赛中的定时有关显示
function tbBaseFaction:UpdatePlayerTimer_Elimination(nPlayerId)
	if nPlayerId and nPlayerId ~= 0 then
		self:UpdateEliminationPlayerTimer(nPlayerId);
	else
		local tbMapPlayer = self:GetMapPlayerTable();
		for i = 1, FactionBattle.ADDEXP_QUEUE_NUM do
			for nId in pairs(tbMapPlayer[i]) do
				self:UpdateEliminationPlayerTimer(nId);
			end
		end
	end
	return 1;
end

function tbBaseFaction:UpdatePlayerTimer_ChampionAword(nPlayerId)
	local szTimeFmt = "";
	local nRestTime = Timer:GetRestTime(self.nTimerId);
	local tbParam = {[1] = nRestTime};
	if FactionBattle._MODEL_NEW == FactionBattle.FACTIONBATTLE_MODLE then
		szTimeFmt, tbParam = self:GetPlayerTimerState("<color=green>冠军发奖阶段：<color><color=white>%s<color>");
		self:UpdatePlayerTimer_Detail("", szTimeFmt, tbParam, nPlayerId, 0);
	else
		szTimeFmt = "<color=green>冠军领奖剩余时间：<color><color=white>%s<color>";
		self:UpdatePlayerTimer_Detail("", szTimeFmt, tbParam, nPlayerId, 0);
	end
end

-- 跟新玩家的定时信息
function tbBaseFaction:UpdatePlayerTimer(nPlayerId, szMsg, szFmt, tbParam, bOpen)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	szMsg = szMsg or "";
	if bOpen and bOpen == 1 then
		Dialog:ShowBattleMsg(pPlayer, 1,  0); --开启界面
	end
	if szMsg then
		Dialog:SendBattleMsg(pPlayer, szMsg);
	end
	if szFmt and tbParam then
		Dialog:SetBattleTimer(pPlayer,  szFmt, unpack(tbParam));
	end
end
-- 跟新玩家的定时信息细节
function tbBaseFaction:UpdatePlayerTimer_Detail(szMsg, szFmt, tbParam, nPlayerId, bOpen)
	if nPlayerId and nPlayerId ~= 0 then
		self:UpdatePlayerTimer(nPlayerId, szMsg, szFmt, tbParam, bOpen);
	else
		local tbMapPlayer = self:GetMapPlayerTable();
		for i = 1, FactionBattle.ADDEXP_QUEUE_NUM do
			for nId in pairs(tbMapPlayer[i]) do
				self:UpdatePlayerTimer(nId, szMsg, szFmt, tbParam, bOpen);
			end
		end
	end
	return 1;
end

function tbBaseFaction:GetPlayerRouteName(pPlayer)
	-- 获取玩家的门派路线
	if not pPlayer then
		return "";
	end
	local tbRoutes = KPlayer.GetFactionInfo(pPlayer.nFaction).tbRoutes;
	local szZhiYe = "";
	if tbRoutes and tbRoutes[pPlayer.nRouteId] and tbRoutes[pPlayer.nRouteId].szName then
		szZhiYe = tbRoutes[pPlayer.nRouteId].szName;
	end
	return szZhiYe;
end
