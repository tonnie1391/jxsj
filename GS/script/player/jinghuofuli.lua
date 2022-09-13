-- 文件名　：jinghuofuli.lua
-- 创建者　：bigfly
-- 创建时间：2009-7-7 17:59:54
-- 文件说明：精活福利脚本

Require("\\script\\player\\player.lua");

local tbBuyJingHuo		= Player.tbBuyJingHuo or {};	-- 支持重载
Player.tbBuyJingHuo		= tbBuyJingHuo;

tbBuyJingHuo.MAX_JINGHUOCOUNT	= 10000;	-- 最多累积10000组
tbBuyJingHuo.DAY_GIVECOUNT		= 1;		-- 每天给1组
tbBuyJingHuo.MAX_BUY_FULIJINGHUO_COUNT = 8; -- 最多能累积购买福利精活的数量

tbBuyJingHuo.tbItem = 
{
	[1] = {nWareId=47, TASK_GROUPID=2024, TASK_ID1=9, TASK_ID2=10, TASK_EXBUY_COUNT_ID = 23, nUseMax=5, nCoin = 16, szTypeName = "Tinh Khí Tán (tiểu)", szDesValue="2500 Tinh lực", szDes="Tinh Lực Tán giảm 60% (tiểu) (5)", }; --小精气散
	[2] = {nWareId=48, TASK_GROUPID=2024, TASK_ID1=11, TASK_ID2=12, TASK_EXBUY_COUNT_ID = 24, nUseMax=5, nCoin = 16, szTypeName = "Hoạt Khí Tán (tiểu)", szDesValue="2500 Hoạt Lực", szDes="Hoạt Lực Tán giảm 60% (tiểu) (5)", }; --小活气散
}
tbBuyJingHuo.nLevelMax = 60;
tbBuyJingHuo.nTaskGroupId		= 2024;
tbBuyJingHuo.nTaskId_FirstOpen	= 25;

tbBuyJingHuo.tbWeekend = {
		[0] = 0,
		[1] = 6,
		[2] = 5,
		[3] = 4,
		[4] = 3,
		[5] = 2,
		[6] = 1,
		[7] = 0,
	};

-- 计算这段时间内有几个周末，首尾段时间都先算上
function tbBuyJingHuo:CalcWeekend(nStartDay, nEndDay)
	local nStartTime	= Lib:GetDate2Time(nStartDay);
	local nEndTime		= Lib:GetDate2Time(nEndDay);
	
	local nLastDay		= Lib:GetLocalDay(nStartTime);
	local nNowDay		= Lib:GetLocalDay(nEndTime);

	local nStartWeekday = tonumber(os.date("%w", nStartTime));
	local nEndWeekday	= tonumber(os.date("%w", nEndTime));

	local nDayDet		= nNowDay - nLastDay;

	local nWeekendCount	= 0;
	
	if (nDayDet <= 0) then
		return nWeekendCount;
	end
	
	local nDet			= self.tbWeekend[nStartWeekday];

	-- 如果在本周
	if (nDayDet <= nDet) then
		if (nEndWeekday == 0) then
			nWeekendCount = 2;
		elseif (nEndWeekday == 6) then
			nWeekendCount = 1;
		end
	else
		nWeekendCount = math.floor((nDayDet - self.tbWeekend[nStartWeekday]) / 7) * 2;
		local nMod = math.fmod((nDayDet - self.tbWeekend[nStartWeekday]), 7);
		if (nMod > 0) then
			if (nEndWeekday == 6) then
				nWeekendCount = nWeekendCount + 1;
			end
		end
		if (nStartWeekday <= 6 and nStartWeekday > 0) then
			nWeekendCount = nWeekendCount + 2;
		elseif (nStartWeekday == 0) then
			nWeekendCount = nWeekendCount + 1;
		end
	end

	return nWeekendCount;
end

