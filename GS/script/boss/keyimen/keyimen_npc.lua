-------------------------------------------------------
-- 文件名　: keyimen_npc.lua
-- 创建者　: zhangjinpin@kingsoft
-- 创建时间: 2012-02-22 11:31:58
-- 文件描述: 
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\boss\\keyimen\\keyimen_def.lua");

-- 战场报名官
local tbSignup = Npc:GetClass("keyimen_npc_signup");

function tbSignup:OnDialog()
	local nCamp = Keyimen.MAP_LIST[him.nMapId];
	if not nCamp or nCamp <= 0 then
		Dialog:Say("Có vẻ như ngươi đến nhầm chỗ rồi!");
		return 0;
	end
	
	local tbTxt = 
	{
		[1] = "Bấy giờ, quân Mông Cổ đang xâm chiếm giang sơn ta, giết đồng bào ta. Nếu ngươi có thể giúp nước nhà đánh đuổi Tiểu Lỗ, cứu dân chúng Tây Hạ khỏi nguy nan. Tây Hạ ta ghi nhớ trong lòng, mà các vị cũng lưu danh sử sách.",
		[2] = "Các vị đại hiệp, có bằng lòng đi tiêu diệt quân Tây Hạ ngoan cố, giúp chúng tôi hoàn thành đại nghiệp không? Chúng tôi muốn biến đồng cỏ xanh trở thành nơi nuôi ngựa của gia tộc, trời cao nhất định sẽ phù hộ các vị chiến thắng!",
	};   
	
	local szMsg = string.format([[
	    %s
		    
	☆ Tộc trưởng đến chỗ Quan Ghi Danh <color=yellow>chọn phe<color>
	☆ Thành viên gia tộc nhận <color=yellow>Quân Lệnh Phe<color> trong ngày.
	☆ Mang theo <color=yellow>Quân Lệnh<color> mới có thể nhận nhiệm vụ phe.
	
	<color=green>Phe của gia tộc: <color>]], tbTxt[nCamp]);
	
	local tbOpt = 
	{
		{"<color=yellow>Nhận Quân Lệnh hôm nay<color>", self.GetCampPad, self},
		{"Ta hiểu rồi"},
	};
	
	if me.GetTask(Keyimen.TASK_GID, Keyimen.TASK_STATE) == 0 then
		if Keyimen:CheckPeriod() == 1 then
			table.insert(tbOpt, 2, {"<color=green>Nhận nhiệm vụ Long Hồn<color>", self.GetTongTask, self});
		else
			table.insert(tbOpt, 2, {"<color=gray>Nhận nhiệm vụ Long Hồn<color>", self.GetTongTask, self});
		end
	elseif me.GetTask(Keyimen.TASK_GID, Keyimen.TASK_STATE) == 1 and Keyimen:CheckPlayerTaskFinish(me) == 1 then
		table.insert(tbOpt, 2, {"<color=green>Hoàn thành nhiệm vụ Long Hồn<color>", self.FinishTongTask, self});
	end
	
	local nTongId = me.dwTongId;
	local nKinId, nMemberId = me.GetKinMember();
	if Tong:CheckSelfRight(nTongId, nKinId, nMemberId, Tong.POW_MASTER) == 1 
	or Tong:CheckPresidentRight(nTongId, nKinId, nMemberId) == 1 then
		table.insert(tbOpt, 1, {"<color=yellow>Chọn phe cho ngày mai<color>", self.SelectCamp, self});
		table.insert(tbOpt, 1, {"<color=cyan>Mở nhiệm vụ Long Hồn<color>", self.StartTongTask, self});
	end
	
	local nCamp = Keyimen:GetTongCamp(nTongId)
	if nCamp <= 0 then
		szMsg = szMsg .."<color=gray>Chưa chọn<color>";
	else
		szMsg = szMsg .. string.format("<color=yellow>%s<color>", Keyimen.CAMP_LIST[nCamp]);
	end         

	Dialog:Say(szMsg, tbOpt);
end

