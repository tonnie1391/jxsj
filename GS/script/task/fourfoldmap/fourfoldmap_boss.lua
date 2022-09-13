--4倍地图怪
--sunduoliang
--2008.11.12

local tbBoss = Npc:GetClass("yunling_qianyunshou")

tbBoss.tbDropRatePath = 
{
	[5] = "\\setting\\npc\\droprate\\droprate001.txt",
	[15] = "\\setting\\npc\\droprate\\droprate002.txt",
	[25] = "\\setting\\npc\\droprate\\droprate003.txt",
	[35] = "\\setting\\npc\\droprate\\droprate004.txt",
	[45] = "\\setting\\npc\\droprate\\droprate005.txt",
	[55] = "\\setting\\npc\\droprate\\droprate006.txt",
	[65] = "\\setting\\npc\\droprate\\droprate007.txt",
	[75] = "\\setting\\npc\\droprate\\droprate008.txt",
	[85] = "\\setting\\npc\\droprate\\droprate009.txt",
	[95] = "\\setting\\npc\\droprate\\droprate010.txt",
	[105] = "\\setting\\npc\\droprate\\droprate011.txt",
	[115] = "\\setting\\npc\\droprate\\droprate011.txt",
}


function tbBoss:OnDeath(pNpc)
	if him.GetNpcType() ~= 0 then
		--精英首领调用自己掉落表。
		return 0;
	end
	if not self.tbDropRatePath[him.nLevel] then
		return 0;
	end
	local pPlayer = pNpc.GetPlayer();
	if not pPlayer then
		return 0
	end
	local nLuck = Task.FourfoldMap.DEF_LUCKY + pPlayer.nCurLucky;
	pPlayer.DropRateItem(self.tbDropRatePath[him.nLevel], 1, nLuck, -1, him);
end
