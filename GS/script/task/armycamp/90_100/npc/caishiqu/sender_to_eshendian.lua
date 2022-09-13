-- 传送去鳄神殿的Npc

-- 上交指定数目的材料可以到下一关
local tbNpc = Npc:GetClass("yunxiaodao");

tbNpc.tbNeedItemList = 
{
	{20, 1, 486, 1, 2},
}

function tbNpc:OnDialog()
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	if (tbInstancing.nEShenDianPass == 1) then
		Dialog:Say("Ngươi muốn đến Ngạc Thần Điện không?",
		{
			{"Ta đi", self.Send, self, tbInstancing, me.nId},
			{"Kết thúc đối thoại"}
		})
	else
	Dialog:Say("Vân Tiểu Đao: “Đưa ta 2 chìa khóa mê cung, ta sẽ cho ngươi qua.”",
		{
			{"Ta có chìa khóa đây", self.Give, self, tbInstancing, me.nId},
			{"Kết thúc đối thoại"}
		})
	end
end

function tbNpc:Give(tbInstancing, nPlayerId)
	Task:OnGift("Hãy đặt 2 chìa khóa mê cung", self.tbNeedItemList, {self.Pass, self, tbInstancing, nPlayerId}, nil, {self.CheckRepeat, self, tbInstancing});
end

function tbNpc:Send(tbInstancing)
	me.NewWorld(tbInstancing.nMapId, 1819, 3941);
end


function tbNpc:Pass(tbInstancing, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);	
	tbInstancing.nEShenDianPass = 1;
	if (pPlayer) then
		Task.tbArmyCampInstancingManager:ShowTip(pPlayer, "Đã có thể đến Ngạc Thần Điện!");
	end
end

function tbNpc:CheckRepeat(tbInstancing)
	if (tbInstancing.nEShenDianPass == 1) then
		return 0;
	end
	
	return 1; 
end
