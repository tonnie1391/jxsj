local tbItem = Item:GetClass("equipbox");

tbItem.tbLevelDesc = 
{
	[6] = "Cấp 60",
	[7] = "Cấp 70",
	[8] = "Cấp 80",
	[9] = "Cấp 90",	
	[10] = "Cấp 100",
};

tbItem.tbQualityDesc =
{
	[1] = "Trang bị thủ công thường",
	[2] = "Trang bị thủ công cao cấp",	
	[3] = "Trang bị Hoàng Kim",	
};

tbItem.tbQianghuaDesc = 
{
	[0] = "Chưa cường hóa",
};
for i = 1, 16 do
	tbItem.tbQianghuaDesc[i] = "+" .. i;
end

tbItem.tbSexDesc = 
{
	[0] = "Nam",
	[1] = "Nữ"	,
};

tbItem.tbSexForbidEquip =
{
	[0] = 5,	-- 男性禁止选峨眉
	[1] = 1,	-- 女性禁止选少林
};

function tbItem:LoadEquipList()
	local tbAddedItem = {};
	local tbItem_4pre = Lib:LoadTabFile("\\setting\\item\\equipgift\\giftequiplist_4pre.txt");
	if not tbItem_4pre or #tbItem_4pre == 0 then
		Dbg:WriteLog("Khong tim thay file");
		return nil;
	end
	local tbItem_20pre = Lib:LoadTabFile("\\setting\\item\\equipgift\\giftequiplist_20pre.txt");
	if not tbItem_20pre or #tbItem_20pre == 0 then
		Dbg:WriteLog("Khong tim thay file");
		return nil;
	end
	local tbItem_hk = Lib:LoadTabFile("\\setting\\item\\equipgift\\giftequiplist_hk.txt");
	if not tbItem_hk or #tbItem_hk == 0 then
		Dbg:WriteLog("Khong tim thay file");
		return nil;
	end
	tbAddedItem[1] = self:FilterTab(tbItem_20pre);
	tbAddedItem[2] = self:FilterTab(tbItem_4pre);
	tbAddedItem[3] = self:FilterTab(tbItem_hk);
	
	return tbAddedItem;
end

function tbItem:FilterTab(tbEquipTable)
	local tbEquip = {};
	for i = 1, Env.FACTION_NUM do
		tbEquip[i] = {};	-- 门派
		for j = 1, 2 do
			tbEquip[i][j] = {};	-- 路线
			for k = 0, 1 do
				tbEquip[i][j][k] = {}; -- 性别
				for p = 1, 10 do 
					tbEquip[i][j][k][p] = {};	-- 装备位置
				end
			end
		end
	end
	for nIndex, tbTemp in ipairs(tbEquipTable) do
		tbEquip[tonumber(tbTemp["Faction"])][tonumber(tbTemp["RoutId"])][tonumber(tbTemp["Sex"])-1][tonumber(tbTemp["PartId"])][1] = tonumber(tbTemp["Genre"]);
		tbEquip[tonumber(tbTemp["Faction"])][tonumber(tbTemp["RoutId"])][tonumber(tbTemp["Sex"])-1][tonumber(tbTemp["PartId"])][2] = tonumber(tbTemp["DetailType"]);
		tbEquip[tonumber(tbTemp["Faction"])][tonumber(tbTemp["RoutId"])][tonumber(tbTemp["Sex"])-1][tonumber(tbTemp["PartId"])][3] = tonumber(tbTemp["ParticularType"]);
		tbEquip[tonumber(tbTemp["Faction"])][tonumber(tbTemp["RoutId"])][tonumber(tbTemp["Sex"])-1][tonumber(tbTemp["PartId"])][4] = tonumber(tbTemp["Level"]);
	end
	return tbEquip;
end

