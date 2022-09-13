-------------------------------------------------------
-- 文件名　：longwutaiye.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-11-16 14:21:55
-- 文件描述：修改原有逻辑结构
-------------------------------------------------------

local tbJie = Npc:GetClass("longwutaiye");

function tbJie:OnDialog()

	local szMsg = "Ta có thể giúp gì cho ngươi ?";
	local tbOpt = {};
	
	--mini客户端, 更改为玩家20级或才可以看到龙五其他的功能
	local nLookLevel = 20;
	if me.nLevel >= nLookLevel then
		if (Youlongmibao:CheckState() == 1) then
			table.insert(tbOpt, {"<color=yellow>Tạp hóa Nguyệt Ảnh Thạch<color>", self.Challenge, self});
			table.insert(tbOpt, {"<color=yellow>Tạp hóa Du Long<color>", self.OpenYouLongZahuoShop, self});
			table.insert(tbOpt, {"<color=yellow>Danh vọng lệnh<color> (cơ bản)", self.OpenYouLongReputeShop, self});			
		end
		
		if (IVER_g_nTwVersion == 1) then
			table.insert(tbOpt, {"月影之石商店", self.Challenge, self});
		end
		
		if (Partner.bOpenPartner == 1) then
			-- table.insert(tbOpt, {"Du long là gì", self.OnSelectPartnerDesc, self});
			table.insert(tbOpt, {"Mở khóa trang bị đồng hành", Partner.UnBindPartEq, Partner, me.nId});
			table.insert(tbOpt, {"Đổi nguyên liệu đặc biệt", self.ChangePartnerMiJi, self});
			table.insert(tbOpt, {"Tách Vô Thượng Tinh Hoa", self.SplitPartnerJinghua, self});
			table.insert(tbOpt, {"Chân nguyên hộ thể", self.ChangeZhenYuan, self});
		end	
		
		local nData = tonumber(GetLocalDate("%Y%m%d"));
		if nData >= SpecialEvent.SpringFrestival.HuaDengOpenTime and nData <= SpecialEvent.SpringFrestival.HuaDengCloseTime then	--活动期间内启动服务器		
			table.insert(tbOpt, 1, {"Dùng bộ sưu tập sách đổi lấy phần thưởng", SpecialEvent.SpringFrestival.GetAward, SpringFrestival});	
		end
		
		if Esport:CheckState(3) == 1 then
			table.insert(tbOpt, 1, {"Hoạt động năm mới", Esport.GetItemJinZhouBaoZu, Esport});
		end	
	end
	
	local task_value = me.GetTask(1022,115);
	if task_value == 1 then
		table.insert(tbOpt, 1, {"Vào tàng kiếm sơn trang", self.Send2NewWorld, self});
		szMsg = string.format("%s: bạn đã đến, "..me.szName, him.szName);
	end;
	
	if me.nLevel >= nLookLevel then
		if (Partner.bOpenPartner == 1) then	
			local nPartnerDelState = Partner:GetDelState(me);
			if nPartnerDelState == 1 then
				table.insert(tbOpt, 4, {"Hủy quan hệ đồng hành", self.OnSelectPartnerDel, self, 1});
			else
				table.insert(tbOpt, 4, {"Khôi phục đồng hành", self.OnSelectPartnerDel, self, 0});
			end
			
			local nPartnerPeelState = Partner:GetPeelState(me);
			if nPartnerPeelState == 1 then
				table.insert(tbOpt, 5, {"Trùng sinh đồng hành", self.OnSelectPartnerPeel, self, 1});
			else
				table.insert(tbOpt, 5, {"Hủy trùng sinh đồng hành", self.OnSelectPartnerPeel, self, 0});
			end
	
			local nPartnerEquipState = Partner:GetPartnerEquipState(me);
			if nPartnerEquipState == 1 then
				table.insert(tbOpt, 6, {"Xin Mở khóa trang bị đồng hành", self.ApplyUnBindPartEq, self, 1});
			else
				table.insert(tbOpt, 6, {"Hủy mở khóa trang bị đồng hành", self.ApplyUnBindPartEq, self, 0});
			end
		end
	end
	
	-- 我绝对不写注释, 你永远都不可能知道1025,75是龙影珠任务完成状态的任务变量ID
	task_value = me.GetTask(1025, 75);
	if task_value == 1 then
		table.insert(tbOpt, {"Cấp lại Long Ảnh Châu", self.ApplyReGetDragonBall, self});
	end
	
	table.insert(tbOpt, {"Kết thúc đối thoại"});

	Dialog:Say(szMsg, tbOpt);
