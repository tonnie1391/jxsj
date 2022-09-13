------------------------------------------------------
-- 文件名　：stone.lua
-- 创建者　：dengyong
-- 创建时间：2011-05-24 11:37:51
-- 描  述  ：宝石
------------------------------------------------------

Require("\\script\\item\\stone\\define.lua");

------------------------------------- stone类道具继承自itembase的基本逻辑 -------------------------------------
local tbStone = Item:GetClass("gem");

function tbStone:GetTitle(nTipState)
	return string.format("<color=0x%x>%s<color>", it.nNameColor, it.szName);
end

function tbStone:CalcValueInfo()
	local nValue = it.nOrgValue;		-- 没有价值量
	
	local nStarLevel = Item.tbStone:GetStarLevel(it);
	
	local szNameColor = "white";
	if Item.tbStone.tbStarLevel and Item.tbStone.tbStarLevel[nStarLevel] then
		szNameColor = Item.tbStone.tbStarLevel[nStarLevel].szNameColor;
	end	
	
	local szTransIcon = "";
	if it.nDetail == 1 then
		if it.nLevel == 3 then
			szTransIcon = "\\image\\effect\\other\\new_cheng1.spr";	
		elseif it.nLevel == 4 then
			szTransIcon = "\\image\\effect\\other\\new_cheng2.spr";	
		elseif it.nLevel == 5 then
			szTransIcon = "\\image\\effect\\other\\new_jin1.spr";
		elseif it.nLevel == 6 then
			szTransIcon = "\\image\\effect\\other\\new_jin2.spr";	
		elseif it.nLevel == 7 then
			szTransIcon = "\\image\\effect\\other\\new_jin3.spr";	
		elseif it.nLevel == 8 then
			szTransIcon = "\\image\\effect\\other\\new_jin3.spr";	
		elseif it.nParticular == 37 then
			szTransIcon = "\\image\\effect\\other\\new_jin1.spr";
		elseif (it.nParticular >= 38 and it.nParticular <= 55) or
			(it.nParticular >= 69 and it.nParticular <= 73) then  --如果做后续宝石需要修改
			szTransIcon = "\\image\\effect\\other\\new_jin1.spr";
		end	
	end
	
	return	nValue, nStarLevel, szNameColor, szTransIcon;
end

function tbStone:GetTip(nTipState)
	local szTip = "";

	szTip = szTip..self:Tip_Info(nTipState).."\n";
	
	szTip = szTip..self:Tip_Attrib(nTipState).."\n";
	
	szTip = szTip..self.Tip_EquipQuaLimit(nTipState);
	
	szTip = szTip..self:Tip_EquipPosLimit(nTipState);
	
	szTip = szTip..self:Tip_UpgradeLimit(nTipState);
	
	szTip = szTip..self:Tip_PartiLimit(nTipState);
	
	return szTip;
end

function tbStone:Tip_StarLevel(nTipState)
	local szTip = "\n  ";
	local nStarLevel = Item.tbStone:GetStarLevel(it);
	local szFillStar = "";
	local szEmptyStar = "";

	if Item.tbStone.tbStarLevel and Item.tbStone.tbStarLevel[nStarLevel] then
		szFillStar = string.format("<pic=%s>", Item.tbStone.tbStarLevel[nStarLevel].nFillStar - 1);
		szEmptyStar = string.format("<pic=%s>", Item.tbStone.tbStarLevel[nStarLevel].nEmptyStar - 1);
	else
		szFillStar = "★";
		szEmptyStar = "☆";
	end

	for i = 1, math.floor(nStarLevel / 2) do
		szTip = szTip..szFillStar;
		if i % 3 == 0 then
			szTip = szTip.." ";
		end
	end
	if (nStarLevel % 2 ~= 0) then
		szTip = szTip..szEmptyStar;
	end
	return	szTip;
end

