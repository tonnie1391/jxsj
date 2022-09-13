local tbItem = Item:GetClass("zhenyuanbox");

local SKILLCOUNT_MIN 	= 2;	-- 目前同伴最少也有两个技能
local SKILLCOUNT_MAX	= 6;	-- 目前同伴最多只有六个技能

function tbItem:OnUse()
	if me.nLevel < Item.tbZhenYuan.ZHENYUAN_LEVEL_NEED then
		me.Msg(string.format("您的等级不足%s级，还不能使用这个道具。", Item.tbZhenYuan.ZHENYUAN_LEVEL_NEED));
		return 0;
	end
		
	self:OnSureUse(it.dwId, 0);
		
	return 0;		
end

function tbItem:OnSureUse(dwId, nStep)
	assert(nStep);
	if nStep == 0 then
		local szMsg = "你确定要使用该道具获得对应真元吗？";
		local tbOpt = 
		{
			{"Xác nhận", self.OnSureUse, self, dwId, 1},
			{"取消"},
		}
		
		Dialog:Say(szMsg, tbOpt);
	elseif nStep == 1 then
		local pItem = KItem.GetObjById(dwId);
		if not pItem then
			return;
		end
		
		local nPartnerId = pItem.GetExtParam(1);
		local nSkillCount = pItem.GetExtParam(2);
		local nHuTi = pItem.GetExtParam(3);
		
		if nSkillCount <= 0 then
			nSkillCount = MathRandom(SKILLCOUNT_MIN, SKILLCOUNT_MAX);
		end
		
		local szItemName = pItem.szName;
		if pItem.Delete(me) == 1 then
			local pZhenYuan = Item.tbZhenYuan:Generate({nPartnerId, nSkillCount});
			if not pZhenYuan then
				local szLog = string.format("%s使用%s获取真元[%d,%d]失败！", me.szName, szItemName, nPartnerId, nSkillCount);
				Dbg:WriteLog("zhenyuanbox", szItemName);
				return;
			end
			
			-- 通过真元盒子开出来的真元都是已护体真元
			if nHuTi == 0 then
				Item.tbZhenYuan:SetEquiped(pZhenYuan, 1);
			end
			
			local szLog = string.format("%s使用%s获得真元%s[%d,%d,%d,%d,%d]", me.szName, szItemName,
				pZhenYuan.szName, Item.tbZhenYuan:GetAttribPotential1(pZhenYuan), 
				Item.tbZhenYuan:GetAttribPotential2(pZhenYuan),
				Item.tbZhenYuan:GetAttribPotential3(pZhenYuan),
				Item.tbZhenYuan:GetAttribPotential4(pZhenYuan),
				Item.tbZhenYuan:GetEquiped(pZhenYuan));
					
			Dbg:WriteLog("zhenyuanbox", szLog);
		end
	end	
end