
-- 首饰制作技能新加道具：修理包


local tbItem 	= Item:GetClass("xiulibao");
tbItem.nTotleUseTimes = 10;

function tbItem:OnUse()
	local nCurUseTimes = it.GetGenInfo(1);
	it.SetGenInfo(1, nCurUseTimes + 1);	
	me.PrepareItemRepair(it.dwId);
	if (nCurUseTimes + 1 >= self.nTotleUseTimes) then
		return 1
	end

	return 0;
end
