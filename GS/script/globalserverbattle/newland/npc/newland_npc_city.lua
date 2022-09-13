-------------------------------------------------------
-- 文件名　: newland_npc_city.lua
-- 创建者　: zhangjinpin@kingsoft
-- 创建时间: 2010-09-06 16:51:04
-- 文件描述: 城市npc
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\newland\\newland_def.lua");

local tbNpc = Npc:GetClass("newland_npc_city");

-------------------------------------------------------
-- 1. 打开报名界面
-- 2. 传送到英雄岛
-- 3. 查询跨服绑银
-- 4. 领取征战奖励
-- 5. 兑换同伴装备
-------------------------------------------------------

function tbNpc:OnDialog()
	
	-- 活动是否开启
	-- if Newland:CheckIsOpen() ~= 1 then
		-- Dialog:Say("Một lần đi thắm thoát mười năm, không ai nhận ra ta nữa. ");
		-- return 0;
	-- end
	
	-- 区服是否开启跨服功能
	local nTransferId = Transfer:GetMyTransferId(me);
	if not Transfer.tbGlobalMapId[nTransferId] then
		Dialog:Say("Một lần đi thắm thoát mười năm, không ai nhận ra ta nữa. ");
		return 0;
	end
	
	-- if (Newland:OpenTimeFrame() == 0) then
		-- Dialog:Say("本服开放103天后方能报名跨服城战. ");
		-- return 0;		
	-- end
	
	local tbOpt = {};
	local szMsg = "Thành trì sụp đổ đang chờ đợi chủ nhân mới. Ngươi có phải anh hùng thực sự không?";
	
	-- 届数校验
	Newland:RectifySession(me);
	
	-- 帮会首领选项
	if Newland:GetPeriod() == Newland.PERIOD_SIGNUP then
		table.insert(tbOpt, {"<color=yellow>Báo danh công thành chiến<color>", self.SignupWar, self});
		
	elseif Newland:GetPeriod() == Newland.PERIOD_WAR_OPEN then
		table.insert(tbOpt, {"Danh sách Bang hội đăng ký", self.ShowGroup, self});
	end
	
	-- 传送至英雄岛
	if Newland:GetPeriod() == Newland.PERIOD_WAR_OPEN then
		table.insert(tbOpt, 1, {"<color=yellow>Đến Đảo Anh Hùng<color>", self.AttendWar, self});
	else
		table.insert(tbOpt, {"<color=gray>Đến Đảo Anh Hùng<color>", self.AttendWar, self});
	end
	
	-- 领取奖励
	if Newland:GetPeriod() == Newland.PERIOD_WAR_REST and Newland:GetSession() ~= 0 then
		table.insert(tbOpt, {"<color=yellow>Nhận phần thưởng<color>", self.ShowAllAward, self});
	end
	
	-- 查询和兑换
	table.insert(tbOpt, {"Tra cứu bạc khóa liên server", self.QueryGlobalMoney, self});
	table.insert(tbOpt, {"Tra cứu Thành chủ trước đây", self.QueryCastleHistory, self});
	
	for szZone, tbHistory in pairs(Newland.tbCastleHistoryBuffer) do
		if (Newland.tbZoneId2Name[szZone]) then
			table.insert(tbOpt, {string.format("Tra cứu <color=yellow>%s<color> thành chủ", Newland.tbZoneId2Name[szZone]), self.QueryCastleOldHistory, self, szZone});
		end
	end
	
	-- table.insert(tbOpt, {"Đổi trang bị đồng hành", self.ExchageEquip, self});
	-- table.insert(tbOpt, {"Tinh chế mảnh trang bị đồng hành", self.SplitAtom, self});
	-- table.insert(tbOpt, {"Tìm hiểu hoạt động", self.WarHelp, self});
	table.insert(tbOpt, {"Danh sách máy chủ tham chiến", self.QueryGlobalArea, self});
	table.insert(tbOpt, {"Ta hiểu rồi"});
	
	Dialog:Say(szMsg, tbOpt);
end

--打开战区界面
function tbNpc:QueryGlobalArea()
	me.CallClientScript({"UiManager:OpenWindow", "UI_GLOBAL_AREA"});
end

-- 帮会报名
function tbNpc:SignupWar()

	-- 是否报名期
	if Newland:GetPeriod() ~= Newland.PERIOD_SIGNUP then
		Dialog:Say("<color=yellow>Bây giờ không phải giai đoạn báo danh!<color>");
		return 0;
	end
	
	-- 打开报名界面
	local nCaptain = Newland:CheckTongCaptain(me);
	me.CallClientScript({"UiManager:OpenWindow", "UI_TIEFUCHENGENROLL"});
	me.CallClientScript({"Ui:ServerCall", "UI_TIEFUCHENGENROLL", "OnRecvData", nCaptain, Newland.tbSignupBuffer});
end

