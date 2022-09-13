-------------------------------------------------------
-- 文件名　：newland_npc_chefu.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-09-06 17:48:15
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\newland\\newland_def.lua");

local tbNpc = Npc:GetClass("newland_npc_chefu");

function tbNpc:OnDialog()
	
	local szMsg = "铁浮城太危险，我可以带您回英雄岛。";
	local tbOpt = 
	{
		{"<color=yellow>铁浮城洗点<color>", self.ResetPoint, self},
		{"返回英雄岛", self.ReturnLand, self},
		{"Ta hiểu rồi"},
	};
		
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:ReturnLand()
	-- balance
	if Newland:CheckIsBalance() == 1 then
		Newland:RemoveBalance(me);
	end
	Transfer:NewWorld2GlobalMap(me);
end

function tbNpc:ResetPoint()
	
	local tbDashi = Npc:GetClass("xisuidashi");
	local szMsg = "我可帮你洗去已分配的潜能点和技能点，供你重新分配。";
	local tbOpt = 
	{
		{"洗潜能点", tbDashi.OnResetDian, tbDashi, me, 1},
		{"洗技能点", tbDashi.OnResetDian, tbDashi, me, 2},
		{"洗潜能点和技能点", tbDashi.OnResetDian, tbDashi, me, 0},
		{"Quay lại", self.OnDialog, self},
	};	

	Dialog:Say(szMsg, tbOpt);
end
