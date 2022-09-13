-------------------------------------------------------
-- 文件名　：womenday_2011_def.lua
-- 创建者　：zhangjinpin@kingsoft
-- 创建时间：2011-02-25 15:15:18
-- 文件描述：
-------------------------------------------------------

local tbWomenday_2011 = SpecialEvent.Womenday_2011 or {};
SpecialEvent.Womenday_2011 = tbWomenday_2011;

-- task
tbWomenday_2011.TASK_GID			= 	2190;	--2155(2011年);
tbWomenday_2011.TASK_CARD 			=
{
	[1] = {{1, "白秋琳", 3570}, {2, "沈荷叶", 3562}, {3, "郝漂靓", 3563}},
	[2] = {{4, "叶芷琳", 3576}, {5, "古枫霞", 3601}, {6, "晏若雪", 3603}},
	[3] = {{7, "尹筱雨", 3536}, {8, "古嫣然", 3524}, {9, "无想师太", 3530}, {10, "红姨", 6513}},
};
tbWomenday_2011.TASK_GET_CARD		= 	11;
tbWomenday_2011.TASK_DAY_AWARD		=	12;
tbWomenday_2011.TASK_DAY_FLOWER		=	13;

-- const
tbWomenday_2011.MAX_NPC_COUNT		=	10;
tbWomenday_2011.tbNpcGroup 			= 	{3570, 3562, 3563, 3576, 3601, 6513, 3603, 3536, 3530, 3524};

-- itemid
tbWomenday_2011.MARK_ID				= 	{1, 13, 139, 1};
tbWomenday_2011.CARD_ID				=	{18,1,1691,1};	--{18, 1, 1191, 1};
tbWomenday_2011.FLOWER_ID			=	{18,1,1690,1};  --{18, 1, 1190, 1};
tbWomenday_2011.SEX_BOX_ID			=
{
	[0] = {18, 1, 1693, 1},	--[0] = {18, 1, 1193, 1},
	[1] = {18, 1, 1692, 1},	--[1] = {18, 1, 1192, 1},
};

-- title
tbWomenday_2011.TITLE_ID			= 	{6, 53, 1, 0};

-- award
tbWomenday_2011.SEND_AWARD			=
{
	[1] = {Rate = 285, Count = 88, Type = "coin"},
	[2] = {Rate = 120, Count = 188, Type = "coin"},
	[3] = {Rate = 60, Count = 388, Type = "coin"},
	[4] = {Rate = 35, Count = 888, Type = "coin"},
	[5] = {Rate = 285, Count = 8800, Type = "money"},
	[6] = {Rate = 120, Count = 18800, Type = "money"},
	[7] = {Rate = 60, Count = 38800, Type = "money"},
	[8] = {Rate = 35, Count = 88800, Type = "money"},
}

-- rate
tbWomenday_2011.TEAM_RATE			=
{
	[1] = 1,
	[2] = 1.1,
	[3] = 1.2,
	[4] = 1.3,
	[5] = 1.4,
	[6] = 1.5,
};

-- switch
function tbWomenday_2011:CheckIsOpen()
	local nDate = tonumber(GetLocalDate("%Y%m%d")); 
	--if nDate >= 20110308 and nDate <= 20110312 then
	if nDate >= 20120308 and nDate <= 20120312 then	
		return 1;
	end
	return 0;
end
