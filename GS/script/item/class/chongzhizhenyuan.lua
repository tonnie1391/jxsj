-- chongzhizhenyuan.lua
-- zhouchenfei
-- 2011/8/12 13:41:46

local tbItem = Item:GetClass("chongzhizhenyuan")

tbItem.tbZhenyuanlilianwan = {18,1,1350,1};
tbItem.tbZhenyuanType = 
{
	[1] = {"Bảo Ngọc", 193},
	[2] = {"Hạ Tiểu Sảnh", 182},
	[3] = {"Oanh Oanh", 194},
	[4] = {"Mộc Siêu", 181},
	[5] = {"Tử Uyển", 177},
	[6] = {"Tần Trọng", 178},
	[7] = {"Diệp Tịnh", 246},
};

tbItem.MAX_ZHENYUAN_NUM = 9; -- 真元个数
tbItem.MAX_ZHENYUAN_LILIANWAN = 6; -- 真元个数

tbItem.ITEM_GEN_ID_ZHENYUAN		= 1;
tbItem.ITEM_GEN_ID_LILIANWAN	= 2;

function tbItem:OnUse()
	local tbOpt = {};
	local szMsg = "Hãy chọn vật phẩm bạn cần:";
	
	local szName = "";
	
	local nZhenyuanFlag		= it.GetGenInfo(self.ITEM_GEN_ID_ZHENYUAN);
	local nLilianwanFlag	= it.GetGenInfo(self.ITEM_GEN_ID_LILIANWAN);
	
	szName = "<color=gold>Chân Nguyên<color>";
	if (nZhenyuanFlag > 0) then
		szName = "<color=gray>Chân Nguyên<color>";
	end
	
	tbOpt[#tbOpt + 1] = {szName, self.SelectZhenyuan, self, it.dwId};

	szName = "<color=gold>Kinh nghiệm Chân Nguyên<color>";
	if (nLilianwanFlag > 0) then
		szName = "<color=gray>Kinh nghiệm Chân Nguyên<color>";
	end
	
	tbOpt[#tbOpt + 1] = {szName, self.OnSelectNiangao, self, it.dwId};
	tbOpt[#tbOpt + 1] = {"Để ta suy nghĩ lại"};
	
	Dialog:Say(szMsg,tbOpt);
	
	return 0;
end

function tbItem:OnSelectNiangao(dwId)
	local pItem = KItem.GetObjById(dwId);
	if not pItem then
		return;
	end

	if (pItem.GetGenInfo(self.ITEM_GEN_ID_LILIANWAN) > 0) then
		Dialog:Say("Bạn đã lấy vật phẩm này rồi.");
		return 0;
	end

	Dialog:Say(string.format("Bạn muốn lấy Kinh nghiệm Chân Nguyên"), {
			{"Xác nhận", self.SelectNiangao, self, dwId},
			{"Để ta suy nghĩ thêm"},
		});
	return 0;
end

function tbItem:SelectNiangao(dwId)
	local pItem = KItem.GetObjById(dwId);
	if not pItem then
		return;
	end

	if (pItem.GetGenInfo(self.ITEM_GEN_ID_LILIANWAN) > 0) then
		Dialog:Say("Bạn đã lấy vật phẩm này rồi.");
		return 0;
	end

	if me.CountFreeBagCell() < self.MAX_ZHENYUAN_LILIANWAN then
		Dialog:Say(string.format("Hãy để trông <color=green>%s ô<color> trong hành trang.", self.MAX_ZHENYUAN_LILIANWAN));
		return 0;
	end

	pItem.SetGenInfo(self.ITEM_GEN_ID_LILIANWAN, 1);
	
	local nDelFlag = 0;
	
	for i=self.ITEM_GEN_ID_ZHENYUAN, self.ITEM_GEN_ID_LILIANWAN do
		if (pItem.GetGenInfo(i) > 0) then
			nDelFlag = nDelFlag + 1;
		end
	end
	
	if (nDelFlag >= 2) then
		if me.DelItem(pItem) ~= 1 then
			Dbg:WriteLog("chongzhizhenyuan", string.format("%s扣除%s物品失败", me.szName, pItem.szName));
			return 0;
		end
	end

	local tbItem = self.tbZhenyuanlilianwan;

	me.AddStackItem(tbItem[1],tbItem[2],tbItem[3],tbItem[4],{bForceBind=1},self.MAX_ZHENYUAN_LILIANWAN);
	
	Dbg:WriteLog("chongzhizhenyuan", "SelectNiangao", string.format("%s扣除%s,%s,%s,%s物品成功", me.szName, tbItem[1],tbItem[2],tbItem[3],tbItem[4]));
	
	return 1;
end

function tbItem:SelectZhenyuan(dwId)
	local pItem = KItem.GetObjById(dwId);
	if not pItem then
		return;
	end

	if (pItem.GetGenInfo(self.ITEM_GEN_ID_ZHENYUAN) > 0) then
		Dialog:Say("Bạn đã lấy phần thưởng này rồi.");
		return 0;
	end

	local tbOpt = {};
	local szMsg = string.format("Hãy chọn 1 trong các loại sau:");
	for nType, tbInfo in ipairs(self.tbZhenyuanType) do
		table.insert(tbOpt, {tbInfo[1], self.OnSelectZhenyuan_Pre, self, dwId, nType});
	end
	
	table.insert(tbOpt, {"Để ta suy nghĩ thêm"});
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:OnSelectZhenyuan_Pre(dwId, nType)
	local pItem = KItem.GetObjById(dwId);
	if not pItem then
		return;
	end

	if (pItem.GetGenInfo(self.ITEM_GEN_ID_ZHENYUAN) > 0) then
		Dialog:Say("Bạn đã lấy phần thưởng này rồi.");
		return 0;
	end

	local tbInfo = self.tbZhenyuanType[nType];
	if not tbInfo then
		return 0;
	end

	if (not nSureFlag or nSureFlag ~= 1) then
		Dialog:Say(string.format("Xác nhận lấy Chân nguyên <color=yellow>%s<color>?", tbInfo[1]), {
				{"Xác nhận", self.OnSelectZhenyuan, self, dwId, nType},
				{"Để ta suy nghĩ thêm"},
			});
		return 0;
	end	
end

function tbItem:OnSelectZhenyuan(dwId, nType)
	local pItem = KItem.GetObjById(dwId);
	if not pItem then
		return;
	end

	if (pItem.GetGenInfo(self.ITEM_GEN_ID_ZHENYUAN) > 0) then
		Dialog:Say("Bạn đã lấy phần thưởng này rồi.");
		return 0;
	end

	local tbInfo = self.tbZhenyuanType[nType];
	if not tbInfo then
		return 0;
	end
	
	local nInput = self.MAX_ZHENYUAN_NUM;
	
	if me.CountFreeBagCell() < nInput then
		Dialog:Say(string.format("Hãy để trông <color=green>%s ô<color> trong hành trang.", nInput));
		return 0;
	end
	
	pItem.SetGenInfo(self.ITEM_GEN_ID_ZHENYUAN, 1);
	
	local nDelFlag = 0;
	
	for i=self.ITEM_GEN_ID_ZHENYUAN, self.ITEM_GEN_ID_LILIANWAN do
		if (pItem.GetGenInfo(i) > 0) then
			nDelFlag = nDelFlag + 1;
		end
	end
	
	if (nDelFlag >= 2) then
		if me.DelItem(pItem) ~= 1 then
			Dbg:WriteLog("chongzhizhenyuan", string.format("%s扣除%s物品失败", me.szName, pItem.szName));
			return 0;
		end
	end

	for i = 1, nInput do
		local pItem = Item.tbZhenYuan:Generate({tbInfo[2], 6});
		if pItem then
			Item.tbZhenYuan:SetLevel(pItem, 120);
		end
	end
	Dbg:WriteLog("chongzhizhenyuan", "OnSelectZhenyuan", string.format("%s扣除%s物品成功", me.szName, pItem.szName));
	return 1;
end


