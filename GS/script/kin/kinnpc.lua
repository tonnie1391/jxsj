-------------------------------------------------------------------
--File: kinnpc.lua
--Author: lbh
--Date: 2007-7-4 11:47
--Describe: 帮会相关npc对话逻辑
-------------------------------------------------------------------
if not Kin then --调试需要
	Kin = {}
	print(GetLocalDate("%Y/%m/%d/%H/%M/%S").." build ok ..")
end

Kin.AwardCount = {
	{{1, 1, 2, 2, 3}, {1, 1, 2, 3, 4}, {1, 2, 3, 4, 5},},
	{{1, 2, 4, 6, 9}, {1, 2, 4, 8, 12}, {1, 3, 6, 10, 15},},
	};


function Kin:DlgCreateKin(szKin, nCamp)
	if me.GetCamp() == 0 then
		Dialog:Say("Người mới chơi, không thể lập gia tộc!")
		return 0
	end
	if me.IsCaptain() ~= 1 then
		Dialog:Say("Không phải đội trưởng, không thể lập gia tộc!")
		return 0
	end	
	local nTeamId = me.nTeamId
	local anPlayerId, nPlayerNum = KTeam.GetTeamMemberList(nTeamId)
	if not anPlayerId or not nPlayerNum or nPlayerNum < 1 or me.nLevel < self.MIN_PLAYER_LEVEL then 
		Dialog:Say(string.format("Tổ đội 3 người trên cấp %s, thân mật cấp 2 mới lập được gia tộc", self.MIN_PLAYER_LEVEL));
		return 0
	end
	local aLocalPlayer, nLocalPlayerNum = me.GetTeamMemberList()
	--TODO:判断是否在周围
	if nPlayerNum ~= nLocalPlayerNum then
		Dialog:Say("Tổ đội cùng đến mới lập được gia tộc!")
		return 0
	end
	-- by jiazhenwei  金牌网吧建立家族5w
	local nMoneyCreat = self.CREATE_KIN_MONEY;
	if SpecialEvent.tbGoldBar:CheckPlayer(me) == 1 then
		nMoneyCreat = math.min(nMoneyCreat, 50000);
	end	
	--end
	--by jiazhenwei 某个日期之前建立家族折扣(不可以和物品及金牌网吧的叠加，取最小值)
	local tbBuffer = GetGblIntBuf(GBLINTBUF_LOGIN_AWARD, 0);
	if not tbBuffer or type(tbBuffer) ~= "table" then
		tbBuffer = {};
	end
	local nMoneyDiscount = 0;
	if tbBuffer[2] and tbBuffer[2][1] and Lib:GetDate2Time(tbBuffer[2][1]) > GetTime() then
		nMoneyDiscount = math.floor(self.CREATE_KIN_MONEY * tbBuffer[2][2] /10000);
		nMoneyCreat = math.min(nMoneyCreat, nMoneyDiscount);
	end
	--end
	if me.nCashMoney < nMoneyCreat then
		Dialog:Say("Lập gia tộc cần <color=yellow>"..nMoneyCreat.."<color> bạc, vui lòng mang đủ bạc trên người.")
		return 0
	end
	local function _FindIndex(nId)
		for i, v in ipairs(anPlayerId) do
			if v == nId then
				return i
			end
		end
	end
	local anStoredRepute = {}
	for i, cPlayer in ipairs(aLocalPlayer) do
		if cPlayer.nPlayerIndex ~= me.nPlayerIndex then
			if cPlayer.nLevel < self.MIN_PLAYER_LEVEL then
				Dialog:Say(string.format("Cấp dưới %s, không thể lập gia tộc!", self.MIN_PLAYER_LEVEL));
				return 0
			end
			if cPlayer.GetCamp() == 0 then
				Dialog:Say("Người mới chơi, không thể lập gia tộc!")
				return 0
			end
			if (EventManager.IVER_bOpenTiFu ~= 1) then
				local nFavor = me.GetFriendFavor(cPlayer.szName)
				if not nFavor or nFavor < 1 then
				Dialog:Say("Độ thân mật chưa đạt cấp 2, không thể lập gia tộc!")
					return 0
				end
			end
			local nKinId = cPlayer.GetKinMember();
			if nKinId and nKinId ~= 0 then
				Dialog:Say("Một thành viên trong đội đã có gia tộc, không thể lập gia tộc!");
				return 0
			end
		end
		local j = _FindIndex(cPlayer.nId)
		if not j then
			return 0
		end
		--按anPlayerId的次序记录缓存的江湖威望
		anStoredRepute[j] = cPlayer.nPrestige;
	end
	if not szKin or szKin == "" then
		me.CallClientScript{"Kin:ShowCreateKinDlg"}
		return 0
	end
	local nRet = self:CreateKin_GS1(anPlayerId, anStoredRepute, szKin, nCamp, me.nId)
	if nRet ~= 1 then
		local szMsg = "Lập gia tộc thất bại!"
		if nRet == -1 then
			szMsg = szMsg.."Độ dài tên gia tộc phải từ 6-12 ký tự!"
		elseif nRet == -2 then
			szMsg = szMsg.."Không sử dụng các ký tự đặc biệt để đặt tên, có thể sử dụng ký hiệu [] !"
		elseif nRet == -3 then
			szMsg = szMsg.."Tên gia tộc chứa các từ ngữ nhạy cảm, hãy nhập lại!"
		elseif nRet == -4 then
			szMsg = szMsg.."Tên gia tộc đã tồn tại!"
		elseif nRet == -5 then
			szMsg = szMsg.."Thành viên trong nhóm đã có gia tộc!"
		end
		Dialog:Say(szMsg);
		return 0
	end
	return 1
