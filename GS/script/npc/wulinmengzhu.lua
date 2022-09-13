-------------------------------------------------------------------
--File: wulinmengzhu.lua
--Author: luobaohang
--Date: 2007-9-19 16:36
--Describe: 武林盟主
-------------------------------------------------------------------

--	武林盟主;	
local tbWuLinMengZhu = Npc:GetClass("wulinmengzhu");

tbWuLinMengZhu.tbYanXiaoLou = {18,1,666,11};
tbWuLinMengZhu.nChangePoint = 8000000;
tbWuLinMengZhu.nMinHonorLevel = 9;
tbWuLinMengZhu.nOpenChangeDay = 150;

function tbWuLinMengZhu:OnDialog()
	
	local szMsg = "Chỉ cần độ thân mật đạt đến 100, đẳng cấp đạt đến 30 thì đến chỗ ta lập gia tộc. Trên 3 gia tộc thì đến chỗ ta lập bang hội.";
	if (EventManager.IVER_bOpenTiFu == 1) then
		szMsg = "Đẳng cấp đạt đến 30 thì đến chỗ ta lập gia tộc. Trên 3 gia tộc thì đến chỗ ta lập bang hội.";
	end

	local nOpenServerTime = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	local nServerDay = Lib:GetLocalDay(nOpenServerTime);
	local nNowDay = Lib:GetLocalDay(GetTime());
	
	local tbOpt = {
			{"Lập gia tộc", Kin.DlgCreateKin, Kin},
			{"Lập bang hội", Tong.DlgCreateTong, Tong},
			{"Đổi phe gia tộc", Kin.DlgChangeCamp, Kin},
			{"Đổi phe bang hội", Tong.DlgChangeCamp, Tong},
			{"Nhận Lệnh Bài Gia Tộc", Kin.DlgKinExp, Kin},
			{"Nhận lợi tức bang hội", Tong.DlgTakeStock, Tong},
			{"Nhận thưởng ưu tú bang", Tong.DlgGreatBonus, Tong},
			{"Ta chỉ xem thôi"}		
		};
	-- if ((nNowDay - nServerDay) >= self.nOpenChangeDay) then
		-- table.insert(tbOpt, 1, 	{"<color=yellow>兑换燕小楼（七技能同伴）<color>", self.OnChangeYanXiaoLou, self});
	-- end
	
	Dialog:Say(szMsg, tbOpt)
end

function tbWuLinMengZhu:NoAccept()
	Dialog:Say("Tạm không thụ lý việc này, xin trở lại sau.")
end

function tbWuLinMengZhu:OnChangeYanXiaoLou()
	local nFlag, szMsg = self:IsCanChangeYanXiaoLou();
	if (1 ~= nFlag) then
		Dialog:Say(szMsg);
		return 0;
	end
	local nPoint = Spreader:GetConsumeMoney();
	Dialog:Say(string.format("Tích lũy tiêu hao Kỳ Trân Các hiện tại là <color=yellow>%s<color>, muốn dùng <color=yellow>640 vạn<color> điểm tích lũy đổi <color=yellow>1 Yến Tiểu Lâu (Đồng hành 7 kỹ năng)<color>?\n\n<color=red>Chú ý: Mỗi nhân vật chỉ được có 1 Đồng hành 7 kỹ năng!<color>", nPoint), {
			{"Đổi", self.OnSureChange, self},
			{"Để ta suy nghĩ đã"},
		});
	
end

function tbWuLinMengZhu:IsCanChangeYanXiaoLou()
	local nPoint = Spreader:GetConsumeMoney();
	local nOpenServerTime = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	local nServerDay = Lib:GetLocalDay(nOpenServerTime);
	local nNowDay = Lib:GetLocalDay(GetTime());
	
	if ((nNowDay - nServerDay) < self.nOpenChangeDay) then
		return 0, string.format(string.format("Sau khi mở server <color=yellow>%s ngày<color> mở hệ thống tích lũy tiêu hao Kỳ Trân Các đổi Yến Tiểu Lâu.", self.nOpenChangeDay));
	end
	
	if (nPoint < self.nChangePoint) then
		return 0, string.format("您当前奇珍阁消耗积分为<color=yellow>%s分<color>，不足<color=yellow>800万分<color>，无法兑换", nPoint);
	end
	
	local nHonorLevel = me.GetHonorLevel();
	if (nHonorLevel < self.nMinHonorLevel) then
		return 0, string.format("兑换燕小楼需要<color=yellow>财富荣誉、武林荣誉、领袖荣誉<color>其中一种的等级达到<color=yellow>%s级<color>才能兑换！", self.nMinHonorLevel);
	end

	local nIsHaveSevenPartner, szMsg = self:IsHaveSevenPartner(me);
	if (1 == nIsHaveSevenPartner) then
		return 0, szMsg;
	end

	if (1 > me.CountFreeBagCell()) then
		return 0, string.format("您的背包剩余空间不足<color=yellow>1<color>格，请整理后再来领取！");
	end
	return 1;
end

function tbWuLinMengZhu:OnSureChange()
	local nFlag, szMsg = self:IsCanChangeYanXiaoLou();
	if (1 ~= nFlag) then
		Dialog:Say(szMsg);
		return 0;
	end
	
	Spreader:DecConsume(self.nChangePoint);
	local pItem = me.AddItem(unpack(self.tbYanXiaoLou));
	if (not pItem) then
		Dbg:WriteLog("changeyanxiaolou", string.format("Trừ %s điểm tích lũy, đổi %s, tăng Yến Tiểu Lâu thất bại", self.nChangePoint, me.szName));
		return 0;
	end
	
	pItem.Bind(1);
	pItem.Sync();
	Dialog:Say("Chúc mừng nhận được Yến Tiểu Lâu!");
	Dbg:WriteLog("changeyanxiaolou", string.format("Trừ %s điểm tích lũy, đổi %s, tăng Yến Tiểu Lâu thành công", self.nChangePoint, me.szName));
	return 0;
end

function tbWuLinMengZhu:IsHaveSevenPartner(pPlayer)
	for i = 1, pPlayer.nPartnerCount do
		local pPartner = pPlayer.GetPartner(i - 1);
		if (pPartner and pPartner.nSkillCount == 7) then
			return 1, "Mỗi nhân vật chỉ được có <color>1 Đồng hành 7 kỹ năng<color>, không thể đổi!";
		end
	end
	
	local tbResult = me.FindItemInAllPosition(unpack(self.tbYanXiaoLou));
	if (#tbResult > 0) then
		return 1, "Trong túi hoặc kho đã có <color=yellow>1 Yến Tiểu Lâu (Đồng hành 7 kỹ năng)<color>, không được đổi, <color=red>mỗi nhân vật chỉ được có 1 Đồng hành 7 kỹ năng<color>!";
	end
	return 0;
end

