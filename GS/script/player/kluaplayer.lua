-- 对C导出的Player对象进行封装
if MODULE_GC_SERVER then
	return
end

local self;		-- 提供以下函数用的UpValue

---- 测试/例子函数
--function _KLuaPlayer.Test(x)	-- 注意，这里要用“.”而不是“:”
--	-- 这里的self是UpValue，会被程序赋值成相应的Player对象
--	self.Msg(x);
--	-- 使用这个self需要注意一点：因为以下所有函数使用的是同一个UpValue（self），
--	-- 所以，在一个函数执行期间有可能self会被改变。为了避免出错，这里的函数应该
--	-- 尽量简洁，如果实在需要很复杂的调用，应当注意保存原self值。
--end

-------------------------------------------------------------------------------
-- for both server & client

-- 获得角色身上指定部位的装备
function _KLuaPlayer.GetEquip(nEquipPos)
	return	self.GetItem(Item.ROOM_EQUIP, nEquipPos);
end

function _KLuaPlayer.GetBagCellCount()
	local tbExt = {4, 6, 8, 10, 12, 15, 18, 20, 24}
	local nBagSize = 40;
	for i = 0, 2 do
		local pExtBag = self.GetExtBag(i);
		if pExtBag then
			local nType = pExtBag.nDetail;
			local nExtSize = tbExt[nType];
			nBagSize = nBagSize + nExtSize;
		end
	end
	return nBagSize;
end

-- 获得角色身上指定部位的切换装备
function _KLuaPlayer.GetEquipEx(nEquipExPos)
	return	self.GetItem(Item.ROOM_EQUIPEX, nEquipExPos);
end

-- 获得主背包里的道具
function _KLuaPlayer.GetMainBagItem(nX, nY)
	return	self.GetItem(Item.ROOM_MAINBAG, nX, nY);
end

-- 获得储物箱里的道具
function _KLuaPlayer.GetRepositoryItem(nX, nY)
	return	self.GetItem(Item.ROOM_REPOSITORY, nX, nY);
end

-- 获得角色所穿扩展背包
function _KLuaPlayer.GetExtBag(nExtBagPos)
	return	self.GetItem(Item.ROOM_EXTBAGBAR, nExtBagPos);
end

-- 获得角色扩展背包里的道具
function _KLuaPlayer.GetExtBagItem(nExtBagPos, nX, nY)
	local nRoom = Item.EXTBAGPOS2ROOM[nExtBagPos];
	if nRoom then
		return self.GetItem(nRoom, nX, nY);
	end
end

-- 获得角色扩展储物箱里的道具
function _KLuaPlayer.GetExtRepItem(nExtRepPos, nX, nY)
	local nRoom = Item.EXTREPPOS2ROOM[nExtRepPos];
	if nRoom then
		return self.GetItem(nRoom, nX, nY);
	end
end

-- 获得角色给予界面里的道具
function _KLuaPlayer.GetGiftItem(nX, nY)
	return	self.GetItem(Item.ROOM_GIFT, nX, nY);
end

-- 获得角色交易栏里的道具
function _KLuaPlayer.GetTradeItem(nX, nY)
	return	self.GetItem(Item.ROOM_TRADE, nX, nY);
end

-- 获得角色交易对方交易栏的道具
function _KLuaPlayer.GetTradeClientItem(nX, nY)
	return	self.GetItem(Item.ROOM_TRADECLIENT, nX, nY);
end

-- 获得角色邮箱里的道具
function _KLuaPlayer.GetMailItem()
	return	self.GetItem(Item.ROOM_MAIL);
end

-- 获得角色装备强化/玄晶剥离装备栏空间的道具
function _KLuaPlayer.GetEnhanceEquip()
	return	self.GetItem(Item.ROOM_ENHANCE_EQUIP);
end

-- 获得角色装备强化/玄晶剥离玄晶放置空间的道具
function _KLuaPlayer.GetEnhanceItem(nX, nY)
	return	self.GetItem(Item.ROOM_ENHANCE_ITEM, nX, nY);
end

-- 获得角色装备强化/玄晶剥离装备栏空间的道具
function _KLuaPlayer.GetHoleEquip()
	return	self.GetItem(Item.ROOM_HOLE_EQUIP);
end


-- 获得角色装备拆解空间的装备
function _KLuaPlayer.GetBreakUpEquip(nX, nY)
	return	self.GetItem(Item.ROOM_BREAKUP);
end

-- 获得角色回购空间的道具
function _KLuaPlayer.GetRecycleItem(nX, nY)
	return	self.GetItem(Item.ROOM_RECYCLE, nX, nY);
end

-- 获取所有背包中物品的数量
function _KLuaPlayer.GetItemCountInBags(nGenre, nDetail, nParticular, nLevel, nSeries, nBind)
	local nCount = 0;
	for _, nRoom in ipairs(Item.BAG_ROOM) do
		nCount = nCount + self.GetItemCount(nRoom, nGenre or 0, nDetail or 0, nParticular or 0, nLevel or 0, nSeries or -1, nBind or -1);
	end
	return	nCount;
end

-- 获取所有背包中物品的价钱
function _KLuaPlayer.GetItemPriceInBags()
	local nValue = 0;
	
	local tbAllRoom = {
			Item.BAG_ROOM,
			Item.REPOSITORY_ROOM,
		}
	for _, tbRoom in pairs(tbAllRoom) do
		for _, nRoom in pairs(tbRoom) do
			local tbIdx = self.FindAllItem(nRoom);
			for i = 1, #tbIdx do
				local pItem = KItem.GetItemObj(tbIdx[i]);
				if pItem.szClass == "xiang" then
					local nXiangCount = pItem.GetGenInfo(1);
					local tbXiang = Item:GetClass("xiang");
					nValue = nValue + pItem.nPrice * nXiangCount / tbXiang:GetMaxItemCount(pItem);
				elseif pItem.nGenre == Item.SCRIPTITEM or pItem.nGenre == Item.MEDICINE or pItem.nGenre == Item.SKILLITEM then
				 	nValue = nValue + pItem.nPrice;
				end
			end
		end
	end
	
	local nPrice = self.GetTask(Player.ACROSS_TSKGROUPID, Player.ACROSS_TSKID_PRICE);
	local nUseTime = self.GetTask(Player.ACROSS_TSKGROUPID, Player.ACROSS_TSKID_USE_TIME);
	local nTimeOut = self.GetTask(Player.ACROSS_TSKGROUPID, Player.ACROSS_TSKID_TIME_OUT);
	local nNowTime = GetTime();
	local nLastTime = nNowTime - nUseTime;
	local MIN_LAST_TIME = 10 * 60;
	if nLastTime < MIN_LAST_TIME and nLastTime > 0 then
		nLastTime = MIN_LAST_TIME;
	end
	if nLastTime < nTimeOut and nLastTime > 0 and nTimeOut > 0 then	
		nValue =  nValue + math.floor(nPrice * (nTimeOut - nLastTime)/ nTimeOut);
	end
	
	return	nValue;
end

function _KLuaPlayer.GetCanOfferSellCountInBag(nGenre, nDetail, nParticular, nLevel, nSeries)
	local nCount = 0;
	for _, nRoom in ipairs(Item.BAG_ROOM) do
		nCount = nCount + self.GetItemCount(nRoom, nGenre or 0, nDetail or 0, nParticular or 0, nLevel or 0, nSeries or -1, 0, 0);
	end
	return	nCount;
end

--在玩家背包和储物箱中找指定类型道具
function _KLuaPlayer.FindItemInAllPosition(nGenre, nDetail, nParticular, nLevel, nSeries)
	local tbResult = self.FindItemInBags(nGenre, nDetail, nParticular, nLevel, nSeries);
	local tbResult_Ex = self.FindItemInRepository(nGenre, nDetail, nParticular, nLevel, nSeries);
	Lib:MergeTable(tbResult, tbResult_Ex);
	return tbResult;
end
-- 在背包里查找指定类型的道具
function _KLuaPlayer.FindItemInBags(nGenre, nDetail, nParticular, nLevel, nSeries)
	local tbResult = {};
	for _, nRoom in ipairs(Item.BAG_ROOM) do
		local tbFind = self.FindItem(nRoom, nGenre or 0, nDetail or 0, nParticular or 0, nLevel or 0, nSeries or -1);
		if tbFind then
			for _, tbItem in ipairs(tbFind) do
				tbItem.nRoom = nRoom;
			end
			Lib:MergeTable(tbResult, tbFind);
		end
	end
	return	tbResult;
end


-- 在储物箱上找指定类型道具
function _KLuaPlayer.FindItemInRepository(nGenre, nDetail, nParticular, nLevel, nSeries)
	local tbResult = {};
	for _, nRoom in ipairs(Item.REPOSITORY_ROOM) do
		local tbFind = self.FindItem(nRoom, nGenre or 0, nDetail or 0, nParticular or 0, nLevel or 0, nSeries or -1);
		if tbFind then
			for _, tbItem in ipairs(tbFind) do
				tbItem.nRoom = nRoom;
			end
			Lib:MergeTable(tbResult, tbFind);
		end
	end
	return	tbResult;
end

-- 在背包里查找角色背包里与指定道具大类、小类、细类、等级、五行都一致的道具
function _KLuaPlayer.FindSameItemInBags(pItem)
	if not pItem then
		return;
	end
	return	self.FindItemInBags(pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel, pItem.nSeries);
end

-- 在背包里查找角色背包里是否拥有该的道具
function _KLuaPlayer.IsHaveItemInBags(pItem)
	if not pItem then
		return;
	end
	if self.GetItemPos(pItem) then
		return 1;
	end
	return 0;
end

