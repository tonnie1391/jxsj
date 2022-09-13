-- 文件名　：dingding.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-06-05 10:25:46
-- 描  述  ：

local tbNpc = Npc:GetClass("girl_dingding");
tbNpc.SZ_UPLOAD_PHOTO_URL = "http://mm2012.jxsj.xoyo.com/belle2012/"

function tbNpc:OnDialog()
	-- if SpecialEvent.Girl_Vote:IsDailyOpen() >= 1 then
		-- SpecialEvent.Girl_Vote:OnDialog_Daily();
		-- return 0;
	-- end
	-- if SpecialEvent.Girl_Vote:IsOpen() ~= 1 then
		-- Dialog:Say("你好，我是丁丁姑娘！！");
		-- return 0;
	-- end
	
	-- if SpecialEvent.Girl_Vote:CheckState(1, 8) ~= 1 then
		-- Dialog:Say("你好，我是丁丁姑娘！！");
		-- return 0;
	-- end
	
	-- local szMsg = [[
	-- “武林第一美女海选”活动火爆开启！
	-- 谁的微笑动人心弦，谁的眼眸让你魂牵？谁又能倾城倾国，武林第一美女最后花落谁家？还在犹豫什么呢，快快点击你的鼠标，报名参加吧！（更多详情参见F12最新活动）
	-- 参加条件：<color=green>所有女性玩家都可参加<color>
	-- 活动奖励：绚丽光环、限量面具、尊贵称号、高级玄晶（不绑定）、<color=pink>绝版极品属性项链[海洋之心]<color> 以及实物大奖<color=pink>施华洛世奇限量版项链[海洋之心]<color>等你拿。
	-- ]];
	-- local tbOpt = {
			-- {"我要给美女投票", self.State1VoteTickets, self},
			-- {"<color=yellow>我要参加美女认证<color>", self.AttendGirlLogo, self},
			-- {"查询排行票数信息", self.Query, self},
			-- {"领取我的参赛奖励", self.GetAward, self},
			-- {"购买海洋之心项链", self.OpenShop, self},
			-- {"了解活动详细信息", self.GetDetailInfo, self},
			-- {"Ta chỉ xem qua Xóa bỏ"},
		-- };
	-- if SpecialEvent.Girl_Vote:CheckState(1, 6) == 1 then
		-- table.insert(tbOpt, 1, {"<color=yellow>我要上传照片<color>", self.UploadPhoto, self});
	-- end
	-- if SpecialEvent.Girl_Vote:CheckState(1, 3) == 1 and SpecialEvent.Girl_Vote:IsHaveGirl(me.szName) == 0 then
		-- table.insert(tbOpt, 1, {"<color=yellow>我要报名参加<color>", self.State1SignUp, self});
	-- end
	Dialog:Say("Chào vị thiếu hiệp! Ta vẫn khỏe");
end

function tbNpc:OpenShop()
	local nFaction = me.nFaction;
	if nFaction <= 0 or me.GetCamp() == 0 then
		Dialog:Say("请先加入门派后再够买项链");
		return 0;
	end
	me.OpenShop(228, 1, 100, -1) --使用声望购买
end

function tbNpc:AttendGirlLogo()
	if me.nSex ~= 1 then
		local szMsg = "只有美女才可以参加这次选美，你这小子可不要糊弄本姑娘！    "
		local tbOpt = {
			{"前往官网看美女", self.State1SignUp, self, 1},
			{"Ta chỉ xem qua"},
		};
		Dialog:Say(szMsg, {{"去官网看看", self.GoToURL, self}, {"Để ta suy nghĩ thêm"}});	
		return 0;
	end
	if SpecialEvent.Girl_Vote:IsHaveGirl(me.szName) == 1 then
		local szMsg = [[
		你已经<color=green>成功报名<color>。
		
		报名2小时后前往官网补充资料、上传个人照片，就可获得剑侠世界<color=pink>“美女认证”<color>光环、面具等<color=pink>美女专享特权<color>，还将有更多惊喜大奖等着你！
		]]
		Dialog:Say(szMsg, {{"前往官网补充个人资料", self.GoToURL, self}, {"Ta chỉ xem qua Xóa bỏ"}});
		return 0;
	end	
	Dialog:Say("你还<color=red>未报名<color>，请先报名才能参加", {{"我要参加", self.State1SignUp, self}, {"Để ta suy nghĩ thêm"}});
	return 0;
end
	

