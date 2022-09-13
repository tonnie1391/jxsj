-------------------------------------------------------
-- 文件名　：newland_gc.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-09-03 15:17:57
-- 文件描述：
-------------------------------------------------------

if not MODULE_GC_SERVER then
	return 0;
end

Require("\\script\\globalserverbattle\\newland\\newland_def.lua");

-------------------------------------------------------
-- 报名相关
-------------------------------------------------------

-- 中心服启动报名
function Newland:StartSignup_GA()

	-- global only
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	
	-- 判断阶段
	if self:GetPeriod() ~= self.PERIOD_WAR_REST then
		return 0;
	end
	
	-- 清空报名数据
	self:ClearBuffer_GC(GBLINTBUF_NL_SIGNUP);
	
	-- 清空军团数据
	self:ClearBuffer_GC(GBLINTBUF_NL_GROUP);
	
	-- 换届换阶段
	SetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_PERIOD, self.PERIOD_SIGNUP);
	SetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_SESSION, self:GetSession() + 1);
	
	-- 大区公告
	self:GlobalAnnounce_GA("<color=green>[Công Thành Chiến] Giai đoạn Báo danh (0:00 thứ 5 - 19:30 thứ 7)<color><color=gold> mời thủ lĩnh Bang hội đến Tướng Viễn Chinh Thiết Phù báo danh.<color>");
	
	-- 启动计时器
	self:StartTimer(self.ANNOUNCE_TIME, self.TimerAnnounce_GA, "announce");
	
	GC_AllExcute({"Newland:StartSignup_GC"});
end

-- 本服gc启动报名
function Newland:StartSignup_GC()
	self:ClearBuffer_GC(GBLINTBUF_NL_SIGNUP);
	self:ClearBuffer_GC(GBLINTBUF_NL_GROUP);
end

-- gc收到首领报名信息
function Newland:OnCaptainSignup_GC(szCaptainName, szGateway, szTongName, nCaptainSex)
	GC_AllExcute({"Newland:OnCaptainSignup_GA", szCaptainName, szGateway, szTongName, nCaptainSex});
end

-- 中心服务器处理报名信息
function Newland:OnCaptainSignup_GA(szCaptainName, szGateway, szTongName, nCaptainSex)
	
	-- global only
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	
	-- 只能报名一次
	if self.tbSignupBuffer[szTongName] then
		return 0;
	end
	
	-- 达到帮会上限
	if self:GetSignupCount() >= self.MAX_GROUP then
		return 0;
	end
	
	-- 加入报名表
	self.tbSignupBuffer[szTongName] = {szCaptainName = szCaptainName, szGateway = szGateway, nCaptainSex = nCaptainSex, nMemberCount = 1, nSuccess = 0};
	self:SaveBuffer_GC(GBLINTBUF_NL_SIGNUP);
	
	-- 通知本服gc更新信息
	GC_AllExcute({"Newland:OnCaptainSignupEnd_GC", szCaptainName, szGateway, szTongName, nCaptainSex});
end

-- 本服gc更新报名信息
function Newland:OnCaptainSignupEnd_GC(szCaptainName, szGateway, szTongName, nCaptainSex)
	
	-- 公告通知
	GlobalExcute{"Newland:OnCaptainSignupEnd_GS", szCaptainName, szGateway, szTongName, nCaptainSex};
	
	-- 影子操作
	self.tbSignupBuffer[szTongName] = {szCaptainName = szCaptainName, szGateway = szGateway, nCaptainSex = nCaptainSex, nMemberCount = 1, nSuccess = 0};
	self:SaveBuffer_GC(GBLINTBUF_NL_SIGNUP);
end

-- gc收到成员确认信息
function Newland:OnMemberSignup_GC(szPlayerName, szGateway, szTongName)
	GC_AllExcute({"Newland:OnMemberSignup_GA", szPlayerName, szGateway, szTongName});
end

-- 中心服gc处理成员确认信息
function Newland:OnMemberSignup_GA(szPlayerName, szGateway, szTongName)
	
	-- global only
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	
	local tbSignup = self.tbSignupBuffer[szTongName];
	if not tbSignup or tbSignup.nSuccess == 1 then
		return 0;
	end
	
	-- 达到帮会上限
	if self:GetSignupCount() >= self.MAX_GROUP then
		return 0;
	end
	
	-- 人数增加
	tbSignup.nMemberCount = tbSignup.nMemberCount + 1;
	
	-- 达到人数标准后立即创建战队
	if tbSignup.nMemberCount >= self.MIN_MEMBER then
		tbSignup.nSuccess = 1;
		table.insert(self.tbGroupBuffer, {
			szCaptainName = tbSignup.szCaptainName,
			szGateway = tbSignup.szGateway,
			szTongName = szTongName,
			nCaptainSex = tbSignup.nCaptainSex
		});
		self:SaveBuffer_GC(GBLINTBUF_NL_GROUP);
		GC_AllExcute({"Newland:OnTongSignupSuccess_GC", szPlayerName, szGateway, szTongName});
	end
	
	-- 保存数据
	self:SaveBuffer_GC(GBLINTBUF_NL_SIGNUP);
	
	-- 通知本服gc更新信息
	GC_AllExcute({"Newland:OnMemberSignupEnd_GC", szPlayerName, szGateway, szTongName});
