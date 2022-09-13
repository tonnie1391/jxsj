-- 文件名　：dayplayerback_item.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-07-02 14:58:12
-- 功能    ：日常回流

SpecialEvent.tbDayPlayerBack = SpecialEvent.tbDayPlayerBack or {};
local tbDayPlayerBack = SpecialEvent.tbDayPlayerBack or {};

local tbItem  = Item:GetClass("zhengzhanjianghuling");

function tbItem:OnUse()
	local tbOpt ={{"Nhận thưởng", self.GetAward, self}, {"Hướng dẫn nhiệm vụ", self.Infor, self},{"Ta chỉ xem qua"}};
	local szMsg = "Xin chào đại hiệp, chào mừng đại hiệp đã trở lại, đại hiệp có thể mang theo vật phẩm này để tham gia hoạt động và sẽ nhận được hiệu quả gấp đôi. Kiểm tra nhanh tiến độ của các hành động cá nhân?";
	Dialog:Say(szMsg, tbOpt);
	return;
end

function tbItem:GetAward(nIndex)
	if not nIndex then
		local tbOpt = {};
		for i, tb in ipairs(tbDayPlayerBack.tbEventList) do
			if i <= 4 then
				table.insert(tbOpt, {tb[1], self.GetAward,self, i});
			end
		end
		table.insert(tbOpt, {"Ta chỉ xem qua"});
		Dialog:Say("Hãy chọn hoạt động mà bạn muốn.", tbOpt);
		return;
	end
	if nIndex == 1 then
		self:GetWantedAward();
	elseif nIndex == 2 then
		self:GetXoyoAward();
	elseif nIndex == 3 then
		self:GetTreasureAward();
	elseif nIndex == 4 then
		self:GetBaihuAward();
	end
end

function tbItem:GetWantedAward(nFlag)
	local nCount = me.GetTask(2040, 2);
	local tbInfo = tbDayPlayerBack.tbEventList[1];
	local nMaxCount = me.GetTask(tbDayPlayerBack.TASK_GID, tbInfo[4]);
	local nGetCount = me.GetTask(tbDayPlayerBack.TASK_GID, tbInfo[5]);
	if nGetCount >= nMaxCount then
		Dialog:Say("Ngươi không còn phần thưởng tăng tốc.");
		return;
	end
	if nCount < 1 then
		Dialog:Say("Đã hết số lượt truy nã.");
		return;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ chỗ trống.");
		return;
	end
	if not nFlag then
		Dialog:Say("Ngươi có muốn đổi 1 phần thưởng tăng tốc để đổi 3 lệnh bài và 1 điểm Uy danh không?", {{"Đồng ý",self.GetWantedAward, self, 1}, {"Ta chỉ xem qua"}});
		return;
	end
	me.AddStackItem(18,1,190,1,nil, 3);
	me.AddKinReputeEntry(1);
	me.SetTask(2040, 2, nCount - 1);
	me.SetTask(tbDayPlayerBack.TASK_GID, tbInfo[5], nGetCount + 1);
	StatLog:WriteStatLog("stat_info", "roleback", "lingpai_use", me.nId, 1);
	me.Msg("Đã nhận phần thưởng tăng tốc thành công.");
end

