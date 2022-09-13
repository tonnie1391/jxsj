--联赛准备场官员
--孙多良
--2008.09.12

local tbNpc = Npc:GetClass("wlls_guanyuan4");

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
	local szLeagueName = League:GetMemberLeague(Wlls.LGTYPE, me.szName);
	if not szLeagueName then
		Dialog:Say("您还没有战队！");
		return 0;
	end
	
	local nInReadyMap = 0;
	for _,nReadyMapId in pairs(Wlls.MACTH_TO_MAP) do
		if nReadyMapId == me.nMapId then
			nInReadyMap = 1;
			break;
		end
	end
	
	if nInReadyMap == 0 then
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
	--local nEnterReadyId = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_ATTEND);
	local nGameLevel = League:GetLeagueTask(Wlls.LGTYPE, szLeagueName, Wlls.LGTASK_MLEVEL);
	Wlls:KickPlayer(me, "您离开了准备场", nGameLevel);
end
