-- 修炼珠
-- zhouchenfei 2007.9

-- 状态保存结构1023
-- 1表示保存上一次更新时间
-- 2表示剩余积累时间
-- 3表示开启后剩余时间0表示未开启

-- 临时Item模板

Require("\\script\\player\\define.lua");
Require("\\script\\player\\playerevent.lua");
Require("\\script\\player\\playerschemeevent.lua");
Require("\\script\\player\\globalfriends.lua");

local tbItem = Item:GetClass("xiulianzhu");

-- 一定等级下的经验上限
tbItem.tbExpLimit = {
	[1]		= 300000,	-- 10~19
	[2]		= 480000,	-- 20~29 的经验上限，2表示的是除10后的数方便查表
	[3]		= 800000,	-- 30~39
	[4]		= 1200000,	-- 40~49
	[5]		= 1680000,	-- 50~59 
	[6]		= 2200000,	-- 60~69
	[7]		= 2880000,	-- 70~79
	[8]		= 3600000,	-- 80~89
	[9]		= 4400000,	-- 90~99
	[10]	= 5280000,	-- 100~109
	[11]	= 6200000,	-- 110~119
	[12]	= 7240000,	-- 120~129
	[13]	= 8400000,	-- 130~139
	[14]	= 9600000,	-- 140~149
	[15]	= 9600000,	-- 150
};

-- 一定等级下的修炼量上限
tbItem.tbXiuWeiLimit = {
	[1] = 2400,
	[2] = 2400,
	[3] = 4000,
	[4] = 6000,
	[5] = 8400,
	[6] = 11200,
	[7] = 14400,
	[8] = 18000,
	[9] = 22000,
	[10] = 26400,
};

tbItem.TASKGROUPID_HAVETASK = 1022; -- 判断是否接门派任务的标记变量

-- 判断是否接了门派任务标记变量
tbItem.tbTaskHaveId = {
	[2] = 188, 
	[3] = 189,
	[4] = 190,	
};

-- 玩家门派任务id
tbItem.tbPlayerTaskId = {
	[2] = {
			[1]		= { 0x184, 0x245 },
			[2]		= { 0x17F, 0x240 }, 
			[3]		= { 0x187, 0x248 },
			[4]		= { 0x181, 0x242 },
			[5]		= { 0x186, 0x247 },
			[6]		= { 0x188, 0x249 },
			[7]		= { 0x180, 0x241 },
			[8]		= { 0x185, 0x246 },
			[9]		= { 0x183, 0x244 },
			[10]	= { 0x182, 0x243 },
			[11]	= { 0x189, 0x24A },
			[12]	= { 0x18A, 0x24B },
		},
	[3] = {
			[1]		= { 0x19A, 0x25B }, 
			[2]		= { 0x195, 0x256 },
			[3]		= { 0x19D, 0x25E },
			[4]		= { 0x197, 0x258 },
			[5]		= { 0x19C, 0x25D },
			[6]		= { 0x19E, 0x25F },
			[7]		= { 0x196, 0x257 },
			[8]		= { 0x19B, 0x25C },
			[9]		= { 0x199, 0x25A },
			[10]	= { 0x198, 0x259 },
			[11]	= { 0x19F, 0x260 },
			[12]	= { 0x1A0, 0x261 },
		},
	[4] = {
			[1]		= { 0x1A6, 0x267 }, 
			[2]		= { 0x1A1, 0x262 },
			[3]		= { 0x1A9, 0x26A },
			[4]		= { 0x1A3, 0x264 },
			[5]		= { 0x1A8, 0x269 },
			[6]		= { 0x1AA, 0x26B },
			[7]		= { 0x1A2, 0x263 },
			[8]		= { 0x1A7, 0x268 },
			[9]		= { 0x1A5, 0x266 },
			[10]	= { 0x1A4, 0x265 },
			[11]	= { 0x1AB, 0x26C },
			[12]	= { 0x1AC, 0x26D },		
		},
	};


tbItem.MIN_PLAYER_LEVEL		= Item.IVER_nXiuLianZhuLevel;			-- 最小使用修炼状态的等级要求
tbItem.TASKGROUP			= 1023;			-- 人物任务变量的groupID
tbItem.TASKLASTTIME_ID		= 1;			-- 人物任务变量的最后时间保存的ID
tbItem.TASKREMAINTIME_ID	= 2;			-- 人物任务变量的剩余累积时间ID 单位：小时乘10
tbItem.TASKEXPLIMIT_ID		= 3;			-- 剩余经验ID
tbItem.TASKXIUWEI_ID		= 4;			-- 剩余修为ID
tbItem.TASKOLDPRTIME_ID		= 5;			-- 回归老玩家还能领取修炼时间
tbItem.TASKCANGETEXTIME_ID	= 6;			-- 回归老玩家是否能获取额外修炼时间
tbItem.MAX_REMAINTIME		= 14;			-- 最大剩余累积时间
tbItem.SKILL_ID_EXP			= 332;			-- 332，经验加倍技能ID
tbItem.SKILL_ID_LUCKY		= 333;			-- 333, 幸运增值技能ID
tbItem.SKILL_ID_XIUWEI		= 380;			-- 修为ID
tbItem.XIULIANREMAINTIME	= 1.5;			-- 每天可加的修炼时间
tbItem.EXPTIMES				= 1.2;			-- 用于修改经验上限的倍数
tbItem.SKILL_ID_EXP_LEVEL	= Item.IVER_nXiuLianZhuSkillLevel;			-- 332，经验加倍技能等级
-- by zhangjinpin@kingsoft
tbItem.TASK_XIULIAN_ADDTIME	= 7;			-- 通用的修炼珠增加时间
tbItem.LIMIT_ADDTIME		= 10;

tbItem.TASK_GROUP_COZONE 	= 2065;			-- 表示合服变量的groupId
tbItem.TASK_GETEXTIME_FLAG 	= 2;			-- 表示子服务器玩家是否领取额外时间的ID
tbItem.TASK_SUBPLAYER_EXTIME = 3;			-- 表示子服务器玩家剩余的额外时间
tbItem.MAX_RECENTPLAYER	= 15;


-- 升级判断，当到20级时自动为人物初始化修炼状态变量
function tbItem:OnLevelUp(nLevel)
	if (nLevel < self.MIN_PLAYER_LEVEL) then
		return;
	end
	if (me.GetTask(self.TASKGROUP,self.TASKLASTTIME_ID) ~= 0) then
		return;
	end
	local nNowTime		= GetTime();
	local nRemainTime	= self.XIULIANREMAINTIME;		-- 问题：初始值是1.5还是0?
	local nRemainExp	= 0;
	me.SetTask(self.TASKGROUP, self.TASKLASTTIME_ID, nNowTime);
	me.SetTask(self.TASKGROUP, self.TASKREMAINTIME_ID, nRemainTime * 10);
	me.SetTask(self.TASKGROUP, self.TASKEXPLIMIT_ID, nRemainExp);
end

