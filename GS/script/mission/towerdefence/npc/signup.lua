--报名npc
--sunduoliang
--2008.12.29
TowerDefence.tbNpc = TowerDefence.tbNpc or {};
local tbNpc = TowerDefence.tbNpc;

function tbNpc:OnDialog()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate < TowerDefence.SNOWFIGHT_STATE[1] then
		Dialog:Say("活动还没有开始！", {{"知道了"}});
		return 0;
	end	
	if TowerDefence:IsSignUpByAward(me) == 1 then
		Dialog:Say("你上次赢了，我有礼物要送给你。", {{"领取奖励", self.GetAward, self}});
		return 0;
	end
	
	local nCountSum, nCount, nCountEx = TowerDefence:IsSignUpByTask(me);
	local szMsg = string.format("一伙由金人操纵的机械怪兽军团正在以围剿之势接近这里，企图借助怪物之力打击义军主力，并威胁先祖之魂，你要加入抗击的行列吗？\n\n<color=yellow>你今天剩余次数：%s次<color>\n<color=yellow>你剩余额外次数：%s次<color>", nCount, nCountEx);
	local tbOpt = {
		{"报名加入抗击的行列", TowerDefence.OnDialog_SignUp, TowerDefence},
		{"领取奖励", self.GetAward, self},
		{"领取最终活动奖励", self.GetFinishAward, self},
		--{"换取额外比赛次数", self.GetExCount, self},
		{"排行榜查询", self.OnOpenRank, self},
		{"了解守护先祖之魂活动", self.OnAbout, self},
		--{"了解新年活动", self.OnAboutNewYears, self},
		{"Ta chỉ xem qua"},
	};	
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GetFinishAward()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	local nCurDateEx = tonumber(GetLocalDate("%Y%m%d"));
	if nCurDate <= TowerDefence.SNOWFIGHT_STATE[2] *10000 + 0400 then				--9号3点排行榜刷过之后，才能开始领奖
		Dialog:Say("活动还没有结束，还是等活动结束了在来领取吧！");
		return 0;
	end
	if nCurDateEx >= TowerDefence.SNOWFIGHT_STATE[2] + 7 then
		Dialog:Say("活动期效已经过了，不能再领取东西了！");
		return 0;
	end
	if me.GetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_AWARD_FINISH) > 0 then
		Dialog:Say("你已领取过奖励了，不能太贪心哦。");
		return 0;
	end
	local nCountSum = me.GetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_ATTEND_TOTAL);
	local nRank		= GetPlayerHonorRankByName(me.szName, PlayerHonor.HONOR_CLASS_DRAGONBOAT, 0);	

	local nRankType = 0;
	local szRank = string.format("Đạt hạng <color=yellow>%s<color>", nRank);
	if nRank <= 0 then
		szRank = "无排名";
	end
	if nRank > 0 then
		for nType, tbType in ipairs(TowerDefence.AWARD_FINISH) do
			if nRank <= tbType[1] then
				nRankType = nType;
				break;
			end
		end
	end	
	if nRankType == 0 then
		Dialog:Say("你不满足获奖条件！");
		return 0;
	end
	local tbAward = TowerDefence.AWARD_FINISH[nRankType][2];
	if nRankType > 1 then	
		if me.CountFreeBagCell() < 1 then
			Dialog:Say("你的背包空间不足，需要1格背包空间");
			return 0;
		end
		local szAwardName = "";
		local pItem = me.AddItem(unpack(tbAward));
		if pItem then
			me.SetItemTimeout(pItem, 30*24*60, 0);
			pItem.Sync();
			szAwardName = pItem.szName;
			me.SetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_AWARD_FINISH, 1);
		end		
		Dialog:Say(string.format("你参加守护先祖之魂，%s，共成功参加%s场，获得了1个%s。", szRank, nCountSum, szAwardName));
		EventManager:WriteLog("[清明节活动]最终排名获得了1个"..szAwardName, me);
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "[清明节活动]最终排名获得了1个"..szAwardName);
	else
		if me.CountFreeBagCell() < 2 then
			Dialog:Say("你的背包空间不足，需要2格背包空间");
			return 0;
		end
		me.AddStackItem(tbAward[1], tbAward[2], tbAward[3], tbAward[4], nil, 10000);
		me.SetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_AWARD_FINISH, 1);
		Dialog:Say(string.format("你参加守护先祖之魂，%s，共成功参加%s场，获得了10000个游龙古币。", szRank, nCountSum));
		EventManager:WriteLog("[清明节活动]最终排名获得了10000个游龙古币", me);
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "[清明节活动]最终排名获得了10000个游龙古币");
	end
