-------------------------------------------------------
-- 文件名　：zhunbeiqutrap.lua
-- 文件描述：战斗和非战斗状态的转换
-- 创建者　：ZhangDeheng
-- 创建时间：2009-03-16 09:23:05
-------------------------------------------------------

-- 转为战斗状态
local tbMap = Map:GetClass(493);
local tbTrap = tbMap:GetTrapClass("hlwm_trap1");

tbTrap.tbSendPos = {{1605, 3177}, {1599, 3163}}

function tbTrap:OnPlayer()
	if (me.nFightState == 0) then
		me.NewWorld(me.nMapId, self.tbSendPos[1][1], self.tbSendPos[1][2]);
		me.SetFightState(1);
	else
		me.NewWorld(me.nMapId, self.tbSendPos[2][1], self.tbSendPos[2][2]);
		me.SetFightState(0);
	end;	
end;