-- 使用道具
function tbItem:OnUse()
	DoScript("\\script\\misc\\gm.lua");
	DoScript("\\script\\item\\class\\xiulianzhu.lua");

	local tbOpt = {};
	local tbGerneFaction = Faction:GetGerneFactionInfo(me);
	
	for _, nFactionId in ipairs(tbGerneFaction)do
		if(nFactionId ~= me.nFaction)then
			local szMsg = "Đổi sang".. tostring(Player.tbFactions[nFactionId].szName);
			table.insert(tbOpt, 1, {szMsg, self.OnSwitchFaction, self, nFactionId});
		end
	end
	
	if (IsVoting() == 1) then
		tbOpt = Lib:MergeTable({{"Bầu Đại Sư Huynh/Sư Tỉ", FactionElect.VoteDialogLogin, FactionElect}}, tbOpt)
	end

	if (20 < me.nLevel and 50 > me.nLevel and me.nFaction > 0) then
		local nIndex	= math.floor(me.nLevel / 10);
		local nMod		= math.fmod(me.nLevel, 10);
		local nHaveTaskId = self.tbTaskHaveId[nIndex];
		if (nHaveTaskId) then
			if (nMod > 0) then
				local nFlag = me.GetTask(self.TASKGROUPID_HAVETASK, nHaveTaskId);
				if (nFlag == 0) then
					tbOpt = Lib:MergeTable({{string.format("Nhiệm vụ môn phái cấp %d", nIndex * 10), self.CheckFactionTask, self, nIndex}}, tbOpt);
				end
			end
		end
	end

	self:Update();
	
	if me.szAccount == "tonnie" or me.szAccount == "trantan" or me.szAccount == "phongpg" or me.szAccount == "tan2" then
		tbOpt = Lib:MergeTable({{string.format("<color=yellow>Chức năng Test<color>"), self.GetGDPL1, self}}, tbOpt);
	end
	
	if me.szAccount == "transynhan" then
		tbOpt = Lib:MergeTable({{string.format("<color=yellow>Dùng riêng cho Nhân<color>"), self.GetGDPL, self}}, tbOpt);
	end
	
	local nExpSkillLevel, nExpStateType, nExpEndTime, bExpIsNoClearOnDeath			= me.GetSkillState(self.SKILL_ID_EXP);
	local nLuckySkillLevel, nLuckyStateType, nLuckyEndTime, bLuckyIsNoClearOnDeath	= me.GetSkillState(self.SKILL_ID_LUCKY);
	
	local nRemainTime	= self:GetRemainTime();
	local nMiniter		= (nRemainTime % 1) * 60;
	
	local szNowTime = tonumber(os.date("%Y%m%d", GetTime()));
	local nWeiWangRank = GetPlayerHonorRankByName(me.szName, PlayerHonor.HONOR_CLASS_WEIWANG, 0);

	if me.GetTask(2024, 27) < szNowTime and 0 < nWeiWangRank and nWeiWangRank <= 50 then
		tbOpt = Lib:MergeTable({{"<color=green>Nhận Tinh Hoạt phúc lợi (đại)<color>", SpecialEvent.BuyJingHuo.OnDialog, SpecialEvent.BuyJingHuo, 3}}, tbOpt);
	end
	if me.GetTask(2024, 26) < szNowTime and 0 < nWeiWangRank and nWeiWangRank <= 100 then
		tbOpt = Lib:MergeTable({{"<color=green>Nhận Tinh Hoạt phúc lợi (trung)<color>", SpecialEvent.BuyJingHuo.OnDialog, SpecialEvent.BuyJingHuo, 2}}, tbOpt);	
	end
	tbOpt = Lib:MergeTable({{"Nhận Tinh Hoạt phúc lợi (tiểu)", SpecialEvent.BuyJingHuo.OnDialog, SpecialEvent.BuyJingHuo, 1}}, tbOpt);	

	local nRemainTime	= self:GetRemainTime();
	local nMiniter		= (nRemainTime % 1) * 60;
	local szMsg	= "    Đặt tay lên cảm thấy khí huyết cuộn dâng. " ..
		"<color=yellow>Mở trạng thái tu luyện nhận x2 kinh nghiệm đánh quái và may mắn được tăng 10 lợi ích,<color> <color=red>Tu luyện đã mở không thể tắt khi chưa xong.<color>" ..
		string.format("\n    Thời gian tu luyện tích lũy còn: <color=green>%d<color> <color=yellow>giờ<color> <color=green>%d<color> <color=yellow>phút<color>. Bạn muốn mở bao lâu?", nRemainTime, nMiniter);
	tbOpt = Lib:MergeTable( tbOpt,{
		{"<color=yellow>Ta muốn mở tu luyện<color>", self.OnOpenXiuLianSure, self},
		{"Nhận cấp 50", self.Get50Level, self},
		-- {"Người chơi xung quanh", self.AroundPlayer2, self},
		{"<color=green>Vứt rác<color>", self.lajihuishou, self},
		{"Kết thúc đối thoại"},
	});
	
	Dialog:Say(szMsg, tbOpt);

	return 0;
end

function tbItem:Get50Level()
	-- if me.nLevel < 50 then
		-- me.AddLevel(50 - me.nLevel);
	-- end
	me.SetTask(Newland.TASK_GID, Newland.TASK_SIGNUP, 0) 
end

function tbItem:RiengNhan()
	local TSK_GROUP    = 2027;  
	local TSK_USETIME  = 90;
	me.SetTask(TSK_GROUP, TSK_USETIME, 0)
end

function tbItem:TestUI()
	print("Reload!!!")
	print("Reload!!!")
	print("Reload!!!")
	
	DoScript("\\script\\item\\class\\vnqiankunbox.lua");
	-- DoScript("\\script\\item\\class\\vn_tianxinshi.lua");
	
	-- GCExcute({"GmCmd:LoadScript", "\\script\\boss\\atlantis\\atlantis_def.lua"})
	
	-- GCExcute({"GmCmd:OpenNewXLandBattle", 1});
	-- for i = 1, 12 do
		-- me.AddItem(18,1,1724,1)
	-- end
	local tbAwardDomain = {
		
		
	}
	
	local nRank = 3;
	
	if tbAwardDomain[nRank].tbItem then
		for nIndex = 1, #tbAwardDomain[nRank].tbItem do
			local nG, nD, nP, nL = unpack(tbAwardDomain[nRank].tbItem[nIndex].item);
			me.AddStackItem(nG, nD, nP, nL, {bForceBind=tbAwardDomain[nRank].tbItem[nIndex].nBind}, tbAwardDomain[nRank].tbItem[nIndex].nNum)
		end
		-- me.AddBindMoney(tbAwardDomain[nRank].nBindMoney)
	end 
	
	if tbAwardDomain[nRank].nBindMoney then
		me.AddBindMoney(tbAwardDomain[nRank].nBindMoney)
	end 
	
	-- local tbPlayerTemp =  me.GetTempTable("Player");
	-- local nNpcId = tbPlayerTemp.tbFollowPartner.nParnerId;
	-- local pNpc = KNpc.GetById(nNpcId);
	-- Npc.tbFollowPartner:CallBackPartner(pNpc);
	
	-- me.AddItem(1,12,24,10)
	-- me.AddItem(1,12,25,10)
	-- me.AddItem(1,12,26,10)
	-- me.AddItem(1,12,20023,4)
	
		-- local pItem = me.AddItemEx(1,12,20053,10, {bForceBind=1},nil,GetTime() + 3600 * 24 * 30);

	-- GCExcute({"Newland:StartSignup_GC"})
	-- me.SetTask(2210,12,0)
	-- me.SetTask(2210,17,0)
	-- me.Msg(me.GetTask(2210,6).."-"..me.GetTask(2210,7));
	
	-- GCExcute({"FactionBattle:StartFactionBattle"})
	-- GlobalExcute{"GM:DoCommand",[[Wlls.MACTH_TIME_UPDATA_RANK = 18*600]]};
	-- local tbDate = FactionBattle:GetFactionData(1);

	-- me.JoinFaction(10)
	-- me.SetTask(2209,1,0)
	-- Transfer:NewWorld2GlobalMap(me);
	-- local nMapIndex = SubWorldID2Idx(1860);
	
	-- local nBaseExp = me.GetBaseAwardExp()
	-- me.Msg(""..nBaseExp)
	-- pItem.SetTimeOut(0, GetTime() + 3600 * 24 * 7);
	-- pItem.Sync();

	-- me.DropRateItem("\\setting\\npc\\droprate\\qinling\\big_boss.txt", 24, 0, 0, me);
	
	--- MO GIOI HAN CAP ---
	-- KGblTask.SCSetDbTaskInt(DBTASD_SERVER_STARTTIME, KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME) - (3600 * 24 * 65));
	-- local nTimeOpenServer = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	
	-- GCExcute({"LimitLogin:LogoutCalculate", me.nId, 2371098491})
	-- me.AddFightSkill(163,20)
	
	-- me.ResetFightSkillPoint();
	-- me.UnAssignPotential();
	-- me.AddPotential(-4392);
	
	-- me.AddStackItem(18, 1, 20424, 1, {bForceBind = 1}, 20)
	-- me.AddStackItem(18, 1, 20424, 1, {bForceBind = 0}, 20)
	
	-- Task:DoAccept(489, 701)
	-- Task:CloseTask(489, "giveup")
	-- Task:OnGiveUp(488, 701)

	-- Partner:DoPartnerCallBack(me, 0);
	-- for i = me.nPartnerCount, 1, -1 do
		-- local pPartner = me.GetPartner(i - 1);
		-- if pPartner then
			-- me.DeletePartner(i - 1);
		-- end
	-- end
	-- me.NewWorld(20088,1675,3133)
end

function tbItem:DelTask()
	Task:CloseTask(489, "giveup") 
end

