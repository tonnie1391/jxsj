-- FileName	: minigamenpc.lua
-- Author	: furuilei
-- Time		: 2010-1-25 16:28
-- Comment	: ½á»éÐ¡ÓÎÏ·npc£¨¸£ÁÙÃÅ£©

local tbNpc = Npc:GetClass("marry_fulinmen");

function tbNpc:OnDialog()
	if (Marry:CheckState() == 0) then
		return 0;
	end
	Marry.MiniGame:OnDialog(him.dwId);
end
