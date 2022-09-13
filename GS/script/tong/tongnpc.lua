-------------------------------------------------------------------
--File: tongnpc.lua
--Author: lbh
--Date: 2007-9-19 23:21
--Describe: 帮会相关npc对话逻辑
-------------------------------------------------------------------
if not Tong then --调试需要
	Tong = {}
	print(GetLocalDate("%Y\\%m\\%d  %H:%M:%S").." build ok ..")
end

function Tong:DlgCreateTong(bConfirm, szTong, nCamp, bAccept)
	if me.IsCaptain() ~= 1 then
		Dialog:Say("Không phải đội trưởng không thể tạo Bang hội")
		return 0
	end	
	local nTeamId = me.nTeamId
	local anPlayerId, nPlayerNum = KTeam.GetTeamMemberList(nTeamId)
	if not anPlayerId or not nPlayerNum or nPlayerNum < 1 then 
		Dialog:Say("Ba tộc trưởng lập tổ đội rồi hãy đến gặp ta")
		return 0
	end
	if me.dwTongId ~= 0 then
		Dialog:Say("Bạn đã có Bang hội, không thể lập Bang")
		return 0
	end
	local anKinId = {}
	local nSelfKinId, nSelfMemberId = me.GetKinMember()
	local cSelfKin = KKin.GetKin(nSelfKinId)	
	if not cSelfKin or cSelfKin.GetCaptain() ~= nSelfMemberId then		
		me.Msg("Bạn không phải Tộc trưởng, không thể tham gia tạo Bang hội")
		return 0
	end
	table.insert(anKinId, nSelfKinId)
	local aLocalPlayer, nLocalPlayerNum = me.GetTeamMemberList()
	--TODO:判断是否在周围
	if nPlayerNum ~= nLocalPlayerNum then
		Dialog:Say("Tất cả Tộc trưởng phải tập trung tại đây!")
		return 0
	end
	-- by jiazhenwei  金牌网吧建立帮会80w
	local nMoneyCreat = self.CREATE_TONG_MONEY;
	if SpecialEvent.tbGoldBar:CheckPlayer(me) == 1 then
		nMoneyCreat = 800000;
	end	
	--end
	--创建扣取金钱说明
	if bConfirm ~= 1 then
		Dialog:Say(string.format("Để lập Bang cần có %s Vạn lượng, đồng thời gây quỹ xây dựng trong 2 tuần phải >=1000 Vạn lượng để vượt qua thời gian thử nghiệm, nếu không Bang hội sẽ tự động giải tán, <color=yellow>100 Vạn lượng tạo Bang sẽ không được hoàn trả lại.<color> Bạn chắc chứ?", nMoneyCreat), 
			{{"Đồng ý", self.DlgCreateTong, self, 1}, {"Để ta suy nghĩ lại"}})
			return 0
	end
	if me.nCashMoney < nMoneyCreat then
		Dialog:Say("Bạn không đủ <color=yellow>"..(nMoneyCreat / 10000).." Vạn lượng<color>, trong hành trang.")
		return 0
	end	
	for i, cPlayer in ipairs(aLocalPlayer) do
		if cPlayer.nPlayerIndex ~= me.nPlayerIndex then
			if cPlayer.dwTongId ~= 0 then
				Dialog:Say("Một thành viên trong tổ đội là người đã có Bang hội, không thể tạo Bang")
				return 0
			end
			local nKinId, nMemberId = cPlayer.GetKinMember()
			if Kin:CheckSelfRight(nKinId, nMemberId, 1) ~= 1 then
				me.Msg("Tất cả thành viên phải đều là Tộc trưởng (chưa bãi nhiệm). Hãy tìm người phù hợp hơn.")
				return 0
			end
			table.insert(anKinId, nKinId)
		end
	end

	if not szTong or szTong == "" then
		me.CallClientScript{"Tong:ShowCreateTongDlg"}
		return 0
	end
	
---------------------------------------------------------------------------------------------------------
	local nReturn = 1;
	local nKinFund = 0;
	for _k,_v in pairs(anKinId) do
		nKinFund = nKinFund + Kin:GetTotalKinStock(_v);
	end

	local nStockPersent = 1;
	if (not bAccept or bAccept ~= 1) then
		if  (nKinFund > 0 and nKinFund > self.MAX_BUILD_FUND) then
			nStockPersent = self.MAX_BUILD_FUND / nKinFund;
			local nTemp = math.floor(nStockPersent * 100);
			local szMsg = "Tạo Bang hội <color=yellow>".. szTong .. "<color>\n";
			szMsg = szMsg .. "Vì tổng quỹ xây dựng hiện tại của Gia tộc gần vượt quá giới hạn của quỹ xây dựng Bang hội"
			szMsg = szMsg .. ", nên khi Bang hội được thành lập, tài sản cá nhân của Gia tộc sẽ giảm xuống <color=yellow> " .. nTemp .. "%<color>";
			
			for i, cPlayer in ipairs(aLocalPlayer) do
				local szTemp = szMsg;
				szTemp = szTemp .. " \nXác nhận bởi <color=yellow>[".. me.szName .. "]<color>!"
				cPlayer.Msg(szTemp);
			end
			
			local function SayWhat(aPlayer)
				for i, cPlayer in ipairs(aPlayer) do
					local szTemp =  " 队长 <color=yellow>【".. me.szName .. "】<color> Hủy bỏ了建立帮会！"
					cPlayer.Msg(szTemp);
				end
			end
			
			Dialog:Say(szMsg,
				{
					{"Lập Bang hội", self.DlgCreateTong, self, bConfirm, szTong, nCamp, 1},
					{"Hủy bỏ", SayWhat, aLocalPlayer},
				});
			return 0;
		end
	end
