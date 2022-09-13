------------------------------------------------------
-- 文件名　：datarecord.lua
-- 创建者　：dengyong
-- 创建时间：2010-06-22 14:29:13
-- 功能    ：数据埋点相关的记录
------------------------------------------------------

if not MODULE_GAMESERVER then
	return;
end

Item = Item or {};

Item.szRECORD_LIST = "\\setting\\misc\\datarecord.txt";
Item.szFILE_FORMAT = "\\log\\datarecord\\%s\\datarecord_%s.txt";
Item.tbRecordList = {};
Item.tbRecordBuff = {};
-- tbRecordBuff = 
-- {
--		[nWay] = 
--		{
--			[szKey] = {nBindCount, nUnBindCount, szName},
--		}
-- 		["Coin"] =
--		{
--			[nCoinType] = {nConsume = .., nAdd = ..,},
--		}
-- }

function Item:OnItemRemove(nCount, nWay)
	if (self:IsInRecordList(1) ~= 1) then
		return;
	end

	-- 记录数据
	self:InsertToMemoryCache(nCount, nWay);
end

function Item:OnItemAdd(nCount, nWay)
	if (self:IsInRecordList() ~= 1) then
		return;
	end
	
	-- 记录数据
	self:InsertToMemoryCache(nCount, nWay);
end

-- nCoinType ：1表示绑金，2表示银两，3表示绑银
-- nCount : 大于0表示增加，小于0表示减少
function Item:OnCoinChanged(nCoinType, nCount)
	Item.tbRecordBuff["Coin"] = Item.tbRecordBuff["Coin"] or {};
	Item.tbRecordBuff["Coin"][nCoinType] = Item.tbRecordBuff["Coin"][nCoinType] or {};
	Item.tbRecordBuff["Coin"][nCoinType].nConsume = Item.tbRecordBuff["Coin"][nCoinType].nConsume or 0;
	Item.tbRecordBuff["Coin"][nCoinType].nAdd = Item.tbRecordBuff["Coin"][nCoinType].nAdd or 0;
	
	if (nCount < 0) then
		Item.tbRecordBuff["Coin"][nCoinType].nConsume = Item.tbRecordBuff["Coin"][nCoinType].nConsume - nCount;
	else
		Item.tbRecordBuff["Coin"][nCoinType].nAdd = Item.tbRecordBuff["Coin"][nCoinType].nAdd + nCount;
	end	
end

-- 将内存中的数据写到日志中，并清除内存中的数据
function Item:WriteDataRecord()
	local szTime = os.date("%Y%m%d", GetTime());
	local szFileName = string.format(self.szFILE_FORMAT, szTime, szTime);
	
	local szRecord = "";
	for varWay, tbWay in pairs(self.tbRecordBuff) do
		for varKey, tbData in pairs(tbWay) do
			-- 钱币类型的记录
			if (type(varWay) == "string" and varWay == "Coin") then
				local szCoinType = (varKey == 1 and "绑金") or (varKey == 2 and "银两") or (varKey == 3 and "绑银");
				if (tbData.nAdd > 0) then
					szRecord = szRecord..string.format("数据埋点_产出：%s，nCount：%d\r\n", szCoinType, tbData.nAdd);
				end
				if (tbData.nConsume > 0) then
					szRecord = szRecord..string.format("数据埋点_消耗：%s，nCount：%d\r\n", szCoinType, tbData.nConsume);
				end
			else	-- 道具类型的记录
				local szType = "产出";
				if varWay > self.emITEM_DATARECORD_ROLLOUTADD then
					szType = "消耗";
				end
				
				-- 如果绑的和不绑的不需要分开记录，把两者加起来
				if (self.tbRecordList[varKey].bDiffBindType == 0) then
					local nCount = tbData.nBindCount + tbData.nUnBindCount;
					szRecord = szRecord..string.format("数据埋点_%s：%s(%s), nCount：%d, nWay：%d\r\n", szType, tbData.szName,
						varKey, nCount, varWay);
				else
					szRecord = szRecord..string.format("数据埋点_%s：%s(%s), nCount：%d, nWay：%d，bBind：0\r\n", szType, tbData.szName,
						varKey, tbData.nUnBindCount, varWay);
						
					szRecord = szRecord..string.format("数据埋点_%s：%s(%s), nCount：%d, nWay：%d，bBind：1\r\n", szType, tbData.szName,
						varKey, tbData.nBindCount, varWay);
				end
			end
		end
	end
	
	-- 如果已经创建了文件，追加写文件；否则写新文件
	if (not szRecord or szRecord == "") then
		return;
	end
	
	if not KFile.ReadTxtFile(szFileName) then
		KFile.WriteFile(szFileName, szRecord.."\r\n");
	else
		KFile.AppendFile(szFileName, szRecord.."\r\n");
	end
	
	-- 数据写完后，要交数据清掉
	self.tbRecordBuff = {};
end

