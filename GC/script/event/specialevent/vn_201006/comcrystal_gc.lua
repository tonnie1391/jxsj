-- 文件名　：comcrystal_gc.lua
-- 创建者　：jiazhenwei
-- 创建时间：2010-05-14 09:16:32
-- 描  述  ：越南6月合成结晶

--VN--

if not MODULE_GC_SERVER then
	return;
end

SpecialEvent.tbComCrystal = SpecialEvent.tbComCrystal or {};
local tbComCrystal = SpecialEvent.tbComCrystal;

--仲裁：一个服务器只能产出2个120级马
function tbComCrystal:IsGetHorse(nPlayerId)
	local nCount = KGblTask.SCGetDbTaskInt(DBTASD_EVENT_COMCRYSTAL) + 1;
	if nCount <= 2 then
		GlobalExcute{"SpecialEvent.tbComCrystal:OnSpecialAward",nPlayerId};
	end
	KGblTask.SCSetDbTaskInt(DBTASD_EVENT_COMCRYSTAL, nCount);
end