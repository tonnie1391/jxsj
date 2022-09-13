-------------------------------------------------------
-- 文件名　：xkland_gc.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-04-08 15:28:55
-- 文件描述：
-------------------------------------------------------

if not MODULE_GC_SERVER then
	return 0;
end

Require("\\script\\globalserverbattle\\xkland\\xkland_def.lua");

-------------------------------------------------------
-- 战争流程
-------------------------------------------------------

-- 初始化游戏
function Xkland:InitGame_GA()
	
	if self:GetPeriod() ~= self.PERIOD_SELECT_GROUP then
		return 0;
	end
	
	if self:GetWarState() ~= 0 then
		return 0;
	end
	
	-- 清空地图人数
	self:ClearMapPlayerCount_GA()
	
	-- 清空玩家数据
	self:ClearBuffer_GC(GBLINTBUF_XK_PLAYER);
	
	-- 全局设置为战争期
	self.nWarState = 1;
	SetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_PERIOD, self.PERIOD_WAR_OPEN);
	
	-- 召唤gs启动
	GlobalExcute({"Xkland:InitGame_GS"});
end

-- 开始游戏
function Xkland:StartGame_GA()
	
	if self:GetPeriod() ~= self.PERIOD_WAR_OPEN then
		return 0;
	end
	
	if self:GetWarState() ~= 1 then
		return 0;
	end
	
	self.nWarState = 2;
	self.nSyncTimerId = Timer:Register(self.SYNC_REPORT_DATA, self.TimerSyncDate_GA, self);
	
	-- 召唤gs开战
	GlobalExcute({"Xkland:StartGame_GS"});	
end

-- 结束游戏
function Xkland:EndGame_GA()
	
	if self:GetPeriod() ~= self.PERIOD_WAR_OPEN then
		return 0;
	end
	
	if self:GetWarState() ~= 2 then
		return 0;
	end
	
	-- 到时间后排序
	self.tbSortGroup = {};
	self.tbSortPlayer = {};
	
	for nGroupIndex, tbInfo in pairs(self.tbWarBuffer) do	
		table.insert(self.tbSortGroup, {nGroupIndex = nGroupIndex, nPoint = nPoint, nThronePoint = tbInfo.nThronePoint});
		if not self.tbSortPlayer[nGroupIndex] then
			self.tbSortPlayer[nGroupIndex] = {};
		end
		for szPlayerName, tbInfo in pairs(self.tbPlayerBuffer) do
			if nGroupIndex == tbInfo.nGroupIndex then
				table.insert(self.tbSortPlayer[nGroupIndex], {szPlayerName = szPlayerName, nPoint = tbInfo.nPoint});
			end
		end
		table.sort(self.tbSortPlayer[nGroupIndex], function(a, b) return a.nPoint > b.nPoint end);
	end
	table.sort(self.tbSortGroup, function(a, b) return a.nThronePoint > b.nThronePoint end);
	
	-- 胜利方
	local nWinGroup = self.tbSortGroup[1].nGroupIndex;
	
	-- 清除timer
	if self.nSyncTimerId and self.nSyncTimerId > 0 then
		Timer:Close(self.nSyncTimerId);
		self.nSyncTimerId = nil;
	end
	
	self.nWarState = 0;
	SetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_PERIOD, self.PERIOD_WAR_REST);
	
	-- 召唤gs结束
	GlobalExcute({"Xkland:EndGame_GS", nWinGroup});
	
	-- 计算奖励
	local tbCaptain = self.tbGroupBuffer[nWinGroup].tbCaptain;
	local nCastleBox = self:CalcCastleBoxCount();
	local nLingPai = self:CalcLingPaiCount();
	local nChengZhuLingPai = self:CalcChengZhuLingPaiCount();
	
	-- 设置城主数据
	self.tbCastleBuffer.szPlayerName = tbCaptain.szPlayerName;
	self.tbCastleBuffer.szGateway = tbCaptain.szGateway;
	self.tbCastleBuffer.szTongName = tbCaptain.szTongName;
	self.tbCastleBuffer.nPlayerSex = tbCaptain.nPlayerSex;
	self.tbCastleBuffer.nGroupIndex = nWinGroup;
	self.tbCastleBuffer.nCastleBox = nCastleBox;
	self.tbCastleBuffer.nLingPai = nLingPai;
	self.tbCastleBuffer.nChengZhuLingPai = nChengZhuLingPai;
	if not self.tbCastleBuffer.tbHistory then
		self.tbCastleBuffer.tbHistory = {};
	end
	
	local nSession = self:GetSession();
	self.tbCastleBuffer.tbHistory[nSession] = 
	{
		szPlayerName = tbCaptain.szPlayerName,
		szGateway = tbCaptain.szGateway,
	};
	
	self.tbCastleBuffer.tbTong = {};
	for szTmpTongName, _ in pairs(self.tbGroupBuffer[nWinGroup].tbTong) do
		if szTmpTongName ~= tbCaptain.szTongName  then
			self.tbCastleBuffer.tbTong[szTmpTongName] = {};
			self.tbCastleBuffer.tbTong[szTmpTongName].nBox = 0;
			self.tbCastleBuffer.tbTong[szTmpTongName].nLingPai = 0;
		end
	end

	-- log
	self:WritePlayerListLog();
	
	-- 保存数据
	self:SaveBuffer_GC(GBLINTBUF_XK_CASTLE);
	
	-- 通知全区gc
	GC_AllExcute({"Xkland:EndGame_GC", tbCaptain, nCastleBox, nLingPai, nChengZhuLingPai, nWinGroup});
	
	-- 系统绑银清0
	SetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_SYSTEM_MONEY, 0);
	
	-- 更新雕像
	self:UpdateCastleStatue_GC(tbCaptain.szPlayerName, tbCaptain.nPlayerSex, 1);
	
	-- 胜方存下来
	self.nWinGroup = nWinGroup;
end

-- 本服gc收到战争结束
function Xkland:EndGame_GC(tbCaptain, nCastleBox, nLingPai, nChengZhuLingPai, nWinGroup)
	
	-- 影子操作
	self.tbLocalCastleBuffer.szPlayerName = tbCaptain.szPlayerName;
	self.tbLocalCastleBuffer.szGateway = tbCaptain.szGateway;
	self.tbLocalCastleBuffer.szTongName = tbCaptain.szTongName;
	self.tbLocalCastleBuffer.nPlayerSex = tbCaptain.nPlayerSex;
	self.tbLocalCastleBuffer.nGroupIndex = nWinGroup;
	self.tbLocalCastleBuffer.nCastleBox = nCastleBox;
	self.tbLocalCastleBuffer.nLingPai = nLingPai;
	self.tbLocalCastleBuffer.nChengZhuLingPai = nChengZhuLingPai;
	self.tbLocalCastleBuffer.tbTong = {};
	
	if not self.tbLocalCastleBuffer.tbHistory then
		self.tbLocalCastleBuffer.tbHistory = {};
	end
	
	local nSession = self:GetSession();
	self.tbLocalCastleBuffer.tbHistory[nSession] = 
	{
		szPlayerName = tbCaptain.szPlayerName,
		szGateway = tbCaptain.szGateway,
	};
	
	for szTmpTongName, _ in pairs(self.tbLocalGroupBuffer[nWinGroup].tbTong) do
		if szTmpTongName ~= tbCaptain.szTongName then
			self.tbLocalCastleBuffer.tbTong[szTmpTongName] = {};
			self.tbLocalCastleBuffer.tbTong[szTmpTongName].nBox = 0;
			self.tbLocalCastleBuffer.tbTong[szTmpTongName].nLingPai = 0;
		end
	end

	-- 保存映像
	self:SaveBuffer_GC(GBLINTBUF_XKL_CASTLE);
	
	-- 帮助锦囊
	local szGroupName = self:GetGroupNameByIndex(nWinGroup);
	self:UpdateHelpTable(szGroupName, tbCaptain.szPlayerName, tbCaptain.szGateway);
	
	-- 更新雕像
	self:UpdateCastleStatue_GC(tbCaptain.szPlayerName, tbCaptain.nPlayerSex, 0);
end

-- 开启跨服定时公告
function Xkland:StartAnnTimer_GA()
	self:CloseAnnTimer_GA();
	self:Announce_GA();
	self.nAnnTimerId = Timer:Register(10 * 60 * Env.GAME_FPS, self.Announce_GA, self);
