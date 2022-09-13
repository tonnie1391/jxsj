local tbMap	= Map:GetClass(2152);
-- 侠客时可汗大帐入口
local tbTrap_1 = tbMap:GetTrapClass("kehandazhang_enter2");
tbTrap_1.tbSendPos = {1702,3249};
function tbTrap_1:OnPlayer()
	print("aaaaaaaaaa");
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[7] == 0 then
		me.NewWorld(me.nMapId, self.tbSendPos[1], self.tbSendPos[2]);
		Dialog:SendBlackBoardMsg(me, "Đại Hãn không muốn ai làm phiền khi đang chiến đấu.");
	end
end

-- 侠客时可汗大帐出口
local tbTrap_1 = tbMap:GetTrapClass("kehandazhang_exit2");
tbTrap_1.tbSendPos = {1712,3233};
function tbTrap_1:OnPlayer()
	print("bbbbbbbbbbb");
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[7] == 0 then
		me.NewWorld(me.nMapId, self.tbSendPos[1], self.tbSendPos[2]);
		Dialog:SendBlackBoardMsg(me, "Đại Hãn không cho ngươi đi thì ngươi không thể đi.");
	end
end
