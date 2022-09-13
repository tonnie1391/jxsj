
Player.ITEM_CHIP_ID = {
	[1] = {tbItemId = {1,  11, 9,  10}, szName = "Ngọc Bội Du Long Giác"},
	[2] = {tbItemId = {1,  11, 10, 10}, szName = "Hương Nang Du Long Giác"},
	[3] = {tbItemId = {18, 5,  1,  2}, 	szName = "Du Long Giác"},
}

function Player:CreateDuLongGiac()
	local nWeek = tonumber(os.date("%w", GetTime()));
	if nWeek == 0 then
		KNpc.Add2(20310, 1, -1, 8, 1721, 3380);
		KNpc.Add2(20310, 1, -1, 8, 1732, 3385);
		KNpc.Add2(20310, 1, -1, 8, 1725, 3391);
		KNpc.Add2(20310, 1, -1, 8, 1720, 3388);
		KNpc.Add2(20310, 1, -1, 8, 1728, 3378);
	end
end

function Player:ClearDuLongGiac()
	local nWeek = tonumber(os.date("%w", GetTime()));
	if nWeek == 6 then
		local tbMap = GetLocalServerMapInfo();		-- 本地服务器地图分配状况
		local nServerIdx = GetServerId();
		for nMapId, nServerId in pairs(tbMap) do
			if nServerIdx == nServerId then
				ClearMapNpcWithTemplateId(nMapId, 20310);
			end
		end
	end
end

