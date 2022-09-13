-- 文件名　：miyin_trap.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-05-12 15:15:48
-- 描  述  ：

local tbMap 	= Map:GetClass(1535);
local tbTrap 	= {};

function tbMap:OnPlayerTrap(szClassName)
	local tbTemp = tbMap:GetTrapClass(szClassName);
	tbTemp:OnPlayer();
	--print("dbtrap", szClassName, tbTemp.nGroup, tbTemp.nPoint);
end

function tbTrap:OnPlayer()
	local nGroup = self.nGroup;
	local nPoint = self.nPoint;
	if (me.nFightState ~= 1) then
		return 0;
	end
	--local tbBase = Console:GetBase(Console.DEF_DRAGON_BOAT);
	local tbMis =  Esport.DragonBoat:GetPlayerMission(me);
	if tbMis and tbMis:IsOpen() == 1 then
		local nType = tbMis:GetSkillItem(nGroup, nPoint);
		--print("Tiger Trap:", nGroup, nPoint, nType)
		if nType > 0 then
			if nType == 1 then
				Esport.DragonBoat:OnPlayerType1(nGroup, nPoint);
			elseif nType == 2 then
				Esport.DragonBoat:OnPlayerType2(nGroup, nPoint);
			elseif nType == 3 then
				Esport.DragonBoat:OnPlayerType3(nGroup, nPoint);
			end
		end
	end
end

function tbMap:OnDyLoad(nDynMapId)
	for nGroup = 1, 10 do
		for nPoint = 1, 10 do
			local szKey = string.format("dbrandpos%s_%s", nGroup, nPoint);
			local nX = tonumber(Esport.DragonBoat.tbPosRandom[nGroup][nPoint].TRAPX);
			local nY = tonumber(Esport.DragonBoat.tbPosRandom[nGroup][nPoint].TRAPY);
			AddMapTrap(nDynMapId, nX + 1, nY, szKey);
			AddMapTrap(nDynMapId, nX - 1, nY, szKey);
			AddMapTrap(nDynMapId, nX, nY + 1, szKey);
			AddMapTrap(nDynMapId, nX, nY - 1, szKey);
			AddMapTrap(nDynMapId, nX + 1, nY + 1, szKey);
			AddMapTrap(nDynMapId, nX - 1, nY - 1, szKey);
			AddMapTrap(nDynMapId, nX - 1, nY + 1, szKey);
			AddMapTrap(nDynMapId, nX + 1, nY - 1, szKey);
			--print("ADD TRAP:", nDynMapId, nX, nY);
			local tbTemp = tbMap:GetTrapClass(szKey);
			for szFnc in pairs(tbTrap) do			-- 复制函数
				tbTemp[szFnc] = tbTrap[szFnc];
			end
			tbTemp.nGroup = nGroup;
			tbTemp.nPoint = nPoint;
		end
	end
end


--[[
function tbTrap:InitMapTrap()

end

if MODULE_GAMESERVER then
	--注册GS启动事件，同步地图禁用表
	ServerEvent:RegisterServerStartFunc(tbTrap.InitMapTrap);
end
]]--

local tbMap1 	= Map:GetClass(2107);
local tbTrap1 	= {};

function tbMap1:OnPlayerTrap(szClassName)
	local tbTemp = tbMap1:GetTrapClass(szClassName);
	tbTemp:OnPlayer();
	--print("dbtrap", szClassName, tbTemp.nGroup, tbTemp.nPoint);
end

function tbTrap1:OnPlayer()
	local nGroup = self.nGroup;
	local nPoint = self.nPoint;
	if (me.nFightState ~= 1) then
		return 0;
	end
	--local tbBase = Console:GetBase(Console.DEF_DRAGON_BOAT);
	local tbMis =  Esport.DragonBoat:GetPlayerMission(me);
	if tbMis and tbMis:IsOpen() == 1 then
		local nType = tbMis:GetSkillItem(nGroup, nPoint);
		--print("Tiger Trap:", nGroup, nPoint, nType)
		if nType > 0 then
			if nType == 1 then
				Esport.DragonBoat:OnPlayerType1(nGroup, nPoint);
			elseif nType == 2 then
				Esport.DragonBoat:OnPlayerType2(nGroup, nPoint);
			elseif nType == 3 then
				Esport.DragonBoat:OnPlayerType3(nGroup, nPoint);
			end
		end
	end
end

function tbMap1:OnDyLoad(nDynMapId)
	for nGroup = 1, 10 do
		for nPoint = 1, 10 do
			local szKey = string.format("dbrandpos%s_%s", nGroup, nPoint);
			local nX = tonumber(Esport.DragonBoat.tbPosRandom[nGroup][nPoint].TRAPX);
			local nY = tonumber(Esport.DragonBoat.tbPosRandom[nGroup][nPoint].TRAPY);
			AddMapTrap(nDynMapId, nX + 1, nY, szKey);
			AddMapTrap(nDynMapId, nX - 1, nY, szKey);
			AddMapTrap(nDynMapId, nX, nY + 1, szKey);
			AddMapTrap(nDynMapId, nX, nY - 1, szKey);
			AddMapTrap(nDynMapId, nX + 1, nY + 1, szKey);
			AddMapTrap(nDynMapId, nX - 1, nY - 1, szKey);
			AddMapTrap(nDynMapId, nX - 1, nY + 1, szKey);
			AddMapTrap(nDynMapId, nX + 1, nY - 1, szKey);
			--print("ADD TRAP:", nDynMapId, nX, nY);
			local tbTemp = tbMap1:GetTrapClass(szKey);
			for szFnc in pairs(tbTrap1) do			-- 复制函数
				tbTemp[szFnc] = tbTrap1[szFnc];
			end
			tbTemp.nGroup = nGroup;
			tbTemp.nPoint = nPoint;
		end
	end
end

