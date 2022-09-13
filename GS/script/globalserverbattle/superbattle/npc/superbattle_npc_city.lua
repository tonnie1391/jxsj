-------------------------------------------------------
-- 文件名　 : superbattle_npc_city.lua
-- 创建者　 : zhangjinpin@kingsoft
-- 创建时间 : 2011-06-02 15:13:41
-- 文件描述 :
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\superbattle\\superbattle_def.lua");

local tbNpc = Npc:GetClass("superbattle_npc_city");
--排名积分
tbNpc.tbLadderHonor = {
	[1] = 400,
	[4] = 320,
	[10] = 280,
	[20] = 240,
	};
tbNpc.tbGradeHonor = {
	[5000] = 280,
	[4000] = 240,
	[3000] = 200,
	[2500] = 160,
	[2000] = 130,
	[1500] = 100,
	[1000] = 80,
	[500] = 60,
	}
function tbNpc:OnDialog()
	
	-- 活动是否开启
	if SuperBattle:CheckIsOpen() ~= 1 then
		Dialog:Say("Chiến trường chưa mở, không thể tham gia.");
		return 0;
	end
	
	-- 区服是否开启跨服功能
	local nTransferId = Transfer:GetMyTransferId(me);
	if not Transfer.tbGlobalMapId[nTransferId] then
		Dialog:Say("Chiến trường chưa mở, không thể tham gia.");
		return 0;
	end
	
	local nTotalBox = GetPlayerSportTask(me.nId, SuperBattle.GA_TASK_GID, SuperBattle.GA_TASK_BOX) or 0;
	local nBox = math.floor(nTotalBox / 100) - me.GetTask(SuperBattle.TASK_GID, SuperBattle.TASK_BOX);
	
	local szMsg = string.format("    Hai mươi năm rồi, ta vẫn không thể quên được trận chiến năm xưa. Khói lửa khuynh thành, đao kiếm ngang dọc. Ngươi muốn theo ta đến chiến trường năm xưa.\n<color=yellow>(Khi trận chiến kết thúc, hãy quay lại đây nhận phần thưởng của mình)<color>\n\n    Dựa vào chiến tích, cuối tuần ngươi sẽ nhận được <color=yellow>%s<color> phần thưởng.", nBox);
	local tbOpt = 
	{
		{"<color=yellow>Báo danh chiến trường<color>", self.AttendSuperBattle, self},
		{"Nhận thưởng tuần", self.GetAward, self},
		{"Nhận thưởng mỗi trận", self.GetExp, self},
		-- {"了解跨服战场", self.Help, self},
		{"Ta hiểu rồi"},
	};
	
	if me.GetTask(SuperBattle.TASK_GID, SuperBattle.TASK_MANTLE) == 1 then
		table.insert(tbOpt, 2, {"<color=yellow>Cửa hàng<color>", self.MantleShop, self});
	end
	
	Dialog:Say(szMsg, tbOpt);
end

-- 本服报名
function tbNpc:AttendSuperBattle()
	SuperBattle:SelectState_GS(me);
end

