-- 文件名　：moonstone_xiang.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-07-14 10:42:51
-- 描述：月影之石箱

local tbItem = Item:GetClass("moonstone_xiang");

local tbMoonStoneGDPL = {18,1,476,1};	--月影之石的gdpl


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

function tbItem:OnUse()
	if me.CountFreeBagCell() < 1 then
		me.Msg("Hành trang không đủ chỗ trống!","");
		return 0;
	end
	GeneralProcess:StartProcess("打开中...", 10 * Env.GAME_FPS, {self.OnOpen, self,it.dwId}, nil, tbEvent);
end

function tbItem:OnOpen(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		me.Msg("道具异常","系统");
		return 0;
	end
	local nAddCount = tonumber(pItem.GetExtParam(1));
	if nAddCount <= 0 then
		me.Msg("道具异常","系统");
		return 0;
	end
	if me.DelItem(pItem,Player.emKLOSEITEM_USE) ~= 1 then
		me.Msg("道具异常","系统");
		return 0;
	end
	me.AddStackItem(tbMoonStoneGDPL[1],tbMoonStoneGDPL[2],tbMoonStoneGDPL[3],tbMoonStoneGDPL[4],nil,nAddCount);
end