-- 将待写数据插入内存中
function Item:InsertToMemoryCache(nCount, nWay)
	local szKey = string.format("%d_%d_%d_%d", it.nGenre, it.nDetail, it.nParticular, it.nLevel);
	
	-- 没在记录列表中，不需要记录
	if not self.tbRecordList[szKey] then
		return;
	end
	
	local tbData = {};
	tbData.szName = it.szName;
	tbData.szKey = szKey;
	tbData.nCount = nCount;
	if (self.tbRecordList[szKey].bDiffBindType == 1) then
		tbData.bBind = it.IsBind();
	end
	
	if not self.tbRecordBuff[nWay] then
		self.tbRecordBuff[nWay] = {};
	end
	
	if not self.tbRecordBuff[nWay][szKey] then
		self.tbRecordBuff[nWay][szKey] = {};
		self.tbRecordBuff[nWay][szKey].nBindCount = self.tbRecordBuff[nWay][szKey].nBindCount or 0;
		self.tbRecordBuff[nWay][szKey].nUnBindCount = self.tbRecordBuff[nWay][szKey].nUnBindCount or 0;
	end
	
	self.tbRecordBuff[nWay][szKey].szName = self.tbRecordBuff[nWay][szKey].szName or it.szName;
	if (it.IsBind() == 1) then
		self.tbRecordBuff[nWay][szKey].nBindCount = (self.tbRecordBuff[nWay][szKey].nBindCount or 0) + nCount;
	else
		self.tbRecordBuff[nWay][szKey].nUnBindCount = (self.tbRecordBuff[nWay][szKey].nUnBindCount or 0) + nCount;
	end
end

-- 是否在可操作列表中，参数为1表示remove的队列，为0表示add的队列
function Item:IsInRecordList(bRemove)
	bRemove = bRemove or 0;
	
	local szKey = string.format("%d_%d_%d_%d", it.nGenre, it.nDetail, it.nParticular, it.nLevel);
	if not self.tbRecordList[szKey] then
		return 0;
	end
	
	local nRet = 0;
	if bRemove == 1 then
		nRet = self.tbRecordList[szKey].bConsume;
	else
		nRet = self.tbRecordList[szKey].bAdd;
	end

	return nRet;
end

-- 加载配置文件
function Item:LoadRecordList()
	local tbFile = Lib:LoadTabFile(self.szRECORD_LIST);
	if not tbFile then
		return;
	end
	for _, tbData in pairs(tbFile) do
		local szKey = string.format("%d_%d_%d_%d", tbData.G, tbData.D, tbData.P, tbData.L);
		-- 重复了，给个错
		if self.tbRecordList[szKey] then
			assert(nil);
		end
		
		self.tbRecordList[szKey] = {};
		self.tbRecordList[szKey].bConsume = tonumber(tbData.bConsume) or 0;
		self.tbRecordList[szKey].bAdd = tonumber(tbData.bAdd) or 0;	
	self.tbRecordList[szKey].bDiffBindType = tonumber(tbData.DiffBindType) or 0;	
	end
end

-- 服务器退出的时候把缓存中的数据写到文件中，并清空缓存数据
function Item:OnServerClose()
	self:WriteDataRecord();
	self:WriteXJRecord();
	Timer:Close(self.nRecordTimer);
	self.nRecordTimer = nil;
end

Item.emITEM_DATARECORD_NORMAL		= 0;		-- 默认途径，不记录
Item.emITEM_DATARECORD_SYSTEMADD	= 1;		-- 系统产出(系统掉落、奇珍阁购买, 生活技能制作)
Item.emITEM_DATARECORD_ROLLOUTADD	= 2;		-- 价值量转出添加(剥离装备，剥离同伴，玄晶拆解)
Item.emITEM_DATARECORD_ROLLINREMOVE	= 3;		-- 价值量转移删除(强化装备、喂同伴，玄晶合成)
Item.emITEM_DATARECORD_REMOVE		= 4;		-- 永久性删除(吃声望令牌、成品，物品在地上系统回收，在回购栏被挤掉，道具兑换, 炼化时扣除的玄晶)

-------------------------------------------- 玄晶统计相关LOG ------------------------------------------------------
Item.emITEM_XJRECORD_DROPRATE		= 1;		-- NPC掉落
Item.emITEM_XJRECORD_EVENT			= 2;		-- 活动产出
Item.emITEM_XJRECORD_TASK			= 3;		-- 任务奖励

Item.LINKTASK_XJLOG_ID				= -1;		-- 玄晶统计LOG特殊记录ID
Item.TASKID_INVALID					= -2;		-- 没法获得ID的任务以这个ID记

Item.tbStrLogType = 
{
	[Item.emITEM_XJRECORD_DROPRATE] = "npcproduct_item",
	[Item.emITEM_XJRECORD_EVENT] = "eventproduct_item",
	[Item.emITEM_XJRECORD_TASK] = "taskproduct_item",
}