end


function tbNpc:GetAward()
	if TowerDefence:IsSignUpByAward(me) <= 0 then
		Dialog:Say("想要礼物吗？想要的话就要报名加入守护先祖之魂的行列哦。", {{"我会去参加的"}});		
		return 0;
	end
	if TowerDefence:IsSignUpByAward(me) >= 5 then
		Dialog:Say("上次的礼物不是已经给你了么，而且，败了的队伍是没有礼物的哦！", {{"啊，我忘记了，对不起"}});
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		me.Msg("您背包空间不足，请整理1格背包空间。");
		return 0;
	end
	
	local pItem = me.AddItem(unpack(TowerDefence.WINNER_BOX[me.GetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_ATTEND_AWARD)]));
	if pItem then
		pItem.Bind(1);
		me.SetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_ATTEND_AWARD, 5);
		TowerDefence:WriteLog("得到物品"..pItem.szName, me.nId);
		EventManager:WriteLog("[清明节活动]获得"..pItem.szName, me);
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "[清明节活动]获得"..pItem.szName);
	end
	Dialog:Say("这是我送你的礼物作为抗击怪物进攻的奖励！", {{"谢谢", self.OnDialog, self}});
	return 0;
end

function tbNpc:OnOpenRank()
	local nTotal = me.GetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_ATTEND_TOTAL);
	local nWin 	 = me.GetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_ATTEND_WIN);
	local nTie 	 = me.GetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_ATTEND_TIE);
	local nLost  = nTotal - nWin - nTie;
	local szRate  = "无胜率";
	if nTotal > 0 then
		szRate = string.format("%.2f", (nWin/nTotal)*100) .. "％";
	end
	local szMsg = string.format([[可以帮你打开荣誉排行榜，你在界面下面的“其他排行榜”下的“活动排行”中查询到排行信息，需要我帮你打开排行榜吗？
	<color=green>
	---参赛信息---
	
	总场数：%s
	胜场数：%s
	平场数：%s
	负场数：%s
	胜率值：%s
	<color>
	]], nTotal, nWin, nTie, nLost, szRate);
	local tbOpt = {
		{"帮我打开排行榜吧", self.OnOpenRankList, self},
		{"我自己去看吧"},
	}
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnOpenRankList()
	me.CallClientScript({"UiManager:OpenWindow", "UI_LADDER"});
end

function tbNpc:GetExCount()
	Dialog:OpenGift("放入红粉莲花（每天限制最多用3个来兑换次数）", {"TowerDefence:CheckGiftSwith"}, {self.OnOpenGiftOk, self});
end

function tbNpc:OnOpenGiftOk(tbItemObj)
	local nSum = 0;
	local szItemParam = string.format("%s,%s,%s,%s",unpack(TowerDefence.SNOWFIGHT_ITEM_EXCOUNT));
	for _, tbItem in pairs(tbItemObj) do
		local szPutParam = string.format("%s,%s,%s,%s",tbItem[1].nGenre,tbItem[1].nDetail,tbItem[1].nParticular,tbItem[1].nLevel);
		if szPutParam ~= szItemParam then
			me.Msg("我只需要红粉莲花，请不要放入其他物品。");
			return 0;
		end
		nSum = nSum + 1;
	end
	local nCurDay = tonumber(GetLocalDate("%Y%m%d"));
	local nTaskDay = me.GetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_NEWYEAR_LIANHUA_DAY);
	if nTaskDay < nCurDay then
		me.SetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_NEWYEAR_LIANHUA_DAY, nCurDay);
		me.SetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_NEWYEAR_LIANHUA_COUNT, 0);
	end 
	
	local nTaskCount = me.GetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_NEWYEAR_LIANHUA_COUNT);
	if nTaskCount >= 3 then
		me.Msg("每天只能使用<color=yellow>3个红粉莲花<color>换取3次额外机会，你今天换取的机会<color=yellow>已达3次<color>。")
		return 0;
	end
	if nTaskCount + nSum > 3 then
		me.Msg(string.format("每天只能使用<color=yellow>3个红粉莲花<color>换取3次额外机会，你还<color=yellow>剩余%s次<color>换取的额外机会,只需放入<color=yellow>%s朵红粉莲花<color>。", (3 - nTaskCount), (3 - nTaskCount)));
		return 0;
	end
	
	local nDelCount = 0;
	for _, tbItem in pairs(tbItemObj) do
		if me.DelItem(tbItem[1]) ~= 1 then
			Dbg:WriteLog("TowerDefence", me.szName.."雪仗给予红粉莲花", "删除失败")
		else
			nDelCount = nDelCount + 1;
		end
	end
	me.SetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_NEWYEAR_LIANHUA_COUNT, nTaskCount + nDelCount);
	me.SetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_ATTEND_EXCOUNT, me.GetTask(TowerDefence.TSK_GROUP, TowerDefence.TSK_ATTEND_EXCOUNT) + nDelCount);
	me.Msg(string.format("您获得了<color=yellow>%s次<color>额外参赛资 ô.", nDelCount));
