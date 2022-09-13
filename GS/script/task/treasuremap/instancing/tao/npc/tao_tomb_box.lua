
-- ====================== 文件信息 ======================

-- 陶朱公疑冢宝箱脚本
-- Edited by peres
-- 2008/03/09 PM 16:14

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================


local tbInstancingTreasureBox = Npc:GetClass("tao_tomb_box");

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

function tbInstancingTreasureBox:OpenTreasureBox(nPlayerId, nNpcId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	local pNpc = KNpc.GetById(nNpcId);
	-- 爆物品
	if (pNpc and pNpc.nIndex > 0) then
		pPlayer.DropRateItem(TreasureMap.tbDrop_Level_2["Box_Inside"], TreasureMap.nTreasureBoxDropCount, -1, -1, pNpc)
		pPlayer.Msg("<color=yellow>开启完成！<color>")
		pNpc.Delete();
	end
end
