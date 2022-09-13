-- npc_signup.lua
-- zhouchenfei
-- 报名npc
-- 2010/11/6 13:53:08

Require("\\script\\mission\\castlefight\\castlefight_def.lua");

local tbNpc = Npc:GetClass("castlefight_signup");

tbNpc.DEF_EVENT_TYPE = CastleFight.DEF_EVENT_TYPE;

function tbNpc:OnDialog()
	local szMsg = "Tại đây có thể báo danh Dạ Lam Quan";
	local tbOpt = {};
	
	local tbConsole = CastleFight:GetConsole();
	if (not tbConsole) then
		Dialog:Say("Hoạt động này chưa mở!");
		return 0;
	end

	CastleFight:TaskDayEvent();

	local nTotal = me.GetTask(CastleFight.TSK_GROUP, CastleFight.TSK_ATTEND_TOTAL);
	local nCountSum, nCount, nCountEx = CastleFight:IsSignUpByTask(me);
	local nUseItem = me.GetTask(CastleFight.TSK_GROUP, CastleFight.TSK_USE_ITEM_TIMES);

	local szMsg = string.format([[    Chào mừng đến với Khiêu chiến Dạ Lam Quan.
    Số lượt khiêu chiến có được có thể nhận được bằng cách sử dụng <color=yellow>Dạ Lam Minh Đăng<color>. Dạ Lam Minh Đăng mua tại cửa hàng Nguyệt Ảnh Thạch.
    
<color=green>Số lượt có thể tham gia: <color=yellow>%s<color> lượt<color>
<color=green>Số lượt đã tham gia: <color=yellow>%s/%s<color> lượt<color>
<color=green>Số lượt tham gia hôm nay: <color=yellow>%s<color> lượt<color>]], nCountSum, nTotal, CastleFight.DEF_MAX_TOTAL_NUM, nUseItem);


	local tbOpt = {
		{"Bảng xếp hạng", self.OnOpenRank, self},
		{"Cửa hàng Nguyệt Ảnh Thạch", self.GetExCount, self},
		{"Quy tắc hoạt động", self.OnAbout, self},
		{"Ta chỉ xem qua"},
	};
	
	local szJoinMsg = "<color=yellow>Báo danh Dạ Lam Quan<color>"
	
	if (CastleFight:IsSignUpByAward(me) > 0) then
		table.insert(tbOpt, 1, {"<color=yellow>Nhận thưởng<color>", self.GetAward, self});
	end

	if (tbConsole:CheckState() ~= 1) then
		szMsg = "<color=red>Hiện tại sự kiện vẫn chưa mở.<color>\n<color=yellow>玉兔吉祥，金兔送福 ，卯兔兆丰年。夜岚关关主石破天为找出智勇双全的真英雄，特地托我向武林之上侠客发出邀请，参加决战夜岚关活动。<color>\n开放时间：\n<color=yellow>1月18日-2月17日\n上午10:00-晚上11:30<color>\n整点和半点开始报名，报名时间5分钟";
		szJoinMsg = "<color=gray>Báo danh Dạ Lam Quan<color>"
	end

	if (tbConsole:CheckAwardState() == 1) then
		table.insert(tbOpt, 1, {"Nhận thưởng xếp hạng", self.GetFinishAward, self});
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end

	table.insert(tbOpt, 1, {szJoinMsg, CastleFight.OnDialog_SignUp, CastleFight});
	
	Dialog:Say(szMsg, tbOpt);
end


