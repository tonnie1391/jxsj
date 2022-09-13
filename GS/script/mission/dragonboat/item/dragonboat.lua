-- 文件名　：dragonboat.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-05-04 14:49:00
-- 描  述  ：龙舟

local tbItem = Item:GetClass("dragonboat");
local GEN_WEAR			= 1;
local GEN_SKILL_ATTACK1 = 2;
local GEN_SKILL_ATTACK2 = 3;
local GEN_SKILL_DEFEND1 = 4;

function tbItem:OnUse()
	if it.nLevel < 5 then
		local tbOpt = {
			{"Xác nhận", NewEPlatForm.ItemChangeOther, NewEPlatForm, it},
			{"Để ta suy nghĩ thêm"}}
		Dialog:Say(string.format("Vật phẩm <color=yellow>%s<color> là vật phẩm dùng cho thi đấu Gia tộc, bạn có thể sử dụng vật phẩm này để đổi vật phẩm khác. Chắc chắn chứ?",it.szName), tbOpt);
		return;
	elseif it.nLevel >= 5 then
		local tbOpt = {
			{"Cải tạo", Npc:GetClass("dragonboat_signup").ProductBoat, Npc:GetClass("dragonboat_signup")},
			{"Hoán đổi vật phẩm", NewEPlatForm.ItemChange, NewEPlatForm, it},
			{"Để ta suy nghĩ thêm"}}
		local nRet, szString = NewEPlatForm:CheckCanUpdate(it);
		if nRet == 1 then
			table.insert(tbOpt, 3, {"Nâng cấp <item=".. szString..">", NewEPlatForm.ItemUpdate, NewEPlatForm, it});
		end
		Dialog:Say(string.format("Vật phẩm <color=yellow>%s<color> có thể thực hiện một số thao tác sau:",it.szName), tbOpt);
		return;
	end
end

function tbItem:GetGenId(nSel, pItem)
	if not pItem then
		return 0;
	end
	local tbProp = Esport.DragonBoat.PRODUCT_BOAT[pItem.nLevel];
	
	local tbSkillAttack = {};
	for _, nGenId in ipairs(Esport.DragonBoat.GEN_SKILL_ATTACK) do
		table.insert(tbSkillAttack, {nGenId, pItem.GetGenInfo(nGenId, 0)})
	end

	local tbSkillDefend = {};
	for _, nGenId in ipairs(Esport.DragonBoat.GEN_SKILL_DEFEND) do
		table.insert(tbSkillDefend, {nGenId, pItem.GetGenInfo(nGenId, 0)})
	end
		
	if nSel == 1 then
		for i=1, tbProp[2] do
			if tbSkillAttack[i] and tbSkillAttack[i][2] <= 0 then
				return tbSkillAttack[i][1];
			end
		end
	elseif nSel == 2 then
		for i=1, tbProp[3] do
			if tbSkillDefend[i] and tbSkillDefend[i][2] <= 0 then
				return tbSkillDefend[i][1];
			end
		end
	end
	return 0;
end


function tbItem:GetTip()
	local szTip  = "";
	local tbProp = Esport.DragonBoat.PRODUCT_BOAT[it.nLevel];
	local nWear  = tbProp[1] - it.GetGenInfo(Esport.DragonBoat.GEN_WEAR, 0);
	local szWear = string.format("Độ bền: %s", nWear);
	if nWear >= 10 then
		szWear = string.format("\n<color=green>%s<color>", szWear);
	elseif nWear >= 5 then
		szWear = string.format("\n%s", szWear);
	else
		szWear = string.format("\n<color=red>%s<color>", szWear);
	end
	
	szTip = szTip .. szWear;
	szTip = szTip .. self:GetSkillTip(it);
	return szTip;
end

function tbItem:GetSkillTip(pItem)
	local tbProp = Esport.DragonBoat.PRODUCT_BOAT[pItem.nLevel];
	local nWear  = tbProp[1] - pItem.GetGenInfo(Esport.DragonBoat.GEN_WEAR, 0);
	
	local tbSkillAttack = {};
	for _, nGenId in ipairs(Esport.DragonBoat.GEN_SKILL_ATTACK) do
		table.insert(tbSkillAttack, pItem.GetGenInfo(nGenId, 0))
	end

	local tbSkillDefend = {};
	for _, nGenId in ipairs(Esport.DragonBoat.GEN_SKILL_DEFEND) do
		table.insert(tbSkillDefend, pItem.GetGenInfo(nGenId, 0))
	end		
	local szTip = "";
	for i=1, tbProp[2], 1 do
		if tbSkillAttack[i] > 0 then
			szTip = szTip .. string.format("\n<color=green>Cải tạo công kích: %s<color>", KFightSkill.GetSkillName(tbSkillAttack[i]));
		else
			szTip = szTip .. string.format("\n<color=gray>Cải tạo công kích: Chưa có<color>");
		end
	end
	
	for i=1, tbProp[3], 1 do
		if tbSkillDefend[i] > 0 then
			szTip = szTip .. string.format("\n<color=green>Cải tạo phòng thủ: %s<color>", KFightSkill.GetSkillName(tbSkillDefend[i]));
		else
			szTip = szTip .. string.format("\n<color=gray>Cải tạo phòng thủ: Chưa có<color>");
		end
	end	
	return szTip;
end

-- 用于竞技平台活动的物品检查函数，不同的活动类型，不同的物品可能需要不同的检查机制
function tbItem:ItemCheckFun(pItem)
	if (not pItem) then
		return 0, "Không tồn tại";
	end
	local nUseBoat = 0;
	local nGenId1 = self:GetGenId(1, pItem);
	local nGenId2 = self:GetGenId(2, pItem);
	if nGenId1 <= 0 and nGenId2 <= 0 then
		nUseBoat = 1;
	end
	if nUseBoat == 0 then
		return 0, "Thuyền rồng của bạn chưa được sửa chữa, Hãy cải tạo lại trước khi bắt đầu cuộc thi.";
	end			
	return 1;
end