-- 选择阵营
function tbSignup:SelectCamp()
	
	local nCamp = Keyimen.MAP_LIST[him.nMapId];
	if not nCamp or nCamp <= 0 then
		Dialog:Say("Có vẻ như ngươi đến nhầm chỗ rồi!");
		return 0;
	end
	
	local nTongId = me.dwTongId;
	local nKinId, nMemberId = me.GetKinMember();
	if Tong:CheckSelfRight(nTongId, nKinId, nMemberId, Tong.POW_MASTER) ~= 1 
	and Tong:CheckPresidentRight(nTongId, nKinId, nMemberId) ~= 1 then
		Dialog:Say("Xin lỗi, chỉ có Bang chủ mới có thể thao tác.");
		return 0;
	end
	
	local nPreCamp = Keyimen:GetTongPreCamp(nTongId);
	if nPreCamp > 0  then
		Dialog:Say(string.format("    Bang hội đã chọn phe: <color=yellow>%s<color>, nếu Bang hội không chọn lại phe, hệ thống sẽ giữ nguyên phe đã chọn cho ngày hôm sau.", Keyimen.CAMP_LIST[nPreCamp]));
		return 0;
	end
	    
	local szMsg = string.format("    Bang hội các ngươi xác định muốn gia nhập <color=yellow>%s<color> làm doanh trại ngày mai sao? Mỗi Bang hội chỉ có thể thay đổi <color=yellow>1 lần<color> trong ngày, một khi đã xác nhận thì không thể thay đổi.", Keyimen.CAMP_LIST[nCamp], Keyimen.CAMP_LIST[nCamp]);
	local tbOpt = 
	{
		{"<color=yellow>Xác nhận<color>", self.DoSelectCamp, self, nCamp},
		{"Ta hiểu rồi"},
	};
	
	Dialog:Say(szMsg, tbOpt);
end

function tbSignup:DoSelectCamp(nCamp)
	
	local nTongId = me.dwTongId;
	local nKinId, nMemberId = me.GetKinMember();
	if Tong:CheckSelfRight(nTongId, nKinId, nMemberId, Tong.POW_MASTER) ~= 1
	and Tong:CheckPresidentRight(nTongId, nKinId, nMemberId) ~= 1 then
		Dialog:Say("Xin lỗi, chỉ có Bang chủ mới có thể thao tác.");
		return 0;
	end
	
	local nPreCamp = Keyimen:GetTongPreCamp(nTongId);
	if nPreCamp > 0  then
		Dialog:Say(string.format("Bang hội của bạn đã chọn phe <color=yellow>%s<color> cho ngày mai.", Keyimen.CAMP_LIST[nPreCamp]));
		return 0;
	end
	
	Keyimen:TongSignup_GS(nTongId, nCamp);
	StatLog:WriteStatLog("stat_info", "keyimen_battle", "select_camp", me.nId, nTongId, nCamp);

	local szMsg = string.format("<color=yellow>%s<color> đã chọn phe <color=yellow>%s<color> cho ngày mai", me.szName, Keyimen.CAMP_LIST[nCamp]);
	KTong.Msg2Tong(nTongId, szMsg, 0);
	Keyimen:SendMessage(me, Keyimen.MSG_CHANNEL, szMsg);
end

-- 领取军令
function tbSignup:GetCampPad()
	
	if me.GetTask(Keyimen.TASK_GID, Keyimen.TASK_GET_PAD) == 1 then
		Dialog:Say("    Hôm nay đã nhận Quân Lệnh rồi, mỗi người chỉ có thể nhận <color=yellow>1 quân lệnh<color> trong ngày.");
		return 0;
	end
	
	local nTongId = me.dwTongId;
	local nKinId, nMemberId = me.GetKinMember();
	
	if nTongId <= 0 then
		Dialog:Say("Xin lỗi, ngươi chưa vào bang hội nào.");
		return 0;
	end
	
	if Keyimen:GetTongCamp(nTongId) <= 0 then
		Dialog:Say("Xin lỗi, bang hội ngươi chưa chọn phe.");
		return 0;
	end
	
	local nCamp = Keyimen.MAP_LIST[him.nMapId];
	if Keyimen:GetTongCamp(nTongId) ~= nCamp then
		Dialog:Say(string.format("    Xin lỗi, bang hội ngươi không chọn phe <color=yellow>%s<color> hôm nay.", Keyimen.CAMP_LIST[nCamp]));
		return 0;
	end
	
	local nNeed = 1;
	if me.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("Hành trang không đủ %s ô trống!", nNeed));
		return 0;
	end
	
	local pItem = me.AddItem(unpack(Keyimen.CAMP_PAD_LIST[nCamp]));
	if pItem then
		me.SetTask(Keyimen.TASK_GID, Keyimen.TASK_GET_PAD, 1);
		Keyimen:SendMessage(me, Keyimen.MSG_CHANNEL, string.format("Hãy cầm quân lệnh này, ngươi sẽ nhận được khá nhiều nhiệm vụ ở hậu doanh đấy."));
		KKin.Msg2Kin(nKinId, string.format("Thành viên <color=yellow>[%s]<color> nhận được 1 %s ở chiến trường Khắc Di Môn.", me.szName, pItem.szName), 0);
		StatLog:WriteStatLog("stat_info", "keyimen_battle", "join", me.nId, 1);
	end	
