-- 文件名　：paotai.lua
-- 创建者　：LQY
-- 创建时间：2012-07-26 10:28:03
-- 说　　明：炮台逻辑
-- 这一个就不卖萌了

--宋军炮台
local tbNpc = Npc:GetClass("NewBattle_paotai")

-- 死亡事件
function tbNpc:OnDeath(pNpcKiller)
	NewBattle.Mission:OnNpcDeath("PAOTAI", pNpcKiller, him);
	local tbInfo =	him.GetTempTable("Npc");
	NewBattle.Mission:PaoTaiOnDeath(tbInfo.nNum, tbInfo.nPower);
end