-- 领取奖励
function tbNpc:GetAward(nSure)
	
	local nWeek = me.GetTask(SuperBattle.TASK_GID, SuperBattle.TASK_WEEK);
	if nWeek >= SuperBattle:GetWeek() or SuperBattle:GetWeek() == 1 then
		Dialog:Say("Hãy đợi cuối tuần đến nhận thưởng.");
		return 0;
	end
	
	local nTotalBox = GetPlayerSportTask(me.nId, SuperBattle.GA_TASK_GID, SuperBattle.GA_TASK_BOX) or 0;
	local nBox = math.floor(nTotalBox / 100) - me.GetTask(SuperBattle.TASK_GID, SuperBattle.TASK_BOX);
	
	if nBox <= 0 then
		Dialog:Say("Ngươi không có phần thưởng để nhận.");
		return 0;
	end
	
	if not nSure then
		local szMsg = string.format("    Có tổng cộng <color=yellow>%s<color> khoáng thạch, ngươi muốn nhận ngay lúc này sao?\n", nBox);
		if GetPlayerSportTask(me.nId, SuperBattle.GA_TASK_GID, SuperBattle.GA_TASK_MANTLE) == 1 then
			szMsg = string.format("%s<color=yellow>(Đạt thành tích tốt trên chiến trường liên server, nhận được tư cách sử dụng Phi phong Trục Nhật)<color>", szMsg);
		end
		local tbOpt =
		{
			{"Xác nhận", self.GetAward, self, 1},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	
	-- 叠加物品背包空间
	local nNeed = KItem.GetNeedFreeBag(SuperBattle.AWARDBOX_ID[1], SuperBattle.AWARDBOX_ID[2], SuperBattle.AWARDBOX_ID[3], SuperBattle.AWARDBOX_ID[4], {bForceBind = 1}, nBox);
	if me.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("Hành trang không đủ %s chỗ trống.", nNeed));
		return 0;
	end
	
	-- 箱子
	me.AddStackItem(SuperBattle.AWARDBOX_ID[1], SuperBattle.AWARDBOX_ID[2], SuperBattle.AWARDBOX_ID[3], SuperBattle.AWARDBOX_ID[4], {bForceBind = 1}, nBox);
	me.SetTask(SuperBattle.TASK_GID, SuperBattle.TASK_BOX, me.GetTask(SuperBattle.TASK_GID, SuperBattle.TASK_BOX) + nBox);
	
	me.SetTask(SuperBattle.TASK_GID, SuperBattle.TASK_WEEK, SuperBattle:GetWeek());
	SuperBattle:StatLog("get_award", me.nId, nWeek, nBox);
	
	if GetPlayerSportTask(me.nId, SuperBattle.GA_TASK_GID, SuperBattle.GA_TASK_MANTLE) == 1 then
		me.AddTitle(unpack(SuperBattle.TITLE_ID));
		me.AddSkillState(SuperBattle.BUFFER_ID, 1, 1, SuperBattle.BUFFER_TIME, 1, 0, 1);
		me.SetTask(SuperBattle.TASK_GID, SuperBattle.TASK_MANTLE, 1);
		me.Msg("Nhận được tư cách sử dụng Phi phong Trục Nhật!");
		GCExcute({"SuperBattle:GetMantleBuffer_GC", me.szName});
		local szMsg = "trên Chiến trường liên server đạt thành tích cao, nhận được khoáng thạch và tư cách sử dụng Phi phong Trục Nhật!";
		me.SendMsgToFriend(string.format("Hảo hữu [%s] %s", me.szName, szMsg));
		Player:SendMsgToKinOrTong(me, szMsg);
	end
end

function tbNpc:MantleShop()
	me.OpenShop(199, 3);
end

