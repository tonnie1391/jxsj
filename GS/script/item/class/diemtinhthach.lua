
local tbItem = Item:GetClass("diemtinhthach");
Item.c2sFun = Item.c2sFun or {};

tbItem.tbOpt = {
	[99] = {"Trống trơn",	"white"},
	[1]  = {"Hiện 1",	"gold"},
	[3]  = {"Hiện 2",	"gold"},
	[5]  = {"Hiện 3",	"gold"},
	[7]  = {"Ẩn 1",		"purple"},
	[9]  = {"Ẩn 2",		"purple"},
	[11] = {"Ẩn 3",		"purple"},
}

tbItem.tbOptPlace = {
	["steallife_p"] = {{1, 2}, "Chỉ khảm trên Vũ khí."},							-- Hút sinh
	["stealmana_p"] = {{1, 2}, "Chỉ khảm trên Vũ khí."},							-- Hút nội
	---------------------
	["attackspeed_v"] = {{1, 2}, "Chỉ khảm trên Vũ khí."},							-- Tốc đánh ngoại
	["castspeed_v"] = {{1, 2}, "Chỉ khảm trên Vũ khí."},							-- Tốc đánh nội
	---------------------
	["addphysicsdamage_p"] = {{1, 2}, "Chỉ khảm trên Vũ khí."},						-- Phần trăm ngoại
	["addphysicsmagic_p"] = {{1, 2}, "Chỉ khảm trên Vũ khí."},						-- Phần trăm nội
	---------------------
	["addphysicsmagic_v"] = {{1, 2}, "Chỉ khảm trên Vũ khí."},						-- Vật công nội
	["addpoisonmagic_v"] = {{1, 2}, "Chỉ khảm trên Vũ khí."},						-- Độc công nội
	["addcoldmagic_v"] = {{1, 2}, "Chỉ khảm trên Vũ khí."},							-- Băng công nội
	["addfiremagic_v"] = {{1, 2}, "Chỉ khảm trên Vũ khí."},							-- Hỏa công nội
	["addlightingmagic_v"] = {{1, 2}, "Chỉ khảm trên Vũ khí."},						-- Thổ công nội
	---------------------
	["addphysicsdamage_v"] = {{1, 2}, "Chỉ khảm trên Vũ khí."},						-- Vật công nội
	["addpoisondamage_v"] = {{1, 2}, "Chỉ khảm trên Vũ khí."},						-- Độc công nội
	["addcolddamage_v"] = {{1, 2}, "Chỉ khảm trên Vũ khí."},						-- Băng công nội
	["addfiredamage_v"] = {{1, 2}, "Chỉ khảm trên Vũ khí."},						-- Hỏa công nội
	["addlightingdamage_v"] = {{1, 2}, "Chỉ khảm trên Vũ khí."},					-- Thổ công nội
	---------------------
	["damage_physics_receive_p"] = {{3,7,8,9,10}, "Chỉ khảm trên Phòng cụ."},		-- Vật công phải chịu
	["damage_poison_receive_p"] = {{3,7,8,9,10}, "Chỉ khảm trên Phòng cụ."},		-- Độc công phải chịu
	["damage_cold_receive_p"] = {{3,7,8,9,10}, "Chỉ khảm trên Phòng cụ."},			-- Băng công phải chịu
	["damage_fire_receive_p"] = {{3,7,8,9,10}, "Chỉ khảm trên Phòng cụ."},			-- Hỏa công phải chịu
	["damage_light_receive_p"] = {{3,7,8,9,10}, "Chỉ khảm trên Phòng cụ."},			-- Thổ công phải chịu
	---------------------
	["meleedamagereturn_p"] = {{3}, "Chỉ khảm trên Y phục."},						-- Phản đòn cận chiến
	["rangedamagereturn_p"] = {{3}, "Chỉ khảm trên Y phục."},						-- Phản đòn tầm xa
	["poisondamagereturn_p"] = {{3}, "Chỉ khảm trên Y phục."},						-- Phản đòn sát thương độc
	["damage_return_receive_p"] = {{3}, "Chỉ khảm trên Y phục."},					-- Kháng phản đòn
	---------------------
	["damage_all_resist"] = {{6}, "Chỉ khảm trên Hộ Thân Phù."},					-- Kháng tất cả
	---------------------
	["fastwalkrun_p"] = {{7}, "Chỉ khảm trên Giày."},								-- Tốc độ di chuyển
	---------------------
	["strength_v"] = {{3,7,8,9,10}, "Chỉ khảm trên Phòng cụ."},						-- Sức mạnh
	["dexterity_v"] = {{3,7,8,9,10}, "Chỉ khảm trên Phòng cụ."},					-- Thân pháp
	["vitality_v"] = {{3,7,8,9,10}, "Chỉ khảm trên Phòng cụ."},						-- Ngoại
	["energy_v"] = {{3,7,8,9,10}, "Chỉ khảm trên Phòng cụ."},						-- Nội
	---------------------
	["lucky_v"] = {{4,5,6,11}, "Chỉ khảm trên Trang sức."},							-- May mắn
	["deadlystrikeenhance_r"] = {{4,5,6,11}, "Chỉ khảm trên Trang sức."},			-- Chí mạng
	["deadlystrikedamageenhance_p"] = {{4,5,6,11}, "Chỉ khảm trên Trang sức."},		-- ST Chí mạng
	["defencedeadlystrikedamagetrim"] = {{4,5,6,11}, "Chỉ khảm trên Trang sức."},	-- Chịu ST Chí mạng
	["adddefense_v"] = {{4,5,6,11}, "Chỉ khảm trên Trang sức."},					-- Né tránh
	["ignoredefenseenhance_v"] = {{4,5}, "Chỉ khảm trên Liên/Nhẫn."},						-- Bỏ qua né tránh
	["attackratingenhance_v"] = {{1,2,10}, "Chỉ khảm trên Vũ khí/Tay."},						-- Điểm đánh trúng
	
}

