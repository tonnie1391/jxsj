
SpecialEvent.BuyOver = {}
local BuyOver = SpecialEvent.BuyOver;

BuyOver.TASK_GROUP_ID 		= 2204;
BuyOver.TASK_CHUCPHUC 		= 1;
BuyOver.TASK_BAOVANDONG 	= 2;
BuyOver.TASK_TRUYNA 		= 3;
BuyOver.TASK_TANGBAODO 		= 4;
BuyOver.TASK_VOLAMCAOTHU 	= 5;
BuyOver.TASK_LAULAN 		= 6; -- chưa
BuyOver.TASK_QUANDOANH 		= 7;
BuyOver.TASK_TIEUDAOCOC 	= 8;
BuyOver.TASK_TONGKIM 		= 9;
BuyOver.TASK_BACHHODUONG 	= 10;
BuyOver.TASK_COGIATOC 		= 11;
BuyOver.TASK_TRONGCAY 		= 12;
BuyOver.TASK_THIDAUGIATOC 	= 13;
BuyOver.TASK_CAUCA 			= 14;

BuyOver.tbEvent = {
	-- Hoạt động				Thời gian mở	Giá		Cấp độ	
	{"Chúc Phúc", 				-1, 			5000,	50,		{"repute"},				{{5, 4, 1}},	" ♦ 1 điểm danh vọng Chúc Phúc"},																		-- 	1 điểm DV			
	{"Bao Vạn Đồng", 			-1, 			30000,	20,		{"item", "item"},		{{18, 1, 84, 1, {bForceBind = 1}, 1}, {18, 1, 9, 3, {bForceBind = 1}, 1}},	" ♦ 1 Lệnh bài danh vọng\n ♦ 1 Tàng bảo đồ kho báu"}, 	--	1 lb, 1 tbd
	{"Truy Nã Hải Tặc", 		-1, 			50000,	50,		{"item", "limit"},		{{18, 1, 190, 1, {bForceBind = 1}, 3}, {Wanted.TASK_GROUP, Wanted.TASK_COUNT, Wanted.LIMIT_COUNT_MAX}}, " ♦ 3 Danh Bổ Lệnh"},											--	3 dbl		
	{"Tàng Bảo Đồ", 			-1, 			30000,	20,		{"item"},				{{18, 1, 114, 5, {bForceBind = 1}, 3}}, " ♦ 3 Huyền Tinh cấp 5"},											--	3 huyền tinh 5
	{"Võ Lâm Cao Thủ", 			-1, 			100000,	50,		{"bindmoney", "item"},	{50000, {18, 1, 114, 6, {bForceBind = 1}, 2}}, " ♦ 5 vạn bạc khóa\n ♦ 2 Huyền tinh cấp 6"},									--	2 Huyền tinh 6 + 5v bạc khóa			
	{"Lâu Lan", 				-1, 			150000,	100,	{"bindmoney"},			{1000000}, " ♦ 100 vạn bạc khóa"},																		--	100v bạc khóa
	{"Quân Doanh", 				-1, 			50000,	80,		{"exp", "repute"},		{120, {1, 2, 500}}, " ♦ Kinh nghiệm (hệ số 120)\n ♦ 500 điểm danh vọng Quân Doanh"},															--	exp + danh vọng			
	{"Tiêu Dao Cốc", 			-1, 			70000,	30,		{"item", "repute", "limit"},		{{18, 1, 114, 6, {bForceBind = 1}, 2}, {5, 3, 20}, {XoyoGame.TASK_GROUP, XoyoGame.TIMES_ID, XoyoGame.MAX_TIMES}}, " ♦ 2 Huyền Tinh cấp 6\n ♦ 20 danh vọng Tiêu Dao Cốc"}, 							-- 	2ht6 + danh vong
	{"Mông Cổ-Tây Hạ", 			-1, 			30000,	60,		{"exp"},				{200}, " ♦ Kinh nghiệm (hệ số 200)"},																			--	base exp			
	{"Bạch Hổ Đường", 			-1, 			50000,	50,		{"item", "item"},		{{18, 1, 114, 5, {bForceBind = 1}, 3}, {18, 1, 111, 3, {bForceBind = 1}, 3}}, " ♦ 3 Huyền Tinh cấp 5\n ♦ 3 Lệnh bài danh vọng (cao)"},	--	5 huyền tinh 5, 3 lbdv cao
	{"Cắm Cờ Gia Tộc", 			-1, 			20000,	30,		{"exp"},				{100}, " ♦ Kinh nghiệm (hệ số 100)"},																			--	base exp
	{"Trồng Cây Gia Tộc", 		-1, 			20000,	30,		{"exp", "item", "bindmoney"},		{100, {18, 1, 114, 5, {bForceBind = 1}, 1}, 50000}, " ♦ Kinh nghiệm (hệ số 100)\n ♦ 1 Huyền tinh cấp 5\n ♦ 5 vạn bạc khóa"},				--	exp 1ht5 bạc khóa		
	{"Thi Đấu Gia Tộc Thú Vị", 	{0, 1, 3, 5}, 	100000,	30,		{"item"},				{{18, 1, 1732, 1, {bForceBind = 1}, 5}}, " ♦ 5 Mảnh Ngọc Như Ý"},											--	stack 5 mảnh ngọc như ý
	{"Câu Cá Cuối Tuần", 		{0, 6}, 		150000,	30,		{"bindmoney", "item"},	{100000, {18, 1, 114, 7, {bForceBind = 1}, 2}}, " ♦ 10 vạn bạc khóa\n ♦ 2 Huyền tinh cấp 7"},								--	2 huyen tinh 7, 10v bac khoa
}