end

-- 本服gc更新成员确认信息
function Newland:OnMemberSignupEnd_GC(szPlayerName, szGateway, szTongName)
	self.tbSignupBuffer[szTongName].nMemberCount = self.tbSignupBuffer[szTongName].nMemberCount + 1;
	if self.tbSignupBuffer[szTongName].nMemberCount >= self.MIN_MEMBER then
		self.tbSignupBuffer[szTongName].nSuccess = 1;
	end
	self:SaveBuffer_GC(GBLINTBUF_NL_SIGNUP);
end

-- 帮会报名成功
function Newland:OnTongSignupSuccess_GC(szPlayerName, szGateway, szTongName)
	GlobalExcute{"Newland:OnTongSignupSuccess_GS", szPlayerName, szGateway, szTongName};
end

-------------------------------------------------------
-- 战争相关
-------------------------------------------------------

-- 战争初始化
function Newland:InitGame_GA()
	
	-- global only
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	
	-- 判断阶段
	if self:GetPeriod() ~= self.PERIOD_SIGNUP then
		return 0;
	end
	
	-- 判断战场状态
	if self:GetWarState() ~= self.WAR_END then
		return 0;
	end
	
	-- 帮会数量限制
	if #self.tbGroupBuffer < self.MIN_GROUP or #self.tbGroupBuffer > self.MAX_GROUP then
		self:GlobalAnnounce_GA("<color=green>[Công Thành Chiến] Không đủ lực lượng tham gia. Trận đấu không thể diễn ra.<color>");
		return 0;
	end

	-- 清空地图人数
	self:ClearMapPlayerCount_GA()
	
	-- 清空玩家数据
	self:ClearBuffer_GC(GBLINTBUF_NL_PLAYER);
	
	-- 清空战争数据
	self:ClearBuffer_GC(GBLINTBUF_NL_WAR);
	
	-- 设置战场状态
	self.nWarState = self.WAR_INIT;
	SetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_PERIOD, self.PERIOD_WAR_OPEN);
	
	-- 军团分组
	Lib:SmashTable(self.tbGroupBuffer);
	self:SaveBuffer_GC(GBLINTBUF_NL_GROUP);
	
	-- 生成三层分组树
	self.tbGroupTree = self:BuildTree(#self.tbGroupBuffer);

	-- 战争数据
	for nGroupIndex, tbInfo in pairs(self.tbGroupBuffer) do
		self.tbWarBuffer[nGroupIndex] = {szTongName = tbInfo.szTongName, nPoint = 0, tbPole = {}};
	end
	self:SaveBuffer_GC(GBLINTBUF_NL_WAR);
	
	-- 召唤gs启动
	GlobalExcute({"Newland:InitGame_GS"});
	
	-- 大区公告
	self:GlobalAnnounce_GA(string.format("<color=green>[Công Thành Chiến] Hoàn tất đăng ký! <color=gold>Có tổng số %s Bang hội tham gia!<color>", #self.tbGroupBuffer));
end

-- 开始游戏
function Newland:StartGame_GA()
	
	-- global only
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	
	-- 判断阶段
	if self:GetPeriod() ~= self.PERIOD_WAR_OPEN then
		return 0;
	end
	
	-- 判断战场状态
	if self:GetWarState() ~= self.WAR_INIT then
		return 0;
	end
	
	-- 设置战场状态
	self.nWarState = self.WAR_START;
	
	-- 启动计时器
	self:StartTimer(self.SYNC_DATE_TIME, self.TimerSyncDate_GA, "syncdata");
	
	-- 召唤gs开战
	GlobalExcute({"Newland:StartGame_GS"});	
end

-- 结束游戏
function Newland:EndGame_GA()
	
	-- global only
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	
	-- 判断阶段
	if self:GetPeriod() ~= self.PERIOD_WAR_OPEN then
		return 0;
	end
	
	-- 判断战场状态
	if self:GetWarState() ~= self.WAR_START then
		return 0;
	end
	
	-- 到时间后排序
	self.tbSortGroup = {};
	self.tbSortPlayer = {};
	
	for nGroupIndex, tbInfo in pairs(self.tbWarBuffer) do	
		table.insert(self.tbSortGroup, {nGroupIndex = nGroupIndex, nPoint = tbInfo.nPoint});
		if not self.tbSortPlayer[nGroupIndex] then
			self.tbSortPlayer[nGroupIndex] = {};
		end
		for szPlayerName, tbInfo in pairs(self.tbPlayerBuffer) do
			if nGroupIndex == tbInfo[1] then
				table.insert(self.tbSortPlayer[nGroupIndex], {szPlayerName = szPlayerName, nPoint = tbInfo[2]});
			end
		end
		table.sort(self.tbSortPlayer[nGroupIndex], function(a, b) return a.nPoint > b.nPoint end);
	end
	table.sort(self.tbSortGroup, function(a, b) return a.nPoint > b.nPoint end);
	
	-- 胜利方
	local nWinGroup = self.tbSortGroup[1].nGroupIndex;
	local tbWinGroup = self.tbGroupBuffer[nWinGroup];
	
	-- 设置状态
	self.nWarState = self.WAR_END;
	SetGlobalSportTask(self.GA_DBTASK_GID, self.GA_DBTASK_PERIOD, self.PERIOD_WAR_REST);
	
	-- 清除所有计时器
	for szType, _ in pairs(self.tbTimerId) do
		self:ClearTimer(szType);
	end
	
	-- 召唤gs结束
	GlobalExcute({"Newland:EndGame_GS", nWinGroup});
	local szCaptainNameInfo = string.format("[%s] %s",ServerEvent:GetServerNameByGateway(tbWinGroup.szGateway), tbWinGroup.szCaptainName)
	-- 大区公告
	local szMsg = string.format("<color=green>[Công Thành Chiến] Kết thúc!<color> <color=gold>%s <color=green>[%s]<color> chiến thắng áp đảo, thủ lĩnh <color=green>[%s]<color> trở thành Thành chủ mới!", ServerEvent:GetServerNameByGateway(tbWinGroup.szGateway), tbWinGroup.szTongName, tbWinGroup.szCaptainName);
	self:GlobalAnnounce_GA(szMsg);
	
	-- 设置城主数据
	self.tbCastleBuffer.szCaptainName = tbWinGroup.szCaptainName;
	self.tbCastleBuffer.szGateway = tbWinGroup.szGateway;
	self.tbCastleBuffer.szTongName = tbWinGroup.szTongName;
	self.tbCastleBuffer.nCaptainSex = tbWinGroup.nCaptainSex;
	self.tbCastleBuffer.nGroupIndex = tbWinGroup.nGroupIndex;
	self.tbCastleBuffer.nAward = 1;
	self.tbCastleBuffer.nSellBox = self.CASTLE_SELL_BOX;
	
	-- 城主历史数据
	if not self.tbCastleBuffer.tbHistory then
		self.tbCastleBuffer.tbHistory = {};
	end
	local nSession = self:GetSession();
	self.tbCastleBuffer.tbHistory[nSession] = 
	{
		szCaptainName = tbWinGroup.szCaptainName,
		szGateway = tbWinGroup.szGateway,
	};
	
	-- 保存数据
	self:SaveBuffer_GC(GBLINTBUF_NL_CASTLE);
	
	-- 通知全区gc
	GC_AllExcute({"Newland:EndGame_GC", tbWinGroup});
	
	-- 更新雕像
	self:UpdateCastleStatue_GC(tbWinGroup.szCaptainName, tbWinGroup.nCaptainSex, 1);
	
	-- log
	self:WritePlayerListLog();
	self:CreateCityCaptainFile(szCaptainNameInfo)
	
	-- 设置数据
	Timer:Register(1, self.SetFinalPlayerData, self, nWinGroup);
end

--生成城主数据写入文件，KE获取同步给各服务器
function Newland:CreateCityCaptainFile(szCaptainNameInfo)
	local nAreaId 		= KGblTask.SCGetDbTaskInt(DBTASK_GLOBAL_AREA_NAME);
	local szAreaName 	= KGblTask.SCGetDbTaskStr(DBTASK_GLOBAL_AREA_NAME);
	local tbArea = ServerEvent.tbDefGlobalAreaName[nAreaId]
	if tbArea then
		local szOutFile = "\\kingeyes\\" .. (tbArea[3] or "") .. "_newlandcaptain.txt";
		local szContext = "AreaId\tAreaName\tCaptainNameInfo\n";
		KFile.WriteFile(szOutFile, szContext);
		local szOut = string.format("%s\t%s\t%s\n", nAreaId, szAreaName, szCaptainNameInfo);
		KFile.AppendFile(szOutFile, szOut);
	end
end

function Newland:LoadCityCaptainFile(szPath)
	if self:CheckIsGlobal() == 1 then
		--全局服不加载
		return 0;
	end
	local tbFile = Lib:LoadTabFile(szPath);
	if not tbFile then
		return 0;
	end
	
	for _, tbInfo in ipairs(tbFile) do
		local nAreaId = tonumber(tbInfo.AreaId) or 0;
		local szCaptainNameInfo = tbInfo.CaptainNameInfo or "";
		local nGbTask = ServerEvent:GetGlobalAreaGbTaskById(nAreaId);
		if nGbTask > 0 then
			KGblTask.SCSetDbTaskStr(nGbTask, szCaptainNameInfo);
		end
	end
	
	return 0;
end


-- 本服gc收到战争结束
function Newland:EndGame_GC(tbWinGroup)
	
	-- 影子操作
	self.tbCastleBuffer.szCaptainName = tbWinGroup.szCaptainName;
	self.tbCastleBuffer.szGateway = tbWinGroup.szGateway;
	self.tbCastleBuffer.szTongName = tbWinGroup.szTongName;
	self.tbCastleBuffer.nCaptainSex = tbWinGroup.nCaptainSex;
	self.tbCastleBuffer.nGroupIndex = tbWinGroup.nGroupIndex;
	self.tbCastleBuffer.nAward = 1;
	self.tbCastleBuffer.nSellBox = self.CASTLE_SELL_BOX;
	
	-- 城主历史数据
	if not self.tbCastleBuffer.tbHistory then
		self.tbCastleBuffer.tbHistory = {};
	end
	
	local nSession = self:GetSession();
	self.tbCastleBuffer.tbHistory[nSession] = 
	{
		szCaptainName = tbWinGroup.szCaptainName,
		szGateway = tbWinGroup.szGateway,
	};

	-- 保存映像
	self:SaveBuffer_GC(GBLINTBUF_NL_CASTLE);
	
	-- 帮助锦囊
	self:UpdateHelpTable(tbWinGroup.szTongName, tbWinGroup.szCaptainName, tbWinGroup.szGateway);
	
	-- 更新雕像
	self:UpdateCastleStatue_GC(tbWinGroup.szCaptainName, tbWinGroup.nCaptainSex, 0);
end

-- 玩家设置数据(积分、排名、箱子)
function Newland:SetFinalPlayerData(nWinGroup)
	for nGroupIndex, tbSort in ipairs(self.tbSortPlayer) do
		local nGroupSort = self:GetFinalGroupSort(nGroupIndex);
		local nGroupPoint = self.tbSortGroup[nGroupSort].nPoint;
		local szGroupName = self:GetGroupNameByIndex(nGroupIndex);
		for nSort, tbInfo in ipairs(tbSort) do
			local nId = KGCPlayer.GetPlayerIdByName(tbInfo.szPlayerName);
			if nId then
				-- 积分
				SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_POINT, tbInfo.nPoint);
				-- 排名
				SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_RANK, nSort);
				-- 个人箱子
				local nBoxCount = self:CalcPlayerBoxCount(nSort, #tbSort, nGroupSort, #self.tbSortGroup);
				-- 经验威望
				local nExpTimes = self:CalcPlayerExp(tbInfo.nPoint);
				if nExpTimes > 0 then
					local nOwnExp = GetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_EXP) or 0;
					SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_EXP, nOwnExp + nExpTimes);
				end
				-- 达到500分
				if tbInfo.nPoint >= self.PLAYER_POINT_LIMIT then	
					local nOwnCount = GetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_BOX) or 0;
					SetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_BOX, nOwnCount + nBoxCount);
					GlobalExcute({"Newland:ShowPlayerResult", tbInfo.szPlayerName, tbInfo.nPoint, nSort, nBoxCount});
				else
					nBoxCount = 0;
					GlobalExcute({"Newland:ShowPlayerResult", tbInfo.szPlayerName, tbInfo.nPoint, nSort, nBoxCount});
				end
				StatLog:WriteStatLog("stat_info", "newland", "finish", nId, tbInfo.nPoint, nSort, nGroupPoint, nGroupSort, szGroupName, nBoxCount);
			end
		end
	end
	return 0;
