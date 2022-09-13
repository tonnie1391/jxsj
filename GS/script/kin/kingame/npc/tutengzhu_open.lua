local tbNpc = Npc:GetClass("tulengzhu_open")

function tbNpc:OnDialog()
	self:OnSwitch(him.dwId);
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

function tbNpc:OnSwitch(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0
	end	
	local tbTmp = pNpc.GetTempTable("KinGame");
	if tbTmp.OnOpenFlag ~= nil then
		Dialog:SendBlackBoardMsg(me, "Cột này đã được mở!");
		return 0;
	end
	if tbTmp.tbLockTable and tbTmp.tbLockTable.tbRoom.nRoomId == 1 then
		local tbFind = me.FindItemInBags(unpack(KinGame.OPEN_KEY_ITEM))
		if #tbFind < 1 then
			return 0;
		end
		local nCount = tbTmp.tbLockTable.tbRoom.tbGame:GetPlayerCount();
		if nCount < KinGame.MIN_PLAYER then
			Dialog:SendBlackBoardMsg(me, "Không đủ số lượng thành viên, xin chờ.");
			return 0;
		end
		if bConfirm ~= 1 then
			Dialog:Say("Trụ cột này đã bị khóa, sau khi mở khóa <color=red>các thành viên gia tộc không thể vào<color> được nữa.",
			{
				{"Mở khóa", self.DoOnSwitch, self, nNpcId},
				{"Kết thúc đối thoại"};
			});
			return 0;
		end
	end
	GeneralProcess:StartProcess("Đang mở...", 30 * Env.GAME_FPS, {self.DoOnSwitch, self, nNpcId}, nil, tbEvent);
end

function tbNpc:DoOnSwitch(nNpcId)
	local pNpc = KNpc.GetById(nNpcId);
	if not pNpc then
		return 0
	end	
	local tbTmp = pNpc.GetTempTable("KinGame");
	if tbTmp.OnOpenFlag ~= nil then
		return 0;
	end
	if tbTmp.tbLockTable and tbTmp.tbLockTable.tbRoom.nRoomId == 1 then
		local tbFind = me.FindItemInBags(unpack(KinGame.OPEN_KEY_ITEM))
		if #tbFind < 1 then
			return 0;
		end
		me.DelItem(tbFind[1].pItem, Player.emKLOSEITEM_TYPE_EVENTUSED);
	end
	local tbTmp = pNpc.GetTempTable("KinGame");
	tbTmp.OnOpenFlag = 1;
	Dialog:SendBlackBoardMsg(me, "Nghe có tiếng động, cửa đã được mở!");
	KinGame:NpcUnLockMulti(pNpc);
end
