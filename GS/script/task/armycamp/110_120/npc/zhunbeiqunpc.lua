-------------------------------------------------------
-- 文件名　：zhunbeiqunpc.lua
-- 文件描述：准备区NPC脚本
-- 创建者　：ZhangDeheng
-- 创建时间：2009-03-16 09:17:36
-------------------------------------------------------


-- 路路通
local tbNpc = Npc:GetClass("hl_lulutong");
-- 传送的位置
tbNpc.tbPos = {
	{"Tầng 1", 1841, 3210,},
	{"Tầng 2", 1883, 3452,},
	{"Tầng 3", 1819, 3647},
	};
tbNpc.tbPosKuoZhanQu = {
		{"Bàn cờ tướng", 53696 / 32, 115104 / 32},
		{"Đồng trung nhân", 52288 / 32, 109760 / 32},
		{"Truy đuổi Lưu Nhất Bán", 54144 / 32, 124160 / 32},
	}

function tbNpc:OnDialog()
	local nSubWorld, _, _	= him.GetWorldPos();
	local tbInstancing = Task.tbArmyCampInstancingManager:GetInstancing(nSubWorld);
	assert(tbInstancing);
	
	local szMsg = "Đây là lối tắt đến nhiều nơi khác nhau trong ngục tối. Nếu ngươi hoặc đồng đội đã mở được cơ quan, ngươi có thể đến đó trực tiếp thông qua lối tắt này. Nhưng ngươi cần phải trả 500 lượng bạc.";
	local tbOpt = {};
	for i = 1, #self.tbPos do
		tbOpt[#tbOpt + 1] = {"Đi " .. self.tbPos[i][1], tbNpc.Send, self, i, tbInstancing, me.nId};
	end;
	if (tbInstancing.tbKuoZhanQuOut[1] == 1) then
		tbOpt[#tbOpt + 1] = {"Đi " .. self.tbPosKuoZhanQu[1][1], tbNpc.Send, self, 4, tbInstancing, me.nId};
	end;
	if (tbInstancing.tbKuoZhanQuOut[2] == 1) then
		tbOpt[#tbOpt + 1] = {"Đi " .. self.tbPosKuoZhanQu[2][1], tbNpc.Send, self, 5, tbInstancing, me.nId};
	end;
	if (tbInstancing.tbKuoZhanQuOut[3] == 1) then
		tbOpt[#tbOpt + 1] = {"Đi " .. self.tbPosKuoZhanQu[3][1], tbNpc.Send, self, 6, tbInstancing, me.nId};
	end;
	
	tbOpt[#tbOpt + 1] = {"Kết thúc đối thoại"};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:Send(nPos, tbInstancing, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end;
	
	if (pPlayer.nCashMoney < 500) then
		Task.tbArmyCampInstancingManager:Warring(pPlayer, "Ngươi không đủ tiền!");
		return;
	end
	
	if (nPos == 1 and tbInstancing.nTrap2Pass == 1) then
		self:SendToNewPos(nPos, tbInstancing.nMapId, nPlayerId);
		tbInstancing:OnCoverBegin(pPlayer);
		return;
	elseif (nPos == 2 and tbInstancing.nTrap4Pass == 1) then
		self:SendToNewPos(nPos, tbInstancing.nMapId, nPlayerId);
		tbInstancing:OnCoverBegin(pPlayer);
		return;
	elseif (nPos == 3 and tbInstancing.nTrap6Pass == 1) then
		self:SendToNewPos(nPos, tbInstancing.nMapId, nPlayerId);
		return;
	elseif (nPos == 4) then
		self:SendToNewPos(4, tbInstancing.nMapId, nPlayerId);
		return;
	elseif (nPos == 5) then
		self:SendToNewPos(5, tbInstancing.nMapId, nPlayerId);
		return;
	elseif (nPos == 6) then
		self:SendToNewPos(6, tbInstancing.nMapId, nPlayerId);
		return;
	end;

	Task.tbArmyCampInstancingManager:Warring(pPlayer, "Chỉ sử dụng để đi tắt đến ải đã vượt qua");
end;

function tbNpc:SendToNewPos(nPos, nMapId, nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if (not pPlayer) then
		return;
	end;
		
	assert(pPlayer.CostMoney(500, Player.emKPAY_CAMPSEND) == 1);
	if (nPos <= 3) then
		pPlayer.NewWorld(pPlayer.nMapId, tbNpc.tbPos[nPos][2], tbNpc.tbPos[nPos][3]);
	elseif (nPos <= 6) then
		pPlayer.NewWorld(pPlayer.nMapId, tbNpc.tbPosKuoZhanQu[nPos - 3][2], tbNpc.tbPosKuoZhanQu[nPos - 3][3]);
	end;
		
	pPlayer.SetFightState(1);	
end;