local tbChild = Npc:GetClass("xoyonpc_thief") -- 飞贼

-- 飞贼处于的状态
tbChild.REST = 1; -- 玩家离太远。等待状态
tbChild.MOVE = 2; -- 正常状态

tbChild.STOP_DISTANCE = 50;
tbChild.RESTART_DISTANCE = 30;

function tbChild:CreateChild(nMapId, x, y, tbRoom)
	local pNpc = KNpc.Add2(5001,150,-1,nMapId, x, y);
	pNpc.SetIgnoreBarrier(1);
	pNpc.SetNpcAI(0, 0, 0, 0, 0, 0, 0, 0); 
	pNpc.GetTempTable("Npc").tbOnArrive = {self.OnArrive, self, pNpc.dwId};
	pNpc.GetTempTable("XoyoGame").nCurIndex = 1;
	pNpc.GetTempTable("XoyoGame").tbRoom = tbRoom;
	
	
	self.jump = nil;
	self:move(pNpc);
	pNpc.GetTempTable("XoyoGame").nObserveTimerId = Timer:Register(1, self.Observe, self, pNpc.dwId);
	return pNpc;
end

function tbChild:OnArrive(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);	
	local nCurIndex = pNpc.GetTempTable("XoyoGame").nCurIndex;
	nCurIndex = nCurIndex + 1;
	if nCurIndex <= #self.tbPos and self.nmove == 1 then		
		pNpc.GetTempTable("XoyoGame").nCurIndex = nCurIndex;
		self.nmove = 0 -- 保证move和设置新目标点的调用一个隔着一个
	else
		local tbRoom = pNpc.GetTempTable("XoyoGame").tbRoom;
		tbRoom:ThiefFinish();
	end
	if pNpc.GetTempTable("XoyoGame").nState == self.MOVE then	
		self:move(pNpc);
	end
end

function tbChild:move(pNpc)
	local nCurIndex = assert(pNpc.GetTempTable("XoyoGame").nCurIndex);
	pNpc.GetTempTable("XoyoGame").nState = self.MOVE
	pNpc.AI_ClearPath();
	self.nmove = 1
	
	for i = 3, #self.tbPos[nCurIndex] do
		local tbFun = self.tbPos[nCurIndex][i];
		pNpc[tbFun[1]](unpack(tbFun, 2));
	end
	
	pNpc.AI_AddMovePos(self.tbPos[nCurIndex][1]*32, self.tbPos[nCurIndex][2]*32);
	pNpc.SetNpcAI(9, 0, 0, 0, 0, 0, 0, 0); 
	--pNpc.JumpTo(self.tbPos[nCurIndex][1]*32, self.tbPos[nCurIndex][2]*32)
	
end

function tbChild:Observe(dwId)
	local pNpc = KNpc.GetById(dwId);
	if not pNpc then
		return 0;
	end
	local tbRoom = pNpc.GetTempTable("XoyoGame").tbRoom;
	local nState = pNpc.GetTempTable("XoyoGame").nState;
	if nState == self.MOVE then
		local tbPlayerList = KNpc.GetAroundPlayerList(pNpc.dwId, self.STOP_DISTANCE);
		if #tbPlayerList == 0 then
			pNpc.SendChat("好累啊，左右无人，休息一会。");
			--tbRoom:SendPlayerMsg(-1, "飞贼：好累啊，左右无人，休息一会。");
			pNpc.SetNpcAI(4, 0, 0, 0, 0, 0, 0, 0);            
			--pNpc.Stop();
			pNpc.GetTempTable("XoyoGame").nState = self.REST;
		end
	else
		assert(pNpc.GetTempTable("XoyoGame").nState == self.REST);
		local tbPlayerList = KNpc.GetAroundPlayerList(pNpc.dwId, self.RESTART_DISTANCE);
		if #tbPlayerList > 0 then
			pNpc.SendChat("奇怪，好像有人在跟踪我，我闪先。");
			--tbRoom:SendPlayerMsg(-1, "飞贼：奇怪，好像有人在跟踪我，我闪先。");
			self:move(pNpc);
		end
	end
end

Require("\\script\\mission\\xoyogame\\npc\\xoyonpc_death.lua");
local tbNpc = Npc:GetClass("xoyonpc_deheng")
local tbNpcDeath = Npc:GetClass("xoyonpc_death");

function tbNpc:OnDeath(pKiller)
	local nMapId, x, y = him.GetWorldPos();
	KItem.AddItemInPos(nMapId, x, y, unpack(XoyoGame.RoomThiefDef.tbVase));
	tbNpcDeath:OnDeath(pKiller); -- 掉落卡片的逻辑
end