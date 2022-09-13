--雪仗mission
--sunduoliang,maiyajin
--2009.01.12

Require("\\script\\mission\\esport\\esport_def.lua")

Esport.Mission = Esport.Mission or Mission:New();
local tbMission = Esport.Mission;

-- Mission用常量
tbMission.TIME_FPS_SYN_DAMAGE	  = Env.GAME_FPS * 2; -- 同步血量时间间隔
tbMission.TIME_FPS_REFRESH_NPC  = Env.GAME_FPS * 20; -- 刷npc时间间隔
tbMission.TIME_FPS_COUNT_DOWN	  = Env.GAME_FPS * 20; -- 倒数时间
tbMission.TIME_FPS_PLAY_TIME	  = Env.GAME_FPS * 160;-- 玩时间
tbMission.TIME_FPS_REST		  = Env.GAME_FPS * 20; -- 休息时间
tbMission.TIME_FPS_ENDPLAY	  = Env.GAME_FPS * 120; -- 结束休息时间
tbMission.TIME_FPS_GAMESUM	  = 1 + tbMission.TIME_FPS_COUNT_DOWN + tbMission.TIME_FPS_PLAY_TIME * 3 + tbMission.TIME_FPS_REST * 3; --总时间
tbMission.NPCID_BINGBAO			= 3708;

tbMission.NPC_REFRESH_COUNT = 10;  -- 刷NPC的数目

local tbMisEventList = 
	{
		{"count down",	1, 							"OnCountDown"},
		{"begin play",	tbMission.TIME_FPS_COUNT_DOWN,"OnPlay"},
		{"rest1",		tbMission.TIME_FPS_PLAY_TIME,	"OnRest"},
		{"play1",		tbMission.TIME_FPS_REST,		"OnPlay"},
		{"rest2",		tbMission.TIME_FPS_PLAY_TIME,	"OnRest"},
		{"play2",		tbMission.TIME_FPS_REST,		"OnPlay"},
		{"rest3",		tbMission.TIME_FPS_PLAY_TIME,	"OnRest"},
		{"endplay",	Env.GAME_FPS,	"OnEndPlayEx"},
		{"end", 		tbMission.TIME_FPS_ENDPLAY, 		"OnEndPlay"},
	};
	
tbMission.tbCallback2ContextFun = 
	{
		OnCountDown = "SetCountDownContext",
		OnPlay		= "SetPlayContext",
		OnRest		= "SetRestContext",
	};
	
tbMission.TRANSFORM_SKILL_ID 		= 1326; -- 变小孩技能
tbMission.NPC_ID_NIAN_SHOU		= 3617; -- 年兽id
tbMission.NPC_POS_NIAN_SHOU		= {50848/32,102560/32}; -- 年兽出现的地方
tbMission.SKILL_ID_NIAN_SHOU		= 1323; -- 年兽技能id
tbMission.NPC_ID_BAO_XIANG		= 3622; -- 宝箱id

-- 随机刷的雪堆Npc {[npcId] = {概率, {color scheme}}, ...}
-- 关于概率：例如npc a,b,c的概率分别为 10%, 10%, 80%, 那这里对应的概率为 1,1,8 或者 10，10，80 亦可
tbMission.tbNpc = {
	[3609] = {16}, [3610] = {16}, [3611] = {16}, [3612] = {16},[3613] = {16}, [3614] = {16}, -- 雪人
	[3615] = {2}, [3628] = {2}, [3629] = {2}, [3630] = {2}, [3631] = {2}, -- 陷阱
	[3616] = {3}, [3624] = {3}, [3625] = {3}, [3626] = {3}, -- 神符
	};

tbMission.tbNpcProbability = {};

for id, data in pairs(tbMission.tbNpc) do
	for i = 1, data[1] do
		table.insert(tbMission.tbNpcProbability, id);
	end
end

-- 刷NPC的位置 {x,y}
tbMission.tbNpcGenPos = {};

local tb = Lib:LoadTabFile("\\setting\\mission\\esport\\npc_refresh_pos.txt");
for _, pos in ipairs(tb) do
    table.insert(tbMission.tbNpcGenPos, {pos["TRAPX"]/32, pos["TRAPY"]/32})
end