end

-- 获取帮会最终排名
function Newland:GetFinalGroupSort(nGroupIndex)
	for nSort, tbInfo in pairs(self.tbSortGroup) do
		if nGroupIndex == tbInfo.nGroupIndex then
			return nSort;
		end
	end
	return 0;
end

-------------------------------------------------------
-- 战场数据
-------------------------------------------------------

-- 间隔同步数据
function Newland:TimerSyncDate_GA()

	-- global only
	if self:CheckIsOpen() ~= 1 or self:CheckIsGlobal() ~= 1 then
		return 0;
	end
	
	-- 判断战场状态
	if self:GetWarState() ~= self.WAR_START then
		return 0;
	end
	
	self:SaveBuffer_GC(GBLINTBUF_NL_WAR);
	self:SaveBuffer_GC(GBLINTBUF_NL_PLAYER);
	
	GlobalExcute({"Newland:TimerSyncDate_GS"});
end

-- gc初始化角色数据
function Newland:InitPlayer_GA(szPlayerName, nGroupIndex)
	if not self.tbPlayerBuffer[szPlayerName] then
		self.tbPlayerBuffer[szPlayerName] = {nGroupIndex, 0, 0, 0, 0, 0, 0, 0, 0};
	end
end

-- gc增加军团积分
function Newland:AddGroupPoint_GA(nGroupIndex, nPoint)
	if self.tbWarBuffer[nGroupIndex] then
		self.tbWarBuffer[nGroupIndex].nPoint = self.tbWarBuffer[nGroupIndex].nPoint + nPoint;
	end
