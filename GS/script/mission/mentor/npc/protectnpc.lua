 ------------------------------------------------------
-- 文件名　：protectnpc.lua
-- 创建者　：zhaoyu
-- 创建时间：2009/10/30 9:38:45
-- 描  述  ：
------------------------------------------------------

local tbNpc = Npc:GetClass("mentor_protect");

function tbNpc:OnDialog()
	local szMsg = "没事别点我！！";
	
	Dialog:Say(szMsg);
end

function tbNpc:OnDeath(pNpc)
	assert(him)
	
	local tbMiss = Esport.Mentor:GetMission(him);
	if not tbMiss then
		return;
	end
	
	tbMiss:SendMessage("挑战失败，副本即将关闭！");
	self.tbOverTimer = Timer:Register(5 * Env.GAME_FPS, self.OnGameOver, self, tbMiss); --5秒钟后关闭副本
end

function tbNpc:OnGameOver(tbMiss)
	tbMiss:OnGameOver();
	
	--这个计时器只需要执行一次，执行过后关闭
	Timer:Close(self.tbOverTimer);
	self.tbOverTimer = nil;
end