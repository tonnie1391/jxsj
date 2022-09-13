-- 弩马
local tbNuma = Npc:GetClass("elunheyuan_numa");
function tbNuma:OnDeath(pKillerNpc)
	local nSubWorld = him.GetWorldPos();
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	Npc:GetClass("elunheyuan_maguan"):KillHorse(him.dwId, nSubWorld, pKillerPlayer.nId, 1);
end

-- 骏马
local tbJunma = Npc:GetClass("elunheyuan_junma");
function tbJunma:OnDeath(pKillerNpc)
	local nSubWorld = him.GetWorldPos();
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	Npc:GetClass("elunheyuan_maguan"):KillHorse(him.dwId, nSubWorld, pKillerPlayer.nId, 2);
end

-- 马王
local tbMawang = Npc:GetClass("elunheyuan_mawang");
function tbMawang:OnDeath(pKillerNpc)
	local nSubWorld = him.GetWorldPos();
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	Npc:GetClass("elunheyuan_maguan"):KillHorse(him.dwId, nSubWorld, pKillerPlayer.nId, 3);
end

-- 眩晕马，打中了会眩晕
local tbXuanyunma = Npc:GetClass("elunheyuan_xuanyunma");
tbXuanyunma.nDurTime = 2 * 18;
function tbXuanyunma:OnDeath(pKillerNpc)
	local nSubWorld = him.GetWorldPos();
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[2] ~= 0 then
		return;
	end
	-- 加眩晕状态
	pKillerPlayer.AddSkillState(2245, 1, 1, self.nDurTime);
end

-- cd马，打中了清cd
local tbCDma = Npc:GetClass("elunheyuan_cdma");
tbCDma.nDurTime = 3 * 18;
function tbCDma:OnDeath(pKillerNpc)
	local nSubWorld = him.GetWorldPos();
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[2] ~= 0 then
		return;
	end
	-- 加眩晕状态
	pKillerPlayer.AddSkillState(2734, 1, 1, self.nDurTime);
	Npc:GetClass("elunheyuan_maguan"):KillHorse(him.dwId, nSubWorld, pKillerPlayer.nId, 5);
	Dialog:SendBlackBoardMsg(pKillerPlayer, "Thi triển chiêu thức liên tục trong 3 giây!");
end

-- 羊
local tbYang = Npc:GetClass("elunheyuan_horseyang");
function tbYang:OnDeath(pKillerNpc)
	local nSubWorld = him.GetWorldPos();
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	Npc:GetClass("elunheyuan_maguan"):KillHorse(him.dwId, nSubWorld, pKillerPlayer.nId, 6, 1);
end

-- 鹿
local tbLu = Npc:GetClass("elunheyuan_horselu");
function tbLu:OnDeath(pKillerNpc)
	local nSubWorld = him.GetWorldPos();
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	Npc:GetClass("elunheyuan_maguan"):KillHorse(him.dwId, nSubWorld, pKillerPlayer.nId, 7, 1);
end
