-- 秦陵炼化套装声望物品
-- By Peres 2009/06/13
-- 何不食肉糜

local tbItem = Item:GetClass("qinling_refine_item");

tbItem.tbData = 
{
	[360] = {10, 2}, -- 长明灯，每次 10 点，最高加到 2 级
	[363] = {10, 3}, -- 搬山印，每次 10 点，最高加到 3 级
	[366] = {10, 4}, -- 摸金符，每次 10 点，最高加到 4 级
	[375] = {10*50, 4},-- 摸金符x50，每次 10 点，最高加到 4 级
}

function tbItem:OnUse()
	if it.nParticular == 375 then
		if me.IsAccountLock() ~= 0 then
			me.Msg("你的账号处于锁定状态，无法使用该物品。");
			return 0;
		end
	end
	if not self.tbData[it.nParticular] then
		me.Msg("使用出错！");
		return;
	end
	
	local nReputeLevel = me.GetReputeLevel(9, 1);
	if nReputeLevel >= self.tbData[it.nParticular][2] then
		me.Msg("使用<color=yellow>"..it.szName.."<color>只能使<color=green>秦始皇陵·官府<color>声望增加到<color=yellow>"..self.tbData[it.nParticular][2].."<color>级！");
		return;
	end
	
	local nFlag = Player:AddRepute(me, 9, 1, self.tbData[it.nParticular][1]);
	if (nFlag == 0) then
		return;
	elseif (nFlag == 1) then
		me.Msg("您的<color=green>秦始皇陵·官府<color>声望已经达到最高级，不能再增加了！");
		return;
	end	

	return 1;
end