end

-- 开启龙魂任务
function tbSignup:StartTongTask()
	
	local nTongId = me.dwTongId;
	local nKinId, nMemberId = me.GetKinMember();
	if Tong:CheckSelfRight(nTongId, nKinId, nMemberId, Tong.POW_MASTER) ~= 1 
	and Tong:CheckPresidentRight(nTongId, nKinId, nMemberId) ~= 1 then
		Dialog:Say("Xin lỗi, chỉ có Bang chủ mới có thể mở nhiệm vụ.");
		return 0;
	end
	
	local nCamp = Keyimen:GetTongCamp(nTongId);
	if nCamp <= 0 then
		Dialog:Say("Xin lỗi, Bang hội chưa chọn phe, không thể mở nhiệm vụ");
		return 0;
	end
	
	if nCamp ~= Keyimen.MAP_LIST[him.nMapId] then
		Dialog:Say("Xin lỗi, hãy mở nhiệm vụ Long Hồn ở hậu doanh.");
		return 0;
	end
	
	local tbInfo = Keyimen.tbTongBuffer[nTongId];
	if tbInfo.tbTask and #tbInfo.tbTask > 0 then
		Dialog:Say("Bang hội này đã mở nhiệm vụ rồi");
		return 0;
	end
	
	Keyimen:TongStartTask_GS(nTongId);

	local szMsg = string.format("%s đã mở nhiệm vụ Long Hồn, thành viên Bang hội có thể tới doanh trại để tiếp nhận nhiệm vụ.", me.szName);
	KTong.Msg2Tong(nTongId, szMsg, 0);
	Keyimen:SendMessage(me, Keyimen.MSG_CHANNEL, szMsg);
end

-- 领取龙魂任务
function tbSignup:GetTongTask()
	
	local nCamp = Keyimen:GetTongCamp(me.dwTongId);
	if nCamp ~= Keyimen.MAP_LIST[him.nMapId] then
		Dialog:Say("Xin lỗi, Bang hội ngươi chưa chọn phe hoặc không chọn phe này, không thể nhận nhiệm vụ.");
		return 0;
	end
	
	if Keyimen:CheckPeriod() ~= 1 then
		Dialog:Say("Mỗi ngày 14:30-15:15 và 21:30-22:15 có thể Nhận nhiệm vụ Long Hồn.");
		return 0;
	end
	
	local tbTask = Keyimen:GetPlayerTongTask(me);
	if not tbTask then
		Dialog:Say("Xin lỗi, Bang hội ngươi chưa mở nhiệm vụ Long Hồn.");
		return 0;
	end
	
	local tbResult = Task:DoAccept(Keyimen.TASK_MAIN_ID, Keyimen.TASK_MAIN_ID);
	if tbResult then
		StatLog:WriteStatLog("stat_info", "keyimen_battle", "task_accept", me.nId, 1);
	end
end

-- 完成龙魂任务
function tbSignup:FinishTongTask()
	if Keyimen:CheckPlayerTaskFinish(me) == 1 then
		Keyimen:FinishTaskAward(me);
	end
end

-------------------------------------------------------

-- 装备商人
local tbTrader = Npc:GetClass("keyimen_npc_trader");