end


tbNpc.tbAboutNewYears = {
[1] = [[
    活动期间，每天上午10点到午夜1点，50级以上加入门派的玩家 可以到各新手村的晏若雪处，在其带领下进行打雪仗的活动。
每天每个玩家只有2次机会，可累计14次，不过据说，晏若雪非常喜欢红粉莲花，如果你能获得该物，说不定她就会额外带你去活动地点。
    此物珍奇，可遇不可求，参加新年活动才可能有机会获得红粉莲花。
    详情可去询问各新手村的晏若雪，或打开帮助锦囊（F12）查看。
]],

[2] = [[
    活动期间，每天晚上8点到9点，每6分钟，礼官会去各大门派拜年，3分钟后离开，所以当系统提示出现时要尽快前往。 
    礼官会送你“新年烟花”和随机奖励，奖励多多，务必参加为是。新年烟花需要在各大城市新手村礼官附近的“烟花燃放处”使用才有效果。 
    详情可去各大城市新手村询问礼官或打开帮助锦囊（F12）查看。
]],
[3] = [[
    拜年任务，是活动期间的每日小任务，你每天都可以去新手村白秋琳处接取，在成功完成后能获得经验，神秘道具等奖励，一定不要错过哦？
    ]],
[4] = [[
    你用“引魂雾”可在野外诱出年兽，它有“上古戾气”护体，不能对其造成有效伤害，使用“禁咒爆竹”，可在短时间内破其护体戾气。妖物强悍，恐怕要和几多好友一起去收服方能奏效，万万小心！！
    活动期间每个玩家都能免费从龙五太爷处得到道具“禁咒爆竹”，想要多获取的话就要多多参加新年活动了。
    详情可去新手村询问龙五太爷或打开帮助锦囊（F12）查看！
]],
};

function tbNpc:OnAboutNewYears(nSel)
	if nSel then
		Dialog:Say(self.tbAboutNewYears[nSel], {{"Quay lại", self.OnAboutNewYears, self}});
		return 0;
	end
	local szMsg = "新年活动如此之多，不知你要了解哪一个？"; 
	local tbOpt = {
		{"打雪仗", 		self.OnAboutNewYears, self, 1},
		{"礼官拜年，烟花漫天", self.OnAboutNewYears, self, 2},
		{"拜年任务", 	self.OnAboutNewYears, self, 3},
		{"消灭年兽", 	self.OnAboutNewYears, self, 4},
		{"我知道啦"},
	};
	Dialog:Say(szMsg, tbOpt);
end


