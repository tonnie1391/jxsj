-- 高级跨服联赛官

local tbNpc = Npc:GetClass("gbwlls_guanyuan3");

function tbNpc:OnDialog()
--	if (GLOBAL_AGENT) then
--		-- 如果黄金跨服联赛还没开那么就转到高级联赛
--		if (0 == GbWlls:CheckOpenGoldenGbWlls()) then
--			Dialog:Say("本大区黄金跨服联赛未开放！请到高级跨服联赛官员那里报名参加高级跨服联赛吧！");
--			return;
--		end
--	end
	local nGameLevel = 2;
	GbWlls.DialogNpc:OnDialog(nGameLevel)	
end
