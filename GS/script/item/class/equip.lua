
-- 装备，通用功能脚本

------------------------------------------------------------------------------------------
-- initialize
local nScriptVersion = Item.IVER_nEquipEnhance

local tbEquip = Item:GetClass("equip");

-- 道具持有情况
tbEquip.HOLDSTATUS_NONE			= 0;	-- 不拥有此物品
tbEquip.HOLDSTATUS_ROOM			= 1;	-- 在箱子或物品栏（或者失效）
tbEquip.HOLDSTATUS_EQUIP		= 2;	-- 装备在身上

-- 所有参与磨损系统的装备位置
tbEquip.ABRADE_POS =
{
	Item.EQUIPPOS_HEAD,
	Item.EQUIPPOS_BODY,
	Item.EQUIPPOS_BELT,
	Item.EQUIPPOS_WEAPON,
	Item.EQUIPPOS_FOOT,
	Item.EQUIPPOS_CUFF,
	Item.EQUIPPOS_AMULET,
	Item.EQUIPPOS_RING,
	Item.EQUIPPOS_NECKLACE,
	Item.EQUIPPOS_PENDANT,
};

-- 潜能名称列表
tbEquip.POTENTIAL_NAME = { "Sức mạnh", "Thân pháp", "Ngoại công", "Nội công" };

------------------------------------------------------------------------------------------
-- public

function tbEquip:OnUse()			-- 右键单击自动装备
	--local nCanUse, szMsg = Item:CheckIsUseAtMap(me.nMapId, it.dwId);
	if (me.CanUseItem(it) == 1) then
		me.AutoEquip(it);
		if it.nGenre == Item.EQUIP_PARTNER and it.IsBind() == 0 then
			it.Bind(1);		-- 同伴装备装备绑定
		end
	else
		self:DialogChange(it);
	end
	return	0;

end

function tbEquip:DialogChange(pEquip)
	local tbOpt = {};
	local tbSetting = Item:GetExternSetting("change", it.nVersion, 1);
	local szGDPL = string.format("%d,%d,%d,%d", pEquip.nGenre, pEquip.nDetail, pEquip.nParticular, pEquip.nLevel);
	if not tbSetting.tbItemToChangeId or not tbSetting.tbItemToChangeId[szGDPL] then
		return 0;
	end
	local tbFacEquip = Item:CheckCanChangable(pEquip);
	local tbFactions = Faction:GetGerneFactionInfo(me);
	for nFactionId, tbGDPL in pairs(tbFacEquip) do
		for _, id in ipairs(tbFactions) do
			if (id == nFactionId) then
				table.insert(tbOpt, {Player.tbFactions[nFactionId].szName, Item.ChangeEquipToFac, Item, it.dwId, nFactionId});
			end
		end
	end
	table.insert(tbOpt, {"Không cần chuyển đổi"});
	Dialog:Say("Không thể sử dụng trang bị, nhưng có thể chuyển đổi thành trang bị tương ứng với môn phái, <color=green>tất cả thuộc tính của trang bị đều chuyển đổi bằng giá, không sợ bị lỗ.<color>",
		tbOpt);
end

function tbEquip:GetTip(nState, tbEnhRandMASS, tbEnhEnhMASS)		-- 获取装备Tip

	local szTip = "";

	szTip = szTip..self:Tip_ReqAttrib();
	szTip = szTip..self:Tip_Durability();
	szTip = szTip..self:Tip_Level();
	szTip = szTip..self:Tip_Series(nState);
	szTip = szTip..self:Tip_FixSeries(nState);
	szTip = szTip.."<color>";
	-- 同伴装备的基础属性加上颜色标签，added by dengyong 20100422
	if (it.IsPartnerEquip() == 1) then
		szTip = szTip.."<color=green>";
	end
	szTip = szTip..self:Tip_BaseAttrib(nState);
	if (it.IsPartnerEquip() == 1) then
		szTip = szTip.."<color>";
	end
	
	szTip = szTip..self:Tip_EnchaseInfo(nState);
	
	szTip = szTip..self:Tip_RandAttrib(nState, tbEnhRandMASS);
	szTip = szTip..self:Tip_EnhAttrib(nState, tbEnhEnhMASS);
	szTip = szTip..self:Tip_StrAttrib(nState);
	szTip = szTip..self:Tip_ActiveRuleAttrib(nState);
	szTip = szTip..self:Tip_Maker();
	szTip = szTip..self:Tip_RepairInfo(nState);
	szTip = szTip..self:GetBreakUpStuffTips();

	return	Lib:StrTrim(szTip, "\n");

end

-- 计算道具价值量相关信息，仅在道具生成时执行一次
-- 返回值：价值量，价值量星级，名字颜色，透明图层路径
function tbEquip:CalcValueInfo()
	-- 计算价值量
	local nValue = self:CalcValue();
	
	-- 计算装备价值量星级，名字颜色，透明图层路径
	local nStarLevel, szNameColor, szTransIcon = Item:CalcStarLevelInfo(it.nVersion, it.nDetail, it.nLevel, nValue);
	return	nValue, nStarLevel, szNameColor, szTransIcon;
end

-- 计算打孔的价值量
function tbEquip:CalcHoleValue(pEquip)
	if (pEquip == nil or pEquip.IsEquip() ~= 1) then
		return 0;
	end
	-- 计算打孔的价值量
	local nHoleValue = 0;
	local tbBaseProp = KItem.GetEquipBaseProp(pEquip.nGenre, pEquip.nDetail, pEquip.nParticular, pEquip.nLevel);
	if (tbBaseProp and tbBaseProp.nQualityPrefix >= Item.nEquipHoleMinQuality and Item.tbMakeHoleMoney[tbBaseProp.nQualityPrefix]) then
		local tbMoney = Item.tbMakeHoleMoney[tbBaseProp.nQualityPrefix];
		for i = 1, Item.nMaxHoleCount do		
			local dwHoleInfo = pEquip.GetHoleStone(i);
			local bSpecialHole = 0;				-- te
			if (dwHoleInfo == 0) then
				break;						-- 孔是按顺序打的
			elseif (dwHoleInfo > 256) then
				bSpecialHole = 1;
			end
			nHoleValue = nHoleValue + (tbMoney[i] or 0); 	-- warnning 如果以后调整费用会造成价值量变化
			if (bSpecialHole == 1) then
				nHoleValue = nHoleValue + 500000;
			end
		end
	end
	return nHoleValue;
end

-- 计算ex价值量
function tbEquip:CalcExValue(pEquip)
	local nValue = 0;
	    
	if  (pEquip.nGenre == Item.EQUIP_PURPLEEX) then
		-- 精铸价值量加成
		local nCastAdd = KItem.GetExCastAddValue(pEquip.GetEquipExValue(Item.ITEM_TASKVAL_EX_SUBID_ENHID));
		if nCastAdd then
			nValue = nValue + nCastAdd;
		end
		
		-- 炼化价值量加成
		local nExRefineLev = pEquip.GetEquipExValue(Item.ITEM_TASKVAL_EX_SUBID_ExRefLevel);
		local tbInfo = Item:GetExternSetting("refine",1) : GetExEquipRefineInfo(pEquip.nDetail, nExRefineLev);
		if tbInfo then
			nValue = nValue + tbInfo.nAddValue;
		end		
	end 
	
	return nValue;
end
------------------------------------------------------------------------------------------
-- private

