-- 文件名　：chaotingyushi.lua
-- 创建者　：furuilei
-- 创建时间：2009-06-16 09:50:36

Require("\\script\\domainbattle\\task\\domaintask_def.lua");

local tbChaoTingYuShi = Npc:GetClass("chaotingyushi");
--=======================================================================
tbChaoTingYuShi.tbFollowInsertItem 	= {18, 1, 379, 1};
tbChaoTingYuShi.tbBuChangItem		= {18,1,205,1}; -- 补偿奖励的物品
tbChaoTingYuShi.BUCHANG_ITEM_HUMSHI_COUNT = 4;		-- 补偿物品奖励魂石个数

tbChaoTingYuShi.TASK_GROUP = 2097;
tbChaoTingYuShi.TASK_ID_COUNT = 10;	-- 玩家缴纳的Bá Chủ Chi Ấn数量

tbChaoTingYuShi.TASK_ID_FLAG_GET_BUCHANG_STATUARY = Domain.DomainTask.TASK_ID_FLAG_GET_BUCHANG_STATUARY; -- 玩家获得雕像补偿的时间

tbChaoTingYuShi.tbAward = {
		-- 需要缴纳的Bá Chủ Chi Ấn数量	物品名称		物品ID
		{nCount = 500, szName = "Huyền tinh cấp 10 (khóa)", tbItem = {18, 1, 114, 10}},
		{nCount = 140, szName = "Huyền tinh cấp 9 (khóa)", tbItem = {18, 1, 114, 9}},
		{nCount = 40,  szName = "Huyền tinh cấp 8 (khóa)", tbItem = {18, 1, 114, 8}},
		{nCount = 10,  szName = "Huyền tinh cấp 7 (khóa)", tbItem = {18, 1, 114, 7}},
		{nCount = 3,   szName = "Huyền tinh cấp 6 (khóa)", tbItem = {18, 1, 114, 6}},
		};
--=======================================================================
tbChaoTingYuShi.nCount = {};

tbChaoTingYuShi.BUCHANG_STATUARY_BAZHUZHIYIN_COUNT = Domain.DomainTask.BUCHANG_STATUARY_BAZHUZHIYIN_COUNT;

function tbChaoTingYuShi:OnDialog()
	local tbOpt = {
		{"Giao nộp Bá Chủ Ấn", self.TakeInItem, self},
		{"Xem xếp hạng", self.GetAwardInfo, self},
		{"Nhận thưởng", self.GetAward, self},
		{"Lập tượng", self.BuildStatuary, self, me.szName},
		{"Nhận phần thưởng sùng bái", self.GiveRevereAward, self, me.szName},
	};
	local szMsg = "Ta phụng thánh chỉ, thu thập Bá Chủ Ấn thất lạc khắp nơi.\nNếu ngươi may mắn lấy được, có thể giao cho ta, ta sẽ trình báo với thánh thượng công lao của ngươi, giao càng nhiều, phần thưởng càng cao\nThánh thượng có chỉ: “Chư vị anh hùng thu thập đủ Bá Chủ Ấn, ngoài việc được lên điện sắc phong, còn được tạc tượng để biểu dương công trạng.”";
	local nState = Domain.DomainTask:CheckState();
	if (2 == nState) then
		if (Domain.DomainTask:CheckBuChangState() == 1) then
			table.insert(tbOpt, {"Nhận Bá Chủ Ấn bổ chính", self.OnGiveBuChangJiangli, self, me.szName});
		end

		local tbTemp = {"Đi đến buổi lễ", me.NewWorld, 1541, 1579, 3260};
		table.insert(tbOpt, 2, tbTemp);
		szMsg = "Hoàng thượng trên triều đã tổ chức lễ biểu dương, muốn tham gia buổi lễ mời lên điện.";
	end
	table.insert(tbOpt, {"Ta chỉ đến xem"});
	Dialog:Say(szMsg, tbOpt);
end

