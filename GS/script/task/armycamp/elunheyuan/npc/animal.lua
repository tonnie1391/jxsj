-- ÍÃ×Ó
local tbTu = Npc:GetClass("elunheyuan_tuizi");
function tbTu:OnDeath(pKillerNpc)
	local nSubWorld = him.GetWorldPos();
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	Npc:GetClass("elunheyuan_animalmanager"):KillAnimal(him.dwId, nSubWorld, pKillerPlayer.nId, 1);
end

-- ÍÃÍõ
local tbKingTu = Npc:GetClass("elunheyuan_kingtu");
function tbKingTu:OnDeath(pKillerNpc)
	local nSubWorld = him.GetWorldPos();
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	Npc:GetClass("elunheyuan_animalmanager"):KillAnimal(him.dwId, nSubWorld, pKillerPlayer.nId, 1, 1);
end

-- Â¹
local tbLu = Npc:GetClass("elunheyuan_lu");
function tbLu:OnDeath(pKillerNpc)
	local nSubWorld = him.GetWorldPos();
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	Npc:GetClass("elunheyuan_animalmanager"):KillAnimal(him.dwId, nSubWorld, pKillerPlayer.nId, 2);
end

-- Â¹Íõ
local tbKingLu = Npc:GetClass("elunheyuan_kinglu");
function tbKingLu:OnDeath(pKillerNpc)
	local nSubWorld = him.GetWorldPos();
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	Npc:GetClass("elunheyuan_animalmanager"):KillAnimal(him.dwId, nSubWorld, pKillerPlayer.nId, 2, 1);
end

-- ÀÇ
local tbLang = Npc:GetClass("elunheyuan_lang");
function tbLang:OnDeath(pKillerNpc)
	local nSubWorld = him.GetWorldPos();
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	Npc:GetClass("elunheyuan_animalmanager"):KillAnimal(him.dwId, nSubWorld, pKillerPlayer.nId, 3);
end

-- ÀÇÍõ
local tbKingLang = Npc:GetClass("elunheyuan_kinglang");
function tbKingLang:OnDeath(pKillerNpc)
	local nSubWorld = him.GetWorldPos();
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	Npc:GetClass("elunheyuan_animalmanager"):KillAnimal(him.dwId, nSubWorld, pKillerPlayer.nId, 3, 1);
end

-- »¢
local tbHu = Npc:GetClass("elunheyuan_hu");
function tbHu:OnDeath(pKillerNpc)
	local nSubWorld = him.GetWorldPos();
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	Npc:GetClass("elunheyuan_animalmanager"):KillAnimal(him.dwId, nSubWorld, pKillerPlayer.nId, 4);
end

-- »¢Íõ
local tbKingHu = Npc:GetClass("elunheyuan_kinghu");
function tbKingHu:OnDeath(pKillerNpc)
	local nSubWorld = him.GetWorldPos();
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	Npc:GetClass("elunheyuan_animalmanager"):KillAnimal(him.dwId, nSubWorld, pKillerPlayer.nId, 4, 1);
end

-- ÐÜ
local tbXiong = Npc:GetClass("elunheyuan_xiong");
function tbXiong:OnDeath(pKillerNpc)
	local nSubWorld = him.GetWorldPos();
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	Npc:GetClass("elunheyuan_animalmanager"):KillAnimal(him.dwId, nSubWorld, pKillerPlayer.nId, 5);
end

-- ÐÜÍõ
local tbKingXiong = Npc:GetClass("elunheyuan_kingxiong");
function tbKingXiong:OnDeath(pKillerNpc)
	local nSubWorld = him.GetWorldPos();
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	Npc:GetClass("elunheyuan_animalmanager"):KillAnimal(him.dwId, nSubWorld, pKillerPlayer.nId, 5, 1);
end

-- Ë«±¶¹Ö
local tbAnimalDouble = Npc:GetClass("elunheyuan_statedouble");

function tbAnimalDouble:OnDeath(pKillerNpc)
	local nSubWorld = him.GetWorldPos();
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	Npc:GetClass("elunheyuan_animalmanager"):AddSpecialState(him.dwId, nSubWorld, pKillerPlayer.nId, 1);
end

-- ÕÐÐ¡¹Ö
local tbAnimalHuge = Npc:GetClass("elunheyuan_statehuge");

function tbAnimalHuge:OnDeath(pKillerNpc)
	local nSubWorld = him.GetWorldPos();
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	Npc:GetClass("elunheyuan_animalmanager"):AddSpecialState(him.dwId, nSubWorld, pKillerPlayer.nId, 2);
end

-- ¹¥»÷¹Ö
local tbAnimalAttack = Npc:GetClass("elunheyuan_stateattack");

function tbAnimalAttack:OnDeath(pKillerNpc)
	local nSubWorld = him.GetWorldPos();
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	Npc:GetClass("elunheyuan_animalmanager"):AddSpecialState(him.dwId, nSubWorld, pKillerPlayer.nId, 3);
end

-- debuff¹Ö
local tbAnimalDebuff = Npc:GetClass("elunheyuan_debuff");

function tbAnimalDebuff:OnDeath(pKillerNpc)
	local nSubWorld = him.GetWorldPos();
	local pKillerPlayer = pKillerNpc.GetPlayer();
	if not pKillerPlayer then
		return 0;
	end
	Npc:GetClass("elunheyuan_animalmanager"):AddSpecialState(him.dwId, nSubWorld, pKillerPlayer.nId, 4);
end