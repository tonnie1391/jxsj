
-- 副本入口Npc
local tbInstancingTreasureBox = Npc:GetClass("treasurebox_Instancing");

function tbInstancingTreasureBox:OnDialog()
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
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
	}
	
	-- TODO:liucahng 10写到head中去
	GeneralProcess:StartProcess("Đang mở rương", 10 * 18, {self.OpenTreasureBox, self, me.nId, him.dwId}, {me.Msg, "Mở thất bại!"}, tbEvent);
end

function tbInstancingTreasureBox:OpenTreasureBox(nPlayerId, dwNpcId)
	-- 爆物品
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	local pNpc = KNpc.GetById(dwNpcId);
	if (pNpc and pNpc.nIndex > 0) then
		pPlayer.DropRateItem(TreasureMap.szBaoXiangShiNeiDropFilePath, TreasureMap.nTreasureBoxDropCount, -1, -1, pNpc)
		pPlayer.Msg("<color=yellow>开启完成！<color>")
		pNpc.Delete();
	end
end
