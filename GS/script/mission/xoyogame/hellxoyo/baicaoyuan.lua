-- 文件名　：baicaoyuan.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-03-18 10:13:22
-- 描述：百草园--逍遥谷

-------------花的逻辑---------------------------------
local tbFlower = Npc:GetClass("baicaoyuan_flower");

local tbEvent = 
{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
}

function tbFlower:OnDialog()
	local nTime = tonumber(him.GetSctiptParam());
	if not nTime then
		self:EndProcess(him.dwId);
	else
		local szMsg = "采花中...";
		GeneralProcess:StartProcess(szMsg, 1 * Env.GAME_FPS, {self.EndProcess, self, him.dwId}, nil, tbEvent);
	end
end

function tbFlower:EndProcess(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
 	end
 	pNpc.Delete();
end
------------------------------------------------------------------------------------------------------

-----------------------百草园丁----------------------------

local tbYuanding = Npc:GetClass("baicaoyuanding");

tbYuanding.nYuanDingId = 7335;	--园丁id

tbYuanding.nFlowerId = 7336;	--花的id

tbYuanding.tbSkillId = 
{
	[1] = 2085,
	[2] = 2079,
	[3] = 2081,
	[4] = 2082,
	[5] = 2083,
}

tbYuanding.tbFlowerPos = 	--花刷出的位置
{
	[1]={51680,102912},
	[2]={51360,103456},
	[3]={51520,104000},
	[4]={52064,102976},
	[5]={52064,103904},
};

tbYuanding.tbYuandingPos = {51744,103520};	--boss位置

tbYuanding.nControlTimerId = nil;	--阶段控制计时器

tbYuanding.nStepTimerId = nil;	--阶段过程计时器

tbYuanding.tbFixSkillId = {2152,2153,2154,2155,2156};	-- 5个定点释放的技能

tbYuanding.nFixSkillTimerId = nil;

tbYuanding.nFixSkillDelay = 8 ;

--获取当前花朵的个数
function tbYuanding:GetFlowerCount()
	local nCount = 0;
	for _,nId in pairs(self.tbFlower) do
		if KNpc.GetById(nId) then
			nCount = nCount + 1;
		end
	end
	return nCount;
end

function tbYuanding:ReSet()
	tbYuanding.nCurrentStep = 1;	--当前阶段，从1开始
	tbYuanding.tbFlower = {};	--记录花的个数
	tbYuanding.tbStepInfo = 
	{
		[1] = {nCount = 16,nSpace = 5,nBeginDelay = 25},	
		[2] = {nCount = 25,nSpace = 4,nBeginDelay = 15},	
		[3] = {nCount = 30,nSpace = 3,nBeginDelay = 15},	
		[4] = {nCount = 70,nSpace = 2,nBeginDelay = 15},	
	} 
end


function tbYuanding:GetFreePos() -- 获取空闲的花的位置
	for nPos,tbPos in ipairs(self.tbFlowerPos) do
		if not KNpc.GetById(tbPos[3] or 0) then
			return nPos;
		end
	end
	return 0;
end

function tbYuanding:Create(nMapId,nLevel,tbRoom)
	self:ReSet();
	local pNpc = KNpc.Add2(self.nYuanDingId,nLevel,-1,nMapId, self.tbYuandingPos[1] / 32, self.tbYuandingPos[2] / 32,0);
	pNpc.GetTempTable("XoyoGame").tbRoom = tbRoom;
	self.nControlTimerId = Timer:Register(
							self.tbStepInfo[self.nCurrentStep].nBeginDelay * Env.GAME_FPS, 
							self.StepControl, 
							self, 
							pNpc.dwId,
							nMapId);
	self.nFixSkillTimerId = Timer:Register(
							self.nFixSkillDelay * Env.GAME_FPS, 
							self.CastFixSkill, 
							self, 
							pNpc.dwId,
							nMapId);						
	return pNpc;
end

function tbYuanding:CastFixSkill(nNpcId,nMapId)
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		for i = 1,#self.tbFlowerPos do
			pNpc.CastSkill(self.tbFixSkillId[i],5,self.tbFlowerPos[i][1],self.tbFlowerPos[i][2],1);
		end
	end
end

function tbYuanding:StepControl(nNpcId,nMapId)
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		local tbRoom = pNpc.GetTempTable("XoyoGame").tbRoom;
		local tbStepInfo = self.tbStepInfo[self.nCurrentStep];
		if tbStepInfo then
			tbRoom:BlackMsg(-1,"我要种花了...");
			tbYuanding.nStepTimerId = Timer:Register(
										tbStepInfo.nSpace * Env.GAME_FPS, 
										self.StepProcess, 
										self, 
										pNpc.dwId,
										nMapId);
		end
		if not tbYuanding.nObserverTimerId then
			tbYuanding.nObserverTimerId = Timer:Register(
										6 * Env.GAME_FPS, 
										self.Observer, 
										self, 
										pNpc.dwId);
		end
		return 0;
	end
	return 0;	
end

function tbYuanding:Observer(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		local nFlowerCount = self:GetFlowerCount();
		local tbRoom = pNpc.GetTempTable("XoyoGame").tbRoom;
		tbRoom:NpcRemoveSkill("boss",self.tbSkillId[4]);	--移除自己的无敌
		tbRoom:NpcRemoveSkill("boss",self.tbSkillId[5]);	--移除自己的狂暴
		if nFlowerCount == 1 then
			pNpc.SendChat("一朵花，祸害众生！");
			tbRoom:NpcCastSkillToPlayer("boss",self.tbSkillId[nFlowerCount],1,1,-1,1);
		elseif nFlowerCount == 2 then
			pNpc.SendChat("两朵花，全部停住！");
			tbRoom:NpcCastSkillToPlayer("boss",self.tbSkillId[nFlowerCount],7,1);
		elseif nFlowerCount == 3 then
			pNpc.SendChat("三朵花，集体赴死！");
			tbRoom:NpcCastSkill("boss",self.tbSkillId[nFlowerCount],1,nil,nil,1);
		elseif nFlowerCount == 4 then
			pNpc.SendChat("四朵花，天下无敌！");
			tbRoom:NpcCastSkill("boss",self.tbSkillId[nFlowerCount],63,nil,nil,1);
		elseif nFlowerCount == 5 then
			pNpc.SendChat("五朵花，哈哈哈哈哈哈哈！");
			tbRoom:NpcCastSkill("boss",self.tbSkillId[nFlowerCount],63,nil,nil,1);	
		end 
	else
		return 0;
	end
end


function tbYuanding:StepProcess(nNpcId,nMapId)
	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		self:AddFlower(nMapId);
		self.tbStepInfo[self.nCurrentStep].nCount = self.tbStepInfo[self.nCurrentStep].nCount - 1;
		if self.tbStepInfo[self.nCurrentStep].nCount <= 0 then
			self.nCurrentStep = self.nCurrentStep + 1;
			if self.nCurrentStep > 4 then
				return 0;
			end
			self.nControlTimerId = Timer:Register(
									self.tbStepInfo[self.nCurrentStep].nBeginDelay * Env.GAME_FPS, 
									self.StepControl, 
									self, 
									pNpc.dwId,
									nMapId);
			return 0;	
		end
	else
		return 0;
	end
end

--增加花朵,按阶段增加
function tbYuanding:AddFlower(nMapId)
	local nCount = self.nCurrentStep;
	local nFlowerCount = self:GetFlowerCount();
	if nFlowerCount < 5 then
		local nPos = self:GetFreePos();
		if nPos == 0 then
			return 0;
		end
		local pNpc = KNpc.Add2(self.nFlowerId,100,-1,nMapId, self.tbFlowerPos[nPos][1] / 32, self.tbFlowerPos[nPos][2] / 32,0);
		table.insert(self.tbFlower,pNpc.dwId);
		self.tbFlowerPos[nPos][3] = pNpc.dwId;
	end
end

function tbYuanding:OnDeath(pKiller)
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

--------------------------房间逻辑-----------------------------

Require("\\script\\mission\\xoyogame\\room_base.lua");

XoyoGame.RoomBaiCaoYuan = Lib:NewClass(XoyoGame.BaseRoom);

local RoomBaiCaoYuan = XoyoGame.RoomBaiCaoYuan;

function RoomBaiCaoYuan:CreateNpc()
	local nLevel = self:GetAverageLevel();
	nLevel = self:GetMonsterLevel(nLevel);
	local pNpc = Npc:GetClass("baicaoyuanding"):Create(self.nMapId,nLevel,self);
	self:AddNpcInGroup(pNpc, "boss");
end


function RoomBaiCaoYuan:Clear()
	if self.tbTeam[1].bIsWiner ~= 1 then
		self:DelNpc("boss");
	end
	ClearMapNpcWithName(self.nMapId,"百草园的花");
end

function RoomBaiCaoYuan:OnInitRoom()
	ClearMapObj(self.nMapId);
end

function RoomBaiCaoYuan:End()
	self:Clear();
	self:MovieDialog(-1, "<npc=7335>:我的花......你们.....");
	self.tbTeam[1].bIsWiner = 1;
	self:CloseInfo(-1);
	self:SetTagetInfo(-1,"任务完成");
	self:ChangeFight(-1,0,Player.emKPK_STATE_PRACTISE);
	self:AddGouHuo(2, 150, "gouhuo", "85_gouhuo_lv7");
	self:RoomLevelUp();
end

function RoomBaiCaoYuan:OnClose()
	self:Clear();
end