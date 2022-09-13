-- 文件名　：spreader_gs.lua
-- 创建者　：xiewen
-- 创建时间：2008-12-29 16:15:01

Require("\\script\\spreader\\spreader_def.lua")

if not MODULE_GAMESERVER then
	return
end

local szWareListPath = "\\setting\\ibshop\\warelist.txt";
local szNonIbItemCongfig = "\\setting\\spreader\\non_ib_item.txt";

Spreader.tbIbItem = {};						-- IB物品
Spreader.tbNonIbItem = {};				-- 非IB物品

Spreader.tbLittleConsumeCache = {};	-- 小额消耗缓存

function Spreader:CalBitByGDPL(nG, nD, nP, nL)
	--nLevel占0-5位，nParticular占6-15位, nDetailType占16-25位，nGenre占26-31位
	--不够用,改用链接
	local szIndex = string.format("%d,%d,%d,%d", nL, nP, nD, nG);
	return szIndex;
end

function Spreader:LoadWareListSetting()
	local tbWareListSetting = Lib:LoadTabFile(szWareListPath);
	-- 加载IB列表配置
	for nRow, tbRowData in pairs(tbWareListSetting) do
		local nGenre = tonumber(tbRowData["nGenre"]);
		local nDetailType = tonumber(tbRowData["nDetailType"]);
		local nParticular = tonumber(tbRowData["nParticular"]);
		local nLevel = tonumber(tbRowData["nLevel"]);
		local nCurrencyType = tonumber(tbRowData["nCurrencyType"]);
		
		--nLevel占0-5位，nParticular占6-15位, nDetailType占16-25位，nGenre占26-31位
		local szIndex = self:CalBitByGDPL(nGenre, nDetailType, nParticular, nLevel);
		
		if szIndex and nCurrencyType and nCurrencyType == 0 then
			local nConsumed = tonumber(tbRowData["Consumed"]) or 0;
			self.tbIbItem[szIndex] = nConsumed;
		end
	end
end

function Spreader:LoadNonIbItemConfig()
	local tbNonIbItemCongfig = Lib:LoadTabFile(szNonIbItemCongfig);
	
	-- 加载非IB类消耗物品配置
	for nRow, tbRowData in pairs(tbNonIbItemCongfig) do
		local nGenre = tonumber(tbRowData["nGenre"]);
		local nDetailType = tonumber(tbRowData["nDetailType"]);
		local nParticular = tonumber(tbRowData["nParticular"]);
		local nLevel = tonumber(tbRowData["nLevel"]);
		
		local nBuyPrice = tonumber(tbRowData["nBuyPrice"]);
		local bCanBind = tonumber(tbRowData["bCanBind"]) or 0;
		
		--nLevel占0-5位，nParticular占6-15位, nDetailType占16-25位，nGenre占26-31位
		local szIndex = self:CalBitByGDPL(nGenre, nDetailType, nParticular, nLevel);
		
		self.tbNonIbItem[szIndex] = {};
		self.tbNonIbItem[szIndex].nBuyPrice = nBuyPrice;
		self.tbNonIbItem[szIndex].bCanBind = bCanBind;
	end
end

function Spreader:OnItemConsumed(nCount, nCosumeMode)
	
	-- 卖店/叠加等消耗途径不算
	if (nCosumeMode == self.emITEM_CONSUMEMODE_SELL or
		nCosumeMode < self.emITEM_CONSUMEMODE_REALCONSUME_START or
		nCosumeMode > self.emITEM_CONSUMEMODE_REALCONSUME_END)
	then
		return
	end
	local nItConsumed, szMsg, bWriteLog = Spreader:CalcCosumeValue(nCount, nCosumeMode, 1);	
	self:IbShopAddConsume(nItConsumed);	
	if bWriteLog == 1 then
		Dbg:WriteLog("Spreader:OnIBShopItemConsumed","奇珍阁消耗记录：",self.ZoneGroup or self:ExtractZoneGroup(), me.szAccount, me.szName, szMsg);		
		me.PlayerLog(Log.emKPLAYERLOG_TYPE_SPREADER, string.format("购买[%s个%s]金币消耗[%s],累积消耗[%s],上月消耗[%s],本月消耗[%s]", nCount, it.szName, nItConsumed, me.GetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONEY), me.GetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONTH_LAST), Spreader:IbShopGetConsume()));
		StatLog:WriteStatLog("stat_info", "consume", "qizhenge", me.nId, nItConsumed);		
	end
	--if self:IsIntroducee(me) ~= 1 then
	--	return
	--end	-- Edited by zhoupf 2010.09.26
		
	local nItConsumed, szMsg, bWriteLog = Spreader:CalcCosumeValue(nCount, nCosumeMode, 0);
	local bResult = self:AddConsume(nItConsumed, nCount);
	if 1 == bResult and bWriteLog == 1 then
		Dbg:WriteLog("Spreader:OnItemConsumed","推广员消耗记录：",self.ZoneGroup or self:ExtractZoneGroup(), me.szAccount, szMsg);
	end
