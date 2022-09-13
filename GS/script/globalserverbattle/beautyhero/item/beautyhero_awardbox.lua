-- 文件名  : beautyhero_mobang.lua
-- 创建者  : zounan
-- 创建时间: 2010-10-19 21:56:23
-- 描述    : 

local tbItem = Item:GetClass("beautyhero_awardbox");
tbItem.AWARD = 
{
	[1] = {   -- 16强
		{ tbItemId = {18,1,114,8}, nCount =1, nBind = 1, },
		{ tbItemId = {18,1,544,2}, nCount =2, nBind = 1, },
		{ tbItemId = {18,1,1046,2},nCount =1, nBind = 1, },
		},
		
	[2] = {   -- 8强
		{ tbItemId = {18,1,114,8}, nCount =2, nBind = 1, },
		{ tbItemId = {18,1,544,2}, nCount =3, nBind = 1, },
		{ tbItemId = {18,1,1046,2},nCount =1, nBind = 1, },
		},	
		
	[3] = {   -- 4强
		{ tbItemId = {18,1,1047,2}, nCount =1, nBind = 0, },
		{ tbItemId = {18,1,544,2}, nCount =5, nBind = 1, },
		{ tbItemId = {18,1,1046,2},nCount =2, nBind = 1, },
		},				
		
	[4] = {   -- 2强
		{ tbItemId = {18,1,1047,2}, nCount =1, nBind = 0, },
		{ tbItemId = {18,1,544,3}, nCount =1, nBind = 1, },
		{ tbItemId = {18,1,1046,2},nCount =4, nBind = 1, },
		},				
		
	[5] = {   -- 1强
		{ tbItemId = {18,1,1047,1}, nCount =1, nBind = 0, },
		{ tbItemId = {18,1,544,3}, nCount =2, nBind = 1, },
		{ tbItemId = {18,1,1046,2},nCount =6, nBind = 1, },
		},		

};

function tbItem:OnUse()
	local tbAward = self.AWARD[it.GetExtParam(1)];
	if not tbAward then
		print("[ERR]，beautyhero_awardbox GetExtParam",it.GetExtParam(1));
		return;
	end
	
	local nNeedCount = 0;
	for _, tbDetail in ipairs(tbAward) do
		nNeedCount = nNeedCount + tbDetail.nCount;		
	end
	
	if me.CountFreeBagCell() < nNeedCount then
		Dialog:Say(string.format("你的背包空间不够。请整理出%d格背包空间再开宝箱吧。",nNeedCount));
		return 0;
	end	
	it.Delete(me);
	local pItem = nil;
	for _, tbDetail in ipairs(tbAward) do
		for i = 1, tbDetail.nCount do
			pItem =	me.AddItem(unpack(tbDetail.tbItemId));
			if pItem and tbDetail.nBind == 1 then
				pItem.Bind(1);
			end
		end
	end
end