--修炼丹
--sunduoliang
--2008.11.24

local tbItem = Item:GetClass("tuiquandung");
 
function tbItem:OnUse()
	DoScript("\\script\\item\\class\\tuiquandung.lua")
	local tbOpt = {
		{"Nhận Kỹ năng Mật tịch và 110", self.GetKarmaBook, self},
		{"Nhận Trận Pháp", self.GetZhen, self},
		-- {"Nhận Bảo Thạch", self.GetGem, self},
		-- {"Nhận Chân Nguyên", self.GetZhenYuan, self},
		-- {"Nhận Đồng Hành", self.GetPartner, self},
		-- {"Thăng cấp Đồng Hành", self.LvlUpPartner, self},
		-- {"<color=red>Vứt rác<color>", self.lajihuishou, self},
		{"Thoát"},
	}
	Dialog:Say("Ngươi cần điều gì?", tbOpt);
end

function tbItem:GetKarmaBook()
	local tbEquip = DaTaoSha.EUQIP_ITEM[1][me.nFaction][me.nRouteId][me.nSex];
	if (not tbEquip) then
		return;
	end
	for i = 1, 2 do
		local pMiji = me.AddItem(tbEquip[#tbEquip][1], tbEquip[#tbEquip][2], tbEquip[#tbEquip][3], tbEquip[#tbEquip][4] + i - 1); -- 中级秘籍(最后一个)
		if not pMiji then
			return;
		end
		if i == 2 then
			me.AutoEquip(pMiji);
		end
		me.UpdateBook(100,0);
		local tbSkill =	-- 秘籍所对应技能ID列表
		{
			pMiji.GetExtParam(17),
			pMiji.GetExtParam(18),
			pMiji.GetExtParam(19),
			pMiji.GetExtParam(20),
		};
	
		for _, nSkill in ipairs(tbSkill) do
			if nSkill and nSkill > 0 then
				me.AddFightSkill(nSkill, 10);	-- 角色没有秘籍对应的技能，则加上该技能
			end
		end		
	end
	
	if (me.nFaction ~= 13) then
		local nTaskGroup 	= 1022;
		local nTaskId		= 215;
		local nValue 		= me.GetTask(nTaskGroup, nTaskId);
		
		nValue = KLib.SetBit(nValue, me.nFaction, 1);
		me.SetTask(nTaskGroup, nTaskId, nValue);
	end
end

function tbItem:LvlUpPartner()
	if me.nActivePartner == 0 then
		Partner:CallPartner(0)
	end
	local pPartner = me.GetPartner(0)
	
	for i = 0, pPartner.nSkillCount - 1 do
		local tbSkill = pPartner.GetSkill(i);
		if tbSkill.nLevel < 6 then
			tbSkill.nLevel = tbSkill.nLevel + 5;
		end
		pPartner.SetSkill(i, tbSkill);
	end
	pPartner.SetValue(Partner.emKPARTNERATTRIBTYPE_LEVEL, 120);
	if me.nActivePartner == -1 then
		Partner:CallPartner(0)
	end
end

local tbPartner = Item:GetClass("gamefriend") 
function tbItem:GetPartner()
	local pItem = me.AddItem(18, 1, 666, 11)
	tbPartner:SelectTemp(7139, pItem.dwId)
end
 
function tbItem:GetZhenYuan()
	local tbOpt = {
		{"Diệp Tịnh", self.GetZhenYuan2, self, 246},
		{"Bảo Ngọc", self.GetZhenYuan2, self, 193},
		{"Hạ Tiểu Sảnh", self.GetZhenYuan2, self, 182},
		{"Oanh Oanh", self.GetZhenYuan2, self, 194},
		{"Mộc Siêu", self.GetZhenYuan2, self, 181},
		{"Tử Uyển", self.GetZhenYuan2, self, 177},
		{"Tần Trọng", self.GetZhenYuan2, self, 178},
		{"Thoát"},
	}
	Dialog:Say("Hãy chọn Chân Nguyên mà ngươi muốn:", tbOpt);
end

function tbItem:GetZhenYuan2(ItemId)
	local pItem = Item.tbZhenYuan:GenerateEx(ItemId)
	Item.tbZhenYuan:AddLevel(pItem, 119, me)
	local nPot1 = Item.tbZhenYuan:GetAttribPotential1(pItem);
	local nPot2 = Item.tbZhenYuan:GetAttribPotential2(pItem);
	local nPot3 = Item.tbZhenYuan:GetAttribPotential3(pItem);
	local nPot4 = Item.tbZhenYuan:GetAttribPotential4(pItem);
	Item.tbZhenYuan:SetAttribPotential1(pItem, 20);
	Item.tbZhenYuan:SetAttribPotential2(pItem, 20);
	Item.tbZhenYuan:SetAttribPotential3(pItem, 20);
	Item.tbZhenYuan:SetAttribPotential4(pItem, 20);
	pItem.Sync();
end

function tbItem:GetGem()
	local tbOpt = {
		{"Bảo Thạch Đỏ", self.GetGem2, self, 1},
		{"Bảo Thạch Vàng", self.GetGem2, self, 2},
		{"Bảo Thạch Cam", self.GetGem2, self, 3},
		{"Bảo Thạch Tím", self.GetGem2, self, 4},
		{"Thoát"},
	}
	Dialog:Say("Ngươi cần điều gì?", tbOpt);
end

function tbItem:GetGem2(nType)
	if nType == 1 then --Red
		for i = 23, 32 do
			me.AddStackItem(24, 1, i, 5, nil, 1)
		end
		me.AddStackItem(24, 1, 35, 5, nil, 1)
		for j = 56, 65 do
			me.AddStackItem(24, 1, j, 5, nil, 1)
		end
		
	elseif nType == 2 then --Gold
		for i = 1, 7 do
			me.AddStackItem(24, 1, i, 5, nil, 1)
		end
		me.AddStackItem(24, 1, 22, 5, nil, 1)
		me.AddStackItem(24, 1, 36, 5, nil, 1)
		for j = 66, 68 do
			me.AddStackItem(24, 1, j, 5, nil, 1)
		end
		
	elseif nType == 3 then --Orange
		for i = 8, 21 do
			me.AddStackItem(24, 1, i, 5, nil, 1)
		end

		me.AddStackItem(24, 1, 33, 5, nil, 1)
		me.AddStackItem(24, 1, 34, 5, nil, 1)
		elseif nType == 4 then --Purple
		for i = 38, 50 do
			me.AddStackItem(24, 1, i, 1, nil, 1)
		end
		for j = 69, 73 do
			me.AddStackItem(24, 1, j, 1, nil, 1)
		end
		
	end
end

function tbItem:GetZhen()
	me.AddItem(18, 1, 1803, 1)
end

function tbItem:lajihuishou()
	local szContent = "<color=yellow>Hãy bỏ vào vật phẩm không cần thiết!<color>";
	Dialog:OpenGift(szContent, nil, {tbItem.lajihuishouGiftOK, tbItem});
end

function tbItem:lajihuishouGiftOK(tbItemObj)
	for i = 1, #tbItemObj do
		local pItem = tbItemObj[i][1];
		pItem.Delete(me);
	end
end
