-- 
-- 闯关基础房间逻辑
--

-- 应用了家族关卡的基础锁逻辑
Require("\\script\\mission\\baselock.lua")
Require("\\script\\mission\\xoyogame\\xoyogame_def.lua");
local tbEventLock = Lib:NewClass(Lock.tbBaseLock);

XoyoGame.BaseRoom = {}
local BaseRoom = XoyoGame.BaseRoom;

BaseRoom.EVENT_PROC  =
{
	[XoyoGame.ADD_NPC]		= "AddNpc",
	[XoyoGame.DEL_NPC]		= "DelNpc",
	[XoyoGame.CHANGE_TRAP]	= "ChangeTrap",
	[XoyoGame.DO_SCRIPT]	= "ExcuteScript",
	[XoyoGame.CHANGE_FIGHT]	= "ChangeFight",
	[XoyoGame.TARGET_INFO]	= "SetTagetInfo",
	[XoyoGame.TIME_INFO]	= "SetTimeInfo",
	[XoyoGame.CLOSE_INFO]	= "CloseInfo",
	[XoyoGame.MOVIE_DIALOG] = "MovieDialog",
	[XoyoGame.BLACK_MSG]	= "BlackMsg",
	[XoyoGame.CHANGE_NPC_AI]= "ChangeNpcAi",
	[XoyoGame.ADD_GOUHUO]	= "AddGouHuo",
	[XoyoGame.SEND_CHAT]	= "SendNpcChat",
	[XoyoGame.ADD_TITLE]	= "AddTeamTitle",
	[XoyoGame.TRANSFORM_CHILD] = "TransformChild",
	[XoyoGame.TRANSFORM_CHILD_2] = "TransformChild2",
	[XoyoGame.SHOW_NAME_AND_LIFE] = "ShowNameAndLife",
	[XoyoGame.NPC_CAN_TALK] = "NpcCanTalk",
	[XoyoGame.CHANGE_CAMP] = "ChangeCamp",
	[XoyoGame.SET_SKILL] = "SetSkill",
	[XoyoGame.DISABLE_SWITCH_SKILL] = "DisableSwitchSkill",
	[XoyoGame.FINISH_ACHIEVE]	= "FinishAchieve",
	[XoyoGame.DEL_MAP_NPC]	= "ClearMapNpc",
	[XoyoGame.NPC_CAST_SKILL] = "NpcCastSkill",
	[XoyoGame.NPC_REMOVE_SKILL] = "NpcRemoveSkill",
	[XoyoGame.NPC_BLOOD_PERCENT] = "RegisterNpcBloodPercent",
	[XoyoGame.PLAYER_SET_FORBID_SKILL] = "SetForbidSkill",
	[XoyoGame.PLAYER_ADD_EFFECT] ="AddPlayerGroupEffect",
	[XoyoGame.PLAYER_REMOVE_EFFECT] = "RemovePlayerGroupEffect",
	[XoyoGame.NPC_CAST_SKILL_TO_PLAYER] = "NpcCastSkillToPlayer",
	[XoyoGame.NPC_SET_LIFE] = "SetNpcLife",
	[XoyoGame.ADD_NPC_SKILL] ="AddNpcSkill",
	[XoyoGame.NEW_WORLD_PLAYER] = "NewWorldGroup",
	[XoyoGame.NEW_MSG_PLAYER] = "NewMsgPlayerGroup",
	[XoyoGame.ADD_PLAYER_TITLE] = "AddPlayerTitle",
};

BaseRoom.ZhenYuanExpAward = 
{
	[1]  = 2,
	[2]  = 2, 
	[3]  = 4,
	[4]  = 5,
	[5]  = 7,
	[6]  = 9,
	[7]  = 12,
	[8]  = 15,
}

BaseRoom.tbLongWenYinBiAward =
{
	[5]  = {18, 1, 1672, 1, 9},
	[6]  = {18, 1, 1672, 1, 8},
	[7]  = {18, 1, 1672, 1, 7},
	[8]  = {18, 1, 1672, 1, 6},
}

function tbEventLock:InitEventLock(tbRoom, nTime, nMultiNum, tbStartEvent, tbUnLockEvent)
	self:InitLock(nTime, nMultiNum);
	self.tbRoom 		= tbRoom;
	self.tbUnLockEvent 	= tbUnLockEvent;
	self.tbStartEvent 	= tbStartEvent;
end

function tbEventLock:OnUnLock()
	if self.tbRoom and self.tbUnLockEvent then
		for i = 1, #self.tbUnLockEvent do
			self.tbRoom:OnEvent(unpack(self.tbUnLockEvent[i]));
		end
	end
	local tbRoom = self.tbRoom;
	if tbRoom and tbRoom.tbTeam[1].bIsWiner == 1 then
		tbRoom:RoomLevelUp();
	end
end

function tbEventLock:OnStartLock()
	if self.tbRoom and self.tbStartEvent then
		for i = 1, #self.tbStartEvent do
			self.tbRoom:OnEvent(unpack(self.tbStartEvent[i]));
		end
	end
end

function BaseRoom:GetMonsterLevel(nLevel)
	if nLevel < 50 then
		return nLevel;
	end
	if self.nDifficuty == 1 or self.nDifficuty == 9 then -- 9是简单难度
		return nLevel;
	elseif self.nDifficuty == 3 then
		return tonumber(XoyoGame.tbNpcLevel[nLevel].nAdd1);
	elseif self.nDifficuty == 5 then
		return tonumber(XoyoGame.tbNpcLevel[nLevel].nAdd2);
	elseif self.nDifficuty == 7 then
		return tonumber(XoyoGame.tbNpcLevel[nLevel].nAdd3);
	end
end

function BaseRoom:ChangeNpcByDifficuty()
	if self.nDifficuty == 5 then
		return 1;
	else
		return 0;
	end
end

function BaseRoom:RoomLevelUp()
	if self.nTimerId then
		local fnExcute = function (pPlayer)
			Dialog:SetBattleTimer(pPlayer, "<color=green>Thời gian còn lại: %s<color>", XoyoGame.DELAY_ENDTIME * Env.GAME_FPS);
		end
		local tbGame = self.tbGame;
		self:GroupPlayerExcute(fnExcute, -1);
		self:GiveStone();
		Timer:Close(self.nTimerId);
		self.nTimerId = nil;
		if tbGame then
			Timer:Register(XoyoGame.DELAY_ENDTIME * Env.GAME_FPS, tbGame.EndRoomTime, tbGame, self.nRoomId);
		else
			print("[Error]not XoyoMission"..self.nRoomId..","..self.nMapId);
		end
	end
end



--过关后给宝石
function BaseRoom:GiveStone()
	if TimeFrame:GetState("OpenLevel150") ~= 1 then
		return 0;
	end
	local nProb = XoyoGame.tbGiveStoneProb[self.tbSetting.nRoomLevel];
	if not nProb then
		return 0;
	end
	local fnExcute = function (pPlayer)
		local nRand = MathRandom(100);
		if nRand <= nProb then
			local pItem = pPlayer.AddItem(18,1,1316,1);
			if pItem then
				local szGDPL = string.format("%d_%d_%d_%d",18,1,1316,1);
				StatLog:WriteStatLog("stat_info","baoshixiangqian","xiaoyaogu",pPlayer.nId,szGDPL,1);
			else
				Dbg:WriteLog("baoshixiangqian", "XoyoGame Generate Stone Failed", pPlayer.szName);
			end
		end
	end
	self:GroupPlayerExcute(fnExcute, -1);
end


function BaseRoom:ChangeCamp(nGroup, nCamp)
	self.USE_CHANGE_CAMP = 1;
	local f = function(pPlayer, nGroupId)
		self.tbGroupOriginalCamp[nGroupId] = pPlayer.GetCurCamp();
		pPlayer.SetCurCamp(nCamp);
	end
	self:GroupPlayerExcute(f, nGroup);
end

function BaseRoom: TestNpc()
	local nMapId, nX, nY = me.GetWorldPos();
	local pMeNpc = me.GetNpc();
	--for i = 1, 3 do
		local pProtectNpc = KNpc.Add2(2183, 80, -1, nMapId, nX, nY, 0, 0, 1);
		pProtectNpc.SetNpcAI(9, 0, 1, 1, 25, 25, 25, 1, pMeNpc.nIndex, pMeNpc.dwId, 0);
	--end
end

