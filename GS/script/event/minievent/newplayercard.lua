--新手卡奖励,内测玩家真情反馈
--2008.09.27
--孙多良

local tbEvent = {};
SpecialEvent.NewPlayerCard = tbEvent;

tbEvent.TASK_GOURP_ID 		= 2027;	--任务变量组
tbEvent.TASK_REGISTER_ID	=	11;	--记录领取那种奖励类型
tbEvent.TASK_GET_TUIGUANGYUAN_AWARD = 69; --09新版剑侠世界推广员系统领奖标志

--新手卡领取奖励表，1级，10级，20级，30级，40级，50级，60级，69级
tbEvent.DEF_AWARD_NEWCARD = {
	{nLevel = 1, nTaskId=12, tbItem={{tbItem={18,1,23,1}, nNum=1, nDay=7}}, szSelect = "领取1级奖励"}, 				--无限回城符（1周）,1级
	{nLevel = 10, nTaskId=13, tbItem={{tbItem={18,1,85,1}, nNum=1, nDay=30}}, szSelect = "领取10级奖励"}, 				--乾坤符1张,10级
	{nLevel = 20, nTaskId=14, tbItem={{tbItem={18,1,71,2}, nNum=20,nDay=30}}, szSelect = "领取20级奖励"}, 				--大白驹丸20个,20级
	{nLevel = 30, nTaskId=15, tbItem={{tbItem={18,1,113,1}, nNum=1, nDay=30},{tbItem={18,1,2,2}, nNum=1, nDay=30}}, szSelect = "领取30级奖励"}, 	--传声海螺（10句）1个、金犀（2级）1个,30级
	{nLevel = 40, nTaskId=16, tbItem={{tbItem={18,1,1,4}, nNum=20, nDay=30}}, nBindCoin=2000, szSelect = "领取40级奖励"}, 							--4级玄晶20个、2000绑定金币,40级
	{nLevel = 50, nTaskId=17, tbItem={{tbItem={18,1,1,5}, nNum=20, nDay=30}}, nBindMoney=100000, szSelect = "领取50级奖励"}, 						--5级玄晶20个、100000绑定银两,50级
	{nLevel = 60, nTaskId=18, tbItem={{tbItem={18,1,1,6}, nNum=10, nDay=30}}, nBindMoney=200000, nPayLimit=15, szSelect = "领取60级奖励"}, 				--6级玄晶10个、200000绑定银两,60级,当月充值48元
	{nLevel = 69, nTaskId=19, tbItem={{tbItem={18,1,1,7}, nNum=10, nDay=30}}, nBindMoney=300000, nBindCoin=5000, nPayLimit=15, szSelect = "领取69级奖励"}, --7级玄晶10个、300000绑定银两、5000绑定金币,69级,当月充值48元
};

--推广员奖励表
tbEvent.DEF_AWARD_TUIGUANGYUAN = {
	{nLevel = 1, nTaskId=12, tbItem={{tbItem={18,1,23,1}, nNum=1, nDay=7}}, szSelect = "领取1级奖励"}, 				--无限回城符（1周）,1级
	{nLevel = 10, nTaskId=13, tbItem={{tbItem={18,1,85,1}, nNum=1, nDay=30}}, szSelect = "领取10级奖励"}, 				--乾坤符1张,10级
	{nLevel = 30, nTaskId=15, tbItem={{tbItem={18,1,113,1}, nNum=1, nDay=30}, {tbItem={18,1,2,2}, nNum=1, nDay=30}}, szSelect = "领取30级奖励"}, 	--传声海螺（10句）1个、金犀（2级）1个,30级
	{nLevel = 40, nTaskId=16, tbItem={{tbItem={18,1,286,4}, nNum=1, nDay=30}}, nBindCoin=2000, szSelect = "领取40级奖励"}, 							--4级玄晶20个、2000绑定金币,40级
	{nLevel = 50, nTaskId=17, tbItem={{tbItem={18,1,286,5}, nNum=1, nDay=30}, {tbItem={18,1,287,2}, nNum=1, nDay=30}}, nBindMoney=100000, szSelect = "领取50级奖励"}, --5级玄晶20个、100000绑定银两,50级, 大白驹丸20个
	{nLevel = 60, nTaskId=18, tbItem={{tbItem={18,1,286,6}, nNum=1, nDay=30}}, nBindMoney=200000, nPayLimit=48, szSelect = "领取60级奖励"}, 				--6级玄晶10个、200000绑定银两,60级,当月充值48元
	{nLevel = 69, nTaskId=19, tbItem={{tbItem={18,1,286,7}, nNum=1, nDay=30}}, nBindMoney=300000, nBindCoin=5000, nPayLimit=48, szSelect = "领取69级奖励"}, --7级玄晶10个、300000绑定银两、5000绑定金币,69级,当月充值48元
};

