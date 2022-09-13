------------------------------------------------------
-- 文件名　：switchseriesequip
-- 创建者　：dengyong
-- 创建时间：2011-05-09 11:02:42
-- 描  述  ：切换装备五行
------------------------------------------------------

-- 装备转换特征组成：装备类型（蓝装/紫装/橙装....(kind5)）, 战斗类型(pvp/pve(kind7))，套装ID（suiteID），越南版（bVN），腰带类型（b2），
-- 装备特殊类别(category)，性别（kind4），装备细类（detailtype），装备适用类别（内功/外功/格斗系(kind3)）,外观特征（布/皮/铁(kind2)）,适用五行(kind7)
-- 一共10个小特征组成，其中前8个特征完全由配置表决定(武器的category和detail特殊处理)，组合成一级特征；后三个特征需要特殊对应规则，组合成二级特征，
-- 其对应规则分别为：装备适用类别要根据目标五行获取，配置表里没填适用类别的表示不区分，可适用多个类别；外观特征由原装备的外观特征配置决定，
-- 如果装备的外观特征没有配置，表示不区分外观，适用；适用五行根据目标五行获取。

Item.FILE_PATH					= "\\setting\\item\\001\\extern\\change\\";
Item.SWITCH_FILE_WUQI			= "switchwuqi.txt";
Item.SWITCH_FILE_FANGJUSHOUSHI  = "switchfangjushoushi.txt";

Item.tbEquipType = 
{
	"外功系", "内功系",
}

-- GDPL到特征的对应表，一个GDPL只能对应一个特征
-- 特征由：后缀类型_PVP类型_套装ID_bVN_b2_Category_性别_detail，这里只包括了配置表决定的特征(一级特征)，
-- 还有一部分特征是需要由角色属性来决定的（其它特征）
Item.tbGDPLToValue				= {};
-- 一级特征对应GDPL，一个特征可对应多个GDPL
Item.tbValueToGDPL				= {};
-- 武器category对应detail，对武器来说，一个category只能对应一个detail
Item.tbWeaponCatToDetail		= {};

Item.SECOND_FEATURE_COUNT 		= 3;		-- 二级特征key数量
Item.DEFAULT_SETTING			= "0";		-- 配置表中空列的默认值

-- 配置配置表以外的其它特征
Item.tbFixList = {
	--路线,五行,内外格斗,武器类型
	{"刀少","外功系","皮","金系",13,"刀",},   
	{"棍少","外功系","铁","金系",14,"棍",},   
	{"枪天","格斗系","铁","金系",15,"枪",},   
	{"锤天","格斗系","铁","金系",16,"锤",},   
	{"陷阱","外功系","皮","木系",22,"飞刀",}, 
	{"袖箭","外功系","皮","木系",23,"袖箭",}, 
	{"刀毒","外功系","皮","木系",13,"刀",},   
	{"掌毒","内功系","皮","木系",11,"手",},   
	{"掌峨","内功系","布","水系",11,"手",},   
	{"辅峨","内功系","布","水系",12,"剑",},   
	{"剑翠","内功系","布","水系",12,"剑",},   
	{"刀翠","外功系","布","水系",13,"刀",},   
	{"掌丐","内功系","皮","火系",11,"手",},   
	{"棍丐","外功系","皮","火系",14,"棍",},   
	{"战忍","外功系","皮","火系",15,"枪",},   
	{"魔忍","内功系","皮","火系",13,"刀",},   
	{"气武","内功系","布","土系",12,"剑",},   
	{"剑武","外功系","布","土系",12,"剑",},   
	{"刀昆","外功系","布","土系",13,"刀",},   
	{"剑昆","内功系","布","土系",12,"剑",},   
	{"锤明","格斗系","皮","木系",16,"锤",},   
	{"剑明","内功系","皮","木系",12,"剑",},   
	{"指段","格斗系","布","水系",11,"手",},   
	{"气段","内功系","布","水系",12,"剑",}, 
};

-- 纠正字符串
function Item:__AdjustStr(str, szException)
	if (not str or str == "") then
		return szException;
	end
	
	return str;
end


