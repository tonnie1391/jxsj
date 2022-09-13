-------------------------------------------------------------------
--File: 	factionelect_gs.lua
--Author: 	zhengyuhua
--Date: 	2008-9-28 18:29
--Describe:	门派选举常量数据定义
-------------------------------------------------------------------
local preEnv = _G;	--保存旧的环境
setfenv(1, FactionElect);	--设置当前环境为FactionBattle

TASK_GROUP				= 2017		-- 任务变量组
TASK_VOTE_VER 			= 1; 		-- 投票版本号（最近投过第几届的票）
TASK_VOTE_ID				= 2; 		-- 投票给某个侯选人的侯选ID
TASK_WIN_VER			= 3;		-- 领取大师兄大师姐称号 版本号
TITEL_GENRE				= 4;		-- 称号组
TITEL_TYPE				= 2;		-- 称号类型
START_DATE				= 1;		-- 开启日期	
-- 门派荣誉
HONOR_CLASS				= 2;		-- 荣誉大类
HONOR_WULIN_TYPE		= 0;		-- 武林荣誉小类
HONOR_ADDITION			= 0.1;	-- 当江湖威望大于当天的精活时，加成投票数
HONOR_ADDITION_PERCENT	= 0.01;	-- 每多相当于福利精活威望的10%，投票票数加成1%
HONOR_ADDITION_BASE		= 0.1;	-- 每多相当于福利精活威望的10%
HONOR_ADDITION_MAX		= 0.5	-- 最多因江湖威望加成投票数50%

FACTION_TO_MASTER = 
{
	"玄慈",
	"杨铁心",
	"唐晓",
	"古嫣然",
	"无想",
	"尹筱雨",
	"石轩辕",
	"完颜襄",
	"王重阳",
	"宋秋石",
	"方行觉",
	"段智兴",
	"林烟卿",
}

--BEGIN---------------------- 与程序 kgc_factionelectdef.h 内定义要保持一致

KD_FACTION_CANDIDATE_MAX		= 30	-- 门派选举候选人上限
KD_FACTION_DATA_SEGMENT_LENGTH	= 1000	-- 门派数据段
KD_FACTION_PUBLIC_DATE			= 1	

-- VALUE 共用任务变量
emKFACTION_BATTLE_CUR_ID		= 0		-- 当前进行门派竞技ID号(各门派共用)
emKFACTION_WINNER_RECODE_COUNT	= 1		-- 历届选举胜者记录计数(各门派共用)
emKFACTION_CUR_VOTE_MONTH		= 2		-- 最近一次选举的月份(各门派共用，用于标识本月是否已经举行过选举)
emKFACTION_PUBLIC_TASK_END		= 50	-- 共用任务变量到此结束
emKFACTION_VOTE_FLAG			= 51	-- 是否处于投票期(各门派共用)

-- VALUE 区分门派任务变量
emKFACTION_CANDIDATE_CUR_COUNT	= 52	-- 当前候选人计数
emKFACTION_LAST_CANDIDATE_COUNT	= 53	-- 上月候选人总数

emKFACTION_FACTION_AHEAD_ID		= 100	-- 该门派处于领先的候选人ID(作用是为了在两个相同得票的候选人能区分胜负)
emKFACTION_CANDIDATE_VOTE_BEGIN	= 101	-- 上月各个候选人的得票情况开始位置（选举在月头选出上月的冠军）
emKFACTION_CANDIDATE_VOTE_END	= emKFACTION_CANDIDATE_VOTE_BEGIN + KD_FACTION_CANDIDATE_MAX

-- BUF 任务变量
emKFACTION_CANDIDATE_CUR_BEGIN			= 0						-- 本月候选人开始位置,
emKFACTION_CANDIDATE_LAST_BEGIN			= emKFACTION_CANDIDATE_CUR_BEGIN + KD_FACTION_CANDIDATE_MAX 	-- 上月候选人开始位置
emKFACTION_CANDIDATE_END				= emKFACTION_CANDIDATE_LAST_BEGIN + KD_FACTION_CANDIDATE_MAX

emKFACTION_WINNER_RECODE_BEGIN			= 100000					-- 历届各门派选举优胜记录

--END---------------------- 与程序 kgc_factionelectdef.h 内定义要保持一致
preEnv.setfenv(1, preEnv);	--恢复全局环境

FactionElect.FACTION_NUM				= Env.FACTION_NUM;	-- 门派个数

