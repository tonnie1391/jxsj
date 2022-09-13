Require("\\script\\mission\\xoyogame\\room_base.lua")
Require("\\script\\mission\\xoyogame\\invade\\invade_def.lua")

XoyoGame.RoomInvade = Lib:NewClass(XoyoGame.BaseRoom);
local RoomInvade = XoyoGame.RoomInvade;

function RoomInvade:OnInitRoom()
	-- tbNpcId2Group: nNpcId --> tbGroup
	-- 当一批npc大部分死后，将通过这个table找到下一批npc，然后 SetActivateForverver
	self.tbNpcId2Group = {};
	
	-- tbNpcGroupSet: 用于 tbNpcGroup 排序
	self.tbNpcGroupSet = {};
	self.nPawnNum = 0;
	
	self.nArriveNum = 0;
	self.szName = "RoomInvade";
end

function RoomInvade:ChoseRoute(tbBitrhPos)
	for nWhichRoute, tbRoute in ipairs(XoyoGame.InvadeDef.tbRoute) do 
		for i, pos in ipairs(tbRoute) do
			if pos[1] == tbBitrhPos[1] and pos[2] == tbBitrhPos[2] then
				return tbRoute, nWhichRoute, i;
			end
		end
	end
end

function RoomInvade:SetPath(pNpc, tbRoute, nRouteIndexBegin)
	if not tbRoute then
		return;
	end
	
	for nRouteIndex = nRouteIndexBegin, #tbRoute do
		local delta = tbRoute[nRouteIndex][3] or 5;
		local x = 0;
		local y = 0;
		if delta > 0 then
			x = MathRandom(2*delta) - delta;
			y = MathRandom(2*delta) - delta;
		end
		
		pNpc.AI_AddMovePos((tbRoute[nRouteIndex][1] + x)*32, 
			(tbRoute[nRouteIndex][2] + y)*32);
	end
end

function RoomInvade:IsBoss(pNpc)
	if pNpc.nTemplateId == 4664 then -- boss
		return 1;
	else
		return 0;
	end
end

function RoomInvade:AttachInfo(pNpc)
	if self:IsBoss(pNpc) == 1 then -- boss
		pNpc.AddLifePObserver(75);
		pNpc.AddLifePObserver(50);
		pNpc.AddLifePObserver(25);
		pNpc.AddLifePObserver(5);
		self:AddNpcInGroup(pNpc, "jinjun_boss");
	else
		local tbNpc = Npc:GetClass("xoyonpc_invade_pawn");
		pNpc.GetTempTable("Npc").tbOnArrive = {tbNpc.OnArrive, tbNpc, pNpc.dwId};
		self:AddNpcInGroup(pNpc, "jinjun");
		self.nPawnNum = self.nPawnNum + 1;
	end
	pNpc.GetTempTable("XoyoGame").tbRoom = self;
end

function RoomInvade:RandomNpc(nTemplateId, nLevel, nMapId, x, y, delta)
	local dx = 0;
	local dy = 0;
	if delta and delta > 0 then
		dx = MathRandom(2*delta) - delta;
		dy = MathRandom(2*delta) - delta;
	end
	local pNpc = KNpc.Add2(nTemplateId, nLevel, 0, nMapId, x + dx, y + dy);
	pNpc.SetIgnoreBarrier(1);
	return pNpc;
end

function RoomInvade:NewGroup(nWhichRoute, nRouteIndexBegin, nBirthIndex)
	if not nWhichRoute or not nRouteIndexBegin or not nBirthIndex then
		return;
	end
	
	local tbNpcGroup = {
		["tbNpcId"] = {}, ["nThreshold"] = 0, ["tbNextGroup"]=nil, ["nDeadNum"]=0,
		["nWhichRoute"] = nWhichRoute, ["nRouteIndexBegin"] = nRouteIndexBegin,
		["isActivate"] = 0,
		};
	
	if not self.tbNpcGroupSet[nBirthIndex] then
		self.tbNpcGroupSet[nBirthIndex] = {};
	end
	if not self.tbNpcGroupSet[nBirthIndex][nWhichRoute] then
		self.tbNpcGroupSet[nBirthIndex][nWhichRoute] = {};
	end
	
	table.insert(self.tbNpcGroupSet[nBirthIndex][nWhichRoute], tbNpcGroup);
	return tbNpcGroup;
end

function RoomInvade:AddNpc2Group(tbNpcGroup, pNpc)
	if tbNpcGroup then
		self.tbNpcId2Group[pNpc.dwId] = tbNpcGroup;
		tbNpcGroup.nThreshold = tbNpcGroup.nThreshold + 0.8; -- 这个 group 牺牲人数大于80%就可以激活下一组
		table.insert(tbNpcGroup.tbNpcId, pNpc.dwId);
	end
