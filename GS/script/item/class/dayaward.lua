-- 文件名　：dayaward.lua
-- 创建者　：jiazhenwei
-- 创建时间：2011-06-20 16:58:46
-- 功能    ：每天领取奖励礼包

local tbItem = Item:GetClass("dayaward");
local SZITEMFILE = "\\setting\\item\\001\\other\\dayaward.txt";

function tbItem:OnUse()
	if self.tbItemList == nil then
		self.tbItemList = self:GetItemList();
	end
	local szMsg = "这个礼包是每日领取的礼包，您每天可以领取一份奖励，直到领取完为止。";
	local tbOpt = {
		{"领取每日奖励", self.OnUseEx, self, it.dwId},
		{"Để ta suy nghĩ thêm"}
		};
	Dialog:Say(szMsg, tbOpt);
end

function tbItem:OnUseEx(nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local nKind = tonumber(pItem.GetExtParam(1));
	if not self.tbItemList[nKind] then
		me.Msg("道具有问题，请联系GM");
		return 0;
	end
	local nNum  = pItem.GetGenInfo(1);		--已经领取的第几份
	local nDate  = pItem.GetGenInfo(2);		--上一次领取的时间
	local nNowDate = tonumber(GetLocalDate("%y%m%d"));
	if nNowDate == nDate then
		me.Msg("今天的奖励已经领取完了，明天再来领取吧。");
		return 0;
	end
	local nFlag, szRetMsg = self:GetAward(nKind, nNum + 1, nItemId);
	if nFlag == 0 then
		me.Msg(szRetMsg);
		return 0;
	elseif ( nNum + 1 == #self.tbItemList[nKind]) then
		pItem.Delete(me);
	end
	return 0;	
end

--获取奖励
function tbItem:GetAward(nKind, nNum, nItemId)
	local pItem = KItem.GetObjById(nItemId);
	if not pItem then
		return 0;
	end
	local tbAward = self.tbItemList[nKind];
	if not tbAward[nNum] then
		return 0, "道具有问题，请联系GM";
	end
	tbAward = tbAward[nNum];
	local nNeedBag = 0;
	local nBindMoney = 0;	
	local nMoney = 0;
	for i = 1, #tbAward do
		if tbAward[i].szItem ~= "" then
			local tbItem = Lib:SplitStr(tbAward[i].szItem);
			local tbItemInfo = {};
			if tbAward[i].nBind > 0 then
				tbItemInfo.bForceBind = tbAward[i].nBind;
			end
			if tbAward[i].nTimeOut > 0 then
				tbItemInfo.bTimeOut = 1;
			end
			local nFreeCount = KItem.GetNeedFreeBag(tonumber(tbItem[1]), tonumber(tbItem[2]), tonumber(tbItem[3]), tonumber(tbItem[4]), tbItemInfo, tbAward[i].nCount);
			nNeedBag = nNeedBag + nFreeCount;
		end
		if tbAward[i].nBindMoney > 0 then
			nBindMoney = nBindMoney + tbAward[i].nBindMoney;
		end
		if tbAward[i].nMoney > 0 then
			nMoney = nMoney + tbAward[i].nMoney;
		end
	end
	--背包空间
	if me.CountFreeBagCell() < nNeedBag then	
		return 0, "Hành trang không đủ ，请留出"..nNeedBag.."格空间再试。";
	end
	-- 检查绑银
	if me.GetBindMoney() + nBindMoney > me.GetMaxCarryMoney() then		
		return 0, "领取后您身上的绑定银两将会超出上限，请整理后再来。";
	end	
	-- 检查银两
	if me.nCashMoney +nMoney > me.GetMaxCarryMoney() then		
		return 0, "领取后您身上的银两将会超出上限，请整理后再来。";
	end	
	self:GetAwardEx(nKind, nNum);
	pItem.SetGenInfo(1, pItem.GetGenInfo(1) + 1);
	pItem.SetGenInfo(2, tonumber(GetLocalDate("%y%m%d")));
	pItem.Sync();
	return 1;
end

--加奖励
function tbItem:GetAwardEx(nKind, nNum)
	local tbAward = self.tbItemList[nKind][nNum];
	for i = 1, #tbAward do
		local nNeedBag = 0;
		--获得称号
		if tbAward[i].szTitle ~= "" then
			local tbTitle = Lib:SplitStr(tbAward[i].szTitle);
			me.AddTitle(tonumber(tbTitle[1]), tonumber(tbTitle[2]), tonumber(tbTitle[3]), tonumber(tbTitle[4]));
			me.SetCurTitle(tonumber(tbTitle[1]), tonumber(tbTitle[2]), tonumber(tbTitle[3]), tonumber(tbTitle[4]));
		end
		--获得物品
		if tbAward[i].szItem ~= "" then
			local tbItem = Lib:SplitStr(tbAward[i].szItem);
			if tbAward[i].nTimeOut > 0 then				
				for j =  1, tbAward[i].nCount do
					local pItem = me.AddItem(tonumber(tbItem[1]), tonumber(tbItem[2]), tonumber(tbItem[3]), tonumber(tbItem[4]));
					if tbAward[i].nBind == 1 then
						pItem.Bind(1);
					end
					if tbAward[i].nTimeOut > 0 then						
						me.SetItemTimeout(pItem, tbAward[i].nTimeOut, 0);
					end
					local szAnnouce = string.format("恭喜您获得了<color=yellow>%s<color>", pItem.szName);
					me.Msg(szAnnouce);
					Dbg:WriteLog("每日奖励礼包获得物品",  me.szName, string.format("获得物品%s", pItem.szName));
				end
			else
				local nAddCount, szItemName =  me.AddStackItem(tbitem.nGenre, tbitem.nDetailType, tbitem.nParticularType, tbitem.nLevel, tbItemInfo, nCount);
				local szAnnouce = string.format("恭喜您获得了<color=yellow>%s<color>", pItem.szName);
				me.Msg(szAnnouce);
				Dbg:WriteLog("每日奖励礼包获得物品",  me.szName, string.format("获得物品%s", pItem.szName));
			end
		end
		--获得绑金
		if tbAward[i].nBindCoin > 0 then
			local nAddCoin = me.AddBindCoin(tbAward[i].nBindCoin, Player.emKBINDCOIN_ADD_EVENT); -- 只会加绑金
			local szAnnouce = string.format("恭喜您获得了<color=yellow>%s<color>绑定%s", tbAward[i].nBindCoin, IVER_g_szCoinName);
			me.Msg(szAnnouce);
			Dbg:WriteLog("每日奖励礼包获得物品",  me.szName, string.format("获得绑金%s", tbAward[i].nBindCoin));
		end
		--获得绑银
		if tbAward[i].nBindMoney > 0 then			
			me.AddBindMoney(tbAward[i].nBindMoney, Player.emKBINDMONEY_ADD_EVENT);
			local szAnnouce = string.format("恭喜您获得了<color=yellow>%s<color>绑定银两", tbAward[i].nBindMoney);
			me.Msg(szAnnouce);
			Dbg:WriteLog("每日奖励礼包获得物品",  me.szName, string.format("获得绑银%s", tbAward[i].nBindMoney));
		end
		--获得银两		
		if tbAward[i].nMoney > 0 then
			me.Earn(tbAward[i].nMoney, Player.emKEARN_EVENT);
			local szAnnouce = string.format("恭喜您获得了<color=yellow>%s<color>两", tbAward[i].nMoney);
			me.Msg(szAnnouce);
			Dbg:WriteLog("每日奖励礼包获得物品",  me.szName, string.format("获得银两%s", tbAward[i].nMoney));
		end
		--执行脚本
		if (tbAward[i].szFun and tbAward[i].szFun ~= "") then
		local nResult = self:GetVar(tbAward[i].szFun);
		if (nResult and nResult == 1) then
			Dbg:WriteLog("随机获得物品",  me.szName, string.format("随机获得了%s，执行了脚本函数，成功", tbAward[i].szFun));		
		else
			Dbg:WriteLog("随机获得物品",  me.szName, string.format("随机获得了%s，执行了脚本函数，失败", tbAward[i].szFun));		
		end
	end
	end
end

--执行脚本
function tbItem:GetVar(var, varDefault)
	local szType = type(var);
	local varResult = nil;
	if (szType == "function") then
		local bOk, varRet = Lib:CallBack({var});
		if (bOk) then
			varResult = varRet;
		end
	elseif(szType == "string") then	
	 	varResult = string.gsub(var, "<%%(.-)%%>", fnStrValue);
	elseif(szType == "number") then
		varResult = var;	
	else
		print("【Error】tbRandomItem:GetStrVal",var);--,debug.traceback());
	end
	return varResult or varDefault;
end

function tbItem:GetTip()
	if self.tbItemList == nil then
		self.tbItemList = self:GetItemList();
	end
	local nKind = tonumber(it.GetExtParam(1));
	if not self.tbItemList[nKind] then
		me.Msg("道具有问题，请联系GM");
		return 0;
	end
	local nNum  = it.GetGenInfo(1);		--已经领取的第几份
	local nDate  = it.GetGenInfo(2);		--上一次领取的时间
	local szMsg = "可以获得以下奖励<color>\n\n";
	local nNowDate = tonumber(GetLocalDate("%y%m%d"));
	local tbAward = self.tbItemList[nKind][nNum + 1];
	for i = 1, #tbAward do
		szMsg = szMsg..tbAward[i].szDesc.."\n";
	end
	if nNowDate == nDate then
		szMsg = "<color=red>明天"..szMsg;
	else
		szMsg = "<color=green>"..szMsg ;
	end
	return szMsg;
end

--读表
function tbItem:GetItemList()
	local tbClassItemList = {};
	local tbFile = Lib:LoadTabFile(SZITEMFILE);
	if not tbFile then
		print("每天领奖配置文件错误",szFileName);
		return;
	end	
	for nId, tbParam in ipairs(tbFile) do
		if nId >= 1 then
			local nClassParamID = tonumber(tbParam.nClassParamID) or 0;
			local nLevelId = tonumber(tbParam.nLevelId) or 0;
			local szTitle = tbParam.szTitle or "";	
			local szFun = tbParam.szFun or "";
			local szItem = tbParam.szItem or "";
			local nCount = tonumber(tbParam.nCount) or 1;
			local nBind = tonumber(tbParam.nBind) or 0;
			local nTimeOut = tonumber(tbParam.nTimeOut) or 0;
			local nBindCoin = tonumber(tbParam.nBindCoin) or 0;
			local nBindMoney = tonumber(tbParam.nBindMoney) or 0;
			local nMoney = tonumber(tbParam.nMoney) or 0;
			local szDesc = tbParam.Desc or "";
			tbClassItemList[nClassParamID] = tbClassItemList[nClassParamID] or {};
			tbClassItemList[nClassParamID][nLevelId] = tbClassItemList[nClassParamID][nLevelId] or {};
			table.insert(tbClassItemList[nClassParamID][nLevelId], {szTitle = szTitle, szItem = szItem, nBind = nBind, nTimeOut = nTimeOut, szFun = szFun, nBindCoin = nBindCoin, nBindMoney = nBindMoney, nMoney = nMoney, nCount = nCount, szDesc = szDesc}); 
		end
	end	
	return tbClassItemList;
end

tbItem.tbItemList = tbItem:GetItemList()
