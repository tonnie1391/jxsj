Require("\\script\\task\\armycamp\\define.lua")

-- 军营FB管理器
local tbManager = Task.tbArmyCampInstancingManager;
tbManager.tbInstancingUsable = {};		-- 副本使用情况
tbManager.tbWaitQueue = {};				-- 等待GC完成地图载入的玩家队列
tbManager.tbInstancingLib = {};			-- 副本基类库

tbManager.tbHuntingRank = {};		-- 打猎排行榜

-- 根据FB获得副本的基类
function tbManager:GetInstancingBase(nInstancingTemplateId)
	if (not self.tbInstancingLib[nInstancingTemplateId]) then
		self.tbInstancingLib[nInstancingTemplateId] = {};
		self.tbInstancingLib[nInstancingTemplateId].nInstancingTemplateId = nInstancingTemplateId;
		self.tbInstancingLib[nInstancingTemplateId].tbSetting = self:GetInstancingSetting(nInstancingTemplateId);
	end
	
	return self.tbInstancingLib[nInstancingTemplateId];
end


-- 和Npc对话选择报名申请FB
function tbManager:AskRegisterInstancing(nInstancingTemplateId, nPlayerId)
	local tbSetting = self:GetInstancingSetting(nInstancingTemplateId);	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	assert(pPlayer);
	
	-- 开服天数限制
	if TimeFrame:GetServerOpenDay() < tbSetting.nOpenDayLimit then
		self:Warring(pPlayer, string.format("Máy chủ mở %s ngày mới có thể tham gia", tbSetting.nOpenDayLimit));
		return;
	end
	
	-- 每个时间段只能报一次名
	local tbNow	= os.date("*t", GetTime());
	if (self:Time2Int(tbNow) == pPlayer.GetTask(tbSetting.tbInstancingTimeId.nTaskGroup, tbSetting.tbInstancingTimeId.nTaskId)) then
		self:Warring(pPlayer, "Lúc này đã báo danh rồi, không thể báo danh phó bản, xin vui lòng đợi");
		return;
	end
	
	if (IpStatistics:IsStudioRole(pPlayer) and self:GetCurOpenInstancingNum(tbNow.hour) >= self.nStudioMaxCount) then
		self:Warring(pPlayer, "Số phó bản đã đạt giới hạn");
		return;
	end

	-- 每个时间段的副本有上限
	if (self:GetCurOpenInstancingNum(tbNow.hour) >= self.nInstancingMaxCount) then
		self:Warring(pPlayer, "Số phó bản đã đạt giới hạn");
		return;
	end
	
	-- 必须组队且队长才能报名
	if (pPlayer.nTeamId <= 0 or pPlayer.IsCaptain() ~= 1) then
		self:Warring(pPlayer, "Đội trưởng mới được báo danh");
		return;
	end
	
	
	-- 只能在指定时间内才能报名
	if (self:CheckRegisterTime(nInstancingTemplateId, nPlayerId) ~= 1) then
		self:Warring(pPlayer, "Xin báo danh đúng thời gian quy định");
		return;
	end
	
	
	-- 附近队友数，是否有非法队友，且需要限制FB总数
	if (self:CheckTeamRegisterCondition(nInstancingTemplateId, nPlayerId) ~= 1) then
		return;
	end
	
	
	-- 成功申请后会给附近队友提示
	local szMsg = "Đội này đã báo danh phó bản"..tbSetting.szName;
	KTeam.Msg2Team(pPlayer.nTeamId, szMsg);
	
	self:RegisterSucess(nInstancingTemplateId, nPlayerId);
end



-- 判断是否在指定的时间内
function tbManager:CheckRegisterTime(nInstancingTemplateId, nPlayerId)
	local tbSetting = self:GetInstancingSetting(nInstancingTemplateId);
	local nNowTime	= GetTime();
	local tbToday	= os.date("*t", nNowTime);
	local nHour 	= tbToday.hour;
	local nMin		= tbToday.min;
	local bOK		= 0;
	for _, nOpenHour in ipairs(tbSetting.tbOpenHour) do
		if (nOpenHour == nHour) then
			bOK = 1;
		end
	end
	if (bOK ~= 1) then
		return 0;
	end

	if (nMin > tbSetting.tbOpenDuration) then
		return 0;
	end
	
	return 1;
end

