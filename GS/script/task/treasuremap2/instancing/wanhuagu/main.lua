
-- ====================== 文件信息 ======================

-- 万花谷初始载入脚本
-- Edited by peres
-- 2008/10/29 PM 04:18

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

Require("\\script\\task\\treasuremap\\treasuremap.lua");
Require("\\script\\task\\treasuremap2\\treasuremap.lua");

local tbInstancing = TreasureMap2:GetInstancingBase(4);
tbInstancing.szName = "Vạn Hoa Cốc";

-- 百人战 NPC 及坐标
tbInstancing.tbSoldierPos_1		= {
		--    ID    等级 五行    X     Y       CAMP
		[1] = {6997, 80,  1,	1654, 3067,		5},
		[2] = {6997, 80,  1,	1657, 3070,		5},
		[3] = {6997, 80,  1,	1660, 3073,		5},
		[4] = {6997, 80,  1,	1652, 3074,		5},
		[5] = {6997, 80,  1,	1656, 3078,		5},
};

tbInstancing.tbSoldierPos_2		= {
		--    ID    等级 五行    X     Y       CAMP
		[1] = {6997, 80,  1,	1654, 3067,		5},
		[2] = {6997, 80,  1,	1657, 3070,		5},
		[3] = {6997, 80,  1,	1660, 3073,		5},
};

tbInstancing.tbDoctorPos		= {
		[1] = {7004, 80,  1,	1652, 3074,		5},
		[2] = {7004, 80,  1,	1656, 3078,		5},
}

-- 陶子的寻路
tbInstancing.tbTaoZiSeekPos		= {
	{1609,	3161},
	{1616,	3140},
	{1618,	3129},
	{1631,	3118},
	{1644,	3100},
	{1648,	3091},	
	{1660,	3064},
	{1666,	3052},
	{1663,	3056},	
};

-- 陶子寻路2
tbInstancing.tbTaoZiSeekPos_2		= {
	{1655,	3073},
	{1651,	3092},
	{1664,	3109},
	{1674,	3128},
	{1680,	3136},
};