function tbEquip:CalcEnhanceAttrib(nState)		-- 计算装备强化/玄晶拆卸后的魔法属性值

	if (nState ~= Item.TIPS_ENHANCE and nState ~= Item.TIPS_TRANSFER) then
		return;
	end

	if (it.nDetail < Item.MIN_COMMON_EQUIP) or (it.nDetail > Item.MAX_COMMON_EQUIP) then
		return;
	end

	local nNewEnhanceTimes = Item.tbTransferEquip.nNewEnhanceTimes;
	local nNewStrengthen = Item.tbTransferEquip.nNewStrengthen;
	
	
	if (it.nEnhTimes >= Item:CalcMaxEnhanceTimes(it)) or 
		(nNewEnhanceTimes and nNewEnhanceTimes> Item:CalcMaxEnhanceTimes(it)) then
		return;
	end
		
	local nType = Item.tbTransferEquip.nType or -1;
	local pTemp = nil;
	local tbTaskData = Item:GetItemTaskData(it);
	tbTaskData = Item:FullFilTable(tbTaskData);
	if nState == Item.TIPS_TRANSFER then
		pTemp = KItem.CreateTempItem(
			it.nGenre,
			it.nDetail,
			it.nParticular,
			it.nLevel,
			it.nSeries,
			(Item:GetEquipType(it) ~= nType or nNewEnhanceTimes <= it.nEnhTimes) and it.nEnhTimes or nNewEnhanceTimes,
			it.nLucky,
			it.GetGenInfo(),
			0,
			it.dwRandSeed,
			it.nIndex,
			(Item:GetEquipType(it) ~= nType or nNewEnhanceTimes <= it.nEnhTimes) and it.nStrengthen or nNewStrengthen,
			it.nCount,
			it.nCurDur,
			it.nMaxDur,
			it.GetRandomInfo(),
			tbTaskData
			);
	else
		pTemp = KItem.CreateTempItem(
			it.nGenre,
			it.nDetail,
			it.nParticular,
			it.nLevel,
			it.nSeries,
			it.nEnhTimes + 1,
			it.nLucky,
			it.GetGenInfo(),
			0,
			it.dwRandSeed,
			it.nIndex,
			it.nStrengthen,
			it.nCount,
			it.nCurDur,
			it.nMaxDur,
			it.GetRandomInfo(),
			tbTaskData
		);
	end

	if (not pTemp) then
		return;
	end
	local tbRandMASS = pTemp.GetRandMASS();
	local tbEnhMASS  = pTemp.GetEnhMASS();
	local nStarLevel = pTemp.nStarLevel;
	local nNameColor = pTemp.nNameColor;
	pTemp.Remove();
	return tbRandMASS, tbEnhMASS, nStarLevel, nNameColor;
end


function tbEquip:GetTitle(nState, nEnhNameColor)	-- 获得Tip字符串：名字、强化次数

	local szTip = string.format("<color=0x%x>", it.nNameColor);

	if ((nState == Item.TIPS_PREVIEW) or (nState == Item.TIPS_GOODS)) and (it.nGenre == Item.EQUIP_GENERAL) then
		szTip = szTip..it.szOrgName;	-- 对于蓝装，处于属性预览状态时不显示后缀
	else
		szTip = szTip..it.szName;
	end

	local nNewEnhanceTimes = Item.tbTransferEquip.nNewEnhanceTimes;
	local nNewStrengthen = Item.tbTransferEquip.nNewStrengthen;
	local nType = Item.tbTransferEquip.nType;
	-- 强化信息
	if (it.IsWhite() ~= 1) then
		if (it.nEnhTimes <= 0 and it.IsPartnerEquip() == 0) then
			szTip = szTip.." \nChưa cường hóa";
		elseif (it.IsPartnerEquip() == 0) then
			szTip = szTip.." +"..it.nEnhTimes;
		end
		if (it.nStrengthen > 0) then
			szTip = szTip.." Sửa";
		end
			
		if (nState == Item.TIPS_ENHANCE) and nEnhNameColor then		-- 装备强化预览
			local nEnhTimes = it.nEnhTimes + 1;
			local nOpen = KGblTask.SCGetDbTaskInt(DBTASK_ENHANCESIXTEEN_OPEN);	
			if ((nOpen == 0 and nEnhTimes <= Item:CalcMaxEnhanceTimes(it)) or (nOpen == 1 and nEnhTimes < Item.nEnhTimesLimitOpen)) then
				szTip = szTip..string.format(
					" <color=gold>→<color> <color=0x%x>+%d<color>",
					nEnhNameColor,
					nEnhTimes
				);
			end
		elseif nState == Item.TIPS_STRENGTHEN  and Item:CheckStrengthenEquip(it) == 1 then
			szTip = szTip..string.format(
				" <color=gold>→<color> <color=0x%x>+%d sửa<color>",
				it.nNameColor,
				it.nEnhTimes
			);
		elseif nState == Item.TIPS_TRANSFER and nEnhNameColor
				and nNewEnhanceTimes and nNewStrengthen and nType then
				if nNewEnhanceTimes <= Item:CalcMaxEnhanceTimes(it) and 
				   (nNewEnhanceTimes > it.nEnhTimes or nNewStrengthen > it.nStrengthen) and
				   nType == Item:GetEquipType(it) then
					--print(nState,nNewEnhanceTimes,nNewStrengthen,nType)
					szTip = szTip ..string.format(
							" <color=gold>→<color> <color=0x%x>+%d%s<color>",
							nEnhNameColor,
							nNewEnhanceTimes,
							nNewStrengthen > 0 and " Sửa" or ""
						);
				end
		end
	end

	return	szTip.."<color>\n";

end

function tbEquip:Tip_Warning()		-- 获得Tip字符串：对于复制装备的警告信息

	if (it.IsDuped() == 1) then
		return	"<color=red>!! Vật phẩm này là đồ giả, hệ thống sẽ tịch thu!! \nCoi chừng bị lừa, đừng giao dịch<color>\n"
	end

	return	"";

end

function tbEquip:Tip_Durability()

	local bIsAbrade = 0;
	for i = 1, #self.ABRADE_POS do
		if (self.ABRADE_POS[i] == it.nEquipPos) then
			bIsAbrade = 1;
			break;
		end
	end;

	if (bIsAbrade ~= 1) then	-- 这里处理不参与磨损系统的装备耐久信息
		return	"";				-- 不显示耐久
	end

	-- 处理参与磨损系统的装备耐久信息

	local szTip = "";
	local bColor = 0;

	if (it.nCurDur <= 0) then
		szTip = "<color=red>";
		bColor = 1;
	end
	szTip = szTip.."Độ bền: "..math.ceil(it.nCurDur / 10);
	if bColor == 1 then
		szTip = szTip.."<color>";
	end

	bColor = 0;
	szTip = szTip.." / ";

	if (it.nMaxDur <= Item.DUR_WARNING) then
		szTip = szTip.."<color=red>";
		bColor = 1;
	elseif (it.nMaxDur < Item.DUR_MAX) then
		szTip = szTip.."<color=orange>";
		bColor = 1;
	end
	szTip = szTip..math.ceil(it.nMaxDur / 10);
	if (bColor == 1) then
		szTip = szTip.."<color>";
	end
	
	return	"\n"..szTip;

end

function tbEquip:Tip_Level()			-- 获得Tip字符串：装备级别

	return	"\nCấp trang bị: "..it.nLevel.."";

end

function tbEquip:Tip_Series(nState)		-- 获得Tip字符串：五行属性

	local szTip = "  Ngũ hành: ";
	local nSeries = it.nSeries;

	if (nState == Item.TIPS_PREVIEW) then	-- 属性预览状态时要看配置表中的五行
		local tbBaseProp = KItem.GetEquipBaseProp(it.nGenre, it.nDetail, it.nParticular, it.nLevel, it.nVersion);
		if (tbBaseProp) then
			nSeries = tbBaseProp.nSeries;
		else
			nSeries = -1;
		end
	end

	local szSeries = Env.SERIES_NAME[nSeries] or "？";
	szTip = szTip..szSeries;

	return	szTip;

end

function tbEquip:Tip_FixSeries()
	local TIP_SERISE = 
	{
		"<color=yellow>Dùng cho hệ Kim<color>", 
		"<color=green>Dùng cho hệ Mộc<color>", 
		"<color=blue>Dùng cho hệ Thủy<color>", 
		"<color=red>Dùng cho hệ Hỏa<color>", 
		"<color=gray>Dùng cho hệ Thổ<color>",
	};
	local szTip = " ("
	if Item.tbSeriesFix[it.nEquipPos] and it.nSeries > 0 then
		return szTip..TIP_SERISE[Item.tbSeriesFix[it.nEquipPos][it.nSeries]]..")";
	end
	return "";
end

function tbEquip:Tip_ReqAttrib()	-- 获得Tip字符串：需求属性

	local tbAttrib = it.GetReqAttrib();		-- 获得道具需求属性
	local tbId = {it.nGenre, it.nDetail, it.nParticular, it.nLevel};

	return	Item:GetRequireDesc(tbAttrib, tbId);
end

