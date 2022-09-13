-- 文件名　：vippartner.lua
-- 创建者　：zounan
-- 创建时间：2010-01-13 10:23:55
-- 描  述  ：

local tbItem = Item:GetClass("gamefriend2");
tbItem.nPotenId = 241;
tbItem.nNpcTempId   = 6803;

function tbItem:OnUse()
	if (Partner.bOpenPartner ~= 1) then
		Dialog:Say("Tính năng đồng hành chưa mở, không thể sử dụng.");
		return 0;
	end
	
	--先检测100级 再查看是否开服150
	if me.nLevel < 100 then
		me.Msg("Cấp của bạn không đủ 100 hãy đạt đủ cấp rồi thử lại.");
		return;
	end		
	
	if TimeFrame:GetStateGS("OpenLevel150") ~= 1 then
		me.Msg("Chưa mở cấp 150");
		return;
	end
	
	if me.nFaction == 0 then
		me.Msg("Bạn chưa gia nhập môn phái không thể có đồng hành.");
		return;
	end	
	
	if me.nPartnerCount >= me.nPartnerLimit then
		me.Msg("Số lượng đồng hành đã đủ.");	    	
		return 0;
	end		
	
	local szInfo = "Lựa chọn loại đồng hành bạn muốn:";
	local	tbOpt = {
			{"Thân pháp 50%，Ngoại công 50%", 		 self.SelectSeries, self, self.nNpcTempId, it.dwId, 1},
			{"Ngoại công 50%，Nội công 50%",			 self.SelectSeries, self, self.nNpcTempId, it.dwId, 2},
			{"Sức mạnh 30%，Thân pháp 30%，Ngoại công 40%", self.SelectSeries, self, self.nNpcTempId, it.dwId, 3},
			{"Sức mạnh 30%，Thân pháp 20%，Ngoại công 50%", self.SelectSeries, self, self.nNpcTempId, it.dwId, 4},
			{"Sức mạnh 40%，Thân pháp 20%，Ngoại công 40%", self.SelectSeries, self, self.nNpcTempId, it.dwId, 5},
			{"Sức mạnh 40%，Thân pháp 30%，Ngoại công 30%", self.SelectSeries, self, self.nNpcTempId, it.dwId, 6},
			{"Sức mạnh 40%，Thân pháp 10%，Ngoại công 50%", self.SelectSeries, self, self.nNpcTempId, it.dwId, 7},
			{"Sức mạnh 40%，Thân pháp 10%，Ngoại công 10%，Nội công 40%", self.SelectSeries, self, self.nNpcTempId, it.dwId, 8},
			{"Sức mạnh 50%，Thân pháp 20%，Ngoại công 30%", self.SelectSeries, self, self.nNpcTempId, it.dwId, 9},
			{"Kết thúc"},
		};
	Dialog:Say(szInfo,tbOpt);	
	return 0;
end

function tbItem:SelectSeries(nNpcTempId, nItemId, nPotenTemplId)
	local szInfo = "Lựa chọn các giá trị: \n  Bạn có thể lựa chọn bạn đồng hành theo <color=yellow>Ngũ hành<color>";
	local	tbOpt = {
			{"Kim", self.Select, self, nNpcTempId, nItemId, 1, nPotenTemplId},
			{"Mộc", self.Select, self, nNpcTempId, nItemId, 2, nPotenTemplId},
			{"Thủy", self.Select, self, nNpcTempId, nItemId, 3, nPotenTemplId},
			{"Hỏa", self.Select, self, nNpcTempId, nItemId, 4, nPotenTemplId},
			{"Thổ", self.Select, self, nNpcTempId, nItemId, 5, nPotenTemplId},			
			{"Kết thúc"},
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
			EventManager:WriteLog(string.format("[Sử dụng đạo cụ đồng hành] truy cập ID là：%s bạn đồng hành", nPotenTemplId), me);
			me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("[Sử dụng đạo cụ đồng hành] truy cập ID là：%s bạn đồng hành", nPotenTemplId ));
		end
	end
end
