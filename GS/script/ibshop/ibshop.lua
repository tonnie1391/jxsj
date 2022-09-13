

local TASK_PROMOTION_TASKID = 2034;
local BACKCOIN = 500;
local GIVEBACKBINDCOIN = 100;
IbShop.EventOpen = 0;
IbShop.WaraItemSaleStatus = {}

local TASK_BindMoney_Id = 11;	--绑银返还

-- 检查玩家当前状态是否能打开奇珍阁
function IbShop:CheckCanUse(nCheckFlag)
	if (nCheckFlag and 1 == nCheckFlag) then -- 当是脚本使用这个指令的话就跳过这些判断
		return 1;
	end
	
	if me.IsAccountLock() ~= 0 then
		return 0;
	end
	
	if Account:Account2CheckIsUse(me, 4) == 0 then
		return 0;
	end	
	-- 在天牢中不能打开奇珍阁
	--if (me.IsInPrison() == 1) then
	--	return 0;
	--end
	Spreader:IbShopGetConsume();	--掉一次清掉积分
	
	if (GLOBAL_AGENT) then
		return 0;
	end;
	
	return 1;
end

--手动上架下架已经废弃，该判断无效
function   IbShop:IsSaleStatus(strWareIndex)
	if not self.WaraItemSaleStatus or not strWareIndex then
		return 1
	end
	if self.WaraItemSaleStatus[strWareIndex] then
		return 0
	end
	return 1
end

function IbShop:_ClearIbShopData(pPlayer)
	local szMonth = GetLocalDate("%Y%m");
	local szPrvMonth = os.date("%Y%m", pPlayer.GetTask(2034, 7));
	if ( szMonth > szPrvMonth) then
		pPlayer.SetTask(2034, 5, 0);
		pPlayer.SetTask(2034, 6, 0);
		pPlayer.SetTask(2034, 7, GetTime());
	end
end

function IbShop:CanPromtion(pPlayer)
	self:_ClearIbShopData(pPlayer);
	
	local nNowTime = tonumber(GetLocalDate("%Y%m%d"));
	-- 回馈时间表
	
	if (nNowTime >= 20090223 and nNowTime < 20090301) then 
		return 1;	
	end
	
	--返还技能buff
	if pPlayer.GetSkillState(1336) > 0 then
		return 1;
	end
	
	--活动系统调用
	if self.EventOpen > 0 then
		return 1;
	end
	
	return 0;
end

function IbShop:Promotion(pPlayer, nTotalCoin,nWareId,nCurrencyType,nItemCount)
	if (not pPlayer) then
		return 0;
	end
	
	-- me.Msg("Promotion")
	if nCurrencyType == 0 then
		Spreader:IbShopAddConsume(nTotalCoin, 1, pPlayer);
	end
	
	--增加热销商品购买次数
	GCExcute{"IbShop:AddFavoriteGoodsTimes",nCurrencyType,nItemCount,nWareId};
	
	--老玩家返还
	SpecialEvent.tbOldPlayerBack:Return(pPlayer, nTotalCoin);
	
	--新服第一次买东西返还好友奖励
	SpecialEvent.tbNewGateEvent:OnFirstBuy(pPlayer, nTotalCoin);
	
	--绑银返还
	self:ReturnBindMoney(pPlayer, nTotalCoin);
	
	self:VipReturn(pPlayer, nTotalCoin);
	
	--奇珍阁log
	local tbWareInfo = pPlayer.IbShop_GetWareInf(nWareId);
	local szGDPL = string.format("%s-%s-%s-%s", tbWareInfo.nGenre, tbWareInfo.nDetailType, tbWareInfo.nParticular, tbWareInfo.nLevel);
	StatLog:WriteStatLog("stat_info", "qizhenge", "purchase", pPlayer.nId, string.format("%s,%s,%s,%s,%s", szGDPL, nWareId, nItemCount, nCurrencyType, tbWareInfo.nCurPrice));
	
	if  self:CanPromtion(pPlayer) ~= 1 then
		return 0;
	end
	local nMonCharge = 100 * pPlayer.nMonCharge;
	local nHaveCoin = pPlayer.GetTask(TASK_PROMOTION_TASKID,  5);
	if (nHaveCoin >= nMonCharge) then
		pPlayer.Msg(string.format("本月累计%s额不够，无法获得消费绑定%s返还！", IVER_g_szPayName, IVER_g_szCoinName));
		return 0;
	end
	local nCoin = nTotalCoin + nHaveCoin;
	if (nMonCharge < nCoin) then
	 	nCoin = nMonCharge;
	end
	pPlayer.SetTask(TASK_PROMOTION_TASKID, 5, nCoin);
	
	local nGiveNum = pPlayer.GetTask(TASK_PROMOTION_TASKID, 6);
	 
	nCoin = math.floor(nCoin - nGiveNum * BACKCOIN);
	local nCount = math.floor(nCoin / BACKCOIN);
	if (nCount > 0) then
	 	local nBindCoin = self:GetEventExCoin(pPlayer, nCount);
	 	pPlayer.AddBindCoin(nBindCoin, Player.emKBINDCOIN_ADD_EVENT);
	 	pPlayer.SetTask(TASK_PROMOTION_TASKID, 6, nCount + nGiveNum);
	 	pPlayer.Msg(string.format("您参加%s消费奖绑定%s活动，获得%s绑定%s奖励。", IVER_g_szCoinName, IVER_g_szCoinName, nBindCoin, IVER_g_szCoinName));
	 	pPlayer.PlayerLog(Log.emKPLAYERLOG_TYPE_PROMOTION, string.format("奇真阁消费%s，获得%s绑定%s", IVER_g_szCoinName, nBindCoin, IVER_g_szCoinName));
	end
	
	return 1;