end

-- 关闭跨服定时公告
function Xkland:CloseAnnTimer_GA()
	if self.nAnnTimerId and self.nAnnTimerId > 0 then
		Timer:Close(self.nAnnTimerId);
		self.nAnnTimerId = nil;
	end
end

-- 定时公告广播
function Xkland:Announce_GA()
	GC_AllExcute({"Xkland:Announce_GC"});
end

-- 本服gc广播
function Xkland:Announce_GC()
	GlobalExcute({"Xkland:Announce_GS"});
end

-- 中心服战斗公告
function Xkland:BroadCast_GA(szMsg, nType)
	GlobalExcute({"Xkland:OnBroadCast_GS", szMsg, nType});
end

-- 间隔同步数据
function Xkland:TimerSyncDate_GA()
	
	if self:GetWarState() ~= 2 then
		return 0;
	end
	
	self:SaveBuffer_GC(GBLINTBUF_XK_PLAYER);
	self:SaveBuffer_GC(GBLINTBUF_XK_WAR);
	
	GlobalExcute({"Xkland:TimerSyncDate_GS"});
end

-------------------------------------------------------
-- 战斗相关
-------------------------------------------------------

-- gc初始化角色数据
function Xkland:InitPlayer_GA(szPlayerName, nGroupIndex)
	if not self.tbPlayerBuffer[szPlayerName] then
		self.tbPlayerBuffer[szPlayerName] = 
		{
			nGroupIndex = nGroupIndex, 
			nPoint = 0, 
			nKillCount = 0, 
			nCurSeriesKill = 0, 
			nMaxSeriesKill = 0, 
			nRank = 0,
			nProtect = 0,
			nResource = 0,
		};
	end
end

-- gc增加军团积分
function Xkland:AddGroupPoint_GA(nGroupIndex, nPoint)
	if self.tbWarBuffer[nGroupIndex] then
		self.tbWarBuffer[nGroupIndex].nPoint = self.tbWarBuffer[nGroupIndex].nPoint + nPoint;
	end
end

-- gc增加军团王座积分
function Xkland:AddGroupThronePoint_GA(nGroupIndex, nPoint)
	if self.tbWarBuffer[nGroupIndex] then
		self.tbWarBuffer[nGroupIndex].nThronePoint = self.tbWarBuffer[nGroupIndex].nThronePoint + nPoint;
	end
end

-- gc增加玩家积分
function Xkland:AddPlayerPoint_GA(szPlayerName, nPoint)
	local tbPlayer = self.tbPlayerBuffer[szPlayerName];
	if tbPlayer then
		tbPlayer.nPoint = tbPlayer.nPoint + nPoint;
		for i = 1, #self.RANK_POINT do
			if tbPlayer.nPoint < self.RANK_POINT[i][1] then
				tbPlayer.nRank = i - 1;
				break;
			end
		end
		if tbPlayer.nPoint >= self.RANK_POINT[#self.RANK_POINT][1] then
			tbPlayer.nRank = #self.RANK_POINT;
		end
	end
end

-- gc占领资源点
function Xkland:OnGetResouce_GA(szPlayerName, nNewGroup, nOldGroup)
	
	local tbPlayer = self.tbPlayerBuffer[szPlayerName];
	if tbPlayer then
		tbPlayer.nResource = tbPlayer.nResource + 1;
	end
	
	local tbOldWar = self.tbWarBuffer[nOldGroup];
	if tbOldWar then
		tbOldWar.nResource = tbOldWar.nResource - 1;
		if tbOldWar.nResource < 0 then
			tbOldWar.nResource = 0;
		end
	end
	
	local tbNewWar = self.tbWarBuffer[nNewGroup];
	if tbNewWar then
		tbNewWar.nResource = tbNewWar.nResource + 1;
	end
end

-- gc守卫资源点
function Xkland:OnProtectResource_GA(szPlayerName)
	local tbPlayer = self.tbPlayerBuffer[szPlayerName];
	if tbPlayer then
		tbPlayer.nProtect = tbPlayer.nProtect + 1;
	end
end

-- 杀人处理
function Xkland:AddPlayerKill_GA(szPlayerName, nSeriesKill)
	local tbPlayer = self.tbPlayerBuffer[szPlayerName];
	if tbPlayer then
		tbPlayer.nKillCount = tbPlayer.nKillCount + 1;
		if nSeriesKill == 1 then
			tbPlayer.nCurSeriesKill = tbPlayer.nCurSeriesKill + 1;
			if tbPlayer.nCurSeriesKill > tbPlayer.nMaxSeriesKill then
				tbPlayer.nMaxSeriesKill = tbPlayer.nCurSeriesKill;
			end
		else
			tbPlayer.nCurSeriesKill = 1;
		end
	end
end

-- gc增加地图人数
function Xkland:AddMapPlayerCount_GA(nMapId, nCount)
	if self.tbMapPlayerCount[nMapId] then
		self.tbMapPlayerCount[nMapId] = self.tbMapPlayerCount[nMapId] + nCount;
		if self.tbMapPlayerCount[nMapId] < 0 then
			self.tbMapPlayerCount[nMapId] = 0;
		end
	end
	GlobalExcute({"Xkland:SyncMapPlayerCount_GS", self.tbMapPlayerCount});
end

-- gc 清除地图人数
function Xkland:ClearMapPlayerCount_GA()
	for _, nMapId in pairs(self.MAP_LIST) do
		self.tbMapPlayerCount[nMapId] = 0;
	end
	GlobalExcute({"Xkland:SyncMapPlayerCount_GS", self.tbMapPlayerCount});	
end

-------------------------------------------------------
-- 竞拍相关
-------------------------------------------------------

-- 玩家设置数据(积分、排名、箱子)
function Xkland:SetFinalPlayerData(nWinGroup)
	
	-- 防止gc重启后数据丢失
	if not self.tbSortPlayer then
		self.tbSortPlayer = {};
		for nGroupIndex, tbInfo in pairs(self.tbWarBuffer) do	
			if not self.tbSortPlayer[nGroupIndex] then
				self.tbSortPlayer[nGroupIndex] = {};
			end
			for szPlayerName, tbInfo in pairs(self.tbPlayerBuffer) do
				if nGroupIndex == tbInfo.nGroupIndex then
					table.insert(self.tbSortPlayer[nGroupIndex], {szPlayerName = szPlayerName, nPoint = tbInfo.nPoint});
				end
			end
			table.sort(self.tbSortPlayer[nGroupIndex], function(a, b) return a.nPoint > b.nPoint end);
		end
	end
	
	-- 设置玩家数据
	for nGroupIndex, tbSort in pairs(self.tbSortPlayer) do
		
		local tbAward = self.tbGroupBuffer[nGroupIndex].tbAward;
		local nAwardCount = tbAward.nAwardCount ;
		local nMultiple = tbAward.nMultiple;
		
		if nGroupIndex ~= nWinGroup and tbAward.nForceSend ~= 1 then
			nAwardCount = 0;
			nMultiple = 0;
		end
		
		local nTotalBox = 0;
		for nSort, tbInfo in ipairs(tbSort) do
			local nId = KGCPlayer.GetPlayerIdByName(tbInfo.szPlayerName);
			if nId then
				-- 积分
				SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_POINT, tbInfo.nPoint);
				-- 排名
				SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_RANK, nSort);
				-- 军团
				SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_GROUP, 0);
				-- 免费次数
				SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_REVIVAL, 0);
				-- 个人箱子
				local nBoxCount = self:CalcPlayerBoxCount(nSort, nAwardCount, nMultiple);
				local nOwnCount = GetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_BOX) or 0;
				SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_BOX, nOwnCount + nBoxCount);
				nTotalBox = nTotalBox + nBoxCount;
				-- 经验
				local nAddExp = 100 + ((tbInfo.nPoint >= 500) and self:CalcPlayerExp(nSort, #tbSort) or 0);
				local nOwnExp = GetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_EXP) or 0;
				SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_EXP, nOwnExp + nAddExp);
			end
		end
		
		-- 记录返还的跨服绑银
		local nCostMoney = nTotalBox * self.BOX_MONEY;
		local nPreMoney = self:CalcMemberAward(tbAward.nAwardCount, tbAward.nMultiple);
		
		local nBackMoney = nPreMoney - nCostMoney;
		if nBackMoney > 0 then
			local nId = KGCPlayer.GetPlayerIdByName(self.tbGroupBuffer[nGroupIndex].tbCaptain.szPlayerName);
			if nId then
				local nMoney = GetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_BACKMONEY) or 0;
				SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_BACKMONEY, nMoney + nBackMoney);
			end
		end
	end
