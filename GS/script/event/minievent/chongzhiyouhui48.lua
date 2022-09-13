--充值优惠领取，本月充值满48元
--sunduoliang
--2008.10.30

SpecialEvent.ChongZhiYouHui48 = {};
local tbChongZhi = SpecialEvent.ChongZhiYouHui48;

tbChongZhi.tbItem = 
{
	[1] = {szName="无限传送符（1个月）", nTaskGroup=2038, nTaskId = 7, tbItem = {18,1,195,1}, nLimiTime = 30};
	[2] = {szName="乾坤符（10次）", nTaskGroup=2038, nTaskId = 8, tbItem = {18,1,85,1}};
}

function tbChongZhi:Dialog()
--	local szPayMsg = "";
--	if IVER_g_nSdoVersion == 0 then
--		szPayMsg = string.format("您本月累计充值<color=yellow>%s%s<color>", me.GetExtMonthPay(), IVER_g_szPayUnit);
--	end
--	local szMsg = string.format([[活动推广员：%s累计%s满<color=red>%s<color>，可获得如下额外优惠：
--	<color=yellow>
--	每天1次额外的祈福机会<color>
--	  （自动获得）<color=yellow>	
--	每天额外领取30分钟4倍<color>
--	  （修炼珠领取）<color=yellow>
--	1个无限传送符（1个月）<color>
--	  （在充值特权可以快速获得）<color=yellow>
--	1个乾坤符（10次）<color>
--	  （在充值特权可以快速获得）
--
--	%s
--	请选择符合的充值方式进行充值（详情可查看官网活动说明），才能领取礼品]], IVER_g_szPayMonth, IVER_g_szPayName, IVER_g_szPayLevel2, szPayMsg);
--	
--	local tbOpt = 
--	{
--		{"领取无限传送符（1月）", self.GetItem, self, 1},
--		{"领取乾坤符（10次）", self.GetItem, self, 2},
--		{"Ta hiểu rồi"},
--	}
--	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
--	if nCurDate >= Esport.SNOWFIGHT_STATE[4] and nCurDate < Esport.SNOWFIGHT_STATE[5] then
--		table.insert(tbOpt, 1, {string.format("<color=gold>领取新年%s礼物<color>", IVER_g_szPayName), self.GetNewYear, self});
--	end
--	if nCurDate < 20090228 then
--		table.insert(tbOpt, 1, {"领取强化费用减少祝福", self.GetZhufu, self});
--	end
--	
--	Dialog:Say(szMsg, tbOpt);                   
	me.CallClientScript({"UiManager:OpenWindow", "UI_FULITEQUAN"});
end

function tbChongZhi:GetZhufu()

		if (me.nPrestige < 50) and (me.nMonCharge < 15) then	--江湖威望不低于50或者当月充值不低于15元
			local szMsg = "江湖威望必须达到<color=yellow>50点<color>或本月累计充值达到<color=yellow>15元<color>。";
			Dialog:Say(szMsg);
			return 0;
		end
		
		local nT = GetTime();
		local nTime = 5*24*3600;
		local nD = tonumber(os.date("%y%m%d%H%M",nT));
		local nTkD = me.GetTask(2027,23);
		if nTkD >= 902170000 then
			if tonumber(os.date("%y%m%d%H%M",(nT-nTime))) < nTkD and me.GetSkillState(892) <= 0 then
				me.AddSkillState(892, 1, 1, nTime*18, 1, 0, 1);
				return 0;
			end
			Dialog:Say("活动推广员：您已领取过祝福了。");
			return 0;
		end
		me.SetTask(2027, 23, nD);
		me.AddSkillState(892, 1, 1, nTime*18, 1, 0, 1);
		Dialog:Say("急急如律令，太上老君快显灵……（突然我感觉到我体内充满了力量）。恭喜你，祝福祷告完成了。");
		return 0;	
end