--09新版剑侠世界推广员奖励表
tbEvent.DEF_AWARD_TUIGUANGYUAN_09 = {
	{nLevel = nil, nTaskId=12, nBindCoin=1000, szSelect = "领取首次消费奖励", 
	funCondition = 
		function(pPlayer) 
			if me.GetTask(Spreader.TASK_GROUP, Spreader.TASKID_CONSUME) > 0 then
				return 1;
			else
				return 0, "您只要在奇珍阁使用金币购买商品并使用该商品，之后就能够领取此项奖励。";
			end
		end,
	 },
	{nLevel = 20, nTaskId=13, nBindCoin=1000, szSelect = "领取20级奖励"},
	{nLevel = 50, nTaskId=14, nBindCoin=2000, szSelect = "领取50级奖励"},
	{nLevel = 70, nTaskId=15, nBindCoin=5000, szSelect = "领取70级奖励"},
};

--领取奖励表，内测玩家真情回馈
tbEvent.DEF_AWARD_FEEDBACK = {
	{nLevel = 69, nTaskId=12, tbItem={{tbItem={18,1,23,1}, nNum=1, nDay=7}}, nPayLimit=48, szSelect = "领取无限回城符（1周）", nPayMax=500, nPrestige=100}, 				--无限回城符（1周）,1级
	{nLevel = 69, nTaskId=13, tbItem={{tbItem={18,1,85,1}, nNum=1, nDay=30}}, nPayLimit=48, szSelect = "领取1张乾坤符", nPayMax=500, nPrestige=100}, 				--乾坤符1张,10级
	{nLevel = 69, nTaskId=14, tbItem={{tbItem={18,1,71,2}, nNum=20,nDay=30}}, nPayLimit=48, szSelect = "领取20个大白驹丸", nPayMax=500, nPrestige=100}, 				--大白驹丸20个,20级
	{nLevel = 69, nTaskId=15, tbItem={{tbItem={18,1,113,1}, nNum=1, nDay=30},{tbItem={18,1,2,2}, nNum=1, nDay=30}}, nPayLimit=48, szSelect = "领取传声海螺和金犀", nPayMax=500, nPrestige=100}, 	--传声海螺（10句）1个、金犀（2级）1个,30级
	{nLevel = 69, nTaskId=16, tbItem={{tbItem={18,1,1,4}, nNum=20, nDay=30}}, nBindCoin=2000, nPayLimit=48, szSelect = "领取20个4级玄晶和2000绑定金币", nPayMax=500, nPrestige=100}, 							--4级玄晶20个、2000绑定金币,40级
	{nLevel = 69, nTaskId=17, tbItem={{tbItem={18,1,1,5}, nNum=20, nDay=30}}, nBindMoney=100000, nPayLimit=48, szSelect = "领取20个5级玄晶和100000绑定银两", nPayMax=500, nPrestige=100}, 					--5级玄晶20个、100000绑定银两,50级
	{nLevel = 69, nTaskId=18, tbItem={{tbItem={18,1,1,6}, nNum=10, nDay=30}}, nBindMoney=200000, nPayLimit=48, szSelect = "领取10个6级玄晶和200000绑定银两", nPayMax=500, nPrestige=100}, 				--6级玄晶10个、200000绑定银两,60级,当月充值48元
	{nLevel = 69, nTaskId=19, tbItem={{tbItem={18,1,1,7}, nNum=10, nDay=30}}, nBindMoney=300000, nBindCoin=5000, nPayLimit=48, szSelect = "领取10个7玄,5000绑金和30万绑银", nPayMax=500, nPrestige=100}, --7级玄晶10个、300000绑定银两、5000绑定金币,69级,当月充值48元
};

