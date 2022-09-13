-- 文件名　：console_gs.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-04-23 10:04:41
-- 描  述  ：--控制台

if (MODULE_GC_SERVER) then
	return 0;
end

Console.Base = Console.Base or {};
local tbBase = Console.Base;

----接口,自定义----

--进入活动场地
function tbBase:OnJoin()
	--print("OnJoin", me.szName)
end

--离开活动场地
function tbBase:OnLeave()
	--print("OnLeave", me.szName)
end

--进入准备场地后
function tbBase:OnJoinWaitMap()
	--print("OnJoinWaitMap", me.szName)
end

--离开准备场地后
function tbBase:OnLeaveWaitMap()
	--print("OnLeaveWaitMap", me.szName)
end

--分组逻辑
function tbBase:OnGroupLogic()
	--print("OnGroupLogic");
end
--开启界面
function tbBase:OpenSingleUi(pPlayer, szMsg, nLastFrameTime)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SetBattleTimer(pPlayer,  szMsg, nLastFrameTime);
	Dialog:ShowBattleMsg(pPlayer,  1,  0); --开启界面
end

--关闭界面
function tbBase:CloseSingleUi(pPlayer)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:ShowBattleMsg(pPlayer,  0,  0); -- 关闭界面
end

--更新界面时间
function tbBase:UpdateTimeUi(pPlayer, szMsg, nLastFrameTime)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SetBattleTimer(pPlayer,  szMsg, nLastFrameTime);
end

--更新界面信息
function tbBase:UpdateMsgUi(pPlayer, szMsg)
	if not pPlayer or pPlayer == 0 then
		return 0;
	end
	Dialog:SendBattleMsg(pPlayer, szMsg, 1);
end

function tbBase:GetRestTime()
	if self.tbTimerList.nReadyId then
		return Timer:GetRestTime(self.tbTimerList.nReadyId);
	end
	return 0;
end

function tbBase:KickPlayer(pPlayer)
	pPlayer.NewWorld(self:GetLeaveMapPos());
end

function tbBase:KickAllPlayer()
	if not self.tbGroupLists then
		return 0;
	end
	for nMapId, tbGroupList in pairs(self.tbGroupLists) do
		if SubWorldID2Idx(nMapId) >= 0 then
			local tbGroupLists = tbGroupList.tbList;
			if tbGroupLists then
				for nGroup, tbGroup in pairs(tbGroupLists) do
					for _, nPlayerId in pairs(tbGroup) do
						local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
						if pPlayer then
							self:KickPlayer(pPlayer);
						end
					end
				end
			end
		end
	end	
end

---调用接口----