function Player:CheckDuLongGiac(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local tbAllRoom = {
			Item.ROOM_EQUIP,
			Item.ROOM_EQUIPEX,
			Item.ROOM_MAINBAG,
			Item.ROOM_EXTBAG1,
			Item.ROOM_EXTBAG2,
			Item.ROOM_EXTBAG3,
			Item.ROOM_REPOSITORY,
			Item.ROOM_EXTBAGBAR,
			Item.ROOM_MAIL,
			Item.ROOM_TRADE,
			Item.ROOM_TRADECLIENT,
			Item.ROOM_RECYCLE,
		}
	
	for _, nRoom in pairs(tbAllRoom) do
		local tbIdx = pPlayer.FindAllItem(nRoom);
		if (tbIdx) then
			for i = 1, #tbIdx do
				local pItem = KItem.GetItemObj(tbIdx[i]);
				for _, tbName in pairs (Player.ITEM_CHIP_ID) do
					if (pItem) and pItem.szOrgName == tbName.szName then
						-- pItem.Delete(me);
						return 1
					end
				end
			end
		end
	end
	return 0
end

function Player:DelDuLongGiac(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local tbAllRoom = {
			Item.ROOM_EQUIP,
			Item.ROOM_EQUIPEX,
			Item.ROOM_MAINBAG,
			Item.ROOM_EXTBAG1,
			Item.ROOM_EXTBAG2,
			Item.ROOM_EXTBAG3,
			Item.ROOM_REPOSITORY,
			Item.ROOM_EXTBAGBAR,
			Item.ROOM_MAIL,
			Item.ROOM_TRADE,
			Item.ROOM_TRADECLIENT,
			Item.ROOM_RECYCLE,
		}
	
	for _, nRoom in pairs(tbAllRoom) do
		local tbIdx = pPlayer.FindAllItem(nRoom);
		if (tbIdx) then
			for i = 1, #tbIdx do
				local pItem = KItem.GetItemObj(tbIdx[i]);
				for _, tbName in pairs (Player.ITEM_CHIP_ID) do
					if (pItem) and pItem.szOrgName == tbName.szName then
						pItem.Delete(pPlayer);
						Dbg:WriteLog(string.format("[Du Long Giác] %s xóa %s", pPlayer.szName, tbName.szName));
					end
				end
			end
		end
	end
end

function Player:GetAllPlayer()
	local tbPlayerList = KPlayer:GetAllPlayer();
	local tbPlayerListSend = {};
	for _, pPlayer in pairs(tbPlayerList) do
		local nMap, nX, nY = pPlayer.GetWorldPos();
		if Player:CheckDuLongGiac(pPlayer.nId) == 1 then
			table.insert(tbPlayerListSend, {pPlayer.szName, nMap, nX, nY})
		end
	end
	GCExcute({"Player:Result", tbPlayerListSend})
end

function Player:OnTake(nPlayerId, pNpcDwId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pNpc = KNpc.GetById(pNpcDwId or 0);
	if not pPlayer then
		return 0;
	end
	
	if Player:CheckDuLongGiac(nPlayerId) == 1 then
		pPlayer.Msg("Ngươi đã có <color=yellow>Du Long Giác<color>. Đừng tham lam quá!")
		return
	end
	
	local pItem = pPlayer.AddItem(18, 5, 1, 2, nil, 16);
	local nWeek = 6 - tonumber(os.date("%w", GetTime()));
	local nTime = GetTime() + nWeek * 24 * 3600;
	if pItem then
		pItem.Bind(1);
		me.SetItemTimeout(pItem, os.date("%Y/%m/%d/23/59/59", nTime));
		pItem.Sync();
		if pNpc then
			pNpc.Delete();
		end
		
		local szMsg = "<color=green>"..pPlayer.szName.."<color> <color=yellow>đang nắm giữ Du Long Giác<color>";
		KDialog.NewsMsg(1, Env.NEWSMSG_COUNT, szMsg);
		KDialog.MsgToGlobal(szMsg);
		KTeam.Msg2Team(pPlayer.nTeamId, string.format("[%s] đang nắm giữ Du Long Giác!", pPlayer.szName));
		Dbg:WriteLog(string.format("[Du Long Giác] %s nhận Du Long Giác", pPlayer.szName));
	end
end

function Player:PlayerLostChip(nLoserId, nReceiverId)
	local pLoser = KPlayer.GetPlayerObjById(nLoserId);
	local pReceiver = KPlayer.GetPlayerObjById(nReceiverId or 0);
	
	if Player:CheckDuLongGiac(nLoserId) ~= 1 then
		return
	end
	
	local nMapId, nMapX, nMapY = pLoser.GetWorldPos();
	local szMsg 	= string.format("<color=green>%s<color> đánh rơi <color=green>Du Long Giác<color> tại <pos=%d,%d,%d>", pLoser.szName, nMapId, nMapX, nMapY );
	local szMsg2 	= string.format("<color=green>%s<color> <color=yellow>đánh rơi<color> <color=green>Du Long Giác<color> tại <color=blue>%s(%s/%s)<color>", pLoser.szName, GetMapNameFormId(nMapId), math.floor(nMapX/8), math.floor(nMapY/16))
	
	if not pReceiver then
		KNpc.Add2(20310, 1, -1, nMapId, nMapX, nMapY);
		KDialog.NewsMsg(1, Env.NEWSMSG_COUNT, szMsg2);
		KDialog.MsgToGlobal(szMsg);
	else
		if pReceiver.CountFreeBagCell() >= 1 then
			Player:OnTake(pReceiver.nId)
		else
			KNpc.Add2(20310, 1, -1, nMapId, nMapX, nMapY);
			KDialog.NewsMsg(1, Env.NEWSMSG_COUNT, szMsg2);
			KDialog.MsgToGlobal(szMsg);
		end
	end
	Player:DelDuLongGiac(nLoserId);
end

function Player:PlayerStealChip(szLoserName, szReceiverName)
	local tbBreakEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SIT,
		Player.ProcessBreakEvent.emEVENT_RIDE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_CHANGEEQUIP,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,		
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_REVIVE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
	}
	GeneralProcess:StartProcess("Du Long Giác là của ta...", 1 * Env.GAME_FPS, {Player.OnSteal, self, szLoserName, szReceiverName}, {self.OnBreak, self, me.nId}, tbBreakEvent);
	me.AddSkillState(Newland.THRONE_BUFFER, 1, 1, 5 * Env.GAME_FPS, 1, 1);
end
Player.c2sFun["PlayerStealChip"] = Player.PlayerStealChip;

function Player:OnSteal(szLoserName, szReceiverName)
	local pLoser = KPlayer.GetPlayerByName(szLoserName);
	local pReceiver = KPlayer.GetPlayerByName(szReceiverName);
	
	if pReceiver.CountFreeBagCell() < 1 then
		pReceiver.Msg("Hành trang không đủ 1 ô trống!")
		return 0
	end
	
	if Player:CheckDuLongGiac(pLoser.nId) == 0 then
		pReceiver.Msg("Ngươi có chắc người này đang giữ <color=yellow>Du Long Giác<color> không?")
		return
	end
	
	if Player:CheckDuLongGiac(pReceiver.nId) == 1 then
		pReceiver.Msg("Ngươi đã có <color=yellow>Du Long Giác<color>. Đừng tham lam quá!")
		return
	end
	
	local nRandom = MathRandom(0, math.floor(pLoser.GetBagCellCount()/10))
	if nRandom == 1 then
		Player:DelDuLongGiac(pLoser.nId);
		local pItem = pReceiver.AddItem(18, 5, 1, 2);
		if pItem then
			pItem.Bind(1);
			pItem.Sync();
			
			local szMsg = "<color=green>"..szReceiverName.."<color> đánh cắp <color=yellow>Du Long Giác<color> từ tay <color=green>"..szLoserName.."<color>";
			KDialog.NewsMsg(1, Env.NEWSMSG_COUNT, szMsg);
			KDialog.MsgToGlobal(szMsg);
			KTeam.Msg2Team(pReceiver.nTeamId, string.format("[%s] đang nắm giữ Du Long Giác!", szReceiverName));
			Dbg:WriteLog(string.format("[Du Long Giác] %s trộm Du Long Giác từ %s", szReceiverName, szLoserName));
		end
	else
		pReceiver.Msg("Tay thúi quá, không tìm thấy <color=yellow>Du Long Giác<color> rồi!")
	end
end

function Player:CheckHavePendant(nLoserId)
	local pLoser = KPlayer.GetPlayerObjById(nLoserId);
	local pItemPendant = pLoser.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_PENDANT, 0);
	if pItemPendant then
		return 1
	end
	return 0
end

-------------------------------------------------------------
local tbItem = Item:GetClass("dulonggiac");

function tbItem:OnUse()
	if Player:CheckHavePendant(me.nId) == 0 then
		me.Msg("Chưa trang bị Ngọc bội hoặc Hương nang!")
		return 0
	end
	
	if me.CountFreeBagCell() < 1 then
		me.Msg("Hành trang không đủ 1 ô trống!")
		return 0
	end
	
	local pItemPendant = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_PENDANT, 0);	
	local nSex = me.nSex;
	local pItem = me.AddItem(1, 11, 9 + nSex, 10);
	local nWeek = 6 - tonumber(os.date("%w", GetTime()));
	local nTime = GetTime() + nWeek * 24 * 3600;
	if pItem then
		pItem.Regenerate(
		pItem.nGenre,
		pItem.nDetail,
		pItem.nParticular,
		pItem.nLevel,
		pItemPendant.nSeries,
		pItemPendant.nEnhTimes,
		pItemPendant.nLucky,
		pItemPendant.GetGenInfo(),
		0,
		pItemPendant.dwRandSeed,
		pItemPendant.nStrengthen);
	
		pItem.Bind(1);
		me.SetItemTimeout(pItem, os.date("%Y/%m/%d/23/59/59", nTime));
		pItem.Sync();
		me.AutoEquip(pItem);
	end
	return 1
end

-------------------------------------------------------------
local tbNpc = Npc:GetClass("dulonggiac");

function tbNpc:OnDialog()	
	local tbBreakEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SIT,
		Player.ProcessBreakEvent.emEVENT_RIDE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_CHANGEEQUIP,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,		
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_REVIVE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
	}
	GeneralProcess:StartProcess("Du Long Giác là của ta...", 1.5 * Env.GAME_FPS, {Player.OnTake, self, me.nId, him.dwId}, {self.OnBreak, self, me.nId}, tbBreakEvent);
	me.AddSkillState(Newland.THRONE_BUFFER, 1, 1, 1.5 * Env.GAME_FPS, 1, 1);
	Dbg:WriteLog(string.format("[Du Long Giác] %s nhặt Du Long Giác từ NPC", me.szName));
end

function tbNpc:OnBreak(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.RemoveSkillState(Newland.THRONE_BUFFER);
	end
end
