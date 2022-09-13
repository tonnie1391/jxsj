-------------------------------------------------------
-- 文件名　：marry_mission.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-01-05 01:23:41
-- 文件描述：
-------------------------------------------------------

Require("\\script\\marry\\logic\\marry_def.lua");

if (not MODULE_GAMESERVER) then
	return 0;
end

local tbMission = Mission:New();
Marry.Mission = tbMission;

-- 副本开启后调用
function tbMission:OnOpen()	
	-- 公告等等
end

-- 副本结束后调用
function tbMission:OnClose()
	local tbNpc = Npc:GetClass("marry_ruyi");
	tbNpc:SendGift2Couple(self.szMaleName, self.szFemaleName, self.nDynMapId);
end

-- 玩家加入mission后调用
function tbMission:OnJoin(nGroupId)
	self:AddCurPlayerCount(1);
	self:OpenRightUI(me, (self.nEndTime - GetTime()) * Env.GAME_FPS);
	self:UpdateAllRightUI();
end

-- 玩家离开mission后调用
function tbMission:OnLeave(nGroupId, szReason)
	self:AddCurPlayerCount(-1);
	self:UpdateAllRightUI();
	self:CloseRightUI(me);
end

-- 副本开启
function tbMission:StartGame(szMaleName, szFemaleName, nDynMapId, nMapLevel, nWeddingLevel, nStartTime, nEndTime)
	
	self.nDynMapId = nDynMapId;				-- 地图编号
	self.nMapLevel = nMapLevel;				-- 地图等级
	self.nWeddingLevel = nWeddingLevel;		-- 婚礼等级
	self.szMaleName = szMaleName;			-- 新郎名字
	self.szFemaleName = szFemaleName;		-- 新娘名字
	self.nStartTime = nStartTime;			-- 开启时间
	self.nEndTime = nEndTime;				-- 结束时间
	self.nMaxPlayer = Marry.MAX_MAP_PLAYER;	-- 地图人数上限
	self.nCurPlayer = 0;					-- 地图当前人数
	self.nPerformState = 0;					-- 表演状态
	self.nCurStep = 1;						-- 仪式步骤
	self.nFoodStep = 0;						-- 第几道菜
	self.nFireWork = 0;						-- 烟火状态
	self.nTicket = 0;						-- 抽奖步骤
	self.szRightMsg = "";					-- 右侧显示信息
	self.nMiniGameStep = 0;					-- 第几个小游戏
	
	-- 配置项
	self.tbMisCfg	= 
	{
		tbLeavePos		= {[0] = {5, 1633, 2955}},				-- 离开坐标
		nPkState		= Player.emKPK_STATE_PRACTISE,			-- 练功模式
		nForbidStall	= 1,									-- 禁止摆摊
	};
	
	-- 权限列表
	self.tbPermission = 
	{
		[1] = {};
		[2] = {},
		[3]	= {},
		[4] = {szMaleName, szFemaleName},
	};
	
	-- 用餐列表
	self.tbDinner = {};
	
	-- 在中心台子的玩家列表
	self.tbPlayerOnStage = {};
	
	-- 外部timer分组存储
	self.tbSpecTimer = {};
	
	-- 开启mission
	self:Open();
	
	Dbg:WriteLog("Marry", "结婚系统", 
		string.format("%s跟%s的典礼开启", szMaleName, szFemaleName),
		string.format("开启日期：%s", os.date("%Y年%m月%d日%H分", GetTime())),
		string.format("典礼档次：%s", nWeddingLevel),
		string.format("场地类型：%s", Marry.MAP_LEVEL_NAME[nMapLevel])
	);
end

-- 获得婚礼主人名字
function tbMission:GetWeddingOwnerName()
	return {self.szMaleName, self.szFemaleName};
end

-- 设置仪式步骤
function tbMission:SetCurStep(nStep)
	self.nCurStep = nStep;
	self:UpdateAllRightUI();
end

-- 获得仪式步骤
function tbMission:GetCurStep()
	return self.nCurStep;
