-- 文件名　：guozi_summer.lua
-- 创建者　：sunduoliang
-- 创建时间：2009-07-09 09:12:56
-- 描  述  ：

local tbItem = Item:GetClass("guozi_summer")
tbItem.tbBoss = {
	{"<color=gold>金系武林高手声望<color>",100 , 1},
	{"<color=green>木系武林高手声望<color>",100, 2},
	{"<color=blue>水系武林高手声望<color>",100, 3},
	{"<color=red>火系武林高手声望<color>",100, 4},
	{"<color=wheat>土系武林高手声望<color>",100, 5},
};

function tbItem:OnUse()
	local szMsg = "打开该物品你可以选择以下两种物品的其中一种，<color=yellow>两者只能选其一<color>。\n\n1.<color=yellow>100点武林高手声望<color>（达到一定点数可购买95级Boss武器）\n2.<color=yellow>一块和氏玉<color>（和氏璧原材料，秦陵黄金武器声望材料，需本服开启了秦陵后才能兑换本项）";
	local tbOpt = {
		{"100点武林高手声望",self.GetItem1, self, it.dwId},
		{"一块和氏玉",self.GetItem2, self, it.dwId},
		{"Để ta suy nghĩ lại"},
	};
	local nType, nTime = it.GetTimeOut();
	if nType and nType >= 0 and nTime and nTime > 0 then
		table.insert(tbOpt, 3, {"换取无时限盛夏果实", self.ChangeItem, self, it.dwId});
	end
	
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:ChangeItem(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	if me.DelItem(pItem) ~= 1 then
		return;
	end
	local pItem1 = me.AddItem(18,1,380,1);
	if pItem1 then
		pItem1.Bind(1);
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("使用盛夏果实换取无时限盛夏果实"));
	end
end

function tbItem:GetItem1(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local szMsg = "你可以换取100点武林高手声望，请选择你想换取哪种五行的武林高手声望？";
	local tbOpt = {};
	for _, tbBoss in ipairs(self.tbBoss) do
		table.insert(tbOpt, {tbBoss[1], self.GetItem1_1, self, nItemId, tbBoss[2], tbBoss[3]});
	end
	table.insert(tbOpt, {"Để ta suy nghĩ lại"});
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:GetItem1_1(nItemId, nScore, nSeries)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	if me.IsHaveItemInBags(pItem) ~= 1 then
		return;
	end
	local nFlag = Player:AddRepute(me, 6, nSeries, nScore);
	if (0 == nFlag) then
		return;
	elseif (1 == nFlag) then
		me.Msg("您已经达到挑战武林高手声望（" .. Env.SERIES_NAME[nSeries] .. "）最高等级，将无法使用挑战武林高手声望（" .. Env.SERIES_NAME[nSeries] .. "）令牌");
		return;
	end	
	me.DelItem(pItem);
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("使用盛夏果实换取武林高手声望(%s)",Env.SERIES_NAME[nSeries]));
	if me.nSeries ~= nSeries then
		me.Msg("<color=yellow>您使用的令牌五行与您的角色五行不同，请小心使用。")
	end	
end

function tbItem:GetItem2(nItemId)
	if TimeFrame:GetState("OpenBoss120") ~= 1 then
		Dialog:Say("秦始皇陵还未开启，现在不能兑换该材料，请选择兑换武林高手声望吧。");
		return 0;
	end
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	if me.IsHaveItemInBags(pItem) ~= 1 then
		return;
	end
	if me.DelItem(pItem) ~= 1 then
		return;
	end
	local pItem = me.AddItem(22,1,81,1);
	if pItem then
		--pItem.Bind(1);
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_JOINSPORT, string.format("使用盛夏果实换取和氏玉一个"));
	end
	me.Msg("成功换取了一块<color=yellow>和氏玉<color>");
end
