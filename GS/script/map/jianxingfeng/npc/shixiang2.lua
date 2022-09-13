--Require("\\script\\npc\\faction\\menpaizhangmenren.lua");

--local tbGaiBangMenPaiZhangMenRen = Npc:NewClass("gaibangzhangmenren", "menpaizhangmenren");

local tbJie = Npc:GetClass("shixiang2");

function tbJie:OnDialog()
	-- 这里可以加入一些通用的Npc对话事件
	local tbOpt	= {};
	--local task_value = me.GetTask(1022,82)
	
	--if task_value == 1 then
		tbOpt[#tbOpt+1] = {"要再次挑战第二重考验吗？", self.Send2NewWorld};
		tbOpt[#tbOpt+1]	= {"现在还不想去", self.OriginalDialog};
		tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
		Dialog:Say(string.format("%s：你来得正好，"..me.szName, him.szName), tbOpt);
		return;
	--end;
end


function tbJie:Send2NewWorld()
	me.NewWorld(429,1608,3201);
	me.SetFightState(1);
end

-- 原有Npc对话，不会进行对话拦截
function tbJie:OriginalDialog()
	
end;
