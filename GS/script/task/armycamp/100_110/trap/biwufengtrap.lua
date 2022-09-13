-----------------------------------------------------------
-- 文件名　：biwufengtrap.lua
-- 文件描述：碧蜈峰trap点脚本
-- 创建者　：ZhangDeheng
-- 创建时间：2008-11-26 19:46:12
-----------------------------------------------------------

-- 杀死蝎王 才可通过此点
local tbMap	= Map:GetClass(560);
local tbTrap_1 = tbMap:GetTrapClass("to_shenzhufeng");

tbTrap_1.tbSendPos = {1827, 3047};

function tbTrap_1:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	if (tbInstancing.nBiWuFengPass == 0) then
		me.NewWorld(me.nMapId, self.tbSendPos[1],self.tbSendPos[2]);
	end;
end