function tbItem:GetXoyoAward(nFlag)
	local nCount = me.GetTask(2050, 1);
	local tbInfo = tbDayPlayerBack.tbEventList[2];
	local nMaxCount = me.GetTask(tbDayPlayerBack.TASK_GID, tbInfo[4]);
	local nGetCount = me.GetTask(tbDayPlayerBack.TASK_GID, tbInfo[5]);
	if nGetCount >= nMaxCount then
		Dialog:Say("Ngươi không còn phần thưởng tăng tốc.");
		return;
	end
	if nCount < 1 then
		Dialog:Say("Lượt tham gia Tiêu Dao Cốc đã hết");
		return;
	end
	if me.CountFreeBagCell() < 2 then
		Dialog:Say("Hành trang không đủ 2 ô trống");
		return;
	end
	if not nFlag then
		Dialog:Say("Tiêu hao 1 lượt tham gia Tiêu Dao Cốc và 30 cơ hội đổi danh vọng (nếu đã đổi thì không bị trừ) để nhận 1 rương Tiêu Dao, 3 Uy danh và ngẫu nhiên được thẻ đặc biệt, chứ?", {{"Đồng ý",self.GetXoyoAward, self, 1}, {"Ta chỉ xem qua"}});
		return;
	end
	--上交物品数
	local nTimes = me.GetTask(XoyoGame.TASK_GROUP, XoyoGame.REPUTE_TIMES);
	local nDate = me.GetTask(XoyoGame.TASK_GROUP, XoyoGame.CUR_REPUTE_DATE);
	local nCurDate = tonumber(os.date("%Y%m%d",GetTime()));
	if nDate ~= nCurDate then
		me.SetTask(XoyoGame.TASK_GROUP, XoyoGame.CUR_REPUTE_DATE, nCurDate)
		nTimes = 0;
	end
	me.SetTask(XoyoGame.TASK_GROUP, XoyoGame.REPUTE_TIMES, nTimes + 30);
	me.AddItemEx(18,1,1756,1);
	me.AddKinReputeEntry(3);
	me.SetTask(2050, 1, nCount - 1);
	if MathRandom(100) <= 30 then
		me.AddItemEx(18,1,314,1, {bForceBind= 1});
	end
	me.SetTask(tbDayPlayerBack.TASK_GID, tbInfo[5], nGetCount + 1);
	StatLog:WriteStatLog("stat_info", "roleback", "lingpai_use", me.nId, 2);
	me.Msg("Đã nhận thành công!");
end

function tbItem:GetTreasureAward()
	local tbInfo = tbDayPlayerBack.tbEventList[3];
	local nMaxCount = me.GetTask(tbDayPlayerBack.TASK_GID, tbInfo[4]);
	local nGetCount = me.GetTask(tbDayPlayerBack.TASK_GID, tbInfo[5]);
	if nGetCount >= nMaxCount then
		Dialog:Say("Không còn thời gian tăng tốc.");
		return;
	end
	local tbOpt = {{"Ta chỉ xem qua"}};
	for i = 3, 9 do
		if me.GetTask(TreasureMap2.TASK_GROUP, i) > 0 then
			table.insert(tbOpt, 1, {"Dùng lệnh bài <color=yellow>"..tbDayPlayerBack.tbNameTreasure[i].."<color>", self.ChangAward, self, i});
		end
	end
	Dialog:Say("Hãy chọn lệnh bài muốn đổi, 1 lệnh bài sẽ đổi được 10 rương phần thưởng Tàng Bảo Đồ", tbOpt);
	--Dialog:OpenGift("请放入<color=yellow>1个藏宝图令牌<color>，可以给你兑换<color=yellow>奖励宝箱10个<color>。", nil ,{self.OnOpenGiftOk, self});
end

function tbItem:ChangAward(nTaskId)
	local tbInfo = tbDayPlayerBack.tbEventList[3];
	local nMaxCount = me.GetTask(tbDayPlayerBack.TASK_GID, tbInfo[4]);
	local nGetCount = me.GetTask(tbDayPlayerBack.TASK_GID, tbInfo[5]);
	if nGetCount >= nMaxCount then
		Dialog:Say("Không còn thời gian tăng tốc.");
		return;
	end
	if me.GetTask(TreasureMap2.TASK_GROUP, nTaskId) <= 0 then
		Dialog:Say("Ngươi không có lệnh bài trong hành trang.");
		return;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ 1 ô trống.");
		return;
	end
	local nSelfLevel = 0;
	for i, nLevelEx in ipairs(tbDayPlayerBack.tbLevelLimit) do
		if me.nLevel >= nLevelEx and ( not tbDayPlayerBack.tbLevelLimit[i+1] or  me.nLevel < tbDayPlayerBack.tbLevelLimit[i+1]) then
			nSelfLevel = i;
			break;
		end
	end
	me.SetTask(TreasureMap2.TASK_GROUP, nTaskId, me.GetTask(TreasureMap2.TASK_GROUP, nTaskId) - 1);
	me.AddStackItem(18,1,1018,nSelfLevel, {bForceBind = 1}, 10);
	me.SetTask(tbDayPlayerBack.TASK_GID, tbInfo[5], nGetCount + 1);
	StatLog:WriteStatLog("stat_info", "roleback", "lingpai_use", me.nId, 3);
	me.Msg("Nhận thưởng thành công.");
