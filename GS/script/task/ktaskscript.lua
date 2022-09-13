-----------------------------------------------------
--文件名		：	ktaskscript.lua
--创建者		：	zhengyuhua
--创建时间		：	2008-01-08
--功能描述		：	任务扩展脚本。
------------------------------------------------------
if MODULE_GC_SERVER then
	return
end

local TASK_AWARD_TIP = {};
TASK_AWARD_TIP.exp = function(tbAward)
	return "Kinh nghiệm: <color=green>"..tostring(tbAward.varValue).."<color>";
end

TASK_AWARD_TIP.money = function(tbAward)
	return "Bạc khóa: <color=green>"..tostring(tbAward.varValue).."<color>";
end

TASK_AWARD_TIP.bindmoney = function(tbAward)
	if (type(tbAward.varValue) == "number") then
		return "Bạc khóa: <color=green>"..tostring(tbAward.varValue).."<color>";
	else
		return tbAward.szDesc;
	end
end

TASK_AWARD_TIP.activemoney = function(tbAward)
	return "Bạc: <color=green>"..tostring(tbAward.varValue).."<color>";
end

TASK_AWARD_TIP.gatherpoint = function(tbAward)
	return "Hoạt lực: <color=green>"..tbAward.varValue.."<color>";
end

TASK_AWARD_TIP.linktask_repute = function(tbAward)
	return	"Danh vọng nghĩa quân: <color=green>"..tbAward.varValue[3].."<color>";
end

TASK_AWARD_TIP.linktask_cancel = function(tbAward)
	return	"<color=green>1 cơ hội hủy nhiệm vụ<color>";
end

TASK_AWARD_TIP.makepoint = function(tbAward)
	return "Tinh lực: <color=green>"..tbAward.varValue.."<color>";
end

TASK_AWARD_TIP.title = function(tbAward)
	local tbTitle = KPlayer.GetTitleLevelAttr(tbAward.varValue[1], tbAward.varValue[2], tbAward.varValue[3]);
	local szDesc = tbTitle.szTitleName or "";
	return "Danh hiệu: <color=green>"..szDesc.."<color>";
end

TASK_AWARD_TIP.repute = function(tbAward)
	local tbRepute = KPlayer.GetReputeInfo();
	local szReputeDesc = tbRepute[tbAward.varValue[1]][tbAward.varValue[2]].szName
	return "Danh vọng: <color=green>"..szReputeDesc.." "..tbAward.varValue[3].." điểm<color>";
end


-- 获取某奖励的tip
function KTask.GetAwardTip(tbAward)
	local fncTip = TASK_AWARD_TIP[tbAward.szType];
	if not fncTip then
		return tbAward.szDesc;
	end
	local szTip	= "";
	if type(fncTip) == "function" then
		szTip = fncTip(tbAward);
	end
	return szTip;
end
