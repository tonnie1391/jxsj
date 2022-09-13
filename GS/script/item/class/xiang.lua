
-- 箱

------------------------------------------------------------------------------------------
-- initialize

local tbXiang = Item:GetClass("xiang");

--取出后箱子绑定类
tbXiang.tbTakeOutBind = {
	["18,1,530,1"] = 1,
}

------------------------------------------------------------------------------------------
-- public

-- 箱子GenInfo各意义参数索引
local PARAM_IDX_GENRE		= 1;
local PARAM_IDX_DETAILTYPE	= 2;
local PARAM_IDX_PARTICULAR	= 3;
local PARAM_IDX_LEVEL		= 4;
local PARAM_IDX_SERIES		= 5;
local PARAM_IDX_NUM			= 6;
local PARAM_IDX_BIND		= 7;

-- 获得最大物品数
function tbXiang:GetMaxItemCount(pItem)
	return pItem.GetExtParam(PARAM_IDX_NUM)
end

-- 获得箱内剩余物品数
function tbXiang:GetRemainItemCount(pItem)
	return pItem.GetGenInfo(1);
end

--箱子是否满
function tbXiang:IsFull(pItem)
	return self:GetMaxItemCount(pItem) == self:GetRemainItemCount(pItem) and 1 or 0;
end

function tbXiang:InitGenInfo()
	return	{ it.GetExtParam(PARAM_IDX_NUM) };
end

tbXiang.tbCanPutBack = {[241]=1,[242]=1,[243]=1,[352]=1,[353]=1,[354]=1,[56]=1,[57]=1,[58]=1,[59]=1,[60]=1,[61]=1,[62]=1,[63]=1,[64]=1,
						[273]=1,[274]=1,[275]=1,[1344]=1,[1345]=1,[1346]=1,[1783]=1,[1784]=1,[1785]=1};

-- 可否把药放回去
-- 可以：1
-- 不可以：0
function tbXiang:CanPutBack(pItem)
	if not pItem then
		return 0;
	end
		
	if self.tbCanPutBack[pItem.nParticular] then
		return 1;
	else
		return 0;
	end
end
-- 返回值：	0不删除、1删除
function tbXiang:OnUse()

	-- modify by zhangjinpin@kingsoft
	--if it.nParticular < 241 or it.nParticular > 243 then
		--return self:OnUseGet(it.dwId);
	--end
	
	if self:CanPutBack(it) == 0 then
		return self:OnUseGet(it.dwId);
	end

	local tbOpt = {
		{"Lấy vật phẩm", self.OnUseGet, self, it.dwId},
		{"Cất vật phẩm", self.OnUsePut, self, it.dwId},
		{"Để ta suy nghĩ thêm"},
	}
	
	Dialog:Say("Hãy chọn thao tác", tbOpt);
	return	0;
end

