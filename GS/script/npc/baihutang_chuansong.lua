-- 白虎堂传送NPC


local tbNpc = Npc:GetClass("baihutangchuansong");

local tbKuaFuPrizeGDPL =	{18,1,1120,1};	--跨服白虎奖励宝箱gdpl
local nPrizeValue = 500;	--一个宝箱为500积分


tbNpc.nTopLevel = 90;
tbNpc.nBottomLevel = 50;

function tbNpc:Init()
	self.tbShopID =
	{
		[Env.FACTION_ID_SHAOLIN] 	= 89, -- 少林
		[Env.FACTION_ID_TIANWANG]	= 90, --天王掌门
		[Env.FACTION_ID_TANGMEN]	= 91, --唐门掌门
		[Env.FACTION_ID_WUDU]		= 93, --五毒掌门
		[Env.FACTION_ID_EMEI]		= 95, --峨嵋掌门
		[Env.FACTION_ID_CUIYAN]		= 96, --翠烟掌门
		[Env.FACTION_ID_GAIBANG]	= 98, --丐帮掌门
		[Env.FACTION_ID_TIANREN]	= 97, --天忍掌门
		[Env.FACTION_ID_WUDANG]		= 99, --武当掌门
		[Env.FACTION_ID_KUNLUN]		= 100, --昆仑掌门
		[Env.FACTION_ID_MINGJIAO]	= 92, --明教掌门
		[Env.FACTION_ID_DALIDUANSHI] = 94, --大理段氏掌门
		[Env.FACTION_ID_GUMU]		= 295,	-- 古墓
	}
end

tbNpc:Init();

function tbNpc:OnDialog()
	local nMapId	= me.nMapId;
	local tbOpt		= {};
	
	if (me.nLevel < tbNpc.nBottomLevel) then
		tbOpt[1] = {"Bạch Hổ Đường quá nguy hiểm, hãy luyện đến cấp 50 rồi tính!"};
	elseif (me.nFaction == 0) then
		tbOpt[1] = {"Hãy gia nhập môn phái rồi đến tham gia Bạch Hổ Đường."};
	else			
		
		if (me.nLevel >= tbNpc.nBottomLevel and me.nLevel < tbNpc.nTopLevel) then		
					
			table.insert(tbOpt, {"Ta muốn vào Bạch Hổ Đường (sơ 1)", self.OnTrans, self, BaiHuTang.ChuJi});
			-- 开放99级后后一周 75 + 7 后关闭 初级二
			if (TimeFrame:GetStateGS("CloseBaiHuTangChu2") == 0 )then 
				table.insert(tbOpt, {"Ta muốn vào Bạch Hổ Đường (sơ 2)", self.OnTrans, self, BaiHuTang.ChuJi2});
			end
			--table.insert(tbOpt, {"我想进入白虎堂（初级三）", self.OnTrans, self, BaiHuTang.ChuJi3});
		else
			table.insert(tbOpt, {"Ta muốn vào Bạch Hổ Đường (cao)", self.OnTrans, self, BaiHuTang.GaoJi});
			if BaiHuTang:IsOpenGolden() == 1 and me.nLevel >= 120 then
				table.insert(tbOpt, {"Bạn muốn vào Bạch Hổ (Hoàng Kim)", self.OnTrans, self, BaiHuTang.Goldlen});
			end
		end
		
		table.insert(tbOpt, {"[Quy tắc hoạt động]", self.Rule, self});
		table.insert(tbOpt, {"Trang bị Danh vọng Bạch Hổ Đường", self.BuyReputeItem, self});
		table.insert(tbOpt, {"Hoạt động Liên Server",self.ChangeKuaFuPrize,self});
		table.insert(tbOpt, {"Kết thúc đối thoại"});
	end
	Dialog:Say("Gần đây Bạch Hổ Đường xuất hiện đạo tặc, ngươi có thể giúp chúng ta không? Ta có thể đưa ngươi đến \"Đại điện Bạch Hổ Đường\", tình hình cụ thể hỏi \"Môn Đồ Bạch Hổ Đường\"\n\nĐi chứ?", tbOpt);
	
end

--规则显示
function tbNpc:Rule()
	local tbOpt = {};
	tbOpt[1] = {"Trở về đối thoại trước đó", self.OnDialog, self};
	tbOpt[2] =  {"Kết thúc đối thoại"};
	local szMsg = string.format("Thời gian báo danh <color=green>30<color> phút, thời gian hoạt động <color=green>30<color> phút. Sau khi hoạt động bắt đầu, trong Bạch Hổ Đường sẽ xuất hiện rất nhiều <color=red>Sấm Đường Tặc<color>, đánh bại chúng sẽ nhặt được vật phẩm và kinh nghiệm, sau một thời gian nhất định sẽ xuất hiện <color=red>Thủ Lĩnh Sấm Đường Tặc<color>, " .. 
"Đánh bại <color=red>Thủ Lĩnh Sấm Đường Tặc<color> sẽ xuất hiện lối vào tầng 2, Bạch Hổ Đường có 3 tầng, nếu bạn đánh bại thủ lĩnh ở cả 3 tầng thì sẽ mở được lối ra. Lưu ý: Khi vào Bạch Hổ Đường sẽ tự động bật chế độ chiến đấu, nên tốt nhất hãy tham gia hoạt động này cùng với hảo hữu, gia tộc hoặc bang hội. (Mỗi ngày chỉ được tham gia tối đa <color=red>%s lần<color>)\n<color=red>Chú ý: Để vào Bạch Hổ Đường (sơ) phải gia nhập gia tộc<color>", BaiHuTang.MAX_ONDDAY_PKTIMES);
	Dialog:Say(szMsg, tbOpt);
