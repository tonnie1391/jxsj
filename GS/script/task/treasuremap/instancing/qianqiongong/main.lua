
-- ====================== 文件信息 ======================

-- 千琼宫初始载入脚本
-- Edited by peres
-- 2008/07/25 AM 11:28

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

Require("\\script\\task\\treasuremap\\treasuremap.lua");

local tbInstancing = TreasureMap:GetInstancingBase(287);
tbInstancing.szName = "千琼宫";

local tbBossPos		=	{
	--      X     Y    NPCID  五行
	[1]	= {1682, 3119,  2739, 1},	-- 羽凌儿（金）
	[2]	= {1565, 2950,  2740, 2},	-- 萧媛媛（木）
	[3]	= {1579, 2819,  2742, 3},	-- 肖良（火）
	[4] = {1714, 2775,  2743, 4},	-- 肖玉（土）
	[5]	= {1812, 2670,  2741, 5},	-- 冷霜然（水）	
}

local tbNpcPos		= 	{
	[1] = {1575, 3224,  2737, 5},	-- 一开始的兔子
	[2]	= {1671, 2846,	2757, 5},	-- 李香兰，金钱任务 NPC
}

local tbStatuaryPos	= {
	[1] = {1694, 3142},
	[2] = {1545, 2927},
	[3] = {1607, 2839},
	[4] = {1780, 2717},
}


-- 第一次打开副本时调用，这个时候里面肯定没有别的队伍
function tbInstancing:OnNew()
	assert(self.nMapTemplateId == self.nMapTemplateId);
	
	self.tbBossIndex		= {};
	self.tbBossLifePoint	= {{},{},{},{},{},{}};	-- BOSS 生命的触发点
	
	-- 加 BOSS
	for i=1, #tbBossPos do
		local pNpc = KNpc.Add2(tbBossPos[i][3], 95, tbBossPos[i][4], self.nTreasureMapId, tbBossPos[i][1], tbBossPos[i][2]);
		self.tbBossIndex[i] = pNpc.dwId;
		
		-- 统一注册血量触发事件，50% 和  30%
		pNpc.AddLifePObserver(50);
		pNpc.AddLifePObserver(30);
		
		self.tbBossLifePoint[i][50]	= 0;
		self.tbBossLifePoint[i][30]	= 0;
	end;
	
	
	self.tbNpcIndex		= {};
	-- 加 NPC
	for i=1, #tbNpcPos do
		local pNpc = KNpc.Add2(tbNpcPos[i][3], 20, tbNpcPos[i][4], self.nTreasureMapId, tbNpcPos[i][1], tbNpcPos[i][2]);
		self.tbNpcIndex[i] = pNpc.dwId;	
	end;
	
	
	self.tbStatuaryIndex	= {};
	-- 加障碍物
	for i=1, #tbStatuaryPos do
		local pNpc = KNpc.Add2(2752, 1, 0, self.nTreasureMapId, tbStatuaryPos[i][1], tbStatuaryPos[i][2]);
		pNpc.szName = " ";
		self.tbStatuaryIndex[i] = pNpc.dwId;	
	end;
	
		
	-- BOSS 被击杀的数据
	self.tbBossDown		= {0,0,0,0,0,0};
	
	-- 如果兔子被杀死，则为 1
	self.nRabbit		= 0;
	
	-- 护送小怜的进程
	self.nGirlProStep	= 0;
	
	-- 护送小怜的 NPC ID
	self.nGirlId		= 0;
	
	-- 如果小怜死了，则为 1
	self.nGirlKilled	= 0;
end;

-- 队伍开启一个副本的时候调用，这个时候里面可能有别的队伍
function tbInstancing:OnOpen()

end

-- 副本的限制时间到的时候调用
function tbInstancing:OnDelete()

end