function tbEquip:Tip_BaseAttrib(nState)	-- 获得Tip字符串：基础属性

	local szTip = "";
	local tbAttrib = it.GetBaseAttrib();	-- 获得道具基础属性

	if (nState == Item.TIPS_PREVIEW) or (nState == Item.TIPS_GOODS) then	-- 属性预览状态

		local tbBaseProp = KItem.GetEquipBaseProp(it.nGenre, it.nDetail, it.nParticular, it.nLevel, it.nVersion);
		if tbBaseProp then
			for i, tbMA in ipairs(tbBaseProp.tbBaseAttrib) do
				if (tbBaseProp.nSeries > 0) and (tbMA.szName == "damage_series_resist") then	-- TODO: 五行抗性特殊处理
					tbMA.tbRange[3].nMin = tbAttrib[i].tbValue[3];
					tbMA.tbRange[3].nMax = tbAttrib[i].tbValue[3];
				end
				local szTemp = self:GetMagicAttribDescEx(tbMA.szName, self:BuildMARange(tbMA.tbRange));
				if szTemp ~= "" then
					szTip = szTip.."\n"..szTemp;
				end
			end
		end

	else									-- 其他状态

		for _, tbMA in ipairs(tbAttrib) do
			local szDesc = self:GetMagicAttribDesc(tbMA.szName, tbMA.tbValue);
			local bInvalid = it.IsInvalid();
			if (tbMA.szName == "weapondamagemin_v") or (tbMA.szName == "weapondamagemax_v") or (tbMA.szName == "weaponmagicmin_v") or (tbMA.szName == "weaponmagicmax_v") then
				szDesc = "";
			end
			if (szDesc ~= "") then
				if bInvalid == 1 then
					szTip = szTip..string.format("\n<color=gray>%s<color>", szDesc);
				else
					szTip = szTip.."\n"..szDesc;
				end
			end
		end
		if it.nEquipPos == Item.EQUIPPOS_WEAPON then
			local tbMA = {}
			tbMA.weapondamagemin_v = {};
			tbMA.weapondamagemax_v = {};
			tbMA.weaponmagicmin_v = {};
			tbMA.weaponmagicmax_v = {};
			for i=1,#tbAttrib do
				if tbAttrib[i].szName == "weapondamagemin_v" then
					tbMA.weapondamagemin_v = tbAttrib[i];
				end
				if tbAttrib[i].szName == "weapondamagemax_v" then
					tbMA.weapondamagemax_v = tbAttrib[i];
				end
				if tbAttrib[i].szName == "weaponmagicmin_v" then
					tbMA.weaponmagicmin_v = tbAttrib[i];
				end
				if tbAttrib[i].szName == "weaponmagicmax_v" then
					tbMA.weaponmagicmax_v = tbAttrib[i];
				end
			end
			if tbMA.weapondamagemin_v.tbValue then
				szTip = szTip..string.format("\nLực công ngoại công tăng: %s - %s", tbMA.weapondamagemin_v.tbValue[1], tbMA.weapondamagemax_v.tbValue[1]);
				szTip = szTip..string.format("\nLực công nội tăng: %s - %s", tbMA.weaponmagicmin_v.tbValue[1], tbMA.weaponmagicmax_v.tbValue[1]);
			end
		end
	end

	if szTip ~= "" then
		return	"\n"..szTip.."";
	end

	return szTip;

end

function tbEquip:Tip_RandAttrib(nState, tbEnhRandMASS)	-- 获得Tip字符串：随机属性
	if (it.IsTTKEquip() == 1) then
		return self:Tip_RandAttrib_TTK(nState, tbEnhRandMASS)
	else
		return self:Tip_RandAttrib_Ex(nState, tbEnhRandMASS)
	end
end

