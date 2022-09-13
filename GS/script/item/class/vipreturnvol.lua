------------------------------------------
--	文件名  ：	vipreturnvol.lua
--	创建者  ：	ZouYing@kingsoft.com
--	创建时间：	2009-3-11 13:55 
------------------------------------------
local TASK_VIPPLAYER_TASKID = 2083;

local tbItem 	= Item:GetClass("fanhuanjuan");


function tbItem:GetTip()
	local nLevel = it.nLevel + 2;
	if (nLevel < 2 or nLevel > 6)then
		assert(false);
	end
	local szTip = "返还卷数额还剩余<color=yellow>" .. me.GetTask(TASK_VIPPLAYER_TASKID, nLevel) .. "<color>";
	return szTip;
end
