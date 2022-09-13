
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
Require("\\script\\task\\treasuremap2\\treasuremap.lua");

local tbInstancing = TreasureMap2:GetInstancingBase(1);



tbInstancing.szName = "Bách Niên Thiên Lao";

-- 第一次打开副本时调用，这个时候里面肯定没有别的队伍
function tbInstancing:OnNew()

end


-- 副本的时间轴
function tbInstancing:GetSteps()
	local tbStep = 
	{

	}
	
	return tbStep;
end