end


function IbShop:GetEventExCoin(pPlayer, nCount)
	local nCurExCount = 0;
	
	--前30次每次500金币多返还300绑定金币；加上前面返还即前15000金币返还15000绑金;后面返还20%
	if self.EventOpen == 2 then
		local nExCount = pPlayer.GetTask(TASK_PROMOTION_TASKID, 6);
		nCurExCount = nCount;
		if nExCount + nCount > 30 then
			nCurExCount = (30 - nExCount);
		end
		if nCurExCount < 0 then
			nCurExCount = 0;
		end
	end
	
	return nCurExCount * 500 + (nCount - nCurExCount)*GIVEBACKBINDCOIN;
end

function IbShop:VipReturn(pPlayer, nTotalCoin)
	if (not pPlayer or nTotalCoin <= 0) then
		return 0;
	end
	VipPlayer:VipReturnBindCoin(pPlayer, nTotalCoin);
end

--- 接受gc数据
function IbShop:OnRecConnectMsg(strWareIndex, bAddOrDel)
	if not self.WaraItemSaleStatus then
		self.WaraItemSaleStatus = {}
	end
	if not bAddOrDel or bAddOrDel == 1 then
		self.WaraItemSaleStatus[strWareIndex] = 1
	else
		self.WaraItemSaleStatus[strWareIndex] = nil
	end
end

--获取本服热销商品列表,by Egg
function IbShop:GetFavoriteGoodsList(nCurrencyType)
	if not nCurrencyType then
		return {};
	end
	if nCurrencyType == 0 then
		 return self.tbCoinList,#self.tbCoinList;
	elseif nCurrencyType == 2 then
		 return self.tbBindCoinList,#self.tbBindCoinList;
	end
	return {},0;
end

--接受gc同步过来的热销商品列表,by Egg
function IbShop:OnSyncFavoriteFavorite(tbList,nCurrencyType)
	local tbSyncList = tbList or {};
	self.tbCoinList = self.tbCoinList or {};
	self.tbBindCoinList = self.tbBindCoinList or {};
	if nCurrencyType == 0 then
		self.tbCoinList = tbSyncList;
	elseif nCurrencyType == 2 then
		self.tbBindCoinList = tbSyncList;
	end	
end


--获取热销产品的数量,by Egg
function IbShop:GetFavoriteGoodsCount(nCurrencyType)
	if not nCurrencyType then
		return 0;
	end
	if nCurrencyType == 0 then
		return #self.tbCoinList;
	elseif nCurrencyType == 2 then
		return #self.tbBindCoinList;
	end
	return 0; 
end


--绑金区不会有购买成功回调,单独的入口
function IbShop:OnBindCoinBuyRet(pPlayer, nWareId,nCurrencyType,nItemCount)		
	--增加热销商品购买次数
	GCExcute{"IbShop:AddFavoriteGoodsTimes",nCurrencyType,nItemCount,nWareId};
	--奇珍阁log
	local tbWareInfo = pPlayer.IbShop_GetWareInf(nWareId);
	local szGDPL = string.format("%s-%s-%s-%s", tbWareInfo.nGenre, tbWareInfo.nDetailType, tbWareInfo.nParticular, tbWareInfo.nLevel);
	StatLog:WriteStatLog("stat_info", "qizhenge", "purchase", pPlayer.nId, string.format("%s,%s,%s,%s,%s", szGDPL, nWareId, nItemCount, nCurrencyType, tbWareInfo.nCurPrice));
end


--gc启动好会进行同步，但是不能保证gs启动完成,所以在gs启动后，向gc发送同步请求,by Egg
function IbShop:RequireGCSyncFavoriteGoodsList()
	GCExcute{"IbShop:SyncFavoriteGoodsToGS"};
end

--注册server启动回调
ServerEvent:RegisterServerStartFunc(IbShop.RequireGCSyncFavoriteGoodsList,IbShop);


----------test--
--清空热销列表,并且同步
function IbShop:ClearFavoriteList()
	GCExcute{"IbShop:ClearFavoriteListGC"};
end

--清空个人最近购买列表
function IbShop:ClearRecentWareList()
	for i = 1,15 do
	    me.SetTask(2165,i,0);
	    me.SetTask(2166,i,0);
	end
end

--绑银返还
function IbShop:ReturnBindMoney(pPlayer, nTotalCoin)
	local nTotalCoin = nTotalCoin *1000;
	local nReturnNum = pPlayer.GetTask(TASK_PROMOTION_TASKID, TASK_BindMoney_Id);
	if  nReturnNum <= 0 or nTotalCoin <= 0 then
		return;
	end	
	local nReturnNumEx = math.min(nReturnNum, nTotalCoin);	
	if pPlayer.GetBindMoney() + nReturnNumEx > pPlayer.GetMaxCarryMoney()  then
		pPlayer.Msg("您的绑银携带量过多，暂时不能返还，也不会扣除您的返还额度。");
		return;
	end
	pPlayer.AddBindMoney(nReturnNumEx);
	pPlayer.SetTask(TASK_PROMOTION_TASKID, TASK_BindMoney_Id, nReturnNum - nReturnNumEx);	
	pPlayer.Msg(string.format("恭喜您获得额外绑银返还%s，您的额外绑银返还点还剩余%s点", nReturnNumEx, nReturnNum - nReturnNumEx));
	StatLog:WriteStatLog("stat_info", "tuiguang", "money_restore", pPlayer.nId, nReturnNumEx);
	Dbg:WriteLog("ReturnBindMoney", nReturnNumEx, pPlayer.szAccount, pPlayer.szName, "奇珍阁返还");
end

