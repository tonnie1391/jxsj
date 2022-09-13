-- 上交指定数目的材料可以到下一关
local tbNpc = Npc:GetClass("caishiqudoorsill");

tbNpc.tbNeedItemList = 
{
	{20,1,603,1,10},
}


function tbNpc:OnDialog()
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	if(tbInstancing.nCaiShiQuColItem == 1) then
		Task.tbArmyCampInstancingManager:ShowTip(me,"Dụng cụ cắt đá đã bị hỏng.");
		return;
	end
	
	Dialog:Say("Đặt 10 đạo cụ vào máy cắt đá, Thợ Cả sẽ xuất hiện.",
		{
			{"Đặt vật phẩm", self.Destroy, self, tbInstancing},
			{"Kết thúc đối thoại"}
		})	
	
end

function tbNpc:Destroy(tbInstancing)
	if (tbInstancing.nCaiShiQuColItem ~= 1) then
		Task:OnGift("Đặt 10 đạo cụ vào để phá hủy máy cắt đá", self.tbNeedItemList, {self.PassCaiKuangQu, self, tbInstancing}, nil, {self.CheckRepeat, self, tbInstancing});
	end
end

function tbNpc:PassCaiKuangQu(tbInstancing)
	TaskAct:Talk("<npc=4002>:“Đám ngu xuẩn các ngươi, nộp mạng đi!!!”");
	tbInstancing.nCaiShiQuColItem = 1;
	local pNpc = KNpc.Add2(4002, tbInstancing.nNpcLevel, -1, tbInstancing.nMapId, 1696, 3880);
	if pNpc then
		local nRand = MathRandom(3);
		Task.ArmyCamp:StartTrigger(pNpc.dwId, nRand);
	end
end


function tbNpc:CheckRepeat(tbInstancing)
	if (tbInstancing.nCaiShiQuColItem == 1) then
		return 0;
	end
	
	return 1;
end
