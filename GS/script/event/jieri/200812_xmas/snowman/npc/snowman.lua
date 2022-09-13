-- 文件名　：snowman.lua
-- 创建者　：zounan
-- 创建时间：2009-11-26 11:36:28
-- 描  述  ：
local tbNpc = Npc:GetClass("snowman");

SpecialEvent.Xmas2008 = SpecialEvent.Xmas2008 or {};
SpecialEvent.Xmas2008.XmasSnowman = SpecialEvent.Xmas2008.XmasSnowman or {};
local XmasSnowman = SpecialEvent.Xmas2008.XmasSnowman;

function tbNpc:OnDialog()
	local nDate = tonumber(GetLocalDate("%Y%m%d"));	
	local nTime = tonumber(GetLocalDate("%H%M"));	

	if nDate <= XmasSnowman.EVENT_END or nDate >= XmasSnowman.MAXMAN_END then
		return;
	end
	local tbOpt = {{"领取福袋", self.OnAward, self}, {"Kết thúc đối thoại"}};	  
	local szMsg = "活动期间，每天可以领两个福袋";
	Dialog:Say(szMsg, tbOpt);
end

function tbNpc:OnAward()
	
	if me.nLevel < 60 then
		Dialog:Say("你的等级不够，60级以后再来吧。");
		return;
	end	
	
	local nDate = tonumber(GetLocalDate("%Y%m%d"));
	local nAward = me.GetTask(XmasSnowman.TSKG_GROUP, XmasSnowman.TSK_AWARD_FUDAI);
    if (nDate == math.floor(nAward /10)) and ((nAward %10) == 1) then
		Dialog:Say("你今天已经领过一次了，不能再次领取。");
		return;
	end
	

	
	if me.CountFreeBagCell() < 2 then
		Dialog:Say("您的包裹空间不足。");
		return;
	end	
	me.SetTask(XmasSnowman.TSKG_GROUP, XmasSnowman.TSK_AWARD_FUDAI, (nDate * 10 + 1));
	for i = 1 , 2 do
		local pItem = me.AddItem(unpack(XmasSnowman.FUDAI_ID));
		if pItem then
			pItem.Bind(1);
		end	
	end	
end


