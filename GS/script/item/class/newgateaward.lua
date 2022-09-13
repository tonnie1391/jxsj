-- 文件名　：newgateaward.lua
-- 创建者　：jiazhenwei
-- 创建时间：2012-02-28 14:37:45
-- 功能    ：新服抽奖包(全服限制奖励项，限制工作室)

SpecialEvent.tbNewGateAward2012 = SpecialEvent.tbNewGateAward2012 or {};
local tbAward = SpecialEvent.tbNewGateAward2012;

--标志位(注意占位不能超了int的最大值)
tbAward.tbTemp = {
	[1] = {
		--占位, 占位，最大值，是否限制工作室
		[4] = {1, 2, 33, 1},
		[5] = {3, 4, 16, 1},
		[6] = {5, 5, 6, 1},
		[7] = {6, 6, 2, 1},
		[8] = {7, 7, 1, 1},
	},
};

--奖励
tbAward.tbAwardList = {
	[1] = {
		--概率，奖励info，类型
		[1] = {3500, 200000, "bindmoney"};		--绑银
		[2] = {3500, 1000, "bindcoin"};		--绑金
		[3] = {2500, 16, "times"};			--离线小时
		[4] = {300, {18,1,1343,2, 1, 30*24*60}, "item"};	--15元金山一卡通
		[5] = {150, {18,1,1343,6, 1, 30*24*60}, "item"};		--50元金山一卡通
		[6] = {35, {18,1,1343,7, 1, 30*24*60}, "item"};		--智能手机礼包
		[7] = {10, {18,1,1343,8, 1, 30*24*60}, "item"};		--数码摄像机礼包
		[8] = {5, {18,1,1343,9, 1, 30*24*60}, "item"};		--笔记本电脑礼包
	},	
};

--全局变量
tbAward.tbGlobalInt = {
	[1] = DBTASK_XIYULONGHUN_LOTTERY,
	}

if not MODULE_GC_SERVER then

local tbItem = Item:GetClass("NewGateAward");

function tbItem:OnUse()
	local nType = tonumber(it.GetExtParam(1)) or 0;
	local nLevel = tonumber(it.GetExtParam(2)) or 0;
	local nMonthPay = tonumber(it.GetExtParam(3)) or 0;
	if me.nLevel < nLevel then
		Dialog:Say(string.format("等级不足%s级，还不能使用。", nLevel));
		return 0;
	end
	if me.GetExtMonthPay() < nMonthPay then
		Dialog:Say(string.format("您当月充值不足%s元。", nMonthPay));
		return 0;
	end
	local nBindMoney, nNeedBag = SpecialEvent.tbNewGateAward2012:GetAwardInfo(nType);
	if me.GetBindMoney() + nBindMoney > me.GetMaxCarryMoney() then
		me.Msg("携带的银两达上限，请清理下再来。");
		return 0;
	end
	if me.CountFreeBagCell() < nNeedBag then
		me.Msg(string.format("Hành trang không đủ %s chỗ trống.", nNeedBag));
		return 0;
	end
	GCExcute({"SpecialEvent.tbNewGateAward2012:GetAward", me.nId, it.dwId, IpStatistics:CheckStudioRole(me), nType});
end

function tbAward:GetAwardInfo(nType)
	if not nType or not self.tbAwardList[nType] then
		return 0, 0;
	end
	local nBindMoney, nNeedBag = 0, 0;
	for i, tb in ipairs(self.tbAwardList[nType]) do		
		if tb[3] == "bindmoney" then
			nBindMoney = nBindMoney + tb[2];
		end
		if tb[3] == "item" then			
			nNeedBag = math.max(nNeedBag , math.min(tb[2][5], KItem.GetNeedFreeBag(tb[2][1], tb[2][2], tb[2][3], tb[2][4], nil,  tb[2][5])));			
		end
	end
	return nBindMoney, nNeedBag;
end

--失败
function tbAward:Failed(nPlayerId)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if pPlayer then
		pPlayer.Msg("道具有问题，请联系GM。");
		return;
	end
end

