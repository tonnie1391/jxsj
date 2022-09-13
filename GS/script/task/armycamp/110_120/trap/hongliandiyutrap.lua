-------------------------------------------------------
-- 文件名　：hongliandiyutrap.lua
-- 文件描述：红莲地狱
-- 创建者　：ZhangDeheng
-- 创建时间：2009-04-09 16:10:10
-------------------------------------------------------

local tbMap = Map:GetClass(493);
local tbTrap_1 = tbMap:GetTrapClass("to_huo1");

tbTrap_1.tbSendPos = {1971, 3800}

function tbTrap_1:OnPlayer()
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(me.nMapId);
	if (not tbInstancing) then
		return;
	end;
	if (tbInstancing.tbDiYuTrap[7] ~= 1) then
		me.NewWorld(me.nMapId, self.tbSendPos[1], self.tbSendPos[2]);
	end;
end

local tbMap = Map:GetClass(493);
local tbTrap_2 = tbMap:GetTrapClass("to_huo2");

tbTrap_2.tbSendPos = {1959, 3715}

function tbTrap_2:OnPlayer()
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(me.nMapId);
	if (not tbInstancing) then
		return;
	end;
	if (tbInstancing.tbDiYuTrap[8] ~= 1) then
		me.NewWorld(me.nMapId, self.tbSendPos[1], self.tbSendPos[2]);
	end;
end

local tbMap = Map:GetClass(493);
local tbTrap_3 = tbMap:GetTrapClass("to_huo3");

tbTrap_3.tbSendPos = {1993, 3629}

function tbTrap_3:OnPlayer()
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(me.nMapId);
	if (not tbInstancing) then
		return;
	end;
	if (tbInstancing.tbDiYuTrap[9] ~= 1) then
		me.NewWorld(me.nMapId, self.tbSendPos[1], self.tbSendPos[2]);
	end;
end



local tbMap = Map:GetClass(493);
local tbTrap_10 = tbMap:GetTrapClass("to_boss3");

tbTrap_10.tbSendPos = {1820, 3646}

function tbTrap_10:OnPlayer()
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(me.nMapId);
	if (not tbInstancing) then
		return;
	end;
	if (tbInstancing.nTrap10Pass == 1) then
		me.NewWorld(me.nMapId, self.tbSendPos[1], self.tbSendPos[2]);
	end;
end


local tbMap = Map:GetClass(493);
local tbTrap_11 = tbMap:GetTrapClass("to_fbover");

tbTrap_11.tbSendPos = {
	[24] = {1934,3414},
	[25] = {1444,3091},
	[29] = {1577,4114},
	}

function tbTrap_11:OnPlayer()
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(me.nMapId);
	if (not tbInstancing) then
		return;
	end;
	
	local nMapId = me.GetTask(2043, 2);
	if (nMapId ~= 24 and nMapId ~= 25 and nMapId ~= 29) then
		nMapId = 29;
	end
	
	if (tbInstancing.nTrap11Pass == 1) then
		me.NewWorld(nMapId, self.tbSendPos[nMapId][1], self.tbSendPos[nMapId][2]);
	end;
end