function tbXiang:OnUseGet(nItemId)
	
	local pItem = KItem.GetObjById(nItemId);
	
	if not pItem then
		return 0;
	end
	
	-- 保存箱子的Id
	local tbTmpTask = me.GetTempTable("Item");
	--tbTmpTask.pItemXiang = pItem;
	tbTmpTask.dwId 		 = pItem.dwId;
	-- 计算最多取出数量
	local nMaxTakeOutCount = pItem.GetGenInfo(1);
	local nGenre 	  = pItem.GetExtParam(PARAM_IDX_GENRE);
	local nDetail 	  = pItem.GetExtParam(PARAM_IDX_DETAILTYPE);
	local nParticular = pItem.GetExtParam(PARAM_IDX_PARTICULAR);
	local nLevel	  = pItem.GetExtParam(PARAM_IDX_LEVEL);
	local nSeries	  = pItem.GetExtParam(PARAM_IDX_SERIES);
	local tbBaseProp = KItem.GetItemBaseProp(nGenre, nDetail, nParticular, nLevel);
	
	if not tbBaseProp then
		return	0;
	end

	local nFreeItemCount = me.CalcFreeItemCountInBags(
		nGenre,
		nDetail,
		nParticular,
		nLevel,
		nSeries,
		KItem.IsItemBindByBindType(tbBaseProp.nBindType)
	);
	local tbTimeOut = me.GetItemAbsTimeout(pItem);
	if tbTimeOut then
		nFreeItemCount = me.CountFreeBagCell();
	end	
	if nFreeItemCount <= 0 then
		me.Msg("Túi không đủ chỗ, hãy sắp xếp lại.");
		return 0;
	end
	
	if tbBaseProp.szClass == "localmedicine" then
		local nMaxLocal = me.CalFreeLocalMedicineCountInBags();
		if nMaxLocal < nMaxTakeOutCount then
			nMaxTakeOutCount = nMaxLocal;
		end
	else
		if tbBaseProp.szClass == "fulimedicine" then
			local nTempMax = me.CalFreeLocalMedicineCountInBags();
			if nTempMax < nFreeItemCount then
				nFreeItemCount = nTempMax;
			end
		end
		
		if (nFreeItemCount < nMaxTakeOutCount) then
			nMaxTakeOutCount = nFreeItemCount;
		end
	end
	-- 只有药箱且在非战斗状态下才能顺开
	if (me.nFightState == 0) then
		self:OnUseAskCount(nMaxTakeOutCount);
		return 0;
	end
	
	
	-- 启动进度条
	local tbBreakEvent = 
	{
		Player.ProcessBreakEvent.emEVENT_MOVE,
		Player.ProcessBreakEvent.emEVENT_ATTACK,
		Player.ProcessBreakEvent.emEVENT_SIT,
		Player.ProcessBreakEvent.emEVENT_RIDE,
		Player.ProcessBreakEvent.emEVENT_USEITEM,
		Player.ProcessBreakEvent.emEVENT_ARRANGEITEM,
		Player.ProcessBreakEvent.emEVENT_DROPITEM,
		Player.ProcessBreakEvent.emEVENT_CHANGEEQUIP,
		Player.ProcessBreakEvent.emEVENT_SENDMAIL,		
		Player.ProcessBreakEvent.emEVENT_TRADE,
		Player.ProcessBreakEvent.emEVENT_CHANGEFIGHTSTATE,
		Player.ProcessBreakEvent.emEVENT_ATTACKED,
		Player.ProcessBreakEvent.emEVENT_DEATH,
		Player.ProcessBreakEvent.emEVENT_LOGOUT,
		Player.ProcessBreakEvent.emEVENT_REVIVE,
		Player.ProcessBreakEvent.emEVENT_CLIENTCOMMAND,
	}
	GeneralProcess:StartProcess("Đang mở "..pItem.szName.."...", 10 * Env.GAME_FPS, {self.OnUseAskCount, self, nMaxTakeOutCount}, nil, tbBreakEvent);
	return 0;
end

function tbXiang:OnUseAskCount(nMaxTakeOutCount)
	Dialog:AskNumber("Nhập số lượng:", nMaxTakeOutCount, self.OnUseTakeOut, self);
end