function tbTrader:OnDialog()
	
	local nCamp = Keyimen.MAP_LIST[him.nMapId];
	if not nCamp or nCamp <= 0 then
		Dialog:Say("Có vẻ như ngươi đến nhầm chỗ rồi!");
		return 0;
	end
	
	local tbTxt = 
	{
		[1] = "Những kẻ xâm lược phải dùng máu của mình mới có thể an ủi được <color=yellow>Tây Hạ<color> của ta!",
		[2] = "Nơi nào có đồng cỏ xanh, thì người <color=yellow>Mông Cổ<color> sẽ đưa ngựa đến ăn ở đó.",
	};   
	
	local szMsg = string.format([[
	    %s
	    Ta có một ít báu vật và thần giáp ở đây, nếu ngươi thu thập thêm cho ta, ta rất cảm kích. Nhưng những bảo vật kia chỉ xuất hiện ở tiền tuyến, lúc đến đó ngươi cần phải thận trọng. 
	]], tbTxt[nCamp]);

	local tbOpt = 
	{
		{"<color=yellow>Tọa kỵ chiến trường<color>", self.KeyimenHorse, self},
		{"<color=yellow>Trang bị Long Hồn<color>", self.BuyEquip, self},
		{"Ta hiểu rồi"},
	};
	
	Dialog:Say(szMsg, tbOpt);
end

-- 战场坐骑
function tbTrader:KeyimenHorse()
	
	local nCamp = Keyimen.MAP_LIST[him.nMapId];
	if not nCamp or nCamp <= 0 then
		Dialog:Say("Có vẻ như ngươi đến nhầm chỗ rồi!");
		return 0;
	end
	
	local szMsg = "    \"赤夜飞翔, 赤地三千, 乘云而奔, 身有羽翅, 乃神驹也\". \n\n    Đó là những câu nói về con chiến mã này. Quả thật, trên đời này chỉ có mình ta biết cách thu phục nó! Ngươi cần một số <color=yellow><color>, nếu ngươi tìm thấy, ta sẽ giúp ngươi.";
	local tbOpt = 
	{
		
		{"<color=yellow>Giao Xích Dạ Phi Tinh<color>", self.HandinFragment, self},
		{"<color=yellow>Nhận lại Xích Dạ Phi Tinh<color>",self.GetFragmentBack, self},
		{"<color=yellow>Xem bảng xếp hạng<color>", self.ViewLadder, self},
		{"<color=yellow>Lãnh nhận Thần Mã<color>", self.GetHorse, self},
		{"Ta hiểu rồi"},
	};
	
	Dialog:Say(szMsg, tbOpt);
end

function tbTrader:HandinFragment(nType, tbItemObj)
	
	nType = nType or 0;
	if nType == 0 then
		local szMsg = "Vào 21:30 Chủ nhật hàng tuần sẽ cập nhật bảng xếp hạng, Hiệp sĩ đầu tiên và số vật phẩm giao nộp <color=yellow>lớn hơn hoặc bằng 300<color> sẽ nhận được 1 con Xích Dạ Phi Tường. <enter>Hiệp sĩ không nằm trong Top 5 có thể <color=yellow>nhận lại tất cả<color> Xích Dạ Phi Tinh đã giao nộp từ 21:30 Chủ nhật đến 21:30 hôm sau. <enter><enter>Hãy đặt Xích Dạ Phi Tinh muốn giao nộp";
		Dialog:OpenGift(szMsg, nil, {self.HandinFragment, self, 1});
		return 0;
	end
	
	if nType == 1 then
		local tbItems = {};
		local nCount = 0;
		local szItemName = "";
		for _, tbItem in pairs(tbItemObj) do
			if tbItem[1].szClass == "newhorse_piece" then
				table.insert(tbItems, tbItem[1]);
				nCount = nCount + tbItem[1].nCount;
				szItemName = tbItem[1].szName;
			end
		end
		
		if nCount <= 0 then
			me.Msg("Số lượng không đúng!");
			return 0;
		end
			
		local szMsg = string.format("Ngươi có chắc muốn nộp %d %s không?", nCount, szItemName);
		local tbOpt = 
		{
			{"Xác nhận", self.HandinFragment, self, 2, tbItems},
			{"Để ta nghĩ lại đã"},
		}
		Dialog:Say(szMsg, tbOpt);
	end
	
	if nType == 2 then
		local nCount = 0;
		for _, pItem in pairs(tbItemObj) do
			if pItem.szClass == "newhorse_piece" then
				local nCurCount = pItem.nCount;
				if me.DelItem(pItem, Player.emKLOSEITEM_HANDIN_HOSRE_FRAG) == 1 then
					nCount = nCount + nCurCount;
				end
			end
		end
		
		if nCount ~= 0 then
			local nOrgCount = GetPlayerHonor(me.nId, PlayerHonor.HONOR_CLASS_LADDER3, 0);
			PlayerHonor:SetPlayerHonor(me.nId, PlayerHonor.HONOR_CLASS_LADDER3 , 0, nOrgCount + nCount);
			Dialog:Say("Đã nộp "..nCount.." Xích Dạ Phi Tinh, tổng cộng trên bảng xếp hạng là "..(nOrgCount+nCount).." Xích Dạ Phi Tinh.");
			me.Msg("Đã nộp "..nCount.." Xích Dạ Phi Tinh, tổng cộng trên bảng xếp hạng là "..(nOrgCount+nCount).." Xích Dạ Phi Tinh.");
			
			-- 数据埋点
			StatLog:WriteStatLog("stat_info", "keyimen_battle", "chip_collect", me.nId, nCount);
		end
	end
