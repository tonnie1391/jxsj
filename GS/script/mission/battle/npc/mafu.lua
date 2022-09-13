-- 宋金马夫（车夫）脚本

local tbNpc	= Npc:GetClass("mafu");
tbNpc._tbBase	= Npc:GetClass("chefu");

-- NPC对话
function tbNpc:OnDialog()
	self:SelectMap("city");
end