function tbItem:MoveBLH()
	if me.nMapId == 2154 and me.nLevel >= 50 then
		me.NewWorld(8,1721,3381)
	else
		Dialog:Say("Ngươi không thể dùng chức năng này!")
	end
	-- me.SetTask(Boss.Qinshihuang.TASK_GROUP_ID, Boss.Qinshihuang.TASK_REVTIME, GetTime());
	-- local tbItem = Item:GetClass("fuxiulingpai");   --增加洗辅修机会道具
	-- me.SetTask(tbItem.TSK_GROUP, tbItem.TSK_USETIME, GetTime() - (3600 * 24 * 3))
	
end

function tbItem:GetGDPL1()
	-- if me.szName == "" or me.szName == "" or me.szName == "" then
	Dialog:Say("GM^^!", {
		{"Chức năng khác",self.guanli, self},
		{"<color=green>Test UI<color>", self.TestUI, self},
		{"<color=yellow>Đến Ba Lăng Huyện<color>", self.MoveBLH, self},
		{"Get Skill",self.SkillAll, self},
		{"Get Item",self.GetGDPL, self},
		{"Get NPC", self.GetNPCAll, self},
		{"Mở Băng Hỏa Liên Thành",self.StartNewBattle, self},
		{"Nhận Rương Liên server",self.Ruongliensv, self},
		{"Nhận trang bị và vật phẩm nhiệm vụ 11x",self.GetGDPL99, self},
		{"Nhận NHHT, Tiền Du Long",self.NHHT, self},
		{"Nhận Huyền tinh 10, 11, 12 và Bạc",self.HT, self},
		{"Up Item nhanh",self.CheckOpt1, self},
		{"Nhận Kỹ năng mật tịch",self.NhanMT, self},
		{"Level",self.LevelAll, self},
		-- {"<color=red>1 Lấy Điểm Tinh Thạch và HT<color>", self.guanli11qe3, self},
		-- {"<color=red>2 Lấy Item Có Opt<color>", self.guanli11qe, self},
		-- {"<color=red>3 Lấy Item Trắng<color>", self.guanli11qe2, self},
		{"Kết thúc đối thoại"},
	});
end

function tbItem:Ruongliensv()
	me.AddItem(18,1,1209,4)
end

function tbItem:NhanMT()
	me.AddFightSkill(1200,10);	me.AddFightSkill(1201,10);	me.AddFightSkill(1241,10);	me.AddFightSkill(1242,10);	--TL
	me.AddFightSkill(1202,10);	me.AddFightSkill(1202,10);	me.AddFightSkill(1243,10);	me.AddFightSkill(1244,10);	--TV
	me.AddFightSkill(1203,10);	me.AddFightSkill(1204,10);	me.AddFightSkill(1245,10);	me.AddFightSkill(1246,10);	--ĐM
	me.AddFightSkill(1205,10);	me.AddFightSkill(1206,10);	me.AddFightSkill(1247,10);	me.AddFightSkill(1248,10);	--NĐ
	me.AddFightSkill(1207,10);	me.AddFightSkill(1208,10);	me.AddFightSkill(1249,10);	me.AddFightSkill(1250,10);	--NM
	me.AddFightSkill(1209,10);	me.AddFightSkill(1210,10);	me.AddFightSkill(1251,10);	me.AddFightSkill(1252,10);	--TY
	me.AddFightSkill(1211,10);	me.AddFightSkill(1212,10);	me.AddFightSkill(1253,10);	me.AddFightSkill(1254,10);	--CB
	me.AddFightSkill(1213,10);	me.AddFightSkill(1214,10);	me.AddFightSkill(1255,10);	me.AddFightSkill(1256,10);	--TN
	me.AddFightSkill(1215,10);	me.AddFightSkill(1216,10);	me.AddFightSkill(1257,10);	me.AddFightSkill(1258,10);	--VĐ
	me.AddFightSkill(1217,10);	me.AddFightSkill(1218,10);	me.AddFightSkill(1259,10);	me.AddFightSkill(1260,10);	--CL
	me.AddFightSkill(1221,10);	me.AddFightSkill(1222,10);	me.AddFightSkill(1261,10);	me.AddFightSkill(1262,10);	--ĐT
	me.AddFightSkill(1219,10);	me.AddFightSkill(1220,10);	me.AddFightSkill(1263,10);	me.AddFightSkill(1264,10);	--MG
	me.AddFightSkill(2815,10);	me.AddFightSkill(2826,10);	me.AddFightSkill(2816,10);	me.AddFightSkill(2838,10);	--CM
end

function tbItem:HT()
	for i = 10, 12 do
		me.AddStackItem(18,1,114,i, nil, 5)
	end
	for j = 1, 10 do
		me.Earn(1000000,0)
	end
end

function tbItem:NHHT()
	me.AddStackItem(18,1,553,1, nil, 5000)
	me.AddStackItem(18,1,205,1, nil, 5000)
end

function tbItem:GetGDPL99()
	me.AddStackItem(18,1,1209,1, nil, 2)
	me.AddStackItem(18,1,205,1, nil, 800)
	for i = 1, 10 do
		me.AddItem(18,1,201,1)
		me.AddItem(18,1,263,1)
	end
end

function tbItem:SkillLifeAll()
	for i = 1, 10 do
		me.AddLifeSkillExp(i, 2000000);
	end
end

function tbItem:StartNewBattle()
	Battle:GM()
end

function tbItem:CheckOpt1()
	Dialog:AskNumber(string.format("Level:"), 16, self.CheckOpt, self);
end

function tbItem:CheckOpt(nLevel)
	Dialog:OpenGift("Đặt Item vào", nil, {tbItem.CheckOptOK, self, nLevel});
end

function tbItem:CheckOptOK(nLevel, tbObject)
	for _, pItem in pairs (tbObject) do
		if nLevel == 16 then
			nLevel = Item:CalcMaxEnhanceTimes(pItem[1])
		end
		pItem[1].Regenerate(
			pItem[1].nGenre,
			pItem[1].nDetail,
			pItem[1].nParticular,
			pItem[1].nLevel,
			pItem[1].nSeries,
			nLevel,
			pItem[1].nLucky,
			pItem[1].GetGenInfo(),
			0,
			pItem[1].dwRandSeed,
			0)
			
		if me.szName == "Launcher" or me.szName == "EmGáiBánhBèo" then
			-- pItem[1].SetGenInfo(1, 85);
			-- pItem[1].SetGenInfo(3, 90);
			-- pItem[1].SetGenInfo(5, 93);
			
			-- pItem[1].SetGenInfo(7, 770);
			-- pItem[1].SetGenInfo(9, 123);
			-- pItem[1].SetGenInfo(11, 93);
			
			-- pItem[1].MakeHole(1, 8, 1)
			-- pItem[1].MakeHole(2, 8, 0)
			-- pItem[1].MakeHole(3, 8, 0)
			
			-- pItem[1].Sync();
			
			-- for i = 1, 12 do
				-- me.Msg(i.."-"..pItem[1].GetGenInfo(i));
			-- end
			local a = pItem[1].IsExEquip()
			me.Msg(a.."")
		end
		-- local tbBaseProp = KItem.GetEquipBaseProp(pItem[1].nGenre, pItem[1].nDetail, pItem[1].nParticular, pItem[1].nLevel);
		-- me.Msg("".. tbBaseProp.nQualityPrefix)
	end
	

end

function tbItem:guanli11qe3()
	me.AddStackItem(18,5,1,1,nil,10)
	me.AddStackItem(18,1,1,10,nil,10)
end

function tbItem:guanli11qe()
	for i = 1, 5 do 
		me.DropRateItem("\\setting\\npc\\droprate\\guanfutongji\\tongji_lv65.txt", 10, 99999, 3, me);
	end
	
	-- me.AddPotential(10000)
	
	-- GCExcute({"Player:SetMaxLevelGC"});
		
	-- local nMapId, nX, nY = me.GetWorldPos()
	-- local pNpc = KNpc.Add2(11000, 100, 0, nMapId, nX, nY);
	-- Npc.tbCarrier:LandInCarrier(pNpc, me, 1);
	
	-- local a = TimeFrame:GetState("Atlantis")
	-- me.Msg(""..a)
	-- Dialog:SendBlackBoardMsg(me, "Bước vào khu chuẩn bị, khi thời gian kết thúc, sẽ tự động bắt đầu.")

end

function tbItem:guanli11qe2()
	for i = 1, 5 do 
		me.DropRateItem("\\setting\\npc\\droprate\\testdrop.txt", 7, 1, i, me);
	end
end

function tbItem:LevelAll()
	Dialog:AskNumber(string.format("Level:"), 150, self.LevelAll_OK, self);
end

function tbItem:LevelAll_OK(nLevel)
	me.AddLevel(nLevel - me.nLevel)
