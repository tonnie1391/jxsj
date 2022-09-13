-------------------------------------------------------
-- 文件名　：viptransfercard.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-01-08 16:32:57
-- 文件描述：
-------------------------------------------------------

local tbItem = Item:GetClass("viptransfercard");

function tbItem:OnUse()
--	me.SetTask(VipPlayer.VipTransfer.TASK_GROUP_ID, VipPlayer.VipTransfer.TASK_QUALIFICATION, 1);
--	me.Msg("恭喜你获得了VIP转服资格！");
	return 1;
end