end

function tbItem:OnOpenGiftOk(tbItemObj)
	local tbInfo = tbDayPlayerBack.tbEventList[3];
	local nMaxCount = me.GetTask(tbDayPlayerBack.TASK_GID, tbInfo[4]);
	local nGetCount = me.GetTask(tbDayPlayerBack.TASK_GID, tbInfo[5]);
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ 1 ô trống.");
		return;
	end
	if nGetCount >= nMaxCount then
		Dialog:Say("Không còn thời gian tăng tốc.");
		return;
	end
	if #tbItemObj ~= 1 then
		Dialog:Say("Chỉ có thể đặt 1 vật phẩm");
		return;
	end
	local nLevel = tbDayPlayerBack.tbTreasureLing[tbItemObj[1][1].SzGDPL()];
	if not nLevel then
		Dialog:Say("Hãy đặt lệnh bài Tàng Bảo Đồ vào.");
		return;
	end
	local nSelfLevel = 0;
	for i, nLevelEx in ipairs(tbDayPlayerBack.tbLevelLimit) do
		if me.nLevel >= nLevelEx and (not tbDayPlayerBack.tbLevelLimit[i+1] or me.nLevel < tbDayPlayerBack.tbLevelLimit[i+1]) then
			nSelfLevel = i;
			break;
		end
	end
	nLevel = math.min(nLevel, nSelfLevel);
	if nLevel <= 0 then
		Dialog:Say("Hãy đặt lệnh bài Tàng Bảo Đồ khác.");
		return;
	end
	me.AddStackItem(18,1,1018,nLevel, {bForceBind = 1}, 10);
	if tbItemObj[1][1].nCount > 1 then
		tbItemObj[1][1].SetCount(tbItemObj[1][1].nCount - 1);
	else
		tbItemObj[1][1].Delete(me);
	end
	me.SetTask(tbDayPlayerBack.TASK_GID, tbInfo[5], nGetCount + 1);
	StatLog:WriteStatLog("stat_info", "roleback", "lingpai_use", me.nId, 3);
	me.Msg("Nhận thưởng thành công.");
end

function tbItem:GetBaihuAward(nFlag)
	local nTimes = me.GetTask(BaiHuTang.TSKG_PVP_ACT, BaiHuTang.TSK_BaiHuTang_PKTIMES) or 0;
	local nOtherTimes = me.GetTask(BaiHuTang.TSKG_PVP_ACT, BaiHuTang.TSK_BaiHuTang_PKTIMES_Ex) or 0;
	local nNowDate =  tonumber(GetLocalDate("%y%m%d"));
	local nDate = math.floor(nTimes / 10);
	local nPKTimes = nTimes % 10;
	local tbInfo = tbDayPlayerBack.tbEventList[4];
	local nMaxCount = me.GetTask(tbDayPlayerBack.TASK_GID, tbInfo[4]);
	local nGetCount = me.GetTask(tbDayPlayerBack.TASK_GID, tbInfo[5]);
	if nGetCount >= nMaxCount then
		Dialog:Say("Không còn phần thưởng tăng tốc Bạch Hổ Đường");
		return;
	end
	if (nDate == nNowDate) and nPKTimes >= BaiHuTang.MAX_ONDDAY_PKTIMES then
		Dialog:Say("Đã hết lượt tham gia Bạch Hổ Đường hôm nay.");
		return;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ 1 ô trống.");
		return;
	end
	if not nFlag then
		Dialog:Say("Đổi 1 lượt Bạch Hổ Đường lấy bảo rương huyền tinh và 1 Uy danh?", {{"Đồng ý",self.GetBaihuAward, self, 1}, {"Ta chỉ xem qua"}});
		return;
	end
	if nDate ~= nNowDate then
		me.SetTask(BaiHuTang.TSKG_PVP_ACT, BaiHuTang.TSK_BaiHuTang_PKTIMES, nNowDate * 10 + 1);
	else
		me.SetTask(BaiHuTang.TSKG_PVP_ACT, BaiHuTang.TSK_BaiHuTang_PKTIMES, nTimes + 1);
	end
	me.AddItemEx(18,1,1757,1);
	me.AddKinReputeEntry(1);
	me.SetTask(tbDayPlayerBack.TASK_GID, tbInfo[5], nGetCount + 1);
	StatLog:WriteStatLog("stat_info", "roleback", "lingpai_use", me.nId, 4);
	me.Msg("Nhận thưởng thành công.");
