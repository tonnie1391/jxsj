-------------------------------------------------------
-- 文件名　 : superbattle_npc_trader.lua
-- 创建者　 : zhangjinpin@kingsoft
-- 创建时间 : 2011-06-09 16:49:21
-- 文件描述 :
-------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Require("\\script\\globalserverbattle\\superbattle\\superbattle_def.lua");

local tbNpc = Npc:GetClass("superbattle_npc_trader");

function tbNpc:OnDialog()
	local szMsg = "Xin chào, mỗi trận chiến diễn ra, ngươi có thể đến nhận <color=yellow>2 rương<color> thuốc miễn phí và có thể mua những loại thuốc cao cấp hơn.";
	local tbOpt = 
	{
		{"<color=yellow>Nhận rương thuốc<color>", self.GetMedicine, self},
		{"Mua thuốc", self.OpenShop, self},
		{"Ta hiểu rồi"}
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GetMedicine()
	
	local nMedicine = SuperBattle:GetPlayerTypeData(me, "nMedicine");
	if nMedicine <= 0 then
		Dialog:Say("Rương thuốc miễn phí đã sử dụng hết.");
		return 0;
	end
	
	local szMsg = "Ngươi muốn chọn loại nào?";
	local tbOpt = {};
	for i, tbInfo in ipairs(SuperBattle.MEDICINE_ID) do
		table.insert(tbOpt, {tbInfo[1], self.DoGetMedicine, self, i});
	end
	tbOpt[#tbOpt + 1] = {"Ta hiểu rồi"};
	
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:DoGetMedicine(nType)
	
	local tbInfo = SuperBattle.MEDICINE_ID[nType];
	if not tbInfo then
		return 0;
	end
	
	local nNeed = 1;
	if me.CountFreeBagCell() < nNeed then
		Dialog:Say(string.format("Hành trang không đủ %s ô trống", nNeed));
		return 0;
	end
	
	me.AddItem(unpack(tbInfo[2]));
	SuperBattle:AddPlayerTypeDate(me, "nMedicine", -1);
end

function tbNpc:OpenShop()
	me.OpenShop(164,7);
end