tbMission.NPC_REFRESH_COUNT = math.min(tbMission.NPC_REFRESH_COUNT, #tbMission.tbNpcGenPos);

function tbMission:SetCountDownContext(pPlayer, nTime)
	nTime = nTime or self.TIME_FPS_COUNT_DOWN;
	pPlayer.SetFightState(0);
	Dialog:SetBattleTimer(pPlayer, "<color=green>Tổng thời gian: <color=white>%s<color>\n<color=green>Thời gian bắt đầu: <color=white>%s<color>\n", self.tbGameSumTimer:GetRestTime(), nTime);
	Dialog:SendBattleMsg(pPlayer, "");
	Dialog:ShowBattleMsg(pPlayer, 1, 0);
end

-- 开始前倒数回调
function tbMission:OnCountDown(nTime)
	for _, pPlayer in pairs(self:GetPlayerList()) do
		self:SetCountDownContext(pPlayer);
	end
end

function tbMission:SetPlayContext(pPlayer, nTime)
	nTime = nTime or self.TIME_FPS_PLAY_TIME;
	pPlayer.SetFightState(1);
	Dialog:SetBattleTimer(pPlayer, "<color=green>Tổng thời gian: <color=white>%s<color>\n<color=green>Thời gian vòng này: <color=white>%s<color>\n", self.tbGameSumTimer:GetRestTime(), nTime);
end

-- 进入游戏状态的回调
function tbMission:OnPlay()
	self.bResfreshNpc = 1;
	for _, pPlayer in pairs(self:GetPlayerList()) do
		self:SetPlayContext(pPlayer);
	end
	
	--if (self.nStateJour == 2) then -- 开始游戏
	
	self.tbCallNpcTimer = self:CreateTimer(18, self.RefreshNpc, self);
	self.tbBlizzardTimer = self:CreateTimer(30 * Env.GAME_FPS, self.BlizzardControl, self);
	self.tbNianShouTimer = self:CreateTimer(self.TIME_FPS_PLAY_TIME - 30 * Env.GAME_FPS, self.NianShouControl, self);
end

function tbMission:SetRestContext(pPlayer, nTime)
	nTime = nTime or self.TIME_FPS_REST;
	pPlayer.SetFightState(0);
	Dialog:SetBattleTimer(pPlayer, "<color=green>Tổng thời gian: <color=white>%s<color>\n\n<color=green>Thời gian nghỉ ngơi: <color=white>%s<color>", self.tbGameSumTimer:GetRestTime(), nTime);
end

function tbMission:GenerateFinalResult()
	--local szWin = "你的队伍胜利了！";
	--local szLost = "你的队伍失败了。";
	--local szTie = "两队战成平手。"
	--
	--local nResult = 3;
	--local szMsg1 = szTie;
	--local szMsg2 = szTie;
	--
	--if self.nGroupQuitEarly then
	--	if self.nGroupQuitEarly == 2 then
	--		nResult = 1;
	--	elseif self.nGroupQuitEarly == 1 then
	--		nResult = 2;
	--	end
	--else
	--	if self.tbDamage[1] < self.tbDamage[2] then
	--		nResult = 1;
	--	elseif self.tbDamage[2] < self.tbDamage[1] then
	--		nResult = 2;
	--	end
	--end
	--
	--if nResult == 1 then
	--	szMsg1 = szWin;
	--	szMsg2 = szLost;
	--elseif nResult == 2 then
	--	szMsg2 = szWin;
	--	szMsg1 = szLost;
	--end
	--
	--for _, pPlayer in pairs(self:GetPlayerList(1)) do
	--	Dialog:SendBlackBoardMsg(pPlayer, szMsg1);
	--end
	--
	--for _, pPlayer in pairs(self:GetPlayerList(2)) do
	--	Dialog:SendBlackBoardMsg(pPlayer, szMsg2);
	--end
	return;
end

function tbMission:CloseAllTimer()
	if self.tbCallNpcTimer then
		self.tbCallNpcTimer:Close();
		self.tbCallNpcTimer = nil;			
	end
	if self.tbBlizzardTimer then
		self.tbBlizzardTimer:Close();
		self.tbBlizzardTimer = nil;
	end
	if self.tbNianShouTimer then
		self.tbNianShouTimer:Close();
		self.tbNianShouTimer = nil;
	end
end

-- 休息
function tbMission:OnRest()
	if (self.nStateJour == 7) then -- 出比赛结果
		self:SynDamage();	--优先同步伤血量
		self:GenerateFinalResult();
--		Esport:AwardSingleSport(self:GetPlayerIdList(1), self:GetPlayerIdList(2), nResult);
	end
	
	self:CloseAllTimer();
	self:DelRefreshNpc();
	self:DelBlizzardNpc();
	for _, pPlayer in pairs(self:GetPlayerList()) do
		self:SetRestContext(pPlayer)
	end
end

--结束缓冲区
function tbMission:OnEndPlayEx()
	--提前到休息时间就算最终奖励了
	if self.tbCallbackOnClose then
		Lib:CallBack(self.tbCallbackOnClose);
	end
	
	for _, pPlayer in pairs(self:GetPlayerList()) do
		if self.tbCallbackEndPlay and type(self.tbCallbackEndPlay[1]) == "function" then
			self.tbCallbackEndPlay[1](self.tbCallbackEndPlay[2], pPlayer);
		end
	end
end

function tbMission:GetCurRank(pPlayer)
	local nGroupId = self:GetPlayerGroupId(pPlayer);
	for nRank, tbRank in pairs(self.tbDamage) do
		if tbRank[1] == nGroupId then
			return nRank;
		end
	end
	return 0;
end

-- 游戏结束回调
function tbMission:OnEndPlay()
	self:Close();
	return 0;
end

function tbMission:OnClose()
	ClearMapNpc(self.nMapId);
	self:CloseAllTimer();
end

function tbMission:OnDeath()
	if self:GetPlayerGroupId(me) >= 0 then
		self:KickPlayer(me);
	end
end

function tbMission:__open(tbEnterPos, tbLeavePos, nMatchType)
	if self:IsOpen() == 1 then
		print("雪仗重复开启");
		return;
	end
	
	self.nMapId	= tbEnterPos[1];
	self.tbMisCfg = {
		tbEnterPos				= {[0] = tbEnterPos},	-- 进入坐标
		tbLeavePos				= {[0] = tbLeavePos},	-- 离开坐标
		tbCamp					= {[1]=1,[2]=2},
		nPkState				= Player.emKPK_STATE_BUTCHER,
		nInLeagueState			= 1,
		nDeathPunish			= 1,
		nOnDeath				= 1,
		nForbidSwitchFaction	= 1,
		nLogOutRV				= Mission.LOGOUTRV_DEF_MISSION_ESPORT,
	};
	
	self.tbGroups	= {};
	self.tbPlayers	= {};
	self.tbTimers	= {};
	self.tbDamageList	 = {};
	self.tbDamage	= {};
	self.tbNowStateTimer = nil;
	self.tbNianShouTimer = nil;
	self.tbCallNpcTimer  = nil;
	self.nStateJour = 0;
	self.bResfreshNpc = 0; -- 控制在刷年兽时不刷Npc
	self.nGroupQuitEarly = nil;
	self.tbMisEventList	= tbMisEventList;
	self.tbGroupName = {};
	self.nGroupNum = 0;
	self.nNpcBlizzardId = nil;
	self.tbBlizzardNpcId = {};
	self.tbRefreshNpcId = {};
	self.nMatchType = nMatchType or 0;
	
	
	self.tbBlizzardNpcStatic = {};
	
	for _, pos in ipairs(Esport.tbBlizzardPos1) do
		local pNpc = KNpc.Add2(self.NPCID_BINGBAO, 1, -1, self.nMapId, pos[1]/32, pos[2]/32);
		if pNpc then
			pNpc.szName = "";
			table.insert(self.tbBlizzardNpcStatic, pNpc.dwId);
		else
			table.insert(self.tbBlizzardNpcStatic, -1);
		end
	end
	
	self.__debug_group_no = 0;
end

function tbMission:__start()
	self:CreateTimer(self.TIME_FPS_SYN_DAMAGE, self.SynDamage, self);
	self.tbGameSumTimer = self:CreateTimer(self.TIME_FPS_GAMESUM, self.OnGameTimeOver, self);
	self:GoNextState();
end


-- mission 控制 GoNextStateroupId
function tbMission:__join(__pPlayer)
	print("__join")
	local tb = {};
	local pPlayer = __pPlayer or me;
	if pPlayer.nTeamId == 0 then
		table.insert(tb, pPlayer);
	else
		local tbPlayerList = KTeam.GetTeamMemberList(pPlayer.nTeamId);
		if pPlayer.nId ~= tbPlayerList[1] then
			pPlayer.Msg("Hãy gọi đội trưởng đến báo danh!");
			return;
		end
		
		for _, nId in ipairs(tbPlayerList) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer then
				table.insert(tb, pPlayer);		
			end
		end
	end
	
	self.__debug_group_no = self.__debug_group_no + 1;
	
	for _, pPlayer in ipairs(tb) do
		self:JoinPlayer(pPlayer, self.__debug_group_no)
	end
	
	return self.__debug_group_no;
end

-- 测试的话不要直接调这个
-- 而是先 __open, 然后 JoinPlayer, 最后 __start
function tbMission:StartGame(tbEnterPos, tbLeavePos)
	self:__open(tbEnterPos, tbLeavePos);
	self:__start();
end

function tbMission:OnGameTimeOver()
	return 0;
end

function tbMission:GetGroupNum()
	return self.nGroupNum;
end

function tbMission:GetGroupName(nGroup)
	return self.tbGroupName[nGroup] or tostring(nGroup);
end

function tbMission:TransformChild(pPlayer, nGroup)
	if pPlayer.GetSkillState(self.TRANSFORM_SKILL_ID) <= 0 then
		local nMapId, nX, nY = pPlayer.GetWorldPos();
		local tbLevel = {[0] = {1,3},[1] = {2,4}};
		if not tbLevel[pPlayer.nSex] then
			tbLevel[pPlayer.nSex] = {1,3};
		end
		local nSkillLevel = tbLevel[pPlayer.nSex][math.fmod(nGroup, 2) + 1]; -- 1-4级依次变成3605-3608号npc
		pPlayer.CastSkill(self.TRANSFORM_SKILL_ID, nSkillLevel, nX, nY);				
	end
end

-- 同步血量
function tbMission:SynDamage()
	if (self:IsOpen() ~= 1)then
		return 0;
	end
	
	-- 更新每个玩家伤血量
	for nGroup=1, self:GetGroupNum() do
		self.tbDamageList[nGroup] = self.tbDamageList[nGroup] or {};
		for _, pPlayer in pairs(self:GetPlayerList(nGroup)) do
			self.tbDamageList[nGroup][pPlayer.nId] = pPlayer.GetAttackCounter() - pPlayer.GetDamageCounter(); -- nGroup -> {[id]=damage, [id]=damage...}
			self:TransformChild(pPlayer, nGroup);
		end
	end
	
	-- 更新每组玩家伤血量
	self.tbDamage = {};
	for nGroup, tbPlayerDamage in pairs(self.tbDamageList)do
		local tbRec = {nGroup, 0};	
		local nPlayerNum = self:GetPlayerCount(nGroup);
		if (nPlayerNum > 0) then
			for _, nDamage in pairs(tbPlayerDamage) do
				tbRec[2] = tbRec[2] + nDamage;
			end
			table.insert(self.tbDamage, tbRec);
		end
	end
	
	local sort_cmp = function (tb1, tb2)
		return tb1[2] > tb2[2];
	end
	table.sort(self.tbDamage, sort_cmp);
	
	self:GenerateAndSendMsg();
end

-- 获取结果
-- {[1] --> (nGroupId, nDamage), [2] --> ...}
function tbMission:GetResult()
	return self.tbDamage;
end

-- 右侧排名
function tbMission:GenerateAndSendMsg()
	local tbMsg = {};
	for _, tbRec in ipairs(self.tbDamage) do
		table.insert(tbMsg, string.format("%-16s：<color=white>%4d<color>", self:GetGroupName(tbRec[1]), 10000 + tbRec[2]));
	end
	local szMsg = table.concat(tbMsg, "\n");
	
	for _, pPlayer in pairs(self:GetPlayerList())do
		Dialog:SendBattleMsg(pPlayer, szMsg, 1);
	end
end

function tbMission:__DelRefreshNpc(tbNpcId)
	for _, nId in ipairs(tbNpcId) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			pNpc.Delete();
		end
	end
end

function tbMission:DelRefreshNpc()
	self:__DelRefreshNpc(self.tbRefreshNpcId);
	self.nCleanNpcTimerId = nil;
	return 0;
end

function tbMission:DelBlizzardNpc()
	self:__DelRefreshNpc(self.tbBlizzardNpcId);
end

-- 刷npc
function tbMission:RefreshNpc()
	if (self:IsOpen() ~= 1)then
		return 0;
	end
	Lib:ShuffleInPlace(self.tbNpcGenPos);
	
	for i = 1, self.NPC_REFRESH_COUNT do
		local nNpcId = self.tbNpcProbability[MathRandom(1, #self.tbNpcProbability)];
		local tbColor = self.tbNpc[nNpcId][2]; 
		local x, y = unpack(self.tbNpcGenPos[i]);
		local pNpc = nil
		if (not tbColor) then
			pNpc = KNpc.Add2(nNpcId, 1, -1, self.nMapId, x, y);
		else
			local nColor = tbColor[MathRandom(1, #tbColor)];
			pNpc = KNpc.Add2(nNpcId, 1, -1, self.nMapId, x, y, 0, 0, 0, 0, nColor);
		end	
		if pNpc then
			table.insert(self.tbRefreshNpcId, pNpc.dwId)
		end
	end
	
	if self.nCleanNpcTimerId then
		Timer:Close(self.nCleanNpcTimerId);
	end
	self.nCleanNpcTimerId = Timer:Register(10*Env.GAME_FPS, self.DelRefreshNpc, self);
	
	return self.TIME_FPS_REFRESH_NPC;
end

-- 每组的名字
function tbMission:AddGroupName(pPlayer, nGroupId, szGroupName)
	if szGroupName then
		self.tbGroupName[nGroupId] = szGroupName;
		return;
	end
	
	if self.tbGroupName[nGroupId] then
		return;
	end
	if pPlayer.nTeamId == 0 then
		self.tbGroupName[nGroupId] = pPlayer.szName;
	else
		local tbPlayerList = KTeam.GetTeamMemberList(pPlayer.nTeamId);
		local pCaptin = KPlayer.GetPlayerObjById(tbPlayerList[1]);
		if pCaptin then
			self.tbGroupName[nGroupId] = pCaptin.szName;
		else
			self.tbGroupName[nGroupId] = pPlayer.szName;
		end
	end
end

function tbMission:OnJoin(nGroupId)
	if self:GetPlayerCount(nGroupId) == 1 then
		self.nGroupNum = self.nGroupNum + 1;
	end
	
	self:AddGroupName(me, nGroupId);
	self:TransformChild(me, nGroupId);
	me.SetFightState(0);
	me.LevelUpFightSkill(1, Esport.SKILL_ID_SNOWBALL_ORIGINAL);
	FightSkill:SaveRightSkillEx(me, Esport.SKILL_ID_SNOWBALL_ORIGINAL);
	FightSkill:SaveRightSkillEx(me, Esport.SKILL_ID_SNOWBALL_ORIGINAL);
	me.StartDamageCounter();
	me.StartAttackCounter();
	me.SetCurCamp(math.fmod(nGroupId,3)+1);
	Player:SetFreshState(me, 1);
	
	if (self.nStateJour > 1) then --中途加入
		local szFun = self.tbCallback2ContextFun[self.tbMisEventList[self.nStateJour - 1][3]];
		local fun = self[szFun];
		fun(self, me, self:GetStateLastTime());
		Dialog:ShowBattleMsg(me, 1, 0);
	end
end

function tbMission:OnLeave(nGroupId, szReason)	
	-- 打回原形
	if me.GetSkillState(self.TRANSFORM_SKILL_ID) > 0 then
		me.RemoveSkillState(self.TRANSFORM_SKILL_ID);
	end
	-- 回到入口处
	me.SetFightState(0);
	Dialog:ShowBattleMsg(me,  0,  0);
	me.StopDamageCounter();
	me.StopAttackCounter();
	Player:SetFreshState(me, 0);
	
	if self.tbOnLevelMision then
		Lib:CallBack(self.tbOnLevelMision);
	end
	
	if self:GetPlayerCount(nGroupId) == 0 and self.nStateJour < 8 then -- 全队早退会输掉比赛
		-- 不是混战赛的话如果有一方队员全部退出了那么就
		if self.nMatchType and self.nMatchType == 2 then
			local nIndex = 0;
			for nId, tbInfo in pairs(self.tbDamage) do
				if (nGroupId == tbInfo[1]) then
					nIndex = nId;
					break;
				end
			end
			if (nIndex > 0) then
				table.remove(self.tbDamage, nIndex);
			end
			
			if (self:GetPlayerCount(0) > 1) then
				return 0;
			end
		end
	
		self.nGroupQuitEarly = nGroupId;
		self.tbGameSumTimer:Close();
		self.tbGameSumTimer = self:CreateTimer(self.TIME_FPS_REST, self.OnGameTimeOver, self);
		self.nStateJour = 7;
		self:GoNextState();
	end	
end

function tbMission:EndGame()
	self:OnEndPlay();
end
function tbMission:BlizzardControl()
	if self.nNpcBlizzardId then
		local pNpc = KNpc.GetById(self.nNpcBlizzardId);
		if pNpc then
			for _, pPlayer in pairs(self:GetPlayerList()) do
				Dialog:SendBlackBoardMsg(pPlayer, "Mưa đá sắp đến! Cẩn thận vỡ đầu...");
			end
			local _, x, y = pNpc.GetWorldPos();
			pNpc.CastSkill(1458, 1, x*32,y*32);
			table.insert(self.tbBlizzardNpcId, self.nNpcBlizzardId);
			
			for i, nNpcId in ipairs(self.tbBlizzardNpcStatic) do
				if nNpcId > 0 then
					local pNpc2 = KNpc.GetById(nNpcId);
					if pNpc2 then
						pNpc2.CastSkill(1458, 1, Esport.tbBlizzardPos1[i][1],Esport.tbBlizzardPos1[i][2]);
					end
				end
			end
		end
		self.nNpcBlizzardId = nil;
		return 30 * Env.GAME_FPS;
	else
		local x,y = unpack(self.tbNpcGenPos[1]);
		
		local pNpc = KNpc.Add2(self.NPCID_BINGBAO, 1, -1, self.nMapId, x, y);
		if not pNpc then
			return 30 * Env.GAME_FPS;
		else
			pNpc.szName = "";
			self.nNpcBlizzardId = pNpc.dwId;
			return 1*Env.GAME_FPS;
		end
	end
end

local tbNianShouWaitTime = 
{
	[1] = 0.5, -- 拉人
	[2] = 2, -- 年兽出招
	[3] = 8, -- 年兽消失
	[4] = 0,
};

-- 年兽控制
function tbMission:NianShouControl()
	if (self:IsOpen() ~= 1)then
		return 0;
	end
	
	if not self.nNianShouState then self.nNianShouState = 0 end;
	self.nNianShouState = self.nNianShouState + 1;
	local state = self.nNianShouState;
	local nWait = tbNianShouWaitTime[state];
	
	if(state == 1)then
		self.bResfreshNpc = 0;
		self:DelRefreshNpc()
		for _, pPlayer in pairs(self:GetPlayerList()) do
			Dialog:SendBlackBoardMsg(pPlayer, "Niên Thú: Ai dám quấy rối giấc ngủ của ta!");
		end
		local pNpc = KNpc.Add2(self.NPC_ID_NIAN_SHOU, 100, -1, self.nMapId, self.NPC_POS_NIAN_SHOU[1], self.NPC_POS_NIAN_SHOU[2]);
		if pNpc then
			self.nNianShouId = pNpc.dwId;
		end
	elseif (state == 2) then
		for _, pPlayer in pairs(self:GetPlayerList()) do
			Dialog:SendBlackBoardMsg(pPlayer, "Niên Thú: Trốn à? Ra hết đây cho ta...");
			pPlayer.NewWorld(self.nMapId, self.NPC_POS_NIAN_SHOU[1], self.NPC_POS_NIAN_SHOU[2]);
		end
	elseif (state == 3) then
		local pNpc = KNpc.GetById(self.nNianShouId);
		if (pNpc) then
			pNpc.CastSkill(self.SKILL_ID_NIAN_SHOU, 1, self.NPC_POS_NIAN_SHOU[1], self.NPC_POS_NIAN_SHOU[2]);
		end
	elseif (state == 4) then
		local pNpc = KNpc.GetById(self.nNianShouId);
		if pNpc then
			pNpc.Delete();
		end
		for _, pPlayer in pairs(self:GetPlayerList()) do
			Dialog:SendBlackBoardMsg(pPlayer, "Niên Thú: Không có gì thú vị, ta đi ngủ tiếp đây!");
		end
	end
	
	if nWait == 0 then
		self.tbNianShouTimer = nil;
		self.nNianShouState = nil;
	end
	
	return nWait * Env.GAME_FPS;
end

-- ?pl DoScript("\\script\\mission\\esport\\esport_mission.lua")
