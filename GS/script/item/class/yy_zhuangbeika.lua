----yy_zhuangbeika.lua
----作者：孙多良
----2012-04-07
----info：

local tbItem = Item:GetClass("yy_zhuangbeika");
tbItem.tbEquip = {
	--白银
	[1] = {
		--男性
		[0] = {
			["帽子"] =
			{
				{4,	9,	477,	10,	1},	--金
				{4,	9,	479,	10,	2},	--木
				{4,	9,	481,	10,	3},	--水
				{4,	9,	483,	10,	4},	--火
				{4,	9,	485,	10,	5},	--土
			},
			["腰带"] =
			{
				{2,	8,	651,	10,	1},	--金
				{2,	8,	652,	10,	2},	--木
				{2,	8,	653,	10,	3},	--水
				{2,	8,	654,	10,	4},	--火
				{2,	8,	655,	10,	5},	--土
			},
			["鞋子"] =
			{
				{2,	7,	503,	10,	1},	--金
				{2,	7,	505,	10,	2},	--木
				{2,	7,	507,	10,	3},	--水
				{2,	7,	509,	10,	4},	--火
				{2,	7,	511,	10,	5},	--土				
			},
			["护身符"] =
			{
				{2,	6,	252,	10,	1},	--金
				{2,	6,	253,	10,	2},	--木
				{2,	6,	254,	10,	3},	--水
				{2,	6,	255,	10,	4},	--火
				{2,	6,	256,	10,	5},	--土				
			},
		},

		--女性
		[1] = {
			["帽子"] =
			{
				{4,	9,	478,	10,	1},	--金
				{4,	9,	480,	10,	2},	--木
				{4,	9,	482,	10,	3},	--水
				{4,	9,	484,	10,	4},	--火
				{4,	9,	486,	10,	5},	--土
			},
			["腰带"] =
			{
				{2,	8,	656,	10,	1},	--金
				{2,	8,	657,	10,	2},	--木
				{2,	8,	658,	10,	3},	--水
				{2,	8,	659,	10,	4},	--火
				{2,	8,	660,	10,	5},	--土
			},
			["鞋子"] =
			{
				{2,	7,	504,	10,	1},	--金
				{2,	7,	506,	10,	2},	--木
				{2,	7,	508,	10,	3},	--水
				{2,	7,	510,	10,	4},	--火
				{2,	7,	512,	10,	5},	--土				
			},			
			["护身符"] =
			{
				{2,	6,	252,	10,	1},	--金
				{2,	6,	253,	10,	2},	--木
				{2,	6,	254,	10,	3},	--水
				{2,	6,	255,	10,	4},	--火
				{2,	6,	256,	10,	5},	--土				
			},			
		},
	},
	--黄金
	[2] = {
		--男性
		[0] = {
			["帽子"] =
			{
				{4,	9,	487,	10,	1},	--金
				{4,	9,	489,	10,	2},	--木
				{4,	9,	491,	10,	3},	--水
				{4,	9,	493,	10,	4},	--火
				{4,	9,	495,	10,	5},	--土
			},
			["腰带"] =
			{
				{2,	8,	661,	10,	1},	--金
				{2,	8,	662,	10,	2},	--木
				{2,	8,	663,	10,	3},	--水
				{2,	8,	664,	10,	4},	--火
				{2,	8,	665,	10,	5},	--土
			},
			["鞋子"] =
			{
				{2,	7,	513,	10,	1},	--金
				{2,	7,	515,	10,	2},	--木
				{2,	7,	517,	10,	3},	--水
				{2,	7,	519,	10,	4},	--火
				{2,	7,	521,	10,	5},	--土				
			},
			["护身符"] =
			{
				{2,	6,	257,	10,	1},	--金
				{2,	6,	258,	10,	2},	--木
				{2,	6,	259,	10,	3},	--水
				{2,	6,	260,	10,	4},	--火
				{2,	6,	261,	10,	5},	--土				
			},
		},

		--女性
		[1] = {
			["帽子"] =
			{
				{4,	9,	488,	10,	1},	--金
				{4,	9,	490,	10,	2},	--木
				{4,	9,	492,	10,	3},	--水
				{4,	9,	494,	10,	4},	--火
				{4,	9,	496,	10,	5},	--土
			},
			["腰带"] =
			{
				{2,	8,	666,	10,	1},	--金
				{2,	8,	667,	10,	2},	--木
				{2,	8,	668,	10,	3},	--水
				{2,	8,	669,	10,	4},	--火
				{2,	8,	670,	10,	5},	--土
			},
			["鞋子"] =
			{
				{2,	7,	514,	10,	1},	--金
				{2,	7,	516,	10,	2},	--木
				{2,	7,	518,	10,	3},	--水
				{2,	7,	520,	10,	4},	--火
				{2,	7,	522,	10,	5},	--土				
			},			
			["护身符"] =
			{
				{2,	6,	257,	10,	1},	--金
				{2,	6,	258,	10,	2},	--木
				{2,	6,	259,	10,	3},	--水
				{2,	6,	260,	10,	4},	--火
				{2,	6,	261,	10,	5},	--土					
			},			
		}
	}
}


function tbItem:OnUse()
	if not self.tbEquip[it.nLevel] or not self.tbEquip[it.nLevel][me.nSex]then
		return 0;
	end
	local tbList = self.tbEquip[it.nLevel][me.nSex];
	local tbName = {
		[1] = "白银",
		[2] = "黄金",
	} 
	local szMsg = "请选择你想要的装备";
	local tbOpt = {};
	for szName, tbList in pairs(tbList) do
		local szItemName = KItem.GetNameById(tbList[1][1],tbList[1][2], tbList[1][3],tbList[1][4]);
		local szSelName = string.format("[%s%s]%s",tbName[it.nLevel], szName, szItemName)
		table.insert(tbOpt, {szSelName, self.Select, self, it.dwId, szSelName, tbList});
	end
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	Dialog:Say(szMsg, tbOpt);
	return 0;
end

function tbItem:Select(nItemId, szName, tbList, nSeries)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return;
	end
	if not nSeries then
		local szMsg = "你选择了"..szName.."\n\n请选择装备适合的职业五行？\n\n<color=yellow>一旦选择将会使用掉卡片获得装备，请谨慎选择。<color>";
		local tbOpt = {};
		for ni, tbItem in ipairs(tbList) do
			local szSelName = string.format("适合%s系职业", Env.SERIES_NAME[tbItem[5]]);
			table.insert(tbOpt, {szSelName, self.Select, self, nItemId, szName, tbList, ni})
		end
		table.insert(tbOpt, {"Để ta suy nghĩ lại"});
		Dialog:Say(szMsg, tbOpt);	
		return;
	end
	if me.DelItem(pItem) ~= 1 then
		return;
	end
	local pItem = me.AddItem(tbList[nSeries][1], tbList[nSeries][2], tbList[nSeries][3], tbList[nSeries][4]);
	if pItem then
		pItem.Bind(1);
	else
		Dbg:Write("yy_zhuangbeika", me.szName, "AddFail");
	end
end

