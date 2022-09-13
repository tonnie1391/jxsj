-- 文件名　：crosstimeroom_gc.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-08-01 15:22:45
-- 描述：时光屋gc

if not MODULE_GC_SERVER then
	return;
end

--gc申请副本回调
function CrossTimeRoom:ApplyGame_GC(nPlayerId,nServerId,nApplyMapId)
	GSExcute(GCEvent.nGCExecuteFromId or -1,{"CrossTimeRoom:ApplyGame_GS", nPlayerId,nServerId,nApplyMapId});
end

--gc结束副本
function CrossTimeRoom:EndGame_GC(nPlayerId,nServerId,nMapId)
	GlobalExcute{"CrossTimeRoom:EndGame_GS", nPlayerId,nServerId,nMapId};
end

--同步给每个gs申请的副本，保证每个队伍只有一个副本
function CrossTimeRoom:SyncGameMapInfo_GC(nPlayerId,szName,nApplyMapId)
	GlobalExcute{"CrossTimeRoom:SyncGameMapInfo_GS",nPlayerId,szName,nApplyMapId};
end

--每天刷出传送npc
function CrossTimeRoom:AddApplyNpc()
	GlobalExcute{"CrossTimeRoom:AddApplyNpc_GS"};
end

function CrossTimeRoom:SetCloseState(bClose)
	-- 0 是开启，1是关闭
	KGblTask.SCSetDbTaskInt(DBTASK_CROSSTIMEROOM_CLOSESTATE,bClose or 0);
end

