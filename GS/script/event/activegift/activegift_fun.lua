-- 文件名　：activegift_fun.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-11-01 17:22:33
-- 功能    ：
SpecialEvent.ActiveGift = SpecialEvent.ActiveGift or {};
local ActiveGift = SpecialEvent.ActiveGift;

ActiveGift.tbParamFun = 
{
	exp 		= "ExeExp",		--经验,单位万
	expbase 	= "ExeExpbase",	--基准经验	
	title 		= "ExeTitle", 		--称号
	binditem 	= "ExeBindItem", 	--绑定物品
	prestige	= "ExePrestige",	--江湖威望	
	customItem = "ExeCust0mItem",	--自定义物品（用任务的自定义物品）
	bindmoney 	= "ExeBindMoney", 	--绑银
	bindcoin 		= "ExeBindCoin", 	--绑金
	xiayi			= "ExeXiaYi",		--狭义值
}

function ActiveGift:CheckGetAward(pPlayer, tbParam)
	local nNeedBag = self:GetNeedFree(tbParam);
	if pPlayer.CountFreeBagCell() < nNeedBag then
		return 0, string.format("Hành trang không đủ <color=yellow>%s<color> ô.", nNeedBag);
	end
	local nBindMoney = self:GetBindMoney(tbParam);
	if pPlayer.GetBindMoney() + nBindMoney > pPlayer.GetMaxCarryMoney() then
		return 0, "你的绑定银两携带达上限了，无法获得绑定银两。";
	end
	return 1;
end

function ActiveGift:GetNeedFree(tbParam)
	local nNeedFree = 0;
	for _, tbFun in pairs(tbParam) do
		if tbFun[1] == "binditem" then
			local nCount = 1;
			if (tbFun[2][6]) then
				nCount = tbFun[2][6];
				if (type(nCount) == "string") then
					nCount = tonumber(nCount);
				end
				if (nCount <= 0) then
					nCount = 1;
				end
			end
			nNeedFree = nNeedFree + nCount;
		elseif tbFun[1] == "customItem" then
			nNeedFree = nNeedFree + 1;
		end
	end
	return nNeedFree;
end

function ActiveGift:GetBindMoney(tbParam)
	local nMoney = 0;
	for _, tbFun in pairs(tbParam) do
		if tbFun[1] == "bindmoney" then
			nMoney = nMoney + tbFun[2];	
		end
	end
	return nMoney;	
end

function ActiveGift:DoExcute(pPlayer, tbParam)
	for _, tbFun in pairs(tbParam) do
		if self.tbParamFun[tbFun[1]] and self[self.tbParamFun[tbFun[1]]] then
			self[self.tbParamFun[tbFun[1]]](self, pPlayer, tbFun[2]);
		end
	end
end

--时间显示转换
function ActiveGift:Number2Time(nTime)
	local nMin = math.mod(nTime, 100);
	local nHour = math.floor(nTime/ 100);
	local szMin = nMin;
	if nMin < 10 then
		szMin = "0" .. nMin;
	end
	local szTime = nHour .. ":" .. szMin;
	return szTime
end 

function ActiveGift:ExeExp(pPlayer, value)
	pPlayer.AddExp(tonumber(value*10000));
end

function ActiveGift:ExeExpbase(pPlayer, value)
	pPlayer.AddExp(pPlayer.GetBaseAwardExp() * value);
end

function ActiveGift:ExeTitle(pPlayer, value)
	--获得称号.
	pPlayer.AddTitle(unpack(value));
end

function ActiveGift:ExeBindItem(pPlayer, value)
	--获得物品
	local nTime = 0;
	local nCount = 1;
	local tbItem = Lib:CopyTB1(value);
	local nSex = -1;
	
	if tbItem[7] and tbItem[7] >= 0 then
		nSex = tbItem[7];
	end
	--绑定物品如果是有区别男女的做限制条件，不符合的不给
	if pPlayer.nSex ~= nSex and nSex >= 0 then
		return;
	end	
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
		end
	end	
end

function ActiveGift:ExeXiaYi(pPlayer, value)
	local nTotal = Achievement:GetConsumeablePoint(pPlayer)
	Achievement:SetConsumablePoint(pPlayer, nTotal + value);
	pPlayer.Msg("增加侠义值<color=yellow>"..value.."<color>");
end

--增加江湖威望
function ActiveGift:ExePrestige(pPlayer, value)
	pPlayer.AddKinReputeEntry(value);
end

function ActiveGift:ExeCust0mItem(pPlayer, value)
	Task:Get_CustomEquip(10000, value)
end


function ActiveGift:ExeBindMoney(pPlayer, value)
	if pPlayer.GetBindMoney() + value > pPlayer.GetMaxCarryMoney() then
		pPlayer.Msg("你的绑定银两携带达上限了，无法获得绑定银两。");
		return 0;
	end
	pPlayer.AddBindMoney(value);
end

function ActiveGift:ExeBindCoin(pPlayer, value)
	pPlayer.AddBindCoin(value);
end