function tbChaoTingYuShi:TakeInItem()
	local tbOpt = {
		{"Ta muốn nộp", self.SureTakeInItem, self},
		{"Ta chỉ đến xem"}
	};
	local szMsg = "Nghe nói ngươi đã thu thập không ít Bá Chủ Ấn rồi.\nCó muốn giao cho ta không?";
	Dialog:Say(szMsg, tbOpt);
end

-- 放入物品
function tbChaoTingYuShi:SureTakeInItem()
	local nState = Domain.DomainTask:CheckState();
	if (0 == nState) then
		Dialog:Say("Sự kiện chưa mở.");
		return;
	end
	if (2 == nState) then
		Dialog:Say("Sự kiện đã kết thúc rồi!");
		return;
	end
	if (1 ~= nState) then
		return;
	end
	Dialog:OpenGift("Ta muốn nộp", nil, {self.OnOpenGiftOk, self});
end

-- 获取奖励
function tbChaoTingYuShi:GetAward()
	local szMsg, tbAward = self:GetAwardMsg(me);
	local tbOpt = {
		{"Ta muốn lãnh thưởng", self.SureGetAward, self, tbAward},
		{"Để ta suy nghĩ thêm"}
	};
	Dialog:Say(szMsg, tbOpt);
end

-- 计算玩家能够领取的奖励
function tbChaoTingYuShi:CalcAward(nSum)
	if (nSum < 0) then
		return;
	end
	local tbAwardCount = {};
	local nLevelCount = 0;
	for i, v in ipairs(self.tbAward) do
		if (nSum == 0 or v.nCount == 0) then
			break;
		end
		nLevelCount = math.floor(nSum / v.nCount);
		nSum = nSum % v.nCount;
		if (not tbAwardCount[i]) then
			tbAwardCount[i] = {};
		end
		tbAwardCount[i].nCount = nLevelCount;
		tbAwardCount[i].szName = v.szName;
		tbAwardCount[i].tbItem = v.tbItem;
	end
	return tbAwardCount;
end

function tbChaoTingYuShi:SureGetAward(tbAward)
	local nState = Domain.DomainTask:CheckState();
	if (0 == nState) then
		Dialog:Say("Sự kiện chưa mở.");
		return;
	end
	if (1 == nState) then
		Dialog:Say("Sự kiện chưa kết thúc, hãy đợi kết thúc rồi đến nhận thưởng.");
		return;
	end
	if (2 ~= nState) then
		return;
	end
	local nSum = 0;
	for i, v in ipairs (tbAward) do
		nSum = nSum + v.nCount;
	end
	if (me.CountFreeBagCell() < nSum) then
		Dialog:Say(string.format("Hành trang không đủ <color=yellow>%s ô<color> trống.", nSum));
		return;
	end
	for i, v in ipairs(tbAward) do
		for i = 1, v.nCount do
			me.AddItemEx(v.tbItem[1], v.tbItem[2], v.tbItem[3], v.tbItem[4], nil, Player.emKITEMLOG_TYPE_BAZHUZHIYIN_AWARD);
		end
		Item:CheckXJRecord(Item.emITEM_XJRECORD_EVENT, "Bá Chủ Chi Ấn收集奖励", 
			{v.tbItem[1], v.tbItem[2], v.tbItem[3], v.tbItem[4], 0, v.nCount});
	end
	
	Dbg:WriteLogEx(Dbg.LOG_INFO, "Domain", "chaotingyushi", string.format("%s缴纳了%s Bá Chủ Chi Ấn, 领取奖励", me.szName, me.GetTask(self.TASK_GROUP, self.TASK_ID_COUNT)));
	me.SetTask(self.TASK_GROUP, self.TASK_ID_COUNT, 0);
	PlayerHonor:SetPlayerHonorByName(me.szName, PlayerHonor.HONOR_CLASS_KAIMENTASK, 0, 0);
end

