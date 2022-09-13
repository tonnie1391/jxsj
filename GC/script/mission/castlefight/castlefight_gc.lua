-- castlefight_gc.lua
-- zhouchenfei
-- 奖励函数
-- 2010/11/6 13:53:08

if (not MODULE_GC_SERVER) then
	return 0;
end

Require("\\script\\mission\\castlefight\\castlefight_def.lua");

function CastleFight:ApplySignUp(tbPlayerList)
	Console:ApplySignUp(self.DEF_EVENT_TYPE, tbPlayerList);
end

--开始报名
function CastleFight:ScheduleCallOut_Common(nTask)
	local tbConsole = self:GetConsole();
	if tbConsole:CheckState() == 1 then
		tbConsole:StartSignUp();
	end
end

function CastleFight:UpdateLadder()
	PlayerHonor:OnSchemeUpdateCastleFightHonorLadder();
end
