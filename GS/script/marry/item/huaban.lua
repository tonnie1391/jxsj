-------------------------------------------------------
-- 文件名　：huaban.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-01-20 20:23:20
-- 文件描述：
-------------------------------------------------------

local tbNpc = Npc:GetClass("marry_xoyo_qinghua");

function tbNpc:OnDialog()
	
	if Marry:CheckState() ~= 1 then
		return 0;
	end
	
	if me.CountFreeBagCell() <= 0 then
		me.Msg("背包已满，请清理背包空间。")
		return 0;
	end
	
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
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
	}
	GeneralProcess:StartProcess("采集中...", 3 * Env.GAME_FPS, {self.DoPickUp, self, me.nId, him.dwId}, nil, tbEvent);
end

function tbNpc:DoPickUp(nPlayerId, nNpcId)
	
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0
	end
		
	local pItem = pPlayer.AddItem(unpack(Marry.ITEM_HUABAN_ID));
	if pItem then
		pItem.Bind(1);
	end
	
	pNpc.Delete();
end
