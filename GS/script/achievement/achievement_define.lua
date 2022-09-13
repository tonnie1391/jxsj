--===================================
-- 文件名　：achievement_define.lua
-- 创建者　：furuilei
-- 创建时间：2010-06-30 10:41:00
-- 功能描述：成就系统数据定义文件
--===================================

--  成就系统是否打开的标记
Achievement.FLAG_OPEN = EventManager.IVER_nAchievementOpen;

-- 成就系统完成情况的记录（每个bit表示一个成就是否完成）
Achievement.TASK_GROUP_ACV = 2127;

-- 对应每个成就的辅助性的一些记录信息（比如某个成就需要杀100个npc，其中记录了目前杀了多少个）
-- 在这个对应的成就完成之后，这个变量注意清零，减少存盘数据量
Achievement.TASK_GROUP_HELP = 2128;

-- 成就点数
-- 注：在这里设置两个变量记录成就的点数，因为成就排行榜需要用的是一个不断累计上升的数值，
--     而玩家身上记录的另一个任务变量可以作为以后后续开发时候的通用数值货币来使用，两个
--     数值会存在差异
Achievement.TASK_GROUP_POINT		= 2129;
Achievement.TSK_ID_POINT_CUR		= 1;	-- 当前的成就点数
Achievement.TSK_ID_POINT_ACCUMULATE	= 2;	-- 积累的成就点数
Achievement.TSK_ID_CONSUMABLE_POINT	= 3;	-- 可消费成就积分
Achievement.TSK_ID_FLAG_CONSUME		= 4;	-- 是否领取过可消费成就积分的标志

-- 通用的成就完成条件的编号
Achievement.INDEX_COND_REPUTE	= 1;
Achievement.INDEX_COND_TITLE	= 2;
Achievement.INDEX_COND_MAP		= 3;
Achievement.INDEX_COND_KILLNPC	= 4;
Achievement.INDEX_COND_ALL		= 5;
Achievement.INDEX_COND_COUNT	= 6;

-- 通用的成就奖励条件
Achievement.INDEX_AWARD_TITLE	= 1;

-- 从配置文件 achievement.txt 中读取到的成就系统的基本信息
Achievement.tbAchievementInfo = Achievement.tbAchievementInfo or {};
-- 从配置文件 cond_XXX.txt 中读取到的通用成就完成条件的信息
Achievement.tbCondInfo = Achievement.tbCondInfo or {};
-- 成就id和成就大类，小类，索引的对应关系
Achievement.tbMapingInfo = Achievement.tbMapingInfo or {};
-- 成就的奖励列表
Achievement.tbAwardInfo = Achievement.tbAwardInfo or {};