tbEvent.DEF_BUYFULI_LIST = {
		--					选项，					条件等级区间，金币，奇珍阁Id，任务变量	
		{"[ 1-50级]购买游龙阁开心蛋", 1,50,10,613, 231, "你确定要使用<color=yellow>10金币<color>，<color=yellow>低于0.1折<color>的优惠购买<color=yellow>游龙阁开心蛋（2000绑定金币）<color>吗？"},
		{"[30-50级]购买游龙阁金锭",30,50,200,612,232, "你确定要使用<color=yellow>200金币<color>，<color=yellow>低于1折<color>的优惠购买<color=yellow>游龙阁金锭（50万绑定银两）<color>吗？"},
		{"[50-60级]购买游龙阁开心蛋",50,60,200,90,233, "你确定要使用<color=yellow>200金币<color>，<color=yellow>低于1折<color>的优惠购买<color=yellow>游龙阁开心蛋（2000绑定金币）<color>吗？"},
		{"[60-70级]购买游龙阁开心蛋",60,70,200,90,234, "你确定要使用<color=yellow>200金币<color>，<color=yellow>低于1折<color>的优惠购买<color=yellow>游龙阁开心蛋（2000绑定金币）<color>吗？"},
		{"[70-80级]购买游龙阁金锭",70,80,200,612,235, "你确定要使用<color=yellow>200金币<color>，<color=yellow>低于1折<color>的优惠购买<color=yellow>游龙阁金锭（50万绑定银两）<color>吗？"},
		{"[80-90级]购买游龙阁金锭",80,90,200,612,236, "你确定要使用<color=yellow>200金币<color>，<color=yellow>低于1折<color>的优惠购买<color=yellow>游龙阁金锭（50万绑定银两）<color>吗？"},
		{"[ 达90级]购买游龙阁金锭",90,150,200,612,237, "你确定要使用<color=yellow>200金币<color>，<color=yellow>低于1折<color>的优惠购买<color=yellow>游龙阁金锭（50万绑定银两）<color>吗？"},
		}
tbEvent.DEF_TYPE_NEWCARD	=	1;	--新手卡类型，1为选择新手卡奖励，2为选择内网奖励
tbEvent.DEF_TYPE_FEEDBACK	=	2;	--真情回馈类型，1为选择新手卡奖励，2为选择内网奖励

tbEvent.DEF_NEWCARD_DATE_END	=	200905312400; --新手卡奖励领取结束时间
tbEvent.DEF_FEEDBACK_DATE_START	=	200810170000; --真情回馈奖励领取开始时间
tbEvent.DEF_FEEDBACK_DATE_END	=	200905312400; --真情回馈奖励领取结束时间
tbEvent.RESULT_DESC =
{
	[1] = "成功验证",
	[2] = "验证失败",
	[3] = "帐号不存在",
	[1009] = "传入的参数非法或为空",
	[1500] = "此激活码不存在",
	[1501] = "此激活码已被激活使用",
	[1502] = "此激活码已过期",
}

function tbEvent:WriteLog(szLog, nPlayerId)
	if nPlayerId then
		local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
		if (pPlayer) then
			Dbg:WriteLog("SpecialEvent.NewPlayerCard", "新手卡奖励", pPlayer.szAccount, pPlayer.szName, szLog);
			pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_BINDCOIN, szLog);
			return 1;
		end
	end
	Dbg:WriteLog("SpecialEvent.NewPlayerCard", "新手卡奖励", szLog);
end

function tbEvent:CheckTime(nType)
	local nDate = tonumber(GetLocalDate("%Y%m%d%H%M"))
	if nType == 1 then
		if nDate < self.DEF_NEWCARD_DATE_END then
			return 1;
		end
	end
	if nType == 2 then
		if nDate >= self.DEF_FEEDBACK_DATE_START and nDate < self.DEF_FEEDBACK_DATE_END  then
			return 1;
		end		
	end
	return 0;
end