-- 使用排行榜提供的接口来显示玩家排名
function tbChaoTingYuShi:GetAwardInfo()
	local nState = Domain.DomainTask:CheckState();
	if (2 == nState) then
		Dialog:Say("Sự kiện đã kết thúc.");
		return;
	end
	local nPlayerRank = PlayerHonor:GetPlayerHonorRankByName(me.szName, PlayerHonor.HONOR_CLASS_KAIMENTASK, 0);
	local nPlayerCount = me.GetTask(self.TASK_GROUP, self.TASK_ID_COUNT);
	local nTongId = me.dwTongId;
	if (nTongId <= 0) then
		Dialog:Say("Bạn hiện không nằm trong bất kỳ Bang hội nào.");
		return;
	end
	local cTong = KTong.GetTong(nTongId);
	if (not cTong) then
		return;
	end
	local szMsg = "";
	if (nPlayerRank > 0) then
		szMsg = string.format("Bạn nộp Bá Chủ Ấn <color=yellow>%s<color>cái, xếp hạng hiện tại: <color=yellow>%s<color>", nPlayerCount, nPlayerRank);
	else
		szMsg = string.format("Bạn nộp Bá Chủ Ấn <color=yellow>%s<color>cái, nhưng chưa có trong bảng xếp hạng, hãy cố gắng.", nPlayerCount);
	end
	local nTongCount = cTong.GetDomainBaZhu();
	szMsg = szMsg .. string.format("Bang hội đã nộp Bá Chủ Ấn <color=yellow>%s<color> cái.", nTongCount);
	Dialog:Say(szMsg);
end

function tbChaoTingYuShi:Init()
	if (not self.nCount) then
		self.nCount = {};
	end
	self.nCount[me.nId] = 0;
end

-- 点击确认按钮
function tbChaoTingYuShi:OnOpenGiftOk(tbItemObj)
	self:Init();
	local bForbidItem = 0;
	for _, pItem in pairs(tbItemObj) do
		if (self:ChechItem(pItem) == 0) then
			bForbidItem = 1;
		end
	end
	if (bForbidItem == 1) then
		me.Msg("Tồn tại không phù hợp với đồ vật!")
		return 0;
	end
	local nTongId = me.dwTongId;
	if (nTongId <= 0) then
		Dialog:Say("Bạn không thuộc bang hội, không thể giao nộp Bá Chủ Ấn");
		return 0;
	end
	local cTong = KTong.GetTong(nTongId);
	if (not cTong) then
		return 0;
	end
	for _, pItem in pairs(tbItemObj) do
		if me.DelItem(pItem[1], Player.emKLOSEITEM_BAZHUZHIYIN_TAKEIN) ~= 1 then
			return 0;
		end
	end
	self:UpdateCount();
	
	return 1;
end

-- 检测物品是否符合条件
function tbChaoTingYuShi:ChechItem(pItem)
	local bForbidItem = 1;
	local szFollowItem = string.format("%s,%s,%s,%s", unpack(self.tbFollowInsertItem));
	local szItem = string.format("%s,%s,%s,%s",pItem[1].nGenre, pItem[1].nDetail, pItem[1].nParticular, pItem[1].nLevel);
	
	if szFollowItem ~= szItem then
		bForbidItem = 0;
	end
	if (not self.nCount[me.nId]) then
		self.nCount[me.nId] = pItem[1].nCount;
	else
		self.nCount[me.nId] = self.nCount[me.nId] + pItem[1].nCount;
	end
	return bForbidItem;
end

-- 检查玩家是否是缴纳Bá Chủ Chi Ấn最多的玩家
function tbChaoTingYuShi:IsFirst(pPlayer)
	local bFirst = 0;
--	local szName = KGblTask.SCGetDbTaskStr(DBTASK_BAZHUZHIYIN_MAX);
	local nFlag	 = Domain.tbStatuary:CheckStatuaryState(pPlayer.szName, Domain.tbStatuary.TYPE_EVENT_NORMAL);
	if (1 == nFlag) then
		bFirst = 1;
	end
	return bFirst;
end

-- 更新玩家和帮会缴纳的Bá Chủ Chi Ấn的数量
function tbChaoTingYuShi:UpdateCount()
	local nTongId = me.dwTongId;
	if (nTongId <= 0) then
		return 0;
	end
	local cTong = KTong.GetTong(nTongId);
	if (not cTong) then
		return 0;
	end
	if (not self.nCount[me.nId] or self.nCount[me.nId] <= 0) then
		return 0;
	end
	local nCurCount = me.GetTask(self.TASK_GROUP, self.TASK_ID_COUNT);
	return GCExcute{"Domain:UpdateBaZhuZhiYin_GC", me.szName, nTongId, nCurCount, self.nCount[me.nId]};