end

-- 中心服启动竞标
function Xkland:StartCompetitive_GA()
	
	-- 设置玩家数据
	self:SetFinalPlayerData(self.tbCastleBuffer.nGroupIndex);
	
	-- 清竞拍数据
	self:ClearBuffer_GC(GBLINTBUF_XK_COMPETITIVE);
	self:ClearCenterBuffer_GC(self.GA_INTBUF_COMPETITIVE);
	
	-- 清空玩家数据
	self:ClearBuffer_GC(GBLINTBUF_XK_PLAYER);
	
	-- 清空战争数据
	self:ClearBuffer_GC(GBLINTBUF_XK_WAR);
	
	-- 清军团数据
	self:ClearBuffer_GC(GBLINTBUF_XK_GROUP);
	
	-- 清战队数据
	League:ClearLeague(self.LEAGUE_TYPE);
	
	-- 换届换阶段
	SetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_PERIOD, self.PERIOD_COMPETITIVE);
	SetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_SESSION, self:GetSession() + 1);
	
	GC_AllExcute({"Xkland:StartCompetitive_GC"});
end

-- 本服gc处理数据
function Xkland:StartCompetitive_GC()
	
	-- 清军团映像
	self:ClearBuffer_GC(GBLINTBUF_XKL_GROUP);	
end

-- gc收到首领竞拍数据
function Xkland:OnCompetitiveBidding_GC(szPlayerName, nCompetitive, szGateway, szTongName, nPlayerSex, nRight)
	GC_AllExcute({"Xkland:OnCompetitiveBidding_GA", szPlayerName, nCompetitive, szGateway, szTongName, nPlayerSex, nRight});
end