function tbBuyJingHuo:BuyItem(nType, nBuyCount, nFlag)
	local nPrestigeKe = KGblTask.SCGetDbTaskInt(DBTASK_JINGHUOFULI_KE);
	local nPrestige = self:GetTodayPrestige();
	if nPrestigeKe > 0 then
		nPrestige = nPrestigeKe;
	end
	if nPrestige <= 0 then
		Dialog:Say("Vẫn chưa sắp xếp uy danh toàn khu, nên chưa có ưu đãi, đợi sau khi xếp hạng rồi hãy quay lại");
		return 0;
	end
	
	if (me.IsInPrison() == 1) then
		Dialog:Say("Trong Thiên Lao không thể nhận phúc lợi.");
		return 0;
	end		

	if me.nLevel < self.nLevelMax then
		Dialog:Say("Đạt cấp 60 mới được nhận phúc lợi.");
		return 0;
	end
	
--	--排名判断
--	if me.nPrestige < nPrestige then
--		Dialog:Say("你的江湖威望不足<color=red>"..nPrestige.."点<color>，不能购买优惠的"..tbItem.szTypeName);
--		return 0;
--	end

	local tbItem = self.tbItem[nType];	
	if me.nPrestige >= nPrestige then
		self:UpdateFuliCount(me, nType);
	end
	
	local nOrgCount = self:GetOrgJingHuoCount(me, nType);
	local nExCount = self:GetExJingHuoBuyCount(me, nType);
	local nNum = nBuyCount * tbItem.nUseMax;
	
	if (nBuyCount <= 0) then
		Dialog:Say(string.format("Không có số lượng để mua."));
		return 0;
	end

	local nCheckFlag = self:CheckBuyState(me, nType);
	if (2 == nCheckFlag) then
		local szMsg = string.format("Bạn chưa đủ tư cách để mua tinh hoạt phúc lợi. Tối thiểu 60 Uy danh.\n\nHiện tại bạn còn thiếu %s Uy danh.", nPrestige - me.nPrestige);
		local tbOpt = {
				-- {"Mở [Kỳ Trân Các] mua <color=yellow>Lệnh Bài Uy Danh<color>", self.OpenQiZhenge, self},
				{"Để ta suy nghĩ thêm"},
			};
			
		-- if (SpecialEvent.ChongZhiRepute:CheckISCanGetRepute() == 0) then
			-- if (SpecialEvent.ChongZhiRepute:CheckIsSetExt() ~= 1) then
				-- table.insert(tbOpt, 1, {"Kích hoạt nhân vật nhận uy danh", SpecialEvent.ChongZhiRepute.OnJiHuoGetRepute, SpecialEvent.ChongZhiRepute});
			-- end
		-- else
			-- if me.nLevel >= 60 then
				-- local nResultRepute, nSumRepute = SpecialEvent.ChongZhiRepute:Check2();
				-- if (nResultRepute < 0) then
					-- table.insert(tbOpt, 1, {"充值获得每周福利精活领取资格", self.OpenChongZhi, self});
				-- elseif (nResultRepute == 0) then
					-- if (me.GetExtMonthPay() < IVER_g_nPayLevel2) then
						-- table.insert(tbOpt, 1, {"充值获得每周福利精活领取资格", self.OpenChongZhi, self});
					-- end					
				-- elseif (nResultRepute > 0) then
					-- if (me.GetExtMonthPay() < IVER_g_nPayLevel2) then
						-- table.insert(tbOpt, 1, {"充值获得每周福利精活领取资格", self.OpenChongZhi, self});
					-- end
					-- table.insert(tbOpt, 1, {"领取本周充值江湖威望", SpecialEvent.ChongZhiRepute.OnDialog, SpecialEvent.ChongZhiRepute});
				-- end
			-- end
		-- end
		Dialog:Say(szMsg, tbOpt);
		return 0;
	elseif (0 == nCheckFlag) then
		Dialog:Say(string.format("Bạn không còn lượt mua hôm nay."));
		return 0;
	end
	
	if nOrgCount + nExCount <= 0 then
		Dialog:Say(string.format("Bạn không còn lượt mua hôm nay."));
		return 0;
	end

	if (nBuyCount > nOrgCount + nExCount) then
		Dialog:Say(string.format("Số lượng bạn mua vượt quá số lượng cho phép."));
		return 0;
	end

	if not nFlag then 
		Dialog:Say(string.format("Bạn có chắc chắn mua <color=yellow>%s<color> <color=yellow>%s<color>?", nNum, tbItem.szTypeName),{{"Xác nhận", self.BuyItem, self, nType, nBuyCount, 1},{"Để ta suy nghĩ lại"}});
		return 0;
	end
	
	if IVER_g_nSdoVersion == 0 and me.GetJbCoin() < (tbItem.nCoin * nNum) then
		Dialog:Say(string.format("Không đủ đồng, mua %s %s cần %s đồng.", nNum, tbItem.szTypeName, tbItem.nCoin*nNum));
		return 0;
	end
	
	if me.CountFreeBagCell() < nNum then
		Dialog:Say(string.format("Túi không đủ chỗ, cần để trống %s ô.", nNum));
		return 0;	
	end
	me.ApplyAutoBuyAndUse(tbItem.nWareId, nBuyCount);
	if IVER_g_nSdoVersion == 0 then
		Dialog:Say(string.format("Ngươi đã mua thành công %s %s",nNum, tbItem.szTypeName));
	end
	local szLog = string.format("Đã mua thành công %s %s",nNum, tbItem.szTypeName);

	--统计玩家购买福利精活的次数（同一天购买精力和活力只计数1）
	Stats.Activity:AddCount(me, Stats.TASK_COUNT_FULIJINGHUO, nBuyCount, 1);

	-- 更新获取福利精活的时间
	Stats:UpdateGetFuliTime();
	Dbg:WriteLog("Player.tbBuyJingHuo", "Ưu đãi mua Tinh Hoạt", me.szAccount, me.szName, szLog);
	return 1;
