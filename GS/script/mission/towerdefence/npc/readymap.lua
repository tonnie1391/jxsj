--准备场npc
--孙多良
--2008.12.29

local tbNpc = Npc:GetClass("td_ready");

function tbNpc:OnDialog()
	local szMsg = "你不参加比赛了吗？\n";
	local tbOpt = {
		{"是的，我有急事要离开", self.OnLeave, self},
		{"Ta chỉ xem qua"},
	}
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnLeave()
	local nMapId, nPosX, nPosY = EPlatForm:GetLeaveMapPos();	
	me.TeamApplyLeave();			--离开队伍
	me.NewWorld(nMapId, nPosX, nPosY);
end

