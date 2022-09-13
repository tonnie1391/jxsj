-- 文件名  : treasuremap2_item.lua
-- 创建者  : huangxiaoming
-- 创建时间: 2012-08-30 11:55:41
-- 描述    : 
Require("\\script\\task\\treasuremap2\\treasuremap2_def.lua")
local tbLingPai = Item:GetClass("treasure2_lingpai")

function tbLingPai:OnUse()
	local nIndex = it.GetExtParam(1);
	if not TreasureMap2.TEMPLATE_LIST[nIndex] then
		return;
	end
	local nTaskGroup = TreasureMap2.TEMPLATE_LIST[nIndex].tbTaskGroupId[1];
	local nTaskId = TreasureMap2.TEMPLATE_LIST[nIndex].tbTaskGroupId[2];
	assert(nTaskGroup > 0 and nTaskId > 0);
	local nCount = me.GetTask(nTaskGroup, nTaskId);
	if nCount >= TreasureMap2.NUMBER_MAX_TREASURE_TIMES then
		me.Msg("Số lượt tích lũy đã đủ "..TreasureMap2.NUMBER_MAX_TREASURE_TIMES.." lần, hãy tham gia Tàng Bảo Đồ trước rồi mới có thể sử dụng.")		
		return;
	end
	local szMsg = string.format("Lượt khiêu chiến <color=yellow>%s<color> tăng 1 lượt.", TreasureMap2.TEMPLATE_LIST[nIndex].szName);
	me.SetTask(nTaskGroup, nTaskId, nCount + 1);
	me.Msg(szMsg);
	return 1;
end

local tbCommon = Item:GetClass("treasure2_common")

function tbCommon:OnUse()
	local nCount = me.GetTask(TreasureMap2.TASK_GROUP, TreasureMap2.TASK_ID_COMMONTASK);
	if nCount >= TreasureMap2.NUMBER_MAX_TREASURE_TIMES then
		me.Msg("Số lượt tích lũy đã đủ "..TreasureMap2.NUMBER_MAX_TREASURE_TIMES.." lần, hãy tham gia Tàng Bảo Đồ trước rồi mới có thể sử dụng.")		
		return;
	end
	me.SetTask(TreasureMap2.TASK_GROUP, TreasureMap2.TASK_ID_COMMONTASK, nCount + 1);
	me.Msg("Lượt khiêu chiến Tàng Bảo Đồ tăng 1 lượt.");
	return 1;
end
