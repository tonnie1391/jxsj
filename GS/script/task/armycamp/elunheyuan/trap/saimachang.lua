local tbMap	= Map:GetClass(2152);

-- 从比武场方向进入马场
local tbTrap_1 = tbMap:GetTrapClass("biwuchang2saimachang");

tbTrap_1.tbSendPos = {1759, 3591};

function tbTrap_1:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	-- 这关没有结束始终不允许通过
	if tbInstancing.tbTollgateReset[2] ~= 2 then
		me.NewWorld(me.nMapId, self.tbSendPos[1], self.tbSendPos[2]);
		if tbInstancing.tbTollgateReset[2] == 1 then
			Dialog:SendBlackBoardMsg(me, "Ở đây đang có chuyện gì? Hãy hỏi thăm người xung quanh!");
		end
	end
end

