-- 文件名　：frendbox.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-16 09:41:05
-- 描  述  ：抽奖奖励的同伴箱子

local tbItem = Item:GetClass("gamefriend")

tbItem.nSevenPartnerType = 17;

function tbItem:OnUse()
	if (Partner.bOpenPartner ~= 1) then
		Dialog:Say("Hệ thống đồng hành chưa mở, không thể sử dụng vật phẩm.");
		return 0;
	end	
	
	local szInfo = "Chọn đồng hành: ";
	if me.nLevel < 100 then
		me.Msg( "Cấp độ của bạn ít hơn 100 không thể sử dụng vật phẩm!");	
		return 0;
	end
	if me.nFaction == 0 then
		me.Msg( "Chưa gia nhập môn phái không thể sử dụng vật phẩm!");
		return 0;
	end
	if me.nPartnerCount >= me.nPartnerLimit then
		me.Msg("Số lượng đồng hành đã đủ!");	    	
		return 0;
	end
	
	local nTempId1 	= tonumber(it.GetExtParam(1));

	local nPartnerType = Partner:GetPartnerType(nTempId1);
	-- 如果是七技能同伴就要判断身上是否已经有了
	if (nPartnerType == self.nSevenPartnerType) then
		local nIsHaveSevenPartner, szMsg = self:IsHaveSevenPartner(me);
		if (1 == nIsHaveSevenPartner) then
			Dialog:Say(szMsg);
			return 0;
		end
	end

	local nTempId2	= tonumber(it.GetExtParam(2));

	local nPartnerType = Partner:GetPartnerType(nTempId2);
	-- 如果是七技能同伴就要判断身上是否已经有了
	if (nPartnerType == self.nSevenPartnerType) then
		local nIsHaveSevenPartner, szMsg = self:IsHaveSevenPartner(me);
		if (1 == nIsHaveSevenPartner) then
			Dialog:Say(szMsg);
			return 0;
		end
	end

	
	local tbOpt = {};
	if  nTempId1 ~= nTempId2 then
		tbOpt = {{"Đồng hành nữ", self.SelectTemp, self, nTempId1, it.dwId},
				{"Đồng hành nam", self.SelectTemp, self, nTempId2, it.dwId},
				{"Hủy bỏ"},
			};
	else
		tbOpt ={{"Chọn đồng hành", self.SelectTemp, self, nTempId1, it.dwId},
				{"Hủy bỏ"},
			};
	end
	Dialog:Say(szInfo,tbOpt);
	return 0;
end

function tbItem:IsHaveSevenPartner(pPlayer)
	for i = 1, pPlayer.nPartnerCount do
		local pPartner = pPlayer.GetPartner(i - 1);
		if (pPartner and pPartner.nSkillCount == 7) then
			return 1, "Ngươi đã có 1 đồng hành 7 kỹ năng rồi!";
		end
	end
	return 0;
end

function tbItem:SelectTemp(nNpcTempId,nItemId)
	local nPartnerType = Partner:GetPartnerType(nNpcTempId);
	-- 如果是七技能同伴就要判断身上是否已经有了
	if (nPartnerType == self.nSevenPartnerType) then
		local nIsHaveSevenPartner, szMsg = self:IsHaveSevenPartner(me);
		if (1 == nIsHaveSevenPartner) then
			Dialog:Say(szMsg);
			return 0;
		end
	end
	
	local szInfo = "Lựa chọn tiềm năng:";
	local	tbOpt = {{"Thân Pháp 50%, Ngoại Công 50%", self.SelectSeries, self, nNpcTempId, nItemId, 1},
			{"Ngoại Công 50%,Nội Công 50%", self.SelectSeries, self, nNpcTempId, nItemId, 2},
			{"Sức mạnh 30%, Thân Pháp 30%, Ngoại Công 40%", self.SelectSeries, self, nNpcTempId, nItemId, 3},
			{"Sức mạnh 30%, Thân Pháp 20%, Ngoại Công 50%", self.SelectSeries, self, nNpcTempId, nItemId, 4},
			{"Sức mạnh 40%, Thân Pháp 20%, Ngoại Công 40%", self.SelectSeries, self, nNpcTempId, nItemId, 5},
			{"Sức mạnh 40%, Thân Pháp 30%, Ngoại Công 30%", self.SelectSeries, self, nNpcTempId, nItemId, 6},
			{"Sức mạnh 40%, Thân Pháp 10%, Ngoại Công 50%", self.SelectSeries, self, nNpcTempId, nItemId, 7},
			{"Sức mạnh 40%, Thân Pháp 10%, Ngoại Công 10%, Nội Công 40%", self.SelectSeries, self, nNpcTempId, nItemId, 8},
			{"Sức mạnh 50%, Thân Pháp 20%, Ngoại Công 30%", self.SelectSeries, self, nNpcTempId, nItemId, 9},
			{"Hủy bỏ"},
		};
	Dialog:Say(szInfo,tbOpt);
	return 0;
end

function tbItem:SelectSeries(nNpcTempId, nItemId, nPotenTemplId)
	local szInfo = "Chọn Ngũ Hành: \n  Khuyến khích lựa chọn <color=yellow>cùng hệ phái Ngũ Hành<color>, nếu cùng Ngũ Hành các tiềm năng của đồng hành sẽ hỗ trợ tối đa.";
	local	tbOpt = {{"Hệ Kim", self.Select, self, nNpcTempId, nItemId, 1, nPotenTemplId},
			{"Hệ Mộc", self.Select, self, nNpcTempId, nItemId, 2, nPotenTemplId},
			{"Hệ Thủy", self.Select, self, nNpcTempId, nItemId, 3, nPotenTemplId},
			{"Hệ Hỏa", self.Select, self, nNpcTempId, nItemId, 4, nPotenTemplId},
			{"Hệ Thổ", self.Select, self, nNpcTempId, nItemId, 5, nPotenTemplId},			
			{"Hủy bỏ"},
		};
	Dialog:Say(szInfo,tbOpt);
	return 0;
end

function tbItem:Select(nNpcTempId, nItemId, nSeries, nPotenTemplId)	
	local pItem =  KItem.GetObjById(nItemId);
	if pItem then
		local nRes = Partner:AddPartner(me.nId, nNpcTempId, nSeries, nPotenTemplId);
		if nRes ~= 0 then			
			pItem.Delete(me);
			EventManager:WriteLog(string.format("[使用贴心同伴道具]获得一个模板Id为：%s 的同伴", nPotenTemplId), me);
			me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[使用贴心同伴道具]获得一个模板Id为：%s 的同伴", nPotenTemplId ));
		end
	end
end
