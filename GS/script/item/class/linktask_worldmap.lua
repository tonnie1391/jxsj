
-- ====================== 文件信息 =======================

-- 剑侠世界门派任务 - 地图志处理文件
-- Edited by peres
-- 2007/05/11 AM 11:31

-- 后来又笑自己的狷介。
-- 每个人有自己的宿命，一切又与他人何干。
-- 太多人太多事，只是我们的借口和理由。

-- =======================================================

local tb = Item:GetClass("linktask_worldmap");

function tb:OnUse()
	return;
end

function tb:PickUp(nX, nY)
	me.Msg("你得到了一张地图志！");
	return 0;
end