---------------------------------------------------------------------------------------------------------
	
	local nRet = self:CreateTong_GS1(anKinId, szTong, nCamp, me.nId);
	if nRet ~= 1 then		
		local szMsg = "Tạo Bang hội thất bại!"
		if nRet == -1 then
			szMsg = szMsg.."Độ dài tên Bang hội không đúng"
		elseif nRet == -2 then
			szMsg = szMsg.."Không thể chứa ký tự đặc biệt"
		elseif nRet == -3 then
			szMsg = szMsg.."Không thể chứa ký tự nhạy cảm"
		elseif nRet == -4 then
			szMsg = szMsg.."Tên Bang hội đã tồn tại!"
		elseif nRet == -5 then
			szMsg = szMsg.."Thành viên trong nhóm đã có Bang hội"
		end
		Dialog:Say(szMsg);
		return 0
	end
	return 1
end

function Tong:DlgChangeCamp(nCamp)
	local nTongId = me.dwTongId;
	if nTongId == 0 then
		Dialog:Say("Bạn chưa gia nhập Bang hội, không thể đổi phe.")
		return 0;
	end
	local nKinId, nMemberId = me.GetKinMember();
	if self:CheckSelfRight(nTongId, nKinId, nMemberId, self.POW_CAMP) ~= 1 then
		Dialog:Say("Bạn không có quyền đổi Phe Bang hội");
		return 0;
	end
	if not nCamp then
		Dialog:Say("Cần tiêu hao "..(Tong.CHANGE_CAMP / 10000).." Vạn lượng quỹ xây dựng Bang hội để tái thiết lập Phe",
			{{"Mông cổ", self.DlgChangeCamp, self, 1},
			 {"Tây Hạ", self.DlgChangeCamp, self, 2},
			 {"Trung Lập", self.DlgChangeCamp, self, 3},
			 {"Để ta suy nghĩ lại"}
			});
	else 
		self:ChangeCamp_GS1(nCamp);		
	end
end

-- 领取分红
function Tong:DlgTakeStock(bConfirm)
	local nTongId = me.dwTongId;
	local pTong = KTong.GetTong(nTongId)
	if not pTong then
		Dialog:Say("Bạn chưa gia nhập Bang hội, không thể nhận lợi tức.")
		return 0
	end
	
	local nTotalFund = pTong.GetBuildFund();
	local nTotalStock = pTong.GetTotalStock();
	local nKinId, nMemberId = me.GetKinMember();
	local pKin = KKin.GetKin(nKinId);
	local pMember = pKin.GetMember(nMemberId);
	local nPersonalStock = pMember.GetPersonalStock();
	local nCurWeek = tonumber(os.date("%Y%W", GetTime()))
	if nTotalFund == 0 or nTotalStock == 0 or nPersonalStock == 0 then
		Dialog:Say("Bạn không có gì để nhận.");
		return 0;
	end
	local nTakePercent = pTong.GetLastTakeStock()
	if nTakePercent <= 0 then
		Dialog:Say("Tuần trước chưa thiết lập cổ tức, không thể nhận ở tuần này.");
		return 0;
	end
	local nWeeks = me.GetTask(self.TONG_TASK_GROUP, self.TONG_TAKE_STOCK_WEEKS);
	if nWeeks == nCurWeek then
		Dialog:Say("Bạn đã nhận của tuần này rồi.");
		return 0;
	end
	local szMsg = "";
	local tbOpt = {};
	local nTakeStock = math.floor(nTakePercent * nPersonalStock / 100);
	local nTakeMoney = math.floor(nTakeStock * nTotalFund / nTotalStock);
	local nMoney = math.floor(nPersonalStock * nTotalFund / nTotalStock);
	if pTong.GetBuildFund() < self.MIN_BUILDFUND then
		Dialog:Say("Quỹ xây dựng ít hơn "..self.MIN_BUILDFUND..", không thể nhận thưởng.")
		return 0;
	end
	if not bConfirm then
		szMsg = string.format([[  Bang chủ đã đặt cổ tức cho tuần này là <color=green>d%%<color>. Bạn có thể nhận được trong tuần này là <color=green>d%%<color> bạc.
		Sau khi nhận, tài sản cá nhân sẽ giảm theo tương ứng.]], 
			nTakePercent, nTakeMoney);
		tbOpt = {
			{"Nhận thưởng", self.DlgTakeStock, self, 1},
			{"Kết thúc đối thoại"},
		}
	else
		if bConfirm and bConfirm == 1 then
			if me.GetBindMoney() + nTakeMoney > me.GetMaxCarryMoney() then
				Dialog:Say("Số ngân lượng mang theo bên người đã đạt tối đa.");
				return 0;
			end
			me.SetTask(self.TONG_TASK_GROUP, self.TONG_TAKE_STOCK_WEEKS, nCurWeek)
			return GCExcute{"Tong:TakeStock_GC", nTongId, nKinId, nMemberId};
		end
	end
	Dialog:Say(szMsg,tbOpt);
end

function Tong:DlgGreatBonus()	
	local pTong = KTong.GetTong(me.dwTongId);
	if not pTong then
		Dialog:Say("Bạn chưa gia nhập Bang hội");
		return 0;
	end
	Dialog:Say("Phần thưởng cho các thành viên là <color=green>"..pTong.GetWeekGreatBonus().."<color>", 
	{
		{"Nhận thưởng ưu tú", Tong.ReceiveGreatBonus, Tong},
		{"Đặt quỹ thưởng bang hội", Tong.AdjustGreatBonusPercent, Tong},
		{"Đóng"}		
	})
end

