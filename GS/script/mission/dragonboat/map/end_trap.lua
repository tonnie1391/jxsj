-- 文件名　：end_trap.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-05-11 11:24:10
-- 描  述  ：终点

local tbMap 	= Map:GetClass(1535);

local tbTrap 	= tbMap:GetTrapClass("trap_end");

function tbTrap:OnPlayer()
	local tbMis = Esport.DragonBoat:GetPlayerMission(me);
	if tbMis and tbMis:IsOpen() == 1 then
		if tbMis:GetGameState() == 2 and tbMis:GetRank(me) < Esport.DragonBoat.DEF_FINISH_RANK then
			tbMis:SetRank(Esport.DragonBoat.DEF_FINISH_RANK);
			tbMis:OnSingleEndGame(me);
			return 0;
		end
	end	
end

local tbMap1 	= Map:GetClass(2107);

local tbTrap1 	= tbMap1:GetTrapClass("trap_end");

function tbTrap1:OnPlayer()
	local tbMis = Esport.DragonBoat:GetPlayerMission(me);
	if tbMis and tbMis:IsOpen() == 1 then
		if tbMis:GetGameState() == 2 and tbMis:GetRank(me) < Esport.DragonBoat.DEF_FINISH_RANK then
			tbMis:SetRank(Esport.DragonBoat.DEF_FINISH_RANK);
			tbMis:OnSingleEndGame(me);
			return 0;
		end
	end	
end
