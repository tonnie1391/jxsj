-- 文件名　：rank_trap.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-05-11 11:10:35
-- 描  述  ：名次trap点


local tbMap 	= Map:GetClass(1535);

local tbTrap 	= {};
function tbTrap:OnPlayer()
	local nRank = self.nRank;
	local tbMis = Esport.DragonBoat:GetPlayerMission(me);
	if tbMis and tbMis:IsOpen() == 1 then
		local nSaveRank = tbMis:GetRank(me);
		if tbMis:GetPlayerGroupId(me) > 0 and nRank ~= nSaveRank and nSaveRank < Esport.DragonBoat.DEF_FINISH_RANK then
			tbMis:SetRank(nRank);
		end
	end
end

for nRank = 0, 69 do
	local tbTemp = tbMap:GetTrapClass("pm"..nRank);
	for szFnc in pairs(tbTrap) do			-- 复制函数
		tbTemp[szFnc] = tbTrap[szFnc];
	end
	tbTemp.nRank = nRank;
end

local tbMap1 	= Map:GetClass(2107);

local tbTrap1 	= {};
function tbTrap1:OnPlayer()
	local nRank = self.nRank;
	local tbMis = Esport.DragonBoat:GetPlayerMission(me);
	if tbMis and tbMis:IsOpen() == 1 then
		local nSaveRank = tbMis:GetRank(me);
		if tbMis:GetPlayerGroupId(me) > 0 and nRank ~= nSaveRank and nSaveRank < Esport.DragonBoat.DEF_FINISH_RANK then
			tbMis:SetRank(nRank);
		end
	end
end

for nRank = 0, 69 do
	local tbTemp = tbMap1:GetTrapClass("pm"..nRank);
	for szFnc in pairs(tbTrap1) do			-- 复制函数
		tbTemp[szFnc] = tbTrap[szFnc];
	end
	tbTemp.nRank = nRank;
end