function tbStone:Tip_Info(nTipState)
	local szTip = "";
	local tbStoneAttrib = it.GetStoneProp();
	local szStoneType = it.GetStoneType() == 1 and "Bảo thạch" or "Nguyên thạch";
	
	local nSpecial = tbStoneAttrib.nSpecial;
	local szSpecial = nSpecial == 0 and "Thường" or "Đặc biệt";
	
	local bExchange = Item.tbStone:GetStoneExchangeFeature(it);
	local szExchange = (bExchange == 1) and "Có thể đổi nguyên thạch khác\n" or ""

	local szColor = "";
	for _, tbColor in pairs(Item.tbStone.tbStoneColor) do
		if (tbStoneAttrib.szColor == tbColor[1]) then
			szColor = tbColor[2];--..szStoneType;
			break;
		end		
	end	
		
	szTip = szTip..string.format("%s %s %s", szColor, szSpecial, szStoneType).."\n";	
	szTip = szTip..szExchange;
	return szTip;
end

function tbStone:Tip_Attrib(nTipState)
	local szTip = "";
	local tbStoneAttrib = it.GetStoneProp();
	
	local szBenefit = "";		-- 增益属性描述
	local szDeBuff = "";		-- 减益属性描述
	local tbActualAttrib = Item.tbStone:GetAttrib(tbStoneAttrib.szMagicClass, it.nLevel);
	for _, tbSingleAttrib in pairs(tbActualAttrib) do
		local bBenefit = tbSingleAttrib.bBenefit or 1;	-- 默认按增益效果处理
		local szThisDesc = "";
		local szMsg = "";
		if tbSingleAttrib.szName == "skilllevel_added" then
			if me.nRouteId == 0 then
				szMsg = "";
			else
				szMsg = "Hệ phái khác <color=gold>Kỹ năng: "..Item.tbStone.tbSkillStoneDesc[tbSingleAttrib.tbValue[1]][1].."<color> +" .. tbSingleAttrib.tbValue[2] .. "\n";
				if Item.tbStone.tbSkillStoneDesc[tbSingleAttrib.tbValue[1]][2] then
					szMsg = szMsg.."Kỹ năng Cổ Mộ: <color=gold>"..Item.tbStone.tbSkillStoneDesc[tbSingleAttrib.tbValue[1]][2].."<color> +" .. tbSingleAttrib.tbValue[2] .. "\n";
				end
			end
		end
		szThisDesc = FightSkill:GetMagicDesc(tbSingleAttrib.szName, tbSingleAttrib.tbValue, nil, 1).."\n";
		
		if bBenefit == 1 then
			szBenefit = szBenefit..szThisDesc..szMsg;
		else
			szDeBuff = szDeBuff ..szThisDesc..szMsg;
		end
	end
	szTip = "<color=greenyellow>"..szBenefit..szDeBuff.."<color>";	
	return szTip;
end


function tbStone:Tip_UpgradeLimit(nTipState)       
	local szStCanUp = "";                            
	if it.nDetail == 2 then
	szStCanUp = szStCanUp.."\nDùng với <color=gold>"..Item.tbStone.tbStoneName[it.nParticular].."-"..Item.tbStone.tbStonePreName[it.nLevel - 1].."<color> để thăng cấp\n";
		if it.nLevel >= 3 then
			szStCanUp = szStCanUp.."\nTách được 3 <color=gold>"..Item.tbStone.tbStoneName[it.nParticular].."-Nguyên Thạch (cấp "..(it.nLevel - 1)..")<color>\n";
		end
	end

	return szStCanUp;                                
end                                                


-- 镶嵌位置限制
function tbStone:Tip_EquipPosLimit(nTipState)
	local tbStoneAttrib = it.GetStoneProp();
	
	local szTip = "Giới hạn vị trí khảm nạm:\n";
	for i, tbPosInfo in pairs(Item.tbStone.tbEquipPosDisplayList) do
		local nPos = tbPosInfo[1];
		local szPos =  tbPosInfo[2];
		
		local szColor = tbStoneAttrib.tbMatchEquipPos[nPos + 1] == 1 and "white" or "gray";
		szTip = szTip..string.format("<color=%s>%s<color>", szColor, szPos);
		
		if i%5 == 0 then
			szTip = szTip .. "\n";
		else
			szTip = szTip .. "  ";
		end				
	end

	return szTip;
end

-- 装备品质限制
function tbStone:Tip_EquipQuaLimit(nTipState)
	local szTip = "";
	
	if Item.tbEquipHoleLevel[7] <= it.nLevel then		-- 质量7表示黄金装备
		szTip = "Chỉ có thể khảm trên trang bị <color=gold>Sử Thi<color>";
	elseif Item.tbEquipHoleLevel[6] <= it.nLevel then  -- 质量6表示白银装备
		szTip = "Chỉ có thể khảm trên trang bị <color=gold>Trác Việt<color>";
	end
	
	if szTip ~= "" then
		szTip = szTip.."\n\n";
	end
	
	return szTip;