end

function tbBuyJingHuo:OpenChongZhi()
	c2s:ApplyOpenOnlinePay();
end

function tbBuyJingHuo:OpenQiZhenge()
	me.CallClientScript({"UiManager:OpenWindow", "UI_IBSHOP"});
end

function tbBuyJingHuo:GetTodayPrestige()
	local nPrestige = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_PRESIGE_RESULT);
	return nPrestige;
end

function tbBuyJingHuo:OnLogin(bExchangeServer)
	if (bExchangeServer == 1) then
		return;
	end
	self:OpenBuJingHuo(me);
end

function tbBuyJingHuo:OpenBuJingHuo(pPlayer, nOpenType)
	local nPrestigeKe = KGblTask.SCGetDbTaskInt(DBTASK_JINGHUOFULI_KE);
	local nPrestige = self:GetTodayPrestige()
	if nPrestigeKe > 0 then
		nPrestige = nPrestigeKe;
	end
	if (nPrestige <= 0) then
		return 0, "Vẫn chưa sắp xếp uy danh toàn khu, nên chưa có ưu đãi, đợi sau khi xếp hạng rồi hãy quay lại";
	end

	if (pPlayer.nLevel < self.nLevelMax) then
		return 0, "Đạt cấp 60 mới được nhận phúc lợi.";
	end

	if (pPlayer.nPrestige >= nPrestige) then
		for i, tbItem in pairs(self.tbItem) do
			self:UpdateFuliCount(pPlayer, i);
		end
	end
	if nOpenType == 3 then -- 福利特权界面更新精活次数
		return 0;
	end
	local nOpenWindow = 0;
	for i, tbItem in pairs(self.tbItem) do
		local nFlag = self:CheckBuyState(pPlayer, i);
		if (nFlag == 1) then
			nOpenWindow = 1;
			break;
		end
		
		if (nFlag == 2) then
			nOpenWindow = 2;
		end
	end
	
	if (not nOpenType or nOpenType ~=1) then
		if (pPlayer.GetTask(self.nTaskGroupId, self.nTaskId_FirstOpen) <= 0) then
			pPlayer.SetTask(self.nTaskGroupId, self.nTaskId_FirstOpen, 1);
			nOpenWindow = 1;
		end
	end

	if (nOpenWindow == 1) then
		KPlayer.CallAllClientScript({"GblTask:s2c_SetTask", DBTASD_EVENT_PRESIGE_RESULT, nPrestige});
		KPlayer.CallAllClientScript({"GblTask:s2c_SetTask", DBTASK_JINGHUOFULI_KE, nPrestigeKe});
		pPlayer.CallClientScript({"UiManager:OpenWindow", "UI_JINGHUOFULI"});
		return 1;
	elseif (nOpenWindow == 2) then
		return 2;
	end
	
	return 0, "Bạn không còn lượt mua hôm nay.";
end

