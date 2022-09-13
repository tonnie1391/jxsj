-- 文件名　：kingame_guwu.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-06-28 21:04:34
-- 描述：谷物


local tbNpc = Npc:GetClass("kingame_guwu");

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


function tbNpc:OnDialog()
	GeneralProcess:StartProcess("拾取中...", 2 * Env.GAME_FPS, {self.PickUp, self,him.dwId}, nil, tbEvent);
end

function tbNpc:PickUp(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		local szMsg = "Hành trang không đủ chỗ trống.";
		me.Msg(szMsg);
		return 0;
	end
	local pItem = me.AddItem(18,1,1335,1);	--加谷物
	if pItem then
		me.SetItemTimeout(pItem,10,0);
		pItem.Sync();
		pNpc.Delete();
	end
end