end

function RoomInvade:SortGroupAndActivate()
	local cmp = function(tb1, tb2)
		return tb1.nRouteIndexBegin > tb2.nRouteIndexBegin; -- 排成{5,4,3,2,1}这样, 接近路径终点的npc在前面
	end
	
	for nBirthIndex, tb1 in pairs(self.tbNpcGroupSet) do
		for nWhichRoute, tb2 in pairs(tb1) do
			table.sort(tb2, cmp);
			for i = 1, #tb2 - 1 do
				if tb2[i] then
					tb2[i].tbNextGroup = tb2[i+1]
				end
			end
			self:ActivateNpcGroup(tb2[1]); -- 离玩家最近的
		end
	end
end

function RoomInvade:AddJinJun()
	local nLevel = self:GetAverageLevel() - 25;
	for nBirthIndex, tbBirth in ipairs(XoyoGame.InvadeDef.tbBirth) do
		for nPosIndex = 2, #tbBirth do -- 遍历出生点
			local tbPos = tbBirth[nPosIndex];
			local tbRoute, nWhichRoute, nRouteIndexBegin = self:ChoseRoute(tbPos);
			local tbNpcGroup = self:NewGroup(nWhichRoute, nRouteIndexBegin, nBirthIndex);
			for _, tbNpc in ipairs(tbBirth[1]) do -- 遍历npc
				local nTemplateId = tbNpc[1];
				local nNum = tbNpc[2];
				for i = 1, nNum do
					local pNpc = self:RandomNpc(nTemplateId, nLevel, self.nMapId, unpack(tbPos));
					if pNpc then
						self:AddNpc2Group(tbNpcGroup, pNpc);
						self:AttachInfo(pNpc);
					end
				end
			end
		end
	end
	self:SortGroupAndActivate();
end

function RoomInvade:PawnArrive()
	self:MovieDialog(1, "想不到金军如此凶悍，竟然一路攻破内城，我军已经战败！");
	
	local f = function(pPlayer)
		self:SendPlayer2RestRoom(pPlayer);
	end
	
	self:GroupPlayerExcute(f, 1);
end

function RoomInvade:HasWin()
	if self.nBossDead == 1 and self.nPawnNum == 0 then
		return 1;
	else
		return 0;
	end
end

function RoomInvade:FinishMsg()
	if self:HasWin() == 1 then
		return;
	else
		self:DelNpc("jinjun");
		self:MovieDialog(1, "想不到金军如此凶悍，竟然一路攻破内城，我军已经战败！");
	end
end

function RoomInvade:BossDie()
	self.nBossDead = 1;
	if self:HasWin() == 1 then
		self:OnWin();
	else
		self:MovieDialog(1, "危险：仍有一小股金军在向内城靠近！");
	end
end

function RoomInvade:ActivateNpcGroup(tbNpcGroup)
	if not tbNpcGroup then
		return;
	end                       
	if tbNpcGroup.isActivate == 1 then
		return;
	end
	tbNpcGroup.isActivate = 1;
	local tbRoute = XoyoGame.InvadeDef.tbRoute[tbNpcGroup.nWhichRoute];
	local nRouteIndexBegin = tbNpcGroup.nRouteIndexBegin;
	for _, nId in ipairs(tbNpcGroup.tbNpcId) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			self:SetPath(pNpc, tbRoute, nRouteIndexBegin);
			pNpc.SetActiveForever(1);
			pNpc.SetNpcAI(9, 100, 1, 0, 100, 0, 0, 0);
		end
	end
end

function RoomInvade:PawnDie(pNpc)
	self.nPawnNum = self.nPawnNum - 1;
	if self:HasWin() == 1 then
		self:OnWin();
	end
	
	local tbGroup = self.tbNpcId2Group[pNpc.dwId];
	if tbGroup then
		tbGroup.nDeadNum = tbGroup.nDeadNum + 1;
		if tbGroup.nDeadNum >= tbGroup.nThreshold then
			self:ActivateNpcGroup(tbGroup.tbNextGroup);
		end
	end
end

function RoomInvade:OnWin()
	self:MovieDialog(1, "在诸位大侠的全力相助之下，金军已经溃不成军，抱头鼠窜了！");
	self:AddGouHuo(10, 150, "gouhuo", {1940,3385});
	self:SetTagetInfo(-1, "<color=green>任务完成<color>");
	self:RoomLevelUp();
	self:FinishAchieve(-1,213); -- achieve 
end

function RoomInvade:WinRule()
	if self:HasWin() == 1 then
		return {self.tbTeam[1].nTeamId}, {};
	else
		return {}, {self.tbTeam[1].nTeamId};
	end
end