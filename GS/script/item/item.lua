-- Item脚本类

Require("\\script\\item\\define.lua");

------------------------------------------------------------------------------------------
-- initialize

-- Item基础模板，详细的在default.lua中定义
if not Item.tbClassBase then
	Item.tbClassBase = {};
end

-- 防止重载脚本的时候模板库丢失
if not Item.tbClass then
	-- Item模板库
	Item.tbClass =
	{
		-- 默认模板，可以提供直接使用
		["default"]	= Item.tbClassBase,
		[""]		= Item.tbClassBase,
	};
end


Item.TASK_OWNER_TONGID = 1; -- General Info里的第一项记录绑定的帮会ID

--货币单位显示
Item.tbTipPriceUnit = 
{
	[1] = "Bạc",		--银两
	[2] = "",			--福缘
	[3] = " %s",		-- 金币替代物品（魂石，月影之石，情花等）
	[4] = "Điểm Quân Nhu",		--积分
	[5] = "",			--贡献度
	[6] = "",			--联赛荣誉点数
	[7] = "Bạc khóa",			--绑定银两
	[8] = " điểm độ bền cơ quan",		--机关耐久度货币类型
	[9] = "Quỹ xây dựng bang hội",		-- 帮会建设资金
	[10]= "%s",					-- 数值货币
	[11]= "Bạc khóa liên server"			-- 跨服绑银
}
------------------------------------------------------------------------------------------
-- interface

-- 系统调用，默认的道具生成信息初始化（服务端&客户端）
function Item:InitGenInfo(szClassName)
	local tbClass = self.tbClass[szClassName];
	if (not tbClass) then
		tbClass = self.tbClass["default"];
	end
	return	tbClass:InitGenInfo();
end

-- 系统调用，检查是否允许使用道具（服务端&客户端）
function Item:CheckUsable(szClassName, nParam)
	local nMapId = -1;
	if (MODULE_GAMESERVER) then
		nMapId = me.nMapId;
	else
		nMapId = me.nTemplateMapId;
	end
	--[[
  	local nCanUse, szMsg = self:CheckIsUseAtMap(nMapId, it.dwId);
	if nCanUse ~= 1 then
		me.Msg(szMsg);
		return 0;
	end]]--

	if szClassName == "localmedicine" then
		szClassName = "medicine";
	end
	local tbClass = self.tbClass[szClassName];
	if (not tbClass) then
		tbClass = self.tbClass["default"];
	end
	return	tbClass:CheckUsable(nParam);
end

-- 当右键点击任何一个物品时，都会调用这里（仅限服务端）
function Item:OnUse(szClassName, nParam)
	if szClassName == "localmedicine" then
		szClassName = "medicine";
	end
	-- if me.IsTraveller() == 1 then
		-- return self:OnTravelUse(szClassName, nParam);
	-- end
	local tbClass = self.tbClass[szClassName];
	local nOnUseFlag = 1;
	if (not tbClass) or (tbClass.OnUse == Item.tbClassBase.OnUse) then
		nOnUseFlag = 0; --原来没有OnUse
	end 
	if (not tbClass) then
		tbClass = self.tbClass["default"];
	end
	local szGenIdName = string.format("%s,%s,%s,%s", it.nGenre, it.nDetail, it.nParticular, it.nLevel);
	if EventManager.tbFun:CheckItemClassEventIsEffect(szClassName, 1) == 1 or EventManager.tbFun:CheckItemClassEventIsEffect(szGenIdName, 2) == 1 then
		--发现有嵌入事件
		local tbOpt = {};
		local tbEventClass = EventManager:GetItemClass(szClassName);
		for nEventId, tbPart in pairs(tbEventClass) do
			for nPartId, tbEvent in pairs(tbPart) do
				if EventManager.tbFun:CheckItemPartEventIsEffect(tbEvent) == 1 then
					table.insert(tbOpt, {tbEvent.tbEventPart.szName, self.OnUseEventManagerEx, self, tbEvent, it.dwId, nParam})	
				end
			end
		end
		local tbEventClass = EventManager:GetItemIdClass(szGenIdName);
		for nEventId, tbPart in pairs(tbEventClass) do
			for nPartId, tbEvent in pairs(tbPart) do
				if EventManager.tbFun:CheckItemPartEventIsEffect(tbEvent) == 1 then
					table.insert(tbOpt, {tbEvent.tbEventPart.szName, self.OnUseEventManagerEx, self, tbEvent, it.dwId, nParam})	
				end
			end
		end
		if nOnUseFlag == 0 then
			if #tbOpt == 1 then
				local tbCallBack = {unpack(tbOpt[1], 2)};
				Lib:CallBack(tbCallBack);
				return 0;
			end
			table.insert(tbOpt, {"Kết thúc đối thoại"});
			Dialog:Say("Xin chào, ta có thể giúp gì cho ngươi?", tbOpt);
			return 0;
		else
			table.insert(tbOpt, {"Ta muốn xem tính năng khác", self.OnUseEventManagerEx, self, tbClass, it.dwId, nParam});
			table.insert(tbOpt, {"Kết thúc đối thoại"});
			Dialog:Say("Xin chào, ta có thể giúp gì cho ngươi?", tbOpt);
		end
		return 0;
	end
	return	tbClass:OnUse(nParam);
end

--活动系统嵌入
function Item:OnUseEventManagerEx(tbClass, dwId, nParam)
	local pItem = KItem.GetObjById(dwId);
	if not pItem then
		return 0;
	end
	Setting:SetGlobalObj(nil, nil, pItem);
	if me.IsHaveItemInBags(pItem) ~= 1 then
		Setting:RestoreGlobalObj();	
		return 0;
	end
	if tbClass:OnUse(nParam) == 1 then
		if it.nCount <= 1 then
			me.DelItem(it, Player.emKLOSEITEM_USE);
		else
			it.SetCount(it.nCount - 1, Item.emITEM_DATARECORD_REMOVE);
		end
	end
	Setting:RestoreGlobalObj();	
end

function Item:OnClientUse(szClassName)
	local tbClass = self.tbClass[szClassName];
	if (not tbClass) then
		tbClass = self.tbClass["default"];
	end
	return	tbClass:OnClientUse();
end

-- 当鼠标移动到任何一个物品图标上时，都触发这里获取Tip（客户端）
function Item:GetTip(szClassName, nState, szBindType)
	if szClassName == "localmedicine" then
		szClassName = "medicine";
	end
	local tbClass = self.tbClass[szClassName];
	if (not tbClass) then
		tbClass = self.tbClass["default"];
	end
	local nUnLockIntervalTimes = KLib.Number2Int(it.GetUnlockTime()) or 0;
	local nNowTime = GetTime();	
	local szTip = "";
	local nTipState = nState;
	local nShopId = me.GetShopId();
	if (nState == Item.TIPS_SHOP) and Shop:GetGoods(nShopId, it.nIndex) then
		nTipState = Item.TIPS_GOODS;
	end
	
	local tbEnhRandMASS, tbEnhEnhMASS, nEnhStarLevel, nEnhNameColor;
	if tbClass.CalcEnhanceAttrib then		-- TODO: zyh: 很龊的方法……暂时先这样做
		tbEnhRandMASS, tbEnhEnhMASS, nEnhStarLevel, nEnhNameColor = tbClass:CalcEnhanceAttrib(nTipState);
		local szTitel = tbClass:GetTitle(nTipState, nEnhNameColor);
		szTip = szTip..tbClass:GetTip(nTipState, tbEnhRandMASS, tbEnhEnhMASS);
		if szTip and szTip ~= "" then
			szTip = "\n\n"..szTip;
		end		
		szTip = self:Tip_Prefix(nTipState, 0, szBindType)..szTip..self:Tip_Suffix(nState);
		if nUnLockIntervalTimes ~= 0 and it.GetLockIntervale() ~= 0 then
			if nUnLockIntervalTimes == -1 then
				szTip = szTip.."\n\n<color=green>Trạng thái khóa, không thể giao dịch"
			elseif nUnLockIntervalTimes - nNowTime > 0 then
				szTip =szTip.."\n\n<color=green>Trạng thái khóa giao dịch, không thể giao dịch\nĐã đăng ký mở khóa, đến "..os.date("%Y/%m/%d %H:%M:%S", nUnLockIntervalTimes).." tự động mở khóa<color>";
			end
		end
		return szTitel, szTip, it.szViewImage;
	else
		local szTitel = tbClass:GetTitle(nTipState); --物品名称
		local szTip = "";
		szTip = szTip..tbClass:GetTip(nTipState);
		if szTip and szTip ~= "" then
			szTip = "\n\n"..szTip;
		end		
		szTip = self:Tip_Prefix(nTipState, 0, szBindType)..szTip..self:Tip_Suffix(nState);
		if nUnLockIntervalTimes ~= 0 and it.GetLockIntervale() ~= 0 then
			if nUnLockIntervalTimes == -1 then
				szTip = szTip.."\n\n<color=green>Trạng thái khóa, không thể giao dịch"
			elseif nUnLockIntervalTimes - nNowTime > 0 then
				szTip =szTip.."\n\n<color=green>Trạng thái khóa giao dịch, không thể giao dịch\nĐã đăng ký mở khóa, đến "..os.date("%Y/%m/%d %H:%M:%S", nUnLockIntervalTimes).." tự động mở khóa<color>";
			end
		end
		return szTitel, szTip, it.szViewImage;
	end
