Player.tbItemSort = Player.tbItemSort or {};
Player.tbItemSort.tbContainerTable = -- 待整理容器组合
{
	[1] = {Item.ROOM_MAINBAG, Item.ROOM_EXTBAG1, Item.ROOM_EXTBAG2, Item.ROOM_EXTBAG3},
	--[2] = {Item.ROOM_REPOSITORY, Item.ROOM_EXTREP1, Item.ROOM_EXTREP2, Item.ROOM_EXTBAG3, ROOM_EXTREP4, ROOM_EXTREP5},
};
Player.tbItemSort.tbRemainCells =	-- 预留不整理的格子数
{
	[1] = 0,
	[2] = 5,
	[3] = 10,	
};
Player.tbItemSort.nCollateInterval = 10;	-- 十秒的间隔
Player.tbItemSort.tbCollateTime = Player.tbItemSort.tbCollateTime or {};
-- nContainerType:1是背包，2是仓库（与tbContainerTable对应） nRemainCells:预留的格子数，默认0
function Player:ItemSortOnSort(nContainerType, nRemainCellsType)
	if Player.tbItemSort.tbCollateTime[me.nId] then
		if Player.tbItemSort.tbCollateTime[me.nId] + Player.tbItemSort.nCollateInterval > GetTime() then
			return -1;
		end
	end
	Player.tbItemSort.tbCollateTime[me.nId] = GetTime();
	nContainerType = nContainerType or 1;
	if nContainerType < 1 or nContainerType > #Player.tbItemSort.tbContainerTable then
		return -1;
	end
	nRemainCellsType = nRemainCellsType or 1;
	if nRemainCellsType < 1 or nRemainCellsType > #Player.tbItemSort.tbRemainCells then
		return -1;
	end
	local tbCells = Player:ItemSortGetAllCells(nContainerType);
	for i = 1, Player.tbItemSort.tbRemainCells[nRemainCellsType] do
		table.remove(tbCells, #tbCells);
	end
	-- 先处理合并
	for i = 1, #tbCells do
		local pItem1 = me.GetItem(tbCells[i].nContainerId, tbCells[i].nRow, tbCells[i].nColumn);
		for j = i + 1, #tbCells do
			local pItem2 = me.GetItem(tbCells[j].nContainerId, tbCells[j].nRow, tbCells[j].nColumn);
			if (pItem1 and pItem2) and (pItem1.nGenre == pItem2.nGenre) and (pItem1.nDetail == pItem2.nDetail)
			and (pItem1.nParticular == pItem2.nParticular) and (pItem1.nLevel == pItem2.nLevel) then
				local _, nTimeOut1 = pItem1.GetTimeOut();
				local _, nTimeOut2 = pItem2.GetTimeOut();
				if (pItem1.IsStackable() == 1 and nTimeOut1 == 0) and (pItem2.IsStackable() == 1 and nTimeOut2 == 0) then
					if (pItem1.IsBind() == pItem2.IsBind()) then
						local nRet = me.SwitchItem(tbCells[j].nContainerId, tbCells[j].nRow, tbCells[j].nColumn,
							tbCells[i].nContainerId, tbCells[i].nRow, tbCells[i].nColumn);
						pItem1 = me.GetItem(tbCells[i].nContainerId, tbCells[i].nRow, tbCells[i].nColumn);
					end
				end
			end
		end
	end
	--再处理排序
	for i = 1, #tbCells do
		local pItem1 = me.GetItem(tbCells[i].nContainerId, tbCells[i].nRow, tbCells[i].nColumn);
		local tbItemMVI = {pItemMVI = pItem1, nNum = i};
		for j = i + 1, #tbCells do
			local pItem2 = me.GetItem(tbCells[j].nContainerId, tbCells[j].nRow, tbCells[j].nColumn);
			--记录当前item后面优先级最大的item及其所在位置			
			if (Player:ItemSortCompare(tbItemMVI.pItemMVI, pItem2, self.tbSortRule) == -1)	then
				tbItemMVI.pItemMVI = pItem2;
				tbItemMVI.nNum = j;
			end
		end
		--如果当前item的优先级不是最大，与最大优先级交换
		if (tbItemMVI.nNum ~= i) then
			local nRet = me.SwitchItem(tbCells[i].nContainerId, tbCells[i].nRow, tbCells[i].nColumn,
				tbCells[tbItemMVI.nNum].nContainerId, tbCells[tbItemMVI.nNum].nRow, tbCells[tbItemMVI.nNum].nColumn);
			if nRet ~= 1 then
				return 0;
			end
		end
	end
end

function Player:ItemSortGetContainers(nContainerType)
	local tbContainer = {};
	for k, nRoomId in ipairs(Player.tbItemSort.tbContainerTable[nContainerType]) do
		local nRow, nColumn = Player:ItemSortGetContainerSize(nRoomId);
		if nRow and nColumn then 
			table.insert(tbContainer, { nRoomId, nRow, nColumn });
		end
	end
	return tbContainer;
end

function Player:ItemSortGetAllCells(nContainerType)
	local tbAllCells = {};
	local tbContainers = Player:ItemSortGetContainers(nContainerType);
	for k, v in ipairs(tbContainers) do
		local nContainerId, nColumn, nRow = v[1], v[2], v[3];
		for c =0, nColumn - 1,1 do
			for r = 0, nRow - 1,1 do
				table.insert(tbAllCells, {nContainerId = nContainerId, nRow = r, nColumn = c});
			end
		end
	end
	return tbAllCells;
end

--获取当前容器最大行数和列数
function Player:ItemSortGetContainerSize(nContainerId)
	local tbFixedContainerTable = { Item.ROOM_MAINBAG, Item.ROOM_REPOSITORY, Item.ROOM_EXTREP1 }; --, Item.ROOM_EXTREP1, Item.ROOM_EXTREP2, Item.ROOM_EXTREP3, Item.ROOM_EXTREP4, Item.ROOM_EXTREP5 };
	local tbExtBag = {  Item.ROOM_EXTBAG1,  Item.ROOM_EXTBAG2, Item.ROOM_EXTBAG3 };
	local tbExtBagType	= { Item.EXTBAG_4CELL, Item.EXTBAG_6CELL, Item.EXTBAG_8CELL, Item.EXTBAG_10CELL, Item.EXTBAG_12CELL, Item.EXTBAG_15CELL, Item.EXTBAG_18CELL, Item.EXTBAG_20CELL, Item.EXTBAG_24CELL	};
	local tbExtBagSize	= { 
		{Item.EXTBAG_WIDTH_4CELL, Item.EXTBAG_HEIGHT_4CELL},
		{Item.EXTBAG_WIDTH_6CELL, Item.EXTBAG_HEIGHT_6CELL}, 
		{Item.EXTBAG_WIDTH_8CELL, Item.EXTBAG_HEIGHT_8CELL}, 
		{Item.EXTBAG_WIDTH_10CELL, Item.EXTBAG_HEIGHT_10CELL}, 
		{Item.EXTBAG_WIDTH_12CELL, Item.EXTBAG_HEIGHT_12CELL}, 
		{Item.EXTBAG_WIDTH_15CELL, Item.EXTBAG_HEIGHT_15CELL}, 
		{Item.EXTBAG_WIDTH_18CELL, Item.EXTBAG_HEIGHT_18CELL}, 
		{Item.EXTBAG_WIDTH_20CELL, Item.EXTBAG_HEIGHT_20CELL}, 
		{Item.EXTBAG_WIDTH_24CELL, Item.EXTBAG_HEIGHT_24CELL}};
	if Lib:TBFindKeyFromValue(tbFixedContainerTable, nContainerId) then
		return Item.ROOM_MAINBAG_HEIGHT, Item.ROOM_MAINBAG_WIDTH;
	elseif Lib:TBFindKeyFromValue(tbExtBag, nContainerId) then
		local nBarId = Item.ROOM_EXTBAGBAR;
		local nPos = nContainerId - Item.ROOM_EXTBAG1;		
		local pBagItemObj = me.GetItem(nBarId, nPos, 0);
		if not pBagItemObj then
			return nil;
		end
		local nType = pBagItemObj.nDetail;
		local k,v = Lib:TBFindKeyFromValue(tbExtBagType, nType);
		return tbExtBagSize[k][2], tbExtBagSize[k][1];
	end
	return nil;