function tbItem:KhamThuocTinhOnOK(pSrcItemId, pTargetItemId, nRate, tbEnhItemId)
	local pSrcItem = KItem.GetObjById(pSrcItemId);
	local pTargetItem = KItem.GetObjById(pTargetItemId);
	local nDongThuocTinh = 0;
	
	for i = 1, 12 do
		if pSrcItem.GetGenInfo(i) ~= 0 then
			nDongThuocTinh = i;
			break;
		end
	end
	
	local nGenID = pSrcItem.GetGenInfo(nDongThuocTinh)
	local nGenLV = pSrcItem.GetGenInfo(nDongThuocTinh + 1)
	
	local nResult = 1
	
	local nCheck, szMsg = tbItem:CheckItemKhamThuocTinh(pSrcItemId, pTargetItemId, nDongThuocTinh);
	if nCheck == 0 then
		me.Msg(szMsg)
		return 0;
	end
	
	local nSysRate = MathRandom(1,100)
	if nRate < nSysRate then
		if nGenLV >= 2 then
			nGenLV = nGenLV - 1
			nResult = -1
		end
	elseif nRate == nSysRate then
		if nGenLV < 10 then
			nGenLV = nGenLV + 1
			nResult = 99
		end
	end

	pSrcItem.Delete(me);
	for _, pEnhItemId in pairs (tbEnhItemId) do
		local pEnhItem = KItem.GetObjById(pEnhItemId);
		pEnhItem.Delete(me);
	end
	
	pTargetItem.SetGenInfo(nDongThuocTinh, nGenID)
	pTargetItem.SetGenInfo(nDongThuocTinh + 1, nGenLV)
	pTargetItem.Sync();
	
	me.CallClientScript({"Ui:ServerCall", "UI_DIEMTINHTHACH", "OnEventResult" , 2, nResult, #tbEnhItemId, pTargetItem.dwId});
end
Item.c2sFun["KhamThuocTinh"] = tbItem.KhamThuocTinhOnOK;

function tbItem:CheckItemKhamThuocTinh(pSrcItemId, pTargetItemId, nDongThuocTinh)
	local tbGenInfo2tbMA = {
		[1] = 1,		[3] = 2,		[5] = 3,
		[7] = 4,		[9] = 5,		[11] = 6,
	}
	local pSrcItem = KItem.GetObjById(pSrcItemId);
	local pTargetItem = KItem.GetObjById(pTargetItemId);

	local tbGenInfo = pSrcItem.GetGenInfo(0, 1)
	local tbMA = tbGenInfo[tbGenInfo2tbMA[nDongThuocTinh]];
	
	if (pTargetItem.IsTTKEquip() ~= 1) then
		return 0, "Trang bị này không thể Khảm thuộc tính!"
	end
	
	if pTargetItem.GetGenInfo(nDongThuocTinh) ~= 0 then
		return 0, "Dòng này trên trang bị đã có thuộc tính"
	end
	
	if pTargetItem.nGenre ~= 1 then
		return 0, "Trang bị này không thể Khảm thuộc tính"
	end
	
	if tbGenInfo2tbMA[nDongThuocTinh] > 3 and pTargetItem.nSeries ~= pSrcItem.nSeries then
		return 0, "Trang bị và Điểm tinh thạch không cùng ngũ hành."
	end
	
	local tbGenInfo2 = pTargetItem.GetGenInfo(0, 1)
	for j = 1, #tbGenInfo2 do
		if tbGenInfo2[j].szName == tbMA.szName then
			return 0, "Thuộc tính này đã có trên Trang bị"
		end
	end
	
	if self.tbOptPlace[tbMA.szName] then
		for i = 1, #self.tbOptPlace[tbMA.szName][1] do
			if pTargetItem.nDetail == self.tbOptPlace[tbMA.szName][1][i] then
				return 1;
			end
		end
		return 0, ""..self.tbOptPlace[tbMA.szName][2];
	end
end 

function tbItem:RefineItemTTKOnOK(pSrcItemId, pTargetItemId, tbEnhItemId)
	local pSrcItem = KItem.GetObjById(pSrcItemId);
	local pTargetItem = KItem.GetObjById(pTargetItemId);
	
	local nResult = 1
	
	local nCheck, szMsg = tbItem:CheckRefineItem(pSrcItemId, pTargetItemId, tbEnhItemId);
	if nCheck == 0 then
		me.Msg(szMsg)
		return 0;
	end
	
	for _, pEnhItemId in pairs (tbEnhItemId) do
		local pEnhItem = KItem.GetObjById(pEnhItemId);
		pEnhItem.Delete(me);
	end
	
	pTargetItem.Regenerate(
		pTargetItem.nGenre,
		pTargetItem.nDetail,
		pTargetItem.nParticular + 10,
		pTargetItem.nLevel,
		pTargetItem.nSeries,
		pTargetItem.nEnhTimes,
		pTargetItem.nLucky,
		pTargetItem.GetGenInfo(),
		0,
		pTargetItem.dwRandSeed,
		pTargetItem.nStrengthen
	);
	
	pSrcItem.Delete(me);
	
	pTargetItem.Bind(1);
	pTargetItem.Sync();
	
	me.CallClientScript({"Ui:ServerCall", "UI_DIEMTINHTHACH", "OnEventResult" , 3, nResult, #tbEnhItemId, pTargetItem.dwId});
end
Item.c2sFun["RefineItemTTK"] = tbItem.RefineItemTTKOnOK;

function tbItem:CheckRefineItem(pSrcItemId, pTargetItemId, tbEnhItemId)
	local pSrcItem = KItem.GetObjById(pSrcItemId);
	local pTargetItem = KItem.GetObjById(pTargetItemId);
	
	if (pTargetItem.IsTTKEquip() ~= 1) or (pTargetItem.nLevel < 10) then
		return 0, "Trang bị này không thể Luyện hóa!"
	end
	
	if (pTargetItem.nRefineLevel == 1) then
		return 0, "Trang bị này đã luyện hóa cấp 1 rồi!"
	end
	
	local nMoney = Item:CalcRefineMoney(pTargetItem);
	if pTargetItem.nEnhTimes == 0 then
		nRefineDegree = 100;
		nMoney = 10000;
	end
	
	if (me.CostBindMoney(nMoney, Player.emKBINDMONEY_COST_REFINE) ~= 1) then
		if (me.nCashMoney + me.GetBindMoney() < nMoney) then
			me.Msg("Bạn không đủ bạc để Luyện hóa!");
			return 0;
		else
			local nBindMoney = me.GetBindMoney();
			me.CostBindMoney(nBindMoney, Player.emKBINDMONEY_COST_REFINE);
			me.CostMoney(nMoney - nBindMoney, Player.emKPAY_REFINE);
		end
	end

	local nXuanJingValue = 0 
	for _, pEnhItemId in pairs (tbEnhItemId) do
		local pEnhItem = KItem.GetObjById(pEnhItemId);
		nXuanJingValue = nXuanJingValue + pEnhItem.nValue
	end
	local nRefineDegree = math.floor((Item:CalcEnhanceValue(pTargetItem) * 8 + nXuanJingValue * 10) / (Item:CalcEnhanceValue(pTargetItem) * 9) * 100);
	if nRefineDegree < 100 then
		return 0, "Tỉ lệ luyện hóa chưa đạt 100%"
	end
end 

function tbItem:HutThuocTinhOnOK(pSrcItemId, pTargetItemId, nDongThuocTinh, nRate, tbEnhItemId)
	local pSrcItem = KItem.GetObjById(pSrcItemId);
	local pTargetItem = KItem.GetObjById(pTargetItemId);
	
	local nGenID = pSrcItem.GetGenInfo(nDongThuocTinh)
	local nGenLV = pSrcItem.GetGenInfo(nDongThuocTinh + 1)
	
	local nResult = 1
	
	local nCheck, szMsg = tbItem:CheckItemHutThuocTinh(pSrcItemId, pTargetItemId, nDongThuocTinh);
	if nCheck == 0 then
		me.Msg(szMsg)
		return 0;
	end
	
	for _, pEnhItemId in pairs (tbEnhItemId) do
		local pEnhItem = KItem.GetObjById(pEnhItemId);
		pEnhItem.Delete(me);
	end
	local nSysRate = MathRandom(1,100)
	if nRate < nSysRate then
		if nGenLV >= 2 then
			nGenLV = nGenLV - 1
			nResult = -1
		end
	elseif nRate == nSysRate then
		if nGenLV < 10 then
			nGenLV = nGenLV + 1
			nResult = 99
		end
	end

	pTargetItem.Regenerate(
		pTargetItem.nGenre,
		pTargetItem.nDetail,
		pTargetItem.nParticular,
		pTargetItem.nLevel,
		pSrcItem.nSeries,
		pTargetItem.nEnhTimes,
		pTargetItem.nLucky,
		nil,
		0,
		pTargetItem.dwRandSeed,
		pTargetItem.nStrengthen
	);
	
	pSrcItem.Delete(me);
	
	pTargetItem.SetGenInfo(nDongThuocTinh, nGenID)
	pTargetItem.SetGenInfo(nDongThuocTinh + 1, nGenLV)
	pTargetItem.Sync();
	
	me.CallClientScript({"Ui:ServerCall", "UI_DIEMTINHTHACH", "OnEventResult" , 1, nResult, #tbEnhItemId, pTargetItem.dwId});
end
Item.c2sFun["HutThuocTinh"] = tbItem.HutThuocTinhOnOK;

function tbItem:CheckItemHutThuocTinh(pSrcItemId, pTargetItemId, nDongThuocTinh)
	local pSrcItem = KItem.GetObjById(pSrcItemId);
	local pTargetItem = KItem.GetObjById(pTargetItemId);
	local nGenID = pSrcItem.GetGenInfo(nDongThuocTinh);
	
	if (pSrcItem.IsTTKEquip() ~= 1) then
		return 0, "Trang bị này không thể Khảm thuộc tính!"
	end
	
	if nGenID == 0 then
		return 0, "Dòng này không chứa thuộc tính"
	end
	
	for i = 1, 12 do
		if pTargetItem.GetGenInfo(i) ~= 0 then
			return 0, "Điểm tinh thạch này đã có thuộc tính"
		end
	end
end 

function tbItem:GetTitle(nTipState)
	local nOptNum = 99
	for i = 1, 12 do
		if it.GetGenInfo(i) > 0 then
			nOptNum = i;
			break;
		end	
	end
	local szTip = "<color="..self.tbOpt[nOptNum][2]..">"
	szTip = szTip..it.szName.." ("..self.tbOpt[nOptNum][1]..")";
	return	szTip.."<color>\n";
end

function tbItem:GetTip(nTipState)
	local nOptNum = 99
	local szTip = "";
	for i = 1, 12 do
		if it.GetGenInfo(i) > 0 then
			nOptNum = i;
			break;
		end	
	end
	if self.tbOpt[nOptNum][2] == "gold" then
		szTip = szTip.."Ngũ hành: Vô hệ\n"
	elseif self.tbOpt[nOptNum][2] == "purple" then
		szTip = szTip.."Ngũ hành: "..Item.TIP_SERISE[it.nSeries].."\n"
	end
	
	local tbGenInfo = it.GetGenInfo(0, 1);
	for i = 1, #tbGenInfo do		-- 明属性处理
		local tbMA = tbGenInfo[i];
		local tbMAInfo = KItem.GetRandAttribInfo(tbMA.szName, tbMA.nLevel, it.nVersion, it.nMAVersion);
		if tbMAInfo then
			szTip = szTip.."\n"..self:GetMagicAttribDescEx(tbMA.szName, self:BuildMARange(tbMAInfo));
			szTip = szTip.."\nCấp thuộc tính: <color=orange>"..tbMA.nLevel.."<color>\n"
			szTip = szTip.."\nVị trí Khảm: ";
			if self.tbOptPlace[tbMA.szName] then
				szTip = szTip.."<color=orange>"..self.tbOptPlace[tbMA.szName][2].."<color>";
			else
				szTip = szTip.."<color=orange>Không giới hạn<color>";
			end
		end
		
	end
	return szTip;
end 

function tbItem:CalcValueInfo()
	local nValue = it.nValue;
	local nLevel = 1;
	local tbGenInfo = it.GetGenInfo(0, 1);
	for i = 1, #tbGenInfo do		-- 明属性处理
		local tbMA = tbGenInfo[i];
		if tbMA.nLevel ~= 0 then
			nLevel = tbMA.nLevel
		end
	end
	
	local tbTransIcon = {
		[1] = "",
		[2] = "",
		[3] = "",
		[4] = "\\image\\effect\\other\\new_cheng1.spr",
		[5] = "\\image\\effect\\other\\new_cheng1.spr",
		[6] = "\\image\\effect\\other\\new_cheng2.spr",
		[7] = "\\image\\effect\\other\\new_jin1.spr",
		[8] = "\\image\\effect\\other\\new_jin2.spr",
		[9] = "\\image\\effect\\other\\new_jin2.spr",
		[10] = "\\image\\effect\\other\\new_jin3.spr",
	}
	local szTransIcon = tbTransIcon[nLevel];
	return nValue, 1, "white", szTransIcon;	
end

function tbItem:OnUse()
	DoScript("\\script\\item\\class\\diemtinhthach.lua")
	me.CallClientScript({"UiManager:OpenWindow", "UI_DIEMTINHTHACH"});
end

function tbItem:GetMagicAttribDescEx(szName, tbLow, tbHigh)
	if szName == "" then
		return	"";
	end
	local szDesc = FightSkill:GetExtentMagicDesc(szName, tbLow, tbHigh);
	return szDesc;
end

function tbItem:BuildMARange(tbRange)
	local tbLow  = {};
	local tbHigh = {};
	for _, tb in ipairs(tbRange) do
		table.insert(tbLow, tb.nMin);
		table.insert(tbHigh, tb.nMax);
	end
	return tbLow, tbHigh;
end