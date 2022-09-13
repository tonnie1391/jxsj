-------------------------------------------------------
-- 文件名　：jingjimilintrap.lua
-- 文件描述：荆棘密林TRAP点
-- 创建者　：ZhangDeheng
-- 创建时间：2009-03-16 09:32:51
-------------------------------------------------------


local tbMap	= Map:GetClass(493);
local tbTrap_1 = tbMap:GetTrapClass("trapjingji");

tbTrap_1.szText = "不小心被荆棘割破了皮肤! 我感觉越来越昏迷......";

function tbTrap_1:OnPlayer()
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(me.nMapId);
	if (not tbInstancing) then
		return;
	end;
	
	TaskAct:Talk(self.szText, self.Return, self, me.nId);
end

function tbTrap_1:Return(nId)
	local pPlayer = KPlayer.GetPlayerObjById(nId);
	if (not pPlayer) then
		return;
	end;
	
	pPlayer.NewWorld(pPlayer.nMapId, 1586, 3157);
	pPlayer.SetFightState(0);
	return 0;
end;

local tbMap	= Map:GetClass(493);
local tbTrap_2 = tbMap:GetTrapClass("to_ceng1");

tbTrap_2.szDesc		= "to_ceng1";

tbTrap_2.tbSendPos	= {{1720, 3289}, {1841, 3211}};

function tbTrap_2:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	if (tbInstancing.nTrap2Pass == 0) then
		me.NewWorld(me.nMapId, self.tbSendPos[1][1],self.tbSendPos[1][2]);
	else
		me.NewWorld(me.nMapId, self.tbSendPos[2	][1],self.tbSendPos[2][2]);
		tbInstancing:OnCoverBegin(me);
		Task.tbArmyCampInstancingManager:ShowTip(me, "Long Ngũ nói thứ tự <color=red>Phong Lâm Hỏa Sơn<color> mà mở ra.");
		me.Msg("Long Ngũ nói thứ tự Phong Lâm Hỏa Sơn mà mở ra.");
	end;	
end;
