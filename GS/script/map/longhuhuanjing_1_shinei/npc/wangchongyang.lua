--Require("\\script\\npc\\faction\\menpaizhangmenren.lua");

--local tbGaiBangMenPaiZhangMenRen = Npc:NewClass("gaibangzhangmenren", "menpaizhangmenren");

local tbJie = Npc:GetClass("wangchongyang");

function tbJie:OnDialog()
	-- 这里可以加入一些通用的Npc对话事件
	local tbOpt	= {};
	--local task_value = me.GetTask(1022,66)
	
	--if task_value == 1 then
		tbOpt[#tbOpt+1] = {"抓住假冒空无大师", self.Send2NewWorld};
		tbOpt[#tbOpt+1]	= {"现在还不想去抓他", self.OriginalDialog};
		tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
		Dialog:Say(string.format("%s：你来得正好，"..me.szName, him.szName), tbOpt);
		return;
	--end;
end


function tbJie:Send2NewWorld()
	me.NewWorld(438,1540,3115);
	me.SetFightState(1);
end

-- 原有Npc对话，不会进行对话拦截
function tbJie:OriginalDialog()
end;
