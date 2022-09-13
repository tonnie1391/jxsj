-------------------------------------------------------
-- 文件名　：domaintask_def.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2009-06-18 05:35:10
-- 文件描述：
-------------------------------------------------------

-- 任务要点
-- 活动开关：领土开放20场后开启，持续时间15天
-- 活动时间：周1-5，16:00-17:00，21:00-22:00，周6-7，16:00-17:00
-- 刷怪区域：18个领土+4个新手村，随机取出8块领土
-- 固定点产生领土守卫者，死亡后角色增加霸主之印残片
-- 队友增加霸主之印残片，如果背包满，则掉落在地上，不绑定
-- 全局变量：领土战步骤，开门任务开启时间

if not Domain.DomainTask then
	Domain.DomainTask = {};
end

local tbDomainTask = Domain.DomainTask;

-- task group
tbDomainTask.TASK_GROUP_ID = 2097;

-- max map count
tbDomainTask.MAX_MAP_COUNT = 8;

-- min map count in every server
tbDomainTask.MIN_MAP_COUNT = 2;

-- period time
tbDomainTask.VAILD_OPEN_TIME = 60 * 60 * 24 * 15;

-- cozone time
tbDomainTask.EXTRA_COZONE_TIME = 60 * 60 * 24 * 5;

-- start time point
tbDomainTask.START_TIME = 200906242400;

-- pos config
tbDomainTask.NPC_POS_PATH = "\\setting\\domainbattle\\task\\npc_pos.txt";

-- index by mapid
tbDomainTask.tbNpcPos = {};

-- server only
tbDomainTask.tbMapList = {};

-- on-off temp
tbDomainTask.nState = 0;

tbDomainTask.BUCHANG_STATUARY_PLAYER_NAME 		= {};										-- 补偿雕像资格的玩家名 格式：{ {szGateWay = "", szName = ""},}
tbDomainTask.BUCHANG_OPEN_SERVER				= {"gate1106",};							-- 开启补偿兑换的区服 
tbDomainTask.BUCHANG_STATUARY_BAZHUZHIYIN_COUNT = 4000;										-- 补偿树立雕像资格需要交纳霸主之印的数量
tbDomainTask.BUCHANG_OPEN_ALLSERVER_FLAG		= 0;										-- 开启全部补偿的标志 1,开启全局补偿，0，不全局开补偿
tbDomainTask.BUCHANG_OPEN_FLAG					= 0;										-- 开启补偿开关，1是开，0是关，默认关