-- 中心服务器处理竞拍数据
function Xkland:OnCompetitiveBidding_GA(szPlayerName, nCompetitive, szGateway, szTongName, nPlayerSex, nRight)
	
	-- global only
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end

	local nExist = 0;
	
	-- 遍历global buffer
	for _, tbInfo in pairs(self.tbCompetitiveBuffer) do
		
		-- 存在该项数据
		if tbInfo.szPlayerName == szPlayerName then
			
			-- 更新数据
			tbInfo.nCompetitive = tbInfo.nCompetitive + nCompetitive;
			tbInfo.szTongName = szTongName;
			tbInfo.nRight = 1;
			nExist = 1;
		
		-- add 剪除其他人的权利	
		elseif tbInfo.szTongName ~= "无" and tbInfo.szTongName == szTongName and tbInfo.nRight == 1 then
			tbInfo.nRight = 0;
		end
	end
	
	-- 不存在插入到末尾
	if nExist == 0 then
		table.insert(self.tbCompetitiveBuffer, {szPlayerName = szPlayerName, szGateway = szGateway, nCompetitive = nCompetitive, szTongName = szTongName, nPlayerSex = nPlayerSex, nRight = nRight});
	end
		
	-- 重新排序
	table.sort(self.tbCompetitiveBuffer, function(a, b) return a.nCompetitive > b.nCompetitive end);
	self:SaveBuffer_GC(GBLINTBUF_XK_COMPETITIVE);
	
	-- 设置大区同步buffer
	local tbSyncSort = {};
	local nMax = ((#self.tbCompetitiveBuffer > self.MAX_GROUP) and self.MAX_GROUP) or #self.tbCompetitiveBuffer;
	for i = 1, nMax do
		tbSyncSort[i] = 
		{
			self.tbCompetitiveBuffer[i].szPlayerName,
			self.tbCompetitiveBuffer[i].szGateway,
			self.tbCompetitiveBuffer[i].nCompetitive,
			self.tbCompetitiveBuffer[i].szTongName,
		};
	end
	self.tbSyncCompBuffer = tbSyncSort;
	self:SaveCenterBuffer_GC(self.GA_INTBUF_COMPETITIVE);
end

-- 创建某个编号的军团
function Xkland:OnCreatGroup_GA(nGroupIndex, szPlayerName, szGateway, szTongName, nPlayerSex, nRight)
	
	-- 先创建战队数据
	local szGroupName = League:GetMemberLeague(self.LEAGUE_TYPE, szPlayerName);
	if not szGroupName then
		szGroupName = string.format("%s的军团", szPlayerName);
		local tbCaptain = 
		{
			nCaptain = 1,
			nGroupIndex = nGroupIndex,
			szPlayerName = szPlayerName,
			nGateWay = tonumber(string.sub(szGateway, 5, 8)),
		};
		self:CreateLeague(szGroupName, nGroupIndex, tbCaptain);
	end
	
	-- 接着创建global buffer数据
	self.tbGroupBuffer[nGroupIndex] = {};
	self.tbGroupBuffer[nGroupIndex].szGroupName = szGroupName;
	self.tbGroupBuffer[nGroupIndex].tbCaptain = 
	{
		szPlayerName = szPlayerName,
		szGateway = szGateway,
		szTongName = szTongName,
		nPlayerSex = nPlayerSex,
	};
	self.tbGroupBuffer[nGroupIndex].tbTong = {};
	self.tbGroupBuffer[nGroupIndex].tbPreTong = {};
	self.tbGroupBuffer[nGroupIndex].nTongCount = 0;
	
	if nRight == 1 then
		self.tbGroupBuffer[nGroupIndex].tbTong[szTongName] = szGateway;
		self.tbGroupBuffer[nGroupIndex].nTongCount = self.tbGroupBuffer[nGroupIndex].nTongCount + 1;
	end
	
	self.tbGroupBuffer[nGroupIndex].tbAward = 
	{
		nAwardCount = 0,
		nMultiple = 0,
		nForceSend = 0,
		nExtraBox = 0,
	};

	-- 战争数据
	self.tbWarBuffer[nGroupIndex] = {nGroupIndex = nGroupIndex, nPoint = 0, nRevivalMoney = 0, nResource = 0, nThronePoint = 0};

	-- 通知所有gc
	GC_AllExcute({"Xkland:OnCreatGroup_GC", nGroupIndex, szGroupName, szPlayerName, szGateway, szTongName, nPlayerSex, nRight});
end

-- 本地gc收到创建军团数据
function Xkland:OnCreatGroup_GC(nGroupIndex, szGroupName, szPlayerName, szGateway, szTongName, nPlayerSex, nRight)
	
	-- 只创建军团映像
	self.tbLocalGroupBuffer[nGroupIndex] = {};
	self.tbLocalGroupBuffer[nGroupIndex].szGroupName = szGroupName;
	self.tbLocalGroupBuffer[nGroupIndex].tbCaptain = 
	{
		szPlayerName = szPlayerName,
		szGateway = szGateway,
		szTongName = szTongName,
		nPlayerSex = nPlayerSex,
	};
	self.tbLocalGroupBuffer[nGroupIndex].tbTong = {};
	self.tbLocalGroupBuffer[nGroupIndex].tbPreTong = {};
	self.tbLocalGroupBuffer[nGroupIndex].nTongCount = 0;
	
	if nRight == 1 then
		self.tbLocalGroupBuffer[nGroupIndex].tbTong[szTongName] = szGateway;
		self.tbLocalGroupBuffer[nGroupIndex].nTongCount = self.tbLocalGroupBuffer[nGroupIndex].nTongCount + 1;
	end
	
	self.tbLocalGroupBuffer[nGroupIndex].tbAward = 
	{
		nAwardCount = 0,
		nMultiple = 0,
		nForceSend = 0,
		nExtraBox = 0,
	};
	
	-- 保存映像
	self:SaveBuffer_GC(GBLINTBUF_XKL_GROUP);
end

-- 竞拍结束后自动创建军团
function Xkland:CreateGroup_GA()
	
	-- 第一届创建6个军团
	if self:GetSession() == 1 then
		
		-- 参与竞拍的数量(最大6个)
		local nMax = ((#self.tbCompetitiveBuffer > self.MAX_GROUP) and self.MAX_GROUP) or #self.tbCompetitiveBuffer;
		if nMax < self.MIN_GROUP then
			return 0;
		end
		
		-- 至少要有2个军团
		for i = 1, nMax do
			if self.tbCompetitiveBuffer[i] then
				local szPlayerName = self.tbCompetitiveBuffer[i].szPlayerName;
				local szGateway = self.tbCompetitiveBuffer[i].szGateway;
				local szTongName = self.tbCompetitiveBuffer[i].szTongName;
				local nPlayerSex = self.tbCompetitiveBuffer[i].nPlayerSex;
				local nRight = self.tbCompetitiveBuffer[i].nRight;
				self:OnCreatGroup_GA(i, szPlayerName, szGateway, szTongName, nPlayerSex, nRight);
			end	
		end
		
	-- 以后只创建攻守军团
	else
		
		-- 没有竞标或者城主数据
		if not self.tbCompetitiveBuffer[1] or not self.tbCastleBuffer.szPlayerName then
			return 0;
		end
		
		-- 攻方只取第一名
		local szAttPlayerName = self.tbCompetitiveBuffer[1].szPlayerName;
		local szAttGateway = self.tbCompetitiveBuffer[1].szGateway;
		local szAttTongName = self.tbCompetitiveBuffer[1].szTongName;
		local nAttPlayerSex = self.tbCompetitiveBuffer[1].nPlayerSex or 0;
		local nAttRight = self.tbCompetitiveBuffer[1].nRight;
		self:OnCreatGroup_GA(self.ATTACK_GROUP_INDEX, szAttPlayerName, szAttGateway, szAttTongName, nAttPlayerSex, nAttRight);
		
		-- 守方取城主数据
		local szDefPlayerName = self.tbCastleBuffer.szPlayerName;
		local szDefGateway = self.tbCastleBuffer.szGateway;
		local szDefTongName = self.tbCastleBuffer.szTongName;
		local nDefPlayerSex = self.tbCastleBuffer.nPlayerSex or 0;
		local nDefRight = (szDefTongName ~= "无") and 1 or 0;
		self:OnCreatGroup_GA(self.CASTLE_GROUP_INDEX, szDefPlayerName, szDefGateway, szDefTongName, nDefPlayerSex, nDefRight);
	end
	
	-- 保存数据
	self:SaveBuffer_GC(GBLINTBUF_XK_GROUP);
	self:SaveBuffer_GC(GBLINTBUF_XK_WAR);
	
	return 1;
end

-- 竞拍结束
function Xkland:OnCompetitiveEnd_GA()
	
	-- global only
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	
	if self:GetPeriod() ~= self.PERIOD_COMPETITIVE then
		return 0;
	end
	
	-- 创建军团
	local nRet = self:CreateGroup_GA();
	if nRet ~= 1 then
		return 0;
	end

	-- 竞拍公告
	for nGroupIndex, tbInfo in pairs(self.tbCompetitiveBuffer) do
		if self:GetSession() == 1 then
			if nGroupIndex <= self.MAX_GROUP then
				GC_AllExcute({"Xkland:OnCompetitiveEnd_GC", tbInfo});
			end
		else
			if nGroupIndex == 1 then
				GC_AllExcute({"Xkland:OnCompetitiveEnd_GC", tbInfo});
			end
		end
	end
	
	-- 设置为下一阶段
	SetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_PERIOD, self.PERIOD_SELECT_GROUP);
end

-- 本地服竞拍结束公告
function Xkland:OnCompetitiveEnd_GC(tbInfo)
	GlobalExcute({"Xkland:OnCompetitiveEnd_GS", tbInfo});
end

-- 获取玩家竞拍排名
function Xkland:GetPlayerCompRank_GC(szPlayerName)
	GC_AllExcute({"Xkland:GetPlayerCompRank_GA", szPlayerName});
end

-- 中心服返回玩家排名
function Xkland:GetPlayerCompRank_GA(szPlayerName)
	local nSort = 0;
	for nIndex, tbInfo in pairs(self.tbCompetitiveBuffer) do
		if tbInfo.szPlayerName == szPlayerName then
			nSort = nIndex;
			break;
		end
	end
	GC_AllExcute({"Xkland:OnGetPlayerCompRank_GC", szPlayerName, nSort});
end

-- 本地服返回玩家排名
function Xkland:OnGetPlayerCompRank_GC(szPlayerName, nSort)
	GlobalExcute({"Xkland:OnGetPlayerCompRank_GS", szPlayerName, nSort});
end

-------------------------------------------------------
-- 选择阵营
-------------------------------------------------------

-- 加入战队
function Xkland:AddGroupMember_GA(szPlayerName, nGroupIndex, szGateway, nCaptain)
	
	-- 是否有战队
	if League:GetMemberLeague(self.LEAGUE_TYPE, szPlayerName) then
		return 0;
	end

	-- 战队添加成员
	local tbMember =
	{
		nCaptain = nCaptain,
		nGroupIndex = nGroupIndex,
		szPlayerName = szPlayerName,
		nGateWay = tonumber(string.sub(szGateway, 5, 8)),		
	};
	
	local szGroupName = self.tbGroupBuffer[nGroupIndex].szGroupName;
	self:AddLeagueMember(szGroupName, tbMember);

	return 1;
end

-- 帮会申请加入
function Xkland:OnSelectGroupTong_GC(szPlayerName, nGroupIndex, szGateway, szTongName)
	GC_AllExcute({"Xkland:OnSelectGroupTong_GA", szPlayerName, nGroupIndex, szGateway, szTongName});
end

-- 中心服务器处理帮会申请
function Xkland:OnSelectGroupTong_GA(szPlayerName, nGroupIndex, szGateway, szTongName)
	
	-- global only
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	
	-- 是否有军团
	if not self.tbGroupBuffer[nGroupIndex] then
		return 0;
	end
	
	-- 如果原来有帮会
	for nGroupIndex, tbInfo in pairs(self.tbGroupBuffer) do
		if tbInfo.tbPreTong[szTongName] then
			tbInfo.tbPreTong[szTongName] = nil;
		end
	end 
	
	-- 添加到新的里面
	self.tbGroupBuffer[nGroupIndex].tbPreTong[szTongName] = szGateway;
	
	-- 保存数据
	self:SaveBuffer_GC(GBLINTBUF_XK_GROUP);
	
	-- 通知大区
	local szGroupName = self.tbGroupBuffer[nGroupIndex].szGroupName;
	GC_AllExcute({"Xkland:OnSelectGroupTongEnd_GC", szPlayerName, nGroupIndex, szGateway, szTongName, szGroupName});
end

-- 帮会加入通知
function Xkland:OnSelectGroupTongEnd_GC(szPlayerName, nGroupIndex, szGateway, szTongName, szGroupName)
	
	-- 公告通知
	GlobalExcute{"Xkland:OnSelectGroupTongEnd_GS", szPlayerName, szGroupName};
	
	-- 影子操作
	for _, tbInfo in pairs(self.tbLocalGroupBuffer) do
		if tbInfo.tbPreTong[szTongName] then
			tbInfo.tbPreTong[szTongName] = nil;
		end
	end
	
	self.tbLocalGroupBuffer[nGroupIndex].tbPreTong[szTongName] = szGateway;
		
	-- 保存数据
	self:SaveBuffer_GC(GBLINTBUF_XKL_GROUP);
end

-- 帮会取消申请
function Xkland:OnCancelGroupTong_GC(szPlayerName, nGroupIndex, szGateway, szTongName)
	GC_AllExcute({"Xkland:OnCancelGroupTong_GA", szPlayerName, nGroupIndex, szGateway, szTongName});
end

-- 中心服帮会取消申请
function Xkland:OnCancelGroupTong_GA(szPlayerName, nGroupIndex, szGateway, szTongName)
	
	-- global only
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	
	-- 是否有军团
	if not self.tbGroupBuffer[nGroupIndex] then
		return 0;
	end
		
	-- 如果原来有帮会
	for nGroupIndex, tbInfo in pairs(self.tbGroupBuffer) do
		if tbInfo.tbPreTong[szTongName] then
			tbInfo.tbPreTong[szTongName] = nil;
		end
	end 
	
	-- 保存数据
	self:SaveBuffer_GC(GBLINTBUF_XK_GROUP);
	
	-- 通知大区
	local szGroupName = self.tbGroupBuffer[nGroupIndex].szGroupName;
	GC_AllExcute({"Xkland:OnCancelGroupTongEnd_GC", szPlayerName, nGroupIndex, szGateway, szTongName, szGroupName});
end

-- 帮会取消申请通知
function Xkland:OnCancelGroupTongEnd_GC(szPlayerName, nGroupIndex, szGateway, szTongName, szGroupName)
	
	-- 公告通知
	GlobalExcute{"Xkland:OnCancelGroupTongEnd_GS", szPlayerName, szGroupName};
	
	-- 影子操作
	for _, tbInfo in pairs(self.tbLocalGroupBuffer) do
		if tbInfo.tbPreTong[szTongName] then
			tbInfo.tbPreTong[szTongName] = nil;
		end
	end
		
	-- 保存数据
	self:SaveBuffer_GC(GBLINTBUF_XKL_GROUP);
end

-- 领袖同意帮会申请
function Xkland:OnPermitGroupTong_GC(szPlayerName, nGroupIndex, szTongName)
	GC_AllExcute({"Xkland:OnPermitGroupTong_GA", szPlayerName, nGroupIndex, szTongName});
end

-- 中心服领袖同意帮会申请
function Xkland:OnPermitGroupTong_GA(szPlayerName, nGroupIndex, szTongName)
		
	-- global only
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	
	-- 是否有军团
	if not self.tbGroupBuffer[nGroupIndex] then
		return 0;
	end
		
	-- 如果原来有帮会
	local szGateway = self.tbGroupBuffer[nGroupIndex].tbPreTong[szTongName];
	if not szGateway then
		return 0;
	end
	
	for nGroupIndex, tbInfo in pairs(self.tbGroupBuffer) do
		if tbInfo.tbTong[szTongName] then
			tbInfo.tbTong[szTongName] = nil;
			tbInfo.nTongCount = tbInfo.nTongCount - 1;
		end
	end 
	
	self.tbGroupBuffer[nGroupIndex].tbTong[szTongName] = szGateway;
	self.tbGroupBuffer[nGroupIndex].tbPreTong[szTongName] = nil;
	self.tbGroupBuffer[nGroupIndex].nTongCount = self.tbGroupBuffer[nGroupIndex].nTongCount + 1;
	
	-- 保存数据
	self:SaveBuffer_GC(GBLINTBUF_XK_GROUP);
	
	-- 通知大区
	local szGroupName = self.tbGroupBuffer[nGroupIndex].szGroupName;
	GC_AllExcute({"Xkland:OnPermitGroupTongEnd_GC", szPlayerName, nGroupIndex, szGateway, szTongName, szGroupName});
end

-- 帮会加入通知
function Xkland:OnPermitGroupTongEnd_GC(szPlayerName, nGroupIndex, szGateway, szTongName, szGroupName)
	
	-- 影子操作
	for _, tbInfo in pairs(self.tbLocalGroupBuffer) do
		if tbInfo.tbTong[szTongName] then
			tbInfo.tbTong[szTongName] = nil;
			tbInfo.nTongCount = tbInfo.nTongCount - 1;
		end
	end

	self.tbLocalGroupBuffer[nGroupIndex].tbPreTong[szTongName] = nil;
	self.tbLocalGroupBuffer[nGroupIndex].tbTong[szTongName] = szGateway;
	self.tbLocalGroupBuffer[nGroupIndex].nTongCount = self.tbLocalGroupBuffer[nGroupIndex].nTongCount + 1;
	
	-- 保存数据
	self:SaveBuffer_GC(GBLINTBUF_XKL_GROUP);
	
	-- 公告通知
	GlobalExcute{"Xkland:OnPermitGroupTongEnd_GS", szPlayerName, nGroupIndex, szTongName, szGroupName};
end

-- 加入帮会所在军团
function Xkland:OnPlayerJoinGroup_GA(szPlayerName, nGroupIndex, szGateway)
	
	-- global only
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	
	-- 是否有军团
	if not self.tbGroupBuffer[nGroupIndex] then
		return 0;
	end
	
	-- 加入战队
	local nRet = self:AddGroupMember_GA(szPlayerName, nGroupIndex, szGateway, 0);
	if nRet ~= 1 then
		return 0;
	end
	
	-- 之前没有战队的，或矫正战队的，在这里统一设一次真数据
	self:SetPlayerGroup_GA(szPlayerName, nGroupIndex);
end

-- 更改战队
function Xkland:OnPlayerChangeGroup_GA(szPlayerName, nOldGroupIndex, nNewGroupIndex, szGateway)
	
	-- global only
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	
	-- 离开原来的战队
	if self.tbGroupBuffer[nOldGroupIndex] then
		local szGroupName = self.tbGroupBuffer[nOldGroupIndex].szGroupName;
		self:RemoveLeagueMember(szGroupName, szPlayerName);
	end
	
	-- 加入新的战队
	self:OnPlayerJoinGroup_GA(szPlayerName, nNewGroupIndex, szGateway);
end

-- 设置玩家军团真数据
function Xkland:SetPlayerGroup_GA(szPlayerName, nGroupIndex)
	
	-- 初始化一次个人数据
	self:InitPlayer_GA(szPlayerName, nGroupIndex);
	
	-- 设置跨服变量
	local nId = KGCPlayer.GetPlayerIdByName(szPlayerName);
	if nId then
		SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_GROUP, nGroupIndex);
	end
end

-- gc领袖设置奖励
function Xkland:OnSetMemberAward_GC(szPlayerName, nGroupIndex, tbAward)
	GC_AllExcute({"Xkland:OnSetMemberAward_GA", szPlayerName, nGroupIndex, tbAward});
end

-- 中心服设置奖励
function Xkland:OnSetMemberAward_GA(szPlayerName, nGroupIndex, tbAward)

	-- global only
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	
	-- 是否有军团
	if not self.tbGroupBuffer[nGroupIndex] then
		return 0;
	end
	
	-- 领袖名字检测
	if self.tbGroupBuffer[nGroupIndex].tbCaptain.szPlayerName ~= szPlayerName then
		return 0;
	end
	
	self.tbGroupBuffer[nGroupIndex].tbAward = tbAward;	
	self:SaveBuffer_GC(GBLINTBUF_XK_GROUP);
	
	GC_AllExcute({"Xkland:OnSetMemberAwardEnd_GC", szPlayerName, nGroupIndex, tbAward});
end

-- gc同步设置奖励
function Xkland:OnSetMemberAwardEnd_GC(szPlayerName, nGroupIndex, tbAward)
	self.tbLocalGroupBuffer[nGroupIndex].tbAward = tbAward;
	self:SaveBuffer_GC(GBLINTBUF_XKL_GROUP);
end

-------------------------------------------------------
-- 城堡相关
-------------------------------------------------------

-- 增加城池金钱
function Xkland:AddCastleMoney_GA(nCastleMoney)
	self.tbCastleBuffer.nCastleMoney = (self.tbCastleBuffer.nCastleMoney or 0) + nCastleMoney;
	if self.tbCastleBuffer.nCastleMoney < 0 then
		self.tbCastleBuffer.nCastleMoney = 0;
	end
	if self.tbCastleBuffer.nCastleMoney > self.MAX_OVERFLOW then
		self.tbCastleBuffer.nCastleMoney = self.MAX_OVERFLOW;
	end
	self:SaveBuffer_GC(GBLINTBUF_XK_CASTLE);
end

-- 增加系统金钱
function Xkland:AddSystemMoney_GA(nSystemMoney)
	local nCurSystemMoney = GetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_SYSTEM_MONEY) or 0;
	local nSubMoney = nCurSystemMoney + nSystemMoney;
	if nSubMoney < 0 then
		nSubMoney = 0;
	end
	if nSubMoney > self.MAX_OVERFLOW then
		nSubMoney = self.MAX_OVERFLOW;
	end
	SetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_SYSTEM_MONEY, nSubMoney);