end

function tbTrader:GetFragmentBack(nStep)
	local nCurTime = GetTime();
	local nWeekDay	= tonumber(os.date("%w", nCurTime));
	local nDayTime = Lib:GetLocalDayTime(nCurTime);
	
	-- 星期天21: 30之后到星期一21:30之前
	if not ((nWeekDay == 0 and nDayTime > Keyimen.SECONDS_PAST) or 
		(nWeekDay == 1 and nDayTime < Keyimen.SECONDS_PAST)) then
		Dialog:Say("Từ 21:30 Chủ nhật đến 21:30 hôm sau là thời gian để nhận lại Xích Dạ Phi Tinh nếu không lọt Top 5 bảng xếp hạng.");
		return;
	end
		
	local nHonor = PlayerHonor:GetPlayerHonor(me.nId, PlayerHonor.HONOR_CLASS_LADDER3, 0);
	if nHonor <= 0 then
		Dialog:Say("Ngươi không có gì để lấy lại!");
		return;
	end
	
	local nMyRank = PlayerHonor:GetPlayerHonorRank(me.nId, PlayerHonor.HONOR_CLASS_LADDER3, 0);
	if nMyRank < Keyimen.GET_FRANG_RANK_LIMIT then
		Dialog:Say("Chỉ những ai không lọt vào Top 5 mới có thể nhận lại.");
		return;
	end
	
	nStep = nStep or 0;	
	if nStep == 0 then
		
		local szMsg = string.format("Ngươi đã nộp %d Xích Dạ Phi Tinh , ngươi muốn lấy lại đúng chứ?", nHonor);
		local tbOpt = 
		{
			{"Xác nhận", self.GetFragmentBack, self, 1},
			{"Để ta suy nghĩ thêm"},
		}
		Dialog:Say(szMsg, tbOpt);
		
	else			
			
		local tbInfo = {unpack(Keyimen.FRANGMENT_GDPL)};
		table.insert(tbInfo, {});
		table.insert(tbInfo, nHonor);	
		
		local tbItemInfo = KItem.GetOtherBaseProp(unpack(tbInfo, 1, 4));
		local nNeedCell = math.ceil(nHonor/tbItemInfo.nStackMax);
		local nFreeCell = me.CountFreeBagCell();
		if nNeedCell > nFreeCell then
			Dialog:Say(string.format("Hành trang không đủ %d ô trống.", nNeedCell));
			return;
		end
		
		-- 清零, 然后领道具
		PlayerHonor:SetPlayerHonor(me.nId, PlayerHonor.HONOR_CLASS_LADDER3 , 0, 0);

		local nCount = me.AddStackItem(unpack(tbInfo));
		if nCount ~= nHonor then
			Dbg:WriteLog("chiyefeiling", "角色名:"..me.szName, "帐号:"..me.szAccount, 
				"领取赤夜飞翎数量不足,应领"..nHonor.."个, 实领"..nCount.."个.");
		end
		
	end
end

function tbTrader:ViewLadder()
	me.CallClientScript({"Ui:ApplyOpenSelectedLadder", Ladder.LADDER_CLASS_LADDER, Ladder.LADDER_TYPE_LADDER_ACTION, Ladder.LADDER_TYPE_LADDER_ACTION_LADDER3});