--新手卡－－－－－－－－－－－－
function tbEvent:OnDialogNewCard(nFlag)
	local nExtPoint = me.GetExtPoint(6);
	--如果该角色已经激活了新手卡
	if me.GetTask(self.TASK_GOURP_ID, self.TASK_REGISTER_ID) == self.DEF_TYPE_NEWCARD then
		if math.mod(nExtPoint, 10) == 1 then
			Dialog:Say("您已经领取过推广员奖励，不能再领取新手卡奖励");
			return 1;
		end
		self:OnGetAwardNewCard(1);
		return 0
	end
	
	--如果该角色已经领取了内测奖励
	if me.GetTask(self.TASK_GOURP_ID, self.TASK_REGISTER_ID) == self.DEF_TYPE_FEEDBACK then
		Dialog:Say("您已经领取过真情回馈奖励，不能再领取新手卡奖励");
		return 0
	end
	if nExtPoint > 0 then
		Dialog:Say("您的帐号已经验证了推广员或激活了新手卡，一个帐号只能一个角色领取推广员或新手卡奖励，您的这个角色不能再领取新手卡奖励。");
		return 0;
	end		
	if nFlag == 1 then
		if me.nLevel > 69 then
			Dialog:Say("您等级已经超过了69级，已经不是新手，不能使用新手卡。")
			return 0;
		end
		Dialog:AskString("请输入新手卡激活码：", 15, self.OnCheckCard, self);
		return 0;
	end
	local szMsg = "您确定要领取新手卡奖励吗？只有等级不超过<color=yellow>69级<color>的新手玩家才有资格使用新手卡获得488奖励。当成功验证新手卡激活码后，只能领取新手卡奖励，将不能领取内测真情回馈奖励。您确定要验证新手卡激活码吗？";
	local tbOpt = {
		{"我确定要验证激活码", self.OnDialogNewCard, self, 1},
		{"Để ta suy nghĩ lại"},
	}
	Dialog:Say(szMsg, tbOpt);
end

function tbEvent:OnCheckCard(szCDKey)
	--检查激活码
	--if not szCDKey or szCDKey == "" or string.len(szCDKey) > 20 or string.len(szCDKey) < 10 then
	--	Dialog:Say("输入激活码的长度不符合要求。");
	--	return 1;
	--end
	if SendPresentKey(szCDKey) == 1 then
		me.AddWaitGetItemNum(1);
		return 1;
	end
	Dialog:Say("输入的激活码不符合要求。");
end

--nResult:1代表成功，2代表失败，3代表帐号不存在，1009代表传入的参数非法或为空，1500代表礼品序列号不存在，1501礼品已被使用,1502礼品已过期
function tbEvent:OnCheckCardResult(nResult)	
	if nResult == 1 then
		SpecialEvent.NewPlayerCard:OnGetAwardNewCard(1);
		return 1;
	end
	Dialog:Say(self.RESULT_DESC[nResult] or "激活码异常");
end

function tbEvent:OnGetAwardNewCard(nType)
	local szMsg = "";
	local tbOpt = {};
	local nExtPoint = me.GetExtPoint(6);
	me.SetTask(self.TASK_GOURP_ID, self.TASK_REGISTER_ID, self.DEF_TYPE_NEWCARD);
	local tbAwardList = self.DEF_AWARD_NEWCARD;
	local tbAbout;
	if nType == 1 then
		szMsg = "激活码验证成功，我来领取奖励。\n领取奖励有效期至<color=red>2009年5月31日<color>";
		tbAbout = {self.NewCardAbout, self};
		--设置扩展点
		if math.mod(nExtPoint, 10) ~= 0 and math.mod(nExtPoint, 10) ~= 2 then
			Dialog:Say("出现异样,请联系游戏管理员。");
			return 0;
		end
		if math.mod(nExtPoint, 10) == 0 then
			me.AddExtPoint(6, 2);
			me.AddExtPoint(6, 10000);
		end
	else
		szMsg = "我来领取推广员奖励。";
		tbAbout = {self.TuiGuangYuanAbout, self};
		--设置扩展点
		if math.mod(math.floor(nExtPoint/100),100) == 0 then
			me.AddExtPoint(6, 100);
			me.SetTask(self.TASK_GOURP_ID, self.TASK_GET_TUIGUANGYUAN_AWARD,1);
		elseif me.GetTask(self.TASK_GOURP_ID, self.TASK_GET_TUIGUANGYUAN_AWARD) ~= 1 then
			Dialog:Say("你的推广员帐号已过期。");
			return;
		end
		
		tbAwardList = self.DEF_AWARD_TUIGUANGYUAN_09;
	end
	
	self:OnGetAwardFeedBack(tbAwardList, tbAbout);
end