-- 在背包里查找指定Class的道具
function _KLuaPlayer.FindClassItemInBags(szClass)
	local tbResult = {};
	for _, nRoom in ipairs(Item.BAG_ROOM) do
		local tbFind = self.FindClassItem(nRoom, szClass);
		if tbFind then
			for _, tbItem in ipairs(tbFind) do
				tbItem.nRoom = nRoom;
			end
			Lib:MergeTable(tbResult, tbFind);
		end
	end
	return	tbResult;
end

function _KLuaPlayer.FindClassItemOnPlayer(szClass)
	local tbResult = {};
	local tbRoom = {};
	Lib:MergeTable(tbRoom, Item.BAG_ROOM);
	Lib:MergeTable(tbRoom, Item.REPOSITORY_ROOM);
	
	for _, nRoom in ipairs(tbRoom) do
		local tbFind = self.FindClassItem(nRoom, szClass);
		if (tbFind) then
			for _, tbItem in ipairs(tbFind) do
				tbItem.nRoom = nRoom;
			end
			Lib:MergeTable(tbResult, tbFind);
		end
	end
	return tbResult;
end
-- 获得角色指定空间里与指定道具大类、小类、细类、等级、五行都一致的道具数目
function _KLuaPlayer.GetSameItemCount(nRoom, pItem)
	if not pItem then
		return;
	end
	return	self.GetItemCount(nRoom, pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel, pItem.nSeries);
end

-- 获得角色背包里与指定道具大类、小类、细类、等级、五行都一致的道具数目
function _KLuaPlayer.GetSameItemCountInBags(pItem)
	if not pItem then
		return;
	end
	return	self.GetItemCountInBags(pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel, pItem.nSeries);
end

-- 计算所有背包空间中还可放置与指定物品相同种类的物品的数量
function _KLuaPlayer.CalcFreeSameItemCountInBags(pItem)
	if (not pItem) then
		return	0;
	end
	if (pItem.IsStackable() ~= 1) then
		return self.CountFreeBagCell();		-- 如果是计时道具或锁定绑定道具一律不计算叠加
	end
	local tbBaseProp = KItem.GetItemBaseProp(pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel);
	if tbBaseProp and (tbBaseProp.szClass == "localmedicine" or tbBaseProp.szClass == "fulimedicine") then
		return self.CalFreeLocalMedicineCountInBags();
	else
		return	self.CalcFreeItemCountInBags(pItem.nGenre, pItem.nDetail, pItem.nParticular, pItem.nLevel, pItem.nSeries, pItem.IsBind());	
	end	
end

function _KLuaPlayer.CalFreeLocalMedicineCountInBags()
	local nMaxCount = self.GetBagCellCount(); -- 背包大小
	
	local nCurCount = self.GetLocalMedicineCount();
	
	local nFreeCount = nMaxCount - nCurCount;
	if nFreeCount <= 0 then
		nFreeCount = 0;
	end
	
	return nFreeCount;	
end

function _KLuaPlayer.GetLocalMedicineCount()
	local nCurCount = 0;
	local tbFind = self.FindClassItemOnPlayer("localmedicine");
	Lib:MergeTable(tbFind, self.FindClassItemOnPlayer("fulimedicine"));
	local nCurCount = 0;
	for _, tbItem in pairs (tbFind) do
		nCurCount = nCurCount + tbItem.pItem.nCount;
	end
	
	return nCurCount;
end

-- 是否可以使用/装备指定道具
function _KLuaPlayer.CanUseItem(pItem)
	return	KItem.CanPlayerUseItem(self, pItem);
end

function _KLuaPlayer.IsItemInBags(pItem)
	local tbFind = self.FindSameItemInBags(pItem);
	if not tbFind then
		return 0;
	end
	for _, tbItem in ipairs(tbFind) do		
		if (tbItem.pItem.dwId == pItem.dwId) then
			return 1;
		end
	end
	
	return 0;
end

function _KLuaPlayer.GetTempTable(szModelName)
	if (not szModelName) then
		print("获得玩家临时变量必须传入模块名");
		assert(false);
	end
	
	if (not Env.tbModelSet[szModelName]) then
		print("没有此模块名，查看scripttable.txt")
		assert(false);
	end
	
	local tbTemp = self.GetPlayerTempTable();
	if (not tbTemp[szModelName]) then
		tbTemp[szModelName] = {};
	end
	
	return tbTemp[szModelName];
end

-- 角色是否学会了指定的生活技能
function _KLuaPlayer.HasLearnLifeSkill(nSkillId)
	return LifeSkill:HasLearnSkill(self, nSkillId);
end

function _KLuaPlayer.GetAttRoute()
	local tbFaction2AttRoute = 
	{
		{0,0},		-- 少林
		{0,0},		-- 天王
		{0,0},		-- 唐门
		{0,1},		-- 五毒
		{1,1},		-- 娥眉
		{1,0},		-- 翠烟
		{1,0},		-- 丐帮
		{0,1},		-- 天忍
		{1,0},		-- 武当
		{0,1},		-- 昆仑
		{0,1},		-- 明教
		{0,1},		-- 段氏
		{0,1},		-- 古墓
	}
	if self.nFaction == 0 or self.nRouteId == 0 or
		not tbFaction2AttRoute[self.nFaction] or
		not tbFaction2AttRoute[self.nFaction][self.nRouteId] then
		return -1;
	end
	return tbFaction2AttRoute[self.nFaction][self.nRouteId];
end

-- 自动匹配真元的位置
function _KLuaPlayer.GetZhenYuanPos()
	local nPos = Item.EQUIPPOS_ZHENYUAN_MAIN;
	local pPlayer = self;
	--[[暂时没有开放后面两个真元格子
	for i = Item.EQUIPPOS_ZHENYUAN_MAIN, Item.EQUIPPOS_ZHENYUAN_SUB2 do
		if not self.GetEquip(i) then
			nPos = i;
			break;
		end
	end
	]]--
	
	return nPos;
end

--检查是否激活充值
function _KLuaPlayer.GetPayActionState(nExtType)
	local tbType = Player.TSK_PAYACTION_EXT_ID;
	if tbType[nExtType] then
		local nCurDate 	= tonumber(GetLocalDate("%Y%m"))	
		local nDate		= self.GetTask(Player.TSK_PAYACTION_GROUP, tbType[nExtType]);
		if nDate == nCurDate then
			return 1; --已经激活
		end
		local nExtState = self.GetActiveValue(nExtType);
		if nExtState == 1 then
			return 2; -- "账号下其他角色已激活了领奖资格，不能再激活了！";
		end
		return 0; -- "当前角色未激活本月的领奖资格";
	end
	return -1; -- "出现异常";
end

--激活充值
function _KLuaPlayer.SetPayActionState(nExtType)
	local tbType = Player.TSK_PAYACTION_EXT_ID;
	if tbType[nExtType] then
		local nCurDate 	= tonumber(GetLocalDate("%Y%m"));
		if self.GetPayActionState(nExtType) == 0 then
			self.SetTask(Player.TSK_PAYACTION_GROUP, tbType[nExtType], nCurDate);
			self.SetActiveValue(nExtType, 1);
			return 1;
		end
	end
	return 0;
end

function _KLuaPlayer.GetKinSkillOffer()
	local nOffer = self.GetTask(Kin.TASK_GROUP, Kin.TASK_SKILLOFFER);
	return nOffer;
end

function _KLuaPlayer.LockClientInput()
	self.SetTask(Player.TASK_OTHER_GROUP, Player.TASK_LOCK_INPUT, 1);
end

function _KLuaPlayer.UnLockClientInput()
	self.SetTask(Player.TASK_OTHER_GROUP, Player.TASK_LOCK_INPUT, 0);
end

-------------------------------------------------------------------------------
-- for server
if MODULE_GAMESERVER then

-- 客户端是否被调试过,一次GS的运行过程
function _KLuaPlayer.ClientIsDebugging()
	return SelfProtect:IsDebugging(self.szName)
end

-- 客户端是否使用了非法的模块
function _KLuaPlayer.ClientHasInvalidModules()
	return SelfProtect:HasInvalidModules(self.szName)
end

function _KLuaPlayer.GetStudioLevel()
	return StudioScore:GetLevel(self);
end

-- 显示连斩效果(bShow:1显示，0取消, nPkCount：连斩数量, nTimeSec：显示时间，0为永久，默认30秒)
function _KLuaPlayer.ShowSeriesPk(bShow, nPkCount, nTimeSec)
	if bShow == 1 then
		self.CallClientScript({"UiManager:OpenWindow", "UI_SERIESKILL", nPkCount, nTimeSec});
	else
		self.CallClientScript({"UiManager:CloseWindow", "UI_SERIESKILL"});
	end
end


-- tbItemInfo =
--{
--		nSeries or Env.SERIES_NONE,		五行，默认无
--		nEnhTimes or 0,					强化次数，默认0
--		nLucky or 0,					幸运
--		tbGenInfo,						
--		tbRandomInfo, 				装备随机品质
--		nVersion or 0,					
--		uRandSeed or 0,					随机种子
--		bForceBind,						强制绑定默认0
--		bTimeOut,						是否会超时
-- 		bMsg,							是否消息通知
--}	

function _KLuaPlayer.AddItemEx(nGenre, nDetail, nParticular, nLevel, tbItemInfo, nWay,nTimeout)
	if not tbItemInfo then
		tbItemInfo = {}
	end
	nGenre 		= tonumber(nGenre) or 0;
	nDetail 	= tonumber(nDetail) or 0;
	nParticular = tonumber(nParticular) or 0;
	nLevel 		= tonumber(nLevel) or 0;
	
	return	KItem.AddPlayerItem(
		self,
		nGenre,
		nDetail,
		nParticular,
		nLevel,
		tbItemInfo.nSeries or Env.SERIES_NONE,
		tbItemInfo.nEnhTimes or 0,
		tbItemInfo.nLucky or 0,
		tbItemInfo.tbGenInfo,
		tbItemInfo.tbRandomInfo,
		tbItemInfo.nVersion or 0,
		tbItemInfo.uRandSeed or 0,
		tbItemInfo.bForceBind or 0,
		tbItemInfo.bTimeOut or 0,
		tbItemInfo.bMsg or 1,
		nWay or 100,
		nTimeout or 0
	);
