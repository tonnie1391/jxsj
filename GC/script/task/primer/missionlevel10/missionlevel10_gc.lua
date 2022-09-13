-- 文件名　：missionlevel10_gc.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-09-19 21:09:03
-- 描述：10级教育副本gc

if not MODULE_GC_SERVER then
	return;
end

Task.PrimerLv10 = Task.PrimerLv10 or {};

local PrimerLv10 = Task.PrimerLv10;

--gc申请副本回调
function PrimerLv10:ApplyGame_GC(nPlayerId,nServerId,nApplyMapId)
	GSExcute(GCEvent.nGCExecuteFromId or -1,{"Task.PrimerLv10:ApplyGame_GS", nPlayerId,nServerId,nApplyMapId});
end

function PrimerLv10:ApplyStaticGame_GC(nPlayerId,nServerId)
	GSExcute(GCEvent.nGCExecuteFromId or -1,{"Task.PrimerLv10:ApplyStaticGame_GS",nPlayerId,nServerId});
end

--gc结束副本
function PrimerLv10:EndGame_GC(nPlayerId,nServerId,nMapId)
	GlobalExcute{"Task.PrimerLv10:EndGame_GS", nPlayerId,nServerId,nMapId};
end

--同步给每个gs申请的副本，保证每个队伍只有一个副本
function PrimerLv10:SyncGameMapInfo_GC(nPlayerId,szName,nApplyMapId)
	GlobalExcute{"Task.PrimerLv10:SyncGameMapInfo_GS",nPlayerId,szName,nApplyMapId};
end