end

-- 计算消耗值
function Spreader:CalcCosumeValue(nCount, nCosumeMode, bIsIbShop)
	--nLevel占0-5位，nParticular占6-15位, nDetailType占16-25位，nGenre占26-31位
	local nIndex = self:CalBitByGDPL(it.nGenre, it.nDetail, it.nParticular, it.nLevel);
	local nItConsumed = 0;
	local szMsg = "Không xác định";
	local bWriteLog = 0;
	if it.IsIbItem() == 1 then
		if (nCosumeMode == self.emITEM_CONSUMEMODE_EXPIREDTIMEOUT or	--保值期到
			nCosumeMode == self.emITEM_CONSUMEMODE_USINGTIMEOUT)		--物品超时
		then
			-- 过期删除可以按原价
			nItConsumed =  it.nBuyPrice * nCount;
			szMsg = string.format("[%s]的Ib物品[%s]%d个,因过期删除,添加消耗记录[%s]", me.szName, it.szName, nCount, nItConsumed);
			bWriteLog = 1;
		else
			-- Ib物品普通消耗（因为有些物品不是按原价计算消耗，所以都乘以一个百分比）
			if self.tbIbItem[nIndex] then
				nItConsumed = it.nBuyPrice * nCount * self.tbIbItem[nIndex] / 100;
				if bIsIbShop == 1 then
					nItConsumed = it.nBuyPrice * nCount;
				end
				szMsg = string.format("[%s]正常消耗Ib物品[%s]%d个,添加消耗记录[%s]",me.szName, it.szName, nCount, nItConsumed)
				bWriteLog = 1;
			end
		end

	elseif bIsIbShop ~= 1 then
		-- 非Ib物品
		--if it.IsBind() == 0 and self.tbNonIbItem[nIndex] then
		if self.tbNonIbItem[nIndex] and it.IsBind() <= self.tbNonIbItem[nIndex].bCanBind then
			nItConsumed = self.tbNonIbItem[nIndex].nBuyPrice * nCount;
			szMsg = string.format("[%s]使用非Ib物品[%s]%d个，添加消耗记录[%s]", me.szName, it.szName, nCount, nItConsumed)
			bWriteLog = 1;
		end
	end
	-- me.Msg(it.IsIbItem().."-"..szMsg.."-"..bWriteLog)
	return nItConsumed, szMsg, bWriteLog;
end

--减少奇珍阁消耗积分(不做大于校验，外层接口自己判断)
function Spreader:DecConsume(nItConsumed)
	Spreader:IbShopGetConsume();
	me.SetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONEY, self:GetConsumeMoney() - nItConsumed);
end

--奇珍阁消耗统计
function Spreader:IbShopAddConsume(nItConsumed, nFlag, pPlayer)
	if nItConsumed <= 0 then
		return 0;
	end	
	local nTotleConSume = Spreader:IbShopGetConsume(pPlayer) + nItConsumed;
	me.SetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_COSUME, nTotleConSume);
	
	--2011年4月份才开始累计的
	local nBatch = me.GetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONEY_BATCH);
	if nBatch ~= 1 then	--没有累积之前的消耗值的时候 = 总累计（累积到上个月） + 本月当前值
		me.SetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONEY, me.GetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONTH_ALL) + nTotleConSume);
		me.SetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONEY_BATCH, 1);
	else
		me.SetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONEY, me.GetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONEY) + nItConsumed);
	end
	----2011年4月份才开始累计的end
	if not nFlag then
		--额外返还积分
		local nOther = me.GetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_OTHER);	
		if nOther > 0 and nOther <= nItConsumed then
			me.SetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONEY, me.GetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONEY) + nOther);
			me.SetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_OTHER, 0);
			me.Msg(string.format("恭喜您获得%s点额外商城积分返还，您的额外商城积分返还剩余%s点", nOther, 0));
		elseif nOther > nItConsumed then
			me.SetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONEY, me.GetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONEY) + nItConsumed);
			me.SetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_OTHER, nOther - nItConsumed);
			me.Msg(string.format("恭喜您获得%s点额外商城积分返还，您的额外商城积分返还剩余%s点", nItConsumed, nOther - nItConsumed));
		end
		--额外返还积分end
	end
	
	--Log 每月消耗过多>充值额10倍，警告
	if (me.GetExtMonthPay() >= 50 and  nTotleConSume > me.GetExtMonthPay() * 1000) or (me.GetExtMonthPay() < 50 and nTotleConSume > 50000) then
		Dbg:WriteLog("Spreader:OnIBShopItemConsumed","奇珍阁消耗异常stack",self.ZoneGroup or self:ExtractZoneGroup(), me.szAccount, me.szName, "当月消耗"..nTotleConSume,"当月充值"..me.GetExtMonthPay());
	end
	
	SpecialEvent.tbTequan:OnIbShopConsumed(nItConsumed);
	
	return 1;
