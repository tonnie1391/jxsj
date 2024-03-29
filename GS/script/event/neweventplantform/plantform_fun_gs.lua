-- 文件名　：plantform_fun_gs.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-09-20 20:20:20
-- 功能    ：无差别竞技

local Fun = {};
NewEPlatForm.Fun = Fun;

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
	for _, tbFun in pairs(tbParam) do
		if tbFun[1] == "item" or tbFun[1] == "binditem" then
			local value  = tbFun[2];
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
	return nNeedFree;
end

function Fun:DoExcute(pPlayer, tbParam)
	for _, tbFun in pairs(tbParam) do		
		if self.tbParamFun[tbFun[1]] and self[self.tbParamFun[tbFun[1]]] then
			self[self.tbParamFun[tbFun[1]]](self, pPlayer, tbFun[2]);
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
		NewEPlatForm:WriteLog("Fun:ExeItem", "获取活动物品奖励失败，背包空间不足  " .. pPlayer.szName, unpack(value));
		return 0;
	end
	local nNowTime = GetTime();
	for i=1, nCount do
		local pItem = pPlayer.AddItem(unpack(tbItem));
		if (pItem) then
			if (nTime > 0) then
				local szDate = os.date("%Y/%m/%d/%H/%M/%S", nNowTime + nTime * 60);
				pPlayer.SetItemTimeout(pItem, szDate);
				NewEPlatForm:WriteLog("Fun:ExeItem", "获取活动物品奖励成功  " .. pPlayer.szName, unpack(value));
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
		NewEPlatForm:WriteLog("Fun:ExeBindItem", "获取活动物品奖励失败，背包空间不足  " .. pPlayer.szName, unpack(value));
		return 0;
	end

	local nNowTime = GetTime();
	--69天后启用高级奖励nlevel+1
	if TimeFrame:GetServerOpenDay() > 69 and tbItem[3] >= 1481 and tbItem[3] <= 1483 then
		tbItem[4] = tbItem[4] + 1;
	end
	for i=1, nCount do
		local pItem = pPlayer.AddItem(unpack(tbItem));
		if (pItem) then
			pItem.Bind(1);
			if (nTime > 0) then
				local szDate = os.date("%Y/%m/%d/%H/%M/%S", nNowTime + nTime * 60);
				pPlayer.SetItemTimeout(pItem, szDate);
			end
			NewEPlatForm:WriteLog("Fun:ExeBindItem", "获取活动物品奖励成功  " .. pPlayer.szName, unpack(value));
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
