-- 文件名　：newplayergiftex.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-10-31 14:34:25
-- 功能    ：

SpecialEvent.NewPlayerGiftEx = SpecialEvent.NewPlayerGiftEx or {};
local NewPlayerGiftEx = SpecialEvent.NewPlayerGiftEx;
NewPlayerGiftEx.IS_OPEN = 0;

--task
NewPlayerGiftEx.TASK_GROUP_ID = 2122;
NewPlayerGiftEx.TASK_CURRENT_INDEX = 21;
NewPlayerGiftEx.TASK_GET_BAG = 22;

NewPlayerGiftEx.tbData = {
	[1] = {10,
		{"CustomEquip", 25},
		{"CustomEquip", 26},
		{"CustomEquip", 27},
		{"CustomEquip", 28},
		{"CustomEquip", 20},
		{"BindMoney", 50000},
		{"Title", {6,92,1,9}, "龙门飞剑新兵"}, --or {"Title", nil, "一骑当千", 3*24*3600, "yellow"}
		},
	[2] = {15,
		{"CustomEquip", 29},
		{"CustomEquip", 23},
		{"CustomEquip", 21},
		{"CustomEquip", 30},
		{{{18,1,1525,1},{18,1,1525,1}}, 1},
		},
	[3] = {20,-- 所需等级
		{"CustomEquip", 1},
		{"CustomEquip", 2},
		{"CustomEquip", 85},
		{"CustomEquip", 86},
		{{{21,5,1,1},{21,5,1,1}},1},	--第一个为男，第二个为女
		{"BindMoney", 70000},
		{{{1,26,11,1},{1,26,26,1}}, 1, nil, 43200},
		{{{1,25,7,1},{1,25,29,1}}, 1, nil, 43200},
		},
	[4] = {25,
		{"CustomEquip", 4},
		{"CustomEquip", 3},
		{"CustomEquip", 87},
		{"CustomEquip", 88},
		{"CustomEquip", 89},
		{{{18,1,1525,2},{18,1,1525,2}}, 1},
		},
	[5] = {30,
		{"CustomEquip", 81},
		{"BindCoin", 1000},
		{{{18,1,71,2},{18,1,71,2}}, 1},
		{{{18,1,1525,3},{18,1,1525,3}}, 1},
		{{{18,1,195,1},{18,1,195,1}},1,nil, 10080},
		},
	[6] = {40,
		{"BindMoney", 120000},
		{{{18,1,114,5},{18,1,114,5}},3},
		{{{18,1,392,1},{18,1,392,1}},2},
		{{{18,1,1525,4},{18,1,1525,4}}, 1},
		},
	[7] = {50,
		{"CustomEquip", 82},
		{"BindCoin", 1500},
		{{{18,1,114,7},{18,1,114,7}},1},
		{{{18,1,394,1},{18,1,394,1}},3},
		{{{18,1,212,1},{18,1,212,1}},1},
		{{{18,1,85,1},{18,1,85,1}},1},
		{{{18,1,1525,5},{18,1,1525,5}}, 1},
		},
	[8] = {60,
		{"CustomEquip", 40},
		{{{18,1,394,1},{18,1,394,1}},4},
		{{{18,1,212,1},{18,1,212,1}},2},
		{{{18,1,2,3},{18,1,2,3}},1},
		},
	[9] = {70,
		{"CustomEquip", 90},
		{"CustomEquip", 83},
		{"BindCoin", 2000},
		{{{18,1,394,1},{18,1,394,1}},5},
		{{{18,1,113,1},{18,1,113,1}},1},
		},
	[10] = {80,
		{"CustomEquip", 60},
		{{{18,1,114,7},{18,1,114,7}},2},
		{{{18,1,394,1},{18,1,394,1}},6},
		{{{18,1,1497,1},{18,1,1497,1}},1},
		{{{1,13,12,1},{1,13,32,1}},1},
		},
	[11] = {90,
		{"CustomEquip", 84},
		{{{18,1,395,1},{18,1,395,1}},2},
		{{{18,1,212,1},{18,1,212,1}},3},
		{{{18,1,1498,1},{18,1,1498,1}},1},
		},
};

