-- 防具宝箱
-- zhouchenfei
-- 2010-10-19 14:33:38

local tbItem = Item:GetClass("fangjubox");

tbItem.tbItemList = {
	[1] = { -- 衣服
		[0] = {
				[Env.SERIES_METAL]	= {
						{ "棍少林、天王", {2,3,612,10} },
						{ "刀少林", {2,3,632,10} },
					},
				[Env.SERIES_WOOD]	= {
						{ "刀毒、唐门、明教", {2,3,652,10} },
						{ "掌五毒", {2,3,672,10} },
					},
				[Env.SERIES_WATER]	= {
						{ "指段", {2,3,692,10} },
						{ "翠烟、气段", {2,3,712,10} },
					},
				[Env.SERIES_FIRE]	= {
						{ "战忍", {2,3,732,10} },
						{ "魔忍、丐帮", {2,3,752,10} },
					},
				[Env.SERIES_EARTH]	= {
						{ "剑武", {2,3,772,10} },
						{ "气武、昆仑", {2,3,792,10} },
					},
			},
		[1]	= {
				[Env.SERIES_METAL]	= {
						{ "天王", {2,3,622,10} },
					},
				[Env.SERIES_WOOD]	= {
						{ "刀毒、唐门、明教", {2,3,662,10} },
						{ "掌五毒", {2,3,682,10} },
					},
				[Env.SERIES_WATER]	= {
						{ "指段", {2,3,702,10} },
						{ "峨眉、翠烟、气段", {2,3,722,10} },
					},
				[Env.SERIES_FIRE]	= {
						{ "战忍", {2,3,742,10} },
						{ "魔忍、丐帮", {2,3,762,10} },
					},
				[Env.SERIES_EARTH]	= {
						{ "剑武", {2,3,782,10} },
						{ "气武、昆仑", {2,3,802,10} },
					},
			},		
		},
	[2] = { -- 帽子
		[0] = {
				[Env.SERIES_METAL]	= {
						{ "棍少林、天王", {2,9,610,10} },
						{ "刀少林", {2,9,630,10} },
					},
				[Env.SERIES_WOOD]	= {
						{ "刀毒、唐门、明教", {2,9,650,10} },
						{ "掌五毒", {2,9,670,10} },
					},
				[Env.SERIES_WATER]	= {
						{ "指段", {2,9,690,10} },
						{ "翠烟、气段", {2,9,710,10} },
					},
				[Env.SERIES_FIRE]	= {
						{ "战忍", {2,9,730,10} },
						{ "魔忍、丐帮", {2,9,750,10} },
					},
				[Env.SERIES_EARTH]	= {
						{ "剑武", {2,9,770,10} },
						{ "气武、昆仑", {2,9,790,10} },
					},
			},
		[1]	= {
				[Env.SERIES_METAL]	= {
						{ "天王", {2,9,620,10} },
					},
				[Env.SERIES_WOOD]	= {
						{ "刀毒、唐门、明教", {2,9,660,10} },
						{ "掌五毒", {2,9,680,10} },
					},
				[Env.SERIES_WATER]	= {
						{ "指段", {2,9,700,10} },
						{ "峨眉、翠烟、气段", {2,9,720,10} },
					},
				[Env.SERIES_FIRE]	= {
						{ "战忍", {2,9,740,10} },
						{ "魔忍、丐帮", {2,9,760,10} },
					},
				[Env.SERIES_EARTH]	= {
						{ "剑武", {2,9,780,10} },
						{ "气武、昆仑", {2,9,800,10} },
					},
			},		
		},
	[3] = { -- 腰带
		[0] = {
				[Env.SERIES_METAL]	= {
						{ "金系" , {2,8,310,10} },
					},
				[Env.SERIES_WOOD]	= {
						{ "木系" , {2,8,330,10} },
					},
				[Env.SERIES_WATER]	= {
						{ "水系" , {2,8,350,10} },
					},
				[Env.SERIES_FIRE]	= {
						{ "火系" , {2,8,370,10} },
					},
				[Env.SERIES_EARTH]	= {
						{ "土系" , {2,8,390,10} },
					},
			},
		[1]	= {
				[Env.SERIES_METAL]	= {
						{ "金系" , {2,8,320,10} },
					},
				[Env.SERIES_WOOD]	= {
						{ "木系" , {2,8,340,10} },
					},
				[Env.SERIES_WATER]	= {
						{ "水系" , {2,8,360,10} },
					},
				[Env.SERIES_FIRE]	= {
						{ "火系" , {2,8,380,10} },
					},
				[Env.SERIES_EARTH]	= {
						{ "土系" , {2,8,400,10} },
					},
			},		
		},
	[4] = { -- 护腕
		[0] = {
				[Env.SERIES_METAL]	= {
						{ "金系" , {2,10,312,10} },
					},
				[Env.SERIES_WOOD]	= {
						{ "木系" , {2,10,332,10} },
					},
				[Env.SERIES_WATER]	= {
						{ "水系" , {2,10,352,10} },
					},
				[Env.SERIES_FIRE]	= {
						{ "火系" , {2,10,372,10} },
					},
				[Env.SERIES_EARTH]	= {
						{ "土系" , {2,10,392,10} },
					},
			},
		[1]	= {
				[Env.SERIES_METAL]	= {
						{ "金系" , {2,10,322,10} },
					},
				[Env.SERIES_WOOD]	= {
						{ "木系" , {2,10,342,10} },
					},
				[Env.SERIES_WATER]	= {
						{ "水系" , {2,10,362,10} },
					},
				[Env.SERIES_FIRE]	= {
						{ "火系" , {2,10,382,10} },
					},
				[Env.SERIES_EARTH]	= {
						{ "土系" , {2,10,402,10} },
					},
			},		
		},
	[5] = { -- 鞋子
		[0] = {
				[Env.SERIES_METAL]	= {
						{ "金系" , {2,7,312,10} },
					},
				[Env.SERIES_WOOD]	= {
						{ "木系" , {2,7,332,10} },
					},
				[Env.SERIES_WATER]	= {
						{ "水系" , {2,7,352,10} },
					},
				[Env.SERIES_FIRE]	= {
						{ "火系" , {2,7,372,10} },
					},
				[Env.SERIES_EARTH]	= {
						{ "土系" , {2,7,392,10} },
					},
			},
		[1]	= {
				[Env.SERIES_METAL]	= {
						{ "金系" , {2,7,322,10} },
					},
				[Env.SERIES_WOOD]	= {
						{ "木系" , {2,7,342,10} },
					},
				[Env.SERIES_WATER]	= {
						{ "水系" , {2,7,362,10} },
					},
				[Env.SERIES_FIRE]	= {
						{ "火系" , {2,7,382,10} },
					},
				[Env.SERIES_EARTH]	= {
						{ "土系" , {2,7,402,10} },
					},
			},
		},
};

