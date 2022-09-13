-------------------------------------------------------
-- 文件名　：SeventhEvening_xialvshu.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2010-07-25 19:26:01
-- 文件描述：
-------------------------------------------------------

local tbNpc = Npc:GetClass("QX_xialvshu");
SpecialEvent.SeventhEvening = SpecialEvent.SeventhEvening or {};
local tbSeventhEvening = SpecialEvent.SeventhEvening;

function tbNpc:OnDialog()
	
	local szMaleName = him.GetTempTable("SpecialEvent").szMaleName;
	local szFemaleName = him.GetTempTable("SpecialEvent").szFemaleName;
	if not szMaleName or not szFemaleName then
		return 0;
	end
	
	local szMsg = string.format("这是<color=yellow>%s<color>和<color=yellow>%s<color>用情感和幸福栽种的七夕侠侣同心树。", szMaleName, szFemaleName);
	local tbOpt = 
	{
		{"领取侠侣同心果", self.GetAward, self},
		{"Ta hiểu rồi"},
	};
	
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:GetAward()
	
	local szMaleName = him.GetTempTable("SpecialEvent").szMaleName;
	local szFemaleName = him.GetTempTable("SpecialEvent").szFemaleName;
	if not szMaleName or not szFemaleName then
		return 0;
	end
	
	if me.szName ~= szMaleName and me.szName ~= szFemaleName then
		Dialog:Say("对不起，这不是你种下的侠侣同心树，你无法领取侠侣同心果。");
		return 0;
	end
	
	if not him.GetTempTable("SpecialEvent").tbGetGuo then
		him.GetTempTable("SpecialEvent").tbGetGuo = {};
	end
	
	if not him.GetTempTable("SpecialEvent").tbGetGuo[me.szName] then
		if me.CountFreeBagCell() < 1 then
			Dialog:Say("请留出1格背包空间。");
			return 0;
		end
		me.AddItem(unpack(tbSeventhEvening.tbXialvguoId));
		him.GetTempTable("SpecialEvent").tbGetGuo[me.szName] = 1;
	else
		Dialog:Say("对不起，你已经从这颗树上摘取过侠侣同心果了。");
		return 0;
	end
end
