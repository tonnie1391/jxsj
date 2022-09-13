-- 牛栏寨
-- 上交指定数目的材料可以到下一关
local tbNpc = Npc:GetClass("qianlai");

tbNpc.tbNeedItemList = 
{
	{20, 1, 485, 1, 2},
}

function tbNpc:OnDialog()
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	if (tbInstancing.nNiuLanZhaiPass ~= 1) then
		Dialog:Say("Tiền Lai: “Hãy dừng bước! Ngươi định đến đây làm gì?”",
		{
			{"Ta cần vào nơi đây", self.Give, self, tbInstancing, me.nId},
			{"Kết thúc đối thoại"}
		})
	end
end

function tbNpc:Give(tbInstancing, nPlayerId)
	Task:OnGift("Giao cho Tiền Lai 2 Ngưu Lan Trại Yêu Bài là có thể tự do ra vào.", self.tbNeedItemList, {self.Pass, self, tbInstancing, nPlayerId}, nil, {self.CheckRepeat, self, tbInstancing});
end

function tbNpc:Send(tbInstancing)
	--me.NewWorld(tbInstancing.nMapId, 1911, 3000);
end


function tbNpc:Pass(tbInstancing, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);	
	tbInstancing.nNiuLanZhaiPass = 1;
	local pNpc = KNpc.GetById(tbInstancing.nNiuLanZhaiLaoMenId);
	if (pNpc) then
		pNpc.Delete();
	end
	
	if (pPlayer) then
		Task.tbArmyCampInstancingManager:ShowTip(pPlayer, "Bây giờ đã có thể đến Ngưu Lan Trại");
	end
end

function tbNpc:CheckRepeat(tbInstancing)
	if (tbInstancing.nNiuLanZhaiPass == 1) then
		return 0;
	end
	
	return 1; 
end
