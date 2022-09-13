------------------------------------------------------
-- 文件名　：zhenyuan.lua
-- 创建者　：
-- 创建时间：2010-07-02 16:32:48
-- 功能    ：真元
-- 说明	   ：真元自身的特殊属性存在GenInfo里面，存储关系为：
--			 GenInfo(1), 高8位存属性1，次8位存属性2，接下来8位存属性3，最后8位存属性4（每个值表示初始属性的大小）
--			 GenInfo(2), 高8位存属性资质1，次8位存属性资质2，接下来8位存属性资质3，最后8位存属性资质4（每个值表示的是属性资质的档次）
--           GenInfo(3), 高8位存模板ID，后面8位存等级，接下来14位存经验，最后2位表示是否装备过
--			 属性资质也需要存盘吗？？？
------------------------------------------------------
Require("\\script\\item\\class\\equip.lua");
Require("\\script\\item\\zhenyuan\\zhenyuan_define.lua");


local ATTRIB_COUNT				= 4;		-- 每个真元的属性数量
local ATTRIBENHANCE_INTERVAL	= 5;		-- 每隔5级提升一次属性的值

local tbZhenYuan = Item:NewClass("zhenyuan", "equip");
if not tbZhenYuan then
	tbZhenYuan = Item:GetClass("zhenyuan");
end

tbZhenYuan.MASKICON_FILE = "\\image\\effect\\other\\zhenyuan_maskicon.spr";

------------------- 道具TIP相关 ----------------- 
function tbZhenYuan:CalcValueInfo()
	local nValue = Item.tbZhenYuan:GetZhenYuanValue(it);
	local nStarLevel, szNameColor, szTransIcon = Item:CalcStarLevelInfo(it.nVersion, it.nDetail, it.nLevel, nValue);
	
	local szMaskIcon = nil;
	if Item.tbZhenYuan:GetEquiped(it) == 1 then
		szMaskIcon = self.MASKICON_FILE;
	end
	return	nValue, nStarLevel, szNameColor, szTransIcon, szMaskIcon;
end

-- 真元装备后绑定
function tbZhenYuan:OnUse()
	if (me.CanUseItem(it) == 1) and (self:CheckCanEquip() == 1) then
		me.AutoEquip(it);
		it.Bind(1);
	end
	
	return 0;
end

--[[
function tbZhenYuan:GetTitle()
	return it.szName;
end]]--

function tbZhenYuan:CheckCanEquip()
	if it.nParticular >= 8 and it.nParticular <= 11 then
		return 0;
	end
	return 1;
end

-- TODO：TIP的信息还不够完整，到时还需要添加
function tbZhenYuan:GetTip(nState, tbEnhRandMASS, tbEnhEnhMASS)
	local szTip = "";
	if Item.tbZhenYuan:GetEquiped(it) == 1 then
		szTip = szTip.."Đã hộ thể\n\n";
	else
		szTip = szTip.."Chưa hộ thể\n\n";
	end
	
	szTip = szTip..self:Tip_ReqAttrib();
	szTip = szTip..self:Tip_LevelAndExp();
		
	-- 属性资质
	szTip = szTip..self:Tip_AtribTip();

	-- 总价值
	szTip = szTip..self:Tip_Value();
	
	return szTip;
end

-- 属性的TIP
function tbZhenYuan:Tip_AtribTip()
	local szTip = "<color=blue>Cấp sao thuộc tính và tư chất<color>\n\n";
	
	local tbBaseAttrib = it.GetBaseAttrib();
	local tbAttribEnhanced = Item.tbZhenYuan:GetAttribEnhanced(it, 0);
			
	for i = 1, ATTRIB_COUNT do
		local nStarLevel = Item.tbZhenYuan["GetAttribPotential"..i](Item.tbZhenYuan, it);
		local szStar = Item.tbZhenYuan:GetAttribStar(nStarLevel, 1);
				
		local szAttribTipName = Item.tbZhenYuan:GetAttribTipName(tbBaseAttrib[i].szName);
		local nBase = Item.tbZhenYuan["GetAttrib"..i.."Range"](Item.tbZhenYuan, it);
		-- 加0.5做四舍五入运算
		local nAdd = math.floor(Item.tbZhenYuan:GetAttribMapValue(tbBaseAttrib[i].szName, tbAttribEnhanced[i]) + 0.5);
		nAdd = math.min(Item.tbZhenYuan.MAPPINGVALUE_MAX_ENHANCE, nAdd);
		local nSum = nBase + nAdd;

		local nAttribId = Item.tbZhenYuan:GetAttribMagicId(it, i);
		szTip = szTip..string.format("<color=green>%s: %d[%d+%d]<color>\n\n", 
			szAttribTipName, nSum, nBase, nAdd);
			
		szTip = szTip..string.format(" %s\n", szStar);
	end
	
	return szTip;
end

function tbZhenYuan:Tip_LevelAndExp()
	return string.format("Cấp chân nguyên: %d [%d/%d]\n\n", 
		Item.tbZhenYuan:GetLevel(it), 
		Item.tbZhenYuan:GetCurExp(it), 
		Item.tbZhenYuan:GetNeedExp(Item.tbZhenYuan:GetLevel(it)));
end

