-- 文件名  : treasuremap2_death.lua
-- 创建者  : zounan
-- 创建时间: 2010-08-19 20:47:34
-- 描述    : 

Require("\\script\\task\\treasuremap2\\treasuremap2_def.lua");

local tbNpc = Npc:GetClass("treasuremap2_death");

function tbNpc:OnDeath(pNpc)		
	local nMapId, nMapX, nMapY	= him.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);

	if not tbInstancing then
		return;
	end	
	
	local nNpcScore  =  him.GetTempTable("TreasureMap2").nNpcScore or 0;

	TreasureMap2:AddKillNpcNum(tbInstancing);	
	if  nNpcScore == 0 then
		return;
	end
	TreasureMap2:AddInstanceScore(tbInstancing, nNpcScore);
--	tbInstancing:UpdateUI();
end

