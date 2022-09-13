--Require("\\script\\npc\\faction\\menpaizhangmenren.lua");

--local tbGaiBangMenPaiZhangMenRen = Npc:NewClass("gaibangzhangmenren", "menpaizhangmenren");

local tbJie = Npc:GetClass("peiyifei");

function tbJie:OnDialog()
	-- 这里可以加入一些通用的Npc对话事件
	local tbOpt	= {};
	-- local task_value = me.GetTask(1022,80)
	
	if (me.nSex == 1) then
		tbOpt[#tbOpt+1] = {"佯装打败我，来吧！", self.Send2NewWorld};
		tbOpt[#tbOpt+1]	= {"现在还不想去", self.OriginalDialog};
		tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
		Dialog:Say(string.format("%s：你来得正好，"..me.szName, him.szName), tbOpt);
		return;
	else
		tbOpt[#tbOpt+1] = {"佯装打败我，来吧！", self.Send2NewWorld2};
		tbOpt[#tbOpt+1]	= {"现在还不想去", self.OriginalDialog};
		tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
		Dialog:Say(string.format("%s：你来得正好，"..me.szName, him.szName), tbOpt);
		return;
	end;
end


function tbJie:Send2NewWorld()
	me.NewWorld(427,1609,3252); 
	me.SetFightState(1);
end

function tbJie:Send2NewWorld2()
	me.NewWorld(426,1609,3252); 
	me.SetFightState(1);
end

-- 原有Npc对话，不会进行对话拦截
function tbJie:OriginalDialog()
end;
