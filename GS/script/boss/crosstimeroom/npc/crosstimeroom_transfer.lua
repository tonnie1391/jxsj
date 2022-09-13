-- 文件名　：crosstimeroom_transfer.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-08-09 14:38:05
-- 描述：传送

local tbNpc = Npc:GetClass("crosstimeroom_transfer")

function tbNpc:OnDialog()
	local szMsg = "你想要穿越到哪一段过去？"
	local pGame = CrossTimeRoom:GetGameObjByMapId(him.nMapId);
	if not pGame then
		return 0;
	end
	local tbOpt = {};
	for i = 1 , pGame.nTransferRoomMaxId do
		tbOpt[i] = {CrossTimeRoom.tbTransferName[i],self.Transfer,self,i,him.nMapId,him.dwId,me.nId};
	end
	tbOpt[#tbOpt + 1] = {"我要回准备场",self.Transfer,self,0,him.nMapId,him.dwId,me.nId};
	tbOpt[#tbOpt + 1] = {"我要离开这里",self.LeaveGame,self,him.nMapId,him.dwId,me.nId};
	tbOpt[#tbOpt + 1] = {"我再想一想"};
	Dialog:Say(szMsg,tbOpt);
end

function tbNpc:Transfer(nRoom,nMapId,nNpcId,nPlayerId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbNpc = KNpc.GetAroundNpcList(me,20);	--如果npc不在附近，不进行操作，防止卡对话框
	local nIsNear = 0;
	for _,pNpc in pairs(tbNpc) do
		if pNpc.dwId == nNpcId then
			nIsNear = 1;
			break;
		end
	end
	if nIsNear ~= 1 then
		return 0;
	end
	local pGame = CrossTimeRoom:GetGameObjByMapId(nMapId);
	if not pGame then
		return 0;
	end
	if nRoom == 0 then
		local tbPos = CrossTimeRoom.ENTER_POS[MathRandom(#CrossTimeRoom.ENTER_POS)];
		me.NewWorld(nMapId,tbPos[1],tbPos[2]);
		if me.nFightState == 1 then
			me.SetFightState(0);
		end
		return 0;
	end
	--如果有个房间已经完成了，那就可以随意传送没有限制，只限单人
	if pGame.tbRoom and pGame.tbRoom[nRoom] and pGame.tbRoom[nRoom]:IsRoomFinished() == 1 then
		local tbPos = CrossTimeRoom.tbRoomPos[nRoom];
		me.NewWorld(nMapId,tbPos[1],tbPos[2]);
		if me.nFightState == 1 then
			me.SetFightState(0);
		end
		return 0;
	end
	if me.nTeamId <= 0 then
		Dialog:Say("你没有队伍!");
		return 0;
	end
	if me.IsCaptain() ~= 1 then
		Dialog:Say("你不是队长!");
		return 0;
	end
	local tbPlayer = pGame:GetPlayerList();
	local nCanTransfer = 1;
	local tbTeam = {};
	for _,pMember in pairs(tbPlayer) do
		if pMember then
			if pMember.nTeamId <= 0 then
				nCanTransfer = 0;
			else
				tbTeam[pMember.nTeamId] = 1;
			end		
		end
	end
	if nCanTransfer ~= 1 then
		Dialog:Say("副本内有玩家没在队伍中，无法进行传送!");
		return 0;
	end
	local nTeamNum = 0;
	for nTeamId,_ in pairs(tbTeam) do
		if nTeamId > 0 then
			nTeamNum = nTeamNum + 1;
		end
	end
	if nTeamNum > 1 then
		Dialog:Say("当前副本内只能存在一个队伍!");
		return 0;
	end
	--判断是不是队伍都在附近,判断整个副本是不是有人没有队伍，是不是队伍数量大于2
	local nNearby = 0;
	local nTeamNear = 0;
	local tbPlayerList = KPlayer.GetAroundPlayerList(me.nId,30);
	local tbPlayer,nCount = pGame:GetPlayerList();
	local _,nTeamMemCount = KTeam.GetTeamMemberList(me.nTeamId);
	for _,tbRound in pairs(tbPlayerList or {}) do
		for _, pMember in pairs(tbPlayer) do
			if pMember and pMember.szName == tbRound.szName then
				nNearby = nNearby + 1;
			end
		end
	end
	if nNearby ~= nCount or nTeamMemCount ~= nCount then
		Dialog:Say("对不起，要保证队友都在一起才能进行传送！");
		return 0;
	end
	if pGame.tbRoom[nRoom]:IsRoomStart() == 1 and pGame.tbRoom[nRoom]:IsRoomFailed() == 0 and 
		pGame.tbRoom[nRoom]:IsRoomFinished() ~= 1 then
		Dialog:Say("你的队伍已经开始挑战了，请稍后!");
		return 0;
	end
	if pGame.tbRoom[nRoom]:IsRoomStart() == 0 or pGame.tbRoom[nRoom]:IsRoomFailed() == 1 then
		pGame:StartRoom(nRoom);
		pGame.tbRoom[nRoom].tbPlayerList = {};
	end
	local tbMember,nCount = pGame:GetPlayerList();
	local tbPlayer = {};
	local tbPos = CrossTimeRoom.tbRoomPos[nRoom];
	for _,pMember in pairs(tbMember) do
		if pMember then
			if pGame.tbRoom[nRoom]:IsRoomFinished() ~= 1 then
				pGame.tbRoom[nRoom].tbPlayerList[pMember.nId] = 1;
				if pMember.nFightState == 0 then
					pMember.SetFightState(1);
				end
			end
			pMember.NewWorld(nMapId,tbPos[1],tbPos[2]);
		end
	end
end

function tbNpc:LeaveGame(nMapId,nNpcId,nPlayerId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local szMsg = "你确定要离开副本么？";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"确定离开",self.SureLeave,self,nMapId,nNpcId,nPlayerId};
	tbOpt[#tbOpt + 1] = {"我再考虑下"};
	Dialog:Say(szMsg,tbOpt);
end


function tbNpc:SureLeave(nMapId,nNpcId,nPlayerId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	local tbNpc = KNpc.GetAroundNpcList(me,20);
	local nIsNear = 0;
	for _,pNpc in pairs(tbNpc) do
		if pNpc.dwId == nNpcId then
			nIsNear = 1;
			break;
		end
	end
	if nIsNear ~= 1 then
		return 0;
	end
	local pGame = CrossTimeRoom:GetGameObjByMapId(nMapId);
	if not pGame then
		return 0;
	end
	pGame:KickPlayer(me);
end
