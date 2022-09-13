
local tb	= Task:GetTarget("StepEvent");
tb.szTargetName	= "StepEvent";


function tb:Init(szMsg)
	self.szMsg = szMsg;
end;


function tb:Start()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	if MODULE_GAMESERVER then
		Dialog:SendInfoBoardMsg(pPlayer, "<color=Yellow>"..self.szMsg.."<color>");
	else
		UiManager:OpenWindow("UI_INFOBOARD", "<color=Yellow>"..self.szMsg.."<color>");
	end
end;

function tb:Save(nGroupId, nStartTaskId)
	return 0;
end;


function tb:Load(nGroupId, nStartTaskId)
	return 0;
end;


function tb:IsDone()
	return 1;
end;


function tb:GetDesc()
	return "";
end;


function tb:GetStaticDesc()
	return "";
end;

function tb:Close(szReason)
end;

