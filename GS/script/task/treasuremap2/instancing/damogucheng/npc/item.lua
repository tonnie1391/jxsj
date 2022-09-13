
-- ====================== 文件信息 ======================

-- 大漠古城物品入脚本
-- Edited by peres
-- 2008/05/15 PM 16:23

-- 她的眼泪轻轻地掉落下来
-- 抚摸着自己的肩头，寂寥的眼神
-- 是，褪掉繁华和名利带给的空洞安慰，她只是一个一无所有的女子
-- 不爱任何人，亦不相信有人会爱她

-- ======================================================

local tbItem		= Item:GetClass("old_zither2");

tbItem.tbCallNpc		= {
		{1908, 3304},
		{1918, 3309},
		{1923, 3321},
		{1919, 3333},
		{1908, 3338},
		{1898, 3333},
		{1893, 3321},
		{1897, 3310},
	};


function tbItem:OnUse()
	local nSubWorld, nX, nY	= me.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nSubWorld);
	if (not tbInstancing) then
		Dialog:SendInfoBoardMsg(me, "<color=red>Hiện tại không thể sử dụng!<color>");
		return;
	end;
	
	if tbInstancing.nBoss_3_call ~= 0  then
		Dialog:SendInfoBoardMsg(me, "<color=red>Hiện tại không thể sử dụng!<color>");
		return;	
	end;
	
	local _, nDistance = TreasureMap2:GetDirection({nX, nY}, {1908, 3319})	
	
	if nDistance > 10 then
		Dialog:SendInfoBoardMsg(me, "<color=red>Không thể sử dụng ở đây!<color>");
		return;
	end;

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
	
	GeneralProcess:StartProcess("Đang sử dụng...", Env.GAME_FPS * 10, {self.ItemUsed, self, it.dwId, me.nId}, nil, tbEvent);

end;


function tbItem:ItemUsed(nItemId, nPlayerId)
	local pItem = KItem.GetObjById(nItemId);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pItem or not pPlayer then
		return 0;
	end	
	
	
	local nSubWorld, nX, nY	= pPlayer.GetWorldPos();
	local tbInstancing = TreasureMap2:GetInstancing(nSubWorld);
	--assert(tbInstancing);
	if not tbInstancing then  --改成 return zounan
		return;
	end
	
	-- 在这里删除物品
	--pPlayer.ConsumeItemInBags(1, 18, 1, 96, 1);
	pItem.Delete(pPlayer);
	--local pBoss		= KNpc.Add2(2719, 75, -1, nSubWorld, 1908, 3319);
	
	local nNpcLevel =  	TreasureMap2.TEMPLATE_LIST[tbInstancing.nTreasureId].tbNpcLevel[tbInstancing.nTreasureLevel] ;
	
	local pBoss		= KNpc.Add2(6943, nNpcLevel, -1, nSubWorld, 1908, 3319);
	if pBoss then
		pBoss.GetTempTable("TreasureMap2").nNpcScore = 57 * TreasureMap2.LEVEL_RATE[tbInstancing.nTreasureLevel];
		pBoss.szName	= "Vô Danh Thị";
	end
	
	for i=1, #self.tbCallNpc do
		--local pNpc	= KNpc.Add2(2716, nNpcLevel, -1, nSubWorld, self.tbCallNpc[i][1], self.tbCallNpc[i][2]);
		local pNpc	= KNpc.Add2(6940, nNpcLevel, -1, nSubWorld, self.tbCallNpc[i][1], self.tbCallNpc[i][2]);
		if pNpc then
		--	pBoss.GetTempTable("TreasureMap2").nNpcScore = 60 * TreasureMap2.LEVEL_RATE[tbInstancing.nTreasureLevel];
			pNpc.szName	= "Quỷ Sứ";
		end
	end;
	
	-- 加石块挡住路口
	tbInstancing.tbStele_1_Idx	= {};
	
	local tbStele_1	= {{1889, 3346}, {1891, 3348}, {1894, 3349}};
	for i=1, #tbStele_1 do
		local pNpc		= KNpc.Add2(2707, 1, -1, nSubWorld, tbStele_1[i][1], tbStele_1[i][2]);
		pNpc.szName		= " ";
		
		-- 将石块的 IDX 保存起来，击杀 BOSS 后删除
		table.insert(tbInstancing.tbStele_1_Idx, pNpc.dwId);
	end;
	
	tbInstancing.nBoss_3_call  = 1;
end;