Item.szXJLOG_FILE	= "\\log\\datarecord\\%s\\xjlog_%s.txt";

Item:LoadRecordList();

-- 注册数据埋点记录定时器，每个小时写一次数据
Item.nRecordTimer = Timer:Register(Env.GAME_FPS * 3600, Item.WriteDataRecord, Item);
-- 服务器关闭前把缓存中的数据写入到文件
ServerEvent:RegisgerServerCloseFunc(Item.OnServerClose, Item);

-- Item.tbXJRecord = 
-- {
--	[nType] = 
--		{{[id] = {nBind, nUnBind}},
-- }
Item.tbXJRecord = {};

function Item:InsertXJRecordMemory(nType, varKey, nXJLevel, nBindAdd, nUnBindAdd)
	if not nType or not varKey  or not nXJLevel or (nBindAdd == 0 and nUnBindAdd == 0) then
		return;
	end
	
	if not self.tbXJRecord[nType] then
		self.tbXJRecord[nType] = {};
	end
	
	if not self.tbXJRecord[nType][varKey] then
		self.tbXJRecord[nType][varKey] = {};
	end
	
	if not self.tbXJRecord[nType][varKey][nXJLevel] then
		self.tbXJRecord[nType][varKey][nXJLevel] = {};	
	end
	
	local nBind = (self.tbXJRecord[nType][varKey][nXJLevel].nBind or 0) + nBindAdd;
	local nUnBind = (self.tbXJRecord[nType][varKey][nXJLevel].nUnBind or 0) + nUnBindAdd;
	
	self.tbXJRecord[nType][varKey][nXJLevel].nBind = nBind;
	self.tbXJRecord[nType][varKey][nXJLevel].nUnBind = nUnBind;
end

function Item:WriteXJRecord()
	local szRecord = "";
	for nType, tbRecord in pairs(self.tbXJRecord) do
		for varKey, tbData in pairs(tbRecord) do
			for i = 1, 12 do
				if (tbData[i]) then
					szRecord = szRecord..string.format("%d,%d%s", tbData[i].nBind, tbData[i].nUnBind, (i == 12) and "" or ",");
				else
					szRecord = szRecord..string.format("%d,%d%s", 0, 0, (i == 12) and "" or ",");
				end
			end
			
		StatLog:WriteStatLog("stat_info", "xuanjing_product", self.tbStrLogType[nType], 0, varKey, szRecord);
		szRecord = "";
		end
	end
	
	-- 写完之后，清空内存表	
	self.tbXJRecord = {};
end

-- 添加物品的时候检查要添加（或已添加的物品）是否是玄晶，是则插入数据
function Item:CheckXJRecord(nType, varKey, ...)
	if not nType or not varKey then
		return;
	end
	
	local szClass = "";
	local bBind, nBindType, nCount = 0, 0, 0;
	local nXJLevel = 0;
	
	if type(arg[1]) == "userdata" then
		local pItem = arg[1];
		szClass = pItem.szClass;
		bBind = pItem.IsBind();
		nCount = pItem.nCount;
		nXJLevel = pItem.nLevel;
	elseif type(arg[1]) == "table" then
		-- {g, d, p, l, bBind, nCount}
		local tb = KItem.GetItemBaseProp(arg[1][1], arg[1][2], arg[1][3], arg[1][4]);
		if not tb then
			return;
		end
		szClass = tb.szClass;
		bBind = arg[1][5];
		nBindType = tb.nBindType;
		nCount = arg[1][6];
		nXJLevel = arg[1][4];
	else
		return;
	end

	if szClass ~= "xuanjing" or nXJLevel == 0 then
		return;
	end

	local nBind, nUnBind = 0, 0;	
	-- 强制绑定或者获取绑定记绑定价值量
	if (bBind == 1 or KItem.IsItemBindByBindType(nBindType) == 1) then
		nBind = nCount;
	else
		nUnBind = nCount;
	end		

	self:InsertXJRecordMemory(nType, varKey, nXJLevel, nBind, nUnBind);
end

-- 玄晶统计每小时写一次
Item.nRecordTimer = Timer:Register(Env.GAME_FPS * 3600, Item.WriteXJRecord, Item);

----------------------------------------- others ----------------------------------------------------

-- 注意，记录个数不能以pItem.nCount作计数，nCount才是实际的数量
function Item:RecordPlayerAddItem(pItem, nCount, eWay)
	if Item.tbStone.tbStoneLogItem[pItem.SzGDPL()] then
		-- 宝石相关的产出log
		StatLog:WriteStatLog("stat_info", "baoshixiangqian", "advanced", me.nId, string.format("%d_%d_%d_%d", 
						pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel), nCount);
	end
	--时光殿产出log
	if pItem and pItem.szClass == "crosstimeroom_stone" then
		CrossTimeRoom:RecordAward(1,me.nId,pItem.szName);
	end
end
