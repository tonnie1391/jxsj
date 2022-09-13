--老玩家召回

--活动系统开关
local tbClass = EventManager:GetClass("event_playercallback")
function tbClass:ExeStartFun()
	EventManager.ExEvent.tbPlayerCallBack.nOpen = 1;
end

function tbClass:ExeEndFun()
	EventManager.ExEvent.tbPlayerCallBack.nOpen = 0;
end
