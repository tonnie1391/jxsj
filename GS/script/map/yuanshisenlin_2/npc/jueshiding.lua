--Require("\\script\\npc\\faction\\menpaizhangmenren.lua");

--local tbGaiBangMenPaiZhangMenRen = Npc:NewClass("gaibangzhangmenren", "menpaizhangmenren");

local tbJie = Npc:GetClass("jueshiding");

function tbJie:OnDialog()
	-- 这里可以加入一些通用的Npc对话事件
	local tbOpt	= {};
	-- local task_value = me.GetTask(1022,25)
	
	-- if task_value == 1 then
		tbOpt[#tbOpt+1] = {"去参加英雄宴吗？", self.Send2NewWorld, self};
--		tbOpt[#tbOpt+1]	= {"现在还不想去", self.OriginalDialog,self};
		tbOpt[#tbOpt+1]	= {"现在还不想去"};
		Dialog:Say(string.format("%s：你来得正好，"..me.szName, him.szName), tbOpt);
		return;
	-- end;
end


function tbJie:Send2NewWorld()
	me.NewWorld(420,1630,3237); 
	me.SetFightState(0);
end

-- 原有Npc对话，不会进行对话拦截
function tbJie:OriginalDialog()
	self:OnDialog();
end;