end

--获取个人总的消耗值
function Spreader:GetAllConsume()
	return Spreader:IbShopGetConsume() + me.GetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONTH_ALL);
end

--获取个人上个月消耗值
function Spreader:GetLastMonthConsume()
	Spreader:IbShopGetConsume();
	return me.GetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONTH_LAST);
end

--获得个人积分货币
function Spreader:GetConsumeMoney()
	return me.GetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONEY);
end

--获得当月的消耗值
function Spreader:IbShopGetConsume(pPlayer)
	if pPlayer then
		me = pPlayer;
	end
	local nMonth	= me.GetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONTH);
	local nConsume = me.GetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_COSUME);
	local nCurMonth = tonumber(GetLocalDate("%Y%m"));
	if nMonth < nCurMonth then
		me.SetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONTH, nCurMonth);
		me.SetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONTH_LAST, nConsume);
		me.SetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_COSUME, 0);
		me.SetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONTH_ALL, me.GetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONTH_ALL) + nConsume);
		Dbg:WriteLog("Spreader:IbShopGetConsume", "换月消耗记录：", me.szAccount, nConsume);
	end
	--货币积分
	--每年请一次积分
	local nNowYear = tonumber(GetLocalDate("%Y")) - 2011;
	local nYear = me.GetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONEY_YEAR);
	if nNowYear >= 0 and nYear ~= nNowYear then
		local nLastYear = me.GetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONTH_ALL);
		local nMoney = me.GetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONEY);
		me.SetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONEY, 0);
		me.SetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONEY_YEAR, nNowYear);
		me.SetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONEY_LASTYEAR, nLastYear);
		me.SetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_MONTH_ALL, 0);
		Dbg:WriteLog("Spreader:IbShopGetConsume", "换年消耗记录：", me.szAccount, nMoney, nLastYear, nNowYear);
	end
	--每年请一次积分end	
	return me.GetTask(self.TSK_IBSHOP_GOURP, self.TSK_IBSHOP_COSUME);
end
-- 装备绑定计算消耗
function Spreader:OnItemBound(pItem)

	if pItem and pItem.nBuyPrice > 0 then
		Setting:SetGlobalObj(nil, nil, pItem);
		local nResult = self:AddConsume(pItem.nBuyPrice, 1)
		Setting:RestoreGlobalObj()
		if 1 == nResult then
			Dbg:WriteLog("Spreader:OnItemBound",
				"推广员消耗记录：",
				self.ZoneGroup or self:ExtractZoneGroup(),
				me.szAccount,
				string.format("[%s]绑定装备[%s],添加消耗记录[%s]",
				 me.szName, pItem.szName, tostring(pItem.nBuyPrice))
				);
		end
		pItem.nBuyPrice = 0	-- 防止装备发生删除时又加一次消耗
	end
end

-- 勾魂玉的特殊处理
function Spreader:OnGouhunyuRepute(nReputeAdded)
	if not nReputeAdded or nReputeAdded <= 0 then
		return
	end
	
	local nConsume = nReputeAdded / 102; -- 102是一个勾魂玉能得到的令牌声望均值
	local nResult = self:AddConsume(self.GOUHUNYU * nConsume, 1);
	
	if (1 == nResult) then
		Dbg:WriteLog("Spreader:OnGouhunyuRepute",
			"推广员消耗记录：",
			self.ZoneGroup or self:ExtractZoneGroup(),
			me.szAccount,
			string.format("[%s]使用勾魂玉，得到声望[%d], 添加消耗记录[%s]", 
				me.szName, nReputeAdded, tostring(self.GOUHUNYU * nConsume))
		);
	end
