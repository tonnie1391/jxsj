-------------------------------------------------------------------
--File: 	factionbattle_npc.lua
--Author: 	zhengyuhua
--Date: 	2008-1-8 17:38
--Describe:	门派战npc对话逻辑
-------------------------------------------------------------------

-- 门派竞技功能选项对话
function FactionBattle:ChoiceFunc(nFaction)
	if (EventManager.IVER_bOpenTiFu == 1) then
	Dialog:Say("Thi đấu môn phái vào tối thứ 3 và thứ 5 hàng tuần sẽ bắt đầu báo danh - 20:00 Sẽ bắt đầu\n<color=red>Điểm của mỗi lần thi đấu sẽ được thay đổi ở những lần thi tiếp theo<color>",
		{
			{"Tôi muốn tham gia thi đấu môn phái", self.EnterMap, self, nFaction},
			{"Điểm đổi giải thưởng", self.ExchangeExp, self, me.nId},
		});
	else
		Dialog:Say(string.format("Thi đấu môn phái vào tối thứ 3 và thứ %s hàng tuần sẽ bắt đầu báo danh - 20:00 Sẽ bắt đầu\n<color=red>Điểm của mỗi lần thi đấu sẽ được thay đổi ở những lần thi tiếp theo<color>", EventManager.IVER_szSecFactionDay),
			{
				{"Tôi muốn tham gia thi đấu môn phái", self.EnterMap, self, nFaction},
				{"Điểm đổi giải thưởng", self.ExchangeExp, self, me.nId},
			});
	end
end

-- 报名参加门派战
function FactionBattle:SignUp(nFaction)
	if me.GetTiredDegree1() == 2 then
		Dialog:Say("Ngươi quá mệt mỏi xin hãy nghĩ ngơi");
		return;
	end
	local tbData = self:GetFactionData(nFaction);
	if not tbData then
		Dialog:Say("Hiện tại không có trận thi đấu môn phái nào！");
		return 0;
	elseif tbData.nState > self.SIGN_UP then
		if (EventManager.IVER_bOpenTiFu == 1) then
			Dialog:Say("Thi đấu môn phái đã bắt đầu, hiện tại không thể tiếp nhận đăng ký, mời bạn tham gia những hoạt động khác tại đây");
		else
			Dialog:Say("Thi đấu môn phái đã bắt đầu lúc 20:00h, hiện tại không thể tiếp nhận đăng ký, mời bạn tham gia những hoạt động khác tại đây");
		end
		return 0;
	end
	if me.nFaction ~= nFaction then
		Dialog:Say("Bạn không phải là đệ tử của môn phái này, không thể tham gia thi đấu!");
		return 0;
	end
	if me.nLevel < self.MIN_LEVEL then
		Dialog:Say("Cấp độ của bạn không đủ"..self.MIN_LEVEL.."Không thể tham gia thi đấu môn phái, nhưng có thể tham gia các hoạt động khác tại đây");
		return 0;
	end
--	if (Wlls:CheckFactionLimit() == 1 and me.nLevel >= self.MAX_LEVEL) then
--		Dialog:Say("你已经出师了，不能进入本门的门派竞技场!");
--		return 0;
--	end
	if tbData:GetAttendPlayuerCount() >= self.MAX_ATTEND_PLAYER then
		Dialog:Say("Số người đăng ký đã đến mức giới hạn "..self.MAX_ATTEND_PLAYER.." người, không thể tiếp nhận đăng ký, nhưng có thể tham gia các hoạt động khác tại đây");
	else
		local nRet = tbData:AddAttendPlayer(me.nId);
		if nRet == 0 then
			Dialog:Say("Bạn đã đăng ký rồi!");
		else
			Dialog:Say("Đăng ký thành công, hãy đợi để tham gia tại đây, nếu thoát sẽ mất tư cách tham gia thi đấu!<color=yellow>trận đấu sẽ chính thức bắt đầu lúc 19:30");
		end
	end
end

-- 进入门派竞技场地图
function FactionBattle:EnterMap(nFaction)
	if me.GetTiredDegree1() == 2 then
		Dialog:Say("您太累了，还是休息下吧！");
		return;
	end
	local nFlag = self:GetBattleFlag(nFaction);
	if nFlag ~= 1 then
		if (EventManager.IVER_bOpenTiFu == 1) then
			Dialog:Say("Trận thi đấu môn phái vào tối thứ 3 và 5 lúc 19:30 hàng tuần sẽ bắt đầu nhận đăng ký 20:00 sẽ bắt đầu\nHiện tại vẫn chưa mở");
		else
			Dialog:Say(string.format("Trận thi đấu môn phái vào tối thứ 3 và thứ %s lúc 19:30 hàng tuần sẽ bắt đầu nhận đăng ký 20:00 sẽ bắt đầu\nHiện tại vẫn chưa mở", Lib:Transfer4LenDigit2CnNum(EventManager.IVER_szSecFactionDay)));
		end
		
		return 0;
	end
	 if me.nFaction ~= nFaction then
		Dialog:Say("Bạn không phải là đệ tử môn phái này, không thể tham gia thi đấu!");
		return 0;
	end
--	if (Wlls:CheckFactionLimit() == 1 and me.nLevel >= self.MAX_LEVEL) then
--		Dialog:Say("你已经出师了，不能进入本门的门派竞技场!");
--		return 0;
--	end
	if me.nLevel < self.MIN_LEVEL then
		Dialog:Say("Cấp độ của bạn không đủ"..self.MIN_LEVEL.."không thể tham gia thi đấu。");
		return 0;
	end
	
	self:TrapIn(me);
	-- 记录参加次数
	local nNum = me.GetTask(StatLog.StatTaskGroupId , 2) + 1;
	me.SetTask(StatLog.StatTaskGroupId , 2, nNum);
	
	SpecialEvent.ActiveGift:AddCounts(me, 23);		--参加门派竞技活跃度
end

-- 离开门派竞技场对话
function FactionBattle:LeaveMap(nFaction, bConfirm)
	nFaction = me.nFaction;
	if bConfirm == 1 then
		Npc.tbMenPaiNpc:Transfer(nFaction);
		return 0;
	end
	Dialog:Say("Bạn có chắc muốn thoát không? nếu không có mặt lúc trận đấu bắt đầu, bạn sẽ mất quyền tham gia",
		{
			{"Đồng ý", FactionBattle.LeaveMap, FactionBattle, nFaction, 1},
			{"Ta muốn suy nghĩ lại"}
		}
	);
end

function FactionBattle:CancelSignUp(nFaction, bConfirm)
	if bConfirm == 1 then
		local tbData = self:GetFactionData(nFaction);
		if tbData ~= nil then
			if tbData.nState ~= self.SIGN_UP then
				Dialog:Say("Trận thi đấu đã bắt đầu,không thể hủy tư cách tham gia.");
				return 0;
			end
			tbData:DelAttendPlayer(me.nId)
			Dialog:Say("Bạn đã hủy tư cách tham gia thi đấu.");
		end
		return 0;
	end
	Dialog:Say("Xác nhận muốn hủy bỏ báo danh?",
		{
			{"Đồng ý", FactionBattle.CancelSignUp, FactionBattle, nFaction, 1},
			{"Ta muốn suy nghĩ lại"}
		}
	);	
end

function FactionBattle:ChampionFlagNpc(pPlayer, pNpc)
	self:ExcuteAwardChampion(pPlayer, pNpc);
end

