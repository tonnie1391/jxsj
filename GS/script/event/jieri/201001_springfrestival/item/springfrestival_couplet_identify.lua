-- 文件名　：couplet_identify.lua
-- 创建者　：jiazhenwei
-- 创建时间：2009-12-28 17:42:09
-- 描  述  ：鉴定过的对联

local tbItem 	= Item:GetClass("distich_get");
SpecialEvent.SpringFrestival = SpecialEvent.SpringFrestival or {};
local SpringFrestival = SpecialEvent.SpringFrestival or {};

function tbItem:GetTip()
	local nCount = it.GetGenInfo(1);	--那副
	local nPart = it.GetGenInfo(2);		--上联还是下联
	local nTimes = me.GetTask(SpringFrestival.TASKID_GROUP,SpringFrestival.TASKID_IDENTIFYCOUPLET_NCOUNT) or 0;
	if nPart == 1 then
		return string.format("<color=yellow>横批：%s\n上联：%s<color>", SpringFrestival.tbCoupletList[nCount][1], SpringFrestival.tbCoupletList[nCount][nPart + 1]);
	else
		return string.format("<color=yellow>横批：%s\n下联：%s<color>", SpringFrestival.tbCoupletList[nCount][1], SpringFrestival.tbCoupletList[nCount][nPart + 1]);
	end
end
