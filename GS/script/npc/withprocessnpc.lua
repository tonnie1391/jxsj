
local tbNpc = Npc:GetClass("withprocesstagnpc"); 

function tbNpc:OnDialog()
	Task:OnExclusiveDialogNpc();
end;
