-- 文件名　：toweritem.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-03-10 16:42:59
-- 描  述  ：

local tbTower = Item:GetClass("tower_Item");
function tbTower:OnUse()
	local tbPlayerTempTable = me.GetPlayerTempTable();
	local tbMission = tbPlayerTempTable.tbMission;	
	
	if tbMission:IsOpen() ~= 1 then
		me.Msg("Chưa thể sử dụng!")
		return 0;
	end
	--第二阶段防守阶段才能种植物
	if tbMission.nStateJour > 3 then
		me.Msg("时机不对，现在不能使用这个！");
		return 0;
	end
	local nFlag , nId = tbMission:CheckeUseItem(me.nId);
	
	if nFlag  == 0 then
		me.Msg("该处不能种植物！");
		return 0;
	end
	if tbMission:AddTower(me.nId, nId, it.dwId) == 1 then
		return 1;
	end
	return 0;
end