function tbEvent:NewCardAbout()
	local szMsg = [[<color=yellow>
1级可获无限回城符（1周）
10级可获乾坤符1张（1月）
20级可获大白驹丸20个（1月）
30级可获传声海螺（10句）1个（1月）、金犀（2级）1个（1月）
40级可获4级玄晶20个（1月）、2000绑定金币
50级可获5级玄晶20个（1月）、100000绑定银两
60级可获6级玄晶10个（1月）、200000绑定银两
69级可获7级玄晶10个（1月）、300000绑定银两、5000绑定金币<color>

<color=yellow>等级不超过69级的新手玩家才有资格使用新手卡获得488奖励。<color>
60级和69级奖励需要帐号本月累计充值超过<color=red>15元<color>才可以领取
	]]
	Dialog:Say(szMsg);
end

function tbEvent:TuiGuangYuanAbout()
	local szMsg = [[<color=yellow>
1级可获无限回城符（1周）
10级可获乾坤符1张（1月）
30级可获传声海螺（10句）1个（1月）、金犀（2级）1个（1月）
40级可获4级玄晶20个（1月）、2000绑定金币
50级可获5级玄晶20个（1月）、100000绑定银两、大白驹丸20个（1月）
60级可获6级玄晶10个（1月）、200000绑定银两
69级可获7级玄晶10个（1月）、300000绑定银两、5000绑定金币<color>

60级和69级奖励需要帐号本月累计充值超过<color=red>48元<color>才可以领取
	]]
	
	szMsg = [[<color=yellow>
首次消费可获取1000绑定金币
20级可获取1000绑定金币
50级可获取2000绑定金币
70级可获取5000绑定金币
<color>
你还可以拥有超值低价购买以下物品的资格<color=yellow>
[ 1-50级]10金币购买游龙阁开心蛋
[30-50级]200金购买游龙阁金锭
[50-60级]200金币购买游龙阁开心蛋
[60-70级]200金币购买游龙阁开心蛋
[70-80级]200金购买游龙阁金锭
[80-90级]200金购买游龙阁金锭
[ 达90级]200金购买游龙阁金锭
<color>
游龙阁开心蛋：可获得2000绑定金币
游龙阁金锭：可获得50万绑定银两
<color=red>
注意：需要当月有任意充值行为，且每个等级段的物品只允许购买一个，同时物品为获取绑定。如果超过该等级段不购买将会失去购买资格。
<color>
]]
	Dialog:Say(szMsg);
end

--真情回馈－－－－－－－－－－－－
function tbEvent:OnDialogFeedBack(nFlag)
	
	--如果该角色已经激活了新手卡
	if me.GetTask(self.TASK_GOURP_ID, self.TASK_REGISTER_ID) == self.DEF_TYPE_FEEDBACK then
		self:OnGetAwardFeedBack(self.DEF_AWARD_FEEDBACK, {self.FeedBackAbout, self});
		return 0
	end
	
	--角色等级未够80级，
	if me.nLevel < 69 then
		Dialog:Say("您的等级未够69级，不能领取内测玩家回馈奖励。")
		return 0
	end
	
	--如果该角色已经领取了内测奖励
	if me.GetTask(self.TASK_GOURP_ID, self.TASK_REGISTER_ID) == self.DEF_TYPE_NEWCARD then
		Dialog:Say("您已经领取过新手卡奖励或活动推广员奖励，不能再领取真情回馈奖励。");
		return 0
	end
	
	
	if nFlag == 1 then
		me.SetTask(self.TASK_GOURP_ID, self.TASK_REGISTER_ID, self.DEF_TYPE_FEEDBACK);
		self:OnGetAwardFeedBack(self.DEF_AWARD_FEEDBACK, {self.FeedBackAbout, self});
		return 0;
	end
	local szMsg = "您确定要领取内测真情回馈奖励吗？<color=red>领取了真情回馈奖励后，将不能领取新手卡奖励。<color>";
	local tbOpt = {
		{"我确定领取(将不能领取新手卡奖励)", self.OnDialogFeedBack, self, 1},
		{"Để ta suy nghĩ lại"},
	}
	Dialog:Say(szMsg, tbOpt);
	
end