-- 报名帮会列表
function tbNpc:ShowGroup()
	
	if Newland:GetPeriod() ~= Newland.PERIOD_WAR_OPEN then
		return 0;
	end
	
	local tbList = {};
	for szTongName, tbInfo in pairs(Newland.tbSignupBuffer) do
		if tbInfo.nSuccess == 1 then
			tbList[szTongName] = tbInfo;
		end
	end
	
	me.CallClientScript({"UiManager:OpenWindow", "UI_TIEFUCHENGENROLL"});
	me.CallClientScript({"Ui:ServerCall", "UI_TIEFUCHENGENROLL", "OnRecvData", 0, tbList});
	me.CallClientScript({"Ui:ServerCall", "UI_TIEFUCHENGENROLL", "DisableAll"});
end

-- 传送到侠客岛
function tbNpc:AttendWar()

	-- 等级限制
	if me.nLevel < 100 then
		Dialog:Say(string.format("<color=yellow>Xin lỗi, đẳng cấp còn quá thấp.<color><enter>%s", Newland.CONDITION_JOIN_NEWLAMD));
		return 0;
	end
	
	-- 门派限制
	if me.nFaction <= 0 then
		Dialog:Say(string.format("<color=yellow>Xin lỗi, ngươi chưa gia nhập môn phái.<color><enter>%s", Newland.CONDITION_JOIN_NEWLAMD));
		return 0;
	end
	
	-- 判断披风(混天)
	local pItem = me.GetItem(Item.ROOM_EQUIP, Item.EQUIPPOS_MANTLE, 0);
	if not pItem or pItem.nLevel < Newland.MANTLE_LEVEL then
		Dialog:Say(string.format("<color=yellow>Nguy hiểm, hãy trang bị phi phong thích hợp đã, ngươi vội quá rồi!<color><enter>%s", Newland.CONDITION_JOIN_NEWLAMD));
		return 0;
	end
	
	-- 判断帮会
	local pTong = KTong.GetTong(me.dwTongId);
	if not pTong then
		Dialog:Say(string.format("<color=yellow>Nguy hiểm, ngươi vẫn chưa có Bang hội, ngươi vội quá rồi!<color><enter>%s", Newland.CONDITION_JOIN_NEWLAMD));
		return 0;
	end
	
	-- 记录帮会名字
	Newland:SetTongName();
	
	-- 传送到跨服服务器(里面已经做了一些判断)
	Transfer:NewWorld2GlobalMap(me);
end

-- 查询跨服绑银
function tbNpc:QueryGlobalMoney()
	local nMoney = KGCPlayer.OptGetTask(me.nId, KGCPlayer.TSK_CURRENCY_MONEY);
	local szMsg = "";
	if nMoney >= 0 then
		szMsg = string.format("Bạc khóa liên server hiện tại: <color=gold>%s<color>. \nĐây là loại bạc khóa chuyên dụng trong liên server và để mua phần thưởng sau trận chiến. Nếu không có, hãy ấn <color=yellow>Ctrl + G<color>, đến khu Hỗ trợ mua và sử dụng.", nMoney);
	else
		szMsg = "Không thể tra cứu.";
	end
	Dialog:Say(szMsg, {"Trở lại trang trước", self.OnDialog, self});
end

-- 城战奖励相关
function tbNpc:ShowAllAward()
	local tbOpt =
	{
		{"Nhận phần thưởng cá nhân", self.GetSingleAward, self},
		{"Nhận phần thưởng Uy danh", self.GetExtraAward, self},
		{"<color=yellow>Có gì trong rương?<color>", self.AboutAwardXiang, self},
		{"Ta hiểu rồi"},
	};
	
	if Newland:CheckCastleOwner(me.szName) ~= 1 then
		table.insert(tbOpt, 1, {"<color=gray>Mua phần thưởng Thành chủ<color>", self.BuyCastleBox, self});
		table.insert(tbOpt, 1, {"<color=gray>Nhận phần thưởng Thành chủ<color>", self.GetCastleAward, self});	
	else
		table.insert(tbOpt, 1, {"<color=yellow>Mua phần thưởng Thành chủ<color>", self.BuyCastleBox, self});
		table.insert(tbOpt, 1, {"<color=yellow>Nhận phần thưởng Thành chủ<color>", self.GetCastleAward, self});
	end
	
	Dialog:Say("Tại đây có thể nhận thưởng, uy danh, kinh nghiệm và mua rương chiến công.", tbOpt);
end

-- 领取城主奖励
function tbNpc:GetCastleAward()
	
	local nCastleBox = Newland:CheckCastleAward(me);
	if nCastleBox <= 0 then
		return 0;
	end
	
	local szMsg = string.format("Chúc mừng! Bang hội đạt thành tích xuất sắc. Có thể nhận nhiều phần thưởng phong phú!");
	local tbOpt = 
	{
		{"Xác nhận lãnh", Newland.GetCastleAward_GS, Newland, me.szName},
		{"Để ta suy nghĩ thêm"},
	};
	Dialog:Say(szMsg, tbOpt);