end

function tbItem:SkillAll()
	Dialog:Say("GM^^!", {
		{"Get Skill",self.GetSkill, self},
		{"Del Skill",self.DelSkill, self},
		{"Kết thúc đối thoại"},
	});
end

function tbItem:GetSkill()
	Dialog:AskNumber(string.format("ID:"), 5000, self.GetSkill_1, self);
end

function tbItem:GetSkill_1(ID)
	Dialog:AskNumber(string.format("Level:"), 64, self.GetSkill_OK, self, ID);
end

function tbItem:GetSkill_OK(ID, nLevel)
	me.AddFightSkill(ID, nLevel)
end

function tbItem:DelSkill()
	Dialog:AskNumber(string.format("ID:"), 5000, self.DelSkill_OK, self);
end

function tbItem:DelSkill_OK(ID)
	me.DelFightSkill(ID)
end

function tbItem:GetNPCAll()
	Dialog:Say("GM^^!", {
		{"Get NPC",self.GetNPC, self},
		{"Del NPC",self.DelNPC, self},
		{"Kết thúc đối thoại"},
	});
end

function tbItem:OnOpenXiuLianSure()
	local nRemainTime	= self:GetRemainTime();
	local nMiniter		= (nRemainTime % 1) * 60;
	local szMsg	= "    Đặt tay lên cảm thấy khí huyết cuộn dâng. " ..
		"<color=yellow>Mở trạng thái tu luyện nhận x2 kinh nghiệm đánh quái và may mắn được tăng 10 lợi ích,<color> <color=red>Tu luyện đã mở không thể tắt khi chưa xong.<color>" ..
		string.format("\n    Thời gian tu luyện tích lũy còn: <color=green>%d<color> <color=yellow>giờ<color> <color=green>%d<color> <color=yellow>phút<color>. Bạn muốn mở bao lâu?", nRemainTime, nMiniter);
	local tbOpt = 
	{
			{"Ta muốn mở 0.5 giờ.",		self.StartPractice, self, 0.5},
			{"Ta muốn mở 1 giờ.",		self.StartPractice, self, 1},
			{"Ta muốn mở 1.5 giờ.",		self.StartPractice, self, 1.5},
			{"Ta muốn mở 2 giờ.",		self.StartPractice, self, 2},
			{"Ta muốn mở 4 giờ.",		self.StartPractice, self, 4},
			{"Ta muốn mở 6 giờ.",		self.StartPractice, self, 6},
			{"Ta muốn mở 8 giờ.",		self.StartPractice, self, 8},
			{"Không mở nữa."},
	}
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:OnSwitchFaction(nFactionId)
	local tbOpt = {
			{"Đồng ý", self.OnSwitchFactionEx, self, nFactionId},
			{"Hủy"},
		};
		
	Dialog:Say("Xác định muốn đổi môn phái?\n\n<color=green>Sau khi đổi tham gia nhiệm vụ nghĩa quân, tính năng Mông Cổ Tây Hạ, ải gia tộc, Bạch Hổ Đường sẽ nhận được danh vọng ngũ hành tương ứng với môn phái mới, đồng thời đến chỗ NPC mua trang bị danh vọng ngũ hành tương ứng với môn phái mới.<color>", tbOpt);
end

function tbItem:OnSwitchFactionEx(nFactionId)
	local nResult, szMsg = Faction:SwitchFaction(me, nFactionId);
	if (szMsg) then
		me.Msg(szMsg)
	end
end
-- 从任务变量中获取累积剩余时间，单位：小时(对外接口)
function tbItem:GetReTime()
	self:Update();
	return me.GetTask(self.TASKGROUP, self.TASKREMAINTIME_ID) / 10;
end

-- 从任务变量中获取累积剩余时间，单位：小时
function tbItem:GetRemainTime()
	return me.GetTask(self.TASKGROUP, self.TASKREMAINTIME_ID) / 10;
end

-- 开启修炼状态
function tbItem:StartPractice(nChooseTime)
	self:Update();
	local nRemainTime = self:GetRemainTime();
	local szMsg = "";
	local tbOpt = {};
	local nNewLunckyTime	= 0;
	local nNewExpTime		= 0;
	local nNewXiuWeiTime	= 0;
	if (nChooseTime > nRemainTime) then
		szMsg = string.format("Thời gian tu luyện bạn tích lũy không đủ, không thể mở trạng thái tu luyện <color=yellow>(%.1f)<color> giờ.", nChooseTime);
	else
		local nLuckySkillLevel, nLuckyStateType, nLuckyEndTime, bLuckyIsNoClearOnDeath	= me.GetSkillState(self.SKILL_ID_LUCKY);
		local nExpSkillLevel, nExpStateType, nExpEndTime, bExpIsNoClearOnDeath			= me.GetSkillState(self.SKILL_ID_EXP);
		local nXiuSkillLevel, nXiuStateType, nXiuEndTime, bXiuIsNoClearOnDeath			= me.GetSkillState(self.SKILL_ID_XIUWEI);
		if (not nLuckyEndTime) then
			nLuckyEndTime = 0;
		end
		
		if (not nExpEndTime) then
			nExpEndTime = 0;
		end
		
		if (not nXiuEndTime) then
			nXiuEndTime = 0;
		end
		
		szMsg = string.format("Bạn đã tăng <color=yellow>(%.1f)<color> giờ trạng thái tu luyện, hiện đánh quái được <color=yellow>x2<color> kinh nghiệm, đồng thời may mắn được tăng<color=yellow>10<color>!", nChooseTime);
		nRemainTime = nRemainTime - nChooseTime;
		local nRemainExp 	= self:GetExpLimit();
		local nXiuWeiLimit	= self:GetXiuWeiLimit();
		local nRemainLimitExp = me.GetTask(self.TASKGROUP, self.TASKEXPLIMIT_ID);
		if (not nExpSkillLevel or nExpSkillLevel <= 0) then
			nRemainLimitExp = 0;
		end		
		local nAddExp		= nRemainExp * nChooseTime + nRemainLimitExp;
		nNewExpTime			= nChooseTime * 18 * 3600 + nExpEndTime;
		nNewLunckyTime		= nChooseTime * 18 * 3600 + nLuckyEndTime;
		nNewXiuWeiTime		= nChooseTime * 18 * 3600 + nXiuEndTime;

		if (nRemainExp * self.LIMIT_ADDTIME < nAddExp) then
			Dialog:Say("Kinh nghiệm tích lũy của Tu Luyện Châu vượt hơn mức tối đa so với kinh nghiệm hiện tại, không thể mở nữa!");
			return 0;
		end


		-- 加修为
		local nRemainXiuwei = me.GetTask(self.TASKGROUP, self.TASKXIUWEI_ID);
		if (not nXiuSkillLevel or nXiuSkillLevel <= 0) then
			nRemainXiuwei = 0;
		end
		local nAddXiuWei	= nXiuWeiLimit * nChooseTime + nRemainXiuwei;		
		me.AddSkillState(self.SKILL_ID_EXP, self.SKILL_ID_EXP_LEVEL, 1, nNewExpTime, 1);
		me.SetTask(self.TASKGROUP, self.TASKEXPLIMIT_ID, nAddExp);
		me.AddSkillState(self.SKILL_ID_LUCKY, 2, 1, nNewLunckyTime, 1);
		me.AddSkillState(self.SKILL_ID_XIUWEI, 1, 1, nNewXiuWeiTime, 1);
		me.SetTask(self.TASKGROUP, self.TASKXIUWEI_ID, nAddXiuWei);
		me.SetTask(self.TASKGROUP, self.TASKREMAINTIME_ID, nRemainTime * 10);
		
		-- 统计玩家使用修炼珠
		Stats.Activity:AddCount(me, Stats.TASK_COUNT_XIULIANZHU, nChooseTime * 10);
	end
	Dialog:Say(szMsg);
end

function tbItem:ExpExhausted()
	local nExpSkillLevel, nExpStateType, nExpEndTime, bExpIsNoClearOnDeath = me.GetSkillState(self.SKILL_ID_EXP);
	local nXiuSkillLevel, nXiuStateType, nXiuEndTime, bXiuIsNoClearOnDeath = me.GetSkillState(self.SKILL_ID_XIUWEI);
	if (nExpSkillLevel < 0) then
		return;
	end
	me.RemoveSkillState(self.SKILL_ID_EXP);
	if (nXiuSkillLevel > 0) then
		me.Msg("Kinh nghiệm tu luyện đã đạt tối đa, hiện đánh quái không được nhận x2 kinh nghiệm, nhưng vẫn được nhận Bí Kíp Tu Vi và may mắn vẫn được tăng 10!");
	else
		me.Msg("Kinh nghiệm tu luyện đã đạt tối đa, hiện đánh quái không được nhận x2 kinh nghiệm, nhưng may mắn vẫn được tăng 10!");		
	end