function tbNpc:GetFinishAward()
	local nCurDate = tonumber(GetLocalDate("%Y%m%d%H%M"));
	local nCurDateEx = tonumber(GetLocalDate("%Y%m%d"));

	local tbConsole = CastleFight:GetConsole();
	if (not tbConsole) then
		Dialog:Say("Hiện tại sự kiện vẫn chưa mở. 开放时间在1月25日-2月14日每天上午10：00-晚上11：30，每逢半点、整点请在我这里报名吧。");
		return 0;
	end
	
	if (tbConsole:CheckAwardState() ~= 1) then
		Dialog:Say("Bây giờ không phải thời gian nhận thưởng!");
		return 0;
	end

	if me.GetTask(CastleFight.TSK_GROUP, CastleFight.TSK_AWARD_FINISH) > 0 then
		Dialog:Say("你已领取过奖励了，不能太贪心哦。");
		return 0;
	end
	local nCountSum = me.GetTask(CastleFight.TSK_GROUP, CastleFight.TSK_ATTEND_TOTAL);
	local nRank		= PlayerHonor:GetPlayerHonorRankByName(me.szName, CastleFight.DEF_HONOR_CLASS, 0);	

	local nRankType = 0;
	local szRank = string.format("Đạt hạng <color=yellow>%s<color>", nRank);
	if nRank <= 0 then
		szRank = "无排名";
	end
	if nRank > 0 then
		for nType, tbType in ipairs(CastleFight.AWARD_FINISH) do
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
	local tbAward = CastleFight.AWARD_FINISH[nRankType][2];
	if nRankType > 2 then
		local nNeedBag = tbAward[5];
		if me.CountFreeBagCell() < nNeedBag then
			Dialog:Say(string.format("你的背包空间不足，需要%s格背包空间", nNeedBag));
			return 0;
		end
		local szAwardName = "";
		for i=1, nNeedBag do
			local pItem = me.AddItem(tbAward[1], tbAward[2], tbAward[3], tbAward[4]);
			if pItem then
--				me.SetItemTimeout(pItem, 30*24*60, 0);
--				pItem.Sync();
				szAwardName = pItem.szName;
			end
		end
		me.SetTask(CastleFight.TSK_GROUP, CastleFight.TSK_AWARD_FINISH, 1);
		Dialog:Say(string.format("你参加决战夜岚关，%s，共成功参加%s场，获得了%s个%s。", szRank, nCountSum, nNeedBag, szAwardName));
		EventManager:WriteLog(string.format("[新年活动]最终排名获得了%s个%s", nNeedBag, szAwardName), me);
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[新年活动]最终排名获得了%s个%s", nNeedBag, szAwardName));
		StatLog:WriteStatLog("stat_info", "fight_YLG", "compos_award", me.nId, "compos", nRank);
	else
		if me.CountFreeBagCell() < 1 then
			Dialog:Say("你的背包空间不足，需要2格背包空间");
			return 0;
		end
		me.AddStackItem(tbAward[1], tbAward[2], tbAward[3], tbAward[4], nil, tbAward[5]);
		me.SetTask(CastleFight.TSK_GROUP, CastleFight.TSK_AWARD_FINISH, 1);
		Dialog:Say(string.format("你参加决战夜岚关，%s，共成功参加%s场，获得了%s个雪魂令。", szRank, nCountSum, tbAward[5]));
		EventManager:WriteLog(string.format("[新年活动]最终排名获得了%s个雪魂令", tbAward[5]), me);
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[新年活动]最终排名获得了%s个雪魂令", tbAward[5]));
		StatLog:WriteStatLog("stat_info", "fight_YLG", "compos_award", me.nId, "compos", nRank);
	end
end


