-- npc_readymap.lua
-- zhouchenfei
-- 兑换物品函数
-- 2010/11/6 13:53:08

local tbNpc = Npc:GetClass("castlefightnpc_ready");

function tbNpc:OnDialog()
	local szMsg = "Bạn muốn rời khỏi đây?\n";
	local tbOpt = {
		{"Đúng vậy, ta có việc phải đi", self.OnLeave, self},
		{"Ta chỉ xem qua"},
	}
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnLeave()
	local nMapId, nPosX, nPosY = EPlatForm:GetLeaveMapPos();	
	me.TeamApplyLeave();			--离开队伍
	me.NewWorld(nMapId, nPosX, nPosY);
end