--报名,进入准备场
function tbBase:ApplySignUp(tbPlayerIdList)
	if self:IsFull(#tbPlayerIdList) == 0 then
		Dialog:Say("人数已满！");
		return 0;
	end
	if self:GetRestTime() <= 5*18 then
		Dialog:Say("报名结束了！");
		return 0;
	end
	Console:ApplySignUp(self.nDegree, tbPlayerIdList);
end

----end----

--地图配置Start
function tbBase:SetMapCfg()
	if self.tbCfg.tbMap then
		for nMapId, tbPos in pairs(self.tbCfg.tbMap) do
			local tbReadyMap = Map:GetClass(nMapId);
			tbReadyMap.OnEnterConsole = function() self:MapReadyOnEnter() end;
			tbReadyMap.OnLeaveConsole = function() self:MapReadyOnLeave() end;
		end
	end
	
	if self.tbCfg.nDynamicMap and self.tbCfg.nDynamicMap > 0 then
		local tbMap = Map:GetClass(self.tbCfg.nDynamicMap);
		tbMap.OnEnterConsole = function() self:MapOnEnter() end;
		tbMap.OnLeaveConsole = function() self:MapOnLeave() end;
	end
end

function tbBase:ApplyDyMap()
	if self.tbCfg.tbMap and self.tbCfg.nDynamicMap then
		for nMapId, tbPos in pairs(self.tbCfg.tbMap) do
			if SubWorldID2Idx(nMapId) >= 0 then
				Console:ApplyDyMap(self.nDegree, nMapId);
			end
		end
	end
end

function tbBase:GetLeaveMapPos()
	for nMapId, tbPos in pairs(self.tbCfg.tbMap) do
		if SubWorldID2Idx(nMapId) >= 0 then
			if tbPos and tbPos.tbOutPos then
				return unpack(tbPos.tbOutPos);
			end
		end
	end
	
	local tbNpc = Npc:GetClass("chefu");
	for _, tbMapInfo in ipairs(tbNpc.tbCountry) do
		if SubWorldID2Idx(tbMapInfo.nId) >= 0 then
			local nRandomPos = MathRandom(1, #tbMapInfo.tbSect)
			return tbMapInfo.nId, tbMapInfo.tbSect[nRandomPos][1],tbMapInfo.tbSect[nRandomPos][2];
		end
	end
	return 5, 1580, 3029;
end

--对象，分配动态地图索引，组号；
function tbBase:OnDyJoin(pPlayer, nDyId, GroupId)
	local tbData = self:GetPlayerData(pPlayer.nMapId, pPlayer.nId);
	if not tbData then
		return 0;
	end
	local nCaptain = tbData.nCaptain;
	local nGroupId = tbData.nGroupId;
	local nMapId   = tbData.nMapId;	
	
	self.tbMapGroupList[nMapId][nDyId] = self.tbMapGroupList[nMapId][nDyId] or {};
	self.tbMapGroupList[nMapId][nDyId][GroupId] = self.tbMapGroupList[nMapId][nDyId][GroupId] or {tbList={},tbPos={}};
	table.insert(self.tbMapGroupList[nMapId][nDyId][GroupId].tbList, pPlayer.nId);
end

function tbBase:StartSignUp()
	self:KickAllPlayer();
	self:Init();
	self:SetMapCfg();
	self:ApplyDyMap();	
	local nDegree = self.nDegree;
	self.nState 	  = 1;
	self.tbTimerList.nReadyId = Timer:Register((self.tbCfg.nReadyTime), self.TimerClose, self)	
	if self.OnMySignUp then
		self:OnMySignUp();
	end
end

function tbBase:TimerClose()
	--self.nState 	  = 2;
	return 0;
end

function tbBase:MapReadyOnEnter()
	me.SetLogoutRV(1);
	if self.nState ~=  1 then
		return 0;
	end
	self:ReadyOnJoin(me.nMapId, me.nId);
	self:OnJoinWaitMap();
end


function tbBase:MapReadyOnLeave()
	--me.SetLogoutRV(0);
	self:CloseSingleUi(me);
	self:ReadyOnLeave(me.nMapId, me.nId);
	self:OnLeaveWaitMap();
end

function tbBase:MapOnEnter()
	me.SetLogoutRV(1);
	self:ConsumeTask(me); -- 进入地图扣次数回调
	self:OnJoin();
end

function tbBase:MapOnLeave()
	self:CloseSingleUi(me);
	self:OnLeave();
	--me.SetLogoutRV(0);
end

--地图配置End

function tbBase:GetPlayerData(nMapId, nId)
	return self.tbPlayerData[nMapId][nId];
end

--进入准备场
function tbBase:ReadyOnJoin(nMapId, nId)
	local tbData = self:GetPlayerData(nMapId, nId);
	if not tbData then
		return 0;
	end
	local nCaptain = tbData.nCaptain;
	local nGroupId = tbData.nGroupId;
	--local nMapId = tbData.nMapId;

	if nCaptain == 1 then
		table.insert(self.tbGroupLists[nMapId].tbList[nGroupId], 1, nId);
	else
		table.insert(self.tbGroupLists[nMapId].tbList[nGroupId], nId);
	end
end

--离开准备场
function tbBase:ReadyOnLeave(nMapId, nId)
	if self.nState >= 2 then
		return 0;
	end	
	GCExcute{"Console:LeaveGroupList", self.nDegree, nMapId, nId};
	Console:LeaveGroupList(self.nDegree, nMapId, nId);
	GlobalExcute{"Console:LeaveGroupList", self.nDegree, nMapId, nId};
end

function tbBase:OnStartMission()
	self.nState 	  = 2;
	local nDyMapIndex = 1;
	if not self.tbGroupLists then
		return 0;
	end
	for nMapId, tbGroupList in pairs(self.tbGroupLists) do
		if SubWorldID2Idx(nMapId) >= 0 then
			self:OnGroupLogic(nMapId);
		end
	end
	
	local nDegree = self.nDegree;
	for nWaitMapId, tbPos in pairs(self.tbCfg.tbMap) do
		if SubWorldID2Idx(nWaitMapId) >= 0 then
			for nDyId, tbGroupLists in pairs(self.tbMapGroupList[nWaitMapId]) do
				local nDyMapId = self.tbDynMapLists[nWaitMapId][nDyId];
				local tbCfg = {
					nWaitMapId	 = nWaitMapId,		--准备场Id
					nDyMapId 	 = nDyMapId,	--活动场Id
					tbGroupLists = tbGroupLists,	--队伍列表
				}
				self:OnMyStart(tbCfg);
			end
		end
	end
	self.tbGroupLists = {};
	return 0;
end

-- 默认分组函数，这个是大部分都能用
function tbBase:GroupLogic(nReadyMap)
	local nMapId	= nReadyMap;
	local tbGroup	= self.tbGroupLists[nMapId];
	
	if (not tbGroup) then
		return 0;
	end
	
	if (self:ProcessMatchCanOpen(nMapId) ~= 1) then
		return 0;
	end
	
	if SubWorldID2Idx(nMapId) > 0 then
		local tbGroupLists = self:LogicPreProcess(tbGroup);
		local tbGroupMatchList, tbGroupFlag = self:LogicBase(tbGroupLists);--基础分配逻辑
		local nCurMembers, nLastMembers = self:LogicGetLastSeries(tbGroupMatchList);
		self:LogicAvgTeam(tbGroupMatchList, tbGroupFlag, nLastMembers, nCurMembers);
		self:LogicCheckKickOut(tbGroupMatchList,nLastMembers, nCurMembers);--轮空处理
		self:LogicEnterGame(tbGroupMatchList, nMapId);--进场比赛
	end
	
	return 1;
end

-- 准备场人数不足无法开启
function tbBase:ProcessMatchCanOpen(nWaitMapId)
	local tbGroup	= self.tbGroupLists[nWaitMapId];
	local nWaitNum	= 0;
		
	for _, tbGroupTemp in ipairs(tbGroup.tbList) do
		nWaitNum = nWaitNum + #tbGroupTemp;
	end
	
	if (nWaitNum >= self.tbCfg.nMinDynPlayer) then
		return 1;
	end
	
	local nLeaveMapId, nLeavePosX, nLeavePosY = self:GetLeaveMapPos()
	
	for _, tbGroupTemp in ipairs(tbGroup.tbList) do
		for _, nId in pairs(tbGroupTemp) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer then
				pPlayer.Msg(string.format("参赛人数不足%s人，比赛无法开启", self.tbCfg.nMinDynPlayer));
				Dialog:SendBlackBoardMsg(pPlayer, string.format("参赛人数不足%s人，比赛无法开启", self.tbCfg.nMinDynPlayer));
				--self:ConsumeTask(pPlayer);
				pPlayer.NewWorld(nLeaveMapId, nLeavePosX, nLeavePosY);
			end
		end
	end
	
	return 0;
end

function tbBase:LogicPreProcess(tbGroup)
	local tbGroupLists = {};
	for nMem=1, self.tbCfg.nMaxTeamMember do
		tbGroupLists[nMem] = {};
	end

	for _, tbGroupTemp in ipairs(tbGroup.tbList) do
		if #tbGroupTemp > 0 then
			table.insert(tbGroupLists[#tbGroupTemp], tbGroupTemp);
		end
	end
	
	--打乱原有顺序
	for _, tbGroups in ipairs(tbGroupLists) do
		for i in pairs(tbGroups) do
			local nP = MathRandom(1, #tbGroups);
			tbGroups[i], tbGroups[nP] = tbGroups[nP], tbGroups[i];
		end
	end
	return tbGroupLists;
end

--基础分配逻辑
function tbBase:LogicBase(tbGroupLists)
	--匹配原则。
	local tbGroupMatchList = {{}};
	local tbGroupFlag = {};
	local nGroupFlag = 0; 
	local nloop = 1;	--防止死循环,最多10000次循环
	while(self:CheckGroupLists(tbGroupLists)==1 and nloop <= 10000) do
		local nCurMembers = #tbGroupMatchList;
		
		--如果表中人员人数超过六个人,则新建下一个空表
		if #tbGroupMatchList[nCurMembers] >= self.tbCfg.nMaxTeamMember then
			nCurMembers = nCurMembers + 1;
			tbGroupMatchList[nCurMembers] = {};
		end
		
		local nIsCreateNewGroup = 1;
		--查找符合条件的队伍加入表中
		for nMem = self.tbCfg.nMaxTeamMember, 1, -1 do
			if #tbGroupLists[nMem] > 0 then
				if  #tbGroupLists[nMem][1] > 0 and #tbGroupMatchList[nCurMembers] + #tbGroupLists[nMem][1] <= self.tbCfg.nMaxTeamMember then
					nGroupFlag = nGroupFlag + 1;
					for _, nId in pairs(tbGroupLists[nMem][1]) do
						tbGroupFlag[nId] = nGroupFlag;
						table.insert(tbGroupMatchList[nCurMembers], nId);
					end
					table.remove(tbGroupLists[nMem], 1);
					nIsCreateNewGroup = 0;
				end
			end
		end
		
		--没找到符合条件的队伍,则新建下一个空表
		if nIsCreateNewGroup == 1 then
			nCurMembers = nCurMembers + 1;
			tbGroupMatchList[nCurMembers] = {};
		end
		
		nloop = nloop + 1;
	end
	return tbGroupMatchList, tbGroupFlag;
end

function tbBase:LogicGetLastSeries(tbGroupMatchList)
	local nCurMembers = #tbGroupMatchList;
	if #tbGroupMatchList[nCurMembers] <= 0 then
		table.remove(tbGroupMatchList, nCurMembers);
	end
	
	nCurMembers = #tbGroupMatchList;
	local nLastMembers = nCurMembers - 1;
	if math.mod(nCurMembers, 2) ~= 0 or nCurMembers == 0 then
		nLastMembers = nCurMembers + 1;
	end
	return  nCurMembers, nLastMembers;
end

--最后两队伍平均分配
function tbBase:LogicAvgTeam(tbGroupMatchList, tbGroupFlag, nLastMembers, nCurMembers)
	--对最后匹配的2队进行平均分配
	
	local tbGroupA = tbGroupMatchList[nLastMembers] or {};
	local tbGroupB = tbGroupMatchList[nCurMembers] or {};
	local nMid = math.floor((#tbGroupA + #tbGroupB)/2);
	local tbFlag = {};
	for _, nId in pairs(tbGroupA) do
		tbFlag[tbGroupFlag[nId]] = tbFlag[tbGroupFlag[nId]] or {};
		table.insert(tbFlag[tbGroupFlag[nId]], nId);
	end
	for _, nId in pairs(tbGroupB) do
		tbFlag[tbGroupFlag[nId]] = tbFlag[tbGroupFlag[nId]] or {};
		table.insert(tbFlag[tbGroupFlag[nId]], nId);
	end
	local nMinTeamMember = self.tbCfg.nMinTeamMember or 0;
	if (#tbGroupA < nMinTeamMember or #tbGroupB < nMinTeamMember) then
		local nLeaveMapId, nLeavePosX, nLeavePosY = self:GetLeaveMapPos()
		for _, nId in pairs(tbGroupA) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer then
				pPlayer.Msg("很抱歉，本次活动轮空，请等待下次活动开启！");
				Dialog:SendBlackBoardMsg(pPlayer, "很抱歉，本次活动轮空，请等待下次活动开启！");
				pPlayer.NewWorld(nLeaveMapId, nLeavePosX, nLeavePosY);
			end
		end
		for _, nId in pairs(tbGroupB) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer then
				pPlayer.Msg("很抱歉，本次活动轮空，请等待下次活动开启！");
				Dialog:SendBlackBoardMsg(pPlayer, "很抱歉，本次活动轮空，请等待下次活动开启！");
				pPlayer.NewWorld(nLeaveMapId, nLeavePosX, nLeavePosY);
			end
		end
		tbGroupA = {};
		tbGroupB = {};
	else
		tbGroupA = {};
		tbGroupB = {};
		for _, tbGroup in pairs(tbFlag) do
			if #tbGroupA <= nMid and (#tbGroupA + #tbGroup) <= nMid then
				for _, nId in pairs(tbGroup) do
					table.insert(tbGroupA, nId);
				end
			else
				for _, nId in pairs(tbGroup) do
					table.insert(tbGroupB, nId);
				end						
			end
		end
	end
	tbGroupMatchList[nLastMembers] = tbGroupA;
	tbGroupMatchList[nCurMembers] = tbGroupB;
	return tbGroupMatchList;
end

--轮空处理
function tbBase:LogicCheckKickOut(tbGroupMatchList, nLastMembers, nCurMembers)
	local nLeaveMapId, nLeavePosX, nLeavePosY = self:GetLeaveMapPos()
	--轮空
	if #tbGroupMatchList[nLastMembers] <=0 or #tbGroupMatchList[nCurMembers] <= 0 then
		for _, nId in pairs(tbGroupMatchList[nLastMembers]) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer then
				pPlayer.Msg("很抱歉，本次活动轮空，请等待下次活动开启！");
				Dialog:SendBlackBoardMsg(pPlayer, "很抱歉，本次活动轮空，请等待下次活动开启！");
				pPlayer.NewWorld(nLeaveMapId, nLeavePosX, nLeavePosY);
			end
		end
		for _, nId in pairs(tbGroupMatchList[nCurMembers]) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer then
				pPlayer.Msg("很抱歉，本次活动轮空，请等待下次活动开启！");
				Dialog:SendBlackBoardMsg(pPlayer, "很抱歉，本次活动轮空，请等待下次活动开启！");
				--self:ConsumeTask(pPlayer);
				pPlayer.NewWorld(nLeaveMapId, nLeavePosX, nLeavePosY);
			end
		end
		if nLastMembers < nCurMembers then
			nLastMembers, nCurMembers = nCurMembers, nLastMembers;
		end
		table.remove(tbGroupMatchList, nLastMembers);
		table.remove(tbGroupMatchList, nCurMembers);
	end
	return tbGroupMatchList;
end

function tbBase:LogicEnterGame(tbGroupMatchList, nMapId)
	local nLeaveMapId, nLeavePosX, nLeavePosY = self:GetLeaveMapPos()
	for nKey = 1, #tbGroupMatchList, 2 do
		local nTeam = math.floor(nKey/2)+1;
		self.tbDynMapLists[nMapId] = self.tbDynMapLists[nMapId] or {};
		local nDyMapId = self.tbDynMapLists[nMapId][nTeam];

		local nCaptionAId =0;
		for _, nId in pairs(tbGroupMatchList[nKey]) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer then
				if nDyMapId then
					--self:ConsumeTask(pPlayer); -- 移到进入地图的时候再扣次数
					self:OnDyJoin(pPlayer, nTeam, nKey);
				else
					pPlayer.Msg("地图加载出现异常，本场比赛无法开启，请联系GM。");
					pPlayer.NewWorld(nLeaveMapId, nLeavePosX, nLeavePosY);					
				end
			end
		end
		
		nCaptionAId = 0;
		for _, nId in pairs(tbGroupMatchList[nKey + 1]) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer then
				if nDyMapId then
					--self:ConsumeTask(pPlayer); -- 移到进入地图的时候再扣次数
					self:OnDyJoin(pPlayer, nTeam, nKey + 1);
				else
					pPlayer.Msg("地图加载出现异常，本场比赛无法开启，请联系GM。");
					pPlayer.NewWorld(nLeaveMapId, nLeavePosX, nLeavePosY);
				end
			end
		end
	end
end

--检查是否没有队伍
function tbBase:CheckGroupLists(tbGroupLists)
	for nMem = 1, self.tbCfg.nMaxTeamMember do
		if #tbGroupLists[nMem] > 0 then
			return 1;
		end
	end
	return 0;
end

-- 记录玩家参赛次数的
function tbBase:ConsumeTask(pPlayer)
end

-- 默认设置玩家入场状态
function tbBase:SetJoinGameState(nGroupId)
	me.ClearSpecialState()		--清除特殊状态
	me.RemoveSkillStateWithoutKind(Player.emKNPCFIGHTSKILLKIND_CLEARDWHENENTERBATTLE) --清除状态
	me.DisableChangeCurCamp(1);	--设置与帮会有关的变量，不允许在竞技场战改变某个帮会阵营的操作
	--me.SetFightState(1);	  	--设置战斗状态
	me.ForbidEnmity(1);			--禁止仇杀
	me.DisabledStall(1);		--摆摊
	me.ForbitTrade(1);			--交易
	me.ForbidExercise(1);		-- 禁止切磋
	me.SetCurCamp(nGroupId);
	me.TeamDisable(1);			--禁止组队
	me.TeamApplyLeave();		--离开队伍
	me.StartDamageCounter();	--开始计算伤害
	Faction:SetForbidSwitchFaction(me, 1); -- 进入准备场比赛场就不能切换门派
	me.SetDisableZhenfa(1);
	me.nForbidChangePK	= 1;
	Player:SetForbidGetItem(1);
end

--玩家离开准备场比赛场地
function tbBase:SetLeaveGameState()
	me.SetFightState(0);
	me.SetCurCamp(me.GetCamp());
	me.StopDamageCounter();	-- 停止伤害计算
	me.DisableChangeCurCamp(0);
	me.nPkModel = Player.emKPK_STATE_PRACTISE;--关闭PK开关
	me.nForbidChangePK	= 0;
	me.SetDeathType(0);
	me.RestoreMana();
	me.RestoreLife();
	me.RestoreStamina();
	me.DisabledStall(0);	--摆摊
	me.TeamDisable(0);		--禁止组队
	me.ForbitTrade(0);		--交易
	me.ForbidEnmity(0);
	me.ForbidExercise(0);		-- 切磋
	Faction:SetForbidSwitchFaction(me, 0); -- 进入准备场比赛场就切换门派还原
	me.SetDisableZhenfa(0);
	me.LeaveTeam();
	Player:SetForbidGetItem(0);
end

function tbBase:OnSingUpSucess(nPlayerId)
end