end

function _KLuaPlayer.AddStackItem(nGenre, nDetail, nParticular, nLevel, tbItemInfo, nCount, nWay)
	if nCount < 1 then
		return 0, "";
	end
	local nCurCount = 0;
	local nStackMax = 0;
	nCount = tonumber(nCount) or 0;
	local szName = "";
	if not tbItemInfo then
		tbItemInfo = {};
	end
	tbItemInfo.bMsg = tbItemInfo.bMsg or 0;
	local pItem = self.AddItemEx(nGenre, nDetail, nParticular, nLevel, tbItemInfo, nWay);
	if pItem then
		nStackMax = pItem.nMaxCount;
		szName = pItem.szName;
		nCurCount = nCurCount + 1;
	end
	while (pItem and nCurCount ~= nCount) do
		local nCanAddNum = nStackMax - pItem.nCount;
		if nCanAddNum > 0 then
			if nCanAddNum + nCurCount > nCount then 
				nCanAddNum = nCount - nCurCount;
			end
			nCurCount = nCurCount + nCanAddNum;
			
			local nItemAddWay = Item.emITEM_DATARECORD_SYSTEMADD;
			local tbSystemAddWay = 
			{
				Player.emKITEMLOG_TYPE_PEEL_PARTNER,
				Player.emKITEMLOG_TYPE_CYSTAL_COMPOSE,
				Player.emKITEMLOG_TYPE_UNENHANCE,
				Player.emKITEMLOG_TYPE_COMPOSE,
			}
			for _, nAddWay in pairs(tbSystemAddWay) do
				if nAddWay == nWay then
					nItemAddWay = Item.emITEM_DATARECORD_ROLLOUTADD;
					break;
				end
			end
			
			pItem.SetCount(pItem.nCount + nCanAddNum, nItemAddWay);
		end
		if nCurCount ~= nCount then
			pItem = self.AddItemEx(nGenre, nDetail, nParticular, nLevel, tbItemInfo, nWay);
			if pItem then
				nCurCount = nCurCount + 1;
			end
		end
	end
	if nCurCount ~= nCount then
		Dbg:WriteLog("AddStackItem", "角色名:"..self.szName, "帐号:"..self.szAccount, "道具"..nGenre, nDetail, nParticular, nLevel, string.format("批量填加道具失败！需要填加%s个，实际只填加了%s个", nCount, nCurCount));
	end
	if nCurCount > 0 then
		self.Msg(string.format("Bạn nhận được %d %s", nCurCount, szName));
	end
	return nCurCount,szName;
end

-- 给指定角色增加一个道具
function _KLuaPlayer.AddItem(nGenre, nDetail, nParticular, nLevel, nSeries, nEnhTimes, nLucky, tbGenInfo, tbRandomInfo, nVersion, uRandSeed, nWay)

	return	KItem.AddPlayerItem(
		self,
		nGenre,
		nDetail,
		nParticular,
		nLevel,
		nSeries or Env.SERIES_NONE,
		nEnhTimes or 0,
		nLucky or 0,
		tbGenInfo,
		tbRandomInfo,
		nVersion or 0,
		uRandSeed or 0,
		0,0,1,
		nWay or 100,
		0
	);

end

-- 给角色增加一个普通装备
function _KLuaPlayer.AddGeneralEquip(nDetail, nParticular, nLevel, nSeries, nEnhTimes, nLucky, nVersion, uRandSeed)
	return	KItem.AddPlayerGeneralEquip(self, nDetail, nParticular, nLevel, nSeries, nEnhTimes, nLucky, nVersion, uRandSeed);
end

-- 给角色增加一个黄金装备
function _KLuaPlayer.AddGoldEquip(nDetail, nParticular, nLevel, nSeries, nEnhTimes, nVersion)
	return	KItem.AddPlayerGoldEquip(self, nDetail, nParticular, nLevel, nSeries, nEnhTimes, nVersion);
end

-- 给角色增加一个绿色装备
function _KLuaPlayer.AddGreenEquip(nDetail, nParticular, nLevel, nSeries, nEnhTimes, nVersion)
	return	KItem.AddPlayerGreenEquip(self, nDetail, nParticular, nLevel, nSeries, nEnhTimes, nVersion);
end

-- 给角色增加一个药品
function _KLuaPlayer.AddMedicine(nDetail, nParticular, nLevel, nSeries, nVersion)
	return	KItem.AddPlayerMedicine(self, nDetail, nParticular, nLevel, nSeries, nVersion);
end

-- 给角色增加一个脚本道具
function _KLuaPlayer.AddScriptItem(nDetail, nParticular, nLevel, nSeries, tbGenInfo, nVersion)
	return	KItem.AddPlayerScriptItem(self, nDetail, nParticular, nLevel, nSeries, tbGenInfo, nVersion);
end

-- 给角色增加一个技能道具
function _KLuaPlayer.AddSkillItem(nDetail, nParticular, nLevel, nSeries, nVersion)
	return	KItem.AddPlayerSkillItem(self, nDetail, nParticular, nLevel, nSeries, nVersion);
end

-- 给角色增加一个任务道具
function _KLuaPlayer.AddQuest(nDetail, nParticular, nLevel, nSeries, tbGenInfo, nVersion)
	return	KItem.AddPlayerQuest(self, nDetail, nParticular, nLevel, nSeries, tbGenInfo, nVersion);
end

-- 给角色增加一个扩展背包
function _KLuaPlayer.AddExtBag(nDetail, nParticular, nVersion)
	return	KItem.AddPlayerExtBag(self, nDetail, nParticular, nVersion);
end

-- 给角色增加一个生活技能材料
function _KLuaPlayer.AddStuffItem(nDetail, nParticular, nLevel, nSeries, nVersion, nWay)
	return	KItem.AddPlayerStuffItem(self, nDetail, nParticular, nLevel, nSeries, nVersion, nWay);
end

-- 给角色增加一个生活技能配方
function _KLuaPlayer.AddPlanItem(nDetail, nParticular, nLevel, nSeries, nVersion)
	return	KItem.AddPlayerPlanItem(self, nDetail, nParticular, nLevel, nSeries, nVersion);
end

-- 删除角色身上某件道具
function _KLuaPlayer.DelItem(pItem, nWay)
	return	KItem.DelPlayerItem(self, pItem, (nWay or 100));
end

function _KLuaPlayer.ConsumeItemInBags2(nCount, nGenre, nDetail, nParticular, nLevel, nSeries, nBind)
	nSeries = tonumber(nSeries) or -1;
	nBind = tonumber(nBind) or -1;
	local nFreeItemCount = self.GetItemCountInBags(nGenre, nDetail, nParticular, nLevel, nSeries, nBind);
	if (nFreeItemCount < nCount or nCount <= 0) then
		return 1;
	end
	local nCalcCount = nCount;
	local tbFind = self.FindItemInBags(nGenre, nDetail, nParticular, nLevel, nSeries)
	for _, tbItem in pairs(tbFind) do
		local pItem = tbItem.pItem;
		local nNeedItem = 1;
		if nBind >= 0 then
			if pItem.IsBind() ~= nBind then
				nNeedItem = 0;
			end
		end
		if nNeedItem == 1 then
			local nDelItemCount = pItem.nCount;
			if pItem.nCount > nCalcCount then
				nDelItemCount = nCalcCount;
			end 
			if pItem.nCount - nDelItemCount > 0 then
				pItem.SetCount(pItem.nCount - nDelItemCount, Item.emITEM_DATARECORD_REMOVE);
			else
				if (self.DelItem(pItem, Player.emKLOSEITEM_USE) ~= 1) then
					return 1;
				end
			end
			nCalcCount = nCalcCount - nDelItemCount;
			if nCalcCount <= 0 then
				break;
			end
		end
	end
	return 0;
end

-- 以当前玩家身份运行
function _KLuaPlayer.Call(...)
	local pPlayerOld	= me;
	me	= self;
	local tbRet	= {Lib:CallBack(arg)};
	me	= pPlayerOld;
	if (tbRet[1]) then
		return unpack(tbRet, 2);
	end
end

-- 增加玩家心得
function _KLuaPlayer.AddInsight(nInsightNumber)
	if (nInsightNumber <= 0) then
		return;
	end
	
	Task:AddInsight(nInsightNumber);
end

-- 增加角色生活技能经验
function _KLuaPlayer.AddLifeSkillExp(nSkillId, nExp)
	return LifeSkill:AddSkillExp(self, nSkillId, nExp);
end

-- 增加角色秘籍修为
function _KLuaPlayer.AddBookKarma(nAddKarma)
	return Item:AddBookKarma(self, nAddKarma);
end