end

-- 获取玩家的奖励情况
function tbChaoTingYuShi:GetAwardMsg(pPlayer)
	if (not pPlayer) then
		return;
	end
	local nPlayerCount = pPlayer.GetTask(self.TASK_GROUP, self.TASK_ID_COUNT);
	local tbAward = self:CalcAward(nPlayerCount);
	if (not tbAward) then
		return;
	end
	local szMsg = string.format("Bạn trước mắt đã giao nộp được Bá Chủ Ấn<color=yellow>%s<color>cái, có thể nhận thưởng được những giải thưởng sau\n", nPlayerCount);
	for i, v in ipairs(tbAward) do
		if (v.nCount > 0) then
			szMsg = szMsg .. string.format("<color=yellow>%s    %s<color>\n", v.szName, v.nCount);
		end
	end
	szMsg = szMsg .. "<color=red>Lưu ý: Các giải thưởng của game thủ sẽ nhận được sau khi hoạt động kết thúc.<color>"
	return szMsg, tbAward;
end

function tbChaoTingYuShi:GiveRevereAward(szName)
	local tbOpt = {
		{"Tao xác nhận lãnh thưởng", self.SureGiveRevereAward, self, szName},
		{"Để ta suy nghĩ thêm"},
		};
	local nRevere = Domain.tbStatuary:GetRevere(szName, Domain.tbStatuary.TYPE_EVENT_NORMAL);
	local szMsg = string.format("Bạn hiện tại đã đạt đến mức độ tôn kính <color=yellow>%d<color>, bạn chắc chắn muốn nhận giải thưởng mức độ này không?", nRevere);
	Dialog:Say(szMsg, tbOpt);
end

-- get horse
function tbChaoTingYuShi:SureGiveRevereAward(szName)
	-- todo: bag space check
--	local nFlag = Domain.tbStatuary:CheckStatuaryState(szName, Domain.tbStatuary.TYPE_EVENT_NORMAL);
--	if (nFlag ~= 2) then
--		Dialog:Say("你当前还没有树立雕像, 无法领取奖励.");
--		return;
--	end
	
	local nRevere = Domain.tbStatuary:GetRevere(szName, Domain.tbStatuary.TYPE_EVENT_NORMAL);
	if (nRevere < 1500) then
		Dialog:Say("Bức tượng hiện tại của bạn mức độ tích lũy không đủ <color=yellow>1500<color> điểm, không thể nhận phần thưởng.");
		return;
	end
	
	if (me.CountFreeBagCell() < 1) then
		Dialog:Say("Hành trang của bạn không đủ, cần trống 1 ô.");
		return;
	end
	
	Dbg:WriteLogEx(Dbg.LOG_INFO, "Domain", "chaotingyushi", string.format("Award %s a horse", me.szName));
	
	Domain.tbStatuary:DecreaseRevere(szName, Domain.tbStatuary.TYPE_EVENT_NORMAL, 1500);
	local pItem = me.AddItem(1,12,12,4);
	if (not pItem) then
		Dbg:WriteLogEx(Dbg.LOG_INFO, "Domain", "chaotingyushi", string.format("Add %s a horse item failed", me.szName));
	end
	local a,b = pItem.GetTimeOut();
	pItem.Bind(1);		-- 强制绑定
	if b == 0 then
		me.SetItemTimeout(pItem, os.date("%Y/%m/%d/%H/%M/00", GetTime() + 3600 * 24 * 30));
		pItem.Sync();
	end
	local szMsg = "Bức tượng được dựng lên trong thời gian này, thành tích của bạn đã được công nhận bởi các game thủ nói chung, bước đột phá tích lũy 1500 điểm mức độ tôn kính. Thông qua các kiểm tra của Hoàng thượng." ..
					"Giải thưởng ngựa cấp 120 của bạn sẽ khấu trừ 1500 điểm mức độ tôn kính." ..
					"Sau đó, miễn là điểm vinh dự của bạn đạt mức độ tôn kính 1500 điểm, bạn có thể đến cửa hàng mua ngựa cấp 120."
	Dialog:Say(szMsg, {"Đóng lại"});
