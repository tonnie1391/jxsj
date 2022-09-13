-- 跨服

Transfer.tbServerTaskId = {2063, 3};			  --记录网关Id（废弃使用）
Transfer.tbServerTaskGatewayName = {2063, 5, 12}; --记录网关名
Transfer.tbServerTaskSaveMapId = {2063, 13};	  --地图ID
Transfer.tbServerTaskSavePosX  = {2063, 14};	  --地图x
Transfer.tbServerTaskSavePosY  = {2063, 15};	  --地图y
Transfer.tbLoginGlbServerEvent = Transfer.tbLoginGlbServerEvent or {};	--注册登陆事件
Transfer.tbTransferSyncData	   = Transfer.tbTransferSyncData or {};		--注册跨服数据同步

--英雄岛地图Id
Transfer.tbGlobalMapId = {
	--编号 地图ID
	[1] = 1609,
	[2] = 1609, --1610,
	[3] = 1609, --1611,
	[4] = 1609, --1612,
	[5] = 1609, --1613,
	[6] = 1609, --1614,
	[7] = 1609, --1615,
	[8] = 1609, --1644,
	[9] = 1609, --1645,
	[10] = 1609, --1646,
	[11] = 1609, --1647,
	[12] = 1609, --1648,
	[13] = 1609, --1649,
	[14] = 1609, --1650,
};