function BaseRoom:InitRoom(tbGame, tbRoomSetting, nMapId, nRoomId, tbAward)
	self.tbGame = tbGame;
	self.tbSetting = tbRoomSetting;
	self.nMapId = nMapId;
	self.nRoomId = nRoomId;
	self.tbLock = {};
	self.tbNpcGroup = {}; -- [szGroupName]-->{dwId1, dwId2, ...} 
	
	-- tbTeam[1] 对应 tbPlayerGroup[1], tbTeam[2] 对应 tbPlayerGroup[2], 如此类推
	self.tbTeam = {};    -- {{nTeamId1, nPlayerCount, ...}, {nTeamId2, nPlayerCount}, ...} 这是一个数组
	self.tbPlayerGroup = {}; -- {{nPlayerId, nPlayerId...}, {nPlayerId, nPlayerId, ...}, ...} 玩家分组，按1组2组3组这样索引, 不直接用队伍机制
	self.tbGroupOriginalCamp = {}; -- 分组原来的阵型
	
	self.tbPlayer = {}; -- [nPlayerId] -->{nTeam, ...} nTeam是self.tbTeam的索引
	self.tbAddNpcTimer = {};
	self.tbTeamId2Group = {};
	self.tbAward = tbAward;
	self.fnExc = nil;
	self.nWinRoomCount = 0;
	self.nRoomCount = 0;
	
	if not tbRoomSetting.LOCK then
		return ;
	end
	for i, tbLockSetting in pairs(tbRoomSetting.LOCK) do
		self.tbLock[i] = Lib:NewClass(tbEventLock);
		self.tbLock[i].nLockId = i;
		self.tbLock[i]:InitEventLock(self, tbLockSetting.nTime * Env.GAME_FPS, tbLockSetting.nNum, tbLockSetting.tbStartEvent, tbLockSetting.tbUnLockEvent);
	end
	for i, tbLockSetting in ipairs(tbRoomSetting.LOCK) do -- 保证解锁顺序
		for _, verPreLock in pairs(tbLockSetting.tbPrelock) do
			if type(verPreLock) == "number" then
				self.tbLock[i]:AddPreLock(self.tbLock[verPreLock]);
			elseif type(verPreLock) == "table" then
				local tbPreLock = {}
				for j = 1, #verPreLock do
					if self.tbLock[verPreLock[j]] then
						table.insert(tbPreLock, self.tbLock[verPreLock[j]]);
					end
				end
				self.tbLock[i]:AddPreLock(tbPreLock);
			else
				return 0;
			end
		end
	end
	
	if self.OnInitRoom then
		self:OnInitRoom();
	end
end

-- 添加NPC
-- varIndex: nTemplateId or {id1,id2,id3...}, 可以是一个或者一组模板id
-- nNum: 刷几个
-- nLock
-- szGroup: 新刷出来的npc所属的组的名字
-- szPointName: 使用哪一组点刷怪
-- nTimes, nFrequency, szTimerName: 循环刷怪用，参数为:次数，隔多久刷一次，timer名字
function BaseRoom:AddNpc(varIndex, nNum, nLock, szGroup, szPointName, nTimes, nFrequency, szTimerName)
	if (nTimes or nFrequency or szTimerName) and not (nTimes > 1 and nFrequency > 0 and szTimerName) then
		assert(false);
	end
	
	if type(varIndex) == "number" then
		varIndex = {varIndex};
	end
	for _, id in ipairs(varIndex) do
		local tbNpcInfo = self.tbSetting.NPC[id];
		assert(tbNpcInfo);
	end

	if nFrequency and not self.tbAddNpcTimer[szTimerName] then
		self.tbAddNpcTimer[szTimerName] = {};
		self.tbAddNpcTimer[szTimerName].tbNpcId = {};
	end

	self:__AddNpc(varIndex, nNum, nLock, szGroup, szPointName, nTimes, nFrequency, szTimerName);
end

-- 计算玩家等级平均值
function BaseRoom:GetAverageLevel()
	local nLevel;
	-- 计算房间内玩家平均等级
	assert(self.tbTeam)
	local nTotalLevel = 0;
	local nTotalPlayer = 0;
	for _, tbTeamInfo in pairs(self.tbTeam) do
		local tbTeamer, nCount = KTeam.GetTeamMemberList(tbTeamInfo.nTeamId);
		for i=1, nCount do
			local pPlayer = KPlayer.GetPlayerObjById(tbTeamer[i]);
			if pPlayer then
				nTotalLevel = nTotalLevel + pPlayer.nLevel;
				nTotalPlayer = nTotalPlayer + 1
			end
		end
	end
	if (nTotalPlayer ~= 0) then
		nLevel = math.ceil(nTotalLevel / nTotalPlayer);
	else
		nLevel = 50;
	end
	return nLevel;
end

