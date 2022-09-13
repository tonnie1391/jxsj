-- 初级跨服联赛官

local tbNpc = Npc:GetClass("gbwlls_guanyuan2");

function tbNpc:OnDialog()
--	if (GLOBAL_AGENT) then
--		-- 如果黄金跨服联赛还没开那么就转到高级联赛
--		if (0 == GbWlls:CheckOpenGoldenGbWlls()) then
--			local nGameLevel = 2;
--			GbWlls.DialogNpc:OnDialog(nGameLevel)
--			return;
--		end
--	end
	
	Dialog:Say("Hiện tại vẫn chưa mở!");
	
--	local nGameLevel = 1;
--	GbWlls.DialogNpc:OnDialog(nGameLevel)	
end
