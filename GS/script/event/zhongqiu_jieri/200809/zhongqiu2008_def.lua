--中秋节
--2008.09.01
--孙多良

local tbEvent = {};
SpecialEvent.ZhongQiu2008 = tbEvent;

tbEvent.TIME_STATE = 
{
	20080909,
	20080916,
	20081011,
}

--材料
tbEvent.ITEM_MERIAL = {
	{22,1,31,1}, --月桂花
	{22,1,33,1}, --莲子粉
}

tbEvent.AWARD_WEIWANG = {{100,2},{30,1}};	--威望对应奖励{达到威望，个数}

tbEvent.TASK_GROUP_ID = 2046;
tbEvent.TASK_WEIWANG_AWARD = 1;	--江湖声望领取奖励。
tbEvent.TASK_USE_MOON = 2;	--使用月满西楼月饼数量

tbEvent.USEITEM_MAX_MOON = 25;	--使用月满西楼数量最大上限

tbEvent.RECIPEID_MERIAL1 = 1346;	--月桂配方
tbEvent.RECIPEID_MERIAL2 = 1347;	--莲子配方
tbEvent.RECIPEID_MOONCAKE = 1348;	--月饼配方

tbEvent.PRODUCTSET = 
{
	{
		tbItem = {18,1,197,1,0,0};
		nRate  = 99;
	},
	{
		tbItem = {18,1,198,1,0,0};
		nRate  = 1;
	},
}

tbEvent.PRODUCTSET_INKIN = 
{
	{
		tbItem = {18,1,197,1,0,0};
		nRate  = 95;
	},
	{
		tbItem = {18,1,198,1,0,0};
		nRate  = 5;
	},
}


tbEvent.NEWS_INFO = 
{
	{
		nKey = 15,
		szTitle = "中秋活动",
		szMsg = [[
活动时间：<color=yellow>9月9日 0:00 — 9月16日 0:00<color>
    
活动内容：
    活动期间，可以通过参加各种活动获得月饼材料，利用生活技能药材加工和药剂合成里的中秋配方：月桂花糖，莲子冰皮，中秋月饼，可以制作出月饼。
    
    可以获得中秋材料的途径：
    白虎堂，宋金战场，门派竞技，猜灯谜，官府通缉任务
    另外，江湖威望达到30以上，每天可以在盛夏活动推广员处领取一份材料；达到100以上，可以每天领取2份

    <color=yellow>注意：在进行家族旗帜活动时制作月饼，获得彩云追月的机率会大大提高<color>
]],
	},
}