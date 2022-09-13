	
-- 任务道具，通用功能脚本

------------------------------------------------------------------------------------------
-- initialize

local tbTaskItem = Item:GetClass("taskitem");

------------------------------------------------------------------------------------------
-- public

function tbTaskItem:OnUse()
	Task:OnTaskItem(it);
	return 0;
end

function tbTaskItem:IsPickable()
	for _, tbTask in pairs(Task:GetPlayerTask(me).tbTasks) do
		if (tbTask:IsItemToBeCollect({it.nGenre, it.nDetail, it.nParticular, it.nLevel}) == 1) then
			return 1;
		end
	end
	
	me.Msg("此物品不能拾取。")
	
	return 0;
end

function tbTaskItem:PickUp()
	Task:SharePickItem(me, it);
	return 1;
end

function tbTaskItem:GetTip()
	local szTip = "";

	if (it.nParticular == 463) then
		szTip = szTip.."<color=0x8080ff>该任务需要获得2000000点修炼经验值方可完成。<color>";
	elseif(it.nParticular == 464) then
		szTip = szTip.."<color=0x8080ff>该任务需要获得6000000点修炼经验值方可完成。<color>";
	elseif(it.nParticular == 465) then
		szTip = szTip.."<color=0x8080ff>该任务需要获得18000000点修炼经验值方可完成。<color>";
	end

	return szTip;

end
