-- 文件名　：shouhuzhe.lua
-- 创建者　：LQY
-- 创建时间：2012-07-24 11:09:12
-- 说　　明：守护者逻辑，死掉就刷龙脉

local tbNpc = Npc:GetClass("NewBattle_shouhuzhe")

-- 死亡事件
function tbNpc:OnDeath(pNpcKiller)
	local tbInfo = him.GetTempTable("Npc");
	local nPower = tbInfo.nPower;
	local szPower = NewBattle.POWER_ENAME[nPower];
	if not nPower then
		return;
	end
	local szMsg = string.format("%sThủ Hộ Giả đã bị đánh bại, <color=red>Long Mạch<color> đang lâm nguy.", NewBattle:GetColStr((nPower == 1) and "Mông Cổ-" or "Tây Hạ-", nPower));
	NewBattle.Mission:BroadCastMission(szMsg,NewBattle.SYSTEMBLACKRED_MSG,0);
	NewBattle.Mission.tbShouhuzheLive[szPower][1] = 0;
	NewBattle.Mission:OnNpcDeath("SHOUHUZHE", pNpcKiller, him);
	--改变龙脉战斗关系为可攻击
	--
	--DEBUG BEGIN
	if NewBattle.__DEBUG then
		print("改变龙脉战斗关系为可攻击", szPower, NewBattle.Mission.tbLongMaipNpcId[szPower]);
	end
	--
	--DEBUG END	
	local pNpc =  KNpc.GetById(NewBattle.Mission.tbLongMaipNpcId[szPower]);
	if not pNpc then
		print("冰火天堑，龙脉ID故障");
		--出问题了
		return;
	end
	--改变龙脉阵营
	pNpc.SetCurCamp(nPower);
	pNpc.RemoveSkillState(NewBattle.WUDITEXIAO[szPower]);
	NewBattle:AddTimer("DefLongMai"..szPower, NewBattle.DEFPOINTTIME, NewBattle.Mission.DefAddPoint,  NewBattle.Mission, "LONGMAI", nPower, pNpc.dwId);	
	NewBattle.Mission.tbLongMaiLive[szPower][1] = 1;
	NewBattle.Mission:AddTip(szPower, 3, 3);
	NewBattle.Mission:AddTip(NewBattle:GetEnemy(szPower), 4, 3);
end
