-------------------------------------------------------
-- 文件名　：vipreborn_def.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-02-23 12:24:50
-- 文件描述：
-------------------------------------------------------

Require("\\script\\misc\\serverlist.lua");

local tbVipReborn = VipPlayer.VipReborn or {};
VipPlayer.VipReborn = tbVipReborn;

tbVipReborn.TASK_GROUP_ID 		= 2154;		-- 任务变量组
tbVipReborn.TASK_QUALIFICATION	= 1;		-- 转服资格
tbVipReborn.TASK_REBORN_FINISH	= 2;		-- 领取转服奖励
tbVipReborn.TASK_REBORN_TIME	= 3;		-- 领取奖励时间(天)
tbVipReborn.TASK_BIND_VALUE		= 4;		-- 绑定价值量
tbVipReborn.TASK_NOBIND_VALUE	= 5;		-- 非绑价值量
tbVipReborn.TASK_ACCOUNT		= 6;		-- 指定账号(6-13);
tbVipReborn.TASK_GATEWAY		= 14;		-- 指定网关(14-21);
tbVipReborn.TASK_MONTH_VALUE	= 22;		-- 每月领取的价值量

-- 领取系数
tbVipReborn.MONTH_RATE			= 30;

-- 转入账号表
-- tbGlobalBuffer[szAccount] = {nNewGateId, nBindValue, nNobindValue};
tbVipReborn.tbGlobalBuffer = tbVipReborn.tbGlobalBuffer or {};

-- Buffer索引
tbVipReborn.nBufferIndex = GBLINTBUF_VIP_REBORN;	

-- 声望转换价值
tbVipReborn.tbReputeValue =
{
	[1] = {tbRepute = {5, 2}, tbLevel = {0, 3000, 9000}, szName = "2008盛夏声望"},				-- 腰带
	[2] = {tbRepute = {5, 4}, tbLevel = {0, 0, 3000, 7000}, szName = "祈福声望"},				-- 护身符
	[3] = {tbRepute = {5, 5}, tbLevel = {0, 3500, 10500}, szName = "2010盛夏声望"},				-- 项链
	[4] = {tbRepute = {5, 6}, tbLevel = {0, 3500, 10500}, szName = "寒武遗迹声望"},				-- 护腕
	[5] = {tbRepute = {7, 1}, tbLevel = {0, 0, 0, 0, 3000, 9000}, szName = "武林联赛声望"},		-- 衣服
	[6] = {tbRepute = {8, 1}, tbLevel = {0, 0, 0, 0, 3500, 10500}, szName = "领土争夺声望"},	-- 帽子
	[7] = {tbRepute = {9, 2}, tbLevel = {0, 12000, 30000}, szName = "秦始皇陵·发丘门声望"},		-- 武器
	[8] = {tbRepute = {10, 1}, tbLevel = {0, 3500, 10500}, szName = "民族大团圆声望"},			-- 鞋子
	[9] = {tbRepute = {11, 1}, tbLevel = {0, 3500, 10500}, szName = "武林大会声望"},			-- 戒指
	[10] = {tbRepute = {12, 1}, tbLevel = {0, 3500, 10500}, szName = "跨服联赛声望"},			-- 鞋子
};

-- 提升等级时间轴
tbVipReborn.tbTimeLevel = 
{
	[1] = {300, 121},
	[2] = {270, 120},
	[3] = {240, 118},
	[4] = {210, 115},
	[5] = {180, 112},
	[6] = {150, 109},
	[7] = {130, 106},
	[8] = {110, 103},
};

-- 计算的玄晶类型
tbVipReborn.tbXuanjing =
{
	{18, 1, 1, 8},
	{18, 1, 1, 9},
	{18, 1, 1, 10},
	{18, 1, 1, 11},
	{18, 1, 1, 12},
	{18, 1, 114, 8},
	{18, 1, 114, 9},
	{18, 1, 114, 10},
	{18, 1, 114, 11},
	{18, 1, 114, 12},
};
