--Require("\\script\\npc\\faction\\menpaizhangmenren.lua");

--local tbGaiBangMenPaiZhangMenRen = Npc:NewClass("gaibangzhangmenren", "menpaizhangmenren");

local tbJie = Npc:GetClass("wuxi");

function tbJie:OnDialog()
	-- 这里可以加入一些通用的Npc对话事件
	local tbOpt	= {};
	local task_value = me.GetTask(1022,39)
	
	if task_value == 1 then
		tbOpt[#tbOpt+1] = {"继续向吴曦挑战", self.Send2NewWorld};
		tbOpt[#tbOpt+1]	= {"现在还不想挑战", self.OriginalDialog};
		tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
		Dialog:Say(string.format("%s：你来得正好，me.szname。", him.szName), tbOpt);
		return;
	end;
	
	self:OriginalDialog();
end


function tbJie:Send2NewWorld()
	me.NewWorld(197,1801,3867);
	me.SetFightState(1);
end

-- 原有Npc对话，不会进行对话拦截
function tbJie:OriginalDialog()
	self:OnDialog();
end;
