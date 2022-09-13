--武林联赛
--孙多良
--2008.10.13
local Fun = {};
EPlatForm.Fun = Fun;

Fun.tbParamFun = 
{
	["exp"] 	= "ExeExp",			--经验,单位万
	expbase 	= "ExeExpbase",		--基准经验
	repute 		= "ExeRepute",		--声望
	item 		= "ExeItem", 		--物品
	title 		= "ExeTitle", 		--称号
	binditem 	= "ExeBindItem", 	--绑定物品
	prestige	= "ExePrestige",	--江湖威望
	stock		= "ExeStock",		--股份
}
function Fun:GetNeedFree(tbParam)
	local nNeedFree = 0;
	for szFun, tbFun in pairs(tbParam) do
		if szFun == "item" or szFun == "binditem" then
			for _, value in pairs(tbFun) do		
				local nCount = 1;
				if (value[6]) then
					nCount = value[6];
					if (type(nCount) == "string") then
						nCount = tonumber(nCount);
					end
					if (nCount <= 0) then
						nCount = 1;
					end
				end
				nNeedFree = nNeedFree + nCount;
			end
		end
	end
	return nNeedFree;
end

function Fun:DoExcute(pPlayer, tbParam)
	for szFun, tbFun in pairs(tbParam) do
		for _, value in pairs(tbFun) do
			if self.tbParamFun[szFun] and self[self.tbParamFun[szFun]] then
				self[self.tbParamFun[szFun]](self, pPlayer, value);
			end
		end
	end
end

--时间显示转换
function Fun:Number2Time(nTime)
	local nMin = math.mod(nTime, 100);
	local nHour = math.floor(nTime/ 100);
	local szMin = nMin;
	if nMin < 10 then
		szMin = "0" .. nMin;
	end
	local szTime = nHour .. ":" .. szMin;
	return szTime
end 

function Fun:ExeExp(pPlayer, value)
	pPlayer.AddExp(tonumber(value*10000));
end

function Fun:ExeExpbase(pPlayer, value)
	pPlayer.AddExp(pPlayer.GetBaseAwardExp() * value);
end

function Fun:ExeRepute(pPlayer, value)
	--增加声望
	pPlayer.AddRepute(7, 1, value);
end

function Fun:ExeItem(pPlayer, value)
	--获得物品
	
	local nTime = 0;
	local nCount = 1;
	local tbItem = Lib:CopyTB1(value);

	if (tbItem[6] and tbItem[6] > 0) then
		nCount = tbItem[6];
		tbItem[6] = nil;
	end
	
	if (tbItem[5] and tbItem[5] > 0) then
		nTime = tbItem[5];
		tbItem[5] = nil;
	end
	
	if pPlayer.CountFreeBagCell() < nCount then
		pPlayer.Msg(string.format("由于您的背包空间已满，无法获得<color=yellow>%s<color>", KItem.GetNameById(unpack(tbItem))));
		EPlatForm:WriteLog("Fun:ExeItem", "获取活动物品奖励失败，背包空间不足  " .. pPlayer.szName, unpack(value));
		return 0;
	end
	local nNowTime = GetTime();
	for i=1, nCount do
		local pItem = pPlayer.AddItem(unpack(tbItem));
		if (pItem) then
			if (nTime > 0) then
				local szDate = os.date("%Y/%m/%d/%H/%M/%S", nNowTime + nTime * 60);
				pPlayer.SetItemTimeout(pItem, szDate);
				EPlatForm:WriteLog("Fun:ExeItem", "获取活动物品奖励成功  " .. pPlayer.szName, unpack(value));
			end
		end
	end
end

function Fun:ExeTitle(pPlayer, value)
	--获得称号.
	pPlayer.AddTitle(unpack(value));
	pPlayer.SetCurTitle(unpack(value));
end

function Fun:ExeBindItem(pPlayer, value)
	--获得物品
	local nTime = 0;
	local nCount = 1;
	local tbItem = Lib:CopyTB1(value);

	if (tbItem[6] and tbItem[6] > 0) then
		nCount = tbItem[6];
		tbItem[6] = nil;
	end
	
	if (tbItem[5] and tbItem[5] > 0) then
		nTime = tbItem[5];
		tbItem[5] = nil;
	end
	
	if pPlayer.CountFreeBagCell() < nCount then
		pPlayer.Msg(string.format("由于您的背包空间已满，无法获得<color=yellow>%s<color>", KItem.GetNameById(unpack(tbItem))));
		EPlatForm:WriteLog("Fun:ExeBindItem", "获取活动物品奖励失败，背包空间不足  " .. pPlayer.szName, unpack(value));
		return 0;
	end

	local nNowTime = GetTime();
	for i=1, nCount do
		local pItem = pPlayer.AddItem(unpack(tbItem));
		if (pItem) then
			pItem.Bind(1);
			if (nTime > 0) then
				local szDate = os.date("%Y/%m/%d/%H/%M/%S", nNowTime + nTime * 60);
				pPlayer.SetItemTimeout(pItem, szDate);
			end
			EPlatForm:WriteLog("Fun:ExeBindItem", "获取活动物品奖励成功  " .. pPlayer.szName, unpack(value));
		end
	end	
end

--增加江湖威望
function Fun:ExePrestige(pPlayer, value)
	pPlayer.AddKinReputeEntry(value, "wlls");
end

--增加建设资金和个人、族长、帮主股份
function Fun:ExeStock(pPlayer, value)
	Tong:AddStockBaseCount_GS1(pPlayer.nId, value, 0.75, 0.15, 0.05, 0, 0.05);
end
