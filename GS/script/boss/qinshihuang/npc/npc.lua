-------------------------------------------------------
-- 文件名　：npc.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-06-15 15:28:48
-- 文件描述：
-------------------------------------------------------

-- 秦陵安全区 NPC 对话
-- By Peres 2009/06/13 PM 06:55

local tbF1_Npc_1 = Npc:GetClass("qinling_safenpc1_1");
local tbF1_Npc_2 = Npc:GetClass("qinling_safenpc1_2");
local tbF1_Npc_3 = Npc:GetClass("qinling_safenpc1_3");
local tbF1_Npc_4 = Npc:GetClass("qinling_safenpc1_4");

local tbF2_Npc_1 = Npc:GetClass("qinling_safenpc2_1");
local tbF2_Npc_2 = Npc:GetClass("qinling_safenpc2_2");
local tbF2_Npc_3 = Npc:GetClass("qinling_safenpc2_3");

-- 第一层的 NPC 
function tbF1_Npc_1:OnDialog()
	Dialog:Say("Tôn Cương: Ngươi có thể giữ được mạng xem như rất có bản lĩnh! Nếu trên người đang có thương tích, thì xem như ngươi gặp được cứu tinh rồi! Đương nhiên, ta phải lấy tiền.",
		{"<color=gold>[Bạc khóa]<color> Ta muốn mua thuốc", self.OnBuyYaoByBind, self},
		{"<color=gold>[Bạc khóa]<color> Ta muốn mua thức ăn", self.OnBuyCaiByBind, self},
		{"Ta muốn mua thuốc", self.OnBuyYao, self},
		{"Kết thúc đối thoại"});
end

function tbF1_Npc_2:OnDialog()
	Dialog:Say("Tống Thu Thu: Thủy Hoàng quả không hổ danh, Tống Thu Thu ta đã từng khai quật không ít mộ phần, lần đầu tiên thấy một nơi hiểm ác đáng sợ như ở đây. Liệu xung quanh đây có phải toàn là yêu quái?");
end

function tbF1_Npc_3:OnDialog()
	Dialog:Say("Gia Cát Tiểu Thảo: Ta vừa mới suýt bị đám du hồn kia tiễn về Tây phương... Ngươi còn ở đây làm gì? Muốn nhìn thấy thây thối ngàn năm của Tần Thủy Hoàng ư? Đừng nằm mơ nữa!",
		{"Hãy đưa ta quay trở về!", self.OnLeave, self},
		{"Kết thúc đối thoại"}
		);
end

function tbF1_Npc_3:OnLeave()
	me.SetLogoutRV(0);
	Boss.Qinshihuang:_MapResetState(me);
	me.NewWorld(Boss.Qinshihuang:GetLeaveMapPos());
end

function tbF1_Npc_4:OnDialog()
	Dialog:Say("Quan Nhất Đao: Ha ha! Bị nhát đến ngu người ra rồi phải không? Ta có một phối phương có thể giúp ngươi thay đổi thịt, có điều... vấn đề là ngươi phải bỏ tiền ra mới được",
		{"Hãy cho ta xem ngươi có món gì tốt", self.OnShop, self},
		{"Kết thúc đối thoại"});
end


-- 第二层的 NPC 
function tbF2_Npc_1:OnDialog()
	Dialog:Say("Dã Tẩu: Vị hiệp khách này, nhìn mặt quen quá!...Nếu có bị thương tích gì thì cứ đến tìm lão phú nhé! Đúng rồi, nếu có nhặt được những chai lọ gì mà không dùng thì cứ mang đến cho lão nhé!",
		{"<color=gold>[Bạc khóa]<color>Ta muốn mua thuốc", self.OnBuyYaoByBind, self},
		{"<color=gold>[Bạc khóa]<color>Ta muốn mua thức ăn", self.OnBuyCaiByBind, self},
		{"Ta muốn mua thuốc", self.OnBuyYao, self},
		{"Ta nhặt được thứ kỳ quái này...", self.ChangeMask, self},
		{"Ta muốn Thanh Đồng Luyện Phổ", self.ChangeRefine, self},   	-- 武器炼化图谱
		{"Danh vọng đổi Thanh Đồng Luyện Phổ", self.OnChangeReputeToRefine, self},
		{"Kết thúc đối thoại"});
