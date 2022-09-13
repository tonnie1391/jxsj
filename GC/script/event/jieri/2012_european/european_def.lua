-------------------------------------------------------
-- 文件名　: european_def.lua
-- 创建者　: zhangjinpin@kingsoft
-- 创建时间: 2012-06-15 16:27:11
-- 文件描述: 
-------------------------------------------------------

local tbEuropean = SpecialEvent.tbEuropean or {};
SpecialEvent.tbEuropean = tbEuropean;

tbEuropean.IS_OPEN				= 1;

tbEuropean.TASK_GID				= 2194;			-- 任务变量组
tbEuropean.TASK_COUNT			= 1;			-- 投注数
tbEuropean.TASK_RESULT			= 2;			-- 投注方
tbEuropean.TASK_SESSION			= 3;			-- 流水号

tbEuropean.MAX_COUNT 			= 50;			-- 每天限注
tbEuropean.BASE_MONEY			= 100000;		-- 每注金额
tbEuropean.MIN_MANTLE			= 4;			-- 最低荣誉等级
tbEuropean.MIN_LEVEL			= 60;			-- 最低角色等级
tbEuropean.MIN_MANTLE_NAME		= "惊世";		-- 最低荣誉名字

tbEuropean.BUFFER_INDEX			= GBLINTBUF_EUROPEAN;

tbEuropean.BASE_BUFFER			=
{
	[1] = {szTime = "2012年6月22日", tbTime = {201206201400, 201206220200}, tbTeam = {"意大利", "平局", "克罗地亚"}, tbAward = {3.66, 1.88, 1.22}, nResult = 0},
	[2] = {szTime = "2012年6月23日", tbTime = {201206221400, 201206230200}, tbTeam = {"荷兰", "平局", "法国"}, tbAward = {3.66, 1.88, 1.22}, nResult = 0},
	[3] = {szTime = "2012年6月24日", tbTime = {201206231400, 201206240200}, tbTeam = {"西班牙", "平局", "德国"}, tbAward = {3.66, 1.88, 1.22}, nResult = 0},
	[4] = {szTime = "2012年6月25日", tbTime = {201206241400, 201206250200}, tbTeam = {"英格兰", "平局", "克罗地亚"}, tbAward = {3.66, 1.88, 1.22}, nResult = 0},
	[5] = {szTime = "2012年6月29日", tbTime = {201206251400, 201206290200}, tbTeam = {"意大利", "平局", "西班牙"}, tbAward = {3.66, 1.88, 1.22}, nResult = 0},
	[6] = {szTime = "2012年6月30日", tbTime = {201206291400, 201206300200}, tbTeam = {"英格兰", "平局", "法国"}, tbAward = {3.66, 1.88, 1.22}, nResult = 0},
	[7] = {szTime = "2012年7月02日", tbTime = {201206301400, 201207020200}, tbTeam = {"意大利", "平局", "英格兰"}, tbAward = {3.66, 1.88, 1.22}, nResult = 0},
};

tbEuropean.IMAGE_PATH			=
{
	["波兰"] = "<pic=image\\item\\other\\scriptitem\\Fifa_Poland.spr>",
	["希腊"] = "<pic=image\\item\\other\\scriptitem\\Fifa_Greece.spr>",
	["俄罗斯"] = "<pic=image\\item\\other\\scriptitem\\Fifa_Russian.spr>",
	["捷克"] = "<pic=image\\item\\other\\scriptitem\\Fifa_Czech.spr>",

	["荷兰"] = "<pic=image\\item\\other\\scriptitem\\Fifa_Netherlands.spr>",
	["丹麦"] = "<pic=image\\item\\other\\scriptitem\\Fifa_Denmark.spr>",
	["德国"] = "<pic=image\\item\\other\\scriptitem\\Fifa_Germany.spr>",
	["葡萄牙"] = "<pic=image\\item\\other\\scriptitem\\Fifa_Portugal.spr>",

	["西班牙"] = "<pic=image\\item\\other\\scriptitem\\Fifa_Spain.spr>",
	["意大利"] = "<pic=image\\item\\other\\scriptitem\\Fifa_Italy.spr>",
	["爱尔兰"] = "<pic=image\\item\\other\\scriptitem\\Fifa_Ireland.spr>",
	["克罗地亚"] = "<pic=image\\item\\other\\scriptitem\\Fifa_Coratia.spr>",

	["乌克兰"] = "<pic=image\\item\\other\\scriptitem\\Fifa_Ukraine.spr>",
	["瑞典"] = "<pic=image\\item\\other\\scriptitem\\Fifa_Sweden.spr>",
	["法国"] = "<pic=image\\item\\other\\scriptitem\\Fifa_France.spr>",
	["英格兰"] = "<pic=image\\item\\other\\scriptitem\\Fifa_England.spr>",
};

tbEuropean.tbGlobalBuffer = tbEuropean.tbGlobalBuffer or {};
