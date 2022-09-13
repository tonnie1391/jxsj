-- 上交指定数目的材料可以到下一关
local tbNpc = Npc:GetClass("caikuangqudoorsill");

tbNpc.tbNeedItemList = 
{
	{20, 1, 604, 1, 3},
	{20, 1, 605, 1, 3},
}

function tbNpc:OnDialog()
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	if (tbInstancing.nCaiKuangQuPass == 1) then
		Dialog:Say("船已修好，可以坐船前往乱石滩。",
		{
			{"坐船前往乱石滩", self.Send, self, tbInstancing, me.nId},
			{"Kết thúc đối thoại"}
		})
	else
	Dialog:Say("这艘船破败不堪，需用三条麻绳和三块木板加固方可使用。",
		{
			{"修复旧船", self.Fix, self, tbInstancing, me.nId},
			{"Kết thúc đối thoại"}
		})
	end
end

function tbNpc:Fix(tbInstancing, nPlayerId)
	Task:OnGift("船已经破损，需要放入三条麻绳，三块木板将其修复才可使用。", self.tbNeedItemList, {self.PassCaiKuangQu, self, tbInstancing, nPlayerId}, nil, {self.CheckRepeat, self, tbInstancing});
end

function tbNpc:Send(tbInstancing)
	me.NewWorld(tbInstancing.nMapId, 1668, 3764);
end


function tbNpc:PassCaiKuangQu(tbInstancing, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);	
	tbInstancing.nCaiKuangQuPass = 1;
	if (pPlayer) then
		Task.tbArmyCampInstancingManager:ShowTip(pPlayer, "Thuyền cũ đã được sửa.");
	end
end

function tbNpc:CheckRepeat(tbInstancing)
	if (tbInstancing.nCaiKuangQuPass == 1) then
		return 0;
	end
	
	return 1; 
end