function tbXiang:OnUseTakeOut(nTakeOutCount)

	local tbTmpTask = me.GetTempTable("Item");
	local nItemId = tbTmpTask.dwId;
	local pItem = KItem.GetObjById(nItemId);
	if (pItem == nil or pItem.szClass ~= "xiang") then
		return;
	end
	
	if me.IsHaveItemInBags(pItem) ~= 1 then
		return;
	end
	
	if not tonumber(nTakeOutCount) or nTakeOutCount <= 0 then
		return;
	end
	
	local nCanUse = KItem.CheckLimitUse(me.nMapId, KItem.GetOtherForbidType(unpack(pItem.TbGDPL())));
	if (not nCanUse or nCanUse == 0) then
		me.Msg("Vật phẩm bị cấm sử dụng ở bản đồ hiện tại!");
		return;
	end

	local tbTimeOut = me.GetItemAbsTimeout(pItem);
	
	-- 备份箱里物品的Id先，因为箱可能会被删除
	local nElemGenre 		= pItem.GetExtParam(PARAM_IDX_GENRE);
	local nElemDetailType 	= pItem.GetExtParam(PARAM_IDX_DETAILTYPE);
	local nElemParticular 	= pItem.GetExtParam(PARAM_IDX_PARTICULAR);
	local nElemLevel 		= pItem.GetExtParam(PARAM_IDX_LEVEL);
	local nElemSeries 		= pItem.GetExtParam(PARAM_IDX_SERIES);
	local nElemBind			= pItem.GetExtParam(PARAM_IDX_BIND);
	
	if nElemBind == 0 then
		nElemBind = pItem.IsBind();
	end
	if nElemBind == 2 then
		nElemBind = 0;
	end
	
	-- 计算取出数量
	local nElemCount = pItem.GetGenInfo(1);
	local nMaxTakeOutCount = pItem.GetGenInfo(1);
	local nFreeItemCount = me.CalcFreeItemCountInBags(
		pItem.GetExtParam(PARAM_IDX_GENRE),
		pItem.GetExtParam(PARAM_IDX_DETAILTYPE),
		pItem.GetExtParam(PARAM_IDX_PARTICULAR),
		pItem.GetExtParam(PARAM_IDX_LEVEL),
		pItem.GetExtParam(PARAM_IDX_SERIES),
		nElemBind
	);
	if nFreeItemCount <= 0 then
		me.Msg("Túi không đủ chỗ, hãy sắp xếp lại.");
		return 0;
	end
	
	if tbTimeOut then
		if me.CountFreeBagCell() < nTakeOutCount then
			me.Msg(string.format("Hành trang không đủ %s chỗ trống!", nTakeOutCount));
			return 0;
		end
	end
	local tbBaseProp = KItem.GetItemBaseProp(nElemGenre, nElemDetailType, nElemParticular, nElemLevel);
	if tbBaseProp then
		if tbBaseProp.szClass == "localmedicine" then
			local nMaxLocal = me.CalFreeLocalMedicineCountInBags();
			if nMaxLocal < nMaxTakeOutCount then
				nMaxTakeOutCount = nMaxLocal;
			end
		else
			if tbBaseProp.szClass == "fulimedicine" then
				local nTempMax = me.CalFreeLocalMedicineCountInBags();
				if nTempMax < nFreeItemCount then
					nFreeItemCount = nTempMax;
				end
			end
			
			if (nFreeItemCount < nMaxTakeOutCount) then
				nMaxTakeOutCount = nFreeItemCount;
			end
		end
	end
	
	if (nTakeOutCount > nMaxTakeOutCount) then
		nTakeOutCount = nMaxTakeOutCount;
	end
	
	local nRemainCount = nElemCount - nTakeOutCount;

	-- 设置箱物品剩余数量或者删除
	if (nRemainCount > 0) then
		pItem.SetGenInfo(1, nRemainCount);
		if pItem.IsBind() == 0 and self.tbTakeOutBind[pItem.nGenre..","..pItem.nDetail..","..pItem.nParticular..","..pItem.nLevel] then
			pItem.Bind(1);
		end
		pItem.Sync();
	else
		if (me.DelItem(pItem, Player.emKLOSEITEM_USE) ~= 1) then
			return;
		end
	end
	
	local szItemName = "";	
	-- 增加箱里物品
	for i = 1, nTakeOutCount do
		local tbInfo = {nSeries = nElemSeries, bForceBind = nElemBind};
		tbInfo.bMsg = 0;	--不通知,后面统一通知
		local nTimeout = 0;
		if tbTimeOut then
			tbInfo.bTimeOut = 1;
			local szTime = string.format("%02d%02d%02d%02d%02d", 			
					tbTimeOut[1],
					tbTimeOut[2],
					tbTimeOut[3],
					tbTimeOut[4],
					tbTimeOut[5]);
			nTimeout = Lib:GetDate2Time(szTime)
		end
		local pIt = me.AddItemEx(nElemGenre, nElemDetailType, nElemParticular, nElemLevel, tbInfo,nil,nTimeout);
		if szItemName == "" and pIt then
			szItemName = pIt.szName;
		end
	end
	if szItemName ~= "" then
		me.Msg("Nhận được " .. tostring(nTakeOutCount) .. " " .. szItemName .. "!","");
	end
end

function tbXiang:GetTip(nState)
	local szTip = "";
	szTip = szTip.."Bảo rương chứa <color=yellow>"..KItem.GetNameById(it.GetExtParam(PARAM_IDX_GENRE), it.GetExtParam(PARAM_IDX_DETAILTYPE), it.GetExtParam(PARAM_IDX_PARTICULAR), it.GetExtParam(PARAM_IDX_LEVEL)).."<color>, <color=yellow>Nhấp chuột phải<color> để mở rương.\n";
	szTip = szTip.."Trong rương còn: <color=green>"..it.GetGenInfo(1).."<color>";
	return	szTip;