end

function Item:GetCompareTip(szClassName, nState, szBindType)
	local szTitle, szTip, szPic = self:GetTip(szClassName, nState, szBindType);
	local szCmpTitle = "";
	local szCmpTip = "";
	local szCmpPic = "";
	if it.IsEquip() == 1 then
		local nEquipPos = it.nEquipPos;
		if nEquipPos == -1 and it.nDetail == Item.EQUIP_ZHENYUAN then
			nEquipPos = Item.EQUIPPOS_ZHENYUAN_MAIN;	-- 真元的话，始终跟主真元格子的比
		end
		
		local pItem = nil;
		if (nEquipPos >= Item.EQUIPPOS_NUM) then
			pItem = me.GetItem(Item.ROOM_PARTNEREQUIP, nEquipPos - Item.EQUIPPOS_NUM, 0);
		else
			pItem = me.GetItem(Item.ROOM_EQUIP, nEquipPos, 0);
		end
		
		if pItem and pItem.dwId ~= it.dwId then
			szCmpTitle, szCmpTip, szCmpPic = pItem.GetTip(Item.TIPS_NORMAL);
			szCmpTip = szCmpTip.."\n<color=yellow><Trang bị hiện tại><color>";
		end
	end
	return szTitle, szTip, szPic, szCmpTitle, szCmpTip, szCmpPic;
end

-- 判断一个物品是否可以被拣起（服务端）
function Item:IsPickable(szClassName, nObjId)
	local tbClass = self.tbClass[szClassName];
	if (not tbClass) then
		tbClass = self.tbClass["default"];
	end
	-- if me.IsTraveller() == 1 then
		-- if Item:CheckTravelItem(it.nGenre, it.nDetail, it.nParticular, it.nLevel) ~= 1 then
			-- me.Msg("Đạo cụ không phải liên server, không thể nhặt!");
			-- return 0;--非跨服旅行道具旅行者不可捡起
		-- end
	-- end
	if Item:CheckIsLocalMedicine(it.nGenre, it.nDetail, it.nParticular, it.nLevel) == 1 then
		if Item:CanGetLocalMedicine(it.nCount, 1) ~= 1 then
			return 0;
		end
	end
	return	tbClass:IsPickable(nObjId);
end

-- 当一个物品被拣起时会处理这里，同决定是否删除该物品（服务端）
function Item:PickUp(szClassName, nX, nY)
	local tbClass = self.tbClass[szClassName];
	if (not tbClass) then
		tbClass = self.tbClass["default"];
	end
	return	tbClass:PickUp(nX, nY);
end

-- 计算道具价值量相关信息，仅在道具生成时执行一次
-- 返回值：价值量，价值量星级，名字颜色，透明图层路径
function Item:CalcValueInfo(szClassName)
	local tbClass = self.tbClass[szClassName];
	if (not tbClass) then
		tbClass = self.tbClass["default"];
	end
	return tbClass:CalcValueInfo();
end

-----------------------------------------------------------------------------------------
-- public

-- 取得特定类名的Item模板
function Item:GetClass(szClassName, bNotCreate)
	local tbClass = self.tbClass[szClassName];
	if (not tbClass) and (bNotCreate ~= 1) then		-- 如果没有bNotCreate，当找不到指定模板类时会自动建立新模板类
		tbClass	= Lib:NewClass(self.tbClassBase);	-- 新模板从父模板类派生
		self.tbClass[szClassName] = tbClass;		-- 加入到模板库里面
	end
	return	tbClass;
end

-- 继承特定类名的Item模板
function Item:NewClass(szClassName, szParent)
	if (self.tbClass[szClassName]) then				-- 指定模板类必须还不存在
		print("[ITEM] 类"..tostring(szClassName).."已存在，请检查脚本！");
		return;
	end
	local tbParent = self.tbClass[szParent];
	if (not tbParent) then							-- 父模板类必须已经存在
		print("[ITEM] 父类"..tostring(szParent).."不存在，请检查脚本！");
		return;
	end
	local tbClass = Lib:NewClass(tbParent);			-- 从父模板类派生
	self.tbClass[szClassName] = tbClass;			-- 加入到模板库里面
	return	tbClass;
end

-- 转换装备位置为对应的切换装备位置
function Item:EqPos2EqExPos(nEquipPos)
	if (nEquipPos < 0) or (nEquipPos > self.EQUIPEXPOS_NUM) then
		return	-1;
	end
	return	nEquipPos;
end

-- 转换切换装备位置为对应的装备位置
function Item:EqExPos2EqPos(nEquipExPos)
	if (nEquipExPos < 0) or (nEquipPos > self.EQUIPEXPOS_NUM) then
		return	-1;
	end
	return	nEquipExPos;
end

function Item:IsTry(nEquipPos)
	if (nEquipPos >= Item.EQUIPPOS_HEAD and nEquipPos <= Item.EQUIPPOS_MASK) then
		return 1;
	else
		return 0;
	end
end

-- 把剑侠币数值格式化为字符串（显示“万”、“亿”等字）
function Item:FormatMoney(nMoney)
	local szMoney = "";
	if (not nMoney) or (nMoney < 0) then
		return	"Vô hiệu";								-- 价钱小于0，出错
	end
	if (nMoney >= 100000000) then
		szMoney = szMoney..tostring(math.floor(nMoney / 100000000)).."Ức";
		nMoney = nMoney % 100000000;
	end
	if (nMoney >= 10000) then
		szMoney = szMoney..tostring(math.floor(nMoney / 10000)).."Vạn";
		nMoney = nMoney % 10000;
	end
	if (nMoney > 0) then
		szMoney = szMoney..tostring(nMoney);
	end
	if (szMoney == "") then
		szMoney = "0";
	end
	return	szMoney;
end

function Item:Tip_FixSeries()
	-- local szTip = "\nThích hợp cho "
	-- if Item.tbSeriesFix[it.nEquipPos] and it.nSeries > 0 then
		-- return szTip..Item.TIP_SERISE[Item.tbSeriesFix[it.nEquipPos][it.nSeries]];--.."使用";
	-- end
	return "";
end

function Item:FindFreeCellInRoom(nRoom, nWidth, nHeight)
	for nY = 0, nHeight - 1 do
		for nX = 0, nWidth - 1 do
			if me.GetItem(nRoom, nX, nY) == nil then
				return nX, nY;
			end
		end
	end
end
function Item:FormatMoney2Style(nMoney)
	
	if (not nMoney) or nMoney < 0 then
		return "Không hợp lệ";
	end
	local k = 0;
  	local nFormatted = nMoney
  	while true do  
  	  nFormatted, k = string.gsub(nFormatted, "^(-?%d+)(%d%d%d)", '%1,%2')
   	 if (k==0) then
    	  break
    	end
  	end
  return nFormatted;
end

function Item:Tip_Prefix(nState, nEnhStarLevel, szBindType)
	local szPreTip = "";
	if it.IsEquip() == 1 then
		szPreTip = szPreTip..self:Tip_StarLevel(nState, nEnhStarLevel);
		szPreTip = szPreTip..self:Tip_FightPower(nState);
		szPreTip = szPreTip..self:Tip_BindInfo(nState, szBindType);	-- 绑定状态
		szPreTip = szPreTip..self:Tip_Changeable(nState)..self:Tip_CanBreakUp(nState);  -- 可否兑换
		if it.IsZhenYuan() ~= 1 then
			szPreTip = szPreTip..self:Tip_GetRefineLevel();
			szPreTip = szPreTip..self:Tip_GetCastInfo();
		end
		szPreTip = szPreTip..self:Tip_FixSeries(nState);
	else
		if (it.GetStoneType() ~= 0) then
			szPreTip = szPreTip..Item.tbClass["gem"]:Tip_StarLevel();
			szPreTip = szPreTip..self:Tip_FightPower();
		end
		szPreTip = szPreTip..self:Tip_BindInfo(nState, szBindType);
		szPreTip = szPreTip..self:Tip_Changeable(nState);  -- 可否兑换
	end
	return szPreTip;
end

function Item:Tip_GetRefineLevel(nState)
	local szTip = " ";
	
	local nRefineLevel = it.nRefineLevel; 
	if it.IsExEquip() == 1 then
		nRefineLevel = it.GetEquipExValue(Item.ITEM_TASKVAL_EX_SUBID_ExRefLevel);
	end	
	
	if nRefineLevel == 0 then
		return szTip.."Chưa luyện hóa";
	elseif nRefineLevel > 0 then
		return szTip.."Luyện hóa <color=gold>cấp "..nRefineLevel.."<color>"
	else
		return szTip.."Không thể luyện hóa";
	end
