Require("\\script\\task\\merchant\\merchant_define.lua")

local MerchantNpc = {};

Merchant.Npc = MerchantNpc;
local tbNpc = Npc:GetClass("merchant");
function tbNpc:OnDialog()
	local tbOpt = {
		{"Giới thiệu nhiệm vụ", Merchant.Npc.About, Merchant.Npc},
		{"Nhận lại thư thương hội", Merchant.Npc.GetDervielItem, Merchant.Npc},
		{"Nhận hộp lưu trữ", Merchant.Npc.GetMerchantBox, Merchant.Npc},
		{"Đổi bạc khóa", Shop.SellItem.OnOpenSell, Shop.SellItem},
		-- {"Hủy bỏ nhiệm vụ hiện tại", Merchant.Npc.CancelTask, Merchant.Npc},
		{"Kết thúc đối thoại"},
	}
	local szMsg =  [[Chủ thương hội: Hoàn thành 40 bước để nhận phần thưởng phong phú.
	Cần đáp ứng những điều kiện sau: <color=yellow>
		1. Đẳng cấp đạt 60.
		2. Uy danh giang hồ đạt 50.
		3. Mỗi tuần nhận nhiệm vụ 1 lần.
		<color>]]
	Dialog:Say(szMsg, tbOpt);
end

function MerchantNpc:GetMerchantBox()
	local tbFind1 = me.FindItemInBags(unpack(Merchant.MERCHANT_BOX_ITEM));
	local tbFind2 = me.FindItemInRepository(unpack(Merchant.MERCHANT_BOX_ITEM));
	if #tbFind1 > 0 or #tbFind2 > 0 then
		Dialog:Say("Ngươi đã có hộp lưu trữ rồi, ngươi hãy tìm lại lần nữa");
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ chỗ trống.")
		return 0;
	end
	me.AddItem(unpack(Merchant.MERCHANT_BOX_ITEM));
	Dialog:Say("Nhận hộp lưu trữ thành công");
end

function MerchantNpc:GetDervielItem()
	
	if Merchant:GetTask(Merchant.TASK_OPEN) == 1 then
		Dialog:Say("Không cần Thư Thương Hội");
		return 0;
	end
	
	if Merchant:GetTask(Merchant.TASK_TYPE) ~= Merchant.TYPE_DELIVERITEM and Merchant:GetTask(Merchant.TASK_TYPE) ~= Merchant.TYPE_DELIVERITEM_NEW then
		Dialog:Say("Không cần Thư Thương Hội");
		return 0;
	end
	
	local tbFind1 = me.FindItemInBags(unpack(Merchant.DERIVEL_ITEM));
	local tbFind2 = me.FindItemInRepository(unpack(Merchant.DERIVEL_ITEM));
	if #tbFind1 > 0 or #tbFind2 > 0 then
		Dialog:Say("Ngươi đã nhận được Thư Thương Hội")
		return 0;
	end
	if me.CountFreeBagCell() < 1 then
		Dialog:Say("Hành trang không đủ chỗ trống.")
		return 0;
	end	
	me.AddItem(unpack(Merchant.DERIVEL_ITEM));
end

function MerchantNpc:CancelTask()
	Task:CloseTask(Merchant.TASKDATA_ID, "giveup");
	Merchant:SetTask(Merchant.TASK_OPEN, 0);
	Merchant:SetTask(Merchant.TASK_STEP_COUNT, 0);
	Merchant:SetTask(Merchant.TASK_TYPE, 0);
	Merchant:SetTask(Merchant.TASK_STEP, 0);
	Merchant:SetTask(Merchant.TASK_LEVEL, 0);
	Merchant:SetTask(Merchant.TASK_NOWTASK, 0);	
end

function MerchantNpc:About()
	local szMsg = [[Giúp Chủ thương hội hoàn thành 40 nhiệm vụ để nhận phần thưởng phong phú.
	Để nhận nhiệm vụ phải đáp ứng điều kiện: <color=yellow>
		1. Đẳng cấp đạt 60.
		2. Uy danh giang hồ đạt 50.
		3. Mỗi tuần chỉ nhận nhiệm vụ 1 lần.
		<color>
	Các nhiệm vụ gồm có: <color=yellow>
		1. Gửi thư: cho người được chỉ định.
		2. Tìm báu vật: mà chủ Thương hội chỉ định.
		3. Thu thập: vật phẩm ở nơi có quái vật canh giữ.
		<color>]]
	Dialog:Say(szMsg);
end