end
Spreader.tbStudioScoreLittleCache = Spreader.tbStudioScoreLittleCache or {};
-- 先缓存起来
function Spreader:AddConsume(fConsume, nItemCount, szItemName)
	if not fConsume or fConsume <= 0 then
		return 0;
	end
	
	-- 角色打分，用于区分工作室和正常玩家
	do
		local fTempCache = (self.tbStudioScoreLittleCache[me.nId] or 0) + fConsume;
		local nCoin = math.floor(fTempCache); -- 取证作为消耗金币数
		StudioScore:OnActivityFinish("__coin", me, nCoin);
		self.tbStudioScoreLittleCache[me.nId] = fTempCache - nCoin; -- 零头缓存起来
	end
	
	if self:IsIntroducee(me) ~= 1 then
		return 0;
	end
	
	local szConsumeLog = nil;
	if fConsume % 1 == 0 then
		szConsumeLog = string.format("%d", fConsume);
	else
		szConsumeLog = string.format("%0.4f", fConsume);
	end
	
	StatLog:WriteStatLog("stat_info", "consume", "spreader", me.nId, szConsumeLog, (szItemName or (it and it.szName or "未知")), nItemCount or 0);
	
	local fTempCache = self.tbLittleConsumeCache[me.nId] or 0
	
	fTempCache = fTempCache + fConsume
	
	if fTempCache > 1 then
		local nConsumeCached = me.GetTask(self.TASK_GROUP, self.TASKID_CONSUME)
		me.SetTask(self.TASK_GROUP, self.TASKID_CONSUME, nConsumeCached + fTempCache)
		
		self.tbLittleConsumeCache[me.nId] = fTempCache - math.floor(fTempCache);
	else
		-- 小于1的
		self.tbLittleConsumeCache[me.nId] = fTempCache
	end
		
	return 1;
end

-- 是否由 推广员/老玩家 介绍来的
function Spreader:IsIntroducee(pPlayer)	
	if self:_IsIntroducee_Spreader(pPlayer) == 1 then
		return 1
	else
		return 0
	end
end

function Spreader:_IsIntroducee_Spreader(pPlayer)
	local nExt = pPlayer.GetExtPoint(6)
	if KLib.BitOperate(nExt, "&", 1) == 1 then
		return 1
	else
		return 0
	end	
end

-- 将玩家消耗发送到GC
function Spreader:Flush(pPlayer)
	local nConsume = pPlayer.GetTask(self.TASK_GROUP, self.TASKID_CONSUME)		-- 取总消耗量
	
--	-- 记录小额消耗的临时表
--	local fConsumeToAdd = self.tbLittleConsumeCache[pPlayer.nId] or 0
--	nConsume = nConsume + fConsumeToAdd
	self.tbLittleConsumeCache[pPlayer.nId] = nil
	
	local nConsumeToSend = math.floor(nConsume / self.ExchangeRate_Rmb2Gold)	-- 只取百位以上的
	local nCharge = me.GetExtPoint(2) 																				-- 取扩展点上累计充值余额￥
	local nLaoWanJia = EventManager.ExEvent.tbPlayerCallBack:CheckIsConsumeRelation(pPlayer);  -- 2009-3-9增加：老玩家召回活动

	if nCharge <= nConsumeToSend then
		nConsumeToSend = nCharge					-- 两者中取小
	end
	if nConsumeToSend > 0 then
		me.PayExtPoint(2, nConsumeToSend) -- 扣除累计充值额
		
		pPlayer.SetTask(self.TASK_GROUP,
			self.TASKID_CONSUME,
			nConsume - nConsumeToSend * self.ExchangeRate_Rmb2Gold)

		if nLaoWanJia == 1 then
			
			local nRealConsume = nConsumeToSend * self.ExchangeRate_Rmb2Gold;
			local nRate		= EventManager.ExEvent.tbPlayerCallBack:GetConsumeRate(pPlayer);
			nRealConsume	= math.floor(nRealConsume * nRate);	

			SendSpreaderConsume(self.ZoneGroup or self:ExtractZoneGroup(),
				pPlayer.szAccount,
				pPlayer.szName,
				nRealConsume,
				pPlayer.nId,
				self.emKTYPE_REDUX_PLAYER)
				
			Dbg:WriteLog("Spreader:Flush",
				"老玩家活动：",
				self.ZoneGroup or self:ExtractZoneGroup(),
				pPlayer.szAccount,
				pPlayer.szName,
				nRealConsume)
		end

		if self:_IsIntroducee_Spreader(pPlayer) == 1 then
			SendSpreaderConsume(self.ZoneGroup or self:ExtractZoneGroup(),
				pPlayer.szAccount,
				pPlayer.szName,
				nConsumeToSend * self.ExchangeRate_Rmb2Gold,
				pPlayer.nId,
				self.emKTYPE_SPREADER)
			
	
			Dbg:WriteLog("Spreader:Flush",
				"推广员消耗记录：",
				self.ZoneGroup or self:ExtractZoneGroup(),
				pPlayer.szAccount,
				pPlayer.szName,
				nConsumeToSend * self.ExchangeRate_Rmb2Gold)
		end
	end
end

-- 从gateway名中提取区服名
function Spreader:ExtractZoneGroup()
	return GetZoneName();
end

-- 玩家下线后消费记录发送到GC
function Spreader:OnPlayerLogout()
	Spreader:Flush(me)
end

if not Spreader.LogoutHandlerId then
	Spreader.LogoutHandlerId = PlayerEvent:RegisterGlobal("OnLogout", Spreader.OnPlayerLogout, Spreader)
end

Spreader:LoadWareListSetting();
Spreader:LoadNonIbItemConfig();