function tbItem:OnUse()
	local nRes, nLevel, nQuality, nQianghua = self:CheckParam(it.dwId);
	if nRes == 0 then
		Dialog:Say("Lỗi hệ thống!");
		return;
	end
	local szMsg = string.format("Mở gói quà này sẽ nhận được bộ trang bị giới tính <color=yellow>%s<color>:\n", self.tbSexDesc[me.nSex]);
	szMsg = szMsg .. string.format("Cấp độ trang bị: <color=yellow>%s<color>\n", self.tbLevelDesc[nLevel]);
	szMsg = szMsg .. string.format("Phẩm chất: <color=yellow>%s<color>\n", self.tbQualityDesc[nQuality]);
	szMsg = szMsg .. string.format("Cường hóa: <color=yellow>%s<color>\n\n", self.tbQianghuaDesc[nQianghua]);
	szMsg = szMsg .. "Xác nhận mở chứ?";
	local tbOpt = 
	{
		{"Xác nhận", self.GetEquipFaction, self, it.dwId, 1},
		{"Để ta suy nghĩ lại"},	
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:CheckParam(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local nLevel = pItem.GetExtParam(1) or 6; 		-- 等级
	local nQuality = pItem.GetExtParam(2) or 1; 	-- 橙装或紫装
	local nQianghua = pItem.GetExtParam(3) or 0;	-- 强化
	if nQuality > 16 or nQuality < 0 or nLevel < 6 or nLevel > 10 or nQuality < 1 or nQuality > 3 then
		return 0;
	end
	return 1, nLevel, nQuality, nQianghua;
end

-- 获取装备的门派
function tbItem:GetEquipFaction(nItemId, nPosStartIdx)
	local nRes, nLevel, nQuality, nQianghua = self:CheckParam(nItemId);
	if nRes == 0 then
		return 0;
	end
	local tbOpt		= {};
	local nCount	= 9;
	for i = nPosStartIdx, Player.FACTION_NUM do
		if (nCount <= 0) then
			tbOpt[#tbOpt]	= {"Trang sau", self.GetEquipFaction, self, nItemId, i - 1};
			break;
		end
		
		if self.tbSexForbidEquip[me.nSex] ~= i then
			tbOpt[#tbOpt+1]	= {Player:GetFactionRouteName(i), self.GetEquipRoute, self, nItemId, i, 1};
			nCount	= nCount - 1;
		end
		
	end;
	tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
	local szMsg = string.format("Mở gói quà này sẽ nhận được bộ trang bị giới tính <color=yellow>%s<color>:\n", self.tbSexDesc[me.nSex]);
	szMsg = szMsg .. string.format("Cấp độ trang bị: <color=yellow>%s<color>\n", self.tbLevelDesc[nLevel]);
	szMsg = szMsg .. string.format("Phẩm chất: <color=yellow>%s<color>\n", self.tbQualityDesc[nQuality]);
	szMsg = szMsg .. string.format("Cường hóa: <color=yellow>%s<color>\n\n", self.tbQianghuaDesc[nQianghua]);
	szMsg = szMsg .. "Lựa chọn môn phái";
	Dialog:Say(szMsg, tbOpt);
end

-- 获得装备所属的路线
function tbItem:GetEquipRoute(nItemId, nFactionId, nPosStartIdx)
	local nRes, nLevel, nQuality, nQianghua = self:CheckParam(nItemId);
	if nRes == 0 then
		return 0;
	end
	local tbOpt		= {};
	local nCount	= 9;
	for i = nPosStartIdx, #Player.tbFactions[nFactionId].tbRoutes do
		if (nCount <= 0) then
			tbOpt[#tbOpt]	= {"Trang sau", self.GetEquipRoute, self, nItemId, nFactionId, i - 1};
			break;
		end
		tbOpt[#tbOpt+1]	= {Player:GetFactionRouteName(nFactionId, i), self.GetEquip, self, nItemId, nFactionId, i};
		nCount	= nCount - 1;
	end;
	tbOpt[#tbOpt+1]	= {"Kết thúc đối thoại"};
	local szMsg = string.format("Mở gói quà này sẽ nhận được bộ trang bị giới tính <color=yellow>%s<color>:\n", self.tbSexDesc[me.nSex]);
	szMsg = szMsg .. string.format("Môn phái: <color=yellow>%s<color>\n", Player:GetFactionRouteName(nFactionId));
	szMsg = szMsg .. string.format("Cấp độ trang bị: <color=yellow>%s<color>\n", self.tbLevelDesc[nLevel]);
	szMsg = szMsg .. string.format("Phẩm chất: <color=yellow>%s<color>\n", self.tbQualityDesc[nQuality]);
	szMsg = szMsg .. string.format("Cường hóa: <color=yellow>%s<color>\n\n", self.tbQianghuaDesc[nQianghua]);
	szMsg = szMsg .. "Lựa chọn hướng tu luyện";
	Dialog:Say(szMsg, tbOpt);
end

-- 获得装备
function tbItem:GetEquip(nItemId, nFactionId, nRouteId, nSure)
	local nRes, nLevel, nQuality, nQianghua = self:CheckParam(nItemId);
	if nRes == 0 then
		return 0;
	end
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	if not nSure then
		local szMsg = string.format("Mở gói quà này sẽ nhận được bộ trang bị giới tính <color=yellow>%s<color>:\n", self.tbSexDesc[me.nSex]);
		szMsg = szMsg .. string.format("Môn phái: <color=yellow>%s<color>\n", Player:GetFactionRouteName(nFactionId));
		szMsg = szMsg .. string.format("Hướng tu luyện: <color=yellow>%s<color>\n", Player:GetFactionRouteName(nFactionId, nRouteId));
		szMsg = szMsg .. string.format("Cấp độ trang bị: <color=yellow>%s<color>\n", self.tbLevelDesc[nLevel]);
		szMsg = szMsg .. string.format("Phẩm chất: <color=yellow>%s<color>\n", self.tbQualityDesc[nQuality]);
		szMsg = szMsg .. string.format("Cường hóa: <color=yellow>%s<color>\n\n", self.tbQianghuaDesc[nQianghua]);
		szMsg = szMsg .. "Hãy xem lại lần nữa nhé!";
		local tbOpt = 
		{
			{"Hoàn toàn đúng", self.GetEquip, self, nItemId, nFactionId, nRouteId, 1},
			{"Để ta nghĩ lại"},	
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	self.tbAddedItem = self.tbAddedItem or self:LoadEquipList();
	if not self.tbAddedItem then
		Dialog:Say("Không sử dụng được vật phẩm!");
		return 0;
	end
	local tbEquip	= self.tbAddedItem[nQuality][nFactionId][nRouteId][me.nSex];
	local tbTempEquip = {};
	for i = 1, #tbEquip do
		tbTempEquip[i] = {};
		tbTempEquip[i][1] = tbEquip[i][1];
		tbTempEquip[i][2] = tbEquip[i][2];
		tbTempEquip[i][3] = tbEquip[i][3] + nLevel - 10;
		tbTempEquip[i][4] = tbEquip[i][4] + nLevel - 10;
		tbTempEquip[i][5] = -1;
	end
	if me.CountFreeBagCell() < #tbEquip then
		Dialog:Say(string.format("Hành trang không đủ chỗ trống, hãy để trống <color=yellow>%s ô<color>.", #tbEquip));
		return 0;
	end 
	local szItemGDPL = string.format("(%s,%s,%s,%s)", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
	me.DelItem(pItem);
	if nQuality == 3 then
		me.AddStackItem(21, 9, 3, 1, nil, 3)
		me.AddStackItem(1, 12, 24, 4, nil, 1)
		me.AddStackItem(1, 17, me.nSeries * 2 - 1 + me.nSex, 7, nil, 1)
		
		local pEquip = me.AddItem(1, 14, nFactionId * 2 - 2 + nRouteId, 3)
		me.AutoEquip(pEquip);
		me.UpdateBook(100, 0)
		
		local nTaskGroup 	= 1022;
		local nTaskId		= 215;
		local nValue 		= me.GetTask(nTaskGroup, nTaskId);
		nValue = KLib.SetBit(nValue, nFactionId, 1)
		me.SetTask(nTaskGroup, nTaskId, nValue);
	end
	for i = 1, #tbTempEquip do
		local tbTmp = {unpack(tbTempEquip[i])};
		tbTmp[6] = tbTmp[6] or nQianghua;
		local pAddItem = me.AddItem(unpack(tbTmp));
		if pAddItem then
			if nQuality == 3 then
				pAddItem.MakeHole(1, 6, 1)
				pAddItem.MakeHole(2, 6, 0)
				pAddItem.MakeHole(3, 6, 0)
			end
			pAddItem.Bind(1);
			local szAddItemGDPL = string.format("(%s,%s,%s,%s)", pAddItem.nGenre, pAddItem.nDetail, pAddItem.nParticular, pAddItem.nLevel);
			Dbg:WriteLog(string.format("%s mở %s nhận được %s %s cường hóa +%s", me.szName, szItemGDPL, pAddItem.szName, szAddItemGDPL, pAddItem.nEnhTimes));
		end
	end
	
end

-- 测试(级别：6-10，属性：1代表百20，2代表4%， 强化：1-16， 门派：1-13， Hướng tu luyện: 1-2， 性别：0-1)
function tbItem:Test_AddEquit(nLevel, nQuality, nQiangHua, nFactionId, nRouteId, nSex)
	self.tbAddedItem = self.tbAddedItem or self:LoadEquipList();
	local tbEquip	= self.tbAddedItem[nQuality][nFactionId][nRouteId][nSex];
	local tbTempEquip = {};
	for i = 1, #tbEquip do
		tbTempEquip[i] = {};
		tbTempEquip[i][1] = tbEquip[i][1];
		tbTempEquip[i][2] = tbEquip[i][2];
		tbTempEquip[i][3] = tbEquip[i][3] + nLevel - 10;
		tbTempEquip[i][4] = tbEquip[i][4] + nLevel - 10;
		tbTempEquip[i][5] = -1;
	end
	if me.CountFreeBagCell() < #tbEquip then
		Dialog:Say(string.format("Hành trang không đủ chỗ trống, hãy để trống <color=yellow>%s ô<color>.", #tbEquip));
		return 0;
	end 
	for i = 1, #tbTempEquip do
		local tbTmp = {unpack(tbTempEquip[i])};
		tbTmp[6] = tbTmp[6] or nQiangHua;
		local pAddItem = me.AddItem(unpack(tbTmp));
		if pAddItem then
			pAddItem.Bind(1);
		end
	end
end
