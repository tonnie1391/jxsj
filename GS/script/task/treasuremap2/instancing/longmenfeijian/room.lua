-- 文件名　：room.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-10-26 19:05:40
-- 描述：龙门飞剑logic

local tbInstance = TreasureMap2:GetInstancingBase(6);
tbInstance.tbLogicRoom = tbInstance.tbLogicRoom or {};
local tbRoom = tbInstance.tbLogicRoom;

local preEnv = _G	 
setfenv(1,tbRoom)
-----------------------define---------------------------
-------room 1--------------------
tbDefenseEnemy = {
	{9778,2,
		{50560/32,104160/32},
		{50656/32,104256/32},
		{50784/32,103968/32},
		{50880/32,104064/32},
		{50752/32,104352/32},
		{50976/32,104160/32}
	},
};	--守兵

tbHorseEnemey = {
	{9779,2,
		{49568/32,102752/32},
		{49472/32,102624/32},
		{49568/32,102528/32},
		{49728/32,102336/32},
		{49824/32,102496/32},
		{49760/32,102592/32},
		{49664/32,102688/32},
		{49664/32,102432/32},
	},
};		--骑兵

tbHorseCallNpc = {
	{9781,0,
		{49568/32,101952/32},
		{49632/32,102208/32},
		{49696/32,101728/32},
		{49888/32,101888/32},
		{49856/32,102144/32},
	},
};	--召唤npc

tbBossStep1	  = {
	{9780,10,
		{49728/32,101984/32},
	},
};		--曹公公

tbBossStep1Percent = {70,40,10};	--召唤npc的血量

-------room 2-------------------
tbEnterNpcStep2 = {
	{9782,0,
		{48704/32,101824/32},
	},	
};	--荆棘林入口的提示npc

tbEnemyStep2 = {
	{9783,1,
		{47296/32,99968 /32},
		{47488/32,101216/32},
		{47168/32,100832/32},
		{48032/32,99264 /32},
		{47616/32,100416/32},
		{47904/32,100896/32},
		{48224/32,100288/32},
		{48416/32,99648 /32},
		{48576/32,100960/32},
		{48160/32,101632/32},	
	},
};	--刺客

tbDropGrassGDPL = {
	{18,1,1510,4},
	{18,1,1510,5}
};	--掉落的两种草药的gdpl

tbGrass = {
	{9784,0,
		{48000/32,100448/32},
		{48512/32,100288/32},
		{48736/32,100512/32},
	},
	{9785,0,
		{48032/32,98912/32},
		{47904/32,99616/32},
		{48320/32,99264/32},
	},
	{9786,0,
		{47264/32,100832/32},
		{47136/32,101568/32},
		{47936/32,101888/32},
	},
};	--草药，采集

tbGrassItem = 
{
	[9784] = {18,1,1510,1},
	[9785] = {18,1,1510,2},
	[9786] = {18,1,1510,3},
};

tbGrassBottle = {
	{9787,0,{47520/32,99584/32}},
};	--交草药的npc

nNeedGrassCount = 5;		--需要5种草药

------room 3 --------------------
tbEnterNpcStep3 = {
	{9792,0,{46848/32,99424/32}},
};	--引导npc

tbBone = {
	{9793,0,
		{45888/32,98880 /32},
		{46048/32,98816 /32},
		{46368/32,99904 /32},
		{46496/32,100000/32},
		{46272/32,99360 /32},
		{46912/32,97824 /32},
		{47072/32,97952 /32},
		{47456/32,98592 /32},
	},
};			--骨头，采集解毒

tbBossStep3 = {
	{9794,15,{46752/32,98880/32}},
};		--古族恶煞

tbBossStep3CallNpc = {	
	9795,0,
	{46752/32,98560/32},
	{46912/32,98752/32},
	{46912/32,99040/32},
	{46752/32,99200/32},
	{46592/32,99040/32},
	{46592/32,98720/32},
};	--boss摆阵的召唤npc,比较特殊

tbEnterTalkContent = {
	"这…这是古族最歹毒的阵法，你果然还忘不了他？",
	"他是为你而死的！他要发狂了！你们快躲进法阵！",
	"他的骨头！周围白色药骨能制住你们体内剧毒！",
};--喊话内容

------room 4--------------------
tbEnterNpcStep4 = {
	{9796,0,{45952/32,95520/32}},	
};	--告诉玩家开启机关顺序的npc

tbBox = {
	{9797,0,
		{46368/32,92704/32},
		{46176/32,93728/32},
		{46464/32,94080/32},
		{46240/32,93312/32},
		{46912/32,92832/32},
		{46592/32,92384/32},
		{46912/32,93408/32},
		{46848/32,94272/32},
		{46656/32,94752/32},
		{47392/32,92192/32},
		{47456/32,93856/32},
		{47360/32,94432/32},
		{47968/32,92096/32},
		{47872/32,93152/32},
		{47648/32,92320/32},
		{47872/32,93792/32},
		{47648/32,94272/32},
		{48224/32,93760/32},
	},
};				--宝箱

tbOpenSwitch = {
	{9798,0,
		{46240/32,92736/32},
		{46720/32,93440/32},
		{47552/32,92032/32},
		{47264/32,94464/32},
		{48192/32,93600/32},
	},
};		--机关

tbEnemyStep3 = {
	{9799,2,
		{46400/32,93920/32},
		{46080/32,93728/32},
		{46432/32,93632/32},
		{46688/32,93824/32},
		{46784/32,94784/32},
	}, 
	{9800,2,
		{46080/32,93376/32},
		{46208/32,94048/32},
		{46240/32,94624/32},
		{46400/32,94784/32},
		{46304/32,94240/32},
	},  
	{9801,2,
		{46624/32,93568/32},
		{46848/32,94112/32},
		{47040/32,94080/32},
		{47072/32,94304/32},
		{47040/32,94656/32},
	},
};		--小怪

nOpenBoxMaxCount  = 2;	--每个人开启宝箱次数

nBoxOpenedMaxCount = 1;	--每个箱子最开的开启次数

tbSwitchName = {"Cung","Thương","Giác","Vũ","Chủy"};	--机关名字

------room 5 ------------------
tbBossStep5 = {
	{9802,20,{49216/32,87392/32}},
};		--月姬

tbEnemyStep5 = {
	{9803,4,
		{48512/32,88416/32},
		{48160/32,88256/32},
		{48864/32,88416/32},
		{48960/32,88832/32},
		{48640/32,88896/32},
	},
};		--月姬随从