end

function tbTrader:GetHorse()
	local nHorseOwnerId = KGblTask.SCGetDbTaskInt(DBTASK_NEW_HORSE_OWNER);
	local szOwner = KGblTask.SCGetDbTaskStr(DBTASK_NEW_HORSE_OWNER);
	-- 以后都应该直接取角色名字, 这时taskint里面应该是0
	if szOwner ~= "" and szOwner ~= me.szName then
		Dialog:Say("Không có gì để nhận cả.");
		return;
	end
	
	-- 之前的设计错误, 导致这里可能存放了玩家ID, 因此这个值还是要再判断的
	-- TODO: 若干周之后, 情况稳定了, 这段判断ID的逻辑应当要去掉
	-- szOwner为空时才需要去检查ID, 因为设置szOwner时必会将ID清0
	if szOwner == "" and nHorseOwnerId ~= me.nId then
		Dialog:Say("Không có gì để nhận cả.");
		return;
	end
		
	if me.CountFreeBagCell() <= 0 then
		Dialog:Say("Hành trang không đủ khoảng trống!");
		return;
	end
	
	local pHorse = me.AddItem(unpack(Keyimen.NEW_HORSE_GDPL));
	if pHorse then
		pHorse.SetTimeOut(0, GetTime() + Keyimen.NEW_HOESE_VALID_TIME);	-- 绝对时间, 从领的时刻起计时, 7日内有效
		pHorse.Sync();
		KGblTask.SCSetDbTaskInt(DBTASK_NEW_HORSE_OWNER, 0);	-- 置0
		KGblTask.SCSetDbTaskStr(DBTASK_NEW_HORSE_OWNER, ""); -- 置空
	end
end

function tbTrader:ExchangeEqToCurrency(nType, tbItemObj)
	nType = nType or 0;
	if nType == 0 then
		local szMsg = "Đặt vào Trang bị Long Hồn chưa cường hóa, mỗi Trang bị Long Hồn sẽ hoàn lại "..Item.EQUIP_TO_CURRENCY_RATE.."% Long Văn Ngân Tệ đã mua";
		Dialog:OpenGift(szMsg, {"Item:ExchangeEqToCurrency_CheckGiftItem"}, {self.ExchangeEqToCurrency, self, 1});
		return 0;
	end
	
	if me.CountFreeBagCell() <= 0 then
		me.Msg("Hành trang không đủ chỗ trống!");
		return 0;
	end

	if nType == 1 then
		local nRetCurrency = 0;
		local bHaveInvalidItem = 0;
		for _, tbItem in pairs(tbItemObj or {}) do
			local pItem = tbItem[1];
			if (pItem.IsExEquip() ~= 1 or pItem.nEnhTimes ~= 0) then
				me.Msg("Chỉ có thể đặt vào Trang bị Long Hồn chưa cường hóa!");
				bHaveInvalidItem = 1;
				break;
			end
			
			if pItem.IsEquipHasStone() == 1 then
				me.Msg("Không đặt trang bị đã khảm nạm bảo thạch.");
				return 0;
			end
			
			nRetCurrency = nRetCurrency + math.floor(pItem.nPrice * Item.EQUIP_TO_CURRENCY_RATE / 10000);
		end
		
		if bHaveInvalidItem == 1 or nRetCurrency == 0 then
			return 0;
		end
		
		local szMsg = string.format("Trang bị Long Hồn này sẽ được hoàn lại %d Long Văn Ngân Tệ, ngươi chắc chứ?", nRetCurrency);
		local tbOpt = 
		{
			{"Xác nhận", self.ExchangeEqToCurrency, self, 2, tbItemObj},
			{"Để ta suy nghĩ thêm"},
		}
		Dialog:Say(szMsg, tbOpt);
	end
	
	if nType == 2 then
		local nCurrencyCount = 0;
		for _, tbItem in pairs(tbItemObj or {}) do
			local pItem = tbItem[1];
			if (pItem.IsExEquip() == 1 and pItem.nEnhTimes == 0 and pItem.IsEquipHasStone() == 0) then
				local nRetCount = math.floor(pItem.nPrice * Item.EQUIP_TO_CURRENCY_RATE / 10000);
				if me.DelItem(pItem, Player.emKLOSEITEM_LONGEQUIP_EXCHANGE) == 1 then
					nCurrencyCount = nCurrencyCount + nRetCount;
				end
			end
		end
		
		local tbInfo = {unpack(Item.tbLonghunCurrencyItemId)};
		tbInfo[5] = nil;
		tbInfo[6] = nCurrencyCount;
		local nCount = me.AddStackItem(unpack(tbInfo));
		if nCurrencyCount ~= nCount then
			Dbg:WriteLog("龙魂装备兑换龙纹银币", "角色名:"..me.szName, "帐号:"..me.szAccount, 
				"理应领取银币: "..nCurrencyCount..", 实际获得银币: "..nCount);
		end
	end
