-----------------------------------------------------
--文件名		: 	baomingdianjunxuguan.lua
--创建者		: 	zhouchenfei
--创建时间		: 	2007-10-23
--功能描述		: 	报名点军需官
------------------------------------------------------

local tbBaoJunXu	= Npc:GetClass("baomingdianjunxuguan");
tbBaoJunXu.TBFACTIONEQUIP = 
{
	{--初级战场, 扬州战场
		[Env.FACTION_ID_SHAOLIN]	= 49, -- 少林
		[Env.FACTION_ID_TIANWANG]	= 50, --天王掌门
		[Env.FACTION_ID_TANGMEN]	= 51, --唐门掌门
		[Env.FACTION_ID_WUDU]		= 53, --五毒掌门
		[Env.FACTION_ID_EMEI]		= 55, --峨嵋掌门
		[Env.FACTION_ID_CUIYAN]		= 56, --翠烟掌门
		[Env.FACTION_ID_GAIBANG]	= 58, --丐帮掌门
		[Env.FACTION_ID_TIANREN]	= 57, --天忍掌门
		[Env.FACTION_ID_WUDANG]		= 59, --武当掌门
		[Env.FACTION_ID_KUNLUN]		 = 60, --昆仑掌门
		[Env.FACTION_ID_MINGJIAO]	 = 52, --明教掌门
		[Env.FACTION_ID_DALIDUANSHI] = 54, --大理段氏掌门
		[Env.FACTION_ID_GUMU]		= 292, -- 古墓
	},
	{--中级战场, 凤翔战场
		[Env.FACTION_ID_SHAOLIN]	= 61, -- 少林
		[Env.FACTION_ID_TIANWANG]	= 62, --天王掌门
		[Env.FACTION_ID_TANGMEN]	= 63, --唐门掌门
		[Env.FACTION_ID_WUDU]		= 65, --五毒掌门
		[Env.FACTION_ID_EMEI]		= 67, --峨嵋掌门
		[Env.FACTION_ID_CUIYAN]		= 68, --翠烟掌门
		[Env.FACTION_ID_GAIBANG]	= 70, --丐帮掌门
		[Env.FACTION_ID_TIANREN]	= 69, --天忍掌门
		[Env.FACTION_ID_WUDANG]		= 71, --武当掌门
		[Env.FACTION_ID_KUNLUN]		 = 72, --昆仑掌门
		[Env.FACTION_ID_MINGJIAO]	 = 64, --明教掌门
		[Env.FACTION_ID_DALIDUANSHI] = 66, --大理段氏掌门
		[Env.FACTION_ID_GUMU]		= 293, -- 古墓 
	},
};


-- NPC对话
function tbBaoJunXu:OnDialog(szCamp)
	if (Battle.LEVEL_LIMIT[1] > me.nLevel) then
		return;
	end
	local pPlayer		= me;
	self.nCampId		= Battle.tbNPCNAMETOID[szCamp];
	self.tbDialog		= Battle.tbCampDialog[self.nCampId];

	if (0 == self:CheckSameCamp()) then
		Dialog:Say(self.tbDialog[7]);
		return;
	end
	
	--self:ProcessBattleBouns();
	
	
	--根据地图获得军需官属于战场级别
	local nNowBattleLevel = 0;
	for nBattleLevel, tbMapSeq in ipairs(Battle.MAPID_LEVEL_CAMP) do
		for nBtSeq, tbMap in ipairs(tbMapSeq) do
			for nMapNum, nMapId in pairs(tbMap) do
				if nMapId == pPlayer.nMapId then
					nNowBattleLevel = nBattleLevel;
					break;
				end
			end
			if nNowBattleLevel ~= 0 then
				break;
			end
		end
		if nNowBattleLevel ~= 0 then
			break;
		end
	end
	
	
	