end

-- 获取要领取的奖励索引
function Kin:GetAwardIndex()
	local nFigure = me.nKinFigure;
	local nFirstIndex = 1;
	local nSecIndex = 1;
	if (1 == nFigure) then	-- 族长
		nFirstIndex = 2;
	else
		nFirstIndex = 1;
	end	
	local nKinId = me.dwKinId;
	local cKin = KKin.GetKin(nKinId);
	local nLastTaskLevel = cKin.GetLastTaskLevel();
	if (Kin.TASK_LEVEL_LOW == nLastTaskLevel) then	-- 上周周任务目标等级
		nSecIndex = 1;
	elseif (Kin.TASK_LEVEL_MID == nLastTaskLevel) then
		nSecIndex = 2;
	elseif (Kin.TASK_LEVEL_HIGH == nLastTaskLevel) then
		nSecIndex = 3;
	end
	return nFirstIndex, nSecIndex;
end

-- 家族活动相关
function Kin:DlgAboutWeeklyAction()
	local szMsg = "Những thành viên có đóng góp xuất sắc sẽ nhận được phần thưởng hấp dẫn. Ngươi đến đây làm gì?";
	Dialog:Say(szMsg,
		{
			{"Thay đổi mục tiêu hoạt động tuần", self.DlgModifyTaskLevel, self},
			{"Nhận thưởng hoạt động tuần", self.DlgGetWeeklyActionAward, self, 0},
		});
end

-- 修改家族周活动目标等级
function Kin:DlgModifyTaskLevel()
	local szMsg = "Mục tiêu hoạt động tuần dựa trên cấp độ của thành viên:\nSơ cấp - cấp độ 50->79\nTrung cấp - cấp độ 80->89\nCao cấp - cấp độ 90 trở lên" ..
					"\n\nMục tiêu càng cao sẽ càng khó, nhưng phần thưởng cũng nhiều hơn. Ngươi muốn thay đổi mức nào?";
	Dialog:Say(szMsg,
		{
			{"Thay đổi đến mức Sơ cấp", self.ModifyLevel, self, Kin.TASK_LEVEL_LOW},
			{"Thay đổi đến mức Trung` cấp", self.ModifyLevel, self, Kin.TASK_LEVEL_MID},
			{"Thay đổi đến mức Cao cấp", self.ModifyLevel, self, Kin.TASK_LEVEL_HIGH},
			{"Để ta suy nghĩ lại"},
		});
end