function tbItem:OnUse()
	local nType = tonumber(it.GetExtParam(1)) or 0;
	local tbItemList = self.tbItemList[nType];
	if (not tbItemList) then
		Dialog:Say("您的物品有问题！");
		return 0;
	end
	
	local tbSeriesItem = tbItemList[me.nSex];
	
	if (not tbSeriesItem) then
		Dialog:Say("没有性别不可能吧！");
		return 0;
	end	

	local szMsg = string.format("通过%s你将获得下列物品中的一种，请选择：", it.szName);
	local tbOpt = {};
	
	for nIndex, tbInfo in pairs(tbSeriesItem) do
		for nIdx, tbDetail in pairs (tbInfo) do
			local szDetail = string.format("<color=yellow>%s（%s）<color>", KItem.GetNameById(unpack(tbDetail[2])), tbDetail[1]);
			table.insert(tbOpt, {szDetail, self.OnSureGetYaodai, self, nType, nIndex, nIdx, it.dwId});
		end
	end
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:OnSureGetYaodai(nType, nIndex, nIdx, nItemId, nFlag)
	local nSex = me.nSex;
	local tbItemList = self.tbItemList[nType];
	if (not tbItemList) then
		Dialog:Say("您的物品有问题！");
		return 0;
	end
	
	local tbSeriesItem = tbItemList[me.nSex];
	
	if (not tbSeriesItem) then
		Dialog:Say("没有性别不可能吧！");
		return;
	end

	if me.CountFreeBagCell() < 1 then
		Dialog:Say((string.format("你的背包不足，需要%s格背包空间。", 1)));
		return 0;
	end

	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	
	local tbInfo = tbSeriesItem[nIndex];
	local tbDetail = tbInfo[nIdx];
	
	local szItemName = KItem.GetNameById(unpack(tbDetail[2]));
	if (not nFlag or nFlag ~= 1) then
		Dialog:Say(string.format("您选择获取<color=yellow>%s（%s）<color>，确定吗？", szItemName, tbDetail[1]), 
			{
				{"Xác nhận", self.OnSureGetYaodai, self, nType, nIndex, nIdx, nItemId, 1},
				{"Để ta suy nghĩ thêm"},	
			});
		return;
	end
	
	local pIt = me.AddItem(unpack(tbDetail[2]));
	if (not pIt) then
		Dbg:WriteLog("Item", "FangJuBox", me.szName, szItemName, "Get Failed!!!!!!!!!!!!!");
	end
	pIt.Bind(1);
	pItem.Delete(me);
end
