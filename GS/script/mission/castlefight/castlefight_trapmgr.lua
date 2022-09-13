-- 文件名  : castlefight_trapmgr.lua
-- 创建者  : zounan
-- 创建时间: 2010-11-26 11:52:53
-- 描述    : TRAP管理 因为用的是动态地图所以TRAP要新加,函数用模板地图函数

Require("\\script\\mission\\castlefight\\base\\base_trap.lua");
Require("\\script\\mission\\castlefight\\castlefight_file.lua");


function CastleFight:GetTrapInfo(nMapId, bDyn)
	bDyn = bDyn or 1;
	self.tbTrapMgrList = self.tbTrapMgrList or {};
	
	if not self.tbTrapMgrList[nMapId] then	
		self.tbTrapMgrList[nMapId] = self:InitTrapForOneMap(nMapId, bDyn);
	end
	
	return self.tbTrapMgrList[nMapId];
end

--模板地图函数
CastleFight.NpcTrap_TEMP    = {};
CastleFight.PlayerTrap_TEMP = {};

--NPC TRAP
for i = 1, 2 do
	CastleFight.NpcTrap_TEMP[i] = Lib:NewClass(CastleFight.tbBaseTrap);
	local tbNpcTrap = CastleFight.NpcTrap_TEMP[i];
	function tbNpcTrap:OnCharacterLeftTrap(pCharacter,szClassName)
		CastleFight:SetNpcMoveAI(pCharacter,CastleFight:GetNpcCamp(pCharacter),1);
	end
	
	function tbNpcTrap:OnCharacterRightTrap(pCharacter,szClassName)
		CastleFight:SetNpcMoveAI(pCharacter,CastleFight:GetNpcCamp(pCharacter),2);
	end
end

--PLAYER TRAP
for i = 1, 2 do
	CastleFight.PlayerTrap_TEMP[i] = Lib:NewClass(CastleFight.tbBaseTrap);
	local tbPlayerTrap = CastleFight.PlayerTrap_TEMP[i];
	function tbPlayerTrap:OnCharacterLeftTrap(pCharacter,szClassName)
		local tbPlayerTempTable = CastleFight:GetPlayerTempTable(pCharacter);	
		pCharacter.SetFightState(2 - tbPlayerTempTable.nCamp);
	end
	
	function tbPlayerTrap:OnCharacterRightTrap(pCharacter,szClassName)
		local tbPlayerTempTable = CastleFight:GetPlayerTempTable(pCharacter);	
		pCharacter.SetFightState(tbPlayerTempTable.nCamp - 1);
	end	
end

function CastleFight:InitTrapForOneMap(nMapId,bDyn)
	bDyn = bDyn or 1;
	local tbTrapList 		= {};
	tbTrapList.tbNpcTrap 	= {};
	tbTrapList.tbPlayerTrap = {};
--	CastleFight.PlayerTrap  =  CastleFight.PlayerTrap or Lib:NewClass(CastleFight.tbBaseTrap);	
--	tbTrapList.tbPlayerTrap =  CastleFight.PlayerTrap; --Lib:NewClass(CastleFight.PlayerTrap);
--	if not tbTrapList.tbPlayerTrap.tbTrapList then
--		tbTrapList.tbPlayerTrap:InitTrapTable(self.TEMP_TRAP_PLAYER);
--	end
	
	for i = 1, 2 do
		tbTrapList.tbNpcTrap[i] = self.NpcTrap_TEMP[i];
		if not tbTrapList.tbNpcTrap[i].tbTrapList then
			tbTrapList.tbNpcTrap[i]:InitTrapTable(self.TEMP_TRAP_NPC[i]);
		end		
		tbTrapList.tbNpcTrap[i]:AttachMapToTrap(nMapId,bDyn);
	end	

	for i = 1, 2 do
		tbTrapList.tbPlayerTrap[i] = self.PlayerTrap_TEMP[i];
		if not tbTrapList.tbPlayerTrap[i].tbTrapList then
			tbTrapList.tbPlayerTrap[i]:InitTrapTable(self.TEMP_TRAP_PLAYER[i]);
		end		
		tbTrapList.tbPlayerTrap[i]:AttachMapToTrap(nMapId,bDyn);
	end		
	
	
	--tbTrapList.tbPlayerTrap:AttachMapToTrap(nMapId,bDyn);
	return tbTrapList;
end

--需要静态地图先
if  MODULE_GAMESERVER then
	CastleFight:GetTrapInfo(CastleFight.TEMP_MAP_ID, 0);
	CastleFight:GetTrapInfo(CastleFight.TEMP_MAP_ID2, 0);
end