function Kin:ModifyLevel(nTaskLevel)
	local nKinId, nMemberId = me.GetKinMember()
	if self:CheckSelfRight(nKinId, nMemberId, 2) ~= 1 then
		Dialog:Say("Bạn không có quyền thực hiện chức năng này.");
		return 0;
	end 
	
	if (nTaskLevel ~= Kin.TASK_LEVEL_LOW and nTaskLevel ~= Kin.TASK_LEVEL_MID and nTaskLevel ~= Kin.TASK_LEVEL_HIGH) then
		return 0;
	end

	local szMsg = "";
	if (0 == TimeFrame:GetState("OpenLevel89") and (nTaskLevel == Kin.TASK_LEVEL_MID or nTaskLevel == Kin.TASK_LEVEL_HIGH)) then
		szMsg = szMsg .. "Máy chủ mở cấp 89, không thể thay đổi thành mức Trung hoặc Cao.";
	elseif (0 == TimeFrame:GetState("OpenLevel99") and nTaskLevel == Kin.TASK_LEVEL_HIGH) then
		szMsg = szMsg .. "Máy chủ mở cấp 99, không thể thay đổi thành mức Cao.";
	end
	if ("" ~= szMsg) then
		Dialog:Say(szMsg);
		return 0;
	end
	local nKinId = me.dwKinId;
	local cKin = KKin.GetKin(nKinId);
	GCExcute{"Kin:SetNewTaskLevel_GC", nKinId , nTaskLevel};
	local szLevel = "";
	if (Kin.TASK_LEVEL_LOW == nTaskLevel) then
		szLevel = szLevel .. "Sơ cấp";
	elseif (Kin.TASK_LEVEL_MID == nTaskLevel) then
		szLevel = szLevel .. "Trung cấp";
	elseif (Kin.TASK_LEVEL_HIGH == nTaskLevel) then
		szLevel = szLevel .. "Cao cấp";
	end
	szMsg = "Mức hoạt động tuần của Gia tộc đã đổi thành <color=yellow>" .. szLevel .. "<color>, hiệu lực sẽ bắt đầu vào tuần tới.";
	Dialog:Say(szMsg);
end
-- 家族更换阵营
function Kin:DlgChangeCamp(nCamp)
	local nKinId, nExcutorId = me.GetKinMember()
	local nRet, cKin = self:CheckSelfRight(nKinId, nExcutorId, 1)
	
	
	if nRet ~= 1 then
		Dialog:Say("Chỉ có tộc trưởng mới có thể đổi phe");
		return 0;
	end
	if cKin.GetBelongTong() ~= 0 then
		Dialog:Say("Gia tộc đang trong Bang hội, không thể đổi phe");
		return 0;
	end
	local nDate = tonumber(Lib:GetLocalDay(GetTime()));
	if cKin.GetChangeCampDate() == nDate then
		Dialog:Say("Hôm nay Gia tộc đã đổi phe 1 lần rồi.")
		return 0;
	end
	if me.nCashMoney < self.CHANGE_CAMP then
		Dialog:Say("Cần <color=red>"..(self.CHANGE_CAMP / 10000).." vạn bạc<color> để đổi phe!");
		return 0;
	end
	if not nCamp then
		Dialog:Say("Cần <color=red>"..(self.CHANGE_CAMP / 10000).." vạn bạc<color> để đổi phe. Bạn muốn chọn phe nào?",
			{{"Mông cổ", self.DlgChangeCamp, self, 1},
			 {"Tây hạ", self.DlgChangeCamp, self, 2},
			 {"Trung lập", self.DlgChangeCamp, self, 3},
			 {"Để ta suy nghĩ thêm"}
			});
	else
		if cKin.GetCamp() == nCamp then
			Dialog:Say("Đã theo phe này rồi, không cần thay đổi nữa!");
			return 0;
		end
		-- 先扣钱了……GC挂了会导致吞钱~写个log吧
		me.CostMoney(self.CHANGE_CAMP, Player.emKPAY_KIN_CAMP);
		Dbg:WriteLog("家族","扣取更换阵营费用"..self.CHANGE_CAMP, "角色名:"..me.szName, "帐号:"..me.szAccount, "家族ID:"..nKinId);
		GCExcute{"Kin:ChangeCamp_GC", nKinId, nExcutorId, nCamp}
	end
end

-- 家族令牌相关选择
function Kin:DlgKinExp()
	local nKinId, nMemberId = me.GetKinMember();	
	if nKinId == 0 then
		Dialog:Say("Bạn đã gia nhập gia tộc");
	end
	
	local cKin = KKin.GetKin(nKinId);	
	if not cKin then
		return 0;
	end
	
	-- 判断需不需要收费给牌子 如果没设置预定时间，则不用收费，否则则要收费清空预定时间再给牌子
	local tbSay = {};
	if cKin.GetKinBuildFlagOrderTime() == 0 then
		table.insert(tbSay, {"Nhận cờ gia tộc", self.DlgGetKinExp, self, 0});
	else
	 	table.insert(tbSay, {"Thay đổi thời gian cắm cờ gia tộc", self.DlgChangBuildFlagSetting, self, 0});
	end
	table.insert(tbSay, {"Kết thúc đối thoại"});
	
	Dialog:Say("Sau khi Cắm cờ gia tộc, bạn có thể thay đổi thời gian để thuận tiện cho việc họp mặt thành viên.", tbSay)