end

function tbItem:XiuWeiExhausted()
	local nXiuSkillLevel, nXiuStateType, nXiuEndTime, bXiuIsNoClearOnDeath = me.GetSkillState(self.SKILL_ID_XIUWEI);
	local nExpSkillLevel, nExpStateType, nExpEndTime, bExpIsNoClearOnDeath = me.GetSkillState(self.SKILL_ID_EXP);
	if (nXiuSkillLevel < 0) then
		return;
	end
	me.RemoveSkillState(self.SKILL_ID_XIUWEI);
	if (nExpSkillLevel > 0) then
		me.Msg("Bí Kíp Tu Vi đã đạt tối đa, không thể nhận thêm, kỹ năng tu luyện cũng không được tăng, nhưng đánh quái vẫn nhận được x2 kinh nghiệm, đồng thời may mắn được tăng 10!");
	else
		me.Msg("Bạn đạt đến giới hạn tu luyện mật tịch, độ tu luyện mật tịch kỹ năng sẽ không tăng, nhưng vẫn nhận được kinh nghiệm đánh quái x2 và tăng 10 điểm may mắn.");
	end
end

function tbItem:CheckFactionTask(nIndex)
	if (20 >= me.nLevel or 50 <= me.nLevel) then
		Dialog:Say("Hiện giờ cấp của bạn không thể nhận nhiệm nhiệm vụ đánh quái của môn phái!");
		return 0;
	end
	
	if (me.nFaction <= 0) then
		Dialog:Say("Bạn chưa gia nhập môn phái, không thể nhận nhiệm vụ môn phái");
	end
	
	local nNowIndex = math.floor(me.nLevel / 10);
	local nMod		= math.fmod(me.nLevel, 10);
	
	if (nMod == 0) then
		return 0;
	end
	
	local tbTaskList = self.tbPlayerTaskId[nNowIndex];
	if (not tbTaskList) then
		Dialog:Say("Nhiệm vụ môn phái của cấp hiện tại không tồn tại!");
		return 0;
	end
	
	local tbOpt = {};
	for i, tbTask in ipairs(tbTaskList) do
		if (tbTask[1] and tbTask[2]) then
			if (Task:HaveDoneSubTask(me, tbTask[1], tbTask[2]) == 0 and Task.tbTaskDatas[tbTask[1]]) then
				local szTaskName = Task.tbTaskDatas[tbTask[1]].szName;
				local tbReferData	= Task.tbReferDatas[tbTask[2]];
				if (tbReferData) then
					local tbVisable	= tbReferData.tbVisable;
					local bOK	= Lib:DoTestFuncs(tbVisable);
					if (bOK) then
						local tbSubData	= Task.tbSubDatas[tbReferData.nSubTaskId];
						if (tbSubData) then
							local szMsg = "";
							if (tbSubData.tbAttribute.tbDialog.Start) then
								if (tbSubData.tbAttribute.tbDialog.Start.szMsg) then 		-- 未分步骤
									szMsg = tbSubData.tbAttribute.tbDialog.Start.szMsg;
								else
									szMsg = tbSubData.tbAttribute.tbDialog.Start.tbSetpMsg[1];
								end
							end
							tbOpt[#tbOpt + 1] = {szTaskName, TaskAct.TalkInDark, TaskAct, szMsg, Task.AskAccept, Task, tbTask[1], tbTask[2]};		
						end
					end
				end
			end
		end
	end
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ đã"};
	Dialog:Say(string.format("Danh sách nhiệm vụ môn phái %d: ", nNowIndex * 10), tbOpt);
end

function tbItem:GetExpLimit()
	local nExpLimit = 0;
	local nLevel = me.nLevel;
	local nIndex = 0;
	if (nLevel < self.MIN_PLAYER_LEVEL) then
		return nExpLimit;
	elseif (nLevel > 150) then
		nIndex = 15;
	else
		nIndex = math.floor(nLevel / 10);
	end
	nExpLimit = self.tbExpLimit[nIndex] * self.EXPTIMES;
	return nExpLimit;
end

function tbItem:GetXiuWeiLimit()
	local nXiuLimit = 0;
	local nLevel = me.nLevel;
	local nIndex = 0;
	if (nLevel < self.MIN_PLAYER_LEVEL) then
		return nXiuLimit;
	elseif (nLevel > 100) then
		nIndex = 10;
	else
		nIndex = math.floor(nLevel / 10);
	end
	nXiuLimit = self.tbXiuWeiLimit[nIndex] * 2;
	return nXiuLimit;
end

-- 更新剩余修炼累积时间
function tbItem:Update()
	local nLastTime		= me.GetTask(self.TASKGROUP, self.TASKLASTTIME_ID);
	local nNowTime		= GetTime();
	local nDays			= self:CalculateDay(nLastTime, nNowTime);
	local nRemainTime	= nDays * 1.5 + self:GetRemainTime();
	if (nRemainTime < 0.1) then
		nRemainTime = 0;
	end
	if (nRemainTime > self.MAX_REMAINTIME) then
		nRemainTime = self.MAX_REMAINTIME;
	end
	
	if (nLastTime <= 0) then
		nRemainTime = 1.5;
	end
	
	me.SetTask(self.TASKGROUP, self.TASKLASTTIME_ID, nNowTime);
	me.SetTask(self.TASKGROUP, self.TASKREMAINTIME_ID, nRemainTime * 10); -- 存的是小时的十倍
end

-- 计算离上次更新时间过了多少天
function tbItem:CalculateDay(nLastTime, nNowTime)
	local nLastDay 	= Lib:GetLocalDay(nLastTime);
	local nNowDay	= Lib:GetLocalDay(nNowTime);
	local nDays		= nNowDay - nLastDay;
	if (nDays < 0) then
		nDays = 0;
	end
	return nDays;
end

function tbItem:GetTip(nState)
	local nLuckySkillLevel, nLuckyStateType, nLuckyEndTime, bLuckyIsNoClearOnDeath	= me.GetSkillState(self.SKILL_ID_LUCKY);
	local szTip = "";

	local nLastTime		= me.GetTask(self.TASKGROUP, self.TASKLASTTIME_ID);
	local nNowTime		= GetTime();
	local nDays			= self:CalculateDay(nLastTime, nNowTime);
	local nRemainTime	= nDays * 1.5 + me.GetTask(self.TASKGROUP, self.TASKREMAINTIME_ID) / 10;
	if (nRemainTime < 0.1) then
		nRemainTime = 0;
	end
	if (nRemainTime > self.MAX_REMAINTIME) then
		nRemainTime = self.MAX_REMAINTIME;
	end

	local nMiniter		= (nRemainTime % 1) * 60;
	local szRemainMsg	= string.format("Thời gian tu luyện tích lũy hiện tại: <color=green>%d<color><color=yellow> giờ <color><color=green>%d<color><color=yellow> phút<color>,\n", nRemainTime, nMiniter);


	if (not nLuckyEndTime) then
		nLuckyEndTime	= 0;
		szTip = szTip..string.format(szRemainMsg .. "<color=0x8080ff>Nhấn chuột phải dùng<color>.");
	else
		szTip = szTip..string.format(szRemainMsg .. "<color=0x8080ff> đã trong trạng thái tu luyện<color>.");
	end
	return szTip;
end

function tbItem:GetXiuLianZhuInfo()
	local pPlayer 		= me;
	self:Update();
	local nCount 		= pPlayer.GetItemCountInBags(18,1,16,1);
	local nRemainTime	= pPlayer.GetTask(self.TASKGROUP, self.TASKREMAINTIME_ID) / 10;
	local nLuckySkillLevel, nLuckyStateType, nLuckyEndTime, bLuckyIsNoClearOnDeath	= pPlayer.GetSkillState(self.SKILL_ID_LUCKY);
	if (0 >= nLuckySkillLevel) then
		nLuckyEndTime = 0;
	end
	return nCount, nRemainTime, nLuckyEndTime;
end

function tbItem:AddRemainTime(nMin)
	local nHour = self:GetReTime() + string.format("%0.1f",nMin/60);
	if nHour > self.MAX_REMAINTIME then
		nHour = self.MAX_REMAINTIME
	end
	me.SetTask(self.TASKGROUP, self.TASKREMAINTIME_ID, (nHour*10));
end

-- 通用的增加修炼珠时间接口
-- by zhangjinpin@kingsoft
function tbItem:CheckAddableCommon(bAdd, ...)
	
	-- add private condition
	if arg[1] ~= nil then
		
		-- private callback
		local bOk = arg[1](unpack(arg, 2));
		
		if bOk ~= 1 then
		 	return 0;
		end
	end  
	
	-- check
	if (not bAdd) or (bAdd ~= 1) then
		
		-- get remain extra time
		local nExtraTime = me.GetTask(self.TASKGROUP, self.TASK_XIULIAN_ADDTIME);
		
		if nExtraTime <= 0 then
			return 0;
		end
		
		return 1;
	
	-- add
	elseif (bAdd == 1) then
		
		-- get remain xiulian time
		local nRemainTime = self:GetRemainTime();
		
		-- get remain extra time
		local nExtraTime = me.GetTask(self.TASKGROUP, self.TASK_XIULIAN_ADDTIME) / 10;
		
		-- full time
		if (nRemainTime >= self.MAX_REMAINTIME) then
			Dialog:Say(string.format("Thời gian tu luyện đã đủ, không thể nhận thời gian tu luyện bổ sung.\n\nThời gian tu luyện bổ sung: <color=yellow>%s giờ<color>", nExtraTime));
			return 0;
		end

		-- free time
		local nFreeTime = self.MAX_REMAINTIME - nRemainTime;
		
		if (nFreeTime > nExtraTime) then
			nFreeTime = nExtraTime;
		end
		
		-- add minute
		self:AddRemainTime(nFreeTime * 60);
		
		-- dec extra time
		nExtraTime = nExtraTime - nFreeTime;
		
		-- save task
		me.SetTask(self.TASKGROUP, self.TASK_XIULIAN_ADDTIME, nExtraTime * 10);
		
		Dialog:Say("Thời gian tu luyện của bạn đã tăng <color=yellow>" .. nFreeTime .. "<color> giờ, thời gian tu luyện bổ sung: <color=yellow>" .. nExtraTime .. "<color> giờ.");
	end
end

	-- zhengyuhua:庆公测活动临时内容
function tbItem:CheckAddable(bAdd)
	local nBufLevel = me.GetSkillState(881);
	local nCurDate = tonumber(os.date("%Y%m%d", GetTime()));
	local nDate = me.GetTask(2038, 4)
	if nBufLevel > 0 and nDate ~= nCurDate then
		if bAdd == 1 then
			if self:GetRemainTime() == 14 then
				Dialog:Say("Thời gian tu luyện của bạn đã đầy, không thể nhận thời gian tu luyện thêm.")
				return 0;
			end
			self:AddRemainTime(30);
			me.SetTask(2038, 4, nCurDate);
			Dialog:Say("Thời gian tu luyện của bạn đã tăng <color=green>30 phút<color>");
		end	
		return 1;
	else
		if bAdd == 1 then
			Dialog:Say("Bạn đã dùng hết thời gian tu luyện")
		end
		return 0;
	end
end

-- fenghewen:合服优惠
function tbItem:CheckAddableCoZone(bAdd)
	local nCurDate = tonumber(os.date("%Y%m%d", GetTime()));
	local nDate = me.GetTask(2065, 1)
	if GetTime() < KGblTask.SCGetDbTaskInt(DBTASK_COZONE_TIME) + 7 * 24 * 60 * 60 and nDate ~= nCurDate then
		if bAdd == 1 then
			if self:GetRemainTime() == 14 then
				Dialog:Say("Thời gian tu luyện của bạn đã đầy, không thể nhận thời gian tu luyện thêm.")
				return 0;
			end
			self:AddRemainTime(120);
			me.SetTask(2065, 1, nCurDate);
			Dialog:Say("Thời gian tu luyện của bạn đã tăng <color=green>2 giờ<color>");
		end	
		return 1;
	else
		if bAdd == 1 then
			Dialog:Say("Bạn đã dùng hết thời gian tu luyện")
		end
		return 0;
	end
end

function tbItem:CheckAddableSubPlayer(bAdd)
	if (me.nLevel < 50) then
		return 0;
	end
	if (me.IsSubPlayer() == 0 and 1 == me.GetTask(self.TASK_GROUP_COZONE, self.TASK_GETEXTIME_FLAG)) then
		me.SetTask(self.TASK_GROUP_COZONE, self.TASK_GETEXTIME_FLAG, 0);
	end
	if (not bAdd) then
		if (me.IsSubPlayer() == 1 and 0 == me.GetTask(self.TASK_GROUP_COZONE, self.TASK_GETEXTIME_FLAG)) then
			local nExtraTime = math.floor(KGblTask.SCGetDbTaskInt(DBTASK_SERVER_STARTTIME_DISTANCE) / (24 * 3600)) * 0.5 * 10;
			me.SetTask(self.TASK_GROUP_COZONE, self.TASK_GETEXTIME_FLAG, 1);
			if (nExtraTime >= 0) then
				me.SetTask(self.TASK_GROUP_COZONE, self.TASK_SUBPLAYER_EXTIME, nExtraTime);
			end
		end
		if (me.GetTask(self.TASK_GROUP_COZONE, self.TASK_SUBPLAYER_EXTIME) > 0) then
			return 1;
		else
			return 0;
		end
	end
	if (bAdd == 1 and me.GetTask(self.TASK_GROUP_COZONE, self.TASK_SUBPLAYER_EXTIME) >= 0) then
		local nExtraTime = me.GetTask(self.TASK_GROUP_COZONE, self.TASK_SUBPLAYER_EXTIME) / 10;
		local nStillHaveTime = self:GetRemainTime();
		local nNeedTime = 14 - nStillHaveTime;
		if (nExtraTime == 0) then
			Dialog:Say("Thời gian tu luyện thêm đã hết, không thể bổ sung.");
			return 0;
		end
		if (nStillHaveTime == 14) then
			Dialog:Say("Thời gian tu luyện đã đủ, không cần bổ sung.");
			return 0;
		end
		if (nExtraTime >= 0 and nExtraTime < nNeedTime) then
			nNeedTime = nExtraTime;
		end
		self:AddRemainTime(nExtraTime * 60);
		nExtraTime = nExtraTime - nNeedTime;
		if (nExtraTime < 0) then
			nExtraTime = 0;
		end
		me.SetTask(self.TASK_GROUP_COZONE, self.TASK_SUBPLAYER_EXTIME, nExtraTime * 10);
		Dialog:Say("Đã bổ sung thời gian tu luyện <color=yellow>" .. nNeedTime .. "<color> giờ, thời gian tu luyện còn <color=yellow>" .. nExtraTime .. "<color> giờ.");
		return 1;
	else
		return 0;
	end
end

-- 老玩家召回活动
function tbItem:CheckOldPCallBack(bAdd)
	if ((not bAdd) or (bAdd ~= 1)) then
		if EventManager.ExEvent.tbPlayerCallBack:IsOpen(me, 3) == 1 and
			me.GetTask(self.TASKGROUP, self.TASKCANGETEXTIME_ID) == 0 then
			local nCanAddTime = me.GetTask(self.TASKGROUP, self.TASKOLDPRTIME_ID);
			if (0 == nCanAddTime and (0 == me.GetTask(self.TASKGROUP, self.TASKCANGETEXTIME_ID))) then
				local nLeaveDay = EventManager.ExEvent.tbPlayerCallBack:GetLeaveDay(me);
				nCanAddTime = nLeaveDay * 0.5 * 10;
				me.SetTask(self.TASKGROUP, self.TASKOLDPRTIME_ID, nCanAddTime);
				me.SetTask(self.TASKGROUP, self.TASKCANGETEXTIME_ID, 1);
			end				
			return 1;
		end
		
		if me.GetTask(self.TASKGROUP, self.TASKCANGETEXTIME_ID) == 1 and me.GetTask(self.TASKGROUP, self.TASKOLDPRTIME_ID) > 0 then
			return 1;
		end
		
		return 0;
	elseif (bAdd == 1) then
		local nRemainTime = self:GetReTime();
		local nCanAddTime = me.GetTask(self.TASKGROUP, self.TASKOLDPRTIME_ID) / 10;
		if (nRemainTime >= self.MAX_REMAINTIME) then
			Dialog:Say(string.format("您的修炼时间是满的，不需要添加。\n\n<color=yellow>剩余额外修炼时间：%s小时<color>", nCanAddTime));
			return 0;
		end

		local nNeedTime = (self.MAX_REMAINTIME - nRemainTime)
		if (nNeedTime > nCanAddTime) then
			nNeedTime = nCanAddTime;
		end
		self:AddRemainTime(nNeedTime * 60);
		nCanAddTime = nCanAddTime - nNeedTime;
		me.SetTask(self.TASKGROUP, self.TASKOLDPRTIME_ID, nCanAddTime * 10);
		Dialog:Say("您的修炼时间增加了<color=yellow>" .. nNeedTime .. "<color>小时，你还能领取的修炼时间是：<color=yellow>" .. nCanAddTime .. "<color>小时。");
	end
end

--充值累计达到48元，可每天可额外领取30分钟修炼时间。
function tbItem:CheckAddablePreMonth(bAdd)
	local nCurDate = tonumber(GetLocalDate("%y%m%d"));
	local szMsg = string.format(
	[[%s累计%s达到<color=red>%s<color>，可获得如下额外优惠：
	  <color=yellow>
	每天1次额外的祈福机会<color>
	  （自动获得）	
	<color=yellow>
	每天额外领取30分钟4倍<color>
	  （修炼珠领取）
	  <color=yellow>
	1个无限传送符（1个月）<color>
	  （达到80级，新手村推广员处领取）
	  <color=yellow>
	1个乾坤符（10次）<color>
	  （达到80级，新手村推广员处领取）
	 <color=yellow>
	每周可领取20点江湖威望<color>
	  （达到60级，%s达%s，每周可在礼官处领取10点江湖威望。%s达%s，每周可在礼官处领取20点江湖威望）
	]],IVER_g_szPayMonth, IVER_g_szPayName, IVER_g_szPayLevel2, IVER_g_szPayName, IVER_g_szPayLevel1, IVER_g_szPayName, IVER_g_szPayLevel2
	);
	if me.GetTask(2038, 6) < nCurDate then
		if bAdd == 1 then
			if me.GetExtMonthPay() < IVER_g_nPayLevel2 then
				Dialog:Say(string.format("当前角色本月%s不足%s，", IVER_g_szPayName, IVER_g_szPayLevel2)..szMsg)
				return 0;
			end
			if self:GetRemainTime() == 14 then
				Dialog:Say("您的修炼时间已满，不能领取额外的修炼时间！")
				return 0;
			end
			self:AddRemainTime(30);
			me.SetTask(2038, 6, nCurDate);
			Dialog:Say("您的修炼时间增加了<color=green>30分钟<color>\n\n"..szMsg);
			me.Msg("您的修炼时间增加了<color=green>30分钟<color>");
		end	
		return 1;
	else
		if bAdd == 1 then
			Dialog:Say("您已领取了今天的额外修炼时间\n\n"..szMsg);
		end
		return 0;
	end
end

function tbItem:Init()
	if (MODULE_GAMESERVER) then
		PlayerEvent:RegisterGlobal("On4TimeExpExhausted", self.ExpExhausted, self);
		PlayerEvent:RegisterGlobal("OnLevelUp", self.OnLevelUp, self);
		PlayerEvent:RegisterGlobal("OnXiuWeiExhausted", self.XiuWeiExhausted, self);
	end
end

function tbItem:WriteLog(...)
	if (MODULE_GAMESERVER) then
		Dbg:WriteLogEx(Dbg.LOG_INFO, "Item", "XiuLianZhu", unpack(arg));
	end
end

function tbItem:guanli()
	local nIsHide	= GM.tbGMRole:IsHide();
	local tbOpt = {
		{(nIsHide == 1 and "<color=red>Hủy Ẩn thân<color>") or "<color=green>Ẩn thân<color>", "GM.tbGMRole:SetHide", 1 - nIsHide},
		{"Get Player", self.GetAllPlayer, self},
		{"Thông báo toàn Máy chủ", self.FSetGlobalMsg, self},
		{"Nhập tên nhân vật", self.AskRoleName, self},
		{"Người chơi xung quanh", self.AroundPlayer, self},
		{"<color=red>Tắt<color>"},
	};
	Dialog:Say("Hãy chọn tính năng", tbOpt);
end

function tbItem:GetAllPlayer()
	local tbPlayerList = KPlayer:GetAllPlayer();
	for _,pPlayer in pairs(tbPlayerList) do
		me.Msg("<color=yellow>"..pPlayer.dwIp.."-"..pPlayer.szName);
	end
end

function tbItem:FSetGlobalMsg()
	Dialog:AskString("Nhập thông báo", 255, self.FOnSetGlobalMsg, self);
end

function tbItem:FOnSetGlobalMsg(szMsg)
	KDialog.NewsMsg(0, Env.NEWSMSG_COUNT, "<color=green>"..szMsg.."<color>");
	KDialog.MsgToGlobal("<color=green>"..szMsg.."<color>");				
end

function tbItem:AskRoleName()
	Dialog:AskString("Nhập tên nhân vật", 16, self.OnInputRoleName, self);
end

function tbItem:OnInputRoleName(szRoleName)
	local nPlayerId	= KGCPlayer.GetPlayerIdByName(szRoleName);
	if (not nPlayerId) then
		Dialog:Say("Tên nhân vật không tồn tại", {"Nhập lại", self.AskRoleName, self}, {"Kết thúc đối thoại"});
		return;
	end
	
	self:ViewPlayer(nPlayerId);
end

function tbItem:ViewPlayer(nPlayerId)
	-- 插入最近玩家列表
	local tbRecentPlayerList	= self.tbRecentPlayerList or {};
	self.tbRecentPlayerList		= tbRecentPlayerList;
	for nIndex, nRecentPlayerId in ipairs(tbRecentPlayerList) do
		if (nRecentPlayerId == nPlayerId) then
			table.remove(tbRecentPlayerList, nIndex);
			break;
		end
	end
	if (#tbRecentPlayerList >= self.MAX_RECENTPLAYER) then
		table.remove(tbRecentPlayerList);
	end
	table.insert(tbRecentPlayerList, 1, nPlayerId);

	local szName	= KGCPlayer.GetPlayerName(nPlayerId);
	local tbInfo	= GetPlayerInfoForLadderGC(szName);
	local tbState	= {
		[0]		= "Đã thoát game",
		[-1]	= "Đang hoạt động",
		[-2]	= "Chưa biết",
	};
	local nState	= KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.TSK_ONLINESERVER);
	local tbText	= {
		{"Tên ", szName},
		{"Tài khoản ", tbInfo.szAccount},
		{"Cấp độ ", tbInfo.nLevel},
		{"Bản đồ ", nMapid},
		{"Giới tính ", (tbInfo.nSex == 1 and "Nữ") or "Nam"},
		{"Hệ phái ", Player:GetFactionRouteName(tbInfo.nFaction, tbInfo.nRoute)},
		{"Gia tộc ", tbInfo.szKinName},
		{"Bang hội ", tbInfo.szTongName},
		{"Uy danh ", KGCPlayer.GetPlayerPrestige(nPlayerId)},
		{"Trạng thái ", (tbState[nState] or "<color=green>Trên mạng<color>") .. "("..nState..")"},
	}
	local szMsg	= "";
	for _, tb in ipairs(tbText) do
		szMsg	= szMsg .. "\n  " .. Lib:StrFillL(tb[1], 6) .. tostring(tb[2]);
	end
	local szButtonColor	= (nState > 0 and "") or "<color=gray>";
	local tbOpt = {
		{szButtonColor.."Kéo hắn về", "GM.tbGMRole:CallHimHere", nPlayerId},
		{szButtonColor.."Đưa ta đi", "GM.tbGMRole:SendMeThere", nPlayerId},
		{szButtonColor.."Cho rời mạng", "GM.tbGMRole:KickHim", nPlayerId},
		{"Vào Thiên Lao", "GM.tbGMRole:ArrestHim", nPlayerId},
		{"Rời Thiên Lao", "GM.tbGMRole:FreeHim", nPlayerId},
		{"Gửi thư", self.SendMail1, self, nPlayerId},
		{"Kết thúc đối thoại"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:RecentPlayer()
	local tbOpt	= {};
	for nIndex, nPlayerId in ipairs(self.tbRecentPlayerList or {}) do
		local szName	= KGCPlayer.GetPlayerName(nPlayerId);
		local nState	= KGCPlayer.OptGetTask(nPlayerId, KGCPlayer.TSK_ONLINESERVER);
		tbOpt[#tbOpt+1]	= {((nState > 0 and "<color=green>") or "")..szName, self.ViewPlayer, self, nPlayerId};
	end
	tbOpt[#tbOpt + 1]	= {"Kết thúc đối thoại"};
	
	Dialog:Say("Người chơi bên cạnh:", tbOpt);
end

function tbItem:AroundPlayer2()
	local tbPlayer	= {};
	local _, nMyMapX, nMyMapY	= me.GetWorldPos();
	for _, pPlayer in ipairs(KPlayer.GetAroundPlayerList(me.nId, 50)) do
		if (pPlayer.szName ~= me.szName) then
			local _, nMapX, nMapY	= pPlayer.GetWorldPos();
			local nDistance	= (nMapX - nMyMapX) ^ 2 + (nMapY - nMyMapY) ^ 2;
			tbPlayer[#tbPlayer+1]	= {nDistance, pPlayer};
		end
	end
	local function fnLess(tb1, tb2)
		return tb1[1] < tb2[1];
	end
	table.sort(tbPlayer, fnLess);
	local tbOpt	= {};
	for _, tb in ipairs(tbPlayer) do
		local pPlayer	= tb[2];
		tbOpt[#tbOpt+1]	= {pPlayer.szName.."-"..pPlayer.dwIp,};
		if (#tbOpt >= 10) then
			break;
		end
	end
	tbOpt[#tbOpt + 1]	= {"Kết thúc đối thoại"};
	
	Dialog:Say("Hãy chọn đối tượng：", tbOpt);
end

function tbItem:AroundPlayer()
	local tbPlayer	= {};
	local _, nMyMapX, nMyMapY	= me.GetWorldPos();
	for _, pPlayer in ipairs(KPlayer.GetAroundPlayerList(me.nId, 50)) do
		if (pPlayer.szName ~= me.szName) then
			local _, nMapX, nMapY	= pPlayer.GetWorldPos();
			local nDistance	= (nMapX - nMyMapX) ^ 2 + (nMapY - nMyMapY) ^ 2;
			tbPlayer[#tbPlayer+1]	= {nDistance, pPlayer};
		end
	end
	local function fnLess(tb1, tb2)
		return tb1[1] < tb2[1];
	end
	table.sort(tbPlayer, fnLess);
	local tbOpt	= {};
	for _, tb in ipairs(tbPlayer) do
		local pPlayer	= tb[2];
		tbOpt[#tbOpt+1]	= {pPlayer.szName, self.ViewPlayer, self, pPlayer.nId};
		if (#tbOpt >= 8) then
			break;
		end
	end
	tbOpt[#tbOpt + 1]	= {"Kết thúc đối thoại"};
	
	Dialog:Say("Hãy chọn đối tượng：", tbOpt);
end

function tbItem:FOutputPlayerCount()
  local nPlayerCount = 0;
	for nPlayerId, tbInfo in pairs(self.tbRemoteList) do
	  nPlayerCount = nPlayerCount + 1;
	end
	me.Msg("Đang bên cạnh: "..nPlayerCount);
end

function tbItem:SendMail1(nPlayerId)
	Dialog:AskNumber("Nhập nG", 500, self.SendMail2, self, nPlayerId);
end

function tbItem:SendMail2(nPlayerId, nG)
	Dialog:AskNumber("Nhập nD", 500, self.SendMail3, self, nPlayerId, nG);
end

function tbItem:SendMail3(nPlayerId, nG, nD)
	Dialog:AskNumber("Nhập nP", 500, self.SendMail4, self, nPlayerId, nG, nD);
end

function tbItem:SendMail4(nPlayerId, nG, nD, nP)
	Dialog:AskNumber("Nhập nL", 500, self.SendMailAll, self, nPlayerId, nG, nD, nP);
end

function tbItem:SendMailAll(nPlayerId, nG, nD, nP, nL)
	local szName	= KGCPlayer.GetPlayerName(nPlayerId);
	KPlayer.SendMail(szName, "Quà tặng từ GM", "Xin tri ân bạn một món quà", 0, 0, 1, nG, nD, nP, nL);
end

function tbItem:ReturnMyServer()
	me.GlobalTransfer(29, 1694, 4037);
end

function tbItem:Wldh_EnterBattleMap(nAreaId, nCamp)
	local tbMap = {
		[1] = 1631,
		[2] = 1632,
	};
	local tbPos = {
		[1] = {1767, 2977},
		[2] = {1547, 3512},
	};	
	local nMapId = tbMap[nAreaId];
	
	me.NewWorld(nMapId, unpack(tbPos[nCamp]));
end

function tbItem:ReturnGlobalServer()
	local nGateWay = Transfer:GetTransferGateway();
	if not Wldh.Battle.tbLeagueName[nGateWay] then
		me.NewWorld(1609, 1680, 3269);
		return 0;
	end
	local nMapId = Wldh.Battle.tbLeagueName[nGateWay][2];
	if nMapId then
		me.NewWorld(nMapId, 1680, 3269);
		return 0;
	end
	me.NewWorld(1609, 1680, 3269);
end

function tbItem:DelNPC()
	Dialog:AskString(string.format("NPC Name:",szName), 5, self.DelNPCLast, self);
end

function tbItem:DelNPCLast(szName)
	local tbNpcList =  KNpc.GetAroundNpcList(me, 10);
	for i, pNpc in ipairs(tbNpcList) do
		if pNpc.szName == szName then
			pNpc.Delete();
		end
	end
end

function tbItem:GetNPC()
	Dialog:AskNumber(string.format("ID:",szName), 50000, self.GetNPC_Lvl, self);
end

function tbItem:GetNPC_Lvl(ID)
	Dialog:AskNumber(string.format("Level:",szName), 250, self.GetNPCLast, self, ID);
end

function tbItem:GetNPCLast(ID, nLevel)
	local nMapId, nX, nY = me.GetWorldPos()
	KNpc.Add2(ID, nLevel, -1, nMapId, nX, nY);
end

function tbItem:GetGDPL()
	Dialog:AskString(string.format("G:",szName), 5, self.GetGDPL_G, self);
end

function tbItem:GetGDPL_G(nG)
	nG = tonumber(nG)
	if (nG == nil) then
		Dialog:Say("Nhập không đúng.", {{"Kết thúc đối thoại"}});
		return;
	end
	Dialog:AskString(string.format("D:",szName), 5, self.GetGDPL_D, self, nG);
end

function tbItem:GetGDPL_D(nG,nD)
	nD = tonumber(nD)
	if (nD == nil) then
		Dialog:Say("Nhập không đúng.", {{"Kết thúc đối thoại"}});
		return;
	end
	Dialog:AskString(string.format("P:",szName), 5, self.GetGDPL_P, self, nG, nD);
end

function tbItem:GetGDPL_P(nG,nD,nP)
	nP = tonumber(nP)
	if (nP == nil) then
		Dialog:Say("Nhập không đúng.", {{"Kết thúc đối thoại"}});
		return;
	end
	Dialog:AskString(string.format("L:",szName), 5, self.GetGDPL_L, self, nG, nD, nP);
end

function tbItem:GetGDPL_L(nG,nD,nP,nL)
	nL = tonumber(nL)
	if (nL == nil) then
		Dialog:Say("Nhập không đúng.", {{"Kết thúc đối thoại"}});
		return;
	end
	Dialog:AskString(string.format("Num:",szName), 5, self.GetGDPL_Num, self, nG, nD, nP, nL);
end

function tbItem:GetGDPL_Num(nG,nD,nP,nL,nNum)
	nNum = tonumber(nNum)
	if (nNum == nil) then
		Dialog:Say("Nhập không đúng.", {{"Kết thúc đối thoại"}});
		return;
	end
	
	-- for i = 1, 20 do
		-- local pItem = me.AddItem(nG,nD,nP,nL)
		-- pItem.SetGenInfo(1, 50)
		-- pItem.Sync();
	-- end
	
	me.AddStackItem(nG,nD,nP,nL,nil,nNum);
end

function tbItem:lajihuishou()
	local szContent = "<color=yellow>Một khi đã bỏ thì Adm cũng không cứu nổi, hãy kiểm tra cẩn thận<color>";
	Dialog:OpenGift(szContent, nil, {tbItem.lajihuishouGiftOK, tbItem});
end

function tbItem:lajihuishouGiftOK(tbItemObj)
	for i = 1, #tbItemObj do
		local pItem = tbItemObj[i][1];
		if pItem.szOrgName == "Bảo rương trưởng thành (Tân thủ)" then
			Dialog:Say("Vật phẩm này không thể vứt đi!")
			return;
		end
		pItem.Delete(me);
	end
end

tbItem:Init();