function tbEquip:Tip_RandAttrib_Ex(nState, tbEnhRandMASS)	-- 获得Tip字符串：随机属性

	local nOpen = KGblTask.SCGetDbTaskInt(DBTASK_ENHANCESIXTEEN_OPEN);
	local szTip = "";
	local nPos1, nPos2 = KItem.GetEquipActive(KItem.EquipType2EquipPos(it.nDetail));
	local tbMASS = it.GetRandMASS();			-- 获得道具随机魔法属性

	if (nState == Item.TIPS_PREVIEW) or (nState == Item.TIPS_GOODS) then	-- 属性预览状态，显示魔法属性范围

		local nSeries = it.nSeries;
		local tbGenInfo = it.GetGenInfo(0, 1);

		if (nState == Item.TIPS_PREVIEW) then	-- 预览状态需读取配置表中的五行
			local tbBaseProp = KItem.GetEquipBaseProp(it.nGenre, it.nDetail, it.nParticular, it.nLevel, it.nVersion);
			if (tbBaseProp) then
				nSeries = tbBaseProp.nSeries;
			else
				nSeries = -1;					-- 五行不确定
			end
		end

		if (not nPos1) or (not nPos2) then		-- 不参与五行激活的装备

			for _, tbMA in ipairs(tbGenInfo) do
				local tbMAInfo = KItem.GetRandAttribInfo(tbMA.szName, tbMA.nLevel, it.nVersion, it.nMAVersion);
				if tbMAInfo then
					szTip = szTip.."\n"..self:GetMagicAttribDescEx(tbMA.szName, self:BuildMARange(tbMAInfo.tbRange));
				end
			end

		else									-- 参与五行激活的装备

			for i = 1, #tbGenInfo / 2 do		-- 明属性处理
				local tbMA = tbGenInfo[i];
				local tbMAInfo = KItem.GetRandAttribInfo(tbMA.szName, tbMA.nLevel, it.nVersion, it.nMAVersion);
				if tbMAInfo then
					szTip = szTip.."\n"..self:GetMagicAttribDescEx(tbMA.szName, self:BuildMARange(tbMAInfo));
				end
			end

			local nTotal  = 0;					-- 暗属性总计数
			local nActive = 0;					-- 已激活暗属性计数
			for i = #tbGenInfo / 2 + 1, #tbGenInfo do	-- 暗属性处理
				local tbMA = tbGenInfo[i];
				if tbMA.szName ~= "" then
					nTotal = nTotal + 1;
					if tbMA.bActive == 1 then
						nActive = nActive + 1;
					end
				else
					break;
				end
			end

			if nTotal > 0 then					-- 存在暗属性

				if nSeries < 0 then				-- 五行不确定的情况

					szTip = szTip..string.format("\n\n<color=blue>Kích hoạt ngũ hành (0/%d)", nTotal);
					szTip = szTip..string.format(
						"<color=gray>%s (?) %s (?) Nhân vật (?) <color>",
						Item.EQUIPPOS_NAME[nPos1],
						Item.EQUIPPOS_NAME[nPos2]
					);		-- 总是灰的
					szTip = szTip.."<color>";

					for i = #tbGenInfo / 2 + 1, #tbGenInfo do
						local tbMA = tbGenInfo[i];
						local tbMAInfo = KItem.GetRandAttribInfo(tbMA.szName, tbMA.nLevel, it.nVersion, it.nMAVersion);
						if tbMAInfo then
							local szDesc = self:GetMagicAttribDescEx(tbMA.szName, self:BuildMARange(tbMAInfo));
							if (szDesc ~= "") and (tbMASS[i].bVisible == 1) then
								szTip = szTip..string.format("\n<color=gray>%s<color>", szDesc);	-- 总是灰的
							end
						end
					end

				else

					local nAccSeries  = KMath.AccruedSeries(it.nSeries);
					local szAccSeries = Env.SERIES_NAME[nAccSeries];
					local pEquip1 = me.GetEquip(nPos1);
					local pEquip2 = me.GetEquip(nPos2);
					local nSeries1 = pEquip1 and pEquip1.nSeries or Env.SERIES_NONE;
					local nSeries2 = pEquip2 and pEquip2.nSeries or Env.SERIES_NONE;

					szTip = szTip..string.format("\n\n<color=blue>Kích hoạt ngũ hành (%d/%d)\n", nActive, nTotal);

					if (nSeries1 ~= nAccSeries) then
						szTip = szTip..string.format("<color=gray>%s (%s)<color> ", Item.EQUIPPOS_NAME[nPos1], szAccSeries);
					else
						szTip = szTip..string.format("<color=white>%s (%s)<color> ", Item.EQUIPPOS_NAME[nPos1], szAccSeries);
					end
					if (nSeries2 ~= nAccSeries) then
						szTip = szTip..string.format("<color=gray>%s (%s)<color> ", Item.EQUIPPOS_NAME[nPos2], szAccSeries);
					else
						szTip = szTip..string.format("<color=white>%s (%s)<color> ", Item.EQUIPPOS_NAME[nPos2], szAccSeries);
					end
					if (me.nSeries ~= nAccSeries) then
						szTip = szTip..string.format("<color=gray>Nhân vật (%s)<color>", szAccSeries);
					else
						szTip = szTip..string.format("<color=white>Nhân vật (%s)<color>", szAccSeries);
					end

					szTip = szTip.."<color>";

					for i = #tbGenInfo / 2 + 1, #tbGenInfo do
						local tbMA = tbGenInfo[i];
						local tbMAInfo = KItem.GetRandAttribInfo(tbMA.szName, tbMA.nLevel, it.nVersion, it.nMAVersion);
						if tbMAInfo then
							local szDesc = self:GetMagicAttribDescEx(tbMA.szName, self:BuildMARange(tbMAInfo));
							if (szDesc ~= "") and (tbMASS[i].bVisible == 1) then
								szTip = szTip..string.format("\n<color=gray>%s<color>", szDesc);	-- 总是灰的
							end
						end
					end

				end

			end

		end

	else										-- 其他状态，显示魔法属性具体值

		if (not nPos1) or (not nPos2) then		-- 不参与五行激活的装备

			for i = 1, #tbMASS do
				local tbMA = tbMASS[i];
				local szDesc = "";
				if tbEnhRandMASS and (nOpen == 0 or (nOpen == 1 and it.nEnhTimes < Item.nEnhTimesLimitOpen - 1)) then
					szDesc = self:GetMagicAttribDescEx2(tbMA.szName, tbMA.tbValue, tbEnhRandMASS[i].tbValue);
				else
					szDesc = self:GetMagicAttribDesc(tbMA.szName, tbMA.tbValue);
				end
				if (szDesc ~= "") and (tbMA.bVisible == 1) then
					if (tbMA.bActive ~= 1) then
						szTip = szTip..string.format("\n<color=gray>%s<color>", szDesc);
					else
						szTip = szTip.."\n"..szDesc;
					end
				end
			end

		else
												-- 不参与五行激活的装备
			for i = 1, #tbMASS / 2 do			-- 明属性处理
				local tbMA = tbMASS[i];
				local szDesc = "";				
				if tbEnhRandMASS and (nOpen == 0 or (nOpen == 1 and it.nEnhTimes < Item.nEnhTimesLimitOpen - 1)) then
					szDesc = self:GetMagicAttribDescEx2(tbMA.szName, tbMA.tbValue, tbEnhRandMASS[i].tbValue);
				else
					szDesc = self:GetMagicAttribDesc(tbMA.szName, tbMA.tbValue);
				end
				if (szDesc ~= "") and (tbMA.bVisible == 1) then
					if (tbMA.bActive ~= 1) then
						szTip = szTip..string.format("\n<color=gray>%s<color>", szDesc);
					else
						szTip = szTip.."\n"..szDesc;
					end
				end
			end

			local nTotal  = 0;					-- 暗属性总计数
			local nActive = 0;					-- 已激活暗属性计数
			for i = #tbMASS / 2 + 1, #tbMASS do	-- 暗属性处理
				local tbMA = tbMASS[i];
				if tbMA.szName ~= "" then
					nTotal = nTotal + 1;
					if tbMA.bActive == 1 then
						nActive = nActive + 1;
					end
				else

					break;
				end
			end

			if nTotal > 0 then					-- 存在暗属性
				local nAccSeries  = KMath.AccruedSeries(it.nSeries);
				local szAccSeries = Env.SERIES_NAME[nAccSeries];
				local pEquip1 = me.GetEquip(nPos1);
				local pEquip2 = me.GetEquip(nPos2);
				local nSeries1 = pEquip1 and pEquip1.nSeries or Env.SERIES_NONE;
				local nSeries2 = pEquip2 and pEquip2.nSeries or Env.SERIES_NONE;
				szTip = szTip..string.format("\n\n<color=blue>Kích hoạt ngũ hành (%d/%d)\n", nActive, nTotal);
				if (nSeries1 ~= nAccSeries) then
					szTip = szTip..string.format("<color=gray>%s (%s)<color> ", Item.EQUIPPOS_NAME[nPos1], szAccSeries);
				else
					szTip = szTip..string.format("<color=white>%s (%s)<color> ", Item.EQUIPPOS_NAME[nPos1], szAccSeries);
				end
				if (nSeries2 ~= nAccSeries) then
					szTip = szTip..string.format("<color=gray>%s (%s)<color> ", Item.EQUIPPOS_NAME[nPos2], szAccSeries);
				else
					szTip = szTip..string.format("<color=white>%s (%s)<color> ", Item.EQUIPPOS_NAME[nPos2], szAccSeries);
				end
				if (me.nSeries ~= nAccSeries) then
					szTip = szTip..string.format("<color=gray>Nhân vật (%s)<color>", szAccSeries);
				else
					szTip = szTip..string.format("<color=white>Nhân vật (%s)<color>", szAccSeries);
				end
				szTip = szTip.."<color>";
				for i = #tbMASS / 2 + 1, #tbMASS do
					local tbMA = tbMASS[i];
					local szDesc = "";
					if tbEnhRandMASS and (nOpen == 0 or (nOpen == 1 and it.nEnhTimes < Item.nEnhTimesLimitOpen - 1)) then
						szDesc = self:GetMagicAttribDescEx2(tbMA.szName, tbMA.tbValue, tbEnhRandMASS[i].tbValue);
					else
						szDesc = self:GetMagicAttribDesc(tbMA.szName, tbMA.tbValue);
					end
					if (szDesc ~= "") and (tbMA.bVisible == 1) then
						if tbMA.bActive == 1 then
							szTip = szTip..string.format("\n%s", szDesc);
						else
							szTip = szTip..string.format("\n<color=gray>%s<color>", szDesc);
						end
					end
				end
			end

		end

	end
	if szTip ~= "" then
		return	"<color=greenyellow>"..szTip.."<color>";
	end
	return szTip;
end