function tbEvent:OnGetAwardFeedBack(tbData, tbAbout)
	local szMsg = "我来领取奖励。";
	local tbOpt = {{"查看奖励内容及领奖条件", unpack(tbAbout)}};
	
	for nId, tbAward in ipairs(tbData) do
		if me.GetTask(self.TASK_GOURP_ID, tbAward.nTaskId) == 0 and 
			((tbAward.nLevel and me.nLevel >= tbAward.nLevel) or  (tbAward.funCondition and tbAward.funCondition(me) == 1))
		then
			table.insert(tbOpt, {tbAward.szSelect, self.GetAward, self, tbData, nId});
		else
			table.insert(tbOpt, {"<color=gray>"..tbAward.szSelect.."<color>", self.GetAward, self, tbData, nId});			
		end
	end

	for nType, tbSelect in ipairs(self.DEF_BUYFULI_LIST) do
		local szSec=tbSelect[1];
		if me.nLevel >= tbSelect[2] and me.nLevel <= tbSelect[3] and me.GetTask(self.TASK_GOURP_ID, tbSelect[6]) == 0 then
			szSec = string.format("<color=yellow>%s<color>", szSec);
		else
			szSec = string.format("<color=gray>%s<color>", szSec);
		end
		table.insert(tbOpt,{szSec, self.BuyItemFuli, self, nType});
	end
	
	if #tbOpt <= 0 then
		szMsg = "您没达到所需领取奖励的条件要求或已领取完所有奖励。";
	end
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	Dialog:Say(szMsg, tbOpt);
end
function tbEvent:BuyItemFuli(nType)
	local tbSelect = self.DEF_BUYFULI_LIST[nType];
	local szMsg = "你可以在我这里用非常优惠的价格购买到相应的商品，资格有限。\n"..tbSelect[7];
	local tbOpt = {
		{"我确定购买",self.BuyItemFuliSure, self, nType},
		{"Kết thúc đối thoại"},
	}
	Dialog:Say(szMsg, tbOpt);
end

function tbEvent:BuyItemFuliSure(nType)
	local tbSelect = self.DEF_BUYFULI_LIST[nType];
	if me.GetTask(self.TASK_GOURP_ID, tbSelect[6]) ~= 0 then
		Dialog:Say("你已经购买过该物品，一个玩家最多只能购买一次。");
		return;
	end
	if me.nLevel < tbSelect[2] or me.nLevel > tbSelect[3] then
		Dialog:Say("你的等级不符合购买资格需求。");
		return;
	end
	local tbPayOpt = {
		{"我要充值", c2s.ApplyOpenOnlinePay, c2s},
		{"Kết thúc đối thoại"},
		};
	if me.GetExtMonthPay() <= 0 then
		Dialog:Say("你的本月还没有进行过充值，只要进行任意充值，就可拥有购买资 ô.", tbPayOpt);
		return;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ 1 ô trống.");
		return 0;
	end
	if me.GetJbCoin() < tbSelect[4] then
		Dialog:Say("您的金币不足，购买1个开心蛋需要200金币。", tbPayOpt);
		return 0;
	end

	if me.ApplyAutoBuyAndUse(tbSelect[5], 1, 0) == 1 then
		me.SetTask(self.TASK_GOURP_ID, tbSelect[6], 1);
		Dialog:Say("您成功购买了优惠物品，请在背包中进行查看！");
		return 0;
	end
	Dialog:Say("很抱歉，购买失败，请稍后再尝试！");
end


function tbEvent:FeedBackAbout()
	Dialog:Say(self.HelpNews);
end