--	local nBouns		= pPlayer.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_TOTALBOUNS);
	local szExMsg		= "Tại đây ngươi có thể mua các đạo cụ chiến trường và các thiết bị đặc biệt."; -- , 用戰場積分換取經驗.你目前的戰場積分為: <color=green>%d<color>.";
	local szMsg			= self.tbDialog[6] .. szExMsg;
	local tbOpt			= {
	--	{"我要购买战场道具", self.OnBuyDaoJu, self},
		{"<color=gold>[Bạc khóa]<color> Ta muốn mua thuốc", self.OnBuyYaoByBind, self},
		{"Ta muốn mua thuốc", self.OnBuyYao, self},
		{"<color=gold>[Bạc khóa]<color> Ta muốn mua thức ăn", self.OnBuyCaiByBind, self},
		{"Ta muốn mua thức ăn", self.OnBuyCai, self},
	--	{"我要购买战场特殊装备(暂时不能用)", self.OnBuyZhuangBei, self},
	--	{"我要用战场积分换取经验", self.OnExchange, self},
		{"Nhận Quân Nhu", self.OnGetJunXuMed, self},
	--	{"我要查看功勋排行榜", self.OnSearchGongRank, self},
		--{"我要积分兑换奖励", self.OnBounsChangeAward, self},
	--	{"我要领取每周总积分奖励", self.OnGetWeekMaxBounsAward, self},
		{"Để ta suy nghĩ lại"},
	};
	
	if nNowBattleLevel == 1 then
		local tbOpenShop = {"Ta muốn mua trang bị tính năng Dương Châu", self.OnBuyBattleEquip, self, nNowBattleLevel};
		table.insert(tbOpt,3,tbOpenShop);
	elseif nNowBattleLevel == 2 then
		local tbOpenShop = {"Ta muốn mua trang bị tính năng Phượng Tường", self.OnBuyBattleEquip, self, nNowBattleLevel};
		table.insert(tbOpt,3,tbOpenShop);		
	end	
	
	Dialog:Say(szMsg, tbOpt);
end

function tbBaoJunXu:OnGetJunXuMed()
	local nJunXuDian	= me.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_JUNXU);
	if (0 >= nJunXuDian) then
		Dialog:Say("Ngươi đã nhận hết toàn bộ quân nhu hôm nay, hãy mau ra trận giết địch!");
		return;
	end
	
	local nBTLevel		= Battle:GetJoinLevel(me);
	local szMsg			= string.format("Hôm nay ngươi còn nhận %d Quân Nhu. Ngươi có chắc muốn nhận?", nJunXuDian);
	local tbOpt			= {
			{"Hồi Huyết Đơn", self.OnChooseMed, self, Battle.tbBattleItem_Medicine[nBTLevel][1], nJunXuDian },
			{"Hồi Nội Đơn", self.OnChooseMed, self, Battle.tbBattleItem_Medicine[nBTLevel][2], nJunXuDian },
			{"Càn Khôn Tạo Hóa Hoàn", self.OnChooseMed, self, Battle.tbBattleItem_Medicine[nBTLevel][3], nJunXuDian },
			{"Để ta suy nghĩ lại"},
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbBaoJunXu:OnSearchGongRank()
	local pPlayer = me;
	local tbPlayerInfo 	= Battle:GetPlayerRankInfo(pPlayer);
	local szMsg			= "";
	if (not tbPlayerInfo) then
		szMsg 	= "Hiện nay ngươi không có tên trong Bảng Xếp Hạng!";
	else
		szMsg	= string.format("%s, Công trạng: <color=yellow>%d<color>, Xếp hạng: <color=green>%d<color>", pPlayer.szName, tbPlayerInfo.nGongXun, tbPlayerInfo.nRank);	
	end
	Dialog:Say(szMsg);
end

function tbBaoJunXu:OnChooseMed(nItemNumber, nJunXuDian)
	local pPlayer = me;
	local nJunXuDian	= pPlayer.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_JUNXU);
	if (0 >= nJunXuDian) then
		return;
	end
	local pItem = pPlayer.AddItemEx(18, 1, nItemNumber, 1, {bTimeOut = 1});
	if not pItem then
		return;
	end
	pItem.SetGenInfo(1, pItem.GetExtParam(6));
	pPlayer.SetItemTimeout(pItem, os.date("%Y/%m/%d/%H/%M/%S", GetTime() + Battle.BTPLJUNXUTIMEOUT));
	pItem.Sync();
	nJunXuDian = nJunXuDian - 1;
	pPlayer.SetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_JUNXU, nJunXuDian);
end

-- 检查是否同一阵营
function tbBaoJunXu:CheckSameCamp()
	local pPlayer = me;
	local nMyCamp = pPlayer.GetTask(Battle.TSKGID, Battle.TASKID_BTCAMP);
	if ((0 == nMyCamp) or (nMyCamp == self.nCampId)) then
		return 1;
	end

	local tbMapInfo 	= Battle:GetMapInfo(him.nMapId);
	local nMyBattleKey	= pPlayer.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_KEY);
	if ((tbMapInfo.tbMission) and (tbMapInfo.tbMission.nBattleKey == nMyBattleKey)) then
		return 0;
	end
	return 1;
