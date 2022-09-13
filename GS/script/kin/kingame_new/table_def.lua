-- 文件名　：table_def.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-06-27 17:35:38
-- 描述：一些setting表的读取


Require("\\script\\kin\\kingame_new\\room_def.lua")


KinGame2.MapTrap = {};

function KinGame2:LoadTrap()
	self.MapTrap = {};
	local szFile = string.format("%s\\maptrap.txt",self.BASEPATH);
	local tbFile = Lib:LoadTabFile(szFile);
	if tbFile then
		for _, tbItem in pairs(tbFile) do
			local nRoomId  		= tonumber(tbItem.RoomId);
			local szTrapName  = tbItem.TrapName;
			local nPosX 			= tonumber(tbItem.TRPOSX);
			local nPosY 			= tonumber(tbItem.TRPOSY);
			local nDirection		= tonumber(tbItem.Direction);
			if self.MapTrap[nRoomId] == nil then
				self.MapTrap[nRoomId]	= {};
			end
			self.MapTrap[nRoomId][szTrapName] = {nPosX,nPosY,nDirection};
		end
	end	
end

KinGame2:LoadTrap()


KinGame2.tbAttackWineNpcAiPos = {};	--攻击酒坛的npc的ai路线，顺序和WINE_NPC_POS一致

function KinGame2:LoadWineAttackAiPos()
	self.tbAttackWineNpcAiPos = {};
	for i = 1,#self.WINE_NPC_POS do 
		local szFile = string.format("%s\\wine_attack_%d.txt",self.BASEPATH,i);
		local tbFile = Lib:LoadTabFile(szFile);
		if tbFile then
			for _,tbTrap in ipairs(tbFile) do
				local nPosX = tonumber(tbTrap.TRAPX);
				local nPosY = tonumber(tbTrap.TRAPY);
				if not self.tbAttackWineNpcAiPos[i] then
					self.tbAttackWineNpcAiPos[i] = {};
				end
				table.insert(self.tbAttackWineNpcAiPos[i],{nPosX,nPosY});
			end			
		end
	end
end

KinGame2:LoadWineAttackAiPos();


--读取开启第四关的路上的npc的pos
KinGame2.ENTER_4TH_ROOM_NORMAL_ENEMY_POS_LEFT = {};
KinGame2.ENTER_4TH_ROOM_NORMAL_ENEMY_POS_RIGHT = {};
function KinGame2:LoadNormalEnemyPos()
	self.ENTER_4TH_ROOM_NORMAL_ENEMY_POS_LEFT = {};
	self.ENTER_4TH_ROOM_NORMAL_ENEMY_POS_RIGHT = {};
	local szFile = string.format("%s\\room3_normal_enemy_left.txt",self.BASEPATH);
	local tbFile = Lib:LoadTabFile(szFile);
	if tbFile then
		for _,tbPos in pairs(tbFile) do
			local nPosX = tonumber(tbPos.TRAPX) / 32;
			local nPosY = tonumber(tbPos.TRAPY) / 32;
			table.insert(self.ENTER_4TH_ROOM_NORMAL_ENEMY_POS_LEFT,{nPosX,nPosY});
		end
	end
	local szFile = string.format("%s\\room3_normal_enemy_right.txt",self.BASEPATH);
	local tbFile = Lib:LoadTabFile(szFile);
	if tbFile then
		for _,tbPos in pairs(tbFile) do
			local nPosX = tonumber(tbPos.TRAPX) / 32;
			local nPosY = tonumber(tbPos.TRAPY) / 32;
			table.insert(self.ENTER_4TH_ROOM_NORMAL_ENEMY_POS_RIGHT,{nPosX,nPosY});
		end
	end
end

KinGame2:LoadNormalEnemyPos();

KinGame2.ROOM3_AI_POS = {};

function KinGame2:LoadRoom3AiPos()
	self.ROOM3_AI_POS = {};
	for i = 1,#self.SHUSHENG_ENEMY_POS do 
		local szFile = string.format("%s\\room3_ai_%d.txt",self.BASEPATH,i);
		local tbFile = Lib:LoadTabFile(szFile);
		if tbFile then
			for _,tbTrap in ipairs(tbFile) do
				local nPosX = tonumber(tbTrap.TRAPX);
				local nPosY = tonumber(tbTrap.TRAPY);
				if not self.ROOM3_AI_POS[i] then
					self.ROOM3_AI_POS[i] = {};
				end
				table.insert(self.ROOM3_AI_POS[i],{nPosX,nPosY});
			end			
		end
	end
end

KinGame2:LoadRoom3AiPos();


KinGame2.SHUSHENG_ARMY_POS = {};

function KinGame2:LoadShuShengArmyPos()
	self.SHUSHENG_ARMY_POS = {};
	local szFile = string.format("%s\\shusheng_army.txt",self.BASEPATH);
	local tbFile = Lib:LoadTabFile(szFile);
	if tbFile then
		for _,tbPos in pairs(tbFile) do
			local nPosX = tonumber(tbPos.TRAPX) / 32;
			local nPosY = tonumber(tbPos.TRAPY) / 32;
			table.insert(self.SHUSHENG_ARMY_POS,{nPosX,nPosY});
		end
	end
end

KinGame2:LoadShuShengArmyPos();