end

-- 购买城主宝箱
function tbNpc:BuyCastleBox()

	local nSellBox = Newland:CheckSellBox(me);
	if nSellBox <= 0 then
		return 0;
	end
	
	local szMsg = string.format("Ngươi có thể mua <color=yellow>%s Rương Chiến Công Huy Hoàng<color>!<enter><enter>Mỗi rương giá <color=yellow>%s bạc<color> liên server, ngươi muốn mua bao nhiêu?", nSellBox, Item:FormatMoney(Newland.CASTLE_BOX_PRICE));
	local tbOpt = 
	{
		{"Ta muốn mua nó", self.OnBuyCastleBox, self, nSellBox},
		{"Để ta suy nghĩ thêm"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnBuyCastleBox(nSellBox)
	Dialog:AskNumber("Hãy nhập số lượng:", nSellBox, Newland.BuyCastleBox_GS, Newland);
end

-- 领取积分奖励
function tbNpc:GetSingleAward()
	
	local nSingleBox, nPoint = Newland:CheckSingleAward(me);
	if nSingleBox <= 0 then
		return 0;
	end
	
	local szMsg = string.format("Điểm tích lũy của bạn là <color=yellow>%s<color>, có thể mua <color=yellow>%s rương phần thưởng<color>!<enter><enter>Mỗi rương giá <color=yellow>%s bạc<color>liên server, ngươi muốn mua bao nhiêu?", nPoint, nSingleBox, Item:FormatMoney(Newland.NORMAL_BOX_PRICE));
	local tbOpt = 
	{
		{"Ta muốn mua nó", self.OnGetSingleAward, self, nSingleBox},
		{"Để ta suy nghĩ thêm"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnGetSingleAward(nSingleBox)
	Dialog:AskNumber("Hãy nhập số lượng:", nSingleBox, Newland.GetSingleAward_GS, Newland);
end

function tbNpc:AboutAwardXiang()
	local szMsg = [[
Phần thưởng bao gồm:
Rương Chiến Công Trác Việt: 
	1、	<color=yellow>Mảnh Bích Huyết Chiến Y, Bích Huyết Chi Nhẫn, Bích Huyết Hộ Thân Phù<color>
	2、	<color=yellow>Mảnh Kim Lân Chiến Y, Kim Lân Chi Nhẫn, Kim Lân Hộ Thân Phù<color>
	3、	Huyền tinh cấp 7(khóa)
	4、	Huyền tinh cấp 8(khóa)
	5、	Huyền tinh cấp 9(khóa)

Rương Chiến Công Huy Hoàng mở ra: 
	1、	<color=yellow>Mảnh Bích Huyết Hộ Thân Phù<color>
	2、	<color=yellow>Mảnh Kim Lân Chiến Y, Kim Lân Chi Nhẫn, Kim Lân Hộ Thân Phù<color>
	3、	<color=yellow>Mảnh Đơn Tâm Chiến Y, Đơn Tâm Chi Nhẫn, Đơn Tâm Hộ Thân Phù<color>

	]]
	local tbOpt = 
	{
		{"Quay lại", self.ShowAllAward, self},
		{"Ta hiểu rồi"},
	};
	Dialog:Say(szMsg, tbOpt);
end

-- 领取经验威望
function tbNpc:GetExtraAward()

	local nTimes = Newland:CheckExtraAward(me); 
	if nTimes <= 0 then
		return 0;
	end
	
	local szMsg = string.format("Chúc mừng! Bạn có thể nhận được <color=yellow>%s kinh nghiệm<color> và <color=yellow>%s uy danh<color>!", Newland.PLAYER_WAR_EXP * nTimes, Newland.PLAYER_WAR_REPUTE * nTimes);
	local tbOpt = 
	{
		{"Xác nhận", Newland.GetExtraAward_GS, Newland},
		{"Để ta suy nghĩ thêm"},
	};
	Dialog:Say(szMsg, tbOpt);
end

-- 查询历届城主
function tbNpc:QueryCastleHistory(nFrom)
	
	local tbHistory = Newland.tbCastleBuffer.tbHistory;
	if not tbHistory then
		Dialog:Say("Không thể kiểm tra.");
		return 0;
	end
	
	local nMaxSession = 0;
	for nIndex, _ in pairs (tbHistory) do
		nMaxSession = math.max(nMaxSession, nIndex);
	end

	local tbOpt = {{"Ta hiểu rồi"}};
	local szMsg = "\nDanh sách bao gồm: \n\n";
	local nCount = 8;
	local nLast = nFrom or nMaxSession;
	while nCount > 0 and nLast > 0 do
		if tbHistory[nLast] then
			local szSession = (nLast <= 10) and string.format("%s", Lib:Transfer4LenDigit2CnNum(nLast)) or string.format("%s", Lib:Transfer4LenDigit2CnNum(nLast));
			szMsg = szMsg .. string.format("<color=green>%s: <color=yellow>%s%s<color>\n", Lib:StrFillC(szSession, 8), Lib:StrFillC(tbHistory[nLast].szCaptainName, 17), Lib:StrFillC(ServerEvent:GetServerNameByGateway(tbHistory[nLast].szGateway), 8));
			nCount = nCount - 1;
		end
		nLast = nLast - 1;
	end
	if nCount == 0 and nLast > 0 then
		table.insert(tbOpt, 1, {"Trang sau", self.QueryCastleHistory, self, nLast});
	end
	
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:QueryCastleOldHistory(szZone, nFrom)
	local tbCastleHistoryBuffer = Newland.tbCastleHistoryBuffer;
	if (not tbCastleHistoryBuffer) then
		Dialog:Say("Không thể tra cứu. ");
		return 0;
	end

	local tbHistory = tbCastleHistoryBuffer[szZone];
	if not tbHistory then
		Dialog:Say("Không thể tra cứu. ");
		return 0;
	end
	
	local szZoneName = Newland.tbZoneId2Name[szZone];
	
	if (not szZoneName) then
		szZoneName = "Không rõ";
	end
	
	local nMaxSession = 0;
	for nIndex, _ in pairs (tbHistory) do
		nMaxSession = math.max(nMaxSession, nIndex);
	end

	local tbOpt = {{"Ta hiểu rồi"}};
	local szMsg = string.format("\n%sDanh sách bao gồm: \n\n", szZoneName);
	local nCount = 8;
	local nLast = nFrom or nMaxSession;
	while nCount > 0 and nLast > 0 do
		if tbHistory[nLast] then
			local szSession = (nLast <= 10) and string.format("%s", Lib:Transfer4LenDigit2CnNum(nLast)) or string.format("%s", Lib:Transfer4LenDigit2CnNum(nLast));
			szMsg = szMsg .. string.format("<color=green>%s: <color=yellow>%s%s<color>\n", Lib:StrFillC(szSession, 8), Lib:StrFillC(tbHistory[nLast].szCaptainName, 17), Lib:StrFillC(ServerEvent:GetServerNameByGateway(tbHistory[nLast].szGateway), 8));
			nCount = nCount - 1;
		end
		nLast = nLast - 1;
	end
	if nCount == 0 and nLast > 0 then
		table.insert(tbOpt, 1, {"Trang sau", self.QueryCastleOldHistory, self, szZone, nLast});
	end
	
	Dialog:Say(szMsg, tbOpt);
end

-------------------------------------------------------
-- 兑换同伴装备
-------------------------------------------------------

-- 装备碎片与同伴装备的兑换关系
tbNpc.tbExchangeInfo = 
{	
	[941] = {5, 19, 1, 1},
	[942] = {5, 19, 1, 2},
	[943] = {5, 19, 1, 3},
	[944] = {5, 20, 1, 1},
	[945] = {5, 20, 1, 2},
	[946] = {5, 20, 1, 3},
	[947] = {5, 23, 1, 1},
	[948] = {5, 23, 1, 2},
	[949] = {5, 23, 1, 3},
	[1237] = {5, 22, 1, 1},
	[1238] = {5, 22, 1, 2},
	[1239] = {5, 22, 1, 3},
	[1240] = {5, 21, 1, 1},
	[1241] = {5, 21, 1, 2},
	[1242] = {5, 21, 1, 3},
};

function tbNpc:ExchageEquip()
	local szMsg = "Tại đây có thể đổi trang bị đồng hành. Ngươi muốn gì ở ta?";
	local tbOpt =
	{
		{"Đổi trang bị đồng hành", self.ExchangePartnerEq, self},
		{"Kết tinh đổi trang bị đồng hành", self.ExchangeJade, self},
		{"Để ta suy nghĩ thêm"},
	};
	Dialog:Say(szMsg, tbOpt);
end

-- 第一步选取要换取的装备等级
-- 第二步放入对应类型对应数量的装备碎片
-- 第三步对放入的碎片类型和数量进行匹配判断
-- 第四步删除要兑换的碎片并添加对应的同伴装备
function tbNpc:ExchangePartnerEq(nStep, nLevel, tbItemObj, tbAddItemInfo)
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang bị khóa, không thể thao tác!");
		return 0;
	end
	nStep = nStep or 1;
	nLevel = nLevel or 0;
	
	local tbLevelInfo = 
	{
		[1] = "Bích Huyết",
		[2] = "Kim Lân",
		[3] = "Đơn Tâm",
	};
	
	local szLevel = tbLevelInfo[nLevel] or "";
	local szMsg, tbOpt = "", {};
	
	if nStep == 1 then
		szMsg = "Tham gia Lâu Lan Cổ Thành có cơ hội nhận được mảnh trang bị khác nhau, ngươi muốn đổi trang bị nào?"
		tbOpt = 
		{
			{"Trang bị Bích Huyết (cấp 1)", self.ExchangePartnerEq, self, 2, 1},	
			{"Trang bị Kim Lân (cấp 2)",	self.ExchangePartnerEq, self, 2, 2},
			{"Trang bị Đơn Tâm (cấp 3)", self.ExchangePartnerEq, self, 2, 3},
			{"Ta chỉ xem qua thôi"},
		};
		Dialog:Say(szMsg, tbOpt);
		
	elseif nStep == 2 then
		
		if nLevel < 1 or nLevel > 3 then
			return;
		end
		
		szMsg = "Tham gia Lâu Lan Cổ Thành có cơ hội nhận được mảnh trang bị khác nhau, ";
		szMsg = szMsg .. string.format("<color=green> ngươi có thể đổi %s Chi Nhẫn, %s Chiến Y, %s Hộ Uyển, %s Giới Chỉ, %s Hộ Thân Phù. ", szLevel, szLevel, szLevel, szLevel, szLevel);
		szMsg = szMsg .. "<color>Mỗi trang bị yêu cầu <color=red>50 mảnh vở tương ứng<color>.";
		Dialog:OpenGift(szMsg, nil, {self.ExchangePartnerEq, self, 3, nLevel});	
		
	elseif nStep == 3 then
		szMsg, tbOpt = self:GetPartnerEquipExchangeInfo(tbItemObj, nLevel);
		Dialog:Say(szMsg, tbOpt);
		
	elseif nStep == 4 then
		
		local nToDelCount = 50;
		local szSuiPianName = "";
		local nBind = 0;
		
		for i, tbItem in pairs(tbItemObj) do
			
			local pItem = tbItem[1];
			if pItem.IsBind() == 1 then
				nBind = 1;
			end
				
			if szSuiPianName == "" then
				szSuiPianName = pItem.szName;
			end
			
			if (pItem.nCount > nToDelCount) then
				if (pItem.SetCount(pItem.nCount - nToDelCount, Item.emITEM_DATARECORD_REMOVE) == 1) then
					nToDelCount = 0;
				end
			else
				local nCount = pItem.nCount;
				if (me.DelItem(tbItem[1], Player.emKLOSEITEM_EXCHANGE_PARTEQ) == 1) then
					nToDelCount = nToDelCount - nCount;
				end
			end
			
			if nToDelCount <= 0 then
				break;
			end
		end	
		
		if nToDelCount <= 0 then
			local szItemName = KItem.GetNameById(unpack(tbAddItemInfo));
			local pAddItem = me.AddItem(unpack(tbAddItemInfo));
			if pAddItem then
				if nBind == 1 then
					pAddItem.Bind(1);
					pAddItem.Sync();
				end
				me.Msg(string.format("Chúc mừng! Bạn nhận được 1 %s!", szItemName));
				Dbg:WriteLog("Newland", "跨服城战", me.szAccount, me.szName, string.format("兑换同伴装备: %s", szItemName));
				StatLog:WriteStatLog("stat_info", "partnerequip", "compound", me.nId, me.GetHonorLevel(), szItemName, 1);
			else
				Dbg:WriteLog("Newland", "跨服城战", me.szAccount, me.szName, string.format("兑换同伴装备失败: %s", szItemName));		
			end
			
		elseif nToDelCount < 50 then
			Dbg:WriteLog(string.format("玩家%s用碎片兑换同伴装备失败, 扣除了%s%d个！", me.szName, szSuiPianName, 50 - nToDelCount));
		end
	end	
end

-- 获得碎片与装备之间的兑换关系
function tbNpc:GetPartnerEquipExchangeInfo(tbItemObj, nLevel)
	
	local nCount = 0;
	local nParticular = 0;
	local szMsg, tbOpt = "", {};
	
	for i, tbItem in pairs(tbItemObj) do
		
		local pItem = tbItem[1];
		
		if not self.tbExchangeInfo[pItem.nParticular] or self.tbExchangeInfo[pItem.nParticular][4] ~= nLevel then
			szMsg = "<color=red>Vật phẩm không đúng<color>, mỗi trang bị cần 50 mảnh trang bị tương ứng.";
			break;
			
		elseif nParticular ~= pItem.nParticular then
			if nParticular == 0 then
				nParticular = pItem.nParticular;
			else
				szMsg = "Mỗi chỉ có thể đổi 1 trang bị đồng hành!";
				break;
			end
		end
		
		nCount = nCount + pItem.nCount;
	end

	if nCount < 50 and szMsg == "" then
		szMsg = "<color=red>Số lượng không đạt yêu cầu<color>, mỗi trang bị cần 50 mảnh trang bị tương ứng.";
	end

	if szMsg == "" then
		szMsg = string.format("Bạn chắc rằng dùng 50 %s đổi lấy<color=red>%s<color>", 
			KItem.GetNameById(18, 1, nParticular, 1), 
			KItem.GetNameById(unpack(self.tbExchangeInfo[nParticular]))
		);
		tbOpt = 
		{
			{"Ta đồng ý", self.ExchangePartnerEq, self, 4, nLevel, tbItemObj, self.tbExchangeInfo[nParticular]},
			{"Để ta suy nghĩ thêm"},
		};
	end
	
	return szMsg, tbOpt;
end

tbNpc.tbJadeList = 
{
	[1] = {"Bích Huyết Chi Nhẫn", {5, 19, 1, 1}, 150},
	[2] = {"Bích Huyết Chiến Y", {5, 20, 1, 1}, 100},
	[3] = {"Bích Huyết Hộ Thân Phù", {5, 23, 1, 1}, 1000},
};

function tbNpc:ExchangeJade()
	local szMsg = "Ngươi muốn đổi trang bị đồng hành nào?";
	local tbOpt = {};
	for i, tbInfo in ipairs(self.tbJadeList) do
		table.insert(tbOpt, {tbInfo[1], self.DoExchangeJade, self, i});
	end
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ thêm"};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:DoExchangeJade(nType, nSure)
	if not nType or not self.tbJadeList[nType] then
		return 0;
	end
	local tbInfo = self.tbJadeList[nType];
	if not nSure then
		local szMsg = string.format("Để đổi <color=yellow>%s<color>, cần tiêu hao <color=yellow>%s<color> mảnh trang bị tương ứng.", tbInfo[1], tbInfo[3]);
		local tbOpt =
		{
			{"<color=yellow>Đồng ý<color>", self.DoExchangeJade, self, nType, 1},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	local nFind = me.GetItemCountInBags(unpack(Newland.JADE_ID));
	if nFind < tbInfo[3] then
		Dialog:Say(string.format("Mảnh trang bị trên người không đủ <color=yellow>%s<color>, không thể đổi <color=yellow>%s<color>", tbInfo[3], tbInfo[1]));
		return 0;
	end
	local nNeedSpace = 1
	if me.CountFreeBagCell() < nNeedSpace then
		Dialog:Say(string.format("Hành trang không đủ <color=yellow>%s<color> chỗ trống. ", nNeedSpace));
		return 0;
	end
	local nRet = me.ConsumeItemInBags2(tbInfo[3], 18, 1, 1491, 1);
	if nRet ~= 0 then
		Dbg:WriteLog("Newland", "跨服城战", me.szAccount, me.szName, string.format("扣除%s个结晶失败", tbInfo[3]));
	end
	me.AddItem(unpack(tbInfo[2]));
	Dbg:WriteLog("Newland", "跨服城战", me.szAccount, me.szName, string.format("兑换同伴装备: %s", tbInfo[1]));
end

function tbNpc:SplitAtom()
	Dialog:OpenGift("Hãy đặt Mảnh trang bị đồng hành\n<color=yellow>(Chỉ có Bích Huyết Chiến Y, Bích Huyết Chi Nhẫn, Bích Huyết Hộ Thân Phù có thể tinh chế)<color>", nil, {self.DoSplitAtom, self});
end

function tbNpc:DoSplitAtom(tbItem, nSure)
	
	local tbList =
	{
		[1] = {"Mảnh Bích Huyết Chi Nhẫn", {18, 1, 941, 1}, 3},
		[2] = {"Mảnh Bích Huyết Giới Chỉ", {18, 1, 944, 1}, 2},
		[3] = {"Mảnh Bích Huyết Hộ Thân Phù", {18, 1, 947, 1}, 20},
	};

	local nBind = 0;
	local nValue = 0;
	for _, tbTmpItem in pairs(tbItem) do
		local pItem = tbTmpItem[1];
		local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
		for _, tbInfo in pairs(tbList) do
			if szKey == string.format("%s,%s,%s,%s", unpack(tbInfo[2])) then
				nValue = nValue + tbInfo[3] * pItem.nCount;
				nBind = pItem.IsBind() or 0;
			end
		end
	end
	
	if nValue <= 0 then
		Dialog:Say("Hãy đặt chính xác mảnh trang bị đồng hành. ");
		return 0;
	end

	local nNeed = KItem.GetNeedFreeBag(Newland.JADE_ID[1], Newland.JADE_ID[2], Newland.JADE_ID[3], Newland.JADE_ID[4], {bForceBind = nBind}, nValue);
	if me.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("Hành trang không đủ %s ô trống.", nNeed));
		return 0;
	end
	
	if me.nCashMoney < nValue * 10000 then
		Dialog:Say(string.format("Bạc thường mang theo không đủ: %s. ", nValue * 10000));
		return 0;
	end
	
	if not nSure then
		local szMsg = string.format("Ngươi muốn tinh chế <color=yellow>%s<color>?Lần tinh chế này sẽ tiêu hao <color=yellow>%s<color> lượng bạc", nValue, nValue * 10000);
		local tbOpt =
		{
			{"<color=yellow>Xác nhận<color>", self.DoSplitAtom, self, tbItem, 1},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	for _, tbTmpItem in pairs(tbItem) do
		local pItem = tbTmpItem[1];
		local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
		for _, tbInfo in pairs(tbList) do
			if szKey == string.format("%s,%s,%s,%s", unpack(tbInfo[2])) then
				if me.DelItem(pItem) ~= 1 then
					Dbg:WriteLog("Newland", "跨服城战", me.szAccount, me.szName, string.format("扣除同伴碎片失败: %s", pItem.szName));
					return 0;
				end
			end
		end
	end
	me.AddStackItem(Newland.JADE_ID[1], Newland.JADE_ID[2], Newland.JADE_ID[3], Newland.JADE_ID[4], nil, nValue);
	me.CostMoney(nValue * 10000, Player.emKEARN_EVENT);
	Dbg:WriteLog("Newland", "跨服城战", me.szAccount, me.szName, string.format("提炼同伴结晶: %s个", nValue));
end

-------------------------------------------------------
-- 跨服城战帮助
-------------------------------------------------------

-- 帮助对话
function tbNpc:WarHelp()
	
	local szMsg = "铁浮城宝座虚位以待, 谁能坐得长久也未为可知……<enter><color=gold>更多请按F12-详细帮助-跨服城战<color>";
	local tbOpt = 
	{
		{"城战简介", self.OnWarHelp, self, 1},
		{"城战时间", self.OnWarHelp, self, 2},
		{"城战报名", self.OnWarHelp, self, 3},
		{"城战流程", self.OnWarHelp, self, 4},
		{"城战积分", self.OnWarHelp, self, 5},
		{"城战奖励", self.OnWarHelp, self, 6},
		{"常见问题", self.OnWarHelp, self, 7},
		{"Ta hiểu rồi"},
	};
	
	Dialog:Say(szMsg, tbOpt);
end

-- 帮助子类
function tbNpc:OnWarHelp(nIndex)
	
	local szMsg = "";
	
	if nIndex == 1 then
		szMsg = [[
<color=green>【城战简介】<color>

    世人从古图《清明上河图》中, 发现了一座藏宝甚丰的古城, 这座城池名叫“<color=yellow>铁浮城<color>”. 一时间, 江湖风云突变, 英雄骤起, 都只为这传说中的<color=yellow>铁浮城王座<color>而来……
    
    铁浮城争夺战已经拉开帷幕, <color=yellow>全区<color>的各路英雄豪杰们, 请不要错过良机, 各大主城的<color=yellow>铁浮城远征大将<color>将带您揭开跨服城战之序幕！
    
    <color=green>相关NPC: <color><color=yellow>铁浮城远征大将<color>（城市）
    <color=red>注意: <color>开启150等级上限后, 开启跨服城战. 
    
    <color=gold>详情请查阅F12帮助锦囊-详细帮助-跨服城战<color>
]];
	
	elseif nIndex == 2 then
		szMsg = [[
<color=green>【城战时间】<color>

    <color=yellow>报名: <color>周四00:00--周六19:29
    <color=yellow>准备: <color>周六19:30--周六19:59
    <color=yellow>战斗: <color>周六20:00--周六21:29
    <color=yellow>领奖: <color>周六21:30--下周三23:59

<color=gold>详情请查阅F12帮助锦囊-详细帮助-跨服城战<color>
]];
		
	elseif nIndex == 3 then
		szMsg = string.format([[
<color=green>【城战报名】<color>

    1、拥有超过30名装备有<color=yellow>%s<color>或%s以上披风的任意玩家的帮会, 由帮会首领前往<color=yellow>铁浮城远征大将<color>处选择“帮会申请”, 即为帮会报名. 
    
    2、在报名期间内, 该帮会必须有<color=yellow>30名以上<color>装备有<color=yellow>%s<color>或者更高等级披风、且等级大于100并加入门派的玩家前来登记, 才可使帮会获得参战资格. 过期若人数不满30, 则报名无效. 
    
    3、参战帮会上限为<color=yellow>45个<color>, 若符合条件帮会超过45个, 则之后报名无效. 若报名成功帮会少于<color=yellow>4个<color>, 则无法开启跨服城战. 
    
    4、获得参战资格帮会的帮众, 等级大于100且加入门派并装备有%s或%s以上披风即可动身前往铁浮城参战. 

<color=gold>详情请查阅F12帮助锦囊-详细帮助-跨服城战<color>
]], Newland.MIN_MANTLE_LEVEL_NAME, Newland.MIN_MANTLE_LEVEL_NAME, Newland.MIN_MANTLE_LEVEL_NAME, Newland.MIN_MANTLE_LEVEL_NAME, Newland.MIN_MANTLE_LEVEL_NAME);
	
	elseif nIndex == 4 then
		szMsg = [[
<color=green>【准备期】<color>
    1、准备期可从各大主城的<color=yellow>铁浮城远征大将<color>处进入<color=yellow>英雄岛<color>, 并从英雄岛的<color=yellow>铁浮城传送人<color>处进入<color=yellow>铁浮城外围<color>等待. 
    2、30分钟准备期内, 可以布置战局、用跨服绑银购买药品等. 

<color=green>【城战期】<color>
    <color=yellow>1、外围争夺战<color>
    20:00城战打响, 各帮会进入外围地图. 需要注意的是, 依据参战帮会数量, 每张外围地图只会容纳最多3个帮会, 所有的帮会会在<color=yellow>不同的外围地图<color>争夺外围资源. 只有在外围地图攻占<color=yellow>三根（包括三）以上龙柱（每张地图共五根）<color>, 该帮会成员才<color=yellow>有资格进入内城（进入不限制披风等级）<color>. 

    <color=yellow>2、内城争夺战<color>
    进入内城后, 同样有五根龙柱资源供大家争夺, 只有某帮会占据其中三根或以上, 该帮会成员才具有进入王座的资格. 

    <color=yellow>3、王座争夺战<color>
    所有帮会将会在同一张地图上争夺王座, <color=yellow>占领王座需要读条<color>. 王座地图内同样有四根龙柱资源供大家争夺. 
]];
		
	elseif nIndex == 5 then
		szMsg = [[
    <color=green>如何获得个人积分？<color>
    1、击败敌对玩家可获得个人积分. 
    2、每次占领龙柱会一次性获得一定数量的个人积分. 
    3、守护在本帮已经夺取的龙柱周围、或者占领王座每隔一段时间也会获得一定的个人积分. 

    <color=green>如何获得帮会积分？<color>
    每次占领龙柱或者王座, 根据占领的时间, 会增加帮会的帮会积分. 

    <color=green>积分有何用途？<color>
    1、21:30跨服城战结束, 届时<color=yellow>帮会积分最多<color>的帮会获得本次城战胜利, 该帮帮会首领成为本周<color=yellow>铁浮城主<color>. 
    2、依据个人积分以及帮会积分排名, <color=yellow>个人积分达到500<color>的玩家城战结束后会获得一定量的<color=yellow>铁浮城荣誉<color>. 依据荣誉点数的多少, 可在各服<color=yellow>铁浮城远征大将<color>处以<color=yellow>每个5万跨服绑银<color>的价格购买一定数量的<color=yellow>卓越战功箱<color>. 
]];
		
	elseif nIndex == 6 then
		szMsg = [[
<color=green>【城主专属奖励】<color>
    称号: <color=yellow>铁浮城主·傲世凌天<color>
    购买以下物品的特权: <color=yellow>凌天披风、凌天神驹<color>

<color=green>【城主雕像】<color>
    跨服城战结束后, 自动为城主在凤翔府竖立雄伟雕像. 
    
<color=green>【城主勇士奖励】<color>
    称号: <color=gold>铁浮勇士·群雄逐日<color>
    购买以下物品的特权: <color=gold>逐日披风、逐日神驹<color>
    
<color=green>【辉煌战功箱】<color>
    辉煌战功箱（不绑定）由城主在我这里领取、购买, 自行分配. 
    打开辉煌战功箱有机会获得<color=yellow>1~3级同伴装备碎片<color>！
    
<color=green>【卓越战功箱】<color>
    依据铁浮城荣誉点, 可在我这里购买卓越战功箱. 
    打开卓越战功箱有机会获得<color=yellow>1~2级同伴装备碎片<color>、7级以上高级玄晶！
    
<color=green>【同伴装备】<color>
    打开战功箱有机会获得<color=yellow>同伴装备碎片<color>！集齐50个同种碎片, 即可在我这里换取一件完整的同伴装备. 
    
<color=green>【经验和威望】<color>
    个人积分大于500的侠士在城战结束后在我这里领取500万经验的奖励和50点威望奖励. 
]];		
	elseif nIndex == 7 then
		szMsg = [[
    <color=green>问: 如何查看详细战况？<color>
    答: 按<color=yellow> ~ <color>键. 

    <color=green>问: 为何我无法完成城主和侍卫任务？<color>
    答: 完成任务需要缴纳一定物品. 
    城主任务: <color=yellow>10和氏璧、299月影之石<color>
    侍卫任务: <color=yellow>3和氏璧、99月影之石<color>. 
    
    <color=gold>更多问题请查阅F12帮助锦囊-详细帮助-跨服城战<color>
]];	
	end
	
	Dialog:Say(szMsg, {"返回上一层", self.WarHelp, self});
end