-- 第一次打开副本时调用，这个时候里面肯定没有别的队伍
function tbInstancing:OnNew()
	
	-- 定义 BOSS 出现的坐标与 ID
	self.tbBossPos	= {
			--    ID    等级 五行    X     Y       CAMP 分值
			[1] = {6982, 100, 1,	1683, 3141,		5, 25},	-- 铁浮屠 BOSS1
			[2]	= {6988, 100, 1,	1715, 3085,		5, 25},	-- 百羽 BOSS2
			[3]	= {6989, 100, 2,	1734, 2944,		5, 25},	-- 黄散一 BOSS3
			[4]	= {6990, 100, 2,	1691, 2891,		5, 30},	-- 柳生 BOSS4
			[5]	= {6991, 100, 2,	1678, 2903,		5, 30},	-- 贾茹 BOSS4
			[6]	= {6994, 100, 2,	1588, 2887,		5, 35},	-- 谷仙仙
			[7]	= {6995, 100, 2,	1610, 3042,		5, 45},	-- 醉僧
		}
		
	self.tbNpcPos	= {
			--    ID    等级 五行    X     Y       CAMP
			[1] = {6983, 80,  1,	1598, 3177,		0},	-- 陶子战斗1
			[2] = {6984, 50,  1,	1598, 3177,		0},	-- 陶子对话1
			[3] = {6985, 100, 1,	1598, 3177,		0},	-- 陶子战斗2
			[4] = {6981, 50,  1,	1593, 3180,		5},	-- 铁莫西
			[5] = {6986, 100, 1,	1688, 3136,		0},	-- 青青战斗
			[6] = {6987, 100, 1,	1688, 3136,		0},	-- 青青对话
			[7] = {2792, 100, 1,	1686, 3135,		0},	-- 陶子对话2
			[8]	= {7000, 100, 1,	1605, 2895,		5}, -- 花豹1
			[9]	= {7000, 100, 1,	1601, 2898,		5}, -- 花豹2
			[10]	= {7009, 10, 1,	1629, 2930,		0}, -- 牧童
			[11]	= {7010, 10, 1,	1631, 2933,		0}, -- 绵羊
			[12]	= {7011, 10, 1,	1564, 3205,		0}, -- 阮小六
			[13]	= {7012, 10, 1,	1734, 2944,		0}, -- 黄散一对话
			
			[14]	= {6998, 90, 1,	1710, 3070,		5}, -- 黑熊
			[15]	= {6998, 90, 1,	1715, 3066,		5}, -- 黑熊
			[16]	= {6998, 90, 1,	1721, 3069,		5}, -- 黑熊
			
		}
	
	-- 各种物件的坐标
	self.tbObjPos	= {
			[1] = {7005, 80,  1,	1669, 3047,		0},	-- 大门铁栏
			
			-- 紫花障碍
			[2] = {7006, 80,  1,	1671, 2972,		0},
			[3] = {7006, 80,  1,	1673, 2970,		0},
			[4] = {7006, 80,  1,	1672, 2971,		0},
			[5] = {7006, 80,  1,	1674, 2969,		0},
			
			-- 拿钥匙的布袋子
			[6] = {7007, 80,  1,	1683, 3141,		0},
			-- 拿酒的布袋子
			[7] = {7007, 80,  1,	1683, 2889,		0},
			-- 拿笛子的布袋子
			[8] = {7008, 80,  1,	1595, 2890,		0},
			
			[9]		= {7013, 60,  1,	1715, 3085,		0},		-- BOSS 2 箱子
			[10]	= {7013, 60,  1,	1588, 2887,		0},		-- BOSS 5 箱子
			[11]	= {7013, 60,  1,	1603, 3043,		0},		-- BOSS 6 箱子
			[12]	= {7013, 60,  1,	1610, 3043,		0},		-- BOSS 6 箱子
			[13]	= {7013, 60,  1,	1617, 3043,		0},		-- BOSS 6 箱子
	}
	
	-- 初始化变量
	self.nCaptainFight		= 0;	-- 与刚开始的铁莫西战斗完，变 1
	self.nTaoZiEscort		= 0;	-- 开始陶子护送：1;   护送到达：2
	self.nSoldierFight		= 0;	-- 百人战杀死士兵数，5 人为一批，3 批后结束
	
	self.nTaoZi_Death		= 0;	-- 如果陶子死亡，为 1;
	self.nQingQing_Death	= 0;	-- 如果青青死亡，为 1;
	
	self.nDoorOpen			= 0;	-- 大门可以通过，为 1;
	self.nSoldierEnd		= 0;	-- 完成百人战后，BOSS 1 出现
	self.nBoss_1			= 0;	-- BOSS 1 铁浮屠死亡后，为 1
	self.nBoss_2			= 0;	-- BOSS 2 死亡后，为 1
	self.nBoss_3			= 0;	-- BOSS 3 死亡后，为 1
	self.nBoss_4			= 0;	-- BOSS 4 死亡后，为 1
	self.nBoss_5_Ready		= 0;	-- 吹响笛子后，BOSS 5 可以出来了
	
	-- BOSS 生命点的触发
	self.tbBossLifePoint	= {
		[1]	= 0,
		[2]	= 0,
		[3]	= 0,
		[4]	= 0,
		[5]	= 0,
		[6]	= 0,
	}
	
	-- 铁莫西与陶子在战斗
	self.pTaoZi_Fight_1		= self:AddNpc(self.tbNpcPos[1], self.nMapId);
	self.dwIdTaoZi_Fight_1	= self.pTaoZi_Fight_1.dwId;
	
	self.pCaptain_Fight		= self:AddNpc(self.tbNpcPos[4], self.nMapId);
	
	-- 大门的铁栏
	local pDoor				= self:AddNpc(self.tbObjPos[1], self.nMapId);
	self.dwIdDoor			= pDoor.dwId;
	pDoor.szName			= "   ";
	
	-- 障碍紫花
	self.tb_dwIdAster		= {};
	for i=2, 5 do
		local pAster			= self:AddNpc(self.tbObjPos[i], self.nMapId);
		self.tb_dwIdAster[i-1]	= pAster.dwId;
		pAster.szName			= "   ";
	end;
	
	-- 加 BOSS
	local pBoss_2			= self:AddNpc(self.tbBossPos[2], self.nMapId);
	self.dwIdBoss_2			= pBoss_2.dwId;
	pBoss_2.AddLifePObserver(50);
	
	local pBoss_3			= self:AddNpc(self.tbBossPos[3], self.nMapId);
	self.dwIdBoss_3			= pBoss_3.dwId;
	pBoss_3.AddLifePObserver(60);
	pBoss_3.AddLifePObserver(30);
	
	local pBoss_4_male		= self:AddNpc(self.tbBossPos[4], self.nMapId);
	self.dwIdBoss_4_male	= pBoss_4_male.dwId;
	pBoss_4_male.AddLifePObserver(60);
	
