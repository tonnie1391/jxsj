-------------------------------------------------------------------
--File: 	yijunjunxuguan.lua
--Author: 	sunduoliang
--Date: 	2008-3-14
--Describe:	义军军需官
-------------------------------------------------------------------



local tbjunxuguan = Npc:GetClass("yijunjunxuguan");

tbjunxuguan.tbShopID =
{
	[Env.FACTION_ID_SHAOLIN]	= 37, -- 少林
	[Env.FACTION_ID_TIANWANG]	= 38, --天王掌门
	[Env.FACTION_ID_TANGMEN]	= 39, --唐门掌门
	[Env.FACTION_ID_WUDU]		= 41, --五毒掌门
	[Env.FACTION_ID_EMEI]		= 43, --峨嵋掌门
	[Env.FACTION_ID_CUIYAN]		= 44, --翠烟掌门
	[Env.FACTION_ID_GAIBANG]	= 46, --丐帮掌门
	[Env.FACTION_ID_TIANREN]	= 45, --天忍掌门
	[Env.FACTION_ID_WUDANG]		= 47, --武当掌门
	[Env.FACTION_ID_KUNLUN]		 = 48, --昆仑掌门
	[Env.FACTION_ID_MINGJIAO]	 = 40, --明教掌门
	[Env.FACTION_ID_DALIDUANSHI] = 42, --大理段氏掌门
	[Env.FACTION_ID_GUMU]		= 291,
}

function tbjunxuguan:OnDialog()
	local tbOpt = 
	{
		{"Tiệm danh vọng nghĩa quân", self.OpenShop, self},
		{"[Bí cảnh] Vào bí cảnh", Task.FourfoldMap.OnDialog, Task.FourfoldMap},
		{"[Bí cảnh] Bí cảnh", Task.FourfoldMap.OnAbout, Task.FourfoldMap},
	}
	
	if TreasureMap2.IS_OPEN   == 1 then
		table.insert(tbOpt,{"[Tàng Bảo Đồ] Mở phó bản", TreasureMap2.OnDialog, TreasureMap2});
		if TreasureMap2:CanAddLingpai() == 1 then			
			table.insert(tbOpt,{"[Tàng Bảo Đồ] Nhận lệnh bài", TreasureMap2.OnLingpaiDialog, TreasureMap2});
		end
		table.insert(tbOpt,{"[Đánh giá] Vào Đắc Duyệt Phường", FightAfter.EnterRoomForMeReady, FightAfter});
	end
	if CrossTimeRoom:GetCrossTimeRoomOpenState() == 1 then
		table.insert(tbOpt,{"<color=yellow>Lãnh lệnh bài phó bản cao cấp<color>",self.OnGetMissionItem,self});
	end
	if (Task.IVER_nCloseExchangeNoemal == 0) then
		table.insert(tbOpt, 4, {"Tôi muốn trao đổi", self.ApplyEchangeYinPia, self, me.nId});
	end
	table.insert(tbOpt,{"Kết thúc đối thoại"});
	Dialog:Say("Điểm danh vọng nghĩa quân khi đạt đến trình độ nhất định, được mua trang bị nghĩa quân chỗ ta.",tbOpt);
end

function tbjunxuguan:OpenShop()
		local nFaction = me.nFaction;
		if nFaction <= 0 or me.GetCamp() == 0 then
			Dialog:Say("Người chưa gia nhập môn phái không thể mua trang bi.");
			return 0;
		end
		me.OpenShop(self.tbShopID[nFaction], 1, 100, me.nSeries) --使用声望购买
end

function tbjunxuguan:OnGetMissionItem()
	local szMsg = "Ngươi muốn nhận lệnh bài nào?";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"Lệnh bài Thời Quang Điện",CrossTimeRoom.GiveCrossTimeRoomItem,CrossTimeRoom,me.nId};
	tbOpt[#tbOpt + 1] = {"Lệnh bài Thần Trùng Trấn",ChenChongZhen.GiveChenChongZhenItem,ChenChongZhen};
	tbOpt[#tbOpt + 1] = {"Ta chưa muốn nhận"};
	Dialog:Say(szMsg,tbOpt);
end