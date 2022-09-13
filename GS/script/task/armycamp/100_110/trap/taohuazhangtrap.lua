-----------------------------------------------------------
-- 文件名　：taohuazhangtrap.lua
-- 文件描述：桃花瘴trap点脚本
-- 创建者　：ZhangDeheng
-- 创建时间：2008-11-26 19:12:37
-----------------------------------------------------------

-- 只有杀死了桃花使，才可通过此点
local tbMap	= Map:GetClass(560);
local tbTrap_1 = tbMap:GetTrapClass("to_biwufeng");

tbTrap_1.tbSendPos = {1678, 2928};

function tbTrap_1:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	if (tbInstancing.nTaoHuaShiPass == 0) then
		me.NewWorld(me.nMapId, self.tbSendPos[1], self.tbSendPos[2]);
	end;
end

local tbMap	= Map:GetClass(560);
local tbTrap_2 = tbMap:GetTrapClass("to_jisi");

tbTrap_2.tbPos = {1663, 3035};

function tbTrap_2:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	if (tbInstancing.nTaoHuaZhangPass == 0) then
		me.NewWorld(nSubWorld, self.tbPos[1], self.tbPos[2]);
	end;
end