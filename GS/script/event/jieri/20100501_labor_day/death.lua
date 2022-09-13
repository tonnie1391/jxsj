-- 文件名　：death.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-04-29 09:08:45
-- 描  述  ：
local tbNpc = Npc:GetClass("hero_death")

function tbNpc:OnDeath(pKiller)
	local pPlayer = pKiller.GetPlayer();
	local nRate = Random(100);
	if him.nTemplateId == 6812 and nRate <= SpecialEvent.LaborDay.nRate then
		pPlayer.AddItem(unpack(SpecialEvent.LaborDay.tbShengliHuiZhang));
		return;		
	end
	if him.nTemplateId == 6813 then
		for i = 1, SpecialEvent.LaborDay.nCount do
			pPlayer.AddItem(unpack(SpecialEvent.LaborDay.tbShengliHuiZhang));
		end
	end
end