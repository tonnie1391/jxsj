local tbMap	= Map:GetClass(2152);
-- 后营到比武场
local tbTrap_1 = tbMap:GetTrapClass("houying2biwuchang");

tbTrap_1.tbSendPos = {1746, 3527};

function tbTrap_1:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	-- 正在战斗中不能进入
	if tbInstancing.tbTollgateReset[1] == 0 then
		me.NewWorld(me.nMapId, self.tbSendPos[1], self.tbSendPos[2]);
	elseif tbInstancing.tbTollgateReset[1] == 1 then
		Dialog:SendBlackBoardMsg(me, "Đối thoại với Hách Xích Lặc để khiêu chiến!");
		me.Msg("Thách thức các chiến binh trên thảo nguyên!");
	end
end

-- 比武场到后营
local tbTrap_2 = tbMap:GetTrapClass("biwuchang_exit");

tbTrap_2.tbSendPos = {1738, 3541};

function tbTrap_2:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);

	if tbInstancing.tbTollgateReset[1] == 0 then
		me.NewWorld(me.nMapId, self.tbSendPos[1], self.tbSendPos[2]);
	end
end

-- 比武场往马场方向的出口
local tbTrap_3 = tbMap:GetTrapClass("biwuchang2machang");

tbTrap_3.tbSendPos = {1739, 3568};

function tbTrap_3:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	-- 正在战斗中不能进入
	if tbInstancing.tbTollgateReset[1] ~= 2 then
		me.NewWorld(me.nMapId, self.tbSendPos[1], self.tbSendPos[2]);
	end
end