function tbBuyJingHuo:CheckBuyState(pPlayer, nJinghuoType)
	local nFlag = 0;
	local nRefresh = 0;
	local tbItem = self.tbItem[nJinghuoType];
	
	local nOrgCount = self:GetOrgJingHuoCount(pPlayer, nJinghuoType);
	local nExCount = self:GetExJingHuoBuyCount(pPlayer, nJinghuoType);
	if (nOrgCount + nExCount > 0) then
		nFlag = 1;
	end
	
	local nLastDay = pPlayer.GetTask(tbItem.TASK_GROUPID, tbItem.TASK_ID1);
	local nNowDay =tonumber(GetLocalDate("%Y%m%d"));
	if (nLastDay >= nNowDay) then
		nRefresh = 1;
	end
	
	-- 通过礼官和修炼珠打开
	if (nFlag == 0) then
		if (nRefresh == 1) then
			return 0;
		else
			return 2;
		end
	end
	return 1;
end

function tbBuyJingHuo:UpdateFuliCount(pPlayer, nType)
	local tbItem = self.tbItem[nType];
	local nDay = pPlayer.GetTask(tbItem.TASK_GROUPID, tbItem.TASK_ID1);
	local nNowDay =tonumber(GetLocalDate("%Y%m%d"));
	if nNowDay > nDay then
		pPlayer.SetTask(tbItem.TASK_GROUPID, tbItem.TASK_ID1, nNowDay);
		pPlayer.SetTask(tbItem.TASK_GROUPID, tbItem.TASK_ID2, 0);
	end	
end

function tbBuyJingHuo:GetPillInfo()
	local tbPillInfo	= {};
	for nType, tbItem in ipairs(self.tbItem) do
		local nOrgCount = self:GetOrgJingHuoCount(me, nType);
		local nExCount = self:GetExJingHuoBuyCount(me, nType);
		tbPillInfo[nType]	= {
			tbItem.szDes,
			tbItem.nCoin * tbItem.nUseMax,
			tbItem.szDesValue,
			nOrgCount + nExCount,
		};
	end	
	return tbPillInfo;
end

function tbBuyJingHuo:OnDailyEvent_UpdateJingHuoUseCount(nDay)
	me.SetTask(self.nTaskGroupId, self.nTaskId_FirstOpen, 0);
	local nPrestigeKe = KGblTask.SCGetDbTaskInt(DBTASK_JINGHUOFULI_KE);
	local nPrestige = self:GetTodayPrestige()
	if nPrestigeKe > 0 then
		nPrestige = nPrestigeKe;
	end
	if (nPrestige <= 0) then
		return 0;
	end
	
	if (me.nPrestige < nPrestige) then
		return 0;
	end
	
	if (me.nLevel < self.nLevelMax) then
		return 0;
	end
	
	local nNowDay = tonumber(GetLocalDate("%Y%m%d"));
	for i, tbItem in pairs(self.tbItem) do
		local nAddCount = nDay - 1;
		if (nAddCount < 0) then
			nAddCount = 0;
		end
		
		-- 计算昨天未使用的次数
		local nTotalCount = me.GetTask(tbItem.TASK_GROUPID, tbItem.TASK_ID2);
		local nLastDay = me.GetTask(tbItem.TASK_GROUPID, tbItem.TASK_ID1);
		
		local nStartTime	= Lib:GetDate2Time(nLastDay);
		local nEndTime		= Lib:GetDate2Time(nNowDay);
		local nStartWeekday = tonumber(os.date("%w", nStartTime));
		local nEndWeekday	= tonumber(os.date("%w", nEndTime));

		if (nLastDay > 0) then
			local nWeekendCount = self:CalcWeekend(nLastDay, nNowDay);

			if (nStartWeekday == 6 or nStartWeekday == 0) then
				nWeekendCount = nWeekendCount - 1;
			end
			if (nEndWeekday == 6 or nEndWeekday == 0) then
				nWeekendCount = nWeekendCount - 1;
			end
			if (nWeekendCount < 0) then
				nWeekendCount = 0;
			end
	
			-- 如果没有购买过，且是昨天那么就将昨天的次数加到额外次数里
			if (nLastDay < nNowDay) then
				local nCount = math.floor(nTotalCount / 5);
				local nResult = 0;
				
				if (nStartWeekday == 0 or nStartWeekday == 6) then
					nResult = 2 - nCount;
				else
					nResult = 1 - nCount;
				end
				
				if (nResult < 0) then
					nResult = 0;
				end
				nAddCount = nAddCount + nResult;
			end
			
			-- 这里就是周末双倍
			if (nWeekendCount > 0) then
				nAddCount = nAddCount + nWeekendCount;
			end

		end

		local nLastCount = self:GetExJingHuoBuyCount(me, i);
		if (nLastCount + nAddCount > self.MAX_BUY_FULIJINGHUO_COUNT) then
			nAddCount = self.MAX_BUY_FULIJINGHUO_COUNT - nLastCount;
			if (nAddCount < 0) then
				nAddCount = 0;
			end
		end
		
		if (nAddCount > 0) then
			self:AddExJingHuoBuyCount(me, i, nAddCount);
			self:AddExUseCount(i, nAddCount * tbItem.nUseMax);
		end
		self:UpdateFuliCount(me, i); -- 跨天时计算当天精活福利
	end