-- 江湖威望增加入口
function _KLuaPlayer.AddKinReputeEntry(nRepute, szWay)
	if nRepute <= 0 then
		return 0;
	end
	local nTimes = KGblTask.SCGetDbTaskInt(DBTASK_WEIWANG_TIMES);
	if (nTimes < 1) then
		nTimes = 1;
	end
	nRepute = nRepute * nTimes;
	if szWay and Player.PRESTIGE_LIMIT[szWay] then
		local nCurWeek = tonumber(os.date("%W", GetTime()));
		local nWeek	   = self.GetTask(Player.PRESTIGE_LIMIT_GROUP, Player.PRESTIGE_WEEK_ID);
		if nWeek ~= nCurWeek then
			for _, tbLimit in pairs(Player.PRESTIGE_LIMIT) do
				self.SetTask(Player.PRESTIGE_LIMIT_GROUP, tbLimit[1], 0);
			end
			self.SetTask(Player.PRESTIGE_LIMIT_GROUP, Player.PRESTIGE_WEEK_ID, nCurWeek);
		end
		local nCurValue = self.GetTask(Player.PRESTIGE_LIMIT_GROUP, Player.PRESTIGE_LIMIT[szWay][1]);
		if nCurValue + nRepute > Player.PRESTIGE_LIMIT[szWay][2] then
			nRepute = Player.PRESTIGE_LIMIT[szWay][2] - nCurValue
		end
		if nRepute <= 0 then
			self.Msg("好厉害！你已经获得了该活动本周所有的“江湖威望”，要想再获得江湖威望可以参加别的活动或着下周再来！")
			return 0;
		end
		self.SetTask(Player.PRESTIGE_LIMIT_GROUP, Player.PRESTIGE_LIMIT[szWay][1], nCurValue + nRepute);
	end
	local nKinId, nMemberId = self.GetKinMember();
	local nTongId = self.dwTongId
	-- 增加家族江湖威望
	GCExcute{"Kin:AddKinTotalRepute_GC", nKinId, nMemberId, self.nId, nRepute};
	-- 增加帮会总江湖威望
	if nTongId ~= 0 then
		GCExcute{"Tong:AddTongTotalRepute_GC", nTongId, nRepute};
	end
	
	-- 在获取江湖威望的时候更新获取威望时间
	Stats:UpdateGetReputeTime(self);
	Dbg:WriteLog("Prestige", self.szName, nRepute, szWay)
	return 1
end


-- 经验增加入口 zounan add
-- me.AddExp表示直接加经验
function _KLuaPlayer.AddExp2(nExp, szWay)
	if nExp <= 0 then
		return 0;
	end
	
	if szWay and Player.EXP_TYPE[szWay] then
		if (self.GetTiredDegree1() == 1) then
			nExp = nExp * 0.5;
		elseif (self.GetTiredDegree1() == 2) then
			nExp = 0;
		end
	end
	
	if nExp > 0 then
		self.AddExp(nExp);
	end

	return math.floor(nExp);
end


-- 绑银增加入口 zounan add
-- 
function _KLuaPlayer.AddBindMoney2(nMoney, szWay, szType)
	if nMoney <= 0 then
		return 0;
	end
	
	if szWay and Player.BINDMONEY_TYPE[szWay] then
		if (self.GetTiredDegree1() == 1) then
			nMoney = nMoney * 0.5;
		elseif (self.GetTiredDegree1() == 2) then
			nMoney = 0;
		end
	end
	
	if nMoney > 0 then
		self.AddBindMoney(nMoney,szType);
	end

	return math.floor(nMoney);
end

-- 用来判断玩家是否是可以立即转为正式成员的老玩家
function _KLuaPlayer.CanJoinKinImmediately()
	local bIsOldPAction = EventManager.ExEvent.tbPlayerCallBack:IsOpen(self, 2);
	if (1 == bIsOldPAction) then
		local nOldPLastJoinKinTime = self.GetTask(Player.TASK_GROUP_OLDPLAYER, Player.TASK_ID_JOINKIN_TIME);
		if (GetTime() > nOldPLastJoinKinTime) then
			self.SetTask(Player.TASK_GROUP_OLDPLAYER, Player.TASK_ID_JOINKIN_TIME, GetTime() + Player.OLDPLAYER_ACTION_TIME);
			return 1;
		end
	end
	return 0;
end

-- 用来判断是否是可以立即离开家族的老玩家
function _KLuaPlayer.CanLeaveKinImmediately()
	local bIsOldPAction = EventManager.ExEvent.tbPlayerCallBack:IsOpen(self, 2);
	if (1 == bIsOldPAction) then
		local nOldPLastLeaveKinTime = self.GetTask(Player.TASK_GROUP_OLDPLAYER, Player.TASK_ID_LEAVEKIN_TIME);
		if (GetTime() > nOldPLastLeaveKinTime) then
			self.SetTask(Player.TASK_GROUP_OLDPLAYER, Player.TASK_ID_LEAVEKIN_TIME, GetTime() + Player.OLDPLAYER_ACTION_TIME);
			return 1;
		end
	end
	return 0;
end


--扣除家族技能贡献值
function _KLuaPlayer.DecreaseKinSkillOffer(nDecreaseOffer)
	local nOffer = self.GetTask(Kin.TASK_GROUP, Kin.TASK_SKILLOFFER);
	if nOffer < nDecreaseOffer then		
		return 0;
	end
	self.SetTask(Kin.TASK_GROUP, Kin.TASK_SKILLOFFER, nOffer - nDecreaseOffer);
	return 1;
end

-- 帮会贡献度入口
function _KLuaPlayer.AddTongOfferEntry(nOffer)
	local nKinId, nMemberId = self.GetKinMember();
	local cKin = KKin.GetKin(nKinId);
	if (not cKin) then
		return 0;
	end
	local cMember = cKin.GetMember(nMemberId);
	if (not cMember) then
		return 0;
	end
	if nOffer <= 0 then
		return 0;
	end
	--隐士不能获得
	local nFigure = cMember.GetFigure();
	if nFigure == 0 or nFigure == Kin.FIGURE_RETIRE or nFigure == Kin.FIGURE_SIGNED then
		return 0
	end
	local nTongId = self.dwTongId;
	if nTongId and nTongId ~= 0 then
		--self.AddTongOffer(nOffer);
		local nFund = math.floor(self.GetProductivity() * nOffer);
		--self.Msg(string.format("帮会建设资金增加%d", nFund));
		GCExcute{"Tong:AddBuildFund_GC", nTongId, nKinId, nMemberId, nFund, 1, 0}
	end
end

function _KLuaPlayer.__GetMonthPayExtValue()
	local nExtPoint = 1;
	local nMonth = tonumber(GetLocalDate("%m"));
	if math.mod(nMonth, 2) == 0 then
		nExtPoint = 5;
	end
	
	return self.GetExtPoint(nExtPoint);
end

function _KLuaPlayer.__AddMonthPayExtValue(nValue)
	local nExtPoint = 1;
	local nMonth = tonumber(GetLocalDate("%m"));
	if math.mod(nMonth, 2) == 0 then
		nExtPoint = 5;
	end
	
	return self.AddExtPoint(nExtPoint, nValue);
end

-- 返回:盛大玩家当月消费的点券数额/100
-- bNeedExactValue 可选参数，如果需要返回盛大玩家当月消费的准确数值时传入1
function _KLuaPlayer.GetMonthPay(bNeedExactValue)
	local nConsume = self.GetSndaConsumeAmount();
	if (nConsume <= 0) then
		return 0;
	end
	if (bNeedExactValue and 1 == bNeedExactValue) then
		return nConsume;
	else
		return math.floor(nConsume / 100);
	end
end
function _KLuaPlayer.__PayMonthPayExtValue(nValue)
	local nExtPoint = 1;
	local nMonth = tonumber(GetLocalDate("%m"));
	if math.mod(nMonth, 2) == 0 then
		nExtPoint = 5;
	end
	
	if self.GetExtPoint(nExtPoint) < nValue then
		return;
	end
	return self.PayExtPoint(nExtPoint, nValue);
end

-- 获得玩家当月的充值情况，单月用1号扩展点，双月用5号扩展点
function _KLuaPlayer.GetExtMonthPay(bNeedExactValue)
	if IVER_g_nSdoVersion == 1 then
		return self.GetMonthPay(bNeedExactValue);
	end
	local nValue = KLib.BitOperate(self.__GetMonthPayExtValue(), "&", 0x0fffffff);
	if jbreturn:GetMonLimit(self) > 0 then
		local nMonth = tonumber(GetLocalDate("%Y%m"));
		nValue = jbreturn:GetMonthPay(nMonth, nValue);
	end
	return nValue;
end

-- 获得玩家当月的充值情况，单月用1号扩展点，双月用5号扩展点
function _KLuaPlayer.GetExtMonthPay_VN(bNeedExactValue)
	if IVER_g_nSdoVersion == 1 then
		return self.GetMonthPay(bNeedExactValue);
	end
	local nValue = math.floor(KLib.BitOperate(self.__GetMonthPayExtValue(), "&", 0x0fffffff));
	if jbreturn:GetMonLimit(self) > 0 then
		local nMonth = tonumber(GetLocalDate("%Y%m"));
		nValue = jbreturn:GetMonthPay(nMonth, nValue);
	end
	return nValue;
end

-- 获得账号数据int
function _KLuaPlayer.GetAccTask(szKey)
	return Account:GetIntValue(self.szAccount, szKey);
end

-- 设置账号数据int
function _KLuaPlayer.SetAccTask(szKey, nValue)
	return Account:ApplySetIntValue(self.szAccount, szKey, nValue, 0);
end

-- 获得账号数据str
function _KLuaPlayer.GetAccTaskStr(szKey)
	return Account:GetBinValue(self.szAccount, szKey);
end

-- 设置账号数据str
function _KLuaPlayer.SetAccTaskStr(szKey, nValue)
	return Account:ApplySetBinValue(self.szAccount, szKey, nValue);
end


-- 本月已经已经激活的帐号数目
function _KLuaPlayer.GetLinkTaskActiveAccountNum()
	local nValue = KLib.BitOperate(self.__GetMonthPayExtValue(), "&", 0xf0000000);
	return KLib.BitOperate(nValue, ">>", 28);
end

-- 增加一个激活帐号
function _KLuaPlayer.AddLinTaskActiveAccount()
	return self.__AddMonthPayExtValue(0x10000000);
end

