
local tb	= Task:GetTarget("TipPopo");
tb.szTargetName	= "TipPopo";


function tb:Init(nGroupId)
	self.nGroupId = nGroupId;
end;


function tb:Start()
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	pPlayer.CallClientScript({"PopoTip:ShowPopo", self.nGroupId});
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
	local pPlayer = self:Base_GetPlayerObj();
	if not pPlayer then
		return;
	end
	pPlayer.CallClientScript({"PopoTip:HidePopo", self.nGroupId});
end;