tbBossStep5AiPos = {
	{48960,87776},
	{48864,88608},
	{48576,89504},
	{48704,90304},
	{49408,90880},
	{49856,91744},
};	--护送的路线

tbHusongNpc = {
	{9805,0,{49216/32,87392/32}},
};		--护送npc

tbRemoveGrass = {
	{9804,0,{48672/32,87808/32}},	
};		--去除buff的npc

------room 6------------------
tbEnemyStep6 = {
	{9806,2,
		{50080/32,92192/32},
		{50080/32,92384/32},
		{50144/32,92640/32},
		{50208/32,92192/32},
		{50432/32,92288/32},
		{50272/32,92416/32},	
	},	
};		--小怪

tbCallNpcStep6 = {
	{9807,0,
		{50368/32,92800/32},
		{50656/32,92448/32},
		{50976/32,92800/32},
		{50688/32,93184/32},
	},
};	--自爆召唤npc

tbBossStep6 = {
	{9808,30,{50688/32,92800/32}},
};		--镖局分舵boss

tbBossStep6Children = {
	{9809,0,{50624/32,92768/32}},
	{9810,0,{50688/32,92672/32}},
};	--分舵boss的分身

tbBossCallChildrenPercent = {50};	--分身的血量

------room 7------------------
tbTransferPos = {52064/32,96320/32};		--传送到室内的pos

tbTransferNpc = {
	{9811,0,{50848/32,92064/32}},	
};		--传送至室内的npc

tbEnemyStep7 = {
	{9814,2,
		{52000/32,96064/32},
		{52192/32,95936/32},
		{52160/32,96352/32},
		{52224/32,96160/32},
		{52384/32,96576/32},
		{52384/32,96320/32},
	},
	{9812,2,
		{52032/32,96192/32},
		{52672/32,96448/32},
	},
	{9813,2,
		{52352/32,96096/32},
	},	
};		--小怪

tbBossStep7 = {
	{9815,40,{53056/32,95264/32}},
};		--客栈boss

tbYuejiEnemy = {
	{9816,17,{53152/32,95296/32}},
};		--客栈内月姬

nCallNpcStep7TemplateId = 9817;	--舞娘，召唤怪

preEnv.setfenv(1,preEnv)
----------------------define end------------------------


----------------------logic-----------------------------
function tbRoom:InitRoom(tbBase)
	if not tbBase then
		print("Room base init error,longmenfeijian");
	else
		self.tbBase = tbBase;
		self:ResetVar();
	end
end

--清空并初始化一些变量
function tbRoom:ResetVar()
	self.tbTrapOpenState = {0,0,0,0,0,0};	--trap点是否可以通过
	self.nStepId = 1;						--当前是在第几个阶段
	self.tbHasGiveGrass = {};				--已经交过的草药
	self.tbStep3CallNpc = {};	
	for i = 1 , #self.tbBossStep3CallNpc - 2 do
		self.tbStep3CallNpc[i] = 0;
	end
	self.tbGiveGrassName = {};
	for i = 1, 5 do
		local szName = KItem.GetNameById(18,1,1510,i);
		self.tbGiveGrassName[szName] = 1;
	end
	self.tbOpenSwitchStep4Order = {};	--开启的次序
	self:ResetStep4Switch();
end

