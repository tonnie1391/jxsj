-------------------------------------------------------
-- 文件名　：atlantis_npc_city.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-03-15 16:35:12
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\boss\\atlantis\\atlantis_def.lua");

local tbNpc = Npc:GetClass("atlantis_npc_city");

function tbNpc:OnDialog()
	
	local szMsg = "Đại hiệp có từng nghe qua truyền thuyết về <color=yellow>Lâu Lan Cổ Thành<color> - vùng hoang mạc thần bí ở hướng Tây. Kể từ khi bọn lâu la của Nhất Phẩm Đường đến đó đến nay bặt vô âm tín,ngay cả xác vẫn chưa tìm thấy. Ta không muốn mang tội đã đưa chúng đi đến đường chết ... Ngươi có thể giúp ta đến vùng đất bí ẩn đó, đưa một số vật phẩm về không ?";
	local tbOpt = 
	{
		{"<color=yellow>Đến Lâu Lan Cổ Thành<color>", Atlantis.PlayerEnter, Atlantis},
		{"<color=yellow>Trao đổi vật báu Lâu Lan<color>", self.OnChangeChip, self},
		{"<color=yellow>Đổi trang bị đồng hành<color>", self.OnChangeEquip, self},
		-- {"<color=yellow>Trao đổi kho báu trang bị Lâu Lan<color>", self.OnChangeBack, self},
		{"Ta biết rồi"},
	};
	Dialog:Say(szMsg, tbOpt);		
end
	
