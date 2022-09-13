--大会准备场官员
--孙多良
--2008.09.12

local tbNpc = Npc:GetClass("Wldh_guanyuan3");

function tbNpc:OnDialog()
	local szMsg = "准备场官员：比赛即将开始,您确定要离开准备场吗？";
	local tbOpt = 
	{
		{"我要离开", self.LevelGame, self},
		{"Kết thúc đối thoại"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:LevelGame(nFlag)
	local nType = Wldh:GetCurGameType();
	local nLGType = Wldh:GetLGType(nType);
	if not nLGType or nLGType == 0 then
		Wldh:KickPlayer(me, "您离开了准备场", nType);
		return 0;
	end
	
	local szLeagueName = League:GetMemberLeague(nLGType, me.szName);
	if not szLeagueName then
		Wldh:KickPlayer(me, "您离开了准备场", nType);
		return 0;
	end
	
	if not nFlag then
		local tbOpt = {
			{"我确定要离开", self.LevelGame, self, 1},
			{"Để ta suy nghĩ lại"},
		}
		Dialog:Say("准备场官员：您现在离开将可能<color=red>无法参加本轮比赛<color>,您确定要离开准备场吗?", tbOpt);
		return 0;
	end
	
	Wldh:KickPlayer(me, "您离开了准备场", nType);
end
