-- FileName	: caibaotu.lua
-- Author	: furuilei
-- Time		: 2010-1-25 9:21
-- Comment	: 婚礼小游戏（财宝兔）

local tbNpc = Npc:GetClass("marry_caibaotu");

--====================================================

tbNpc.CAIBAOTU_NPC_ID = 6564;					-- 财宝兔npcid
tbNpc.CAIBAOTU_ITEM_GDPL = {18, 1, 608, 1};		-- 财宝兔道具gdpl
tbNpc.BAOXIANG_GDPL_SMALL = {18, 1, 610, 1};	-- 兑换成的小宝箱gdpl
tbNpc.BAOXIANG_GDPL_BIG = {18, 1, 609, 1};		-- 兑换成的大宝箱gdpl

tbNpc.LIVETIME = 15;		-- 财宝兔的存在时间15秒
tbNpc.TIME_READLINE = 2;	-- 读条时间2秒
tbNpc.TIME_PERCRICLE = 30;	-- 每30秒进行一轮财宝兔活动

-- 对应4个不同档次婚礼地图的财宝兔输出位置配置文件
tbNpc.TB_POS_FILEPATH = {
	[1] = "\\setting\\marry\\caibaotu_1.txt",
	[2] = "\\setting\\marry\\caibaotu_2.txt",
	[3] = "\\setting\\marry\\caibaotu_3.txt",
	[4] = "\\setting\\marry\\caibaotu_4.txt",
	};
	
-- 对应4个不同人数的财宝兔数量
tbNpc.TB_COUNT_CAIBAOTU = {
	[1] = {nMin = 1, nMax = 10, nCount = 10},
	[2] = {nMin = 11, nMax = 30, nCount = 15},
	[3] = {nMin = 31, nMax = 50, nCount = 20},
	[4] = {nMin = 51, nMax = 100, nCount = 25},
	[5] = {nMin = 101, nMax = 150, nCount = 30},
	[6] = {nMin = 151, nMax = 200, nCount = 35},
	[7] = {nMin = 201, nMax = 1000, nCount = 40},
	};

-- 对应4个不同档次婚礼的游戏进行多少次（进行几轮刷财宝兔）
tbNpc.TB_TIMES_CALLNPC = {10, 16, 24, 24};

--====================================================

-- 读取坐标配置文件
function tbNpc:ReadPosFile(nWeddingMapLevel)
	local szFilePath = self.TB_POS_FILEPATH[nWeddingMapLevel];
	if (not szFilePath) then
		return;
	end
	
	local tbPosSetting = Lib:LoadTabFile(szFilePath);
	local tbPos = {};
	-- 加载财宝兔刷出坐标
	for nRow, tbRowData in pairs(tbPosSetting) do
		local tbTemp = {};
		tbTemp[1] = tonumber(tbRowData["PosX"]);
		tbTemp[2] = tonumber(tbRowData["PosY"]);
		table.insert(tbPos, tbTemp);
	end
	return tbPos;
end

-- 开始游戏（刷出财宝兔）
function tbNpc:StartGame(nMapId)
	local nWeddingLevel = Marry:GetWeddingLevel(nMapId);
	local nWeddingMapLevel = Marry:GetWeddingMapLevel(nMapId);
	local tbPosList = self:ReadPosFile(nWeddingMapLevel);
	if (not tbPosList) then
		return 0;
	end
	local nCircleCount = self.TB_TIMES_CALLNPC[nWeddingLevel];
	local nEndTime = GetTime() + nCircleCount * self.TIME_PERCRICLE;
	local nTimerId = Timer:Register(1, self.NextTime, self, nMapId, nEndTime, tbPosList);
	Marry:AddSpecTimer("caibaotu", nTimerId);
end

function tbNpc:GetCaibaotuCount(nMapId)
	if (not nMapId or nMapId <= 0) then
		return 0;
	end
	
	local _, nPlayerCount = KPlayer.GetMapPlayer(nMapId);
	for _, tbInfo in pairs(self.TB_COUNT_CAIBAOTU) do
		if (nPlayerCount >= tbInfo.nMin and nPlayerCount <= tbInfo.nMax) then
			return tbInfo.nCount;
		end
	end
	
	return 0;
end

-- 开始下一轮游戏（刷出另一波财宝兔）
function tbNpc:NextTime(nMapId, nEndTime, tbPosList)
	-- 超过游戏结束时间，游戏over
	if (GetTime() >= nEndTime) then
		self:EndGame(nMapId);
		return 0;
	end
	
	local nWeddingLevel = Marry:GetWeddingLevel(nMapId);
	local nCallNpcCount = self:GetCaibaotuCount(nMapId);
	if (nCallNpcCount > #tbPosList) then
		return 0;
	end
	Lib:SmashTable(tbPosList);
	for nCount = 1, nCallNpcCount do
		local tbPos = tbPosList[nCount];
		local pNpc = KNpc.Add2(self.CAIBAOTU_NPC_ID , 120, -1, nMapId, unpack(tbPos));
		if (pNpc) then
			pNpc.SetLiveTime(self.LIVETIME * Env.GAME_FPS);
		end
	end
	
	return self.TIME_PERCRICLE * Env.GAME_FPS;
end

-- 结束游戏，停止刷财宝兔
function tbNpc:EndGame(nMapId)
	local tbPlayerList = Marry:GetAllPlayers(nMapId);
	if (not tbPlayerList) then
		return 0;
	end
	
	local szMsg = "在典礼场地中已经找不到财宝兔了，大家快来兑奖吧。";
	for _, pPlayer in pairs(tbPlayerList) do
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	end
	
	Marry.MiniGame:NextStep(nMapId);
	return 1;
end

-- 点击财宝兔
function tbNpc:OnDialog()
	if (Marry:CheckState() == 0) then
		return 0;
	end
	
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
	}

	GeneralProcess:StartProcess("游戏中...", self.TIME_READLINE * Env.GAME_FPS,
		{self.GetAwardBox, self, him.dwId, me.szName}, nil, tbEvent);
end

-- 读条结束获取奖励的箱子
function tbNpc:GetAwardBox(nNpdId, szName)
	local pNpc = KNpc.GetById(nNpdId);
	local pPlayer = KPlayer.GetPlayerByName(szName);
	if (not pNpc or not pPlayer) then
		return 0;
	end
	
	pPlayer.AddItem(unpack(Marry.MiniGame.CAIBAOTU_ITEM_GDPL));
	pNpc.Delete();
end
