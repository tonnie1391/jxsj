-- 文件名　：define.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-1-25 10:10:10
-- 描  述  ：

if not MODULE_GC_SERVER then
	return;
end

Require("\\script\\event\\specialevent\\santaclaus2010\\santa2010_def.lua");
SpecialEvent.Santa2010 = SpecialEvent.Santa2010 or {};
local tbSanta = SpecialEvent.Santa2010 or {};

function SpecialEvent:SantaClaus2010_GC(nSeg)
	nSeg = nSeg or 6;
	local nData = tonumber(GetLocalDate("%Y%m%d"));
	if nData >= tbSanta.OPEN_DAY and nData <= tbSanta.CLOSE_DAY then
		GlobalExcute{"SpecialEvent.Santa2010:StartSantaClaus_GS"};
		Timer:Register(tbSanta.TOTAL_TIME, tbSanta.CloseSantaClaus2010_GC, tbSanta, nSeg);
	end
	
end

-- 结束公告
function tbSanta:CloseSantaClaus2010_GC(nSeg)
	Dialog:GlobalNewsMsg_GC(self.MSG_INFO[nSeg]);
	Dialog:GlobalMsg2SubWorld_GC(self.MSG_INFO[nSeg]);
	return 0;
end