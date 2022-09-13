-- 文件名　：signup.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-05-04 16:23:47
-- 描  述  ：报名npc

local tbNpc = Npc:GetClass("dragonboat_signup");

tbNpc.tbChangeItemList = {
	[1] = {
		szContext = "Dùng 1 Nguyệt Ảnh Thạch để đổi 1 Thuyền Rồng: Phá Lãng (2 kỹ năng tấn công)",
		tbGiftParam = {
			tbAward = { {nGenre=18, nDetail=1, nParticular=327, nLevel=1,nCount=1,},},
			tbMareial = { { nGenre = 18, nDetail = 1, nParticular = 476,nLevel = 1, nCount = 1,},},
		},
	},
	[2] = {
		szContext = "Dùng 1 Nguyệt Ảnh Thạch để đổi 1 Thuyền Rồng: Thừa Phong (1 kỹ năng tấn công, 1 kỹ năng phòng thủ)",
		tbGiftParam = {
			tbAward = { {nGenre=18, nDetail=1, nParticular=327, nLevel=2,nCount=1,},},
			tbMareial = { { nGenre = 18, nDetail = 1, nParticular = 476,nLevel = 1, nCount = 1,},},
		},
	},
	[3] = {
		szContext = "Dùng 1 Nguyệt Ảnh Thạch để đổi 1 Thuyền Rồng: Li Thủy (2 kỹ năng phòng thủ)",
		tbGiftParam = {
			tbAward = { {nGenre=18, nDetail=1, nParticular=327, nLevel=3,nCount=1,},},
			tbMareial = { { nGenre = 18, nDetail = 1, nParticular = 476,nLevel = 1, nCount = 1,},},
		},
	},
	[4] = {
		szContext = "Dùng 5 Nguyệt Ảnh Thạch để đổi 1 Thuyền Rồng: Bá Châu (2 kỹ năng tấn công, 1 kỹ năng phòng thủ)",
		tbGiftParam = {
			tbAward = { {nGenre=18, nDetail=1, nParticular=327, nLevel=4,nCount=1,},},
			tbMareial = { { nGenre = 18, nDetail = 1, nParticular = 476,nLevel = 1, nCount = 5,},},
		},
	},
};