end

-- 设置第几道菜
function tbMission:SetFoodStep(nStep)
	self.nFoodStep = nStep;
end

-- 获得第几道菜
function tbMission:GetFoodStep()
	return self.nFoodStep;
end

-- 设置玩家权限
function tbMission:SetPlayerLevel(szPlayerName, nLevel)
	
	-- 是否清出表
	if nLevel == 0 then
		for nTmpLevel, tbRow in pairs(self.tbPermission) do
			for nIndex, szName in pairs(self.tbPermission[nTmpLevel]) do
				if szName == szPlayerName then
					table.remove(self.tbPermission[nTmpLevel], nIndex);
				end
			end
		end
		
	-- 更改权限
	else
		if not self.tbPermission[nLevel] then
			return 0;
		end
		-- 先删除
		for nTmpLevel, tbRow in pairs(self.tbPermission) do
			for nIndex, szName in pairs(self.tbPermission[nTmpLevel]) do
				if szName == szPlayerName then
					table.remove(self.tbPermission[nTmpLevel], nIndex);
				end
			end
		end
		-- 再插入
		table.insert(self.tbPermission[nLevel], szPlayerName);		
	end
end

-- 获取玩家权限
function tbMission:GetPlayerLevel(szPlayerName)
	for nLevel, tbPlayerList in pairs(self.tbPermission) do
		for _, szName in pairs(tbPlayerList) do
			if szName == szPlayerName then
				return nLevel;
			end
		end
	end
	return 0;
end

-- 返回玩家权限列表
function tbMission:GetAllPermission()
	return self.tbPermission;
end

-- 判断是否在中心台子
function tbMission:CheckPlayerOnStage(szPlayerName)
	for _, szName in pairs(self.tbPlayerOnStage) do
		if szName == szPlayerName then
			return 1;
		end
	end
	return 0;
end

-- 增加台上玩家
function tbMission:AddPlayerOnStage(szPlayerName)
	if self:CheckPlayerOnStage(szPlayerName) == 0 then
		table.insert(self.tbPlayerOnStage, szPlayerName);
	end
end

-- 删除台上玩家
function tbMission:RemovePlayerOnStage(szPlayerName)
	for nIndex, szName in pairs(self.tbPlayerOnStage) do
		if szName == szPlayerName then
			table.remove(self.tbPlayerOnStage, nIndex);
		end
	end
end

-- 设置婚礼等级
function tbMission:SetWeddingLevel(nWeddingLevel)
	self.nWeddingLevel = nWeddingLevel;
end

-- 得到婚礼等级
function tbMission:GetWeddingLevel()
	return self.nWeddingLevel;
end

-- 增加地图人数上限(只能增加)
function tbMission:AddMaxPlayerCount(nCount)
	self.nMaxPlayer = self.nMaxPlayer + nCount;
end

-- 得到地图人数上限
function tbMission:GetMaxPlayerCount()
	return self.nMaxPlayer;
end

-- 返回对话
function tbMission:GetNpcTalk(nLevel, nNpcId)
	if Marry.tbNpcTalk[nLevel] then
		local tbMsg = {};
		for nIndex, tbTalk in pairs(Marry.tbNpcTalk[nLevel][nNpcId] or {}) do
			if not tbTalk[2] then
				tbMsg[nIndex] = tbTalk[1];
			else
				tbMsg[nIndex] = string.format(tbTalk[1], self.szMaleName, self.szFemaleName);
			end
		end
		return tbMsg;
	end
	return nil;
end

-- 设置表演
function tbMission:SetPerformState(nState)
	self.nPerformState = nState;
end

-- 得到表演状态
function tbMission:GetPerformState()
	return self.nPerformState;
end

-- 设置礼包信息
function tbMission:SetLibaoInfo(tbInfo)
	self.tbLibaoInfo = tbInfo;
end

-- 得到礼包信息
function tbMission:GetLibaoInfo()
	return self.tbLibaoInfo;
end

