
-- 秘籍，通用功能脚本

Require("\\script\\item\\class\\equip.lua");

------------------------------------------------------------------------------------------
-- initialize

local tbBook = Item:NewClass("book", "equip");
if not tbBook then
	tbBook = Item:GetClass("book");
end

------------------------------------------------------------------------------------------
-- public

function tbBook:InitGenInfo()
	return	{ Item.MIN_BOOK_LEVEL, 0 };			-- 秘籍等级和修为初始化
end

function tbBook:OnUse()			-- 右键单击自动装备秘籍

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
				me.AddFightSkill(nSkill, 1);	-- 角色没有秘籍对应的技能，则加上该技能
			end
		end
	end

	return	0;

end

function tbBook:GetTip(nState)		-- 获取秘籍Tip

	local szTip = "";

	local tbSetting = Item:GetExternSetting("book", it.nVersion);
	if not tbSetting then
		return	szTip;
	end

	local tbSkill =								-- 秘籍所对应技能ID列表
	{
		it.GetExtParam(17),
		it.GetExtParam(18),
		it.GetExtParam(19),
		it.GetExtParam(20),
	};

	local nLevel = it.GetGenInfo(1);			-- 秘籍当前等级
	local nKarma = it.GetGenInfo(2);			-- 秘籍当前修为

	szTip = szTip..self:Tip_ReqAttrib();
	szTip = szTip.."<color=white>";
	szTip = szTip.."\nCấp: "..nLevel.."";
	if tbSetting then
		if it.nLevel == 3 then 
			szTip = szTip..string.format("\nLuyện: %d/%d", nKarma, tbSetting.m_tbHighLevelKarma[nLevel]);
		else
			szTip = szTip..string.format("\nLuyện: %d/%d", nKarma, tbSetting.m_tbLevelKarma[nLevel]);
		end
	end
	szTip = szTip.."<color>";
	szTip = szTip..self:Tip_BaseAttrib(nState);
	
	local tbDef = FightSkill:GetClass("default");
	for i, nSkill in ipairs(tbSkill) do
		if (nSkill > 0) then
			szTip = szTip..string.format("\nKỹ năng %d: <color=yellow>%s<color>\n\n", i, KFightSkill.GetSkillName(nSkill));
			local nMaxLevel = KFightSkill.GetSkillMaxLevel(nSkill);
			local tbInfo = KFightSkill.GetSkillInfo(nSkill, 1);
			-- 技能类型
			if(tbInfo.szProperty ~= "") then
				szTip = szTip..string.format("<color=metal>%s<color>\n",tbInfo.szProperty);
			end;
		
			-- 技能描述
			if(tbInfo.szDesc ~= "") then
				szTip = szTip..tbInfo.szDesc.."\n\n";
			end;
			local szClassName = tbInfo.szClassName;
			local tbSkill2 = assert(FightSkill.tbClass[szClassName], "Skill{"..szClassName.."} not found!");
			local tbMsg = { "<color=cyan>Cấp 1<color>" }; 
			tbDef:GetDescAboutLevel(tbMsg, tbInfo)
			szTip = szTip..table.concat(tbMsg, "\n");
			if (tbSkill2.GetExtraDesc) then
				szTip = szTip.."\n"..tbSkill2:GetExtraDesc(tbInfo);
			end
			if nMaxLevel > 1 then
				tbMsg = { "\n\n<color=cyan>Cấp "..nMaxLevel.." <color>[Cao nhất]" };
				tbInfo = KFightSkill.GetSkillInfo(nSkill, nMaxLevel);
				tbDef:GetDescAboutLevel(tbMsg, tbInfo);
				szTip = szTip..table.concat(tbMsg, "\n");
				if (tbSkill2.GetExtraDesc) then
					szTip = szTip.."\n"..tbSkill2:GetExtraDesc(tbInfo)
				end
			end
		end
	end

	return szTip;

end

function tbBook:Tip_BaseAttrib(nState)	-- 获得Tip字符串：基础属性
	local szTip = "";
	local tbAttrib = it.GetBaseAttrib();	-- 获得道具基础属性

	if (nState == Item.TIPS_PREVIEW) or (nState == Item.TIPS_GOODS) then	-- 属性预览状态
		for i, tbMA in ipairs(tbAttrib) do
			local nInitMin	= it.GetExtParam((i - 1) * 4 + 1);
			local nInitMax	= it.GetExtParam((i - 1) * 4 + 2);
			local tbRange = {};
			tbRange[1] = {};
			tbRange[1].nMin = math.floor(nInitMin / 100);
			tbRange[1].nMax = math.floor(nInitMax / 100);
			local szTemp = self:GetMagicAttribDescEx(tbMA.szName, self:BuildMARange(tbRange));
			if szTemp ~= "" then
				szTip = szTip.."\n"..szTemp;
			end
		end
		if szTip ~= "" then
			return	"\n"..szTip.."";
		end
	else									-- 其他状态
		szTip = self._tbBase:Tip_BaseAttrib(nState);
	end

	return szTip;
end

function tbBook:CalcValueInfo()
	local nValue = it.nOrgValue;
	local nStarLevel, szNameColor, szTransIcon = Item:CalcStarLevelInfo(it.nVersion, it.nDetail, it.nLevel, nValue);
	return	nValue, nStarLevel, szNameColor, szTransIcon;
end
