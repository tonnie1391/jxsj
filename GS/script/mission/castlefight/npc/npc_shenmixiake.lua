-- npc_shenmixiake.lua
-- huangxiaoming
-- 报名npc
-- 2011/01/10 09:36:08

Require("\\script\\mission\\castlefight\\castlefight_def.lua");

local tbNpc = Npc:GetClass("shenmixiake");

tbNpc.DEF_EVENT_TYPE = CastleFight.DEF_EVENT_TYPE;

function tbNpc:OnDialog()
	if GetMapType(me.nMapId) ~= "castlefight" then
		return 0;
	end
	local szMsg = "Sàng tiền minh nguyệt quang...\n<color=yellow>Tráng sĩ, ngươi cần gì ở ta?<color>"
	local tbOpt = 
	{
		{"Khôi phục đạo cụ", self.RestoreItem, self},
		{"Tiêu hủy đạo cụ", self.DeleteItem, self},
		{"Ta hiểu rồi"},	
	};
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:RestoreItem()
	if GetMapType(me.nMapId) ~= "castlefight" then
		return 0;
	end
	for _, tbInfo in ipairs(CastleFight.ITEM_LIST) do	
		local tbFind = me.FindItemInAllPosition(unpack(tbInfo));
		if not tbFind[1] then
			if me.CountFreeBagCell() < 1 then
				Dialog:Say("Hành trang không đủ chỗ trống.");
				return 0;
			end
			local pItem = me.AddItem(unpack(tbInfo));
			if pItem then
				pItem.Bind(1);
			end
		end
	end
	Dialog:Say("Đạo cụ trên người đã đầy đủ.");
end

function tbNpc:DeleteItem()
	if GetMapType(me.nMapId) ~= "castlefight" then
		return 0;
	end
	local szContent = "Hãy đặt các vật phẩm cần tiêu hủy <color=yellow>(Thức ăn, Thuốc, Huyền tinh cấp 5 trở xuống)<color>";
	Dialog:OpenGift(szContent, nil, {self.OnOpenGiftOk, self});
end

function tbNpc:OnOpenGiftOk(tbItemObj)
	for _, tbItem in pairs(tbItemObj) do -- tbItem[1].nLevel 
		if tbItem[1].szClass ~= "medicine" and tbItem[1].szClass ~= "xuanjing" and tbItem[1].szClass ~= "skillitem" then
			Dialog:Say("Sai vật phẩm, chỉ có thể đặt vào <color=yellow>Thức ăn, Thuốc, Huyền tinh cấp 5 trở xuống<color>");
			return 0;
		end
		if tbItem[1].szClass == "xuanjing" then
			if tbItem[1].nLevel > CastleFight.DELETE_XUANJING_LEVEL then
				Dialog:Say("Sai vật phẩm, chỉ có thể đặt vào <color=yellow>Thức ăn, Thuốc, Huyền tinh cấp 5 trở xuống<color>");
				return 0;
			end
		end
	end
	for _, tbItem in pairs(tbItemObj) do
		tbItem[1].Delete(me);
	end
	me.Msg("Tiêu hủy thành công.");
end