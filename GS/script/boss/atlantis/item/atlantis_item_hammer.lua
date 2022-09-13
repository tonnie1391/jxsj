-------------------------------------------------------
-- 文件名　：atlantis_item_hammer.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-03-22 21:54:50
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\boss\\atlantis\\atlantis_def.lua");

local tbItem = Item:GetClass("atlantis_hammer");

function tbItem:OnUse()
	
	if me.nMapId ~= Atlantis.MAP_ID then
		return 1;
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
	GeneralProcess:StartProcess("Đang sử dụng...", 10 * Env.GAME_FPS, {self.OnProcess, self, me.nId, it.dwId}, nil, tbBreakEvent);
	
	return 0;
end

function tbItem:OnProcess(nPlayerId, nItemDwId)
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	local pItem = KItem.GetObjById(nItemDwId);
	if not pPlayer or not pItem then
		return 0;
	end
	
	local nRet = Atlantis:PlayerLostEquip(pPlayer, "drop");
	if nRet ~= 1 then
		Dialog:Say("对不起，你身上没有携带神兵。");
		return 0;
	end
	
	pItem.Delete(pPlayer);
end