function tbEquip:Tip_RandAttrib_TTK(nState, tbEnhRandMASS)	-- 获得Tip字符串：随机属性

	local nOpen = KGblTask.SCGetDbTaskInt(DBTASK_ENHANCESIXTEEN_OPEN);
	local szTip = "";
	local nPos1, nPos2 = KItem.GetEquipActive(KItem.EquipType2EquipPos(it.nDetail));
	local tbMASS = it.GetRandMASS();			-- 获得道具随机魔法属性

	if (nState == Item.TIPS_PREVIEW) or (nState == Item.TIPS_GOODS) then	-- 属性预览状态，显示魔法属性范围

		local nSeries = it.nSeries;
		local tbGenInfo = it.GetGenInfo(0, 1);

		if (nState == Item.TIPS_PREVIEW) then	-- 预览状态需读取配置表中的五行
			local tbBaseProp = KItem.GetEquipBaseProp(it.nGenre, it.nDetail, it.nParticular, it.nLevel, it.nVersion);
			if (tbBaseProp) then
				nSeries = tbBaseProp.nSeries;
			else
				nSeries = -1;					-- 五行不确定
			end
		end

		if (not nPos1) or (not nPos2) then		-- 不参与五行激活的装备

			for _, tbMA in ipairs(tbGenInfo) do
				local tbMAInfo = KItem.GetRandAttribInfo(tbMA.szName, tbMA.nLevel, it.nVersion, it.nMAVersion);
				if tbMAInfo then
					szTip = szTip.."\n"..self:GetMagicAttribDescEx(tbMA.szName, self:BuildMARange(tbMAInfo.tbRange));
				end
			end

		else									-- 参与五行激活的装备

			for i = 1, #tbGenInfo / 2 do		-- 明属性处理
				local tbMA = tbGenInfo[i];
				local tbMAInfo = KItem.GetRandAttribInfo(tbMA.szName, tbMA.nLevel, it.nVersion, it.nMAVersion);
				if tbMAInfo then
					szTip = szTip.."\n"..self:GetMagicAttribDescEx(tbMA.szName, self:BuildMARange(tbMAInfo));
				end
			end

			local nTotal  = 0;					-- 暗属性总计数
			local nActive = 0;					-- 已激活暗属性计数
			for i = #tbGenInfo / 2 + 1, #tbGenInfo do	-- 暗属性处理
				local tbMA = tbGenInfo[i];
				if tbMA.szName ~= "" then
					nTotal = nTotal + 1;
					if tbMA.bActive == 1 then
						nActive = nActive + 1;
					end
				else
					break;
				end
			end

			if nTotal > 0 then					-- 存在暗属性

				if nSeries < 0 then				-- 五行不确定的情况

					szTip = szTip..string.format("\n\n<color=blue>Kích hoạt ngũ hành (0/%d)", nTotal);
					szTip = szTip..string.format(
						"<color=gray>%s (?) %s (?) Nhân vật (?) <color>",
						Item.EQUIPPOS_NAME[nPos1],
						Item.EQUIPPOS_NAME[nPos2]
					);		-- 总是灰的
					szTip = szTip.."<color>";

					for i = #tbGenInfo / 2 + 1, #tbGenInfo do
						local tbMA = tbGenInfo[i];
						local tbMAInfo = KItem.GetRandAttribInfo(tbMA.szName, tbMA.nLevel, it.nVersion, it.nMAVersion);
						if tbMAInfo then
							local szDesc = self:GetMagicAttribDescEx(tbMA.szName, self:BuildMARange(tbMAInfo));
							if (szDesc ~= "") and (tbMASS[i].bVisible == 1) then
								szTip = szTip..string.format("\n<color=gray>%s<color>", szDesc);	-- 总是灰的
							end
						end
					end

				else

					local nAccSeries  = KMath.AccruedSeries(it.nSeries);
					local szAccSeries = Env.SERIES_NAME[nAccSeries];
					local pEquip1 = me.GetEquip(nPos1);
					local pEquip2 = me.GetEquip(nPos2);
					local nSeries1 = pEquip1 and pEquip1.nSeries or Env.SERIES_NONE;
					local nSeries2 = pEquip2 and pEquip2.nSeries or Env.SERIES_NONE;

					szTip = szTip..string.format("\n\n<color=blue>Kích hoạt ngũ hành (%d/%d)\n", nActive, nTotal);

					if (nSeries1 ~= nAccSeries) then
						szTip = szTip..string.format("<color=gray>%s (%s)<color> ", Item.EQUIPPOS_NAME[nPos1], szAccSeries);
					else
						szTip = szTip..string.format("<color=white>%s (%s)<color> ", Item.EQUIPPOS_NAME[nPos1], szAccSeries);
					end
					if (nSeries2 ~= nAccSeries) then
						szTip = szTip..string.format("<color=gray>%s (%s)<color> ", Item.EQUIPPOS_NAME[nPos2], szAccSeries);
					else
						szTip = szTip..string.format("<color=white>%s (%s)<color> ", Item.EQUIPPOS_NAME[nPos2], szAccSeries);
					end
					if (me.nSeries ~= nAccSeries) then
						szTip = szTip..string.format("<color=gray>Nhân vật (%s)<color>", szAccSeries);
					else
						szTip = szTip..string.format("<color=white>Nhân vật (%s)<color>", szAccSeries);
					end

					szTip = szTip.."<color>";

					for i = #tbGenInfo / 2 + 1, #tbGenInfo do
						local tbMA = tbGenInfo[i];
						local tbMAInfo = KItem.GetRandAttribInfo(tbMA.szName, tbMA.nLevel, it.nVersion, it.nMAVersion);
						if tbMAInfo then
							local szDesc = self:GetMagicAttribDescEx(tbMA.szName, self:BuildMARange(tbMAInfo));
							if (szDesc ~= "") and (tbMASS[i].bVisible == 1) then
								szTip = szTip..string.format("\n<color=gray>%s<color>", szDesc);	-- 总是灰的
							end
						end
					end

				end

			end

		end

	else										-- 其他状态，显示魔法属性具体值

		if (not nPos1) or (not nPos2) then		-- 不参与五行激活的装备

			for i = 1, #tbMASS do
				local tbMA = tbMASS[i];
				local szDesc = "";
				if tbEnhRandMASS and (nOpen == 0 or (nOpen == 1 and it.nEnhTimes < Item.nEnhTimesLimitOpen - 1)) then
					szDesc = self:GetMagicAttribDescEx2(tbMA.szName, tbMA.tbValue, tbEnhRandMASS[i].tbValue);
				else
					szDesc = self:GetMagicAttribDesc(tbMA.szName, tbMA.tbValue);
				end
				if (szDesc ~= "") and (tbMA.bVisible == 1) then
					if (tbMA.bActive ~= 1) then
						szTip = szTip..string.format("\n<color=gray>%s<color>", szDesc);
					else
						szTip = szTip.."\n"..szDesc;
					end
				end
			end

		else
												-- 不参与五行激活的装备
			for i = 1, #tbMASS / 2 do			-- 明属性处理
				local tbMA = tbMASS[i];
				local tbGenInfo = it.GetGenInfo(0, 1);
				local tbMA2 = tbGenInfo[i];
				local szDesc = "";				
				if tbEnhRandMASS and (nOpen == 0 or (nOpen == 1 and it.nEnhTimes < Item.nEnhTimesLimitOpen - 1)) then
					szDesc = self:GetMagicAttribDescEx2(tbMA.szName, tbMA.tbValue, tbEnhRandMASS[i].tbValue);
				else
					szDesc = self:GetMagicAttribDesc(tbMA.szName, tbMA.tbValue);
				end
				if (szDesc ~= "") and (tbMA.bVisible == 1) then
					if (tbMA.bActive ~= 1) then
						szTip = szTip..string.format("\n<color=gray>%s<color>", szDesc);
					else
						szTip = szTip.."\n<color=orange>(Lv."..tbMA2.nLevel..")<color> "..szDesc;
					end
				else
					szTip = szTip.."\n<color=orange>(Lv.0)<color> <color=purple>Thuộc tính Hiện "..i.." chưa có<color>";
				end
			end

			local nTotal  = 0;					-- 暗属性总计数
			local nActive = 0;					-- 已激活暗属性计数
			for i = #tbMASS / 2 + 1, #tbMASS do	-- 暗属性处理
				local tbMA = tbMASS[i];
				if tbMA.szName ~= "" then
					nTotal = nTotal + 1;
					if tbMA.bActive == 1 then
						nActive = nActive + 1;
					end
				else
					-- break;
				end
			end

			if nTotal > 0 then					-- 存在暗属性
				local nAccSeries  = KMath.AccruedSeries(it.nSeries);
				local szAccSeries = Env.SERIES_NAME[nAccSeries];
				local pEquip1 = me.GetEquip(nPos1);
				local pEquip2 = me.GetEquip(nPos2);
				local nSeries1 = pEquip1 and pEquip1.nSeries or Env.SERIES_NONE;
				local nSeries2 = pEquip2 and pEquip2.nSeries or Env.SERIES_NONE;
				szTip = szTip..string.format("\n\n<color=blue>Kích hoạt ngũ hành (%d/%d)\n", nActive, nTotal);
				if (nSeries1 ~= nAccSeries) then
					szTip = szTip..string.format("<color=gray>%s (%s)<color> ", Item.EQUIPPOS_NAME[nPos1], szAccSeries);
				else
					szTip = szTip..string.format("<color=white>%s (%s)<color> ", Item.EQUIPPOS_NAME[nPos1], szAccSeries);
				end
				if (nSeries2 ~= nAccSeries) then
					szTip = szTip..string.format("<color=gray>%s (%s)<color> ", Item.EQUIPPOS_NAME[nPos2], szAccSeries);
				else
					szTip = szTip..string.format("<color=white>%s (%s)<color> ", Item.EQUIPPOS_NAME[nPos2], szAccSeries);
				end
				if (me.nSeries ~= nAccSeries) then
					szTip = szTip..string.format("<color=gray>Nhân vật (%s)<color>", szAccSeries);
				else
					szTip = szTip..string.format("<color=white>Nhân vật (%s)<color>", szAccSeries);
				end
				szTip = szTip.."<color>";
				for i = #tbMASS / 2 + 1, #tbMASS do
					local tbMA = tbMASS[i];
					local tbGenInfo = it.GetGenInfo(0, 1);
					local tbMA2 = tbGenInfo[i];					local szDesc = "";
					if tbEnhRandMASS and (nOpen == 0 or (nOpen == 1 and it.nEnhTimes < Item.nEnhTimesLimitOpen - 1)) then
						szDesc = self:GetMagicAttribDescEx2(tbMA.szName, tbMA.tbValue, tbEnhRandMASS[i].tbValue);
					else
						szDesc = self:GetMagicAttribDesc(tbMA.szName, tbMA.tbValue);
					end
					if (szDesc ~= "") and (tbMA.bVisible == 1) then
						if tbMA.bActive == 1 then
							szTip = szTip..string.format("\n<color=orange>(Lv."..tbMA2.nLevel..")<color> %s", szDesc);
						else
							szTip = szTip..string.format("\n<color=orange>(Lv."..tbMA2.nLevel..")<color> <color=gray>%s<color>", szDesc);
						end
					else
						local tbRow = {
							[4] = "1",
							[5] = "2",
							[6] = "3",
						}
						szTip = szTip..string.format("\n<color=orange>(Lv.0)<color> <color=purple>Thuộc tính Ẩn ".. tbRow[i] .." chưa có<color>");
					end
				end
			else
				local nAccSeries  = KMath.AccruedSeries(it.nSeries);
				local szAccSeries = Env.SERIES_NAME[nAccSeries];
				local pEquip1 = me.GetEquip(nPos1);
				local pEquip2 = me.GetEquip(nPos2);
				local nSeries1 = pEquip1 and pEquip1.nSeries or Env.SERIES_NONE;
				local nSeries2 = pEquip2 and pEquip2.nSeries or Env.SERIES_NONE;
				szTip = szTip..string.format("\n\n<color=blue>Kích hoạt ngũ hành (%d/%d)\n", nActive, nTotal);
				if (nSeries1 ~= nAccSeries) then
					szTip = szTip..string.format("<color=gray>%s (%s)<color> ", Item.EQUIPPOS_NAME[nPos1], szAccSeries);
				else
					szTip = szTip..string.format("<color=white>%s (%s)<color> ", Item.EQUIPPOS_NAME[nPos1], szAccSeries);
				end
				if (nSeries2 ~= nAccSeries) then
					szTip = szTip..string.format("<color=gray>%s (%s)<color> ", Item.EQUIPPOS_NAME[nPos2], szAccSeries);
				else
					szTip = szTip..string.format("<color=white>%s (%s)<color> ", Item.EQUIPPOS_NAME[nPos2], szAccSeries);
				end
				if (me.nSeries ~= nAccSeries) then
					szTip = szTip..string.format("<color=gray>Nhân vật (%s)<color>", szAccSeries);
				else
					szTip = szTip..string.format("<color=white>Nhân vật (%s)<color>", szAccSeries);
				end
				szTip = szTip.."<color>";
				for i = 1, 3 do
					szTip = szTip..string.format("\n<color=orange>(Lv.0)<color> <color=purple>Thuộc tính Ẩn ".. i .." chưa có<color>");
				end
			end

		end

	end
	if szTip ~= "" then
		return	"<color=greenyellow>"..szTip.."<color>";
	end
	return szTip;