end

function tbF2_Npc_2:OnDialog()
	Dialog:Say("Trương Nguyên: Khà khà! Đến được tầng 3 này, xem ra bản lĩnh của ngươi cũng không tệ...");
end

function tbF2_Npc_3:OnDialog()
	Dialog:Say("Bạch Miêu Miêu: Bọn ta nhất định sẽ thực hiện được hoài bão của trại chủ!",
		{"Mua vũ khí cấp 120 <color=gold>(Kim)<color>", self.OnShop, self, 1},
		{"Mua vũ khí cấp 120 <color=gold>(Mộc)<color>", self.OnShop, self, 2},
		{"Mua vũ khí cấp 120 <color=gold>(Thủy)<color>", self.OnShop, self, 3},
		{"Mua vũ khí cấp 120 <color=gold>(Hỏa)<color>", self.OnShop, self, 4},
		{"Mua vũ khí cấp 120 <color=gold>(Thổ)<color>", self.OnShop, self, 5},
		{"Kết thúc đối thoại"});
end


-- 买药
function tbF1_Npc_1:OnBuyYaoByBind()
	me.OpenShop(14,7);
end

function tbF1_Npc_1:OnBuyYao()
	me.OpenShop(14,1);
end

function tbF2_Npc_1:OnBuyYaoByBind()
	me.OpenShop(14,7);
end

function tbF2_Npc_1:OnBuyYao()
	me.OpenShop(14,1);
end

-- 买菜
function tbF1_Npc_1:OnBuyCaiByBind()
	me.OpenShop(21,7);
end

function tbF2_Npc_1:OnBuyCaiByBind()
	me.OpenShop(21,7);
end

tbF2_Npc_1.tbData = {
	{18,1,370,100},
	{18,1,371,300},
	{18,1,372,100},	
}

-- 兑换面具
function tbF2_Npc_1:ChangeMask()
	Dialog:Say("Dã Tẩu: Ở những khu vực này bất cứ ngươi lấy được món đồ nào cũng đều quý báu cả. Nếu có món nào ngươi không hiểu cách sử dụng thì cứ mang đến cho ta nhé! Sẽ có phần thưởng bất ngờ cho ngươi!",
		{"Ta nhặt được 1 miếng Vải phượng vũ", self.ChangeItemGift, self, 1},	-- 20 格背包
		{"Ta nhặt được 1 Khăn tay có chữ", self.ChangeItemGift, self, 2},	-- 24 格背包
		{"Ta nhặt được 1 Phát quán dị thường", self.ChangeItemGift, self, 3},   -- 秦始皇面具
		{"Kết thúc đối thoại"}
		)
end

function tbF2_Npc_1:ChangeRefine()
	local tbParam = 
	{
		tbAward = {{nGenre = 18, nDetail = 2, nParticular = 385, nLevel = 1, nCount = 1, nBind=1}},
		tbMareial = {{nGenre = 18, nDetail = 1, nParticular = 377, nLevel = 1, nCount = 5}},
	};
	Dialog:OpenGift("Đặt vào 5 Hòa Thị Bích có thể đổi 1 Luyên Hóa Đồ Phổ", tbParam);
end

function tbF2_Npc_1:OnChangeReputeToRefine()
	Dialog:Say("Ngươi muốn dùng <color=yellow>500 điểm Danh Vọng – Phát Khâu Môn<color> đổi Thanh Đồng Luyện Phổ cấp 110 chứ? <color=yellow>Chỉ có thể giảm điểm trong cấp danh vọng hiện tại.<color>",
		{
			{"Vâng", self.ChangeReputeToRefine, self},
			{"Không"},
		}
		);
end

