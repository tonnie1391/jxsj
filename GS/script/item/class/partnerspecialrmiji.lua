-- 文件名　：partnermiji.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-01-19 11:32:29
-- 描  述  ：同伴特殊秘籍

local tbItem = Item:GetClass("miji_tbEx");

tbItem.tbBookValue =  
{
	600000,    --初级      
	3000000,  --中级       
	18000000 --高级        
};         

--对应等级需要的星级数(2倍值)
tbItem.tbGradeRequire =  
{       
	0,                   
	12,
	16
}; 

function tbItem:OnUse()
	if (Partner.bOpenPartner ~= 1) then
		Dialog:Say("现在同伴活动已经关闭，无法使用物品");
		return 0;
	end	
	
	self:OnSelectUse(it.dwId);
end

function tbItem:OnSelectUse(dwId, nParam, bSure)
	bSure = bSure or 0;
	
	if me.nPartnerCount <= 0 then
		me.Msg("您当前并没有同伴！");
		return 0;
	end
	
	if bSure == 0 then
		local szMsg = "您想给以下哪位同伴增加技能等级：";
		local tbOpt = {};
		for i = 1, me.nPartnerCount do
			local pPartner = me.GetPartner(i - 1);
			if pPartner then
				table.insert(tbOpt, {pPartner.szName, self.OnSelectUse, self, dwId, i - 1, 1});
			end
		end
		
		table.insert(tbOpt, {"Để ta suy nghĩ thêm"});
		Dialog:Say(szMsg, tbOpt);
		
		return 0;
	else
		local pPartner = me.GetPartner(nParam);
		local pItem = KItem.GetObjById(dwId);
		if not pPartner or not pItem then
			return 0;
		end
		local nCount = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_SKILLBOOK);   --用千位表示特殊技能书个数
		if nCount < 0 then
			nCount = 0;
		end
		--检查使用同类物品的次数
		if self:CheckSkillBookCount(nCount) == 1 then
			Dialog:Say("该同伴已经使用过两本该特殊秘籍了", {"知道了"});
			return 0;
		end
		
		--等级判定
		if pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_LEVEL) < 120 then
			Dialog:Say("同伴等级没有达到120级还不能使用该物品！", {"知道了"});
			return 0;
		end
		
		--技能检查
		if self:CheckSkill(nParam)  == 1 then
			Dialog:Say("该同伴没有低于6级的技能！", {"知道了"});
			return 0;
		end		
		
--		--6星及以下的同伴只能吃初级秘籍6星半到8星的同伴只能吃中级秘籍8星半以上才能吃高级秘籍
--		if self:CheckPartnerGrade(nParam, dwId) == 1 then
--			Dialog:Say("同伴秘籍使用规则：<color=yellow>6星及以下<color>的同伴只能吃初级秘籍,<color=yellow>6星半到8星<color>的同伴只能吃中级秘籍,<color=yellow>8星半以上<color>只能吃高级秘籍,您的同伴不符合这本秘籍的要求。", {"知道了"});
--			return 0;
--		end
		self:AddPartnerSkillLevel(nParam, dwId);
	end
	
	return 1;
end

--检查有没有小于6级的技能
function tbItem:CheckSkill(nParam)
	local pPartner = me.GetPartner(nParam);
	if pPartner then
		for i = 1, pPartner.nSkillCount do
			local tbSkill = pPartner.GetSkill(i - 1);
			if tbSkill.nLevel < 6 then
				return 0;
			end
		end
	end
	return 1;
end

--随机一个小于6级的技能加一级
function tbItem:AddPartnerSkillLevel(nParam, dwId)
	local pPartner = me.GetPartner(nParam);
	local pItem = KItem.GetObjById(dwId);
	local tbStatisSkil = {};
	if not pPartner or not pItem then
		return 0;
	end	
	local szName = pItem.szName;
	--找等级小于6的技能
	for i = 1, pPartner.nSkillCount do
		local tbSkill = pPartner.GetSkill(i - 1);
		if tbSkill.nLevel < 6 then
			table.insert(tbStatisSkil, {i - 1, tbSkill.nId, tbSkill.nLevel});
		end
	end
	local nAddSkillIndex = MathRandom(#tbStatisSkil); --随机一个技能增加
	pPartner.SetSkill(tbStatisSkil[nAddSkillIndex][1],{["nId"] = tbStatisSkil[nAddSkillIndex][2], ["nLevel"] = tbStatisSkil[nAddSkillIndex][3] + 1});
	me.Msg(string.format("您使用同伴秘籍使技能<color=yellow>%s<color>提升了一级",KFightSkill.GetSkillName(tbStatisSkil[nAddSkillIndex][2])));
	pItem.Delete(me);
	local nCount = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_SKILLBOOK);
	if nCount < 0 then
		nCount = 0;
	end
	nCount = nCount + 1000;
	pPartner.SetValue(Partner.emKPARTNERATTRIBTYPE_SKILLBOOK, nCount);
	PlayerHonor:UpdatePartnerValue(me, 0);
	Dbg:WriteLog("同伴Log:", me.szName, "对同伴", pPartner.szName,"使用:", szName);
	return 1;
end

--检查使用同类物品的次数
function tbItem:CheckSkillBookCount(nCount)
	local nCountEx = 0;	
	nCountEx = math.floor(nCount / 1000);
	if nCountEx >= 2 then
		return 1;
	end
	return 0;
end

function tbItem:CheckPartnerGrade(nParam, dwId)
	local pPartner = me.GetPartner(nParam);
	local pItem = KItem.GetObjById(dwId);
	if not pPartner or not pItem then
		return 1;
	end
	local nLevel = pItem.nLevel;
	local nGradeXing = Partner:GetSelfStartCount(pPartner);
	if nGradeXing > self.tbGradeRequire[nLevel] and (not self.tbGradeRequire[nLevel + 1] or nGradeXing <= self.tbGradeRequire[nLevel + 1]) then		
		return 0;
	end
	return 1;
end