function tbNpc:GetExp(nSure)
	
	local nTotalExp = GetPlayerSportTask(me.nId, SuperBattle.GA_TASK_GID, SuperBattle.GA_TASK_EXP) or 0;
	local nExp = nTotalExp - me.GetTask(SuperBattle.TASK_GID, SuperBattle.TASK_EXP);
	if nExp <= 0 then
		Dialog:Say("Ngươi không có gì để nhận thưởng!");
		return 0;
	end
	
	local nBindMoney = SuperBattle:CalcPlayerBindMoney(nExp);
	local nRepute = GetPlayerSportTask(me.nId, SuperBattle.GA_TASK_GID, SuperBattle.GA_TASK_REPUTE) or 0
	
	local nSort = GetPlayerSportTask(me.nId, SuperBattle.GA_TASK_GID, SuperBattle.GA_TASK_SORT) or 0;
	local nPoint = GetPlayerSportTask(me.nId, SuperBattle.GA_TASK_GID, SuperBattle.GA_TASK_POINT) or 0;
	local nOffer = SuperBattle:CalcPlayerOffer(nSort, nPoint);
	local nPad = math.min(math.floor(nPoint / 1000), 5);
	
	if not nSure then
		local szMsg = string.format([[Phần thưởng gồm:
			
    <color=yellow>%s<color> kinh nghiệm
    <color=yellow>%s<color> bạc khóa
    <color=yellow>%s điểm<color> Uy danh
    <color=yellow>%s<color> Lệnh bài thương hội
    
ngươi đồng ý không?
<color=yellow>(Uy danh tối đa nhận được là 60 điểm)<color>]], me.GetBaseAwardExp() * nExp, nBindMoney, nRepute, nPad, nOffer);
		local tbOpt =
		{
			{"Xác nhận", self.GetExp, self, 1},
			{"Để ta suy nghĩ thêm"},
		};
		Dialog:Say(szMsg, tbOpt);
		return 0;
	end
	local nFreeCount, tbFunExecute = SpecialEvent.ExtendAward:DoCheck("SuperBattle", me, nPoint) 	
	
	-- 绑银
	if nBindMoney + me.GetBindMoney() > me.GetMaxCarryMoney()  then
		Dialog:Say("Lượng bạc mang theo vượt quá số lượng cho phép!");
		return 0;
	end
	
	-- 牌子
	if nPad + nFreeCount > 0 then
		if me.CountFreeBagCell() < nPad +nFreeCount then
			Dialog:Say(string.format("Hành trang không đủ %s ô trống", nPad));
			return 0;
		end
		for i = 1, nPad do
			me.AddItem(SuperBattle.PAD_ID[1], SuperBattle.PAD_ID[2], SuperBattle.PAD_ID[3], SuperBattle.PAD_ID[4]);
		end
	end
	
	SpecialEvent.ExtendAward:DoExecute(tbFunExecute);
	
	SpecialEvent.ActiveGift:AddCounts(me, 31);		--领取宋金奖励完成一场宋金活跃度
	SpecialEvent.BuyOver:AddCounts(me, SpecialEvent.BuyOver.TASK_TONGKIM);
	
	if TimeFrame:GetState("Keyimen") == 1 then
		Item:ActiveDragonBall(me);
	end
	
	-- 经验和威望
	me.AddExp(me.GetBaseAwardExp() * nExp);
	me.AddBindMoney(nBindMoney);
	me.SetTask(SuperBattle.TASK_GID, SuperBattle.TASK_EXP, me.GetTask(SuperBattle.TASK_GID, SuperBattle.TASK_EXP) + nExp);
	me.AddKinReputeEntry(nRepute, "superbattle");
	--本服宋金声望
	self:AddRepute(nSort, nPoint);
	
	-- 股权
	Tong:AddStockBaseCount_GS1(me.nId, nOffer, 0.8, 0.1, 0.1, 0, 0);

	
	-- task
	if me.GetTask(1022, 233) == 1 and GetPlayerSportTask(me.nId, SuperBattle.GA_TASK_GID, SuperBattle.GA_TASK_TASK1) == 1 then
		me.SetTask(1022, 228, 1);
		GCExcute({"SuperBattle:FinishTask_GC", me.szName, 1});
	end
	
	if me.GetTask(1022, 234) == 1 and GetPlayerSportTask(me.nId, SuperBattle.GA_TASK_GID, SuperBattle.GA_TASK_TASK2) == 1 then
		me.SetTask(1022, 231, 1);
		GCExcute({"SuperBattle:FinishTask_GC", me.szName, 2});
	end
end

function tbNpc:AddRepute(nSort, nPoint)
	local nAddHonor = 0;
	local bLadder = 0;
	for i, nHonor in pairs(self.tbLadderHonor) do 
		if nSort <= i then
			nAddHonor = nHonor;
			bLadder = 1;
			break;
		end
	end
	if bLadder <= 0 then
		for i, nHonor in pairs(self.tbGradeHonor) do 
			if nPoint >= i then
				nAddHonor = nHonor;
				break;
			end
		end
	end
	if nAddHonor > 0 then
		PlayerHonor:AddPlayerHonor(me, PlayerHonor.HONOR_CLASS_BATTLE, 0, nAddHonor);		
	end
end

function tbNpc:Help()
	Task.tbHelp:OpenNews(5, "梦回采石矶");
end