end

-- 获取战场信息
function tbBaoJunXu:GetBattleState()
	local tbMapInfo 	= Battle:GetMapInfo(him.nMapId);
	if (tbMapInfo.tbMission) then
		local nState = tbMapInfo.tbMission.nState;
		return nState;
	end
	return 0;
end

-- 买卖
function tbBaoJunXu:OnBuyZhuangBei()
--	me.OpenShop(23,4);
end

function tbBaoJunXu:OnBuyBattleEquip(nBattleLevel)
	local nFaction = me.nFaction;
	if nFaction <= 0 or me.GetCamp() == 0 then
		Dialog:Say("Người chưa gia nhập môn phái!!!");
		return 0;
	end	
	me.OpenShop(self.TBFACTIONEQUIP[nBattleLevel][nFaction], 1, 100, me.nSeries)
	
end

function tbBaoJunXu:OnBuyDaoJu()
--	me.OpenShop(14,1);
	me.OpenShop(23,4);
end

function tbBaoJunXu:OnBuyYaoByBind()
	me.OpenShop(14,7);
end

function tbBaoJunXu:OnBuyYao()
	me.OpenShop(14,1);
end

-- 买菜
function tbBaoJunXu:OnBuyCai()
	me.OpenShop(21,1);
end

function tbBaoJunXu:OnBuyCaiByBind()
	me.OpenShop(21,7);
end

-- 积分换经验
function tbBaoJunXu:OnExchange()
	local nBattleState	= self:GetBattleState();	
	if ( 2 == nBattleState ) then
		Dialog:Say("Cuộc chiến đang còn tiếp diễn, sau khi kết thúc mới được đổi!");
		return;
	end	
	
	local nMyRemainBouns	= me.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_TOTALBOUNS);
	if (0 >= nMyRemainBouns ) then
		Dialog:Say("Điểm hiện tại của ngươi: <color=green>0<color>!");
		return 0;
	end
	
	local szMsg		= "Ngươi cần đổi bao nhiêu điểm?";
	local tbOpt		= 	{
							{"500 Điểm", self.OnChangeBouns, self, 500},
							{"1000 Điểm", self.OnChangeBouns, self, 1000},
							{"2000 Điểm", self.OnChangeBouns, self, 2000},
							{"5000 Điểm", self.OnChangeBouns, self, 5000},
							{"10000 Điểm", self.OnChangeBouns, self, 10000},
							{"Tất cả điểm", self.OnChangeBouns, self, nMyRemainBouns},
							{"Ta suy nghĩ lại..."},
						};
	Dialog:Say(szMsg, tbOpt);
	-- 积分减少后还得更新数据
end

-- 积分换经验
function tbBaoJunXu:OnChangeBouns(nChangeBouns)
	if (0 == self:CheckBouns(nChangeBouns)) then
		return;
	end
	local nLevel	= me.nLevel;
	local nExp		= Battle:BounsChangeExp(nLevel, nChangeBouns) * Battle.BOUNS2EXPMUL;
	Battle:DbgWrite(Dbg.LOG_INFO, "tbBaoJunXu:OnChangeBouns", me.szName, nLevel, nChangeBouns, nExp);
	local szMsg		= string.format("Ngươi đã sử dụng <color=red>%d<color> điểm tích lũy đổi <color=green>%d<color> kinh nghiệm, ngươi chắc chứ?", nChangeBouns, nExp);
	local tbOpt		= 	{
							{"Ta chắc", self.OnChangeBounsSuc, self, nChangeBouns, nExp},
							{"Khoan, ta suy nghĩ lại..."},
						};
	Dialog:Say(szMsg, tbOpt);
end

-- 成功换取经验
function tbBaoJunXu:OnChangeBounsSuc(nChangeBouns, nExp)
	Battle:WeekBounsChangeExp(me, nChangeBouns);
--	if (0 == self:CheckBouns(nChangeBouns)) then
--		return;
--	end
--
--	local nMyRemainBouns	= pPlayer.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_TOTALBOUNS);
--	local nMyUserBouns		= Battle:GetMyUseBouns();
--	Battle:AddUseBouns(me, nChangeBouns, nMyUserBouns);
--	pPlayer.SetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_TOTALBOUNS, nMyRemainBouns - nChangeBouns);
--	pPlayer.AddExp2(nExp,"battle"); -- mod zounan 修改经验接口
end