end

-- 增加免费复活绑银
function Xkland:AddFreeRevival_GA(nGroupIndex, nRevivalMoney)
	if self.tbWarBuffer[nGroupIndex] then
		self.tbWarBuffer[nGroupIndex].nRevivalMoney = self.tbWarBuffer[nGroupIndex].nRevivalMoney + nRevivalMoney;
		if self.tbWarBuffer[nGroupIndex].nRevivalMoney < 0 then
			self.tbWarBuffer[nGroupIndex].nRevivalMoney = 0;
		end
		if self.tbWarBuffer[nGroupIndex].nRevivalMoney > self.MAX_OVERFLOW then
			self.tbWarBuffer[nGroupIndex].nRevivalMoney = self.MAX_OVERFLOW;
		end
		self:SaveBuffer_GC(GBLINTBUF_XK_WAR);
	end
end

-- 设置各等级披风复活次数
function Xkland:SetMantleRevival_GA(nGroupIndex, nType, nCount)
	if self.tbWarBuffer[nGroupIndex] then
		if not self.tbWarBuffer[nGroupIndex].tbFreeRevival then
			self.tbWarBuffer[nGroupIndex].tbFreeRevival = {};
		end
		self.tbWarBuffer[nGroupIndex].tbFreeRevival[nType] = nCount;
		self:SaveBuffer_GC(GBLINTBUF_XK_WAR);
	end	
