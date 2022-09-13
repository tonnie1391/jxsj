-- 文件名　：duanwu2011_item.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-05-17 09:46:10
-- 描  述  ：

Require("\\script\\event\\specialevent\\duanwu2011\\duanwu2011_def.lua");
SpecialEvent.DuanWu2011 = SpecialEvent.DuanWu2011 or {};
local tbDuanWu2011 = SpecialEvent.DuanWu2011 or {};

-- 材料
local tbMaterial = Item:GetClass("duanwu2011_material");

function tbMaterial:OnUse()
	local nRet, szMsg = tbDuanWu2011:CheckCanUse(me);
	if nRet ~= 1 then
		me.Msg(szMsg);
		return 0;
	end
	local nTodayRemainNum = tbDuanWu2011:CheckTodayMakeRemainNum(me);
	local szMsg = string.format("Hôm nay bạn có thể làm <color=yellow>%s<color> bánh.\n\nChắc chứ?", nTodayRemainNum);
	local tbOpt = 
	{
		{"Xác nhận", self.MakeDumpling, self, nTodayRemainNum},
		{"Để ta suy nghĩ thêm"},	
	};
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

function tbMaterial:MakeDumpling(nNum)
	Dialog:AskNumber("Nhập số lượng:", nNum, tbDuanWu2011.MakeDumplingDlg, tbDuanWu2011);
end

-- 粽子
local tbDumpling = Item:GetClass("duanwu2011_dumpling");

function tbDumpling:OnUse()
	local nRet, szMsg = tbDuanWu2011:CheckCanUse(me);
	if nRet ~= 1 then
		me.Msg(szMsg);
		return 0;
	end
	nRet, szMsg = tbDuanWu2011:CheckCanFish(me);
	if nRet ~= 1 then
		me.Msg(szMsg);
		return 0;
	end
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
	}
		
	GeneralProcess:StartProcess("Đang thao tác...", 10 * Env.GAME_FPS, 
		{SpecialEvent.DuanWu2011.FeedingFish, SpecialEvent.DuanWu2011, me.nId}, nil, tbEvent);
	return 0;
end

-- 勋章
local tbMedals = Item:GetClass("duanwu2011_medals");

function tbMedals:OnUse()
	local nRet, szMsg = tbDuanWu2011:CheckCanUse(me);
	if nRet ~= 1 then
		me.Msg(szMsg);
		return 0;
	end
	local nKinId, nMemberId = me.GetKinMember();
	if nKinId == 0 or nMemberId == 0 then
		me.Msg("Phải có Gia tộc mới có thể sử dụng。");
		return 0;
	end
	local cKin = KKin.GetKin(nKinId)
	if not cKin then
		me.Msg("Phải có Gia tộc mới có thể sử dụng。");
		return 0
	end
	GCExcute{"SpecialEvent.DuanWu2011:AddMedals_GC", nKinId, tbDuanWu2011.MEDALS_POINT, me.nId};
	Dbg:WriteLog("duanwu2011", "usemedals", me.szName, nKinId);
	me.Msg("Sử dụng thành công, tăng 5 điểm tích lũy Trung Hồn Đoan Ngọ Gia tộc.");
	return 1;
end

-- 忠魂令牌
local tbLingPai = Item:GetClass("duanwu2011_lingpai");

function tbLingPai:OnUse()
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	if nDate < tbDuanWu2011.RANK_OPEN_DAY then
		Dialog:Say("Hoạt động vẫn chưa bắt đầu!");
		return 0;
	end
	if nDate > tbDuanWu2011.RANK_CLOSE_DAY then
		Dialog:Say("Hoạt động đã kết thúc.");
		return 0
	end
	local nKinId, nMemberId = me.GetKinMember();
	if Kin:CheckSelfRight(nKinId, nMemberId, 2) ~= 1 then
		Dialog:Say("Tộc trưởng và Tộc phó mới có thể sử dụng.");
		return 0;
	end
	if GetMapType(me.nMapId) ~= "fight" then
		Dialog:Say("Chỉ có thể sử dụng tại bản đồ chiến đấu!");
		return 0;
	end
	local tbNpcList = KNpc.GetAroundNpcList(me, 10);
	for _, pNpc in ipairs(tbNpcList) do
		if pNpc.nTemplateId == tbDuanWu2011.NPC_QUYUAN_ID then
			Dialog:Say("Nơi này đã có Khuất Nguyên Trung Hồn, hãy triệu hồi ở địa điểm khác!");
			return 0;
		end
	end
	local tbEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SITE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_DEATH,
	}
		
	GeneralProcess:StartProcess("Đang triệu hồi...", 5 * Env.GAME_FPS, 
		{SpecialEvent.DuanWu2011.AddDuanWuZhongHun, SpecialEvent.DuanWu2011, me.nId}, nil, tbEvent);
	return 0;
end

-- 霸王鱼
local tbBaWangYu = Item:GetClass("duanwu2011_bawangyu");

function tbBaWangYu:OnUse()
	if me.CountFreeBagCell() < 2 then
		Dialog:Say("Hành trang không đủ chỗ trống, hãy chuẩn bị <color=yellow>2 ô trống<color>.");
		return 0;
	end
	local tbRandomItem = Item:GetClass("randomitem");
	local nRet = tbRandomItem:OnUse();
	if nRet ~= 1 then
		return 0;
	end
	-- 没有背包直接返回
	if me.CountFreeBagCell() < 1 then
		return 1;
	end
	local nHonorRank = PlayerHonor:GetPlayerHonorRankByName(me.szName, PlayerHonor.HONOR_CLASS_MONEY, 0);
	local nType = 1;
	if not nHonorRank or nHonorRank <= 0 or nHonorRank > tbDuanWu2011.MIN_WEALTHORDER then
		nType = 2;
	end
	if tbDuanWu2011:RandFragment(nType) ~= 1 then
		return 1;
	end
	local pItem = me.AddItem(unpack(tbDuanWu2011.ITEM_FRAGMENT_ID));
	StatLog:WriteStatLog("stat_info", "duanwujie_2011", "repute_item", me.nId, 1);
	if not pItem then
		Dbg:WriteLog("tbDuanWu201", "add_suipian_failure", me.szName, nHonorRank);
	end
	return 1;
end

-- 碎片
local tbFragment = Item:GetClass("duanwu2011_fragment");

function tbFragment:OnUse()
	local nFlag = Player:AddRepute(me, 13, 1, tbDuanWu2011.DUANWU_REPUTE);

	if (0 == nFlag) then
		return;
	elseif (1 == nFlag) then
		me.Msg("Danh vọng đã đạt cấp cao nhất!");
		return;
	end	

	me.Msg(string.format("Bạn nhận được <color=yellow>%s điểm<color> Danh vọng Trung Hồn Đoan Ngọ.",tbDuanWu2011.DUANWU_REPUTE));
	return 1;
end