function tbBaoJunXu:CheckBouns(nChangeBouns)
	local nMyRemainBouns	= me.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_TOTALBOUNS);
	local nMyUserBouns		= Battle:GetMyUseBouns();
	if (nMyRemainBouns < nChangeBouns) then
		Dialog:Say(string.format("Tích lũy ngươi chỉ có: <color=red>%d<color>, không thể đổi <color=yellow>%d<color> điểm tích lũy!", nMyRemainBouns, nChangeBouns));
		return 0;
	end

	if ((nMyUserBouns + nChangeBouns) > Battle.BATTLES_POINT2EXP_MAXEXP) then
		Dialog:Say(string.format("Trong tuần này, ngươi đã đổi: <color=red>%d<color>, đã đạt giới hạn, không được đổi thêm!", Battle.BATTLES_POINT2EXP_MAXEXP));
		return 0;
	end
	
	return 1;
end

function tbBaoJunXu:ProcessBattleBouns()
	local nBouns	= me.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_TOTALBOUNS);
	if (nBouns > 0) then
		local tbMapInfo 	= Battle:GetMapInfo(him.nMapId);
		local nMyBattleKey	= me.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_KEY);
		-- 这里有问题, 仔细看看
		if ((tbMapInfo.tbMission) and (tbMapInfo.tbMission.nBattleKey ~= nMyBattleKey)) then
			local nOrgBouns = me.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_BOUNS_TOTAL_WEEK);
			local nNowBouns = nBouns + nOrgBouns;
			me.SetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_BOUNS_TOTAL_WEEK, nNowBouns);
			local nLastReWeek = Lib:GetLocalWeek(pPlayer.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_BOUNS_TOTAL_RETIME));
			local nNowWeek = Lib:GetLocalWeek(GetTime());
			if (nNowWeek == nLastReWeek) then
				local nCurMax = KGblTask.SCGetDbTaskInt(Battle.DBTASK_SONGJIN_BOUNS_MAX);
				if (nCurMax < nNowBouns) then
					KGblTask.SCSetDbTaskStr(Battle.DBTASK_SONGJIN_BOUNS_MAX, me.szName);
					KGblTask.SCSetDbTaskInt(Battle.DBTASK_SONGJIN_BOUNS_MAX, nNowBouns);	
				end
			end
			me.SetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_TOTALBOUNS, 0);
			me.Msg(string.format("Trận vừa rồi vẫn còn điểm tích lũy chưa nhận, ta sẽ giúp ngươi thêm vào điểm tích lũy tuần. Sau đó, ngươi có thể đến <color=yellow>Quan Quân Nhu<color> để đổi thưởng!"));			
		end
	end
	
	local nFlag = Battle:RefreshBattleWeekBouns(me);
	if (1 == nFlag) then
		return 2;
	end
	return 0;
end

function tbBaoJunXu:OnBounsChangeAward()
	local tbOpt = {};
	local szMsg = "Tích lũy đổi phần thưởng: ";
	local szMaxName = KGblTask.SCGetDbTaskStr(Battle.DBTASK_SONGJIN_BOUNS_MAX) or "Vô";
	local nMaxBouns	= KGblTask.SCGetDbTaskInt(Battle.DBTASK_SONGJIN_BOUNS_MAX) or 0;
	local nNowWeekBouns = me.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_BOUNS_TOTAL_WEEK);
	local nUseWeekBouns	= me.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_BOUNS_TOTAL_USE_WEEK);
	local nDet = nNowWeekBouns - nUseWeekBouns;
	if (nDet < 0) then
		nDet = 0;
	end
	
	szMsg = string.format("Hiện tại bạn đã nhận được tích lũy tuần: <color=yellow>%s điểm<color>\nTích lũy có thể đổi: <color=yellow>%s điểm<color>\nHiện tại người có tích lũy tuần cao nhất: <color=yellow>%s<color>\nTích lũy tuần cao nhất: <color=yellow>%s điểm<color>\n\nBạn có muốn đổi không?", nNowWeekBouns, nDet, szMaxName, nMaxBouns);
	table.insert(tbOpt, {"<color=yellow>3000 điểm<color> đổi <color=green>1 Lệnh Bài Mông Cổ Tây Hạ<color> và <color=yellow>2 Túi Phúc<color>", self.OnChangeAward, self, 3000});
	table.insert(tbOpt, {"<color=yellow>1500 điểm<color> đổi <color=yellow>1 Túi Phúc<color>", self.OnChangeAward, self, 1500});
	if (nDet > 0) then
		table.insert(tbOpt, {"Đổi tích lũy còn lại thành kinh nghiệm", self.OnChangeBouns, self, nDet});
	end
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	
	Dialog:Say(szMsg, tbOpt);