--	local pBoss_5			= self:AddNpc(self.tbBossPos[6], self.nMapId);
--	self.dwIdBoss_5			= pBoss_5.dwId;
	
	-- 加花豹
	local pLeopard_1		= self:AddNpc(self.tbNpcPos[8], self.nMapId);
	self.dwIdLeopard_1		= pLeopard_1.dwId;
	
	local pLeopard_2		= self:AddNpc(self.tbNpcPos[9], self.nMapId);
	self.dwIdLeopard_2		= pLeopard_2.dwId;
	
	-- 加装笛子的袋子
	local pBag_2			= self:AddNpc(self.tbObjPos[8], self.nMapId);
	
	-- 加绵羊
	local pTalkNpc_1		= self:AddNpc(self.tbNpcPos[10], self.nMapId);
	local pTalkNpc_2		= self:AddNpc(self.tbNpcPos[11], self.nMapId);
end;

-- 内部函数，CALL 出一个NPC，传入参数是内部固定的格式
-- 返回值：pNpc
function tbInstancing:AddNpc(tbPos, nMapId)
	local nNpcLevel =  	TreasureMap2.TEMPLATE_LIST[self.nTreasureId].tbNpcLevel[self.nTreasureLevel] ;
	local pNpc = KNpc.Add2(tbPos[1],nNpcLevel, tbPos[3], nMapId, tbPos[4], tbPos[5]);
	if pNpc then	
		pNpc.SetCurCamp(tbPos[6]);
		if tbPos[7] then
			 pNpc.GetTempTable("TreasureMap2").nNpcScore = tbPos[7] * TreasureMap2.LEVEL_RATE[self.nTreasureLevel];
		end 
	end
	return pNpc;
end;

-- 内部函数，根据 NPC ID CALL 出一个 NPC，并指定一个寻路路径，可以有完成后的回调
function tbInstancing:AddSeekNpc(nNpcId, nLevel, nX, nY, tbSeekPos, nCamp, pPlayer, nCallBack, tbNpc)
	local pFightNpc		= KNpc.Add2(nNpcId, nLevel, -1, self.nMapId, nX, nY, 0, 0, 1);
	pFightNpc.SetCurCamp(nCamp);
	
	pFightNpc.RestoreLife();
	
	if nCallBack == 1 and tbNpc then
		pFightNpc.GetTempTable("Npc").tbOnArrive = {tbNpc.OnArrive, tbNpc, pFightNpc, pPlayer};
	end;
	
	pFightNpc.AI_ClearPath();
	
	for _,Pos in ipairs(tbSeekPos) do
		if (Pos[1] and Pos[2]) then
			pFightNpc.AI_AddMovePos(tonumber(Pos[1])*32, tonumber(Pos[2])*32)
		end
	end;
	
	if pPlayer then
		pFightNpc.SetNpcAI(9, 50, 1, -1, 25, 25, 25, 0, 0, 0, pPlayer.GetNpc().nIndex);
	else
		pFightNpc.SetNpcAI(9, 50, 1, -1, 25, 25, 25, 0, 0, 0, 0);
	end;

	return pFightNpc;
end;


-- 副本的时间轴
function tbInstancing:GetSteps()
	local tbStep = 
	{
		-- 第一步：与铁莫西战斗完，将陶子变成对话 NPC
		{
			tbActions = {{self.tbActions_1, self}}, 
			tbConditions = {{self.tbConditions_1, self}},
			nTime = 1,
		},

		-- 第二步：护送陶子到门口，开始百人战
		{
			tbActions = {{self.tbActions_2, self}}, 
			tbConditions = {{self.tbConditions_2, self}},
			nTime = 3,
		},
		
		-- 第三步：百人战二开始
		{
			tbActions = {{self.tbActions_3, self}}, 
			tbConditions = {{self.tbConditions_3, self}},
			nTime = 8,
		},
		
		-- 百人战三开始
		{
			tbActions = {{self.tbActions_4, self}}, 
			tbConditions = {{self.tbConditions_4, self}},
			nTime = 8,
		},
		
		-- BOSS1 出现，去和陶子救青青
		{
			tbActions = {{self.tbActions_5, self}}, 
			tbConditions = {{self.tbConditions_5, self}},
			nTime = 5,
		},		
	}
	return tbStep;