end

-- 家族插旗时间修改
function Kin:DlgChangBuildFlagSetting(bConfirm)
	local nKinId, nMemberId = me.GetKinMember();	
	if nKinId == 0 then
		Dialog:Say("Bạn đã gia nhập gia tộc");
	end
	
	local cKin = KKin.GetKin(nKinId);	
	if not cKin then
		return 0;
	end
	
	local nRet, cKin = self:CheckSelfRight(nKinId, nMemberId, 2);	
	if nRet ~= 1 then
		Dialog:Say("Chỉ có tộc trưởng hoặc tộc phó mới có thể nhận cờ gia tộc!");
		return 0;
	end
	
	local nTime = GetTime();
	local nNowDay = tonumber(os.date("%m%d", nTime));
	
	-- 如果今天已经领过了
	if cKin.GetGainExpState() == nNowDay then
		Dialog:Say("Hôm nay đã thay đổi thời gian cắm cờ, nếu muốn thay đổi hay quay lại vào ngày mai.");
		return 0;
	end
	
	if bConfirm ~= 1 then
		Dialog:Say("Thay đổi thời gian cần 100000 bạc",
				{{"Ta đồng ý", self.ConfirmBuildFlagSetting, self},
			 	{"Để ta suy nghĩ đã"}		
		})
		return 0;
	end
	
	-- 如果包包不足
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang đã đầy!")
		return 0;
	end
	
	if me.CostMoney(100000, Player.emKPAY_BUILD_FLAG_TIME) ~= 1 then
		me.Msg("Sửa thời gian và địa điểm cắm cờ gia tộc rất tốn kém, cần mang đủ 100000 bạc để thực hiện.");
		return 0;
	end
	
	Dbg:WriteLog("Kin","PlayerID:"..me.nId,"Account:"..me.szAccount.."修改插旗预定时间花费：100000银两");
	
	return GCExcute{"Kin:ChangeKinExpState_GC", me.nId, nKinId, nMemberId};
end

function Kin:ConfirmBuildFlagSetting()
	Dialog:Say("Bạn có chắc muốn thay đổi? Không hối tiếc chứ?",
				{{"Vâng, tôi chắc chắn", self.DlgChangBuildFlagSetting, self, 1},
			 	 {"Không thay đổi"}		
				})
end

-- 家族令牌的领取
function Kin:DlgGetKinExp(bConfirm)
	local nKinId, nMemberId = me.GetKinMember();
	if nKinId == 0 then
		Dialog:Say("Bạn đã gia nhập gia tộc");
		return 0;
	end
	
	local nRet, cKin = self:CheckSelfRight(nKinId, nMemberId, 2);	
	if nRet ~= 1 then
		Dialog:Say("Chỉ có tộc trưởng hoặc tộc phó mới có thể nhận mã thông báo gia tộc!");
		return 0;
	end

	local nTime = GetTime();
	local nNowDay = tonumber(os.date("%m%d", nTime));

	
	--  家族已经领取过了的情况要重新处理,领过了但没设置时间 和 领过了并设置了时间的要分开处理
	local nOrderTime = cKin.GetKinBuildFlagOrderTime();	
	if bConfirm ~= 1 and cKin.GetGainExpState() == nNowDay then 
		Dialog:Say("你的家族已经领取过了。请尽快设置家族插旗活动的时间及地点");
		return 0;
	end
	
	-- 还没领
	if bConfirm ~= 1 and cKin.GetGainExpState() ~= nNowDay then 
		Dialog:Say("Hãy đặt thời gian và địa điểm. Chúng tôi sẽ tự động mở hoạt động trong thời gian tới.",
				{{"Xác nhận", self.DlgGetKinExp, Kin, 1},
			 	{"Để ta suy nghĩ lại"}		
				})
		return 0;
	end
	
	-- 如果包包不足
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang đã đầy!")
		return 0;
	end
	
	return GCExcute{"Kin:GetKinLingPai_GC", nKinId, nMemberId};
end

function Kin:DlgShowKinRecruitmentList()
	me.CallClientScript({"UiManager:OpenWindow", "UI_KINRCM_LIST" });
end