--获得奖励
function tbAward:Finsh(nPlayerId, nItemId, nType, nGrade)
	local pPlayer = KPlayer.GetPlayerObjById(nPlayerId);
	if not pPlayer then
		return;
	end
	local pItem  = KItem.GetObjById(nItemId);
	if not pItem then
		print("道具丢失");
		return;
	end
	if not nType or not self.tbAwardList[nType] or not self.tbAwardList[nType][nGrade] then
		pPlayer.Msg("道具异常，请联系Gm。");
		return;
	end
	if self.tbAwardList[nType][nGrade][3] == "bindmoney" then
		pPlayer.AddBindMoney(self.tbAwardList[nType][nGrade][2]);
	end
	if self.tbAwardList[nType][nGrade][3] == "bindcoin" then
		pPlayer.AddBindCoin(self.tbAwardList[nType][nGrade][2]);
	end
	if self.tbAwardList[nType][nGrade][3] == "times" then
		Setting:SetGlobalObj(pPlayer);
		Player.tbOffline:AddExOffLineTime(self.tbAwardList[nType][nGrade][2] * 60);
		Setting:RestoreGlobalObj();
		pPlayer.Msg("恭喜获得离线时间：<color=yellow>"..self.tbAwardList[nType][nGrade][2].."小时<color>")
	end
	if self.tbAwardList[nType][nGrade][3] == "item" then
		for i = 1, self.tbAwardList[nType][nGrade][2][5] do
			local pItem  = pPlayer.AddItem(self.tbAwardList[nType][nGrade][2][1], self.tbAwardList[nType][nGrade][2][2], self.tbAwardList[nType][nGrade][2][3], self.tbAwardList[nType][nGrade][2][4]);
			if pItem and self.tbAwardList[nType][nGrade][2][6] > 0 then
				pPlayer.SetItemTimeout(pItem, self.tbAwardList[nType][nGrade][2][6], 0);
			end
		end
	end
	pItem.Delete(pPlayer);
end

end

if (MODULE_GC_SERVER) then
	
function tbAward:GetAward(nPlayerId, nItemId, bStudio, nType)
	if not nType or not self.tbTemp[nType] or not self.tbAwardList[nType] or not self.tbGlobalInt[nType] then
		GlobalExcute({"SpecialEvent.tbNewGateAward2012:Failed", nPlayerId});
		return 0;
	end
	local nNum = KGblTask.SCGetDbTaskInt(self.tbGlobalInt[nType]);
	local tbRandom = {};
	local nRandomMax = 0;
	for i = 1, Lib:CountTB(self.tbAwardList[nType]) do
		if self.tbTemp[nType][i] then
			local nCount = self:GetBitNum(nNum, self.tbTemp[nType][i][1], self.tbTemp[nType][i][2]);
			if nCount < self.tbTemp[nType][i][3] then
				if self.tbTemp[nType][i][4] ~= 1 or bStudio ~= 1 then
					tbRandom[i] = self.tbAwardList[nType][i];
					nRandomMax = nRandomMax + self.tbAwardList[nType][i][1];
				end
			end
		else
			tbRandom[i] = self.tbAwardList[nType][i];
			nRandomMax = nRandomMax + self.tbAwardList[nType][i][1];
		end
	end
	local nRand = MathRandom(nRandomMax);
	local nRandIt = 0;
	for nGrade, tbList in pairs(tbRandom) do
		nRandIt = nRandIt + tbList[1];
		if nRand < nRandIt then
			self:AddTimes(nType, nGrade);
			GlobalExcute({"SpecialEvent.tbNewGateAward2012:Finsh", nPlayerId, nItemId, nType, nGrade});
			return;
		end
	end
end

function tbAward:AddTimes(nType, nGrade)
	if nType and self.tbTemp[nType] and self.tbTemp[nType][nGrade] and self.tbGlobalInt[nType] then
		local nNum = KGblTask.SCGetDbTaskInt(self.tbGlobalInt[nType]);	
		nNum = nNum + 1*(10^ (self.tbTemp[nType][nGrade][1] - 1));
		KGblTask.SCSetDbTaskInt(self.tbGlobalInt[nType], nNum);
	end
end

function tbAward:GetBitNum(nNum, nStar, nEnd)
	if not nNum or not nStar or not nEnd or nEnd < nStar then
		return 0;
	end
	return math.fmod(math.floor(nNum/(10 ^ (nStar - 1))), 10 ^ (nEnd - nStar + 1))
end

end

