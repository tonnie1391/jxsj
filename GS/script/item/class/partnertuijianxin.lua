------------------------------------------------------
-- 文件名　：partnertuijianxin.lua
-- 创建者　：dengyong
-- 创建时间：2010-01-05 17:42:14
-- 描  述  ：同伴推荐信
------------------------------------------------------

local tbItem = Item:GetClass("partnertuijianxin");

local tbLimitPartnerId = { 258 };

function tbItem:OnUse()
	if (Partner.bOpenPartner ~= 1) then
		Dialog:Say("现在同伴活动已经关闭，无法使用物品");
		return 0;
	end

	local szMsg = "使用推荐信，同伴将可以被交易，<color=yellow>同时同伴的亲密度和领悟度都会恢复成默认值<color>，确定使用吗？";
	local tbOpt = {};
	
	for i = 1, me.nPartnerCount do
		local pPartner = me.GetPartner(i - 1);
		-- 只有一级的同伴才可以
		if pPartner and pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_LEVEL) == 1 and self:IsLimited(pPartner) == 0 then
			table.insert(tbOpt, {pPartner.szName, self.InsertAPartner, self, i - 1, it.dwId});
		end
	end
	
	if #tbOpt == 0 then
		me.Msg("您现在身边没有可以推荐的1级同伴！");
		Dialog:Say("您现在身边没有可以推荐的1级同伴！");
		return 0;
	end
	
	table.insert(tbOpt, {"取消"});
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

function tbItem:InsertAPartner(nIndex, dwId)
	local pPartner = me.GetPartner(nIndex);
	local pItem = KItem.GetObjById(dwId);
	
	if not pPartner or not pItem then
		return;
	end
	
	if pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_LEVEL) > 1 then
		me.Msg("您只能给1级的同伴写推荐信！");
		return;
	end
	
	-- 把同伴放入稚嫩的同伴中之前，先把同伴的信息记录下来，操作成功之后写入日志
	local nPartnerId = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_TEMPID);
	local nLevel = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_LEVEL);
	local nPotentialId = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_PotentialTemp);
	local nPotentialRemained = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_PotentialPoint);
	local nPartnerValue = Partner:GetPartnerValue(pPartner);
	
	local szMsg = string.format("%s给同伴%s写推荐信，", me.szName, pPartner.szName);
	szMsg = szMsg..string.format("%d, %d, %d, %d, %d, %d, %d, %d, %d",
		nPartnerId, nLevel, nPotentialId, nPotentialRemained, pPartner.GetAttrib(0),
		pPartner.GetAttrib(1), pPartner.GetAttrib(2), pPartner.GetAttrib(3),nPartnerValue
		);
		
	for i = 1, pPartner.nSkillCount do
		local tbSkill = pPartner.GetSkill(i - 1);
		szMsg = szMsg..string.format(", {%d, %d}", tbSkill.nId, tbSkill.nLevel);
	end
	
	local nRes, pAddItem = Partner:TurnPartnerToItem(me, pPartner);
	if nRes ~= 0 then
		Partner:ConsumePartnerItem(pItem, me);
		
		szMsg = szMsg..string.format("获得了道具%s：", pAddItem.szName);
		local nParnterTempId, nPotentialTemp, tbSkillId = Item:GetClass("childpartner"):ParseGenInfo(pAddItem);
		szMsg = szMsg..string.format("同伴模板ID：%d, 潜能模板ID：%d, 技能ID：{", nParnterTempId, nPotentialTemp);
		for _, nItemSkillId in pairs(tbSkillId) do
			szMsg = szMsg..string.format(" %d,", nItemSkillId);
		end
		szMsg = szMsg.."}";
		
		Dbg:WriteLog("同伴Log:", szMsg);
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_REALTION, szMsg);
	end
end

function tbItem:IsLimited(pPartner)
	local nLimit = 0;
	local nPartnerTplId = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_TEMPID);
	for _, nId in pairs(tbLimitPartnerId) do
		if (nId == nPartnerTplId) then
			nLimit = 1;
			break;
		end
	end
	return nLimit;
end
