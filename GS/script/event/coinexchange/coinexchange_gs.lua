-- 文件名　：coinexchange.lua
-- 创建者　：xiewen
-- 创建时间：2009-02-16 15:17:18
-- 功能：绑银兑换银两

Require("\\script\\event\\coinexchange\\coinexchange_def.lua")

-- GS
function CoinExchange:CheckOnlinePayer_GS()
	local nOnlinePayer = CountOnlinePayer(15)		-- 获得在线的付费用户数
	if nOnlinePayer then
		GCExcute{"CoinExchange:CheckOnlinePayer_GC", nOnlinePayer}
	end
end

function CoinExchange:ExchangePayerMaxIsSusscess(nPlayerId, nSuccess)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return 0;
	end
	if nSuccess == 1 then
		CoinExchange:Exchange(pPlayer, 1)
	else
		Setting:SetGlobalObj(pPlayer);
		Dialog:Say("Tuần này bạn đã đổi rồi.");
		Setting:RestoreGlobalObj();
	end
	return 0;
end


-- 是否可以兑换 -1尚未排序，0已兑换，1可兑换
function CoinExchange:CanExchange(pPlayer)
	if pPlayer.IsAccountLock() ~= 0 then
		return 0, "Tài khoản đang khóa, không thể thao tác";
	end
	local nPrestige = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_PRESIGE_RESULT);
	if nPrestige == 0 then
		return -1, "Hệ thống vẫn chưa sắp xếp bảng xếp hạng Uy danh."
	end

	if nPrestige < self.MIN_PRESTIGE then
		nPrestige = self.MIN_PRESTIGE
	end
	
	if nPrestige > pPlayer.nPrestige then
		return 0, "Uy danh của bạn chưa đủ "..nPrestige.." điểm, không thể đổi."
	end
	
	local nLastXchgWeek = pPlayer.GetTask(self.TASK_GROUP, self.TASK_XCHG_TIME)
	local nThisWeek = Lib:GetLocalWeek(GetTime()) + 1
	
	if nLastXchgWeek == nThisWeek then
		return 0, "Tuần này bạn đã đổi rồi, mỗi tuần chỉ có thể đổi 1 lần."
	end
	
	return 1, "Có thể đổi"
end


function CoinExchange:RefreshExchangeRate()
	if SpecialEvent:IsWellfareStarted_Remake() == 1 then
		self.ExchangeRate = self.__ExchangeRate_wellfare;
	else
		self.ExchangeRate = self.__ExchangeRate;
	end
end

function CoinExchange:Exchange(pPlayer, Susscess)
	Setting:SetGlobalObj(pPlayer);
	local nErr, szErr = self:CanExchange(pPlayer)
	if nErr == 1 then
		if not Susscess then
			GCExcute({"CoinExchange:CheckExchangePayerMax_GC", pPlayer.nId, 1});
			Setting:RestoreGlobalObj();
			return 0;
		end
		
		if pPlayer.GetBindMoney() < self.ExchangeAmount then			
			Dialog:Say("Số bạc trong người không đủ "..self.ExchangeAmount.." bạc, không thể đổi")
			Setting:RestoreGlobalObj()
			return
		end
		
		if self.ExchangeAmount * self.ExchangeRate + pPlayer.nCashMoney > pPlayer.GetMaxCarryMoney() then
			Dialog:Say("Lượng bạc mang theo trên người vượt quá giới hạn. Hãy sắp xếp lại rồi đến đổi lại.")
			Setting:RestoreGlobalObj()
			return
		end

		if pPlayer.CostBindMoney(self.ExchangeAmount, Player.emKBINDMONEY_COST_EXCHANGE) == 1 then
			local nRank = PlayerHonor:GetPlayerHonorRank(pPlayer.nId, PlayerHonor.HONOR_CLASS_WEIWANG, 0);
			if nRank <= 0 or nRank > self.nMaxLimitRank then
				GCExcute({"CoinExchange:AddExchangePayerMax_GC", });
			end
			local nThisWeek = Lib:GetLocalWeek(GetTime()) + 1
			pPlayer.SetTask(self.TASK_GROUP, self.TASK_XCHG_TIME, nThisWeek)
	
			local nAddCount = self.ExchangeAmount * self.ExchangeRate;
			pPlayer.Earn(nAddCount, Player.emKEARN_EXCHANGE_BIND)
			KStatLog.ModifyAdd("jxb", "[产出]绑银兑换", "总量", nAddCount);
			KStatLog.ModifyAdd("bindjxb", "[消耗]兑换银两", "总量", self.ExchangeAmount);
			KStatLog.ModifyAdd("mixstat", "[统计]绑银兑换银两人数", "总量", 1);
			Dialog:Say("Bạn đôi thành công "..self.ExchangeAmount * self.ExchangeRate.." bạc.")
			
			-- 记录玩家兑换银两的次数
			Stats.Activity:AddCount(pPlayer, Stats.TASK_COUNT_COINEX, 1);
			
			Setting:RestoreGlobalObj()
		else
			Dialog:Say("Đổi thất bại, không thể trừ số bạc đã qui định");
			Setting:RestoreGlobalObj()
		end
	else
		Dialog:Say(szErr)
		Setting:RestoreGlobalObj()
	end	
end

local tbCoinExchange = {}
SpecialEvent.CoinExchange = tbCoinExchange

function tbCoinExchange:OnDialog()
	CoinExchange:RefreshExchangeRate();
	
	local nPrestige = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_PRESIGE_RESULT)
	if nPrestige <= 0 then
		Dialog:Say("Hãy đợi Hệ thống cập nhật bảng xếp hạng rồi hãy đến gặp ta.")
		return 0
	end
	
	if nPrestige < CoinExchange.MIN_PRESTIGE then
		nPrestige = CoinExchange.MIN_PRESTIGE
	end
	
	local szMsg = "  Người chơi đủ điều kiện có thể đổi <color=red>" .. CoinExchange.ExchangeAmount ..
		" bạc khóa<color> thành <color=red>" .. CoinExchange.ExchangeAmount * CoinExchange.ExchangeRate ..
		" bạc thường<color>. Uy danh của bạn cần đạt <color=green>" .. nPrestige ..
		" điểm<color>. Quyền lợi chỉ được nhận 1 lần trong tuần, không cộng dồn sang tuần tiếp theo và số lượng có hạn. Hãy đổi càng sớm càng tốt."
	local tbOpt = {
		{"Xác nhận đổi", self.OnDialog2, self},
		{"Để ta suy nghĩ lại"},
		}
	Dialog:Say(szMsg, tbOpt)
end

function tbCoinExchange:OnDialog2()
	CoinExchange:Exchange(me);
end