end

-- gc增加玩家积分
function Newland:AddPlayerPoint_GA(szPlayerName, nPoint)
	local tbPlayer = self.tbPlayerBuffer[szPlayerName];
	if tbPlayer then
		tbPlayer[2] = tbPlayer[2] + nPoint;
		for i = 1, #self.RANK_POINT do
			if tbPlayer[2] < self.RANK_POINT[i][1] then
				tbPlayer[6] = i - 1;
				break;
			end
		end
		if tbPlayer[2] >= self.RANK_POINT[#self.RANK_POINT][1] then
			tbPlayer[6] = #self.RANK_POINT;
		end
	end
end

-- gc占领龙柱
function Newland:OnOccupyPole_GA(szPlayerName, nNewGroup, nOldGroup, nMapId)
	
	local tbPlayer = self.tbPlayerBuffer[szPlayerName];
	if tbPlayer then
		tbPlayer[8] = tbPlayer[8] + 1;
	end
	
	if self.tbWarBuffer[nOldGroup] then
		local tbOldWarPole = self.tbWarBuffer[nOldGroup].tbPole;
		if tbOldWarPole then
			tbOldWarPole[nMapId] = tbOldWarPole[nMapId] - 1;
			if tbOldWarPole[nMapId] < 0 then
				tbOldWarPole[nMapId] = 0;
			end
		end
	end
	
	if self.tbWarBuffer[nNewGroup] then
		local tbNewWarPole = self.tbWarBuffer[nNewGroup].tbPole;
		if tbNewWarPole then
			if not tbNewWarPole[nMapId] then
				tbNewWarPole[nMapId] = 0;
			end
			tbNewWarPole[nMapId] = tbNewWarPole[nMapId] + 1;
		end
	end
end

-- gc护卫龙柱
function Newland:OnProtectPole_GA(szPlayerName)
	local tbPlayer = self.tbPlayerBuffer[szPlayerName];
	if tbPlayer then
		tbPlayer[7] = tbPlayer[7] + 1;
	end
end

-- gc占领王座
function Newland:OnOccupyThrone_GA(szPlayerName)
	local tbPlayer = self.tbPlayerBuffer[szPlayerName];
	if tbPlayer then
		tbPlayer[9] = tbPlayer[9] + 1;
	end
end

-- 杀人处理
function Newland:AddPlayerKill_GA(szPlayerName, nSeriesKill)
	local tbPlayer = self.tbPlayerBuffer[szPlayerName];
	if tbPlayer then
		tbPlayer[3] = tbPlayer[3] + 1;
		if nSeriesKill == 1 then
			tbPlayer[4] = tbPlayer[4] + 1;
			if tbPlayer[4] > tbPlayer[5] then
				tbPlayer[5] = tbPlayer[4];
			end
		else
			tbPlayer[4] = 1;
		end
	end
end

-------------------------------------------------------
-- 奖励相关
-------------------------------------------------------

-- gc申请领取城主奖励
function Newland:GetCastleAward_GC(szPlayerName)
	GC_AllExcute({"Newland:GetCastleAward_GA", szPlayerName});
end

-- 中心服务器处理城主领奖
function Newland:GetCastleAward_GA(szPlayerName)
	if szPlayerName == self.tbCastleBuffer.szCaptainName and self.tbCastleBuffer.nAward == 1 then
		GC_AllExcute({"Newland:GetCastleAwardSuccess_GC", szPlayerName});
		self.tbCastleBuffer.nAward = 0;
		self:SaveBuffer_GC(GBLINTBUF_NL_CASTLE);
		self:GlobalAnnounce_GA(string.format("<color=gold>Thành chủ<color=green> [%s] <color>nhận thưởng, Rương chiến công: <color=green>%s<color>, Thành chủ lệnh: <color=green>%s<color>, Dũng sĩ lệnh: <color=green>%s<color>", szPlayerName, self.CASTLE_BOX, self.CASTLE_PAD, self.NORMAL_PAD));
	else
		GC_AllExcute({"Newland:GetCastleAwardFailed_GC", szPlayerName});
	end
end

-- gc收到城主领奖成功
function Newland:GetCastleAwardSuccess_GC(szPlayerName)
	self.tbCastleBuffer.nAward = 0;
	self:SaveBuffer_GC(GBLINTBUF_NL_CASTLE);
	GlobalExcute({"Newland:GetCastleAwardSuccess_GS", szPlayerName});
end

-- gc收到城主领奖失败
function Newland:GetCastleAwardFailed_GC(szPlayerName)
	GlobalExcute({"Newland:GetCastleAwardFailed_GS", szPlayerName});
end

-- gc申请购买城主箱子
function Newland:BuyCastleBox_GC(szPlayerName, nCount)
	GC_AllExcute({"Newland:BuyCastleBox_GA", szPlayerName, nCount});
end

-- 中心服务器处理购买箱子
function Newland:BuyCastleBox_GA(szPlayerName, nCount)
	if szPlayerName == self.tbCastleBuffer.szCaptainName and nCount > 0 and self.tbCastleBuffer.nSellBox >= nCount then
		GC_AllExcute({"Newland:BuyCastleBoxSuccess_GC", szPlayerName, nCount});
		self.tbCastleBuffer.nSellBox = self.tbCastleBuffer.nSellBox - nCount;	
		self:SaveBuffer_GC(GBLINTBUF_NL_CASTLE);
	else
		GC_AllExcute({"Newland:BuyCastleBoxFailed_GC", szPlayerName, nCount});
	end
end

-- gc收到购买成功
function Newland:BuyCastleBoxSuccess_GC(szPlayerName, nCount)
	self.tbCastleBuffer.nSellBox = self.tbCastleBuffer.nSellBox - nCount;	
	self:SaveBuffer_GC(GBLINTBUF_NL_CASTLE);
	GlobalExcute({"Newland:BuyCastleBoxSuccess_GS", szPlayerName, nCount});
end

-- gc收到购买失败
function Newland:BuyCastleBoxFailed_GC(szPlayerName, nCount)
	GlobalExcute({"Newland:BuyCastleBoxFailed_GS", szPlayerName, nCount});
end

-------------------------------------------------------
-- 系统相关
-------------------------------------------------------

-- gc增加地图人数
function Newland:AddMapPlayerCount_GA(nMapId, nCount)
	if self.tbMapPlayerCount[nMapId] then
		self.tbMapPlayerCount[nMapId] = self.tbMapPlayerCount[nMapId] + nCount;
		if self.tbMapPlayerCount[nMapId] < 0 then
			self.tbMapPlayerCount[nMapId] = 0;
		end
	end
	GlobalExcute({"Newland:SyncMapPlayerCount_GS", self.tbMapPlayerCount});
end

-- gc 清除地图人数
function Newland:ClearMapPlayerCount_GA()
	for nLevel, tbMapId in pairs(self.MAP_LIST) do
		for _, nMapId in pairs(tbMapId) do
			self.tbMapPlayerCount[nMapId] = 0;
		end
	end
	GlobalExcute({"Newland:SyncMapPlayerCount_GS", self.tbMapPlayerCount});	
end

-- 全服广播系统
function Newland:BroadCast_GA(szMsg, nType)
	GlobalExcute({"Newland:OnBroadCast_GS", szMsg, nType});
end

-- 全大区广播
function Newland:GlobalAnnounce_GA(szMsg)
	Dialog:GlobalNewsMsg_Center(szMsg);
	Dialog:GlobalMsg2SubWorld_Center(szMsg);
end

-- 战后更新城主雕像
function Newland:UpdateCastleStatue_GC(szPlayerName, nPlayerSex, nCenter)
	GlobalExcute({"Newland:UpdateCastleStatue_GS", szPlayerName, nPlayerSex, nCenter});
end

-- 启动计时器
function Newland:StartTimer(nTime, fnTimer, szType)
	self:ClearTimer(szType);
	self.tbTimerId[szType] = Timer:Register(nTime, fnTimer, self);
end

-- 关闭计时器
function Newland:ClearTimer(szType)
	local nTimerId = self.tbTimerId[szType];
	if nTimerId and nTimerId > 0 then
		Timer:Close(nTimerId);
		self.tbTimerId[szType] = nil;
	end
end

-- 公告处理
function Newland:TimerAnnounce_GA()
	local nDay = tonumber(os.date("%w", GetTime()));
	local nTime = tonumber(GetLocalDate("%H%M"));
	if nDay == 4 or nDay == 5 then
		if nTime > 2000 and nTime < 2400 then 
			local szMsg = "<color=green>[Công Thành Chiến] Bắt đầu đăng ký (Thứ 5 0:00-Thứ 7 19:30)<color> <color=gold>Mời thủ lĩnh đến Tướng Viễn Chinh Thiết Phù đăng ký tham chiến!<color>";
			self:GlobalAnnounce_GA(szMsg);
		end
	elseif nDay == 6 then
		if nTime > 1500 and nTime < 1930 then
			local szMsg = "<color=green>[Công Thành Chiến] Kết thúc đăng ký vào 19:30!<color> <color=gold>Mời thủ lĩnh đến Tướng Viễn Chinh Thiết Phù đăng ký tham chiến!<color>";
			self:GlobalAnnounce_GA(szMsg);
		elseif nTime > 1930 and nTime < 2000 then
			local szMsg = "<color=green>[Công Thành Chiến] Giai đoạn chuẩn bị (19:30~19:59)<color> <color=gold>Đến Đảo Anh Hùng tìm Truyền Tống Thiết Phù để vào Thiết Phù Thành.<color>";
			self:GlobalAnnounce_GA(szMsg);
		elseif nTime > 2000 and nTime < 2130 then
			local szMsg = "<color=green>[Công Thành Chiến] Khai chiến (20:00~21:30)<color> <color=gold>Các Bang hội đang tranh đoạt Ngai vàng!<color>";
			self:GlobalAnnounce_GA(szMsg);
		end
	end
end

-------------------------------------------------------
-- buffer相关
-------------------------------------------------------
-- 载入本地global buffer
function Newland:LoadBuffer_GC(nBufferIndex)
	
	local szBuffer = self.GBLBUFFER_LIST[nBufferIndex];
	if not szBuffer then
		return 0;
	end
	
	local tbLoadBuffer = GetGblIntBuf(nBufferIndex, 0);
	if tbLoadBuffer and type(tbLoadBuffer) == "table" then
		self[szBuffer] = tbLoadBuffer;
	end
end

-- 存储本地global buffer
function Newland:SaveBuffer_GC(nBufferIndex)
	
	local szBuffer = self.GBLBUFFER_LIST[nBufferIndex];
	if not szBuffer then
		return 0;
	end
	
	SetGblIntBuf(nBufferIndex, 0, 1, self[szBuffer]);
	GlobalExcute({"Newland:LoadBuffer_GS", nBufferIndex});
end

-- 清空本地global buffer
function Newland:ClearBuffer_GC(nBufferIndex)
	
	local szBuffer = self.GBLBUFFER_LIST[nBufferIndex];
	if not szBuffer then
		return 0;
	end
	
	self[szBuffer] = {};
	SetGblIntBuf(nBufferIndex, 0, 1, {});
	GlobalExcute({"Newland:ClearBuffer_GS", nBufferIndex});
end

-------------------------------------------------------
-- 计划任务
-------------------------------------------------------

-- 铁浮城战争预备
function Newland:TaskInitGame()	
	if self:CheckIsOpen() ~= 1 or self:CheckWarTaskOpen() ~= 1 then
		return 0;
	end
	self:InitGame_GA();
end

-- 铁浮城战争开始
function Newland:TaskStartGame()
	if self:CheckIsOpen() ~= 1 or self:CheckWarTaskOpen() ~= 1 then
		return 0;
	end
	self:StartGame_GA();
end

-- 铁浮城战争结束
function Newland:TaskEndGame()
	if self:CheckIsOpen() ~= 1 or self:CheckWarTaskOpen() ~= 1 then
		return 0;
	end
	self:EndGame_GA();
end

-- 铁浮城每日事件
function Newland:TaskDailyEvent()
	if self:CheckIsOpen() ~= 1 then
		return 0;
	end
	if self:GetPeriod() == self.PERIOD_WAR_REST and self:GetDailyPeriod() == self.PERIOD_SIGNUP then
		self:StartSignup_GA();
	end
end

-------------------------------------------------------
-- 启动相关
-------------------------------------------------------

-- gc启动事件
function Newland:StartEvent_GC()
	
	-- 载入buffer
	for nBufferIndex, _ in pairs(self.GBLBUFFER_LIST) do
		self:LoadBuffer_GC(nBufferIndex);
	end
	
	-- global only
	if self:CheckIsGlobal() ~= 1 then
		return 0;
	end

	-- 计划任务
	local nTaskId = 0;
	
	nTaskId = KScheduleTask.AddTask("新铁浮城每日事件", "Newland", "TaskDailyEvent");
	KScheduleTask.RegisterTimeTask(nTaskId, 0005, 1);
	
	nTaskId = KScheduleTask.AddTask("新铁浮城战争预备", "Newland", "TaskInitGame");
	KScheduleTask.RegisterTimeTask(nTaskId, 1730, 1); --1730
	
	nTaskId = KScheduleTask.AddTask("新铁浮城战争开始", "Newland", "TaskStartGame");
	KScheduleTask.RegisterTimeTask(nTaskId, 2000, 1); --2000
	
	nTaskId = KScheduleTask.AddTask("新铁浮城战争结束", "Newland", "TaskEndGame");
	KScheduleTask.RegisterTimeTask(nTaskId, 2100, 1); --2100
end

-- 本服gc连接到中心gc时同步数据
function Newland:OnConnectEvent_GA(nConnectId)
	
	-- 同步城主数据
	local tbCastleInfo =
	{
		szCaptainName = self.tbCastleBuffer.szCaptainName,
		szGateway = self.tbCastleBuffer.szGateway,
		szTongName = self.tbCastleBuffer.szTongName,
		nCaptainSex = self.tbCastleBuffer.nCaptainSex,
		nGroupIndex = self.tbCastleBuffer.nGroupIndex,
		nAward = self.tbCastleBuffer.nAward,
		nSellBox = self.tbCastleBuffer.nSellBox,
	}
	GlobalGCExcute(nConnectId, {"Newland:OnRecvCastleInfo", tbCastleInfo});

	-- 同步历史数据
	for nSession, tbInfo in pairs(self.tbCastleBuffer.tbHistory or {}) do
		GlobalGCExcute(nConnectId, {"Newland:OnRecvCastleHistory", nSession, tbInfo});
	end
	
	-- 同步合服后历史数据
	for szZone, tbHistory in pairs(self.tbCastleHistoryBuffer or {}) do
		for nSession, tbInfo in pairs(tbHistory or {}) do
			GlobalGCExcute(nConnectId, {"Newland:OnRecvCastleOldHistory", szZone, nSession, tbInfo});
		end
	end
	
	-- 同步报名数据
	for szTongName, tbInfo in pairs(self.tbSignupBuffer) do
		GlobalGCExcute(nConnectId, {"Newland:OnRecvSignupInfo", szTongName, tbInfo});
	end
end

-- 同步城堡信息
function Newland:OnRecvCastleInfo(tbInfo)
	self.tbCastleBuffer.szCaptainName = tbInfo.szCaptainName;
	self.tbCastleBuffer.szGateway = tbInfo.szGateway;
	self.tbCastleBuffer.szTongName = tbInfo.szTongName;
	self.tbCastleBuffer.nCaptainSex = tbInfo.nCaptainSex;
	self.tbCastleBuffer.nGroupIndex = tbInfo.nGroupIndex;
	self.tbCastleBuffer.nAward = tbInfo.nAward;
	self.tbCastleBuffer.nSellBox = tbInfo.nSellBox;
	self:SaveBuffer_GC(GBLINTBUF_NL_CASTLE);
end

-- 同步城堡历史
function Newland:OnRecvCastleHistory(nSession, tbInfo)
	if not self.tbCastleBuffer.tbHistory then
		self.tbCastleBuffer.tbHistory = {};
	end
	self.tbCastleBuffer.tbHistory[nSession] = tbInfo;
	self:SaveBuffer_GC(GBLINTBUF_NL_CASTLE);	
end

-- 同步合服过往历史
function Newland:OnRecvCastleOldHistory(szZone, nSession, tbInfo)
	if not self.tbCastleHistoryBuffer then
		self.tbCastleHistoryBuffer = {};
	end
	
	if (not self.tbCastleHistoryBuffer[szZone]) then
		self.tbCastleHistoryBuffer[szZone] = {};
	end
	self.tbCastleHistoryBuffer[szZone][nSession] = tbInfo;
	self:SaveBuffer_GC(GBLINTBUF_NL_HISTORY_EX);	
end

-- 同步报名数据
function Newland:OnRecvSignupInfo(szTongName, tbInfo)
	self.tbSignupBuffer[szTongName] = tbInfo;
	self:SaveBuffer_GC(GBLINTBUF_NL_SIGNUP);
end

-- 注册gamecenter启动事件
GCEvent:RegisterGCServerStartFunc(Newland.StartEvent_GC, Newland);

-- 注册center server收到连接时事件
GCEvent:RegisterGBGCServerRecvConnectFunc({Newland.OnConnectEvent_GA, Newland});

-------------------------------------------------------
-- 测试指令
-------------------------------------------------------

-- 输出跨服任务变量
function Newland:_ShowPlayerCenterTask(szPlayerName)
	local nId = KGCPlayer.GetPlayerIdByName(szPlayerName);
	if nId then
		print("战争个人排名：" .. GetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_RANK));
		print("城战个人积分：" .. GetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_POINT));
		print("积分兑换箱子：" .. GetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_BOX));
		print("经验威望奖励：" .. GetPlayerSportTask(nId, self.GA_TASK_GID, self.GA_TASK_WAR_EXP));
	end
