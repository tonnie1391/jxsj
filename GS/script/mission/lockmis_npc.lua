-- 文件名　：lockmis_npc.lua
-- 创建者　：zounan
-- 创建时间：2009-12-21 10:21:58
-- 描  述  ：LOCKMIS中NPC的一些回调

-- 

local LockMis_Npc = Npc:GetClass("lockmis_npc_death");

function LockMis_Npc:OnDeath(pKiller)
	if not him.GetTempTable("Mission").tbGame then
		print("npc is not in the Mission");
		return;
	end
	him.GetTempTable("Mission").tbGame:UnLockNpc(him);
end

function LockMis_Npc:OnLifePercentReduceHere(nPercent)
	if not him.GetTempTable("Mission").tbGame then
		print("npc is not in the Mission");
		return;
	end
	him.GetTempTable("Mission").tbGame:UnLockNpc(him);
end

local LockMis_Npc2 = Npc:GetClass("lockmis_npc_dialog");

--对话NPC 有概率解锁。。
function LockMis_Npc2:OnDialog()
	if not him.GetTempTable("Mission").tbGame then
		print("npc is not in the Mission");
		return;
	end
	if him.GetTempTable("Mission").nUsed then
		return;
	end
	
	if not him.GetTempTable("Mission").nRate then
		him.GetTempTable("Mission").tbGame:UnLockNpc(him);
		him.GetTempTable("Mission").nUsed = 1;
		return;
	end
	
	local nRandom = MathRandom(1000000); --100w为基数
	if him.GetTempTable("Mission").nRate >= nRandom then
		him.GetTempTable("Mission").tbGame:UnLockNpc(him);	
	end
	him.GetTempTable("Mission").nUsed = 1;
end