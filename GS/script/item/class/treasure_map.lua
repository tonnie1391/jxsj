
-- ====================== 文件信息 ======================

-- 剑侠世界随机任务 - 藏宝图物品脚本文件
-- Edited by peres
-- 2007/06/11 PM 11:08

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

local tbTreasureMap = Item:GetClass("treasure_map");

function tbTreasureMap:OnUse()

end;

function tbTreasureMap:GetTip()
	local szMain = "一张破旧的藏宝图";
	return szMain;
end;