end

-- UNDONE: Fanghao_Wu	临时代码，将药箱内药品数量*1.5，2008-9-1后删除！！！
function tbXiang:OnLoaded()
	if (it.nParticular < 28 or it.nParticular > 42) then
		return
	end
	local nFixStartTime = Lib:GetDate2Time(200807220800);
	if (it.dwGenTime < nFixStartTime and it.GetGenInfo(2) == 0) then
		local nElemCount = it.GetGenInfo(1);
		it.SetGenInfo(1, nElemCount * 1.5);
		it.SetGenInfo(2, nElemCount);
		it.Sync();
	end
end

function tbXiang:GetChangeable(pItem)
	if pItem.nMakeCost > 0 and pItem.IsBind() ~= 1 and pItem.GetExtParam(PARAM_IDX_NUM) == pItem.GetGenInfo(1) then
		return 1;
	else
		return 0;
	end
end

function tbXiang:OnCheckUsePutDel(nItemId, nDelCount)
	local pItem = KItem.GetObjById(nItemId);
	
	if not pItem then
		return 0;
	end
	local nType, nTime = pItem.GetTimeOut();
	
	--if pItem.nParticular < 241 or pItem.nParticular > 243 then
		--return 0;
	--end
	
	if self:CanPutBack(pItem) == 0 then
		return 0;
	end
	
	local nXiangCount = pItem.GetGenInfo(1);
	
	if not nXiangCount or nXiangCount >= self:GetMaxItemCount(pItem) then
		me.Msg("Rương đã đầy, không thể bỏ thêm vào!");
		return 0;
	end
	
	local nBind = pItem.IsBind();
	local tbFind = me.FindItemInBags(
		pItem.GetExtParam(PARAM_IDX_GENRE),
		pItem.GetExtParam(PARAM_IDX_DETAILTYPE),
		pItem.GetExtParam(PARAM_IDX_PARTICULAR),
		pItem.GetExtParam(PARAM_IDX_LEVEL),
		pItem.GetExtParam(PARAM_IDX_SERIES)
	);
	local nBagCount = 0;
	for _, tbItem in pairs(tbFind) do
		local pItem1 = tbItem.pItem;
		local nNeedItem = 1;
		local nType1, nTime1 = pItem1.GetTimeOut();
		
		if pItem1.IsBind() == nBind and nType1 == nType and 
			( (nTime > 0 and math.abs(nTime1 - nTime) <= 60) or nTime == nTime1 ) then
			if nDelCount and nDelCount > 0 and nBagCount < nDelCount then
				me.DelItem(pItem1);
			end
			nBagCount = nBagCount + 1;
		end
	end

	if not nBagCount or nBagCount <= 0 then
		me.Msg("你的背包中并没有此种药品。");
		return 0;
	end
	local nMaxPutCount = nBagCount;
	
	if nMaxPutCount + nXiangCount > self:GetMaxItemCount(pItem) then
		nMaxPutCount = self:GetMaxItemCount(pItem) - nXiangCount;
	end
	return nMaxPutCount;
end

function tbXiang:OnUsePut(nItemId)
	
	local nMaxPutCount = self:OnCheckUsePutDel(nItemId);
	
	if nMaxPutCount <= 0 then
		return;
	end
		
	Dialog:AskNumber("Nhập số lượng trả lại:", nMaxPutCount, self.OnUsePutExec, self, nItemId);
end

function tbXiang:OnUsePutExec(nItemId, nPutCount)
	
	local pItem = KItem.GetObjById(nItemId);
	
	if not pItem then
		return;
	end
	
	local nMaxPutCount = self:OnCheckUsePutDel(nItemId);
	if nMaxPutCount <= 0 or nMaxPutCount < nPutCount then
		return;
	end
	
	self:OnCheckUsePutDel(nItemId, nPutCount);
	
	local nXiangCount = pItem.GetGenInfo(1);
	pItem.SetGenInfo(1, nXiangCount + nPutCount);
	pItem.Sync();
end


