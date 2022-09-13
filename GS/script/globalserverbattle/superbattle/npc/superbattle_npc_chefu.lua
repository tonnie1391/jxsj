-------------------------------------------------------
-- 文件名　 : superbattle_npc_chefu.lua
-- 创建者　 : zhangjinpin@kingsoft
-- 创建时间 : 2011-06-09 16:48:11
-- 文件描述 :
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\superbattle\\superbattle_def.lua");

local tbNpc = Npc:GetClass("superbattle_npc_chefu");

function tbNpc:OnDialog()
	
	local szMsg = "    Nhất nhập hồ hải tam thập niên! Ngươi muốn đi đâu?";
	local tbOpt = 
	{
		{"Về Đảo Anh Hùng", self.ReturnLand, self},
		{"Ta hiểu rồi"},
	};
		
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:ReturnLand()
	Transfer:NewWorld2GlobalMap(me, SuperBattle.TRANS_POS);
end
