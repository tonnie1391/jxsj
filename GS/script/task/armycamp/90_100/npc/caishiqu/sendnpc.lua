local tbNpc = Npc:GetClass("send2caikuangqu");

function tbNpc:OnDialog()
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	Dialog:Say("这艘船显然是刚修好的",
		{
			{"坐船前往犀角矿", self.Send, self, tbInstancing},
			{"Kết thúc đối thoại"}
		})	
end

function tbNpc:Send(tbInstancing)
	me.NewWorld(tbInstancing.nMapId, 1878, 3464);
end



local tbNpc1 = Npc:GetClass("outcaishiqu");

function tbNpc1:OnDialog()
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	Dialog:Say("这条水路是返回前往山地的唯一通路",
		{
			{"送我回哨岗", self.Send, self, tbInstancing},
			{"Kết thúc đối thoại"}
		})
end

function tbNpc1:Send(tbInstancing)
	me.NewWorld(tbInstancing.nMapId, 1643, 3623);
end
