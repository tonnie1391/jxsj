
local tbItem = Item:GetClass("girl_vote_meigui");

function tbItem:OnUse()
	if SpecialEvent.Girl_Vote:CheckState(5, 6) == 1 then
		local tbNpc = Npc:GetClass("girl_dingding");
		local szMsg = "现在是美女评选决赛阶段，和自己喜欢的美女组队，并选择“<color=yellow>给我的美女队友投票<color>”选项投票给自己喜欢的美女，票数将会有20％的票数加成。\n请选择你想进行的操作。";
		local tbOpt = {
			{"<color=yellow>给我的美女队友投票<color>",self.VoteState2, self},
			{"给其他区服美女投票",tbNpc.State2VoteTickets, tbNpc},
			{"查询排行及票数信息",tbNpc.Query2, tbNpc},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	if SpecialEvent.Girl_Vote:CheckState(2, 4) ~= 1 then
		Dialog:Say("现在不是投票期。<enter><enter>3月5日至3月16日是预赛投票，3月19日至3月30日是决赛投票。");
		return 0;
	end
	self:VoteState1();
	return 0;
end

function tbItem:VoteState1()
	local nCheck, szGirlName = self:CheckIsVote();
	if nCheck == 1 then
		SpecialEvent.Girl_Vote:State1VoteTickets1(szGirlName, 1);
	end
end

function tbItem:VoteState2()
	local nCheck, szGirlName = self:CheckIsVote2();
	if nCheck == 1 then
		SpecialEvent.Girl_Vote:State2VoteTickets1(GetGatewayName(), szGirlName, 1);
	end
end

function tbItem:CheckIsVote()
	local tbAllPlayerId = KTeam.GetTeamMemberList(me.nTeamId);
	local tbPlayerId = me.GetTeamMemberList();
	if not tbPlayerId or not tbAllPlayerId or #tbAllPlayerId ~= 2 or #tbPlayerId ~= 2 then
		me.Msg("单独与美女组队，并且要在附近才能进行投票哦！");
		return 0;
	end
	local szGirlName = "";
	local nMapId, nPosX, nPosY = me.GetWorldPos();
	for _, pPlayer in pairs(tbPlayerId) do
		if pPlayer.nId ~= me.nId then
			szGirlName = pPlayer.szName;
			if pPlayer.nSex ~= 1 then
				me.Msg("玫瑰花只能送给女玩家！");
				return 0;
			end
			local nMapId2, nPosX2, nPosY2	= pPlayer.GetWorldPos();
			local nDisSquare = (nPosX - nPosX2)^2 + (nPosY - nPosY2)^2;
			if nMapId2 ~= nMapId or nDisSquare > 400 then
				me.Msg("单独与美女组队，并且要在附近才能进行投票哦！");
				return 0;
			end
			if SpecialEvent.Girl_Vote:IsHaveGirl(szGirlName) == 0 then
				Dialog:Say("该美女还未报名参赛，不能投票！叫她去临安丁丁处报名吧。");
				return 0;
			end
			break;
		end
	end
	return 1, szGirlName;
end

function tbItem:CheckIsVote2()
	local tbAllPlayerId = KTeam.GetTeamMemberList(me.nTeamId);
	local tbPlayerId = me.GetTeamMemberList();
	if not tbPlayerId or not tbAllPlayerId or #tbAllPlayerId ~= 2 or #tbPlayerId ~= 2 then
		me.Msg("单独与美女组队，并且要在附近才能进行投票哦！");
		return 0;
	end
	local szGirlName = "";
	local nMapId, nPosX, nPosY = me.GetWorldPos();
	for _, pPlayer in pairs(tbPlayerId) do
		if pPlayer.nId ~= me.nId then
			szGirlName = pPlayer.szName;
			if pPlayer.nSex ~= 1 then
				me.Msg("玫瑰花只能送给女玩家！");
				return 0;
			end
			local nMapId2, nPosX2, nPosY2	= pPlayer.GetWorldPos();
			local nDisSquare = (nPosX - nPosX2)^2 + (nPosY - nPosY2)^2;
			if nMapId2 ~= nMapId or nDisSquare > 400 then
				me.Msg("单独与美女组队，并且要在附近才能进行投票哦！");
				return 0;
			end
			if SpecialEvent.Girl_Vote:IsHaveGirl2(GetGatewayName(), szGirlName) == 0 then
				Dialog:Say("该美女不是预赛本区服前十名入围美女玩家。");
				return 0;
			end
			break;
		end
	end
	return 1, szGirlName;
end
