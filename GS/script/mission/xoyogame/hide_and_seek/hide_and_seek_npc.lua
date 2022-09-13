local tbChild = Npc:GetClass("xoyo_child_hide_and_seek") -- id:4658

--tbChild.tbPos = {
--{1646,3184},
--{1653,3180},
--{1662,3184},
--{1654,3192},
--	};

--xoyo_lv3
--tbChild.tbPos = {
--{1487,3032},
--{1461,3023},
--{1450,3022},
--{1467,2980},
--{1503,2960},
--	};

tbChild.tbPos = {
{1704,3606},
{1740,3486},
{1741,3548},
{1757,3510},
{1747,3541},
{1753,3582},
{1754,3595},
{1772,3461},
{1772,3554},
{1775,3580},
{1784,3433},
{1785,3469},
{1782,3550},
{1788,3603},
{1793,3431},
{1797,3471},
{1803,3531},
{1797,3542},
{1793,3558},
{1805,3615},
{1810,3447},
{1815,3593},
{1823,3607},
{1838,3451},
{1839,3489},
{1837,3562},
{1824,3553},
{1838,3580},
{1852,3543},
{1840,3521},
{1863,3463},
{1858,3510},
{1858,3564},
{1881,3410},
{1894,3518},
{1888,3546},
{1916,3442},
};

