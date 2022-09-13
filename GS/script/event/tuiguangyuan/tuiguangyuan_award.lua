--推广员奖励
--孙多良
--2008.08.13
--ExtPoint6
--游戏内使用规则：
--1.       个位数值 > 0，则表示可以领奖
--2.       领取推广员奖励，ExtPoint6 + 100，百位表示领取次数标记
--3.       新手卡奖励开放后，将关闭推广员奖励
--4.       领取新手卡奖励，ExtPoint6 + 10000，万位表示领取次数标记

local TbTuiGuangYuan = {}
SpecialEvent.TuiGuangYuan = TbTuiGuangYuan;

TbTuiGuangYuan.OPEN = Task.IVER_nEvent_TuiGuangYuan;
TbTuiGuangYuan.EXTPOINT = 6;
TbTuiGuangYuan.OPEN_TUIGUANGYUAN_09 = 20090625;
function TbTuiGuangYuan:Check()
	if self.OPEN == 1 and self.OPEN_TUIGUANGYUAN_09 <= tonumber(GetLocalDate("%Y%m%d"))then
		return 1;
	end
	return 0;
end

function TbTuiGuangYuan:OnDialog(nFlag)
	local nExtPoint = me.GetExtPoint(self.EXTPOINT);
	if me.GetTask(SpecialEvent.NewPlayerCard.TASK_GOURP_ID, SpecialEvent.NewPlayerCard.TASK_REGISTER_ID) ==  SpecialEvent.NewPlayerCard.DEF_TYPE_NEWCARD then
		--如果已经激活.如果是领取过新手卡奖励
		if math.mod(nExtPoint, 10) == 2 then
			Dialog:Say("活动推广员：您的帐号已经激活了新手卡奖励，不能再领取推广员奖励。")
			return 0
		end
		SpecialEvent.NewPlayerCard:OnGetAwardNewCard(2);
		return 0;
	end
	
	--如果该角色已经领取了内测奖励
	if me.GetTask(SpecialEvent.NewPlayerCard.TASK_GOURP_ID, SpecialEvent.NewPlayerCard.TASK_REGISTER_ID) == SpecialEvent.NewPlayerCard.DEF_TYPE_FEEDBACK then
		Dialog:Say("您已经领取过真情回馈奖励，不能再领取推广员奖励");
		return 0
	end

	local nCheck, szMsg = self:CheckExt();
	if nCheck ~= 0 then
		Dialog:Say(szMsg);
		return 0;
	end
	if me.nLevel < 1 then
		Dialog:Say("活动推广员：推广员奖励需要10级之后才能领取，请升到10级之后再过来吧。");
		return 0;
	end
	--if me.CountFreeBagCell() < 10 then
	--	Dialog:Say("活动推广员：领取推广员奖励需要占用10格背包空间，请清理出足够的背包空间之后再来领取吧。");
	--	return 0;
	--end
	if nFlag then
		SpecialEvent.NewPlayerCard:OnGetAwardNewCard(2);
		return 0;
	end
	local szMsg = 
[[活动推广员：如果您是被推广的玩家，将可领取丰厚的奖励
	<color=yellow>每个被推广帐号下，只允许选择一个角色领取一次奖励。
	您这个角色领取后，您本帐号下所有角色将不能再领取了。<color>
	
	您的这个角色领取了推广员奖励后，将不能再领取新手卡奖励和真情回馈奖励。
	您确定要领取奖励吗？
]]
	local tbOpt = 
	{
		{"确定领取奖励", self.OnDialog, self, 1},
		{"Kết thúc đối thoại"},
	}
	Dialog:Say(szMsg, tbOpt)
end

function TbTuiGuangYuan:CheckExt()
	local nExtPoint = me.GetExtPoint(self.EXTPOINT);
	if nExtPoint <= 0 then
		return 1, "活动推广员：只有被推广员系统推广的帐号才可以领取奖励。";
	end

	if math.mod(nExtPoint, 10) == 2 then
		return 2, "活动推广员：你已激活了新手卡奖励，不能领取推广员奖励。"
	end
	
	local nExtPonit_TuiGuang = math.mod(math.floor(nExtPoint/100),100);
	if nExtPonit_TuiGuang > 0 then
		return 3, "活动推广员：每个被推广帐号下，只允许选择一个角色领取一次奖励。";
	end
	
	return 0;
end