NewPlayerGiftEx.tbNeededSpace = {};
NewPlayerGiftEx.tbLevel = {};
NewPlayerGiftEx.tbAward = {}
NewPlayerGiftEx.tbBindMoney = {};

function NewPlayerGiftEx:Init()
	for i, tb in ipairs(self.tbData) do
		local tbItems = {};
		local nNeededBagSpace = 0;
		local nBindMoney = 0;
		for _, v in ipairs(tb) do
			if type(v)=="table" then
				table.insert(tbItems, v);
				if type(v[1]) == "table" then
					nNeededBagSpace = nNeededBagSpace + v[2];
				elseif v[1] == "CustomEquip" then
					nNeededBagSpace = nNeededBagSpace + 1;
				elseif v[1] == "BindMoney" then
					nBindMoney = nBindMoney + v[2];
				end
			end
		end		
		self.tbLevel[i] = tb[1];
		self.tbNeededSpace[i] = nNeededBagSpace;
		self.tbAward[i] = tbItems;
		self.tbBindMoney[i] = nBindMoney;
	end
end

function NewPlayerGiftEx:GetCurrData(pPlayer)
	local nIndex =  pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_CURRENT_INDEX);
	if nIndex >= #self.tbData + 1 then
		return nil;
	end
	
	if nIndex == 0 then
		nIndex = 1;
		pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_CURRENT_INDEX, 1);
	end
	return self.tbLevel[nIndex], self.tbNeededSpace[nIndex], self.tbAward[nIndex], self.tbBindMoney[nIndex];
end

function NewPlayerGiftEx:CanGetAward(pPlayer)
	if me.nFaction <= 0 or me.nRouteId <= 0 then
		return 0, "请加入门派并选定路线。";
	end
	local nLevel, nNeededSpace, tbItems, nBindMoney = self:GetCurrData(pPlayer);
	if not nLevel then
		return 0, "你已经领到这个礼包里面的所有礼物啦！";
	end
	
	if me.nLevel < nLevel then
		return 0, string.format("你需要达到%d级才能再领礼物。", nLevel);
	end
	
	if me.CountFreeBagCell() < nNeededSpace then
		return 0, string.format("Hành trang không đủ chỗ trống，请空出%d格之后再开启", nNeededSpace);
	end
	--特殊做法
	if me.GetBindMoney() + nBindMoney > me.GetMaxCarryMoney() then
		return 0, "你的绑定银两携带达上限了，无法获得绑定银两。";
	end
	return 1;
end

