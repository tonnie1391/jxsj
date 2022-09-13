-- 文件名　：strat_trap.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-05-11 11:24:04
-- 描  述  ：起点

local tbMap 	= Map:GetClass(1535);

local tbTrap 	= tbMap:GetTrapClass("trap_start");

function tbTrap:OnPlayer()
	local tbMis = Esport.DragonBoat:GetPlayerMission(me);
	if tbMis and tbMis:IsOpen() == 1 then
		if tbMis:GetGameState() ~= 2 then
			local nR = MathRandom(#Esport.DragonBoat.MAP_POS_START);
			me.NewWorld(me.nMapId, unpack(Esport.DragonBoat.MAP_POS_START[nR]));
			return 0;
		end
	end
end

local tbMap1 	= Map:GetClass(2107);

local tbTrap1 	= tbMap1:GetTrapClass("trap_start");

function tbTrap1:OnPlayer()
	local tbMis = Esport.DragonBoat:GetPlayerMission(me);
	if tbMis and tbMis:IsOpen() == 1 then
		if tbMis:GetGameState() ~= 2 then
			local nR = MathRandom(#Esport.DragonBoat.MAP_POS_START);
			me.NewWorld(me.nMapId, unpack(Esport.DragonBoat.MAP_POS_START[nR]));
			return 0;
		end
	end
end
