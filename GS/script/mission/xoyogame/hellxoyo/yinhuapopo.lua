-- 文件名　：yinhua.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-03-13 17:57:35
-- 描述：银花婆婆-地狱逍遥谷

local tbNpc = Npc:GetClass("yinhuapopo");

tbNpc.nNpcId = 7303;
tbNpc.nCastDelay = 20;
tbNpc.nSkillId = 1874;

tbNpc.nChildNpcId = 7331;	--铜花
tbNpc.nChildCastDelay = 10;	--释放技能的时间间隔
tbNpc.nChildSkillId	= 1871;	--要释放的技能id
tbNpc.tbChildBornPos =	--两个npc的出生位置
{
	[1] = {50496,102720},
	[2] = {50848,102208},	
}
tbNpc.tbCastPos = {50848,102720}
tbNpc.tbChildNpc = {}
tbNpc.nChildCastTimerId = nil;
tbNpc.nCastTimerId = nil;

tbNpc.tbYinHuaNpcId = 
{
	[1] = 7388;
	[2] = 7389;
	[3] = 7390;
	[4] = 7391;	
}
tbNpc.tbYinHuaBornPos =	--4个npc的出生位置
{
	[1] = {50464,102176},
	[2] = {51168,102176},	
	[3] = {51168,103264},
	[4] = {50464,103264},
}
tbNpc.nWudiSkillId = 1475;

function tbNpc:Create(nMapId,nLevel,tbRoom)
	local pNpc = KNpc.Add2(self.nNpcId,nLevel,2,nMapId, self.tbCastPos[1] / 32, self.tbCastPos[2] / 32,0);
	pNpc.GetTempTable("XoyoGame").tbRoom = tbRoom;
	self.nCastTimerId = Timer:Register(self.nCastDelay * Env.GAME_FPS, self.CastSkill, self, pNpc.dwId);
	return pNpc;
end

function tbNpc:CastSkill(dwId)
	local pNpc = KNpc.GetById(dwId);
	if pNpc then
		local tbRoom = pNpc.GetTempTable("XoyoGame").tbRoom;
		tbRoom:BlackMsg(-1,"老身最讨厌你们这些年轻人蹦来跳去的...");
		self.nChildCastTimerId = Timer:Register(self.nChildCastDelay * Env.GAME_FPS, self.CastChildSkill, self, self.tbChildNpc[MathRandom(100)%2 + 1] and self.tbChildNpc[MathRandom(100)%2 + 1].dwId );
	else
		return 0;
	end
end

function tbNpc:CreateChild(nMapId,nLevel)
	self.tbChildNpc = {};
	for i = 1,#self.tbChildBornPos do
		local pNpc = KNpc.Add2(self.nChildNpcId,nLevel,-1,nMapId, self.tbChildBornPos[i][1] / 32, self.tbChildBornPos[i][2] / 32);	--加两个npc
		table.insert(self.tbChildNpc,pNpc);
	end
	return self.tbChildNpc;
end

--定点释放技能
function tbNpc:CastChildSkill(dwId)
	local pNpc = KNpc.GetById(dwId);
	if pNpc then
		pNpc.CastSkill(self.nChildSkillId,10,self.tbCastPos[1],self.tbCastPos[2],1);
	end
	return 0;
end


function tbNpc:CreateYinHua(nMapId,nLevel)
	local tbNpc = {};
	for i = 1,#self.tbYinHuaBornPos do
		local pNpc = KNpc.Add2(self.tbYinHuaNpcId[i],nLevel,-1,nMapId, self.tbYinHuaBornPos[i][1] / 32, self.tbYinHuaBornPos[i][2] / 32);	
		table.insert(tbNpc,pNpc);
	end
	return tbNpc;
end

function tbNpc:OnDeath(pKiller)
	local tbRoom = him.GetTempTable("XoyoGame").tbRoom;
	XoyoGame:NpcUnLock(him);
	XoyoGame.XoyoChallenge:KillNpcForCard(pKiller.GetPlayer(), him);
	local pPlayer = pKiller.GetPlayer();
	if pPlayer then
		Achievement:FinishAchievement(pPlayer, 200);
	end
	if tbRoom then
		tbRoom:End();
	end
end
------------------------------------------------------------------------------------

Require("\\script\\mission\\xoyogame\\room_base.lua");

XoyoGame.RoomYinHua = Lib:NewClass(XoyoGame.BaseRoom);

local RoomYinHua = XoyoGame.RoomYinHua;

function RoomYinHua:CreateNpc()
	local nLevel = self:GetAverageLevel();
	nLevel = self:GetMonsterLevel(nLevel);
	local tbNpc1 = Npc:GetClass("yinhuapopo"):CreateChild(self.nMapId,nLevel);
	local tbNpc2 = Npc:GetClass("yinhuapopo"):CreateYinHua(self.nMapId,nLevel);
	local pNpc = Npc:GetClass("yinhuapopo"):Create(self.nMapId,nLevel,self);
	self:AddNpcInGroup(pNpc,"boss");
	for i = 1 ,#tbNpc1 do
		self:AddNpcInGroup(tbNpc1[i], "guaiwu");
	end
	for i = 1 ,#tbNpc2 do
		self:AddNpcInGroup(tbNpc2[i], "guaiwu");
	end
end


function RoomYinHua:Clear()
	if self.tbTeam[1].bIsWiner ~= 1 then
		self:DelNpc("boss");
	end
	self:DelNpc("guaiwu");
end

function RoomYinHua:OnInitRoom()
	ClearMapObj(self.nMapId);
end

function RoomYinHua:End()
	self:Clear();
	self:MovieDialog(-1, "<npc=7303>：“人老了,打不过你们这些年轻人了..咳..咳”");
	self.tbTeam[1].bIsWiner = 1;
	self:CloseInfo(-1);
	self:SetTagetInfo(-1,"任务完成");
	self:ChangeFight(-1,0,Player.emKPK_STATE_PRACTISE);
	self:AddGouHuo(2, 150, "gouhuo", "82_gouhuo");
	self:RoomLevelUp();
end

function RoomYinHua:OnClose()
	self:Clear();
end