-- 加载配置表
function Item:LoadSwitchSetting(szFile)
	local tbFile = Lib:LoadTabFile(szFile);
	if not tbFile then
		return;
	end
	
	
	for _, tbData in pairs(tbFile) do
		local G = tbData.Genre;
		local D = tbData.DetailType;
		local P = tbData.ParticularType;
		local L = tbData.Level;
		
		local szGDPL = string.format("%s_%s_%s_%s", G, D, P, L);
		-- 一级特征，后缀类型_PVP类型_套装ID_bVN_b2_Category_性别_detail
		local szFeature1 = string.format("%s_%s_%s_%s_%s_%s_%s_%s", tbData.kind5, tbData.kind6, 
			self:__AdjustStr(tbData.SuiteID, self.DEFAULT_SETTING),
			self:__AdjustStr(tbData.bVN, self.DEFAULT_SETTING), 
			self:__AdjustStr(tbData.b2, self.DEFAULT_SETTING), 
			tbData.Category, 
			self:__AdjustStr(tbData.kind4, self.DEFAULT_SETTING),
			D);
			
		-- 其它特征（二级特征），内功系/外功系/格斗系_布/皮/甲_五行
		local szFeature2 = string.format("%s_%s_%s", 
			self:__AdjustStr(tbData.kind3, self.DEFAULT_SETTING), 
			self:__AdjustStr(tbData.kind2, self.DEFAULT_SETTING), 
			tbData.kind7);
		
		local szFullFeature = string.format("%s_%s", szFeature1, szFeature2);
		
		-- 一个GDPL只能对应一个特征，方便获取，两级特征分开记录
		self.tbGDPLToValue[szGDPL] =  {szFeature1, szFeature2};
		
		-- 一个特征可能作用多个GDPL，这里需要全特征来作key
		self.tbValueToGDPL[szFeature1] = self.tbValueToGDPL[szFeature1] or {};
		table.insert(self.tbValueToGDPL[szFeature1], szGDPL);

		
		-- 武器的Category与detail之间有单向的映射关系，一个Category固定对应某个detail
		if (tonumber(D) == Item.EQUIP_MELEE_WEAPON or tonumber(D) == Item.EQUIP_RANGE_WEAPON) then
			self.tbWeaponCatToDetail[tonumber(tbData.Category)] = tonumber(D);
		end
	end	
end

-- 获取二级特征（配置表以外的特征）
-- 武器内外功系类型由选择的路线决定,如选定了气段装备,武器必然是内功系，若tbFixList[2]为格斗系,优先转换为外功系装备,没有对应外功系装备转换为格斗系装备
-- 因此武器有可能需要检查两次，第一次的时候内外功系始终为内功系或外功系，第二次检查的时候才可能出现格斗系
function Item:GetOtherFeature(nFaction, nRouteId, szSelectVSType,nEquipPos, bRepeatWeapon)
	local nId = (nFaction - 1) * 2 + nRouteId;
	local tbFeature = self.tbFixList[nId];
	if not tbFeature or nEquipPos < Item.EQUIPPOS_HEAD or nEquipPos > Item.EQUIPPOS_PENDANT then
		return;
	end
	
	bRepeatWeapon = bRepeatWeapon or 0;
	
	-- 内功系/外功系/格斗系_布/皮/甲_五行
	-- 只有衣服和帽子才区分布/皮/甲
	local szVSType = szSelectVSType; --tbFeature[2] == "内功系" and tbFeature[2] or "外功系";
	local szApperance = self.DEFAULT_SETTING;
	local szSeries = tbFeature[4];
	
	-- 武器以Item.tbFixList中配置的为准
	if (nEquipPos == Item.EQUIPPOS_WEAPON) then
		szVSType = tbFeature[2] == "内功系" and tbFeature[2] or "外功系";
	end
	
	-- 武器在重复检查的时候直接取Item.tbFixList中的配置
	if (bRepeatWeapon == 1 and nEquipPos == Item.EQUIPPOS_WEAPON) then
		szVSType = tbFeature[2];
	end
	
	-- 只有衣服和帽子才区分 “布/皮/铁” 类型
	if (nEquipPos == Item.EQUIPPOS_HEAD or nEquipPos == Item.EQUIPPOS_BODY) then
		szApperance = tbFeature[3];
	end
	
	local szFeature2 = string.format("%s_%s_%s", szVSType, szApperance, szSeries);
	
	local nWeaponCategory = tbFeature[5];
	
	return szFeature2, nWeaponCategory;
end

