
-- 金犀

------------------------------------------------------------------------------------------
-- initialize

local tbJinxi = Item:GetClass("jinxi");

------------------------------------------------------------------------------------------
-- public

function tbJinxi:InitGenInfo()
	return	{ it.GetExtParam(1) };		-- 初始化金犀耐久
end

function tbJinxi:OnUse()					-- 准备道具修理
	me.PrepareItemRepair(it.dwId);
	return	0;
end


function tbJinxi:OnAllRepair(pRepairItem)
	me.UseItem(pRepairItem);
	local tbMsg = {};
	tbMsg.szMsg = "Muốn sửa toàn bộ trang bị?";
	function tbMsg:Callback(nOptIndex)
		if nOptIndex == 2 then
			local tbItemIndex = {};
			for i = 0, Item.EQUIPPOS_NUM - 1 do
				local pItem = me.GetItem(Item.ROOM_EQUIP,i,0)
				if pItem and pItem.nCurDur < Item.DUR_MAX then 
   					table.insert(tbItemIndex, pItem.nIndex);
				end
			end
			if (#tbItemIndex > 0) then
				me.RepairEquipment(Item.REPAIR_ITEM, #tbItemIndex, tbItemIndex);
			end
			Timer:Register(Env.GAME_FPS * 1, tbJinxi.DelayCloseRepairWnd, tbJinxi, tbItemIndex);
		else
			UiManager:ReleaseUiState(UiManager.UIS_ITEM_REPAIR);
		end
	end
	UiManager:OpenWindow(Ui.UI_MSGBOX, tbMsg);
	return 0;
end


function tbJinxi:DelayCloseRepairWnd(tbItemIndex)
	UiManager:ReleaseUiState(UiManager.UIS_ITEM_REPAIR);
	return 0;
end

function tbJinxi:GetTip(nState)
	local szTip = "";
	szTip = szTip.."<color=0x8080ff>Số điểm còn có thể dùng:"..it.GetGenInfo(1).."<color>";
	return	szTip;
end