function tbRoom:ResetStep4Switch()
	self.tbNeedOpenStep4Order = {};	--需要开启的次序
	local tbOrder = {};
	for i = 1 ,#self.tbSwitchName do
		tbOrder[i] = i;
	end
	for i = 1,#tbOrder do
		local nPos = MathRandom(#tbOrder);
		local nNum = tbOrder[nPos];
		table.insert(self.tbNeedOpenStep4Order,nNum);
		table.remove(tbOrder,nPos);
	end
end

function tbRoom:StartRoom()
	self:StartStep1();	
end

function tbRoom:StartStep1()
	self.nDefenseEnemyCount = 0;
	local nNpcLevel =  	TreasureMap2.TEMPLATE_LIST[self.tbBase.nTreasureId].tbNpcLevel[self.tbBase.nTreasureLevel];
	for _,tbInfo in pairs(self.tbDefenseEnemy) do
		local nTemplateId = tbInfo[1];
		local nScore = tbInfo[2] or 0;
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,nNpcLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						Npc:RegPNpcOnDeath(pNpc,self.OnDefenseEnemyDeath,self); 
						pNpc.GetTempTable("TreasureMap2").nNpcScore =  nScore * TreasureMap2.LEVEL_RATE[self.tbBase.nTreasureLevel];
						self.nDefenseEnemyCount = self.nDefenseEnemyCount + 1;
					end
				end
			end
		end
	end
end

function tbRoom:OnDefenseEnemyDeath()
	self.nDefenseEnemyCount = self.nDefenseEnemyCount - 1;
	self.tbBase:AddInstanceScore(him.GetTempTable("TreasureMap2").nNpcScore or 0);
	self.tbBase:AddKillNpcNum();
	if self.nDefenseEnemyCount <= 0 then
		self.tbTrapOpenState[1] = 1;	--可以通过城门
		self.tbBase:DelTrapNpc(1);
		local szMsg = string.format("Cấp báo────Có kẻ lạ đột nhập!");
		self.tbBase:SendBlackBoardMsgByTeam(szMsg);
		self:AddBossStep1();	
	end
end

--刷曹公公和骑兵
function tbRoom:AddBossStep1()
	local nNpcLevel =  	TreasureMap2.TEMPLATE_LIST[self.tbBase.nTreasureId].tbNpcLevel[self.tbBase.nTreasureLevel];
	for _,tbInfo in pairs(self.tbHorseEnemey) do
		local nTemplateId = tbInfo[1];
		local nScore = tbInfo[2] or 0;
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,nNpcLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						pNpc.GetTempTable("TreasureMap2").nNpcScore =  nScore * TreasureMap2.LEVEL_RATE[self.tbBase.nTreasureLevel];
						Npc:RegPNpcOnDeath(pNpc,self.OnHorseEnemyDeath,self); 
					end
				end
			end
		end
	end
	for _,tbInfo in pairs(self.tbBossStep1) do
		local nTemplateId = tbInfo[1];
		local nScore = tbInfo[2] or 0;
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,nNpcLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						Npc:RegPNpcOnDeath(pNpc,self.OnBossStep1Death,self); 
						pNpc.GetTempTable("TreasureMap2").nNpcScore =  nScore * TreasureMap2.LEVEL_RATE[self.tbBase.nTreasureLevel];
						for _,nPercent in pairs(self.tbBossStep1Percent) do
							Npc:RegPNpcLifePercentReduce(pNpc,nPercent,self.OnBossStep1Percent,self,pNpc.dwId); 
						end
					end
				end
			end
		end
	end
end

function tbRoom:OnHorseEnemyDeath()
	self.tbBase:AddInstanceScore(him.GetTempTable("TreasureMap2").nNpcScore or 0);
	self.tbBase:AddKillNpcNum();
end

function tbRoom:OnBossStep1Death()
	self.tbBase:AddKillBossNum(him);
	self.tbTrapOpenState[2] = 1;	--可以通过城门
	self.tbBase:DelTrapNpc(2);
	local szMsg = string.format("Minh ước không có trong người Tào Công Công, vượt rừng gai để điều tra.");
	self.tbBase:SendBlackBoardMsgByTeam(szMsg);
	self:AddNpcStep2();	--第二阶段
end

function tbRoom:OnBossStep1Percent(nId)
	local pNpc = KNpc.GetById(nId);
	if not pNpc then
		return 0;
	end
	for _,tbInfo in pairs(self.tbHorseCallNpc) do
		local nTemplateId = tbInfo[1];
		local nScore = tbInfo[2];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					KNpc.Add2(nTemplateId,pNpc.nLevel - 10,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
				end
			end
		end
	end
end


--第二阶段npc
function tbRoom:AddNpcStep2()
	self.nStepId = 2;
	local nNpcLevel = TreasureMap2.TEMPLATE_LIST[self.tbBase.nTreasureId].tbNpcLevel[self.tbBase.nTreasureLevel];
	for _,tbInfo in pairs(self.tbEnterNpcStep2) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					KNpc.Add2(nTemplateId,nNpcLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
				end
			end
		end
	end
	for _,tbInfo in pairs(self.tbEnemyStep2) do
		local nTemplateId = tbInfo[1];
		local nScore = tbInfo[2] or 0;
		if nTemplateId then
			for nIndex,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local nRand = nIndex % 2;
					local pNpc = KNpc.Add2(nTemplateId,nNpcLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						if nRand == 0 then
							local tbGDPL = self.tbDropGrassGDPL[1];
							pNpc.AddDropItem(tbGDPL[1],tbGDPL[2],tbGDPL[3],tbGDPL[4],-1);
						else
							local tbGDPL = self.tbDropGrassGDPL[2];
							pNpc.AddDropItem(tbGDPL[1],tbGDPL[2],tbGDPL[3],tbGDPL[4],-1);
						end
						Npc:RegPNpcOnDeath(pNpc,self.OnEnemyStep2Death,self); 
						pNpc.GetTempTable("TreasureMap2").nNpcScore =  nScore * TreasureMap2.LEVEL_RATE[self.tbBase.nTreasureLevel];
					end
				end
			end
		end
	end
	for _,tbInfo in pairs(self.tbGrass) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					KNpc.Add2(nTemplateId,nNpcLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
				end
			end
		end
	end
	for _,tbInfo in pairs(self.tbGrassBottle) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					KNpc.Add2(nTemplateId,nNpcLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
				end
			end
		end
	end
end

function tbRoom:OnEnemyStep2Death()
	self.tbBase:AddInstanceScore(him.GetTempTable("TreasureMap2").nNpcScore or 0);
	self.tbBase:AddKillNpcNum();
end

function tbRoom:ProcessGrass()
	if #self.tbHasGiveGrass ~= self.nNeedGrassCount then
		local szMsg = string.format("Cần %s thảo mộc, tiếp tục tìm kiếm!",self.nNeedGrassCount - #self.tbHasGiveGrass);
		self.tbBase:SendBlackBoardMsgByTeam(szMsg);
	else
		self.tbTrapOpenState[3] = 1;	--可以通过城门
		self.tbBase:DelTrapNpc(3);
		self:StartStep3();
		local szMsg = "Hương thuốc bốc lên từ lò luyện, một làn sương độc tỏa ra.";
		self.tbBase:SendBlackBoardMsgByTeam(szMsg);
	end	
end


function tbRoom:StartStep3()
	local nNpcLevel =  	TreasureMap2.TEMPLATE_LIST[self.tbBase.nTreasureId].tbNpcLevel[self.tbBase.nTreasureLevel];
	for _,tbInfo in pairs(self.tbEnterNpcStep3) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,nNpcLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					self.nEnterNpcStep3Id = pNpc.dwId;
				end
			end
		end
	end
end

function tbRoom:ProcessStep3()
	self.nStepId = 3;
	local pNpc = KNpc.GetById(self.nEnterNpcStep3Id);
	self.tbBase:NpcTalk(pNpc.dwId,"Sự ngu dốt của các ngươi đã giúp Lục Mạnh Ngôn hồi sinh.");
	local nNpcLevel = TreasureMap2.TEMPLATE_LIST[self.tbBase.nTreasureId].tbNpcLevel[self.tbBase.nTreasureLevel];
	for _,tbInfo in pairs(self.tbBossStep3) do
		local nTemplateId = tbInfo[1];
		local nScore = tbInfo[2] or 0;
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,nNpcLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						Npc:RegPNpcOnDeath(pNpc,self.OnBossStep3Death,self); 
						pNpc.GetTempTable("TreasureMap2").nNpcScore =  nScore * TreasureMap2.LEVEL_RATE[self.tbBase.nTreasureLevel];
						self.nBossStep3Id = pNpc.dwId;
					end
				end
			end
		end
	end
	for _,tbInfo in pairs(self.tbBone) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					KNpc.Add2(nTemplateId,nNpcLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
				end
			end
		end
	end
	local pBoss = KNpc.GetById(self.nBossStep3Id);
	if pBoss then
		self.nStep3CallNpcTimer = Timer:Register(10 * Env.GAME_FPS,self.OnCallNpcStep3,self);
		self.nStep3EnterNpcTalkTimer = Timer:Register(15 * Env.GAME_FPS,self.OnTalkStep3,self);
	end
end

function tbRoom:OnTalkStep3()
	local tbContent = self.tbEnterTalkContent;
	if not self.nStep3TalkState then
		self.nStep3TalkState = 1;
	end
	local pNpc = KNpc.GetById(self.nEnterNpcStep3Id);
	if pNpc then
		self.tbBase:NpcTalk(pNpc.dwId,tbContent[self.nStep3TalkState]);
		self.nStep3TalkState = self.nStep3TalkState + 1;
		if self.nStep3TalkState > #tbContent then
			self.nStep3TalkState = 1;
		end
		return 10 * Env.GAME_FPS;
	else
		self.nStep3EnterNpcTalkTimer = 0;
		return 0;
	end
end


function tbRoom:OnCallNpcStep3()
	local nNpcLevel = TreasureMap2.TEMPLATE_LIST[self.tbBase.nTreasureId].tbNpcLevel[self.tbBase.nTreasureLevel];
	local pBoss = KNpc.GetById(self.nBossStep3Id);
	if not pBoss then
		self.nStep3CallNpcTimer = 0;
		return 0;
	end
	for i = 1 , #self.tbBossStep3CallNpc - 2 do
		local pNpc = KNpc.GetById(self.tbStep3CallNpc[i]);
		if not pNpc then
			pNpc = KNpc.Add2(self.tbBossStep3CallNpc[1],nNpcLevel,-1,self.tbBase.nMapId,self.tbBossStep3CallNpc[i + 2][1],self.tbBossStep3CallNpc[i + 2][2]);
			self.tbStep3CallNpc[i] = pNpc.dwId;
			break;
		end
	end
	local nCallCount = 0;
	for _,nId in pairs(self.tbStep3CallNpc) do
		if KNpc.GetById(nId) then
			nCallCount = nCallCount + 1;
		end
	end	
	if nCallCount >= #self.tbBossStep3CallNpc - 2 then
		--boss放大招
		local _,nX,nY = pBoss.GetWorldPos();
		pBoss.CastSkill(2398,4,nX * 32,nY *32,1);
		for nIndex,nId in pairs(self.tbStep3CallNpc) do
			local pNpc = KNpc.GetById(nId);
			if pNpc then
				pNpc.Delete();
				self.tbStep3CallNpc[nIndex] = 0;
			end
		end
	end
	return 10 * Env.GAME_FPS; 
end


function tbRoom:OnBossStep3Death()
	if self.nStep3EnterNpcTalkTimer and self.nStep3EnterNpcTalkTimer > 0 then
		Timer:Close(self.nStep3EnterNpcTalkTimer);
		self.nStep3EnterNpcTalkTimer = 0;
	end
	if self.nStep3CallNpcTimer and self.nStep3CallNpcTimer > 0 then
		Timer:Close(self.nStep3CallNpcTimer);
		self.nStep3CallNpcTimer = 0;
	end
	for nIndex,nId in pairs(self.tbStep3CallNpc) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			pNpc.Delete();
			self.tbStep3CallNpc[nIndex] = 0;
		end
	end
	local tbPlayer = self.tbBase:GetPlayerList();
	for _,pPlayer in pairs(tbPlayer) do
		if pPlayer and pPlayer.GetSkillState(2407) > 0 then	--如果boss死了，清除毒buff
			pPlayer.RemoveSkillState(2407);
		end
	end
	local pNpc = KNpc.GetById(self.nEnterNpcStep3Id);
	if pNpc then
		self.tbBase:NpcTalk(pNpc.dwId,"Khá lắm... Ha..ha...!");
	end
	self.tbBase:AddKillBossNum(him);
	self.tbTrapOpenState[4] = 1;	--可以通过城门
	self.tbBase:DelTrapNpc(4);
	self:StartStep4();	--开启第4关
	local szMsg = string.format("Địa hình phía trước có vẻ hiểm trở, hãy tiến lên nào!");
	self.tbBase:SendBlackBoardMsgByTeam(szMsg);
end


function tbRoom:StartStep4()
	self.nStepId = 4;
	if not self.nEnemyStep4Count then
		self.nEnemyStep4Count = 0;
	end
	local nNpcLevel = TreasureMap2.TEMPLATE_LIST[self.tbBase.nTreasureId].tbNpcLevel[self.tbBase.nTreasureLevel];
	for _,tbInfo in pairs(self.tbEnterNpcStep4) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					KNpc.Add2(nTemplateId,nNpcLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
				end
			end
		end
	end
	for _,tbInfo in pairs(self.tbEnemyStep3) do
		local nTemplateId = tbInfo[1];
		local nScore = tbInfo[2] or 0;
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,nNpcLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						self.nEnemyStep4Count = self.nEnemyStep4Count + 1;
						Npc:RegPNpcOnDeath(pNpc,self.OnEnemyStep4Death,self); 
						pNpc.GetTempTable("TreasureMap2").nNpcScore =  nScore * TreasureMap2.LEVEL_RATE[self.tbBase.nTreasureLevel];
					end
				end
			end
		end
	end
end

function tbRoom:OnEnemyStep4Death()
	self.tbBase:AddInstanceScore(him.GetTempTable("TreasureMap2").nNpcScore or 0);
	self.tbBase:AddKillNpcNum();
	self.nEnemyStep4Count = self.nEnemyStep4Count - 1;
	if self.nEnemyStep4Count <= 0 then
		self:AddStep4OtherNpc();
	end
end

function tbRoom:AddStep4OtherNpc()
	local nNpcLevel = TreasureMap2.TEMPLATE_LIST[self.tbBase.nTreasureId].tbNpcLevel[self.tbBase.nTreasureLevel];
	for _,tbInfo in pairs(self.tbOpenSwitch) do
		local nTemplateId = tbInfo[1];
		local tbNewPos = {};
		for _,tbPos in pairs(tbInfo) do
			if type(tbPos) == "table" then
				table.insert(tbNewPos,tbPos);	
			end
		end
		if nTemplateId then
			Lib:SmashTable(tbNewPos);	--打乱刷出顺序
			for nIndex,tbPos in pairs(tbNewPos) do
				local pNpc = KNpc.Add2(nTemplateId,nNpcLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
				if pNpc then
					pNpc.szName = self.tbSwitchName[nIndex];
					pNpc.SetTitle("<color=green>Long Môn Ngũ Âm Trận<color>");
					pNpc.GetTempTable("TreasureMap2").nIndex = nIndex;
					pNpc.Sync();
				end
			end
		end
	end
	for _,tbInfo in pairs(self.tbBox) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,nNpcLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						pNpc.GetTempTable("TreasureMap2").nMaxOpenedCount = self.nBoxOpenedMaxCount;
					end
				end
			end
		end
	end
end

function tbRoom:ProcessOpenSwitch(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local nIndex = pNpc.GetTempTable("TreasureMap2").nIndex or 0;
	table.insert(self.tbOpenSwitchStep4Order,nIndex);
	local nIsOrderd = 1;
	for i = 1,#self.tbOpenSwitchStep4Order do
		if self.tbOpenSwitchStep4Order[i] ~= self.tbNeedOpenStep4Order[i] then
			nIsOrderd = 0;
			break;
		end
	end
	if nIsOrderd ~= 1 then
		--黑条提示开启错误
		self.tbBase:SendMsgByTeam("Cơ quan rắn chắc không chút lung lay!");
		self.tbBase:SendBlackBoardMsgByTeam("Cơ quan rắn chắc không chút lung lay!");
		self.tbOpenSwitchStep4Order = {};
	else
		if #self.tbOpenSwitchStep4Order == #self.tbNeedOpenStep4Order then	--按顺序开启过了
			self.tbTrapOpenState[5] = 1;	--可以通过城门
			self.tbBase:DelTrapNpc(5);
			self:StartStep5();	--开启第5关
			self.tbBase:SendBlackBoardMsgByTeam("Một tiếng nổ lớn, lối ra đã xuất hiện cuối mê cung!");
		end
	end
end



function tbRoom:StartStep5()
	self.nStepId = 5;
	local nNpcLevel = TreasureMap2.TEMPLATE_LIST[self.tbBase.nTreasureId].tbNpcLevel[self.tbBase.nTreasureLevel];
	if not self.nEnemyStep5Count then
		self.nEnemyStep5Count = 0;
	end
	for _,tbInfo in pairs(self.tbRemoveGrass) do	--解除buff的npc
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,nNpcLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						self.nRemoveBuffStep5NpcId = pNpc.dwId;
					end
				end
			end
		end
	end
	for _,tbInfo in pairs(self.tbEnemyStep5) do
		local nTemplateId = tbInfo[1];
		local nScore = tbInfo[2] or 0;
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,nNpcLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						Npc:RegPNpcOnDeath(pNpc,self.OnEnemyStep5Death,self); 
						pNpc.GetTempTable("TreasureMap2").nNpcScore =  nScore * TreasureMap2.LEVEL_RATE[self.tbBase.nTreasureLevel];
						self.nEnemyStep5Count = self.nEnemyStep5Count + 1;
					end
				end
			end
		end
	end

end


function tbRoom:AddBossStep5()
	local nNpcLevel = TreasureMap2.TEMPLATE_LIST[self.tbBase.nTreasureId].tbNpcLevel[self.tbBase.nTreasureLevel];
	for _,tbInfo in pairs(self.tbBossStep5) do
		local nTemplateId = tbInfo[1];
		local nScore = tbInfo[2];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,nNpcLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						Npc:RegPNpcOnDeath(pNpc,self.OnBossStep5Death,self); 
						pNpc.GetTempTable("TreasureMap2").nNpcScore =  nScore * TreasureMap2.LEVEL_RATE[self.tbBase.nTreasureLevel];
						self.nBossStep5Id = pNpc.dwId;
					end
				end
			end
		end
	end
	local pBoss = KNpc.GetById(self.nBossStep5Id);
	if pBoss then
		self.nCastLunhuiTimer = Timer:Register(30 * Env.GAME_FPS,self.OnCastLunhui,self);
	end
end


function tbRoom:OnCastLunhui()
	local pBoss = KNpc.GetById(self.nBossStep5Id);
	if not pBoss then
		self.nCastLunhuiTimer = 0;
		return 0;
	end 
	if not self.tbSufferBuffPlayer then
		self.tbSufferBuffPlayer = {};
	end
	local tbPlayer = KNpc.GetAroundPlayerList(pBoss.dwId,40);	--获取boss身边40格子的玩家
	local _,x,y = pBoss.GetWorldPos();
	pBoss.CastSkill(2408,1,x * 32 ,y * 32,1);
	self.tbBase:NpcTalk(pBoss.dwId,"Bài hát kết thúc, ai sẽ là người nói lời tiễn biệt?");
	if #tbPlayer > 0 then
		for _,pPlayer in pairs(tbPlayer) do
			pPlayer.AddSkillState(2410,1,0,20 * Env.GAME_FPS);
			table.insert(self.tbSufferBuffPlayer,pPlayer.nId);		
		end
	end
	if self.nScanPlayerBuffTimer and self.nScanPlayerBuffTimer > 0 then
		Timer:Close(self.nScanPlayerBuffTimer);
		self.nScanPlayerBuffTimer = 0;
	end
	local pRemoveBuffNpc = KNpc.GetById(self.nRemoveBuffStep5NpcId);
	if pRemoveBuffNpc then
		self.tbBase:NpcTalk(pRemoveBuffNpc.dwId,"Bài hát là lời nguyền rủa, mau tìm cách hóa giải.");
	end
	self.nScanPlayerBuffTimer = Timer:Register(19 * Env.GAME_FPS,self.OnScanPlayerBuff,self);	--小于buff 1秒，看不出
	return 30 * Env.GAME_FPS;
end

function tbRoom:OnScanPlayerBuff()
	for _,nId in pairs(self.tbSufferBuffPlayer) do
		local pPlayer = KPlayer.GetPlayerObjById(nId);
		if pPlayer and pPlayer.GetSkillState(2410) > 0 then
			local _,nX,nY = pPlayer.GetWorldPos();
			pPlayer.CastSkill(2309,20,nX*32, nY*32,1);	
		end
	end
	self.nScanPlayerBuffTimer = 0;
	self.tbSufferBuffPlayer = {};
	return 0;
end

function tbRoom:OnBossStep5Death()
	if self.nCastLunhuiTimer and self.nCastLunhuiTimer > 0 then
		Timer:Close(self.nCastLunhuiTimer);
		self.nCastLunhuiTimer = 0;
	end
	if self.nScanPlayerBuffTimer and self.nScanPlayerBuffTimer > 0 then
		Timer:Close(self.nScanPlayerBuffTimer);
		self.nScanPlayerBuffTimer = 0;
	end
	if self.tbSufferBuffPlayer then
		for _,nId in pairs(self.tbSufferBuffPlayer) do
			local pPlayer = KPlayer.GetPlayerObjById(nId);
			if pPlayer and pPlayer.GetSkillState(2410) > 0 then
				pPlayer.RemoveSkillState(2410);
			end
		end
	end
	self.tbSufferBuffPlayer = {};
	self.tbBase:AddKillBossNum(him);
	self:AddProtectNpc();			--增加护送npc
end

function tbRoom:OnEnemyStep5Death()
	self.tbBase:AddInstanceScore(him.GetTempTable("TreasureMap2").nNpcScore or 0);
	self.tbBase:AddKillNpcNum();
	self.nEnemyStep5Count = self.nEnemyStep5Count - 1;
	if self.nEnemyStep5Count <= 0 then
		self:AddBossStep5();
		self.tbBase:SendBlackBoardMsgByTeam("Ai dám nhìn trộm Nguyệt Cơ tắm suối!!!");
	end
end


function tbRoom:AddProtectNpc()
	local nNpcLevel = TreasureMap2.TEMPLATE_LIST[self.tbBase.nTreasureId].tbNpcLevel[self.tbBase.nTreasureLevel];
	for _,tbInfo in pairs(self.tbHusongNpc) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,nNpcLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						self.nStartWalkTimer = Timer:Register(Env.GAME_FPS,self.StartWalk,self,pNpc.dwId);
						pNpc.SetCurCamp(0);
					end
				end
			end
		end
	end
end

function tbRoom:StartWalk(nId)
	local pNpc = KNpc.GetById(nId);
	if not pNpc then
		self:OnBossStep5Arrive(nId);
		self.nStartWalkTimer = 0;
		return 0;
	end
	local tbAiPos = self.tbBossStep5AiPos;
	pNpc.AI_ClearPath();
	for i = 1,#tbAiPos do
		pNpc.AI_AddMovePos(tbAiPos[i][1],tbAiPos[i][2]);
	end
	pNpc.SetNpcAI(9,0,0,0,0,0,0,0);
	pNpc.GetTempTable("Npc").tbOnArrive = {self.OnBossStep5Arrive,self,pNpc.dwId};
	self.tbBase:NpcTalk(pNpc.dwId,"Vị thiếu hiệp chớ giận, Nguyệt Cơ đã hiểu lầm.");
	self.tbBase:SendBlackBoardMsgByTeam("Nguyệt Cơ nguyện dẫn đường đến Long Môn Tiêu Cục");
	self.nStartWalkTimer = 0;
	return 0;	
end


function tbRoom:OnBossStep5Arrive(nId)
	local pNpc = KNpc.GetById(nId);
	if pNpc then
		pNpc.Delete();
	end
	self.tbTrapOpenState[6] = 1;	--可以通过城门
	self.tbBase:DelTrapNpc(6);
	self:StartStep6(nId);
	self.tbBase:SendBlackBoardMsgByTeam("Đã đến Long Môn Tiêu Cục, dường như Vũ Sinh không có ở đây.");
end


function tbRoom:StartStep6()
	self.nStepId = 6;
	local nNpcLevel = TreasureMap2.TEMPLATE_LIST[self.tbBase.nTreasureId].tbNpcLevel[self.tbBase.nTreasureLevel];
	for _,tbInfo in pairs(self.tbBossStep6) do
		local nTemplateId = tbInfo[1];
		local nScore = tbInfo[2] or 0;
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,nNpcLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						for _,nPercent in pairs(self.tbBossCallChildrenPercent) do
							Npc:RegPNpcLifePercentReduce(pNpc,nPercent,self.OnBossStep6Percent,self); 
						end
						Npc:RegPNpcOnDeath(pNpc,self.OnBossStep6Death,self); 
						pNpc.GetTempTable("TreasureMap2").nNpcScore =  nScore * TreasureMap2.LEVEL_RATE[self.tbBase.nTreasureLevel];
						self.nBossStep6Id = pNpc.dwId;
					end
				end
			end
		end
	end
	for _,tbInfo in pairs(self.tbEnemyStep6) do
		local nTemplateId = tbInfo[1];
		local nScore = tbInfo[2] or 0;
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,nNpcLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						Npc:RegPNpcOnDeath(pNpc,self.OnEnemyStep6Death,self); 
						pNpc.GetTempTable("TreasureMap2").nNpcScore =  nScore * TreasureMap2.LEVEL_RATE[self.tbBase.nTreasureLevel];
					end
				end
			end
		end
	end
	local pNpc = KNpc.GetById(self.nBossStep6Id);
	if pNpc then
		self.nCallSishiStep6Timer = Timer:Register(30 * Env.GAME_FPS,self.OnCallSishiStep6,self);
	end
end

function tbRoom:OnEnemyStep6Death()
	self.tbBase:AddInstanceScore(him.GetTempTable("TreasureMap2").nNpcScore or 0);
	self.tbBase:AddKillNpcNum();
end


function tbRoom:OnCallSishiStep6()
	local pNpc = KNpc.GetById(self.nBossStep6Id);
	if pNpc then
		--黑条提示
		if not self.tbSishiNpc then
			self.tbSishiNpc = {};
		end
		for _,tbInfo in pairs(self.tbCallNpcStep6) do
			local nTemplateId = tbInfo[1];
			if nTemplateId then
				for _,tbPos in pairs(tbInfo) do
					if type(tbPos) == "table" then
						local pNpc = KNpc.Add2(nTemplateId,pNpc.nLevel - 10,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
						if pNpc then
							self.tbBase:NpcTalk(pNpc.dwId,"Tất cả thành viên Long Môn Tiêu Cục không màn sống chết!");
							table.insert(self.tbSishiNpc,pNpc.dwId);
						end
					end
				end
			end
		end
		if self.nSishiCastSkillTimer and self.nSishiCastSkillTimer > 0 then
			Timer:Close(self.nSishiCastSkillTimer);
			self.nSishiCastSkillTimer = 0;
		end
		self.nSishiCastSkillTimer = Timer:Register(Env.GAME_FPS,self.OnSishiCastSkill,self);
		if self.nDelSishiStep6Timer and self.nDelSishiStep6Timer > 0 then
			Timer:Close(self.nDelSishiStep6Timer);
			self.nDelSishiStep6Timer = 0;
		end
		self.nDelSishiStep6Timer = Timer:Register(10 * Env.GAME_FPS,self.OnDelSishiStep6,self);
		return 30 * Env.GAME_FPS;
	else
		self.nCallSishiStep6Timer = 0;
		return 0;
	end
end

function tbRoom:OnSishiCastSkill()
	if not self.tbSishiNpc then
		return 0;
	end
	for _,nId in pairs(self.tbSishiNpc) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			local _,nX,nY = pNpc.GetWorldPos();
			pNpc.CastSkill(2416,6,nX * 32,nY * 32,1);
		end
	end
	self.nSishiCastSkillTimer = 0;
	return 0;
end

function tbRoom:OnDelSishiStep6()	--删除死士
	if not self.tbSishiNpc then
		return 0;
	end
	for _,nId in pairs(self.tbSishiNpc) do
		local pNpc = KNpc.GetById(nId);
		if pNpc then
			pNpc.Delete();
		end
	end
	self.tbSishiNpc = {};
	self.nDelSishiStep6Timer = 0;
	return 0;
end

function tbRoom:OnBossStep6Percent()
	local pNpc = KNpc.GetById(self.nBossStep6Id);
	local nNpcLevel = TreasureMap2.TEMPLATE_LIST[self.tbBase.nTreasureId].tbNpcLevel[self.tbBase.nTreasureLevel];
	if pNpc then
		local tbCallPos = {};
		local tbTemplateId = {};
		local nBossTemplateId = pNpc.nTemplateId;	--记录真boss的模板id
		local nReduceLifePercent = 1 - pNpc.nCurLife / pNpc.nMaxLife;	--要减去的血量
		local nScore = pNpc.GetTempTable("TreasureMap2").nNpcScore or 0;
		for _,tbInfo in pairs(self.tbBossStep6) do
			local nTemplateId = tbInfo[1];
			table.insert(tbTemplateId,nTemplateId);
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					table.insert(tbCallPos,tbPos);
				end
			end
		end
		for _,tbInfo in pairs(self.tbBossStep6Children) do
			local nTemplateId = tbInfo[1];
			table.insert(tbTemplateId,nTemplateId);
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					table.insert(tbCallPos,tbPos);
				end
			end
		end
		Lib:SmashTable(tbCallPos);
		Lib:SmashTable(tbTemplateId);
		pNpc.Delete();
		for i = 1 , #tbTemplateId do
			local pNpc = KNpc.Add2(tbTemplateId[i],nNpcLevel,-1,self.tbBase.nMapId,tbCallPos[i][1],tbCallPos[i][2]);
			if pNpc then
				if pNpc.nTemplateId == nBossTemplateId then	--如果是boss
					Npc:RegPNpcOnDeath(pNpc,self.OnBossStep6Death,self);
					pNpc.GetTempTable("TreasureMap2").nNpcScore =  nScore * TreasureMap2.LEVEL_RATE[self.tbBase.nTreasureLevel];
					self.nBossStep6Id = pNpc.dwId;
				else
					if not self.tbShadowStep6 then
						self.tbShadowStep6 = {};	--记录分身
					end
					table.insert(self.tbShadowStep6,pNpc.dwId);				
				end
				pNpc.ReduceLife(pNpc.nMaxLife * nReduceLifePercent);
			end
		end
	end
end

function tbRoom:OnBossStep6Death()
	if self.nCallSishiStep6Timer and self.nCallSishiStep6Timer > 0 then
		Timer:Close(self.nCallSishiStep6Timer);
		self.nCallSishiStep6Timer = 0;
	end
	if self.nDelSishiStep6Timer and self.nDelSishiStep6Timer > 0 then
		Timer:Close(self.nDelSishiStep6Timer);
		self.nDelSishiStep6Timer = 0;
	end
	if self.nSishiCastSkillTimer and self.nSishiCastSkillTimer > 0 then
		Timer:Close(self.nSishiCastSkillTimer);
		self.nSishiCastSkillTimer = 0;
	end
	if self.tbSishiNpc then
		for _,nId in pairs(self.tbSishiNpc) do
			local pNpc = KNpc.GetById(nId);
			if pNpc then
				pNpc.Delete();
			end
		end
	end
	if self.tbShadowStep6 then	--如果有影子存在就删掉
		for _,nId in pairs(self.tbShadowStep6) do
			local pNpc = KNpc.GetById(nId);
			if pNpc then
				pNpc.Delete();
			end
		end
	end
	self.tbShadowStep6 = {};
	self.tbSishiNpc = {};
	self.tbBase:AddKillBossNum(him);
	self:StartStep7();
	self.tbBase:SendBlackBoardMsgByTeam("Dường như người trong Long Môn Tiêu Cục không biết tên trộm đã vào nhà trọ.");
end

function tbRoom:StartStep7()
	self.nStepId = 7;
	self:AddTransferNpc();	--加进入室内的npc
	self:AddNpc();
end

function tbRoom:AddNpc()
	local nNpcLevel = TreasureMap2.TEMPLATE_LIST[self.tbBase.nTreasureId].tbNpcLevel[self.tbBase.nTreasureLevel];
	for _,tbInfo in pairs(self.tbEnemyStep7) do
		local nTemplateId = tbInfo[1];
		local nScore = tbInfo[2] or 0;
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,nNpcLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						Npc:RegPNpcOnDeath(pNpc,self.OnEnemyStep7Death,self); 
						pNpc.GetTempTable("TreasureMap2").nNpcScore =  nScore * TreasureMap2.LEVEL_RATE[self.tbBase.nTreasureLevel];
					end
				end
			end
		end
	end
	for _,tbInfo in pairs(self.tbYuejiEnemy) do
		local nTemplateId = tbInfo[1];
		local nScore = tbInfo[2] or 0;
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,nNpcLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						self.nYuejiStep7Id = pNpc.dwId;
						pNpc.AddSkillState(999,10,1, 2 * 60 * 60 * Env.GAME_FPS);
						Npc:RegPNpcOnDeath(pNpc,self.OnYuejiStep7Death,self); 
						pNpc.GetTempTable("TreasureMap2").nNpcScore =  nScore * TreasureMap2.LEVEL_RATE[self.tbBase.nTreasureLevel];	
					end
				end
			end
		end
	end
	for _,tbInfo in pairs(self.tbBossStep7) do
		local nTemplateId = tbInfo[1];
		local nScore = tbInfo[2] or 0;
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,nNpcLevel,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
					if pNpc then
						Npc:RegPNpcOnDeath(pNpc,self.OnBossStep7Death,self); 
						pNpc.GetTempTable("TreasureMap2").nNpcScore =  nScore * TreasureMap2.LEVEL_RATE[self.tbBase.nTreasureLevel];
						Npc:RegPNpcLifePercentReduce(pNpc,60,self.OnBossStep7Percent,self); --60%月姬无敌取消
						self.nBossStep7Id = pNpc.dwId;
						self.nCallNpcStep7Timer = Timer:Register(30 * Env.GAME_FPS,self.OnCallNpcStep7,self);
					end
				end
			end
		end
	end
end

function tbRoom:OnYuejiStep7Death()
	self.tbBase:AddKillBossNum(him);
	local pBoss = KNpc.GetById(self.nBossStep7Id);
	if pBoss then
		pBoss.RemoveSkillState(999);
	end
end

function tbRoom:OnCallNpcStep7()
	local pBoss = KNpc.GetById(self.nBossStep7Id);
	if pBoss then
		if not self.tbWuniangNpc then
			self.tbWuniangNpc = {};
		end
		for _,nId in pairs(self.tbWuniangNpc) do
			local pNpc = KNpc.GetById(nId);
			if pNpc then
				pNpc.Delete();
			end
		end
		self.tbWuniangNpc = {};
		local tbPlayer = KNpc.GetAroundPlayerList(pBoss.dwId,40);	--获取boss身边40格子的玩家
		if #tbPlayer > 0 then
			local pPlayer = tbPlayer[MathRandom(#tbPlayer)];
			if pPlayer then
				pPlayer.AddSkillState(2437,10,1, 3 * Env.GAME_FPS);
				local _,x,y = pPlayer.GetWorldPos();
				local tbPos = {};
				for i = -2,2,2 do
					if i ~= 0 then
						table.insert(tbPos,{x + i, y});
						table.insert(tbPos,{x , y + i});
					end
				end
				for i = 1, #tbPos do
					local tb = tbPos[i];
					local pNpc = KNpc.Add2(self.nCallNpcStep7TemplateId,pBoss.nLevel - 10,-1,self.tbBase.nMapId,tb[1],tb[2]);
					if pNpc then
						table.insert(self.tbWuniangNpc,pNpc.dwId);
					end
				end
			end
		end
		return 25 * Env.GAME_FPS;
	else
		self.nCallNpcStep7Timer = 0;
		return 0;
	end
end


function tbRoom:OnBossStep7Percent()
	local pNpc = KNpc.GetById(self.nYuejiStep7Id);
	if pNpc then
		pNpc.RemoveSkillState(999);
		self.nYuejiStep7CastTimer = Timer:Register(30 * Env.GAME_FPS,self.OnYuejiStep7CastSkill,self);
	end
	local pBoss = KNpc.GetById(self.nBossStep7Id);
	if pBoss then
		pBoss.AddSkillState(999,10,1, 2 * 60 * 60 * Env.GAME_FPS);
	end
end

function tbRoom:OnYuejiStep7CastSkill()
	local pNpc = KNpc.GetById(self.nYuejiStep7Id);
	if pNpc then
		local _,nX,nY = pNpc.GetWorldPos();
		pNpc.CastSkill(2412,1,nX * 32,nY * 32,1);
	else
		self.nYuejiStep7CastTimer = 0;
		return 0;
	end
end


function tbRoom:OnEnemyStep7Death()
	self.tbBase:AddInstanceScore(him.GetTempTable("TreasureMap2").nNpcScore or 0);
	self.tbBase:AddKillNpcNum();
end

function tbRoom:AddTransferNpc()
	for _,tbInfo in pairs(self.tbTransferNpc) do
		local nTemplateId = tbInfo[1];
		if nTemplateId then
			for _,tbPos in pairs(tbInfo) do
				if type(tbPos) == "table" then
					local pNpc = KNpc.Add2(nTemplateId,10,-1,self.tbBase.nMapId,tbPos[1],tbPos[2]);
				end
			end
		end
	end
end

function tbRoom:OnBossStep7Death()
	local pNpc = KNpc.GetById(self.nYuejiStep7Id);
	if pNpc then
		--删除月姬
		pNpc.Delete();
	end
	if self.nCallNpcStep7Timer and self.nCallNpcStep7Timer > 0 then
		Timer:Close(self.nCallNpcStep7Timer);
		self.nCallNpcStep7Timer = 0;
	end
	if self.nYuejiStep7CastTimer and self.nYuejiStep7CastTimer > 0 then
		Timer:Close(self.nYuejiStep7CastTimer);
		self.nYuejiStep7CastTimer = 0;
	end
	if self.tbWuniangNpc then
		for _,nId in pairs(self.tbWuniangNpc) do
			local pNpc = KNpc.GetById(nId);
			if pNpc then
				pNpc.Delete();
			end
		end
	end
	--死了掉骆驼
	self.tbBase:GiveHorse(him);
	self.tbWuniangNpc = {};
	self.tbBase:AddKillBossNum(him);
	self.nEndGameTimer = Timer:Register(5 * Env.GAME_FPS,self.OnEndGame,self);
	self.tbBase:SendBlackBoardMsgByTeam("Rõ ràng Vũ Sinh mang theo Minh ước. Ta phải phá hủy nó để bảo vệ Giang sơn");
end

function tbRoom:OnEndGame()
	self.tbBase:MissionComplete();
	return 0;
end

function tbRoom:ClearRoom()
	self:ResetVar();
	if self.nCallNpcStep7Timer and self.nCallNpcStep7Timer > 0 then
		Timer:Close(self.nCallNpcStep7Timer);
		self.nCallNpcStep7Timer = 0;
	end
	if self.nYuejiStep7CastTimer and self.nYuejiStep7CastTimer > 0 then
		Timer:Close(self.nYuejiStep7CastTimer);
		self.nYuejiStep7CastTimer = 0;
	end
	if self.nStep3EnterNpcTalkTimer and self.nStep3EnterNpcTalkTimer > 0 then
		Timer:Close(self.nStep3EnterNpcTalkTimer);
		self.nStep3EnterNpcTalkTimer = 0;
	end
	if self.nStep3CallNpcTimer and self.nStep3CallNpcTimer > 0 then
		Timer:Close(self.nStep3CallNpcTimer);
		self.nStep3CallNpcTimer = 0;
	end
	if self.nScanPlayerBuffTimer and self.nScanPlayerBuffTimer > 0 then
		Timer:Close(self.nScanPlayerBuffTimer);
		self.nScanPlayerBuffTimer = 0;
	end
	if self.nCastLunhuiTimer and self.nCastLunhuiTimer > 0 then
		Timer:Close(self.nCastLunhuiTimer);
		self.nCastLunhuiTimer = 0;
	end
	if self.nCallSishiStep6Timer and self.nCallSishiStep6Timer > 0 then
		Timer:Close(self.nCallSishiStep6Timer);
		self.nCallSishiStep6Timer = 0;
	end
	if self.nDelSishiStep6Timer and self.nDelSishiStep6Timer > 0 then
		Timer:Close(self.nDelSishiStep6Timer);
		self.nDelSishiStep6Timer = 0;
	end
	if self.nSishiCastSkillTimer and self.nSishiCastSkillTimer > 0 then
		Timer:Close(self.nSishiCastSkillTimer);
		self.nSishiCastSkillTimer = 0;
	end
	if self.nStartWalkTimer and self.nStartWalkTimer > 0 then
		Timer:Close(self.nStartWalkTimer);
		self.nStartWalkTimer = 0;
	end
end