-- 某个位置上的装备切换到指定路线的装备特征值
function Item:GetEquipFeatures(szGDPL, nFaction, nRouteId, szVsType, nEquipPos)
	if not self.tbGDPLToValue[szGDPL] then
		return;
	end
	
	local szFeature1 = self.tbGDPLToValue[szGDPL][1];		-- 一级特征
	local szFeature2, nWeaponCat = Item:GetOtherFeature(nFaction, nRouteId, szVsType, nEquipPos);

	-- 如果是武器，要替换特征一里面的category子特征和detail子特征
	if (nEquipPos == 3 ) then
		local tbFeature1 = Lib:SplitStr(szFeature1, "_");
		local nDstDetail = self.tbWeaponCatToDetail[nWeaponCat];
		if (tbFeature1[6] ~= tostring(nWeaponCat)) then
			szFeature1 = string.format("%s_%s_%s_%s_%s_%s_%s_%s", tbFeature1[1], tbFeature1[2], tbFeature1[3],
				tbFeature1[4], tbFeature1[5], tostring(nWeaponCat), tbFeature1[7], tonumber(nDstDetail));
		end
	end
	
	return szFeature1, szFeature2;
end

-- 根据选择情况，获得对应装备的匹配装备
function Item:GetMatchEquip(szGDPL, nFaction, nRouteId, szVSType, nEquipPos)
	local szFeature1, szFeature2 = self:GetEquipFeatures(szGDPL, nFaction, nRouteId, szVSType, nEquipPos);
	
	local tbMatchGDPLs = self:GetMatchEquipByFeature(szFeature1, szFeature2);

	
	--没找到匹配关系，如果是武器，重复检查一次
	if (not tbMatchGDPLs or #tbMatchGDPLs == 0) and nEquipPos == Item.EQUIPPOS_WEAPON then
		szFeature2 = self:GetOtherFeature(nFaction, nRouteId, szVsType, nEquipPos, 1);	-- 1表示武器的重复检查
		
		tbMatchGDPLs = self:GetMatchEquipByFeature(szFeature1, szFeature2);	-- 重新获取一次
	end
	
	return tbMatchGDPLs;
end

-- 按特征获取特征匹配的装备
function Item:GetMatchEquipByFeature(szFeature1, szFeature2)
	if not szFeature1 or not szFeature2 then
		return;
	end
	
	local tbMatchGDPL = self.tbValueToGDPL[szFeature1];
	if not tbMatchGDPL then
		return;
	end
	
	local tbRetGDPL = {};
	for _, szGDPL in pairs(tbMatchGDPL) do
		local szThisFeature2 = self.tbGDPLToValue[szGDPL][2];
		
		if (self:IsOtherFeatureMatch(szFeature2, szThisFeature2) == 1) then
			local tbGDPL = Lib:SplitStr(szGDPL, "_");
			for i, strValue in pairs(tbGDPL) do
				tbGDPL[i] = assert(tonumber(strValue));
			end
			
			table.insert(tbRetGDPL, tbGDPL);
		end		
	end
	
	return tbRetGDPL;
end

-- 判断二级特征是否匹配（第二个参数是否匹配第一个参数的特征，是单向关系!）
function Item:IsOtherFeatureMatch(szSrc, szDest)
	local tbFeatureSrc = Lib:SplitStr(szSrc, "_");
	local tbFeatureDest = Lib:SplitStr(szDest, "_");
	
	if not tbFeatureSrc or not tbFeatureDest then
		return 0;
	end
	
	if #tbFeatureSrc ~= self.SECOND_FEATURE_COUNT or #tbFeatureDest ~= self.SECOND_FEATURE_COUNT then
		return 0;
	end
	
	-- 检查内、外功、格斗系
	local szSrc1 = tbFeatureSrc[1];
	local szDest1 = tbFeatureDest[1];
	if szSrc1 ~= self.DEFAULT_SETTING and szDest1 ~= self.DEFAULT_SETTING and 
		szSrc1 ~= szDest1 then
			return 0;
		end	
	
	-- 检查外观特征
	local szSrcAppearance = tbFeatureSrc[2];
	local szDestAppearance = tbFeatureDest[2];
	if szSrcAppearance ~= self.DEFAULT_SETTING and szDestAppearance ~= self.DEFAULT_SETTING and 
		szSrcAppearance ~= szDestAppearance then
			return 0;
		end	
	
	-- 检查五行
	local szSrcSex = tbFeatureSrc[3];
	local szDestSex = tbFeatureDest[3];
	if szSrcSex ~= szDestSex then
		return 0;
	end
	
	
	return 1;
end


if (MODULE_GAMESERVER) then
	
Item.c2sFun 	= Item.c2sFun or {};
	
function Item:ApplySwitchEquipSeries()
	-- 打开UI
	me.CallClientScript({"UiManager:OpenWindow", "UI_SWITCH_PANEL"});
end

-- tbSelectInfo = {nFaction, nRoute, nEquipType, tbSwitchInfo = {0, 1, 0, 1, ..., 1}}
-- tbSwitchInfo 里记录对应位置上的装备是否需要切换，0不切换，1切换
function Item:ApplySwitchOK(tbSelectInfo)

	if me.CheckSwitchEquipSeriesState() ~= 1 then
		return;
	end
	
	local nRet = self:CheckInfoFormat(tbSelectInfo);
	if nRet ~= 1 then
		return;
	end	

	-- 判断有没有选择可转换的装备
	local nSwitchCount = 0;
	for _, bSwitch in pairs(tbSelectInfo.tbSwitchInfo) do
		nSwitchCount = bSwitch == 1 and nSwitchCount + 1 or nSwitchCount;		
	end
	
	if nSwitchCount == 0 then
		me.Msg("没有选择可转换的装备！");
		return;
	end

	local nFaction = tbSelectInfo.nFaction;
	local nRoute = tbSelectInfo.nRoute;
	local nEquipType = tbSelectInfo.nEquipType;
	local szEquipType = self.tbEquipType[nEquipType];
	local szRouteName = Player.tbRouteName[(nFaction - 1) * 2 + nRoute];
	
	local szMsg = string.format("你选择转换为<color=yellow>%s%s<color>装备，", szRouteName, szEquipType);
	if szEquipType == "内功系" then
		szMsg = szMsg.."虽然装备基础属性可能略高，但是会损失大量命中和忽闪，如果您已经辅修了或者想要辅修外功系职业，使用这套装备可能会使能力相对较低，是否依然要转换？"		
	else
		szMsg = szMsg.."是否确定转换？";		
	end

	local tbOpt = 
	{
		{"Xác nhận", self.SureSwitch, self, me.nId, tbSelectInfo},
		{"取消"},
	}
		
	Dialog:Say(szMsg, tbOpt);
end
	
function Item:SureSwitch(nPlayerId, tbSelectInfo)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	
	-- 要转换才切换装备，不转换直接修改状态
	if me.CheckSwitchEquipSeriesState() ~= 1 then
		return;
	end

	local nFaction = tbSelectInfo.nFaction;
	local nRoute = tbSelectInfo.nRoute;
	if self:IsSelectFactionRoute(nFaction, nRoute) ~= 1 then
		pPlayer.Msg("请先加入指定门派路线！");
		return;
	end
	
	local nEquipType = tbSelectInfo.nEquipType;
	local szEquipType = self.tbEquipType[nEquipType];
	local szRouteName = Player.tbRouteName[(nFaction - 1) * 2 + nRoute];

	local tbLogMsg = {};
	table.insert(tbLogMsg, string.format("申请转换装备成%s%s装备。SwitchEquipSeries Log Begin:", szRouteName, szEquipType));
	for i = Item.EQUIPPOS_HEAD, Item.EQUIPPOS_PENDANT do			
			
		local pEquip = pPlayer.GetItem(Item.ROOM_EQUIP, i);
		if pEquip then
			
			-- log格式:装备名字(g_d_p_l_五行_强化次数_幸运值_版本号_随机种子_改造等级)
			local szCurLogMsg = string.format("原装备：%s(%d_%d_%d_%d_%d_%d_%d_%d_%d_%d)", pEquip.szName,
				pEquip.nGenre, pEquip.nDetail, pEquip.nParticular, pEquip.nLevel, pEquip.nSeries, 
				pEquip.nEnhTimes, pEquip.nLucky, 0, pEquip.dwRandSeed, pEquip.nStrengthen);	
								
			if (tbSelectInfo.tbSwitchInfo[i + 1] == 1) then
				local szGDPL = string.format("%d_%d_%d_%d", pEquip.nGenre, pEquip.nDetail, pEquip.nParticular, pEquip.nLevel);
				local tbMatchGDPLs = Item:GetMatchEquip(szGDPL, tbSelectInfo.nFaction, tbSelectInfo.nRoute, szEquipType, i);
											
				local tbGDPL = nil;
				if tbMatchGDPLs then
					tbGDPL = tbMatchGDPLs[1];
				end
				
				if tbGDPL then				
					local nSeries = KItem.GetEquipBaseProp(unpack(tbGDPL)).nSeries;
					local nRet = pEquip.Regenerate(
						tbGDPL[1],
						tbGDPL[2],
						tbGDPL[3],
						tbGDPL[4],
						nSeries,
						pEquip.nEnhTimes,			-- 强化次数加一
						pEquip.nLucky,
						nil,
						0,
						pEquip.dwRandSeed,
						pEquip.nStrengthen
					);
					
					if nRet ~= 1 then
						szCurLogMsg = szCurLogMsg..string.format("，转化失败！");
					else
						-- log格式:装备名字(g_d_p_l_五行_强化次数_幸运值_版本号_随机种子_改造等级)
						szCurLogMsg = szCurLogMsg..string.format("，新装备：%s(%d_%d_%d_%d_%d_%d_%d_%d_%d_%d)",pEquip.szName,
							pEquip.nGenre, pEquip.nDetail, pEquip.nParticular, pEquip.nLevel, pEquip.nSeries, 
							pEquip.nEnhTimes, pEquip.nLucky, 0, pEquip.dwRandSeed, pEquip.nStrengthen);
					end
				end
			else
				szCurLogMsg = szCurLogMsg..string.format("，不转换！");
			end
			
			table.insert(tbLogMsg, szCurLogMsg);		
		end
	end
	table.insert(tbLogMsg, string.format("申请转换装备成%s%s装备。SwitchEquipSeries Log End！", szRouteName, szEquipType));
	
	-- 写LOG
	for _, szLogMsg in pairs(tbLogMsg) do
		Dbg:WriteLog("SwitchEquipSeries", pPlayer.szAccount, pPlayer.szName, szLogMsg);
	end
	
	local szMsg = string.format("你成功将装备转换到<color=yellow>%s%s<color>装备！", szRouteName, szEquipType);
	pPlayer.Msg(szMsg);

	me.CloseSwitchEquipSeries();
	
	-- 关闭UI
	pPlayer.CallClientScript({"UiManager:CloseWindow", "UI_SWITCH_PANEL"});
end
Item.c2sFun["OnSwitchOK"] = Item.ApplySwitchOK;

function Item:ApplySwitchCancel()
	me.CloseSwitchEquipSeries();
end
Item.c2sFun["OnSwitchCancel"] = Item.ApplySwitchCancel;
	
-- 是否已经加入了指定门派指定路线
function Item:IsSelectFactionRoute(nFaction, nRoute)
	if nFaction <= 0 or nFaction > 12 then
		return 0;
	end
	
	if nRoute <= 0 or nRoute > 2 then
		return 0;
	end
	
	local nMyRoute = nil;
	if nFaction == me.nFaction then  -- 如果是当前应用门派，路线以me.nRouteId为准，不取任务变量（任务变量有可能并不同步）
		nMyRoute = me.nRouteId;
	elseif (Faction:IsInit(me) == 1) then  -- 如果不是当前应用门派，且任务变量组还没有初始化，从逻辑上是讲不通的，始终验证不通过；否则取任务变量
		-- 先判断是否学了这个门派
		local tbGerneFaction = Faction:GetGerneFactionInfo(me);
		local bLearnFaction = 0;
		for _, nLearnedFaction in pairs(tbGerneFaction) do
			if (nFaction == nLearnedFaction) then
				bLearnFaction = 1;
				break;
			end
		end	
		
		-- 再判断是否有对应门派的路线
		if bLearnFaction == 1 then
			local nFactionGroupId = Faction.tbFactionRecGroupId[nFaction];
			nMyRoute = me.GetTask(nFactionGroupId, Faction.TSKID_FACTION_ROUTE);
		end
	end
	
	if not nMyRoute or nMyRoute ~= nRoute then
		return 0;
	end
	
	return 1;
end

function Item:CheckInfoFormat(tbSelectInfo)
	if not tbSelectInfo then
		return 0;
	end
	
	if not tbSelectInfo.nFaction or not tbSelectInfo.nRoute then
		return 0;
	end
	
	if tbSelectInfo.nFaction <= 0 or tbSelectInfo.nFaction > 12 or
		tbSelectInfo.nRoute <= 0 or tbSelectInfo.nRoute > 2 then
			
		return 0;
	end
	
	if not tbSelectInfo.tbSwitchInfo or type(tbSelectInfo.tbSwitchInfo) ~= "table" then
		return 0;
	end
	
	return 1;	
end


end


Item:LoadSwitchSetting(Item.FILE_PATH..Item.SWITCH_FILE_WUQI);
Item:LoadSwitchSetting(Item.FILE_PATH..Item.SWITCH_FILE_FANGJUSHOUSHI);