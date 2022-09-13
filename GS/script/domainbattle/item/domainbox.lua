
-- 领土争夺战箱子
-- 

local tbItem = Item:GetClass("domainbox");

tbItem.ITEM_LEVEL_RATE =  		-- 开牌子等级概率
{
	[1] = 15;
	[2] = 50;
	[3] = 35;
}
tbItem.MAX_RATE	= 100			-- 上面数值的和
tbItem.ITEM_GDPL = {18,1,253}


function tbItem:OnUse()
	if Item:IsBindItemUsable(it, me.dwTongId) ~= 1 then
		return 0
	end
	local nRand = MathRandom(self.MAX_RATE);
	local nLevel = 1;
	for i = 1, #self.ITEM_LEVEL_RATE do
		nRand = nRand - self.ITEM_LEVEL_RATE[i];
		if nRand <= 0 then
			nLevel = i;
			break;
		end
	end
	if me.CountFreeBagCell() < 1 then
		me.Msg("Hành trang không đủ chỗ trống!");
		return 0;
	end
	local pItem = me.AddItem(self.ITEM_GDPL[1],self.ITEM_GDPL[2],self.ITEM_GDPL[3],nLevel);
	if pItem then
		Item:BindWithTong(pItem, me.dwTongId);
		return 1;
	end
end

-- TODO
function tbItem:GetTip()
	local nOwnerTongId = KLib.Number2UInt(it.GetGenInfo(Item.TASK_OWNER_TONGID, 0));
	if nOwnerTongId == 0 then
		return "<color=gold>Đạo cụ không khóa với Bang hội, ai cũng có thể sử dụng<color>";
	elseif nOwnerTongId == me.dwTongId then
		return "<color=gold>Đạo cụ đã khóa với Bang hội của bạn, Bang hội khác không thể sử dụng<color>";
	else
		return "<color=red>Đạo cụ này đã khóa với Bang hội khác, bạn không thể sử dụng!<color>"
	end
end