end

function Item:Tip_GetCastInfo(nState)
	local szTip = "";
	
	if it.IsExEquip() == 1 then
		local nCastLevel = it.GetEquipExValue(self.ITEM_TASKVAL_EX_SUBID_CastLevel);
		if nCastLevel == 0 then
			szTip = it.nEquipCategory == 0 and " Không thể tinh chú" or " Chưa tinh chú";
		elseif nCastLevel == 1 then
			szTip = " Tinh chú trác việt";
		elseif nCastLevel == 2 then
			szTip = " Tinh chú sử thi";
		end
	end
	
	return szTip;
end

function Item:Tip_Changeable(nState)
	local szTip = "\n";
	if (nState == Item.TIPS_PREVIEW) then
		return szTip;
	elseif (nState == Item.TIPS_BINDGOLD_SECTION) then
		return szTip.."Không thể đổi";
	elseif (nState == Item.TIPS_INTEGRAL_SECTION) then
		return szTip.."Không thể đổi";
	end
	
	if Item:CalcChange({it}) > 0 then
		return szTip.."Có thể đổi";
	else
		return szTip.."Không thể đổi";
	end
end

function Item:Tip_Suffix(nState)
	local szTip = "";
	szTip = szTip..self:Tip_Intro();
	szTip = szTip..self:Tip_UseTime();
	szTip = szTip..self:Tip_Help();
	szTip = szTip..self:Tip_ReqLevel();
	szTip = szTip..self:Tip_Price(nState);
	szTip = szTip..self:Tip_Timeout();
	return	szTip;
end

function Item:Tip_StarLevel(nState, nEnhStarLevel)	-- 获得Tip字符串：装备价值量星级
	local tbSetting = Item.tbExternSetting:GetClass("value");
	--if (nState == Item.TIPS_PREVIEW) then
	--	return	"";			-- 属性预览状态时不显示价值量星级
	--end

	local szTip = "\n  ";
	local nStarLevel = it.nStarLevel;
	local szFillStar = "";
	local szEmptyStar = "";
	if tbSetting and tbSetting.m_tbStarLevelInfo and tbSetting.m_tbStarLevelInfo[nStarLevel] then
		szFillStar = string.format("<pic=%s>", tbSetting.m_tbStarLevelInfo[nStarLevel].nFillStar - 1);
		szEmptyStar = string.format("<pic=%s>", tbSetting.m_tbStarLevelInfo[nStarLevel].nEmptyStar - 1);
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
	if (it.nStarLevel % 2 ~= 0) then
		szTip = szTip..szEmptyStar;
	end
	return	szTip;

end

function Item:Tip_BindInfo(nState, szBindType)
	local szTip = "";
	if it.IsEquip() == 1 then
		local nPos = KItem.EquipType2EquipPos(it.nDetail)
		if nPos < 0 and it.nDetail == Item.EQUIP_ZHENYUAN then
			nPos = me.GetZhenYuanPos();
		end
		szTip = Item.EQUIPPOS_NAME[nPos];
		if nPos == self.EQUIPPOS_WEAPON and self.WEAPON_NAME[it.nEquipCategory] then
			szTip = szTip.."("..self.WEAPON_NAME[it.nEquipCategory]..") ";
		else
			szTip = szTip.." ";
		end
	end
	local nShopId = me.GetShopId();
	local nGoodsId = Shop:GetGoods(nShopId, it.nIndex);
	local nCurrencyType	= 0;
	if (nGoodsId) then		-- 只有买入时有不同的货币单位
		nCurrencyType	= me.nCurrencyType;
	end
	
	if (szBindType) then
		szTip = szTip..szBindType;
	elseif (nState == Item.TIPS_GOODS and nGoodsId and (KItem.IsGetBindType(nGoodsId) == 1 or nCurrencyType == 7)) then
		szTip	= szTip.."  Nhận khóa";
	else
		local nBindType = it.nBindType;
		if (nState == Item.TIPS_BINDGOLD_SECTION) then
			szTip = szTip.."  Nhận khóa";
		elseif (nState == Item.TIPS_INTEGRAL_SECTION) then
			local szTipBindType = "  Nhận khóa";
			local tbTemp = it.GetTempTable("IbShop");
			if tbTemp and tbTemp[it.nIndex] then
				local tbWareInfo = me.IbShop_GetWareInf(tbTemp[it.nIndex]);
				if (tbWareInfo and tbWareInfo.nBind >= 0) then
					if tbWareInfo.nBind == 0 then
						if	(Item.BIND_NONE  == nBindType or Item.BIND_NONE_OWN == nBindType) then
							szTipBindType = "  Không khóa";
						elseif	(Item.BIND_GET   == nBindType) then
							szTipBindType = "  Nhận khóa";
						elseif	(Item.BIND_EQUIP == nBindType) then
							szTipBindType = "  Trang bị khóa";
						elseif  (Item.BIND_OWN == nBindType) then
							szTipBindType = "  Nhận khóa";
						end
					end
				end
			end
			szTip = szTip..szTipBindType;
		elseif (nState ~= Item.TIPS_PREVIEW) and (1 == it.IsBind()) then	-- 属性预览状态时只按照nBindType显示
			szTip = szTip.."  Đã khóa";
			if (it.nGenre == 24) then
				szTip = szTip.."(<color=greenyellow>Có thể mở khóa<color>)";
			end
		elseif	(Item.BIND_NONE  == nBindType or Item.BIND_NONE_OWN == nBindType) then
			szTip = szTip.."  Không khóa";
		elseif	(Item.BIND_GET   == nBindType) then
			szTip = szTip.."  Nhận khóa";
		elseif	(Item.BIND_EQUIP == nBindType) then
			szTip = szTip.."  Trang bị khóa";
		elseif  (Item.BIND_OWN == nBindType) then
			szTip = szTip.."  Nhận khóa";
		end
	end
	if szTip ~= "" then
		szTip = "\n"..szTip;
	end
	return	szTip;
end

function Item:Tip_FightPower(nState)	-- 获得Tip字符串：战斗力
	if (1 ~= Player.tbFightPower:IsFightPowerValid()) then
		return "";
	end
	local nOpen = KGblTask.SCGetDbTaskInt(DBTASK_ENHANCESIXTEEN_OPEN);
	
	local nFightPower, nPowerEncPreview = self:GetItemFightPower();
	local szTip = "";
	if (nFightPower) then
		nFightPower = math.floor(nFightPower * 100) / 100;
		szTip = string.format("\n<color=blue>Lực chiến +%g<color>", nFightPower);
		if it.szClass == "zhenyuan" then
			local varRank = Item.tbZhenYuan:GetRank(it);
			if varRank == 0 then
				varRank = "Không có";
			end
			szTip = szTip..string.format("<color=blue>   Hạng: %s<color>", varRank);
		end
		
		if (nState == Item.TIPS_ENHANCE and nPowerEncPreview) and (nOpen == 0 or (nOpen == 1 and it.nEnhTimes < Item.nEnhTimesLimitOpen - 1))  then
			nPowerEncPreview = math.floor(nPowerEncPreview * 100) / 100;
			szTip = szTip .. string.format(" <color=blue>→ +%g<color>", nPowerEncPreview);
		end
		szTip = szTip .. "\n";
	end
	return szTip;
end

