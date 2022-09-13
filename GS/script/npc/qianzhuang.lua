
local tbNpc = Npc:GetClass("qianzhuang");


function tbNpc:OnDialog()
	if me.IsAccountLock() ~= 0 then
		Dialog:Say("Tài khoản bị khóa, vui lòng mở khóa tài khoản.");
		Account:OpenLockWindow(me);
		return;
	end
	local tbOpt = {
			{"Cửa Hàng Hồn Thạch", self.OnOpenShop, self, me},
			{"Trang Bị Đổi Hồn Thạch", Dialog.Gift, Dialog, "Item.ChangeGift"},
			{"Phi Phong Đổi Hồn Thạch", self.SaleMantle, self},		
			{"Kết thúc đối thoại"},
		};
	if IVER_g_nSdoVersion == 0 then
		table.insert(tbOpt, 1, {"Mở Tiền Trang", self.OpenBank, self});
	end
	if Task.TaskExp.Open == 1 then
		table.insert(tbOpt, 1,{"<color=yellow>Kênh phân phối<color>", Task.TaskExp.OnDialog, Task.TaskExp, me});
	end
	Dialog:Say(me.szName.."，ngươi muốn mua gì nào ?",tbOpt);
end

function tbNpc:SaleMantle()
	Shop.MantleGift:OnOpen();
end


function tbNpc:OpenBank()
	if (Bank.nBankState == 0) then
		me.Msg("Không thể mở tiền trang.");
		return ;
	end
	me.CallClientScript({"UiManager:OpenWindow", "UI_BANK"});
end

function tbNpc:OnOpenShop(pPlayer)
	local nSeries = pPlayer.nSeries;
	if (nSeries == 0) then
		Dialog:Say("Bạn hãy gia nhập phái");
		return;
	end
	
	if (1 == nSeries) then
		pPlayer.OpenShop(140, 3);
	elseif (2 == nSeries) then
		pPlayer.OpenShop(141, 3);
	elseif (3 == nSeries) then
		pPlayer.OpenShop(142, 3);
	elseif (4 == nSeries) then
		pPlayer.OpenShop(143, 3);
	elseif (5 == nSeries) then
		pPlayer.OpenShop(144, 3);
	else
		Dbg:WriteLogEx(Dbg.LOG_INFO, "Npc qianzhuang", pPlayer.szName, "There is no Series", nSeries);
	end
end
