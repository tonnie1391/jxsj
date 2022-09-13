local tbMap	= Map:GetClass(2152);
-- 狩猎场障碍
local tbTrap_1 = tbMap:GetTrapClass("shouliechang_exit");

function tbTrap_1:OnPlayer()
	me.NewWorld(me.nMapId, 1819, 3528)	;
end

-- 狩猎场入口
local tbTrap_2 = tbMap:GetTrapClass("shouliechang_enter");
tbTrap_2.tbSendPos = {
	[1] = {1799, 3584},
	[2] = {1808, 3569},
	};
function tbTrap_2:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[3] == 0 then
		me.NewWorld(nSubWorld, unpack(self.tbSendPos[1]));
		Dialog:SendBlackBoardMsg(me, "Hãy chờ đợi đồng đội săn bắn hoàn tất.");
	elseif tbInstancing.tbTollgateReset[3] == 1 then
		TaskAct:Talk("狩猎是草原人从小起就需要熟练掌握的技艺，蒙人小孩自小骑羊擎木弓练习骑射，方有今日之精湛箭术。狩猎比赛也是在草原上考校一个人实力的重要标准。向猎官咨询一下考验的细则吧！");
	end
end

-- 狩猎场回马场
local tbTrap_3 = tbMap:GetTrapClass("shouliechang2machang");
tbTrap_3.tbSendPos = {
	[1] = {1808, 3569},
	[2] = {1799, 3584},
	};
function tbTrap_3:OnPlayer()
	local nSubWorld, _, _	= me.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	if tbInstancing.tbTollgateReset[3] == 0 then
		me.NewWorld(nSubWorld, unpack(self.tbSendPos[1]));
	end
end