function Item:Tip_CanBreakUp(nState)
	local szTip = "";
	local nGTPCost, tbStuff, tbExp = Item:CalcBreakUpStuff(it);
	if (nGTPCost <= 0) or (#tbStuff <= 0) then
		szTip = szTip.." Không thể tách";
	else
		szTip = szTip.." Có thể tách"
	end
	if szTip ~= "" then
		szTip = ""..szTip;
	end
	return	szTip;
end

function Item:Tip_Intro()
	local szIntro = it.szIntro;	
	if szIntro and szIntro ~= "" then
		return "\n\n"..szIntro;
	end
	return "";
end

function Item:Tip_Help()			-- 获得Tip字符串：帮助文字
	if it.szHelp and it.szHelp ~= ""then
		return	"\n\n"..it.szHelp;
	end
	return "";
end

function Item:Tip_UseTime()		-- 获得Tip字符串：使用时间
	local szTip = "";
	local nTime = GetCdTime(it.nCdType) / Env.GAME_FPS;

	if (nTime ~= 0) then

		local nHour = math.floor(nTime / 3600);
		nTime = nTime % 3600;
		local nMin  = math.floor(nTime / 60);
		nTime = nTime % 60;
		local nSec  = math.floor(nTime * 10) / 10;		-- 精确到小数点后一位

		local szTime = "";
		if (nHour ~= 0) then
			szTime = szTime..nHour.."Giờ";
		end
		if (nMin ~= 0) then
			szTime = szTime..nMin.." phút";
		end
		if (nSec ~= 0) then
			szTime = szTime..nSec.."Giây";
		end

		szTip = "\n\n"..szTip.."Giãn cách sử dụng: "..szTime;

	end

	return	szTip;
end

function Item:Tip_ReqLevel()

	if (it.nReqLevel <= 0) then
		return	"";
	end

	local szTip = "";
	local nRed = 0;

	if (me.nLevel < it.nReqLevel) then
		nRed = 1;
	end

	if (nRed == 1) then
		szTip = szTip.."<color=red>";
	end

	szTip = "\n"..szTip.."Yêu cầu cấp: "..it.nReqLevel.."";

	if (nRed == 1) then
		szTip = szTip.."<color>";
	end

	return	szTip;

end

--临时增加使用, 2008.11.18后将被删除 dzh
function Item:SendDisableTrade(szMsg)
	--me.Msg("由于披风过于贵重，运送过程需十分小心，因此最近一批披风要等到最近一次维护后才能送到。");
end

function Item:Tip_Price(nState)	
	local szTip = "";
 	local szUnit = "";
	
	if (nState == Item.TIPS_SHOP) then	-- NPC交易状态显示物品价格
		local nShopId = me.GetShopId();
		local pGoodsId = Shop:GetGoods(nShopId, it.nIndex);
		
		local nCurrencyType	= 1;	-- 卖出永远是剑侠币
		if pGoodsId then		-- 只有买入时有不同的货币单位
			nCurrencyType = me.nCurrencyType;
		end

		szUnit = self.tbTipPriceUnit[nCurrencyType] or "";
		szTip = szTip.."<color=yellow>";

		if pGoodsId then
			local tbGoods = me.GetShopBuyItemInfo(pGoodsId);
			local nPrice = tbGoods.nPrice;
			local nCamp = tbGoods.nReputeCamp;
			local nClass = tbGoods.nReputeClass; 
			local nLevel = tbGoods.nReputeLevel;
			local nRequireHonor = tbGoods.nHonour;
			local nFightPowerRankNeed = tbGoods.nFightPowerRank;
			local nOfficialLevel = tbGoods.nOfficialLevel;
			local nEnergy = tbGoods.nEnergy;
			local nBuyPlayerLevel = tbGoods.nBuyPlayerLevel;

			-- 实物货币单位
			if (nCurrencyType == 3) then
				local nItemCoinIndex = tbGoods.ItemCoinIndex;
				if (szUnit ~= "") then
					szUnit = string.format(szUnit, Shop:GetItemCoinUnit(nItemCoinIndex));
				end
			end
			
			-- 数值货币单位
			if (nCurrencyType == 10) then
				local nValueCoinIndex = tbGoods.ValueCoinIndex;
				if (szUnit ~= "") then
					szUnit = string.format(szUnit, Shop:GetValueCoinUnit(nValueCoinIndex));
				end
			end
			
			szTip = "\n\n"..szTip.."<color=yellow>Giá mua: "..self:FormatMoney(nPrice)..szUnit.."<color>";
			if nCurrencyType == 9 and nEnergy > 0 then
				szTip = szTip..string.format("\nTiêu hao %d sức hành động bang hội", nEnergy);
			end
			-- 声望需求
			local bConditionLevel = false;
			if nLevel > 0 then
				bConditionLevel = true;
				local tbInfo = KPlayer.GetReputeInfo();
				if me.GetReputeLevel(nCamp, nClass) >= nLevel then
					szTip = szTip.."\n\n<color=white>Điều kiện mua:";
				else
					szTip = szTip.."\n\n<color=red>Điều kiện mua:";
				end
				if tbInfo then
					szTip = szTip..tbInfo[nCamp][nClass].szName.."Danh vọng đạt đến cấp "..tbInfo[nCamp][nClass][nLevel].szName.."["..nLevel.."]";
				else
					szTip = szTip.."Yêu cầu danh vọng - chưa biết";
				end
				szTip = szTip.."<color>";
			end
			
			--增加荣誉支持
			--local nRequireHonor = 0 --debug
			if nRequireHonor > 0 then
				if me.GetHonorLevel() >= nRequireHonor then
					szTip = szTip.."\n<color=white>";
				else
					szTip = szTip.."\n<color=red>";
				end
				if bConditionLevel == false then
					szTip = szTip.."\nĐiều kiện mua:";
				end
				
				local strcondfmt = "\nThỏa mãn 1 trong các điều kiện sau\nThủ Lĩnh đạt cấp %d\nVõ Lâm đạt cấp %d\nTài Phú đạt cấp %d";
				local strcond = string.format(strcondfmt, nRequireHonor, nRequireHonor, nRequireHonor); 
				szTip = szTip..strcond;
				
				szTip = szTip.."<color>";
			end
			if nOfficialLevel > 0 then
				local nLevel = me.GetOfficialLevel()
				local szColor = "white";
				if nOfficialLevel > nLevel then
					szColor = "red";
				end
				szTip = szTip..string.format("\n<color=%s>Cấp quan hàm đạt cấp %d<color>", szColor, nOfficialLevel);
			end

			if (nBuyPlayerLevel > 0) then
				local szColor = "white";
				if (me.nLevel < nBuyPlayerLevel) then
					szColor = "red";
				end
				szTip = szTip..string.format("\n<color=%s>Nhân vật đạt cấp %d<color>", szColor, nBuyPlayerLevel);
			end
			
			if nFightPowerRankNeed > 0 then
				local nRank = Player.tbFightPower:GetFightPowerRank();
				local szColor = "white";
				if nRank <= 0 or nRank > nFightPowerRankNeed then
					szColor = "red";
				end
				szTip = szTip..string.format("\n<color=%s> Lực chiến %d điểm<color>", szColor, nFightPowerRankNeed);
			end
		else
			local nPrice = me.GetRecycleItemPrice(it)
			if nPrice then
				szTip = "\n"..szTip.."<color=yellow>Giá mua lại: "..nPrice..szUnit.."<color>";
			else
				nPrice = GetSalePrice(it);
				if it.IsForbitSell() == 1 then
					szTip = "\n<color=red>Không thể bán<color>";
				else
          --卖道具需要判断道具的绑定属性
					if 1 == it.IsBind() or it.nGenre == 24 then
						szUnit = "Bạc khóa";
					else
						szUnit = "Bạc";
					end
					szTip = "\n"..szTip.."<color=yellow>Giá bán: "..self:FormatMoney(nPrice)..szUnit.."<color>";
					if it.nEnhTimes > 0 or it.IsEquipHasStone() == 1 then -- 强化过或者有镶嵌宝石的装备不能售店
						szTip = szTip.."<color=red>(Không bán được)<color>";
					elseif it.IsPartnerEquip() == 1 and it.IsBind() == 1 then	-- 锁定的同伴装备不能卖店
						szTip = szTip.."<color=red>(Không bán được)<color>";
					end
				end
			end
		end
		
	elseif (nState == Item.TIPS_STALL) then			-- 摆摊状态显示摆摊信息

		local nPrice = me.GetStallPrice(it);		-- 先看是不是自己摆摊的东西

		if not nPrice then							-- 如果不是，看看是不是别人摆摊的东西
			local _, _, tbInfo = me.GetOtherStallInfo();
			if tbInfo then
				for i = 1, #tbInfo do
					if (tbInfo[i].uId == it.nIndex) and (tbInfo[i].nPrice >= 0) then
						nPrice = tbInfo[i].nPrice;
						break;
					end
				end
			end
		end

		if nPrice then								-- 如果都不是，就不显示摆摊信息
			szUnit = self.tbTipPriceUnit[1];---摆摊交易都是银两单位
			szTip = "\n"..szTip.."<color=yellow>Đơn giá bán: "..self:FormatMoney2Style(nPrice)..szUnit.."("..self:FormatMoney(nPrice)..szUnit..")<color>";
			local nTotal = nPrice * it.nCount;
			szTip =  szTip .. "\n<color=yellow>Tổng giá bán: "..self:FormatMoney2Style(nTotal)..szUnit.."("..self:FormatMoney(nTotal)..szUnit..")<color>";
		end

	elseif (nState == Item.TIPS_OFFER) then			-- 收购状态显示收购信息

		local nPrice, nCount = me.GetOfferReq(it);	-- 先看是不是自己收购的东西

		if (not nPrice) or (not nCount) then		-- 如果不是，再看是不是别人收购的东西
			local _, _, tbInfo = me.GetOtherOfferInfo();
			if tbInfo then
				for i = 1, #tbInfo do
					if (tbInfo[i].uId == it.nIndex) and (tbInfo[i].nPrice >= 0) then
						nPrice = tbInfo[i].nPrice;
						nCount = tbInfo[i].nNum;
						break;
					end
				end
			end
		end

		if nPrice and nCount then					-- 如果都不是，不显示收购信息
			szUnit = self.tbTipPriceUnit[1];---摆摊交易都是银两单位
			szTip = "\n"..szTip.."<color=yellow>Số lượng thu mua: "..nCount.." cái\nĐơn giá thu mua: "..self:FormatMoney2Style(nPrice)..szUnit.."("..self:FormatMoney(nPrice)..szUnit..") <color>";
			local nTotal = nPrice * nCount;
			szTip =  szTip .. "\n<color=yellow>Giá mua: "..self:FormatMoney2Style(nTotal)..szUnit.."("..self:FormatMoney(nTotal)..szUnit..")<color>";
		end

	elseif (nState == Item.TIPS_NOBIND_SECTION or nState == Item.TIPS_BINDGOLD_SECTION or nState == Item.TIPS_INTEGRAL_SECTION) then
		local tbTemp = it.GetTempTable("IbShop");		
		if tbTemp and tbTemp[it.nIndex] then
			local tbWareInfo = me.IbShop_GetWareInf(tbTemp[it.nIndex]);			
			if (tbWareInfo and tbWareInfo.nDiscount > 0) then
				local szTemp = "";
				if (tbWareInfo.nDiscountType == 0) then
					szTemp = tbWareInfo.nDiscount / 10;
				else
					if (tbWareInfo.nCurrencyType == 0) then
						szTemp = tbWareInfo.nDiscount .. IVER_g_szCoinName;
					elseif (tbWareInfo.nCurrencyType == 1) then
						szTemp = tbWareInfo.nDiscount .. "Bạc";
					elseif (tbWareInfo.nCurrencyType == 2) then
						szTemp = tbWareInfo.nDiscount .. IVER_g_szCoinName .. " Khóa";
					elseif (tbWareInfo.nCurrencyType == 3) then
						szTemp = tbWareInfo.nDiscount .. "Tích lũy tiêu hao";
					else
						assert(false);
					end
				end
				if tbWareInfo.nDiscEnd > Lib:GetDate2Time(20180101) then	--特殊处理
					szTip = szTip..string.format("\n\n<color=green>Giảm: %s phần\nCó hiệu lực dài hạn.",szTemp);
				elseif (tbWareInfo.nDiscStart ~= tbWareInfo.nDiscEnd and GetTime() <= tbWareInfo.nDiscEnd) then
					local szStartDate = os.date("%Y - %m - %d  %H giờ %M phút %S giây", tbWareInfo.nDiscStart);
					local szEndDate  = os.date("%Y - %m - %d  %H giờ %M phút %S giây", tbWareInfo.nDiscEnd);
					szTip = szTip..string.format("\n\n<color=green>Giảm: %s phần\nThời gian bắt đầu: %s\nThời gian kết thúc: %s<color>",szTemp,szStartDate,szEndDate);
				end
			end
			if (tbWareInfo and tbWareInfo.nHonor > 0) then
				if me.GetHonorLevel() >= tbWareInfo.nHonor then
					szTip = szTip.."\n<color=white>";
				else
					szTip = szTip.."\n<color=red>";
				end
				szTip = szTip.."\nĐiều kiện mua:";
					local strcondfmt = "\nThỏa mãn 1 trong các điều kiện sau\nThủ lĩnh đạt cấp %d\nVõ Lâm đạt cấp %d\nTài Phú đạt cấp %d";
				local strcond = string.format(strcondfmt, tbWareInfo.nHonor, tbWareInfo.nHonor, tbWareInfo.nHonor); 
				szTip = szTip..strcond;
				szTip = szTip.."<color>";
			end
		end
	end
		
	return	szTip;

end

function Item:Tip_Timeout()			-- 超时时间
	
	local szTip = "";
	local tbAbsTime = me.GetItemAbsTimeout(it);

	if tbAbsTime then
		local strTimeout = string.format("<color=yellow>Hạn sử dụng: %d-%d-%d %d giờ %d phút.<color>",
			tbAbsTime[1],
			tbAbsTime[2],
			tbAbsTime[3],
			tbAbsTime[4],
			tbAbsTime[5]);
		szTip = "\n\n"..szTip..strTimeout;
	else
		local tbRelTime = me.GetItemRelTimeout(it);
		if tbRelTime then
			local strTimeout = string.format("<color=yellow>Vật phẩm còn: %d ngày %d giờ %d phút.<color>",
				tbRelTime[1],
				tbRelTime[2],
				tbRelTime[3]);
			szTip = "\n\n"..szTip..strTimeout;
		end
	end

	return	szTip;

end

--地图,物品限制,禁止在当前地图使用
function Item:CheckIsUseAtMap(nMapId, ...)
	local nCheck, szMsg, szMapClass, szItemClass = self:CheckForBidItemAtMap(nMapId, unpack(arg));
	if not nCheck or nCheck == 0 then
		return nCheck, szMsg;
	end
	if nCheck == 2 then
		return 1;
	end
	if Map.tbMapItemState[szMapClass].tbForbiddenUse[szItemClass] ~= nil then
		return 0, "Đạo cụ này không được dùng ở đây";
	end
	
	return 1;
end

--召唤类调用,是否允许自己被别人召唤出地图,[禁止被召唤出去]
--(为了清晰召出和召入分开2个函数，而不选择通过参数来进行判断的做法。)
function Item:IsCallOutAtMap(nMapId, ...)
	local szForbitType = "";
	if type(arg[1]) == "string" then
		szForbitType = arg[1]
	elseif #arg == 4 then
		szForbitType = KItem.GetOtherForbidType(unpack(arg));
	end
	
	if not szForbitType or szForbitType == "" then
		return 0, "Đạo cụ này không được dùng ở đây";
	end

	-- 要先判断该道具能不能在指定地图使用
	local nCanUse = KItem.CheckLimitUse(nMapId, szForbitType);
	if nCanUse == 0 then
		return 0, "Đạo cụ này không được dùng ở đây";
	end
	
	-- 再判断是否被禁止传出
	local szMapClass = GetMapType(nMapId);	
	if Map.tbMapItemState[szMapClass] and Map.tbMapItemState[szMapClass].tbForbiddenCallOut[szForbitType] ~= nil then
		return 0, "Đạo cụ này không được dùng ở đây";
	end
	return 1;
end

--召唤类调用,是否允许召唤别人进入地图和 是 否允许使用物品传入地图
function Item:IsCallInAtMap(nMapId, ...)
	local szForbitType = "";
	if type(arg[1]) == "string" then
		szForbitType = arg[1]
	elseif #arg == 4 then
		szForbitType = KItem.GetOtherForbidType(unpack(arg));
	end
	
	if not szForbitType or szForbitType == "" then
		return 0, "Đạo cụ này không được dùng ở đây";
	end

	-- 要先判断该道具能不能在指定地图使用
	local nCanUse = KItem.CheckLimitUse(nMapId, szForbitType);
	if nCanUse == 0 then
		return 0, "Đạo cụ này không được dùng ở đây";
	end
	
	-- 再判断是否被禁止传入
	local szMapClass = GetMapType(nMapId);
	if Map.tbMapItemState[szMapClass] and Map.tbMapItemState[szMapClass].tbForbiddenCallIn[szForbitType] ~= nil then
		return 0, "Đạo cụ này không được dùng ở đây";
	end
	
	return 1;
end

Item.ForBidUseAtMap = {
	["mask"]= "MASK";
}

function Item:CheckForBidItemAtMap(nMapId, ...)
	local szItemClass = "";
	if #arg == 4 then
		szItemClass = KItem.GetOtherForbidType(unpack(arg)) or "";
	elseif #arg == 1 then
		if type(arg[1]) == "string" then
			szItemClass = arg[1] or "";
		elseif type(arg[1]) == "number" then
			local pItem = KItem.GetObjById(arg[1]);
			if pItem == nil then
				return 0, "Đạo cụ này không được dùng ở đây";
			end
			if self.ForBidUseAtMap[pItem.szClass] then
				szItemClass = self.ForBidUseAtMap[pItem.szClass];
			else
				szItemClass = pItem.GetForbidType() or "";
			end
		else
			return 0, "Đạo cụ này không được dùng ở đây";
		end		
	else
		return 0, "Đạo cụ này không được dùng ở đây";
	end
	
	if (self:CheckDynamicForbiden(nMapId, szItemClass) == 1) then
		return 0, "Đạo cụ này không được dùng ở đây";
	end

	local szMapClass = GetMapType(nMapId) or "";

	if Map.tbMapItemState[szMapClass] == nil then
		return 2, "", szMapClass, szItemClass;	
	end
	if Map.tbMapProperItem[szItemClass] then 
		 if Map.tbMapProperItem[szItemClass] ~= szMapClass then
			--该物品为仅允许.
			local szInfo = Map.tbMapItemState[Map.tbMapProperItem[szItemClass]].szInfo;
			local szMsg = "Đạo cụ này không được dùng ở đây";
			if szInfo ~= "" then
				szMsg = "Đạo cụ này chỉ được dùng ở " .. szInfo .."";
			end
			return 0, szMsg;
		else
			return 1,"", szMapClass, szItemClass;
		end
	end
	
	if Map.tbMapItemState[szMapClass].tbForbiddenUse["ALL_ITEM"]  then
		return 0, "Đạo cụ này không được dùng ở đây";
	end
	
	return 1, "", szMapClass, szItemClass;	
end


function Item:IsEquipRoom(nRoom)
	if nRoom == Item.ROOM_EQUIP or nRoom == Item.ROOM_EQUIPEX or nRoom == Item.ROOM_PARTNEREQUIP then
		return 1;
	end
	return 0;
end


-- UNDONE: Fanghao_Wu	临时代码，将药箱内药品数量*1.5，2008-9-1后删除！！！
function Item:OnLoaded(szClassName)
	local tbClass = self.tbClass[szClassName];
	if (szClassName == "xiang" and tbClass) then
		tbClass:OnLoaded();
	end
end

function Item:ChangeEquipToFac(varEquip, nFaction)
	local pEquip
	if type(varEquip) == "userdata" then
		pEquip = varEquip;
	elseif type(varEquip) == "number" then
		pEquip = KItem.GetObjById(varEquip);
	else
		return 0;
	end
	if not pEquip then
		return 0;
	end
	local tbFacEquip = self:CheckCanChangable(pEquip);
	if not tbFacEquip then
		return 0;
	end
	local tbGDPL = tbFacEquip[nFaction];
	if (not tbGDPL) then
		return 0;
	end
	if (pEquip.nGenre == tbGDPL[1] and 
		pEquip.nDetail == tbGDPL[2] and  
		pEquip.nParticular == tbGDPL[3] and  
		pEquip.nLevel == tbGDPL[4]) then
		return 1;
	end
	return pEquip.Regenerate(
		tbGDPL[1],
		tbGDPL[2],
		tbGDPL[3],
		tbGDPL[4],
		pEquip.nSeries,
		pEquip.nEnhTimes,
		pEquip.nLucky,
		pEquip.GetGenInfo(),
		0,
		pEquip.dwRandSeed,
		pEquip.nStrengthen
	);
end

function Item:CheckCanChangable(pEquip)
	local tbSetting = Item:GetExternSetting("change", pEquip.nVersion, 1);
	local szGDPL = string.format("%d,%d,%d,%d", pEquip.nGenre, pEquip.nDetail, pEquip.nParticular, pEquip.nLevel);
	if not tbSetting.tbItemToChangeId or not tbSetting.tbItemToChangeId[szGDPL] then
		return;
	end
	local nId = tbSetting.tbItemToChangeId[szGDPL];
	if (not tbSetting.tbChange or 
		not tbSetting.tbChange[nId])then
		return;
	end
	return tbSetting.tbChange[nId];
end

-- 将普通门派五行印兑换成特殊五行印
function Item:ExchangeSignet(pEquip, pNewSignet)
	if pEquip.szClass ~= self.UPGRADE_EQUIP_CLASS or pNewSignet.szClass ~= self.UPGRADE_EQUIP_CLASS then
		return;
	end
	
	local tbSetting = Item:GetExternSetting("signet", pEquip.nVersion);
	local tb = {pEquip.GetGenInfo(1), pEquip.GetGenInfo(3)};
	
	for nIndex, v in pairs(tb) do
		local nValue = 0;
		for nLevel = 1, v -1 do
			nValue = nValue + tbSetting.m_LevelExp[nLevel];
		end
		nValue = nValue + pEquip.GetGenInfo(nIndex * 2);
		
		local nNewLevel, nExp = Item:CalcUpgrade(pNewSignet, nIndex, nValue/Item.UPGRADE_EXP_PER_ITEM);
		Item:SetSignetMagic(pEquip, nIndex, 0, 0);
		Item:SetSignetMagic(pNewSignet, nIndex, nNewLevel, nExp);
	end
end

-- 将道具与帮会绑定
function Item:BindWithTong(pItem, nTongId)
	if pItem then
		pItem.SetGenInfo(Item.TASK_OWNER_TONGID, nTongId);
		pItem.Sync();
		return 1;
	end
end

-- 检查该道具是否可以被某帮会成员使用
function Item:IsBindItemUsable(pItem, nTongId)
	if pItem then
		local nOwnerTongId = KLib.Number2UInt(pItem.GetGenInfo(Item.TASK_OWNER_TONGID, 0));
		if nOwnerTongId == 0 or nOwnerTongId == nTongId then
			return 1;
		end
		local pTong = KTong.GetTong(nOwnerTongId);
		if pTong then
			me.Msg("Đạo cụ này đã được khóa cùng bang hội ["..pTong.GetName().."]!");
		else
			me.Msg("Đạo cụ này đã khóa bang hội!");
		end
		return 0;
	end
	return 0;
end


--检测动态注册的地图禁用，0：可用；1：不可用
function Item:CheckDynamicForbiden(nMapId, szClassName)
	local tbDynamicForbiden = Map.tbDynamicForbiden;
	if tbDynamicForbiden == nil or (tbDynamicForbiden[nMapId] == nil) then
		return 0;
	end
	if (tbDynamicForbiden[nMapId][szClassName] == nil) then
		return 0;
	end
	return 1;
end


--计算商品打折信息（对优惠券）
--返回值：打折商品数量，打折率
function Item:CalDiscount(szClassName, tbWareList)
	
	local tbClass = self.tbClass[szClassName];
	if (not tbClass) then
		tbClass = self.tbClass["default"];
	end
	return	tbClass:CalDiscount(tbWareList);
end

--消耗使用次数
function Item:DecreaseCouponTimes(szClassName, tbCouponWare)
	local tbClass = self.tbClass[szClassName];
	if (not tbClass) then
		tbClass = self.tbClass["default"];
	end
	return	tbClass:DecreaseCouponTimes(tbCouponWare);
end

function Item:CanCouponUse(szClassName, dwId)
	local tbClass = self.tbClass[szClassName];
	if (not tbClass) then
		tbClass = self.tbClass["default"];
	end
	return tbClass:CanCouponUse(dwId);
end

function Item:GetItemFightPower()
	if (1 == it.IsPartnerEquip()) then		-- 同伴装备
		return nil;	-- Edited by zhoupf 2010.09.26
		--return Player.tbFightPower:GetPartnerEquipPowerByItem(it);
	end
	if (1 ~= it.IsEquip() and it.GetStoneType() == 0) then	-- 是不是装备
		return nil;
	end
	
	local nPos = it.nEquipPos;
	local nFightPower = nil;
	local nPowerEnhancePreview = nil;
	if ("zhenyuan" == it.szClass) then	-- 是装备的真元
		nFightPower = Item.tbZhenYuan:GetFightPower(it);
	elseif "gem" == it.szClass then		-- 宝石
		nFightPower = Item.tbStone:GetFightPower(it);
	elseif (10 > nPos) then
		nFightPower = it.CalcFightPower();
		if (it.nEnhTimes < 16) then
			local nDiff = it.CalcExtraFightPower(it.nEnhTimes + 1, 0) - it.CalcExtraFightPower(it.nEnhTimes, 0);
			nPowerEnhancePreview = nFightPower + nDiff;
		end
	elseif( Item.EQUIPPOS_MANTLE == nPos) then	-- 披风
		nFightPower = Player.tbFightPower:GetPiFengPower(me, it);
	elseif(Item.EQUIPPOS_SIGNET == nPos) then	-- 五行印
		nFightPower = Player.tbFightPower:Get5XingYinPower(me, it);
	elseif(Item.EQUIPPOS_BOOK == nPos) then		-- 秘籍
		nFightPower = Player.tbFightPower:GetMiJiPower(me, it);
	elseif(Item.EQUIPPOS_ZHEN == nPos) then		-- 阵法
		nFightPower = Player.tbFightPower:GetZhenFaPower(me, it);
	elseif(Item.EQUIPPOS_CHOP == nPos) then		-- 官印
		nFightPower = Player.tbFightPower:GetGuanYinPower(me, it);
	end
	return nFightPower, nPowerEnhancePreview;
end

-- 越南版特殊功能
function Item:LoadSpecialedItemList()
	local tbFile = Lib:LoadTabFile(self.tbSpecFile);
	if not tbFile then
		print(self.tbSpecFile.." load failed!");
		return;
	end
	
	Item.tbSpecialedList = {};
	
	for _, tbData in pairs(tbFile) do
		local szKey = string.format("%s,%s,%s,%s", tbData.G, tbData.D, tbData.P, tbData.L);
		Item.tbSpecialedList[szKey] = 1;
	end	
end

function Item:IsInLimitItems(pItem)
	local szGDPL = pItem.SzGDPL();
	if (not self.tbSpecialedList[szGDPL]) then
		return 0;
	end
	
	return 1;
end

function Item:ApplyBindEquip(pEquip)
	if self:IsInLimitItems(pEquip) ~= 1 then
		me.Msg("Đạo cụ này không thể thao tác!");
		return;		
	end
	
	local nUnLockTime = KLib.Number2Int(pEquip.GetUnlockTime());
	if (pEquip.GetLockIntervale() ~= 0 and (nUnLockTime == -1 or nUnLockTime > GetTime())) then
		me.Msg("Đạo cụ này đang khóa giao dịch!");
		return;
	end
	
	if (pEquip.GetLockIntervale() > 0) then
		pEquip.SetLockState(1, -1);		-- 永久绑定
		pEquip.Sync();
		me.Msg("Khóa thành công!");
	end
end

-- 申请延迟解绑道具（申请之后，若干时间后道具解绑）
function Item:ApplyDelayUnBindEquip(pEquip)
	if self:IsInLimitItems(pEquip) ~= 1 then
		me.Msg("Đạo cụ này không thể thao tác!");
		return;		
	end
	
	local nUnLockTime = KLib.Number2Int(pEquip.GetUnlockTime());
	if (pEquip.GetLockIntervale() == 0 or (nUnLockTime ~= -1 and nUnLockTime <= GetTime())) then
		me.Msg("Đạo cụ này không bị khóa giao dịch!");
		return;
	end	
	
	if (pEquip.GetLockIntervale() > 0) then
		if (pEquip.GetUnlockTime() > GetTime() and pEquip.GetUnlockTime() < GetTime() + pEquip.GetLockIntervale()) then
			me.Msg("Đạo cụ này đã xin mở khóa!");
			return;
		end
		
		pEquip.SetLockState(1, GetTime() + pEquip.GetLockIntervale());
		pEquip.Sync();
		me.Msg("Xin mở khóa thành công!")
	end
end

function Item:ApplyCacelDelayUnBind(pEquip)
	if self:IsInLimitItems(pEquip) ~= 1 then
		me.Msg("Đạo cụ này không thể thao tác!");
		return;		
	end
	
	local nUnLockTime = KLib.Number2Int(pEquip.GetUnlockTime());
	if (pEquip.GetLockIntervale() == 0 or (nUnLockTime ~= -1 and nUnLockTime <= GetTime())) then
		me.Msg("Đạo cụ này không bị khóa giao dịch!");
		return;
	end	
	
	if (pEquip.GetLockIntervale() > 0) then
		local nUnlockTime = KLib.Number2Int(pEquip.GetUnlockTime());
		if (nUnlockTime <= GetTime() or nUnlockTime >= GetTime() + pEquip.GetLockIntervale() or nUnlockTime == -1) then
			me.Msg("Đạo cụ này chưa mở khóa!");
			return;
		end
		
		pEquip.SetLockState(1, -1);		-- 永久绑定
		pEquip.Sync();
		me.Msg("Hủy thao tác xin mở khóa thành công!");
	end	
end

function Item:DelayBind_Check(tbGiftSelf, pPickItem, pDropItem, nX, nY, nType)
	if pDropItem then
		if self:IsInLimitItems(pDropItem) ~= 1 then
			me.Msg("Đạo cụ này không thể thao tác!");
			return 0;
		end
		
		local nCount = 0;
		local pItem = tbGiftSelf:First();
		while(pItem) do
			nCount = nCount + 1;
			pItem = tbGiftSelf:Next();
		end
		if nCount > 0 then
			me.Msg("Mỗi lần chỉ được thao tác với 1 trang bị!");
			return;	
		end	
	end
	
	return 1;
end

function Item:DelayBind_OK(nType, tbItemObj)
	if Lib:CountTB(tbItemObj) == 0 then
		return;
	end
	
	if Lib:CountTB(tbItemObj) > 1 then
		me.Msg("Mỗi lần chỉ được thao tác với 1 trang bị!");
		return;	
	end
	
	if nType == Item.DELAY_BIND	then
		self:ApplyBindEquip(tbItemObj[1][1]);
	elseif nType == Item.DELAY_UNBIND then
		self:ApplyDelayUnBindEquip(tbItemObj[1][1]);
	elseif nType == Item.DELAY_CACEL_UNBIND then
		self:ApplyCacelDelayUnBind(tbItemObj[1][1]);
	end
end

Item:LoadSpecialedItemList();

function Item:GetItemType(g, d, p)
	local nValue = 0;
	nValue = Lib:SetBits(nValue, p, 0, 11);
	nValue = Lib:SetBits(nValue, d, 12, 23);
	nValue = Lib:SetBits(nValue, g, 24, 31);
	
	return nValue;
end

-- 道具数据加载完成后会通知的脚本
function Item:OnLoadComplete()
	local tbClass = self.tbClass[it.szClass];
	if (tbClass and tbClass.OnLoadComplete) then
		tbClass:OnLoadComplete();
	end
end




---星级对应的装备颜色，成就用,pItem.nStarLevel
Item.tbStarLevelAchievement = 
{
	[5]= 418,
	[6]= 418,
	[7]= 418,
	[8]= 418,
	[9]= 419,
	[10]=419,
	[11]=419,
	[12]=419,
	[13]=420,
	[14]=420,
	[15]=420,
	[16]=420,
};

--装备细类,pItem.nDetail
Item.tbDetailAchievement = 
{
	[Item.EQUIP_MANTLE] = 425,
	[Item.EQUIP_GARMENT] = 426,
	[Item.EQUIP_OUTHAT] = 426,
	[Item.EQUIP_HORSE] = 427,
};

---装备相关成就
function Item:OnEquipAchievement(pItem)
	if not pItem then
		return 0;
	end
	local nStarLevel = pItem.nStarLevel;
	local nDetail = pItem.nDetail;
	local nStarAchiId = self.tbStarLevelAchievement[nStarLevel];
	if nStarAchiId and nDetail <= Item.EQUIP_PENDANT then	--只对10件装备进行判断
		Achievement:FinishAchievement(me,nStarAchiId);
	end
	local nDetailAchiId = self.tbDetailAchievement[nDetail];
	if nDetail then
		Achievement:FinishAchievement(me,nDetailAchiId);
	end
	if nDetail == Item.EQUIP_HORSE then	--马匹成就
		self:FinishHorseAchievement(pItem);
	end
	self:FinishAllEquipAchievement();	--全身装备成就
end

function Item:FinishHorseAchievement(pItem)
	local tbMASS = pItem.GetRandMASS();
	local nSpeed = 0;
	for i = 1, #tbMASS do		
		if tbMASS[i].szName == "fastwalkrun_p" then
			nSpeed = tonumber(tbMASS[i].tbValue[1]);
			break;
		end
	end
	if nSpeed >= 95 then
		Achievement:FinishAchievement(me,428);
	end
	if pItem.Equal(unpack(self.tbNewHorseGDPL)) == 1 then
		Achievement:FinishAchievement(me, 500);
	end
end

function Item:FinishAllEquipAchievement()
	local nEquipCount = 0;	--装备数量
	local nBlueCount = 0;	--蓝装数量
	local nPurpleCount = 0;	--紫装数量
	local nOrangeCount = 0; --橙装数量
	local nGT8Count = 0;	--大于等于8的数量
	local nGT12Count = 0;	--大于等于12的数量
	local nMaxEquipCount = 10;	--全身装备数量
	for nPos = Item.EQUIPPOS_HEAD,Item.EQUIPPOS_PENDANT do
		local pItem = me.GetEquip(nPos);
		if pItem then
			nEquipCount = nEquipCount + 1;
			if pItem.nStarLevel >= 5 then
				nBlueCount = nBlueCount + 1;
			end
			if pItem.nStarLevel >= 9 then
				nPurpleCount = nPurpleCount + 1;
			end
			if pItem.nStarLevel >= 13 then
				nOrangeCount = nOrangeCount + 1;
			end
			if pItem.nEnhTimes >= 8 then
				nGT8Count = nGT8Count + 1;
			end
			if pItem.nEnhTimes >= 12 then
				nGT12Count = nGT12Count + 1;
			end
		end
	end
	if nEquipCount >= nMaxEquipCount then
		Achievement:FinishAchievement(me,421);
	end
	if nBlueCount >= nMaxEquipCount then
		Achievement:FinishAchievement(me,422);
	end
	if nPurpleCount >= nMaxEquipCount then
		Achievement:FinishAchievement(me,423);
	end
	if nOrangeCount >= nMaxEquipCount then
		Achievement:FinishAchievement(me,424);
	end
	if nGT8Count >= nMaxEquipCount then
		Achievement:FinishAchievement(me,435);
	end
	if nGT12Count >= nMaxEquipCount then
		Achievement:FinishAchievement(me,436);
	end
end

--宝石相关成就
function Item:FinishStoneAchievement(nSpeical)
	local nCountLevel1 = 20;
	local nCountLevel2 = 30;
	Achievement:FinishAchievement(me,429);
	if nSpeical ~= 0 then
		Achievement:FinishAchievement(me,430);
	end
	local nStoneCount = 0;
	for nPos = Item.EQUIPPOS_HEAD,Item.EQUIPPOS_PENDANT do
		local pItem = me.GetEquip(nPos);
		if pItem then
			for nHoleId = 1 , 3 do
				local _,dwStone = pItem.GetHoleStone(nHoleId);
				if dwStone ~= 0 then
					nStoneCount = nStoneCount + 1;
				end
			end
		end
	end
	if nStoneCount >= nCountLevel1 then
		Achievement:FinishAchievement(me,431);
	end
	if nStoneCount >= nCountLevel2 then
		Achievement:FinishAchievement(me,432);
	end
end              


--强化相关成就
function Item:FinishEnhanceAchievement(nLevel,nProb,nRet)
	if nRet == 0 then
		Achievement:FinishAchievement(me,437);
		if nProb >= 95 and nLevel >= 14 then
			Achievement:FinishAchievement(me,439);
		end
	elseif nRet == 1 then
		if nLevel >= 12 then
			Achievement:FinishAchievement(me,433);
		end
		if nLevel >= 16 then
			Achievement:FinishAchievement(me,434);			
		end
		if nLevel >= 14 then
			if nProb <= 70 then
				Achievement:FinishAchievement(me,438);
			end
		end
	end
end   


--全套装备强化成就,修复直接可用
function Item:RepairEnhanceAchievement()
	local nEquipCount = 10;	--10件装备数量
	local nGT8Count = 0;	--大于等于8的数量
	local nGT12Count = 0;	--大于等于12的数量
	local nGT16Count = 0;
	local tbRoom = {0,1,2,3,5,6,7,8,9,10,11,12,24}
	for _, nRoom in pairs(tbRoom) do
		local tbItem = me.FindAllItem(nRoom);
		for i = 1, #tbItem do
			local pItem = KItem.GetItemObj(tbItem[i]);
			if pItem and pItem.nDetail <= Item.EQUIP_PENDANT then
				if pItem.nEnhTimes >= 8 then
					nGT8Count = nGT8Count + 1;
				end
				if pItem.nEnhTimes >= 12 then
					nGT12Count = nGT12Count + 1;
				end
				if pItem.nEnhTimes >= 16 then
					nGT16Count = nGT16Count + 1;
				end
			end
		end
	end
	if nGT8Count >= nEquipCount then
		Achievement:FinishAchievement(me,435);
	end
	if nGT12Count >= nEquipCount then
		Achievement:FinishAchievement(me,436);
	end
	if nGT12Count >= 1 then
		Achievement:FinishAchievement(me,433);
	end
	if nGT16Count >= 1 then
		Achievement:FinishAchievement(me,434);
	end
end     


Item.ITEM_REQ_LEVEL		= 5;				-- 等级需求

function Item:InitReduceReqLevel()
	self.tbItemReqConditionLevel = {};
	self.tbEquip2SkillId = {};	
	local szFilePath = "\\setting\\item\\001\\equip\\reducereqlevel.txt"
	local tbFile = Lib:LoadTabFile(szFilePath);
	if not tbFile then
		return
	end
	for nId, tbParam in ipairs(tbFile) do
		if (nId > 1) then
			local nSkillId = tonumber(tbParam.SkillId) or 0;
			if (nSkillId > 0) then
				local tbSkill = self.tbItemReqConditionLevel[nSkillId];
				if (not tbSkill) then
					self.tbItemReqConditionLevel[nSkillId] = {};
					tbSkill = self.tbItemReqConditionLevel[nSkillId];
				end
				local nType = tonumber(tbParam.Type) or 0;

				local tbType = tbSkill[nType];
				if (not tbType) then
					tbSkill[nType] = {};
					tbType = tbSkill[nType];
				end
				local szEquipId = tbParam.EquipId;
				if (szEquipId and szEquipId ~= "") then
					local nDelLevel = tonumber(tbParam.DelLevel) or 0;
					tbType[szEquipId] = nDelLevel;
					local tbSkillList = self.tbEquip2SkillId[szEquipId];
					if (not tbSkillList) then
						self.tbEquip2SkillId[szEquipId] = {};
						tbSkillList = self.tbEquip2SkillId[szEquipId];
					end
					tbSkillList[#tbSkillList + 1] = {nSkillId = nSkillId, nType = nType};
				end
			end
		end
	end
end

function Item:GetConditionRequireValue(nGenre, nDetailAchiId, nParticular, nLevel, nRequireType, nReqValue)
	if (nRequireType == self.ITEM_REQ_LEVEL) then
		if (not self.tbEquip2SkillId) then
			return nReqValue;
		end		
		
		local szDetailItem = string.format("%s,%s,%s,%s", nGenre, nDetailAchiId, nParticular, nLevel);
		local szItemClass = string.format("%s,%s", nGenre, nDetailAchiId);		
		local tbDetailItem_SkillId = self.tbEquip2SkillId[szDetailItem];
		
		if (tbDetailItem_SkillId) then
			for _, tbInfo in pairs(tbDetailItem_SkillId) do
				local nSkillId = tbInfo.nSkillId;
				local nType = tbInfo.nType;
				local nSkillLevel = me.GetSkillState(nSkillId);
				if (nSkillLevel > 0) then
					local nDelLevel = self.tbItemReqConditionLevel[nSkillId][nType][szDetailItem];
					if (nDelLevel) then
						nReqValue = nReqValue - nDelLevel;
						return nReqValue;
					end
				end
			end 
		end
		
		local tbClassItem_SkillId = self.tbEquip2SkillId[szItemClass];		
		if (tbClassItem_SkillId) then
			for _, tbInfo in pairs(tbClassItem_SkillId) do
				local nSkillId = tbInfo.nSkillId;
				local nType = tbInfo.nType;
				local nSkillLevel = me.GetSkillState(nSkillId);
				if (nSkillLevel > 0) then
					local tbBaseProp = KItem.GetEquipBaseProp(nGenre, nDetailAchiId, nParticular, nLevel);
					local nDelLevel = self.tbItemReqConditionLevel[nSkillId][nType][szItemClass];
					if (nDelLevel and nType == tbBaseProp.nQualityPrefix) then
						nReqValue = nReqValue - nDelLevel;
						return nReqValue;
					end
				end
			end 
		end
		
	end
	
	return nReqValue;
end

function Item:CanPutLocalMedicineIntoBags(nCount, bShowTip, pPlayer)
	local pPlayer = pPlayer or me;
	if not pPlayer then
		return 0;
	end
	
	if pPlayer and pPlayer.CountFreeBagCell() < 1 then
		pPlayer.Msg("Túi đã đầy.");
		return 0;	
	end
	
	local nMaxCount = pPlayer.GetBagCellCount(); -- 背包大小
	
	local tbFind = pPlayer.FindClassItemInBags("localmedicine");
	Lib:MergeTable(tbFind, pPlayer.FindClassItemInBags("fulimedicine"));
	local nCurCount = 0;
	for _, tbItem in pairs (tbFind) do
		nCurCount = nCurCount + tbItem.pItem.nCount;
	end
	
	local nFreeCount = nMaxCount - nCurCount;
	
	if nFreeCount < nCount then
		if bShowTip then
			if bShowTip == 1 then
				pPlayer.Msg("Tối đa có thể mang " .. nFreeCount .. " dược phẩm.");
			elseif bShowTip == 2 then
				pPlayer.Msg("Số dược phẩm mang theo đạt giới hạn!");
			end
		end
		return 0;
	end
	
	return 1;	
end

function Item:CanGetLocalMedicine(nCount, bShowTip, pPlayer)
	local pPlayer = pPlayer or me;
	if not pPlayer then
		return 0;
	end
	
	if pPlayer and pPlayer.CountFreeBagCell() < 1 then
		pPlayer.Msg("Túi đã đầy.");
		return 0;	
	end
	
	local nFreeCount = pPlayer.CalFreeLocalMedicineCountInBags();
	
	if nFreeCount < nCount then
		if bShowTip then
			if bShowTip == 1 then
				pPlayer.Msg("Tối đa có thể mang " .. nFreeCount .. " dược phẩm.");
			elseif bShowTip == 2 then
				pPlayer.Msg("Số dược phẩm mang theo đạt giới hạn!");
			end
		end
		return 0;
	end
	
	return 1;
end

function Item:CheckIsLocalMedicine(nGenre, nDetail, nParticular, nLevel, nShowTipType, pPlayer)		-- 是否本服普通药
	local tbBaseProp = KItem.GetItemBaseProp(nGenre, nDetail, nParticular, nLevel);
	local pPlayer = pPlayer or me;
	if not tbBaseProp or tbBaseProp.szClass ~= "localmedicine" then
		return 0;
	end
	
	if nShowTipType and pPlayer then
		local szMsg = "";
		if nShowTipType == 1 then
			szMsg = szMsg.."Vật phẩm này không được đặt vào Rương Chứa Đồ";
		elseif nShowTipType == 2 then
			szMsg = szMsg.."Vật phẩm này không được đặt vào Thương Khố Bang";
		end
		pPlayer.Msg(szMsg);
	end
	
	return 1;
end

Item:InitReduceReqLevel();
