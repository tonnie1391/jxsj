-------------------------------------------------------
-- 文件名　：atlantis_npc_chefu.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-03-15 16:07:55
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\boss\\atlantis\\atlantis_def.lua");

local tbNpc = Npc:GetClass("atlantis_npc_chefu");

function tbNpc:OnDialog()
	local szMsg = "Tại sao ngươi muốn quay lại? Lần đầu tiên thấy sự ác liệt của nơi này đúng không? Tốt nhất là ở một nơi ít nguy hiểm hơn";
	local tbOpt = 
	{
		{"<color=yellow>Trở Lại Phượng Tường<color>", self.ReturnCity, self},
		{"Tôi biết rồi"},
	};
	Dialog:Say(szMsg, tbOpt);		
end

function tbNpc:ReturnCity()
	Atlantis:SafeLeave(me);
end
