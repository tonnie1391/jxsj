-- 传送去蛮瘴山的Npc

-- 上交指定数目的材料可以到下一关
local tbNpc = Npc:GetClass("yundadao");

tbNpc.tbNeedItemList = 
{
	{20, 1, 487, 1, 2},
}

function tbNpc:OnDialog()
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	if (tbInstancing.nManZhangShanPass == 1) then
		Dialog:Say("Ngươi muốn đi đâu?",
		{
			{"Ta thăm dò Man Chướng Sơn", self.Send, self, tbInstancing, me.nId},
			{"Kết thúc đối thoại"}
		})
	else
	Dialog:Say("Vân Đại Đao: “Đưa ta 2 Cốt Ngọc Đồ Đằng ta sẽ cho qua”",
		{
			{"Ta có vật phẩm đây", self.Give, self, tbInstancing, me.nId},
			{"Kết thúc đối thoại"}
		})
	end
end

function tbNpc:Give(tbInstancing, nPlayerId)
	Task:OnGift("Hãy đặt vào 2 Cốt Ngọc Đồ Đằng.", self.tbNeedItemList, {self.Pass, self, tbInstancing, nPlayerId}, nil, {self.CheckRepeat, self, tbInstancing});
end

function tbNpc:Send(tbInstancing)
	me.NewWorld(tbInstancing.nMapId, 1911, 3000);
end


function tbNpc:Pass(tbInstancing, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);	
	tbInstancing.nManZhangShanPass = 1;
	if (pPlayer) then
		Task.tbArmyCampInstancingManager:ShowTip(pPlayer, "Đã có thể đến Man Chướng Sơn rồi");
	end
end

function tbNpc:CheckRepeat(tbInstancing)
	if (tbInstancing.nManZhangShanPass == 1) then
		return 0;
	end
	
	return 1; 
end
