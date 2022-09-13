--Require("\\script\\npc\\faction\\menpaizhangmenren.lua");

--local tbGaiBangMenPaiZhangMenRen = Npc:NewClass("gaibangzhangmenren", "menpaizhangmenren");

local tbJie = Npc:GetClass("zhonglingxiu");

function tbJie:OnDialog()
	-- 这里可以加入一些通用的Npc对话事件
	local tbOpt	= {};
	-- local task_value = me.GetTask(1022,78)
	
	-- if task_value == 1 then
		tbOpt[#tbOpt+1] = {"去打败来敌首领", self.Send2NewWorld};
		tbOpt[#tbOpt+1]	= {"现在还不想去", self.OriginalDialog};
		tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
		Dialog:Say(string.format("%s：你来得正好，"..me.szName, him.szName), tbOpt);
		return;
	-- end;	
end


function tbJie:Send2NewWorld()
	me.NewWorld(474,1630,3243); 
	me.SetFightState(1);
end

-- 原有Npc对话，不会进行对话拦截
function tbJie:OriginalDialog()
end;
