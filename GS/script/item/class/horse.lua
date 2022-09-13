-- 马

Require("\\script\\item\\class\\equip.lua");

------------------------------------------------------------------------------------------
-- initialize

local tbHores = Item:NewClass("horse", "equip");
if not tbHores then
	tbHores = Item:GetClass("horse");
end

------------------------------------------------------------------------------------------
-- public

-- 获得Tip字符串：名字
function tbHores:GetTitle(nState, nEnhNameColor)	
	local szTip = string.format("<color=0x%x>", it.nNameColor);
	szTip = szTip..it.szName;
	return	szTip.."<color>\n";
end

-- 计算获得强化、乘骑属性，要求等级、名字颜色
function tbHores:CalcEnhanceAttrib(nState)
	local pTemp = KItem.CreateTempItem(
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
		it.nIndex
	);

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

-- 获取Tip
function tbHores:GetTip(nState, tbEnhRandMASS, tbEnhEnhMASS)		
	local szTip = "";
	szTip = szTip..self:Tip_ReqAttrib();
	szTip = szTip..self:Tip_Durability();
	szTip = szTip..self:Tip_Level();
	szTip = szTip..self:Tip_Series(nState);
	szTip = szTip.."<color>";
	local szBaseAttrib = self:Tip_BaseAttrib(nState);
	if szBaseAttrib and szBaseAttrib ~= "" then
		szTip = szTip.."\n\n<color=blue>Thuộc tính trang bị: <color>"..szBaseAttrib;
	end
	szTip = szTip..tbHores:Tip_RandAttrib(nState, tbEnhRandMASS);
	szTip = szTip..self:Tip_EnhAttrib(nState, tbEnhEnhMASS);
	szTip = szTip..self:Tip_Maker();
	szTip = szTip..self:Tip_RepairInfo(nState);
	szTip = szTip..self:GetBreakUpStuffTips();
	szTip = szTip..self:Tip_Skill();
	
	return	Lib:StrTrim(szTip, "\n");
end

-- 获得Tip字符串：乘骑属性
function tbHores:Tip_RandAttrib(nState, tbEnhRandMASS)	
	local szTip = "";
	local nPos1, nPos2 = KItem.GetEquipActive(KItem.EquipType2EquipPos(it.nDetail));
	local tbMASS = it.GetRandMASS();			-- 获得道具随机魔法属性

	if (nState == Item.TIPS_PREVIEW) or (nState == Item.TIPS_GOODS) then	-- 属性预览状态，显示魔法属性范围
		local nSeries = it.nSeries;
		local tbGenInfo = it.GetGenInfo(0, 1);

		for _, tbMA in ipairs(tbGenInfo) do
			local tbMAInfo = KItem.GetRandAttribInfo(tbMA.szName, tbMA.nLevel, it.nVersion, it.nMAVersion);
			if tbMAInfo then
				szTip = szTip.."\n"..self:GetMagicAttribDescEx(tbMA.szName, self:BuildMARange(tbMAInfo.tbRange));
			end
		end
	else										-- 其他状态，显示魔法属性具体值
		for i = 1, #tbMASS do		
			local tbMA = tbMASS[i];
			local szDesc = "";
			if tbEnhRandMASS then
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
	end
	if szTip ~= "" then
		return	"\n\n<color=blue>Thuộc tính thú cưỡi: <color><color=greenyellow>"..szTip.."<color>";
	end
	return szTip;
end

function tbHores:Tip_Skill()
	local tbSkill =								-- 对应技能ID列表
	{
		it.GetExtParam(17),
		it.GetExtParam(18),
		it.GetExtParam(19),
		it.GetExtParam(20),
	};
	
	local szTip = "";
	for i, nSkill in pairs(tbSkill) do
		if nSkill > 0 then
			szTip = szTip..string.format("\nKỹ năng %d: <color=yellow>%s<color>\n\n", i, KFightSkill.GetSkillName(nSkill));		
		end
	end
	
	return szTip;
end

function tbHores:OnUse()			-- 右键单击自动装备秘籍

	if (me.AutoEquip(it) ~= 1) then
		return	0;
	end

	local tbSkill =								-- 秘籍所对应技能ID列表
	{
		it.GetExtParam(17),
		it.GetExtParam(18),
		it.GetExtParam(19),
		it.GetExtParam(20),
	};

	for _, nSkill in ipairs(tbSkill) do
		if (nSkill > 0) then
			if (1 ~= me.IsHaveSkill(nSkill)) then
				me.AddFightSkill(nSkill, 1);	-- 角色没有对应的技能，则加上该技能
			end
		end
	end

	return	0;

end