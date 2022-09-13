local tbNpc = Npc:GetClass("jiejing");


function tbNpc:OnDialog()
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	
	local szMsg = "Đây là đường tắt để đi tới các điểm trong bản đồ, ngươi có thể di chuyển đến các ải đã được tổ đội vượt qua, có thể đi qua ta. Tuy nhiên, cần phải trả 500 bạc.";
	local tbOpt = 
	{
		{"Đi đến tê giác khoáng", tbNpc.JieJing, self, 1, tbInstancing, me.nId},
		{"Đi đến bãi đá", tbNpc.JieJing, self, 2, tbInstancing, me.nId},
		{"Kết thúc đối thoại"},
	}
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:JieJing(nPosType, tbInstancing, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	
	if (pPlayer.nCashMoney < 500) then
		Task.tbArmyCampInstancingManager:Warring(pPlayer, "Ngươi không đủ tiền");
		return;
	end
	
	if (nPosType == 1 and tbInstancing.nFaMuQuTrapOpen == 1) then
		assert(pPlayer.CostMoney(500, Player.emKPAY_CAMPSEND) == 1);
		pPlayer.NewWorld(tbInstancing.nMapId, 1919, 3308);	
		pPlayer.SetFightState(1);
		return;
	elseif (nPosType == 2 and tbInstancing.nCaiKuangQuPass == 1) then
		assert(pPlayer.CostMoney(500, Player.emKPAY_CAMPSEND) == 1);
		pPlayer.NewWorld(tbInstancing.nMapId, 1668,3764);
		pPlayer.SetFightState(1);
		return;
	end
	
	Task.tbArmyCampInstancingManager:Warring(pPlayer, "Chỉ sử dụng để đi tắt đến ải đã vượt qua");
end

