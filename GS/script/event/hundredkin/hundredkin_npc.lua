------
-- zhengyuhua
-- 百大家族评选 对话逻辑

if not SpecialEvent.HundredKin then
	SpecialEvent.HundredKin = {}
end

local HundredKin = SpecialEvent.HundredKin;

function HundredKin:DialogLogic(nItemLevel)
	local nRet = self:CheckEventTime2("award")
	if nRet == -1 then
		Dialog:Say("百大家族评选会在8月18日展开，在这之前请积极参加各种活动赚取家族积分吧");
		return 0;
	elseif nRet == 0 then
		Dialog:Say("百大家族评选兑奖已经结束");
		return 0;
	elseif nRet ~= 1 then
		return 0;
	end
	-- 判断条件 
	local nKinId, nMemberId = me.GetKinMember();
	local nRet, pKin = Kin:HaveFigure(nKinId, nMemberId, 3);
	if pKin.GetHundredKinAwardCount() >= self.TAKE_AWARD_MAX_COUNT then
		Dialog:Say("你所在家族已经有<color=red>40个正式成员<color>领取过奖励了，每个家族只允许40个成员领取盛夏活动奖励。");
		return 0;		
	end
	local nScore = me.GetTask(self.TASK_GROUP, self.TASK_SCORE_ID)
	if nScore < self.TAKE_AWARD_MIN_SCORE or nRet ~= 1  then
		Dialog:Say("只有加入家族的<color=red>正式成员<color>且盛夏活动期间个人获得的家族<color=red>积分超过500<color>，才有资格领取奖励！你的积分贡献是"..nScore);
		return 0;
	end
	nRet = me.GetTask(self.TASK_GROUP, self.TASK_AWARD_ID)
	if nRet == 1 then
		Dialog:Say("你已经领取过奖励了");
		return 0;
	end
	-- 判断族长
	local nDetail = 9;
	local nCaptain = 2;
	local szInfo = "<color=green>另外，家族族长可以额外领取<color=yellow>%d<color>绑定银两的奖励.<color>"
	if pKin.GetCaptain() == nMemberId then
		if pKin.GetHundredKinAward() == 0 then
			nDetail = 8;
			nCaptain = 1;
		else
			szInfo = szInfo.."<color=red>（你的家族族长奖励已经被前任族长领取了，你只能领取正式成员的奖励）<color>"
		end
	end
	-- 确定领奖励（第二次调用）
	if nItemLevel then
		local tbAward = self.KIN_AWARD[nItemLevel][nCaptain];
		if me.CountFreeBagCell() < ((tbAward.freebag) or 0) then
			Dialog:Say("你的背包空间不足");
			return 0;
		end
		if tbAward.bindmoney then
			if me.GetBindMoney() + tbAward.bindmoney > me.GetMaxCarryMoney() then
				Dialog:Say("你的金钱携带量不足，请把部分金钱存到物品保管人再来领取！");
				return 0;
			end
			me.AddBindMoney(tbAward.bindmoney, Player.emKBINDMONEY_ADD_HUNDREDKIN);
			pKin.SetHundredKinAward(1);		-- 标记已经领过族长的奖励了
			GCExcute{"SpecialEvent.HundredKin:SetHundredKinAward_GC", nKinId, 1}
			-- 谁领取了族长奖励的？记个log方便查
			print("[HundredKin]CaptainAward "..nItemLevel ,"角色名:"..me.szName, "帐号:"..me.szAccount);
		end
		local nTitleLevel = (5-nItemLevel);
		if nTitleLevel > 0 then
			me.AddTitle(6, nDetail, nTitleLevel, 0);
			me.SetCurTitle(6, nDetail, nTitleLevel, 0);
		end
		
		if tbAward.item then
			me.AddStackItem(unpack(tbAward.item));
			Dbg:WriteLog("SpecialEvent.HundredKin", "百大家族评选活动积分", nKinId or 0, nKinSort or 0, nKinScore or 0, me.szName, nItemLevel or 0);
		end
		
		if tbAward.repute then
			me.Msg(string.format("你获得了<color=yellow>%s点江湖威望<color>", tbAward.repute));
			me.AddKinReputeEntry(tbAward.repute);
		end
		
		if tbAward.leader then
			me.Msg(string.format("你获得了<color=yellow>%s点领袖荣誉<color>", tbAward.leader));
			local nCurHonor = PlayerHonor:GetPlayerHonorByName(me.szName, PlayerHonor.HONOR_CLASS_LINGXIU, 0);
			PlayerHonor:SetPlayerHonorByName(me.szName, PlayerHonor.HONOR_CLASS_LINGXIU, 0, nCurHonor + tbAward.leader)
		end
		me.SetTask(self.TASK_GROUP, self.TASK_AWARD_ID, 1);
		local nKinCount = pKin.GetHundredKinAwardCount();
		pKin.SetHundredKinAwardCount(nKinCount + 1);
		GCExcute{"SpecialEvent.HundredKin:SetHundredKinAwardCount_GC", nKinId, nKinCount + 1};
		local nKinSort, nKinScore = self:GetKinSort(nKinId);
		return 0;
	end
	local nSort = self:GetKinSort(nKinId);
	if nSort <= 0 then
		Dialog:Say("很遗憾，你家族在100名之外，不能获得任何奖励");
		return 0;
	end
	if nSort == 1 then
		Dialog:Say("  恭喜你们家族位于百家之首，族长和正式成员分别获得<color=yellow>“第一家族族长”、“第一家族成员”<color>称号以及<color=yellow>盛夏黄金宝箱<color>3个！族长可获得1000点江湖威望，5000点领袖荣誉，成员可获得500点江湖威望！"..string.format(szInfo, self.KIN_AWARD[1][1].bindmoney),
			{{"Nhận", self.DialogLogic, self, 1}, {"取消"}});
	elseif nSort <= 10 then 
		Dialog:Say("  恭喜你们家族位于十大家族，族长和正式成员可以分别获得<color=yellow>“十大家族族长”、“十大家族成员”<color>称号以及<color=yellow>盛夏黄金宝箱<color>2个！族长可获得600点江湖威望，3000点领袖荣誉，成员可获得300点江湖威望！"..string.format(szInfo, self.KIN_AWARD[2][1].bindmoney),
			{{"Nhận", self.DialogLogic, self, 2}, {"取消"}});
	elseif nSort <= 30 then 
		Dialog:Say("  恭喜你们家族位于前三十家族，族长和正式成员可以分别获得<color=purple>“出类拔萃的族长”、“出类拔萃的成员”<color>称号以及<color=yellow>盛夏黄金宝箱<color>1个！族长可获得400点江湖威望，2000点领袖荣誉，成员可获得200点江湖威望！"..string.format(szInfo, self.KIN_AWARD[3][1].bindmoney),
			{{"Nhận", self.DialogLogic, self, 3}, {"取消"}});
	elseif nSort <= 60 then
		Dialog:Say("  恭喜你们家族位于前六十之列，族长和正式成员可以分别获得<color=blue>“干劲十足的族长”、“干劲十足的成员”<color>称号以及<color=purple>盛夏白银宝箱<color>2个！族长可获得200点江湖威望，1000点领袖荣誉，成员可获得100点江湖威望！"..string.format(szInfo, self.KIN_AWARD[4][1].bindmoney),
			{{"Nhận", self.DialogLogic, self, 4}, {"取消"}});
	elseif nSort <= 100 then
		Dialog:Say("  恭喜你们家族位于百家之列，族长和正式成员可以分别获得<color=purple>盛夏白银宝箱<color>1个！族长可获得500点领袖荣誉！"..string.format(szInfo, self.KIN_AWARD[5][1].bindmoney),
			{{"Nhận", self.DialogLogic, self, 5}, {"取消"}});
	else
		Dialog:Say("很遗憾，你家族在100名之外，不能获得任何奖励");
	end 
