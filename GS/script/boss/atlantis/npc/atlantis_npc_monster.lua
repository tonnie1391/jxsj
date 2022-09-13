-------------------------------------------------------
-- 文件名　：atlantis_npc_monster.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-03-15 19:14:53
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\boss\\atlantis\\atlantis_def.lua");

local tbNpc = Atlantis.MonsterClass or {};
Atlantis.MonsterClass = tbNpc;

-- 死亡事件
function tbNpc:OnDeath(pNpcKiller)
	local nPlayerId = pNpcKiller.GetPlayer() and pNpcKiller.GetPlayer().nId or 0;
	local nDropTimes = Atlantis:GetCurDropTimes();
	him.DropRateItem(Atlantis.MONSTER_DROP_FILE, nDropTimes, -1, -1, nPlayerId);
	Atlantis._nTotalDropTimes = (Atlantis._nTotalDropTimes or 0) + 1;
	Atlantis:OnMonsterDeath(him);
end;

-- 血量触发
function tbNpc:OnLifePercentReduceHere(nLifePercent)

	local nMapId, nMapX, nMapY = him.GetWorldPos();
	if nMapId ~= Atlantis.MAP_ID then
		return 0;
	end

	local tbInfo = Atlantis:GetMonsterById(him.dwId);
	if not tbInfo then
		return 0;
	end
	
	local tbBaby = Atlantis.MONSTER_BABY[him.nTemplateId];
	for _, tbLife in ipairs(tbBaby or {}) do
		if nLifePercent == tbLife.nPercent then
			local tbTmp = {{-5, 0}, {5, 0}, {0, -5}, {0, 5}};
			for i = 1, 4 do
				local pNpc = KNpc.Add2(tbLife.nBabyId, Atlantis.NPC_LEVEL, -1, nMapId, nMapX + tbTmp[i][1], nMapY + tbTmp[i][2]);
				if pNpc then
					Atlantis:OnAddMonsterBaby(him.dwId, pNpc.dwId);
				end	
			end
		end
	end
end

-- 掉落物品回调
function tbNpc:DeathLoseItem(tbLoseItem)
	
	local tbItem = tbLoseItem.Item;
	local tbList = {};
	
	-- 列清单
	for _, nItemId in pairs(tbItem or {}) do
		local pItem = KItem.GetObjById(nItemId);
		if pItem then
			local szName = pItem.szName;					
			if not tbList[szName] then
				tbList[szName] = 1;
			else
				tbList[szName] = tbList[szName] + 1;
			end
		end
	end

	for szItemName, nCount in pairs(tbList) do
		StatLog:WriteStatLog("stat_info", "loulangucheng", "pve", me.nId, szItemName, nCount);
	end
end

function Atlantis:LinkNpc()
	for i, tbInfo in pairs(self.MONSTER_LIST) do
		local tbNpc = Npc:GetClass(tbInfo.szNpcClass);
		for szFunNpc, _ in pairs(self.MonsterClass) do
			tbNpc[szFunNpc] = self.MonsterClass[szFunNpc];
		end
	end
end

Atlantis:LinkNpc();