end
function tbNpc:OnTrans(nMapId)
	if EventManager.IVER_bOpenBaiLimit == 1 then
		if nMapId == BaiHuTang.ChuJi or nMapId == BaiHuTang.ChuJi2 then
			if me.dwKinId == 0 then
				Dialog:Say("Ngươi vẫn chưa có gia tộc, gia nhập gia tộc rồi hẵn đến!");
				return;
			end
		end
	end
	local nRect		= MathRandom(#BaiHuTang.tbPKPos);
	local tbPos		= BaiHuTang.tbPKPos[nRect];
	me.NewWorld(nMapId, tbPos.nX / 32, tbPos.nY / 32);
end

-- 购买白虎堂声望装备
function tbNpc:BuyReputeItem()
		local nFaction = me.nFaction;
		if nFaction <= 0 then
			Dialog:Say("Người chơi chữ trắng không mua được trang bị danh vọng");
			return 0;
		end
		me.OpenShop(self.tbShopID[nFaction], 1, 100, me.nSeries) --使用声望购买
end

--兑换跨服白虎奖励
function tbNpc:ChangeKuaFuPrize()
	local szMsg = string.format("Chào %s, ta có thể giúp được gì?",me.szName);
	local tbOpt = {};
	tbOpt[1] = {"Xem tích lũy", self.ViewKuaFuScores, self};
	tbOpt[2] = {"Đổi thưởng liên server",self.ExchangeBox_Info,self};
	tbOpt[3] = {"Trở về",self.OnDialog,self};
	tbOpt[4] = {"Kết thúc đối thoại"};
	Dialog:Say(szMsg,tbOpt);
end

function tbNpc:ViewKuaFuScores()
	local nSportScores = GetPlayerSportTask(me.nId,KuaFuBaiHu.GB_TASK_GID,KuaFuBaiHu.GB_TASK_SCORES) or 0;
	local nLocalScores = me.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_MYSERVER_SCORES) or 0;
	local nUseScores = nSportScores - nLocalScores;
	local szMsg = string.format("Hiện tích lũy Bạch Hổ liên server là: <color=green>%s<color>",tostring(nUseScores));
	local tbOpt = {};
	tbOpt[1] = {"Trở về",self.ChangeKuaFuPrize,self};
	tbOpt[2] = {"Kết thúc đối thoại"}
	Dialog:Say(szMsg,tbOpt);
end

function tbNpc:ExchangeBox_Info()
	local nSportScores = GetPlayerSportTask(me.nId,KuaFuBaiHu.GB_TASK_GID,KuaFuBaiHu.GB_TASK_SCORES) or 0;
	local nLocalScores = me.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_MYSERVER_SCORES) or 0;
	local nUseScores = nSportScores - nLocalScores;
	local nCount = math.floor(nUseScores / nPrizeValue);
	if nCount < 1 then
		local szMsg = string.format("Hiện tích lũy Bạch Hổ liên server là <color=red>%s<color>, không đủ đổi rương!",tostring(nUseScores));
		local tbOpt = {};
		tbOpt[1] = {"Trở về",self.ChangeKuaFuPrize,self};
		tbOpt[2] = {"Kết thúc đối thoại"}
		Dialog:Say(szMsg,tbOpt);
	elseif nCount >= 1 then
		local szMsg = string.format("Hiện tích lũy Bạch Hổ liên server là: <color=yellow>%s<color>, có thể đổi <color=yellow>%s<color> rương, có muốn đổi không?",tostring(nUseScores),tostring(nCount));
		local tbOpt = {};
		tbOpt[1] = {"Vâng",self.ExchangeBox,self};
		tbOpt[2] = {"Sau này mới đổi"};
		Dialog:Say(szMsg,tbOpt);
	end
end

function tbNpc:ExchangeBox()
	local nSportScores = GetPlayerSportTask(me.nId,KuaFuBaiHu.GB_TASK_GID,KuaFuBaiHu.GB_TASK_SCORES) or 0;
	local nLocalScores = me.GetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_MYSERVER_SCORES) or 0;
	local nUseScores = nSportScores - nLocalScores;
	local nCount	 = math.floor(nUseScores / nPrizeValue);
	local nFreeBagCell = me.CountFreeBagCell();	--背包空间
	local tbPrizeProp = KItem.GetOtherBaseProp(tbKuaFuPrizeGDPL[1],tbKuaFuPrizeGDPL[2],tbKuaFuPrizeGDPL[3],tbKuaFuPrizeGDPL[4]);
	local nMaxPrizeCount = tbPrizeProp["nStackMax"] or 5000;
	local nPrizeCount = math.ceil(nCount / nMaxPrizeCount);--宝箱叠加100个，计算需要几个背包空间
	if nFreeBagCell < nPrizeCount then
		local szMsg = string.format("Ít nhất chừa %s ô túi trống!",tostring(nPrizeCount));
		me.Msg(szMsg,"Hệ thống");
		return 0;
	end
	me.AddStackItem(tbKuaFuPrizeGDPL[1],tbKuaFuPrizeGDPL[2],tbKuaFuPrizeGDPL[3],tbKuaFuPrizeGDPL[4],nil,nCount);
	local nNewScores = nLocalScores + nPrizeValue * nCount;
	me.SetTask(KuaFuBaiHu.TASK_GID,KuaFuBaiHu.TASK_MYSERVER_SCORES,nNewScores);	--将使用过的积分存储
	
	SpecialEvent.ActiveGift:AddCounts(pPlayer, 35);		--领取跨服白虎堂奖励活跃度
end