end

-- 清除所有buffer
function Newland:_ClearAllBuffer()
	for nBufferIndex, _ in pairs(self.GBLBUFFER_LIST) do
		self:ClearBuffer_GC(nBufferIndex);
	end
end

-- 玩家列表log
function Newland:WritePlayerListLog()
	
	local nTime = GetLocalDate("%y_%m_%d");
	local strResult = "\n军团编号\t排名\t玩家名字\t积分\t网关\t军团\n";
	local szFilePath = "\\log\\gamecenter\\20" .. nTime .. "\\newland_log_20" .. nTime .. ".txt";
	
	KFile.WriteFile(szFilePath, strResult);
	
	for nGroupIndex, tbSort in ipairs(self.tbSortPlayer) do
		local szGroupName = self:GetGroupNameByIndex(nGroupIndex);
		local szGateway = self:GetGatewayByIndex(nGroupIndex);
		for i, tbInfo in ipairs(tbSort) do
			local szOut = string.format("%s\t%s\t%s\t%s\t%s\t%s\n", nGroupIndex, i, tbInfo.szPlayerName, tbInfo.nPoint, szGateway, szGroupName);
			KFile.AppendFile(szFilePath, szOut);
		end	
	end
	
	local szChengZhuInfo = string.format("城主：%s\t网关：%s\t帮会：%s\t城主箱子：%s\t城主令牌：%s\t侍卫令牌：%s\n",
		self.tbCastleBuffer.szCaptainName,
		self.tbCastleBuffer.szGateway,
		self.tbCastleBuffer.szTongName,
		self.CASTLE_BOX,
		self.CASTLE_PAD,
		self.NORMAL_PAD
	);
	
	KFile.AppendFile(szFilePath, szChengZhuInfo);
end