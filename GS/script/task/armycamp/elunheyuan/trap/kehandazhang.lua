local tbMap	= Map:GetClass(2152);
-- 可汗大帐入口
local tbTrap_1 = tbMap:GetTrapClass("kehandazhang_enter");
tbTrap_1.tbSendPos = {1702,3249};
function tbTrap_1:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[6] ~= 2 then
		me.NewWorld(me.nMapId, self.tbSendPos[1], self.tbSendPos[2]);
		Dialog:SendBlackBoardMsg(me, "Chỉ những người thuộc về nơi này mới có thể vào!");
	elseif tbInstancing.tbTollgateReset[7] == 0 then
		me.NewWorld(me.nMapId, self.tbSendPos[1], self.tbSendPos[2]);
		Dialog:SendBlackBoardMsg(me, "Đại Hãn chiến đấu không muốn bị ai làm phiền!");
	end
end

-- 可汗大帐出口
local tbTrap_1 = tbMap:GetTrapClass("kehandazhang_exit");
tbTrap_1.tbSendPos = {1712,3233};
function tbTrap_1:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[6] ~= 2 then
		me.NewWorld(me.nMapId, self.tbSendPos[1], self.tbSendPos[2]);
		Dialog:SendBlackBoardMsg(me, "Muốn đi à? Muộn rồi!");
	elseif tbInstancing.tbTollgateReset[7] == 0 then
		me.NewWorld(me.nMapId, self.tbSendPos[1], self.tbSendPos[2]);
		Dialog:SendBlackBoardMsg(me, "Đây không phải là nơi tùy tiện ra vào!");
	end
end