end

-- 特殊宝石描述
function tbStone:Tip_PartiLimit(nTipState)
	local szTip = "";
	local tbStoneAttrib = it.GetStoneProp();	
	local nSpecial = tbStoneAttrib.nSpecial;
	local szTip = (nSpecial == 1 and it.nDetail == 1) and "\n<color=gold>Chỉ có thể khảm trên lỗ đặc biệt<color>\n" or "";
	return szTip;
end

-- 使用原石切换到宝石升级状态
function tbStone:OnUse()
	if (Item.tbStone:GetOpenDay() == 0) then
		return 0;
	end
	if Item.STONE_GEM == it.nDetail then
		if (me.nFightState == 1) then
			me.Msg("Không thể nâng cấp trong trạng thái chiến đấu");
			return 0;
		end
		me.PrepareUpgradeStone(it.dwId);
	elseif (Item.STONE_PRODUCT == it.nDetail) then		-- 打开UI镶嵌剥离面板
		if (me.nFightState == 1) then
			me.Msg("Không thể nâng cấp trong trạng thái chiến đấu");
			return 0;
		end
		me.CallClientScript({"UiManager:OpenWindow", "UI_EQUIPHOLE", Item.HOLE_MODE_ENCHASE});
	end
	
	return 0;
end

------------------------------------------------- 宝石特有逻辑 -------------------------------------------------

Item.tbStone = Item.tbStone or {};
local tbStone = Item.tbStone;

-- 宝石魔法属性表分两种类型，一种是直接属性值定义，还有一种是线性关系配置，在获取的时候需要计算
function tbStone:GetAttrib(szMagicClass, nLevel)
	local tbAttrib;
	
	if self.tbStoneMagic["fix"][szMagicClass] then
		-- 是定制属性
		tbAttrib = self:GetFixAttrib(szMagicClass, nLevel);
	elseif self.tbStoneMagic["line"][szMagicClass] then
		-- 是线性属性
		tbAttrib = self:GetLineAttrib(szMagicClass, nLevel);
	end
	
	if not tbAttrib then
		assert("stone attrib get failed! magic class name[" .. szMagicClass .."], level[" .. nLevel .. "]");
	end
	
	return tbAttrib, Lib:CountTB(tbAttrib or {});
end

-- 获取定制属性值
function tbStone:GetFixAttrib(szMagicClass, nLevel)
	local tbMagic = self.tbStoneMagic["fix"][szMagicClass];
	if not tbMagic then
		return;
	end
	
	local tbAttrib = {};
	local nFromIndex = 1;
	for szAttribName, tbValues in pairs(tbMagic) do
		local tbTemp = {};
		tbTemp.szName = szAttribName;
		tbTemp.tbValue = {};

		for i = 1, FightSkill.MAGIC_VALUE_NUM do
			if not tbValues[i] or not tbValues[i][nLevel] then
				tbTemp.tbValue[i] = 0;  -- 容错，支持不填按默认值为0处理
			else
				local tbLevel = tbValues[i][nLevel];
				tbTemp.tbValue[i] = tbLevel[2];
			end
		end
		tbTemp.bBenefit = tbValues.bBenefit;
		
		tbAttrib[nFromIndex] = tbTemp;
		nFromIndex = nFromIndex + 1;
	end
	
	return tbAttrib;
end

-- 获取线性属性值
function tbStone:GetLineAttrib(szMagicClass, nLevel)
	local tbMagic = self.tbStoneMagic["line"][szMagicClass];
	if not tbMagic then
		return;
	end
	
	local tbAttrib = {};
	local nFromIndex = 1;
	for szAttribName, tbValues in pairs(tbMagic) do
		local tbTemp = {};
		tbTemp.szName = szAttribName;
		tbTemp.tbValue = {};		
			
		for i = 1, FightSkill.MAGIC_VALUE_NUM do
			tbTemp.tbValue[i] = Lib.Calc:Link(nLevel, tbValues[i]);			
		end
		
		tbAttrib[nFromIndex] = tbTemp;
		nFromIndex = nFromIndex + 1;
	end

	return tbAttrib;