--获得每月激活位值(1-3位)
function _KLuaPlayer.GetActiveValue(nBit)
	if not nBit or nBit <= 0 or nBit > 3 then
		print("GetActiveValue!!! nBit Must between 1 and 3");
		return 0;
	end 	
	local nExtValue = self.GetLinkTaskActiveAccountNum();
	local nExtBit = Lib:LoadBits(nExtValue, nBit-1, nBit-1);
	return nExtBit;
end

--设置每月激活位值(1-3位)
function _KLuaPlayer.SetActiveValue(nBit, nValue)
	if not nBit or nBit <= 0 or nBit > 3 then
		print("SetActiveValueError!!! nBit Must between 1 and 3");
		return 0;
	end 
	if not nValue or nValue < 0 or nValue > 1 then
		print("SetActiveValueError!!! nValue Must 0 or 1");
		return 0;
	end
	local nExtValue = self.GetLinkTaskActiveAccountNum();
	local nExtBitValue = Lib:SetBits(nExtValue, nValue, nBit-1, nBit-1);
	local nExt2 = nExtBitValue - nExtValue;
	if nExt2 > 0 then
		self.__AddMonthPayExtValue((nExt2 * 2^28));
	elseif nExt2 < 0 then
		self.__PayMonthPayExtValue((-nExt2 * 2^28));
	end
	return 1;
end

-- 设置账号数据
function _KLuaPlayer.SetBankPayQualification(nValue)
	Account:ApplySetIntValue(self.szAccount, "OnlineBankPay.ActiveValue", nValue);
end

function _KLuaPlayer.GetBankPayQualification()
	return Account:GetIntValue(self.szAccount, "OnlineBankPay.ActiveValue");
end



---- 关进天牢 -------
function _KLuaPlayer.TakeToPrison(nPrisonTime, nMapId)
	if (nPrisonTime <= 0) then
		return 0;
	end
	---默认天牢地图id
	if (nMapId == nil or nMapId <= 0) then
		nMapId = 399;
	end
	
	self.SetTask(2000, 3, nPrisonTime);
	local nTianLaoX		= 1651;		-- X坐标
	local nTianLaoY		= 3260;		-- Y坐标
	self.NewWorld(nMapId, nTianLaoX, nTianLaoY);
end

--- 放出天牢
function _KLuaPlayer.TakeOutPrison()
	self.DisabledStall(0);	--摆摊
	self.DisableOffer(0); 
	self.SetForbidChat(0);
	-- 返回0，表示要关闭此Timer
	local tbTmp = self.GetTempTable("Npc");
	tbTmp.nPrisonLeftTimeId = nil;
	self.SetTask(2000, 3, 0);	-- 坐牢剩余时间设置为0
	local nMapId, nPointId, nXPos, nYPos = self.GetDeathRevivePos();
	self.NewWorld(nMapId, nXPos / 32, nYPos / 32);
end

function _KLuaPlayer.IsInPrison()
	local nArrestTime = self.GetArrestTime();
	local nLeftTime = self.GetTask(2000, 3);
	local bRet = 0;
	if (nArrestTime ~= 0 or nLeftTime ~= 0) then
		bRet = 1;
	end
	return bRet;
end

-- 是否是夫妻
function _KLuaPlayer.IsCouple(szRelation)
	local tbRelation = self.GetRelationList(Player.emKPLAYERRELATION_TYPE_COUPLE);
	for _, szName in ipairs(tbRelation) do
		if (szName == szRelation) then
			return 1;
		end
	end
	return 0;
end

