-- 文件名  : fightafter_npc.lua
-- 创建者  : zounan
-- 创建时间: 2010-07-22 17:25:47
-- 描述    : 战后系统 NPC

if (MODULE_GC_SERVER) then
	return 0;
end

local tbDialogNpc  = Npc:GetClass("shihoupingjia");

function tbDialogNpc:OnDialog()
	local tbOpt = {};
	local szMsg = "Ngươi có thể nhận thưởng ngay, hoặc có thể thông qua Quan Nghĩa Quân để tìm ta.\n";

	local tbInstanceList = FightAfter:GetExpiryInstanceList(me);
	if #tbInstanceList ~= 0 then
		szMsg = szMsg.. "<color=orange>(Hãy đến nhận thưởng trong 24 giờ)<color>\n";
	else
		szMsg = szMsg.. "<color=orange>(Ngươi không có phần thưởng nào)<color>\n";
	end
	
	for nIndex, tbInstance in ipairs(tbInstanceList) do	 
		local szTitle = string.format("%s  %s<color>",self:GeTime(tbInstance.nEndTime),tbInstance.szName); 
		table.insert(tbOpt, {szTitle, self.ShowInstanceDesc,self, tbInstance.szInstanceId});
	end    	

	-- table.insert(tbOpt,{"了解活动评价系统", self.ShowHelp, self});
	table.insert(tbOpt,{"Rời khỏi đây", self.LeaveHere, self});
	table.insert(tbOpt,{"Ta hiểu rồi"});	
	Dialog:Say(szMsg,tbOpt);		
end

function tbDialogNpc:ShowInstanceDesc(szInstanceId)
	local nRet = FightAfter:ShowInstanceDesc(me,szInstanceId);
	if nRet == 0 then
		Dialog:Say("Phần thưởng này đã hết hạn.");
	end
end

function tbDialogNpc:LeaveHere()
	FightAfter:Fly2City(me);
	me.SetLogoutRV(0);	
end

function tbDialogNpc:ShowHelp()
	local szMsg = "属于全队的战斗积分，是你们表现好坏的依据，我会据此发放奖励！当然，呼朋唤友一起战斗，会使奖励有所增加。<color=orange>详情请查看F12-详细帮助<color>\n";
	local tbOpt = 
	{
		{"打开F12查看详细", self.OpenHelpSprite,self},	
		{"返回上一层", self.OnDialog, self},
		{"Ta hiểu rồi",}
	};

	Dialog:Say(szMsg, tbOpt);
end

function tbDialogNpc:OpenHelpSprite()
	me.CallClientScript({"UiManager:OpenWindow", "UI_HELPSPRITE"});
end

function tbDialogNpc:GeTime(nSec)
	local szMsg = "";
	local nCurDate = tonumber(GetLocalDate("%Y%m%d"));
	local nCompleteDate = tonumber(os.date("%Y%m%d", nSec));
	local szCompleteHour = os.date("%H:%M", nSec);
	if nCurDate ~= nCompleteDate then
		szMsg = "<color=yellow>Hôm qua, "..szCompleteHour;
	else
		szMsg = "<color=orange>Hôm nay, "..szCompleteHour;
	end
	
	return szMsg;
end