end


function tbInstancing:tbConditions_1()
	if self.nCaptainFight == 1 and self.nTaoZi_Death ==0 then
		return 1;
	end;
	return 0;
end;

function tbInstancing:tbActions_1()
	local pNpc	= KNpc.GetById(self.dwIdTaoZi_Fight_1);
	if pNpc then
		pNpc.Delete();
		self:AddNpc(self.tbNpcPos[2], self.nMapId);
	end;
end;

function tbInstancing:tbConditions_2()
	if self.nTaoZiEscort == 2 then
		return 1;
	end;
	return 0;
end;

function tbInstancing:tbActions_2()
	local tbPos	 = self.tbSoldierPos_1;
	for i=1, #tbPos do
		self:AddSeekNpc(tbPos[i][1],
						tbPos[i][2],
						tbPos[i][4],
						tbPos[i][5],
						{{1661, 3058},{1663, 3056}},
						5,
						nil,
						0,
						nil);
	end;
end;

function tbInstancing:tbConditions_3()
	if self.nSoldierFight == 5 and self.nTaoZi_Death == 0 then
		return 1;
	end;
end;

function tbInstancing:tbActions_3()
	local tbPos	 = self.tbSoldierPos_2;
	for i=1, #tbPos do
		self:AddSeekNpc(tbPos[i][1],
						tbPos[i][2],
						tbPos[i][4],
						tbPos[i][5],
						{{1661, 3058},{1663, 3056}},
						5,
						nil,
						0,
						nil);
	end;
	tbPos	= self.tbDoctorPos;
	for i=1, #tbPos do
		self:AddNpc(tbPos[i], self.nMapId);
	end;
end;

function tbInstancing:tbConditions_4()
	if self.nSoldierFight == 10 and self.nTaoZi_Death == 0 then
		return 1;
	end;
end;

function tbInstancing:tbActions_4()
	local tbPos	 = self.tbSoldierPos_2;
	for i=1, #tbPos do
		self:AddSeekNpc(tbPos[i][1],
						tbPos[i][2],
						tbPos[i][4],
						tbPos[i][5],
						{{1661, 3058},{1663, 3056}},
						5,
						nil,
						0,
						nil);
	end;
	tbPos	= self.tbDoctorPos;
	for i=1, #tbPos do
		self:AddNpc(tbPos[i], self.nMapId);
	end;	
end;

function tbInstancing:tbConditions_5()
	if self.nSoldierFight == 15 and self.nTaoZi_Death == 0 then
		return 1;
	end;
end;

function tbInstancing:tbActions_5()
--	print ("tbInstancing:tbActions_5()");
	if self.pTaoZi_Fight_2 then
		self.pTaoZi_Fight_2.SendChat("Tôi thấy Thanh Thanh! Hãy xuống cứu cô ấy!");
		self.pTaoZi_Fight_2.RestoreLife();
		self.pTaoZi_Fight_2.AI_ClearPath();
		for _,Pos in ipairs(self.tbTaoZiSeekPos_2) do
			if (Pos[1] and Pos[2]) then
				self.pTaoZi_Fight_2.AI_AddMovePos(tonumber(Pos[1])*32, tonumber(Pos[2])*32)
			end
		end;		
		self.pTaoZi_Fight_2.SetNpcAI(9, 50, 1, -1, 25, 25, 25, 0, 0, 0, 0);
	end;
	
	-- 出现 BOSS1 和青青
	local pQingQing_Fight_1	= self:AddNpc(self.tbNpcPos[5], self.nMapId);
	if pQingQing_Fight_1 then
		self.dwQingQing_F_1 = pQingQing_Fight_1.dwId;
	end;
	self.pBoss_1			= self:AddNpc(self.tbBossPos[1], self.nMapId);
	
	-- 给 BOSS 1 设置生命触发点
	self.pBoss_1.AddLifePObserver(50);
	self.pBoss_1.AddLifePObserver(30);
end;
