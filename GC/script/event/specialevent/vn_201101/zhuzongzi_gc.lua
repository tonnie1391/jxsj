-- 文件名　：zhuzongzi_gc.lua
-- 创建者　：huangxiaoming
-- 创建时间：2010-12-21 16:10:10
-- 描  述  ：

if not MODULE_GC_SERVER then
	return;
end

SpecialEvent.ZongZi2011 = SpecialEvent.ZongZi2011 or {};
local tbZongZi = SpecialEvent.ZongZi2011 or {};
tbZongZi.MAX_BENXIAO_COUNT = 10;	-- 最多奔宵个数

function tbZongZi:RandomBenXiao_GC(nPlayerId)
	local nNowDate = tonumber(GetLocalDate("%Y%m%d"));
	local nDay = KGblTask.SCGetDbTaskInt(DATASK_VN_BENXIAO_LAST_DAY);
	local nCount = KGblTask.SCGetDbTaskInt(DATASK_VN_BENXIAO_ALL_COUNT);
	if nDay >= nNowDate or nCount >= self.MAX_BENXIAO_COUNT then	-- 今天已经随到过奔宵了或服务器超过10个
		GlobalExcute{"SpecialEvent.ZongZi2011:RandomBenXiao_GS2", nPlayerId, 0, nNowDate, nCount};
		return 0;	
	end
	KGblTask.SCSetDbTaskInt(DATASK_VN_BENXIAO_LAST_DAY, nNowDate);
	KGblTask.SCSetDbTaskInt(DATASK_VN_BENXIAO_ALL_COUNT, nCount + 1);
	GlobalExcute{"SpecialEvent.ZongZi2011:RandomBenXiao_GS2", nPlayerId, 1, nNowDate, nCount + 1};
	local szName = KGCPlayer.GetPlayerName(nPlayerId);
	Dialog:GlobalNewsMsg_GC(string.format("%s使用粽子幸运获得奔宵", szName));
	Dialog:GlobalMsg2SubWorld_GC(string.format("<color=yellow>%s<color>使用粽子幸运获得奔宵", szName));
end