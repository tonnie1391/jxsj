--===================================================
-- 文件名　：seriespk.lua
-- 创建者　：sunduoliang
-- 创建时间：2012-06-21 15:15:15
-- 功能描述：pk连斩特效
--===================================================
if not MODULE_GAMESERVER then
	return 0;
end
SpecialEvent.tbMakeJinghuo = SpecialEvent.tbMakeJinghuo or {}; 
local tbMakeJinghuo = SpecialEvent.tbMakeJinghuo; 

tbMakeJinghuo.nTaskGroup 		= 2216;

tbMakeJinghuo.nMakeMaxNum		= 3;
tbMakeJinghuo.nUseMaxNum		= 30;

tbMakeJinghuo.nLeftTime 		= 50;
tbMakeJinghuo.nCountPerWeek		= 51;

tbMakeJinghuo.nUseItemDate		= 52;
tbMakeJinghuo.nUseItemCount		= 53;

tbMakeJinghuo.tbItem 			= {18, 1, 1910, 1};
tbMakeJinghuo.nCostPoint 		= 11000;
tbMakeJinghuo.nEarnPoint 		= 10000;

function c2s:ApplyOpenMaskJinghuo()
	tbMakeJinghuo:OnDialog()
end

function tbMakeJinghuo:OnDialog()
	local nCheckTotalBottle = tbMakeJinghuo:CountBottleAvailable()
	local nAvailableBottle = math.min(nCheckTotalBottle, tbMakeJinghuo.nMakeMaxNum - me.GetTask(self.nTaskGroup, self.nLeftTime));
	local szMsg = string.format([[Chế tạo [Bình Tinh Hoạt]:
	
	Hiệp khách đứng <color=yellow>Top 100 Uy danh<color> có thể tiêu hao <color=yellow>11000 tinh lực và hoạt lực<color> gia công 1 Bình Tinh Hoạt <color=red>(Không khóa, vĩnh viễn, chứa 10000 tinh lực và 10000 hoạt lực)<color>.
	
	<color=green>Bình Tinh Hoạt mỗi tuần gia công 1 lần, tối đa tích lũy %s lần.<color>
	
	Tinh lực còn: <color=yellow>%s điểm<color>
	Hoạt lực còn: <color=yellow>%s điểm<color>
	Bình Tinh Hoạt có thể chế tạo: <color=yellow>%s bình<color>
	Số lần đã chế tạo Bình Tinh Hoạt: <color=yellow>%s/%s<color>]],
	tbMakeJinghuo.nMakeMaxNum, me.dwCurMKP, me.dwCurGTP, nAvailableBottle, me.GetTask(self.nTaskGroup, self.nLeftTime), tbMakeJinghuo.nMakeMaxNum);
	local tbOpt = {
		{"Ta muốn chế tạo [Bình Tinh Hoạt]", self.OnMakeJingHuo, self},
		{"Để ta suy nghĩ đã"}
	}
	Dialog:Say(szMsg, tbOpt);
end

function tbMakeJinghuo:OnMakeJingHuo(bOK)
	local nRank = PlayerHonor:GetPlayerHonorRank(me.nId, PlayerHonor.HONOR_CLASS_WEIWANG, 0);
	if nRank <= 0 or 100 < nRank then
		Dialog:Say("Thứ hạng Uy danh không nằm trong <color=yellow>Top 100<color>!");
		return;
	end
	
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ chỗ trống!");
		return;
	end
	
	if me.GetTask(self.nTaskGroup, self.nLeftTime) >= tbMakeJinghuo.nMakeMaxNum then
		Dialog:Say("Tuần này đã hết lượt chế tạo!");
		return;
	end
	
	local nNowDate = Lib:GetLocalWeek(GetTime());
	if not bOK then
		local nAvailableBottle = self:CountBottleAvailable()
		if nAvailableBottle > 0 then
			if nNowDate - me.GetTask(self.nTaskGroup, self.nCountPerWeek) > 0 then
				me.SetTask(self.nTaskGroup, self.nLeftTime, 0)
			end
			self:OnMakeJingHuo(1)
			return;
		else
			Dialog:Say("Không đủ tinh lực và hoạt lực");
			return;
		end
	end
	
	me.AddItem(unpack(self.tbItem));
	me.ChangeCurGatherPoint(-self.nCostPoint);
	me.ChangeCurMakePoint(-self.nCostPoint);
	
	me.SetTask(self.nTaskGroup, self.nLeftTime, me.GetTask(self.nTaskGroup, self.nLeftTime) + 1);
	me.SetTask(self.nTaskGroup, self.nCountPerWeek, nNowDate);
end

function tbMakeJinghuo:CountBottleAvailable()
	local nCheckMaxMKP = math.floor(me.dwCurMKP/self.nCostPoint);
	local nCheckMaxGTP = math.floor(me.dwCurGTP/self.nCostPoint);
	return math.min(nCheckMaxMKP, nCheckMaxGTP);
end

local tbItem = Item:GetClass("MakeJinghuo"); 

function tbItem:OnUse() 
	local nFlag = Player:CheckTask(tbMakeJinghuo.nTaskGroup, tbMakeJinghuo.nUseItemDate, "%Y%m%d", tbMakeJinghuo.nUseItemCount, tbMakeJinghuo.nUseMaxNum); 
	if nFlag == 0 then 
		Dialog:Say("Mỗi ngày chỉ có thể sử dụng tối đa 30 bình, ngày mai hãy uống tiếp."); 
		return 0; 
	end
	
	me.ChangeCurMakePoint(tbMakeJinghuo.nEarnPoint); 
	me.ChangeCurGatherPoint(tbMakeJinghuo.nEarnPoint); 
	me.SetTask(tbMakeJinghuo.nTaskGroup, tbMakeJinghuo.nUseItemCount, me.GetTask(tbMakeJinghuo.nTaskGroup, tbMakeJinghuo.nUseItemCount) + 1);
	return 1; 
end 