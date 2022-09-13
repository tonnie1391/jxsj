-- 文件名　：snowman_def.lua
-- 创建者　：zounan
-- 创建时间：2009-11-24 14:32:42
-- 描  述  ：

SpecialEvent.Xmas2008 = SpecialEvent.Xmas2008 or {};
SpecialEvent.Xmas2008.XmasSnowman = SpecialEvent.Xmas2008.XmasSnowman or {};
local XmasSnowman = SpecialEvent.Xmas2008.XmasSnowman;

--任务变量
XmasSnowman.TSKG_GROUP 		   = 2027;
XmasSnowman.TSK_AWARD_COUNT    = 99;              
XmasSnowman.TSK_AWARD_DATE	   = 100;

--活动结束后有福袋
XmasSnowman.TSK_AWARD_FUDAI    = 98;       
  

XmasSnowman.AWARD_LEVEL_LIMIT  = 60;           -- 等级限制
XmasSnowman.AWARD_JINGHUO_LIMIT = 60;          -- 精活限制
XmasSnowman.AWARD_COUNT		   = 5;            --一天领取奖励次数
XmasSnowman.FUDAI_ID           = {18,1,80,1};  --福袋ID

XmasSnowman.EVENT_START 	   = 20091222;     -- 活动开始日期
XmasSnowman.EVENT_END		   = 20100104;	   -- 活动结束日期

XmasSnowman.MAXMAN_END		   = 20100119;	   -- 刷大雪人结束日期

XmasSnowman.REFRESH_TIME       = 2400;		   -- 活动刷新时间

--雪人 不同等级不同情况
XmasSnowman.SNOWMAN_LEVEL 	  = {[1] ={nClassId = 3710, nCount = 1500},
								 [2] ={nClassId = 3711, nCount = 2000},
								 [3] ={nClassId = 3712, nCount = 2500},
								 [4] ={nClassId = 3713, nCount = 3000},
								 [5] ={nClassId = 3714, nCount = 0},
								};
XmasSnowman.SNOWMAN_DISTANCE   = 40;          -- 雪人的有效距离
XmasSnowman.SNOWMAN_SKILL 	   = 1490;        -- 雪人成长技能ID

XmasSnowman.SNOWBALL_ID        = 3716;        -- 雪堆的ID
XmasSnowman.SNOWBALL_INTERVAL  = 3; 	      -- 雪堆消失后开3秒的计时器 重生

XmasSnowman.SNOWBALL_CATCHTIME = 1;     	  -- 采集雪片的时间
XmasSnowman.SNOWFLAKE_ID 	   = {18,1,535,1};  -- 小雪片的ID
XmasSnowman.SNOWFLAKE_TIMEOUT  = 3;			  -- 小雪片的时限

XmasSnowman.CHEST_ID 		   = 3717;        -- 宝箱ID 
XmasSnowman.CHEST_START 	   = 2100;		  -- 刷出宝箱的时间
XmasSnowman.CHEST_CATCHTIME    = 2;           -- 采集宝箱的时间
XmasSnowman.CHEST_INTERVAL     = 3;           -- 刷新宝箱的时间
XmasSnowman.CHEST_COUNT        = 5;           -- 刷新宝箱的次数
XmasSnowman.CHEST_LIVETIME     = 1;           -- 刷新宝箱的时间
XmasSnowman.CHEST_NUMBER       = {60,80,100}; -- 一次刷新宝箱的个数


XmasSnowman.YANHUA_SKILLID 	   = {1327};      -- 烟花技能ID
XmasSnowman.YANHUA_INTERVAL    = 5;		      -- 释放技能的间隔
XmasSnowman.YANHUA_COUNT       = 15;		  -- 烟花技能1分钟

XmasSnowman.EXP_NPC            = 3715;        -- 增加经验的NPC
XmasSnowman.EXP_INTERVAL       = 6;           -- 每6秒加一次经验
XmasSnowman.EXP_TIME 		   = 3 * 60;      -- 持续时间
XmasSnowman.EXP_RATE           = 1400;        -- 经验倍数 
XmasSnowman.EXP_ROUND          = 90;          -- 增加经验范围

XmasSnowman.XUETUAN_DISTANCE   =  10;         -- 雪团的有效距离

XmasSnowman.BOX_ID 			   = {18,1,536,1};
						
						  
--内存变量						  
XmasSnowman.tbSnowmanMgr  = XmasSnowman.tbSnowmanMgr  or {};    -- 雪人管理
XmasSnowman.tbSnowballMgr = XmasSnowman.tbSnowballMgr or {};	-- 雪球管理			
XmasSnowman.tbChestMgr    = XmasSnowman.tbChestMgr    or {};    -- 宝箱管理

--出生点 文件读取
XmasSnowman.SNOWMAN_POS  = XmasSnowman.SNOWMAN_POS or {};	
XmasSnowman.CHEST_POS    = XmasSnowman.CHEST_POS   or {};	
XmasSnowman.SNOWBALL_POS = XmasSnowman.SNOWBALL_POS or {};
XmasSnowman.SNOWSEED_POS = XmasSnowman.SNOWSEED_POS or {};

XmasSnowman.nState        = 0;     -- 活动阶段
XmasSnowman.nChestCount   = 0;     -- 已刷宝箱的次数
XmasSnowman.nYanhuaCount  = 0;     -- 烟花次数
							
							