-- SpecialEvent.BuyOver:AddCounts(me, SpecialEvent.BuyOver.TASK_CHUCPHUC);
function BuyOver:AddCounts(pPlayer, nNum)
	Setting:SetGlobalObj(pPlayer);	
	
	local nAward = me.GetTask(self.TASK_GROUP_ID, nNum);
	local nDate = tonumber(os.date("%d", GetTime()));
	nAward = Lib:SetBits(nAward, 1, nDate, nDate);
	me.SetTask(SpecialEvent.BuyOver.TASK_GROUP_ID, nNum, nAward);
	
	Setting:RestoreGlobalObj();
end

function BuyOver:OnClientCall(nNum, nOffset)
	if me.CountFreeBagCell() < 5 then
		me.Msg("Hành trang không đủ <color=yellow>5 ô<color> trống!")
		return
	end
	
	local bRetDateOpenServer, szMsg = self:CheckDateOpenServer(nNum, nOffset)
	if bRetDateOpenServer == 0 then
		me.Msg(""..szMsg)
		return
	end
	
	local bRetDate, szMsg = self:CheckDate(nNum, nOffset) -- Ngày hoạt động
	if bRetDate == 0 then
		me.Msg(""..szMsg)
		return
	end
	
	local bRetBindCoin, szMsg = self:CheckBindCoin(nNum) -- Bạc thường
	if bRetBindCoin == 0 then
		me.Msg(""..szMsg)
		return
	end
	
	local bRetLevel, szMsg = self:CheckLevel(nNum) -- Cấp độ
	if bRetLevel == 0 then
		me.Msg(""..szMsg)
		return
	end
	
	for j, tb1 in pairs (self.tbEvent[nNum][5]) do
		if tb1 == "limit" then
			local bRetLimit, szMsg = self:CheckLimit(nNum) -- Số lượt
			if bRetLimit == 0 then
				me.Msg(""..szMsg)
				return
			end
		end
	end
	
	for i, tb in pairs (self.tbEvent[nNum][5]) do
		if tb == "repute" then
			me.AddRepute(unpack(self.tbEvent[nNum][6][i]))
			
		elseif tb == "exp" then
			me.AddExp(me.GetBaseAwardExp() * self.tbEvent[nNum][6][i]);
		elseif tb == "bindmoney" then
			me.AddBindMoney(self.tbEvent[nNum][6][i])
		elseif tb == "item" then
			me.AddStackItem(unpack(self.tbEvent[nNum][6][i]))
		end
	end
	
	for k = 1, 10 do
		local nAwardOver = me.GetTask(self.TASK_GROUP_ID, nNum);
		local nDateOver = tonumber(os.date("%d", GetTime() + 3600 * 24 * k));
		nAwardOver = Lib:SetBits(nAwardOver, 0, nDateOver, nDateOver);
		me.SetTask(self.TASK_GROUP_ID, nNum, nAwardOver);
	end
	
	local nAward = me.GetTask(self.TASK_GROUP_ID, nNum);
	local nDate = tonumber(os.date("%d", GetTime() - 3600 * 24 * nOffset));
	nAward = Lib:SetBits(nAward, 1, nDate, nDate);
	me.SetTask(self.TASK_GROUP_ID, nNum, nAward);
	
	me.CostMoney(self.tbEvent[nNum][3], 0);
	
	me.CallClientScript({"Ui:ServerCall", "UI_BUYOVER", "OnShowMailList"});