-- 兑换同伴碎片
function tbNpc:OnChangeChip()
	local tbOpt = {};
	local szMsg = "Ngươi sẽ tìm thấy <color=yellow>Bảo vật Lâu Lan<color> tại Lâu Lan Cổ Thành, cùng với <color=yellow>Nguyệt Ảnh Thạch<color> ta sẽ cho ngươi những gì ngươi muốn <color=yellow>từ những mãnh vỡ đó<color>!";
	for nIndex, tbInfo in ipairs(Atlantis.CHANGE_LIST) do
		table.insert(tbOpt, {string.format("Trao đổi <color=yellow>[%s]<color>", tbInfo.szName), self.OnGiftChip, self, nIndex});
	end
	tbOpt[#tbOpt + 1] = {"Ta biết rồi"};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnGiftChip(nIndex)
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản bị khóa, vui lòng mở khóa tài khoản.");
		return 0;
	end
	Dialog:AskNumber("Vui lòng nhập số", 50, self.DoChangeChip, self, nIndex);
end

function tbNpc:DoChangeChip(nIndex, nInput, nSure)
	
	local tbInfo = Atlantis.CHANGE_LIST[nIndex];
	if not tbInfo or nInput <= 0 then
		Dialog:Say("Vui lòng nhập số chính xác");
		return 0;
	end
	
	local nNeedChip = tbInfo.nNeedChip * nInput;
	local nNeedMoon = tbInfo.nNeedMoon * nInput;
	
	if not nSure then
		local szMsg = string.format([[
    Hãy đưa cho ta:
    <color=yellow>%s %s<color>
    <color=yellow>%s Nguyệt Ảnh Thạch<color>
    Ta sẽ đưa cho ngươi: <color=yellow>%s %s<color>, quá hời phải không?]], nNeedChip, tbInfo.szBase, nNeedMoon, nInput, tbInfo.szName);
		local tbOpt =
		{
			{"<color=yellow>Xác định<color>", self.DoChangeChip, self, nIndex, nInput, 1},
			{"Ta nghĩ lại đã"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	local nCount = me.GetItemCountInBags(unpack(tbInfo.tbBaseId));
	if nCount < nNeedChip then
		Dialog:Say(string.format(" Ngươi không có <color=yellow>%s %s<color>\n Ta không chơi với kẻ lừa dối!", nNeedChip, tbInfo.szBase));
		return 0;
	end
	
	nCount = me.GetItemCountInBags(unpack(Atlantis.ITEM_MOON_ID));
	if nCount < nNeedMoon then
		Dialog:Say(string.format(" Ngươi không có <color=yellow>%s Nguyệt Ảnh Thạch<color>\n Ta không chơi với kẻ lừa dối!", nNeedMoon));
		return 0;
	end
	
	local nNeedSpace = KItem.GetNeedFreeBag(tbInfo.tbItemId[1], tbInfo.tbItemId[2], tbInfo.tbItemId[3], tbInfo.tbItemId[4], nil, nInput);
	if me.CountFreeBagCell() < nNeedSpace then
		Dialog:Say(string.format("Hành trang không đủ <color=yellow>%s<color> ô trống", nNeedSpace));
		return 0;
	end
	
	local nRet = me.ConsumeItemInBags2(nNeedChip, tbInfo.tbBaseId[1], tbInfo.tbBaseId[2], tbInfo.tbBaseId[3], tbInfo.tbBaseId[4]);
	if nRet ~= 0 then
		Dbg:WriteLog("Lâu Lan Cổ Thành", "Atlantis", me.szAccount, me.szName, string.format("khấu trừ%s-%skhông thành công", tbInfo.szBase, nNeedChip));
	end
	
	nRet = me.ConsumeItemInBags2(nNeedMoon, Atlantis.ITEM_MOON_ID[1], Atlantis.ITEM_MOON_ID[2], Atlantis.ITEM_MOON_ID[3], Atlantis.ITEM_MOON_ID[4]);
	if nRet ~= 0 then
		Dbg:WriteLog("Lâu Lan Cổ Thành", "Atlantis", me.szAccount, me.szName, string.format("khấu trừ%s Nguyện ảnh Thạch không thành công", nNeedMoon));
	end
	
	me.AddStackItem(tbInfo.tbItemId[1], tbInfo.tbItemId[2], tbInfo.tbItemId[3], tbInfo.tbItemId[4], nil, nInput);
	
	Dbg:WriteLog("Atlantis", "Lâu Lan Cổ Thành", me.szAccount, me.szName, "đổi trang bị đồng hành", string.format("%s-%s", nInput, tbInfo.szName));
	StatLog:WriteStatLog("stat_info", "loulangucheng", "gain", me.nId, me.GetHonorLevel(), tbInfo.szName, nInput);
	StatLog:WriteStatLog("stat_info", "yueyingxiaohao", "exchange", me.nId, nNeedMoon, tbInfo.szName, nInput);
end

-- 兑换同伴装备
function tbNpc:OnChangeEquip()
	local tbNewland = Npc:GetClass("newland_npc_city");
	tbNewland:ExchangePartnerEq();
end

-- 同伴装备兑换材料
function tbNpc:OnChangeBack()
	Dialog:OpenGift("Xin vui lòng đặt trang bị đồng hành Lâu Lan <color=yellow>chỉ có thể trao đổi<color>", nil, {self.DoChangeBack, self});
end

function tbNpc:DoChangeBack(tbItem, nSure)
	
	local tbPartnerEquip =
	{
		[1] = {"Bích Huyết Hộ Uyển", {5, 22, 1, 1}, {18, 1, 1237, 1}, 45},
		[2] = {"Bích Huyết Giới Chỉ", {5, 21, 1, 1}, {18, 1, 1240, 1}, 45},
		[3] = {"Kim Lân Hộ Uyển", {5, 22, 1, 2}, {18, 1, 1238, 1}, 45},
		[4] = {"Kim Lân Giới Chỉ", {5, 21, 1, 2}, {18, 1, 1241, 1}, 45},
	};
	
	local nBind = 0;
	local nValue = 0;
	local tbEquip = nil;
	for _, tbTmpItem in pairs(tbItem) do
		local pItem = tbTmpItem[1];
		if Partner:GetPartnerEquipParam(pItem) ~= 1 then
			local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
			for _, tbInfo in pairs(tbPartnerEquip) do
				if szKey == string.format("%s,%s,%s,%s", unpack(tbInfo[2])) then
					nValue = nValue + 1;
					tbEquip = tbInfo;
					nBind = pItem.IsBind() or 0;
				end
			end
		end
	end
	
	if nValue ~= 1 then
		Dialog:Say("Xin vui lòng đặt đúng các thiết bị đồng hành , mỗi thiết bị đồng hành chỉ có thể đặt một");
		return 0;
	end

	local nNeed = KItem.GetNeedFreeBag(tbEquip[3][1], tbEquip[3][2], tbEquip[3][3], tbEquip[3][4], {bForceBind = nBind}, tbEquip[4]);
	if me.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("Hãy để %s ô trống hành trang", nNeed));
		return 0;
	end
	
	if not nSure then
		local szMsg = string.format("Ngươi có muốn<color=yellow>%s<color>đổi<color=yellow>%s<color>trang bị đồng hành không?",tbEquip[1], tbEquip[4]);
		local tbOpt =
		{
			{"<color=yellow>Đồng ý<color>", self.DoChangeBack, self, tbItem, 1},
			{"Kết thúc đối thoại"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	for _, tbTmpItem in pairs(tbItem) do
		local pItem = tbTmpItem[1];
		if Partner:GetPartnerEquipParam(pItem) ~= 1 then
			local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
			if szKey == string.format("%s,%s,%s,%s", unpack(tbEquip[2])) then
				if me.DelItem(pItem) == 1 then
					me.AddStackItem(tbEquip[3][1], tbEquip[3][2], tbEquip[3][3], tbEquip[3][4], {bForceBind = nBind}, tbEquip[4]);
					Dbg:WriteLog("Atlantis", "Lâu Lan Cổ Thành", me.szAccount, me.szName, "ͬđổi thiết bị đồng hành", tbEquip[1], tbEquip[4], nBind);
					StatLog:WriteStatLog("stat_info", "partnerequip", "reback", me.nId, tbEquip[1], tbEquip[4], nBind);
				else
					Dbg:WriteLog("Atlantis", "Lâu Lan Cổ Thành", me.szAccount, me.szName, "ͬĐổi thiết bị đồng hành thất bại", tbEquip[1], tbEquip[4], nBind);
				end
				break;
			end
		end
	end
end