end

-- 宝石兑换特性：等级、普通/特殊
-- 返回值：可否兑换、兑换等级、兑换类型（普通/特殊）
function tbStone:GetStoneExchangeFeature(pStone)
	if not pStone or type(pStone) ~= "userdata" or
		pStone.GetStoneType() ~= Item.STONE_GEM then
		return 0;
	end
	
	local tbStoneAttrib = pStone.GetStoneProp();
	if not tbStoneAttrib then
		return 0;
	end
	
	local nStyle = tbStoneAttrib.nStyle;
	if nStyle ~= self.EXCHANGE_STYLE_LIMIT then
		return 0;
	end
	
	return 1, {pStone.nLevel, tbStoneAttrib.nSpecial};
end

-- 判断两个宝石兑换特征是否一致
function tbStone:IsExchangeFeatureMatch(var1, var2)
	local bExchange1, bExchange2 = 1, 1;
	local tbFeature1, tbFeature2;
	if type(var1) == "userdata" then
		bExchange1, tbFeature1 = self:GetStoneExchangeFeature(var1)
	elseif type(var1) == "table" then
		tbFeature1 = var1;
	else
		return 0;
	end
	
	if type(var2) == "userdata" then
		bExchange2, tbFeature2 = self:GetStoneExchangeFeature(var2);
	elseif type(var2) == "table" then
		tbFeature2 = var2;
	else
		return 0;
	end
	
	if bExchange1 ~= 1 or bExchange2 ~= 1 then
		return 0;
	end
	
	if tbFeature1[1] ~= tbFeature2[1] then
		return 0;
	end
	
	if tbFeature1[2] ~= tbFeature2[2] then
		return 0;
	end
	
	return 1;	
end

-- 传入宝石对象或者宝石特征，得到可兑换宝石列表
function tbStone:GetExchangeList(varFeature)
	local tbFeature = nil;
	if type(varFeature) == "userdata" then
		local _, tb = self:GetStoneExchangeFeature(varFeature);
		tbFeature = tb;
	else
		tbFeature = varFeature;
	end
	
	if not tbFeature then
		return;
	end

	-- 只需要传入special特征就可以了
	local tbGDPLList = KItem.GetSameFeatureStones(unpack(tbFeature));
	if not tbGDPLList or Lib:CountTB(tbGDPLList) == 0 then
		return;
	end
	
	-- 按颜色分类存储
	local tbItemList = {};
	for _, tbGDPL in pairs(tbGDPLList) do
		local tbProp = KItem.GetStoneProp(unpack(tbGDPL));
		local szColor = tbProp.szColor;
		tbItemList[szColor] = tbItemList[szColor] or {};
		
		if (tbProp.nStyle == self.EXCHANGE_STYLE_LIMIT) then
			table.insert(tbItemList[szColor], tbGDPL);
		end
	end
			
	return tbItemList;
end

-- 过滤中兑换列表中指定的GDPL
function tbStone:FilterExchangeList(tbList, varItem)
	local szGDPL;
	if type(varItem) == "string" then
		szGDPL = varItem;
	elseif type(varItem) == "table" then
		szGDPL = string.format("%d,%d,%d,%d", unpack(varItem));
	elseif type(varItem) == "userdata" then
		szGDPL = varItem.SzGDPL();
	end
	
	if not szGDPL then
		return tbList;
	end
	
	-- 避免tbList有重复GDPL的情况
	local nBegin = 1;
	local nMax = Lib:CountTB(tbList);
	while (nBegin <= nMax) do
		local _szGDPL = string.format("%d,%d,%d,%d", unpack(tbList[nBegin]));
		if szGDPL == _szGDPL then
			table.remove(tbList, nBegin);
			nMax = nMax - 1;
		else
			nBegin = nBegin + 1;
		end
	end
	
	return tbList;
end