function tbEvent:GetAward(tbAward, nId)
	local tbAward = tbAward[nId]
	if me.GetTask(self.TASK_GOURP_ID, tbAward.nTaskId) ~= 0 then
		Dialog:Say("您已经领取了该项奖励。");
		return 0;
	end
	
	local nNeedFree = 0;
	if tbAward.tbItem then
		for _, tbItem in pairs(tbAward.tbItem) do
			nNeedFree = nNeedFree + tbItem.nNum;
		end
	end
	local nCheck = 1;
	if tbAward.nPayMax then
		if me.GetExtMonthPay() >= tbAward.nPayMax then
			nCheck = nil;
		end	
	end
	
	if tbAward.nLevel then
		if me.nLevel < tbAward.nLevel then
			local szMsg =  string.format("本奖励必须要等级达到%s级才能领取。", tbAward.nLevel);
			Dialog:Say(szMsg);
			return 0;
		end
	end
	
	if tbAward.funCondition then
		local nRes, szMsg = tbAward.funCondition(me);
		if nRes ~= 1 then
			Dialog:Say(szMsg);
			return 0;
		end
	end
	
	if tbAward.nPrestige and nCheck then
		if me.nPrestige < tbAward.nPrestige then
			local szMsg =  string.format("本奖励必须要江湖威望达到%s点才能领取", tbAward.nPrestige);
			if tbAward.nPayMax then
				szMsg = szMsg .. "或者本月充值达到500元才能领取。";
			end
			szMsg = szMsg .."。";
			Dialog:Say(szMsg);
			return 0;			
		end
	end
	if tbAward.nPayLimit and nCheck then
		if me.GetExtMonthPay() < tbAward.nPayLimit then
			Dialog:Say(string.format("本奖励必须在您帐号本月充值达到%s元后才能领取，您本月的充值已累计%s元。", tbAward.nPayLimit, me.GetExtMonthPay()))
			return 0;
		end
	end
	local nNeedBindMoney = tbAward.nBindMoney or 0;
	if nNeedBindMoney + me.GetBindMoney() > me.GetMaxCarryMoney() then
		Dialog:Say(string.format("对不起，领取后，您身上的绑定银两将会达到上限，请整理后再来领取。"));
		return 0;		
	end
	if me.CountFreeBagCell() < nNeedFree then
		Dialog:Say(string.format("对不起，您的背包空间不够，请整理一下背包再来领取。您需要%s格背包空间。", nNeedFree));
		return 0;
	end
	me.SetTask(self.TASK_GOURP_ID, tbAward.nTaskId, 1)
	if tbAward.tbItem then
		for _, tbItem in pairs(tbAward.tbItem) do
			for i=1, tbItem.nNum do
				local pItem = me.AddItem(unpack(tbItem.tbItem));
				if pItem then
					pItem.Bind(1);
					me.SetItemTimeout(pItem, os.date("%Y/%m/%d/00/00/00", GetTime() + tbItem.nDay * 24 * 3600));
				end
			end
		end
	end
	
	if tbAward.nBindMoney then
		me.AddBindMoney(tbAward.nBindMoney, Player.emKBINDMONEY_ADD_EVENT);
	end
	
	if tbAward.nBindCoin then
		me.AddBindCoin(tbAward.nBindCoin, Player.emKBINDCOIN_ADD_EVENT);
	end
	Dialog:Say("您成功领取了奖励。");
	self:WriteLog(string.format("领取了第%s项奖励:%s", nId, tbAward.szSelect), me.nId);
end

tbEvent.HelpNews = [[
  为答谢广大玩家对我们的支持，应广大玩家的热烈要求，我们将延长“内测玩家真情回馈”活动并向所有玩家开放，同样的，只要您满足如下条件之一：<color=green>
  条件一：等级达到69级，江湖威望达到100，本月累计充值达到48元。
  条件二：等级达到69级，本月累计充值达到500元。<color>

就可以领取这个价值不菲的黄金大礼包。礼包内容包括：<color=yellow>
  无限回城符（1周，绑定）
  乾坤符1张（1月，绑定）
  大白驹丸20个（1月，绑定）
  传声海螺（10句）1个（1月，绑定）
  金犀（2级）1个（1月，绑定）
  4级玄晶20个（1月，绑定）
  5级玄晶20个（1月，绑定）
  6级玄晶10个（1月，绑定）
  7级玄晶10个（1月，绑定）
  2000绑定金币
  100000绑定银两
  200000绑定银两
  300000绑定银两
  5000绑定金币
<color>
领取截至时间：
  <color=red>2009年5月31日24时<color>
  
注意：内测玩家真情回馈和新手卡奖励只能择一领取
  <color=red>必须当月充值当月领取奖励<color>

温馨提示：必须是当月成功充值“15元充值卡”、“30元充值卡”、“48元充值卡”、“50元充值卡”、“100元充值卡”、“500元充值卡”中任意一种实卡或虚卡、银行卡才有效。  
]]


--if (not MODULE_GC_SERVER) then
--	return 0;
--end

--function tbEvent:SetNews()
--	local nData = tonumber(GetLocalDate("%Y%m%d%H%M"));
--	if nData < self.DEF_FEEDBACK_DATE_END then
--		local nEndTime	= Lib:GetDate2Time(math.floor(self.DEF_FEEDBACK_DATE_END));
--		Task.tbHelp:SetCollectCardNews(0, nEndTime, "真情回馈玩家大礼包", self.HelpNews, 6);	
--	end
--end

--GCEvent:RegisterGCServerStartFunc(SpecialEvent.NewPlayerCard.SetNews, SpecialEvent.NewPlayerCard);