end

-- 分配奖励结果
function Xkland:OnDistributeResult_GA(szTongName, nCount, nType)
	
	if nType == 1 then
		
		if self.tbCastleBuffer.nCastleBox < nCount then
			return 0;
		end
		if self.tbCastleBuffer.tbTong[szTongName] then
			self.tbCastleBuffer.tbTong[szTongName].nBox = self.tbCastleBuffer.tbTong[szTongName].nBox + nCount;
			self.tbCastleBuffer.nCastleBox = self.tbCastleBuffer.nCastleBox - nCount;
			self:SaveBuffer_GC(GBLINTBUF_XK_CASTLE);
			GC_AllExcute({"Xkland:OnDistributeResult_GC", szTongName, self.tbCastleBuffer.tbTong[szTongName].nBox, self.tbCastleBuffer.nCastleBox, 1});
		end
		
	elseif nType == 2 then
		
		if self.tbCastleBuffer.nLingPai < nCount then
			return 0;
		end
		if self.tbCastleBuffer.tbTong[szTongName] then
			self.tbCastleBuffer.tbTong[szTongName].nLingPai = self.tbCastleBuffer.tbTong[szTongName].nLingPai + nCount;
			self.tbCastleBuffer.nLingPai = self.tbCastleBuffer.nLingPai - nCount;
			self:SaveBuffer_GC(GBLINTBUF_XK_CASTLE);
			GC_AllExcute({"Xkland:OnDistributeResult_GC", szTongName, self.tbCastleBuffer.tbTong[szTongName].nLingPai, self.tbCastleBuffer.nLingPai, 2});
		end
	end
end

-- 本服同步分配结果
function Xkland:OnDistributeResult_GC(szTongName, nTongBox, nCastleBox, nType)
	
	-- 采用直接设置的办法	
	if self.tbLocalCastleBuffer.tbTong[szTongName] then
		
		if nType == 1 then
			self.tbLocalCastleBuffer.tbTong[szTongName].nBox = nTongBox;
			self.tbLocalCastleBuffer.nCastleBox = nCastleBox;
			
		elseif nType == 2 then
			self.tbLocalCastleBuffer.tbTong[szTongName].nLingPai = nTongBox;
			self.tbLocalCastleBuffer.nLingPai = nCastleBox;
		else
			return 0;
		end
		
		self:SaveBuffer_GC(GBLINTBUF_XKL_CASTLE);
	end
end

-- gc申请领取城主令牌
function Xkland:GetLadderAward_GC(szPlayerName)
	GC_AllExcute({"Xkland:GetLadderAward_GA", szPlayerName});
end

-- 中心服务器处理城主令牌
function Xkland:GetLadderAward_GA(szPlayerName)
	if szPlayerName == self.tbCastleBuffer.szPlayerName and self.tbCastleBuffer.nChengZhuLingPai > 0 then
		GC_AllExcute({"Xkland:OnGetLadderAward_GC", szPlayerName, self.tbCastleBuffer.nChengZhuLingPai});
		self.tbCastleBuffer.nChengZhuLingPai = 0;		
		self:SaveBuffer_GC(GBLINTBUF_XK_CASTLE);
	else
		GC_AllExcute({"Xkland:OnGetLadderAwardFailed_GC", szPlayerName});
	end
end

-- gc城主令牌奖励回调
function Xkland:OnGetLadderAward_GC(szPlayerName, nChengZhuLingPai)
	GlobalExcute({"Xkland:OnGetLadderAward_GS", szPlayerName, nChengZhuLingPai});
end

-- gc城主令牌领取失败
function Xkland:OnGetLadderAwardFailed_GC(szPlayerName)
	GlobalExcute({"Xkland:OnGetLadderAwardFailed_GS", szPlayerName});
end

-- gc申请领取城主奖励
function Xkland:GetCastleAward_GC(szPlayerName, szTongName)
	GC_AllExcute({"Xkland:GetCastleAward_GA", szPlayerName, szTongName});
end

-- 中心服务器处理城主奖励
function Xkland:GetCastleAward_GA(szPlayerName, szTongName)
	
	-- 城主领奖
	if szPlayerName == self.tbCastleBuffer.szPlayerName then
		if self.tbCastleBuffer.nCastleBox > 0 or self.tbCastleBuffer.nLingPai > 0  then
			GC_AllExcute({"Xkland:OnGetCastleAward_GC", szPlayerName, nil, self.tbCastleBuffer.nCastleBox, self.tbCastleBuffer.nLingPai});
			self.tbCastleBuffer.nCastleBox = 0;
			self.tbCastleBuffer.nLingPai = 0;
			self:SaveBuffer_GC(GBLINTBUF_XK_CASTLE);
		else
			GC_AllExcute({"Xkland:OnGetCastleAwardFailed_GC", szPlayerName});
		end
		
	-- 其他帮会帮主
	else			
		local tbAward = self.tbCastleBuffer.tbTong[szTongName];
		if tbAward and (tbAward.nBox > 0 or tbAward.nLingPai > 0) then
			GC_AllExcute({"Xkland:OnGetCastleAward_GC", szPlayerName, szTongName, tbAward.nBox, tbAward.nLingPai});
			self.tbCastleBuffer.tbTong[szTongName].nBox = 0;
			self.tbCastleBuffer.tbTong[szTongName].nLingPai = 0;
			self:SaveBuffer_GC(GBLINTBUF_XK_CASTLE);
		else
			GC_AllExcute({"Xkland:OnGetCastleAwardFailed_GC", szPlayerName});
		end
	end
end

-- gc城主奖励回调
function Xkland:OnGetCastleAward_GC(szPlayerName, szTongName, nCastleBox, nLingPai)
	GlobalExcute({"Xkland:OnGetCastleAward_GS", szPlayerName, szTongName, nCastleBox, nLingPai});
end

-- gc城主领奖失败
function Xkland:OnGetCastleAwardFailed_GC(szPlayerName)
	GlobalExcute({"Xkland:OnGetCastleAwardFailed_GS", szPlayerName});
end

-- 领取返还的跨服绑银
function Xkland:GetBackMoney_GC(szPlayerName)
	GC_AllExcute({"Xkland:GetBackMoney_GA", szPlayerName});
end

-- 中心服领取返还绑银
function Xkland:GetBackMoney_GA(szPlayerName)
	local nMoney = 0;
	local nId = KGCPlayer.GetPlayerIdByName(szPlayerName)
	if nId then
		nMoney = GetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_BACKMONEY) or 0;
		if nMoney > 0 then
			SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_BACKMONEY, 0);
		end
	end
	GC_AllExcute({"Xkland:OnGetBackMoney_GC", szPlayerName, nMoney});
end

-- 本服领取成功
function Xkland:OnGetBackMoney_GC(szPlayerName, nMoney)
	GlobalExcute({"Xkland:OnGetBackMoney_GS", szPlayerName, nMoney});
end

-- 战后更新城主雕像
function Xkland:UpdateCastleStatue_GC(szPlayerName, nPlayerSex, nCenter)
	GlobalExcute({"Xkland:UpdateCastleStatue_GS", szPlayerName, nPlayerSex, nCenter});
end

-------------------------------------------------------
-- 系统相关
-------------------------------------------------------