end

function tbEquip:Tip_EnhAttrib(nState, tbEnhEnhMASS)	-- 获得Tip字符串：强化激活属性
	local nOpen = KGblTask.SCGetDbTaskInt(DBTASK_ENHANCESIXTEEN_OPEN);
	-- if (it.IsWhite() == 1) then
		-- return	"";						-- 白色装备不显示强化激活属性
		
	-- end

	local szTip = "<color=greenyellow>";
	local tbMASS = it.GetEnhMASS();		-- 获得道具强化激活魔法属性

	if (nState == Item.TIPS_PREVIEW) then	-- 属性预览状态，显示魔法属性范围

		local tbBaseProp = KItem.GetEquipBaseProp(it.nGenre, it.nDetail, it.nParticular, it.nLevel, it.nVersion);

		if tbBaseProp then
			local tbEnhMA = tbBaseProp.tbEnhaceMA;
			local nCount = 0;				-- 强化属性计数
			for i, tbMA in ipairs(tbEnhMA) do
				if (tbMA.szName ~= "") and (tbMASS[i].bVisible == 1) then
					nCount = nCount + 1;
				end
			end
			if nCount > 0 then				-- 具有强化属性
				local nCouldEnhanceTimes = Item:CalcMaxEnhanceTimes(it);
				if nOpen == 1 then
					nCouldEnhanceTimes = Item.nEnhTimesLimitOpen - 1;					
				end
				if it.nEnhTimes > nCouldEnhanceTimes then
					nCouldEnhanceTimes = it.nEnhTimes;
				end
				szTip = string.format(
					"%s\n<color=blue>Cường hóa (%d/%d)<color>",
					szTip,
					it.nEnhTimes,
					nCouldEnhanceTimes
				);
				for i, tbMA in ipairs(tbEnhMA) do
					local szDesc = self:GetMagicAttribDescEx(tbMA.szName, self:BuildMARange(tbMA.tbRange));
					if (szDesc ~= "") and (tbMASS[i].bVisible == 1) then
						if nOpen == 0 or ( nOpen == 1 and tbMA.nTimes < Item.nEnhTimesLimitOpen) then
							if tbMASS[i].bActive ~= 1 then	-- 未激活显示为灰色
								if nScriptVersion ~= 1 then
									szTip = szTip.."\n<color=gray>"..Lib:StrFillL(string.format("(+ %d)", tbMA.nTimes), 12)..szDesc.."<color>";
								elseif tbMA.nTimes <= Item:CalcMaxEnhanceTimes(it) then
									szTip = szTip.."\n<color=gray>"..Lib:StrFillL(string.format("(+ %d)", tbMA.nTimes), 12)..szDesc.."<color>";
								end
							else
								szTip = szTip.."\n"..Lib:StrFillL(string.format("(+ %d)", tbMA.nTimes), 12)..szDesc;
							end
						end
					end
				end
			end
		end

	else									-- 其他状态，显示魔法属性具体值

		local nCount = 0;					-- 强化属性计数

		for _, tbMA in ipairs(tbMASS) do
			if (tbMA.szName ~= "") and (tbMA.bVisible == 1) then
				nCount = nCount + 1;
			end
		end

		if nCount > 0 then					-- 具有强化属性
			local nCouldEnhanceTimes = Item:CalcMaxEnhanceTimes(it);
			if nOpen == 1 then
				nCouldEnhanceTimes = Item.nEnhTimesLimitOpen - 1;				
			end
			if it.nEnhTimes > nCouldEnhanceTimes then
				nCouldEnhanceTimes = it.nEnhTimes;
			end
			szTip = string.format(
				"%s\n<color=blue>Cường hóa (%d/%d)<color>",
				szTip,
				it.nEnhTimes,
				nCouldEnhanceTimes
			);
			for i = 1, #tbMASS do
				local tbMA = tbMASS[i];
				local szDesc = self:GetMagicAttribDesc(tbMA.szName, tbMA.tbValue);
				if (szDesc ~= "") and (tbMA.bVisible == 1) then
					if (tbMA.bActive ~= 1) and (tbMA.bVisible == 1) then
						if nOpen == 0 or ( nOpen == 1 and tbMA.nTimes < Item.nEnhTimesLimitOpen) then
							if tbEnhEnhMASS and (tbEnhEnhMASS[i].bActive == 1) then
								szTip = szTip.."\n<color=gold>"..Lib:StrFillL(string.format("(+ %d)", tbMA.nTimes), 12)..szDesc.."<color>";
							else
								if nScriptVersion ~= 1 then
									szTip = szTip.."\n<color=gray>"..Lib:StrFillL(string.format("(+ %d)", tbMA.nTimes), 12)..szDesc.."<color>";
								elseif tbMA.nTimes <= Item:CalcMaxEnhanceTimes(it) then
									szTip = szTip.."\n<color=gray>"..Lib:StrFillL(string.format("(+ %d)", tbMA.nTimes), 12)..szDesc.."<color>";
								end
							end
						end
					else
						szTip = szTip.."\n"..Lib:StrFillL(string.format("(+ %d)", tbMA.nTimes), 12)..szDesc;
					end
				end
			end
		end

	end

	if szTip ~= "" then
		return	"\n<color=greenyellow>"..szTip.."<color>";
	end

	return szTip;