function tbNpc:OnDialog()
	local tbWeekendFishNpc = Npc:GetClass("weekednfish_npc");
	if tbWeekendFishNpc then
		tbWeekendFishNpc:OnDialog();
		return 0;
	end
	local tbDuanWuNpc = Npc:GetClass("npc_duanwu2011");
	if tbDuanWuNpc then
		tbDuanWuNpc:OnDialog();
		return 0;
	end
	
	local tbCastleNpc = Npc:GetClass("castlefight_signup");
	if (tbCastleNpc) then
		tbCastleNpc:OnDialog();
		return 0;
	end
	
	local nState = EPlatForm:GetMacthState();
	if (EPlatForm:GetMacthType(EPlatForm:GetMacthSession()) ~= 2) then
		local tbOpt = {{"Ta chỉ đến xem"},};
		if (nState == EPlatForm.DEF_STATE_REST) then
			tbOpt = {
				{"领取最终活动奖励", EPlatForm.GetPlayerAward_Final, EPlatForm},
				{"领取家族奖励", EPlatForm.GetKinAward, EPlatForm},
				{"Ta chỉ đến xem"},	
			};
		end
		Dialog:Say("现在不是赛龙舟时间，请过段时间再来吧！", tbOpt);
		return 0;	
	end		

	if EPlatForm:IsSignUpByAward(me) > 0 then
		Dialog:Say("你上次比赛的奖励还没领呢，赶快领吧。领奖吗？", 
			{
				{"好，领啊", EPlatForm.GetPlayerAward_Single, EPlatForm},
				{"Để ta suy nghĩ lại"},
			}
		);
		return 0;
	end
	
	if (nState == EPlatForm.DEF_STATE_CLOSE) then
		Dialog:Say("家族竞技还未开启！请过些天再来吧！");
		return 0;
	end

	local nNowCount = EPlatForm:UpdateEventCount(me);
	local nCount = EPlatForm:GetEventCount(me);
	local nTotalCount = EPlatForm:GetPlayerTotalCount(me);
	local szStateName = EPlatForm.DEF_STATE_MSG[nState];
	local szMsg = string.format("嘿嘿，本月的家族竞技活动呢，就是龙舟赛，在我这里参加。目前比赛已经到了<color=yellow>%s<color>，你想参加比赛吗？\n\n", szStateName);
	if (nState == EPlatForm.DEF_STATE_MATCH_1 or nState == EPlatForm.DEF_STATE_MATCH_2) then
		szMsg = string.format("%s<color=yellow>你今天剩余次数：%s次\n", szMsg, nNowCount);
		if (nState == EPlatForm.DEF_STATE_MATCH_1) then
			szMsg = string.format("%s本阶段已经参加的总场数：%d次", szMsg, nTotalCount);
		end
	end
	
	local tbOpt = {
		{"参加家族竞技——赛龙舟",			EPlatForm.tbNpc.OnDialog,		EPlatForm.tbNpc},
		{"我要查询相关赛况",				EPlatForm.tbNpc.QueryMatch,		EPlatForm.tbNpc},
		{"领取最终活动奖励",				EPlatForm.GetPlayerAward_Final,	EPlatForm},
		{"领取家族奖励",					EPlatForm.GetKinAward,			EPlatForm},
		{"月影之石商店",				self.ChangeItem,				self},
		{"龙舟改造",						self.ProductBoat,				self},
		{"了解龙舟赛",				self.OnAbout,					self},
		{"Ta chỉ xem qua"},
	};

	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:ProductBoat()
	local szMsg = "Hãy chọn thứ ngươi muốn!";
	local tbOpt = {
		-- {"Tìm hiểu hoạt động", self.AboutBoat, self},
		{"Cải tạo tấn công", self.OpenProductBoatUi, self, 1},
		{"Cải tạo phòng thủ", self.OpenProductBoatUi, self, 2},
		{"Ta chỉ xem qua"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:ChangeItem(nLevel)
	
	me.OpenShop(166,3);
	do return end;
	
	if (EPlatForm:GetMacthType(EPlatForm:GetMacthSession()) ~= 2) then
		Dialog:Say("活动还没有开放，不能兑换道具。");
		return;
	end
	
	if (not nLevel) then
		local tbOpt = {};
		for nLevel, tbInfo in ipairs(self.tbChangeItemList) do
			table.insert(tbOpt, {tbInfo.szContext, self.ChangeItem, self, nLevel});
		end
		tbOpt[#tbOpt + 1] = {"Ta chỉ đến xem"};
		Dialog:Say("Dùng 1 Nguyệt Ảnh Thạch để đổi 1艘破浪或者乘风或者离水，5个月影之石换取一艘霸舟。月影之石可以去杂货店买月影原石利用生活技能加工制作得到。你要兑换哪种道具？", tbOpt);
		return 0;
	end
	local tbParam = self.tbChangeItemList[nLevel];
	
	if (not tbParam or not tbParam.tbGiftParam) then
		return 0;
	end
	
	Dialog:OpenGift(tbParam.szContext, tbParam.tbGiftParam);
	
end

function tbNpc:AboutBoat()
	local szMSg = self.tbAbout[5][2];
	Dialog:Say(szMSg,{{"Ta hiểu rồi", self.ProductBoat, self}});
end

function tbNpc:OpenProductBoatUi(nType)
	Dialog:OpenGift("Hãy đặt Thuyền Rồng của ngươi vào", nil, {self.OnProductBoat, self, nType});
end

function tbNpc:OnProductBoat(nType, tbItem)
	if #tbItem <= 0 or #tbItem >= 2 then
		Dialog:Say("Chỉ đặt 1 Thuyền Rồng cần cải tạo");
		return 0;
	end
	local pItem = tbItem[1][1];
	local szKey = string.format("%s,%s,%s", pItem.nGenre, pItem.nDetail, pItem.nParticular)
	if szKey ~= string.format("%s,%s,%s", unpack(Esport.DragonBoat.ITEM_BOAT_ID)) then
		Dialog:Say("Hãy đặt đúng vật phẩm.");
		return 0;
	end
	local nGenId1 = Esport.DragonBoat:GetBoatRestGenId(nType, pItem)
	if nGenId1 <= 0 then
		Dialog:Say("Thuyền Rồng đã cải tạo rồi. Không thể cải tạo thêm!");
		return 0;
	end
	self:OnProductBoat1(nType, pItem.dwId);
	return 0;
end

function tbNpc:OnProductBoat1(nSel, nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local nGenId = Esport.DragonBoat:GetBoatRestGenId(nSel, pItem)
	if nGenId <= 0 then
		Dialog:Say("Thuyền Rồng đã cải tạo rồi. Không thể cải tạo thêm!", {{"Quay lại", self.OnProductBoatSel, self, nItemId},{"Kết thúc đối thoại"}});
		return 0;
	end
	
	local tbOpt = {};
	for nSelSkill, tbSkill in pairs(Esport.DragonBoat.PRODUCT_SKILL[nSel]) do
		if tbSkill[4][pItem.nLevel] then
			local szSelect = "Cải tạo-"..tbSkill[2];
			if Esport.DragonBoat:CheckSkill(pItem, tbSkill[1]) > 0 then
				szSelect = string.format("<color=green>%s<color>",szSelect);
			end
			table.insert(tbOpt, {szSelect, self.OnProductBoat2, self, nSel, nSelSkill, nItemId});
		end
	end
	--table.insert(tbOpt, {"Quay lại", self.OnProductBoat1, self, nSel, nItemId});
	table.insert(tbOpt, {"Kết thúc đối thoại"});
	Dialog:Say("Ngươi muốn cải tạo gì cho Thuyền Rồng của mình? Ta có thể giúp ngươi. Hãy nhớ mang theo ngân lượng là được. Ha ha...", tbOpt);
end

function tbNpc:OnProductBoat2(nSel, nSelSkill, nItemId) 
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	
	local nSkillId 		= Esport.DragonBoat.PRODUCT_SKILL[nSel][nSelSkill][1];
	local szSkillName 	= Esport.DragonBoat.PRODUCT_SKILL[nSel][nSelSkill][2];
	local szSkillDesc 	= Esport.DragonBoat.PRODUCT_SKILL[nSel][nSelSkill][3];
	local nNeedBindMoney = Esport.DragonBoat.PRODUCT_SKILL[nSel][nSelSkill][5];
	
	if Esport.DragonBoat:CheckSkill(pItem, nSkillId) > 0 then
		Dialog:Say("Thuyền Rồng của ngươi đã cải tạo kỹ năng này, hãy chọn kỹ năng khác", {{"Tiếp tục cải tạo", self.OnProductBoat1, self, nSel, nItemId},{"Kết thúc đối thoại"}});
		return 0;
	end
	
	local szMsg = string.format("Kỹ năng đã chọn: <color=yellow>%s<color>\n\nHiệu ứng: <color=yellow>%s<color>\n\nPhí cải tạo: <color=yellow>%s bạc khóa<color>", szSkillName, szSkillDesc, nNeedBindMoney);
	local tbOpt = {
		{"Đồng ý", self.OnProductBoat3, self, nSel, nSelSkill, nItemId},
		{"Quay lại", self.OnProductBoat1, self, nSel, nItemId},
		{"Để ta suy nghĩ lại"},
	}
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnProductBoat3(nSel, nSelSkill, nItemId) 
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local nSkillId = Esport.DragonBoat.PRODUCT_SKILL[nSel][nSelSkill][1];
	local nNeedBindMoney =Esport.DragonBoat.PRODUCT_SKILL[nSel][nSelSkill][5];
	if me.GetBindMoney() < nNeedBindMoney then
		Dialog:Say(string.format("Cải tạo kỹ năng này cần <color=yellow>%s bạc khóa<color>, hãy chuẩn bị đủ rồi thử lại.", nNeedBindMoney));
		return 0;
	end
	
	me.CostBindMoney(nNeedBindMoney, Player.emKBINDMONEY_COST_EVENT);
	
	local nGenId = Esport.DragonBoat:GetBoatRestGenId(nSel, pItem)
	if nGenId <= 0 then
		return 0;
	end
	
	pItem.SetGenInfo(nGenId, nSkillId);
	if pItem.IsBind() ~= 1 then
		pItem.Bind(1);
	end
	pItem.Sync();
	
	Dialog:Say("Cải tạo thành công!", {{"Tiếp tục cải tạo",self.ProductBoat, self},{"Kết thúc đối thoại"}});
end

tbNpc.tbAbout = {
{"何谓“寂寞划水寨”", [[
    寂寞划水寨你听说过没？什么，没听过？好吧……今天应该听说了吧。俺来告诉你俺们寂寞划水寨是干什么的。
    事情是这样子的，有一年端午节，和几个兄弟夜半月下豪饮，忽然觉得寂寞难耐。怎么办呢？大家冥思苦想，最后我提出：端午夜半，去大河之中划龙舟，既可应景还能排解此种寂寞。大家一听，齐声说好。当夜甚欢，后来就决定成立一寂寞划水山寨，我做寨主，每年端午都会去大河之中划划水，赛赛龙舟，发泄寂寞苦闷之情兼慰灵均英魂。目前我们寂寞划水寨人数越来越多，已经发展得很是壮大了。
    怎么样？是不是也想加入我们啊？哈哈~~~咳，咳，淡定！淡定！]]
},
{"活动开启时间",string.format([[
    比赛共分三个阶段：
    家族选拔赛阶段：单人混战。每个月的7号~20号，共计14天，活动开启时间为每天的10点——23点，每15分钟开启一场，10点为第一场，22：45为每天最后一场，报名时间5分钟。
    家族预选赛阶段：战队对战赛。总积分排名前120的家族可以组战队进入比赛。每个月的21号~26号，共计6天。活动开启时间每天共2轮，下午及晚上各一轮：每天的15点——17点，21：30——23：00。
	家族决赛阶段：家族战队决赛，8强战队有资格进入。每个月的27号，为期1天，21：30~~23：00为比赛时间。]])
},
{"如何参加比赛",[[
    活动开启后，60级以上的玩家可以去各新手村找秦洼报名参加，每个玩家每天有2次机会。参加比赛必须有自己的专属龙舟，龙舟可以采取一定方式获得，同时还能进行额外改造，使其具有各种特殊能力。]]
},
{"如何获得专属龙舟",[[
    龙舟的获取方式：去杂货店购买月影原石，利用生活技能制作出月影之石，再去秦洼处换取。Dùng 1 Nguyệt Ảnh Thạch để đổi 1艘普通龙舟，5个月影之石可换取龙舟·霸舟。
    ]]
},
{"了解龙舟改造",[[
    龙舟改造共有两大类：进攻性改造和防御性改造，分别有4个改造方向。
    <color=yellow>1.进攻性改造：<color>
    改造-履冰：使龙舟具有减慢其他龙舟速度的能力；
    改造-暗礁：使龙舟具有眩晕能力；
    改造-掀浪：使龙舟具有定身能力；
    改造-漩涡：使龙舟具有混乱能力。
    <color=yellow>2.防御性改造：<color>
    改造-石肤：使龙舟具有去除及免疫定身和迟缓的被动能力；
    改造-龙心：使龙舟具有去除及免疫混乱和迟缓的被动能力；
    改造-海魂：去使龙舟具有去除及免疫眩晕和迟缓的被动能力；
    改造-逆鳞：使龙舟具有去除及免疫一切负面效果的被动能力。（仅<color=yellow>龙舟：霸舟<color>可以改造）
    <color=yellow>注意：<color>不同龙舟可进行的改造是不同的，同一改造类别只能进行有限次数，次数满后就不能再进行此类改造。龙舟上有详细说明。已改造完全的龙舟将不能重新改造，所以请慎重选择改造方向。]]
},
{"比赛如何玩",[[
    报名后，您会被传入比赛场地，比赛开始时将会以自己所拥有龙舟的外观进入比赛地图，比赛开始后您就可以沿着河道的指示向终点跑去，河道内会随机出现奇怪的漂浮物，路过的话会有意想不到的结果，可能获得强力技能，神秘道具，也可能运气不好中了陷阱，甚至你可能遇到具有天罚一样的能力的柱子，通过其上会有神奇的效果。
如果撞到河道里的障碍（包括河岸上的栅栏附近，赛道中的孤岛），则会眩晕一定时间，还有机关需要躲避，获得的技能也能对对手造成不良影响，总之是机关重重，千万小心。]]
},
{"胜负及奖励",[[
    按通过终点的先后顺序或排名先后判断名次，前5名将获得宝箱，经验及荣誉等奖励，其他名次能获得经验，玄晶及荣誉等奖励。]]
},
}

function tbNpc:OnAbout()
	local szMSg = "寂寞划水山寨在此举行龙舟比赛，你要了解哪些内容呢？";
	local tbOpt = {};
	for i, tbMsg in pairs(self.tbAbout) do
		table.insert(tbOpt, {tbMsg[1], self.AboutInfo, self, i});
	end
	table.insert(tbOpt, {"Tôi hiểu"});
	Dialog:Say(szMSg, tbOpt);
end

function tbNpc:AboutInfo(nSel)
	local szMSg = self.tbAbout[nSel][2];
	Dialog:Say(szMSg,{{"Ta hiểu rồi", self.OnAbout, self}});
end