-- 总价值， 战斗力排名，战斗力加成
function tbZhenYuan:Tip_Value()
	local szTip = "";
	
	szTip = szTip..string.format("\nTổng điểm chân nguyên: %d\n", Item.tbZhenYuan:GetZhenYuanValue(it)/10000);
	--szTip = szTip..string.format("真元当前排名：%d\n", Item.tbZhenYuan:GetRank(it));
	--szTip = szTip..string.format("战斗力加成:%d\n", Item.tbZhenYuan:GetFightPower(it));
	
	return szTip;
end

------------------- 访问真元特有道具属性的相关接口 ----------------- 

Item.tbZhenYuan = Item.tbZhenYuan or {};
tbZhenYuan = Item.tbZhenYuan;

for key, _ in pairs(tbZhenYuan.tbParam) do
	local funGet = 
		function (_self, ...)
			return tbZhenYuan.GetParam(_self, key, unpack(arg));
		end
		
	rawset(tbZhenYuan, "Get"..key, funGet);
end

-- 第二个参数为number时，应该是道具ID；或者直接为道具对象
function tbZhenYuan:GetParam(szFun, varItem)
	local pItem = nil;
	if type(varItem) == "number" then
		pItem = KItem.GetObjById(varItem);
	elseif type(varItem) == "userdata" then
		pItem = varItem;
	end
	
	if (not pItem) then
		return;
	end
	
	local tbFunParam = self.tbParam[szFun];
	local nValue = Lib:LoadBits(pItem.GetGenInfo(tbFunParam[1]), tbFunParam[2], tbFunParam[3]);
	return nValue;
end

-- 获取真元某条属性的魔法属性ID
-- 第一个参数或者为道具的dwId，或者直接为道具对象
-- 当返回值为0时，表示类型错误
function tbZhenYuan:GetAttribMagicId(varItem, nIndex)
	local szMagicName = "";
	if (type(varItem) == "number") then
		local pItem = KItem.GetObjById(varItem);
		local tbBaseAttrib = pItem.GetBaseAttrib();
		szMagicName = tbBaseAttrib[nIndex].szName;	
	elseif (type(varItem) == "userdata") then
		local pItem = varItem;
		local tbBaseAttrib = pItem.GetBaseAttrib();
		szMagicName = tbBaseAttrib[nIndex].szName;
	elseif (type(varItem) == "table") then
		local tbBaseAttribSetting = KItem.GetEquipBaseProp(unpack(varItem));
		szMagicName = tbBaseAttribSetting.tbBaseAttrib[nIndex].szName;
	end
	
	if szMagicName == "" then
		return;
	end
	
	-- 注意：这里的nAttribId一定是从attribsetting.txt中读取出来的值，不是魔法属性实际类型的枚举值	
	local nAttribId = Item.tbZhenYuanSetting.tbAttribNameToId[szMagicName];
	if not nAttribId then
		nAttribId = 0;
	end
	
	return nAttribId;	
end

-- 通过属性ID或者属性名获取属性TIP名字
function tbZhenYuan:GetAttribTipName(varAttrib)
	local nId = 0;
	if type(varAttrib) == "number" then
		nId = varAttrib;
	elseif type(varAttrib) == "string" then
		nId = Item.tbZhenYuanSetting.tbAttribNameToId[varAttrib];
	end
	
	if not nId or nId == 0 then
		return "";
	end
	
	return Item.tbZhenYuanSetting.tbAttribSetting[nId].szTipText;
end

-- 获取映射过后属性的加点值
function tbZhenYuan:GetAttribMapValue(varAttrib, nOrgValue)
	local nMapValue = 0;
	local nId = 0;
	if type(varAttrib) == "number" then
		nId = varAttrib;
	elseif type(varAttrib) == "string" then
		nId = Item.tbZhenYuanSetting.tbAttribNameToId[varAttrib];
	end
	
	if not nId or nId == 0 then
		return 0;
	end
	
	local nMaxValue = Item.tbZhenYuanSetting.tbAttribSetting[nId].nMaxValue;
	-- 成长值只占最大值的96%
	nMapValue = nOrgValue/(nMaxValue * self.MAPPINGVALUE_MAX_ENHANCE/self.MAPPINGVALUE_MAX) * self.MAPPINGVALUE_MAX;
		
	
	if nMapValue < self.MAPPINGVALUE_MIN then
		nMapValue = self.MAPPINGVALUE_MIN;
	elseif nMapValue > self.MAPPINGVALUE_MAX_ENHANCE then
		nMapValue = self.MAPPINGVALUE_MAX_ENHANCE;
	end

	return nMapValue;
end

-- 在指定真元上查找指定魔法属性ID的属性索引，找到返回索引，没找到返回0
function tbZhenYuan:GetAttribIndex(varItem, nAttribId)
	local nAttribIndex = 0;
	
	for i = 1, self.ATTRIB_COUNT do
		local nId = self:GetAttribMagicId(varItem, i);
		if nAttribId == nId then
			nAttribIndex = i;
			break;
		end 
	end
	
	return nAttribIndex;
end	

-- 当前等级升到下一级共需要多少经验
function tbZhenYuan:GetNeedExp(nLevel)
	-- 满级后， 不需要再升级了
	if nLevel < self.MINLEVEL or nLevel >= self.MAXLEVEL then
		return 0;
	end
	
	local nNeedExp = Item.tbZhenYuanSetting.tbLevelSetting[nLevel].nNeedExp;
	
	return nNeedExp;
