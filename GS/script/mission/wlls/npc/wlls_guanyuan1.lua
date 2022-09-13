--初级联赛官员
--孙多良
--2008.09.12

local tbNpc = Npc:GetClass("wlls_guanyuan1");

function tbNpc:OnDialog()
	local nGameLevel = 1;
	Wlls.DialogNpc:OnDialog(nGameLevel)
end