end

function tbTrader:CheckPermission(tbOption)
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang bị khóa, không thể thao tác!");
		Account:OpenLockWindow(me);
		return;
	end
	Lib:CallBack(tbOption);
end

-- 购买装备
function tbTrader:BuyEquip()
	
	local nCamp = Keyimen.MAP_LIST[him.nMapId];
	if not nCamp or nCamp <= 0 then
		Dialog:Say("Có vẻ như ngươi đến nhầm chỗ rồi!");
		return 0;
	end
	
	local szMsg = "    Bây giờ chiến sự mặt trận căng thẳng, đội quân của chúng ta rất cần những người dũng cảm và thiện chiến. Đây là những trang bị cực phẩm, hy vọng sẽ được thưởng cho những người dũng cảm giết tiêu diệt kẻ thù."
	local tbOpt = 
	{
		{"<color=yellow>Tinh chú trang bị Long Hồn<color>", self.CheckPermission, self, {me.OpenEnhance, Item.ENHANCE_MODE_CAST, Item.BIND_MONEY}},
		{"<color=yellow>Đổi danh vọng<color>", self.ExchangeRepute, self},	
		{"<color=yellow>Đổi Long Văn Ngân Tệ<color>", self.CheckPermission, self, {self.ExchangeEqToCurrency, self}},
		{"<color=green>Long Hồn Hiệp Ảnh-Trang bị<color>", self.DoBuyEquip, self, 1},
		{"<color=green>Long Hồn-Chiến Y<color>", self.DoBuyEquip, self, 2},
		{"<color=green>Long Hồn-Giới Chỉ<color>", self.DoBuyEquip, self, 3},
		{"<color=green>Long Hồn-Hộ Phù<color>", self.DoBuyEquip, self, 4},
		{"Ta hiểu rồi"},
	};
	
	Dialog:Say(szMsg, tbOpt);
end

function tbTrader:ExchangeRepute()
	Dialog:OpenGift(Item:ExChangeLongHun_GetInitMsg(), {"Item:ExChangeLongHun_CheckGiftItem"}, {Item.ExChangeLongHun_OnOK, Item});
end

function tbTrader:DoBuyEquip(nType)
	local tbType = {229, 230, 231, 232};
	if not tbType[nType] then
		return 0;
	end
	me.OpenShop(tbType[nType], 3);
end
-------------------------------------------------------

-- 战场医师
local tbSeller = Npc:GetClass("keyimen_npc_seller");

function tbSeller:OnDialog()
	local szMsg = "    Tiệm thuốc: Hiệp sĩ này, đến nơi chiến tranh này thì phải chuẩn bị nhiều thuốc cho bất cứ trường hợp nào!";
	local tbOpt = 
	{
		{"<color=yellow>[Bạc khóa] Ta muốn mua dược phẩm<color>", self.OnBuyYaoBind, self},
		{"<color=yellow>[Bạc khóa] Ta muốn mua thực phẩm<color>", self.OnBuyCaiBind, self},
		{"Ta muốn mua dược phẩm", self.OnBuyYao, self},
		{"Ta hiểu rồi"},
	};
	Dialog:Say(szMsg, tbOpt);		
end

-- 买药
function tbSeller:OnBuyYaoBind()
	me.OpenShop(14,7);
end

function tbSeller:OnBuyYao()
	me.OpenShop(14,1);
end

-- 买菜
function tbSeller:OnBuyCaiBind()
	me.OpenShop(21,7);
end