end

function tbBaoJunXu:OnChangeAward(nChangeBouns, nFlag)
	local nNowWeekBouns = me.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_BOUNS_TOTAL_WEEK);
	local nUseWeekBouns	= me.GetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_BOUNS_TOTAL_USE_WEEK);
	local nDet = nNowWeekBouns - nUseWeekBouns;
	local nNeedBag = 0;
	if (nDet < nChangeBouns) then
		Dialog:Say(string.format("Hiện tại tích lũy có thể đổi của bạn là %s không thể đổi phần thưởng %s điểm!", nDet, nChangeBouns));
		return 0;
	end
	
	if (3000 == nChangeBouns) then
		nNeedBag = 3;
	elseif (1500 == nChangeBouns) then
		nNeedBag = 1;
	end
	
	if (me.CountFreeBagCell() < nNeedBag * Battle.nTimes) then
		Dialog:Say(string.format("Túi không đủ %d ô trống, hãy sắp xếp lại rồi đến nhận!", nNeedBag * Battle.nTimes));
		return 0;
	end
	
	if (not nFlag or 1 ~= nFlag) then
		Dialog:Say(string.format("Bạn có đồng ý đổi phần thưởng %s không?", nChangeBouns), {
				{"Đồng ý", self.OnChangeAward, self, nChangeBouns, 1},
				{"Để ta suy nghĩ lại"},
			});
		return 0;
	end
	
	nUseWeekBouns = nUseWeekBouns + nChangeBouns;
	me.SetTask(Battle.TSKGID, Battle.TSK_BTPLAYER_BOUNS_TOTAL_USE_WEEK, nUseWeekBouns);
	Battle:RefreshBattleWeekBouns(me);
	local nLevel = Battle:GetJoinLevel(me);
	local nItemId = Battle.tbPaiItemId[nLevel];
	for i=1, Battle.nTimes do
		if (3000 == nChangeBouns) then
			Battle:WriteLog("AwardGood", string.format("Give player %s a zhanchanglingpai", me.szName), nItemId);
			me.AddItem(18,1,112,nItemId);
			me.AddItem(18,1,80,1);
			me.AddItem(18,1,80,1);
		elseif (1500 == nChangeBouns) then
			me.AddItem(18,1,80,1);
		end
		Battle:WeekBounsChangeExp(me, nChangeBouns);
	end
end

function tbBaoJunXu:OnGetWeekMaxBounsAward(nFlag)
	local szMaxName = KGblTask.SCGetDbTaskStr(Battle.DBTASK_SONGJIN_BOUNS_MAX_AWARDPLAYER);
	local nGetTime	= KGblTask.SCGetDbTaskInt(Battle.DBTASK_SONGJIN_BOUNS_MAX_AWARDPLAYER);
	if (not szMaxName or szMaxName == "" or szMaxName ~= me.szName) then
		Dialog:Say("Bạn chưa nhận được phần thưởng xếp hạng tuần này, tiếp tục cố gắng.");
		return 0;
	end
	
	if (nGetTime > 0) then
		Dialog:Say("Bạn đã nhận phần thưởng, hãy tiếp tục cố gắng!");
		return 0;
	end
	
	if (not nFlag or 1 ~= nFlag) then
		Dialog:Say("Bạn xếp hạng 1 tổng tích lũy Mông Cổ Tây Hạ tuần này, đây là phần thưởng của bạn, bạn đồng ý nhận không?", {
				{"Xác nhận", self.OnGetWeekMaxBounsAward, self, 1},
				{"Để ta suy nghĩ lại"},
			});
		return 0;
	end
	
	KGblTask.SCSetDbTaskInt(Battle.DBTASK_SONGJIN_BOUNS_MAX_AWARDPLAYER, GetTime());
	me.AddTitle(2,3,1,0);
end

