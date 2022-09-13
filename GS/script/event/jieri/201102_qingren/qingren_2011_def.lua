-------------------------------------------------------
-- 文件名　：qingren_2011_def.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-01-05 16:32:01
-- 文件描述：
-------------------------------------------------------

local tbQingren_2011 = SpecialEvent.Qingren_2011 or {};
SpecialEvent.Qingren_2011 = tbQingren_2011;

-- task
tbQingren_2011.TASK_GID				= 	2151;
tbQingren_2011.TASK_FACTION 		=
{
	[1] = {{1, "少林"}, {2, "天王"}, {3, "唐门"}, {4, "五毒"}},
	[2] = {{5, "峨嵋"}, {6, "翠烟"}, {7, "丐帮"}, {8, "天忍"}},
	[3] = {{9, "武当"}, {10, "昆仑"}, {11, "明教"}, {12, "段式"}},
};

tbQingren_2011.TASK_POINT			=	13;			-- 活动积分
tbQingren_2011.TASK_RECV_TIMES		= 	14;			-- 被送次数
tbQingren_2011.TASK_RECV_INTERVAL	=	15;			-- 被送间隔
tbQingren_2011.TASK_GET_CARD		=	16;			-- 获得卡册
tbQingren_2011.TASK_GET_AWARD		= 	17;			-- 领奖标记

-- const
tbQingren_2011.MAX_RECV_TIMES		= 	5;			-- 每天最多被送5次
tbQingren_2011.MIN_RECV_INTERVAL	=	1800;		-- 两次背诵间隔30分钟
tbQingren_2011.MAX_FACTION			= 	11;			-- 最多11个门派
tbQingren_2011.MAX_BUFFER_LEN		= 	100;		-- 保留100个排名
tbQingren_2011.SEX_FLITER			=	{[0] = 1, [1] = 5};

-- itemid
tbQingren_2011.ROSE_ID				=	{18, 1, 1161, 1};
tbQingren_2011.CARD_ID				= 	{18, 1, 1162, 1};
tbQingren_2011.BOX_ID				=	{18, 1, 1163, 1};
tbQingren_2011.XUAN10_ID			=	{18, 1, 114, 10};
tbQingren_2011.XUAN12_ID			=	{18, 1, 114, 12};
tbQingren_2011.HORSE_ID				=	{1, 12, 41, 4};

-- title
tbQingren_2011.TITLE_ID				=	{6, 51, 1, 0};

function tbQingren_2011:CheckIsOpen()
	local nDate = tonumber(GetLocalDate("%Y%m%d")); 
	if nDate >= 20110212 and nDate <= 20110214 then
		return 1;
	elseif nDate >= 20110215 and nDate <= 20110221 then
		return 2;
	end
	return 0;
end

tbQingren_2011.tbBuffer	= tbQingren_2011.tbBuffer or {};
