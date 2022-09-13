
local tbNpc = Npc:GetClass("xunbaoren")

local tbShop = 
{
	{132},			-- 兑换物品
}

function tbNpc:OnDialog()
	Dialog:Say("  Nghe nói trong Tiêu Dao Cốc có một kho báu, ta muốn tới đó để khám phá nhưng chưa tìm được đồng hành, ta không được phép đi. Xem ra ngươi có khả năng phi thường, nếu có thể vào thung lũng để giúp ra tìm chúng, ta có một vài món đồ tốt, ngươi có thể lấy! Ngươi muốn không?\n    Vâng đúng! Ta nghe nói trong thung lũng có một bậc thầy chế tác đồ, nhưng ta không biết đo là ai... Ngươi hãy đi từ từ để tìm thấy ông ấy...",
		{
			{"Ta có món bảo vật quý này", Dialog.Gift, Dialog, "XoyoGame.tbGift"},
			{"Cho ta xem ngươi có món gì tốt", self.OpenShop, self},
			{"Nhận thuốc Tiêu Dao Cốc", SpecialEvent.tbMedicine_2012.GetMedicine, SpecialEvent.tbMedicine_2012},
			{"Xem xếp hạng", XoyoGame.WatchRecord, XoyoGame},
			{"Xem xếp hạng Gia tộc", XoyoGame.WatchKinRecord, XoyoGame},
			--{"Xem", XoyoGame.TestWatch, XoyoGame};
			{"Kết thúc đối thoại"},
		})
end

function tbNpc:OpenShop()
		me.OpenShop(132);
end
