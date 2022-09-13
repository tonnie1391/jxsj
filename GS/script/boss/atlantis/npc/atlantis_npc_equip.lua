-------------------------------------------------------
-- 文件名　：atlantis_npc_equip.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-03-16 15:47:06
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\boss\\atlantis\\atlantis_def.lua");

local tbNpc = Npc:GetClass("atlantis_npc_equip");

function tbNpc:OnDialog()

	if Atlantis:CheckGetEquip(me) ~= 1 then
		return 0;
	end
	
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
	GeneralProcess:StartProcess("Đang thu nhặt...", 10 * Env.GAME_FPS, {self.OnGetEquip, self, him.dwId, me.nId}, {self.OnBreak, self, me.nId}, tbBreakEvent);

	me.AddSkillState(Newland.THRONE_BUFFER, 1, 1, 10 * Env.GAME_FPS, 1, 1);
end

function tbNpc:OnGetEquip(pNpcDwId, nPlayerId)
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pNpc = KNpc.GetById(pNpcDwId);
	if not pNpc or not pPlayer then
		return 0;
	end

	if Atlantis:CheckGetEquip(pPlayer) ~= 1 then
		return 0;
	end
	
	local tbItem = Atlantis:GetEquipId(pPlayer);
	if tbItem then
		local pItem = pPlayer.AddItem(tbItem[1], tbItem[2], tbItem[3], tbItem[4], nil, 16);
		if pItem then
			pItem.Bind(1);
			pItem.SetTimeOut(0, GetTime() + 7200);
			pNpc.Delete();
			Atlantis.tbPlayerList[pPlayer.szName].nSuperEquip = 1;
			Atlantis.tbTeamList[pPlayer.nTeamId].nSuperTeam = 1;
			Atlantis:SendMessage(Atlantis.MSG_BOTTOM, "<color=yellow>Ngươi đã nhận được Thần khí Phong ấn Lâu Lan Cổ Thành!<color>");
			Atlantis:BroadCast(Atlantis.MSG_CHANNEL, "<color=yellow>Một nhân vật thần bí đã nhận được Thần khí<color>");
			KTeam.Msg2Team(pPlayer.nTeamId, string.format("[%s] nhặt được Thần khí!", pPlayer.szName));
			pPlayer.AddItem(unpack(Atlantis.ITEM_HAMMER_ID));
		end
	end
end

function tbNpc:OnBreak(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.RemoveSkillState(Newland.THRONE_BUFFER);
	end
end
