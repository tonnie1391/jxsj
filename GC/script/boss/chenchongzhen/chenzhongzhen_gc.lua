-- 文件名　：chenzhongzhen_gc.lua
-- 创建者　：zhangjunjie
-- 创建时间：2012-02-20 14:36:58
-- 描述：gc

if not MODULE_GC_SERVER then
	return;
end

--gc申请副本回调
function ChenChongZhen:ApplyGame_GC(nPlayerId,nServerId,nApplyMapId)
	GSExcute(GCEvent.nGCExecuteFromId or -1,{"ChenChongZhen:ApplyGame_GS", nPlayerId,nServerId,nApplyMapId});
end

--gc结束副本
function ChenChongZhen:EndGame_GC(nPlayerId,nServerId,nMapId)
	GlobalExcute{"ChenChongZhen:EndGame_GS", nPlayerId,nServerId,nMapId};
end

--同步给每个gs申请的副本，保证每个队伍只有一个副本
function ChenChongZhen:SyncGameMapInfo_GC(nPlayerId,szName,nApplyMapId)
	GlobalExcute{"ChenChongZhen:SyncGameMapInfo_GS",nPlayerId,szName,nApplyMapId};
end