function tbChongZhi:GetNewYear(nSure)
	if nSure == 1 then
		if me.nLevel < 50 then
			Dialog:Say("活动推广员：您等级未达到50级，不能领取。");
			return 0;
		end
		
		if me.GetExtMonthPay() < 15 then
			Dialog:Say("活动推广员：您本月充值累计未够15元，不能领取。");
			return 0;
		end
		
		local nTaskGetCount = me.GetTask(Esport.TSK_GROUP, Esport.TSK_NEWYEAR_LIANHUA)
		if me.GetExtMonthPay() < 48 and nTaskGetCount >= 2 then
			Dialog:Say("活动推广员：您本月充值累计不足48元，但本月累计充值达到了15元，已领取过了两朵红粉莲花。");
			return 0;
		end
		if me.GetExtMonthPay() >= 48 and nTaskGetCount >= 5 then
			Dialog:Say("活动推广员：您本月累计充值达到了48元，已领取过了五朵红粉莲花。");
			return 0;
		end
		local nCanGetCount = 2;
		if me.GetExtMonthPay() >= 48 then
			nCanGetCount = 5 - nTaskGetCount;
		end

		if me.CountFreeBagCell() <= nCanGetCount then
			Dialog:Say(string.format("活动推广员：您的背包空间不足，需要%s格背包空间。", nCanGetCount));
			return 0;
		end
		
		for i=1,nCanGetCount do
			local pItem = me.AddItem(unpack(Esport.SNOWFIGHT_ITEM_EXCOUNT));
			if pItem then
				pItem.Bind(1);
				me.SetTask(Esport.TSK_GROUP, Esport.TSK_NEWYEAR_LIANHUA, me.GetTask(Esport.TSK_GROUP, Esport.TSK_NEWYEAR_LIANHUA) + 1)
			end
		end
		Dialog:Say("成功领取了新年充值礼物。");
		return 0;
	end
	
	if nSure == 2 then
		if me.nLevel < 50 then
			Dialog:Say("活动推广员：您等级未达到50级，不能领取。");
			return 0;
		end
		
		if me.GetExtMonthPay() < 48 then
			Dialog:Say("活动推广员：您本月充值累计未够48元，不能领取。");
			return 0;
		end
		local nT = GetTime();
		local nTime = 5*24*3600;
		local nD = tonumber(os.date("%y%m%d%H%M",nT));
		local nTkD = me.GetTask(2027,23);
		
		if nTkD >= (math.mod(Esport.SNOWFIGHT_STATE[4], 1000000) * 10000) then
			if tonumber(os.date("%y%m%d%H%M",(nT-nTime))) < nTkD and me.GetSkillState(892) <= 0 then
				me.AddSkillState(892, 1, 1, nTime*18, 1, 0, 1);
				return 0;
			end
			Dialog:Say("活动推广员：您已领取过祝福了。");
			return 0;
		end
		me.SetTask(2027, 23, nD);
		me.AddSkillState(892, 1, 1, nTime*18, 1, 0, 1);
		Dialog:Say("急急如律令，太上老君快显灵……（突然我感觉到我体内充满了力量）。恭喜你，新年祝福祷告完成了。");
		return 0;
	end
	local szMsg = "新年充值送礼！\n 1.如果本月累计充值达到15元，将会获得2朵红粉莲花，充值累计达到48元，将会获得5朵红粉莲花;\n\n 2.充值累计达到48元可领取新年强化费用降低的祝福，祝福效果持续五天; \n\n<color=yellow>活动时间：2009年1月21日－2009年1月31日<color> \n\n要领取礼物吗？";
	local tbOpt = {
		{"确定领取红粉莲花", self.GetNewYear, self, 1},
		{"确定领取祝福", self.GetNewYear, self, 2},
		{"Ta chỉ xem qua thôi"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbChongZhi:GetItem(nChose)
	local nCurDate = tonumber(GetLocalDate("%y%m%d"));
--	if me.nLevel < 80 then
--		Dialog:Say("活动推广员：您等级未达到80级，不能领取。");
--		return 0;
--	end
	if me.GetExtMonthPay() < IVER_g_nPayLevel2 then
		Dialog:Say(string.format("活动推广员：您当%s不足%s，不能领取。", IVER_g_szPayName, IVER_g_szPayLevel2));
		return 0;		
	end
	--修复记录bug，因之前已记录了ymd,所以只能使用此方法修正错误。
	if math.floor(me.GetTask(self.tbItem[nChose].nTaskGroup, self.tbItem[nChose].nTaskId)/100) >= math.floor(nCurDate/100) then
		Dialog:Say("活动推广员：您当月已领取过本物品。");
		return 0;
	end
	if me.CountFreeBagCell() <= 0 then
		Dialog:Say("活动推广员：您的背包空间不足。");
		return 0;
	end
	local pItem = me.AddItem(unpack(self.tbItem[nChose].tbItem));
	if pItem then
		pItem.Bind(1);
		if self.tbItem[nChose].nLimiTime then
			me.SetItemTimeout(pItem, os.date("%Y/%m/%d/%H/%M/%S", GetTime() + self.tbItem[nChose].nLimiTime * 24 * 3600), 0);
		end
		me.SetTask(self.tbItem[nChose].nTaskGroup, self.tbItem[nChose].nTaskId, nCurDate)
		Dbg:WriteLog("SpecialEvent.ChongZhiYouHui48", "获得物品：".. self.tbItem[nChose].szName, "角色名:"..me.szName, "帐号:"..me.szAccount);
	end
	Dialog:Say(string.format("活动推广员：成功领取了一个<color=yellow>%s<color>", self.tbItem[nChose].szName));
end

-- 外部调用，直接领取充值福利
-- nChose, 要领取的东西， 0： 无限传送符，1：乾坤符
-- 成功返回1和提示信息，失败返回0和错误信息
function tbChongZhi:GetItemEx(nChose)
	local nCurDate = tonumber(GetLocalDate("%y%m%d"));
	if me.GetExtMonthPay() < IVER_g_nPayLevel2 then
		return 0, string.format("您当月%s不足%s，不能领取。", IVER_g_szPayName, IVER_g_szPayLevel2);		
	end
	--修复记录bug，因之前已记录了ymd,所以只能使用此方法修正错误。
	if math.floor(me.GetTask(self.tbItem[nChose].nTaskGroup, self.tbItem[nChose].nTaskId)/100) >= math.floor(nCurDate/100) then
		return 0, "您当月已领取过本物品。";
	end
	if me.CountFreeBagCell() <= 0 then
		return 0, "Hành trang không đủ 。";
	end
	local pItem = me.AddItem(unpack(self.tbItem[nChose].tbItem));
	if pItem then
		pItem.Bind(1);
		if self.tbItem[nChose].nLimiTime then
			me.SetItemTimeout(pItem, os.date("%Y/%m/%d/%H/%M/%S", GetTime() + self.tbItem[nChose].nLimiTime * 24 * 3600), 0);
		end
		me.SetTask(self.tbItem[nChose].nTaskGroup, self.tbItem[nChose].nTaskId, nCurDate)
		Dbg:WriteLog("SpecialEvent.ChongZhiYouHui48", "获得物品：".. self.tbItem[nChose].szName, "角色名:"..me.szName, "帐号:"..me.szAccount);
	end
	
	return 1, string.format("您成功领取了一个<color=yellow>%s<color>。", self.tbItem[nChose].szName)
end

