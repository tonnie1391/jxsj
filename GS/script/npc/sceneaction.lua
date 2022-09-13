-- 文件名　：sceneaction.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-07-04 14:11:49
-- 功能    ：场景动作

Npc.SceneAction = Npc.SceneAction or {};
local SceneAction = Npc.SceneAction;

SceneAction.szFileName = "\\setting\\npc\\sceneaction.txt";

SceneAction.tbMapInfo = {
	["taoxizhen"] = {2154,2254},	
	}

SceneAction.tbActionEvent = SceneAction.tbActionEvent or {};	--管理表
SceneAction.tbActionEventEx = SceneAction.tbActionEventEx or {};	--管理表
SceneAction.tbActionList = SceneAction.tbActionList or {};		--配置表

----------------------------------------------------------------------------------------------------------
--函数回调
----------------------------------------------------------------------------------------------------------
--条件函数集
SceneAction.tbCheckFunction = {
	["CheckTask"] = "ExCheckTask",
	["CheckHasItem"] = "ExCheckHasItem",
};

function SceneAction.ExCheckTask(szParam)
	local tbParam = Lib:SplitStr(szParam);
	local nTaskGourpId 	= tonumber(tbParam[1]) or 0;
	local nTaskId 	= tonumber(tbParam[2]) or 0;
	local nNeed 		= tonumber(tbParam[3]) or 0;
	local nType 		= tonumber(tbParam[4]) or 0;
	if nTaskGourpId <= 0 or nTaskId <= 0 then
		return 0;
	end 
	if not me then
		return 1;
	end
	if nType == 0 then
		if me.GetTask(nTaskGourpId, nTaskId) == nNeed then
			return 1;
		end
	elseif nType == 1 then
		if me.GetTask(nTaskGourpId, nTaskId) <= nNeed then
			return 1;
		end
	elseif nType == 2 then
		if me.GetTask(nTaskGourpId, nTaskId) >= nNeed then
			return 1;
		end
	end
	return 0;
end

function SceneAction:ExCheckHasItem(szParam)
	local tbParam = Lib:SplitStr(szParam);
	local nG 	= tonumber(tbParam[1]) or 0;
	local nD 	= tonumber(tbParam[2]) or 0;
	local nP 	= tonumber(tbParam[3]) or 0;
	local nL 	= tonumber(tbParam[4]) or 0;
	if not me then
		return 1;
	end
	local tbFind = me.FindItemInBags(nG, nD, nP, nL);
	if #tbFind > 0 then
		return 1;
	end
	return 0;
end

--------------------------------------------------------------------------------------------------------
--开始函数集（这里需要添加对象进去，所有的场景必须以npc或者玩家为对象做处理）
--------------------------------------------------------------------------------------------------------

SceneAction.tbStartFunction = {
	["AddNpc"] 	= "ExAddNpc",		--添加npc
	["AddNpc2"] 	= "ExAddNpc2",		--添加npc
	["FindNpc"] 	= "ExFindNpc",	--附近找npc
	["NpcFindPlayer"] 	= "ExNpcFindPlayer",	--通过npc掉进来找玩家
	["FindPlayer"]		= "ExFindPlayer",		--全局找玩家
	["AddSelfPlayer"] 	= "ExAddSelfPlayer",	--添加玩家自己
};

