-- 文件名　：missionlevel20_gc.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-07-16 09:30:08
-- 功能    ：

if not MODULE_GC_SERVER then
	return;
end

Task.NewPrimerLv20 = Task.NewPrimerLv20 or {};

local NewPrimerLv20 = Task.NewPrimerLv20;

--gc申请副本回调
function NewPrimerLv20:ApplyGameMap_GC(nPlayerId,nServerId)
	if self.tbManagerList[nPlayerId] then
		GlobalExcute{"Task.NewPrimerLv20:ApplyGameFailed", nPlayerId, self.tbManagerList[nPlayerId].nMapId, self.tbManagerList[nPlayerId].nServerId};
		return;
	end
	--分配服务器（找负载比较小的服务器）
	local tbPlayerInfo = GetServerPlayerCount();
	local nMinPlayerServer = 100000;
	local nServerIdEx = 0;
	for nId, nCount in pairs(tbPlayerInfo) do
		--人数少而且没有达最大上限的服务器
		if nId ~= nServerId and nMinPlayerServer >= nCount and (not self.tbServerInfo[nId] or self.tbServerInfo[nId] and self.tbServerInfo[nId].nUseCount < self:GetServerMaxMCount()) then
			nMinPlayerServer = nCount;
			nServerIdEx = nId;
		end
	end
	
	GlobalExcute({"Task.NewPrimerLv20:ApplyGame_GS", nServerIdEx, nPlayerId, -1});
end

--gc结束副本
function NewPrimerLv20:EndGame_GC(nPlayerId,nServerId,nMapId)
	GlobalExcute{"Task.NewPrimerLv20:EndGame_GS", nPlayerId,nServerId,nMapId};
end

--同步给每个gs申请的副本，保证每个队伍只有一个副本
function NewPrimerLv20:SyncGameMapInfo_GC(nPlayerId,szName,nApplyMapId)
	GlobalExcute{"Task.NewPrimerLv20:SyncGameMapInfo_GS",nPlayerId,szName,nApplyMapId};
end