function tbF2_Npc_1:ChangeReputeToRefine()
	local nDelRepute	= 500;
	local nRepute		= me.GetReputeValue(9,2);
	local nLevel		= me.GetReputeLevel(9,2);
	if (nDelRepute > nRepute) then
		Dialog:Say("Cấp Danh Vọng – Phát Khâu Môn hiện tại không đủ để giảm <color=yellow>500 điểm<color>!");
		return;
	end

	if (me.CountFreeBagCell() < 1) then
		Dialog:Say("Hành trang không đủ chỗ trống, không thể đổi Vũ Khí Thanh Đồng Luyện Hóa Đồ.");
		return;
	end	
	
	me.AddRepute(9, 2, -1*nDelRepute);
	local nNowRepute	= me.GetReputeValue(9,2);
	local nNowLevel		= me.GetReputeLevel(9,2);
	local szLog = string.format("%s delete %d repute, last Repute: %d, Level: %d, now Repute: %d, level: %d!!", me.szName, nDelRepute, nRepute, nLevel, nNowRepute, nNowLevel);
	Dbg:WriteLogEx(Dbg.LOG_INFO, "Qinshihuang", "npc", "ChangeReputeToRefine", szLog);
	local pItem			= me.AddItem(18,2,385,1,1,1);
	if (not pItem) then
		Dbg:WriteLogEx(Dbg.LOG_INFO, "Qinshihuang", "ChangeReputeToRefine", string.format("%s get the item failed!", me.szName));
		return;
	end
	Dbg:WriteLogEx(Dbg.LOG_INFO, "Qinshihuang", "ChangeReputeToRefine", string.format("%s get the item success!", me.szName));
end

function tbF2_Npc_1:ChangeItemGift(nItemId)
	local szMsg	= {
		[1]="Dã Tẩu: Ngươi nhặt được 1 miếng Vải phượng vũ? Ta đang có 1 <color=green>Túi hương Triệu Cơ (Túi 20 ô)<color> có thể đổi cho ngươi, có điều ngươi phải <color=yellow>thêm 100 Dạ Minh Châu<color> mới được! <color=red>Sau khi đổi vật này sẽ bị khóa!<color>",
		[2]="Dã Tẩu: Ngươi nhặt được 1 Khăn tay có chữ? Ta đang có 1 <color=green>Ký ức công chúa A Nhược (Túi 24 ô)<color> có thể đổi cho ngươi, có điều ngươi phải <color=yellow>thêm 300 Dạ Minh Châu<color> mới được! <color=red>Sau khi đổi vật này sẽ bị khóa!<color>",
		[3]="Dã Tẩu: Ngươi nhặt được 1 Phát quán dị thường? Ta đang có 1 <color=green>Mặt nạ Tần Thủy Hoàng<color> có thể đổi cho ngươi, có điều ngươi phải <color=yellow>thêm 100 Dạ Minh Châu<color> mới được! <color=red>Sau khi đổi vật này sẽ bị khóa!<color>",
	}
	Dialog:Say(szMsg[nItemId], {"<color=yellow>Được thôi! Dạ Minh Châu ta đã chuẩn bị đủ rồi!<color>", self.ChangeItem, self, nItemId}, {"Thôi đi!"});
end

function tbF2_Npc_1:ChangeItem(nItemId)
	
	local tbData = 
	{
		{100, 21, 8, 3, 1, 18, 1, 370, 1},
		{300, 21, 9, 5, 1, 18, 1, 371, 1},
		{100, 1, 13, 24, 1, 18, 1, 372, 1},
	};
	
	local nFind = me.GetItemCountInBags(18, 1, 357, 1);
	if nFind < tbData[nItemId][1] then
		Dialog:Say("Dã Tẩu: Ngươi... Ngươi thật sự có <color=yellow>"..tbData[nItemId][1].." Dạ Minh Châu<color>? Đừng gạt lão đầu này nhé!");
		return;
	end
	
	local nFindItem = me.GetItemCountInBags(tbData[nItemId][6], tbData[nItemId][7], tbData[nItemId][8], tbData[nItemId][9]);
	if nFindItem < 1 then
		Dialog:Say("Dã Tẩu: Ngươi... Ngươi thật sự có thứ đó? Đừng gạt lão đầu này nhé!");
		return;
	end
	
	local bRet1 = me.ConsumeItemInBags2(tbData[nItemId][1], 18, 1, 357, 1);
	local bRet2 = me.ConsumeItemInBags2(1, tbData[nItemId][6], tbData[nItemId][7], tbData[nItemId][8], tbData[nItemId][9]);
	
	if bRet1 == 0 and bRet2 == 0 then
		local pItem = me.AddItem(tbData[nItemId][2], tbData[nItemId][3], tbData[nItemId][4], tbData[nItemId][5]);	
		if pItem then
			pItem.Bind(1);
			local szMsg = string.format("Tại Tần Lăng trao đổi thành công %s, mất %d Dạ Minh Châu", pItem.szName, tbData[nItemId][1]);
			me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, szMsg);
		end
	end