--npcId， 地图，x坐标，y坐标，等级，类型（nil默认，1跟随类型）
function SceneAction:ExAddNpc(szParam, nIndex)
	local tbParam = Lib:SplitStr(szParam);
	local nNpcId 	= tonumber(tbParam[1]) or 0;
	local nMapId 	= tonumber(tbParam[2]) or tbParam[2];
	local nX 		= tonumber(tbParam[3]) or 0;
	local nY 		= tonumber(tbParam[4]) or 0;
	local nLevel 	= tonumber(tbParam[5]) or 1;
	local nMode 	= tonumber(tbParam[6]) or 0;
	local nDir 	= tonumber(tbParam[7]) or 0;
	if nNpcId <= 0 or (not self.tbMapInfo[nMapId] and type(nMapId) == "number" and nMapId <= 0) or nX <= 0 or nY <= 0 then
		return 0;
	end
	if not self.tbMapInfo[nMapId] then
		if SubWorldID2Idx(nMapId) < 0 then
			return 0;
		end
		local pNpc = KNpc.Add2(nNpcId, nLevel, -1, nMapId, nX, nY,0,0,0,0,0,nDir);
		local nIndexEx = self:FindBlackTB();
		if pNpc then
			self.tbActionEvent[nIndexEx] = {};
			self.tbActionEvent[nIndexEx].tbObjInfo = {pNpc.dwId};
			self.tbActionEvent[nIndexEx].nTypeObj = "Npc";
			self.tbActionEvent[nIndexEx].nEventIndex = nIndex;
			self.tbActionEvent[nIndexEx].nStep = 0;
			self.tbActionEvent[nIndexEx].nMinStep = 0;
			
			self.tbActionEventEx[nIndexEx] = nil;
			if nMode == 0 then
				pNpc.SetNpcAI(9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
			elseif nMode == 1 and me then
				pNpc.SetNpcAI(10, me.GetNpc().nIndex, 0, 0, 0, 0, 0, 0, 0, 0, 0);
			end
			return nIndexEx;
		end
	else
		local nIndexEx = self:FindBlackTB();
		local tbObjInfo = {};
		for i, nMapIdEx in ipairs(self.tbMapInfo[nMapId]) do
			if SubWorldID2Idx(nMapIdEx) >= 0 then
				local pNpc = KNpc.Add2(nNpcId, nLevel, -1, nMapIdEx, nX, nY,0,0,0,0,0,nDir);	
				if pNpc then
					if nMode == 0 then
						pNpc.SetNpcAI(9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
					elseif nMode == 1 and me then
						pNpc.SetNpcAI(10, me.GetNpc().nIndex, 0, 0, 0, 0, 0, 0, 0, 0, 0);
					end
					table.insert(tbObjInfo, pNpc.dwId);
				end
			end
		end
		if #tbObjInfo > 0 then
			self.tbActionEvent[nIndexEx] = {};
			self.tbActionEvent[nIndexEx].tbObjInfo = tbObjInfo;
			self.tbActionEvent[nIndexEx].nTypeObj = "Npc";
			self.tbActionEvent[nIndexEx].nEventIndex = nIndex;
			self.tbActionEvent[nIndexEx].nStep = 0;
			self.tbActionEvent[nIndexEx].nMinStep = 0;
			self.tbActionEventEx[nIndexEx] = nil;
			return nIndexEx;
		end
	end
	return 0;
end

--特殊Addnpc ，必须由玩家me掉进来
function SceneAction:ExAddNpc2(szParam, nIndex)
	local tbParam = Lib:SplitStr(szParam);
	local nNpcId 	= tonumber(tbParam[1]) or 0;
	local nMapId 	= tonumber(tbParam[2]) or 0;
	local nX 		= tonumber(tbParam[3]) or 0;
	local nY 		= tonumber(tbParam[4]) or 0;
	local nLevel 	= tonumber(tbParam[5]) or 1;
	local nMode 	= tonumber(tbParam[6]) or 0;
	local nDir 	= tonumber(tbParam[7]) or 0;
	if nNpcId <= 0 or nX <= 0 or nY <= 0 then
		return 0;
	end
	if not me then
		return 0;
	end
	if nMapId ~= me.nTemplateMapId then
		return 0;
	end
	local pNpc = KNpc.Add2(nNpcId, nLevel, -1, me.nMapId, nX, nY,0,0,0,0,0,nDir);
	local nIndexEx = self:FindBlackTB();
	if pNpc then
		self.tbActionEvent[nIndexEx] = {};
		self.tbActionEvent[nIndexEx].tbObjInfo = {pNpc.dwId};
		self.tbActionEvent[nIndexEx].nTypeObj = "Npc";
		self.tbActionEvent[nIndexEx].nEventIndex = nIndex;
		self.tbActionEvent[nIndexEx].nStep = 0;
		self.tbActionEvent[nIndexEx].nMinStep = 0;
		self.tbActionEventEx[nIndexEx] = nil;
		if nMode == 0 then
			pNpc.SetNpcAI(9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		elseif nMode == 1 then
			pNpc.SetNpcAI(10, me.GetNpc().nIndex, 0, 0, 0, 0, 0, 0, 0, 0, 0);
		end
		return nIndexEx;
	end
	return 0;
end

--npcId, 多少距离内npc
function SceneAction:ExFindNpc(szParam, nIndex)
	local tbParam = Lib:SplitStr(szParam);
	local nNpcId = tonumber(tbParam[1]) or 0;
	local nRound = tonumber(tbParam[2]) or 0;
	if nNpcId <= 0 or nRound <= 0 then
		return 0;
	end
	local tbObjInfo = {};
	local tbNpcList =  KNpc.GetAroundNpcList(me, nRound);
	for i, pNpc in ipairs(tbNpcList) do
		if pNpc.nTemplateId == nNpcId then
			table.insert(tbObjInfo, pNpc.dwId);
		end
	end
	local nIndexEx = self:FindBlackTB();
	if #tbObjInfo > 0 then
		self.tbActionEvent[nIndexEx] = {};
		self.tbActionEvent[nIndexEx].tbObjInfo = tbObjInfo;
		self.tbActionEvent[nIndexEx].nTypeObj = "Npc";
		self.tbActionEvent[nIndexEx].nEventIndex = nIndex;
		self.tbActionEvent[nIndexEx].nStep = 0;
		self.tbActionEvent[nIndexEx].nMinStep = 0;
		self.tbActionEventEx[nIndexEx] = nil;
		return nIndexEx;
	end
	return 0;
end

--玩家名字
function SceneAction:ExNpcFindPlayer(szParam, nIndex)
	local tbParam = Lib:SplitStr(szParam);
	local nNpcId = tonumber(tbParam[1]) or 0;
	local nRound = tonumber(tbParam[2]) or 0;
	if nNpcId <= 0 or nRound <= 0 then
		return 0;
	end
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		local tbObjInfo = {};
		local tbPlayerList = KNpc.GetAroundPlayerList(pNpc.dwId, nRound);
		for i, pPlayer in ipairs(tbPlayerList) do
			table.insert(tbObjInfo, pPlayer.nId);
		end
		local nIndexEx = self:FindBlackTB();
		if #tbPlayerList > 0 then
			self.tbActionEvent[nIndexEx] = {};
			self.tbActionEvent[nIndexEx].tbObjInfo = tbObjInfo;
			self.tbActionEvent[nIndexEx].nTypeObj = "Player";
			self.tbActionEvent[nIndexEx].nEventIndex = nIndex;
			self.tbActionEvent[nIndexEx].nStep = 0;
			self.tbActionEvent[nIndexEx].nMinStep = 0;
			self.tbActionEventEx[nIndexEx] = nil;
			return nIndexEx;
		end
	end
	return 0
end

--玩家名字
function SceneAction:ExFindPlayer(szParam, nIndex)
	local pPlayer = KPlayer.GetPlayerByName(szParam);
	local nIndexEx = self:FindBlackTB();
	if pPlayer then
		self.tbActionEvent[nIndexEx] = {};
		self.tbActionEvent[nIndexEx].tbObjInfo = {pPlayer.nId};
		self.tbActionEvent[nIndexEx].nTypeObj = "Player";
		self.tbActionEvent[nIndexEx].nEventIndex = nIndex;
		self.tbActionEvent[nIndexEx].nStep = 0;
		self.tbActionEvent[nIndexEx].nMinStep = 0;
		self.tbActionEventEx[nIndexEx] = nil;
		return nIndexEx;
	end
	return 0;
end

function SceneAction:ExAddSelfPlayer(szParam, nIndex)
	local nIndexEx = self:FindBlackTB();
	if not me then
		return 0;
	end
	self.tbActionEvent[nIndexEx] = {};
	self.tbActionEvent[nIndexEx].tbObjInfo = {me.nId};
	self.tbActionEvent[nIndexEx].nTypeObj = "Player";
	self.tbActionEvent[nIndexEx].nEventIndex = nIndex;
	self.tbActionEvent[nIndexEx].nStep = 0;
	self.tbActionEvent[nIndexEx].nMinStep = 0;
	self.tbActionEventEx[nIndexEx] = nil;
	return nIndexEx;
end

--------------------------------------------------------------------------------------------------------
--步骤函数集（每个函数都需要一个回调GoBack，这里为了保证标志一步完成）
--------------------------------------------------------------------------------------------------------
SceneAction.tbParamFunction = {
	["Speak"] 			= "ExSpeak",
	["SpeakRandom"] 	= "ExSpeakRandom",
	["CastSkill"] 		= "ExCastSkill",
	["SetTask"] 		= "ExSetTask",
	["SetArrivePos"]	= "ExSetArrivePos",
	["WaitTime"]		= "ExWaitTime",
	["ClearNpc"]		= "ExClearNpc",
};

--玩家或npc说话
function SceneAction:ExSpeak(szParam, nIndex)
	local tbParam = Lib:SplitStr(szParam);
	local szMsg = tbParam[1] or "";
	local nType = tonumber(tbParam[2]) or 0;	--默认为泡泡形式
	local bSynPlayer = tonumber(tbParam[3]) or 0;	--默认为泡泡形式
	if szMsg == "" or nIndex <= 0 then
		self:GoBack(nIndex);
		return 0;
	end
	local tbActionInfo = self.tbActionEvent[nIndex];
	if not tbActionInfo then
		self:GoBack(nIndex);
		return 0;
	end
	if tbActionInfo.nTypeObj == "Player" then
		for _, nPlayerId in ipairs(tbActionInfo.tbObjInfo) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				pPlayer.GetNpc().SendChat(szMsg);
				pPlayer.Msg(szMsg, pPlayer.szName);
			end
		end
	elseif tbActionInfo.nTypeObj == "Npc" then
		for _, nNpcId in ipairs(tbActionInfo.tbObjInfo) do
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				pNpc.SendChat(szMsg, nType);

				if bSynPlayer == 1 then
					local tbPlayerList = KNpc.GetAroundPlayerList(nNpcId, 30);
					for i, pPlayer in ipairs(tbPlayerList) do
						pPlayer.Msg(szMsg, pNpc.szName);
					end
				end
			end
		end
	end
	self:GoBack(nIndex);
	return 1;
end

function SceneAction:ExSpeakRandom(szParam, nIndex)
	local tbParam = Lib:SplitStr(szParam);
	local szMsg = tbParam[1] or "";
	local tbMsg = Lib:SplitStr(szMsg, "+");
	local nType = tonumber(tbParam[2]) or 0;			--默认为泡泡形式
	local nTime = tonumber(tbParam[3]) or 0;			--延迟说话
	local bTimerCycle = tonumber(tbParam[4]) or 0;	--循环随即说话
	if #tbMsg <= 0 or nTime <= 0 then
		self:GoBack(nIndex);
		return 0;
	end
	local tbActionInfo = self.tbActionEvent[nIndex];
	if not tbActionInfo then
		self:GoBack(nIndex);
		return 0;
	end
	Timer:Register(nTime * Env.GAME_FPS, self.ExSpeakRandom2, self, tbMsg, nType, bTimerCycle, nIndex);
	if bTimerCycle == 1 then
		self:GoBack(nIndex);
	end
	return 1;
end

function SceneAction:ExSpeakRandom2(tbMsg, nType, bTimerCycle, nIndex)
	local tbActionInfo = self.tbActionEvent[nIndex];
	if not tbActionInfo then
		self:GoBack(nIndex);
		return 0;
	end
	local bSend = 0;
	if tbActionInfo.nTypeObj == "Player" then
		for _, nPlayerId in ipairs(tbActionInfo.tbObjInfo) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				pPlayer.GetNpc().SendChat(tbMsg[MathRandom(#tbMsg)]);
				bSend = 1;
			end
		end
	elseif tbActionInfo.nTypeObj == "Npc" then
		for _, nNpcId in ipairs(tbActionInfo.tbObjInfo) do
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				pNpc.SendChat(tbMsg[MathRandom(#tbMsg)], nType);
				bSend = 1;
			end
		end
	end
	if bSend == 0 then
		self:GoBack(nIndex);
		return 0;
	end
	if bTimerCycle == 1 then
		return;
	end
	self:GoBack(nIndex);
	return 0;
end


function SceneAction:ExCastSkill(szParam, nIndex)
	local tbParam = Lib:SplitStr(szParam);
	local nSkillId = tonumber(tbParam[1]) or 0;
	local nLevel = tonumber(tbParam[2]) or 0;
	if nSkillId <= 0 or nLevel <= 0 then
		self:GoBack(nIndex);
		return 0;
	end
	local tbActionInfo = self.tbActionEvent[nIndex];
	if not tbActionInfo then
		self:GoBack(nIndex);
		return 0;
	end
	if tbActionInfo.nTypeObj == "Player" then
		for _, nPlayerId in ipairs(tbActionInfo.tbObjInfo) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				pPlayer.CastSkill(nSkillId, nLevel, -1, pPlayer.GetNpc().nIndex);
			end
		end
	elseif tbActionInfo.nTypeObj == "Npc" then
		for _, nNpcId in ipairs(tbActionInfo.tbObjInfo) do
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				pNpc.CastSkill(nSkillId, nLevel, -1, pNpc.nIndex);
			end
		end
	end
	self:GoBack(nIndex);
	return 1;
end

function SceneAction:ExSetTask(szParam, nIndex)
	local tbParam = Lib:SplitStr(szParam);
	local nGroup = tonumber(tbParam[1]) or 0;
	local nTaskId = tonumber(tbParam[2]) or 0;
	local nNum = tonumber(tbParam[3]) or 0;
	if nGroup <= 0 and nTaskId <= 0 then
		self:GoBack(nIndex);
		return 0;
	end
	local tbActionInfo = self.tbActionEvent[nIndex];
	if not tbActionInfo then
		self:GoBack(nIndex);
		return 0;
	end
	if tbActionInfo.nTypeObj ~= "Player" then
		self:GoBack(nIndex);
		return 0;
	end
	for _, nPlayerId in ipairs(tbActionInfo.tbObjInfo) do
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
		if pPlayer then
			pPlayer.SetTask(nGroup, nTaskId, nNum);
		end
	end
	self:GoBack(nIndex);
	return 1;
end

function SceneAction:ExSetArrivePos(szParam, nIndex)
	local tbParam = Lib:SplitStr(szParam);
	local nMovX = tonumber(tbParam[1]) or 0;
	local nMovY = tonumber(tbParam[2]) or 0;
	if nMovX <= 0  and nMovY <= 0 then
		self:GoBack(nIndex);
		return 0;
	end
	local tbActionInfo = self.tbActionEvent[nIndex];
	if tbActionInfo.nTypeObj == "Player" then
		for _, nPlayerId in ipairs(tbActionInfo.tbObjInfo) do
			local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
			if pPlayer then
				pPlayer.CallClientScript({"GM:DoCommand",string.format("me.StartAutoPath(%s, %s, 1)", nMovX, nMovY)});
			end
		end
		self:GoBack(nIndex);
	elseif tbActionInfo.nTypeObj == "Npc" then
		for i, nNpcId in ipairs(tbActionInfo.tbObjInfo) do
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				pNpc.AI_ClearPath();
				pNpc.AI_AddMovePos(nMovX * 32, nMovY * 32);
				pNpc.SetNpcAI(9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
				if i == #tbActionInfo.tbObjInfo then	--只有最后一个到达条件做回调
					pNpc.GetTempTable("Npc").tbOnArrive = {self.tbOnArrive, self, pNpc.dwId, nIndex};
				end
			end
		end
	end
	return 0;
end

function SceneAction:tbOnArrive(dwId, nIndex)
	local pNpc = KNpc.GetById(dwId)
	if pNpc then
		pNpc.SetNpcAI(4, 0, 0, 0, 0, 0, 100, 0, 0, 0, 0);
	end
	self:GoBack(nIndex);
end

function SceneAction:ExWaitTime(szParam, nIndex)
	local tbParam = Lib:SplitStr(szParam);
	local nTime = tonumber(tbParam[1]) or 0;
	local tbActionInfo = self.tbActionEvent[nIndex];
	if not tbActionInfo then
		self:GoBack(nIndex);
		return 0;
	end
	if nTime <= 0 then
		self:GoBack(nIndex);
		return 0;
	end
	tbActionInfo.nTimerId = Timer:Register(nTime * Env.GAME_FPS, self.ExWaitTime2, self, nIndex);
end

function SceneAction:ExWaitTime2(nIndex)
	local tbActionInfo = self.tbActionEvent[nIndex];
	if not tbActionInfo then
		self:GoBack(nIndex);
		return 0;
	end
	tbActionInfo.nTimerId = nil;
	self:GoBack(nIndex);
	return 0;
end

function SceneAction:ExClearNpc(szParam, nIndex)
	local tbActionInfo = self.tbActionEvent[nIndex];
	if tbActionInfo.nTypeObj == "Npc" then
		for i, nNpcId in ipairs(tbActionInfo.tbObjInfo) do
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				pNpc.Delete();
			end
		end
	end
	self:GoBack(nIndex);
end

----------------------------------------------------------------------------------------------------------
--逻辑
----------------------------------------------------------------------------------------------------------


function SceneAction:FindBlackTB()
	local nSelectIndex = 0;
	for i, _ in pairs(self.tbActionEventEx) do
		nSelectIndex = i;
		break;
	end
	if nSelectIndex > 0 then
		return nSelectIndex;
	end
	return #self.tbActionEvent + 1;
end

function SceneAction:SplitFun(szParam)
	local tbParam = {};
	if string.find(szParam, "|")  then
		local tbFun = Lib:SplitStr(szParam, "|");
		for i, szFun in ipairs(tbFun) do
			local tbFunEx = Lib:SplitStr(szFun, ":");
			if #tbFunEx == 2 then
				tbParam[tbFunEx[1]] = tbFunEx[2];
			end
		end
	else
		local tbFunEx = Lib:SplitStr(szParam, ":");
		if #tbFunEx == 2 then
			tbParam[tbFunEx[1]] = tbFunEx[2];
		end
	end
	return tbParam;
end

--load npc动作表
function SceneAction:LoadFile()
	local tbFile = Lib:LoadTabFile(self.szFileName);
	if not tbFile then
		print("场景配置文件读取错误！");
		return;
	end
	for nId, tbParam in ipairs(tbFile) do
		if nId > 1 then
			local nIndex  		= tonumber(tbParam.Index) or 0;
			local bStartSys  	= tonumber(tbParam.bStartSys) or 0;
			local bCycle  		= tonumber(tbParam.bCycle) or 0;
			local nCycleStartNum  	= tonumber(tbParam.CycleStartNum) or 0;
			local szStartAction 	= tbParam.StartAction or "";
			local szType = tbParam.szType or "";
			self.tbActionList[nIndex] = self.tbActionList[nIndex] or {};
			self.tbActionList[nIndex].bStartSys = bStartSys;
			self.tbActionList[nIndex].bCycle = bCycle;
			self.tbActionList[nIndex].nCycleStartNum = nCycleStartNum;
			self.tbActionList[nIndex].tbStartAction =  self:SplitFun(szStartAction);
			self.tbActionList[nIndex].tbAction = self.tbActionList[nIndex].tbAction or {};
			for i =1, 15 do
				local szExparam = "Action"..i;
				szExparam = tbParam[szExparam];
				local tbParam = {};
				if szExparam then
					tbParam = self:SplitFun(szExparam);
				end
				if Lib:CountTB(tbParam) > 0 then
					self.tbActionList[nIndex].tbAction[i] = tbParam;
				end
			end
		end
	end
end

SceneAction:LoadFile();


--load gs启动后加载需要的动作，开始执行
function SceneAction:ServerStart()
	for i, tb in pairs(self.tbActionList) do
		if tb.bStartSys == 1 then
			self:DoParam(i);
		end
	end
end

--执行操作
function SceneAction:DoParam(nIndex)
	if not self.tbActionList[nIndex] then
		return 0;
	end
	--开始条件
	if self:CheckParam(nIndex) == 0 then
		return 0;
	end
	--找对象设置管理表
	local nIndexEx = self:SetObjInfo(nIndex);
	if nIndexEx == 0 then
		return 0;
	end
	--执行其他操作
	self:DoParamEx(nIndex, nIndexEx, 1);
end

function SceneAction:CheckParam(nIndex, nNum)
	local tbList = self.tbActionList[nIndex];
	local tbParam = tbList.tbStartAction;
	if nNum and tbList.tbAction[nNum] then
		tbParam = tbList.tbAction[nNum];
	end
	for szFun, szParamEx in pairs(tbParam) do
		if self.tbCheckFunction[szFun] then
			if self[self.tbCheckFunction[szFun]](self, szParamEx) == 0 then
				return 0;
			end
		end
	end
	return 1;
end

function SceneAction:SetObjInfo(nIndex)
	local tbList = self.tbActionList[nIndex];
	local tbParam = tbList.tbStartAction;
	for szFun, szParamEx in pairs(tbParam) do
		if self.tbStartFunction[szFun] then
			local nIndexEx = self[self.tbStartFunction[szFun]](self, szParamEx, nIndex);
			if nIndexEx <= 0 then
				return 0;
			else
				return nIndexEx;
			end
		end
	end
	if Lib:CountTB(tbParam) <= 0 then
		return 0;
	end
	return 1;
end

--执行
function SceneAction:DoParamEx(nIndex, nIndexEx, nNum)
	local tbList = self.tbActionList[nIndex];
	local tbParam = tbList.tbStartAction;
	local tbActionEvent = self.tbActionEvent[nIndexEx];
	if not tbActionEvent then
		return;
	end
	if nNum and tbList.tbAction[nNum] then
		tbParam = tbList.tbAction[nNum];
		if tbActionEvent.nStep ~= nNum then
			tbActionEvent.nStep = nNum;
		end
	end
	for szFun, szParamEx in pairs(tbParam) do
		if self.tbParamFunction[szFun] then
			self[self.tbParamFunction[szFun]](self, szParamEx, nIndexEx);
		end
	end
end

function SceneAction:GoBack(nIndex)
	if not self.tbActionEvent[nIndex] then
		return;
	end
	local nEventIndex = self.tbActionEvent[nIndex].nEventIndex;
	local nStep = self.tbActionEvent[nIndex].nStep;
	if not self.tbActionList[nEventIndex] or not self.tbActionList[nEventIndex].tbAction[nStep] then
		return;
	end
	local tbParam = self.tbActionList[nEventIndex].tbAction[nStep];
	self.tbActionEvent[nIndex].nMinStep = (self.tbActionEvent[nIndex].nMinStep or 0) + 1;
	if self.tbActionEvent[nIndex].nMinStep == Lib:CountTB(tbParam) then
		if #self.tbActionList[nEventIndex].tbAction == nStep then
			if self.tbActionList[nEventIndex].bCycle == 1 and self.tbActionList[nEventIndex].nCycleStartNum > 0 then
				self.tbActionEvent[nIndex].nStep = self.tbActionList[nEventIndex].nCycleStartNum;
			else
				self.tbActionEvent[nIndex].nStep =  self.tbActionEvent[nIndex].nStep + 1;
			end
		else
			self.tbActionEvent[nIndex].nStep =  self.tbActionEvent[nIndex].nStep + 1;
		end
		self.tbActionEvent[nIndex].nMinStep = 0;
		self:GoNext(nIndex);
	end
end

function SceneAction:GoNext(nIndex)
	if not self.tbActionEvent[nIndex] then
		return;
	end
	local nEventIndex = self.tbActionEvent[nIndex].nEventIndex;
	local nStep = self.tbActionEvent[nIndex].nStep;
	if not self.tbActionList[nEventIndex] or not self.tbActionList[nEventIndex].tbAction[nStep] then
		self.tbActionEvent[nIndex] = {};
		self.tbActionEventEx[nIndex] = 1;
		return;
	end
	self:DoParamEx(nEventIndex, nIndex, nStep);
end

ServerEvent:RegisterServerStartFunc(Npc.SceneAction.ServerStart, Npc.SceneAction);