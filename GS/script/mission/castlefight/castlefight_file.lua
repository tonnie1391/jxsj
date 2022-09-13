-- 文件名  : castlefight_file.lua
-- 创建者  : zounan
-- 创建时间: 2010-12-09 10:11:37
-- 描述    : 读文件

Require("\\script\\mission\\castlefight\\castlefight_def.lua");

function CastleFight:LoadNpcDesc()	
	local tbFile = Lib:LoadTabFile("\\setting\\mission\\castlefight\\npcinfo.txt");
	if not tbFile then
		print("【ERR】 castlefight: LoadNpcDesc : not file");
		return;
	end
	
	
	self.NPC_TEMPLATE = {};
	for nIndex, tbParam in ipairs(tbFile) do
		if nIndex > 1 then
			local nId  = tonumber(tbParam.Id);
			self.NPC_TEMPLATE[nId] = {};
			self.NPC_TEMPLATE[nId].nId	 		= nId;
			self.NPC_TEMPLATE[nId].nNpcId 		= tonumber(tbParam.NpcId);
			self.NPC_TEMPLATE[nId].szName		= tbParam.Name;
			self.NPC_TEMPLATE[nId].nLevel 		= tonumber(tbParam.NpcLevel)  or 100;
			self.NPC_TEMPLATE[nId].nSeries 		= tonumber(tbParam.NpcSeries) or -1;
			self.NPC_TEMPLATE[nId].nDeathMoney	= tonumber(tbParam.DeathMoney) or 1;
			self.NPC_TEMPLATE[nId].nDeathScore	= tonumber(tbParam.DeathScore) or 1;
			self.NPC_TEMPLATE[nId].nProductCD	= tonumber(tbParam.ProductCD) or 1;
			self.NPC_TEMPLATE[nId].nProductScore = tonumber(tbParam.ProductScore) or 0;
			self.NPC_TEMPLATE[nId].nProductMoney = tonumber(tbParam.ProductMoney) or 1;
			self.NPC_TEMPLATE[nId].nIsBuilding	= tonumber(tbParam.IsBuilding) or 0;
			self.NPC_TEMPLATE[nId].nProductNpc	= tonumber(tbParam.ProductNpcId) or 0;
			self.NPC_TEMPLATE[nId].nLevelUpMoney = tonumber(tbParam.LevelUpMoney) or 1;
			self.NPC_TEMPLATE[nId].nLevelUpCD 	= tonumber(tbParam.LevelUpCD) or 1;	
			self.NPC_TEMPLATE[nId].nLevelUpNpc	= tonumber(tbParam.LevelUpNpc) or 0;
			self.NPC_TEMPLATE[nId].nDeathSpeMoney	= tonumber(tbParam.SpeMoney) or 0;
		end
	end
end

function CastleFight:LoadObjFile()
	self.TEMP_OBJ = {};
	self.TEMP_OBJ[1]  = self:LoadObjFileEx("\\setting\\mission\\castlefight\\obj_left.txt");
	self.TEMP_OBJ[2]  = self:LoadObjFileEx("\\setting\\mission\\castlefight\\obj_right.txt");
end