tbNpc.tbAbout = {
[1] = [[
  <color=yellow>  2010年3月30日更新后——4月10日<color>
每天<color=yellow>10点-23点，半小时一场<color>，其中报名时间<color=yellow>4<color>分钟半；

如：10点整开始报名，10：05开启第一场，10：25结束；
22：30最后一次报名，22：35开启最后一场，23点整结束。
 
]],

[2] = [[
	1、等级达到<color=yellow>60级、已入门派<color>的玩家均可参加；
	2、每天获得<color=yellow>2<color>次参加机会，每周可累积<color=yellow>14<color>次；
	只要大侠满足以上条件，就可以单人或多人组队报名参加了！

]],
[3] = [[
<color=green>【玩法简介】<color>
	怪物来袭，我们束手无策，只有借助植物们的力量，方能消灭他们！
	<color=yellow>两个队伍相互比赛，想办法在合适的地点种植合适的植物，做好防御工事，阻止怪物通过<color>，守卫先祖之魂！
<color=green>【详细玩法】<color>
	  1、你们到了比赛场会发现大家被变成一个特殊形态，在地上可以捡到<color=yellow>“眩晕”<color>等技能，<color=yellow>只有这些技能可以阻挡来袭的敌人<color>；
	  2、通过义军<color=yellow>自动运送<color>可获得军饷，凭此在场地内的<color=yellow>五毒秘术商人<color>处购买植物；
	  3、在特定区域<color=yellow>种植<color>植物，<color=yellow>每格只可种植一棵<color>，植物可以消灭怪物；
	  4、怪物一波接一波，有时还会有<color=yellow>BOSS<color>出现！所以一定要组织好你的<color=yellow>植物战队的阵型<color>，当植物达到下一个等级的血量时会自动<color=yellow>升级植物<color>！

]],
[4] = [[
    1.虽然你报名了但是由于人数问题可能会轮空，没关系，出了准备场再报名吧。
    
    2.进了赛场后，大家属性都一样的，和角色的技能等都没有任何关系了哦。
    
    3.去商店购买蘑菇道具用来击杀怪物，其他的技能对他们都是无效的哦。
]],
[5] = [[
<color=green>【胜负判定】<color>
	1、通过<color=yellow>消灭敌人<color>来计分，若是多人比赛，会按照队伍消灭的敌人来计分。
	2、总得分高的一方获胜。
<color=green>【活动奖励】<color>
	1、消灭怪物，则有一定几率掉落<color=yellow>玄晶<color>，BOSS还可能会掉落高级玄晶！
	2、胜方可在各大新手村晏若雪处领取奖励，可能会开出<color=yellow>高级玄晶<color>！
	3、参加活动均可获得一定的荣誉点，清明节活动全部结束后，可以<color=yellow>通过累积的荣誉点获得诱人的奖励<color>！

]]
};

function tbNpc:OnAbout(nSel)
	if nSel then
		Dialog:Say(self.tbAbout[nSel], {{"Quay lại", self.OnDialog, self}});
		return 0;
	end
	local szMsg = "清明时节雨纷纷，\n路上行人欲断魂。\n剑侠世界新活动，\n植物大战侵略军！\n你想了解守护先祖之魂活动的哪些信息呢？"; 
	local tbOpt = {
		{"活动时间相关"	, self.OnAbout, self, 1},
		{"参加条件"		, self.OnAbout, self, 2},
		{"如何阻击前来进犯的怪物"	, self.OnAbout, self, 3},
		{"胜负与奖励", self.OnAbout,self, 5},
		{"注意事项"		, self.OnAbout, self, 4},
		{"我知道啦"		, self.OnDialog, self},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnAboutYanHua()
	local szMsg = [[
	  活动期间，每天晚上8点到9点，每6分钟，礼官会去各大门派拜年，3分钟后离开，所以当系统提示要尽快前往。
    礼官会送你“新年烟花”和随机奖励，奖励多多，务必参加为是。新年烟花需要在各大城市新手村礼官附近的“烟花燃放处”使用才有效果。 
    详情可去各大城市新手村询问礼官或打开帮助锦囊（F12）查看。
]];
	Dialog:Say(szMsg);
end

function tbNpc:OnAboutNianShou()
	local szMsg = [[
	你用“引魂雾”在野外诱出这妖物，如果和其蛮干，几乎不能对其造成任何损伤，因其有“上古戾气”护体，若点燃我给你的“禁咒爆竹”，则可使其在短时间内护体戾气崩裂，在妖物重新聚集戾气的空隙就可对其造成有力打击。
妖物强悍，恐怕要和几多好友一起去收服方能奏效，万万小心！！
]];
	Dialog:Say(szMsg);
end


------------------------