-- 把npc刷到不同位置上
-- nNum: 数量
-- tbIndex: npc索引表
function BaseRoom:__AllocNpc(nNum, tbIndex, nLock, szGroup, nLevel, tbPoint)
	local pNpc;
	local tbNpcId = {};
	local point_ge_num;
	if #tbPoint >= nNum then
		point_ge_num = 1;
	end
	local nIndex;
	if #tbIndex == 1 then
		nIndex = tbIndex[1];
	end
	for i = 1, nNum do
		local nRand;
		local x,y;
		local tbNpcInfo;
		if nIndex then
			tbNpcInfo = self.tbSetting.NPC[nIndex];
		else
			tbNpcInfo = self.tbSetting.NPC[tbIndex[MathRandom(#tbIndex)]];
		end
		if point_ge_num then -- 点多怪少，要保证一个点只刷一个怪
			nRand = MathRandom(#tbPoint - i + 1) - 1;
			if tbPoint[i + nRand] then
				tbPoint[i], tbPoint[i + nRand] = tbPoint[i + nRand], tbPoint[i];
			end
			x, y = tbPoint[i][1], tbPoint[i][2];
		else
			nRand = MathRandom(#tbPoint);
			x, y = tbPoint[nRand][1], tbPoint[nRand][2];
		end
		if tbNpcInfo.nTemplate2 and self:ChangeNpcByDifficuty() == 1 then
			pNpc = KNpc.Add2(tbNpcInfo.nTemplate2, nLevel, tbNpcInfo.nSeries, self.nMapId, x,y,0,0,0,1)
		else
			pNpc = KNpc.Add2(tbNpcInfo.nTemplate, nLevel, tbNpcInfo.nSeries, self.nMapId, x,y,0,0,0,1)
		end
		if pNpc then
			self:AddNpcInLock(pNpc, nLock);
			self:AddNpcInGroup(pNpc, szGroup);
			table.insert(tbNpcId, pNpc.dwId);
			local tbTmp = pNpc.GetTempTable("XoyoGame")
			tbTmp.tbRoom = self;
		else
			print("Add Npc Failed", tbNpcInfo.nTemplate, nLevel, tbNpcInfo.nSeries, self.nMapId, x,y,0,0,0,1)
		end
	end
	return tbNpcId;
end

function BaseRoom:__AddNpc(tbIndex, nNum, nLock, szGroup, szPointName, nTimes, nFrequency, szTimerName)
	if not self.tbSetting or not self.tbSetting.NPC then
		return 0;
	end
	local tbPoint = XoyoGame.tbNpcPoint[szPointName];
	if not tbPoint then
		return 0;
	end
	
	local nLevel = 10;	-- 默认值
	local tbNpcInfo = self.tbSetting.NPC[tbIndex[1]];
	if not tbNpcInfo.nLevel or tbNpcInfo.nLevel <= 0 then
		nLevel = self:GetAverageLevel();
		nLevel = self:GetMonsterLevel(nLevel);
	else
		nLevel = tbNpcInfo.nLevel;
	end
	local tbNpcId = self:__AllocNpc(nNum, tbIndex, nLock, szGroup, nLevel, tbPoint);
	
	if nFrequency then
		for _, id in ipairs(self.tbAddNpcTimer[szTimerName].tbNpcId) do -- 删除上一轮的npc
			local pNpc = KNpc.GetById(id);
			if pNpc then
				pNpc.Delete();
			end
		end
		if nTimes == 1 then
			self.tbAddNpcTimer[szTimerName].nTimerId = nil;
			self.tbAddNpcTimer[szTimerName].tbNpcId = tbNpcId;
		else
			self.tbAddNpcTimer[szTimerName].nTimerId = Timer:Register(nFrequency * Env.GAME_FPS, self.__AddNpc, self, tbIndex, nNum, nLock, szGroup, szPointName, nTimes - 1, nFrequency, szTimerName);
			self.tbAddNpcTimer[szTimerName].tbNpcId = tbNpcId;
		end
	end
	
	return 0;
end

-- 把NPC加到锁里
function BaseRoom:AddNpcInLock(pNpc, nLock)
	if not nLock or nLock <= 0 then
		return 0;
	end
	local tbTmp = pNpc.GetTempTable("XoyoGame")
	tbTmp.nLock = nLock
end

-- 把NPC加到组里
function BaseRoom:AddNpcInGroup(pNpc, szGroup)
	if not self.tbNpcGroup[szGroup] then
		self.tbNpcGroup[szGroup] = {};
	end
	if pNpc then
		table.insert(self.tbNpcGroup[szGroup], pNpc.dwId);
	end
end

-- 删除特定组的NPC
function BaseRoom:DelNpc(szGroup)
	if not self.tbNpcGroup[szGroup] then
		return 0;
	end
	for _, nId in pairs(self.tbNpcGroup[szGroup]) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			pNpc.Delete();
		end
	end
	self.tbNpcGroup[szGroup] = nil;
end

-- 改变Trap点传送位置
function BaseRoom:ChangeTrap(szClassName, tbPoint)
	if self.tbGame.tbTrap then
		self.tbGame.tbTrap[szClassName] = tbPoint;
	end
end

-- 成就
function BaseRoom:FinishAchieve(nPlayerGroup, nAchieveId)
	local fnExcute = function (pPlayer)
		Achievement:FinishAchievement(pPlayer, nAchieveId);
	end
	self:GroupPlayerExcute(fnExcute, nPlayerGroup);
end

-- 设置玩家某个技能可用状态，by Egg
function BaseRoom:SetForbidSkill(nPlayerGroup,nSkillId,bUse)
	local fnExcute = function (pPlayer)
		pPlayer.SetAForbitSkill(nSkillId,bUse);
	end
	self:GroupPlayerExcute(fnExcute, nPlayerGroup);
end

--房间内玩家加一个状态，by Egg
function BaseRoom:AddPlayerGroupEffect(nPlayerGroup,nSkillId,nLevel,bBroad)
	local fnExcute = function (pPlayer)
		local _,x,y = pPlayer.GetWorldPos();
		pPlayer.CastSkill(nSkillId,nLevel,x * 32,y * 32,bBroad or 1);
	end
	self:GroupPlayerExcute(fnExcute, nPlayerGroup);
end

--移除房间内玩家身上的一个状态,by Egg
function BaseRoom:RemovePlayerGroupEffect(nPlayerGroup,nSkillId)
	local fnExcute = function (pPlayer)
		pPlayer.RemoveSkillState(nSkillId);
	end
	self:GroupPlayerExcute(fnExcute, nPlayerGroup);
end
-- 成就2
function BaseRoom:FinishAchieve2(tbTeam, nAchieveId)
	local fnExcute = function (pPlayer)
		Achievement:FinishAchievement(pPlayer, nAchieveId);
	end
	self:TeamPlayerExcute(fnExcute, tbTeam);
end

--只针对6，7，8等级关卡的地图,by Egg
function BaseRoom:ClearMapNpc()
	if not self.nMapId then
		return;
	end
	ClearMapNpc(self.nMapId);
end

--npc移除技能状态,by Egg
function BaseRoom:NpcRemoveSkill(szGroup,nSkillId)
	if not szGroup or not self.tbNpcGroup[szGroup] or not nSkillId then
		return 0;
	end
	for _, nId in pairs(self.tbNpcGroup[szGroup]) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			pNpc.RemoveSkillState(nSkillId);
		end
	end
end

--npc释放技能,by Egg
function BaseRoom:NpcCastSkill(szGroup,nSkillId,nLevel,nX,nY,bBroadcast)
	if not self.tbNpcGroup[szGroup] then
		return 0;
	end
	for _, nId in pairs(self.tbNpcGroup[szGroup]) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			local _,x,y = pNpc.GetWorldPos();
			pNpc.CastSkill(nSkillId or 0,nLevel or 0,nX or (x * 32),nY or (y * 32),bBroadcast or 1);
		end
	end
end

--播报消息
function BaseRoom:NewMsgPlayerGroup(szMsg,nType)
	if not szMsg or szMsg == "" then
		return 0;
	end
	if not nType then
		return 0;
	end
	if nType == XoyoGame.TOFRIEND then
		local fnExcute = function (pPlayer)
			pPlayer.SendMsgToFriend(szMsg);
		end
		self:GroupPlayerExcute(fnExcute, -1);
		return 1;
	end
	if nType == XoyoGame.TOKINORTONG then
		local fnExcute = function (pPlayer)
			Player:SendMsgToKinOrTong(pPlayer,szMsg,1);
		end	
		self:GroupPlayerExcute(fnExcute, -1);
		return 1;
	end
	if not self.tbTeam[1] then
		return 0;
	end
	local tbMember, nCount = KTeam.GetTeamMemberList(self.tbTeam[1].nTeamId);
	local szName = "";
	local szGate = "";
	for i = 1, nCount do
		local pPlayer = KPlayer.GetPlayerObjById(tbMember[i]);
		if pPlayer then
			if pPlayer.IsLeader() then
				szName = pPlayer.szName;
				break;
			end
		end
	end
	if nType == XoyoGame.TOALLGAMESERVER then
		szMsg = "<color=green>" .. szName .. "<color>Hướng dẫn nhóm" .. szMsg;
		KDialog.NewsMsg(1, Env.NEWSMSG_NORMAL, szMsg);
		return 1;
	end
end

--加称号
function BaseRoom:AddPlayerTitle(szTitle,nLastTime,szColor)
	if not szTitle or not nLastTime then
		return 0;
	end
	local fnExcute = function (pPlayer)
		if pPlayer.FindSpeTitle(szTitle) == 1 then
			pPlayer.AddSpeTitle(szTitle,GetTime() + nLastTime * 60,szColor or "gold") ;
		end
	end
	self:GroupPlayerExcute(fnExcute, -1);
	return 1;
end



--npc释放技能给玩家,nRange为nil或者-1则向房间内所有玩家释放，否则向nRange范围内的玩家释放
--nRandomCount,如果不存在，则是向全体释放，如果为0，不进行任何操作，大于1，则随机选择nRandomCount个玩家进行释放
function BaseRoom:NpcCastSkillToPlayer(szGroup,nSkillId,nLevel,bBroadcast,nRange,nRandomCount)
	if not self.tbNpcGroup[szGroup] then
		return 0;
	end
	for _, nId in pairs(self.tbNpcGroup[szGroup]) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			if not nRange or nRange == -1 then
				local tbGroup = self.tbPlayerGroup;
				local tbPlayerTemp = {};
				for nGroupId, tbCurGroup in pairs(tbGroup) do
					for _, nPlayerId in pairs(tbCurGroup) do
						if self.tbPlayer[nPlayerId] then 
							local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
							table.insert(tbPlayerTemp,pPlayer);
						end
					end
				end
				if not nRandomCount or nRandomCount > #tbPlayerTemp then
					for i = 1,#tbPlayerTemp do
						local _,x,y = tbPlayerTemp[i].GetWorldPos();
						pNpc.CastSkill(nSkillId or 0,nLevel or 0,x * 32,y * 32,bBroadcast or 1);
					end
				elseif nRandomCount <= #tbPlayerTemp then
					for i = 1,nRandomCount do
						local nPos = MathRandom(#tbPlayerTemp);
						local _,x,y = tbPlayerTemp[nPos].GetWorldPos();
						pNpc.CastSkill(nSkillId or 0,nLevel or 0,x * 32,y * 32,bBroadcast or 1);
						table.remove(tbPlayerTemp,nPos);
					end
				end
			else
				local tbPlayer,nCount = KNpc.GetAroundPlayerList(pNpc.dwId,nRange or 90);
				if nCount ~= 0 then
					if not nRandomCount then
						for i = 1,nCount do
							local _,nX,nY = tbPlayer[i].GetWorldPos();
							pNpc.CastSkill(nSkillId or 0,nLevel or 0,nX * 32,nY * 32,bBroadcast or 1);
						end
					elseif nRandomCount >= 1 then
						for i = 1,nRandomCount do
							local nPos = MathRandom(nCount);
							local _,nX,nY = tbPlayer[nPos].GetWorldPos(); 
							pNpc.CastSkill(nSkillId or 0,nLevel or 0,nX * 32,nY* 32,bBroadcast or 1);
							table.remove(tbPlayer,nPos);
						end
					end 
				end
			end
		end
	end
end
--减少npc的血量,by Egg
function BaseRoom:SetNpcLife(szGroup,nPercent)
	if not self.tbNpcGroup[szGroup] then
		return 0;
	end
	if nPercent <= 0 or nPercent > 100 then	--血量百分比只能在(0,100]之间
		return 0;
	end
	for _, nId in pairs(self.tbNpcGroup[szGroup]) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			local nMaxLife = pNpc.nMaxLife;
			local nSubLife = (1 - nPercent / 100) * nMaxLife;
			pNpc.ReduceLife(nSubLife); 
		end
	end
end
--给npc添加技能，用于ai
function BaseRoom:AddNpcSkill(szGroup,nSkillId1,nLevel1,nSkillId2,nLevel2,nSkillId3,nLevel3)
	if not self.tbNpcGroup[szGroup] then
		return 0;
	end
	for _, nId in pairs(self.tbNpcGroup[szGroup]) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			if nSkillId1 and nSkillId1 > 0 then
				pNpc.AddFightSkill(nSkillId1,nLevel1,1);
			end
			if nSkillId2 and nSkillId2 > 0 then
				pNpc.AddFightSkill(nSkillId2,nLevel2,2)
			end
			if nSkillId3 and nSkillId3 > 0 then
				pNpc.AddFightSkill(nSkillId3,nLevel3,3)
			end
		end
	end
end
--注册npc血量回调,by Egg
function BaseRoom:RegisterNpcBloodPercent(szGroup,...)
	if not self.tbNpcGroup[szGroup] then
		return 0;
	end
	local tbPercentInfo = {};
	for i = 1,#arg do
		tbPercentInfo[i] = arg[i];
	end
	if not tbPercentInfo then
		return 0;
	end
	for _, nId in pairs(self.tbNpcGroup[szGroup]) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			pNpc.GetTempTable("XoyoGame").tbPercentInfo = {};
			for i = 1,#tbPercentInfo do
				pNpc.AddLifePObserver(tbPercentInfo[i][1]);
			end
			pNpc.GetTempTable("XoyoGame").szGroup = szGroup;
			pNpc.GetTempTable("XoyoGame").tbPercentInfo = tbPercentInfo;
			pNpc.GetTempTable("XoyoGame").tbRoom = self;
		end
	end
end
--血量回调触发事件,by Egg
function BaseRoom:OnNpcBloodPercent(szGroup,nPercent,nEventType,...)
	if not szGroup or not self.tbNpcGroup[szGroup] then
		return 0;
	end
	if not nPercent then
		return 0;
	end
	for _, nId in pairs(self.tbNpcGroup[szGroup]) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			self:OnEvent(nEventType,unpack(arg));
		end
	end
end
-- 执行脚本 -- TODO
function BaseRoom:ExcuteScript(szCmd)
	XoyoGame.tbExcuteTable = self;
	local fnExc = loadstring("local self = XoyoGame.tbExcuteTable;"..szCmd);
	if fnExc then
		xpcall(fnExc, Lib.ShowStack);
	end
	XoyoGame.tbExcuteTable = nil;
end

-- 遍历房间所有玩家
function BaseRoom:GroupPlayerExcute(fnExcute, nPlayerGroup)
	local tbGroup;
	if nPlayerGroup and nPlayerGroup > 0 then
		if (not self.tbPlayerGroup) or (not self.tbPlayerGroup[nPlayerGroup]) then
			return 0;
		end
		tbGroup = {[nPlayerGroup] = self.tbPlayerGroup[nPlayerGroup]};
	else
		tbGroup = self.tbPlayerGroup;
	end
	for nGroupId, tbCurGroup in pairs(tbGroup) do
		for _, nPlayerId in pairs(tbCurGroup) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer and self.tbPlayer[nPlayerId] then
				fnExcute(pPlayer, nGroupId);
			end
		end
	end
end

-- 遍历队伍所有完家执行
function BaseRoom:TeamPlayerExcute(fnExcute, tbTeam)
	if not tbTeam then
		return;
	end
	for _, nTeamId in ipairs(tbTeam) do
		local tbMember, nCount = KTeam.GetTeamMemberList(nTeamId);
		for i = 1, nCount do
			local pPlayer = KPlayer.GetPlayerObjById(tbMember[i]);
			if pPlayer then
				fnExcute(pPlayer);
			end
		end
	end
end

-- 队伍横幅
function BaseRoom:TeamBlackMsg(tbTeam, szMsg)
	local fnExcute = function (pPlayer)
		Dialog:SendBlackBoardMsg(pPlayer, szMsg);
	end
	self:TeamPlayerExcute(fnExcute, tbTeam);
end

-- 队伍奖励
function BaseRoom:TeamAward(tbTeam, nMinuteExp, nRepute, nPrestige, nOffer, bWinner, nTollGatePoint)
	if not nMinuteExp or nMinuteExp <= 0 then
		return;
	end
	local nRoomId = self.nRoomId;
	local fnExcute = function (pPlayer)
		local nBaseExp = pPlayer.GetBaseAwardExp()
		pPlayer.AddExp(nMinuteExp * nBaseExp);
	
		if bWinner == 1 then
			pPlayer.Earn(2000 * self.tbSetting.nRoomLevel, 0);
			pPlayer.AddBindMoney(20000 * self.tbSetting.nRoomLevel);
			
			local tbInfo = Kinsalary.EVENT_TYPE[Kinsalary.EVENT_XIAOYAO];
			Kinsalary:AddSalary_GS(pPlayer, Kinsalary.EVENT_XIAOYAO, tbInfo.nRate);
			
			local tbTeamPlayer, nCount = KTeam.GetTeamMemberList(pPlayer.nTeamId);
			if tbTeamPlayer and tbTeamPlayer[1] and tbTeamPlayer[1] == pPlayer.nId and 
				XoyoGame.HONOR[self.tbSetting.nRoomLevel] and 
				XoyoGame.HONOR[self.tbSetting.nRoomLevel][nCount] then 
				PlayerHonor:AddPlayerHonorById_GS(tbTeamPlayer[1], PlayerHonor.HONOR_CLASS_LINGXIU, 0, 
					XoyoGame.HONOR[self.tbSetting.nRoomLevel][nCount]);
			end
			XoyoGame.XoyoChallenge:PassRoomForCard(pPlayer, nRoomId);
			local nDifficuty = XoyoGame:GetDifficuty(pPlayer.nTeamId);
			local nWinRoomCount = self.nWinRoomCount or 0;
			local nRoomCount = self.nRoomCount or 0;
			local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("XoyoGame", pPlayer, self.tbSetting.nRoomLevel, nDifficuty, nWinRoomCount, nRoomCount);
			SpecialEvent.ExtendAward:DoExecute(tbFunExecute);	
			
			SpecialEvent.tbGoldBar:AddTask(pPlayer, 5);		--金牌联赛逍遥谷每层关卡
			-- 增加主真元经验
			local pZhenYuan = pPlayer.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_ZHENYUAN_MAIN);
			if self.ZhenYuanExpAward[self.tbSetting.nRoomLevel] then
				-- pZhenYuan可以为nil
				local nExpTime = self.ZhenYuanExpAward[self.tbSetting.nRoomLevel];
				Item.tbZhenYuan:AddExp(pZhenYuan, nExpTime, Item.tbZhenYuan.EXPWAY_XIAOYAO, pPlayer);
			end	
			if nTollGatePoint and nTollGatePoint > 0 then
				-- 增加通关积分
				pPlayer.SetTask(XoyoGame.TASK_GROUP, XoyoGame.TOLL_GATE_POINT, pPlayer.GetTask(XoyoGame.TASK_GROUP, XoyoGame.TOLL_GATE_POINT) + nTollGatePoint);
				local nKinId, nMemberId = pPlayer.GetKinMember();
				local cKin = KKin.GetKin(nKinId);
				if cKin then
					GCExcute({"XoyoGame:UpdateKinRankData", nKinId, nTollGatePoint});
				end 
			end
			
			-- 增加龙纹银币，前提是时间轴到了
			if TimeFrame:GetState("Keyimen") == 1 and self.tbLongWenYinBiAward[self.tbSetting.nRoomLevel] then
				local tbAward = self.tbLongWenYinBiAward[self.tbSetting.nRoomLevel];
				local nActualCount = pPlayer.AddStackItem(tbAward[1], tbAward[2], tbAward[3], tbAward[4], nil, tbAward[5]);
				if nActualCount ~= tbAward[5] then
					pPlayer.Msg("Hành trang không đủ, không thể nhận thưởng!");
				end
			end
		end
		
		if nRepute and nRepute > 0 then
			pPlayer.AddRepute(XoyoGame.REPUTE_CAMP, XoyoGame.REPUTE_CLASS, nRepute);
		end
		
		local bPrestige = 0;  --是否加上江湖威望
		if nPrestige and nPrestige > 0 then
			bPrestige = pPlayer.AddKinReputeEntry(nPrestige, "xoyogame");
		end
		
		-- 成就:逍遥谷通关
		if (self.tbSetting.nRoomLevel == XoyoGame.ROOM_MAX_LEVEL) then
			Achievement_ST:FinishAchievement(pPlayer.nId, Achievement_ST.XOYOGAME_PASS);
		end
		
		local nDifficuty = XoyoGame:GetDifficuty(pPlayer.nTeamId);
		local nWinRoomCount = self.nWinRoomCount or 0;
		local nRoomCount = self.nRoomCount or 0;
		--到第五关时，成功失败都会掉到
		if nRoomCount == XoyoGame.PLAY_ROOM_COUNT then
			local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("XoyoGameFinish", pPlayer, self.tbSetting.nRoomLevel, nDifficuty, nWinRoomCount);
			SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
		end
		-- 成就 -- NEW
		if bWinner == 1 then --需要胜利？
			XoyoGame.Achievement:PassGames(pPlayer, self.tbSetting.nRoomLevel);
			-- 记录逍遥谷次数，只要过了第三关就记录
			if self.tbSetting.nRoomLevel == 3 then
				Player:AddJoinRecord_DailyCount(pPlayer, Player.EVENT_JOIN_RECORD_XOYOGAME, 1);
			end
		end
		
		--奖励LOG
		if XoyoGame.LOG_ATTEND_OPEN == 1 then
			local nExp = nMinuteExp * nBaseExp;
			Dbg:WriteLog("xoyogame", "attend 奖励LOG 玩家:"..pPlayer.szName, "房间等级"..self.tbSetting.nRoomLevel,
				"经验:"..nExp, "贡献度:"..nOffer,"声望:"..nRepute, "江湖威望:"..nPrestige..","..bPrestige);
		end
				
	end
	self:TeamPlayerExcute(fnExcute, tbTeam);
	-- 添加亲密度
	self:AddFriendFavor(tbTeam);
end

function BaseRoom:AddFriendFavor(tbTeamId)
	if (not tbTeamId) then
		return ;
	end
	for _, nTeamId in ipairs(tbTeamId) do
		local tbMember, nCount = KTeam.GetTeamMemberList(nTeamId);
		if (nCount >= 2) then
			local pPlayer = KPlayer.GetPlayerObjById(tbMember[1]);
			if (pPlayer) then
				local tbTeamPlayer = pPlayer.GetTeamMemberList();
				self:AddFriendFavorInTeam(tbTeamPlayer);
			end	
		end
	end	
end

function BaseRoom:AddFriendFavorInTeam(tbTeamPlayer)
	if (not tbTeamPlayer) then
		return ;
	end
	for i = 1, #tbTeamPlayer do
		for j = i + 1, #tbTeamPlayer do
			if (tbTeamPlayer[i] and tbTeamPlayer[j] and 1 == tbTeamPlayer[i].IsFriendRelation(tbTeamPlayer[j].szName)) then
				Relation:AddFriendFavor(tbTeamPlayer[i].szName, tbTeamPlayer[j].szName, 16);
				tbTeamPlayer[i].Msg(string.format("Bạn và <color=yellow>%s<color>hảo hữu thân mật %d.", tbTeamPlayer[j].szName, 16));
				tbTeamPlayer[j].Msg(string.format("Bạn và <color=yellow>%s<color>hảo hữu thân mật%d.", tbTeamPlayer[i].szName, 16));
			end	
		end
	end		
end

-- 改变PK、战斗模式
function BaseRoom:ChangeFight(nPlayerGroup, nFightState, nPkModel, nCamp)
	local fnExcute = function (pPlayer)
		pPlayer.SetFightState(nFightState);
		pPlayer.nPkModel = nPkModel;
		if nCamp and nCamp > 0 and nCamp <=3 then
			pPlayer.SetCurCamp(nCamp);
		end
	end
	self:GroupPlayerExcute(fnExcute, nPlayerGroup);
end

-- 同步即时战报信息给所有玩家
function BaseRoom:SetTagetInfo(nPlayerGroup, szInfo)
	local fnExcute = function (pPlayer)
		Dialog:SendBattleMsg(pPlayer,  szInfo);
		Dialog:ShowBattleMsg(pPlayer,  1,  0); --开启界面
	end
	self:GroupPlayerExcute(fnExcute, nPlayerGroup);
	--成功LOG统计 比较差的实现
	if XoyoGame.LOG_ATTEND_OPEN == 1 and szInfo == "Nhiệm vụ hoàn thành" and self.nTimerId then

		--查找所在Group
		local tbGroup;
		if nPlayerGroup and nPlayerGroup > 0 then
			if (not self.tbPlayerGroup) or (not self.tbPlayerGroup[nPlayerGroup]) then
				return;
			end
			tbGroup = {[nPlayerGroup] = self.tbPlayerGroup[nPlayerGroup]};
		else
			tbGroup = self.tbPlayerGroup;
		end		
		local nLastFrameTime = tonumber(Timer:GetRestTime(self.nTimerId));			
		local nLevel =  XoyoGame.RoomSetting.tbRoom[self.nRoomId].nRoomLevel;
		local nPlayTime = XoyoGame.ROOM_TIME[nLevel]  - math.floor(nLastFrameTime/Env.GAME_FPS);
		
		for nGroupId, tbCurGroup in pairs(tbGroup) do
			for _, nPlayerId in pairs(tbCurGroup) do
				local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
				if pPlayer and self.tbPlayer[nPlayerId] then
					DataLog:WriteELog(pPlayer.szName, 1, 2, self.nRoomId, pPlayer.nTeamId, nPlayTime);
				end
			end
		end
	end	
	
end

-- 同步时间信息
-- varLock: nLock or {nLock1, nLock2, ...}
function BaseRoom:SetTimeInfo(nPlayerGroup, szTimeInfo, varLock)
	local tbLock;
	local tbLockTime = {};
	if type(varLock) == "number" then
		tbLock = {varLock};
	else
		tbLock = varLock;
	end
		
	if (not self.tbLock) then 
		assert(false)
	end
	
	for _, nLock in ipairs(tbLock) do
		if not self.tbLock[nLock] then
			assert(false)
		end
	end
	
	for _, nLock in ipairs(tbLock) do
		local nLastFrameTime = tonumber(Timer:GetRestTime(self.tbLock[nLock].nTimerId));
		if nLastFrameTime == -1 then -- timer还没开启
			nLastFrameTime = self.tbSetting.LOCK[nLock].nTime*Env.GAME_FPS;
		end
		table.insert(tbLockTime, nLastFrameTime);
	end
	
	local fnExcute = function (pPlayer)
		Dialog:SetBattleTimer(pPlayer,  szTimeInfo, unpack(tbLockTime));
	end
	self:GroupPlayerExcute(fnExcute, nPlayerGroup);
end

-- 关闭即时战报信息
function BaseRoom:CloseInfo(nPlayerGroup)
	local fnExcute = function (pPlayer)
		Dialog:ShowBattleMsg(pPlayer,  0,  0); --关闭界面
	end
	self:GroupPlayerExcute(fnExcute, nPlayerGroup);
end

-- 电影模式对话
function BaseRoom:MovieDialog(nPlayerGroup, szMovie)
	local fnExcute = function (pPlayer)
		Setting:SetGlobalObj(pPlayer);
		TaskAct:Talk(szMovie);
		Setting:RestoreGlobalObj();
	end
	self:GroupPlayerExcute(fnExcute, nPlayerGroup);
end

-- 黑条消息
function BaseRoom:BlackMsg(nPlayerGroup, szMsg)
	local fnExcute = function (pPlayer)
		Dialog:SendBlackBoardMsg(pPlayer, szMsg)
	end
	self:GroupPlayerExcute(fnExcute, nPlayerGroup);
end

-- 篝火
-- nMinute: ?
-- nBaseMultip: ?
-- 篝火npc的group
-- varPoint: {x,y} or 点的名字
function BaseRoom:AddGouHuo(nMinute, nBaseMultip, szGroup, varPoint)
	if not self.tbTeam[1] then
		return 0;
	end
	
	local pos;
	
	if type(varPoint) == "table" then
		pos = varPoint;
	else
		local szPointName = varPoint
		local tbPoint 	= XoyoGame.tbNpcPoint[szPointName];
		if not tbPoint then
			return 0;
		end
		local nRand = MathRandom(#tbPoint)
		pos = tbPoint[nRand];
	end
	
	local nTeamId	= self.tbTeam[1].nTeamId;
	local tbNpc		= Npc:GetClass("gouhuonpc");
	local pNpc		= KNpc.Add2(tbNpc.nNpcId, 1, -1, self.nMapId, pos[1], pos[2]);		-- 获得篝火Npc
	if pNpc then
		tbNpc:InitGouHuo(pNpc.dwId, 1,	nMinute * 60, 5, 40, nBaseMultip, 1)
		tbNpc:SetTeamId(pNpc.dwId, nTeamId);
		tbNpc:StartNpcTimer(pNpc.dwId)
		self:AddNpcInGroup(pNpc, szGroup);
		KTeam.Msg2Team(nTeamId, "Lửa trại đã được thắp sáng, các thành viên có thể tập trung chia sẽ điểm kinh nghiệm!");
	else
		print("XoyoGame", "AddGouHuo Failed");
	end
end

-- npc头顶冒字
function BaseRoom:SendNpcChat(szGroup, szChat)
	if not szGroup or not self.tbNpcGroup[szGroup] then
		print("error", "No Npc Group!");
		return 0;
	end
	for _, nNpcId in pairs(self.tbNpcGroup[szGroup]) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.SendChat(szChat);
			local tbNearPlayer = KNpc.GetAroundPlayerList(pNpc.dwId, 30);
			if tbNearPlayer then
				for _, pPlayer in ipairs(tbNearPlayer) do
					pPlayer.Msg(szChat, pNpc.szName);
				end
			end
		else
			print("NO NPC?")
		end
	end
end

-- 公告
function BaseRoom:SendPlayerMsg(nPlayerGroup, szMsg)
	local f = function(pPlayer)
		pPlayer.Msg(szMsg);
	end
	
	self:GroupPlayerExcute(f, nPlayerGroup);
end

function BaseRoom:AddTeamTitle(nPlayerGroup, nGenre, nDetail, nLevel, nParam)
	local fnExcute = function (pPlayer)
		pPlayer.AddTitle(nGenre, nDetail, nLevel, nParam);
	end
	self:GroupPlayerExcute(fnExcute, nPlayerGroup);
end

--集体传送,by Egg
function BaseRoom:NewWorldGroup(nPlayerGroup,nX,nY)
	local fnExcute = function(pPlayer)
		pPlayer.NewWorld(self.nMapId,nX,nY);
	end
	self:GroupPlayerExcute(fnExcute,nPlayerGroup);
end
-- 变身做小孩
function BaseRoom:TransformChild(__pPlayer) -- 只用于双队房
	self.USE_TRANSFORM_CHILD = 1;
	local fnExcute = function (pPlayer, nGroupId)
		local nSkillLevel; -- 1-4级依次变成3605-3608号npc
		-- 变身
		if (pPlayer.nSex == 0) then
			if (nGroupId == 1) then
				nSkillLevel = 5;
			else
				nSkillLevel = 7;
			end
		else
			if (nGroupId == 1) then
				nSkillLevel = 6;
			else
				nSkillLevel = 8;
			end
		end
		local mapId, x, y = pPlayer.GetWorldPos();
		pPlayer.CastSkill(1326, nSkillLevel, x, y);
		
		--pPlayer.LevelUpFightSkill(1, 1451);
		FightSkill:SaveRightSkillEx(pPlayer, 1451);
	end
	
	if __pPlayer then
		local nGroupId = self.tbTeamId2Group[__pPlayer.nTeamId];
		fnExcute(__pPlayer, nGroupId);
	else
		self:GroupPlayerExcute(fnExcute, 1);
		self:GroupPlayerExcute(fnExcute, 2);
	end
end

-- 变牧童
function BaseRoom:TransformChild2()
	self.USE_TRANSFORM_CHILD = 1;
	local fnExcute = function (pPlayer, nGroupId)
		local mapId, x, y = pPlayer.GetWorldPos();
		pPlayer.CastSkill(1326, 9, x, y);
	end
	self:GroupPlayerExcute(fnExcute, 1);
end

function BaseRoom:SetSkill(nGroupId, nSkillId, szLeftRight)
	local fnExcute = function(pPlayer, nGroupId)
		FightSkill:SaveRightSkillEx(pPlayer, nSkillId);
		FightSkill:SaveLeftSkillEx(pPlayer, nSkillId);
	end
	self:GroupPlayerExcute(fnExcute, nGroupId);
end

function BaseRoom:DisableSwitchSkill(var, nDisable)
	self.USE_DISABLE_SWITCH_SKILL = 1;
	local szVal;
	if nDisable == 1 then
		szVal = "1";
	else
		szVal = "nil";
	end
	
	local sz = string.format([[
		UiManager:CloseWindow(Ui.UI_SKILLTREE, "LEFT");
		UiManager:CloseWindow(Ui.UI_SKILLTREE, "RIGHT");
		Ui(Ui.UI_SKILLBAR)._disable_switch_skill = %s;
	]], szVal);
	local fnExcute = function(pPlayer)
		pPlayer.CallClientScript({"GM:DoCommand",sz});
	end
	
	if type(var) == "number" then
		self:GroupPlayerExcute(fnExcute, var);
	else
		fnExcute(var);
	end
end

function BaseRoom:ShowNameAndLife(nShow)
	assert(nShow == 0 or nShow == 1)
	local sz = string.format(
		[[
		UiManager:CloseWindow(Ui.UI_SYSTEM);
		me.nShowLife =%d;
		me.nShowName =%d;
		Ui(Ui.UI_SYSTEM)._no_name_or_life=%d;
		]], nShow, nShow, nShow);
		
	local fnExcute = function(pPlayer)
		pPlayer.CallClientScript({"GM:DoCommand",sz});
	end
	self:GroupPlayerExcute(fnExcute);
end

function BaseRoom:SetNpcMove(pNpc, szRoad, nLockId, nAttact, bRetort, bArriveDel,nCamp,nSkill1Rate,nSkill2Rate,nSkill3Rate)
	pNpc.SetCamp(nCamp or 0);
	if not XoyoGame.tbRoad or not XoyoGame.tbRoad[szRoad] then
		return 0;
	end
	pNpc.AI_ClearPath();
	for _,Pos in pairs(XoyoGame.tbRoad[szRoad]) do
		if (Pos[1] and Pos[2]) then
			pNpc.AI_AddMovePos(Pos[1]*32, Pos[2]*32);
		end
	end
	pNpc.SetNpcAI(9, nAttact or 0, bRetort or 1, -1, nSkill1Rate or 25, nSkill2Rate or 25, nSkill3Rate or 25, 0, 0, 0, 0);
	pNpc.SetActiveForever(1);
	pNpc.GetTempTable("Npc").tbOnArrive = {self.OnArrive, self, nLockId, bArriveDel};
end

function BaseRoom:SetNpcReMove(pNpc, szRoad, nAttact, bRetort, nTimes)
	if not XoyoGame.tbRoad or not XoyoGame.tbRoad[szRoad] then
		return 0;
	end
	pNpc.AI_ClearPath();
	for _,Pos in pairs(XoyoGame.tbRoad[szRoad]) do
		if (Pos[1] and Pos[2]) then
			pNpc.AI_AddMovePos(Pos[1]*32, Pos[2]*32);
		end
	end
	pNpc.SetNpcAI(9, nAttact or 0, bRetort or 1, -1, 25, 25, 25, 0, 0, 0, 0);
	pNpc.SetActiveForever(1);
	pNpc.GetTempTable("Npc").tbOnArrive = {self.OnReMoveArrive, self, szRoad, nAttact, bRetort, nTimes};
end

function BaseRoom:SetNpcAttack(pNpc, szNpc, nCamp, bRetort)
	pNpc.SetCurCamp(nCamp)
	if szNpc and self.tbNpcGroup[szNpc] then
		if #self.tbNpcGroup[szNpc] >= 1 then
			local nRandom = MathRandom(#self.tbNpcGroup[szNpc]);
			local pTagetNpc = KNpc.GetById(self.tbNpcGroup[szNpc][nRandom])
			if pTagetNpc then
				pNpc.SetNpcAI(9, 100, bRetort or 1, -1, 25, 25, 25, 1, 0, self.tbNpcGroup[szNpc][nRandom], 0);
			end
		end
	end
end

function BaseRoom:OnArrive(nLockId, bArriveDel)
	-- 要先删除NPC~
	if bArriveDel == 1 then
		him.Delete();
	end
	if not nLockId then
		return 0;
	end
	
	if not self.tbLock[nLockId] then
		return 0;
	end
	self.tbLock[nLockId]:UnLockMulti();
end

function BaseRoom:OnReMoveArrive(szRoad, nAttact, bRetort, nTimes)
	if not XoyoGame.tbRoad or not XoyoGame.tbRoad[szRoad] then
		return 0;
	end
	him.AI_ClearPath();
	for _,Pos in pairs(XoyoGame.tbRoad[szRoad]) do
		if (Pos[1] and Pos[2]) then
			him.AI_AddMovePos(Pos[1]*32, Pos[2]*32);
		end
	end
	him.SetNpcAI(9, nAttact or 0, bRetort or 1, -1, 25, 25, 25, 0, 0, 0, 0);
end

BaseRoom.AI_MODE_PROC = 
{
	[XoyoGame.AI_MOVE] 			= "SetNpcMove";
	[XoyoGame.AI_RECYLE_MOVE]	= "SetNpcReMove";
	[XoyoGame.AI_ATTACK]		= "SetNpcAttack";
}

function BaseRoom:OnEvent(nEventType, ...)
	if self.EVENT_PROC[nEventType] and self[self.EVENT_PROC[nEventType]] then
		self[self.EVENT_PROC[nEventType]](self, ...);
	else
		print("Undefind EventType ", nEventType, ...);
	end
end

function BaseRoom:ChangeNpcAi(szNpcGroup, nAiMode, ...)
	if not self.tbNpcGroup[szNpcGroup] then
		print("NpcGroup is not In", szNpcGroup);
		return 0
	end
	if self.AI_MODE_PROC[nAiMode] and self[self.AI_MODE_PROC[nAiMode]] then
		for i, nNpcId in pairs(self.tbNpcGroup[szNpcGroup]) do
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				self[self.AI_MODE_PROC[nAiMode]](self, pNpc, ...);
			end
		end
	else
		print("Undefin AiModeType ", nAiMode, ...);
	end
end


-- 加入房间 nTeamId1, nTeamId2, ....
function BaseRoom:JoinRoom(...)
	if self.tbSetting.fnPlayerGroup then
		self.tbSetting.fnPlayerGroup(self, unpack(arg));
	else 
		self:DefaultGroup(unpack(arg));
	end
	for i = 1, #arg do
		local tbMember, nNum = KTeam.GetTeamMemberList(arg[i])
		table.insert(self.tbTeam, { nTeamId = arg[i], nPlayerCount = 0 });
		self.tbGame.tbTeam[arg[i]].nRoomId = nRoomId;
		for j = 1, nNum do
			local pPlayer = KPlayer.GetPlayerObjById(tbMember[j]);
			-- TODO   
			if (pPlayer) and self.tbGame == XoyoGame:GetPlayerGame(pPlayer.nId)
				and (not self.tbPlayer[tbMember[j]])
			then
				self.tbPlayer[tbMember[j]] = {};
				self.tbPlayer[tbMember[j]].nTeam = #self.tbTeam;
				self.tbTeam[#self.tbTeam].nPlayerCount = self.tbTeam[#self.tbTeam].nPlayerCount + 1;
				-- 设定玩家在本房间内
				self.tbGame:SetPlayerInRoom(tbMember[j], self.nRoomId);
				Setting:SetGlobalObj(pPlayer);
				if self.tbSetting.fnDeath then
					self.tbPlayer[tbMember[j]].nOnDeathRegId = PlayerEvent:Register("OnDeath", self.tbSetting.fnDeath, self);
				else
					self.tbPlayer[tbMember[j]].nOnDeathRegId = PlayerEvent:Register("OnDeath", self.DefaultDeath, self);
				end
				Setting:RestoreGlobalObj();
				pPlayer.SetTask(XoyoGame.TASK_GROUP, XoyoGame.EXCHANGE_ROOM_LEVEL, 0);
			end
		end		
	end
end
-- 死亡重回房间
function BaseRoom:ReviveBackRoom(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer or self.tbPlayer[nPlayerId] or self.tbGame ~= XoyoGame:GetPlayerGame(pPlayer.nId) then
		return 0;
	end
	self.tbPlayer[nPlayerId] = {};
	self.tbPlayer[nPlayerId].nTeam = #self.tbTeam;
	self.tbTeam[#self.tbTeam].nPlayerCount = self.tbTeam[#self.tbTeam].nPlayerCount + 1;
	self.tbGame:SetPlayerInRoom(nPlayerId, self.nRoomId);
	Setting:SetGlobalObj(pPlayer);
	if self.tbSetting.fnDeath then
		self.tbPlayer[nPlayerId].nOnDeathRegId = PlayerEvent:Register("OnDeath", self.tbSetting.fnDeath, self);
	else
		self.tbPlayer[nPlayerId].nOnDeathRegId = PlayerEvent:Register("OnDeath", self.DefaultDeath, self);
	end
	Setting:RestoreGlobalObj();
	return 1;
end

-- 默认死亡函数
function BaseRoom:DefaultDeath(pKiller)
	-- 自动重生
	me.ReviveImmediately(0);
	-- 战斗状态
	me.SetFightState(0);
	-- PK状态
	me.nPkModel = Player.emKPK_STATE_PRACTISE;
	
	-- 剔除房间逻辑
	self:PlayerLeaveRoom(me.nId);
	
	-- 提示信息
	if self.GetDeathMsg then
		Dialog:SendBlackBoardMsg(me, self:GetDeathMsg(me));
	else
		Dialog:SendBlackBoardMsg(me, "请耐心在此等候，你将在下个关卡开启时与其他队友汇合！");
	end
	
	-- 提示时间最后做~万一定时器被以外关了也不至于逻辑错误
	if self.nTimerId then
		local nLastFrameTime = tonumber(Timer:GetRestTime(self.nTimerId));
		Dialog:SetBattleTimer(me, "<color=green>Thời gian còn lại: %s<color>", nLastFrameTime);
		Dialog:SendBattleMsg(me, "Hãy kiên nhẫn chờ đợi...");
	end
end

function BaseRoom:SendPlayer2RestRoom(pPlayer)
	-- 战斗状态
	pPlayer.SetFightState(0);
	-- PK状态
	pPlayer.nPkModel = Player.emKPK_STATE_PRACTISE;
	-- 剔除房间逻辑
	self:PlayerLeaveRoom(pPlayer.nId);
	pPlayer.NewWorld(unpack(self.tbGame.tbMisCfg.tbDeathRevPos[1]));
	
	-- 提示时间最后做~万一定时器被以外关了也不至于逻辑错误
	if self.nTimerId then
		local nLastFrameTime = tonumber(Timer:GetRestTime(self.nTimerId));
		Dialog:SetBattleTimer(pPlayer, "<color=green>Thời gian còn lại: %s<color>", nLastFrameTime);
		Dialog:SendBattleMsg(pPlayer, "Hãy kiên nhẫn chờ đợi...");
	end
end

-- 默认分组函数
function BaseRoom:DefaultGroup(...)
	for i = 1, #arg do
		local tbMemberList, nNum = KTeam.GetTeamMemberList(arg[i]);
		self.tbTeamId2Group[arg[i]] = i;
		if tbMemberList then
			for j = 1, nNum do
				local pPlayer = KPlayer.GetPlayerObjById(tbMemberList[j])
				if not self.tbPlayerGroup[i] then
					self.tbPlayerGroup[i] = {};
				end
				if pPlayer then
					if GetMapType(pPlayer.nMapId) == "xoyogame" then
						local tbPos;
						if type(self.tbSetting.tbBeginPoint[1]) == "number" then
							tbPos = self.tbSetting.tbBeginPoint;
						else
							tbPos = self.tbSetting.tbBeginPoint[MathRandom(#self.tbSetting.tbBeginPoint)];
						end
						pPlayer.NewWorld(self.nMapId, unpack(tbPos));
						table.insert(self.tbPlayerGroup[i], tbMemberList[j]);						
					else
						pPlayer.LeaveTeam();
					end
				end
			end
		end
	end
end

-- 删除队伍信息
function BaseRoom:DelTeamInfo(nTeamId)
	for i = 1, #self.tbTeam do
		if self.tbTeam[i].nTeamId == nTeamId then
			self.tbTeam[i] = nil;
		end
	end
end

-- 获得队伍信息
function BaseRoom:GetTeamInfo(nTeamId)
	for i = 1, #self.tbTeam do
		if self.tbTeam[i].nTeamId == nTeamId then
			return self.tbTeam[i];
		end
	end
end

function BaseRoom:NpcCanTalk(szGroup, nCanTalk)
	local var = nil;
	if nCanTalk == 0 then
		var = 1;
	end
	for _, dwId in ipairs(self.tbNpcGroup[szGroup]) do
		local pNpc = KNpc.GetById(dwId);
		if pNpc then
			pNpc.GetTempTable("XoyoGame").nDontTalk = var;
		end
	end	
end

-- 玩家离开房间; (恢复状态)
function BaseRoom:PlayerLeaveRoom(nPlayerId)
	if self.tbPlayer[nPlayerId] then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		if pPlayer then
			-- 战斗状态
			pPlayer.SetFightState(0);
			pPlayer.nPkModel = Player.emKPK_STATE_PRACTISE;
			-- 注销死亡脚本
			if self.tbPlayer[nPlayerId].nOnDeathRegId then
				Setting:SetGlobalObj(pPlayer);
				PlayerEvent:UnRegister("OnDeath", self.tbPlayer[nPlayerId].nOnDeathRegId);
				self.tbPlayer[nPlayerId].nOnDeathRegId = 0
				Setting:RestoreGlobalObj();
			end
			self.tbTeam[self.tbPlayer[nPlayerId].nTeam].nPlayerCount = self.tbTeam[self.tbPlayer[nPlayerId].nTeam].nPlayerCount - 1;
			
			if self.USE_TRANSFORM_CHILD then
				if pPlayer.GetSkillState(1326) > 0 then
					pPlayer.RemoveSkillState(1326);
				end
			end
			
			if self.USE_CHANGE_CAMP then
				local nOriginalCamp = self.tbGroupOriginalCamp[self.tbPlayer[nPlayerId].nTeam];
				if nOriginalCamp then
					pPlayer.SetCurCamp(nOriginalCamp);
				end
			end
			
			if self.USE_DISABLE_SWITCH_SKILL then
				self:DisableSwitchSkill(pPlayer, 0);
			end
		end
		self.tbPlayer[nPlayerId] = nil;
		
		if self.OnPlayerLeaveRoom then
			self:OnPlayerLeaveRoom(nPlayerId);
		end
	end
end

-- 检查胜方
function BaseRoom:CheckWinner()
	if not self.tbWinner or not self.tbLoser then
		if self.tbSetting.fnWinRule then
			self.tbWinner, self.tbLoser = self.tbSetting.fnWinRule(self);
		else
			self.tbWinner, self.tbLoser = self:DefaultWinRule();
		end
	end
	return self.tbWinner, self.tbLoser;
end

-- 默认胜利规则
function BaseRoom:DefaultWinRule()
	local tbWinnerTeam = {};
	local tbLostTeam = {};
	for _, tbTeamInfo in pairs(self.tbTeam) do
		if tbTeamInfo.bIsWiner == 1 then
			table.insert(tbWinnerTeam, tbTeamInfo.nTeamId);
		else
			table.insert(tbLostTeam, tbTeamInfo.nTeamId);
		end
	end
	return tbWinnerTeam, tbLostTeam;
end


-- 开启房间
function BaseRoom:Start()
	if self.OnBeforeStart then
		self:OnBeforeStart();
	end
	self.tbLock[1]:StartLock();
end

-- 关闭房间
function BaseRoom:Close()
	-- 删除剩余的NPC
	for szGroup, _ in pairs(self.tbNpcGroup) do
		self:DelNpc(szGroup);
	end
	for nPlayerId, _ in pairs(self.tbPlayer) do
		self:PlayerLeaveRoom(nPlayerId);
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			Dialog:ShowBattleMsg(pPlayer,  0,  0); --关闭界面
		end
	end
	for _, data in pairs(self.tbAddNpcTimer) do
		if data.nTimerId then
			Timer:Close(data.nTimerId);
		end
	end
	
	for _, tbLock in ipairs(self.tbLock) do
		tbLock:Close();
	end
	
	if self.tbWinner and self.tbAward then
		self:TeamAward(self.tbWinner, self.tbAward.nWinExp, self.tbAward.nWinRepute, self.tbAward.nPrestige, 10, 1, self.tbAward.nTollGatePoint); -- 10是胜利通关后的贡献度
	end
	if self.tbLoser and self.tbAward then
		self:TeamAward(self.tbLoser, self.tbAward.nLostExp, self.tbAward.nLostRepute, 0, 0, 0, 0);
	end
	
	if self.OnClose then
		self:OnClose();
	end
end

--------------------------------- PK 房间逻辑 -------------------------------------

function BaseRoom:PKGroup(...)
	if #arg ~= 2 then
		print("not enough team in PK Room", arg[1], arg[2]);
		return 0;
	end
	for i = 1, #arg do
		local tbMemberList, nNum = KTeam.GetTeamMemberList(arg[i]);
		if tbMemberList then
			for j = 1, nNum do
				local pPlayer = KPlayer.GetPlayerObjById(tbMemberList[j])
				if pPlayer then
					pPlayer.NewWorld(self.nMapId, unpack(self.tbSetting.tbBeginPoint[i]));
					pPlayer.SetCurCamp(i);
					pPlayer.nInBattleState = 1
				end
				if not self.tbPlayerGroup[i] then
					self.tbPlayerGroup[i] = {};
				end
				table.insert(self.tbPlayerGroup[i], tbMemberList[j]);
			end
		end
	end
end

function BaseRoom:PKDeath(pKillNpc)
	-- 马上原地复活
	me.ReviveImmediately(1);
	-- 战斗状态
	me.SetFightState(0);
	local pWinPlayer = pKillNpc.GetPlayer();
	if not pWinPlayer then -- 不是被玩家所杀
		return 0;
	end
	local nWinPlayerId = pWinPlayer.nId;
	local nPlayerId = me.nId;
	if not self.tbPlayer[nWinPlayerId] or not self.tbPlayer[nPlayerId] then		-- 玩家不在房间数据内
		return 0;
	end
	local nWinTeam = self.tbPlayer[nWinPlayerId].nTeam;
	local nKilledTeam = self.tbPlayer[nPlayerId].nTeam;
	if not self.tbTeam[nWinTeam].nCount then
		self.tbTeam[nWinTeam].nCount = 0;
	end
	if not self.tbTeam[nKilledTeam].nCount then
		self.tbTeam[nKilledTeam].nCount = 0;
	end
	-- 重投战斗定时
	self.tbPlayer[nPlayerId].nTimerId = Timer:Register(XoyoGame.PK_REFIGHT_TIME * Env.GAME_FPS, self.ReFight, self, nPlayerId)
	self.tbTeam[nWinTeam].nCount = self.tbTeam[nWinTeam].nCount + 1;
	self:SetTagetInfo(nWinTeam, 
		string.format("Kẻ địch đã đánh bại nhóm: %d\nKẻ địch bị đánh bại bởi: %d", self.tbTeam[nKilledTeam].nCount, self.tbTeam[nWinTeam].nCount));
	self:SetTagetInfo(nKilledTeam,
		string.format("Kẻ địch bì giết: %d\nNhóm đã bị kẻ địch đánh bại: %d", self.tbTeam[nWinTeam].nCount, self.tbTeam[nKilledTeam].nCount));
end

function BaseRoom:ReFight(nPlayerId)
	if not self.tbPlayer[nPlayerId] then
		return 0;
	end
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.SetFightState(1);
	end
	return 0;
end

-- PK胜负规则
function BaseRoom:PKWinRule()
	if (not self.tbTeam[1]) and (not self.tbTeam[2]) then		-- 双方都不在场
		return {},{};
	elseif not self.tbTeam[1] then					-- 一方在场
		return {self.tbTeam[2].nTeamId}, {};
	elseif not self.tbTeam[2] then
		return {self.tbTeam[1].nTeamId}, {};
	elseif not self.tbTeam[1].nCount then			-- 双方无杀人
		return {}, {self.tbTeam[1].nTeamId, self.tbTeam[2].nTeamId};
	else
		local tbLevel = {}
		for i = 1, 2 do
			local tbMemberList, nCount = KTeam.GetTeamMemberList(self.tbTeam[i].nTeamId);
			tbLevel[i] = 0;
			for j = 1, nCount do
				local pPlayer = KPlayer.GetPlayerObjById(tbMemberList[j]);
				if pPlayer then
					tbLevel[i] = tbLevel[i] + pPlayer.nLevel;
				end
			end
			tbLevel[i] = tbLevel[i] / (nCount * 1000);
		end
		if self.tbTeam[1].nCount - tbLevel[1] > self.tbTeam[2].nCount - tbLevel[2] then	-- 一方胜利
			return {self.tbTeam[1].nTeamId}, {self.tbTeam[2].nTeamId}
		elseif self.tbTeam[2].nCount - tbLevel[2] > self.tbTeam[1].nCount - tbLevel[1] then
			return {self.tbTeam[2].nTeamId}, {self.tbTeam[1].nTeamId};
		else		-- 平局
			return {}, {self.tbTeam[1].nTeamId, self.tbTeam[2].nTeamId};
		end
	end
end

-- PK胜负规则 忽略等级差别
function BaseRoom:PKWinRule2()
	if (not self.tbTeam[1]) and (not self.tbTeam[2]) then		-- 双方都不在场
		return {},{};
	elseif not self.tbTeam[1] then					-- 一方在场
		return {self.tbTeam[2].nTeamId}, {};
	elseif not self.tbTeam[2] then
		return {self.tbTeam[1].nTeamId}, {};
	elseif self.tbTeam[1].nCount > self.tbTeam[2].nCount then	-- 一方胜利
		return {self.tbTeam[1].nTeamId}, {self.tbTeam[2].nTeamId}
	elseif self.tbTeam[2].nCount > self.tbTeam[1].nCount then
		return {self.tbTeam[2].nTeamId}, {self.tbTeam[1].nTeamId};
	else	-- 平局
		return {}, {self.tbTeam[1].nTeamId, self.tbTeam[2].nTeamId};
	end
end

----------------- 猜谜房间逻辑--------------------------------------------
-- 获得队伍答题者
function BaseRoom:GetTeamGuessPlayer(nTeamId)
	for _, tbTeamInfo in ipairs(self.tbTeam) do
		if tbTeamInfo.nTeamId == nTeamId then
			if not tbTeamInfo.nGuessPlayer then
				return 0;
			end
			return tbTeamInfo.nGuessPlayer;
		end 
	end
end

-- 设定队伍答题者
function BaseRoom:SetTeamGuessPlayer(nTeamId, nPlayerId)
	for _, tbTeamInfo in ipairs(self.tbTeam) do
		if tbTeamInfo.nTeamId == nTeamId then
			if not tbTeamInfo.nGuessPlayer then
				tbTeamInfo.nGuessPlayer = nPlayerId
			end
		end 
	end
end

function BaseRoom:AskQuestion(nTeamId, nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbTeamInfo = self:GetTeamInfo(nTeamId);
	if not tbTeamInfo then
		return ;
	end
	if not tbTeamInfo.nQuestCount then
		tbTeamInfo.nQuestCount = 0;
		tbTeamInfo.nGuessScore = 0;
		tbTeamInfo.nTime = GetTime();
	end
	local szMsg;
	local szMemberMsg = "Đội trưởng yêu cầu những câu hỏi sau: \n  ";
	local tbOpt = {};
	if tbTeamInfo.nQuestCount >= XoyoGame.GUESS_QUESTIONS then
		if tbTeamInfo.nGuessScore >= XoyoGame.MIN_CORRECT then
			szMsg = "Ngươi được quyền"..tbTeamInfo.nGuessScore.."...,Với thời gian"..Lib:TimeDesc(tbTeamInfo.nTime).."，干得不错，不过还得等时间到才能分出胜负哦";
		else
			szMsg = "Ngươi chỉ trả lời "..tbTeamInfo.nGuessScore.."Có vẻ như ngươi đã quen thuộc với phần này."
		end
		Dialog:Say(szMsg);
		return 0;
	end
	local nRandom = MathRandom(#XoyoGame.tbGuessQuestion);
	szMsg = XoyoGame.tbGuessQuestion[nRandom].szQuestion;
	szMemberMsg = szMemberMsg..szMsg;
	table.insert(tbOpt, {XoyoGame.tbGuessQuestion[nRandom].szAnswer, self.ResultAnswer, self, nTeamId, 1, nNpcId})
	for i = 1, #XoyoGame.tbGuessQuestion[nRandom].tbSelect do
		if XoyoGame.tbGuessQuestion[nRandom].tbSelect[i] ~= "" then
			table.insert(tbOpt, {XoyoGame.tbGuessQuestion[nRandom].tbSelect[i], self.ResultAnswer, self, nTeamId, 0, nNpcId})
		end
	end
	local nOptCount = #tbOpt;
	for i = 1, nOptCount do
		local nSwap = MathRandom(nOptCount);
		tbOpt[i], tbOpt[nSwap] = tbOpt[nSwap], tbOpt[i];
	end
	for i = 1, nOptCount do
		szMemberMsg = szMemberMsg.."\nTùy chọn"..i..":"..tbOpt[i][1]
	end
	table.insert(tbOpt, {"Ta hủy bỏ"});
	tbTeamInfo.nQuestCount = tbTeamInfo.nQuestCount + 1;
	Dialog:Say("Câu hỏi "..tbTeamInfo.nQuestCount.." có nội dung như sau: \n  "..szMsg, tbOpt);
	local tbMemberList, nCount = KTeam.GetTeamMemberList(me.nTeamId);
	for i = 2, nCount do
		local pPlayer = KPlayer.GetPlayerObjById(tbMemberList[i]);
		if pPlayer then
			Setting:SetGlobalObj(pPlayer);
			Dialog:Say(szMemberMsg);
			Setting:RestoreGlobalObj();
		end
	end
end

function BaseRoom:ResultAnswer(nTeamId, nResult, nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbTeamInfo = self:GetTeamInfo(nTeamId);
	if not tbTeamInfo then
		return ;
	end
	if nResult == 1 then
		tbTeamInfo.nGuessScore = tbTeamInfo.nGuessScore + 1;
	end
	if tbTeamInfo.nQuestCount == XoyoGame.GUESS_QUESTIONS then
		tbTeamInfo.nTime = GetTime() - tbTeamInfo.nTime;
	end
	self:AskQuestion(nTeamId, nNpcId);
end

-- 答题胜负规则
function BaseRoom:GuessRule()
	local tbWinner = {};
	local tbLoser = {};
	local tbTemp = {};
	for i = 1, 2 do
		if self.tbTeam[i] then
			if not self.tbTeam[i].nQuestCount or self.tbTeam[i].nQuestCount < XoyoGame.GUESS_QUESTIONS or self.tbTeam[i].nGuessScore < XoyoGame.MIN_CORRECT then
				table.insert(tbLoser, self.tbTeam[i].nTeamId);
			else
				table.insert(tbTemp, self.tbTeam[i]);
			end
		end
	end
	if #tbTemp < 2 then
		if tbTemp[1] then
			table.insert(tbWinner, tbTemp[1].nTeamId);
		end
	else
		if tbTemp[1].nGuessScore - tbTemp[1].nTime / 600 > tbTemp[2].nGuessScore - tbTemp[2].nTime / 600 then
			tbWinner[1] = tbTemp[1].nTeamId;
			tbLoser[1] = tbTemp[2].nTeamId;
		elseif tbTemp[1].nGuessScore - tbTemp[1].nTime / 600 < tbTemp[2].nGuessScore - tbTemp[2].nTime / 600 then
			tbWinner[1] = tbTemp[2].nTeamId;
			tbLoser[2] = tbTemp[1].nTeamId;
		else
			tbWinner[1] = tbTemp[1].nTeamId;
			tbWinner[2] = tbTemp[2].nTeamId;
		end
	end
	return tbWinner, tbLoser;
end

------------------------------------------------------------------------------------------------------------------------
-- 生存模式规则

function BaseRoom:SurviveRule()
	if self.tbTeam[1].bIsLost == 1 then
		return {}, {self.tbTeam[1].nTeamId};
	end
	local tbTemp = {}
	--Lib:ShowTB(self.tbPlayer);
	for _, tbPlayerInfo in pairs(self.tbPlayer) do
		if tbPlayerInfo.nTeam then
			return {tbPlayerInfo.nTeam}, {};
		end
	end
	return {}, {self.tbTeam[1].nTeamId};
end


