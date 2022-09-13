-- 文件名　：jianta.lua
-- 创建者　：LQY
-- 创建时间：2012-07-25 13:59:23
-- 说　　明：箭塔逻辑
-- 嗖嗖嗖嗖

--宋军箭塔
local tbNpc = Npc:GetClass("NewBattle_jianta")

-- 死亡事件
function tbNpc:OnDeath(pNpcKiller)
	local tbInfo	=	him.GetTempTable("Npc");
	local szPower	= 	NewBattle.POWER_ENAME[tbInfo.nPower];
	NewBattle.Mission.tbArrowLive[szPower][tbInfo.nNum] = 0;
	NewBattle.Mission:OnNpcDeath("JIANTA", pNpcKiller, him);
	--注册复活计时器
	NewBattle:AddTimer("CallJianTa"..tbInfo.nNum, NewBattle.SWORDREBORN, NewBattle.Mission.JianTaFuHuo, NewBattle.Mission,tbInfo.nNum, tbInfo.nPower);
	--pNpcKiller.CastSkill(2935,1,1,1);
end
