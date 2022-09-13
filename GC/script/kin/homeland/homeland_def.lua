-- 文件名　：homeland.lua
-- 创建者　：huangxiaoming
-- 创建时间：2011-06-10 14:01:10
-- 描  述  ：家园

HomeLand._OPEN				= 1;			-- 系统开关

HomeLand.MAX_LADDER_RNAK	= 200;			-- 最多上榜家族
HomeLand.REFRESH_WEEKDAY	= 1;			-- 每星期一更新
HomeLand.MAX_VISIBLE_LADDER = 1000;			-- 排行榜上最多显示的家族数
HomeLand.MAX_LOG_COUNT		= HomeLand.MAX_LADDER_RNAK + 100;	-- log记录的家族数目

HomeLand.MAP_TEMPLATE		= 2086;			-- 家园模板id

HomeLand.tbLastWeekRank 	= HomeLand.tbLastWeekRank or {};			-- 上周排名表
HomeLand.tbLastWeekKinId2Index = HomeLand.tbLastWeekKinId2Index or {};		-- 上周排名索引表
HomeLand.tbCurWeekRank		= HomeLand.tbCurWeekRank or {};			-- 本周排名表
HomeLand.tbKinId2Index		= HomeLand.tbKinId2Index or {};			-- 家族id到索引表
HomeLand.tbKinId2MapId		= HomeLand.tbKinId2MapId or {};			-- 家族id对应地图id
HomeLand.tbLoadFailKin		= HomeLand.tbLoadFailKin or {};			-- 加载失败的加载列表

HomeLand.CAMP = 
{
	[1]		= "宋方",
	[2]		= "金方",
	[3]		= "中立",
}

HomeLand.DEFAULT_POS			= {1, 1401, 3146};-- 默认离开坐标点
HomeLand.ENTER_POS				= {56384/32 ,106848/32};	-- 进入坐标
HomeLand.NPC_POS_CRAFTMAN		= {1794, 3093};	-- 宝石工匠
HomeLand.NPC_POS_CARVEMANANGE	= {1633, 3151}; -- 雕塑管理员
HomeLand.NPC_POS_MACHUANSHAN	= {1679, 3231};	-- 马穿山

function HomeLand:CheckOpen()
	return self._OPEN;
end

HomeLand.TB_TRANS_POS	=
{
	[1] = {[1] = {1632, 3201}, [2] = "中心广场"},	-- 中央广场
	[2] = {[1] = {1784, 3108}, [2] = "熔炉"},	-- 熔炉	
	[3] = {[1] = {1535, 3147}, [2] = "后园"},	-- 田园
	[4] = {[1] = {1550, 2981}, [2] = "议事厅"},	-- 议事厅
	[5] = {[1] = {1692, 3101}, [2] = "仓库"}, -- 未知
};