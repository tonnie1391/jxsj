local tbMap	= Map:GetClass(2152);
-- 往祭坛方向
local tbTrap_1 = tbMap:GetTrapClass("jisichang_enter");

tbTrap_1.tbSendPos = {1750, 3414};
function tbTrap_1:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	-- 正在战斗中不能进入,有可能绕过了trap点，则允许他跨过这个点重新进来
	if tbInstancing.tbTollgateReset[4] == 0 and  tbInstancing.tbAttendPlayerList[me.nId] ~= 1 then
		me.NewWorld(me.nMapId, self.tbSendPos[1], self.tbSendPos[2]);
		Dialog:SendBlackBoardMsg(me, "Đồng đội vẫn còn đang chiến đấu.");
	end
end
-- 祭坛往外方向

local tbTrap_2 = tbMap:GetTrapClass("jisichang_exit");

tbTrap_2.tbSendPos = {
	[1] = {1720, 3400},
	[2] = {1721, 3387},
	[3] = {1733, 3386},
	[4] = {1736, 3398},
	};
	
function tbTrap_2:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	-- 正在战斗中不能出去，随机传到场内某一点
	local nRand = MathRandom(#self.tbSendPos);
	if tbInstancing.tbTollgateReset[4] == 0 then
		me.NewWorld(me.nMapId, self.tbSendPos[nRand][1], self.tbSendPos[nRand][2]);
		Dialog:SendBlackBoardMsg(me, "Muốn đi? Không dễ dàng vậy đâu!");
	end
end

-- 祭坛去校场
local tbTrap_3 = tbMap:GetTrapClass("jisichang2jiaochang");
tbTrap_3.tbSendPos = {1695, 3363};
function tbTrap_3:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[4] ~= 2 then
		me.NewWorld(me.nMapId, self.tbSendPos[1], self.tbSendPos[2]);
		Dialog:SendBlackBoardMsg(me, "Đánh bại Đại Tế Tự trước khi rời khỏi đây!");
	end
end

-- 祭祀场跑回后营
local tbTrap_4 = tbMap:GetTrapClass("jisichang2houying");
function tbTrap_4:OnPlayer()
	me.NewWorld(me.nMapId, 1695, 3363);
end