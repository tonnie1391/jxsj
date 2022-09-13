
-- 药品，通用功能脚本

------------------------------------------------------------------------------------------
-- initialize

local tbMedicine = Item:GetClass("medicine");

local PK_LIMIT_USE_MEDICINE	= 9;			-- 恶名值过高喝药无效

------------------------------------------------------------------------------------------
-- public

function tbMedicine:CheckUsable()			-- 判断是否可用
	if (me.nPKValue >= PK_LIMIT_USE_MEDICINE) then
		me.Msg("您的恶名值过高，不允许使用药品！");
		return	0;
	end
	return	1;
end

function tbMedicine:OnUse()					-- 喝药
	local tbBaseAttrib = it.GetBaseAttrib();
	for _, tb in ipairs(tbBaseAttrib) do
		me.GetNpc().ApplyMagicAttrib(tb.szName, tb.tbValue);
		if (FightSkill.nDATimer and FightSkill.nDATimer > 0 and tb.szName == "lifepotion_v") then
			if(FightSkill.tbDamageAccountPlayer[me.nId] == 1) then
				me.CallClientScript({"Ui:ServerCall", "UI_DAMAGETEST", "RefreshMsg", 0, tb.tbValue[1] * 5 * 2});
			end;
		end;
	end
	--成就
	Achievement:FinishAchievement(me,411);
	return	1;
end

function tbMedicine:GetTip(nState)			-- 获取Tip2010/11/2 18:20:51
	local szTip = "";
	szTip = szTip..self:Tip_Attrib();
	return szTip;
end

function tbMedicine:Tip_Attrib()			-- 获得Tip字符串：药品属性

	local szTip = "<color=white>";
	local tbAttrib = it.GetBaseAttrib();	-- 获得药品属性
	local tbDesc = {};

	for _, tbMA in ipairs(tbAttrib) do
		if tbMA.szName ~= "" then
			local szDesc = FightSkill:GetMagicDesc(tbMA.szName, tbMA.tbValue, nil, 1);
			if szDesc ~= "" then
				table.insert(tbDesc, szDesc);
			end
		end
	end

	return	szTip..table.concat(tbDesc, "\n").."<color>";

end



function tbMedicine:IsPickable(szClassName, nObjId)
	if (me.GetCamp() == 6) then	-- GM阵营
		return 0;
	else
		return 1;
	end
end