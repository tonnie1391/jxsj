--优惠购买精活
--孙多良
--2008.09.22

Require("\\script\\player\\jinghuofuli.lua");

local tbBuyJingHuo = {};
SpecialEvent.BuyJingHuo = tbBuyJingHuo;

function tbBuyJingHuo:OnDialog(nType)
	local tbTaskJingHuo = {
		[2] = {TASK_GROUPID=2024, TASK_BOUGHT=26, szTypeName="Tinh Hoạt phúc lợi (trung)", szRank=100, nItemId=2},
		[3] = {TASK_GROUPID=2024, TASK_BOUGHT=27, szTypeName="Tinh Hoạt phúc lợi (đại)", szRank=50, nItemId=1},
	}
	
	if nType == 1 then
		local nFlag, szMsg = Player.tbBuyJingHuo:OpenBuJingHuo(me, 1);
		if (0 == nFlag) then
			Dialog:Say(szMsg);
		elseif (2 == nFlag) then
			local nPrestigeKe = KGblTask.SCGetDbTaskInt(DBTASK_JINGHUOFULI_KE);
			local nPrestige = Player.tbBuyJingHuo:GetTodayPrestige()
			if nPrestigeKe > 0 then
				nPrestige = nPrestigeKe;
			end
			
			local szMsg = string.format("Bạn chưa đủ tư cách để mua tinh hoạt phúc lợi. Tối thiểu 60 Uy danh.\n\nHiện tại bạn còn thiếu %s Uy danh.", nPrestige - me.nPrestige);
			local tbOpt = {
				{"Để ta suy nghĩ lại"},
			};
			Dialog:Say(szMsg, tbOpt);
		end
	else
		if KGblTask.SCGetDbTaskInt(DBTASK_WEIWANG_WEEK) ~= tonumber(GetLocalDate("%W")) then
			Dialog:Say("Bảng xếp hạng Uy danh tuần này vẫn chưa có!")
			return;
		end
		
		if me.CountFreeBagCell() < 2 then
			Dialog:Say("Hành trang không đủ 2 ô trống.")
			return;
		end
		
		local nWeiWangRank = GetPlayerHonorRankByName(me.szName, PlayerHonor.HONOR_CLASS_WEIWANG, 0);
		if 0 < nWeiWangRank and nWeiWangRank <= tbTaskJingHuo[nType].szRank then
			local szDate = tonumber(os.date("%Y%m%d", GetTime()));
			me.SetTask(tbTaskJingHuo[nType].TASK_GROUPID,tbTaskJingHuo[nType].TASK_BOUGHT,szDate)
			me.AddStackItem(18, 1, 1516, tbTaskJingHuo[nType].nItemId, {bForceBind = 1}, 1)
			me.AddStackItem(18, 1, 1517, tbTaskJingHuo[nType].nItemId, {bForceBind = 1}, 1)
			Dialog:Say("Nhận thành công!!!")
		else
			Dialog:Say("Thứ hạng Uy danh Giang hồ cần đạt tối thiểu đạt <color=yellow>Top "..tbTaskJingHuo[nType].szRank.."<color> mới có thể nhận "..tbTaskJingHuo[nType].szTypeName);
		end
	end
end

function tbBuyJingHuo:OpenChongZhi()
	c2s:ApplyOpenOnlinePay();
end

function tbBuyJingHuo:OpenQiZhenge()
	me.CallClientScript({"UiManager:OpenWindow", "UI_IBSHOP"});
end

--脚本购买精气药过渡物品
local tbItem = Item:GetClass("jingqisan_coin")
function tbItem:OnUse()
	if me.CountFreeBagCell() < 5 then
		me.Msg(string.format("Hành trang không đủ 5 ô trống"));
		Dbg:WriteLog("Player.tbBuyJingHuo", "优惠购买精活", me.szAccount, me.szName, "Hành trang không đủ chỗ trống，无法获得精气散。");		
		return 0;
	end

	if (Player.tbBuyJingHuo:GetOrgJingHuoCount(me, 1) > 0) then
		Player.tbBuyJingHuo:AddOrgJingHuoBuyCount(me, 1);
	else
		Player.tbBuyJingHuo:DelExJingHuoBuyCount(me, 1, 1);
	end
	
	local tbItemInfo = {bTimeOut=1};
	for i=1, 5 do
		local pItem = me.AddItemEx(18, 1, 89, 1, tbItemInfo)
		--不公告
		if pItem then
			pItem.Bind(1);
			local szDate = os.date("%Y/%m/%d/%H/%M/%S", GetTime() + 3600*24*30);
			me.SetItemTimeout(pItem, szDate);
			local szLog = string.format("自动使用获得了1个精气散");
			Dbg:WriteLog("Player.tbBuyJingHuo", "优惠购买精活", me.szAccount, me.szName, szLog);		
		end
	end

	KStatLog.ModifyAdd("mixstat", "[统计]购买福利精气散人数", "总量", 1);
	me.CallClientScript({"Ui:ServerCall", "UI_JINGHUOFULI", "RefreshCount"});
	return 1
end

--脚本购买活气药过渡物品
local tbItem = Item:GetClass("huoqisan_coin")
function tbItem:OnUse()
	if me.CountFreeBagCell() < 5 then
		me.Msg(string.format("Hành trang không đủ 5 ô trống"));
		Dbg:WriteLog("Player.tbBuyJingHuo", "优惠购买精活", me.szAccount, me.szName, "Hành trang không đủ chỗ trống，无法获得活气散。");		
		return 0;
	end	

	if (Player.tbBuyJingHuo:GetOrgJingHuoCount(me, 2) > 0) then
		Player.tbBuyJingHuo:AddOrgJingHuoBuyCount(me, 2);
	else
		Player.tbBuyJingHuo:DelExJingHuoBuyCount(me, 2, 1);
	end
	
	local tbItemInfo = {bTimeOut=1};
	--不公告
	for i=1, 5 do
		local pItem = me.AddItemEx(18, 1, 90, 1, tbItemInfo)
		if pItem then
			pItem.Bind(1);
			local szDate = os.date("%Y/%m/%d/%H/%M/%S", GetTime() + 3600*24*30);
			me.SetItemTimeout(pItem, szDate);
			local szLog = string.format("自动使用获得了1个活气散");
			Dbg:WriteLog("Player.tbBuyJingHuo", "优惠购买精活", me.szAccount, me.szName, szLog);
		end
	end

	KStatLog.ModifyAdd("mixstat", "[统计]购买福利活气散人数", "总量", 1);
	me.CallClientScript({"Ui:ServerCall", "UI_JINGHUOFULI", "RefreshCount"});
	return 1
end
