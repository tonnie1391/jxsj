-- 文件名　：repute_seller.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-09-07 15:26:46
-- 描述：统一的声望装备购买npc

---稀有装备购买npc
local tbXiyouEquipNpc = Npc:GetClass("xiyouequip_npc");

local tbXiyoEquipShopId = 
{
	[1] = 201,
	[2] = 202,
	[3] = 203,
	[4] = 204,
	[5] = 205,
	[6] = 206,
	[7] = 238,
};

function tbXiyouEquipNpc:OnDialog()
	local szMsg = "Ta ở đây bán trang bị hiếm. nếu muốn mua trang bị cấp thấp hơn, tôi có thể giới thiệu một vài người.\n<color=yellow>Vũ khí<color>: bán Vũ Khí Đặc Chế ở Lâm An Phủ\n<color=yellow>Áo<color>: chưởng môn các phái\n<color=yellow>Bội<color>: Quan Quân Nhu( nghĩa quân)\n<color=yellow>Lưng<color>: Mông Cổ-Tây Hạ chiêu mộ sứ\n<color=yellow>Tay<color>: Tiếp dẫn ải gia tộc\n<color=yellow>Liên<color>: hộ vệ Bạch Hổ Đường";
	local tbOpt = {};
	tbOpt[#tbOpt + 1]  = {"Mua vũ khí hiếm",self.OnBuyXiyouEquip,self,1,me.nId};
	tbOpt[#tbOpt + 1]  = {"Mua áo hiếm",self.OnBuyXiyouEquip,self,2,me.nId};
	tbOpt[#tbOpt + 1]  = {"Mua bội hiếm",self.OnBuyXiyouEquip,self,3,me.nId};
	tbOpt[#tbOpt + 1]  = {"Mua thắt lưng hiếm",self.OnBuyXiyouEquip,self,4,me.nId};
	tbOpt[#tbOpt + 1]  = {"Mua bao tay hiếm",self.OnBuyXiyouEquip,self,5,me.nId};
	tbOpt[#tbOpt + 1]  = {"Mua dây chuyền hiếm",self.OnBuyXiyouEquip,self,6,me.nId};
	tbOpt[#tbOpt + 1]  = {"Mua giày hiếm",self.OnBuyXiyouEquip,self,7,me.nId};
	tbOpt[#tbOpt + 1]  = {"Để ta suy nghĩ"};
	Dialog:Say(szMsg,tbOpt);
end

function tbXiyouEquipNpc:OnBuyXiyouEquip(nType,nId)
	local pPlayer = KPlayer.GetPlayerObjById(nId);
	if not pPlayer then
		return 0;
	end
	if not nType or not tbXiyoEquipShopId[nType] then
		return 0;
	end
	pPlayer.OpenShop(tbXiyoEquipShopId[nType],1);
end


----炼化图纸npc
local tbRefinePicNpc = Npc:GetClass("refinepic_npc");

local tbRefinePicShopId = 
{
	[1] = 207,
	[2] = 208,
	[3] = 209,
	[4] = 210,
	[5] = 197,
};

function tbRefinePicNpc:OnDialog()
	local szMsg = "Gặp lại thiếu hiệp đúng là có duyên! Ta có công thức chế tạo báu vật, thích thì lấy xem";
	local tbOpt = {};
	tbOpt[#tbOpt + 1]  = {"Mua đồ phổ luyện hóa bộ Tiêu Dao",self.OnBuyRefinePic,self,1,me.nId};
	tbOpt[#tbOpt + 1]  = {"Mua đồ phổ luyện hóa bộ Liên Đấu",self.OnBuyRefinePic,self,2,me.nId};
	tbOpt[#tbOpt + 1]  = {"Mua đồ phổ luyện hóa bộ Trục Lộc",self.OnBuyRefinePic,self,3,me.nId};
	tbOpt[#tbOpt + 1]  = {"Mua đồ phổ luyện hóa bộ Thủy Hoàng",self.OnBuyRefinePic,self,4,me.nId};
	tbOpt[#tbOpt + 1]  = {"Mua đồ phổ luyện hóa bộ Trung Hồn",self.OnBuyRefinePic,self,5,me.nId};
	tbOpt[#tbOpt + 1]  = {"Mua đồ phổ luyện hóa Vũ Khí Thanh Đồng",self.ChangeQingtongWeaponPic,self,me.nId};	
	tbOpt[#tbOpt + 1]  = {"Để ta suy nghĩ"};
	Dialog:Say(szMsg,tbOpt);
end

function tbRefinePicNpc:ChangeQingtongWeaponPic()

	local bGreenServer = KGblTask.SCGetDbTaskInt(DBTASK_TIMEFRAME_OPEN);
	local nType  = Ladder:GetType(0, 2, 1, 0) or 0;	-- 由于ladder的tbconfig没有gs副本，所有特殊处理，获取战斗力等级排行榜的type
	local tbInfo = GetHonorLadderInfoByRank(nType, 50);	-- 等级排行榜第50名
	local nLadderLevel = 0;
	if (tbInfo) then
		nLadderLevel = tbInfo.nHonor;
	end
	if Boss.Qinshihuang:_CheckState() ~= 1 then
		Dialog:Say("Rất tiếc,hệ thống Tần Lăng tạm thời đóng cửa,không thể mua đồ phổ luyện hóa Vũ Khí Thanh Đồng", {"Ta biết rồi"});
		return;
	end
	if bGreenServer == 1 then  --绿色服务器限制
		if nLadderLevel < 100 then
			Dialog:Say("Rất tiếc,hệ thống Tần Lăng chưa mở,không thể mua đồ phổ luyện hóa Vũ Khí Thanh Đồng", {"Ta biết rồi"});
			return;
		end
	end
	if TimeFrame:GetState("OpenBoss120") ~= 1 then
		Dialog:Say("Rất tiếc,hệ thống Tần Lăng chưa mở,không thể mua đồ phổ luyện hóa Vũ Khí Thanh Đồng", {"Ta biết rồi"});
		return;
	end
	local szMsg = "Sử dụng danh vọng hoặc Hòa Thị Bích để đổi vũ khí Thanh Đồng luyện hóa đồ";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] = {"Ta muốn đổi vũ khí Thanh Đồng luyện hóa đồ",Npc:GetClass("qinling_safenpc2_1").ChangeRefine,Npc:GetClass("qinling_safenpc2_1")};
	tbOpt[#tbOpt + 1] = {"Dùng danh vọng đổi vũ khí Thanh Đồng luyện hóa đồ",Npc:GetClass("qinling_safenpc2_1").OnChangeReputeToRefine,Npc:GetClass("qinling_safenpc2_1")};
	tbOpt[#tbOpt + 1] = {"Ta nghĩ lại đã"};
	Dialog:Say(szMsg,tbOpt);
	return 1;
end


function tbRefinePicNpc:OnBuyRefinePic(nType,nId)
	if not nType or not tbRefinePicShopId[nType] then
		return 0;
	end
	me.OpenShop(tbRefinePicShopId[nType],1);
end


----声望防具npc
local tbReputeAromrNpc = Npc:GetClass("shengwangaromr_npc");

local tbReputeAromrShopId = 
{
	[1] = 211,
	[2] = 212,
	[3] = 213,
	[4] = 214,
	[5] = 215,
};

function tbReputeAromrNpc:OnDialog()
	local szMsg = "Ta rất thích thích kết bạn. Câu thơ mà ta thích nhất chính là: khuyên bạn cạn thêm một chén rượu, tây xuất dương quan vô cố nhân";
	local tbOpt = {};
	tbOpt[#tbOpt + 1]  = {"Mua nón danh vọng lãnh thổ",self.OnBuyReputeAromr,self,1,me.nId};
	tbOpt[#tbOpt + 1]  = {"Mua áo danh vọng liên đấu",self.OnBuyReputeAromr,self,2,me.nId};
	tbOpt[#tbOpt + 1]  = {"Mua lưng danh vọng thịnh hạ 2008",self.OnBuyReputeAromr,self,3,me.nId};
	tbOpt[#tbOpt + 1]  = {"Mua tay danh vọng di tích Hàn Vũ",self.OnBuyReputeAromr,self,4,me.nId};
	tbOpt[#tbOpt + 1]  = {"Mua giày danh vọng đoàn viên dân tộc",self.OnBuyReputeAromr,self,5,me.nId};
	tbOpt[#tbOpt + 1]  = {"Để ta suy nghĩ"};
	Dialog:Say(szMsg,tbOpt);
end

function tbReputeAromrNpc:OnBuyReputeAromr(nType,nId)
	if not nType or not tbReputeAromrShopId[nType] then
		return 0;
	end
	me.OpenShop(tbReputeAromrShopId[nType],1);
end


----声望首饰npc
local tbReputeJewelryNpc = Npc:GetClass("shengwangjewelry_npc");

local tbReputeJewelryShopId = 
{
	[1] = 216,
	[2] = 217,
	[3] = 218,
	[4] = 219,
};

function tbReputeJewelryNpc:OnDialog()
	local szMsg = "Nam đeo ngọc bội, nữ đeo hương nang. Bổn tiệm Long Thần Kiếm có đợt hàng thủ công mỹ nghệ rất đẹp, mời quý khách ghé xem";
	local tbOpt = {};
	tbOpt[#tbOpt + 1]  = {"Mua liên danh vọng thịnh hạ 2010",self.OnBuyReputeJewelry,self,1,me.nId};
	tbOpt[#tbOpt + 1]  = {"Mua nhẫn danh vọng đại hội Võ Lâm",self.OnBuyReputeJewelry,self,2,me.nId};
	tbOpt[#tbOpt + 1]  = {"Mua Bội danh vọng liên đấu server",self.OnBuyReputeJewelry,self,3,me.nId};
	tbOpt[#tbOpt + 1]  = {"Mua Phù danh vọng chúc phúc",self.OnBuyReputeJewelry,self,4,me.nId};
	tbOpt[#tbOpt + 1]  = {"Để ta suy nghĩ"};
	Dialog:Say(szMsg,tbOpt);
end

function tbReputeJewelryNpc:OnBuyReputeJewelry(nType,nId)
	if not nType or not tbReputeJewelryShopId[nType] then
		return 0;
	end
	me.OpenShop(tbReputeJewelryShopId[nType],1);
end

----白银，黄金武器npc
local tbReputeWeaponNpc = Npc:GetClass("shengwangweapon_npc");

local tbReputeWeaponShopId = 
{
	[1] = 220,	
	[2] = 221,
	[3] = 222,
	[4] = 223,
	[5] = 224,
};

function tbReputeWeaponNpc:OnDialog()
	local bGreenServer = KGblTask.SCGetDbTaskInt(DBTASK_TIMEFRAME_OPEN);
	local nType  = Ladder:GetType(0, 2, 1, 0) or 0;	-- 由于ladder的tbconfig没有gs副本，所有特殊处理，获取战斗力等级排行榜的type
	local tbInfo = GetHonorLadderInfoByRank(nType, 50);	-- 等级排行榜第50名
	local nLadderLevel = 0;
	if (tbInfo) then
		nLadderLevel = tbInfo.nHonor;
	end
	if Boss.Qinshihuang:_CheckState() ~= 1 then
		Dialog:Say("Rất tiếc,hệ thống Tần Lăng tạm thời đóng cửa,không thể mua vũ khí 120", {"Ta biết rồi"});
		return;
	end
	if bGreenServer == 1 then  --绿色服务器限制
		if nLadderLevel < 100 then
			Dialog:Say("Rất tiếc,hệ thống Tần Lăng chưa mở cửa,không thể mua vũ khí 120", {"Ta biết rồi"});
			return;
		end
	end
	if TimeFrame:GetState("OpenBoss120") ~= 1 then
		Dialog:Say("Rất tiếc,hệ thống Tần Lăng chưa mở cửa,không thể mua vũ khí 120", {"Ta biết rồi"});
		return;
	end
	local szMsg = "Đêm trước ta có một giấc mơ, mơ thấy một cô gái tên là Bạch Miêu Miêu cho ta lượng vũ khí Long Thần Kiếm lớn, nhờ ta giao cho người có duyên. Sau khi thức dậy ta phát hiện khắp nhà toàn là vũ khí. Nghe nói toàn là thần binh thu thập từ các cổ mộ của các vị Hoàng đế, ngươi là người có duyên với Long Thần Kiếm ta đó sao?";
	local tbOpt = {};
	tbOpt[#tbOpt + 1] =	{"Mua vũ khí cấp 120<color=gold>(Kim)<color>", self.OnBuyReputeWeapon, self, 1, me.nId};
	tbOpt[#tbOpt + 1] =	{"Mua vũ khí cấp 120<color=gold>(Mộc)<color>", self.OnBuyReputeWeapon, self, 2, me.nId};
	tbOpt[#tbOpt + 1] =	{"Mua vũ khí cấp 120<color=gold>(Thủy)<color>", self.OnBuyReputeWeapon, self, 3, me.nId};
	tbOpt[#tbOpt + 1] =	{"Mua vũ khí cấp 120<color=gold>(Hỏa)<color>", self.OnBuyReputeWeapon, self, 4, me.nId};
	tbOpt[#tbOpt + 1] =	{"Mua vũ khí cấp 120<color=gold>(Thổ)<color>", self.OnBuyReputeWeapon, self, 5, me.nId};
	tbOpt[#tbOpt + 1] =	{"Để ta suy nghĩ"};
	Dialog:Say(szMsg,tbOpt);
end


function tbReputeWeaponNpc:OnBuyReputeWeapon(nType,nId)
	if not nType or not tbReputeWeaponShopId[nType] then
		return 0;
	end
	me.OpenShop(tbReputeWeaponShopId[nType],1);
end