end

-- 属性资质的价值量和星级
function tbZhenYuan:GetAttribPotentialValue(pItem)
	local tb = {};
	
	for i = 1, self.ATTRIB_COUNT do
		local szFun = "GetAttribPotential"..i;
		local nPotenLevel = self[szFun](self, pItem);
		
		-- 在生成的时候，属性资质的价值量决定星级
		-- 在生成以后，通过属性资质的星级来获取价值量
		local nAttribId = self:GetAttribMagicId(pItem, i);
		local nCommonValue = Item.tbZhenYuanSetting.tbAttribSetting[nAttribId]["StarLevel"..nPotenLevel.."Value"];
		local nWeight = Item.tbZhenYuanSetting.tbAttribSetting[nAttribId].nWeight;
		local nPotenValue = nCommonValue * nWeight;
		
		table.insert(tb, i, {nPotenValue, nPotenLevel});
	end
	
	return tb;
end

-- 获得某条属性资质的价值量星级，这里返回的是重组字符串，不是星级数
-- nType：1表示图片，2表示取文本
function tbZhenYuan:GetAttribStar(nPotenLevel, nType)
	local tbSetting = Partner.tbStarLevel;
	local szFillStar = "";
	local szEmptyStar = "";
	if nType == 1 and tbSetting and tbSetting[nPotenLevel] then
		szFillStar = string.format("<pic=%s>", tbSetting[nPotenLevel].nFillStar - 1);
		szEmptyStar = string.format("<pic=%s>", tbSetting[nPotenLevel].nEmptyStar - 1);
	else
		szFillStar = "★";
		szEmptyStar = "☆";
	end
	local szStar = "";
	
	for i = 1, math.floor(nPotenLevel / 2) do
		szStar = szStar..szFillStar;
		if i % 3 == 0 then
			szStar = szStar.." ";
		end
	end
	if (nPotenLevel % 2 ~= 0) then
		szStar = szStar..szEmptyStar;
	end
	
	return szStar;
end