--local tbPosCache = {};
--
--function tbPosCache:Init()
--	self.TIME_WINDOW = 3; -- 秒
--	self.MAX_POS_NUM = self.TIME_WINDOW * Env.GAME_FPS;
--	self.THRESHOLD = 0.9;
--	self.tbPosQueue = {};
--	self.tbPosMap = {};
--	self.nHit = 0;
--end
--
--function tbPosCache:AddPos(x, y)
--	local nPos = x*1000 + y;
--	if #self.tbPosQueue == self.MAX_POS_NUM then
--		local nLast = self.tbPosQueue[#self.tbPosQueue];
--		self.tbPosMap[nLast] = self.tbPosMap[nLast] - 1;
--		if self.tbPosMap[nLast] > 0 then
--			self.nHit = self.nHit - 1;
--		end
--		table.remove(self.tbPosQueue, 1);
--	end
--	
--	tabel.insert(self.tbPosQueue, nPos);
--	if not self.tbPosMap[nPos] then
--		self.tbPosMap[nPos] = 1;
--	else
--		self.tbPosMap[nPos] = self.tbPosMap + 1;
--		self.nHit = self.nHit + 1;
--	end
--end
--
--function tbPosCache:IsDeadLoop()
--	if self.nHit/(#self.tbPosQueue) >= self.THRESHOLD then
--		return 1;
--	else
--		return 0;
--	end
--end
--
--function tbChild:DetectDeadLoop(nNpcId)
--	local pNpc = KNpc.GetById(nNpcId);
--	if not pNpc then
--		return 0;
--	end
--	
--	if not pNpc.GetTempTable("Npc").nIsMoving then
--		return;
--	end
--	
--	local _, x, y = pNpc.GetWorldPos();
--	local tbCache = pNpc.GetTempTable("XoyoGame").tbPosCache 
--	tbCache:AddPos(x, y);
--end


function tbChild:Move(pNpc)
	local Pos = self:GetNextPos(pNpc)
	pNpc.GetTempTable("Npc").tbOnArrive = {self.OnArrive, self, pNpc.dwId};
	pNpc.GetTempTable("Npc").tbNextPos = Pos;
	pNpc.GetTempTable("Npc").nIsMoving = 1;
	pNpc.AI_ClearPath();
	pNpc.AI_AddMovePos(Pos[1]*32, Pos[2]*32);
	pNpc.SetNpcAI(9, 0, 0, 0, 0, 0, 0, 0); 
end

function tbChild:CancelMove(pNpc)
	pNpc.GetTempTable("Npc").nIsMoving = nil;
	pNpc.GetTempTable("Npc").tbOnArrive = nil;
	pNpc.GetTempTable("Npc").tbNextPos = nil;
	pNpc.AI_ClearPath();
	pNpc.SetNpcAI(4, 0, 0, 0, 0, 0, 0, 0);
	--pNpc.Stop();
end

function tbChild:Wait(nNpcId, nFinished)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end

	if nFinished then
		pNpc.GetTempTable("Npc").nWaitTimerId = nil;
		self:MakeDecision(nNpcId);
		return 0;
	else
		assert(not pNpc.GetTempTable("Npc").nWaitTimerId )
		local wait = MathRandom(3);
		pNpc.GetTempTable("Npc").nWaitTimerId = Timer:Register(wait*Env.GAME_FPS, self.Wait, self, nNpcId, 1);
	end
end

function tbChild:CancelWait(pNpc)
	if pNpc.GetTempTable("Npc").nWaitTimerId then
		Timer:Close(pNpc.GetTempTable("Npc").nWaitTimerId);
		pNpc.GetTempTable("Npc").nWaitTimerId = nil;
	end
end

function tbChild:CreateChild(nTemplateId, nMapId, x, y, tbRoom)
	if not x or not y then
		local Pos = self:GetNextPos();
		x = Pos[1];
		y = Pos[2];
	end
	
	local pNpc = KNpc.Add2(nTemplateId, 1, -1, nMapId, x, y);
	--pNpc.SetIgnoreBarrier(1)
	self:Move(pNpc);	
	pNpc.AddLifePObserver(90);
	pNpc.GetTempTable("XoyoGame").tbRoom = tbRoom;
	--pNpc.GetTempTable("XoyoGame").tbPosCache = Lib:NewClass(tbPosCache);
	return pNpc;
end

function tbChild:OnArrive(nNpcId)
	--print("OnArrive");
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return;
	end
	pNpc.GetTempTable("Npc").nCheated = 0;
	--pNpc.SetMoveSpeed(12);
	pNpc.GetTempTable("Npc").tbNextPos = nil;
	pNpc.SetNpcAI(0, 0, 0, 0, 0, 0, 0, 0); 
	self:MakeDecision(nNpcId);
end

function tbChild:MakeDecision(nNpcId)
	if self.nMakingDecision == 1 then
		return 0;
	end
	
	self.nMakingDecision = 1;
	
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		if pNpc.GetTempTable("Npc").nStop == 1 then
			self:CancelMove(pNpc);
			self:CancelWait(pNpc);
		else
			local wait = MathRandom(10);
			if wait >= 5 then
				self:Wait(nNpcId);
				--print("wait", wait)
			else
				self:Move(pNpc);
				--print("go");
			end
		end
	end
	
	self.nMakingDecision = nil;
	return 0;
end

function tbChild:Stop(pNpc)
	pNpc.GetTempTable("Npc").nStop = 1;
	self:MakeDecision(pNpc.dwId);
end

function tbChild:Resume(pNpc)
	pNpc.GetTempTable("Npc").nStop = nil;
end

function tbChild:GetNextPos(pNpc)
	local index = MathRandom(#self.tbPos);
	local Pos = self.tbPos[index];
	if pNpc then
		if pNpc.GetTempTable("Npc").tbNextPos then
			Pos = pNpc.GetTempTable("Npc").tbNextPos
		else
			local _, x, y = pNpc.GetWorldPos();
			if Pos[1] == x and Pos[2] == y then
				index = math.mod(index + 1, #self.tbPos) + 1;
				Pos = self.tbPos[index];
			end
		end
	end
	return Pos;
end

function tbChild:OnLifePercentReduceHere()
	him.RestoreLife();
	local room = him.GetTempTable("XoyoGame").tbRoom;
	
	if him.GetTempTable("Npc").nCheated == 1 or him.GetTempTable("Npc").nJustGetCaught == 1 then
		return;
	end
	
	if room:CanCatchChild() ~= 1 then
		return;
	end
	
	local tbPlayerList = KNpc.GetAroundPlayerList(him.dwId, 25);
	if not tbPlayerList or not tbPlayerList[1] then
		return;
	end
	
	if room:IsTargetChild(him) == 1 then
		local rand = MathRandom(10);
		if rand >= 2.5 then
			self:__GetCaught(tbPlayerList[1], him, room)
		else
			self:__Cheat(him, room);			
		end
	else
		self:__CastSkill(him, room);
	end
end

function tbChild:__GetCaught(pPlayer, pNpc, room)
	room:CaughtChild(pPlayer, pNpc);
	pNpc.GetTempTable("Npc").nJustGetCaught = 1;
	self:Stop(pNpc);
	local f = function(nNpcId)
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			self:Resume(pNpc);
			pNpc.GetTempTable("Npc").nJustGetCaught = nil;
		end
		return 0;
	end
	
	pNpc.SendChat("你好厉害啊，竟然给你捉到了。");
	
	--Timer:Register(3 * Env.GAME_FPS, f, pNpc.dwId);
end

function tbChild:__Cheat(pNpc, room)
	pNpc.SendChat("不要！这回不算数，这回不算数！");
			
	pNpc.GetTempTable("Npc").nCheated = 1
	
	local f = function(nNpcId)
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			local nMapId, x, y = pNpc.GetWorldPos();
			pNpc.CastSkill(1425, 1, x, y);	-- 隐身	
		end
		return 0;
	end
	
	--pNpc.SetMoveSpeed(30);
	self:CancelWait(pNpc);
	self:Move(pNpc);
	Timer:Register(1 * Env.GAME_FPS, f, pNpc.dwId);
end

function tbChild:__CastSkill(pNpc, room)
	local nMapId, x, y = pNpc.GetWorldPos();
	local tbData = room:GetSkillId(pNpc);
	local nSkillId = tbData[1];
	local szMsg = tbData[2];
	local nIsCasting = pNpc.GetTempTable("Npc").nIsCasting;
	
	if not nIsCasting then
		pNpc.GetTempTable("Npc").nIsCasting = 1;
		pNpc.CastSkill(nSkillId, 1, x, y);
		pNpc.SendChat(szMsg);
		
		local f = function(nNpcId)
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				pNpc.GetTempTable("Npc").nIsCasting = nil;
			end
			return 0;
		end
		
		Timer:Register(3*Env.GAME_FPS, f, pNpc.dwId);
	end
end

local tbDialog = Npc:GetClass("xoyo_child_hide_and_seek_dialog");

function tbDialog:OnDialog()
	local room = XoyoGame:GetPlayerRoom(me.nId);
	if not room then
		return;
	end
	room:DialogNpcOnDialog(him);
end