end

function tbJie:Send2NewWorld()
	me.NewWorld(477,1631,3099);
	me.SetFightState(0);
end

tbJie.tbReputeShop = {
	[1] = { "OpenYoulongAllSell", 299, 3},
	[2] = { "OpenLevel150", 298, 3},
	[3] = { "OpenLevel99", 297, 3},
	[4] = { "OpenLevel79", 296, 3},
};

function tbJie:OpenYouLongReputeShop()
	for i = 1, #self.tbReputeShop do
		local tbRepute = self.tbReputeShop[i];
		if (TimeFrame:GetState(tbRepute[1]) == 1) then
			me.OpenShop(tbRepute[2], tbRepute[3]);
			return;
		end
	end
	Dialog:Say("Du long chưa mở cửa");
	return;
end

function tbJie:OpenYouLongZahuoShop()
	me.OpenShop(167,3);
end

function tbJie:Challenge()
	
	me.OpenShop(166, 3);
	do return end;
	
	Dialog:OpenGift("Hãy đặt nguyệt ảnh thạch vào", nil, {Youlongmibao.OnChallenge, Youlongmibao});
end

function tbJie:OnSelectPartnerDesc()
	Dialog:Say("    想让剑侠世界里的各路江湖人士与你结伴同行吗?当你陷入苦战时, 同伴能够助你一臂之力。<enter>    详细请看<color=yellow>F12<color>中<color=yellow>详细帮助的同伴系统<color>进行了解。");
end

function tbJie:OnSelectPartnerDel(nState)
	local szMsg = "";
	local tbOpt = {};
	
	if nState == 1 then
		if me.nPartnerCount == 0 then
			szMsg = "Bạn không có đồng hành";
			Dialog:Say(szMsg);
			return;
		end
	
		szMsg = string.format("Sau %d giây sẽ thực hiện hủy bỏ đồng hành, bạn có chắc chắn?", 
			Partner.DEL_USABLE_MINTIME, Partner.DELLIMITSTARLEVEL, Partner.DELLIMITSKILLCOUNT);
		tbOpt =
		{
			{"Đồng ý", Partner.ApplyDelPartner, Partner, me.nId},
			{"Ta chỉ xem qua thôi"},
		}
	else
		local nPeelTime = me.GetTask(Partner.TASK_DEL_PARTNER_GROUPID, Partner.TASK_DEL_PARTNER_SUBID);
		local nDiff = GetTime() - nPeelTime;
		
		if nDiff <= Partner.DEL_USABLE_MINTIME then	
			szMsg = string.format("Bạn đã gửi yêu cầu hủy bỏ, %d giây để thực hiện, bạn có chắc chắn?", 
				(Partner.DEL_USABLE_MINTIME - nDiff));
		elseif nDiff >= Partner.DEL_USABLE_MAXTIME then
			me.Msg("Bạn gửi một yêu cầu loại bỏ đã hết hạn, xin vui lòng thử lại");
			return;
		else
			szMsg = string.format("Bạn gửi một ứng dụng đã bắt đầu có hiệu lực, bạn có thể  đồng hành %0.1f ! Bạn có muốn thu hồi?", 
				Partner.DELLIMITSTARLEVEL, Partner.DELLIMITSKILLCOUNT);
		end	
			
		tbOpt = 
		{
			{"Đồng ý", Partner.CancelDelPartner, Partner, me.nId},
			{"Ta chỉ xem qua thôi"},
		}
	end
		
	Dialog:Say(szMsg, tbOpt);
end