end

-- 树立雕像
function tbChaoTingYuShi:BuildStatuary(szName)
	if (not szName or me.szName ~= szName) then
		return;
	end
	local nState = Domain.DomainTask:CheckState();
	if (0 == nState) then
		Dialog:Say("Hoạt động này vẫn chưa bắt đầu, không thể thiết lập một bức tượng.");
	end
	if (1 == nState) then
		Dialog:Say("Hoạt động chưa kết thúc, không thể thiết lập một bức tượng.");
	end
	if (2 ~= nState) then
		return;
	end
	local nFlag = Domain.tbStatuary:CheckStatuaryState(me.szName, Domain.tbStatuary.TYPE_EVENT_NORMAL);	
	local szMsg = "";
	if (0 == nFlag) then
		szMsg = "Thành tích hiện tại của bạn không đáp ứng  thiết lập sức mạnh của bức tượng.\nchỉ có thu thập đc nhìu Bá Chủ Ấn mới có tư cách lập tượng.";
		Dialog:Say(szMsg);
		return;
	elseif (nFlag == 2) then
		Dialog:Say("Bạn đã thiết lập  bức tượng, không thể tiếp tục thiết lập");
		return;
	elseif (nFlag == 1) then
		local bFinishTask = me.GetTask(1024, 62);
		if (1 ~= bFinishTask) then
			Dialog:Say("Bạn cần phải hoàn thành<color=yellow>giải thưởng anh hùng<color>Lễ để thiết lập các bức tượng.\n<color=red>từ quan lễ bộ tiến đến, trên triều đình tại điện và đối thoại lễ bộ sách có thể tham gia nghi thức giải thưởng anh hùng.<color>");
			return;
		end
		szMsg = string.format("Thánh thượng đã hạ lệnh：các vi anh hùng, ai thu thập được nhiều Bá Chủ Ấn nhất, sẽ được lên điện nghe phong thưởng và lập tượng ghi danh\
		\nBạn là bá chủ của trận chiến của hoạt động, thánh thượng thu thập được nhiều Bá Chủ Ấn nhất. Thiết lập các trình độ của bức tượng.\
		\nThiết lập một bức tượng, nó mất<color=yellow>10000<color>từng yêu tố của đá ngũ hành.\
		\nBức tượng đã được dựng lên, sẽ nhận được sự thờ phượng công cộng hoặc gạt sang một bên. Để được tôn thờ, nó sẽ làm tăng sự tôn trọng của bức tượng.\
		Nếu sự tôn kính của bức tượng đã đạt<color=yellow>1500<color>Điểm, Đó là thành tích của bạn đã được sự công nhận của mọi người, Sau đó, bạn có thể đến đây để nhận được phần thưởng cuối cùng：Món quà của hoàng đế ban<color=yellow>120Mới được sử dụng<color>.");
	elseif (nFlag == 3) then
		Dialog:Say("Vị trí tượng không đủ，không thể thiết lập bức tượng!");
		return;
	end

	Dialog:Say(szMsg,
		{
			{"Ta muốn thiết lập bức tượng của mình", self.SureBuildStatuary, self},
			{"Để ta suy nghĩ thêm"},
		});
end

