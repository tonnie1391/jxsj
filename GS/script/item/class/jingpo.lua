------------------------------------------------------
-- 文件名　：jingpo.lua
-- 创建者　：zhaoyu
-- 创建时间：2009-12-11 17:11:29
-- 描  述  ：添加同伴亲密度道具
------------------------------------------------------

local tbItem 	= Item:GetClass("jingpo");

function tbItem:OnUse()
	if (Partner.bOpenPartner ~= 1) then
		Dialog:Say("现在同伴活动已经关闭，无法使用物品");
		return 0;
	end
	
	if me.nPartnerCount == 0 then
		Dialog:Say("您当前没有同伴可以增加亲密度。");
		return 0;
	end
		
	local tbOpt = {};
	for i = 0, me.nPartnerCount - 1 do
		local pPartner = me.GetPartner(i);
		local szMsg = pPartner.szName;
		local nFriendshipCurr = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_FRIENDSHIP);
		local nLevel = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_LEVEL);
		
		if nFriendshipCurr < Partner.FRIENDSHIP_MAX and nLevel >= Partner.FRIENDSHIP_DECLEVEL then
			local nFriendshipInc = self:GetFrendshipAdded(it, i);
			local nSumMax = math.min((nFriendshipInc + nFriendshipCurr), Partner.FRIENDSHIP_MAX);
			szMsg = szMsg..string.format(" （%0.2f→<color=yellow>%0.2f<color>）", 
				nFriendshipCurr/100, nSumMax/100);
				
			table.insert(tbOpt, {szMsg, self.OnSelectPartner, self, it.dwId, i});
		end
	end
	
	if #tbOpt == 0 then
		me.Msg("您当前没有同伴需要添加亲密度。");
		Partner:SendClientMsg("您当前没有同伴需要添加亲密度。");
		return 0;	
	end
	
	table.insert(tbOpt, {"Để ta suy nghĩ thêm"});
		
	Dialog:Say("请选择给以下哪位同伴增加和你的亲密度：", tbOpt);
	
	return 0;
end

-- 返回增加的
function tbItem:GetFrendshipAdded(pItem, nPartnerIndex)
	local pPartner = me.GetPartner(nPartnerIndex);
	local nPointValue = Partner:GetFriendshipValue(nPartnerIndex);
	
	local nItemValue = pItem.nValue / pItem.nCount;	-- 物品价值量; 
	
	local nFriendshipInc = nItemValue / nPointValue;
	
	return nFriendshipInc;
end

function tbItem:OnSelectPartner(nItemId, nPartnerIndex)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem or pItem.GetOwner().nId ~= me.nId then
		return;
	end

	local pPartner = me.GetPartner(nPartnerIndex);
	local nFriendshipInc = self:GetFrendshipAdded(pItem, nPartnerIndex);
	-- 使用精魄前的亲密
	local nFriendshipBefore = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_FRIENDSHIP);
	
	local nFriendship = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_FRIENDSHIP);	-- 当前亲密度
	local nRes, szMsg = Partner:AddFriendship(pPartner, nFriendshipInc);
	local nNewFriendship = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_FRIENDSHIP);	-- 新亲密度
		
	if nNewFriendship - nFriendship >= 1 then
		SpecialEvent.ActiveGift:AddCounts(me, 28);		--提升亲密度活跃度
	end
	
	if nRes == 1 then
		-- 使用精魄后的亲密
		local nFriendshipCur = pPartner.GetValue(Partner.emKPARTNERATTRIBTYPE_FRIENDSHIP);
		Dbg:WriteLog("同伴Log:", me.szName, "使用", pItem.szName, "增加同伴亲密度：", nFriendshipCur - nFriendshipBefore);
		-- 返回成功则扣除道具
		Partner:ConsumePartnerItem(pItem, me);
	end
	
	me.Msg(szMsg);
end