end

-- 买炼化声望物品
function tbF1_Npc_4:OnShop()
	me.OpenShop(155, 1);
end

-- 买武器
function tbF2_Npc_3:OnShop(nSeries)
	local tbData = {156,157,158,159,160};
	me.OpenShop(tbData[nSeries], 1);
end

-------------------------------------------------------
-- by zhangjinpin@kingsoft
-------------------------------------------------------

-- 传送npc
local tbEnterNpc1 = Npc:GetClass("qinling_enternpc_1");


function tbEnterNpc1:OnDialog()

	local tbOpt	= {
		{"Đúng vậy, đưa ta xuống dưới", self.EnterQingling},
		{"Thôi đi"}
	};
	
	local szMsg = "Lương Tiếu Tiếu: Lâu lắm rồi ta chưa thấy một tên trộm nào dám mò vào đây, nơi này dễ vào, ra khó... Ta thấy tiếc cho ngươi quá... Liệu có phải ngươi muốn xuống?";
	
	Dialog:Say(szMsg, tbOpt);
end

-- 进入秦陵
function tbEnterNpc1:EnterQingling()
	local bGreenServer = KGblTask.SCGetDbTaskInt(DBTASK_TIMEFRAME_OPEN);
	local nType  = Ladder:GetType(0, 2, 1, 0) or 0;	-- 由于ladder的tbconfig没有gs副本，所有特殊处理，获取战斗力等级排行榜的type
	local tbInfo = GetHonorLadderInfoByRank(nType, 50);	-- 等级排行榜第50名
	local nLadderLevel = 0;
	if (tbInfo) then
		nLadderLevel = tbInfo.nHonor;
	end

	if me.GetTiredDegree1() == 2 then
		Dialog:Say("您太累了，还是休息下吧！");
		return;
	end
	if Boss.Qinshihuang:_CheckState() ~= 1 then
		Dialog:Say("Rất tiếc, hệ thống Tần Lăng tạm thời đóng cửa", {"Ta biết rồi"});
		return;
	end
	
	if bGreenServer == 1 then  --绿色服务器限制
		if nLadderLevel < 100 then
			Dialog:Say("梁笑笑：皇陵还未开放，本服50人达到100级后将会自动开启。", {"Ta hiểu rồi"});
			return;
		end
	end
	
	if TimeFrame:GetState("OpenBoss120") ~= 1 then
		Dialog:Say("Lương Tiếu Tiếu: Người của ta đã vào trong dò hỏi vẫn chưa thấy tin tức! Ngươi không nên vào trong để chịu chết.", {"Ta biết rồi"});
		return;
	end	
	
	-- 100级才可以进入
	if me.nLevel < 100 then
		Dialog:Say("Lương Tiếu Tiếu: Đẳng cấp ngươi chỉ có vậy mà cũng muốn vào trong? Hãy đi tu luyện thêm đi!", {"Ta biết rồi"});
		return;
	end
	
	-- 门派限制
	if me.nFaction <= 0 then
		Dialog:Say("Lương Tiếu Tiếu: Tên chữ trắng cũng muốn vào trong? Mau tìm một môn phái gia nhập vào đi chứ!", {"Ta biết rồi"});
		return;
	end
	
	local nUseTime = me.GetTask(Boss.Qinshihuang.TASK_GROUP_ID, Boss.Qinshihuang.TASK_USE_TIME);
	
	-- 剩余时间为0
	if nUseTime >= Boss.Qinshihuang.MAX_DAILY_TIME then
		Dialog:Say("Lương Tiếu Tiếu: Hôm nay ngươi đã ở dưới đó 1 khoảng thời gian khá lâu rồi, xuống lần nữa nhất định ngươi sẽ không chịu nổi khí độc bên trong, có lẽ ngươi hãy chờ ngày mai quay lại!", {"Ta biết rồi"});
		return;
	end
	
	if me.GetSkillState(CrossTimeRoom.nLimitJoinHuanglingBuffId) > 0 then
		Dialog:Say("Lương Tiếu Tiếu: Trong thời gian vượt Thời Quan Điện, không thể vào Tần Lăng!", {"Ta hiểu rồi"});
		return;
	end
		
	me.SetFightState(0);
	me.NewWorld(1536, 1567, 3629);	-- 1层安全区
