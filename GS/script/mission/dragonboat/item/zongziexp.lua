-- 文件名　：zongziexp.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-05-18 11:56:05
-- 描  述  ：

local tbItem = Item:GetClass("dragonboat_zongziexp")

function tbItem:OnUse()
	if me.GetTask(2064, 21) >= 100 then
		Dialog:Say("你最多只能食用<color=yellow>100个粽子<color>，已不能再吃了。");
		return 0;
	end
	local nBase = me.GetBaseAwardExp();
	me.AddExp(nBase*60);
	me.SetTask(2064, 21, me.GetTask(2064, 21)+1);
	return 1;
end

function tbItem:GetTip()
	local szTip = "";
	local tbParam = self.tbBook;
	local nUse =  me.GetTask(2064, 21);
	szTip = szTip .. string.format("<color=green>已食用%s/100个<color>", nUse);
	return szTip;
end

