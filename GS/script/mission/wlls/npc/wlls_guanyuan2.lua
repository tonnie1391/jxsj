--高级联赛官员
--孙多良
--2008.09.12

local tbNpc = Npc:GetClass("wlls_guanyuan2");

function tbNpc:OnDialog()
	local nGameLevel = 2;
	Wlls.DialogNpc:OnDialog(nGameLevel)
end