-- 参数2对应的原石能否升级参数1对应的成品宝石
-- 参数类型：道具对象或者道具GDPL的tabel
function tbStone:CanUpgrade(varStone, varGem)
	if (Item.tbStone:GetOpenDay() == 0) then
		return 0, "Hệ thống bảo thạch chưa mở.";
	end
	local tbStoneInfo;		-- 宝石GDPL
	local tbGemInfo;		-- 原石GDPL
	if type(varStone) == "userdata" then
		tbStoneInfo = varStone.TbGDPL();
	elseif type(varStone) == "table" then
		tbStoneInfo = varStone;
	end
	
	if type(varGem) == "userdata" then
		tbGemInfo = varGem.TbGDPL();
	elseif (type(varGem) == "table") then
		tbGemInfo = varGem;
	end

	if not tbStoneInfo or not tbGemInfo then
		return 0, "Lỗi bên trong";
	end
		
	-- 满足升级的条件是原石的P值与宝石的P值一样，且原石的L值比宝石的L值大1
	
	--g值要相等
	if (tbStoneInfo[1] ~= Item.STONEITEM or tbGemInfo[1] ~= Item.STONEITEM) then
		return 0, "Chỉ có thể sử dụng Nguyên thạch để nâng cấp";
	end
	
	-- 要一个是宝石，一个是原石
	if (tbStoneInfo[2] ~= Item.STONE_PRODUCT or tbGemInfo[2] ~= Item.STONE_GEM) then
		return 0, "Chỉ có thể dùng Nguyên thạch có chung thuộc tính và cao hơn bảo thạch này 1 cấp mới có thể nâng cấp.";
	end
	
	-- p值要一样
	if (tbStoneInfo[3] ~= tbGemInfo[3]) then
		return 0, "Chỉ có thể dùng Nguyên thạch có chung thuộc tính và cao hơn bảo thạch này 1 cấp mới có thể nâng cấp.";
	end
	
	-- 宝石的等级要比成品的小1
	if (tbStoneInfo[4] ~= tbGemInfo[4] - 1) then
		return 0, "Chỉ có thể dùng Nguyên thạch có chung thuộc tính và cao hơn bảo thạch này 1 cấp mới có thể nâng cấp.";
	end
	
	return 1;
end

-- 获得原石拆解结果
function tbStone:GetBreakUpList(varStone)
	local tbGDPL;
	if type(varStone) == "userdata" then
		tbGDPL = varStone.TbGDPL();
	elseif type(varStone) == "table" then
		tbGDPL = varStone;
	end

	if not tbGDPL then
		return;
	end

	if (tbGDPL[1] ~= Item.STONEITEM or tbGDPL[2] ~= Item.STONE_GEM or 
		tbGDPL[4] < self.STONE_BREAKUP_LEVEL_LIMIT) then
		return;
	end

	local tbRes = {};
	tbRes.nCount = self.STONE_BREAKUP_RES_COUT;
	tbRes.tbGDPL = {tbGDPL[1], tbGDPL[2], tbGDPL[3], tbGDPL[4] - 1};
	
	return tbRes;
end

-- 是否可拆解
function tbStone:CanBreakUp(varStone, pPlayer)
	local pStone;
	if type(varStone) == "number" then
		pStone = KItem.GetObjById(varStone);
	elseif type(varStone) == "userdata" then
		pStone = varStone;
	end
	
	if not pStone then
		return 0;
	end
	
	local tbRes = self:GetBreakUpList(pStone);
	if not tbRes then
		return 0;
	end
	
	-- 检查申请状态
	if pStone.nLevel >= self.STONE_BREAKUP_LEVEL_APPLY then
		local nState = self:GetBreakUpState(pPlayer);
		if nState == 0 then
			pPlayer.Msg(self.STONE_BREAKUP_LEVEL_APPLY.."-cấp trở lên (Bảo thạch) muốn tách phải đến chỗ Thợ rèn bảo thạch.");
			return 0;
		elseif nState == 1 then
			pPlayer.Msg("Thời gian chưa đến, vui lòng chờ!");
			return 0;
		end	
	end
	
	-- 绑银是不是够
	local nMoney = pPlayer.GetBindMoney();
	if (nMoney < self.BREAKUP_COST_MONEY) then
		nMoney = pPlayer.nCashMoney + nMoney;
	end
	if (nMoney < self.BREAKUP_COST_MONEY) then
		pPlayer.Msg("Bạc không đủ, tách Nguyên thạch cần tốn "..Item:FormatMoney(self.BREAKUP_COST_MONEY).." Bạc (Ưu tiên trừ Bạc khóa).");
		return 0;
	end
	
	if pPlayer.CountFreeBagCell() < tbRes.nCount then
		pPlayer.Msg("Túi đã đầy, hãy để "..tbRes.nCount.." ô trống!");
		return 0;
	end
	
	return 1;
