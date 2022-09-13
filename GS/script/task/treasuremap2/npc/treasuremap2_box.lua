-- 文件名  : treasuremap2_box.lua
-- 创建者  : zounan
-- 创建时间: 2010-08-19 21:23:36
-- 描述    : 


-- 副本入口Npc
local tbInstancingTreasureBox = Npc:GetClass("treasuremap2_box");

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
	GeneralProcess:StartProcess("Đang mở rương...", 10 * 18, {self.OpenTreasureBox, self, me.nId, him.dwId}, {me.Msg, "Mở gián đoạn"}, tbEvent);
end

function tbInstancingTreasureBox:OpenTreasureBox(nPlayerId, dwNpcId)
	-- 爆物品
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end
	local pNpc = KNpc.GetById(dwNpcId);
	if not pNpc  then
		return;
	end

	local nMapId, nMapX, nMapY	= pNpc.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nMapId);	

	if not tbInstancing then
		return;
	end

	--pNpc.CastSkill(TreasureMap2.YanHuaId, 1,  nMapX * 32, nMapY * 32);   	
	pNpc.Delete();	
	pPlayer.Msg("<color=yellow>Đã mở rương!<color>");
	pPlayer.CastSkill(TreasureMap2.YanHuaId, 1,  nMapX * 32, nMapY * 32);   	
	local nNpcScore  =  pNpc.GetTempTable("TreasureMap2").nNpcScore or 0;
	if nNpcScore == 0 then
		return;
	end
	
	TreasureMap2:AddInstanceScore(tbInstancing, nNpcScore);
	tbInstancing:SendMsgByTeam(string.format("Tổ đội mở rương kho báu nhận được <color=yellow>%d<color> điểm tích lũy.",nNpcScore));
end
