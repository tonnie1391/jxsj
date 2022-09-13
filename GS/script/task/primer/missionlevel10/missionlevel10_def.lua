-- 文件名　：missionlevel10_def.lua
-- 创建者　：zhangjunjie
-- 创建时间：2011-09-16 14:52:32
-- 描述：10级教育副本define

Task.PrimerLv10 = Task.PrimerLv10 or {};

local PrimerLv10 = Task.PrimerLv10;

local preEnv = _G	 
setfenv(1,PrimerLv10)

nMapTemplateId = 2130;	--地图模板id

MAX_TIME = 30 * 60;	--游戏最大时间

ENTER_POS = {{48992/32,98304/32}};	--进入点

LEAVE_POS = {1605,3288};	--离开点

PUSH_FIRE_ITEM = {20,1,874,1};	--灭火的水

MAX_PUSH_FIRE_NUM = 5;	--最大的灭火数量

GRASS_ITEM = {20,1,875,1};	--草药

MAX_CURE_NUM = 5;	--最大的救治数量

TASK_MAIN_ID =  "1E0";
TASK_SUB_ID  =  "2AB";

TASK_NEXT_SUB_ID = "2AC";	--这个任务完成后接取下一个任务

VILLAGE_MAP = {2115,2116,2117,2118,2119,2120,2121};

tbTaskSubId = {34,35,36,37,38,39,40,41,42,43,44,45,48,49};

STATIC_MAP_ID = 
{
	2131,
	2132,
	2133,
	2134,
	2135,
	2136,
	2137,
};


REFRESH_NPC_DELAY = 5;		--静态地图刷npc的间隔

--------------------other-----------------
tbBlueEnemy = 	--精英怪和首领怪
{
	{9705,{49088/32,99776/32}},
};

tbNormalEnemy = 
{
	{
		9705,
		{49056/32,99520/32},
		{48928/32,99552/32},
		{48896/32,99776/32},
		{49024/32,99968/32},
		{49216/32,99968/32},
		{49248/32,99712/32},
		{49184/32,99616/32},	
	},		
};

tbXizuo = --细作
{
	{9719,{50272/32,97536/32}},
};

tbOpenNormalBoss = --开启五行怪的的柱子
{
	[9732] ={{51264/32,97728/32},{51968/32,97120/32},{53792/32,98720/32},{53216/32,99552/32},{53344/32,97440/32}},
};

tbNormalBossPos = --五行怪的pos
{
	[9710] = {51488/32,97728/32},
	[9711] = {52160/32,97120/32},
	[9713] = {53600/32,98656/32},
	[9714] = {53088/32,99392/32},
	[9712] = {53152/32,97472/32},
}

tbNormalBossTaskSub = 
{
	[1] = 41,[2] = 42,[3] = 44,[4] = 45,[5] = 43,
};

tbNormalBoss = --五行怪
{
	9710,9711,9713,9714,9712,	
};

tbFinalEnemy =
{
	{9705,
	 {1632,3072},
	 {1630,3067},
	 {1625,3075},
	 {1632,3062},
	 {1646,3068},
	 {1633,3081},
	 {1633,3074},
	 {1640,3086},
	 {1642,3078},
	 {1640,3075},
	 {1649,3075},
 	},
};

tbFinalBoss = --最终boss
{
	{9715,{52416/32,98272/32}},
};


tbSeriesRelation = --五行关系
{
	[1] = 2,
	[2] = 5,
	[3] = 4,
	[4] = 1,
	[5] = 3,	
};

tbSeriesName = 
{
	"金","木","水","火","土",	
};

preEnv.setfenv(1,preEnv)

local tbFileName = 
{
	[9709] = "\\setting\\task\\primer\\grass.txt",
	[9707] = "\\setting\\task\\primer\\fire.txt",
};

local function LoadPos()
	if not PrimerLv10.tbPasserby then
		PrimerLv10.tbPasserby = {};
	end
	local tbPasserby = PrimerLv10.tbPasserby;
	tbPasserby[9704] =  {{51040/32,100544/32}};	                                                                                         
	tbPasserby[9708] = 	{{51104/32,102240/32},{51232/32,102048/32},{51360/32,102176/32},{51424/32,101856/32},{51552/32,101984/32}};
	tbPasserby[9706] = 	{{49824/32,97824/32}}                                                                                         
	tbPasserby[9709] =  {};
	tbPasserby[9707] =  {};
	for nTemplateId,tbInfo in pairs(tbPasserby) do
		if #tbInfo == 0 then
			local szFile = tbFileName[nTemplateId];
			local tbFile = Lib:LoadTabFile(szFile);
			for _,tbPos in pairs(tbFile) do
				local tbTemp = {tonumber(tbPos.TRAPX)/32,tonumber(tbPos.TRAPY)/32};
				table.insert(tbPasserby[nTemplateId],tbTemp);
			end
		end
	end
end

if MODULE_GAMESERVER then
	LoadPos();
end