end

-- 获取拆解申请状态
-- 返回值0表示无申请或申请无效；1表示申请等待中；2表示申请成功，可以操作；
function tbStone:GetBreakUpState(pPlayer)
	local nValue = pPlayer.GetTask(self.TASK_GID_BREAKUP, self.TASK_SUBID_BREAKUP);
	if nValue == 0 or nValue > GetTime() or nValue + self.BREAKUP_MAX_TIME < GetTime() then
		return 0;	-- 没有申请，申请过期
	elseif nValue <= GetTime() and nValue + self.BREAKUP_MIN_TIME >= GetTime() then
		return 1;	-- 有申请，尚未到可操作状态
	else
		return 2;	-- 有申请，可操作状态
	end
end

-- 解绑检查函数
function tbStone:SwitchBind_Check(pDrop)
	
	-- 只有成品宝石才能解绑
	if pDrop.GetStoneType() ~= Item.STONE_PRODUCT then
		return 0;		
	end
	
	return 1;	
end

-- 判断某件装备里是否镶嵌有宝石
-- 第二个参数为空，表示对所有位置进行判断；第二个参数不为空，表示判断指定位置
-- 返回值-1,表示还没有打孔，0打孔了没镶嵌，1打孔且有镶嵌
function tbStone:IsFillInStone(pEquip, nPos)
	local nHoleCount = pEquip.GetHoleCount();
	if not nHoleCount or nHoleCount <= 0 then
		return -1;		-- 没打孔
	end
	
	-- 已经打过孔了，判断有没有镶嵌
	local bHaveStone = 0;
	if not nPos or nPos <= 0 or nPos > Item.nMaxHoleCount then
		
		for i = 1, Item.nMaxHoleCount do
			local nHoleType, nValue = pEquip.GetHoleStone(i);
			if nValue ~= 0 and nHoleType ~= 0 then
				bHaveStone = 1;
				break;
			end
		end
		
	else
		
		local _, nValue = pEquip.GetHoleStone(nPos);
		bHaveStone = nValue == 0 and 0 or 1;
	end
	
	
	return bHaveStone;
end

-- 解析装备孔内嵌入的宝石的GDPL
function tbStone:ParseStoneInfoInHole(nStone)
	local nG = Lib:LoadBits(nStone, unpack(self.tbHoleStoneBitParam[1]));
	local nD = Lib:LoadBits(nStone, unpack(self.tbHoleStoneBitParam[2]));
	local nP = Lib:LoadBits(nStone, unpack(self.tbHoleStoneBitParam[3]));
	local nL = Lib:LoadBits(nStone, unpack(self.tbHoleStoneBitParam[4]));
	
	return {nG, nD, nP, nL};
end

-- 把GDPL反向格式化成孔内存储的格式
-- TODO:注意溢出的问题
function tbStone:ReParseGDPLToHoleFormat(tbGDPL)
	local nValue = 0;
	nValue = Lib:SetBits(nValue, tbGDPL[1], unpack(self.tbHoleStoneBitParam[1]));
	nValue = Lib:SetBits(nValue, tbGDPL[2], unpack(self.tbHoleStoneBitParam[2]));
	nValue = Lib:SetBits(nValue, tbGDPL[3], unpack(self.tbHoleStoneBitParam[3]));
	nValue = Lib:SetBits(nValue, tbGDPL[4], unpack(self.tbHoleStoneBitParam[4]));
	
	return nValue;
end

-- 解析孔的信息
-- 最低字节在放孔的等级，次低字节存放孔的特殊标志
function tbStone:ParseHoleType(nHoleType)
	local nHoleLevel = Lib:LoadBits(nHoleType, 0, 7);
	local nSpecial = Lib:LoadBits(nHoleType, 8, 15);
	
	return nHoleLevel, nSpecial;
end

