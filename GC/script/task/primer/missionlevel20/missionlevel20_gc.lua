-- 文件名　：missionlevel20_gc.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-09-20 10:22:31
-- 描述：20级教育副本gc

if not MODULE_GC_SERVER then
	return;
end

Task.PrimerLv20 = Task.PrimerLv20 or {};

local PrimerLv20 = Task.PrimerLv20;

--gc申请副本回调
function PrimerLv20:ApplyGame_GC(nPlayerId,nServerId,nApplyMapId)
	GSExcute(GCEvent.nGCExecuteFromId or -1,{"Task.PrimerLv20:ApplyGame_GS", nPlayerId,nServerId,nApplyMapId});
end

--gc结束副本
function PrimerLv20:EndGame_GC(nPlayerId,nServerId,nMapId)
	GlobalExcute{"Task.PrimerLv20:EndGame_GS", nPlayerId,nServerId,nMapId};
end

function PrimerLv20:ApplyStaticGame_GC(nPlayerId,nServerId)
	GSExcute(GCEvent.nGCExecuteFromId or -1,{"Task.PrimerLv20:ApplyStaticGame_GS",nPlayerId,nServerId});
end

--同步给每个gs申请的副本，保证每个队伍只有一个副本
function PrimerLv20:SyncGameMapInfo_GC(nPlayerId,szName,nApplyMapId)
	GlobalExcute{"Task.PrimerLv20:SyncGameMapInfo_GS",nPlayerId,szName,nApplyMapId};
end