-- 载入本地global buffer
function Xkland:LoadBuffer_GC(nBufferIndex)
	
	local szBuffer = self.VAILD_GBLBUFFER[nBufferIndex];
	if not szBuffer then
		return 0;
	end
	
	local tbLoadBuffer = GetGblIntBuf(nBufferIndex, 0);
	if tbLoadBuffer and type(tbLoadBuffer) == "table" then
		self[szBuffer] = tbLoadBuffer;
	end
end

-- 存储本地global buffer
function Xkland:SaveBuffer_GC(nBufferIndex)
	
	local szBuffer = self.VAILD_GBLBUFFER[nBufferIndex];
	if not szBuffer then
		return 0;
	end
	
	SetGblIntBuf(nBufferIndex, 0, 1, self[szBuffer]);
	GlobalExcute({"Xkland:LoadBuffer_GS", nBufferIndex});
end

-- 清空本地global buffer
function Xkland:ClearBuffer_GC(nBufferIndex)
	
	local szBuffer = self.VAILD_GBLBUFFER[nBufferIndex];
	if not szBuffer then
		return 0;
	end
	
	self[szBuffer] = {};
	SetGblIntBuf(nBufferIndex, 0, 1, {});
	GlobalExcute({"Xkland:ClearBuffer_GS", nBufferIndex});
end

-- 载入中心服务器buffer
function Xkland:LoadCenterBuffer_GC(nBufferIndex)

	local szBuffer = self.VAILD_CENTER_BUFFER[nBufferIndex];
	if not szBuffer then
		return 0;
	end
	
	local tbLoadBuffer = GetGlobalSportBufTask(self.GA_INTBUF_GID, nBufferIndex);
	if tbLoadBuffer then
		local tbTmp = Lib:Str2Val(tbLoadBuffer);
		if type(tbTmp) == "table" then
			self[szBuffer] = tbTmp;
		end
	end
	
	GlobalExcute({"Xkland:LoadCenterBuffer_GS", nBufferIndex});
end

-- 中心服务器call全区gc重新载入buffer
function Xkland:SaveCenterBuffer_GC(nBufferIndex)

	local szBuffer = self.VAILD_CENTER_BUFFER[nBufferIndex];
	if not szBuffer then
		return 0;
	end
	
	SetGlobalSportBufTask(self.GA_INTBUF_GID, nBufferIndex, Lib:Val2Str(self[szBuffer]));
	GlobalExcute({"Xkland:LoadCenterBuffer_GS", nBufferIndex});

	if self:CheckIsGlobal() == 1 then
		GC_AllExcute({"Xkland:LoadCenterBuffer_GC", nBufferIndex});
	end
end

-- 清空中心服务器buffer
function Xkland:ClearCenterBuffer_GC(nBufferIndex)

	local szBuffer = self.VAILD_CENTER_BUFFER[nBufferIndex];
	if not szBuffer then
		return 0;
	end
	
	self[szBuffer] = {};
	SetGlobalSportBufTask(self.GA_INTBUF_GID, nBufferIndex, Lib:Val2Str({}));	
	GlobalExcute({"Xkland:ClearCenterBuffer_GS", nBufferIndex});
	
	if self:CheckIsGlobal() == 1 then
		GC_AllExcute({"Xkland:ClearCenterBuffer_GC", nBufferIndex});
	end
end

-------------------------------------------------------
-- 启动事件
-------------------------------------------------------

-- gc启动事件
function Xkland:StartEvent_GC()
	
	if self:CheckIsGlobal() == 1 then
		for i = GBLINTBUF_XK_COMPETITIVE, GBLINTBUF_XK_CASTLE do
			self:LoadBuffer_GC(i);
		end
	else
		for i = GBLINTBUF_XKL_GROUP, GBLINTBUF_XKL_CASTLE do
			self:LoadBuffer_GC(i);
		end
	end
	
	for nBufferIndex, _ in pairs(self.VAILD_CENTER_BUFFER) do
		self:LoadCenterBuffer_GC(nBufferIndex);
	end
	
	if self:GetSession() <= 0 then
		SetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_SESSION, 1);
	end
	
	if self:GetPeriod() <= 0 then
		SetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_PERIOD, self.PERIOD_COMPETITIVE);
	end
	
--	local nTaskId = 0;
--	
--	nTaskId = KScheduleTask.AddTask("铁浮城每日事件", "Xkland", "TaskDailyEvent");
--	KScheduleTask.RegisterTimeTask(nTaskId, 0005, 1);
--	
--	nTaskId = KScheduleTask.AddTask("铁浮城公告开启", "Xkland", "TaskStartAnnounce");
--	KScheduleTask.RegisterTimeTask(nTaskId, 1900, 1);
--	
--	nTaskId = KScheduleTask.AddTask("铁浮城战争预备", "Xkland", "TaskInitGame");
--	KScheduleTask.RegisterTimeTask(nTaskId, 1930, 1);
--	
--	nTaskId = KScheduleTask.AddTask("铁浮城战争开始", "Xkland", "TaskStartGame");
--	KScheduleTask.RegisterTimeTask(nTaskId, 2000, 1);
--	
--	nTaskId = KScheduleTask.AddTask("铁浮城战争结束", "Xkland", "TaskEndGame");
--	KScheduleTask.RegisterTimeTask(nTaskId, 2130, 1);
--	
--	nTaskId = KScheduleTask.AddTask("铁浮城公告关闭", "Xkland", "TaskEndAnnounce");
--	KScheduleTask.RegisterTimeTask(nTaskId, 2200, 1);
end

-- 本服gc连接到中心gc时同步数据
function Xkland:OnConnectEvent_GA(nConnectId)
	
	local tbCastleInfo =
	{
		szPlayerName = self.tbCastleBuffer.szPlayerName,
		szGateway = self.tbCastleBuffer.szGateway,
		szTongName = self.tbCastleBuffer.szTongName,
		nPlayerSex = self.tbCastleBuffer.nPlayerSex,
		nGroupIndex = self.tbCastleBuffer.nGroupIndex,
		nCastleMoney = self.tbCastleBuffer.nCastleMoney,
		nCastleBox = self.tbCastleBuffer.nCastleBox,
		nLingPai = self.tbCastleBuffer.nLingPai,
		nChengZhuLingPai = self.tbCastleBuffer.nChengZhuLingPai,
	}
	GlobalGCExcute(nConnectId, {"Xkland:OnRecvCastleInfo", tbCastleInfo});

	for szTongName, tbTongInfo in pairs(self.tbCastleBuffer.tbTong or {}) do
		GlobalGCExcute(nConnectId, {"Xkland:OnRecvCastleTong", szTongName, tbTongInfo});
	end
	
	for nSession, tbInfo in pairs(self.tbCastleBuffer.tbHistory or {}) do
		GlobalGCExcute(nConnectId, {"Xkland:OnRecvCastleHistory", nSession, tbInfo});
	end
	
	for i, tbGroup in ipairs(self.tbGroupBuffer) do 
		local tbGroupInfo = 
		{
			szGroupName = tbGroup.szGroupName,
			nTongCount = tbGroup.nTongCount,
			tbAward = tbGroup.tbAward,
			tbCaptain = tbGroup.tbCaptain,
		};
		GlobalGCExcute(nConnectId, {"Xkland:OnRecvGroupInfo", i, tbGroupInfo});
		
		for szTongName, szGateway in pairs(tbGroup.tbTong or {}) do
			GlobalGCExcute(nConnectId, {"Xkland:OnRecvGroupTong", i, szTongName, szGateway});
		end
		
		for szTongName, szGateway in pairs(tbGroup.tbPreTong or {}) do
			GlobalGCExcute(nConnectId, {"Xkland:OnRecvGroupPreTong", i, szTongName, szGateway});
		end
	end
end

-- 同步城堡信息
function Xkland:OnRecvCastleInfo(tbInfo)
	if not self.tbLocalCastleBuffer then
		self.tbLocalCastleBuffer = {};
	end
	self.tbLocalCastleBuffer.szPlayerName = tbInfo.szPlayerName;
	self.tbLocalCastleBuffer.szGateway = tbInfo.szGateway;
	self.tbLocalCastleBuffer.szTongName = tbInfo.szTongName;
	self.tbLocalCastleBuffer.nPlayerSex = tbInfo.nPlayerSex;
	self.tbLocalCastleBuffer.nGroupIndex = tbInfo.nGroupIndex;
	self.tbLocalCastleBuffer.nCastleMoney = tbInfo.nCastleMoney;
	self.tbLocalCastleBuffer.nCastleBox = tbInfo.nCastleBox;
	self.tbLocalCastleBuffer.nLingPai = tbInfo.nLingPai;
	self.tbLocalCastleBuffer.nChengZhuLingPai = tbInfo.nChengZhuLingPai;
	self:SaveBuffer_GC(GBLINTBUF_XKL_CASTLE);
