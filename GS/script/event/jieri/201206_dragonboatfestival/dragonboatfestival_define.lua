-- 文件名　：dragonboatfestival_define.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-06-07 11:13:29
-- 功能    ：

SpecialEvent.tbDragonBoatFestival2012 = SpecialEvent.tbDragonBoatFestival2012 or {};
local tbDragonBoatFestival2012 = SpecialEvent.tbDragonBoatFestival2012;

tbDragonBoatFestival2012.TASKID_GROUP			= 2192;

tbDragonBoatFestival2012.TASKID_POSITION_START	= 46; 	--46-60表示15个地方
tbDragonBoatFestival2012.TASKID_POSITION_END	= 60; 	--46-60表示15个地方
tbDragonBoatFestival2012.TASKID_GETITEM_1		= 61; 	--获得道具的次数
tbDragonBoatFestival2012.TASKID_GETITEM_2		= 62; 	--获得道具的次数
tbDragonBoatFestival2012.TASKID_GETITEM_3		= 63; 	--获得道具的次数
tbDragonBoatFestival2012.TASKID_COUNT			= 64; 	--投种子的次数
tbDragonBoatFestival2012.TASKID_ITEMCOUNT		= 65; 	--偷吃粽子的次数
tbDragonBoatFestival2012.TASKID_GETITEM_4		= 66; 	--领取团圆粽
tbDragonBoatFestival2012.TASKID_TIME			= 67; 	--时间
tbDragonBoatFestival2012.TASKID_GETBOOK		= 68; 	--获得册子
tbDragonBoatFestival2012.TASKID_OPENBOX		= 69; 
tbDragonBoatFestival2012.TASKID_GETSPEITEM		= 70;

tbDragonBoatFestival2012.tbItemList 		= {{18,1,1740,1},{18,1,1741,1},{18,1,1742,1}}	--粽叶，糯米，莲子
tbDragonBoatFestival2012.tbItem 			= {18,1,1743,1};	--粽子
tbDragonBoatFestival2012.tbBook 			= {18,1,1745,1};	--册子
tbDragonBoatFestival2012.tbGItem 		= {18,1,1746,1};	--锅
tbDragonBoatFestival2012.tbKinItem 		= {18,1,1744,1};	--家族粽子
tbDragonBoatFestival2012.tbRandomBox 	= {18,1,1750,1};	--花
tbDragonBoatFestival2012.tbRandomBox2 	= {18,1,1750,2};--熟透的粽子
tbDragonBoatFestival2012.tbSpeItem 	= {18,1,1730,9};
tbDragonBoatFestival2012.tbSpeItem2 	= {18,1,475,1};
tbDragonBoatFestival2012.tbPosition 	= {
	{1, 1387, 3183,		"云中镇北部",	{1, 1386, 3169}},
	{1, 1417, 3193,		"云中镇中部",	{1,1422,3184}},
	{7, 1444, 3347,		"龙泉村中部",	{7,1449,3348}},
	{7, 1435, 3385,		"龙泉村西部",	{7,1428,3387}},
	{8, 1607, 3438,		"巴陵县西部",	{8,1611,3444}},
	{8, 1758, 3572,		"巴陵县南部",	{8,1755,3563}},
	{4, 1571, 3100,		"稻香村",		{4,1577,3092}},
	{5, 1519, 3178,		"江津村",		{5,1522,3184}},
	{6, 1721, 3043,		"石鼓镇",		{6,1717,3034}},
	{2, 1845, 3678,		"龙门镇",		{2,1852,3669}},
	{23, 1540, 3176,	"汴京府",		{23,1534,3163}},
	{27, 1534, 3376,	"成都府",		{27,1530,3364}},
	{26, 1540, 3208,	"扬州府",		{26,1536,3213}},
	{29, 1527, 3801,	"临安府",		{29,1521,3807}},
	{24, 1789, 3679,	"凤翔府",		{24,1791,3686}},
};

tbDragonBoatFestival2012.tbExp = {
	{6500,14},
	{8500,25},
	{9500,50},
	{10000,100},
}

tbDragonBoatFestival2012.nStarTime 		= 20120621;
tbDragonBoatFestival2012.nEndTime 		= 20120625;
tbDragonBoatFestival2012.nTotalCount 		= 15;
tbDragonBoatFestival2012.tbEventTime 		= {{110000,140000}, {190000,220000}};
tbDragonBoatFestival2012.nNpcId 			= 10230;
tbDragonBoatFestival2012.nMaxFireCount 	= 10;
tbDragonBoatFestival2012.nMaxGetCount 	= 10;

tbDragonBoatFestival2012.nGradeOne		= 15;
tbDragonBoatFestival2012.nGradeTow		= 25;
tbDragonBoatFestival2012.nFireLimit 		 = 120;

function tbDragonBoatFestival2012:CheckTime(bEventDay)
	local nDayNow = tonumber(GetLocalDate("%Y%m%d"));
	if nDayNow < self.nStarTime then
		return 0, "活动还没开启。";
	end
	if nDayNow > self.nEndTime then
		return 0, "活动已经结束";
	end
	if bEventDay then
		return 1;
	end
	local nTimeNow = tonumber(GetLocalDate("%H%M%S"));
	for _, tbTime in ipairs(self.tbEventTime) do
		if nTimeNow >= tbTime[1] and nTimeNow < tbTime[2] then
			return 1;
		end
	end
	return 0, "活动时间为：<color=yellow>11：00-14：00和19：00-22：00<color>";
end