function NewPlayerGiftEx:GetAward(pPlayer, pItem)
	local nRes, szMsg = self:CanGetAward(pPlayer);
	if nRes == 0 then
		return 0, szMsg;
	end
	
	local nLevel, nNeededSpace, tbItems = self:GetCurrData(pPlayer);
	local tbAddedItem = {};
	local szAward = "";
	for _, tbItem in ipairs(tbItems) do
		if tbItem[1] == "BindCoin" then
			pPlayer.AddBindCoin(tbItem[2], Player.emKBINDCOIN_ADD_EVENT);
			szAward = szAward .. "绑定".. IVER_g_szCoinName .. tbItem[2] .. ",";
		elseif tbItem[1] == "BindMoney" then
			pPlayer.AddBindMoney(tbItem[2], Player.emKBINDMONEY_ADD_EVENT);
			szAward = szAward .. "绑银" .. tbItem[2] .. ",";
		elseif tbItem[1] == "CustomEquip" then
			local tbItem = SpecialEvent.ActiveGift:GetCustomItem(pPlayer, tbItem[2]);
			if tbItem then
				local pItem = pPlayer.AddItem(unpack(tbItem));
				if pItem then
					pItem.Bind(1);
					szAward = szAward .. pItem.szName .. ",";
				end
			end
		elseif tbItem[1] == "Title" then
			if type(tbItem[2]) == "table" then
				pPlayer.AddTitle(unpack(tbItem[2]));
				pPlayer.SetCurTitle(unpack(tbItem[2]));
			else
				me.AddSpeTitle(tbItem[3], tbItem[4], tbItem[5]);
			end
		else
			local nSex = pPlayer.nSex;
			for i = 1, tbItem[2] do
				local pItem = pPlayer.AddItem(unpack(tbItem[1][nSex + 1]));
				if pItem then
					if tbItem[3] then
						--pItem.SetGenInfo(1, tbItem[3]);
						--pItem.Sync();
					end
					if tbItem[4] and tbItem[4] ~= 0 then
						pPlayer.SetItemTimeout(pItem, tbItem[4], 0)
					end
					pItem.Bind(1);
					szAward = szAward .. pItem.szName .. ",";
				end
			end
		end
	end
	
	Dbg:WriteLog("SpecialEvent.NewPlayerGiftEx", string.format("%s 获得新手礼包%d级物品：%s", me.szName, nLevel, szAward));
	local nIndex =  pPlayer.GetTask(self.TASK_GROUP_ID, self.TASK_CURRENT_INDEX);
	nIndex = nIndex + 1;
	pPlayer.SetTask(self.TASK_GROUP_ID, self.TASK_CURRENT_INDEX, nIndex);
	if pItem then
		if self.tbLevel[nIndex] then
			pItem.SetGenInfo(1, self.tbLevel[nIndex]);
			pItem.Sync();
		end
		if nIndex >= #self.tbData + 1 then
			pItem.Delete(pPlayer);
			pPlayer.Msg("恭喜你已经领到这个礼包里面的所有礼物！");
		end
	end
	return 1;
end

function NewPlayerGiftEx:GetAwardLibao(nItemId)
	if self.IS_OPEN ~= 1 then
		return 0;
	end
	if not nItemId then
		return;
	end
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return ;
	end
	local nRes, szMsg = self:GetAward(me, pItem);
	if szMsg then
		me.Msg(szMsg);
	end
end

function NewPlayerGiftEx:OnDialog()
--	local nRes, szMsg = self:GiveGift();
--	if szMsg then
--		Dialog:Say(szMsg);
--	end
end

function NewPlayerGiftEx:GiveGift()
	if self.IS_OPEN ~= 1 then
		return 0;
	end
	
	if me.GetTask(self.TASK_GROUP_ID, self.TASK_GET_BAG) == 1 then
		return 0, "您已经获得过新手礼包了。";
	end
	
	if me.CountFreeBagCell() < 1 then
		return 0, "Hành trang không đủ chỗ trống，请空出一格之后再来"
	end
	
	local pItem = me.AddItem(18, 1, 1509, 1);
	if pItem then
		me.SetTask(self.TASK_GROUP_ID, self.TASK_CURRENT_INDEX, 1);
		me.SetTask(self.TASK_GROUP_ID, self.TASK_GET_BAG, 1);
		pItem.SetGenInfo(1, self.tbLevel[1]);
		pItem.Sync();
		Dbg:WriteLog("SpecialEvent.NewPlayerGiftEx", string.format("%s 获得新手礼包", me.szName));
	end
	
	return 1;
end

NewPlayerGiftEx:Init()

-------------------------------------------------------
-- c2s call
-------------------------------------------------------
-- 新手礼包
function c2s:GetNewPlayerGift(nItemId)
	do return; end;
	if GLOBAL_AGENT then
		return 0;
	end
	-- SpecialEvent.NewPlayerGiftEx:GetAwardLibao(nItemId)
end

-------------------------------------------------------------------------------------------
--item

local tbGift = Item:GetClass("NewPlayerGiftEx");

function tbGift:OnUse()
	local nItemLevel, nNeededSpace, tbItems = NewPlayerGiftEx:GetCurrData(me);
	if (not nItemLevel) then
		Dialog:Say("已经没有礼物可以领取！");
		return 0;
	end
	me.CallClientScript({"SpecialEvent.NewPlayerGiftEx:OpenWindow", it.dwId, nItemLevel, tbItems});
end