end

function Player:ItemSortCompare(pItem1, pItem2, tbSortRule)
	if not pItem1 and pItem2 then
		return -1;
	end
	if pItem1 and not pItem2 then
		return 1;
	end
	if not pItem1 and not pItem2 then
		return 0;
	end
	local nRetVal = nil;
	for i, v in ipairs(tbSortRule) do
		local pFun = tbSortRule[i];
		nRetVal = pFun(self, pItem1, pItem2);
		if nRetVal ~= 0 then
			break;
		end
	end
	return nRetVal;
end

function Player:ItemSortCompareValue(var1, var2)
	if var1 < var2 then
		return 1;
	elseif var1 == var2 then
		return 0;
	else
		return -1;
	end
end

function Player:ItemSortCompareGenre(pItem1, pItem2)
	return Player:ItemSortCompareValue(pItem1.nGenre, pItem2.nGenre);
end

function Player:ItemSortCompareDetail(pItem1, pItem2)
	return Player:ItemSortCompareValue(pItem1.nDetail, pItem2.nDetail);
end

function Player:ItemSortCompareClassName(pItem1, pItem2)
	return Player:ItemSortCompareValue(pItem1.szClass, pItem2.szClass);
end

function Player:ItemSortCompareBindType(pItem1, pItem2)
	return Player:ItemSortCompareValue(pItem1.IsBind(), pItem2.IsBind());
end

function Player:ItemSortCompareLevel(pItem1, pItem2)
	return Player:ItemSortCompareValue(pItem1.nLevel, pItem2.nLevel);
end

function Player:ItemSortCompareName(pItem1, pItem2)
	return Player:ItemSortCompareValue(pItem1.szName, pItem2.szName);
end

function Player:ItemSortCompareCount(pItem1, pItem2)
	return Player:ItemSortCompareValue(pItem2.nCount, pItem1.nCount); -- 个数从多到少排
end

-- 排序规则，可以添加和调换顺序
Player.tbSortRule = Player.tbSortRule or {Player.ItemSortCompareGenre, Player.ItemSortCompareDetail, Player.ItemSortCompareClassName, Player.ItemSortCompareBindType, Player.ItemSortCompareLevel,Player.ItemSortCompareName, Player.ItemSortCompareCount};