end

function BuyOver:CheckLimit(nNum) --Số lượt
	for j, tb in pairs (self.tbEvent[nNum][5]) do
		if tb == "limit" then
			if me.GetTask(self.tbEvent[nNum][6][j][1], self.tbEvent[nNum][6][j][2]) < self.tbEvent[nNum][6][j][3] then
				return 0, "Cơ hội tham gia hôm qua đã được tích lũy, không cần phải mua lại hoạt động này."
			end
		end
	end
end

function BuyOver:CheckLevel(nNum) --Cấp độ
	local nLevel = me.nLevel;
	if nLevel < self.tbEvent[nNum][4] then
		return 0, "Cấp độ chưa đạt <color=yellow>"..self.tbEvent[nNum][4].."<color>!"
	end
end

function BuyOver:CheckBindCoin(nNum) --BindCoin
	local nBindCoin = me.nCashMoney;
	if nBindCoin < self.tbEvent[nNum][3] then
		return 0, "Không đủ <color=yellow>"..self.tbEvent[nNum][3].." bạc thường<color>!"
	end
end

function BuyOver:CheckDate(nNum, nOffset) -- Ngày hoạt động
	local nWeekDay	= tonumber(os.date("%w", GetTime()));
	local nLastDay = nWeekDay - 1;
	
	local nAward = me.GetTask(self.TASK_GROUP_ID, nNum)
	local nDate = tonumber(os.date("%d", GetTime() - 3600 * 24 * nOffset));
	local nAwardWay = Lib:LoadBits(nAward, nDate, nDate);			-- 0: Có thể mua; 1: Đã mua; 2: Đã hoàn thành
	
	if nLastDay == -1 then
		nLastDay = 6;
	end
	if self.tbEvent[nNum][2] ~= -1 then
		for _, nDate in pairs (self.tbEvent[nNum][2]) do
			if nLastDay == nDate and nAwardWay == 0 then
				return 1, "Có thể mua: Hoạt động ".. self.tbEvent[nNum][1];
			end
		end
	elseif self.tbEvent[nNum][2] == -1 and nAwardWay == 0  then
		return 1, "Có thể mua: Hoạt động ".. self.tbEvent[nNum][1];
	end
	
	return 0, "Không thể mua hoạt động ".. self.tbEvent[nNum][1];
end

function BuyOver:CheckDateOpenServer(nNum, nOffset)
	local nTimeOpenServer = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	local nOpenDay = math.floor((GetTime() - nTimeOpenServer) / (3600 * 24));
	
	me.Msg(nOpenDay.."-"..nOffset)
	if nOpenDay < nOffset then
		return 0, "Không thể mua hoạt động trước ngày mở máy chủ!";
	end
end