function tbNpc:GetAwardDay(nFlag)
	local szMsg = "每位参赛者投票期间每天在本服务器中得到一定数量的玫瑰后，都可得到精美光环称号（每天0点结算前一天投票数，第2天领取光环，有效期1天，当天未领取视为放弃）。\n每天收到<color=yellow>99朵<color>玫瑰，获得光环<color=pink>人气宝贝<color>";
	if not nFlag then
		Dialog:Say(szMsg, {"领取光环", self.GetAwardDay, self, 1});
		return 0;
	end
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	--不在投票期不能领每日投票的奖励
	if SpecialEvent.Girl_Vote:CheckState(2, 6) == 0 and nNowDate ~= 20120331 then
		Dialog:Say("只有2012年3月5日-2012年3月31日才能领取该奖励。");
		return 0;
	end
	if not SpecialEvent.Girl_Vote.tbGblBuf3[me.szName] then
		Dialog:Say("昨天并没有您的投票。");
		return 0;
	end
	if SpecialEvent.Girl_Vote.tbGblBuf3[me.szName][2] < 99 then
		Dialog:Say(string.format("您昨天的得票数为<color=yellow>%s朵<color>，没有奖励可以领取。", SpecialEvent.Girl_Vote.tbGblBuf3[me.szName][2]));
		return 0;
	end
	local nGetDate = me.GetTask(SpecialEvent.Girl_Vote.TSK_GROUP, SpecialEvent.Girl_Vote.TSK_Award_Title_Day);
	if nGetDate == nNowDate then
		Dialog:Say("今天的奖励您已经领取了。");
		return 0;
	end
	local nTime = math.max(3600, 24 * 3600 - (GetTime() - Lib:GetDate2Time(nNowDate)));		--领取的时间为当天剩余的时间(如果不足1小时的按一小时算)
	me.AddSkillState(2578, 1, 1, nTime * 18, 1,0,1);
	me.Msg("恭喜你获得人气宝贝称号。");
	me.SetTask(SpecialEvent.Girl_Vote.TSK_GROUP, SpecialEvent.Girl_Vote.TSK_Award_Title_Day, nNowDate);		
end