end

-- 改造属性
function tbEquip:Tip_StrAttrib(nState)
	local nNewEnhanceTimes = Item.tbTransferEquip.nNewEnhanceTimes;
	local nNewStrengthen = Item.tbTransferEquip.nNewStrengthen;
	local nType = Item.tbTransferEquip.nType or -1;
	
	--Vn--
	if UiManager.IVER_nqianghua15 == 1 then
		return	"";	
	end
	--Vn--
	if (nState ~= Item.TIPS_TRANSFER or (nNewStrengthen and nNewStrengthen == 0) or Item:GetEquipType(it) ~= nType) and 
		(it.IsWhite() == 1 or it.nEnhTimes <= 14 or it.nEnhTimes > 15 ) then
		return	"";						-- 白色装备不显示强化激活属性
	end

	local nCount = 0;					-- 改造属性计数	
	local szTip = "\n<color=blue>Sửa<color>";
	local tbMASS = it.GetStrMASS();		-- 获得道具强化激活魔法属性
	for i = 1, #tbMASS do
		local tbMA = tbMASS[i];
		local szDesc = self:GetMagicAttribDesc(tbMA.szName, tbMA.tbValue);
		
		if (szDesc ~= "") and (tbMA.bVisible == 1) then
			nCount = nCount + 1;
			--如果是装备预览状态且满足改造需求，改造TIP变色（类似于装备强化）
			if (nState == Item.TIPS_STRENGTHEN  and Item:CheckStrengthenEquip(it) == 1) or 
				(nNewStrengthen and nNewStrengthen > 0 and Item:GetEquipType(it) == nType) then
				local _, _, _, nStrengthenColor = self:CalcEnhanceAttrib(Item.TIPS_ENHANCE);	--用装备强化时所用的颜色列表
				local szColor = string.format("<color=0x%x>", nStrengthenColor);
				szDesc = "\n"..szColor..Lib:StrFillL(string.format("(Cường hóa +%d sửa)", tbMA.nTimes), 12)..szDesc.."<color>";
			elseif (tbMA.bActive == 1) and (tbMA.bVisible == 1) then
				szDesc = "\n"..Lib:StrFillL(string.format("(Cường hóa +%d sửa)", tbMA.nTimes), 12)..szDesc;
			else
				if nScriptVersion ~= 1 then
					szDesc = "\n<color=gray>"..Lib:StrFillL(string.format("(Cường hóa +%d sửa)", tbMA.nTimes), 12)..szDesc.."<color>";
				elseif tbMA.nTimes <= Item:CalcMaxEnhanceTimes(it) then
					szDesc = "\n<color=gray>"..Lib:StrFillL(string.format("(+ %d sửa)", tbMA.nTimes), 12)..szDesc.."<color>";
				end
			end
		end

		szTip = szTip..szDesc;
	end

	if nCount == 0 then
		return	"";
	else
		return	"\n<color=greenyellow>"..szTip.."<color>";
	end
end

