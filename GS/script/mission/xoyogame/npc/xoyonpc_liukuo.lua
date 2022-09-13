local tbNpc = Npc:GetClass("heixinshangren_lv1");

function tbNpc:OnDialog()
	local nDifficulty = XoyoGame:GetDifficuty(me.nTeamId);
	local nFlag = me.GetTask(XoyoGame.TASK_GROUP, XoyoGame.EXCHANGE_ROOM_LEVEL);
	if XoyoGame.XINGSHENSHI_OPEN == 1 and GetMapType(me.nMapId) == "xoyogame" and nDifficulty >= XoyoGame.HUANSHENDAN_MIN_DIFFICULTY and nFlag >= 0 then
		local szMsg = "Hãy đưa ta \"Tiêu Dao Tỉnh Thần Thạch\" được gia công bằng Kỹ năng sống. Ta sẽ giúp ngươi quay lại chiến đấu cùng đồng đội.";
		local tbOpt = 
		{
			{"Trở lại chiến đấu", self.GoFighting, self},
			{"Mở tiệm thuốc", self.OpenMedicineShop, self},
			{"Kết thúc đối thoại"}
		};
		Dialog:Say(szMsg, tbOpt);
	else
		self:OpenMedicineShop();
	end
	
end

function tbNpc:GoFighting(nCheck)
	local nPlayerId = me.nId;
	local tbGame = XoyoGame:GetPlayerGame(nPlayerId);
	if not tbGame then
		Dialog:Say("Có gì đó sai sai rồi!");
		return 0;
	end
	local tbRoom = tbGame:GetPlayerRoom(nPlayerId);
	if not tbRoom then
		Dialog:Say("Đồng đội không còn ở trận chiến, không thể di chuyển!");
		return 0;
	end
	
	local nHasExchangeTimes = me.GetTask(XoyoGame.TASK_GROUP, XoyoGame.EXCHANGE_TIMES);
	local nRoomLevel = me.GetTask(XoyoGame.TASK_GROUP, XoyoGame.EXCHANGE_ROOM_LEVEL);
	local nLevel = tbRoom.tbSetting.nRoomLevel;
	if nRoomLevel > 0 then
		Dialog:Say(string.format("Bạn đã sử dụng Tiêu Dao Tỉnh Thần Thạch ở ải này rồi"));
		return 0;
	end
	if nHasExchangeTimes >= XoyoGame.HUANSHENDAN_GAME_USETIMES then
		Dialog:Say(string.format("Bạn đã sử dụng %s lần Tiêu Dao Tỉnh Thần Thạch, không thể sử dụng thêm", nHasExchangeTimes));
		return 0;
	end
	local tbFind = me.FindItemInBags(unpack(XoyoGame.ITEM_HUANSHENDAN));
	if not tbFind[1] then
		Dialog:Say("Không tìm thấy vật phẩm phù hợp.");
		return 0;
	end
	local tbMember, nNum = KTeam.GetTeamMemberList(me.nTeamId);
	local tbTeammateList = {};
	for j = 1, nNum do
		local pPlayer = KPlayer.GetPlayerObjById(tbMember[j]);
		if pPlayer and GetMapType(pPlayer.nMapId) == "xoyogame" and pPlayer.nFightState == 1 and tbGame == XoyoGame:GetPlayerGame(pPlayer.nId) and tbRoom == tbGame:GetPlayerRoom(pPlayer.nId) then
			table.insert(tbTeammateList, pPlayer);
		end
	end
	if #tbTeammateList == 0 then
		Dialog:Say("Không có tổ đội.");
		return 0;
	end
	if nCheck and nCheck == 1 then
		local nRand = MathRandom(#tbTeammateList);
		if tbRoom:ReviveBackRoom(nPlayerId) ~= 1 then
			return 0;
		end
		me.ConsumeItemInBags(1, unpack(XoyoGame.ITEM_HUANSHENDAN));
		local nMapId, nPosX, nPosY = tbTeammateList[nRand].GetWorldPos();
		me.NewWorld(nMapId, nPosX, nPosY);
		me.SetFightState(1);
		Player:AddProtectedState(me, XoyoGame.SUPER_TIME);
		me.SetTask(XoyoGame.TASK_GROUP, XoyoGame.EXCHANGE_ROOM_LEVEL, nLevel);
		me.SetTask(XoyoGame.TASK_GROUP, XoyoGame.EXCHANGE_TIMES, me.GetTask(XoyoGame.TASK_GROUP, XoyoGame.EXCHANGE_TIMES) + 1);
	else
		local tbOpt = 
		{
			{"Đồng ý", self.GoFighting, self, 1},
			{"Khoang đã"},	
		};
		Dialog:Say(string.format("Đi lần này sẽ còn <color=yellow>%s lần<color> sử dụng, ngươi chắc chứ?", XoyoGame.HUANSHENDAN_GAME_USETIMES - nHasExchangeTimes), tbOpt);
	end
end

function tbNpc:OpenMedicineShop()
	Dialog:Say(self.tbMap[0].szMsg, self.tbMap[0].tbOpt);
end