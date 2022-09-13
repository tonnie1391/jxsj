-------------------------------------------------------
-- 文件名　：keyimen_item.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2012-02-22 11:31:58
-- 文件描述：
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\boss\\keyimen\\keyimen_def.lua");

local tbPad = Item:GetClass("keyimen_item_pad");

function tbPad:InitGenInfo()	
	it.SetTimeOut(0, Lib:GetDate2Time(GetLocalDate("%Y%m%d")) + 3600 * 24);
	return {};
end

function tbPad:OnUse()
	if Keyimen:CheckPeriod() ~= 1 then
		me.Msg("Chưa đến thời gian chiến trường Khắc Di Môn, mỗi ngày từ 14:30-15:15 và 21:30-22:15 sẽ mở chiến trường!")
		return 0;
	end
	
	local szMapClass = GetMapType(me.nMapId) or "";
	if szMapClass ~= "village" and szMapClass ~= "city" and szMapClass ~= "battle_wild" then
		Keyimen:SendMessage(me, self.MSG_CHANNEL, "Quân Lệnh chỉ có thể sử dụng ở Tân thủ thôn, Thành thị và Khắc Di Môn.");
		return 0;
	end
	
	local nKinId, nMemberId = me.GetKinMember();	
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		Keyimen:SendMessage(me, self.MSG_CHANNEL, "Xin lỗi, không có gia tộc, không thể sử dụng.");
		return 0;
	end
	
	if me.dwTongId <= 0 then
		Keyimen:SendMessage(me, self.MSG_CHANNEL, "Xin lỗi, không có bang hội, không thể sử dụng.");
		return 0;
	end
	
	local tbOpt = {{"Ta hiểu rồi"}};
	local szMsg = "    <color=yellow>Tộc trưởng hoặc Tộc phó<color> có thể sử dụng Quân Lệnh <color=yellow>ở bản đồ phe đối địch<color> đặt 1 Quân Kỳ, thành viên gia tộc có thể truyền tống đến Quân Kỳ trong thời gian nhất định.";
	local nTime, tbPos = Keyimen:GetKinFlagPos(nKinId);
	if nTime == 0 then
		table.insert(tbOpt, 1, {"<color=gray>Truyền tống đến Quân Kỳ<color>"});
	else
		table.insert(tbOpt, 1, {string.format("<color=yellow>Truyền tống đến Quân Kỳ (%s giây)<color>", nTime), self.FlyFlag, self});
	end
	
	if Kin:CheckSelfRight(nKinId, nMemberId, 2) == 1 then
		local nRet = Keyimen:CheckKinFlag_GS(me, me.dwTongId, nKinId);
		if nRet == 0 then
			table.insert(tbOpt, 1, {"<color=gray>Đặt Quân Kỳ<color>"});
		elseif nRet == 1 then
			table.insert(tbOpt, 1, {"<color=yellow>Đặt Quân Kỳ<color>", self.SetFlag, self});
		else
			table.insert(tbOpt, 1, {string.format("<color=gray>Đặt Quân Kỳ còn (%s giây)<color>", 0 - nRet)});
		end
	end
	
	Dialog:Say(szMsg, tbOpt);
end

function tbPad:FlyFlag()
	local nKinId, nMemberId = me.GetKinMember();	
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	local nTime, tbPos = Keyimen:GetKinFlagPos(nKinId);
	if nTime == 0 then
		return 0;
	end
	if me.nFightState > 0 then
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
		GeneralProcess:StartProcess("Đang truyền tống...", 1 * Env.GAME_FPS, {self.DoFly, self, tbPos}, nil, tbBreakEvent);
	else
		me.SetFightState(1);
		self:DoFly(tbPos);
	end
end

function tbPad:DoFly(tbPos)
	me.NewWorld(unpack(tbPos));
end

function tbPad:SetFlag(nClose)
	local nKinId, nMemberId = me.GetKinMember();	
	local pKin = KKin.GetKin(nKinId);
	if not pKin then
		return 0;
	end
	if Kin:CheckSelfRight(nKinId, nMemberId, 2) ~= 1 then
		return 0;
	end
	local nTongId = me.dwTongId;
	if nTongId <= 0 then
		return 0;
	end
	if Keyimen:CheckKinFlag_GS(me, nTongId, nKinId) == 1 then
		Keyimen:KinFlag_GS(me, nTongId, nKinId);
	end
end

-- 工资银锭
local tbSalaryItem = Item:GetClass("keyimen_item_salary");
function tbSalaryItem:OnUse()
	local nAddYinDing = math.floor(Keyimen.BASE_SALARY * Lib:_GetXuanEnlarge(Kinsalary:GetOpenDay()));
	local nCurYinDing = me.GetTask(Kinsalary.TASK_GID, Kinsalary.TASK_YINDING);
	if nCurYinDing + nAddYinDing > Kinsalary.MAX_NUMBER then
		Dialog:Say("Tài sản Gia tộc đạt mức tối đa, hãy sử dụng bớt rồi tiếp tục!");
		return 0;
	end
	me.SetTask(Kinsalary.TASK_GID, Kinsalary.TASK_YINDING, nCurYinDing + nAddYinDing);
	Kinsalary:SendMessage(me, Kinsalary.MSG_CHANNEL, string.format("Nhận được %s thỏi bạc Gia tộc", nAddYinDing));
	return 1;
end

-- 龙锦玉匣
local tbYuxia = Item:GetClass("keyimen_Item_yuxia");
function tbYuxia:OnUse()
	if IpStatistics:CheckStudioRole(me) ~= 1 then
		return Item:GetClass("randomitem"):SureOnUse(357);
	else
		return Item:GetClass("randomitem"):SureOnUse(358);
	end
end

-- 龙魂侠影声望
local tbReputeItem = Item:GetClass("keyimen_Item_repute");
function tbReputeItem:OnUse()
	me.AddRepute(15, 1, 20);
	return 1;
end
