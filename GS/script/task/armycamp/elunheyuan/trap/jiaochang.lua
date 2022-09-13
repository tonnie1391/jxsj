local tbMap	= Map:GetClass(2152);
-- 祭祀场往校场的入口
local tbTrap_1 = tbMap:GetTrapClass("jiaochang_enter");
tbTrap_1.tbSendPos = {1681,3346};
function tbTrap_1:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[5] == 0 then
		me.NewWorld(me.nMapId, self.tbSendPos[1], self.tbSendPos[2]);
	elseif tbInstancing.tbTollgateReset[5] == 1 then
		Dialog:SendBlackBoardMsg(me, "Trên sân xuất hiện những ngọn cờ kỳ quá, hãy kiểm tra");
	end
end

-- 校场往可汗大帐的的出口
local tbTrap_2 = tbMap:GetTrapClass("jiaochang2dazhang");
tbTrap_2.tbSendPos = {1665,3299};
function tbTrap_2:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[5] ~= 2 then
		Dialog:SendBlackBoardMsg(me, "Mộc Hoa Lê: Muốn gặp Kha Hãn thì phải thông qua ta đã.");
		me.NewWorld(me.nMapId, self.tbSendPos[1], self.tbSendPos[2]);
	else
		me.Msg("Cần trả lời các câu hỏi vấn đáp mới có thể đi qua.");
	end
end

-- 校场往祭坛的出口
local tbTrap_3 = tbMap:GetTrapClass("jiaochang_exit");
tbTrap_3.tbSendPos = {1669,3332};
function tbTrap_3:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[5] == 0 then
		me.NewWorld(me.nMapId, self.tbSendPos[1], self.tbSendPos[2]);
	end
end
