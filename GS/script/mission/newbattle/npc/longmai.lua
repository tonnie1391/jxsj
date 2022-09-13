-- 文件名　：longmai.lua
-- 创建者　：LQY
-- 创建时间：2012-07-24 11:09:02
-- 说　　明：龙脉逻辑，死掉就判断胜负

local tbNpc = Npc:GetClass("NewBattle_longmai")
-- 龙脉宋死亡事件
function tbNpc:OnDeath(pNpcKiller)
	local tbInfo = him.GetTempTable("Npc");
	local szPower = NewBattle.POWER_ENAME[tbInfo.nPower];
	NewBattle.Mission.tbLongMaiLive[szPower][1] = 0;
	NewBattle.Mission.tbLongMaiLiveWL[szPower] = 0;
	NewBattle.Mission:OnNpcDeath("LONGMAI", pNpcKiller, him);
	NewBattle.Mission:GoNextState();
	NewBattle.Mission:Boom(szPower, pNpcKiller);
	--him.CastSkill(NewBattle.BOOM_ID,1,1,1,1);
end
--血量触发
function tbNpc:OnLifePercentReduceHere(nLifePercent)
	if nLifePercent == NewBattle.LONGMAIBLOODBIANSHEN then
		local tbInfo = him.GetTempTable("Npc");
		local szPower = NewBattle.POWER_ENAME[tbInfo.nPower];
		NewBattle.Mission:BroadCastMission(NewBattle:GetColStr(NewBattle.POWER_CNAME[tbInfo.nPower].."-", tbInfo.nPower).."<color=red>Long Mạch<color> bị tấn công!", NewBattle.SYSTEMBLACK_MSG, 0);
		him.CastSkill(NewBattle.BIANSHEN[szPower], 1, 1, 1)	
	end
end
