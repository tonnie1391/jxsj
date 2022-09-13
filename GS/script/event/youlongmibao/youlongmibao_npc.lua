-------------------------------------------------------
-- 文件名　：youlongmibao_npc.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-11-05 23:22:33
-- 文件描述：
-------------------------------------------------------

Require("\\script\\event\\youlongmibao\\youlongmibao_def.lua");

-- 九公主芊芊
local tbNpc = Npc:GetClass("qianqian_dialog");

function tbNpc:OnDialog()

	local szMsg = "Này, bạn muốn khiêu chiến Tiểu Long Nữ? Ở đây có nhiều tính năng khác nữa. Tí nữa đừng khóc gọi mẹ nha!!!\n\n";
	Youlongmibao:RefreshCanYoulongCount(me)
	local nNowCount = me.GetTask(Youlongmibao.TASK_GROUP_ID, Youlongmibao.TASK_CAN_YOULONG_COUNT);
	szMsg = string.format("%sMỗi ngày ngươi có thể tích lũy <color=yellow>20 lần<color> cho mỗi nhân vật, và có thể tích lũy tối đa <color=yellow>200 lần<color>.\nLượt khiêu chiến còn lại: <color=yellow>%s lượt<color>.", szMsg, nNowCount);
	local tbOpt = 
	{
		{"Bắt đầu khiêu chiến", self.StartGame, self},
		{"Nguyệt Ảnh Thạch đổi Chiến Thư", self.Challenge, self},
		{"Đổi Du Long Danh vọng lệnh", self.Shengwang, self},
		{"Đổi Tiền Du Long", self.ChangeCoin, self},
		{"Rời khỏi đây", self.LeaveHere, self},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:StartGame()
	if me.GetTiredDegree1() == 2 then
		Dialog:Say("Hôm nay không thể tiếp tục khiêu chiến.");
		return;
	end
	if KGblTask.SCGetDbTaskInt(DBTASD_EVENT_YOULONGGESWITCH) == 1 then
		local nFlag = Player:CheckTask(Youlongmibao.TASK_GROUP_ID, Youlongmibao.TASK_ATTEND_DATE, "%Y%m%d", Youlongmibao.TASK_ATTEND_NUM, 10);
		if nFlag == 0 then
			Dialog:Say("Hôm nay không thể tiếp tục khiêu chiến.");
			return;
		end
	end
	if Youlongmibao.tbPlayerList[me.nId] then	
		Youlongmibao:RecoverAward(me);
	else
		Youlongmibao:Continue(me);
	end
end

function tbNpc:GetAward()
	
	local nGetAward = Youlongmibao:CheckGetAward(me);
	
	if nGetAward == 1 then
		Youlongmibao:RecoverAward(me);
	else
		Dialog:Say("Bạn đã nhận phần thưởng rồi. Xin hãy rời khỏi đây!");
	end
end

function tbNpc:Challenge()
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang bị khóa, không thể thao tác!");
		return 0;
	end
	Dialog:OpenGift("Bạn có thể đổi Nguyệt Ảnh Thạch lấy Chiến Thư Du Long tại đây", nil, {Youlongmibao.OnChallenge, Youlongmibao});
end

function tbNpc:LeaveHere()
	
	local tbOpt = 
	{
		{"Xác nhận", Youlongmibao.OnPlayerLeave, Youlongmibao},
		{"Để ta suy nghĩ thêm"},
	}	
	Dialog:Say("Ngươi muốn rời khỏi đây?", tbOpt);
end

function tbNpc:Shengwang()
	local szMsg = "Tại đây, ngươi có thể sử dụng <color=yellow>Du Long Danh Vọng Lệnh (vé)<color> để đổi <color=yellow>“Du Long Danh Vọng Lệnh”<color>. Ngươi muốn đổi loại nào?"
	local tbOpt = 
	{
		{"Đổi danh vọng [Hộ thân phù]", self.OnShengwang, self, 1},
		{"Đổi danh vọng [Nón]", self.OnShengwang, self, 2},
		{"Đổi danh vọng [Y phục]", self.OnShengwang, self, 3},
		{"Đổi danh vọng [Yêu đái]", self.OnShengwang, self, 4},
		{"Đổi danh vọng [Giày]", self.OnShengwang, self, 5},
		{"Đổi danh vọng [Liên]", self.OnShengwang, self, 6},
		{"Đổi danh vọng [Tay]", self.OnShengwang, self, 7},
		{"Để ta suy nghĩ lại"},
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnShengwang(nType)
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản đang bị khóa, không thể thao tác!");
		return 0;
	end
	Dialog:OpenGift("Hãy đặt vào Du Long Danh Vọng Lệnh (vé)", nil, {Youlongmibao.OnShengwang, Youlongmibao, nType});
end

function tbNpc:ChangeCoin()
	Dialog:OpenGift("Hãy đặt Du Long Lệnh, ta sẽ đổi Tiền Du Long cho ngươi", nil, {Youlongmibao.OnChangeCoin, Youlongmibao});
end