function tbJie:OnSelectPartnerPeel(nState)
	local szMsg = "";
	local tbOpt = {};
	
	if nState == 1 then
		if me.nPartnerCount == 0 then
			szMsg = "Bạn không có đồng hành";
			Dialog:Say(szMsg);
			return;
		end
		
		szMsg = string.format("%d giây sau khi nộp Bồ Đề Quả, có thể trùng sinh đồng hành %0.1f, xác định trùng sinh?", 
			(Partner.PEEL_USABLE_MINTIME), Partner.PEELLIMITSTARLEVEL);
		tbOpt =
		{
			{"Đồng ý", Partner.ApplyPeelPartner, Partner, me.nId},
			{"Để ta suy nghĩ thêm"},
		}
	else
		local nPeelTime = me.GetTask(Partner.TASK_PEEL_PARTNER_GROUPID, Partner.TASK_PEEL_PARTNER_SUBID);
		local nDiff = GetTime() - nPeelTime;
		
		if nDiff <= Partner.PEEL_USABLE_MINTIME then	
			szMsg = string.format("Bạn đã gửi yêu cầu trùng sinh đồng hành, sau %d giây có thể thực hiện nhưng bạn có thể quyết định hủy bỏ thao tác vừa chọn?", 
				(Partner.PEEL_USABLE_MINTIME - nDiff));
		elseif nDiff >= Partner.PEEL_USABLE_MAXTIME then
			me.Msg("Yêu cầu của bạn đã quá hạn, vui lòng thử lại");
			return;
		else
			szMsg = string.format("Bạn đã gửi yêu cầu và bắt đầu có hiệu lực, bạn có thể sử dụng Bồ Đề Quả để trùng sinh đồng hành %0.1f sao! Bạn có muốn thu hồi?",
				Partner.PEELLIMITSTARLEVEL);
		end	
			
		tbOpt = 
		{
			{"Đồng ý", Partner.CancelPeelPartner, Partner, me.nId},
			{"Để ta suy nghĩ thêm"},
		}
	end
	
	Dialog:Say(szMsg, tbOpt);
end

