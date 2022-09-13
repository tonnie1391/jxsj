-- 官印
-- zhengyuhua
--

Require("\\script\\item\\class\\equip.lua");

------------------------------------------------------------------------------------------
-- initialize

local tbChop = Item:NewClass("chop", "equip");
if not tbChop then
	tbChop = Item:GetClass("chop");
end

function tbChop:GetTip(nState, tbEnhRandMASS, tbEnhEnhMASS)		-- 获取套装装备Tip

	local szTip = "";

	if (Item.EQUIPPOS_CHOP ~= it.nEquipPos) then
		return	szTip;
	end

	szTip = szTip.."<color=white>";
	szTip = szTip..self:Tip_ReqAttrib();
	szTip = szTip..self:Tip_Durability();
	szTip = szTip..self:Tip_Level();
	szTip = szTip..self:Tip_Series(nState);
	szTip = szTip.."<color>\n";
	
	local tbAttrib = it.GetBaseAttrib();
	local tbDef = FightSkill:GetClass("default");
	
	local nLiuQiLevel = 0;
	for i = 1, #tbAttrib do
		if tbAttrib[i].szName == "allskill_v" then
			local tbMsg = {};
			local tbInfo = KFightSkill.GetSkillInfo(tbAttrib[i].tbValue[3], tbAttrib[i].tbValue[1]);
			if (tbAttrib[i].tbValue[3] == 899) then --六气化玉功
				nLiuQiLevel = tbAttrib[i].tbValue[1];
			end;
			
			if (i ~= 1) then
				szTip = szTip..string.format("\n\nKỹ năng: <color=yellow>%s<color>\n", KFightSkill.GetSkillName(tbAttrib[i].tbValue[3]));
				local tbInfo = KFightSkill.GetSkillInfo(tbAttrib[i].tbValue[3], tbAttrib[i].tbValue[1]);
				-- 技能类型
				if(tbInfo.szProperty ~= "") then
					szTip = szTip..string.format("<color=metal>%s<color>\n",tbInfo.szProperty);
				end;
				if(tbInfo.szDesc ~= "") then
					szTip = szTip..tbInfo.szDesc.."\n\n";
				end;
				tbMsg = { string.format("<color=cyan>Cấp %d<color>", tbAttrib[i].tbValue[1]) }; 
			end;
			tbDef:GetDescAboutLevel(tbMsg, tbInfo)
			szTip = szTip..table.concat(tbMsg, "\n");
		end
	end
	
	szTip = szTip..self:Tip_RepairInfo(nState);
	
	szTip = string.gsub(szTip, "nLevel", nLiuQiLevel);
	
	return	Lib:StrTrim(szTip, "\n");
end

function tbChop:CalcValueInfo()
	local nValue = it.nOrgValue;
	local nStarLevel, szNameColor, szTransIcon = Item:CalcStarLevelInfo(it.nVersion, it.nDetail, it.nLevel, nValue);
	return	nValue, nStarLevel, szNameColor, szTransIcon;
end