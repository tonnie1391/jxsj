-- 文件名  : xuehunling.lua
-- 创建者  : jiazhenwei
-- 创建时间: 2010-12-14 22:55:29
-- 描述    : 血魂令

local tbItem = Item:GetClass("xuehunling");

function tbItem:OnUse()
	if (Player:AddRepute(me, 5, 6, 50)==1) then
		Dialog:Say("Danh vọng đã đạt cấp cao nhất!");
		return 0;
	end
	return 1;
end