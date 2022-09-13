-- 文件名　：zhanche.lua
-- 创建者　：LQY
-- 创建时间：2012-07-25 13:51:49
-- 说　　明：战车逻辑
-- 嗒嗒滴 哒哒哒 达达嘟

-- 战车
local tbNpc = Npc:GetClass("NewBattle_zhanche")

-- 死亡事件
function tbNpc:OnDeath(pNpcKiller)
	local tbInfo 	= 	him.GetTempTable("Npc");
	local szPower	= 	NewBattle.POWER_ENAME[tbInfo.nPower];
	NewBattle.Mission:OnNpcDeath("ZHANCHE", pNpcKiller, him);
	NewBattle:DeleteCardwId(szPower, tbInfo.nNum);
	NewBattle.Mission.tbCarLive[szPower][tbInfo.nNum] = 0;	
end