function CastleFight:LoadObjFileEx(szFilePath)
	local tbFile = Lib:LoadTabFile(szFilePath);
	if not tbFile then
		print("【ERR】CastleFight:LoadObjFileEx", szFilePath);
		return;
	end
	
	local TEMP_OBJ = {};
	for nId, tbParam in ipairs(tbFile) do
		TEMP_OBJ[#TEMP_OBJ + 1] = {};
		TEMP_OBJ[#TEMP_OBJ].nRange = tonumber(tbParam.Range);
		TEMP_OBJ[#TEMP_OBJ].nX	 = math.floor(tonumber(tbParam.TRAPX)/32);		
		TEMP_OBJ[#TEMP_OBJ].nY	 = math.floor(tonumber(tbParam.TRAPY)/32);		
		TEMP_OBJ[#TEMP_OBJ].nDirect = tonumber(tbParam.Direct);			
	end
	return TEMP_OBJ;
end


function CastleFight:LoadNpcMove()
	self.NPC_MOVE 	 = {};
	self.NPC_MOVE[1] = {};
	self.NPC_MOVE[1][1] = self:LoadNpcMoveEx("\\setting\\mission\\castlefight\\npc_move_left_up.txt");
	self.NPC_MOVE[1][2] = self:LoadNpcMoveEx("\\setting\\mission\\castlefight\\npc_move_left_down.txt");
	
	self.NPC_MOVE[2] = {};
	
	self.NPC_MOVE[2][1] = self:LoadNpcMoveEx("\\setting\\mission\\castlefight\\npc_move_right_up.txt");
	self.NPC_MOVE[2][2] = self:LoadNpcMoveEx("\\setting\\mission\\castlefight\\npc_move_right_down.txt");
		
--	self.NPC_MOVE[2][1] = self:ReserverTable(self.NPC_MOVE[1][2]);
--	self.NPC_MOVE[2][2] = self:ReserverTable(self.NPC_MOVE[1][2]);
end

function CastleFight:LoadNpcMoveEx(szFilePath)
	local tbFile = Lib:LoadTabFile(szFilePath);
	if not tbFile then
		print("【ERR】CastleFight:LoadNpcMoveEx", szFilePath);
		return;
	end	
	local tbTable = {};
	for nId, tbParam in ipairs(tbFile) do
		tbTable[#tbTable + 1] = {};
		tbTable[#tbTable][1] = tonumber(tbParam.TRAPX);
		tbTable[#tbTable][2] = tonumber(tbParam.TRAPY);
	end	
	return tbTable;
end

function CastleFight:ReserverTable(tbSrc)
	if not tbSrc then
		return;
	end
	
	local tbTable = {};
	for i =1, #tbSrc  do
		tbTable[i] = tbSrc[#tbSrc - i + 1];
	end
	return tbTable;
end


function CastleFight:LoadNpcTrap()
	self.TEMP_TRAP_NPC   = {};
	self.TEMP_TRAP_NPC[1]   = self:LoadTrapFile("\\setting\\mission\\castlefight\\trap\\npc_trap_down.txt");
	self.TEMP_TRAP_NPC[2]   = self:LoadTrapFile("\\setting\\mission\\castlefight\\trap\\npc_trap_up.txt");
	self.TEMP_TRAP_PLAYER = {};
	self.TEMP_TRAP_PLAYER[1] = self:LoadTrapFile("\\setting\\mission\\castlefight\\trap\\player_trap_down.txt");
	self.TEMP_TRAP_PLAYER[2] = self:LoadTrapFile("\\setting\\mission\\castlefight\\trap\\player_trap_up.txt");
end

function CastleFight:LoadTrapFile(szFilePath)	
	local tbFile = Lib:LoadTabFile(szFilePath);
	if not tbFile then
		print("【ERR】CastleFight:LoadTrapFile", szFilePath);
		return;
	end
	
	local tbTrapList = {};
	for nId, tbParam in ipairs(tbFile) do
		tbTrapList[tbParam.ClassName] = {};

		tbTrapList[tbParam.ClassName].tbLeftTrap  = {};
		tbTrapList[tbParam.ClassName].tbLeftTrap.szName = tbParam.LeftTrapName;
		tbTrapList[tbParam.ClassName].tbLeftTrap.tbTrap = {};
		local tbLeftTrap = tbTrapList[tbParam.ClassName].tbLeftTrap.tbTrap;
		local tbLeftFile = Lib:LoadTabFile(tbParam.LeftTrapFile);
		if not tbLeftFile then
			print("【ERR】tbBaseTrap:LoadLeftTabFile", tbLeftFile);
			return;
		end
		
		for _, tbInfo in ipairs(tbLeftFile) do
			tbLeftTrap[#tbLeftTrap+1] = {};
			tbLeftTrap[#tbLeftTrap][1] = math.floor((tonumber(tbInfo.TRAPX)));
			tbLeftTrap[#tbLeftTrap][2] = math.floor((tonumber(tbInfo.TRAPY)));
		end
		
		
		tbTrapList[tbParam.ClassName].tbRightTrap  = {};
		tbTrapList[tbParam.ClassName].tbRightTrap.szName = tbParam.RightTrapName;
		tbTrapList[tbParam.ClassName].tbRightTrap.tbTrap = {};
		local tbRightTrap = tbTrapList[tbParam.ClassName].tbRightTrap.tbTrap;
		local tbRightFile = Lib:LoadTabFile(tbParam.RightTrapFile);
		if not tbRightFile then
			print("【ERR】tbBaseTrap:LoadRightTabFile", tbRightFile);
			return;
		end
		
		for _, tbInfo in ipairs(tbRightFile) do
			tbRightTrap[#tbRightTrap+1] = {};
			tbRightTrap[#tbRightTrap][1] = math.floor((tonumber(tbInfo.TRAPX)));
			tbRightTrap[#tbRightTrap][2] = math.floor((tonumber(tbInfo.TRAPY)));
		end
	end
	return tbTrapList;
end


function CastleFight:LoadInitFile()
	self:LoadNpcDesc();
	self:LoadNpcMove();
	self:LoadObjFile();
	self:LoadNpcTrap();
end

if  MODULE_GAMESERVER then
	 CastleFight:LoadInitFile();
end