end

-- 传送阵
local tbPassNpc1 = Npc:GetClass("qinling_pass1");
local tbPassNpc2 = Npc:GetClass("qinling_pass2");

function tbPassNpc1:OnDialog()
	
	-- 启动进度条
	local tbBreakEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SIT,
		Player.ProcessBreakEvent.emEVENT_RIDE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_CHANGEEQUIP,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,		
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_REVIVE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
	}
	GeneralProcess:StartProcess("Đến Tầng 5 - Nam", 20 * Env.GAME_FPS, {self.OnPassSouth, self}, nil, tbBreakEvent);	
end

function tbPassNpc1:OnPassSouth()
	me.NewWorld(1540, 1790, 3183);
end

function tbPassNpc2:OnDialog()
	
	-- 启动进度条
	local tbBreakEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SIT,
		Player.ProcessBreakEvent.emEVENT_RIDE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_CHANGEEQUIP,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,		
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_REVIVE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
	}
	GeneralProcess:StartProcess("Đến Tầng 5 - Bắc", 20 * Env.GAME_FPS, {self.OnPassNorth, self}, nil, tbBreakEvent);	
end

function tbPassNpc2:OnPassNorth()
	me.NewWorld(1540, 1915, 3312);
end

-- 神捕吴用
local tbEnterNpc2 = Npc:GetClass("qinling_enternpc_2");

function tbEnterNpc2:OnDialog()
	local szMsg = "Ngô Dụng: Hừm! Người tìm đến Tần Lăng này chỉ muốn trộm cướp các bảo vật mà thôi! Ngươi chắc cũng không hơn gì bọn chúng! Nếu không có chuyện gì thì mau cút cho khuất mắt ta!";	
	Dialog:Say(szMsg, {"Kết thúc đối thoại"});
end

-- 路路通
local tbFreewayNpc = Npc:GetClass("qinling_npc_freeway");

function tbFreewayNpc:OnDialog()
	local szMsg = "Hãy chọn nơi muốn đến:";
	local tbOpt = {};
	for i, tbInfo in ipairs(Boss.Qinshihuang.tbTranList) do
		table.insert(tbOpt, {tbInfo[0], self.Transfer, self, i});
	end
	tbOpt[#tbOpt + 1] = {"Ta hiểu rồi"};
	Dialog:Say(szMsg, tbOpt);
end

function tbFreewayNpc:Transfer(nIndex)
	local tbData = Boss.Qinshihuang.tbTranList[nIndex];
	if not tbData then
		return 0;
	end
	local szMsg = "Hãy chọn nơi muốn đến:";
	local tbOpt = {};
	for i, tbInfo in ipairs(tbData) do
		if i ~= 0 then
			table.insert(tbOpt, {tbInfo[1], self.DoTransfer, self, tbInfo[2]});
		end
	end
	tbOpt[#tbOpt + 1] = {"Ta hiểu rồi"};
	Dialog:Say(szMsg, tbOpt);
end

function tbFreewayNpc:DoTransfer(tbPos)
	local tbBreakEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SIT,
		Player.ProcessBreakEvent.emEVENT_RIDE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_CHANGEEQUIP,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,		
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_REVIVE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
	}
	GeneralProcess:StartProcess("Đang truyền tống...", 8 * Env.GAME_FPS, {self.DoTransferEnd, self, tbPos}, nil, tbBreakEvent);	
end

function tbFreewayNpc:DoTransferEnd(tbPos)
	if tbPos[1] == 1540 and Boss.Qinshihuang:CheckOpenQinFive() ~= 1 then
		Dialog:SendBlackBoardMsg(me, "Bên trong nguy hiểm khó lường, tốt nhất không nên vào!");
		return 0;
	end
	me.SetFightState(1);
	me.NewWorld(unpack(tbPos));
end