end

-- 同步城堡帮会
function Xkland:OnRecvCastleTong(szTongName, tbTongInfo)
	if not self.tbLocalCastleBuffer.tbTong then
		self.tbLocalCastleBuffer.tbTong = {};
	end
	self.tbLocalCastleBuffer.tbTong[szTongName] = tbTongInfo;
	self:SaveBuffer_GC(GBLINTBUF_XKL_CASTLE);
end

-- 同步城堡历史
function Xkland:OnRecvCastleHistory(nSession, tbInfo)
	if not self.tbLocalCastleBuffer.tbHistory then
		self.tbLocalCastleBuffer.tbHistory = {};
	end
	self.tbLocalCastleBuffer.tbHistory[nSession] = tbInfo;
	self:SaveBuffer_GC(GBLINTBUF_XKL_CASTLE);	
end

-- 同步军团信息
function Xkland:OnRecvGroupInfo(nGroupIndex, tbInfo)
	if not self.tbLocalGroupBuffer then
		self.tbLocalGroupBuffer = {};
	end
	if not self.tbLocalGroupBuffer[nGroupIndex] then
		self.tbLocalGroupBuffer[nGroupIndex] = {};
	end
	self.tbLocalGroupBuffer[nGroupIndex].szGroupName = tbInfo.szGroupName;
	self.tbLocalGroupBuffer[nGroupIndex].nTongCount = tbInfo.nTongCount;
	self.tbLocalGroupBuffer[nGroupIndex].tbAward = tbInfo.tbAward;
	self.tbLocalGroupBuffer[nGroupIndex].tbCaptain = tbInfo.tbCaptain;
	self:SaveBuffer_GC(GBLINTBUF_XKL_GROUP);
end

-- 同步军团帮会
function Xkland:OnRecvGroupTong(nGroupIndex, szTongName, szGateway)
	if not self.tbLocalGroupBuffer[nGroupIndex].tbTong then
		self.tbLocalGroupBuffer[nGroupIndex].tbTong = {};
	end
	self.tbLocalGroupBuffer[nGroupIndex].tbTong[szTongName] = szGateway;
	self:SaveBuffer_GC(GBLINTBUF_XKL_GROUP);
end

-- 同步帮会申请列表
function Xkland:OnRecvGroupPreTong(nGroupIndex, szTongName, szGateway)
	if not self.tbLocalGroupBuffer[nGroupIndex].tbPreTong then
		self.tbLocalGroupBuffer[nGroupIndex].tbPreTong = {};
	end
	self.tbLocalGroupBuffer[nGroupIndex].tbPreTong[szTongName] = szGateway;
	self:SaveBuffer_GC(GBLINTBUF_XKL_GROUP);
end

-------------------------------------------------------
-- 计划任务
-------------------------------------------------------

-- 铁浮城竞标启动
function Xkland:TaskCompetitive()
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	self:StartCompetitive_GA();
end

-- 铁浮城选择军团
function Xkland:TaskSelectGroup()
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	self:OnCompetitiveEnd_GA();
end

-- 铁浮城战争预备
function Xkland:TaskInitGame()
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	if self:CheckWarTaskOpen() ~= 1 then
		return 0;
	end
	self:InitGame_GA();
end

-- 铁浮城战争开始
function Xkland:TaskStartGame()
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	if self:CheckWarTaskOpen() ~= 1 then
		return 0;
	end
	self:StartGame_GA();
end

-- 铁浮城战争结束
function Xkland:TaskEndGame()
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	if self:CheckWarTaskOpen() ~= 1 then
		return 0;
	end
	self:EndGame_GA();
end

-- 铁浮城公告开启
function Xkland:TaskStartAnnounce()
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	self:StartAnnTimer_GA();
end

-- 铁浮城公告结束
function Xkland:TaskEndAnnounce()
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	self:CloseAnnTimer_GA();
end

-- 每日事件
function Xkland:TaskDailyEvent()
	
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	
	local nPeriod = 0;
	local nPrePeriod = self:GetPeriod();
	local nDay = tonumber(os.date("%w", GetTime()));
	
	if self:GetSession() == 1 then
		nPeriod = self.PERIOD_DAY_FIRST[nDay];
	else
		nPeriod = self.PERIOD_DAY_NORMAL[nDay];
	end
	
	if nPrePeriod == self.PERIOD_WAR_REST and nPeriod == self.PERIOD_COMPETITIVE then
		self:TaskCompetitive();
		
	elseif nPrePeriod == self.PERIOD_COMPETITIVE and nPeriod == self.PERIOD_SELECT_GROUP then
		self:TaskSelectGroup();
	end
end

-- 注册gamecenter启动事件
--GCEvent:RegisterGCServerStartFunc(Xkland.StartEvent_GC, Xkland);

-- 注册center server收到连接时事件
--GCEvent:RegisterGBGCServerRecvConnectFunc({Xkland.OnConnectEvent_GA, Xkland});

-- 测试指令
function Xkland:_ShowPlayerCenterTask(szPlayerName)
	local nId = KGCPlayer.GetPlayerIdByName(szPlayerName);
	if nId then
		print("战争个人排名："..GetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_RANK));
		print("城战个人积分："..GetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_POINT));
		print("跨服军团编号："..GetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_GROUP));
		print("积分兑换箱子："..GetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_BOX));
		print("免费复活次数："..GetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_REVIVAL));
		print("返还跨服绑银："..GetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_BACKMONEY));
		print("跨服经验奖励："..GetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_EXP));
	end
end

-- 清除所有buffer
function Xkland:_ClearAllBuffer()
	
	if self:CheckIsGlobal() == 1 then
		for i = GBLINTBUF_XK_COMPETITIVE, GBLINTBUF_XK_CASTLE do
			self:ClearBuffer_GC(i);
		end
		for nBufferIndex, _ in pairs(self.VAILD_CENTER_BUFFER) do
			self:ClearCenterBuffer_GC(nBufferIndex);
		end
		League:ClearLeague(self.LEAGUE_TYPE);
	else
		for i = GBLINTBUF_XKL_GROUP, GBLINTBUF_XKL_CASTLE do
			self:ClearBuffer_GC(i);
		end
	end
end

function Xkland:WritePlayerListLog()
	
	local nTime = GetLocalDate("%y_%m_%d");
	local strResult = "\n军团编号\t排名\t玩家名字\t积分\t网关\t军团\n";
	local szFilePath = self.LOG_PATH .. nTime .. "\\xiakedaolog_20" .. nTime .. ".txt";
	
	KFile.WriteFile(szFilePath, strResult);
	
	for nGroupIndex, tbSort in ipairs(self.tbSortPlayer) do
		for i, tbInfo in ipairs(tbSort) do
			local szLeagueName =  League:GetMemberLeague(self.LEAGUE_TYPE, tbInfo.szPlayerName) or "";
			local szGateway = "";
			if szLeagueName ~= "" then
				szGateway = League:GetMemberTask(self.LEAGUE_TYPE, szLeagueName, tbInfo.szPlayerName, self.LGMTASK_GATEWAY);
			end
			local szOut = string.format("%s\t%s\t%s\t%s\t%s\t%s\n", nGroupIndex, i, tbInfo.szPlayerName, tbInfo.nPoint, szGateway, szLeagueName);
			KFile.AppendFile(szFilePath, szOut);
		end	
	end
	
	local szChengZhuInfo = string.format("城主：%s\t网关：%s\t帮会：%s\t奖励箱子：%s\t英雄令牌：%s\t城主令牌：%s\n",
		self.tbCastleBuffer.szPlayerName,
		self.tbCastleBuffer.szGateway,
		self.tbCastleBuffer.szTongName,
		self.tbCastleBuffer.nCastleBox,
		self.tbCastleBuffer.nLingPai,
		self.tbCastleBuffer.nChengZhuLingPai
	);
	
	KFile.AppendFile(szFilePath, szChengZhuInfo);
end
