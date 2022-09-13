local tbNpc = Npc:GetClass("elunheyuan_lulutong");

-- 传送的位置
tbNpc.tbPos = {
	{"Khu bắt ngựa", 1752, 3580,},
	{"Tế Tự Đài", 1755, 3423},
	{"Đại Doanh Kha Hãn", 1694, 3258},
};

function tbNpc:OnDialog()
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	local szMsg = "Đây là lối tắt đến các nơi trong phó bản, nếu như ngươi hoặc đồng đội của ngươi đã mở ra điều kiện thông quan, liền có thể thông qua lối tắt này trực tiếp đi tới đó.";
	local tbOpt = {};
	for i = 1, #self.tbPos do
		tbOpt[#tbOpt + 1] = {"Đi " .. self.tbPos[i][1], tbNpc.Send, self, i, tbInstancing, me.nId};
	end
	tbOpt[#tbOpt + 1] = {"Kết thúc đối thoại"};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:Send(nPos, tbInstancing, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end;
	-- 正在进行关卡游戏中不能传送
	for i = 1, #tbInstancing.tbTollgateReset do
		if tbInstancing.tbTollgateReset[i] == 0 then
			Task.tbArmyCampInstancingManager:Warring(pPlayer, "Đồng đội đang chiến đấu, hãy chờ đợi");
			return;
		end
	end
	if nPos == 1 and tbInstancing.tbTollgateReset[1] == 2 then
		self:SendToNewPos(nPos, tbInstancing.nMapId, nPlayerId, 0);
		return;
	elseif nPos == 2 and tbInstancing.tbTollgateReset[3] == 2 then
		self:SendToNewPos(nPos, tbInstancing.nMapId, nPlayerId, 0);
		return;
	elseif nPos == 3 and tbInstancing.tbTollgateReset[5] == 2 then
		self:SendToNewPos(nPos, tbInstancing.nMapId, nPlayerId, 0);
		return;
	end
	Task.tbArmyCampInstancingManager:Warring(pPlayer, "Chỉ có thể sử dụng khi đã vượt qua cấp độ.");
end

function tbNpc:SendToNewPos(nPos, nMapId, nPlayerId, nFightState)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end;
		
	pPlayer.NewWorld(pPlayer.nMapId, tbNpc.tbPos[nPos][2], tbNpc.tbPos[nPos][3]);
		
	pPlayer.SetFightState(nFightState);	
end;