end

-- 增加精活使用次数
function tbBuyJingHuo:AddExUseCount(nType, nCount)
	if (1 == nType) then
		Item:GetClass("jingqisan"):AddExUseCount(nCount);
	elseif (2 == nType) then
		Item:GetClass("huoqisan"):AddExUseCount(nCount);
	end
end

function tbBuyJingHuo:AddOrgJingHuoBuyCount(pPlayer, nType)
	local nCount = pPlayer.GetTask(self.tbItem[nType].TASK_GROUPID, self.tbItem[nType].TASK_ID2);
	pPlayer.SetTask(self.tbItem[nType].TASK_GROUPID, self.tbItem[nType].TASK_ID2, nCount + 5);
end

-- 原来记录玩家购买福利精活的标记是
function tbBuyJingHuo:GetOrgJingHuoCount(pPlayer, nType)
	-- 计算昨天未使用的次数
	local nTotalCount = pPlayer.GetTask(self.tbItem[nType].TASK_GROUPID, self.tbItem[nType].TASK_ID2);
	local nLastDay = pPlayer.GetTask(self.tbItem[nType].TASK_GROUPID, self.tbItem[nType].TASK_ID1);
	local nNowDay = tonumber(GetLocalDate("%Y%m%d"));
	local nLastTime	= Lib:GetDate2Time(nLastDay);
	local nLastWeek = tonumber(os.date("%w", nLastTime));
	
	local nCount = math.floor(nTotalCount / 5);
	local nResult = 0;
	
	if (nLastDay ~= nNowDay) then
		return 0;
	end
	
	if (nLastWeek == 0 or nLastWeek == 6) then
		nResult = 2 - nCount;
	else
		nResult = 1 - nCount;
	end
	
	if (nResult < 0) then
		nResult = 0;
	end	

	return nResult;
end

function tbBuyJingHuo:AddExJingHuoBuyCount(pPlayer, nType, nCount)
	local nOrgCount = pPlayer.GetTask(self.tbItem[nType].TASK_GROUPID, self.tbItem[nType].TASK_EXBUY_COUNT_ID);
	pPlayer.SetTask(self.tbItem[nType].TASK_GROUPID, self.tbItem[nType].TASK_EXBUY_COUNT_ID, nOrgCount + nCount);
end

function tbBuyJingHuo:DelExJingHuoBuyCount(pPlayer, nType, nCount)
	local nOrgCount = pPlayer.GetTask(self.tbItem[nType].TASK_GROUPID, self.tbItem[nType].TASK_EXBUY_COUNT_ID);
	local nDelCount = nOrgCount - nCount;
	if (nDelCount < 0) then
		nDelCount = 0;
	end
	pPlayer.SetTask(self.tbItem[nType].TASK_GROUPID, self.tbItem[nType].TASK_EXBUY_COUNT_ID, nDelCount);
end

function tbBuyJingHuo:GetExJingHuoBuyCount(pPlayer, nType)
	return pPlayer.GetTask(self.tbItem[nType].TASK_GROUPID, self.tbItem[nType].TASK_EXBUY_COUNT_ID);
end

if (MODULE_GAMESERVER) then
	PlayerSchemeEvent:RegisterGlobalDailyEvent({Player.tbBuyJingHuo.OnDailyEvent_UpdateJingHuoUseCount, Player.tbBuyJingHuo});
end
