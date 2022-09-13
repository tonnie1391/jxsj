--武林联赛
--孙多良
--2008.10.13
local Fun = {};
Wlls.Fun = Fun;

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
	bindmoney	= "ExeBindMoney",	--绑定银两
	stone_stackitem	= "ExeStoneStackItem",	--叠加道具
}
function Fun:GetNeedFree(tbParam)
	local nNeedFree = 0;
	for szFun, tbFun in pairs(tbParam) do
		for _, value in pairs(tbFun) do
			if szFun == "item" or szFun == "binditem" then
				nNeedFree = nNeedFree + 1;
			elseif szFun == "stone_stackitem" then
				if (Item.tbStone:GetOpenDay() ~= 0) then	-- 宝石系统没开放
					nNeedFree = nNeedFree + value[6];  -- value:g,d,p,l,count,bagneed
				end
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
--成就		
	local nMyWin 	= pPlayer.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_WIN);
	local nSession 	= pPlayer.GetTask(Wlls.TASKID_GROUP, Wlls.TASKID_HELP_SESSION);
	local nMathType = Wlls:GetMacthType(nSession);
	local tbAchievement = Wlls.tbAchievementWin;
	if not GLOBAL_AGENT and tbAchievement[nMathType] then
		for nNeedWin, nAchievementId in pairs(tbAchievement[nMathType]) do
			if nMyWin >= nNeedWin then
				Achievement:FinishAchievement(pPlayer, nAchievementId);
			end
		end
	end
--成就	end
	
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
	local nReputeExt = Item:GetClass("reputeaccelerate"):GetAndUseExtRepute(pPlayer, 7, 1, value, 1);
	pPlayer.AddRepute(7, 1, value + nReputeExt);
end

function Fun:ExeItem(pPlayer, value)
	--获得物品
	if pPlayer.CountFreeBagCell() < 1 then
		pPlayer.Msg(string.format("Hành trang không đủ <color=yellow>%s<color> ô trống", KItem.GetNameById(unpack(value))));
		return 0;
	end	
	pPlayer.AddItem(unpack(value))
end

function Fun:ExeTitle(pPlayer, value)
	--获得称号.
	pPlayer.AddTitle(unpack(value));
	pPlayer.SetCurTitle(unpack(value));
end

function Fun:ExeBindItem(pPlayer, value)
	--获得物品
	if pPlayer.CountFreeBagCell() < 1 then
		pPlayer.Msg(string.format("Hành trang không đủ <color=yellow>%s<color> ô trống", KItem.GetNameById(unpack(value))));
		return 0;
	end
	local pItem = pPlayer.AddItem(unpack(value));
	if pItem then
		pItem.Bind(1);
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

function Fun:ExeBindMoney(pPlayer, value)
	pPlayer.AddBindMoney(tonumber(value), Player.emKBINDMONEY_ADD_EVENT);
	Wlls:WriteLog(string.format("武林联赛获得绑定银两：%s", value), pPlayer.nId);
end

function Fun:ExeStoneStackItem(pPlayer, value)
	if (Item.tbStone:GetOpenDay() == 0) then	-- 宝石系统没开放
		return;
	end
	local nBagNeed = value[6];
	if (pPlayer.CountFreeBagCell() < nBagNeed) then
		pPlayer.Msg(string.format("Hành trang không đủ <color=yellow>%s<color>", 
				KItem.GetNameById(value[1],value[2],value[3],value[4])));
		return 0;		
	end
	--value[6] = nil;
	--table.insert(value, 5, nil);
	pPlayer.AddStackItem(value[1], value[2], value[3], value[4], nil, value[5]);
	StatLog:WriteStatLog("stat_info", "baoshixiangqian", "advanced", pPlayer.nId, string.format("%d_%d_%d_%d", 
						value[1],value[2],value[3],value[4]), value[5]);
	
end