-- 属性的初始价值量
function tbZhenYuan:GetAttribBaseValue(pItem)
	--local pItem = KItem.GetObjById(dwId);
	if not pItem then
		return;
	end
	
	local tb = {};
	local nZhenyuanTempl = self:GetTemplateId(pItem);
	for i = 1, self.ATTRIB_COUNT do
		-- 随机档次
		local szFun = "GetAttrib"..i.."Range";
		local nRand = self[szFun](self, pItem);
		
		local nAttribId = self:GetAttribMagicId(pItem, i);
		local nWeight = Item.tbZhenYuanSetting.tbAttribSetting[nAttribId].nWeight;	-- 属性类型加权值
		
		-- 单条属性的价值量能取到的上限值和下限值
		local nValueMin = Item.tbZhenYuanSetting.tbTemplateSetting[nZhenyuanTempl]["nAttrib"..i.."ValueMin"];
		local nValueMax = Item.tbZhenYuanSetting.tbTemplateSetting[nZhenyuanTempl]["nAttrib"..i.."ValueMax"];
		
		local nAttribValue = math.floor((nRand-2)/(40-2) * nWeight * (nValueMax - nValueMin) + nValueMin);
		
		-- 不能超过上限值或者低于下限值
		if nAttribValue < nValueMin then
			nAttribValue = nValueMin;
		elseif nAttribValue > nValueMax then
			nAttribValue = nValueMax;
		end
		
		table.insert(tb, i, nAttribValue);
	end
	
	--[[
	-- 道具生成的实际数值
	local tbBaseAttrib = pItem.GetBaseAttrib();
	-- 配置表中的数值
	local tbBaseSetting = KItem.GetEquipBaseProp(pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
	-- 提升的值
	local tbEnhanced = self:GetAttribEnhanced(pItem);
	for i = 1, self.ATTRIB_COUNT do
		local nAttribId = self:GetAttribMagicId(pItem, i);
		local nInitValue = tbBaseAttrib[i].tbValue[1];	-- 初始属性的值
		nInitValue = nInitValue - tbEnhanced[i];
		
		local nWeight = Item.tbZhenYuanSetting.tbAttribSetting[nAttribId].nWeight;	-- 属性类型加权值
		
		-- 属性初始值的取值范围
		local nMin = tbBaseSetting.tbBaseAttrib[i].tbRange[1].nMin;
		local nMax = tbBaseSetting.tbBaseAttrib[i].tbRange[1].nMax;
		
		-- 单条属性的价值量能取到的上限值和下限值
		local nValueMin = Item.tbZhenYuanSetting.tbTemplateSetting[nZhenyuanTempl]["nAttrib"..i.."ValueMin"];
		local nValueMax = Item.tbZhenYuanSetting.tbTemplateSetting[nZhenyuanTempl]["nAttrib"..i.."ValueMax"];
		
		local nAttribValue = math.floor((nInitValue - nMin)/(nMax - nMin) * nWeight *  nValueMax);
		
		-- 不能超过上限值或者低于下限值
		if nAttribValue < nValueMin then
			nAttribValue = nValueMin;
		elseif nAttribValue > nValueMax then
			nAttribValue = nValueMax;
		end
		
		table.insert(tb, i, nAttribValue);
	end--]]
	
	return tb;
end

-- 获取真元的等级价值量
function tbZhenYuan:GetLevelValue(nLevel)
	if nLevel < self.MINLEVEL or nLevel > self.MAXLEVEL then
		return 0;
	end
	
	if not Item.tbZhenYuanSetting.tbLevelSetting[nLevel] then
		return 0;
	end
	
	return Item.tbZhenYuanSetting.tbLevelSetting[nLevel].nLevelValue;
end

-- 计算真元的总价值量
function tbZhenYuan:GetZhenYuanValue(pItem)
	-- 属性的初始价值量
	local tbAttribValue = self:GetAttribBaseValue(pItem);
	
	-- 属性资质的价值量
	local tbAttribPotenValue = self:GetAttribPotentialValue(pItem);
	
	-- 等级价值量
	local nLevelValue = self:GetLevelValue(self:GetLevel(pItem));
	
	-- 总价值量
	local nSumValue = nLevelValue;
	for i = 1, self.ATTRIB_COUNT do
		nSumValue = nSumValue + tbAttribValue[i];
		nSumValue = nSumValue + tbAttribPotenValue[i][1];
	end

	return math.floor(nSumValue);
end

-- 属性提升的点数, bForce为1时表示要四舍五入，否则就保留小数
function tbZhenYuan:GetAttribEnhanced(varItem, bForce)
	bForce = bForce or 1;
	local nLevel = self:GetLevel(varItem);
	local nAddTimes = math.floor(nLevel/self.ATTRIBENHANCE_INTERVAL);
	if nAddTimes == 0 then
		return {0,0,0,0};
	end
	
	local tb = {};
	for i = 1, self.ATTRIB_COUNT do
		local szFun = "GetAttribPotential"..i;
		local nPotenLevel = self[szFun](self, varItem);
	
		local nAttribId = self:GetAttribMagicId(varItem, i);
		-- 读表，得到当前的属性资质星级下每次能提升多少点属性点
		local nAddedPerTime = Item.tbZhenYuanSetting.tbAttribSetting[nAttribId]["StarLevel"..nPotenLevel.."Growth"];
		-- 四舍五入
		local nAddValue = nAddedPerTime * nAddTimes;
		if bForce == 1 then
			nAddValue = math.floor(nAddValue + 0.5);
		end
		table.insert(tb, i, nAddValue);
	end
	
	return tb;
end

-- 返回值：是否放入的太多，能到达的等级，剩余经验（返回值直接set就可以了，不要add）
function tbZhenYuan:GetExpAdded(pItem, tbItem)
	local nNewLevel = self:GetLevel(pItem);
	--local nBalanceExp = self:GetCurExp(pItem);
	local bTooMany = 0;		-- 是否放得太多(已经能达到满级了，还要往里放经验书就算放多了)

	local nBookCount = Lib:CountTB(tbItem);
	local nExpTime = nBookCount * self.EXPTIMES_XIULIAN;
	local nLevelUp, nBalanceExp, nNeedTime, nSumExp = self:CalExpFromTime(pItem, nExpTime);

	nNewLevel = nNewLevel + nLevelUp;
	if nNewLevel >= 120 then
		-- 如果总放入的时间经验比需要的多的大于一本的时间，是浪费，给提示
		if nExpTime >= self.EXPTIMES_XIULIAN + nNeedTime then
			bTooMany = 1;
		end
		nNewLevel = 120;
	end
	
	return bTooMany, nNewLevel, nBalanceExp;
end

-- 计算指定真元，添加指定时间的基准经验后能提升的等级和剩余经验
-- 返回值，能提升的等级，剩余经验，需要用多少经验，总共提升的经验点数
function tbZhenYuan:CalExpFromTime(pItem, nExpTime)
	local nCurExp = self:GetCurExp(pItem);
	local nLevel = self:GetLevel(pItem);
	local nNeedExp = self:GetNeedExp(nLevel);
	local nBaseExp = Item.tbZhenYuanSetting.tbLevelSetting[nLevel].nBaseExpPerMin;
	local nSumExp = 0;		-- 统计共加了多少经验
	local nNeedTime = 0;
	
	local nLevelUp = 0;
	while (nExpTime > 0) do
		if (nLevelUp + nLevel >= self.MAXLEVEL) then
			break;
		end
		
		local nUseTime = math.ceil((nNeedExp - nCurExp)/nBaseExp); -- 升到下一级需要消耗多少的基准时间
		if nUseTime > nExpTime then
			nCurExp = nCurExp + nExpTime * nBaseExp;
			nSumExp = nSumExp + nExpTime * nBaseExp;
			nNeedTime = nNeedTime + nExpTime;
			nExpTime = 0;
			break;
		end
		
		nCurExp = nCurExp + nUseTime * nBaseExp;
		nSumExp = nSumExp + nUseTime * nBaseExp;
		nNeedTime = nNeedTime + nUseTime;
		nCurExp = nCurExp - nNeedExp;
		nExpTime = nExpTime - nUseTime;		
		nLevelUp = nLevelUp + 1;
		nNeedExp = self:GetNeedExp(nLevel + nLevelUp);
		nBaseExp = Item.tbZhenYuanSetting.tbLevelSetting[nLevel + nLevelUp].nBaseExpPerMin;
	end
	
	return nLevelUp, nCurExp, nNeedTime, nSumExp;
end

-- 因为真元的名字是动态的，所以需要一个接口在生成真元之后做名字初始化操作
function tbZhenYuan:InitName()
	local nZhenyuanTempl = self:GetTemplateId(it);
	if not nZhenyuanTempl or nZhenyuanTempl <= 0 then
		return;
	end
	
	local nParterId = Item.tbZhenYuanSetting.tbZhenYuanTempToPartnerId[nZhenyuanTempl];
	if not nParterId then
		return;
	end
	
	if not Item.tbZhenYuanSetting.tbPartnerToZhenYuan[nParterId] then
		return;
	end
	
	local szName = "";
	if self:GetEquiped(it) == 1 then
		szName = "[Chân nguyên hộ thể]"..Item.tbZhenYuanSetting.tbPartnerToZhenYuan[nParterId].szPartnerName;
	else
		szName = Item.tbZhenYuanSetting.tbPartnerToZhenYuan[nParterId].szName;
	end
	
	return szName;
end

function tbZhenYuan:OnZhenYuanDrop()
	assert(it);
	
if MODULE_GAMESERVER then
	-- 记录真元护体的情况
	if (self:GetEquiped(it) ~= 1) then
		local tbBaseAttrib = it.GetBaseAttrib();
		local tbAttribEnhanced = Item.tbZhenYuan:GetAttribEnhanced(it.dwId);
		local tbAttrib = {};
		for i = 1, self.ATTRIB_COUNT do
			-- 加0.5做四舍五入运算
			tbAttrib[i] = self["GetAttrib"..i.."Range"](self, it) + 
				math.floor(self:GetAttribMapValue(tbBaseAttrib[i].szName, tbAttribEnhanced[i]) + 0.5);
		end
		Dbg:WriteLog("Hệ thống chân nguyên", me.szName, "Chân nguyên hộ thể", string.format("%s_%s_%d_%1.0f_[%d,%d,%d,%d,%d,%d,%d,%d]",
				it.szName, it.szGUID, self:GetLevel(it), self:GetZhenYuanValue(it),
				self:GetAttribPotential1(it), tbAttrib[1],
				self:GetAttribPotential2(it), tbAttrib[2],
				self:GetAttribPotential3(it), tbAttrib[3],
				self:GetAttribPotential4(it), tbAttrib[4])
			);
	end
	
	self:SetEquiped(it, 1);
	
	if self:GetParam1(it) == 1 and IsGlobalServer() == false then
		Ladder.tbGuidLadder:ApplyChangeValue(self:GetLadderId(it), it.szGUID, me.szName, self:GetZhenYuanValue(it)/10000);
	end 
end -- if MODULE_GAMESERVER then
	
	return self:InitName();
end

-- 检查能否炼化并计算炼化后的数据，服务端客户端共用逻辑
-- 当不能炼化时，返回非1和错误信息
-- 如果能炼化，返回炼化后提升的对应属性的属性资质星级下限和上限，下限和上限各自的概率
-- bPreView表示是否是预览信息，如果是预览炼化信息，不需要检查银两；否则要检查银两
function tbZhenYuan:CalcRefineInfo(pDestItem, pSrcItem, nAttribId, bPreView)
	-- 判断等级
	bPreView = bPreView or 0;
	-- 检查银两
	if bPreView ~= 1 then
		if me.nCashMoney < self.REFINE_COST_COUNT then
			return 2, "Luyện hóa cần 2 vạn bạc. Bạc trong túi không đủ!";
		end
	end

	local varRes1 = self:CheckRefineItem(pDestItem, 1);
	local varRes2 = self:CheckRefineItem(pSrcItem, 2, pDestItem);
	
	if type(varRes1) ~= "number" then
		return 0, varRes1;
	end
	if type(varRes2) ~= "number" then
		return 0, varRes2;
	end
	
	-- 两个真元都必须有指定类型的魔法属性才能炼化
	local nDestAttribIndex = self:GetAttribIndex(pDestItem, nAttribId);
	local nSrcAttribIndex = self:GetAttribIndex(pSrcItem, nAttribId);
	if nDestAttribIndex == 0 or nSrcAttribIndex == 0 then
		return 0, "Thuộc tính ma pháp chưa chỉ định!"
	end	
	
	-- 判断属性，用来炼化的真元对应的属性资质的星级不能低于被炼化的真元属性资质的星级
	local szFun = "GetAttribPotential"..nDestAttribIndex;
	local nDestStarLevel = self[szFun](self, pDestItem);	-- 被炼化真元的指定属性的属性资质等级
	szFun = "GetAttribPotential"..nSrcAttribIndex;
	local nStrStarLevel = self[szFun](self, pSrcItem);		-- 用来炼化的真元指定属性的属性资质等级
	
	if nDestStarLevel >= self.ATTRIB_MAXSTARLEVEL then
		return 0, "Tư chất chân nguyên chỉ định đã đầy, hãy chọn thuộc tính luyện hóa khác!";
	elseif (nDestStarLevel > nStrStarLevel) then
		return 0, "Cấp sao tư chất chân nguyên luyện hóa không được thấp hơn cấp sao tư chất chân nguyên được luyện hóa";
	end	
	
	-- 计算能提升的资质星级
	local nSrcValue = self:GetZhenYuanValue(pSrcItem);
	local tbDestValue = self:GetAttribPotentialValue(pDestItem);
	nSrcValue = nSrcValue + tbDestValue[nDestAttribIndex][1];
	local nStarLevelAddedLeft = 0;	-- 能提升的属性资质星级下限
	local nLeftRate = 0;			-- 按下限提升的概率
	local nStarLevelAddedRight = 0;	-- 能提升的属性资质星级上限
	local nRightRate = 0;			-- 按上限提升的概率
	local nWeight = Item.tbZhenYuanSetting.tbAttribSetting[nAttribId].nWeight;		-- 权重
	local nNeedValue;
	while(nSrcValue > 0) do
		local nNewStarLevel = nDestStarLevel + nStarLevelAddedLeft;
		if nNewStarLevel >= self.ATTRIB_MAXSTARLEVEL then
			break;
		end
		nNeedValue = Item.tbZhenYuanSetting.tbAttribSetting[nAttribId]["StarLevel"..(nNewStarLevel+1).."Value"];	
		nNeedValue = nNeedValue * nWeight;

		if nSrcValue >= nNeedValue then
			nStarLevelAddedLeft = nStarLevelAddedLeft + 1;
		else
			break;
		end
	end

	-- 正常情况下，上限应该比下限大1
	nStarLevelAddedRight = nStarLevelAddedLeft + 1;
	-- 如果刚好用光价值量，则是固定升到某一档次，上限跟下限相等

	if nSrcValue == nNeedValue then
		nStarLevelAddedRight = nStarLevelAddedLeft;
		nLeftRate = 100;
		nRightRate = 100;
	elseif nSrcValue <= nNeedValue and nStarLevelAddedLeft < self.REFINE_MAXLEVELUP then
		-- 还有剩余价值量，且提升档次还没到1.5星，则有概率升到下一档次，上限比下限大1
		nStarLevelAddedRight = nStarLevelAddedLeft + 1;
		local nNowStarLevel = nDestStarLevel + nStarLevelAddedLeft;
		local nValue1 = Item.tbZhenYuanSetting.tbAttribSetting[nAttribId]["StarLevel"..nNowStarLevel.."Value"];
		local nValue2 = Item.tbZhenYuanSetting.tbAttribSetting[nAttribId]["StarLevel"..(nNowStarLevel+1).."Value"];
		nRightRate = math.floor((nSrcValue-nValue1)/(nValue2 - nValue1) * nWeight * 100)
		--nRightRate = math.ceil(nSrcValue/((nValue2-nValue1)*nWeight) * 100);
		nLeftRate = 100 - nRightRate;
	elseif nStarLevelAddedLeft >= self.REFINE_MAXLEVELUP then
		nStarLevelAddedLeft = self.REFINE_MAXLEVELUP;
		nStarLevelAddedRight = nStarLevelAddedLeft;
		nLeftRate = 100;
		nRightRate = 100;
	end
	
	if nDestStarLevel + nStarLevelAddedLeft >= self.ATTRIB_MAXSTARLEVEL then
		nStarLevelAddedLeft = self.ATTRIB_MAXSTARLEVEL - nDestStarLevel;
		nLeftRate = 100;
		nStarLevelAddedRight = nStarLevelAddedLeft;
		nRightRate = 100;
	end

	return 1, nStarLevelAddedLeft, nStarLevelAddedRight, nLeftRate, nRightRate, nSrcValue;
end

-- 炼化时判断能能否放入道具，nPos为1表示判断主真元，为2表示判断副真元
function tbZhenYuan:CheckRefineItem(pItem, nPos, pAttach)
	if pItem.szClass ~= "zhenyuan" then
		return "Chỉ có thể đặt chân nguyên vào.";
	end
		
	if nPos == 1 then
		-- 满级判断
		if self:GetLevel(pItem) ~= self.MAXLEVEL then
			return "Chân nguyên chính cần phải đủ cấp!";
		end
		
		-- 资质满星级判断
		local bIsAllFull = 1;
		for i = 1, self.ATTRIB_COUNT do
			local szFun = "GetAttribPotential"..i;
			if (self[szFun](self, pItem) ~= self.ATTRIB_MAXSTARLEVEL) then
				bIsAllFull = 0;
				break;
			end
		end
		
		if bIsAllFull == 1 then
			return "Tư chất chân nguyên này đã đầy, không cần luyện hóa!";
		end
		
	elseif nPos == 2 then
		-- 要先放入主真元
		local pMain = me.GetItem(Item.ROOM_ZHENYUAN_REFINE_MAIN, 0)
		pMain = pAttach or pMain;

		if not pMain then
			return "Hãy đặt chân nguyên chính vào trước.";
		end
		
		-- 不能已护体
		if self:GetEquiped(pItem) == 1 then
			return "Chân nguyên hộ thể không thể dùng luyện hóa các chân nguyên khác!";
		end
		
		-- 必须要与主真元有相同属性
		local bHaveSameAttrib = 0;
		for i = 1, self.ATTRIB_COUNT do
			for j = 1, self.ATTRIB_COUNT do
				if self:GetAttribMagicId(pMain, i) == self:GetAttribMagicId(pItem, j) then
					bHaveSameAttrib = 1;
					break;
				end
			end
		end
		
		if bHaveSameAttrib == 0 then
			return "Thuộc tính chân nguyên phụ không giống với chân nguyên chính, không thể luyện hóa!";
		end
	end
	
	return 1;
end

-- 获取排行榜所在ID
function tbZhenYuan:GetLadderId(varItem)
	return self:GetTemplateId(varItem);
end

-- 根据排行榜的排名获取当前应当提升的战斗力
function tbZhenYuan:GetFightPowerFormRank(nRank)
	if nRank < self.RANK_MIN or nRank > self.RANK_MAX then
		return 0;
	end
	
	-- 如果配置表中直接有该排名对应的战斗力，直接返回该值；
	-- 否则需要在最近的两个值之间计算
	if Item.tbZhenYuanSetting.tbRankInfo[nRank] then
		return Item.tbZhenYuanSetting.tbRankInfo[nRank];
	end
	
	local nMin = self.RANK_MIN;
	local nMax = self.RANK_MAX;
	local nFightPowerMin, nFightPowerMax = 0, 0;
	for i, nFightPower in pairs(Item.tbZhenYuanSetting.tbRankInfo) do
		if i <= nRank and i >= nMin then
			nMin = i;
			nFightPowerMin = nFightPower;
		elseif i >= nRank and i <= nMax then
			nMax = i;
			nFightPowerMax = nFightPower;
		end
	end
	
	-- 加0.5做四舍五入运算
	local nValue = math.floor((nRank - nMin + 1)/(nMax - nMin + 1) * (nFightPowerMax - nFightPowerMin) + nFightPowerMin + 0.5);
	return nValue;
end

-- 获取某个真元提升的战斗力
function tbZhenYuan:GetFightPower(pItem)
	local nRank = self:GetRank(pItem);
	local nFightPower = self:GetFightPowerFormRank(nRank);

	return nFightPower;	
end

-- 设置开关状态
function tbZhenYuan:SwitchState(nState)
	if self.bOpen == nState then
		return;
	end
	
	self.bOpen = nState;
	if MODULE_GAMESERVER then
		for _, pPlayer in pairs(KPlayer.GetAllPlayer()) do
			pPlayer.CallClientScript({"Item.tbZhenYuan:SwitchState", nState});
		end
	end
	
	-- 真元系统的开关会影响同伴的基本数量
	local nPartnerLimitCount = Partner.PARTNERLIMIT_MIN;
	if nState == 0 then
		nPartnerLimitCount = 3;
	elseif nState == 1 then
		nPartnerLimitCount = 4;
	end
	
	Partner:SetPartnerBaseCount(nPartnerLimitCount);
end

function tbZhenYuan:GetConvertCost(pPartner)
	if not pPartner then
		return;
	end
	
	local _, _, nPartnerValue, _ = Partner:GetZhenYunInfoFromPartner(pPartner);
	local nCost = math.ceil(nPartnerValue * self.CONVERT_COST_RATE /100);
	
	return nCost;
end

-- 使用历练经验时的检查函数 
function tbZhenYuan:LiLianCheck(tbGiftSelf, pPickItem, pDropItem, nX, nY)
	local nCount = 0;
	local pItem = tbGiftSelf:First();
	while(pItem) do
		nCount = nCount + 1;
		pItem = tbGiftSelf:Next();
	end
	
	local szContent = string.format("Xin đặt vào <color=green>1-%d<color> chân nguyên chưa đầy cấp.<enter><enter>Chý ý: kinh nghiệm luyện hóa cho 1 chân nguyên tăng 1 cấp, có thể khiến toàn bộ chân nguyên dưới đây tăng 1 cấp! Đề nghị <color=green>mỗi lần chỉ nên đặt %d<color>", self.LILIAN_MAX_COUNT, self.LILIAN_MAX_COUNT);
	if pDropItem then
		if pDropItem.IsZhenYuan() == 0 then
			UiManager:OpenWindow(Ui.UI_INFOBOARD, "Chỉ có thể đặt vào chân nguyên!")
			me.Msg("Chỉ có thể đặt vào chân nguyên!");
			return 0;
		end
		
		if self:GetLevel(pDropItem) >= self.MAXLEVEL then
			UiManager:OpenWindow(Ui.UI_INFOBOARD, "Chỉ có thể đặt vào chân nguyên chưa đầy cấp!");
			me.Msg("Chỉ có thể đặt vào chân nguyên chưa đầy cấp!");
			return 0;
		end
				
		if nCount >= self.LILIAN_MAX_COUNT then
			local szMsg = string.format("Mỗi lần chỉ có thể đem %d chân nguyên đồng thời tăng kinh nghiệm!", self.LILIAN_MAX_COUNT);
			me.Msg(szMsg);
			UiManager:OpenWindow(Ui.UI_INFOBOARD, szMsg);
			return 0;
		end
				
		local nLiLianTime = me.GetTask(self.EXPSTORE_TASK_MAIN, self.EXPSTORE_TASK_SUB);
		local nLiLianUsed = 0;
		local pItem = tbGiftSelf:First();
		while pItem do
			local _, _, nTemp = self:CalExpFromTime(pItem, nLiLianTime);
			if nTemp < nLiLianUsed or nLiLianUsed == 0 then
				nLiLianUsed = nTemp;
			end
			pItem = tbGiftSelf:Next();
		end
		
		local _, _, nTemp = self:CalExpFromTime(pDropItem, nLiLianTime);
		if nTemp < nLiLianUsed or nLiLianUsed == 0 then
			nLiLianUsed = nTemp;
		end
		
		szContent = string.format("Xin đặt vào <color=green>1-%d<color> chân nguyên chưa đầy cấp.<enter><enter>Mỗi chân nguyên sẽ nhận được %d phút kinh nghiệm luyện hóa!", self.LILIAN_MAX_COUNT, nLiLianUsed);
	end
	
	if pPickItem then
		nCount = nCount - 1;
		if nCount <= 0 then
			szContent = string.format("Xin đặt vào <color=green>1-%d<color> chân nguyên chưa đầy cấp.<enter><enter>Chý ý: kinh nghiệm luyện hóa cho 1 chân nguyên tăng 1 cấp, có thể khiến toàn bộ chân nguyên dưới đây tăng 1 cấp! Đề nghị <color=green>mỗi lần chỉ nên đặt %d<color>", self.LILIAN_MAX_COUNT, self.LILIAN_MAX_COUNT);
		else		
			local nLiLianTime = me.GetTask(self.EXPSTORE_TASK_MAIN, self.EXPSTORE_TASK_SUB);
			local nLiLianUsed = 0;
			local pItem = tbGiftSelf:First();
			while pItem do
				if pItem.dwId ~= pPickItem.dwId then
					local _, _, nTemp = self:CalExpFromTime(pItem, nLiLianTime);
					if nTemp < nLiLianUsed or nLiLianUsed == 0 then
						nLiLianUsed = nTemp;
					end
				end
				pItem = tbGiftSelf:Next();
			end
			
			szContent = string.format("Xin đặt vào <color=green>1-%d<color> chân nguyên chưa đầy cấp.<enter><enter>Mỗi chân nguyên sẽ nhận được %d phút kinh nghiệm luyện hóa!", self.LILIAN_MAX_COUNT, nLiLianUsed);
		end
	end
	
	tbGiftSelf:UpdateContent(szContent);	
	return 1;
end

function tbZhenYuan:TryToPersuade(pPlayer, pNpc, nItemLevel)
	if not Partner.tbPersuadeInfo or not Partner.tbPartnerAttrib then
		return 0, "Sử dụng đạo cụ thất bại!";
	end
	
	if pPlayer.nFaction == 0 then
		return 0, "Chưa gia nhập môn phái không thể thuyết phục đồng hành!";
	end
	
	if pPlayer.nLevel < 100 then		-- 100级以后才可以说服同伴
		return 0, "Hãy đạt cấp 100, rồi hãy tới ngưng tụ Chân nguyên!";
	end
	
	if pPlayer.CountFreeBagCell() < 1 then
		return 0, "Túi đã đầy, hãy sắp xếp lại!";
	end
	
	local nPartnerId = Partner.tbPersuadeInfo[pNpc.nTemplateId];
	if not nPartnerId  then
		return 0, "Tên này trông rất hung dữ, tốt nhất nên tránh xa. Hãy thử với những tên có trái tim cạnh biểu tượng xem sao.";
	end
	
	if (nItemLevel ==  1 and Item:GetClass("zhenyuan_tie").tbADVLevelNpc[pNpc.nTemplateId]) or (nItemLevel == 2 and not Item:GetClass("zhenyuan_tie").tbADVLevelNpc[pNpc.nTemplateId]) then
		return 0, "Thứ này sao thuyết phục được ai, mau đem loại thiệp thích hợp đến đây.";
	end
	
	local nLifeRate = math.ceil(pNpc.nCurLife/pNpc.nMaxLife * 100);
	if nLifeRate > Partner.tbPartnerAttrib[nPartnerId].nLifeRatio then
		return 0, string.format("Tên này thật ngoan cố, chỉ khi lượng máu thấp hơn %d%%, mới có thể khiến hắn tâm phục khẩu phục!", 
			Partner.tbPartnerAttrib[nPartnerId].nLifeRatio);
	end
	
	local nPlayerMapId, nPlayerPosX, nPlayerPosY = pPlayer.GetWorldPos();
	local nNpcMapId, nNpcPosX, nNpcPosY	= pNpc.GetWorldPos();
	if nPlayerMapId ~= nNpcMapId then
		Dbg:WriteLog("Partner", 
			string.format("Người chơi %s thử ngưng tụ NPC không ở cùng bản đồ thành Chân nguyên của mình!!!", pPlayer.szName));
		return 0, "Sử dụng đạo cụ thất bại!";
	end
	local nDistance = math.ceil(math.sqrt((nPlayerPosX - nNpcPosX) ^ 2 + (nPlayerPosY - nNpcPosY) ^ 2) * 32);
	if nDistance > Partner.MAXPERSUADEDISTANCE then
		return 0, "Đối tượng nghe không rõ bạn nói, hãy tới gần hơn.";
	end
		
	return 1;
end