-- 保存主持人id
function tbMission:SetWitnessesId(nWithnessesId)
	self.nWithnessesId = nWithnessesId;
end

-- 获取主持人id
function tbMission:GetWithnessesId()
	return self.nWithnessesId;
end

-- 烟火状态
function tbMission:GetFireState()
	return self.nFireWork;
end

-- 设置烟火
function tbMission:SetFireState(nFireWork)
	self.nFireWork = nFireWork;
end

-- 抽奖一次
function tbMission:AddTicket()
	self.nTicket = self.nTicket + 1;
end

-- 获取抽奖次数
function tbMission:GetTicket()
	return self.nTicket;
end

-- 设置小游戏步骤
function tbMission:SetMiniGameStep(nStep)
	self.nMiniGameStep = nStep;
end

-- 返回小游戏步骤
function tbMission:GetMiniGameStep()
	return self.nMiniGameStep;
end

-- 使用一道菜
function tbMission:SetDinner(szPlayerName, nDinner)
	self.tbDinner[szPlayerName] = nDinner;
end

-- 获取使用菜数
function tbMission:GetDinner(szPlayerName)
	if not self.tbDinner[szPlayerName] then
		return 0;
	end
	return self.tbDinner[szPlayerName];
end

-- 获得当前地图人数
function tbMission:GetCurPlayerCount()
	return self.nCurPlayer;
end

-- 增加当前地图人数
function tbMission:AddCurPlayerCount(nCount)
	self.nCurPlayer = self.nCurPlayer + nCount;
end

-- 右侧信息界面
function tbMission:OpenRightUI(pPlayer, nRemainFrame)
	if not pPlayer then
		return 0;
	end
	Dialog:SetBattleTimer(pPlayer, "<color=green>Thời gian hành lễ: %s<color>\n", nRemainFrame);
	Dialog:ShowBattleMsg(pPlayer, 1, 0);	
end

-- 更新右侧信息
function tbMission:UpdateRightUI(szMsg)
	self.szRightMsg = szMsg;
	self:UpdateAllRightUI();
end

-- 关闭信息界面
function tbMission:CloseRightUI(pPlayer)
	if not pPlayer then
		return 0;
	end
	Dialog:ShowBattleMsg(pPlayer, 0, 0);
end

-- 更新所有玩家右侧信息
function tbMission:UpdateAllRightUI()
	local tbPlayers = self:GetPlayerList();
	local szMsg = string.format("<color=yellow>当前场地人数：%s/%s<color>\n%s\n\n%s", 
		self:GetCurPlayerCount(), self:GetMaxPlayerCount(), Marry.PERFORM_STEP[self.nCurStep], self.szRightMsg);
	for _, pPlayer in pairs(tbPlayers or {}) do
		Dialog:SendBattleMsg(pPlayer, szMsg, 1);
	end
end

-- 按类别获取外部timerid
function tbMission:GetSpecTimer(szKey)
	if not self.tbSpecTimer[szKey] then
		return nil;
	end
	local tbRet = {};
	for nTimerId, _ in pairs(self.tbSpecTimer[szKey]) do
		table.insert(tbRet, nTimerId);
	end
	return tbRet;
end

-- 按类别增加外部timerid
function tbMission:AddSpecTimer(szKey, nTimerId)
	if not self.tbSpecTimer[szKey] then
		self.tbSpecTimer[szKey] = {};
	end
	if not self.tbSpecTimer[szKey][nTimerId] then
		self.tbSpecTimer[szKey][nTimerId] = 1;
	end
end

-- 按类别清除外部timerid
function tbMission:ClearSpecTimer(szKey)
	if self.tbSpecTimer[szKey] then
		self.tbSpecTimer[szKey] = nil;
	end
end

-- 设置来访npc信息
function tbMission:SetVisitorNpc(tbInfo)
	self.tbVisitorNpc = tbInfo;
end

-- 获取来访npc信息
function tbMission:GetVisitorNpc()
	return self.tbVisitorNpc;
end