function tbNpc:GetAward(nFlag)
	if CastleFight:IsSignUpByAward(me) <= 0 then
		Dialog:Say("想要礼物吗？想要的话就要报名加入决战夜岚关的行列哦。", {{"我会去参加的"}});		
		return 0;
	end
	
	local nAwardId = me.GetTask(CastleFight.TSK_GROUP, CastleFight.TSK_ATTEND_AWARD);
	local tbItem = CastleFight.WINNER_BOX[nAwardId];
	
	local szAward = "";
	
	if (tbItem and #tbItem >= 4) then
		szAward = string.format("<color=yellow>%s<color>",KItem.GetNameById(unpack(tbItem)));
		if me.CountFreeBagCell() < 1 then
			me.Msg("您背包空间不足，请整理1格背包空间。");
			return 0;
		end		
		
		local pItem = me.AddItem(unpack(tbItem));
		if pItem then
			pItem.Bind(1);
			CastleFight:WriteLog("得到物品"..pItem.szName, me.nId);
			EventManager:WriteLog("[新年活动]获得"..pItem.szName, me);
			me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, "[新年活动]获得"..pItem.szName);
		end
	elseif (tbItem and #tbItem == 1) then
		szAward = string.format("<color=yellow>绑定银两%s<color>", tbItem[1]);
		me.AddBindMoney(tbItem[1], Player.emKBINDMONEY_ADD_EVENT);
		CastleFight:WriteLog(string.format("得到绑银%s", tbItem[1]), me.nId);
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[新年活动]得到绑银%s", tbItem[1]));
	end
	
	me.SetTask(CastleFight.TSK_GROUP, CastleFight.TSK_ATTEND_AWARD, 0);
	
	Dialog:Say(string.format("由于你上一场比赛的出色表现奖励你%s，继续努力！", szAward), {{"谢谢", self.OnDialog, self}});
	return 0;
end

function tbNpc:OnOpenRank()
	local nTotal = me.GetTask(CastleFight.TSK_GROUP, CastleFight.TSK_ATTEND_TOTAL);
	local nWin 	 = me.GetTask(CastleFight.TSK_GROUP, CastleFight.TSK_ATTEND_WIN);
	local nTie 	 = me.GetTask(CastleFight.TSK_GROUP, CastleFight.TSK_ATTEND_TIE);
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
	me.CallClientScript({"UiManager:OpenWindow", "UI_LADDER", 2,2});
end

function tbNpc:GetExCount()
	local nTotal = me.GetTask(CastleFight.TSK_GROUP, CastleFight.TSK_ATTEND_TOTAL);
	if (nTotal >= CastleFight.DEF_MAX_TOTAL_NUM) then
		Dialog:Say("您参与本lần活动lần数已达上限，无法继续参加。");
		return 0;
	end
	
	me.OpenShop(166,3);

	return 0;
	
--	Dialog:OpenGift("放入月影石【每个月影之石可以兑换两lần参加决战夜岚关活动的资格哦】", {"CastleFight:CheckGiftSwith"}, {self.OnOpenGiftOk, self});
end

function tbNpc:OnOpenGiftOk(tbItemObj)
	local nSum = 0;
	local szItemParam = string.format("%s,%s,%s,%s",unpack(CastleFight.SNOWFIGHT_ITEM_EXCOUNT));
	for _, tbItem in pairs(tbItemObj) do
		local szPutParam = string.format("%s,%s,%s,%s",tbItem[1].nGenre,tbItem[1].nDetail,tbItem[1].nParticular,tbItem[1].nLevel);
		if szPutParam ~= szItemParam then
			me.Msg("我只需要月影之石，请不要放入其他物品。");
			return 0;
		end
		nSum = nSum + tbItem[1].nCount;
	end
	local nCurDay = tonumber(GetLocalDate("%Y%m%d"));
	local nTaskDay = me.GetTask(CastleFight.TSK_GROUP, CastleFight.TSK_NEWYEAR_LIANHUA_DAY);
	if nTaskDay < nCurDay then
		me.SetTask(CastleFight.TSK_GROUP, CastleFight.TSK_NEWYEAR_LIANHUA_DAY, nCurDay);
		me.SetTask(CastleFight.TSK_GROUP, CastleFight.TSK_NEWYEAR_LIANHUA_COUNT, 0);
	end 
	
	local nTaskCount = me.GetTask(CastleFight.TSK_GROUP, CastleFight.TSK_NEWYEAR_LIANHUA_COUNT);

	local nCount = me.GetTask(CastleFight.TSK_GROUP, CastleFight.TSK_ATTEND_COUNT);
	local nExCount = me.GetTask(CastleFight.TSK_GROUP, CastleFight.TSK_ATTEND_EXCOUNT)
	local nTotal = me.GetTask(CastleFight.TSK_GROUP, CastleFight.TSK_ATTEND_TOTAL);
	if (nTotal + nCount + nExCount >= CastleFight.DEF_MAX_TOTAL_NUM) then
		me.Msg("您已经参加活动的lần数和剩余挑战资格已经超过最大参加活动的lần数，不能兑换！");
		return 0;
	end
	
	local nDelCount = 0;
	local nTotalNum	= 0;
	for _, tbItem in pairs(tbItemObj) do
		local nCount = tbItem[1].nCount;
		if me.DelItem(tbItem[1]) ~= 1 then
			Dbg:WriteLog("CastleFight", me.szName.."决战夜岚关给予月影之石", "删除失败")
		else
			nDelCount = nDelCount + 1;
			nTotalNum = nTotalNum + nCount * CastleFight.DEF_CHANGENUME;
		end
	end
	me.SetTask(CastleFight.TSK_GROUP, CastleFight.TSK_NEWYEAR_LIANHUA_COUNT, nTaskCount + nDelCount);
	me.SetTask(CastleFight.TSK_GROUP, CastleFight.TSK_ATTEND_EXCOUNT, me.GetTask(CastleFight.TSK_GROUP, CastleFight.TSK_ATTEND_EXCOUNT) + nTotalNum);
	me.Msg(string.format("您获得了<color=yellow>%slần<color>额外参赛资 ô.", nTotalNum));
end


tbNpc.tbAbout = {
[1] = [[
    比赛共分三个阶段：
    家族选拔赛阶段：单人混战。每个月的7号~20号，共计14天，活动开启时间为每天的上午11点—14点，下午19点—午夜23点，每15分钟开启一场，10点为第一场，22：45为每天最后一场，报名时间5分钟。
    家族预选赛阶段：战队对战赛。总积分排名前120的家族可以组战队进入比赛。每个月的21号~26号，共计6天。活动开启时间每天共2轮，下午及晚上各一轮：每天的15点——17点，21：30——23：00。
	家族决赛阶段：家族战队决赛，8强战队有资格进入。每个月的27号，为期1天，21：30~~23：00为比赛时间。 
]],

[2] = [[
   活动开启后，60级以上的玩家可以去各新手村找晏若雪报名参加，每个玩家每天有2lần机会。参加比赛必须有自己的Dạ Lam Quan或夜岚翡翠灯，拥有夜岚翡翠灯，杀死敌方兵可以额外获得15%的军饷。
]],
[3] = [[
<color=green>【玩法简介】<color>
每场8人进行比赛，每个队伍4人。
进入夜岚关后，自身无法使用技能，也无法攻击，操作均须使用道具（已放入快捷栏）。您的队伍必须通过消耗军饷来建造与升级建筑，方可获得攻防能力。建造与击毁建筑和敌军可获得军饷、积分。
五种兵种各具特色，哨塔可起防御作用但不产生士兵。升级后的建筑所产生的士兵将变得更强大。
当情况危急之时可以在本大营内释放倾城必杀技，有可能扭转战局。
]],
[4] = [[
1.虽然你报名了但是由于人数问题可能会轮空，没关系，出了准备场再报名吧。   
2.进了赛场后，大家属性都一样的，和角色的技能等都没有任何关系了哦。
]],
[5] = [[
    建造建筑、消灭敌方兵营、消灭敌军的玩家会获得积分，活动结束后按照本场玩家所获得的积分排名，领取奖励。
]]
};

function tbNpc:OnAbout(nSel)
	if nSel then
		Dialog:Say(self.tbAbout[nSel], {{"Quay lại", self.OnAbout, self}});
		return 0;
	end
	local szMsg = "决战夜岚关"; 
	local tbOpt = {
		{"活动时间相关"	, self.OnAbout, self, 1},
		{"参加条件"		, self.OnAbout, self, 2},
		{"玩法简介"		, self.OnAbout, self, 3},
		{"胜负与奖励", self.OnAbout,self, 5},
		--{"注意事项"		, self.OnAbout, self, 4},
		{"我知道啦"},
	};
	Dialog:Say(szMsg, tbOpt);
end

------------------------
