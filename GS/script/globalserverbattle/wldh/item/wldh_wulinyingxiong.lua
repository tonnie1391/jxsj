-- 文件名　：wldh_wulinyingxiong.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-09-23 16:11:42
-- 描  述  ：

local tbItem = Item:GetClass("wldh_wulinyingxiong");

function tbItem:OnUse()
	
--	-- add bind to no bind
--	if it.IsBind() == 1 then
--		if me.CountFreeBagCell() < 1 then
--			Dialog:SendBlackBoardMsg(me, "你背包满了，放不下，留1格空间再来吧。");
--			return 0;
--		end
--		me.AddItem(18, 1, 487, 1);
--		me.Msg("您手中绑定的武林英雄令牌，已经成功转化为不绑定。");
--		return 1;
--	end
	
	local nFlag = Player:AddRepute(me, 11, 1, 300);
	if (0 == nFlag) then
		return;
	elseif (1 == nFlag) then
		me.Msg("您已经达到武林大会声望最高等级，将无法武林大会令牌");
		return;
	end
	return 1;
end
