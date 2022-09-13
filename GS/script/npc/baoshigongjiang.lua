local tbBaoShiGongJiang = Npc:GetClass("baoshigongjiang");

function tbBaoShiGongJiang:OnDialog()
	-- 剥离选项：by zhangjinpin@kingsoft
	if (Item.tbStone:GetOpenDay() == 0) then
		local tbOpt = {
			{"Quay lại sau"},
		};
		Dialog:Say("Hệ thống Bảo thạch chưa mở.", tbOpt);
		return;
	end
	local tbOpt = {
			-- {"<color=yellow>Giới thiệu hệ thống Bảo Thạch<color>", self.Introduce, self},
			{"Cửa hàng Bảo thạch", self.OpenStoneShop, self},
			{"Mở giao diện khảm/tách", me.CallClientScript, {"UiManager:OpenWindow", "UI_EQUIPHOLE", Item.HOLE_MODE_ENCHASE}},
			{"Đục lỗ trang bị", self.CheckPermission, self, {self.Hole, self}},
			{"Đổi Nguyên Thạch", self.CheckPermission, self, {self.ExchangeStone, self}},
			{"Tách Nguyên Thạch", self.CheckPermission, self, {self.BreakUpStone, self}},
			{"Mảnh Khoáng Thạch đổi Nguyên Thạch", self.CheckPermission, self, {self.PreComposeStone, self}},
			{"Mảnh Khoáng Thạch đổi Khoan", self.CheckPermission, self, {self.PreComposeStone2, self}},
			{"Làm mới lỗ trang bị", self.CheckPermission, self, {self.RefreshEquipHoleLevel, self, 1}},
			{"Kết thúc đối thoại"},
		};
			
	local nStoneBreakUpState = Item.tbStone:GetBreakUpState(me);
	if nStoneBreakUpState == 0 then
		table.insert(tbOpt, #tbOpt, {"Xin tách Nguyên thạch cấp cao", self.CheckPermission, self, {self.PreSetStoneBreakUpState, self}});	
	else
		table.insert(tbOpt, #tbOpt, {"Hủy xin tách Nguyên thạch cấp cao", self.SetStoneBreakUpState, self, 0});
	end

	table.insert(tbOpt, #tbOpt, {"Mở khóa Bảo thạch",self.CheckPermission, self, {self.UnBindStone, self}});
	local nStoneUnBindState = Item.tbStone:GetUnBindState(me);
	if nStoneUnBindState == 0 then
		table.insert(tbOpt, #tbOpt, {"Xin Mở khóa Bảo thạch", self.CheckPermission, self, {self.PreUnBindStone, self}});
	else
		table.insert(tbOpt, #tbOpt, {"Hủy xin mở khóa Bảo thạch", self.SetUnBindStoneState, self, 0});
	end

	local szMsg = "<color=yellow>Khảm nạm Bảo thạch<color> có thể tăng sức mạnh, nhưng trước tiên phải <color=yellow>Đục lỗ trang bị<color>.\nTa vẫn còn một số Bảo thạch cùi mía, muốn có Bảo thạch ngon hơn ngươi phải tự đi tìm!";		
	Dialog:Say(szMsg, tbOpt);
end

function tbBaoShiGongJiang:CheckPermission(tbOption)
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản khóa không thể thao tác!");
		Account:OpenLockWindow(me);
		return;
	end
	Lib:CallBack(tbOption);
end

function tbBaoShiGongJiang:OpenStoneShop()
	me.OpenShop(198, 1);
end
-- 装备打孔
function tbBaoShiGongJiang:Hole()
	me.OpenEquipHole(Item.HOLE_MODE_MAKEHOLE);
end

-- 宝石兑换
function tbBaoShiGongJiang:ExchangeStone()
	me.OpenStoneEnhance(Item.tbStone.emSTONE_OPERATION_EXCHANGE);
end

-- 申请原石拆解
function tbBaoShiGongJiang:PreSetStoneBreakUpState()
	local tbOpt = 
	{
		{"Tách Nguyên thạch cấp cao", self.SetStoneBreakUpState, self, 1},
		{"Rời khỏi"},
	};
	Dialog:Say("Tách Nguyên thạch cấp cao diễn ra trong <color=yellow>2 phút<color>, cần <color=yellow>1 phút<color> để chuẩn bị. Sau đó có thể tách Nguyên thạch cấp 4 trở lên.", tbOpt);
end

-- 宝石拆解
function tbBaoShiGongJiang:BreakUpStone()
	me.OpenStoneEnhance(Item.tbStone.emSTONE_OPERATION_BREAKUP);
end

-- 申请高级原石拆解
function tbBaoShiGongJiang:SetStoneBreakUpState(nState)
	if nState == 1 then
		Item.tbStone:ApplyBreakUpStone(me.nId);
	else
		Item.tbStone:CancelBreakUpStone(me.nId);
	end
end

function tbBaoShiGongJiang:PreUnBindStone()
	local tbOpt = 
	{
		{"Yêu cầu mở khóa", self.SetUnBindStoneState, self, 1},
		{"Rời khỏi"},
	};
	Dialog:Say("Mở khóa Bảo thạch diễn ra trong <color=yellow>2 phút<color>, cần <color=yellow>1 phút<color> để chuẩn bị. Sau đó có thể mở khóa 5 Bảo thạch cùng lúc.", tbOpt);
end

-- 宝石、原石解绑
function tbBaoShiGongJiang:UnBindStone()
	Item.tbStone:UnBindStone(me.nId);
end

-- 申请解绑宝石
function tbBaoShiGongJiang:SetUnBindStoneState(nState)
	if nState == 1 then
		Item.tbStone:ApplyUnBindStone(me.nId);		
	else
		Item.tbStone:CancelUnBindStone(me.nId);
	end
end

function tbBaoShiGongJiang:PreComposeStone()
	local tbOpt = {
		{"Xác nhận đổi", self.ComposeStone, self},
		{"Rời khỏi"},
	};
	Dialog:Say("Đổi <color=yellow>30<color> Mảnh Khoáng Thạch lấy 1 <color=yellow>Nguyên Thạch cấp 2 (ngẫu nhiên)<color>.", tbOpt);
end

function tbBaoShiGongJiang:PreComposeStone2()
	local tbOpt = {
		{"Xác nhận đổi", self.ComposeStone2, self},
		{"Rời khỏi"},
	};
	Dialog:Say("Đổi <color=yellow>50<color> Mảnh Khoáng Thạch lấy 1 <color=yellow>Khoan Kim Cương<color>.", tbOpt);
end

function tbBaoShiGongJiang:ComposeStone2()
	local tbStonePatch = Item.tbStone.tbStonePatch;
	local nCount = me.GetItemCountInBags(unpack(tbStonePatch));
	if (nCount < Item.tbStone.nStonePatchPerStone2) then
		Dialog:Say("Cần "..Item.tbStone.nStonePatchPerStone2.." để đổi Nguyên thạch.");
		return;
	end
	if (me.CountFreeBagCell() < 1) then
		Dialog:Say("Hành trang không đủ <color=yellow>1 ô<color> trống, không thể đổi.");
		return;
	end
		
	local nCount = me.ConsumeItemInBags(Item.tbStone.nStonePatchPerStone2, unpack(tbStonePatch));
	if (nCount ~= 0) then
		Dialog:Say("Không thể khấu trừ Mảnh Khoáng Thạch");
		return;
	end
	
	-- 产出限制 2级原石 低级产出（非技能）
	local pItem = Item.tbStone:__RandItemGetStone2();
	if (pItem == nil) then
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "矿石碎片换取随机生成原石错误");
		Dialog:Say("Đổi không thành công!");
		return;
	end
	Item.tbStone:BrodcastMsg("矿石碎片换取", pItem);
	-- 数据埋点
	StatLog:WriteStatLog("stat_info", "baoshixiangqian", "suipianduihuan", me.nId, 
		string.format("%d_%d_%d_%d,%d,%d_%d_%d_%d,%d", tbStonePatch[1], tbStonePatch[2], tbStonePatch[3], tbStonePatch[4], Item.tbStone.nStonePatchPerStone,
					 pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel, 1));			
end

function tbBaoShiGongJiang:ComposeStone()
	local tbStonePatch = Item.tbStone.tbStonePatch;
	local nCount = me.GetItemCountInBags(unpack(tbStonePatch));
	if (nCount < Item.tbStone.nStonePatchPerStone) then
		Dialog:Say("Cần "..Item.tbStone.nStonePatchPerStone.." để đổi Nguyên thạch.");
		return;
	end
	if (me.CountFreeBagCell() < 1) then
		Dialog:Say("Hành trang không đủ <color=yellow>1 ô<color> trống, không thể đổi.");
		return;
	end
		
	local nCount = me.ConsumeItemInBags(Item.tbStone.nStonePatchPerStone, unpack(tbStonePatch));
	if (nCount ~= 0) then
		Dialog:Say("Không thể khấu trừ Mảnh Khoáng Thạch");
		return;
	end
	
	-- 产出限制 2级原石 低级产出（非技能）
	local pItem = Item.tbStone:__RandItemGetStone(1, 2, 0, 2);
	if (pItem == nil) then
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "矿石碎片换取随机生成原石错误");
		Dialog:Say("Đổi không thành công!");
		return;
	end
	Item.tbStone:BrodcastMsg("矿石碎片换取", pItem);
	-- 数据埋点
	StatLog:WriteStatLog("stat_info", "baoshixiangqian", "suipianduihuan", me.nId, 
		string.format("%d_%d_%d_%d,%d,%d_%d_%d_%d,%d", tbStonePatch[1], tbStonePatch[2], tbStonePatch[3], tbStonePatch[4], Item.tbStone.nStonePatchPerStone,
					 pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel, 1));			
end

function tbBaoShiGongJiang:RefreshEquipHoleLevel(nStep)
	nStep = nStep or 1;
	if nStep == 1 then
		local szMsg = "Sau khi sửa chữa, lỗ trên trang bị sẽ được nâng lên phụ thuộc vào phẩm chất trang bị.\n\nBấm đồng ý để xác nhận";
		local tbOpt = 
		{
			{"Đồng ý", self.RefreshEquipHoleLevel, self, 2},
			{"Rời khỏi"}
		}
		Dialog:Say(szMsg, tbOpt);
	end
	
	if nStep == 2 then
		local tbPos = {Item.EQUIPPOS_BODY, Item.EQUIPPOS_AMULET, Item.EQUIPPOS_RING};		-- 三优龙魂装备
		local tbRoom = {Item.ROOM_EQUIP, Item.ROOM_EQUIPEX};	-- 装备栏和备用装备栏
		for _, nRoom in pairs(tbRoom) do
			for _, nPos in pairs(tbPos) do
				local pEquip = me.GetItem(nRoom, nPos, 0);
				if pEquip then
					Item:RefreshEquipHoleLevel(pEquip);
					pEquip.Sync();
				end
			end
		end
		
		me.Msg("Sửa chữa thành công!");
	end
end