end


-- 修炼珠对话逻辑
function HundredKin:XiuLianZhu_Logic()
	local tbInfo = self:GetTensKin()
	local szInfo = "<color=green>家族积分排名:<color>\n\n"
	for i = 1, 10 do
		if tbInfo[i] then
			szInfo = szInfo..Lib:StrFillL("第"..i.."名 "..tbInfo[i].szName, 26)..tbInfo[i].nScore.."分";
		end
		szInfo = szInfo.."\n";
 	end
 	if #self.tbSortKin >= 100 then
 		local nSort, nScore, szName = self:GetKinSort(self.tbSortKin[100].nKinId);
 		szInfo = szInfo.."\n目前第100名的家族积分为"..nScore.."\n";
 	end
 	local nKinId = me.GetKinMember();
 	if nKinId ~= 0 then
 		local nSort, nScore, szName = self:GetKinSort(nKinId);
 		szInfo = szInfo.."\n<color=yellow>我的家族\n"..Lib:StrFillL("第"..nSort.."名 "..szName, 26)..nScore.."分\n";
 		local nSelfScore = me.GetTask(self.TASK_GROUP, self.TASK_SCORE_ID)
 		szInfo = szInfo.."我贡献的家族积分:"..nSelfScore.."<color>";
 	end
 	Dialog:Say(szInfo);
end