function tbChaoTingYuShi:SureBuildStatuary()
	-- 获取玩家的主修门派
	local nFaction = Faction:GetGerneFactionInfo(me)[1];
	if (not nFaction) then
		nFaction = me.nFaction;
	end
	
	if (Player.FACTION_NONE == nFaction) then
		Dialog:Say("Bạn vẫn chưa tham gia môn phái nào，không thể thiết lập một bức tượng.");
		return;
	end
	if (Player.FACTION_NUM < nFaction) then
		return;
	end
	local nStoneCount = me.GetItemCountInBags(18,1,205,1);
	if (nStoneCount < 10000) then
		Dialog:Say("Năm yếu tố cần thiết để thiết lập một bức tượng đá linh hồn!");
		return;
	end
	self:WriteLog("BuildStatuary", string.format("%s use series stone %d success!", me.szName, 10000));
	local nResult = Domain.tbStatuary:AddStatuary(me.szName, Domain.tbStatuary.TYPE_EVENT_NORMAL, nFaction, me.nSex);
	if (0 == nResult) then
		self:WriteLog("BuildStatuary", string.format("%s BuildStatuary Failed!", me.szName));
		return;
	end
	if (1 == me.ConsumeItemInBags2(10000, 18,1,205,1)) then
		self:WriteLog("BuildStatuary", string.format("%s use series stone %d failed!", me.szName, 10000));
		return;
	end
end

function tbChaoTingYuShi:WriteLog(...)
	if (MODULE_GAMESERVER) then
		Dbg:WriteLogEx(Dbg.LOG_INFO, "Domain", "tbChaoTingYuShi", unpack(arg));
	end
end

-- 用于补偿Bá Chủ Chi Ấn活动结束后剩余未交的Bá Chủ Chi Ấn
function tbChaoTingYuShi:OnGiveBuChangJiangli(szPlayerName)
	if (not szPlayerName) then
		return 0;
	end
	
	local nState, szMsg = Domain.DomainTask:CheckBuChangState();
	if (0 == nState) then
		Dialog:Say(szMsg);
		return 0;
	end

	self.CONTEXT_CHANGE_HUNSHI = "1 Bá Chủ Ấn có thể đổi 4 Hồn Thạch"; 
	Dialog:OpenGift(self.CONTEXT_CHANGE_HUNSHI, nil, {self.OnBuChangOpenGiftOk, self});	
end

function tbChaoTingYuShi:OnBuChangOpenGiftOk(tbItemObj)
	local bForbidItem = 0;
	local nBaZhuCount = 0;
	local szFollowItem = string.format("%s,%s,%s,%s", unpack(self.tbFollowInsertItem));

	for _, pItem in pairs(tbItemObj) do
		local szItem = string.format("%s,%s,%s,%s",pItem[1].nGenre, pItem[1].nDetail, pItem[1].nParticular, pItem[1].nLevel);
		if szFollowItem ~= szItem then
			bForbidItem = 1;
			break;
		end
		nBaZhuCount = nBaZhuCount + pItem[1].nCount;
	end
	if (bForbidItem == 1) then
		me.Msg("Tồn tại không đáp ứng vật phẩm!")
		return 0;
	end
	local nTongId = me.dwTongId;
	if (nBaZhuCount <= 0) then
		Dialog:Say("Chưa đóng góp Bá Chủ Ấn.");
		return 0;
	end
	
	local nFreeCount = me.CountFreeBagCell();
	local nHunshi = nBaZhuCount * self.BUCHANG_ITEM_HUMSHI_COUNT;
	local nHunFree = math.ceil(nHunshi / 5000);
	if (nHunFree <= 0) then
		Dialog:Say("Không có đủ Bá Chủ Ấn!");
		return 0;
	end
	
	if (nHunFree > nFreeCount) then
		Dialog:Say(string.format("Hành trang của bạn không đủ，Bạn cần%smở rộng không gian túi.", nHunFree));
		return 0;
	end
	
	if (1 == me.ConsumeItemInBags2(nBaZhuCount,unpack(self.tbFollowInsertItem))) then
		self:WriteLog("OnBuChangOpenGiftOk", me.szName, "give bazhuzhiyin failed!");
		return 0;
	end
	local nGetNum = me.AddStackItem(self.tbBuChangItem[1], self.tbBuChangItem[2], self.tbBuChangItem[3], self.tbBuChangItem[4], {bForceBind = 1}, nHunshi);
	self:WriteLog("OnBuChangOpenGiftOk",  me.szName..",Nên được số lượng đá linh hồn: ", nHunshi, "Số lượng thực tế của đá linh hồn：", nGetNum);
	
	return 1;
end
