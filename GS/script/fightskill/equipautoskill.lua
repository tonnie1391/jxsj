--装备上的autoskill显示
FightSkill.tbEquipAutoSkill = {};
FightSkill.tbEquipAutoSkill.tbTipFunc = 
{
	-- 西夏套装的第二条套装属性
	[111] = function(nSkillLevel)
		local tbChildInfo = KFightSkill.GetSkillInfo(1996, nSkillLevel);
		
		local tbMsg = {};
		local szMsg = "";
		--szMsg = szMsg.."<color=green>黯相望<color>\n";
		szMsg = szMsg.."附近每个友方都可能使你";
		szMsg = szMsg.."所受五行伤害缩小"..tbChildInfo.tbWholeMagic["redeivedamage_dec_p2"][1].."%，";
		szMsg = szMsg.."最多叠加"..tbChildInfo.tbWholeMagic["superposemagic"][1].."次，";
		szMsg = szMsg.."持续"..FightSkill:Frame2Sec(tbChildInfo.nStateTime).."秒";
		return szMsg;
	end,
};

local tbSkill = FightSkill:GetClass("equipAutoSkill");

function tbSkill:GetAutoDesc(tbAutoInfo, tbSkillInfo)
	local funTip = FightSkill.tbEquipAutoSkill.tbTipFunc[tbAutoInfo.nId];	
	local szMsg = "";
	if funTip then
		szMsg = funTip(tbAutoInfo.nSkillLevel);
	end
	return szMsg;
end