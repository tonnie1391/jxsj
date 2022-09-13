--Require("\\script\\npc\\faction\\menpaizhangmenren.lua");

--local tbGaiBangMenPaiZhangMenRen = Npc:NewClass("gaibangzhangmenren", "menpaizhangmenren");

local tbJie = Npc:GetClass("jizhu");

function tbJie:OnDialog()
	-- 这里可以加入一些通用的Npc对话事件
	local tbOpt	= {};
	-- local task_value = me.GetTask(1022,77)
	
	if (me.nSex == 1)  then
		tbOpt[#tbOpt+1] = {"我们换个地方说话", self.Send2NewWorld, self};
		tbOpt[#tbOpt+1]	= {"现在还不想去", self.OriginalDialog, self};
		tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
		Dialog:Say(string.format("%s：你来得正好，"..me.szName, him.szName), tbOpt);
		return;
	else
		tbOpt[#tbOpt+1] = {"我们换个地方说话", self.Send2NewWorld2, self};
		tbOpt[#tbOpt+1]	= {"现在还不想去", self.OriginalDialog, self};
		tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
		Dialog:Say(string.format("%s：你来得正好，"..me.szName, him.szName), tbOpt);
		return;
	end;
end


function tbJie:Send2NewWorld()
	me.NewWorld(419,1607,3208); 
	me.SetFightState(1);
end

function tbJie:Send2NewWorld2()
	me.NewWorld(418,1607,3208); 
	me.SetFightState(1);
end

-- 原有Npc对话，不会进行对话拦截
function tbJie:OriginalDialog()
	self:OnDialog();
end;
