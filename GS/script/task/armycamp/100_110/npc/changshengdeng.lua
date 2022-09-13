-----------------------------------------------------------
-- 文件名　：changshengdeng.lua
-- 文件描述：长生灯
-- 创建者　：ZhangDeheng
-- 创建时间：2008-11-27 10:54:05
-----------------------------------------------------------

-- 长生灯
local tbChangShengDeng = Npc:GetClass("changshengdeng");

tbChangShengDeng.GUWANG_ID = 4152;

tbChangShengDeng.tbGuWangText = {"教宗的产业不会毁在我的手中。"};

function tbChangShengDeng:OnDialog()
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	if (tbInstancing.nOpenChangShengDeng == 5) then
		return;
	end;
	
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
	}
	GeneralProcess:StartProcess("Đang mở...", 1 * 18, {self.OnOpen, self, him.dwId, me.nId, tbInstancing}, {me.Msg, "Mở gián đoạn"}, tbEvent);	
	
end;

function tbChangShengDeng:OnOpen(dwNpcId, nPlayerId, tbInstancing)
	if (tbInstancing.nOpenChangShengDeng == 5) then
		return;
	end;
	
	local pNpc = KNpc.GetById(dwNpcId);
	assert(pNpc);
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	assert(pPlayer);
	local tbNpcData = pNpc.GetTempTable("Task"); 
	assert(tbNpcData);	
	if (tbNpcData.nNo ~= (tbInstancing.nOpenChangShengDeng + 1)) then
		local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
		for _, teammate in ipairs(tbPlayList) do
			Task.tbArmyCampInstancingManager:ShowTip(teammate, "Thứ tự mở không đúng, hãy thử lại!");
		end;
		tbInstancing.nOpenChangShengDeng = 0;
		return;
	end;
	
	tbInstancing.nOpenChangShengDeng = tbInstancing.nOpenChangShengDeng + 1;
	pPlayer.Msg("Mở thành công!");
	
	if (tbInstancing.nOpenChangShengDeng == 5) then
		local nSubWorld, _, _	= pNpc.GetWorldPos();
		local pGuWang = KNpc.Add2(self.GUWANG_ID, tbInstancing.nNpcLevel, -1, nSubWorld, 1818, 2847);
		assert(pGuWang);
		
		tbInstancing:NpcSay(pGuWang.dwId, self.tbGuWangText);
		pGuWang.AddLifePObserver(99);
		pGuWang.AddLifePObserver(75);
		pGuWang.AddLifePObserver(50);
		pGuWang.AddLifePObserver(30);
		
		if (tbInstancing.nLiuYiBanOutCount ~= 0) then 
			KNpc.Add2(4155, tbInstancing.nNpcLevel, -1, tbInstancing.nMapId, 1816, 2845);
		end;
		
		local tbPlayList, _ = KPlayer.GetMapPlayer(tbInstancing.nMapId);
		for _, teammate in ipairs(tbPlayList) do
			Task.tbArmyCampInstancingManager:ShowTip(teammate, "Cổ Vương đã xuất hiện!");
		end;
	end;
end;