-------------------------------------------------------
-- 文件名　：wldh_qualification_def.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-09-08 10:37:26
-- 文件描述：
-------------------------------------------------------

local tbQualification = Wldh.Qualification or {};
Wldh.Qualification = tbQualification;

tbQualification.ISOPEN				= 0;	--开关，是否开启（1开启；0不开启）

-- 两个阶段，0921-0927确认参赛资格，0928-0930选举武林盟主
tbQualification.MEMBER_STATE 		= {200909210330, 200909272400};
tbQualification.CAPTAIN_STATE 		= {200909280000, 200909302200};

tbQualification.TASK_GROUP_ID 		= 2101;
tbQualification.TASK_YINXIONGTIE	= 1;	-- 使用英雄帖的数量
tbQualification.TASK_VOTE			= 2;	-- 是否投票

tbQualification.tbGblBuf_Member 	= {};	-- global buff, no clear

tbQualification.tbVaildServer = 
{
	["0101"] = 1, ["0102"] = 1, ["0103"] = 1, ["0104"] = 1, ["0105"] = 1,
	["0107"] = 1, ["0108"] = 1, ["0110"] = 1, ["0112"] = 1, ["0113"] = 1,
	["0114"] = 1, ["0116"] = 1, ["0118"] = 1,
	["0201"] = 1, ["0202"] = 1, ["0203"] = 1, ["0207"] = 1, ["0209"] = 1,
	["0210"] = 1, ["0213"] = 1, ["0215"] = 1,
	["0301"] = 1, ["0302"] = 1, ["0304"] = 1, ["0307"] = 1, ["0308"] = 1,
	["0312"] = 1, ["0316"] = 1, ["0321"] = 1, 
	["0401"] = 1, ["0403"] = 1, ["0404"] = 1, ["0405"] = 1, ["0408"] = 1,
	["0409"] = 1, ["0410"] = 1, ["0414"] = 1, ["0416"] = 1, ["0420"] = 1,
	["0421"] = 1, ["0422"] = 1, ["0426"] = 1,
	["0501"] = 1, ["0504"] = 1, ["0509"] = 1, ["0511"] = 1, ["0512"] = 1, 
	["0514"] = 1,
	["0602"] = 1, ["0603"] = 1, ["0605"] = 1, ["0606"] = 1, ["0611"] = 1,
	["0616"] = 1, ["0618"] = 1, ["0620"] = 1, ["0621"] = 1,
};

function tbQualification:CheckServer()
	if self.ISOPEN ~= 1 then
		return 0;
	end
	local szGateWay = string.sub(GetGatewayName(), 5, 8);
	if not self.tbVaildServer[szGateWay] then
		return 0;
	end
	return 1;
end

tbQualification._Sort = function(tbMember1, tbMember2)
	return tbMember1[2].nVote > tbMember2[2].nVote;
end