--同伴特殊材料兑换同伴秘籍
function tbJie:ChangePartnerMiJi()
	local szMsg = "Dùng nguyên liệu đồng hành đặc biệt có thể trao đổi đồng hành(Khóa):\n nguyên liệu sơ(khóa) đổi được <color=yellow>6 sao <color> cần <color=yellow>5<color> nguyên liệu đặc biệt \n nguyên liệu trung(Khóa) đổi được đồng hành <color=yellow> 6 sao và 6 sao rưỡi <color> cần <color=yellow>5<color> nguyên liệu đặc biệt \n Nguyên liệu đồng hành cao cấp <color=yellow> Đồng hành 8 sao hoặc hơn <color> cần <color=yellow>30<color> nguyên liệu, ngươi muốn trao đổi gì nào?";
	local tbOpt = 
	{
		{"Ta muốn đổi đồng hành sơ", self.ChangePartnerMiJExi, self, 1},
		{"Ta muốn đổi đồng hành trung", self.ChangePartnerMiJExi, self, 2},
		{"Ta muốn đổi đồng hành cao", self.ChangePartnerMiJExi, self, 3},
		{"Để ta suy nghĩ thêm"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbJie:ChangePartnerMiJExi(nLevel)
	local tbType = {1, 5, 30} --三个级别兑换的个数
	local szContent = string.format("Hãy đặt vào <color=yellow>%s<color> nguyên liệu đặc biệt", tbType[nLevel]);
	Dialog:OpenGift(szContent, nil, {tbJie.OnOpenGiftOk, tbJie, nLevel});
end

function tbJie:OnOpenGiftOk(nLevel, tbItemObj)
	local tbType = {1, 5, 30} --三个级别兑换的个数
	local szPartnerCaiLiao = "18,1,556,1"; 	--同伴特殊材料的gdpl
	--数量判断
	local nCount = 0;
	for i = 1, #tbItemObj do
		nCount = nCount + tbItemObj[i][1].nCount;
	end
	if nCount ~= tbType[nLevel] then
		Dialog:Say("Số lượng không đủ", {"Ta biết rồi"});
		return 0;
	end
	--物品判定
	for i = 1, #tbItemObj do
		local pItem = tbItemObj[i][1];
		local szKey = string.format("%s,%s,%s,%s",pItem.nGenre,pItem.nDetail,pItem.nParticular,pItem.nLevel);
		if szKey ~= szPartnerCaiLiao then
			Dialog:Say("Loại nguyên liệu không đúng", {"Ta biết rồi"});
			return 0;
		end
	end
	--背包判定
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang đã đầy, hãy thu xếp rồi nhận lại",{"Ta biết rồi"});
		return 0;
	end
	--删除交的东西
	for i = 1, #tbItemObj do
		local pItem = tbItemObj[i][1];
		pItem.Delete(me);
	end
	local pItemEx = me.AddItem(18, 1, 554, nLevel);
	if pItemEx then
		pItemEx.Bind(1);
		me.SetItemTimeout(pItemEx, 60*24*30, 0);
		EventManager:WriteLog(string.format("[Trao đổi đồng hành] cùng với hàng hóa: %s",pItemEx.szName), me);
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[Trao đổi đồng hành] cùng với hàng hóa: %s",pItemEx.szName));
	else
		EventManager:WriteLog(string.format("[Trao đổi đồng hành] thất bại, tiếu tốn %s",nCount), me);
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[Trao đổi đồng hành] thất bại, tiếu tốn: %s",nCount));		
	end
end

-- by zhangjinpin@kingsoft
function tbJie:SplitPartnerJinghua()
	local szMsg = "Ở đây bạn có thể dùng <color=yellow>Đồng hành (4 kỹ năng)<color> tách thành <color=yellow>Đồng hành (3 kỹ năng)<color>";
	szMsg = szMsg .. "<color=green>(1 nguyên liệu cao cấp, có thể tách thành 10 nguyên liệu bạch kim)<color>";
	Dialog:OpenGift(szMsg, nil, {tbJie.OnSplitPartnerJinghua, tbJie});
end

function tbJie:OnSplitPartnerJinghua(tbItem)
	
	local tbItemIdIn = {18, 1, 565, 4};
	local tbItemIdOut = {18, 1, 565, 3};
	
	local nExCount = 0;
	for _, tbItem in pairs(tbItem) do
		local pItem = tbItem[1];
		local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel)
		if szKey == string.format("%s,%s,%s,%s", unpack(tbItemIdIn)) then
			nExCount = nExCount + pItem.nCount;
		end
	end
	
	if nExCount <= 0 then
		Dialog:Say("Xin vui lòng đặt vào đúng số lượng yêu cầu");
		return 0;
	end
	
	local nNeed = KItem.GetNeedFreeBag(tbItemIdOut[1], tbItemIdOut[2], tbItemIdOut[3], tbItemIdOut[4], nil, nExCount * 10);
	if me.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("Hãy thu xếp hành trang đủ %s ô rồi thử lại", nNeed));
		return 0;
	end
	
	local nExTempCount = 0;
	for _, tbItem in pairs(tbItem) do
		local pItem = tbItem[1];
		local szKey = string.format("%s,%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel)
		if szKey == string.format("%s,%s,%s,%s", unpack(tbItemIdIn)) then
			me.DelItem(pItem);
			nExTempCount = nExTempCount + pItem.nCount;
		end
		if nExTempCount >= nExCount then
			break;
		end
	end
	
	me.AddStackItem(tbItemIdOut[1], tbItemIdOut[2], tbItemIdOut[3], tbItemIdOut[4], nil, nExCount * 10);
end

function tbJie:ApplyUnBindPartEq(nState)
	local szMsg = "";
	local tbOpt = {};
	
	if nState == 1 then
		-- 下面除以2是把小时转成时辰
		szMsg = string.format("Chiếc ổ khóa quá cũ, tôi chưa bao giờ thấy cái nào cũ như thế, tôi cần %d giây, sau đó ngươi có %d phút để mở, tôi có thể mở cho ngươi ngay không phải chờ đợi.", 
			Partner.BIND_PARTNERQUIP_MINTIME/2, Partner.BIND_PARTNERQUIP_MINTIME);
		tbOpt =
		{
			{"Mở khóa thết bị đồng hành", Partner.ApplyUnBindPartEq, Partner, me.nId},
			{"Xem qua thôi"},
		}
	else
		local nBindTime = me.GetTask(Partner.TASK_BIND_PARTNEREQ_GROUPID, Partner.TASK_BIND_PARTNEREQ_SUBID);
		local nDiff = GetTime() - nBindTime;
		
		if nDiff <= Partner.BIND_PARTNERQUIP_MINTIME then	
			szMsg = string.format("Bạn yêu cầu mở khóa thết bị đồng hành, sau khi %d giây sẽ có hiệu lực,", 
				(Partner.BIND_PARTNERQUIP_MINTIME - nDiff));
		elseif nDiff >= Partner.BIND_PARTNERQUIP_MAXTIME then
			me.Msg("Yêu cầu của bạn đã hết hạn, xin hãy gửi lại");
			return;
		else
			szMsg = string.format("Yêu cầu mở khóa bạn đồng hành của bạn đã có hiệu lực, bạn có muốn thu hồi lại không?",
				Partner.PEELLIMITSTARLEVEL);
		end	
			
		tbOpt = 
		{
			{"Đồng ý", Partner.CancelUnBindPartEq, Partner, me.nId},
			{"Để ta suy nghĩ thêm"},
		}
	end
	
	Dialog:Say(szMsg, tbOpt);
end

function tbJie:ChangeZhenYuan()
	local szMsg = "    Miễn phí Chuyển Chân Nguyên Hộ Thể thành phi hộ thể (giới hạn chân nguyên trên 1000), sau khi chuyển hóa<color=red> toàn bộ thuộc tính sẽ giảm nửa sao<color>.";
	local nTime = me.GetTask(2085, 8);
	local nDetra = GetTime() - nTime;
	if nTime <= 0 or nDetra <= 0 or nDetra > Item.MAX_PEEL_TIME then
		szMsg = szMsg .. "Để ta chuẩn bị đã, 3 giờ sau có thể bắt đầu";
		local tbOpt = 
		{
			{"<color=yellow>Đồng ý<color>", self.OnApplyChangeZhenYuan, self},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	elseif nDetra <= Item.VALID_PEEL_TIME then
		szMsg = szMsg .. "Đã chuyển hóa, xin chờ một chút để bắt đầu";
		local tbOpt = 
		{
			{"<color=yellow>Hủy bỏ<color>", self.ChancelChangeZhenYuan, self},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	else
		szMsg = szMsg .. "Bạn có chắc chắn muốn chuyển hóa ?";
		local tbOpt =
		{
			{"<color=yellow>Đồng ý<color>", jbreturn.ChangeFree, jbreturn},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
end

function tbJie:ChancelChangeZhenYuan()
	local szMsg = "Bạn có chắc chắn muốn hủy bỏ chuyển hóa chân nguyên hộ thể ?";
	local tbOpt =
	{
		{"<color=yellow>Đồng ý<color>", self.OnChancelChangeZhenYuan, self},
		{"Để ta suy nghĩ thêm"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbJie:OnApplyChangeZhenYuan()
	me.SetTask(2085, 8, GetTime());
	me.AddSkillState(2476, 1, 1, Item.MAX_PEEL_TIME * Env.GAME_FPS, 1, 0, 1);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "Thực hiện chuyển hóa chân nguyên hộ thể thành phi hộ thể");
	me.Msg(" Bạn xác định Chuyển Chân Nguyên Hộ Thể thành phi hộ thể");
end

function tbJie:OnChancelChangeZhenYuan()
	me.SetTask(2085, 8, 0);
	me.RemoveSkillState(2476);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "Thu hồi chuyển hóa chân nguyên hộ thể thành phi hộ thể");
	me.Msg("Bạn hủy bỏ Chuyển Chân Nguyên Hộ Thể thành phi hộ thể");
end

function tbJie:ApplyReGetDragonBall()
	local tbRes = me.FindItemInAllPosition(unpack(Item.DRAGONBALL_GDPL));
	if tbRes and Lib:CountTB(tbRes) ~= 0 then
		Dialog:Say(" Thiếu chủ, cấp tư chất thuộc tính quyết định giá trị của chân nguyên, sau khi trang bị vào người sức chiến đấu cộng thêm nhiều hơn <enter>Vì vậy,không thể ham muốn nhiều hơn nữa, tránh thu hút tai họa thiệt thân");
		return;
	end
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Xin hãy bỏ trống ít nhất là một cột ô trống trong hành trang");
		return;
	end
	
	local pItem = me.AddItem(unpack(Item.DRAGONBALL_GDPL));
	if not pItem then
		Dialog:Say("Nhận thất bại, hãy thiết lập lại");
		return;
	end
	
	Item:SyncPlayerDataToBall(me, pItem);	
end