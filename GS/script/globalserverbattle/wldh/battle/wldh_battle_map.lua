-------------------------------------------------------
-- 文件名　：wldh_battle_map.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-09-22 23:48:29
-- 文件描述：
-------------------------------------------------------

Require("\\script\\globalserverbattle\\wldh\\battle\\wldh_battle_def.lua");

local tbBattle = Wldh.Battle;

function tbBattle:AddSyncPlayer(pPlayer)
	if not pPlayer or not self.tbFinalList then
		return;
	end
	if not self.tbSyncList then
		self.tbSyncList = {};
	end
	self.tbSyncList[pPlayer.nId] = 1;
	
	Dialog:SyncCampaignDate(pPlayer, "wldh_battle", self.tbFinalList, 15 * 60 * Env.GAME_FPS);
end

function tbBattle:RemoveSyncPlayer(pPlayer)
	if not pPlayer then
		return;
	end
	if not self.tbSyncList or not self.tbSyncList[pPlayer.nId] then
		return;
	end
	self.tbSyncList[pPlayer.nId] = nil;
	
	Dialog:SyncCampaignDate(pPlayer, "wldh_battle", nil, 0);
end

local tbMap = {};
local tbMapId = {{1623, 1628}};

function tbMap:OnEnter(szParam)
	Wldh.Battle:AddSyncPlayer(me);
end;

function tbMap:OnLeave(szParam)
	Wldh.Battle:RemoveSyncPlayer(me);
end;

for _, varMap in pairs(tbMapId) do
	for nMapId = varMap[1], varMap[2] do
		local tbSyncMap = Map:GetClass(nMapId);
		for szFnc in pairs(tbMap) do
			tbSyncMap[szFnc] = tbMap[szFnc];
		end
	end
end
