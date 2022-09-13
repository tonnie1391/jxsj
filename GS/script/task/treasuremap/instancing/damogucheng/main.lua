
-- ====================== 文件信息 ======================

-- 大漠古城初始载入脚本
-- Edited by peres
-- 2008/05/15 PM 16:23

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

Require("\\script\\task\\treasuremap\\treasuremap.lua");

local tbInstancing = TreasureMap:GetInstancingBase(272);
tbInstancing.szName = "大漠古城";

-- 第一次打开副本时调用，这个时候里面肯定没有别的队伍
function tbInstancing:OnNew()
	assert(self.nMapTemplateId == self.nMapTemplateId);
	self.nBoss_1			= 0;	-- 击杀第一个 BOSS
	self.nBoss_2			= 0;	-- 击杀第二个 BOSS
	self.nGateLock			= 0;	-- 开完第一道锁
	self.nBoss_3_call		= 0;	-- 召唤出第三个 BOSS
	self.nBoss_3_kill		= 0;	-- 击杀第三个 BOSS
	
	-- 新增任务 NPC （石碑）
	KNpc.Add2(2731, 1, -1, self.nTreasureMapId, 1552, 3542);
end


-- 队伍开启一个副本的时候调用，这个时候里面可能有别的队伍
function tbInstancing:OnOpen()

end

-- 副本的限制时间到的时候调用
function tbInstancing:OnDelete()

end