end

function tbItem:Infor(nIndex)
	local szInfo = "Tham gia hoạt động để tích lũy phần thưởng tăng tốc."
	local tbEventInfo = {
	[1] = [[<color=green>Truy nã Hải tặc<color>
	
		Số lượt tối đa: <color=yellow>%s<color>
		Tiến độ: <color=yellow>%s/%s (Số lượt đã sử dụng/Số lượt thu được)<color>
		
		<color=red>Hướng dẫn: Hoàn thành 1 nhiệm vụ Truy nã Hải tặc nhận được 1 phần thưởng tăng tốc, sử dụng phần thưởng tăng tốc để nhận thưởng (Tiêu hao 1 lượt truy nã Hải tặc đổi lấy 3 lệnh bài và 1 điểm Uy danh)<color>]],
	[2] = [[<color=green>Tiêu Dao Cốc<color>
	
		Số lượt tối đa: <color=yellow>%s<color>
		Tiến độ: <color=yellow>%s/%s (Số lượt đã sử dụng/Số lượt thu được)<color>
		
		<color=red>Hướng dẫn: Hoàn thành ải cấp độ 4 trở đi sẽ nhận được phần thưởng tăng tốc, sử dụng phần thưởng tăng tốc để nhận thưởng( Tiêu hao 1 lần vượt ải Tiêu Dao Cốc đổi lấy 1 Hộp huyền tinh, 3 điểm Uy danh và ngẫu nhiên nhận được Thẻ đặc biệt)<color>]],
	[3] = [[<color=green>Tàng Bảo Đồ<color>
	
		Số lượt tối đa: <color=yellow>%s<color>
		Tiến độ: <color=yellow>%s/%s (Số lượt đã sử dụng/Số lượt thu được)<color>
		
		<color=red>Hướng dẫn: Hoàn thành Tàng bảo đồ để nhận phần thưởng tăng tốc, sử dụng phần thưởng tăng tốc để nhận thưởng (Tiêu hao 1 lệnh bài Tàng bảo đồ đổi lấy 10 rương phần thưởng)<color>]],
	[4] = [[<color=green>Bạch Hổ Đường<color>
	
		Số lượt tối đa: <color=yellow>%s<color>
		Tiến độ: <color=yellow>%s/%s (Số lượt đã sử dụng/Số lượt thu được)<color>
		
		<color=red>Hướng dẫn: Tham gia Bạch Hổ Đường qua tầng 2 sẽ nhận được phần thưởng tăng tốc, sử dụng phần thưởng tăng tốc nhận được phần thưởng (Tiêu hao 1 lần vượt ải nhận hộp huyền tinh và 1 điểm Uy danh)<color>]],
	[5] = [[<color=green>Quân doanh<color>
	
		Số lượt tối đa: <color=yellow>%s<color>
		Tiến độ: <color=yellow>%s/%s (Số lượt đã sử dụng/Số lượt thu được)<color>
		
		<color=red>Hướng dẫn: Hoàn thành nhiệm vụ Quân doanh nhận được phần thưởng tăng tốc (1 điểm Danh vọng, 1000 bạc khóa, 1 hộp Huyền tinh và 1 Uy danh)<color>]],
	[6] = [[<color=green>Đoán Hoa Đăng<color>
	
		Số lượt tối đa: <color=yellow>%s<color>
		Tiến độ: <color=yellow>%s/%s (Số lượt đã sử dụng/Số lượt thu được)<color>
		
		<color=red>Hướng dẫn: Đạt 200 điểm Đoán hoa đăng nhận được phần thưởng tăng tốc (Nhận gấp đôi phần thưởng)<color>]],
	[7] = [[<color=green>Ải Gia Tộc (Sơ)<color>
	
		Số lượt tối đa: <color=yellow>%s<color>
		Tiến độ: <color=yellow>%s/%s (Số lượt đã sử dụng/Số lượt thu được)<color>
		
		<color=red>Hướng dẫn: Dùng đồng tiền cổ đổi bảo rương nhận được phần thưởng tăng tốc (Nhận thêm 60 đồng tiền cổ)<color>]],
	[8] = [[<color=green>Ải Gia Tộc (Cao)<color>
	
		Số lượt tối đa: <color=yellow>%s<color>
		Tiến độ: <color=yellow>%s/%s (Số lượt đã sử dụng/Số lượt thu được)<color>
		
		<color=red>Hướng dẫn: Dùng đồng tiền cổ đổi Mảnh thạch cổ nhận được phần thưởng tăng tốc (Nhận thêm 60 đồng tiền cổ)<color>]],
	[9] = [[<color=green>Tranh đoạt lãnh thổ<color>
	
		Số lượt tối đa: <color=yellow>%s<color>
		Tiến độ: <color=yellow>%s/%s (Số lượt đã sử dụng/Số lượt thu được)<color>
		
		<color=red>Hướng dẫn: Sau khi kết thúc lãnh thổ chiến, tích lũy hơn 1000 điểm nhận được phần thưởng tăng tốc (Nhân đôi số rương lãnh thổ nhận được)<color>]],
	[10] = [[<color=green>Trồng cây Gia tộc<color>
	
		Số lượt tối đa: <color=yellow>%s<color>
		Tiến độ: <color=yellow>%s/%s (Số lượt đã sử dụng/Số lượt thu được)<color>
		
		<color=red>Hướng dẫn: Thu hoạch cây trồng trong Lãnh địa Gia tộc sẽ nhận được phần thưởng tăng tốc (Nhân đôi sản lượng thu hoạch)<color>]],	
	[11] = [[<color=green>Nhiệm vụ hiệp khách<color>
	
		Số lượt tối đa: <color=yellow>%s<color>
		Tiến độ: <color=yellow>%s/%s (Số lượt đã sử dụng/Số lượt thu được)<color>
		
		<color=red>Hướng dẫn: Hoàn thành Nhiệm vụ Hiệp khách để nhận phần thưởng tăng tốc, có cơ hội nhận thưởng tăng tốc đồng thời (Phần thưởng được nhân đôi)<color>]],
	}
	if not nIndex then
		local tbOpt = {};
		for i, tb in ipairs(tbDayPlayerBack.tbEventList) do
			table.insert(tbOpt, {tb[1], self.Infor, self, i});
		end
		table.insert(tbOpt, {"Ta chỉ xem qua"});
		Dialog:Say(szInfo, tbOpt);
		return;
	end
	local tbEvent = tbDayPlayerBack.tbEventList[nIndex];
	local nRate = me.GetTask(tbDayPlayerBack.TASK_GID, tbDayPlayerBack.TASK_RATE_BACK);
	local szInfoEx = string.format(tbEventInfo[nIndex], math.min(nRate * tbEvent[2], tbEvent[3]), me.GetTask(tbDayPlayerBack.TASK_GID, tbEvent[5]), me.GetTask(tbDayPlayerBack.TASK_GID, tbEvent[4]));
	Dialog:Say(szInfoEx);
	return;
end