-- 装备激活规则属性
function tbEquip:Tip_ActiveRuleAttrib(nState)
	local tbMass = it.GetActiveRuleMASS();
	if (not tbMass or #tbMass == 0) then
		return "";
	end

	local szStr = "";
	local tbStr = {};
	for i = 0, #tbMass do
		-- 属性类型不能为0
		local tbMagic = tbMass[i].tbMagic;
		if (tbMagic.szName ~= "") then
			local szRuleDesc = string.format("\n\n<color=blue>%s<color>", tbMass[i].szDesc);
			local szMagicDesc = "";
			if tbMagic.szName == "disguise_part_base" then
				szMagicDesc = string.format("\nCó thể thay đổi %s", Item.szResPart[tbMagic.tbValue[2]]);
			else
				szMagicDesc = self:GetMagicAttribDesc(tbMagic.szName, tbMagic.tbValue);
			end
			
			if (szMagicDesc ~= "") then
				local szColor = tbMagic.bActive == 0 and "gray" or "greenyellow"; 
				szMagicDesc = string.format("<color=%s>%s<color>", szColor, szMagicDesc);
				tbStr[szRuleDesc] = tbStr[szRuleDesc] or {};
				table.insert(tbStr[szRuleDesc], szMagicDesc);
			end
		end
	end
	
	for szRuleStr, tbRuleStrs in pairs(tbStr) do
		if #tbRuleStrs > 0 and szRuleStr ~= "" then
			szStr = szStr..szRuleStr.."\n";
		end
		for j, szSingleStr in pairs(tbRuleStrs) do
			szStr = szStr..szSingleStr.."\n";
		end
	end

	return szStr;
end

function tbEquip:Tip_Maker()			-- 获得Tip字符串：制造者信息

	if (it.nCustomType == Item.CUSTOM_TYPE_MAKER) and it.szCustomString ~= "" then
		return	"\n<color=orange>"..it.szCustomString.."<color> <color=green>chế tạo<color>";
	end
	if (it.nCustomType == Item.CUSTOM_TYPE_EVENT) and it.szCustomString ~= "" then
		return	"\n<color=orange>"..it.szCustomString.."<color>";
	end

	return "";

end

function tbEquip:Tip_RepairInfo(nState)	-- 获得Tip字符串：修理信息

	if (nState == Item.TIPS_CREPAIR) then
		local nMoney = Item:CalcCommonRepairPrice(it);
		if (nMoney >= 0) then
			local szMoney = "Miễn phí";
			if (nMoney > 0) then
				szMoney = Item:FormatMoney(nMoney).." lượng";
			end
			return	"\n<color=yellow>Phí sửa thường: "..szMoney.."<color>";
		end
	elseif (nState == Item.TIPS_SREPAIR) or (nState == Item.TIPS_IREPAIR) then	-- 修理状态显示修理信息
		local nMoney   = Item:CalcSpecialRepairPrice(it);
		local nItemDur = Item:CalcItemRepairPrice(it);
		local szMoney = "Miễn phí";
		if (nMoney > 0) then
			szMoney = Item:FormatMoney(nMoney).." lượng";
		end
		if (nMoney >= 0) and (nItemDur >= 0) then
			return	"\n<color=yellow>Phí sửa kỹ: "..szMoney.." (ưu tiên dùng bạc khóa) hoặc"..nItemDur.."Điểm độ bền Kim Tê <color>";
		else
			return	"\n<color=yellow>Không cần sửa thành độ bền lớn nhất<color>";
		end
	end

	return	"";

end

function tbEquip:Tip_EnchaseInfo(nState)  -- 嵌入属性描述
	local szTip = "";
	
	local nHoleCount = it.GetHoleCount();
	if not nHoleCount or nHoleCount <= 0 then
		return szTip.."\n";
	end	
	
	for i = 1, Item.nMaxHoleCount do
		local nHoleType, nValue = it.GetHoleStone(i);
		if nHoleType ~= 0 then
			szTip = szTip .. self:GetHoleDesc(nHoleType, nValue);
		end
	end

	return "\n\n<color=greenyellow>" .. szTip .. "<color>";
end

------------------------------------------------------------------------------------------

function tbEquip:GetMagicAttribDesc(szName, tbValue, bActive)
	if szName == "" then
		return	"";
	end
	local s = FightSkill:GetMagicDesc(szName, tbValue, nil, 1);
	return s;
end

function tbEquip:GetMagicAttribDescEx(szName, tbLow, tbHigh)
	if szName == "" then
		return	"";
	end
	local szDesc = FightSkill:GetExtentMagicDesc(szName, tbLow, tbHigh);
	return szDesc;
end

function tbEquip:GetMagicAttribDescEx2(szName, tbBefore, tbAfter)
	if szName == "" then
		return	"";
	end
	local s = FightSkill:GetExtentMagicDesc(szName, tbBefore, tbAfter, 1);
	return s;
end

function tbEquip:BuildMARange(tbRange)
	local tbLow  = {};
	local tbHigh = {};
	for _, tb in ipairs(tbRange) do
		table.insert(tbLow, tb.nMin);
		table.insert(tbHigh, tb.nMax);
	end
	return tbLow, tbHigh;
end

function tbEquip:GetBreakUpStuffTips()
	local szTip = ""
	local nGTPCost, tbStuff, tbExp = Item:CalcBreakUpStuff(it);
	
	if (nGTPCost > 0) and (#tbStuff > 0) then
		szTip = "\n\n<color=orange>".."Tách vật phẩm (mất "..tostring(nGTPCost).. " hoạt lực): <color>\n";
		for _, tbInfo in ipairs(tbStuff) do
			local szName = KItem.GetNameById(tbInfo.nGenre, tbInfo.nDetail, tbInfo.nParticular, tbInfo.nLevel);
			szTip = szTip..string.format("<color=green>%s<color><color=yellow> x %d<color>\n", szName, tbInfo.nCount);
		end
	end
	return szTip;
end

function tbEquip:GetHoleDesc(nHoleType, nValue)
	local szDesc = "";
	local szColor = "empty";	-- 表示格子里没有嵌宝石
		
	local nHoleLevel, nSpecial = Item.tbStone:ParseHoleType(nHoleType);	
	local tbGDPL = Item.tbStone:ParseStoneInfoInHole(nValue);
	local tbStone = KItem.GetStoneProp(unpack(tbGDPL));
	local tbST ={}
	tbST.lifepermillage = {};
	tbST.manapermillage = {};
	tbST.life_v = {};
	tbST.mana_v = {};
	
	
	-- 找不到石头，表示没有镶嵌
	if not tbStone then
		local nImgIdx = Item.tbStone.tbStoneTipsImg[nSpecial][szColor];
		szDesc = string.format("<pic=%d> ", nImgIdx);
		szDesc = szDesc.."<color=gray>Chưa khảm".. "(0/"..nHoleLevel..")<color>\n";
	else
		szColor = tbStone.szColor;
		local nImgIdx = Item.tbStone.tbStoneTipsImg[nSpecial][szColor];
		szDesc = string.format("<pic=%d> ", nImgIdx);
		
		local szBenefit = "";		-- 增益属性描述
		local szDeBuff = "";		-- 减益属性描述
		local szPreFix, szLvDesc = "", "";
		
		local tbAttrib = Item.tbStone:GetAttrib(tbStone.szMagicClass, tbGDPL[4]);
		local tbTemp = {};			
		for i, tbSingleAttrib in pairs(tbAttrib) do
			local bBenefit = tbSingleAttrib.bBenefit or 1;	-- 默认按增益效果处理
			local szThisDesc = "";			
			
			if (tbSingleAttrib.szName == "lifemax_permillage") or (tbSingleAttrib.szName == "manamax_permillage") then
				if not tbTemp["lifemax_permillage"] then
					local szAdd = tbSingleAttrib.tbValue[1]>=0 and "Tăng " or "Giảm ";
					szThisDesc = string.format("Sinh lực và nội lực tối đa: %s%s%%", szAdd, math.abs(tbSingleAttrib.tbValue[1]/10));
					tbTemp["lifemax_permillage"] = 1;
				end
			elseif tbSingleAttrib.szName == "lifemax_v" or tbSingleAttrib.szName == "manamax_v" then  --血量点数
				if not tbTemp["lifemax_v"] then
					local szAdd = tbSingleAttrib.tbValue[1]>=0 and "Tăng " or "Giảm ";
					szThisDesc = string.format("Sinh lực và nội lực tối đa: %s%d điểm", szAdd, math.abs(tbSingleAttrib.tbValue[1]));
					tbTemp["lifemax_v"] = 1;
				end
			elseif tbSingleAttrib.szName == "lifereplenish_p" or tbSingleAttrib.szName == "manareplenish_p" then  --血蓝回复效率
				if not tbTemp["lifereplenish_p"] then
					local szAdd = tbSingleAttrib.tbValue[1]>=0 and "Tăng " or "Giảm ";
					szThisDesc = string.format("Hiệu suất hồi sinh lực và nội lực: %s%s%%", szAdd, math.abs(tbSingleAttrib.tbValue[1]));
					tbTemp["lifereplenish_p"] = 1;
				end
			else
																												 
				szThisDesc = FightSkill:GetMagicDesc(tbSingleAttrib.szName, tbSingleAttrib.tbValue, nil, 1, nil, 0);
			end
			
			if szThisDesc ~= "" then
				if bBenefit == 1 then
					szPreFix = szBenefit == "" and "" or "   ";
					szLvDesc = (szBenefit == "" and tbStone.nStyle ~= 1) 
						and string.format("(%d/%d)\n", tbGDPL[4], nHoleLevel) or "\n";
					szBenefit = szBenefit..szPreFix..szThisDesc..szLvDesc;
				else
					szPreFix = "   ";
					szLvDesc = "\n";
					szDeBuff = szDeBuff..szPreFix..szThisDesc..szLvDesc;
				end
			end
		end
		
		szDesc = szDesc..szBenefit..szDeBuff;
	end
	return szDesc;
end

-- 道具数据加载完成后会通知的脚本
function tbEquip:OnLoadComplete()
	self:UpdateValue();				-- 打孔价值量加成	
end

-- 更新装备的财富荣誉，用于打孔等影响装备价值量的操作，又不重新生成装备的时候
function tbEquip:UpdateValue()
	it.nValue = self:CalcValueInfo();
end

-- 计算财富荣誉
function tbEquip:CalcValue()
	local nValue = it.nOrgValue;
	local tbSetting = Item:GetExternSetting("value", it.nVersion, 1);

	if (not tbSetting) then
		print("File cấu hình value không tồn tại! Trở về giá trị ban đầu!");
	else
		-- 同伴装备的价值量直接等于nOrgValue，不采用下面的计算方法计算
		if (it.IsPartnerEquip() == 0) then
			local tbGenInfo	= it.GetGenInfo(0, 1);
			local tbValue = {};
			local nLevelRate = tbSetting.m_tbEquipLevel[it.nLevel] or 100;
			local nTypeRate  = tbSetting.m_tbEquipTypeRate[it.nDetail] or 100;
			local nEnhValue  = 0;
			local nStrValue  = 0;
			for i = 1, it.nEnhTimes do
				nEnhValue = nEnhValue + (tbSetting.m_tbEnhanceValue[i] or 0);
			end
			if it.nStrengthen > 0 then
				nStrValue = tbSetting.m_tbStrengthenValue[it.nEnhTimes] or 0;
			end
	
			-- 随机属性位置加权
			for i, tbInfo in ipairs(tbGenInfo) do
				local v = KItem.GetMagicValue(tbInfo.szName, tbInfo.nLevel, it.nVersion, it.nMAVersion);
				local nRate = (tbSetting.m_tbEquipRandPos[i] or 100) / 100;
				v = math.floor(v * nRate);
				tbValue[i] = v;
				nValue = nValue + v;
			end
	
			-- 随机属性组合加权
			for i = 1, #tbGenInfo do
				for j = i, #tbGenInfo do
					local t = tbSetting.m_tbMagicCombine[tbGenInfo[i].szName];
					if t then
						local n = t[tbGenInfo[j].szName];
						if n then
							local nRate = math.sqrt(n) / 10;
							nRate = (nRate - 1) * tbGenInfo[i].nLevel * tbGenInfo[j].nLevel / 400;
							local v = math.floor((tbValue[i] + tbValue[j]) * nRate);
							nValue = nValue + v;
						end
					end
				end
			end		
				
			nValue = math.floor(nValue / 100 * nLevelRate);					-- 装备等级加权
			nValue = math.floor(nValue / 100 * nTypeRate);					-- 装备类型加权
			nValue = nValue + math.floor(nEnhValue / 100 * nTypeRate);		-- 强化价值量加成
			nValue = nValue + math.floor(nStrValue / 100 * nTypeRate);		-- 改造价值量加成
			nValue = nValue + math.floor(self:CalcHoleValue(it));			-- 打孔价值量加成
			nValue = nValue + math.floor(self:CalcExValue(it));				-- ex数据对价值量的加成
		end
	end
	return nValue;
end
