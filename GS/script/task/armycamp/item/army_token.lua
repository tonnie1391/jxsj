--军营令牌
--孙多良
--2008.08.19

local tbItem = Item:GetClass("army_token")
tbItem.tbItemId = 
{
	[606] = 0,	--单次
	[607] = 1,	--无限军营令牌
	[195] = 1,	--无限传送符
	[235] = 1,
}
-- （此表会被其它模块引用）
tbItem.tbTransMap = {
	{"Quân doanh [Phượng Tường]",24,1917,3444},
	{"Quân doanh [Tương Dương]",25,1464,3061},
	{"Quân doanh [Lâm An]",29,1606,4139}
}
tbItem.nTime = 5;

-- （此函数会被其它模块调用）
function tbItem:OnUse()
	local szMsg = "Hãy chọn điểm báo danh, nếu muốn đến <color=yellow>Phục Ngưu Sơn Quân Doanh<color> hãy tìm <color=green>Truyền Tống Quân Doanh<color> tại các Tân Thủ Thôn để đến.";
	local tbOpt = {}
	for i, tbItem in ipairs(self.tbTransMap) do
		table.insert(tbOpt, {tbItem[1], self.OnTrans, self, it.dwId, i, 0})
	end
	
	Lib:SmashTable(tbOpt);
	
	self.nOptionAutoTeamId = #tbOpt + 1;
	table.insert(tbOpt, { "Tự động tổ đội", self.OnTrans, self, it.dwId, self.nOptionAutoTeamId, 0});
	
	table.insert(tbOpt, {"Kết thúc đối thoại"});
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:OnTrans(nItemId, nTransId, nWithOutItem)
	local pPlayer = me;
	if nTransId == self.nOptionAutoTeamId then
		pPlayer.CallClientScript({ "AutoTeam:OpenUi" });
		return;
	end
	
	if pPlayer.nLevel < 60 then
		pPlayer.Msg("Người chơi dưới cấp 60 không được vào Quân Doanh");
		return;
	end
	local tbEvent	= {						-- 会中断延时的事件
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
	};
	if (0 == pPlayer.nFightState) then				-- 玩家在非战斗状态下传送无延时正常传送
		self:TransSure(nItemId, nTransId, pPlayer.nId, nWithOutItem);
		return 0;
	end

	GeneralProcess:StartProcess("Đang chuyển đến Quân Doanh...", self.nTime * Env.GAME_FPS, {self.TransSure, self, nItemId, nTransId, pPlayer.nId, nWithOutItem}, nil, tbEvent);	-- 在战斗状态下需要nTime秒的延时
end

function tbItem:TransSure(nItemId, nTransId, nPlayerId, nWithOutItem)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if nWithOutItem ~= 1 then
		local pItem = KItem.GetObjById(nItemId);
		if not pItem or not pPlayer then
			return 0;
		end
		if self.tbItemId[pItem.nParticular] ~= 1 then
			local nCount = pItem.nCount;
			if nCount <= 1 then
				if (pPlayer.DelItem(pItem, Player.emKLOSEITEM_USE) ~= 1) then
					pPlayer.Msg("Xóa Lệnh Bài Quân Doanh thất bại!");
					return 0;
				end
			else
				pItem.SetCount(nCount - 1, Item.emITEM_DATARECORD_REMOVE);
				pItem.Sync();
			end
		end
	end
	pPlayer.NewWorld(self.tbTransMap[nTransId][2], self.tbTransMap[nTransId][3], self.tbTransMap[nTransId][4]);
end
