-- 文件名　：crosstimeroom_npc.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-08-02 16:11:02
-- 描述：传送npc

local tbNpc = Npc:GetClass("crosstimeroom_npc")

function tbNpc:OnDialog()
	if KGblTask.SCGetDbTaskInt(DBTASK_CROSSTIMEROOM_CLOSESTATE) ~= 0 then
		Dialog:Say(string.format("Lâm Phong Dương: Ngươi khỏe chứ, %s!",me.szName));
		return 0;
	end
	if TimeFrame:GetState("OpenBoss120") ~= 1 then
		Dialog:Say(string.format("Lâm Phong Dương: Ngươi khỏe chứ, %s!",me.szName));
		return 0;
	else
		local nOpenBoss120Week = Lib:GetLocalWeek(TimeFrame:GetTime("OpenBoss120"));
		local nNowWeek = Lib:GetLocalWeek(GetTime());
		if nNowWeek <= nOpenBoss120Week then
			Dialog:Say(string.format("Lâm Phong Dương: Ngươi khỏe chứ, %s!",me.szName));
			return 0;
		end
	end
	local szMsg = "    Ngươi tìm ta có việc gì?";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"Xông vào Thời Quang Điện",self.Process,self,me.nId};
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg,tbOpt);
end

function tbNpc:Process(nPlayerId)
	local szMsg = "Ta có thể dẫn ngươi đến Thời Quang Điện!";
	local tbOpt = {};
	if me.nFaction <= 0 then
		Dialog:Say("Hãy gia nhập môn phái trước đã");
		return 0;
	end
	if me.nLevel < 100 then
		Dialog:Say("Hãy đạt cấp độ 100 trước đã");
		return 0;
	end
	local nTeamId = me.nTeamId;
	if nTeamId <= 0 then
		Dialog:Say("Hãy tổ đội trước đã");
		return 0;
	end
	local pGame = CrossTimeRoom:GetGameObjByTeamId(me.nTeamId);
	if not pGame then
		tbOpt[#tbOpt + 1] = {"Mở Thời Quang Điện",self.ApplyGame,self,nPlayerId};
	else
		tbOpt[#tbOpt + 1] = {"Tiến vào Thời Quang Điện",self.Transfer,self};
	end
	tbOpt[#tbOpt + 1] = {"Để ta nghĩ lại"};
	Dialog:Say(szMsg,tbOpt);
end


function tbNpc:ApplyGame(nPlayerId)
	if me.nFaction <= 0 then
		Dialog:Say("Hãy gia nhập môn phái trước đã");
		return 0;
	end
	if me.nLevel < 100 then
		Dialog:Say("Hãy đạt cấp độ 100 trước đã");
		return 0;
	end
	if me.nTeamId <= 0 then
		Dialog:Say("Hãy tổ đội trước đã");
		return 0;
	end
	if me.IsCaptain() ~= 1 then
		Dialog:Say("Hãy bảo đội trưởng đến tìm ta");
		return 0;
	end
	local nRet,szError = CrossTimeRoom:CheckCanApply(me.nId);
	if nRet ~= 1 then
		Dialog:Say(szError);
		return 0;
	end
	local nNearby = 0;
	local tbMemberId,nCount = KTeam.GetTeamMemberList(me.nTeamId);
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId, 40);
	for _,tbRound in pairs(tbPlayerList or {}) do
		for _, nMemberId in pairs(tbMemberId) do
			local pMember = KPlayer.GetPlayerObjById(nMemberId);
			if pMember and pMember.szName == tbRound.szName then
				nNearby = nNearby + 1;
			end
		end
	end
	if nNearby ~= nCount then
		Dialog:Say("Có đồng đội không ở đây");
		return 0;
	end
	--todo,检查队友身上次数，和队友身上道具是否符合条件
	local nIsPlayerHasNoItem ,tbNoItemPlayerName = 0 , {};
	local nIsPlayerNoGetLevel,tbNoGetLevelPlayerName = 0,{};
	local nIsPlayerNoFaction,tbNoFactionPlayerName = 0, {};
	local nIsPlayerNotGetTask,tbNoTaskPlayerName = 0,{};
	for _, nMemberId in pairs(tbMemberId) do
		local pMember = KPlayer.GetPlayerObjById(nMemberId);
		if pMember then
			if CrossTimeRoom:CheckHaveJoinItem(pMember) ~= 1 then
				nIsPlayerHasNoItem = 1;
				table.insert(tbNoItemPlayerName,pMember.szName);
			end
			if pMember.nLevel < 100 then
				nIsPlayerNoGetLevel = 1;
				table.insert(tbNoGetLevelPlayerName,pMember.szName);
			end
			if pMember.nFaction <= 0 then
				nIsPlayerNoFaction = 1;
				table.insert(tbNoFactionPlayerName,pMember.szName);
			end
			if not Task:GetPlayerTask(pMember).tbTasks[479] or Task:GetPlayerTask(pMember).tbTasks[479].nCurStep ~= 2 then
				nIsPlayerNotGetTask = 1;
				table.insert(tbNoTaskPlayerName,pMember.szName);
			end
		end
	end
	if nIsPlayerNoGetLevel == 1 then	--有等级未达到的
		local szMsg = "";
		for _,szName in pairs(tbNoGetLevelPlayerName) do
			szMsg = szMsg .. "<color=yellow>" .. szName .. "<color> chưa đạt cấp độ 100\n";
		end
		Dialog:Say(szMsg);
		return 0;
	end
	if nIsPlayerNoFaction == 1 then		--有未加入门派的
		local szMsg = "";
		for _,szName in pairs(tbNoFactionPlayerName) do
			szMsg = szMsg .. "<color=yellow>" .. szName .. "<color> chưa gia nhập môn phái\n";
		end
		Dialog:Say(szMsg);
		return 0;
	end
	if nIsPlayerHasNoItem == 1 then
		local szMsg = "";
		for _,szName in pairs(tbNoItemPlayerName) do
			szMsg = szMsg .. "<color=yellow>" .. szName .. "<color> trên người không có lệnh bài\n";
		end
		Dialog:Say(szMsg);
		return 0;
	end
	if nIsPlayerNotGetTask == 1 then
		local szMsg = "";
		for _,szName in pairs(tbNoTaskPlayerName) do
			szMsg = szMsg .. "<color=yellow>" .. szName .. "<color> chưa nhận nhiệm vụ hoặc chưa đến bước chỉ định\n";
		end
		Dialog:Say(szMsg);
		return 0;
	end
	local pGame = CrossTimeRoom:GetGameObjByTeamId(me.nTeamId);
	if not pGame then
		local nNum = CrossTimeRoom:GetGameNum(GetServerId());
		if nNum >= CrossTimeRoom.MAX_GAME then
			Dialog:Say("Thời Quang Điện đã đầy");
			return 0;
		end
		GCExcute{"CrossTimeRoom:ApplyGame_GC",me.nId,GetServerId(),me.nMapId};
		return 1;
	else
		Dialog:Say("Đội trưởng đã mở phó bản rồi!");
		return 0;
	end
end

function tbNpc:Transfer()
	CrossTimeRoom:JoinGame();
end


-----------------第一关的对话开启人----
local tbRoom2Npc = Npc:GetClass("crosstimeroom2_dialog");

function tbRoom2Npc:OnDialog()
	self:BeginGame(him.dwId);
end

function tbRoom2Npc:BeginGame(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local pGame = CrossTimeRoom:GetGameObjByMapId(him.nMapId);
	if not pGame then
		return 0;
	end
	if pGame.tbRoom and pGame.tbRoom[1] then
		pGame.tbRoom[1]:StartAddNpc();
		pNpc.Delete();
	else
		return 0;
	end	
end

-------------第三关的月影花--------
local tbEvent = 
{
	Player.ProcessBreakEvent.emEVENT_MOVE,
	Player.ProcessBreakEvent.emEVENT_ATTACK,
	Player.ProcessBreakEvent.emEVENT_SITE,
	Player.ProcessBreakEvent.emEVENT_USEITEM,
	Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
	Player.ProcessBreakEvent.emEVENT_DROPITEM,
	Player.ProcessBreakEvent.emEVENT_SENDMAIL,
	Player.ProcessBreakEvent.emEVENT_TRADE,
	Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
	Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
	Player.ProcessBreakEvent.emEVENT_LOGOUT,
	Player.ProcessBreakEvent.emEVENT_DEATH,
}

local tbRoom3Flower = Npc:GetClass("crosstimeroom_flowernpc");

function tbRoom3Flower:OnDialog()
	GeneralProcess:StartProcess("Đang chữa trị...", 2 * Env.GAME_FPS, {self.DoCure, self,him.dwId,me.nId}, nil, tbEvent);
end

function tbRoom3Flower:DoCure(nNpcId,nPlayerId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local pGame = CrossTimeRoom:GetGameObjByMapId(me.nMapId);
	if not pGame then
		return 0;
	end
	me.RemoveSkillState(CrossTimeRoom.nRedStateId);
	me.RemoveSkillState(CrossTimeRoom.nYellowStateId);
	me.RemoveSkillState(CrossTimeRoom.nGreenStateId);
	pNpc.Delete();
end

--------------------------
local tbRoom3Grass = Npc:GetClass("crosstimeroom_grassnpc");

function tbRoom3Grass:OnDialog()
	GeneralProcess:StartProcess("Đang hái...", 1 * Env.GAME_FPS, {self.DoPickUp, self,him.dwId,me.nId}, nil, tbEvent);
end

function tbRoom3Grass:DoPickUp(nNpcId,nPlayerId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end

	local pGame = CrossTimeRoom:GetGameObjByMapId(me.nMapId);
	if not pGame then
		return 0;
	end
	local tbRoom = pGame.tbRoom[pGame.nCurrentRoomId];
	if not tbRoom then
		return 0;
	end
	local pZixuan = KNpc.GetById(tbRoom.pBossZi and tbRoom.pBossZi.dwId or 0);
	if pZixuan then
		local _ , x, y = pZixuan.GetWorldPos();
		me.CastSkill(CrossTimeRoom.nDamageSkillId,1,x*32,y*32,1);
		local nMaxLife = pZixuan.nMaxLife;
		local nReduceLife = math.floor(nMaxLife * 0.2);
		pZixuan.ReduceLife(nReduceLife);
		if pZixuan.nCurLife <= 0 then
			me.KillNpc(pZixuan.dwId);
		end
	end
	pNpc.Delete();
end