-- 获取宝石功能开放时间
-- 注意，这里面存的是天数
function tbStone:GetOpenDay()
	if (KGblTask.SCGetDbTaskInt(DBTASK_STONE_FUNCTION_OPENFLAG) ~= 1) then
		return 0;
	end
	local nDay = KGblTask.SCGetDbTaskInt(DBTASK_STONE_FUNCTION_OPENDAY);
	if (nDay ~= 0) then
		nDay = Item.tbStone.nAbsoluteOpenDay;				-- 20110712
	end
	return nDay;
end


-- 获取宝石能提供的战斗力
function tbStone:GetFightPower(varStone)
	local nStoneLevel = 0;
	local tbStoneProp;
	if type(varStone) == "table" then
		nStoneLevel = varStone[4];
		tbStoneProp = KItem.GetStoneProp(unpack(varStone));
	elseif type(varStone) == "userdata" then
		nStoneLevel = varStone.nLevel;
		tbStoneProp = varStone.GetStoneProp();
	end
	
	if tbStoneProp and tbStoneProp.nStyle == 1 then
		local nAddEx = 0;
		if (nStoneLevel > 1) then
			nAddEx = nStoneLevel - 1;
		end
		nStoneLevel = self.SKILLSTONE_STAR_CAL_LEVEL + nAddEx;
	elseif tbStoneProp and tbStoneProp.nStyle == 4 then	--充值送的经验宝石
		nStoneLevel = self.EXPSTONE_STAR_CAL_LEVEL;
	elseif tbStoneProp and tbStoneProp.nStyle == 5 then	--美女海选的宝石
		nStoneLevel = self.SKILLSTONE_STAR_CAL_LEVEL;   
	end
	
	-- 等于宝石等级减1
	local nFightPower = nStoneLevel - 1;
	
	return nFightPower < 0 and 0 or nFightPower;
end

-- 宝石星级，避免小数，返回值比实际际扩大了两倍
function tbStone:GetStarLevel(varStone)
	local nStoneLevel;
	local tbStoneProp;
	if type(varStone) == "userdata" then
		nStoneLevel = varStone.nLevel;
		tbStoneProp = varStone.GetStoneProp();
	elseif type(varStone) == "table" then
		nStoneLevel = varStone[4];
		tbStoneProp = KItem.GetStoneProp(unpack(varStone));
	end
	
	if not nStoneLevel then
		return;
	end
	
	if tbStoneProp and tbStoneProp.nStyle == 1 then
		local nAddEx = 0;
		if (nStoneLevel > 1) then
			nAddEx = nStoneLevel - 1;
		end
		nStoneLevel = self.SKILLSTONE_STAR_CAL_LEVEL + nAddEx;
	elseif tbStoneProp and tbStoneProp.nStyle == 4 then	--充值送的经验宝石
		nStoneLevel = self.EXPSTONE_STAR_CAL_LEVEL;
	elseif tbStoneProp and tbStoneProp.nStyle == 5 then	--美女海选的宝石
		nStoneLevel = self.SKILLSTONE_STAR_CAL_LEVEL;
	end
	
	local nStarLevel = 0;
	if nStoneLevel == 1 then
		nStarLevel = self.STONE_STAR_LEVEL_1;
	else
		nStarLevel = self.STONE_STAR_LEVEL_2 +( nStoneLevel - self.STONE_STAR_LEVEL_BEGINGROW) * self.STONE_STAR_LEVEL_GROWTH;
	end
		
	return nStarLevel;
end

-- 宝石星级配置表
function tbStone:LoadStarLevelReprsentFile()
	local tbFile = Lib:LoadTabFile(self.STAR_LELVEL_REPRESENT_FILE);
	if not tbFile then
		assert(false, self.STAR_LELVEL_REPRESENT_FILE .. " load failed！");
		return;
	end
	
	self.tbStarLevel = {};
	for i, tbData in pairs(tbFile) do
		local nStarLevel = assert(tonumber(tbData.STAR_LEVEL));
		local tbInfo =
		{
			nStarLevel 	= nStarLevel,
			szNameColor = tbData.NAME_COLOR;
			szTransIcon = tbData.TRANSPARENCY_ICON;
			nEmptyStar 	= tonumber(tbData.EMPTY_STAR) or 0;
			nFillStar	= tonumber(tbData.FILL_STAR) or 0;
		};
		
		self.tbStarLevel[nStarLevel] = tbInfo;
	end
end

Item.tbStone:LoadStarLevelReprsentFile()