-- 获取配偶的名字
function _KLuaPlayer.GetCoupleName()
	-- 夫妻关系需要尝试主位和次位来获取对方的信息
	local tbRelation = self.GetRelationList(Player.emKPLAYERRELATION_TYPE_COUPLE, 1);
	if (#tbRelation == 0) then
		tbRelation = self.GetRelationList(Player.emKPLAYERRELATION_TYPE_COUPLE, 0);
		if (#tbRelation == 0) then
			return;
		end
	end
	
	if (#tbRelation ~= 1) then
		return;
	end
	
	return tbRelation[1];
end

-- 查询是否结婚
function _KLuaPlayer.IsMarried()
	if (not self:GetCoupleName()) then
		return 0;
	end
	return 1;
end

-- 是否有好友关系
function _KLuaPlayer.IsFriendRelation(szRelation)
	local tbRelation = self.GetRelationList(Player.emKPLAYERRELATION_TYPE_BIDFRIEND);
	for _, szName in ipairs(tbRelation) do
		if (szName == szRelation) then
			return 1;
		end
	end	
	return 0;
end


function _KLuaPlayer.IsHaveRelation(szRelationPlayer, nRelatinId, bAsMaster)
	local tbRelation = nil;
	if bAsMaster then
		tbRelation = self.GetRelationList(nRelatinId, bAsMaster);
	else
		tbRelation = self.GetRelationList(nRelatinId);
	end
	
	if not tbRelation then
		return 0;
	end
	
	for _, szName in ipairs(tbRelation) do
		if (szName == szRelationPlayer) then
			return 1;
		end
	end	
	return 0;	
end


-- 判断是否是师徒关系
function _KLuaPlayer.IsTeacherRelation(szPlayerName, bAsMaster)
	local tbRelation = self.GetRelationList(Player.emKPLAYERRELATION_TYPE_TRAINING, bAsMaster);
	for _, szName in ipairs(tbRelation) do
		if (szName == szPlayerName) then
			return 1;
		end
	end	
	tbRelation = self.GetRelationList(Player.emKPLAYERRELATION_TYPE_TRAINED, bAsMaster);
	for _, szName in ipairs(tbRelation) do
		if (szName == szPlayerName) then
			return 1;
		end
	end	
	return 0;
end

-- 获得亲密度等级
function _KLuaPlayer.GetFriendFavorLevel(szFriendName)
	local nFavor = self.GetFriendFavor(szFriendName);
	local nLevel = math.ceil(math.sqrt(math.ceil(nFavor/100)));
	return nLevel;
end

function _KLuaPlayer.GetLogOutState()
	return self.GetTask(2029, 3)
end

function _KLuaPlayer.SetLogOutState(nMissionType)
	return self.SetTask(2029, 3, nMissionType);
end

-- 设置屏蔽组队界面
function _KLuaPlayer.SetDisableTeam(nState)
	self.CallClientScript({"Ui:ServerCall", "UI_SYSTEM", "SetDisableTeam" , nState or 0});
end

-- 设置屏蔽交易界面
function _KLuaPlayer.SetDisableStall(nState)
	self.CallClientScript({"Ui:ServerCall", "UI_SYSTEM", "SetDisableStall" , nState or 0});
end

-- 设置屏蔽好友界面
function _KLuaPlayer.SetDisableFriend(nState)
	self.CallClientScript({"Ui:ServerCall", "UI_SYSTEM", "SetDisableFriend" , nState or 0});
end

-- 增加跨服绑银
function _KLuaPlayer.AddGlbBindMoney(nAddMoney, nWay)
	nWay = nWay or 0;
	if GLOBAL_AGENT then
		if self.GetBindMoney() + nAddMoney > self.GetMaxCarryMoney() then
			Dbg:WriteLog("AddGlbBindMoney", "Fail", self.szName, nAddMoney, nWay);
			return 0;
		end
		self.AddBindMoney(nAddMoney, nWay);
		Dbg:WriteLog("AddGlbBindMoney", "Success", self.szName, nAddMoney, nWay);
		return 1;
	end
	
	local nCurrentMoney = KGCPlayer.OptGetTask(self.nId, KGCPlayer.TSK_CURRENCY_MONEY);
	if nCurrentMoney + nAddMoney > self.GetMaxCarryMoney() then
		Dbg:WriteLog("AddGlbBindMoney", "Fail", self.szName, nAddMoney, nWay);
		return 0;
	end
	GCExcute{"Player:Nor_DataSync_GC", self.szName, nAddMoney};
	self.Msg(string.format("你成功增加了%s两的跨服专用银两。", nAddMoney));
	Dbg:WriteLog("AddGlbBindMoney", "Success", self.szName, nAddMoney, nWay);
	return 1;
end

-- 消耗跨服绑银
function _KLuaPlayer.CostGlbBindMoney(nMoney, nWay)
	nWay = nWay or 0;
	if GLOBAL_AGENT then
		if nMoney > self.GetBindMoney() then
			Dbg:WriteLog("CostGlbBindMoney", "Fail", self.szName, nMoney, nWay);
			return 0;
		end
		self.CostBindMoney(nMoney, nWay);
		Dbg:WriteLog("CostGlbBindMoney", "Success", self.szName, nMoney, nWay);
		return 1;
	end
	
	local nCurrentMoney = KGCPlayer.OptGetTask(self.nId, KGCPlayer.TSK_CURRENCY_MONEY);
	if nMoney > nCurrentMoney then
		Dbg:WriteLog("CostGlbBindMoney", "Fail", self.szName, nMoney, nWay);
		return 0;
	end
	GCExcute{"Player:Nor_DataSync_GC", self.szName, (-nMoney)};
	self.Msg(string.format("你消耗了%s两的跨服专用银两。", nMoney));
	Dbg:WriteLog("CostGlbBindMoney", "Success", self.szName, nMoney, nWay);
	return 1;
end

-- 获得跨服专用绑银
function _KLuaPlayer.GetGlbBindMoney()
	if GLOBAL_AGENT then
		return self.GetBindMoney();
	end
	local nCurrentMoney = KGCPlayer.OptGetTask(self.nId, KGCPlayer.TSK_CURRENCY_MONEY);
	return nCurrentMoney;
end

--聊天栏禁用(nType 类型对应表里面，nState 1表示禁掉，0表示开启)
function _KLuaPlayer.SetChannelState(nType, nState)
	local nDisabledFlag = self.GetDisabledFuncFlag();
	local tbType = {
		--[-1]		--全部频道
		[1] = 0,	--公聊
		[2] = 1,	--派聊
		[3] = 2,	--族聊
		[4] = 3,	--帮聊
		[5] = 4,	--帮派联盟聊
		[6] = 5,	--城聊
		[7] = 6,	--队聊
		[8] = 7,	--近聊
		[9] = 8,	--密聊
		[10] = 22,	--跨服的同服频道
		[11] = 24,	--好友
		 };
	if not nType or (not tbType[nType] and nType ~= -1) then
		return 0;
	end
	if not nState or nState < 0 or nState > 1 then
		return 0;
	end	
	if nType == -1 then
		for i ,nNum in pairs(tbType) do
			nDisabledFlag = Lib:SetBits(nDisabledFlag, nState, nNum, nNum);
		end
	else		
		nDisabledFlag = Lib:SetBits(nDisabledFlag, nState, tbType[nType], tbType[nType]);
	end	
	self.SetDisabledFuncFlag(nDisabledFlag);
	return 1;
end

function _KLuaPlayer.GetIp()
	local szAddr = self.GetPlayerIpAddress();
	local nPos	= string.find(szAddr, ":");
	if (not nPos) then
		return szAddr;
	end
	return string.sub(szAddr, 1, nPos - 1), string.sub(szAddr, nPos + 1);
end

function _KLuaPlayer.NewWorld2(dwMapId, nX, nY)
	if self.IsInCarrier() == 1 then
		local pCarrier = self.GetCarrierNpc();
		if pCarrier then
			pCarrier.NewWorld(dwMapId, nX, nY);
		end
	else
		self.NewWorld(dwMapId, nX, nY);
	end		
end

-------------------------------------------------------------------------------
-- for client
elseif MODULE_GAMECLIENT then

function _KLuaPlayer.GetSelectNpc()
	local tbTemp = self.GetTempTable("Npc");
	return tbTemp.pSelectNpc;
end

-- 获得角色指定技能的Tip字符串
function _KLuaPlayer.GetFightSkillTip(nSkillId, nAddPoint, bViewNext)
	local pNpc = self.GetNpc();
	if not pNpc then
		return	"";
	end
	local nLevel = pNpc.GetFightSkillLevel(nSkillId);
	local szTitle, szInfo = FightSkill:GetDesc(nSkillId, nLevel + nAddPoint, nAddPoint, bViewNext, pNpc);
	return szTitle, szInfo;
end

-- 获得潜能对应的Tip字符串
function _KLuaPlayer.GetPotentialTip(nPotential)

	local tbInfo = 
	{
		[Player.ATTRIB_STR] =
		{
			szName		= "力量",
			tbValue		= { self.nBaseStrength, self.nStrength - self.nBaseStrength },
			tbProperty	=
			{
				{ "外功系普攻攻击", KPlayer.GetStrength2DamagePhysics },
			},
		},
		[Player.ATTRIB_DEX] =
		{
			szName		= "身法",
			tbValue		= { self.nBaseDexterity, self.nDexterity - self.nBaseDexterity },
			tbProperty	=
			{
				{ "外功系普攻攻击", KPlayer.GetDexterity2DamagePhysics },
				{ "命中", 			KPlayer.GetDexterity2AttackRate },
				{ "闪避", 			KPlayer.GetDexterity2Defence },
			},
		},
		[Player.ATTRIB_VIT] =
		{
			szName		= "外功",
			tbValue		= { self.nBaseVitality, self.nVitality - self.nBaseVitality },
			tbProperty	=
			{
				{ "生命值", 		KPlayer.GetVitality2Life },
			},
		},
		[Player.ATTRIB_ENG] =
		{
			szName		= "内功",
			tbValue		= { self.nBaseEnergy, self.nEnergy - self.nBaseEnergy },
			tbProperty	=
			{
				{ "内功系普攻攻击", KPlayer.GetEnergy2DamageMagic },
				{ "内力值", 		KPlayer.GetEnergy2Mana },
			},
		},
	};

	local tb = tbInfo[nPotential];
	if (not tb) then
		return "";
	end

	-- 潜能相关数值Tip
	local szTipName = string.format(
		"%s：<color=green>%d<color> + <color=gold>%d<color>\n",
		tb.szName,
		tb.tbValue[1],
		tb.tbValue[2]
	);

	-- 所影响属性值Tip
	local szTipProperty = "";
	for i = 1, #tb.tbProperty do
		local nProperty = tb.tbProperty[i][2](
			self.nFaction,
			self.nRouteId,
			tb.tbValue[1] + tb.tbValue[2]
		);
		if (nProperty > 0) then
			szTipProperty = szTipProperty..string.format("提高%s%d点\n", tb.tbProperty[i][1], nProperty);
		end
	end

	if (szTipProperty == "") then
		szTipProperty = "此能力对于您所属的门派无意义";
	end

	return szTipName..szTipProperty;

end

function _KLuaPlayer.GetStateTip(nState)
	local tbInfo =
	{
		[Npc.STATE_HURT]	= "受伤",
		[Npc.STATE_SLOWALL]	= "迟缓",
		[Npc.STATE_WEAK]	= "虚弱",
		[Npc.STATE_BURN]	= "灼伤",
		[Npc.STATE_STUN]	= "眩晕",
	};
	local szInfo = tbInfo[nState];
	if (not szInfo) then
		return "";
	end

	local nValue = self.GetNpc().GetState(nState).nResistTime;
	local szMsg = nValue >= 0 and "缩短" or "增加";
	nValue = math.abs(nValue);
	return string.format("%s受到的%s效果时间%d%%", szMsg, szInfo, math.floor(nValue /(nValue + 250) * 100));
end

-- 获得抗性对应的Tip字符串
function _KLuaPlayer.GetResistTip(nResist)
	local tbInfo =
	{
		[Env.SERIES_METAL]	= { "普攻", self.nGR },
		[Env.SERIES_WOOD]	= { "毒攻", self.nPR },
		[Env.SERIES_WATER]	= { "冰攻", self.nCR },
		[Env.SERIES_FIRE]	= { "火攻", self.nFR },
		[Env.SERIES_EARTH]	= { "雷攻", self.nLR },
	};
	local tb = tbInfo[nResist];
	if (not tb) then
		return "";
	end

	local pReduce = Player:CountReduceDefence(tb[2]);
	local pDefenceValue = 1/(1-pReduce/100);			--防御价值,百分比..
	
	return string.format(
		"受到同等级敌人的%s攻击%s<color=gold>%s%%<color>\n即受到同等级敌人的%s攻击除<color=gold>%s%%<color>",
		tb[1],
		(pReduce >= 0) and "减少" or "增加",
		math.floor(100*pReduce)/100,
		tb[1],
		math.floor(100*pDefenceValue)
	);
end

-- 获得攻速对应的Tip字符串
function _KLuaPlayer.GetAttackSpeedTip()
	local tbSet = KFightSkill.GetSetting();
	local nAttackPerSecond = math.max(tbSet.nAttackFrameMin, Env.GAME_FPS - math.floor(self.nAttackSpeed / 10));
	nAttackPerSecond = math.min(tbSet.nAttackFrameMax, nAttackPerSecond) / Env.GAME_FPS;
	nAttackPerSecond = math.floor(nAttackPerSecond * 100 + 0.5) / 100;	-- 四舍五入并保留2位小数
	local nCastPerSecond = math.max(tbSet.nCastFrameMin, Env.GAME_FPS - math.floor(self.nCastSpeed / 10));
	nCastPerSecond = math.min(tbSet.nCastFrameMax, nCastPerSecond) / Env.GAME_FPS;
	nCastPerSecond = math.floor(nCastPerSecond * 100 + 0.5) / 100;		-- 四舍五入并保留2位小数
	
	return "外功系技能出招速度，每"..nAttackPerSecond.."秒出招1次；\n内功系技能出招速度，每"..nCastPerSecond.."秒出招1次；\n格斗系技能出招速度不受攻速影响。";
end

-- 获得角色手持武器所对应的技能
function _KLuaPlayer.GetWeaponSkill()
	return KFightSkill.GetPlayerWeaponSkill(self);
end

-- 家族申请列表 core数据缓存GM指令.
function _KLuaPlayer.KinRequest_InitRequestList()
	local tbTemp = self.GetTempTable("Kin");
	if tbTemp then
		if not tbTemp.Kin_tbRequest then
			tbTemp.Kin_tbRequest = {}
			tbTemp.Kin_tbRequest.tbRequestList = {};
			tbTemp.Kin_tbRequest.nCount = Kin.REQUEST_REST_BEGIN;	-- 固定操作预留索引ID
		end
		return 1;
	end
	return 0;
end

function _KLuaPlayer.KinRequest_GetRequestList()
	local tbTemp = self.GetTempTable("Kin");
	if (not tbTemp) or (not tbTemp.Kin_tbRequest) or (not tbTemp.Kin_tbRequest.tbRequestList) then
		return nil;
	end
	return tbTemp.Kin_tbRequest.tbRequestList;
end

function _KLuaPlayer.KinRequest_AddRequset(tbRequest, nIndex)
	local tbTemp = self.GetTempTable("Kin");
	if (not tbTemp) or (not tbTemp.Kin_tbRequest) then
		if self.KinRequest_InitRequestList() ~= 1 then
			return 0;
		end
	end
	tbTemp.Kin_tbRequest.nCount = tbTemp.Kin_tbRequest.nCount + 1;
	if nIndex then
		tbTemp.Kin_tbRequest.tbRequestList[nIndex] = tbRequest;
	else
		tbTemp.Kin_tbRequest.tbRequestList[tbTemp.Kin_tbRequest.nCount] = tbRequest;
	end
end

function _KLuaPlayer.KinRequest_DelRequest(nKey)
	local tbTemp = self.GetTempTable("Kin");
	if (not tbTemp) or (not tbTemp.Kin_tbRequest) then
		if self.KinRequest_InitRequestList() ~= 1 then
			return 0;
		end
	end
	local tbRequest = tbTemp.Kin_tbRequest.tbRequestList[nKey];
	tbTemp.Kin_tbRequest.tbRequestList[nKey] = nil;
	return tbRequest;
end

-- 帮会申请列表 CORE数据缓存GM指令
function _KLuaPlayer.TongRequest_InitRequestList()
	local tbTemp = self.GetTempTable("Tong");
	if tbTemp then
		if not tbTemp.Tong_tbRequest then
			tbTemp.Tong_tbRequest = {};
			tbTemp.Tong_tbRequest.tbRequestList = {};
		end
		return 1;
	end
	return 0;
end

function _KLuaPlayer.TongRequest_GetRequestList()
	local tbTemp = self.GetTempTable("Tong");
	if (not tbTemp) or (not tbTemp.Tong_tbRequest) or (not tbTemp.Tong_tbRequest.tbRequestList) then
		return nil;
	end
	return tbTemp.Tong_tbRequest.tbRequestList;
end

function _KLuaPlayer.TongRequest_AddRequest(nKey, tbRequest)
	local tbTemp = self.GetTempTable("Tong");
	if (not tbTemp) or (not tbTemp.Tong_tbRequest) then
		if self.TongRequest_InitRequestList() ~= 1 then
			return 0;
		end
	end
	if not tbTemp.Tong_tbRequest.tbRequestList then
		tbTemp.Tong_tbRequest.tbRequestList = {};
	end
	tbTemp.Tong_tbRequest.tbRequestList[nKey] = tbRequest;
end

function _KLuaPlayer.TongRequest_DelRequest(nKey)
	local tbTemp = self.GetTempTable("Tong")
	if (not tbTemp) or (not tbTemp.Tong_tbRequest) then
		if self.TongRequest_InitRequestList() ~= 1 then
			return 0;
		end
	end
	if not tbTemp.Tong_tbRequest.tbRequestList then
		tbTemp.Tong_tbRequest.tbRequestList = {};
	end
	local tbRequest = tbTemp.Tong_tbRequest.tbRequestList[nKey];
	tbTemp.Tong_tbRequest.tbRequestList[nKey] = nil;
end

-- 人际关系表 CORE数据缓存 GM指令
function _KLuaPlayer.Relation_InitRelationList()
	local tbTemp = self.GetTempTable("Relation");
	if tbTemp then
		if (not tbTemp.Relation_tbRelation) then
			tbTemp.Relation_tbRelation = {}
		end
		tbTemp.Relation_tbRelation.tbRelationList 	= {};
		tbTemp.Relation_tbRelation.tbInfo			= {};
		
		if (not tbTemp.Relation_tbRelationGroup) then
			tbTemp.Relation_tbRelationGroup = {};
		end
		
		return 1;
	end
	return 0;
end

function _KLuaPlayer.Relation_AddRelation(tbRelation)	
	local tbTemp = self.GetTempTable("Relation");
	if (not tbTemp) or (not tbTemp.Relation_tbRelation) then
		if self.Relation_InitRelationList() ~= 1 then
			return 0;
		end
	end
	local tbList = tbTemp.Relation_tbRelation.tbRelationList
	if not tbList[tbRelation.nType] then
		tbList[tbRelation.nType] = {};
	end
	
	if tbRelation.nType == Player.emKPLAYERRELATION_TYPE_TMPFRIEND or 
		tbRelation.nType == Player.emKPLAYERRELATION_TYPE_BLACKLIST or
		tbRelation.nType == Player.emKPLAYERRELATION_TYPE_ENEMEY then
		if (tbTemp.Relation_tbRelation.tbInfo[tbRelation.szPlayer]) then
			tbTemp.Relation_tbRelation.tbInfo[tbRelation.szPlayer] = nil;
		end		
	end	
	if (tbList[tbRelation.nType][tbRelation.szPlayer]) then
		return 0;
	end
	if not tbList[tbRelation.nType][tbRelation.szPlayer] then
		tbList[tbRelation.nType][tbRelation.szPlayer] = {};
	end
	tbList[tbRelation.nType][tbRelation.szPlayer] = tbRelation;
	if (tbRelation.nType == Player.emKPLAYERRELATION_TYPE_BIDFRIEND) then
		tbTemp.Relation_tbRelation.nFriendNum	= (tbTemp.Relation_tbRelation.nFriendNum or 0) + 1;
		
	elseif (tbRelation.nType == Player.emKPLAYERRELATION_TYPE_TRAINING) then
		if (tbRelation.nRole == 0) then
			tbTemp.Relation_tbRelation.nStudentNum	= (tbTemp.Relation_tbRelation.nStudentNum or 0) + 1;
		else
			tbTemp.Relation_tbRelation.nTeacherNum	= (tbTemp.Relation_tbRelation.nTeacherNum or 0) + 1;
		end
		tbTemp.Relation_tbRelation.nFriendNum	= (tbTemp.Relation_tbRelation.nFriendNum or 0) + 1;
	elseif (tbRelation.nType == Player.emKPLAYERRELATION_TYPE_TRAINED) then
		if (tbRelation.nRole == 0) then
			tbTemp.Relation_tbRelation.nStudentNum	= (tbTemp.Relation_tbRelation.nStudentNum or 0) + 1;
			tbTemp.Relation_tbRelation.nMiyouNum	= 	(tbTemp.Relation_tbRelation.nMiyouNum or 0) + 1;
		else
			tbTemp.Relation_tbRelation.nTeacherNum	= (tbTemp.Relation_tbRelation.nTeacherNum or 0) + 1;
		end
		tbTemp.Relation_tbRelation.nFriendNum	= (tbTemp.Relation_tbRelation.nFriendNum or 0) + 1;
	elseif ((tbRelation.nType == Player.emKPLAYERRELATION_TYPE_INTRODUCTION and tbRelation.nRole == 0)  or 
			tbRelation.nType == Player.emKPLAYERRELATION_TYPE_BUDDY) then
		tbTemp.Relation_tbRelation.nMiyouNum	= 	(tbTemp.Relation_tbRelation.nMiyouNum or 0) + 1;
		if (tbRelation.nType == Player.emKPLAYERRELATION_TYPE_BUDDY) then
			tbTemp.Relation_tbRelation.nFriendNum	= (tbTemp.Relation_tbRelation.nFriendNum or 0) + 1;
		end
	end
	return 1;
end

function _KLuaPlayer.GetRelationNum()
	local tbTemp = self.GetTempTable("Relation");
	local nStudentNum 	= 0;
	local nTeacherNum	= 0;
	local nMiyouNum		= 0; 
	
	if (not tbTemp.Relation_tbRelation)then
		return;
	end
	
	if (nil ~= tbTemp.Relation_tbRelation.nStudentNum)then
		nStudentNum	= tbTemp.Relation_tbRelation.nStudentNum;
	end
	if (nil ~= tbTemp.Relation_tbRelation.nTeacherNum) then
		nTeacherNum	= tbTemp.Relation_tbRelation.nTeacherNum;
	end
	if (nil ~= tbTemp.Relation_tbRelation.nMiyouNum)then
		nMiyouNum	= tbTemp.Relation_tbRelation.nMiyouNum;
	end
	return nStudentNum, nTeacherNum, nMiyouNum;
end

function _KLuaPlayer.Relation_SetOnlineState(szPlayer, nOnline)
	local tbTemp = self.GetTempTable("Relation");
	local tbList = tbTemp.Relation_tbRelation.tbRelationList;
	for nType, tbRelationData in pairs(tbList) do
		if (tbRelationData[szPlayer]) then
			tbRelationData[szPlayer].nOnline = nOnline;
		end
	end
end

function _KLuaPlayer.Relation_SetRelationInfo(szPlayer, tbInfo)
	local tbTemp = self.GetTempTable("Relation");
	if (not tbTemp) or (not tbTemp.Relation_tbRelation) then
		if self.Relation_InitRelationList() ~= 1 then
			return 0;
		end
	end
	tbTemp.Relation_tbRelation.tbInfo[szPlayer] = tbInfo;
	return 1;
end

function _KLuaPlayer.Relation_DelRelation(nRelationType, szPlayer)
	local tbTemp = self.GetTempTable("Relation");
	if (not tbTemp) or (not tbTemp.Relation_tbRelation) then
		return;
	end
	local tbList = tbTemp.Relation_tbRelation.tbRelationList
	local tbRet;
	if tbList[nRelationType] and tbList[nRelationType][szPlayer] then
		tbRet = tbList[nRelationType][szPlayer];
		tbList[nRelationType][szPlayer] = nil;
		local nNum	= tbTemp.Relation_tbRelation.nFriendNum;
		if (nNum and  nNum > 1 and nRelationType == Player.emKPLAYERRELATION_TYPE_BIDFRIEND) then
			tbTemp.Relation_tbRelation.nFriendNum = tbTemp.Relation_tbRelation.nFriendNum - 1;
		end
	end
	return tbRet;
end

function _KLuaPlayer.Relation_GetRelationList()
	local tbTemp = self.GetTempTable("Relation");
	if (not tbTemp) or (not tbTemp.Relation_tbRelation) then
		return;
	end
	return tbTemp.Relation_tbRelation.tbRelationList, tbTemp.Relation_tbRelation.tbInfo, tbTemp.Relation_tbRelation.nFriendNum;
end

----- 分组自定义好友
function _KLuaPlayer.Relation_InitRelationGroupList()
	local tbTemp = self.GetTempTable("Relation");
	if tbTemp then
		if (not tbTemp.Relation_tbRelationGroup) then
			tbTemp.Relation_tbRelationGroup = {};
		end				
		return 1;
	end
	return 0;
end

function _KLuaPlayer.Relation_GetRelationGroupList(nGroupId)
	local tbTemp = self.GetTempTable("Relation");
	if (not tbTemp) or (not tbTemp.Relation_tbRelationGroup) then
		return;
	end
	return tbTemp.Relation_tbRelationGroup[nGroupId];
end

function _KLuaPlayer.Relation_AddRelationGroup(nGroupId, tbGroupList)
	local tbTemp = self.GetTempTable("Relation");
	if (not tbTemp) or (not tbTemp.Relation_tbRelationGroup) then
		if self.Relation_InitRelationGroupList() ~= 1 then
			return 0;
		end
	end
	
	tbTemp.Relation_tbRelationGroup[nGroupId] = tbGroupList;

	return 1;
end

function _KLuaPlayer.Relation_DelRelationGroup(nGroupId)
	local tbTemp = self.GetTempTable("Relation");
	if (not tbTemp) or (not tbTemp.Relation_tbRelationGroup) then
		if self.Relation_InitRelationGroupList() ~= 1 then
			return 0;
		end
	end

	tbTemp.Relation_tbRelationGroup[nGroupId] = nil;
	return 1;
end

function _KLuaPlayer.Relation_DelRelationGroupPlayer(nGroupId, szPlayerName)
	self.CallServerScript({"RelationCmd", "DelRelationGroupPlayer_C2S", nGroupId, szPlayerName});
end

function _KLuaPlayer.Relation_ApplyCreateRelationGroup(nGroupId)
	local tbTemp = self.GetTempTable("Relation");
	if (not tbTemp) or (not tbTemp.Relation_tbRelationGroup) then
		if self.Relation_InitRelationGroupList() ~= 1 then
			return 0;
		end
	end

	self.CallServerScript({"RelationCmd", "ApplyCreateRelationGroup_C2S", nGroupId});
end

function _KLuaPlayer.Relation_ApplyAddRelationGroupPlayer(nGroupId, szPlayerName)	
	self.CallServerScript({"RelationCmd", "ApplyAddRelationGroupPlayer_C2S", nGroupId, szPlayerName});
end

function _KLuaPlayer.Relation_ApplyRenameRelationGroup(nGroupId)	
	self.CallServerScript({"RelationCmd", "ApplyRenameRelationGroup_C2S", nGroupId});
end

function _KLuaPlayer.Relation_ApplyDelRelationGroup(nGroupId)	
	self.CallServerScript({"RelationCmd", "ApplyDelRelationGroup_C2S", nGroupId});
end


function _KLuaPlayer.GetMySelfCheckTime()
	local tbTemp = self.GetTempTable("Relation");
	if (not tbTemp) or (not tbTemp.nCheckTime) then
		return 0;
	else
		return tbTemp.nCheckTime or 0;
	end
end

function _KLuaPlayer.SetMySelfCheckTime(nTime)
	local tbTemp = self.GetTempTable("Relation");
	tbTemp.nCheckTime = nTime;
end

-- 获取师徒关系的列表(包括师傅和徒弟)
function _KLuaPlayer.Relation_GetTrainingRelation()
	local tbList = {};
	local tbRelationList, tbInfoList = self.Relation_GetRelationList();
	if (not tbRelationList) then
		return ;
	end
	local tbData = {
		tbRelationList[Player.emKPLAYERRELATION_TYPE_TRAINING],
		tbRelationList[Player.emKPLAYERRELATION_TYPE_TRAINED]
	}
	for i = 1, #tbData do
		if tbData[i] then
			for szPlayer, tbRelation in pairs(tbData[i]) do
				local tbTraining 	= {};
				local tbInfo 		= tbInfoList[szPlayer];
				tbTraining.szPlayer = szPlayer;
				tbTraining.nType 	= tbRelation.nType;
				tbTraining.nRole 	= tbRelation.nRole;
				if tbInfo then
					tbTraining.nLevel = tbInfo.nLevel;
					tbTraining.nFaction = tbInfo.nFaction;
					tbTraining.nSex = tbInfo.nSex;
					tbTraining.nFavor = tbInfo.nFavor;
				else
					tbTraining.nLevel = 0;
					tbTraining.nFaction = 0;
					tbTraining.nSex = 0;
					tbTraining.nFavor = 0;
				end
				table.insert(tbList, tbTraining);
			end
		end
	end
	return tbList;
end

function _KLuaPlayer.GetGoldSuiteAttrib(...)
	return KItem.GetPlayerGoldSuiteAttrib(self, unpack(arg));
end

function _KLuaPlayer.GetGreenSuiteAttrib(...)
	return KItem.GetPlayerGreenSuiteAttrib(self, unpack(arg));
end

-- 获取任务链奖励内容
function _KLuaPlayer.GetChainTaskAward()
	local tbTemp = self.GetTempTable("Task");
	return tbTemp.Task_tbChainTaskAward;
end

-- 缓存任务链奖励内容
function _KLuaPlayer.SetChainTaskAward(tbAward)
	local tbTemp = self.GetTempTable("Task");
	tbTemp.Task_tbChainTaskAward = tbAward;
end
-- 缓存一个活动的数据
-- szType		: 活动类型
-- tbDate		: 活动数据 
-- nUsefulTime 	: 有效时间（帧数），时间到后数据会失效，nil为永远有效
function _KLuaPlayer.SetCampaignDate(szType, tbDate, nUsefulTime)
	local tbTemp = self.GetTempTable("Ui");
	if not tbTemp.tbCampaignDate then
		tbTemp.tbCampaignDate = {};
	end
	tbTemp.tbCampaignDate.szType = szType;
	tbTemp.tbCampaignDate.tbDate = tbDate;
	tbTemp.tbCampaignDate.nValdState = 1; -- 标志数据有效
	if tbTemp.tbCampaignDate.nTimerId and tbTemp.tbCampaignDate.nTimerId ~= 0 then
		Player:CloseTimer(tbTemp.tbCampaignDate.nTimerId);
		tbTemp.tbCampaignDate.nTimerId = 0;
	end
	if nUsefulTime and nUsefulTime > 0 then
		tbTemp.tbCampaignDate.nTimerId = Player:RegisterTimer(
			nUsefulTime,
			self.CampaignDateTimeOut
		);
	end
	CoreEventNotify(UiNotify.emCOREEVENT_SYNC_CAMPAIGN_DATE, szType);	-- 活动数据改变了
end

-- 获得缓存的一个活动界面数据
-- 如果数据已经失效则返回为nil, 否则返回活动的类型szType和数据表tbDate
function _KLuaPlayer.GetCampaignDate()
	local tbTemp = self.GetTempTable("Ui");
	if not tbTemp.tbCampaignDate then
		return;
	end
	if tbTemp.tbCampaignDate.nValdState == 0 then
		return;
	end
	return tbTemp.tbCampaignDate.szType, tbTemp.tbCampaignDate.tbDate;
end

-- 缓存的活动数据超时失效
function _KLuaPlayer.CampaignDateTimeOut()
	local tbTemp = self.GetTempTable("Ui");
	if not tbTemp.tbCampaignDate then
		return 0;
	end
	tbTemp.tbCampaignDate.nValdState = 0;
	tbTemp.tbCampaignDate.nTimerId = 0;
	CoreEventNotify(
		UiNotify.emCOREEVENT_SYNC_CAMPAIGN_DATE, 
		tbTemp.tbCampaignDate.szType
	);
	return 0;
end

--	缓存角色交易单信息
function _KLuaPlayer.SetPlayerBillInfo(tbBillInfo)
	local tbTemp = self.GetTempTable("JbExchange");
	tbTemp.JbExchange_tbPlayerBillInfo	= tbBillInfo;
end

--	获取角色交易单信息
function _KLuaPlayer.GetPlayerBillInfo()
	local tbTemp = self.GetTempTable("JbExchange");
	return tbTemp.JbExchange_tbPlayerBillInfo;
end

--	缓存交易所内要显示的交易单信息
function _KLuaPlayer.SetShowBillList(tbInfo, tbShowBill)
	local tbTemp = self.GetTempTable("JbExchange");
	tbTemp.JbExchange_tbShowBill	= tbShowBill;
	tbTemp.JbExchange_tbInfo		= tbInfo;
end

--	获取要显示的交易单信息
function _KLuaPlayer.GetShowBillList()
	local tbTemp = self.GetTempTable("JbExchange");
	return tbTemp.JbExchange_tbShowBill;
end

--	获取交易所的一些基本信息
function _KLuaPlayer.GetExchangeInfo()
	local tbTemp = self.GetTempTable("JbExchange");
	return tbTemp.JbExchange_tbInfo;
end

-- 获得玩家所在地图的模板id
function _KLuaPlayer.GetMapTemplateId()
	local nMapId = self.GetWorldPos();
	return nMapId;
end

function _KLuaPlayer.SetMailBoxLoadOk()
	local  tbTemp = self.GetTempTable("Mail");
	tbTemp.MailBoxLoadOk = 1;
end

function _KLuaPlayer.GetMailBoxLoadOk()
	local tbTemp = self.GetTempTable("Mail");
	if not tbTemp.MailBoxLoadOk then
		return 0;
	else
		return 1;
	end
end

function _KLuaPlayer.UseSkill(nSkillId, nX, nY)
	UseSkill(nSkillId);
end

function _KLuaPlayer.LandInSelCarrier()
	local pNpc = self.GetSelectNpc();
	if not pNpc or pNpc.IsCarrier() == 0 then
		return;
	end
	
	self.CallServerScript({"LandInClientSelCarrier", pNpc.dwId});
end

--------------------------------------------------------------------------------
end	--if MODULE_GAMESERVER then else end