-- 检查队友是否合法
function tbManager:CheckTeamRegisterCondition(nInstancingTemplateId, nPlayerId)
	local pCaptain = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pCaptain) then
		return 0;
	end
	
	local tbSetting = self:GetInstancingSetting(nInstancingTemplateId);
	local tbTeammateList, _ = pCaptain.GetTeamMemberList();
	
	local nCount = 0;
	for _, pPlayer in ipairs(tbTeammateList) do
		if (pPlayer.nMapId == pCaptain.nMapId) then
			local nRet, szMsg = self:CheckRegisterCondition(nInstancingTemplateId, pPlayer.nId);
			if (nRet ~= 1) then
				self:Warring(pCaptain, szMsg);
				return 0;
			end	
			
			if (pPlayer.nMapId == pCaptain.nMapId) then
				nCount = nCount + 1;
			end
		end
	end
	
	if (nCount < tbSetting.nMinPlayer) then
		self:Warring(pCaptain, "Phải có "..(tbSetting.nMinPlayer-nCount).." đồng đội ở gần!");
		return 0;
	end
	
	return 1;
end



-- 申请成功
function tbManager:RegisterSucess(nInstancingTemplateId, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	assert(pPlayer);
	local tbInstancingList = self:GetRunInstancingList();
	for _, tbInstancing in pairs(tbInstancingList) do
		if (tbInstancing.nTeamId == pPlayer.nTeamId) then
			tbInstancing.nTeamId = nil;
		end
	end;
	
	local nMapId = self:GetFreeInstancing(nInstancingTemplateId);
	if (nMapId) then
		self:OpenMap(nMapId, nInstancingTemplateId, nPlayerId)
	else
		local nMapTemplateId = self:GetInstancingSetting(nInstancingTemplateId).nInstancingMapTemplateId;
		if (LoadDynMap(Map.DYNMAP_TREASUREMAP, nMapTemplateId, nInstancingTemplateId) == 1) then
			self.tbWaitQueue[#self.tbWaitQueue + 1] = {nPlayerId = nPlayerId, nInstancingTemplateId = nInstancingTemplateId};
		end
	end
end


-- 申请进入FB
function tbManager:AskEnterInstancing(nInstancingTemplateId, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	
	local nRet, szErrorMsg = self:CheckEnterCondition(nInstancingTemplateId, nPlayerId);
	if (nRet ~= 1) then
		self:Warring(pPlayer, szErrorMsg);
		return;
	end

	local tbSetting = self:GetInstancingSetting(nInstancingTemplateId);
	local tbInstancingList = self:GetRunInstancingList();
	assert(tbInstancingList);

	for _, tbInstancing in pairs(tbInstancingList) do 
		if ((tbInstancing.nTeamId == pPlayer.nTeamId) and
			(tbInstancing.nInstancingTemplateId == nInstancingTemplateId) and
			self:Time2Int(tbInstancing.tbOpenTime) > pPlayer.GetTask(tbSetting.tbInstancingTimeId.nTaskGroup, tbSetting.tbInstancingTimeId.nTaskId)) then -- TODO:liuchang 跨年的时候会有问题
				--if (self:CheckTaskLimit(pPlayer, tbSetting.nInstancingEnterLimit_D) ~= 1) then
				if (pPlayer.GetTask(tbSetting.nInstancingRemainEnterTimes.nTaskGroup, tbSetting.nInstancingRemainEnterTimes.nTaskId) <= 0) then
					self:Warring(pPlayer, "Số lần ngươi vào phó bản đã đến giới hạn.");
					return;
				else
					self:BindPlayer2Instancing(pPlayer.nId, nInstancingTemplateId, tbInstancing.tbOpenTime, tbInstancing.nMapId, tbInstancing.nRegisterMapId); -- TODO:liuchang 有漏洞
					tbInstancing:OnPlayerAskEnter(pPlayer.nId);
					return;
				end
		end
	end
	
	for _, tbInstancing in pairs(tbInstancingList) do		
		local nPlayerInstancingMapId = pPlayer.GetTask(tbSetting.tbInstancingMapId.nTaskGroup, tbSetting.tbInstancingMapId.nTaskId);
		if (tbInstancing.nMapId == nPlayerInstancingMapId) and
			(tbInstancing.nInstancingTemplateId == nInstancingTemplateId) then
			if (self:Time2Int(tbInstancing.tbOpenTime) == pPlayer.GetTask(tbSetting.tbInstancingTimeId.nTaskGroup, tbSetting.tbInstancingTimeId.nTaskId)) then
				tbInstancing:OnPlayerAskEnter(pPlayer.nId);
				return;
			end
		end
	end

	local nRegisterMapId = pPlayer.GetTask(tbSetting.nRegisterMapId.nTaskGroup, tbSetting.nRegisterMapId.nTaskId);
	local tbNow	= os.date("*t", GetTime());
	local nLastHour = (self:Time2Int(tbNow) - pPlayer.GetTask(tbSetting.tbInstancingTimeId.nTaskGroup, tbSetting.tbInstancingTimeId.nTaskId));
	local nLastMin = nLastHour * 60 + tbNow.min;	
		-- 之前注册的FB还未关闭则先进入该服务器的军营
	if (nLastMin * 60 < tbSetting.nInstancingExistTime) then
		if (nRegisterMapId ~= pPlayer.nMapId and nRegisterMapId ~= 0) then
			self:Send2RegisterMap(nRegisterMapId, nPlayerId);
			return;
		end
	end
		
	self:Warring(pPlayer, "Báo danh trước hoặc tìm được khu quân doanh của đội lúc báo danh vào phó bản");
end

-- 选择去报名地图
function tbManager:Send2RegisterMap(nRegisterMapId, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	assert(pPlayer);
	Setting:SetGlobalObj(pPlayer, him, it)
	local szRegisterMapName = Task:GetMapName(nRegisterMapId);
	
	local szMainMsg = "Bạn đã ở "..szRegisterMapName.." báo danh, xin tới khu vực này để vào phó bản";
	local tbSendPos = {
		[24] = {1934,3414},
		[25] = {1444,3091},
		[29] = {1577,4114},
	};
	local tbOpt = {
		{"Đi ngay bây giờ", self.ChoseCamp, self, nPlayerId, nRegisterMapId, tbSendPos[nRegisterMapId][1], tbSendPos[nRegisterMapId][2]},
		{"Kết thúc đối thoại"}
	}
	
	Dialog:Say(szMainMsg, tbOpt);
	Setting:RestoreGlobalObj();
end

function tbManager:ChoseCamp(nPlayerId, nMapId, nPosX, nPosY)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	assert(pPlayer);
	
	pPlayer.NewWorld(nMapId, nPosX, nPosY);
end

-- 进入FB的条件
function tbManager:CheckEnterCondition(nInstancingTemplateId, nPlayerId)
	local tbSetting = self:GetInstancingSetting(nInstancingTemplateId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return 0, "Người chơi không tồn tại";
	end
	
	-- 白名玩家
	if (pPlayer.nFaction <= 0) then
		return 0, pPlayer.szName.."Là người chơi chữ trắng!";
	end
	
	-- 等级限制
	if (pPlayer.nLevel < tbSetting.nMinLevel) then
		return 0, pPlayer.szName.." (đẳng cấp) nhỏ hơn "..tbSetting.nMinLevel;
	end
	
	if (pPlayer.nLevel > tbSetting.nMaxLevel) then
		return 0, pPlayer.szName.." (đẳng cấp) lớn hơn "..tbSetting.nMaxLevel;
	end
	
	local nHaveTask = 0;
	for _, nTaskId in ipairs(tbSetting.tbHaveTask) do
		if (Task:HaveTask(pPlayer, nTaskId) == 1) then
			nHaveTask = 1;
			break;
		end
	end
	if nHaveTask ~= 1 and #tbSetting.tbHaveTask > 0 then 
		if (self:CheckTaskLimit(pPlayer, tbSetting.nJuQingTaskLimit_W) == 1) then
			local nRet, szMsg = Task:CheckAcceptTask(pPlayer, tbSetting.tbJuqingTask.nTaskId, tbSetting.tbJuqingTask.nReferId);
			if nRet ~= 1 then
				if szMsg and szMsg ~= "" then
					return 0, pPlayer.szName .. szMsg;
				else
					return 0, "";
				end
			end
		elseif (self:CheckTaskLimit(pPlayer, tbSetting.nDailyTaskLimit_W) == 1) then
			local nRet, szMsg = Task:CheckAcceptTask(pPlayer, tbSetting.tbRichangTask.nTaskId, tbSetting.tbRichangTask.nReferId);
			if nRet ~= 1 then
				if szMsg and szMsg ~= "" then
					return 0, pPlayer.szName .. szMsg;
				else
					return 0, "";
				end
			end
		else
			return 0, pPlayer.szName.." không thể nhận nhiệm vụ";
		end
	end

	return 1;
end


-- 检查玩家的报名条件
function tbManager:CheckRegisterCondition(nInstancingTemplateId, nPlayerId)
	local tbSetting = self:GetInstancingSetting(nInstancingTemplateId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return 0, "Người chơi không tồn tại";
	end
	
	
	-- 白名玩家
	if (pPlayer.nFaction <= 0) then
		return 0, pPlayer.szName.."Là người chơi chữ trắng!";
	end
	
	-- 等级下限
	if (pPlayer.nLevel < tbSetting.nMinLevel) then
		return 0, pPlayer.szName.." (đẳng cấp) nhỏ hơn "..tbSetting.nMinLevel;
	end
	
	-- 等级上限
	if (pPlayer.nLevel > tbSetting.nMaxLevel) then
		return 0, pPlayer.szName.." (đẳng cấp) lớn hơn "..tbSetting.nMaxLevel;
	end
	
	-- 每日进入FB的上限
	--if (self:CheckTaskLimit(pPlayer, tbSetting.nInstancingEnterLimit_D) ~= 1) then
	if (pPlayer.GetTask(tbSetting.nInstancingRemainEnterTimes.nTaskGroup, tbSetting.nInstancingRemainEnterTimes.nTaskId) <= 0) then
		return 0, pPlayer.szName.."Số lần vào phó bản hôm nay đã đạt giới hạn.";
		
	end
	
	-- 这个时间点已经报过名的不能再参与报名
	local tbNow	= os.date("*t", GetTime());
	if (self:Time2Int(tbNow) == pPlayer.GetTask(tbSetting.tbInstancingTimeId.nTaskGroup, tbSetting.tbInstancingTimeId.nTaskId)) then
		return 0, pPlayer.szName.." đã báo danh rồi";
	end
	local nHaveTask = 0;
	for _, nTaskId in ipairs(tbSetting.tbHaveTask) do
		if (Task:HaveTask(pPlayer, nTaskId) == 1) then
			nHaveTask = 1;
			break;
		end
	end
	if nHaveTask ~= 1 and #tbSetting.tbHaveTask > 0 then	
		if (self:CheckTaskLimit(pPlayer, tbSetting.nJuQingTaskLimit_W) == 1) then
			local nRet, szMsg = Task:CheckAcceptTask(pPlayer, tbSetting.tbJuqingTask.nTaskId, tbSetting.tbJuqingTask.nReferId);
			if nRet ~= 1 then
				if szMsg and szMsg ~= "" then
					return 0, pPlayer.szName .. szMsg;
				else
					return 0, pPlayer.szName .. " không thể nhận nhiệm vụ chính tuyến";
				end
			end
		elseif (self:CheckTaskLimit(pPlayer, tbSetting.nDailyTaskLimit_W) == 1) then
			local nRet, szMsg = Task:CheckAcceptTask(pPlayer, tbSetting.tbRichangTask.nTaskId, tbSetting.tbRichangTask.nReferId);
			if nRet ~= 1 then
				if szMsg and szMsg ~= "" then
					return 0, pPlayer.szName .. szMsg;
				else
					return 0, pPlayer.szName .. " không thể nhận nhiệm vụ hằng ngày";
				end
			end
		else
			return 0, pPlayer.szName .. " không thể nhận nhiệm vụ";
		end
	end
	
	-- 记录参加次数
	local nNum = pPlayer.GetTask(StatLog.StatTaskGroupId , 5) + 1;
	pPlayer.SetTask(StatLog.StatTaskGroupId , 5, nNum);
	return 1;
end


-- GC通知一个地图被载入
function tbManager:OnLoadMapFinish(nMapId, nMapTemplateId, nInstancingTemplateId)
	if (#self.tbWaitQueue == 0) then
		assert(false);
		return;
	end
	local tbSetting = self:GetInstancingSetting(nInstancingTemplateId);
	for nIndex = 1, #self.tbWaitQueue do
		if (nInstancingTemplateId == self.tbWaitQueue[nIndex].nInstancingTemplateId) then
			local pPlayer = KPlayer.GetPlayerObjById(self.tbWaitQueue[nIndex].nPlayerId);
			if (pPlayer and pPlayer.nTeamId ~= 0) then
				self.tbInstancingUsable[nInstancingTemplateId][#self.tbInstancingUsable[nInstancingTemplateId] + 1] = {MapTemplateId = nMapTemplateId, MapId = nMapId, Free = 0};
				self:OpenMap(nMapId, nInstancingTemplateId, pPlayer.nId);
				table.remove(self.tbWaitQueue, nIndex);
				break;
			else
				self.tbInstancingUsable[nInstancingTemplateId][#self.tbInstancingUsable[nInstancingTemplateId] + 1] = {MapTemplateId = nMapTemplateId, MapId = nMapId, Free = 1};
				table.remove(self.tbWaitQueue, nIndex);
				break;
			end
		end
	end
end


-- 获得一个空闲的副本
function tbManager:GetFreeInstancing(nInstancingTemplateId)
	if (not self.tbInstancingUsable[nInstancingTemplateId]) then
		self.tbInstancingUsable[nInstancingTemplateId] = {};
		return;
	end
	
	for _, tbInstancing in ipairs(self.tbInstancingUsable[nInstancingTemplateId]) do
		if (tbInstancing.Free == 1) then
			return tbInstancing.MapId;
		end
	end
end


-- 判断一个模板地图是否是军营任务的地图
function tbManager:IsArmyCampInstancingMap(nMapTemplateId)
	for _, tbSetting in pairs(self.tbSettings) do
		if (tbSetting.nInstancingMapTemplateId == nMapTemplateId) then
			return 1;
		end
	end
	
	return 0;
end

function tbManager:GetNpcLevel(pPlayer)
	local tbDay2Level = {
		-- 开服XX天，怪物等级底线
			[1] = {80, 90},
			[2] = {120, 100},
			[3] = {210, 110},
			[4] = {390, 120},
			[5] = {720, 130},
		};
	local nNowTime = GetTime();
	local nNowDay	= Lib:GetLocalDay(nNowTime);
	local nOpenTime = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	local nOpenDay	= Lib:GetLocalDay(nOpenTime);
	local nDetDay	= nNowDay - nOpenDay;
	local nNpcLevel = 0;
	local nLimitLevel	= 0;
	for _, tbInfo in ipairs(tbDay2Level) do
		if (nDetDay < tbInfo[1]) then
			break;
		end
		nLimitLevel = tbInfo[2];
	end
	-- 保底等级是90级
	if (nOpenTime <= 0 or nLimitLevel <= 0) then
		nLimitLevel = 90;
	end
	if (not pPlayer) then
		return nLimitLevel;
	end
	local tbTeammateList, nMemCount = pPlayer.GetTeamMemberList();
	if (tbTeammateList) then
		for _, pPlayer in ipairs(tbTeammateList) do
			nNpcLevel = nNpcLevel + pPlayer.nLevel;
		end
		if (nMemCount > 0) then
			nNpcLevel = math.ceil(nNpcLevel/nMemCount);
		end
	end
	if (nNpcLevel < nLimitLevel) then
		nNpcLevel = nLimitLevel;
	end
	return nNpcLevel;
end

-- 开启一个FB
function tbManager:OpenMap(nMapId, nInstancingTemplateId, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	assert(pPlayer);
	
	-- 重置地图的Npc和Obj
	ResetMapNpc(nMapId);
	local tbInstancingBase = self:GetInstancingBase(nInstancingTemplateId);
	local tbInstancing = Lib:NewClass(tbInstancingBase);
	tbInstancing.nMapId = nMapId;
	tbInstancing.nTeamId = pPlayer.nTeamId;
	tbInstancing.nOpenerId = nPlayerId;
	tbInstancing.szOpenerName = pPlayer.szName;
	tbInstancing.nPlayerCount = 0;
	tbInstancing.tbOpenTime	= os.date("*t", GetTime());
	tbInstancing.nRegisterMapId = pPlayer.nMapId;
	tbInstancing.szRegisterMapName = Task:GetMapName(tbInstancing.nRegisterMapId);
	tbInstancing.nNpcLevel = self:GetNpcLevel(pPlayer);
	local tbInstancingList = self:GetRunInstancingList();
	assert(not tbInstancingList[nMapId]);
	tbInstancingList[nMapId] = tbInstancing;
	self:BindTeam2Instancing(nPlayerId, nInstancingTemplateId, tbInstancing.tbOpenTime, nMapId, pPlayer.nMapId);
	tbInstancing:OnOpen();
	
	
	for _, tbInstancing in ipairs(self.tbInstancingUsable[nInstancingTemplateId]) do
		if (tbInstancing.MapId == nMapId) then
			tbInstancing.Free = 0;
			break;
		end
	end
	
	--额外事件，活动系统
	SpecialEvent.ExtendEvent:DoExecute("Open_ArmyCamp", nMapId, nInstancingTemplateId);
	
end

-- 队伍和此FB绑定
function tbManager:BindTeam2Instancing(nPlayerId, nInstancingTemplateId, tbOpenTime, nMapId, nRegisterMapId)
	local pCaptain = KPlayer.GetPlayerObjById(nPlayerId);
	assert(pCaptain);
	local tbTeammateList, _ = pCaptain.GetTeamMemberList();
	for _, pPlayer in ipairs(tbTeammateList) do
		if (pPlayer.nMapId == nRegisterMapId) then
			-- 在申请FB成功到GC答复FB载入成功中间有一小段时间，这段时间内，可能有非法队友进来
			if (self:CheckRegisterCondition(nInstancingTemplateId, pPlayer.nId) == 1) then
				self:BindPlayer2Instancing(pPlayer.nId, nInstancingTemplateId, tbOpenTime, nMapId, nRegisterMapId);
			end
		end
	end
end


-- 队员和此FB绑定
function tbManager:BindPlayer2Instancing(nPlayerId, nInstancingTemplateId, tbOpenTime, nMapId, nRegisterMapId)
	local tbSetting = self:GetInstancingSetting(nInstancingTemplateId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	
	pPlayer.DirectSetTask(tbSetting.tbInstancingMapId.nTaskGroup, tbSetting.tbInstancingMapId.nTaskId, nMapId, 1); 									-- 玩家记录所属的FB地图Id
	pPlayer.DirectSetTask(tbSetting.tbInstancingTimeId.nTaskGroup, tbSetting.tbInstancingTimeId.nTaskId, self:Time2Int(tbOpenTime), 1);	-- 玩家记录自己和副本绑定的时间
	pPlayer.SetTask(tbSetting.nRegisterMapId.nTaskGroup, tbSetting.nRegisterMapId.nTaskId, nRegisterMapId);										-- 玩家记录他的报名地图Id
end


-- 关闭一个FB
function tbManager:CloseMap(nMapId)
	local tbInstancingList = self:GetRunInstancingList();
	assert(tbInstancingList[nMapId]);
	local tbInstancing = tbInstancingList[nMapId];
	local nInstancingTemplateId = tbInstancing.nInstancingTemplateId;
	for _, tbInstancing in ipairs(self.tbInstancingUsable[nInstancingTemplateId]) do
		if (tbInstancing.MapId == tbInstancingList[nMapId].nMapId) then
			tbInstancing.Free = 1;
			break;
		end
	end
	
	tbInstancingList[nMapId] = nil;
end


-- 获得当前运行的副本列表，它可能不是连续的索引
function tbManager:GetRunInstancingList()
	if (not self.tbInstancingList) then
		self.tbInstancingList = {};
	end
	
	return self.tbInstancingList;
end

function tbManager:GetInstancing(nMapId)
	return self.tbInstancingList[nMapId];
end


--------------------------------------------------------------
-- 获得指定FB的配置
function tbManager:GetInstancingSetting(nInstancingTemplateId)
	assert(self.tbSettings[nInstancingTemplateId])
	return self.tbSettings[nInstancingTemplateId];
end

-- 获得指定FB的临时重生点
function tbManager:GetRevivePos(nInstancingTemplateId)
	local tbSetting = self:GetInstancingSetting(nInstancingTemplateId);
	return unpack(tbSetting.tbRevivePos);
end

-- 获得指定FB的生存时间
function tbManager:GetInstancingExistTime(nInstancingTemplateId)
	local tbSetting = self:GetInstancingSetting(nInstancingTemplateId);
	return tbSetting.nInstancingExistTime;
end

-- 获得开启FB需要的最小玩家数
function tbManager:GetMinPlayerCount(nInstancingTemplateId)
	local tbSetting = self:GetInstancingSetting(nInstancingTemplateId);
	return tbSetting.nMinPlayer;
end

-- FB能容纳的最大玩家数
function tbManager:GetMaxPlayerCount(nInstancingTemplateId)
	local tbSetting = self:GetInstancingSetting(nInstancingTemplateId);
	return tbSetting.nMaxPlayer;
end

-- 获得进入FB的等级下限
function tbManager:GetLevelMinLimit(nInstancingTemplateId)
	local tbSetting = self:GetInstancingSetting(nInstancingTemplateId);
	return tbSetting.nMinLevel;
end

-- 获得进入FB的等级上限
function tbManager:GetLevelMaxLimit()
	local tbSetting = self:GetInstancingSetting(nInstancingTemplateId);
	return tbSetting.nMaxLevel;
end

-- 获得离报名的时间(分)
function tbManager:GetRegisterWaitTime(nInstancingTemplateId)
	if (not nInstancingTemplateId) then
		nInstancingTemplateId = 1;
	end
	
	local tbSetting = self:GetInstancingSetting(nInstancingTemplateId);
	local nNowTime	= GetTime();
	local tbToday	= os.date("*t", nNowTime);
	local nHour 	= tbToday.hour;
	local nNextHour	= 0;
	local nMin		= tbToday.min;
	local bOK		= 0;
	
	for _, nOpenHour in ipairs(tbSetting.tbOpenHour) do
		if (nOpenHour == nHour and nMin <= tbSetting.tbOpenDuration) then
			return 0;
		elseif (nOpenHour > nHour) then
			return (60 - nMin) + (nOpenHour - nHour -1) * 60;
		end
	end
	
	return (tbSetting.tbOpenHour[1] + 24 - nHour -1) * 60 + (60 - nMin);
end

--玩家进入副本打开时间计时显示
function tbManager:OpenArmyCampUi(nPlayerId, nTimerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	assert(pPlayer);

	if nTimerId <= 0 then
		return 0;
	end
	local nLastFrameTime = tonumber(Timer:GetRestTime(nTimerId));
	local szMsg = "<color=green>Phó bản kết thúc còn<color> <color=white>%s<color>"
	Dialog:SetBattleTimer(pPlayer,  szMsg, nLastFrameTime);
	Dialog:ShowBattleMsg(pPlayer,  1,  0); --开启界面
		
end

--玩家离开副本关闭时间计时显示
function tbManager:CloseArmyCampUi(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	assert(pPlayer);	
	Dialog:ShowBattleMsg(pPlayer,  0,  0); -- 关闭界面
end

-- 获得本周完成副本剧情任务的次数
function tbManager:GetGutTaskTimesThisWeek(nInstancingTemplateId, nPlayerId)
	local pPlayer = nil;
	if (MODULE_GAMECLIENT) then
		pPlayer = me;
	else
		pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	end
	
	if (not pPlayer) then
		return;
	end
	
	if (not nInstancingTemplateId) then
		nInstancingTemplateId = 1;
	end
	
	local tbSetting = self:GetInstancingSetting(nInstancingTemplateId);
	
	return pPlayer.GetTask(tbSetting.nJuQingTaskLimit_W.nTaskGroup, tbSetting.nJuQingTaskLimit_W.nTaskId);
end

-- 获得当前已经开启的副本数目
function tbManager:GetCurOpenInstancingNum(nHour)
	local tbRunInstancingList = self:GetRunInstancingList();
	local nCount = 0;
	for _, Instancing in pairs(tbRunInstancingList) do
		if (Instancing.tbOpenTime.hour == nHour) then
			nCount = nCount + 1;
		end
	end
	
	return nCount;
end

-- 本周完成的副本日常任务次数为
function tbManager:GetDailyTaskTimesThisWeek(nInstancingTemplateId, nPlayerId)
	local pPlayer = nil;
	
	if (MODULE_GAMECLIENT) then
		pPlayer = me;
	else
		pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	end

	if (not pPlayer) then
		return;
	end
	
	if (not nInstancingTemplateId) then
		nInstancingTemplateId = 1;
	end
	
	local tbSetting = self:GetInstancingSetting(nInstancingTemplateId);
	
	return pPlayer.GetTask(tbSetting.nDailyTaskLimit_W.nTaskGroup, tbSetting.nDailyTaskLimit_W.nTaskId);
end

-- 今天进入FB的次数
function tbManager:EnterInstancingThisDay(nInstancingTemplateId, nPlayerId)
	local pPlayer = nil;
	if (MODULE_GAMECLIENT) then
		pPlayer = me;
	else
		pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	end

	assert(pPlayer);
	
	if (not nInstancingTemplateId) then
		nInstancingTemplateId = 1;
	end
	
	local tbSetting = self:GetInstancingSetting(nInstancingTemplateId);
	--local nTimes = pPlayer.GetTask(tbSetting.nInstancingEnterLimit_D.nTaskGroup, tbSetting.nInstancingEnterLimit_D.nTaskId);
	local nTimes = pPlayer.GetTask(tbSetting.nInstancingRemainEnterTimes.nTaskGroup, tbSetting.nInstancingRemainEnterTimes.nTaskId);
	return nTimes;
end


-- 今天读兵书的数量
function tbManager:GetBingShuReadTimesThisDay(nPlayerId)
	local pPlayer;
	if (MODULE_GAMECLIENT) then
		pPlayer = me;
	else
		pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	end
	
	assert(pPlayer);
	
	local nReadCount = 0;
	if (pPlayer.nLevel < 110) then
		nReadCount = 1 - pPlayer.GetTask(1022, 118);
	elseif (pPlayer.nLevel < 130) then
		nReadCount = 1 - pPlayer.GetTask(1022, 164);
	else
		nReadCount = 1 - pPlayer.GetTask(1022, 181);
	end;
	return nReadCount;
end

-- 今天读机关书的数量
function tbManager:JiGuanShuReadedTimesThisDay(nPlayerId)
	local pPlayer;
	if (MODULE_GAMECLIENT) then
		pPlayer = me;
	else
		pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	end
	
	assert(pPlayer);
	
	local nReadCount = 0;
	if (pPlayer.nLevel < 110) then
		nReadCount = 1 - pPlayer.GetTask(1022, 131);
	elseif (pPlayer.nLevel < 130) then
		nReadCount = 1 - pPlayer.GetTask(1022, 166);
	else
		nReadCount = 1 - pPlayer.GetTask(1022, 183);
	end;
	return nReadCount;
end


-- 检查任务变量
function tbManager:CheckTaskLimit(pPlayer, tbTask)
	if (pPlayer.GetTask(tbTask.nTaskGroup, tbTask.nTaskId) >= tbTask.nLimitValue) then
		return 0;
	end
	
	return 1;
end


-- 每周清一次
function tbManager:WeekEvent()
	me.SetTask(1024, 52, 0, 1);
	me.SetTask(1024, 51, 0, 1);
	me.SetTask(1024, 55, 0, 1);
	me.SetTask(1024, 58, 0, 1);
	me.SetTask(1022, 174, 0, 1);
	me.SetTask(1022, 180, 0, 1);
	me.SetTask(1022, 187, 1, 1);
	me.SetTask(1022, 229, 0, 1);
	me.SetTask(1022, 230, 0, 1);
end

-- 每天清一次
function tbManager:DailyEvent()
	if (me.nLevel < 110) then
		me.SetTask(1022, 118, 1, 1);	-- 读兵书标记
		me.SetTask(1022, 131, 1, 1);	-- 机关书
		me.SetTask(1022, 132, 1, 1);	
	elseif (me.nLevel > 109 and me.nLevel < 130) then
		me.SetTask(1022, 164, 1, 1);    -- 读兵书标记
		me.SetTask(1022, 166, 1, 1);    -- 机关书
		me.SetTask(1022, 171, 1, 1);
	else
		me.SetTask(1022, 181, 1, 1);    -- 读兵书标记
		me.SetTask(1022, 183, 1, 1);    -- 机关书
		me.SetTask(1022, 185, 1, 1);	
	end;
	
	me.SetTask(2043, 1, 0, 1);
	me.SetTask(1022, 173, 1, 1);
	self:UpdateEnterTimes();
end

-- 登录事件
function tbManager:LoginEvent()
	self:UpdateEnterTimes();
	local tbPlayerTasks	= Task:GetPlayerTask(me).tbTasks;
	local tbTask = tbPlayerTasks[429];
	if tbTask then
		me.SetTask(1025, 70, 1);
	end
end

-- 更新可进副本的次数
function tbManager:UpdateEnterTimes()
	if me.nLevel < 80 then
		return;
	end
	local nDay = Lib:GetLocalDay();
	local nTaskDay = me.GetTask(1025, 63);
	if nTaskDay == 0 then
		me.SetTask(1025, 63, nDay);
		me.SetTask(1025, 62, self.nDailyEnterTimes + 2); --送两次
		return;
	end
	if nDay > nTaskDay then
		local nAddTimes = (nDay - nTaskDay) * self.nDailyEnterTimes;
		local nTotalTimes = me.GetTask(1025, 62) + nAddTimes;
		if nTotalTimes > self.nMaxEnterTimes then
			me.SetTask(1025, 62, self.nMaxEnterTimes);
		else
			me.SetTask(1025, 62, nTotalTimes);
		end
		me.SetTask(1025, 63, nDay);
	end
end


function tbManager:Warring(pPlayer, szMsg, nTime)
	if (MODULE_GAMESERVER) then
		pPlayer.CallClientScript({"Ui:ServerCall", "UI_TASKTIPS", "Begin", szMsg, nTime});		
	end
end


function tbManager:ShowTip(pPlayer, szMsg, nTime)
	if (MODULE_GAMESERVER) then
		pPlayer.CallClientScript({"Ui:ServerCall", "UI_TASKTIPS", "Begin", szMsg, nTime});		
	end
end

function tbManager:Tip2MapPlayer(nMapId, szMsg, nTime)
	local tbPlayList, nCount = KPlayer.GetMapPlayer(nMapId);
	for _, pPlayer in ipairs(tbPlayList) do
		self:ShowTip(pPlayer, szMsg, nTime);
	end
end

function tbManager:Time2Int(tbTime)
	local nYear = tbTime.year or 0;
	local nDay	= tbTime.yday or 0;
	local nHour = tbTime.hour or 0;
	return	nYear * 1000 * 100 + nDay * 100 + nHour;
end

function tbManager:UpdateHuntingRank(tbRank)
	local nIndex = 1;
	for i = 1, #self.tbHuntingRank do
		if tbRank.nPoint > self.tbHuntingRank[i].nPoint then
			break;
		end
		nIndex = i + 1;
	end
	if nIndex <= 5 then
		table.insert(self.tbHuntingRank, nIndex, tbRank);
		if #self.tbHuntingRank > 5 then
			self.tbHuntingRank[6] = nil;
		end
		return nIndex;
	end
	return 0;
end

function tbManager:GetHuntingRank()
	return self.tbHuntingRank;
end

PlayerSchemeEvent:RegisterGlobalDailyEvent({Task.tbArmyCampInstancingManager.DailyEvent, Task.tbArmyCampInstancingManager});

PlayerSchemeEvent:RegisterGlobalWeekEvent({Task.tbArmyCampInstancingManager.WeekEvent, Task.tbArmyCampInstancingManager});
PlayerEvent:RegisterOnLoginEvent(Task.tbArmyCampInstancingManager.LoginEvent, Task.tbArmyCampInstancingManager);