function tbNpc:GetAward()
	local szMsg = [[
    【每日领奖】：3月5日-3月30日 每天一次。                       
    【初赛领奖】：4月6日-4月9日                   
    【决赛领奖】：4月6日-4月16日     
	]];
	local tbOpt = {
		{"领取参赛者每日奖励", self.GetAwardDay, self},
		{"领取初赛奖励", self.GetAward1, self},
		{"领取初赛投票奖励", self.GetAwardEx1, self},
		{"领取决赛奖励", self.GetAward2, self},
		{"领取决赛投票奖励", self.GetAwardEx2, self},
		{"Ta chỉ đến xem thôi"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GetAwardEx1()
	if tonumber(GetLocalDate("%Y%m%d")) < (SpecialEvent.Girl_Vote.STATE_AWARD[1]) then
		Dialog:Say("美女评选初赛粉丝奖励还未开始领取");
		return 0;
	end
	if tonumber(GetLocalDate("%Y%m%d")) >= SpecialEvent.Girl_Vote.STATE_AWARD[2] then
		Dialog:Say("美女评选初赛粉丝奖励领取已经结束");
		return 0;
	end	
	--if not SpecialEvent.Girl_Vote.tbGirlKinTong then
	--	Dialog:Say("美女评选初赛领奖还未开始，请耐心等待。");
	--	return 0;		
	--end	
	if me.GetTask(SpecialEvent.Girl_Vote.TSK_GROUP, SpecialEvent.Girl_Vote.TSK_Award_StateEx1) > 0 then
		Dialog:Say("你已经领取过奖励了，不能太贪心哦。");
		return 0;
	end	
	Dialog:AskString("哪位美女的粉丝", 16, self.GetAwardEx1_1, self);		
end

function tbNpc:GetAwardEx1_1(szName)
	if me.GetTask(SpecialEvent.Girl_Vote.TSK_GROUP, SpecialEvent.Girl_Vote.TSK_Award_StateEx1) > 0 then
		Dialog:Say("你已经领取过奖励了，不能太贪心哦。");
		return 0;
	end
	local tbBuf = SpecialEvent.Girl_Vote:GetGblBuf();
	if not tbBuf[szName] then
		Dialog:Say(string.format("美女评选中找不到美女%s的资料，如果你是某个美女的第一粉丝，请输入你该美女名字领取第一粉丝称号奖励。", szName));
		return 0;
	end
	local szFanName = tbBuf[szName][1];
	if szFanName ~= me.szName then
		Dialog:Say(string.format("你不是美女%s的第一粉丝哦，该美女的第一粉丝是%s", szName, szFanName));
		return 0;	
	end
	local nHonor = PlayerHonor:GetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_PRETTYGIRL, 0);
	local nRank = PlayerHonor:GetPlayerHonorRankByName(szName, PlayerHonor.HONOR_CLASS_PRETTYGIRL, 0);
	if nRank > 20 and nHonor < 499 then
		Dialog:Say(" 只有初赛前20名或者票数达到499的美女的第一粉丝才有奖励。");
		return 0;
	end
	if SpecialEvent.Girl_Vote:GetAward(me, 3, "您成功领取了美女评选初赛第一粉丝奖励")== 1 then
		me.SetTask(SpecialEvent.Girl_Vote.TSK_GROUP, SpecialEvent.Girl_Vote.TSK_Award_StateEx1, 1);
	end
end

function tbNpc:GetAward1()
	if tonumber(GetLocalDate("%Y%m%d")) < (SpecialEvent.Girl_Vote.STATE_AWARD[1]) then
		Dialog:Say("美女评选初赛奖励还未开始领取");
		return 0;
	end
	if tonumber(GetLocalDate("%Y%m%d")) >= SpecialEvent.Girl_Vote.STATE_AWARD[2] then
		Dialog:Say("美女评选初赛奖励领取已经结束");
		return 0;
	end
	--if not SpecialEvent.Girl_Vote.tbGirlKinTong then
	--	Dialog:Say("美女评选初赛领奖还未开始，请耐心等待。");
	--	return 0;		
	--end
	if me.nSex ~= Env.SEX_FEMALE then
		Dialog:Say("你没有报名参加美女评选活动。");
		return 1;
	end
	
	local tbBuf = SpecialEvent.Girl_Vote:GetGblBuf();	
	if not tbBuf[me.szName] then
		Dialog:Say("你没有报名参加美女评选活动。");
		return 0;
	end
	
	if me.GetTask(SpecialEvent.Girl_Vote.TSK_GROUP, SpecialEvent.Girl_Vote.TSK_Award_State1) > 0 then
		Dialog:Say("你已经领取过奖励了，不能太贪心哦。");
		return 0;
	end

	local nHonor		= PlayerHonor:GetPlayerHonorByName(me.szName, PlayerHonor.HONOR_CLASS_PRETTYGIRL, 0);
--	local nType 		= Ladder:GetType(0, Ladder.LADDER_CLASS_LADDER, Ladder.LADDER_TYPE_LADDER_ACTION, Ladder.LADDER_TYPE_LADDER_ACTION_PRETTYGIRL);
--	local tbLadderPart 	= GetTotalLadderPart(nType, 1, SpecialEvent.Girl_Vote.DEF_AWARD_ALL_RANK);
	
	local nPlayerRank	= GetPlayerHonorRankByName(me.szName, PlayerHonor.HONOR_CLASS_PRETTYGIRL, 0);
	
	local tbPassGirl 	= {};
	local tbNoPassGirl	= {};
	
--	for nRank, tbPlayer in ipairs(tbLadderPart) do
--		local szName = tbPlayer.szPlayerName;
--		if tbBuf[szName] then
--			if tonumber(tbBuf[szName][4]) == 2 then
--				tbPassGirl[szName] = nRank;
--			else
--				tbNoPassGirl[szName] = nRank;
--			end
--		end
--	end
	
	if (nPlayerRank <= SpecialEvent.Girl_Vote.DEF_AWARD_ALL_RANK and nPlayerRank > 0) then
		if tbBuf[me.szName] then
			if tonumber(tbBuf[me.szName][4]) == 2 then
				tbPassGirl[me.szName] = nPlayerRank;
			else
				tbNoPassGirl[me.szName] = nPlayerRank;
			end
		end		
	end
	

	if tbPassGirl[me.szName] then
		Dialog:Say("恭喜您进入了决赛，请先参加决赛，等待决赛结束后再领取您的奖励。");
		return 0;
	end
	
	if tbNoPassGirl[me.szName] then
		if SpecialEvent.Girl_Vote:GetAward(me, 1, "您成功领取了美女评选初赛奖励") == 1 then
			me.SetTask(SpecialEvent.Girl_Vote.TSK_GROUP, SpecialEvent.Girl_Vote.TSK_Award_State1, 1);
		end
		return 0;
	end
	
	if nHonor >= SpecialEvent.Girl_Vote.DEF_AWARD_TICKETS then
		if SpecialEvent.Girl_Vote:GetAward(me, 1, "您成功领取了美女评选初赛奖励") == 1 then
			me.SetTask(SpecialEvent.Girl_Vote.TSK_GROUP, SpecialEvent.Girl_Vote.TSK_Award_State1, 1);
		end
		return 0;
	end
	
	Dialog:Say("很遗憾，按你的排名和票数，你没有任何奖励可以领取。");
	return 0;
end

function tbNpc:GetAward2()
	if tonumber(GetLocalDate("%Y%m%d")) < (SpecialEvent.Girl_Vote.STATE_AWARD[3]) then
		Dialog:Say("美女评选决赛奖励还未开始领取");
		return 0;
	end
	if tonumber(GetLocalDate("%Y%m%d")) >= SpecialEvent.Girl_Vote.STATE_AWARD[4] then
		Dialog:Say("美女评选决赛奖励领取已经结束");
		return 0;
	end
	
	if me.nSex ~= Env.SEX_FEMALE then
		Dialog:Say("这是全区全服前十名美女的奖励，没有你的份哦。");
		return 1;
	end
	
	if not SpecialEvent.Girl_Vote.tbFinishWinList then
		Dialog:Say("美女评选决赛奖励还未开始领取");
		return 0;		
	end
	local szGateWay = string.sub(GetGatewayName(), 5, 6);
	if not SpecialEvent.Girl_Vote.tbFinishWinList[szGateWay] then
		Dialog:Say("对不起，你不是全区全服前十名的美女。");
		return 0;
	end
	if not SpecialEvent.Girl_Vote.tbFinishWinList[szGateWay][me.szName] then
		Dialog:Say("对不起，你不是全区全服前十名的美女。");
		return 0;
	end
	if me.GetTask(SpecialEvent.Girl_Vote.TSK_GROUP, SpecialEvent.Girl_Vote.TSK_Award_State2) > 0 then
		Dialog:Say("你已经领取过奖励了，不能太贪心哦。");
		return 0;
	end
	local tbInfo = SpecialEvent.Girl_Vote.tbFinishWinList[szGateWay][me.szName];
	local nType = 2;
	if tbInfo.nRank > 1 and tbInfo.nRank <= 10 then
		nType = 4;
	end 
	if tbInfo.nRank == 1 then
		nType = 5;
	end
	if SpecialEvent.Girl_Vote:GetAward(me, nType, string.format("<color=red>恭喜您，您是剑侠世界全区全服第%s名美女！<color>\n您成功领取了美女评选决赛奖励", tbInfo.nRank)) == 1 then
		me.SetTask(SpecialEvent.Girl_Vote.TSK_GROUP, SpecialEvent.Girl_Vote.TSK_Award_State2, 1);
		local szMsg = "";
		szMsg = [[荣获剑侠世界“武林十大美女”大奖，大家快去恭喜她吧！]];
		if tbInfo.nRank == 1 then
			szMsg = [[登上了剑侠世界“武林第一美女”宝座，大家快去恭喜她吧！]];
		end
		Player:SendMsgToKinOrTong(me, szMsg, 1);
		Player:SendMsgToKinOrTong(me, szMsg, 0);
		local szFriendMsg = string.format("您的好友<color=yellow>%s<color>", me.szName) ..szMsg;
		me.SendMsgToFriend(szFriendMsg);
		szMsg = "恭喜美女<color=pink>"..me.szName.."<color>"..szMsg
		KDialog.NewsMsg(1,3,szMsg);
	end
	return 0;
end

function tbNpc:GetAwardEx2()
	if tonumber(GetLocalDate("%Y%m%d")) < (SpecialEvent.Girl_Vote.STATE_AWARD[3]) then
		Dialog:Say("美女评选决赛奖励还未开始领取");
		return 0;
	end
	if tonumber(GetLocalDate("%Y%m%d")) >= SpecialEvent.Girl_Vote.STATE_AWARD[4] then
		Dialog:Say("美女评选决赛奖励领取已经结束");
		return 0;
	end

	
	if me.GetTask(SpecialEvent.Girl_Vote.TSK_GROUP, SpecialEvent.Girl_Vote.TSK_Award_StateEx2) > 0 then
		Dialog:Say("你已经领取过奖励了，不能太贪心哦。");
		return 0;
	end
	
	if not SpecialEvent.Girl_Vote.tbFinishWinList then
		Dialog:Say("美女评选决赛粉丝奖励还未开始领取");
		return 0;		
	end	
	local szGateWay = string.sub(GetGatewayName(), 5, 6);
	
	local nHaveFans = 0;
	local szGirlName = "";
	local nRank = 0;
	for szWay, tbWay in pairs(SpecialEvent.Girl_Vote.tbFinishWinList) do
		for szName, tbInfo in pairs(tbWay) do
			if me.szName == tbInfo.szFansName and szGateWay == tbInfo.szFansGateWay then
				nHaveFans = 1;
				szGirlName = szName;
				nRank = tbInfo.nRank;
				break;
			end
		end
	end
	if nHaveFans == 0 or nRank > 10 then
		Dialog:Say("对不起，你不是全区全服前十名美女的粉丝。");
		return 0;
	end
	
	if SpecialEvent.Girl_Vote:GetAward(me, 6, string.format("你是全区全服<color=yellow>第%s名美女%s<color>的第一粉丝；您成功领取了美女评选决赛粉丝奖励", nRank, szGirlName)) == 1 then
		me.SetTask(SpecialEvent.Girl_Vote.TSK_GROUP, SpecialEvent.Girl_Vote.TSK_Award_StateEx2, 1);
	end
	return 0;	
end

function tbNpc:GoToURL()
	me.CallClientScript({"OpenWebSite", tbNpc.SZ_UPLOAD_PHOTO_URL});
end

function tbNpc:UploadPhoto()
	if me.nSex ~= Env.SEX_FEMALE then
		Dialog:Say("只有女玩家才可以上传照片，你这小子是不是有病啊？");
		return 1;
	end	
	if SpecialEvent.Girl_Vote:CheckState(1, 6) ~= 1 then
		Dialog:Say("美女评选2月28日至3月30日进行，现在不在活动期间，不能上传照片。");
		return 0;
	end
	local nAssignTime = me.GetTask(SpecialEvent.Girl_Vote.TSK_GROUP, SpecialEvent.Girl_Vote.TSK_Vote_Girl);
	if nAssignTime <= 0 then
		Dialog:Say("你还没有报名。请先报名，并在报名的2小时再后来找我，我会把你传送到对应官方网页上传照片。");
		return 2;
	end
	
	if GetTime() - nAssignTime <= 3600 then
		Dialog:Say("不要急呀，你的报名信息还在传送中，报名2小时后才可以上传照片呀！");
		return 3;
	end
	
	me.CallClientScript({"OpenWebSite", tbNpc.SZ_UPLOAD_PHOTO_URL});
	return 0;
end

function tbNpc:GetDetailInfo()
	local sz = [[
	    UiManager:OpenWindow(Ui.UI_HELPSPRITE);
	    local uiHelpSprite = Ui(Ui.UI_HELPSPRITE);
	    uiHelpSprite:OnButtonClick("BtnHelpPage", 1);
	    for key, tbNews in pairs(uiHelpSprite.tbNewsInfo) do
	        if (tbNews.szName == "武林第一美女海选开幕！") then
	            uiHelpSprite:Link_news_OnClick("", key);
	        end
	    end
	]]
	
	me.CallClientScript({"GM:DoCommand",sz});
end

function tbNpc:Query()
	if SpecialEvent.Girl_Vote:CheckState(5, 7) == 1 then
		self:Query2();
		return 0;
	end
	if SpecialEvent.Girl_Vote:CheckState(7, 8) == 1 then
		Dialog:Say("美女评选已经完全结束了。");
		return 0;
	end	
	local szMsg = "查询美女评选初赛信息";
	local tbOpt = {
			{"查询自己信息", self.QueryMyName, self},
			{"查询他人信息", self.QueryIntPutName, self},
			{"查看排行榜", self.OpenRankList, self},
			{"Kết thúc đối thoại"},
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OpenRankList()
	local sz = [[
		UiManager:OpenWindow(Ui.UI_LADDER);
		local uiLadder = Ui(Ui.UI_LADDER);
		uiLadder:OnButtonClick("BtnPage5");
		uiLadder:OnButtonClick("BtnGenre2");
	]]
	
	me.CallClientScript({"GM:DoCommand",sz});
end

function tbNpc:QueryMyName()
	local tbBuf = SpecialEvent.Girl_Vote:GetGblBuf();	
	if not tbBuf[me.szName] then
		Dialog:Say("你不是参赛选手！");
		return 0;
	end
	self:QueryByName(me.szName);
end

function tbNpc:QueryIntPutName()
	Dialog:AskString("请输入美女名字", 16, self.QueryByName, self);	
end

function tbNpc:QueryByName(szName)
	
	local tbBuf = SpecialEvent.Girl_Vote:GetGblBuf();
	if not tbBuf[szName] then
		Dialog:Say("没有该美女玩家！");
		return 0;
	end
	local nFansTickets 	= tbBuf[szName][2];
	local szFansName 	= tbBuf[szName][1];
	local nFanSex 		= tbBuf[szName][3];
	local nRank 		= GetPlayerHonorRankByName(szName, PlayerHonor.HONOR_CLASS_PRETTYGIRL, 0);	
	local nHonor		= PlayerHonor:GetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_PRETTYGIRL, 0);
	
	local szMyTickets 	= "";
	if szName ~= me.szName then
		local nUseTask		= SpecialEvent.Girl_Vote:GetTaskGirlVoteId(szName);
		local nMyTickets	= me.GetTask(SpecialEvent.Girl_Vote.TSK_GROUP, (nUseTask + SpecialEvent.Girl_Vote.DEF_TASK_SAVE_FANS - 1));
		szMyTickets = string.format("我的投票数：<color=white>%s<color>", nMyTickets);
	end
	local szRank = nRank;
	if nRank == 0 then
		szRank = "Vô";
	end
	
	local szFanSex = "男";
	if nFanSex == 1 then
		szFanSex = "女";
	end
	
	if szFansName == "" then
		szFansName = "Vô";
		nFansTickets = 0;
		szFanSex = "Vô";
	end

	local szMsg = string.format([[
		<color=green>------美女玩家投票明细------
		
		美女玩家：<color=white>%s<color>
		总 排 名：<color=white>%s<color>
		总 票 数：<color=white>%s<color>
		
		第一粉丝：<color=white>%s<color>
		第一粉丝票数：<color=white>%s<color>
		第一粉丝性别：<color=white>%s<color>
		
		%s
		<color>
	]], szName, szRank, nHonor, szFansName, nFansTickets, szFanSex, szMyTickets);
	Dialog:Say(szMsg, {{"Quay lại", self.Query, self},{"Kết thúc đối thoại"}});
end

--美女初选报名
function tbNpc:State1SignUp(nSure)
	if SpecialEvent.Girl_Vote:CheckState(1, 3) ~= 1 then
		Dialog:Say("美女评选报名阶段为2月28日至3月11日，现在不在报名期间，不能进行报名。");
		return 0;
	end	
	if me.nSex ~= 1 then
		local szMsg = "只有美女才可以参加这次选美，你这小子可不要糊弄本姑娘！    "
		local tbOpt = {
			{"前往官网看美女", self.State1SignUp, self, 1},
			{"Ta chỉ xem qua"},
		};
		Dialog:Say(szMsg, {{"去官网看看", self.GoToURL, self}, {"Để ta suy nghĩ thêm"}});	
		return 0;
	end
	if SpecialEvent.Girl_Vote:IsHaveGirl(me.szName) == 1 then
		local szMsg = [[
		你已经<color=green>成功报名<color>。
		
		报名2小时后前往官网补充资料、上传个人照片，就可获得剑侠世界<color=pink>“美女认证”<color>光环、面具等<color=pink>美女专享特权<color>，还将有更多惊喜大奖等着你！
		]]
		Dialog:Say(szMsg, {{"前往官网补充个人资料", self.GoToURL, self}, {"Ta chỉ xem qua Xóa bỏ"}});
		return 0;
	end
	
	if not nSure then
		local szMsg = [[你确定要参加“武林第一美女海选”吗？]];
		local tbOpt = {
			{"确定参加", self.State1SignUp, self, 1},
			{"Ta chỉ xem qua"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	GCExcute({"SpecialEvent.Girl_Vote:SignUpBuf", me.szName});
	me.AddTitle(6,95,1,5);
	me.SetCurTitle(6,95,1,5);
	me.SetTask(SpecialEvent.Girl_Vote.TSK_GROUP, SpecialEvent.Girl_Vote.TSK_Vote_Girl, GetTime());
	local szMsgWorld = [[报名参加了<color=yellow>“武林第一美女海选”<color>活动，炫目光环，极品装备甚至神秘大奖等着她，大家快去给她捧场啊！]]
	Player:SendMsgToKinOrTong(me, szMsgWorld, 1);
	Player:SendMsgToKinOrTong(me, szMsgWorld, 0);
	szMsgWorld = string.format("您的好友<color=yellow>%s<color>", me.szName) ..szMsgWorld;
	me.SendMsgToFriend(szMsgWorld);
	KDialog.NewsMsg(1,3,szWorldMsg);
	StatLog:WriteStatLog("stat_info", "prety_lady", "lady_entry", me.nId, 1);
	local szDialogMsg = [[
	恭喜你，<color=green>已成功报名！<color>
	2小时后前往官网补充资料、上传个人照片，就可获得剑侠世界“美女认证”技能光环、面具等美女专享特权，还将有更多惊喜大奖等着你！    
		]];
	Dialog:Say(szDialogMsg, {{"去官网看看", self.GoToURL, self}, {"Để ta suy nghĩ thêm"}});	
	return 0;
end

function tbNpc:State1VoteTickets(nExTicket)
	if SpecialEvent.Girl_Vote:CheckState(5, 6) == 1 then
		self:State2VoteTickets();
		return 0;
	end
	
	if SpecialEvent.Girl_Vote:CheckState(2, 4) ~= 1 then
		Dialog:Say("3月5日至3月16日是初选投票，3月19日至3月30日是决赛投票，现在不在投票期间。");
		return 0;
	end
	Dialog:AskString("请输入美女名", 16, SpecialEvent.Girl_Vote.State1VoteTickets1, SpecialEvent.Girl_Vote, nExTicket);	
end

function tbNpc:State2VoteTickets(szNextKey)
	local szMsg = "请选择你想投票的美女所在的大区";
	local tbOpt = {
		{"<color=yellow>我们服的十大美女<color>", self.State2VoteTicketsSelectServer, self, GetGatewayName()},
	};
	local tbBuf = SpecialEvent.Girl_Vote:GetGblBuf2();
	if tbBuf.tGList then
		for szZoneName in pairs(tbBuf.tGList) do
			if #tbOpt >= 6 then
				table.insert(tbOpt, {"Trang sau", self.State2VoteTickets, self, szZoneName});				
				break;
			end
			if not szNextKey then
				table.insert(tbOpt, {szZoneName, self.State2VoteTicketsSelectZone, self, szZoneName});				
			end
			if szNextKey and szNextKey == szZoneName then
				table.insert(tbOpt, {szZoneName, self.State2VoteTicketsSelectZone, self, szZoneName});
				szNextKey = nil;
			end
		end
	end
	table.insert(tbOpt, {"Ta chỉ xem qua"});
	Dialog:Say(szMsg, tbOpt);
	return 0;	
end

function tbNpc:State2VoteTicketsSelectZone(szZoneName, szNextKey)
	local tbBuf = SpecialEvent.Girl_Vote:GetGblBuf2();
	if not tbBuf.tGList[szZoneName] then
		return 0;
	end
	local szMsg = "请选择你想投票的美女所在区服";
	local tbOpt = {};
	for szServerName, szGateWay in pairs(tbBuf.tGList[szZoneName]) do
		if #tbOpt >= 6 then
			table.insert(tbOpt, {"Trang sau", self.State2VoteTicketsSelectZone, self, szZoneName, szServerName});				
			break;
		end
		if not szNextKey then
			table.insert(tbOpt, {szServerName, self.State2VoteTicketsSelectServer, self, szGateWay});					
		end
		if szNextKey and szNextKey == szServerName then
			table.insert(tbOpt, {szServerName, self.State2VoteTicketsSelectServer, self, szGateWay});					
			szNextKey = nil;
		end
	end
	table.insert(tbOpt, {"Quay lại", self.State2VoteTickets, self});
	table.insert(tbOpt, {"Ta chỉ xem qua"});
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:State2VoteTicketsSelectServer(szGateWay, szNextKey)
	local tbBuf = SpecialEvent.Girl_Vote:GetGblBuf2();
	if not tbBuf.tPList or not tbBuf.tPList[szGateWay] then
		return 0;
	end
	local szZoneName = tbBuf.tZList[szGateWay][1];
	local szMsg = "请选择你想投票的美女";
	local tbOpt = {};
	for szRoleName in pairs(tbBuf.tPList[szGateWay]) do
		if #tbOpt >= 6 then
			table.insert(tbOpt, {"Trang sau", self.State2VoteTicketsSelectServer, self, szGateWay, szRoleName});				
			break;			
		end
		if not szNextKey then
			table.insert(tbOpt, {szRoleName, SpecialEvent.Girl_Vote.State2VoteTickets1, SpecialEvent.Girl_Vote, szGateWay, szRoleName, 0});		
		end
		if szNextKey and szRoleName == szNextKey then
			table.insert(tbOpt, {szRoleName, SpecialEvent.Girl_Vote.State2VoteTickets1, SpecialEvent.Girl_Vote, szGateWay, szRoleName, 0});		
			szNextKey = nil;
		end
	end
	table.insert(tbOpt, {"Quay lại", self.State2VoteTicketsSelectZone, self, szZoneName});
	table.insert(tbOpt, {"Ta chỉ xem qua"});
	Dialog:Say(szMsg, tbOpt);	
end

function tbNpc:Query2()
	local szMsg = "查询美女评选决赛信息";
	local tbOpt = {
			{"查询自己信息", self.State2QueryMyName, self},
			{"查询本区服美女信息", self.State2QueryMyServer, self, GetGatewayName()},
			{"查询各区服美女信息", self.State2QueryByZone, self},
			{"Kết thúc đối thoại"},
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:State2QueryMyName()
	local szGateWay = GetGatewayName();
	if SpecialEvent.Girl_Vote:IsHaveGirl2(szGateWay, me.szName) ~= 1 then
		Dialog:Say("对不起，你不是入围决赛的美女玩家。");
		return 0;
	end
	self:State2QueryByName(szGateWay, me.szName)
end

function tbNpc:State2QueryByZone()
	local szMsg ="请选择你想查询的美女所在的大区";
	local tbOpt = {};
	local tbBuf = SpecialEvent.Girl_Vote:GetGblBuf2();
	if tbBuf.tGList then
		for szZoneName in pairs(tbBuf.tGList) do
			table.insert(tbOpt, {szZoneName, self.State2QueryByServer, self, szZoneName});
		end
	end
	table.insert(tbOpt, {"Ta chỉ xem qua"});
	Dialog:Say(szMsg, tbOpt);
	return 0;		
end

function tbNpc:State2QueryByServer(szZoneName, szNextKey)
	local tbBuf = SpecialEvent.Girl_Vote:GetGblBuf2();
	if not tbBuf.tGList[szZoneName] then
		return 0;
	end
	local szMsg = "请选择你想查询的美女所在的服务器。";
	local tbOpt = {};
	for szServerName, szGateWay in pairs(tbBuf.tGList[szZoneName]) do
		if #tbOpt >= 6 then
			table.insert(tbOpt, {"Trang sau", self.State2QueryByServer, self, szZoneName, szServerName});				
			break;			
		end
		if not szNextKey then
			table.insert(tbOpt, {szServerName, self.State2QueryMyServer, self, szGateWay});	
		end
		if szNextKey and szNextKey == szServerName then
			table.insert(tbOpt, {szServerName, self.State2QueryMyServer, self, szGateWay});	
			szNextKey = nil;
		end		
			
	end
	table.insert(tbOpt, {"Quay lại", self.State2QueryByZone, self});
	table.insert(tbOpt, {"Ta chỉ xem qua"});
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:State2QueryMyServer(szGateWay, szNextKey)
	local tbBuf = SpecialEvent.Girl_Vote:GetGblBuf2();
	if not tbBuf.tPList or not tbBuf.tPList[szGateWay] then
		return 0;
	end
	local szMsg = "请选择你想查看的美女。";
	local szZoneName = tbBuf.tZList[szGateWay][1];
	local tbOpt = {};
	for szRoleName in pairs(tbBuf.tPList[szGateWay]) do
		if #tbOpt >= 6 then
			table.insert(tbOpt, {"Trang sau", self.State2QueryMyServer, self, szGateWay, szRoleName});				
			break;			
		end
		if not szNextKey then
			table.insert(tbOpt, {szRoleName, self.State2QueryByName, self, szGateWay, szRoleName});		
		end
		if szNextKey and szNextKey == szRoleName then
			table.insert(tbOpt, {szRoleName, self.State2QueryByName, self, szGateWay, szRoleName});		
			szNextKey = nil;
		end
	end
	table.insert(tbOpt, {"Quay lại", self.State2QueryByServer, self, szZoneName});
	table.insert(tbOpt, {"Ta chỉ xem qua"});
	Dialog:Say(szMsg, tbOpt);		
end

function tbNpc:State2QueryByName(szGateWay, szName)
	if SpecialEvent.Girl_Vote:IsHaveGirl2(szGateWay, szName) ~= 1 then
		Dialog:Say("没有该美女玩家！");
		return 0;
	end
	
	local tbBuf = SpecialEvent.Girl_Vote:GetGblBuf2();
	local tbRole= tbBuf.tPList[szGateWay][szName];
	local nTickets = tbRole[2];
	local szDescGate  = tbBuf.tZList[szGateWay][1];
	local szDescServer= tbBuf.tZList[szGateWay][2];
	local szFans="";
	for i=1, 5 do
		local szFansName = "<color=gray>无粉丝<color>"
		if tbRole[3] and tbRole[3][i] and tbRole[3][i][1] then
		 szFansName = tbRole[3][i][1]
		end
		local nFansTickets = 0;
		if tbRole[3] and tbRole[3][i] and tbRole[3][i][2] then
		 nFansTickets = tbRole[3][i][2]
		end		
		szFans = szFans .. string.format("本服第%s粉丝：<color=white>%s<color> 票数：<color=white>%s<color>\n", i, szFansName, nFansTickets);
	end
	
	local szMyTickets 	= "";
	if szGateWay ~= GetGatewayName() or szName ~= me.szName then
		local nUseTask		= SpecialEvent.Girl_Vote:GetTaskGirlVoteId2(szGateWay, szName);
		local nMyTickets	= me.GetTask(SpecialEvent.Girl_Vote.TSK_GROUP, (nUseTask+4));
		szMyTickets = string.format("我的投票数：<color=white>%s<color>", nMyTickets);
	end

	local szMsg = string.format([[
		<color=green>------美女玩家投票明细------
		
美女玩家：<color=white>%s<color>
大    区：<color=white>%s<color>
服 务 器：<color=white>%s<color>
		
总 排 名：<color=white>请查看官方网站<color>
总 票 数：<color=white>请查看官方网站<color>
本服票数：<color=white>%s<color>
		
%s
		
%s
<color>
	]], szName, szDescGate, szDescServer, nTickets, szFans, szMyTickets);
	Dialog:Say(szMsg, {{"Quay lại", self.Query, self},{"Kết thúc đối thoại"}});
end

------------------------------------------------------------------------------------------------
--木偶

local tbNpc1 = Npc:GetClass("girl_dingding_Ex");

function tbNpc1:OnDialog()
	if SpecialEvent.Girl_Vote:IsOpen() ~= 1 then
		Dialog:Say("你好，我是玫瑰小仙子！！");
		return 0;
	end
	
	if SpecialEvent.Girl_Vote:CheckState(1, 8) ~= 1 then
		Dialog:Say("你好，我是玫瑰小仙子！！");
		return 0;
	end
	if not him.GetTempTable("Npc").szGril2012_Name then
		Dialog:Say("你好，我是玫瑰小仙子！！");
		return 0;
	end
	local szName = him.GetTempTable("Npc").szGril2012_Name;
	local szMsg = string.format([[<color=yellow>“武林第一美女”<color>海选火爆进行中！<color><enter><enter>你好，我是<color=green>%s<color>的召唤小精灵。你要送花给我的主人吗？她可是位大美人哦！<enter>（在我这里投票有20%%的票数加成。）]], szName);
	local nHonor = PlayerHonor:GetPlayerHonorByName(szName, PlayerHonor.HONOR_CLASS_PRETTYGIRL, 0);
	local nRank = PlayerHonor:GetPlayerHonorRankByName(szName, PlayerHonor.HONOR_CLASS_PRETTYGIRL, 0);
	if SpecialEvent.Girl_Vote:CheckState(2, 4) == 1 then
		szMsg = szMsg..string.format("\n\n美女<color=green>%s<color>当前票数：%s票\t第%s名", szName, nHonor, nRank)
	end
	local tbOpt = {
			{"我要给美女投票", self.VoteTickets, self, szName, 2},
			{"查询排行及票数信息", tbNpc.Query, tbNpc},
			{"Ta chỉ xem qua Xóa bỏ"},
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc1:VoteTickets(szName, nExTicket)
	--决赛阶段
	if SpecialEvent.Girl_Vote:CheckState(5, 6) == 1 then
		local szIsHave = SpecialEvent.Girl_Vote:IsHaveGirl2Ex(szName);
		if not szIsHave then
			Dialog:Say("玫瑰精灵助战的美女未进入决赛，不可以被投票。");
			return 0;
		end
		SpecialEvent.Girl_Vote:State2VoteTickets1(szIsHave, szName, nExTicket);
		return 0;
	end
	--初赛阶段
	if SpecialEvent.Girl_Vote:CheckState(2, 4) ~= 1 then
		Dialog:Say("3月5日至3月16日是初选投票，3月19日至3月30日是决赛投票，现在不在投票期间。");
		return 0;
	end
	SpecialEvent.Girl_Vote:State1VoteTickets1(szName, nExTicket);
end

------------------------------------------------------------------------------------------------
--告示板

local tbBoard = Npc:GetClass("Girl_Board");

function tbBoard:OnDialog()
	tbNpc:Query();
end

------------------------------------------------------------------------------------------------
--助战npc	10105--10115郝漂靓\沈荷叶\白秋琳\尹筱雨\洁羽公主\红姨\玫瑰花坛\玫瑰花坛\玫瑰精灵1\玫瑰精灵2\玫瑰精灵3
local tbTemp = Npc:GetClass("Girl_Temp");
tbTemp.tbMsg = {
	[10105] = "众多姐们都在参加选美，我也不忘来凑凑热闹。\n\n你看，姐姐今天的妆漂亮吗？",
	[10106] = "前段时间为这选美，每天都赶工制作面具和外装，可把我们铺子的人都忙死了。不过做出的东西，可真真是好看！",
	[10107] = "如今义军数量一天天庞大，军中美人也越来越多。\n\n你看，原来一个个黄毛丫头，现在全都出落的这般水灵，秋姨我真是开心啊！",
	[10108] = "最近大家都在传言，有一件绝世装备惊现武林，不知道是真是假。\n\n你可以去帮我打探打探吗？",
	[10109] = "晃眼几年就过去了，我总还记得上一次武林美女海选的情景。\n\n你可懂得，这高处不胜寒的寂寞？",
	[10110] = "待到选出这第一美女，红姨我一定帮她寻一门好婚事！",
	}
function tbTemp:OnDialog()
	local szMsg = self.tbMsg[him.nTemplateId] or "你好，我是"..him.szName;
	Dialog:Say(szMsg)
end
