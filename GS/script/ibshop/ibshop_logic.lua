-- 文件名　：ibshop_logic.lua
-- 创建者　：付瑞磊
-- 创建时间：2009-09-28 10:49:00
-- 说明： client,gameserver,gamecenter公用逻辑文件


-- 在存在优惠券的情况下计算物品的总价值
-- 传入参数：进行过打折处理的商品类型数目和对应商品信息{{nWareId（商品id）, nCount（数量）}, ...}，是否消耗优惠券
-- 返回结果：进行过打折的物品id，数量以及打的折扣（注意：打的折扣是0.01的倍数）
-- 			 {{nWareId = XXX, nDiscountCount = XXX, nRebate = XXX}, ...}
-- 注意：在本方法内需要用到物品的话，可以通过me.IbShop_GetWareInf(nWareId)来获取gdpls，然后用KItem.CreateTempItem(...)生成商品
function IbShop:CalculateAmount(tbWareList, bUse)
	if (not tbWareList or Lib:CountTB(tbWareList) == 0 ) then
		return;
	end
	
	assert(it);
	
	bUse = bUse or 0;
	local tbRet = {};
	
	local pVoucher = KItem.GetObjById(it.dwId);
	if (not pVoucher) then
		return;
	end
	local tbItemCanuseVoucher = {};
	local nDiscountRate = pVoucher.GetExtParam(2);	-- 优惠券的折扣，在extparam2里面配置
	for _, tbWareInfo in pairs(tbWareList) do
		-- 只有在优惠券的折扣比原来折扣低的时候，才使用优惠券进行打折
		if (nDiscountRate < tbWareInfo.nDiscountRate) then
			table.insert(tbItemCanuseVoucher, tbWareInfo);
		end
	end
	if (Lib:CountTB(tbItemCanuseVoucher) <= 0) then
		return;
	end
	
	local tbRet = Item:CalDiscount(it.szClass, tbItemCanuseVoucher);
	
	--消耗优惠券次数
	if bUse ~= 0 then
		local szVoucher = it.szName;
		local nRes = Item:DecreaseCouponTimes(it.szClass, tbRet);

		self:WriteLog(szVoucher, nRes, tbRet);

		if nRes == 0 then
			return 0, {};
		end
	end
	
	return Lib:CountTB(tbRet), tbRet;
end


-- 记录log
function IbShop:WriteLog(szVoucher, nRes, tbRet)
	local szLog = "";
	local szUseResult = (nRes == 0) and "失败" or "成功";
	szLog = string.format("扣除优惠券【%s】 %s ", szVoucher, szUseResult);
	if (0 == Lib:CountTB(tbRet)) then
		szLog = szLog .. "没有对任何物品进行优惠";
	else
		for _, tbInfo in pairs(tbRet) do
			local tbWareInfo = me.IbShop_GetWareInf(tbInfo[1]);
			local tbBaseProp = KItem.GetItemBaseProp(tbWareInfo.nGenre, tbWareInfo.nDetailType, tbWareInfo.nParticular,
														tbWareInfo.nLevel);
			local szWareName = tbBaseProp.szName;
			szLog = szLog .. string.format("对 %s 个 %s 打百分之 %s 的折扣",
											tbInfo[2], szWareName, tbInfo[3]);
		end
	end
	
	me.PlayerLog(Log.emKPLAYERLOG_TYPE_USEGOLDCOIN_APP, szLog);
end
if (MODULE_GC_SERVER) then

-- 每执行一条在线ibshop指令，把指令记录下来，方便gc关闭的时候存盘用
function IbShop:SaveIbshopCmd(tbCmd, bSave)
	if (not tbCmd or Lib:CountTB(tbCmd) <= 1) then
		return;
	end

	-- 如果只是单纯的修改折扣，那么如果折扣是100%的话就不用修改了
	if (not tbCmd.WareId) then
		return;
	end
	
	if (not self.tbIbshopCmdBuff) then
		self.tbIbshopCmdBuff = {};
	end
	
	-- 需要判断buff当中是否已经有了这条指令，如果没有可以直接写入
	-- 如果已经有了，里面的字段以后来的指令为准进行修改
	if (not self.tbIbshopCmdBuff[tbCmd.WareId]) then
		self.tbIbshopCmdBuff[tbCmd.WareId] = tbCmd;
	else			
		for szKeyName, szValue in pairs(tbCmd) do			
			self.tbIbshopCmdBuff[tbCmd.WareId][szKeyName] = szValue;			
		end		
	end
	
	if (bSave and bSave == 1) then
		IbShop:SaveBuf();
	end
	
	return 1;
end

-- gc启动时，执行从buff当中读取出的指令
function IbShop:ExecuteIbshopCmdBuf(tbIbshopCmdBuff)
	if (not tbIbshopCmdBuff or Lib:CountTB(tbIbshopCmdBuff) == 0) then
		return;
	end
	for _, tbCmd in pairs(tbIbshopCmdBuff) do
		if (self.tbPreloadWareInfo[tbCmd["WareId"]]) then
			ModifyIBWare(tbCmd);
		end
	end
end

end -- if (MODULE_GC_SERVER) then

function IbShop:ParseTime(szTime)	
	local tb1 = Lib:SplitStr(szTime, " ");
	local szTime = "";
	for _, v in ipairs(tb1) do
		szTime = szTime .. v;
	end
	local tb2 = Lib:SplitStr(szTime, "-");
	local szTime = "";
	for _, v in ipairs(tb2) do
		szTime = szTime .. self:ParseFormat(v);
	end
	local tb3 = Lib:SplitStr(szTime, ":");
	local szTime = "";
	for _, v in ipairs(tb3) do
		szTime = szTime .. self:ParseFormat(v);
	end
	return tonumber(szTime);
end

function IbShop:ParseFormat(szTime)
	if (string.len(szTime) < 2) then
		szTime = string.format("%s%s", 0, szTime);
	end
	return szTime;
end

--gc和gs公用的判断是否上架接口
function IbShop:CheckIsOnSale(nWareId, nLevel, nCurrencyType, nStartSaleDay, nEndSaleDay,nTimeSaleStart,nTimeSaleClose)
	local strIndex = tostring(nWareId) .. ',' ..tostring(nLevel) .. ','..tostring(nCurrencyType)
	
	local nDate_ServerStart = KGblTask.SCGetDbTaskInt(DBTASD_SERVER_STARTTIME);
	local nDate_NowTime 	= GetTime();
	
	if nDate_ServerStart == nil then
		return 0;
	end
	
	if nTimeSaleStart and nTimeSaleStart ~= 0 and nDate_NowTime < nTimeSaleStart then
		return 0;
	end
	
	if nTimeSaleClose and nTimeSaleClose ~= 0 and nDate_NowTime > nTimeSaleClose then
		return 0;
	end
	
	if nStartSaleDay == 0 and nEndSaleDay == 0 then
		return 1
	end

	local nStartTime = nDate_ServerStart + ((nStartSaleDay - 1) * 86400);
	local nEndTime = 0;
	if nEndSaleDay or nEndSaleDay > 0 then
		nEndTime = nDate_ServerStart + ((nEndSaleDay - 1) * 86400);
	end
	if nDate_NowTime >= nStartTime and (nEndTime == 0 or nDate_NowTime < nEndTime) then
		return 1;
	end
	return 0;
end