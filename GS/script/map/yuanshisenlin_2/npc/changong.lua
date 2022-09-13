--Require("\\script\\npc\\faction\\menpaizhangmenren.lua");

--local tbGaiBangMenPaiZhangMenRen = Npc:NewClass("gaibangzhangmenren", "menpaizhangmenren");

local tbJie = Npc:GetClass("changong");

function tbJie:OnDialog()
	-- 这里可以加入一些通用的Npc对话事件
	local tbOpt	= {};
	-- local task_value = me.GetTask(1022,73)
	
	-- if task_value == 1 then
		tbOpt[#tbOpt+1] = {"去蟾宫?", self.Send2NewWorld};
		tbOpt[#tbOpt+1]	= {"现在还不想去", self.OriginalDialog, self};
		tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
		Dialog:Say(string.format("%s：你来得正好，"..me.szName, him.szName), tbOpt);
		return;
	-- end;
end


function tbJie:Send2NewWorld()
	me.NewWorld(205,1576,3944); 
	me.SetFightState(0);
end

-- 原有Npc对话，不会进行对话拦截
function tbJie:OriginalDialog()
	self:OnDialog();
end;
